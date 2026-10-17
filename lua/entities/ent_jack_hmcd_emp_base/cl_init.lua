include("shared.lua")

function ENT:Draw()

	self:DrawModel()
	
end

net.Receive("huysound", function()
	local pos = net.ReadVector()
	local close = net.ReadString()
	local far = net.ReadString()
	local pitch = math.Rand(95, 105)
	if close ~= "" then sound.Play(close, pos, 75, pitch) end
	if far ~= "" then sound.Play(far, pos, 150, pitch) end
end)