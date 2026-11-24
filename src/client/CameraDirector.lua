--!strict
-- ALNAIR: 3rd person is the ONLY playable camera for this development stage.
-- True Roblox blocky R15 avatar, no FPS or 360-degree camera orbit.
-- RIGHT mouse drag: yaw limited to +/-90 deg from initial heading (180 total).
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local CameraDirector={}

local function drift(camera,position,target,speed)
    camera.CameraType=Enum.CameraType.Scriptable
    camera.FieldOfView=54
    local tick=0
    local conn=RunService.RenderStepped:Connect(function(dt)
        if not camera.Parent then return end
        tick+=math.min(dt,.05)
        local move=Vector3.new(math.sin(tick*speed)*1.4,
            math.sin(tick*.24)*.4,math.cos(tick*speed*.65)*.6)
        camera.CFrame=CFrame.lookAt(position+move,target)
    end)
    return function()conn:Disconnect()end
end

local function anchor(name)
    local world=workspace:FindFirstChild("AlnairWorld")
    local house=world and world:FindFirstChild("MenuCinematicHouse")
    local anchors=house and house:FindFirstChild("CameraAnchors")
    local part=anchors and anchors:FindFirstChild(name)
    return part and part:IsA("BasePart") and part.CFrame or nil
end

function CameraDirector.menu(camera)
    local cf=anchor("Menu")
    if cf then return drift(camera,cf.Position,cf.Position+cf.LookVector*48,.065)end
    return drift(camera,Vector3.new(45,14,84),Vector3.new(7,6,15),.10)
end
function CameraDirector.creator(camera)
    local cf=anchor("Race")
    if cf then return drift(camera,cf.Position,cf.Position+cf.LookVector*38,.04)end
    return drift(camera,Vector3.new(23,16,52),Vector3.new(0,5,-8),.08)
end

local KEY="AlnairLimitedThirdPersonCamera"
local MAX_YAW=math.rad(90)
local MIN_PITCH=math.rad(-13)
local MAX_PITCH=math.rad(42)
local DISTANCE=10.3
local LOOK_HEIGHT=2.5

function CameraDirector.explore(camera,player,humanoid)
    if not humanoid or not humanoid.Parent then return function()end end
    local character=humanoid.Parent
    local root=character:FindFirstChild("HumanoidRootPart") or
        character:WaitForChild("HumanoidRootPart",12)
    if not root or not root:IsA("BasePart") then return function()end end
    if humanoid.RigType~=Enum.HumanoidRigType.R15 then
        warn("[ALNAIR] Terceira pessoa articulada requer Roblox BLOCKY R15.")
    end

    local saved={
        mode=player.CameraMode,
        min=player.CameraMinZoomDistance,max=player.CameraMaxZoomDistance,
        icon=UserInputService.MouseIconEnabled,
        behavior=UserInputService.MouseBehavior,
        cameraType=camera.CameraType,subject=camera.CameraSubject,
        fov=camera.FieldOfView,offset=humanoid.CameraOffset,
    }
    local network=ReplicatedStorage:WaitForChild("AlnairGame",10)
    local action=network and network:FindFirstChild("Action")
    local forward=root.CFrame.LookVector
    local cameraYaw=math.atan2(-forward.X,-forward.Z)
    local lastCameraInput=os.clock()
    local returnTime=3
    local pitch=math.rad(18)
    local dragging=false
    local dragButton=nil
    local sprinting=false
    local shiftStart=nil
    local goalFov=67
    local active=true
    local cameraPosition=nil
    local lastDragDelta=Vector2.zero

    player.CameraMode=Enum.CameraMode.Classic
    player.CameraMinZoomDistance=8
    player.CameraMaxZoomDistance=13
    player:SetAttribute("AlnairCameraMode","ThirdPersonLimited")
    player:SetAttribute("AlnairCameraYawLimit",180)
    UserInputService.MouseBehavior=Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled=true
    humanoid.CameraOffset=Vector3.zero
    camera.CameraType=Enum.CameraType.Scriptable
    camera.CameraSubject=humanoid
    camera.FieldOfView=67

    local function sprint(enable)
        if not active or sprinting==enable then return end
        sprinting=enable and humanoid.Health>0
        player:SetAttribute("AlnairSprinting",sprinting)
        goalFov=sprinting and 73 or 67
        if action then action:FireServer("sprint",sprinting)end
    end
    local down=UserInputService.InputBegan:Connect(function(input,processed)
        if not active or player:GetAttribute("AlnairUIFocus") then return end
        if (input.UserInputType==Enum.UserInputType.MouseButton2)
            then
            dragging=true
            dragButton=input.UserInputType
            lastDragDelta=Vector2.zero
        elseif not processed and (input.KeyCode==Enum.KeyCode.LeftShift
            or input.KeyCode==Enum.KeyCode.ButtonL3) then
            shiftStart=os.clock()
            local stamp=shiftStart
            task.delay(.20,function() if active and shiftStart==stamp then sprint(true) end end)
        end
    end)
    local movement=UserInputService.InputChanged:Connect(function() end)
    local previousMouse=UserInputService:GetMouseLocation()
    local wasHeld=false
    local up=UserInputService.InputEnded:Connect(function(input)
        if dragButton and input.UserInputType==dragButton then
            dragging=false
            dragButton=nil
            player:SetAttribute("AlnairCameraDragging",false)
        elseif input.KeyCode==Enum.KeyCode.LeftShift or
            input.KeyCode==Enum.KeyCode.ButtonL3 then
            local tap=shiftStart and os.clock()-shiftStart<.20
            shiftStart=nil
            sprint(false)
            if tap and action then
                local dir=humanoid.MoveDirection
                if dir.Magnitude<.1 then dir=root.CFrame.LookVector end
                action:FireServer("dodge",dir)
            end
        end
    end)
    local death=humanoid.Died:Connect(function()
        dragging=false
        sprint(false)
    end)

    local trace=RaycastParams.new()
    trace.FilterType=Enum.RaycastFilterType.Exclude
    trace.FilterDescendantsInstances={character}
    trace.IgnoreWater=true
    pcall(function()RunService:UnbindFromRenderStep(KEY)end)
    RunService:BindToRenderStep(KEY,Enum.RenderPriority.Camera.Value+8,function(dt)
        if not active or not root.Parent or humanoid.Health<=0 then return end
        if player:GetAttribute("AlnairUIFocus") then
            dragging=false
            if sprinting then sprint(false) end
        end
        local mouse=UserInputService:GetMouseLocation()
        local held=UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if held and wasHeld and not player:GetAttribute("AlnairUIFocus") then
            local delta=mouse-previousMouse
            if delta.Magnitude>.12 then
                -- Do not tie the camera to each character turn while being controlled.
                local heading=root.CFrame.LookVector
                local headingYaw=math.atan2(-heading.X,-heading.Z)
                local desired=cameraYaw-delta.X*.0058
                local relative=math.atan2(math.sin(desired-headingYaw),math.cos(desired-headingYaw))
                cameraYaw=headingYaw+math.clamp(relative,-MAX_YAW,MAX_YAW)
                pitch=math.clamp(pitch+delta.Y*.0039,MIN_PITCH,MAX_PITCH)
                lastCameraInput=os.clock()
            end
            lastDragDelta+=delta
            player:SetAttribute("AlnairCameraDragging",lastDragDelta.Magnitude>5)
        elseif not held then
            lastDragDelta=Vector2.zero
            player:SetAttribute("AlnairCameraDragging",false)
        end
        previousMouse=mouse
        wasHeld=held
        local heading=root.CFrame.LookVector
        local headingYaw=math.atan2(-heading.X,-heading.Z)
        -- Auto-return only after three full seconds without dragging.
        -- When the return finishes, reset the timer instead of permanently
        -- locking the camera to the character's neck.
        if os.clock()-lastCameraInput>=returnTime
            and not held and not player:GetAttribute("AlnairUIFocus") then
            local difference=math.atan2(math.sin(headingYaw-cameraYaw),math.cos(headingYaw-cameraYaw))
            cameraYaw+=difference*(1-math.exp(-math.clamp(dt,0,.07)*4))
            if math.abs(difference)<.018 then
                cameraYaw=headingYaw
                lastCameraInput=os.clock()
            end
        end
        local relativeYaw=math.atan2(math.sin(cameraYaw-headingYaw),math.cos(cameraYaw-headingYaw))
        player:SetAttribute("AlnairCameraYaw",math.deg(relativeYaw))
        local focus=root.Position+Vector3.new(0,LOOK_HEIGHT,0)
        local inclination=CFrame.Angles(0,cameraYaw,0)
        local localOffset=Vector3.new(0,math.sin(pitch)*DISTANCE,
            math.cos(pitch)*DISTANCE)
        local desired=focus+inclination:VectorToWorldSpace(localOffset)
        local hit=workspace:Raycast(focus,desired-focus,trace)
        if hit then
            local candidate=hit.Position+hit.Normal*.45
            if (candidate-focus).Magnitude>2.7 then desired=candidate
            else desired=focus+(desired-focus).Unit*2.7 end
        end
        local blend=1-math.exp(-math.clamp(dt,0,.07)*13)
        cameraPosition=cameraPosition and cameraPosition:Lerp(desired,blend)
            or desired
        camera.CFrame=CFrame.lookAt(cameraPosition,focus)
        camera.FieldOfView+=(goalFov-camera.FieldOfView)*
            (1-math.exp(-math.clamp(dt,0,.07)*7))
    end)

    return function()
        if not active then return end
        active=false
        pcall(function()RunService:UnbindFromRenderStep(KEY)end)
        down:Disconnect()
        movement:Disconnect()
        up:Disconnect()
        death:Disconnect()
        if sprinting and action then action:FireServer("sprint",false)end
        player:SetAttribute("AlnairSprinting",false)
        player:SetAttribute("AlnairCameraDragging",false)
        player:SetAttribute("AlnairCameraMode",nil)
        player:SetAttribute("AlnairCameraYawLimit",nil)
        player.CameraMode=saved.mode
        player.CameraMinZoomDistance=saved.min
        player.CameraMaxZoomDistance=saved.max
        UserInputService.MouseIconEnabled=saved.icon
        UserInputService.MouseBehavior=saved.behavior
        camera.CameraType=saved.cameraType
        camera.CameraSubject=saved.subject
        camera.FieldOfView=saved.fov
        if humanoid.Parent then humanoid.CameraOffset=saved.offset end
    end
end

return CameraDirector
