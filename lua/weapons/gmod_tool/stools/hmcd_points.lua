TOOL.Category = "Homicide"
TOOL.Name = "points"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar = {
    ["team"] = "red"
}

if CLIENT then
    language.Add("tool.hmcd_points.name", "123")
    language.Add("tool.hmcd_points.desc", "team points")
    language.Add("tool.hmcd_points.0", "LMB - place , RMB - remove , reload - stats")

    TOOL.Information = {
        { name = "left", stage = 0 },
        { name = "right", stage = 0 },
        { name = "reload", stage = 0 }
    }
end

TOOL.ClientConVar = {
    ["team"] = "red"
}

function TOOL:DrawHUD()
    if SERVER then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    local trace = ply:GetEyeTrace()
    if not trace.Hit then return end

    local team = self:GetClientInfo("team")

    cam.Start3D()
        render.DrawWireframeSphere(trace.HitPos, 5, 8, 5, Color(81,255,0,200), false)

        render.DrawWireframeSphere(trace.HitPos, 100, 8, 8, Color(255, 0, 0, 200), false)
    cam.End3D()
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    if not trace.Hit then return false end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    if not ply:IsAdmin() then
        ply:ChatPrint("fuck off")
        return false
    end

    local team = self:GetClientInfo("team")
    local ang = Angle(0, ply:EyeAngles().y, 0)

    local teamN, idx = QiwiSpawnPoints.Add(team, trace.HitPos, ang)
    if not teamN then
        ply:ChatPrint("Bad team (use red/blu in panel)")
        return false
    end

    local eff = EffectData()
    eff:SetOrigin(trace.HitPos)
    util.Effect("cball_explode", eff)

    ply:ChatPrint(teamN .. " spawnpoint #" .. idx .. " placed")
    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    if not trace.Hit then return false end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    if not ply:IsAdmin() then
        ply:ChatPrint("fuck off")
        return false
    end

    local removed = QiwiSpawnPoints.DeleteNear(trace.HitPos, 100)

    if removed > 0 then
        local eff = EffectData()
        eff:SetOrigin(trace.HitPos)
        util.Effect("GlassBusterEffect", eff)

        ply:ChatPrint("Deleted spawnpoints: " .. removed)
    else
        ply:ChatPrint("No spawnpoints near")
    end
    return true
end

function TOOL:Reload(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    if not ply:IsAdmin() then return false end

    local red = #QiwiSpawnPoints.GetPoints("red")
    local blu = #QiwiSpawnPoints.GetPoints("blu")

    ply:ChatPrint("Spawnpoints on " .. game.GetMap() .. ": red = " .. red .. ", blu = " .. blu)
    return true
end

function TOOL.BuildCPanel(CPanel)
    local hdr = CPanel:Help("LMB - place , RMB - remove , reload - stats")
    hdr:SetWrap(true)

    local combo = CPanel:ComboBox("team", "team")
    combo:AddChoice("red", "red")
    combo:AddChoice("blu", "blu")
end
