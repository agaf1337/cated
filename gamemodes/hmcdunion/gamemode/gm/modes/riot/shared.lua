local mode = GM:RegisterMode("riot", {
	Name = "Homicide: Riot Mode",
	ShortName = "Riot",
	Weight = 1,
	DefaultRole = "Rioter",
	StartSound = "snd_jack_hmcd_disaster.mp3",
	TimeLimit = 400,
	TimeLimitMessage = "Stopping round because it was too boring..",

	HelpRole = {
		["Rioter"] = "Rob, destroy and kill.",
		["Police"] = "Disperse the crowd of rioters.",
	},
})

mode.TeamColors = {
	Rioters = Color(178, 119, 17),
	Police = Color(32, 98, 185),
}