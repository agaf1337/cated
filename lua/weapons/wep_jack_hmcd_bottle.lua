if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
elseif CLIENT then
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 70
	SWEP.Slot = 4
	SWEP.SlotPos = 3
	killicon.AddFont("wep_jack_hmcd_molotov", "HL2MPTypeDeath", "5", Color(0, 0, 255, 255))

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
SWEP.ViewModel = "models/weapons/hl2meleepack/v_bottle.mdl"
SWEP.WorldModel = "models/props_junk/garbage_glassbottle003a.mdl"

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/bottle")
	SWEP.BounceWeaponIcon = false
end

SWEP.IconOverride = "vgui/bottle"
SWEP.IconTexture = "vgui/bottle"
SWEP.PrintName = "Bottle"
SWEP.Instructions = "Just an ordinary beer bottle, the perfect murder weapon for any drunk..."
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.BobScale = 3
SWEP.SwayScale = 3
SWEP.Weight = 3
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.ViewModelFlip = false
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 3
SWEP.Primary.Damage = 30
SWEP.Damage = 65
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.04
SWEP.Primary.ClipSize = -1
SWEP.Primary.Force = 900
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Category="HMCD: Union - Melee"
SWEP.Spawnable = true
SWEP.Secondary.Delay = 0.9
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Damage = 0
SWEP.Secondary.NumShots = 1
SWEP.Secondary.Cone = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.HomicideSWEP = true
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.ENT = "ent_jack_hmcd_bottle"
SWEP.DrawAnim = "draw"
SWEP.CarryWeight = 1200
SWEP.BreakChance = 45
SWEP.BrokenWeapon = "wep_jack_hmcd_bottlebroken"
SWEP.UseHands = true
SWEP.AttackAnim = "misscenter1"
SWEP.ViewAttackAnimDelay = .1
SWEP.AttackFrontDelay = .4
SWEP.AttackPlayback = .75
SWEP.AttackAnimDelay = .1
SWEP.ViewPunch = Angle(0, 20, 0)
SWEP.HoldType = "grenade"
SWEP.RunHoldType = "normal"

SWEP.HardImpactSounds = {
	{
		"GlassBottle.ImpactHard", 1, 65, {90, 110}
	},
	{
		"GlassBottle.ImpactHard", 0, 65, {90, 110}
	},
	{
		"GlassBottle.ImpactHard", -1, 65, {90, 110}
	},
}

SWEP.SoftImpactSounds = {
	{
		"GlassBottle.ImpactHard", 1, 65, {90, 110}
	},
	{
		"GlassBottle.ImpactHard", 0, 65, {90, 110}
	},
	{
		"GlassBottle.ImpactHard", -1, 65, {90, 110}
	},
	{
		"Flesh.ImpactHard", 0, 65, {90, 110}
	}
}

SWEP.IdleAnim = "idle01"
SWEP.DamageType = DMG_CLUB
SWEP.MinDamage = 30
SWEP.MaxDamage = 40
SWEP.ForceOffset = 1500
SWEP.DamageForceDiv = 5
SWEP.ReachDistance = 40

SWEP.WooshSound = {
	"weapons/iceaxe/iceaxe_swing1.wav", 65, {60, 70}
}

SWEP.PrehitViewPunch = Angle(0, -10, 0)
SWEP.AttackDelay = 1
SWEP.PrehitViewPunchDelay = .1
SWEP.Force = 3500

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:SetupDataTables()
end

function SWEP:CreateGlassShards(pos)
	if CLIENT then return end
	
	for i = 1, 2 do
		local bottle = ents.Create("prop_physics")
		bottle:SetPos(pos + VectorRand(-5, 5))
		bottle:SetAngles(AngleRand(-90, 90))
		bottle:SetModel("models/props_junk/garbage_glassbottle003a_chunk0"..math.random(2,3)..".mdl")
		bottle:Spawn()
		bottle:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
		local phys = bottle:GetPhysicsObject()
		if IsValid(phys) then
			phys:AddVelocity(VectorRand(-100, 100))
			phys:Wake()
		end
		
		SafeRemoveEntityDelayed(bottle, 15)
	end
end

function SWEP:HandleBreak(impactPos)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	self:CreateGlassShards(impactPos)
	sound.Play("physics/glass/glass_pottery_break"..math.random(1,4)..".wav", impactPos, 80, math.random(90, 110))
	owner:Give(self.BrokenWeapon)
	owner:SelectWeapon(self.BrokenWeapon)
	self:Remove()
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	self:GetOwner():GetViewModel():SetPlaybackRate(.5)
	timer.Simple(.3, function()
		self.Prepared = true
	end)
	self:SetNextPrimaryFire(CurTime() + 5)
	self:SetNextSecondaryFire(CurTime() + 5)
end

function SWEP:AttackFront()
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	local Ent, HitPos, HitNorm, Hitbox = HMCD_WhomILookinAt(owner, 0.02, self.ReachDistance)
	if IsValid(Ent) or (Ent and Ent.IsWorld and Ent:IsWorld()) then
		self.BaseClass.AttackFront(self)
		
		if math.random(1, 100) <= self.BreakChance then
			timer.Simple(0.2, function()
				if IsValid(self) then
					self:HandleBreak(HitPos)
				end
			end)
			return
		end
	else
		self.BaseClass.AttackFront(self)
	end
end

function SWEP:Think()
	if SERVER then
		local HoldType = self.HoldType
		if self:GetOwner():KeyDown(IN_SPEED) then
			HoldType = self.RunHoldType
		end
		self:SetHoldType(HoldType)
		if self.NextAttackFront and self.NextAttackFront < CurTime() then
			self:AttackFront()
		end
	end
end

if CLIENT then
	local DownAmt = 0

	function SWEP:GetViewModelPosition(pos, ang)
		if not self.DownAmt then
			self.DownAmt = 0
		end

		if self:GetOwner():KeyDown(IN_SPEED) then
			self.DownAmt = math.Clamp(self.DownAmt + .1, 0, 20)
		else
			self.DownAmt = math.Clamp(self.DownAmt - .15, 0, 60)
		end

		pos = pos - ang:Up() * self.DownAmt

		return pos, ang
	end

	function SWEP:DrawWorldModel()
		local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))

		if self.DatWorldModel then
			if Pos and Ang then
				self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 3.5 + Ang:Right() * 2.5 - Ang:Up() * 1)
				Ang:RotateAroundAxis(Ang:Right(), 0)
				Ang:RotateAroundAxis(Ang:Right(), 90)
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