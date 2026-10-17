if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
else
	killicon.AddFont("wep_jack_hmcd_assaultrifle", "HL2MPTypeDeath", "1", Color(255, 0, 0))
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_ins2_fn_fal")
end

SWEP.IconOverride = "entities/arccw_falins2.png"
SWEP.IconTexture = "vgui/hud/tfa_ins2_fn_fal"
SWEP.IconLength = 3
SWEP.IconHeight = 2
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "FN FAL"
SWEP.Instructions = "An absurdly powerful weapon, this aluminum/polymer 5.56x45mm semi-automatic home-assembled 30-round-capacity rifle is the quintessence of an armed American citizenry in the early 21st century.\n\nLMB to fire.\nRMB to aim.\nRELOAD to reload.\nShot placement counts.\nCrouching helps stability.\nBullets can ricochet and penetrate."
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.ViewModel = "models/weapons/c_ins2_fn_fal.mdl"
SWEP.WorldModel = "models/weapons/w_ins2_fn_fal.mdl"
SWEP.SwitchFM = false
SWEP.ViewModelFlip = false
SWEP.Damage = 30
SWEP.Category="HMCD: Union - Rifles"
SWEP.Primary.Automatic = true
SWEP.ViewModelFOV = 70
SWEP.SprintPos = Vector(10, 0, -3)
SWEP.SprintAng = Angle(-20, 40, -50)
SWEP.AimPos = Vector(-2.49, -1, 0.5)
SWEP.AimAng = Angle(1.3, 0, 0)
SWEP.CloseAimPos = Vector(.45, 0, 0)
SWEP.AltAimPos = Vector(-1.63, -4, 0.4)
SWEP.ReloadTime = 5
SWEP.ReloadRate = .6
SWEP.UseHands = true
SWEP.ReloadSound = ""
SWEP.AmmoType = "AR2"
SWEP.Primary.Ammo = "AR2"
SWEP.TriggerDelay = 0.08
SWEP.CycleTime = 0.035
SWEP.MuzAngAdd = Angle(-0.3,-0.05,0)

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

SWEP.Recoil = .5
SWEP.AttBone = "Weapon"
SWEP.Supersonic = true
SWEP.Accuracy = .999
SWEP.ShotPitch = 100
SWEP.ENT = "ent_jack_hmcd_fnfal"
SWEP.FuckedWorldModel = true
SWEP.DeathDroppable = false
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.CycleType = "auto"
SWEP.ReloadType = "magazine"
SWEP.DrawAnim = "base_draw"
SWEP.FireAnim = "base_fire"
SWEP.IronFireAnim = "iron_fire"
SWEP.ReloadAnim = "base_reloadempty"
SWEP.TacticalReloadAnim = "base_reload"
SWEP.CloseFireSound = "weapons/fal/fnfal_fire.wav"
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
SWEP.ShellAttachment = 3
SWEP.MagEntity = "ent_jack_hmcd_akmmag"
SWEP.MagDelay = 1.9

SWEP.MuzzlePos = {30, -5.1, -3.1}

SWEP.InsHands = true
SWEP.ReloadAdd = 2

SWEP.ReloadSounds = {
	{"weapons/fal/fnfal_magout.wav", 0.9, "Both"},
	{"weapons/fal/fnfal_magin.wav", 3.3, "Both"},
	{"weapons/fal/fnfal_boltback.wav", 4.9, "EmptyOnly"},
	{"weapons/fal/fnfal_boltrelease.wav", 5.5, "EmptyOnly"},
}

SWEP.BulletDir = {400, 1.6, -10}

SWEP.SuicidePos = Vector(4, 7, -32)
SWEP.SuicideAng = Angle(100, 0, 90)
SWEP.SuicideTime = 10
SWEP.SuicideType = "Rifle"
SWEP.ProreloadMul = .5

SWEP.MuzzleInfo = {
	["Bone"] = "Muzzle",
	["Offset"] = Vector(30, 1, 20)
}

SWEP.StandardModel = "models/weapons/tfa_ins2/upgrades/a_standard_fal.mdl"
SWEP.MagazineModel = "models/weapons/tfa_ins2/upgrades/a_magazine_fal_l1a1_30.mdl"
SWEP.StandardBone = "W_STANDARD"
SWEP.MagBone = "W_MAGAZINE"

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
			self.DatWorldModel=ClientsideModel("models/weapons/w_ins2_fn_fal.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
		end
	end
	
	function SWEP:CreateModels()
		if CLIENT then
			if self.StandardModel and not IsValid(self.StandardModelView) then
				self.StandardModelView = ClientsideModel(self.StandardModel, RENDERGROUP_VIEWMODEL)
				if IsValid(self.StandardModelView) then
					self.StandardModelView:SetNoDraw(true)
				end
			end
			if self.MagazineModel and not IsValid(self.MagModel) then
				self.MagModel = ClientsideModel(self.MagazineModel, RENDERGROUP_VIEWMODEL)
				if IsValid(self.MagModel) then
					self.MagModel:SetNoDraw(true)
				end
			end
		end
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
			if IsValid(self.StandardModelView) then
				self.StandardModelView:Remove()
				self.StandardModelView = nil
			end
			if IsValid(self.MagModel) then
				self.MagModel:Remove()
				self.MagModel = nil
			end
		end
		
		if self.BaseHolster then
			return self:BaseHolster()
		end
		
		return true
	end
	
	function SWEP:ViewModelDrawn(vm)
		if CLIENT and IsValid(vm) then
			if not IsValid(self.StandardModelView) and self.StandardModel then
				self:CreateModels()
			end
			if not IsValid(self.MagModel) and self.MagazineModel then
				self:CreateModels()
			end
			if IsValid(self.StandardModelView) then
				if not IsValid(self.StandardModelView:GetParent()) or self.StandardModelView:GetParent() ~= vm then
					self.StandardModelView:SetParent(vm)
					self.StandardModelView:AddEffects(EF_BONEMERGE)
				end
				self.StandardModelView:DrawModel()
			end
			if IsValid(self.MagModel) then
				if not IsValid(self.MagModel:GetParent()) or self.MagModel:GetParent() ~= vm then
					self.MagModel:SetParent(vm)
					self.MagModel:AddEffects(EF_BONEMERGE)
				end
				self.MagModel:DrawModel()
			end
		end
		
		if self.BaseViewModelDrawn then
			self:BaseViewModelDrawn(vm)
		end
	end
	
	function SWEP:OnRemove()
		if CLIENT then
			if IsValid(self.StandardModelView) then
				self.StandardModelView:Remove()
				self.StandardModelView = nil
			end
			if IsValid(self.MagModel) then
				self.MagModel:Remove()
				self.MagModel = nil
			end
		end
		
		if self.BaseOnRemove then
			self:BaseOnRemove()
		end
	end
end