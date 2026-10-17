QiwiSpawnPoints = QiwiSpawnPoints or {}
QiwiSpawnPoints.Points = QiwiSpawnPoints.Points or {}

local DATA_FILE = "qiwi_spawnpoints.txt"
local DELETE_RADIUS = 100

local TEAM_ALIASES = {
	red = "red",
	redd = "red",
	blu = "blu",
	blue = "blu",
}

local ROLE_TO_TEAM = {
	Rebel = "red",
	Combine = "blu",
	Wagner = "red",
	Azov = "blu",
	Rioter = "red",
	Police = "blu",
}

local COLORS = {
	red = Color(255, 60, 60, 50),
	blu = Color(60, 120, 255, 50),
}

local Points = QiwiSpawnPoints.Points

local function CurrentMap()
	return string.lower(game.GetMap())
end

local function SavePoints()
	local dump = {}
	for map, teams in pairs(Points) do
		dump[map] = {}
		for team, list in pairs(teams) do
			dump[map][team] = {}
			for i, p in ipairs(list) do
				dump[map][team][i] = {
					pos = {x = p.pos.x, y = p.pos.y, z = p.pos.z},
					ang = {p = p.ang.p, y = p.ang.y, r = p.ang.r},
				}
			end
		end
	end

	pcall(file.Write, DATA_FILE, util.TableToJSON(dump))
end

local function LoadPoints()
	if not file.Exists(DATA_FILE, "DATA") then return end

	local ok, data = pcall(util.JSONToTable, file.Read(DATA_FILE, "DATA") or "")
	if not ok or not istable(data) then return end

	for map, teams in pairs(data) do
		Points[map] = {}
		for team, list in pairs(teams) do
			Points[map][team] = {}
			for _, p in ipairs(list or {}) do
				if p and p.pos and p.pos.x ~= nil and p.ang and p.ang.p ~= nil then
					table.insert(Points[map][team], {
						pos = Vector(tonumber(p.pos.x) or 0, tonumber(p.pos.y) or 0, tonumber(p.pos.z) or 0),
						ang = Angle(tonumber(p.ang.p) or 0, tonumber(p.ang.y) or 0, tonumber(p.ang.r) or 0),
					})
				end
			end
		end
	end

	local map = Points[CurrentMap()]
	if map then
		print("[QiwiSpawnPoints] " .. CurrentMap() .. ": red = " .. #(map.red or {}) .. ", blu = " .. #(map.blu or {}))
	end
end

local function GetTeamList(team)
	local map = Points[CurrentMap()]
	if not map then return nil end
	return map[team]
end

function QiwiSpawnPoints.GetPoints(team)
	return GetTeamList(team) or {}
end

local function Notify(ply, msg)
	ply:PrintMessage(HUD_PRINTTALK, msg)
end

hook.Add("PlayerSay", "QiwiSpawnPoints_Chat", function(ply, text)
	local args = string.Explode(" ", string.Trim(text))
	local cmd = string.lower(args[1] or "")
	if cmd ~= "!point" and cmd ~= "!delpoint" and cmd ~= "!points" then return end

	if not ply:IsAdmin() then
		Notify(ply, "fuck off")
		return ""
	end

	local map = CurrentMap()
	Points[map] = Points[map] or {red = {}, blu = {}}

	if cmd == "!points" then
		Notify(ply, map .. ": red = " .. #Points[map].red .. ", blu = " .. #Points[map].blu)
		return ""
	end

	if cmd == "!point" then
		local team = TEAM_ALIASES[string.lower(args[2] or "")]
		if not team then
			Notify(ply, "use: !point red/blu")
			return ""
		end

		local eye = ply:EyeAngles()
		table.insert(Points[map][team], {
			pos = ply:GetPos(),
			ang = Angle(0, eye.y, 0),
		})
		SavePoints()

		Notify(ply, team:upper() .. " #" .. #Points[map][team] .. " placed (total: " .. #Points[map][team] .. ")")
		return ""
	end

	local removed = 0
	for _, team in ipairs({"red", "blu"}) do
		local list = Points[map][team]
		for i = #list, 1, -1 do
			if list[i].pos:DistToSqr(ply:GetPos()) <= DELETE_RADIUS * DELETE_RADIUS then
				table.remove(list, i)
				removed = removed + 1
			end
		end
	end

	if removed > 0 then
		SavePoints()
		Notify(ply, "deleted " .. removed .. " (red: " .. #Points[map].red .. ", blu: " .. #Points[map].blu .. ")")
	else
		Notify(ply, "no points in " .. DELETE_RADIUS .. " units")
	end
	return ""
end)

local spawnDummy

hook.Add("PlayerSelectSpawn", "spawnpointsselectqiiw", function(ply)
	local team = ROLE_TO_TEAM[ply.Role or ""] or ROLE_TO_TEAM[ply:GetNWString("RoleShow", "")]
	if not team then return end

	local list = GetTeamList(team)
	if not list or #list == 0 then return end

	local point = list[math.random(#list)]

	if IsValid(spawnDummy) then spawnDummy:Remove() end
	spawnDummy = ents.Create("info_player_start")
	spawnDummy:SetPos(point.pos)
	spawnDummy:SetAngles(point.ang)
	spawnDummy:Spawn()

	timer.Simple(0, function()
		if IsValid(spawnDummy) then
			spawnDummy:Remove()
			spawnDummy = nil
		end
	end)

	ply.QiwiSpawnTeam = team
	return spawnDummy
end)

hook.Add("PlayerSpawn", "QiwiSpawnPoints_Mark", function(ply)
	ply.QiwiSpawnTeam = nil
end)

local TP_WINDOW = 15

timer.Create("QiwiSpawnPoints_TP", 0.1, 0, function()
	if GAMEMODE.RoundState ~= 1 then return end
	if CurTime() - (GAMEMODE.elapsed or 0) > TP_WINDOW then return end

	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and ply:Alive()
		and not ply:GetNWBool("Spectating", false)
		and not ply:GetNWBool("fake", false)
		and ply:GetMoveType() ~= MOVETYPE_NOCLIP then

			local team = ROLE_TO_TEAM[ply.Role or ""] or ROLE_TO_TEAM[ply:GetNWString("RoleShow", "")]
			if team and ply.QiwiSpawnTeam ~= team then
				local list = GetTeamList(team)
				if list and #list > 0 then
					local point = list[math.random(#list)]

					ply:SetVelocity(-ply:GetVelocity())
					ply:SetPos(point.pos + Vector(0, 0, 8))
					ply:SetEyeAngles(point.ang)
					ply.QiwiSpawnTeam = team
				end
			end
		end
	end
end)

timer.Create("debugpointsqiwi", 1, 0, function()
	local map = Points[CurrentMap()]
	if not map then return end

	for team, list in pairs(map) do
		local col = COLORS[team] or color_white
		for i, point in ipairs(list) do
			debugoverlay.Box(point.pos, Vector(-16, -16, 0), Vector(16, 16, 72), 1.1, col, true)
			debugoverlay.Text(point.pos + Vector(0, 0, 76), team .. " #" .. i, 1.1, true)
		end
	end
end)

LoadPoints()

function QiwiSpawnPoints.Add(team, pos, ang)
	team = TEAM_ALIASES[string.lower(tostring(team or ""))]
	if not team then return nil end

	local map = CurrentMap()
	Points[map] = Points[map] or {red = {}, blu = {}}

	table.insert(Points[map][team], {
		pos = pos,
		ang = ang or Angle(0, 0, 0),
	})
	SavePoints()

	return team, #Points[map][team]
end

function QiwiSpawnPoints.DeleteNear(pos, radius)
	radius = radius or DELETE_RADIUS

	local map = Points[CurrentMap()]
	if not map then return 0 end

	local removed = 0
	for _, team in ipairs({"red", "blu"}) do
		local list = map[team]
		for i = #list, 1, -1 do
			if list[i].pos:DistToSqr(pos) <= radius * radius then
				table.remove(list, i)
				removed = removed + 1
			end
		end
	end

	if removed > 0 then SavePoints() end
	return removed
end
