# =====================================================================
# gen_assets.ps1  -  生成 APP 图标与三种语言的国旗图片（纯本地绘制，无需联网）
# 用法： powershell -ExecutionPolicy Bypass -File .\gen_assets.ps1
# 注意：本文件必须以 UTF-8 with BOM 保存，否则 Windows PowerShell 5.1 会乱码
# =====================================================================
Add-Type -AssemblyName System.Drawing

$here   = Split-Path -Parent $MyInvocation.MyCommand.Path
$res    = Join-Path (Split-Path -Parent $here) "app\src\main\res"
# 国旗按“语言限定符”目录存放，Android 会按手机系统语言自动选用对应的那一张
$drawEn = Join-Path $res "drawable-en"
$drawZh = Join-Path $res "drawable-zh"
$drawJa = Join-Path $res "drawable-ja"
# 注意：必须同时有一份“默认”的 drawable/flag.png（不带语言限定符），
# 否则 Android Studio 不会为 R.drawable.flag 生成引用，编译报 Unresolved reference 'flag'
$draw   = Join-Path $res "drawable"
$mipmap = Join-Path $res "mipmap-xxxhdpi"
New-Item -ItemType Directory -Force -Path $draw, $drawEn, $drawZh, $drawJa, $mipmap | Out-Null

function New-Canvas([int]$w, [int]$h, [string]$color) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([System.Drawing.ColorTranslator]::FromHtml($color))
    return @($bmp, $g)
}

# 五角星路径
function Get-StarPath([double]$cx, [double]$cy, [double]$r, [double]$rotDeg) {
    $pts = @()
    for ($i = 0; $i -lt 10; $i++) {
        if ($i % 2 -eq 0) { $rad = $r } else { $rad = $r * 0.382 }
        $a = (($rotDeg - 90 + $i * 36) * [Math]::PI) / 180.0
        $x = [float]($cx + $rad * [Math]::Cos($a))
        $y = [float]($cy + $rad * [Math]::Sin($a))
        $pts += New-Object System.Drawing.PointF($x, $y)
    }
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddPolygon($pts)
    return $p
}

# ---------------------------------------------------------------------
# 1) 中国国旗  216 x 144
# ---------------------------------------------------------------------
function Save-FlagCN([string]$path) {
    $r = New-Canvas 216 144 "#DE2910"; $bmp = $r[0]; $g = $r[1]
    $yellow = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml("#FFDE00"))
    $g.FillPath($yellow, (Get-StarPath 36 42 21 0))
    $xs = @(72, 90, 90, 72); $ys = @(12, 27, 57, 72)
    for ($i = 0; $i -lt 4; $i++) {
        $ang = [Math]::Atan2(42 - $ys[$i], 36 - $xs[$i]) * 180.0 / [Math]::PI + 90
        $g.FillPath($yellow, (Get-StarPath $xs[$i] $ys[$i] 8 $ang))
    }
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    Write-Host "OK  $path"
}

# ---------------------------------------------------------------------
# 2) 英国国旗（English）  216 x 144
# ---------------------------------------------------------------------
function Save-FlagGB([string]$path) {
    $r = New-Canvas 216 144 "#012169"; $bmp = $r[0]; $g = $r[1]
    $white = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 30
    $red   = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml("#C8102E")), 10
    # 米字旗的对角线
    $g.DrawLine($white, 0, 0, 216, 144); $g.DrawLine($white, 216, 0, 0, 144)
    $g.DrawLine($red, 0, 0, 216, 144);   $g.DrawLine($red, 216, 0, 0, 144)
    # 白色正十字
    $wPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 48
    $g.DrawLine($wPen, 108, 0, 108, 144)
    $g.DrawLine($wPen, 0, 72, 216, 72)
    # 红色正十字
    $rPen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml("#C8102E")), 28
    $g.DrawLine($rPen, 108, 0, 108, 144)
    $g.DrawLine($rPen, 0, 72, 216, 72)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    Write-Host "OK  $path"
}

# ---------------------------------------------------------------------
# 3) 日本国旗  216 x 144
# ---------------------------------------------------------------------
function Save-FlagJP([string]$path) {
    $r = New-Canvas 216 144 "#FFFFFF"; $bmp = $r[0]; $g = $r[1]
    $red = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml("#BC002D"))
    $g.FillEllipse($red, 108 - 43, 72 - 43, 86, 86)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    Write-Host "OK  $path"
}

# ---------------------------------------------------------------------
# 4) APP 图标前景（金色字母 H）  432 x 432
# ---------------------------------------------------------------------
function Save-IconForeground([string]$path) {
    $bmp = New-Object System.Drawing.Bitmap(432, 432)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    $font  = New-Object System.Drawing.Font("Arial", 170, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml("#FFDE00"))
    $fmt   = New-Object System.Drawing.StringFormat
    $fmt.Alignment     = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect  = New-Object System.Drawing.RectangleF(0, 0, 432, 432)
    $g.DrawString("H", $font, $brush, $rect, $fmt)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    Write-Host "OK  $path"
}

# 三张国旗分别放进对应语言限定符目录，文件名统一叫 flag.png
Save-FlagCN (Join-Path $drawZh "flag.png")
Save-FlagGB (Join-Path $drawEn "flag.png")
Save-FlagJP (Join-Path $drawJa "flag.png")
# 默认目录也必须有一份（未适配的语言显示它），否则 R.drawable.flag 不会生成
Save-FlagGB (Join-Path $draw "flag.png")
Save-IconForeground (Join-Path $mipmap "ic_launcher_foreground.png")

# 同时导出一份到 tools/preview 方便人眼查看（预览文件名带语言后缀，只是便于分辨）
$preview = Join-Path $here "preview"
New-Item -ItemType Directory -Force -Path $preview | Out-Null
Copy-Item (Join-Path $drawZh "flag.png") (Join-Path $preview "flag_cn.png") -Force
Copy-Item (Join-Path $drawEn "flag.png") (Join-Path $preview "flag_gb.png") -Force
Copy-Item (Join-Path $drawJa "flag.png") (Join-Path $preview "flag_jp.png") -Force
Copy-Item (Join-Path $mipmap "ic_launcher_foreground.png") $preview -Force
Write-Host "ALL DONE"
