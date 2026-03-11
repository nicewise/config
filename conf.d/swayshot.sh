#!/usr/bin/env bash
# Sway 截图脚本 (grim + slurp)
# 替代 X11 的 print.sh

# 截图保存目录
SHOT_DIR="$HOME"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

print_help() {
    echo "swayshot.sh           - 截取整个屏幕"
    echo "swayshot.sh -s        - 截取选定区域"
    echo "swayshot.sh -w        - 截取当前窗口"
    echo "swayshot.sh --help    - 显示帮助"
}

case "${1}" in
    "")
        # 截取所有输出
        grim "$SHOT_DIR/Screenshot-${TIMESTAMP}.png"
        ;;
    "-s")
        # 选择区域
        grim -g "$(slurp)" "$SHOT_DIR/Screenshot-${TIMESTAMP}.png"
        ;;
    "-w")
        # 截取当前焦点窗口
        grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" "$SHOT_DIR/Screenshot-${TIMESTAMP}.png"
        ;;
    "-h"|"--help")
        print_help
        ;;
    *)
        echo "未知选项: $1"
        print_help
        exit 1
        ;;
esac
