DeriveGamemode("sandbox")

GM.Name = "Cated"
GM.Author = "By MEDIC, Makaroni (ex-dev), OG Homicidal by kazoo & crow,  Thanks to Cat. v0.65"
GM.Email = "N/A"
GM.Website = "https://discord.gg/XJ5qGhc5p6"
GM.TeamBased = true

GM.ZoneTimeToShrink = 120

function GM.GetZoneRadius()
	local dist_start = GetGlobalFloat("ZoneDistance", 0)
	if dist_start == 0 then return 999999 end
	
	local start_time = GetGlobalFloat("ZoneStartTime", 0)
	if start_time == 0 then return dist_start + 1024 end

	local dist = dist_start + 1024
	
	return (dist * math.max(((start_time + GAMEMODE.ZoneTimeToShrink) - CurTime()) / GAMEMODE.ZoneTimeToShrink, 0.025))
end

-- checha gm ints!!!
GM.DMTime = 10
GM.RoundName = "homicide"
GM.RoundNext = "homicide"
GM.RoundType = 2
GM.RoundState = 3
GM.Version = ""
GM.Traitor = nil
GM.RoundEnding = false
GM.elapsed = CurTime()
GM.MVP = nil

RunConsoleCommand("hostname", GM.Name)

-- round types hmcd
-- 1 = Standard
-- 2 = State of Emergency
-- 3 = Jihad
-- 4 = Wild West
-- 5 = Gun Free Zone

include("loader.lua")

GM.papkago("hmcdunion/gamemode/gm/")

function GM:CreateTeams()
	team.SetUp(1, "Players", Color(57,62,213))
end

PrecacheParticleSystem("blood_impact")
PrecacheParticleSystem("swb_muzzle")

HMCD_REMOVEEQUIPMENT=-1

HMCD_GASMASK=4
HMCD_FLASHLIGHT=5
HMCD_PISTOLSUPP=6
HMCD_RIFLESUPP=7
HMCD_SHOTGUNSUPP=8
HMCD_LASERSMALL=9
HMCD_LASERBIG=10
HMCD_AIMPOINT=11
HMCD_EOTECH=12
HMCD_KOBRA=13
HMCD_PBS=14
HMCD_OSPREY=15
HMCD_BALLISTICMASK=16
HMCD_NVG=17
HMCD_MOTHELMET=18
HMCD_BRASSKNUCKLES=19
HMCD_SCOPE=20

blood_drop = {
	"bleeding/bleeding1.wav",
	"bleeding/bleeding2.wav",
	"bleeding/bleeding3.wav",
	"bleeding/bleeding4.wav",
}

TypeHit = {
	[DMG_BULLET] = "shot",
	[DMG_SNIPER] = "shot",
	[DMG_BUCKSHOT] = "shot",
	[DMG_SLASH] = "slash",
	[DMG_CLUB] = "club",
	[DMG_CRUSH] = "crush",
	[DMG_FALL] = "fall"
}

HitgroupReason = {
	[HITGROUP_HEAD] = "head",
	[HITGROUP_CHEST] = "chest",
	[HITGROUP_STOMACH] = "stomach",
	[HITGROUP_LEFTARM] = "left arm",
	[HITGROUP_RIGHTARM] = "right arm",
	[HITGROUP_LEFTLEG] = "left leg",
	[HITGROUP_RIGHTLEG] = "right leg"
}

DieReason = {
	[DMG_BURN] = "burnout.",
	[DMG_BULLET] = "bullet.",
	[DMG_SNIPER] = "bullet.",
	[DMG_BLAST] = "explosion",
	[DMG_CRUSH] = "crush.",
	[DMG_BUCKSHOT] = "bullet.",
	[DMG_SLASH] = "melee weapon.",
	[DMG_CLUB] = "melee weapon.",
	[DMG_FALL] = "falled.",
	[DMG_DROWN] = "drowned.",
	[DMG_POISON] = "poison."
}

HMCD_EquipmentNames = {
	[1] = "Level IIIA Armor",
	[2] = "Level III Armor",
	[3] = "Advanced Combat Helmet",
	[4] = "M40 Gas Mask",
	[5] = "Maglite ML300LX-S3CC6L Flashlight",
	[6] = "Cobra M2 Suppressor",
	[7] = "Hybrid 46 Suppressor",
	[8] = "Salvo 12 Suppressor",
	[9] = "Marcool JG5 Laser Sight",
	[10] = "AN/PEQ-15 Laser Sight",
	[11] = "Aimpoint CompM2 Sight",
	[12] = "EOTech 552.A65 Sight",
	[13] = "Kobra Sight",
	[14] = "PBS-1 Suppressor",
	[15] = "Osprey 45 Suppressor",
	[16] = "Ballistic Mask",
	[17] = "Ground Panoramic Night Vision Goggles",
	[18] = "Bell Bullitt Motorcycle Helmet",
	[19] = "Brass Knuckles",
	[20] = "Optic Scope"
}

HMCD_HelpRole = {
	["Traitor"] = "KILL'EM ALL!",
	["Bystander"] = "You innocent, just find traitor and kill him.",
	["Gunman"] = "You have a gun, kill traitor in your party.",
	["Fighter"] = "You fighter, kill all and stay alive.",
	["Rebel"] = "You're a rebel, kill the entire Alliance.",
	["Combine"] = "You're in the Alliance, kill all the rebels."
}

RoundsNormalise = {
	["homicide"] = "Homicide",
	["sandbox"] = "Sandbox",
	["hl2"] = "Homicide: Resistance Versus Combine",
	["dm"] = "Homicide: Deathmatch",
	["hl2coop"] = "Half-Life 2 Cooperative",
	["svo"] = "Special Military Operation"
}

Classes = {
	"Medic",
	"Fighter"
}

ClassesCombine = {
	"Shotguner",
	"Elite",
	"Simple"
}

CombineModels = {
	["Simple"] = "models/player/combine_soldier.mdl",
	["Shotguner"] = "models/player/combine_soldier.mdl",
	["Elite"] = "models/player/combine_super_soldier.mdl"
}

Fighter_RebelModels = {
	["female"] = {
		"models/player/Group03/female_01.mdl",
		"models/player/Group03/female_02.mdl",
		"models/player/Group03/female_03.mdl",
		"models/player/Group03/female_04.mdl",
		"models/player/Group03/female_05.mdl",
		"models/player/Group03/female_06.mdl",
	},
	["male"] = {
		"models/player/Group03/male_01.mdl",
		"models/player/Group03/male_02.mdl",
		"models/player/Group03/male_03.mdl",
		"models/player/Group03/Male_04.mdl",
		"models/player/Group03/Male_05.mdl",
		"models/player/Group03/male_06.mdl",
		"models/player/Group03/male_07.mdl",
		"models/player/Group03/male_08.mdl",
		"models/player/Group03/male_09.mdl"
	}
}

Medic_RebelModels = {
	["female"] = {
		"models/player/Group03m/female_01.mdl",
		"models/player/Group03m/female_02.mdl",
		"models/player/Group03m/female_03.mdl",
		"models/player/Group03m/female_04.mdl",
		"models/player/Group03m/female_04.mdl",
		"models/player/Group03m/female_05.mdl",
		"models/player/Group03m/female_06.mdl"
	},
	["male"] = {
		"models/player/Group03m/Male_01.mdl",
		"models/player/Group03m/male_02.mdl",
		"models/player/Group03m/male_03.mdl",
		"models/player/Group03m/Male_04.mdl",
		"models/player/Group03m/Male_05.mdl",
		"models/player/Group03m/male_06.mdl",
		"models/player/Group03m/male_07.mdl",
		"models/player/Group03m/male_08.mdl",
		"models/player/Group03m/male_09.mdl"
	}
}

NormaliseKonech = {
	["head"] = "Head",
	["left_hand"] = "Left arm",
	["left_leg"] = "Left leg",
	["right_hand"] = "Right arm",
	["right_leg"] = "Right leg",
	["stomach"] = "Stomach",
	["chest"] = "Chest"
}



HMCD_AmmoWeights={
	["AlyxGun"]=4,
	["Pistol"]=12,
	["HelicopterGun"]=30,
	["357"]=15,
	["AirboatGun"]=3,
	["Buckshot"]=60,
	["AR2"]=50,
	["MP5_Grenade"]=60,
	["SMG1"]=18,
	["Gravity"]=18,
	["SniperRound"]=20,
	["XBowBolt"]=22,
	["Thumper"]=26,
	["StriderMinigun"]=20,
	["RPG_Round"]=150,
	["9mmRound"]=8,
	["Hornet"]=30,
	["SniperPenetratedRound"]=20
}

HMCD_AmmoNames={
	["AlyxGun"]="5.7x16mm (.22 long rifle)",
	["Pistol"]="9x19mm (9mm luger/parabellum)",
	["357"]="9x29mmR (.38 special)",
	["SMG1"]="5.56x45mm (.223 remington)",
	["Buckshot"]="18.5x70mmR (12 gauge shotshell)",
	["AR2"]="7x57mm (7mm mauser)",
	["XBowBolt"]="6x735mm broadhead hunting arrow",
	["AirboatGun"]="2x89mm Carpentry Nail",
	["RPG_Round"]="40mm Rocket",
	["StriderMinigun"]="7.62x51 NATO",
	["HelicopterGun"]="4.6x30mm",
	["SniperRound"]="7.62x39mm",
	["Gravity"]="Pulse Slug",
	["Thumper"]="300mm Rebar",
	["MP5_Grenade"]="Energy Ball",
	["SniperPenetratedRound"]="X26 Taser Cartridge",
	["9mmRound"]="9×22mm P.A.",
	["Hornet"]="Flexible Baton Round"
}

Box2_Models = {
    ["models/props_c17/oildrum001.mdl"] = true,
    ["models/props_wasteland/kitchen_fridge001a.mdl"] = true,
    ["models/props_c17/lockers001a.mdl"] = true,
    ["models/props_c17/furniturewashingmachine001a.mdl"] = true,
    ["models/props_borealis/bluebarrel001.mdl"] = true,
    ["models/props_wasteland/controlroom_storagecloset001a.mdl"] = true,
    ["models/props_lab/filecabinet02.mdl"] = true,
    ["models/props_wasteland/controlroom_filecabinet001a.mdl"] = true,
    ["models/props_wasteland/controlroom_filecabinet002a.mdl"] = true,
    ["models/props_wasteland/controlroom_storagecloset001b.mdl"] = true,
    ["models/props_junk/trashdumpster01a.mdl"] = true,
    ["models/props_c17/furniturefridge001a.mdl"] = true,
    ["models/props_c17/briefcase001a.mdl"] = true,
    ["models/props_c17/suitcase001a.mdl"] = true,
    ["models/props_c17/suitcase_passenger_physics.mdl"] = true,
    ["models/props_junk/trashbin01a.mdl"] = true,
    ["models/props/cs_militia/crate_extralargemill.mdl"] = true,
    ["models/props/cs_militia/crate_extrasmallmill.mdl"] = true,
    ["models/props/cs_militia/dryer.mdl"] = true,
    ["models/props/cs_militia/microwave01.mdl"] = true,
    ["models/props/cs_assault/washer_box.mdl"] = true,
    ["models/props/cs_assault/dryer_box.mdl"] = true,
    ["models/props/cs_assault/washer_box2.mdl"] = true,
    ["models/props/cs_assault/dryer_box2.mdl"] = true,
    ["models/props/cs_office/cardboard_box03.mdl"] = true,
    ["models/props/cs_office/cardboard_box02.mdl"] = true,
    ["models/props/cs_office/cardboard_box01.mdl"] = true,
    ["models/props/cs_office/file_cabinet1.mdl"] = true,
    ["models/props/cs_office/file_cabinet1_group.mdl"] = true,
    ["models/props/cs_office/file_cabinet2.mdl"] = true,
    ["models/props/cs_office/file_cabinet3.mdl"] = true,
    ["models/props/cs_office/microwave.mdl"] = true,
    ["models/props/de_nuke/crate_extralarge.mdl"] = true,
    ["models/props/de_nuke/crate_extrasmall.mdl"] = true,
    ["models/props/de_nuke/crate_large.mdl"] = true,
    ["models/props/de_nuke/file_cabinet1_group.mdl"] = true,
    ["models/props/de_nuke/nuclearcontainerboxclosed.mdl"] = true,
}

Box_DropGunFreeZone = {
	"ent_jack_hmcd_ammo",
	"ent_jack_hmcd_fooddrinkbig",
	"ent_jack_hmcd_fooddrink",
	"ent_jack_hmcd_adrenaline",
	"ent_jack_hmcd_medkit",
	"ent_jack_hmcd_bandagebig",
	"ent_jack_hmcd_morphine",
	"ent_jack_hmcd_painpills",
	"ent_jack_hmcd_bandage",
	"ent_jack_hmcd_baseballbat",
	"ent_jack_hmcd_brick",
	"ent_jack_hmcd_cleaver",
	"ent_jack_hmcd_hammer",
	"ent_jack_hmcd_pocketknife",
	"ent_jack_hmcd_crowbar",
	"ent_jack_hmcd_hatchet",
	"ent_jack_hmcd_leadpipe",
	"ent_jack_hmcd_axe",
	"ent_jack_hmcd_ducttape",
	"ent_jack_hmcd_oldgrenade_dm",
	"ent_jack_hmcd_bugbait",
	"ent_jack_hmcd_softarmor",
	"ent_jack_hmcd_brassknuckles",
	"ent_jack_hmcd_cat"
}

HeavyBox_DropGunFreeZone = {
	"ent_jack_hmcd_adrenaline",
	"ent_jack_hmcd_medkit"
}

Box_Drop = {
	"ent_jack_hmcd_ammo",
	"ent_jack_hmcd_fooddrinkbig",
	"ent_jack_hmcd_fooddrink",
	"ent_jack_hmcd_adrenaline",
	"ent_jack_hmcd_medkit",
	"ent_jack_hmcd_bandagebig",
	"ent_jack_hmcd_morphine",
	"ent_jack_hmcd_painpills",
	"ent_jack_hmcd_bandage",
	"ent_jack_hmcd_baseballbat",
	"ent_jack_hmcd_brick",
	"ent_jack_hmcd_cleaver",
	"ent_jack_hmcd_hammer",
	"ent_jack_hmcd_pocketknife",
	"ent_jack_hmcd_crowbar",
	"ent_jack_hmcd_hatchet",
	"ent_jack_hmcd_leadpipe",
	"ent_jack_hmcd_axe",
	"ent_jack_hmcd_smallpistol",
	"ent_jack_hmcd_ducttape",
	"ent_jack_hmcd_oldgrenade_dm",
	"ent_jack_hmcd_glock17",
	"ent_jack_hmcd_revolver",
	"ent_jack_hmcd_rifle",
	"ent_jack_hmcd_mp7",
	//"ent_jack_hmcd_shotgun",
	"ent_jack_hmcd_dbarrel",
	//"ent_jack_hmcd_remington",
	"ent_jack_hmcd_bugbait",
	"ent_jack_hmcd_nvg",
	"ent_jack_hmcd_softarmor",
	"ent_jack_hmcd_hardarmor",
	"ent_jack_hmcd_brassknuckles",
	"ent_jack_hmcd_helmet",
	"ent_jack_hmcd_laserbig",
	"ent_jack_hmcd_eotech",
	"ent_jack_hmcd_kobra",
	"ent_jack_hmcd_uspsuppressor",
	"ent_jack_hmcd_aksuppressor",
	"ent_jack_hmcd_pistolsuppressor",
	"wep_jack_hmcd_makarych",
	"wep_jack_hmcd_mac10",
	"wep_jack_hmcd_medkit",
	"wep_jack_hmcd_bandagebig",
	"wep_jack_hmcd_bandage",
	"ent_jack_hmcd_riflesuppressor",
	"ent_jack_hmcd_shotgunsuppressor",
	"ent_hmcd_ssh68",
	"ent_hmcd_mich_helmet",
	"ent_hmcd_plate_3a",
	"ent_jack_hmcd_laser"
}

HeavyBox_Drop = {
	"ent_jack_hmcd_ptrd",
	"ent_jack_hmcd_adrenaline",
	"ent_jack_hmcd_medkit",
	"ent_jack_hmcd_oldgrenade_dm",
	"ent_jack_hmcd_glock17",
	"ent_jack_hmcd_revolver",
	"ent_jack_hmcd_rifle",
	"ent_jack_hmcd_mp7",
	"ent_jack_hmcd_shotgun",
	"ent_jack_hmcd_dbarrel",
	"ent_jack_hmcd_remington",
	"wep_jack_hmcd_deagle",
	"ent_jack_hmcd_nvg",
	"ent_jack_hmcd_softarmor",
	"ent_jack_hmcd_hardarmor",
	"ent_jack_hmcd_helmet",
	"ent_jack_hmcd_laserbig",
	"ent_jack_hmcd_eotech",
	"ent_hmcd_ach_helmet",
	"ent_hmcd_plate_3a",
	"ent_jack_hmcd_kobra",
	"ent_jack_hmcd_uspsuppressor",
	"ent_jack_hmcd_aksuppressor",
	"ent_jack_hmcd_pistolsuppressor",
	"ent_jack_hmcd_riflesuppressor",
	"ent_jack_hmcd_shotgunsuppressor",
	"ent_jack_hmcd_laser"
}

AmmoType_Drop = {
	"AirboatGun",
	"AlyxGun",
	"357",
	"Pistol",
	"Buckshot",
	"AR2",
	"SMG1",
	"XBowBolt",
	"AirboatGun"
}

local atts_ents = {
	[HMCD_PISTOLSUPP]="ent_jack_hmcd_pistolsuppressor",
	[HMCD_RIFLESUPP]="ent_jack_hmcd_riflesuppressor",
	[HMCD_SHOTGUNSUPP]="ent_jack_hmcd_shotgunsuppressor",
	[HMCD_LASERSMALL]="ent_jack_hmcd_laser",
	[HMCD_LASERBIG]="ent_jack_hmcd_laserbig",
	[HMCD_KOBRA]="ent_jack_hmcd_kobra",
	[HMCD_AIMPOINT]="ent_jack_hmcd_eq_base",
	[HMCD_EOTECH]="ent_jack_hmcd_eotech",
	[HMCD_PBS]="ent_jack_hmcd_aksuppressor",
	[HMCD_OSPREY]="ent_jack_hmcd_uspsuppressor",
	[HMCD_SCOPE]="ent_jack_hmcd_scope",
	[HMCD_FLASHLIGHT]="ent_jack_hmcd_flashlight",
	[HMCD_BRASSKNUCKLES]="ent_jack_hmcd_brassknuckles"
}

local atts_simplified={
	[HMCD_PISTOLSUPP]="Suppressor",
	[HMCD_RIFLESUPP]="Suppressor",
	[HMCD_SHOTGUNSUPP]="Suppressor",
	[HMCD_LASERSMALL]="Laser",
	[HMCD_LASERBIG]="Laser",
	[HMCD_KOBRA]="Sight",
	[HMCD_AIMPOINT]="Sight2",
	[HMCD_EOTECH]="Sight3",
	[HMCD_PBS]="Suppressor",
	[HMCD_OSPREY]="Suppressor",
    [HMCD_BRASSKNUCKLES] = "Brass Knuckles",
    [HMCD_SCOPE] = "Scope"
}

concommand.Add("hmcd_attachrequest",function(ply,cmd,args)
	local attachment=math.Round(args[1])
	local wep=ply:GetActiveWeapon()
	
	if wep:GetNWBool(atts_simplified[attachment]) then
		if ply.Equipment[HMCD_EquipmentNames[attachment]] then ply:PrintMessage(HUD_PRINTTALK, "You already have this attachment!") return end
		wep:SetNWBool(atts_simplified[attachment],false)
		ply.Equipment[HMCD_EquipmentNames[attachment]]=true
		if (wep:GetNWBool("Rail", false) == true) and (attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_EOTECH) then
			wep:SetNWBool("Rail", false)
		end
		net.Start("hmcd_equipment")
		net.WriteInt(attachment,6)
		net.WriteBit(true)
		net.Send(ply)
	else
		if attachment==HMCD_LASERBIG and (wep:GetNWBool("Sight") or wep:GetNWBool("Sight2") or wep:GetNWBool("Sight3")) and not(wep.MultipleRIS) then
			ply:PrintMessage(HUD_PRINTTALK, "You can't apply this attachment! There isn't enough space!")
			return
		end
		if (attachment==HMCD_EOTECH or attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_SCOPE) and wep:GetNWBool("Laser") and not(wep.MultipleRIS) then
			ply:PrintMessage(HUD_PRINTTALK, "You can't apply this attachment! There isn't enough space!")
			return
		end
		if (attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_EOTECH or attachment==HMCD_SCOPE) and (wep:GetNWBool("Sight") or wep:GetNWBool("Sight2") or wep:GetNWBool("Sight3")) then
			ply:PrintMessage(HUD_PRINTTALK, "You already have a sight attached!")
			return
		end
		if wep:GetClass() == "wep_jack_hmcd_akm" and (attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_EOTECH) then
			wep:SetNWBool("Rail", true)
		end
		wep:SetNWBool(atts_simplified[attachment],true)
		ply.Equipment[HMCD_EquipmentNames[attachment]]=false
		net.Start("hmcd_equipment")
		net.WriteInt(attachment, 6)
		net.WriteBit(false)
		net.Send(ply)
	end
end)

concommand.Add("hmcd_droprequest",function(ply,cmd,args)
	local attachment=math.Round(args[1])
	local wep=ply:GetActiveWeapon()

	local attachmentsuka=ents.Create(atts_ents[attachment])
	attachmentsuka.HmcdSpawned=true
	attachmentsuka:SetPos(ply:GetShootPos()+ply:GetAimVector()*20)
	attachmentsuka:Spawn()
	attachmentsuka:Activate()
	attachmentsuka:GetPhysicsObject():SetVelocity(ply:GetVelocity()+ply:GetAimVector()*100)

	-- вот эта нижняя строка самая длинная ее не надо разбирать, это убирание рэйла при убирании прицела
	if wep:GetClass() == "wep_jack_hmcd_akm" and (attachment==HMCD_KOBRA or attachment==HMCD_AIMPOINT or attachment==HMCD_EOTECH) then wep:SetNWBool("Rail", false) end
	if attachment != 5 then wep:SetNWBool(atts_simplified[attachment],false) end
	//if attachment == 5 then ply:AllowFlashlight(false) end

	ply.Equipment[HMCD_EquipmentNames[attachment]]=false
	net.Start("hmcd_equipment")
	net.WriteInt(attachment, 6)
	net.WriteBit(false)
	net.Send(ply)
end)
