--!strict
-- Regras publicas do prototipo Alnair. Nenhuma credencial fica neste modulo.
local GameRules = {}

GameRules.VERSION = "0.4.0"
GameRules.MOUNT_LEVEL = {horse=2, dragon=5}
GameRules.SKILL_LEVELS = {3,5,7,9,11}
GameRules.MAX_SKILLS = 5
GameRules.MAX_LEVEL = 100
GameRules.MAP_SIZE = 640
GameRules.FOG_GRID = 12
GameRules.CAMPAIGN_CENTER = Vector3.new(0, 0, 0)
GameRules.LOBBY_SPAWN = Vector3.new(760, 6, 0)
GameRules.ARENA_SPAWN = Vector3.new(0, 6, 800)
GameRules.CAMPAIGN_SPAWN = Vector3.new(0, 7, 12)
GameRules.DUNGEON_SPAWN = Vector3.new(-155, -46, -126)
GameRules.SKY_SPAWN = Vector3.new(188, 126, 90)
GameRules.GEMS_PRODUCT_IDS = {} -- somente MarketplaceService.ProcessReceipt (IDs futuros)
GameRules.Shop = {
    {id="potion",name="Frasco Rubro",kind="consumable",desc="Recupera 60 de vida.",amount=1,goldPrice=35},
    {id="bronze_sword",name="Espada de Bronze",kind="weapon",desc="Arma confiavel de +5 de dano.",amount=1,goldPrice=130,damageBonus=5},
    {id="silver_sword",name="Lamina de Prata",kind="weapon",desc="Lamina reforcada de +13 de dano.",amount=1,goldPrice=320,damageBonus=13},
    {id="vanguard_armor",name="Cota da Vanguarda",kind="armor",desc="Armadura de +25 de vida.",amount=1,goldPrice=180,hpBonus=25},
    {id="arcane_armor",name="Manto do Arcano",kind="armor",desc="Protecao arcana de +50 de vida.",amount=1,goldPrice=410,hpBonus=50},
}

function GameRules.xpForNext(level)
    return math.floor(60 + 40 * (math.max(1, level) ^ 1.24))
end

GameRules.Cards = {
    {id="iron",name="Pele de Ferro",desc="-15% dano recebido ate o fim da run",stat="armor",value=.15},
    {id="flame",name="Fio Incandescente",desc="+25% de dano",stat="damage",value=.25},
    {id="stride",name="Passos do Vento",desc="+20% velocidade",stat="speed",value=.20},
    {id="heart",name="Coracao de Titanio",desc="+40 vida maxima na run",stat="health",value=40},
    {id="harvest",name="Pacto do Ouro",desc="+35% ouro acumulado",stat="gold",value=.35},
    {id="vampire",name="Sifao Carmesim",desc="Cura 6% do dano causado",stat="leech",value=.06},
    {id="storm",name="Brilho da Tempestade",desc="+15% velocidade de recarga",stat="haste",value=.15},
    {id="arcane",name="Furia Astral",desc="+20% dano elemental",stat="damage",value=.20},
    {id="sanctuary",name="Ultima Prece",desc="Recupera 70 de vida",stat="heal",value=70},
    {id="fortune",name="Runa da Fortuna",desc="+25% experiencia de run",stat="xp",value=.25},
    {id="thorns",name="Espinhos Antigos",desc="+12% reducao de dano",stat="armor",value=.12},
    {id="gale",name="Asas de Cinzas",desc="+16% velocidade",stat="speed",value=.16},
}

GameRules.Quests = {
    {id="awakening",title="A Centelha na Pedra",task="Ative o Fogo Primordial na praca.",kind="interact",target="Brazier",gold=60,xp=60},
    {id="ashes",title="Ossos que se Levantam",task="Derrote 3 esqueletos no Vale das Cinzas.",kind="kill",target="skeleton",count=3,gold=90,xp=95},
    {id="whispers",title="Sussurros da Cripta",task="Encontre e atravesse a entrada da Cripta Afogada.",kind="interact",target="Crypt",gold=110,xp=120},
    {id="warden",title="O Vigia sem Sol",task="Venca o capitao da Cripta Afogada.",kind="kill",target="warden",count=1,gold=160,xp=170},
    {id="sky",title="A Escada do Ceu",task="Acenda o Farol Astral na ilha suspensa.",kind="interact",target="SkyBeacon",gold=260,xp=240},
}
GameRules.Enemies = {
    skeleton={name="Esqueleto Errante",level=1,hp=72,damage=9,range=5,speed=7,aggro=46,xp=26,gold=11,color=Color3.fromRGB(213,209,189)},
    orc={name="Orc da Fenda",level=4,hp=155,damage=19,range=5,speed=8,aggro=52,xp=63,gold=26,color=Color3.fromRGB(87,139,87)},
    witch={name="Bruxa do Breu",level=6,hp=135,damage=24,range=21,speed=7,aggro=65,xp=80,gold=32,color=Color3.fromRGB(137,92,164)},
    dragon={name="Draco das Brumas",level=10,hp=450,damage=45,range=13,speed=9,aggro=75,xp=300,gold=180,color=Color3.fromRGB(144,74,59)},
    warden={name="Vigia sem Sol",level=7,hp=310,damage=27,range=7,speed=7,aggro=60,xp=145,gold=80,color=Color3.fromRGB(98,148,157)},
}

GameRules.Skills = {}
local function skill(id,name,desc,kind,damage,range,cooldown)
    return {id=id,name=name,desc=desc,kind=kind,damage=damage,range=range,cooldown=cooldown}
end
GameRules.Skills.mage = {
    [3]={skill("mage_spark","Lanca Astral","Projetil eletrico","damage",35,35,7),skill("mage_frost","Prisma Gelido","Congela ao redor","damage",28,20,6),skill("mage_fire","Orbe de Fogo","Explosao ardente","damage",43,24,9)},
    [5]={skill("mage_storm","Tormenta","Raio devastador","damage",55,36,11),skill("mage_heal","Selo Vital","Restauracao de vida","heal",65,0,15),skill("mage_shield","Muralha de Mana","Barreira restauradora","shield",20,0,18)},
    [7]={skill("mage_void","Lamina do Vazio","Corte arcano amplo","damage",78,29,13),skill("mage_star","Chuva de Estrelas","Onda de energia","damage",65,40,11),skill("mage_pulse","Pulso Espectral","Pulso proximo","damage",72,18,9)},
    [9]={skill("mage_rune","Runa Explosiva","Fogo runico","damage",103,23,13),skill("mage_seal","Selo da Vida","Curar ferimentos","heal",110,0,20),skill("mage_lance","Lanca Celeste","Feixe penetrante","damage",97,42,12)},
    [11]={skill("mage_comet","Cometa Azul","Magia suprema","damage",150,40,20),skill("mage_blast","Ruptura Astral","Explosao em area","damage",145,22,19),skill("mage_grace","Graca Antiga","Cura suprema","heal",185,0,28)},
}
GameRules.Skills.warrior = {
    [3]={skill("war_cleave","Racha-Escudos","Corte pesado","damage",40,11,6),skill("war_bash","Impacto","Golpe de escudo","damage",36,10,5),skill("war_roar","Grito de Ferro","Cura pela bravura","heal",35,0,12)},
    [5]={skill("war_charge","Investida","Ataque lancado","damage",58,17,9),skill("war_rend","Rasgo","Corte cortante","damage",65,10,9),skill("war_guard","Guardiao","Defesa e vigor","shield",40,0,18)},
    [7]={skill("war_quake","Abalo","Onda de choque","damage",85,18,13),skill("war_pierce","Lanca de Guerra","Perfuracao","damage",89,16,12),skill("war_blood","Vontade de Aco","Regenere energia","heal",80,0,15)},
    [9]={skill("war_fury","Furia do Norte","Golpe brutal","damage",107,15,14),skill("war_crush","Quebra-Reinos","Esmagamento","damage",124,13,17),skill("war_wall","Bastiao","Escudo vital","shield",80,0,25)},
    [11]={skill("war_legend","Ultimo Baluarte","Ataque heroico","damage",170,17,23),skill("war_king","Rei da Tempestade","Ondas de acero","damage",155,26,21),skill("war_aegis","Aegis","Restauracao","heal",165,0,27)},
}
GameRules.Skills.samurai = {
    [3]={skill("sam_draw","Iaijutsu","Saque veloz","damage",46,13,6),skill("sam_slash","Corte Lunar","Lamina em arco","damage",36,16,5),skill("sam_focus","Postura Serena","Recupere vigor","heal",30,0,12)},
    [5]={skill("sam_flurry","Tres Ventos","Tres cortes","damage",68,15,9),skill("sam_vow","Juramento","Foco superior","shield",39,0,18),skill("sam_cross","Cruzamento","Corte duplo","damage",77,12,11)},
    [7]={skill("sam_gale","Vento Partido","Golpe do vento","damage",91,21,12),skill("sam_sakura","Sakura","Danca da lamina","damage",83,18,11),skill("sam_soul","Alma Livre","Curar","heal",89,0,18)},
    [9]={skill("sam_oni","Golpe Oni","Corte profundo","damage",118,15,16),skill("sam_echo","Eco da Katana","Impacto distante","damage",105,29,14),skill("sam_moon","Lua Partida","Corte crepuscular","damage",112,18,15)},
    [11]={skill("sam_destiny","Fio do Destino","Golpe decisivo","damage",174,18,23),skill("sam_dawn","Alvorada","Corte radiante","damage",164,30,22),skill("sam_guard","Mente Vazia","Purificacao","heal",175,0,28)},
}
GameRules.Skills.assassin = {
    [3]={skill("ass_back","Passo Sombrio","Ataque rapido","damage",41,16,5),skill("ass_dagger","Adaga Venenosa","Golpe de veneno","damage",37,17,5),skill("ass_smoke","Cortina de Fumaca","Recupere folego","heal",30,0,11)},
    [5]={skill("ass_burst","Chuva de Laminas","Ataque em leque","damage",66,16,9),skill("ass_cobra","Cobra Noturna","Perfuracao","damage",69,20,10),skill("ass_veil","Veu","Escudo fugaz","shield",35,0,17)},
    [7]={skill("ass_shadow","Danca Sombria","Golpe silencioso","damage",94,19,12),skill("ass_chain","Correntes","Ataques sequenciais","damage",87,21,10),skill("ass_drink","Sede de Sangue","Cura","heal",82,0,17)},
    [9]={skill("ass_night","Noite sem Fim","Ataque furtivo","damage",114,26,14),skill("ass_venom","Picada Mortal","Veneno","damage",121,19,16),skill("ass_flash","Clarão Oculto","Golpe luminoso","damage",116,23,15)},
    [11]={skill("ass_reaper","Ceifador","Ataque final","damage",178,23,22),skill("ass_fang","Presa Final","Perfure a escuridao","damage",167,31,23),skill("ass_heart","Coracao Livre","Cura rapida","heal",166,0,26)},
}
GameRules.Skills.fighter = {
    [3]={skill("fig_upper","Uppercut","Golpe ascendente","damage",37,8,4),skill("fig_round","Giro","Chute circular","damage",42,10,5),skill("fig_breath","Respirar","Recupere vida","heal",29,0,10)},
    [5]={skill("fig_combo","Combo de Punhos","Sequencia poderosa","damage",64,10,9),skill("fig_kick","Chute de Vento","Golpe a distancia","damage",67,17,10),skill("fig_stance","Postura de Pedra","Fortaleca defesa","shield",38,0,17)},
    [7]={skill("fig_storm","Vendaval","Ataque circular","damage",86,14,11),skill("fig_dash","Avanco","Investida corporal","damage",91,18,12),skill("fig_center","Centro","Recuperacao","heal",85,0,16)},
    [9]={skill("fig_earth","Punho Terrestre","Abalo no solo","damage",115,19,15),skill("fig_dragon","Punho do Dragao","Golpe ancestral","damage",120,11,16),skill("fig_burst","Ruptura","Impacto forte","damage",117,16,15)},
    [11]={skill("fig_titan","Punho Titanico","Golpe supremo","damage",172,20,22),skill("fig_star","Estrela Cadente","Ataque aereo","damage",158,29,23),skill("fig_lotus","Lotus","Restauracao","heal",175,0,27)},
}

function GameRules.skillById(classId, skillId)
    local tiers=GameRules.Skills[classId]
    if not tiers then return nil end
    for _,pool in pairs(tiers) do
        for _,info in ipairs(pool) do
            if info.id == skillId then return info end
        end
    end
    return nil
end

return GameRules
