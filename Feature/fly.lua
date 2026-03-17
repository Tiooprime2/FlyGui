-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
-- Support R6 + R15 | PC + Mobile
-- =========================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

local Fly = {}
Fly.enabled = false
Fly.speed   = 50

local flyConn = nil
local flyBG   = nil
local flyBV   = nil

-- =========================================================
-- ENABLE
-- =========================================================
function Fly.enable()
    Fly.disable()

    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- R6 atau R15
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end

    hum.PlatformStand = true

    -- Disable semua state biar gak jatuh
    local states = {
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Flying,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Landed,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.Swimming,
    }
    for _, s in ipairs(states) do hum:SetStateEnabled(s, false) end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)

    local bg = Instance.new("BodyGyro")
    bg.P         = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame    = torso.CFrame
    bg.Parent    = torso
    flyBG = bg

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0.1, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent   = torso
    flyBV = bv

    local currentSpeed = 0
    local maxSpeed     = Fly.speed
    local lastMove     = Vector3.zero

    flyConn = RunService.RenderStepped:Connect(function()
        if not Fly.enabled then return end

        local char2  = lp.Character
        if not char2 then return end
        local hum2   = char2:FindFirstChildOfClass("Humanoid")
        if not hum2  then return end
        local torso2 = char2:FindFirstChild("UpperTorso") or char2:FindFirstChild("Torso")
        if not torso2 then return end

        hum2.PlatformStand = true
        maxSpeed = Fly.speed

        -- Ambil MoveDirection langsung (works mobile + PC)
        local md = hum2.MoveDirection  -- Vector3, world space
        local moving = md.Magnitude > 0.1

        -- Smooth accel/decel sama persis kayak script asli
        if moving then
            currentSpeed = currentSpeed + 0.5 + (currentSpeed / maxSpeed)
            if currentSpeed > maxSpeed then currentSpeed = maxSpeed end
            lastMove = md
        else
            currentSpeed = currentSpeed - 1
            if currentSpeed < 0 then currentSpeed = 0 end
        end

        local cam   = workspace.CurrentCamera
        local camCF = cam.CoordinateFrame

        if moving or currentSpeed > 0 then
            local dir = moving and md or lastMove
            -- Pakai formula SAMA PERSIS dari script asli, tinggal ganti ctrl ke MoveDirection
            -- dir.X = strafe (kiri/kanan), dir.Z = maju/mundur
            local f = -dir.Z  -- maju = Z negatif
            local r =  dir.X  -- kanan = X positif

            flyBV.Velocity = (
                (camCF.LookVector * f) +
                ((camCF * CFrame.new(r, f * 0.2, 0).Position) - camCF.Position)
            ) * currentSpeed

            -- Tilt badan saat maju (visual)
            flyBG.CFrame = camCF * CFrame.Angles(-math.rad(f * 50 * currentSpeed / maxSpeed), 0, 0)
        else
            flyBV.Velocity = Vector3.zero
            flyBG.CFrame   = camCF
        end
    end)
end

-- =========================================================
-- DISABLE
-- =========================================================
function Fly.disable()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBG   then flyBG:Destroy();      flyBG   = nil end
    if flyBV   then flyBV:Destroy();      flyBV   = nil end

    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.PlatformStand = false

    local states = {
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Flying,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Landed,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.Swimming,
    }
    for _, s in ipairs(states) do hum:SetStateEnabled(s, true) end
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

print("[TIOO] fly.lua loaded! (R6+R15 | Smooth | Mobile+PC)")
return Fly
