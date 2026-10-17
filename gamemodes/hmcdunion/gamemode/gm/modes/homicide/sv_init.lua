local mode = GM:GetMode("homicide")
local ply_GetAll = player.GetAll

concommand.Add("qiwi_homicidetype", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end

	print("Homicide Types:\n1 = Standart\n2 = SOE\n3 = JIHAD\n4 = Wild west\n5 = No Gunman")

	local t = tonumber(args[1])
	if t and t >= 1 and t <= 5 then
		GAMEMODE.RoundNextType = t
		local roundNameLabel = (HMCD_RoundsTypeNormalise and HMCD_RoundsTypeNormalise[t]) or tostring(t)
		PrintMessage(HUD_PRINTTALK, "Next Homicide roundtype: " .. roundNameLabel)
	end
end)

function mode:OnStart()
	if #ply_GetAll() < 2 then return end

	for _, p in ipairs(ply_GetAll()) do
		if not p.Role or p.Role == "Fighter" or p.Role == "Sandboxer" then
			p.Role = "Bystander"
			p:SetNWString("RoleShow", "Bystander")
		end
	end

	local traitor = table.Random(ply_GetAll())
	local gunman
	if #ply_GetAll() >= 2 then
		repeat
			gunman = table.Random(ply_GetAll())
		until gunman ~= traitor
	end

	traitor.Role = "Traitor"
	traitor:SetNWString("RoleShow", "Traitor")
	if traitor.SetRoleColor then traitor:SetRoleColor(164, 26, 26) end

	if GAMEMODE.RoundType ~= 5 and IsValid(gunman) then
		gunman.SecretRole = "Gunman"
		gunman:SetNWString("RoleShow", "Gunman")
	end

	GAMEMODE.Traitor = traitor

	for _, ply in player.Iterator() do
		local roleShow = ply:GetNWString("RoleShow", "")
		if roleShow == "" then
			roleShow = ply.Role or "Bystander"
			ply:SetNWString("RoleShow", roleShow)
		end

		if HMCD_Loadout and HMCD_Loadout[roleShow] and HMCD_Loadout[roleShow][GAMEMODE.RoundType] then
			for _, wep in pairs(HMCD_Loadout[roleShow][GAMEMODE.RoundType]) do
				ply:Give(wep)
			end
		end

		if HMCD_Loadout_Firearms and HMCD_Loadout_Firearms[roleShow] and HMCD_Loadout_Firearms[roleShow][GAMEMODE.RoundType] then
			for _, wep in pairs(HMCD_Loadout_Firearms[roleShow][GAMEMODE.RoundType]) do
				if wep ~= "" then
					ply:Give(wep)
					if roleShow == "Traitor" and weapons.Get(wep) then
						ply:GiveAmmo(weapons.Get(wep).Primary.ClipSize, weapons.Get(wep).Primary.Ammo, true)
					end
					if GAMEMODE.RoundType == 2 and ply.Role == "Traitor" then
						ply.Equipment = ply.Equipment or {}
						ply.Equipment[6] = true
						net.Start("hmcd_equipment")
							net.WriteInt(6, 6)
							net.WriteBit(true)
						net.Send(ply)
					end
					if ply.Role == "Traitor" then
						ply:AllowFlashlight(true)
						ply.Equipment = ply.Equipment or {}
						local eqIndex = (HMCD_EquipmentNames and HMCD_EquipmentNames[5]) or 5
						ply.Equipment[eqIndex] = true
						net.Start("hmcd_equipment")
							net.WriteInt(5, 6)
							net.WriteBit(true)
						net.Send(ply)
					end
				end
			end
		end
	end
end

local function GetDamageReason(dmgType)
	if not dmgType then return "Unknown" end
	if bit.band(dmgType, DMG_BUCKSHOT) ~= 0 then return "Shotgun" end
	if bit.band(dmgType, DMG_BULLET) ~= 0 then return "Gunshot" end
	if bit.band(dmgType, DMG_SLASH) ~= 0 then return "Laceration" end
	if bit.band(dmgType, DMG_CLUB) ~= 0 then return "Blunt Force" end
	if bit.band(dmgType, DMG_BLAST) ~= 0 then return "Explosion" end
	if bit.band(dmgType, DMG_BURN) ~= 0 or bit.band(dmgType, DMG_SLOWBURN) ~= 0 then return "Fire" end
	if bit.band(dmgType, DMG_VEHICLE) ~= 0 then return "Vehicle" end
	if bit.band(dmgType, DMG_FALL) ~= 0 then return "Fall" end
	if bit.band(dmgType, DMG_DROWN) ~= 0 then return "Drowning" end
	if bit.band(dmgType, DMG_POISON) ~= 0 or bit.band(dmgType, DMG_NERVEGAS) ~= 0 or bit.band(dmgType, DMG_ACID) ~= 0 then return "Poison" end
	if bit.band(dmgType, DMG_SHOCK) ~= 0 then return "Electricity" end
	if bit.band(dmgType, DMG_CRUSH) ~= 0 then return "Crushing" end
	if bit.band(dmgType, DMG_PHYSGUN) ~= 0 then return "Physics" end
	return "Unknown"
end

function mode:Think()
	local alive_traitor = 0
	local alive_innocent = 0
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and not ply:GetNWBool("Spectating", false) then
			if ply.Role == "Traitor" then
				alive_traitor = alive_traitor + 1
			else
				if ply.Role == "Bystander" or ply.SecretRole == "Gunman" or ply:GetNWString("RoleShow", "") == "Gunman" or ply:GetNWString("RoleShow", "") == "Bystander" then
					alive_innocent = alive_innocent + 1
				elseif not ply.Role or ply.Role == "" then
					alive_innocent = alive_innocent + 1
				end
			end
		end
	end

	if alive_innocent <= 0 and alive_traitor > 0 then
		GAMEMODE:EndRound(1, GAMEMODE.Traitor)
		if IsValid(GAMEMODE.Traitor) and GAMEMODE.Traitor.AddAchiveProgress then
			GAMEMODE.Traitor:AddAchiveProgress("twin", 100)
		end
	elseif alive_traitor <= 0 and alive_innocent > 0 then
		local killer = IsValid(GAMEMODE.Traitor) and GAMEMODE.Traitor.LastAttacker or nil
		if not IsValid(killer) or not killer:IsPlayer() then killer = nil end
		GAMEMODE:EndRound(2, killer)
		if IsValid(GAMEMODE.Traitor) and GAMEMODE.Traitor.LastDamageType then
			PrintMessage(HUD_PRINTTALK, "The murderer died because of " .. GetDamageReason(GAMEMODE.Traitor.LastDamageType))
		end
	elseif alive_innocent <= 0 and alive_traitor <= 0 then
		GAMEMODE:EndRound(1, nil)
	end
end

local NextBoxSpawn = 0

hook.Add("Think", "HomicideSimpleBoxes", function()
	if not GAMEMODE or GAMEMODE.RoundName ~= "homicide" or GAMEMODE.RoundState ~= 1 then
		NextBoxSpawn = CurTime() + math.random(10, 30)
		return
	end

	if CurTime() < NextBoxSpawn then return end
	NextBoxSpawn = CurTime() + math.random(10, 30)

	local spawns = {}
	for _, cls in ipairs({"info_player_start", "info_player_deathmatch", "info_player_combine", "info_player_rebel", "gmod_player_start"}) do
		for _, e in ipairs(ents.FindByClass(cls)) do
			if IsValid(e) then spawns[#spawns + 1] = e:GetPos() end
		end
	end
	if #spawns == 0 then spawns = {Vector(0, 0, 0)} end

	local base = spawns[math.random(#spawns)]
	local tryPos = base + Vector(math.random(-1500, 1500), math.random(-1500, 1500), 200)
	local tr = util.TraceLine({start = tryPos, endpos = tryPos - Vector(0, 0, 1000), mask = MASK_SOLID_BRUSHONLY})
	if not tr.Hit then return end
	local pos = tr.HitPos + Vector(0, 0, 5)

	local isHeavy = math.random() < 0.25

	local mdl
	if math.random(1, 2) == 1 then
		mdl = isHeavy and HeavyBox_Models[math.random(#HeavyBox_Models)] or Box_Models[math.random(#Box_Models)]
	else
		mdl = Box22_Models[math.random(#Box22_Models)]
	end

	local ent = ents.Create("prop_physics")
	if not IsValid(ent) then return end
	ent:SetModel(mdl)
	ent:SetPos(pos)
	ent:SetAngles(Angle(0, math.random(0, 360), 0))
	ent:Spawn()
	ent:Activate()
	print("spawned")
	ent.HmcdSpawned = true
	if IsValid(ent:GetPhysicsObject()) then
		ent:GetPhysicsObject():SetMass(isHeavy and math.random(45, 80) or math.random(12, 25))
		ent:GetPhysicsObject():Wake()
	end
end)
