if SERVER then
	AddCSLuaFile()
SWEP.Spawnable = true
else
	killicon.AddFont("wep_jack_hmcd_pistol", "HL2MPTypeDeath", "1", Color(255, 0, 0))
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_ins2_deagle")
end
SWEP.Spawnable = true

SWEP.IconOverride = "entities/tfa_ins2_deagle.png"
SWEP.IconTexture = "vgui/hud/tfa_ins2_deagle"
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "Desert Eagle"
SWEP.Instructions = "Pistol chambered in .50 Magnum"
SWEP.ViewModel = "models/weapons/tfa_ins2/c_deagle.mdl"
SWEP.WorldModel = "models/weapons/tfa_ins2/w_deagle.mdl"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.ENT = "ent_jack_hmcd_deagle"
SWEP.HolsterSlot = 2
SWEP.Damage = 100
SWEP.World_MuzzleAttachmentName="1"
SWEP.DrawAnim = "base_draw"
SWEP.DrawAnimEmpty = "empty_draw"
SWEP.UseHands = true
SWEP.ReloadAnim = "base_reload_empty"
SWEP.TacticalReloadAnim = "base_reload"
SWEP.FireAnim = "base_fire" .. math.random(2, 3) .. ""
SWEP.IronFireAnim = "iron_fire_" .. math.random(1, 3) .. ""
SWEP.TriggerDelay = .05
SWEP.AttBone = "glock in my rari"
SWEP.FuckedWorldModel = true
SWEP.Recoil = .8
SWEP.TPIK = false
SWEP.SwitchFM = false
SWEP.Supersonic = true
SWEP.AmmoType = "357"
SWEP.LastFireAnim = "base_firelast"
SWEP.CanOneHanded=true
SWEP.LastIronFireAnim = "iron_firelast"
SWEP.ShellType = ""
SWEP.ShellDelay = 0
SWEP.Category="HMCD: Union - Pistols"
SWEP.DeathDroppable = false
SWEP.CloseFireSound = "weapons/tfa_ins2/deagle/de_single.wav"
--SWEP.FarFireSound="snd_jack_hmcd_smp_far.wav"
SWEP.MuzzleEffectSuppressed = "pcf_jack_mf_suppressed"
--SWEP.SuppressedFireSound="snd_jack_hmcd_supppistol.wav"
--SWEP.CloseFireSound="m9/m9_fp.wav"
SWEP.FarFireSound = "m9/m9_dist.wav"
SWEP.SuppressedFireSound = "m9/m9_suppressed_fp.wav"
SWEP.ReloadSound = ""
SWEP.ReloadTime = 3.6
SWEP.vbwPistol =true
SWEP.SprintPos = Vector(5, 0, -18)
SWEP.AimPos = Vector(-3.6, -2.1, 0.4)
SWEP.AltAimPos = Vector(2, -2.1, 1.1)
SWEP.HipFireInaccuracy = .04
SWEP.LaserAngle = Angle(180, 0, 0)
SWEP.CarryWeight = 1200
SWEP.MagDelay = .7
--SWEP.MagEntity = "ent_jack_hmcd_glock17mag"

SWEP.MuzzlePos = {13.3, -4, 1.6}

SWEP.ViewModelFlip = false
SWEP.ReloadAdd = 0.7

SWEP.ReloadSounds = {
	{"weapons/tfa_ins2/deagle/handling/deagle_magout.wav", 0.9, "Both"},
	{"weapons/tfa_ins2/deagle/handling/deagle_magin.wav", 3, "Both"},
	{"weapons/tfa_ins2/deagle/handling/deagle_boltrelease.wav", 3.9, "EmptyOnly"}
}

SWEP.DeployVolume = 60

SWEP.BulletDir = {400, 1.3, -1}

SWEP.SuicidePos = Vector(15, 0, -20)
SWEP.SuicideAng = Angle(90, 30, 90)
SWEP.SuicideSuppr = Vector(4, 0, -8)

SWEP.MuzzleInfo = {
	["Bone"] = "A_Muzzle",
	["Offset"] = Vector(20, 2, -1)
}
