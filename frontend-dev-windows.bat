@echo off
title Frontend Developer Setup
color 0B

echo ==========================================
echo   FRONTEND DEVELOPER SETUP - WINDOWS
echo ==========================================
echo.

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed!
    echo.
    echo Download from: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo [OK] Node.js is installed
node --version
echo.

REM Check npm
npm --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm is not available!
    pause
    exit /b 1
)

echo [OK] npm is available
npm --version
echo.

echo ==========================================
echo   SELECT FRONTEND TO DEVELOP
echo ==========================================
echo.
echo 1. Customer Portal (Port 3000)
echo 2. Branch Dashboard (Port 3001)
echo 3. Central Bank Portal (Port 3002)
echo 4. All Frontends (Open 3 terminals)
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    set FRONTEND=customer-portal
    set PORT=3000
) else if "%choice%"=="2" (
    set FRONTEND=branch-dashboard
    set PORT=3001
) else if "%choice%"=="3" (
    set FRONTEND=central-bank-portal
    set PORT=3002
) else if "%choice%"=="4" (
    goto ALL_FRONTENDS
) else (
    echo Invalid choice!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   SETTING UP %FRONTEND%
echo ==========================================
echo.

REM Navigate to frontend
cd frontends\%FRONTEND%
if errorlevel 1 (
    echo [ERROR] Frontend directory not found!
    pause
    exit /b 1
)

REM Check if node_modules exists
if not exist "node_modules\" (
    echo Installing dependencies...
    echo This might take a few minutes...
    echo.
    call npm install
    if errorlevel 1 (
        echo [ERROR] npm install failed!
        pause
        exit /b 1
    )
) else (
    echo Dependencies already installed.
    echo Run 'npm install' manually if you need to update.
)

echo.
echo ==========================================
echo   STARTING DEVELOPMENT SERVER
echo ==========================================
echo.
echo Frontend: %FRONTEND%
echo Port: %PORT%
echo.
echo Backend services should be running!
echo If not, run: start-windows.bat
echo.
echo Press Ctrl+C to stop the dev server
echo.
echo Opening in browser in 5 seconds...
timeout /t 5 /nobreak >nul
start http://localhost:%PORT%

echo.
call npm run dev

goto END

:ALL_FRONTENDS
echo.
echo ==========================================
echo   STARTING ALL FRONTENDS
echo ==========================================
echo.
echo This will open 3 terminal windows...
echo.
echo Make sure backend services are running!
echo If not, run: start-windows.bat
echo.
pause

REM Customer Portal
start "Customer Portal - Port 3000" cmd /k "cd frontends\customer-portal && if not exist node_modules (npm install) && npm run dev"

REM Branch Dashboard
start "Branch Dashboard - Port 3001" cmd /k "cd frontends\branch-dashboard && if not exist node_modules (npm install) && npm run dev"

REM Central Bank Portal
start "Central Bank Portal - Port 3002" cmd /k "cd frontends\central-bank-portal && if not exist node_modules (npm install) && npm run dev"

echo.
echo All frontends starting in separate windows...
echo.
echo Access at:
echo   - http://localhost:3000 (Customer)
echo   - http://localhost:3001 (Branch)
echo   - http://localhost:3002 (Central Bank)
echo.
pause

:END
