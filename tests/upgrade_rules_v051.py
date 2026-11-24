from pathlib import Path
R=Path(r"C:\Users\bartk\Desktop\Alnair\src")
p=R/"shared"/"GameRules.lua"
s=p.read_text(encoding="utf-8")
def change(old,new):
 global s
 if old not in s: raise ValueError("ANCHOR NOT FOUND: "+old[:110])
 s=s.replace(old,new,1)
change('GameRules.VERSION = "0.4.0"','GameRules.VERSION = "0.5.1"')
change('goldPrice=180,hpBonus=25','goldPrice=180,hpBonus=25,defense=16,statBonus={vitality=2}')
change('goldPrice=410,hpBonus=50','goldPrice=410,hpBonus=50,defense=10,statBonus={arcana=5}')
change('    {id="arcane_armor",name="Manto do Arcano",kind="armor",desc="Protecao arcana de +50 de vida.",amount=1,goldPrice=410,hpBonus=50,defense=10,statBonus={arcana=5}},\n}', '''    {id="arcane_armor",name="Manto do Arcano",kind="armor",desc="Protecao arcana: +50 vida, +10 defesa, +5 arcano.",amount=1,goldPrice=410,hpBonus=50,defense=10,statBonus={arcana=5}},
    {id="scout_leathers",name="Couro do Explorador",kind="armor",desc="+10 defesa e +3 agilidade.",amount=1,goldPrice=150,defense=10,statBonus={agility=3}},
    {id="steel_cuirass",name="Couraca de Ferro",kind="armor",desc="+28 defesa, +35 vida e +3 vigor.",amount=1,goldPrice=560,defense=28,hpBonus=35,statBonus={vitality=3}},
    {id="dragon_plate",name="Placas do Dragao",kind="armor",desc="+42 defesa, +65 vida e +5 vigor.",amount=1,goldPrice=1150,defense=42,hpBonus=65,statBonus={vitality=5}},
}
GameRules.Attributes = {
    {id="strength",name="FORCA",description="+2 ataque fisico por ponto"},
    {id="agility",name="AGILIDADE",description="+0.14 velocidade e dano agil"},
    {id="vitality",name="VIGOR",description="+8 vida e defesa moderada"},
    {id="arcana",name="ARCANO",description="+dano de magia e habilidades"}
}
GameRules.StartingOutfits = {
    warrior={id="novice_chain",name="Cota do Guerreiro",kind="armor",desc="Cota de aprendiz. +7 defesa.",amount=1,defense=7},
    assassin={id="shadow_leathers",name="Couro da Sombra",kind="armor",desc="Conjunto furtivo. +4 defesa, +2 agilidade.",amount=1,defense=4,statBonus={agility=2}},
    mage={id="apprentice_robe",name="Veste do Aprendiz",kind="armor",desc="Manto arcano. +4 arcano.",amount=1,defense=2,statBonus={arcana=4}},
    fighter={id="fighters_wrap",name="Bandagens do Lutador",kind="armor",desc="Protecao leve. +1 forca, +1 agilidade.",amount=1,defense=2,statBonus={strength=1,agility=1}},
    samurai={id="ronin_haori",name="Haori do Ronin",kind="armor",desc="Armadura do ronin. +5 defesa, +1 agilidade.",amount=1,defense=5,statBonus={agility=1}},
}
function GameRules.itemById(id)
    if typeof(id)~="string" then return nil end
    for _,entry in ipairs(GameRules.Shop) do if entry.id==id then return entry end end
    for _,entry in pairs(GameRules.StartingOutfits) do
        if entry.id==id then return entry end
    end
    if id=="travel_robe" then
        return {id="travel_robe",defense=2,hpBonus=0,kind="armor"}
    end
    if id=="starter_blade" then
        return {id="starter_blade",damageBonus=0,kind="weapon"}
    end
    return nil
end
''')
p.write_text(s,encoding="utf-8",newline="\n")
print("UPDATED GameRules",len(s))
