#!/bin/bash
# FLUX Playground - Generate demo data & test scenarios

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

API="http://localhost:8089"

clear
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}      FLUX PLAYGROUND${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Check if running
if ! curl -s "$API/actuator/health" > /dev/null 2>&1; then
    echo -e "${RED}✗ FLUX is not running${NC}"
    echo "Start it first: ./flux-start.sh"
    exit 1
fi

echo -e "${GREEN}✓ Connected to FLUX${NC}"
echo ""

echo "Choose action:"
echo ""
echo "  1. 🎪 Full Demo (everything)"
echo "  2. 👥 Add 10 customers"
echo "  3. 🏦 Add 5 accounts"
echo "  4. 💸 Generate 20 transactions"
echo "  5. 📊 View current data"
echo "  6. 🗑️  Reset all data"
echo ""
read -p "→ " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Creating full demo scenario...${NC}"
        
        # Customers
        for i in {1..10}; do
            curl -s -X POST "$API/customers" \
                -H "Content-Type: application/json" \
                -d "{\"firstName\":\"User$i\",\"lastName\":\"Test\",\"email\":\"user$i@flux.io\",\"phone\":\"555000$i\"}" > /dev/null
            echo -e "${GREEN}✓${NC} Customer $i"
        done
        
        # Accounts
        for i in {1..5}; do
            curl -s -X POST "$API/accounts" \
                -H "Content-Type: application/json" \
                -d "{\"customerId\":\"$i\",\"type\":\"SAVINGS\",\"balance\":$((RANDOM % 50000 + 1000))}" > /dev/null
            echo -e "${GREEN}✓${NC} Account $i"
        done
        
        # Transactions
        for i in {1..20}; do
            curl -s -X POST "$API/transactions/deposit" \
                -H "Content-Type: application/json" \
                -d "{\"accountId\":\"$((RANDOM % 5 + 1))\",\"amount\":$((RANDOM % 5000 + 100))}" > /dev/null
            echo -e "${GREEN}✓${NC} Transaction $i"
        done
        
        echo ""
        echo -e "${GREEN}✓ Demo complete!${NC}"
        echo "Visit the portals to see data"
        ;;
        
    5)
        echo ""
        CUSTOMERS=$(curl -s "$API/customers" 2>/dev/null | grep -o '"id"' | wc -l)
        ACCOUNTS=$(curl -s "$API/accounts" 2>/dev/null | grep -o '"id"' | wc -l)
        TRANS=$(curl -s "$API/transactions" 2>/dev/null | grep -o '"id"' | wc -l)
        
        echo "Current data:"
        echo "  Customers:    $CUSTOMERS"
        echo "  Accounts:     $ACCOUNTS"
        echo "  Transactions: $TRANS"
        ;;
        
    6)
        echo ""
        echo -e "${RED}This will reset the database!${NC}"
        read -p "Continue? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            docker compose restart database
            echo -e "${GREEN}✓ Reset complete${NC}"
        fi
        ;;
        
    *)
        echo -e "${RED}Invalid option${NC}"
        ;;
esac

echo ""
