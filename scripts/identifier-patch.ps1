#Requires -Version 7.0
function Get-IdentifierAddedSegments {
    param([string]$Patch)
    $segment = [Text.StringBuilder]::new()
    $inHunk = $false
    $oldRemaining = 0
    $newRemaining = 0
    $previous = ''
    $hasFileHeader = $false
    $hasPathHeader = $false
    $hasHunk = $false
    foreach ($line in $Patch.Split("`n")) {
        if ($line -ceq '\ No newline at end of file') {
            if ($previous -eq '+') {
                if ($segment.Length -eq 0) { throw 'invalid newline marker' }
                $null = $segment.Remove($segment.Length - 1, 1)
            } elseif ($previous -notin @('-', ' ')) { throw 'invalid newline marker' }
            $previous = ''
            continue
        }
        if ($inHunk -and $oldRemaining -eq 0 -and $newRemaining -eq 0) { $inHunk = $false }
        if ($line -match '^@@ -\d+(?:,(\d+))? \+\d+(?:,(\d+))? @@') {
            if (-not $hasFileHeader -or -not $hasPathHeader) { throw 'missing patch header' }
            if ($inHunk) { throw 'incomplete hunk' }
            if ($segment.Length) { $segment.ToString(); $null = $segment.Clear() }
            $oldRemaining = if ($Matches.ContainsKey(1)) { [int]$Matches[1] } else { 1 }
            $newRemaining = if ($Matches.ContainsKey(2)) { [int]$Matches[2] } else { 1 }
            $inHunk = $true
            $hasHunk = $true
            $previous = ''
            continue
        }
        if (-not $inHunk) {
            if ($hasHunk -and $line -ne '') { throw 'unexpected record after hunk' }
            if ($line.StartsWith('diff --git ')) {
                if ($hasFileHeader) { throw 'multiple files in patch segment' }
                $hasFileHeader = $true
            } elseif ($line.StartsWith('+++ ')) {
                if (-not $hasFileHeader -or $hasPathHeader) { throw 'invalid path header' }
                $hasPathHeader = $true
            } elseif ($line -ne '' -and -not $hasFileHeader) { throw 'missing file header' }
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

function ConvertFrom-IdentifierGitPath {
    param([string]$Path)
    # 空白を含む unquoted path の後ろには Git が TAB の区切りを付ける。
    if ($Path.EndsWith("`t")) { $Path = $Path.Substring(0, $Path.Length - 1) }
    # Patch は Latin1 で運んでいるため、unquote 後に UTF-8 として読む。
    if ($Path.StartsWith('"')) {
        if ($Path.Length -lt 2 -or -not $Path.EndsWith('"')) { throw 'invalid quoted path' }
        $bytes = [Collections.Generic.List[byte]]::new()
        $escapes = @{ a = 7; b = 8; t = 9; n = 10; v = 11; f = 12; r = 13; '\' = 92; '"' = 34 }
        for ($i = 1; $i -lt $Path.Length - 1; $i++) {
            $character = $Path[$i]
            if ($character -eq '\') {
                $i++
                if ($i -ge $Path.Length - 1) { throw 'incomplete path escape' }
                $escape = [string]$Path[$i]
                if ($escapes.ContainsKey($escape)) { $bytes.Add([byte]$escapes[$escape]) }
                elseif ($escape -cmatch '^[0-3]$' -and $i + 2 -lt $Path.Length - 1 -and $Path.Substring($i, 3) -cmatch '^[0-3][0-7]{2}$') {
                    $bytes.Add([Convert]::ToByte($Path.Substring($i, 3), 8))
                    $i += 2
                } else { throw 'invalid path escape' }
            } elseif ($character -eq '"') { throw 'unescaped path quote' }
            else { $bytes.Add([byte]$character) }
        }
        $raw = $bytes.ToArray()
    } else { $raw = [Text.Encoding]::Latin1.GetBytes($Path) }
    $decoded = [Text.UTF8Encoding]::new($false, $true).GetString($raw)
    if (-not $decoded.StartsWith('b/', [StringComparison]::Ordinal)) { throw 'invalid path prefix' }
    return $decoded.Substring(2)
}

function Get-IdentifierPatchFiles {
    param([string]$Patch, [string[]]$Paths)
    $files = [Collections.Generic.Dictionary[string, object]]::new([StringComparer]::Ordinal)
    foreach ($path in $Paths) { $files.Add($path, @()) }
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $sections = 0
    foreach ($section in [regex]::Split($Patch, '(?m)(?=^diff --git )')) {
        if ($section -eq '') { continue }
        if (-not $section.StartsWith('diff --git ')) { throw 'missing file header' }
        $sections++
        $segments = @(Get-IdentifierAddedSegments $section)
        # +++ に似た追加行を header と読まない。
        $metadata = ([regex]::new('(?m)^@@ ').Split($section, 2))[0]
        $headers = [regex]::Matches($metadata, '(?m)^\+\+\+ (.*)$')
        if ($headers.Count -gt 1) { throw 'duplicate path header' }
        if ($headers.Count -eq 1) {
            $path = ConvertFrom-IdentifierGitPath $headers[0].Groups[1].Value
            if (-not $files.ContainsKey($path) -or -not $seen.Add($path)) { throw 'patch path mismatch' }
            $files[$path] = $segments
        } elseif ($segments.Count) { throw 'missing path header' }
    }
    if ($sections -ne $Paths.Count) { throw 'patch file count mismatch' }
    return ,$files
}
