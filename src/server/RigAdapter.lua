--!strict
-- Compatibilidade do esqueleto R15 Quaternius/Avatar Setup com Animator do Roblox.
-- Avatar Setup exporta 15 AnimationConstraints cinemáticos, enquanto o script
-- Animate do personagem jogável controla juntas Motor6D. Convertemos somente
-- a COPIA StarterCharacter, mantendo o asset original intacto.
local RigAdapter={}

local EXPECTED={
    Root=true,Waist=true,Neck=true,
    LeftShoulder=true,LeftElbow=true,LeftWrist=true,
    RightShoulder=true,RightElbow=true,RightWrist=true,
    LeftHip=true,LeftKnee=true,LeftAnkle=true,
    RightHip=true,RightKnee=true,RightAnkle=true,
}
function RigAdapter.adapt(character)
    if not character or not character:IsA("Model") then return false,0 end
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false,0 end
    humanoid.RigType=Enum.HumanoidRigType.R15
    local joints=0
    for _,instance in ipairs(character:GetDescendants()) do
        if instance:IsA("AnimationConstraint") and EXPECTED[instance.Name] then
            local attachment0=instance.Attachment0
            local attachment1=instance.Attachment1
            local part0=attachment0 and attachment0.Parent
            local part1=attachment1 and attachment1.Parent
            if part0 and part1 and part0:IsA("BasePart") and part1:IsA("BasePart") then
                local old=part0:FindFirstChild(instance.Name)
                if old and old:IsA("Motor6D") then
                    instance:Destroy()
                else
                    local motor=Instance.new("Motor6D")
                    motor.Name=instance.Name
                    motor.Part0=part0
                    motor.Part1=part1
                    motor.C0=attachment0.CFrame
                    motor.C1=attachment1.CFrame
                    motor.Parent=part0
                    instance:Destroy()
                    joints+=1
                end
            else
                warn("[ALNAIR] Joint sem anexos:",instance.Name)
            end
        elseif instance:IsA("BallSocketConstraint") then
            -- Articulacoes fisicas originais lutam contra o Animator.
            instance.Enabled=false
        end
        if instance:IsA("BasePart") then
            instance.Anchored=false
            -- Manter a colisao original importada: so HRP em CanCollide afunda o avatar.
        end
    end
    if not humanoid:FindFirstChildOfClass("Animator") then
        Instance.new("Animator").Parent=humanoid
    end
    print("[ALNAIR] R15 rig convertido:",joints,"juntas Motor6D")
    return joints==15,joints
end
return RigAdapter
