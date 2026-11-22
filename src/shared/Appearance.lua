--!strict
-- Aparência procedural: não precisa de IDs externos de roupas ou acessórios.
local Catalog = require(script.Parent.Catalog)
local MeshAccessories = require(script.Parent.MeshAccessories)
local Appearance = {}

local function find(model, names)
    for _, name in ipairs(names) do
        local p = model:FindFirstChild(name)
        if p and p:IsA("BasePart") then return p end
    end
    return nil
end

local function colorPart(item, color)
    if item and item:IsA("BasePart") then
        item.Color = color
        item.Material = Enum.Material.SmoothPlastic
    end
end

local function attach(model, target, size, transform, color, name, shape, material)
    if not target then return nil end
    local p = Instance.new(shape == "wedge" and "WedgePart" or "Part")
    p.Name = "Alnair_" .. name
    p.Size = size
    p.CFrame = target.CFrame * transform
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Massless = true
    p.CastShadow = false
    if shape == "ball" then p.Shape = Enum.PartType.Ball end
    if shape == "cylinder" then p.Shape = Enum.PartType.Cylinder end
    p.Anchored = target.Anchored
    p.Parent = model
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = target
    weld.Part1 = p
    weld.Parent = p
    return p
end

local function makeFace(head, id, race)
    local old = head:FindFirstChild("AlnairFace")
    if old then old:Destroy() end
    for _, v in ipairs(head:GetChildren()) do
        if v:IsA("Decal") and v.Face == Enum.NormalId.Front then v:Destroy() end
    end

    local gui = Instance.new("SurfaceGui")
    gui.Name = "AlnairFace"
    gui.Face = Enum.NormalId.Front
    gui.Adornee = head
    gui.CanvasSize = Vector2.new(256, 256)
    gui.LightInfluence = 0
    gui.AlwaysOnTop = false
    gui.Parent = head

    local ink = race == "undead" and Color3.fromRGB(37, 72, 61) or Color3.fromRGB(48, 44, 43)
    if race == "witch" then ink = Color3.fromRGB(57, 31, 91) end
    local function mark(x, y, w, h, c, rotation, round)
        local f = Instance.new("Frame")
        f.BorderSizePixel = 0
        f.BackgroundColor3 = c or ink
        f.Position = UDim2.fromOffset(x, y)
        f.Size = UDim2.fromOffset(w, h)
        f.Rotation = rotation or 0
        f.Parent = gui
        if round then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = f
        end
        return f
    end

    local wide = id == "shadow"
    mark(61, 85, wide and 34 or 25, 14, ink, id == "determined" and 11 or 0, true)
    mark(161, 85, wide and 34 or 25, 14, ink, id == "determined" and -11 or 0, true)
    if id == "mysterious" or id == "shadow" then
        mark(59, 70, 39, 7, ink, -8, true)
        mark(158, 70, 39, 7, ink, 8, true)
    end

    if id == "happy" then
        mark(105, 166, 45, 12, ink, 0, true)
        mark(113, 163, 30, 9, Color3.fromRGB(204, 124, 114), 0, true)
    elseif id == "determined" or id == "shadow" then
        mark(105, 160, 47, 7, ink, 0, true)
    elseif id == "mysterious" then
        mark(115, 162, 31, 7, ink, 14, true)
    else
        mark(106, 160, 45, 8, ink, 0, true)
        if id == "serene" then
            mark(108, 155, 12, 7, ink, -15, true)
            mark(136, 155, 12, 7, ink, 15, true)
        end
    end
    if id == "warrior" then
        mark(185, 72, 6, 88, Color3.fromRGB(146, 80, 70), -26, true)
        mark(177, 115, 18, 4, Color3.fromRGB(146, 80, 70), -26, true)
    end
    if race == "undead" then
        mark(83, 132, 12, 7, Color3.fromRGB(81, 115, 103), 30, true)
        mark(165, 140, 20, 5, Color3.fromRGB(81, 115, 103), -20, true)
    end
end

local function hair(model, head, style, color)
    if style == "bald" then return end
    local sx, sy, sz = head.Size.X, head.Size.Y, head.Size.Z
    local top = sy / 2
    if style == "mohawk" then
        for i = -2, 2 do
            attach(model, head, Vector3.new(.35, .5, .48), CFrame.new(0, top + .22, i*.35), color, "HairSpike", "wedge")
        end
        return
    end
    attach(model, head, Vector3.new(sx*1.06,.30,sz*1.07), CFrame.new(0,top+.09,0), color, "HairCap")
    if style == "short" then
        for i = -1, 1 do
            attach(model, head, Vector3.new(.5,.22,.32), CFrame.new(i*.55,top+.17,-sz*.36), color, "HairTuft", "wedge")
        end
    elseif style == "fringe" then
        for i = -1, 1 do
            attach(model, head, Vector3.new(.58,.55,.37), CFrame.new(i*.57,top-.19,-sz*.52), color, "HairFringe", "wedge")
        end
    elseif style == "long" then
        attach(model, head, Vector3.new(sx*.88,1.45,.36), CFrame.new(0,-.54,sz*.52), color, "HairBack")
        attach(model, head, Vector3.new(.30,1.02,.33), CFrame.new(-sx*.54,-.25,0), color, "HairSide")
        attach(model, head, Vector3.new(.30,1.02,.33), CFrame.new(sx*.54,-.25,0), color, "HairSide")
    elseif style == "bun" then
        attach(model, head, Vector3.new(.72,.72,.72), CFrame.new(0,top+.26,sz*.38), color, "HairBun", "ball")
    end
end

local function decorateClothes(model, torso, appearance, upperId, upperColor, accent)
    if not torso or not upperColor or upperId == "bare" then return end
    local plateColor = upperId == "armor" and Color3.fromRGB(159,166,175) or accent
    attach(model, torso, Vector3.new(torso.Size.X*.42,.18,.11), CFrame.new(0,torso.Size.Y*.20,-torso.Size.Z*.52), plateColor, "ChestPlate")
    attach(model, torso, Vector3.new(torso.Size.X*.68,.15,torso.Size.Z*1.07), CFrame.new(0,-torso.Size.Y*.36,0), Color3.fromRGB(56,47,39), "Belt")
    if upperId == "robe" then
        attach(model, torso, Vector3.new(.2,.26,.12), CFrame.new(0,.18,-torso.Size.Z*.55), accent, "RuneGem", "ball", Enum.Material.Neon)
    elseif upperId == "armor" then
        attach(model, torso, Vector3.new(torso.Size.X*.65,.5,.13), CFrame.new(0,0,-torso.Size.Z*.55), upperColor, "ArmorPlate")
    end
end

local function addBoots(model, character, feetId, skin)
    local option = Catalog.findOption("feet", feetId)
    if not option or feetId == "barefoot" then return end
    local left = find(character, { "Left Leg", "LeftLowerLeg", "LeftFoot" })
    local right = find(character, { "Right Leg", "RightLowerLeg", "RightFoot" })
    for _, leg in ipairs({left, right}) do
        if leg then
            local h = math.min(leg.Size.Y*.49,.65)
            attach(model, leg, Vector3.new(leg.Size.X*1.05,h,leg.Size.Z*1.1), CFrame.new(0,-leg.Size.Y/2+h/2,0), option.color or skin, "Footwear")
        end
    end
end

local STEEL = Color3.fromRGB(189,202,210)
local WOOD = Color3.fromRGB(81,55,43)
local GOLD = Color3.fromRGB(220,165,87)

local function sword(model, hand, short, katana)
    if not hand then return end
    local z = -.38
    local handleLen = short and .55 or .8
    attach(model, hand, Vector3.new(.22,handleLen,.23), CFrame.new(0,-.67,z), WOOD, "Grip")
    attach(model, hand, Vector3.new(short and .52 or .85,.14,.26), CFrame.new(0,-.25,z), GOLD, "Crossguard")
    local length = short and 1.0 or (katana and 2.15 or 1.9)
    attach(model, hand, Vector3.new(katana and .19 or .29,length,.16), CFrame.new(0,length/2-.13,z), STEEL, "Blade", "wedge", Enum.Material.Metal)
end

local function shield(model, hand)
    if not hand then return end
    attach(model, hand, Vector3.new(1.35,1.6,.22), CFrame.new(0,-.65,-.45), Color3.fromRGB(105,115,129), "Shield", nil, Enum.Material.Metal)
    attach(model, hand, Vector3.new(.33,.93,.26), CFrame.new(0,-.65,-.61), GOLD, "ShieldMark")
end

local function staff(model, hand)
    if not hand then return end
    attach(model, hand, Vector3.new(.19,3.05,.19), CFrame.new(0,.38,-.4), WOOD, "Staff", nil, Enum.Material.Wood)
    attach(model, hand, Vector3.new(.58,.58,.58), CFrame.new(0,2.03,-.4), Color3.fromRGB(102,171,239), "StaffCrystal", "ball", Enum.Material.Neon)
end

local function weapons(model, character, class)
    local right = find(character, { "RightHand", "Right Arm", "RightLowerArm" })
    local left = find(character, { "LeftHand", "Left Arm", "LeftLowerArm" })
    if class == "warrior" then
        sword(model, right, false, false)
        shield(model, left)
    elseif class == "assassin" then
        sword(model, right, true, false)
        sword(model, left, true, false)
    elseif class == "mage" then
        staff(model, right)
    elseif class == "samurai" then
        sword(model, right, false, true)
    elseif class == "fighter" then
        -- A classe Lutador não recebe arma; os punhos ficam livres.
    end
end

function Appearance.apply(character, rawSelection)
    if not character then return end
    local selection = Catalog.clean(rawSelection)
    local race = Catalog.Races[selection.race]
    local ap = selection.appearance
    local set = Catalog.findOption("set", ap.set)
    local upperId = (set and set.upper) or ap.upper
    local lowerId = (set and set.lower) or ap.lower
    local upper = Catalog.findOption("upper", upperId)
    local lower = Catalog.findOption("lower", lowerId)
    local skin = race.color
    local upperColor = upper and upper.color or skin
    local lowerColor = lower and lower.color or skin

    for _, item in ipairs(character:GetDescendants()) do
        if item.Name:sub(1,7) == "Alnair_" or item.Name == "AlnairFace" then
            item:Destroy()
        end
    end

    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
            item:Destroy()
        end
        if item:IsA("BasePart") then
            local name = item.Name:lower()
            if name == "head" or name:find("arm") or name:find("hand") then
                colorPart(item, skin)
            elseif name:find("torso") then
                colorPart(item, upperColor)
            elseif name:find("leg") or name:find("foot") then
                colorPart(item, lowerColor)
            end
        end
    end

    local head = find(character, { "Head" })
    local torso = find(character, { "Torso", "UpperTorso" })
    if head then
        makeFace(head, ap.face, selection.race)
        local hairColor = selection.race == "undead" and Color3.fromRGB(99,119,113)
            or selection.race == "witch" and Color3.fromRGB(71,54,95)
            or Color3.fromRGB(64,48,43)
        MeshAccessories.hair(character, head, ap.hair, hairColor)
        MeshAccessories.eyebrows(character, head, hairColor)
        MeshAccessories.beard(character, head, ap.beard, hairColor)
        MeshAccessories.ears(character, head, ap.ears, selection.race, skin)
        if selection.race == "witch" then
            attach(character, head, Vector3.new(.25,.22,.08), CFrame.new(0,.22,-head.Size.Z*.52), race.accent, "ArcaneMark", "ball", Enum.Material.Neon)
        end
    end
    decorateClothes(character, torso, ap, upperId, upperColor, race.accent)
    addBoots(character, character, ap.feet, skin)
    weapons(character, character, selection.class)
end

-- Um manequim clássico R6 construído localmente para o ViewportFrame da UI.
function Appearance.createPreview(parent)
    local rig = Instance.new("Model")
    rig.Name = "PreviewAvatar"
    local pieces = {
        { "Torso", Vector3.new(2,2,1), Vector3.new(0,2.8,0) },
        { "Head", Vector3.new(2,1,1), Vector3.new(0,4.4,0) },
        { "Left Arm", Vector3.new(1,2,1), Vector3.new(-1.55,2.8,0) },
        { "Right Arm", Vector3.new(1,2,1), Vector3.new(1.55,2.8,0) },
        { "Left Leg", Vector3.new(1,2,1), Vector3.new(-.53,.8,0) },
        { "Right Leg", Vector3.new(1,2,1), Vector3.new(.53,.8,0) },
    }
    for _, data in ipairs(pieces) do
        local part = Instance.new("Part")
        part.Name = data[1]
        part.Size = data[2]
        part.CFrame = CFrame.new(data[3])
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.SmoothPlastic
        part.Parent = rig
    end
    rig.Parent = parent
    return rig
end

return Appearance
