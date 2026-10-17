local hRun = hook.Run

hook.Add("RoundPlayerVar", "FUNC_VAR", function(ply)
    local mode = GAMEMODE:GetActiveMode()
    local role = (mode and mode.DefaultRole) or "Bystander"

    ply.Role = role
    ply:SetNWString("RoleShow", role)

    ply.SecretRole = ""
    ply:SetNWString("SecretRole", "")
    ply:SetRoleColor(57, 62, 213)
end)

hook.Add("PlayerSpawn", "RoundPlayerVar_Spawn", function(ply)
    if PLYSPAWN_OVERRIDE then return end
    hRun("RoundPlayerVar", ply)
end)
