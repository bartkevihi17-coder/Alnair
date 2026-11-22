--!strict
-- Malhas 3D importadas: cabelos Quaternius (CC0), orelhas Innerscene (CC0).
-- Mantemos a base classica R6; apenas acessorios sao substituidos por MeshParts reais.
local MeshAccessories = {}
local root = script.Parent:WaitForChild("AlnairMeshes")
local earsRoot = script.Parent:FindFirstChild("AlnairEarMeshes")

local HAIR_MODELS = {
    short = "Hair_Buzzed",
    fringe = "Hair_SimpleParted",
    long = "Hair_Long",
    mohawk = "Hair_BuzzedFemale",
    bun = "Hair_Buns",
    bald = nil,
}

local function getSource(modelName)
    if not modelName then return nil end
    local prefab = root:FindFirstChild(modelName)
    if not prefab and earsRoot then
        prefab = earsRoot:FindFirstChild(modelName)
    end
    if not prefab then return nil end
    return prefab:FindFirstChildWhichIsA("MeshPart", true)
end

local function attach(character, head, modelName, color, size, offset, labelName)
    local template = getSource(modelName)
    if not template then
        warn("[ALNAIR] Mesh 3D indisponivel:", tostring(modelName))
        return nil
    end
    local mesh = template:Clone()
    mesh.Name = "Alnair_" .. (labelName or modelName)
    mesh.Size = size
    mesh.Color = color
    mesh.Material = Enum.Material.SmoothPlastic
    mesh.Transparency = 0
    mesh.CanCollide = false
    mesh.CanTouch = false
    mesh.CanQuery = false
    mesh.CastShadow = false
    mesh.Massless = true
    mesh.Anchored = head.Anchored
    mesh.CFrame = head.CFrame * offset
    mesh.Parent = character
    local weld = Instance.new("WeldConstraint")
    weld.Name = "Alnair_Weld"
    weld.Part0 = head
    weld.Part1 = mesh
    weld.Parent = mesh
    return mesh
end

function MeshAccessories.hair(character, head, style, color)
    local modelName = HAIR_MODELS[style]
    if not modelName then return end
    local isLong = style == "long"
    local hasBun = style == "bun"
    local size = Vector3.new(
        head.Size.X * 1.10,
        head.Size.Y * (isLong and 1.85 or (hasBun and 1.54 or 1.20)),
        head.Size.Z * 1.44
    )
    local y = isLong and head.Size.Y * .17 or head.Size.Y * .48
    attach(character,head,modelName,color,size,CFrame.new(0,y,.06),"ImportedHair")
end

function MeshAccessories.eyebrows(character, head, color)
    local size = Vector3.new(head.Size.X*.67,head.Size.Y*.16,head.Size.Z*.18)
    attach(character,head,"Eyebrows_Regular",color,size,
        CFrame.new(0,head.Size.Y*.18,-head.Size.Z*.56),"ImportedBrows")
end

function MeshAccessories.beard(character, head, style, color)
    if style == "none" or style == nil then return end
    local typeScale = style == "trim" and .60 or 1
    local size = Vector3.new(head.Size.X*.77*typeScale,
        head.Size.Y*.72*typeScale,
        head.Size.Z*.39*typeScale)
    attach(character,head,"Hair_Beard",color,size,
        CFrame.new(0,-head.Size.Y*.40,-head.Size.Z*.60),"ImportedBeard")
end

function MeshAccessories.ears(character, head, style, race, color)
    if style == "normal" and race == "elf" then
        style = "pointed"
    end
    -- As variantes redimensionam e orientam a MESMA orelha anatomica de terceiros,
    -- sem simular geometria com Parts/Wedges. Pontuda/alongada sao variantes
    -- estilizadas; um modelo elfico especifico pode substituir estes prefabs depois.
    local settings = {
        normal = {w=.23,h=.52,d=.16,angle=2},
        small = {w=.18,h=.38,d=.14,angle=1},
        pointed = {w=.32,h=.73,d=.17,angle=20},
        long = {w=.35,h=.98,d=.18,angle=28},
    }
    local preset = settings[style] or settings.normal
    for _, side in ipairs({-1,1}) do
        local name = side == -1 and "Ear_Anatomical_Left" or "Ear_Anatomical_Right"
        local size=Vector3.new(preset.w,preset.h,preset.d)
        local offset=CFrame.new(side*(head.Size.X/2+.085),0,0)
            * CFrame.Angles(0,math.rad(10*side),math.rad(preset.angle*side))
        attach(character,head,name,color,size,offset,side == -1 and "EarLeft" or "EarRight")
    end
end

return MeshAccessories
