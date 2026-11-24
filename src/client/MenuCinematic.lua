--!strict
-- Alnair: camera enters a physical house, wooden door swings open, then
-- the player chooses race/class inside. No videos, screenshots, or paid assets.
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")

local Cinematic={}
local function tween(object,props,duration,style,direction)
    local tw=TweenService:Create(object,
        TweenInfo.new(duration,style or Enum.EasingStyle.Sine,
            direction or Enum.EasingDirection.InOut),props)
    tw:Play()
    return tw
end
-- Never leave a black screen if a tween Completed signal is lost.
-- Roblox Studio preview can interrupt a camera tween during rendering.
local function awaitTween(tw,duration)
    local finished=false
    local connection=tw.Completed:Connect(function()
        finished=true
    end)
    local deadline=os.clock()+duration+1.10
    while not finished and os.clock()<deadline do
        task.wait(.04)
    end
    connection:Disconnect()
    if not finished then
        tw:Cancel()
        warn("[ALNAIR] Tween timeout; recovering without black screen.")
    end
end

local function doorStage()
    local world=Workspace:FindFirstChild("AlnairWorld") or Workspace:WaitForChild("AlnairWorld",10)
    if not world then return nil end
    return world:FindFirstChild("MenuCinematicHouse") or world:WaitForChild("MenuCinematicHouse",9)
end

function Cinematic.new(camera,gui,left)
    local stage=doorStage()
    local available=stage~=nil
    local anchors=available and stage:FindFirstChild("CameraAnchors")
    local door=available and stage:FindFirstChild("MenuDoor")
    local exterior=available and stage:FindFirstChild("CC0HouseExterior")
    if not (anchors and door and exterior) then
        available=false
        warn("[ALNAIR] Menu scene not ready; transitions will use simple fade.")
    end
    local curtain=Instance.new("Frame")
    curtain.Name="CinematicBlackout"
    curtain.Size=UDim2.fromScale(1,1)
    curtain.Position=UDim2.fromScale(0,0)
    curtain.BackgroundColor3=Color3.fromRGB(5,9,9)
    curtain.BackgroundTransparency=1
    curtain.BorderSizePixel=0
    curtain.ZIndex=50
    curtain.Active=false
    curtain.Visible=false
    curtain.Parent=gui
    local busy=false
    local inside=false
    local transitionNumber=0
    local timedOut=false
    local closed=door and door.CFrame
    local opened=nil
    if closed and door then
        local hinge=Vector3.new(
            door:GetAttribute("HingeX") or closed.Position.X-door.Size.X/2,
            door:GetAttribute("HingeY") or closed.Position.Y,
            door:GetAttribute("HingeZ") or closed.Position.Z
        )
        opened=CFrame.new(hinge)*CFrame.Angles(0,math.rad(-96),0)*
            CFrame.new(door.Size.X/2,0,0)
    end

    local function concealExterior(conceal)
        if not exterior then return end
        for _,obj in ipairs(exterior:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier=conceal and 1 or 0
            end
        end
    end
    local function anchor(name)
        local result=anchors and anchors:FindFirstChild(name)
        return result and result:IsA("BasePart") and result.CFrame or nil
    end
    local function move(name,seconds)
        if timedOut then error("Alnair cinematic superseded") end
        local cf=anchor(name)
        if not cf then return end
        camera.CameraType=Enum.CameraType.Scriptable
        local motion=tween(camera,{CFrame=cf},seconds)
        awaitTween(motion,seconds)
    end
    local function veil(to,seconds)
        if timedOut then error("Alnair cinematic superseded") end
        curtain.Visible=true
        -- Never blank the entire world during an entrance animation.
        -- Keep some of the 3D scene visible even at the darkest moment.
        local motion=tween(curtain,{BackgroundTransparency=math.max(to,.38)},seconds)
        awaitTween(motion,seconds)
        if to>=1 then curtain.Visible=false end
    end
    local function leftFade(to,seconds)
        if timedOut then error("Alnair cinematic superseded") end
        if not left or not left.Parent or not left:IsA("CanvasGroup") then return end
        local motion=tween(left,{GroupTransparency=to},seconds)
        awaitTween(motion,seconds)
    end
    local function finish()
        -- New gameplay should not hide this house from the local player.
        concealExterior(false)
        if closed and door then door.CFrame=closed end
        inside=false
        curtain.Visible=false
        curtain.BackgroundTransparency=1
        if left and left:IsA("CanvasGroup") then left.GroupTransparency=0 end
    end

    local api={}
    function api.available()
        return available
    end
    function api.busy()
        return busy
    end
    function api.finish()
        finish()
    end
    function api.play(fromStep,toStep,onArrive)
        if busy then return false end
        busy=true
        timedOut=false
        transitionNumber+=1
        local myTransition=transitionNumber
        local invoked=false
        local function arrive()
            if not invoked then
                invoked=true
                onArrive()
            end
        end
        local function recover()
            if myTransition~=transitionNumber then return end
            transitionNumber+=1
            timedOut=true
            -- Restore all user-facing GUI and the camera to the exact
            -- destination. Keep the interactive house scene for the
            -- race/class/appearance panels, and always reveal text.
            finish()
            if toStep~="home" then concealExterior(true) end
            local target=(toStep=="home" and "Menu")
                or (toStep=="class" and "Class")
                or (toStep=="appearance" and "Appearance") or "Race"
            camera.CameraType=Enum.CameraType.Scriptable
            camera.CFrame=anchor(target) or camera.CFrame
            local ok,err=pcall(arrive)
            if not ok then warn("[ALNAIR] Menu recovery callback:",err) end
            curtain.Visible=false
            curtain.BackgroundTransparency=1
            if left and left:IsA("CanvasGroup") then left.GroupTransparency=0 end
            busy=false
        end
        -- No black-screen deadlock, even if a tween / door / streaming
        -- load stalls. This watchdog runs in the real Play client.
        task.delay(10,function()
            if busy and transitionNumber==myTransition then
                warn("[ALNAIR] Menu transition exceeded 10s; restoring scene.")
                recover()
            end
        end)
        task.spawn(function()
            local ok,err=pcall(function()
                if not available then
                    veil(0,.20)
                    arrive()
                    veil(1,.29)
                    return
                end
                if fromStep=="home" and toStep=="race" then
                    camera.CameraType=Enum.CameraType.Scriptable
                    leftFade(1,.32)
                    move("Approach",1.15)
                    local camDoor=anchor("Doorway")
                    local doorTween=tween(door,{CFrame=opened},.88,
                        Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
                    if camDoor then
                        local motion=tween(camera,{CFrame=camDoor},.88)
                        awaitTween(motion,.88)
                    else
                        awaitTween(doorTween,.88)
                    end
                    local final=anchor("Threshold")
                    if final then
                        local moveIn=tween(camera,{CFrame=final},.65,
                            Enum.EasingStyle.Sine,Enum.EasingDirection.In)
                        task.wait(.33)
                        veil(0,.31)
                        awaitTween(moveIn,.65)
                    else
                        veil(0,.30)
                    end
                    concealExterior(true)
                    inside=true
                    camera.CFrame=anchor("Race") or camera.CFrame
                    arrive()
                    veil(1,.47)
                    leftFade(0,.31)
                elseif toStep=="home" then
                    leftFade(1,.18)
                    veil(0,.24)
                    concealExterior(false)
                    camera.CFrame=anchor("Threshold") or camera.CFrame
                    veil(1,.28)
                    move("Doorway",.62)
                    local doorBack=tween(door,{CFrame=closed},.86,
                        Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
                    move("Approach",.86)
                    awaitTween(doorBack,.86)
                    move("Menu",1.05)
                    inside=false
                    arrive()
                    leftFade(0,.35)
                else
                    local nextAnchor=(toStep=="class" and "Class")
                        or (toStep=="appearance" and "Appearance") or "Race"
                    leftFade(1,.20)
                    move(nextAnchor,.70)
                    arrive()
                    leftFade(0,.22)
                end
            end)
            if myTransition~=transitionNumber then return end
            if not ok then
                warn("[ALNAIR] Menu cinematic error:",err)
                recover()
                return
            end
            -- Invariant: a completed transition never leaves a black
            -- overlay or hidden controls behind.
            curtain.Visible=false
            curtain.BackgroundTransparency=1
            if left and left:IsA("CanvasGroup") then left.GroupTransparency=0 end
            busy=false
        end)
        return true
    end
    return api
end
return Cinematic
