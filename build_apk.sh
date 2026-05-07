#!/bin/bash
# ============================================================
# CVE Root APK 快速构建脚本
# 
# 需求: Android SDK + Gradle 或 Android Studio
# ============================================================

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR/RootAPK"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  CVE Root APK 构建脚本${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查 Gradle
if ! command -v gradle &> /dev/null; then
    echo -e "${YELLOW}Gradle 未安装,尝试使用 wrapper...${NC}"
fi

# 检查 SDK
if [ -z "$ANDROID_HOME" ]; then
    if [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
    elif [ -d "/opt/android-sdk" ]; then
        export ANDROID_HOME="/opt/android-sdk"
    fi
fi

echo -e "ANDROID_HOME: ${ANDROID_HOME:-未设置}"

# 清理
echo -e "${YELLOW}清理构建...${NC}"
rm -rf app/build 2>/dev/null || true

# 构建
echo -e "${YELLOW}开始构建...${NC}"

if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
    ./gradlew assembleDebug
else
    gradle assembleDebug
fi

# 检查结果
APK="app/build/outputs/apk/debug/app-debug.apk"
if [ -f "$APK" ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}构建成功!${NC}"
    echo -e "${GREEN}APK: $(realpath "$APK")${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "安装命令:"
    echo "  adb install $(realpath "$APK")"
else
    echo -e "${RED}构建失败!${NC}"
    exit 1
fi