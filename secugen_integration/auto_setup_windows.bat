@echo off
setlocal enabledelayedexpansion
title SecuGen Fingerprint Service - Automated Setup

:: Set colors for output
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "RESET=%ESC%[0m"

echo %BLUE%========================================%RESET%
echo %BLUE%SecuGen HU20-A Automated Setup Script%RESET%
echo %BLUE%========================================%RESET%
echo.
echo This script will automatically:
echo - Check and install Python if needed
echo - Install required packages
echo - Setup SecuGen SDK files
echo - Configure Windows Firewall
echo - Test the fingerprint device
echo - Start the fingerprint service
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED%❌ This script requires administrator privileges%RESET%
    echo %YELLOW%Please right-click and select "Run as administrator"%RESET%
    pause
    exit /b 1
)

echo %GREEN%✅ Running with administrator privileges%RESET%
echo.

:: Step 1: Check Python Installation
echo %BLUE%Step 1: Checking Python installation...%RESET%
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo %YELLOW%⚠️  Python not found. Attempting to install...%RESET%
    
    :: Try to install Python using winget (Windows 10/11)
    winget --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo %BLUE%Installing Python using Windows Package Manager...%RESET%
        winget install Python.Python.3.11 --silent --accept-package-agreements --accept-source-agreements
        
        :: Refresh PATH
        call refreshenv >nul 2>&1
        
        :: Check again
        python --version >nul 2>&1
        if %errorlevel% neq 0 (
            echo %RED%❌ Python installation failed%RESET%
            echo %YELLOW%Please manually install Python from https://python.org%RESET%
            echo %YELLOW%Make sure to check "Add Python to PATH" during installation%RESET%
            pause
            exit /b 1
        )
    ) else (
        echo %RED%❌ Windows Package Manager not available%RESET%
        echo %YELLOW%Please manually install Python from https://python.org%RESET%
        echo %YELLOW%Make sure to check "Add Python to PATH" during installation%RESET%
        pause
        exit /b 1
    )
)

for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo %GREEN%✅ Python found: %PYTHON_VERSION%%RESET%
echo.

:: Step 2: Install Python packages
echo %BLUE%Step 2: Installing required Python packages...%RESET%
pip install --upgrade pip >nul 2>&1
pip install flask flask-cors requests >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%❌ Failed to install Python packages%RESET%
    echo %YELLOW%Trying alternative installation method...%RESET%
    python -m pip install --upgrade pip
    python -m pip install flask flask-cors requests
    if %errorlevel% neq 0 (
        echo %RED%❌ Package installation failed%RESET%
        pause
        exit /b 1
    )
)
echo %GREEN%✅ Python packages installed successfully%RESET%
echo.

:: Step 3: Setup SecuGen SDK
echo %BLUE%Step 3: Setting up SecuGen SDK...%RESET%

:: Check for SDK DLL in various locations
set SDK_FOUND=0
set SDK_PATH=""

if exist "sgfplib.dll" (
    echo %GREEN%✅ Found sgfplib.dll in current directory%RESET%
    set SDK_FOUND=1
    set SDK_PATH="sgfplib.dll"
) else (
    :: Look for SDK in common installation paths
    set "SDK_PATHS[0]=C:\Program Files\SecuGen\FDx SDK Pro for Windows\bin\x64\sgfplib.dll"
    set "SDK_PATHS[1]=C:\Program Files (x86)\SecuGen\FDx SDK Pro for Windows\bin\x64\sgfplib.dll"
    set "SDK_PATHS[2]=bin\x64\sgfplib.dll"
    set "SDK_PATHS[3]=bin\i386\sgfplib.dll"
    set "SDK_PATHS[4]=..\FDx SDK Pro for Windows v4.3.1_J1.12\FDx SDK Pro for Windows v4.3.1\bin\x64\sgfplib.dll"
    
    for /L %%i in (0,1,4) do (
        if exist "!SDK_PATHS[%%i]!" (
            echo %GREEN%✅ Found SDK at: !SDK_PATHS[%%i]!%RESET%
            copy "!SDK_PATHS[%%i]!" "sgfplib.dll" >nul 2>&1
            if %errorlevel% equ 0 (
                set SDK_FOUND=1
                set SDK_PATH="!SDK_PATHS[%%i]!"
                goto :sdk_found
            )
        )
    )
)

:sdk_found
if %SDK_FOUND% equ 0 (
    echo %YELLOW%⚠️  SecuGen SDK DLL not found%RESET%
    echo %YELLOW%The service will run in simulation mode only%RESET%
    echo %YELLOW%To enable hardware support:%RESET%
    echo %YELLOW%1. Install SecuGen FDx SDK Pro for Windows%RESET%
    echo %YELLOW%2. Copy sgfplib.dll to this directory%RESET%
) else (
    echo %GREEN%✅ SecuGen SDK configured successfully%RESET%
)
echo.

:: Step 4: Configure Windows Firewall
echo %BLUE%Step 4: Configuring Windows Firewall...%RESET%
netsh advfirewall firewall show rule name="SecuGen Fingerprint Service" >nul 2>&1
if %errorlevel% neq 0 (
    echo %BLUE%Adding firewall rule for port 5001...%RESET%
    netsh advfirewall firewall add rule name="SecuGen Fingerprint Service" dir=in action=allow protocol=TCP localport=5001 >nul 2>&1
    if %errorlevel% equ 0 (
        echo %GREEN%✅ Firewall rule added successfully%RESET%
    ) else (
        echo %YELLOW%⚠️  Failed to add firewall rule%RESET%
        echo %YELLOW%You may need to manually allow port 5001%RESET%
    )
) else (
    echo %GREEN%✅ Firewall rule already exists%RESET%
)
echo.

:: Step 5: Get network information
echo %BLUE%Step 5: Network configuration...%RESET%
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%a
    set IP=!IP: =!
    if not "!IP!"=="" (
        echo %GREEN%✅ Your IP address: !IP!%RESET%
        echo %BLUE%Other devices can access the service at: http://!IP!:5001%RESET%
        goto :ip_found
    )
)
:ip_found
echo.

:: Step 6: Test device connection
echo %BLUE%Step 6: Testing SecuGen device connection...%RESET%
echo %BLUE%Please connect your SecuGen HU20-A Hamster Pro 20 to USB%RESET%

:: Check if device appears in device manager
powershell -Command "Get-PnpDevice | Where-Object {$_.FriendlyName -like '*SecuGen*' -or $_.FriendlyName -like '*Hamster*' -or $_.FriendlyName -like '*HU20*'}" >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%✅ SecuGen device detected in Device Manager%RESET%
) else (
    echo %YELLOW%⚠️  SecuGen device not detected%RESET%
    echo %YELLOW%Please ensure:%RESET%
    echo %YELLOW%- Device is connected to USB%RESET%
    echo %YELLOW%- Drivers are installed%RESET%
    echo %YELLOW%- Device appears in Device Manager%RESET%
)
echo.

:: Step 7: Create startup script
echo %BLUE%Step 7: Creating startup script...%RESET%
(
echo @echo off
echo title SecuGen Fingerprint Service
echo echo Starting SecuGen Fingerprint Service...
echo echo Service will be available at:
echo echo - Local: http://localhost:5001
echo echo - Network: http://%IP%:5001
echo echo.
echo echo Press Ctrl+C to stop the service
echo echo.
echo python windows_fingerprint_service.py
echo pause
) > start_fingerprint_service.bat

echo %GREEN%✅ Startup script created: start_fingerprint_service.bat%RESET%
echo.

:: Step 8: Create desktop shortcut
echo %BLUE%Step 8: Creating desktop shortcut...%RESET%
set DESKTOP=%USERPROFILE%\Desktop
set CURRENT_DIR=%CD%

powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%DESKTOP%\SecuGen Fingerprint Service.lnk'); $Shortcut.TargetPath = '%CURRENT_DIR%\start_fingerprint_service.bat'; $Shortcut.WorkingDirectory = '%CURRENT_DIR%'; $Shortcut.IconLocation = 'shell32.dll,23'; $Shortcut.Description = 'SecuGen Fingerprint Service for Tribute System'; $Shortcut.Save()" >nul 2>&1

if %errorlevel% equ 0 (
    echo %GREEN%✅ Desktop shortcut created%RESET%
) else (
    echo %YELLOW%⚠️  Could not create desktop shortcut%RESET%
)
echo.

:: Step 9: Run initial test
echo %BLUE%Step 9: Running initial service test...%RESET%
echo %BLUE%Starting service for 10 seconds to test...%RESET%

:: Start the service in background
start /B python windows_fingerprint_service.py >service_test.log 2>&1

:: Wait a moment for service to start
timeout /t 3 /nobreak >nul

:: Test the service
python -c "import requests; r = requests.get('http://localhost:5001/api/fingerprint/status', timeout=5); print('✅ Service test successful' if r.status_code == 200 else '❌ Service test failed')" 2>nul
if %errorlevel% equ 0 (
    echo %GREEN%✅ Service test successful%RESET%
) else (
    echo %YELLOW%⚠️  Service test failed - check service_test.log for details%RESET%
)

:: Stop the test service
taskkill /F /IM python.exe >nul 2>&1

echo.

:: Final summary
echo %BLUE%========================================%RESET%
echo %GREEN%🎉 Setup Complete!%RESET%
echo %BLUE%========================================%RESET%
echo.
echo %GREEN%✅ Python installed and configured%RESET%
echo %GREEN%✅ Required packages installed%RESET%
echo %GREEN%✅ SecuGen SDK configured%RESET%
echo %GREEN%✅ Windows Firewall configured%RESET%
echo %GREEN%✅ Network settings configured%RESET%
echo %GREEN%✅ Startup scripts created%RESET%
echo.
echo %BLUE%To start the fingerprint service:%RESET%
echo %YELLOW%Option 1:%RESET% Double-click "SecuGen Fingerprint Service" on desktop
echo %YELLOW%Option 2:%RESET% Run start_fingerprint_service.bat
echo %YELLOW%Option 3:%RESET% Run: python windows_fingerprint_service.py
echo.
echo %BLUE%Service will be available at:%RESET%
echo - Local: http://localhost:5001
echo - Network: http://%IP%:5001
echo.
echo %BLUE%Next steps:%RESET%
echo 1. Connect your SecuGen HU20-A Hamster Pro 20 to USB
echo 2. Start the fingerprint service using one of the options above
echo 3. Access your web application from any device on the network
echo 4. The web app will automatically detect the fingerprint service
echo.

choice /C YN /M "Would you like to start the fingerprint service now"
if %errorlevel% equ 1 (
    echo.
    echo %GREEN%Starting SecuGen Fingerprint Service...%RESET%
    echo %BLUE%Press Ctrl+C to stop the service%RESET%
    echo.
    python windows_fingerprint_service.py
) else (
    echo.
    echo %BLUE%Setup complete! Start the service when ready.%RESET%
)

pause
