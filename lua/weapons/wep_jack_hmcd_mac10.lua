if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
else
	killicon.AddFont("wep_jack_hmcd_assaultrifle", "HL2MPTypeDeath", "1", Color(255, 0, 0))
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/zmirli/raw_mac10")
end

SWEP.IconOverride = "entities/tfa_zmr_mac10.png"
SWEP.IconTexture = "vgui/zmirli/raw_mac10"
SWEP.IconHeight = 2
SWEP.IconLength = 3
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "MAC-10"
SWEP.Instructions = "Compact submachine gun chambered in .45 ACP.\n\nExtremely high rate of fire.\nA lead hose effective at point-blank range but difficult to control."
SWEP.Primary.ClipSize = 32
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.ViewModel = "models/weapons/tfa/zmirli/c_mac10.mdl"
SWEP.WorldModel = "models/weapons/tfa/zmirli/w_mac10.mdl"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.Primary.Automatic = true
SWEP.Damage = 30
SWEP.ShellType = ""
SWEP.FuckedWorldModel = true
SWEP.CanOneHanded=true
SWEP.SprintPos = Vector(5, 0, -3)
SWEP.SprintAng = Angle(-30, 30, -60)
SWEP.AimPos = Vector(-3.14, -1, 1.7)
SWEP.AltAimPos = Vector(2, -1, 0.75)
SWEP.CloseAimPos = Vector(.45, 0, 0)
SWEP.ReloadTime = 2.6
SWEP.ReloadAdd = 2
SWEP.ReloadRate = .69 //6sixnine9
SWEP.ReloadAnim = "reload_empty"
SWEP.TacticalReloadAnim = "reload_tactic"
SWEP.FireAnim = "fire01"
SWEP.IronFireAnim = "fire01_ironsights"
SWEP.AmmoType = "Pistol"
SWEP.TriggerDelay = .055
SWEP.CycleTime = 0
SWEP.Recoil = .6
SWEP.Supersonic = true
SWEP.DrawAnim = "draw"
SWEP.Accuracy = .99
SWEP.Category="HMCD: Union - SMG"
SWEP.ShotPitch = 100
SWEP.ENT = "ent_jack_hmcd_mac10"
SWEP.DeathDroppable = false
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.CloseFireSound = "weapons/zmirli/mac10/mac10_fire01.mp3"
SWEP.FarFireSound = "mp5k/mp5k_dist.wav"
SWEP.SuppressedFireSound = "mp5k/mp5k_suppressed_fp.wav"
SWEP.BarrelLength = 10
SWEP.AimTime = 6
SWEP.BearTime = 7
SWEP.HipHoldType = "revolver"
SWEP.AimHoldType = "revolver"
SWEP.DownHoldType = "normal"
SWEP.HipFireInaccuracy = .05
SWEP.HolsterSlot=1
SWEP.HolsterPos=Vector(3,-7,-4)
SWEP.HolsterAng=Angle(160,5,180)
SWEP.CarryWeight = 3000
SWEP.NextFireTime = 0
SWEP.InsHands = true

SWEP.MuzzleInfo = {
	["Bone"] = "A_Muzzle",
	["Offset"] = Vector(7, -33, -6)
}

SWEP.SuicidePos = Vector(5, 7, -25)
SWEP.SuicideAng = Angle(110, 2, 90)
SWEP.SuicideSuppr = Vector(0, 4.5, -9.5)
SWEP.SuicideTime = 10
SWEP.SuicideType = "SMG"

SWEP.ReloadSounds = {
	{"weapons/zmirli/mac10/mac10_magout.wav", 1, "FullOnly"},
	{"weapons/zmirli/mac10/mac10_magin.wav", 2.25, "FullOnly"},
	{"weapons/tfa_ins2/mp5a4/mp5k_boltback.wav", .5, "EmptyOnly"},
	{"weapons/tfa_ins2/mp5a4/mp5k_boltlock.wav", .85, "EmptyOnly"},
	{"weapons/zmirli/mac10/mac10_magout.wav", 2.2, "EmptyOnly"},
	{"weapons/zmirli/mac10/mac10_boltpull.wav", 3, "EmptyOnly"},
}

SWEP.MagEntity = "ent_jack_hmcd_mac10mag"
SWEP.MagDelay = 1

SWEP.MuzzlePos = {15, -6, 1}

SWEP.ShellAttachment = 2

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()
    local scale = self.WorldModelScale or Vector(1, 1, 1)
    local mat = Matrix()
    mat:Scale(scale)
    self:EnableMatrix("RenderMultiply", mat)

    if not IsValid(ply) or not ply:Alive() then
        self:SetRenderOrigin(nil)
        self:SetRenderAngles(nil)
        self:DrawModel()
        return
    end

    local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
    if not bone then
        self:DrawModel()
        return
    end

    local pos, ang = ply:GetBonePosition(bone)
    pos = pos + ang:Forward() * 4
    pos = pos + ang:Right() * 0.6
    pos = pos + ang:Up() * -3.2

    ang:RotateAroundAxis(ang:Up(), 0)
    ang:RotateAroundAxis(ang:Right(), 0)
    ang:RotateAroundAxis(ang:Forward(), 180)

    self:SetRenderOrigin(pos)
    self:SetRenderAngles(ang)
    self:DrawModel()
end
