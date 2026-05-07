# Root Exploit APK Project
集成 CVE-2026-21385 + CVE-2026-31431 等漏洞，针对 Android 7.1.2 车机 ROM 实现一键 Root

## ⚠️ 免责声明
本项目仅用于安全研究和学习目的。请遵守当地法律法规，未经授权对他人设备进行root操作是违法行为。

## 支持的漏洞

| CVE | 芯片/组件 | 评分 | 描述 |
|-----|-----------|------|------|
| CVE-2026-21385 | Qualcomm GPU | 7.8 HIGH | 内存对齐漏洞，可用于提权 |
| CVE-2026-31431 | Linux Kernel crypto | 7.8 HIGH | 内核密码学子系统提权 |

## 支持的设备
- Android 7.1.2 (Nougat)
- 基于 Qualcomm SoC 的车机 ROM
- KingoRoot exploit 二进制兼容

## 文件结构
```
RootAPK/
├── app/
│   ├── src/main/
│   │   ├── java/com/exploit/root/
│   │   │   ├── MainActivity.java      # 主界面 + Root 逻辑
│   │   │   ├── RootService.java       # 后台服务
│   │   │   ├── BootReceiver.java      # 开机自启
│   │   │   ├── ExploitNative.java     # JNI 接口
│   │   │   └── NativeLib.java         # Native 库封装
│   │   ├── jni/                       # Native C/C++ 代码
│   │   │   ├── Android.mk
│   │   │   ├── Application.mk
│   │   │   └── exploit.c              # CVE-2026-21385 exploit
│   │   ├── res/
│   │   └── assets/
│   │       ├── kingo_ac64             # KingoRoot ARM64
│   │       └── kingo_ac               # KingoRoot ARM32
│   └── build.gradle
├── build.gradle
├── settings.gradle
└── .github/workflows/
    └── build.yml                      # CI/CD 自动构建
```

## 构建方法

### 方法1: GitHub Actions (推荐)
```bash
git push
# 自动触发构建，无需本地配置
```

### 方法2: 本地 Gradle
```bash
cd RootAPK
./gradlew assembleDebug
```

### 方法3: Android Studio
1. 用 Android Studio 打开 RootAPK 目录
2. 等待 Gradle 同步完成
3. Build → Build APK

## 安装和运行
```bash
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 使用说明

1. **打开应用** - 应用会自动检测 root 状态
2. **检测漏洞** - 点击检测按钮检查 CVE-2026-21385/CVE-2026-31431 是否存在
3. **开始提权** - 点击提权按钮，系统会按顺序尝试：
   - remount /system + 创建 su
   - CVE-2026-21385 exploit (Qualcomm 内存对齐漏洞)
   - CVE-2026-31431 exploit (内核提权)
   - /data/local/tmp 替代方案
   - KingoRoot exploit 二进制
4. **Root Shell** - 提权成功后点击访问 root 权限

## 漏洞利用原理

### CVE-2026-21385 (Qualcomm GPU 内存对齐)
- 触发 `mdss_fb` 驱动中的内存对齐处理错误
- 通过精心构造的图形缓冲区分配请求触发内核内存损坏
- 利用 `cred` 结构体覆写实现特权提升
- 需要 Qualcomm Adreno GPU 环境

### CVE-2026-31431 (Linux Kernel crypto)
- 内核 `algif_aead` 组件的内存对齐操作漏洞
- 在处理 AEAD (Authenticated Encryption with Associated Data) 时
- 可以触发 out-of-bounds 写入
- 获取内核态执行权限后覆写 `cred` 结构体

### KingoRoot Exploit
- 集成成熟的 KingoRoot exploit 二进制
- 支持 ARM32/ARM64 架构自动选择
- 通过 `su` 二进制创建实现持久化 root

## 技术细节

### 提权流程
```
1. checkRootStatus()     → 检测当前 root 状态
2. checkVulnerability()  → 检测漏洞是否存在
3. runExploit()          → 执行提权
   ├── remountSystem()    → remount /system
   ├── cve202621385()     → CVE-2026-21385 exploit
   ├── cve202631431()     → CVE-2026-31431 exploit
   ├── tmpFallback()      → /data/local/tmp 方案
   └── kingoRoot()        → KingoRoot 二进制
4. verifyRoot()          → 验证 root 状态
```

### Native JNI
- `libexploit.so` 提供底层 exploit 接口
- 使用 Android NDK 编译
- 支持 ARM32 (armeabi-v7a) 和 ARM64 (arm64-v8a)

## License
MIT License - 仅供学习研究使用
