local matindex = {
    ["male01"] = 3,
    ["male02"] = 3,
    ["male03"] = 4,
    ["male04"] = 5,
    ["male05"] = 5,
    ["male06"] = 0,
    ["male07"] = 4,
    ["male08"] = 0,
    ["male09"] = 3,
    ["female01"] = 2,
    ["female02"] = 3,
    ["female03"] = 3,
    ["female04"] = 1,
    ["female05"] = 2,
    ["female06"] = 4,
}

local sex = {
    ["male01"] = "male",
    ["male02"] = "male",
    ["male03"] = "male",
    ["male04"] = "male",
    ["male05"] = "male",
    ["male06"] = "male",
    ["male07"] = "male",
    ["male08"] = "male",
    ["male09"] = "male",
    ["female01"] = "female",
    ["female02"] = "female",
    ["female03"] = "female",
    ["female04"] = "female",
    ["female05"] = "female",
    ["female06"] = "female"
}

net.Receive("accessory", function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end
    ply.ModelSex = net.ReadString()
    ply.Accessory = net.ReadString()
    if IsValid(ply.AccessoryModel) then
        ply.AccessoryModel:Remove()
        ply.AccessoryModel = nil
    end
end)

net.Receive("open_appmenu", function()
    if OpenMenu then
        OpenMenu()
    end
end)

surface.CreateFont("HMCD_Title", {
    font = "Roboto",
    size = 32,
    weight = 1000,
    antialias = true
})

surface.CreateFont("HMCD_Label", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true
})

local AppearanceMenuOpen, Frame = false, nil

function OpenMenu()
    if AppearanceMenuOpen then return end
    AppearanceMenuOpen = true
    local ply = LocalPlayer()

    Frame = vgui.Create("DFrame")
    Frame:SetSize(ScrW() * 0.7, ScrH() * 0.8)
    Frame:Center()
    Frame:SetTitle("")
    Frame:MakePopup()
    Frame:ShowCloseButton(true)
    Frame:SetDraggable(true)
    
    Frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 240))
        draw.RoundedBox(4, 0, 0, w, 30, Color(30, 30, 30, 255))
        draw.SimpleText("Character Customization", "HMCD_Title", 10, 35, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    
    Frame.OnClose = function()
        AppearanceMenuOpen = false
    end

    local ControlPanel = vgui.Create("DPanel", Frame)
    ControlPanel:Dock(LEFT)
    ControlPanel:SetWide(Frame:GetWide() * 0.35)
    ControlPanel:DockMargin(10, 60, 10, 10)
    ControlPanel.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 100))
    end
    
    local PreviewPanel = vgui.Create("DModelPanel", Frame)
    PreviewPanel:Dock(FILL)
    PreviewPanel:DockMargin(0, 0, 10, 10)
    PreviewPanel:SetFOV(60)
    
    local Scroll = vgui.Create("DScrollPanel", ControlPanel)
    Scroll:Dock(FILL)
    Scroll:DockMargin(10, 10, 10, 10)

    local function AddLabel(text, parent)
        local lbl = vgui.Create("DLabel", parent)
        lbl:SetText(text)
        lbl:SetFont("HMCD_Label")
        lbl:SetColor(Color(200, 200, 200))
        lbl:Dock(TOP)
        lbl:DockMargin(0, 10, 0, 5)
        return lbl
    end

    local function AddCombo(parent)
        local cmb = vgui.Create("DComboBox", parent)
        cmb:Dock(TOP)
        cmb:SetTall(25)
        return cmb
    end

    AddLabel("Name", Scroll)
    local NameEntry = vgui.Create("DTextEntry", Scroll)
    NameEntry:Dock(TOP)
    NameEntry:SetTall(25)
    NameEntry:SetText(ply:GetNWString("Character_Name", "Unknown"))

    AddLabel("Description", Scroll)
    local DescEntry = vgui.Create("DTextEntry", Scroll)
    DescEntry:Dock(TOP)
    DescEntry:SetTall(25)
    DescEntry:SetText(ply:GetNWString("Character_Desc", "Nothing interesting."))

    AddLabel("Model", Scroll)
    local MdlSelect = AddCombo(Scroll)
    for k, v in pairs(Models_Customize or {}) do
        MdlSelect:AddChoice(v)
    end

    AddLabel("Clothes Style", Scroll)
    local CSelect = AddCombo(Scroll)
    for k, v in pairs(Clothes_Customize or {}) do
        CSelect:AddChoice(v)
    end
    
    AddLabel("Accessory", Scroll)
    local ASelect = AddCombo(Scroll)
    for k, v in pairs(AccessoryList or {}) do
        ASelect:AddChoice(k)
    end

    AddLabel("Clothing Color", Scroll)
    local Mixer = vgui.Create("DColorMixer", Scroll)
    Mixer:Dock(TOP)
    Mixer:SetTall(150)
    Mixer:SetPalette(true)
    Mixer:SetAlphaBar(false)
    Mixer:SetWangs(true)

    --[[AddLabel("Model Rotation", Scroll)
    local RotSlider = vgui.Create("DNumSlider", Scroll)
    RotSlider:Dock(TOP)
    RotSlider:SetMin(-180)
    RotSlider:SetMax(180)
    RotSlider:SetDecimals(0)
    RotSlider:SetValue(45)
    RotSlider:SetDark(false)--]] // сука нахуя делать отдельной хуйней если можно сделать потом по другому

    local SaveBtn = vgui.Create("DButton", ControlPanel)
    SaveBtn:Dock(BOTTOM)
    SaveBtn:DockMargin(10, 10, 10, 10)
    SaveBtn:SetTall(40)
    SaveBtn:SetText("Save & Apply")
    SaveBtn:SetFont("HMCD_Label")
    
    if file.Exists("union_appearance.txt", "DATA") then
        local vartxt = string.Split(file.Read("union_appearance.txt", "DATA"), "\n")
        
        MdlSelect:SetValue(tostring(vartxt[1] or ""))
        
        local rVal = (tonumber(vartxt[2]) or 0.5) * 255
        local gVal = (tonumber(vartxt[3]) or 0.5) * 255
        local bVal = (tonumber(vartxt[4]) or 0.5) * 255
        Mixer:SetColor(Color(rVal, gVal, bVal, 255))
        
        CSelect:SetValue(tostring(vartxt[5] or ""))
        NameEntry:SetValue(tostring(vartxt[6] or ""))
        DescEntry:SetValue(tostring(vartxt[7] or ""))
        
        local loadedAcc = vartxt[9] and string.Trim(tostring(vartxt[9])) or "none"
        if not AccessoryList or not AccessoryList[loadedAcc] then loadedAcc = "none" end
        ASelect:SetValue(loadedAcc)
    else
        local rndModel = table.Random(Models_Customize or {"male01"})
        local rndClothes = table.Random(Clothes_Customize or {"normal"})
        local rndAcc = "none"
        
        MdlSelect:SetValue(rndModel)
        CSelect:SetValue(rndClothes)
        ASelect:SetValue(rndAcc)
        Mixer:SetColor(Color(math.random(0,255), math.random(0,255), math.random(0,255), 255))
    end

    local function UpdatePreview()
        local mdlName = MdlSelect:GetValue()
        local clothes = CSelect:GetValue()
        local col = Mixer:GetColor()
        
        if not mdlName or mdlName == "Model" then return end
        
        local trueModel = player_manager.TranslatePlayerModel(mdlName)
        util.PrecacheModel(trueModel)
        PreviewPanel:SetModel(trueModel)
        
        local ent = PreviewPanel.Entity
        if not IsValid(ent) then return end
        
        ent:SetSubMaterial()
        
        if clothes ~= "Style Clothes" and clothes ~= "none" then
            local index = (ent.FindClothingMatIndex and ent:FindClothingMatIndex()) or matindex[mdlName]
            if index and index >= 0 then
                local mats = ent:GetMaterials()
                if mats and mats[index + 1] then
                    local targetMat = string.lower(mats[index + 1])
                    if not string.find(targetMat, "eye") and not string.find(targetMat, "pupil") and not string.find(targetMat, "face") then
                        ent:SetSubMaterial(index, "models/humans/" .. (sex[mdlName] or "male") .. "/group01/" .. clothes)
                    end
                end
            end
        end
        
        local vec = Vector(col.r / 255, col.g / 255, col.b / 255)
        ent.GetPlayerColor = function() return vec end
        
        local accName = ASelect:GetValue()
        ent.AccData = nil
        if accName and accName ~= "Accessory" and AccessoryList and AccessoryList[accName] then
            local accInfo = AccessoryList[accName]
            if accInfo[1] then
                ent.AccData = {
                    Model = accInfo[1],
                    Bone = accInfo[2],
                    Info = (sex[mdlName] == "male") and accInfo[3] or accInfo[4],
                    Skin = accInfo[6] or 0
                }
            end
        end
    end

    MdlSelect.OnSelect = UpdatePreview
    CSelect.OnSelect = UpdatePreview
    ASelect.OnSelect = UpdatePreview
    Mixer.ValueChanged = UpdatePreview

    UpdatePreview()
    
    function PreviewPanel:LayoutEntity(ent)
        ent:SetAngles(Angle(0, RotSlider:GetValue(), 0))
        ent:SetSequence(ent:LookupSequence("idle_all_01"))
        if (ent:GetCycle() >= 1) then ent:SetCycle(0) end
        self:RunAnimation()
    end
    
    function PreviewPanel:PostDrawModel(ent)
        if not ent.AccData then return end
        local data = ent.AccData
        
        if not IsValid(ent.AccModel) then
            ent.AccModel = ClientsideModel(data.Model)
            if IsValid(ent.AccModel) then
                ent.AccModel:SetNoDraw(true)
            end
        end
        
        local acc = ent.AccModel
        if not IsValid(acc) then return end
        
        if acc:GetModel() ~= data.Model then
            acc:SetModel(data.Model)
        end
        
        acc:SetSkin(data.Skin or 0)
        
        local boneID = ent:LookupBone(data.Bone)
        if not boneID then return end
        
        local pos, ang = ent:GetBonePosition(boneID)
        if not pos then return end
        
        local posInfo = data.Info
        if not posInfo then return end
        local offsetVec = posInfo[1]
        local offsetAng = posInfo[2]
        local scale = posInfo[3]
        
        local newPos = pos + ang:Right() * offsetVec.x + ang:Forward() * offsetVec.y + ang:Up() * offsetVec.z
        
        ang:RotateAroundAxis(ang:Right(), offsetAng.p)
        ang:RotateAroundAxis(ang:Up(), offsetAng.y)
        ang:RotateAroundAxis(ang:Forward(), offsetAng.r)
        
        acc:SetRenderOrigin(newPos)
        acc:SetRenderAngles(ang)
        
        local mat = Matrix()
        mat:Scale(Vector(scale, scale, scale))
        acc:EnableMatrix("RenderMultiply", mat)
        
        acc:DrawModel()
    end
    
    PreviewPanel.OnRemove = function(self)
        if IsValid(self.Entity) and IsValid(self.Entity.AccModel) then
            self.Entity.AccModel:Remove()
        end
    end

    SaveBtn.DoClick = function()
        local Maudel = MdlSelect:GetValue()
        local col = Mixer:GetColor()
        local R, G, B = col.r / 255, col.g / 255, col.b / 255
        local Clothes = CSelect:GetValue()
        local BystName = NameEntry:GetValue()
        local BystDesc = DescEntry:GetValue()
        local rost = 1
        local Accs = ASelect:GetValue()
        
        net.Start("hmcd_save_appearance")
            net.WriteString(Maudel)
            net.WriteVector(Vector(R, G, B))
            net.WriteString(Clothes)
            net.WriteString(BystName)
            net.WriteString(BystDesc)
            net.WriteString(Accs)
        net.SendToServer()

        local RawData = tostring(Maudel) .. "\n" .. tostring(R) .. "\n" .. tostring(G) .. "\n" .. tostring(B) .. "\n" .. tostring(Clothes) .. "\n" .. tostring(BystName) .. "\n" .. tostring(BystDesc) .. "\n" .. tostring(rost) .. "\n" .. tostring(Accs)
        file.Write("union_appearance.txt", RawData)
        
        Frame:Close()
    end
end

concommand.Add("hmcd_appearance_menu", OpenMenu)

local function ApplySavedAppearance()
    if file.Exists("union_appearance.txt", "DATA") then
        local vartxt = string.Split(file.Read("union_appearance.txt", "DATA"), "\n")
        if #vartxt >= 5 then
            local modelName = tostring(vartxt[1] or "male01")
            local rVal = tonumber(vartxt[2]) or 0.5
            local gVal = tonumber(vartxt[3]) or 0.5
            local bVal = tonumber(vartxt[4]) or 0.5
            local clothesStyle = tostring(vartxt[5] or "normal")
            local custName = tostring(vartxt[6] or "")
            local custDesc = tostring(vartxt[7] or "")
            local loadedAcc = vartxt[9] and string.Trim(tostring(vartxt[9])) or "none"

            timer.Simple(1, function()
                net.Start("hmcd_save_appearance")
                    net.WriteString(modelName)
                    net.WriteVector(Vector(rVal, gVal, bVal))
                    net.WriteString(clothesStyle)
                    net.WriteString(custName)
                    net.WriteString(custDesc)
                    net.WriteString(loadedAcc)
                net.SendToServer()
            end)
        end
    end
end

hook.Add("InitPostEntity", "HMCD_AutoApplyAppearance", ApplySavedAppearance)
