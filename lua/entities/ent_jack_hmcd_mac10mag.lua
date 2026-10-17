--[[File Path:   gamemodes/homicide/entities/entities/ent_jack_hmcd_mp5mag.lua

--]]
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_hmcd_loot_base"
ENT.PrintName = "32-Round MAC10 Magazine"
ENT.ImpactSound = "weapon_impact_soft1.wav"
ENT.Model = "models/weapons/unloaded/smg_mac10_mag.mdl"

if SERVER then
	function ENT:PickUp(ply)
		ply:PickupObject(self)
	end
end