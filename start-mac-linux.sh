#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear

echo -e "${BLUE}=========================================="
echo "  COMPLETE BANKING SYSTEM - STARTUP"
echo -e "==========================================${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}[ERROR] Docker is not running!${NC}"
    echo ""
    echo "Please start Docker and try again."
    echo ""
    echo "macOS: Start Docker Desktop"
    echo "Linux: sudo systemctl start docker"
    echo ""
    exit 1
fi

echo -e "${GREEN}[OK] Docker is running${NC}"
echo ""

# Check if ports are available
echo "Checking if ports are available..."
PORTS_IN_USE=0

for port in 3000 3001 3002 5432 8089; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}[WARNING] Port $port is in use${NC}"
        PORTS_IN_USE=1
    fi
done

if [ $PORTS_IN_USE -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}Some ports are in use. Continue anyway? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Startup cancelled."
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}=========================================="
echo "  STARTING ALL SERVICES"
echo -e "==========================================${NC}"
echo ""
echo "This will take 3-5 minutes on first run..."
echo ""

# Start infrastructure
echo -e "${YELLOW}[1/4] Starting Database and Kafka...${NC}"
docker-compose up -d database zookeeper kafka

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Failed to start infrastructure${NC}"
    exit 1
fi

echo "Waiting for infrastructure to be ready..."
sleep 20

# Start microservices
echo ""
echo -e "${YELLOW}[2/4] Starting Microservices...${NC}"
docker-compose up -d \
    account-service \
    customer-service \
    card-service \
    ledger-service \
    loan-service \
    notification-service \
    reporting-service \
    transaction-service

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Failed to start microservices${NC}"
    exit 1
fi

echo "Waiting for microservices to start..."
sleep 15

# Start API Gateway
echo ""
echo -e "${YELLOW}[3/4] Starting API Gateway...${NC}"
docker-compose up -d bank-api-gateway

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Failed to start API Gateway${NC}"
    exit 1
fi

echo "Waiting for API Gateway..."
sleep 10

# Start Frontends
echo ""
echo -e "${YELLOW}[4/4] Starting Frontend Applications...${NC}"
docker-compose up -d \
    customer-portal \
    branch-dashboard \
    central-bank-portal

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Failed to start frontends${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  SUCCESS! ALL SERVICES STARTED"
echo -e "==========================================${NC}"
echo ""
echo "Your banking system is now running!"
echo ""
echo -e "${BLUE}Access your applications:${NC}"
echo ""
echo -e "  ${GREEN}Customer Portal:${NC}       http://localhost:3000"
echo -e "  ${GREEN}Branch Dashboard:${NC}      http://localhost:3001"
echo -e "  ${GREEN}Central Bank Portal:${NC}   http://localhost:3002"
echo ""
echo -e "${BLUE}Login:${NC} Use any username/password"
echo ""
echo -e "${BLUE}=========================================="
echo "  SERVICE STATUS"
echo -e "==========================================${NC}"
echo ""

docker-compose ps

echo ""
echo -e "${BLUE}=========================================="
echo "  USEFUL COMMANDS"
echo -e "==========================================${NC}"
echo ""
echo -e "  ${YELLOW}View logs:${NC}        docker-compose logs -f"
echo -e "  ${YELLOW}Stop all:${NC}         docker-compose down"
echo -e "  ${YELLOW}Restart service:${NC}  docker-compose restart [service-name]"
echo -e "  ${YELLOW}Health check:${NC}     ./health-check.sh"
echo ""
