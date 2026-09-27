# 多语言 Hello World（跟随系统语言 / 纯代码界面 / adb 调试）

Android 实验工程：不写一行布局 XML，界面全部用 Kotlin 代码创建；**按手机的系统语言自动显示对应语言的问候语和国旗**。

- **APP 名称（桌面标题）**：`袁连一2024110545`
- **包名**：`com.example.helloworld`
- **入口**：`app/src/main/java/com/example/helloworld/MainActivity.kt`

## 它是怎么“跟着系统语言变”的

用的是 Android 的**资源限定符**，代码里不写任何 `if (语言 == ...)`：

| 系统语言 | 字符串资源 | 国旗资源 | 界面显示 |
| --- | --- | --- | --- |
| 英语（或其它语言） | `res/values/strings_default.xml` | `res/drawable-en/flag.png` | 英国国旗 + `Hello, World!` |
| 中文 | `res/values-zh/strings.xml` | `res/drawable-zh/flag.png` | 中国国旗 + `你好，世界！` |
| 日本語 | `res/values-ja/strings.xml` | `res/drawable-ja/flag.png` | 日本国旗 + `こんにちは、世界！` |

代码里只写 `R.string.greeting` 和 `R.drawable.flag`，**具体取哪一份由系统按当前语言决定**，切换系统语言后 Activity 会被系统重建，界面自动变成新语言。这就是 Android 推荐的国际化（i18n）做法。

---

## 一、3 分钟跑起来

### 1. 用 Android Studio 打开（推荐）

1. Android Studio → **Open** → 选择本工程根目录（有 `settings.gradle.kts` 的那一层）。
2. 第一次同步会自动下载 Gradle 9.0.0 和依赖，需联网。
3. 若提示 `SDK location not found`，在工程根目录新建 `local.properties`：

```properties
sdk.dir=C\:\\Users\\<你的用户名>\\AppData\\Local\\Android\\Sdk
```

4. 启动模拟器（Device Manager 里创建/启动一个 AVD），点绿色 ▶ 运行。

### 2. 纯命令行

```bat
:: 编译 + 安装 + 启动（脚本会自动补 local.properties）
build_and_install.bat
```

或者手动：

```bat
gradlew.bat :app:assembleDebug
adb install -r app\build\outputs\apk\debug\app-debug.apk
adb shell am start -n com.example.helloworld/.MainActivity
```

> **首次命令行构建前**：本工程随附 `gradle/wrapper/gradle-wrapper.properties`、`gradlew`、`gradlew.bat`，但没有二进制 `gradle-wrapper.jar`（不方便用文本形式提供）。用下面任一方式补齐即可：
>
> - **方式 A（最简单）**：用 Android Studio 打开工程同步一次，Studio 会自动补上 wrapper；
> - **方式 B**：如果本机已装 Gradle，在工程根目录执行 `gradle wrapper --gradle-version 9.0.0`；
> - **方式 C**：从任意一个已有 Gradle 缓存里复制。Gradle 发行包自带这个 jar，找到解压后的目录：
>   `%USERPROFILE%\.gradle\wrapper\dists\gradle-9.0.0-bin\<hash>\gradle-9.0.0\lib\gradle-wrapper-9.0.0.jar`
>   （注意是 `lib\`，不是 `lib\plugins\`），把它复制并改名为 `gradle\wrapper\gradle-wrapper.jar`。
> - **方式 D（命令行党）**：本机装了任意版本 Gradle 的话，在工程根目录执行
>   `gradle wrapper --gradle-version 9.0.0 --distribution-type bin`，它会同时生成 jar 和脚本。

---

## 一之二、Gradle Sync 失败 / 下载超时怎么办（国内网络必看）

如果 Build 窗口出现：

```
Could not install Gradle distribution from 'https://services.gradle.org/distributions/gradle-9.0.0-bin.zip'
Reason: java.net.SocketTimeoutException: Connect timed out
```

这不是代码问题，而是 **Gradle 发行包（约 130MB）和依赖仓库连不上**。本工程已经默认改成国内镜像，如果还不行，按下面顺序逐个排查：

**⓪ 清掉上次下载失败的残留**（很重要）—— 删掉这个目录，否则 Gradle 可能继续用坏的半成品：

```
C:\Users\<用户名>\.gradle\wrapper\dists\gradle-9.0.0-bin\
```

然后 **File → Sync Project with Gradle Files** 重新同步。

**① 换 Gradle 发行包镜像** —— 改 `gradle/wrapper/gradle-wrapper.properties` 里的 `distributionUrl`：

```properties
# 腾讯云（本工程默认）
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-9.0.0-bin.zip
# 华为云
distributionUrl=https\://mirrors.huaweicloud.com/gradle/gradle-9.0.0-bin.zip
# 阿里云
distributionUrl=https\://mirrors.aliyun.com/macports/distfiles/gradle/gradle-9.0.0-bin.zip
```

**② 换依赖仓库镜像** —— 已经写在 `settings.gradle.kts` 里（`maven.aliyun.com/repository/google` 和 `/public`），
它们分别代理 Google Maven（AGP、AndroidX）和 Maven Central（Kotlin）。

**③ 用浏览器手动下载（最稳）** —— 浏览器能打开下载链接的话：

1. 下载 `gradle-9.0.0-bin.zip` 到本地，例如 `D:\gradle-9.0.0-bin.zip`（**不要解压**）；
2. `distributionUrl=file\:///D:/gradle-9.0.0-bin.zip`（注意正斜杠）；
3. **File → Settings → Build, Execution, Deployment → Gradle**，把 *Gradle JDK* 设为 JBR 17/21；
4. Sync。

**④ 用 Android Studio 自带的 Gradle** —— Settings → Gradle → 选 *Use Gradle from: 'wrapper'* 改成
*Specified location*，指向一个已装好的 Gradle 目录（例如 Android Studio 插件目录里的 `gradle`），
并在 `settings.gradle.kts` 保持镜像仓库不变。

**⑤ 还不行就查代理** —— 如果电脑用了公司代理/加速器，在 `gradle.properties` 里加：

```properties
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=7890
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=7890
```

> 判断方法：浏览器能打开 `https://mirrors.cloud.tencent.com/gradle/gradle-9.0.0-bin.zip` 说明网络没问题，
> 那就是 Android Studio 里的代理设置没配好（Settings → HTTP Proxy → No proxy / Auto-detect）。

---

## 二、adb 调试（对应实验要求 3.(4)）

```bat
:: 装 + 启动
adb install -r app\build\outputs\apk\debug\app-debug.apk
adb shell am start -n com.example.helloworld/.MainActivity

:: ============ 验证“跟随系统语言” ============
:: 1) 切成简体中文（App 应立刻变成 中国国旗 + 你好，世界！）
adb shell "setprop persist.sys.locale zh-CN; setprop ctl.restart zygote"
:: 或者：adb shell am broadcast -a android.intent.action.LOCALE_CHANGED

:: 2) 切成日语（日本国旗 + こんにちは、世界！）
adb shell "setprop persist.sys.locale ja-JP; setprop ctl.restart zygote"

:: 3) 切成英语（英国国旗 + Hello, World!）
adb shell "setprop persist.sys.locale en-US; setprop ctl.restart zygote"

:: 4) 如果切完语言界面没变，重启一下 APP（或点界面上的“刷新”按钮）
adb shell am force-stop com.example.helloworld
adb shell am start -n com.example.helloworld/.MainActivity

:: 5) 查看当前已生效的系统语言
adb shell getprop persist.sys.locale
adb shell getprop ro.product.locale

:: ============ adb 模拟操作界面 ============
:: 得到分辨率
adb shell wm size

:: 方式一：模拟触摸（点击屏幕坐标：按下+抬起）
adb shell input tap 540 1500

:: 方式二：模拟按键
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent 66

:: 方式三：先 dump 界面拿到控件真实坐标，再点
adb shell uiautomator dump /sdcard/ui.xml
adb shell cat /sdcard/ui.xml
::   在输出里找对应控件节点，读它的 bounds="[x1,y1][x2,y2]"，中心点就是 tap 坐标

:: 截图
adb exec-out screencap -p > shot.png
```

> ⚠️ `setprop ctl.restart zygote` 会让模拟器**重启一次界面**（黑屏几秒），这是正常的，等桌面回来再看 APP。
> 最稳妥的办法其实还是在模拟器里手动改：**Settings → System → Languages & input → Languages → Add a language**，
> 加到第一位即可，效果和上面命令完全一样。

---

## 三、工程结构

```
HelloWorld/
├── settings.gradle.kts              声明仓库与 :app 模块
├── build.gradle.kts                 插件版本（AGP 8.13.0 / Kotlin 2.2.0）
├── gradle.properties                开启 AndroidX 等
├── gradlew / gradlew.bat            Gradle wrapper 脚本
├── build_and_install.bat            一键编译+adb安装+启动
├── 实验报告.md                       提交用的实验报告（按学校要求格式）
├── tools/
│   ├── gen_assets.ps1               本地绘制国旗与图标（无需联网）
│   └── preview/                     生成结果预览（可直接看国旗长啥样）
└── app/
    ├── build.gradle.kts
    └── src/main/
        ├── AndroidManifest.xml
        ├── java/com/example/helloworld/MainActivity.kt   ★ 纯代码界面
        └── res/
            ├── values/strings_default.xml      默认（英文）Hello, World!
            ├── values-zh/strings.xml           中文：你好，世界！
            ├── values-ja/strings.xml           日语：こんにちは、世界！
            ├── values/themes.xml               主题（无 ActionBar）
            ├── values/colors.xml               图标背景色
            ├── drawable/ic_launcher_background.xml        图标背景（纯色 Shape）
            ├── drawable/flag.png               默认国旗（未适配语言时显示）
            ├── drawable-en/flag.png            英国国旗（英文系统显示）
            ├── drawable-zh/flag.png            中国国旗（中文系统显示）
            ├── drawable-ja/flag.png            日本国旗（日文系统显示）
            ├── mipmap-xxxhdpi/ic_launcher_foreground.png  图标前景
            └── mipmap-anydpi-v26/ic_launcher.xml          自适应图标
                mipmap-anydpi-v26/ic_launcher_round.xml
```

**注意两点：**
1. 工程里**没有 `res/layout/` 目录**——这正是实验要求“不采用布局文件，界面部分改为纯代码实现”的体现。
2. 三面国旗**文件名都叫 `flag.png`**，靠所在的目录（`drawable-en` / `drawable-zh` / `drawable-ja`）区分，系统根据语言自动挑一张 —— 跟 `strings.xml` 是一个原理。
3. ⚠️ **`drawable/flag.png`（不带语言限定符的默认那份）必须存在**，否则 Android Studio 不会为 `R.drawable.flag` 生成引用，编译会报 `Unresolved reference 'flag'` —— 这是最容易踩的坑。字符串同理，要有 `values/strings_default.xml` 兜底。

---

## 四、想换个语言 / 换名字怎么办

1. **再加一种语言（比如韩语）**：新建 `res/values-ko/strings.xml` 写问候语，新建 `res/drawable-ko/flag.png` 放国旗，**代码一行都不用改**——这就是资源限定符的好处。
2. **换姓名学号**：改三个 `strings.xml` 里的 `app_name`（`values/strings_default.xml`、`values-zh/strings.xml`、`values-ja/strings.xml`）。`AndroidManifest.xml` 不用动（它引用的是 `@string/app_name`）。如果已经装过 APP，要 `adb uninstall com.example.helloworld` 再装，否则桌面图标/名称可能还是旧的。

---

## 五、版本对照（编译不过时先看这里）

| 组件 | 本工程设置 | 说明 |
| --- | --- | --- |
| Gradle | 9.0.0 | 见 `gradle/wrapper/gradle-wrapper.properties` |
| Android Gradle Plugin | 8.13.0 | 需 Gradle 9.x、JDK 17+ |
| Kotlin | 2.2.0 | 用到 `enum.entries`，需 Kotlin ≥ 1.9 |
| compileSdk / targetSdk | 36 | 若你本机只装了 API 37，把 `app/build.gradle.kts` 的 `compileSdk` 改成 37 |
| minSdk | 24 | Android 7.0 及以上 |
| JDK | 17+ | Android Studio 自带的 JBR 即可；命令行构建可设 `JAVA_HOME` |

---

## 六、提交到 Gitee

```bat
git init
git add .
git commit -m "Android 实验：跟随系统语言的多语言 Hello World（纯代码界面）"
git branch -M main
git remote add origin https://gitee.com/<你的用户名>/<仓库名>.git
git push -u origin main
```

> 推送时如果要求密码，请填 Gitee 的**私人令牌**（设置 → 私人令牌），不要填登录密码。
> `local.properties` 已被 `.gitignore` 忽略，不会把本机路径传上去。
