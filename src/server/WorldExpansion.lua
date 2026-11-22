--!strict
-- Cenografia do prototipo: lobby social, tres portais, arena, montanhas, criptas e ilhas.
-- Areas na mesma experiencia durante desenvolvimento; PlaceIds distintos virao depois.
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Rules=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("GameRules"))
local WorldExpansion={}
local ArtAssets=require(script.Parent:WaitForChild("ArtAssets"))
local rng=Random.new(14927)
local root=nil
local arenas={}

local function solid(parent,name,size,cf,color,material,shape,collide)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=true
    p.Material=material or Enum.Material.Slate
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    if collide==false then p.CanCollide=false;p.CanTouch=false end
    p.Parent=parent
    return p
end
local function globe(parent,name,pos,size,color,material)
    return solid(parent,name,Vector3.new(size,size,size),CFrame.new(pos),color,material or Enum.Material.Rock,Enum.PartType.Ball)
end
local function writeSign(part,title,subtitle)
    local billboard=Instance.new("BillboardGui")
    billboard.Name="AlnairSign";billboard.Adornee=part;billboard.AlwaysOnTop=true
    billboard.Size=UDim2.fromOffset(290,80)
    billboard.StudsOffset=Vector3.new(0,4.5,0);billboard.MaxDistance=110
    billboard.Parent=part
    local titleLabel=Instance.new("TextLabel")
    titleLabel.BackgroundTransparency=1;titleLabel.Size=UDim2.fromScale(1,.58)
    titleLabel.Text=title;titleLabel.TextColor3=Color3.fromRGB(242,221,174)
    titleLabel.TextStrokeTransparency=.15;titleLabel.TextScaled=true
    titleLabel.Font=Enum.Font.Antique;titleLabel.Parent=billboard
    local detail=Instance.new("TextLabel")
    detail.BackgroundTransparency=1;detail.Position=UDim2.fromScale(0,.55)
    detail.Size=UDim2.fromScale(1,.30);detail.Text=subtitle or ""
    detail.TextColor3=Color3.fromRGB(210,214,220);detail.TextStrokeTransparency=.1
    detail.TextScaled=true;detail.Font=Enum.Font.Gotham;detail.Parent=billboard
end
local function prompt(part,action,objectName,title,detail)
    part:SetAttribute("Action",action)
    part:SetAttribute("ActionTarget",objectName)
    local p=Instance.new("ProximityPrompt")
    p.Name="AlnairInteraction"
    p.ActionText=title
    p.ObjectText=detail
    p.HoldDuration=.35
    p.MaxActivationDistance=13
    p.RequiresLineOfSight=false
    p.Parent=part
    return p
end
local function portal(parent,pos,index,enabled)
    local cf=CFrame.new(pos)
    local stone=Color3.fromRGB(69,80,91)
    local p1=solid(parent,"Portal Pilar E",Vector3.new(3,17,4),cf*CFrame.new(-8,9,0),stone)
    local p2=solid(parent,"Portal Pilar D",Vector3.new(3,17,4),cf*CFrame.new(8,9,0),stone)
    local p3=solid(parent,"Arco de Pedra",Vector3.new(19,3,4),cf*CFrame.new(0,18,0),stone)
    if ArtAssets.place("FORTRESS","WallEntrance",parent,pos,22,0) then
        p1.Transparency=1;p2.Transparency=1;p3.Transparency=1
    end
    local glow=solid(parent,"Portal Mapa "..index,Vector3.new(13,13,.3),cf*CFrame.new(0,9,0),
        enabled and Color3.fromRGB(69,155,207) or Color3.fromRGB(79,62,85),Enum.Material.Neon,nil,false)
    glow.Transparency=enabled and .36 or .72
    local orb=globe(parent,"Portal Alnair",pos+Vector3.new(0,2,3),1.7,
        enabled and Color3.fromRGB(151,223,244) or Color3.fromRGB(131,108,126),Enum.Material.Neon)
    prompt(orb,"portal","map"..index,"ATRAVESSAR","MAPA "..index)
    writeSign(glow,"MAPA "..index,enabled and "VALE DAS CINZAS" or "BLOQUEADO")
end

local function makeLobby()
    local lobby=Instance.new("Folder");lobby.Name="LobbySocial";lobby.Parent=root
    local c=Vector3.new(760,0,0)
    solid(lobby,"Plaza do Nexo",Vector3.new(190,5,195),CFrame.new(c.X,-2,c.Z),
        Color3.fromRGB(72,76,92),Enum.Material.Cobblestone)
    solid(lobby,"Circulo central",Vector3.new(44,.4,44),CFrame.new(c.X,.7,c.Z+20),
        Color3.fromRGB(113,108,99),Enum.Material.Slate)
    for i=1,18 do
        local theta=(i/18)*math.pi*2
        local r=70
        local x=c.X+math.cos(theta)*r;local z=c.Z+math.sin(theta)*r
        local pillar=solid(lobby,"Coluna do Nexo",Vector3.new(3,15,3),
            CFrame.new(x,7.5,z),Color3.fromRGB(96,101,115),Enum.Material.Marble)
        ArtAssets.replaceSolid(pillar,"DUNGEON","Column",16,theta)
        local lamp=globe(lobby,"Luz do Nexo",Vector3.new(x,17,z),2.2,
            Color3.fromRGB(150,204,235),Enum.Material.Neon)
        lamp.CanCollide=false
        local light=Instance.new("PointLight")
        light.Range=26;light.Brightness=1.35;light.Color=lamp.Color;light.Parent=lamp
    end
    portal(lobby,Vector3.new(730,1,-55),1,true)
    portal(lobby,Vector3.new(760,1,-55),2,false)
    portal(lobby,Vector3.new(790,1,-55),3,false)
    local arenaGate=solid(lobby,"Portal da Arena",Vector3.new(15,13,.8),
        CFrame.new(812,8,25),Color3.fromRGB(159,80,106),Enum.Material.Neon,nil,false)
    prompt(arenaGate,"portal","sandbox","ENTRAR","ARENA DAS HORDAS")
    ArtAssets.place("FORTRESS","WallEntrance",lobby,Vector3.new(812,0,25),20,math.pi/2)
    writeSign(arenaGate,"ARENA DO CREPUSCULO","Roguelite • Recompensa na derrota")
    local sign=solid(lobby,"Quadro das Lendas",Vector3.new(19,14,2),
        CFrame.new(696,9,34),Color3.fromRGB(34,40,54),Enum.Material.Slate)
    writeSign(sign,"LENDAS DE ALNAIR","TOP 10 • NIVEL E VITORIAS")
    sign:SetAttribute("Leaderboard",true)
    local sp=Instance.new("SpawnLocation")
    sp.Name="AlnairLobbySpawn";sp.Anchored=true;sp.CanCollide=false
    sp.Transparency=1;sp.Size=Vector3.new(6,.5,6);sp.CFrame=CFrame.new(Rules.LOBBY_SPAWN)
    sp.Neutral=true;sp.Duration=0;sp.Parent=lobby
    local storyteller=solid(lobby,"Cronista Astral",Vector3.new(3,6,2),
        CFrame.new(772,4,31),Color3.fromRGB(114,99,143),Enum.Material.SmoothPlastic)
    writeSign(storyteller,"O CRONISTA","As sete estrelas tombaram.")
    prompt(storyteller,"dialogue","chronicle","OUVIR","CRONISTA ASTRAL")
    ArtAssets.place("ITEMS","Armor_Metal",lobby,Vector3.new(762,2,32),5,math.pi)
    for _,cfg in ipairs({
        {"VILLAGE","Inn",679,58,32},
        {"VILLAGE","House_1",848,52,24},
        {"VILLAGE","House_2",679,-20,22},
        {"VILLAGE","Stable",844,-48,21},
        {"VILLAGE","Blacksmith",677,-77,23},
        {"VILLAGE","MarketStand_1",795,49,14},
        {"VILLAGE","Well",760,71,10},
        {"FORTRESS","Tower",672,-84,29},
        {"FORTRESS","WatchTowerWRoof",854,-82,34},
    }) do
        ArtAssets.place(cfg[1],cfg[2],lobby,Vector3.new(cfg[3],.6,cfg[4]),
            cfg[5],rng:NextNumber(-.4,.4))
    end
    local merchant=solid(lobby,"Mercador das Brasas",Vector3.new(3.1,5.9,2.2),
        CFrame.new(740,4.0,36),Color3.fromRGB(93,74,53),Enum.Material.Wood)
    writeSign(merchant,"MERCADOR DAS BRASAS","Armas, frascos e armaduras")
    prompt(merchant,"shop","merchant","NEGOCIAR","LOJA DE OURO")
    local base=ReplicatedStorage:FindFirstChild("AlnairShared")
    local humanoidPrefab=base and base:FindFirstChild("AlnairRiggedBody")
    if humanoidPrefab and humanoidPrefab:IsA("Model") then
        for _,entry in ipairs({{772,4,31,"Cronista 3D"},{740,4,36,"Mercador 3D"}}) do
            local figure=humanoidPrefab:Clone()
            figure.Name=entry[4]
            for _,piece in ipairs(figure:GetDescendants()) do
                if piece:IsA("BasePart") then
                    piece.Anchored=true;piece.CanCollide=false;piece.CanTouch=false
                end
            end
            figure.Parent=lobby
            figure:PivotTo(CFrame.new(entry[1],entry[2],entry[3]))
        end
        storyteller.Transparency=1;merchant.Transparency=1
    end
end

local function makeArena(index)
    local x=index*225;local z=800
    local key=tostring(index)
    if arenas[key] then return arenas[key] end
    local arena=Instance.new("Folder");arena.Name="Arena_"..key;arena.Parent=root
    arena:SetAttribute("ArenaIndex",index)
    solid(arena,"Areia de Ossos",Vector3.new(175,6,175),CFrame.new(x,-3,z),
        Color3.fromRGB(90,78,74),Enum.Material.Sand)
    for i=1,32 do
        local a=2*math.pi*i/32
        local px=x+math.cos(a)*86;local pz=z+math.sin(a)*86
        local height=rng:NextNumber(22,36)
        local wall=solid(arena,"Muralha da Arena",Vector3.new(17,height,13),CFrame.new(px,height/2,pz)*CFrame.Angles(0,a,0),
            Color3.fromRGB(87,77,85),Enum.Material.Rock)
        ArtAssets.replaceSolid(wall,"FORTRESS",i%4==0 and "Tower" or "TallWall",height,a)
    end
    for i=0,7 do
        local a=i*math.pi/4
        local orb=globe(arena,"Brasa da Arena",Vector3.new(x+math.cos(a)*68,11,z+math.sin(a)*68),
            3,Color3.fromRGB(242,139,74),Enum.Material.Neon)
        orb.CanCollide=false
        local light=Instance.new("PointLight");light.Range=30;light.Brightness=1.2;light.Parent=orb
    end
    local exit=globe(arena,"Obelisco de Saida",Vector3.new(x,5,z+62),4,
        Color3.fromRGB(153,185,236),Enum.Material.Neon)
    prompt(exit,"exitArena","none","DESISTIR DA RUN","SEM RECEBER RECOMPENSA")
    arenas[key]={folder=arena,spawn=Vector3.new(x,6,z-55),center=Vector3.new(x,0,z)}
    return arenas[key]
end

local function mountains()
    local landscape=Instance.new("Folder");landscape.Name="Cordilheira das Cinzas";landscape.Parent=root
    for side=1,4 do
        for i=-13,13 do
            local t=i*23
            local h=rng:NextNumber(30,75)+(math.sin(i*.85+side)*13)
            local w=rng:NextNumber(23,42)
            local x,z=0,0
            if side==1 then x=-319;z=t elseif side==2 then x=319;z=t
            elseif side==3 then x=t;z=-319 else x=t;z=319 end
            local wall=solid(landscape,"Muralha Natural",Vector3.new(w,h,42),
                CFrame.new(x,h/2-3,z)*CFrame.Angles(0,side>2 and math.pi/2 or 0,0),
                Color3.fromRGB(82+rng:NextInteger(0,13),87,94),Enum.Material.Rock)
            ArtAssets.replaceSolid(wall,"NATURE",i%3==0 and "Rock_Moss_3" or "Rock_5",h*1.15,
                rng:NextNumber(-math.pi,math.pi))
        end
    end
    local peaks={{-224,160,67},{190,-220,78},{-230,-200,72},{240,156,81},{-82,246,43}}
    for idx,entry in ipairs(peaks) do
        local x,z,h=entry[1],entry[2],entry[3]
        local mountain=globe(landscape,"Pico Acessivel "..idx,Vector3.new(x,h*.36,z),h*1.15,
            Color3.fromRGB(92,99,104),Enum.Material.Rock)
        ArtAssets.replaceSolid(mountain,"NATURE","Rock_Moss_3",h*1.1)
        local top=solid(landscape,"Mirante das Alturas",Vector3.new(37,3,37),
            CFrame.new(x,h*.91,z),Color3.fromRGB(92,110,96),Enum.Material.Grass)
        if idx<=3 then
            -- Degraus largos: acesso sem montaria a maioria dos mirantes.
            for step=1,10 do
                local y=step*h*.087
                solid(landscape,"Trilha da Montanha",Vector3.new(12,2,22),
                    CFrame.new(x+34-step*2,y,z-88+step*7),
                    Color3.fromRGB(110,104,96),Enum.Material.Slate)
            end
        end
    end
    local pit=solid(landscape,"Ravina da Ultima Fronteira",Vector3.new(240,5,14),
        CFrame.new(0,-8,301),Color3.fromRGB(25,32,42),Enum.Material.Slate)
    pit.CanCollide=false
end

local function dungeon()
    local zone=Instance.new("Folder");zone.Name="Cripta Afogada";zone.Parent=root
    local c=Rules.DUNGEON_SPAWN
    solid(zone,"Piso da Cripta",Vector3.new(104,5,104),CFrame.new(c.X,-52,c.Z),
        Color3.fromRGB(54,62,71),Enum.Material.Cobblestone)
    solid(zone,"Teto Abobadado",Vector3.new(110,5,110),CFrame.new(c.X,-23,c.Z),
        Color3.fromRGB(42,46,58),Enum.Material.Rock)
    for a=1,4 do
        local x=(a<=2) and c.X+(a==1 and -53 or 53) or c.X
        local z=(a>=3) and c.Z+(a==3 and -53 or 53) or c.Z
        local wall=solid(zone,"Paredes da Cripta",Vector3.new(a<=2 and 5 or 108,30,a>=3 and 5 or 108),
            CFrame.new(x,-37,z),Color3.fromRGB(65,70,82),Enum.Material.Slate)
        local success=false
        for k=-2,2 do
            local px=a<=2 and x or x+k*21
            local pz=a>=3 and z or z+k*21
            if ArtAssets.place("DUNGEON","ModularStoneWall",zone,Vector3.new(px,-52,pz),31,
                a<=2 and math.pi/2 or 0) then success=true end
        end
        if success then wall.Transparency=1 end
    end
    for i=1,12 do
        local a=i*math.pi/6
        local pillar=solid(zone,"Pilar de pedra",Vector3.new(4,25,4),
            CFrame.new(c.X+math.cos(a)*39,-37,c.Z+math.sin(a)*39),
            Color3.fromRGB(94,93,99),Enum.Material.Marble)
        ArtAssets.replaceSolid(pillar,"DUNGEON","Column",27)
        if i%3==0 then
            ArtAssets.place("DUNGEON","Torch",zone,
                Vector3.new(c.X+math.cos(a)*34,-52,c.Z+math.sin(a)*34),7,a)
        end
    end
    local gate=solid(root,"Entrada da Cripta",Vector3.new(11,13,6),
        CFrame.new(-118,6,-98),Color3.fromRGB(59,74,85),Enum.Material.Rock)
    ArtAssets.replaceSolid(gate,"DUNGEON","Entrance",14)
    writeSign(gate,"CRIPTA AFOGADA","O VIGIA SEM SOL")
    prompt(gate,"dungeon","Crypt","DESCER","CRIPTA AFOGADA")
    for _,cfg in ipairs({{"Candelabrum",-31,-19,6},{"Chest_gold",27,18,4},{"Bones",-14,22,3}}) do
        ArtAssets.place("DUNGEON",cfg[1],zone,
            Vector3.new(c.X+cfg[2],-50,c.Z+cfg[3]),cfg[4])
    end
    local exit=globe(zone,"Saida da Cripta",c+Vector3.new(0,3,43),3,
        Color3.fromRGB(115,199,219),Enum.Material.Neon)
    prompt(exit,"dungeon","ExitCrypt","RETORNAR","VALE DAS CINZAS")
end

local function sky()
    local zone=Instance.new("Folder");zone.Name="Ilhas do Eter";zone.Parent=root
    local coords={{188,120,90,90},{270,150,169,72},{109,142,189,68},{-4,179,197,48}}
    for i,p in ipairs(coords) do
        local x,y,z,size=p[1],p[2],p[3],p[4]
        local rock=globe(zone,"Ilha Suspensa "..i,Vector3.new(x,y-18,z),size,
            Color3.fromRGB(87,96,105),Enum.Material.Rock)
        rock.Size=Vector3.new(size,size*.56,size)
        local cliff=ArtAssets.place("NATURE","Rock_Moss_3",zone,
            Vector3.new(x,y-size*.40,z),size*.66)
        if cliff then rock.Transparency=1 end
        solid(zone,"Jardim do Eter",Vector3.new(size*.88,4,size*.83),
            CFrame.new(x,y+5,z),Color3.fromRGB(95,140,116),Enum.Material.Grass)
        for a=1,6 do
            local theta=a*math.pi/3
            if a%2==1 then
                ArtAssets.place("NATURE","PineTree_1",zone,
                    Vector3.new(x+math.cos(theta)*size*.21,y+7,z+math.sin(theta)*size*.18),
                    rng:NextNumber(10,17),theta)
            else
                ArtAssets.place("NATURE","Bush_1",zone,
                    Vector3.new(x+math.cos(theta)*size*.25,y+7,z+math.sin(theta)*size*.24),3)
            end
            globe(zone,"Pedra Celestial",Vector3.new(x+math.cos(theta)*size*.35,y+13,z+math.sin(theta)*size*.34),
                rng:NextNumber(3,6),Color3.fromRGB(117,126,150),Enum.Material.Rock)
        end
    end
    local entry=globe(root,"Escadaria do Ceu",Vector3.new(147,4,94),3,
        Color3.fromRGB(170,207,234),Enum.Material.Neon)
    writeSign(entry,"ILHAS DO ETER","NIVEL 5 • MONTARIA VOADORA")
    prompt(entry,"sky","EnterSky","ASCENDER","ILHAS DO ETER")
    local beacon=globe(zone,"Farol Astral",Rules.SKY_SPAWN+Vector3.new(0,11,0),5,
        Color3.fromRGB(121,224,225),Enum.Material.Neon)
    writeSign(beacon,"FAROL ASTRAL","RESTAURE A QUINTA CHAMA")
    prompt(beacon,"quest","SkyBeacon","ACENDER","FAROL ASTRAL")
    local exit=globe(zone,"Retorno das Nuvens",Rules.SKY_SPAWN+Vector3.new(-31,6,10),3,
        Color3.fromRGB(162,185,240),Enum.Material.Neon)
    prompt(exit,"sky","ExitSky","DESCER","VALE DAS CINZAS")
    local skyGate=globe(zone,"Abismo Celestial",Vector3.new(264,159,153),3,
        Color3.fromRGB(209,174,254),Enum.Material.Neon)
    writeSign(skyGate,"SANTUARIO NAS NUVENS","MASMORRA CELESTIAL")
    prompt(skyGate,"dungeon","SkyDungeon","ENTRAR","SANTUARIO ETEREO")
end

local function pointsOfInterest()
    local camp=globe(root,"Braseiro Primordial",Vector3.new(15,4,13),1.8,
        Color3.fromRGB(233,167,74),Enum.Material.Neon)
    prompt(camp,"quest","Brazier","ACENDER","FOGO PRIMORDIAL")
    if ArtAssets.place("VILLAGE","Bonfire_Lit",root,Vector3.new(15,1,13),4) then
        camp.Transparency=1
    end
    local c=globe(root,"Bau das Cinzas",Vector3.new(62,3,-30),3,
        Color3.fromRGB(168,127,71),Enum.Material.Wood)
    prompt(c,"chest","AshChest","ABRIR","BAU ANTIGO")
    if ArtAssets.place("DUNGEON","Chest_gold",root,Vector3.new(62,1,-30),3.5) then
        c.Transparency=1
    end
    c:SetAttribute("GoldMin",35)
    c:SetAttribute("GoldMax",70)
end

function WorldExpansion.create()
    if root and root.Parent then return root end
    root=Workspace:FindFirstChild("AlnairGameplayWorld")
    if root then return root end
    root=Instance.new("Folder");root.Name="AlnairGameplayWorld";root.Parent=Workspace
    makeLobby()
    makeArena(0)
    mountains()
    dungeon()
    sky()
    pointsOfInterest()
    return root
end

function WorldExpansion.arena(index)
    return makeArena(math.clamp(math.floor(index or 0),0,6))
end

return WorldExpansion
