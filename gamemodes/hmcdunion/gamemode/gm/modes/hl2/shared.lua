local mode = GM:RegisterMode("hl2", {
	Name = "Homicide: Resistance Versus Combine",
	ShortName = "Half Life 2 - Deathmatch",
	Weight = 1,
	DefaultRole = "Rebel",
	StartSound = "hl2mode1.wav",
	TimeLimit = 400,
	TimeLimitMessage = "Stopping round because it was too boring..",

	HelpRole = {
		["Rebel"] = "You're a rebel, kill the entire Alliance.",
		["Combine"] = "You're in the Alliance, kill all the rebels.",
	},
})

mode.TeamColors = {
	Rebel = Color(178, 119, 17),
	Combine = Color(32, 98, 185),
}

mode.RebelClasses = { "Medic", "Fighter" }
mode.CombineClasses = { "Simple", "Shotguner", "Elite" }

Combine_Names = {
	"C17-0142", "C17-0231", "C17-0387", "C17-0464", "C17-0519", "C17-0633",
	"C17-0748", "C17-0826", "C17-0954", "C17-1071", "C17-1188", "C17-1246",
	"C17-1362", "C17-1490", "C17-1533", "C17-1675", "C17-1781", "C17-1849",
	"C17-1927", "C17-2058",
}

mode.RoleNames = {
	Combine = Combine_Names
}

HL2_Loadout = {
	["Rebel"] = {
		["Medic"] = {"wep_jack_hmcd_oldgrenade_dm","wep_jack_hmcd_fooddrinkbig","wep_jack_hmcd_adrenaline","wep_jack_hmcd_medkit","wep_jack_hmcd_bandagebig","wep_jack_hmcd_painpills","wep_jack_hmcd_walkietalkie"},
		["Fighter"] = {"wep_jack_hmcd_oldgrenade_dm","wep_jack_hmcd_m67","wep_jack_hmcd_bandage","wep_jack_hmcd_painpills","wep_jack_hmcd_pocketknife","wep_jack_hmcd_riotshield","wep_jack_hmcd_walkietalkie","wep_jack_hmcd_riotshield"}
	},
	["Combine"] = {
		["Simple"] = {"wep_jack_hmcd_grenade","wep_jack_hmcd_adrenaline","wep_jack_hmcd_medkit","wep_jack_hmcd_bandagebig","wep_jack_hmcd_painpills"},
		["Elite"] = {"wep_jack_hmcd_grenade","wep_jack_hmcd_m67"},
		["Shotguner"] = {"wep_jack_hmcd_grenade","wep_jack_hmcd_m67"},
	}
}

HL2_LoadoutFire_Main = {
	["Rebel"] = {
		["Medic"] = {
			"wep_jack_hmcd_mp7",
			"wep_jack_hmcd_dbarrel",
			"wep_jack_hmcd_shotgun",
			"wep_jack_hmcd_spas"
		},
		["Fighter"] = {
			"wep_jack_hmcd_combinesniper",
			"wep_jack_hmcd_akm",
			"wep_jack_hmcd_rifle",
			"wep_jack_hmcd_mp7",
			"wep_jack_hmcd_mp5",
			"wep_jack_hmcd_dbarrel",
			"wep_jack_hmcd_shotgun",
			"wep_jack_hmcd_spas"
		},
	},
	["Combine"] = {
		["Simple"] = {
			"wep_jack_hmcd_ar2"
		},
		["Shotguner"] = {
			"wep_jack_hmcd_spas"
		},
		["Elite"] = {
			"wep_jack_hmcd_combinesniper",
			"wep_jack_hmcd_ar2"
		},
	}
}

HL2_LoadoutFire_Secondary = {
	["Rebel"] = {"wep_jack_hmcd_smallpistol","wep_jack_hmcd_usp"},
	["Combine"] = {"wep_jack_hmcd_usp"}
}
