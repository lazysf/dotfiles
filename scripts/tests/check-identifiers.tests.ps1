#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
$scriptPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../check-identifiers.ps1'))
$root = Join-Path ([IO.Path]::GetTempPath()) ('identifier-tests-' + [guid]::NewGuid().ToString('N'))
$original = Get-Location
$count = 0
function Git {
    & git.exe @args 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'fixture git failed' }
}
function Probe([int]$expected, [string]$kind = '') {
    $output = & pwsh -NoProfile -NonInteractive -File $scriptPath 2>&1
    if ($LASTEXITCODE -ne $expected) { throw "unexpected exit in case $count" }
    $text = $output -join "`n"
    if ($kind -and $text -notmatch "${kind}: ") { throw "missing kind in case $count" }
    foreach ($value in @($HOME, $env:USER, $env:USERNAME, [Environment]::MachineName)) {
        if ($value -and $text.Contains($value, [StringComparison]::OrdinalIgnoreCase)) { throw "identity leaked in case $count" }
    }
    $script:count++
}
function Stage([string]$value, [string]$path = 'probe.txt') {
    [IO.File]::WriteAllText((Join-Path $PWD $path), $value)
    Git --literal-pathspecs add -- $path
}
try {
    $null = New-Item -ItemType Directory -Path $root
    Set-Location $root
    Probe 1
    Git init --quiet
    Probe 0
    Stage 'ordinary synthetic text'
    Probe 0
    [IO.File]::WriteAllText((Join-Path $PWD 'probe.txt'), $HOME)
    Probe 0
    foreach ($value in @($HOME, $HOME.Replace('\', '/'))) { Stage $value; Probe 1 home }
    $userValue = if ($env:USER) { $env:USER } else { $env:USERNAME }
    $hostValue = [Environment]::MachineName.Split('.')[0]
    foreach ($pair in @(@($userValue, 'user'), @($hostValue, 'host'))) {
        Stage $pair[0]; Probe 1 $pair[1]
        Stage $pair[0].ToUpperInvariant(); Probe 1 $pair[1]
        Stage $pair[0].ToLowerInvariant(); Probe 1 $pair[1]
        Stage ('prefix' + $pair[0] + 'suffix'); Probe 0
    }
    Stage $HOME
    [IO.File]::WriteAllText((Join-Path $PWD 'probe.txt'), 'ordinary synthetic text')
    Probe 1 home
    Stage 'ordinary synthetic text'
    foreach ($path in @('日本語 space.txt', '[probe].txt')) {
        Stage $HOME $path
        Probe 1 home
        Git --literal-pathspecs rm --cached --quiet -- $path
    }
    Stage '' ($userValue + '.txt')
    Probe 1 user
    Git --literal-pathspecs rm --cached --quiet -- ($userValue + '.txt')
    foreach ($path in @(($userValue + '_backup.txt'), ($hostValue + '_backup.txt'))) {
        Stage $HOME $path
        Probe 1 home
        Git --literal-pathspecs rm --cached --quiet -- $path
    }
    # 不正な UTF-8 があっても、正常・識別子ありを区別する。
    foreach ($encoding in @([Text.Encoding]::UTF8, [Text.Encoding]::Unicode, [Text.Encoding]::BigEndianUnicode)) {
        foreach ($value in @('ordinary synthetic text', $HOME, $userValue, $hostValue)) {
            # user/host は単語として照合するので、バイナリの前後にも文字列の区切りを置く。
            $bytes = [byte[]]@(0xff, 0xfe, 0x80) + $encoding.GetBytes(' ' + $value + ' ')
            [IO.File]::WriteAllBytes((Join-Path $root 'probe.bin'), $bytes)
            Git add -- probe.bin
            if ($value -eq 'ordinary synthetic text') { Probe 0 } else { Probe 1 }
        }
    }
    Git rm --cached --quiet -- probe.bin
    # 永続設定は変えず、設定が path の検査を省略させないことを確かめる。
    $savedConfig = @($env:GIT_CONFIG_COUNT, $env:GIT_CONFIG_KEY_0, $env:GIT_CONFIG_VALUE_0)
    try {
        $env:GIT_CONFIG_COUNT = '1'
        $env:GIT_CONFIG_KEY_0 = 'diff.ignoreSubmodules'
        $env:GIT_CONFIG_VALUE_0 = 'all'
        Git update-index --add --cacheinfo ('160000,0123456789012345678901234567890123456789,' + $userValue)
        Probe 1 user
        Git --literal-pathspecs rm --cached --quiet -- $userValue
        Git update-index --add --cacheinfo '160000,0123456789012345678901234567890123456789,ordinary-submodule'
        Probe 0
        Git rm --cached --quiet -- ordinary-submodule
    } finally {
        $env:GIT_CONFIG_COUNT, $env:GIT_CONFIG_KEY_0, $env:GIT_CONFIG_VALUE_0 = $savedConfig
    }
    . (Join-Path $PSScriptRoot '../identifier-patch.ps1')
    . (Join-Path $PSScriptRoot '../identifier-runner.ps1')
    $oldUser = $env:USER
    try {
        $env:USER = '上田'
        foreach ($encoding in @([Text.Encoding]::Unicode, [Text.Encoding]::BigEndianUnicode)) {
            foreach ($offset in @(0, 1)) {
                foreach ($newline in @('', "`n")) {
                    $payload = $encoding.GetBytes(' ' + $env:USER + ' ' + $newline)
                    if ($offset) { $payload = [byte[]]@(0x80) + $payload }
                    [IO.File]::WriteAllBytes((Join-Path $root 'unicode.txt'), $payload)
                    Git add -- unicode.txt
                    Probe 1 user
                }
            }
        }
        Git rm --cached --quiet -- unicode.txt
    } finally { $env:USER = $oldUser }
    $patch = "diff --git a/probe b/probe`n@@ -1,2 +1,2 @@`n-old`n+first`n-old2`n+second`n\ No newline at end of file`n"
    $segments = @(Get-IdentifierAddedSegments $patch)
    if ($segments.Count -ne 2 -or $segments[0] -cne "first`n" -or $segments[1] -cne 'second') { throw 'patch reconstruction failed' }
    $count++
    $bad = $false
    try { $null = Get-IdentifierAddedSegments "@@ -0,0 +1,2 @@`n+short`n" } catch { $bad = $true }
    if (-not $bad) { throw 'malformed patch accepted' }
    $count++
    $result = Invoke-IdentifierProcess -Executable (Join-Path $PSHOME 'pwsh.exe') -Arguments @('-NoProfile', '-NonInteractive', '-Command', '[Console]::Out.Write((''o'' * 200000)); [Console]::Error.Write((''e'' * 200000))') -WorkingDirectory $root
    if ($result.Length -ne 200000) { throw 'large output lost' }
    $count++
    foreach ($request in @(
        @{ Executable = (Join-Path $PSHOME 'pwsh.exe'); Arguments = @('-NoProfile', '-Command', 'exit 7') },
        @{ Executable = (Join-Path $root 'missing.exe'); Arguments = @() }
    )) {
        $failed = $false
        try { $null = Invoke-IdentifierProcess @request -WorkingDirectory $root } catch { $failed = $true }
        if (-not $failed) { throw 'process failure ignored' }
        $count++
    }
    $env:IDENTIFIER_TEST_ROOT = $root
    $grandchild = '[IO.File]::AppendAllText((Join-Path $env:IDENTIFIER_TEST_ROOT "pids.txt"), "$PID`n"); Start-Sleep -Seconds 30'
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($grandchild))
    $child = '$p = [Diagnostics.Process]::new(); $p.StartInfo.FileName = Join-Path $PSHOME "pwsh.exe"; $p.StartInfo.UseShellExecute = $false; foreach($a in @("-NoProfile", "-EncodedCommand", "' + $encoded + '")){ $p.StartInfo.ArgumentList.Add($a) }; $null = $p.Start(); [IO.File]::AppendAllText((Join-Path $env:IDENTIFIER_TEST_ROOT "pids.txt"), "$PID`n"); Start-Sleep -Seconds 30'
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($child))
    $parent = '$p = [Diagnostics.Process]::new(); $p.StartInfo.FileName = Join-Path $PSHOME "pwsh.exe"; $p.StartInfo.UseShellExecute = $false; foreach($a in @("-NoProfile", "-EncodedCommand", "' + $encoded + '")){ $p.StartInfo.ArgumentList.Add($a) }; $null = $p.Start()'
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $failed = $false
    try { $null = Invoke-IdentifierProcess -Executable (Join-Path $PSHOME 'pwsh.exe') -Arguments @('-NoProfile', '-Command', $parent) -WorkingDirectory $root -TimeoutMilliseconds 4000 } catch { $failed = $true }
    if (-not $failed -or $timer.Elapsed.TotalSeconds -ge 10) { throw 'pipe timeout failed' }
    $pids = @(Get-Content -LiteralPath (Join-Path $root 'pids.txt'))
    if ($pids.Count -ne 2) { throw 'descendant fixture failed' }
    foreach ($processId in $pids) { if (Get-Process -Id ([int]$processId) -ErrorAction SilentlyContinue) { throw 'descendant survived' } }
    $count++
    foreach ($encoding in @([Text.Encoding]::Unicode, [Text.Encoding]::BigEndianUnicode)) {
        foreach ($bom in @($false, $true)) {
            $bytes = $encoding.GetBytes(' 上田 ')
            if ($bom) { $bytes = $encoding.GetPreamble() + $bytes }
            $raw = [Text.Encoding]::Latin1.GetString($bytes)
            $lines = $raw.Split("`n")
            $patch = "@@ -0,0 +1,$($lines.Count) @@`n" + (($lines | ForEach-Object { '+' + $_ }) -join "`n") + "`n\ No newline at end of file`n"
            $segments = @(Get-IdentifierAddedSegments $patch)
            if ($segments.Count -ne 1 -or $segments[0] -cne $raw) { throw 'BOM byte reconstruction failed' }
            $count++
        }
    }
    $worker = [Diagnostics.Process]::new()
    $worker.StartInfo.FileName = Join-Path $PSHOME 'pwsh.exe'
    $worker.StartInfo.UseShellExecute = $false
    $worker.StartInfo.RedirectStandardInput = $true
    foreach ($a in @('-NoProfile', '-NonInteractive', '-File', (Join-Path $PSScriptRoot '../identifier-worker.ps1'))) { $worker.StartInfo.ArgumentList.Add($a) }
    try {
        $null = $worker.Start()
        $worker.StandardInput.Close()
        if (-not $worker.WaitForExit(5000) -or $worker.ExitCode -eq 0) { throw 'worker EOF accepted' }
        $job = [IdentifierCheck.ProcessJob]::new()
        $job.Dispose()
        $failed = $false
        try { $job.Assign($worker) } catch { $failed = $true }
        if (-not $failed) { throw 'invalid job assignment accepted' }
        $count += 2
    } finally {
        if (-not $worker.HasExited) { $worker.Kill($true) }
        $worker.Dispose()
    }
    Write-Output "PASS: $count cases"
} finally {
    Set-Location $original
    $full = [IO.Path]::GetFullPath($root)
    if ((Split-Path -Parent $full).TrimEnd('\') -ne ([IO.Path]::GetTempPath()).TrimEnd('\') -or (Split-Path -Leaf $full) -notmatch '^identifier-tests-[a-f0-9]{32}$') { throw 'unsafe cleanup path' }
    if (Test-Path -LiteralPath $full) { Remove-Item -LiteralPath $full -Recurse -Force }
}
