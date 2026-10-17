local mode = GM:RegisterMode("homicide", {
	Name = "Homicide",
	ShortName = "Homicide",
	Weight = 8,
	HasRoundTypes = true,
	TypeCount = 5,
	DefaultRole = "Bystander",
	ShowMurdererReveal = true,
	TitleSeparator = ": ",
	TimeLimit = 400,
	TimeLimitMessage = "Stopping round because it lasted more than 6 minutes..",

	HelpRole = {
		["Traitor"] = "KILL'EM ALL!",
		["Bystander"] = "You innocent, just find traitor and kill him.",
		["Gunman"] = "You have a gun, kill traitor in your party.",
	},
})

HMCD_RoundsTypeNormalise = {
	[0] = "",
	[1] = "Standart",
	[2] = "State of Emergency",
	[3] = "Jihad",
	[4] = "Wild West",
	[5] = "Gun-Free-Zone Mode"
}

HMCD_RoundStartSound = {
	[1] = "snd_jack_hmcd_halloween.mp3",
	[2] = "snd_jack_hmcd_disaster.mp3",
	[3] = "snd_mann_islam.mp3",
	[4] = "snd_jack_hmcd_wildwest.mp3",
	[5] = "snd_jack_hmcd_halloween.mp3",
}

mode.RoundTypes = {
	[1] = { name = HMCD_RoundsTypeNormalise[1], sound = HMCD_RoundStartSound[1] },
	[2] = { name = HMCD_RoundsTypeNormalise[2], sound = HMCD_RoundStartSound[2] },
	[3] = { name = HMCD_RoundsTypeNormalise[3], sound = HMCD_RoundStartSound[3] },
	[4] = { name = HMCD_RoundsTypeNormalise[4], sound = HMCD_RoundStartSound[4] },
	[5] = { name = HMCD_RoundsTypeNormalise[5], sound = HMCD_RoundStartSound[5] },
}

HMCD_Loadout = {
	["Traitor"] = {
		[1] = {
			"wep_jack_hmcd_knife",
			"wep_jack_hmcd_shuriken",
			"wep_jack_hmcd_poisonneedle",
			"wep_jack_hmcd_poisonpowder",
			"wep_jack_hmcd_ied",
			"wep_jack_hmcd_oldgrenade",
			"wep_jack_hmcd_smokebomb",
			"wep_jack_hmcd_fakepistol",
			"wep_jack_hmcd_adrenaline",
			"wep_jack_hmcd_jam",
			"wep_jack_hmcd_poisonliquid",
			"wep_jack_hmcd_poisongoo",
			"wep_jack_hmcd_poisoncanister",
			"wep_jack_hmcd_mask",
			"wep_jack_hmcd_beartrap"
		},
		[2] = {
			"wep_jack_hmcd_knife",
			"wep_jack_hmcd_poisonpowder",
			"wep_jack_hmcd_ied",
			"wep_jack_hmcd_oldgrenade",
			"wep_jack_hmcd_smokebomb",
			--"wep_jack_hmcd_suppressed",
			"wep_jack_hmcd_adrenaline",
			"wep_jack_hmcd_poisoncanister",
			"wep_jack_hmcd_poisonliquid"
		},
		[3] = {
			"wep_jack_hmcd_knife",
			"wep_jack_hmcd_ied",
			"wep_jack_hmcd_pipebombtest",
			"wep_jack_hmcd_jihad",
			"wep_jack_hmcd_molotovtest",
			"wep_jack_hmcd_oldgrenade",
			"wep_jack_hmcd_claymore"
		},
		[4] = {
			"wep_jack_hmcd_knife",
			--"wep_jack_hmcd_revolver",
			"wep_jack_hmcd_ied",
			"wep_jack_hmcd_smokebomb"
		},
		[5] = {
			"wep_jack_hmcd_knife",
			"wep_jack_hmcd_shuriken",
			"wep_jack_hmcd_poisonneedle",
			"wep_jack_hmcd_poisonpowder",
			"wep_jack_hmcd_ied",
			"wep_jack_hmcd_oldgrenade",
			"wep_jack_hmcd_smokebomb",
			"wep_jack_hmcd_fakepistol",
			"wep_jack_hmcd_adrenaline",
			"wep_jack_hmcd_jam",
			"wep_jack_hmcd_poisonliquid",
			"wep_jack_hmcd_poisongoo",
			"wep_jack_hmcd_poisoncanister",
			"wep_jack_hmcd_mask",
			"wep_jack_hmcd_beartrap"
		}
	},
	["Gunman"] = {
		[1] = {""},
		[2] = {""},
		[3] = {""},
		[4] = {""},
		[5] = {""}	
	},
	["Bystander"] = {
		[1] = {""},
		[2] = {""},
		[3] = {""},
		[4] = {"wep_jack_hmcd_revolver"},
		[5] = {""}
	}
}


HMCD_Loadout_Firearms = {
	["Traitor"] = {
		[1] = {""},
		[2] = {"wep_jack_hmcd_suppressed"},
		[3] = {""},
		[4] = {"wep_jack_hmcd_revolver"},
		[5] = {""}
	},
	["Gunman"] = {
		[1] = {"wep_jack_hmcd_smallpistol"},
		[2] = {"wep_jack_hmcd_rifle"},
		[3] = {"wep_jack_hmcd_smallpistol"},
		[4] = {"wep_jack_hmcd_revolver"},
		[5] = {""}
	},
	["Bystander"] = {
		[1] = {""},
		[2] = {""},
		[3] = {""},
		[4] = {"wep_jack_hmcd_revolver"},
		[5] = {""}
	}
}






Box_Models = {
	"models/props_c17/FurnitureDrawer001a.mdl",
	"models/props_c17/FurnitureDresser001a.mdl",
	"models/props_c17/FurnitureDrawer003a.mdl",
	"models/props_c17/FurnitureCupboard001a.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"models/props_junk/cardboard_box002a_gib01.mdl",
	"models/props_junk/cardboard_box002a.mdl",
	"models/props_junk/cardboard_box001b.mdl",
	"models/props_junk/cardboard_box001a_gib01.mdl",
	"models/props_junk/cardboard_box002b.mdl",
	"models/props_junk/cardboard_box003a.mdl",
	"models/props_junk/cardboard_box003a_gib01.mdl",
	"models/props_junk/cardboard_box003b_gib01.mdl",
	"models/props_junk/cardboard_box004a.mdl",
	"models/props_junk/cardboard_box004a_gib01.mdl",
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_crate002a.mdl",
	"models/props_c17/woodbarrel001.mdl",
	"models/props_junk/cardboard_box001a_present.mdl",
	"models/props_junk/cardboard_box002a_present.mdl",
	"models/props_junk/cardboard_box003a_present.mdl",
	"models/props_junk/cardboard_box001b_present.mdl",
	"models/props_junk/cardboard_box002b_present.mdl",
	"models/props_junk/cardboard_box003b_present.mdl",

}


HeavyBox_Models = {
	"models/props_junk/wood_crate002a.mdl",
	"models/props_c17/FurnitureDresser001a.mdl",
	"models/props_c17/FurnitureDrawer003a.mdl"
}


Box22_Models = {
    "models/props_c17/oildrum001.mdl",
    "models/props_wasteland/kitchen_fridge001a.mdl",
    "models/props_c17/Lockers001a.mdl",
    "models/props_c17/FurnitureWashingmachine001a.mdl",
    "models/props_borealis/bluebarrel001.mdl",
    "models/props_wasteland/controlroom_storagecloset001a.mdl",
    "models/props_lab/filecabinet02.mdl",
    "models/props_wasteland/controlroom_filecabinet001a.mdl",
    "models/props_wasteland/controlroom_filecabinet002a.mdl",
    "models/props_wasteland/controlroom_storagecloset001b.mdl",
    "models/props_junk/TrashDumpster01a.mdl",
    "models/props_c17/FurnitureFridge001a.mdl",
    "models/props_c17/BriefCase001a.mdl",
    "models/props_c17/SuitCase001a.mdl",
    "models/props_c17/SuitCase_Passenger_Physics.mdl",
    "models/props_junk/TrashBin01a.mdl",
    "models/props/CS_militia/crate_extralargemill.mdl",
    "models/props/CS_militia/crate_extrasmallmill.mdl",
    "models/props/CS_militia/dryer.mdl",
    "models/props/CS_militia/microwave01.mdl",
    "models/props/cs_assault/washer_box.mdl",
    "models/props/cs_assault/dryer_box.mdl",
    "models/props/cs_assault/washer_box2.mdl",
    "models/props/cs_assault/dryer_box2.mdl",
    "models/props/cs_office/Cardboard_box03.mdl",
    "models/props/cs_office/Cardboard_box02.mdl",
    "models/props/cs_office/Cardboard_box01.mdl",
    "models/props/cs_office/file_cabinet1.mdl",
    "models/props/cs_office/file_cabinet1_group.mdl",
    "models/props/cs_office/file_cabinet2.mdl",
    "models/props/cs_office/file_cabinet3.mdl",
    "models/props/cs_office/microwave.mdl",
    "models/props/de_nuke/crate_extralarge.mdl",
    "models/props/de_nuke/crate_extrasmall.mdl",
    "models/props/de_nuke/crate_large.mdl",
    "models/props/de_nuke/file_cabinet1_group.mdl",
    "models/props/de_nuke/NuclearContainerBoxClosed.mdl"
}

