if SERVER then
	AddCSLuaFile()
SWEP.Spawnable = true
else
	killicon.AddFont("wep_jack_hmcd_pistol", "HL2MPTypeDeath", "1", Color(255, 0, 0))
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_ins2_fnp45")
end
SWEP.Spawnable = true

SWEP.IconOverride = "entities/tfa_ins2_fnp45_1.png"
SWEP.IconTexture = "vgui/hud/tfa_ins2_fnp45"
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "FN45"
SWEP.Instructions = "The FN FNX pistol is a series of semi-automatic, polymer-framed pistols manufactured in Columbia, South Carolina, by FN America (branded FNH USA), a division of Fabrique Nationale d'Herstal.[4] The pistol is chambered for the 9×19mm Parabellum, .40 S&W, and .45 ACP cartridges. Thats version chambered in .45 ACP"
SWEP.ViewModel = "models/weapons/c_ins2_pist_fnp45.mdl"
SWEP.WorldModel = "models/weapons/w_ins2_pist_fnp45.mdl"
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.ENT = "ent_jack_hmcd_fn"
SWEP.HolsterSlot = 2
SWEP.Damage = 25
SWEP.World_MuzzleAttachmentName="1"
SWEP.DrawAnim = "base_draw"
SWEP.DrawAnimEmpty = "empty_draw"
SWEP.UseHands = true
SWEP.ReloadAnim = "base_reloadempty"
SWEP.TacticalReloadAnim = "base_reload"
SWEP.FireAnim = "base_fire" .. math.random(1, 3) .. ""
SWEP.IronFireAnim = "iron_fire_" .. math.random(1, 3) .. ""
SWEP.TriggerDelay = .05
SWEP.AttBone = "glock in my rari"
SWEP.FuckedWorldModel = true
SWEP.Recoil = .5
SWEP.TPIK = false
SWEP.SwitchFM = false
SWEP.Supersonic = true
SWEP.AmmoType = "Pistol"
SWEP.LastFireAnim = "base_firelast"
SWEP.CanOneHanded=true
SWEP.LastIronFireAnim = "iron_firelast"
SWEP.ShellType = ""
SWEP.ShellDelay = 0
SWEP.Category="HMCD: Union - Pistols"
SWEP.DeathDroppable = false
SWEP.CloseFireSound = "weapons/fnp/fnp_fire.wav"
--SWEP.FarFireSound="snd_jack_hmcd_smp_far.wav"
SWEP.MuzzleEffectSuppressed = "pcf_jack_mf_suppressed"
--SWEP.SuppressedFireSound="snd_jack_hmcd_supppistol.wav"
--SWEP.CloseFireSound="m9/m9_fp.wav"
SWEP.FarFireSound = "m9/m9_dist.wav"
SWEP.SuppressedFireSound = "weapons/fnp/fnp_suppressed.wav"
SWEP.ReloadSound = ""
SWEP.ReloadTime = 3.6
SWEP.vbwPistol =true
SWEP.SprintPos = Vector(5, 0, -18)
SWEP.AimPos = Vector(-1.87, -2.1, 0.3)
SWEP.AltAimPos = Vector(2, -2.1, 1.1)
SWEP.HipFireInaccuracy = .04
SWEP.LaserAngle = Angle(180, 0, 0)
SWEP.CarryWeight = 1200
SWEP.MagDelay = .7
SWEP.MagEntity = "ent_jack_hmcd_glock17mag"

SWEP.MuzzlePos = {13.3, -4, 1.6}

SWEP.ViewModelFlip = false
SWEP.ReloadAdd = 0.7

SWEP.ReloadSounds = {
	{"weapons/fnp/fnp_magout.wav", 0.4, "Both"},
	{"weapons/fnp/fnp_magin.wav", 2.1, "Both"},
	{"weapons/fnp/fnp_maghit.wav", 2.9, "Both"},
	{"weapons/fnp/fnp_boltrelease.wav", 3.7, "EmptyOnly"},
}

SWEP.DeployVolume = 60

SWEP.BulletDir = {400, 1.3, -1}

SWEP.SuicidePos = Vector(1, 0, -20)
SWEP.SuicideAng = Angle(90, 0, 90)
SWEP.SuicideSuppr = Vector(4, 0, -8)

SWEP.MuzzleInfo = {
	["Bone"] = "A_Muzzle",
	["Offset"] = Vector(20, 2, -1)
}

SWEP.MagazineModel = "models/weapons/upgrades/a_magazine_fnp45_15.mdl"
SWEP.MagBone = "W_MAGAZINE"

if(CLIENT)then
	function SWEP:CreateModels()
		if CLIENT then
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
			if not IsValid(self.MagModel) and self.MagazineModel then
				self:CreateModels()
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