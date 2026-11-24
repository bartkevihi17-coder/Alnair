--!strict
-- Alnair: server-authoritative geometry checks for combat.
-- Kept separate from NPC visuals so it can execute in the VPS test harness.
local CombatChecks={}

function CombatChecks.facing(lookForward,planarDirection,multi)
    if not lookForward or not planarDirection then return false end
    if planarDirection.Magnitude<1 then return true end
    local threshold=multi and -.15 or .20
    return lookForward:Dot(planarDirection.Unit)>threshold
end

function CombatChecks.clearPath(world,from,to,attacker,defender,enemyFolder)
    if not world or not from or not to then return false end
    local direction=to-from
    if direction.Magnitude<.1 then return true end
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.IgnoreWater=true
    local excluded={}
    if attacker then table.insert(excluded,attacker) end
    if defender then table.insert(excluded,defender) end
    if enemyFolder then table.insert(excluded,enemyFolder) end
    params.FilterDescendantsInstances=excluded
    -- The caller must exclude both combatants but allow the world (solid
    -- buildings and dungeon walls) to block combat.
    return world:Raycast(from,direction,params)==nil
end

return CombatChecks
