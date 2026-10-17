HMCD_SurfaceHardness = {
	[MAT_METAL] = .95,
	[MAT_COMPUTER] = .95,
	[MAT_VENT] = .95,
	[MAT_GRATE] = .95,
	[MAT_FLESH] = .5,
	[MAT_ALIENFLESH] = .3,
	[MAT_SAND] = .3,
	[MAT_DIRT] = .3,
	[74] = .1,
	[85] = .2,
	[MAT_WOOD] = .5,
	[MAT_FOLIAGE] = .5,
	[MAT_CONCRETE] = .9,
	[MAT_TILE] = .8,
	[MAT_SLOSH] = .05,
	[MAT_PLASTIC] = .3,
	[MAT_GLASS] = .1
}

local function RayOBBIntersection(rayStart, rayDir, boxMin, boxMax, boxPos, boxAng)
	local tMin, tMax = 0, math.huge
	local delta = boxPos - rayStart
	local axes = {boxAng:Forward(), boxAng:Right(), boxAng:Up()}

	for i = 1, 3 do
		local axis = axes[i]
		local e = axis:Dot(delta)
		local f = rayDir:Dot(axis)

		if math.abs(f) > 0.0001 then
			local t1 = (e + boxMin[i]) / f
			local t2 = (e + boxMax[i]) / f
			if t1 > t2 then t1, t2 = t2, t1 end
			if t1 > tMin then tMin = t1 end
			if t2 < tMax then tMax = t2 end
			if tMin > tMax or tMax < 0 then return false end
		else
			if -e + boxMin[i] > 0 or -e + boxMax[i] < 0 then return false end
		end
	end
	return true, tMin, tMax
end

function SWEP:BulletCallbackFunc(dmgAmt, ply, tr, dmg, tracer, hard, multi)
	if tr.MatType == MAT_FLESH then
		local vPoint = tr.HitPos
		local effectdata = EffectData()
		effectdata:SetOrigin(vPoint)
		util.Effect("BloodImpact", effectdata)
	end

	if tr.HitSky then return end
	if hard then self:RicochetOrPenetrate(tr) end
end

function SWEP:RicochetOrPenetrate(initialTrace)
	local AVec, IPos, TNorm, SMul = initialTrace.Normal, initialTrace.HitPos, initialTrace.HitNormal, HMCD_SurfaceHardness[initialTrace.MatType]
	if not SMul then SMul = .5 end
	
	local ApproachAngle = -math.deg(math.asin(math.Clamp(TNorm:DotProduct(AVec), -1, 1)))
	local MaxRicAngle = 60 * SMul
	local ent = initialTrace.Entity

	if ApproachAngle > (MaxRicAngle * 1.25) then
		local MaxDist = (self.Damage / SMul) * 1.15
		local ExitPos = IPos + AVec * 5
		local Penetrated = false
		local HitInnerBox = false

		if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer() or ent:GetClass() == "prop_ragdoll") then
			local numHitBoxSets = ent:GetHitboxSetCount() or 1
			local hitboxesToProcess = {}

			for set = 0, numHitBoxSets - 1 do
				local numHitBoxes = ent:GetHitBoxCount(set) or 0
				for hitbox = 0, numHitBoxes - 1 do
					local bone = ent:GetHitBoxBone(hitbox, set)
					if bone then
						local bMin, bMax = ent:GetHitBoxBounds(hitbox, set)
						local bPos, bAng = ent:GetBonePosition(bone)
						
						if bMin and bMax and bPos and bAng then
							local hit, t1, t2 = RayOBBIntersection(IPos - AVec * 2, AVec, bMin, bMax, bPos, bAng)
							if hit and t1 < MaxDist then
								table.insert(hitboxesToProcess, {
									entryDist = t1,
									exitDist = t2,
									min = bMin,
									max = bMax
								})
							end
						end
					end
				end
			end

			table.sort(hitboxesToProcess, function(a, b) return a.entryDist < b.entryDist end)

			local finalExitDist = 0
			if #hitboxesToProcess > 0 then
				Penetrated = true
				
				local initialHit = hitboxesToProcess[1]
				finalExitDist = initialHit.exitDist

				for i = 1, #hitboxesToProcess do
					local hb = hitboxesToProcess[i]

					if hb.entryDist <= MaxDist then
						if hb.exitDist > finalExitDist then
							finalExitDist = hb.exitDist
						end

						local volume = (hb.max.x - hb.min.x) * (hb.max.y - hb.min.y) * (hb.max.z - hb.min.z)
					
						if volume > 200 and volume < 950 and hb.entryDist <= finalExitDist then
							HitInnerBox = true
						end
					end
				end
			end

			if Penetrated then
				ExitPos = IPos + AVec * (math.Clamp(finalExitDist, 1, MaxDist) + 1)
				
				if HitInnerBox then
					local d = DamageInfo()
					d:SetDamage(self.CurrentDamage * 2.5)
					d:SetAttacker(self.Owner or ply)
					d:SetInflictor(self)
					d:SetDamageType(DMG_BULLET)
					d:SetDamagePosition(IPos)
					ent:TakeDamageInfo(d)
				end
			end
		end

		if not Penetrated then
			local SearchDist = 5
			while (not Penetrated) and (SearchDist < MaxDist) do
				local SearchPos = IPos + AVec * SearchDist
				local PeneTrace = util.QuickTrace(SearchPos, -AVec * SearchDist)
				if (not PeneTrace.StartSolid) and PeneTrace.Hit then
					Penetrated = true
					ExitPos = SearchPos
				else
					SearchDist = SearchDist + 5
				end
			end
		end

		if Penetrated then
			local DistTraveled = IPos:Distance(ExitPos)
			local StopMul = DistTraveled / MaxDist
			local NextDamage = self.CurrentDamage * math.Clamp((1 - StopMul) * 1.2, 0.01, 1)

			self:FireBullets({
				Attacker = self.Owner,
				Damage = 1,
				Force = 1,
				Num = 1,
				Tracer = 0,
				Dir = -AVec,
				Spread = Vector(0, 0, 0),
				Src = ExitPos
			})

			self:FireBullets({
				Attacker = self.Owner,
				Damage = NextDamage,
				Force = self.Damage / 15,
				Num = 1,
				Tracer = 0,
				Dir = AVec,
				Spread = Vector(0, 0, 0),
				Src = ExitPos,
				Callback = function(ply, tr)
					local traceData = {
						start = ExitPos,
						endpos = ExitPos + AVec * 100000,
						filter = ent
					}
					local trace = util.TraceLine(traceData)
					local wep = ply:GetActiveWeapon()
					if IsValid(wep) and wep.BulletCallbackFunc then
						wep:BulletCallbackFunc(NextDamage, ply, trace, nil, false, true, false)
					end
				end
			})

			self.CurrentDamage = NextDamage
		end

	elseif ApproachAngle < (MaxRicAngle * .75) and not (initialTrace.MatType == MAT_FLESH) then
		sound.Play("snd_jack_hmcd_ricochet_" .. math.random(1, 2) .. ".wav", IPos, 70, math.random(90, 100))
		local NewVec = AVec:Angle()
		NewVec:RotateAroundAxis(TNorm, 180)
		local AngDiffNormal = math.deg(math.acos(math.Clamp(NewVec:Forward():Dot(TNorm), -1, 1))) - 90
		NewVec:RotateAroundAxis(NewVec:Right(), AngDiffNormal * .7)
		NewVec = NewVec:Forward()
		
		self:FireBullets({
			Attacker = self.Owner,
			Damage = self.Damage * .5,
			Force = self.Damage / 15,
			Num = 1,
			Tracer = 0,
			Distance = 600,
			Dir = NewVec,
			Spread = Vector(0, 0, 0),
			Src = IPos + TNorm
		})
	end
end
