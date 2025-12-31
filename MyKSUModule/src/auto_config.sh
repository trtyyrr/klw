#!/system/bin/sh
# 自动生成适配当前硬件的省电/性能参数

MODDIR="/data/adb/modules/ultra_power_saver"
OUT_FILE="$MODDIR/hardware_params.conf"

echo "# 自动生成的设备参数 - $(date)" > "$OUT_FILE"

# 1. 获取 CPU 簇信息 (Policy)
for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    P_ID=$(basename "$policy")
    
    # 获取该簇支持的所有频率
    if [ -f "$policy/scaling_available_frequencies" ]; then
        FREQS=$(cat "$policy/scaling_available_frequencies")
        # 获取最大和最小频率
        MAX_FREQ=$(echo "$FREQS" | awk '{print $NF}')
        MIN_FREQ=$(echo "$FREQS" | awk '{print $1}')
        
        # 计算省电频率 (取最大频率的 60% 附近的可用频率)
        SAVE_FREQ=$(echo "$MAX_FREQ" | awk '{print int($1 * 0.6)}")
        
        # 写入配置
        echo "${P_ID}_MAX=$MAX_FREQ" >> "$OUT_FILE"
        echo "${P_ID}_MIN=$MIN_FREQ" >> "$OUT_FILE"
        echo "${P_ID}_SAVE=$SAVE_FREQ" >> "$OUT_FILE"
    fi
done

# 2. 获取 GPU 路径 (高通示例)
GPU_MAX_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
if [ -f "$GPU_MAX_PATH" ]; then
    echo "GPU_PATH=$GPU_MAX_PATH" >> "$OUT_FILE"
    echo "GPU_MAX=$(cat $GPU_MAX_PATH)" >> "$OUT_FILE"
fi

echo "info: 硬件参数扫描完成"