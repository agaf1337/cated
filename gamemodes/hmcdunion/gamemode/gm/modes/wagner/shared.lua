local mode = GM:RegisterMode("wagner", {
	Name = "Homicide: War in Ukraine",
	ShortName = "Wagner VS Azov",
	Weight = 2,
	DefaultRole = "Wagner",
	TimeLimit = 300,
	TimeLimitMessage = "Stopping the battle because of the time limit..",

	HelpRole = {
		["Wagner"] = "Вы вежливые люди, eliminate all ukrainian soldiers.",
		["Azov"] = "Eliminate all russian soldiers.",
	},
})

mode.TeamColors = {
	Wagner = Color(140, 25, 25),
	Azov = Color(25, 70, 180),
}

mode.RoleStartSounds = {
	Wagner = "ukraineround.wav",//ukraineround.wav
	Azov = "hohols.mp3",//hohols.mp3
}

Wagner_Names = {
    "Ратибор", "Сокол", "Вега", "Ураган", "Кречет", "Беркут", "Шторм",
    "Ветер", "Гром", "Кобра", "Шаман", "След", "Литой", "Белый",
    "Серый", "Малыш", "Дед", "Тихон", "Сайга", "Манул", "Легион",
    "Скиф", "Ястреб", "Тайга", "Вихрь", "Клык", "Молот", "Зверь", "Прикол", "Филя"
}

Azov_Names = {
    "Калина", "Сокіл", "Бурлака", "Грім", "Вітер", "Чайка", "Ворон",
    "Зубр", "Лис", "Барс", "Орел", "Сум", "Тарас", "Остап",
    "Береза", "Вільха", "Стрый", "Мальва", "Равлик", "Гайдамака",
    "Хмара", "Буран", "Сивый", "Птах", "Яструб", "Верес", "Лелека", "Батько suffix'а", "Хантiр", "Зiля"
}

mode.RoleNames = {
	Wagner = Wagner_Names,
	Azov = Azov_Names,
}

Wagner_Models = {
	{ model = "models/leygun/rfarmy/soilder_rf_08.mdl", sex = "male" },
	{ model = "models/leygun/rfarmy/soilder_rf_02.mdl", sex = "male" },
    { model = "models/leygun/rfarmy/soilder_rf_04.mdl", sex = "male" },
    { model = "models/leygun/rfarmy/soilder_rf_07.mdl", sex = "male" }, 
    { model = "models/leygun/rfarmy/soilder_rf_05.mdl", sex = "male" },
    { model = "models/leygun/rfarmy/soilder_rf_09.mdl", sex = "male" },
}

Azov_Models = {
	{ model = "models/leygun/ua_army/soilder_ua_02.mdl", sex = "male" },
    { model = "models/leygun/ua_army/soilder_ua_04.mdl", sex = "male" },
    { model = "models/leygun/ua_army/soilder_ua_06.mdl", sex = "male" },
    { model = "models/leygun/ua_army/soilder_ua_05.mdl", sex = "male" },
    { model = "models/leygun/ua_army/soilder_ua_07.mdl", sex = "male" },
    { model = "models/leygun/ua_army/soilder_ua_08.mdl", sex = "male" },
    { model = "models/leygun/ua_army/soilder_ua_09.mdl", sex = "male" },

}

Wagner_Loadout = {
	Main = {
		"wep_jack_hmcd_akm",
		"wep_jack_hmcd_scar",
		"wep_jack_hmcd_spas",
	},
	Secondary = {
		"wep_jack_hmcd_cz75a",
	},
}

Azov_Loadout = {
	Main = {
		"wep_jack_hmcd_scar",
		"wep_jack_hmcd_sr25",
		"wep_jack_hmcd_spas",
	},
	Secondary = {
		"wep_jack_hmcd_cz75a",
		"wep_jack_hmcd_usp",
	},
}

mode.CommonLoadout = {
	"wep_jack_hmcd_combatknife",
	"wep_jack_hmcd_bandage",
	"wep_jack_hmcd_painpills",
}
