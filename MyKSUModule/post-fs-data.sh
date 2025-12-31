#!/system/bin/sh
MODDIR=${0%/*}

# 示例：禁止某些耗电的内核调试功能
if [ -d "/sys/kernel/debug" ]; then
    echo "0" > /sys/kernel/debug/tracing/tracing_on
fi