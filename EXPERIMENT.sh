#!/bin/bash

# Experimentation Tool
# Add or remove test data, restart services, play around

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

API_URL="http://localhost:8089"

show_menu() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  BANKING SYSTEM - EXPERIMENT MODE${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "What do you want to do?"
    echo ""
    echo "  ${YELLOW}DATA MANAGEMENT:${NC}"
    echo "    1) Add test customer"
    echo "    2) Add test account"
    echo "    3) Create test transaction"
    echo "    4) Generate random data (10 customers)"
    echo "    5) Clear ALL data (fresh start)"
    echo ""
    echo "  ${YELLOW}SERVICE MANAGEMENT:${NC}"
    echo "    6) Restart a service"
    echo "    7) View service logs"
    echo "    8) Stop a service"
    echo "    9) Start a service"
    echo ""
    echo "  ${YELLOW}TESTING:${NC}"
    echo "    10) Run integration tests"
    echo "    11) Test API endpoint"
    echo "    12) Health check all services"
    echo ""
    echo "    0) Exit"
    echo ""
    read -p "Enter choice: " choice
}

add_customer() {
    echo ""
    read -p "First Name: " first
    read -p "Last Name: " last
    read -p "Email: " email
    
    echo -e "${YELLOW}Creating customer...${NC}"
    
    response=$(curl -s -X POST "$API_URL/customers" \
      -H "Content-Type: application/json" \
      -d "{
        \"firstName\": \"$first\",
        \"lastName\": \"$last\",
        \"email\": \"$email\",
        \"phone\": \"555-$(shuf -i 1000-9999 -n 1)\"
      }")
    
    echo -e "${GREEN}✓ Customer created!${NC}"
    echo "$response" | jq '.'
    echo ""
    read -p "Press enter to continue..."
}

add_account() {
    echo ""
    read -p "Customer ID: " customer_id
    echo "Account Type:"
    echo "  1) SAVINGS"
    echo "  2) CHECKING"
    echo "  3) FIXED_DEPOSIT"
    read -p "Choice (1-3): " type_choice
    
    case $type_choice in
        1) type="SAVINGS";;
        2) type="CHECKING";;
        3) type="FIXED_DEPOSIT";;
        *) type="SAVINGS";;
    esac
    
    read -p "Initial Balance: " balance
    
    echo -e "${YELLOW}Creating account...${NC}"
    
    response=$(curl -s -X POST "$API_URL/accounts" \
      -H "Content-Type: application/json" \
      -d "{
        \"customerId\": \"$customer_id\",
        \"accountType\": \"$type\",
        \"initialBalance\": $balance
      }")
    
    echo -e "${GREEN}✓ Account created!${NC}"
    echo "$response" | jq '.'
    echo ""
    read -p "Press enter to continue..."
}

create_transaction() {
    echo ""
    read -p "Account Number: " account
    echo "Transaction Type:"
    echo "  1) DEPOSIT"
    echo "  2) WITHDRAWAL"
    echo "  3) TRANSFER"
    read -p "Choice (1-3): " trans_choice
    
    case $trans_choice in
        1) type="deposit";;
        2) type="withdrawal";;
        3) type="transfer";;
        *) type="deposit";;
    esac
    
    read -p "Amount: " amount
    
    echo -e "${YELLOW}Creating transaction...${NC}"
    
    curl -s -X POST "$API_URL/transactions/$type" \
      -H "Content-Type: application/json" \
      -d "{
        \"accountNumber\": \"$account\",
        \"amount\": $amount,
        \"description\": \"Test transaction\"
      }" | jq '.'
    
    echo -e "${GREEN}✓ Transaction created!${NC}"
    echo ""
    read -p "Press enter to continue..."
}

generate_random_data() {
    echo ""
    echo -e "${YELLOW}Generating 10 random customers with accounts...${NC}"
    
    for i in {1..10}; do
        first="User$i"
        last="Test"
        email="user$i@test.com"
        
        customer_id=$(curl -s -X POST "$API_URL/customers" \
          -H "Content-Type: application/json" \
          -d "{
            \"firstName\": \"$first\",
            \"lastName\": \"$last\",
            \"email\": \"$email\",
            \"phone\": \"555-$(shuf -i 1000-9999 -n 1)\"
          }" | jq -r '.id')
        
        if [ ! -z "$customer_id" ]; then
            curl -s -X POST "$API_URL/accounts" \
              -H "Content-Type: application/json" \
              -d "{
                \"customerId\": \"$customer_id\",
                \"accountType\": \"SAVINGS\",
                \"initialBalance\": $(shuf -i 1000-10000 -n 1)
              }" > /dev/null
            
            echo "  ✓ Created customer $i with account"
        fi
    done
    
    echo -e "${GREEN}✓ Generated 10 customers!${NC}"
    echo ""
    read -p "Press enter to continue..."
}

clear_data() {
    echo ""
    echo -e "${RED}WARNING: This will delete ALL data!${NC}"
    read -p "Are you sure? (type 'yes'): " confirm
    
    if [ "$confirm" = "yes" ]; then
        echo -e "${YELLOW}Clearing database...${NC}"
        docker-compose down -v
        docker-compose up -d database
        sleep 10
        docker-compose up -d
        echo -e "${GREEN}✓ Data cleared! Starting fresh...${NC}"
    else
        echo "Cancelled."
    fi
    
    echo ""
    read -p "Press enter to continue..."
}

restart_service() {
    echo ""
    echo "Services:"
    echo "  1) account-service"
    echo "  2) customer-service"
    echo "  3) card-service"
    echo "  4) transaction-service"
    echo "  5) API Gateway"
    read -p "Which service? (1-5): " svc
    
    case $svc in
        1) service="account-service";;
        2) service="customer-service";;
        3) service="card-service";;
        4) service="transaction-service";;
        5) service="bank-api-gateway";;
        *) echo "Invalid choice"; return;;
    esac
    
    echo -e "${YELLOW}Restarting $service...${NC}"
    docker-compose restart $service
    echo -e "${GREEN}✓ Restarted!${NC}"
    echo ""
    read -p "Press enter to continue..."
}

view_logs() {
    echo ""
    read -p "Service name (e.g., account-service): " service
    echo -e "${YELLOW}Showing logs for $service (Ctrl+C to exit)...${NC}"
    echo ""
    docker-compose logs -f $service
}

health_check() {
    echo ""
    echo -e "${YELLOW}Checking all services...${NC}"
    echo ""
    
    services=("8081:Account" "8082:Customer" "8083:Card" "8084:Ledger" "8085:Notification" "8086:Reporting" "8087:Loan" "8088:Transaction" "8089:Gateway")
    
    for svc in "${services[@]}"; do
        IFS=':' read -r port name <<< "$svc"
        if curl -s "http://localhost:$port/actuator/health" | grep -q "UP"; then
            echo -e "${GREEN}✓${NC} $name Service"
        else
            echo -e "${RED}✗${NC} $name Service"
        fi
    done
    
    echo ""
    read -p "Press enter to continue..."
}

# Main loop
while true; do
    show_menu
    
    case $choice in
        1) add_customer;;
        2) add_account;;
        3) create_transaction;;
        4) generate_random_data;;
        5) clear_data;;
        6) restart_service;;
        7) view_logs;;
        8) read -p "Service name: " svc; docker-compose stop $svc;;
        9) read -p "Service name: " svc; docker-compose start $svc;;
        10) ./RUN-INTEGRATION-TESTS.sh; read -p "Press enter...";;
        11) read -p "Endpoint (e.g., /customers): " ep; curl "$API_URL$ep" | jq '.'; read -p "Press enter...";;
        12) health_check;;
        0) echo "Bye!"; exit 0;;
        *) echo "Invalid choice";;
    esac
done
