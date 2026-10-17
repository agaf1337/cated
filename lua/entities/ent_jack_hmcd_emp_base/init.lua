AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
ENT.Recoil = 0 

function ENT:Initialize()
    self.sightAng = Angle(0, 0, 0)
    self.IsInitializing = true
    self:SetUseType(SIMPLE_USE)

    self:SetModel(self.BaseModel)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:AddEffects(EF_NODRAW)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end

    timer.Simple(0, function()
        if IsValid(self) then
            self:SetPos(self:LocalToWorld(self.Offset or Vector(0, 0, 0)))
        end
    end)

    timer.Simple(0.1, function()
        if not IsValid(self) then return end
        self.GunEnt = ents.Create("prop_dynamic")
        self.GunEnt:SetModel(self.GunModel)
        self.GunEnt:SetPos(self:GetPos())
        self.GunEnt:SetAngles(self:GetAngles() + Angle(0, 180, 0))
        self.GunEnt:Spawn()
        self.GunEnt:SetMoveType(MOVETYPE_NONE)
        self.GunEnt:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        local gPhys = self.GunEnt:GetPhysicsObject()
        if IsValid(gPhys) then
            gPhys:EnableMotion(false)
            gPhys:EnableCollisions(false)
        end

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
        self.IsInitializing = false
    end)
end

function ENT:Use(taker)
    if self.User == taker then 
        self.User = nil 
        return 
    end
    self.User = taker
end

function ENT:ReloadSound()
    if not self.ReloadSounds then return end
    for k, v in pairs(self.ReloadSounds) do
        if istable(k) then return end
        timer.Create(k .. "snd" .. self:EntIndex(), tonumber(k, 10) or 0.1, 1, function()
            if IsValid(self) and v[1] then
                self:EmitSound(v[1], 55, 100, 1, CHAN_AUTO)
            end
        end)
    end
end

local function PlayPropAnim(ent, animNameFallbackTable)
    if not IsValid(ent) then return end
    local chosenSeqName = nil
    for _, name in ipairs(animNameFallbackTable) do
        if ent:LookupSequence(name) != -1 then
            chosenSeqName = name
            break
        end
    end

    if chosenSeqName then
        ent:Fire("SetAnimation", chosenSeqName, 0)
        local seq = ent:LookupSequence(chosenSeqName)
        ent:SetSequence(seq)
        ent:SetPlaybackRate(1)
        ent:SetCycle(0)
    end
end

function ENT:Reload()
    if not timer.Exists("reload" .. self:EntIndex()) and self.Clip ~= self.MaxClip then
        self:ReloadSound()
        
        if IsValid(self.GunEnt) then
            PlayPropAnim(self.GunEnt, {"Reload", "reload", "Reload1", "reload1", "insert"})
        end

        timer.Create("reload" .. self:EntIndex(), 7, 1, function()
            if IsValid(self) then
                self.Clip = math.Clamp(self.Clip + 9999, 0, self.MaxClip)
                
                if IsValid(self.GunEnt) then
                    PlayPropAnim(self.GunEnt, {"Idle", "idle", "Idle1", "idle1", "idle01"})
                end
            end
        end)
    end
end

local function RayOBBIntersection(rayStart, rayDir, boxMin, boxMax, boxPos, boxAng)
    local tMin, tMax = 0, math.huge
    local delta = boxPos - rayStart
    local axes = {boxAng:Forward(), boxAng:Right(), boxAng:Up()}

    for i = 1, 3 do
        local axis = axes[i]
        local e = axis:Dot(delta)
        local f = rayDir:Dot(axis)

        if math.abs(f) > 0.0001 then
            local t1 = (e + boxMin[i]) / f
            local t2 = (e + boxMax[i]) / f
            if t1 > t2 then t1, t2 = t2, t1 end
            if t1 > tMin then tMin = t1 end
            if t2 < tMax then tMax = t2 end
            if tMin > tMax or tMax < 0 then return false end
        else
            if -e + boxMin[i] > 0 or -e + boxMax[i] < 0 then return false end
        end
    end
    return true, tMin, tMax
end

function ENT:BulletCallbackFunc(dmgAmt, ply, tr, dmg, tracer, hard, multi)
    if tr.MatType == MAT_FLESH then
        local effectdata = EffectData()
        effectdata:SetOrigin(tr.HitPos)
        util.Effect("BloodImpact", effectdata)
    end
    if tr.HitSky then return end
    if hard then self:RicochetOrPenetrate(tr) end
end

function ENT:RicochetOrPenetrate(initialTrace)
    local AVec, IPos, TNorm, SMul = initialTrace.Normal, initialTrace.HitPos, initialTrace.HitNormal, (HMCD_SurfaceHardness and HMCD_SurfaceHardness[initialTrace.MatType]) or 0.5

    local ApproachAngle = -math.deg(math.asin(math.Clamp(TNorm:DotProduct(AVec), -1, 1)))
    local MaxRicAngle = 60 * SMul
    local ent = initialTrace.Entity
    local dmgAmt = self.CurrentDamage or self.Damage
    local attacker = self.User

    if ApproachAngle > (MaxRicAngle * 1.25) then
        local MaxDist = (dmgAmt / SMul) * 1.15
        local ExitPos = IPos + AVec * 5
        local Penetrated = false
        local HitInnerBox = false

        if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer() or ent:GetClass() == "prop_ragdoll") then
            local numHitBoxSets = ent:GetHitboxSetCount() or 1
            local hitboxesToProcess = {}

            for set = 0, numHitBoxSets - 1 do
                local numHitBoxes = ent:GetHitBoxCount(set) or 0
                for hitbox = 0, numHitBoxes - 1 do
                    local bone = ent:GetHitBoxBone(hitbox, set)
                    if bone then
                        local bMin, bMax = ent:GetHitBoxBounds(hitbox, set)
                        local bPos, bAng = ent:GetBonePosition(bone)

                        if bMin and bMax and bPos and bAng then
                            local hit, t1, t2 = RayOBBIntersection(IPos - AVec * 2, AVec, bMin, bMax, bPos, bAng)
                            if hit and t1 < MaxDist then
                                table.insert(hitboxesToProcess, { entryDist = t1, exitDist = t2, min = bMin, max = bMax })
                            end
                        end
                    end
                end
            end

            table.sort(hitboxesToProcess, function(a, b) return a.entryDist < b.entryDist end)

            local finalExitDist = 0
            if #hitboxesToProcess > 0 then
                Penetrated = true
                finalExitDist = hitboxesToProcess[1].exitDist

                for i = 1, #hitboxesToProcess do
                    local hb = hitboxesToProcess[i]
                    if hb.entryDist <= MaxDist then
                        if hb.exitDist > finalExitDist then finalExitDist = hb.exitDist end
                        local volume = (hb.max.x - hb.min.x) * (hb.max.y - hb.min.y) * (hb.max.z - hb.min.z)
                        if volume > 200 and volume < 950 and hb.entryDist <= finalExitDist then HitInnerBox = true end
                    end
                end
            end

            if Penetrated then
                ExitPos = IPos + AVec * (math.Clamp(finalExitDist, 1, MaxDist) + 1)
                if HitInnerBox then
                    local d = DamageInfo()
                    d:SetDamage(self.CurrentDamage * 2.5)
                    d:SetAttacker(attacker)
                    d:SetInflictor(self)
                    d:SetDamageType(DMG_BULLET)
                    d:SetDamagePosition(IPos)
                    ent:TakeDamageInfo(d)
                end
            end
        end

        if not Penetrated then
            local SearchDist = 5
            while (not Penetrated) and (SearchDist < MaxDist) do
                local SearchPos = IPos + AVec * SearchDist
                local PeneTrace = util.QuickTrace(SearchPos, -AVec * SearchDist)
                if (not PeneTrace.StartSolid) and PeneTrace.Hit then
                    Penetrated = true
                    ExitPos = SearchPos
                else
                    SearchDist = SearchDist + 5
                end
            end
        end

        if Penetrated then
            local DistTraveled = IPos:Distance(ExitPos)
            local StopMul = DistTraveled / MaxDist
            local NextDamage = self.CurrentDamage * math.Clamp((1 - StopMul) * 1.2, 0.01, 1)

            self:FireBullets({
                Attacker = attacker,
                Damage = 1,
                Force = 1,
                Num = 1,
                Tracer = 0,
                Dir = -AVec,
                Spread = Vector(0, 0, 0),
                Src = ExitPos
            })

            self:FireBullets({
                Attacker = attacker,
                Damage = NextDamage,
                Force = dmgAmt / 15,
                Num = 1,
                Tracer = 0,
                Dir = AVec,
                Spread = Vector(0, 0, 0),
                Src = ExitPos,
                Callback = function(ply, tr)
                    local traceData = { start = ExitPos, endpos = ExitPos + AVec * 100000, filter = ent }
                    local trace = util.TraceLine(traceData)
                    if self.BulletCallbackFunc then self:BulletCallbackFunc(NextDamage, ply, trace, nil, false, true, false) end
                end
            })

            self.CurrentDamage = NextDamage
        end

    elseif ApproachAngle < (MaxRicAngle * .75) and not (initialTrace.MatType == MAT_FLESH) then
        sound.Play("snd_jack_hmcd_ricochet_" .. math.random(1, 2) .. ".wav", IPos, 70, math.random(90, 100))
        local NewVec = AVec:Angle()
        NewVec:RotateAroundAxis(TNorm, 180)
        local AngDiffNormal = math.deg(math.acos(math.Clamp(NewVec:Forward():Dot(TNorm), -1, 1))) - 90
        NewVec:RotateAroundAxis(NewVec:Right(), AngDiffNormal * .7)
        NewVec = NewVec:Forward()

        self:FireBullets({
            Attacker = attacker,
            Damage = dmgAmt * .5,
            Force = dmgAmt / 15,
            Num = 1,
            Tracer = 0,
            Distance = 600,
            Dir = NewVec,
            Spread = Vector(0, 0, 0),
            Src = IPos + TNorm
        })
    end
end

function ENT:GunShoot(wep)
    local damage = self.Damage
    self.CurrentDamage = damage
    local attacker = self.User
    if not IsValid(attacker) or attacker.fake then return end

    local Attachment
    local aID = wep:LookupAttachment("muzzle")
    if not aID or aID == 0 then aID = wep:LookupAttachment("muzzle_flash") end
    if aID and aID > 0 then Attachment = wep:GetAttachment(aID) end

    local rawPos, muzzleAng
    if Attachment then
        rawPos = Attachment.Pos
        muzzleAng = Attachment.Ang
    else
        muzzleAng = wep:GetAngles()
        rawPos = wep:GetPos()
    end

    local o = self.MuzzleOffset or Vector(10, 0, 0)
    local muzzlePos = rawPos + muzzleAng:Forward() * o.x + muzzleAng:Right() * o.y + muzzleAng:Up() * o.z
    local shootOrigin = muzzlePos + muzzleAng:Forward() * 2
    local shootDir = muzzleAng:Forward()

    local bullet = {}
    bullet.Num      = 1
    bullet.Src      = shootOrigin
    bullet.Dir      = shootDir
    bullet.Spread   = Vector(0, 0, 0)
    bullet.Tracer   = 0
    bullet.Force    = damage / 30
    bullet.Damage   = damage / 4
    bullet.Attacker = attacker
    bullet.Callback = function(ply, tr)
        if self.BulletCallbackFunc then self:BulletCallbackFunc(damage, ply, tr, damage, false, true, false) end
    end

    if self.MuzzleEffect and self.MuzzleEffect ~= "" then
        ParticleEffect(self.MuzzleEffect, muzzlePos, muzzleAng, self)
    end
    self:FireBullets(bullet)

    if SERVER then
        net.Start("huysound")
        net.WriteVector(muzzlePos)
        net.WriteString(self.ShootSound or "")
        net.WriteString(self.ShootSoundFar or "")
        net.SendPVS(muzzlePos)
    end
    
    local obj = wep:LookupAttachment("shell")
    local shellAtt = wep:GetAttachment(obj)
    if shellAtt then
        local ef = EffectData()
        ef:SetOrigin(shellAtt.Pos)
        ef:SetAngles(shellAtt.Ang)
        ef:SetFlags(140)
        util.Effect("EjectBrass_762Nato", ef)
    end

    self.Recoil = (self.Recoil or 0) + math.Rand(-3, 3)
    self.NextShoot = CurTime() + (self.Delay or 0.1)
    self.Clip = self.Clip - 1
end

local function easedBackLerp(fraction, from, to)
    return Lerp(math.ease.OutBack(fraction), from, to)
end

local function easedLerpAng(fraction, from, to)
    return LerpAngle(math.ease.OutExpo(fraction), from, to)
end

function ENT:Think()
    if IsValid(self.User) then
        if self.User.fake or not self.User:Alive() or self.User:GetPos():Distance(self:GetPos()) > 160 then
            self.User = nil
        end
    else
        self.User = nil
    end

    if self.IsInitializing then return end
    if not IsValid(self.GunEnt) then self:Remove() return end

    if self.Recoil and self.Recoil != 0 then 
        self.Recoil = easedBackLerp(.09, self.Recoil, 0) 
    end

    if IsValid(self.GunEnt) then
        self.GunEnt:SetPos(self:GetPos() + self:GetAngles():Up() * 2.5)
        self.GunEnt:SetAngles(self:GetAngles() + AngleRand(-(self.Recoil or 0), (self.Recoil or 0)) - (self.sightAng or Angle(0, 0, 0)))
    end

    self:NextThink(CurTime() + 0.05)

    if IsValid(self.User) then
        local wpn = self.User:GetActiveWeapon()
        if IsValid(wpn) and wpn ~= self then
            wpn:SetNextPrimaryFire(CurTime() + 0.3)
            wpn:SetNextSecondaryFire(CurTime() + 0.3)
        end

        if self.User:KeyDown(IN_ATTACK) and (CurTime() >= (self.NextShoot or 0)) and self.Clip > 0 and not timer.Exists("reload" .. self:EntIndex()) then
            self:GunShoot(self.GunEnt)
        end

        self.sightAng = easedLerpAng(.05, self.sightAng or Angle(0, 0, 0), self:GetAngles() - self.User:EyeAngles())

        if self.User:KeyPressed(IN_RELOAD) then
            self:Reload()
        end
    end

    return true
end

function ENT:OnRemove()
    if IsValid(self.GunEnt) then self.GunEnt:Remove() end
end