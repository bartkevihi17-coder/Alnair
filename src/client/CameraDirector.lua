--!strict
-- Camera original de Alnair, orientada por conceitos de RPG em terceira pessoa.
-- Mantem a camera Roblox Custom (colisao, toque e controle nativos) e a
-- velocidade original; adiciona enquadramento suave, FOV e movimento de postura.
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local MovementPresentation = require(script.Parent:WaitForChild("MovementPresentation"))
local CameraDirector = {}

local function drift(camera, source, target, rate)
    camera.CameraType = Enum.CameraType.Scriptable
    local elapsed = 0
    local conn = RunService.RenderStepped:Connect(function(dt)
        if not camera.Parent then return end
        elapsed += math.min(dt, .05)
        local offset = Vector3.new(
            math.sin(elapsed * rate) * 2.45,
            math.sin(elapsed * rate * .6) * .54,
            math.cos(elapsed * rate * .7) * 1.15
        )
        camera.CFrame = CFrame.lookAt(source + offset, target)
    end)
    return function() conn:Disconnect() end
end

function CameraDirector.menu(camera)
    camera.FieldOfView = 54
    return drift(camera, Vector3.new(31, 18, 58), Vector3.new(0, 7, -78), .10)
end

function CameraDirector.creator(camera)
    camera.FieldOfView = 55
    return drift(camera, Vector3.new(-48, 32, 64), Vector3.new(0, 8, -26), .055)
end

function CameraDirector.explore(camera, player, humanoid)
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    camera.FieldOfView = 70
    player.CameraMinZoomDistance = 5
    player.CameraMaxZoomDistance = 17
    player.CameraMode = Enum.CameraMode.Classic
    humanoid.CameraOffset = Vector3.new(1.24, .48, 0)
    humanoid.WalkSpeed = 16

    local stopMotion = MovementPresentation.start(
        humanoid.Parent, humanoid, player:GetAttribute("AlnairClass")
    )
    local sprinting = false
    local speedTween = nil
    local clock = 0
    local function sprint(on)
        if sprinting == on or humanoid.Health <= 0 then return end
        sprinting = on
        if speedTween then speedTween:Cancel() end
        -- As regras de velocidade (16/23) continuam sendo as originais do jogo.
        speedTween = TweenService:Create(humanoid, TweenInfo.new(.24, Enum.EasingStyle.Quad), {
            WalkSpeed = on and 23 or 16
        })
        speedTween:Play()
    end

    local render = RunService.RenderStepped:Connect(function(dt)
        if not humanoid.Parent or not camera.Parent then return end
        dt = math.min(dt, .05)
        local moving = humanoid.MoveDirection.Magnitude > .12
        local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
        if moving and grounded then
            clock += dt * (sprinting and 11 or 8)
        end
        local bounce = moving and grounded and math.sin(clock * 2) * (sprinting and .055 or .032) or 0
        local sway = moving and grounded and math.sin(clock) * .035 or 0
        local shoulder = Vector3.new(1.24 + sway, .48 + bounce, 0)
        local alpha = 1 - math.exp(-dt * 8.5)
        humanoid.CameraOffset = humanoid.CameraOffset:Lerp(shoulder, alpha)
        local targetFov = sprinting and 75 or (moving and 71.5 or 70)
        camera.FieldOfView += (targetFov - camera.FieldOfView) * (1 - math.exp(-dt * 5.5))
    end)

    local down = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
            sprint(true)
        end
    end)
    local up = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
            sprint(false)
        end
    end)
    local death = humanoid.Died:Connect(function()
        sprint(false)
    end)

    return function()
        render:Disconnect()
        down:Disconnect()
        up:Disconnect()
        death:Disconnect()
        stopMotion()
        if speedTween then speedTween:Cancel() end
        if humanoid.Parent then
            humanoid.CameraOffset = Vector3.zero
            humanoid.WalkSpeed = 16
        end
    end
end

return CameraDirector
