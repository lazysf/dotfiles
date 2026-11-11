#Requires -Version 7.0
$ErrorActionPreference = 'Stop'
try {
    # EOF では起動しない。controller が Job に所属させてから指示を送る。
    $line = [Console]::ReadLine()
    if (-not $line) { exit 1 }
    # GetString は ISO-8601 も文字列のまま返す。PowerShell 7.0 でも使える。
    $document = [System.Text.Json.JsonDocument]::Parse($line)
    try {
        $request = $document.RootElement
        $executable = $request.GetProperty('Executable').GetString()
        $workingDirectory = $request.GetProperty('WorkingDirectory').GetString()
        $arguments = $request.GetProperty('Arguments')
        if ($arguments.ValueKind -ne [System.Text.Json.JsonValueKind]::Array) { throw 'invalid arguments' }
        $argumentList = @($arguments.EnumerateArray() | ForEach-Object {
            if ($_.ValueKind -ne [System.Text.Json.JsonValueKind]::String) { throw 'invalid argument' }
            $_.GetString()
        })
    } finally { $document.Dispose() }
    if (-not [IO.Path]::IsPathFullyQualified($executable) -or -not [IO.Path]::IsPathFullyQualified($workingDirectory)) { exit 1 }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo.FileName = $executable
    $process.StartInfo.WorkingDirectory = $workingDirectory
    $process.StartInfo.UseShellExecute = $false
    foreach ($argument in $argumentList) { $process.StartInfo.ArgumentList.Add($argument) }
    $null = $process.Start()
    # この worker ごと controller の Job と期限で管理する。stream は byte のまま継承する。
    $process.WaitForExit()
    $code = $process.ExitCode
    $process.Dispose()
    exit $code
} catch { exit 1 }
