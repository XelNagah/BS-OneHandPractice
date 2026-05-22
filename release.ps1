#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Build OneHandPractice in Release and produce a Plugins-folder-ready zip for distribution.

.EXAMPLE
  pwsh release.ps1
  pwsh release.ps1 -BeatSaberDir "D:\BSManager\BSInstances\1.39.1" -OutputDir .\dist

.NOTES
  GitHub Actions is not used because building a Beat Saber mod requires the local game DLLs
  (Main.dll, BeatmapCore.dll, etc.) which cannot be redistributed. Run this script locally,
  attach the produced zip to a manual GitHub Release.
#>

[CmdletBinding()]
param(
    [string]$BeatSaberDir = $env:BeatSaberDir,
    [string]$OutputDir = (Join-Path $PSScriptRoot 'dist'),
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($BeatSaberDir)) {
    $BeatSaberDir = 'D:\BSManager\BSInstances\1.39.1'
    Write-Host "BeatSaberDir not set, defaulting to $BeatSaberDir" -ForegroundColor Yellow
}

if (-not (Test-Path (Join-Path $BeatSaberDir 'Beat Saber_Data\Managed'))) {
    throw "BeatSaberDir '$BeatSaberDir' does not look like a Beat Saber install. Pass -BeatSaberDir or set the env var."
}

$env:BeatSaberDir = $BeatSaberDir

$projectPath = Join-Path $PSScriptRoot 'OneHandPractice\OneHandPractice.csproj'
$binDir = Join-Path $PSScriptRoot "OneHandPractice\bin\$Configuration"

# Read version from AssemblyInfo so the zip filename matches.
$asmInfo = Get-Content (Join-Path $PSScriptRoot 'OneHandPractice\Properties\AssemblyInfo.cs') -Raw
$versionMatch = [regex]::Match($asmInfo, 'AssemblyVersion\("([0-9.]+)"\)')
if (-not $versionMatch.Success) { throw 'Could not parse AssemblyVersion from AssemblyInfo.cs' }
$version = $versionMatch.Groups[1].Value -replace '\.0$',''

Write-Host "Building OneHandPractice v$version ($Configuration)..." -ForegroundColor Cyan
# BeatSaberModdingTools.Tasks shells out to `git` for the commit hash; with no commits yet that
# writes a benign warning to stderr that strict mode would treat as terminating. Relax for the
# build call only — we still gate on the dotnet exit code below.
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
    & dotnet build $projectPath -c $Configuration --nologo 2>&1 | Out-Host
}
finally {
    $ErrorActionPreference = $prevEAP
}
if ($LASTEXITCODE -ne 0) { throw "dotnet build failed (exit $LASTEXITCODE)" }

$dll = Join-Path $binDir 'OneHandPractice.dll'
if (-not (Test-Path $dll)) { throw "Expected output not found: $dll" }

# Create dist/<version>/Plugins/OneHandPractice.dll, then zip Plugins/ at root level.
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$stagingDir = Join-Path $OutputDir "OneHandPractice-$version"
if (Test-Path $stagingDir) { Remove-Item -Recurse -Force $stagingDir }
$pluginsDir = Join-Path $stagingDir 'Plugins'
New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
Copy-Item $dll $pluginsDir

$zipPath = Join-Path $OutputDir "OneHandPractice-$version-bs1.39.1.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }
Compress-Archive -Path (Join-Path $stagingDir 'Plugins') -DestinationPath $zipPath

Write-Host ""
Write-Host "Release artifact ready:" -ForegroundColor Green
Write-Host "  $zipPath"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. git tag v$version && git push origin v$version"
Write-Host "  2. Create GitHub Release for the tag, upload the zip above as asset."
Write-Host "  3. Submit metadata to Lunar Mods (https://lunarmods.aeroluna.dev/)."
