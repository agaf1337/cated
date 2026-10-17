local mode = GM:GetMode("dm")

local mat = Material("hmcd_dmzone")
local White = Color(255, 255, 255)

hook.Add("PostDrawTranslucentRenderables", "DrawDMZone", function(bDepth, bSkybox, isDraw3DSkybox)
	if GetGlobalString("RoundName", "") ~= "dm" then return end
	if GetGlobalFloat("ZoneStartTime", 0) == 0 then return end
	if bSkybox or isDraw3DSkybox then return end

	local pos = GetGlobalVector("ZonePos", Vector(0, 0, 0))
	local radius = (GAMEMODE.GetZoneRadius and GAMEMODE.GetZoneRadius()) or 1000

	render.SetMaterial(mat)
	render.DrawSphere(pos, -radius, 60, 60, White)
end)

local ZoneSoundStation = nil

hook.Add("Think", "ZoneSoundThink", function()
	if GetGlobalString("RoundName", "") ~= "dm" then
		if IsValid(ZoneSoundStation) then ZoneSoundStation:Stop() ZoneSoundStation = nil end
		return
	end
	if GetGlobalFloat("ZoneStartTime", 0) == 0 then return end

	local pos = GetGlobalVector("ZonePos", Vector(0, 0, 0))
	local radius = (GAMEMODE.GetZoneRadius and GAMEMODE.GetZoneRadius()) or 1000

	if not IsValid(ZoneSoundStation) then
		sound.PlayFile("sound/ambient/energy/force_field_loop1.wav", "noblock", function(station, errCode, errStr)
			if IsValid(station) then
				ZoneSoundStation = station
				station:Play()
				station:EnableLooping(true)
				station:SetVolume(0)
			end
		end)
	else
		local dist = LocalPlayer():GetPos():Distance(pos)
		local volume = math.Clamp((dist - radius) + 200, 0, 200) / 200
		ZoneSoundStation:SetVolume(volume)
	end
end)

function mode:GetEndTitle(data)
	if data.reason == 6 then
		return (data.survived or "Someone") .. " survived.", Color(178, 119, 17)
	end
end
