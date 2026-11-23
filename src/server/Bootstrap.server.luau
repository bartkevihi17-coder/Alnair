--!strict
-- Porta de entrada. O cliente só escolhe; o servidor valida e cria o personagem.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local shared = ReplicatedStorage:WaitForChild("AlnairShared")
local Catalog = require(shared:WaitForChild("Catalog"))
local Appearance = require(shared:WaitForChild("Appearance"))
local RigAdapter=require(script.Parent:WaitForChild("RigAdapter"))
local World = require(script.Parent:WaitForChild("World"))

-- Menu antes do spawn; aparência padrão da conta Roblox desativada.
Players.CharacterAutoLoads = false
StarterPlayer.LoadCharacterAppearance = false

-- Avatar organico R15: importado FBX (Quaternius, CC0) e articulado via
-- Avatar Setup. StarterCharacter mantem colisao/camera/animacoes do Humanoid.
local rigSource = shared:FindFirstChild("AlnairRiggedBody")
if rigSource and rigSource:IsA("Model") then
    local starter = rigSource:Clone()
    starter.Name = "StarterCharacter"
    local adapted,count=RigAdapter.adapt(starter)
    local bodyHumanoid=starter:FindFirstChildOfClass("Humanoid")
    if bodyHumanoid then
        -- Evita que o auto scaling da Avatar Setup recalcule HipHeight negativo.
        bodyHumanoid.AutomaticScalingEnabled=false
        bodyHumanoid.HipHeight=2.67
    end
    if not adapted then
        warn("[ALNAIR] Rig R15 incompleto:",count,"juntas; verificar animacoes.")
    end
    local rootPart = starter:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart:IsA("BasePart") then
        rootPart.Anchored = false
    end
    starter.Parent = StarterPlayer
else
    warn("[ALNAIR] Avatar R15 indisponivel, mantendo personagem Roblox nativo.")
end
local world = World.create()
local spawn = world:FindFirstChild("AlnairSpawn")

local events = Instance.new("Folder")
events.Name = "AlnairRemotes"
events.Parent = ReplicatedStorage
local startEvent = Instance.new("RemoteEvent")
startEvent.Name = "StartJourney"
startEvent.Parent = events

local active = {}
local pending = {}

local function setupPlayer(player)
    player.CanLoadCharacterAppearance = false
    if spawn and spawn:IsA("SpawnLocation") then
        player.RespawnLocation = spawn
    end

    player.CharacterAdded:Connect(function(character)
        local selection = active[player]
        if not selection then return end
        task.spawn(function()
            local head = character:WaitForChild("Head", 12)
            local humanoid = character:WaitForChild("Humanoid", 12)
            if not head or not humanoid then return end
            -- Aguarda o rig clássico ou os membros do R15 concluírem o carregamento.
            character:WaitForChild("HumanoidRootPart", 8)
            task.wait(.2)
            if player.Character == character then
                Appearance.apply(character, selection)
            end
            humanoid.Died:Connect(function()
                task.wait(3)
                if player.Parent == Players and active[player] then
                    pcall(function() player:LoadCharacterAsync() end)
                end
            end)
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
    pending[player] = nil
end)

startEvent.OnServerEvent:Connect(function(player, mode, payload)
    if typeof(mode) ~= "string" or (mode ~= "campaign" and mode ~= "sandbox") then
        startEvent:FireClient(player, false, "Modo indisponível.")
        return
    end
    if active[player] or pending[player] then return end
    pending[player] = true

    -- Nenhuma escolha do cliente é usada sem validação.
    local selection = mode == "sandbox"
        and Catalog.clean({})
        or Catalog.clean(payload)
    active[player] = selection
    for _,key in ipairs(Catalog.PresetOrder) do
        player:SetAttribute("AlnairPreset_"..key,selection.appearance[key])
    end

    player:SetAttribute("AlnairMode", mode)
    player:SetAttribute("AlnairRace", selection.race)
    player:SetAttribute("AlnairClass", selection.class)

    task.spawn(function()
        local ok, err = pcall(function()
            player:LoadCharacterAsync()
        end)
        if not ok then
            active[player] = nil
            pending[player] = nil
            warn("[ALNAIR] Não foi possível criar o personagem:", err)
            if player.Parent == Players then
                startEvent:FireClient(player, false, "Falha ao iniciar o personagem. Tente novamente.")
            end
            return
        end
        pending[player] = nil
        if player.Parent == Players then
            startEvent:FireClient(player, true, mode)
        end
    end)
end)

print("[ALNAIR] Versão 0.1.0 iniciada. Mapa, menu, criação e introdução prontos.")
