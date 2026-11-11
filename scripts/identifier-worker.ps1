#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
try {
    # EOF では起動しない。controller が Job に所属させてから指示を送る。
    $line = [Console]::ReadLine()
    if (-not $line) { exit 1 }
    $request = $line | ConvertFrom-Json
    if (-not [IO.Path]::IsPathFullyQualified($request.Executable) -or -not [IO.Path]::IsPathFullyQualified($request.WorkingDirectory)) { exit 1 }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo.FileName = $request.Executable
    $process.StartInfo.WorkingDirectory = $request.WorkingDirectory
    $process.StartInfo.UseShellExecute = $false
    foreach ($argument in $request.Arguments) { $process.StartInfo.ArgumentList.Add([string]$argument) }
    $null = $process.Start()
    # この worker ごと controller の Job と期限で管理する。stream は byte のまま継承する。
    $process.WaitForExit()
    $code = $process.ExitCode
    $process.Dispose()
    exit $code
} catch { exit 1 }
