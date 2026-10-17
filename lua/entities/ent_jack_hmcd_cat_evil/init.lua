AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

if SERVER then

    function ENT:Initialize()
        self:SetModel("models/dingus/dingus.mdl")
    
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:SetFriction(0)
            phys:SetBuoyancyRatio(0)
        end

        self.NextHopTime = CurTime() + 1
        self.NextAttackTime = 0
        self.LastPos = self:GetPos()
        self.StuckTicks = 0
    end

    function ENT:GetNearestPlayer()
        local nearestPly = nil
        local minDist = 3000

        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() and ply:GetObserverMode() == OBS_MODE_NONE then
                local dist = self:GetPos():Distance(ply:GetPos())
                if dist < minDist then
                    minDist = dist
                    nearestPly = ply
                end
            end
        end
        return nearestPly
    end

    function ENT:Think()
        if CurTime() >= self.NextHopTime then
            self:DoHop()
            self.NextHopTime = CurTime() + (self.EVIL and 0.4 or 1.2)
        end

        if self.EVIL and CurTime() >= self.NextAttackTime then
            for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 50)) do
                if IsValid(ent) and ent ~= self then
                    local class = ent:GetClass()
                    if class == "prop_door_rotating" or class == "func_door_rotating" then
                        HMCD_BlastThatDoor(ent)
                    end
                    if ent:Health() > 0 and !ent:IsRagdoll() and !ent:IsPlayer() then
                        local dmg = DamageInfo()
                        dmg:SetDamage(100)
                        dmg:SetAttacker(self)
                        dmg:SetInflictor(self)
                        dmg:SetDamageType(DMG_CLUB)
                        ent:TakeDamageInfo(dmg)
                    end
                end
            end

            local target = self:GetNearestPlayer()
            if IsValid(target) and self:GetPos():Distance(target:GetPos()) < 60 then
                self.Victims = self.Victims or {}
                local entID = target:EntIndex()

                if not self.Victims[entID] then
                    target:EmitSound(target.ModelSex == "male" and "s_crush_m.wav" or "s_crush_f.wav", 350)
                    target.Hit["spine"] = true                                     
                    if not target.fake then Faking(target) end
                    
                    Bleed(target, 1, "right_hand", target)
                    Bleed(target, 1, "chest", target)
                    Bleed(target, 1, "left_hand", target)
                    Bleed(target, 1, "right_leg", target)
                    Bleed(target, 1, "left_leg", target)

                    self.Victims[entID] = true
                end

                local dmg = DamageInfo()
                dmg:SetDamage(2)
                dmg:SetAttacker(self)
                dmg:SetInflictor(self)
                dmg:SetDamageType(DMG_SLASH)
                target:TakeDamageInfo(dmg)    
                target:EmitSound("bones/bone" .. math.random(1, 8) .. ".mp3", 111, 100, 1, CHAN_ITEM)   
                
                self.NextAttackTime = CurTime() + 0.1
            end
        end

        self:NextThink(CurTime() + 0.1)
        return true
    end

    function ENT:DoHop()
        local target = self:GetNearestPlayer()
        if not IsValid(target) then return end

        local phys = self:GetPhysicsObject()
        if not IsValid(phys) then return end

        local myPos = self:GetPos()
        if not self.LastPos then self.LastPos = myPos end

        local targetPos = target:GetPos()
        local dir = (targetPos - (myPos + Vector(0,0,10))):GetNormalized()
        
        if myPos:Distance(self.LastPos) < 15 then
            self.StuckTicks = self.StuckTicks + 1
        else
            self.StuckTicks = 0
        end
        self.LastPos = myPos

        local tr = util.TraceLine({
            start = myPos + Vector(0,0,10),
            endpos = myPos + Vector(0,0,10) + dir * 65,
            filter = self
        })

        if tr.Hit and tr.Entity ~= target then
            local foundPath = false
            for i = 1, 6 do
                local ang = i * 30
                for _, side in ipairs({-1, 1}) do
                    local scanDir = Vector(dir.x, dir.y, dir.z)
                    scanDir:Rotate(Angle(0, ang * side, 0))
                    local scanTr = util.TraceLine({
                        start = myPos + Vector(0,0,10),
                        endpos = myPos + Vector(0,0,10) + scanDir * 85,
                        filter = self
                    })
                    if not scanTr.Hit then
                        dir = scanTr.Normal
                        foundPath = true
                        break
                    end
                end
                if foundPath then break end
            end
        end

        local zForce = 260
        local isHigher = (targetPos.z - myPos.z) > 35

        if isHigher or self.StuckTicks > 2 then
            zForce = math.Clamp((targetPos.z - myPos.z) * 2.5, 450, 850)
            if self.StuckTicks > 3 then zForce = 750 end
        end

        local speed = self.EVIL and 480 or 320
        local hopVector = (dir * speed) + (Vector(0, 0, 1) * zForce)

        phys:ApplyForceCenter(hopVector * phys:GetMass())
        self:EmitSound("cat/meow" .. math.random(1, 5) .. ".wav", 75, 100)
    end

    function ENT:OnTakeDamage(dmg)
        self:EmitSound("cat/meowbad.wav", 1075, 120)
        self.EVIL = true
    end

end