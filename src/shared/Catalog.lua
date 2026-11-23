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

-- IDs livres de caracteres especiais para preservar no Git e facilitar DataStore futuro.
Catalog.PresetOrder = { "face", "ears", "hair", "beard", "upper", "lower", "set", "feet" }
Catalog.Presets = {
    face = {
        name = "Rosto",
        options = {
            { id = "serene", name = "Sereno", expression = "smile" },
            { id = "determined", name = "Determinado", expression = "stern" },
            { id = "mysterious", name = "Misterioso", expression = "mystery" },
            { id = "happy", name = "Alegre", expression = "happy" },
            { id = "warrior", name = "Cicatriz", expression = "scar" },
            { id = "shadow", name = "Sombrio", expression = "shadow" },
        },
    },
    ears = {
        name = "Orelhas",
        options = {
            { id = "normal", name = "Clássicas" },
            { id = "small", name = "Discretas" },
            { id = "pointed", name = "Pontudas" },
            { id = "long", name = "Alongadas" },
        },
    },
    hair = {
        name = "Cabelo",
        options = {
            { id = "short", name = "Curto" },
            { id = "fringe", name = "Franja" },
            { id = "long", name = "Longo" },
            { id = "mohawk", name = "Curto estilizado" },
            { id = "bun", name = "Coque" },
            { id = "bald", name = "Careca" },
        },
    },
    beard = {
        name = "Barba",
        options = {
            { id = "none", name = "Sem barba" },
            { id = "full", name = "Barba completa" },
            { id = "trim", name = "Barba curta" },
        },
    },
    upper = {
        name = "Parte superior",
        options = {
            { id = "tunic", name = "Túnica de viagem", color = Color3.fromRGB(69, 86, 93) },
            { id = "leather", name = "Couro aventureiro", color = Color3.fromRGB(111, 78, 64) },
            { id = "armor", name = "Peitoral de ferro", color = Color3.fromRGB(116, 129, 145) },
            { id = "robe", name = "Manto arcano", color = Color3.fromRGB(82, 72, 125) },
            { id = "linen", name = "Linho claro", color = Color3.fromRGB(182, 173, 151) },
            { id = "bare", name = "Túnica simples", color = nil },
        },
    },
    lower = {
        name = "Parte inferior",
        options = {
            { id = "pants", name = "Calça de viagem", color = Color3.fromRGB(61, 62, 66) },
            { id = "leather", name = "Calça de couro", color = Color3.fromRGB(83, 61, 53) },
            { id = "hakama", name = "Hakama escuro", color = Color3.fromRGB(46, 52, 76) },
            { id = "linen", name = "Tecido claro", color = Color3.fromRGB(152, 139, 114) },
            { id = "shorts", name = "Bermuda simples", color = Color3.fromRGB(115, 117, 103) },
        },
    },
    set = {
        name = "Conjuntos",
        options = {
            { id = "none", name = "Personalizado", upper = nil, lower = nil },
            { id = "traveler", name = "Viajante", upper = "tunic", lower = "pants" },
            { id = "guardian", name = "Guardião", upper = "armor", lower = "leather" },
            { id = "arcanist", name = "Arcanista", upper = "robe", lower = "hakama" },
            { id = "ronin", name = "Ronin", upper = "leather", lower = "hakama" },
        },
    },
    feet = {
        name = "Calçados",
        options = {
            { id = "boots", name = "Botas de couro", color = Color3.fromRGB(73, 48, 38) },
            { id = "iron", name = "Botas de ferro", color = Color3.fromRGB(126, 130, 142) },
            { id = "shoes", name = "Sapatos simples", color = Color3.fromRGB(49, 43, 43) },
            { id = "sandals", name = "Sandálias", color = Color3.fromRGB(124, 85, 62) },
            { id = "barefoot", name = "Descalço", color = nil },
        },
    },
}

Catalog.DefaultAppearance = {
    face = "serene",
    ears = "normal",
    hair = "short",
    beard = "none",
    upper = "tunic",
    lower = "pants",
    set = "none",
    feet = "boots",
}

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
    local supplied = typeof(payload.appearance) == "table" and payload.appearance or {}
    for _, group in ipairs(Catalog.PresetOrder) do
        local value = supplied[group]
        if typeof(value) ~= "string" or not Catalog.findOption(group, value) then
            value = Catalog.DefaultAppearance[group]
        end
        appearance[group] = value
    end
    return { race = race, class = class, appearance = appearance }
end

return Catalog
