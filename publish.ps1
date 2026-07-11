$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (git status --porcelain)) {
    Read-Host "没有检测到任何改动，回车退出"
    exit 0
}

git add -A
git commit -m ("更新 " + (Get-Date -Format "yyyy-MM-dd HH:mm"))
git push

Write-Host ""
Write-Host "推送完成。GitHub 正在自动构建，约 1-2 分钟后生效："
Write-Host "https://abilatte.github.io"
Read-Host "回车关闭"
