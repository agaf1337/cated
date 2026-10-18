hook.Add("EntityTakeDamage", "AntiDamageWithDM", function(ply, dmginfo)
	if engine.ActiveGamemode() ~= "hmcdunion" then return end
	if GAMEMODE.DMTime and GAMEMODE.DMTime >= 1 then return false end
end)

local CTime = CurTime()
hook.Add("PlayerTick", "Glaza", function (ply)
    ply:SetEyeTarget(ply:GetEyeTrace().HitPos)
end)

local painwalk = {
    "Fuck.. it hurts to walk",
    "My leg.. goddamnit..",
    "Ngh.. every step is agony..",
    "I shouldn't be walking on this..",
    "Shit.. it's broken..",
    "Aargh.. damn leg..",
    "It's tearing me apart..",
    "I can barely stand.."
}

local painrun = {
    "FUCK! IT'S KILLING ME!",
    "AAAGGHH! MY LEG!",
    "I CAN'T RUN! SHIT!",
    "FUUUUUCCKKKK!!",
    "MY LEG IS TEARING APART!",
    "STOP! I CAN'T TAKE THIS!",
    "GAAAAAHH! MY BONE!",
    "I'M GONNA PASS OUT! FUCK!"
}

local paintrip = {
    "SHIT!",
    "FUCK!",
    "GAH!",
    "WHOA!",
    "OH SHIT!",
    "FUCK-!",
    "GODDAMN!",
    "NOT AGAIN! FUCK!",
    "NO! SHIT!",
    "MY LEG! GAH!",
    "AAARGH!"
}
local fef = 0
local function DoFootstepEffects(ply, foot)
	if engine.ActiveGamemode() == "hmcdunion" and ply.Role == "combine" then
        ply:EmitSound("npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav")
    end

    local painMult = (ply.pain > 20 and ply.pain / 25 or 1)
    local legBroken = (foot == 0 and (ply.Bones["LeftLeg"] or 1) < 1) or (foot == 1 and (ply.Bones["RightLeg"] or 1) < 1)
    local power = legBroken and 2 or 0.9

    if ply:IsSprinting() then
        local side = (foot == 0 and -0.6 or 0.6)
		local roll = (foot == 0 and -0.45 or 0.45)
        ply:ViewPunch(Angle(power, side, roll) * painMult)
		if legBroken then
			ply.pain_add = ply.pain_add + 6	
			if math.random(1,16) == 1 then Faking(ply) 
			if ply.ModelSex == "male" then ply:EmitSound("vo/episode_1/npc/male01/cit_pain0"..math.random(1,9)..".wav", 100) else ply:EmitSound("vo/episode_1/npc/female01/cit_pain0"..math.random(1,9)..".wav", 100) end
			end
		end
    else
        local side = (foot == 0 and -0.15 or 0.15)
        local roll = (foot == 0 and -0.1 or 0.1)
        ply:ViewPunch(Angle(power, side, roll) * painMult)
		if legBroken then
			ply.pain_add = ply.pain_add + 1

			if math.random(1,64) == 1 then Faking(ply) 
			

			if ply.ModelSex == "male" then ply:EmitSound("vo/episode_1/npc/male01/cit_pain0"..math.random(1,9)..".wav", 100) else ply:EmitSound("vo/episode_1/npc/female01/cit_pain0"..math.random(1,9)..".wav", 100) end
			end
		end
    end
end

hook.Add("PlayerFootstep", "CustomFootstep", function(ply, pos, foot, sound, volume, rf)
    DoFootstepEffects(ply, foot)
end)

hook.Add("Think", "SlowMovementFootsteps", function()
    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() or not ply:IsOnGround() or ply:InVehicle() then continue end

        local vel = ply:GetVelocity():Length()
        
        if vel > 80 or vel < 5 then 
            ply.StepDist = 0
            continue 
        end

        ply.StepDist = (ply.StepDist or 0) + (vel * FrameTime())

        local stepThreshold = 45 

        if ply.StepDist > stepThreshold then
            ply.StepDist = 0
            ply.StepSide = (ply.StepSide == 0) and 1 or 0
            
            ply:EmitSound("player/footsteps/gear" .. math.random(1, 6) .. ".wav", 60, 100, 0.3)
            
            DoFootstepEffects(ply, ply.StepSide)
        end
    end
end)

hook.Add("PlayerUse", "jig431eeij1qdgedqpviag", function(ply, ent)
    ply.NextBoxUse = ply.NextBoxUse or 0
    if ply.NextBoxUse > CurTime() then return end

    local model = ent:GetModel()
    if not model then return end

    if Box2_Models[model] then
		if ent.looted1 then return false end
        ply.NextBoxUse = CurTime() + 1
        if math.random(1, 4) == 1 then
            ent.looted1 = true

			local drop
			if ply:GetNWInt("RoundType", 1) == 5 then
				if not HeavyBox_DropGunFreeZone or not Box_DropGunFreeZone then return end
				drop = table.Random(Box_DropGunFreeZone)
			else
				if not HeavyBox_Drop or not Box_Drop then return end
				drop = table.Random(Box_Drop)
			end
			local loot = ents.Create(drop)
			loot:SetPos(ply:GetEyeTrace().HitPos)
			
			if drop == "ent_jack_hmcd_ammo" then
				loot.HmcdSpawned=true
				loot.AmmoType=table.Random(AmmoType_Drop)
				loot.Rounds=math.random(1,20)
			end

			loot:Activate()
			loot:Spawn()
			ply:ViewPunch(Angle(math.random(4, 6), 0, 0))
			ply:EmitSound("physics/cardboard/cardboard_box_break" .. math.random(1,7) ..".wav",50)
        else
            ply:ViewPunch(Angle(math.random(1, 3), 0, 0))
			ply:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1,3) ..".wav",40)
        end
    end
end)

hook.Add( "AllowPlayerPickup", "nonkpi31g", function( ply, ent )
    if not IsValid(ent) then return end 
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then 
        if phys:GetMass() >= 15 then 
            return false 
        end
    end
end )

hook.Add("PropBreak", "SystemLoot", function(ply, prop)
	if not IsValid(ply) or not ply:Alive() then return end
	local pos = prop:GetPos()

	local hdrop
	local drop
	if ply:GetNWInt("RoundType", 1) == 5 then
		if not HeavyBox_DropGunFreeZone or not Box_DropGunFreeZone then return end
		hdrop = table.Random(HeavyBox_DropGunFreeZone)
		drop = table.Random(Box_DropGunFreeZone)
	else
		if not HeavyBox_Drop or not Box_Drop then return end
		hdrop = table.Random(HeavyBox_Drop)
		drop = table.Random(Box_Drop)
	end

	if table.HasValue(HeavyBox_Models, prop:GetModel()) then
		local heavyloot = ents.Create(hdrop)
		heavyloot:SetPos(pos+Vector(0,0,5))
		heavyloot:Activate()
		heavyloot:Spawn()
	end
	if table.HasValue(Box_Models, prop:GetModel()) then
		local loot = ents.Create(drop)
		loot:SetPos(pos+Vector(0,0,5))
		
		if drop == "ent_jack_hmcd_ammo" then
			loot.HmcdSpawned=true
			loot.AmmoType=table.Random(AmmoType_Drop)
			loot.Rounds=math.random(1,20)
		end

		loot:Activate()
		loot:Spawn()
	end
end)

hook.Add("PlayerPostThink", "CapsicumWork", function(ply)
	if engine.ActiveGamemode() ~= "hmcdunion" then return end -- Чеча я убью тебя нахуй
	if not IsValid(ply) then return end
    if ply:GetNWString("HL2_Class", "") == "Shotguner" then
        ply:SetBodygroup(0, 1)
    end

	if IsValid(ply) and engine.ActiveGamemode() == "hmcdunion" then ply.capsicumminus = ply.capsicumminus or CTime end
	if ply.capsicum and ply.capsicum < 0 then ply.capsicum = 0 end
	if ply.capsicum and ply.capsicum > 0.1 then
		ply:ScreenFade(SCREENFADE.IN, color_black, 1, 3)
		if ply.capsicumminus and ply.capsicumminus < CTime then
			ply.capsicumminus = ply.capsicumminus + 0.08
			ply.capsicum = ply.capsicum - 0.3
		end
	end
end)

local realpypy = {
	["models/props_junk/cinderblock01a.mdl"] = "wep_jack_hmcd_brick",
	["models/props/cs_office/fire_extinguisher.mdl"] = "wep_jack_hmcd_firextinguisher",
	["models/weapons/w_fire_extinguisher.mdl"] = "wep_jack_hmcd_firextinguisher",
	["models/props_canal/mattpipe.mdl"] = "wep_jack_hmcd_leadpipe",
	["models/props_junk/garbage_glassbottle003a.mdl"] = "wep_jack_hmcd_bottle",
	["models/props_junk/garbage_glassbottle003a_chunk01.mdl"] = "wep_jack_hmcd_bottlebroken",
	["models/props_junk/shovel01a.mdl"] = "wep_jack_hmcd_shovel",
	["models/props_c17/metalpot002a.mdl"] = "wep_jack_hmcd_pan",
	["models/props_interiors/pot02a.mdl"] = "wep_jack_hmcd_pot",
	["models/props_junk/garbage_coffeemug001a.mdl"] = "wep_jack_hmcd_mug",
	["models/weapons/w_knife_ct.mdl"] = "wep_jack_hmcd_combatknife",
	["models/weapons/w_knife_t.mdl"] = "wep_jack_hmcd_combatknife", // это для фанатов
	["models/props/cs_militia/axe.mdl"] = "wep_jack_hmcd_axe",
	["models/weapons/w_357.mdl"] = "wep_jack_hmcd_revolver",
	["models/weapons/w_pistol.mdl"] = "wep_jack_hmcd_usp",
	["models/weapons/w_irifle.mdl"] = "wep_jack_hmcd_ar2",
	["models/weapons/w_shotgun.mdl"] = "wep_jack_hmcd_spas",
	["models/weapons/w_crossbow.mdl"] = "wep_jack_hmcd_crossbow",
	["models/weapons/w_stunbaton.mdl"] = "wep_jack_hmcd_stunstick",
	["models/weapons/w_crowbar.mdl"] = "wep_jack_hmcd_crowbar"
}

hook.Add("PlayerUse", "RealPropTake", function(ply, prop)
	if not IsValid(ply) or not IsValid(prop) then return end

	if ply.click then return end
	ply.click = true
	timer.Simple(4, function()
		if IsValid(ply) then ply.click = false end
	end)

	local model = string.lower(prop:GetModel() or "")

	if realpypy[model] then
		ply:Give(realpypy[model])
		prop:Remove()
	end

	local class = prop:GetClass()

	if class == "prop_physics" or class=="prop_physics_multiplayer" or class == "func_physbox" then
		local PhysObj = prop:GetPhysicsObject()
		if PhysObj and PhysObj.GetMass and PhysObj:GetMass() > 100 then return false end
	end

	if ply.fake then return false end
end)

local function WorkOtrub(ply)
	if ply.Blood <= 3100 or ply.pain >= 300 or ply.o2 <= 0.4 or (ply.consciousness and ply.consciousness < 40) then
		ply.Otrub = true
		ply:SetNWBool("Breath", true)
		ply:ScreenFade(SCREENFADE.IN, color_black, 0.5, 0.5)
		ply:SetDSP(14)
		ply:AddAchiveProgress("sweetdreams", 100)
	else 
		ply.Otrub = false 
		ply:SetDSP(1) 
	end
end

hook.Add("Player Think", "Otrub", function(ply)
	if !ply:Alive() then return end
	local oldOtrub = ply.Otrub
	WorkOtrub(ply)
	if ply.Otrub and !ply.fake then 
		Faking(ply) 
	//elseif oldOtrub and not ply.Otrub and ply.fake then
		//Faking(ply) нахуя?
	end
end)

hook.Add("PlayerPostThink", "Glazkiotrub", function(ply)
	local rag = ply:GetNWEntity("Ragdoll")
	if IsValid(rag) then 
		if ply.Otrub then
			rag:SetFlexWeight(9, 11)
		else
			rag:SetFlexWeight(9, 0)
		end
	end
end)

/*local delaybutton = 0
hook.Add("PlayerButtonDown", "F1_ShowHelp", function(ply, button)
	ply.delaybutton = ply.delaybutton or delaybutton
	if ply.delaybutton < CurTime() then
		ply.delaybutton = ply.delaybutton + 1
    	if button == KEY_F1 then
    	    //ply:ConCommand("gm_showhelp") no fuck off
    	end
	end
end)*/

--[[hook.Add("Move", "FakeBecauseHitWall", function(ply,mv)
    local speed = mv:GetVelocity():LengthSqr()
    local need = 75000
    if speed > need then
        local trace = util.TraceLine({
            start = ply:GetPos(),
            endpos = ply:GetPos() + ply:GetForward() * 20 + ply:GetUp() * 4,
            filter = ply
        })

        if trace.Hit then
			if !ply.fake then
				Faking(ply)
			end
        end
    end
end)]]--

--[[hook.Add("Think", "CheckPlayerCollisionSpeed", function()
    for _, ply in player.Iterator() do
        if not IsValid(ply) or not ply:Alive() then continue end

        local pos = ply:GetPos()
        local forward = ply:GetForward()
        local trace = util.TraceHull({
            start = pos,
            endpos = pos + forward * 20 + ply:GetUp() * 8,
            mins = ply:OBBMins(),
            maxs = ply:OBBMaxs(),
            filter = ply
        })

        if trace.Hit then
            local speed = ply:GetVelocity():Length()
			if speed > 300 then
				if !ply.fake then
					Faking(ply)
				end
			end
        end
    end
end)]]--

concommand.Add("hmcd_holdbreath", function(ply)
	if not ply:Alive() then return end
	local breath = ply:GetNWBool("Breath", true)
	if breath then
		ply:SetNWBool("Breath", false)
	else
		ply:SetNWBool("Breath", true)
	end
end)

-- headcrab infection
hook.Add("PlayerPostThink", "StadeHeadcrab", function(ply)
	if ply:GetNWBool("Headcrab", false) == true then
		if ply.pain >= 130 then
			ply:SetNWInt("Headcrab_Stade", 4)
		elseif ply.pain >= 100 then
			ply:SetNWInt("Headcrab_Stade", 3)
		elseif ply.pain >= 60 then
			ply:SetNWInt("Headcrab_Stade", 2)
		elseif ply.pain >= 0 then
			ply:SetNWInt("Headcrab_Stade", 1)
		end
	end
end)

local function AdminOnlySpawn(ply)
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then
        return false
    end
end

hook.Add("PlayerSpawnObject", "HMCD_RestrictSpawn", AdminOnlySpawn)
hook.Add("PlayerSpawnProp", "HMCD_RestrictSpawn", AdminOnlySpawn)
hook.Add("PlayerSpawnNPC", "HMCD_RestrictSpawn", AdminOnlySpawn)
hook.Add("PlayerSpawnSENT", "HMCD_RestrictSpawn", AdminOnlySpawn)
hook.Add("PlayerSpawnSWEP", "HMCD_RestrictSpawn", AdminOnlySpawn)
hook.Add("PlayerSpawnVehicle", "HMCD_RestrictSpawn", AdminOnlySpawn)
hook.Add("PlayerSpawnEffect", "HMCD_RestrictSpawn", AdminOnlySpawn)
hook.Add("PlayerSpawnRagdoll", "HMCD_RestrictSpawn", AdminOnlySpawn)


local function replaceitfuck()
    local processed = {}
    for _, v in pairs(ents.GetAll()) do
        if v:GetModel() == "models/props_combine/bunker_gun01.mdl" then
            local pos = v:GetPos()
            local unique = false
            
            for _, pPos in pairs(processed) do
                if pos:DistToSqr(pPos) < 2500 then
                    unique = true
                    break
                end
            end
            
            if not unique then
                table.insert(processed, pos)
                local ang = v:GetAngles()
                
                for _, double in pairs(ents.FindInSphere(pos, 50)) do
                    if double:GetModel() == "models/props_combine/bunker_gun01.mdl" then
                        double:Remove()
                    end
                end
                
                local newEnt = ents.Create("ent_jack_hmcd_placed_pkm")
                if IsValid(newEnt) then
                    newEnt:SetPos(pos)
                    newEnt:SetAngles(ang)
                    newEnt:Spawn()
                end
            end
        end
    end
end

hook.Add("InitPostEntity", "funnyier", replaceitfuck)
hook.Add("PostCleanupMap", "funyguns", replaceitfuck)

local tbl213 = {
	"ent_jack_hmcd_morphine",
	"ent_jack_hmcd_adrenaline",
	"ent_jack_hmcd_bandagebig",
	"ent_jack_hmcd_painpills"
}

hook.Add("OnEntityCreated", "ripoffmydick", function(ent)
    if ent:GetClass() == "item_healthvial" then
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            
            local pos = ent:GetPos()
            local ang = ent:GetAngles()
            ent:Remove()

            local b = ents.Create(tbl213[math.random(1,#tbl213)])
            if IsValid(b) then
                b:SetPos(pos)
                b:SetAngles(ang)
                b:Spawn()
            end
        end)
    end
    if ent:GetClass() == "item_healthkit" then
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            
            local pos = ent:GetPos()
            local ang = ent:GetAngles()
            ent:Remove()

            local b = ents.Create("ent_jack_hmcd_medkit")
            if IsValid(b) then
                b:SetPos(pos)
                b:SetAngles(ang)
                b:Spawn()
            end
        end)
    end

end)
