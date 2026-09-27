@echo off
chcp 65001 >nul
rem =====================================================================
rem  build_and_install.bat
rem  一键：编译 Debug APK 并用 adb 安装/启动到模拟器
rem  前提：已安装 JDK 17+ 与 Android SDK，并且网络可以访问 google()/mavenCentral()
rem =====================================================================
setlocal

set "APP_NAME=HelloWorld"
set "PKG=com.example.helloworld"
set "APK=app\build\outputs\apk\debug\app-debug.apk"

echo [1/4] 检查 Android SDK 路径...
if not exist "local.properties" (
    if not "%ANDROID_HOME%"=="" (
        echo sdk.dir=%ANDROID_HOME:\=\\%> local.properties
        echo     已根据 ANDROID_HOME 生成 local.properties
    ) else (
        echo     警告：没有 local.properties，也没有 ANDROID_HOME 环境变量。
        echo     请手动把 SDK 路径写进 local.properties：sdk.dir=C\:\\Users\\你的用户名\\AppData\\Local\\Android\\Sdk
    )
)

echo [2/4] 编译 Debug APK（第一次会比较慢，需要下载依赖）...
call gradlew.bat :app:assembleDebug
if errorlevel 1 (
    echo 编译失败，请检查上面的错误信息。
    exit /b 1
)

echo [3/4] 安装到设备/模拟器...
adb install -r "%APK%"
if errorlevel 1 (
    echo 安装失败：确认模拟器已经启动（adb devices 能看到设备）。
    exit /b 1
)

echo [4/4] 启动 APP...
adb shell am start -n %PKG%/.MainActivity

echo.
echo 完成。可以用下面命令查看界面里的控件层级：
echo   adb shell dumpsys activity top ^| findstr /i button
endlocal
