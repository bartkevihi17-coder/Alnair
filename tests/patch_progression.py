from pathlib import Path
f=Path(r"C:\Users\bartk\Desktop\Alnair\src\server\PlayerProgress.lua")
s=f.read_text("utf-8")
def patch(old,new):
 global s
 if old not in s:raise Exception("missing "+repr(old[:100]))
 s=s.replace(old,new,1)
 print("PATCH",old[:63].replace("\n"," "))
patch('''    {id="travel_robe",name="Manto de Viagem",kind="armor",desc="Tecido recuperado do Primeiro Fogo.",amount=1},''',
'''    {id="travel_robe",name="Manto de Viagem",kind="armor",desc="Tecido recuperado do Primeiro Fogo.",amount=1},
    {id="traveler_boots",name="Botas de Viagem",kind="boots",desc="Botas de couro reforcado.",amount=1},''')
patch('''        equipped={weapon="starter_blade",armor="travel_robe"},visited={},''',
'''        equipped={weapon="starter_blade",armor="travel_robe",boots="traveler_boots"},
        attributes={},visited={},''')
patch('''    return base
end

function Profile.setNotifier''',
'''    local purchased=typeof(input.attributes)=="table" and input.attributes or {}
    local remaining=math.max(0,(base.level-1)*Rules.ATTRIBUTE_POINTS_PER_LEVEL)
    for _,attr in ipairs(Rules.ATTRIBUTE_ORDER) do
        local claimed=integer(purchased[attr],0,Rules.MAX_ATTRIBUTE,0)
        base.attributes[attr]=math.min(remaining,claimed)
        remaining-=base.attributes[attr]
    end
    if typeof(base.equipped)~="table" then base.equipped={} end
    base.equipped.weapon=Rules.Equipment[base.equipped.weapon] and base.equipped.weapon or "starter_blade"
    base.equipped.armor=Rules.Equipment[base.equipped.armor] and base.equipped.armor or "travel_robe"
    base.equipped.boots=Rules.Equipment[base.equipped.boots] and base.equipped.boots or "traveler_boots"
    return base
end

local function calculate(player,p)
    local race=player:GetAttribute("AlnairRace") or "human"
    local class=player:GetAttribute("AlnairClass") or "warrior"
    local raceBonus=Rules.RACE_ATTRIBUTES[race] or Rules.RACE_ATTRIBUTES.human
    local classBonus=Rules.CLASS_ATTRIBUTES[class] or Rules.CLASS_ATTRIBUTES.warrior
    local values={}
    local spent=0
    for _,key in ipairs(Rules.ATTRIBUTE_ORDER) do
        local allocated=math.max(0,tonumber(p.attributes[key]) or 0)
        spent+=allocated
        values[key]=(Rules.BASE_ATTRIBUTES[key] or 5)+(raceBonus[key] or 0)+(classBonus[key] or 0)+allocated
    end
    local budget=math.max(0,(p.level-1)*Rules.ATTRIBUTE_POINTS_PER_LEVEL)
    return values,math.max(0,budget-spent),spent
end
function Profile.attributes(player)
    local p=cache[player]
    if not p then return nil end
    local values,available,spent=calculate(player,p)
    return {values=values,available=available,spent=spent,allocated=table.clone(p.attributes)}
end
function Profile.allocateAttribute(player,key)
    local p=cache[player]
    if not p or typeof(key)~="string" or not Rules.ATTRIBUTE_INFO[key] then
        return false,"Atributo invalido."
    end
    local values,remaining=calculate(player,p)
    if remaining<=0 then return false,"Sem pontos de atributo disponiveis." end
    local current=p.attributes[key] or 0
    if current>=Rules.MAX_ATTRIBUTE then return false,"Limite de atributo atingido." end
    p.attributes[key]=current+1
    Profile.touch(player)
    return true,Rules.ATTRIBUTE_INFO[key].name.." melhorado: "..tostring(values[key]+1)
end

function Profile.setNotifier''')
patch('''    local pending=nil
    for _,level in ipairs(Rules.SKILL_LEVELS) do''',
'''    local pending=nil
    local attributes=Profile.attributes(player)
    for _,level in ipairs(Rules.SKILL_LEVELS) do''')
patch('''        inventory=table.clone(p.inventory),equipped=table.clone(p.equipped),''',
'''        inventory=table.clone(p.inventory),equipped=table.clone(p.equipped),
        attributes=attributes,defense=Profile.defense(player),attack=Profile.attackPower(player),''')
start=s.index("local function equippedBonus")
end=s.index("\nfunction Profile.buy",start)
s=s[:start]+'''local function equippedBonus(record,slot,bonusKey)
    if not record or not record.equipped then return 0 end
    local item=Rules.Equipment[record.equipped[slot]]
    return item and item[bonusKey] or 0
end
function Profile.maxHealth(player)
    local p=cache[player]
    if not p then return 100 end
    local stats=calculate(player,p)
    return math.floor(100+(p.level-1)*9+stats.vigor*8+equippedBonus(p,"armor","hpBonus"))
end
function Profile.attackPower(player)
    local p=cache[player]
    if not p then return 20 end
    local stats=calculate(player,p)
    local class=player:GetAttribute("AlnairClass") or "warrior"
    local scaling=stats.strength*1.2+stats.dexterity*.65
    if class=="mage" then scaling=stats.intelligence*1.7+stats.dexterity*.35 end
    return math.floor(17+(p.level-1)*2+scaling+equippedBonus(p,"weapon","damageBonus")
        +(class=="mage" and equippedBonus(p,"armor","magicBonus") or 0))
end
function Profile.defense(player)
    local p=cache[player]
    if not p then return 0 end
    local stats=calculate(player,p)
    return math.floor(stats.endurance*1.3+
        equippedBonus(p,"armor","defenseBonus")+
        equippedBonus(p,"boots","defenseBonus"))
end
function Profile.damageMitigation(player)
    local def=Profile.defense(player)
    return math.clamp(def/(def+100),0,.58)
end
function Profile.speedBonus(player)
    local p=cache[player]
    if not p then return 0 end
    local stats=calculate(player,p)
    return math.clamp((stats.dexterity-5)*.004+
        equippedBonus(p,"boots","speedBonus")+
        equippedBonus(p,"armor","speedBonus"),0,.24)
end
''' + s[end:]
patch('''            if p.gold<cost then return false,"Ouro insuficiente." end
            p.gold-=cost''',
'''            if p.gold<cost then return false,"Ouro insuficiente." end
            if entry.kind~="consumable" then
                for _,existing in ipairs(p.inventory) do
                    if existing.id==itemId and existing.amount>0 then
                        return false,"Voce ja possui este equipamento."
                    end
                end
            end
            p.gold-=cost''')
patch('''(item.kind=="weapon" or item.kind=="armor") then''',
'''(item.kind=="weapon" or item.kind=="armor" or item.kind=="boots") then''')
f.write_text(s,"utf-8",newline="\n")
print("PROFILE_UPDATED",len(s))
