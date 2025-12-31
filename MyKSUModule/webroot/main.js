// 引用 NPM 提供的 kernelsu 库
import { exec, toast } from 'https://cdn.jsdelivr.net/npm/kernelsu/+esm';

async function applySettings() {
    const mode = document.getElementById('modeSelector').value;
    const modulePath = "/data/adb/modules/ultra_power_saver"; // 需与 module.prop 的 ID 一致

    try {
        // 1. 将配置持久化到文件
        await exec(`echo "${mode}" > ${modulePath}/mode.conf`);
        
        // 2. 立即执行一次参数调整（不需要重启就生效）
        // 我们直接调用模块里的脚本来执行
        await exec(`sh ${modulePath}/service.sh`);

        toast(`已切换至: ${mode}`);
    } catch (error) {
        console.error(error);
        toast("执行失败，请检查 KSU 授权");
    }
}

// 绑定按钮事件
document.getElementById('applyBtn').onclick = applySettings;