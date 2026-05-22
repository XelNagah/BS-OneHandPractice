param(
    [string]$PluginsDir = "D:\BSManager\BSInstances\1.43.0\Plugins",
    [string]$LibsDir    = "D:\BSManager\BSInstances\1.43.0\Libs",
    [string]$ManagedDir = "D:\BSManager\BSInstances\1.43.0\Beat Saber_Data\Managed",
    [string]$MethodName = "GetBeatmapLevel",
    [string]$DeclaringTypeName = "BeatmapLevelsModel"
)

$ilspy = "$env:TEMP\ilspy"
Add-Type -Path "$ilspy\Mono.Cecil.dll"

$resolver = New-Object Mono.Cecil.DefaultAssemblyResolver
foreach ($d in @($PluginsDir, $LibsDir, $ManagedDir)) { if (Test-Path $d) { $resolver.AddSearchDirectory($d) } }
$rp = New-Object Mono.Cecil.ReaderParameters
$rp.AssemblyResolver = $resolver

$results = @()
$dlls = Get-ChildItem $PluginsDir -Filter "*.dll" -ErrorAction SilentlyContinue
Write-Output "Scanning $($dlls.Count) DLLs for callers of $DeclaringTypeName.$MethodName ..."

foreach ($f in $dlls) {
    try {
        $asm = [Mono.Cecil.AssemblyDefinition]::ReadAssembly($f.FullName, $rp)
    } catch {
        continue
    }
    foreach ($t in $asm.MainModule.GetTypes()) {
        if (-not $t.HasMethods) { continue }
        foreach ($m in $t.Methods) {
            if (-not $m.HasBody) { continue }
            foreach ($instr in $m.Body.Instructions) {
                $op = $instr.Operand
                if ($op -is [Mono.Cecil.MethodReference]) {
                    if ($op.Name -eq $MethodName -and $op.DeclaringType -and $op.DeclaringType.Name -eq $DeclaringTypeName) {
                        $results += [pscustomobject]@{
                            Dll        = $f.Name
                            Caller     = "$($t.FullName).$($m.Name)"
                            Target     = "$($op.DeclaringType.FullName).$($op.Name)($(($op.Parameters | ForEach-Object { $_.ParameterType.Name }) -join ', '))"
                        }
                    }
                }
            }
        }
    }
}

if ($results.Count -eq 0) {
    Write-Output "No callers found."
} else {
    $results | Sort-Object Dll, Caller -Unique | Format-Table -AutoSize -Wrap
}
