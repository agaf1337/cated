if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
else
	killicon.AddFont("wep_jack_hmcd_assaultrifle", "HL2MPTypeDeath", "1", Color(255, 0, 0))
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_ins2_scar_h_ssr")
end

SWEP.IconOverride = "entities/tfa_ins2_scar_h_ssr_1.png"
SWEP.IconTexture = "vgui/hud/tfa_ins2_scar_h_ssr"
SWEP.IconLength = 3
SWEP.IconHeight = 2
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "FN SCAR 17"
SWEP.Instructions = "An absurdly powerful weapon, this aluminum/polymer 5.56x45mm semi-automatic home-assembled 30-round-capacity rifle is the quintessence of an armed American citizenry in the early 21st century.\n\nLMB to fire.\nRMB to aim.\nRELOAD to reload.\nShot placement counts.\nCrouching helps stability.\nBullets can ricochet and penetrate."
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.ViewModel = "models/weapons/c_ins2_fn_scar_h_ssr.mdl"
SWEP.WorldModel = "models/weapons/w_ins2_fn_scar_h_ssr.mdl"
SWEP.SwitchFM = false
SWEP.ViewModelFlip = false
SWEP.Damage = 30
SWEP.Category="HMCD: Union - Rifles"
SWEP.Primary.Automatic = true
SWEP.ViewModelFOV = 70
SWEP.SprintPos = Vector(10, 0, -3)
SWEP.SprintAng = Angle(-20, 40, -50)
SWEP.AimPos = Vector(-2.75, -1, 1.6)
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
SWEP.ENT = "ent_jack_hmcd_scar"
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
SWEP.CloseFireSound = "weapons/scar_ssr/fire.wav"
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
	{"weapons/scar_ssr/magout.wav", 0.9, "Both"},
	{"weapons/scar_ssr/magin.wav", 3.3, "Both"},
	{"weapons/scar_ssr/boltback.wav", 4.9, "EmptyOnly"},
	{"weapons/scar_ssr/boltrelease.wav", 5.5, "EmptyOnly"},
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