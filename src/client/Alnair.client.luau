--!strict
-- ALNAIR · interface imersiva 0.2
-- Implementação Roblox nativa inspirada em FluxLines, CircularCarousel e HalftoneReveal.
-- O prólogo cinematográfico existente é preservado abaixo desta seção.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("AlnairShared")
local Catalog = require(shared:WaitForChild("Catalog"))
local Appearance = require(shared:WaitForChild("Appearance"))
local Visuals = require(script.Parent:WaitForChild("Visuals"))
local MenuReforged = require(script.Parent:WaitForChild("MenuReforged"))
local startEvent = ReplicatedStorage:WaitForChild("AlnairRemotes"):WaitForChild("StartJourney")

while not workspace.CurrentCamera do task.wait() end
local camera = workspace.CurrentCamera
local gui = Instance.new("ScreenGui")
gui.Name = "AlnairUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 20
gui.Parent = playerGui

local ink = Color3.fromRGB(8, 15, 22)
local dark = Color3.fromRGB(14, 24, 33)
local soft = Color3.fromRGB(24, 36, 46)
local bg = dark
local ivory = Color3.fromRGB(240, 233, 213)
local muted = Color3.fromRGB(162, 174, 177)
local gold = Color3.fromRGB(225, 183, 115)
local paleGold = Color3.fromRGB(245, 221, 168)
local cyan = Color3.fromRGB(143, 198, 214)

local state = { mode = "campaign", race = "human", class = "warrior", appearance = {} }
for k,v in pairs(Catalog.DefaultAppearance) do state.appearance[k] = v end

local currentStep = 1
local tab = "face"
local waiting = false
local cinematicSkip = false
local currentCameraTween = nil
local renderCreator
local renderMenu
local cleanup = {}

local function obj(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do
        o[k] = v
    end
    if parent then o.Parent = parent end
    return o
end

local function round(element, radius)
    obj("UICorner",{CornerRadius=UDim.new(0,radius or 8)},element)
    return element
end

local function stroke(element, color, transparency, thickness)
    return obj("UIStroke",{
        Color=color or gold, Transparency=transparency or 0,
        Thickness=thickness or 1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
    },element)
end

local function gradient(element, colors, rotation, alpha)
    local keys={}
    for i,c in ipairs(colors) do
        table.insert(keys,ColorSequenceKeypoint.new((i-1)/(#colors-1),c))
    end
    local props={Color=ColorSequence.new(keys),Rotation=rotation or 0}
    if alpha then
        props.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,alpha[1]),
            NumberSequenceKeypoint.new(1,alpha[2]),
        })
    end
    return obj("UIGradient",props,element)
end

local function line(parent, position, size, color, transparency, z, rotation)
    return obj("Frame",{
        BorderSizePixel=0,BackgroundColor3=color or gold,
        BackgroundTransparency=transparency or 0,
        Position=position,Size=size,Rotation=rotation or 0,
        ZIndex=z or 4,
    },parent)
end

local function label(parent, content, fontSize, color, font, rect, extra)
    local props={
        BackgroundTransparency=1,BorderSizePixel=0,Text=content,
        TextSize=fontSize,TextColor3=color or ivory,Font=font or Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
        TextWrapped=true,Size=rect or UDim2.fromScale(1,1),
        ZIndex=8,
    }
    for k,v in pairs(extra or {}) do props[k]=v end
    return obj("TextLabel",props,parent)
end

local function register(callback)
    table.insert(cleanup,callback)
    return callback
end

local function clear()
    for _,fn in ipairs(cleanup) do pcall(fn) end
    table.clear(cleanup)
    for _,child in ipairs(gui:GetChildren()) do child:Destroy() end
end

local function scenicCamera()
    camera.CameraType=Enum.CameraType.Scriptable
    camera.FieldOfView=58
    camera.CFrame=CFrame.lookAt(Vector3.new(-52,38,70),Vector3.new(0,6,-26))
end

local function base()
    local root=obj("Frame",{
        Name="AstralScreen",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),
        ClipsDescendants=true,ZIndex=1,
    },gui)

    local wash=obj("Frame",{
        BackgroundColor3=dark,BackgroundTransparency=.33,BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),ZIndex=1,
    },root)
    gradient(wash,{Color3.fromRGB(5,10,18),Color3.fromRGB(10,18,27),Color3.fromRGB(22,34,43)},15)

    local left=obj("Frame",{
        BorderSizePixel=0,BackgroundColor3=ink,BackgroundTransparency=.1,
        Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(.84,1),ZIndex=1,
    },root)
    gradient(left,{ink,ink},0,{.06,1})

    local bottom=obj("Frame",{
        BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(5,10,18),BackgroundTransparency=.45,
        Position=UDim2.fromScale(0,.69),Size=UDim2.fromScale(1,.31),ZIndex=1,
    },root)
    gradient(bottom,{ink,ink},90,{1,.16})

    -- Pequenas marcações em vez de grandes cartões retangulares.
    line(root,UDim2.fromScale(.043,.108),UDim2.new(.914,0,0,1),gold,.64,4)
    line(root,UDim2.fromScale(.043,.933),UDim2.new(.914,0,0,1),gold,.74,4)
    return root
end

local function signature(root, section)
    label(root,"✦",27,paleGold,Enum.Font.Antique,UDim2.fromOffset(29,35),{
        Position=UDim2.fromScale(.047,.024),TextXAlignment=Enum.TextXAlignment.Center,
    })
    label(root,"A L N A I R",20,ivory,Enum.Font.Antique,UDim2.fromScale(.32,.06),{
        Position=UDim2.fromScale(.08,.026),
    })
    label(root,section or "AS TERRAS ESQUECIDAS",11,muted,Enum.Font.GothamBold,UDim2.fromScale(.38,.052),{
        Position=UDim2.fromScale(.57,.034),TextXAlignment=Enum.TextXAlignment.Right,
    })
end

local function button(parent,text,position,size,action,color,outlined,disabled)
    local b=obj("TextButton",{
        Text=text,TextSize=15,TextWrapped=true,Font=Enum.Font.GothamBold,
        TextColor3=disabled and Color3.fromRGB(96,108,114) or ivory,
        BackgroundColor3=color or soft,BackgroundTransparency=outlined and .72 or .09,
        BorderSizePixel=0,AutoButtonColor=false,Active=not disabled,Selectable=not disabled,
        Position=position,Size=size,ZIndex=10,
    },parent)
    round(b,5)
    if outlined then stroke(b,disabled and muted or gold,disabled and .86 or .54) end
    if not disabled then
        local resting=b.BackgroundTransparency
        b.MouseEnter:Connect(function()
            TweenService:Create(b,TweenInfo.new(.17),{
                BackgroundTransparency=math.max(0,resting-.30),
                BackgroundColor3=soft,
            }):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b,TweenInfo.new(.17),{
                BackgroundTransparency=resting,
                BackgroundColor3=color or soft,
            }):Play()
        end)
        b.MouseButton1Click:Connect(function()
            if action then action() end
        end)
    end
    return b
end

local function chapterProgress(root)
    label(root,"A CRIAÇÃO DE UM LEGADO",11,gold,Enum.Font.GothamBold,
        UDim2.fromScale(.47,.035),{Position=UDim2.fromScale(.047,.13)})
    local names={"ORIGEM","DESTINO","IDENTIDADE"}
    for i,name in ipairs(names) do
        local x=.047+(i-1)*.145
        line(root,UDim2.fromScale(x,.197),UDim2.new(.13,0,0,2),
            i<=currentStep and gold or muted,i<=currentStep and .07 or .83,6)
        label(root,string.format("%02d  %s",i,name),10,
            i==currentStep and paleGold or muted,Enum.Font.GothamBold,
            UDim2.fromScale(.14,.033),{Position=UDim2.fromScale(x,.162)})
    end
end

local function fadingEntrance(root)
    -- Escurecimento cinematográfico de entrada, sem travar os botões.
    local curtain=obj("Frame",{
        BackgroundColor3=ink,BackgroundTransparency=0,
        BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=35,Active=true,
    },root)
    TweenService:Create(curtain,TweenInfo.new(.65,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
        BackgroundTransparency=1,
    }):Play()
    task.delay(.68,function()
        if curtain.Parent then curtain:Destroy() end
    end)
end

local function footer(root, text)
    label(root,text,10,muted,Enum.Font.GothamMedium,UDim2.fromScale(.5,.033),{
        Position=UDim2.fromScale(.048,.949),
    })
    label(root,"VERSÃO 0.2  •  UMA HISTÓRIA POR ESCREVER",10,muted,Enum.Font.GothamMedium,
        UDim2.fromScale(.40,.034),{
            Position=UDim2.fromScale(.56,.949),
            TextXAlignment=Enum.TextXAlignment.Right,
        })
end

local function decorativeStar(root, x, y, size, color)
    local diamond=line(root,UDim2.fromScale(x,y),UDim2.fromOffset(size,size),color,.12,5,45)
    diamond.AnchorPoint=Vector2.new(.5,.5)
    local core=line(root,UDim2.fromScale(x,y),UDim2.fromOffset(size*.55,size*.55),ivory,.14,6,45)
    core.AnchorPoint=Vector2.new(.5,.5)
end

local function menuChoice(root,order,title,subtitle,enabled,handler)
    local y=.528+(order-1)*.098
    local wrap=obj("TextButton",{
        Text="",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromScale(.083,y),Size=UDim2.fromScale(.39,.083),
        AutoButtonColor=false,Active=enabled,Selectable=enabled,ZIndex=7,
    },root)
    local baseLine=line(wrap,UDim2.fromScale(0,1),UDim2.new(1,0,0,1),
        enabled and Color3.fromRGB(188,193,190) or muted,.73,8)
    local leading=line(wrap,UDim2.fromScale(0,0),UDim2.new(0,3,1,0),gold,1,8)
    local serial=label(wrap,string.format("%02d",order),11,enabled and gold or muted,
        Enum.Font.GothamBold,UDim2.fromScale(.10,.8),{
            Position=UDim2.fromScale(.02,.10),TextTransparency=enabled and .15 or .61,
        })
    local name=label(wrap,title,21,enabled and ivory or muted,Enum.Font.Antique,
        UDim2.fromScale(.52,.8),{
            Position=UDim2.fromScale(.13,.10),TextTransparency=enabled and 0 or .65,
        })
    local detail=label(wrap,subtitle,10,enabled and gold or muted,Enum.Font.GothamBold,
        UDim2.fromScale(.32,.76),{
            Position=UDim2.fromScale(.66,.13),
            TextXAlignment=Enum.TextXAlignment.Right,
            TextTransparency=enabled and .30 or .70,
        })
    if enabled then
        wrap.MouseEnter:Connect(function()
            TweenService:Create(leading,TweenInfo.new(.18),{BackgroundTransparency=0}):Play()
            TweenService:Create(name,TweenInfo.new(.18),{Position=UDim2.fromScale(.149,.10),TextColor3=paleGold}):Play()
            TweenService:Create(baseLine,TweenInfo.new(.18),{BackgroundTransparency=.24}):Play()
        end)
        wrap.MouseLeave:Connect(function()
            TweenService:Create(leading,TweenInfo.new(.18),{BackgroundTransparency=1}):Play()
            TweenService:Create(name,TweenInfo.new(.18),{Position=UDim2.fromScale(.13,.10),TextColor3=ivory}):Play()
            TweenService:Create(baseLine,TweenInfo.new(.18),{BackgroundTransparency=.73}):Play()
        end)
        wrap.MouseButton1Click:Connect(function() if handler then handler() end end)
    end
end

renderMenu=function()
    clear()
    waiting=false
    scenicCamera()
    local root=base()
    signature(root,"PRÓLOGO  •  O DESPERTAR")

    -- Um campo de linhas animadas ocupa a parte direita, como aurora mágica.
    register(Visuals.flux(root,{
        position=UDim2.fromScale(.42,.08),size=UDim2.fromScale(.58,.89),
        strands=7,segments=16,speed=.27,
        colors={cyan,Color3.fromRGB(225,218,183),Color3.fromRGB(144,174,207)},
    }))
    local h=math.max(235,math.min(camera.ViewportSize.Y*.73,410))
    register(Visuals.rings(root,.78,.54,h))
    decorativeStar(root,.78,.54,22,paleGold)
    decorativeStar(root,.73,.26,7,cyan)
    decorativeStar(root,.94,.69,7,gold)

    label(root,"A ESTRELA NÃO ESQUECE",12,gold,Enum.Font.GothamBold,
        UDim2.fromScale(.52,.048),{Position=UDim2.fromScale(.083,.16)})
    local title=label(root,"ALNAIR",82,ivory,Enum.Font.Antique,
        UDim2.fromScale(.66,.21),{
            Position=UDim2.fromScale(.072,.205),
            TextYAlignment=Enum.TextYAlignment.Center,
        })
    title.TextStrokeColor3=ink
    title.TextStrokeTransparency=.64
    label(root,"UM MUNDO ENTRE A LUZ E O ESQUECIMENTO",13,paleGold,Enum.Font.GothamMedium,
        UDim2.fromScale(.59,.055),{Position=UDim2.fromScale(.084,.402)})
    label(root,"O destino não é escrito pelas estrelas.\nEle começa com a sua escolha.",14,muted,
        Enum.Font.Gotham,UDim2.fromScale(.50,.082),{
            Position=UDim2.fromScale(.084,.449),TextYAlignment=Enum.TextYAlignment.Top,
        })

    menuChoice(root,1,"CAMPANHA","INICIAR JORNADA",true,function()
        state.mode="campaign"
        currentStep=1
        renderCreator()
    end)
    menuChoice(root,2,"SANDBOX","MUNDO LIVRE",true,function()
        if waiting then return end
        state.mode="sandbox"
        waiting=true
        clear()
        local r=base()
        signature(r,"PREPARANDO A EXPLORAÇÃO")
        register(Visuals.flux(r,{position=UDim2.fromScale(.1,.2),size=UDim2.fromScale(.8,.62),strands=6,segments=13,speed=.34}))
        label(r,"As portas de Alnair se abrem...",37,ivory,Enum.Font.Antique,
            UDim2.fromScale(.86,.22),{
                Position=UDim2.fromScale(.07,.40),TextXAlignment=Enum.TextXAlignment.Center,
            })
        startEvent:FireServer("sandbox",{})
    end)
    menuChoice(root,3,"CO-OP","EM BREVE  •  BLOQUEADO",false,nil)
    menuChoice(root,4,"PvP","EM BREVE  •  BLOQUEADO",false,nil)

    label(root,"✦  ESCOLHA SEU CAMINHO",10,muted,Enum.Font.GothamBold,
        UDim2.fromScale(.25,.04),{
            Position=UDim2.fromScale(.66,.80),TextXAlignment=Enum.TextXAlignment.Center,
        })
    footer(root,"ALNAIR   /   A PRIMEIRA ERA")
    fadingEntrance(root)
end

local function displayAvatar(parent, selection, position, size, fov)
    local viewport=obj("ViewportFrame",{
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=position or UDim2.fromScale(0,0),
        Size=size or UDim2.fromScale(1,1),
        Ambient=Color3.fromRGB(172,182,204),
        LightColor=Color3.fromRGB(255,231,190),
        LightDirection=Vector3.new(-.7,-1,-.7),
        ZIndex=8,
    },parent)
    local worldModel=obj("WorldModel",{},viewport)
    local rig=Appearance.createPreview(worldModel)
    Appearance.apply(rig,selection)
    local cam=obj("Camera",{FieldOfView=fov or 36},viewport)
    cam.CFrame=CFrame.lookAt(Vector3.new(3.7,3.6,-11.7),Vector3.new(0,2.3,0))
    viewport.CurrentCamera=cam
    return viewport,rig,cam
end

local function carouselStep(root)
    local isRace=currentStep==1
    local ids=isRace and Catalog.RaceOrder or Catalog.ClassOrder
    local items=isRace and Catalog.Races or Catalog.Classes
    local selected=isRace and state.race or state.class
    local selectedIndex=table.find(ids,selected) or 1
    local accent=isRace and cyan or gold

    chapterProgress(root)
    local heading=isRace and "O sangue que te define." or "A arma que escolhe você."
    local subtitle=isRace and "Cada origem carrega uma história. Qual será a sua?" or
        "Todo caminho exige uma escolha. Que legado você deixará?"
    label(root,heading,36,ivory,Enum.Font.Antique,UDim2.fromScale(.78,.085),{
        Position=UDim2.fromScale(.047,.225),
    })
    label(root,subtitle,13,muted,Enum.Font.Gotham,UDim2.fromScale(.76,.04),{
        Position=UDim2.fromScale(.050,.306),
    })

    local stage=obj("Frame",{
        Name="CircularCarouselNative",
        BackgroundTransparency=1,BorderSizePixel=0,
        Active=true,ClipsDescendants=true,
        Position=UDim2.fromScale(.03,.347),
        Size=UDim2.fromScale(.62,.48),
        ZIndex=4,
    },root)
    local bottomLine=line(stage,UDim2.fromScale(.06,.94),UDim2.new(.88,0,0,1),gold,.57,4)
    local shadow=line(stage,UDim2.fromScale(.25,.89),UDim2.fromScale(.52,.075),Color3.fromRGB(9,14,19),.44,4)
    round(shadow,100)
    shadow.Visible=true

    local cards={}
    local function createCard(i,id)
        local item=items[id]
        local card=obj("TextButton",{
            Name="OrbitCard_"..id,
            Text="",AutoButtonColor=false,
            BackgroundColor3=dark,BackgroundTransparency=.16,
            BorderSizePixel=0,
            AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.fromScale(.5,.52),
            Size=UDim2.fromScale(.3,.85),
            ClipsDescendants=true,ZIndex=8,Active=true,
        },stage)
        round(card,9)
        local outline=stroke(card,gold,.7,1)
        local wash=obj("Frame",{
            BackgroundColor3=Color3.fromRGB(29,44,54),
            BorderSizePixel=0,BackgroundTransparency=.35,
            Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),
            ZIndex=8,
        },card)
        gradient(wash,{Color3.fromRGB(44,64,76),Color3.fromRGB(10,17,25)},90)
        local hairline=line(card,UDim2.fromScale(.06,.035),UDim2.new(.88,0,0,1),gold,.48,9)
        local selection={
            race=isRace and id or state.race,
            class=isRace and state.class or id,
            appearance=state.appearance,
        }
        displayAvatar(card,selection,UDim2.fromScale(.03,.04),UDim2.fromScale(.94,.75),36)
        local fade=obj("Frame",{
            BorderSizePixel=0,BackgroundColor3=ink,BackgroundTransparency=.36,
            Size=UDim2.fromScale(1,.32),Position=UDim2.fromScale(0,.68),ZIndex=9,
        },card)
        gradient(fade,{ink,ink},90,{1,.10})
        local number=label(card,string.format("%02d",i),11,paleGold,Enum.Font.GothamBold,
            UDim2.fromScale(.23,.12),{Position=UDim2.fromScale(.09,.07),ZIndex=10})
        local name=label(card,item.name:upper(),19,ivory,Enum.Font.Antique,
            UDim2.fromScale(.92,.18),{
                Position=UDim2.fromScale(.04,.78),TextXAlignment=Enum.TextXAlignment.Center,ZIndex=10,
            })
        cards[i]={root=card,outline=outline,number=number,name=name,id=id}
        card.MouseButton1Click:Connect(function()
            if selectedIndex==i then return end
            selectedIndex=i
            selected=id
            if isRace then state.race=id else state.class=id end
            -- Atualização de posições sem recriar os modelos 3D.
            if cards.update then cards.update() end
        end)
    end
    for i,id in ipairs(ids) do createCard(i,id) end

    local info=obj("Frame",{
        BackgroundColor3=ink,BackgroundTransparency=.24,BorderSizePixel=0,
        Position=UDim2.fromScale(.668,.359),Size=UDim2.fromScale(.285,.47),
        ZIndex=5,
    },root)
    round(info,3)
    line(info,UDim2.fromScale(0,0),UDim2.new(0,2,1,0),gold,.07,7)
    local category=label(info,isRace and "ORIGEM SELECIONADA" or "CAMINHO ESCOLHIDO",
        11,gold,Enum.Font.GothamBold,UDim2.fromScale(.89,.08),{
            Position=UDim2.fromScale(.075,.06),
        })
    local num=label(info,"01  /  04",12,cyan,Enum.Font.GothamBold,UDim2.fromScale(.89,.08),{
        Position=UDim2.fromScale(.075,.17),
    })
    local infoTitle=label(info,"",39,ivory,Enum.Font.Antique,UDim2.fromScale(.88,.23),{
        Position=UDim2.fromScale(.075,.26),TextYAlignment=Enum.TextYAlignment.Top,
    })
    line(info,UDim2.fromScale(.075,.53),UDim2.new(.35,0,0,1),gold,.31,7)
    local infoSubtitle=label(info,"",13,paleGold,Enum.Font.GothamBold,UDim2.fromScale(.86,.12),{
        Position=UDim2.fromScale(.075,.56),
    })
    local description=label(info,"",13,muted,Enum.Font.Gotham,UDim2.fromScale(.84,.25),{
        Position=UDim2.fromScale(.075,.69),TextYAlignment=Enum.TextYAlignment.Top,
    })

    local function placement(index)
        local delta=index-selectedIndex
        local length=#ids
        if delta>length/2 then delta-=length end
        if delta< -length/2 then delta+=length end
        if length%2==0 and delta==length/2 then delta=-delta end
        local distance=math.abs(delta)
        if distance==0 then
            return UDim2.fromScale(.50,.51),UDim2.fromScale(.39,.88),.05,10,true
        elseif distance==1 then
            return UDim2.fromScale(.50+(delta>0 and .34 or -.34),.535),
                UDim2.fromScale(.28,.70),.30,8,true
        else
            return UDim2.fromScale(.50+(delta>0 and .59 or -.59),.55),
                UDim2.fromScale(.18,.54),.76,6,false
        end
    end

    local function update()
        local item=items[ids[selectedIndex]]
        local letter=isRace and (item.title or "UMA NOVA ORIGEM") or (item.weapon or "UM NOVO CAMINHO")
        num.Text=string.format("%02d  /  %02d",selectedIndex,#ids)
        infoTitle.Text=item.name
        infoSubtitle.Text=letter:upper()
        description.Text=item.description
        for i,itemCard in ipairs(cards) do
            local pos,size,trans,z,visible=placement(i)
            itemCard.root.ZIndex=z
            itemCard.root.Active=visible
            local chosen=i==selectedIndex
            TweenService:Create(itemCard.root,TweenInfo.new(.44,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                Position=pos,Size=size,BackgroundTransparency=trans,
            }):Play()
            TweenService:Create(itemCard.outline,TweenInfo.new(.3),{
                Transparency=chosen and .12 or .83,
                Thickness=chosen and 2 or 1,
            }):Play()
            itemCard.name.TextColor3=chosen and ivory or muted
        end
    end
    cards.update=update
    update()

    local function shift(amount)
        selectedIndex=((selectedIndex-1+amount)%#ids)+1
        local id=ids[selectedIndex]
        if isRace then state.race=id else state.class=id end
        update()
    end
    local prev=button(root,"〈",UDim2.fromScale(.045,.57),UDim2.fromScale(.047,.078),
        function()shift(-1) end,dark,true)
    local nxt=button(root,"〉",UDim2.fromScale(.582,.57),UDim2.fromScale(.047,.078),
        function()shift(1) end,dark,true)
    prev.TextSize=30
    nxt.TextSize=30

    label(root,"←  →   SELECIONE / ARRASTE PARA EXPLORAR",10,muted,Enum.Font.GothamBold,
        UDim2.fromScale(.59,.037),{
            Position=UDim2.fromScale(.052,.837),TextXAlignment=Enum.TextXAlignment.Center,
        })

    local beganX=nil
    register((function()
        local onBegan=stage.InputBegan:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.Touch then beganX=io.Position.X end
        end)
        local onEnded=stage.InputEnded:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.Touch and beganX then
                local dx=io.Position.X-beganX
                if math.abs(dx)>40 then shift(dx>0 and -1 or 1) end
                beganX=nil
            end
        end)
        local onChanged=stage.InputChanged:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseWheel then
                shift(io.Position.Z>0 and -1 or 1)
            end
        end)
        local keyboard=UserInputService.InputBegan:Connect(function(io,processed)
            if processed then return end
            if io.KeyCode==Enum.KeyCode.Left or io.KeyCode==Enum.KeyCode.A then shift(-1) end
            if io.KeyCode==Enum.KeyCode.Right or io.KeyCode==Enum.KeyCode.D then shift(1) end
        end)
        return function() onBegan:Disconnect();onEnded:Disconnect();onChanged:Disconnect();keyboard:Disconnect() end
    end)())

    button(root,"←  VOLTAR",UDim2.fromScale(.051,.872),UDim2.fromScale(.185,.066),function()
        if currentStep==1 then renderMenu()
        else currentStep=1;renderCreator() end
    end,dark,true)
    button(root,isRace and "ESCOLHER CLASSE  →" or "PERSONALIZAR  →",
        UDim2.fromScale(.715,.871),UDim2.fromScale(.237,.067),function()
            currentStep+=1
            renderCreator()
        end,Color3.fromRGB(112,89,61),true)
    footer(root,isRace and "CAPÍTULO I  /  ORIGENS" or "CAPÍTULO II  /  CAMINHOS")
end

-- NEXT: APPEARANCE CREATOR AND renderCreator

local function appearanceStep(root)
    chapterProgress(root)
    label(root,"Um rosto para a eternidade.",36,ivory,Enum.Font.Antique,
        UDim2.fromScale(.81,.082),{Position=UDim2.fromScale(.047,.22)})
    label(root,"A sua lenda tem a sua aparência. Ajuste cada detalhe.",13,muted,Enum.Font.Gotham,
        UDim2.fromScale(.80,.037),{Position=UDim2.fromScale(.049,.303)})

    local portrait=obj("Frame",{
        BackgroundColor3=Color3.fromRGB(14,24,34),
        BackgroundTransparency=.41,BorderSizePixel=0,
        Position=UDim2.fromScale(.048,.355),Size=UDim2.fromScale(.395,.478),
        ZIndex=4,ClipsDescendants=true,
    },root)
    round(portrait,8)
    stroke(portrait,gold,.71)
    local ambiance=obj("Frame",{
        BackgroundColor3=Color3.fromRGB(37,52,65),
        BackgroundTransparency=.12,BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),ZIndex=4,
    },portrait)
    gradient(ambiance,{Color3.fromRGB(36,49,61),Color3.fromRGB(9,15,23)},90)
    local halo=line(portrait,UDim2.fromScale(.19,.18),UDim2.fromScale(.62,.69),
        Color3.fromRGB(66,93,101),.80,5)
    round(halo,200)
    stroke(halo,cyan,.84)
    local preview,rig,cam=displayAvatar(portrait,state,
        UDim2.fromScale(.06,.01),UDim2.fromScale(.88,.94),29)
    preview.Active=true
    local charYaw=0
    local targetYaw=.10
    local touchX=nil
    register(Visuals.halftone(portrait,{
        color=gold,columns=21,rows=14,size=3,zIndex=9,
    }))
    register((function()
        local began=preview.InputBegan:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
                touchX=io.Position.X
            end
        end)
        local move=UserInputService.InputChanged:Connect(function(io)
            if not touchX then return end
            if io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch then
                local x=io.Position.X
                targetYaw+=math.clamp((x-touchX)*.009,-.33,.33)
                touchX=x
            end
        end)
        local ended=UserInputService.InputEnded:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
                touchX=nil
            end
        end)
        local spin=RunService.RenderStepped:Connect(function(dt)
            charYaw+=(targetYaw-charYaw)*math.min(1,dt*9)
            local pos=Vector3.new(math.sin(charYaw)*11.8,4,math.cos(charYaw)*-11.8)
            cam.CFrame=CFrame.lookAt(pos,Vector3.new(0,2.45,0))
        end)
        return function()
            began:Disconnect();move:Disconnect();ended:Disconnect();spin:Disconnect()
        end
    end)())
    label(portrait,"✦  PRÉVIA DO PERSONAGEM",11,paleGold,Enum.Font.GothamBold,
        UDim2.fromScale(.90,.06),{Position=UDim2.fromScale(.055,.035),ZIndex=12})
    label(portrait,"ARRASTE PARA GIRAR  ⟳",10,muted,Enum.Font.GothamBold,
        UDim2.fromScale(.9,.052),{
            Position=UDim2.fromScale(.05,.91),
            TextXAlignment=Enum.TextXAlignment.Center,ZIndex=12,
        })

    local chosenRace=Catalog.Races[state.race].name
    local chosenClass=Catalog.Classes[state.class].name
    label(root,(chosenRace.."   /   "..chosenClass):upper(),15,paleGold,
        Enum.Font.Antique,UDim2.fromScale(.395,.045),{
            Position=UDim2.fromScale(.048,.832),TextXAlignment=Enum.TextXAlignment.Center,
        })

    local panel=obj("Frame",{
        Name="AppearanceAtelier",
        BackgroundColor3=ink,BackgroundTransparency=.23,
        BorderSizePixel=0,
        Position=UDim2.fromScale(.488,.350),Size=UDim2.fromScale(.466,.525),
        ZIndex=4,
    },root)
    round(panel,5)
    line(panel,UDim2.fromScale(0,0),UDim2.new(0,2,1,0),gold,.16,6)
    label(panel,"ATELIÊ DA IDENTIDADE",12,gold,Enum.Font.GothamBold,
        UDim2.fromScale(.86,.075),{Position=UDim2.fromScale(.045,.025)})
    local tcount=label(panel,"01  /  07",11,muted,Enum.Font.GothamBold,
        UDim2.fromScale(.28,.075),{
            Position=UDim2.fromScale(.675,.025),TextXAlignment=Enum.TextXAlignment.Right,
        })

    local tabs=obj("Frame",{
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromScale(.035,.115),
        Size=UDim2.fromScale(.93,.235),ZIndex=8,
    },panel)
    local buttons={}
    for i,key in ipairs(Catalog.PresetOrder) do
        local name=Catalog.Presets[key].name
        local c=(i-1)%4
        local row=math.floor((i-1)/4)
        local b=obj("TextButton",{
            Text=name,Font=Enum.Font.GothamBold,TextSize=12,
            TextColor3=muted,TextWrapped=true,
            BackgroundColor3=soft,BackgroundTransparency=.83,
            BorderSizePixel=0,AutoButtonColor=false,
            Position=UDim2.new(c*.25+.005,0,row*.48+.02,0),
            Size=UDim2.fromScale(.239,.43),
            ZIndex=8,
        },tabs)
        round(b,3)
        buttons[key]=b
        b.MouseButton1Click:Connect(function()
            tab=key
            if buttons.refresh then buttons.refresh() end
        end)
    end
    local ruler=line(panel,UDim2.fromScale(.048,.363),UDim2.new(.90,0,0,1),gold,.72,8)
    local groupTitle=label(panel,"",18,ivory,Enum.Font.Antique,
        UDim2.fromScale(.76,.095),{Position=UDim2.fromScale(.05,.385)})
    local groupDesc=label(panel,"CLIQUE PARA EXPERIMENTAR",10,muted,Enum.Font.GothamBold,
        UDim2.fromScale(.70,.075),{Position=UDim2.fromScale(.05,.465)})

    local scroll=obj("ScrollingFrame",{
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromScale(.05,.544),Size=UDim2.fromScale(.89,.404),
        ScrollingDirection=Enum.ScrollingDirection.Y,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.fromOffset(0,0),
        ScrollBarThickness=3,
        ScrollBarImageColor3=gold,
        ZIndex=9,
    },panel)
    local grid=obj("UIGridLayout",{
        CellSize=UDim2.new(.48,0,0,43),
        CellPadding=UDim2.new(.035,0,0,8),
        SortOrder=Enum.SortOrder.LayoutOrder,
    },scroll)

    local optionButtons={}
    local function highlight()
        for key,b in pairs(buttons) do
            if typeof(b)=="Instance" then
                local selected=key==tab
                b.TextColor3=selected and paleGold or muted
                b.BackgroundTransparency=selected and .42 or .83
                b.BackgroundColor3=selected and Color3.fromRGB(69,56,43) or soft
            end
        end
        for id,b in pairs(optionButtons) do
            local selected=state.appearance[tab]==id
            b.TextColor3=selected and paleGold or muted
            b.BackgroundColor3=selected and Color3.fromRGB(67,57,45) or soft
            b.BackgroundTransparency=selected and .06 or .63
            local mark=b:FindFirstChild("SelectedLine")
            if mark then
                mark.BackgroundTransparency=selected and .05 or 1
            end
        end
        local idx=table.find(Catalog.PresetOrder,tab) or 1
        tcount.Text=string.format("%02d  /  %02d",idx,#Catalog.PresetOrder)
    end

    local function options()
        for _,ch in ipairs(scroll:GetChildren()) do
            if ch~=grid then ch:Destroy() end
        end
        table.clear(optionButtons)
        local group=Catalog.Presets[tab]
        groupTitle.Text=group.name:upper()
        local opts=group.options
        for i,opt in ipairs(opts) do
            local b=obj("TextButton",{
                Name=opt.id,
                Text="   "..opt.name,
                Font=Enum.Font.GothamSemibold,
                TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                TextColor3=muted,
                AutoButtonColor=false,
                BorderSizePixel=0,
                BackgroundColor3=soft,BackgroundTransparency=.61,
                LayoutOrder=i,
                ZIndex=9,
            },scroll)
            round(b,3)
            line(b,UDim2.fromScale(0,.12),UDim2.new(0,3,.76,0),
                gold,1,10).Name="SelectedLine"
            optionButtons[opt.id]=b
            b.MouseButton1Click:Connect(function()
                state.appearance[tab]=opt.id
                if tab=="upper" or tab=="lower" then
                    state.appearance.set="none"
                end
                Appearance.apply(rig,state)
                highlight()
            end)
        end
        scroll.CanvasPosition=Vector2.zero
        highlight()
    end

    buttons.refresh=function()
        options()
    end
    options()

    button(root,"←  CLASSES",UDim2.fromScale(.051,.892),UDim2.fromScale(.18,.060),function()
        currentStep=2
        renderCreator()
    end,dark,true)
    local start=button(root,"CONFIRMAR  •  COMEÇAR A JORNADA  →",
        UDim2.fromScale(.66,.89),UDim2.fromScale(.294,.063),function()
            if waiting then return end
            waiting=true
            clear()
            local waitScreen=base()
            signature(waitScreen,"A SUA JORNADA COMEÇA")
            register(Visuals.flux(waitScreen,{
                position=UDim2.fromScale(.05,.2),size=UDim2.fromScale(.9,.65),
                strands=6,segments=13,speed=.36,
            }))
            label(waitScreen,"As estrelas reconhecem seu nome.",35,ivory,Enum.Font.Antique,
                UDim2.fromScale(.86,.20),{
                    Position=UDim2.fromScale(.07,.40),
                    TextXAlignment=Enum.TextXAlignment.Center,
                })
            label(waitScreen,"Preparando a sua chegada ao mundo...",13,gold,Enum.Font.Gotham,
                UDim2.fromScale(.80,.09),{
                    Position=UDim2.fromScale(.10,.58),TextXAlignment=Enum.TextXAlignment.Center,
                })
            startEvent:FireServer("campaign",state)
        end,Color3.fromRGB(112,87,56),true)
    start.TextSize=13
    footer(root,"CAPÍTULO III  /  IDENTIDADE")
end

renderCreator=function()
    clear()
    scenicCamera()
    local root=base()
    signature(root,"UM NOVO DESTINO  •  CRIAÇÃO DO PERSONAGEM")
    -- Elementos de movimento discretos no fundo, preservando a legibilidade.
    register(Visuals.flux(root,{
        position=UDim2.fromScale(.81,.13),size=UDim2.fromScale(.19,.82),
        strands=3,segments=13,speed=.17,
        colors={cyan,gold,Color3.fromRGB(171,189,204)},
    }))
    if currentStep==1 or currentStep==2 then
        carouselStep(root)
    else
        appearanceStep(root)
    end
    fadingEntrance(root)
end

-- Menu de título cinematográfico renovado; funções do criador permanecem independentes.
renderMenu = function()
    clear()
    waiting = false
    camera.CameraType = Enum.CameraType.Scriptable
    camera.FieldOfView = 56
    camera.CFrame = CFrame.lookAt(Vector3.new(29,17,63),Vector3.new(0,6,-83))
    register(MenuReforged.show(gui,{
        appearance = Appearance,
        selection = state,
        campaign = function()
            state.mode = "campaign"
            currentStep = 1
            renderCreator()
        end,
        sandbox = function()
            state.mode = "sandbox"
            waiting = true
            clear()
            local waitScreen = base()
            signature(waitScreen,"PREPARANDO O MUNDO")
            label(waitScreen,"Alnair desperta ao seu redor...",36,ivory,Enum.Font.Antique,
                UDim2.fromScale(.86,.20),{
                    Position=UDim2.fromScale(.07,.40),
                    TextXAlignment=Enum.TextXAlignment.Center,
                })
            startEvent:FireServer("sandbox",{})
        end,
    }))
end
-- O restante do script é o prólogo cinematográfico original, sem mudanças.

local function enterGame(mode)
    clear()
    camera.CameraType=Enum.CameraType.Custom
    camera.FieldOfView=70
    local character=player.Character or player.CharacterAdded:Wait()
    local humanoid=character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid",15)
    if humanoid then camera.CameraSubject=humanoid end

    local hud=obj("Frame",{
        BackgroundColor3=bg,BackgroundTransparency=.25,BorderSizePixel=0,
        Position=UDim2.fromScale(.025,.04),Size=UDim2.fromScale(.26,.115),
    },gui)
    round(hud,9)
    stroke(hud,gold,.71)
    label(hud,"✦  ALNAIR",17,gold,Enum.Font.Antique,
        UDim2.fromScale(.91,.47),{Position=UDim2.fromScale(.05,.05)})
    label(hud,mode=="campaign" and "PRÓLOGO · TERRAS ESQUECIDAS" or "SANDBOX · EXPLORAÇÃO LIVRE",
        10,muted,Enum.Font.GothamBold,
        UDim2.fromScale(.91,.34),{Position=UDim2.fromScale(.05,.53)})
    task.delay(10,function()
        if hud.Parent then
            TweenService:Create(hud,TweenInfo.new(1),{BackgroundTransparency=.72}):Play()
        end
    end)
end

local function playCutscene()
    cinematicSkip=false
    clear()
    camera.CameraType=Enum.CameraType.Scriptable
    camera.FieldOfView=60

    local cut=obj("Frame",{
        BackgroundColor3=bg,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),
    },gui)
    local upper=obj("Frame",{
        BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,
        Size=UDim2.fromScale(1,.11),
    },cut)
    local lower=obj("Frame",{
        BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,
        Position=UDim2.fromScale(0,.89),Size=UDim2.fromScale(1,.11),
    },cut)
    local caption=label(cut,"",21,ivory,Enum.Font.Antique,
        UDim2.fromScale(.8,.14),{Position=UDim2.fromScale(.1,.74),TextXAlignment=Enum.TextXAlignment.Center,TextTransparency=1})
    label(cut,"✦  ALNAIR",17,gold,Enum.Font.Antique,
        UDim2.fromScale(.3,.06),{Position=UDim2.fromScale(.04,.028)})
    button(cut,"PULAR INTRO  →",UDim2.fromScale(.80,.03),UDim2.fromScale(.165,.064),function()
        cinematicSkip=true
        if currentCameraTween then currentCameraTween:Cancel() end
    end,panel,true)

    local shots={
        {
            start=CFrame.lookAt(Vector3.new(-97,62,-22),Vector3.new(0,14,-126)),
            finish=CFrame.lookAt(Vector3.new(-58,38,-36),Vector3.new(0,12,-115)),
            text="Quando as estrelas se calaram, os reinos perderam seu caminho...",
            duration=3.2,
        },
        {
            start=CFrame.lookAt(Vector3.new(58,25,-90),Vector3.new(0,5,-12)),
            finish=CFrame.lookAt(Vector3.new(36,21,-56),Vector3.new(0,5,-8)),
            text="Mas uma antiga chama ainda resiste entre as ruínas.",
            duration=3.0,
        },
        {
            start=CFrame.lookAt(Vector3.new(35,18,50),Vector3.new(0,2,0)),
            finish=CFrame.lookAt(Vector3.new(19,12,26),Vector3.new(0,3,-8)),
            text="Agora, o primeiro passo pertence a você.",
            duration=3.1,
        },
    }
    local function fadeText(textValue)
        caption.TextTransparency=1
        caption.Text=textValue
        TweenService:Create(caption,TweenInfo.new(.55),{TextTransparency=0}):Play()
    end
    for _,shot in ipairs(shots) do
        if cinematicSkip then break end
        camera.CFrame=shot.start
        fadeText(shot.text)
        local t=TweenService:Create(camera,TweenInfo.new(shot.duration,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
            CFrame=shot.finish,
            FieldOfView=54,
        })
        currentCameraTween=t
        t:Play()
        local elapsed=0
        while elapsed<shot.duration and not cinematicSkip do
            elapsed+=task.wait(.05)
        end
        t:Cancel()
        currentCameraTween=nil
    end
    if cinematicSkip then
        -- A câmera volta para o personagem mesmo após o skip.
    end
    cut:Destroy()
    enterGame("campaign")
end

-- O servidor confirma o modo permitido e só então libera câmera e avatar.
startEvent.OnClientEvent:Connect(function(ok, response)
    if not waiting then return end
    if not ok then
        waiting=false
        warn("[ALNAIR] "..tostring(response))
        if state.mode=="sandbox" then
            renderMenu()
        else
            renderCreator()
        end
        return
    end
    waiting=false
    if response=="campaign" then
        task.spawn(playCutscene)
    else
        enterGame("sandbox")
    end
end)

-- Interface inicial. Evita carregar um avatar antes da escolha.
renderMenu()
