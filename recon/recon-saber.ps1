param(
    [Parameter(Mandatory = $true, HelpMessage = "Path to a Beat Saber install's <root>\Beat Saber_Data\Managed folder.")]
    [string]$ManagedDir,
    [string]$OutFile
)
$managed = $ManagedDir
$ilspy = "$env:TEMP\ilspy"
Add-Type -Path "$ilspy\Mono.Cecil.dll"
$resolver = New-Object Mono.Cecil.DefaultAssemblyResolver
$resolver.AddSearchDirectory($managed)
$rp = New-Object Mono.Cecil.ReaderParameters
$rp.AssemblyResolver = $resolver

$dlls = @('Main.dll','BeatmapCore.dll','GameplayCore.dll','DataModels.dll')
$types = @()
foreach ($d in $dlls) {
    $a = [Mono.Cecil.AssemblyDefinition]::ReadAssembly("$managed\$d", $rp)
    foreach ($t in $a.MainModule.GetTypes()) { $types += $t }
}

function Format-Method($m) {
    $sig = "$($m.ReturnType.Name) $($m.Name)("
    $sig += ($m.Parameters | ForEach-Object { "$($_.ParameterType.Name) $($_.Name)" }) -join ', '
    $sig += ')'
    $vis = if ($m.IsPublic) {'pub'} elseif ($m.IsPrivate) {'priv'} elseif ($m.IsAssembly) {'int'} elseif ($m.IsFamily) {'prot'} else {'?'}
    $stat = if ($m.IsStatic) { ' stat' } else { '' }
    return "[${vis}${stat}] $sig"
}

function Dump-Type($name) {
    $t = $types | Where-Object { $_.Name -eq $name -and -not $_.IsNested } | Select-Object -First 1
    if (-not $t) { Write-Output "NOT FOUND: $name"; return }
    Write-Output ("=" * 70)
    Write-Output "$($t.FullName) [$($t.Module.Name)]"
    Write-Output ("=" * 70)
    Write-Output "Base: $($t.BaseType)"
    if ($t.IsEnum) {
        foreach ($f in $t.Fields | Where-Object { $_.IsStatic -and $_.HasConstant }) {
            Write-Output "  $($f.Name) = $($f.Constant)"
        }
        return
    }
    Write-Output "Fields:"
    foreach ($f in $t.Fields) {
        $vis = if ($f.IsPublic) {'pub'} elseif ($f.IsPrivate) {'priv'} else {'int'}
        $stat = if ($f.IsStatic) {' stat'} else {''}
        Write-Output "  [${vis}${stat}] $($f.FieldType.Name) $($f.Name)"
    }
    Write-Output "Properties:"
    foreach ($p in $t.Properties) {
        Write-Output "  $($p.PropertyType.Name) $($p.Name)"
    }
    Write-Output "Methods:"
    foreach ($m in $t.Methods | Where-Object { $_.IsPublic -or $_.IsFamily }) {
        if ($m.IsGetter -or $m.IsSetter) { continue }
        Write-Output "  $(Format-Method $m)"
    }
}

foreach ($n in @('SaberManager','Saber','OneSaberGameplayManager','PlayerController','SaberType','SaberTypeObject','OneSaberInstaller','GameplayCoreInstaller','SaberModelManager')) {
    Dump-Type $n
    Write-Output ""
}

# Find types containing 'OneSaber'
Write-Output ("=" * 70)
Write-Output "Types matching 'OneSaber' or 'OneHand'"
Write-Output ("=" * 70)
foreach ($t in $types) {
    if ($t.Name -match 'OneSaber|OneHand|SaberHide|SaberDisable') {
        Write-Output "  $($t.FullName) [$($t.Module.Name)]"
    }
}

# allowedSaberTypes? requiredSaberType? Find them
Write-Output ""
Write-Output ("=" * 70)
Write-Output "Methods / fields with 'requiredSaberType' or 'allowedSaberType' or 'disableSaber'"
Write-Output ("=" * 70)
foreach ($t in $types) {
    foreach ($f in $t.Fields) {
        if ($f.Name -match 'requiredSaberType|allowedSaberType|disableSaber|hideSaber|saberDisabled') {
            Write-Output "  field $($t.FullName).$($f.Name) : $($f.FieldType.Name)"
        }
    }
    foreach ($p in $t.Properties) {
        if ($p.Name -match 'requiredSaberType|allowedSaberType|disableSaber|hideSaber|saberDisabled') {
            Write-Output "  prop  $($t.FullName).$($p.Name) : $($p.PropertyType.Name)"
        }
    }
    foreach ($m in $t.Methods) {
        if ($m.Name -match 'requiredSaberType|allowedSaberType|disableSaber|hideSaber|enableSaber') {
            Write-Output "  meth  $($t.FullName).$($m.Name)(...)"
        }
    }
}
