#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear

echo -e "${BLUE}=========================================="
echo "  FRONTEND DEVELOPER SETUP"
echo -e "==========================================${NC}"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR] Node.js is not installed!${NC}"
    echo ""
    echo "Install Node.js from: https://nodejs.org/"
    echo "Or use nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    echo ""
    exit 1
fi

echo -e "${GREEN}[OK] Node.js is installed${NC}"
node --version
echo ""

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}[ERROR] npm is not available!${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] npm is available${NC}"
npm --version
echo ""

# Function to setup and run frontend
setup_frontend() {
    local FRONTEND=$1
    local PORT=$2
    
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  SETTING UP $FRONTEND"
    echo -e "==========================================${NC}"
    echo ""
    
    cd "frontends/$FRONTEND" || exit 1
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        echo "This might take a few minutes..."
        echo ""
        npm install
        if [ $? -ne 0 ]; then
            echo -e "${RED}[ERROR] npm install failed!${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Dependencies already installed.${NC}"
        echo "Run 'npm install' manually if you need to update."
    fi
    
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  STARTING DEVELOPMENT SERVER"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "Frontend: ${GREEN}$FRONTEND${NC}"
    echo -e "Port: ${GREEN}$PORT${NC}"
    echo ""
    echo -e "${YELLOW}Backend services should be running!${NC}"
    echo "If not, run: ./start-mac-linux.sh"
    echo ""
    echo "Press Ctrl+C to stop the dev server"
    echo ""
    
    # Open browser (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Opening in browser in 3 seconds..."
        sleep 3
        open "http://localhost:$PORT" &
    fi
    
    # Start dev server
    npm run dev
}

# Menu
echo -e "${BLUE}=========================================="
echo "  SELECT FRONTEND TO DEVELOP"
echo -e "==========================================${NC}"
echo ""
echo "1. Customer Portal (Port 3000)"
echo "2. Branch Dashboard (Port 3001)"
echo "3. Central Bank Portal (Port 3002)"
echo "4. All Frontends (Separate terminals)"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        setup_frontend "customer-portal" "3000"
        ;;
    2)
        setup_frontend "branch-dashboard" "3001"
        ;;
    3)
        setup_frontend "central-bank-portal" "3002"
        ;;
    4)
        echo ""
        echo -e "${BLUE}=========================================="
        echo "  STARTING ALL FRONTENDS"
        echo -e "==========================================${NC}"
        echo ""
        echo "This will open multiple terminal windows..."
        echo ""
        echo -e "${YELLOW}Make sure backend services are running!${NC}"
        echo "If not, run: ./start-mac-linux.sh"
        echo ""
        read -p "Press Enter to continue..."
        
        # Start Customer Portal
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            osascript -e 'tell app "Terminal" to do script "cd \"'$(pwd)'/frontends/customer-portal\" && npm install 2>/dev/null; npm run dev"'
            osascript -e 'tell app "Terminal" to do script "cd \"'$(pwd)'/frontends/branch-dashboard\" && npm install 2>/dev/null; npm run dev"'
            osascript -e 'tell app "Terminal" to do script "cd \"'$(pwd)'/frontends/central-bank-portal\" && npm install 2>/dev/null; npm run dev"'
        else
            # Linux
            gnome-terminal -- bash -c "cd frontends/customer-portal && npm install 2>/dev/null; npm run dev; exec bash" &
            gnome-terminal -- bash -c "cd frontends/branch-dashboard && npm install 2>/dev/null; npm run dev; exec bash" &
            gnome-terminal -- bash -c "cd frontends/central-bank-portal && npm install 2>/dev/null; npm run dev; exec bash" &
        fi
        
        echo ""
        echo -e "${GREEN}All frontends starting in separate windows...${NC}"
        echo ""
        echo "Access at:"
        echo "  - http://localhost:3000 (Customer)"
        echo "  - http://localhost:3001 (Branch)"
        echo "  - http://localhost:3002 (Central Bank)"
        echo ""
        ;;
    *)
        echo -e "${RED}Invalid choice!${NC}"
        exit 1
        ;;
esac
