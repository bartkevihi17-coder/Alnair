--!strict
-- Visual kit imported into Roblox Studio, not primitive geometry.
-- The source meshes are Quaternius/Grab3D CC0; this module only places and scales them.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Shared=ReplicatedStorage:WaitForChild("AlnairShared")
local ArtAssets={}
local library=Shared:WaitForChild("AlnairArtV05",10)
local missing={}
local function get(category,name)
    local folder=library and library:FindFirstChild(category)
    local model=folder and folder:FindFirstChild(name)
    if model and model:IsA("Model") then return model end
    local id=tostring(category).."/"..tostring(name)
    if not missing[id] then
        missing[id]=true
        warn("[ALNAIR] Modelo nao importado:",id)
    end
    return nil
end
function ArtAssets.source(category,name)
    return get(category,name)
end
local function prepare(model)
    for _,item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Anchored=true
            item.CanCollide=false
            item.CanQuery=false
            item.CanTouch=false
            item.CastShadow=true
            item.Massless=true
        elseif item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
            item:Destroy()
        end
    end
end
function ArtAssets.place(category,name,parent,pos,targetHeight,rotation)
    local prefab=get(category,name)
    if not prefab or not parent or typeof(pos)~="Vector3" then return nil end
    local model=prefab:Clone()
    model.Name="ART_"..name
    prepare(model)
    model.Parent=parent
    local bounds=model:GetExtentsSize()
    if bounds.Y<.025 then model:Destroy();return nil end
    local height=math.clamp(targetHeight or bounds.Y,.15,170)
    local factor=math.clamp(height/bounds.Y,.02,90)
    local ok,err=pcall(function() model:ScaleTo(factor) end)
    if not ok then
        warn("[ALNAIR] Nao foi possivel ajustar escala:",name,err)
        model:Destroy()
        return nil
    end
    local boundingCF,finalSize=model:GetBoundingBox()
    local localOffset=model:GetPivot():ToObjectSpace(boundingCF)
    local wanted=CFrame.new(pos.X,pos.Y+finalSize.Y/2,pos.Z)*CFrame.Angles(0,rotation or 0,0)
    model:PivotTo(wanted*localOffset:Inverse())
    return model
end
function ArtAssets.replaceSolid(base,category,name,targetHeight,rotation)
    if not base or not base:IsA("BasePart") then return nil end
    local bottom=base.Position.Y-base.Size.Y/2
    local model=ArtAssets.place(category,name,base.Parent,
        Vector3.new(base.Position.X,bottom,base.Position.Z),targetHeight,rotation)
    if model then
        base.Transparency=1
        base.CastShadow=false
    end
    return model
end
function ArtAssets.actor(npc,kind,targetHeight)
    if not npc or not npc:IsA("Model") then return nil end
    local root=npc:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then return nil end
    local preset=get("ACTORS",kind)
    if not preset then return nil end
    local visual=preset:Clone()
    visual.Name="ImportedCreatureVisual"
    prepare(visual)
    visual.Parent=npc
    local size=visual:GetExtentsSize()
    if size.Y<=0 then visual:Destroy();return nil end
    local factor=math.clamp(targetHeight/size.Y,.1,10)
    local ok=pcall(function() visual:ScaleTo(factor) end)
    if not ok then visual:Destroy();return nil end
    local boxCF,boxSize=visual:GetBoundingBox()
    local offset=visual:GetPivot():ToObjectSpace(boxCF)
    local wanted=root.CFrame*CFrame.new(0,.2,0)
    visual:PivotTo(wanted*offset:Inverse())
    for _,piece in ipairs(npc:GetChildren()) do
        if piece:IsA("BasePart") and piece~=root then piece.Transparency=1 end
    end
    return visual
end
function ArtAssets.mount(player,kind,targetHeight)
    local character=player.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local visual=get("ACTORS",kind)
    if not visual then return nil end
    local model=visual:Clone()
    model.Name=kind=="horse" and "Cavalo 3D" or "Dragao 3D"
    prepare(model)
    model.Parent=character
    local bounds=model:GetExtentsSize()
    if bounds.Y<=0 then model:Destroy();return nil end
    local ok=pcall(function() model:ScaleTo(targetHeight/bounds.Y) end)
    if not ok then model:Destroy();return nil end
    local boxCF,boxSize=model:GetBoundingBox()
    local offset=model:GetPivot():ToObjectSpace(boxCF)
    local wanted=root.CFrame*CFrame.new(0,kind=="horse" and -2.0 or -2.35,kind=="horse" and -.6 or -1)
    model:PivotTo(wanted*offset:Inverse())
    for _,part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored=false
            part.Massless=true
            part.CanCollide=false
            local w=Instance.new("WeldConstraint")
            w.Part0=root;w.Part1=part;w.Parent=part
        end
    end
    return model
end
return ArtAssets
