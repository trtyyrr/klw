// 导入 KSU JS API
// 如果你本地有 ksu.js 文件，路径改为 './ksu.js'
import { exec, toast } from 'https://cdn.jsdelivr.net/npm/kernelsu/+esm';

const MOD_ID = "ultra_power_saver";
const BASE_PATH = `/data/adb/modules/${MOD_ID}`;

// 1. 更新 UI 状态
async function updateUI() {
    try {
        // 获取当前模式配置
        const { stdout: mode } = await exec(`cat ${BASE_PATH}/mode.conf`);
        document.getElementById('mode-val').innerText = mode.trim() || "未配置";

        // 检查 C++ 线程管理器进程
        const { stdout: pgrep } = await exec("pgrep thread_manager");
        const cppVal = document.getElementById('cpp-status');
        const indicator = document.getElementById('service-indicator');
        
        if (pgrep.trim()) {
            cppVal.innerText = "运行中 (PID: " + pgrep.trim() + ")";
            cppVal.style.color = "#4CAF50";
            indicator.style.backgroundColor = "#4CAF50";
        } else {
            cppVal.innerText = "已停止";
            cppVal.style.color = "#F44336";
            indicator.style.backgroundColor = "#F44336";
        }

        // 获取硬件信息摘要
        const { stdout: hw } = await exec(`grep "policy0_MAX" ${BASE_PATH}/hardware_params.conf`);
        document.getElementById('device-info').innerText = hw ? "设备已适配" : "需要扫描设备";

    } catch (err) {
        console.error("Update UI Failed", err);
    }
}

// 2. 切换模式逻辑
async function setMode(mode) {
    toast(`正在切换至 ${mode}...`);
    try {
        // 写入配置并杀掉旧的 C++ 进程，由 service.sh 自动拉起新的
        await exec(`echo "${mode}" > ${BASE_PATH}/mode.conf`);
        await exec(`pkill thread_manager`);
        
        // 立即手动执行一次 service.sh 应用底层参数
        await exec(`sh ${BASE_PATH}/service.sh`);
        
        setTimeout(updateUI, 500); // 延迟刷新以确保进程启动
    } catch (e) {
        toast("执行出错: " + e);
    }
}

// 3. 事件绑定
document.querySelectorAll('.mode-btn').forEach(btn => {
    btn.onclick = () => setMode(btn.dataset.mode);
});

document.getElementById('rescan-hw').onclick = async () => {
    toast("正在重新分析硬件节点...");
    await exec(`sh ${BASE_PATH}/src/auto_config.sh`);
    updateUI();
};

// 初始加载
updateUI();