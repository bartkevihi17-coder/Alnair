--!strict
-- HUD, mapa coberto, inventario, cartas de horda, talentos e painel DEV.
-- Sem UI padrao de mochila do Roblox.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) end)
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local Rules=require(ReplicatedStorage:WaitForChild("AlnairShared"):WaitForChild("GameRules"))
local network=ReplicatedStorage:WaitForChild("AlnairGame",35)
if not network then
    warn("[ALNAIR] Sistemas de jogo indisponiveis.")
    return
end
local action=network:WaitForChild("Action")
local state=network:WaitForChild("State")
local query=network:WaitForChild("Query")
local C={
    bg=Color3.fromRGB(12,17,27),panel=Color3.fromRGB(26,33,45),panel2=Color3.fromRGB(34,43,56),
    gold=Color3.fromRGB(226,185,112),white=Color3.fromRGB(239,233,220),
    mute=Color3.fromRGB(166,173,184),blue=Color3.fromRGB(112,188,219),
    green=Color3.fromRGB(117,202,148),red=Color3.fromRGB(207,94,97)
}
local profile=nil
local modal=nil
local modalKind=nil
local toastSerial=0
local dismissedDraft=nil
local cardsSignature=nil
local menuOpen=false
local gameplay=false

local function obj(class,props,parent)
    local v=Instance.new(class)
    for key,value in pairs(props or {}) do v[key]=value end
    if parent then v.Parent=parent end
    return v
end
local function curve(parent,r)
    obj("UICorner",{CornerRadius=UDim.new(0,r or 8)},parent)
    return parent
end
local function outline(parent,color,transparency,thickness)
    obj("UIStroke",{Color=color or C.gold,Transparency=transparency or .55,Thickness=thickness or 1},parent)
    return parent
end
local function label(parent,text,size,pos,dimensions,color,font)
    return obj("TextLabel",{
        BackgroundTransparency=1,Text=tostring(text),Font=font or Enum.Font.Gotham,
        TextColor3=color or C.white,TextSize=size or 15,TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
        Position=pos or UDim2.fromScale(0,0),
        Size=dimensions or UDim2.fromScale(1,1),
    },parent)
end
local function button(parent,caption,pos,dimensions,handler,accent)
    local b=obj("TextButton",{
        Text=caption,Font=Enum.Font.GothamBold,TextColor3=accent and C.bg or C.white,
        TextSize=13,TextWrapped=true,AutoButtonColor=false,BorderSizePixel=0,
        BackgroundColor3=accent and C.gold or C.panel2,
        Position=pos,Size=dimensions
    },parent)
    curve(b,6)
    outline(b,C.gold,accent and .1 or .8,1)
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(.13),{BackgroundTransparency=.19}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(.13),{BackgroundTransparency=0}):Play()
    end)
    b.MouseButton1Click:Connect(handler)
    return b
end
local function panel(parent,size,pos)
    local f=obj("Frame",{
        Size=size,Position=pos,BorderSizePixel=0,
        BackgroundColor3=C.panel,BackgroundTransparency=.05
    },parent)
    curve(f,10)
    outline(f,C.gold,.68)
    return f
end
local gui=obj("ScreenGui",{
    Name="AlnairGameplayHUD",IgnoreGuiInset=true,ResetOnSpawn=false,
    DisplayOrder=35,ZIndexBehavior=Enum.ZIndexBehavior.Sibling
},playerGui)
local devButton=button(gui,"DEV",UDim2.new(1,-88,1,-46),UDim2.fromOffset(72,30),function()
    if not profile or not profile.dev then
        -- showDev implemented adiante
    end
end,false)
devButton.Name="DeveloperEntry"
devButton.BackgroundColor3=Color3.fromRGB(52,44,46)
devButton.TextColor3=C.gold
devButton.ZIndex=14

local hud=obj("Frame",{
    Name="CampaignHUD",BackgroundTransparency=1,
    Size=UDim2.fromScale(1,1),Visible=false
},gui)
local stats=panel(hud,UDim2.fromOffset(330,101),UDim2.new(1,-345,0,18))
local statMain=label(stats,"NIVEL 1   •   0 OURO   •   0 GEMAS",15,UDim2.fromScale(.05,.09),UDim2.fromScale(.9,.34),C.gold,Enum.Font.GothamBold)
local statAux=label(stats,"0 / 100 XP   |   VIDA 100/100",12,UDim2.fromScale(.05,.42),UDim2.fromScale(.9,.22),C.mute)
local xpBg=obj("Frame",{
    Size=UDim2.fromScale(.91,.07),Position=UDim2.fromScale(.045,.80),
    BackgroundColor3=Color3.fromRGB(54,63,76),BorderSizePixel=0,
},stats)
curve(xpBg,5)
local xpFill=obj("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=C.gold,BorderSizePixel=0},xpBg)
curve(xpFill,5)
local questPanel=panel(hud,UDim2.fromOffset(327,95),UDim2.fromOffset(18,97))
local questText=label(questPanel,"MISSÃO PRINCIPAL",14,UDim2.fromScale(.06,.12),UDim2.fromScale(.88,.72),C.white,Enum.Font.GothamMedium)
questText.TextYAlignment=Enum.TextYAlignment.Top

local bottom=panel(hud,UDim2.fromOffset(620,60),UDim2.new(.5,-310,1,-78))
bottom.BackgroundTransparency=.15
button(bottom,"M  MAPA",UDim2.fromScale(.01,.15),UDim2.fromScale(.17,.67),function() end)
button(bottom,"I  BOLSA",UDim2.fromScale(.20,.15),UDim2.fromScale(.19,.67),function() end)
button(bottom,"K  TALENTOS",UDim2.fromScale(.41,.15),UDim2.fromScale(.22,.67),function() end)
button(bottom,"V  CAVALO",UDim2.fromScale(.65,.15),UDim2.fromScale(.16,.67),function() action:FireServer("mount","horse") end)
button(bottom,"B  DRACO",UDim2.fromScale(.83,.15),UDim2.fromScale(.16,.67),function() action:FireServer("mount","dragon") end)

local runPanel=panel(hud,UDim2.fromOffset(310,94),UDim2.new(.5,-155,0,17))
runPanel.Visible=false
local runText=label(runPanel,"ARENA",14,UDim2.fromScale(.06,.12),UDim2.fromScale(.88,.82),C.gold,Enum.Font.GothamBold)
local skillBar=panel(hud,UDim2.fromOffset(390,47),UDim2.new(.5,-195,1,-132))
skillBar.Visible=false
local skillButtons={}
for i=1,5 do
    local x=(i-1)*.2
    local b=button(skillBar,tostring(i).." • --",UDim2.fromScale(x+.008,.10),UDim2.fromScale(.18,.78),function()
        if profile and profile.skills and profile.skills[i] then
            action:FireServer("attack",profile.skills[i])
        end
    end)
    b.TextSize=11
    skillButtons[i]=b
end

local notifyRoot=obj("Frame",{
    Name="Messages",BackgroundTransparency=1,
    Size=UDim2.fromOffset(570,110),Position=UDim2.new(.5,-285,.13,0)
},gui)
local function toast(message,kind)
    toastSerial+=1
    local stamp=toastSerial
    notifyRoot:ClearAllChildren()
    local f=panel(notifyRoot,UDim2.fromScale(.93,.60),UDim2.fromScale(.035,.20))
    f.BackgroundColor3=C.bg
    outline(f,kind=="warning" and C.red or kind=="success" and C.green or C.gold,.22)
    local t=label(f,message,15,UDim2.fromScale(.05,.05),UDim2.fromScale(.90,.9),C.white,Enum.Font.GothamMedium)
    t.TextXAlignment=Enum.TextXAlignment.Center
    task.delay(3.4,function()
        if stamp==toastSerial and f.Parent then f:Destroy() end
    end)
end

local function closeModal()
    if modal then modal:Destroy() end
    modal=nil;modalKind=nil;menuOpen=false
end
local function createModal(titleText,kind)
    closeModal()
    menuOpen=true;modalKind=kind
    modal=obj("Frame",{
        Name="Overlay_"..kind,Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.33,
        BorderSizePixel=0,ZIndex=50
    },gui)
    local frame=panel(modal,UDim2.fromScale(.70,.83),UDim2.fromScale(.15,.085))
    frame.Name="Window"
    frame.BackgroundColor3=C.bg
    frame.BackgroundTransparency=.01
    frame.ZIndex=51
    label(frame,titleText,26,UDim2.fromScale(.05,.032),UDim2.fromScale(.82,.10),
        C.gold,Enum.Font.Antique).ZIndex=53
    button(frame,"× FECHAR",UDim2.fromScale(.81,.035),UDim2.fromScale(.15,.075),closeModal).ZIndex=53
    return frame
end
local function makeScroll(parent)
    local scroll=obj("ScrollingFrame",{
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromScale(.92,.78),Position=UDim2.fromScale(.04,.16),
        CanvasSize=UDim2.fromScale(0,1),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=5,ScrollingDirection=Enum.ScrollingDirection.Y
    },parent)
    obj("UIListLayout",{
        Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder
    },scroll)
    return scroll
end
local function rowInfo(parent,title,detail,actionLabel,fn)
    local wrap=panel(parent,UDim2.new(1,-8,0,63),UDim2.new())
    wrap.AutomaticSize=Enum.AutomaticSize.None
    label(wrap,title,15,UDim2.fromScale(.04,.10),UDim2.fromScale(.65,.34),C.white,Enum.Font.GothamBold)
    label(wrap,detail,12,UDim2.fromScale(.04,.47),UDim2.fromScale(.69,.39),C.mute)
    if actionLabel then
        button(wrap,actionLabel,UDim2.fromScale(.77,.22),UDim2.fromScale(.20,.57),fn or function()end)
    end
    return wrap
end
local function showInventory()
    local win=createModal("INVENTÁRIO  /  RELÍQUIAS", "inventory")
    label(win,"A jornada é escrita nos objetos que carregamos.",12,
        UDim2.fromScale(.05,.125),UDim2.fromScale(.87,.05),C.mute)
    local scroll=makeScroll(win)
    if not profile then return end
    local equips=profile.equipped or {}
    rowInfo(scroll,"EQUIPADO","Arma: "..(equips.weapon or "--").."   |   Armadura: "..(equips.armor or "--"))
    for _,item in ipairs(profile.inventory or {}) do
        local typ=item.kind or "item"
        local actionCaption=(typ=="weapon" or typ=="armor") and "EQUIPAR"
            or typ=="consumable" and "UTILIZAR" or nil
        rowInfo(scroll,(item.name or item.id).."   ×"..tostring(item.amount or 1),
            (item.desc or "").."  •  "..typ,actionCaption,function()
                if typ=="consumable" then action:FireServer("potion")
                else action:FireServer("equip",item.id) end
            end)
    end
end
local function showShop()
    local win=createModal("MERCADOR DAS BRASAS  /  LOJA DE OURO","shop")
    label(win,"A moeda dourada e ganha nas aventuras. Gemas sao uma moeda premium separada.",
        13,UDim2.fromScale(.05,.12),UDim2.fromScale(.90,.07),C.mute)
    local wallet=profile and profile.gold or 0
    label(win,"SEU OURO:  "..wallet,15,UDim2.fromScale(.05,.205),UDim2.fromScale(.87,.06),C.gold,Enum.Font.GothamBold)
    local scroll=makeScroll(win)
    scroll.Position=UDim2.fromScale(.05,.30)
    scroll.Size=UDim2.fromScale(.89,.64)
    for _,item in ipairs(Rules.Shop) do
        rowInfo(scroll,item.name.." • "..item.goldPrice.." OURO",item.desc,"COMPRAR",function()
            action:FireServer("buy",item.id)
        end)
    end
end
local function showMap()
    local win=createModal("MAPA  /  VALE DAS CINZAS","map")
    label(win,"Áreas desconhecidas ficam encobertas. Explore para revelar o território.",13,
        UDim2.fromScale(.05,.12),UDim2.fromScale(.87,.06),C.mute)
    local map=obj("Frame",{
        BackgroundColor3=Color3.fromRGB(18,28,35),BorderSizePixel=0,
        Position=UDim2.fromScale(.08,.22),Size=UDim2.fromScale(.78,.69),
        ClipsDescendants=true
    },win)
    curve(map,5)
    local g=Rules.FOG_GRID
    local fog=profile and profile.fog or {}
    for z=0,g-1 do
        for x=0,g-1 do
            local id=x.."_"..z
            local seen=fog[id]==true
            local cell=obj("Frame",{
                Position=UDim2.fromScale(x/g,z/g),
                Size=UDim2.fromScale(1/g,1/g),
                BorderSizePixel=1,BorderColor3=Color3.fromRGB(29,37,45),
                BackgroundColor3=seen and Color3.fromRGB(72+(x%3)*5,97+(z%3)*5,85) or Color3.fromRGB(13,15,24),
            },map)
            if not seen then
                label(cell,"?",14,UDim2.fromScale(0,0),UDim2.fromScale(1,1),C.mute).TextXAlignment=Enum.TextXAlignment.Center
            end
        end
    end
    local marker=obj("TextLabel",{
        BackgroundTransparency=1,Text="◆",TextColor3=C.gold,TextSize=25,
        TextStrokeTransparency=0,Size=UDim2.fromScale(.06,.07),
        Position=UDim2.fromScale(.47,.47)
    },map)
    local legends=label(win,"◆ VOCÊ  •  ZONA INICIAL: PRAÇA DO PRIMEIRO FOGO",11,
        UDim2.fromScale(.10,.92),UDim2.fromScale(.80,.048),C.gold,Enum.Font.GothamBold)
    local function sync()
        while modal==win.Parent and marker.Parent do
            local char=player.Character
            local rootPart=char and char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local pos=rootPart.Position
                local x=math.clamp((pos.X+Rules.MAP_SIZE/2)/Rules.MAP_SIZE,.02,.95)
                local z=math.clamp((pos.Z+Rules.MAP_SIZE/2)/Rules.MAP_SIZE,.02,.94)
                marker.Position=UDim2.fromScale(x,z)
            end
            task.wait(.45)
        end
    end
    task.spawn(sync)
end
local function showSkillbook()
    local win=createModal("LIVRO DE TALENTOS","skills")
    label(win,"A cada nível ímpar de 3 a 11, escolha 1 de 3. As outras duas desaparecem.",12,
        UDim2.fromScale(.05,.125),UDim2.fromScale(.91,.056),C.mute)
    local list=makeScroll(win)
    if not profile then return end
    local skills=profile.skills or {}
    local class=profile.class or "warrior"
    for i,id in ipairs(skills) do
        local info=Rules.skillById(class,id)
        if info then
            rowInfo(list,i..". "..info.name,info.desc.."  •  Recarga "..info.cooldown.."s")
        end
    end
    if #skills==0 then rowInfo(list,"Nenhum poder adquirido","O primeiro talento aparece no nível 3.") end
    if profile.draft then
        rowInfo(list,"ESCOLHA PENDENTE","Há 3 habilidades disponíveis.","ESCOLHER",function()
            dismissedDraft=nil
            -- A tela de escolha será exibida por renderDraft
            closeModal()
        end)
    end
end
local function renderDraft(draft)
    if not draft then return end
    local win=createModal("DESTINO  /  NÍVEL "..draft.level,"draft")
    label(win,"Escolha apenas um dos três talentos. Os outros jamais voltarão para este personagem.",
        13,UDim2.fromScale(.05,.135),UDim2.fromScale(.89,.09),C.mute)
    local cls=profile and profile.class or "warrior"
    for idx,id in ipairs(draft.options) do
        local data=Rules.skillById(cls,id)
        if data then
            local y=.28+(idx-1)*.205
            local f=panel(win,UDim2.fromScale(.89,.175),UDim2.fromScale(.055,y))
            label(f,string.format("%02d   %s",idx,data.name),19,
                UDim2.fromScale(.04,.12),UDim2.fromScale(.65,.32),C.gold,Enum.Font.Antique)
            label(f,data.desc.."  •  Recarga "..data.cooldown.."s",12,
                UDim2.fromScale(.04,.49),UDim2.fromScale(.63,.37),C.mute)
            button(f,"APRENDER",UDim2.fromScale(.72,.23),UDim2.fromScale(.25,.56),function()
                action:FireServer("skillChoice",id)
                closeModal()
                dismissedDraft=nil
            end,true)
        end
    end
end
local function renderCards(cards,wave)
    local win=createModal("A ARENA RESPIRA  /  HORDA "..tostring(wave),"cards")
    label(win,"A bênção permanece apenas até o fim desta run. Escolha uma carta.",14,
        UDim2.fromScale(.04,.15),UDim2.fromScale(.92,.07),C.mute)
    for idx,card in ipairs(cards or {}) do
        local y=.28+(idx-1)*.205
        local f=panel(win,UDim2.fromScale(.89,.177),UDim2.fromScale(.055,y))
        label(f,"✦  "..(card.name or ""),20,UDim2.fromScale(.04,.11),UDim2.fromScale(.66,.35),
            C.gold,Enum.Font.Antique)
        label(f,card.desc or "",13,UDim2.fromScale(.04,.48),UDim2.fromScale(.65,.39),C.mute)
        button(f,"ESCOLHER",UDim2.fromScale(.72,.21),UDim2.fromScale(.25,.60),function()
            action:FireServer("card",card.id);closeModal()
        end,true)
    end
    -- Não permitir fechar sem escolher carta; renderCards voltará pela atualização da run.
    local close=win:FindFirstChild("TextButton")
    if close then close.Visible=false end
end

local devInput=nil
local function devCommand(op,val)
    action:FireServer("dev",{op=op,value=val})
end
local function showDeveloper()
    local win=createModal("OFICINA DO CRIADOR  /  DEV","dev")
    if not profile or not profile.dev then
        label(win,"Somente para testes no Roblox Studio. A senha é verificada no servidor.",14,
            UDim2.fromScale(.07,.22),UDim2.fromScale(.86,.14),C.mute)
        local input=obj("TextBox",{
            Name="DevPassword",Text="",PlaceholderText="Senha de desenvolvimento",
            ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=20,
            TextColor3=C.white,BackgroundColor3=C.panel2,
            Position=UDim2.fromScale(.15,.45),Size=UDim2.fromScale(.7,.11),
            BorderSizePixel=0
        },win)
        curve(input,5)
        button(win,"DESBLOQUEAR",UDim2.fromScale(.31,.63),UDim2.fromScale(.38,.095),function()
            action:FireServer("devAuth",input.Text)
            input.Text=""
        end,true)
        return
    end
    label(win,"ACESSO TOTAL DE TESTE  •  SOMENTE STUDIO",12,
        UDim2.fromScale(.05,.12),UDim2.fromScale(.85,.055),C.green,Enum.Font.GothamBold)
    local val=obj("TextBox",{
        Name="DevValue",Text="5",ClearTextOnFocus=false,PlaceholderText="Valor numerico / texto",
        Font=Enum.Font.Gotham,TextSize=18,TextColor3=C.white,
        BackgroundColor3=C.panel2,BorderSizePixel=0,
        Position=UDim2.fromScale(.055,.19),Size=UDim2.fromScale(.89,.08),
    },win)
    curve(val,4);devInput=val
    local sc=obj("ScrollingFrame",{
        Size=UDim2.fromScale(.9,.64),Position=UDim2.fromScale(.05,.30),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,
        CanvasSize=UDim2.fromScale(0,1),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    },win)
    local layout=obj("UIGridLayout",{
        CellSize=UDim2.new(.47,0,0,48),
        CellPadding=UDim2.new(.04,0,0,9),SortOrder=Enum.SortOrder.LayoutOrder,
    },sc)
    local ops={
        {"DEFINIR NÍVEL","level"},{"SOMAR XP","xp"},
        {"SOMAR / REMOVER OURO","gold"},{"SOMAR / REMOVER GEMAS","gems"},
        {"TODAS AS HABILIDADES","skills"},{"RESETAR HABILIDADES","resetSkills"},
        {"MISSÃO Nº","quest"},{"CURAR TUDO","heal"},
        {"REVELAR MAPA","revealMap"},{"RECOBRIR MAPA","clearFog"},
        {"PRÓXIMA HORDA","nextWave"},{"DESBLOQUEAR MAPAS","unlockMaps"},
        {"VOLTAR AO LOBBY","lobby"},{"ENTRAR NO MAPA 1","map1"},
        {"ENTRAR NA ARENA","sandbox"},{"CRIAR ESQUELETO","skeleton"},
        {"CRIAR ORC","orc"},{"CRIAR BRUXA","witch"},
        {"CRIAR DRAGÃO","dragon"},{"CRIAR VIGIA","warden"},
    }
    for _,spec in ipairs(ops) do
        button(sc,spec[1],UDim2.new(),UDim2.new(),function()
            local op=spec[2]
            if op=="skeleton" or op=="orc" or op=="witch" or op=="dragon" or op=="warden" then
                devCommand("spawn",op)
            else
                devCommand(op,val.Text)
            end
        end)
    end
end
devButton.MouseButton1Click:Connect(showDeveloper)

local function runSummary(payload)
    local win=createModal("FIM DE RUN  /  ARENA DO CREPÚSCULO","summary")
    local claimed=payload.claimed
    label(win,claimed and "Você caiu. Mas as cinzas guardaram sua força." or "Você deixou a arena antes da queda.",
        22,UDim2.fromScale(.09,.23),UDim2.fromScale(.83,.15),claimed and C.gold or C.mute,Enum.Font.Antique)
    label(win,"HORDA SUPERADA: "..payload.wave,26,
        UDim2.fromScale(.10,.47),UDim2.fromScale(.80,.08),C.white,Enum.Font.GothamBold)
    label(win,"INIMIGOS: "..payload.kills.."    OURO: +"..payload.gold.."    XP: +"..payload.xp,
        18,UDim2.fromScale(.10,.60),UDim2.fromScale(.80,.10),C.gold)
    button(win,"RETORNAR AO NEXO",UDim2.fromScale(.30,.78),UDim2.fromScale(.40,.10),closeModal,true)
end

local function refreshHUD()
    if not profile then return end
    local mode=profile.mode
    gameplay=mode=="sandbox" or mode=="lobby" or mode=="campaign_map" or mode=="dungeon" or mode=="sky"
    hud.Visible=gameplay
    if not gameplay then return end
    local class=profile.class or "warrior"
    statMain.Text=string.format("NV.%d    ◆ %d OURO    ✦ %d GEMAS",
        profile.level or 1,profile.gold or 0,profile.gems or 0)
    local rootPart,humanoid=nil,nil
    if player.Character then humanoid=player.Character:FindFirstChildOfClass("Humanoid") end
    local health=humanoid and math.floor(humanoid.Health) or 100
    local maxHP=humanoid and math.floor(humanoid.MaxHealth) or 100
    statAux.Text=string.format("%d / %d XP    •    VIDA %d / %d",
        profile.xp or 0,profile.xpNext or 100,health,maxHP)
    xpFill.Size=UDim2.fromScale(math.clamp((profile.xp or 0)/math.max(1,profile.xpNext or 100),0,1),1)
    local quest=profile.quest
    if mode=="sandbox" then
        questText.Text="ARENA DO CREPÚSCULO\nRecompensas serão entregues ao morrer."
    elseif mode=="lobby" then
        questText.Text="NEXO DAS ESTRELAS\nAtravesse o portal azul para entrar no primeiro mapa."
    elseif quest then
        questText.Text=quest.title.."\n"..quest.task.."  "..(quest.progress or 0).."/"..(quest.total or 1)
    else
        questText.Text="VALE DAS CINZAS\nO primeiro capítulo foi concluído."
    end
    local r=profile.run
    runPanel.Visible=r~=nil
    if r then
        runText.Text=string.format("ARENA   /   HORDA %d\nInimigos: %d  •  Ouro pendente: %d\nEXP pendente: %d",
            r.wave or 1,r.remaining or 0,r.gold or 0,r.xp or 0)
    end
    skillBar.Visible=profile.skills and #profile.skills>0
    for i,b in ipairs(skillButtons) do
        local id=profile.skills and profile.skills[i]
        local skill=id and Rules.skillById(class,id)
        b.Text=skill and (i.."  "..skill.name) or tostring(i).."   —"
    end
    devButton.Text=profile.dev and "DEV ✓" or "DEV"
    if r and r.phase=="card" and r.cards and #r.cards==3 then
        local sig=tostring(r.wave)..":"..tostring(r.cards[1].id)
        if modalKind~="cards" and cardsSignature~=sig then
            cardsSignature=sig
            renderCards(r.cards,r.wave)
        end
    elseif not r or r.phase~="card" then
        cardsSignature=nil
    end
    if profile.draft and modalKind==nil then
        local id=tostring(profile.draft.level)
        if dismissedDraft~=id then
            dismissedDraft=id
            renderDraft(profile.draft)
        end
    elseif not profile.draft then
        dismissedDraft=nil
    end
end

local function toggle(kind)
    if modalKind==kind then closeModal();return end
    if kind=="inventory" then showInventory()
    elseif kind=="map" then showMap()
    elseif kind=="skills" then showSkillbook()
    elseif kind=="dev" then showDeveloper() end
end

-- Reencaminhar cliques dos botoes fixos para as janelas.
local menuHandlers={inventory=showInventory,map=showMap,skills=showSkillbook}
local barBtns={}
for _,child in ipairs(bottom:GetChildren()) do
    if child:IsA("TextButton") then table.insert(barBtns,child) end
end
for _,child in ipairs(barBtns) do
    if string.find(child.Text,"MAPA") then child.MouseButton1Click:Connect(function()toggle("map")end)
    elseif string.find(child.Text,"BOLSA") then child.MouseButton1Click:Connect(function()toggle("inventory")end)
    elseif string.find(child.Text,"TALENTOS") then child.MouseButton1Click:Connect(function()toggle("skills")end)
    end
end

state.OnClientEvent:Connect(function(kind,payload)
    if kind=="state" then
        profile=payload
        if modalKind=="dev" and profile and profile.dev then
            showDeveloper()
        end
        refreshHUD()
    elseif kind=="toast" then
        if payload then toast(payload.message or "",payload.kind) end
    elseif kind=="runSummary" then
        runSummary(payload)
    elseif kind=="openShop" then
        showShop()
    elseif kind=="skillUsed" then
        -- Recarga e dano sao calculados pelo servidor.
    end
end)
local ok,initial=pcall(function()return query:InvokeServer() end)
if ok and initial then profile=initial;refreshHUD() end

UserInputService.InputBegan:Connect(function(input,processed)
    if processed and input.KeyCode~=Enum.KeyCode.F8 then return end
    if input.KeyCode==Enum.KeyCode.F8 then toggle("dev");return end
    if not gameplay then return end
    if input.KeyCode==Enum.KeyCode.M then toggle("map");return end
    if input.KeyCode==Enum.KeyCode.I then toggle("inventory");return end
    if input.KeyCode==Enum.KeyCode.K then toggle("skills");return end
    if menuOpen then return end
    if input.KeyCode==Enum.KeyCode.V then action:FireServer("mount","horse")
    elseif input.KeyCode==Enum.KeyCode.B then action:FireServer("mount","dragon")
    elseif input.KeyCode==Enum.KeyCode.H then action:FireServer("potion")
    elseif input.UserInputType==Enum.UserInputType.MouseButton1 then action:FireServer("attack","basic")
    else
        local keys={Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Five}
        for i,key in ipairs(keys) do
            if input.KeyCode==key then
                local id=profile and profile.skills and profile.skills[i]
                if id then action:FireServer("attack",id) end
                break
            end
        end
    end
end)

local lastFlight=0
RunService.Heartbeat:Connect(function(dt)
    if not profile or profile.mounted~="dragon" or not gameplay then return end
    lastFlight+=dt
    if lastFlight<.13 then return end
    lastFlight=0
    local cam=workspace.CurrentCamera
    if not cam then return end
    local f=cam.CFrame.LookVector
    local forward=Vector3.new(f.X,0,f.Z)
    if forward.Magnitude<.05 then forward=Vector3.new(0,0,-1) end
    forward=forward.Unit
    local right=cam.CFrame.RightVector
    right=Vector3.new(right.X,0,right.Z).Unit
    local velocity=Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity+=forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity-=forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity+=right end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity-=right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity+=Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity-=Vector3.yAxis end
    if velocity.Magnitude>1 then velocity=velocity.Unit end
    action:FireServer("fly",velocity)
end)

print("[ALNAIR] HUD v0.4 pronto: M mapa, I bolsa, K poderes, F8 DEV, V cavalo, B dragao.")
