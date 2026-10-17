hmcd = hmcd or {}
hmcd.Achievements = hmcd.Achievements or {}
hmcd.Achievements.List = hmcd.Achievements.List or {}
hmcd.Experience = hmcd.Experience or {}

local plyMeta = FindMetaTable("Player")

function hmcd.Achievements.CreateAchievement(key, name, description, icon)
    if not key then return end

    hmcd.Achievements.List[key] = {
        key = key,
        name = name or key,
        description = description or "",
        icon = icon or "vgui/entities/tfa_nmrih_hatchet"
    }
end

function hmcd.Achievements.GetAchievements(self, key)
    if not IsValid(self) then return 0 end
    if not key then return 0 end

    self.HMCD_Achievements = self.HMCD_Achievements or {}

    if self.HMCD_Achievements[key] then
        return self.HMCD_Achievements[key]
    end

    if SERVER then
        local pDataVal = tonumber(self:GetPData("hmcd_ach_" .. key, 0)) or 0
        self.HMCD_Achievements[key] = pDataVal
        return pDataVal
    end

    return self.HMCD_Achievements[key] or 0
end

hmcd.Experience.GetAchievements = hmcd.Achievements.GetAchievements

function plyMeta:GetAchive(key)
    if CLIENT then
        net.Start("hmcd_ach_get")
            net.WriteEntity(self)
            net.WriteString(key)
        net.SendToServer()
    end
    return hmcd.Achievements.GetAchievements(self, key)
end

function plyMeta:AddAchiveProgress(key, amount)
    if not SERVER then return end
    if not IsValid(self) or not key then return end

    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    self.HMCD_Achievements = self.HMCD_Achievements or {}

    local current = hmcd.Achievements.GetAchievements(self, key)
    local wasUnlocked = (current >= 100)

    local newProgress = math.Clamp(current + amount, 0, 100)
    self.HMCD_Achievements[key] = newProgress

    self:SetPData("hmcd_ach_" .. key, newProgress)

    net.Start("hmcd_ach_sync")
        net.WriteString(key)
        net.WriteFloat(newProgress)
    net.Send(self)

    if newProgress >= 100 and not wasUnlocked then
        net.Start("hmcd_ach_unlocked")
            net.WriteString(key)
        net.Send(self)
    end
end

hmcd.Achievements.CreateAchievement("speedround", "Speed Run", "End round in less than 60 seconds", "achievements/speedrun")
hmcd.Achievements.CreateAchievement("twin", "Bloody Souvenir", "Win round as a traitor", "achievements/bloodysouvenir")
hmcd.Achievements.CreateAchievement("1000lives", "A thousand lives", "Spawn 1000 times", "achievements/thousandlives")
hmcd.Achievements.CreateAchievement("genocide", "Genocide", "Kill 500 people", "achievements/genocide")
hmcd.Achievements.CreateAchievement("toxicfumes", "Toxic Fumes", "Kill 250 people", "achievements/toxicfumes")
hmcd.Achievements.CreateAchievement("bones", "Bones", "Kill 100 people", "achievements/bones")
hmcd.Achievements.CreateAchievement("guilt", "Guilty", "Get punished by guilt", "achievements/guilt_1")
hmcd.Achievements.CreateAchievement("murdersuicide", "Murder Suicide", "Kill yourself as a traitor", "achievements/murdersuicide")
hmcd.Achievements.CreateAchievement("sweetdreams", "Sweet Dreams", "Get unconscious", "achievements/sweetdreams")


