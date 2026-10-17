--[[File Path:   gamemodes/homicide/entities/entities/ent_jack_hmcd_akm.lua

--]]
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_wep_base"
ENT.SWEP = "wep_jack_hmcd_fnfal"
ENT.ImpactSound = "physics/metal/weapon_impact_soft3.wav"
ENT.Model = "models/weapons/w_ins2_fn_fal.mdl"
ENT.DefaultAmmoAmt = 30
ENT.AmmoType = "SniperRound"
ENT.MuzzlePos = Vector(27, 0, 2.8)
ENT.BulletDir = Vector(1, 0, 0)
ENT.BulletEjectPos = Vector(6, 1, 3.3)
ENT.BulletEjectDir = Vector(0, 1, 0)
ENT.Damage = 90
ENT.ShellEffect = "eff_jack_hmcd_76239"
ENT.TriggerDelay = .1
ENT.Automatic = true
ENT.MuzzleEffect = "pcf_jack_mf_mrifle1"