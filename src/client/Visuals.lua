--!strict
-- Inspirações visuais adaptadas ao Roblox:
-- FluxLines -> fitas luminosas procedurais com atração do cursor/click swirl.
-- HalftoneReveal -> retícula de pontos com revelação por aproximação/click.
-- Sem shaders WebGL/React: apenas GuiObjects, RunService e Luau.
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Visuals = {}

local function element(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function inside(p, rect)
    return p.X >= rect.AbsolutePosition.X and p.Y >= rect.AbsolutePosition.Y
        and p.X <= rect.AbsolutePosition.X + rect.AbsoluteSize.X
        and p.Y <= rect.AbsolutePosition.Y + rect.AbsoluteSize.Y
end

local function segment(parent, color, alpha, thick, index)
    return element("Frame", {
        Name = "Segment_" .. index,
        AnchorPoint = Vector2.new(.5,.5),
        BackgroundColor3 = color,
        BackgroundTransparency = alpha,
        BorderSizePixel = 0,
        ZIndex = 2,
        Size = UDim2.fromOffset(2,thick),
        Visible = true,
    },parent)
end

local function fitLine(gui, from, to, width)
    local v = to - from
    local length = v.Magnitude
    if length < .05 then
        gui.Visible = false
        return
    end
    gui.Visible = true
    gui.Position = UDim2.fromOffset((from.X + to.X)/2,(from.Y + to.Y)/2)
    gui.Size = UDim2.fromOffset(length,width)
    gui.Rotation = math.deg(math.atan2(v.Y,v.X))
end

function Visuals.flux(parent, opts)
    opts = opts or {}
    local n = opts.strands or 8
    local count = opts.segments or 20
    local base = element("Frame", {
        Name = "FluxLinesNative",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = false,
        ClipsDescendants = true,
        ZIndex = 2,
        Position = opts.position or UDim2.fromScale(0,0),
        Size = opts.size or UDim2.fromScale(1,1),
    }, parent)
    local palette = opts.colors or {
        Color3.fromRGB(190,225,240),
        Color3.fromRGB(236,216,177),
        Color3.fromRGB(130,188,205),
    }
    local layers = {}
    for i=1,n do
        layers[i] = {}
        local color = palette[((i-1) % #palette) + 1]
        for j=1,count do
            layers[i][j] = {
                glow=segment(base,color,.94,10,i*1000+j),
                middle=segment(base,color,.86,4,i*1000+j+300),
                core=segment(base,color,.44,1.5,i*1000+j+600),
            }
        end
    end

    local sparks = {}
    for i=1,42 do
        local v = element("Frame", {
            Name="StellarDust",
            AnchorPoint=Vector2.new(.5,.5),
            BackgroundColor3=palette[((i-1)%#palette)+1],
            BackgroundTransparency=.7,
            BorderSizePixel=0,
            Size=UDim2.fromOffset(i%5==0 and 3 or 2,i%5==0 and 3 or 2),
            ZIndex=2,
        },base)
        element("UICorner",{CornerRadius=UDim.new(1,0)},v)
        sparks[i] = v
    end

    local elapsed = 0
    local drawn = 0
    local swirlAt = -100
    local swirlPoint = Vector2.zero
    local currentMouse = Vector2.zero

    local input = UserInputService.InputBegan:Connect(function(io, processed)
        if processed then return end
        if io.UserInputType == Enum.UserInputType.MouseButton1 or io.UserInputType == Enum.UserInputType.Touch then
            local m = UserInputService:GetMouseLocation()
            if inside(m,base) then
                swirlAt=elapsed
                swirlPoint=m-base.AbsolutePosition
            end
        end
    end)

    local function flowPoint(i,j,width,height,time)
        local fraction = (j-1)/(count)
        local phase = i*.93
        local drift=time*(opts.speed or .25)
        local baseX=width*(.10+(i-1)/(math.max(n-1,1))*.80)
        local x=baseX
            + math.sin(fraction*7.8+phase+drift*.62)*width*.056
            + math.sin(fraction*14.1+phase*.3-drift*.34)*width*.018
            + math.noise(fraction*2.3+time*.03,i*.24,.5)*width*.018
        local y=(fraction*1.23-.105)*height
        y = ((y+time*height*(opts.speed or .25)*.075)%(height*1.25))-(height*.10)
        local mag = UserInputService:GetMouseLocation()-base.AbsolutePosition
        currentMouse = currentMouse:Lerp(mag,.10)
        local v=Vector2.new(x,y)
        local reach=height*.38
        local delta = v-currentMouse
        local d2=delta:Dot(delta)
        local pull=math.exp(-d2/(reach*reach))
        v+=Vector2.new(delta.Y,-delta.X)*pull*.18
        local age=time-swirlAt
        if age>0 and age<2 then
            local offset = v-swirlPoint
            local r=height*.39
            local strength=math.exp(-age*1.6)*math.exp(-offset:Dot(offset)/(r*r))
            local theta=strength*1.15
            local c,s=math.cos(theta),math.sin(theta)
            v=swirlPoint+Vector2.new(offset.X*c-offset.Y*s,offset.X*s+offset.Y*c)
        end
        return v
    end

    local connection = RunService.RenderStepped:Connect(function(dt)
        if not base.Parent then return end
        elapsed += math.min(dt,.07)
        if elapsed-drawn < (opts.updateInterval or .055) then return end
        drawn=elapsed
        local width,height=base.AbsoluteSize.X,base.AbsoluteSize.Y
        if width<10 or height<10 then return end

        for i=1,n do
            local previous = flowPoint(i,1,width,height,elapsed)
            for j=1,count do
                local point=flowPoint(i,j+1,width,height,elapsed)
                local seg=layers[i][j]
                local alpha=math.sin((i/n)*math.pi)*.45+.5
                fitLine(seg.glow,previous,point,11*alpha)
                fitLine(seg.middle,previous,point,4*alpha)
                fitLine(seg.core,previous,point,1.5)
                local fade=math.clamp(.58+(1-alpha)*.38,0,1)
                seg.core.BackgroundTransparency=fade
                previous=point
            end
        end
        for i,v in ipairs(sparks) do
            local x=((i*73)%100)/100
            local y=((i*39)%97)/97
            local phase=elapsed*(.20+(i%8)*.015)
            v.Position=UDim2.fromOffset(
                width*(x + math.sin(phase*2+i)*.009),
                height*((y-phase*.035)%1)
            )
            v.BackgroundTransparency=math.clamp(.78+math.sin(elapsed*(1+i%5)*.58+i)*.16,.46,.98)
        end
    end)

    return function()
        connection:Disconnect()
        input:Disconnect()
        base:Destroy()
    end
end

function Visuals.halftone(parent, opts)
    opts=opts or {}
    local layer=element("Frame",{
        Name="HalftoneRevealNative",
        Active=false,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ClipsDescendants=true,
        ZIndex=opts.zIndex or 7,
        Position=UDim2.fromScale(0,0),
        Size=UDim2.fromScale(1,1),
    },parent)
    local nx,ny=opts.columns or 22,opts.rows or 17
    local dots={}
    for y=1,ny do
        for x=1,nx do
            local nxp=(x-.5)/nx
            local nyp=(y-.5)/ny
            local size=math.max(2,opts.size or 4)
            local dot=element("Frame",{
                AnchorPoint=Vector2.new(.5,.5),
                Position=UDim2.fromScale(nxp,nyp),
                Size=UDim2.fromOffset(size,size),
                BackgroundColor3=opts.color or Color3.fromRGB(225,199,147),
                BackgroundTransparency=.76,
                BorderSizePixel=0,
                ZIndex=layer.ZIndex,
            },layer)
            element("UICorner",{CornerRadius=UDim.new(1,0)},dot)
            table.insert(dots,{node=dot,x=nxp,y=nyp})
        end
    end
    local elapsed=0
    local drawn=0
    local burstTime=-20
    local burstPos=Vector2.new(.5,.5)
    local mouse=Vector2.new(-1000,-1000)
    local input=UserInputService.InputBegan:Connect(function(io,processed)
        if processed then return end
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
            local m=UserInputService:GetMouseLocation()
            if inside(m,layer) then
                burstTime=elapsed
                local lp=m-layer.AbsolutePosition
                burstPos=Vector2.new(lp.X/math.max(layer.AbsoluteSize.X,1),lp.Y/math.max(layer.AbsoluteSize.Y,1))
            end
        end
    end)
    local connection=RunService.RenderStepped:Connect(function(dt)
        elapsed += math.min(dt,.09)
        if elapsed-drawn<.08 then return end
        drawn=elapsed
        local pos=UserInputService:GetMouseLocation()
        local localMouse=pos-layer.AbsolutePosition
        mouse=mouse:Lerp(localMouse,.25)
        local scale=layer.AbsoluteSize
        local radius=math.max(90,math.min(scale.X,scale.Y)*.30)
        local bAge=elapsed-burstTime
        for i,d in ipairs(dots) do
            local p=Vector2.new(d.x*scale.X,d.y*scale.Y)
            local distance=(mouse-p).Magnitude
            local reveal=math.exp(-math.pow(distance/radius,2)*1.3)
            local burstDistance=(Vector2.new(d.x,d.y)-burstPos).Magnitude
            local shock=(bAge>=0 and bAge<1.2)
                and math.exp(-math.pow((burstDistance-bAge*.8)/.09,2))*(1-bAge/1.2)
                or 0
            local noise=math.noise(i*.11,d.x*4,elapsed*.4)
            d.node.BackgroundTransparency=math.clamp(.60+reveal*.36+shock*.42+noise*.05,.48,.99)
            local size=math.max(1.5,(opts.size or 3.4)*(1-reveal*.55-shock*.45))
            d.node.Size=UDim2.fromOffset(size,size)
        end
    end)
    return function()
        connection:Disconnect()
        input:Disconnect()
        layer:Destroy()
    end
end

function Visuals.rings(parent, centerX,centerY,size)
    local base=element("Frame",{
        Name="AstralRings",BackgroundTransparency=1,
        AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(centerX,centerY),
        Size=UDim2.fromOffset(size,size),
        ZIndex=3,
    },parent)
    local rings = {}
    for i=1,4 do
        local side=size*(.40+i*.14)
        local r=element("Frame",{
            BackgroundTransparency=1,
            AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.fromScale(.5,.5),
            Size=UDim2.fromOffset(side,side),
            ZIndex=3,
        },base)
        element("UICorner",{CornerRadius=UDim.new(1,0)},r)
        element("UIStroke",{
            Color=i%2==0 and Color3.fromRGB(204,174,118) or Color3.fromRGB(134,186,205),
            Transparency=.71+i*.04,
            Thickness=i==1 and 2 or 1,
        },r)
        rings[i]=r
    end
    local glyphs={}
    for i=1,12 do
        local dot=element("Frame",{
            BackgroundColor3=i%3==0 and Color3.fromRGB(243,210,151) or Color3.fromRGB(148,194,211),
            BackgroundTransparency=i%3==0 and .16 or .45,
            BorderSizePixel=0,
            Size=UDim2.fromOffset(i%3==0 and 5 or 2,i%3==0 and 5 or 2),
            AnchorPoint=Vector2.new(.5,.5),
            ZIndex=4,
        },base)
        if i%3==0 then dot.Rotation=45 end
        glyphs[i]=dot
    end
    local elapsed=0
    local connection=RunService.RenderStepped:Connect(function(dt)
        elapsed+=math.min(dt,.08)
        for i,r in ipairs(rings) do r.Rotation=(i%2==0 and -1 or 1)*elapsed*(2+i*1.1) end
        for i,d in ipairs(glyphs) do
            local a=i*math.pi/6+elapsed*(i%2==0 and -.06 or .08)
            local rad=size*(.28+(i%3)*.06)
            d.Position=UDim2.fromOffset(size/2+math.cos(a)*rad,size/2+math.sin(a)*rad)
        end
    end)
    return function()
        connection:Disconnect()
        base:Destroy()
    end
end

return Visuals
