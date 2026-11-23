--!strict
-- Vestuario 3D: usa modelos CC0 realmente importados no Studio.
-- Nenhum bloco provisório é adicionado ao jogador R15.
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("AlnairShared")
local Catalog=require(Shared:WaitForChild("Catalog"))
local Wardrobe={}
local library=Shared:FindFirstChild("AlnairArtV05")
local function findPart(char,preferred)
    for _,n in ipairs(preferred) do
        local p=char:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    return nil
end
local function addModel(char,target,category,asset,label,height,offset,colorTint)
    local family=library and library:FindFirstChild(category)
    local template=family and family:FindFirstChild(asset)
    if not target or not template or not template:IsA("Model") then return nil end
    local model=template:Clone()
    model.Name="AlnairWear_"..label
    model.Parent=char
    for _,child in ipairs(model:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
            child:Destroy()
        elseif child:IsA("BasePart") then
            child.Anchored=true
            child.Massless=true
            child.CanCollide=false
            child.CanTouch=false
            child.CanQuery=false
            child.CastShadow=(label=="Breastplate" or label:find("Armor")~=nil)
            if colorTint then child.Color=colorTint end
        end
    end
    local size=model:GetExtentsSize()
    if size.Y<.02 then model:Destroy();return nil end
    local ok=pcall(function()
        model:ScaleTo(math.clamp(height/size.Y,.08,6))
    end)
    if not ok then model:Destroy();return nil end
    local box=model:GetBoundingBox()
    local wanted=target.CFrame*(offset or CFrame.new())
    local relative=model:GetPivot():ToObjectSpace(box)
    model:PivotTo(wanted*relative:Inverse())
    for _,piece in ipairs(model:GetDescendants()) do
        if piece:IsA("BasePart") then
            piece.Anchored=target.Anchored
            local weld=Instance.new("WeldConstraint")
            weld.Name="AlnairWearWeld"
            weld.Part0=target
            weld.Part1=piece
            weld.Parent=piece
        end
    end
    return model
end
local races={
    human={cloth=Color3.fromRGB(135,101,77),trim=Color3.fromRGB(193,145,83),boots=Color3.fromRGB(88,57,39)},
    witch={cloth=Color3.fromRGB(89,67,138),trim=Color3.fromRGB(174,117,230),boots=Color3.fromRGB(71,53,85)},
    undead={cloth=Color3.fromRGB(77,92,85),trim=Color3.fromRGB(168,146,99),boots=Color3.fromRGB(72,72,65)},
    elf={cloth=Color3.fromRGB(75,115,95),trim=Color3.fromRGB(177,190,122),boots=Color3.fromRGB(85,69,49)},
}
local classColors={
    warrior=Color3.fromRGB(139,146,153),assassin=Color3.fromRGB(57,64,78),
    mage=Color3.fromRGB(101,81,144),fighter=Color3.fromRGB(141,101,71),
    samurai=Color3.fromRGB(119,89,88)
}
local function tint(char,part,shade)
    local item=char:FindFirstChild(part)
    if item and item:IsA("BasePart") then
        item.Color=shade
        item.Material=Enum.Material.Fabric
    end
end
-- Race/class detail pieces: imported CC0 3D silhouettes plus a unique shield.
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
        addModel(character,torso,"ITEMS","Armor_Leather","HumanTravelMantle",.80,
            CFrame.new(.28,.18,.38)*CFrame.Angles(0,0,math.rad(-14)),style.cloth)
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
        addModel(character,leftArm,"ITEMS","Armor_Leather","WitchWideSleeveLeft",.74,
            CFrame.new(-.10,-.19,.06)*CFrame.Angles(0,0,math.rad(-15)),style.cloth)
        addModel(character,rightArm,"ITEMS","Armor_Leather","WitchWideSleeveRight",.74,
            CFrame.new(.10,-.19,.06)*CFrame.Angles(0,0,math.rad(15)),style.cloth)
    elseif race=="undead" then
        -- Undead: visible skeletal mesh overlay; not just green skin.
        addModel(character,torso,"DUNGEON","Bones","UndeadRibCage",1.23,
            CFrame.new(0,-.1,-.39),nil)
        addModel(character,rightArm,"DUNGEON","Bones","UndeadBoneSpikes",.62,
            CFrame.new(.22,.25,-.04),nil)
        addModel(character,head,"DUNGEON","Bones","UndeadCrown",.48,
            CFrame.new(0,head and head.Size.Y*.57 or .54,.05),nil)
        addModel(character,leftArm,"DUNGEON","Bones","UndeadLeftSpurs",.54,
            CFrame.new(-.15,.23,.04)*CFrame.Angles(0,0,math.rad(-26)),nil)
    elseif race=="elf" then
        -- Elf: real foliage meshes on both shoulders, plus long ears elsewhere.
        addModel(character,leftArm,"NATURE","Bush_1","ElvenLeftFoliage",.60,
            CFrame.new(-.23,.24,.08),nil)
        addModel(character,rightArm,"NATURE","Bush_1","ElvenRightFoliage",.60,
            CFrame.new(.23,.24,.08),nil)
        addModel(character,head,"ITEMS","Coin_Star","ElvenCirclet",.34,
            CFrame.new(0,head and head.Size.Y*.52 or .49,-.13),style.trim)
        addModel(character,torso,"NATURE","Bush_1","ElvenBackMantle",.65,
            CFrame.new(0,.20,.42),nil)
    end

    -- Class is a second independent axis. Each one adds different physical gear.
    if class=="warrior" then
        attachShield(character,leftHand)
        addModel(character,rightArm,"ITEMS","Armor_Metal","WarriorShoulderArmor",.78,
            CFrame.new(.12,.15,0),Color3.fromRGB(165,173,179))
        addModel(character,torso,"ITEMS","Armor_Metal","WarriorFrontLayer",.73,
            CFrame.new(0,.02,-.35),Color3.fromRGB(162,168,173))
    elseif class=="assassin" then
        addModel(character,leftArm,"ITEMS","Armor_Leather","AssassinLeatherLeft",.66,
            CFrame.new(-.04,.17,.05),Color3.fromRGB(45,49,57))
        addModel(character,rightArm,"ITEMS","Armor_Leather","AssassinLeatherRight",.66,
            CFrame.new(.04,.17,.05),Color3.fromRGB(45,49,57))
        addModel(character,torso,"ITEMS","Armor_Leather","AssassinCrossHarness",.72,
            CFrame.new(.09,-.01,-.28)*CFrame.Angles(0,0,math.rad(19)),Color3.fromRGB(42,43,53))
    elseif class=="mage" then
        addModel(character,leftArm,"ITEMS","Coin_Star","MageSigilLeft",.46,
            CFrame.new(-.11,.14,-.20),Color3.fromRGB(126,164,242))
        addModel(character,rightArm,"ITEMS","Coin_Star","MageSigilRight",.46,
            CFrame.new(.11,.14,-.20),Color3.fromRGB(126,164,242))
        addModel(character,torso,"ITEMS","Armor_Leather","MageRobeLayer",1.12,
            CFrame.new(0,-.16,.22),Color3.fromRGB(77,61,131))
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
        addModel(character,torso,"ITEMS","Armor_Metal","SamuraiLamellar",.86,
            CFrame.new(0,-.10,-.25)*CFrame.Angles(0,0,math.rad(-5)),Color3.fromRGB(108,65,61))
    end
end

function Wardrobe.apply(character,rawSelection,loadout)
    if not character or not character.Parent then return end
    local selection=Catalog.clean(rawSelection)
    local race=selection.race
    local class=selection.class
    local style=races[race] or races.human
    local appearance=selection.appearance or Catalog.DefaultAppearance
    local set=Catalog.findOption("set",appearance.set)
    local upperId=(set and set.upper) or appearance.upper
    local lowerId=(set and set.lower) or appearance.lower
    for _,existing in ipairs(character:GetChildren()) do
        if existing.Name:sub(1,11)=="AlnairWear_" then existing:Destroy() end
    end
    local torso=findPart(character,{"UpperTorso","Torso"})
    local left=findPart(character,{"LeftHand","Left Arm"})
    local right=findPart(character,{"RightHand","Right Arm"})
    local armorId=loadout and loadout.armor or "travel_robe"
    local tintColor=style.cloth
    local gearType="Armor_Leather"
    if armorId=="vanguard_armor" or armorId=="steel_plate" or armorId=="guardian_plate"
        or upperId=="armor" then
        gearType="Armor_Metal"
        tintColor=Color3.fromRGB(136,150,166)
    elseif armorId=="arcane_armor" or armorId=="runic_robe" or class=="mage" then
        tintColor=Color3.fromRGB(106,84,161)
    elseif class=="warrior" then
        gearType="Armor_Metal"
        tintColor=Color3.fromRGB(124,105,85)
    elseif class=="assassin" then tintColor=classColors.assassin
    elseif class=="samurai" then tintColor=classColors.samurai
    elseif race=="undead" then tintColor=style.cloth
    end
    local chosen=Catalog.findOption("upper",upperId)
    if chosen and chosen.color and upperId~="tunic" and upperId~="armor" then
        tintColor=chosen.color
    end
    -- Even a minimal outfit always has a fitted leather/tunic 3D layer.
    if torso then
        if gearType then
            addModel(character,torso,"ITEMS",gearType,"Breastplate",
                math.max(1.1,torso.Size.Y*1.16),CFrame.new(0,0,-.10),tintColor)
        end
        if race=="witch" or class=="mage" then
            addModel(character,torso,"ITEMS","Coin_Star","ArcaneInsignia",
                .56,CFrame.new(0,.20,-torso.Size.Z*.58),style.trim)
        elseif race=="elf" then
            addModel(character,torso,"ITEMS","Coin_Star","ElvenInsignia",
                .38,CFrame.new(0,.27,-torso.Size.Z*.58),style.trim)
        elseif race=="undead" then
            addModel(character,torso,"DUNGEON","Bones","BoneEmblem",
                .55,CFrame.new(.1,.35,-torso.Size.Z*.60),style.trim)
        end
    end
    local trousers=Catalog.findOption("lower",lowerId)
    local pantsColor=trousers and trousers.color or Color3.fromRGB(62,62,64)
    if lowerId=="pants" and race=="witch" then pantsColor=Color3.fromRGB(63,49,95) end
    if lowerId=="pants" and race=="elf" then pantsColor=Color3.fromRGB(59,75,64) end
    if lowerId=="pants" and race=="undead" then pantsColor=Color3.fromRGB(63,71,66) end
    for _,piece in ipairs({"LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg"}) do
        tint(character,piece,pantsColor)
    end
    local shoes=Catalog.findOption("feet",appearance.feet)
    local shoeColor=shoes and shoes.color or style.boots
    if appearance.feet~="barefoot" then
        for _,piece in ipairs({"LeftFoot","RightFoot"}) do
            tint(character,piece,shoeColor)
            local p=character:FindFirstChild(piece)
            if p and p:IsA("BasePart") then p.Material=Enum.Material.Fabric end
        end
    end
    if class=="warrior" or class=="samurai" then
        addModel(character,right,"ITEMS",class=="samurai" and "Sword_Golden" or "Sword",
            "RightBlade",class=="samurai" and 2.7 or 2.35,
            CFrame.new(0,-.90,-.2)*CFrame.Angles(0,0,math.rad(-8)),nil)
    elseif class=="assassin" then
        addModel(character,right,"ITEMS","Sword","DaggerRight",1.38,
            CFrame.new(0,-.45,-.05)*CFrame.Angles(0,0,math.rad(-12)),nil)
        addModel(character,left,"ITEMS","Sword","DaggerLeft",1.38,
            CFrame.new(0,-.45,-.05)*CFrame.Angles(0,0,math.rad(12)),nil)
    elseif class=="mage" then
        addModel(character,right,"DUNGEON","Torch","MageStaff",3.1,
            CFrame.new(0,-1.2,-.2),style.trim)
    end
    signatureGeometry(character,race,class,style)
    character:SetAttribute("AlnairOutfit",race..":"..class..":"..armorId)
end
return Wardrobe
