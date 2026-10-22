# Windows 環境セットアップ (chezmoi 配布対象外。手動、または chezmoi apply の run_onchange_after_install-packages から実行)。
# 用途別 Install-*Stack ブロックで「何のためか」「他に何が依存か」を表す。
# 同じパッケージが複数ブロックに出てよい（既導入 skip で 2 重実行コストはほぼ無い）。
# 引数の machine profile は chezmoi の `.profile` と同じ値を取る。work では 1Password（会社管理の
# パスワード管理ツール想定）と Zotero（仕事環境では不要）を入れない。Windows の work では
# GUI ユーティリティ（Raycast）も入れない。
# profile は 引数 → chezmoi の設定ファイル → 選択 の順で決める。既定値を持たせないのは、指定漏れで
# 仕事のマシンに 1Password が入るのを防ぐため。
# 設定ファイルが無ければ選んだ profile を書いておく。chezmoi init の promptChoiceOnce がこれを見つけ、
# 同じ profile をもう一度聞かない。init は .chezmoi.toml.tmpl から設定ファイルを作り直す。
# 変数名を $Profile にしないのは、PowerShell の自動変数 $PROFILE と衝突するため。
#Requires -Version 5.1
param(
    [Parameter(Position = 0)]
    [ValidateSet('personal', 'work')]
    [string]$MachineProfile
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$chezmoiConfig = Join-Path $HOME '.config/chezmoi/chezmoi.toml'
if (-not $MachineProfile -and (Test-Path $chezmoiConfig)) {
    # .chezmoi.toml.tmpl が書く形の行だけを読む。TOML を解釈するわけではない。
    $match = Select-String -Path $chezmoiConfig -Pattern '^\s*profile = "(personal|work)"\s*$' | Select-Object -First 1
    if ($match) {
        $MachineProfile = $match.Matches[0].Groups[1].Value
    }
}
if (-not $MachineProfile) {
    if ([Console]::IsInputRedirected) {
        Write-Error 'Usage: setup.ps1 [personal|work]'
        exit 1
    }
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]@('&personal', '&work')
    $index = $Host.UI.PromptForChoice('Machine profile', 'Machine profile を選んでください', $choices, -1)
    $MachineProfile = @('personal', 'work')[$index]
}
if (-not (Test-Path $chezmoiConfig)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $chezmoiConfig) | Out-Null
    Set-Content -Path $chezmoiConfig -Encoding ascii -Value @('[data]', "  profile = `"$MachineProfile`"")
}

# winget (App Installer) は Windows 10/11 に標準同梱だが、無い環境では自動導入が脆いため手動導入を促す。
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error 'winget が見つかりません。Microsoft Store の "App Installer" を導入してください: https://aka.ms/getwinget'
    exit 1
}

# Windows PowerShell 5.1 は既定の Restricted ではプロファイルを読まない。現在のユーザーだけ RemoteSigned にする。
# 利用者や管理者が既に決めた値（CurrentUser の設定、グループポリシー、AllSigned など）は変えない。
# このスクリプトは -ExecutionPolicy Bypass で起動されるので、Process スコープを含む Get-ExecutionPolicy では判定できない。
$policyUnset = (Get-ExecutionPolicy -Scope MachinePolicy) -eq 'Undefined' -and
    (Get-ExecutionPolicy -Scope UserPolicy) -eq 'Undefined' -and
    (Get-ExecutionPolicy -Scope CurrentUser) -eq 'Undefined' -and
    (Get-ExecutionPolicy -Scope LocalMachine) -in @('Restricted', 'Undefined')
if ($policyUnset) {
    Write-Host '==> 現在のユーザーの実行ポリシーを RemoteSigned にします'
    try {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    } catch {
        # グループポリシーが上書きしている時は、設定は保存されても効かず、エラーになる。
        Write-Warning "実行ポリシーを変更できませんでした: $($_.Exception.Message)"
    }
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
        return
    }
    # 同じ ID が後の stack にも出るので、照会結果へ足して 2 回目を skip させる。
    # 足さないと winget が既導入として非ゼロ exit を返し、上の警告が出る。
    $script:installedList += "`n$Id"
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

# winget で入れたコマンドは、この session の PATH に入らない。レジストリから読み直して op を見つける。
function Update-SessionPath {
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
}

# CLI 連携が有効なら、op はアプリでサインインしているアカウントを返す。
function Test-OnePasswordCli {
    # PowerShell 5.1 は native command の stderr を ErrorRecord にし、Stop の下では例外にするため緩める。
    $ErrorActionPreference = 'Continue'
    if (-not (Get-Command op -ErrorAction SilentlyContinue)) {
        return $false
    }
    $json = (op account list --format=json 2>$null | Out-String)
    if ($LASTEXITCODE -ne 0 -or -not $json.Trim()) {
        return $false
    }
    # パイプで渡すと 5.1 は配列を 1 つのまとまりとして返し、空でも 1 件に数えるため -InputObject で渡す。
    $accounts = ConvertFrom-Json -InputObject $json
    return (@($accounts).Count -gt 0)
}

# 0 だけを設定済みとみなす。Windows の OpenSSH Authentication Agent が鍵の無い状態で答えると 1 になる。
function Test-OnePasswordAgent {
    $ErrorActionPreference = 'Continue'
    if (-not (Get-Command ssh-add -ErrorAction SilentlyContinue)) {
        return $false
    }
    ssh-add -l *> $null
    return ($LASTEXITCODE -eq 0)
}

# CLI 連携と SSH agent は 1Password のアプリの設定画面でしか有効にできないため、画面を開いて待つ。
# chezmoi apply から実行された時 (CHEZMOI=1) は、利用者が画面の前にいるとは限らないので待たない。
function Wait-OnePassword {
    if ($env:CHEZMOI -eq '1') {
        return
    }
    $opened = $false
    while ($true) {
        Update-SessionPath
        $missing = @()
        if (-not (Test-OnePasswordCli)) { $missing += 'CLI 連携' }
        if (-not (Test-OnePasswordAgent)) { $missing += 'SSH agent' }
        if ($missing.Count -eq 0) {
            Write-Host '  1Password は設定済みです'
            return
        }
        if ([Console]::IsInputRedirected) {
            Write-Warning "1Password の設定が済んでいません: $($missing -join ', ')"
            return
        }
        if (-not $opened) {
            try {
                Start-Process 'onepassword://settings/developers'
            } catch {
                Write-Warning '1Password の設定画面を開けませんでした。アプリから Settings > Developer を開いてください'
            }
            $opened = $true
            Write-Host '  1Password で次を設定してください'
            Write-Host '    - アカウントにサインインする'
            Write-Host '    - Security: Windows Hello を有効にする'
            Write-Host '    - Windows のサービス OpenSSH Authentication Agent が動いていれば止める'
            Write-Host '    - Developer: Integrate with 1Password CLI'
            Write-Host '    - Developer: Use the SSH Agent'
            Write-Host '    - General: Keep 1Password in the notification area'
        }
        Write-Host "  未設定: $($missing -join ', ')"
        Read-Host '  設定したら Enter を押してください (中断は Ctrl+C)' | Out-Null
    }
}

function Install-AiStack {
    Write-Host '==> AI ツール (デスクトップ)'
    Install-WingetPackage Anthropic.Claude
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
    Wait-OnePassword
}
Install-AiStack
Install-FontStack
if ($MachineProfile -eq 'personal') {
    Install-GuiUtilityStack
}
Install-EditorGuiStack
if ($MachineProfile -eq 'personal') {
    Install-ResearchStack
}

Write-Host '==> 完了しました'
