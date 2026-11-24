--!strict
-- Catálogo único da UI, dos avatares e da validação no servidor.
local Catalog = {}

Catalog.RaceOrder = { "human", "witch", "undead", "elf" }
Catalog.Races = {
    human = {
        name = "Humano", title = "O espírito indomável",
        description = "Versátil, resistente e acostumado a sobreviver a qualquer reino.",
        color = Color3.fromRGB(203, 156, 118), accent = Color3.fromRGB(222, 178, 114),
    },
    witch = {
        name = "Bruxa", title = "O sangue arcano",
        description = "A magia antiga deixa marcas na pele e na própria alma.",
        color = Color3.fromRGB(181, 157, 207), accent = Color3.fromRGB(163, 117, 233),
    },
    undead = {
        name = "Morto-vivo", title = "A segunda existência",
        description = "De volta do silêncio, movido por uma vontade que desafia a morte.",
        color = Color3.fromRGB(160, 187, 167), accent = Color3.fromRGB(128, 202, 167),
    },
    elf = {
        name = "Elfo", title = "Filho da floresta",
        description = "Elegância ancestral, sentidos aguçados e ligação com a natureza.",
        color = Color3.fromRGB(230, 197, 166), accent = Color3.fromRGB(174, 215, 164),
    },
}

Catalog.ClassOrder = { "warrior", "assassin", "mage", "fighter", "samurai" }
Catalog.Classes = {
    warrior = { name = "Guerreiro", weapon = "Espada + escudo", description = "O aço e a coragem são sua primeira defesa.", accent = Color3.fromRGB(214, 163, 94) },
    assassin = { name = "Assassino", weapon = "Duas adagas", description = "Movimentos rápidos, ataques precisos e furtividade.", accent = Color3.fromRGB(189, 125, 185) },
    mage = { name = "Mago", weapon = "Cajado", description = "Busca os mistérios que governam os elementos.", accent = Color3.fromRGB(125, 171, 227) },
    fighter = { name = "Lutador", weapon = "Punhos", description = "O próprio corpo é sua arma.", accent = Color3.fromRGB(216, 128, 114) },
    samurai = { name = "Samurai", weapon = "Katana", description = "Disciplina, precisão e uma lâmina sem igual.", accent = Color3.fromRGB(206, 115, 104) },
}

-- Apenas IDs REAIS do Marketplace oficial Roblox, todos checados dentro do
-- Roblox Studio com MarketplaceService:GetProductInfo. Nenhum cabelo, rosto,
-- chapéu ou roupa desenhado com Parts e nenhum ativo que exija Robux.
-- Rostos classicos podem estar fora de venda, mas são assets Roblox reais
-- com preço histórico zero e funcionam em HumanoidDescription.Face.
-- Calca NeoClassic faz parte do pacote GRATUITO Cindy, criado pela Roblox.
-- IDs internos anteriores preservados quando possivel para manter escolhas.
Catalog.PresetOrder = { "face", "hair", "hat", "outer3d", "upper", "lower", "set" }
Catalog.Presets = {
    face = {
        name = "Rosto oficial Roblox",
        options = {
            {id="serene",name="Fica Frio (Chill)",assetId=7074764},
            {id="determined",name="Saca Só (Check It)",assetId=7074786},
            {id="mysterious",name="Rosto de Homem",assetId=86487700},
            {id="happy",name="Diversão Pateta",assetId=7699174},
            {id="warrior",name="Sorriso clássico",assetId=144075659},
            {id="shadow",name="Rosto de Mulher",assetId=86487766},
            {id="ghost",name="Fantasmagórico (Ghostface)",assetId=12467159},
            {id="stare",name="Olhar Frio (Stare)",assetId=8560971},
        },
    },
    hair = {
        name = "Cabelo oficial Roblox",
        options = {
            {id="short",name="Cabelo de Parceiro",assetId=63690008},
            {id="fringe",name="Cabelo Encantador Castanho",assetId=376548738},
            {id="long",name="Cabelo longo Roblox Girl",assetId=48474294},
            {id="mohawk",name="Loiro Espetado",assetId=376524487},
            {id="bun",name="Penteado Alto de Lavanda",assetId=451220849},
            {id="blue",name="Cabelo Azul Verdadeiro",assetId=451221329},
            {id="brown",name="Cabelo Castanho",assetId=62234425},
            {id="bald",name="Sem cabelo",assetId=0},
        },
    },
    hat = {
        name = "Chapéus oficiais Roblox",
        options = {
            {id="class",name="Cabeça protegida (classe)",assetId=0},
            {id="none",name="Sem chapéu",assetId=0},
            {id="hood",name="Capuz Medieval do Mistério",assetId=617605556},
            {id="cap",name="Boné de Beisebol Roblox",assetId=607702162},
            {id="redcap",name="Boné 'R' Roblox",assetId=417457461},
            {id="knighthelm",name="Elmo dos Cavaleiros de Redcliff",assetId=2493590711},
        },
    },
    outer3d = {
        name = "Trajes 3D da classe",
        options = {
            {id="class",name="Equipamento de classe",assetId=0},
            {id="knight-dark",name="Couraça de viagem escura",assetId=7192549218,classes={"warrior"}},
            {id="knight-brown",name="Cota de couro castanho",assetId=6984767443,classes={"warrior"}},
            {id="rogue-dark",name="Couro sombrio de batedor",assetId=7192549218,classes={"assassin"}},
            {id="rogue-hood",name="Manto cinza de batedor",assetId=8516620262,classes={"assassin"}},
            {id="ritual-purple",name="Vestes longas da Feiticeira",assetId=78121746609585,classes={"mage"}},
            {id="ritual-blue",name="Vestes do Arcano Azul",assetId=78121746609585,classes={"mage"}},
            {id="brawler-leather",name="Proteção leve de couro",assetId=6984767443,classes={"fighter"}},
            {id="brawler-dark",name="Couro de combate escuro",assetId=7192549218,classes={"fighter"}},
            {id="ronin-maroon",name="Hakama Carmesim",assetId=9240776381,classes={"samurai"}},
            {id="ronin-blue",name="Hakama Azul",assetId=78121746609585,classes={"samurai"}},
        },
    },
    upper = {
        name = "Camisas clássicas Roblox",
        options = {
            {id="tunic",name="Jaqueta Roblox",assetId=607785314},
            {id="forest",name="Blusão Verde",assetId=382538059},
            {id="leather",name="Jeans e Moletom Branco",assetId=398633584},
            {id="armor",name="Camisa de Motoqueiro",assetId=144076358},
            {id="robe",name="Camiseta Roxa e Verde-Azulada",assetId=4047886060},
            {id="linen",name="Padrão Simples Roblox",assetId=3670737444},
            {id="bare",name="Camisa Azul-Esverdeada",assetId=382537702},
        },
    },
    lower = {
        name = "Calças clássicas Roblox",
        options = {
            {id="pants",name="Jeans Verde Escuro",assetId=144076760},
            {id="leather",name="Calças Rasgadas de Skatista",assetId=398635338},
            {id="hakama",name="Calças NeoClassic Cindy",assetId=4637612548},
        },
    },
    set = {
        name = "Conjuntos Roblox",
        options = {
            {id="none",name="Personalizado",upper=nil,lower=nil},
            {id="traveler",name="Viajante Roblox",upper="tunic",lower="pants"},
            {id="guardian",name="Guardião Urbano",upper="armor",lower="leather"},
            {id="arcanist",name="Explorador Arcano",upper="robe",lower="hakama"},
            {id="ronin",name="Viajante Sombrio",upper="leather",lower="pants"},
        },
    },
}
-- Acessórios de avatar do catálogo OFICIAL Roblox, checados no Studio
-- em 23/11/2026: criador Roblox, preço 0, tipo 46 (Back).
-- SÃO acessórios de verdade do HumanoidDescription, não modelos artificiais.
Catalog.FreeRobloxBack={
    dog=98752422639730, -- Dog Backpack
    green=117627132830661, -- Green Block
    red=115223868209681, -- Red Block
    aura=100061531345826, -- Roblox Knowledge Aura
    yellow=106228206889859, -- Yellow Block
    silver=71409823493730, -- Silver Block
}
Catalog.FreeRobloxShoulder=119934643965525 -- Starwisp, tipo 44, grátis

-- ROUPAS 3D AUTÊNTICAS da Roblox (WrapLayer + pele R15).
-- Todas verificadas no MarketplaceService da instância Studio real:
-- criador "Roblox", preco 0; tipos JacketAccessory (67),
-- SweaterAccessory (68), PantsAccessory (66).
-- Nenhuma camiseta 2D pode substituir um colete/armadura 3D.
Catalog.Official3DLayered={
    leatherBlack=7192549218,  -- Leather Jacket Black
    leatherBrown=6984767443,  -- Leather Jacket Brown
    leatherCollaredBrown=7192547628,
    leatherCollaredWhite=7192546798,
    hoodedGray=8516620262,
    parkaBrown=8648397446,
    trenchWhite=8648380153,
    sweaterBlack=9240757332,
    pantsBlack=9120251003,
    pantsBrown=8721985925,
    sweaterBeige=6984769289,
    longSkirtWhite=9240776381,
    smockDressWhite=85339840603460,
    hemDressBlue=78121746609585,
    blackDress=95591391483771,
    greenDress=113913554875680,
}
-- As silhuetas diferem por classe, mas continuam Roblox BLOCKY R15.
-- Uma camada base de tecido, outra camada externa volumétrica,
-- e calça 3D deformável em vez de estampa sobre os polígonos do avatar.
-- Roupas são determinadas pela CLASSE, independentemente da raça.
-- Onde existirem camadas longas, use a malha 3D DressSkirt da Roblox,
-- nunca um blazer moderno no samurai nem uma jaqueta no mago.
Catalog.Class3DOutfit={
    warrior={base="sweaterBlack",pants="pantsBlack",outer="leatherBlack",type="Jacket"},
    assassin={base="sweaterBlack",pants="pantsBlack",outer="leatherBlack",type="Jacket"},
    mage={base="sweaterBlack",pants="pantsBlack",outer="hemDressBlue",type="DressSkirt"},
    fighter={base="sweaterBeige",pants="pantsBrown",outer="leatherBrown",type="Jacket"},
    samurai={base="sweaterBeige",pants="pantsBlack",outer="longSkirtWhite",type="DressSkirt"},
}
Catalog.ClassHeadwear={
    warrior="knighthelm",
    assassin="hood",
    mage="hood",
    fighter="none",
    samurai="none",
}
-- Face é sempre escolha pessoal da raça, não da profissão.
Catalog.RaceFaceChoices={
    human={"serene","happy","determined","warrior"},
    witch={"ghost","stare","shadow","mysterious"},
    undead={"ghost","stare","mysterious","determined"},
    elf={"serene","happy","shadow","warrior"},
}
function Catalog.faceAllowed(race,id)
    for _,allowed in ipairs(Catalog.RaceFaceChoices[race]
        or Catalog.RaceFaceChoices.human) do
        if allowed==id then return true end
    end
    return false
end
function Catalog.armorAllowed(class,id)
    if id=="class" then return true end
    local option=Catalog.findOption("outer3d",id)
    if not option or not option.classes then return false end
    for _,role in ipairs(option.classes) do
        if role==class then return true end
    end
    return false
end
function Catalog.layeredAccessories(class,outer3d)
    local outfit=Catalog.Class3DOutfit[class] or Catalog.Class3DOutfit.warrior
    local t=Catalog.Official3DLayered
    local variant="class"
    if outer3d and Catalog.armorAllowed(class,outer3d) then
        variant=outer3d
    end
    local option=Catalog.findOption("outer3d",variant)
    local outer=(option and option.assetId and option.assetId>0)
        and option.assetId or t[outfit.outer]
    local typeName=(option and option.assetId and
        (option.assetId==t.smockDressWhite or
         option.assetId==t.hemDressBlue or
         option.assetId==t.longSkirtWhite))
        and "DressSkirt" or outfit.type
    return {
        {AssetId=t[outfit.pants],AccessoryType=Enum.AccessoryType.Pants,
            IsLayered=true,Order=1},
        {AssetId=t[outfit.base],AccessoryType=Enum.AccessoryType.Sweater,
            IsLayered=true,Order=2},
        {AssetId=outer,AccessoryType=Enum.AccessoryType[typeName],
            IsLayered=true,Order=3},
    }
end
function Catalog.tint3D(class,outer3d)
    -- Recolor only the *official* MeshPart fabric, never fabricate geometry.
    if class=="mage" then
        return outer3d=="ritual-blue" and Color3.fromRGB(68,76,124)
            or Color3.fromRGB(111,59,145)
    elseif class=="samurai" then
        return outer3d=="ronin-blue" and Color3.fromRGB(56,69,100)
            or Color3.fromRGB(123,61,63)
    end
    return nil
end
-- Cinco acessórios VERDADEIROS nas costas, com composição por classe.
-- Aplique só os IDs oficiais realmente carregados pelo motor.
Catalog.ClassBackSet={
    warrior={"dog","silver","red","yellow","aura"},
    assassin={"silver","green","red","yellow","aura"},
    mage={"aura","green","yellow","silver","red"},
    fighter={"dog","red","green","yellow","silver"},
    samurai={"silver","red","yellow","green","dog"},
}
function Catalog.backIds(class)
    local names=Catalog.ClassBackSet[class] or Catalog.ClassBackSet.warrior
    local out={}
    local seen={}
    for _,name in ipairs(names) do
        local id=Catalog.FreeRobloxBack[name]
        if id and not seen[id] then
            table.insert(out,tostring(id))
            seen[id]=true
        end
    end
    assert(#out==5,"Alnair: os trajes precisam de 5 acessórios reais de costas")
    return out
end

Catalog.DefaultAppearance = {
    face = "serene",
    hair = "short",
    hat = "class",
    outer3d = "class",
    upper = "tunic",
    lower = "pants",
    set = "none",
}
Catalog.RaceAppearance = {
    human={face="serene",hair="short"},
    witch={face="ghost",hair="bun"},
    undead={face="stare",hair="bald"},
    elf={face="happy",hair="long"},
}
Catalog.ClassOutfits = {
    warrior={upper="armor",lower="pants",hat="class",outer3d="class"},
    assassin={upper="leather",lower="pants",hat="class",outer3d="class"},
    mage={upper="robe",lower="hakama",hat="class",outer3d="class"},
    fighter={upper="forest",lower="pants",hat="class",outer3d="class"},
    samurai={upper="linen",lower="hakama",hat="class",outer3d="class"},
}
function Catalog.defaultsForRace(race)
    local defaults=table.clone(Catalog.DefaultAppearance)
    local racial=Catalog.RaceAppearance[race] or {}
    for k,v in pairs(racial) do defaults[k]=v end
    return defaults
end
function Catalog.findOption(group, id)
    local category = Catalog.Presets[group]
    if not category then return nil end
    for _, option in ipairs(category.options) do
        if option.id == id then return option end
    end
    return nil
end

function Catalog.clean(payload)
    if typeof(payload) ~= "table" then payload = {} end
    local race = payload.race
    if typeof(race) ~= "string" or not Catalog.Races[race] then race = "human" end
    local class = payload.class
    if typeof(class) ~= "string" or not Catalog.Classes[class] then class = "warrior" end

    local appearance = {}
    local defaults=Catalog.defaultsForRace(race)
    local supplied = typeof(payload.appearance) == "table" and payload.appearance or {}
    for _, group in ipairs(Catalog.PresetOrder) do
        local value = supplied[group]
        if typeof(value) ~= "string" or not Catalog.findOption(group, value) then
            value = defaults[group]
        end
        if group=="face" and not Catalog.faceAllowed(race,value) then
            value=defaults.face
        elseif group=="outer3d" and not Catalog.armorAllowed(class,value) then
            value="class"
        end
        appearance[group] = value
    end
    return { race = race, class = class, appearance = appearance }
end

return Catalog
