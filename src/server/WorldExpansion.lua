--!strict
-- ALNAIR REBORN / areas jogaveis com linguagem visual unica.
-- Mantem nomes de objetos de interacao, portais e posicoes do GameRules
-- para nao quebrar quests, arenas, inventario ou progressao.
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Shared=ReplicatedStorage:WaitForChild("AlnairShared")
local Rules=require(Shared:WaitForChild("GameRules"))
local ArtAssets=require(script.Parent:WaitForChild("ArtAssets"))
local WorldLighting=require(script.Parent:WaitForChild("WorldLighting"))
local WorldExpansion={}
local rng=Random.new(63019)
local root=nil
local arenas={}

local function solid(parent,name,size,cf,color,material,shape,collision)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=true
    p.Material=material or Enum.Material.Rock
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    if collision==false then p.CanCollide=false;p.CanTouch=false;p.CanQuery=false end
    p.Parent=parent
    return p
end
local function orb(parent,name,pos,radius,color,material,collision)
    return solid(parent,name,Vector3.new(radius,radius,radius),CFrame.new(pos),
        color,material or Enum.Material.SmoothPlastic,Enum.PartType.Ball,collision)
end
local function prop(parent,category,name,x,z,height,rot)
    return ArtAssets.place(category,name,parent,Vector3.new(x,0,z),height,rot or 0)
end
local function tag(obj,title,detail,compact)
    -- Fixed-size, restrained labels: three adjacent portals must not
    -- overlap or fill the screen with giant TextScaled headings.
    local billboard=Instance.new("BillboardGui")
    billboard.Name="AlnairSign"
    billboard.Size=compact and UDim2.fromOffset(146,50)
        or UDim2.fromOffset(190,58)
    billboard.StudsOffset=Vector3.new(0,compact and 4.1 or 4.7,0)
    billboard.MaxDistance=compact and 65 or 80
    billboard.AlwaysOnTop=false
    billboard.Adornee=obj;billboard.Parent=obj
    local heading=Instance.new("TextLabel")
    heading.Name="Title";heading.BackgroundTransparency=1
    heading.Size=UDim2.new(1,0,0,30)
    heading.Text=title;heading.Font=Enum.Font.Merriweather
    heading.TextColor3=Color3.fromRGB(248,225,173)
    heading.TextStrokeTransparency=.40
    heading.TextSize=compact and 12 or 15
    heading.TextWrapped=true
    heading.Parent=billboard
    local sub=Instance.new("TextLabel")
    sub.BackgroundTransparency=1
    sub.Position=UDim2.new(0,0,0,30)
    sub.Size=UDim2.new(1,0,0,18)
    sub.Text=detail or ""
    sub.Font=Enum.Font.BuilderSansMedium
    sub.TextSize=compact and 9 or 11
    sub.TextWrapped=true
    sub.TextColor3=Color3.fromRGB(237,242,226)
    sub.TextStrokeTransparency=.45
    sub.Parent=billboard
end
local function prompt(obj,action,target,title,detail)
    obj:SetAttribute("Action",action)
    obj:SetAttribute("ActionTarget",target)
    local p=Instance.new("ProximityPrompt")
    p.Name="AlnairInteraction";p.ActionText=title;p.ObjectText=detail
    p.HoldDuration=.35;p.MaxActivationDistance=13;p.RequiresLineOfSight=false
    p.KeyboardKeyCode=Enum.KeyCode.E;p.Parent=obj
    return p
end
local function lamp(parent,x,y,z,color)
    local base=solid(parent,"Poste entalhado",Vector3.new(.48,y,.48),
        CFrame.new(x,y/2,z),Color3.fromRGB(101,73,52),Enum.Material.Wood)
    local flame=orb(parent,"Chama da vila",Vector3.new(x,y+.35,z),.83,
        color or Color3.fromRGB(252,173,100),Enum.Material.Neon,false)
    flame.CastShadow=false
    local light=Instance.new("PointLight")
    light.Color=flame.Color;light.Range=18;light.Brightness=.85;light.Shadows=false;light.Parent=flame
    WorldLighting.embers(flame,true)
end
local function mushroom(parent,x,y,z,scale,red)
    local stem=solid(parent,"Caule de cogumelo",Vector3.new(.65*scale,2.6*scale,.65*scale),
        CFrame.new(x,y+1.3*scale,z),Color3.fromRGB(237,226,198),
        Enum.Material.SmoothPlastic,Enum.PartType.Cylinder,false)
    local cap=orb(parent,"Coroa fungica",Vector3.new(x,y+2.8*scale,z),2.8*scale,
        red and Color3.fromRGB(208,85,80) or Color3.fromRGB(146,122,205),
        Enum.Material.SmoothPlastic,false)
    cap.Size=Vector3.new(3.2*scale,1.35*scale,3.2*scale)
    for i=1,3 do
        local a=i*2*math.pi/3
        local dot=orb(parent,"Sarda de fungo",Vector3.new(x+math.cos(a)*.65*scale,
            y+3.45*scale,z+math.sin(a)*.65*scale),.35*scale,
            Color3.fromRGB(253,240,208),Enum.Material.SmoothPlastic,false)
        dot.CastShadow=false
    end
end
local function portal(parent,where,index,enabled)
    local pos=where
    local side=enabled and Color3.fromRGB(82,166,170) or Color3.fromRGB(110,104,119)
    for _,offset in ipairs({-6.5,6.5}) do
        solid(parent,"Arco de pedra",Vector3.new(2.8,14,3.5),
            CFrame.new(pos+Vector3.new(offset,7,0)),
            Color3.fromRGB(133,144,133),Enum.Material.Slate)
    end
    solid(parent,"Coroa do portal",Vector3.new(17,2.8,4.5),
        CFrame.new(pos+Vector3.new(0,15,0)),
        Color3.fromRGB(119,133,121),Enum.Material.Slate)
    local heart=solid(parent,"Véu do portal "..index,Vector3.new(10,11,.2),
        CFrame.new(pos+Vector3.new(0,7,0)),
        side,Enum.Material.Neon,nil,false)
    heart.Transparency=enabled and .48 or .75;heart.CastShadow=false
    local trigger=orb(parent,"Selo de viagem",pos+Vector3.new(0,1.7,2.5),1.35,
        enabled and Color3.fromRGB(144,236,218) or Color3.fromRGB(109,101,112),Enum.Material.Neon,false)
    prompt(trigger,"portal","map"..index,"ATRAVESSAR","MAPA "..index)
    tag(heart,index==1 and "VALE DAS CINZAS" or "PORTAL SELADO",enabled and "A GRANDE AVENTURA" or "EM CONSTRUCAO",true)
end
local function makeLobby()
    local lobby=Instance.new("Folder");lobby.Name="LobbySocial";lobby.Parent=root
    local x=760
    solid(lobby,"Pedra do Santuario",Vector3.new(190,5,195),
        CFrame.new(x,-2,0),Color3.fromRGB(133,123,101),Enum.Material.Cobblestone)
    solid(lobby,"Tapete de grama",Vector3.new(165,.17,165),
        CFrame.new(x,.64,2),Color3.fromRGB(91,145,94),Enum.Material.Grass)
    solid(lobby,"Coracao do Nexo",Vector3.new(53,.38,53),
        CFrame.new(x,.86,19),Color3.fromRGB(157,132,94),Enum.Material.Cobblestone)
    for i=1,16 do
        local theta=i*math.pi/8
        local radius=76
        local px=x+math.cos(theta)*radius
        local pz=math.sin(theta)*radius
        solid(lobby,"Coluna das Estrelas",Vector3.new(2.4,12,2.4),
            CFrame.new(px,6,pz),Color3.fromRGB(139,139,125),Enum.Material.Marble)
        if i%2==0 then lamp(lobby,px,12,pz,Color3.fromRGB(165,213,171))end
    end
    for _,cfg in ipairs({
        {"VILLAGE","Inn",694,16,23},
        {"VILLAGE","MarketStand_1",716,53,9},
        {"VILLAGE","House_1",827,57,21},
        {"VILLAGE","Bell_Tower",865,-14,29},
        {"VILLAGE","Well",785,23,8},
        {"VILLAGE","Bonfire_Lit",760,27,9},
        {"VILLAGE","Bench_1",745,47,4},
        {"NATURE","CommonTree_1",695,-63,26},
        {"NATURE","CommonTree_4",824,-73,24},
        {"FORTRESS","WatchTowerWRoof",860,65,33},
    })do
        prop(lobby,cfg[1],cfg[2],cfg[3],cfg[4],cfg[5])
    end
    for i=1,17 do
        local a=i*2.4
        local radius=53+(i%3)*9
        mushroom(lobby,x+math.cos(a)*radius,.8,math.sin(a)*radius,
            rng:NextNumber(.62,1.25),i%2==0)
    end
    -- Peripheral terrain relief and clustered woodland; keep travel lanes clear.
    local terrain=Workspace.Terrain
    for i=1,22 do
        local angle=i*math.pi*2/22
        local px=x+math.cos(angle)*94
        local pz=math.sin(angle)*94
        local h=rng:NextNumber(10,23)
        terrain:FillBall(Vector3.new(px,-5,pz),h,Enum.Material.Rock)
        terrain:FillBall(Vector3.new(px,-2,pz),h*.83,Enum.Material.Grass)
    end
    for i=1,28 do
        local angle=i*2.39996
        local radius=rng:NextNumber(65,78)
        local px=x+math.cos(angle)*radius
        local pz=math.sin(angle)*radius
        if pz>-43 or math.abs(px-x)>48 then
            prop(lobby,"NATURE",i%2==0 and "CommonTree_1" or "CommonTree_4",px,pz,rng:NextNumber(15,26),angle)
            local rock=orb(lobby,"Weathered boulder",Vector3.new(px+3,1,pz+2),rng:NextNumber(3,6),Color3.fromRGB(105,110,101),Enum.Material.Slate,true)
            rock.Size=rock.Size*Vector3.new(1.4,.65,1)
        end
    end
    portal(lobby,Vector3.new(731,1,-56),1,true)
    portal(lobby,Vector3.new(761,1,-56),2,false)
    portal(lobby,Vector3.new(791,1,-56),3,false)
    local arenaDoor=solid(lobby,"Portal da Arena",Vector3.new(13,13,.55),
        CFrame.new(813,8,22),Color3.fromRGB(204,93,105),Enum.Material.Neon,nil,false)
    arenaDoor.Transparency=.28
    prompt(arenaDoor,"portal","sandbox","ENTRAR","ARENA DAS HORDAS")
    tag(arenaDoor,"ARENA DO CREPUSCULO","ENFRENTE ONDAS E ESCOLHA PODERES")
    local board=solid(lobby,"Quadro das Lendas",Vector3.new(18,13,2),
        CFrame.new(708,8,32),Color3.fromRGB(83,59,41),Enum.Material.Wood)
    board:SetAttribute("Leaderboard",true)
    local charSpawn=Instance.new("SpawnLocation")
    charSpawn.Name="AlnairLobbySpawn";charSpawn.Size=Vector3.new(6,.5,6)
    charSpawn.CFrame=CFrame.new(Rules.LOBBY_SPAWN)
    charSpawn.Transparency=1;charSpawn.CanCollide=false;charSpawn.Anchored=true
    charSpawn.Neutral=true;charSpawn.Duration=0;charSpawn.Parent=lobby
    local historian=solid(lobby,"Cronista Astral",Vector3.new(2.8,5.5,2.5),
        CFrame.new(778,3.7,37),Color3.fromRGB(109,87,149),Enum.Material.SmoothPlastic)
    tag(historian,"O CRONISTA","SETE ESTRELAS CAIRAM")
    prompt(historian,"dialogue","chronicle","CONVERSAR","HISTORIA DE ALNAIR")
    local shop=solid(lobby,"Mercador das Brasas",Vector3.new(2.9,5.5,2.2),
        CFrame.new(733,3.7,41),Color3.fromRGB(116,90,63),Enum.Material.Wood)
    tag(shop,"MERCADOR DAS BRASAS","EQUIPAMENTOS E FRASCOS")
    prompt(shop,"shop","merchant","NEGOCIAR","LOJA DE OURO")
end

local function makeArena(index)
    local index=math.clamp(math.floor(index or 0),0,6)
    local key=tostring(index)
    if arenas[key] then return arenas[key] end
    local x=index*225
    local z=800
    local area=Instance.new("Folder")
    area.Name="Arena_"..key;area:SetAttribute("ArenaIndex",index);area.Parent=root
    solid(area,"Solo de arena",Vector3.new(175,6,175),
        CFrame.new(x,-3,z),Color3.fromRGB(146,107,88),Enum.Material.Sand)
    for i=1,28 do
        local a=(i/28)*math.pi*2
        local px=x+math.cos(a)*88
        local pz=z+math.sin(a)*88
        local h=rng:NextNumber(23,39)
        solid(area,"Rochedo circular",Vector3.new(17,h,15),
            CFrame.new(px,h/2-1,pz)*CFrame.Angles(0,a,0),
            Color3.fromRGB(110,112,111),Enum.Material.Rock)
        if i%4==0 then
            local glow=orb(area,"Cristal da Arena",Vector3.new(px,h+1,pz),3,
                Color3.fromRGB(255,154,92),Enum.Material.Neon,false)
            glow.CastShadow=false
        end
    end
    for i=1,12 do
        local a=i*math.pi/6
        mushroom(area,x+math.cos(a)*60,0,z+math.sin(a)*60,.80,i%2==1)
    end
    local exit=orb(area,"Obelisco de Saida",Vector3.new(x,4.8,z+62),3.5,
        Color3.fromRGB(129,218,211),Enum.Material.Neon,false)
    prompt(exit,"exitArena","none","DESISTIR","SEM RECEBER RECOMPENSAS")
    arenas[key]={folder=area,spawn=Vector3.new(x,6,z-55),center=Vector3.new(x,0,z)}
    return arenas[key]
end
local function mountains()
    local zone=Instance.new("Folder");zone.Name="Montanhas do Limiar";zone.Parent=root
    for side=1,4 do
        for i=-11,11 do
            local t=i*29
            local h=rng:NextNumber(34,81)
            local x,z=0,0
            if side==1 then x=-327;z=t elseif side==2 then x=327;z=t
            elseif side==3 then x=t;z=-327 else x=t;z=327 end
            local terrain=Workspace.Terrain
            terrain:FillBall(Vector3.new(x,h*.18-8,z),h*.55,Enum.Material.Rock)
            terrain:FillBall(Vector3.new(x,h*.36-5,z),h*.39,Enum.Material.Rock)
            terrain:FillBall(Vector3.new(x,h*.42-6,z),h*.31,Enum.Material.Grass)
            if i%3==0 then
                terrain:FillBall(Vector3.new(x+8,h*.52,z-5),h*.19,Enum.Material.Rock)
            end
        end
    end
    for index,peak in ipairs({
        {-226,160,69},{190,-221,81},{-230,-200,75},{240,156,77},{-82,246,47},
    })do
        local x,z,h=peak[1],peak[2],peak[3]
        local rock=orb(zone,"Montanha de pedra "..index,Vector3.new(x,h*.42,z),h*1.22,
            Color3.fromRGB(105,116,113),Enum.Material.Rock)
        rock.Size=Vector3.new(h*1.16,h,h*1.05)
        solid(zone,"Mirante da Montanha",Vector3.new(39,3,39),
            CFrame.new(x,h*.9,z),Color3.fromRGB(113,153,105),Enum.Material.Grass)
        if index<=3 then
            for n=1,10 do
                solid(zone,"Degrau da Encosta",Vector3.new(12,2,22),
                    CFrame.new(x+34-n*2,n*h*.087,z-88+n*7),
                    Color3.fromRGB(142,134,111),Enum.Material.Slate)
            end
        end
    end
end
local function dungeon()
    local zone=Instance.new("Folder");zone.Name="Cripta Afogada";zone.Parent=root
    local c=Rules.DUNGEON_SPAWN
    solid(zone,"Piso antigo",Vector3.new(104,5,104),
        CFrame.new(c.X,-52,c.Z),Color3.fromRGB(70,83,85),Enum.Material.Cobblestone)
    solid(zone,"Teto esculpido",Vector3.new(109,5,110),
        CFrame.new(c.X,-22,c.Z),Color3.fromRGB(57,70,72),Enum.Material.Rock)
    for side=1,4 do
        local x=side<=2 and c.X+(side==1 and -52 or 52) or c.X
        local z=side>2 and c.Z+(side==3 and -52 or 52) or c.Z
        solid(zone,"Parede da cripta",Vector3.new(side<=2 and 5 or 108,29,side>2 and 5 or 108),
            CFrame.new(x,-37,z),Color3.fromRGB(76,93,95),Enum.Material.Slate)
    end
    for i=1,12 do
        local a=i*math.pi/6
        local px=c.X+math.cos(a)*37
        local pz=c.Z+math.sin(a)*37
        solid(zone,"Coluna talhada",Vector3.new(3.7,22,3.7),
            CFrame.new(px,-38,pz),Color3.fromRGB(117,127,116),Enum.Material.Marble)
        if i%2==0 then
            local shroom=orb(zone,"Fungo azulado",Vector3.new(px,-23,pz),2.8,
                Color3.fromRGB(94,179,202),Enum.Material.Neon,false)
            shroom.CastShadow=false
        end
    end
    local gateway=solid(root,"Entrada da Cripta",Vector3.new(11,13,5),
        CFrame.new(-118,6,-98),Color3.fromRGB(89,113,117),Enum.Material.Rock)
    tag(gateway,"CRIPTA AFOGADA","O VIGIA SEM SOL")
    prompt(gateway,"dungeon","Crypt","DESCER","CRIPTA AFOGADA")
    local exit=orb(zone,"Saida da Cripta",c+Vector3.new(0,4,43),3,
        Color3.fromRGB(115,220,203),Enum.Material.Neon,false)
    prompt(exit,"dungeon","ExitCrypt","RETORNAR","VALE DAS CINZAS")
end
local function sky()
    local zone=Instance.new("Folder");zone.Name="Ilhas do Eter";zone.Parent=root
    for index,item in ipairs({
        {188,120,90,92},{270,150,169,73},{109,142,189,69},{-4,179,197,49},
    }) do
        local x,y,z,size=item[1],item[2],item[3],item[4]
        -- Layered angular cliffs, broad walkable crown and tapered underside.
        for n=1,5 do
            local width=size*(1-(n-1)*.16)
            local rock=solid(zone,"Island cliff shelf",Vector3.new(width,7,width*.83),CFrame.new(x+math.sin(n)*3,y+1-n*6,z+math.cos(n)*3)*CFrame.Angles(0,n*.22,0),Color3.fromRGB(105+n*4,112+n*3,115+n*3),Enum.Material.Slate)
        end
        solid(zone,"Jardim do vento",Vector3.new(size*.96,4,size*.87),CFrame.new(x,y+5,z),Color3.fromRGB(112,156,104),Enum.Material.Grass)
        local surface=y+7
        for n=1,3 do
            local a=n*2.094+index*.5
            ArtAssets.place("VILLAGE",n==1 and "House_1" or n==2 and "House_2" or "Gazebo",zone,Vector3.new(x+math.cos(a)*size*.22,surface,z+math.sin(a)*size*.22),size*.28,a)
        end
        for n=1,13 do
            local a=n*2.39996
            ArtAssets.place("NATURE",({"CommonTree_4","PineTree_3","BirchTree_1","CommonTree_1"})[n%4+1],zone,Vector3.new(x+math.cos(a)*size*.36,surface,z+math.sin(a)*size*.34),size*.13,a)
        end
        for i=1,6 do
            local a=i*math.pi/3
            orb(zone,"Cristal do eter",Vector3.new(x+math.cos(a)*size*.34,y+12,z+math.sin(a)*size*.3),
                rng:NextNumber(3,5),i%2==0 and Color3.fromRGB(143,227,214) or Color3.fromRGB(189,164,238),Enum.Material.Neon,false)
        end
    end
    local entrance=orb(root,"Escadaria do Ceu",Vector3.new(147,4,94),3,
        Color3.fromRGB(129,207,215),Enum.Material.Neon,false)
    tag(entrance,"ILHAS DO ETER","DESBLOQUEIA NO NIVEL 5")
    prompt(entrance,"sky","EnterSky","ASCENDER","ILHAS DO ETER")
    local beacon=orb(zone,"Farol Astral",Rules.SKY_SPAWN+Vector3.new(0,11,0),5.5,
        Color3.fromRGB(134,233,207),Enum.Material.Neon,false)
    tag(beacon,"FAROL ASTRAL","RESTAURE A QUINTA CHAMA")
    prompt(beacon,"quest","SkyBeacon","ACENDER","FAROL ASTRAL")
    local back=orb(zone,"Retorno das Nuvens",Rules.SKY_SPAWN+Vector3.new(-31,6,10),3,
        Color3.fromRGB(166,204,242),Enum.Material.Neon,false)
    prompt(back,"sky","ExitSky","DESCER","VALE DAS CINZAS")
    local dungeonGate=orb(zone,"Abismo Celestial",Vector3.new(264,159,153),3,
        Color3.fromRGB(195,171,240),Enum.Material.Neon,false)
    tag(dungeonGate,"SANTUARIO NAS NUVENS","MASMORRA CELESTIAL")
    prompt(dungeonGate,"dungeon","SkyDungeon","ENTRAR","SANTUARIO ETEREO")
end
local function secrets()
    local brazier=orb(root,"Braseiro Primordial",Vector3.new(15,4,13),1.8,
        Color3.fromRGB(242,172,89),Enum.Material.Neon,false)
    prompt(brazier,"quest","Brazier","ACENDER","FOGO PRIMORDIAL")
    local chest=orb(root,"Bau das Cinzas",Vector3.new(62,3,-30),3,
        Color3.fromRGB(173,129,77),Enum.Material.Wood,false)
    prompt(chest,"chest","AshChest","ABRIR","BAU ANTIGO")
    chest:SetAttribute("GoldMin",35);chest:SetAttribute("GoldMax",70)
end
function WorldExpansion.create()
    if root and root.Parent then return root end
    root=Workspace:FindFirstChild("AlnairGameplayWorld")
    if root then return root end
    root=Instance.new("Folder");root.Name="AlnairGameplayWorld";root.Parent=Workspace
    makeLobby()
    root:SetAttribute("AlnairGenerationPhase","lobby-ready")
    -- Keep the lobby interactive immediately. Remaining zones are built
    -- in bounded batches after startup instead of blocking the first frame.
    task.defer(function()
        if not root or not root.Parent then return end
        makeArena(0)
        task.wait(.06)
        mountains()
        task.wait(.06)
        dungeon()
        task.wait(.06)
        sky()
        task.wait(.06)
        secrets()
        if root and root.Parent then
            root:SetAttribute("AlnairGenerationPhase","complete")
        end
    end)
    return root
end
function WorldExpansion.arena(index)
    return makeArena(index)
end
return WorldExpansion
