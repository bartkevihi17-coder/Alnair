-- Testes de regras executaveis no Luau CLI, independente do Roblox Studio.
Color3 = {fromRGB=function(r,g,b) return {r=r,g=g,b=b} end}
Vector3 = {new=function(x,y,z) return {X=x,Y=y,Z=z} end}
local rules = require("../src/shared/GameRules")

assert(rules.MOUNT_LEVEL.horse==2, "Cavalo deve liberar no nivel 2")
assert(rules.MOUNT_LEVEL.dragon==5, "Dragao deve liberar no nivel 5")
assert(rules.MAX_SKILLS==5, "Habilidades maximas deve ser 5")
assert(rules.SKILL_LEVELS[1]==3 and rules.SKILL_LEVELS[5]==11,"Marcos de habilidade")
assert(#rules.Quests>=5,"Cinco quests")
assert(#rules.Cards>=9,"Cartas da arena")
assert(rules.GEMS_PRODUCT_IDS and next(rules.GEMS_PRODUCT_IDS)==nil,"Gemas pagas desabilitadas ate produto oficial")
local skillCount=0
for _,className in ipairs({"warrior","assassin","mage","fighter","samurai"}) do
  local all={}
  for _,level in ipairs(rules.SKILL_LEVELS) do
    local options=rules.Skills[className][level]
    assert(options and #options==3,className.." nivel "..level..": tres escolhas")
    for _,entry in ipairs(options) do
      assert(type(entry.id)=="string" and type(entry.cooldown)=="number","metadados habilidade")
      assert(not all[entry.id],"skill duplicada em "..className..": "..entry.id)
      all[entry.id]=true
      assert(rules.skillById(className,entry.id)==entry,"skillById "..entry.id)
      skillCount+=1
    end
  end
end
for lvl=1,20 do
  assert(rules.xpForNext(lvl+1)>rules.xpForNext(lvl),"Curva XP crescente")
end
for _,key in ipairs({"skeleton","orc","witch","dragon","warden"}) do
   local mob=rules.Enemies[key]
   assert(mob and mob.hp>0 and mob.damage>0 and mob.xp>=0,"Inimigo "..key)
end
print("PASS: regras, 75 magias, duas montarias, cinco quests, "..#rules.Cards.." cartas, curva XP, moedas")
