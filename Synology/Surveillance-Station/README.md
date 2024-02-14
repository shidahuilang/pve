#### 群晖监控套件破解授权
- 仅支持群晖监控套件版本9.1.2-10854
- 需要先下载并手动安装群晖监控套件后进行破解授权
- 破解授权后请勿升级群晖监控套件
---

#### A. x86_64 (9.1.2-10854)
- 套件下载链接: https://global.synologydownload.com/download/Package/spk/SurveillanceStation/9.1.2-10854/SurveillanceStation-x86_64-9.1.2-10854.spk

---
#### 破解授权步骤
- 打开群晖控制面板 -> 任务计划程序
- 创建 -> 计划任务 -> 用户定义的脚本
- 常规：用户 = root，取消选中启用
- 任务设置：用户定义的脚本（脚本内容如下）
```
bash <(curl -L https://cdn.jsdelivr.net/gh/shidahuilang/pve/Synology/Surveillance-Station/lib/SurveillanceStation-x86_64/install_license)
```
- 确定 - 确定
- 运行任务
- 当您看到有 58 个许可证时，请删除此任务

---
#### 删除许可证
- 脚本:
```
bash <(curl -L https://cdn.jsdelivr.net/gh/shidahuilang/pve/Synology/Surveillance-Station/Surveillance-Station/lib/license/remove_license)
```
