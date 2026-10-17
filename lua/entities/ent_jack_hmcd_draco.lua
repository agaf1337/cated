--[[File Path:   gamemodes/homicide/entities/entities/ent_jack_hmcd_akm.lua

--]]
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_wep_base"
ENT.SWEP = "wep_jack_hmcd_draco"
ENT.ImpactSound = "physics/metal/weapon_impact_soft3.wav"
ENT.Model = "models/weapons/w_draco.mdl"
ENT.DefaultAmmoAmt = 30
ENT.AmmoType = "SniperRound"
ENT.MuzzlePos = Vector(27, 0, 2.8)
ENT.BulletDir = Vector(1, 0, 0)
ENT.BulletEjectPos = Vector(6, 1, 3.3)
ENT.BulletEjectDir = Vector(0, 1, 0)
ENT.Damage = 45
ENT.ShellEffect = "eff_jack_hmcd_76239"
ENT.TriggerDelay = .1
ENT.Automatic = true
ENT.MuzzleEffect = "pcf_jack_mf_mrifle1"


if CLIENT then
	local WorldMagModel = nil
	
	function ENT:Initialize()
		WorldMagModel = ClientsideModel("models/weapons/w_draco_mag.mdl")
		if IsValid(WorldMagModel) then
			WorldMagModel:SetNoDraw(true)
			WorldMagModel:AddEffects(EF_BONEMERGE)
		end
	end
	
	function ENT:Draw()
		self:DrawModel()
		
		if IsValid(WorldMagModel) then
			local boneIndex = self:LookupBone("W_MAGAZINE")
			if boneIndex then
				local pos, ang = self:GetBonePosition(boneIndex)
				if pos and ang then
					-- Rotate 45 degrees to the right and move slightly up
					ang:RotateAroundAxis(ang:Right(), 45)
					pos = pos + ang:Up() * 0.5
					
					WorldMagModel:SetPos(pos)
					WorldMagModel:SetAngles(ang)
					WorldMagModel:SetParent(self)
					WorldMagModel:DrawModel()
				end
			end
		end
	end
	
	function ENT:OnRemove()
		if IsValid(WorldMagModel) then
			WorldMagModel:Remove()
		end
	end
end