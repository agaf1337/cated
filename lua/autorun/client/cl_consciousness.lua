if SERVER then return end

local earRingingSound = nil

hook.Add("EntityEmitSound", "HMCD_ConsciousnessMuffle", function(soundData)
	if soundData.OriginalSoundName == "earringing.wav" then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() or ply.Otrub then return end

	local cons = ply:GetNWFloat("blinded", 100)

	if cons < 70 then
		local severity = (70 - cons) / 70
		
		local muffleMultiplier = 1 - (severity * 0.1)
		soundData.Volume = soundData.Volume * muffleMultiplier
		
		soundData.Pitch = soundData.Pitch * (1 - (severity * 0.9)) //verity
		ply:SetDSP(4)
		return true 
	end
end)

hook.Add("RenderScreenspaceEffects", "HMCD_ConsciousnessBlur", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then 
		if earRingingSound then earRingingSound:Stop() earRingingSound = nil end
		return 
	end
	
	local cons = ply:GetNWFloat("blinded", 100)//uh
	
	if cons < 70 then
		if not earRingingSound then
			earRingingSound = CreateSound(ply, "earringing.wav")
			if earRingingSound then earRingingSound:Play() end
		end
		
		if earRingingSound then
			local volume = (70 - cons) / 70
			earRingingSound:ChangeVolume(volume, 0)
		end
	else
		if earRingingSound then
			earRingingSound:Stop()
			earRingingSound = nil
		end
	end
	
	if cons < 100 then
		local add_alpha = 0.01
		local draw_alpha = 0.01
		
		if cons <= 50 then
			local severity = (50 - cons) / 50
			add_alpha = 0.05 - (severity * 0.03)
			draw_alpha = 0.95 + (severity * 0.04)
		else
			local severity = (100 - cons) / 50
			add_alpha = 1.0 - (severity * 0.95)
			draw_alpha = severity * 0.95
		end
		
		if draw_alpha > 0.01 then
			DrawMotionBlur(add_alpha, draw_alpha, 0.01)
		end
	end
end)
