local mode = GM:GetMode("hl2coop")

function mode:GetStartSound()
	return "hl2mode1.wav"
end

mode.EndTitles = {
	[7] = { text = "Episode Failed", color = Color(164, 26, 26) },
	[8] = { text = "Episode Successful", color = Color(29, 125, 19) },
}
