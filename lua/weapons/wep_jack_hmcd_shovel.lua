if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
elseif CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	killicon.AddFont("wep_jack_hmcd_baseballbat", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

	function SWEP:Initialize()
	end

	--wat
	function SWEP:DrawViewModel()
		return false
	end

	function SWEP:DrawWorldModel()
		self:DrawModel()
	end

	function SWEP:DrawHUD()
	end
end

--
SWEP.IconTexture = "vgui/shovel"
SWEP.IconLength = 2
SWEP.Base = "wep_jack_hmcd_melee_base"
SWEP.ViewModel = "models/weapons/hl2meleepack/v_shovel.mdl"
SWEP.WorldModel = "models/props_junk/Shovel01a.mdl"

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/shovel")
	SWEP.BounceWeaponIcon = false
end

SWEP.IconOverride = "entities/ent_jack_gmod_ezshovel.png"
SWEP.PrintName = "Shovel"
SWEP.Instructions = "A shovel may be big and slow but it can pack a punch."
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.BobScale = 3
SWEP.SwayScale = 1
SWEP.Weight = 3
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.Spawnable = true
SWEP.Category="HMCD: Union - Melee"
SWEP.AdminOnly = false
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 3
SWEP.Primary.Damage = 85
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.04
SWEP.Primary.ClipSize = -1
SWEP.Primary.Force = 900
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Spawnable = true
SWEP.Secondary.Delay = 0.9
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Damage = 0
SWEP.Secondary.NumShots = 1
SWEP.Secondary.Cone = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ENT = "ent_jack_hmcd_shovel"
SWEP.DeathDroppable = false
SWEP.HomicideSWEP = true
SWEP.CarryWeight = 4000
SWEP.UseHands = true
--
SWEP.HoldType = "melee2"
SWEP.RunHoldType = "normal"
SWEP.AttackAnim = "misscenter1"
SWEP.ViewAttackAnimDelay = .1
SWEP.AttackFrontDelay = .4
SWEP.PrehitViewPunchDelay = .1
SWEP.IdleAnim = "Idle01"
SWEP.AttackAnimDelay = .1
SWEP.AttackDelay = 1
SWEP.DrawAnim = "Draw"
SWEP.ViewModelFOV = 50

SWEP.DrawSound = {
	"SolidMetal.ImpactSoft", 65, {90, 110}
}

SWEP.WooshSound = {
	"weapons/iceaxe/iceaxe_swing1.wav", 65, {60, 70}
}

SWEP.ViewPunch = Angle(0, 20, 0)
SWEP.ReachDistance = 70
SWEP.Force = 150
SWEP.ArmorMul = .45

SWEP.SoftImpactSounds = {
	{
		"Flesh.ImpactHard", 1, 65, {90, 110}
	},
	{
		"Flesh.ImpactHard", 0, 65, {90, 110}
	},
	{
		"Flesh.ImpactHard", -1, 65, {90, 110}
	}
}

SWEP.HardImpactSounds = {
	{
		"Canister.ImpactHard", 0, 65, {90, 110}
	},
	{
		"Canister.ImpactHard", 0, 65, {90, 110}
	}
}

SWEP.UniversalSound = {
	"Canister.ImpactHard", 0, 65, {90, 110}
}

SWEP.AttackPlayback = 1
SWEP.MinDamage = 25
SWEP.MaxDamage = 30
SWEP.DamageForceDiv = 5
SWEP.ForceOffset = 4500
SWEP.DamageType = DMG_CLUB
SWEP.PrehitViewPunch = Angle(0, -10, 0)
SWEP.ReachDistance = 75
SWEP.CanUpdateIdle = true

if CLIENT then
	local DownAmt = 0

	function SWEP:GetViewModelPosition(pos, ang)
		if self:GetOwner():KeyDown(IN_SPEED) then
			DownAmt = math.Clamp(DownAmt + .2, 0, 50)
		else
			DownAmt = math.Clamp(DownAmt - .2, 0, 10)
		end

		ang:RotateAroundAxis(ang:Forward(), 0)

		return pos - ang:Up() * DownAmt + ang:Right() * -1 + ang:Forward() * -1 + ang:Up() * 4, ang
	end

	function SWEP:DrawWorldModel()
		if 1 then
			if not self.WModel then
				self.WModel = ClientsideModel(self.WorldModel)
				self.WModel:SetPos(self:GetOwner():GetPos())
				self.WModel:SetParent(self:GetOwner())
				self.WModel:SetNoDraw(true)
			else
				local pos, ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))

				if pos and ang then
					self.WModel:SetRenderOrigin(pos + ang:Right() + ang:Up() * -1 + ang:Forward() * 3 + ang:Right() * 2.5)
					ang:RotateAroundAxis(ang:Forward(), 7)
					ang:RotateAroundAxis(ang:Up(), 90)
					self.WModel:SetRenderAngles(ang)
					self.WModel:DrawModel()
				end
			end
		end
	end
end