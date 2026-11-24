--!strict
-- ALNAIR: a transicao do menu percorre uma casa real do Workspace.
-- Exterior, bancos, barris e baus reutilizam modelos de malha CC0 ja presentes.
-- Somente a folha da porta usa uma Part para permitir movimento em dobradica.
local ArtAssets=require(script.Parent:WaitForChild("ArtAssets"))
local Stage={}
local ENTRY=Vector3.new(46,0,38)

local function part(parent,name,size,cf,color,material,visible,collidable)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
    p.Material=material or Enum.Material.Wood
    p.Color=color or Color3.fromRGB(115,79,54)
    p.Transparency=visible and 0 or 1;p.CanCollide=collidable==true
    p.CanTouch=false;p.CanQuery=false
    p.CastShadow=visible==true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end
local function lookAnchor(parent,name,pos,look)
    return part(parent,name,Vector3.new(.1,.1,.1),CFrame.lookAt(pos,look),
        Color3.new(0,0,0),Enum.Material.SmoothPlastic,false,false)
end

function Stage.create(world)
    local existing=world:FindFirstChild("MenuCinematicHouse")
    if existing then return existing end
    local house=Instance.new("Model")
    house.Name="MenuCinematicHouse"
    -- The animated menu house is always required BEFORE a character spawns.
    pcall(function()house.ModelStreamingMode=Enum.ModelStreamingMode.Persistent end)
    house.Parent=world

    -- Modelo 3D ja licenciado do Alnair; nao construir uma casa com caixas.
    local exterior=ArtAssets.place("VILLAGE","House_1",house,ENTRY,21,0)
    if exterior then
        exterior.Name="CC0HouseExterior"
    else
        warn("[ALNAIR] House_1 unavailable; menu stage will use entrance geometry only")
    end

    -- Basear paredes, piso e porta no volume do prefab de verdade.
    -- O House_1 importado tem proporcoes diferentes das medidas fixas antigas.
    local boundsCF,boundsSize
    if exterior then
        boundsCF,boundsSize=exterior:GetBoundingBox()
    else
        boundsCF=CFrame.new(ENTRY.X,10.5,ENTRY.Z)
        boundsSize=Vector3.new(13.28,21,16.47)
    end
    local x,z=boundsCF.Position.X,boundsCF.Position.Z
    local floorWidth=math.max(9.0,boundsSize.X-.55)
    local floorDepth=math.max(10.0,boundsSize.Z-.75)
    local halfWidth=floorWidth*.5
    local halfDepth=floorDepth*.5
    -- O batente toca a fachada real; nao fica 0.75 studs destacado dela.
    local front=z+boundsSize.Z*.5+.06
    house:SetAttribute("WallFitWidth",floorWidth)
    house:SetAttribute("WallFitDepth",floorDepth)
    house:SetAttribute("DoorFlushZ",front)
    house:SetAttribute("PrefabWidth",boundsSize.X)
    house:SetAttribute("PrefabDepth",boundsSize.Z)
    local timber=Color3.fromRGB(103,66,43)
    local stone=Color3.fromRGB(137,121,91)
    part(house,"DoorFrameLeft",Vector3.new(.42,7.0,.48),
        CFrame.new(x-1.85,3.5,front),timber,Enum.Material.Wood,true,false)
    part(house,"DoorFrameRight",Vector3.new(.42,7.0,.48),
        CFrame.new(x+1.85,3.5,front),timber,Enum.Material.Wood,true,false)
    part(house,"DoorHeader",Vector3.new(4.15,.60,.70),
        CFrame.new(x,7.10,front),stone,Enum.Material.Cobblestone,true,false)
    local hinge=CFrame.new(x-1.60,3.42,front)
    local offset=CFrame.new(1.60,0,0)
    local door=part(house,"MenuDoor",Vector3.new(3.20,6.84,.27),
        hinge*offset,Color3.fromRGB(104,66,43),Enum.Material.WoodPlanks,true,false)
    door:SetAttribute("HingeX",hinge.Position.X)
    door:SetAttribute("HingeY",hinge.Position.Y)
    door:SetAttribute("HingeZ",hinge.Position.Z)
    door:SetAttribute("Width",3.2)
    local function attachDoor(detail)
        detail.Anchored=false
        local weld=Instance.new("WeldConstraint")
        weld.Part0=door
        weld.Part1=detail
        weld.Parent=detail
    end
    for _,dx in ipairs({-.8,.8}) do
        local brace=part(house,"DoorIronBrace",Vector3.new(.12,5.9,.13),
            door.CFrame*CFrame.new(dx,0,.22),
            Color3.fromRGB(74,73,70),Enum.Material.Metal,true,false)
        attachDoor(brace)
    end
    local knob=part(house,"DoorKnob",Vector3.new(.28,.28,.25),
        door.CFrame*CFrame.new(1.10,-.1,.29),
        Color3.fromRGB(217,165,95),Enum.Material.Metal,true,false)
    knob.Shape=Enum.PartType.Ball
    attachDoor(knob)
    local closed=door.CFrame
    door:SetAttribute("ClosedX",closed.Position.X)
    door:SetAttribute("ClosedY",closed.Position.Y)
    door:SetAttribute("ClosedZ",closed.Position.Z)

    -- Interior real no mesmo local; na entrada o cliente oculta apenas a fachada.
    local interior=Instance.new("Folder")
    interior.Name="Room"
    interior.Parent=house
    part(interior,"Floor",Vector3.new(floorWidth,.46,floorDepth),
        CFrame.new(x,-.07,z),Color3.fromRGB(122,92,67),
        Enum.Material.WoodPlanks,true,false)
    part(interior,"BackWall",Vector3.new(floorWidth,9,.48),
        CFrame.new(x,4.5,z-halfDepth+.18),
        Color3.fromRGB(155,141,116),Enum.Material.Concrete,true,false)
    for _,side in ipairs({-1,1}) do
        local wallX=x+side*(halfWidth-.18)
        part(interior,"SideWall",Vector3.new(.45,9,floorDepth-.12),
            CFrame.new(wallX,4.5,z),
            Color3.fromRGB(150,136,113),Enum.Material.Concrete,true,false)
        for _,factor in ipairs({-.69,0,.69}) do
            part(interior,"TimberBeam",Vector3.new(.56,9,.50),
                CFrame.new(wallX-side*.08,4.5,z+halfDepth*factor),
                timber,Enum.Material.Wood,true,false)
        end
    end
    -- A sala so existia com piso e tres paredes. Quando a fachada externa
    -- ficava invisivel para a camera, o teto desaparecia e entrava o ceu.
    -- Teto e fachada com abertura de porta de verdade, dimensionados pelo
    -- bounding box da casa importada, nao por numeros de screenshot.
    part(interior,"InteriorCeiling",
        Vector3.new(floorWidth+.42,.55,floorDepth+.42),
        CFrame.new(x,9.35,z),Color3.fromRGB(100,76,56),
        Enum.Material.WoodPlanks,true,false)
    for _,offset in ipairs({-.40,0,.40}) do
        part(interior,"CeilingTimberBeam",
            Vector3.new(.45,.52,floorDepth+.18),
            CFrame.new(x+floorWidth*offset,8.86,z),
            timber,Enum.Material.Wood,true,false)
    end
    local doorGap=3.75
    local sideWidth=(floorWidth-doorGap)*.5
    for _,side in ipairs({-1,1}) do
        local wallX=x+side*(doorGap*.5+sideWidth*.5)
        part(interior,"FrontWallSide",
            Vector3.new(sideWidth+.06,9,.45),
            CFrame.new(wallX,4.50,front-.24),
            Color3.fromRGB(155,141,116),Enum.Material.Concrete,true,false)
    end
    part(interior,"FrontWallHeader",
        Vector3.new(doorGap+.05,1.95,.45),
        CFrame.new(x,8.03,front-.24),
        Color3.fromRGB(155,141,116),Enum.Material.Concrete,true,false)

    -- Um unico ponto de iluminacao quente com sombra para o interior;
    -- nao distribuir dezenas de luzes pesadas por cada objeto.
    local lampAnchor=part(interior,"WarmLanternAnchor",Vector3.new(.15,.15,.15),
        CFrame.new(x+3.5,5.4,z-4.6),Color3.fromRGB(245,193,116),
        Enum.Material.SmoothPlastic,false,false)
    local lamp=Instance.new("PointLight")
    lamp.Name="AlnairWarmInterior"
    lamp.Color=Color3.fromRGB(255,199,131)
    lamp.Brightness=1.35
    lamp.Range=17
    lamp.Shadows=true
    lamp.Parent=lampAnchor
    -- Decoracao verdadeira reutilizando os 3D existentes na biblioteca local.
    ArtAssets.place("VILLAGE","Bench_1",interior,Vector3.new(x-4,0,z-5),3.0,math.pi/2)
    ArtAssets.place("VILLAGE","Barrel",interior,Vector3.new(x+5,0,z-4),3.8,0)
    ArtAssets.place("VILLAGE","Crate",interior,Vector3.new(x+5,0,z+1),3.2,.22)
    ArtAssets.place("DUNGEON","Chest",interior,Vector3.new(x-4,0,z+3),2.2,0)
    ArtAssets.place("DUNGEON","Candelabrum",interior,Vector3.new(x+4,0,z-5),5.2,0)
    part(interior,"SelectionRug",Vector3.new(8,.05,5.6),
        CFrame.new(x,.23,z-1.0),Color3.fromRGB(98,80,87),
        Enum.Material.Fabric,true,false)

    local anchors=Instance.new("Folder")
    anchors.Name="CameraAnchors"
    anchors.Parent=house
    lookAnchor(anchors,"Menu",Vector3.new(34,12,78),Vector3.new(x,5,40))
    lookAnchor(anchors,"Approach",Vector3.new(x-2,7.1,front+15),Vector3.new(x,3.5,front))
    lookAnchor(anchors,"Doorway",Vector3.new(x,4.05,front+2.5),Vector3.new(x,3.5,front-9))
    lookAnchor(anchors,"Threshold",Vector3.new(x,4.05,front-3),Vector3.new(x,3.9,front-12))
    lookAnchor(anchors,"Race",Vector3.new(x+1.8,5.5,z+5.5),Vector3.new(x,4.1,z-5))
    lookAnchor(anchors,"Class",Vector3.new(x+4.0,5.6,z+4.4),Vector3.new(x,4.0,z-5))
    lookAnchor(anchors,"Appearance",Vector3.new(x-3.6,5.4,z+4.2),Vector3.new(x,4.0,z-5))
    return house
end
return Stage
