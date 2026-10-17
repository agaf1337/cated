if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
else
	killicon.AddFont("wep_jack_hmcd_assaultrifle", "HL2MPTypeDeath", "1", Color(255, 0, 0))
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_kopter_pkm")
end

SWEP.IconOverride = "entities/tfa_kopter_pkm.png"
SWEP.IconTexture = "vgui/hud/tfa_kopter_pkm"
SWEP.IconLength = 3
SWEP.IconHeight = 2
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "PKM"
SWEP.Instructions = "This is a gas-operated, air-cooled, belt-fed, automatic weapon that fires 5.56x45mm rounds.\n\nLMB to fire.\nRMB to aim.\nRELOAD to reload.\nShot placement counts.\nCrouching helps stability.\nBullets can ricochet and penetrate."
SWEP.Primary.DefaultClip = 200
SWEP.Primary.ClipSize = 200
SWEP.ViewModel = "models/weapons/tfa_gamebanana/c_mach_pkm.mdl"
SWEP.WorldModel = "models/weapons/tfa_gamebanana/w_mach_pkm.mdl"
SWEP.ViewModelFlip = false
SWEP.Damage = 90
SWEP.ViewModelFOV = 70
SWEP.Primary.Automatic = true
SWEP.SprintPos = Vector(6, 5, 3)
SWEP.SprintAng = Angle(-30, 60, 0)
SWEP.AimPos = Vector(-2.77, -1, 0.45)
SWEP.CloseAimPos = Vector(.45, 0, 0)
SWEP.AltAimPos = Vector(-1.902, -3.2, .13)
SWEP.ReloadTime = 6.56
SWEP.ReloadRate = 1
SWEP.UseHands = true
SWEP.ReloadSound = "snd_jack_hmcd_arreload.wav"
SWEP.AmmoType = "SMG1"
SWEP.TriggerDelay = .059
SWEP.CycleTime = 0
SWEP.Recoil = .75
SWEP.AttBone = "LidCont"
SWEP.Category="HMCD: Union - Machine Guns"
SWEP.Supersonic = true
SWEP.Accuracy = .999
SWEP.ShotPitch = 100
SWEP.ENT = "ent_jack_hmcd_pkm"
SWEP.FuckedWorldModel = true
SWEP.DeathDroppable = false
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.CycleType = "auto"
SWEP.ReloadType = "magazine"
SWEP.DrawAnim = "draw"
SWEP.FireAnim = "shoot1"
SWEP.IronFireAnim = "shoot2"
SWEP.BipodFireAnim ="shoot1"
SWEP.BipodIronFireAnim ="shoot1"
SWEP.ReloadAnimEmpty = "reload"
SWEP.ReloadAnim = "reload"
SWEP.ReloadAnimHalf = "reload"
SWEP.BipodReloadAnimEmpty = "reload"
SWEP.BipodReloadAnim = "reload"
SWEP.BipodReloadAnimHalf = "reload"
SWEP.CloseFireSound = "sounds_zcity/m249/close.wav"
SWEP.ShellAttachment = 2
SWEP.FarFireSound = "m249/m249_dist.wav"
SWEP.SuppressedFireSound = "m249/m249_suppressed_fp.wav"
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
SWEP.HolsterPos=Vector(4,-9,-4)
SWEP.HolsterAng=Angle(160,10,190)
SWEP.CarryWeight = 6000
SWEP.ScopeDotPosition = Vector(0, 0, 0)
SWEP.ScopeDotAngle = Angle(0, 0, 0)
SWEP.NextFireTime = 0
SWEP.ShellEffect = "eff_jack_hmcd_76239"
SWEP.ShellEffect2 = false
SWEP.InsHands = true

SWEP.MuzzlePos = {25.5, -5.1 - 4.1}

SWEP.BulletDir = {400, 2, -1.5}

SWEP.BipodUsable = false

SWEP.BipodDeploySound = {.5, "weapons/m249/handling/m249_bipoddeploy.wav"}

SWEP.BipodRemoveSound = {.5, "weapons/m249/handling/m249_bipodretract.wav"}

SWEP.BipodOffset = 10
SWEP.BipodAimOffset = Vector(0, 2.05, -0.95)
SWEP.SuicidePos = Vector(3.5, 6.5, -39)
SWEP.SuicideAng = Angle(100, 0, 90)
SWEP.SuicideTime = 10
SWEP.SuicideType = "Rifle"

SWEP.MuzzleInfo = {
	["Bone"] = "A_Muzzle",
	["Offset"] = Vector(37, 2, 20)
}

SWEP.ReloadSounds = {
	{"weapons/pkm/coverup.wav", 0.8, "Both"},
	{"weapons/pkm/bullet.wav", 1.3, "Both"},
	{"weapons/pkm/boxout.wav", 2.4, "Both"},
	{"weapons/pkm/boxin.wav", 3.5, "Both"},
	{"weapons/pkm/chain.wav", 4.2, "Both"},
	{"weapons/pkm/coverdown.wav", 4.8, "Both"},
	{"weapons/pkm/coversmack.wav", 5.05, "Both"},
	{"weapons/pkm/bolt.wav", 5.8, "Both"},
}

SWEP.Attachments = {
	["Owner"] = {
		["Suppressor"] = {
			bone = "A_Suppressor",
			pos = {
				right = 11,
				forward = -2.05,
				up = -0.05
			},
			ang = {
				up = 180,
				right = 90
			},
			scale = .7,
			model = "models/cw2/attachments/556suppressor.mdl",
			num = HMCD_RIFLESUPP
		},
		["Laser"] = {
			bone = "LidCont",
			pos = {
				right = -4,
				forward = -0.2,
				up = 0.3
			},
			ang = {
				up = 90
			},
			scale = .5,
			model = "models/cw2/attachments/anpeq15.mdl",
			aimpos = Vector(-2.05, -1.5, 0.25),
			bipodpos = Vector(0, 2, -0.2),
			num = HMCD_LASERBIG
		},
		["Sight"] = {
			bone = "LidCont",
			pos = {
				right = -3,
				forward = -0.2,
				up = 0.5
			},
			ang = {
				up = 270
			},
			scale = .7,
			model = "models/weapons/tfa_ins2/upgrades/a_optic_kobra.mdl",
			sightpos = {
				right = 9.15,
				forward = -0.3,
				up = 1.45
			},
			sightang = {
				up = -90
			},
			aimpos = Vector(-1.95, -1.5, 0.25),
			bipodpos = Vector(0, 2, -0.2),
			num = HMCD_KOBRA
		},
		["Sight2"] = {
			bone = "LidCont",
			pos = {
				right = -3.2,
				forward = -0.2,
				up = 0.5
			},
			ang = {
				up = 270
			},
			scale = .7,
			model = "models/weapons/tfa_ins2/upgrades/a_optic_aimpoint.mdl",
			sightpos = {
				right = 9.15,
				forward = -0.3,
				up = 1.5
			},
			sightang = {
				up = -90
			},
			aimpos = Vector(-1.95, -1.5, 0.17),
			bipodpos = Vector(0, 2, -.05),
			num = HMCD_AIMPOINT
		},
		["Sight3"] = {
			bone = "LidCont",
			pos = {
				right = -3.2,
				forward = -0.2,
				up = 0.5
			},
			ang = {
				up = 270
			},
			scale = .7,
			model = "models/weapons/tfa_ins2/upgrades/a_optic_eotech.mdl",
			sightpos = {
				right = 9.15,
				forward = -0.3,
				up = 1.55
			},
			sightang = {
				up = -90
			},
			aimpos = Vector(-1.95, -1.5, 0.15),
			bipodpos = Vector(0, 2, -.05),
			num = HMCD_EOTECH
		}
	},
	["Viewer"] = {
		["Weapon"] = {
			pos = {
				right = 1,
				forward = 5,
				up = -1
			},
			ang = {
				forward = 180,
			}
		},
		["Suppressor"] = {
			pos = {
				forward = 13.5,
				up = -7.4,
				right = 1.1
			},
			ang = {
				right = 270,
				up = 90,
				forward = 270
			},
			scale = .9,
			model = "models/cw2/attachments/556suppressor.mdl"
		},
		["Laser"] = {
			pos = {
				forward = 7,
				up = -6.4,
				right = 1.2
			},
			ang = {
				forward = 180,
				up = 180
			},
			scale = .9,
			model = "models/cw2/attachments/anpeq15.mdl"
		},
		["Sight"] = {
			pos = {
				forward = 6,
				up = -6.4,
				right = 1
			},
			ang = {
				forward = 180
			},
			scale = .9,
			model = "models/weapons/tfa_ins2/upgrades/a_optic_kobra.mdl"
		},
		["Sight2"] = {
			pos = {
				forward = 6,
				up = -6.6,
				right = 1
			},
			ang = {
				forward = 180
			},
			scale = .9,
			model = "models/weapons/tfa_ins2/upgrades/a_optic_aimpoint.mdl"
		},
		["Sight3"] = {
			pos = {
				forward = 6,
				up = -6.6,
				right = 1
			},
			ang = {
				forward = 180
			},
			scale = .9,
			model = "models/weapons/tfa_ins2/upgrades/a_optic_eotech.mdl"
		}
	}
}