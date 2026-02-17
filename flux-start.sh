#!/bin/bash
# FLUX - Universal Banking System Startup
# Works on any Linux/Mac with Docker (no Desktop needed)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}"
cat << "EOF"
    ███████╗██╗     ██╗   ██╗██╗  ██╗
    ██╔════╝██║     ██║   ██║╚██╗██╔╝
    █████╗  ██║     ██║   ██║ ╚███╔╝ 
    ██╔══╝  ██║     ██║   ██║ ██╔██╗ 
    ██║     ███████╗╚██████╔╝██╔╝ ██╗
    ╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
    
    Distributed Banking Infrastructure
EOF
echo -e "${NC}"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found${NC}"
    echo ""
    echo "Install Docker Engine:"
    echo "  curl -fsSL https://get.docker.com | sh"
    exit 1
fi

echo -e "${GREEN}✓ Docker installed${NC}"

# Check Docker Compose
if ! docker compose version &> /dev/null 2>&1; then
    echo -e "${RED}✗ Docker Compose not found${NC}"
    echo ""
    echo "Install Docker Compose:"
    echo "  sudo apt install docker-compose-plugin"
    exit 1
fi

echo -e "${GREEN}✓ Docker Compose ready${NC}"
echo ""

# Start infrastructure
echo -e "${YELLOW}► Starting infrastructure...${NC}"
docker compose up -d database zookeeper kafka
sleep 15

# Start services
echo -e "${YELLOW}► Starting microservices...${NC}"
docker compose up -d \
  account-service customer-service card-service \
  ledger-service loan-service notification-service \
  reporting-service transaction-service
sleep 10

# Start gateway
echo -e "${YELLOW}► Starting API Gateway...${NC}"
docker compose up -d bank-api-gateway
sleep 5

# Start frontends
echo -e "${YELLOW}► Starting portals...${NC}"
docker compose up -d customer-portal branch-dashboard central-bank-portal

echo ""
echo -e "${GREEN}✓ FLUX is running${NC}"
echo ""
echo "Access points:"
echo "  • Customer:     http://localhost:3000"
echo "  • Branch:       http://localhost:3001"
echo "  • Central Bank: http://localhost:3002"
echo ""
echo "Commands:"
echo "  • Status:  docker compose ps"
echo "  • Logs:    docker compose logs -f"
echo "  • Stop:    docker compose down"
echo ""
