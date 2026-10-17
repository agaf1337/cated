RunConsoleCommand("sv_visiblemaxplayers", "20")
local whitelist = {
    ["76561199148042205"] = true, -- моль (навальный)
    ["76561199022280769"] = true, -- agent
    ["76561199126041062"] = true, -- medic
    ["76561199815381722"] = true, -- sveoo // incident: пробирочный (11.05.2026)
    ["76561199102730277"] = true, // niko
    ["76561199052784844"] = true, //валя , бигчикен хит, улькора бля ну да
    ["76561198948912841"] = true, //pokumeka
//ЗАЯВОЧНЫЕ

    ["76561199674130729"] = true, //zinnyx
    ["76561199869237141"] = true, // frex
    ["76561199406383730"] = true, // sleepwalker
    ["76561199177615202"] = true, // митяй слоты
    ["76561199112161016"] = true, // blade
    ["76561198963528067"] = true, // vigu
    ["76561199572391192"] = true, // pa1ka
    ["76561199177386941"] = true, // colatik
    ["76561199053239971"] = true, //ptsr instructor
    ["76561199508512274"] = true, //cr33py
    ["76561199763109258"] = true, //alexander.lua AKA sanya dimple
    ["76561199476151555"] = true, //кичигин моноколесо
    ["76561199204392748"] = true, //neon taburet
    ["76561198421243822"] = true, //greh // пидорас? хуй сосешь? ты похож на пидораса 
    ["76561199379692156"] = true, //pilgrim AKA solver
    ["76561199095961501"] = true, //fuzzodared
    ["76561199370031359"] = true, //viktor darit
    ["76561199682890934"] = true, //shpecaryi aka episkop
    ["76561199445097211"] = true, //neon fridge
}

local blacklist = {
    ["76561199413732059"] = "хукер", // lamiones
    ["76561199515763250"] = "хукер", // tokarb
    ["76561198975861212"] = "хукер", // babuch1y
    ["76561198976349450"] = "хукер", // t1ne
    ["76561199010177340"] = "заявка отклонена, комиградер хукер.", //diplomat
    ["76561199346692655"] = "заявка отклонена, комиградер хукер.", //white rose
    ["76561199139371697"] = "удален из вайтлиста, векад тебе нужно лечится и уметь прощать людей.", //v3kad
    ["76561199038803940"] = "пошел нахуй я твою мать ебал ооо мегеле ооо меге", -- suffix
    ["76561198999158880"] = "двухсотый", -- makaroshek (incident 06.05.2026)
    ["76561199049624925"] = "зоофил ди отсюда наху", -- tovarich fox
    ["76561199509987140"] = "двухсотый", //markiz
    ["76561199188236465"] = "двухсотый", //vectira
    ["76561199059004026"] = "пошол нахуй" //xylan
}



local priority = {
    ["76561199022280769"] = true, //agent
    ["76561199126041062"] = true, -- medic
}

local function SimpleLog(name, steamID64, ipAddress, status)
    local text = string.format("[%s] player %s (%s) %s — %s\n", os.date("%X"), name, steamID64, ipAddress, status)
    file.Append("connect_logs.txt", text)
    print(text)
end

hook.Add("CheckPassword", "kkkg2jig4igj2g2igfk", function(steamID64, ipAddress, svPassword, clPassword, name)
    local steamid = util.SteamIDFrom64(steamID64)
    
    if blacklist[steamID64] then
       SimpleLog(name, steamID64, ipAddress, "banned for "..blacklist[steamID64])
       return false, blacklist[steamID64]     
    end
        
    if not whitelist[steamID64] and not whitelist[steamid] then
        SimpleLog(name, steamID64, ipAddress , "not in whitelist.")
        return false, "not in whitelist, sorry! discord.gg/A2SUBfjAnR"
    end
    local playerCount = player.GetCount()
    local publicLimit = 20

    if playerCount >= publicLimit then
        if not priority[steamID64] then
            return false, "Server is full!"
        end
    end
end)

hook.Add("PlayerCheckLimit", "ULg2wq4gaszdgfeck", function()
return true
end)