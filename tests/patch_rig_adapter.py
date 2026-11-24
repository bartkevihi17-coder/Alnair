from pathlib import Path
p=Path(r"C:\Users\bartk\Desktop\Alnair\src\server\Bootstrap.server.luau")
s=p.read_text("utf-8")
n='local Appearance = require(shared:WaitForChild("Appearance"))'
assert n in s
s=s.replace(n,n+'\nlocal RigAdapter=require(script.Parent:WaitForChild("RigAdapter"))',1)
n='''    starter.Name = "StarterCharacter"
    local rootPart = starter:FindFirstChild("HumanoidRootPart")'''
assert n in s
s=s.replace(n,'''    starter.Name = "StarterCharacter"
    local adapted,count=RigAdapter.adapt(starter)
    if not adapted then
        warn("[ALNAIR] Rig R15 incompleto:",count,"juntas; verificar animacoes.")
    end
    local rootPart = starter:FindFirstChild("HumanoidRootPart")''',1)
p.write_text(s,"utf-8",newline="\n")
print("ADAPTED BOOTSTRAP")
