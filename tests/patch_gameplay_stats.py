from pathlib import Path
f=Path(r"C:\Users\bartk\Desktop\Alnair\src\server\AlnairGameplay.server.luau")
s=f.read_text("utf-8")
def patch(old,new):
 global s
 if old not in s:raise RuntimeError("anchor "+repr(old[:100]))
 s=s.replace(old,new,1);print("PATCH",old[:60].replace("\n"," | "))
patch('''    player:SetAttribute("AlnairRunArmor",runBuff(r,"armor"))''',
'''    player:SetAttribute("AlnairRunArmor",
        math.clamp(Profiles.damageMitigation(player)+runBuff(r,"armor"),0,.75))
    player:SetAttribute("AlnairDefense",Profiles.defense(player))
    player:SetAttribute("AlnairAttack",Profiles.attackPower(player))''')
patch('''        humanoid.WalkSpeed=16*(1+runBuff(r,"speed"))''',
'''        humanoid.WalkSpeed=16*(1+runBuff(r,"speed")+Profiles.speedBonus(player))''')
patch('''    player:SetAttribute("AlnairRunArmor",0)
    if died then''',
'''    player:SetAttribute("AlnairRunArmor",Profiles.damageMitigation(player))
    if died then''')
patch('''    elseif verb=="skillChoice" then''',
'''    elseif verb=="allocateStat" then
        local ok,msg=Profiles.allocateAttribute(player,value)
        if ok then
            updatePlayerVitals(player)
        end
        notice(player,msg,ok and "success" or "warning")
    elseif verb=="skillChoice" then''')
patch('''        humanoid.MaxHealth=Profiles.maxHealth(player)
        humanoid.Health=humanoid.MaxHealth
        Profiles.ensureDraft(player)''',
'''        humanoid.MaxHealth=Profiles.maxHealth(player)
        humanoid.Health=humanoid.MaxHealth
        updatePlayerVitals(player)
        Profiles.ensureDraft(player)''')
f.write_text(s,"utf-8",newline="\n")
print("GAMEPLAY_UPDATED",len(s))
