# Root Exploit APK Project
集成 CVE-2026-21385 + CVE-2026-31431 等漏洞，针对 Android 7.1.2 车机 ROM 实现一键 Root

## 支持的漏洞

| CVE | 芯片/组件 | CVSS | 描述 |
|-----|-----------|------|------|
| CVE-2026-21385 | Qualcomm GPU | 7.8 HIGH | Qualcomm芯片内存对齐漏洞，可触发内核内存损坏实现提权 |
| CVE-2026-31431 | Linux Kernel crypto | 7.8 HIGH | 内核密码学子系统 algif_aead 内存操作漏洞 |

## 目标设备
- Android 7.1.2 (Nougat) 车机 ROM
- Qualcomm SoC (Snapdragon 4xx/6xx 系列)
- KingoRoot 兼容设备

## 项目结构

```
RootAPK/
├── app/
│   ├── src/main/
│   │   ├── java/com/exploit/root/
│   │   │   ├── MainActivity.java      # 主界面 + 完整 Root 逻辑
│   │   │   ├── RootService.java       # 后台 Root 服务
│   │   │   ├── BootReceiver.java      # 开机自启 Receiver
│   │   │   ├── ExploitNative.java     # JNI 接口定义
│   │   │   └── NativeLib.java         # Native 库封装
│   │   ├── jni/
│   │   │   ├── Android.mk
│   │   │   ├── Application.mk
│   │   │   └── exploit.c              # Native CVE exploit 实现
│   │   ├── res/
│   │   │   ├── layout/activity_main.xml
│   │   │   ├── values/strings.xml
│   │   │   ├── values/colors.xml
│   │   │   └── drawable/ic_launcher.xml
│   │   └── assets/
│   │       ├── kingo_ac64/kingo_ac64  # KingoRoot ARM64 exploit
│   │       └── kingo_ac               # KingoRoot ARM32 exploit
│   └── build.gradle
├── build.gradle
├── settings.gradle
├── .github/
│   └── workflows/
│       └── build.yml                  # GitHub Actions CI/CD
├── build_apk.bat                      # Windows 构建脚本
└── build_apk.sh                       # Linux/macOS 构建脚本
```

## 构建方式

### 方式1: GitHub Actions (自动构建)
```bash
git init
git add .
git commit -m "Initial RootAPK commit"
git remote add origin https://github.com/YOUR_USERNAME/RootAPK.git
git push -u origin main
# 自动触发构建，APK 输出在 Actions Artifacts
```

### 方式2: 本地 Gradle
```bash
cd RootAPK
gradle assembleDebug
# 输出: app/build/outputs/apk/debug/app-debug.apk
```

### 方式3: Android Studio
1. File → Open → 选择 RootAPK 目录
2. 等待 Gradle 同步完成
3. Build → Build APK

## 安装运行
```bash
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 使用流程
1. 打开应用，自动检测 root 状态
2. 点击"检测漏洞"检查 CVE-2026-21385/CVE-2026-31431 是否存在
3. 点击"开始提权"尝试提权 (按优先级尝试多种方法)
4. 成功后点击"Root Shell"访问 root 权限

## 提权方法 (按优先级)

1. **remount /system** - 直接 remount 系统分区并写入 su
2. **CVE-2026-21385** - Qualcomm GPU 内存对齐漏洞利用
3. **CVE-2026-31431** - Linux Kernel crypto 提权
4. **/data/local/tmp** - 临时目录 su 二进制
5. **KingoRoot** - 集成 exploit 二进制

## 技术架构

### Java 层
- `MainActivity` - UI + 主逻辑
- `RootService` - 后台服务，维持 root 会话
- `BootReceiver` - 开机自启
- `ExploitNative` - JNI 调用封装

### Native 层 (JNI)
- `libexploit.so` - C/C++ 编写的高权限 exploit
- 编译使用 Android NDK
- 支持 ARM32/ARM64 双架构

### Assets
- `kingo_ac64` - KingoRoot ARM64 exploit 二进制
- `kingo_ac` - KingoRoot ARM32 exploit 二进制

## 漏洞详情

### CVE-2026-21385
- **CVE ID**: CVE-2026-21385
- **来源**: Qualcomm, Inc.
- **CVSS**: 7.8 (HIGH)
- **向量**: CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H
- **类型**: Memory corruption while using alignments for memory allocation
- **影响**: Qualcomm GPU/mdss_fb 驱动内存对齐处理错误
- **利用**: 通过精心构造的图形缓冲区触发内核内存损坏，覆写 cred 结构体

### CVE-2026-31431
- **CVE ID**: CVE-2026-31431
- **来源**: kernel.org
- **CVSS**: 7.8 (HIGH)
- **向量**: CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H
- **类型**: crypto: algif_aead - 内核密码学操作内存漏洞
- **影响**: Linux kernel crypto/algif_aead 组件
- **利用**: AEAD 加密操作时的 out-of-place 操作漏洞

## 安全说明
⚠️ 本项目仅供安全研究学习使用，请遵守法律法规，未经授权的 root 操作是违法的。
