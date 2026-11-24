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
    Lighting.ClockTime = 15.3
    Lighting.GeographicLatitude = 36
    Lighting.Brightness = 2.25
    Lighting.ExposureCompensation = .02
    Lighting.GlobalShadows = true
    Lighting.Ambient = Color3.fromRGB(74, 82, 83)
    Lighting.OutdoorAmbient = Color3.fromRGB(124, 135, 130)
    Lighting.FogColor = Color3.fromRGB(204, 214, 222)
    Lighting.FogStart = 460
    Lighting.FogEnd = 1090
    -- Unified Lighting: tecnologia antiga removida, usar LightingStyle (Realistic) no Rojo.
    pcall(function() Lighting.LightingStyle = Enum.LightingStyle.Realistic end)
    pcall(function() Lighting.PrioritizeLightingQuality = true end)
    pcall(function() Lighting.ShadowSoftness = .29 end)
    pcall(function() Lighting.EnvironmentDiffuseScale = .72 end)
    pcall(function() Lighting.EnvironmentSpecularScale = .48 end)
    pcall(function() Workspace.GlobalWind = Vector3.new(4.6, 0, 2.2) end)

    local atmosphere = getEffect("Atmosphere", "AlnairAtmosphere")
    atmosphere.Density = .21
    atmosphere.Offset = .12
    atmosphere.Haze = .78
    atmosphere.Glare = .10
    atmosphere.Color = Color3.fromRGB(227, 225, 212)
    atmosphere.Decay = Color3.fromRGB(172, 184, 178)

    -- A Sky usa os astros nativos e o gradiente atmosférico do motor.
    -- Não criar céu artificial com Partes; Clouds do Terrain tem volume e vento.
    local sky = getEffect("Sky", "AlnairNaturalSky")
    sky.CelestialBodiesShown = true
    sky.SunAngularSize = 10
    sky.MoonAngularSize = 9
    sky.StarCount = 1300

    local color = getEffect("ColorCorrectionEffect", "AlnairColor")
    color.Brightness = .00
    color.Contrast = .11
    color.Saturation = .08
    color.TintColor = Color3.fromRGB(255, 250, 238)

    local bloom = getEffect("BloomEffect", "AlnairBloom")
    bloom.Enabled = true
    bloom.Intensity = .15
    bloom.Size = 22
    bloom.Threshold = 1.95

    local sun = getEffect("SunRaysEffect", "AlnairSunRays")
    sun.Enabled = true
    sun.Intensity = .09
    sun.Spread = .53
    -- Nuvens leves (uma instancia, sem loops por frame) para quebrar o ceu vazio.
    pcall(function()
        local terrain = Workspace.Terrain
        local clouds = terrain:FindFirstChild("AlnairClouds")
        if not clouds then
            clouds = Instance.new("Clouds")
            clouds.Name = "AlnairClouds"
            clouds.Parent = terrain
        end
        clouds.Enabled = true
        clouds.Cover = .37
        clouds.Density = .43
        clouds.Color = Color3.fromRGB(247, 245, 242)
    end)
    -- Nao aplicar DOF nem Blur: manter a primeira pessoa nítida no gameplay.
    -- Efeitos limitados a Atmosphere + ColorCorrection + Bloom + SunRays.
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
