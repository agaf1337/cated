if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
elseif CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 70
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
SWEP.Base = "wep_jack_hmcd_melee_base"
SWEP.ViewModel = "models/weapons/db2020/c_db2020.mdl"
SWEP.WorldModel = "models/weapons/db2020/w_db2020.mdl"

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_nmrih_crowbar")
	SWEP.BounceWeaponIcon = false
end

SWEP.IconOverride = "kazoo/wep_mann_hmcd_crowbar.png"
SWEP.PrintName = "DB 2020"
SWEP.Instructions = 'The hammer is coated with urethane which provides a "thud" using steel balls to cushion the impact and reduce the vibration recoil to the handle.' 
SWEP.IconTexture = "vgui/hud/tfa_nmrih_crowbar"
SWEP.IconLength = 2
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.BobScale = 3
SWEP.SwayScale = 3
SWEP.Weight = 1113
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.Category="HMCD: Union - Melee"
SWEP.Spawnable = true
SWEP.BreakDoorChance = 1
SWEP.CanBreakDoors = true
SWEP.AdminOnly = false
SWEP.Primary.Delay = 0.9
SWEP.Primary.Recoil = 3
SWEP.Primary.Damage = 5
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
SWEP.ENT = ""
SWEP.BloodDecals = 4
SWEP.DeathDroppable = false
SWEP.HomicideSWEP = true
SWEP.CarryWeight = 6000
SWEP.UseHands = true
SWEP.DangerLevel = 100
SWEP.HoldType = "melee2"
SWEP.RunHoldType = "normal"
SWEP.AttackAnim = "Swing1"
SWEP.ViewAttackAnimDelay = .1
SWEP.AttackFrontDelay = .6
SWEP.PrehitViewPunchDelay = .1
SWEP.IdleAnim = "idle01"
SWEP.AttackAnimDelay = .1
SWEP.AttackDelay = 1.25
SWEP.DrawAnim = "draw"

SWEP.DrawSound = {
	"Wood_Plank.ImpactSoft", 65, {90, 110}
}

SWEP.WooshSound = {
	"weapons/db2020/sledge_swing_miss2.wav", 65, {100, 110}
}

SWEP.ViewPunch = Angle(10, 30, -10)
SWEP.ReachDistance = 90
SWEP.Force = 250
SWEP.ArmorMul = .3

SWEP.SoftImpactSounds = {
	{
		"weapons/db2020/blunt/blunt_01.wav", 1, 65, {90, 110}
	},
	{
		"weapons/db2020/blunt/blunt_02.wav", 0, 65, {90, 110}
	},
	{
		"weapons/db2020/blunt/blunt_03.wav", -1, 65, {90, 110}
	}
}

SWEP.HardImpactSounds = {
	{
		"weapons/db2020/blunt/blunt_01.wav", 1, 65, {90, 110}
	},
	{
		"weapons/db2020/blunt/blunt_02.wav", 0, 65, {90, 110}
	},
	{
		"weapons/db2020/blunt/blunt_03.wav", -1, 65, {90, 110}
	}
}

SWEP.AttackPlayback = 1.2
SWEP.MinDamage = 45
SWEP.MaxDamage = 50
SWEP.DamageForceDiv = 5
SWEP.ForceOffset = 5500
SWEP.DamageType = DMG_CLUB
SWEP.PrehitViewPunch = Angle(0, -30, 5)

function SWEP:Initialize()
	timer.Simple(.1, function()
		if IsValid(self:GetOwner()) and string.find(self:GetOwner():GetModel(), "freeman") then
			self.AttackPlayback = self.AttackPlayback * 1.5
			self.AttackFrontDelay = self.AttackFrontDelay / 2
			self.AttackDelay = self.AttackDelay / 2
		end
	end)
end

SWEP.ViewModelFOV = 90
if CLIENT then
	local DownAmt = 0

	function SWEP:GetViewModelPosition(pos, ang)
		if self:GetOwner():KeyDown(IN_SPEED) then
			DownAmt = math.Clamp(DownAmt + .2, 0, 50)
		else
			DownAmt = math.Clamp(DownAmt - .2, 0, 10)
		end

		return pos - ang:Up() * DownAmt + ang:Right() * 0 + ang:Forward() * -3 + ang:Up() * -1, ang
	end

	function SWEP:DrawWorldModel()
		local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))

		if self.DatWorldModel then
			if Pos and Ang then
				self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 2.5 + Ang:Right() * -0.5 + Ang:Up() * -1)
				Ang:RotateAroundAxis(Ang:Right(), -90)
				Ang:RotateAroundAxis(Ang:Forward(), -90)
				Ang:RotateAroundAxis(Ang:Up(), -10)
				self.DatWorldModel:SetRenderAngles(Ang)
				self.DatWorldModel:DrawModel()
			end
		else
			self.DatWorldModel = ClientsideModel(self.WorldModel)
			self.DatWorldModel:SetPos(self:GetPos())
			self.DatWorldModel:SetParent(self)
			self.DatWorldModel:SetNoDraw(true)
		end
	end
end