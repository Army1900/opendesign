#!/bin/bash

echo "========================================"
echo "  OpenDesign Skills Installer"
echo "  将 Skills 链接到用户级 Claude 配置目录"
echo "========================================"
echo

# 设置目标目录
TARGET_DIR="$HOME/.claude/skills"

# 检查目标目录是否存在，不存在则创建
if [ ! -d "$TARGET_DIR" ]; then
    echo "创建目标目录: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGINS_DIR="$SCRIPT_DIR/plugins"

echo "可用的插件:"
echo
echo "[1] product-design      - 产品设计审查"
echo "[2] system-design       - 系统设计审查"
echo "[3] code-design         - 代码性能分析"
echo "[A] 全部安装"
echo "[Q] 退出"
echo

read -p "请选择要安装的插件 (1/2/3/A/Q): " choice

install_skill() {
    local PLUGIN_NAME=$1
    local SKILL_NAME=$2
    local SOURCE_PATH="$PLUGINS_DIR/$PLUGIN_NAME/skills/$SKILL_NAME"
    local LINK_PATH="$TARGET_DIR/$SKILL_NAME"

    # 检查源目录是否存在
    if [ ! -d "$SOURCE_PATH" ]; then
        echo "[错误] 源目录不存在: $SOURCE_PATH"
        return
    fi

    # 检查目标是否已存在
    if [ -e "$LINK_PATH" ] || [ -L "$LINK_PATH" ]; then
        echo "[跳过] 已存在: $SKILL_NAME"
        echo "       如需重新安装，请先删除: $LINK_PATH"
        return
    fi

    # 创建符号链接
    echo "[安装] $SKILL_NAME"
    echo "       源: $SOURCE_PATH"
    echo "       目标: $LINK_PATH"

    ln -s "$SOURCE_PATH" "$LINK_PATH"

    if [ $? -eq 0 ]; then
        echo "       [成功] 符号链接创建成功"
    else
        echo "       [失败] 符号链接创建失败"
    fi
    echo
}

case $choice in
    [Qq])
        echo "已取消"
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
        echo "无效的选择"
        ;;
esac

echo
echo "========================================"
echo "  安装完成"
echo "  Skills 目录: $TARGET_DIR"
echo "========================================"
echo
