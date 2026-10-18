local BLOCKED_EFFECTS = {
    ["eff_jack_hmcd_blood"] = true,
    ["BloodImpact"]         = true,
}

if not util._hmcdOriginalEffect then
    util._hmcdOriginalEffect = util.Effect
end
local oldEffect = util._hmcdOriginalEffect

function util.Effect(name, data, allowOverride, ignorePrediction)
    if isstring(name) and BLOCKED_EFFECTS[name] then
        return
    end
    return oldEffect(name, data, allowOverride, ignorePrediction)
end

if SERVER then
    local BLOOD_DMG_MASK = bit.bor(DMG_BULLET, DMG_BUCKSHOT, DMG_SLASH, DMG_SNIPER)

    local BLOOD_PARTICLE = "blood_impact_red_01"
    local BLOOD_DECAL    = "Blood"


    local lastHit = setmetatable({}, { __mode = "k" })

    local function IsBloodTarget(ent)
        return ent:IsPlayer() or ent:IsRagdoll() or ent:IsNPC() or ent:IsNextBot()
    end

    hook.Add("EntityTakeDamage", "HMCD_HL2_Blood", function(ent, dmg)
        if not IsValid(ent) then return end
        if not IsBloodTarget(ent) then return end
        if not dmg:IsDamageType(BLOOD_DMG_MASK) then return end
        if dmg:GetDamage() < 1 then return end

        local pos = dmg:GetDamagePosition()
        if not pos or pos:LengthSqr() < 0.01 then
            pos = ent:WorldSpaceCenter()
        end

        local dir = dmg:GetDamageForce():GetNormalized()
        if dir:LengthSqr() < 0.01 then
            local attacker = dmg:GetAttacker()
            if IsValid(attacker) then
                dir = (pos - attacker:GetPos()):GetNormalized()
            else
                dir = Vector(0, 0, 1)
            end
        end

        local now = CurTime()
        if (lastHit[ent] or 0) + 0.03 > now then return end
        lastHit[ent] = now


        ParticleEffect(BLOOD_PARTICLE, pos, dir:Angle())


        local tr = util.TraceLine({
            start  = pos,
            endpos = pos + dir * 100,
            mask   = MASK_SOLID_BRUSHONLY,
        })
        if tr.Hit and not tr.HitSky then
            util.Decal(BLOOD_DECAL, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
        end
    end)


    hook.Add("EntityRemoved", "HMCD_HL2_Blood_Cleanup", function(ent)
        lastHit[ent] = nil
    end)
end