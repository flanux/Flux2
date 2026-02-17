#!/bin/bash

# Run All Tests
# Executes unit tests for all services and generates report

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  RUNNING ALL UNIT TESTS${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

passed=0
failed=0

# Function to run tests for a service
run_service_tests() {
    local service=$1
    local service_dir="services/$service"
    
    echo -e "${YELLOW}Testing $service...${NC}"
    
    cd "$service_dir"
    
    if ./mvnw test -q > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $service PASSED${NC}"
        ((passed++))
    else
        echo -e "${RED}✗ $service FAILED${NC}"
        ((failed++))
    fi
    
    cd ../..
}

# Test all services
services=(
    "account-service"
    "customer-service"
    "card-service"
    "ledger-service"
    "loan-service"
    "notification-service"
    "reporting-service"
    "transaction-service"
)

for service in "${services[@]}"; do
    run_service_tests "$service"
done

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  TEST RESULTS${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo -e "${GREEN}Passed:${NC} $passed"
echo -e "${RED}Failed:${NC} $failed"
echo -e "Total:  $((passed + failed))"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    exit 1
fi
