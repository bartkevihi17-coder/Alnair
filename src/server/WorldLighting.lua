--!strict
-- Direcao de arte original de Alnair: atmosfera RPG com efeitos moderados.
-- Em Roblox, o resultado semelhante a um shader usa Lighting + pos-processamento,
-- sem filtros externos, texturas pesadas ou loops de atualizacao por quadro.
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local WorldLighting = {}

local function getEffect(className, name)
    local existing = Lighting:FindFirstChild(name)
    if existing and not existing:IsA(className) then
        existing:Destroy()
        existing = nil
    end
    if existing then return existing end
    local effect = Instance.new(className)
    effect.Name = name
    effect.Parent = Lighting
    return effect
end

function WorldLighting.apply()
    Lighting.ClockTime = 16.35
    Lighting.Brightness = 2.45
    Lighting.ExposureCompensation = .04
    Lighting.GlobalShadows = true
    Lighting.Ambient = Color3.fromRGB(107, 112, 127)
    Lighting.OutdoorAmbient = Color3.fromRGB(156, 166, 177)
    Lighting.FogColor = Color3.fromRGB(175, 187, 197)
    Lighting.FogStart = 205
    Lighting.FogEnd = 825
    -- Compatibilidade entre versoes do motor Roblox.
    pcall(function() Lighting.Technology = Enum.Technology.ShadowMap end)
    pcall(function() Lighting.EnvironmentDiffuseScale = .65 end)
    pcall(function() Lighting.EnvironmentSpecularScale = .38 end)
    pcall(function() Workspace.GlobalWind = Vector3.new(2.5, 0, 1.4) end)

    local atmosphere = getEffect("Atmosphere", "AlnairAtmosphere")
    atmosphere.Density = .22
    atmosphere.Offset = .06
    atmosphere.Haze = 1.3
    atmosphere.Glare = .10
    atmosphere.Color = Color3.fromRGB(227, 211, 193)
    atmosphere.Decay = Color3.fromRGB(114, 134, 167)

    local color = getEffect("ColorCorrectionEffect", "AlnairColor")
    color.Brightness = .01
    color.Contrast = .12
    color.Saturation = .10
    color.TintColor = Color3.fromRGB(255, 240, 223)

    local bloom = getEffect("BloomEffect", "AlnairBloom")
    bloom.Enabled = true
    bloom.Intensity = .15
    bloom.Size = 18
    bloom.Threshold = 2.1

    local sun = getEffect("SunRaysEffect", "AlnairSunRays")
    sun.Enabled = true
    sun.Intensity = .035
    sun.Spread = .75
    -- DOF propositalmente omitido: custa GPU e compromete nitidez do combate.
end

function WorldLighting.embers(source, warm)
    if not source or not source:IsA("BasePart") then return end
    if source:FindFirstChild("AlnairEmbers") then return end
    local sparks = Instance.new("ParticleEmitter")
    sparks.Name = "AlnairEmbers"
    sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    sparks.Rate = warm and 5 or 2
    sparks.Lifetime = NumberRange.new(.65, 1.25)
    sparks.Speed = NumberRange.new(.7, 1.7)
    sparks.SpreadAngle = Vector2.new(14, 14)
    sparks.EmissionDirection = Enum.NormalId.Top
    sparks.LightEmission = .4
    sparks.Drag = 2
    sparks.Color = ColorSequence.new(
        warm and Color3.fromRGB(255, 183, 106) or Color3.fromRGB(139, 212, 250),
        warm and Color3.fromRGB(215, 85, 43) or Color3.fromRGB(62, 139, 214)
    )
    sparks.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, .14),
        NumberSequenceKeypoint.new(.55, .09),
        NumberSequenceKeypoint.new(1, 0),
    })
    sparks.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, .15),
        NumberSequenceKeypoint.new(.65, .4),
        NumberSequenceKeypoint.new(1, 1),
    })
    sparks.Parent = source
end

return WorldLighting
