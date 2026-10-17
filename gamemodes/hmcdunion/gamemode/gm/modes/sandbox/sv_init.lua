local mode = GM:GetMode("sandbox")

local NextRespawnCheck = 0

function mode:Think()
	if CurTime() < NextRespawnCheck then return end
	NextRespawnCheck = CurTime() + 2

	for _, ply in ipairs(player.GetAll()) do
		if IsValid(ply) and not ply:Alive() then
			ply.fake = false
			ply:SetNWBool("fake", false)
			if IsValid(ply.fakeragdoll) then
				ply.fakeragdoll:Remove()
				ply.fakeragdoll = nil
			end
			ply:UnSpectate()
			ply:Spawn()
		end
	end
end

hook.Add("Vars Player", "ammoou", function(ply)
	if GAMEMODE.RoundName == "sandbox" then
		ply:GiveAmmo(400, "Pistol", true)
		ply:GiveAmmo(400, "Ar2", true)
		ply:GiveAmmo(200, "smg", true)
		ply:GiveAmmo(200, "buckshot", true)
		ply:GiveAmmo(200, "357", true)
	end
end)

local WHITELIST = {
	ents = {
		["grenade_helicopter"] = true,
		["gmod_button"] = true,
		["gmod_light"] = true,
	},
	weapons = {
		["wep_jack_hmcd_m249"] = true,
		["wep_jack_hmcd_chlorine"] = true,
		["wep_jack_hmcd_poisoncanister"] = true,
		["wep_jack_hmcd_smokebomb"] = true,
		["weapon_rpg"] = true,
	},
	tools = {
		["weld"] = true,
		["axis"] = true,
		["rope"] = true,
		["remover"] = true,
		["nocollide"] = true,
		["colour"] = true,
		["material"] = true,
		["duplicator"] = false,
	},
}

local function IsSandbox()
	local n = ""
	if GAMEMODE and GAMEMODE.RoundName then
		n = GAMEMODE.RoundName
	else
		n = GetGlobalString("RoundName", "")
	end
	return string.lower(n) == "sandbox"
end

local function IsAdmin(ply)
	if not IsValid(ply) then return false end
	if ply:IsAdmin() or ply:IsSuperAdmin() then return true end
end

local function Notify(ply, msg)
	if IsValid(ply) then ply:ChatPrint(msg) end
end

local COOLDOWN = 60

local function BlockWeapon(ply, class)
	if IsAdmin(ply) then return end
	if not IsSandbox() then return end
	if WHITELIST.weapons[class] then
		Notify(ply, tostring(class) .. " is blacklisted!")
		return false
	end
	if ply._nextWeaponGive and ply._nextWeaponGive > CurTime() then
		local left = math.ceil(ply._nextWeaponGive - CurTime())
		Notify(ply, "cooldown " .. left .. " seconds")
		return false
	end
	ply._nextWeaponGive = CurTime() + COOLDOWN
end

hook.Add("PlayerSpawnSWEP", "Whitelist_Weapon", BlockWeapon)
hook.Add("PlayerGiveSWEP", "Whitelist_GiveWeapon", BlockWeapon)
hook.Add("PlayerSpawnSENT", "Whitelist_WeaponSENT", function(ply, class)
	if WHITELIST.weapons[class] then return end
	return BlockWeapon(ply, class)
end)
hook.Add("CanTool", "Whitelist_Tool", function(ply, tr, tool)
	if IsAdmin(ply) then return end
	if not IsSandbox() then return end
	if WHITELIST.tools[tool] == false then
		Notify(ply, "tool forbidden " .. tool)
		return false
	end
end)

RunConsoleCommand("sbox_noclip", "0")
