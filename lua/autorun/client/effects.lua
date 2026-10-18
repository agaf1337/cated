local ppain = 0
local function init()
hook.Add("RenderScreenspaceEffects","Effects", function()
	local ply = LocalPlayer()
    if ply:GetViewEntity() != ply then return end
	if !ply:Alive() then 
		ppain = 0 
		return 
	end

	local bloodlevel, painlevel = ply:GetNWFloat("Blood",5200), ply:GetNWFloat("pain",0)
	local adrenaline = ply:GetNWFloat("Adrenaline", 0)
	local fraction, hp = math.Clamp(1-((bloodlevel-3200)/((5000-1400)-2000)),0,1), ply:Health() / 100 
	local alpha = math.Clamp(255 - hp * 255, 0, 255)
	
	ppain = math.Approach(ppain, painlevel, FrameTime() * 10)

    if ppain > 0.01 then
    	local blur = math.Clamp(ppain / 100, 0, 1)

    	render.DrawMercRadialBlur(0.5, 0.5, blur * 0.1)
    end

	DrawToyTown(fraction * 8, ScrH() * fraction * 1.5)
	
	local tab = {
	    ["$pp_colour_addr"] = 0,
	    ["$pp_colour_addg"] = 0,
	    ["$pp_colour_addb"] = 0,
	    ["$pp_colour_contrast"] = 1 + (adrenaline / 100),
	    ["$pp_colour_colour"] = 1 - (alpha / 255) * 0.6,
	    ["$pp_colour_mulr"] = 0,
	    ["$pp_colour_mulg"] = 0, 
	    ["$pp_colour_mulb"] = 0
    }

    DrawColorModify(tab)
end)
end

timer.Simple(1,function() --ну епта
	init()
end)
