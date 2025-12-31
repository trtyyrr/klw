#!/system/bin/sh
# MODDIR 是当前脚本所在的目录
MODDIR=${0%/*}

# 1. 读取配置文件 (如果没有则默认为 balance)
CONF_FILE="$MODDIR/mode.conf"
if [ -f "$CONF_FILE" ]; then
    MODE=$(cat "$CONF_FILE")
else
    MODE="balance"
fi

# 2. 执行核心省电/性能逻辑
case "$MODE" in
    "powersave")
        # --- 超级省电模式策略 ---
        # 限制大核心频率 (示例：假设 4-7 是大核，将其最大频率锁定在较低值)
        echo 1200000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
        echo 1200000 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq
        
        # 切换调度器为 powersave
        echo "powersave" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
        
        # 关闭内核增压 (Boost)
        echo 0 > /sys/devices/system/cpu/cpufreq/boost
        
        # 限制 GPU 频率
        # echo 300 > /sys/class/kgsl/kgsl-3d0/max_gpuclk
        ;;

    "performance")
        # --- 高性能模式策略 ---
        echo "performance" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
        echo 1 > /sys/devices/system/cpu/cpufreq/boost
        ;;

    "balance"|*)
        # --- 平衡模式 (恢复默认) ---
        echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
        # 恢复默认频率限制（此处建议根据具体机型填值）
        ;;
esac

exit 0