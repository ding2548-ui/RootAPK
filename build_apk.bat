# ============================================================
# CVE Root - 一键构建 APK
# ============================================================

@echo off
setlocal

set DIR=%~dp0
cd /d "%DIR%RootAPK"

echo =========================================
echo   CVE Root APK 构建脚本
echo =========================================

REM 检查 Gradle
where gradle >nul 2>&1
if %errorlevel% neq 0 (
    echo Gradle 未安装，将尝试使用 wrapper...
)

REM 检查 Android SDK
if not defined ANDROID_HOME (
    if exist "%USERPROFILE%\AppData\Local\Android\Sdk" (
        set ANDROID_HOME=%USERPROFILE%\AppData\Local\Android\Sdk
    ) else if exist "C:\Android\android-sdk" (
        set ANDROID_HOME=C:\Android\android-sdk
    )
)

echo ANDROID_HOME: %ANDROID_HOME%

REM 清理
echo 清理构建...
if exist "app\build" rmdir /s /q "app\build"

REM 构建
echo 开始构建...

if exist "gradlew.bat" (
    call gradlew.bat assembleDebug
) else if exist "gradlew" (
    call gradlew assembleDebug
) else (
    gradle assembleDebug
)

REM 检查结果
if exist "app\build\outputs\apk\debug\app-debug.apk" (
    echo =========================================
    echo 构建成功!
    echo APK: %DIR%RootAPK\app\build\outputs\apk\debug\app-debug.apk
    echo =========================================
    echo.
    echo 安装命令:
    echo   adb install "%DIR%RootAPK\app\build\outputs\apk\debug\app-debug.apk"
) else (
    echo =========================================
    echo 构建失败!
    echo =========================================
    exit /b 1
)

endlocal