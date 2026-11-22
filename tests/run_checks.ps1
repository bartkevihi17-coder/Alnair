$ErrorActionPreference="Stop"
$root=Split-Path $PSScriptRoot -Parent
$luau=Join-Path $env:LOCALAPPDATA "Programs\Luau\luau-compile.exe"
$rojo=Join-Path $env:LOCALAPPDATA "Programs\Rojo\rojo.exe"
if (!(Test-Path $luau) -or !(Test-Path $rojo)){throw "Luau ou Rojo nao encontrado"}
Get-ChildItem (Join-Path $root "src") -Recurse -File |
  Where-Object {$_.Extension -in @(".lua",".luau")} |
  ForEach-Object {
    & $luau --null $_.FullName 2>&1 | Out-Null
    if($LASTEXITCODE -ne 0){throw ("Falha Luau: "+$_.FullName)}
    Write-Output ("PASS COMPILE "+$_.Name)
  }
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "tests\run_rules.ps1")
if($LASTEXITCODE -ne 0){throw "Falha rules"}
$place=Join-Path $root "build\Alnair-v04-playtest.rbxlx"
& $rojo build (Join-Path $root "default.project.json") -o $place
if($LASTEXITCODE -ne 0){throw "Falha Rojo"}
[xml]$xml=[IO.File]::ReadAllText($place)
$all=@($xml.SelectNodes("//Item/Properties/string[@name='Name']")|ForEach-Object {$_.InnerText})
foreach($required in @("AlnairGameplay","GameplayUI","GameRules","WorldExpansion","EnemyDirector","PlayerProgress","AlnairRiggedBody","AlnairMeshes","AlnairEarMeshes")){
    if($required -notin $all){throw ("Arquivo nao incluido no lugar: "+$required)}
    Write-Output ("PASS PLACE "+$required)
}
Write-Output ("VALIDACAO CONCLUIDA: "+(Get-Item $place).Length+" bytes")
