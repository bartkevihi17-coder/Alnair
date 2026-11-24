--!strict
-- ALNAIR REBORN / Bosque das Sete Estrelas.
-- Cenario novo: aldeia, rios, trilhas, fungos e ruinas estilizadas.
-- Todas as malhas importadas abaixo pertencem a biblioteca CC0 do projeto.
local Lighting=game:GetService("Lighting")
local Workspace=game:GetService("Workspace")
local ArtAssets=require(script.Parent:WaitForChild("ArtAssets"))
local WorldLighting=require(script.Parent:WaitForChild("WorldLighting"))
local MenuHouseStage=require(script.Parent:WaitForChild("MenuHouseStage"))
local World={}
local rng=Random.new(20261122)

local function solid(parent,name,size,cf,color,material,collide,shape)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Anchored=true
    p.Material=material or Enum.Material.Grass
    if shape then p.Shape=shape end
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.CastShadow=true
    p.CanCollide=collide~=false
    if collide==false then p.CanTouch=false;p.CanQuery=false end
    p.Parent=parent
    return p
end
local function orb(parent,name,pos,size,color,material,collide)
    return solid(parent,name,Vector3.new(size,size,size),CFrame.new(pos),color,material,collide,Enum.PartType.Ball)
end
local function placed(parent,category,asset,x,z,height,rotation)
    return ArtAssets.place(category,asset,parent,Vector3.new(x,0,z),height,rotation or rng:NextNumber(-3.1,3.1))
end
local function mushroom(parent,x,z,scale,red)
    local group=Instance.new("Model");group.Name="Cogumelo da floresta";group.Parent=parent
    local stem=solid(group,"Talo de marfim",Vector3.new(.60*scale,2.8*scale,.60*scale),
        CFrame.new(x,1.40*scale,z),Color3.fromRGB(229,220,187),Enum.Material.SmoothPlastic,false,Enum.PartType.Cylinder)
    local cap=orb(group,"Chapeu",Vector3.new(x,3.0*scale,z),3.0*scale,
        red and Color3.fromRGB(207,69,64) or Color3.fromRGB(128,103,176),Enum.Material.SmoothPlastic,false)
    cap.Size=Vector3.new(3.5*scale,1.45*scale,3.5*scale)
    for i=1,4 do
        local a=i*math.pi/2+.36
        local spot=orb(group,"Pinta clara",Vector3.new(x+math.cos(a)*.90*scale,3.65*scale,z+math.sin(a)*.90*scale),
            .35*scale,Color3.fromRGB(249,234,205),Enum.Material.SmoothPlastic,false)
        spot.CastShadow=false
    end
    return group
end
local function torch(parent,x,y,z,warm)
    local bulb=orb(parent,warm and "Vaga-lume de fogo" or "Luz espiritual",
        Vector3.new(x,y,z),.72,warm and Color3.fromRGB(255,184,106) or Color3.fromRGB(115,222,204),
        Enum.Material.Neon,false)
    bulb.CastShadow=false
    local light=Instance.new("PointLight")
    light.Color=bulb.Color;light.Brightness=warm and 1.0 or .65
    light.Range=warm and 18 or 14;light.Shadows=warm and math.abs(x-17)<.1 and math.abs(z-18)<.1
    light.Parent=bulb
    WorldLighting.embers(bulb,warm)
    return bulb
end
-- Stylized camp tents and red-cap mushrooms: key landmarks in the reference game.
local function tent(parent,x,z,color)
    -- Barracas importadas da biblioteca CC0, em vez de lona de WedgeParts.
    local stand=ArtAssets.place("VILLAGE","MarketStand_1",parent,
        Vector3.new(x,0,z),10,0)
    if stand then
        stand.Name="Barraca medieval CC0"
        return stand
    end
    return nil
end
local function groveMushrooms(world)
    local grove=Instance.new("Folder");grove.Name="Floresta de Cogumelos";grove.Parent=world
    -- Maiores do que o heroi, caps vermelhos com manchas claras.
    for _,item in ipairs({
        {-45,71,5.5,true},{55,91,5.2,true},{-59,-22,6.4,true},
        {91,-118,5.7,true},{-149,55,7.0,true},{-87,152,5.0,false},
        {101,84,4.6,false},{-35,-157,6.0,true}
    }) do
        mushroom(grove,item[1],item[2],item[3],item[4])
        for n=1,3 do
            local a=n*2.094
            mushroom(grove,item[1]+math.cos(a)*8,item[2]+math.sin(a)*7,
                rng:NextNumber(.6,1.15),n%2==0)
        end
    end
end
local function decoratedTree(parent,x,z,tall,style)
    local typeName=style=="birch" and "BirchTree_1" or style=="pine" and "PineTree_3" or "CommonTree_1"
    placed(parent,"NATURE",typeName,x,z,tall,0)
    if rng:NextNumber()>.62 then
        placed(parent,"NATURE","Bush_1",x+2,z+1,rng:NextNumber(1.3,3.8))
    end
end
local function forest(world)
    local decor=Instance.new("Folder");decor.Name="Bosque Encantado";decor.Parent=world
    local treePalette={"CommonTree_1","CommonTree_4","BirchTree_1","BirchTree_2","PineTree_3","PineTree_5"}
    for i=1,220 do
        if i%12==0 then task.wait() end
        local x=rng:NextNumber(-306,306)
        local z=rng:NextNumber(-305,305)
        local reserved=(math.abs(x)<64 and z>-148 and z<110)
            or (x>-190 and x<-97 and z>-108 and z<15)
            or (x>76 and x<165 and z>-135 and z<66)
        if not reserved then
            placed(decor,"NATURE",treePalette[rng:NextInteger(1,#treePalette)],x,z,rng:NextNumber(14,27))
            if i%3==0 then
                mushroom(decor,x+rng:NextNumber(3,7),z+rng:NextNumber(-4,4),rng:NextNumber(.5,1.05),i%2==0)
            end
        end
    end
    for i=1,270 do
        if i%12==0 then task.wait() end
        local x=rng:NextNumber(-293,293)
        local z=rng:NextNumber(-298,298)
        if x*x+z*z>40*40 then
            local name=({"Grass","Grass_2","Bush_1","Flowers","Grass_Short","BushBerries_1"})[i%6+1]
            placed(decor,"NATURE",name,x,z,rng:NextNumber(.8,3.2))
        end
    end
    for i=1,58 do
        if i%12==0 then task.wait() end
        local x=rng:NextNumber(-302,302)
        local z=rng:NextNumber(-302,302)
        if x*x+z*z>55*55 then
            placed(decor,"NATURE",i%3==0 and "Rock_Moss_3" or i%2==0 and "Rock_3" or "Rock_Moss_1",
                x,z,rng:NextNumber(2,7.3))
        end
    end
end
local function village(world)
    local town=Instance.new("Folder");town.Name="Aldeia da Primeira Chama";town.Parent=world
    -- Grande trilha ocre com cascalho aparente e pedras irregulares.
    solid(town,"Trilha principal",Vector3.new(16,.18,220),
        CFrame.new(0,.10,-75),Color3.fromRGB(152,125,88),Enum.Material.Ground,false)
    for i=0,46 do
        local z=-178+i*5.2
        local x=math.sin(i*.36)*2.2
        placed(town,"VILLAGE","Path_Square",x,z,rng:NextNumber(.75,1.55),rng:NextNumber(-.2,.2))
    end
    solid(town,"Placa da vila",Vector3.new(49,.85,49),
        CFrame.new(0,.46,7),Color3.fromRGB(158,132,97),Enum.Material.Cobblestone)
    solid(town,"Circulo sagrado",Vector3.new(17,.95,17),
        CFrame.new(0,.79,-8),Color3.fromRGB(101,122,103),Enum.Material.Slate)
    placed(town,"VILLAGE","Gazebo",-4,13,13)
    placed(town,"VILLAGE","Inn",83,18,38,.22)
    placed(town,"VILLAGE","House_1",-77,20,31)
    placed(town,"VILLAGE","House_2",-99,-27,30)
    placed(town,"VILLAGE","Blacksmith",92,-59,22)
    placed(town,"VILLAGE","Stable",-117,-69,23)
    placed(town,"VILLAGE","Bell_Tower",63,-133,39)
    placed(town,"VILLAGE","Mill",173,143,31)
    placed(town,"VILLAGE","Well",28,39,8)
    placed(town,"VILLAGE","MarketStand_1",51,7,9)
    placed(town,"VILLAGE","MarketStand_1",-47,-43,8)
    -- Feira colorida e com volume similar aos encontros nos bosques de Vesteria.
    tent(town,49,52,Color3.fromRGB(125,72,192))
    tent(town,-35,59,Color3.fromRGB(191,136,78))
    tent(town,74,-34,Color3.fromRGB(73,150,169))
    for i=1,13 do
        local a=i*2.39996
        local radius=43+(i%3)*15
        local x=math.cos(a)*radius
        local z=math.sin(a)*radius
        placed(town,"VILLAGE",i%3==0 and "Barrel" or i%2==0 and "Crate" or "Cart",
            x,z,rng:NextNumber(2,6),a)
    end
    for _,p in ipairs({
        {-18,27},{18,27},{-18,-23},{18,-23},{-12,-107},{12,-107},
        {-36,-77},{36,-77},{-75,52},{68,42},
    })do
        solid(town,"Poste de madeira",Vector3.new(.38,5.8,.38),
            CFrame.new(p[1],2.9,p[2]),Color3.fromRGB(96,70,47),Enum.Material.Wood)
        torch(town,p[1],6,p[2],true)
    end
    for _,p in ipairs({{-55,35},{57,33},{-64,-31},{68,-25},{-34,-95},{35,-95}}) do
        placed(town,"NATURE","CommonTree_4",p[1],p[2],rng:NextNumber(13,19))
        placed(town,"NATURE","BushBerries_1",p[1]+3,p[2]+2,2.2)
        placed(town,"VILLAGE","Bench_1",p[1]-3,p[2]+4,2.5,0)
    end
    local fire=placed(town,"VILLAGE","Bonfire_Lit",17,18,8)
    torch(town,17,3,18,true)
    for _,p in ipairs({{-36,5},{33,-19},{-14,-57},{14,-68}})do
        mushroom(town,p[1],p[2],1.4,true)
    end
    -- Arco e ruinas preservam a silhueta de aventura do primeiro capitulo.
    placed(town,"FORTRESS","WallEntrance",0,-178,26,0)
    placed(town,"FORTRESS","WatchTowerWRoof",-57,-166,34,0)
    placed(town,"FORTRESS","LargeTower",61,-171,36,0)
    placed(town,"DUNGEON","Entrance",-118,-98,23,0)
end
local function waterways(world)
    local zone=Instance.new("Folder");zone.Name="Rio das Estrelas";zone.Parent=world
    for i=0,55 do
        local z=-260+i*10
        local x=169+22*math.sin(z*.014)
        local sheet=solid(zone,"Agua cristalina",Vector3.new(19,.27,12),
            CFrame.new(x,.05,z),Color3.fromRGB(75,174,186),Enum.Material.Glass,false)
        sheet.Transparency=.32
        sheet.CastShadow=false
        if i%6==0 then
            placed(zone,"NATURE","Rock_3",x+13,z,3.3)
        end
    end
    placed(zone,"FORTRESS","Bridge",170,10,17,math.pi/2)
end
function World.create()
    local old=Workspace:FindFirstChild("AlnairWorld")
    if old then return old end
    WorldLighting.apply()
    local world=Instance.new("Folder");world.Name="AlnairWorld";world.Parent=Workspace
    solid(world,"Terras de Alnair",Vector3.new(660,3,660),CFrame.new(0,-1.7,0),
        Color3.fromRGB(82,143,99),Enum.Material.Grass)
    solid(world,"Verde claro na campina",Vector3.new(128,.15,150),CFrame.new(-75,.05,112),
        Color3.fromRGB(103,155,105),Enum.Material.Grass,false)
    -- Carregar primeiro a vila principal e a casa cinematografica.
    -- A decoracao distante nasce em lotes para nao travar o primeiro quadro,
    -- enquanto Workspace.StreamingEnabled controla replicacao por proximidade.
    village(world)
    MenuHouseStage.create(world)
    local spawn=Instance.new("SpawnLocation")
    spawn.Name="AlnairSpawn";spawn.Size=Vector3.new(7,.5,7)
    spawn.CFrame=CFrame.new(0,1.25,12)
    spawn.Anchored=true;spawn.CanCollide=false;spawn.Transparency=1
    spawn.Neutral=true;spawn.Duration=0;spawn.Parent=world
    task.defer(function()
        if not world.Parent then return end
        forest(world)
        groveMushrooms(world)
        waterways(world)
        world:SetAttribute("AlnairFarDecorReady",true)
    end)
    return world
end
return World
