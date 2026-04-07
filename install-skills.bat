@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo   OpenDesign Skills Installer
echo   将 Skills 链接到用户级 Claude 配置目录
echo ========================================
echo.

:: 设置目标目录
set "TARGET_DIR=%USERPROFILE%\.claude\skills"

:: 检查目标目录是否存在，不存在则创建
if not exist "%TARGET_DIR%" (
    echo 创建目标目录: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "PLUGINS_DIR=%SCRIPT_DIR%plugins"

echo 可用的插件:
echo.
echo [1] product-design      - 产品设计审查
echo [2] system-design       - 系统设计审查
echo [3] code-design         - 代码性能分析
echo [A] 全部安装
echo [Q] 退出
echo.

set /p choice="请选择要安装的插件 (1/2/3/A/Q): "

if /i "%choice%"=="Q" (
    echo 已取消
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

echo 无效的选择
goto :end

:install_skill
:: 参数1: 插件目录名
:: 参数2: skill目录名
set "PLUGIN_NAME=%~1"
set "SKILL_NAME=%~2"
set "SOURCE_PATH=%PLUGINS_DIR%\%PLUGIN_NAME%\skills\%SKILL_NAME%"
set "LINK_PATH=%TARGET_DIR%\%SKILL_NAME%"

:: 检查源目录是否存在
if not exist "%SOURCE_PATH%" (
    echo [错误] 源目录不存在: %SOURCE_PATH%
    goto :eof
)

:: 检查目标是否已存在
if exist "%LINK_PATH%" (
    echo [跳过] 已存在: %SKILL_NAME%
    echo        如需重新安装，请先删除: %LINK_PATH%
    goto :eof
)

:: 创建符号链接
echo [安装] %SKILL_NAME%
echo        源: %SOURCE_PATH%
echo        目标: %LINK_PATH%

:: 使用 /D 创建目录符号链接
:: 需要管理员权限，或者开启开发者模式
mklink /D "%LINK_PATH%" "%SOURCE_PATH%" >nul 2>&1

if !errorlevel! equ 0 (
    echo        [成功] 符号链接创建成功
) else (
    echo        [失败] 符号链接创建失败
    echo        可能需要管理员权限，尝试使用 Junction...

    :: 尝试使用 junction (不需要管理员权限)
    mklink /J "%LINK_PATH%" "%SOURCE_PATH%" >nul 2>&1

    if !errorlevel! equ 0 (
        echo        [成功] Junction 创建成功
    ) else (
        echo        [失败] 请以管理员身份运行此脚本
        echo        或在 Windows 设置中开启"开发人员模式"
    )
)

echo.
goto :eof

:end
echo.
echo ========================================
echo   安装完成
echo   Skills 目录: %TARGET_DIR%
echo ========================================
echo.
pause
