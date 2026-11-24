--!strict
-- Alnair v0.4: campanha, sistema de ondas, progressao, montarias e painel DEV.
-- Autoridade: servidor. Gema nao e drop: somente ProcessReceipt configurado ou comando DEV.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local Debris=game:GetService("Debris")
local MarketplaceService=game:GetService("MarketplaceService")
local Rules=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("GameRules"))
local Shared=ReplicatedStorage:WaitForChild("AlnairShared")
local Appearance=require(Shared:WaitForChild("Appearance"))
local Catalog=require(Shared:WaitForChild("Catalog"))
local ArtAssets=require(script.Parent:WaitForChild("ArtAssets"))
local Profiles=require(script.Parent:WaitForChild("PlayerProgress"))
local WorldExpansion=require(script.Parent:WaitForChild("WorldExpansion"))
local Enemies=require(script.Parent:WaitForChild("EnemyDirector"))
local DEV_PASSWORD="infantaria" -- apenas servidor + execucao local Studio, NAO publicar senha
local ALLOW_DEV=RunService:IsStudio()

local rng=Random.new(72443)
local folder=ReplicatedStorage:FindFirstChild("AlnairGame") or Instance.new("Folder")
folder.Name="AlnairGame"
folder.Parent=ReplicatedStorage

local function remote(class,name)
    local r=folder:FindFirstChild(name)
    if not r then r=Instance.new(class);r.Name=name;r.Parent=folder end
    return r
end
local action=remote("RemoteEvent","Action")
local state=remote("RemoteEvent","State")
local query=remote("RemoteFunction","Query")
local run={}
local abilityCooldown={}
local lastAttack={}
local combos={}
local function countHit(player,n)
    if n<=0 or not player.Parent then return end
    local now=workspace:GetServerTimeNow()
    local old=player:GetAttribute("AlnairComboUntil") or 0
    local count=now<old and (player:GetAttribute("AlnairHitCombo") or 0) or 0
    player:SetAttribute("AlnairHitCombo",count+n)
    player:SetAttribute("AlnairComboUntil",now+3)
end
local fx=remote("RemoteEvent","CombatFX")
local lastSprint={}
local lastFly={}
local failedLogin={}
local devAccess={}
local mounts={}
local claimedChests={}
local lastNotify={}
local arenasTaken={}
local registeredPrompts={}

local function emit(player,typeName,payload)
    if player and player.Parent then
        state:FireClient(player,typeName,payload)
    end
end
local function snapshot(player)
    local s=Profiles.snapshot(player)
    if not s then return nil end
    local r=run[player]
    if r then
        s.run={
            wave=r.wave,phase=r.phase,kills=r.kills,remaining=r.remaining,
            gold=r.gold,xp=r.xp,cards=r.cards,
            buffs=table.clone(r.buffs),arena=r.arena,
        }
    end
    return s
end
local function push(player)
    emit(player,"state",snapshot(player))
end
Profiles.setNotifier(push)
query.OnServerInvoke=function(player)
    return snapshot(player)
end

WorldExpansion.create()
Enemies.init()
local notices={}
local function notice(player,text,kind)
    emit(player,"toast",{message=text,kind=kind or "info"})
end
local function characterRoot(player)
    local character=player.Character
    if not character then return nil,nil end
    return character:FindFirstChild("HumanoidRootPart"),character:FindFirstChildOfClass("Humanoid")
end
local function warp(player,position)
    if typeof(position)~="Vector3" then return end
    local character=player.Character
    if not character then return end
    local rootPart=character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    rootPart.AssemblyLinearVelocity=Vector3.zero
    character:PivotTo(CFrame.new(position)*CFrame.Angles(0,math.pi,0))
end

local function cleanupMount(player)
    local m=mounts[player]
    if not m then return end
    if m.flight then m.flight:Destroy() end
    if m.attachment then m.attachment:Destroy() end
    if m.visual then m.visual:Destroy() end
    local _root,humanoid=characterRoot(player)
    if humanoid then
        humanoid.AutoRotate=true
        player:SetAttribute("AlnairSprinting",false)
        local speedBoost=(run[player] and run[player].buffs
            and run[player].buffs.speed or 0)
        humanoid.WalkSpeed=16*(1+speedBoost+Profiles.speedBonus(player))
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    mounts[player]=nil
    player:SetAttribute("AlnairMount","")
    push(player)
end

local function refreshOutfit(player)
    local profile=Profiles.get(player)
    local character=player.Character
    if not profile or not character then return end
    local choices={}
    for _,group in ipairs(Catalog.PresetOrder) do
        choices[group]=player:GetAttribute("AlnairPreset_"..group)
    end
    Appearance.refreshOutfit(character,{
        race=player:GetAttribute("AlnairRace"),
        class=player:GetAttribute("AlnairClass"),
        appearance=choices
    },profile.equipped)
end
local function mountVisual(player,kind)
    local rootPart,humanoid=characterRoot(player)
    if not rootPart or not humanoid then return nil end
    -- Usa cavalo e dragao 3D de bibliotecas gratuitas, com solda no avatar.
    local imported=ArtAssets.mount(player,kind,kind=="horse" and 5.7 or 9.2)
    if imported then return imported end
    local mdl=Instance.new("Model")
    mdl.Name=kind=="horse" and "Cavalo do Viajante" or "Draco Celestial"
    local color=kind=="horse" and Color3.fromRGB(124,82,53) or Color3.fromRGB(100,92,161)
    local function meshPiece(name,size,relative,colorOverride,shape)
        local p=Instance.new("Part")
        p.Name=name;p.Size=size;p.Color=colorOverride or color
        p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
        p.Massless=true;p.CastShadow=true
        p.Material=Enum.Material.SmoothPlastic
        p.CFrame=rootPart.CFrame*relative
        if shape then p.Shape=shape end
        p.Parent=mdl
        local weld=Instance.new("WeldConstraint")
        weld.Part0=rootPart;weld.Part1=p;weld.Parent=p
        return p
    end
    if kind=="horse" then
        meshPiece("Corpo de Cavalo",Vector3.new(2.5,1.6,4.5),CFrame.new(0,-2.2,-.3),color)
        meshPiece("Pescoco",Vector3.new(1.1,2.0,1.3),CFrame.new(0,-1.32,-2.12),color)
        meshPiece("Cabeca",Vector3.new(1.2,1.1,1.6),CFrame.new(0,-.6,-2.55),color)
        for _,x in ipairs({-1,1}) do
            for _,z in ipairs({-1.6,1.2}) do
                meshPiece("Perna de Cavalo",Vector3.new(.47,2,.48),CFrame.new(x,-3.7,z),Color3.fromRGB(85,61,48))
            end
        end
        meshPiece("Sela",Vector3.new(2.0,.2,2.0),CFrame.new(0,-1.25,-.20),Color3.fromRGB(54,42,37))
    else
        meshPiece("Corpo do Draco",Vector3.new(3.5,1.6,5.0),CFrame.new(0,-2.7,-.5),color)
        meshPiece("Cabeca do Draco",Vector3.new(1.7,1.2,2.0),CFrame.new(0,-1.1,-3),Color3.fromRGB(124,104,185))
        for _,side in ipairs({-1,1}) do
            meshPiece("Asa do Draco",Vector3.new(5.5,.26,4.8),
                CFrame.new(side*4,-2.1,.15)*CFrame.Angles(0,side*.20,side*.30),
                Color3.fromRGB(77,66,121))
        end
        meshPiece("Cauda",Vector3.new(1.0,.8,4.0),CFrame.new(0,-2.4,3.6),Color3.fromRGB(93,76,141))
    end
    mdl.Parent=player.Character
    return mdl
end
local function toggleMount(player,kind)
    if not Profiles.get(player) then return end
    if kind~="horse" and kind~="dragon" then return end
    if mounts[player] and mounts[player].kind==kind then
        cleanupMount(player);return
    end
    local level=Profiles.get(player).level
    if level<Rules.MOUNT_LEVEL[kind] then
        notice(player,"Requer nivel "..Rules.MOUNT_LEVEL[kind].." para "..(kind=="horse" and "cavalo" or "dragao"),"warning")
        return
    end
    local mode=player:GetAttribute("AlnairMode")
    if mode~="campaign_map" and mode~="sky" and mode~="dungeon" then
        notice(player,"Montarias so podem ser usadas durante exploracao.","warning")
        return
    end
    cleanupMount(player)
    local rootPart,humanoid=characterRoot(player)
    if not rootPart or not humanoid or humanoid.Health<=0 then return end
    local model=mountVisual(player,kind)
    if not model then return end
    mounts[player]={kind=kind,visual=model}
    player:SetAttribute("AlnairMount",kind)
    if kind=="horse" then
        humanoid.WalkSpeed=28
    else
        local a=Instance.new("Attachment");a.Name="AlnairFlight";a.Parent=rootPart
        local v=Instance.new("LinearVelocity")
        v.Name="AlnairFlightVelocity";v.Attachment0=a
        v.RelativeTo=Enum.ActuatorRelativeTo.World
        v.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
        v.VectorVelocity=Vector3.zero
        v.MaxForce=1500000
        v.ForceLimitsEnabled=false
        v.Parent=rootPart
        mounts[player].attachment=a
        mounts[player].flight=v
        humanoid.AutoRotate=false
        humanoid.WalkSpeed=18
    end
    notice(player,"Montaria: "..(kind=="horse" and "Cavalo do Viajante" or "Draco Celestial"))
    push(player)
end

local function arenaFor(player)
    for i=0,6 do
        if not arenasTaken[i] or arenasTaken[i]==player then
            arenasTaken[i]=player
            return i
        end
    end
    return nil
end
local function releaseArena(player)
    for k,p in pairs(arenasTaken) do
        if p==player then arenasTaken[k]=nil end
    end
end
local function runBuff(r,stat)
    return (r and r.buffs[stat]) or 0
end
local function randomCards(r)
    local chosen={}
    local used={}
    for i=1,3 do
        local tries=0
        local candidate=nil
        repeat
            candidate=Rules.Cards[rng:NextInteger(1,#Rules.Cards)]
            tries+=1
        until not used[candidate.id] or tries>40
        used[candidate.id]=true
        table.insert(chosen,{id=candidate.id,name=candidate.name,desc=candidate.desc,stat=candidate.stat,value=candidate.value})
    end
    return chosen
end
local function updatePlayerVitals(player)
    local p=Profiles.get(player)
    local rootPart,humanoid=characterRoot(player)
    if not p or not humanoid then return end
    local r=run[player]
    local stats=Profiles.attributes(player)
    if stats then
        local staminaMax=60+stats.values.endurance*8
        local manaMax=30+stats.values.intelligence*10
        player:SetAttribute("AlnairMaxStamina",staminaMax)
        player:SetAttribute("AlnairMaxMana",manaMax)
        if player:GetAttribute("AlnairStamina")==nil then player:SetAttribute("AlnairStamina",staminaMax) end
        if player:GetAttribute("AlnairMana")==nil then player:SetAttribute("AlnairMana",manaMax) end
    end
    local max=Profiles.maxHealth(player)+runBuff(r,"health")
    local pct=humanoid.MaxHealth>0 and humanoid.Health/humanoid.MaxHealth or 1
    humanoid.MaxHealth=max
    humanoid.Health=math.clamp(max*pct,1,max)
    if not mounts[player] then
        humanoid.WalkSpeed=16*(1+runBuff(r,"speed")+Profiles.speedBonus(player))
            + (player:GetAttribute("AlnairSprinting")==true and 7 or 0)
    end
    player:SetAttribute("AlnairRunArmor",
        math.clamp(Profiles.damageMitigation(player)+runBuff(r,"armor"),0,.75))
    player:SetAttribute("AlnairDefense",Profiles.defense(player))
    player:SetAttribute("AlnairAttack",Profiles.attackPower(player))
end
local function spawnWave(player)
    local r=run[player]
    if not r then return end
    r.phase="fight";r.cards=nil;r.remaining=0
    local kinds={"skeleton","skeleton","orc","witch","dragon"}
    local wave=r.wave
    local count=math.min(4+math.floor(wave*1.25),18)
    local arena=WorldExpansion.arena(r.arena)
    for i=1,count do
        local angle=(i/count)*math.pi*2+rng:NextNumber(-.1,.1)
        local radius=rng:NextNumber(27,51)
        local c=arena.center
        local pos=Vector3.new(c.X+math.cos(angle)*radius,4,c.Z+math.sin(angle)*radius)
        local choice=math.min(#kinds,1+math.floor((wave-1)/3))
        local kind=kinds[rng:NextInteger(1,math.max(1,choice))]
        local record=Enemies.spawn(kind,pos,{
            owner=player,level=math.max(1,wave+math.floor(wave/2)),
            wave=wave,arena=r.arena
        })
        if record then r.remaining+=1 end
    end
    push(player)
    notice(player,"HORDA "..wave.." • "..r.remaining.." inimigos")
end
local function beginArena(player)
    if run[player] then return end
    local index=arenaFor(player)
    if not index then
        notice(player,"Todas as arenas estao ocupadas. Tente novamente.","warning")
        return
    end
    local arena=WorldExpansion.arena(index)
    run[player]={arena=index,phase="fight",wave=1,kills=0,remaining=0,gold=0,xp=0,
        buffs={damage=0,armor=0,speed=0,health=0,gold=0,xp=0,leech=0,haste=0}}
    player:SetAttribute("AlnairMode","sandbox")
    warp(player,arena.spawn)
    spawnWave(player)
end
local function finishArena(player,died)
    local r=run[player]
    if not r then return end
    local rewardGold=math.floor(r.gold*(1+runBuff(r,"gold")))
    local rewardXP=math.floor(r.xp*(1+runBuff(r,"xp")))
    local completed=r.wave-(r.phase=="fight" and 1 or 0)
    Enemies.clearRun(player)
    releaseArena(player)
    run[player]=nil
    player:SetAttribute("AlnairRunArmor",Profiles.damageMitigation(player))
    if died then
        Profiles.addGold(player,rewardGold)
        Profiles.addXP(player,rewardXP)
        local p=Profiles.get(player)
        if p then p.bestWave=math.max(p.bestWave,completed);Profiles.touch(player) end
    end
    player:SetAttribute("AlnairMode","lobby")
    emit(player,"runSummary",{
        wave=completed,kills=r.kills,gold=died and rewardGold or 0,
        xp=died and rewardXP or 0,claimed=died,
    })
    if not died then warp(player,Rules.LOBBY_SPAWN) end
    push(player)
end

Enemies.setOnKill(function(player,enemy)
    local mode=player:GetAttribute("AlnairMode")
    local r=run[player]
    if r and enemy.owner==player then
        r.kills+=1;r.remaining=math.max(0,r.remaining-1)
        r.gold+=enemy.gold+math.floor(r.wave*2)
        r.xp+=enemy.xp+math.floor(r.wave*2)
        Profiles.enemyKill(player,enemy.kind,0,0,"sandbox")
        if r.remaining<=0 and r.phase=="fight" then
            r.phase="card";r.cards=randomCards(r)
            notice(player,"Horda concluida! Escolha uma carta para continuar.")
        end
        push(player)
    elseif not enemy.owner then
        Profiles.enemyKill(player,enemy.kind,enemy.gold,enemy.xp,mode)
        if enemy.rank>0 then
            Profiles.defeatRival(player,enemy.kind,enemy.rank)
            notice(player,"RIVAL DERROTADO! Selo obtido. +"..(enemy.rank*28).." ouro","success")
        else
            notice(player,"+"..enemy.gold.." ouro  •  +"..enemy.xp.." XP")
        end
    end
end)

local function grantCard(player,id)
    local r=run[player]
    if not r or r.phase~="card" or typeof(id)~="string" then return end
    local choice=nil
    for _,c in ipairs(r.cards or {}) do if c.id==id then choice=c;break end end
    if not choice then return end
    r.cards=nil
    r.buffs[choice.stat]=(r.buffs[choice.stat] or 0)+choice.value
    local _root,hum=characterRoot(player)
    if choice.stat=="heal" and hum then
        hum.Health=math.min(hum.MaxHealth,hum.Health+choice.value)
    end
    if choice.stat=="health" or choice.stat=="speed" or choice.stat=="armor" then
        updatePlayerVitals(player)
    end
    r.wave+=1
    r.phase="interlude"
    push(player)
    task.delay(1.7,function()
        if run[player]==r and player.Parent==Players then spawnWave(player) end
    end)
end

local function handlePrompt(promptObj,player)
    if not Profiles.ready(player) then return end
    local mode=player:GetAttribute("AlnairMode")
    if not mode or mode=="menu" then return end
    local p=promptObj.Parent
    if not p or not p:IsA("BasePart") then return end
    local rootPart,hum=characterRoot(player)
    if not rootPart or not hum or hum.Health<=0 then return end
    if (rootPart.Position-p.Position).Magnitude>22 then return end
    local kind=p:GetAttribute("Action")
    local target=p:GetAttribute("ActionTarget")
    if kind=="portal" then
        if target=="map1" then
            if run[player] then finishArena(player,false) end
            player:SetAttribute("AlnairMode","campaign_map")
            warp(player,Rules.CAMPAIGN_SPAWN)
            notice(player,"Capitulo I • O Vale das Cinzas")
            push(player)
        elseif target=="sandbox" then
            if run[player] then return end
            beginArena(player)
        else
            notice(player,"Mapa selado. Conclua os capitulos anteriores.","warning")
        end
    elseif kind=="quest" then
        if Profiles.quest(player,"interact",target,1) then
            notice(player,"Missao concluida! A luz antiga cresce.","success")
        else notice(player,"Esse misterio ainda nao faz parte de sua missao.","info") end
    elseif kind=="dungeon" then
        if target=="Crypt" then
            Profiles.quest(player,"interact","Crypt",1)
            player:SetAttribute("AlnairMode","dungeon")
            warp(player,Rules.DUNGEON_SPAWN)
            notice(player,"Cripta Afogada • Trespassaste o limiar")
        elseif target=="ExitCrypt" then
            player:SetAttribute("AlnairMode","campaign_map")
            warp(player,Vector3.new(-112,7,-85))
        elseif target=="SkyDungeon" then
            player:SetAttribute("AlnairMode","dungeon")
            warp(player,Vector3.new(265,161,169))
            notice(player,"Santuario Aereo • Ecos do Abismo")
        end
        push(player)
    elseif kind=="sky" then
        if target=="EnterSky" then
            if Profiles.get(player).level<5 then
                notice(player,"A passagem eterea exige nivel 5.","warning")
                return
            end
            player:SetAttribute("AlnairMode","sky");warp(player,Rules.SKY_SPAWN)
        elseif target=="ExitSky" then
            player:SetAttribute("AlnairMode","campaign_map")
            warp(player,Vector3.new(148,8,100))
        end
        push(player)
    elseif kind=="exitArena" then
        if run[player] then finishArena(player,false) end
    elseif kind=="chest" then
        claimedChests[player]=claimedChests[player] or {}
        if claimedChests[player][target] then
            notice(player,"Esse bau ja foi encontrado nesta sessao.","info")
        else
            claimedChests[player][target]=true
            local value=rng:NextInteger(p:GetAttribute("GoldMin") or 30,p:GetAttribute("GoldMax") or 50)
            Profiles.addGold(player,value)
            notice(player,"Voce encontrou "..value.." ouro!","success")
        end
    elseif kind=="dialogue" then
        notice(player,"Cronista: Sete estrelas cairam. Encontre a primeira chama e siga o eco das ruinas.")
    elseif kind=="shop" and mode=="lobby" then
        emit(player,"openShop",{})
    end
end

local function registerPrompt(obj)
    if not obj:IsA("ProximityPrompt") or obj.Name~="AlnairInteraction" or registeredPrompts[obj] then return end
    registeredPrompts[obj]=true
    obj.Triggered:Connect(function(player)handlePrompt(obj,player)end)
end
for _,obj in ipairs(Workspace:GetDescendants()) do registerPrompt(obj) end
Workspace.DescendantAdded:Connect(registerPrompt)

local function combat(player,id)
    local mode=player:GetAttribute("AlnairMode")
    if mode~="sandbox" and mode~="campaign_map" and mode~="dungeon" and mode~="sky" then return end
    local rootPart,hum=characterRoot(player)
    if not rootPart or not hum or hum.Health<=0 then return end
    local aim=rootPart.CFrame.LookVector
    if typeof(id)=="table" then
        local point=id.aim;id=id.id
        if typeof(point)=="Vector3" and point.Magnitude<100000 then
            local d=point-rootPart.Position;d=Vector3.new(d.X,0,d.Z)
            if d.Magnitude>.1 then aim=d.Unit end
        end
    end
    local now=os.clock()
    local r=run[player]
    if id=="basic" then
        if now-(lastAttack[player] or 0)<.48 then return end
        local previous=lastAttack[player] or 0
        lastAttack[player]=now
        local class=player:GetAttribute("AlnairClass") or "warrior"
        local step=now-previous>1.4 and 1 or ((combos[player] or 0)%3)+1
        combos[player]=step
        local range=class=="mage" and 55 or class=="fighter" and 8 or 12
        local target=Enemies.findTarget(player,range,aim)
        local destination=target and target.pos+Vector3.new(0,1,0) or rootPart.Position+aim*range
        fx:FireAllClients(player.Character,class,step,CFrame.lookAt(rootPart.Position,rootPart.Position+aim),destination)
        local power=Profiles.attackPower(player)*(1+runBuff(r,"damage"))
        local hits=0
        if class=="mage" then
            task.delay(.81,function()
                if target and player.Character and hum.Health>0 and Enemies.damage(target,player,power*(step==3 and 1.35 or 1)) then countHit(player,1) end
            end)
        else
            -- Register contact at the actual visual blade impact, not on key-down.
            task.delay(.27,function()
                if target and player.Character and hum.Health>0
                    and Enemies.damage(target,player,power*(step==3 and 1.35 or 1)) then
                    countHit(player,1)
                    if runBuff(r,"leech")>0 then
                        hum.Health=math.min(hum.MaxHealth,hum.Health+power*runBuff(r,"leech"))
                    end
                end
            end)
        end
        return
    end
    if typeof(id)~="string" or #id>64 then return end
    local p=Profiles.get(player)
    if not p or not table.find(p.skills,id) then return end
    local skill=Rules.skillById(player:GetAttribute("AlnairClass") or "warrior",id)
    if not skill then return end
    local cooldown=abilityCooldown[player] or {}
    abilityCooldown[player]=cooldown
    local resetTime=cooldown[id] or 0
    if now<resetTime then return end
    local mana=player:GetAttribute("AlnairMana") or 0
    if mana<15 then return end
    player:SetAttribute("AlnairMana",mana-15)
    cooldown[id]=now+skill.cooldown/(1+runBuff(r,"haste"))
    if skill.kind=="heal" then
        hum.Health=math.min(hum.MaxHealth,hum.Health+skill.damage)
    elseif skill.kind=="shield" then
        hum:SetAttribute("AlnairShield",skill.damage)
        task.delay(12,function()
            if hum and hum.Parent then hum:SetAttribute("AlnairShield",0) end
        end)
    else
        local power=(skill.damage+Profiles.attackPower(player)*.42)*(1+runBuff(r,"damage"))
        local class=player:GetAttribute("AlnairClass") or "warrior"
        local target=Enemies.findTarget(player,skill.range,aim)
        local destination=target and target.pos+Vector3.new(0,1,0) or rootPart.Position+aim*skill.range
        fx:FireAllClients(player.Character,class,3,rootPart.CFrame,destination)
        countHit(player,Enemies.attackArea(player,skill.range,power,true,aim))
        if runBuff(r,"leech")>0 then
            hum.Health=math.min(hum.MaxHealth,hum.Health+power*runBuff(r,"leech"))
        end
    end
    emit(player,"skillUsed",{id=id,cooldown=skill.cooldown})
end

local function handleDev(player,request)
    if not devAccess[player] or not ALLOW_DEV or typeof(request)~="table" then return end
    local p=Profiles.get(player)
    if not p then return end
    local op=request.op
    local val=request.value
    if op=="level" then
        Profiles.setLevel(player,tonumber(val) or 1)
        updatePlayerVitals(player)
    elseif op=="gold" then
        Profiles.addGold(player,math.clamp(math.floor(tonumber(val) or 0),-100000,100000))
    elseif op=="gems" then
        Profiles.addPurchasedGems(player,math.clamp(math.floor(tonumber(val) or 0),-100000,100000))
    elseif op=="xp" then
        Profiles.addXP(player,math.clamp(math.floor(tonumber(val) or 0),0,100000))
        updatePlayerVitals(player)
    elseif op=="skills" then
        local class=player:GetAttribute("AlnairClass") or "warrior"
        local skills=Rules.Skills[class] or Rules.Skills.warrior
        p.skills={}
        for _,level in ipairs(Rules.SKILL_LEVELS) do
            for _,skill in ipairs(skills[level]) do table.insert(p.skills,skill.id) end
            p.drafts[tostring(level)]={level=level,options={},chosen="DEV"}
        end
        p.rejected={}
        Profiles.touch(player)
    elseif op=="resetSkills" then
        p.skills={};p.rejected={};p.drafts={}
        Profiles.ensureDraft(player)
    elseif op=="quest" then
        p.questIndex=math.clamp(math.floor(tonumber(val) or 1),1,#Rules.Quests+1)
        p.questCount=0;Profiles.touch(player)
    elseif op=="heal" then
        local _,hum=characterRoot(player)
        if hum then hum.Health=hum.MaxHealth end
    elseif op=="spawn" then
        local rootPart=characterRoot(player)
        if rootPart and Rules.Enemies[val] then
            Enemies.spawn(val,rootPart.Position+rootPart.CFrame.LookVector*16+Vector3.new(0,2,0),
                {level=Rules.Enemies[val].level})
        end
    elseif op=="revealMap" then
        for x=0,Rules.FOG_GRID-1 do
            for z=0,Rules.FOG_GRID-1 do
                p.visited[x.."_"..z]=true
            end
        end
        Profiles.touch(player)
    elseif op=="clearFog" then
        p.visited={};Profiles.touch(player)
    elseif op=="nextWave" then
        local r=run[player]
        if r then
            Enemies.clearRun(player)
            r.remaining=0;r.phase="card";r.cards=randomCards(r)
            push(player)
        end
    elseif op=="lobby" then
        if run[player] then finishArena(player,false) end
        cleanupMount(player)
        player:SetAttribute("AlnairMode","lobby")
        warp(player,Rules.LOBBY_SPAWN);push(player)
    elseif op=="map1" then
        if run[player] then finishArena(player,false) end
        player:SetAttribute("AlnairMode","campaign_map")
        warp(player,Rules.CAMPAIGN_SPAWN);push(player)
    elseif op=="sandbox" then
        if not run[player] then beginArena(player) end
    elseif op=="unlockMaps" then
        p.unlockedMaps={["1"]=true,["2"]=true,["3"]=true}
        Profiles.touch(player)
    end
end

action.OnServerEvent:Connect(function(player,verb,value)
    if typeof(verb)~="string" or #verb>40 then return end
    if verb=="sprint" then
        if typeof(value)~="boolean" or not Profiles.ready(player) then return end
        local now=os.clock()
        if now-(lastSprint[player] or -100)<.055 then return end
        lastSprint[player]=now
        local mode=player:GetAttribute("AlnairMode")
        if (mode~="campaign_map" and mode~="sandbox" and mode~="lobby"
            and mode~="dungeon" and mode~="sky")
            or mounts[player] then
            player:SetAttribute("AlnairSprinting",false)
            return
        end
        local _,hum=characterRoot(player)
        if not hum or hum.Health<=0 then return end
        player:SetAttribute("AlnairSprinting",value)
        updatePlayerVitals(player)
    elseif verb=="dodge" then
        local rootPart,hum=characterRoot(player)
        local now=workspace:GetServerTimeNow()
        if not rootPart or not hum or hum.Health<=0 or mounts[player] or not Profiles.ready(player) or typeof(value)~="Vector3" or value.Magnitude>2 or value.Magnitude<.1 then return end
        if now<(player:GetAttribute("AlnairDodgeUntil") or 0)+.55 then return end
        local dir=Vector3.new(value.X,0,value.Z)
        if dir.Magnitude<.1 then return end
        dir=dir.Unit
        local stamina=player:GetAttribute("AlnairStamina") or 100
        if stamina<20 then return end
        player:SetAttribute("AlnairStamina",stamina-20)
        player:SetAttribute("AlnairDodgeUntil",now+.48)
        rootPart.AssemblyLinearVelocity=dir*30+Vector3.new(0,rootPart.AssemblyLinearVelocity.Y,0)
        local att=Instance.new("Attachment",rootPart)
        local lv=Instance.new("LinearVelocity");lv.Attachment0=att;lv.MaxForce=30000;lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane;lv.PrimaryTangentAxis=Vector3.xAxis;lv.SecondaryTangentAxis=Vector3.zAxis;lv.PlaneVelocity=Vector2.new(dir.X,dir.Z)*28;lv.Parent=rootPart
        task.delay(.42,function() lv:Destroy();att:Destroy() end)
    elseif verb=="devAuth" then
        local now=os.clock()
        if now-(failedLogin[player] or -100)<1.8 then return end
        failedLogin[player]=now
        if not ALLOW_DEV then
            notice(player,"Modo DEV desativado fora do Roblox Studio.","warning")
        elseif typeof(value)=="string" and value==DEV_PASSWORD then
            devAccess[player]=true
            player:SetAttribute("AlnairDev",true)
            notice(player,"Modo DEV habilitado nesta sessao.", "success")
            push(player)
        else
            notice(player,"Senha DEV incorreta.","warning")
        end
    elseif verb=="dev" then
        handleDev(player,value)
    elseif verb=="allocateStat" then
        local ok,msg=Profiles.allocateAttribute(player,value)
        if ok then
            updatePlayerVitals(player)
        end
        notice(player,msg,ok and "success" or "warning")
    elseif verb=="skillChoice" then
        local ok,msg=Profiles.chooseSkill(player,value)
        notice(player,msg,ok and "success" or "warning")
    elseif verb=="card" then grantCard(player,value)
    elseif verb=="attack" then combat(player,value)
    elseif verb=="potion" then
        if not Profiles.usePotion(player) then notice(player,"Nao foi possivel usar o frasco.","warning") end
    elseif verb=="buy" then
        if player:GetAttribute("AlnairMode")~="lobby" then return end
        local ok,msg=Profiles.buy(player,value)
        notice(player,msg,ok and "success" or "warning")
    elseif verb=="equip" then
        if Profiles.equip(player,value) then
            updatePlayerVitals(player)
            refreshOutfit(player)
        end
    elseif verb=="mount" then toggleMount(player,value)
    elseif verb=="fly" then
        local m=mounts[player]
        if not m or m.kind~="dragon" or not m.flight or typeof(value)~="Vector3" then return end
        local now=os.clock()
        if now-(lastFly[player] or 0)<.09 then return end
        lastFly[player]=now
        local rootPart=characterRoot(player)
        if not rootPart then return end
        local vec=value.Magnitude>1 and value.Unit or value
        local y=vec.Y
        if rootPart.Position.Y>230 then y=math.min(y,0) end
        if rootPart.Position.Y<8 then y=math.max(y,0) end
        vec=Vector3.new(vec.X,y,vec.Z)
        m.flight.VectorVelocity=vec*48
        local forward=Vector3.new(vec.X,0,vec.Z)
        if forward.Magnitude>.2 then rootPart.CFrame=CFrame.lookAt(rootPart.Position,rootPart.Position+forward) end
    elseif verb=="save" then
        Profiles.save(player)
    end
end)

local function setupCharacter(player,character)
    task.spawn(function()
        local rootPart=character:WaitForChild("HumanoidRootPart",15)
        local humanoid=character:WaitForChild("Humanoid",15)
        if not rootPart or not humanoid then return end
        local count=0
        while not Profiles.ready(player) and count<40 do count+=1;task.wait(.2) end
        if player.Character~=character then return end
        task.wait(.45)
        player:SetAttribute("AlnairSprinting",false)
        -- O rig R6 quadrado usa as dimensoes classicas do Roblox.
        if humanoid.RigType==Enum.HumanoidRigType.R6 then
            humanoid.HipHeight=0
        end
        local mode=player:GetAttribute("AlnairMode")
        if mode=="sandbox" then
            if not run[player] then beginArena(player) end
        elseif mode=="campaign" or mode=="lobby" then
            player:SetAttribute("AlnairMode","lobby")
            warp(player,Rules.LOBBY_SPAWN)
        elseif mode=="campaign_map" then
            warp(player,Rules.CAMPAIGN_SPAWN)
        elseif mode=="dungeon" then
            warp(player,Rules.DUNGEON_SPAWN)
        elseif mode=="sky" then
            warp(player,Rules.SKY_SPAWN)
        end
        humanoid.MaxHealth=Profiles.maxHealth(player)
        humanoid.Health=humanoid.MaxHealth
        updatePlayerVitals(player)
        Profiles.ensureDraft(player)
        refreshOutfit(player)
        push(player)
        humanoid.Died:Connect(function()
            local r=run[player]
            if r then finishArena(player,true)
            else
                local enemyKind=player:GetAttribute("AlnairLastEnemy")
                if typeof(enemyKind)=="string" and Rules.Enemies[enemyKind] then
                    Profiles.rivalMemory(player,enemyKind)
                end
                player:SetAttribute("AlnairMode","lobby")
            end
            cleanupMount(player)
            push(player)
        end)
    end)
end

local function setupPlayer(player)
    Profiles.load(player)
    if player.Character then setupCharacter(player,player.Character) end
    player.CharacterAdded:Connect(function(char)setupCharacter(player,char)end)
    player:GetAttributeChangedSignal("AlnairClass"):Connect(function()
        Profiles.ensureDraft(player)
    end)
end
for _,player in ipairs(Players:GetPlayers()) do task.spawn(setupPlayer,player) end
Players.PlayerAdded:Connect(function(player)task.spawn(setupPlayer,player)end)
Players.PlayerRemoving:Connect(function(player)
    if run[player] then
        Enemies.clearRun(player)
        run[player]=nil
        releaseArena(player)
    end
    cleanupMount(player)
    Profiles.unload(player)
    lastAttack[player]=nil
    combos[player]=nil
    lastSprint[player]=nil
    lastFly[player]=nil
    devAccess[player]=nil
    failedLogin[player]=nil
    claimedChests[player]=nil
    abilityCooldown[player]=nil
end)

task.spawn(function()
    while true do
        task.wait(.25)
        for _,p in ipairs(Players:GetPlayers()) do
            local max=p:GetAttribute("AlnairMaxStamina")
            if max then
                local s=p:GetAttribute("AlnairStamina") or max
                local root,hum=characterRoot(p)
                local running=p:GetAttribute("AlnairSprinting") and root and root.AssemblyLinearVelocity.Magnitude>5
                s=math.clamp(s+(running and -3 or 4),0,max)
                p:SetAttribute("AlnairStamina",s)
                if s<=0 and running then p:SetAttribute("AlnairSprinting",false);updatePlayerVitals(p) end
                local m=p:GetAttribute("AlnairMaxMana") or 0
                p:SetAttribute("AlnairMana",math.min(m,(p:GetAttribute("AlnairMana") or m)+2))
            end
        end
    end
end)
-- Exploracao: servidor revela apenas celulas proximas do avatar real.
task.spawn(function()
    while true do
        task.wait(2.2)
        for _,player in ipairs(Players:GetPlayers()) do
            local mode=player:GetAttribute("AlnairMode")
            if mode=="campaign_map" then
                local rootPart=characterRoot(player)
                if rootPart then
                    if math.abs(rootPart.Position.X)<=Rules.MAP_SIZE/2 and
                        math.abs(rootPart.Position.Z)<=Rules.MAP_SIZE/2 then
                        Profiles.discovery(player,rootPart.Position.X,rootPart.Position.Z)
                    end
                end
            end
        end
    end
end)

-- Ranking compartilhado no lobby (em Studio e uma placa de testes).
local board=Workspace:FindFirstChild("AlnairGameplayWorld")
board=board and board:FindFirstChild("LobbySocial")
board=board and board:FindFirstChild("Quadro das Lendas")
if board then
    local surface=Instance.new("SurfaceGui")
    surface.Face=Enum.NormalId.Front
    surface.CanvasSize=Vector2.new(850,650)
    surface.Name="RankingAlnair"
    surface.Parent=board
    local background=Instance.new("Frame")
    background.Size=UDim2.fromScale(1,1)
    background.BackgroundColor3=Color3.fromRGB(14,19,29)
    background.BackgroundTransparency=.08
    background.Parent=surface
    local text=Instance.new("TextLabel")
    text.Name="RankList";text.Size=UDim2.fromScale(.94,.94)
    text.Position=UDim2.fromScale(.03,.03);text.BackgroundTransparency=1
    text.TextColor3=Color3.fromRGB(238,221,184)
    text.Font=Enum.Font.GothamBold;text.TextSize=29
    text.TextYAlignment=Enum.TextYAlignment.Top;text.TextXAlignment=Enum.TextXAlignment.Left
    text.TextWrapped=true;text.Parent=background
    task.spawn(function()
        while board and board.Parent do
            local ranks=Profiles.top(10)
            local lines={"★ LENDAS DE ALNAIR","  RANK    AVENTUREIRO / NIVEL",""}
            for i,data in ipairs(ranks) do
                table.insert(lines,string.format("  %02d     %s    • Nv. %d",i,data.name,data.level or 1))
            end
            if #ranks==0 then table.insert(lines,"Ainda nao existem aventureiros no ranking.") end
            if RunService:IsStudio() then table.insert(lines,"");table.insert(lines,"[ Ranking demonstrativo no Studio ]") end
            text.Text=table.concat(lines,"\n")
            task.wait(90)
        end
    end)
end

-- Gemas somente via ProcessReceipt depois de IDs reais configurados.
-- Nao definir callback sem produtos: evitamos processar pagamentos de outros scripts.
print("[ALNAIR] Gameplay v0.4 carregado. DEV somente Studio; economia e combate no servidor.")
