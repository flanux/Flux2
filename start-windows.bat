@echo off
title Banking System - Startup
color 0A

echo ==========================================
echo   COMPLETE BANKING SYSTEM - WINDOWS
echo ==========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running!
    echo.
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

echo [OK] Docker is running
echo.

REM Check if ports are available
echo Checking if ports are available...
netstat -ano | findstr ":3000 :3001 :3002 :5432 :8089" >nul
if not errorlevel 1 (
    echo [WARNING] Some ports might be in use!
    echo If startup fails, check these ports: 3000, 3001, 3002, 5432, 8089
    echo.
    pause
)

echo.
echo ==========================================
echo   STARTING ALL SERVICES
echo ==========================================
echo.
echo This will take 3-5 minutes on first run...
echo.

REM Start infrastructure
echo [1/4] Starting Database and Kafka...
docker-compose up -d database zookeeper kafka
if errorlevel 1 (
    echo [ERROR] Failed to start infrastructure
    pause
    exit /b 1
)

echo Waiting for infrastructure to be ready...
timeout /t 20 /nobreak >nul

REM Start microservices
echo.
echo [2/4] Starting Microservices...
docker-compose up -d account-service customer-service card-service ledger-service loan-service notification-service reporting-service transaction-service
if errorlevel 1 (
    echo [ERROR] Failed to start microservices
    pause
    exit /b 1
)

echo Waiting for microservices to start...
timeout /t 15 /nobreak >nul

REM Start API Gateway
echo.
echo [3/4] Starting API Gateway...
docker-compose up -d bank-api-gateway
if errorlevel 1 (
    echo [ERROR] Failed to start API Gateway
    pause
    exit /b 1
)

echo Waiting for API Gateway...
timeout /t 10 /nobreak >nul

REM Start Frontends
echo.
echo [4/4] Starting Frontend Applications...
docker-compose up -d customer-portal branch-dashboard central-bank-portal
if errorlevel 1 (
    echo [ERROR] Failed to start frontends
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   SUCCESS! ALL SERVICES STARTED
echo ==========================================
echo.
echo Your banking system is now running!
echo.
echo Access your applications:
echo.
echo   Customer Portal:       http://localhost:3000
echo   Branch Dashboard:      http://localhost:3001
echo   Central Bank Portal:   http://localhost:3002
echo.
echo Login: Use any username/password
echo.
echo ==========================================
echo.
echo Press any key to view service status...
pause >nul

docker-compose ps

echo.
echo ==========================================
echo   USEFUL COMMANDS
echo ==========================================
echo.
echo View logs:        docker-compose logs -f
echo Stop all:         docker-compose down
echo Restart service:  docker-compose restart [service-name]
echo.
echo Press any key to exit...
pause >nul
