--!strict
-- IA autoritativa de criaturas: ronda, investiga, persegue, recua e guarda memoria.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local Rules=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("GameRules"))
local EnemyDirector={}
local ArtAssets=require(script.Parent:WaitForChild("ArtAssets"))
local rng=Random.new(74332)
local living={}
local enemyFolder=nil
local onKill=function(_player,_record) end
local cap=80
local counter=0
local tickCount=0
local maxNPC=0

local function part(parent,name,size,cf,color,material,shape)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    if shape then p.Shape=shape end
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
    p.Parent=parent
    return p
end
local function label(record)
    local root=record.model
    local head=root:FindFirstChild("Head")
    if not head then return end
    local gui=Instance.new("BillboardGui")
    gui.Name="RivalName";gui.Size=UDim2.fromOffset(180,49)
    gui.StudsOffset=Vector3.new(0,3.2,0)
    gui.AlwaysOnTop=true;gui.MaxDistance=85;gui.Parent=head
    local name=Instance.new("TextLabel")
    name.BackgroundTransparency=1;name.Size=UDim2.fromScale(1,.60)
    name.Text=record.title;name.TextColor3=Color3.fromRGB(241,217,174)
    name.TextStrokeTransparency=.1;name.Font=Enum.Font.GothamBold;name.TextScaled=true;name.Parent=gui
    local bg=Instance.new("Frame")
    bg.BorderSizePixel=0;bg.Size=UDim2.fromScale(.83,.13)
    bg.Position=UDim2.fromScale(.09,.74)
    bg.BackgroundColor3=Color3.fromRGB(40,35,39);bg.Parent=gui
    local bar=Instance.new("Frame")
    bar.Name="Health";bar.BorderSizePixel=0;bar.Size=UDim2.fromScale(1,1)
    bar.BackgroundColor3=Color3.fromRGB(199,79,82);bar.Parent=bg
    record.healthBar=bar
end
local function visual(kind,center,level,health,rank)
    local info=Rules.Enemies[kind]
    local model=Instance.new("Model")
    model.Name=info.name.." [Nv."..level.."]"
    model:SetAttribute("AlnairEnemyKind",kind)
    model:SetAttribute("AlnairEnemyLevel",level)
    model:SetAttribute("AlnairEnemyRank",rank)
    local scale=kind=="dragon" and 2.25 or kind=="warden" and 1.32 or 1
    local skin=info.color
    local root=part(model,"HumanoidRootPart",Vector3.new(2,2,2),CFrame.new(center),skin)
    root.Transparency=1
    model.PrimaryPart=root
    local chest=part(model,"Chest",Vector3.new(2.1,2.6,1.3)*scale,
        CFrame.new(center+Vector3.new(0,.1,0)),skin)
    part(model,"Head",Vector3.new(1.55,1.5,1.4)*scale,
        CFrame.new(center+Vector3.new(0,2.05*scale,0)),skin,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    for _,side in ipairs({-1,1}) do
        part(model,"Arm",Vector3.new(.65,2.2,.75)*scale,
            CFrame.new(center+Vector3.new(side*1.42*scale,-.08,0)),
            skin)
        part(model,"Leg",Vector3.new(.79,2,.82)*scale,
            CFrame.new(center+Vector3.new(side*.55*scale,-1.88*scale,0)),
            kind=="skeleton" and skin or Color3.fromRGB(49,52,59))
        if kind=="orc" then
            part(model,"Presa",Vector3.new(.27,.53,.27)*scale,
                CFrame.new(center+Vector3.new(side*.45*scale,1.76*scale,-.73*scale)),
                Color3.fromRGB(234,228,191))
        elseif kind=="dragon" then
            part(model,"Asa",Vector3.new(3.2,.38,4.7)*scale,
                CFrame.new(center+Vector3.new(side*2.2*scale,1.2*scale,1))
                    *CFrame.Angles(0,side*.35,side*.30),
                Color3.fromRGB(91,50,52),Enum.Material.SmoothPlastic)
        end
    end
    if kind=="skeleton" then
        for i=-1,1 do
            part(model,"Costela",Vector3.new(1.7,.14,.3),
                CFrame.new(center+Vector3.new(0,i*.47,-.70)),
                Color3.fromRGB(241,240,222))
        end
    elseif kind=="witch" then
        part(model,"Chapeu",Vector3.new(2.6,.20,2.6),
            CFrame.new(center+Vector3.new(0,2.90,0)),
            Color3.fromRGB(50,40,73),Enum.Material.Fabric,Enum.PartType.Cylinder)
        part(model,"Chapeu Ponta",Vector3.new(.75,1.35,.75),
            CFrame.new(center+Vector3.new(0,3.58,0)),
            Color3.fromRGB(60,43,89))
    elseif kind=="warden" then
        part(model,"Armadura do Vigia",Vector3.new(2.5,2.2,1.6),
            CFrame.new(center+Vector3.new(0,.1,-.05)),Color3.fromRGB(52,70,83),Enum.Material.Metal)
    end
    for _,side in ipairs({-.37,.37}) do
        local eye=part(model,"Olho",Vector3.new(.25,.20,.19)*scale,
            CFrame.new(center+Vector3.new(side*scale,2.17*scale,-.69*scale)),
            kind=="skeleton" and Color3.fromRGB(69,209,237) or Color3.fromRGB(225,104,87),
            Enum.Material.Neon,Enum.PartType.Ball)
        eye.CanQuery=false
    end
    local hum=Instance.new("Humanoid")
    hum.Name="Humanoid";hum.BreakJointsOnDeath=false
    hum.RequiresNeck=false;hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    hum.MaxHealth=health;hum.Health=health;hum.WalkSpeed=0
    hum.Parent=model
    model.PrimaryPart=root
    local presetFolder=ReplicatedStorage:FindFirstChild("AlnairShared")
    local assetFolder=presetFolder and presetFolder:FindFirstChild("EnemyMeshes")
    if assetFolder then
        local prefab=assetFolder:FindFirstChild(kind)
        if prefab and prefab:IsA("MeshPart") then
            local visualMesh=prefab:Clone()
            visualMesh.Name="ImportedCreatureMesh"
            visualMesh.Size=Vector3.new(3,5,2.8)*scale
            visualMesh.CFrame=root.CFrame
            visualMesh.Anchored=true
            visualMesh.CanCollide=false
            visualMesh.Parent=model
            for _,partIn in ipairs(model:GetChildren()) do
                if partIn:IsA("BasePart") and partIn~=root and partIn~=visualMesh then partIn.Transparency=1 end
            end
        end
    end
    return model,hum
end

function EnemyDirector.setOnKill(fn)onKill=fn end
function EnemyDirector.get() return living end
function EnemyDirector.count(owner)
    local count=0
    for _,r in pairs(living) do
        if r.owner==owner then count+=1 end
    end
    return count
end

function EnemyDirector.spawn(kind,pos,options)
    if not Rules.Enemies[kind] or typeof(pos)~="Vector3" or typeof(options)~="table" then return nil end
    if maxNPC>=cap then return nil end
    local data=Rules.Enemies[kind]
    counter+=1
    local lvl=math.clamp(math.floor(options.level or data.level),1,100)
    local hp=math.floor(data.hp*(1+(lvl-data.level)*.16)*(1+(options.wave or 0)*.095))
    local rank=options.rank or 0
    local npc,hum=visual(kind,pos,lvl,hp,rank)
    npc.Name=data.name.."_"..counter
    local title=rank>0 and ("Capitao "..data.name.." • "..rank) or (data.name.." • Nv. "..lvl)
    local record={
        id=counter,kind=kind,model=npc,hum=hum,owner=options.owner,level=lvl,
        pos=pos,origin=pos,rank=rank,title=title,health=hp,base=data,
        xp=math.floor(data.xp*(1+.2*(lvl-data.level))),gold=math.floor(data.gold*(1+.11*(lvl-data.level))),
        behavior="patrol",lastAction=0,nextWander=0,attackAt=0,dead=false,
        lastHitter=nil,locked=nil,spawnTag=options.spawnTag,arena=options.arena,
        motionPieces={},wanderPhase=rng:NextNumber(0,math.pi*2),
    }
    npc.Parent=enemyFolder
    -- Malhas reais importadas pelo 3D Importer: preserve hitboxes invisiveis.
    local imported=ArtAssets.actor(npc,kind,kind=="dragon" and 11 or kind=="warden" and 7.5 or 5.1)
    local rootCFrame=npc:GetPivot()
    for _,bodyPart in ipairs(npc:GetDescendants()) do
        if bodyPart:IsA("BasePart") and bodyPart.Name~="HumanoidRootPart" then
            if bodyPart.Name=="Arm" or bodyPart.Name=="Leg" or bodyPart.Name=="Head" or bodyPart.Name=="Asa" then
                table.insert(record.motionPieces,{bodyPart=bodyPart,base=rootCFrame:ToObjectSpace(bodyPart.CFrame)})
            end
        end
    end
    living[npc]=record
    maxNPC+=1
    label(record)
    return record
end

local function removeRecord(record, killer)
    if record.dead then return end
    record.dead=true
    local npc=record.model
    living[npc]=nil;maxNPC=math.max(0,maxNPC-1)
    if killer and killer.Parent==Players then
        onKill(killer,record)
    end
    task.delay(.8,function()
        if npc and npc.Parent then npc:Destroy() end
    end)
    if record.spawnTag and record.owner==nil then
        task.delay(25+rng:NextInteger(0,15),function()
            if enemyFolder and enemyFolder.Parent then
                EnemyDirector.spawn(record.kind,record.origin,{level=record.level,rank=record.rank,spawnTag=record.spawnTag})
            end
        end)
    end
end
function EnemyDirector.damage(record,player,damage)
    if not record or record.dead or record.hum.Health<=0 then return false end
    if record.owner and record.owner~=player then return false end
    local diff=record.pos-(player.Character and player.Character:GetPivot().Position or Vector3.zero)
    if diff.Magnitude>100 then return false end
    local dmg=math.clamp(math.floor(damage),1,800)
    record.lastHitter=player
    record.hum:TakeDamage(dmg)
    record.healthBar.Size=UDim2.fromScale(math.max(0,record.hum.Health/record.hum.MaxHealth),1)
    if record.hum.Health<=0 then removeRecord(record,player) end
    return true
end
function EnemyDirector.attackArea(player,range,damage,multi)
    local char=player.Character
    local rootPart=char and char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return 0 end
    local hits=0
    for _,r in pairs(living) do
        if hits>=(multi and 8 or 1) then break end
        if not r.dead and (not r.owner or r.owner==player) then
            local delta=r.pos-rootPart.Position
            local planar=Vector3.new(delta.X,0,delta.Z)
            if planar.Magnitude<=range and math.abs(delta.Y)<=22 then
                local facing=planar.Magnitude<1 or rootPart.CFrame.LookVector:Dot(planar.Unit) > (multi and -.4 or -.25)
                if facing and EnemyDirector.damage(r,player,damage) then hits+=1 end
            end
        end
    end
    return hits
end
function EnemyDirector.clearRun(player)
    local toRemove={}
    for _,r in pairs(living) do
        if r.owner==player then table.insert(toRemove,r) end
    end
    for _,r in ipairs(toRemove) do
        r.dead=true
        living[r.model]=nil
        maxNPC=math.max(0,maxNPC-1)
        r.model:Destroy()
    end
end

local function selectTarget(record)
    if record.owner then
        local target=record.owner
        local char=target and target.Character
        local human=char and char:FindFirstChildOfClass("Humanoid")
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if root and human and human.Health>0 and (root.Position-record.pos).Magnitude<record.base.aggro*2 then
            return target,root,human
        end
        return nil
    end
    local best,bestRoot,bestHum=nil,nil,nil
    local range=record.base.aggro
    for _,player in ipairs(Players:GetPlayers()) do
        local mode=player:GetAttribute("AlnairMode")
        if mode=="campaign_map" or mode=="dungeon" or mode=="sky" then
            local char=player.Character
            local root=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health>0 then
                local dst=(root.Position-record.pos).Magnitude
                if dst<range then range=dst;best=player;bestRoot=root;bestHum=hum end
            end
        end
    end
    return best,bestRoot,bestHum
end

local function stepAI(record,dt,clock)
    if record.dead or not record.model.Parent then return end
    if record.hum.Health<=0 then removeRecord(record,record.lastHitter);return end
    local player,root,hum=selectTarget(record)
    local speed=record.base.speed + math.min(record.rank,4)
    local targetPosition=nil
    if root and player and hum then
        local remembered=math.clamp(player:GetAttribute("AlnairRival_"..record.kind) or 0,0,6)
        if remembered>record.rank and not record.owner then
            local delta=remembered-record.rank
            record.rank=remembered
            record.hum.MaxHealth=record.hum.MaxHealth*(1+delta*.13)
            record.hum.Health=math.min(record.hum.MaxHealth,record.hum.Health+delta*45)
            record.title="RIVAL • "..record.base.name.." / MARCA "..remembered
            local head=record.model:FindFirstChild("Head")
            local tag=head and head:FindFirstChild("RivalName")
            local title=tag and tag:FindFirstChildWhichIsA("TextLabel")
            if title then title.Text=record.title end
        end
        local dist=(root.Position-record.pos).Magnitude
        if record.kind=="witch" and record.hum.Health<record.hum.MaxHealth*.33 and dist<14 then
            record.behavior="retreat"
            targetPosition=record.pos+(record.pos-root.Position).Unit*15
        elseif dist>record.base.range+1.5 then
            record.behavior="hunt"
            targetPosition=root.Position
        else
            record.behavior="attack"
            if clock-record.attackAt>2.3 and dist < record.base.range+2 then
                record.attackAt=clock
                local amount=record.base.damage+math.max(0,record.level-record.base.level)*2
                if player:GetAttribute("AlnairDev") then amount=math.floor(amount*.4) end
                local victimShield=hum:GetAttribute("AlnairShield")
                if typeof(victimShield)=="number" and victimShield>0 then
                    amount=math.max(1,amount-math.floor(victimShield))
                    hum:SetAttribute("AlnairShield",0)
                end
                local mitigation=player:GetAttribute("AlnairRunArmor") or 0
                amount=math.max(1,math.floor(amount*(1-math.clamp(mitigation,0,.75))))
                hum:TakeDamage(amount)
                player:SetAttribute("AlnairLastEnemy",record.kind)
                if hum.Health<=0 then
                    record.rank=math.min(record.rank+1,6)
                    record.hum.Health=math.min(record.hum.MaxHealth,record.hum.Health+50)
                end
            end
        end
    else
        record.behavior="patrol"
        if clock>record.nextWander then
            record.nextWander=clock+rng:NextNumber(3,8)
            local a=rng:NextNumber(-math.pi,math.pi)
            local radius=rng:NextNumber(5,19)
            record.destination=record.origin+Vector3.new(math.cos(a)*radius,0,math.sin(a)*radius)
        end
        targetPosition=record.destination
    end
    if targetPosition then
        local delta=Vector3.new(targetPosition.X-record.pos.X,0,targetPosition.Z-record.pos.Z)
        if delta.Magnitude>.5 then
            local dir=delta.Unit
            local step=math.min(delta.Magnitude,dt*speed)
            local nextPosition=record.pos+dir*step
            local basis=CFrame.lookAt(nextPosition,nextPosition+dir)
            record.pos=nextPosition
            record.model:PivotTo(basis)
        end
    end
    -- Animacao procedural de pernas, bracos e asas: modo repouso / deslocamento / ataque.
    local rootCFrame=record.model:GetPivot()
    local moving=record.behavior=="hunt" or record.behavior=="patrol" or record.behavior=="retreat"
    local phase=clock*(moving and 7.8 or 2.3)+record.wanderPhase
    local amplitude=moving and .38 or .035
    local attackMotion=record.behavior=="attack" and math.sin(clock*12)*.55 or 0
    for _,motion in ipairs(record.motionPieces) do
        local part=motion.bodyPart
        if part.Parent then
            local sign=motion.base.Position.X>=0 and 1 or -1
            local offset=CFrame.new()
            if part.Name=="Arm" then
                offset=CFrame.Angles(math.sin(phase+sign*math.pi)*amplitude+attackMotion,0,sign*.07)
            elseif part.Name=="Leg" then
                offset=CFrame.Angles(-math.sin(phase+sign*math.pi)*amplitude,0,0)
            elseif part.Name=="Head" then
                offset=CFrame.Angles(.035*math.sin(phase*.4),.06*math.sin(phase*.35),0)
            elseif part.Name=="Asa" then
                offset=CFrame.Angles(0,0,sign*.20*math.sin(phase*.45))
            end
            part.CFrame=rootCFrame*motion.base*offset
        end
    end
    record.model:SetAttribute("AIState",record.behavior)
end

function EnemyDirector.init()
    if enemyFolder then return end
    enemyFolder=Workspace:FindFirstChild("AlnairEnemies") or Instance.new("Folder")
    enemyFolder.Name="AlnairEnemies";enemyFolder.Parent=Workspace
    local locations={
        {"skeleton",Vector3.new(-32,4,-97),1},{"skeleton",Vector3.new(21,4,-167),2},
        {"skeleton",Vector3.new(-50,4,-147),2},{"skeleton",Vector3.new(-95,4,-64),3},
        {"orc",Vector3.new(125,4,-178),5},{"orc",Vector3.new(190,4,-133),6},
        {"orc",Vector3.new(205,4,-215),7},
        {"witch",Vector3.new(-174,4,64),7},{"witch",Vector3.new(-205,4,115),9},
        {"dragon",Vector3.new(244,9,219),12},
        {"warden",Rules.DUNGEON_SPAWN+Vector3.new(0,4,-26),7},
        {"dragon",Rules.SKY_SPAWN+Vector3.new(25,6,24),11},
    }
    for i,info in ipairs(locations) do
        EnemyDirector.spawn(info[1],info[2],{level=info[3],spawnTag="world"..i})
    end
    local acc=0
    RunService.Heartbeat:Connect(function(dt)
        acc+=dt
        if acc<.18 then return end
        local elapsed=math.min(acc,.32)
        acc=0
        local now=os.clock()
        for _,record in pairs(living) do stepAI(record,elapsed,now) end
    end)
    print("[ALNAIR] Diretor de inimigos inicializado.")
end
return EnemyDirector
