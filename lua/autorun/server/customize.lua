util.AddNetworkString("open_appmenu")
util.AddNetworkString("hmcd_save_appearance")

function OpenAppMenu(ply, cmd, args)
    if not IsValid(ply) then return end
    net.Start("open_appmenu")
    net.Send(ply)
end

hook.Add("PlayerSay", "OpenAppearanceMenu", function(ply, text)
    if string.lower(text) == "!appearance" or string.lower(text) == "!customize" then
        OpenAppMenu(ply)
        return ""
    end
end)

net.Receive("hmcd_save_appearance", function(len, ply)
    if not IsValid(ply) then return end

    local modelName = net.ReadString()
    local colorVec = net.ReadVector()
    local clothesStyle = net.ReadString()
    local custName = net.ReadString()
    local custDesc = net.ReadString()
    local accsName = net.ReadString()

    ply.CustomModel = modelName
    ply.CustomColor = colorVec
    ply.CustomClothes = clothesStyle
    ply.CustomName = custName
    ply.CustomDescription = custDesc
    ply.CustomAccessory = accsName

    if custName and custName ~= "" then
        ply:SetNWString("Character_Name", custName)
    end
    if custDesc and custDesc ~= "" then
        ply:SetNWString("Character_Desc", custDesc)
    end

    if player_manager then
        local trueModel = player_manager.TranslatePlayerModel(modelName)
        if trueModel then
            util.PrecacheModel(trueModel)
        end
    end
end)

local function ManualIdentity(ply, name, args)
    if not IsValid(ply) or not args then return end
    
    local Maudel = args[1]
    local R = tonumber(args[2])
    local G = tonumber(args[3])
    local B = tonumber(args[4])
    local Clothes = args[5]
    local BystName = args[6]
    local BystDesc = args[7]

    if not (Maudel and R and G and B and Clothes and BystName) then return end

    ply.CustomModel = Maudel
    ply.CustomColor = Vector(R, G, B)
    ply.CustomClothes = Clothes
    ply.CustomName = BystName
    ply.CustomDescription = BystDesc or "Nothing interesting."
end

concommand.Add("hmcd_appearance_menu_manual", ManualIdentity)
concommand.Add("customize_manual", ManualIdentity)
