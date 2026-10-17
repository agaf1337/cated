surface.CreateFont("HMCD_AchTitle", {
    font = "coolvetica", size = 28, weight = 500,
    antialias = true, italic = false
})

surface.CreateFont("HMCD_AchName", {
    font = "coolvetica", size = 22, weight = 500,
    antialias = true, italic = false
})

surface.CreateFont("HMCD_AchSub", {
    font = "coolvetica", size = 18, weight = 500,
    antialias = true, italic = false
})

surface.CreateFont("HMCD_AchSmall", {
    font = "coolvetica", size = 14, weight = 400,
    antialias = true, italic = false
})

surface.CreateFont( "achv_title", {
    font = "Arial",
    extended = false,
    size = 16,
    weight = 100,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

surface.CreateFont( "achv_title2", {
    font = "Arial",
    extended = false,
    size = 15,
    weight = 100,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

local HMCD_Ach_Queue = {}
local bgMaterial = Material("entities/achivmientsteam.png")
local defaultIcon = Material("vgui/hud/hmcd_achievement_default")

local AchState = {}
local AchStateReady = false

net.Receive("hmcd_ach_sync", function()
    local key = net.ReadString()
    local progress = net.ReadFloat()

    local ply = LocalPlayer()
    if IsValid(ply) then
        ply.HMCD_Achievements = ply.HMCD_Achievements or {}
        ply.HMCD_Achievements[key] = progress
    end

    AchState[key] = {
        progress = progress,
        unlocked = progress >= 100
    }
end)

net.Receive("hmcd_ach_unlocked", function()
    local key = net.ReadString()
    local ach = hmcd.Achievements.List[key] or {
        key = key, name = key,
        description = "Achievement Unlocked!",
        icon = "vgui/hud/hmcd_achievement_default"
    }

    table.insert(HMCD_Ach_Queue, {
        ach = ach,
        startTime = RealTime(),
        duration = 5.0
    })

    surface.PlaySound("steam-achievement.mp3")
end)

local function WrapText(text, font, maxWidth)
    surface.SetFont(font)
    local words = string.Explode(" ", text or "")
    local lines = {}
    local currentLine = ""

    for _, word in ipairs(words) do
        local testLine = (currentLine == "") and word or (currentLine .. " " .. word)
        local w, _ = surface.GetTextSize(testLine)
        if w > maxWidth and currentLine ~= "" then
            table.insert(lines, currentLine)
            currentLine = word
        else
            currentLine = testLine
        end
    end

    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end

    return lines
end

local function GetAchievementMaterial(ach)
    if ach and ach.icon then
        local mat = Material(ach.icon)
        if mat and not mat:IsError() then
            return mat
        end
    end
    return defaultIcon
end

local function drawTextShadow(t, f, x, y, c, px, py)
    draw.SimpleText(t, f, x + 1, y + 1, Color(0, 0, 0, c.a), px, py)
    draw.SimpleText(t, f, x - 1, y - 1, Color(255, 255, 255, math.Clamp(c.a * 0.25, 0, 255)), px, py)
    draw.SimpleText(t, f, x, y, c, px, py)
end

hook.Add("PostDrawHUD", "HMCD_DrawAchievementPopups", function()
    if #HMCD_Ach_Queue == 0 then return end

    local currentTime = RealTime()
    local popupW, popupH = 255, 103
    local marginX, marginY = 20, 20

    for i = #HMCD_Ach_Queue, 1, -1 do
        local item = HMCD_Ach_Queue[i]
        local elapsed = currentTime - item.startTime

        if elapsed > item.duration then
            table.remove(HMCD_Ach_Queue, i)
            continue
        end

        local slideProgress = 1.0
        if elapsed < 0.5 then
            slideProgress = math.EaseInOut(elapsed / 0.5, 0.0, 0.8)
        elseif elapsed > (item.duration - 0.5) then
            slideProgress = math.EaseInOut((item.duration - elapsed) / 0.5, 0.0, 0.8)
        end

        local x = ScrW() - popupW - marginX
        local restY = ScrH() - popupH - marginY - ((#HMCD_Ach_Queue - i) * (popupH + 10))
        local startY = restY + popupH + 30

        local y = Lerp(slideProgress, startY, restY)
        local alpha = 255

        surface.SetDrawColor(255, 255, 255, alpha)
        if bgMaterial then
            surface.SetMaterial(bgMaterial)
            surface.DrawTexturedRect(x, y, popupW, popupH)
        end

        local iconSize = 73
        local iconX = x + 12
        local iconY = y + (popupH - iconSize) / 2

        local achIcon = GetAchievementMaterial(item.ach)

        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(achIcon)
        surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)

        local textX = iconX + iconSize + 12
        local maxTextW = popupW - (textX - 6 - x) - 8

        draw.SimpleText("Achievement Unlocked!", "achv_title", textX - 6, y + 10, Color(245, 245, 245, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local curY = y + 30
        local nameLines = WrapText(item.ach.name or "Achievement", "achv_title2", maxTextW)
        for idx, line in ipairs(nameLines) do
            if idx > 2 then break end
            draw.SimpleText(line, "achv_title2", textX - 6, curY, Color(205, 205, 205, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            curY = curY + 19
        end

        local descLines = WrapText(item.ach.description or "", "achv_title2", maxTextW)
        for idx, line in ipairs(descLines) do
            if curY + 15 > y + popupH - 4 then break end
            draw.SimpleText(line, "achv_title2", textX - 6, curY, Color(180, 180, 180, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            curY = curY + 15
        end
    end
end)

local function CreateAchievementsMenu()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    AchState = {}
    for key, _ in pairs(hmcd.Achievements.List) do
        ply:GetAchive(key)
    end

    timer.Simple(0.15, function()
        if not IsValid(ply) then return end
        BuildAchievementsMenu(ply)
    end)
end

function BuildAchievementsMenu(ply)
    if not IsValid(ply) then return end

    local frameW, frameH = 640, 480
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(true)
    frame:SetDraggable(true)
    frame:MakePopup()

    function frame:Paint(w, h)
        surface.SetDrawColor(Color(40, 40, 40, 255))
        surface.DrawRect(0, 0, w, h)
        drawTextShadow("Achievements", "HMCD_AchTitle", w / 2, 8,
            Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(4, 44, 4, 44)

    function scroll:Paint(w, h)
        surface.SetDrawColor(Color(50, 50, 50, 255))
        surface.DrawRect(2, 2, w - 4, h - 4)
    end

    local canvas = scroll:GetCanvas()
    function canvas:OnChildAdded(child)
        child:Dock(TOP)
        child:DockMargin(0, 0, 0, 4)
    end

    local sorted = {}
    for key, ach in pairs(hmcd.Achievements.List) do
        local st = AchState[key]
        local progress = (st and st.progress) or (ply.HMCD_Achievements and ply.HMCD_Achievements[key]) or 0
        table.insert(sorted, { ach = ach, progress = progress, unlocked = progress >= 100 })
    end
    table.sort(sorted, function(a, b)
        if a.unlocked ~= b.unlocked then return a.unlocked end
        return a.progress > b.progress
    end)

    for _, item in ipairs(sorted) do
        local ach = item.ach
        local progress = item.progress
        local unlocked = item.unlocked

        local card = vgui.Create("DPanel", scroll)
        card:SetTall(68)
        card.achProgress = progress
        card.achUnlocked = unlocked

        function card:Paint(w, h)
            if self.achUnlocked then
                surface.SetDrawColor(Color(30, 80, 40, 255))
            else
                surface.SetDrawColor(Color(60, 60, 60, 255))
            end
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(color_black)
            surface.DrawOutlinedRect(0, 0, w, h)

            surface.SetDrawColor(255, 255, 255, 10)
            surface.DrawRect(0, 0, w, h * 0.45)

            local iconS = 52
            local ix, iy = 8, (h - iconS) / 2
            local mat = GetAchievementMaterial(ach)
            if not self.achUnlocked then
                surface.SetDrawColor(80, 80, 80, 200)
            else
                surface.SetDrawColor(255, 255, 255, 255)
            end
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(ix, iy, iconS, iconS)
            surface.SetDrawColor(color_black)
            surface.DrawOutlinedRect(ix, iy, iconS, iconS)

            local tx = ix + iconS + 10
            local nameText = self.achUnlocked and ach.name or "???"
            local nameCol  = self.achUnlocked and Color(220, 220, 220) or Color(130, 130, 140)
            drawTextShadow(nameText, "HMCD_AchName", tx, 4, nameCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            local barX, barY = tx, 34
            local barW, barH = w - barX - 16, 10
            surface.SetDrawColor(Color(40, 40, 48, 230))
            surface.DrawRect(barX, barY, barW, barH)
            surface.SetDrawColor(color_black)
            surface.DrawOutlinedRect(barX, barY, barW, barH)

            local fillW = self.achUnlocked and barW or (barW * self.achProgress / 100)
            local fillCol = self.achUnlocked and Color(70, 180, 100) or Color(100, 100, 200)
            surface.SetDrawColor(fillCol)
            surface.DrawRect(barX + 1, barY + 1, fillW - 2, barH - 2)

            local progText = self.achUnlocked and "UNLOCKED" or (math.floor(self.achProgress) .. "%")
            local progCol  = self.achUnlocked and Color(130, 220, 150) or Color(160, 160, 170)
            drawTextShadow(progText, "HMCD_AchSmall", w - 12, barY - 2, progCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

            if self.achUnlocked then
                drawTextShadow(ach.description or "", "HMCD_AchSmall", tx, 48, Color(180, 180, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            else
                drawTextShadow("Hidden achievement", "HMCD_AchSmall", tx, 48, Color(90, 90, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end

        card.DoClick = function(self)
            if ach.icon then
                SetClipboardText(ach.icon)
            end
        end
    end

    local bottom = vgui.Create("DPanel", frame)
    bottom:Dock(BOTTOM)
    bottom:SetTall(36)
    bottom:DockMargin(4, 0, 4, 4)

    local total = #sorted
    local unlocked = 0
    for _, item in ipairs(sorted) do
        if item.unlocked then unlocked = unlocked + 1 end
    end

    function bottom:Paint(w, h)
        surface.SetDrawColor(Color(50, 50, 50, 255))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(color_black)
        surface.DrawOutlinedRect(0, 0, w, h)

        local barW = w - 16
        local barH = 6
        local barX, barY = 8, h - 12
        surface.SetDrawColor(Color(40, 40, 48, 230))
        surface.DrawRect(barX, barY, barW, barH)
        if total > 0 then
            surface.SetDrawColor(Color(70, 180, 100))
            surface.DrawRect(barX, barY, barW * unlocked / total, barH)
        end

        local pct = total > 0 and math.floor(unlocked / total * 100) or 0
        drawTextShadow(unlocked .. " / " .. total .. "  (" .. pct .. "%)",
            "HMCD_AchSmall", w / 2, 4, Color(180, 180, 190),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    frame.OnKeyCodePressed = function(self, code)
        if code == KEY_ESCAPE then self:Close() end
    end
end

concommand.Add("hmcd_achievements", function(ply, cmd, args)
    if not IsValid(LocalPlayer()) then return end
    CreateAchievementsMenu()
end)
