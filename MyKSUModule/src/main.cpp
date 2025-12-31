#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <dirent.h>
#include <sched.h>
#include <unistd.h>
#include <sys/resource.h>

using namespace std;

// 定义核心掩码：通常 0-3 是小核 (Little Cores)
void bind_to_little_cores(int pid) {
    cpu_set_t mask;
    CPU_ZERO(&mask);
    // 强制绑定到前 4 个核心 (0,1,2,3)
    for (int i = 0; i <= 3; i++) {
        CPU_SET(i, &mask);
    }
    // 应用到进程及其所有线程
    if (sched_setaffinity(pid, sizeof(mask), &mask) == -1) {
        // 某些系统进程可能失败，属于正常现象
    }
}

// 检查模式：从配置文件读取 WebUI 设置
string get_current_mode() {
    ifstream conf("/data/adb/modules/ultra_power_saver/mode.conf");
    string mode;
    if (conf >> mode) return mode;
    return "balance";
}

void run_power_strategy() {
    while (true) {
        string mode = get_current_mode();

        if (mode == "powersave") {
            DIR* dir = opendir("/proc");
            if (dir == nullptr) return;

            struct dirent* entry;
            while ((entry = readdir(dir)) != nullptr) {
                // 只处理数字命名的文件夹 (PID)
                int pid = atoi(entry->d_name);
                if (pid > 500) { 
                    // 这里可以根据 PID 进一步过滤
                    // 在超级省电模式下，将大部分非核心进程压入小核
                    bind_to_little_cores(pid);
                }
            }
            closedir(dir);
        }

        // 每 30 秒扫描一次，防止频繁操作增加功耗
        sleep(30);
    }
}

int main() {
    // 设置程序自身的优先级为最低，避免管理器本身耗电
    setpriority(PRIO_PROCESS, 0, 19);
    
    // 启动监控循环
    run_power_strategy();
    
    return 0;
}