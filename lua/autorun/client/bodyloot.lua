
local wepModels3D = {

    ["wep_jack_hmcd_baseballbat"] = {
        pos    = Vector(-2, 4, 5),
        ang    = Angle(0, 20, 100),
        camPos = Vector(35, 35, 18),
        fov    = 30,
    },
    ["wep_jack_hmcd_axe"] = {
        pos    = Vector(5.4, 5, 3),
        ang    = Angle(90, 40, 0),
        camPos = Vector(35, 35, 18),
        fov    = 40,
    },

    ["wep_jack_hmcd_hatchet"] = {
        pos    = Vector(0, 0, 0),
        ang    = Angle(0, 0, 0),
        camPos = Vector(35, 35, 18),
        fov    = 20,
    },


}

local blackListedWeps = {
    ["wep_jack_hmcd_hands"] = true,
    ["wep_jack_hmcd_fastzombhands"] = true,
    ["wep_jack_hmcd_zombhands"] = true,
    ["wep_jack_hmcd_zombhandsfast"] = true
}

local blackListedAmmo = {
    [8] = true,
    [9] = true,
    [10] = true
}

local RoundTextures = {
    ["Pistol"]     = "vgui/hud/hmcd_round_9",
    ["357"]        = "vgui/hud/hmcd_round_38",
    ["AlyxGun"]    = "vgui/hud/hmcd_round_22",
    ["Buckshot"]   = "vgui/hud/hmcd_round_12",
    ["AR2"]        = "vgui/hud/hmcd_round_76239",
    ["SMG1"]       = "vgui/hud/hmcd_round_4630",
    ["XBowBolt"]   = "vgui/hud/hmcd_round_arrow",
    ["AirboatGun"] = "vgui/hud/hmcd_nail",
    ["RPG_Round"]  = "vgui/hud/hmcd_round_76239"
}

local black  = Color(30, 30, 30, 128)
local black2 = Color(64, 64, 64, 128)
local gray   = Color(105, 105, 105, 128)

local function getText(text, limitW)
    local newText = {}
    local newText_I = 1
    local curretText = ""

    surface.SetFont("Trebuchet18")

    for i = 1, #text do
        local sumbol = string.sub(text, i, i)
        local w, h = surface.GetTextSize(curretText .. sumbol)

        if w >= limitW then
            newText_I = newText_I + 1
            curretText = sumbol
        else
            curretText = curretText .. sumbol
        end

        newText[newText_I] = curretText
    end

    return newText
end

local bodyvestIcons = {
    [""] = Material("empty"),
    ["Level IIIA"] = Material("vgui/icons/armor01"),
    ["Level III"]  = Material("vgui/icons/armor02")
}

local maskIcons = {
    [""] = Material("empty"),
    ["NVG"] = Material("vgui/icons/nvg")
}

local helmetIcons = {
    [""] = Material("empty"),
    ["ACH"] = Material("vgui/icons/helmet")
}

local function AddWeaponModel(parent, w, h, wepClass, wepTbl)
    local cfg = wepModels3D[wepClass]
    if not cfg then return end

    local mdl = cfg.model
        or (type(wepTbl) == "table" and (wepTbl.WorldModel or wepTbl.ViewModel))
        or nil
    if not mdl or mdl == "" then return end

    local model = vgui.Create("DModelPanel", parent)
    model:SetPos(2, 2)
    model:SetSize(w - 4, h - 4)
    model:SetMouseInputEnabled(false)
    model:SetKeyboardInputEnabled(false)
    model:SetCursor("arrow")
    model:SetPaintBackground(false)
    model:SetFOV(cfg.fov or 45)
    model:SetModel(mdl)

    model:SetAmbientLight(Color(180, 180, 180))
    model:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
    model:SetDirectionalLight(BOX_FRONT, Color(120, 120, 120))

    local modelPos = cfg.pos or Vector(0, 0, 0)
    local modelAng = cfg.ang or Angle(0, 45, 0)

    model.LayoutEntity = function(self, ent)
        if not IsValid(ent) then return end
        ent:SetAngles(modelAng)
        ent:SetPos(modelPos) 
    end

    local ent = model:GetEntity()
    if IsValid(ent) then
        local mins, maxs = ent:GetRenderBounds()
        local center = (mins + maxs) * 0.5

        local camPos = cfg.camPos
        local lookAt = cfg.lookAt or center

        if not camPos then
            local size = (maxs - mins):Length()
            if size <= 0 then
                camPos = center + Vector(40, 40, 20)
            else
                camPos = center + Vector(size, size, size * 0.5)
            end
        else
            camPos = camPos + center
        end

        model:SetCamPos(camPos)
        model:SetLookAt(lookAt)
    end

    return model
end

local function DrawWeaponIcon(button, w, h, wepTbl)
    if type(wepTbl) ~= "table" then return end
    local tex = wepTbl.IconTexture
    if not tex or tex == "" then return end

    local mat = Material(tex)
    if not mat or mat:IsError() then return end

    surface.SetMaterial(mat)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(2, 2, w - 4, h - 4)
end

local panel

net.Receive("inventory", function()
    local lply = LocalPlayer()

    if IsValid(panel) then 
        panel.override = true 
        panel:Remove() 
    end

    local lootEnt = net.ReadEntity()
    local success, items = pcall(net.ReadTable)
    local nickname = (lootEnt:IsPlayer() and lootEnt:Name()) or (lootEnt:GetNWString("Character_Name")) or ""
    if not success or not IsValid(lootEnt) then return end
    
    if items[lootEnt.curweapon] then items[lootEnt.curweapon] = nil end

    local items_ammo = net.ReadTable()
    items.weapon_hands = nil

    panel = vgui.Create("DFrame")
    panel:SetAlpha(255)
    panel:SetSize(600, 420)
    panel:Center()
    panel:SetDraggable(true)
    panel:MakePopup()
    panel:SetTitle(nickname .. "'s body")

    function panel:OnKeyCodePressed(key)
        if key == KEY_W or key == KEY_S or key == KEY_A or key == KEY_D or key == KEY_SPACE or key == KEY_BACKSPACE then 
            self:Remove() 
        end
    end
    
    function panel:OnRemove()
        if self.override then return end

        net.Start("inventory")
            net.WriteEntity(lootEnt)
        net.SendToServer()
    end

    panel.Paint = function(self, w, h)
        if not IsValid(lootEnt) or not LocalPlayer():Alive() then panel:Remove() return end

        draw.RoundedBox(0, 0, 0, w, h, black)
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
    end

    local x, y = 5, 27
    local corner = 6
    local rowMaxW = panel:GetWide() - 10
    local rowH = 50

    local function AddGridButton(btnW, btnH)
        if x + btnW > rowMaxW then
            x = 5
            y = y + rowH + 6
            rowH = btnH
        else
            if btnH > rowH then rowH = btnH end
        end

        local btnX, btnY = x, y
        x = x + btnW + 2

        return btnX, btnY
    end

    for wep in pairs(items) do
        local wepTbl = weapons.Get(wep) or wep
        local CarryWeight = (type(wepTbl) == "table" and wepTbl.CarryWeight) or 0
        if blackListedWeps[wep] then continue end

        local btnW = (CarryWeight >= 3000 and 50 * 4) or 50
        local btnH = (CarryWeight >= 3000 and 50 * 2) or 50

        local btnX, btnY = AddGridButton(btnW, btnH)

        local button = vgui.Create("DButton", panel)
        button:SetPos(btnX, btnY)
        button:SetSize(btnW, btnH)
        button:SetText("")

        local use3D = wepModels3D[wep] ~= nil

        button.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and black2 or Color(50,50,50,220))
            surface.SetDrawColor(0, 0, 0, 0)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)


            if not use3D then
                DrawWeaponIcon(self, w, h, wepTbl)
            end
        end

        if use3D then
            AddWeaponModel(button, btnW, btnH, wep, wepTbl)
        end

        button.DoClick = function(selfBtn)
            net.Start("ply_take_item")
                net.WriteEntity(lootEnt)
                net.WriteString(tostring(wep))
            net.SendToServer()
            selfBtn:Remove()
        end
        button.DoRightClick = button.DoClick
    end

    for ammo, amt in pairs(items_ammo) do
        if blackListedAmmo[ammo] then continue end

        local btnW, btnH = 50, 50
        local btnX, btnY = AddGridButton(btnW, btnH)

        local button = vgui.Create("DButton", panel)
        button:SetPos(btnX, btnY)
        button:SetSize(btnW, btnH)
        button:SetText('')

        local ammoName = game.GetAmmoName(ammo) or "Ammo"
        local text = getText(ammoName, button:GetWide() - corner * 2)

        button.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and black2 or Color(50,50,50,220))
            surface.SetDrawColor(0, 0, 0, 0)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            if RoundTextures[ammoName] then
                surface.SetMaterial(Material(RoundTextures[ammoName], "noclamp smooth"))
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(2, 2, w - 4, h - 4)
            end

            for i, txt in pairs(text) do
                draw.SimpleText(amt, "Trebuchet18", corner + 28, corner + 24 + (i - 1) * 3, color_white)
            end
        end

        button.DoClick = function(selfBtn)
            net.Start("ply_take_ammo")
                net.WriteEntity(lootEnt)
                net.WriteFloat(tonumber(ammo))
            net.SendToServer()
            selfBtn:Remove()
        end
        button.DoRightClick = button.DoClick
    end

    local bodyvestStr = (lootEnt.GetNWString and lootEnt:GetNWString("Bodyvest", "")) or ""
    local helmetStr   = (lootEnt.GetNWString and lootEnt:GetNWString("Helmet", "")) or ""
    local maskStr     = (lootEnt.GetNWString and lootEnt:GetNWString("Mask", "")) or ""

    if bodyvestStr ~= "" then
        local btnW, btnH = 90, 90
        local btnX, btnY = AddGridButton(btnW, btnH)

        local bodyvest = vgui.Create("DButton", panel)
        bodyvest:SetPos(btnX, btnY)
        bodyvest:SetSize(btnW, btnH)
        bodyvest.Armor = bodyvestStr
        bodyvest:SetText("")

        bodyvest.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and black2 or Color(50,50,50,220))
            surface.SetDrawColor(0, 0, 0, 0)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            if bodyvestIcons[bodyvest.Armor] then
                surface.SetMaterial(bodyvestIcons[bodyvest.Armor])
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(2, 2, w - 4, h - 4)
            end
        end
        bodyvest.DoClick = function(selfBtn)
            net.Start("ply_take_armor")
                net.WriteEntity(lootEnt)
                net.WriteString("Bodyvest")
                net.WriteString(tostring(bodyvest.Armor))
            net.SendToServer()
            selfBtn:Remove()
        end
    end

    if helmetStr ~= "" then
        local btnW, btnH = 100, 100
        local btnX, btnY = AddGridButton(btnW, btnH)

        local helmet = vgui.Create("DButton", panel)
        helmet:SetPos(btnX, btnY)
        helmet:SetSize(btnW, btnH)
        helmet.Armor = helmetStr
        helmet:SetText("")

        helmet.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and black2 or Color(50,50,50,220))
            surface.SetDrawColor(0, 0, 0, 0)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            if helmetIcons[helmet.Armor] then
                surface.SetMaterial(helmetIcons[helmet.Armor])
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(2, 2, w - 4, h - 4)
            end
        end
        helmet.DoClick = function(selfBtn)
            net.Start("ply_take_armor")
                net.WriteEntity(lootEnt)
                net.WriteString("Helmet")
                net.WriteString(tostring(helmet.Armor))
            net.SendToServer()
            selfBtn:Remove()
        end
    end

    if maskStr ~= "" then
        local btnW, btnH = 90, 90
        local btnX, btnY = AddGridButton(btnW, btnH)

        local mask = vgui.Create("DButton", panel)
        mask:SetPos(btnX, btnY)
        mask:SetSize(btnW, btnH)
        mask.Armor = maskStr
        mask:SetText("")

        mask.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and black2 or Color(50,50,50,220))
            surface.SetDrawColor(0, 0, 0, 0)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            if maskIcons[mask.Armor] then
                surface.SetMaterial(maskIcons[mask.Armor])
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(2, 2, w - 4, h - 4)
            end
        end
        mask.DoClick = function(selfBtn)
            net.Start("ply_take_armor")
                net.WriteEntity(lootEnt)
                net.WriteString("Mask")
                net.WriteString(tostring(mask.Armor))
            net.SendToServer()
            selfBtn:Remove()
        end
    end
end)
