--!strict
-- Animacao original de R6 com valores numericos puros, sem AnimationIds
-- pagos nem dependencias de terceiros. Facilita testes no servidor via Lune.
local Motion={}

local function clamp(x,lower,upper)
    return math.max(lower,math.min(upper,x))
end

function Motion.blend(current,goal,dt,rate)
    local alpha=1-math.exp(-clamp(dt,0,.10)*(rate or 10))
    return current+(goal-current)*alpha
end

function Motion.sample(input)
    local moving=clamp(input.moving or 0,0,1)
    local sprint=input.sprint==true
    local grounded=input.grounded~=false
    local phase=input.phase or 0
    local idleTime=input.idleTime or 0
    local land=clamp(input.landing or 0,0,1)
    local velocityY=clamp(input.velocityY or 0,-90,90)
    local strafe=clamp(input.strafe or 0,-1,1)
    local cameraY=clamp(input.cameraY or 0,-1,1)
    local native=input.native==true
    -- When Roblox's default Animate is already running, this is only an
    -- additive detail layer. When Animate is absent, pose the full R6 rig.
    local strength=native and .32 or 1
    local stride=math.sin(phase)
    local oppose=math.sin(phase+math.pi)
    local pace=sprint and 1.16 or 1
    local step=grounded and moving or 0
    local legAmplitude=(sprint and .66 or .48)*step*strength
    local armAmplitude=(sprint and .59 or .37)*step*strength
    local idleBreath=(.014*math.sin(idleTime*1.6)+.010*math.sin(idleTime*.62))*strength
    local airborne=not grounded
    local jump=airborne and clamp(velocityY/19,0,1) or 0
    local fall=airborne and clamp(-velocityY/20,0,1) or 0
    local airborneStrength=airborne and strength or 0
    local sprintLean=sprint and moving or 0
    local bodyPitch=(-.045*moving-.055*sprintLean-.025*jump+.030*fall)*strength
    local bodyRoll=clamp(-strafe*.115*moving,-.115,.115)*strength
    local dip=(math.abs(stride)*.032*step-land*.085)*strength
    local idleArm=.07*strength
    local rightArm=oppose*armAmplitude+idleArm+(.16*jump+.11*fall)*airborneStrength
    local leftArm=stride*armAmplitude-idleArm+(.16*jump+.11*fall)*airborneStrength
    local rightHip=stride*legAmplitude- .25*jump*airborneStrength + .17*fall*airborneStrength
    local leftHip=oppose*legAmplitude+ .18*jump*airborneStrength + .16*fall*airborneStrength

    return {
        rightShoulder=rightArm,
        leftShoulder=leftArm,
        rightHip=rightHip,
        leftHip=leftHip,
        rootPitch=bodyPitch+idleBreath*.3,
        rootRoll=bodyRoll,
        rootBob=dip,
        neckPitch=clamp(-cameraY*.075,-.075,.075)*strength-idleBreath*.5,
        shoulderRoll=(.065+.040*sprintLean)*strength,
        landed=land*.03*strength,
        moving=moving,
        sprint=sprint,
        grounded=grounded,
        mode=(not grounded and (velocityY>=0 and "jump" or "fall"))
            or (land>.15 and "land")
            or (moving<.12 and "idle")
            or (sprint and "sprint" or "walk"),
        pace=pace,
    }
end

return Motion
