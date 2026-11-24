--!strict
-- Aparência de personagens ALNAIR com ativos REAIS do Roblox.
-- HumanoidDescription aplica rosto (Face), cabelo (HairAccessory),
-- chapéu (HatAccessory), Shirt, Pants e cores do corpo no rig NATIVO R15 BLOCKY.
-- Nunca desenhar rosto com GUI ou modelar cabelo/armadura com Parts.
local Catalog=require(script.Parent:WaitForChild("Catalog"))
local BlockyRig=require(script.Parent:WaitForChild("BlockyRig"))
local WeaponRender=require(script.Parent:WaitForChild("WeaponRender"))
local Appearance={}

local function asset(group,id,fallback)
    local found=Catalog.findOption(group,id)
    return found and found.assetId or fallback or 0
end

function Appearance.description(rawSelection,loadout)
    local choice=Catalog.clean(rawSelection)
    local ap=choice.appearance
    local race=Catalog.Races[choice.race]
    local description=Instance.new("HumanoidDescription")
    description.Name="AlnairRobloxAvatar"
    description.UseAvatarSettings=false
    -- Avatar R15 oficial articulado, com silhueta classica BLOCKY:
    description.Head=0
    description.Torso=0
    description.LeftArm=0
    description.RightArm=0
    description.LeftLeg=0
    description.RightLeg=0
    description.BodyTypeScale=0
    description.ProportionScale=0
    description.HeightScale=1
    description.WidthScale=1
    description.DepthScale=1
    description.HeadScale=1

    local set=Catalog.findOption("set",ap.set)
    local upperId=set and set.upper or ap.upper
    local lowerId=set and set.lower or ap.lower
    local shirt=asset("upper",upperId,607785314)
    local pants=asset("lower",lowerId,144076760)

    if typeof(loadout)=="table" then
        local armor=tostring(loadout.armor or loadout.chest or "")
        if armor:find("iron") or armor:find("steel") or armor:find("metal") then
            shirt=144076358
        elseif armor:find("leather") then
            shirt=398633584
        end
    end
    description.Shirt=shirt
    description.Pants=pants
    description.Face=asset("face",ap.face,7074764)

    local hairId=asset("hair",ap.hair,63690008)
    local hatStyle=ap.hat=="class" and Catalog.ClassHeadwear[choice.class]
        or ap.hat
    local hatId=asset("hat",hatStyle,0)
    -- Não colocar duas geometrias de cabelo/chapéu sem que o próprio
    -- avatar engine gerencie os Attachments e o encaixe real.
    description.HairAccessory=hairId>0 and hatStyle~="knighthelm" and hatStyle~="hood" and tostring(hairId) or ""
    description.HatAccessory=hatId>0 and tostring(hatId) or ""
    -- Cinco itens gratuitos REAIS de costas por personagem.
    -- Avatar service valida IDs e realiza attachment. Não renderizar
    -- "falsas" espadas ou mochilas de caixas.
    description.BackAccessory=""
    description.ShouldersAccessory=""
    -- SET COMPLETO DE ROUPA VOLUMÉTRICA 3D: camadas deformáveis do
    -- Roblox com WrapLayer, na ordem 1 (pernas), 2 (malha), 3 (couro).
    -- A flag false preserva os 5 BackAccessories e demais itens rígidos.
    -- Classic clothing preserves every blocky R15 body part.
    local outfits={
        warrior={71055892113200,79252076528791},
        assassin={124692451753451,81594562434031},
        mage={87030750261915,139475784344355},
        fighter={8982554536,123516625687997},
        samurai={15647400846,15647402807},
    }
    local outfit=outfits[choice.class]
    local layers={
        warrior={{107274850047755,Enum.AccessoryType.Pants},{16100249133,Enum.AccessoryType.Jacket}},
        assassin={{84360481650502,Enum.AccessoryType.Pants},{82732990077744,Enum.AccessoryType.Jacket}},
        mage={},
        fighter={{83645533605092,Enum.AccessoryType.Pants},{127231703676326,Enum.AccessoryType.DressSkirt}},
        samurai={{9038817955,Enum.AccessoryType.Jacket}},
    }
    local accessories={}
    for i,item in ipairs(layers[choice.class] or {}) do
        table.insert(accessories,{AssetId=item[1],AccessoryType=item[2],Order=i,Puffiness=0})
    end
    description:SetAccessories(accessories,false)
    if outfit then description.Shirt=outfit[1];description.Pants=outfit[2] end
    if choice.class=="warrior" then
        description.HatAccessory="2761428180"
        description.HairAccessory=""
    end
    local skin=race.color
    description.HeadColor=skin
    description.LeftArmColor=skin
    description.RightArmColor=skin
    description.TorsoColor=Color3.fromRGB(118,108,103)
    description.LeftLegColor=Color3.fromRGB(81,79,77)
    description.RightLegColor=Color3.fromRGB(81,79,77)
    return description
end

-- Organiza os CINCO acessórios oficiais para ficarem visíveis como
-- talismãs de expedição, em vez de cinco meshes grandes sobrepostas no
-- mesmo BackAttachment. A malha continua 100% original do catálogo.
local BACK_LAYOUT={
    -- Five official Roblox accessories stay equipped, but read as
    -- small travelling charms instead of giant overlapping backpacks.
    DogBackpack={x=0,y=-.12,z=.08,scale=.41},
    ["Accessory (Roblox Aura)"]={x=0,y=.16,z=.14,scale=.20},
    ["Accessory (Green_Block)"]={x=-.45,y=.27,z=.10,scale=.13},
    ["Accessory (Red_Block)"]={x=.45,y=.27,z=.10,scale=.13},
    ["Accessory (Yellow_Block)"]={x=-.45,y=-.27,z=.10,scale=.13},
    ["Accessory (Silver_Block)"]={x=.45,y=-.27,z=.10,scale=.13},
}
function Appearance.arrangeAccessories(character,selection)
    if not character then return {back=0,shoulder=0} end
    local backCount,shoulderCount=0,0
    for _,acc in ipairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle=acc:FindFirstChild("Handle")
            local weld=handle and handle:FindFirstChild("AccessoryWeld")
            if acc.AccessoryType==Enum.AccessoryType.Back then
                backCount+=1
                local cfg=BACK_LAYOUT[acc.Name]
                if cfg and handle and handle:IsA("BasePart") then
                    -- Só modificar a proporção da malha REAL, nunca gerar peça.
                    handle.Size=handle.Size*cfg.scale
                    if weld and weld:IsA("Weld")
                        and weld.Part0 and weld.Part1 then
                        local shift=CFrame.new(cfg.x,cfg.y,cfg.z)
                        if weld.Part0==handle then
                            weld.C1=shift*weld.C1
                        elseif weld.Part1==handle then
                            weld.C0=shift*weld.C0
                        end
                    end
                end
            elseif acc.AccessoryType==Enum.AccessoryType.Shoulder then
                shoulderCount+=1
            end
            -- No WorldModel o Handle ancorado pode não acompanhar o
            -- PivotTo. Recalcular pelo AccessoryWeld do próprio Roblox.
            if handle and handle:IsA("BasePart") and handle.Anchored and weld
                and weld:IsA("Weld") and weld.Part0 and weld.Part1 then
                if weld.Part0==handle then
                    handle.CFrame=weld.Part1.CFrame*weld.C1*weld.C0:Inverse()
                elseif weld.Part1==handle then
                    handle.CFrame=weld.Part0.CFrame*weld.C0*weld.C1:Inverse()
                end
            end
        end
    end
    local layeredCount=0
    local jacketCount=0
    for _,obj in ipairs(character:GetChildren())do
        if obj:IsA("Accessory") then
            local layer=obj:FindFirstChildWhichIsA("WrapLayer",true)
            if layer then
                layeredCount+=1
                if obj.AccessoryType==Enum.AccessoryType.Jacket then
                    jacketCount+=1
                end
            end
        end
    end
    character:SetAttribute("AlnairBackAccessoryCount",backCount)
    character:SetAttribute("AlnairShoulderAccessoryCount",shoulderCount)
    -- Cloth is a mesh belonging to Roblox, but Roblox's wrapping cage
    -- remains intact. The tint changes its base Color, never the mesh.
    local selectionData=Catalog.clean(selection)
    local tint=Catalog.tint3D(selectionData.class,
        selectionData.appearance.outer3d)
    if tint then
        for _,acc in ipairs(character:GetChildren()) do
            if acc:IsA("Accessory") and
                acc.AccessoryType==Enum.AccessoryType.DressSkirt then
                for _,piece in ipairs(acc:GetDescendants()) do
                    if piece:IsA("SurfaceAppearance") then
                        -- O ColorMap opaco da roupa Roblox esconde a tintura.
                        -- Retirar somente o shader externo, conservando
                        -- a malha 3D ORIGINAL, WrapLayer e encaixes Roblox.
                        piece:Destroy()
                    elseif piece:IsA("MeshPart") then
                        piece.Material=Enum.Material.Fabric
                        piece.Color=tint
                        -- As malhas gratuitas originais são vestidos curtos.
                        -- Ajuste vertical da MESMA malha para formar uma
                        -- veste comprida (mago) ou hakama (samurai).
                        local stretch=selectionData.class=="mage" and 1.55 or 1.52
                        piece.Size=Vector3.new(piece.Size.X,
                            piece.Size.Y*stretch,piece.Size.Z)
                    end
                end
            end
        end
    end
    character:SetAttribute("AlnairArmor3DLayers",layeredCount)
    character:SetAttribute("AlnairArmor3DJackets",jacketCount)
    return {back=backCount,shoulder=shoulderCount,layered=layeredCount,
        jacket=jacketCount}
end


-- Stylized 3-D robe panels are welded to native R15 torso/leg/arm bones.
-- The old free-floating layered jacket was deliberately removed for mage.
-- Each hem follows its own articulated limb (no independent physics/anchoring).
local function rigMageCoat(character)
    local folder=character:FindFirstChild("AlnairMageRiggedCoat")
    if folder then folder:Destroy() end
    local upper=character:FindFirstChild("UpperTorso")
    local waist=character:FindFirstChild("LowerTorso")
    if not upper or not waist then return end
    folder=Instance.new("Folder")
    folder.Name="AlnairMageRiggedCoat"
    folder.Parent=character
    local navy=Color3.fromRGB(43,54,117)
    local cloth=Color3.fromRGB(32,42,93)
    local gold=Color3.fromRGB(197,154,94)
    local function panel(name,body,offset,size,color)
        if not body or not body:IsA("BasePart") then return end
        local part=Instance.new("Part")
        part.Name=name
        part.Material=Enum.Material.Fabric
        part.Color=color
        part.Size=size
        part.CFrame=body.CFrame*offset
        part.Anchored=false
        part.Massless=true
        part.CanCollide=false
        part.CanTouch=false
        part.CanQuery=false
        part.CastShadow=true
        part.Parent=folder
        local weld=Instance.new("WeldConstraint")
        weld.Name="MageRobeJoint"
        weld.Part0=body
        weld.Part1=part
        weld.Parent=part
        return part
    end
    -- Open-front upper tabard, with gold piping around the neckline.
    panel("UpperCoatLeft",upper,CFrame.new(-.49,-.03,-upper.Size.Z*.5-.13),Vector3.new(.94,1.72,.19),navy)
    panel("UpperCoatRight",upper,CFrame.new(.49,-.03,-upper.Size.Z*.5-.13),Vector3.new(.94,1.72,.19),navy)
    panel("UpperCoatBack",upper,CFrame.new(0,-.08,upper.Size.Z*.5+.14),Vector3.new(1.93,1.7,.19),cloth)
    panel("GoldTrimLeft",upper,CFrame.new(-.095,.05,-upper.Size.Z*.5-.265),Vector3.new(.085,1.4,.075),gold)
    panel("GoldTrimRight",upper,CFrame.new(.095,.05,-upper.Size.Z*.5-.265),Vector3.new(.085,1.4,.075),gold)
    panel("GoldChestSigil",upper,CFrame.new(0,.31,-upper.Size.Z*.5-.29),Vector3.new(.3,.3,.08),gold)
    panel("Belt",waist,CFrame.new(0,.25,-waist.Size.Z*.5-.145),Vector3.new(1.7,.23,.22),gold)
    for _,side in ipairs({"Left","Right"}) do
        local thigh=character:FindFirstChild(side.."UpperLeg")
        local shin=character:FindFirstChild(side.."LowerLeg")
        local arm=character:FindFirstChild(side.."UpperArm")
        local forearm=character:FindFirstChild(side.."LowerArm")
        if thigh then
            panel(side.."RobeFrontThigh",thigh,CFrame.new(0,-.68,-thigh.Size.Z*.5-.16),Vector3.new(1.12,2.35,.23),navy)
            panel(side.."RobeBackThigh",thigh,CFrame.new(0,-.67,thigh.Size.Z*.5+.15),Vector3.new(1.12,2.35,.22),cloth)
            local sideDirection=side=="Left" and -1 or 1
            panel(side.."RobeSideThigh",thigh,CFrame.new(sideDirection*(thigh.Size.X*.5+.12),-.64,0),Vector3.new(.17,2.2,thigh.Size.Z+.32),navy)
            panel(side.."GoldThighHem",thigh,CFrame.new(0,-1.82,-thigh.Size.Z*.5-.30),Vector3.new(1.12,.11,.25),gold)
            panel(side.."GoldBackHem",thigh,CFrame.new(0,-1.82,thigh.Size.Z*.5+.30),Vector3.new(1.12,.11,.25),gold)
        end
        if shin then
            panel(side.."RobeShin",shin,CFrame.new(0,.03,-shin.Size.Z*.5-.15),Vector3.new(.88,1.8,.19),cloth)
            panel(side.."RobeShinHem",shin,CFrame.new(0,-.82,-shin.Size.Z*.5-.26),Vector3.new(.9,.12,.2),gold)
        end
        if arm then
            panel(side.."RobeSleeve",arm,CFrame.new(0,-.05,0),arm.Size+Vector3.new(.24,-.18,.24),navy)
        end
        if forearm then
            panel(side.."RobeCuff",forearm,CFrame.new(0,-forearm.Size.Y*.34,0),Vector3.new(forearm.Size.X+.29,.29,forearm.Size.Z+.29),gold)
        end
    end
    character:SetAttribute("AlnairMageCoatRigged",true)
end

local function removeLegacyFakeParts(character)
    -- Migracao única dos sistemas anteriores; jamais apagar acessórios
    -- reais, decal oficial 'face', Shirt, Pants ou CharacterMesh do Roblox.
    for _,item in ipairs(character:GetDescendants()) do
        if item.Name=="AlnairFace" and item:IsA("SurfaceGui") then
            item:Destroy()
        elseif item.Name:sub(1,7)=="Alnair_" and
            (item:IsA("BasePart") or item:IsA("WeldConstraint")) then
            item:Destroy()
        end
    end
end

function Appearance.apply(character,rawSelection,loadout)
    if not character then return false end
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.RigType~=Enum.HumanoidRigType.R15 then
        warn("[ALNAIR] Aparência Roblox exige Humanoid R15 blocky nativo.")
        return false
    end
    local selection=Catalog.clean(rawSelection)
    local desc=Appearance.description(selection,loadout)
    removeLegacyFakeParts(character)
    local ok,err=pcall(function()
        humanoid:ApplyDescriptionAsync(desc)
    end)
    desc:Destroy()
    if not ok then
        warn("[ALNAIR] Falha ao carregar ativos oficiais Roblox:",err)
        return false
    end
    character:SetAttribute("AlnairRaceVisual",selection.race)
    character:SetAttribute("AlnairClassVisual",selection.class)
    character:SetAttribute("AlnairRig","RobloxBlockyR15")
    character:SetAttribute("AlnairAvatarSource","RobloxHumanoidDescription")
    local extras=Appearance.arrangeAccessories(character,selection)
    if selection.class=="mage" then rigMageCoat(character) end
    if extras.back>0 then
        warn("[ALNAIR] Faltaram acessórios oficiais de costas:",
            selection.class,extras.back,"unexpected")
    end
    WeaponRender.attach(character,selection.class)
    return true
end

function Appearance.refreshOutfit(character,selection,equipped)
    return Appearance.apply(character,selection,equipped)
end

function Appearance.applyFaceControls(character,faceId)
    if not character then return false end
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.RigType~=Enum.HumanoidRigType.R15 then
        return false
    end
    local faceAsset=asset("face",faceId,7074764)
    local desc=humanoid:GetAppliedDescription()
    desc.Face=faceAsset
    local ok,err=pcall(function()
        humanoid:ApplyDescriptionAsync(desc)
    end)
    desc:Destroy()
    if not ok then warn("[ALNAIR] Rosto Roblox indisponível:",err) end
    return ok
end

function Appearance.createPreview(parent,rawSelection)
    local desc=Appearance.description(rawSelection)
    local ok,model=pcall(function()
        return BlockyRig.create(desc)
    end)
    desc:Destroy()
    if not ok then error(tostring(model)) end
    model.Name="PreviewAvatarRobloxR15"
    model:SetAttribute("AlnairAvatarSource","RobloxHumanoidDescription")
    model.Parent=parent
    for _,item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Anchored=true
            item.CanCollide=false
            item.CanQuery=false
            item.CanTouch=false
        end
    end
    -- HumanoidModelFromDescriptionAsync pode vir no ponto de spawn interno
    -- (0, 18, 22.5) mesmo dentro de um WorldModel. Trazer o avatar para
    -- a ORIGEM do estúdio de criação, nunca alterar o rig nem inventar parts.
    model:PivotTo(CFrame.new(0,2.85,0))
    Appearance.arrangeAccessories(model,Catalog.clean(rawSelection))
    local selection=Catalog.clean(rawSelection)
    if selection.class=="mage" then rigMageCoat(model) end
    WeaponRender.attach(model,selection.class)
    return model
end

return Appearance
