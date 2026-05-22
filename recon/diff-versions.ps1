param(
    [string]$ReconDir = $PSScriptRoot,
    [string]$OutFile = "$PSScriptRoot\drift-summary.md"
)

$versions = @('1.39.1','1.40.8','1.43.0')
$files = @{}
foreach ($v in $versions) {
    $p = Join-Path $ReconDir "recon-output-$v.txt"
    if (-not (Test-Path $p)) { Write-Output "missing: $p"; continue }
    $files[$v] = Get-Content $p
}

# Extract content for a given target section header
function Get-Section($lines, $target) {
    $marker = "## Target: $target"
    $result = New-Object System.Collections.Generic.List[string]
    $inside = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -like "*$marker*") {
            $inside = $true
            continue
        }
        if ($inside) {
            if ($lines[$i] -like "## *" -or $lines[$i] -like "===*") {
                # next section header — stop. But our format uses == bars as separators.
                if ($lines[$i] -like "================================================================" -and
                    ($i + 1) -lt $lines.Count -and $lines[$i+1] -like "## *") {
                    break
                }
                if ($lines[$i] -like "## *") {
                    break
                }
            }
            $result.Add($lines[$i])
        }
    }
    return ($result -join "`n").Trim()
}

# Extract a "free" text block matching a pattern (regex)
function Get-Lines($lines, $pattern) {
    return ($lines | Where-Object { $_ -match $pattern }) -join "`n"
}

$targets = @(
    'BeatmapDataTransformHelper',
    'BeatmapData',
    'IReadonlyBeatmapData',
    'NoteData',
    'SliderData',
    'ColorType',
    'ScoreModel',
    'GameplayCoreSceneSetupData',
    'BeatmapDataItem'
)

$specialPatterns = @{
    'CreateTransformedBeatmapData' = 'CreateTransformedBeatmapData'
    'GetFilteredCopy'              = 'GetFilteredCopy'
    'ComputeMaxMultipliedScoreForBeatmap' = 'ComputeMaxMultipliedScoreForBeatmap'
    'SaberManager.SaberForType'    = 'SaberForType'
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# API drift across BS versions")
[void]$sb.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
[void]$sb.AppendLine("")

foreach ($t in $targets) {
    [void]$sb.AppendLine("## Type: $t")
    [void]$sb.AppendLine("")
    foreach ($v in $versions) {
        $section = Get-Section $files[$v] $t
        $found = if ($section -and $section -notmatch 'NOT FOUND') { "found" } else { "MISSING" }
        $module = if ($section -match 'Module:\s*(\S+)') { $Matches[1] } else { 'unknown' }
        [void]$sb.AppendLine("- **BS $v**: $found ($module)")
    }
    [void]$sb.AppendLine("")

    # Show fingerprint differences (line-count compare)
    foreach ($v in $versions) {
        $section = Get-Section $files[$v] $t
        $lines = ($section -split "`n").Count
        [void]$sb.Append("  - ${v}: ${lines} lines    ")
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("")
}

[void]$sb.AppendLine("---")
[void]$sb.AppendLine("## Specific method/field hits per version")
[void]$sb.AppendLine("")

foreach ($key in $specialPatterns.Keys) {
    $pattern = $specialPatterns[$key]
    [void]$sb.AppendLine("### $key")
    [void]$sb.AppendLine("")
    foreach ($v in $versions) {
        $hits = $files[$v] | Where-Object { $_ -match $pattern }
        [void]$sb.AppendLine("**BS $v** ($($hits.Count) hits):")
        foreach ($h in $hits | Select-Object -First 6) {
            [void]$sb.AppendLine("``````")
            [void]$sb.AppendLine($h.Trim())
            [void]$sb.AppendLine("``````")
        }
        [void]$sb.AppendLine("")
    }
}

Set-Content -Path $OutFile -Value $sb.ToString() -Encoding utf8
Write-Output "Drift summary: $OutFile"
