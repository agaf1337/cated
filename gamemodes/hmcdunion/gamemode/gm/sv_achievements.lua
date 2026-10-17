util.AddNetworkString("hmcd_ach_get")
util.AddNetworkString("hmcd_ach_sync")
util.AddNetworkString("hmcd_ach_unlocked")

net.Receive("hmcd_ach_get", function(len, ply)
    local target = net.ReadEntity()
    local key = net.ReadString()

    if not IsValid(target) or not key then return end

    local progress = hmcd.Achievements.GetAchievements(target, key)

    net.Start("hmcd_ach_sync")
        net.WriteString(key)
        net.WriteFloat(progress)
    net.Send(ply)
end)