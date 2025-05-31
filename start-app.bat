@echo off
title Tribute Biometric Authentication System

echo 🚀 Starting Tribute Biometric Authentication System...
echo ==================================================

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js 19.9.0 or higher.
    pause
    exit /b 1
)

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python is not installed. Please install Python 3.8 or higher.
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed

echo.
echo 📦 Installing frontend dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install frontend dependencies
    pause
    exit /b 1
)
echo ✅ Frontend dependencies installed

echo.
echo 📦 Installing backend dependencies...
cd Tribute_Biometric_Integration_Complete_All_Files\Backend
call pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ❌ Failed to install backend dependencies
    pause
    exit /b 1
)
echo ✅ Backend dependencies installed

cd ..\..

echo.
echo 🎉 Setup complete!
echo.
echo Backend will start on: http://localhost:5000
echo Frontend will start on: http://localhost:3000
echo.
echo Press Ctrl+C to stop the servers
echo.

REM Start backend server
echo 🔧 Starting Flask backend server...
cd Tribute_Biometric_Integration_Complete_All_Files\Backend
start "Backend Server" cmd /k "python app.py"
cd ..\..

REM Wait a moment for backend to start
timeout /t 3 /nobreak >nul

REM Start frontend server
echo ⚛️ Starting React frontend server...
start "Frontend Server" cmd /k "npm start"

echo.
echo ✅ Both servers are starting...
echo Check the opened terminal windows for server status
echo.
pause
