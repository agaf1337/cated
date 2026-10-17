surface.CreateFont("chfont", {font = "coolvetica", size = 40, antialias = true, shadow = true, extended = true})
surface.CreateFont("chfont2", {font = "coolvetica", size = 35, antialias = true, shadow = true, extended = true})

local a1, a2, lt, le = 0, 0, 0, nil

hook.Add("PostDrawHUD", "chrdesc", function()
	local p = LocalPlayer()
	if not IsValid(p) or not p:Alive() then return end
	local noticed = {}
	local w = p:GetActiveWeapon()
	local tr = util.TraceLine({
		start = p:GetShootPos(),
		endpos = p:GetShootPos() + p:GetAimVector() * 75,
		filter = p,
		mask = MASK_SHOT
	})
	local ent = tr.Entity

	local isValidTarget = IsValid(ent) and (ent:IsPlayer() or ent:GetClass() == "prop_ragdoll") and ent ~= p

	if IsValid(w) and (w:GetClass() == "wep_jack_hmcd_hands" or w:GetClass() == "wep_jack_hmcd_brassknuckles") and isValidTarget then
		if le == ent then lt = lt + FrameTime() else le, lt = ent, 0 end
	else
		lt, le = 0, nil
		a1, a2 = 0, 0
	end

	a1 = Lerp(FrameTime() * 5, a1, (lt >= 1 and IsValid(le)) and 255 or 0)
	a2 = Lerp(FrameTime() * 2, a2, (lt >= 2.5 and IsValid(le)) and 255 or 0)

	if a1 < 1 or not IsValid(le) then return end

	local target = le
	if le:GetClass() == "prop_ragdoll" then
		local owner = le:GetNWEntity("RagdollOwner")
		if IsValid(owner) then target = owner end
	end

	local d = target:GetNWString("Character_Desc", "Nothing interesting.")
	local c = target:GetPlayerColor() or Vector(1, 1, 1)
	local txtc = Color(c.x * 175, c.y * 175, c.z * 175, a1)
	local midx, midy = ScrW() / 2, ScrH() / 2

	draw.DrawText(d, "chfont", midx, midy + 140, txtc, TEXT_ALIGN_CENTER)
    
	local s = target.ModelSex or "nonbinary"
	local prn = (s == "male" and "he's") or (s == "female" and "she's") or "they're"
	local prn2 = (s == "male" and "his") or (s == "female" and "her") or "their"
	local prn3 = (s == "male" and "He") or (s == "female" and "She") or "They"

	if target:GetNWInt("org_fat") >= 100 then
		table.insert(noticed, "You noticed that " .. prn .. " overweight.")
	end

	if target:GetNWFloat("otrub", false) and target:Alive() then
		table.insert(noticed, "You noticed that " .. prn .. " unconscious.")
	end	

	if target:GetNWBool("mutejaw", false) then
		table.insert(noticed, "You noticed that " .. prn2 .. " jaw is dislocated.")
	end

	if target:GetNWBool("anejaw", false) then
		table.insert(noticed, "You noticed that " .. prn2 .. " jaw is broken.")
	end

	if target:GetNWFloat("overdose", 0) >= 1 or target:GetNWFloat("adrenaline", 0) >= 15 or target:GetNWFloat("pulse", 70) >= 120 then
		table.insert(noticed, "You noticed that " .. prn2 .. " pupils are dilated.")
	end

	if target:GetNWBool("ane_ra", false) then
		table.insert(noticed, "You noticed that " .. prn2 .. " right arm is broken.")
	end
	
	if target:GetNWBool("ane_la", false) then
		table.insert(noticed, "You noticed that " .. prn2 .. " left arm is broken.")
	end

	if target:GetNWBool("ane_rl", false) then
		table.insert(noticed, "You noticed that " .. prn2 .. " right leg is broken.")
	end

	if target:GetNWBool("ane_ll", false) then
		table.insert(noticed, "You noticed that " .. prn2 .. " left leg is broken.")
	end

    if owner and !owner:Alive() and !target:IsPlayer() then
        table.insert(noticed, prn3 .. " look dead...")
    end

	if a2 > 1 then
		txtc.a = a2
		draw.DrawText(table.concat(noticed, " \n "), "chfont2", midx, midy + 180, txtc, TEXT_ALIGN_CENTER)
	end
end)

local PlayerMeta = FindMetaTable("Player")

surface.CreateFont("hmcd_notify_font", {font = "coolvetica", size = 32, antialias = true, shadow = false, extended = true, italic = false, extended=true})
surface.CreateFont("hmcd_notify_font_italic", {font = "coolvetica", size = 32, antialias = true, shadow = false, extended = true, italic = true, extended=true})

local notify_data = nil

function PlayerMeta:Notify(str, shaking, col, thoughts, speed)
	notify_data = {
		text = str,
		shaking = shaking,
		color = col or color_white,
		thoughts = thoughts or false,
		start_time = CurTime(),
		die_time = CurTime() + #str * 0.05 + 5,
		type_speed = speed or 0.04
	}
end

net.Receive("hmcd_notification_net", function()
    local str = net.ReadString()
    local shaking = net.ReadBool()
    local col = net.ReadColor()
    local thoughts = net.ReadBool()
	local speed = net.ReadFloat()
    LocalPlayer():Notify(str, shaking, col, thoughts, speed)
end)



hook.Add("PostDrawHUD", "hmcdBITchhec", function()
	if not notify_data then return end
	
	local cur_time = CurTime()
	if cur_time > notify_data.die_time then
		notify_data = nil
		return
	end

	local ply = LocalPlayer()
	local is_otrub = ply:GetNWBool("otrub", false) or !ply:Alive()

	local time_left = notify_data.die_time - cur_time
	local alpha = 255
	if time_left < 1.5 then
		alpha = (time_left / 1.5) * 255
	end

	local font = notify_data.thoughts and "hmcd_notify_font_italic" or "hmcd_notify_font"
	surface.SetFont(font)
	
	local full_text = notify_data.text
	local full_len = utf8.len(full_text)

	local current_progress = math.floor((cur_time - notify_data.start_time) / notify_data.type_speed)

	if is_otrub then
		if not notify_data.interrupted_at then
			notify_data.interrupted_at = math.Clamp(current_progress, 1, full_len)
			notify_data.is_cut = true
		end
	end

	local chars_to_show = notify_data.is_cut and notify_data.interrupted_at or current_progress
	
	chars_to_show = math.Clamp(chars_to_show, 0, full_len)

	local visible_text = utf8.sub(full_text, 1, chars_to_show)
	
	if notify_data.is_cut and utf8.len(visible_text) > 0 then
		visible_text = visible_text.. "-"
	end

	if visible_text == "" then return end

	local total_w, total_h = surface.GetTextSize(visible_text)
	local start_x = (ScrW() / 2) - (total_w / 2)
	local start_y = (ScrH() / 2) + 250
	local current_x = start_x

	local col = Color(notify_data.color.r, notify_data.color.g, notify_data.color.b, alpha)

	local characters = {}
	for _, c in utf8.codes(visible_text) do
		table.insert(characters, utf8.char(c))
	end

	for i = 1, #characters do
		local char = characters[i]
		local char_w, char_h = surface.GetTextSize(char)
		
		local offset_x, offset_y = 0, 0
		if notify_data.shaking then
			offset_x = math.random(-2, 2)
			offset_y = math.random(-2, 2)
		end

		draw.SimpleText(char, font, current_x + offset_x + 1, start_y + offset_y + 1, Color(0, 0, 0, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(char, font, current_x + offset_x, start_y + offset_y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		current_x = current_x + char_w
	end
end)