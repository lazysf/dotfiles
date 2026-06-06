# Windows 環境セットアップ: winget で winget-packages.json のパッケージを一括導入する。
# 実行: scripts/setup.ps1 （chezmoi 配布対象外。手動で叩く）
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# winget が未導入ならエラーにして導線を案内する。
# winget (App Installer) は Windows 10/11 に標準同梱だが、無い環境では自動導入が脆いため手動導入を促す。
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error 'winget が見つかりません。Microsoft Store の "App Installer" を導入してください: https://aka.ms/getwinget'
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ImportFile = Join-Path $ScriptDir 'winget-packages.json'

# winget-packages.json のパッケージを適用する。
Write-Host "==> winget パッケージを導入します: $ImportFile"
winget import --import-file $ImportFile --accept-package-agreements --accept-source-agreements
# $ErrorActionPreference='Stop' は native command (winget.exe) の非ゼロ exit を例外化しないため、明示確認する。
if ($LASTEXITCODE -ne 0) {
    Write-Warning "winget import が exit code $LASTEXITCODE で終了しました (既導入パッケージ等で正常な場合もあります)"
}

Write-Host '==> 完了しました'
