@echo off

:: Build and test script for n8n-nodes-mediafx (Windows)

echo 🚀 Building n8n-nodes-mediafx for Docker testing...

:: Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running. Please start Docker first.
    exit /b 1
)

:: Build the project first
echo 📦 Building the npm package...
call npm run build

if %errorlevel% neq 0 (
    echo ❌ npm build failed. Please fix the build errors first.
    exit /b 1
)

echo ✅ Build successful!

:: Ask user which version to run
echo.
echo Which version would you like to test?
echo 1) Development build (faster, includes dev dependencies)
echo 2) Production build (slower, production-ready)
echo 3) Both (development on port 5678, production on port 5679)
echo.

set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo 🐳 Starting development build...
    docker-compose up --build n8n-dev
) else if "%choice%"=="2" (
    echo 🐳 Starting production build...
    docker-compose --profile prod up --build n8n-prod
) else if "%choice%"=="3" (
    echo 🐳 Starting both builds...
    docker-compose --profile prod up --build
) else (
    echo ❌ Invalid choice. Exiting.
    exit /b 1
)

echo.
echo 🎉 n8n is starting up!
echo 📱 Access n8n at:
if "%choice%"=="1" (
    echo    Development: http://localhost:5678
) else if "%choice%"=="3" (
    echo    Development: http://localhost:5678
)
if "%choice%"=="2" (
    echo    Production:  http://localhost:5679
) else if "%choice%"=="3" (
    echo    Production:  http://localhost:5679
)
echo.
echo 🔐 Default credentials:
echo    Username: admin
echo    Password: password
echo.
echo 📁 Test media files: Place files in ./test-media/ directory
echo    They'll be available at /home/node/test-media/ in n8n
