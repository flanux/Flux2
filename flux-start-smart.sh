#!/bin/bash

# ==============================================================================
# FLUX Banking System - Smart Startup Script
# ==============================================================================
# This script automatically detects whether to:
#   1. Pull pre-built images from GHCR (fast - 30 seconds)
#   2. Build images locally (slower - 5-10 minutes)
#
# Usage:
#   ./flux-start-smart.sh              # Auto-detect
#   ./flux-start-smart.sh --prod       # Force use published images
#   ./flux-start-smart.sh --dev        # Force build locally
#   ./flux-start-smart.sh --version v1.0.0  # Use specific version
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MODE="auto"
VERSION="latest"
COMPOSE_FILE="docker-compose.yml"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --prod)
      MODE="prod"
      COMPOSE_FILE="docker-compose.prod.yml"
      shift
      ;;
    --dev)
      MODE="dev"
      COMPOSE_FILE="docker-compose.yml"
      shift
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║              🌊 FLUX BANKING SYSTEM v1.0                   ║${NC}"
echo -e "${BLUE}║                  Smart Startup Script                      ║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check if images are available on GHCR
check_published_images() {
    echo -e "${YELLOW}🔍 Checking for published images on GHCR...${NC}"
    
    # Load GITHUB_USER from .env
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
    
    if [ -z "$GITHUB_USER" ]; then
        echo -e "${RED}❌ GITHUB_USER not set in .env${NC}"
        return 1
    fi
    
    # Try to pull one image as a test
    local test_image="ghcr.io/$GITHUB_USER/flux-account-service:$VERSION"
    echo -e "${BLUE}   Testing: $test_image${NC}"
    
    if docker pull "$test_image" &> /dev/null; then
        echo -e "${GREEN}✅ Published images available!${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Published images not found${NC}"
        return 1
    fi
}

# Function to check Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed${NC}"
        echo -e "${YELLOW}   Install from: https://docker.com${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker daemon is not running${NC}"
        echo -e "${YELLOW}   Please start Docker first${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker is ready${NC}"
}

# Auto-detect mode
if [ "$MODE" == "auto" ]; then
    echo -e "${YELLOW}🤖 Auto-detecting best deployment mode...${NC}"
    echo ""
    
    if check_published_images; then
        echo -e "${GREEN}🚀 Using fast mode: Published images${NC}"
        MODE="prod"
        COMPOSE_FILE="docker-compose.prod.yml"
    else
        echo -e "${YELLOW}🔨 Using build mode: Building locally${NC}"
        MODE="dev"
        COMPOSE_FILE="docker-compose.yml"
    fi
    echo ""
fi

# Display mode
echo -e "${BLUE}📋 Configuration:${NC}"
echo -e "   Mode: $MODE"
echo -e "   Compose: $COMPOSE_FILE"
echo -e "   Version: $VERSION"
echo ""

# Check Docker
check_docker
echo ""

# Start deployment
if [ "$MODE" == "prod" ]; then
    echo -e "${GREEN}🚀 Starting FLUX with published images (fast)...${NC}"
    echo -e "${YELLOW}   This will take ~30 seconds${NC}"
else
    echo -e "${YELLOW}🔨 Building FLUX from source...${NC}"
    echo -e "${YELLOW}   This will take ~5-10 minutes first time${NC}"
fi
echo ""

# Export VERSION for docker-compose
export VERSION=$VERSION

# Start services
docker-compose -f "$COMPOSE_FILE" up -d

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ FLUX is starting up!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}⏱️  Services will be ready in 1-2 minutes${NC}"
echo ""
echo -e "${BLUE}🌐 Access Points:${NC}"
echo -e "   ${GREEN}Customer Portal:${NC}      http://localhost:3000"
echo -e "   ${GREEN}Branch Dashboard:${NC}     http://localhost:3001"
echo -e "   ${GREEN}Central Bank Portal:${NC}  http://localhost:3002"
echo -e "   ${GREEN}API Gateway:${NC}          http://localhost:8089"
echo ""
echo -e "${BLUE}📊 Check status:${NC}"
echo -e "   docker-compose -f $COMPOSE_FILE ps"
echo ""
echo -e "${BLUE}🔍 View logs:${NC}"
echo -e "   docker-compose -f $COMPOSE_FILE logs -f"
echo ""
echo -e "${BLUE}🛑 Stop services:${NC}"
echo -e "   docker-compose -f $COMPOSE_FILE down"
echo ""

# Wait for services
echo -e "${YELLOW}⏳ Waiting for services to be healthy...${NC}"

WAIT_TIME=0
MAX_WAIT=120  # 2 minutes

while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    # Check if database is healthy
    if docker-compose -f "$COMPOSE_FILE" ps | grep -q "database.*healthy"; then
        echo -e "${GREEN}✅ Database is healthy!${NC}"
        break
    fi
    
    echo -n "."
    sleep 2
    WAIT_TIME=$((WAIT_TIME + 2))
done

echo ""
echo ""

if [ $WAIT_TIME -ge $MAX_WAIT ]; then
    echo -e "${YELLOW}⚠️  Services are taking longer than expected${NC}"
    echo -e "${YELLOW}   Check logs: docker-compose -f $COMPOSE_FILE logs${NC}"
else
    echo -e "${GREEN}🎉 FLUX Banking System is ready!${NC}"
    echo ""
    echo -e "${BLUE}💡 Quick tips:${NC}"
    echo -e "   • Login credentials: any username/password (dev mode)"
    echo -e "   • Try the playground: ./flux-playground.sh"
    echo -e "   • Generate test data: ./flux-playground.sh"
    echo -e "   • Run health check: ./health-check.sh"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
