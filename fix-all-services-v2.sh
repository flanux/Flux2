#!/bin/bash
# FLUX v2.0 - Universal Service Fix Script
# Handles different config file locations

set -e

echo "🔧 FLUX Universal Service Repair"
echo "================================="
echo ""

# Fix all microservices POM files
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
    echo "🔧 Fixing $SERVICE..."
    
    POM_FILE="services/$SERVICE/pom.xml"
    
    if [ ! -f "$POM_FILE" ]; then
        echo "   ❌ $POM_FILE not found! Skipping..."
        continue
    fi
    
    # Check if PostgreSQL dependency exists
    if grep -q "postgresql" "$POM_FILE"; then
        echo "   ✓ PostgreSQL dependency found"
        
        # Fix scope if it's in test
        if grep -A2 "postgresql" "$POM_FILE" | grep -q "<scope>test</scope>"; then
            echo "   🔧 Fixing PostgreSQL scope from test to runtime..."
            # Create temp file with fix
            awk '
                /<artifactId>postgresql<\/artifactId>/ {
                    print
                    getline
                    if ($0 ~ /<scope>test<\/scope>/) {
                        print "            <scope>runtime</scope>"
                    } else {
                        print
                    }
                    next
                }
                {print}
            ' "$POM_FILE" > "$POM_FILE.tmp"
            mv "$POM_FILE.tmp" "$POM_FILE"
        fi
        
        # Add scope if missing
        if grep -A2 "postgresql" "$POM_FILE" | grep -v "scope" | grep -q "</dependency>"; then
            echo "   🔧 Adding runtime scope to PostgreSQL..."
            sed -i.bak '/<artifactId>postgresql<\/artifactId>/a\            <scope>runtime</scope>' "$POM_FILE"
        fi
    else
        echo "   ⚠️  PostgreSQL dependency MISSING! Adding it..."
        
        # Add PostgreSQL dependency before </dependencies>
        sed -i.bak '/<\/dependencies>/i\
        <dependency>\
            <groupId>org.postgresql</groupId>\
            <artifactId>postgresql</artifactId>\
            <scope>runtime</scope>\
        </dependency>' "$POM_FILE"
    fi
    
    # Fix H2 to test scope if it's in runtime
    if grep -A2 "h2" "$POM_FILE" | grep -q "<scope>runtime</scope>"; then
        echo "   🗑️  Fixing H2 scope to test..."
        awk '
            /<artifactId>h2<\/artifactId>/ {
                print
                getline
                if ($0 ~ /<scope>runtime<\/scope>/) {
                    print "            <scope>test</scope>"
                } else {
                    print
                }
                next
            }
            {print}
        ' "$POM_FILE" > "$POM_FILE.tmp"
        mv "$POM_FILE.tmp" "$POM_FILE"
    fi
    
    echo "   ✅ Fixed!"
    echo ""
done

echo ""
echo "🔧 Fixing API Gateway Redis config..."
echo ""

# Find all possible config files in gateway
GATEWAY_CONFIGS=(
    "bank-api-gateway/src/main/resources/application.yml"
    "bank-api-gateway/src/main/resources/application.yaml"
    "bank-api-gateway/src/main/resources/application-docker.yml"
    "bank-api-gateway/src/main/resources/application-docker.yaml"
    "bank-api-gateway/src/main/resources/application-prod.yml"
    "bank-api-gateway/src/main/resources/application.properties"
)

FOUND_CONFIG=false

for CONFIG in "${GATEWAY_CONFIGS[@]}"; do
    if [ -f "$CONFIG" ]; then
        echo "   📄 Found: $CONFIG"
        
        # Fix YAML files
        if [[ "$CONFIG" == *.yml ]] || [[ "$CONFIG" == *.yaml ]]; then
            if grep -q "host: localhost" "$CONFIG" 2>/dev/null; then
                echo "   🔧 Fixing Redis host localhost -> redis"
                sed -i.bak 's/host: localhost/host: redis/g' "$CONFIG"
                echo "   ✅ Fixed!"
                FOUND_CONFIG=true
            elif grep -q "host: 127.0.0.1" "$CONFIG" 2>/dev/null; then
                echo "   🔧 Fixing Redis host 127.0.0.1 -> redis"
                sed -i.bak 's/host: 127.0.0.1/host: redis/g' "$CONFIG"
                echo "   ✅ Fixed!"
                FOUND_CONFIG=true
            else
                echo "   ℹ️  Redis config looks good or not found in this file"
            fi
        fi
        
        # Fix Properties files
        if [[ "$CONFIG" == *.properties ]]; then
            if grep -q "spring.redis.host=localhost" "$CONFIG" 2>/dev/null; then
                echo "   🔧 Fixing Redis host localhost -> redis"
                sed -i.bak 's/spring.redis.host=localhost/spring.redis.host=redis/g' "$CONFIG"
                echo "   ✅ Fixed!"
                FOUND_CONFIG=true
            elif grep -q "spring.redis.host=127.0.0.1" "$CONFIG" 2>/dev/null; then
                echo "   🔧 Fixing Redis host 127.0.0.1 -> redis"
                sed -i.bak 's/spring.redis.host=127.0.0.1/spring.redis.host=redis/g' "$CONFIG"
                echo "   ✅ Fixed!"
                FOUND_CONFIG=true
            fi
        fi
    fi
done

if [ "$FOUND_CONFIG" = false ]; then
    echo "   ℹ️  No Redis config found in gateway - might be using defaults or environment variables"
    echo "   This is OK if Redis is configured via docker-compose environment variables"
fi

# Clean up backup files
find services -name "*.bak" -delete 2>/dev/null || true
find bank-api-gateway -name "*.bak" -delete 2>/dev/null || true

echo ""
echo "✅ ALL FIXES APPLIED!"
echo ""
echo "📋 Summary:"
echo "   - Fixed PostgreSQL driver in 8 microservices"
echo "   - Fixed H2 scope conflicts"
echo "   - Fixed Redis config (if found)"
echo ""
echo "🚀 Next steps:"
echo "   1. docker compose down -v"
echo "   2. docker compose up --build -d"
echo "   3. docker compose logs -f"
echo ""
echo "⏰ Build time: ~5-10 minutes"
echo "⏰ Wait time after build: ~2 minutes for all services to start"
echo ""
