#Requires -Version 7.0
if (-not ('IdentifierCheck.ProcessJob' -as [type])) { Add-Type -Path (Join-Path $PSScriptRoot 'IdentifierProcess.cs') -ErrorAction Stop }

function Invoke-IdentifierProcess {
    param([string]$Executable, [string[]]$Arguments, [string]$WorkingDirectory, [int]$TimeoutMilliseconds = 30000)
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $job = [IdentifierCheck.ProcessJob]::new()
    $process = [Diagnostics.Process]::new()
    $started = $false
    $assigned = $false
    $stdout = [IO.MemoryStream]::new()
    $stderr = [IO.MemoryStream]::new()
    try {
        $process.StartInfo.FileName = Join-Path $PSHOME 'pwsh.exe'
        $process.StartInfo.WorkingDirectory = $WorkingDirectory
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.CreateNoWindow = $true
        $process.StartInfo.RedirectStandardInput = $true
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        foreach ($argument in @('-NoProfile', '-NonInteractive', '-File', (Join-Path $PSScriptRoot 'identifier-worker.ps1'))) { $process.StartInfo.ArgumentList.Add($argument) }
        $null = $process.Start()
        $started = $true
        $outTask = $process.StandardOutput.BaseStream.CopyToAsync($stdout)
        $errTask = $process.StandardError.BaseStream.CopyToAsync($stderr)
        $job.Assign($process)
        $assigned = $true
        $payload = @{ Executable = $Executable; Arguments = @($Arguments); WorkingDirectory = $WorkingDirectory } | ConvertTo-Json -Compress
        $sendTask = $process.StandardInput.WriteLineAsync($payload)
        $remaining = [Math]::Max(0, $TimeoutMilliseconds - [int]$clock.ElapsedMilliseconds)
        if (-not $sendTask.Wait($remaining)) { throw 'worker instruction timeout' }
        $process.StandardInput.Close()
        $remaining = [Math]::Max(0, $TimeoutMilliseconds - [int]$clock.ElapsedMilliseconds)
        if (-not $process.WaitForExit($remaining)) { throw 'process timeout' }
        $remaining = [Math]::Max(0, $TimeoutMilliseconds - [int]$clock.ElapsedMilliseconds)
        if (-not [Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($outTask, $errTask), $remaining)) { throw 'stream timeout' }
        if ($process.ExitCode -ne 0) { throw 'process failed' }
        return ,$stdout.ToArray()
    } finally {
        $cleanup = [Diagnostics.Stopwatch]::StartNew()
        try {
            if ($started -and -not $assigned -and -not $process.HasExited) {
                $process.Kill($true)
                if (-not $process.WaitForExit(5000)) { throw 'worker cleanup timeout' }
            }
        } finally {
            try {
                $remaining = [Math]::Max(0, 5000 - [int]$cleanup.ElapsedMilliseconds)
                $job.Stop($remaining)
                if ($started) {
                    $remaining = [Math]::Max(0, 5000 - [int]$cleanup.ElapsedMilliseconds)
                    if (-not [Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($outTask, $errTask), $remaining)) { throw 'stream cleanup timeout' }
                }
            } finally {
                $job.Dispose()
                $process.Dispose()
                $stdout.Dispose()
                $stderr.Dispose()
            }
        }
    }
}
