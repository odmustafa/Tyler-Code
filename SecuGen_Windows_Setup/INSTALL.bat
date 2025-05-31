@echo off
title SecuGen Fingerprint Service - One-Click Installer

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ========================================
    echo   SecuGen Fingerprint Service Setup
    echo ========================================
    echo.
    echo This installer will automatically set up everything needed
    echo for the SecuGen HU20-A Hamster Pro 20 fingerprint scanner.
    echo.
    echo Administrator privileges are required for:
    echo - Installing Python (if needed)
    echo - Configuring Windows Firewall
    echo - Setting up device drivers
    echo.
    echo Please right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   SecuGen Fingerprint Service Setup
echo ========================================
echo.
echo Checking system capabilities...

:: Check if PowerShell is available and execution policy allows scripts
powershell -Command "Get-ExecutionPolicy" >nul 2>&1
if %errorlevel% equ 0 (
    echo Using PowerShell installer for enhanced features...
    echo.
    powershell -ExecutionPolicy Bypass -File "auto_setup_windows.ps1"
) else (
    echo Using batch installer for compatibility...
    echo.
    call "auto_setup_windows.bat"
)

echo.
echo Installation complete!
pause
