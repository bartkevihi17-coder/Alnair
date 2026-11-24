from pathlib import Path
root=Path(r"C:\Users\bartk\Desktop\Alnair")
p=root/"src/shared/MeshWardrobe.lua"
s=p.read_text("utf-8")
assert "local function attachShield" not in s
anchor="function Wardrobe.apply(character,rawSelection,loadout)"
assert s.count(anchor)==1
addition=r'''-- Race/class detail pieces: imported CC0 3D silhouettes plus a unique shield.
-- These are distinct GEOMETRIES, not recolored copies of the same outfit.
local function attachShield(character, hand)
    if not hand then return end
    local shieldCF = hand.CFrame * CFrame.new(-.08,-.52,-.57) * CFrame.Angles(0,math.rad(-8),math.rad(8))
    local function panel(name,size,offset,material,color,shape)
        local part=Instance.new(shape or "Part")
        part.Name="AlnairWear_"..name
        part.Size=size
        part.CFrame=shieldCF*offset
        part.Material=material
        part.Color=color
        part.Anchored=hand.Anchored
        part.CanCollide=false
        part.CanQuery=false
        part.CanTouch=false
        part.Massless=true
        part.Parent=character
        local weld=Instance.new("WeldConstraint")
        weld.Part0=hand
        weld.Part1=part
        weld.Parent=part
        return part
    end
    local steel=Color3.fromRGB(145,159,171)
    panel("ShieldCore",Vector3.new(1.28,1.52,.16),CFrame.new(),Enum.Material.Wood,Color3.fromRGB(86,57,44))
    panel("ShieldUpperRim",Vector3.new(1.38,.17,.24),CFrame.new(0,.66,0),Enum.Material.Metal,steel)
    panel("ShieldLowerTip",Vector3.new(1.14,.38,.18),CFrame.new(0,-.82,0)*CFrame.Angles(0,0,math.rad(180)),Enum.Material.Metal,steel,"WedgePart")
    panel("ShieldSpine",Vector3.new(.17,1.55,.26),CFrame.new(0,0,-.065),Enum.Material.Metal,steel)
    addModel(character,hand,"ITEMS","Coin_Star","ShieldHeraldry",.43,
        CFrame.new(-.08,-.52,-.78),Color3.fromRGB(219,178,102))
end

local function signatureGeometry(character,race,class,style)
    local head=findPart(character,{"Head"})
    local torso=findPart(character,{"UpperTorso","Torso"})
    local leftArm=findPart(character,{"LeftUpperArm","Left Arm"})
    local rightArm=findPart(character,{"RightUpperArm","Right Arm"})
    local leftHand=findPart(character,{"LeftHand","Left Arm"})
    local rightHand=findPart(character,{"RightHand","Right Arm"})
    if race=="human" then
        -- Human: compact knight epaulette, an actual metal mesh.
        addModel(character,leftArm,"ITEMS","Armor_Metal","HumanPauldron",.66,
            CFrame.new(-.08,.22,.02),Color3.fromRGB(147,153,156))
    elseif race=="witch" then
        -- Witch: tall ritual headdress and layered robe, distinct cranial outline.
        addModel(character,head,"ITEMS","Coin_Star","WitchCrownFront",.51,
            CFrame.new(0,head and head.Size.Y*.49 or .5,-.14),style.trim)
        addModel(character,head,"ITEMS","Coin_Star","WitchCrownLeft",.30,
            CFrame.new(-.30,head and head.Size.Y*.56 or .51,-.02)*CFrame.Angles(0,0,math.rad(-28)),style.trim)
        addModel(character,head,"ITEMS","Coin_Star","WitchCrownRight",.30,
            CFrame.new(.30,head and head.Size.Y*.56 or .51,-.02)*CFrame.Angles(0,0,math.rad(28)),style.trim)
        addModel(character,torso,"ITEMS","Armor_Leather","WitchLayeredMantle",1.55,
            CFrame.new(0,-.55,.26),Color3.fromRGB(76,54,116))
    elseif race=="undead" then
        -- Undead: visible skeletal mesh overlay; not just green skin.
        addModel(character,torso,"DUNGEON","Bones","UndeadRibCage",1.23,
            CFrame.new(0,-.1,-.39),nil)
        addModel(character,rightArm,"DUNGEON","Bones","UndeadBoneSpikes",.62,
            CFrame.new(.22,.25,-.04),nil)
        addModel(character,head,"DUNGEON","Bones","UndeadCrown",.48,
            CFrame.new(0,head and head.Size.Y*.57 or .54,.05),nil)
    elseif race=="elf" then
        -- Elf: real foliage meshes on both shoulders, plus long ears elsewhere.
        addModel(character,leftArm,"NATURE","Bush_1","ElvenLeftFoliage",.60,
            CFrame.new(-.23,.24,.08),nil)
        addModel(character,rightArm,"NATURE","Bush_1","ElvenRightFoliage",.60,
            CFrame.new(.23,.24,.08),nil)
        addModel(character,head,"ITEMS","Coin_Star","ElvenCirclet",.34,
            CFrame.new(0,head and head.Size.Y*.52 or .49,-.13),style.trim)
    end

    -- Class is a second independent axis. Each one adds different physical gear.
    if class=="warrior" then
        attachShield(character,leftHand)
        addModel(character,rightArm,"ITEMS","Armor_Metal","WarriorShoulderArmor",.78,
            CFrame.new(.12,.15,0),Color3.fromRGB(165,173,179))
    elseif class=="assassin" then
        addModel(character,leftArm,"ITEMS","Armor_Leather","AssassinLeatherLeft",.66,
            CFrame.new(-.04,.17,.05),Color3.fromRGB(45,49,57))
        addModel(character,rightArm,"ITEMS","Armor_Leather","AssassinLeatherRight",.66,
            CFrame.new(.04,.17,.05),Color3.fromRGB(45,49,57))
    elseif class=="mage" then
        addModel(character,leftArm,"ITEMS","Coin_Star","MageSigilLeft",.46,
            CFrame.new(-.11,.14,-.20),Color3.fromRGB(126,164,242))
        addModel(character,rightArm,"ITEMS","Coin_Star","MageSigilRight",.46,
            CFrame.new(.11,.14,-.20),Color3.fromRGB(126,164,242))
    elseif class=="fighter" then
        addModel(character,leftHand,"ITEMS","Armor_Metal","FighterGauntletL",.48,
            CFrame.new(0,-.08,-.04),Color3.fromRGB(161,112,77))
        addModel(character,rightHand,"ITEMS","Armor_Metal","FighterGauntletR",.48,
            CFrame.new(0,-.08,-.04),Color3.fromRGB(161,112,77))
        addModel(character,torso,"ITEMS","Armor_Leather","FighterHarness",.94,
            CFrame.new(0,.22,-.12),Color3.fromRGB(109,70,51))
    elseif class=="samurai" then
        addModel(character,leftArm,"ITEMS","Armor_Metal","SamuraiSingleSode",.89,
            CFrame.new(-.12,.08,.03),Color3.fromRGB(108,48,48))
        addModel(character,torso,"ITEMS","Coin_Star","SamuraiClanMon",.35,
            CFrame.new(0,.30,-.54),Color3.fromRGB(214,166,101))
    end
end

'''
s=s.replace(anchor,addition+anchor,1)
s=s.replace('''    if upperId=="bare" and armorId=="travel_robe" then
        gearType=nil
    end
''','''    -- Even a minimal outfit always has a fitted leather/tunic 3D layer.
''')
anchor='''    character:SetAttribute("AlnairOutfit",race..":"..class..":"..armorId)'''
assert s.count(anchor)==1
s=s.replace(anchor,'''    signatureGeometry(character,race,class,style)
'''+anchor,1)
p.write_text(s,"utf-8",newline="\n")
catalog=root/"src/shared/Catalog.lua"
s=catalog.read_text("utf-8")
assert 'name = "Bruxo"' in s
s=s.replace('name = "Bruxo"','name = "Bruxa"',1)
s=s.replace('name = "Sem camisa"','name = "Túnica simples"',1)
catalog.write_text(s,"utf-8",newline="\n")
print("PATCHED 3D SILHOUETTES + WARRIOR SHIELD + BRUXA + NO NAKED OUTFIT")
