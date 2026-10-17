util.AddNetworkString("hmcd_notification_net")
local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

hook.Add("PlayerDeathSound", "DeFlatline", function() 
    return true 
end)

local noise = Sound("death.wav")

hook.Add("PlayerDeath", "NewSound", function(vic, unused1, unused2) 
    if IsValid(vic) then
        vic:EmitSound(noise) 
    end
end)

function PlayerMeta:GetSex()
	return self.ModelSex or "nonbinary" //LGBTQ+ PRIDE MOTNH
end

function PlayerMeta:GetFat()
    return self.Fat or 64
end

function PlayerMeta:SetFat(int)
    self.Fat = int
    self:SetNWInt("org_fat", int)
end

function PlayerMeta:Notify(str, shaking, col, thoughts, speed)
    net.Start("hmcd_notification_net")
        net.WriteString(str or "")
        net.WriteBool(shaking or false)
        net.WriteColor(col or color_white)
        net.WriteBool(thoughts or false)
        net.WriteFloat(speed or 0.04)
    net.Send(self)
end

local bandageMap = {
    "bandhead",
    "bandchest",
    "bandstomach",
    "bandgroin",
    "bandleft_leg",
    "bandright_leg",
    "bandleft_hand",
    "bandright_hand",
}

hook.Add("Vars Player", "fat", function(ply) 
    for _, v in ipairs(bandageMap) do
        ply:SetNWBool(v, false)
    end
    ply.stamina = {
        ["int"] = 100,
        ["lleg"] = 1, //MINIMUM 0.5 !!
        ["rleg"] = 1 //MINIMUM 0.5 !!
    }
    ply.JumpCount = 0
    ply.LastJumpTime = 0
    ply.blinded = 100
    ply:SetNWFloat("blinded",100)
	ply.headhp = 100
    timer.Simple(0.25,function() //name give end
        if ply:GetNWString("Character_Name") == "Buyanov" then ply:SetFat(200) 
        else 
            ply:SetFat(math.random(45,90)) //more than 100 is actually too much.
        end
    end)
    ply:SetAllowWeaponsInVehicle( true )
    ply.hmcd:SetBoneAngles("r_hand", Angle(0, -0, -0), 0.4, 10.0, "smooth")
    ply.hmcd:SetBoneAngles("r_forearm", Angle(-0, -0, 0), 0.4, 10.0, "smooth")
	ply.hmcd:SetBoneAngles("r_upperarm", Angle(0, -0, 0), 0.4, 10.0, "smooth")
    ply.hmcd:SetBoneAngles("l_upperarm", Angle(-0, 0, -0), 0.8, 10.0, "smooth")   
end)

//meta end

hook.Add("KeyPress", "hk_antipidoras suka VERNIS TI NE UPRIGAESH U SUKA ", function(ply, key)
    if key == IN_JUMP and ply:IsOnGround() and ply:GetMoveType() == MOVETYPE_WALK then
        if not ply.stamina then return end
        
        ply.JumpCount = (ply.JumpCount or 0) + 1
        ply.LastJumpTime = CurTime()
        
        local fat = ply:GetFat()
        local jumpCost = (1.1 + (fat * 0.004)) * (1 + (ply.JumpCount * 0.6))
        
        ply.stamina['int'] = math.Clamp(ply.stamina['int'] - jumpCost, 0, 100)
        ply:SetNWInt("stamina", ply.stamina['int'])

        ply.pulse = (ply.pulse or 70) + 2
        ply.exhausted = math.Clamp((ply.exhausted or 0), 0, 10)
    end
    
end)
hook.Add("Player Think", "hk_Stamina", function(ply) 
    if not ply.stamina or not ply:Alive() then return end

    ply.pulse = ply.pulse or 70
    ply.exhausted = ply.exhausted or 0
    
    local fat = ply:GetFat()
    local legs = ply.stamina['lleg'] * ply.stamina['rleg']
    local curStamina = ply.stamina['int'] or 0
    local curTime = CurTime()

    ply:SetNWFloat("blinded",ply.blinded)

    ply.pulse = ply.pulse
    ply.exhausted = ply.exhausted
    
    if (ply.LastJumpTime or 0) + 2 < curTime then
        ply.JumpCount = 0
    end

    local baseWalk = math.max(10, 200 * legs - (fat * 1.1))
    local baseRun = math.max(10, 430 * legs - (fat * 1.95))
    local baseSlow = math.max(10, 100 * legs - (fat * 0.8))
    local baseCrouch = math.max(1, 1 * legs - (fat * 0.8))

    if curStamina < 40 then
        local staminaRatio = math.Clamp(curStamina / 40, 0, 1)
        baseRun = Lerp(staminaRatio, 150, baseRun)
        if baseWalk > baseRun then baseWalk = baseRun end
    end

    local pain = ply.pain or 0
    local adren = ply.adrenaline or 0
    local painMul = 1 - math.Clamp(pain / 100, 0, 0.75)
    local adrenMul = 1 + math.Clamp(adren / 40, 0, 0.35)
    local moveMul = painMul * adrenMul

    baseWalk = math.max(10, baseWalk * moveMul)
    baseRun = math.max(10, baseRun * moveMul)
    baseSlow = math.max(10, baseSlow * moveMul)
    baseCrouch = math.max(10, baseCrouch * moveMul)

    local strafeDir = 0
    if ply:KeyDown(IN_MOVELEFT) then strafeDir = strafeDir - 1 end
    if ply:KeyDown(IN_MOVERIGHT) then strafeDir = strafeDir + 1 end
    if ply:KeyDown(IN_MOVELEFT) and ply:KeyDown(IN_MOVERIGHT) then strafeDir = 0 end

    ply.lastStrafeDir = ply.lastStrafeDir or 0
    ply.lastStrafeTime = ply.lastStrafeTime or 0
    ply.strafePenalty = ply.strafePenalty or 0
    ply.strafeInertia = ply.strafeInertia or 1

    if strafeDir ~= 0 and strafeDir ~= ply.lastStrafeDir and ply.lastStrafeDir ~= 0 then
        local dt = curTime - ply.lastStrafeTime
        if dt < 0.45 and ply:IsOnGround() then
            ply.strafePenalty = math.min(1, ply.strafePenalty + 10.35)
        end
    end
    if strafeDir ~= 0 then
        ply.lastStrafeDir = strafeDir
        ply.lastStrafeTime = curTime
    end

    if ply.strafePenalty > 0 then
        ply.strafePenalty = math.max(0, ply.strafePenalty - FrameTime() * 0.65)
    end
    local strafeMul = 1 - ply.strafePenalty * 0.35
    ply.strafeInertia = Lerp(FrameTime() * 1.5, ply.strafeInertia, strafeMul)

    baseWalk = baseWalk * ply.strafeInertia
    baseRun = baseRun * ply.strafeInertia
    baseSlow = baseSlow * ply.strafeInertia
    baseCrouch = baseCrouch * ply.strafeInertia

    ply:SetWalkSpeed(baseWalk)
    ply:SetRunSpeed(baseRun)
    ply:SetSlowWalkSpeed(baseSlow)
    ply:SetCrouchedWalkSpeed(0.5)//baseCrouch)

    local bhopDecay = math.Clamp(1 - ((ply.JumpCount or 0) * 0.05), 0.1, 5)
    local staminaJump = math.Clamp(curStamina / 50, 0.2, 1)
    ply:SetJumpPower(math.max(10, (189 *legs - (fat*0.2)) *bhopDecay* staminaJump *moveMul * ply.strafeInertia))
    ply:SetDuckSpeed(0.3 + (fat * 0.005))

    local boneIndex = ply:LookupBone("ValveBiped.Bip01_Pelvis")
    if boneIndex then
        /*local belly = 1 + (fat * 0.0025)
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Neck1"), Vector(belly, belly, belly))
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Pelvis"), Vector(belly, belly, belly))
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Spine"), Vector(belly, belly, belly))
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Vector(belly, belly, belly))
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Vector(belly, belly, belly))
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Hand"), Vector(belly, belly, belly))
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Hand"), Vector(belly, belly, belly))
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_L_Calf"), Vector(belly / 1.1, belly / 1.1, belly / 1.1))
        ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_R_Calf"), Vector(belly / 1.1, belly / 1.1, belly / 1.1))  */     
    end

    local minus = (1 * legs) + (fat * 0.0005)
    local rag = ply:GetNWEntity("Ragdoll")
    local isHolding = IsValid(rag) and (IsValid(rag.ZacConsLH) or IsValid(rag.ZacConsRH))
    local isMoving = ply:GetVelocity():LengthSqr() > 1000
    local isSprinting = ply:GetMoveType() == MOVETYPE_WALK and ply:IsSprinting() and ply:IsOnGround() and isMoving

    local isWelded = IsValid(rag) and (IsValid(rag.ZacConsLH) or IsValid(rag.ZacConsRH))
    local isHanging = false

    if isWelded then
        local phys = rag:GetPhysicsObjectNum(0)
        if IsValid(phys) then
            local tr = util.TraceLine({
                start = phys:GetPos(),
                endpos = phys:GetPos() - Vector(0, 0, 50),
                filter = rag
            })
            if not tr.Hit or tr.Fraction > 0.85 then
                isHanging = true
            end
        end
    end

    if isSprinting then
        ply.stamina['int'] = math.Clamp(ply.stamina['int'] - (minus * FrameTime() * 5), 0, 100)
        ply.pulse = math.Approach(ply.pulse, 220, FrameTime() * 3)
        ply.exhausted = math.Approach(ply.exhausted, 10, FrameTime() * 0.4)
    elseif isHanging then
        local cost = 3 * FrameTime() 
        ply.stamina['int'] = math.max(0, ply.stamina['int'] - cost)
        ply.pulse = math.Approach(ply.pulse, 180, FrameTime() * 3)
        ply.exhausted = math.Approach(ply.exhausted, 8, FrameTime() * 0.4)

        if ply.stamina['int'] <= 15 and not ply.staminaWarned then
            if ply.Notify then
                ply:Notify("I can't hold any longer..", true, Color(230, 10, 10), false, 0.09)
            end
            ply.staminaWarned = true
        end

        if ply.stamina['int'] <= 0 then
            rag.ZacNextGrLH = curTime + 3
            rag.ZacNextGrRH = curTime + 3
            if IsValid(rag.ZacConsLH) then rag.ZacConsLH:Remove() rag.ZacConsLH = nil end
            if IsValid(rag.ZacConsRH) then rag.ZacConsRH:Remove() rag.ZacConsRH = nil end
            rag:EmitSound("physics/body/body_medium_impact_soft"..math.random(1,7)..".wav")
            SetFingers(rag, "left", "release")
            SetFingers(rag, "right", "release")
        end
    else
        ply.stamina['int'] = math.Clamp(ply.stamina['int'] + (minus * FrameTime() * 10), 0, 100)
        
        local targetPulse = 70 + (100 - curStamina) * 0.4

        if pain > 10 and ply.pulse < 130 then
            targetPulse = targetPulse + (pain - 1) * 0.5
        end

        ply.pulse = math.Approach(ply.pulse, targetPulse, FrameTime() * 4)
        

        
        local targetExh = math.Clamp((100 - curStamina) / 10, 0, 10)
        ply.exhausted = math.Approach(ply.exhausted, targetExh, FrameTime() * 0.8)

        if curStamina > 15 then ply.staminaWarned = false end
    end

    ply:SetNWInt("stamina", math.Round(ply.stamina['int']))
    ply:SetNWInt("pulse", math.Round(ply.pulse))
    ply:SetNWInt("exhausted", math.Round(ply.exhausted))
    if ply.pulse > 100 then
        ply.nextHB = ply.nextHB or 0
        if curTime > ply.nextHB then
            local intensity = math.Clamp((ply.pulse - 90) / 120, 0, 1)
            local vol = Lerp(intensity, 0.05, 1.2)
            local pitch = Lerp(intensity, 100, 135)

            ply:SendLua(string.format("LocalPlayer():EmitSound('heartbeat/heartbeat_single.wav', 1000000, %d, %f, CHAN_AUTO)", pitch, vol))

            ply.nextHB = curTime + (60 / ply.pulse)
        end
    end

    local speed = ply:GetVelocity():LengthSqr()
    if ply.exhausted > 1.5 and speed < 10000 and not isSprinting and not ply.Otrub then
        ply.nextBreath = ply.nextBreath or 0
        if curTime > ply.nextBreath then
            local sex = ply:GetSex()
            if sex == "nonbinary" then sex = "male" end
            
            ply.breathState = (ply.breathState or 0) + 1
            if ply.breathState > 2 then ply.breathState = 1 end
            
            local snd = ""
            local breathDelay = math.Remap(ply.exhausted, 1.5, 10, 1.6, 0.7)
            
            if ply.breathState == 1 then
                snd = "breathing/inhale/"..sex.."/inhale_0"..math.random(1, 5)..".wav"
            else
                local maxEx = (sex == "male") and 4 or 5
                snd = "breathing/exhale/"..sex.."/exhale_0"..math.random(1, maxEx)..".wav"
            end
            
            local bVol = math.Clamp(ply.exhausted / 10, 0.1, 0.9)
            ply:EmitSound(snd, 60, 100, bVol, CHAN_AUTO)
            ply.nextBreath = curTime + breathDelay
        end
    else
        ply.breathState = 0
    end
/*
	ply.Wounds = {
		["right_hand"] = 0,
		["left_hand"] = 0,

		["left_leg"] = 0,
		["right_leg"] = 0,

		["stomach"] = 0,
		["chest"] = 0
	}
*/

    if ply.BleedOuts then
        local totalBleeding = 0

        for _, bleed in pairs(ply.BleedOuts) do
            if bleed > 0 then
                totalBleeding = totalBleeding + bleed
            end
        end

        if totalBleeding > 0 then
            ply.NextBleedPain = ply.NextBleedPain or 0

            if ply.NextBleedPain < CurTime() then
                local painAdd = math.Clamp(totalBleeding / 50, 0.1, 3)

                ply.pain = (ply.pain or 0) + painAdd

                ply.NextBleedPain = CurTime() + 0.1
            end
        end
    end

    local killyourself1 = {
        "FUUUUCCCKKK!!",
        "AAAAAAGGGHHH!!",
        "FUCK! FUCK! FUCK!",
        "HHRRRNNGGHH...",
        "SHIT... AAAAARGH!!",
        "ARRRGGGHHH!!",
        "GAAAAHH!!",
        "HURRRRGGGNN...",
        "UUGGGHHH... FUCK...",
        "G-GAAAHHH... NO!",
        
        "JUST KILL ME... FUCK...",
        "I CAN'T FUCKING TAKE THIS ANYMORE!",
        "END THIS... PLEASE END THIS...",
        "I WANT TO FUCKING DIE!",
        "PUT A BULLET IN MY HEAD...",
        "SOMEONE... JUST FINISH ME...",
        "I'D RATHER BE DEAD RIGHT NOW",
        "FUCKING END ME ALREADY!",
        "JUST LET ME DIE... PLEASE...",
        "BLOW MY FUCKING MIND PLEASE",
        
        "EVERYTHING IS BURNING... FUCK!",
        "IT FEELS LIKE I'M ON FIRE!",
        "MY BONES... THEY'RE CRUSHED...",
        "EVERYTHING IS TURNING BLACK... FUCK...",
        "I CAN'T FEEL MY BODY... GAH!",
        "SHIT, IT'S TEARING ME APART!",
        "I'M FALLING APART... SHIT!",
        "I CAN'T BREATHE... ARGH!",
        
        "FUCKING... AAAA!",
        "FUCK... STOP IT... AAAA!",
        "S-SHIT... AAAAGH!",
        "GAAAAHH!! IT'S TOO MUCH...",
        "WHY... FUCK... WHY...",
        "I'M GOING TO VOMIT... FUCK...",
        "DAMN IT! DAMN IT ALL!!",
        "NO... NOT LIKE THIS... FUCK!"
    }

    ply.lastPainValue = ply.lastPainValue or 0
    ply.nextPainNotify = ply.nextPainNotify or 0
    ply.nextPainNotify2 = ply.nextPainNotify2 or 0    

    if pain >= 150 and pain > ply.lastPainValue and !ply.Otrub then
        if CurTime() > ply.nextPainNotify then
            local phrase = table.Random(killyourself1)
            ply:Notify(phrase, true, Color(200, 0, 0), false, 0.1)
            
            ply.nextPainNotify = CurTime() + math.random(4, 7)
        end
    end

    if pain >= 250 and pain > ply.lastPainValue and !ply.Otrub and !ply.fake then
        if CurTime() > ply.nextPainNotify2 then
            Faking(ply)
            ply.nextPainNotify2 = CurTime() + 5
        end
    end

    ply.lastPainValue = pain

    if isHolding then
        local phys = rag:GetPhysicsObjectNum(0)
        if IsValid(phys) then
            local tr = util.TraceLine({
                start = phys:GetPos(),
                endpos = phys:GetPos() - Vector(0, 0, 50),
                filter = rag
            })

            if not tr.Hit or tr.Fraction > 0.85 then
                local cost = 3 * FrameTime() 
                ply.stamina['int'] = math.max(0, ply.stamina['int'] - cost)

                if ply.stamina['int'] <= 15 and not ply.staminaWarned then
                    if ply.Notify then
                        ply:Notify("I can't hold any longer..", true, Color(230, 10, 10), false, 0.09)
                    end
                    ply.staminaWarned = true
                end

                if ply.stamina['int'] <= 0 then
                    rag.ZacNextGrLH = curTime + 3
                    rag.ZacNextGrRH = curTime + 3
                    if IsValid(rag.ZacConsLH) then rag.ZacConsLH:Remove() rag.ZacConsLH = nil end
                    if IsValid(rag.ZacConsRH) then rag.ZacConsRH:Remove() rag.ZacConsRH = nil end
                    rag:EmitSound("physics/body/body_medium_impact_soft"..math.random(1,7)..".wav")
                end
            end
        end
    else
        if (ply.stamina['int'] or 0) > 15 then
            ply.staminaWarned = false
        end
    end

    if ply:IsOnFire() then
        local burnAmount = 50 * FrameTime()
        local currentFat = ply:GetFat()
        ply:SetFat(math.max(10, currentFat - burnAmount))
        if math.random(1,100) == 6 then
            local tr = util.TraceLine({
                start = ply:GetPos() + Vector(math.Random(-2,2), math.Random(-2,2), math.Random(8,12)),
                endpos = ply:GetPos() - Vector(0, 0, 50),
                filter = ply
            })
            if tr.Hit then util.Decal("BeerSplash", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal, ply) end
        end
    end

    if ply.blinded < 100 then
        ply.blinded = Lerp(1 - math.exp(-0.05 * FrameTime()), ply.blinded, 100)
        if ply.blinded > 99.9 then ply.blinded = 100 end
    end


    ply:SetNWBool("ane_ra", ply.ane_ra)
    ply:SetNWBool("ane_rl", ply.ane_rl)
    ply:SetNWBool("ane_la", ply.ane_la)
    ply:SetNWBool("ane_ll", ply.ane_ll)
    ply:SetNWBool("otrub", ply.Otrub)
    ply:SetBloodColor(DONT_BLEED)

end)




hook.Add("HOOK_UNION_Damage", "FATPUZO", function(ply, hitgroup, dmginfo, rag)
    if not IsValid(ply) then return end
    ply.pain = ply.pain + (dmginfo:GetDamage() / 1.2)
    print(ply.pain)
    local fat = ply:GetFat()
    if fat <= 100 then return end

    /*if hitgroup == HITGROUP_STOMACH or hitgroup == HITGROUP_CHEST then
        local mul = math.Clamp(1.0 - (fat * 0.005), 0.2, 1.0)
        //print("do sreza"..dmginfo)
        //dmginfo:ScaleDamage(mul)
        //print("posle sreza"..dmginfo)
    end*/
end)

function Pulse(ply)
    local basePulse = 70
    local bloodFactor = ply.Blood / 4000
    local adrenalineFactor = ply.adrenaline
    local painFactor = 1 + (ply.pain / 1000)

    pulse = basePulse * bloodFactor * painFactor + adrenalineFactor
	return pulse
end

hook.Add("Player Think","HeartWork",function(ply,time)
	if not ply:Alive() or ply:HasGodMode() then return end
	//ply.pulse = Pulse(ply)
	local ent = IsValid(ply.fakeragdoll) and ply.fakeragdoll or ply
    
    ply.ArteryThink = ply.ArteryThink or 0
	if ply.ArteryThink < CurTime() then
	
		ply.ArteryThink = CurTime() + 0.6
		if ply.Hit["rl_artery"] or ply.Hit["ll_artery"] then
			ply.Blood = ply.Blood - 15
			sound.Play(table.Random(blood_drop), ent:GetPos(), 55, 100,1)
			BloodParticle(ply)
		end

		if ply.Hit["rh_artery"] or ply.Hit["lh_artery"] then
			ply.Blood = ply.Blood - 10
			sound.Play(table.Random(blood_drop), ent:GetPos(), 55, 100,1)
			BloodParticle(ply)
		end

		if ply.Hit["neck_artery"] then
			ply.Blood = ply.Blood - 30
			sound.Play(table.Random(blood_drop), ent:GetPos(), 55, 100,1)
			BloodParticle(ply)
		end

	end
end)

local hook_run = hook.Run

OrgansNextThink = 0
LungNextThink = 0
hook.Add("Player Think","Organs_Hit_Reactions",function(ply,time)
	ply.OrgansNextThink = ply.OrgansNextThink or OrgansNextThink
	ply.LungNextThink = ply.LungNextThink or LungNextThink
	if ply.o2 < 0 then
		ply:ChatPrint("You died because of a small amount of oxygen.")
		ply:Kill()
		ply.o2 = 1
	end

	if ply.Blood <= 1000 and ply:Alive() then
		ply:ChatPrint("You died due to a lot of blood loss.")
		ply:Kill()
	end
	
	if ply.pain >= 900 and ply:Alive() then
		ply:ChatPrint("You died due to pain shock.")
		ply:Kill()
	end

	if ply.overdose >= 10 and ply:Alive() then
		ply:ChatPrint("You died due to an overdose.")
		ply:Kill()
	end
	
	if not ( ply.OrgansNextThink > CurTime() ) and ply:Alive() then
		ply.OrgansNextThink = CurTime() + 0.2

		if ply.Hit["intestines"] == true then
			ply.cant_eat = true
		end

		if ply.Hit["heart"] == true then
			ply.heartstop = true
		end

    end

	if not ( ply.LungNextThink > CurTime() ) and ply:Alive() then
		ply.LungNextThink = CurTime() + 1

		if ply.Hit["lungs"] == true then
			ply.o2 = ply.o2 - math.Rand(0.1, 0.4)
		end

		if !ply:GetNWBool("Breath", true) then
			ply.o2 = ply.o2 - math.Rand(0.1, 0.3)
		end

		if ply:GetNWBool("Breath", true) then
			ply.o2 = ply.o2 + math.Rand(0.08, 0.3)
		end
		
    end
end)


timer.Create("Headcrab",2,0,function()
    for _, ply in player.Iterator() do
        hook_run("Headcrab", ply)
    end

end)

timer.Create("PulseWork",0.9,0,function()
    for _, ply in player.Iterator() do
        hook_run("Bleeding", ply)
    end

end)

hook.Add("Bleeding", "BleedWorkPulse", function(ply)
	if not ply:Alive() then return end
	local ent = IsValid(ply.fakeragdoll) and ply.fakeragdoll or ply

	if ply.BleedOuts["right_hand"] > 0 then
		Bleed(ply, 0.1, "right_hand", ent)
	end

	if ply.BleedOuts["left_hand"] > 0 then
		Bleed(ply, 0.1, "left_hand", ent)
	end

	if ply.BleedOuts["left_leg"] > 0 then
		Bleed(ply, 0.1, "left_leg", ent)
	end

	if ply.BleedOuts["right_leg"] > 0 then
		Bleed(ply, 0.1, "right_leg", ent)
	end

	if ply.BleedOuts["right_leg"] > 0 then
		Bleed(ply, 0.1, "right_leg", ent)
	end

	if ply.BleedOuts["stomach"] > 0 then
		Bleed(ply, 0.1, "stomach", ent)
	end

	if ply.BleedOuts["chest"] > 0 then
		Bleed(ply, 0.1, "chest", ent)
	end
end)

local BleedBoneMap = {
    ["right_hand"] = "ValveBiped.Bip01_R_Hand",
    ["left_hand"]  = "ValveBiped.Bip01_L_Hand",
    ["right_arm"]  = "ValveBiped.Bip01_R_Forearm",
    ["left_arm"]   = "ValveBiped.Bip01_L_Forearm",
    ["right_leg"]  = "ValveBiped.Bip01_R_Thigh",
    ["left_leg"]   = "ValveBiped.Bip01_L_Thigh",
    ["stomach"]    = "ValveBiped.Bip01_Spine1",
    ["chest"]      = "ValveBiped.Bip01_Spine2",
    ["head"]       = "ValveBiped.Bip01_Head1",
    ["neck"]       = "ValveBiped.Bip01_Neck1",
}


local BLEEDING_NextThink1 = 0
hook.Add("Think","BleedingBodies",function()
	for i, ent in pairs(BleedingEntities) do
		if not ent.IsBleeding then return end
		ent.BLEEDING_NextThink1 = ent.BLEEDING_NextThink1 or BLEEDING_NextThink1
		if ent.BLEEDING_NextThink1 < CurTime() then
			ent.BLEEDING_NextThink1 = CurTime() + math.random(0.6, 0.8)
			local rn = math.Rand(-0.35, 0.35)
			local rnn = math.Rand(-0.35, 0.35)
			local tr = {}
			tr.start = Vector(ent:GetPos(0, 0, 50)) + Vector(0, 0, 50)
			tr.endpos = tr.start + Vector(rn, rnn, -1) * 8000
			tr.filter = ent
			local trw = util.TraceHull(tr)
			local Pos1 = trw.HitPos + trw.HitNormal
			local Pos2 = trw.HitPos - trw.HitNormal
			if IsValid(ent) and blood_drop then
				ent:EmitSound(table.Random(blood_drop), 60, math.random(230, 240), 0.2, CHAN_AUTO)
			end
			BloodParticle(ent)
		end
	end
end)


local CTime = CurTime
hook.Add("Player Think", "AdrenalineWork", function(ply)
	ply.adrenaline_unone = ply.adrenaline_unone or CTime()
	ply.pain_addtime = ply.pain_addtime or CTime()

	if ply.adrenaline < 0 then ply.adrenaline = 0 end
	if ply.pain_add < 0 then ply.pain_add = 0 end

	if ply.pain_add > 0 and ply.adrenaline < 10 then
		if ply.pain_addtime < CTime() then
			ply.pain_addtime = ply.pain_addtime + 0.1
			ply.pain_add = ply.pain_add - 0.4
			ply.pain = ply.pain + 1
		end
	end

	if ply.adrenaline > 0 then
		if ply.adrenaline_unone < CTime() then
			ply.adrenaline_unone = ply.adrenaline_unone + 1
			ply.adrenaline = ply.adrenaline - 0.3
		end
	end

	if ply.adrenaline < 5 then
		if ply.ane_ra then
			ply:ChatPrint("Your right arm is broken")
			ply.ane_ra = false
		elseif ply.ane_la then
			ply:ChatPrint("Your left arm is broken")
			ply.ane_la = false
		elseif ply.ane_ll then
			ply:ChatPrint("Your left leg is broken")
			ply.ane_ll = false
		elseif ply.ane_rl then
			ply:ChatPrint("Your right leg is broken")
			ply.ane_rl = false
		end
	end

	if ply.adrenaline < 20 then
		if ply.ane_neck then
			ply:ChatPrint("Your neck is broken")
            ply:Kill()
			ply.ane_neck = false
		end
	end

	if ply.adrenaline < 15 then
		if ply.ane_jdis then
            ply:ChatPrint("Your jaw has been dislocated")
            if !ply.fake then
                Faking(ply)
            end
			ply.ane_jdis = false
		elseif ply.ane_jaw then
            ply:ChatPrint("Your jaw is broken")
            ply.mutejaw = true
			ply.ane_jaw = false
		end
	end
end)

//ya seriezen!!
// сука я думал ты шутил
//эт очто МНЕ СТРАШНО
// сука я за компом нахуй уснул
