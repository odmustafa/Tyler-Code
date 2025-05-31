@echo off
title SecuGen Fingerprint Service Setup

echo ========================================
echo SecuGen HU20-A Fingerprint Service Setup
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python is not installed or not in PATH
    echo Please install Python 3.8 or higher from https://python.org
    pause
    exit /b 1
)

echo ✅ Python is installed

REM Check if pip is available
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ pip is not available
    echo Please ensure pip is installed with Python
    pause
    exit /b 1
)

echo ✅ pip is available

REM Install required Python packages
echo.
echo 📦 Installing required Python packages...
pip install flask flask-cors

if %errorlevel% neq 0 (
    echo ❌ Failed to install Python packages
    pause
    exit /b 1
)

echo ✅ Python packages installed successfully

REM Check if SecuGen SDK DLL exists
echo.
echo 🔍 Checking for SecuGen SDK...

set SDK_FOUND=0

if exist "sgfplib.dll" (
    echo ✅ Found sgfplib.dll in current directory
    set SDK_FOUND=1
) else if exist "bin\x64\sgfplib.dll" (
    echo ✅ Found sgfplib.dll in bin\x64\ directory
    copy "bin\x64\sgfplib.dll" "sgfplib.dll" >nul
    set SDK_FOUND=1
) else if exist "bin\i386\sgfplib.dll" (
    echo ✅ Found sgfplib.dll in bin\i386\ directory
    copy "bin\i386\sgfplib.dll" "sgfplib.dll" >nul
    set SDK_FOUND=1
) else (
    echo ⚠️  SecuGen SDK DLL not found in expected locations
    echo.
    echo Please ensure you have:
    echo 1. Installed the SecuGen FDx SDK Pro for Windows
    echo 2. Copied sgfplib.dll to this directory
    echo 3. Or run this script from the SDK directory
    echo.
    echo The service will still run but will use simulation mode only.
    set SDK_FOUND=0
)

REM Check if fingerprint device is connected
echo.
echo 🔌 Checking for SecuGen HU20-A device...

REM This is a basic check - the actual device detection happens in the Python service
echo Note: Device detection will be performed when the service starts

echo.
echo 🚀 Setup complete!
echo.
echo To start the fingerprint service:
echo 1. Connect your SecuGen HU20-A Hamster Pro 20 to USB
echo 2. Run: python windows_fingerprint_service.py
echo 3. The service will be available at http://localhost:5001
echo 4. Other computers can access it at http://YOUR_IP:5001
echo.
echo To find your IP address, run: ipconfig
echo.

pause
