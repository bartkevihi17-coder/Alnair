--!strict
-- Real Roblox R15 motion with knee/elbow/wrist articulation.
-- Uses published, verified Roblox-owned R15 animation clips. Not fake body
-- segments or R6 Motor6D overrides. Gentle transitions and stride speed.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer

local CLIPS={
    idle={id=507766666,priority=Enum.AnimationPriority.Idle,looped=true},
    walk={id=507777826,priority=Enum.AnimationPriority.Movement,looped=true},
    run={id=507767714,priority=Enum.AnimationPriority.Movement,looped=true},
    jump={id=656117878,priority=Enum.AnimationPriority.Action,looped=false},
    fall={id=507767968,priority=Enum.AnimationPriority.Movement,looped=true},
    climb={id=507765644,priority=Enum.AnimationPriority.Movement,looped=true},
    swim={id=507784897,priority=Enum.AnimationPriority.Movement,looped=true},
}
local activeCleanup=nil

local function attach(character)
    if activeCleanup then activeCleanup();activeCleanup=nil end
    local humanoid=character:WaitForChild("Humanoid",12)
    local root=character:WaitForChild("HumanoidRootPart",12)
    if not humanoid or not root then return end
    if humanoid.RigType~=Enum.HumanoidRigType.R15 then return end
    local animator=humanoid:FindFirstChildOfClass("Animator")
        or humanoid:WaitForChild("Animator",8)
    if not animator then
        warn("[ALNAIR] Animator R15 não encontrado; animações padrão preservadas.")
        return
    end
    local nativeAnimate=character:FindFirstChild("Animate")
    local tracks={}
    local originalAnimateEnabled=nativeAnimate and nativeAnimate:IsA("LocalScript")
        and nativeAnimate.Enabled or false
    local function build()
        for name,clip in pairs(CLIPS) do
            local anim=Instance.new("Animation")
            anim.Name="AlnairOfficial_"..name
            anim.AnimationId="rbxassetid://"..clip.id
            local ok,track=pcall(function()
                return animator:LoadAnimation(anim)
            end)
            anim:Destroy()
            if not ok or not track then
                warn("[ALNAIR] Falha ao carregar animação Roblox:",name,track)
                return false
            end
            track.Priority=clip.priority
            track.Looped=clip.looped
            tracks[name]=track
        end
        return true
    end
    if not build() then
        for _,track in pairs(tracks) do pcall(function()track:Destroy()end)end
        return
    end
    -- Only suppress the stock Animate once the replacement is ready.
    if nativeAnimate and nativeAnimate:IsA("LocalScript") then
        nativeAnimate.Enabled=false
        -- Stop already playing stock tracks so they cannot compete
        -- with the articulated Alnair tracks at the same time.
        for _,oldTrack in ipairs(animator:GetPlayingAnimationTracks()) do
            oldTrack:Stop(.12)
        end
    end
    if player:GetAttribute("AlnairClass")=="assassin" then
        local anim=Instance.new("Animation");anim.AnimationId="rbxassetid://656118852"
        local ok,tr=pcall(function() return animator:LoadAnimation(anim) end);anim:Destroy()
        if ok then tracks.run:Destroy();tracks.run=tr;tr.Priority=Enum.AnimationPriority.Movement;tr.Looped=true end
    end
    local current=nil
    local alive=true
    local velocityScale=1
    local jumpUntil=0
    -- HumanoidDescription can briefly restart the original Roblox idle
    -- after Animate was disabled. Suppress those stock idle tracks only,
    -- while preserving action/combat animations from other systems.
    local stockPlayback=animator.AnimationPlayed:Connect(function(track)
        if (track.Name=="Animation1" or track.Name=="Animation2")
            and (track.Priority==Enum.AnimationPriority.Idle
                or track.Priority==Enum.AnimationPriority.Core) then
            track:Stop(.10)
        end
    end)
    local function transition(name)
        if current==name then return end
        local previous=current and tracks[current]
        local nextTrack=tracks[name]
        if not nextTrack then return end
        if previous then previous:Stop(.19) end
        current=name
        nextTrack:Play(.19,1,1)
        character:SetAttribute("AlnairMotion",name)
    end
    transition("idle")

    local connection=RunService.PreAnimation:Connect(function(dt)
        if not alive or not character.Parent or humanoid.Health<=0 then return end
        local state=humanoid:GetState()
        local goal="idle"
        if state==Enum.HumanoidStateType.Jumping then
            jumpUntil=os.clock()+.23
            goal="jump"
        elseif state==Enum.HumanoidStateType.Freefall then
            goal=os.clock()<jumpUntil and "jump" or "fall"
        elseif state==Enum.HumanoidStateType.Climbing then
            goal="climb"
        elseif state==Enum.HumanoidStateType.Swimming then
            goal="swim"
        else
            local velocity=root.AssemblyLinearVelocity
            local horizontal=Vector3.new(velocity.X,0,velocity.Z).Magnitude
            -- MoveTo / controller movement can report zero MoveDirection
            -- on some Roblox clients even as the avatar walks.
            local walking=humanoid.MoveDirection.Magnitude>.11
                or (state==Enum.HumanoidStateType.Running and horizontal>1.2)
            if walking then
                goal=(player:GetAttribute("AlnairSprinting")==true or
                    humanoid.WalkSpeed>=20) and "run" or "walk"
            end
        end
        transition(goal)
        if goal=="walk" or goal=="run" then
            local velocity=root.AssemblyLinearVelocity
            local groundSpeed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
            local base=goal=="run" and 23 or 16
            local desired=math.clamp(groundSpeed/base,.68,1.37)
            velocityScale+=(desired-velocityScale)*
                (1-math.exp(-math.clamp(dt,0,.07)*7))
            tracks[goal]:AdjustSpeed(velocityScale)
        end
    end)

    local dust=Instance.new("ParticleEmitter")
    dust.Name="AlnairSprintDust";dust.Texture="rbxasset://textures/particles/smoke_main.dds"
    dust.Rate=0;dust.Lifetime=NumberRange.new(.25,.65);dust.Speed=NumberRange.new(2,5)
    dust.Color=ColorSequence.new(Color3.fromRGB(181,163,130),Color3.fromRGB(119,109,92))
    dust.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.35),NumberSequenceKeypoint.new(1,2.2)})
    dust.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.35),NumberSequenceKeypoint.new(1,1)})
    dust.SpreadAngle=Vector2.new(65,35);dust.EmissionDirection=Enum.NormalId.Back
    local ground=Instance.new("Attachment",root);ground.Position=Vector3.new(0,-2.5,.5);dust.Parent=ground
    local front=Instance.new("Attachment",root);front.Position=Vector3.new(0,-2.4,-1.4)
    local brakeDust=dust:Clone();brakeDust.EmissionDirection=Enum.NormalId.Front;brakeDust.Parent=front
    local trails={}
    for _,name in ipairs({"LeftFoot","RightFoot"}) do
        local foot=character:FindFirstChild(name)
        if foot then
            local a=Instance.new("Attachment",foot);a.Position=Vector3.new(-.24,-.15,0)
            local b=Instance.new("Attachment",foot);b.Position=Vector3.new(.24,-.15,0)
            local trail=Instance.new("Trail",foot);trail.Attachment0=a;trail.Attachment1=b
            trail.Lifetime=.22;trail.Enabled=false;trail.Color=ColorSequence.new(Color3.fromRGB(231,219,188))
            trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.45),NumberSequenceKeypoint.new(1,1)})
            table.insert(trails,{trail,a,b})
        end
    end
    local previousSpeed=0
    local lastRun=-10
    local slideDirection=Vector3.zero
    local lastVelocity=Vector3.zero
    local brakeStart=-10
    local slideMover=nil
    local skidAnchor=Instance.new("Attachment")
    skidAnchor.Name="AlnairSkidAttachment"
    skidAnchor.Parent=root
    local joints={}
    for _,j in ipairs(character:GetDescendants()) do
        if j:IsA("AnimationConstraint") or j:IsA("Motor6D") then joints[j.Name]=j end
    end
    local motionFX=RunService.PreSimulation:Connect(function()
        local v=root.AssemblyLinearVelocity
        local speed=Vector3.new(v.X,0,v.Z).Magnitude
        local grounded=humanoid.FloorMaterial~=Enum.Material.Air
        local sprint=grounded and current=="run" and speed>15 and humanoid.MoveDirection.Magnitude>.1
        if sprint then lastRun=os.clock() end
        local now=os.clock()
        local stoppedSprinting=now-lastRun<.5 and not sprint
        local combatBusy=(character:GetAttribute("AlnairCombatBusyUntil") or 0)>now
        local dodgeBusy=(player:GetAttribute("AlnairDodgeUntil") or 0)>workspace:GetServerTimeNow()
        if grounded and stoppedSprinting and not combatBusy and not dodgeBusy and now-brakeStart>.6 then
            brakeStart=now
            lastRun=-10
            slideDirection=lastVelocity.Magnitude>1 and lastVelocity.Unit or root.CFrame.LookVector
            front.Position=root.CFrame:VectorToObjectSpace(slideDirection)*1.25+Vector3.new(0,-2.4,0)
            brakeDust:Emit(38)
            character:SetAttribute("AlnairBraking",true)
            if slideMover then slideMover:Destroy() end
            slideMover=Instance.new("LinearVelocity")
            slideMover.Name="AlnairSkidVelocity"
            slideMover.Attachment0=skidAnchor
            slideMover.RelativeTo=Enum.ActuatorRelativeTo.World
            slideMover.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
            slideMover.MaxForce=25000
            slideMover.VectorVelocity=slideDirection*10
            slideMover.Parent=root
        end
        previousSpeed=speed
        if speed>3 then lastVelocity=Vector3.new(v.X,0,v.Z) end
        dust.Rate=sprint and 22 or 0
        for _,entry in ipairs(trails) do entry[1].Enabled=sprint end
        local t=(os.clock()-brakeStart)/.48
        local dodgeUntil=player:GetAttribute("AlnairDodgeUntil") or 0
        local roll=1-(dodgeUntil-workspace:GetServerTimeNow())/.48
        if roll>=0 and roll<1 then
            if joints.Root then joints.Root.Transform=CFrame.Angles(-math.pi*2*roll,0,0) end
            for _,n in ipairs({"RightHip","LeftHip","RightKnee","LeftKnee"}) do if joints[n] then joints[n].Transform=CFrame.Angles(.95*math.sin(math.pi*roll),0,0) end end
            return
        end
        if t<1 and t>=0 then
            local k=math.sin(math.pi*t)
            if slideMover then
                slideMover.VectorVelocity=slideDirection*(10*(1-t)*(1-t))
            end
            local function bend(n,x,y,z) if joints[n] then joints[n].Transform=CFrame.Angles(x*k,y*k,z*k) end end
            bend("Waist",-.32,0,0);bend("RightHip",-.65,0,0);bend("LeftHip",.24,0,0)
            bend("RightKnee",.65,0,0);bend("LeftKnee",.42,0,0)
            bend("RightShoulder",.42,0,.2);bend("LeftShoulder",.42,0,-.2)
        elseif character:GetAttribute("AlnairBraking") then
            character:SetAttribute("AlnairBraking",false)
            if slideMover then slideMover:Destroy();slideMover=nil end
        end
    end)
    activeCleanup=function()
        if not alive then return end
        alive=false
        connection:Disconnect()
        motionFX:Disconnect();ground:Destroy();front:Destroy()
        if slideMover then slideMover:Destroy() end
        skidAnchor:Destroy()
        for _,entry in ipairs(trails) do for _,obj in ipairs(entry) do obj:Destroy() end end
        stockPlayback:Disconnect()
        for _,track in pairs(tracks) do
            pcall(function()track:Stop(.12);track:Destroy()end)
        end
        if nativeAnimate and nativeAnimate.Parent and originalAnimateEnabled then
            nativeAnimate.Enabled=true
        end
        if character.Parent then character:SetAttribute("AlnairMotion",nil) end
    end
end
player.CharacterAdded:Connect(function(char)
    task.spawn(attach,char)
end)
player.CharacterRemoving:Connect(function()
    if activeCleanup then activeCleanup();activeCleanup=nil end
end)
if player.Character then task.spawn(attach,player.Character) end
