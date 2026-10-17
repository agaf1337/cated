if SERVER then
	AddCSLuaFile()
SWEP.Spawnable = true
else
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_ins2_pm")
	killicon.AddFont("wep_jack_hmcd_pistol", "HL2MPTypeDeath", "1", Color(255, 0, 0))
end

SWEP.IconOverride = "kazoo/wep_daun_hmcd_pm.png"
SWEP.IconTexture = "vgui/hud/tfa_ins2_pm"
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "PM Makarov"
SWEP.Category = "HMCD: Union - Pistols"
SWEP.Instructions = "This is a non-lethal gas pistol with the ability to fire ammunition with rubber bullets.\n\nLMB to fire.\nRMB to aim.\nRELOAD to reload.\nShot placement counts.\nCrouching helps stability.\nBullets can ricochet."
SWEP.Primary.ClipSize = 9
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.ViewModel = "models/weapons/tfa_ins2/c_pm.mdl"
SWEP.WorldModel = "models/weapons/tfa_ins2/w_pm.mdl"
SWEP.ENT = "ent_jack_hmcd_makarov"
SWEP.HolsterSlot=2
SWEP.Damage = 11
SWEP.ShellType = ""
SWEP.DeathDroppable = false
SWEP.UseHands = true
SWEP.Category="HMCD: Union - Pistols"
SWEP.ViewModelFlip = false
SWEP.SprintPos = Vector(4, 0, -15)
SWEP.SprintAng = Angle(80, 0, 0)
--SWEP.SprintPos=Vector(0,20,0)
--SWEP.SprintAng=Angle(-90,90,0)
SWEP.AimPos = Vector(-2.15, 0, 0.5)
SWEP.FireAnim = "base_fire" .. math.random(2, 3) .. ""
SWEP.IronFireAnim = "iron_fire_" .. math.random(1, 3) .. ""
SWEP.LastIronFireAnim = "iron_fire_last"
SWEP.LastFireAnim = "base_firelast"
SWEP.DrawAnimEmpty = "empty_draw"
SWEP.DrawAnim = "base_draw"
SWEP.ReloadAnim = "base_reload_empty"
SWEP.TacticalReloadAnim = "base_reload"
--SWEP.CloseFireSound="m9/m9_fp.wav"
SWEP.CloseFireSound = "sounds_zcity/makarov/close.wav"
SWEP.FarFireSound = "m9/m9_dist.wav"
SWEP.HipFireInaccuracy = .04
SWEP.CarryWeight = 1200
SWEP.FuckedWorldModel = true
SWEP.Spawnable = true
SWEP.ReloadSound = ""
SWEP.AmmoType = "Pistol"
SWEP.MagEntity = "ent_jack_hmcd_makarychmag"
SWEP.ReloadTime = 4.2
SWEP.MagDelay = 1.5
SWEP.ReloadAdd = .7
SWEP.Traumatic = false
SWEP.FireAnimRate = 0.75
SWEP.ShellAttachment = 3
SWEP.MuzzleEffect = ""

SWEP.ReloadSounds = {
	{"weapons/tfa_ins2/pm/handling/makarov_magrelease.wav", 1.1, "Both"},
	{"weapons/tfa_ins2/pm/handling/makarov_magout.wav", 1.3, "Both"},
	{"weapons/tfa_ins2/pm/handling/makarov_magin.wav", 3.1, "Both"},
	{"weapons/tfa_ins2/pm/handling/makarov_maghit.wav", 3.3, "Both"},
	{"weapons/tfa_ins2/pm/handling/makarov_boltrelease.wav", 3.6, "EmptyOnly"}
}

SWEP.BulletDir = {400, 2, -1}

SWEP.Attachments = {
	["Owner"] = {
		["Magazine"] = {
			bone = "Bullet_1",
			pos = {
				right = -14,
				forward = 2.5,
				up = 1.5
			},
			ang = {
				up = -90
			},
			model = "models/weapons/tfa_ins2/upgrades/a_magazine_pm_8_phys.mdl"
		}
	},
	["Viewer"] = {
		["Weapon"] = {
			pos = {
				right = 1,
				up = -1,
				forward = 5
			},
			ang = {
				forward = 180,
				right = 10
			}
		},
		["Magazine"] = {
			model = "models/weapons/tfa_ins2/upgrades/a_magazine_pm_8_phys.mdl",
			pos = {
				forward = -10,
				up = -1.75,
				right = 3.5
			},
			ang = {
				right = 170,
				up = 180
			}
		}
	}
}

SWEP.MagazineModel = "models/weapons/tfa_ins2/upgrades/a_magazine_pm_8.mdl"
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
			self.DatWorldModel=ClientsideModel("models/weapons/tfa_ins2/w_pm.mdl")
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
		end
	end
	
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