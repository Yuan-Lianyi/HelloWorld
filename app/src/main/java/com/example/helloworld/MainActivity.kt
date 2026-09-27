package com.example.helloworld

import android.content.res.Configuration
import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

/**
 * 多语言 Hello World（纯代码界面，没有任何 layout XML 文件）
 *
 * 语言显示规则：**跟随手机的系统语言自动切换**，靠的是 Android 的资源限定符：
 *
 *   res/values/strings_default.xml  -> 默认（英文）  Hello, World!
 *   res/values-zh/strings.xml       -> 中文系统     你好，世界！
 *   res/values-ja/strings.xml       -> 日语系统     こんにちは、世界！
 *
 *   res/drawable-en/flag.png        -> 默认（英文） 英国国旗
 *   res/drawable-zh/flag.png        -> 中文系统     中国国旗
 *   res/drawable-ja/flag.png        -> 日语系统     日本国旗
 *
 * 代码里只写 @string/greeting 和 @drawable/flag，具体取哪一份由系统按当前语言决定，
 * 所以 Activity 里没有任何 if/else 判断语言，这就是 Android 推荐的国际化（i18n）做法。
 */
class MainActivity : AppCompatActivity() {

    private lateinit var greetView: TextView
    private lateinit var hintView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(buildRootView())
        refreshTexts()
    }

    /**
     * 系统语言变化时（模拟器里用 adb 切换语言测试），Activity 默认会被系统重建，
     * 重新走一遍 onCreate，文字和国旗就自动换成新语言的了。
     */
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        refreshTexts()
    }

    // ------------------------------------------------------------------
    // 1. 纯代码构建界面（对应实验要求 “不使用布局文件，界面改为纯代码实现”）
    // ------------------------------------------------------------------
    private fun buildRootView(): View {
        val pad = dp(24)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#FFFFFF"))
            setPadding(pad, pad, pad, pad)
            // 适配 Android 15+ 的沉浸式（edge-to-edge）布局，避免内容顶到状态栏
            setOnApplyWindowInsetsListener { v, insets ->
                v.setPadding(
                    pad,
                    pad + insets.systemWindowInsetTop,
                    pad,
                    pad + insets.systemWindowInsetBottom
                )
                insets
            }
        }

        // 顶部标题：@string/app_name（各语言下都是“袁连一2024110545”）
        val titleView = TextView(this).apply {
            text = getString(R.string.app_name)
            textSize = 20f
            setTextColor(Color.parseColor("#333333"))
            gravity = Gravity.CENTER
        }

        // 国旗：@drawable/flag，按系统语言自动取 drawable-en / -zh / -ja 里的那一张
        val flagView = ImageView(this).apply {
            adjustViewBounds = true
            setImageResource(R.drawable.flag)
            layoutParams = LinearLayout.LayoutParams(dp(210), dp(140)).apply {
                topMargin = dp(24)
            }
        }

        // 问候语：@string/greeting，按系统语言自动取对应语言的那一份
        greetView = TextView(this).apply {
            textSize = 34f
            setTextColor(Color.parseColor("#222222"))
            gravity = Gravity.CENTER
            setPadding(0, dp(24), 0, 0)
        }

        // 提示：显示当前系统语言代码，方便验证“确实是跟着系统语言变的”
        hintView = TextView(this).apply {
            textSize = 15f
            setTextColor(Color.parseColor("#888888"))
            gravity = Gravity.CENTER
            setPadding(0, dp(10), 0, dp(24))
        }

        // 刷新按钮：如果模拟器切换语言后界面没立刻跟着变，点一下手动刷新
        val refreshButton = Button(this).apply {
            text = getString(R.string.refresh)
            isAllCaps = false
            setOnClickListener { recreate() }
        }

        root.addView(titleView)
        root.addView(flagView)
        root.addView(greetView)
        root.addView(hintView)
        root.addView(
            refreshButton,
            LinearLayout.LayoutParams(dp(200), ViewGroup.LayoutParams.WRAP_CONTENT)
        )
        return root
    }

    // ------------------------------------------------------------------
    // 2. 读取“当前生效的语言”，把问候语和系统语言提示刷到界面上
    // ------------------------------------------------------------------
    private fun refreshTexts() {
        // Locale 的 language 字段是小写的（zh / ja / en），资源目录里的限定符大小写都可以，
        // 这里统一转成小写，再映射成给人看的名字。
        val language = currentLanguageTag().substringBefore('-').lowercase()
        val displayName = when (language) {
            "zh" -> "中文 (zh)"
            "ja" -> "日本語 (ja)"
            else -> "English ($language)"
        }
        greetView.text = getString(R.string.greeting)
        hintView.text = getString(R.string.system_language_hint, displayName)
    }

    /** 取当前生效的语言标签：优先用 Configuration.getLocales()（Android 7.0+），再兜底 Configuration.locale */
    @Suppress("DEPRECATION")
    private fun currentLanguageTag(): String {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            resources.configuration.locales.get(0)?.toLanguageTag() ?: "en"
        } else {
            resources.configuration.locale?.toLanguageTag() ?: "en"
        }
    }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density + 0.5f).toInt()
}
