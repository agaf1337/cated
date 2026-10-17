if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
else
	killicon.AddFont("wep_jack_hmcd_assaultrifle", "HL2MPTypeDeath", "1", Color(255, 0, 0))
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_ins2_draco")
end

SWEP.IconOverride = "kazoo/wep_daun_hmcd_draco.png"
SWEP.IconTexture = "vgui/hud/tfa_ins2_draco"
SWEP.IconLength = 3
SWEP.IconHeight = 2
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "Draco"
SWEP.Instructions = "This is a wooden/steel 7.62×39mm selective fire 30-round-capacity rifle, one of the most popular assault rifles in the world.\n\nLMB to fire.\nRMB to aim.\nRELOAD to reload.\nShot placement counts.\nCrouching helps stability.\nBullets can ricochet and penetrate."
SWEP.Primary.ClipSize = 31
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.ViewModel = "models/weapons/v_draco.mdl"
SWEP.WorldModel = "models/weapons/w_draco.mdl"
SWEP.SwitchFM = true
SWEP.ViewModelFlip = false
SWEP.Damage = 45
SWEP.Category="HMCD: Union - Pistols"
SWEP.Primary.Automatic = false
SWEP.ViewModelFOV = 70
SWEP.SprintPos = Vector(10, 0, -3)
SWEP.SprintAng = Angle(-20, 40, -50)
SWEP.AimPos = Vector(-2.22, -1, 0.8)
SWEP.AimAng = Angle(1.3, 0, 0)
SWEP.CloseAimPos = Vector(.45, 0, 0)
SWEP.AltAimPos = Vector(-1.63, -4, 0.4)
SWEP.ReloadTime = 5
SWEP.ReloadRate = .6
SWEP.UseHands = true
SWEP.ReloadSound = ""
SWEP.AmmoType = "AR2"
SWEP.Primary.Ammo = "AR2"
SWEP.TriggerDelay = .1
SWEP.CycleTime = 0.035

SWEP.TPIK = false

SWEP.TPIK_PosAngles = {
    ["ValveBiped.Bip01_R_Upperarm"] = Angle(-5, 0, 0),
	["ValveBiped.Bip01_L_Upperarm"] = Angle(30, 0, 0),
	["ValveBiped.Bip01_L_Finger1"] = Angle(-60, 0, 0),
}

SWEP.TPIK_PosVectors = {
	["ValveBiped.Bip01_Spine2"] = Vector(3,0,0)
}

SWEP.ShootWait_Ragdoll = 0.2

SWEP.Recoil = .85
SWEP.AttBone = "Weapon"
SWEP.Supersonic = true
SWEP.Accuracy = .999
SWEP.ShotPitch = 100
SWEP.ENT = "ent_jack_hmcd_draco"
SWEP.FuckedWorldModel = true
SWEP.DeathDroppable = false
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.CycleType = "auto"
SWEP.ReloadType = "magazine"
SWEP.DrawAnim = "base_draw"
SWEP.FireAnim = "base_fire"
local abcs = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
}
SWEP.IronFireAnim = "iron_fire_"..abcs[math.random(1,#abcs)]
SWEP.ReloadAnim = "base_reloadempty"
SWEP.TacticalReloadAnim = "base_reload"
SWEP.CloseFireSound = "sounds_zcity/draco/close.wav"
SWEP.LaserAngle = Angle(270, 0, 0)

SWEP.LaserPos_Right = 0
SWEP.LaserPos_Forward = 0
SWEP.LaserPos_Up = 0
SWEP.LaserPos_RightCorrect = 0

SWEP.FarFireSound = "ak74/ak74_dist.wav"
SWEP.SuppressedFireSound = "ak74/ak74_suppressed_fp.wav"
SWEP.ShellType = ""
SWEP.BarrelLength = 18
SWEP.FireAnimRate = 1
SWEP.AimTime = 6
SWEP.BearTime = 7
SWEP.HipHoldType = "ar2"
SWEP.AimHoldType = "ar2"
SWEP.DownHoldType = "passive"
SWEP.MuzzleEffect = "pcf_jack_mf_mrifle2"
SWEP.MuzzleEffectSuppressed = "pcf_jack_mf_suppressed"
SWEP.HipFireInaccuracy = .05
SWEP.HolsterSlot=1
SWEP.HolsterPos=Vector(3,-7,-4)
SWEP.HolsterAng=Angle(160,10,180)
SWEP.CarryWeight = 4500
SWEP.ScopeDotPosition = Vector(0, 0, 0)
SWEP.ScopeDotAngle = Angle(0, 0, 0)
SWEP.NextFireTime = 0
SWEP.ShellEffect = "eff_jack_hmcd_76239"
SWEP.ShellAttachment = 2
SWEP.MagEntity = "ent_jack_hmcd_akmmag"
SWEP.MagDelay = 1.9

SWEP.MuzzlePos = {30, -5.1, -3.1}

SWEP.InsHands = true
SWEP.ReloadAdd = 2

SWEP.ReloadSounds = {
	{"weapons/ak74/handling/ak74_magout.wav", 0.9, "Both"},
	{"weapons/ak74/handling/ak74_magin.wav", 3.6, "Both"},
	{"weapons/ak74/handling/ak74_boltback.wav", 5.2, "EmptyOnly"},
	{"weapons/ak74/handling/ak74_boltrelease.wav", 5.6, "EmptyOnly"}
}

SWEP.BulletDir = {400, 1.6, -10}

SWEP.SuicidePos = Vector(4, 7, -32)
SWEP.SuicideAng = Angle(100, 0, 90)
SWEP.SuicideTime = 10
SWEP.SuicideType = "Rifle"
SWEP.ProreloadMul = .5

SWEP.MuzzleInfo = {
	["Bone"] = "A_Muzzle",
	["Offset"] = Vector(30, 2, -2)
}

SWEP.MagazineModel = "models/weapons/v_draco_mag.mdl"
SWEP.MagBone = "Magazine"

if(CLIENT)then
	function SWEP:DrawWorldModel()
		local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
		if(self.DatWorldModel)then
			if((Pos)and(Ang))then
				self.DatWorldModel:SetRenderOrigin(Pos+Ang:Forward()*4.5+Ang:Right()-Ang:Up()*1.5)
				Ang:RotateAroundAxis(Ang:Up(),180)
				Ang:RotateAroundAxis(Ang:Right(),180)
				Ang:RotateAroundAxis(Ang:Forward(),0)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel=ClientsideModel("models/weapons/w_draco.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
		end
		
		-- Handle worldmodel magazine attachment
		if CLIENT then
			if not IsValid(self.WorldMagModel) and self.MagazineModel then
				self.WorldMagModel = ClientsideModel(self.MagazineModel, RENDERGROUP_OPAQUE)
				if IsValid(self.WorldMagModel) then
					self.WorldMagModel:SetNoDraw(true)
				end
			end
			
			if IsValid(self.WorldMagModel) and IsValid(self.DatWorldModel) then
				local magBone = self.DatWorldModel:LookupBone("W_MAGAZINE")
				if magBone and magBone > 0 then
					local bonePos, boneAng = self.DatWorldModel:GetBonePosition(magBone)
					if bonePos and boneAng then
								-- Apply rotation to the magazine
					boneAng:RotateAroundAxis(boneAng:Right(), 360)
					boneAng:RotateAroundAxis(boneAng:Forward(), 0)
					boneAng:RotateAroundAxis(boneAng:Up(), 267)
					bonePos = bonePos + boneAng:Up() * 3.2
					bonePos = bonePos + boneAng:Forward() * -1.7
					bonePos = bonePos + boneAng:Right() * 0.17
					
					self.WorldMagModel:SetPos(bonePos)
					self.WorldMagModel:SetAngles(boneAng)
					self.WorldMagModel:SetParent(self.DatWorldModel)
					self.WorldMagModel:AddEffects(EF_BONEMERGE)
					end
				end
				
				-- Position relative to worldmodel and draw
				if IsValid(self.WorldMagModel:GetParent()) then
					self.WorldMagModel:DrawModel()
				end
			end
		end
	end
	
	function SWEP:CreateModels()
		if CLIENT then
			-- Create the magazine model
			if self.MagazineModel and not IsValid(self.MagModel) then
				self.MagModel = ClientsideModel(self.MagazineModel, RENDERGROUP_VIEWMODEL)
				if IsValid(self.MagModel) then
					self.MagModel:SetNoDraw(true)
				end
			end
		end
	end
	
	function SWEP:Initialize()
		self:SetHoldType(self.HoldType or "shotgun")
		
		if self.BaseInit then
			self:BaseInit()
		end
		
		self:CreateModels()
	end
	
	function SWEP:Deploy()
		if CLIENT then
			self:CreateModels()
		end
		
		if self.BaseDeploy then
			return self:BaseDeploy()
		end
		
		return true
	end
	
	function SWEP:Holster()
		if CLIENT then
			if IsValid(self.MagModel) then
				self.MagModel:Remove()
				self.MagModel = nil
			end
			if IsValid(self.WorldMagModel) then
				self.WorldMagModel:Remove()
				self.WorldMagModel = nil
			end
		end
		
		if self.BaseHolster then
			return self:BaseHolster()
		end
		
		return true
	end
	
	function SWEP:ViewModelDrawn(vm)
		if CLIENT and IsValid(vm) then
			if not IsValid(self.MagModel) and self.MagazineModel then
				self:CreateModels()
			end
			
			if IsValid(self.MagModel) then
				-- Simple approach: Set parent to viewmodel and use EF_BONEMERGE
				-- This allows the engine to handle bone merging automatically
				if not IsValid(self.MagModel:GetParent()) or self.MagModel:GetParent() ~= vm then
					self.MagModel:SetParent(vm)
					self.MagModel:AddEffects(EF_BONEMERGE)
				end
				
				-- Ensure the magazine is drawn
				self.MagModel:DrawModel()
			end
		end
		
		if self.BaseViewModelDrawn then
			self:BaseViewModelDrawn(vm)
		end
	end
	
	function SWEP:OnRemove()
		if CLIENT then
			if IsValid(self.MagModel) then
				self.MagModel:Remove()
				self.MagModel = nil
			end
			if IsValid(self.WorldMagModel) then
				self.WorldMagModel:Remove()
				self.WorldMagModel = nil
			end
		end
		
		if self.BaseOnRemove then
			self:BaseOnRemove()
		end
	end
end
