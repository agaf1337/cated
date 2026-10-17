AddCSLuaFile()

ENT.Base = "ent_jack_hmcd_emp_base"

ENT.PrintName = "PKM"
ENT.Category = "HMCD: QIWI - Other"

ENT.Spawnable = true
ENT.BaseModel = "models/hunter/blocks/cube025x025x025.mdl" 

ENT.GunModel = "models/weapons/tfa_gamebanana/c_mach_pkm.mdl"
ENT.NextShoot = 0

ENT.MuzzleOffset = Vector(38, 2.5, -3)
ENT.Offset = Vector(-0,1.5,5)

ENT.Damage = 90
ENT.Force = 30

ENT.MaxClip = 200
ENT.Clip = 200
ENT.Delay = .059

ENT.ReloadSounds = {
	{"weapons/pkm/coverup.wav", 0.8, "Both"},
	{"weapons/pkm/bullet.wav", 1.3, "Both"},
	{"weapons/pkm/boxout.wav", 2.4, "Both"},
	{"weapons/pkm/boxin.wav", 3.5, "Both"},
	{"weapons/pkm/chain.wav", 4.2, "Both"},
	{"weapons/pkm/coverdown.wav", 4.8, "Both"},
	{"weapons/pkm/coversmack.wav", 5.05, "Both"},
	{"weapons/pkm/bolt.wav", 5.8, "Both"},
}

ENT.ShootSound = "sounds_zcity/m249/close.wav"
ENT.ShootSoundFar = "m249/m249_dist.wav"
