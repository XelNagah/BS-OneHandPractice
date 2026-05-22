#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Build OneHandPractice in Release for every supported Beat Saber version and produce
  Plugins-folder-ready zips for distribution.

.DESCRIPTION
  Same source code targets every BS version: only the embedded manifest.json
  (gameVersion + dependsOn) changes. Game DLLs from a real Beat Saber install are
  needed to compile against. BS versions are bucketed into groups that share dep
  versions; each group is compiled once against a "build target" install and the
  resulting DLL is repackaged with one manifest per ship version.

.PARAMETER BsVersion
  Subset of ship versions to build. Defaults to all supported versions.

.PARAMETER OutputDir
  Where the final zips land. Defaults to ./dist.

.PARAMETER Configuration
  MSBuild configuration. Defaults to Release.

.PARAMETER BsManagerInstancesDir
  Folder holding BSManager's per-version subfolders. Auto-discovered when omitted.

.EXAMPLE
  pwsh release.ps1
  pwsh release.ps1 -BsVersion 1.43.0
  pwsh release.ps1 -BsVersion 1.40.0,1.40.8
#>

[CmdletBinding()]
param(
    # One zip per dependency group. Each ship target's gameVersion is the highest version we
    # tested directly inside its group; BSIPA's strict gameVersion check means each user picks
    # the zip whose name matches their game (BSManager handles this automatically).
    [string[]]$BsVersion = @('1.39.1', '1.40.8', '1.43.0'),
    [string]$OutputDir = (Join-Path $PSScriptRoot 'dist'),
    [string]$Configuration = 'Release',
    [string]$BsManagerInstancesDir = $env:BSMANAGER_INSTANCES_DIR
)

$ErrorActionPreference = 'Stop'

# ---- Build groups -----------------------------------------------------------
# Each group lists BS ship versions whose dependency floor is identical, plus the
# BS version we actually compile against. The compiled DLL is then repackaged with
# every group member's manifest. If the build target install isn't available,
# every ship version in that group is skipped.
$buildGroups = @(
    @{ BuildAgainst = '1.39.1'; ShipVersions = @('1.39.1') },
    @{ BuildAgainst = '1.40.8'; ShipVersions = @('1.40.8') },
    @{ BuildAgainst = '1.43.0'; ShipVersions = @('1.43.0') }
)

# Auto-discover BSManager instances folder when not provided.
if ([string]::IsNullOrWhiteSpace($BsManagerInstancesDir)) {
    $candidates = @(
        (Join-Path $env:APPDATA      'BSManager\BSInstances'),
        (Join-Path $env:LOCALAPPDATA 'BSManager\BSInstances'),
        (Join-Path $env:APPDATA      'bs-manager\BSInstances'),
        'C:\BSManager\BSInstances',
        'D:\BSManager\BSInstances'
    )
    $BsManagerInstancesDir = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $BsManagerInstancesDir) {
        throw "Could not locate BSManager's BSInstances directory. Pass -BsManagerInstancesDir or set the BSMANAGER_INSTANCES_DIR environment variable."
    }
    Write-Host "Using BSManager instances dir: $BsManagerInstancesDir" -ForegroundColor DarkGray
}

$projectDir   = Join-Path $PSScriptRoot 'OneHandPractice'
$projectPath  = Join-Path $projectDir 'OneHandPractice.csproj'
$activeManifest = Join-Path $projectDir 'manifest.json'

$asmInfo = Get-Content (Join-Path $projectDir 'Properties\AssemblyInfo.cs') -Raw
$versionMatch = [regex]::Match($asmInfo, 'AssemblyVersion\("([0-9.]+)"\)')
if (-not $versionMatch.Success) { throw 'Could not parse AssemblyVersion from AssemblyInfo.cs' }
$pluginVersion = $versionMatch.Groups[1].Value -replace '\.0$', ''

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# Snapshot manifest.json so we can restore it after the loop (or on failure).
$activeManifestBackup = Join-Path $env:TEMP "OneHandPractice-manifest-backup-$([Guid]::NewGuid()).json"
Copy-Item $activeManifest $activeManifestBackup -Force

$builtZips = New-Object System.Collections.Generic.List[string]
$skipped   = New-Object System.Collections.Generic.List[string]

try {
    foreach ($group in $buildGroups) {
        $buildVer    = $group.BuildAgainst
        $shipInGroup = $group.ShipVersions | Where-Object { $BsVersion -contains $_ }
        if ($shipInGroup.Count -eq 0) { continue }

        $beatSaberDir = Join-Path $BsManagerInstancesDir $buildVer
        if (-not (Test-Path (Join-Path $beatSaberDir 'Beat Saber_Data\Managed'))) {
            Write-Warning "BeatSaberDir for build target $buildVer not found at '$beatSaberDir'. Skipping ship versions: $($shipInGroup -join ', ')"
            $shipInGroup | ForEach-Object { $skipped.Add($_) }
            continue
        }

        $env:BeatSaberDir = $beatSaberDir

        foreach ($ship in $shipInGroup) {
            Write-Host ""
            Write-Host "================================================================" -ForegroundColor Cyan
            Write-Host "  OneHandPractice v$pluginVersion -> BS $ship (compiled vs $buildVer)" -ForegroundColor Cyan
            Write-Host "================================================================" -ForegroundColor Cyan

            $manifestForVersion = Join-Path $projectDir "manifest-$ship.json"
            if (-not (Test-Path $manifestForVersion)) {
                Write-Warning "No manifest-$ship.json found. Skipping."
                $skipped.Add($ship)
                continue
            }
            Copy-Item $manifestForVersion $activeManifest -Force

            $prevEAP = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                & dotnet build $projectPath -c $Configuration --nologo /p:GitModified='' 2>&1 | Out-Host
            }
            finally {
                $ErrorActionPreference = $prevEAP
            }
            if ($LASTEXITCODE -ne 0) { throw "dotnet build failed for ship version $ship (exit $LASTEXITCODE)" }

            $dll = Join-Path $projectDir "bin\$Configuration\OneHandPractice.dll"
            if (-not (Test-Path $dll)) { throw "Expected output not found: $dll" }

            $stagingDir = Join-Path $OutputDir "OneHandPractice-$pluginVersion-bs$ship"
            if (Test-Path $stagingDir) { Remove-Item -Recurse -Force $stagingDir }
            $pluginsDir = Join-Path $stagingDir 'Plugins'
            New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
            Copy-Item $dll $pluginsDir -Force

            $zipPath = Join-Path $OutputDir "OneHandPractice-$pluginVersion-bs$ship.zip"
            if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
            Compress-Archive -Path (Join-Path $stagingDir 'Plugins') -DestinationPath $zipPath

            Write-Host "  -> $zipPath" -ForegroundColor Green
            $builtZips.Add($zipPath)
        }
    }
}
finally {
    Copy-Item $activeManifestBackup $activeManifest -Force
    Remove-Item $activeManifestBackup -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "  Built : $($builtZips.Count) zip(s)"
$builtZips | ForEach-Object { Write-Host "    $_" }
if ($skipped.Count -gt 0) {
    Write-Host "  Skipped: $($skipped -join ', ')" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  - Verify the directly-tested DLL loads in its target BS install (check Logs\_latest.log)."
Write-Host "  - Tag and push the release in git (e.g. v$pluginVersion)."
Write-Host "  - Upload the matching zips as assets to the GitHub Release for the tag."
Write-Host "  - Submit each version's metadata to Lunar Mods / BeatMods."
