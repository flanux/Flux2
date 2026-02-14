#!/bin/bash

# Test Data Generator
# Creates sample customers, accounts, transactions for testing

API_URL="http://localhost:8089"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "  TEST DATA GENERATOR"
echo "========================================="
echo ""

# Function to create test customer
create_customer() {
    local first=$1
    local last=$2
    local email=$3
    
    echo -e "${YELLOW}Creating customer: $first $last${NC}"
    
    curl -X POST "$API_URL/customers" \
      -H "Content-Type: application/json" \
      -d "{
        \"firstName\": \"$first\",
        \"lastName\": \"$last\",
        \"email\": \"$email\",
        \"phone\": \"555-$(shuf -i 1000-9999 -n 1)\",
        \"address\": \"123 Main St\",
        \"dateOfBirth\": \"1990-01-01\",
        \"idNumber\": \"ID$(shuf -i 100000-999999 -n 1)\"
      }" \
      -s | jq -r '.id'
}

# Function to create account
create_account() {
    local customer_id=$1
    local type=$2
    local balance=$3
    
    echo -e "${YELLOW}Creating $type account with balance \$$balance${NC}"
    
    curl -X POST "$API_URL/accounts" \
      -H "Content-Type: application/json" \
      -d "{
        \"customerId\": \"$customer_id\",
        \"accountType\": \"$type\",
        \"initialBalance\": $balance
      }" \
      -s | jq -r '.id'
}

# Function to create transaction
create_transaction() {
    local account=$1
    local type=$2
    local amount=$3
    
    echo -e "${YELLOW}Creating $type transaction: \$$amount${NC}"
    
    curl -X POST "$API_URL/transactions/$type" \
      -H "Content-Type: application/json" \
      -d "{
        \"accountNumber\": \"$account\",
        \"amount\": $amount,
        \"description\": \"Test $type\"
      }" \
      -s > /dev/null
}

echo "Waiting for API Gateway to be ready..."
sleep 5

# Create test customers
echo ""
echo "Creating Test Customers..."
echo "------------------------"
customer1=$(create_customer "John" "Doe" "john.doe@test.com")
customer2=$(create_customer "Jane" "Smith" "jane.smith@test.com")
customer3=$(create_customer "Bob" "Johnson" "bob.j@test.com")
customer4=$(create_customer "Alice" "Williams" "alice.w@test.com")
customer5=$(create_customer "Charlie" "Brown" "charlie.b@test.com")

sleep 2

# Create test accounts
echo ""
echo "Creating Test Accounts..."
echo "------------------------"
if [ ! -z "$customer1" ]; then
    account1=$(create_account "$customer1" "SAVINGS" "5000")
    account2=$(create_account "$customer1" "CHECKING" "2500")
fi

if [ ! -z "$customer2" ]; then
    account3=$(create_account "$customer2" "SAVINGS" "10000")
fi

if [ ! -z "$customer3" ]; then
    account4=$(create_account "$customer3" "CHECKING" "3000")
    account5=$(create_account "$customer3" "SAVINGS" "15000")
fi

if [ ! -z "$customer4" ]; then
    account6=$(create_account "$customer4" "SAVINGS" "7500")
fi

if [ ! -z "$customer5" ]; then
    account7=$(create_account "$customer5" "CHECKING" "4500")
fi

sleep 2

# Create test transactions
echo ""
echo "Creating Test Transactions..."
echo "----------------------------"
if [ ! -z "$account1" ]; then
    create_transaction "$account1" "deposit" "1000"
    create_transaction "$account1" "withdrawal" "500"
fi

if [ ! -z "$account3" ]; then
    create_transaction "$account3" "deposit" "2000"
fi

if [ ! -z "$account4" ]; then
    create_transaction "$account4" "deposit" "500"
    create_transaction "$account4" "withdrawal" "200"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  TEST DATA CREATED!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Created:"
echo "  ✓ 5 Test Customers"
echo "  ✓ 7 Test Accounts"
echo "  ✓ 5 Test Transactions"
echo ""
echo "You can now:"
echo "  • View customers in Branch Dashboard"
echo "  • See accounts in Customer Portal"
echo "  • Check transactions in reports"
echo ""
