local mode = GM:GetMode("riot")

local POLICE_RATIO = 3
local PISTOL_CHANCE = 0.4

local Police_Loadout = {
	Main = {
		""
	},
	Sidearm = {
		"wep_jack_hmcd_glock17",
		"wep_jack_hmcd_usp",
		"wep_jack_hmcd_revolver",
	},
	LessLethal = {
		"wep_jack_hmcd_taser",
		"wep_jack_hmcd_pepperspray",
	},
	Utility = {
		"wep_jack_hmcd_medkit",
		"wep_jack_hmcd_bandage",
		"wep_jack_hmcd_handcuffs",
		"wep_jack_hmcd_baton"
	},
}

local Rioter_Loadout = {
	Melee = {
		"wep_jack_hmcd_leadpipe",
		"wep_jack_hmcd_crowbar",
		"wep_jack_hmcd_knife",
		"wep_jack_hmcd_pocketknife",
		"wep_jack_hmcd_combatknife",
		"wep_jack_hmcd_brick",
		"wep_jack_hmcd_pan",
		"wep_jack_hmcd_cleaver",
		"wep_jack_hmcd_hammer",
	},
	Throw = {
		"wep_jack_hmcd_molotov",
		"wep_jack_hmcd_pipebombtest",
	},
	Utility = {
		"wep_jack_hmcd_bandage",
	},
	Pistols = {
		"wep_jack_hmcd_smallpistol",
		"wep_jack_hmcd_glock17",
		"wep_jack_hmcd_revolver",
	},
}

local Police_Models = {
	{ model = "models/monolithservers/mpd/male_07_2.mdl", sex = "male" },
	{ model = "models/monolithservers/mpd/male_07.mdl", sex = "male" }, //bez bab
}

local function ApplyHands(ply)
	if not IsValid(ply) then return end

	local hands = ply:GetHands()
	if not IsValid(hands) then return end

	local name = player_manager.TranslateToPlayerModelName(ply:GetModel())
	if not name then return end

	local info = player_manager.TranslatePlayerHands(name)
	if info and info.model then
		util.PrecacheModel(info.model)
		hands:SetModel(info.model)
		if info.skin then hands:SetSkin(info.skin) end
		if info.body then hands:SetBodyGroups(info.body) end
	end
end

local function ApplyPoliceModel(ply, entry)
	if not IsValid(ply) or not entry then return end

	ply:SetMaterial("")
	for i = 0, 9 do ply:SetSubMaterial(i, "") end

	util.PrecacheModel(entry.model)
	ply:SetModel(entry.model)
	ply.ModelSex = entry.sex or "male"

	ply:SetPlayerColor(Vector(1, 1, 1))
	if ply.SetClothing then ply:SetClothing("none") end
	if ply.SetAccessory then ply:SetAccessory("none") end

	ApplyHands(ply)
end

local function EquipPoliceArmor(ply)
	if not IsValid(ply) or GAMEMODE.RoundName ~= "riot" then return end

	local pieces = {"ent_hmcd_police"}
	if math.random() < 0.5 then
		table.insert(pieces, "ent_jack_hmcd_riotshield")
	end

	for _, cls in ipairs(pieces) do
		local ent = ents.Create(cls)
		if IsValid(ent) and hmcd and hmcd.EquipArmor then
			hmcd.EquipArmor(ply, ent)
		end
	end
end

local function GiveWithAmmo(ply, cls, mul)
	ply:Give(cls)
	local wepDat = weapons.Get(cls)
	if wepDat and wepDat.Primary then
		ply:GiveAmmo(math.max(math.floor((wepDat.Primary.ClipSize or 0) * (mul or 1)), 0), wepDat.Primary.Ammo, true)
	end
end

local function GivePoliceLoadout(ply)
	GiveWithAmmo(ply, table.Random(Police_Loadout.Main), 2)
	GiveWithAmmo(ply, table.Random(Police_Loadout.Sidearm), 1)
	GiveWithAmmo(ply, table.Random(Police_Loadout.LessLethal), 1)

	for _, cls in ipairs(Police_Loadout.Utility) do
		if weapons.Get(cls) then ply:Give(cls) end
	end
end

local function GiveRioterLoadout(ply)
	ply:Give(table.Random(Rioter_Loadout.Melee))
	ply:Give(table.Random(Rioter_Loadout.Throw))
	ply:Give(table.Random(Rioter_Loadout.Utility))

	if math.random() < PISTOL_CHANCE then
		GiveWithAmmo(ply, table.Random(Rioter_Loadout.Pistols), 1)
	end
end

local function SplitTeams()
	local players = player.GetAll()
	if #players < 2 then return nil end

	local shuffled = table.Copy(players)
	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	local teams = {Rioter = {}, Police = {}}
	for i, ply in ipairs(shuffled) do
		local side = (i % POLICE_RATIO == 0) and "Police" or "Rioter"
		teams[side][#teams[side] + 1] = ply
	end

	if #teams.Police == 0 then
		local ply = table.remove(teams.Rioter, #teams.Rioter)
		teams.Police[#teams.Police + 1] = ply
	elseif #teams.Rioter == 0 then
		local ply = table.remove(teams.Police, 1)
		teams.Rioter[#teams.Rioter + 1] = ply
	end

	return teams
end

function mode:OnStartPrepare()
	local teams = SplitTeams()
	if not teams then return end

	for side, members in pairs(teams) do
		for _, ply in ipairs(members) do
			ply.Role = side
			ply:SetNWString("RoleShow", side)
			ply.SecretRole = ""
		end
	end

	self.Teams = teams
end

function mode:OnStart()
	local teams = self.Teams
	if not teams then return end

	for side, members in pairs(teams) do
		local col = (side == "Rioter") and mode.TeamColors.Rioters or mode.TeamColors.Police

		for _, ply in ipairs(members) do
			if IsValid(ply) and ply.SetRoleColor then
				ply:SetRoleColor(col.r, col.g, col.b)
			end

			if side == "Police" then
				local entry = Police_Models[math.random(#Police_Models)]
				ply.Riot_Outfit = entry
				ApplyPoliceModel(ply, entry)
				GivePoliceLoadout(ply)

				timer.Simple(1, function()
					if IsValid(ply) and GAMEMODE.RoundName == "riot" and GAMEMODE.RoundState == 1 then
						EquipPoliceArmor(ply)
					end
				end)
			else
				GiveRioterLoadout(ply)
			end
		end
	end

	local function RefitPolice()
		for _, ply in ipairs(player.GetAll()) do
			local entry = ply.Riot_Outfit
			if IsValid(ply) and entry and GAMEMODE.RoundName == "riot" and GAMEMODE.RoundState == 1 then
				ApplyPoliceModel(ply, entry)
			end
		end
	end

	timer.Simple(0.7, RefitPolice)
	timer.Simple(1.3, RefitPolice)
end

local function CountAlive(role)
	local alive = 0
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and not ply:GetNWBool("Spectating", false)
		and ply.Role == role then
			alive = alive + 1
		end
	end
	return alive
end

local function RandomAlive(role)
	local pool = {}
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and not ply:GetNWBool("Spectating", false)
		and ply.Role == role then
			pool[#pool + 1] = ply
		end
	end
	return (#pool > 0) and table.Random(pool) or nil
end

function mode:Think()
	local aliveRioters = CountAlive("Rioter")
	local alivePolice = CountAlive("Police")

	if aliveRioters <= 0 and alivePolice <= 0 then
		GAMEMODE:EndRound(3, nil)
	elseif aliveRioters <= 0 then
		GAMEMODE:EndRound(4, RandomAlive("Police"))
	elseif alivePolice <= 0 then
		GAMEMODE:EndRound(5, RandomAlive("Rioter"))
	end
end

function mode:OnEnd(reason)
	if reason == 4 then
		PrintMessage(HUD_PRINTTALK, "Police wins the riot!")
	elseif reason == 5 then
		PrintMessage(HUD_PRINTTALK, "Rioters win!")
	end
end
