local RS=game:GetService("RunService")
local TS=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local remote=game.ReplicatedStorage:WaitForChild("AlnairGame"):WaitForChild("CombatFX")
local colors={warrior=Color3.fromRGB(255,198,100),samurai=Color3.fromRGB(120,220,255),assassin=Color3.fromRGB(210,90,255),fighter=Color3.fromRGB(255,125,65),mage=Color3.fromRGB(105,160,255),enemy=Color3.fromRGB(255,55,45)}
local function part(pos,color,size)
 local p=Instance.new("Part");p.Name="AlnairCombatFX";p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Color=color;p.Size=size;p.CFrame=CFrame.new(pos);p.Parent=workspace;Debris:AddItem(p,2);return p
end
local function fade(p,d,size)
 TS:Create(p,TweenInfo.new(d,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=1,Size=size}):Play();Debris:AddItem(p,d+.05)
end
local function burst(pos,color,power)
 local p=part(pos,color,Vector3.one*1.4);p.Shape=Enum.PartType.Ball;fade(p,.32,Vector3.one*power)
 local ring=part(pos,color,Vector3.new(.12,2,2));ring.Shape=Enum.PartType.Cylinder;ring.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2);fade(ring,.45,Vector3.new(.08,power*1.6,power*1.6))
 local light=Instance.new("PointLight");light.Color=color;light.Range=power*2;light.Brightness=3;light.Parent=p;TS:Create(light,TweenInfo.new(.25),{Brightness=0}):Play()
 local e=Instance.new("ParticleEmitter");e.Texture="rbxasset://textures/particles/sparkles_main.dds";e.Color=ColorSequence.new(color,Color3.new(1,1,1));e.LightEmission=1;e.Lifetime=NumberRange.new(.25,.65);e.Speed=NumberRange.new(9,24);e.SpreadAngle=Vector2.new(180,180);e.Rate=0;e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.55),NumberSequenceKeypoint.new(1,0)});e.Parent=p;e:Emit(30)
end
local function arc(cf,color,step,scale)
 -- The particle blade is drawn along the same plane as the R15 body strike.
 local last
 for i=0,24 do
  local t=i/24
  local a=-1.32+t*2.64
  local x,y,z
  if step==1 then -- flat horizontal cut
   x=math.sin(a)*scale;y=1.9+math.sin(math.pi*t)*.16;z=-math.cos(a)*scale
  elseif step==2 then -- left-to-right ascending diagonal cut
   x=math.sin(a)*scale;y=.8+t*3.5;z=-math.cos(a)*scale
  else -- overhead vertical downward slash
   x=math.sin(a)*.42;y=5.2-t*4.2;z=-math.cos(a)*scale*.86
  end
  local pos=cf:PointToWorldSpace(Vector3.new(x,y,z))
  if last then
   local mid=(last+pos)/2
   local p=part(mid,color,Vector3.new(.18,.5,(pos-last).Magnitude+.15))
   p.CFrame=CFrame.lookAt(mid,pos)
   fade(p,.3,Vector3.new(.025,.07,p.Size.Z))
  end
  last=pos
  if i%4==0 then task.wait(.008) end
 end
end
local function projectile(cf,target,color,step)
 local start=cf:PointToWorldSpace(Vector3.new(1.4,2,-2))
 local control=(start+target)/2+Vector3.new(0,8+step*2,0)+cf.RightVector*(step==2 and -8 or 8)
 local p=part(start,color,Vector3.one*.8);p.Shape=Enum.PartType.Ball
 local a=Instance.new("Attachment",p);a.Position=Vector3.new(0,.45,0)
 local b=Instance.new("Attachment",p);b.Position=Vector3.new(0,-.45,0)
 local trail=Instance.new("Trail");trail.Attachment0=a;trail.Attachment1=b;trail.Color=ColorSequence.new(Color3.new(1,1,1),color);trail.Lifetime=.35;trail.LightEmission=1;trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.05),NumberSequenceKeypoint.new(1,1)});trail.Parent=p
 local glow=Instance.new("PointLight",p);glow.Color=color;glow.Range=12;glow.Brightness=2
 local begin=os.clock()
 while p.Parent do
  local t=math.min(1,(os.clock()-begin)/.65);local u=1-t
  p.Position=start*u*u+control*2*u*t+target*t*t
  if t>=1 then break end
  RS.Heartbeat:Wait()
 end
 p.Transparency=1;glow.Enabled=false;burst(target,color,step==3 and 12 or 8);Debris:AddItem(p,.4)
end
local active={}
local function pose(char,class,step)
 if not char then return end
 local token={};active[char]=token
 local joints={}
 for _,joint in ipairs(char:GetDescendants()) do
  if joint:IsA("Motor6D") or joint:IsA("AnimationConstraint") then joints[joint.Name]=joint end
 end
 local duration=class=="mage" and .82 or class=="assassin" and .43
  or class=="fighter" and .46 or .61
 local started=os.clock()
 char:SetAttribute("AlnairCombatBusyUntil",started+duration)
 local conn
 conn=RS.PreSimulation:Connect(function()
  local t=(os.clock()-started)/duration
  if t>=1 or active[char]~=token or not char.Parent then
   conn:Disconnect()
   if active[char]==token then
    active[char]=nil
    for _,joint in pairs(joints) do pcall(function()joint.Transform=CFrame.identity end) end
   end
   return
  end
  -- Three actual trajectories: flat, diagonal and overhead/downward.
  local weight=math.sin(math.pi*t)
  local progress=math.clamp((t-.15)/.67,0,1)
  progress=progress*progress*(3-2*progress)
  local side=(step==2) and -1 or 1
  local travel=(1-2*progress)*weight
  local function j(name,x,y,z)
   local joint=joints[name]
   if joint then joint.Transform=CFrame.Angles(x,y,z) end
  end
  local waistYaw=side*travel*.58
  j("Root",-.12*weight,side*travel*.16,-side*.08*weight)
  j("Waist",-.18*weight,waistYaw,side*travel*.22)
  j("Neck",.08*weight,-waistYaw*.4,0)
  j("RightHip",-.31*weight,0,.12*weight)
  j("LeftHip",.26*weight,0,-.12*weight)
  j("RightKnee",.33*weight,0,0)
  j("LeftKnee",.25*weight,0,0)
  j("RightAnkle",-.14*weight,0,0)
  j("LeftAnkle",-.12*weight,0,0)
  if class=="mage" then
   -- Staff follows a diagonal sweep toward the casting target; no overhead
   -- vertical arm lift fighting a diagonal flying magic projectile.
   j("RightShoulder",-.94*weight,-.4*side*weight,(-.85+1.55*progress)*weight)
   j("LeftShoulder",-.92*weight,.24*side*weight,(-.3+.7*progress)*weight)
   j("RightElbow",-.45*weight,0,.2*weight)
   j("LeftElbow",-.68*weight,0,-.14*weight)
   j("RightWrist",-.28*weight,.25*weight,0)
  elseif class=="fighter" or class=="assassin" then
   local swap=(step==2)
   local rightPower=swap and .48 or 1
   local leftPower=swap and 1 or .48
   j("RightShoulder",-(.4+.95*progress)*weight*rightPower,0,(travel*.9)*rightPower)
   j("LeftShoulder",-(.4+.95*progress)*weight*leftPower,0,(-travel*.9)*leftPower)
   j("RightElbow",-(1.12-.75*progress)*weight*rightPower,0,0)
   j("LeftElbow",-(1.12-.75*progress)*weight*leftPower,0,0)
   j("RightWrist",-.2*rightPower*weight,0,0)
   j("LeftWrist",-.2*leftPower*weight,0,0)
  elseif step==1 then
   -- A broad LEFT-to-RIGHT horizontal blade sweep.
   j("RightShoulder",-1.15*weight,0,1.15*travel)
   j("RightElbow",-.58*weight,0,.12*weight)
   j("LeftShoulder",-.53*weight,-.22*weight,-.25*weight)
   j("LeftElbow",-.76*weight,0,0)
  elseif step==2 then
   -- Diagonal rising strike: arm and torso roll together with the FX.
   j("RightShoulder",-1.38*weight,-.3*weight,(-.95+1.85*progress)*weight)
   j("RightElbow",-.68*weight,0,.16*weight)
   j("LeftShoulder",-.56*weight,0,-.3*weight)
   j("LeftElbow",-.8*weight,0,0)
   j("Waist",-.16*weight,-.45*travel,.3*travel)
  else
   -- Overhead chop: high windup then forward/downward follow-through.
   j("RightShoulder",(-2.35+1.95*progress)*weight,0,.18*weight)
   j("RightElbow",(-.95+.65*progress)*weight,0,0)
   j("LeftShoulder",-.6*weight,0,-.25*weight)
   j("LeftElbow",-.8*weight,0,0)
   j("Waist",(-.32+.42*progress)*weight,.1*travel,0)
  end
 end)
end
remote.OnClientEvent:Connect(function(char,class,step,cf,target)
 if typeof(cf)~="CFrame" or typeof(target)~="Vector3" then return end
 local cam=workspace.CurrentCamera;if cam and (cam.CFrame.Position-cf.Position).Magnitude>180 then return end
 local color=colors[class] or colors.warrior
 pose(char,class,step)
 if class=="mage" then
  task.delay(.16,function()task.spawn(projectile,cf,target,color,step)end)
  if step==3 then
   task.delay(.16,function()
    task.spawn(projectile,cf*CFrame.new(-1.5,0,0),target,Color3.fromRGB(170,110,255),2)
    task.spawn(projectile,cf*CFrame.new(1.5,0,0),target,Color3.fromRGB(100,235,255),1)
   end)
   task.delay(.83,function()
    burst(target,color,18)
    task.spawn(arc,CFrame.new(target),color,3,10)
   end)
  end
 else
  task.delay(.15,function()
   task.spawn(arc,cf,color,step,class=="fighter" and 3 or class=="assassin" and 4 or 6)
  end)
  task.delay(.27,function()
   local impact=target
   if (impact-cf.Position).Magnitude>16 then
    impact=cf.Position+cf.LookVector*(class=="fighter" and 3 or 5)+Vector3.new(0,1,0)
   end
   burst(impact,color,step==3 and 8 or 4)
  end)
 end
end)

local player=game.Players.LocalPlayer
local gui=Instance.new("ScreenGui");gui.Name="AlnairComboHUD";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local label=Instance.new("TextLabel");label.Name="HitCombo";label.AnchorPoint=Vector2.new(0,.5);label.Position=UDim2.fromScale(.035,.43);label.Size=UDim2.fromOffset(210,70);label.BackgroundTransparency=1;label.TextXAlignment=Enum.TextXAlignment.Left;label.Font=Enum.Font.GothamBlack;label.TextSize=32;label.TextColor3=Color3.fromRGB(255,215,135);label.TextStrokeTransparency=.45;label.Parent=gui
RS.RenderStepped:Connect(function()
 local remaining=(player:GetAttribute("AlnairComboUntil") or 0)-workspace:GetServerTimeNow()
 local count=player:GetAttribute("AlnairHitCombo") or 0
 label.Visible=remaining>0 and count>0
 label.Text=tostring(count).."x COMBO"
 label.TextTransparency=1-math.clamp(remaining/.55,0,1)
 label.TextStrokeTransparency=.45+.55*label.TextTransparency
end)
