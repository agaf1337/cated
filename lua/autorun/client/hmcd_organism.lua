surface.CreateFont("DebugMinimal", {
    font = "Roboto", // а че не coolvetica не юзаешь???
    size = 14,
    weight = 400,
    antialias = true
})

hook.Add("PostDrawHUD", "halloo", function()
    if !GetConVar("developer"):GetBool() then return end
    if !LocalPlayer():IsSuperAdmin() then return end
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local fat     = ply:GetNWInt("org_fat", 0)
    local stamina = ply.stamina and math.Round(ply.stamina["int"] or 0, 1) or "N/A"
    local lleg    = ply.stamina and math.Round(ply.stamina["lleg"] or 1, 2) or "N/A"
    local rleg    = ply.stamina and math.Round(ply.stamina["rleg"] or 1, 2) or "N/A"

    local x = 15
    local y = ScrH() * 0.4
    local w = 110
    local h = 85

    local function drawDebugLine(text, offset)
        draw.SimpleText(text, "DebugMinimal", x + 10, y + offset, Color(240, 240, 240), Color(0, 0, 0, 200), 1, 1)
    end

    drawDebugLine("fat: " .. fat, 12)
    drawDebugLine("stm: " .. stamina, 30)
    drawDebugLine("lleg: " .. lleg, 48)
    drawDebugLine("rleg: " .. rleg, 66)
    drawDebugLine("sex: " .. ply.ModelSex or "nonbinary", 84 )// фу секс //О ДА СЕКС
    drawDebugLine("stamina: " .. ply:GetNWInt("stamina"), 98)
    drawDebugLine("pulse: " .. ply:GetNWInt("pulse"), 128)
    drawDebugLine("exhausted: " .. ply:GetNWInt("exhausted"), 145)
end)

