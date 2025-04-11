@echo off
rem see: https://github.com/darianmiller/control-windows-updates
setlocal EnableExtensions EnableDelayedExpansion

:: ==== Validate argument ====
if "%~1"=="" (
    echo Usage: %~nx0 [enable^|disable]
    pause
    exit /b 1
)

set ACTION=%~1
set SCRIPT=

if /I "%ACTION%"=="enable" (
    set SCRIPT=enable-windowsupdate.ps1
) else if /I "%ACTION%"=="disable" (
    set SCRIPT=disable-windowsupdate.ps1
) else (
    echo Invalid option: %ACTION%
    echo Usage: %~nx0 [enable^|disable]
    pause
    exit /b 1
)

:: ==== Check for Administrator ====
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -ArgumentList '%ACTION%' -Verb RunAs"
    exit /b
)

:: ==== Execute PowerShell script ====
echo Running %SCRIPT% as administrator...
powershell -ExecutionPolicy Bypass -File "%~dp0%SCRIPT%"

