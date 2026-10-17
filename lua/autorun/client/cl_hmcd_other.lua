-- auto generated Client part for hmcd_shared
if CLIENT then
    local flashlights = {}
    local models = {}

    local function RemoveFlashlight(ply)
        if IsValid(flashlights[ply]) then
            flashlights[ply]:Remove()
            flashlights[ply] = nil
        end
        if IsValid(models[ply]) then
            models[ply]:Remove()
            models[ply] = nil
        end
    end

    hook.Add("Think", "HMCD_DynamicFlashlightUpdate", function()
        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) or not ply:Alive() or not ply:GetNWBool("DynamicFlashlight") or ply:GetNWBool("fake") then
                RemoveFlashlight(ply)
                continue
            end

            local pos, ang

            local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
            if bone then
                local matrix = ply:GetBoneMatrix(bone)
                if matrix then
                    pos = matrix:GetTranslation()
                else
                    pos = ply:GetBonePosition(bone)
                end
            else
                pos = ply:EyePos()
            end
            ang = ply:EyeAngles()

            if not pos or not ang then continue end

            ply.SwayFlashlightAng = ply.SwayFlashlightAng or ang
            ply.SwayFlashlightAng = LerpAngle(math.Clamp(FrameTime() * 12, 0, 1), ply.SwayFlashlightAng, ang)

            local moveVel = ply:GetVelocity():LengthSqr()
            local walkSwayP, walkSwayY = 0, 0
            if moveVel > 1000 and ply:IsOnGround() then
                local speedMul = math.Clamp(math.sqrt(moveVel) / 200, 0.5, 2.0)
                walkSwayP = math.sin(CurTime() * 10) * 0.8 * speedMul
                walkSwayY = math.cos(CurTime() * 8) * 0.6 * speedMul
            end

            local finalAng = ply.SwayFlashlightAng + Angle(walkSwayP, walkSwayY, 0)

            if not IsValid(models[ply]) then
                models[ply] = ClientsideModel("models/maxofs2d/lamp_flashlight.mdl")
                if IsValid(models[ply]) then
                    models[ply]:SetNoDraw(false)
                    models[ply]:SetModelScale(0.5)
                end
            end

            local mdl = models[ply]
            if IsValid(mdl) then
                if ply:GetActiveWeapon() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "wep_jack_hmcd_hands" and ply:GetActiveWeapon():GetClass() ~= "wep_jack_hmcd_brassknuckles" then
                    mdl:SetModelScale(0)
                else
                    mdl:SetModelScale(0.5)
                end

                mdl:SetPos(pos + finalAng:Forward() * 9 + finalAng:Right() * -2 + finalAng:Up() * 0)
                mdl:SetAngles(finalAng)
                mdl:DrawModel()
            end

            if not IsValid(flashlights[ply]) then
                local lamp = ProjectedTexture()
                lamp:SetTexture("effects/flashlight001")
                lamp:SetFarZ(1250)
                lamp:SetFOV(60)
                lamp:SetBrightness(2.5)
                lamp:SetEnableShadows(true)
                flashlights[ply] = lamp
            end

            local light = flashlights[ply]
            if IsValid(light) then
                light:SetPos(pos + finalAng:Forward() * 14 + finalAng:Right() * -3)
                light:SetAngles(finalAng)
                light:Update()
            end
        end
    end)

    local LightSprite = Material("sprites/glow04_noz")

    hook.Add("PostDrawTranslucentRenderables", "HMCD_FlashlightGlow", function(bDepth, bSkybox)
        if bSkybox then return end
        local client = LocalPlayer()
        local eyePos = EyePos()

        for ply, mdl in pairs(models) do
            if IsValid(mdl) and IsValid(ply) and ply ~= client then
                local lightPos = mdl:GetPos() + mdl:GetAngles():Forward() * 5
                local lightDir = mdl:GetAngles():Forward()
                local viewDir = (lightPos - eyePos):GetNormalized()
                local dot = viewDir:Dot(lightDir * -1)

                if dot > 0 then
                    local tr = util.TraceLine({
                        start = eyePos,
                        endpos = lightPos,
                        filter = {client, mdl, ply, ply:GetNWEntity("DeathRagdoll")},
                        mask = MASK_SHOT
                    })
                    if not tr.Hit then
                        local size = 128 * dot
                        local alpha = 255 * dot
                        render.SetMaterial(LightSprite)
                        render.DrawSprite(lightPos, size, size, Color(255, 255, 255, alpha))
                        render.DrawSprite(lightPos, size * 0.3, size * 0.3, Color(255, 255, 255, alpha))
                    end
                end
            end
        end
    end)

    hook.Add("EntityRemoved", "HMCD_FlashlightCleanupEntity", function(ent)
        RemoveFlashlight(ent)
    end)

    hook.Add("PlayerDeath", "HMCD_FlashlightCleanupDeath", function(ply)
        RemoveFlashlight(ply)
    end)
end

