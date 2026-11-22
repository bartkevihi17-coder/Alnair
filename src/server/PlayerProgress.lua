--!strict
-- Perfil persistente, progressao, escolhas irreversiveis e nevoa de guerra.
-- O cliente nunca modifica dados; todas as escritas partem do servidor.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("GameRules"))

local Profile = {}
local cache = {}
local writable = {}
local notify = function(_player) end
local store = DataStoreService:GetDataStore("Alnair_Profile_v04")
local ranks = DataStoreService:GetOrderedDataStore("Alnair_Rank_v04")
local defaultInventory = {
    {id="starter_blade",name="Lamina do Despertar",kind="weapon",desc="Espada antiga, ainda afiada.",amount=1},
    {id="travel_robe",name="Manto de Viagem",kind="armor",desc="Tecido recuperado do Primeiro Fogo.",amount=1},
    {id="potion",name="Frasco Rubro",kind="consumable",desc="Restaura 60 de vida.",amount=3},
}

local function fresh()
    local inv={}
    for _,item in ipairs(defaultInventory) do
        table.insert(inv,table.clone(item))
    end
    return {
        version=4,level=1,xp=0,gold=0,gems=0,kills=0,bestWave=0,questIndex=1,
        questCount=0,skills={},rejected={},drafts={},inventory=inv,
        equipped={weapon="starter_blade",armor="travel_robe"},visited={},
        rivals={},unlockedMaps={["1"]=true},achievements={},seconds=0,
    }
end

local function integer(x,minVal,maxVal,otherwise)
    if typeof(x)~="number" or x~=x then return otherwise end
    return math.clamp(math.floor(x),minVal,maxVal)
end

local function clean(input)
    local base=fresh()
    if typeof(input)~="table" then return base end
    for _,key in ipairs({"level","xp","gold","gems","kills","bestWave","questIndex","questCount","seconds"}) do
        local maxVal = (key=="level" and Rules.MAX_LEVEL)
            or (key=="questIndex" and #Rules.Quests+1)
            or 100000000
        local minVal=(key=="level" or key=="questIndex") and 1 or 0
        base[key]=integer(input[key],minVal,maxVal,base[key])
    end
    for _,key in ipairs({"skills","rejected","drafts","inventory","equipped","visited","rivals","unlockedMaps","achievements"}) do
        if typeof(input[key])=="table" then base[key]=input[key] end
    end
    return base
end

function Profile.setNotifier(fn) notify=fn end
function Profile.get(player) return cache[player] end
function Profile.ready(player) return cache[player]~=nil end
function Profile.load(player)
    if cache[player] then return cache[player] end
    local data=nil
    local canSave=false
    if not RunService:IsStudio() then
        local success,result=pcall(function() return store:GetAsync(tostring(player.UserId)) end)
        if success then data=result;canSave=true
        else warn("[ALNAIR] DataStore indisponivel; sessao temporaria:",result) end
    end
    if not player.Parent then return nil end
    local record=clean(data)
    cache[player]=record
    writable[player]=canSave
    player:SetAttribute("AlnairLevel",record.level)
    player:SetAttribute("AlnairGold",record.gold)
    player:SetAttribute("AlnairGems",record.gems)
    player:SetAttribute("AlnairQuest",record.questIndex)
    for kind,value in pairs(record.rivals) do
        if Rules.Enemies[kind] then
            player:SetAttribute("AlnairRival_"..kind,integer(value,0,6,0))
        end
    end
    notify(player)
    return record
end

function Profile.snapshot(player)
    local p=cache[player]
    if not p then return nil end
    local cls=player:GetAttribute("AlnairClass") or "warrior"
    local current=Rules.Quests[p.questIndex]
    local pending=nil
    for _,level in ipairs(Rules.SKILL_LEVELS) do
        if level<=p.level and p.drafts[tostring(level)] and not p.drafts[tostring(level)].chosen then
            pending=p.drafts[tostring(level)]
            break
        end
    end
    return {
        level=p.level,xp=p.xp,xpNext=Rules.xpForNext(p.level),gold=p.gold,gems=p.gems,
        kills=p.kills,bestWave=p.bestWave,questIndex=p.questIndex,
        quest=current and {title=current.title,task=current.task,progress=p.questCount,total=current.count or 1} or nil,
        skills=table.clone(p.skills),rejected=table.clone(p.rejected),
        draft=pending and {level=pending.level,options=table.clone(pending.options)} or nil,
        inventory=table.clone(p.inventory),equipped=table.clone(p.equipped),
        fog=table.clone(p.visited),class=cls,race=player:GetAttribute("AlnairRace") or "human",
        mounted=player:GetAttribute("AlnairMount") or "",mode=player:GetAttribute("AlnairMode") or "menu",
        mapUnlocked=table.clone(p.unlockedMaps),
        dev=(player:GetAttribute("AlnairDev")==true),
    }
end

local function updateAttributes(player,p)
    player:SetAttribute("AlnairLevel",p.level)
    player:SetAttribute("AlnairGold",p.gold)
    player:SetAttribute("AlnairGems",p.gems)
    player:SetAttribute("AlnairQuest",p.questIndex)
end

function Profile.touch(player)
    local p=cache[player]
    if p then updateAttributes(player,p);notify(player) end
end

local function createDrafts(player)
    local p=cache[player]
    if not p then return end
    local className=player:GetAttribute("AlnairClass") or "warrior"
    local poolByLevel=Rules.Skills[className] or Rules.Skills.warrior
    for _,level in ipairs(Rules.SKILL_LEVELS) do
        local id=tostring(level)
        if p.level>=level and not p.drafts[id] then
            local skills=poolByLevel[level]
            if skills then
                p.drafts[id]={level=level,options={skills[1].id,skills[2].id,skills[3].id},chosen=nil}
            end
        end
    end
end

function Profile.ensureDraft(player)
    createDrafts(player)
    Profile.touch(player)
end

function Profile.addXP(player,amount)
    local p=cache[player];if not p then return 0 end
    local bonus=integer(amount,0,500000,0)
    p.xp+=bonus
    local gained=0
    while p.level<Rules.MAX_LEVEL and p.xp>=Rules.xpForNext(p.level) do
        p.xp-=Rules.xpForNext(p.level)
        p.level+=1
        gained+=1
    end
    if p.level>=Rules.MAX_LEVEL then p.xp=0 end
    createDrafts(player)
    Profile.touch(player)
    return gained
end

function Profile.setLevel(player,level)
    local p=cache[player];if not p then return end
    p.level=integer(level,1,Rules.MAX_LEVEL,1)
    p.xp=0
    createDrafts(player)
    Profile.touch(player)
end

function Profile.addGold(player,amount)
    local p=cache[player];if not p then return end
    p.gold=integer(p.gold+integer(amount,-1000000,1000000,0),0,100000000,p.gold)
    Profile.touch(player)
end

function Profile.addPurchasedGems(player,amount)
    local p=cache[player];if not p then return end
    p.gems=integer(p.gems+integer(amount,-1000000,1000000,0),0,100000000,p.gems)
    Profile.touch(player)
end

function Profile.chooseSkill(player,id)
    local p=cache[player];if not p or typeof(id)~="string" then return false,"Escolha invalida" end
    if #p.skills>=Rules.MAX_SKILLS then return false,"Limite de habilidades atingido" end
    local class=player:GetAttribute("AlnairClass") or "warrior"
    for _,level in ipairs(Rules.SKILL_LEVELS) do
        local draft=p.drafts[tostring(level)]
        if draft and draft.chosen==nil then
            if not table.find(draft.options,id) then return false,"Habilidade fora das 3 opcoes" end
            if not Rules.skillById(class,id) then return false,"Habilidade incompativel" end
            if table.find(p.skills,id) or table.find(p.rejected,id) then return false,"Escolha ja resolvida" end
            draft.chosen=id
            table.insert(p.skills,id)
            for _,skillId in ipairs(draft.options) do
                if skillId~=id then table.insert(p.rejected,skillId) end
            end
            Profile.touch(player)
            return true,"Habilidade adquirida: "..Rules.skillById(class,id).name
        end
    end
    return false,"Nenhum talento aguardando escolha"
end

local function equippedBonus(record,slot,bonusKey)
    if not record then return 0 end
    local equipped=record.equipped and record.equipped[slot]
    for _,entry in ipairs(Rules.Shop) do
        if entry.id==equipped then
            return entry[bonusKey] or 0
        end
    end
    return 0
end
function Profile.maxHealth(player)
    local p=cache[player]
    return 100+((p and p.level or 1)-1)*12+equippedBonus(p,"armor","hpBonus")
end
function Profile.attackPower(player)
    local p=cache[player]
    return 22+((p and p.level or 1)-1)*3+equippedBonus(p,"weapon","damageBonus")
end

function Profile.buy(player,itemId)
    local p=cache[player]
    if not p or typeof(itemId)~="string" then return false,"Compra invalida." end
    for _,entry in ipairs(Rules.Shop) do
        if entry.id==itemId then
            local cost=entry.goldPrice
            if p.gold<cost then return false,"Ouro insuficiente." end
            p.gold-=cost
            Profile.addItem(player,entry)
            Profile.touch(player)
            return true,"Compra: "..entry.name.." (-"..cost.." ouro)"
        end
    end
    return false,"Mercadoria indisponivel."
end

function Profile.addItem(player,item)
    local p=cache[player];if not p or typeof(item)~="table" then return end
    for _,old in ipairs(p.inventory) do
        if old.id==item.id then
            old.amount=integer((old.amount or 0)+(item.amount or 1),0,999,1)
            Profile.touch(player)
            return
        end
    end
    table.insert(p.inventory,{id=item.id,name=item.name or item.id,kind=item.kind or "material",desc=item.desc or "",amount=integer(item.amount,1,999,1)})
    Profile.touch(player)
end

function Profile.usePotion(player)
    local p=cache[player];if not p then return false end
    local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health<=0 or humanoid.Health>=humanoid.MaxHealth then return false end
    for _,item in ipairs(p.inventory) do
        if item.id=="potion" and item.amount>0 then
            item.amount-=1
            humanoid.Health=math.min(humanoid.MaxHealth,humanoid.Health+60)
            Profile.touch(player)
            return true
        end
    end
    return false
end

function Profile.equip(player,itemId)
    local p=cache[player];if not p or typeof(itemId)~="string" then return false end
    for _,item in ipairs(p.inventory) do
        if item.id==itemId and item.amount>0 and (item.kind=="weapon" or item.kind=="armor") then
            p.equipped[item.kind]=item.id
            Profile.touch(player)
            return true
        end
    end
    return false
end

function Profile.discovery(player,x,z)
    local p=cache[player];if not p then return end
    local g=Rules.FOG_GRID
    local gx=math.clamp(math.floor((x+Rules.MAP_SIZE/2)/Rules.MAP_SIZE*g),0,g-1)
    local gz=math.clamp(math.floor((z+Rules.MAP_SIZE/2)/Rules.MAP_SIZE*g),0,g-1)
    local dirty=false
    for dx=-1,1 do
        for dz=-1,1 do
            if math.abs(dx)+math.abs(dz)<=1 then
                local xx=gx+dx;local zz=gz+dz
                if xx>=0 and xx<g and zz>=0 and zz<g then
                    local key=tostring(xx).."_"..tostring(zz)
                    if not p.visited[key] then p.visited[key]=true;dirty=true end
                end
            end
        end
    end
    if dirty then notify(player) end
end

function Profile.quest(player,kind,target,qty)
    local p=cache[player];if not p then return false end
    local q=Rules.Quests[p.questIndex]
    if not q or q.kind~=kind or q.target~=target then return false end
    p.questCount+=integer(qty or 1,1,50,1)
    if p.questCount>=(q.count or 1) then
        p.questIndex+=1;p.questCount=0
        Profile.addXP(player,q.xp)
        Profile.addGold(player,q.gold)
        Profile.addItem(player,{id="rune_fragment",name="Fragmento Astral",kind="material",desc="Fragmento encontrado nas ruinas.",amount=1})
    end
    Profile.touch(player)
    return true
end

function Profile.enemyKill(player,enemyKind,gold,xp,mode)
    local p=cache[player];if not p then return end
    p.kills+=1
    if mode~="sandbox" then
        Profile.addXP(player,xp)
        Profile.addGold(player,gold)
        Profile.quest(player,"kill",enemyKind,1)
    else
        Profile.touch(player)
    end
end

function Profile.rivalMemory(player,enemyKind)
    local p=cache[player];if not p then return end
    local n=integer(p.rivals[enemyKind],0,20,0)
    p.rivals[enemyKind]=math.min(n+1,6)
    player:SetAttribute("AlnairRival_"..enemyKind,p.rivals[enemyKind])
    notify(player)
end

function Profile.defeatRival(player,enemyKind,rank)
    local p=cache[player]
    if not p or rank<=0 then return end
    p.rivals[enemyKind]=0
    player:SetAttribute("AlnairRival_"..enemyKind,0)
    Profile.addItem(player,{id="rival_seal",name="Selo do Rival",kind="material",desc="Prova de um inimigo vencido.",amount=1})
    Profile.addGold(player,rank*28)
    Profile.addXP(player,rank*25)
    Profile.touch(player)
end

function Profile.save(player)
    local p=cache[player];if not p or not writable[player] or RunService:IsStudio() then return false end
    local payload=clean(p)
    local ok,err=pcall(function()
        store:UpdateAsync(tostring(player.UserId),function(_previous) return payload end)
        ranks:SetAsync(tostring(player.UserId),p.level*100000+p.kills)
    end)
    if not ok then warn("[ALNAIR] Erro ao salvar perfil:",err) end
    return ok
end

function Profile.top(limit)
    if RunService:IsStudio() then return {{name="TESTE LOCAL",score=0}} end
    local ok,result=pcall(function()return ranks:GetSortedAsync(false,limit or 10) end)
    if not ok then return {} end
    local arr={}
    for _,row in ipairs(result:GetCurrentPage()) do
        local okName,name=pcall(function()return Players:GetNameFromUserIdAsync(tonumber(row.key)) end)
        table.insert(arr,{name=okName and name or "Aventureiro",score=row.value,level=math.floor(row.value/100000)})
    end
    return arr
end

function Profile.unload(player)
    Profile.save(player)
    cache[player]=nil
    writable[player]=nil
end

return Profile
