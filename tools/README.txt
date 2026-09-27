# 本目录存放不需要 Android 编译的生成脚本与预览图
#
# gen_assets.ps1 会生成并复制到 res/ 下面（国旗按“语言限定符”目录存放，文件名统一叫 flag.png）：
#   res/drawable-en/flag.png  英国国旗（系统语言为英语时显示）
#   res/drawable-zh/flag.png  中国国旗（系统语言为中文时显示）
#   res/drawable-ja/flag.png  日本国旗（系统语言为日语时显示）
#   res/mipmap-xxxhdpi/ic_launcher_foreground.png   APP 图标前景（金色 H）
#
# 重新生成（例如想再加一种语言）。注意：必须在 Windows PowerShell 下执行，
# 而且本脚本保存为 UTF-8 with BOM 才能让中文注释不乱码：
#   powershell -ExecutionPolicy Bypass -File .\gen_assets.ps1
#
# preview/ 里是给人看的预览图，文件名带语言后缀只是为了容易分辨，
# 跟 Android 资源名无关（资源名统一是 flag）。
