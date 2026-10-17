local CATEGORY_NAME = "Homicide"

local function VotesBoxDone(t)
    local winner, winnernum = nil, 0
    for id, num in pairs(t.results) do
        if num > winnernum then winner = id winnernum = num end
    end
    if winner ~= 1 or (winnernum / t.voters) < 0.6 then
        local s = "VotesBox FAILED. Need 60% Yes. (" .. (t.results[1] or 0) .. "/" .. t.voters .. ")"
        ULib.tsay(_, s) ulx.logString(s) Msg(s.."\n")
        return
    end
    local s = "VotesBox PASSED! (" .. winnernum .. "/" .. t.voters .. ") Random map + Sandbox"
    ULib.tsay(_, s) ulx.logString(s) Msg(s.."\n")

    if SERVER then
        file.Write("votesbox_forcesandbox.txt", "1")
        Rounds = {"sandbox"}
        if GAMEMODE then GAMEMODE.RoundNext="sandbox" GAMEMODE.RoundNextType=0 end
        local maps = file.Find("maps/*.bsp", "GAME")
        local cur = string.lower(game.GetMap())
        local out = {}
        for _, f in ipairs(maps) do
            local m = string.lower(string.StripExtension(f))
            if m ~= cur and not m:find("^bg_") and not m:find("^background") and not m:find("^gui_") and not m:find("^style_") and m~="gm_flatgrass" and m~="gm_construct" then
                table.insert(out, m)
            end
        end
        local nextMap = table.Random(out) or "gm_construct"
        ULib.tsay(_, "Next map: " .. nextMap)
        timer.Simple(5, function() ULib.consoleCommand("changelevel " .. nextMap .. "\n") end)
    end
end

function ulx.votesbox(calling_ply)
    if ulx.voteInProgress then
        ULib.tsayError(calling_ply, "There is already vote going!", true)
        return
    end
    ulx.doVote("VoteSBox: Sandbox + random map", {"Yes", "No"}, VotesBoxDone, 30)
    ulx.fancyLogAdmin(calling_ply, "#A started VoteSBox")
end
local votesbox = ulx.command(CATEGORY_NAME, "ulx votesbox", ulx.votesbox, "!votesbox")
votesbox:defaultAccess(ULib.ACCESS_ALL)
votesbox:help("Vote for a random map and changing mode to sandbox.")

function ulx.forcefake(calling_ply, target_ply)
    if SERVER then
        if not IsValid(target_ply) then return end
        if target_ply:GetNWBool("fake", false) or target_ply.fake then
            ULib.tsayError(calling_ply, "Already in fake", true) return
        end
        if not target_ply:Alive() then
            ULib.tsayError(calling_ply, target_ply.." is dead!", true) return
        end
        if Faking then Faking(target_ply) else ULib.tsayError(calling_ply, "err Faking()", true) return end
    end
    ulx.fancyLogAdmin(calling_ply, "#A forced #T into ragdoll", target_ply)
end
local forcefake = ulx.command(CATEGORY_NAME, "ulx forcefake", ulx.forcefake, "!forcefake")
forcefake:addParam{ type=ULib.cmds.PlayerArg }
forcefake:defaultAccess(ULib.ACCESS_ADMIN)
forcefake:help("Force fake player")

function ulx.razorvat(calling_ply, target_ply)
    if SERVER then
        target_ply:Razobrat(true)
    end
    ulx.fancyLogAdmin(calling_ply, "#A gibbed #T", target_ply)
end
local forcefake = ulx.command(CATEGORY_NAME, "ulx razorvat", ulx.razorvat, "!razorvat")
forcefake:addParam{ type=ULib.cmds.PlayerArg }
forcefake:defaultAccess(ULib.ACCESS_ADMIN)
forcefake:help("Gib player")


function ulx.endround(calling_ply)
    if SERVER and GAMEMODE and GAMEMODE.EndRound then
        GAMEMODE:EndRound(3, calling_ply)
    end
    ulx.fancyLogAdmin(calling_ply, "#A ended round")
end
local endround = ulx.command(CATEGORY_NAME, "ulx endround", ulx.endround, "!endround")
endround:defaultAccess(ULib.ACCESS_ADMIN)
endround:help("End round")

function ulx.changegamemode(calling_ply, gm)
    if SERVER then
        gm = string.lower(gm)
        if gm == "homicide" then
            local t = math.random(1,5)
            GAMEMODE.RoundNext="homicide" GAMEMODE.RoundNextType=t
            PrintMessage(HUD_PRINTTALK, "Next: Homicide - " .. ((HMCD_RoundsTypeNormalise and HMCD_RoundsTypeNormalise[t]) or t))
        elseif gm=="dm" or gm=="hl2" or gm=="sandbox" or gm=="riot" then
            GAMEMODE.RoundNext=gm GAMEMODE.RoundNextType=0
            PrintMessage(HUD_PRINTTALK, "Next: " .. gm)
        else
            ULib.tsayError(calling_ply, "homicide/dm/hl2/sandbox", true) return
        end
    end
    ulx.fancyLogAdmin(calling_ply, "#A set next gamemode to #s", gm)
end
local changegm = ulx.command(CATEGORY_NAME, "ulx changegamemode", ulx.changegamemode, "!changegamemode")
changegm:addParam{ type=ULib.cmds.StringArg, hint="homicide/dm/hl2/sandbox", completes={"homicide","dm","hl2","sandbox"}, ULib.cmds.restrictToCompletes }
changegm:defaultAccess(ULib.ACCESS_ADMIN)
changegm:help("Change next gamemode")

if SERVER then
    hook.Add("Initialize", "VotesBox_Force_Homicide", function()
        if file.Exists("votesbox_forcesandbox.txt","DATA") then
            print("VoteSBox flag -> force sandbox")
            timer.Simple(5, function() Rounds={"sandbox"} if GAMEMODE then GAMEMODE.RoundNext="sandbox" end end)
            hook.Add("Think","VotesBox_ForceThink", function()
                if not file.Exists("votesbox_forcesandbox.txt","DATA") then hook.Remove("Think","VotesBox_ForceThink") return end
                if GAMEMODE and GAMEMODE.RoundName~="sandbox" and GAMEMODE.RoundState==0 then
                    GAMEMODE.RoundNext="sandbox" Rounds={"sandbox"}
                    file.Delete("votesbox_forcesandbox.txt")
                end
            end)
        end
    end)
    concommand.Add("votesbox_clear", function(ply) if IsValid(ply) and not ply:IsAdmin() then return end file.Delete("votesbox_forcesandbox.txt") Rounds=nil ULib.tsay(_,"Flag cleared") end)
end
