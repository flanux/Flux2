#!/bin/bash
# FLUX v2.0 - Master Service Fix Script
# Fixes PostgreSQL driver issues in ALL microservices

set -e

echo "🔧 FLUX Master Service Repair"
echo "=============================="
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
    echo "🔧 Fixing $SERVICE..."
    
    POM_FILE="services/$SERVICE/pom.xml"
    
    if [ ! -f "$POM_FILE" ]; then
        echo "❌ $POM_FILE not found! Skipping..."
        continue
    fi
    
    # Check if PostgreSQL dependency exists
    if grep -q "postgresql" "$POM_FILE"; then
        echo "   ✓ PostgreSQL dependency found"
        
        # Fix: Make sure it's in runtime scope (not test scope)
        sed -i.bak 's|<scope>test</scope>.*</dependency>.*postgresql|<scope>runtime</scope>\n    </dependency>|g' "$POM_FILE"
        
        # Or add it if missing scope
        if ! grep -A2 "postgresql" "$POM_FILE" | grep -q "scope"; then
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
        </dependency>\
' "$POM_FILE"
    fi
    
    # Remove H2 from runtime if it exists
    if grep -q "h2.*runtime" "$POM_FILE"; then
        echo "   🗑️  Removing H2 from runtime scope..."
        sed -i.bak 's|<scope>runtime</scope>.*h2|<scope>test</scope>|g' "$POM_FILE"
    fi
    
    echo "   ✅ Fixed!"
    echo ""
done

echo ""
echo "🔧 Fixing API Gateway Redis config..."

GATEWAY_CONFIG="bank-api-gateway/src/main/resources/application-docker.yml"

if [ -f "$GATEWAY_CONFIG" ]; then
    # Fix Redis host from localhost to redis
    sed -i.bak 's/host: localhost/host: redis/g' "$GATEWAY_CONFIG"
    echo "   ✅ Fixed Redis host!"
else
    echo "   ⚠️  Gateway config not found at: $GATEWAY_CONFIG"
fi

echo ""
echo "✅ ALL FIXES APPLIED!"
echo ""
echo "Next steps:"
echo "1. Rebuild everything: docker compose down -v && docker compose up --build -d"
echo "2. Wait 2 minutes for services to start"
echo "3. Check status: docker compose ps"
echo ""
