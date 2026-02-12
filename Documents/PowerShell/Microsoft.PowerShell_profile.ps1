# -----------------------------
# Editors
# -----------------------------
$env:EDITOR = "nvim"
$env:CVSEDITOR = $env:EDITOR
$env:SVN_EDITOR = $env:EDITOR
$env:GIT_EDITOR = $env:EDITOR

# -----------------------------
# XDG Base Directory
# -----------------------------
$env:XDG_CACHE_HOME = if ($env:XDG_CACHE_HOME) { $env:XDG_CACHE_HOME } else { (Join-Path $HOME ".cache") }
$env:XDG_CONFIG_HOME = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { (Join-Path $HOME ".config") }
$env:XDG_DATA_HOME = if ($env:XDG_DATA_HOME) { $env:XDG_DATA_HOME } else { (Join-Path $HOME ".local/share") }
$env:XDG_STATE_HOME = if ($env:XDG_STATE_HOME) { $env:XDG_STATE_HOME } else { (Join-Path $HOME ".local/state") }

# -----------------------------
# yazi environment
# -----------------------------
$env:YAZI_FILE_ONE = Join-Path $HOME "scoop/apps/git/current/usr/bin/file.exe"
$env:YAZI_CONFIG_HOME = Join-Path $HOME ".config/yazi"

# -----------------------------
# PSReadLine options (history / completion)
# -----------------------------
if (Get-Module -ListAvailable -Name PSReadLine) {
  Set-PSReadLineOption -HistoryNoDuplicates
  Set-PSReadLineOption -BellStyle None
  try {
    Set-PSReadLineOption -PredictionSource History
  } catch {
    # Ignore when the installed PSReadLine does not support prediction.
  }
}

# -----------------------------
# Built-in aliases
# Keep only aliases that are useful for zsh-like operation.
# -----------------------------
$keepAliases = @(
  "cat",
  "cd",
  "cls",
  "cp",
  "dir",
  "echo",
  "ls",
  "man",
  "mv",
  "pwd",
  "rm",
  "sleep",
  "sort",
  "tee"
)

Get-Alias | ForEach-Object {
  if ($keepAliases -contains $_.Name) {
    return
  }

  if ($_.Options -match "Constant") {
    return
  }

  Remove-Item -LiteralPath ("Alias:" + $_.Name) -Force -ErrorAction SilentlyContinue
}

# -----------------------------
# Tool activation (mise)
# -----------------------------
if (Get-Command mise -ErrorAction SilentlyContinue) {
  # Apply mise-managed PATH/env settings to this pwsh session.
  (& mise activate pwsh) | Out-String | Invoke-Expression
}

# -----------------------------
# Prompt (starship)
# -----------------------------
$starship = Get-Command -Name starship -CommandType Application -ErrorAction SilentlyContinue
if ($starship) {
  # Initialize starship prompt only when executable is available.
  Invoke-Expression (& $starship.Source init powershell)
}

# -----------------------------
# Aliases / wrappers
# -----------------------------
if (Get-Command eza -ErrorAction SilentlyContinue) {
  function ls {
    eza --icons --git @args
  }

  function la {
    eza --icons --git -la @args
  }
}

function reload {
  . $PROFILE
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
  Set-Alias -Name vi -Value nvim
  Set-Alias -Name vim -Value nvim
}

# -----------------------------
# yazi wrapper
# -----------------------------
if (Get-Command yazi -ErrorAction SilentlyContinue) {
  function y {
    param(
      [Parameter(ValueFromRemainingArguments = $true)]
      [string[]]$YaziArgs
    )

    $tmp = [System.IO.Path]::GetTempFileName()
    try {
      & yazi @YaziArgs --cwd-file="$tmp"
      if (Test-Path -LiteralPath $tmp) {
        $cwd = (Get-Content -Raw -LiteralPath $tmp).Trim()
        if ($cwd -and $cwd -ne (Get-Location).Path) {
          Set-Location -LiteralPath $cwd
        }
      }
    } finally {
      Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
    }
  }
}

# -----------------------------
# ghq + fzf
# -----------------------------
if ((Get-Command ghq -ErrorAction SilentlyContinue) -and (Get-Command fzf -ErrorAction SilentlyContinue)) {
  function ghq-fzf {
    $root = ghq root
    if (-not $root) {
      return
    }

    $src = ghq list | fzf
    if ($src) {
      Set-Location -LiteralPath (Join-Path $root $src)
    }
  }

  # Ctrl+g runs ghq-fzf via PSReadLine key binding.
  if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineKeyHandler -Chord Ctrl+g -ScriptBlock {
      ghq-fzf
      [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
  }
}
