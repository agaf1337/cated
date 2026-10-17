if SERVER then
    
    util.AddNetworkString("WaterCleaner_RemoveDecals")
    
    hook.Add("Think", "WaterDecalCleaner", function()
        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) or not ply:Alive() then continue end
            
            if ply:WaterLevel() == 3 then
                net.Start("WaterCleaner_RemoveDecals")
                    net.WriteEntity(ply)
                net.Broadcast()
            end
        end
    end)

end

if CLIENT then
    
    net.Receive("WaterCleaner_RemoveDecals", function()
        local ply = net.ReadEntity()
        if IsValid(ply) then
            ply:RemoveAllDecals()
        end
    end)

end