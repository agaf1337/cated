local SKIP_ROLES = {
	Combine = true,
	Wagner = true,
	Azov = true,
	Police = true,
}

local function ReapplyAccessory(ply)
	if not IsValid(ply) or not ply:Alive() then return end
	if ply:GetNWBool("fake", false) then return end
	if SKIP_ROLES[ply.Role or ""] then return end

	local cur = ply.Accessory
	if cur and cur ~= "" and cur ~= "none" then return end

	local want = ply.CustomAccessory
	if not want or want == "" or want == "none" then return end

	ply:SetAccessory(want)
end

local function ClearOutfitFields()
	for _, ply in ipairs(player.GetAll()) do
		ply.HL2_Outfit = nil
		ply.Wagner_Outfit = nil
		ply.Riot_Outfit = nil
	end
end

hook.Add("PlayerSpawn", "Qiwi_AccSync_Spawn", function(ply)
	timer.Simple(0.6, function()
		ReapplyAccessory(ply)
	end)
	timer.Simple(1.6, function()
		ReapplyAccessory(ply)
	end)
end)

timer.Create("Qiwi_AccSync_Periodic", 10, 0, function()
	if GAMEMODE.RoundState ~= 1 then
		ClearOutfitFields()
	end

	for _, ply in ipairs(player.GetAll()) do
		ReapplyAccessory(ply)
	end
end)

timer.Create("Qiwi_AccSync_Broadcast", 25, 0, function()
	local all = player.GetAll()
	if #all == 0 then return end

	for _, ply in ipairs(all) do
		local acc = ply.Accessory
		if acc and acc ~= "" and acc ~= "none" then
			net.Start("accessory")
				net.WriteEntity(ply)
				net.WriteString(ply.ModelSex or "male")
				net.WriteString(acc)
			net.Send(all)
		end
	end
end)
