@echo off
chcp 65001 >nul
rem =====================================================================
rem  push_to_gitee.bat  -  把本工程推送到你自己的 Gitee 仓库
rem  用法： 先新建一个空仓库，然后执行
rem         push_to_gitee.bat https://gitee.com/你的用户名/仓库名.git
rem =====================================================================
setlocal
if "%~1"=="" (
    echo 用法: push_to_gitee.bat https://gitee.com/你的用户名/仓库名.git
    exit /b 1
)

if not exist ".git" (
    echo [1/4] 初始化本地仓库...
    git init
) else (
    echo [1/4] 本地仓库已存在，跳过 init
)

echo [2/4] 添加文件并提交...
git add .
git commit -m "Android 实验：跟随系统语言的多语言 Hello World（纯代码界面）"
if errorlevel 1 echo     （没有新改动可提交，继续）

echo [3/4] 设置远程仓库...
git remote remove origin 2>nul
git remote add origin %~1
git branch -M main

echo [4/4] 推送到 Gitee（提示输入密码时请填“私人令牌”）...
git push -u origin main

echo.
echo 完成。仓库地址：%~1
endlocal
