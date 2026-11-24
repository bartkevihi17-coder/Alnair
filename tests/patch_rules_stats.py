from pathlib import Path
r=Path(r"C:\Users\bartk\Desktop\Alnair")
p=r/"src/shared/GameRules.lua"
s=p.read_text("utf-8")
a=s.index("GameRules.Shop = {")
b=s.index("\nfunction GameRules.xpForNext",a)
s=s[:a]+'''GameRules.ATTRIBUTE_ORDER={"vigor","strength","dexterity","intelligence","endurance"}
GameRules.ATTRIBUTE_INFO={
    vigor={name="Vigor",description="+8 de vida maxima por ponto"},
    strength={name="Forca",description="Aumenta dano de arma e ataques fisicos"},
    dexterity={name="Destreza",description="Melhora dano, velocidade e agilidade"},
    intelligence={name="Inteligencia",description="Aumenta poder das magias"},
    endurance={name="Resistencia",description="Reduz dano sofrido e suporta equipamentos"},
}
GameRules.BASE_ATTRIBUTES={vigor=5,strength=5,dexterity=5,intelligence=5,endurance=5}
GameRules.RACE_ATTRIBUTES={
    human={vigor=1,strength=1,dexterity=1,intelligence=1,endurance=1},
    witch={intelligence=4,dexterity=1,endurance=1},
    undead={vigor=3,endurance=3,strength=1},
    elf={dexterity=3,intelligence=2,endurance=1},
}
GameRules.CLASS_ATTRIBUTES={
    warrior={vigor=2,strength=3,endurance=1},
    assassin={dexterity=4,strength=1,endurance=1},
    mage={intelligence=5,vigor=1},
    fighter={strength=3,vigor=2,endurance=1},
    samurai={dexterity=3,strength=2,endurance=1},
}
GameRules.MAX_ATTRIBUTE=75
GameRules.ATTRIBUTE_POINTS_PER_LEVEL=2
GameRules.STARTER_GEAR={
    starter_blade={id="starter_blade",name="Lamina do Despertar",kind="weapon",damageBonus=2},
    travel_robe={id="travel_robe",name="Manto de Viagem",kind="armor",defenseBonus=3},
    traveler_boots={id="traveler_boots",name="Botas de Viagem",kind="boots",defenseBonus=1},
}
GameRules.Shop = {
    {id="potion",name="Frasco Rubro",kind="consumable",desc="Recupera 60 de vida.",amount=1,goldPrice=35},
    {id="bronze_sword",name="Espada de Bronze",kind="weapon",desc="Arma confiavel: +5 de dano.",amount=1,goldPrice=130,damageBonus=5},
    {id="silver_sword",name="Lamina de Prata",kind="weapon",desc="Lamina reforcada: +13 de dano.",amount=1,goldPrice=320,damageBonus=13},
    {id="vanguard_armor",name="Cota da Vanguarda",kind="armor",desc="+25 vida e +12 defesa.",amount=1,goldPrice=180,hpBonus=25,defenseBonus=12},
    {id="arcane_armor",name="Manto do Arcano",kind="armor",desc="+50 vida, +6 defesa e +8 magia.",amount=1,goldPrice=410,hpBonus=50,defenseBonus=6,magicBonus=8},
    {id="swift_leather",name="Couro do Batedor",kind="armor",desc="+15 vida, +8 defesa e +5% velocidade.",amount=1,goldPrice=270,hpBonus=15,defenseBonus=8,speedBonus=.05},
    {id="guardian_plate",name="Couraca do Guardiao",kind="armor",desc="+75 vida e +25 defesa.",amount=1,goldPrice=720,hpBonus=75,defenseBonus=25},
    {id="runic_robe",name="Vestes de Runas",kind="armor",desc="+35 vida, +9 defesa e +20 magia.",amount=1,goldPrice=630,hpBonus=35,defenseBonus=9,magicBonus=20},
    {id="scout_boots",name="Botas do Explorador",kind="boots",desc="+3 defesa e +4% velocidade.",amount=1,goldPrice=115,defenseBonus=3,speedBonus=.04},
    {id="iron_boots",name="Botas de Ferro",kind="boots",desc="+9 defesa.",amount=1,goldPrice=240,defenseBonus=9},
    {id="sword_of_ashes",name="Espada das Cinzas",kind="weapon",desc="+22 dano. Um eco da primeira estrela.",amount=1,goldPrice=680,damageBonus=22},
}
GameRules.Equipment={}
for id,gear in pairs(GameRules.STARTER_GEAR) do GameRules.Equipment[id]=gear end
for _,gear in ipairs(GameRules.Shop) do
    if gear.kind=="armor" or gear.kind=="weapon" or gear.kind=="boots" then
        GameRules.Equipment[gear.id]=gear
    end
end
''' +s[b:]
p.write_text(s,"utf-8",newline="\n")
print("RULES_EXTENDED",p.stat().st_size)
