
util.AddNetworkString("hmcd_xp_get")
util.AddNetworkString("get_svPData")

if not plyMeta.GiveKills then
    function plyMeta:GiveKills(num)
        num = num or 1
        self:AddFrags(num)
        local k = (tonumber(self:GetPData("hmcd_kills", 0)) or 0) + num
        self:SetPData("hmcd_kills", k)
    end
end

if not plyMeta.GiveDeaths then
    function plyMeta:GiveDeaths(num)
        num = num or 1
        self:AddDeaths(num)
        local d = (tonumber(self:GetPData("hmcd_deaths", 0)) or 0) + num
        self:SetPData("hmcd_deaths", d)
    end
end

if not plyMeta.GiveSuicides then
    function plyMeta:GiveSuicides(num)
        num = num or 1
        local s = (tonumber(self:GetPData("hmcd_suicides", 0)) or 0) + num
        self:SetPData("hmcd_suicides", s)
    end
end

hook.Add("PlayerInitialSpawn", "HMCD_LoadPlayerSkillXP", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        ply.exp = math.max(0, tonumber(ply:GetPData("hmcd_exp", hmcd.Experience.Config.DefaultXP)) or hmcd.Experience.Config.DefaultXP)
        ply.skill = math.max(0, tonumber(ply:GetPData("hmcd_skill", hmcd.Experience.Config.DefaultSkill)) or hmcd.Experience.Config.DefaultSkill)
        
        ply:SetNWInt("hmcd_exp", ply.exp)
        ply:SetNWFloat("hmcd_skill", ply.skill)
    end)
end)

function hmcd.Experience.AddXP(ply, amount)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local currentXP = ply.exp or tonumber(ply:GetPData("hmcd_exp", 0)) or 0
    ply.exp = math.max(0, currentXP + amount)
    ply:SetPData("hmcd_exp", ply.exp)
    ply:SetNWInt("hmcd_exp", ply.exp)
end

function hmcd.Experience.AddSkill(ply, amount)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local currentSkill = ply.skill or tonumber(ply:GetPData("hmcd_skill", 0)) or 0
    ply.skill = math.max(0, math.Round(currentSkill + amount, 4))
    ply:SetPData("hmcd_skill", ply.skill)
    ply:SetNWFloat("hmcd_skill", ply.skill)
end

function hmcd.Experience.OnKill(attacker, victim)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    
    local xpGain = hmcd.Experience.Config.KillXP
    local victimSkill = IsValid(victim) and (victim.skill or 0) or 0
    local attackerSkill = attacker.skill or 0
    
    local skillGain = hmcd.Experience.Config.KillSkillBase
    if victimSkill > attackerSkill then
        skillGain = skillGain + (victimSkill - attackerSkill) * 0.1
    end
    
    hmcd.Experience.AddXP(attacker, xpGain)
    hmcd.Experience.AddSkill(attacker, skillGain)
    attacker:AddAchiveProgress("genocide", 0.2)
    attacker:AddAchiveProgress("toxicfumes", 0.4)
    attacker:AddAchiveProgress("bones", 1.0)
    if IsValid(victim) and victim:IsPlayer() then
        hmcd.Experience.AddSkill(victim, -hmcd.Experience.Config.DeathSkillLoss)
    end
end

function hmcd.Experience.OnSuicide(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    hmcd.Experience.AddSkill(ply, -hmcd.Experience.Config.SuicideSkillLoss)
    hmcd.Experience.AddXP(ply, -hmcd.Experience.Config.SuicideXPLoss)
    if GAMEMODE.Traitor == ply then
        ply:AddAchiveProgress("murdersuicide", 100)
    end
end

function hmcd.Experience.OnDeath(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    hmcd.Experience.AddSkill(ply, -hmcd.Experience.Config.DeathSkillLoss)
end

function hmcd.Experience.OnRoundEnd()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:IsPlayer() and ply:Alive() and not ply:GetNWBool("Spectating", false) then
            local expGain = math.random(hmcd.Experience.Config.SurvivorMinXP, hmcd.Experience.Config.SurvivorMaxXP)
            local skillGain = math.Round(math.Rand(hmcd.Experience.Config.SurvivorMinSkill, hmcd.Experience.Config.SurvivorMaxSkill), 3)

            hmcd.Experience.AddXP(ply, expGain)
            hmcd.Experience.AddSkill(ply, skillGain)
            if (GAMEMODE.elapsed or 120) < 61 then 
                ply:AddAchiveProgress("speedround", 100)
            end
        end
    end
end

net.Receive("hmcd_xp_get", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    
    net.Start("hmcd_xp_get")
        net.WriteEntity(ent)
        net.WriteFloat(ent.skill or 0)
        net.WriteInt(ent.exp or 0, 19)
    net.Send(ply)
end)

net.Receive("get_svPData", function(len, ply)
    local ent = net.ReadEntity()
    local dataName = net.ReadString()
    if not IsValid(ent) then return end
    
    local val = 0
    if ent["Get" .. dataName] then
        val = ent["Get" .. dataName](ent) or 0
    elseif ent.SvDB and ent.SvDB[dataName] then
        val = ent.SvDB[dataName]
    else
        val = tonumber(ent:GetPData(dataName, 0)) or 0
    end

    net.Start("get_svPData")
        net.WriteEntity(ent)
        net.WriteString(dataName)
        net.WriteFloat(val)
    net.Send(ply)
end)

hmcd.HarmDone = hmcd.HarmDone or {}

local function RecordHarm(target, attacker, damage)
    if IsValid(target) and target:IsPlayer() and IsValid(attacker) and attacker:IsPlayer() then
        hmcd.HarmDone[target] = hmcd.HarmDone[target] or {}
        hmcd.HarmDone[target][attacker] = (hmcd.HarmDone[target][attacker] or 0) + (damage or 0)
    end
end

hook.Add("HOOK_UNION_Damage", "skilllllll", function(ply, hitgroup, dmginfo, rag)
    if IsValid(ply) and dmginfo then
        RecordHarm(ply, dmginfo:GetAttacker(), dmginfo:GetDamage())
    end
end)

hook.Add("EntityTakeDamage", "HMCD_TrackHarm", function(target, dmginfo)
    if IsValid(target) and dmginfo then
        RecordHarm(target, dmginfo:GetAttacker(), dmginfo:GetDamage())
    end
end)

hook.Add("PlayerDeath", "HMCD_GiveKills", function(ply, inflictor, attacker)
    timer.Simple(0.1, function()
        if not IsValid(ply) then return end

        local most_harm, biggest_attacker = 0, nil
        for attacker_ent, attacker_harm in pairs(hmcd.HarmDone[ply] or {}) do
            if IsValid(attacker_ent) and most_harm < attacker_harm then
                most_harm = attacker_harm
                biggest_attacker = attacker_ent
            end
        end

        if not IsValid(biggest_attacker) and IsValid(attacker) and attacker:IsPlayer() then
            biggest_attacker = attacker
        end

        ply:GiveDeaths(1)

        if IsValid(biggest_attacker) then
            if biggest_attacker == ply then
                biggest_attacker:GiveSuicides(1)
                hmcd.Experience.OnSuicide(ply)
            else
                biggest_attacker:GiveKills(1)
                hmcd.Experience.OnKill(biggest_attacker, ply)
            end
        else
            hmcd.Experience.OnDeath(ply)
        end

        hmcd.HarmDone[ply] = nil
    end)
end)
