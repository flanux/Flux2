#!/bin/bash

# Integration Tests
# Tests the entire system end-to-end

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

API_URL="http://localhost:8089"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  INTEGRATION TESTS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

passed=0
failed=0

# Test function
test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    
    echo -n "Testing: $name... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "%{http_code}" -o /dev/null "$API_URL$endpoint")
    else
        response=$(curl -s -w "%{http_code}" -o /dev/null -X "$method" "$API_URL$endpoint" \
          -H "Content-Type: application/json" \
          -d "$data")
    fi
    
    if [ "$response" = "200" ] || [ "$response" = "201" ]; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((passed++))
    else
        echo -e "${RED}✗ FAIL (HTTP $response)${NC}"
        ((failed++))
    fi
}

echo -e "${YELLOW}1. Testing Infrastructure${NC}"
echo "----------------------------"
test_endpoint "API Gateway Health" "GET" "/actuator/health" ""
test_endpoint "Account Service Health" "GET" "/actuator/health" ""
test_endpoint "Customer Service Health" "GET" "/actuator/health" ""

echo ""
echo -e "${YELLOW}2. Testing Customer Service${NC}"
echo "----------------------------"
test_endpoint "Get All Customers" "GET" "/customers" ""
test_endpoint "Create Customer" "POST" "/customers" '{
  "firstName": "Test",
  "lastName": "User",
  "email": "test@example.com",
  "phone": "555-1234"
}'

echo ""
echo -e "${YELLOW}3. Testing Account Service${NC}"
echo "----------------------------"
test_endpoint "Get All Accounts" "GET" "/accounts" ""

echo ""
echo -e "${YELLOW}4. Testing Transaction Service${NC}"
echo "----------------------------"
test_endpoint "Get All Transactions" "GET" "/transactions" ""

echo ""
echo -e "${YELLOW}5. Testing Card Service${NC}"
echo "----------------------------"
test_endpoint "Get All Cards" "GET" "/cards" ""

echo ""
echo -e "${YELLOW}6. Testing Loan Service${NC}"
echo "----------------------------"
test_endpoint "Get All Loans" "GET" "/loans" ""

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  TEST SUMMARY${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Passed:${NC} $passed"
echo -e "${RED}Failed:${NC} $failed"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL INTEGRATION TESTS PASSED!${NC}"
    echo ""
    echo "System is working correctly!"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo ""
    echo "Check the logs for more details:"
    echo "  docker-compose logs -f"
    exit 1
fi
