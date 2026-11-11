#Requires -Version 7.0
# Windows では Git 同梱の sh を起動できない sandbox があるため、Git 以外は .NET で処理する。
$ErrorActionPreference = 'Stop'

function Invoke-GitDiff {
    param([string[]]$DiffArguments, [Text.Encoding]$OutputEncoding = [Text.UTF8Encoding]::new($false, $true))
    $arguments = @('--literal-pathspecs', 'diff', '--cached', '--no-relative', '--no-renames', '--diff-filter=d', '--ignore-submodules=none', '--no-ext-diff', '--no-textconv', '--no-color') + $DiffArguments
    $bytes = Invoke-IdentifierProcess -Executable $script:identifierGit -Arguments $arguments -WorkingDirectory $PWD.ProviderPath
    return $OutputEncoding.GetString($bytes)
}

try {
    . (Join-Path $PSScriptRoot 'identifier-runner.ps1')
    . (Join-Path $PSScriptRoot 'identifier-patch.ps1')
    $script:identifierGit = (Get-Command git.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $userValue = if ($env:USER) { $env:USER } else { $env:USERNAME }
    $hostValue = [Environment]::MachineName.Split('.')[0]
    if (-not $HOME -or -not $userValue -or -not $hostValue) { throw 'identity unavailable' }
    $homeValue = $HOME.TrimEnd('/', '\')
    $patterns = [ordered]@{
        home = '(?i:' + [regex]::Escape($homeValue).Replace('\\', '[\\/]') + ')'
        user = '(?i:(?<![\p{L}\p{N}_])' + [regex]::Escape($userValue) + '(?![\p{L}\p{N}_]))'
        host = '(?i:(?<![\p{L}\p{N}_])' + [regex]::Escape($hostValue) + '(?![\p{L}\p{N}_]))'
    }
    # 検出は単語単位でも、診断では隣接文字にかかわらず値を伏せる。
    $displayPatterns = [ordered]@{
        home = $patterns.home
        user = '(?i:' + [regex]::Escape($userValue) + ')'
        host = '(?i:' + [regex]::Escape($hostValue) + ')'
    }
    $reports = [Collections.Generic.List[string]]::new()
    $contentEncodings = @([Text.Encoding]::UTF8, [Text.Encoding]::Unicode, [Text.Encoding]::BigEndianUnicode, [Text.Encoding]::Latin1)
    $names = Invoke-GitDiff @('--name-only', '-z')
    foreach ($path in $names.Split([char]0, [StringSplitOptions]::RemoveEmptyEntries)) {
        $added = [Collections.Generic.List[string]]::new()
        $added.Add($path)
        $patch = Invoke-GitDiff -DiffArguments @('-U0', '--text', '--', $path) -OutputEncoding ([Text.Encoding]::Latin1)
        foreach ($segment in @(Get-IdentifierAddedSegments $patch)) {
            $bytes = [Text.Encoding]::Latin1.GetBytes($segment)
            foreach ($encoding in $contentEncodings) {
                $added.Add($encoding.GetString($bytes))
                if ($encoding.CodePage -in @(1200, 1201) -and $bytes.Length -gt 1) {
                    $added.Add($encoding.GetString($bytes, 1, $bytes.Length - 1))
                }
            }
        }
        $text = $added -join "`n"
        $displayPath = $path
        foreach ($kind in $patterns.Keys) {
            $replacement = switch ($kind) { home { '~' } user { '<user>' } host { '<host>' } }
            $displayPath = [regex]::Replace($displayPath, $displayPatterns[$kind], $replacement)
        }
        # 制御文字を escape し、path が診断の行構造を変えないようにする。
        $displayPath = $displayPath.Replace("`r", '\r').Replace("`n", '\n').Replace("`t", '\t')
        foreach ($kind in $patterns.Keys) {
            if ([regex]::IsMatch($text, $patterns[$kind])) { $reports.Add("  ${kind}: $displayPath") }
        }
    }
    if ($reports.Count -eq 0) { exit 0 }
    [Console]::Error.WriteLine('check-identifiers: staged の path か追加行に、この作業機の識別子がある。')
    foreach ($report in $reports) { [Console]::Error.WriteLine($report) }
    [Console]::Error.WriteLine('値を ~/ や <user> のようなプレースホルダへ置き換え、stage し直してから commit する。')
    exit 1
} catch {
    # 例外と Git の生の stderr は、識別子を含むことがあるため出さない。
    [Console]::Error.WriteLine('check-identifiers: 検査できなかった（Git の失敗、timeout、識別子の取得失敗を確認する）。')
    exit 1
}
