local mode = GM:GetMode("wagner")

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

local function ApplyFactionModel(ply, entry)
	if not IsValid(ply) then return end

	ply:SetMaterial("")
	for i = 0, 9 do ply:SetSubMaterial(i, "") end

	util.PrecacheModel(entry.model)
	ply:SetModel(entry.model)

	if entry.bodygroups then ply:SetBodyGroups(entry.bodygroups) end
	ply.ModelSex = entry.sex or "male"

	ply:SetPlayerColor(Vector(1, 1, 1))
	if ply.SetClothing then ply:SetClothing("none") end
	if ply.SetAccessory then ply:SetAccessory("none") end

	ApplyHands(ply)
end

local function GiveLoadout(ply, loadout)
	local mainClass = table.Random(loadout.Main)
	local secClass = table.Random(loadout.Secondary)

	ply:Give(mainClass)
	local wepDat = weapons.Get(mainClass)
	if wepDat and wepDat.Primary then
		ply:GiveAmmo(wepDat.Primary.ClipSize * 2, wepDat.Primary.Ammo, true)
	end

	ply:Give(secClass)
	wepDat = weapons.Get(secClass)
	if wepDat and wepDat.Primary then
		ply:GiveAmmo(wepDat.Primary.ClipSize, wepDat.Primary.Ammo, true)
	end

	for _, cls in ipairs(mode.CommonLoadout) do
		ply:Give(cls)
	end
end

function mode:OnStart()
	local players = player.GetAll()
	if #players < 2 then return end

	local shuffled = table.Copy(players)
	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	local factions = { Wagner = {}, Azov = {} }

	for i, ply in ipairs(shuffled) do
		local faction = (i % 2 == 1) and "Wagner" or "Azov"
		factions[faction][#factions[faction] + 1] = ply

		ply.Role = faction
		ply:SetNWString("RoleShow", faction)
		ply.SecretRole = ""

		local col = mode.TeamColors[faction]
		ply:SetRoleColor(col.r, col.g, col.b)
	end

	for faction, members in pairs(factions) do
		local modelPool = (faction == "Wagner") and Wagner_Models or Azov_Models
		local loadout = (faction == "Wagner") and Wagner_Loadout or Azov_Loadout

		for _, ply in ipairs(members) do
			local entry = table.Random(modelPool)
			ply.Wagner_Outfit = entry
			ApplyFactionModel(ply, entry)
			GiveLoadout(ply, loadout)
		end
	end

	self.Teams = factions

	local function RefitAll()
		for _, ply in ipairs(player.GetAll()) do
			local entry = ply.Wagner_Outfit
			if IsValid(ply) and entry and GAMEMODE.RoundName == "wagner" and GAMEMODE.RoundState == 1 then
				ApplyFactionModel(ply, entry)
			end
		end
	end

	timer.Simple(0.7, RefitAll)
	timer.Simple(1.3, RefitAll)
end

local function CountAlive(faction)
	local alive = 0
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and not ply:GetNWBool("Spectating", false)
		and ply.Role == faction then
			alive = alive + 1
		end
	end
	return alive
end

local function RandomAlive(faction)
	local pool = {}
	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive() and not ply:GetNWBool("Spectating", false)
		and ply.Role == faction then
			pool[#pool + 1] = ply
		end
	end
	return (#pool > 0) and table.Random(pool) or nil
end

function mode:Think()
	local aliveWagner = CountAlive("Wagner")
	local aliveAzov = CountAlive("Azov")

	if aliveWagner <= 0 and aliveAzov <= 0 then
		GAMEMODE:EndRound(3, nil)
	elseif aliveWagner <= 0 then
		GAMEMODE:EndRound(10, RandomAlive("Azov"))
	elseif aliveAzov <= 0 then
		GAMEMODE:EndRound(9, RandomAlive("Wagner"))
	end
end

function mode:OnEnd(reason)
	if reason == 9 then
		PrintMessage(HUD_PRINTTALK, "Wagner PMC wins the battle!")
	elseif reason == 10 then
		PrintMessage(HUD_PRINTTALK, "Azov wins the battle!")
	end
end
