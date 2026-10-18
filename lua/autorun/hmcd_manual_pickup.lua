local playersCanPickup = {}

hook.Add("PlayerCanPickupWeapon", "PreventAutoPickupWeapon", function(ply, weapon)
    if playersCanPickup[ply] then
        return true
    end

    if not ply:KeyDown(IN_USE) then
        return false
    end
end)

hook.Add("PlayerSpawn", "EnableWeaponPickupOnSpawn", function(ply)
    playersCanPickup[ply] = true
    timer.Simple(2, function()
        if IsValid(ply) then
            playersCanPickup[ply] = false
        end
    end)
end)

hook.Add("PlayerGiveSWEP", "EnablePickupOnGiveSWEP", function(ply, class)
    playersCanPickup[ply] = true
    timer.Simple(1, function()
        if IsValid(ply) then
            playersCanPickup[ply] = false
        end
    end)
end)

hook.Add("PlayerSpawnedSWEP", "EnablePickupOnSpawnedSWEP", function(ply, wep)
    playersCanPickup[ply] = true
    timer.Simple(1, function()
        if IsValid(ply) then
            playersCanPickup[ply] = false
        end
    end)
end)
