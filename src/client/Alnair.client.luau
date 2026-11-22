--!strict
-- Interface principal, criação de personagem e prólogo cinematográfico.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("AlnairShared")
local Catalog = require(shared:WaitForChild("Catalog"))
local Appearance = require(shared:WaitForChild("Appearance"))
local startEvent = ReplicatedStorage:WaitForChild("AlnairRemotes"):WaitForChild("StartJourney")

while not workspace.CurrentCamera do task.wait() end
local camera = workspace.CurrentCamera
local bg = Color3.fromRGB(9, 14, 24)
local panel = Color3.fromRGB(18, 25, 36)
local panelBright = Color3.fromRGB(30, 40, 54)
local ivory = Color3.fromRGB(237, 230, 209)
local muted = Color3.fromRGB(155, 164, 175)
local gold = Color3.fromRGB(232, 182, 109)
local blue = Color3.fromRGB(123, 185, 218)

local gui = Instance.new("ScreenGui")
gui.Name = "AlnairUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 20
gui.Parent = playerGui

local state = {
    mode = "campaign",
    race = "human",
    class = "warrior",
    appearance = {},
}
for k,v in pairs(Catalog.DefaultAppearance) do state.appearance[k] = v end

local currentStep = 1
local tab = "face"
local waiting = false
local cinematicSkip = false
local currentCameraTween = nil
local renderCreator -- função definida abaixo, depois dos componentes

local function obj(class, properties, parent)
    local instance = Instance.new(class)
    for key, value in pairs(properties or {}) do
        instance[key] = value
    end
    instance.Parent = parent
    return instance
end

local function round(target, radius)
    obj("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, target)
    return target
end

local function stroke(target, color, transparency, thick)
    obj("UIStroke", {
        Color = color or gold,
        Thickness = thick or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, target)
    return target
end

local function label(parent, text, size, color, font, rect, extra)
    local props = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = text,
        TextSize = size,
        TextColor3 = color or ivory,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        Size = rect or UDim2.fromScale(1,1),
    }
    for k,v in pairs(extra or {}) do props[k] = v end
    return obj("TextLabel", props, parent)
end

local function button(parent, text, position, size, action, color, outlined, disabled)
    local baseColor = color or panelBright
    local b = obj("TextButton", {
        BackgroundColor3 = baseColor,
        BackgroundTransparency = outlined and .78 or .05,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = disabled and Color3.fromRGB(103,110,122) or ivory,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
        AutoButtonColor = false,
        Active = not disabled,
        Selectable = not disabled,
        Position = position,
        Size = size,
    }, parent)
    round(b, 8)
    if outlined then stroke(b, disabled and Color3.fromRGB(64,74,90) or gold, disabled and .45 or .28) end
    if not disabled then
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(.15), { BackgroundTransparency = 0, BackgroundColor3 = panelBright }):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(.15), {
                BackgroundTransparency = outlined and .78 or .05,
                BackgroundColor3 = baseColor,
            }):Play()
        end)
        b.MouseButton1Click:Connect(function()
            if action then action() end
        end)
    end
    return b
end

local function clear()
    for _, child in ipairs(gui:GetChildren()) do child:Destroy() end
end

local function scenicCamera()
    camera.CameraType = Enum.CameraType.Scriptable
    camera.FieldOfView = 58
    camera.CFrame = CFrame.lookAt(Vector3.new(-52,38,70), Vector3.new(0,6,-26))
end

local function backdrop()
    local base = obj("Frame", {
        Name = "Backdrop",
        BackgroundColor3 = bg,
        BackgroundTransparency = .15,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1,1),
    }, gui)
    obj("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(5,11,19)),
            ColorSequenceKeypoint.new(.45, Color3.fromRGB(14,21,34)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(11,22,33)),
        }),
        Rotation = 22,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, .02),
            NumberSequenceKeypoint.new(.5, .12),
            NumberSequenceKeypoint.new(1, .34),
        }),
    }, base)
    local top = obj("Frame", {
        BackgroundColor3 = gold,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(.05,.07),
        Size = UDim2.new(.9,0,0,2),
    }, base)
    top.BackgroundTransparency = .60
    return base
end

local function signature(parent)
    label(parent, "✦  A L N A I R", 22, gold, Enum.Font.Antique,
        UDim2.new(.4,0,0,42), { Position = UDim2.fromScale(.055,.015) })
    label(parent, "UM MUNDO A DESPERTAR", 10, muted, Enum.Font.GothamBold,
        UDim2.new(.4,0,0,24), { Position = UDim2.fromScale(.73,.032), TextXAlignment = Enum.TextXAlignment.Right })
end

local function renderMenu()
    waiting = false
    clear()
    scenicCamera()
    local base = backdrop()
    signature(base)

    label(base, "A estrela esquecida", 17, gold, Enum.Font.GothamSemibold,
        UDim2.new(.56,0,0,32), { Position = UDim2.fromScale(.08,.17) })
    label(base, "Toda lenda tem\num primeiro passo.", 53, ivory, Enum.Font.Antique,
        UDim2.new(.61,0,.25,0), { Position = UDim2.fromScale(.08,.215), TextYAlignment = Enum.TextYAlignment.Top })
    label(base, "Explore as terras antigas, escolha sua origem e escreva sua própria história.",
        16, muted, Enum.Font.Gotham,
        UDim2.new(.54,0,.12,0), { Position = UDim2.fromScale(.082,.47), TextYAlignment = Enum.TextYAlignment.Top })

    local menu = obj("Frame", {
        BackgroundColor3 = panel, BackgroundTransparency = .15, BorderSizePixel = 0,
        Position = UDim2.fromScale(.08,.615), Size = UDim2.fromScale(.49,.30),
    }, base)
    round(menu,12)
    stroke(menu, gold, .82)
    obj("UIListLayout", {
        Padding = UDim.new(0,6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, menu)

    local items = {
        { title = "CAMPANHA", sub = "Começar uma nova jornada", key = "campaign", enabled = true },
        { title = "SANDBOX", sub = "Exploração livre do mundo", key = "sandbox", enabled = true },
        { title = "CO-OP", sub = "EM BREVE", key = "coop", enabled = false },
        { title = "PvP", sub = "EM BREVE", key = "pvp", enabled = false },
    }
    for i,item in ipairs(items) do
        local b = obj("TextButton", {
            LayoutOrder = i,
            BackgroundColor3 = i == 1 and Color3.fromRGB(57,62,64) or Color3.fromRGB(23,31,42),
            BackgroundTransparency = i == 1 and .12 or .20,
            BorderSizePixel = 0,
            Text = "",
            Active = item.enabled,
            Selectable = item.enabled,
            AutoButtonColor = false,
            Size = UDim2.new(.95,0,.225,0),
        },menu)
        round(b,7)
        label(b,item.title,16,item.enabled and ivory or muted,Enum.Font.GothamBold,
            UDim2.new(.62,0,.9,0), { Position = UDim2.fromScale(.04,.05) })
        label(b,item.sub,11,item.enabled and gold or Color3.fromRGB(106,117,127),
            Enum.Font.Gotham,UDim2.new(.36,0,.9,0), {
                Position=UDim2.fromScale(.61,.05),
                TextXAlignment=Enum.TextXAlignment.Right,
            })
        if item.enabled then
            b.MouseEnter:Connect(function()
                TweenService:Create(b,TweenInfo.new(.16),{BackgroundColor3=panelBright,BackgroundTransparency=0}):Play()
            end)
            b.MouseLeave:Connect(function()
                TweenService:Create(b,TweenInfo.new(.16),{BackgroundColor3=i==1 and Color3.fromRGB(57,62,64) or Color3.fromRGB(23,31,42),BackgroundTransparency=.17}):Play()
            end)
            b.MouseButton1Click:Connect(function()
                state.mode = item.key
                if item.key == "sandbox" then
                    waiting = true
                    -- O sandbox tem um início rápido; a campanha possui criação completa.
                    clear()
                    local waitingBg = backdrop()
                    signature(waitingBg)
                    label(waitingBg,"Preparando o mundo livre...",30,ivory,Enum.Font.Antique,
                        UDim2.fromScale(.8,.15),{Position=UDim2.fromScale(.1,.41),TextXAlignment=Enum.TextXAlignment.Center})
                    startEvent:FireServer("sandbox",{})
                else
                    currentStep = 1
                    renderCreator()
                end
            end)
        end
    end

    label(base,"ALNAIR · PRÓLOGO / VERSÃO 0.1.0",10,muted,Enum.Font.GothamBold,
        UDim2.new(.55,0,0,26),{Position=UDim2.fromScale(.08,.95)})
    label(base,"Um mundo à espera da sua história",12,blue,Enum.Font.Gotham,
        UDim2.fromScale(.32,.05),{
            Position=UDim2.fromScale(.64,.88),
            TextXAlignment=Enum.TextXAlignment.Right,
        })
end

local function preview(parent)
    local container = obj("Frame", {
        BackgroundColor3 = Color3.fromRGB(21,30,43),
        BackgroundTransparency = .04,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(.658,.172),
        Size = UDim2.fromScale(.302,.708),
    },parent)
    round(container,12)
    stroke(container, gold, .74)
    label(container,"SEU PERSONAGEM",11,gold,Enum.Font.GothamBold,
        UDim2.fromScale(.86,.05),{Position=UDim2.fromScale(.07,.032)})
    local vp = obj("ViewportFrame",{
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(.06,.1),
        Size = UDim2.fromScale(.88,.68),
        Ambient = Color3.fromRGB(175,178,197),
        LightColor = Color3.fromRGB(255,227,185),
        LightDirection = Vector3.new(-.6,-1,-.8),
    },container)
    local vm = obj("WorldModel",{},vp)
    local rig = Appearance.createPreview(vm)
    Appearance.apply(rig,state)
    local cam = obj("Camera",{FieldOfView=33},vp)
    cam.CFrame=CFrame.lookAt(Vector3.new(7,5.1,-13),Vector3.new(0,2.5,0))
    vp.CurrentCamera=cam

    local className = Catalog.Classes[state.class].name
    local raceName = Catalog.Races[state.race].name
    label(container, raceName.."  /  "..className,18,ivory,Enum.Font.GothamBold,
        UDim2.fromScale(.88,.07), { Position=UDim2.fromScale(.065,.79),TextXAlignment=Enum.TextXAlignment.Center })
    label(container, "Pré-visualização do avatar clássico",11,muted,Enum.Font.Gotham,
        UDim2.fromScale(.88,.05), { Position=UDim2.fromScale(.065,.86),TextXAlignment=Enum.TextXAlignment.Center })
    label(container, "Mudanças aplicadas ao iniciar",10,gold,Enum.Font.Gotham,
        UDim2.fromScale(.88,.05), { Position=UDim2.fromScale(.065,.91),TextXAlignment=Enum.TextXAlignment.Center })
end

local function optionsGrid(parent, ids, dictionary, selected, onChoose, title)
    label(parent,title,19,ivory,Enum.Font.Antique,
        UDim2.new(.90,0,0,32),{Position=UDim2.fromScale(.035,.02)})
    local scroller = obj("ScrollingFrame", {
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Position=UDim2.fromScale(.03,.11),
        Size=UDim2.fromScale(.94,.80),
        CanvasSize=UDim2.fromScale(0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=4,
        ScrollBarImageColor3=gold,
        ScrollingDirection=Enum.ScrollingDirection.Y,
    },parent)
    obj("UIPadding", {
        PaddingTop = UDim.new(0,6),
        PaddingLeft = UDim.new(0,4),
        PaddingRight = UDim.new(0,4),
        PaddingBottom = UDim.new(0,8),
    },scroller)
    obj("UIGridLayout", {
        CellSize = UDim2.new(.475,0,0,116),
        CellPadding = UDim2.new(.035,0,0,12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    },scroller)

    for i,id in ipairs(ids) do
        local item = dictionary[id]
        local chosen = selected == id
        local b = obj("TextButton", {
            LayoutOrder=i,Text="",AutoButtonColor=false,
            BackgroundColor3=chosen and Color3.fromRGB(63,67,69) or panel,
            BackgroundTransparency=chosen and .06 or .18,
            Size=UDim2.fromScale(1,1),
            BorderSizePixel=0,
        },scroller)
        round(b,9)
        stroke(b,chosen and gold or Color3.fromRGB(71,83,98),chosen and .03 or .65,chosen and 2 or 1)
        label(b,string.format("%02d",i),11,chosen and gold or muted,Enum.Font.GothamBold,
            UDim2.new(.19,0,0,27),{Position=UDim2.fromScale(.06,.08)})
        label(b,item.name,19,ivory,Enum.Font.GothamBold,
            UDim2.new(.87,0,0,29),{Position=UDim2.fromScale(.07,.34)})
        local info = item.description or item.title or item.weapon or "Selecione esta opção"
        label(b,info,11,muted,Enum.Font.Gotham,
            UDim2.new(.89,0,0,32),{Position=UDim2.fromScale(.07,.64),TextYAlignment=Enum.TextYAlignment.Top})
        b.MouseButton1Click:Connect(function() onChoose(id) end)
    end
end

local function appearanceChooser(parent)
    label(parent,"Seu visual. Sua história.",23,ivory,Enum.Font.Antique,
        UDim2.new(.9,0,0,36),{Position=UDim2.fromScale(.03,.01)})
    label(parent,"Customize cada detalhe antes de iniciar a jornada.",12,muted,Enum.Font.Gotham,
        UDim2.new(.9,0,0,28),{Position=UDim2.fromScale(.03,.07)})

    local tabs = obj("ScrollingFrame", {
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromScale(.026,.15),Size=UDim2.fromScale(.95,.12),
        CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.X,
        ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=3,
        ScrollBarImageColor3=gold,
    },parent)
    obj("UIListLayout", {
        FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Left,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,6),
    },tabs)
    for i,key in ipairs(Catalog.PresetOrder) do
        local group=Catalog.Presets[key]
        local active=(tab==key)
        local b=button(tabs,group.name,UDim2.fromOffset(0,0),
            UDim2.fromOffset((key=="upper" or key=="lower") and 132 or 116,43),
            function() tab=key;renderCreator() end,
            active and Color3.fromRGB(65,73,80) or panel,active,false)
        b.LayoutOrder=i
        if active then stroke(b,gold,.1,2) end
    end

    local group=Catalog.Presets[tab]
    label(parent,group.name:upper(),12,gold,Enum.Font.GothamBold,
        UDim2.fromScale(.9,.055),{Position=UDim2.fromScale(.035,.295)})
    local scroller=obj("ScrollingFrame", {
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromScale(.03,.355),Size=UDim2.fromScale(.95,.53),
        CanvasSize=UDim2.fromScale(0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ScrollBarThickness=4,ScrollBarImageColor3=gold,
    },parent)
    obj("UIGridLayout", {
        CellSize=UDim2.new(.475,0,0,73),
        CellPadding=UDim2.new(.035,0,0,10),
        SortOrder=Enum.SortOrder.LayoutOrder,
    },scroller)
    for i,opt in ipairs(group.options) do
        local chosen=state.appearance[tab]==opt.id
        local b=obj("TextButton",{
            LayoutOrder=i,
            Text=opt.name,
            Font=Enum.Font.GothamBold,
            TextSize=14,
            TextColor3=chosen and ivory or muted,
            TextWrapped=true,
            AutoButtonColor=false,
            BackgroundColor3=chosen and Color3.fromRGB(65,70,76) or panel,
            BackgroundTransparency=chosen and 0 or .15,
            BorderSizePixel=0,
            Size=UDim2.fromScale(1,1),
        },scroller)
        round(b,8)
        stroke(b,chosen and gold or Color3.fromRGB(75,83,94),chosen and .05 or .7,chosen and 2 or 1)
        b.MouseButton1Click:Connect(function()
            state.appearance[tab]=opt.id
            if tab=="upper" or tab=="lower" then state.appearance.set="none" end
            renderCreator()
        end)
    end
end

renderCreator=function()
    clear()
    scenicCamera()
    local base=backdrop()
    signature(base)

    local stepNames={"RAÇA","CLASSE","APARÊNCIA"}
    label(base,"CRIAÇÃO DE PERSONAGEM",11,gold,Enum.Font.GothamBold,
        UDim2.fromScale(.55,.035),{Position=UDim2.fromScale(.052,.105)})
    label(base,"Etapa "..currentStep.." de 3  —  "..stepNames[currentStep],
        24,ivory,Enum.Font.Antique,UDim2.fromScale(.55,.055),{Position=UDim2.fromScale(.052,.13)})

    for i=1,3 do
        local active=i<=currentStep
        obj("Frame", {
            BackgroundColor3=active and gold or Color3.fromRGB(70,80,88),
            BackgroundTransparency=active and 0 or .43,
            BorderSizePixel=0,
            Position=UDim2.new(.053+(i-1)*.196,0,.197,0),
            Size=UDim2.new(.181,0,0,3),
        },base)
    end

    local chooser=obj("Frame",{
        BackgroundColor3=panel,BackgroundTransparency=.10,BorderSizePixel=0,
        Position=UDim2.fromScale(.051,.236),Size=UDim2.fromScale(.583,.65),
    },base)
    round(chooser,11)
    stroke(chooser,gold,.81)

    if currentStep==1 then
        optionsGrid(chooser,Catalog.RaceOrder,Catalog.Races,state.race,function(id)
            state.race=id
            renderCreator()
        end,"Escolha sua origem")
    elseif currentStep==2 then
        optionsGrid(chooser,Catalog.ClassOrder,Catalog.Classes,state.class,function(id)
            state.class=id
            renderCreator()
        end,"Escolha seu caminho")
    else
        appearanceChooser(chooser)
    end

    preview(base)

    button(base,"← VOLTAR",UDim2.fromScale(.052,.905),UDim2.fromScale(.19,.062),function()
        if currentStep==1 then renderMenu() else currentStep-=1;renderCreator() end
    end,panel,true)

    local nextText = currentStep==3 and "COMEÇAR A JORNADA  ✦" or "CONTINUAR  →"
    button(base,nextText,UDim2.fromScale(.389,.905),UDim2.fromScale(.245,.062),function()
        if currentStep<3 then currentStep+=1;renderCreator();return end
        if waiting then return end
        waiting=true
        clear()
        local fade=backdrop()
        signature(fade)
        label(fade,"A estrela está despertando...",30,ivory,Enum.Font.Antique,
            UDim2.fromScale(.8,.16),{Position=UDim2.fromScale(.1,.4),TextXAlignment=Enum.TextXAlignment.Center})
        label(fade,"Preparando sua chegada às terras de Alnair",13,muted,Enum.Font.Gotham,
            UDim2.fromScale(.8,.09),{Position=UDim2.fromScale(.1,.57),TextXAlignment=Enum.TextXAlignment.Center})
        startEvent:FireServer("campaign",state)
    end,gold,false)
end

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
