--[[File Path:   gamemodes/homicide/entities/entities/ent_jack_hmcd_pistol.lua

--]]
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_wep_base"
ENT.SWEP = "wep_jack_hmcd_m9berreta"
ENT.ImpactSound = "physics/metal/weapon_impact_soft3.wav"
ENT.Model = "models/weapons/tfa_ins2/w_m9.mdl"
ENT.DefaultAmmoAmt = 13
ENT.AmmoType = "Pistol"
ENT.MuzzlePos = Vector(0.4, 9.5, 4)
ENT.BulletDir = Vector(0, 1, 0)
ENT.AngleOffset = Angle(3, 0, 10)
ENT.BulletEjectPos = Vector(1.1, 5.5, 4.5)
ENT.BulletEjectDir = Vector(-1, 0, 0)
ENT.Damage = 30
ENT.ShellEffect = "eff_jack_hmcd_919"