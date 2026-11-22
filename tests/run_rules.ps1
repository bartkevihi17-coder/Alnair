$ErrorActionPreference='Stop'
$root=Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
$rules=[IO.File]::ReadAllText((Join-Path $root 'src\shared\GameRules.lua'))
$tests=[IO.File]::ReadAllText((Join-Path $root 'tests\rules_spec.luau'))
$tests=[regex]::Replace($tests,'(?m)^Color3\s*=.*(?:\r?\n)','')
$tests=[regex]::Replace($tests,'(?m)^Vector3\s*=.*(?:\r?\n)','')
$tests=[regex]::Replace($tests,'(?m)^local rules\s*=\s*require\(.*(?:\r?\n)','')
$header=@'
Color3 = {fromRGB=function(r,g,b) return {r=r,g=g,b=b} end}
Vector3 = {new=function(x,y,z) return {X=x,Y=y,Z=z} end}
local rules = (function()
'@
$built=$header+[Environment]::NewLine+$rules+[Environment]::NewLine+'end)()'+[Environment]::NewLine+$tests
$tmp=Join-Path $root 'build\.rules_spec.compiled.luau'
[IO.File]::WriteAllText($tmp,$built,(New-Object Text.UTF8Encoding($false)))
$luau=Join-Path $env:LOCALAPPDATA 'Programs\Luau\luau.exe'
& $luau $tmp
if($LASTEXITCODE -ne 0){throw ('Rules failed, exit '+$LASTEXITCODE)}
