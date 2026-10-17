GM:RegisterMode("dm", {
	Name = "Homicide: Deathmatch",
	ShortName = "Deathmatch",
	Weight = 1,
	DefaultRole = "Fighter",
	StartSound = "snd_jack_hmcd_deathmatch.mp3",

	HelpRole = {
		["Fighter"] = "You fighter, kill all and stay alive.",
	},
})


DM_LoadoutMain = {
	"wep_jack_hmcd_akm",
	"wep_jack_hmcd_assaultrifle",
	"wep_jack_hmcd_rifle",
	"wep_jack_hmcd_sr25",
	"wep_jack_hmcd_mp7",
	"wep_jack_hmcd_mp5",
	"wep_jack_hmcd_dbarrel",
	-- "wep_jack_hmcd_remington", Бараны это дробовик стреляющий бинбегом
	"wep_jack_hmcd_shotgun",
	"wep_jack_hmcd_spas",
	"wep_jack_hmcd_scar",
	"wep_jack_hmcd_akmwreked",
	"wep_jack_hmcd_fnfal",
	"wep_jack_hmcd_mac10",
	"wep_jack_hmcd_mp9",
	"wep_jack_hmcd_nova"
}


DM_LoadoutSecondary = {
	"wep_jack_hmcd_smallpistol",
	"wep_jack_hmcd_cz75a",
	"wep_jack_hmcd_glock17",
	"wep_jack_hmcd_usp",
	"wep_jack_hmcd_revolver",
	"wep_jack_hmcd_suppressed",
	"wep_jack_hmcd_fn"
}

