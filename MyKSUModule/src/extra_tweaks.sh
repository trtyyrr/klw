#!/system/bin/sh
# 进阶省电微调

# 1. 优化 I/O 队列 (减少唤醒)
for disk in /sys/block/sd*; do
    echo "1024" > "$disk/queue/read_ahead_kb"
    echo "0" > "$disk/queue/add_random"
done

# 2. 虚拟机参数调优 (减少写入频率，省电)
echo "1500" > /proc/sys/vm/dirty_writeback_centisecs
echo "10" > /proc/sys/vm/swappiness

# 3. 限制 GMS 唤醒 (选做，可能会导致通知延迟)
# pm disable com.google.android.gms/.chimera.GmsIntentOperationService