-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
-- Support R6 + R15 | PC + Mobile
-- =========================================================

local Players   = game:GetService("Players")
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
    Fly.disable() -- cleanup dulu

    local char = lp.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Support R6 dan R15
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end

    hum.PlatformStand = true

    -- Disable semua humanoid state (anti gravity / anti fall)
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
    for _, state in ipairs(states) do
        hum:SetStateEnabled(state, false)
    end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)

    -- BodyGyro: orientasi karakter ikut kamera
    local bg = Instance.new("BodyGyro")
    bg.P          = 9e4
    bg.MaxTorque  = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame     = torso.CFrame
    bg.Parent     = torso
    flyBG = bg

    -- BodyVelocity: gerak karakter
    local bv = Instance.new("BodyVelocity")
    bv.Velocity  = Vector3.new(0, 0.1, 0)
    bv.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent    = torso
    flyBV = bv

    -- Smooth speed acceleration
    local currentSpeed = 0
    local maxSpeed     = Fly.speed
    local lastDir      = Vector3.zero

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

        local cam     = workspace.CurrentCamera
        local camCF   = cam.CoordinateFrame
        local moveDir = hum2.MoveDirection  -- works PC + mobile joystick!

        -- Konversi MoveDirection ke ctrl f/b/l/r
        local f = -moveDir.Z  -- maju
        local b =  moveDir.Z  -- mundur  
        local l = -moveDir.X  -- kiri
        local r =  moveDir.X  -- kanan

        local moving = (l + r ~= 0) or (f + b ~= 0)

        -- Smooth acceleration / deceleration
        if moving then
            currentSpeed = currentSpeed + 0.5 + (currentSpeed / maxSpeed)
            if currentSpeed > maxSpeed then
                currentSpeed = maxSpeed
            end
        else
            currentSpeed = currentSpeed - 1
            if currentSpeed < 0 then currentSpeed = 0 end
        end

        -- Set velocity
        if moving then
            local vel = ((camCF.LookVector * (f + b)) +
                ((camCF * CFrame.new(l + r, (f + b) * 0.2, 0).Position) - camCF.Position))
                * currentSpeed
            flyBV.Velocity = vel
            lastDir = Vector3.new(f + b, 0, l + r)
        elseif currentSpeed ~= 0 then
            -- Masih meluncur pelan (deceleration)
            local vel = ((camCF.LookVector * lastDir.X) +
                ((camCF * CFrame.new(lastDir.Z, lastDir.X * 0.2, 0).Position) - camCF.Position))
                * currentSpeed
            flyBV.Velocity = vel
        else
            flyBV.Velocity = Vector3.zero  -- hover stabil
        end

        -- Gyro tilt ikut arah gerak (visual keren)
        flyBG.CFrame = camCF * CFrame.Angles(-math.rad((f + b) * 50 * currentSpeed / maxSpeed), 0, 0)
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

    -- Re-enable semua humanoid state
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
    for _, state in ipairs(states) do
        hum:SetStateEnabled(state, true)
    end
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

print("[TIOO] fly.lua loaded! (R6+R15 | Smooth Accel)")
return Fly
