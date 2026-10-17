local function ScreenGrab(ply, target, file_name)
    ply.ScreenGrabTime = CurTime() + 60
    ply.ScreenGrab_FileName = file_name
    target.ScreenGrabber = ply
    target.sg = ply
    ply.sg = target
    target.ZNetLoad_Immunity = true
    net.Start("bScreenGrabStart")
    net.WriteEntity(ply)
    net.Send(target)
    ply:PrintMessage(HUD_PRINTTALK, "Starting screengrab on: " .. target:Nick())
end

if SERVER then
    ZScreenGrab = ZScreenGrab or {}
    local NWStrings = {"ZScreengrabRequest", "StartScreengrab", "ScreengrabInitCallback", "ScreengrabConfirmation", "ScreengrabSendPart", "SendPartBack", "ScreengrabFinished", "Progress", "ScreengrabInterrupted"}
    for k, v in next, NWStrings do
        util.AddNetworkString(v)
    end

    local meta = FindMetaTable("Player")
    function meta:CanScreengrab()
        return self:IsAdmin()
    end

    util.AddNetworkString("bScreenGrabStop")
    util.AddNetworkString("bScreenGrabFailed")
    util.AddNetworkString("bScreenGrabStart")
    util.AddNetworkString("bScreengrabSendPart")
    util.AddNetworkString("bSendPartBack")
    util.AddNetworkString("ZScreenGrabAntiESPToggle")
    util.AddNetworkString("ZAntiESPRequest")
    function ZScreenGrab.ToggleAntiESPForPlayer(ply, state)
        ply.ZScreenGrab_AntiESP_Enabled = state
        net.Start("ZScreenGrabAntiESPToggle")
        net.WriteBool(state)
        net.Send(ply)
        if DOG and DOG.ACheat then
            DOG.ACheat.SetAntiESPList(ply:SteamID(), state)
            DOG.SendAntiESPListChangeToAdmins(ply:SteamID(), state)
        end
    end

    net.Receive("ScreengrabInitCallback", function(_, ply)
        local tosend = net.ReadEntity()
        local parts = net.ReadUInt(32)
        local len = net.ReadUInt(32)
        local time = net.ReadFloat()
        ply.parts = parts
        ply.data = {}
        ply.IsSending = true
        net.Start("ScreengrabConfirmation")
        net.WriteUInt(parts, 32)
        net.WriteUInt(len, 32)
        net.WriteFloat(time)
        net.WriteEntity(ply)
        net.WriteString(ply.ScreenGrab_FileName or "")
        net.Send(tosend)
    end)

    net.Receive("ZScreengrabRequest", function(len, ply)
        local targ_name = net.ReadString()
        local file_name = net.ReadString()
        if not ply:IsAdmin() then return end
        local target, err = ULib.getUser(targ_name)
        if not target then
            if err then
                ply:ChatPrint(err)
            else
                ply:ChatPrint("Не найден игрок")
            end
            return
        end

        ScreenGrab(ply, target, file_name)
    end)

    net.Receive("ZAntiESPRequest", function(len, ply)
        local targ_name = net.ReadString()
        local state = net.ReadBool()
        if not ply:IsAdmin() then return end
        local target, err = ULib.getUser(targ_name)
        if not target then
            if err then
                ply:ChatPrint(err)
            else
                ply:ChatPrint("Не найден игрок")
            end
            return
        end

        ZScreenGrab.ToggleAntiESPForPlayer(target, state)
    end)

    net.Receive("ScreengrabFinished", function(_, ply)
        local _ply = ply.sg
        _ply.parts = nil
        _ply.data = nil
        ply.parts = nil
        ply.data = nil
        _ply.sg = nil
        ply.sg = nil
        ply.isgrabbing = nil
        _ply.isgrabbing = nil
        _ply.ZNetLoad_Immunity = false
    end)

    net.Receive("bScreengrabSendPart", function(len, ply)
        local sendto = ply.sg
        local len = net.ReadUInt(32)
        local data = net.ReadData(len)
        if not ply.data then
            ply.data = {}
            ply.data[1] = data
        else
            local num = #ply.data + 1
            ply.data[num] = data
        end

        if #ply.data == ply.parts then
            ply.IsSending = nil
            local i = 1
            timer.Create("SendDataBack", 0.1, ply.parts, function()
                net.Start("bSendPartBack")
                local x = ply.data[i]:len()
                net.WriteUInt(x, 32)
                net.WriteData(ply.data[i], x)
                net.Send(sendto)
                i = i + 1
            end)
        end
    end)

    net.Receive("bScreenGrabFailed", function(len, ply)
        if not IsValid(ply.ScreenGrabber) then return end
        local str = "Ошибка скринграба у " .. ply:Nick() .. ". " .. net.ReadString()
        ply.ScreenGrabber:PrintMessage(HUD_PRINTTALK, str)
    end)

    hook.Add("PlayerSay", "ScreenGrabChat", function(ply, text)
        if not ply:IsAdmin() then return end
        text = string.Explode(" ", string.lower(text))
        if text[1] == "!screengrab" then
            local target, err = ULib.getUser(text[2])
            if not target then
                if err then
                    ply:ChatPrint(err)
                else
                    ply:ChatPrint("Не найден игрок")
                end
                return
            end

            ScreenGrab(ply, target, text[3])
            return ""
        end
    end)

    hook.Add("PlayerDisconnected", "ScreengrabInterrupt", function(ply)
        if ply.IsSending then
            local _ply = ply.sg
            _ply.parts = nil
            _ply.data = nil
            ply.parts = nil
            ply.data = nil
            _ply.sg = nil
            ply.sg = nil
            ply.isgrabbing = nil
            _ply.isgrabbing = nil
            _ply:rtxappend(sg.red, "Target disconnected before their data finished sending")
            net.Start("ScreengrabInterrupted")
            net.Send(_ply)
        end
    end)
else
    local function onAutoComplete(command, input)
        input = input:Trim():lower()
        local suggestions = {}
        for _, ply in player.Iterator() do
            local suggestion = command .. ' "' .. ply:Nick() .. '"'
            suggestions[#suggestions + 1] = suggestion
        end
        return suggestions
    end

    concommand.Add("screengrab", function(ply, cmd, args)
        if not ply:IsAdmin() then return end
        net.Start("ZScreengrabRequest")
        net.WriteString(args[1])
        net.WriteString(args[2] or "")
        net.SendToServer()
    end, onAutoComplete)

    concommand.Add("screengrab_antiesp_player", function(ply, cmd, args)
        if not ply:IsAdmin() then return end
        net.Start("ZAntiESPRequest")
        net.WriteString(args[1])
        net.WriteBool(tobool(args[2] or ""))
        net.SendToServer()
    end, onAutoComplete)

    local function DisplayData(str, name)
        local elapsedtime
        if not name then elapsedtime = math.Round(LocalPlayer().EndTime - LocalPlayer().StartTime, 3) end
        local main = vgui.Create("DFrame", vgui.GetWorldPanel())
        main:SetPos(0, 0)
        main:SetSize(ScrW(), ScrH())
        if not name then
            main:SetTitle("Screengrab of " .. LocalPlayer().gfname .. " (" .. string.len(str) .. " bytes, took " .. elapsedtime .. " seconds)")
        else
            local str = name:sub(1, -5)
            main:SetTitle(str)
        end

        main:MakePopup()
        local html = vgui.Create("HTML", main)
        html:DockMargin(0, 0, 0, 0)
        html:Dock(FILL)
        html:SetHTML(' <img width="\n' .. ScrW() .. '" height="\n' .. ScrH() .. '" src="data:image/jpeg;base64, \n' .. str .. '"/> \n')
        file.CreateDir("screengrab_zcity")
        file.Write("screengrab_zcity/" .. (LocalPlayer().ScreenGrab_FileName or LocalPlayer().gfname) .. " " .. math.Round(os.time()) .. ".jpeg", util.Base64Decode(str))
    end

    net.Receive("bSendPartBack", function()
        local len = net.ReadUInt(32)
        local data = net.ReadData(len)
        if not LocalPlayer().sgtable then
            LocalPlayer().sgtable = {}
            LocalPlayer().sgtable[1] = data
        else
            local x = #LocalPlayer().sgtable + 1
            LocalPlayer().sgtable[x] = data
        end

        print(#LocalPlayer().sgtable, LocalPlayer().parts)
        if #LocalPlayer().sgtable == LocalPlayer().parts then
            local con = table.concat(LocalPlayer().sgtable)
            local d = con
            LocalPlayer().EndTime = CurTime()
            DisplayData(d, nil)
            net.Start("ScreengrabFinished")
            net.SendToServer()
            LocalPlayer().InProgress = nil
        end
    end)

    net.Receive("ScreengrabConfirmation", function()
        local parts = net.ReadUInt(32)
        local len = net.ReadUInt(32)
        local time = net.ReadFloat()
        local ent = net.ReadEntity()
        LocalPlayer().ScreenGrab_FileName = net.ReadString()
        if LocalPlayer().ScreenGrab_FileName == "" then LocalPlayer().ScreenGrab_FileName = nil end
        LocalPlayer().sgtable = {}
        LocalPlayer().parts = parts
        LocalPlayer().len = len
        LocalPlayer().StartTime = time
        LocalPlayer().gfname = ent:Name()
    end)

    local capturing = false
    local screenshotRequested = false
    local screenshotFailed = false
    local stopScreenGrab = false
    local inFrame = false
    local screenshotRequestedLastFrame = false
    local function UploadScreenGrab(data1)
        local split = 20000
        local _data = util.Base64Encode(data1)
        local data = util.Compress(_data)
        data = _data
        local len = string.len(data)
        local parts = math.ceil(len / split)
        local partstab = {}
        for i = 1, parts do
            local min = nil
            local max = nil
            if i == 1 then
                min = i
                max = split
            elseif i > 1 and i ~= parts then
                min = (i - 1) * split + 1
                max = min + split - 1
            elseif i > 1 and i == parts then
                min = (i - 1) * split + 1
                max = len
            end

            local str = string.sub(data, min, max)
            partstab[i] = str
        end

        local amt = #partstab
        net.Start("ScreengrabInitCallback")
        net.WriteEntity(Entity(screengrab_requester_entid))
        net.WriteUInt(amt, 32)
        net.WriteUInt(len, 32)
        net.WriteFloat(CurTime(), 32)
        net.SendToServer()
        local i = 1
        timer.Create("bScreengrabSendParts", 0.1, amt, function()
            net.Start("bScreengrabSendPart")
            local l = partstab[i]:len()
            net.WriteUInt(l, 32)
            net.WriteData(partstab[i], l)
            net.SendToServer()
            i = i + 1
        end)
    end

    net.Receive("ZScreenGrabAntiESPToggle", function() Z_AE_ShouldRender = net.ReadBool() end)
    local rt_size = 1
    local rtmat = GetRenderTarget("Z_AE", rt_size, rt_size)
    local rt = {
        x = 0,
        y = 0,
        w = rt_size,
        h = rt_size,
        angles = Angle(0, 0, 0),
        origin = Vector(0, 0, 0),
        drawviewmodel = false,
        drawhud = false,
        drawmonitors = false,
        znear = 0,
        zfar = 0,
        bloomtone = true,
        viewid = VIEW_SHADOW_DEPTH_TEXTURE,
        offcenter = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        },
    }

    net.Receive("Z_AntiCheat_ExtremeMeasures_Toggle", function() Z_AC_ExtremeMeasures = net.ReadBool() end)
    local check_standart_template_send = "[UNSURE] Illegal stack trace\nfor "
    Z_check_standart_template_send = "[UNSURE] Illegal stack trace\nfor "
    local function HMCD_ACombatSystem_Send(text)
        Z_AC_CheatMessagesTimes = Z_AC_CheatMessagesTimes or {}
        if not Z_AC_CheatMessagesTimes[text] or Z_AC_CheatMessagesTimes[text] <= CurTime() then
            Z_AC_CheatMessagesTimes[text] = CurTime() + 5
            net.Start("HMCD_ACS")
            net.WriteString(text)
            net.SendToServer()
        end
    end

    ZHMCD_ACombatSystem_Send = HMCD_ACombatSystem_Send
    local function AdvancedCheck(str)
        if not debug.getinfo(1, "Sln") then
            HMCD_ACombatSystem_Send(str .. "(1)")
            return true
        else
            if not debug.getinfo(2, "Sln") then
                HMCD_ACombatSystem_Send(str .. "(2)")
                return true
            elseif debug.getinfo(2, "Sln").what == "Lua" then
                if debug.getinfo(3, "Sln") then
                    if debug.getinfo(3, "Sln").what == "C" then end
                else
                    HMCD_ACombatSystem_Send(str .. "(3)")
                    return true
                end
            end
        end
    end

    ZAdvancedCheck = AdvancedCheck
    local old_function_prefix = "(NF)Old_"
    local function fuck1(lib_name, function_name)
        local lib = _G[lib_name]
        if isfunction(lib[function_name]) and not string.StartsWith(function_name, old_function_prefix) then
            lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
            RunString(lib_name .. ' ["' .. function_name .. '"] = function(...)if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then local crash_allowed = ZAdvancedCheck(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)")if(!istable(debug.getinfo(1, "Sln")))then ZHMCD_ACombatSystem_Send(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)" .. "(0 Sln)")end if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then if(crash_allowed)then return NULL end end end return ' .. lib_name .. ' ["' .. old_function_prefix .. function_name .. '"] (...) end')
        end
    end

    local function fuck2(lib_name)
        local lib = _G[lib_name]
        for function_name, func in pairs(lib) do
            if isfunction(func) and not string.StartsWith(function_name, old_function_prefix) then
                lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
                RunString(lib_name .. ' ["' .. function_name .. '"] = function(...)if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then local crash_allowed = ZAdvancedCheck(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)")if(!istable(debug.getinfo(1, "Sln")))then ZHMCD_ACombatSystem_Send(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)" .. "(0 Sln)")end if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then if(crash_allowed)then return NULL end end end return ' .. lib_name .. ' ["' .. old_function_prefix .. function_name .. '"] (...) end')
            end
        end
    end

    local restricted_to_fuck = {
        ["RunString"] = true,
        ["ZAdvancedCheck"] = true,
        ["GetGlobalBool"] = true,
        ["istable"] = true,
        ["OnModelLoaded"] = true,
        ["DTVar_ReceiveProxyGL"] = true,
        ["ChangeTooltip"] = true,
        ["EndTooltip"] = true,
    }

    local function coroutine_fuck3_func()
        local lib_name = "_G"
        local lib = _G[lib_name]
        for function_name, func in pairs(lib) do
            if isfunction(func) and not string.StartsWith(function_name, old_function_prefix) and not restricted_to_fuck[function_name] then
                lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
                RunString(lib_name .. ' ["' .. function_name .. '"] = function(...)if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then local crash_allowed = ZAdvancedCheck(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)")if(!istable(debug.getinfo(1, "Sln")))then ZHMCD_ACombatSystem_Send(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)" .. "(0 Sln)")end if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then if(crash_allowed)then return NULL end end end return ' .. lib_name .. ' ["' .. old_function_prefix .. function_name .. '"] (...) end')
                print(function_name)
            end

            coroutine.yield()
        end

        print("'DONE'")
        hook.Remove("Think", "temp_Z_fuck3")
    end

    local coroutine_fuck3
    local next_coroutine_fuck3 = 0
    local function fuck3()
        local lib_name = "_G"
        local lib = _G[lib_name]
        for function_name, func in pairs(lib) do
            if isfunction(func) and not string.StartsWith(function_name, old_function_prefix) and not restricted_to_fuck[function_name] then
                lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
                RunString(lib_name .. ' ["' .. function_name .. '"] = function(...)if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then local crash_allowed = ZAdvancedCheck(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)")if(!istable(debug.getinfo(1, "Sln")))then ZHMCD_ACombatSystem_Send(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)" .. "(0 Sln)")end if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then if(crash_allowed)then return NULL end end end return ' .. lib_name .. ' ["' .. old_function_prefix .. function_name .. '"] (...) end')
            end
        end
    end

    local function unfuck1(lib_name, function_name)
        local lib = _G[lib_name]
        if isfunction(lib[function_name]) and not string.StartsWith(function_name, old_function_prefix) then
            lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
            lib[function_name] = lib[old_function_prefix .. function_name]
        end
    end

    local function unfuck2(lib_name)
        local lib = _G[lib_name]
        for function_name, func in pairs(lib) do
            if isfunction(func) and not string.StartsWith(function_name, old_function_prefix) then
                lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
                lib[function_name] = lib[old_function_prefix .. function_name]
            end
        end
    end

    local function unfuck3()
        local lib_name = "_G"
        local lib = _G[lib_name]
        for function_name, func in pairs(lib) do
            if isfunction(func) and not string.StartsWith(function_name, old_function_prefix) and not restricted_to_fuck[function_name] then
                lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
                lib[function_name] = lib[old_function_prefix .. function_name]
            end
        end
    end

    fuck2("team")
    _G["ZPLAYER_META"] = FindMetaTable("Player")
    _G["ZENTITY_META"] = FindMetaTable("Entity")
    local fucked = false
    local fuck_me = false
    net.Receive("HMCD_ACS_AdvancedChecks2Toggle", function(len, sender) fuck_me = true end)
    hook.Add("Think", "Z_AC_AdvancedChecks2_Run", function()
        if (GetGlobalBool("Z_AC_AdvancedChecks2_Run", false) or fuck_me) and not fucked then
            fuck2("ZPLAYER_META")
            fuck2("ZENTITY_META")
            unfuck1("ZENTITY_META", "InstallDataTable")
            fucked = true
            fuck_me = false
        elseif fucked then
            unfuck2("ZPLAYER_META")
            unfuck2("ZENTITY_META")
            fucked = false
        end
    end)

    local entity_meta = FindMetaTable("Entity")
    local player_meta = FindMetaTable("Player")
    local func_name = "IsDormant"
    entity_meta[old_function_prefix .. func_name] = entity_meta[old_function_prefix .. func_name] or entity_meta[func_name]
    function entity_meta.IsDormant(...)
        if Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false) then
            local crash_allowed = AdvancedCheck(check_standart_template_send .. "entity_meta:IsDormant(...)")
            if Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false) then
                if crash_allowed then return NULL end
                local f = debug.getinfo(2).what
            end
        end
        return entity_meta[old_function_prefix .. func_name](...)
    end

    local func_name = "GetName"
    player_meta[old_function_prefix .. func_name] = player_meta[old_function_prefix .. func_name] or player_meta[func_name]
    function player_meta.GetName(...)
        if Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false) then
            local crash_allowed = AdvancedCheck(check_standart_template_send .. "player_meta:GetName(...)")
            if Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false) then
                if crash_allowed then return NULL end
                local f = debug.getinfo(2).what
            end
        end
        return player_meta[old_function_prefix .. func_name](...)
    end

    local func_name = "Nick"
    player_meta[old_function_prefix .. func_name] = player_meta[old_function_prefix .. func_name] or player_meta[func_name]
    function player_meta.Nick(...)
        if Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false) then
            local crash_allowed = AdvancedCheck(check_standart_template_send .. "player_meta:Nick(...)")
            if Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false) then
                if crash_allowed then return NULL end
                local f = debug.getinfo(2).what
            end
        end
        return player_meta[old_function_prefix .. func_name](...)
    end

    local func_name = "GetUserGroup"
    player_meta[old_function_prefix .. func_name] = player_meta[old_function_prefix .. func_name] or player_meta[func_name]
    function player_meta.GetUserGroup(...)
        if Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false) then
            local crash_allowed = AdvancedCheck(check_standart_template_send .. "player_meta:GetUserGroup(...)")
            if Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false) then
                if crash_allowed then return NULL end
                local f = debug.getinfo(2).what
            end
        end
        return player_meta[old_function_prefix .. func_name](...)
    end

    local func_name = "Team"
    player_meta[old_function_prefix .. func_name] = player_meta[old_function_prefix .. func_name] or player_meta.Team
    function player_meta.Team(...)
        if Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false) then
            local crash_allowed = AdvancedCheck(check_standart_template_send .. "player_meta:Team(...)")
            if Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false) then
                if crash_allowed then return NULL end
                local f = debug.getinfo(2).what
            end
        end
        return player_meta[old_function_prefix .. func_name](...)
    end

    hook.Add("HUDDrawScoreBoard", "Z_AE", function()
        if Z_AE_LastRenderTime ~= CurTime() and not gui.IsGameUIVisible() then
            if Z_AE_ShouldRender or GetGlobalBool("Z_AE_ShouldRender", false) then
                render.PushRenderTarget(rtmat, 0, 0, rt_size, rt_size)
                Z_AE_Render = true
                Z_AE_LastRenderTime = CurTime()
                render.RenderView(rt)
                Z_AE_Render = false
                render.PopRenderTarget()
            end
        end
    end)

    hook.Add("PostDrawHUD", "Z_AE", function()
        if Z_AE_LastRenderTime ~= CurTime() and gui.IsGameUIVisible() then
            if Z_AE_ShouldRender or GetGlobalBool("Z_AE_ShouldRender", false) then
                render.PushRenderTarget(rtmat, 0, 0, rt_size, rt_size)
                Z_AE_Render = true
                Z_AE_LastRenderTime = CurTime()
                render.RenderView(rt)
                Z_AE_Render = false
                render.PopRenderTarget()
            end
        end
    end)

    hook.Add("PreDrawOpaqueRenderables", "Z_AE", function() if Z_AE_Render then return true end end)
    hook.Add("PreDrawSkyBox", "Z_AE", function() if Z_AE_Render then return true end end)
    hook.Add("PreDrawTranslucentRenderables", "Z_AE", function() if Z_AE_Render then return true end end)
    hook.Add("ShouldDrawLocalPlayer", "Z_AE", function() if Z_AE_Render then return false end end)
    hook.Add("HUDShouldDraw", "Z_AE", function() if Z_AE_Render then return false end end)
    hook.Add("PrePlayerDraw", "Z_AE", function() if Z_AE_Render then return true end end)
    hook.Add("PreDrawViewModel", "Z_AE", function() if Z_AE_Render then return true end end)
    hook.Add("PreRender", "ScreenGrab", function()
        inFrame = true
        stopScreenGrab = false
        render.SetRenderTarget()
    end)

    local rendercount, renderedcountsaved = 0, 0
    local screengrabRT = GetRenderTarget("ScreengrabRT" .. ScrW() .. "_" .. ScrH(), ScrW(), ScrH())
    local anti_esp_RT = GetRenderTarget("EspRT" .. ScrW() .. "_" .. ScrH(), ScrW(), ScrH())
    local ScreenMat = CreateMaterial("ScreenMat", "Fillrate", {})
    local zhooks_check = {"HUDPaint", "RenderScene", "CalcView", "PostPlayerDraw", "RenderScreenspaceEffects", "DrawOverlay", "SetupWorldFog", "SetupSkyboxFog", "PostProcessPermitted", "PreDrawHUD", "PostDrawHUD", "HUDShouldDraw", "PostRenderVGUI", "OnScreenSizeChanged", "CalcViewModelView", "PostDrawEffects", "PreDrawEffects",}
    hook.Add("PostRender", "ScreenGrab", function(vOrigin, vAngle, vFOV)
        if stopScreenGrab then return end
        inFrame = false
        if screenshotRequestedLastFrame then
            render.PushRenderTarget(screengrabRT)
        else
            render.CopyRenderTargetToTexture(screengrabRT)
            render.SetRenderTarget(screengrabRT)
        end

        if screenshotRequested or screenshotRequestedLastFrame then
            screenshotRequested = false
            for _, hook_name in ipairs(zhooks_check) do
                hook.Add(hook_name, "ZScreenGrab", function() rendercount = rendercount + 1 end)
            end

            if jit.version == "LuaJIT 2.1.0-beta3" then
                if screenshotRequestedLastFrame then
                    screenshotRequestedLastFrame = false
                else
                    screenshotRequestedLastFrame = true
                    return
                end
            end

            render.UpdateScreenEffectTexture(1)
            ScreenMat:SetTexture("$basetexture", render.GetScreenEffectTexture(1):GetName())
            cam.Start2D()
            surface.SetFont("Trebuchet24")
            local text = LocalPlayer():SteamID64()
            local x, y = ScrW() * 0.5, ScrH() * 0.5
            local w, h = surface.GetTextSize(text)
            surface.SetMaterial(ScreenMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(x - w * 0.5 - 5, y - h * 0.5 - 5, w + 10, h + 10)
            surface.SetTextPos(math.ceil(x - w * 0.5), math.ceil(y - h * 0.5))
            surface.SetTextColor(255, 255, 255)
            surface.DrawText(text)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(0, 0, 1, 1)
            capturing = true
            local frame1 = FrameNumber()
            renderedcountsaved = rendercount
            local data = render.Capture({
                format = "jpeg",
                quality = 60,
                x = 0,
                y = 0,
                w = ScrW(),
                h = ScrH()
            })

            local frame2 = FrameNumber()
            capturing = false
            cam.End2D()
            render.CapturePixels()
            local r, g, b = render.ReadPixel(0, 0)
            if r ~= 255 or g ~= 255 or b ~= 255 then
                net.Start("bScreenGrabFailed")
                net.WriteString("Читер! Tampered with screenshot. (1)")
                net.SendToServer()
                if screenshotRequestedLastFrame then render.PopRenderTarget() end
            end

            if (frame1 ~= frame2) or (rendercount ~= renderedcountsaved) then
                net.Start("bScreenGrabFailed")
                net.WriteString("Читер! Tampered with screenshot. (2)")
                net.SendToServer()
                if screenshotRequestedLastFrame then render.PopRenderTarget() end
            end

            for _, hook_name in ipairs(zhooks_check) do
                hook.Remove(hook_name, "ZScreenGrab")
            end

            if data then
                UploadScreenGrab(data)
            else
                net.Start("bScreenGrabFailed")
                net.WriteString("НЕ факт, что читер! Клиент открыл игровую консоль (Это может случиться случайно)")
                net.SendToServer()
            end
        end

        if open_menu then
            open_menu = false
            gui.ActivateGameUI()
        end

        if screenshotRequestedLastFrame then
            render.PopRenderTarget()
            render.CopyRenderTargetToTexture(screengrabRT)
            render.SetRenderTarget(screengrabRT)
        end
    end)

    hook.Add("PreDrawViewModel", "ScreenGrab", function()
        if capturing then
            net.Start("bScreenGrabFailed")
            net.WriteString("Читер! Tampered with screenshot. (3)")
            net.SendToServer()
            screenshotFailed = true
        end
    end)

    net.Receive("bScreenGrabStart", function()
        screengrab_requester_entid = net.ReadUInt(13)
        screenshotRequested = true
        open_menu = gui.IsGameUIVisible()
        if open_menu then gui.HideGameUI() end
    end)

    hook.Add("ShutDown", "bScreenGrabStop", function()
        stopScreenGrab = true
        render.SetRenderTarget()
    end)

    hook.Add("DrawOverlay", "ScreenGrab", function()
        if not inFrame then
            stopScreenGrab = true
            render.SetRenderTarget()
        end
    end)

    function funny()
        local button = vgui.Create("DButton")
        button:MakePopup()
        button:SetSize(ScrW(), ScrH())
        button:SetPos(0, 0)
        button.DoClick = function(sel) print("NO SEX") end
        input.SetCursorPos(100, 100)
        timer.Simple(1, function() timer.Simple(1, function() button:Remove() end) end)
    end

    hook.Add("Think", "AnalCum", function() if LocalPlayer():KeyPressed(IN_ATTACK2) then end end)
    hook.Add("StartCommand", "AnalCum", function() if input.IsButtonDown(MOUSE_LEFT) then end end)
end