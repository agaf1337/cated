AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "PropArmorBase"  
ENT.Category = "HMCD: QIWI - Dev"
ENT.ImpactSound = "physics/metal/weapon_impact_soft3.wav"

if SERVER then
    function ENT:Initialize()
		if self.Material then self.Entity:SetMaterial(self.Material) end
		if self.Color then self.Entity:SetColor(self.Color) end
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			local mass = self.Mass or 15
			phys:SetMass(mass)
			phys:Wake()
			phys:EnableMotion(true)
		end
    end
end
