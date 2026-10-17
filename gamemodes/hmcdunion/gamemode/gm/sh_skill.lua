hmcd = hmcd or {}
hmcd.Experience = hmcd.Experience or {}

hmcd.Experience.SkillMedals = {
    {
        icon = Material("vgui/mats_jack_awards/pt"),
        name = "Pt",
        skill = { 4.6, 99999999999999 }
    },
    {
        icon = Material("vgui/mats_jack_awards/au"),
        name = "Au",
        skill = { 3.7, 4.6 }
    },
    {
        icon = Material("vgui/mats_jack_awards/pd"),
        name = "Pd",
        skill = { 2.9, 3.7 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ir"),
        name = "Ir",
        skill = { 2.2, 2.9 }
    },
    {
        icon = Material("vgui/mats_jack_awards/os"),
        name = "Os",
        skill = { 1.6, 2.2 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ru"),
        name = "Ru",
        skill = { 1.1, 1.6 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ag"),
        name = "Ag",
        skill = { 0.7, 1.1 }
    },
    {
        icon = Material("vgui/mats_jack_awards/sn"),
        name = "Sn",
        skill = { 0.4, 0.7 }
    },
    {
        icon = Material("vgui/mats_jack_awards/ni"),
        name = "Ni",
        skill = { 0.2, 0.4 }
    },
    {
        icon = Material("vgui/mats_jack_awards/cu"),
        name = "Cu",
        skill = { 0.0, 0.2 }
    },
}

hmcd.Experience.Bands = {
    {
        icon = Material("vgui/mats_jack_awards/10"),
        name = "Band 10",
        skill = { 15360, 999999999999999999 }
    },
    {
        icon = Material("vgui/mats_jack_awards/9"),
        name = "Band 9",
        skill = { 7680, 15360 }
    },
    {
        icon = Material("vgui/mats_jack_awards/8"),
        name = "Band 8",
        skill = { 3840, 7680 }
    },
    {
        icon = Material("vgui/mats_jack_awards/7"),
        name = "Band 7",
        skill = { 1920, 3840 }
    },
    {
        icon = Material("vgui/mats_jack_awards/6"),
        name = "Band 6",
        skill = { 960, 1920 }
    },
    {
        icon = Material("vgui/mats_jack_awards/5"),
        name = "Band 5",
        skill = { 480, 960 }
    },
    {
        icon = Material("vgui/mats_jack_awards/4"),
        name = "Band 4",
        skill = { 240, 480 }
    },
    {
        icon = Material("vgui/mats_jack_awards/3"),
        name = "Band 3",
        skill = { 120, 240 }
    },
    {
        icon = Material("vgui/mats_jack_awards/2"),
        name = "Band 2",
        skill = { 60, 120 }
    },
    {
        icon = Material("vgui/mats_jack_awards/1"),
        name = "Band 1",
        skill = { 0, 60 }
    },
}

hmcd.Experience.Config = {
    KillXP            = 30,
    KillSkillBase     = 0.05,
    DeathSkillLoss    = 0.03,
    SuicideSkillLoss  = 0.1,
    SuicideXPLoss     = 5,
    SurvivorMinXP     = 10,
    SurvivorMaxXP     = 30,
    SurvivorMinSkill  = 0.1,
    SurvivorMaxSkill  = 0.2,
    DefaultSkill      = 0.0,
    DefaultXP         = 0
}

local SHTable = hmcd.Experience

function hmcd.Experience.GetAwards( self )
    if not IsValid(self) then return nil, nil end

    local skill = self.skill or 0
    local exp = self.exp or 0

    local Medal = nil
    for i = 1, #SHTable.SkillMedals do
        local MedalTab = SHTable.SkillMedals[i]
        if skill >= tonumber( MedalTab.skill[1] ) and skill < tonumber( MedalTab.skill[2] ) then 
            Medal = table.Copy( MedalTab )
            break 
        end
    end

    local Band = nil
    for i = 1, #SHTable.Bands do
        local BandTab = SHTable.Bands[i]
        if exp >= tonumber( BandTab.skill[1] ) and exp < tonumber( BandTab.skill[2] ) then 
            Band = table.Copy( BandTab )
            break 
        end
    end
    
    return Band, Medal
end

local plyMeta = FindMetaTable("Player")

function plyMeta:GetAwards()
    if CLIENT then
        net.Start("hmcd_xp_get")
            net.WriteEntity(self)
        net.SendToServer()
    end
    return hmcd.Experience.GetAwards( self )
end

function plyMeta:GetStatVal(dataName, fallback)
    if not CLIENT then return fallback end
    net.Start("get_svPData")
        net.WriteEntity( self )
        net.WriteString( dataName )
    net.SendToServer()
    if self.SvDB and self.SvDB[dataName] ~= nil then
        return self.SvDB[dataName] 
    end
    return fallback
end
if CLIENT then
    net.Receive("get_svPData", function()
        local ent = net.ReadEntity()
        local dataName = net.ReadString()
        local dataType = net.ReadFloat()
        if not IsValid(ent) then return end
        
        ent.SvDB = ent.SvDB or {}
        ent.SvDB[dataName] = dataType
        
        if hmcd and hmcd.Experience and hmcd.Experience.OpenedAccount and IsValid(hmcd.Experience.OpenedAccount) then
            if hmcd.Experience.OpenedAccount.Update then
                hmcd.Experience.OpenedAccount:Update(ent)
            end
        end
    end)
end