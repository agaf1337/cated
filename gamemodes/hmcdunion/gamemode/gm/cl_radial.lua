surface.CreateFont( "Radial_QM" , {
	font = "coolvetica",
	size = math.ceil(ScrW() / 38),
	weight = 500,
	antialias = true,
	italic = false
})

surface.CreateFont( "RadialSmall_QM" , {
	font = "coolvetica",
	size = math.ceil(ScrW() / 80),
	weight = 100,
	antialias = true,
	italic = false
})

local ments
local radialOpen = false
local prevSelected, prevSelectedVertex
function GM:OpenRadialMenu(elements)
	if not LocalPlayer():Alive() then return end
	if PhraseOpen then return end
	radialOpen = true
	LocalPlayer():SetNWBool("radialopen", true)
	gui.EnableScreenClicker(true)
	ments = elements or {}
	prevSelected = nil
end

local pistol = {
	"9х19 mm Parabellum",
	"9х18 mm",
	".45 Rubber",
	"4.6x30 mm",
	"5.7x28 mm",
	".44 Remington Magnum",
	".50 AE Magnum",
	".45 acp",
	"Pistol"
}

local shotgun = {
   	"12/70 gauge",
   	"12/70 beanbag",
	"Buckshot"
}

local rifle = {
   	"5.56x45 mm",
   	"7.62x51 NATO",
   	"7.62x54 mm",
   	".308 Winchester",
   	".408 Cheyenne Tactical",
   	"12.7x99 mm",
   	"7.62x39 mm",
   	"5.45x39 mm",
	"9x39 mm",
	"AR2",
	"SMG"
}

local other = {
   	"nails"
}

local painWords = {
   	"AgRgh!", "Aaaaa!", "Ohh...", "Uugh!", "AAAH!", "AAAA", "ShhGH..",
   	"Nyagh!", "Owch!", "GRAAAH!", "AURGH!", "Aggh!", "nya", "FUCkkH", 
}

function GM:CloseRadialMenu()
	radialOpen = false
	LocalPlayer():SetNWBool("radialopen", false)
	gui.EnableScreenClicker(false)
end

local function getSelected()
	local mx, my = gui.MousePos()
	local sw,sh = ScrW(), ScrH()
	local total = #ments
	local w = math.min(sw * 0.45, sh * 0.45)
	local h = w
	local sx, sy = sw / 2, sh / 2
	local x2,y2 = mx - sx, my - sy
	local ang = 0
	local dis = math.sqrt(x2 ^ 2 + y2 ^ 2)
	if dis / w <= 1 then
		if y2 <= 0 && x2 <= 0 then
			ang = math.acos(x2 / dis)
		elseif x2 > 0 && y2 <= 0 then
			ang = -math.asin(y2 / dis)
		elseif x2 <= 0 && y2 > 0 then
			ang = math.asin(y2 / dis) + math.pi
		else
			ang = math.pi * 2 - math.acos(x2 / dis)
		end
		return math.floor((1 - (ang - math.pi / 2 - math.pi / total) / (math.pi * 2) % 1) * total) + 1
	end
end

local function hasWeapon(ply, weaponName)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    
    for _, weapon in pairs(ply:GetWeapons()) do
        if IsValid(weapon) and weapon:GetClass() == weaponName then
            return true
        end
    end
    
    return false 
end

function GM:RadialMousePressed(code, vec)
	if radialOpen then
		local selected = getSelected()
		if selected and selected > 0 and code == MOUSE_LEFT then
			if selected and ments[selected] then
				if ments[selected].Code == "hmcd_ammo" then
					RunConsoleCommand("open_ammo_drop_menu")
				elseif ments[selected].Code == "unloadwep" then
					local lply = LocalPlayer()
        			local wep = lply:GetActiveWeapon()
                	net.Start("Unload")
                	net.WriteEntity(wep) //fix exploit here later
                	net.SendToServer()
				elseif ments[selected].Code == "drop" then
					local lply = LocalPlayer()
					lply:ConCommand("say *drop")
				elseif ments[selected].Code == "hmcd_armor" then
					RunConsoleCommand("open_equipment_drop_menu")
				elseif ments[selected].Code == "phrase" then
					local lply = LocalPlayer()
					lply:ConCommand("+phrase")
				elseif ments[selected].Code == "swfm" then
                	net.Start("switch fire mode")
                	net.SendToServer()		
					local lply = LocalPlayer()
        			local wep = lply:GetActiveWeapon()
					if wep.SwitchFM then wep.Primary.Automatic = !wep.Primary.Automatic 
					surface.PlaySound("weapons/m4a1/m4a1_fireselect.wav")
					end
				elseif ments[selected].Code == "onehand" then
					LocalPlayer():ConCommand("hmcd_onehanded")
				elseif ments[selected].Code == "onehand" then
					LocalPlayer():ConCommand("hmcd_onehanded")		
				elseif ments[selected].Code == "laser" then
					local lply = LocalPlayer()
					if !lply:GetActiveWeapon():GetNWBool("LaserStatus", false) then
						lply:GetActiveWeapon():SetNWBool("LaserStatus", true)
						lply:EmitSound("att/laser_on.ogg", 75,100,1,CHAN_AUTO)
					else
						lply:GetActiveWeapon():SetNWBool("LaserStatus", false)
						lply:EmitSound("att/laser_off.ogg", 75,100,1,CHAN_AUTO)
					end
				elseif ments[selected].Code == "usemenu" then
					local lply = LocalPlayer()
					lply:ConCommand("+menu_use")
				elseif ments[selected].Code == "attach" then
					local lply = LocalPlayer()
					lply:ConCommand("attachmentsmenu")
				elseif ments[selected].Code == "nvg" then
					local lply = LocalPlayer()
					local nvgstat = lply:GetNWBool("NVG_Up", false)
					if nvgstat then
						lply:SetNWBool("NVG_Up", false)
						lply:SetNWBool("NVG_WereOn", false)
					else
						lply:SetNWBool("NVG_Up", true)
						lply:SetNWBool("NVG_WereOn", true)
					end
				elseif ments[selected].Code == "painmoan" then
					RunConsoleCommand("taunt", "pain")
				end
			end
		end

		self:CloseRadialMenu()
	end
end



local elements
local function addElement(transCode, code)
	local t = {}
	t.TransCode = transCode
	t.Code = code
	table.insert(elements, t)
end

concommand.Add("+menu",function(client, com, args, full)
	if client:GetNWBool("Phraseopen") then return end
	if client:GetNWBool("Otrub", false) == true then return end
	if client:Alive() then
		local Wep = client:GetActiveWeapon()
		local Ammos = {}
		for key,name in pairs(HMCD_AmmoNames) do
			local Amownt = client:GetAmmoCount(key)
			if (Amownt > 0) then Ammos[key] = Amownt end
		end

		elements = {}
		if #table.GetKeys(Ammos) > 0 then addElement("Ammo Menu","hmcd_ammo") end
		if #table.GetKeys(Ammos) > 0 then addElement("Armor Menu","hmcd_armor") end
		addElement("Phrase_Category","phrase")
		if client:GetNWBool("Mask", "") == "NVG" then addElement("nvg", "nvg") end
		if fs then addElement("MenuUse_Category","usemenu") end
		if IsValid(Wep) then
			if Wep:GetClass() ~= "wep_jack_hmcd_hands" and Wep:GetClass() ~= "wep_jack_hmcd_brassknuckles" then
				addElement("Drop", "drop")
				addElement("attach", "attach")
			end
			if Wep:GetNWBool("Laser", false) then addElement("LaserOn","laser") end
       		if Wep:Clip1() > 0 then
				addElement("UnloadWep", "unloadwep")
			end
			if Wep.SwitchFM then
				addElement("Switch Fire Mode", "swfm")
			end
			if Wep.CanOneHanded then
				addElement("One Handed", "onehand")
			end			
		end

		if client:GetNWFloat("pain", 0) >= 210 then
			elements = {}
			local count = math.random(4, 6)
			for i = 1, count do
				addElement(table.Random(painWords), "painmoan")
			end
		end

		GAMEMODE:OpenRadialMenu(elements)
	end
end)

concommand.Add(
	"-menu",
	function(client, com, args, full)
		GAMEMODE:RadialMousePressed(MOUSE_LEFT)
	end
)

local tex = surface.GetTextureID("VGUI/white.vmt")
local function drawShadow(n,f,x,y,color,pos)
	draw.DrawText(n,f,x + 1,y + 1,color_black,pos)
	draw.DrawText(n,f,x,y,color,pos)
end
local function drawTextShadow(t,f,x,y,c,px,py)
	draw.SimpleText(t,f,x + 1,y + 1,Color(0,0,0,c.a),px,py)
	draw.SimpleText(t,f,x - 1,y - 1,Color(255,255,255,math.Clamp(c.a*.25,0,255)),px,py)
	draw.SimpleText(t,f,x,y,c,px,py)
end

local circleVertex
local fontHeight = draw.GetFontHeight("Radial_QM")
function GM:DrawRadialMenu()
	if radialOpen then
		local sw,sh = ScrW(), ScrH()
		local total = #ments
		local w = math.min(sw * 0.45, sh * 0.45)
		local h = w
		local sx, sy = sw / 2, sh / 2

		local selected = getSelected() or -1


		if !circleVertex then
			circleVertex = {}
			local max = 50
			for i = 0, max do
				local vx, vy = math.cos((math.pi * 2) * i / max), math.sin((math.pi * 2) * i / max)

				table.insert(circleVertex, {x = sx + w* 1 * vx, y= sy + h* 1 * vy})
			end
		end

		surface.SetTexture(tex)
		local defaultTextCol = color_white
		if selected <= 0 || selected ~= selected then
			surface.SetDrawColor(20,20,20,180)
		else
			surface.SetDrawColor(20,20,20,120)
			defaultTextCol = Color(150,150,150)
		end
		surface.DrawPoly(circleVertex)

		local add = math.pi * 1.5 + math.pi / total
		local add2 = math.pi * 1.5 - math.pi / total

		for k,ment in pairs(ments) do
			local x,y = math.cos((k - 1) / total * math.pi * 2 + math.pi * 1.5), math.sin((k - 1) / total * math.pi * 2 + math.pi * 1.5)

			local lx, ly = math.cos((k - 1) / total * math.pi * 2 + add), math.sin((k - 1) / total * math.pi * 2 + add)

			local textCol = defaultTextCol
			if(ment.Code=="villain")then
				textCol=Color(200,10,10,150)
			elseif(ment.Code=="hero") or (ment.Code=="police")then
				textCol=Color(20,200,255,150)
			elseif(ment.Code=="painmoan")then
				textCol=Color(230,40,40,255)
			end
			if selected == k then
				local vertexes = prevSelectedVertex -- uhh, you mean VERTICES? Dumbass.

				if prevSelected != selected then
					prevSelected = selected
					vertexes = {}
					prevSelectedVertex = vertexes
					local lx2, ly2 = math.cos((k - 1) / total * math.pi * 2 + add2), math.sin((k - 1) / total * math.pi * 2 + add2)

					table.insert(vertexes, {x = sx, y = sy})

					table.insert(vertexes, {x = sx + w* 1 * lx2, y= sy + h* 1 * ly2})

					local max = math.floor(50 / total)
					for i = 0, max do
						local addv = (add - add2) * i / max + add2
						local vx, vy = math.cos((k - 1) / total * math.pi * 2 + addv), math.sin((k - 1) / total * math.pi * 2 + addv)

						table.insert(vertexes, {x = sx + w* 1 * vx, y= sy + h* 1 * vy})
					end

					table.insert(vertexes, {x = sx + w* 1 * lx, y= sy + h* 1 * ly})

				end

				surface.SetTexture(tex)
				surface.SetDrawColor(20,120,255,120)
				if ment.Code == "happy" then
					surface.SetDrawColor(255, 20, 20, 120)
				elseif ment.Code == "burp" then
					surface.SetDrawColor(195, 167, 30, 120)
				elseif ment.Code == "fart" then
					surface.SetDrawColor(111, 94, 8, 120)
				elseif ment.Code == "kurare" then
					surface.SetDrawColor(192, 23, 23, 120)
				elseif ment.Code == "painmoan" then
					surface.SetDrawColor(200, 30, 30, 120)
				end

				surface.DrawPoly(vertexes)
				textCol = color_white
			end
			local ply = LocalPlayer()
			local Main, Sub
			local wep = ply:GetActiveWeapon()
			if ment.TransCode == "Ammo Menu" then
				Main = "Ammo Menu"
				Sub = "drop ammo"
			elseif ment.TransCode == "Armor Menu" then
				Main = "Armor Menu"
				Sub = "drop armor"
			elseif ment.TransCode == "UnloadWep" then
				Main = "Unload Ammo"
				Sub = "unload weapon in your hands"
			elseif ment.TransCode == "Switch Fire Mode" then
				Main = "Switch Fire Mode"
				Sub = "switch from "..(ply:GetActiveWeapon().Primary.Automatic and "Automatic" or "Semi-Auto").." to "..(!ply:GetActiveWeapon().Primary.Automatic and "Automatic" or "Semi-Auto")
			elseif ment.TransCode == "One Handed" and IsOneHandedMode then
				Main = "Use "..(IsOneHandedMode() and "Both Hands" or "One Hand")
				Sub = "hold weapon with "..(IsOneHandedMode() and "both hands" or "one hand")
			elseif ment.TransCode == "Drop" then
				Main = "Drop Weapon"
				Sub = "drop weapon in your hands"
			elseif ment.TransCode == "Phrase_Category" then
				Main = "Phrase"
				Sub = "say something"
			elseif ment.TransCode == "LaserOn" then
				Main = "Laser"
				Sub = (ply:GetActiveWeapon():GetNWBool("LaserStatus") and "Disable") or "Enable"
			elseif ment.TransCode == "MenuUse_Category" then
				Main = "Actions Menu"
				Sub = "interact with the environment"
			elseif ment.TransCode == "attach" then
				Main = "Modify weapon"
				Sub = "equip weapon attachments"
			elseif ment.TransCode == "nvg" then
				Main = "NVG"
				Sub = "up or down nvg"
			elseif ment.Code == "painmoan" then
				Main = ment.TransCode
				Sub = ""
			else
    			Main = "?"
    			Sub = "?"
			end
			drawShadow(ply:GetNWString("Character_Name") or "Bystander", "GM", w/2.7, h/8.5, Color(255,255,255,255), 1)
			drawShadow(ply:GetNWString("Role") or "Bystander", "GM", w/3, h/5, Color(ply:GetNWInt("RoleColor_R"),ply:GetNWInt("RoleColor_G"),ply:GetNWInt("RoleColor_B"),255), 1)
			drawShadow(Main, "Radial_QM", sx + w * 0.6 * x, sy + h * 0.6 * y - fontHeight / 3,textCol, 1)
			drawShadow(Sub, "RadialSmall_QM", sx + w * 0.6 * x, sy + h * 0.6 * y + fontHeight / 2, textCol, 1)
		end
	end
end

local HMCD_HelpSpawnMenu = false

local function HMCD_ToggleSpawnMenu()
    if not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() or GetGlobalString("RoundName") == "sandbox") then return end
    
    if IsValid(g_SpawnMenu) and g_SpawnMenu:IsVisible() then
        if isfunction(g_SpawnMenu.Close) then
            g_SpawnMenu:Close()
        else
            g_SpawnMenu:SetVisible(false)
        end
        HMCD_HelpSpawnMenu = false
        return
    end

    if IsValid(g_SpawnMenu) then
        HMCD_HelpSpawnMenu = true
        if isfunction(g_SpawnMenu.Open) then
            g_SpawnMenu:Open()
        else
            g_SpawnMenu:SetVisible(true)
            if isfunction(g_SpawnMenu.MakePopup) then
                g_SpawnMenu:MakePopup()
            end
            gui.EnableScreenClicker(true)
        end
        return
    end

    HMCD_HelpSpawnMenu = true
    RunConsoleCommand("+menu")
end

hook.Add("PlayerBindPress", "HMCD_HelpSpawnMenu_Bind", function(ply, bind, pressed)
    if not pressed then return end
    if bind:find("gm_showhelp", 1, true) then
        HMCD_ToggleSpawnMenu()
        return true
    end
end)

hook.Add("OnSpawnMenuOpen", "HMCD_OverrideSpawnMenu", function()
    if HMCD_HelpSpawnMenu then
        return 
    end

    return false 
end)

hook.Add("OnSpawnMenuClose", "HMCD_OverrideSpawnMenuClose", function()
    HMCD_HelpSpawnMenu = false
end)
