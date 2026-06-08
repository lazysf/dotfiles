# Windows 環境セットアップ (仕事用、chezmoi 配布対象外、手動実行)。
# 構造は scripts/windows_personal/setup.ps1 と揃え、仕事環境で不要なブロックを落としている。
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error 'winget が見つかりません。Microsoft Store の "App Installer" を導入してください: https://aka.ms/getwinget'
    exit 1
}

Write-Host '==> 既導入パッケージを照会します'
$installedList = (winget list --accept-source-agreements 2>$null | Out-String)

function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [ValidateSet('winget', 'msstore')][string]$Source = 'winget'
    )
    if ($installedList -match [regex]::Escape($Id)) {
        Write-Host "  - $Id (skip)"
        return
    }
    Write-Host "  + $Id ($Source)"
    if ($Source -eq 'msstore') {
        # msstore source は PackageIdentifier ではなく query 指定が公式慣習 (`winget install Codex -s msstore`)。
        winget install $Id --source msstore --exact --accept-package-agreements --accept-source-agreements --silent
    } else {
        winget install --id $Id --source winget --exact --accept-package-agreements --accept-source-agreements --silent
    }
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
    Install-WingetPackage sharkdp.bat        # cat 代替
    Install-WingetPackage eza-community.eza  # ls 代替
}

function Install-GitStack {
    Write-Host '==> git workflow'
    Install-WingetPackage Git.Git
    Install-WingetPackage GitHub.cli
    Install-WingetPackage x-motemen.ghq
    Install-WingetPackage JesseDuffield.lazygit
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
    Install-WingetPackage Schniz.fnm    # Node.js
    Install-WingetPackage astral-sh.uv  # Python
}

function Install-DotfilesStack {
    Write-Host '==> dotfiles / pre-commit 系'
    Install-WingetPackage twpayne.chezmoi
    Install-WingetPackage j178.Prek   # pre-commit 互換 hook ランナー (Rust 製)
}

function Install-AiStack {
    Write-Host '==> AI ツール (CLI + デスクトップ)'
    Install-WingetPackage Anthropic.Claude
    Install-WingetPackage Anthropic.ClaudeCode
    Install-WingetPackage OpenAI.Codex
    Install-WingetPackage -Id Codex -Source msstore   # winget 公式 ID 無し、Microsoft Store 経由
    # ChatGPT デスクトップも msstore 経由 (`-Id ChatGPT -Source msstore`) で入手可能だが現状未採用。
}

function Install-FontStack {
    Write-Host '==> フォント (Nerd Font)'
    Install-WingetPackage DEVCOM.JetBrainsMonoNerdFont
    # font-symbols-only-nerd-font は winget manifest 無し。
}

function Install-GuiUtilityStack {
    Write-Host '==> GUI ユーティリティ'
    Install-WingetPackage Raycast.Raycast   # ランチャー
    # Microsoft Edge は Windows 10/11 標準同梱のため明示インストール不要。
    # mos (macOS 専用) は Windows 非対応。
}

function Install-EditorGuiStack {
    Write-Host '==> エディタ (GUI)'
    Install-WingetPackage Microsoft.VisualStudioCode
}

# 仕事用には含めないブロック (個人用 setup.ps1 にある):
#   - Install-PasswordStack (1Password): 会社管理のパスワード管理ツール想定
#   - Install-ResearchStack (Zotero): 仕事環境では不要

Install-ShellStack
Install-ModernCliStack
Install-GitStack
Install-NeovimStack
Install-YaziStack
Install-LanguageRuntimesStack
Install-DotfilesStack
Install-AiStack
Install-FontStack
Install-GuiUtilityStack
Install-EditorGuiStack

Write-Host '==> 完了しました'
