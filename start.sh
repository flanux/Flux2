#!/bin/bash

echo "=========================================="
echo "  COMPLETE BANKING SYSTEM - STARTUP"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting infrastructure services...${NC}"
docker-compose up -d database zookeeper kafka

echo ""
echo -e "${YELLOW}Waiting for database and Kafka to be ready...${NC}"
sleep 15

echo ""
echo -e "${YELLOW}Starting microservices...${NC}"
docker-compose up -d \
  account-service \
  customer-service \
  card-service \
  ledger-service \
  loan-service \
  notification-service \
  reporting-service \
  transaction-service

echo ""
echo -e "${YELLOW}Waiting for microservices to start...${NC}"
sleep 10

echo ""
echo -e "${YELLOW}Starting API Gateway...${NC}"
docker-compose up -d bank-api-gateway

echo ""
echo -e "${YELLOW}Waiting for API Gateway...${NC}"
sleep 5

echo ""
echo -e "${YELLOW}Starting Frontend Applications...${NC}"
docker-compose up -d \
  customer-portal \
  branch-dashboard \
  central-bank-portal

echo ""
echo -e "${GREEN}=========================================="
echo -e "  ALL SERVICES STARTED!"
echo -e "==========================================${NC}"
echo ""
echo "🌐 Access your applications:"
echo ""
echo -e "  ${GREEN}Customer Portal:${NC}        http://localhost:3000"
echo -e "  ${GREEN}Branch Dashboard:${NC}       http://localhost:3001"
echo -e "  ${GREEN}Central Bank Portal:${NC}    http://localhost:3002"
echo -e "  ${GREEN}API Gateway:${NC}            http://localhost:8089"
echo ""
echo "📊 Check status:"
echo "  docker-compose ps"
echo ""
echo "📝 View logs:"
echo "  docker-compose logs -f [service-name]"
echo ""
echo "🛑 Stop all services:"
echo "  docker-compose down"
echo ""
echo -e "${YELLOW}Note: Services may take 1-2 minutes to fully start.${NC}"
echo ""
