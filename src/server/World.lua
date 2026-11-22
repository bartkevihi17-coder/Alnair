--!strict
-- Cenário inicial gerado no servidor. É um protótipo de exploração, não o mapa final.
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local World = {}
local rng = Random.new(1479)

local function part(parent, name, size, cf, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function makeLamp(parent, pos, height)
    part(parent, "Pilar da chama", Vector3.new(.7,height,.7),
        CFrame.new(pos.X,height/2,pos.Z), Color3.fromRGB(71,63,64), Enum.Material.Slate)
    local flame = part(parent, "Luz etérea", Vector3.new(.55,.85,.55),
        CFrame.new(pos.X,height+.3,pos.Z), Color3.fromRGB(117,190,247), Enum.Material.Neon, Enum.PartType.Ball)
    flame.CanCollide = false
    local glow = Instance.new("PointLight")
    glow.Color = Color3.fromRGB(109,182,251)
    glow.Brightness = 1.2
    glow.Range = 23
    glow.Shadows = false
    glow.Parent = flame
end

local function createTree(parent, x, z, size, variation)
    local wood = Color3.fromRGB(66,58,51)
    local leaf = variation == 1 and Color3.fromRGB(48,96,90)
        or variation == 2 and Color3.fromRGB(66,109,91)
        or Color3.fromRGB(88,102,115)
    part(parent, "Tronco", Vector3.new(1.3*size,7*size,1.3*size),
        CFrame.new(x,3.5*size,z), wood, Enum.Material.Wood)
    for _, t in ipairs({
        {0,8.6,0,5.8},
        {-2.2,7.2,.7,4.2},
        {2,7.5,.2,4.5},
        {.2,7.6,-2,4.0},
    }) do
        local leafPart = part(parent, "Copa", Vector3.new(t[4]*size,t[4]*.8*size,t[4]*size),
            CFrame.new(x+t[1]*size,t[2]*size,z+t[3]*size), leaf, Enum.Material.Grass, Enum.PartType.Ball)
        leafPart.CanCollide = false
    end
end

local function setupLighting()
    Lighting.ClockTime = 17.6
    Lighting.Brightness = 2.2
    Lighting.Ambient = Color3.fromRGB(94,93,117)
    Lighting.OutdoorAmbient = Color3.fromRGB(112,119,135)
    Lighting.FogColor = Color3.fromRGB(121,139,156)
    Lighting.FogStart = 100
    Lighting.FogEnd = 510
    Lighting.GlobalShadows = true

    local atmosphere = Lighting:FindFirstChild("AlnairAtmosphere") or Instance.new("Atmosphere")
    atmosphere.Name = "AlnairAtmosphere"
    atmosphere.Density = .29
    atmosphere.Haze = 1.7
    atmosphere.Glare = .12
    atmosphere.Color = Color3.fromRGB(195,190,209)
    atmosphere.Decay = Color3.fromRGB(77,103,133)
    atmosphere.Parent = Lighting

    local bloom = Lighting:FindFirstChild("AlnairBloom") or Instance.new("BloomEffect")
    bloom.Name = "AlnairBloom"
    bloom.Intensity = .32
    bloom.Size = 25
    bloom.Threshold = 1.7
    bloom.Parent = Lighting

    local color = Lighting:FindFirstChild("AlnairColor") or Instance.new("ColorCorrectionEffect")
    color.Name = "AlnairColor"
    color.Contrast = .11
    color.Saturation = -.08
    color.TintColor = Color3.fromRGB(222,225,245)
    color.Parent = Lighting
end

function World.create()
    local existing = Workspace:FindFirstChild("AlnairWorld")
    if existing then return existing end
    setupLighting()

    local world = Instance.new("Folder")
    world.Name = "AlnairWorld"
    world.Parent = Workspace

    part(world, "Terras de Alnair", Vector3.new(650,3,650),
        CFrame.new(0,-1.7,0), Color3.fromRGB(66,94,83), Enum.Material.Grass)

    -- Caminho de pedra: do antigo portão até a praça central.
    for i = 0, 26 do
        local z = -122 + i*5
        local x = math.sin(i*.27)*2.5
        part(world, "Trilha de pedras", Vector3.new(rng:NextNumber(3.5,5),.15,rng:NextNumber(3.1,4.8)),
            CFrame.new(x,.01,z)*CFrame.Angles(0,rng:NextNumber(-.24,.24),0),
            Color3.fromRGB(111,119,123), Enum.Material.Slate)
    end

    -- Praça segura para o início de jogo.
    part(world, "Praça do Primeiro Fogo", Vector3.new(54,.8,54),
        CFrame.new(0,.0,0), Color3.fromRGB(101,105,112), Enum.Material.Cobblestone)
    part(world, "Pedestal central", Vector3.new(10,1.1,10),
        CFrame.new(0,.9,-8), Color3.fromRGB(66,74,89), Enum.Material.Slate)
    local symbol = part(world, "Estrela de Alnair", Vector3.new(3.2,.25,3.2),
        CFrame.new(0,1.6,-8)*CFrame.Angles(0,math.rad(45),0),
        Color3.fromRGB(124,194,225), Enum.Material.Neon)
    symbol.CanCollide = false

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "AlnairSpawn"
    spawn.Size = Vector3.new(7,.5,7)
    spawn.CFrame = CFrame.new(0,.78,12)
    spawn.Transparency = 1
    spawn.Anchored = true
    spawn.CanCollide = false
    spawn.Neutral = true
    spawn.Duration = 0
    spawn.Parent = world

    -- Ruínas e portão ao norte da trilha.
    local ruinColor = Color3.fromRGB(102,109,116)
    for _, x in ipairs({-13,13}) do
        part(world, "Coluna do portão", Vector3.new(4,20,4),
            CFrame.new(x,10,-127), ruinColor, Enum.Material.Slate)
        part(world, "Fundação da coluna", Vector3.new(6,2,6),
            CFrame.new(x,1,-127), Color3.fromRGB(76,84,89), Enum.Material.Cobblestone)
        part(world, "Arco partido", Vector3.new(5,3,4),
            CFrame.new(x*0.57,20,-127), ruinColor, Enum.Material.Slate)
    end
    part(world, "Lintel antigo", Vector3.new(28,3.5,4.5),
        CFrame.new(0,21.9,-127), ruinColor, Enum.Material.Slate)
    for _, p in ipairs({
        Vector3.new(-22,0,-83),Vector3.new(23,0,-78),Vector3.new(-26,0,16),
        Vector3.new(28,0,18),Vector3.new(-32,0,-125),Vector3.new(33,0,-134),
    }) do
        local h = rng:NextNumber(5,12)
        part(world, "Ruína esquecida", Vector3.new(rng:NextNumber(2.4,4),h,rng:NextNumber(2,3.8)),
            CFrame.new(p.X,h/2,p.Z)*CFrame.Angles(0,rng:NextNumber(-.19,.19),.06),
            ruinColor, Enum.Material.Slate)
    end

    -- Fogueira de descanso e lanternas azuladas.
    part(world, "Círculo do acampamento", Vector3.new(10,.4,10),
        CFrame.new(15,.23,13), Color3.fromRGB(71,72,72), Enum.Material.Slate)
    for i = 0, 5 do
        local a = i*math.pi/3
        part(world, "Pedra da fogueira", Vector3.new(1.4,.9,1.1),
            CFrame.new(15+math.cos(a)*2.1,.7,13+math.sin(a)*2.1),
            Color3.fromRGB(105,100,100), Enum.Material.Rock)
    end
    local fire = part(world, "Fogo do viajante", Vector3.new(1.5,2.8,1.5),
        CFrame.new(15,1.7,13), Color3.fromRGB(241,157,86), Enum.Material.Neon, Enum.PartType.Ball)
    fire.CanCollide = false
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255,174,91)
    light.Brightness = 2
    light.Range = 25
    light.Parent = fire
    makeLamp(world, Vector3.new(-20,0,-16), 7)
    makeLamp(world, Vector3.new(20,0,-16), 7)
    makeLamp(world, Vector3.new(-13,0,-114), 5)
    makeLamp(world, Vector3.new(13,0,-114), 5)

    -- Bosque espalhado; área de spawn livre.
    for i = 1, 86 do
        local x = rng:NextNumber(-270,270)
        local z = rng:NextNumber(-270,270)
        if math.abs(x) > 45 or math.abs(z) > 145 then
            createTree(world, x,z,rng:NextNumber(.75,1.62),rng:NextInteger(1,3))
        end
    end

    -- Pedras e montes baixos nos limites.
    for i = 1, 42 do
        local x = rng:NextNumber(-290,290)
        local z = rng:NextNumber(-290,290)
        if x*x+z*z > 70*70 then
            local radius = rng:NextNumber(3,12)
            part(world, "Pedra musgosa", Vector3.new(radius,radius*.65,radius*.8),
                CFrame.new(x,radius*.18,z), Color3.fromRGB(80,92,92), Enum.Material.Rock, Enum.PartType.Ball)
        end
    end

    return world
end

return World
