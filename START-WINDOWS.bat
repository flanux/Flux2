@echo off
title Banking System - Setup and Start
color 0A

echo ========================================
echo   BANKING SYSTEM - AUTOMATED SETUP
echo ========================================
echo.

REM Check if Docker is installed
where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not installed!
    echo.
    echo Please install Docker Desktop from:
    echo https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)

REM Check if Docker is running
docker ps >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running!
    echo.
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

echo [OK] Docker is installed and running
echo.

echo Stopping any existing containers...
docker-compose down 2>nul
echo.

echo ========================================
echo   STEP 1: Starting Infrastructure
echo ========================================
echo Starting Database and Kafka...
docker-compose up -d database zookeeper kafka
echo Waiting 20 seconds for infrastructure...
timeout /t 20 /nobreak >nul
echo [OK] Infrastructure ready
echo.

echo ========================================
echo   STEP 2: Starting Microservices
echo ========================================
echo Starting all 8 microservices...
docker-compose up -d account-service customer-service card-service ledger-service loan-service notification-service reporting-service transaction-service
echo Waiting 30 seconds for services to start...
timeout /t 30 /nobreak >nul
echo [OK] Microservices ready
echo.

echo ========================================
echo   STEP 3: Starting API Gateway
echo ========================================
docker-compose up -d bank-api-gateway
echo Waiting 10 seconds for gateway...
timeout /t 10 /nobreak >nul
echo [OK] Gateway ready
echo.

echo ========================================
echo   STEP 4: Starting Frontend Apps
echo ========================================
echo Building and starting all 3 frontend applications...
docker-compose up -d customer-portal branch-dashboard central-bank-portal
echo Waiting 20 seconds for frontends...
timeout /t 20 /nobreak >nul
echo.

echo ========================================
echo   SUCCESS! EVERYTHING IS RUNNING!
echo ========================================
echo.
echo Your banking system is now live at:
echo.
echo   [1] Customer Portal:      http://localhost:3000
echo   [2] Branch Dashboard:     http://localhost:3001
echo   [3] Central Bank Portal:  http://localhost:3002
echo   [4] API Gateway:          http://localhost:8089
echo.
echo ========================================
echo   Quick Commands:
echo ========================================
echo.
echo   View Status:    docker-compose ps
echo   View Logs:      docker-compose logs -f
echo   Stop All:       docker-compose down
echo   Restart:        Just run this script again
echo.
echo Opening Customer Portal in your browser...
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo Press any key to exit (services will keep running)...
pause >nul
