local MODES_PATH = "hmcdunion/gamemode/gm/modes/"

GM.Modes = GM.Modes or {}

function GM.RegisterMode(gm, id, data)
	data.Id = id
	gm.Modes[id] = data

	if data.Name then
		RoundsNormalise = RoundsNormalise or {}
		RoundsNormalise[id] = data.Name
	end

	return data
end

function GM.GetMode(gm, id)
	return gm.Modes[id]
end

function GM.GetActiveMode(gm)
	if SERVER then
		return gm.Modes[GAMEMODE.RoundName or "homicide"]
	end
	return gm.Modes[GetGlobalString("RoundName", "homicide")]
end

do
	local _, modeDirs = file.Find(MODES_PATH .. "*", "LUA")
	for _, dir in ipairs(modeDirs) do
		local shPath = MODES_PATH .. dir .. "/shared.lua"
		if file.Exists(shPath, "LUA") then
			include(shPath)
		end
	end
end

HMCD_MedalConfig = {
	Width = 230,
	Height = 230,
	OffsetX = 0,
	OffsetY = 0
}

local MVPTarget = nil

hook.Add("CalcView", "HMCD_MVPCameraOrbit", function(ply, pos, angles, fov)
	if IsValid(MVPTarget) and MVPTarget:IsPlayer() and MVPTarget:Alive() then
		local rag = MVPTarget:GetNWEntity("Ragdoll")
		local isRagdoll = MVPTarget:GetNWBool("fake", false) and IsValid(rag)

		local targetPos
		if isRagdoll then
			local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
			if headBone then
				local matrix = rag:GetBoneMatrix(headBone)
				if matrix then
					targetPos = matrix:GetTranslation() + Vector(0, 0, 10)
				else
					targetPos = rag:GetBonePosition(headBone) + Vector(0, 0, 10)
				end
			else
				targetPos = rag:WorldSpaceCenter() + Vector(0, 0, 15)
			end
		else
			targetPos = MVPTarget:GetPos() + Vector(0, 0, 45)
		end

		local dist = isRagdoll and 90 or 110
		local zHeight = isRagdoll and 25 or 12
		local speed = 15
		local timeAngle = (CurTime() * speed) % 360
		local rad = math.rad(timeAngle)

		local camPos = targetPos + Vector(math.cos(rad) * dist, math.sin(rad) * dist, zHeight)

		local tr = util.TraceLine({
			start = targetPos,
			endpos = camPos,
			filter = {MVPTarget, ply, rag}
		})
		if tr.Hit then
			camPos = tr.HitPos + tr.HitNormal * 4
		end

		local camAngles = (targetPos - camPos):Angle()

		return {
			origin = camPos,
			angles = camAngles,
			fov = 75,
			drawviewer = true
		}
	end
end)

function GM:StartNewRound(data)
	MVPTarget = nil
	local ply = LocalPlayer()
	local mode = GAMEMODE:GetActiveMode()

	local roleShow = (data and data.role and data.role ~= "") and data.role or ply:GetNWString("RoleShow", "")
	local roleCol = (data and data.color) or Color(ply:GetNWInt("RoleColor_R", 255), ply:GetNWInt("RoleColor_G", 255), ply:GetNWInt("RoleColor_B", 255))

	local startsound
	if mode then
		if mode.GetRoleStartSound then
			startsound = mode:GetRoleStartSound(ply)
		end
		if not startsound and mode.RoleStartSounds then
			startsound = mode.RoleStartSounds[roleShow]
		end
		if not startsound and mode.GetStartSound then
			startsound = mode:GetStartSound()
		end
		if not startsound and mode.StartSound then
			startsound = mode.StartSound
		end
	end
	if not startsound and RoundStartSound then
		startsound = RoundStartSound[GetGlobalString("RoundName", "homicide")]
	end
	if startsound then
		ply:EmitSound(startsound)
	end

	local Panel = vgui.Create("DPanel")
	Panel:SetPos(0, 0)
	Panel:SetSize(ScrW(), ScrH())
	Panel.Paint = function(sel, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
	end
	Panel:MakePopup()
	Panel:SetMouseInputEnabled(false)
	Panel:SetKeyboardInputEnabled(false)
	Panel:AlphaTo(0, 3, 9, function() if IsValid(Panel) then Panel:Remove() end end)

	surface.SetFont("FontSmall")
	local textWidth, textHeight = surface.GetTextSize(ply:GetNWString("Role", ""))

	local You = Label("You are", Panel)
	You:SetFont("FontSmall")
	You:SetColor(roleCol)
	You:SetPos(0, ScrH() / 2 - textHeight * 1.5)
	You:SizeToContents()
	You:CenterHorizontal()

	local RoundLabel = Label(roleShow, Panel)
	RoundLabel:SetFont("DefaultFont")
	RoundLabel:SizeToContents()
	RoundLabel:Center()
	RoundLabel:SetColor(roleCol)

	local extra = mode and mode.GetStartExtraLine and mode:GetStartExtraLine(ply)
	if extra and extra.text then
		local Instructions = Label(extra.text, Panel)
		Instructions:SetFont("FontSmall")
		Instructions:SizeToContents()
		Instructions:Center()
		Instructions:SetPos(Instructions:GetX(), Instructions:GetY() + textHeight * 1.5)
		Instructions:SetColor(extra.color or Color(121, 61, 244))
	end

	local helpText = ""
	if mode and mode.HelpRole then
		helpText = mode.HelpRole[roleShow] or ""
	end
	if helpText == "" and HMCD_HelpRole then
		helpText = HMCD_HelpRole[roleShow] or ""
	end

	local HelpLabel = Label(helpText, Panel)
	HelpLabel:SetFont("FontSmall")
	HelpLabel:SizeToContents()
	HelpLabel:Center()

	local fontHeight = draw.GetFontHeight("FontSmall")
	HelpLabel:SetPos(HelpLabel:GetX(), ScrH() - fontHeight * 2)
	HelpLabel:SetColor(roleCol)

	local roundName = GetGlobalString("RoundName", "homicide")
	local roundType = GetGlobalInt("RoundType", 2)

	local nameStr = (mode and mode.Name) or (RoundsNormalise and RoundsNormalise[roundName]) or roundName
	local typeStr = ""
	if mode and mode.HasRoundTypes and HMCD_RoundsTypeNormalise then
		typeStr = HMCD_RoundsTypeNormalise[roundType] or tostring(roundType)
	end
	local sep = (mode and mode.TitleSeparator) or " "

	local TitleLabel = Label(nameStr .. sep .. typeStr, Panel)
	TitleLabel:SetFont("FontSmall")
	TitleLabel:SizeToContents()
	TitleLabel:CenterHorizontal()
	TitleLabel:SetPos(TitleLabel:GetX(), 50)
end

surface.CreateFont("BigEndRound", {
	font = "coolvetica",
	size = math.ceil(ScrW() / 24),
	weight = 500,
	antialias = true,
	italic = false
})

local menu

local function GetEndTitle(data)
	local mode = GAMEMODE:GetActiveMode()

	if mode then
		if mode.GetEndTitle then
			local text, col = mode:GetEndTitle(data)
			if text then return text, col end
		end

		local entry = mode.EndTitles and mode.EndTitles[data.reason]
		if entry then return entry.text, entry.color end
	end

	if data.reason == 1 or data.reason == 2 then
		return "Round over!"
	elseif data.reason == 3 then
		return "Draw!", Color(223, 223, 223)
	elseif data.reason == 4 then
		return "Combines win!", Color(32, 98, 185)
	elseif data.reason == 5 then
		return "Rebels win!", Color(178, 119, 17)
	elseif data.reason == 6 then
		return (data.survived or "Someone") .. " survived.", Color(178, 119, 17)
	elseif data.reason == 7 then
		return "Episode Failed", Color(164, 26, 26)
	elseif data.reason == 8 then
		return "Episode Successful", Color(29, 125, 19)
	end

	return nil
end

function GM:DisplayEndRoundBoard(data)
	if IsValid(menu) then
		menu:Close()
	end

	local mode = GAMEMODE:GetActiveMode()

	local Showin, Dude = false, GAMEMODE.MVP
	if Dude and IsValid(Dude) and data.reason ~= 7 and data.reason ~= 8 then
		Showin = true
	end

	if IsValid(Dude) and Dude:IsPlayer() and Dude:Alive() then
		MVPTarget = Dude
	end

	menu = vgui.Create("DFrame")
	menu:SetSize(ScrW() * 0.8, ScrH() * 0.8)
	menu:Center()
	if Showin then
		menu:SetSize(ScrW() * 0.45, ScrH() * 0.9)
		menu:SetPos(ScrW() * 0.525, ScrH() * 0.05)
	end
	menu:SetTitle("")
	menu:MakePopup()
	menu:SetKeyboardInputEnabled(false)

	function menu:Paint()
		surface.SetDrawColor(Color(40, 40, 40, 255))
		surface.DrawRect(0, 0, menu:GetWide(), menu:GetTall())
	end

	local winnerPnl = vgui.Create("DPanel", menu)
	winnerPnl:DockPadding(24, 24, 24, 24)
	winnerPnl:Dock(TOP)
	function winnerPnl:PerformLayout()
		self:SizeToChildren(false, true)
	end
	function winnerPnl:Paint(w, h)
		surface.SetDrawColor(Color(50, 50, 50, 255))
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local winner = vgui.Create("DLabel", winnerPnl)
	winner:Dock(TOP)
	winner:SetFont("BigEndRound")
	winner:SetAutoStretchVertical(true)
	winner:SetTextColor(Color(255, 255, 255))

	local titleText, titleColor = GetEndTitle(data)
	if titleText then
		winner:SetText(titleText)
		if titleColor then winner:SetTextColor(titleColor) end
	else
		winner:SetText("")
	end

	local murdererPnl = vgui.Create("DPanel", winnerPnl)
	murdererPnl:Dock(TOP)
	murdererPnl:SetTall(draw.GetFontHeight("FontSmall"))
	function murdererPnl:Paint() end

	if data.murdererName and mode and mode.ShowMurdererReveal and data.reason ~= 3 then
		local col = data.murdererColor or Vector(1, 1, 1)
		local was = vgui.Create("DLabel", murdererPnl)
		was:Dock(LEFT)
		was:SetText("The traitor was")
		was:SetFont("FontSmall")
		was:SetTextColor(color_white)
		was:SetAutoStretchVertical(true)
		was:SizeToContentsX()

		local name = vgui.Create("DLabel", murdererPnl)
		name:Dock(LEFT)
		name:SetText(" " .. data.murdererName)
		name:SetTextColor(Color(col.x * 255, col.y * 255, col.z * 255))
		name:SetFont("FontSmall")
		name:SizeToContentsX()
	end

	local lootPnl = vgui.Create("DPanel", menu)
	lootPnl:Dock(FILL)
	lootPnl:DockPadding(24, 24, 24, 24)
	function lootPnl:Paint(w, h)
		surface.SetDrawColor(Color(50, 50, 50, 255))
		surface.DrawRect(2, 2, w - 4, h - 4)
	end

	local desc = vgui.Create("DLabel", lootPnl)
	desc:Dock(TOP)
	desc:SetFont("DefaultFont")
	desc:SetAutoStretchVertical(true)
	desc:SetText("Players")
	desc:SetTextColor(color_white)

	local lootList = vgui.Create("DPanelList", lootPnl)
	lootList:Dock(FILL)

	for k, v in pairs(team.GetPlayers(1)) do
		local pnl = vgui.Create("DPanel")
		pnl:SetTall(draw.GetFontHeight("FontSmall"))
		function pnl:Paint(w, h) end

		function pnl:PerformLayout()
			if self.NamePnl then
				self.NamePnl:SetWidth(self:GetWide() * 0.35)
			end
			if self.BNamePnl then
				self.BNamePnl:SetWidth(self:GetWide() * 0.35)
			end
			if self.XPNamePnl then
				self.XPNamePnl:SetWidth(self:GetWide() * 0.28)
			end
			self:SizeToChildren(false, true)
		end

		local name = vgui.Create("DButton", pnl)
		pnl.NamePnl = name
		name:Dock(LEFT)
		name:SetAutoStretchVertical(true)
		name:SetText(v:Nick() .. " - " .. v:GetNWString("Role", ""))
		name:SetFont("FontSmall")
		name:SetTextColor(Color(v:GetNWInt("RoleColor_R", 255), v:GetNWInt("RoleColor_G", 255), v:GetNWInt("RoleColor_B", 255)))
		name:SetContentAlignment(4)
		function name:Paint() end

		function name:DoClick()
			if IsValid(v) then
				GAMEMODE:DoScoreboardActionPopup(v)
			end
		end

		local bname = vgui.Create("DButton", pnl)
		pnl.BNamePnl = bname
		bname:Dock(LEFT)
		bname:SetAutoStretchVertical(true)
		local col
		if v.MurdererIdentityHidden and v.TrueIdentity then
			bname:SetText(v.TrueIdentity[5] or "")
			col = v.TrueIdentity[7] or Vector(1, 1, 1)
		else
			bname:SetText(v:GetNWString("Character_Name", ""))
			col = v:GetPlayerColor() or Vector(1, 1, 1)
		end
		bname:SetFont("FontSmall")
		bname:SetTextColor(Color(col.x * 255, col.y * 255, col.z * 255))
		bname:SetContentAlignment(4)
		function bname:Paint() end
		bname.DoClick = name.DoClick

		local xpLabel = vgui.Create("DLabel", pnl)
		pnl.XPNamePnl = xpLabel
		xpLabel:Dock(RIGHT)
		xpLabel:SetAutoStretchVertical(true)

		local currentXP = v:GetNWInt("hmcd_exp", v.exp or 0)
		local currentSkill = math.Round(v:GetNWFloat("hmcd_skill", v.skill or 0), 1)

		xpLabel:SetText("(XP: " .. currentXP .. " SK: " .. currentSkill .. ")")
		xpLabel:SetFont("FontSmall")
		xpLabel:SetTextColor(Color(255, 255, 255, 230))
		xpLabel:SetContentAlignment(6)

		lootList:AddItem(pnl)
	end

	if Showin then
		local Bottom = vgui.Create("DFrame")
		function Bottom:Paint()
			surface.SetDrawColor(Color(40, 40, 40, 255))
			surface.DrawRect(0, 0, Bottom:GetWide(), Bottom:GetTall())
		end

		local Bottom2 = vgui.Create("DFrame")

		if Dude and IsValid(Dude) then
			Bottom:ShowCloseButton(false)
			Bottom:SetSize(600, 75)
			Bottom:SetPos(ScrW() * 0.05, ScrH() * 0.05)
			Bottom:SetTitle("                       MVP: " .. Dude:GetNWString("Character_Name", ""))
			Bottom:MakePopup()
			Bottom:SetKeyboardInputEnabled(false)

			Bottom2:ShowCloseButton(false)
			Bottom2:SetSize(153, 275)
			Bottom2:SetPos(ScrW() * 0.05, ScrH() * 0.13)
			Bottom2:SetTitle("XP: " .. Dude:GetNWInt("hmcd_exp", Dude.exp or 0) .. " SK: " .. math.Round(Dude:GetNWFloat("hmcd_skill", Dude.skill or 0), 1))
			Bottom2:MakePopup()
			Bottom2:SetKeyboardInputEnabled(false)

			function Bottom2:Paint(w, h)
				surface.SetDrawColor(Color(40, 40, 40, 255))
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(Color(50, 50, 50, 255))
				surface.DrawRect(5, 27, w - 10, h - 33)

				local Band, Medal = Dude:GetAwards()

				local innerX, innerY = 5, 27
				local innerW, innerH = w - 10, h - 33

				local drawW = HMCD_MedalConfig.Width or (innerW - 10)
				local drawH = HMCD_MedalConfig.Height or (innerH - 10)
				local drawX = innerX + (innerW - drawW) / 2 + (HMCD_MedalConfig.OffsetX or 0)
				local drawY = innerY + (innerH - drawH) / 2 + (HMCD_MedalConfig.OffsetY or 0)

				if Band and Band.icon then
					surface.SetDrawColor(0, 0, 0, 0)
					surface.DrawTexturedRect(drawX + 3, drawY + 3, drawW, drawH)

					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(Band.icon)
					surface.DrawTexturedRect(drawX, drawY, drawW, drawH)
				end

				if Medal and Medal.icon then
					surface.SetDrawColor(0, 0, 0, 155)
					surface.DrawTexturedRect(drawX + 3, drawY + 3, drawW, drawH)

					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(Medal.icon)
					surface.DrawTexturedRect(drawX, drawY, drawW, drawH)
				end
			end

			local Pnl2 = vgui.Create("DPanel", Bottom)
			Pnl2:Dock(FILL)
			Pnl2:DockPadding(24, 24, 24, 24)
			function Pnl2:Paint(w, h)
				surface.SetDrawColor(Color(50, 50, 50, 255))
				surface.DrawRect(0, 0, w, h)
			end

			local av = vgui.Create("AvatarImage", Bottom)
			av:SetSize(64, 64)
			av:SetPos(5, 5)
			av:SetPlayer(Dude, 64)

			local wow = vgui.Create("DLabel", Bottom)
			wow:SetFont("FontMedium")
			wow:SetText(Dude:Nick())
			wow:SetTextColor(Color(255, 255, 255, 255))
			wow:SetPos(80, 27)
			wow:SetSize(530, 50)
		end

		menu.OnClose = function()
			if IsValid(Bottom) then Bottom:Remove() end
			if IsValid(Bottom2) then Bottom2:Remove() end
		end
	end
end

net.Receive("StartRound", function()
	local data = {}
	data.role = net.ReadString()
	data.color = net.ReadColor()
	GAMEMODE:StartNewRound(data)
end)

net.Receive("EndRound", function()
	local data = {}
	data.reason = net.ReadInt(8)
	data.murderer = net.ReadEntity()
	data.murdererColor = net.ReadVector()
	data.murdererName = net.ReadString()
	data.survived = net.ReadString()
	GAMEMODE.MVP = data.murderer
	GAMEMODE:DisplayEndRoundBoard(data)
	local pitch = math.random(80, 120)
	if IsValid(LocalPlayer()) then
		LocalPlayer():EmitSound("ambient/alarms/warningbell1.wav", 100, pitch)
	end
end)
