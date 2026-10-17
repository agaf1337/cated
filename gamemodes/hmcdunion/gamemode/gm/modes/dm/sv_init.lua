local mode = GM:GetMode("dm")

local dm_atts_simplified = {
	[HMCD_PISTOLSUPP] = "Suppressor",
	[HMCD_RIFLESUPP] = "Suppressor",
	[HMCD_SHOTGUNSUPP] = "Suppressor",
	[HMCD_LASERSMALL] = "Laser",
	[HMCD_LASERBIG] = "Laser",
	[HMCD_AIMPOINT] = "Sight2",
	[HMCD_EOTECH] = "Sight3",
	[HMCD_KOBRA] = "Sight",
	[HMCD_PBS] = "Suppressor",
	[HMCD_OSPREY] = "Suppressor",
	[HMCD_SCOPE] = "Scope"
}

-- Same install logic as hmcd_attachrequest's "attach" branch, so random DM
-- attachments land directly on the player's weapon instead of just in inventory.
local function TryInstallAttachment(ply, attachment, wep)
	if not IsValid(wep) then return end
	local name = dm_atts_simplified[attachment]
	if not name then return end
	if wep:GetNWBool(name) then return end

	if attachment == HMCD_LASERBIG and (wep:GetNWBool("Sight") or wep:GetNWBool("Sight2") or wep:GetNWBool("Sight3")) and not (wep.MultipleRIS) then return end
	if (attachment == HMCD_EOTECH or attachment == HMCD_KOBRA or attachment == HMCD_AIMPOINT or attachment == HMCD_SCOPE) and wep:GetNWBool("Laser") and not (wep.MultipleRIS) then return end
	if (attachment == HMCD_KOBRA or attachment == HMCD_AIMPOINT or attachment == HMCD_EOTECH or attachment == HMCD_SCOPE) and (wep:GetNWBool("Sight") or wep:GetNWBool("Sight2") or wep:GetNWBool("Sight3")) then return end

	if wep:GetClass() == "wep_jack_hmcd_akm" and (attachment == HMCD_KOBRA or attachment == HMCD_AIMPOINT or attachment == HMCD_EOTECH) then
		wep:SetNWBool("Rail", true)
	end
	wep:SetNWBool(name, true)
end

function mode:OnStartPrepare()
	GAMEMODE.DMTime = 10
	GAMEMODE.NoGun = true
	if GAMEMODE.SyncRoundGlobals then GAMEMODE.SyncRoundGlobals() end
	timer.Simple(12, function()
		if GAMEMODE.RoundName ~= "dm" or GAMEMODE.RoundState ~= 1 then return end

		timer.Create("DM_Timer", 1, 10, function()
			if GAMEMODE.RoundName ~= "dm" then timer.Remove("DM_Timer") return end
			GAMEMODE.DMTime = GAMEMODE.DMTime - 1
			SetGlobalInt("DMTime", GAMEMODE.DMTime)
			if timer.RepsLeft("DM_Timer") <= 0 then
				timer.Remove("DM_Timer")
				GAMEMODE.NoGun = false
				SetGlobalFloat("ZoneStartTime", CurTime())
			end
		end)
	end)
end

function mode:OnStart()
	if GAMEMODE.RoundName ~= "dm" then return end

	local poses = {}
	for _, ply in ipairs(player.GetAll()) do
		if ply:Alive() then
			table.insert(poses, ply:GetPos())
		end
	end

	if #poses > 0 then
		local centerpoint = Vector(0, 0, 0)
		for _, pos in ipairs(poses) do
			centerpoint:Add(pos)
		end
		centerpoint:Div(#poses)

		local dist = 0
		for _, pos in ipairs(poses) do
			local dist2 = pos:Distance(centerpoint)
			if dist < dist2 then
				dist = dist2
			end
		end

		GAMEMODE.ZonePos = centerpoint
		GAMEMODE.ZoneDistance = dist

		SetGlobalFloat("ZoneStartTime", 0)
		SetGlobalVector("ZonePos", centerpoint)
		SetGlobalFloat("ZoneDistance", dist)
	end

	for _, ply in ipairs(player.GetAll()) do
		ply.Role = "Fighter"
		ply:SetNWString("RoleShow", "Fighter")

		timer.Simple(1, function()
			if not IsValid(ply) then return end
			for _, v in pairs(table.Random(hmcd.armorsprefabs)) do
				print(v)
				local ent = ents.Create(v)
				hmcd.EquipArmor(ply, ent)
			end
		end)

		if DM_LoadoutMain and DM_LoadoutSecondary then
			local mainwep = table.Random(DM_LoadoutMain)
			local secwep = table.Random(DM_LoadoutSecondary)
			-- Give() returns the weapon entity, so grab the main weapon directly.
			-- GetActiveWeapon() after Give() is NOT guaranteed to be the new weapon,
			-- which previously sent the attachments to the wrong/old active weapon.
			local mainwepEnt = ply:Give(mainwep)
			if weapons.Get(mainwep) then
				ply:GiveAmmo(weapons.Get(mainwep).Primary.ClipSize * 1.5, weapons.Get(mainwep).Primary.Ammo, true)
			end
			ply:Give(secwep)
			if weapons.Get(secwep) then
				ply:GiveAmmo(weapons.Get(secwep).Primary.ClipSize * 0.5, weapons.Get(secwep).Primary.Ammo, true)
			end
			ply:Give("wep_jack_hmcd_combatknife")

			local dmMainWep = mainwepEnt
			ply.Equipment = ply.Equipment or {}
			for _ = 1, math.random(1, 4) do
				local atth = math.random(6, 15)
				ply.Equipment[atth] = true
				net.Start("hmcd_equipment")
					net.WriteInt(atth, 6)
					net.WriteBit(true)
				net.Send(ply)
				if IsValid(dmMainWep) then
					TryInstallAttachment(ply, atth, dmMainWep)
				end
			end
		end

		ply:Give("wep_jack_hmcd_oldgrenade_dm")
		ply:Give("wep_jack_hmcd_medkit")
		ply:Give("wep_jack_hmcd_bandage")
	end
end

function mode:Think(alive_ply)
	if (alive_ply or ((GetAlivePlayerCount and GetAlivePlayerCount()) or 0)) < 2 then
		GAMEMODE:EndRound(6, nil, (GetLastPlayerAlive and GetLastPlayerAlive()) or nil)
	end
end

hook.Add("PlayerPostThink", "ZoneDamage", function(ply)
	if GAMEMODE.RoundName ~= "dm" or GAMEMODE.RoundState ~= 1 then return end
	if GetGlobalFloat("ZoneStartTime", 0) == 0 then return end
	if not ply:Alive() then return end
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return end

	local pos = GetGlobalVector("ZonePos", Vector(0, 0, 0))
	local radius = (GAMEMODE.GetZoneRadius and GAMEMODE.GetZoneRadius()) or 1000
	local radiussqr = radius * radius

	local ply_pos = ply:GetPos()
	if ply.fake and IsValid(ply:GetNWEntity("Ragdoll")) then
		ply_pos = ply:GetNWEntity("Ragdoll"):GetPos()
	end

	if pos:DistToSqr(ply_pos) > radiussqr then
		if not ply.fake and not IsValid(ply:GetNWEntity("Ragdoll")) then
			if ply.Hit then ply.Hit["spine"] = true end
			if type(Faking) == "function" then Faking(ply) end
			if IsValid(ply:GetNWEntity("Ragdoll")) then
				ply:GetNWEntity("Ragdoll"):Dissolve()
			end
		else
			if IsValid(ply:GetNWEntity("Ragdoll")) then
				ply:GetNWEntity("Ragdoll"):Dissolve()
			end
		end
	end
end)
