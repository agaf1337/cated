if SERVER then
	AddCSLuaFile()
	SWEP.Spawnable = true
else
	killicon.AddFont("wep_jack_hmcd_assaultrifle", "HL2MPTypeDeath", "1", Color(255, 0, 0))
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/tfa_ins2_akm_bw")
end

SWEP.IconOverride = "entities/tfa_ins2_akm_bw.png"
SWEP.IconTexture = "vgui/hud/tfa_ins2_akm_bw"
SWEP.IconLength = 3
SWEP.IconHeight = 2
SWEP.Base = "wep_cat_base"
SWEP.PrintName = "Underground Akm"
SWEP.Instructions = "The AKM base used in this build is made of various AK parts from similar guns, it was fucked up, it shoots slower than AKM and also has an extremely strong recoil. It uses a 7.62x39 caliber"
SWEP.Primary.ClipSize = 31
SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
SWEP.ViewModel = "models/weapons/tfa_ins2/c_akm_bw.mdl"
SWEP.WorldModel = "models/weapons/tfa_ins2/w_akm_bw.mdl"
SWEP.SwitchFM = true
SWEP.ViewModelFlip = false
SWEP.Damage = 30
SWEP.Category="HMCD: Union - Rifles"
SWEP.Primary.Automatic = true
SWEP.ViewModelFOV = 70
SWEP.SprintPos = Vector(10, 0, 1)
SWEP.SprintAng = Angle(-20, 40, 10)
SWEP.AimPos = Vector(-2.95, -4, 0.9)
SWEP.AimAng = Angle(1.3, 0, 0)
SWEP.CloseAimPos = Vector(.45, 0, 0)
SWEP.AltAimPos = Vector(-1.63, -4, 0.4)
SWEP.ReloadTime = 5
SWEP.ReloadRate = .6
SWEP.UseHands = true
SWEP.ReloadSound = ""
SWEP.AmmoType = "AR2"
SWEP.Primary.Ammo = "AR2"
SWEP.TriggerDelay = .1
SWEP.CycleTime = 0.035

SWEP.TPIK = false

SWEP.TPIK_PosAngles = {
    ["ValveBiped.Bip01_R_Upperarm"] = Angle(-5, 0, 0),
	["ValveBiped.Bip01_L_Upperarm"] = Angle(30, 0, 0),
	["ValveBiped.Bip01_L_Finger1"] = Angle(-60, 0, 0),
}

SWEP.TPIK_PosVectors = {
	["ValveBiped.Bip01_Spine2"] = Vector(3,0,0)
}

SWEP.ShootWait_Ragdoll = 0.2

SWEP.Recoil = .6
SWEP.AttBone = "Weapon"
SWEP.Supersonic = true
SWEP.Accuracy = .999
SWEP.ShotPitch = 100
SWEP.ENT = "ent_jack_hmcd_akmwreked"
SWEP.FuckedWorldModel = true
SWEP.DeathDroppable = false
SWEP.CommandDroppable = true
SWEP.Spawnable = true
SWEP.CycleType = "auto"
SWEP.ReloadType = "magazine"
SWEP.DrawAnim = "base_draw"
SWEP.FireAnim = "base_fire"
local abcs = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
}
SWEP.IronFireAnim = "iron_fire_"..abcs[math.random(1,#abcs)]
SWEP.ReloadAnim = "base_reloadempty"
SWEP.TacticalReloadAnim = "base_reload"
--SWEP.TacticalReloadAnim="base_reload"
SWEP.CloseFireSound = "sounds_zcity/akm/close.wav"
--SWEP.SuppressedFireSound="snd_jack_hmcd_supppistol.wav"
--SWEP.FarFireSound="snd_jack_hmcd_ar_far.wav"
SWEP.LaserAngle = Angle(270, 0, 0)

-- lasers

SWEP.LaserPos_Right = 0
SWEP.LaserPos_Forward = 0
SWEP.LaserPos_Up = 0
SWEP.LaserPos_RightCorrect = 0

--SWEP.CloseFireSound="ak74/ak74_fp.wav"
SWEP.FarFireSound = "ak74/ak74_dist.wav"
SWEP.SuppressedFireSound = "ak74/ak74_suppressed_fp.wav"
SWEP.ShellType = ""
SWEP.BarrelLength = 18
SWEP.FireAnimRate = 1
SWEP.AimTime = 6
SWEP.BearTime = 7
SWEP.HipHoldType = "ar2"
SWEP.AimHoldType = "ar2"
SWEP.DownHoldType = "passive"
SWEP.MuzzleEffect = "pcf_jack_mf_mrifle2"
SWEP.MuzzleEffectSuppressed = "pcf_jack_mf_suppressed"
SWEP.HipFireInaccuracy = .05
SWEP.HolsterSlot=1
SWEP.HolsterPos=Vector(3,-7,-4)
SWEP.HolsterAng=Angle(160,10,180)
SWEP.CarryWeight = 4500
SWEP.ScopeDotPosition = Vector(0, 0, 0)
SWEP.ScopeDotAngle = Angle(0, 0, 0)
SWEP.NextFireTime = 0
SWEP.ShellEffect = "eff_jack_hmcd_76239"
SWEP.ShellAttachment = 3
SWEP.MagEntity = "ent_jack_hmcd_akmmag"
SWEP.MagDelay = 1.9

SWEP.MuzzlePos = {30, -5.1, -3.1}

SWEP.InsHands = true
SWEP.ReloadAdd = 2

SWEP.ReloadSounds = {
	{"weapons/tfa_ins2/akm_bw/magout.wav", 0.9, "Both"},
	{"weapons/tfa_ins2/akm_bw/magin.wav", 3.6, "Both"},
	{"weapons/tfa_ins2/akm_bw/boltback.wav", 5.5, "EmptyOnly"},
	{"weapons/tfa_ins2/akm_bw/boltrelease.wav", 5.85, "EmptyOnly"}
}

SWEP.BulletDir = {400, 1.6, -10}

SWEP.SuicidePos = Vector(4, 7, -32)
SWEP.SuicideAng = Angle(100, 0, 90)
SWEP.SuicideTime = 10
SWEP.SuicideType = "Rifle"
SWEP.ProreloadMul = .5

SWEP.MuzzleInfo = {
	["Bone"] = "A_Muzzle",
	["Offset"] = Vector(30, 2, -2)
}

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()
    local scale = self.WorldModelScale or Vector(1, 1, 1)
    local mat = Matrix()
    mat:Scale(scale)
    self:EnableMatrix("RenderMultiply", mat)

    if not IsValid(ply) or not ply:Alive() then
        self:SetRenderOrigin(nil)
        self:SetRenderAngles(nil)
        self:DrawModel()
        return
    end

    local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
    if not bone then
        self:DrawModel()
        return
    end

    local pos, ang = ply:GetBonePosition(bone)
    pos = pos + ang:Forward() * 4
    pos = pos + ang:Right() * 0.6
    pos = pos + ang:Up() * -2

    ang:RotateAroundAxis(ang:Up(), 0)
    ang:RotateAroundAxis(ang:Right(), 0)
    ang:RotateAroundAxis(ang:Forward(), 180)

    self:SetRenderOrigin(pos)
    self:SetRenderAngles(ang)
    self:DrawModel()
end
