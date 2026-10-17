if SERVER then
    AddCSLuaFile()
end

HMCD_ClothingIndices = {
    ["male01"]   = 3,
    ["male02"]   = 3,
    ["male03"]   = 4,
    ["male04"]   = 5,
    ["male05"]   = 5,
    ["male06"]   = 1,
    ["male07"]   = 4,
    ["male08"]   = 0,
    ["male09"]   = 3,
    ["female01"] = 1,
    ["female02"] = 3,
    ["female03"] = 3,
    ["female04"] = 2,
    ["female05"] = 2,
    ["female06"] = 4,
}

Clothes_Customize = {
    "normal",
    "casual",
    "formal",
    "young",
    "cold",
    "striped",
    "plaid",
    "none"
}

Models_Customize = {
    "male01",
    "male02",
    "male03",
    "male04",
    "male05",
    "male06",
    "male07",
    "male08",
    "male09",
    "female01",
    "female02",
    "female03",
    "female04",
    "female05",
    "female06"
}

PlayerModels = {}

function addModel(model, sex, clothes)
    local t = {}
    t.model = model
    t.sex = sex
    t.clothes = clothes
    table.insert(PlayerModels, t)
end

addModel("male01", "male", HMCD_ClothingIndices["male01"])
addModel("male02", "male", HMCD_ClothingIndices["male02"])
addModel("male03", "male", HMCD_ClothingIndices["male03"])
addModel("male04", "male", HMCD_ClothingIndices["male04"])
addModel("male05", "male", HMCD_ClothingIndices["male05"])
addModel("male06", "male", HMCD_ClothingIndices["male06"])
addModel("male07", "male", HMCD_ClothingIndices["male07"])
addModel("male08", "male", HMCD_ClothingIndices["male08"])
addModel("male09", "male", HMCD_ClothingIndices["male09"])
addModel("female01", "female", HMCD_ClothingIndices["female01"])
addModel("female02", "female", HMCD_ClothingIndices["female02"])
addModel("female03", "female", HMCD_ClothingIndices["female03"])
addModel("female04", "female", HMCD_ClothingIndices["female04"])
addModel("female05", "female", HMCD_ClothingIndices["female05"])
addModel("female06", "female", HMCD_ClothingIndices["female06"])

AccessoryList = {
    ["none"] = {},
    ["Glasses"]          = {"models/captainbigbutt/skeyler/accessories/glasses01.mdl", "ValveBiped.Bip01_Head1", {Vector(2.1, 3, 0), Angle(0, -70, -90), .9}, {Vector(2.75, 2, 0), Angle(0, -70, -90), .8}, false, 0},
    ["Sunglasses"]       = {"models/captainbigbutt/skeyler/accessories/glasses02.mdl", "ValveBiped.Bip01_Head1", {Vector(2.9, 2.2, 0), Angle(0, -70, -90), .9}, {Vector(3.5, 1.25, 0), Angle(0, -70, -90), .8}, false, 0},
    ["Big Sunglasses"]   = {"models/captainbigbutt/skeyler/accessories/glasses04.mdl", "ValveBiped.Bip01_Head1", {Vector(3.65, 2.4, 0), Angle(0, -70, -90), .9}, {Vector(3.5, 1.25, 0), Angle(0, -70, -90), .8}, false, 0},
    ["Aviators"]         = {"models/gmod_tower/aviators.mdl", "ValveBiped.Bip01_Head1", {Vector(2.2, 2.9, 0), Angle(0, -75, -90), .9}, {Vector(2.8, 1.9, 0), Angle(0, -75, -90), .85}, false, 0},
    ["Nerd Glasses"]     = {"models/gmod_tower/klienerglasses.mdl", "ValveBiped.Bip01_Head1", {Vector(2.6, 2.9, 0), Angle(0, -75, -90), 1}, {Vector(2.6, 2.3, 0), Angle(0, -80, -90), .9}, false, 0},
    ["Headphones"]       = {"models/gmod_tower/headphones.mdl", "ValveBiped.Bip01_Head1", {Vector(.5, 3, 0), Angle(0, -90, -90), .9}, {Vector(1, 2.3, 0), Angle(0, -90, -90), .8}, false, 0},
    ["Baseball Cap"]     = {"models/gmod_tower/jaseballcap.mdl", "ValveBiped.Bip01_Head1", {Vector(.05, 5.1, 0), Angle(0, -75, -90), 1.125}, {Vector(0, 4.2, 0), Angle(0, -75, -90), 1.1}, true, 0},
    ["Fedora"]           = {"models/captainbigbutt/skeyler/hats/fedora.mdl", "ValveBiped.Bip01_Head1", {Vector(.25, 5.5, 0), Angle(0, -75, -90), .7}, {Vector(0, 4.8, 0), Angle(0, -75, -90), .65}, true, 0},
    ["Cowboy Hat"]       = {"models/captainbigbutt/skeyler/hats/cowboyhat.mdl", "ValveBiped.Bip01_Head1", {Vector(.3, 6, 0), Angle(0, -70, -90), .75}, {Vector(.25, 5.6, 0), Angle(0, -75, -90), .7}, true, 0},
    ["Straw Hat"]        = {"models/captainbigbutt/skeyler/hats/strawhat.mdl", "ValveBiped.Bip01_Head1", {Vector(.75, 5, 0), Angle(0, -75, -90), .85}, {Vector(.5, 4.5, 0), Angle(0, -75, -90), .75}, true, 0},
    ["Sun Hat"]          = {"models/captainbigbutt/skeyler/hats/sunhat.mdl", "ValveBiped.Bip01_Head1", {Vector(-1.5, 3.5, 0), Angle(0, -75, -90), .8}, {Vector(-1.5, 3, 0), Angle(0, -75, -90), .75}, true, 0},
    ["Fancy Hat"]        = {"models/captainbigbutt/skeyler/hats/zhat.mdl", "ValveBiped.Bip01_Head1", {Vector(.7, 3.75, .3), Angle(0, -75, -90), .75}, {Vector(.3, 3, .25), Angle(0, -75, -90), .75}, true, 0},
    ["Top Hat"]          = {"models/player/items/player/top_hat.mdl", "ValveBiped.Bip01_Head1", {Vector(2, -1, 0), Angle(0, -80, -90), 1.025}, {Vector(2, -1, 0), Angle(0, -80, -90), .95}, true, 0},
    ["Backpack"]         = {"models/makka12/bag/jag.mdl", "ValveBiped.Bip01_Spine4", {Vector(0, -3, 0), Angle(0, 90, 90), .7}, {Vector(.5, -3, 0), Angle(0, 90, 90), .6}, false, 0},
    ["Briefcase"]        = {"models/props_c17/BriefCase001a.mdl", "ValveBiped.Bip01_Spine1", {Vector(-3, -10, 7), Angle(0, 90, 90), .6}, {Vector(-3, -10, 7), Angle(0, 90, 90), .6}, false, 0},
    ["Gray Cap"]         = {"models/modified/hat07.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4.5, .2), Angle(0, -75, -90), 1}, {Vector(0, 4.5, 0), Angle(0, -75, -90), .95}, true, 0},
    ["Light Gray Cap"]   = {"models/modified/hat07.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4.5, .2), Angle(0, -75, -90), 1}, {Vector(0, 4.5, 0), Angle(0, -75, -90), .95}, true, 2},
    ["White Cap"]        = {"models/modified/hat07.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4.5, .2), Angle(0, -75, -90), 1}, {Vector(0, 4.5, 0), Angle(0, -75, -90), .95}, true, 3},
    ["Green Cap"]        = {"models/modified/hat07.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4.5, .2), Angle(0, -75, -90), 1}, {Vector(0, 4.5, 0), Angle(0, -75, -90), .95}, true, 4},
    ["Dark Green Cap"]   = {"models/modified/hat07.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4.5, .2), Angle(0, -75, -90), 1}, {Vector(0, 4.5, 0), Angle(0, -75, -90), .95}, true, 5},
    ["Brown Cap"]        = {"models/modified/hat07.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4.5, .2), Angle(0, -75, -90), 1}, {Vector(0, 4.5, 0), Angle(0, -75, -90), .95}, true, 6},
    ["Blue Cap"]         = {"models/modified/hat07.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4.5, .2), Angle(0, -75, -90), 1}, {Vector(0, 4.5, 0), Angle(0, -75, -90), .95}, true, 7},
    ["Bandana"]          = {"models/modified/bandana.mdl", "ValveBiped.Bip01_Head1", {Vector(1.1, -1.2, 0), Angle(0, -75, -90), 1}, {Vector(1, -1.5, 0), Angle(0, -80, -90), .9}, false, 0},
    ["White Scarf"]      = {"models/sal/acc/fix/scarf01.mdl", "ValveBiped.Bip01_Spine4", {Vector(-10, -17, 0), Angle(0, 70, 90), 1}, {Vector(-9, -19.5, 0), Angle(0, 70, 90), 1}, false, 0},
    ["Gray Scarf"]       = {"models/sal/acc/fix/scarf01.mdl", "ValveBiped.Bip01_Spine4", {Vector(-10, -17, 0), Angle(0, 70, 90), 1}, {Vector(-9, -19.5, 0), Angle(0, 70, 90), 1}, false, 1},
    ["Black Scarf"]      = {"models/sal/acc/fix/scarf01.mdl", "ValveBiped.Bip01_Spine4", {Vector(-10, -17, 0), Angle(0, 70, 90), 1}, {Vector(-9, -19.5, 0), Angle(0, 70, 90), 1}, false, 2},
    ["Blue Scarf"]       = {"models/sal/acc/fix/scarf01.mdl", "ValveBiped.Bip01_Spine4", {Vector(-10, -17, 0), Angle(0, 70, 90), 1}, {Vector(-9, -19.5, 0), Angle(0, 70, 90), 1}, false, 3},
    ["Red Scarf"]        = {"models/sal/acc/fix/scarf01.mdl", "ValveBiped.Bip01_Spine4", {Vector(-10, -17, 0), Angle(0, 70, 90), 1}, {Vector(-9, -19.5, 0), Angle(0, 70, 90), 1}, false, 4},
    ["Green Scarf"]      = {"models/sal/acc/fix/scarf01.mdl", "ValveBiped.Bip01_Spine4", {Vector(-10, -17, 0), Angle(0, 70, 90), 1}, {Vector(-9, -19.5, 0), Angle(0, 70, 90), 1}, false, 5},
    ["Pink Scarf"]       = {"models/sal/acc/fix/scarf01.mdl", "ValveBiped.Bip01_Spine4", {Vector(-10, -17, 0), Angle(0, 70, 90), 1}, {Vector(-9, -19.5, 0), Angle(0, 70, 90), 1}, false, 6},
    ["Red Headphones"]   = {"models/modified/headphones.mdl", "ValveBiped.Bip01_Head1", {Vector(1, 2.5, 0), Angle(0, -90, -90), .9}, {Vector(1, 2, 0), Angle(0, -90, -90), .9}, false, 0},
    ["Pink Headphones"]  = {"models/modified/headphones.mdl", "ValveBiped.Bip01_Head1", {Vector(1, 2.5, 0), Angle(0, -90, -90), .9}, {Vector(1, 2, 0), Angle(0, -90, -90), .9}, false, 1},
    ["Green Headphones"] = {"models/modified/headphones.mdl", "ValveBiped.Bip01_Head1", {Vector(1, 2.5, 0), Angle(0, -90, -90), .9}, {Vector(1, 2, 0), Angle(0, -90, -90), .9}, false, 2},
    ["Yellow Headphones"]= {"models/modified/headphones.mdl", "ValveBiped.Bip01_Head1", {Vector(1, 2.5, 0), Angle(0, -90, -90), .9}, {Vector(1, 2, 0), Angle(0, -90, -90), .9}, false, 3},
    ["Gray Hat"]         = {"models/modified/hat01_fix.mdl", "ValveBiped.Bip01_Head1", {Vector(-.1, 4.1, 0), Angle(0, -75, -90), .9}, {Vector(-.5, 4, 0), Angle(0, -75, -90), .9}, true, 0},
    ["Black Hat"]        = {"models/modified/hat01_fix.mdl", "ValveBiped.Bip01_Head1", {Vector(-.1, 4.1, 0), Angle(0, -75, -90), .9}, {Vector(-.5, 4, 0), Angle(0, -75, -90), .9}, true, 1},
    ["White Hat"]        = {"models/modified/hat01_fix.mdl", "ValveBiped.Bip01_Head1", {Vector(-.1, 4.1, 0), Angle(0, -75, -90), .9}, {Vector(-.5, 4, 0), Angle(0, -75, -90), .9}, true, 2},
    ["Beige Hat"]        = {"models/modified/hat01_fix.mdl", "ValveBiped.Bip01_Head1", {Vector(-.1, 4.1, 0), Angle(0, -75, -90), .9}, {Vector(-.5, 4, 0), Angle(0, -75, -90), .9}, true, 3},
    ["Burgundy Hat"]     = {"models/modified/hat01_fix.mdl", "ValveBiped.Bip01_Head1", {Vector(-.1, 4.1, 0), Angle(0, -75, -90), .9}, {Vector(-.5, 4, 0), Angle(0, -75, -90), .9}, true, 5},
    ["Blue Hat"]         = {"models/modified/hat01_fix.mdl", "ValveBiped.Bip01_Head1", {Vector(-.1, 4.1, 0), Angle(0, -75, -90), .9}, {Vector(-.5, 4, 0), Angle(0, -75, -90), .9}, true, 7},
    ["Striped Beanie"]   = {"models/modified/hat03.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4, 0), Angle(0, -75, -90), 1}, {Vector(-.2, 3.5, 0), Angle(0, -75, -90), 1}, true, 0},
    ["Blue Beanie"]      = {"models/modified/hat03.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4, 0), Angle(0, -75, -90), 1}, {Vector(-.2, 3.5, 0), Angle(0, -75, -90), 1}, true, 1},
    ["Purple Beanie"]    = {"models/modified/hat03.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4, 0), Angle(0, -75, -90), 1}, {Vector(-.2, 3.5, 0), Angle(0, -75, -90), 1}, true, 2},
    ["White Beanie"]     = {"models/modified/hat03.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4, 0), Angle(0, -75, -90), 1}, {Vector(-.2, 3.5, 0), Angle(0, -75, -90), 1}, true, 3},
    ["Gray Beanie"]      = {"models/modified/hat03.mdl", "ValveBiped.Bip01_Head1", {Vector(.1, 4, 0), Angle(0, -75, -90), 1}, {Vector(-.2, 3.5, 0), Angle(0, -75, -90), 1}, true, 4},
    ["Big Red Backpack"] = {"models/modified/backpack_1.mdl", "ValveBiped.Bip01_Spine4", {Vector(-2, -8, 0), Angle(0, 90, 90), 1}, {Vector(-2, -8, 0), Angle(0, 90, 90), .9}, false, 0},
    ["Big Gray Backpack"]= {"models/modified/backpack_1.mdl", "ValveBiped.Bip01_Spine4", {Vector(-2, -8, 0), Angle(0, 90, 90), 1}, {Vector(-2, -8, 0), Angle(0, 90, 90), .9}, false, 1},
    ["Normal Backpack"]  = {"models/modified/backpack_3.mdl", "ValveBiped.Bip01_Spine4", {Vector(-3, -6, 0), Angle(0, 90, 90), .9}, {Vector(-3, -6, 0), Angle(0, 90, 90), .8}, false, 0},
    ["Gray Backpack"]    = {"models/modified/backpack_3.mdl", "ValveBiped.Bip01_Spine4", {Vector(-3, -6, 0), Angle(0, 90, 90), .9}, {Vector(-3, -6, 0), Angle(0, 90, 90), .8}, false, 1}
}

AccessoryListWithoutEmpty = {}

for k, v in pairs(AccessoryList) do
    if k ~= "none" then
        AccessoryListWithoutEmpty[k] = v
    end
end

if CLIENT then

    local function RenderAccessoryOnEnt(ent, accName, sex, blend)
        if not IsValid(ent) or not accName or accName == "" or accName == "none" or not AccessoryList or not AccessoryList[accName] then
            if IsValid(ent.AccessoryModel) then
                ent.AccessoryModel:Remove()
                ent.AccessoryModel = nil
            end
            return
        end

        local accInfo = AccessoryList[accName]
        if not accInfo or not accInfo[1] then return end

        local modelPath = accInfo[1]
        local boneName = accInfo[2]
        local posInfo = (sex == "male") and accInfo[3] or accInfo[4]
        local skin = accInfo[6] or 0

        if not posInfo then return end

        if not IsValid(ent.AccessoryModel) or ent.AccessoryModel:GetModel() ~= modelPath then
            if IsValid(ent.AccessoryModel) then ent.AccessoryModel:Remove() end
            ent.AccessoryModel = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
            if IsValid(ent.AccessoryModel) then
                ent.AccessoryModel:SetNoDraw(true)
            end
        end

        local acc = ent.AccessoryModel
        if not IsValid(acc) then return end

        acc:SetSkin(skin)

        local boneID = ent:LookupBone(boneName)
        if not boneID then return end

        local pos, ang
        local matrix = ent:GetBoneMatrix(boneID)
        if matrix then
            pos = matrix:GetTranslation()
            ang = matrix:GetAngles()
        else
            pos, ang = ent:GetBonePosition(boneID)
        end

        if not pos or not ang then return end

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

        if blend and blend < 255 then
            local R, G, B = render.GetColorModulation()
            render.SetColorModulation(1, 1, 1)
            render.SetBlend(blend)
            acc:DrawModel()
            render.SetBlend(255)
            render.SetColorModulation(R, G, B)
        else
            acc:DrawModel()
        end
    end

    hook.Add("PostPlayerDraw", "HMCD_RenderAccessoriesWorld", function(ply)
        if not IsValid(ply) or not ply:Alive() or ply:GetNoDraw() then return end
        local accName = ply.Accessory or ply:GetNWString("Accessory", "none")
        local sex = ply.ModelSex or ply:GetNWString("ModelSex", "male")
        if sex ~= "male" and sex ~= "female" then sex = "male" end
        RenderAccessoryOnEnt(ply, accName, sex)
    end)

    hook.Add("PostDrawOpaqueRenderables", "HMCD_RenderAccessoriesRagdolls", function(bDepth, bSkybox)
        if bSkybox then return end

        for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
            if not IsValid(rag) or rag:GetNoDraw() then continue end

            local owner = rag:GetNWEntity("RagdollOwner")
            if not IsValid(owner) then owner = rag:GetNWEntity("RagdollController") end
            if not IsValid(owner) then owner = rag:GetNWEntity("player") end
            if not IsValid(owner) then owner = rag:GetNWEntity("Ragdoll") end
            if not IsValid(owner) or not owner:IsPlayer() then
                for _, pl in ipairs(player.GetAll()) do
                    if pl:GetNWEntity("Ragdoll") == rag then
                        owner = pl
                        break
                    end
                end
            end

            local accName = rag:GetNWString("Accessory", "")
            if (not accName or accName == "" or accName == "none") and IsValid(owner) then
                accName = owner.Accessory or owner:GetNWString("Accessory", "")
            end

            local sex = rag.ModelSex or (IsValid(owner) and owner.ModelSex) or "male"
            if sex ~= "male" and sex ~= "female" then sex = rag:GetNWString("ModelSex", (IsValid(owner) and owner:GetNWString("ModelSex", "")) or "") end
            if sex ~= "male" and sex ~= "female" then sex = "male" end

            local blend = 255
            if IsValid(owner) and owner:IsPlayer() and owner:Alive() then
                if owner:GetNWBool("fake") and owner:GetViewEntity() == owner then
                    blend = 0.1
                end
            end

            RenderAccessoryOnEnt(rag, accName, sex, blend)
        end
    end)

    hook.Add("EntityRemoved", "HMCD_CleanupAccessoryModel", function(ent)
        if IsValid(ent) and IsValid(ent.AccessoryModel) then
            ent.AccessoryModel:Remove()
            ent.AccessoryModel = nil
        end
    end)
end
