#!/system/bin/sh
MODDIR=${0%/*}

# 如果没有硬件配置文件，先生成一个
[ ! -f "$MODDIR/hardware_params.conf" ] && sh "$MODDIR/src/auto_config.sh"

# 加载动态参数
. "$MODDIR/hardware_params.conf"

# 读取用户在 WebUI 选的模式
MODE=$(cat "$MODDIR/mode.conf" 2>/dev/null || echo "balance")

apply_powersave() {
    # 动态应用省电频率（根据 auto_config 计算出的 60% 频率）
    for i in 0 4 7; do # 针对典型大中小核架构
        [ -d "/sys/devices/system/cpu/cpufreq/policy$i" ] && \
        echo "$(eval echo \$policy${i}_SAVE)" > "/sys/devices/system/cpu/cpufreq/policy$i/scaling_max_freq"
    done
    
    # 降低 GPU 频率到最低（如果有的话）
    [ -f "$GPU_PATH" ] && echo "305000000" > "$GPU_PATH"
}

apply_performance() {
    # 恢复最大频率
    for i in 0 4 7; do
        [ -d "/sys/devices/system/cpu/cpufreq/policy$i" ] && \
        echo "$(eval echo \$policy${i}_MAX)" > "/sys/devices/system/cpu/cpufreq/policy$i/scaling_max_freq"
    done
}

case "$MODE" in
    "powersave") apply_powersave ;;
    "performance") apply_performance ;;
    *) # 恢复默认逻辑... ;;
esac