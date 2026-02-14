#!/bin/bash

# Banking System Playground
# Add/Remove test data for experimentation

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

API_URL="http://localhost:8089"

clear

echo -e "${BLUE}=========================================="
echo "  BANKING SYSTEM - PLAYGROUND"
echo -e "==========================================${NC}"
echo ""
echo "🎮 Experiment with test data!"
echo ""

# Check if services are running
if ! curl -s "$API_URL/actuator/health" > /dev/null 2>&1; then
    echo -e "${RED}[ERROR] Services are not running!${NC}"
    echo "Start services first: ./start-mac-linux.sh"
    exit 1
fi

echo -e "${GREEN}[OK] Services are running${NC}"
echo ""

# Menu
echo "1. 🎲 Generate Random Test Data"
echo "2. 👤 Add Sample Customers"
echo "3. 🏦 Add Sample Accounts"
echo "4. 💳 Add Sample Cards"
echo "5. 💰 Add Sample Loans"
echo "6. 💸 Generate Sample Transactions"
echo "7. 🗑️  Clear All Test Data"
echo "8. 📊 View Current Data"
echo "9. 🎪 Run Full Demo Scenario"
echo ""
read -p "Enter your choice (1-9): " choice

generate_random_customers() {
    echo ""
    echo -e "${YELLOW}Generating random customers...${NC}"
    
    FIRST_NAMES=("John" "Jane" "Mike" "Sarah" "David" "Emily" "Chris" "Anna" "Tom" "Lisa")
    LAST_NAMES=("Smith" "Johnson" "Brown" "Davis" "Wilson" "Moore" "Taylor" "Anderson" "Thomas" "Jackson")
    
    COUNT=${1:-5}
    
    for i in $(seq 1 $COUNT); do
        FIRST=${FIRST_NAMES[$RANDOM % ${#FIRST_NAMES[@]}]}
        LAST=${LAST_NAMES[$RANDOM % ${#LAST_NAMES[@]}]}
        EMAIL="${FIRST,,}.${LAST,,}@example.com"
        PHONE="555-$(printf "%04d" $((RANDOM % 10000)))"
        
        RESPONSE=$(curl -s -X POST "$API_URL/customers" \
            -H "Content-Type: application/json" \
            -d "{
                \"firstName\": \"$FIRST\",
                \"lastName\": \"$LAST\",
                \"email\": \"$EMAIL\",
                \"phone\": \"$PHONE\"
            }")
        
        if echo "$RESPONSE" | grep -q "id"; then
            echo -e "${GREEN}✓ Created: $FIRST $LAST ($EMAIL)${NC}"
        else
            echo -e "${YELLOW}○ Skipped: $FIRST $LAST${NC}"
        fi
        
        sleep 0.2
    done
    
    echo ""
    echo -e "${GREEN}Generated $COUNT customers!${NC}"
}

add_sample_customers() {
    echo ""
    echo -e "${YELLOW}Adding sample customers...${NC}"
    
    # Customer 1
    curl -s -X POST "$API_URL/customers" \
        -H "Content-Type: application/json" \
        -d '{
            "firstName": "Alice",
            "lastName": "Wonder",
            "email": "alice@example.com",
            "phone": "555-0001",
            "address": "123 Main St, Wonderland"
        }' > /dev/null
    echo -e "${GREEN}✓ Added: Alice Wonder${NC}"
    
    # Customer 2
    curl -s -X POST "$API_URL/customers" \
        -H "Content-Type: application/json" \
        -d '{
            "firstName": "Bob",
            "lastName": "Builder",
            "email": "bob@example.com",
            "phone": "555-0002",
            "address": "456 Oak Ave, Buildville"
        }' > /dev/null
    echo -e "${GREEN}✓ Added: Bob Builder${NC}"
    
    # Customer 3
    curl -s -X POST "$API_URL/customers" \
        -H "Content-Type: application/json" \
        -d '{
            "firstName": "Charlie",
            "lastName": "Chocolate",
            "email": "charlie@example.com",
            "phone": "555-0003",
            "address": "789 Candy Lane, Sweetville"
        }' > /dev/null
    echo -e "${GREEN}✓ Added: Charlie Chocolate${NC}"
    
    echo ""
    echo -e "${GREEN}Added 3 sample customers!${NC}"
}

add_sample_accounts() {
    echo ""
    echo -e "${YELLOW}Adding sample accounts...${NC}"
    
    TYPES=("SAVINGS" "CHECKING" "FIXED_DEPOSIT")
    
    for i in {1..5}; do
        TYPE=${TYPES[$RANDOM % ${#TYPES[@]}]}
        BALANCE=$((RANDOM % 50000 + 1000))
        
        curl -s -X POST "$API_URL/accounts" \
            -H "Content-Type: application/json" \
            -d "{
                \"customerId\": \"$i\",
                \"accountType\": \"$TYPE\",
                \"balance\": $BALANCE
            }" > /dev/null
        
        echo -e "${GREEN}✓ Created: $TYPE account with \$$BALANCE${NC}"
        sleep 0.2
    done
    
    echo ""
    echo -e "${GREEN}Added 5 sample accounts!${NC}"
}

add_sample_cards() {
    echo ""
    echo -e "${YELLOW}Adding sample cards...${NC}"
    
    for i in {1..3}; do
        TYPE=$( [ $((RANDOM % 2)) -eq 0 ] && echo "DEBIT" || echo "CREDIT" )
        
        curl -s -X POST "$API_URL/cards" \
            -H "Content-Type: application/json" \
            -d "{
                \"customerId\": \"$i\",
                \"accountId\": \"$i\",
                \"cardType\": \"$TYPE\"
            }" > /dev/null
        
        echo -e "${GREEN}✓ Issued: $TYPE card for customer $i${NC}"
        sleep 0.2
    done
    
    echo ""
    echo -e "${GREEN}Added 3 sample cards!${NC}"
}

add_sample_loans() {
    echo ""
    echo -e "${YELLOW}Adding sample loans...${NC}"
    
    TYPES=("PERSONAL" "HOME" "AUTO" "EDUCATION")
    
    for i in {1..4}; do
        TYPE=${TYPES[$((i-1))]}
        AMOUNT=$((RANDOM % 100000 + 10000))
        TENURE=$((RANDOM % 240 + 12))
        
        curl -s -X POST "$API_URL/loans" \
            -H "Content-Type: application/json" \
            -d "{
                \"customerId\": \"$i\",
                \"loanType\": \"$TYPE\",
                \"amount\": $AMOUNT,
                \"tenure\": $TENURE,
                \"interestRate\": 7.5
            }" > /dev/null
        
        echo -e "${GREEN}✓ Created: $TYPE loan for \$$AMOUNT${NC}"
        sleep 0.2
    done
    
    echo ""
    echo -e "${GREEN}Added 4 sample loans!${NC}"
}

generate_transactions() {
    echo ""
    echo -e "${YELLOW}Generating sample transactions...${NC}"
    
    TYPES=("DEPOSIT" "WITHDRAWAL")
    
    for i in {1..10}; do
        TYPE=${TYPES[$RANDOM % ${#TYPES[@]}]}
        AMOUNT=$((RANDOM % 5000 + 100))
        ACCOUNT=$((RANDOM % 5 + 1))
        
        if [ "$TYPE" == "DEPOSIT" ]; then
            ENDPOINT="/transactions/deposit"
        else
            ENDPOINT="/transactions/withdrawal"
        fi
        
        curl -s -X POST "$API_URL$ENDPOINT" \
            -H "Content-Type: application/json" \
            -d "{
                \"accountId\": \"$ACCOUNT\",
                \"amount\": $AMOUNT,
                \"description\": \"Test $TYPE\"
            }" > /dev/null
        
        echo -e "${GREEN}✓ $TYPE: \$$AMOUNT (Account $ACCOUNT)${NC}"
        sleep 0.3
    done
    
    echo ""
    echo -e "${GREEN}Generated 10 transactions!${NC}"
}

clear_all_data() {
    echo ""
    echo -e "${RED}WARNING: This will delete ALL test data!${NC}"
    echo ""
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        return
    fi
    
    echo ""
    echo -e "${YELLOW}Clearing all data...${NC}"
    
    # Note: In production, implement actual delete endpoints
    # For now, restart database to clear
    docker-compose restart database
    
    echo ""
    echo -e "${GREEN}Database cleared! Restart services to reinitialize.${NC}"
}

view_current_data() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  CURRENT DATA SUMMARY"
    echo -e "==========================================${NC}"
    echo ""
    
    echo -e "${YELLOW}Customers:${NC}"
    CUSTOMERS=$(curl -s "$API_URL/customers" | grep -o '"id"' | wc -l)
    echo "  Total: $CUSTOMERS"
    echo ""
    
    echo -e "${YELLOW}Accounts:${NC}"
    ACCOUNTS=$(curl -s "$API_URL/accounts" | grep -o '"id"' | wc -l)
    echo "  Total: $ACCOUNTS"
    echo ""
    
    echo -e "${YELLOW}Transactions:${NC}"
    TRANS=$(curl -s "$API_URL/transactions" | grep -o '"id"' | wc -l)
    echo "  Total: $TRANS"
    echo ""
    
    echo -e "${YELLOW}Cards:${NC}"
    CARDS=$(curl -s "$API_URL/cards" | grep -o '"id"' | wc -l)
    echo "  Total: $CARDS"
    echo ""
    
    echo -e "${YELLOW}Loans:${NC}"
    LOANS=$(curl -s "$API_URL/loans" | grep -o '"id"' | wc -l)
    echo "  Total: $LOANS"
}

run_full_demo() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  RUNNING FULL DEMO SCENARIO"
    echo -e "==========================================${NC}"
    echo ""
    echo "This will create a complete demo dataset..."
    echo ""
    sleep 2
    
    echo "Step 1: Adding customers..."
    generate_random_customers 10
    sleep 1
    
    echo ""
    echo "Step 2: Creating accounts..."
    add_sample_accounts
    sleep 1
    
    echo ""
    echo "Step 3: Issuing cards..."
    add_sample_cards
    sleep 1
    
    echo ""
    echo "Step 4: Processing loans..."
    add_sample_loans
    sleep 1
    
    echo ""
    echo "Step 5: Generating transactions..."
    generate_transactions
    sleep 1
    
    echo ""
    echo -e "${GREEN}=========================================="
    echo "  DEMO SCENARIO COMPLETE!"
    echo -e "==========================================${NC}"
    echo ""
    echo "Your system now has:"
    echo "  ✓ 10 Customers"
    echo "  ✓ 5 Accounts"
    echo "  ✓ 3 Cards"
    echo "  ✓ 4 Loans"
    echo "  ✓ 10 Transactions"
    echo ""
    echo "Visit the portals to see the data:"
    echo "  - http://localhost:3000 (Customer Portal)"
    echo "  - http://localhost:3001 (Branch Dashboard)"
    echo "  - http://localhost:3002 (Central Bank)"
}

# Execute based on choice
case $choice in
    1) 
        read -p "How many customers to generate? (default 5): " num
        generate_random_customers ${num:-5}
        ;;
    2) add_sample_customers ;;
    3) add_sample_accounts ;;
    4) add_sample_cards ;;
    5) add_sample_loans ;;
    6) generate_transactions ;;
    7) clear_all_data ;;
    8) view_current_data ;;
    9) run_full_demo ;;
    *) echo -e "${RED}Invalid choice!${NC}"; exit 1 ;;
esac

echo ""
