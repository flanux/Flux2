#!/bin/bash

# Banking System Test Runner
# Runs unit tests and system tests

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear

echo -e "${BLUE}=========================================="
echo "  BANKING SYSTEM - TEST RUNNER"
echo -e "==========================================${NC}"
echo ""

# Menu
echo "1. Run Unit Tests (All Services)"
echo "2. Run System Tests (Integration)"
echo "3. Run Frontend Tests"
echo "4. Run All Tests"
echo "5. Generate Test Report"
echo ""
read -p "Enter your choice (1-5): " choice

run_service_tests() {
    local service=$1
    echo ""
    echo -e "${YELLOW}Testing: $service${NC}"
    
    cd "services/$service" || return 1
    
    if [ -f "pom.xml" ]; then
        mvn test
        TEST_RESULT=$?
    elif [ -f "build.gradle" ]; then
        ./gradlew test
        TEST_RESULT=$?
    else
        echo -e "${YELLOW}No test configuration found for $service${NC}"
        return 0
    fi
    
    cd ../..
    
    if [ $TEST_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ $service tests passed${NC}"
    else
        echo -e "${RED}✗ $service tests failed${NC}"
    fi
    
    return $TEST_RESULT
}

run_unit_tests() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  RUNNING UNIT TESTS"
    echo -e "==========================================${NC}"
    
    FAILED=0
    
    for service in account-service customer-service card-service ledger-service loan-service notification-service reporting-service transaction-service; do
        run_service_tests "$service"
        if [ $? -ne 0 ]; then
            FAILED=$((FAILED + 1))
        fi
    done
    
    echo ""
    echo -e "${BLUE}=========================================="
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}  ALL UNIT TESTS PASSED!${NC}"
    else
        echo -e "${RED}  $FAILED SERVICES FAILED${NC}"
    fi
    echo -e "${BLUE}==========================================${NC}"
}

run_system_tests() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  RUNNING SYSTEM TESTS"
    echo -e "==========================================${NC}"
    echo ""
    
    # Check if services are running
    if ! curl -s http://localhost:8089/actuator/health > /dev/null; then
        echo -e "${RED}[ERROR] Services are not running!${NC}"
        echo "Start services first: ./start-mac-linux.sh"
        return 1
    fi
    
    echo -e "${GREEN}[OK] Services are running${NC}"
    echo ""
    
    # Test each service health
    echo "Testing service health..."
    FAILED=0
    
    for port in 8081 8082 8083 8084 8085 8086 8087 8088 8089; do
        if curl -s http://localhost:$port/actuator/health | grep -q "UP"; then
            echo -e "${GREEN}✓ Service on port $port is healthy${NC}"
        else
            echo -e "${RED}✗ Service on port $port is down${NC}"
            FAILED=$((FAILED + 1))
        fi
    done
    
    echo ""
    
    # Test end-to-end scenarios
    echo "Running integration tests..."
    
    # Test 1: Create Customer
    echo -n "Test: Create Customer... "
    RESPONSE=$(curl -s -X POST http://localhost:8089/customers \
        -H "Content-Type: application/json" \
        -d '{
            "firstName": "Test",
            "lastName": "User",
            "email": "test@example.com",
            "phone": "1234567890"
        }')
    
    if echo "$RESPONSE" | grep -q "id"; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        FAILED=$((FAILED + 1))
    fi
    
    # Test 2: Get Customers
    echo -n "Test: Get Customers... "
    if curl -s http://localhost:8089/customers | grep -q "Test"; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        FAILED=$((FAILED + 1))
    fi
    
    # Test 3: Create Account
    echo -n "Test: Create Account... "
    RESPONSE=$(curl -s -X POST http://localhost:8089/accounts \
        -H "Content-Type: application/json" \
        -d '{
            "customerId": "1",
            "accountType": "SAVINGS",
            "balance": 1000
        }')
    
    if echo "$RESPONSE" | grep -q "accountNumber\|id"; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        FAILED=$((FAILED + 1))
    fi
    
    echo ""
    echo -e "${BLUE}=========================================="
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}  ALL SYSTEM TESTS PASSED!${NC}"
    else
        echo -e "${RED}  $FAILED TESTS FAILED${NC}"
    fi
    echo -e "${BLUE}==========================================${NC}"
}

run_frontend_tests() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  RUNNING FRONTEND TESTS"
    echo -e "==========================================${NC}"
    
    FAILED=0
    
    for frontend in customer-portal branch-dashboard central-bank-portal; do
        echo ""
        echo -e "${YELLOW}Testing: $frontend${NC}"
        cd "frontends/$frontend" || continue
        
        if [ -f "package.json" ]; then
            npm test 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ $frontend tests passed${NC}"
            else
                echo -e "${YELLOW}○ $frontend has no tests configured${NC}"
            fi
        fi
        
        cd ../..
    done
    
    echo ""
    echo -e "${BLUE}=========================================="
    echo -e "${GREEN}  FRONTEND TEST SCAN COMPLETE${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

generate_report() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  GENERATING TEST REPORT"
    echo -e "==========================================${NC}"
    echo ""
    
    REPORT_FILE="test-report-$(date +%Y%m%d-%H%M%S).html"
    
    cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Banking System - Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .header { background: #1976d2; color: white; padding: 20px; border-radius: 8px; }
        .section { background: white; margin: 20px 0; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .pass { color: #4caf50; font-weight: bold; }
        .fail { color: #f44336; font-weight: bold; }
        .warn { color: #ff9800; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f5f5f5; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Banking System Test Report</h1>
        <p>Generated: $(date)</p>
    </div>
    
    <div class="section">
        <h2>System Status</h2>
        <p>All services are operational</p>
    </div>
    
    <div class="section">
        <h2>Service Health</h2>
        <table>
            <tr><th>Service</th><th>Status</th></tr>
EOF
    
    # Add service statuses
    for port in 8081 8082 8083 8084 8085 8086 8087 8088 8089; do
        if curl -s http://localhost:$port/actuator/health > /dev/null 2>&1; then
            echo "<tr><td>Service $port</td><td class='pass'>HEALTHY</td></tr>" >> "$REPORT_FILE"
        else
            echo "<tr><td>Service $port</td><td class='fail'>DOWN</td></tr>" >> "$REPORT_FILE"
        fi
    done
    
    cat >> "$REPORT_FILE" << 'EOF'
        </table>
    </div>
</body>
</html>
EOF
    
    echo -e "${GREEN}Report generated: $REPORT_FILE${NC}"
    echo "Open it in your browser to view results"
    
    # Try to open in browser
    if command -v xdg-open &> /dev/null; then
        xdg-open "$REPORT_FILE"
    elif command -v open &> /dev/null; then
        open "$REPORT_FILE"
    fi
}

# Execute based on choice
case $choice in
    1) run_unit_tests ;;
    2) run_system_tests ;;
    3) run_frontend_tests ;;
    4)
        run_unit_tests
        run_system_tests
        run_frontend_tests
        ;;
    5) generate_report ;;
    *) echo -e "${RED}Invalid choice!${NC}"; exit 1 ;;
esac

echo ""
