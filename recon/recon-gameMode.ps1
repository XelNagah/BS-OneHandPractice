param(
    [Parameter(Mandatory = $true, HelpMessage = "Path to a Beat Saber install's <root>\Beat Saber_Data\Managed folder.")]
    [string]$ManagedDir
)
$managed = $ManagedDir
$ilspy = "$env:TEMP\ilspy"
Add-Type -Path "$ilspy\Mono.Cecil.dll"
$resolver = New-Object Mono.Cecil.DefaultAssemblyResolver
$resolver.AddSearchDirectory($managed)
$rp = New-Object Mono.Cecil.ReaderParameters
$rp.AssemblyResolver = $resolver

$asm = [Mono.Cecil.AssemblyDefinition]::ReadAssembly("$managed\Main.dll", $rp)
$types = $asm.MainModule.GetTypes()

foreach ($name in @('StandardLevelScenesTransitionSetupDataSO','MultiplayerLevelScenesTransitionSetupDataSO','MissionLevelScenesTransitionSetupDataSO','LevelScenesTransitionSetupDataSO')) {
    $t = $types | Where-Object { $_.Name -eq $name } | Select-Object -First 1
    if (-not $t) { Write-Output "NOT FOUND: $name"; continue }
    Write-Output ("=" * 80)
    Write-Output "$($t.FullName)"
    Write-Output ("=" * 80)
    Write-Output "Base: $($t.BaseType)"
    Write-Output "Fields:"
    foreach ($f in $t.Fields) {
        if ($f.Name -match 'gameMode|GameMode|<gameMode>') {
            Write-Output "  $($f.FieldType.FullName) $($f.Name)"
        }
    }
    Write-Output "Public/protected Init* methods:"
    foreach ($m in $t.Methods) {
        if ($m.Name -match '^Init$|InitSolo|InitMultiplayer|InitMission') {
            $params = ($m.Parameters | ForEach-Object { "$($_.ParameterType.Name) $($_.Name)" }) -join ', '
            $vis = if ($m.IsPublic) {'pub'} elseif ($m.IsAssembly) {'int'} elseif ($m.IsFamily) {'prot'} else {'priv'}
            Write-Output "  [$vis] $($m.Name)($params) -> $($m.ReturnType.Name)"
        }
    }
}
