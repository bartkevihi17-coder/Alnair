--!strict
-- ALNAIR REBORN: menu e criador inteiramente novos.
-- Inspiracao: estruturas de aventura artesanal dos RPGs de fantasia.
-- Nenhum asset, logotipo ou interface do Vesteria e copiado.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local shared=ReplicatedStorage:WaitForChild("AlnairShared")
local Catalog=require(shared:WaitForChild("Catalog"))
local Appearance=require(shared:WaitForChild("Appearance"))
local Theme=require(shared:WaitForChild("FantasyTheme"))
local CameraDirector=require(script.Parent:WaitForChild("CameraDirector"))
local MenuCinematic=require(script.Parent:WaitForChild("MenuCinematic"))
local startEvent=ReplicatedStorage:WaitForChild("AlnairRemotes"):WaitForChild("StartJourney")

while not workspace.CurrentCamera do task.wait()end
local camera=workspace.CurrentCamera
local prior=playerGui:FindFirstChild("AlnairUI")
if prior then prior:Destroy()end
local gui=Instance.new("ScreenGui")
gui.Name="AlnairUI"
gui.IgnoreGuiInset=true
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.DisplayOrder=25
gui.Parent=playerGui

local selected={race="human",class="warrior",appearance={}}
for key,value in pairs(Catalog.DefaultAppearance)do selected.appearance[key]=value end
local mode="campaign"
local step="home"
local waiting=false
local stopCamera=CameraDirector.menu(camera)
local stopPreview=nil
local muted=Theme.muted
local cream=Theme.cream
local gold=Theme.gold

local function make(class,parent,properties)
    local node=Instance.new(class)
    for k,v in pairs(properties or {}) do node[k]=v end
    node.Parent=parent
    return node
end
local function text(parent,value,size,position,dimensions,color,font,alignment)
    local item=make("TextLabel",parent,{
        Text=value,TextColor3=color or cream,TextSize=size or 16,
        Font=font or Theme.fontText,BackgroundTransparency=1,
        Position=position or UDim2.fromScale(0,0),Size=dimensions or UDim2.fromScale(1,1),
        TextWrapped=true,TextXAlignment=alignment or Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
    })
    return item
end
-- A interface nao tem placas, bordas, ornamentos ou imagem de fundo.
-- CameraDirector mostra o cenario REAL gerado no Workspace.
-- Um unico gradiente preto a esquerda protege a leitura sem esconder a paisagem.
local function button(parent,title,position,dimensions,callback,accent)
    local btn=make("TextButton",parent,{
        Text=title,TextSize=14,
        Font=Enum.Font.BuilderSansBold,
        TextColor3=accent and Color3.fromRGB(250,245,234) or Color3.fromRGB(190,194,186),
        TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,
        Position=position,Size=dimensions,
    })
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(.14),{TextColor3=Color3.fromRGB(255,255,255)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(.14),{
            TextColor3=accent and Color3.fromRGB(250,245,234) or Color3.fromRGB(190,194,186)
        }):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local fade=make("Frame",gui,{
    Name="WorldLeftFade",
    BackgroundColor3=Color3.fromRGB(0,0,0),
    BackgroundTransparency=0,BorderSizePixel=0,
    Size=UDim2.fromScale(1,1),
})
make("UIGradient",fade,{
    Rotation=0,
    Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.10),
        NumberSequenceKeypoint.new(.16,.19),
        NumberSequenceKeypoint.new(.32,.51),
        NumberSequenceKeypoint.new(.52,.86),
        NumberSequenceKeypoint.new(.72,1),
        NumberSequenceKeypoint.new(1,1),
    })
})
local left=make("CanvasGroup",gui,{
    Name="MainMenuTextOnly",BackgroundTransparency=1,BorderSizePixel=0,
    Position=UDim2.new(.047,0,0,0),
    Size=UDim2.new(.53,0,1,0),
})
make("UISizeConstraint",left,{MinSize=Vector2.new(225,0),MaxSize=Vector2.new(470,10000)})

local logo=text(left,"ALNAIR",53,
    UDim2.new(0,0,.18,0),UDim2.new(1,0,0,76),
    Color3.fromRGB(255,255,255),Enum.Font.BuilderSansBold)
logo.TextWrapped=false
local subtitle=text(left,"RPG DE FANTASIA",12,
    UDim2.new(0,2,.18,81),UDim2.new(1,0,0,25),
    Color3.fromRGB(180,187,180),Enum.Font.BuilderSansMedium)
subtitle.TextWrapped=false

local title=text(left,"",24,UDim2.new(0,0,.30,0),
    UDim2.new(1,0,0,40),Color3.fromRGB(245,245,243),
    Enum.Font.BuilderSansBold)
title.TextWrapped=false
local description=text(left,"",13,UDim2.new(0,0,.30,39),
    UDim2.new(1,0,0,55),Color3.fromRGB(185,191,186),
    Enum.Font.BuilderSans)
description.TextYAlignment=Enum.TextYAlignment.Top
local selectionArea=make("Frame",left,{
    Name="SelectionArea",Position=UDim2.new(0,0,.36,0),
    Size=UDim2.new(1,0,.45,0),BackgroundTransparency=1,
})
local bottom=make("Frame",left,{
    Position=UDim2.new(0,0,.92,0),Size=UDim2.new(1,0,0,40),
    BackgroundTransparency=1,
})
local cinematic=MenuCinematic.new(camera,gui,left)
local previewFrame=nil
local previewConnections={}
local previewYaw=0
local previewTicket=0
local function clearPreview()
    previewTicket+=1
    for _,connection in ipairs(previewConnections) do
        connection:Disconnect()
    end
    table.clear(previewConnections)
    if previewFrame then
        previewFrame:Destroy()
        previewFrame=nil
    end
end
local function updatePreview()
    clearPreview()
    if step=="home" or step=="loading" then return end

    -- O avatar é criado pelo motor oficial do Roblox. Pode demorar um
    -- pouco para baixar Shirt/Pants, HairAccessory e Face, por isso
    -- o carregamento é assíncrono e antigas escolhas são canceladas.
    local thisTicket=previewTicket
    local selectedSnapshot=Catalog.clean(selected)
    previewFrame=make("Frame",gui,{
        Name="CharacterStage",Size=UDim2.new(.36,0,.70,0),
        Position=UDim2.new(.60,0,.20,0),
        BackgroundTransparency=1,BorderSizePixel=0,
    })
    local viewport=make("ViewportFrame",previewFrame,{
        Name="CharacterPreview",Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        Ambient=Color3.fromRGB(141,163,154),
        LightColor=Color3.fromRGB(255,234,192),
        LightDirection=Vector3.new(-.65,-1,-.43),
        Active=true,
    })
    local world=make("WorldModel",viewport,{})
    local cam=make("Camera",viewport,{FieldOfView=42})
    viewport.CurrentCamera=cam
    local raceName=Catalog.Races[selectedSnapshot.race].name
    local className=Catalog.Classes[selectedSnapshot.class].name
    local caption=text(previewFrame,raceName.."  •  "..className,21,
        UDim2.fromScale(.04,.87),UDim2.fromScale(.92,.09),
        cream,Theme.fontTitle,Enum.TextXAlignment.Center)
    caption.TextStrokeColor3=Color3.fromRGB(13,27,25)
    caption.TextStrokeTransparency=.38
    text(previewFrame,"ARRASTE COM BOTÃO ESQUERDO PARA GIRAR",11,
        UDim2.fromScale(.03,.955),UDim2.fromScale(.94,.04),
        Color3.fromRGB(186,190,179),Enum.Font.BuilderSans,
        Enum.TextXAlignment.Center)
    local loading=text(previewFrame,"CARREGANDO AVATAR DO ROBLOX…",12,
        UDim2.fromScale(.04,.46),UDim2.fromScale(.92,.10),
        Color3.fromRGB(209,213,196),Enum.Font.BuilderSansMedium,
        Enum.TextXAlignment.Center)

    task.spawn(function()
        local ok,model=pcall(function()
            return Appearance.createPreview(world,selectedSnapshot)
        end)
        if not ok then
            if thisTicket==previewTicket and loading.Parent then
                loading.Text="AVATAR INDISPONÍVEL — TENTE OUTRA OPÇÃO"
                warn("[ALNAIR] O Roblox não carregou o avatar:",model)
            end
            return
        end
        if thisTicket~=previewTicket or not previewFrame
            or not previewFrame.Parent or not world.Parent then
            model:Destroy()
            return
        end
        if loading.Parent then loading:Destroy() end
        local function applyView()
            local pos=Vector3.new(math.sin(previewYaw)*8.6,
                3.85,-math.cos(previewYaw)*8.6)
            cam.CFrame=CFrame.lookAt(pos,Vector3.new(0,2.7,0))
        end
        -- No automatic orbit: the character stays still and faces forward.
        -- A drag rotates the VIEWPORT camera only, and stops exactly
        -- where the mouse was released. Preserve the angle across choices.
        applyView()
        local holding=false
        local touch=nil
        local lastX=0
        -- Studio embeds the game viewport in an editor panel. Mouse input
        -- may be captured by that panel before ViewportFrame.InputBegan,
        -- so listen globally but activate ONLY inside the 3D preview.
        table.insert(previewConnections,UserInputService.InputBegan:Connect(function(input)
            if not viewport.Parent then return end
            if input.UserInputType~=Enum.UserInputType.MouseButton1
                and input.UserInputType~=Enum.UserInputType.Touch then return end
            local pos=input.Position
            local origin=viewport.AbsolutePosition
            local size=viewport.AbsoluteSize
            if pos.X<origin.X or pos.X>origin.X+size.X
                or pos.Y<origin.Y or pos.Y>origin.Y+size.Y then return end
            holding=true
            touch=input.UserInputType==Enum.UserInputType.Touch and input or nil
            lastX=pos.X
        end))
        table.insert(previewConnections,UserInputService.InputChanged:Connect(function(input)
            if not holding or not viewport.Parent then return end
            local dx=0
            if touch and input==touch then
                dx=input.Position.X-lastX
                lastX=input.Position.X
            elseif not touch and input.UserInputType==Enum.UserInputType.MouseMovement then
                -- Studio MCP and some OS drivers report InputChanged with
                -- Delta.X=0. Relative cursor position still changes and
                -- provides stable physical drag; never auto-rotate.
                dx=input.Position.X-lastX
                lastX=input.Position.X
            end
            if math.abs(dx)>.001 then
                previewYaw=(previewYaw-dx*.010)%(math.pi*2)
                applyView()
            end
        end))
        table.insert(previewConnections,UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 and not touch then
                holding=false
            elseif touch and input==touch then
                touch=nil
                holding=false
            end
        end))
    end)
end
local function clearArea()
    for _,child in ipairs(selectionArea:GetChildren())do child:Destroy()end
    for _,child in ipairs(bottom:GetChildren())do child:Destroy()end
end
local function page(nextStep,heading,detail)
    step=nextStep
    title.Text=heading
    description.Text=detail
    title.Visible=nextStep~="home"
    description.Visible=nextStep~="home"
    selectionArea.Position=UDim2.new(0,0,nextStep=="home" and .36 or .46,0)
    clearArea()
    updatePreview()
end
local function list()
    local scroll=make("ScrollingFrame",selectionArea,{
        Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        ScrollBarThickness=0,ScrollBarImageColor3=Color3.fromRGB(128,128,128),
        CanvasSize=UDim2.fromScale(0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,BorderSizePixel=0
    })
    make("UIListLayout",scroll,{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder})
    return scroll
end
local function choice(scroll,name,sub,selectedNow,onclick)
    local row=make("TextButton",scroll,{
        Name="MenuOption_"..name,
        Size=UDim2.new(1,-6,0,73),BackgroundTransparency=1,
        BorderSizePixel=0,AutoButtonColor=false,Text="",
    })
    local marker=make("Frame",row,{
        Name="HoverMarker",Size=UDim2.fromOffset(2,34),
        Position=UDim2.new(0,0,0,14),
        BackgroundColor3=Color3.fromRGB(247,245,239),
        BackgroundTransparency=selectedNow and 0 or 1,
        BorderSizePixel=0,
    })
    local heading=text(row,name,selectedNow and 26 or 25,
        UDim2.fromOffset(14,3),UDim2.new(1,-18,0,40),
        selectedNow and Color3.fromRGB(255,255,255) or Color3.fromRGB(227,230,226),
        Enum.Font.BuilderSansMedium)
    heading.TextWrapped=false
    local note=text(row,sub or "",12,
        UDim2.fromOffset(14,40),UDim2.new(1,-18,0,25),
        Color3.fromRGB(157,164,159),Enum.Font.BuilderSans)
    note.TextWrapped=false
    row.MouseEnter:Connect(function()
        TweenService:Create(heading,TweenInfo.new(.15),{
            TextColor3=Color3.fromRGB(255,255,255),
            Position=UDim2.fromOffset(20,3),
        }):Play()
        TweenService:Create(marker,TweenInfo.new(.15),{BackgroundTransparency=0}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(heading,TweenInfo.new(.15),{
            TextColor3=selectedNow and Color3.fromRGB(255,255,255) or Color3.fromRGB(227,230,226),
            Position=UDim2.fromOffset(14,3),
        }):Play()
        TweenService:Create(marker,TweenInfo.new(.15),{
            BackgroundTransparency=selectedNow and 0 or 1,
        }):Play()
    end)
    row.MouseButton1Click:Connect(onclick)
    return row
end
local showHome,showRace,showClass,showAppearance
local function transition(nextStep,callback)
    if waiting or cinematic.busy() then return end
    local fromStep=step
    if fromStep=="home" and nextStep=="race" then
        -- Stop the ambient camera drift before TweenService takes over.
        if stopCamera then stopCamera();stopCamera=nil end
    end
    cinematic.play(fromStep,nextStep,function()
        callback()
        if nextStep=="home" then
            if stopCamera then stopCamera() end
            stopCamera=CameraDirector.menu(camera)
        end
    end)
end
showHome=function()
    mode="campaign"
    page("home","","")
    title.Visible=false
    description.Visible=false
    local s=list()
    choice(s,"Campanha","Comece uma nova jornada.",false,function()
        mode="campaign";transition("race",showRace)
    end)
    choice(s,"Sandbox","Explore e enfrente desafios livres.",false,function()
        mode="sandbox";transition("race",showRace)
    end)
    choice(s,"Cooperativo","Em desenvolvimento.",false,function()end)
    choice(s,"Multijogador","Em desenvolvimento.",false,function()end)
end
showRace=function()
    page("race","Escolha sua raça","Cada povo tem sua própria história.")
    local s=list()
    for _,id in ipairs(Catalog.RaceOrder)do
        local race=Catalog.Races[id]
        choice(s,race.name,race.description,selected.race==id,function()
            if selected.race~=id then
                selected.race=id
                -- Race changes only skin/face/hair; clothes remain class gear.
                local personal=Catalog.defaultsForRace(id)
                selected.appearance.face=personal.face
                selected.appearance.hair=personal.hair
            end
            showRace()
        end)
    end
    button(bottom,"VOLTAR",UDim2.fromScale(0,.12),UDim2.fromScale(.42,.74),
        function()transition("home",showHome)end,false)
    button(bottom,"CONTINUAR",UDim2.fromScale(.48,.12),UDim2.fromScale(.52,.74),
        function()transition("class",showClass)end,true)
end
showClass=function()
    page("class","Escolha sua classe","Como você prefere lutar?")
    local s=list()
    for _,id in ipairs(Catalog.ClassOrder)do
        local cls=Catalog.Classes[id]
        choice(s,cls.name,cls.weapon.."  •  "..cls.description,selected.class==id,function()
            if selected.class~=id then
                selected.class=id
                local preset=Catalog.ClassOutfits[id]
                if preset then
                    selected.appearance.upper=preset.upper
                    selected.appearance.lower=preset.lower
                    selected.appearance.set="none"
                    selected.appearance.outer3d="class"
                    selected.appearance.hat="class"
                end
            end
            showClass()
        end)
    end
    button(bottom,"VOLTAR",UDim2.fromScale(0,.12),UDim2.fromScale(.42,.74),
        function()transition("race",showRace)end,false)
    button(bottom,"PERSONALIZAR",UDim2.fromScale(.48,.12),UDim2.fromScale(.52,.74),
        function()transition("appearance",showAppearance)end,true)
end
local function startGame()
    if waiting then return end
    waiting=true
    page("loading","Preparando sua jornada","Carregando personagem e mundo...")
    text(selectionArea,"QUE AS ESTRELAS O GUIEM",24,UDim2.fromScale(.06,.19),
        UDim2.fromScale(.86,.35),gold,Theme.fontTitle,Enum.TextXAlignment.Center)
    startEvent:FireServer(mode,selected)
end
showAppearance=function()
    page("appearance","Personalizar","Escolha sua aparência antes de começar.")
    local s=list()
    for _,category in ipairs(Catalog.PresetOrder)do
        local group=Catalog.Presets[category]
        if group then
            local header=make("Frame",s,{Size=UDim2.new(1,-9,0,28),BackgroundTransparency=1})
            text(header,string.upper(group.name),13,UDim2.fromScale(0,0),UDim2.fromScale(1,1),gold,Theme.fontBold)
            for _,option in ipairs(group.options)do
                local id=option.id
                if (category~="face" or Catalog.faceAllowed(selected.race,id))
                    and (category~="outer3d" or Catalog.armorAllowed(selected.class,id)) then
                choice(s,option.name,"",selected.appearance[category]==id,function()
                    selected.appearance[category]=id
                    if category=="upper" or category=="lower" then selected.appearance.set="none" end
                    showAppearance()
                end)
                end
            end
        end
    end
    button(bottom,"VOLTAR",UDim2.fromScale(0,.12),UDim2.fromScale(.42,.74),
        function()transition("class",showClass)end,false)
    button(bottom,"COMEÇAR",UDim2.fromScale(.48,.12),UDim2.fromScale(.52,.74),startGame,true)
end

local playing=false
local stopThirdPerson=nil
local function connectThirdPerson(character)
    local humanoid=character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid",15)
    if not humanoid then
        warn("[ALNAIR] Personagem articulado sem Humanoid.")
        return false
    end
    if stopThirdPerson then
        stopThirdPerson()
        stopThirdPerson=nil
    end
    -- Camera limitada de terceira pessoa permanece apos respawn.
    stopThirdPerson=CameraDirector.explore(camera,player,humanoid)
    return true
end
player.CharacterAdded:Connect(function(character)
    if playing then
        task.spawn(connectThirdPerson,character)
    end
end)
local function enterGame()
    if playing then return end
    playing=true
    if stopCamera then stopCamera();stopCamera=nil end
    clearPreview()
    local character=player.Character or player.CharacterAdded:Wait()
    if not connectThirdPerson(character) then
        playing=false
        showHome()
        return
    end
    -- Restore the house facade locally before entering the playable world.
    cinematic.finish()
    gui.Enabled=false
end
startEvent.OnClientEvent:Connect(function(ok,response)
    if not waiting then return end
    waiting=false
    if not ok then
        warn("[ALNAIR] Nao foi possivel iniciar:",tostring(response))
        showHome()
        description.Text="Falha ao iniciar: "..tostring(response)
        return
    end
    task.spawn(enterGame)
end)
-- Studio-only test entry: reuse the single open instance and invoke the
-- exact same StartJourney -> enterGame flow without mouse automation.
-- This object never exists in a published Roblox session.
if RunService:IsStudio() then
    local qa=Instance.new("BindableEvent")
    qa.Name="AlnairStudioQAStart"
    qa.Parent=gui
    qa.Event:Connect(function(selection)
        if playing or waiting then return end
        selected=Catalog.clean(selection)
        mode="campaign"
        startGame()
    end)
end

UserInputService.InputBegan:Connect(function(input,processed)
    if processed or playing or waiting then return end
    if input.KeyCode==Enum.KeyCode.Escape then
        if step=="appearance" then transition("class",showClass)
        elseif step=="class" then transition("race",showRace)
        else transition("home",showHome) end
    end
end)
showHome()
