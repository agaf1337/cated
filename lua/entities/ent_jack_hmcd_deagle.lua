--[[File Path:   gamemodes/homicide/entities/entities/ent_jack_hmcd_glock17.lua

--]]
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_wep_base"
ENT.SWEP = "wep_jack_hmcd_deagle"
ENT.ImpactSound = "physics/metal/weapon_impact_soft3.wav"
ENT.Model = "models/weapons/tfa_ins2/w_deagle.mdl"
ENT.DefaultAmmoAmt = 17
ENT.AmmoType = "Pistol"

ENT.MuzzlePos = Vector(7, .2, 1)
ENT.BulletDir = Vector(1, 0, 0)
ENT.BulletEjectPos = Vector(2, 1.5, 1.5)
ENT.BulletEjectDir = Vector(0, -1, 0)
ENT.ShellEffect = "eff_jack_hmcd_919"
ENT.Damage = 30