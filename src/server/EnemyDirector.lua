--!strict
-- IA autoritativa de criaturas: ronda, investiga, persegue, recua e guarda memoria.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local Rules=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("GameRules"))
local CombatChecks=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("CombatChecks"))
local BlockyRig=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("BlockyRig"))
local Appearance=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("Appearance"))
local WeaponRender=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("WeaponRender"))

local EnemyDirector={}
local rng=Random.new(74332)
local living={}
local enemyFolder=nil
local onKill=function(_player,_record) end
local cap=80
local counter=0
local tickCount=0
local maxNPC=0

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
-- 100% dos inimigos usam o avatar articulado R15 BLOCKY criado pelo Roblox.
-- Não criar cabeças/olhos/cabelos com Parts. Cinco acessórios de costas reais.
-- Os acessórios e roupas abaixo são IDs oficiais Roblox verificados.
local EnemyLooks={
    skeleton={
        race="undead",class="assassin",
        appearance={face="mysterious",hair="bald",hat="hood",
            upper="linen",lower="pants",set="none"},
    },
    orc={
        race="undead",class="fighter",
        appearance={face="determined",hair="mohawk",hat="none",
            upper="forest",lower="leather",set="none"},
    },
    witch={
        race="witch",class="mage",
        appearance={face="shadow",hair="bun",hat="hood",
            upper="robe",lower="hakama",set="none"},
    },
    dragon={
        race="undead",class="samurai",
        appearance={face="warrior",hair="mohawk",hat="hood",
            upper="armor",lower="leather",set="none"},
    },
    warden={
        race="undead",class="warrior",
        appearance={face="determined",hair="bald",hat="knighthelm",
            upper="armor",lower="hakama",set="none"},
    },
}
local nativeEnemyTemplates={}

local function enemyTemplate(kind)
    local previous=nativeEnemyTemplates[kind]
    if previous then return previous end
    local appearance=EnemyLooks[kind]
    assert(appearance,"Unknown Roblox enemy look: "..kind)
    local desc=Appearance.description(appearance)
    -- Enemy skin follows enemy species, not the playable race.
    local skin=Rules.Enemies[kind] and Rules.Enemies[kind].color
    if skin then
        desc.HeadColor=skin
        desc.LeftArmColor=skin
        desc.RightArmColor=skin
    end
    local ok,model=pcall(function()
        return BlockyRig.create(desc)
    end)
    desc:Destroy()
    if not ok then
        warn("[ALNAIR] O motor Roblox não criou o NPC R15 articulado:",kind,model)
        return nil
    end
    model.Name="NativeRobloxNPC_"..kind
    model:SetAttribute("AlnairAvatarSource","RobloxHumanoidDescription")
    model:SetAttribute("AlnairRig","RobloxBlockyR15")
    Appearance.arrangeAccessories(model,appearance)
    model.Archivable=true
    nativeEnemyTemplates[kind]=model
    return model
end

local function visual(kind,center,level,health,rank)
    local template=enemyTemplate(kind)
    if not template then return nil,nil end
    local model=template:Clone()
    model.Name=Rules.Enemies[kind].name.." [Nv."..level.."]"
    model:SetAttribute("AlnairEnemyKind",kind)
    model:SetAttribute("AlnairEnemyLevel",level)
    model:SetAttribute("AlnairEnemyRank",rank)
    local humanoid=model:FindFirstChildOfClass("Humanoid")
    local root=model:FindFirstChild("HumanoidRootPart")
    if not (humanoid and root) then
        model:Destroy()
        return nil,nil
    end
    -- Chefes permanecem maiores, mas continuam R6 genuínos.
    if kind=="dragon" then
        model:ScaleTo(1.85)
    elseif kind=="warden" then
        model:ScaleTo(1.22)
    end
    for _,body in ipairs(model:GetDescendants()) do
        if body:IsA("BasePart") then
            body.CanCollide=false
            body.CanTouch=false
            body.CanQuery=false
            body.Massless=true
            body.Anchored=(body==root)
        end
    end
    root.Transparency=1
    humanoid.BreakJointsOnDeath=false
    humanoid.RequiresNeck=false
    humanoid.AutoRotate=false
    humanoid.WalkSpeed=0
    humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
    humanoid.MaxHealth=health
    humanoid.Health=health
    model.PrimaryPart=root
    model:PivotTo(CFrame.new(center))
    local look=EnemyLooks[kind]
    if look then WeaponRender.attach(model,look.class)end
    return model,humanoid
end

-- Native Roblox-created R15 animation assets (verified MarketplaceService).
-- Unlike the old fake limbs these clips bend actual R15 elbows and knees.
local function npcTrack(humanoid,id,priority,looped)
    local animator=humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator=Instance.new("Animator")
        animator.Parent=humanoid
    end
    local clip=Instance.new("Animation")
    clip.Name="RobloxNativeR15_"..tostring(id)
    clip.AnimationId="rbxassetid://"..tostring(id)
    local ok,track=pcall(function()return animator:LoadAnimation(clip)end)
    clip:Destroy()
    if not ok or not track then
        warn("[ALNAIR] Animacao oficial NPC indisponivel:",id,track)
        return nil
    end
    track.Priority=priority or Enum.AnimationPriority.Movement
    track.Looped=looped==true
    return track
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
    if not npc or not hum then
        warn("[ALNAIR] Falha ao gerar inimigo com rig oficial Roblox:",kind)
        return nil
    end
    npc.Name=data.name.."_"..counter
    local title=rank>0 and ("Capitao "..data.name.." • "..rank) or (data.name.." • Nv. "..lvl)
    local record={
        id=counter,kind=kind,model=npc,hum=hum,owner=options.owner,level=lvl,
        pos=pos,origin=pos,rank=rank,title=title,health=hp,base=data,
        xp=math.floor(data.xp*(1+.2*(lvl-data.level))),gold=math.floor(data.gold*(1+.11*(lvl-data.level))),
        behavior="patrol",lastAction=0,nextWander=0,attackAt=0,dead=false,
        lastHitter=nil,locked=nil,spawnTag=options.spawnTag,arena=options.arena,
        animationTracks={},animationState=nil,wanderPhase=rng:NextNumber(0,math.pi*2),
    }
    npc.Parent=enemyFolder
    record.animationTracks={
        idle=npcTrack(hum,507766388,Enum.AnimationPriority.Idle,true),
        walk=npcTrack(hum,507777826,Enum.AnimationPriority.Movement,true),
        run=npcTrack(hum,507767714,Enum.AnimationPriority.Movement,true),
        attack=npcTrack(hum,522635514,Enum.AnimationPriority.Action,false),
    }
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
function EnemyDirector.findTarget(player,range,aim)
    local char=player.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best,bestDistance=nil,range
    for _,r in pairs(living) do
        local delta=r.pos-root.Position
        if not r.dead and (not r.owner or r.owner==player) and delta.Magnitude<bestDistance
            and CombatChecks.facing(aim or root.CFrame.LookVector,Vector3.new(delta.X,0,delta.Z),false)
            and CombatChecks.clearPath(Workspace,root.Position+Vector3.new(0,1,0),r.pos+Vector3.new(0,1,0),char,enemyFolder,enemyFolder) then
            best,bestDistance=r,delta.Magnitude
        end
    end
    return best
end
function EnemyDirector.attackArea(player,range,damage,multi,aim)
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
                local facing=CombatChecks.facing(aim or rootPart.CFrame.LookVector,planar,multi)
                if facing and CombatChecks.clearPath(Workspace,
                    rootPart.Position+Vector3.new(0,1.15,0),
                    r.pos+Vector3.new(0,.45,0),char,enemyFolder,enemyFolder)
                    and EnemyDirector.damage(r,player,damage) then
                    hits+=1
                end
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
        elseif dist>record.base.range+1.5
            or not CombatChecks.clearPath(Workspace,
                record.pos+Vector3.new(0,.9,0),
                root.Position+Vector3.new(0,.9,0),
                record.model,player.Character,enemyFolder) then
            -- Never damage through walls even when enemy AI is close to player.
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
                local network=game.ReplicatedStorage:FindFirstChild("AlnairGame")
                local fx=network and network:FindFirstChild("CombatFX")
                if fx then fx:FireAllClients(record.model,"enemy",1,CFrame.lookAt(record.pos,root.Position),root.Position) end
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
            local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={enemyFolder}
            local ground=Workspace:Raycast(nextPosition+Vector3.new(0,8,0),Vector3.new(0,-24,0),params)
            if ground then
                local foot=record.model:FindFirstChild("LeftFoot")
                local r=record.model.PrimaryPart
                local offset=foot and r and (r.Position.Y-foot.Position.Y+foot.Size.Y/2) or 3
                nextPosition=Vector3.new(nextPosition.X,ground.Position.Y+offset,nextPosition.Z)
            end
            local basis=CFrame.lookAt(nextPosition,nextPosition+dir)
            record.pos=nextPosition
            record.model:PivotTo(basis)
        end
    end
    -- The official Animator drives R15 elbows, knees, wrists and hands.
    -- Never rotate individual MeshParts or fabricate Motor6D joints.
    local animationState=(record.behavior=="attack" and "attack")
        or (record.behavior=="hunt" and "run")
        or ((record.behavior=="patrol" or record.behavior=="retreat")
            and "walk") or "idle"
    if animationState~=record.animationState then
        record.animationState=animationState
        for key,track in pairs(record.animationTracks) do
            if track and track.IsPlaying and key~=animationState then
                track:Stop(.13)
            end
        end
        local selected=record.animationTracks[animationState]
        if selected and not selected.IsPlaying then selected:Play(.14,1,1)end
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
