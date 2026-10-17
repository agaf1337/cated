if SERVER then
    AddCSLuaFile()
    SWEP.Spawnable = true
    SWEP.Primary.Ammo = SWEP.AmmoType
end
if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("OneHandedToggle")
    util.AddNetworkString("OneHandedPunishment")
    local oneHandedPlayers = {}
    concommand.Add("hmcd_onehanded", function(ply, cmd, args)
        if not IsValid(ply) then return end
        if ply:GetNWBool("ane_la") then ply:Notify("I can't hold my gun with the broken hand..", false, Color(214,214,214), true) return end
        if ply:GetNWBool("ane_ra") then ply:Notify("I can't hold my gun with the only broken hand..", false, Color(214,214,214), true) return end
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or not weapon.CanOneHanded then
            return
        end
        if weapon.GetReady and not weapon:GetReady() then return end
        if weapon.GetSuicide and weapon:GetSuicide() > 0 then return end
        oneHandedPlayers[ply:SteamID()] = not oneHandedPlayers[ply:SteamID()]
        local isOneHanded = oneHandedPlayers[ply:SteamID()]
        net.Start("OneHandedToggle")
        net.WriteBool(isOneHanded)
        net.Send(ply)
    end)
    function IsPlayerOneHanded(ply)
        return oneHandedPlayers[ply:SteamID()] or ply:GetNWBool("ane_la", false)
    end
    hook.Add("PlayerDisconnected", "OneHandedCleanup", function(ply)
        local steamID = ply:SteamID()
        oneHandedPlayers[steamID] = nil
        weaponReadyStates[steamID] = nil
        if ply.oneHandedBeforeReload then
            ply.oneHandedBeforeReload = nil
        end
    end)
    local lastShotTime = {}
    local rapidFireCount = {}
    /*hook.Add("EntityFireBullets", "OneHandedPunishment", function(ent, data)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if not IsPlayerOneHanded(ent) then return end
        local weapon = ent:GetActiveWeapon()
        if not IsValid(weapon) or not true then return end
        local steamID = ent:SteamID()
        local currentTime = CurTime()
        if not lastShotTime[steamID] then
            lastShotTime[steamID] = 0
            rapidFireCount[steamID] = 0
        end
        if currentTime - lastShotTime[steamID] < 0.5 then
            rapidFireCount[steamID] = rapidFireCount[steamID] + 1
        else
            rapidFireCount[steamID] = 0
        end
        lastShotTime[steamID] = currentTime
        if rapidFireCount[steamID] >= 2 then
            if math.random() < 0.7 then
                ent:DropWeapon(weapon)
            end
            rapidFireCount[steamID] = 0
        end
    end)*/
    local weaponReadyStates = {}
    hook.Add("Think", "OneHandedSuicideCheck", function()
        if not SERVER or not oneHandedPlayers then return end
        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) then continue end
            local weapon = ply:GetActiveWeapon()
            if not IsValid(weapon) or not weapon.CanOneHanded then continue end
            local steamID = ply:SteamID()
            if weapon.GetReady then
                local isReady = weapon:GetReady()
                local wasReady = weaponReadyStates[steamID]
                local currentOneHanded = oneHandedPlayers[steamID] or false
                if wasReady == nil then
                    weaponReadyStates[steamID] = isReady
                    wasReady = isReady
                end
                if not isReady and wasReady then
                    if currentOneHanded and not ply.oneHandedBeforeReload then
                        ply.oneHandedBeforeReload = true
                        oneHandedPlayers[steamID] = false
                        net.Start("OneHandedToggle")
                        net.WriteBool(false)
                        net.Send(ply)
                    end
                elseif isReady and not wasReady then
                    if ply.oneHandedBeforeReload then
                        ply.oneHandedBeforeReload = nil
                    end
                end
                weaponReadyStates[steamID] = isReady
            end
            if weapon.GetSuicide then
                local inSuicide = weapon:GetSuicide() > 0
                local wasOneHanded = oneHandedPlayers[steamID] or false
                if inSuicide and not wasOneHanded and not ply.oneHandedAutoEnabled then
                    oneHandedPlayers[steamID] = true
                    ply.oneHandedAutoEnabled = true
                    net.Start("OneHandedToggle")
                    net.WriteBool(true)
                    net.Send(ply)
                elseif not inSuicide and ply.oneHandedAutoEnabled then
                    oneHandedPlayers[steamID] = false
                    ply.oneHandedAutoEnabled = nil
                    net.Start("OneHandedToggle")
                    net.WriteBool(false)
                    net.Send(ply)
                end
            end
        end
    end)
end
if SERVER then
    util.AddNetworkString("switch fire mode") //horrible

    net.Receive("switch fire mode",function(len, ply)
        local wep = ply:GetActiveWeapon()
        if !wep.SwitchFM then return end
        wep.Primary.Automatic = !wep.Primary.Automatic
    end)
end