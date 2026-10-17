local bandageVariants = {
    ["bandstomach"]     = {"Belly"},
    ["bandchest"]       = {"Chest"},
    ["bandgroin"]       = {"Groin"}, //FUCK JOHN! THEY SHOT ME IN MY SACK!
    ["bandleft_hand"]   = {"Hand Left", "Hand Down Left", "Hand Up Left"},
    ["bandleft_arm"]    = {"Hand Left", "Hand Down Left", "Hand Up Left"},
    ["bandright_hand"]  = {"Hand Right", "Hand Down Right", "Hand Up Right"},
    ["bandright_arm"]   = {"Hand Right", "Hand Down Right", "Hand Up Right"},
    ["bandleft_leg"]    = {"Leg Down Left", "Leg Up Left"},
    ["bandright_leg"]   = {"Leg Down Right", "Leg Up Right"} 
}

local function GetBodygroupID(ent, name)
    if not IsValid(ent) then return -1 end
    local search = string.lower(name):gsub("%s+", "")
    for i = 0, ent:GetNumBodyGroups() - 1 do
        local bgName = string.lower(ent:GetBodygroupName(i)):gsub("%s+", "")
        if bgName == search then return i end
    end
    return -1
end

local isDrawing = false

function HmcdPostDrawPlayer(ent, ply)
    if isDrawing then return end
    if not IsValid(ent) then return end

    if IsValid(ply) and ply:Alive() then
        ent.CachedBands = ent.CachedBands or {}
        local hasAny = false
        for k, _ in pairs(bandageVariants) do
            local val = ply:GetNWBool(k, false)
            ent.CachedBands[k] = val
            if val then hasAny = true end
        end
        local hVal = ply:GetNWBool("bandhead", false)
        ent.CachedBands["bandhead"] = hVal
        if hVal then hasAny = true end
        ent.HasBands = hasAny
        ent.SyncIndex = ply:EntIndex()
    end

    if not ent.HasBands then 
        if IsValid(ent.BandageEnt) then ent.BandageEnt:SetNoDraw(true) end
        if IsValid(ent.BandageHeadEnt) then ent.BandageHeadEnt:SetNoDraw(true) end
        return 
    end

    if ent == LocalPlayer() and GetViewEntity() == ent and not ent:ShouldDrawLocalPlayer() then return end

    if not IsValid(ent.BandageEnt) then
        ent.BandageEnt = ClientsideModel("models/distac/newbandage.mdl")
        ent.BandageEnt:SetNoDraw(true)
    end
    if not IsValid(ent.BandageHeadEnt) then
        ent.BandageHeadEnt = ClientsideModel("models/distac/newbandage-head.mdl")
        ent.BandageHeadEnt:SetNoDraw(true)
    end

    local bBody = ent.BandageEnt
    local bHead = ent.BandageHeadEnt
    local anyBody = false
    local isHead = ent.CachedBands["bandhead"]

    for i = 0, bBody:GetNumBodyGroups() - 1 do bBody:SetBodygroup(i, 0) end
    for nwKey, variants in pairs(bandageVariants) do
        if ent.CachedBands[nwKey] then
            anyBody = true
            local seed = (ent.SyncIndex or ent:EntIndex()) + #nwKey
            local randVal = util.SharedRandom("HMCD_Bands_" .. nwKey .. (ent.SyncIndex or ent:EntIndex()), 1, #variants, seed)
            local id = GetBodygroupID(bBody, variants[math.Round(randVal)])
            if id != -1 then bBody:SetBodygroup(id, 1) end
        end
    end

    isDrawing = true
        if anyBody then
            bBody:SetParent(ent)
            bBody:SetPos(ent:GetPos())
            bBody:SetAngles(ent:GetAngles())
            bBody:AddEffects(EF_BONEMERGE)
            ent:SetupBones()
            bBody:SetupBones()
            bBody:DrawModel()
        end
        if isHead then
            bHead:SetParent(ent)
            bHead:SetPos(ent:GetPos())
            bHead:SetAngles(ent:GetAngles())
            bHead:AddEffects(EF_BONEMERGE)
            bHead:SetupBones()
            bHead:DrawModel()
        end
    isDrawing = false
end

hook.Add("PostPlayerDraw", "Hmcd_Bandages_Normal", function(ply)
    if not IsValid(ply) or not ply:Alive() then return end
    local rag = ply:GetNWEntity("Ragdoll")
    if IsValid(rag) or ply:GetNWBool("fake", false) then
        if IsValid(ply.BandageEnt) then ply.BandageEnt:SetNoDraw(true) end
        if IsValid(ply.BandageHeadEnt) then ply.BandageHeadEnt:SetNoDraw(true) end
        return
    end
    HmcdPostDrawPlayer(ply, ply)
end)

hook.Add("PostDrawOpaqueRenderables", "Hmcd_Bandages_Ragdolls", function()
    local rags = ents.FindByClass("prop_ragdoll")
    for i = 1, #rags do
        local rag = rags[i]
        if not IsValid(rag) then continue end
        
        local ply = rag:GetNWEntity("RagdollOwner")
        if not IsValid(ply) then ply = rag:GetInternalVariable("m_hPlayer") end
        
        if IsValid(ply) or rag.HasBands then
            HmcdPostDrawPlayer(rag, ply)
        end
    end
end)

hook.Add("EntityRemoved", "Hmcd_BandageCleanup", function(ent)
    if IsValid(ent.BandageEnt) then ent.BandageEnt:Remove() end
    if IsValid(ent.BandageHeadEnt) then ent.BandageHeadEnt:Remove() end
end)