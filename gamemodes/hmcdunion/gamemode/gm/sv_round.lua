util.AddNetworkString("armor_end_round")

local ply_GetAll = player.GetAll
local math_Clamp = math.Clamp
local table_Random = table.Random

local MODES_PATH = "hmcdunion/gamemode/gm/modes/"

GM.Modes = GM.Modes or {}

function GM.RegisterMode(gm, id, data)
	data.Id = id
	gm.Modes[id] = data

	if data.Name then
		RoundsNormalise = RoundsNormalise or {}
		RoundsNormalise[id] = data.Name
	end

	if SERVER then
		local pool = {}
		for mid, m in pairs(gm.Modes) do
			local weight = tonumber(m.Weight) or 0
			for _ = 1, weight do pool[#pool + 1] = mid end
		end
		Rounds = pool
	end

	return data
end

function GM.GetMode(gm, id)
	return gm.Modes[id]
end

function GM.GetActiveMode(gm)
	if SERVER then
		return gm.Modes[GAMEMODE.RoundName or "homicide"]
	end
	return gm.Modes[GetGlobalString("RoundName", "homicide")]
end

do
	local _, modeDirs = file.Find(MODES_PATH .. "*", "LUA")
	for _, dir in ipairs(modeDirs) do
		local shPath = MODES_PATH .. dir .. "/shared.lua"
		if file.Exists(shPath, "LUA") then
			AddCSLuaFile(shPath)
			include(shPath)
		end
	end
end

if GAMEMODE.RoundName == nil then GAMEMODE.RoundName = "homicide" end
if GAMEMODE.RoundType == nil then GAMEMODE.RoundType = 0 end
if GAMEMODE.RoundCount == nil then GAMEMODE.RoundCount = 0 end

local function SyncRoundGlobals()
	SetGlobalString("RoundName", GAMEMODE.RoundName or "homicide")
	SetGlobalInt("RoundType", GAMEMODE.RoundType or 0)
	SetGlobalInt("DMTime", GAMEMODE.DMTime or 0)
end
GM.SyncRoundGlobals = SyncRoundGlobals

SyncRoundGlobals()

concommand.Add("qiwi_gamemode", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end

	local id = string.lower(tostring(args[1] or ""))
	local mode = GAMEMODE:GetMode(id)
	if not mode then return end

	GAMEMODE.RoundNext = id
	if mode.HasRoundTypes then
		GAMEMODE.RoundNextType = math.random(1, mode.TypeCount or 5)
	else
		GAMEMODE.RoundNextType = 0
	end

	local msg = "Next gamemode: " .. (mode.ShortName or mode.Name or id)
	if GAMEMODE.RoundNextType ~= 0 then
		local label = (HMCD_RoundsTypeNormalise and HMCD_RoundsTypeNormalise[GAMEMODE.RoundNextType]) or tostring(GAMEMODE.RoundNextType)
		msg = msg .. " - " .. label
	end
	PrintMessage(HUD_PRINTTALK, msg)
end)

concommand.Add("qiwi_gamemode_end", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	GAMEMODE:EndRound(3, ply)
end)

local function ApplyRoleNames(mode)
	if not mode.RoleNames then return end

	for _, ply in player.Iterator() do
		local pool = mode.RoleNames[ply.Role or ""]
		if not pool or #pool == 0 then
			pool = mode.RoleNames[ply:GetNWString("RoleShow", "")]
		end
		if pool and #pool > 0 then
			if ply.SavedCharName == nil then
				ply.SavedCharName = ply:GetNWString("Character_Name", "")
			end
			ply:SetNWString("Character_Name", table_Random(pool))
		end
	end
end

local function RestoreRoleNames()
	for _, ply in player.Iterator() do
		if ply.SavedCharName ~= nil then
			ply:SetNWString("Character_Name", ply.SavedCharName)
			ply.SavedCharName = nil
		end
	end
end

local function RestoreAppearance()
	for _, ply in player.Iterator() do
		if IsValid(ply) then
			hook.Run("Identity", ply)
		end
	end
end

local mapBlacklist = {
	["gm_flatgrass"] = true,
	["gm_construct"] = true,
}

function GM:StartRound()
	if #ply_GetAll() < 2 and GAMEMODE.RoundName ~= "sandbox" then
		print("StartRound skipped: not enough players")
		return
	end

	self.RoundEnding = false

	local pool = (Rounds and #Rounds > 0) and Rounds or {"homicide", "dm"}
	local chosen = self.RoundNext or table_Random(pool)

	local mode = self:GetMode(chosen)
	if not mode then
		print("Unknown mode '" .. tostring(chosen) .. "', fallback to homicide")
		chosen = "homicide"
		mode = self:GetMode(chosen)
	end
	self.RoundName = chosen

	local roundType = 0
	if mode.HasRoundTypes then
		local maxTypes = mode.TypeCount or 5
		roundType = math_Clamp(tonumber(self.RoundNextType) or math.random(1, maxTypes), 1, maxTypes)
	end

	if self.RoundNext == chosen then
		local nextName = table_Random(pool)
		self.RoundNext = nextName
		local nextMode = self:GetMode(nextName)
		if nextMode and nextMode.HasRoundTypes then
			self.RoundNextType = math.random(1, nextMode.TypeCount or 5)
		else
			self.RoundNextType = 0
		end
	elseif not self.RoundNext then
		self.RoundNext = chosen
		self.RoundNextType = roundType
	end

	if HMCD_HL2Coop and HMCD_HL2Coop.IsHL2Map and HMCD_HL2Coop.IsHL2Map() then
		chosen = "hl2coop"
		mode = self:GetMode(chosen)
		self.RoundName = "hl2coop"
		self.RoundNext = "hl2coop"
		self.RoundNextType = 0
		roundType = 0
	end

	self.RoundType = roundType
	self.RoundCount = (self.RoundCount or 0) + 1
	self.elapsed = CurTime()

	print("round count " .. self.RoundCount .. " | Now: " .. tostring(self.RoundName) .. " Type:" .. tostring(self.RoundType) .. " | Next:" .. tostring(self.RoundNext) .. " NextType:" .. tostring(self.RoundNextType))

	if self.RoundCount == 15 then
		PrintMessage(HUD_PRINTCENTER, "This is the last round before map change!")
	end
	if self.RoundCount >= 16 then
		local maps = file.Find("maps/*.bsp", "GAME")
		local currentMap = string.lower(game.GetMap())
		local validMaps = {}
		for _, mapFile in ipairs(maps) do
			local mapName = string.lower(string.StripExtension(mapFile))
			if mapName ~= currentMap
			and not mapBlacklist[mapName]
			and not string.find(mapName, "^bg_")
			and not string.find(mapName, "^background")
			and not string.find(mapName, "^gui_")
			and not string.find(mapName, "^style_") then
				table.insert(validMaps, mapName)
			end
		end
		local nextMap = (#validMaps > 0) and table_Random(validMaps) or currentMap
		PrintMessage(HUD_PRINTCENTER, "Changing map to " .. nextMap .. "!")
		timer.Simple(5, function()
			game.ConsoleCommand("changelevel " .. nextMap .. "\n")
		end)
		return
	end

	SyncRoundGlobals()
	print("StartRound -> " .. self.RoundName .. " type " .. tostring(self.RoundType))

	for _, ply in player.Iterator() do
		if ply.fake then
			ply.fake = false
			ply:SetNWBool("fake", false)
			ply.fakeragdoll = nil
			ply.FakeShooting = false
			ply:SetNWInt("FakeShooting", false)
		end
		ply.Role = nil
		ply.SecretRole = nil
		ply:SetNWString("RoleShow", "")
		ply:StripAmmo()
		ply:StripWeapons()
	end

	game.CleanUpMap(false, {"env_fire", "entityflame", "_firesmoke"})

	for _, ply in player.Iterator() do
		ply:UnSpectate()
		ply:Spawn()
	end

	timer.Remove("DM_Timer")

	if mode.OnStartPrepare then mode:OnStartPrepare() end

	timer.Simple(0.3, function()
		if GAMEMODE.RoundName ~= chosen then return end
		if mode.OnStart then mode:OnStart() end
		ApplyRoleNames(mode)
		GAMEMODE.RoundState = 1
		SyncRoundGlobals()
	end)

	timer.Simple(0.5, function()
		for _, ply in player.Iterator() do
			net.Start("StartRound")
			net.WriteString(ply:GetNWString("RoleShow", ply.Role or ""))
			net.WriteColor(Color(ply:GetNWInt("RoleColor_R", 255), ply:GetNWInt("RoleColor_G", 255), ply:GetNWInt("RoleColor_B", 255)), true)
			net.Send(ply)
		end
	end)
end

function GM:EndRound(reason, mvp, survived)
	if self.RoundEnding then return end
	self.RoundEnding = true

	local mode = self:GetActiveMode()
	if mode and mode.OnEnd then mode:OnEnd(reason, mvp) end

	PrintMessage(HUD_PRINTTALK, "Round end")
	if hmcd and hmcd.Experience and hmcd.Experience.OnRoundEnd then
		hmcd.Experience.OnRoundEnd()
	end
	self.elapsed = CurTime() - (self.elapsed or CurTime())

	net.Start("EndRound")
		net.WriteUInt(reason, 8)
		net.WriteEntity(mvp or Entity(-1))
		if mvp and IsValid(mvp) and mvp:IsPlayer() then
			net.WriteVector(mvp:GetPlayerColor())
			net.WriteString(mvp:GetNWString("Character_Name", "?"))
			if hmcd and hmcd.Experience then
				hmcd.Experience.AddSkill(mvp, 0.4)
				hmcd.Experience.AddXP(mvp, 200)
			end
		else
			net.WriteVector(Vector(0, 0, 0))
			net.WriteString("?")
		end
		if survived and IsValid(survived) then
			net.WriteString(survived:GetNWString("Character_Name", ""))
		else
			net.WriteString("?")
		end
	net.Broadcast()

	for _, ply in pairs(RecipientFilter():GetPlayers()) do
		net.Start("armor_end_round")
		net.WritePlayer(ply)
		net.Broadcast()
	end

	timer.Remove("DM_Timer")
	self.NoGun = false
	timer.Simple(4.7, function()
		RestoreRoleNames()
		RestoreAppearance()
	end)


	timer.Simple(5, function()
		GAMEMODE:StartRound()
	end)
	self.RoundState = 0
	SyncRoundGlobals()
end

function GM:Think()
	local mode = self:GetActiveMode()

	if mode and mode.WaitForPlayers == false then
		if self.RoundState ~= 1 then self.RoundState = 1 end
		if mode.Think then mode:Think() end
		return
	end

	if #ply_GetAll() < 2 then
		self.RoundState = 2
		return
	end

	if self.RoundState == 0 or self.RoundState == 2 then
		if self.RoundState == 2 then
			self:EndRound(1, table_Random(ply_GetAll()), nil)
		end
		return
	end

	if self.RoundState ~= 1 then return end

	if not mode then
		print("Think: unknown RoundName " .. tostring(self.RoundName))
		return
	end

	if not mode.HasRoundTypes and self.RoundType ~= 0 then
		self.RoundType = 0
		SetGlobalInt("RoundType", 0)
	end

	local alive_ply = (GetAlivePlayerCount and GetAlivePlayerCount()) or 0

	if mode.CheckAllDead ~= false and alive_ply <= 0 then
		self:EndRound(1, table_Random(ply_GetAll()), nil)
		return
	end

	if mode.TimeLimit and self.elapsed and (CurTime() - self.elapsed) >= mode.TimeLimit then
		self:EndRound(3, nil)
		PrintMessage(HUD_PRINTTALK, mode.TimeLimitMessage or "Stopping round because of the time limit..")
		return
	end

	if mode.Think then mode:Think(alive_ply) end
end

hook.Add("PlayerPostThink", "Spectating", function(ply)
	if not ply:GetNWBool("Spectating", false) then return end

	local alive = {}
	for _, p in ipairs(player.GetAll()) do
		if p:Alive() and not p:GetNWBool("Spectating", false) then
			table.insert(alive, p)
		end
	end

	local plyselect = ply:GetNWEntity("SelectPlayer", Entity(-1))
	if not IsValid(plyselect) or not plyselect:Alive() or plyselect:GetNWBool("Spectating", false) then
		if #alive > 0 then
			ply:SetNWEntity("SelectPlayer", table_Random(alive))
		end
	end

	ply.ButtonInput = ply.ButtonInput or 0

	if ply:KeyDown(IN_ATTACK) and ply.ButtonInput < CurTime() then
		ply.ButtonInput = CurTime() + math.random(0.1, 0.5)
		if #alive > 0 then
			local target = table_Random(alive)
			if #alive > 1 then
				for _ = 1, 10 do
					if target ~= ply:GetNWEntity("SelectPlayer") then break end
					target = table_Random(alive)
				end
			end
			ply:SetNWEntity("SelectPlayer", target)
		end
	end
	if ply:KeyDown(IN_ATTACK2) and ply.ButtonInput < CurTime() then
		ply.ButtonInput = CurTime() + math.random(0.1, 0.5)
		if ply:GetNWInt("SpectateMode") == 3 then
			ply:SetNWInt("SpectateMode", 1)
		else
			ply:SetNWInt("SpectateMode", 3)
			ply:UnSpectate()
		end
	end
	if ply:KeyDown(IN_RELOAD) and ply:GetNWInt("SpectateMode") ~= 3 and ply.ButtonInput < CurTime() then
		ply.ButtonInput = CurTime() + math.random(0.1, 0.5)
		ply:SetNWInt("SpectateMode", (ply:GetNWInt("SpectateMode") + 1) % 3)
	end

	if ply:GetNWInt("SpectateMode") == 1 then
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(plyselect)
		ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end

	if ply:GetNWInt("SpectateMode") == 2 then
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SpectateEntity(plyselect)
		ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end

	if ply:GetNWInt("SpectateMode") == 3 then
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SpectateEntity(nil)
		ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end)

hook.Add("PlayerDeathThink", "DeathThink", function(ply)
	local mode = GAMEMODE:GetActiveMode()
	if mode and mode.RespawnAllowed then return true end
	return false
end)

hook.Add("ShouldCollide", "Spect123k", function(a, b)
	if IsValid(a) and a:IsPlayer() and a:GetNWBool("Spectating", false) then return false end
	if IsValid(b) and b:IsPlayer() and b:GetNWBool("Spectating", false) then return false end
end)
