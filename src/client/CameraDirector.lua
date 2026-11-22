--!strict
-- Camera e locomocao em prototipo: inspiradas em RPGs modernos sem substituir o controlador nativo Roblox.
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CameraDirector = {}

local function drift(camera, source, target, rate)
    camera.CameraType = Enum.CameraType.Scriptable
    local elapsed=0
    local conn=RunService.RenderStepped:Connect(function(dt)
        if not camera.Parent then return end
        elapsed += math.min(dt,.05)
        local offset = Vector3.new(
            math.sin(elapsed*rate)*2.45,
            math.sin(elapsed*rate*.6)*.54,
            math.cos(elapsed*rate*.7)*1.15
        )
        camera.CFrame=CFrame.lookAt(source+offset,target)
    end)
    return function() conn:Disconnect() end
end

function CameraDirector.menu(camera)
    camera.FieldOfView=54
    return drift(camera,Vector3.new(31,18,58),Vector3.new(0,7,-78),.10)
end

function CameraDirector.creator(camera)
    camera.FieldOfView=55
    return drift(camera,Vector3.new(-48,32,64),Vector3.new(0,8,-26),.055)
end

function CameraDirector.explore(camera,player,humanoid)
    camera.CameraType=Enum.CameraType.Custom
    camera.CameraSubject=humanoid
    camera.FieldOfView=70
    player.CameraMinZoomDistance=5
    player.CameraMaxZoomDistance=17
    player.CameraMode=Enum.CameraMode.Classic
    humanoid.CameraOffset=Vector3.new(1.35,.45,0)
    humanoid.WalkSpeed=16

    local sprinting=false
    local speedTween=nil
    local function sprint(on)
        if sprinting==on or humanoid.Health <= 0 then return end
        sprinting=on
        if speedTween then speedTween:Cancel() end
        speedTween=TweenService:Create(humanoid,TweenInfo.new(.24,Enum.EasingStyle.Quad),{
            WalkSpeed=on and 23 or 16
        })
        speedTween:Play()
    end

    local down=UserInputService.InputBegan:Connect(function(input,processed)
        if processed then return end
        if input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.ButtonL3 then
            sprint(true)
        end
    end)
    local up=UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.ButtonL3 then
            sprint(false)
        end
    end)
    local death=humanoid.Died:Connect(function()
        sprint(false)
    end)

    return function()
        down:Disconnect()
        up:Disconnect()
        death:Disconnect()
        if speedTween then speedTween:Cancel() end
        if humanoid.Parent then
            humanoid.CameraOffset=Vector3.zero
            humanoid.WalkSpeed=16
        end
    end
end

return CameraDirector
