include("shared.lua")

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end