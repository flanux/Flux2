#!/bin/bash

echo "=========================================="
echo "  BANKING SYSTEM - HEALTH CHECK"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_service() {
  local url=$1
  local name=$2
  
  if curl -s -f "$url" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $name"
    return 0
  else
    echo -e "${RED}✗${NC} $name"
    return 1
  fi
}

echo "Checking Backend Services:"
echo ""
check_service "http://localhost:8081/actuator/health" "Account Service (8081)"
check_service "http://localhost:8082/actuator/health" "Customer Service (8082)"
check_service "http://localhost:8083/actuator/health" "Card Service (8083)"
check_service "http://localhost:8084/actuator/health" "Ledger Service (8084)"
check_service "http://localhost:8085/actuator/health" "Notification Service (8085)"
check_service "http://localhost:8086/actuator/health" "Reporting Service (8086)"
check_service "http://localhost:8087/actuator/health" "Loan Service (8087)"
check_service "http://localhost:8088/actuator/health" "Transaction Service (8088)"
check_service "http://localhost:8089/actuator/health" "API Gateway (8089)"

echo ""
echo "Checking Frontend Services:"
echo ""
check_service "http://localhost:3000" "Customer Portal (3000)"
check_service "http://localhost:3001" "Branch Dashboard (3001)"
check_service "http://localhost:3002" "Central Bank Portal (3002)"

echo ""
echo "Checking Infrastructure:"
echo ""

# Check database
if docker-compose exec -T database pg_isready -U admin > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} PostgreSQL (5432)"
else
  echo -e "${RED}✗${NC} PostgreSQL (5432)"
fi

# Check Kafka
if docker-compose exec -T kafka kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Kafka (9092)"
else
  echo -e "${RED}✗${NC} Kafka (9092)"
fi

echo ""
echo "=========================================="
