#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <dirent.h>
#include <sched.h>
#include <unistd.h>

using namespace std;

// 将特定 PID 绑定到小核 (通常是 CPU 0-3)
void bind_to_little_cores(int pid) {
    cpu_set_t mask;
    CPU_ZERO(&mask);
    for (int i = 0; i <= 3; i++) CPU_SET(i, &mask); 
    sched_setaffinity(pid, sizeof(mask), &mask);
}

void monitor_and_manage(string mode) {
    while (true) {
        if (mode == "powersave") {
            // 扫描所有进程，如果是第三方 App，强制压入小核
            DIR* dir = opendir("/proc");
            struct dirent* entry;
            while ((entry = readdir(dir)) != nullptr) {
                int pid = atoi(entry->d_name);
                if (pid > 1000) { // 简单过滤系统基础进程
                    bind_to_little_cores(pid);
                }
            }
            closedir(dir);
        }
        sleep(30); // 每30秒轮询一次，平衡功耗
    }
}

int main() {
    // 读取 mode.conf
    ifstream conf("/data/adb/modules/ultra_power_saver/mode.conf");
    string mode;
    if (conf >> mode) {
        monitor_and_manage(mode);
    }
    return 0;
}