AddCSLuaFile()
hmcd = hmcd or {}
hmcd.Armor = {}
hmcd.Armor.Body = {}
hmcd.Armor.Head = {}
local entbase = "ArmorBase"


if SERVER then
    util.AddNetworkString("hmcd_armor_equip")
    util.AddNetworkString("hmcd_armor_nodraw") 
    util.AddNetworkString("hmcd_set_size")
    util.AddNetworkString("hmcd_drop_armor")
end
ammotypes_now_armor = {
    [3] = 5,
    [4] = 10,
    [7] = 3,
    [1] = 14,
    [5] = 7,
}
hmcd.armorsprefabs = {
    [1] = {"ent_hmcd_plate_3a", "ent_hmcd_ach_helmet"},
    [2] = {"ent_hmcd_plate_3a", "ent_hmcd_uk_carrier" , "ent_hmcd_ach_helmet"},
    [3] = {"ent_hmcd_ballistic_vest", "ent_hmcd_ach_helmet"},
    [4] = {"ent_hmcd_ballistic_vest", "ent_hmcd_ach_helmet"},
}
hmcd.ARMOR_STR = {
    Body = {
        ["Plate"] = "BodyPlate",
        ["Vest"] = "BodyVest",
        ["Carrier"] = "BodyCarrier",
    },
}
local split = {
    ["BodyPlate"] = true,
    ["BodyCarrier"] = true
}
function hmcd.FindArmor(str)
    for _,slot in pairs(hmcd.Armor) do
        for _, armortype in pairs(slot) do
            for _,armor in pairs(armortype) do
                if armor.PrintName == str then
                    return armor
                end
            end
        end
    end
end

function hmcd.FindArmorKey(str)
    for _,slot in pairs(hmcd.Armor) do
        for _, armortype in pairs(slot) do
            for index,armor in pairs(armortype) do
                if armor.PrintName == str then
                    return index
                end
            end
        end
    end
end

--Броники всякие которые не 200
hmcd.Armor.Body["Vest"] = {
    ["ballistic_vest"] = {
        PrintName = "Ballistic IV Vest",
        Model = "models/combataegis/body/ballisticvest_d.mdl",
        EquippedModel = "models/combataegis/body/ballisticvest.mdl",
        vector = Vector(9,0,0),
        angle = Angle(-105,180,-90),
        Spawnable = true,
        Mass = 3,
        Bone = "ValveBiped.Bip01_Spine4",
        Protection = 7,
        State = 60,
        Material = "models/combataegis/body/ballisticvest",
        ImpactSound = "physics/metal/weapon_impact_soft3.wav",
    }
}
hmcd.Armor.Body["Plate"] = {
    ["plate_3a"] = {
        PrintName = "Level IIIA Plate",
        Model = "models/jworld_equipment/kevlar.mdl",
        EquippedModel = "models/sal/acc/armor01.mdl",
        vector = Vector(-56,-18,0),
        angle = Angle(-75,0,90),
        ragvector = Vector(-57,-2.5,0),
        ragangle = Angle(-90,0,90),
        Spawnable = true,
        Mass = 5,
        Bone = "ValveBiped.Bip01_Spine4",
        Protection = 5,
        State = 100,
        Material = "models/mat_jack_hmcd_armor",
        ImpactSound = "physics/metal/weapon_impact_soft3.wav", 
    },
    ["police"] = {
        PrintName = "Police Plate",
        Model = "models/eu_homicide/armor_prop.mdl",
        EquippedModel = "models/eu_homicide/armor_on.mdl",
        vector = Vector(-10,-5,0),
        angle = Angle(-105,180,-90),
        ragvector = Vector(-10,-2.2,0),
        ragangle = Angle(-90,180,-90),
        Spawnable = true,
        Mass = 5,
        Bone = "ValveBiped.Bip01_Spine4",
        Protection = 6,
        State = 80,
        ImpactSound = "physics/metal/weapon_impact_soft3.wav", 
    },
}
hmcd.Armor.Body["Carrier"] = { --models/combataegis/body/smershvest.mdl
    ["uk_carrier"] = {
        PrintName = "Uk Carrier",
        Model = "models/combataegis/body/ukvest_d.mdl",
        EquippedModel = "models/combataegis/body/ukvest.mdl",
        CarSize = 1.27,
        CarVector = Vector(2,0,0),
        vector = Vector(9.2,-0.45,0),
        ragvector = Vector(12,-1.5,0),
        ragangle = Angle(-90,180,-90),
        angle = Angle(-105,180,-90),
        Spawnable = true,
        Mass = 2,
        Bone = "ValveBiped.Bip01_Spine4",
        Material = "models/combataegis/body/ukvest_d",
        EquippedMaterial = "models/combataegis/body/ukvest",
        ImpactSound = "physics/metal/weapon_impact_soft3.wav",
    },
    ["smersh"] = {
        PrintName = "Smersh Load-Bearing Vest",
        Model = "models/combataegis/body/smershvest_d.mdl",
        EquippedModel = "models/combataegis/body/smershvest.mdl",
        CarSize = 1.15,
        CarVector = Vector(1.2,0,0),
        vector = Vector(11,0.5,0),
        angle = Angle(-105,180,-90),
        Spawnable = true,
        Mass = 2.5,
        Bone = "ValveBiped.Bip01_Spine4",
        Material = "models/combataegis/body/smershvest_d",
        EquippedMaterial = "models/combataegis/body/smershvest",
        ImpactSound = "physics/metal/weapon_impact_soft3.wav",
    },
}



--шлемакии
hmcd.Armor.Head["Helmet"] = {
    ["ach_helmet"] = {
        PrintName = "ACH Helmet",
        Model = "models/barney_helmet.mdl",
        EquippedModel = "models/barney_helmet.mdl",
        vector = Vector(1.6,1.5,0),
        angle = Angle(-90,0,-90),
        ragangle = Angle(-75,0,-90),
        State = 20,
        Protection = 3,
        Spawnable = true,
        Mass = 1,
        Bone = "ValveBiped.Bip01_Head1",
        Material = "models/mat_jack_hmcd_armor",
        ImpactSound = "physics/metal/weapon_impact_soft3.wav",
    },
    ["mich_helmet"] = {
        PrintName = "MICH Helmet",
        Model = "models/combataegis/head/michhelmet_d.mdl",
        EquippedModel = "models/combataegis/head/michhelmet.mdl",
        vector = Vector(4,1,0),
        angle = Angle(-90,0,-90),
        ragangle = Angle(-75,0,-90),
        ragvector = Vector(3.4,0,0),
        State = 20,
        Protection = 4,
        Spawnable = true,
        Mass = 1,
        Bone = "ValveBiped.Bip01_Head1",
        Material = "mmodels/combataegis/head/michhelmet_d",
        EquippedMaterial = "models/combataegis/head/michhelmet",
        ImpactSound = "physics/metal/weapon_impact_soft3.wav",
    },
    ["ssh68"] = {
        PrintName = "SSH-68 Helmet",
        Model = "models/combataegis/head/ssh68_d.mdl",
        EquippedModel = "models/combataegis/head/ssh68.mdl",
        vector = Vector(4,1,0),
        angle = Angle(-90,0,-90),
        ragangle = Angle(-90,0,-90),
        State = 20,
        Protection = 2,
        Spawnable = true,
        Mass = 1,
        Bone = "ValveBiped.Bip01_Head1",
        Material = "models/combataegis/head/ssh68_d",
        EquippedMaterial = "models/combataegis/head/ssh68",
        ImpactSound = "physics/metal/weapon_impact_soft3.wav",
    }
}


local function armor_init()
    for i,v in pairs(hmcd.Armor.Body) do
        local str = hmcd.ARMOR_STR.Body[i]
        for armorkey,ent in pairs(v) do
            ent.armorkey = "ent_hmcd_"..armorkey
            ent.Str = str
            ent.Slot = "Body"
            hmcd.DoEntity(ent,"ent_hmcd_armor_base","ent_hmcd_",armorkey,"HMCD: QIWI - Armors")
        end
    end
    for armorkey,ent in pairs(hmcd.Armor.Head.Helmet) do
        local str = "HeadHelmet"
        ent.armorkey = "ent_hmcd_"..armorkey
        ent.Str = str
        ent.Slot = "Head"
        hmcd.DoEntity(ent,"ent_hmcd_armor_base","ent_hmcd_",armorkey,"HMCD: QIWI - Armors")
    end
end

    local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:DropArmor(name)
    if not name then return end
        
    for _,slot in pairs(self.EquippedArmor) do
        for key,armor in pairs(slot) do
            if key == name then
                if SERVER then
                    net.Start("hmcd_armor_drop")
    			    net.WriteString(key)
                    net.WritePlayer(self)
	    		    net.Broadcast()
                end
                local ent = ents.Create("ent_hmcd_"..armor.armorkey)
                ent.Protection = armor.Protection or hmcd.FindArmor(key).Protection
                ent.State = armor.State or hmcd.FindArmor(key).State
                ent:SetPos(self:GetPos())
                ent:Spawn()
                if ply.fake then
                    ply.fakeragdoll:SetNWEntity("ent_armor_prop_" .. hmcd.FindArmorKey(key), nil)
                    ply.fakeragdoll.ArmorModel[name]:Remove()
                end
            end
        end
    end
end

    function hmcd.EquipArmor(ply,ent)
        local equip = false -- for debug write true
        
        if not ply:GetNWString(ent.Str, false) then
            
            if split[ent.Str] and not ply:GetNWString("BodyVest", false) then
                
                equip = true
            elseif ent.Str == "BodyVest" then
                if not ply:GetNWString("BodyPlate", false) and not ply:GetNWString("BodyCarrier", false) then
                    equip = true
                end
            elseif ent.Str == "HeadHelmet" then
                equip = true
            end
        end
        if equip then
            
        ply.EquippedArmor[ent.Slot][ent.PrintName] = {}
        ply.EquippedArmor[ent.Slot][ent.PrintName].ImpactSound = ent.ImpactSound
        ply.EquippedArmor[ent.Slot][ent.PrintName].Mass = ent.Mass
        ply.EquippedArmor[ent.Slot][ent.PrintName].Key = ent.armorkey
        ply.EquippedArmor[ent.Slot][ent.PrintName].Material = ent.Material
        ply.EquippedArmor[ent.Slot][ent.PrintName].Bone = ent.Bone
        ply.EquippedArmor[ent.Slot][ent.PrintName].EquippedModel = ent.EquippedModel
        ply.EquippedArmor[ent.Slot][ent.PrintName].PrintName = ent.PrintName
        ply.EquippedArmor[ent.Slot][ent.PrintName].angle = ent.angle
        ply.EquippedArmor[ent.Slot][ent.PrintName].vector = ent.vector
        ply.EquippedArmor[ent.Slot][ent.PrintName].rag_angle = ent.ragangle
        ply.EquippedArmor[ent.Slot][ent.PrintName].rag_vector = ent.ragvector
        ply.EquippedArmor[ent.Slot][ent.PrintName].Slot = ent.Slot
        ply.EquippedArmor[ent.Slot][ent.PrintName].EquippedMaterial = ent.EquippedMaterial or nil
        if ent.State and ent.Protection then
            ply.EquppedArmor[ent.Slot][ent.PrintName].State = ent.State
            ply.EquppedArmor[ent.Slot][ent.PrintName].Protection = ent.Protection
        end

            net.Start("hmcd_armor_equip")
	        net.WriteString(ent.Slot)
            net.WriteString(ent.EquippedModel)

            net.WriteAngle(ply.EquippedArmor[ent.Slot][ent.PrintName].angle)
            net.WriteVector(ply.EquippedArmor[ent.Slot][ent.PrintName].vector)
            net.WriteString(ent.Bone)
    	    net.WritePlayer(ply)
            net.WriteString(ent.PrintName)
            if ent.EquippedMaterial then
                net.WriteString(ent.EquippedMaterial)
            else
                net.WriteString(ent.Material)
            end
            net.Broadcast()
            if ply:GetNWString("BodyCarrier", false) or ply:GetNWString("BodyPlate", false) and ent.Slot != "Head" then
                if ent.PrintName != ply:GetNWString("BodyPlate", "") and ent.PrintName != ply:GetNWString("BodyCarrier", "") then
                    net.Start("hmcd_set_size")
                    if not ply:GetNWString("BodyCarrier", false) then
                        net.WriteString(ent.PrintName)
                        net.WriteFloat(ent.CarSize)
                        net.WriteVector(ent.CarVector)
                    else
                        net.WriteString(ply:GetNWString("BodyCarrier", false))
                        net.WriteFloat(hmcd.FindArmor(ply:GetNWString("BodyCarrier", false)).CarSize)
                        net.WriteVector(hmcd.FindArmor(ply:GetNWString("BodyCarrier", false)).CarVector)
                    end
                    net.WritePlayer(ply)   
                   net.Broadcast()
                   ply.CarrierFlagged = true
                end
            end

        ply:SetNWString(ent.Str, ent.PrintName)


       net.Start("hmcd_armor_nodraw")
       net.WritePlayer(ply)
       net.Send(ply)
            sound.Play("snd_jack_hmcd_disguise.wav",ply:GetPos(),65,80)
		    ent:Remove()
        else
            ply:PickupObject(ent)
        end
       

    end
if SERVER then
    util.AddNetworkString("ply_die")
    util.AddNetworkString("hmcd_armor_unragdoll_draw")
    hook.Add("PlayerDeath", "ArmorNil", function(ply)
        net.Start("ply_die")
        net.WritePlayer(ply)
        net.Broadcast()
        for _,slot in pairs(ply.EquippedArmor) do
            table.Empty(slot)
        end
        for _,val in ipairs(hmcd.ARMOR_STR.Body) do
            ply:SetNWString(val, nil)
        end
        ply:SetNWString("HeadHelmet", nil)
    end)
    function hmcd.UnRagdollArmor(ply)
        net.Start("hmcd_armor_unragdoll_draw")
        net.WritePlayer(ply)
        net.Broadcast()
    end
    --[[concommand.Add("hmcd_give_armor", function(ply,cmd,args)
        if not IsValid(ply) then return end
        local rf = RecipientFilter()
        local sply = args[1]
        PrintTable(rf:GetPlayers())
        for i,v in pairs(rf:GetPlayers()) do
            print(v)
        end
        
        local ent = args[2]
        if args[3] then
                
        end

    end)]]
end


armor_init()
hook.Add("Initialize", "init-atts", armor_init)



    
