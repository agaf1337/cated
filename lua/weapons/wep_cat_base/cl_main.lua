if CLIENT then
    killicon.AddFont(
        "wep_jack_hmcd_smallpistol",
        "HL2MPTypeDeath",
        "1",
        Color(255, 0, 0)
    )
    SWEP.WepSelectIcon = surface.GetTextureID(
        "vgui/wep_jack_hmcd_smallpistol"
    )
    SWEP.BounceWeaponIcon = false
    SWEP.Primary.Ammo = SWEP.AmmoType
end
if CLIENT then
    local LastAimGotten = 0
    local LastSuicideGotten = 0
    local LastSprintGotten = 0
    local LastBipodGotten = 0
    local function SmoothLerp(speed, ft)
        return 1 - math.exp(-speed * ft)
    end
    function SWEP:StartViewModelRecoil()
        if self:GetOwner() ~= LocalPlayer() then return end
        self.vmRecoil = self.vmRecoil or Angle(0, 0, 0)
        self.vmRecoilTarget = self.vmRecoilTarget or Angle(0, 0, 0)
        local recoil = tonumber(self.Recoil) or 1
        // how much recoil is already accumulated.
        local accumulated = math.Clamp(
            math.abs(self.vmRecoilTarget.p) / math.max(recoil * 8, 1),
            0,
            1
        )
        local instability =
            1 + accumulated * 0.65
        local verticalKick =
            recoil
            * math.Rand(-0.35, 0.35)
            * instability
        self.vmRecoilTarget.p =
            math.Clamp(
                self.vmRecoilTarget.p + verticalKick,
                0,
                recoil * 8
            )
        local horizontalKick =
            recoil
            * math.Rand(-1.6, 1.6)
            * instability
        self.vmRecoilTarget.y =
            math.Clamp(
                self.vmRecoilTarget.y + horizontalKick,
                -recoil * 14,
                recoil * 14
            )
        local rollKick =
            recoil
            * math.Rand(-0.08, 0.08)
            * instability
        self.vmRecoilTarget.r =
            math.Clamp(
                self.vmRecoilTarget.r + rollKick,
                -recoil * 2,
                recoil * 2
            )
        self.vmLastRecoilShot = CurTime()
    end
    function SWEP:CheckViewModelRecoilShot()
        if self:GetOwner() ~= LocalPlayer() then return end
        self.vmLastClip =
            self.vmLastClip or self:Clip1()
        local clip = self:Clip1()
        if
            clip >= 0
            and self.vmLastClip >= 0
            and clip < self.vmLastClip
        then
            local shots =
                math.Clamp(
                    self.vmLastClip - clip,
                    1,
                    3
                )
            for i = 1, shots do
                self:StartViewModelRecoil()
            end
            self.vmLastClip = clip
            return
        end
        self.vmLastClip = clip
        if self.LastFire
            and self.LastFire ~= self.vmLastFire
            and self:Clip1() > 0
        then
            self.vmLastFire = self.LastFire
            if self.vmLastRecoilShot ~= self.LastFire then
                self:StartViewModelRecoil()
            end
        end
    end
    function SWEP:GetViewModelPosition(pos, ang)
        if LocalPlayer() ~= self:GetOwner() then
            self:Think()
        end
        local FrontBlocked =
            self.FrontBlocked or 0
        local FrontBlockedPerc =
            self.FrontBlockedPerc or 0
        local Sprint =
            math.Clamp(
                self.SprintingWeapon / 100,
                0,
                1
            )
        local AimGotten =
            Lerp(
                0.05,
                LastAimGotten,
                self.AimPerc / 100
            )
        LastAimGotten = AimGotten
        local Bipod =
            Lerp(
                0.05,
                LastBipodGotten,
                self.BipodAmt / 100
            )
        LastBipodGotten = Bipod
        local Aim = AimGotten
        local SuicideGotten =
            Lerp(
                0.05,
                LastSuicideGotten,
                self.SuicideAmt / 100
            )
        LastSuicideGotten = SuicideGotten
        local Suicide = SuicideGotten
        local Up =
            ang:Up()
        local Forward =
            ang:Forward()
        local Right =
            ang:Right()
        local SprintGotten =
            Lerp(
                0.05,
                LastSprintGotten,
                (self.SprintingWeapon / 100)
                    * (
                        1
                        - FrontBlocked
                        * (1 - Sprint)
                    )
                    + FrontBlockedPerc
                    * (1 - Sprint)
            )
        LastSprintGotten = SprintGotten
        Sprint = SprintGotten
        if self.InertiaScale ~= 0 then
            local ply = self:GetOwner()
            if IsValid(ply) then
                self.hk_OldMouseAng =
                    self.hk_OldMouseAng
                    or (
                        ply:EyeAngles()
                        - ply:GetViewPunchAngles()
                    )
                self.hk_SwayAngDiff =
                    self.hk_SwayAngDiff
                    or Angle(0, 0, 0)
                self.hk_SwayAng =
                    self.hk_SwayAng
                    or Angle(0, 0, 0)
                local curMouseAng =
                    ply:EyeAngles()
                    - ply:GetViewPunchAngles()
                local delta =
                    curMouseAng
                    - self.hk_OldMouseAng
                delta:Normalize()
                self.hk_OldMouseAng =
                    curMouseAng
                self.hk_SwayAngDiff =
                    LerpAngle(
                        math.Clamp(
                            FrameTime() * 1,
                            0,
                            1
                        ),
                        self.hk_SwayAngDiff,
                        delta
                    )
                local swayTarget =
                    Angle(0, 0, 0)
                local punch =
                    ply:GetViewPunchAngles()
                swayTarget.p =
                    self.hk_SwayAngDiff.p * 25
                swayTarget.y =
                    self.hk_SwayAngDiff.y * 20
                    + punch.y * 1.2
                self.hk_SwayAng =
                    LerpAngle(
                        math.min(
                            1,
                            FrameTime() * 200
                        ),
                        self.hk_SwayAng,
                        swayTarget
                    )
                self.hk_SwayAng.p =
                    math.Clamp(
                        self.hk_SwayAng.p,
                        -20,
                        20
                    )
                self.hk_SwayAng.y =
                    math.Clamp(
                        self.hk_SwayAng.y,
                        -30,
                        30
                    )
                ang =
                    ang + self.hk_SwayAng
            end
        end
        ang:RotateAroundAxis(
            Right,
            self.SprintAng.p * Sprint
        )
        ang:RotateAroundAxis(
            Up,
            self.SprintAng.y * Sprint
        )
        ang:RotateAroundAxis(
            Forward,
            self.SprintAng.r * Sprint
        )
        if self.SuicideAng then
            ang:RotateAroundAxis(
                ang:Right(),
                self.SuicideAng.p * Suicide
            )
            ang:RotateAroundAxis(
                ang:Up(),
                self.SuicideAng.y * Suicide
            )
            ang:RotateAroundAxis(
                ang:Forward(),
                self.SuicideAng.r * Suicide
            )
        end
        if self.AimAng then
            ang:RotateAroundAxis(
                Right,
                self.AimAng.p * Aim
            )
            ang:RotateAroundAxis(
                Up,
                self.AimAng.y * Aim
            )
            ang:RotateAroundAxis(
                Forward,
                self.AimAng.r * Aim
            )
        end
        if
            self.LastFire
            and self.LastFire ~= self.hk_LastShot
        then
            self.hk_LastShot =
                self.LastFire
        self.hk_shake = math.min(0.55, (self.hk_shake or 0) + 0.51)
    end
    self.hk_shake = math.max(0, (self.hk_shake or 0) - FrameTime() * 1)
    self.smth = self.smth or 0

    local isAiming = (self.AimPerc or 0) >= 99 && self.Scoped

    local baseSway = isAiming and 0 or 0.15
    local painSway = (ply:GetNWFloat("pain", 0) / 150) * (isAiming and 0 or 1)

    self.t1arget = (
            self:GetOwner():GetNWBool("ane_ra")
            and 0.6
            or (baseSway + painSway)
        )
        +
        (
            self:GetOwner():GetNWBool("ane_la")
            and 0.35
            or 0
        )

    if isAiming then
        self.t1arget = 0
    end

    self.smth = Lerp(FrameTime() * 5, self.smth, self.t1arget)

    ang:RotateAroundAxis(ang:Up(), math.sin(CurTime() * 5) * self.smth)
    ang:RotateAroundAxis(ang:Right(), math.cos(CurTime() * 5) * self.smth)

        self:CheckViewModelRecoilShot()
        self.vmRecoil =
            self.vmRecoil
            or Angle(0, 0, 0)
        self.vmRecoilTarget =
            self.vmRecoilTarget
            or Angle(0, 0, 0)
        local ft =
            math.min(
                FrameTime(),
                0.033
            )
        local recoilLerp =
            SmoothLerp(
                1,
                ft
            )
        self.vmRecoil.p =
            Lerp(
                recoilLerp,
                self.vmRecoil.p,
                self.vmRecoilTarget.p
            )
        self.vmRecoil.y =
            Lerp(
                recoilLerp,
                self.vmRecoil.y,
                self.vmRecoilTarget.y
            )
        self.vmRecoil.r =
            Lerp(
                recoilLerp,
                self.vmRecoil.r,
                self.vmRecoilTarget.r
            )
        local sinceShot =
            CurTime()
            - (self.vmLastRecoilShot or -999)
        if sinceShot > 0.08 then
            local recovery =
                SmoothLerp(
                    1,
                    ft
                )
            self.vmRecoilTarget.p =
                Lerp(
                    recovery,
                    self.vmRecoilTarget.p,
                    0
                )
            self.vmRecoilTarget.y =
                Lerp(
                    recovery,
                    self.vmRecoilTarget.y,
                    0
                )
            self.vmRecoilTarget.r =
                Lerp(
                    recovery,
                    self.vmRecoilTarget.r,
                    0
                )
        end
        ang:RotateAroundAxis(
            ang:Right(),
            -self.vmRecoil.p
        )
        ang:RotateAroundAxis(
            ang:Up(),
            self.vmRecoil.y
        )
        ang:RotateAroundAxis(
            ang:Forward(),
            self.vmRecoil.r
        )
        local npos =
            LerpVector(
                Aim,
                Vector(0, 0, 0),
                self.AttAimPos or self.AimPos
            )
        local spos =
            LerpVector(
                Sprint,
                Vector(0, 0, 0),
                self.SprintPos
            )
        local kpos =
            LerpVector(
                Suicide,
                Vector(0, 0, 0),
                self.SuicidePos
                or Vector(0, 0, 0)
            )
        return
            pos
            + Right
                * (
                    npos[1]
                    + spos[1]
                    + kpos[1]
                )
            + Forward
                * (
                    npos[2]
                    + spos[2]
                    + kpos[2]
                )
            + Up
                * (
                    npos[3]
                    + spos[3]
                    + kpos[3]
                ),
            ang
    end
    function SWEP:FireAnimationEvent(
        pos,
        ang,
        event,
        name
    )
        return true
    end
end
if CLIENT then
    local laserline =
        Material("cable/smoke")
    local laserdot =
        Material("effects/tfalaserdot")
    SWEP.LaserDistance = 6000
    SWEP.LaserFOV = 1.5
    SWEP.LaserColor =
        Color(255, 0, 0, 255)
    function SWEP:DrawLaser()
        if not IsValid(self:GetOwner()) then
            return
        end
        if not self.WDrawnAttachments
            or not self.WDrawnAttachments["Laser"]
        then
            return
        end
        local attachment =
            self.WDrawnAttachments["Laser"]
        if not IsValid(attachment) then
            return
        end
        local pos =
            attachment:GetPos()
        local ang =
            attachment:GetAngles()
        if attachment:GetModel()
            == "models/cw2/attachments/anpeq15.mdl"
        then
            ang:RotateAroundAxis(
                ang:Right(),
                180
            )
        end
        local ply =
            self:GetOwner()
        if not IsValid(ply.HMCDLaserDot) then
            local lamp =
                ProjectedTexture()
            ply.HMCDLaserDot =
                lamp
            lamp:SetTexture(
                laserdot:GetString(
                    "$basetexture"
                )
            )
            lamp:SetFarZ(
                self.LaserDistance
            )
            lamp:SetFOV(
                self.LaserFOV
            )
            lamp:SetPos(pos)
            lamp:SetAngles(ang)
            lamp:SetBrightness(15)
            lamp:SetNearZ(1)
            lamp:SetEnableShadows(false)
            lamp:Update()
            self.LastLaserUpdate =
                CurTime()
            local entIndex =
                ply:EntIndex()
            hook.Add(
                "Think",
                "Laserdot_" .. entIndex,
                function()
                    if not (
                        IsValid(ply)
                        and IsValid(lamp)
                        and IsValid(self)
                        and self.LastLaserUpdate
                    ) then
                        hook.Remove(
                            "Think",
                            "Laserdot_" .. entIndex
                        )
                        return
                    end
                    if
                        self.LastLaserUpdate
                        + 0.1
                        < CurTime()
                    then
                        lamp:Remove()
                    end
                end
            )
        end
        local lamp =
            ply.HMCDLaserDot
        if IsValid(lamp) then
            ang:RotateAroundAxis(
                ang:Forward(),
                math.Rand(-180, 180)
            )
            lamp:SetPos(pos)
            lamp:SetAngles(ang)
            lamp:SetColor(
                self.LaserColor
            )
            lamp:SetFOV(
                self.LaserFOV
                * math.Rand(0.9, 1.1)
            )
            lamp:Update()
            self.LastLaserUpdate =
                CurTime()
        end
    end
    function SWEP:CleanLaser()
        local own =
            self:GetOwner()
        if IsValid(own)
            and IsValid(own.HMCDLaserDot)
        then
            own.HMCDLaserDot:Remove()
        end
    end
end
if CLIENT then
    LocalPlayer().isOneHanded = false
    local isOneHanded = false
    local oneHandedDelta = 0
    local targetDelta = 0
    local LHIKBones = {
        "ValveBiped.Bip01_L_UpperArm",
        "ValveBiped.Bip01_L_Forearm",
        "ValveBiped.Bip01_L_Wrist",
        "ValveBiped.Bip01_L_Ulna",
        "ValveBiped.Bip01_L_Hand",
        "ValveBiped.Bip01_L_Finger4",
        "ValveBiped.Bip01_L_Finger41",
        "ValveBiped.Bip01_L_Finger42",
        "ValveBiped.Bip01_L_Finger3",
        "ValveBiped.Bip01_L_Finger31",
        "ValveBiped.Bip01_L_Finger32",
        "ValveBiped.Bip01_L_Finger2",
        "ValveBiped.Bip01_L_Finger21",
        "ValveBiped.Bip01_L_Finger22",
        "ValveBiped.Bip01_L_Finger1",
        "ValveBiped.Bip01_L_Finger11",
        "ValveBiped.Bip01_L_Finger12",
        "ValveBiped.Bip01_L_Finger0",
        "ValveBiped.Bip01_L_Finger01",
        "ValveBiped.Bip01_L_Finger02"
    }
    local RHIKBones = {
        "ValveBiped.Bip01_R_UpperArm",
        "ValveBiped.Bip01_R_Forearm",
        "ValveBiped.Bip01_R_Wrist",
        "ValveBiped.Bip01_R_Ulna",
        "ValveBiped.Bip01_R_Hand",
        "ValveBiped.Bip01_R_Finger4",
        "ValveBiped.Bip01_R_Finger41",
        "ValveBiped.Bip01_R_Finger42",
        "ValveBiped.Bip01_R_Finger3",
        "ValveBiped.Bip01_R_Finger31",
        "ValveBiped.Bip01_R_Finger32",
        "ValveBiped.Bip01_R_Finger2",
        "ValveBiped.Bip01_R_Finger21",
        "ValveBiped.Bip01_R_Finger22",
        "ValveBiped.Bip01_R_Finger1",
        "ValveBiped.Bip01_R_Finger11",
        "ValveBiped.Bip01_R_Finger12",
        "ValveBiped.Bip01_R_Finger0",
        "ValveBiped.Bip01_R_Finger01",
        "ValveBiped.Bip01_R_Finger02"
    }
    net.Receive(
        "OneHandedToggle",
        function()
            isOneHanded =
                net.ReadBool()
            targetDelta =
                isOneHanded
                and 1
                or 0
        end
    )
    hook.Add(
        "Think",
        "OneHandedDeltaLerp",
        function()
            local ply =
                LocalPlayer()
            if IsValid(ply) then
                local laBroken =
                    ply:GetNWBool(
                        "ane_la",
                        false
                    )
                local shouldBeOneHanded =
                    isOneHanded
                    or laBroken
                targetDelta =
                    shouldBeOneHanded
                    and 1
                    or 0
                if targetDelta ~= oneHandedDelta then
                    oneHandedDelta =
                        Lerp(
                            FrameTime() * 3,
                            oneHandedDelta,
                            targetDelta
                        )
                    if math.abs(
                        oneHandedDelta
                        - targetDelta
                    ) < 0.01 then
                        oneHandedDelta =
                            targetDelta
                    end
                end
            end
        end
    )
    function GetOneHandedDelta()
        return oneHandedDelta
    end
    function IsOneHandedMode()
        return
            isOneHanded
            or LocalPlayer():GetNWBool(
                "ane_la",
                false
            )
    end
    hook.Add(
        "PreDrawViewModel",
        "OneHandedViewmodel",
        function(
            vm,
            ply,
            weapon
        )
            if not IsValid(weapon)
                or not weapon.CanOneHanded
            then
                return
            end
            if oneHandedDelta <= 0 then
                return
            end
            local ea =
                EyeAngles()
            local bones =
                weapon.OneHandReverse
                and RHIKBones
                or LHIKBones
            for _, bone in ipairs(bones) do
                local vmbone =
                    vm:LookupBone(bone)
                if not vmbone then
                    continue
                end
                local vmtransform =
                    vm:GetBoneMatrix(vmbone)
                if not vmtransform then
                    continue
                end
                local vm_pos =
                    vmtransform:GetTranslation()
                local vm_ang =
                    vmtransform:GetAngles()
                local newtransform =
                    Matrix()
                local offset =
                    (ea:Up() * 12)
                    + (ea:Forward() * 12)
                    + (ea:Right() * 4)
                newtransform:SetTranslation(
                    LerpVector(
                        oneHandedDelta,
                        vm_pos,
                        vm_pos - offset
                    )
                )
                newtransform:SetAngles(
                    vm_ang
                )
                vm:SetBoneMatrix(
                    vmbone,
                    newtransform
                )
            end
        end
    )
end