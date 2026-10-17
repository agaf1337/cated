local mode = GM:GetMode("homicide")

function mode:GetStartSound()
	local roundType = GetGlobalInt("RoundType", 2)
	if roundType ~= 0 and HMCD_RoundStartSound then
		return HMCD_RoundStartSound[roundType]
	end
end

function mode:GetStartExtraLine(ply)
	local roundType = GetGlobalInt("RoundType", 2)
	if ply:GetNWString("RoleShow", "") == "Gunman" and roundType ~= 5 then
		return {
			text = (roundType == 2 and "with a large weapon") or "with a lawful concealed firearm",
			color = Color(121, 61, 244),
		}
	end
end

mode.EndTitles = {
	[1] = { text = "The traitor wins!", color = Color(190, 20, 20) },
	[2] = { text = "Innocents win!", color = Color(20, 120, 255) },
	[3] = { text = "Draw!", color = Color(223, 223, 223) },
}
