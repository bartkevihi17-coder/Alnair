from pathlib import Path
r=Path(r"C:\Users\bartk\Desktop\Alnair")
boot=r/"src/server/Bootstrap.server.luau"
s=boot.read_text("utf-8")
old='''    local adapted,count=RigAdapter.adapt(starter)
    if not adapted then'''
new='''    local adapted,count=RigAdapter.adapt(starter)
    local bodyHumanoid=starter:FindFirstChildOfClass("Humanoid")
    if bodyHumanoid then
        -- Evita que o auto scaling da Avatar Setup recalcule HipHeight negativo.
        bodyHumanoid.AutomaticScalingEnabled=false
        bodyHumanoid.HipHeight=2.67
    end
    if not adapted then'''
assert old in s
boot.write_text(s.replace(old,new,1),"utf-8",newline="\n")
gp=r/"src/server/AlnairGameplay.server.luau"
s=gp.read_text("utf-8")
old='''        task.wait(.45)
        local mode=player:GetAttribute("AlnairMode")'''
new='''        task.wait(.45)
        -- O R15 importado chegava com HipHeight=-0.087 e os pés afundavam/voavam.
        if character:FindFirstChild("LeftUpperArm") then
            humanoid.AutomaticScalingEnabled=false
            humanoid.HipHeight=2.67
        end
        local mode=player:GetAttribute("AlnairMode")'''
assert old in s
gp.write_text(s.replace(old,new,1),"utf-8",newline="\n")
diag=r/"src/server/CharacterDiagnostics.server.luau"
s=diag.read_text("utf-8")
old='''        local ray=Workspace:Raycast(root.Position+Vector3.new(0,12,0),Vector3.new(0,-35,0))'''
new='''        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances={c}
        local ray=Workspace:Raycast(root.Position+Vector3.new(0,12,0),Vector3.new(0,-100,0),params)'''
assert old in s
diag.write_text(s.replace(old,new,1),"utf-8",newline="\n")
print("HIPHEIGHT FIXED")
