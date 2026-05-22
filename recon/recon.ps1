param(
    [Parameter(Mandatory = $true, HelpMessage = "Path to a Beat Saber install's <root>\Beat Saber_Data\Managed folder.")]
    [string]$ManagedDir,
    [string]$IlspyDir = "$env:TEMP\ilspy",
    [string]$OutFile = "$PSScriptRoot\recon-output.txt"
)

Add-Type -Path "$IlspyDir\Mono.Cecil.dll"
$resolver = New-Object Mono.Cecil.DefaultAssemblyResolver
$resolver.AddSearchDirectory($ManagedDir)
$readerParams = New-Object Mono.Cecil.ReaderParameters
$readerParams.AssemblyResolver = $resolver

# DLLs to scan
$dllNames = @('Main.dll','BeatmapCore.dll','GameplayCore.dll','DataModels.dll','HMUI.dll','BGLib.AppFlow.dll','BeatSaber.Init.dll','GameInit.dll','BeatSaber.Settings.dll','BeatSaber.ViewSystem.dll')
$allTypes = New-Object System.Collections.Generic.List[Mono.Cecil.TypeDefinition]
foreach ($dll in $dllNames) {
    $p = Join-Path $ManagedDir $dll
    if (-not (Test-Path $p)) { continue }
    $asm = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($p, $readerParams)
    foreach ($t in $asm.MainModule.GetTypes()) { $allTypes.Add($t) }
}

$targets = @(
    'BeatmapDataTransformHelper',
    'BeatmapData',
    'IReadonlyBeatmapData',
    'NoteData',
    'SliderData',
    'BurstSliderData',
    'ObstacleData',
    'BombNoteData',
    'ScoreModel',
    'GameplayCoreSceneSetupData',
    'BeatmapDataItem',
    'BeatmapObjectSpawnController',
    'BeatmapObjectManager',
    'BeatmapDataLoader',
    'ColorType',
    'NoteLineLayer',
    'GameplayModifiers'
)

function Format-Method($m) {
    $sig = "$($m.ReturnType.FullName) $($m.Name)("
    $sig += ($m.Parameters | ForEach-Object { "$($_.ParameterType.FullName) $($_.Name)" }) -join ', '
    $sig += ')'
    $vis = if ($m.IsPublic) {'public'} elseif ($m.IsPrivate) {'private'} elseif ($m.IsAssembly) {'internal'} elseif ($m.IsFamily) {'protected'} else {'unk'}
    $stat = if ($m.IsStatic) {' static'} else {''}
    return "${vis}${stat} $sig"
}

$out = New-Object System.Text.StringBuilder
[void]$out.AppendLine("# Recon BS 1.39.1 - multi-asm")
[void]$out.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$out.AppendLine("DLLs scanned: $($dllNames -join ', ')")
[void]$out.AppendLine("Total types: $($allTypes.Count)")
[void]$out.AppendLine("")

foreach ($target in $targets) {
    [void]$out.AppendLine("================================================================")
    [void]$out.AppendLine("## Target: $target")
    [void]$out.AppendLine("================================================================")
    $matches = $allTypes | Where-Object { $_.Name -eq $target }
    if (-not $matches) {
        [void]$out.AppendLine("NOT FOUND in scanned DLLs")
        [void]$out.AppendLine("")
        continue
    }
    foreach ($t in $matches) {
        [void]$out.AppendLine("FullName: $($t.FullName)")
        [void]$out.AppendLine("Module: $($t.Module.Name)")
        [void]$out.AppendLine("Kind: $(if($t.IsInterface){'interface'}elseif($t.IsEnum){'enum'}elseif($t.IsValueType){'struct'}else{'class'})")
        [void]$out.AppendLine("BaseType: $($t.BaseType)")
        if ($t.HasInterfaces) {
            [void]$out.AppendLine("Implements:")
            foreach ($i in $t.Interfaces) { [void]$out.AppendLine("  - $($i.InterfaceType.FullName)") }
        }
        if ($t.IsEnum) {
            [void]$out.AppendLine("Enum values:")
            foreach ($f in $t.Fields) {
                if ($f.IsStatic -and $f.HasConstant) {
                    [void]$out.AppendLine("  - $($f.Name) = $($f.Constant)")
                }
            }
        } else {
            if ($t.HasFields) {
                [void]$out.AppendLine("Fields:")
                foreach ($f in $t.Fields) {
                    $mod = if ($f.IsPublic) {'public'} elseif ($f.IsPrivate) {'private'} else {'internal'}
                    if ($f.IsStatic) { $mod += ' static' }
                    [void]$out.AppendLine("  - $mod $($f.FieldType.FullName) $($f.Name)")
                }
            }
            if ($t.HasProperties) {
                [void]$out.AppendLine("Properties:")
                foreach ($p in $t.Properties) {
                    [void]$out.AppendLine("  - $($p.PropertyType.FullName) $($p.Name) { $(if($p.GetMethod){'get;'} else {''}) $(if($p.SetMethod){'set;'} else {''}) }")
                }
            }
            if ($t.HasMethods) {
                [void]$out.AppendLine("Methods (public + protected, excluding accessors):")
                foreach ($m in $t.Methods) {
                    if (-not ($m.IsPublic -or $m.IsFamily)) { continue }
                    if ($m.IsGetter -or $m.IsSetter) { continue }
                    if ($m.Name -like 'add_*' -or $m.Name -like 'remove_*') { continue }
                    [void]$out.AppendLine("  - $(Format-Method $m)")
                }
            }
        }
        [void]$out.AppendLine("")
    }
}

# Score-related search
[void]$out.AppendLine("================================================================")
[void]$out.AppendLine("## All ScoreModel-like types (Score in name)")
[void]$out.AppendLine("================================================================")
$scoreTypes = $allTypes | Where-Object { $_.Name -match 'Score' -and -not $_.IsInterface -and -not $_.IsNested }
foreach ($t in $scoreTypes) {
    [void]$out.AppendLine("- $($t.FullName) [$($t.Module.Name)]")
}
[void]$out.AppendLine("")

# ScoreModel detail
[void]$out.AppendLine("================================================================")
[void]$out.AppendLine("## ScoreModel - all methods")
[void]$out.AppendLine("================================================================")
$sm = $allTypes | Where-Object { $_.Name -eq 'ScoreModel' } | Select-Object -First 1
if ($sm) {
    [void]$out.AppendLine("Module: $($sm.Module.Name)")
    foreach ($m in $sm.Methods) {
        [void]$out.AppendLine("  - $(Format-Method $m)")
    }
} else {
    [void]$out.AppendLine("Not found by exact name. Trying ScoreController/ScoreCalculator...")
    foreach ($name in @('ScoreController','ScoreCalculator','GameplayCoreInstaller')) {
        $c = $allTypes | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        if ($c) {
            [void]$out.AppendLine("")
            [void]$out.AppendLine("### $($c.FullName) [$($c.Module.Name)]")
            foreach ($m in $c.Methods) {
                if (-not ($m.IsPublic -or $m.IsFamily)) { continue }
                [void]$out.AppendLine("  - $(Format-Method $m)")
            }
        }
    }
}
[void]$out.AppendLine("")

# Find MaxScore methods anywhere
[void]$out.AppendLine("================================================================")
[void]$out.AppendLine("## Methods named with 'MaxScore','MaxMultiplied','ComputeMax'")
[void]$out.AppendLine("================================================================")
foreach ($t in $allTypes) {
    if (-not $t.HasMethods) { continue }
    foreach ($m in $t.Methods) {
        if ($m.Name -match 'MaxScore|MaxMultiplied|ComputeMax|MaxRawScore') {
            $stat = if ($m.IsStatic) {'static '} else {''}
            [void]$out.AppendLine("  ${stat}$($t.FullName).$($m.Name)(...) -> $($m.ReturnType.FullName) [$($t.Module.Name)]")
        }
    }
}
[void]$out.AppendLine("")

# Find Transform* methods on beatmap-related types
[void]$out.AppendLine("================================================================")
[void]$out.AppendLine("## Beatmap transform methods")
[void]$out.AppendLine("================================================================")
foreach ($t in $allTypes) {
    if (-not $t.HasMethods) { continue }
    foreach ($m in $t.Methods) {
        $rt = $m.ReturnType.FullName
        if ($rt -match 'IReadonlyBeatmapData|^BeatmapData$' -or $m.Name -match 'CreateTransform|TransformBeatmap|GetTransform') {
            $stat = if ($m.IsStatic) {'static '} else {''}
            [void]$out.AppendLine("  ${stat}$($t.FullName).$($m.Name)(...) -> $rt [$($t.Module.Name)]")
        }
    }
}
[void]$out.AppendLine("")

# Find gameMode field/property
[void]$out.AppendLine("================================================================")
[void]$out.AppendLine("## gameMode fields/properties")
[void]$out.AppendLine("================================================================")
foreach ($t in $allTypes) {
    foreach ($f in $t.Fields) {
        if ($f.Name -match 'gameMode|GameMode') {
            [void]$out.AppendLine("  field: $($t.FullName).$($f.Name) : $($f.FieldType.FullName) [$($t.Module.Name)]")
        }
    }
    foreach ($p in $t.Properties) {
        if ($p.Name -match 'gameMode|GameMode') {
            [void]$out.AppendLine("  prop: $($t.FullName).$($p.Name) : $($p.PropertyType.FullName) [$($t.Module.Name)]")
        }
    }
}

Set-Content -Path $OutFile -Value $out.ToString() -Encoding utf8
Write-Output "Recon written to: $OutFile"
Write-Output "Total types scanned: $($allTypes.Count)"
