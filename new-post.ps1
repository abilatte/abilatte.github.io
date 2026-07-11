$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$title = Read-Host "文章标题"
if ([string]::IsNullOrWhiteSpace($title)) {
    Read-Host "标题不能为空，回车退出"
    exit 1
}

$date   = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
$prefix = Get-Date -Format "yyyy-MM-dd"
$safe   = ($title -replace '[\\/:\*\?"<>\|]', '') -replace '\s+', '-'
$path   = Join-Path "content/posts" "$prefix-$safe.md"

if (Test-Path $path) {
    Read-Host "同名文章已存在，回车退出"
    exit 1
}

$front = @"
---
title: "$title"
date: $date
draft: false
tags: []
---

"@

$front | Out-File -FilePath $path -Encoding utf8
Write-Host ""
Write-Host "已创建：$path"
Write-Host "Typora 已打开，写完保存，双击「发布.bat」即可上线。"
$typora = "C:\Program Files\Typora\Typora.exe"
if (Test-Path $typora) {
    Start-Process $typora -ArgumentList "`"$path`""
} else {
    Start-Process notepad.exe -ArgumentList "`"$path`""
}
