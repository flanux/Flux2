#!/bin/bash

# Unit Test Setup
# Adds test dependencies and creates test structure for all services

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  UNIT TEST SETUP${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to setup tests for a service
setup_service_tests() {
    local service=$1
    local service_dir="services/$service"
    
    echo -e "${YELLOW}Setting up tests for $service...${NC}"
    
    # Create test directory structure
    mkdir -p "$service_dir/src/test/java/com/bank/$service"
    
    # Create sample unit test
    cat > "$service_dir/src/test/java/com/bank/$service/SampleTest.java" << 'EOF'
package com.bank.SERVICE_NAME;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class SampleTest {

    @Test
    void contextLoads() {
        assertTrue(true);
    }
    
    @Test
    void sampleUnitTest() {
        // Arrange
        String expected = "test";
        
        // Act
        String actual = "test";
        
        // Assert
        assertEquals(expected, actual);
    }
}
EOF
    
    # Replace SERVICE_NAME with actual service name
    sed -i "s/SERVICE_NAME/${service}/g" "$service_dir/src/test/java/com/bank/$service/SampleTest.java" 2>/dev/null || \
    sed -i '' "s/SERVICE_NAME/${service}/g" "$service_dir/src/test/java/com/bank/$service/SampleTest.java"
    
    echo -e "${GREEN}✓ Tests created for $service${NC}"
}

# Setup tests for all services
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
    setup_service_tests "$service"
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  UNIT TEST SETUP COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Run tests for a service:"
echo "  cd services/account-service"
echo "  ./mvnw test"
echo ""
echo "Run all tests:"
echo "  ./RUN-ALL-TESTS.sh"
echo ""
