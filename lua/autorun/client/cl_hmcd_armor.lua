local function SaveArmor(armor)
    local info
    for i,v in pairs(armor) do
        info[i] = v
    end
    return info
end
net.Receive("hmcd_armor_drop", function()
    local str = net.ReadString()
    local ply = net.ReadPlayer()
    for _,slot in pairs(ply.EquippedArmor) do
        for i,v in pairs(slot) do
            if i == str then
                v.model:SetNoDraw(true)
                v = nil
            end
        end
    end
end)
net.Receive("hmcd_armor_ragdoll_nodraw", function()
    local ply = net.ReadPlayer()
    local drawing = net.ReadBool()
    if ply == LocalPlayer() then return end
    for _,slot in pairs(ply.EquippedArmor) do
        for key,armor in pairs(slot) do
            armor.model:SetNoDraw(true)
        end
    end
end)


net.Receive("hmcd_set_size", function()
    local name = net.ReadString()
    local size = net.ReadFloat()
    local carvector = net.ReadVector()
    local ply = net.ReadPlayer()
    ply.EquippedArmor = ply.EquippedArmor or {}
    ply.EquippedArmor.Body = ply.EquippedArmor.Body or {}
    if not ply.EquippedArmor.Body[name] then return end
    ply.EquippedArmor.Body[name].model:SetModelScale(size)
    ply.EquippedArmor.Body[name].vector = ply.EquippedArmor.Body[name].vector + carvector
end)

net.Receive("hmcd_armor_nodraw", function()
    ply = net.ReadPlayer()
    for _,slot in pairs(ply.EquippedArmor) do
        for key,armor in pairs(slot) do
            armor.model:SetNoDraw(true)
            armor.model = nil
        end
    end
    
end)
net.Receive("armor_end_round", function()
    local ply = net.ReadPlayer()
    for _,slot in pairs(ply.EquippedArmor) do
        for key,armor in pairs(slot) do
            armor.model:SetNoDraw(true)
            armor.model = nil
        end
        table.Empty(slot)
    end

end)


net.Receive("hmcd_armor_ragdoll", function()
    ply = net.ReadPlayer()
    for i,v in pairs(ply.EquippedArmor) do
        for index,value in pairs(v) do
            value.model:SetNoDraw(true)
        end
    end
end)
net.Receive("ply_die", function()
    ply = net.ReadPlayer()
    for i,v in pairs(ply.EquippedArmor) do
        for index,value in pairs(v) do
            value.model:SetNoDraw(true)
        end
        table.Empty(v)
    end
    
end)





net.Receive("hmcd_armor_equip", function()
    
    local slot = net.ReadString()
    local model = net.ReadString()
    local angle = net.ReadAngle()
    local vector = net.ReadVector()
    local bone = net.ReadString()  
    local ply = net.ReadPlayer()
    local name = net.ReadString() 
    local material = net.ReadString() 


    ply.EquippedArmor = ply.EquippedArmor or {}
    ply.EquippedArmor[slot] = ply.EquippedArmor[slot] or {}
    
    local armor = ply.EquippedArmor[slot]
    armor[name] = armor[name] or {}
    armor[name].name = name
    armor[name].vector = vector
    armor[name].angle = angle
    armor[name].bone = bone
    if material then
        armor[name].material = material
    end

    armor[name].model = ClientsideModel(model)
end)


function hmcd.RenderArmor(ply)
  
    if not ply.EquippedArmor then return end



    for index, slotData in pairs(ply.EquippedArmor) do
            for name,armor in pairs(slotData) do

                if not IsValid(armor.model) then continue end
                
            



                local boneID = ply:LookupBone(armor.bone)
                if not boneID then continue end
                
        
                local Pos, Ang = ply:GetBonePosition(boneID)
    

                if armor.vector then
                    Pos = Pos + Ang:Forward() * armor.vector.x
                              + Ang:Right()   * armor.vector.y
                              + Ang:Up()      * armor.vector.z
                end
        
                if armor.angle then
                    Ang:RotateAroundAxis(Ang:Forward(), armor.angle.r or 0)
                    Ang:RotateAroundAxis(Ang:Right(),   armor.angle.p or 0)
                    Ang:RotateAroundAxis(Ang:Up(),      armor.angle.y or 0)
                end
                --[[if armor.size then
                    armor.model:SetModelScale(armor.size)
                end]]

                armor.model:SetPos(Pos)
                armor.model:SetAngles(Ang)
                armor.model:SetupBones()
                if armor.material then
                    armor.model:SetMaterial(armor.material)
                end
                
                armor.model:DrawModel()
           


            
            
            end
    end
end

