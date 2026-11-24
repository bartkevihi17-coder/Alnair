from pathlib import Path
root=Path(r"C:\Users\bartk\Desktop\Alnair")
def patch(file,old,new):
    p=root/file
    s=p.read_text("utf-8")
    if old not in s:raise RuntimeError("Missing anchor "+file+" "+repr(old[:130]))
    p.write_text(s.replace(old,new,1),"utf-8",newline="\n")
    print("MOD",file)
patch("src/shared/MeshWardrobe.lua","p.Material=Enum.Material.Leather","p.Material=Enum.Material.Fabric")
patch("src/shared/Appearance.lua",'''local MeshAccessories = require(script.Parent.MeshAccessories)''',
'''local MeshAccessories = require(script.Parent.MeshAccessories)
local MeshWardrobe = require(script.Parent.MeshWardrobe)''')
patch("src/shared/Appearance.lua",'''        weapons(character, character, selection.class)
    end
end

-- Um manequim''',
'''        weapons(character, character, selection.class)
    end
    if isOrganic then MeshWardrobe.apply(character,selection,nil) end
end

-- Reaplica apenas a roupa e os equipamentos, sem apagar cabelo, rosto ou barba.
function Appearance.refreshOutfit(character,selection,equipped)
    if character and character:FindFirstChild("LeftUpperArm") then
        MeshWardrobe.apply(character,Catalog.clean(selection),equipped)
    end
end

-- Um manequim''')
patch("src/server/Bootstrap.server.luau",'''    active[player] = selection
''',
'''    active[player] = selection
    for _,key in ipairs(Catalog.PresetOrder) do
        player:SetAttribute("AlnairPreset_"..key,selection.appearance[key])
    end
''')
patch("src/server/AlnairGameplay.server.luau",'''local Rules=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("GameRules"))''',
'''local Rules=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("GameRules"))
local Shared=ReplicatedStorage:WaitForChild("AlnairShared")
local Appearance=require(Shared:WaitForChild("Appearance"))
local Catalog=require(Shared:WaitForChild("Catalog"))''')
patch("src/server/AlnairGameplay.server.luau",'''local function mountVisual(player,kind)''',
'''local function refreshOutfit(player)
    local profile=Profiles.get(player)
    local character=player.Character
    if not profile or not character then return end
    local choices={}
    for _,group in ipairs(Catalog.PresetOrder) do
        choices[group]=player:GetAttribute("AlnairPreset_"..group)
    end
    Appearance.refreshOutfit(character,{
        race=player:GetAttribute("AlnairRace"),
        class=player:GetAttribute("AlnairClass"),
        appearance=choices
    },profile.equipped)
end
local function mountVisual(player,kind)''')
patch("src/server/AlnairGameplay.server.luau",'''        if Profiles.equip(player,value) then
            updatePlayerVitals(player)
        end''',
'''        if Profiles.equip(player,value) then
            updatePlayerVitals(player)
            refreshOutfit(player)
        end''')
patch("src/server/AlnairGameplay.server.luau",'''        Profiles.ensureDraft(player)
        push(player)''',
'''        Profiles.ensureDraft(player)
        refreshOutfit(player)
        push(player)''')
