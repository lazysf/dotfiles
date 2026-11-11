#Requires -Version 7.0
function Get-IdentifierAddedSegments {
    param([string]$Patch)
    $segment = [Text.StringBuilder]::new()
    $inHunk = $false
    $oldRemaining = 0
    $newRemaining = 0
    $previous = ''
    foreach ($line in $Patch.Split("`n")) {
        if ($line.StartsWith('\ No newline at end of file')) {
            if ($previous -eq '+') {
                if ($segment.Length -eq 0) { throw 'invalid newline marker' }
                $null = $segment.Remove($segment.Length - 1, 1)
            } elseif ($previous -notin @('-', ' ')) { throw 'invalid newline marker' }
            $previous = ''
            continue
        }
        if ($inHunk -and $oldRemaining -eq 0 -and $newRemaining -eq 0) { $inHunk = $false }
        if ($line -match '^@@ -\d+(?:,(\d+))? \+\d+(?:,(\d+))? @@') {
            if ($inHunk) { throw 'incomplete hunk' }
            if ($segment.Length) { $segment.ToString(); $null = $segment.Clear() }
            $oldRemaining = if ($Matches.ContainsKey(1)) { [int]$Matches[1] } else { 1 }
            $newRemaining = if ($Matches.ContainsKey(2)) { [int]$Matches[2] } else { 1 }
            $inHunk = $true
            $previous = ''
            continue
        }
        if (-not $inHunk) {
            if ($segment.Length) { $segment.ToString(); $null = $segment.Clear() }
            if ($line -ne '' -and $line -notmatch '^(diff --git |index |--- |\+\+\+ |old mode |new mode |new file mode |deleted file mode |similarity index |dissimilarity index |rename from |rename to |copy from |copy to )') { throw 'unknown patch record' }
            $previous = ''
            continue
        }
        if ($line.Length -eq 0) { throw 'empty hunk record' }
        $prefix = $line.Substring(0, 1)
        if ($prefix -ne '+' -and $segment.Length) { $segment.ToString(); $null = $segment.Clear() }
        switch ($prefix) {
            '+' { $newRemaining--; $null = $segment.Append($line.Substring(1)).Append("`n") }
            '-' { $oldRemaining-- }
            ' ' { $oldRemaining--; $newRemaining-- }
            default { throw 'unknown hunk record' }
        }
        if ($oldRemaining -lt 0 -or $newRemaining -lt 0) { throw 'invalid hunk size' }
        $previous = $prefix
    }
    if ($oldRemaining -ne 0 -or $newRemaining -ne 0) { throw 'incomplete patch' }
    if ($segment.Length) { $segment.ToString() }
}
