#!/bin/bash

# Frontend Developer - Quick Setup Script
# This script sets up ONLY the backend so you can work on frontends locally

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  FRONTEND DEVELOPER SETUP${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "This will:"
echo "  ✓ Start backend services in Docker"
echo "  ✓ Leave frontends for you to run locally"
echo "  ✓ Set up hot-reload development"
echo ""

# Check Docker
if ! docker ps &> /dev/null; then
    echo -e "${YELLOW}Starting Docker...${NC}"
    open -a Docker 2>/dev/null || echo "Please start Docker Desktop manually"
    sleep 5
fi

echo -e "${YELLOW}Step 1: Starting Backend Infrastructure${NC}"
docker-compose up -d database zookeeper kafka
sleep 15

echo -e "${YELLOW}Step 2: Starting All Microservices${NC}"
docker-compose up -d \
  account-service \
  customer-service \
  card-service \
  ledger-service \
  loan-service \
  notification-service \
  reporting-service \
  transaction-service
sleep 25

echo -e "${YELLOW}Step 3: Starting API Gateway${NC}"
docker-compose up -d bank-api-gateway
sleep 10

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  BACKEND READY!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}API Gateway:${NC} http://localhost:8089"
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  NOW RUN YOUR FRONTEND:${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Function to setup and run a frontend
setup_frontend() {
    local frontend=$1
    local port=$2
    
    echo -e "${BLUE}To run ${frontend}:${NC}"
    echo "  cd frontends/${frontend}"
    echo "  npm install"
    echo "  npm run dev"
    echo "  → Opens on http://localhost:${port}"
    echo ""
}

setup_frontend "customer-portal" "3000"
setup_frontend "branch-dashboard" "3001"
setup_frontend "central-bank-portal" "3002"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  HELPFUL COMMANDS:${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "View backend logs:       docker-compose logs -f"
echo "Stop backend:            docker-compose down"
echo "Restart a service:       docker-compose restart account-service"
echo "View service status:     docker-compose ps"
echo ""

# Ask which frontend to setup
echo -e "${BLUE}Which frontend do you want to work on?${NC}"
echo "  1) Customer Portal (3000)"
echo "  2) Branch Dashboard (3001)"
echo "  3) Central Bank Portal (3002)"
echo "  4) I'll do it myself"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        cd frontends/customer-portal
        echo "Installing dependencies..."
        npm install
        echo ""
        echo -e "${GREEN}Starting Customer Portal...${NC}"
        npm run dev
        ;;
    2)
        cd frontends/branch-dashboard
        echo "Installing dependencies..."
        npm install
        echo ""
        echo -e "${GREEN}Starting Branch Dashboard...${NC}"
        npm run dev
        ;;
    3)
        cd frontends/central-bank-portal
        echo "Installing dependencies..."
        npm install
        echo ""
        echo -e "${GREEN}Starting Central Bank Portal...${NC}"
        npm run dev
        ;;
    *)
        echo ""
        echo "Cool! Backend is running. Start your frontend manually."
        echo ""
        ;;
esac
