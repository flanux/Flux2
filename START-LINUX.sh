#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  BANKING SYSTEM - AUTOMATED SETUP${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker is not installed!${NC}"
    echo ""
    echo "Please install Docker using:"
    echo "  curl -fsSL https://get.docker.com | sh"
    echo ""
    echo "Or visit: https://docs.docker.com/engine/install/"
    echo ""
    echo "Press any key to exit..."
    read -n 1
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}[ERROR] Docker Compose is not installed!${NC}"
    echo ""
    echo "Please install Docker Compose:"
    echo "  sudo apt-get install docker-compose"
    echo ""
    echo "Press any key to exit..."
    read -n 1
    exit 1
fi

# Check if Docker is running
if ! docker ps &> /dev/null; then
    echo -e "${RED}[ERROR] Docker is not running!${NC}"
    echo ""
    echo "Please start Docker service:"
    echo "  sudo systemctl start docker"
    echo ""
    echo "Press any key to exit..."
    read -n 1
    exit 1
fi

echo -e "${GREEN}[OK] Docker is installed and running${NC}"
echo ""

echo "Stopping any existing containers..."
docker-compose down 2>/dev/null
echo ""

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  STEP 1: Starting Infrastructure${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "Starting Database and Kafka..."
docker-compose up -d database zookeeper kafka
echo "Waiting 20 seconds for infrastructure..."
sleep 20
echo -e "${GREEN}[OK] Infrastructure ready${NC}"
echo ""

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  STEP 2: Starting Microservices${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "Starting all 8 microservices..."
docker-compose up -d \
  account-service \
  customer-service \
  card-service \
  ledger-service \
  loan-service \
  notification-service \
  reporting-service \
  transaction-service
echo "Waiting 30 seconds for services to start..."
sleep 30
echo -e "${GREEN}[OK] Microservices ready${NC}"
echo ""

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  STEP 3: Starting API Gateway${NC}"
echo -e "${YELLOW}========================================${NC}"
docker-compose up -d bank-api-gateway
echo "Waiting 10 seconds for gateway..."
sleep 10
echo -e "${GREEN}[OK] Gateway ready${NC}"
echo ""

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  STEP 4: Starting Frontend Apps${NC}"
echo -e "${YELLOW}========================================${NC}"
echo "Building and starting all 3 frontend applications..."
docker-compose up -d customer-portal branch-dashboard central-bank-portal
echo "Waiting 20 seconds for frontends..."
sleep 20
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  SUCCESS! EVERYTHING IS RUNNING!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your banking system is now live at:"
echo ""
echo -e "  ${BLUE}[1] Customer Portal:${NC}      http://localhost:3000"
echo -e "  ${BLUE}[2] Branch Dashboard:${NC}     http://localhost:3001"
echo -e "  ${BLUE}[3] Central Bank Portal:${NC}  http://localhost:3002"
echo -e "  ${BLUE}[4] API Gateway:${NC}          http://localhost:8089"
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Quick Commands:${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "  View Status:    docker-compose ps"
echo "  View Logs:      docker-compose logs -f"
echo "  Stop All:       docker-compose down"
echo "  Restart:        Just run this script again"
echo ""

# Try to open browser (works on most Linux desktops)
if command -v xdg-open &> /dev/null; then
    echo "Opening Customer Portal in your browser..."
    sleep 2
    xdg-open http://localhost:3000 &
fi

echo ""
echo "Press any key to exit (services will keep running)..."
read -n 1
