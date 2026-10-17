if SERVER then
    util.AddNetworkString("blyadinagoviadina")
    util.AddNetworkString("blyadinagoviadina2")
    util.AddNetworkString("blyadmist2")

    hook.Add("EntityTakeDamage", "vafli_em2", function(ply, dmginfo, hggg)//HOOK_UNION_Damage - govno!
        //print(123) 
        ply:SetBloodColor(DONT_BLEED) //navsiakiy
        if dmginfo:IsBulletDamage() and (ply:IsRagdoll() or ply:IsPlayer() or ply:IsNPC()) then

        net.Start("blyadinagoviadina")
            net.WriteVector(dmginfo:GetDamagePosition())
            net.WriteVector(dmginfo:GetDamageForce():GetNormalized())
            net.WriteFloat(dmginfo:GetDamage())
        net.Broadcast()
        end
    end)
end
if CLIENT then
    net.Receive("blyadinagoviadina", function()
        local pos = net.ReadVector()
        local dir = net.ReadVector()
        local dmg = net.ReadFloat()

        if not dir or dir == Vector(0,0,0) then
            dir = Vector(0, 0, -1)
        end

        local emitter = ParticleEmitter(pos)
        if not emitter then return end

        local count = math.Clamp(math.floor(dmg / 4), 10, 250)
        for i = 1, count do
            local part = emitter:Add("decals/blood" .. math.random(1,7), pos + dir * 1.5)
            if part then
                local speed = dmg * 2 + math.Rand(70,120)
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
                part:SetCollideCallback( function( p, hitpos, hitnormal )
                    util.DecalEx(Material("decals/blood" .. math.random(1,7)), game.GetWorld(), hitpos + hitnormal, VectorRand() * 360, Color(40, 0, 0), decalSize / 10, decalSize / 10)
                    p:SetDieTime( 0 )
                end)
            end
        end

        local entryCount = math.Clamp(math.floor(dmg / 6), 5, 10)
        for i = 1, entryCount do            
            local part = emitter:Add("decals/blood" .. math.random(1,7), pos)
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
                part:SetCollideCallback( function( p, hitpos, hitnormal )
                    util.DecalEx(Material("decals/blood" .. math.random(1,7)), game.GetWorld(), hitpos + hitnormal, VectorRand() * 360, Color(40, 0, 0), decalSize / 10, decalSize / 10)
                    p:SetDieTime( 0 )
                end)
            end
        end

        emitter:Finish()
    end)
    net.Receive("blyadinagoviadina2", function()
        local pos = net.ReadVector()
        local dir = net.ReadVector()

        if not dir or dir == Vector(0,0,0) then
            dir = Vector(0, 0, -1)
        end

        local emitter = ParticleEmitter(pos)
        if not emitter then return end

        for i = 1, math.random(50,100) do
            local part = emitter:Add("decals/blood" .. math.random(1,7), pos + dir * 1.5)
            if part then
                local speed = math.Rand(10,40)
                local spread = math.Rand(10,20)
                local vel = dir * speed + VectorRand() * (speed * spread)
                part:SetVelocity(vel)
                part:SetDieTime(10)
                part:SetStartAlpha(255)
                part:SetEndAlpha(0)
                part:SetStartSize(math.Rand(12,19))
                part:SetGravity(Vector(0, 0, -350))
                part:SetAirResistance(10)
                part:SetCollide(true)
                part:SetRoll(math.Rand(0, 360))
                part:SetRollDelta(math.Rand(-20, 20))

                local decalSize = math.Rand(3,5)
                part:SetCollideCallback( function( p, hitpos, hitnormal )
                    util.DecalEx(Material("decals/blood" .. math.random(1,7)), game.GetWorld(), hitpos + hitnormal, VectorRand() * 360, Color(40, 0, 0), decalSize / 4, decalSize / 4)
                    p:SetDieTime( 0 )
                    sound.Play(table.Random(blood_drop), hitpos, 55, 100,1)
                end)
            end
        end

        emitter:Finish()
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

        local rag = IsValid(ply) and ply:GetNWEntity("Ragdoll") or nil
        if IsValid(rag) then
            local bone = rag:LookupBone(bonename)
            if bone then
                local pos, ang = rag:GetBonePosition(bone)
                return pos, ang
            end
        end

        if IsValid(ply) and ply:IsPlayer() then
            local bone = ply:LookupBone(bonename)
            if bone then
                local pos, ang = ply:GetBonePosition(bone)
                if pos then return pos, ang end
            end
        end

        return nil
    end
    net.Receive("hmcdnbleed", function()
        local ply         = net.ReadEntity()
        local limb        = net.ReadString()
        local fallbackPos = net.ReadVector()

        local pos, boneAng = GetBleedPos(ply, limb)
        if not pos then pos = fallbackPos end

        local emitter = ParticleEmitter(pos)
        if not emitter then return end

        for i = 1, math.random(2, 4) do
            local part = emitter:Add("decals/blood" .. math.random(1, 7), pos + VectorRand() * 5)
            if part then
                local dir
                if boneAng then
                    dir = boneAng:Forward() + VectorRand() * 0.1
                else
                    dir = VectorRand()
                end
                dir:Normalize()

                part:SetVelocity(dir * math.Rand(40, 90))
                part:SetDieTime(10)
                part:SetStartAlpha(255)
                part:SetStartSize(math.Rand(1,2))
                part:SetGravity(Vector(0, 0, -650))
                part:SetAirResistance(110)
                part:SetCollide(true)
                part:SetRoll(math.Rand(-20, 20))
                part:SetRollDelta(math.Rand(-5, 5))
                part:SetCollideCallback(function(p, hitpos, hitnormal)
                    util.DecalEx(Material("decals/blood" .. math.random(1, 7)), game.GetWorld(),
                        hitpos + hitnormal, VectorRand() * 360, Color(40, 0, 0), math.Rand(0.1,0.15), math.Rand(0.1,0.15))
                    p:SetDieTime(0)
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
                part:SetVelocity(VectorRand() * 30 + Vector(0,0,math.Rand(-10,30)))
                part:SetDieTime(30)
                part:SetStartAlpha(20)
                part:SetEndAlpha(45)
                part:SetColor(70,0,0)
                part:SetStartSize(math.Rand(30,35))
                part:SetGravity(Vector(0, 0, -35))
                part:SetAirResistance(10)
                part:SetCollide(true)
                part:SetRoll(math.Rand(0, 360))
                part:SetRollDelta(math.Rand(-1, 1))
                part:SetAirResistance(50)
            end
        end

        emitter:Finish()

        local emitter = ParticleEmitter(pos)
        if not emitter then return end

        for i = 1, math.random(185, 190) do
            local part = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos + VectorRand() * 25)
            if part then
                part:SetVelocity(VectorRand() * 50 + Vector(0,0,math.Rand(-10,30)))
                part:SetDieTime(15)
                part:SetStartAlpha(40)
                part:SetEndAlpha(85)
                part:SetColor(70,0,0)
                part:SetStartSize(math.Rand(40,45))
                part:SetGravity(Vector(0, 0, -35))
                part:SetAirResistance(1)
                part:SetCollide(true)
                part:SetRoll(math.Rand(0, 360))
                part:SetRollDelta(math.Rand(-0.5, 0.5))
            end
        end

        emitter:Finish()        
    end)