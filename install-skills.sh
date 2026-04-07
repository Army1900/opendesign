#!/bin/bash

echo "========================================"
echo "  OpenDesign Skills Installer"
echo "  for OpenCode"
echo "========================================"
echo

# 设置目标目录 - OpenCode 用户级 skill 目录
TARGET_DIR="$HOME/.config/opencode/skill"

# 检查目标目录是否存在，不存在则创建
if [ ! -d "$TARGET_DIR" ]; then
    echo "[INFO] Creating directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGINS_DIR="$SCRIPT_DIR/plugins"

echo "Available plugins:"
echo
echo "[1] product-design      - Product design review"
echo "[2] system-design       - System design review"
echo "[3] code-design         - Code performance analysis"
echo "[A] Install ALL"
echo "[Q] Quit"
echo

read -p "Select plugin to install (1/2/3/A/Q): " choice

install_skill() {
    local PLUGIN_NAME=$1
    local SKILL_NAME=$2
    local SOURCE_PATH="$PLUGINS_DIR/$PLUGIN_NAME/skills/$SKILL_NAME"
    local LINK_PATH="$TARGET_DIR/$SKILL_NAME"

    # 检查源目录是否存在
    if [ ! -d "$SOURCE_PATH" ]; then
        echo "[ERROR] Source not found: $SOURCE_PATH"
        return
    fi

    # 检查目标是否已存在
    if [ -e "$LINK_PATH" ] || [ -L "$LINK_PATH" ]; then
        echo "[SKIP] Already exists: $SKILL_NAME"
        echo "       To reinstall, delete first: $LINK_PATH"
        return
    fi

    # 创建符号链接
    echo "[INSTALL] $SKILL_NAME"
    echo "          Source: $SOURCE_PATH"
    echo "          Target: $LINK_PATH"

    ln -s "$SOURCE_PATH" "$LINK_PATH"

    if [ $? -eq 0 ]; then
        echo "          [OK] Symlink created successfully"
    else
        echo "          [FAIL] Symlink creation failed"
    fi
    echo
}

case $choice in
    [Qq])
        echo "Cancelled."
        ;;
    [Aa])
        install_skill "product-design" "product-design-review"
        install_skill "system-design" "system-design-review"
        install_skill "code-design" "code-execution-efficiency"
        ;;
    1)
        install_skill "product-design" "product-design-review"
        ;;
    2)
        install_skill "system-design" "system-design-review"
        ;;
    3)
        install_skill "code-design" "code-execution-efficiency"
        ;;
    *)
        echo "Invalid choice."
        ;;
esac

echo
echo "========================================"
echo "  Installation Complete"
echo "  OpenCode skill directory: $TARGET_DIR"
echo "========================================"
echo
