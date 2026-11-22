--!strict
-- Menu inspirado em composições cinematográficas de RPG de fantasia.
-- Sem React nem dependências web; respeita input de mouse, toque e controle Roblox.
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Menu = {}

local COLOR = {
    ink = Color3.fromRGB(8, 11, 16),
    gold = Color3.fromRGB(219, 169, 98),
    light = Color3.fromRGB(243, 227, 196),
    paper = Color3.fromRGB(235, 233, 221),
    mute = Color3.fromRGB(175, 173, 170),
    blue = Color3.fromRGB(116, 175, 185),
}

local function item(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end

local function label(parent, text, rect, pos, size, font, color, z)
    local o = item("TextLabel",{
        Name="Text",
        Text=text, TextColor3=color or COLOR.paper,
        TextSize=size,Font=font or Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
        TextWrapped=true,BackgroundTransparency=1,BorderSizePixel=0,
        Size=rect,Position=pos,ZIndex=z or 5,
    },parent)
    return o
end

local function line(parent, pos, size, color, trans, z)
    return item("Frame",{
        BackgroundColor3=color or COLOR.gold,BackgroundTransparency=trans or 0,
        BorderSizePixel=0,Position=pos,Size=size,ZIndex=z or 4,
    },parent)
end

local function tint(frame, colors, rotation, transparency)
    local ks={}
    for n,c in ipairs(colors) do table.insert(ks,ColorSequenceKeypoint.new((n-1)/(#colors-1),c)) end
    local p={Color=ColorSequence.new(ks),Rotation=rotation or 0}
    if transparency then
        p.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,transparency[1]),
            NumberSequenceKeypoint.new(1,transparency[2]),
        })
    end
    return item("UIGradient",p,frame)
end

local function glowCircle(parent, position, radius, color, trans)
    local node=item("Frame",{
        Name="Halo",BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(.5,.5),Position=position,Size=UDim2.fromOffset(radius,radius),
        ZIndex=2,
    },parent)
    item("UICorner",{CornerRadius=UDim.new(1,0)},node)
    item("UIStroke",{Color=color,Transparency=trans or .88,Thickness=1},node)
    return node
end

local function designNode(parent, position, s, color)
    local p=line(parent,position,UDim2.fromOffset(s,s),color,.25,6)
    p.AnchorPoint=Vector2.new(.5,.5)
    p.Rotation=45
    return p
end

function Menu.show(gui, options)
    local root=item("Frame",{
        Name="AlnairTitleMenu",
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),ClipsDescendants=true,
    },gui)
    local callbacks={}
    local touched=false

    -- O mapa real permanece visível por trás da interface, com ambiente natural.
    local darkLeft=item("Frame",{
        BackgroundColor3=COLOR.ink,BackgroundTransparency=.05,BorderSizePixel=0,
        Size=UDim2.fromScale(.74,1),ZIndex=1,
    },root)
    tint(darkLeft,{COLOR.ink,COLOR.ink},0,{0,1})
    local softBottom=item("Frame",{
        BackgroundColor3=COLOR.ink,BackgroundTransparency=.36,BorderSizePixel=0,
        Position=UDim2.fromScale(0,.62),Size=UDim2.fromScale(1,.38),ZIndex=1,
    },root)
    tint(softBottom,{COLOR.ink,COLOR.ink},90,{1,.17})
    local vignette=item("Frame",{
        BackgroundColor3=COLOR.ink,BackgroundTransparency=.52,BorderSizePixel=0,
        Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,.24),ZIndex=1,
    },root)
    tint(vignette,{COLOR.ink,COLOR.ink},90,{.15,1})

    line(root,UDim2.fromScale(.062,.121),UDim2.new(.876,0,0,1),COLOR.gold,.64,3)
    line(root,UDim2.fromScale(.062,.911),UDim2.new(.876,0,0,1),COLOR.gold,.68,3)
    line(root,UDim2.fromScale(.062,.121),UDim2.new(0,1,.79,0),COLOR.gold,.90,3)
    line(root,UDim2.fromScale(.937,.121),UDim2.new(0,1,.79,0),COLOR.gold,.90,3)

    local symbol=label(root,"✦",UDim2.fromScale(.07,.08),UDim2.fromScale(.068,.024),35,
        Enum.Font.Antique,COLOR.gold,5)
    local company=label(root,"A  L  N  A  I  R",UDim2.fromScale(.47,.08),UDim2.fromScale(.104,.028),21,
        Enum.Font.Antique,COLOR.light,5)
    local topRight=label(root,"PRÓLOGO    /    PRIMEIRA ERA",UDim2.fromScale(.33,.06),UDim2.fromScale(.607,.037),11,
        Enum.Font.GothamBold,COLOR.mute,5)
    topRight.TextXAlignment=Enum.TextXAlignment.Right

    local eyebrow=label(root,"UM NOVO DESTINO AGUARDA",UDim2.fromScale(.5,.035),UDim2.fromScale(.087,.19),11,
        Enum.Font.GothamBold,COLOR.gold,5)
    local title=label(root,"ALNAIR",UDim2.fromScale(.61,.16),UDim2.fromScale(.069,.242),76,
        Enum.Font.Antique,COLOR.light,5)
    title.TextStrokeColor3=COLOR.ink
    title.TextStrokeTransparency=.66
    local rule=line(root,UDim2.fromScale(.088,.423),UDim2.new(.13,0,0,2),COLOR.gold,.25,5)
    local tagline=label(root,"Toda era começa com uma escolha.",UDim2.fromScale(.48,.055),
        UDim2.fromScale(.086,.440),16,Enum.Font.Antique,COLOR.paper,5)
    local secondary=label(root,"Desperte entre as ruínas de um mundo esquecido.\nA história ainda não foi escrita.",
        UDim2.fromScale(.47,.068),UDim2.fromScale(.086,.49),12,Enum.Font.Gotham,COLOR.mute,5)
    secondary.TextYAlignment=Enum.TextYAlignment.Top

    -- Acento delicado e pontual em vez de linhas verticais brilhantes sobre toda a tela.
    local time=0
    local halo=glowCircle(root,UDim2.fromScale(.753,.43),236,COLOR.blue,.91)
    local ring=glowCircle(root,UDim2.fromScale(.753,.43),189,COLOR.gold,.89)
    local stars={}
    for i=1,9 do
        stars[i]=designNode(root,UDim2.fromScale(.75,.42),i%3==0 and 4 or 2,
            i%3==0 and COLOR.gold or COLOR.blue)
    end

    local onUpdate=RunService.RenderStepped:Connect(function(dt)
        if not root.Parent then return end
        time+=math.min(dt,.07)
        ring.Rotation=time*5
        halo.Rotation=-time*3.6
        for i,v in ipairs(stars) do
            local alpha=i*math.pi*2/#stars+time*(i%2==0 and -.085 or .07)
            local radius=.16+(i%3)*.015
            v.Position=UDim2.fromScale(.753+math.cos(alpha)*radius*.55,.43+math.sin(alpha)*radius)
            v.BackgroundTransparency=.38+.28*math.sin(time*1.5+i)
        end
    end)
    table.insert(callbacks,function()onUpdate:Disconnect()end)

    local summary=label(root," ✦   SUA JORNADA, SUAS ESCOLHAS",UDim2.fromScale(.34,.05),
        UDim2.fromScale(.652,.746),10,Enum.Font.GothamBold,COLOR.gold,7)
    summary.TextXAlignment=Enum.TextXAlignment.Center

    -- Manequim de destaque; ganha automaticamente os modelos 3D importados
    -- pela implementação de Appearance.apply().
    if options.appearance and options.selection then
        local viewport=item("ViewportFrame",{
            Name="HeroPreview",
            Ambient=Color3.fromRGB(178,184,191),LightColor=Color3.fromRGB(250,223,185),
            LightDirection=Vector3.new(-.8,-1,-.7),
            BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.fromScale(.57,.164),Size=UDim2.fromScale(.37,.56),ZIndex=6,
        },root)
        local model=item("WorldModel",{},viewport)
        local mannequin=options.appearance.createPreview(model)
        options.appearance.apply(mannequin,options.selection)
        local cam=item("Camera",{FieldOfView=29},viewport)
        cam.CFrame=CFrame.lookAt(Vector3.new(3.0,3.1,-12),Vector3.new(0,2.3,0))
        viewport.CurrentCamera=cam
        local ticker=RunService.RenderStepped:Connect(function(dt)
            if not viewport.Parent then return end
            cam.CFrame=CFrame.lookAt(
                Vector3.new(2.5+math.sin(time*.12)*.65,3.2,-12),
                Vector3.new(0,2.4,0)
            )
        end)
        table.insert(callbacks,function()ticker:Disconnect()end)
    end

    local menu={
        {"CAMPANHA","INICIAR UMA NOVA JORNADA",true,options.campaign},
        {"SANDBOX","EXPLORAÇÃO LIVRE",true,options.sandbox},
        {"CO-OP","EM BREVE",false,nil},
        {"PvP","EM BREVE",false,nil}
    }
    local activeIndex=1
    local rows={}

    local function activate(i)
        if not rows[i] or not menu[i][3] then return end
        activeIndex=i
        for j,o in ipairs(rows) do
            if menu[j][3] then
                local chosen=j==i
                TweenService:Create(o.mark,TweenInfo.new(.18),{BackgroundTransparency=chosen and .07 or 1}):Play()
                TweenService:Create(o.head,TweenInfo.new(.18),{
                    TextColor3=chosen and COLOR.light or COLOR.mute,
                    Position=UDim2.fromScale(chosen and .13 or .114,.02),
                }):Play()
                o.desc.TextColor3=chosen and COLOR.gold or COLOR.mute
            end
        end
    end

    for idx,data in ipairs(menu) do
        local y=.615+(idx-1)*.067
        local enabled=data[3]
        local row=item("TextButton",{
            Name="Menu_"..data[1],
            Text="",AutoButtonColor=false,BorderSizePixel=0,BackgroundTransparency=1,
            Position=UDim2.fromScale(.09,y),Size=UDim2.fromScale(.405,.060),
            Active=enabled,Selectable=enabled,ZIndex=10,
        },root)
        local mark=line(row,UDim2.fromScale(0,.1),UDim2.new(0,3,.80,0),COLOR.gold,idx==1 and .07 or 1,9)
        local number=label(row,string.format("%02d",idx),UDim2.fromScale(.105,.86),UDim2.fromScale(.015,.06),
            12,Enum.Font.GothamBold,enabled and COLOR.gold or COLOR.mute,10)
        local head=label(row,data[1],UDim2.fromScale(.48,.96),UDim2.fromScale(.114,.02),
            20,Enum.Font.Antique,idx==1 and COLOR.light or COLOR.mute,10)
        head.TextTransparency=enabled and 0 or .67
        local desc=label(row,data[2],UDim2.fromScale(.38,.95),UDim2.fromScale(.615,.02),
            9,Enum.Font.GothamBold,idx==1 and COLOR.gold or COLOR.mute,10)
        desc.TextTransparency=enabled and .10 or .72
        desc.TextXAlignment=Enum.TextXAlignment.Right
        line(row,UDim2.fromScale(0,.99),UDim2.new(1,0,0,1),
            enabled and COLOR.gold or COLOR.mute,enabled and .77 or .93,10)
        rows[idx]={mark=mark,head=head,desc=desc,button=row}
        if enabled then
            row.MouseEnter:Connect(function()activate(idx)end)
            row.SelectionGained:Connect(function()activate(idx)end)
            row.MouseButton1Click:Connect(function()
                if touched then return end
                touched=true
                if data[4] then data[4]() end
            end)
        end
    end

    local footer=label(root,"✦  ALNAIR  /  A LENDA COMEÇA AQUI",UDim2.fromScale(.48,.055),
        UDim2.fromScale(.082,.925),10,Enum.Font.GothamMedium,COLOR.mute,5)
    local version=label(root,"EDIÇÃO DE DESENVOLVIMENTO   •   0.3",UDim2.fromScale(.34,.06),
        UDim2.fromScale(.605,.926),10,Enum.Font.GothamMedium,COLOR.mute,5)
    version.TextXAlignment=Enum.TextXAlignment.Right

    local curtain=item("Frame",{
        BackgroundColor3=COLOR.ink,BackgroundTransparency=0,BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),ZIndex=30,Active=true,
    },root)
    TweenService:Create(curtain,TweenInfo.new(.72,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
        BackgroundTransparency=1,
    }):Play()
    task.delay(.75,function()
        if curtain.Parent then curtain:Destroy() end
    end)

    return function()
        for _,cb in ipairs(callbacks) do cb() end
        root:Destroy()
    end
end

return Menu
