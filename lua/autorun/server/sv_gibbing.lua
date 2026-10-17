local plym = FindMetaTable("Player")

local gibs = {
    //"models/gore/gorehead.mdl",
    "models/gore/head_eye01.mdl", "models/gore/head_eye02.mdl", "models/gore/head_headbitbackright.mdl", "models/gore/head_headbitfrontright.mdl", "models/gore/head_headbitfrontleft.mdl", "models/gore/head_headbitbackleft.mdl", "models/gore/head_headbittopright.mdl",
 
    "models/gore/uppertorso.mdl",
    "models/gore/uppertorso_boneslowerleft.mdl",
    "models/gore/rleg_meatbit004r.mdl",
    "models/gore/rleg_meatbit003r.mdl",
    "models/gore/rleg_meatbit002r.mdl",
    "models/gore/rleg_meatbit001r.mdl",
    "models/gore/rleg_legpartfootr001.mdl",
    "models/gore/pelvis.mdl",
    "models/gore/lleg_meatbit001l.mdl",
    "models/gore/lleg_legpartmidl.mdl",
    "models/gore/lleg_legpartfootl002.mdl",
    "models/gore/larm_armgoreupperl.mdl",
    "models/gore/larm_armgorehandl.mdl",
    "models/gore/rarm_armgorehandr.mdl",
    "models/gore/larm_armgorelowerl.mdl",
    "models/gore/rarm_armgoreupperr.mdl",
    "models/gore/rleg_legpartfootr002.mdl",
    "models/gore/rleg_meatbit001r.mdl",
}

local debrisgibs = {
    "models/gore/debris_goredebris01.mdl",
    "models/gore/debris_goredebris02.mdl",
    "models/gore/debris_goredebris03.mdl",
    "models/gore/debris_goredebris04.mdl",
    "models/gore/debris_goredebris01.mdl",
    "models/gore/debris_goredebris02.mdl",
    "models/gore/debris_goredebris03.mdl",
    "models/gore/debris_goredebris04.mdl",
    "models/gore/debris_goredebris01.mdl",
    "models/gore/debris_goredebris02.mdl",
    "models/gore/debris_goredebris03.mdl",
    "models/gore/debris_goredebris04.mdl",
    "models/gore/debris_goredebris01.mdl",
    "models/gore/debris_goredebris02.mdl",
    "models/gore/debris_goredebris03.mdl",
    "models/gore/debris_goredebris04.mdl"    
}

for _, model in ipairs(gibs) do util.PrecacheModel(model) end
for _, model in ipairs(debrisgibs) do util.PrecacheModel(model) end

local function SpawnGibs(pos, vel, dir, bblood)
    dir = dir or ((isvector(vel) and vel:LengthSqr() > 1) and vel:GetNormalized() or VectorRand())

    if bblood then
        net.Start("blyadinagoviadina2")
            net.WriteVector(pos + Vector(0, 0, 20))
            net.WriteVector(dir * 5)
        net.Broadcast()
        net.Start("blyadmist2")
            net.WriteVector(pos)
        net.Broadcast()
    end

    for _, model in ipairs(gibs) do
        local gib = ents.Create("prop_physics")
        if IsValid(gib) then
            gib:SetModel(model)
            gib:SetPos(pos + VectorRand(-2, 2))
            gib:SetAngles(AngleRand())
            gib:Spawn()

            local phys = gib:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(vel + VectorRand(-0, 0) + Vector(0, 0, 1))
                phys:AddAngleVelocity(VectorRand(-20, 20))
            end
            gib:AddCallback("PhysicsCollide", function(ent, data)
                if data.Speed > 150 then
                    local hitpos = data.HitPos
                    local hitnormal = data.HitNormal
                    net.Start("blyadinagoviadina")
                        net.WriteVector(hitpos)
                        net.WriteVector(VectorRand() * 1)
                        net.WriteFloat(6)
                    net.Broadcast()
                end
            end)
        end
    end

    for _, model in ipairs(debrisgibs) do
        local debris = ents.Create("prop_physics")
        if IsValid(debris) then
            debris:SetModel(model)
            debris:SetPos(pos + VectorRand(-20, 20))
            debris:SetAngles(AngleRand())
            debris:Spawn()

            debris:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

            local phys = debris:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(vel * 1.2 + VectorRand(-100, 100))
            end
        end
    end
end

local tbl11 = {
    "pelvissmash.mp3",
    "headsmash.mp3",
    "limbrip1.mp3"
}

function plym:Razobrat(bool_blood, vec_velocity, vec_dir, posOverride) //lego
    local pos = posOverride or (self:GetPos() + Vector(0, 0, 40))
    local vel = vec_velocity or self:GetVelocity() or Vector()
    self:EmitSound("flesh-impact.mp3", 130, math.random(95,105))
    self:EmitSound(tbl11[math.random(1,#tbl11)], 130, math.random(95,105))
    SpawnGibs(pos, vel, vec_dir, bool_blood or false)
    self:KillSilent()
end

concommand.Add("hmcd_razobrat", function(ply, cmd, args)
    if !ply:IsAdmin() then return end
    if args[1] == "@" then ply:GetEyeTrace().Entity:Razobrat(true) else ply:Razobrat(true) end
end)

local function FindRagOwner(rag)
    local owner = RagdollOwner(rag)
    if IsValid(owner) and owner:IsPlayer() then return owner end

    owner = rag:GetNWEntity("RagdollController")
    if IsValid(owner) and owner:IsPlayer() then return owner end

    for _, pl in ipairs(player.GetAll()) do
        if pl:GetNWEntity("Ragdoll") == rag then return pl end
    end

    return nil
end

hook.Add("PostEntityTakeDamage", "IMAFUCKINGBRICKCHARACTERSMASHMYHEADWITHASLEDGEHAMMERMARIO", function(ent, dmginfo)
    if not IsValid(ent) then return end

    local dtype = dmginfo:GetDamageType()
    if !dtype == 64 then return end

    local dmg = dmginfo:GetDamage()
    local isExplosion = bit.band(dtype, 64) ~= 0 or bit.band(dtype, 134217728) ~= 0

    if not (isExplosion and (dmg >= 270 or (dmg >= 50 and dmginfo:GetDamagePosition():Distance(ent:GetPos() + Vector(0, 0, 40)) <= 120))) then 
        return 
    end

    local attacker = dmginfo:GetAttacker()
    local inflictor = dmginfo:GetInflictor()

    local function CalcDir(fromPos)
        local origin = dmginfo:GetDamagePosition()
        if not origin or origin == vector_origin then
            origin = IsValid(inflictor) and inflictor:GetPos() or (IsValid(attacker) and attacker:GetPos() or fromPos)
        end

        local d = fromPos - origin
        if d:LengthSqr() < 1 then return VectorRand() end
        return d:GetNormalized()
    end

    local force = math.Clamp(dmg, 110, 220)
    local function CalcVel(dir)
        return dir * force
    end

    if ent:IsPlayer() then
        if ent:GetNWBool("Spectating", false) then return end

        local dir = CalcDir(ent:GetPos())

        if IsValid(attacker) and attacker:IsPlayer() then
            ent.LastAttacker = attacker
        end
        ent.LastDamageType = dtype

        ent:Razobrat(true, CalcVel(dir), dir)
        return true
    end

    if ent:GetClass() ~= "prop_ragdoll" then return end

    local ragPos = ent:GetPos() + Vector(0, 0, 40)
    local dir = CalcDir(ragPos)
    local vel = CalcVel(dir)

    local owner = FindRagOwner(ent)

    if owner and owner:Alive() and not owner:GetNWBool("Spectating", false) then
        if IsValid(attacker) and attacker:IsPlayer() then
            owner.LastAttacker = attacker
        end
        owner.LastDamageType = dtype

        owner:Razobrat(true, vel, dir, ragPos)

        timer.Simple(0, function()
            if IsValid(ent) then ent:Remove() end
        end)
    else
        SpawnGibs(ragPos, vel, dir, true)
        ent:Remove()
    end

    return true
end)
