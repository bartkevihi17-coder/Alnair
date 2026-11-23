--!strict
-- Camada de expressividade procedural: nao troca nem reconfigura o Animator.
-- Combina inclinacao, respiracao e posturas distintas por classe.
local RunService = game:GetService("RunService")
local Motion = {}

local CLASS_STANCE = {
    warrior = {roll = .060, pitch = .030, idle = .010},
    assassin = {roll = .115, pitch = .065, idle = .012},
    mage = {roll = .040, pitch = .020, idle = .019},
    fighter = {roll = .130, pitch = .085, idle = .014},
    samurai = {roll = .075, pitch = .040, idle = .008},
}

function Motion.start(character, humanoid, classId)
    if not character or not humanoid then return function() end end
    local waist = character:FindFirstChild("Waist", true)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not waist or not waist:IsA("Motor6D") or not root or not root:IsA("BasePart") then
        return function() end
    end

    local baseC0 = waist.C0
    local stance = CLASS_STANCE[classId] or CLASS_STANCE.warrior
    local clock = 0
    local connection = RunService.RenderStepped:Connect(function(dt)
        if not waist.Parent or humanoid.Health <= 0 then return end
        dt = math.min(dt, .05)
        clock += dt
        local motion = root.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
        local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
        local energy = grounded and math.min(1, humanoid.MoveDirection.Magnitude) or .25
        local breathing = math.sin(clock * (energy > .5 and 7.5 or 1.65)) * stance.idle
        local pitch = -motion.Z * stance.pitch + breathing
        local roll = -motion.X * stance.roll
        local destination = baseC0 * CFrame.Angles(pitch, 0, roll)
        waist.C0 = waist.C0:Lerp(destination, math.min(1, dt * 8.5))
    end)

    return function()
        connection:Disconnect()
        if waist.Parent then waist.C0 = baseC0 end
    end
end

return Motion
