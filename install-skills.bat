@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

title OpenDesign Skills Installer for OpenCode

echo.
echo ========================================
echo   OpenDesign Skills Installer
echo   for OpenCode
echo ========================================
echo.

:: 设置目标目录 - OpenCode 用户级 skills 目录
set "TARGET_DIR=%USERPROFILE%\.local\share\opencode\skills"

:: 检查目标目录是否存在，不存在则创建
if not exist "%TARGET_DIR%" (
    echo [INFO] Creating directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "PLUGINS_DIR=%SCRIPT_DIR%plugins"

echo Available plugins:
echo.
echo [1] product-design      - Product design review
echo [2] system-design       - System design review
echo [3] code-design         - Code performance analysis
echo [A] Install ALL
echo [Q] Quit
echo.

set /p choice="Select plugin to install (1/2/3/A/Q): "

if /i "%choice%"=="Q" (
    echo Cancelled.
    goto :end
)

if /i "%choice%"=="A" (
    call :install_skill "product-design" "product-design-review"
    call :install_skill "system-design" "system-design-review"
    call :install_skill "code-design" "code-execution-efficiency"
    goto :end
)

if "%choice%"=="1" (
    call :install_skill "product-design" "product-design-review"
    goto :end
)

if "%choice%"=="2" (
    call :install_skill "system-design" "system-design-review"
    goto :end
)

if "%choice%"=="3" (
    call :install_skill "code-design" "code-execution-efficiency"
    goto :end
)

echo Invalid choice.
goto :end

:install_skill
:: Param 1: plugin directory name
:: Param 2: skill directory name
set "PLUGIN_NAME=%~1"
set "SKILL_NAME=%~2"
set "SOURCE_PATH=%PLUGINS_DIR%\%PLUGIN_NAME%\skills\%SKILL_NAME%"
set "LINK_PATH=%TARGET_DIR%\%SKILL_NAME%"

:: Check if source exists
if not exist "%SOURCE_PATH%" (
    echo [ERROR] Source not found: %SOURCE_PATH%
    goto :eof
)

:: Check if target already exists
if exist "%LINK_PATH%" (
    echo [SKIP] Already exists: %SKILL_NAME%
    echo        To reinstall, delete first: %LINK_PATH%
    goto :eof
)

:: Create symbolic link
echo [INSTALL] %SKILL_NAME%
echo          Source: %SOURCE_PATH%
echo          Target: %LINK_PATH%

:: Use /D for directory symlink (requires admin or developer mode)
mklink /D "%LINK_PATH%" "%SOURCE_PATH%" >nul 2>&1

if !errorlevel! equ 0 (
    echo          [OK] Symlink created successfully
) else (
    echo          [FAIL] Symlink failed, trying junction...

    :: Try junction (doesn't require admin)
    mklink /J "%LINK_PATH%" "%SOURCE_PATH%" >nul 2>&1

    if !errorlevel! equ 0 (
        echo          [OK] Junction created successfully
    ) else (
        echo          [FAIL] Please run as Administrator
        echo          Or enable Developer Mode in Windows Settings
    )
)

echo.
goto :eof

:end
echo.
echo ========================================
echo   Installation Complete
echo   OpenCode skills directory: %TARGET_DIR%
echo ========================================
echo.
pause
