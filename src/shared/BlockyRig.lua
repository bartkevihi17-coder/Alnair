--!strict
-- Alnair / Roblox NATIVE classic-blocky R15 articulated avatars.
-- Official segmented R15: wrists, elbows and knees are independent avatar joints.
-- No hand-built impostor parts, no paid body bundles.
local Players=game:GetService("Players")
local Rig={}

local function normalize(model)
    if not model or not model:IsA("Model") then return nil end
    local hum=model:FindFirstChildOfClass("Humanoid")
    local root=model:FindFirstChild("HumanoidRootPart")
    local head=model:FindFirstChild("Head")
    local upper=model:FindFirstChild("UpperTorso")
    local lower=model:FindFirstChild("LowerTorso")
    local leftHand=model:FindFirstChild("LeftHand")
    local rightHand=model:FindFirstChild("RightHand")
    local leftKnee=model:FindFirstChild("LeftLowerLeg")
    local rightKnee=model:FindFirstChild("RightLowerLeg")
    if not (hum and root and head and upper and lower and leftHand
        and rightHand and leftKnee and rightKnee) then return nil end
    if hum.RigType~=Enum.HumanoidRigType.R15 then return nil end
    for _,item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Anchored=false
            if item.Name=="HumanoidRootPart" then
                item.Transparency=1
                item.CanCollide=false
                item.CanTouch=false
                item.CanQuery=false
            end
        end
    end
    hum.AutoRotate=true
    hum.WalkSpeed=16
    hum.BreakJointsOnDeath=false
    -- Keep the official Animator, AnimationConstraints and Animate script.
    model.Name="StarterCharacter"
    model.PrimaryPart=root
    model:SetAttribute("AlnairRig","RobloxBlockyR15")
    model:SetAttribute("AlnairAvatarSource","RobloxHumanoidDescription")
    return model
end

function Rig.create(description)
    local own=description==nil
    local desc=description or Instance.new("HumanoidDescription")
    if own then
        desc.Head=0;desc.Torso=0
        desc.LeftArm=0;desc.RightArm=0
        desc.LeftLeg=0;desc.RightLeg=0
        desc.UseAvatarSettings=false
    end
    -- True Roblox blocky silhouette, with R15 articulation.
    desc.BodyTypeScale=0
    desc.ProportionScale=0
    desc.HeightScale=1
    desc.WidthScale=1
    desc.DepthScale=1
    desc.HeadScale=1
    local err="Unknown failure"
    for n=1,2 do
        local ok,model=pcall(function()
            return Players:CreateHumanoidModelFromDescriptionAsync(
                desc,Enum.HumanoidRigType.R15
            )
        end)
        if ok and model then
            local result=normalize(model)
            if result then
                if own then desc:Destroy() end
                return result
            end
            model:Destroy()
            err="Roblox returned incomplete articulated R15 rig"
        else
            err=tostring(model)
        end
        if n==1 then task.wait(.25) end
    end
    if own then desc:Destroy() end
    error("[ALNAIR] Official blocky R15 unavailable: "..err)
end

function Rig.preview(parent,description)
    local model=Rig.create(description)
    model.Name="PreviewAvatarRobloxR15"
    model.Parent=parent
    for _,item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Anchored=true
            item.CanCollide=false
            item.CanQuery=false
            item.CanTouch=false
        end
    end
    return model
end
return Rig
