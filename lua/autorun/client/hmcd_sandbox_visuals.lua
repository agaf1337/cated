
if SERVER then return end

surface.CreateFont("DefaultFont",{
    font = "Coolvetica",
    size = math.ceil(ScrW() / 38),
    weight = 500,
    antialias = true,
    italic = false
})

surface.CreateFont("Role",{
	font = "Coolvetica",
	size = 48,
	weight = 1100,
    antialias = true,
    italic = false
})

surface.CreateFont("GM",{
	font = "Coolvetica",
	size = 64,
	weight = 1100,
    antialias = true,
    italic = false
})

surface.CreateFont("TextYou",{
	font = "Coolvetica",
	size = 30,
	weight = 1100,
    antialias = true,
    italic = false
})


surface.CreateFont("FontTargetP",{
	font = "Coolvetica",
	size = 48,
	weight = 1100,
    antialias = true,
    italic = false
})

surface.CreateFont("FontBigger",{
	font = "Coolvetica",
	size = 36,
	weight = 1100,
    antialias = true,
    italic = false
})

surface.CreateFont("FontBig",{
	font = "Coolvetica",
	size = 25,
	weight = 1100,
    antialias = true,
    italic = false
})

surface.CreateFont("FontRadialMenu",{
	font = "Coolvetica",
	size = 26,
	weight = 1100,
	antialias = true,
	italic = false
})

surface.CreateFont("FontLarge",{
	font = "Coolvetica",
	size = ScreenScale(30),
	weight = 1100,
    antialias = true,
    italic = false
})

surface.CreateFont("FontSmall",{
	font = "Coolvetica",
	size = ScreenScale(10),
	weight = 1100,
    antialias = true,
    italic = false
})

surface.CreateFont("MedKitFont",{
	font = "Coolvetica",
	size = ScreenScale(7),
	weight = 150,
    antialias = true,
    italic = false
})

local function Identity(data)
	if not LocalPlayer().ConCommand then return end
	if file.Exists("union_appearance.txt", "DATA") then
		local RawData = string.Split(file.Read("union_appearance.txt", "DATA"), "\n")
		LocalPlayer():ConCommand("customize_manual " .. RawData[1] .. " " .. RawData[2] .. " " .. RawData[3] .. " " .. RawData[4] .. " " .. RawData[5] .. " " .. RawData[6] .. " " .. RawData[7] .. " " .. RawData[8])
	end
end

usermessage.Hook("Skin_Appearance", Identity)

hook.Add("Initialize", "HMCD_CVarsSet", function()
	RunConsoleCommand( "r_decals", "9999" )
	--RunConsoleCommand( "mp_decals", "9999" )
	RunConsoleCommand( "r_queued_decals", "1" )
	RunConsoleCommand( "gm_demo_icon", "0" )
	RunConsoleCommand("sv_alltalk", "2")
end)

function HMCD_RenderAccessories(ply)
	if ply:IsPlayer() then
		local Weps, DrawWep = ply:GetWeapons(), nil
		for key, wep in pairs(Weps) do
			if wep.HolsterSlot and (wep.HolsterSlot == 1) then
				DrawWep = wep
				break
			end
		end

		if DrawWep and (DrawWep ~= ply:GetActiveWeapon()) then
			if ply.HolsterWep and (ply.HolsterWepModelName == DrawWep.WorldModel) then
				local Pos, Ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Spine4"))
				if Pos and Ang then
					local Dist = 0
					

					Pos = Pos + Ang:Right() * (DrawWep.HolsterPos.x + Dist) + Ang:Forward() * DrawWep.HolsterPos.y + Ang:Up() * DrawWep.HolsterPos.z
					Ang:RotateAroundAxis(Ang:Right(), DrawWep.HolsterAng.p)
					Ang:RotateAroundAxis(Ang:Up(), DrawWep.HolsterAng.y)
					Ang:RotateAroundAxis(Ang:Forward(), DrawWep.HolsterAng.r)
					ply.HolsterWep:SetRenderOrigin(Pos)
					ply.HolsterWep:SetRenderAngles(Ang)
					ply.HolsterWep:DrawModel()
				end
			else
				ply.HolsterWep = ClientsideModel(DrawWep.WorldModel)
				ply.HolsterWepModelName = DrawWep.WorldModel
				ply.HolsterWep:SetPos(ply:GetPos())
				ply.HolsterWep:SetParent(ply)
				local Mats = ply.HolsterWep:GetMaterials()
				for key, mat in pairs(Mats) do
					ply.HolsterWep:SetSubMaterial(key - 1, mat)
				end

				ply.HolsterWep:SetNoDraw(true)
			end
		end
	end
end

function HMCD_RenderArmor(ply)
	local Mod=ply:GetModel()
	
	

	if ply:GetNWString("Mask", "") == "NVG" then
		if ply.NVG then
			local Pos, Ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
			if Pos and Ang then
				if ply.ModelSex == "male" then
					Dist = 6
				end

				Pos = Pos + Ang:Forward() * 1 + Ang:Right() * 0
				ply.NVG:SetRenderOrigin(Pos)
				if ply:GetNWBool("NVG_Up", false) then
					Ang:RotateAroundAxis(Ang:Up(), -70)
					Ang:RotateAroundAxis(Ang:Forward(), -90)
				else
					Ang:RotateAroundAxis(Ang:Up(), -80)
					Ang:RotateAroundAxis(Ang:Forward(), -90)
				end
				ply.NVG:SetRenderAngles(Ang)
				local R, G, B = render.GetColorModulation()
				render.SetColorModulation(.7, .7, .7)
				ply.NVG:DrawModel()
				render.SetColorModulation(R, G, B)
			end
		else
			ply.NVG = ClientsideModel("models/arctic_nvgs/nvg_gpnvg.mdl")
			ply.NVG:SetPos(ply:GetPos())
			ply.NVG:SetParent(ply)
			ply.NVG:SetNoDraw(true)
			local Scale = 1
			if ply.ModelSex == "female" then
				Scale = Scale * .9
			end

			ply.NVG:SetModelScale(Scale, 0)
		end
	else
		ply.NVG = nil
	end

	if ply:GetNWBool("Headcrab", false) then
		if ply.HeadCrab then
			local Pos, Ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
			if Pos and Ang then
				if ply.ModelSex == "male" then
					Dist = 6
				end

				Pos = Pos + Ang:Forward() * 2 + Ang:Right() * 5
				ply.HeadCrab:SetRenderOrigin(Pos)
				Ang:RotateAroundAxis(Ang:Up(), -80)
				Ang:RotateAroundAxis(Ang:Forward(), -90)
				ply.HeadCrab:SetRenderAngles(Ang)
				local R, G, B = render.GetColorModulation()
				render.SetColorModulation(.7, .7, .7)
				ply.HeadCrab:DrawModel()
				render.SetColorModulation(R, G, B)
			end
		else
			ply.HeadCrab = ClientsideModel("models/headcrabclassic.mdl")
			ply.HeadCrab:SetPos(ply:GetPos())
			ply.HeadCrab:SetParent(ply)
			ply.HeadCrab:SetNoDraw(true)
			local Scale = .8
			if ply.ModelSex == "female" then
				Scale = Scale * .7
			end

			ply.HeadCrab:SetModelScale(Scale, 0)
		end
	else
		ply.HeadCrab = nil
	end
end

hook.Add("PostPlayerDraw", "HMCD_PostPlayerDraw", function(ply)
	if ply:Alive() then

		hmcd.RenderArmor(ply)
		HMCD_RenderAccessories(ply)
	end
end)

hook.Add("PostDrawOpaqueRenderables", "HMCD_PostDrawOpaqueRenderables", function(drawingDepth, drawingSkybox)
	for key, ply in player.Iterator() do
		if ply ~= LocalPlayer() then
			if ply:Alive() and not ply:GetNWBool("fake") then
				hmcd.RenderArmor(ply)
			end
		end
	end
end)

