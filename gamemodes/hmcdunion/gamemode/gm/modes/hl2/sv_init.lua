local mode = GM:GetMode("hl2")

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

local function ApplyModel(ply, mdl, sex)
	if not IsValid(ply) or not mdl then return end

	ply:SetMaterial("")
	for i = 0, 9 do ply:SetSubMaterial(i, "") end

	util.PrecacheModel(mdl)
	ply:SetModel(mdl)
	ply.ModelSex = sex or "male"

	ply:SetPlayerColor(Vector(1, 1, 1))
	if ply.SetClothing then ply:SetClothing("none") end
	if ply.SetAccessory then ply:SetAccessory("none") end
	ApplyHands(ply)
end

local function ApplyRebelModel(ply, pool)
	if not pool then return end
	local sex = (math.random() < 0.5) and "female" or "male"
	local list = pool[sex] or pool.male
	if list and #list > 0 then
		ApplyModel(ply, list[math.random(#list)], sex)
	end
end

local function GiveLoadout(ply, side, subclass)
	local utility = HL2_Loadout and HL2_Loadout[side] and HL2_Loadout[side][subclass]
	if utility then
		for _, cls in ipairs(utility) do ply:Give(cls) end
	end

	local mains = HL2_LoadoutFire_Main and HL2_LoadoutFire_Main[side] and HL2_LoadoutFire_Main[side][subclass]
	if mains and #mains > 0 then
		local mainClass = table.Random(mains)
		ply:Give(mainClass)
		local wepDat = weapons.Get(mainClass)
		if wepDat then
			ply:GiveAmmo(93, wepDat.Primary.Ammo, true)
		end
	end

	local secs = HL2_LoadoutFire_Secondary and HL2_LoadoutFire_Secondary[side]
	if secs and #secs > 0 then
		local secClass = table.Random(secs)
		ply:Give(secClass)
		local wepDat = weapons.Get(secClass)
		if wepDat then
			ply:GiveAmmo(wepDat.Primary.ClipSize, wepDat.Primary.Ammo, true)
		end
	end

	ply:Give("wep_jack_hmcd_combatknife")
end

function mode:OnStart()
	local players = player.GetAll()
	if #players < 2 then return end

	local shuffled = table.Copy(players)
	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	for i, ply in ipairs(shuffled) do
		local side = (i % 2 == 1) and "Rebel" or "Combine"

		ply.Role = side
		ply:SetNWString("RoleShow", side)
		ply.SecretRole = ""

		local col = mode.TeamColors[side]
		ply:SetRoleColor(col.r, col.g, col.b)

		if side == "Rebel" then
			local subclass = table.Random(mode.RebelClasses)
			ply.SubClass = subclass
			ApplyRebelModel(ply, (subclass == "Medic") and Medic_RebelModels or Fighter_RebelModels)
			GiveLoadout(ply, side, subclass)
		else
			local subclass = table.Random(mode.CombineClasses)
			ply.SubClass = subclass
			ApplyModel(ply, CombineModels and CombineModels[subclass], "male")
			GiveLoadout(ply, side, subclass)
		end
	end
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
	local aliveRebel = CountAlive("Rebel")
	local aliveCombine = CountAlive("Combine")

	if aliveRebel <= 0 and aliveCombine <= 0 then
		GAMEMODE:EndRound(3, nil)
	elseif aliveRebel <= 0 then
		GAMEMODE:EndRound(4, RandomAlive("Combine"))
	elseif aliveCombine <= 0 then
		GAMEMODE:EndRound(5, RandomAlive("Rebel"))
	end
end

function mode:OnEnd(reason)
	if reason == 4 then
		PrintMessage(HUD_PRINTTALK, "Combine Overwatch wins the battle!")
	elseif reason == 5 then
		PrintMessage(HUD_PRINTTALK, "The Resistance wins the battle!")
	end
end
