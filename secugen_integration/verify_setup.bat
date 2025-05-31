@echo off
title SecuGen Setup Verification

echo ========================================
echo   SecuGen Setup Verification
echo ========================================
echo.

:: Check Python
echo Checking Python installation...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo ✅ %%i
) else (
    echo ❌ Python not found
    goto :error
)

:: Check Python packages
echo.
echo Checking Python packages...
python -c "import flask; print('✅ Flask installed')" 2>nul || echo ❌ Flask not installed
python -c "import flask_cors; print('✅ Flask-CORS installed')" 2>nul || echo ❌ Flask-CORS not installed
python -c "import requests; print('✅ Requests installed')" 2>nul || echo ❌ Requests not installed

:: Check SecuGen SDK
echo.
echo Checking SecuGen SDK...
if exist "sgfplib.dll" (
    echo ✅ SecuGen SDK DLL found
) else (
    echo ⚠️  SecuGen SDK DLL not found (simulation mode only)
)

:: Check service files
echo.
echo Checking service files...
if exist "windows_fingerprint_service.py" (
    echo ✅ Fingerprint service found
) else (
    echo ❌ Fingerprint service not found
    goto :error
)

if exist "start_fingerprint_service.bat" (
    echo ✅ Startup script found
) else (
    echo ⚠️  Startup script not found
)

:: Check desktop shortcut
echo.
echo Checking desktop shortcut...
if exist "%USERPROFILE%\Desktop\SecuGen Fingerprint Service.lnk" (
    echo ✅ Desktop shortcut found
) else (
    echo ⚠️  Desktop shortcut not found
)

:: Check firewall rule
echo.
echo Checking firewall rule...
netsh advfirewall firewall show rule name="SecuGen Fingerprint Service" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Firewall rule configured
) else (
    echo ⚠️  Firewall rule not found
)

:: Check device
echo.
echo Checking for SecuGen device...
powershell -Command "Get-PnpDevice | Where-Object {$_.FriendlyName -like '*SecuGen*' -or $_.FriendlyName -like '*Hamster*' -or $_.FriendlyName -like '*HU20*'} | Select-Object -First 1" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ SecuGen device detected
) else (
    echo ⚠️  SecuGen device not detected
)

:: Get IP address
echo.
echo Network information:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%a
    set IP=!IP: =!
    if not "!IP!"=="" (
        echo ✅ IP Address: !IP!
        echo 🌐 Service URL: http://!IP!:5001
        goto :ip_found
    )
)
:ip_found

echo.
echo ========================================
echo   Verification Complete
echo ========================================
echo.
echo To start the service:
echo 1. Double-click "SecuGen Fingerprint Service" on desktop
echo 2. Or run: start_fingerprint_service.bat
echo 3. Or run: python windows_fingerprint_service.py
echo.
echo To test the service:
echo python test_integration.py
echo.
goto :end

:error
echo.
echo ❌ Setup verification failed!
echo Please run the installer again:
echo - Right-click INSTALL.bat and "Run as administrator"
echo.

:end
pause
