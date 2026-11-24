--!strict
-- Visual-only equipment from REAL, free Roblox Creator Store models.
-- Never generate swords, daggers, shields or staves with primitive Parts.
-- All combat/damage remains authoritative in AlnairGameplay/EnemyDirector.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local WeaponRender={}
local catalog={
    warrior={
        {model="Sword",hand="RightHand",length=3.55},
        {model="Shield",hand="LeftHand",length=2.45},
    },
    assassin={
        {model="Dagger",hand="RightHand",length=2.00},
        {model="Dagger",hand="LeftHand",length=2.00},
    },
    mage={
        {model="Staff",hand="RightHand",length=4.70},
    },
    fighter={},
    samurai={
        {model="Katana",hand="RightHand",length=3.60},
    },
}
local warned={}
local function template(name)
    local root=ReplicatedStorage:FindFirstChild("AlnairWeapons")
    if not root then
        if not warned.missingLibrary then
            warned.missingLibrary=true
            warn("[ALNAIR] Catalogo de armas gratuitas ainda nao embutido no Place.")
        end
        return nil
    end
    return root:FindFirstChild(name)
end

local function attachOne(character,folder,spec)
    local source=template(spec.model)
    if not source or not source:IsA("Model") then return false end
    local hand=character:FindFirstChild(spec.hand)
    if not hand or not hand:IsA("BasePart") then return false end
    local model=source:Clone()
    model.Name=spec.model.."_"..spec.hand
    model.Parent=folder
    if spec.model=="Staff" then
        local chosen=nil
        for _,v in ipairs(model:GetDescendants()) do
            if v:IsA("BasePart") then
                if not chosen or v.Size.X*v.Size.Z>chosen.Size.X*chosen.Size.Z then chosen=v end
            end
        end
        for _,v in ipairs(model:GetDescendants()) do
            if v:IsA("BasePart") and v~=chosen then v:Destroy() end
        end
    end
    local originalCF,originalSize=model:GetBoundingBox()
    local longest=math.max(originalSize.X,originalSize.Y,originalSize.Z)
    if longest<.05 then model:Destroy();return false end
    local scale=math.clamp(spec.length/longest,.035,7)
    local ok=pcall(function()model:ScaleTo(scale)end)
    if not ok then model:Destroy();return false end
    local bbox,size=model:GetBoundingBox()
    local localBox=model:GetPivot():ToObjectSpace(bbox)
    local rotate=CFrame.identity
    if originalSize.Z>originalSize.Y*1.45
        and originalSize.Z>originalSize.X then
        rotate=CFrame.Angles(-math.pi*.5,0,0)
    elseif originalSize.X>originalSize.Y*1.45
        and originalSize.X>originalSize.Z then
        rotate=CFrame.Angles(0,0,math.pi*.5)
    end
    local placement=CFrame.identity
    if spec.model=="Shield" then
        placement=CFrame.new(0,-.12,-.87)
            *CFrame.Angles(math.rad(-12),0,0)
    else
        -- Blade axis points forward from the palm, not up through the forearm.
        local side=spec.hand=="LeftHand" and -1 or 1
        local offset=spec.model=="Staff" and .85 or spec.model=="Dagger" and .58 or spec.length*.34
        placement=CFrame.new(side*.12,-.16,-offset)
            *CFrame.Angles(-math.pi*.5,0,0)
    end
    local center=hand.CFrame*placement*rotate
    if spec.model=="Sword" or spec.model=="Dagger" then
        local grip=model:FindFirstChild("Handle",true) or model:FindFirstChild("handle",true)
        local blade=model:FindFirstChild("Blade",true) or model:FindFirstChild("blade",true)
        if grip and blade then
            local axis=(blade.Position-grip.Position).Unit
            local desired=-hand.CFrame.RightVector
            local dot=math.clamp(axis:Dot(desired),-1,1)
            local cross=axis:Cross(desired)
            local rotation=cross.Magnitude>.001 and CFrame.fromAxisAngle(cross.Unit,math.acos(dot)) or (dot<0 and CFrame.fromAxisAngle(hand.CFrame.RightVector,math.pi) or CFrame.identity)
            local pivot=model:GetPivot()
            local palm=hand.CFrame:PointToWorldSpace(Vector3.new(0,-.20,-.08))
            model:PivotTo(CFrame.new(palm)*rotation*CFrame.new(-grip.Position)*pivot)
        else model:PivotTo(center*localBox:Inverse()) end
    elseif spec.model=="Staff" then
        model:PivotTo(hand.CFrame*CFrame.new(.12,.75,-.22)*localBox:Inverse())
    else model:PivotTo(center*localBox:Inverse()) end
    local pieces=0
    for _,obj in ipairs(model:GetDescendants()) do
        -- Defense-in-depth: NEVER execute any Creator Store scripts.
        if obj:IsA("LuaSourceContainer") then
            obj:Destroy()
        elseif obj:IsA("BasePart") then
            obj.Anchored=false
            obj.CanCollide=false
            obj.CanTouch=false
            obj.CanQuery=false
            obj.Massless=true
            obj.CastShadow=true
            local weld=Instance.new("WeldConstraint")
            weld.Name="AlnairGrip"
            weld.Part0=hand
            weld.Part1=obj
            weld.Parent=obj
            pieces+=1
        end
    end
    if pieces<1 then model:Destroy();return false end
    model:SetAttribute("AlnairWeaponSource","RobloxCreatorStore")
    model:SetAttribute("AlnairWeaponAssetId",source:GetAttribute("AlnairAssetId"))
    return true
end

function WeaponRender.attach(character,className)
    if not character then return 0 end
    local prev=character:FindFirstChild("AlnairEquippedWeaponModels")
    if prev then prev:Destroy() end
    local folder=Instance.new("Folder")
    folder.Name="AlnairEquippedWeaponModels"
    folder.Parent=character
    local count=0
    for _,spec in ipairs(catalog[className] or {}) do
        if attachOne(character,folder,spec) then count+=1 end
    end
    return count
end

return WeaponRender
