AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Brass Knuckles"
ENT.Category = "HMCD: Union - Other"
ENT.Spawnable = true
ENT.ImpactSound = "physics/metal/weapon_impact_soft3.wav"
ENT.Model = "models/mosi/fallout4/props/weapons/melee/knuckles.mdl"
if not HMCD_BRASSKNUCKLES then HMCD_BRASSKNUCKLES = 19 end
ENT.EquipmentNum = HMCD_BRASSKNUCKLES

if SERVER then
    function ENT:Initialize()
        self.Entity:SetModel(self.Model)
        if self.Material then self.Entity:SetMaterial(self.Material) end
        if self.Color then self.Entity:SetColor(self.Color) end
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:SetUseType(SIMPLE_USE)
        self:DrawShadow(true)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            local mass = self.Mass or 1
            phys:SetMass(mass)
            phys:Wake()
            phys:EnableMotion(true)
        end
    end

    function ENT:Use(ply)
        if not IsValid(ply) then return end
        if not ply.Equipment then ply.Equipment = {} end
        
        if ply.Equipment[HMCD_EquipmentNames[self.EquipmentNum]] or ply:HasWeapon("wep_jack_hmcd_brassknuckles") then
            ply:PrintMessage(HUD_PRINTTALK, "You already have brass knuckles!")
            return
        end
        
        local hands = ply:GetWeapon("wep_jack_hmcd_hands")
        if IsValid(hands) then
            ply:StripWeapon("wep_jack_hmcd_hands")
        end
        
        if ply:HasWeapon("wep_jack_hmcd_brassknuckles") then
            ply:StripWeapon("wep_jack_hmcd_brassknuckles")
        end
        
        ply:Give("wep_jack_hmcd_brassknuckles")
        ply:SelectWeapon("wep_jack_hmcd_brassknuckles")
        
        ply.Equipment[HMCD_EquipmentNames[self.EquipmentNum]] = true
        
        net.Start("hmcd_equipment")
        net.WriteInt(self.EquipmentNum, 6)
        net.WriteBit(true)
        net.Send(ply)
        
        self:EmitSound(self.ImpactSound, 65, 100)
        self:Remove()
    end

    hook.Add("PlayerSpawn", "BrassKnucklesCleanup", function(ply)
        timer.Simple(0.1, function()
            if IsValid(ply) then
                if ply:HasWeapon("wep_jack_hmcd_brassknuckles") then
                    ply:StripWeapon("wep_jack_hmcd_brassknuckles")
                end
                if not ply:HasWeapon("wep_jack_hmcd_hands") then
                    ply:Give("wep_jack_hmcd_hands")
                end
                ply:SelectWeapon("wep_jack_hmcd_hands")
                if ply.Equipment and HMCD_EquipmentNames and HMCD_EquipmentNames[HMCD_BRASSKNUCKLES] then
                    ply.Equipment[HMCD_EquipmentNames[HMCD_BRASSKNUCKLES]] = nil
                end
            end
        end)
    end)

    hook.Add("PlayerDeath", "BrassKnucklesCleanup", function(ply)
        if IsValid(ply) then
            if ply:HasWeapon("wep_jack_hmcd_brassknuckles") then
                ply:StripWeapon("wep_jack_hmcd_brassknuckles")
            end
            if not ply:HasWeapon("wep_jack_hmcd_hands") then
                ply:Give("wep_jack_hmcd_hands")
            end
            ply:SelectWeapon("wep_jack_hmcd_hands")
            if ply.Equipment and HMCD_EquipmentNames and HMCD_EquipmentNames[HMCD_BRASSKNUCKLES] then
                ply.Equipment[HMCD_EquipmentNames[HMCD_BRASSKNUCKLES]] = nil
            end
        end
    end)

    concommand.Add("hmcd_droprequest", function(ply, cmd, args)
        if not IsValid(ply) then return end
        local attachment = math.Round(args[1])
        
        if attachment == HMCD_BRASSKNUCKLES then
            if ply:HasWeapon("wep_jack_hmcd_brassknuckles") then
                ply:StripWeapon("wep_jack_hmcd_brassknuckles")
            end
            if not ply:HasWeapon("wep_jack_hmcd_hands") then
                ply:Give("wep_jack_hmcd_hands")
            end
            ply:SelectWeapon("wep_jack_hmcd_hands")
            
            if ply.Equipment and HMCD_EquipmentNames and HMCD_EquipmentNames[HMCD_BRASSKNUCKLES] then
                ply.Equipment[HMCD_EquipmentNames[HMCD_BRASSKNUCKLES]] = nil
            end
            
            net.Start("hmcd_equipment")
            net.WriteInt(HMCD_BRASSKNUCKLES, 6)
            net.WriteBit(false)
            net.Send(ply)
            
            local knuckles = ents.Create("ent_jack_hmcd_brassknuckles")
            knuckles.HmcdSpawned = true
            knuckles:SetPos(ply:GetShootPos() + ply:GetAimVector() * 20)
            knuckles:Spawn()
            knuckles:Activate()
            local phys = knuckles:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(ply:GetVelocity() + ply:GetAimVector() * 100)
            end
            return
        end
        
        if attachment == 5 then
            local flashlight = ents.Create("ent_jack_hmcd_flashlight")
            flashlight.HmcdSpawned = true
            flashlight:SetPos(ply:GetShootPos() + ply:GetAimVector() * 20)
            flashlight:Spawn()
            flashlight:Activate()
            local phys = flashlight:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(ply:GetVelocity() + ply:GetAimVector() * 100)
            end
            
            ply.Equipment[HMCD_EquipmentNames[attachment]] = false
            ply:AllowFlashlight(false)
            ply:SetNWBool("DynamicFlashlight", false)
            net.Start("hmcd_equipment")
            net.WriteInt(attachment, 6)
            net.WriteBit(false)
            net.Send(ply)
            return
        end

        local attachmentsuka = ents.Create(atts_ents[attachment])
        attachmentsuka.HmcdSpawned = true
        attachmentsuka:SetPos(ply:GetShootPos() + ply:GetAimVector() * 20)
        attachmentsuka:Spawn()
        attachmentsuka:Activate()
        local phys = attachmentsuka:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(ply:GetVelocity() + ply:GetAimVector() * 100)
        end

        local wep = ply:GetActiveWeapon()
        if IsValid(wep) then
            if wep:GetClass() == "wep_jack_hmcd_akm" and (attachment == HMCD_KOBRA or attachment == HMCD_AIMPOINT or attachment == HMCD_EOTECH) then
                wep:SetNWBool("Rail", false)
            end
            if attachment != 5 then
                wep:SetNWBool(atts_simplified[attachment], false)
            end
        end

        ply.Equipment[HMCD_EquipmentNames[attachment]] = false
        net.Start("hmcd_equipment")
        net.WriteInt(attachment, 6)
        net.WriteBit(false)
        net.Send(ply)
    end)
elseif CLIENT then

end
