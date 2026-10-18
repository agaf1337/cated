hmcd = hmcd or {}
hmcd.Experience = hmcd.Experience or {}

local EXP = hmcd.Experience
EXP.OpenedMenu = EXP.OpenedMenu or nil
EXP.OpenedAccount = EXP.OpenedAccount or nil

surface.CreateFont("HMCD_MedalTitle", {
    font = "coolvetica",
    size = 28,
    weight = 500,
    antialias = true,
    italic = false
})

surface.CreateFont("HMCD_MedalText", {
    font = "coolvetica",
    size = 22,
    weight = 500,
    antialias = true,
    italic = false
})

surface.CreateFont("HMCD_MedalSubText", {
    font = "coolvetica",
    size = 18,
    weight = 500,
    antialias = true,
    italic = false
})

surface.CreateFont("FontSmall2", {
    font = "coolvetica",
    size = ScreenScale(10),
    weight = 555, //ТРИСТА ТРИДЦЭТ ТРИ
    antialias = true,
    italic = false
})

local PANEL = {}

local function RenderMedalBox(w, h)
    local boxSize = math.min(w, h) - 20
    local x = (w - boxSize) / 2
    local y = (h - boxSize) / 2

    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawTexturedRect(x + 4, y + 4, boxSize, boxSize)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(x, y, boxSize, boxSize)
end

function PANEL:Init()
    self.Player = nil

    self.MainPanel = vgui.Create("DPanel", self)
    self.MainPanel:Dock(FILL)
    function self.MainPanel:Paint(w, h)
        surface.SetDrawColor(color_black)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.PlyLabel = vgui.Create("DLabel", self.MainPanel)
    self.PlyLabel:Dock(TOP)
    self.PlyLabel:SetContentAlignment(5)
    self.PlyLabel:SetSize(0, 45)
    self.PlyLabel:SetFont("HMCD_MedalTitle")
    self.PlyLabel:SetColor(color_white)

    self.MedalPanel = vgui.Create("DPanel", self.MainPanel)
    self.MedalPanel:Dock(FILL)
    self.MedalPanel:DockMargin(10, 5, 10, 5)
    self.MedalPanel.Band = nil
    self.MedalPanel.Medal = nil

    function self.MedalPanel:Paint(w, h)

        if not self.Band or not self.Medal then return end
        if self.Band.icon then
            surface.SetMaterial(self.Band.icon)
            RenderMedalBox(w, h)
        end
        if self.Medal.icon then
            surface.SetMaterial(self.Medal.icon)
            RenderMedalBox(w, h)
        end
    end

    self.ExpLabel = vgui.Create("DLabel", self.MainPanel)
    self.ExpLabel:Dock(BOTTOM)
    self.ExpLabel:SetContentAlignment(5)
    self.ExpLabel:SetSize(0, 45)
    self.ExpLabel:SetFont("HMCD_MedalText")
    self.ExpLabel:SetColor(color_white)

    function self:Paint(w, h)
    end
end

function PANEL:SetPlayer(ply)
    if not IsValid(ply) then return end

    self.Player = ply
    local Band, Medal = ply:GetAwards()

    self.MedalPanel.Band = Band
    self.MedalPanel.Medal = Medal
    self.PlyLabel:SetText(ply:Nick() .. "'s Medal")
    self.ExpLabel:SetText((ply.exp or 0) .. " XP  |  " .. math.Round(ply.skill or 0, 3) .. " Skill")

    local oldexp = -1
    local medalPanel = self.MedalPanel

    function self.ExpLabel:Think()
        if not IsValid(ply) then return end
        if ply.exp ~= oldexp then
            local Band, Medal = ply:GetAwards()
            medalPanel.Band = Band
            medalPanel.Medal = Medal
            oldexp = ply.exp
        end
        self:SetText((ply.exp or 0) .. " XP  |  " .. math.Round(ply.skill or 0, 3) .. " Skill")
    end
end

vgui.Register("HMCD_ExpPanel", PANEL, "DPanel")

local function PaintMedalFrame(self, w, h)
    surface.SetDrawColor(Color(40, 40, 40, 255))
    surface.DrawRect(0, 0, w, h)
end

function EXP.Menu(ply)
    if not IsValid(ply) then return end

    if IsValid(EXP.OpenedMenu) then
        EXP.OpenedMenu:Remove()
        EXP.OpenedMenu = nil
    end

    EXP.OpenedMenu = vgui.Create("DFrame")
    EXP.OpenedMenu:SetSize(ScrW() * 0.22, ScrH() * 0.45)
    EXP.OpenedMenu:Center()
    EXP.OpenedMenu:MakePopup()
    EXP.OpenedMenu:SetTitle("")
    EXP.OpenedMenu:ShowCloseButton(true)
    EXP.OpenedMenu:DockPadding(6, 34, 6, 6)

    function EXP.OpenedMenu:Paint(w, h)
        PaintMedalFrame(self, w, h)
        draw.SimpleText("Medal", "HMCD_MedalSubText", 10, 6, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    EXP.OpenedMenu.Medal = vgui.Create("HMCD_ExpPanel", EXP.OpenedMenu)
    local ExpPanel = EXP.OpenedMenu.Medal
    ExpPanel:Dock(FILL)
    ExpPanel:SetPlayer(ply)
end

function EXP.OpenMenu(ply)
    if not IsValid(ply) then return end
    net.Start("hmcd_xp_get")
        net.WriteEntity(ply)
    net.SendToServer()
end

local needCallback = false

net.Receive("hmcd_xp_get", function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end

    ply.skill = net.ReadFloat()
    ply.exp = net.ReadInt(19)

    if needCallback then
        if IsValid(EXP.OpenedAccount) then
            EXP.OpenedAccount:Remove()
            EXP.OpenedAccount = nil
        end

        local accountClass = vgui.GetControlTable("HMCD_AccountFrame") and "HMCD_AccountFrame"
        EXP.OpenedAccount = vgui.Create(accountClass)
        local AcMenu = EXP.OpenedAccount
        AcMenu:MakePopup()
        if AcMenu.SetPlayer then
            AcMenu:SetPlayer(ply)
        end
        if AcMenu.SetTitle then
            AcMenu:SetTitle("")
        end
        needCallback = false
    end
end)

function EXP.AccountMenu(ply)
    needCallback = true
    EXP.OpenMenu(ply)
end

local function drawTextShadow(t, f, x, y, c, px, py)
    draw.SimpleText(t, f, x + 1, y + 1, Color(0, 0, 0, c.a), px, py)
    draw.SimpleText(t, f, x - 1, y - 1, Color(255, 255, 255, math.Clamp(c.a * 0.25, 0, 255)), px, py)
    draw.SimpleText(t, f, x, y, c, px, py)
end

local healthCol = Color(120, 255, 20)

function GM:HUDPaint()
    local client = LocalPlayer()
    self:DrawGameHUD(client)
    self:DrawPhraseMenu()
    self:DrawRadialMenu()
    self:Drawmenu_useMenu()
    self:DrawSpectate()
    self:DrawDMTime()
    self:DrawHeadCrabHud()
end

local fullbright = 255

function GM:DrawHeadCrabHud()
    if LocalPlayer():GetNWBool("Headcrab", false) == true then
        if LocalPlayer():GetNWInt("Headcrab_Stade", 1) >= 1 then
            if math.random(1, 25) == 3 then
                fullbright = math.Rand(0, 200)
            else
                fullbright = 255
            end
            surface.SetDrawColor(0, 0, 0, fullbright)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
        if LocalPlayer():GetNWInt("Headcrab_Stade", 1) >= 2 then
            if type(DrawRandomPizdec) == "function" then DrawRandomPizdec() end
        end
        if LocalPlayer():GetNWInt("Headcrab_Stade", 1) >= 3 then
            if math.random(1, 5) == 2 and type(DrawRandomText) == "function" then
                DrawRandomText()
            end
        end
        if LocalPlayer():GetNWInt("Headcrab_Stade", 1) >= 4 then
            if math.random(1, 2) == 1 and type(DrawRandomOther) == "function" then
                DrawRandomOther()
            end
        end
    end
end

function GM:DrawDMTime()
    if GetGlobalString("RoundName", "homicide") == "dm" and GetGlobalInt("DMTime", 10) >= 1 then
        drawTextShadow(GetGlobalInt("DMTime", 10), "DefaultFont", 950, 50, team.GetColor(1), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local hmcdhelp = CreateClientConVar("hmcd_help","1",true,false,"tips",0,1)
local spectateTips = {
    "There's someone behind you.",
    "The less guilt the better, Z-Citer!",
    "If you can manage to find some duct tape or a hammer and nails, you can build forts and barricades.",
    "People can survive headshots, aim for the brain.",
    "Bleeding won't stop on its own. Use a bandage before you pass out.",
    "Boxes spawn randomly around the map during rounds.",
    "A body on the floor might not be dead.",
    "Poisons take time to kill, curare is slow, VX is fast and merciless.",
    "Bear traps hurt like hell and pin you in place. Watch your step.",
    "Silenced weapons are quiet, but not silent. Listen closely.",
    "A helmet can save you from a single headshot. Better ugly than dead.",
    "Body armor protects your chest, not your face. Stand behind cover anyway.",
    "Guilt gives you away - people can see you acting weird. Stay sharp.",
    "Walkie-talkies let your team talk at distance. Coordinate, don't yell.",
    "The murderer's biggest weapon is panic. Don't run in a straight line.",
    "Darkness is your best friend and worst enemy.",
    "Molotovs don't forgive, neither do the people you throw them at.",
    "Dead men tell no tales, but their weapons do, loot the bodies.",
    "Type hmcd_appearance_menu in console to change your look before the next round.",
    "The round ends after ~6 minutes.",
    "Ricochets are real here, don't shoot at walls near teammates.",
    "Spectating is a great time to learn the map, try to learn and remember where people hide.",
    "Suppressors hide your muzzle flash and lower your sound, but you still crack off rounds - don't fire near others.",
    "A red dot or scope isn't just a cosmetic - line up your shot before the target sees you.",
    "Rifles punch harder at range, pistols are faster up close. Pick the tool for the range you're fighting at.",
    "Chamber a round before you need it - an empty gun in a firefight is a death sentence.",
    "Watch your ammo count. Reload in cover, not out in the open.",
    "Crouch and move slowly in the open. Movement is noise, and noise is how they find you.",
    "Keep walls between you and unknown footsteps. Let them walk into YOUR ambush, not the other way around.",
    "The first shot is the only one that matters.",
    "Curare is slow but quiet - the perfect way to take someone out without anyone noticing.",
    "VX kills fast and loud. Use it when you can't afford a witness.",
    "You can bleed out faster than you think. Bandage as soon as the fight is over, not when you're already blacking out.",
    "Dark corners hide knives.",
    "If you can't find them, wait them out.",
}

local currentTip = spectateTips[1] or ""
local nextTipChange = 0

function GM:DrawSpectate()
    local ply = LocalPlayer()
    local plyselect = ply:GetNWEntity("SelectPlayer", Entity(-1))

    if ply:Alive() or not ply:GetNWBool("Spectating", false) then return end
    if not hmcdhelp:GetBool() then return end

    if CurTime() >= nextTipChange then
        currentTip = table.Random(spectateTips) or ""
        nextTipChange = CurTime() + 20
    end

    local mode = ply:GetNWInt("SpectateMode", 0)
    local cx = ScrW() / 2
    local y = 50

    drawTextShadow("Spectating", "FontSmall", cx, y, Color(180, 180, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if mode == 3 then
        drawTextShadow("Free Camera", "FontBigger", cx, y + 40, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif IsValid(plyselect) and plyselect:IsPlayer() then
        local nick = plyselect:GetNWString("Character_Name", "")
        if nick == "" then nick = plyselect:Nick() end

        local hp = math.max(0, plyselect:Health())
        local role = plyselect:GetNWString("RoleShow", "Bystander")
        local roleText, roleColor = role, Color(200, 200, 200)

        if role == "Traitor" then
            roleText = "Traitor"
            roleColor = Color(164, 26, 26)
        elseif role == "Bystander" or role == "Innocent" or role == "Gunman" then
            roleText = "Innocent"
            roleColor = Color(57, 62, 213)
        end

        drawTextShadow(nick, "FontBigger", cx, y + 40, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        drawTextShadow(hp .. "/100 HP", "FontBig", cx, y + 85, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        drawTextShadow(roleText, "FontBigger", cx, y + 125, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        drawTextShadow("No target", "FontBigger", cx, y + 40, Color(180, 180, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local bx = ScrW() - 30
    drawTextShadow("R - Change mode spectate player", "FontSmall", bx, ScrH() - 240, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    drawTextShadow("LMB - Change player spectate", "FontSmall", bx, ScrH() - 210, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    drawTextShadow("RMB - Change mode spectate ( noclip / player )", "FontSmall", bx, ScrH() - 180, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    if currentTip ~= "" then
        drawTextShadow(currentTip, "FontSmall2", cx, ScrH() / 1.05, Color(25, 25, 25), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end


function RagdollOwner(rag)
    if not IsValid(rag) then return end
    local ent = rag:GetNWEntity("RagdollController")
    return IsValid(ent) and ent
end

local AmmoShells      = {}
local LastAmmoWep     = nil
local LastFireTracked = 0
local LastAmmoShow    = 0
local LastAmmoClip    = 0

local function SpawnAmmoShell(tex, w, h)
    local W, H = ScrW(), ScrH()
    AmmoShells[#AmmoShells + 1] = {
        tex  = tex,
        w    = w,
        h    = h,
        x    = W * 0.7 + 20 + w / 2 + math.Rand(-10, 10),
        y    = H * 0.830 + h / 2 + math.Rand(-8, 8),
        vx   = math.Rand(90, 260),
        vy   = -math.Rand(280, 480),
        rot  = math.Rand(0, 360),
        vrot = math.Rand(-760, 760),
        born = CurTime(),
        life = math.Rand(1, 3),
    }
end

local function ThinkAmmoShells()
    local dt = FrameTime()
    for i = #AmmoShells, 1, -1 do
        local s = AmmoShells[i]
        local t = CurTime() - s.born
        if t > s.life then
            table.remove(AmmoShells, i)
        else
            s.vy  = s.vy + 900 * dt
            s.x   = s.x + s.vx * dt
            s.y   = s.y + s.vy * dt
            s.vx  = s.vx * (1 - dt * 0.1)
            s.rot = s.rot + s.vrot * dt
        end
    end
end

local function DrawAmmoShells()
    for _, s in ipairs(AmmoShells) do
        local t = CurTime() - s.born
        local a = 255
        if t > s.life - 0.5 then
            a = 255 * math.Clamp((s.life - t) / 0.5, 0, 1)
        end
        local scale = 1
        surface.SetTexture(s.tex)
        surface.SetDrawColor(255, 255, 255, a)
        surface.DrawTexturedRectRotated(s.x, s.y, s.w * scale, s.h * scale, s.rot)
    end
end

function GM:DrawGameHUD(ply)
    if not IsValid(ply) then return end
    local health = ply:Health()
    if not (LocalPlayer() == ply) then return end

    local W, H, Vary = ScrW(), ScrH(), math.sin(CurTime() * 10) / 2 + 0.5
    local Bright = Color(255, 255, 255, 255)

    ThinkAmmoShells()
    DrawAmmoShells()

    local tr = ply:GetEyeTraceNoCursor()

    if IsValid(tr.Entity) and tr.HitPos:Distance(tr.StartPos) < 60 then
        if tr.Entity:IsPlayer() or tr.Entity:IsRagdoll() then
            self.LastLooked = (tr.Entity:IsRagdoll()) and RagdollOwner(tr.Entity) or tr.Entity
            self.LastLookedType = (tr.Entity:IsRagdoll()) and "Ragdoll" or "Other"
            self.LookedFade = CurTime()
        end
    end

    if IsValid(self.LastLooked) and self.LookedFade + 1 > CurTime() and self.LastLooked ~= LocalPlayer() and LocalPlayer():Alive() then
        local type_look = self.LastLookedType
        local name = (type_look == "Ragdoll") and tr.Entity:GetNWString("Character_Name") or self.LastLooked:GetNWString("Character_Name")
        local col = (type_look == "Ragdoll") and tr.Entity:GetNWVector("plycolor") or self.LastLooked:GetPlayerColor() or Vector()
        col = Color(col.x * 255, col.y * 255, col.z * 255)
        col.a = (1 - (CurTime() - self.LookedFade) / 1) * 255
        drawTextShadow(name, "FontTargetP", ScrW() / 2, ScrH() / 2 + 80, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if type_look == "Ragdoll" then
            drawTextShadow("[RMB]+[E] Loot", "FontSmall", ScrW() / 2, ScrH() / 2 + 110, Color(255, 255, 255, col.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local RoundTextures = {
        ["Pistol"]     = surface.GetTextureID("vgui/hud/hmcd_round_9"),
        ["357"]        = surface.GetTextureID("vgui/hud/hmcd_round_38"),
        ["AlyxGun"]    = surface.GetTextureID("vgui/hud/hmcd_round_22"),
        ["Buckshot"]   = surface.GetTextureID("vgui/hud/hmcd_round_12"),
        ["AR2"]        = surface.GetTextureID("vgui/hud/hmcd_round_76239"),
        ["SMG1"]       = surface.GetTextureID("vgui/hud/hmcd_round_4630"),
        ["XBowBolt"]   = surface.GetTextureID("vgui/hud/hmcd_round_arrow"),
        ["AirboatGun"] = surface.GetTextureID("vgui/hud/hmcd_nail"),
        ["RPG_Round"]  = surface.GetTextureID("vgui/hud/hmcd_round_rpg")
    }

    if ply.AmmoShow and (ply.AmmoShow > CurTime()) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().AmmoType ~= nil then
        local Wep, TimeLeft, Opacity = ply:GetActiveWeapon(), ply.AmmoShow - CurTime(), 255
        if Opacity <= 0 then return end
        Opacity = TimeLeft * 255
        if Wep.CanAmmoShow then
            local clip = Wep:Clip1()
            if IsValid(Wep) and Wep.CanAmmoShow and Wep.AmmoType and RoundTextures[Wep.AmmoType] then
                if Wep ~= LastAmmoWep then
                    LastAmmoWep, LastFireTracked = Wep, Wep.LastFire or CurTime()
                elseif Wep.LastFire and Wep.LastFire ~= LastFireTracked and (LastAmmoClip or 0) >= 1 then
                    LastFireTracked = Wep.LastFire
                    SpawnAmmoShell(RoundTextures[Wep.AmmoType], (Wep.AmmoType == "RPG_Round" and 175) or 128, 100)
                end
            end
            LastAmmoShow, LastAmmoClip = ply.AmmoShow, clip
            surface.SetTexture(RoundTextures[Wep.AmmoType])
            surface.SetDrawColor(Color(255, 255, 255, Opacity))
            surface.DrawTexturedRect(W * .7 + 20, H * .830, (Wep.AmmoType == "RPG_Round" and 175) or 128, 100)
            local Mag, Message, Cnt = Wep:Clip1(), "", ply:GetAmmoCount(Wep.AmmoType)
            if Mag >= 0 then
                Message = tostring(Mag)
                if Cnt > 0 then Message = Message .. " + " .. tostring(Cnt) end
            else
                Message = tostring(Cnt)
            end
            drawTextShadow(Message, "FontSmall", W * .7 + 30, H * .8 + 45, Color(255, 255, 255, Opacity), 0, TEXT_ALIGN_TOP)
        end
    end
end

local function ShowAmmo(data)
    LocalPlayer().AmmoShow = CurTime() + 2
end
usermessage.Hook("HMCD_AmmoShow", ShowAmmo)

function GM:GUIMousePressed(code, vector)
    LocalPlayer():ConCommand("-phrase")
    LocalPlayer():ConCommand("-menu_use")
end

function GM:OpenAmmoDropMenu()
    local Ply, AmmoType, AmmoAmt, Ammos = LocalPlayer(), "Pistol", 1, {}
    if HMCD_AmmoNames then
        for key, name in pairs(HMCD_AmmoNames) do
            local Amownt = Ply:GetAmmoCount(key)
            if (Amownt > 0) then Ammos[key] = Amownt end
        end
    end
    
    if (#table.GetKeys(Ammos) <= 0) then
        Ply:ChatPrint("You have no ammo!")
        return
    end
    
    AmmoType = table.GetKeys(Ammos)[1]
    AmmoAmt = Ammos[AmmoType]
    local DermaPanel = vgui.Create("DFrame")
    DermaPanel:SetPos(40, 80)
    DermaPanel:SetSize(300, 300)
    DermaPanel:SetTitle("Drop Ammo")
    DermaPanel:SetVisible(true)
    DermaPanel:SetDraggable(true)
    DermaPanel:ShowCloseButton(true)
    DermaPanel:MakePopup()
    DermaPanel:Center()

    local MainPanel = vgui.Create("DPanel", DermaPanel)
    MainPanel:SetPos(5, 25)
    MainPanel:SetSize(290, 270)
    MainPanel.Paint = function()
        surface.SetDrawColor(0, 20, 40, 255)
        surface.DrawRect(0, 0, MainPanel:GetWide(), MainPanel:GetTall() + 3)
    end
    
    local SecondPanel = vgui.Create("DPanel", MainPanel)
    SecondPanel:SetPos(100, 177)
    SecondPanel:SetSize(180, 20)
    SecondPanel.Paint = function()
        surface.SetDrawColor(100, 100, 100, 255)
        surface.DrawRect(0, 0, SecondPanel:GetWide(), SecondPanel:GetTall() + 3)
    end
    
    local amtselect = vgui.Create("DNumSlider", MainPanel)
    amtselect:SetPos(10, 170)
    amtselect:SetWide(290)
    amtselect:SetText("Amount")
    amtselect:SetMin(1)
    amtselect:SetMax(AmmoAmt)
    amtselect:SetDecimals(0)
    amtselect:SetValue(AmmoAmt)
    amtselect.OnValueChanged = function(panel, val)
        AmmoAmt = math.Round(val)
    end
    
    local AmmoList = vgui.Create("DListView", MainPanel)
    AmmoList:SetMultiSelect(false)
    AmmoList:AddColumn("Type")
    for key, amm in pairs(Ammos) do
        local label = (HMCD_AmmoNames and HMCD_AmmoNames[key]) or key
        AmmoList:AddLine(label).Type = key
    end
    AmmoList:SetPos(5, 5)
    AmmoList:SetSize(280, 150)
    AmmoList.OnRowSelected = function(panel, ind, row)
        AmmoType = row.Type
        AmmoAmt = Ammos[AmmoType] or 1
        amtselect:SetMax(AmmoAmt)
        amtselect:SetValue(AmmoAmt)
    end
    AmmoList:SelectFirstItem()
    
    local gobutton = vgui.Create("Button", MainPanel)
    gobutton:SetSize(270, 40)
    gobutton:SetPos(10, 220)
    gobutton:SetText("Drop")
    gobutton:SetVisible(true)
    gobutton.DoClick = function()
        DermaPanel:Close()
        RunConsoleCommand("hmcd_droprequest_ammo", AmmoType, tostring(AmmoAmt))
    end
end

concommand.Add("open_ammo_drop_menu", function()
    GAMEMODE:OpenAmmoDropMenu()
end)

function GM:OpenEquipmentDropMenu()
    local ply, eqType = LocalPlayer(), ""
    if not ply.Equipment or (table.Count(ply.Equipment) <= 0) then
        ply:ChatPrint("You have no equipment!")
        return
    end
    local size = ScrW() / 8.5
    local DermaPanel = vgui.Create("DFrame")
    DermaPanel:SetSize(size, size)
    DermaPanel:SetTitle("Drop Equipment")
    DermaPanel:SetVisible(true)
    DermaPanel:SetDraggable(true)
    DermaPanel:ShowCloseButton(true)
    DermaPanel:MakePopup()
    DermaPanel:Center()

    local MainPanel = vgui.Create("DPanel", DermaPanel)
    MainPanel:SetPos(5, 25)
    MainPanel:SetSize(size * 0.96, size * 0.9)
    MainPanel.Paint = function()
        surface.SetDrawColor(0, 20, 40, 255)
        surface.DrawRect(0, 0, MainPanel:GetWide(), MainPanel:GetTall())
    end

    local EquipmentList = vgui.Create("DListView", MainPanel)
    EquipmentList:SetMultiSelect(false)
    EquipmentList:AddColumn("Type")
    for key, amm in pairs(ply.Equipment) do
        local typeName = (HMCD_EquipmentNames and table.KeyFromValue(HMCD_EquipmentNames, key)) or key
        EquipmentList:AddLine(key).Type = typeName
    end
    EquipmentList:SetPos(5, 5)
    EquipmentList:SetSize(size * 0.93, size * 0.5)
    EquipmentList.OnRowSelected = function(panel, ind, row)
        eqType = row.Type
    end
    EquipmentList:SelectFirstItem()

    local gobutton = vgui.Create("Button", MainPanel)
    gobutton:SetSize(size * 0.9, size * 0.15)
    gobutton:SetPos(size / 30, size * 0.73)
    gobutton:SetText("Drop")
    gobutton:SetVisible(true)
    gobutton.DoClick = function()
        DermaPanel:Close()
        if HMCD_EquipmentNames and HMCD_EquipmentNames[eqType] then
            ply.Equipment[HMCD_EquipmentNames[eqType]] = nil
        end
        RunConsoleCommand("hmcd_dropequipment", eqType)
    end
end

function OpenAttachmentMenu()
    local ply, Wep, attType = LocalPlayer(), LocalPlayer():GetActiveWeapon(), 0
    local List = {}
    if IsValid(Wep) then
        local atts = {}
        if Wep.Attachments and Wep.Attachments["Owner"] then
            for attachment, info in pairs(Wep.Attachments["Owner"]) do
                if info.num then
                    if Wep:GetNWBool(attachment) then
                        table.insert(List, info.num)
                    end
                    table.insert(atts, info.num)
                end
            end
        end
        if ply.Equipment then
            for i, attachment in pairs(atts) do
                if HMCD_EquipmentNames and ply.Equipment[HMCD_EquipmentNames[attachment]] then
                    table.insert(List, attachment)
                end
            end
        end
    end
    local size = math.max(ScrW() * 0.2, 400)
    local DermaPanel = vgui.Create("DFrame")
    DermaPanel:SetPos(40, 80)
    DermaPanel:SetSize(size, size)
    DermaPanel:SetTitle("Customize your weapon")
    DermaPanel:SetVisible(true)
    DermaPanel:SetDraggable(true)
    DermaPanel:ShowCloseButton(true)
    DermaPanel:MakePopup()
    DermaPanel:Center()

    local MainPanel = vgui.Create("DPanel", DermaPanel)
    MainPanel:SetPos(5, 25)
    MainPanel:SetSize(size * 0.96, size * 0.9)
    MainPanel.Paint = function()
        surface.SetDrawColor(0, 20, 40, 255)
        surface.DrawRect(0, 0, MainPanel:GetWide(), MainPanel:GetTall() + 3)
    end

    local AttachmentList = vgui.Create("DListView", MainPanel)
    AttachmentList:SetMultiSelect(false)
    AttachmentList:AddColumn("Type")
    for i, att in pairs(List) do
        local name = (HMCD_EquipmentNames and HMCD_EquipmentNames[List[i]]) or tostring(List[i])
        AttachmentList:AddLine(name).Type = att
    end
    AttachmentList:SetPos(5, 5)
    AttachmentList:SetSize(size * 0.93, size * 0.5)

    local gobutton = vgui.Create("Button", MainPanel)
    gobutton:SetSize(size * 0.9, size * 0.15)
    gobutton:SetPos(size / 30, size * 0.73)
    gobutton:SetText("Attach")
    gobutton:SetVisible(true)
    gobutton:SetEnabled(false)
    gobutton.DoClick = function()
        DermaPanel:Close()
        RunConsoleCommand("hmcd_attachrequest", attType)
    end
    AttachmentList.OnRowSelected = function(panel, ind, row)
        attType = row.Type
        gobutton:SetEnabled(true)
    end
end

concommand.Add("attachmentsmenu", OpenAttachmentMenu)

local menu

surface.CreateFont("ScoreboardPlayer", {
    font = "coolvetica",
    size = 32,
    weight = 500,
    antialias = true,
    italic = false
})

local muted = Material("icon32/muted.png")
local admin = Material("icon32/wand.png")

local function addPlayerItem(self, mlist, ply, pteam)
    local but = vgui.Create("DButton")
    but.player = ply
    but.ctime = CurTime()
    but:SetTall(40)
    but:SetText("")
    local show_charactername

    function but:Paint(w, h)
        local showAdmins = false
        if IsValid(ply) and showAdmins and ply:IsAdmin() then
            surface.SetDrawColor(Color(150, 50, 50))
        else
            surface.SetDrawColor(team.GetColor(pteam))
        end
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h * 0.45)
        surface.SetDrawColor(color_black)
        surface.DrawOutlinedRect(0, 0, w, h)

        if IsValid(ply) and ply:IsPlayer() then
            local s = 0
            if showAdmins and ply:IsAdmin() then
                surface.SetMaterial(admin)
                surface.SetDrawColor(color_white)
                surface.DrawTexturedRect(s + 4, h / 2 - 16, 32, 32)
                s = s + 32
            end
            if ply:IsMuted() then
                surface.SetMaterial(muted)
                surface.SetDrawColor(color_white)
                surface.DrawTexturedRect(s + 4, h / 2 - 16, 32, 32)
                s = s + 32
            end
            if GetGlobalInt("RoundState", 0) == 0 then
                show_charactername = ply:GetNWString("Character_Name", "")
            else
                show_charactername = ""
            end
            draw.DrawText(ply:Ping(), "ScoreboardPlayer", w - 9, 9, color_black, 2)
            draw.DrawText(ply:Ping(), "ScoreboardPlayer", w - 10, 8, color_white, 2)
            draw.DrawText(ply:Nick() .. " " .. show_charactername, "ScoreboardPlayer", s + 11, 9, color_black, 0)
            draw.DrawText(ply:Nick() .. " " .. show_charactername, "ScoreboardPlayer", s + 10, 8, color_white, 0)
        end
    end

    function but:DoClick()
        GAMEMODE:DoScoreboardActionPopup(ply)
    end

    function but:DoRightClick()
        GAMEMODE:DoScoreboardActionPopup(ply)
    end

    mlist:AddItem(but)
end

function GM:DoScoreboardActionPopup(ply)
    if not ((ply) and (IsValid(ply)) and (ply:IsPlayer())) then return end

    local actions = DermaMenu()

    local medal = actions:AddOption("Medal", function()
        if IsValid(ply) and hmcd and hmcd.Experience and hmcd.Experience.Menu then
            hmcd.Experience.Menu(ply)
        end
    end)
    medal:SetIcon("icon16/award_star_gold_3.png")

    if ply ~= LocalPlayer() then
        local t = "Mute"
        if ply:IsMuted() then
            t = "Unmute"
        end
        local mute = actions:AddOption(t)
        mute:SetIcon("icon16/sound_mute.png")
        function mute:DoClick()
            if IsValid(ply) then
                ply:SetMuted(not ply:IsMuted())
            end
        end
    end

    actions:Open()
end

local function doPlayerItems(self, mlist, pteam)
    for k, ply in pairs(team.GetPlayers(pteam)) do
        local found = false
        for t, v in pairs(mlist:GetCanvas():GetChildren()) do
            if v.player == ply then
                found = true
                v.ctime = CurTime()
            end
        end
        if not found then
            addPlayerItem(self, mlist, ply, pteam)
        end
    end
    local del = false
    for t, v in pairs(mlist:GetCanvas():GetChildren()) do
        if v.ctime ~= CurTime() then
            v:Remove()
            del = true
        end
    end
    if del then
        timer.Simple(0, function()
            if IsValid(mlist) and IsValid(mlist:GetCanvas()) then
                mlist:GetCanvas():InvalidateLayout()
            end
        end)
    end
end

local function makeTeamList(parent, pteam)
    local mlist
    local pnl = vgui.Create("DPanel", parent)
    pnl:DockPadding(8, 8, 8, 8)
    function pnl:Paint(w, h)
        surface.SetDrawColor(Color(50, 50, 50, 255))
        surface.DrawRect(2, 2, w - 4, h - 4)
    end
    function pnl:Think()
        if not self.RefreshWait or self.RefreshWait < CurTime() then
            self.RefreshWait = CurTime() + 0.1
            doPlayerItems(self, mlist, pteam)
        end
    end

    local headp = vgui.Create("DPanel", pnl)
    headp:DockMargin(0, 0, 0, 4)
    headp:Dock(TOP)
    function headp:Paint() end

    local but = vgui.Create("DButton", headp)
    but:Dock(RIGHT)
    but:SetText("Join")
    but:SetTextColor(color_white)
    but:SetFont("Trebuchet18")
    function but:Paint(w, h)
        surface.SetDrawColor(team.GetColor(pteam))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h * 0.45)
        surface.SetDrawColor(color_black)
        surface.DrawOutlinedRect(0, 0, w, h)
        if self:IsDown() then
            surface.SetDrawColor(50, 50, 50, 120)
            surface.DrawRect(1, 1, w - 2, h - 2)
        elseif self:IsHovered() then
            surface.SetDrawColor(255, 255, 255, 30)
            surface.DrawRect(1, 1, w - 2, h - 2)
        end
    end

    local head = vgui.Create("DLabel", headp)
    head:SetText(team.GetName(pteam))
    head:SetFont("Trebuchet24")
    head:SetTextColor(team.GetColor(pteam))
    head:Dock(FILL)

    mlist = vgui.Create("DScrollPanel", pnl)
    mlist:Dock(FILL)

    local canvas = mlist:GetCanvas()
    function canvas:OnChildAdded(child)
        child:Dock(TOP)
        child:DockMargin(0, 0, 0, 4)
    end

    return pnl
end

function GM:ScoreboardShow()
    if IsValid(menu) then
        menu:SetVisible(true)
    else
        menu = vgui.Create("DFrame")
        menu:SetSize(ScrW() * 0.8, ScrH() * 0.8)
        menu:Center()
        menu:MakePopup()
        menu:SetKeyboardInputEnabled(false)
        menu:SetDraggable(false)
        menu:ShowCloseButton(false)
        menu:SetTitle("")
        menu:DockPadding(4, 4, 4, 4)
        function menu:Paint()
            surface.SetDrawColor(Color(40, 40, 40, 255))
            surface.DrawRect(0, 0, menu:GetWide(), menu:GetTall())
        end

        menu.Credits = vgui.Create("DPanel", menu)
        menu.Credits:Dock(TOP)
        menu.Credits:DockPadding(8, 6, 8, 0)
        function menu.Credits:Paint() end

        local name = Label((GAMEMODE and GAMEMODE.Name) or "derp errors", menu.Credits)
        name:Dock(LEFT)
        name:SetFont("DefaultFont")
        name:SetTextColor(team.GetColor(2))
        function name:PerformLayout()
            surface.SetFont(self:GetFont())
            local w, h = surface.GetTextSize(self:GetText())
            self:SetSize(w, h)
        end

        local lab = Label(((GAMEMODE and GAMEMODE.Author) or "") .. tostring((GAMEMODE and GAMEMODE.Version) or "error"), menu.Credits)
        lab:Dock(RIGHT)
        lab:SetFont("FontSmall")
        lab.PerformLayout = name.PerformLayout
        lab:SetTextColor(team.GetColor(1))

        function menu.Credits:PerformLayout()
            surface.SetFont(name:GetFont())
            local w, h = surface.GetTextSize(name:GetText())
            self:SetTall(h)
        end

        menu.Players = makeTeamList(menu, 1)
        menu.Players:Dock(LEFT)

        menu.Spectators = makeTeamList(menu, 2)
        menu.Spectators:Dock(FILL)

        function menu:PerformLayout()
            menu.Players:SetWidth(self:GetWide() * 0.5)
        end
    end
end

function GM:ScoreboardHide()
    if IsValid(menu) then
        menu:Close()
    end
end

function GM:HUDDrawScoreBoard()
end

function GM:AdjustMouseSensitivity(def)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.Scoped and wep.AimPerc and wep.AimPerc > 99 then
        return wep.ScopedSensitivity or 0.15
    end
    if IsValid(ply) and ply:IsSprinting() and ply:KeyDown(IN_FORWARD) then
        return 0.5
    else
        return 1
    end
end

local ScpMat = surface.GetTextureID("sprites/mat_jack_hmcd_scope_diffuse")

surface.CreateFont("CrossbowText", {
    font = "Coolvetica",
    size = 24,
    weight = 500,
    antialias = true
})

surface.CreateFont("BinocularNums", {
    font = "Coolvetica",
    size = 20,
    weight = 500,
    antialias = true
})

local ScopeTarget, ScopeCur

local function ScopeZoomSet(target)
    if target then
        ScopeTarget = target
        if not ScopeCur then
            ScopeCur = LocalPlayer():GetFOV()
        end
    else
        ScopeTarget = nil
    end
end

local function ScopeZoomKill()
    ScopeTarget = nil
    ScopeCur = nil
end

local currentFOV = nil

hook.Add("CalcView", "TF22ew", function(ply, pos, angles, fov)
    local defaultFOV = ply:GetFOV() or 90
    local targetFOV = ScopeTarget or defaultFOV

    if not ScopeTarget and not currentFOV then return end
    if not currentFOV then currentFOV = fov end

    local fovSpeed = FrameTime() * 450
    currentFOV = math.Approach(currentFOV, targetFOV, fovSpeed)

    if not ScopeTarget and currentFOV == defaultFOV then
        currentFOV = nil
        return
    end

    return {
        origin = pos,
        angles = angles,
        fov = currentFOV
    }
end)

local function ScopeOverlay(wep, ply)
    if wep.AimPerc and wep.AimPerc > 99 and wep.Scoped and not IsValid(ply:GetNWEntity("Fake")) then
        if wep.DetachableScope and not (wep.DrawnAttachments and wep.DrawnAttachments["Scope"]) then return end

        local W, H = ScrW(), ScrH()
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetTexture(ScpMat)

        if wep:GetClass() == "wep_jack_hmcd_crossbow" then
            local Mul = H / 1080
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(W / 2 - 60, H / 2 + 50 * Mul, 65, 2)
            surface.SetTextPos(W / 2 - 60, H / 2 + 37 * Mul + 5 * (Mul - 2))
            surface.SetTextColor(0, 0, 0, 255)
            surface.SetFont("CrossbowText")
            surface.DrawText("20", false)
            surface.DrawRect(W / 2 - 80, H / 2 + 130 * Mul, 85, 2)
            surface.SetTextPos(W / 2 - 80, H / 2 + 117 * Mul + 5 * (Mul - 2))
            surface.DrawText("30", false)
            surface.DrawRect(W / 2 - 100, H / 2 + 210 * Mul, 105, 2)
            surface.SetTextPos(W / 2 - 100, H / 2 + 197 * Mul + 5 * (Mul - 2))
            surface.DrawText("40", false)
            surface.SetDrawColor(255, 255, 255, 255)
        end

        surface.DrawTexturedRect(-1, -1, W + 1, H + 1)
        surface.SetDrawColor(0, 0, 0, 255)

        if not wep.Binocular then
            surface.DrawRect(0, H / 2, W, 2)
            surface.DrawRect(W / 2 + 5, -1, 2, H + 1)
        else
            local widthmul = W / 2560 * 1.2
            surface.DrawRect(W / 2 - 5, H / 2, 10, 1)
            surface.DrawRect(W / 2, H / 2 - 5, 1, 10)
            for i = 1, 2 do
                surface.DrawRect(W / 2, H / 2 - 20 - 16 * (i - 1), 1, 10)
                surface.DrawRect(W / 2 - 6, H / 2 - 23 - 16 * (i - 1), 14, 1)
            end
            for i = 1, 9 do
                local mul = 1
                if i % 2 == 1 then mul = 0.5 end
                surface.DrawRect(W / 2 - 5 - i * 64 * widthmul, H / 2 - 5 * mul, 1, 20 * mul)
                surface.DrawRect(W / 2 + 5 + i * 64 * widthmul, H / 2 - 5 * mul, 1, 20 * mul)
                if i % 4 == 0 then
                    surface.SetTextColor(0, 0, 0, 255)
                    surface.SetFont("BinocularNums")
                    surface.SetTextPos(W / 2 - 10 - i * 64 * widthmul, H / 2 - 15)
                    surface.DrawText(tostring(i * 5), false)
                    surface.SetTextPos(W / 2 - 2 + i * 64 * widthmul, H / 2 - 15)
                    surface.DrawText(tostring(i * 5), false)
                end
            end
        end

        if wep.ScopeFoV then
            ScopeZoomSet(wep.ScopeFoV)
        end
    else
        ScopeZoomSet(nil)
    end
end

hook.Add("RenderScreenspaceEffects", "HMCD_ScopeOverlay", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then
        ScopeZoomKill()
        return
    end

    ScopeOverlay(wep, ply)
end)

hook.Add("PlayerDeath", "HMCD_ScopeZoomReset", function(ply)
    if ply == LocalPlayer() then
        ScopeZoomKill()
    end
end)
