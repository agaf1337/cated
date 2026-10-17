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
SWEP.Base = "weapon_base"
SWEP.ViewModel = "models/weapons/winterland/v_snowball.mdl"
SWEP.WorldModel = "models/weapons/winterland/w_snowball.mdl"

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/wep_jack_hmcd_snowball")
	SWEP.BounceWeaponIcon = false
end

SWEP.IconTexture = "vgui/wep_jack_hmcd_snowball"
SWEP.PrintName = "Snowball"
SWEP.Instructions = "This is a spherical object made from snow.\n\nLMB to throw."
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.BobScale = 3
SWEP.SwayScale = 3
SWEP.Weight = 3
SWEP.Category="HMCD: Union - Other"
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false
SWEP.ViewModelFlip = false
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 3
SWEP.Primary.Damage = 120
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
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.HomicideSWEP = true
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.ENT = "ent_jack_hmcd_snowball"
SWEP.DrawAnim = "draw"
SWEP.CarryWeight = 100
SWEP.UseHands = true
SWEP.HoldType = "grenade"
SWEP.RunHoldType = "normal"
SWEP.IdleAnim = "idle"
SWEP.PrepareAnim = "fire"
SWEP.ThrowAnim = "fire2"

function SWEP:Deploy()
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(self.DrawAnim)

		return
	end

	if self.DownAmt then
		self.DownAmt = 20
	end

	self:DoBFSAnimation(self.DrawAnim)

	return true
end

function SWEP:DoBFSAnimation(anim)
	if self:GetOwner() and self:GetOwner().GetViewModel then
		local vm = self:GetOwner():GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
		self.NextIdle = CurTime() + vm:SequenceDuration() * vm:GetPlaybackRate()
	end
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:SetupDataTables()
end

function SWEP:ThrowGrenade()
	if CLIENT then return end
	self:GetOwner():SetLagCompensated(true)
	self.CommandDroppable = false
	local Grenade = ents.Create("ent_jack_hmcd_snowball")
	Grenade.HmcdSpawned = self.HmcdSpawned
	Grenade:SetAngles(VectorRand():Angle())
	Grenade:SetPos(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 1)
	Grenade.Owner = self:GetOwner()
	Grenade.Thrown = true
	Grenade.CollisionGroup = COLLISION_GROUP_NONE
	Grenade:Spawn()
	Grenade:Activate()
	Grenade:Throw()
	Grenade.InitialDir = self:GetOwner():GetAimVector()
	Grenade:GetPhysicsObject():SetVelocity(self:GetOwner():GetVelocity() + self:GetOwner():GetAimVector() * 750)
	self:GetOwner():SetLagCompensated(false)

	timer.Simple(.1, function()
		if IsValid(self) then
			self:Remove()
		end
	end)
end

function SWEP:OnRemove()
	if IsValid(self:GetOwner()) and CLIENT then
		local vm = self:GetOwner():GetViewModel()

		if IsValid(vm) then
			vm:SetSubMaterial(0, "")
		end
	end
end

function SWEP:Holster(newWep)
	if IsValid(self:GetOwner()) and CLIENT then
		local vm = self:GetOwner():GetViewModel()

		if IsValid(vm) then
			vm:SetSubMaterial(0, "")
		end
	end

	return true
end

function SWEP:OnDrop()
	local owner = self:GetOwner()

	if self.IsUnfaking then return end
	if IsValid(owner) and owner.IsUnfaking then return end

	local Ent = ents.Create(self.ENT)
	Ent.HmcdSpawned = self.HmcdSpawned
	Ent:SetPos(self:GetPos())
	Ent:SetAngles(self:GetAngles())
	Ent:Spawn()
	Ent:Activate()
	if IsValid(Ent:GetPhysicsObject()) then
		Ent:GetPhysicsObject():SetVelocity(self:GetVelocity() / 2)
	end
	self:Remove()
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end

	self:DoBFSAnimation(self.PrepareAnim)
	self:GetOwner():GetViewModel():SetPlaybackRate(.5)

	timer.Simple(.3, function()
		self.Prepared = true
	end)

	self:SetNextPrimaryFire(CurTime() + 5)
	self:SetNextSecondaryFire(CurTime() + 5)
end

function SWEP:SecondaryAttack()
end

--
function SWEP:Think()
	if self.Prepared and not self:GetOwner():KeyDown(IN_ATTACK) then
		if SERVER then
			self.Prepared = false
			self:GetOwner():ViewPunch(Angle(-10, -5, 0))
			sound.Play("weapons/m67/m67_throw_01.wav", self:GetPos(), 100, 100)
			self:DoBFSAnimation(self.ThrowAnim)

			timer.Simple(.3, function()
				self:GetOwner():ViewPunch(Angle(20, 10, 0))
				self:ThrowGrenade()
			end)
		end

		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	end

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
