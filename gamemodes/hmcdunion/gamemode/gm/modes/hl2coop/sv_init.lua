local mode = GM:GetMode("hl2coop")

function mode:OnStart()
	for _, ply in ipairs(player.GetAll()) do
		ply.Role = "Player"
		ply:SetNWString("RoleShow", "Player")
	end
end
