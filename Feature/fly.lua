-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
-- PC + Mobile Compatible (BodyGyro + BodyVelocity)
-- =========================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local lp = Players.LocalPlayer

local Fly = {}
Fly.enabled = false
Fly.speed   = 50

local flyConn = nil
local flyBV   = nil
local flyBG   = nil

-- =========================================================
-- ENABLE
-- =========================================================
function Fly.enable()
    -- Cleanup dulu kalau ada sisa
    Fly.disable()

    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root then return end

    hum.PlatformStand = true

    -- BodyGyro: bikin karakter menghadap arah kamera (stabil, tidak goyang)
    local bg = Instance.new("BodyGyro")
    bg.P          = 9e4
    bg.MaxTorque  = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame     = root.CFrame
    bg.Parent     = root
    flyBG = bg

    -- BodyVelocity: gerakkan karakter
    local bv = Instance.new("BodyVelocity")
    bv.Velocity  = Vector3.zero
    bv.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent    = root
    flyBV = bv

    flyConn = RunService.RenderStepped:Connect(function()
        if not Fly.enabled then return end

        local currentChar = lp.Character
        local currentHum  = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
        local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHum or not currentRoot then return end

        -- Pastikan PlatformStand aktif terus
        currentHum.PlatformStand = true

        -- Rebuild BG/BV kalau respawn / hilang
        if not flyBG or flyBG.Parent ~= currentRoot then
            if flyBG then flyBG:Destroy() end
            local newBG = Instance.new("BodyGyro")
            newBG.P         = 9e4
            newBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            newBG.CFrame    = currentRoot.CFrame
            newBG.Parent    = currentRoot
            flyBG = newBG
        end

        if not flyBV or flyBV.Parent ~= currentRoot then
            if flyBV then flyBV:Destroy() end
            local newBV = Instance.new("BodyVelocity")
            newBV.Velocity = Vector3.zero
            newBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            newBV.Parent   = currentRoot
            flyBV = newBV
        end

        local cam      = workspace.CurrentCamera
        local look     = cam.CFrame.LookVector
        local moveDir  = currentHum.MoveDirection  -- Works PC + Mobile joystick!

        -- Gyro ikutin arah kamera
        flyBG.CFrame = cam.CFrame

        -- Gerak horizontal dari joystick/WASD, vertikal dari arah kamera
        if moveDir.Magnitude > 0 then
            flyBV.Velocity = Vector3.new(
                moveDir.X * Fly.speed,
                look.Y    * Fly.speed,  -- naik/turun sesuai sudut kamera
                moveDir.Z * Fly.speed
            )
        else
            flyBV.Velocity = Vector3.zero  -- Hover stabil
        end
    end)
end

-- =========================================================
-- DISABLE
-- =========================================================
function Fly.disable()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV   then flyBV:Destroy();      flyBV   = nil end
    if flyBG   then flyBG:Destroy();      flyBG   = nil end
    local currentChar = lp.Character
    if currentChar then
        local currentHum = currentChar:FindFirstChildOfClass("Humanoid")
        if currentHum then currentHum.PlatformStand = false end
    end
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

print("[TIOO] fly.lua loaded! (PC + Mobile | BodyGyro)")
return Fly
