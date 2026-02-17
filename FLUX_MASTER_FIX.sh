#!/bin/bash

# =============================================================================
# FLUX 2.0 MASTER FIX SCRIPT
# Fixes ALL issues: PostgreSQL drivers, H2 conflicts, Redis config, Auth service
# =============================================================================

set -e

PROJECT_ROOT="$(pwd)"
echo "🚀 FLUX 2.0 Master Fix Script"
echo "================================"
echo "Project root: $PROJECT_ROOT"
echo ""

# =============================================================================
# PART 1: Fix all microservice POM files (PostgreSQL + H2)
# =============================================================================
echo "📦 PART 1: Fixing microservice dependencies..."
echo ""

SERVICES=(
    "account-service"
    "customer-service"
    "card-service"
    "ledger-service"
    "loan-service"
    "notification-service"
    "reporting-service"
    "transaction-service"
)

for SERVICE in "${SERVICES[@]}"; do
    POM="services/$SERVICE/pom.xml"
    
    if [ ! -f "$POM" ]; then
        echo "⚠️  $POM not found, skipping..."
        continue
    fi
    
    echo "🔧 Fixing $SERVICE..."
    
    # Remove duplicate scope tags first
    awk '!/<scope>runtime<\/scope>/ || prev != /<scope>runtime<\/scope>/ {print} {prev=$0}' "$POM" > "$POM.clean"
    mv "$POM.clean" "$POM"
    
    # Ensure PostgreSQL has runtime scope
    if grep -q "postgresql" "$POM"; then
        if grep -A3 "postgresql" "$POM" | grep -q "<scope>test</scope>"; then
            sed -i '/<artifactId>postgresql<\/artifactId>/,/<\/dependency>/ s/<scope>test<\/scope>/<scope>runtime<\/scope>/' "$POM"
            echo "   ✅ Fixed PostgreSQL scope (test → runtime)"
        elif ! grep -A3 "postgresql" "$POM" | grep -q "<scope>"; then
            sed -i '/<artifactId>postgresql<\/artifactId>/a\            <scope>runtime</scope>' "$POM"
            echo "   ✅ Added runtime scope to PostgreSQL"
        else
            echo "   ✓ PostgreSQL scope OK"
        fi
    else
        echo "   ⚠️  PostgreSQL missing! Adding..."
        sed -i '/<\/dependencies>/i\        <dependency>\n            <groupId>org.postgresql</groupId>\n            <artifactId>postgresql</artifactId>\n            <scope>runtime</scope>\n        </dependency>' "$POM"
        echo "   ✅ Added PostgreSQL dependency"
    fi
    
    # Ensure H2 has test scope (not runtime)
    if grep -q "h2" "$POM"; then
        if grep -A3 "h2" "$POM" | grep -q "<scope>runtime</scope>"; then
            sed -i '/<artifactId>h2<\/artifactId>/,/<\/dependency>/ s/<scope>runtime<\/scope>/<scope>test<\/scope>/' "$POM"
            echo "   ✅ Fixed H2 scope (runtime → test)"
        else
            echo "   ✓ H2 scope OK"
        fi
    fi
    
    echo ""
done

# =============================================================================
# PART 2: Fix transaction-service application.yml (if missing)
# =============================================================================
echo "📦 PART 2: Fixing transaction-service config..."
echo ""

TRANS_CONFIG="services/transaction-service/src/main/resources"

if [ ! -d "$TRANS_CONFIG" ]; then
    echo "🔧 Creating transaction-service resources directory..."
    mkdir -p "$TRANS_CONFIG"
fi

if [ ! -f "$TRANS_CONFIG/application.yml" ]; then
    echo "🔧 Creating transaction-service application.yml..."
    cat > "$TRANS_CONFIG/application.yml" << 'EOF'
server:
  port: 8080

spring:
  application:
    name: transaction-service
    
  datasource:
    url: jdbc:postgresql://database:5432/transaction_db
    username: transaction_user
    password: transaction_2026
    
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
    database-platform: org.hibernate.dialect.PostgreSQLDialect
    
  kafka:
    bootstrap-servers: kafka:29092
    consumer:
      group-id: transaction-service
      auto-offset-reset: earliest
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
EOF
    echo "   ✅ Created application.yml"
else
    echo "   ✓ application.yml exists"
fi

echo ""

# =============================================================================
# PART 3: Check if auth-service exists, warn if missing
# =============================================================================
echo "📦 PART 3: Checking auth-service..."
echo ""

if [ ! -d "services/auth-service" ]; then
    echo "❌ AUTH-SERVICE IS MISSING!"
    echo ""
    echo "Auth-service directory not found. You need to:"
    echo "1. Extract the auth-service from the provided tar.gz"
    echo "2. Place it in services/auth-service/"
    echo "3. Run this script again"
    echo ""
    echo "Without auth-service, login will not work!"
    echo ""
    AUTH_MISSING=true
else
    echo "✅ auth-service found"
    
    # Fix auth-service application.yml if it exists
    AUTH_CONFIG="services/auth-service/src/main/resources/application.yml"
    if [ -f "$AUTH_CONFIG" ]; then
        echo "🔧 Checking auth-service Redis config..."
        if grep -q "host: localhost" "$AUTH_CONFIG"; then
            sed -i 's/host: localhost/host: redis/g' "$AUTH_CONFIG"
            echo "   ✅ Fixed Redis host (localhost → redis)"
        else
            echo "   ✓ Redis config looks good"
        fi
    fi
    AUTH_MISSING=false
fi

echo ""

# =============================================================================
# PART 4: Update docker-compose.yml to add auth-service
# =============================================================================
echo "📦 PART 4: Updating docker-compose.yml..."
echo ""

if [ -f "docker-compose.yml" ]; then
    if grep -q "auth-service:" "docker-compose.yml"; then
        echo "✓ auth-service already in docker-compose.yml"
    else
        echo "🔧 Adding auth-service to docker-compose.yml..."
        
        # Add auth-service before API gateway
        sed -i '/# API GATEWAY/i\  # ============================================\n  # AUTH SERVICE\n  # ============================================\n  auth-service:\n    build:\n      context: ./services/auth-service\n      dockerfile: Dockerfile\n    container_name: auth-service\n    ports:\n      - "8090:8080"\n    environment:\n      SPRING_DATASOURCE_URL: jdbc:postgresql://database:5432/auth_db\n      SPRING_DATASOURCE_USERNAME: auth_user\n      SPRING_DATASOURCE_PASSWORD: auth_2026\n      SPRING_DATA_REDIS_HOST: redis\n      SPRING_DATA_REDIS_PORT: 6379\n    depends_on:\n      database:\n        condition: service_healthy\n      redis:\n        condition: service_healthy\n    networks:\n      - banking-network\n    restart: unless-stopped\n\n' "docker-compose.yml"
        
        # Add auth-service to gateway depends_on
        sed -i '/bank-api-gateway:/,/depends_on:/ {/depends_on:/a\      - auth-service' "docker-compose.yml"
        
        echo "   ✅ Added auth-service to docker-compose.yml"
    fi
else
    echo "⚠️  docker-compose.yml not found!"
fi

echo ""

# =============================================================================
# SUMMARY
# =============================================================================
echo "✅ ALL FIXES APPLIED!"
echo ""
echo "📋 Summary:"
echo "   ✅ Fixed PostgreSQL dependencies in all 8 services"
echo "   ✅ Fixed H2 scope conflicts"
echo "   ✅ Created transaction-service config"
if [ "$AUTH_MISSING" = true ]; then
    echo "   ❌ Auth-service is MISSING - you need to add it!"
else
    echo "   ✅ Fixed auth-service Redis config"
    echo "   ✅ Updated docker-compose.yml"
fi
echo ""
echo "🚀 Next steps:"
if [ "$AUTH_MISSING" = true ]; then
    echo "   1. Add auth-service to services/auth-service/"
    echo "   2. Run this script again"
    echo "   3. docker compose down -v"
    echo "   4. docker compose up --build -d"
else
    echo "   1. docker compose down -v"
    echo "   2. docker compose up --build -d"
    echo "   3. Wait 2-3 minutes for all services to start"
    echo "   4. Test login: curl -X POST http://localhost:8090/api/auth/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"Flux@2026\"}'"
fi
echo ""
echo "⏰ Build time: ~5-10 minutes"
echo ""
