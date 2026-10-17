-- auto generated Server part for hmcd_shared
if SERVER then
	util.AddNetworkString("hmcd_equipment")
	util.AddNetworkString("ragplayercolor")
	util.AddNetworkString("ebal_chellele")

	concommand.Add("hmcd_attachrequest",function(ply,cmd,args)
		if not ply.Equipment then ply.Equipment={} end
		local attachment=math.Round(args[1])
		local wep=ply:GetActiveWeapon()
		
		if not IsValid(wep) then return end

		if wep:GetNWBool(atts_simplified[attachment]) then
			if ply.Equipment[HMCD_EquipmentNames[attachment]] then ply:PrintMessage(HUD_PRINTTALK, "You already have this attachment!") return end
			wep:SetNWBool(atts_simplified[attachment],false)
			ply.Equipment[HMCD_EquipmentNames[attachment]]=true
			if (wep:GetNWBool("Rail", false) == true) and (attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_EOTECH) then
				wep:SetNWBool("Rail", false)
			end
			net.Start("hmcd_equipment")
			net.WriteInt(attachment,6)
			net.WriteBit(true)
			net.Send(ply)
		else
			if attachment==HMCD_LASERBIG and (wep:GetNWBool("Sight") or wep:GetNWBool("Sight2") or wep:GetNWBool("Sight3")) and not(wep.MultipleRIS) then
				ply:PrintMessage(HUD_PRINTTALK, "You can't apply this attachment! There isn't enough space!")
				return
			end
			if (attachment==HMCD_EOTECH or attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_SCOPE) and wep:GetNWBool("Laser") and not(wep.MultipleRIS) then
				ply:PrintMessage(HUD_PRINTTALK, "You can't apply this attachment! There isn't enough space!")
				return
			end
			if (attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_EOTECH or attachment==HMCD_SCOPE) and (wep:GetNWBool("Sight") or wep:GetNWBool("Sight2") or wep:GetNWBool("Sight3")) then
				ply:PrintMessage(HUD_PRINTTALK, "You already have a sight attached!")
				return
			end
			if wep:GetClass() == "wep_jack_hmcd_akm" and (attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_EOTECH) then
				wep:SetNWBool("Rail", true)
			end
			wep:SetNWBool(atts_simplified[attachment],true)
			ply.Equipment[HMCD_EquipmentNames[attachment]]=false
			net.Start("hmcd_equipment")
			net.WriteInt(attachment, 6)
			net.WriteBit(false)
			net.Send(ply)
		end
	end)

	concommand.Add("hmcd_droprequest",function(ply,cmd,args)
	if not ply.Equipment then ply.Equipment={} end
	local attachment=math.Round(args[1])
	local wep=ply:GetActiveWeapon()

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
		-- вот эта нижняя строка самая длинная ее не надо разбирать, это убирание рэйла при убирании прицела
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
end

if SERVER then
    hook.Add("PlayerSwitchFlashlight", "Fleshlight", function(ply, enabled)
        if not ply.Equipment or not ply.Equipment[HMCD_EquipmentNames[HMCD_FLASHLIGHT]] then
            return false
        end
        
        if not ply.fake then
            local status = not ply:GetNWBool("DynamicFlashlight")
            ply:SetNWBool("DynamicFlashlight", status)
            ply:EmitSound("items/flashlight1.wav", 60, 100)
        end
        return false
    end)

    hook.Add("PlayerDeath", "Fleshlight", function(ply)
        ply:SetNWBool("DynamicFlashlight", false)
    end)

    hook.Add("PlayerSpawn", "Fleshlight", function(ply)
        ply:SetNWBool("DynamicFlashlight", false)
    end)
end

hook.Add("KeyPress", "SnowballsPickup", function(ply, key)
    if IsValid(ply.FakeRagdoll) or key != IN_USE then return end
    
    ply.SnowBallPickupCD = ply.SnowBallPickupCD or 0
    if ply.SnowBallPickupCD > CurTime() then return end

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 120,
        filter = ply,
        mask = MASK_SHOT
    })
    
    if tr.Hit and tr.MatType == MAT_SNOW then
        local has = false
        for _, wep in ipairs(ply:GetWeapons()) do
            if wep:GetClass() == "wep_jack_hmcd_snowball" then has = true break end
        end
        
        if not has then
            ply:EmitSound("player/footsteps/snow1.wav", 65, math.Rand(90, 110))
            ply.SnowBallPickupCD = CurTime() + 1
            ply:Give("wep_jack_hmcd_snowball")
            ply:Select("wep_jack_hmcd_snowball")
        end
    end
end)








local MeleeTypes = {
	["wep_jack_hmcd_knife"] = "slash",
	["wep_jack_hmcd_combatknife"] = "slash",
	["wep_jack_hmcd_pocketknife"] = "slash",
	["wep_jack_hmcd_cleaver"] = "slash",
	["wep_jack_hmcd_axe"] = "slash",
	["wep_mann_hmcd_machete"] = "slash",
	["wep_jack_hmcd_crowbar"] = "club",
	["wep_jack_hmcd_leadpipe"] = "club",
	["wep_jack_hmcd_hammer"] = "club",
	["wep_jack_hmcd_pan"] = "club",
	["wep_jack_hmcd_brick"] = "club",
	["wep_jack_hmcd_baton"] = "club",
}

local SWING_COOLDOWN = 0.6
local SLASH_COOLDOWN = 0.45
local SLASH_MIN_SPEED = 50
local CLUB_MIN_SPEED = 250
local CLUB_FULL_SPEED = 400

local function IsMelee(cls)
	return cls and MeleeTypes[cls] ~= nil
end

local function GetDamage(cls)
	local wep = weapons.Get(cls)
	if wep and wep.Primary and wep.Primary.Damage then
		return wep.Primary.Damage
	end

	local wep2 = weapons.Get(cls)
	if wep2 and wep2.MinDamage and wep2.MaxDamage then
		return math.random(wep2.MinDamage, wep2.MaxDamage)
	end

	return 20
end

local function HandBone(rag)
	local bone = rag:LookupBone("ValveBiped.Bip01_R_Hand")
	if not bone then return nil end
	return rag:TranslateBoneToPhysBone(bone)
end

local function RemoveMeleeEnt(ply)
	if IsValid(ply.QiwiMeleeEnt) then
		ply.QiwiMeleeEnt:Remove()
	end
	ply.QiwiMeleeEnt = nil
end

local function SpawnMeleeEnt(ply, rag, cls)
	local wepDat = weapons.Get(cls)
	if not wepDat or not wepDat.WorldModel then return end
	if ply.RightArmbroke then return end

	local boneNum = HandBone(rag)
	if not boneNum then return end

	local hand = rag:GetPhysicsObjectNum(boneNum)
	if not IsValid(hand) then return end

	local ent = ents.Create("prop_physics")
	if not IsValid(ent) then return end

	ent:SetModel(wepDat.WorldModel)
	ent:SetPos(hand:GetPos())
	ent:SetAngles(hand:GetAngles() - Angle(0, 0, 180))
	ent:Spawn()
	ent:Activate()
	ent.HmcdSpawned = true
	ent.QiwiMelee = cls

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(3)
		phys:Wake()
	end

	constraint.Weld(ent, rag, 0, boneNum, 0, true, false)

	ply.QiwiMeleeEnt = ent
	ply.QiwiMeleeNext = CurTime() + 0.5
end

hook.Add("Fake", "QiwiFakeMelee_Remember", function(ply)
	ply.QiwiMeleeWanted = nil

	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and not ply.FakeShooting then
		local cls = wep:GetClass()
		if IsMelee(cls) then
			ply.QiwiMeleeWanted = cls
		end
	end
end)

hook.Add("PlayerSwitchWeapon", "QiwiFakeMelee_Switch", function(ply, oldWep, newWep)
	if not ply.fake then return end

	ply.QiwiMeleeWanted = nil
	if IsValid(newWep) and IsMelee(newWep:GetClass()) then
		ply.QiwiMeleeWanted = newWep:GetClass()
		RemoveMeleeEnt(ply)
	end
end)

hook.Add("KeyPress", "QiwiFakeMelee_Swing", function(ply, key)
	if key ~= IN_ATTACK then return end
	if not ply.fake or ply.Otrub then return end
	if not IsValid(ply.QiwiMeleeEnt) then return end
	if ply.FakeShooting then return end

	local rag = ply:GetNWEntity("Ragdoll")
	if not IsValid(rag) or ply.RightArmbroke then return end
	if RagdollOwner(rag) and RagdollOwner(rag).Otrub then return end

	local boneNum = HandBone(rag)
	if not boneNum then return end

	local hand = rag:GetPhysicsObjectNum(boneNum)
	local head = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_Head1")))
	if not IsValid(hand) or not IsValid(head) then return end

	local eyeangs = ply:EyeAngles()
	local ang = eyeangs
	ang:RotateAroundAxis(eyeangs:Forward(), 90)
	ang:RotateAroundAxis(eyeangs:Right(), 75)

	hand:Wake()
	hand:ComputeShadowControl({
		secondstoarrive = 0.05,
		pos = head:GetPos() + eyeangs:Forward() * 60 + eyeangs:Right() * 8,
		angle = ang,
		maxangular = 670,
		maxangulardamp = 600,
		maxspeeddamp = 50,
		maxspeed = 500,
		teleportdistance = 0,
		deltatime = 0.05,
	})
end)

local function VictimIsValid(ent, ply)
	if not IsValid(ent) then return false end
	if ent == ply then return false end

	local rag = ply:GetNWEntity("Ragdoll")
	if ent == rag then return false end

	if ent:IsPlayer() then
		return ent:Alive() or IsValid(ent:GetNWEntity("Ragdoll"))
	end

	if ent:GetClass() == "prop_ragdoll" then
		local owner = RagdollOwner(ent)
		if IsValid(owner) then
			return owner ~= ply
		end
		return true
	end

	return false
end

local function MeleeHitCheck(ply)
	local ent = ply.QiwiMeleeEnt
	if not IsValid(ent) then return end

	local phys = ent:GetPhysicsObject()
	if not IsValid(phys) then return end

	local vel = phys:GetVelocity()
	local speed = vel:Length()
	if speed < SLASH_MIN_SPEED then return end
	if CurTime() < (ply.QiwiMeleeNext or 0) then return end
	if ply.Otrub then return end

	local dir = vel:GetNormalized()
	local tr = util.TraceLine({
		start = ent:GetPos() - dir * 6,
		endpos = ent:GetPos() + dir * (speed * 0.06 + 14),
		filter = {ply, ply:GetNWEntity("Ragdoll"), ent},
		mask = MASK_SHOT,
	})

	if not (tr.Hit and VictimIsValid(tr.Entity, ply)) then return end

	local cls = ent.QiwiMelee
	local kind = MeleeTypes[cls] or "club"
	local base = GetDamage(cls)

	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(ply)
	dmginfo:SetInflictor(ent)
	dmginfo:SetDamagePosition(tr.HitPos)
	dmginfo:SetDamageForce(dir * math.min(speed * 6, 1500))

	if kind == "slash" then
		dmginfo:SetDamageType(DMG_SLASH)
		dmginfo:SetDamage(math.max(math.Round(base * 0.4), 4))
		sound.Play("snd_jack_hmcd_knifestab.wav", tr.HitPos, 75, 130)
		ply.QiwiMeleeNext = CurTime() + SLASH_COOLDOWN
	else
		dmginfo:SetDamageType(DMG_CLUB)
		local mul = (speed >= CLUB_FULL_SPEED) and 1 or 0.6
		dmginfo:SetDamage(math.max(math.Round(base * mul), 5))
		sound.Play("Flesh.ImpactHard", tr.HitPos, 75, 100)
		ply.QiwiMeleeNext = CurTime() + SWING_COOLDOWN
	end

	tr.Entity:TakeDamageInfo(dmginfo)
end

timer.Create("QiwiFakeMelee_Think", 0.05, 0, function()
	for _, ply in ipairs(player.GetAll()) do
		if ply.fake and ply:Alive() then
			local rag = ply:GetNWEntity("Ragdoll")
			if IsValid(rag) then
				local hasGun = IsValid(ply.wep) or ply.FakeShooting

				if ply.QiwiMeleeWanted and not hasGun and not IsValid(ply.QiwiMeleeEnt) then
					SpawnMeleeEnt(ply, rag, ply.QiwiMeleeWanted)
				end

				if IsValid(ply.QiwiMeleeEnt) and (hasGun or not ply.QiwiMeleeWanted) then
					RemoveMeleeEnt(ply)
				end

				MeleeHitCheck(ply)
			else
				RemoveMeleeEnt(ply)
			end
		else
			if ply.QiwiMeleeWanted ~= nil and not ply.fake then
				ply.QiwiMeleeWanted = nil
			end
			RemoveMeleeEnt(ply)
		end
	end
end)

hook.Add("PlayerSpawn", "QiwiFakeMelee_Reset", function(ply)
	ply.QiwiMeleeWanted = nil
	timer.Simple(0, function()
		if IsValid(ply) then RemoveMeleeEnt(ply) end
	end)
end)

hook.Add("PlayerDisconnected", "QiwiFakeMelee_DC", function(ply)
	RemoveMeleeEnt(ply)
end)
