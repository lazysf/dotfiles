# Windows 環境セットアップ (chezmoi 配布対象外。手動、または chezmoi apply の run_onchange_after_install-packages から実行)。
# 用途別 Install-*Stack ブロックで「何のためか」「他に何が依存か」を表す。
# 同じパッケージが複数ブロックに出てよい（既導入 skip で 2 重実行コストはほぼ無い）。
# 引数の machine profile は chezmoi の `.profile` と同じ値を取る。work では 1Password（会社管理の
# パスワード管理ツール想定）と Zotero（仕事環境では不要）を入れない。
# 既定値を持たせないのは、指定漏れで仕事のマシンに 1Password が入るのを防ぐため。
# 変数名を $Profile にしないのは、PowerShell の自動変数 $PROFILE と衝突するため。
#Requires -Version 5.1
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('personal', 'work')]
    [string]$MachineProfile
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# winget (App Installer) は Windows 10/11 に標準同梱だが、無い環境では自動導入が脆いため手動導入を促す。
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error 'winget が見つかりません。Microsoft Store の "App Installer" を導入してください: https://aka.ms/getwinget'
    exit 1
}

# winget list は ID も列に出るので部分文字列マッチで skip 判定する。
# 表形式が改行で折れる可能性に備え Out-String で 1 文字列に潰す。
Write-Host '==> 既導入パッケージを照会します'
$installedList = (winget list --accept-source-agreements 2>$null | Out-String)

function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)][string]$Id
    )
    if ($installedList -match [regex]::Escape($Id)) {
        Write-Host "  - $Id (skip)"
        return
    }
    Write-Host "  + $Id"
    winget install --id $Id --source winget --exact --accept-package-agreements --accept-source-agreements --silent
    # $ErrorActionPreference='Stop' は native command (winget.exe) の非ゼロ exit を例外化しないため、明示確認する。
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "    winget install '$Id' が exit code $LASTEXITCODE で終了しました"
    }
}

function Install-ShellStack {
    Write-Host '==> shell (プロンプト)'
    Install-WingetPackage Starship.Starship
}

function Install-ModernCliStack {
    Write-Host '==> modern CLI utilities (汎用)'
    Install-WingetPackage sharkdp.bat              # cat 代替
    Install-WingetPackage eza-community.eza        # ls 代替
    Install-WingetPackage junegunn.fzf             # 汎用ファジー検索 (PowerShell g() / fzf-lua)
    Install-WingetPackage BurntSushi.ripgrep.MSVC  # 高速 grep
    Install-WingetPackage sharkdp.fd               # 高速 find
    Install-WingetPackage jqlang.jq                # JSON parser
    Install-WingetPackage ajeetdsouza.zoxide       # cd 代替 (z コマンド)
}

function Install-GitStack {
    Write-Host '==> git workflow'
    Install-WingetPackage Git.Git
    Install-WingetPackage GitHub.cli
    Install-WingetPackage x-motemen.ghq
    Install-WingetPackage JesseDuffield.lazygit
    Install-WingetPackage j178.Prek      # pre-commit 互換 hook ランナー (Rust 製)
    Install-WingetPackage junegunn.fzf   # PowerShell profile の g() 関数 (ghq + fzf) で使用
}

function Install-NeovimStack {
    Write-Host '==> neovim (純粋テキストエディタ運用)'
    Install-WingetPackage Neovim.Neovim
    Install-WingetPackage tree-sitter.tree-sitter-cli   # nvim-treesitter main branch の parser ビルダ
}

function Install-YaziStack {
    Write-Host '==> yazi (terminal file manager) + プレビュー依存'
    Install-WingetPackage sxyazi.yazi
    Install-WingetPackage Gyan.FFmpeg                # 動画プレビュー
    Install-WingetPackage ImageMagick.ImageMagick    # 画像プレビュー
    Install-WingetPackage oschwartz10612.Poppler     # PDF プレビュー
    Install-WingetPackage 7zip.7zip                  # アーカイブプレビュー
    Install-WingetPackage jqlang.jq                  # 構造化データプレビュー
    Install-WingetPackage sharkdp.fd                 # ファイル検索連携
    Install-WingetPackage BurntSushi.ripgrep.MSVC    # grep 連携
    Install-WingetPackage junegunn.fzf               # ファジー連携
    Install-WingetPackage ajeetdsouza.zoxide         # cd 履歴連携
    Install-WingetPackage Git.Git                    # YAZI_FILE_ONE = Git 同梱の file.exe (PowerShell profile)
}

function Install-LanguageRuntimesStack {
    Write-Host '==> 言語ランタイム/版管理'
    Install-WingetPackage CoreyButler.NVMforWindows    # Node.js
    Install-WingetPackage astral-sh.uv  # Python
}

function Install-DotfilesStack {
    Write-Host '==> dotfiles'
    Install-WingetPackage twpayne.chezmoi
}

function Install-PasswordStack {
    Write-Host '==> パスワード管理'
    Install-WingetPackage AgileBits.1Password
    Install-WingetPackage AgileBits.1Password.CLI
}

function Install-AiStack {
    Write-Host '==> AI ツール (CLI + デスクトップ)'
    Install-WingetPackage Anthropic.Claude
    Install-WingetPackage Anthropic.ClaudeCode
    # ChatGPT デスクトップは Microsoft Store 経由で入手可能だが現状未採用。
}

function Install-FontStack {
    Write-Host '==> フォント (Nerd Font)'
    Install-WingetPackage DEVCOM.JetBrainsMonoNerdFont
    # font-symbols-only-nerd-font は winget manifest 無し。
}

function Install-GuiUtilityStack {
    Write-Host '==> GUI ユーティリティ'
    Install-WingetPackage Raycast.Raycast   # ランチャー
    # mos (macOS 専用) は Windows 非対応。
}

function Install-EditorGuiStack {
    Write-Host '==> エディタ (GUI)'
    Install-WingetPackage Microsoft.VisualStudioCode
}

function Install-ResearchStack {
    Write-Host '==> 研究 / 文献管理'
    Install-WingetPackage DigitalScholar.Zotero
}

Install-ShellStack
Install-ModernCliStack
Install-GitStack
Install-NeovimStack
Install-YaziStack
Install-LanguageRuntimesStack
Install-DotfilesStack
if ($MachineProfile -eq 'personal') {
    Install-PasswordStack
}
Install-AiStack
Install-FontStack
Install-GuiUtilityStack
Install-EditorGuiStack
if ($MachineProfile -eq 'personal') {
    Install-ResearchStack
}

Write-Host '==> 完了しました'
