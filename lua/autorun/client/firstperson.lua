net.Receive("ebal_chellele",function(len)
    net.ReadEntity().curweapon = net.ReadString()
end)

net.Receive("pophead",function(len)
	local rag = net.ReadEntity()
	deathrag = rag
end)

-- просто нетворки сверху не  смотреть

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudZoom"] = true,
	["CTargetID"]=true,
	["CHudCrosshair"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function(name)
	if hide[name] then
		return false
	end
    -- спастил с гмодвики
end)
hook.Add("HUDDrawTargetID","HideHUD2", function() return false end)

AddCSLuaFile()
local viewmodeldraw = {
	["weapon_physgun"] = true,
	["gmod_tool"] = true,
	["gmod_camera"] = true,
	["sf_tool"] = true,
    ["weapon_drr_remote"] = true
}
LerpEyeRagdoll = Angle(0,0,0)
local vecZero = Vector(0.01,0.01,0.01)
local vecHeadNormal = Vector(1,1,1)
local tryaska = vecZero
local shootfov = 0
local GOVNOVEC = Vector(0,0,7)

local mul = 1
local FrameTime,TickInterval = FrameTime,engine.TickInterval

hook.Add("Think","Mul lerp",function()
	mul = FrameTime() / TickInterval()
end)

local Lerp,LerpVector,LerpAngle = Lerp,LerpVector,LerpAngle
local math_min = math.min

function LerpAngleFT(lerp,source,set)
	return LerpAngle(math_min(lerp * mul,1),source,set)
end

local sight = 0
local changed = false

local shrunkHeads = {}

local function ShrinkHead(ent)
	if not IsValid(ent) then return end
	local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
	if not bone then return end

	ent:ManipulateBoneScale(bone, vecZero)
	shrunkHeads[ent] = bone
end

local function RestoreHead(ent)
	if not IsValid(ent) then
		shrunkHeads[ent] = nil
		return
	end

	local bone = shrunkHeads[ent] or ent:LookupBone("ValveBiped.Bip01_Head1")
	if bone then
		ent:ManipulateBoneScale(bone, vecHeadNormal)
	end
	shrunkHeads[ent] = nil
end

local function HeadStillNeeded(ent, ply, plyselect, ragdoll)
	if LocalPlayer():GetViewEntity() != LocalPlayer() then return false end
	if ply:Alive() and ply:GetNWBool("fake") and ragdoll == ent then
		return true
	end

	if not ply:Alive() and ply:GetNWBool("Spectating", false)
	and IsValid(plyselect) and plyselect:GetNWBool("fake")
	and plyselect:GetNWEntity("Ragdoll") == ent then
		local mode = ply:GetNWInt("SpectateMode", 0)
		if mode == 0 or mode == 2 then return true end
	end

	return false
end

hook.Add("Think", "RagCamHeadRestore", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local plyselect = ply:GetNWEntity("SelectPlayer", Entity(-1))
	local ragdoll = ply:GetNWEntity("Ragdoll")

	for ent in pairs(shrunkHeads) do
		if not IsValid(ent) then
			shrunkHeads[ent] = nil
		elseif not HeadStillNeeded(ent, ply, plyselect, ragdoll) then
			RestoreHead(ent)
		end
	end
end)

local function ImersiveCam(ply,pos,ang,fov)
	if ply:GetViewEntity() != ply then return end
	local plyselect = ply:GetNWEntity("SelectPlayer", Entity(-1))
	local ragdoll = ply:GetNWEntity("Ragdoll")

	if ply:GetNWBool("Spectating", false) == true then
		if IsValid(plyselect) then
			if !plyselect:GetNWBool("fake") and ply:GetNWInt("SpectateMode", 0) == 0 then
				local att = plyselect:GetAttachment(plyselect:LookupAttachment("eyes"))
				if att then
					local view = {
						origin = att.Pos + Vector(0,-15,0),
						angles = att.Ang
					}
					return view
				end
			elseif plyselect:GetNWBool("fake") and IsValid(plyselect:GetNWEntity("Ragdoll")) and (ply:GetNWInt("SpectateMode", 0) == 0 or ply:GetNWInt("SpectateMode", 0) == 2) then
				local ragdollselect = plyselect:GetNWEntity("Ragdoll")
				ShrinkHead(ragdollselect)

				local attID = ragdollselect:LookupAttachment("eyes")
				if attID > 0 then
					local PosAng = ragdollselect:GetAttachment(attID)
					if PosAng then
						local camfake = {
							origin = PosAng.Pos - Vector(2,0,0),
							angles = PosAng.Ang,
							znear = 1,
							zfar = 26000,
							fov = 95
						}
						return camfake
					end
				end
			end
		end

		return
	end

	if ply:Alive() and ply:GetNWBool("fake") and IsValid(ragdoll) then
		ShrinkHead(ragdoll)

		local attID = ragdoll:LookupAttachment("eyes")
		if attID > 0 then
			local PosAngHead = ragdoll:GetAttachment(attID)
			if PosAngHead then
				local camfake = {
					origin = PosAngHead.Pos,
					angles = PosAngHead.Ang,
					znear = 1,
					zfar = 26000,
					fov = 95
				}
				return camfake
			end
		end
	end
end

hook.Add( "CalcView", "RagCam", ImersiveCam )

hook.Add( "PreDrawViewModel", "HMCD_ResetStencilState", function(vm, ply, wep)
    render.SetStencilEnable(false)
end)

concommand.Add("hmcd_fixvm", function()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end

    render.SetStencilEnable(false)
    render.SetBlend(255)
    render.SetColorModulation(1, 1, 1)
    render.SetBlendMode(BLEND_NORMAL)
    render.SetMaterial()

    local wep = lp:GetActiveWeapon()
    local vm  = lp:GetViewModel()
    if not IsValid(vm) then return end
    if not IsValid(wep) then
        vm:SetModel(vm:GetModel())
        return
    end

    vm:SetModel(vm:GetModel())
    vm:SetSkin(0)
    if wep.Bodygroups then
        for i, bgroup in pairs(wep.Bodygroups) do
            vm:SetBodygroup(i, bgroup)
        end
    end

    if wep.Deploy then wep:Deploy() end
    if wep.SetReady then wep:SetReady(true) end

    if wep.DoBFSAnimation then wep:DoBFSAnimation(wep.DrawAnim or wep.IdleAnim or "base_draw") end
end)
