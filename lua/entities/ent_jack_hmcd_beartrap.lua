--[[File Path:   gamemodes/homicide/entities/entities/ent_jack_hmcd_beartrap.lua

--]]
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_loot_base"
ENT.PrintName = "Bear Trap"
ENT.SWEP = "wep_jack_hmcd_beartrap"
ENT.Model = "models/stiffy360/beartrap.mdl"
ENT.Sequence = "OpenIdle"
ENT.CollisionGroup = COLLISION_GROUP_NONE

if SERVER then
	function ENT:PickUp(ply)
		local SWEP = self.SWEP

		if not (ply:HasWeapon(self.SWEP) or self.Triggered) then
			self:EmitSound("Grenade.ImpactHard", 60, 90)
			ply:Give(self.SWEP)
			ply:GetWeapon(self.SWEP).HmcdSpawned = self.HmcdSpawned

			if self.Poisoned then
				ply:GetWeapon(self.SWEP).Poisoned = true
			end

			self:Remove()
			ply:SelectWeapon(SWEP)
		else
			ply:PickupObject(self)
		end
	end

	local legBones = {
		[19] = true,
		[20] = true,
		[21] = true,
		[23] = true,
		[24] = true,
		[25] = true
	}

	local damageMuls = {
		[6] = 20,
		[5] = 20
	}

	function ENT:StartTouch(ply)
		if not IsValid(ply) or not IsValid(self) then return end

		if self.Triggered then return end

		if self:GetSequence() ~= 0 and self:GetSequence() ~= 2 and not self.Triggered then
			self.Triggered = true
			self:SetPlaybackRate(1)
			self:SetCycle(0)
			self:SetSequence("Snap")
			self:EmitSound("beartrap.wav")
			constraint.RemoveAll(self)
			self:GetPhysicsObject():EnableMotion(false)
			timer.Simple(0.1, function()
				if not IsValid(self) then return end
				local Pos = self:LocalToWorld(self:OBBCenter()) + Vector(0, 0, 5)
				self:SetSequence("ClosedIdle")

				if self:IsEntSoft(ply) then
					for i = 1, 20 do
						local Tr = util.TraceLine({
							start = Pos,
							endpos = ply:GetPos() + VectorRand() * 50
						})

						util.Decal("Blood", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
					end
				end

				if not (ply:IsPlayer() or ply:IsRagdoll()) then
					local DamageAmt = math.random(30, 35)
					local Dam = DamageInfo()
					Dam:SetAttacker(IsValid(self.Attacker) and self.Attacker or self)
					Dam:SetInflictor(self)
					Dam:SetDamage(DamageAmt)
					Dam:SetDamageForce(vector_origin)
					Dam:SetDamageType(DMG_SLASH)
					Dam:SetDamagePosition(ply:GetPos())
					ply:TakeDamageInfo(Dam)
				end
			end)

			if ply:IsPlayer() or ply:GetClass() == "prop_ragdoll" then
				local owner = ply

				if self.Poisoned or self.ContactPoisoned then
					local poisonsApplied = {}

					if self.Poisoned then
						table.insert(poisonsApplied, "Curare")
					end

					if self.ContactPoisoned then
						table.insert(poisonsApplied, "VX")
					end

					self.Poisoned = nil
					self.ContactPoisoned = nil

					if owner:IsPlayer() then
						HMCD_Poison(owner, self.Poisoner, table.Random(poisonsApplied))
					end
				end

				local minDist, bestBone = 1000000, 0

				for i = 0, ply:GetBoneCount() - 1 do
					local pos = ply:GetBonePosition(i)
					local dist = pos:DistToSqr(self:GetPos())

					if dist < minDist then
						minDist = dist
						bestBone = i
					end
				end
				if !owner.fake then Faking(owner) end

				local impactBoneName = ""
				if bestBone >= 0 and bestBone < ply:GetBoneCount() then
					impactBoneName = string.lower(ply:GetBoneName(bestBone) or "")
				end
				print(impactBoneName)
				if string.find(impactBoneName, "head") or string.find(impactBoneName, "forward") or string.find(impactBoneName, "neck") then
					if owner:IsPlayer() then
						owner.consciousness = 0
					end

					local upDir = (self:GetUp() + Vector(math.random(-1,1), math.random(-1,1), math.random(0,1))):GetNormalized()
					local headPos = ply:GetBonePosition(bestBone)

					local headRag = owner:GetNWEntity("Ragdoll")
					if IsValid(headRag) then
						for i = 0, headRag:GetPhysicsObjectCount() - 1 do
							local bn = headRag:TranslatePhysBoneToBone(i)
							local nm = string.lower(headRag:GetBoneName(bn) or "")
							if string.find(nm, "head") then
								local hp = headRag:GetPhysicsObjectNum(i)
								if IsValid(hp) then
									headPos = hp:GetPos()
									hp:SetVelocity(upDir * 1500)
									hp:AddAngleVelocity(VectorRand() * 3000)
								end
								break
							end
						end
					end

					owner:EmitSound("bones/bone2.mp3", 90, 100)

					net.Start("blyadinagoviadina")
						net.WriteVector(self:GetPos() + Vector(0,0,1))
						net.WriteVector(VectorRand(-1,1))
						net.WriteFloat(120)
					net.Broadcast()
					if owner:IsRagdoll() and owner:GetNWEntity("RagdollOwner") then
						owner:GetNWEntity("RagdollOwner").consciousness = 0
						owner:GetNWEntity("RagdollOwner").pain = 500
						owner.pain = 500
						owner.consciousness = 0
					end
					if owner:IsRagdoll() and owner:GetNWEntity("RagdollOwner") then
						timer.Simple(0.5, function()
							owner:GetNWEntity("RagdollOwner").brain = 0
							owner:GetNWEntity("RagdollOwner").skull = 0
							owner:GetNWEntity("RagdollOwner"):Kill()
						end)
					end

							

				end

				if legBones[bestBone] then
					if math.random(1,2) == 1 then
						if SERVER then 
							owner.Bones['RightLeg'] = owner.Bones['RightLeg'] - 0.5
						end
						owner:ChatPrint("Your right leg is broken.")
					else
						if SERVER then 
							owner.Bones['LeftLeg'] = owner.Bones['LeftLeg'] - 0.5
						end
						owner:ChatPrint("Your left leg is broken.")
					end
				end
		local rag = owner:GetNWEntity("Ragdoll")
		if not IsValid(rag) then rag = ply end

		if IsValid(rag) and rag:IsRagdoll() then
			rag.IsWeld = (rag.IsWeld or 0) + 1

			local bone = bestBone
			if bone < 0 or bone >= rag:GetBoneCount() then
				local minBone, minDist2 = -1, math.huge
				for i = 0, rag:GetBoneCount() - 1 do
					local d = (rag:GetBonePosition(i) - self:GetPos()):LengthSqr()
					if d < minDist2 then minBone, minDist2 = i, d end
				end
				bone = minBone
			end

			local PhysBone = -1
			local BoneObj = nil
			if bone >= 0 then
				PhysBone = rag:TranslateBoneToPhysBone(bone)
				if PhysBone >= 0 then BoneObj = rag:GetPhysicsObjectNum(PhysBone) end
			end

			if IsValid(BoneObj) then
				BoneObj:SetPos(self:GetPos())

				local weldEntity = constraint.Weld(rag, self, PhysBone, 0, 0, true, false)
				constraint.Weld(self, game.GetWorld(), 0, 0, 0, true)
				if IsValid(weldEntity) then
					rag.weld = rag.weld or {}
					rag.weld[weldEntity] = self
				end
			end
		end
		
			local pos = ply:GetBonePosition(bestBone)
				local DamageAmt = math.random(30, 35) * (damageMuls[bestBone] or 1)
				local Dam = DamageInfo()
				Dam:SetAttacker(IsValid(self.Attacker) and self.Attacker or self)
				Dam:SetInflictor(self)
				Dam:SetDamage(DamageAmt)
				Dam:SetDamageForce(vector_origin)
				Dam:SetDamageType(DMG_SLASH)
				Dam:SetDamagePosition(pos)
				ply:TakeDamageInfo(Dam)
			end

			return
		end
	end

	function ENT:IsEntSoft(ent)
		return ent:IsNPC() or ent:IsPlayer() or (ent:GetClass() == "prop_ragdoll")
	end
end