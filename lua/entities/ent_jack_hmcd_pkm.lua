--[[File Path:   gamemodes/homicide/entities/entities/ent_jack_hmcd_m249.lua

--]]
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_wep_base"
ENT.SWEP = "wep_jack_hmcd_pkm"
ENT.ImpactSound = "physics/metal/weapon_impact_soft3.wav"
ENT.Model = "models/weapons/tfa_gamebanana/w_mach_pkm.mdl"
ENT.DefaultAmmoAmt = 200
ENT.AmmoType = "SMG1"
ENT.MuzzlePos = Vector(25.7, 0, 3.8)
ENT.BulletDir = Vector(1, 0, 0)
ENT.BulletEjectPos = Vector(4, 0, 3.4)
ENT.BulletEjectDir = Vector(0, 1, 0)
ENT.Damage = 90
ENT.ShellEffect = "eff_jack_hmcd_556"
ENT.ShellEffect2 = "eff_jack_hmcd_m249link"
ENT.TriggerDelay = .031
ENT.MuzzleEffect = "pcf_jack_mf_mrifle1"
ENT.Automatic = true