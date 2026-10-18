if not blood_drop then
    blood_drop = {
        "bleeding/bleeding1.wav",
        "bleeding/bleeding2.wav",
        "bleeding/bleeding3.wav",
        "bleeding/bleeding4.wav",
    }
end

if SERVER then
    util.AddNetworkString("blyadinagoviadina")
    util.AddNetworkString("blyadinagoviadina2")
    util.AddNetworkString("blyadmist2")

    hook.Add("EntityTakeDamage", "vafli_em2", function(ply, dmginfo, hggg)
        ply:SetBloodColor(DONT_BLEED)
        if dmginfo:IsBulletDamage() and (ply:IsRagdoll() or ply:IsPlayer() or ply:IsNPC()) then
            net.Start("blyadinagoviadina")
                net.WriteVector(dmginfo:GetDamagePosition())
                net.WriteVector(dmginfo:GetDamageForce():GetNormalized())
                net.WriteFloat(dmginfo:GetDamage())
            net.Broadcast()
        end
    end)
end

local BleedBoneMap = {
    ["right_hand"] = "ValveBiped.Bip01_R_Hand",
    ["left_hand"]  = "ValveBiped.Bip01_L_Hand",
    ["right_arm"]  = "ValveBiped.Bip01_R_Forearm",
    ["left_arm"]   = "ValveBiped.Bip01_L_Forearm",
    ["right_leg"]  = "ValveBiped.Bip01_R_Thigh",
    ["left_leg"]   = "ValveBiped.Bip01_L_Thigh",
    ["stomach"]    = "ValveBiped.Bip01_Spine1",
    ["chest"]      = "ValveBiped.Bip01_Spine2",
    ["head"]       = "ValveBiped.Bip01_Head1",
    ["neck"]       = "ValveBiped.Bip01_Neck1",
}

local function GetBleedPos(ply, limb)
    local bonename = BleedBoneMap[limb]
    if not bonename then return nil end

    local function tryGetBone(ent)
        if not IsValid(ent) then return nil end
        local bone = ent:LookupBone(bonename)
        if not bone or bone <= 0 then return nil end
        return ent:GetBonePosition(bone)
    end

    local rag = IsValid(ply) and ply:GetNWEntity("Ragdoll") or nil
    local pos, ang = tryGetBone(rag)
    if pos then return pos, ang end

    pos, ang = tryGetBone(ply)
    if pos then return pos, ang end

    if IsValid(ply) then
        return ply:WorldSpaceCenter()
    end
    return nil
end

if CLIENT then
    net.Receive("blyadinagoviadina", function()
        local pos = net.ReadVector()
        local dir = net.ReadVector()
        local dmg = net.ReadFloat()

        if not dir or dir == Vector(0, 0, 0) then dir = Vector(0, 0, -1) end

        local emitter = ParticleEmitter(pos)
        if not emitter then return end

        local count = math.Clamp(math.floor(dmg / 4), 10, 250)
        for i = 1, count do
            local part = emitter:Add("decals/blood" .. math.random(1, 7), pos + dir * 1.5)
            if part then
                local speed = dmg * 2 + math.Rand(70, 120)
                local spread = 0.02 + (dmg / 700)
                local vel = dir * speed + VectorRand() * (speed * spread)

                part:SetVelocity(vel)
                part:SetDieTime(10)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)
                part:SetStartSize(math.Clamp(1 + (dmg / 12), 1, 4))
                part:SetGravity(Vector(0, 0, -450))
                part:SetAirResistance(10)
                part:SetCollide(true)
                part:SetRoll(math.Rand(0, 360))
                part:SetRollDelta(math.Rand(-20, 20))

                local decalSize = math.Clamp(dmg, 1, 3)
                part:SetCollideCallback(function(p, hitpos, hitnormal)
                    util.DecalEx(Material("decals/blood" .. math.random(1, 7)), game.GetWorld(),
                        hitpos + hitnormal, VectorRand() * 360, Color(40, 0, 0), decalSize / 10, decalSize / 10)
                    p:SetDieTime(0)
                end)
            end
        end

        local entryCount = math.Clamp(math.floor(dmg / 6), 5, 10)
        for i = 1, entryCount do
            local part = emitter:Add("decals/blood" .. math.random(1, 7), pos)
            if part then
                local speed = math.random(20, 80)
                local vel = -dir * speed + VectorRand() * (speed * 0.1)

                part:SetVelocity(vel)
                part:SetDieTime(10)
                part:SetStartAlpha(200)
                part:SetEndAlpha(0)
                part:SetStartSize(math.Rand(1, 3))
                part:SetEndSize(0)
                part:SetGravity(Vector(0, 0, -600))
                part:SetAirResistance(40)
                part:SetCollide(true)
                part:SetColor(60, 0, 0)

                local decalSize = math.Clamp(dmg / 1.1, 0.5, 2)
                part:SetCollideCallback(function(p, hitpos, hitnormal)
                    util.DecalEx(Material("decals/blood" .. math.random(1, 7)), game.GetWorld(),
                        hitpos + hitnormal, VectorRand() * 360, Color(40, 0, 0), decalSize / 10, decalSize / 10)
                    p:SetDieTime(0)
                end)
            end
        end

        emitter:Finish()
    end)

    net.Receive("blyadinagoviadina2", function()
        local pos = net.ReadVector()
        local dir = net.ReadVector()

        if not dir or dir == Vector(0, 0, 0) then dir = Vector(0, 0, -1) end

        local emitter = ParticleEmitter(pos)
        if not emitter then return end

        for i = 1, math.random(50, 100) do
            local part = emitter:Add("decals/blood" .. math.random(1, 7), pos + dir * 1.5)
            if part then
                local speed = math.Rand(10, 40)
                local spread = math.Rand(10, 20)
                local vel = dir * speed + VectorRand() * (speed * spread)
                part:SetVelocity(vel)
                part:SetDieTime(10)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)
                part:SetStartSize(math.Rand(12, 19))
                part:SetGravity(Vector(0, 0, -350))
                part:SetAirResistance(10)
                part:SetCollide(true)
                part:SetRoll(math.Rand(0, 360))
                part:SetRollDelta(math.Rand(-20, 20))

                local decalSize = math.Rand(3, 5)
                part:SetCollideCallback(function(p, hitpos, hitnormal)
                    util.DecalEx(Material("decals/blood" .. math.random(1, 7)), game.GetWorld(),
                        hitpos + hitnormal, VectorRand() * 360, Color(40, 0, 0), decalSize / 4, decalSize / 4)
                    p:SetDieTime(0)
                    if blood_drop then
                        sound.Play(table.Random(blood_drop), hitpos, 55, 100, 1)
                    end
                end)
            end
        end

        emitter:Finish()
    end)

    net.Receive("blyadmist2", function()
        local pos = net.ReadVector()

        local emitter = ParticleEmitter(pos)
        if not emitter then return end
        for i = 1, math.random(175, 190) do
            local part = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos + VectorRand() * 25)
            if part then
                part:SetVelocity(VectorRand() * 30 + Vector(0, 0, math.Rand(-10, 30)))
                part:SetDieTime(30)
                part:SetStartAlpha(20)
                part:SetEndAlpha(45)
                part:SetColor(70, 0, 0)
                part:SetStartSize(math.Rand(30, 35))
                part:SetGravity(Vector(0, 0, -35))
                part:SetAirResistance(10)
                part:SetCollide(true)
                part:SetRoll(math.Rand(0, 360))
                part:SetRollDelta(math.Rand(-1, 1))
            end
        end
        emitter:Finish()

        local emitter2 = ParticleEmitter(pos)
        if not emitter2 then return end
        for i = 1, math.random(185, 190) do
            local part = emitter2:Add("particle/smokesprites_000" .. math.random(1, 9), pos + VectorRand() * 25)
            if part then
                part:SetVelocity(VectorRand() * 50 + Vector(0, 0, math.Rand(-10, 30)))
                part:SetDieTime(15)
                part:SetStartAlpha(40)
                part:SetEndAlpha(85)
                part:SetColor(70, 0, 0)
                part:SetStartSize(math.Rand(40, 45))
                part:SetGravity(Vector(0, 0, -35))
                part:SetAirResistance(1)
                part:SetCollide(true)
                part:SetRoll(math.Rand(0, 360))
                part:SetRollDelta(math.Rand(-0.5, 0.5))
            end
        end
        emitter2:Finish()
    end)

    net.Receive("hmcdnbleed", function()
        local ply         = net.ReadEntity()
        local limb        = net.ReadString()
        local fallbackPos = net.ReadVector()

        local pos, boneAng = GetBleedPos(ply, limb)
        if not pos then pos = fallbackPos end
        if not pos then return end

        local dir
        if boneAng then
            dir = boneAng:Forward() + Vector(0, 0, -0.5)
        else
            dir = Vector(0, 0, -1)
        end
        dir:Normalize()

        local spawnPos = pos + Vector(0, 0, 5) + dir * 15

        local emitter = ParticleEmitter(spawnPos)
        if not emitter then return end

        for i = 1, math.random(2, 4) do
            local part = emitter:Add("effects/blood_drop", spawnPos + VectorRand() * 3)
            if part then
                part:SetVelocity(dir * math.Rand(50, 110) + VectorRand() * 20)
                part:SetDieTime(8)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)
                part:SetStartSize(math.Rand(3, 5))
                part:SetEndSize(math.Rand(1, 2))
                part:SetGravity(Vector(0, 0, -700))
                part:SetAirResistance(10)
                part:SetCollide(true)
                part:SetRoll(math.Rand(-20, 20))
                part:SetRollDelta(math.Rand(-5, 5))
                part:SetCollideCallback(function(p, hitpos, hitnormal)
                    util.DecalEx(Material("decals/blood" .. math.random(1, 7)), game.GetWorld(),
                        hitpos + hitnormal, VectorRand() * 360, Color(40, 0, 0), math.Rand(0.1, 0.2), math.Rand(0.1, 0.2))
                    p:SetDieTime(0)
                end)
            end
        end

        emitter:Finish()
    end)
end