--!strict
-- Visual kit imported into Roblox Studio, not primitive geometry.
-- The source meshes are Quaternius/Grab3D CC0; this module only places and scales them.
local ServerStorage=game:GetService("ServerStorage")
local ArtAssets={}
-- Keep the original CC0 prefab collection on the SERVER ONLY.
-- ReplicatedStorage is not streamed; shipping every prefab to each
-- player added unnecessary mesh memory before any scene was visible.
local library=ServerStorage:WaitForChild("AlnairArtV05",15)
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
local function prepare(model,castShadows,physicalCollision)
    for _,item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Anchored=true
            item.CanCollide=physicalCollision==true
            item.CanQuery=physicalCollision==true
            item.CanTouch=false
            item.CastShadow=(castShadows~=false)
            item.Massless=true
        elseif item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript") then
            item:Destroy()
        end
    end
end
local function isPhysicalDecoration(category,name)
    -- The older generator disabled collision on EVERY imported asset,
    -- including buildings and bridges. That allowed players to walk through
    -- stone walls or fall through elevated structures.
    if category=="FORTRESS" then return true end
    if category=="DUNGEON" then
        return name:find("Wall")~=nil or name:find("Entrance")~=nil
    end
    if category=="VILLAGE" then
        return name:find("House")~=nil or name=="Inn" or name=="Blacksmith"
            or name=="Stable" or name=="Mill" or name=="Well"
            or name=="Barrel" or name=="Crate" or name=="Cart"
            or name=="Bell_Tower" or name=="Bench_1"
    end
    return category=="NATURE" and name:find("Rock")~=nil
end
function ArtAssets.place(category,name,parent,pos,targetHeight,rotation)
    local prefab=get(category,name)
    if not prefab or not parent or typeof(pos)~="Vector3" then return nil end
    local model=prefab:Clone()
    model.Name="ART_"..name
    -- Arbustos, flores e grama nao projetam sombras: economia de GPU.
    -- Casas, arvores altas, rochas e props importantes continuam projetando.
    local smallFoliage=category=="NATURE" and (
        name:find("Grass")~=nil or name:find("Bush")~=nil or name:find("Flowers")~=nil
    )
    local physical=isPhysicalDecoration(category,name)
    prepare(model,not smallFoliage,physical)
    model.Parent=parent
    -- At full resolution nearby; allow Roblox to stream out model
    -- components at distance instead of loading the entire world upfront.
    pcall(function()
        model.LevelOfDetail=Enum.ModelLevelOfDetail.SLIM
    end)
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
    if category=="NATURE" and name:find("Tree") then
        -- An invisible trunk, not the entire convex tree canopy, is solid.
        -- One cheap collision proxy per tree makes world exploration credible.
        local treeCF,treeSize=model:GetBoundingBox()
        local radius=math.clamp(math.min(treeSize.X,treeSize.Z)*.13,.85,3.2)
        local trunk=Instance.new("Part")
        trunk.Name="TreeTrunkCollision"
        trunk.Size=Vector3.new(radius*2,treeSize.Y*.66,radius*2)
        trunk.CFrame=CFrame.new(
            treeCF.Position.X,
            pos.Y+treeSize.Y*.33,
            treeCF.Position.Z)
        trunk.Anchored=true
        trunk.Transparency=1
        trunk.CanCollide=true
        trunk.CanQuery=true
        trunk.CanTouch=false
        trunk.CastShadow=false
        trunk.Parent=model
    end
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
