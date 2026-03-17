-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
-- Logic: XNEO (TranslateBy + BodyGyro hover)
-- =========================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

local Fly = {}
Fly.enabled = false
Fly.speed   = 50

local flyHoverConn = nil  -- untuk hover (BodyGyro + BodyVelocity)
local flyMoveConn  = nil  -- untuk gerak (TranslateBy)
local flyBG        = nil
local flyBV        = nil

-- =========================================================
-- ENABLE
-- =========================================================
function Fly.enable()
    Fly.disable()

    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Disable semua state biar gak jatuh (sama XNEO)
    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
    hum:ChangeState(Enum.HumanoidStateType.Swimming)

    -- Stop animasi (sama XNEO)
    char.Animate.Disabled = true
    local animHum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("AnimationController")
    if animHum then
        for _, track in next, animHum:GetPlayingAnimationTracks() do
            track:AdjustSpeed(0)
        end
    end

    hum.PlatformStand = true

    -- BodyGyro: biar karakter gak goyang/jatuh saat hover
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end

    local bg = Instance.new("BodyGyro", torso)
    bg.P         = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame    = torso.CFrame
    flyBG = bg

    local bv = Instance.new("BodyVelocity", torso)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV = bv

    -- Gyro ikutin kamera tiap frame
    flyHoverConn = RunService.RenderStepped:Connect(function()
        if not Fly.enabled then return end
        local cam = workspace.CurrentCamera
        if flyBG then
            flyBG.CFrame = cam.CoordinateFrame
        end
    end)

    -- Gerak pakai TranslateBy dari MoveDirection (sama XNEO, ini yang works!)
    flyMoveConn = RunService.Heartbeat:Connect(function()
        if not Fly.enabled then return end
        local char2 = lp.Character
        if not char2 then return end
        local hum2 = char2:FindFirstChildOfClass("Humanoid")
        if not hum2 then return end

        if hum2.MoveDirection.Magnitude > 0 then
            -- TranslateBy sama persis XNEO, dikalikan speed
            char2:TranslateBy(hum2.MoveDirection * (Fly.speed / 50))
        end
    end)
end

-- =========================================================
-- DISABLE
-- =========================================================
function Fly.disable()
    Fly.enabled = false

    if flyHoverConn then flyHoverConn:Disconnect(); flyHoverConn = nil end
    if flyMoveConn  then flyMoveConn:Disconnect();  flyMoveConn  = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end

    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.PlatformStand = false
    char.Animate.Disabled = false

    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
end

-- =========================================================
-- TOGGLE
-- =========================================================
function Fly.toggle()
    Fly.enabled = not Fly.enabled
    if Fly.enabled then
        Fly.enable()
    else
        Fly.disable()
    end
    return Fly.enabled
end

-- Auto cleanup saat respawn
lp.CharacterAdded:Connect(function()
    Fly.enabled = false
    Fly.disable()
end)

print("[TIOO] fly.lua loaded! (XNEO TranslateBy)")
return Fly
