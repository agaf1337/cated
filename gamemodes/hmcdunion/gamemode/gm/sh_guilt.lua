local PlayerMeta = FindMetaTable("Player")

local Guilt_Sentences = {
    "Seizure",
    "Thunder"
}

local Guilt_Phrases = {
    "The voices won't stop...",
    "The blood on your hands won't wash off.",
    "Your conscience is screaming...",
    "You feel a terrible weight on your chest.",
    "The ghosts of the past are here.",
    "Me when consequences of my actions enter the room:"
}

local function InitGuilt(ply)
    if not IsValid(ply) then return end
    local saved = ply:GetPData("U_Guilt", 0)
    ply.guilth = tonumber(saved) or 0
    ply:SetNWInt("Guilt", ply.guilth)
    ply.GuiltAttackers = {}
    ply.WrongfullyKilled = false
    ply.DeathTime = 0
end

hook.Add("PlayerInitialSpawn", "Guilt_Init_Spawn", InitGuilt)
hook.Add("PlayerSpawn", "Guilt_Init_ReSpawn", function(ply)
    InitGuilt(ply)
    ply.WrongfullyKilled = false
    ply.GuiltAttackers = {}
    ply.DeathTime = 0
    if SERVER then
        net.Start("Guilt_SetWrongfulState")
        net.WriteBool(false)
        net.Send(ply)
    end
end)

function PlayerMeta:GuiltAdd(count)
    self.guilth = (self.guilth or 0) + count
    self:SetNWInt("Guilt", self.guilth)
    self:SetPData("U_Guilt", self.guilth)
end

function PlayerMeta:GuiltSet(count) 
    self.guilth = count
    self:SetNWInt("Guilt", count)
    self:SetPData("U_Guilt", count)
end

if SERVER then
    util.AddNetworkString("Guilt_OpenForgiveness")
    util.AddNetworkString("Guilt_OpenForgiveness_Menu")
    util.AddNetworkString("Guilt_ForgiveRequest")
    util.AddNetworkString("Guilt_SetWrongfulState")

    net.Receive("Guilt_OpenForgiveness", function(len, ply)
        if not IsValid(ply) or ply:Alive() then return end
        
        ply.LastForgiveOpen = ply.LastForgiveOpen or 0
        if CurTime() - ply.LastForgiveOpen < 0.5 then return end
        ply.LastForgiveOpen = CurTime()

        if not ply.WrongfullyKilled then return end

        local attackersData = {}
        if ply.GuiltAttackers then
            for att, gAmount in pairs(ply.GuiltAttackers) do
                if IsValid(att) and att:IsPlayer() then
                    attackersData[att:UserID()] = { name = att:Nick(), guiltCaused = gAmount, currentGuilt = att.guilth or 0 }
                end
            end
        end

        net.Start("Guilt_OpenForgiveness_Menu")
        net.WriteTable(attackersData)
        net.Send(ply)
    end)

    net.Receive("Guilt_ForgiveRequest", function(len, ply)
        if not IsValid(ply) or ply:Alive() then return end

        ply.LastForgiveReq = ply.LastForgiveReq or 0
        if CurTime() - ply.LastForgiveReq < 0.3 then return end
        ply.LastForgiveReq = CurTime()

        local targetUserID = net.ReadUInt(16)
        local percent = net.ReadUInt(8)

        local targetAttacker = Player(targetUserID)
        if not IsValid(targetAttacker) or not targetAttacker:IsPlayer() then return end
        if percent ~= 50 and percent ~= 100 then return end

        if not ply.GuiltAttackers or not ply.GuiltAttackers[targetAttacker] then
            return
        end

        local guiltCaused = ply.GuiltAttackers[targetAttacker]
        if guiltCaused <= 0 then return end

        local guiltToRemove = math.ceil(guiltCaused * (percent / 100))
        local newGuilt = math.max(0, (targetAttacker.guilth or 0) - guiltToRemove)
        
        targetAttacker:GuiltSet(newGuilt)
        ply.GuiltAttackers[targetAttacker] = nil

        ply:PrintMessage(HUD_PRINTTALK, "You have forgiven " .. targetAttacker:Nick() .. " (" .. percent .."%).")
        targetAttacker:PrintMessage(HUD_PRINTTALK, "You have been forgiven.")
    end)
end

hook.Add("HOOK_UNION_Damage", "GuiltLogic", function(ply, hitgroup, dmginfo, rag)
    local victim = ply
    local attacker = dmginfo:GetAttacker()

    if not attacker:IsPlayer() and isfunction(attacker.GetOwner) then
        attacker = attacker:GetOwner()
    end

    if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

    if attacker.guilth == nil then InitGuilt(attacker) end

    if dmginfo:GetDamage() > 5 then
        local attRole = attacker.Role or attacker:GetNWString("Role", "Innocent")
        if attRole ~= "Traitor" and attRole ~= "Murderer" then
            attacker:SetNWBool("LostInnocence", true)
            timer.Create("InnocenceReset_" .. attacker:EntIndex(), 60, 1, function()
                if IsValid(attacker) then attacker:SetNWBool("LostInnocence", false) end
            end)
        end
    end

    if attacker.guilth >= 90 then
        local multiplier = math.Clamp(1 - ((attacker.guilth - 50) / 70), 0.1, 1)
        dmginfo:ScaleDamage(multiplier)
    end

    local rname = GetGlobalString("RoundName", "")
    if rname == "dm" or rname == "hl2" or rname == "sandbox" then return end

    local attRole = attacker.Role or attacker:GetNWString("Role", "Innocent")
    local vicRole = victim.Role or victim:GetNWString("Role", "Innocent")

    if attRole == vicRole and attRole ~= "Traitor" and attRole ~= "Murderer" then
        local guiltint = math.ceil(dmginfo:GetDamage() / math.random(2, 4))
        attacker:GuiltAdd(guiltint)

        victim.GuiltAttackers = victim.GuiltAttackers or {}
        victim.GuiltAttackers[attacker] = (victim.GuiltAttackers[attacker] or 0) + guiltint
        victim.WrongfullyKilled = true
        victim.DeathTime = victim.DeathTime or CurTime()

        if SERVER then
            net.Start("Guilt_SetWrongfulState")
            net.WriteBool(true)
            net.Send(victim)
        end

        if attacker.guilth >= 100 then
            if attacker.Notify then
                attacker:Notify(table.Random(Guilt_Phrases), true, Color(200, 0, 0), false)
            end
            
            attacker.Guilt_Sentence = table.Random(Guilt_Sentences)
            attacker:AddAchiveProgress("guilt", 100)
        end
    end
end)

hook.Add("PlayerDeath", "Guilt_DeathCheck", function(victim, inflictor, attacker)
    if not IsValid(victim) or not victim:IsPlayer() then return end
    if not attacker:IsPlayer() and isfunction(attacker.GetOwner) then
        attacker = attacker:GetOwner()
    end
    if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
        local attRole = attacker.Role or attacker:GetNWString("Role", "Innocent")
        local vicRole = victim.Role or victim:GetNWString("Role", "Innocent")
        if (attRole == vicRole and attRole ~= "Traitor" and attRole ~= "Murderer") or (victim.GuiltAttackers and victim.GuiltAttackers[attacker]) then
            victim.WrongfullyKilled = true
            victim.DeathTime = CurTime()
            if SERVER then
                net.Start("Guilt_SetWrongfulState")
                net.WriteBool(true)
                net.Send(victim)
            end
        end
    end
end)

hook.Add("Player Think", "GuiltThink", function(ply)
    if ply.Guilt_Sentence == "Seizure" then
        ply.Guilt_Sentence = nil
        ply.Seizure = true
        ply.SeizureReps = 0
        if math.random(1, 2) == 1 then Faking(ply) end
    elseif ply.Guilt_Sentence == "Thunder" then
        ply.Guilt_Sentence = nil
        sound.Play("snd_jack_hmcd_lightning.wav", ply:GetPos(), 100, 100, 1)
        local effectdata = EffectData()
        effectdata:SetOrigin(ply:GetPos())
        util.Effect("cball_explode", effectdata)
        local d = DamageInfo()
        d:SetDamage( 90 )
        d:SetAttacker( ply )
        d:SetDamageType( DMG_SHOCK ) 
        ply:TakeDamageInfo( d )
    end
    if ply.guilth >= 175 then
        ply:GuiltSet(50)
        if ulx and ulx.ban then
            ulx.ban("Guilt", ply, 30, "Killing innocents and teammates.")
        end
    end
end)

hook.Add("Think", "SeizureRun", function()
    for _, ply in ipairs(player.GetAll()) do
        if ply.Seizure then
            ply.NextSeizure = ply.NextSeizure or 0
            if CurTime() > ply.NextSeizure then
                ply.NextSeizure = CurTime() + 0.15
                
                ply.SeizureReps = (ply.SeizureReps or 0) + 1
                ply:ViewPunch(Angle(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50)))

                ply:ConCommand("+attack")
                timer.Simple(0.05, function() if IsValid(ply) then ply:ConCommand("-attack") end end)

                if ply.SeizureReps >= 20 then
                    ply.Seizure = false
                    ply.SeizureReps = 0
                end
            end
        end
    end
end)

if CLIENT then
    net.Receive("Guilt_SetWrongfulState", function()
        local state = net.ReadBool()
        local ply = LocalPlayer()
        if IsValid(ply) then
            ply.WrongfullyKilled = state
            if state then
                ply.ClientDeathTime = CurTime()
            end
        end
    end)

    local function drawTextShadow(text, font, x, y, color, align)
        draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 255), align, align)
        draw.SimpleText(text, font, x, y, color, align, align)
    end

    hook.Add("PostDrawHUD", "Guilt_WrongfulDeathHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or ply:Alive() then return end
        
        if ply.WrongfulKilled then
            ply.ClientDeathTime = ply.ClientDeathTime or CurTime()
            if CurTime() - ply.ClientDeathTime <= 10 then
                local sw, sh = ScrW(), ScrH()
                drawTextShadow("You've been wrongfully killed", "FontSmall", sw / 2, sh / 1.35, Color(158, 1, 1), TEXT_ALIGN_CENTER)
                drawTextShadow("Press F to open forgiveness menu", "FontSmall", sw / 2, sh / 1.3, Color(134, 1, 1), TEXT_ALIGN_CENTER)
            end
        end
    end)

    hook.Add("PlayerButtonDown", "Guilt_OpenMenuKey", function(ply, button)
        if CLIENT and ply == LocalPlayer() and button == KEY_F then
            if not ply:Alive() and ply.WrongfullyKilled then
                net.Start("Guilt_OpenForgiveness")
                net.SendToServer()
            end
        end
    end)

    net.Receive("Guilt_OpenForgiveness_Menu", function()
        local attackersData = net.ReadTable()
        if not attackersData or table.IsEmpty(attackersData) then
            chat.AddText(Color(255, 50, 50), "No teammates to forgive.")
            return
        end

        local frame = vgui.Create("DFrame")
        frame:SetSize(450, 300)
        frame:Center()
        frame:SetTitle("Forgiveness Menu")
        frame:MakePopup()

        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(5, 5, 5, 5)

        for userID, data in pairs(attackersData) do
            local attPlayer = Player(userID)
            local displayName = IsValid(attPlayer) and attPlayer:Nick() or data.name

            local panel = scroll:Add("DPanel")
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetTall(50)
            panel:SetBackgroundColor(Color(40, 40, 40, 200))

            local lbl = vgui.Create("DLabel", panel)
            lbl:Dock(LEFT)
            lbl:DockMargin(10, 0, 0, 0)
            lbl:SetWide(200)
            lbl:SetText(displayName .. "\nGuilt Caused: " .. data.guiltCaused .. " | Total: " .. data.currentGuilt)
            lbl:SetTextColor(Color(255, 255, 255))

            local btn100 = vgui.Create("DButton", panel)
            btn100:Dock(RIGHT)
            btn100:DockMargin(5, 10, 10, 10)
            btn100:SetWide(80)
            btn100:SetText("Forgive 100%")
            btn100.DoClick = function()
                net.Start("Guilt_ForgiveRequest")
                net.WriteUInt(userID, 16)
                net.WriteUInt(100, 8)
                net.SendToServer()
                frame:Close()
            end

            local btn50 = vgui.Create("DButton", panel)
            btn50:Dock(RIGHT)
            btn50:DockMargin(5, 10, 0, 10)
            btn50:SetWide(80)
            btn50:SetText("Forgive 50%")
            btn50.DoClick = function()
                net.Start("Guilt_ForgiveRequest")
                net.WriteUInt(userID, 16)
                net.WriteUInt(50, 8)
                net.SendToServer()
                frame:Close()
            end
        end
    end)
end
