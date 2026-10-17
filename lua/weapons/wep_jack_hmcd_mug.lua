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
SWEP.ViewModel = "models/weapons/combatknife/tactical_knife_iw7_vm.mdl"
SWEP.WorldModel = "models/props_junk/garbage_coffeemug001a.mdl"

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/mug")
	SWEP.BounceWeaponIcon = false
end

SWEP.IconOverride = "vgui/mug"
SWEP.IconTexture = "vgui/mug"
SWEP.PrintName = "Mug"
SWEP.Instructions = "A small mug typically used to hold liquids.\n\nLMB to attack."
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
SWEP.Damage = 15
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
SWEP.ENT = "ent_jack_hmcd_mug"
SWEP.DrawAnim = "vm_knifeonly_raise"
SWEP.CarryWeight = 1200
SWEP.BreakChance = 40
SWEP.BrokenWeapon = "wep_jack_hmcd_hands"
SWEP.UseHands = true
SWEP.AttackAnim = "vm_knifeonly_stab"
SWEP.ViewAttackAnimDelay = .1
SWEP.AttackFrontDelay = .4
SWEP.AttackPlayback = .95
SWEP.AttackAnimDelay = .1
SWEP.ViewPunch = Angle(0, 20, 0)
SWEP.HoldType = "knife"
SWEP.RunHoldType = "normal"

SWEP.HardImpactSounds = {
	{
		"physics/glass/glass_bottle_impact_hard1.wav", 0, 65, {100, 120}
	}
}

SWEP.SoftImpactSounds = {
	{
		"physics/glass/glass_bottle_impact_hard1.wav", 0, 60, {90, 110}
	}
}

SWEP.IdleAnim = "idle"
SWEP.DamageType = DMG_CLUB
SWEP.MinDamage = 25
SWEP.MaxDamage = 30
SWEP.ForceOffset = 1500
SWEP.DamageForceDiv = 5
SWEP.ReachDistance = 40

SWEP.WooshSound = {
	"weapons/iceaxe/iceaxe_swing1.wav", 65, {60, 70}
}

SWEP.ViewPunch = Angle(0, 3, 0)
SWEP.AttackDelay = 1
SWEP.PrehitViewPunchDelay = .1
SWEP.Force = 3500

function SWEP:PreDrawViewModel(vm, wep, ply)
	if IsValid(self:GetOwner():GetNWEntity("Ragdoll")) then return true end
	vm:SetSubMaterial(0, "engine/occlusionproxy")
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:SetupDataTables()
end

function SWEP:HandleBreak(impactPos)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	sound.Play("physics/glass/glass_pottery_break"..math.random(1,4)..".wav", impactPos, 80, math.random(90, 110))
	
	if owner:HasWeapon("wep_jack_hmcd_brassknuckles") then
		owner:SelectWeapon("wep_jack_hmcd_brassknuckles")
	else
		if not owner:HasWeapon("wep_jack_hmcd_hands") then
			owner:Give("wep_jack_hmcd_hands")
		end
		owner:SelectWeapon("wep_jack_hmcd_hands")
	end
	
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

		pos = pos - ang:Up() * self.DownAmt + ang:Right() * -3.5


		return pos, ang
	end

	function SWEP:ViewModelDrawn(vm)
		if not self.Snowball then
			self.Snowball = ClientsideModel(self.WorldModel)
			self.Snowball:SetPos(vm:GetPos())
			self.Snowball:SetParent(vm)
			self.Snowball:SetNoDraw(true)
		else
			local matr = vm:GetBoneMatrix(vm:LookupBone("ValveBiped.Bip01_R_Hand"))
			local pos, ang = matr:GetTranslation(), matr:GetAngles()
			ang:RotateAroundAxis(ang:Up(), -90)
			self.Snowball:SetRenderOrigin(pos + ang:Forward() * 1.5 + ang:Right() * -6)
			self.Snowball:SetRenderAngles(ang)
			self.Snowball:DrawModel()
		end
	end

	function SWEP:DrawWorldModel()
		local Pos, Ang = self:GetOwner():GetBonePosition(self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand"))

		if self.DatWorldModel then
			if Pos and Ang then
				self.DatWorldModel:SetRenderOrigin(Pos + Ang:Forward() * 6 + Ang:Right() * 1.5 - Ang:Up() * 1.5)
				Ang:RotateAroundAxis(Ang:Forward(), -80)
				Ang:RotateAroundAxis(Ang:Up(), -90)	
				Ang:RotateAroundAxis(Ang:Right(), 70)
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