AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "ArmorBase"  
ENT.Category = "HMCD: QIWI - Armors"
ENT.ImpactSound = "physics/metal/weapon_impact_soft3.wav"
local split = {
    ["BodyPlate"] = true,
    ["BodyCarrier"] = true
}

if SERVER then
    function ENT:Initialize()
        self.Entity:SetModel(self.Model)
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
    function ENT:Use(ply)
        hmcd.EquipArmor(ply,self)
        
	end
end
