-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
-- PC + Mobile Compatible
-- =========================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer

local Fly = {}
Fly.enabled = false
Fly.speed   = 50

local flyConn = nil
local flyBV   = nil

-- =========================================================
-- SETUP BODY VELOCITY
-- =========================================================
local function setupBV(part)
    if flyBV then flyBV:Destroy() end
    local bv    = Instance.new("BodyVelocity")
    bv.Name     = "TIOO_FlyForce"
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.P        = 1250
    bv.Parent   = part
    flyBV = bv
end

-- =========================================================
-- ENABLE
-- =========================================================
function Fly.enable()
    if flyConn then flyConn:Disconnect() end

    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then setupBV(hrp) end

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not Fly.enabled then return end

        local currentChar = lp.Character
        local currentHRP  = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        local currentHum  = currentChar and currentChar:FindFirstChild("Humanoid")
        if not currentHRP or not currentHum then return end

        currentHum.PlatformStand = true

        -- Rebuild BV kalau respawn / hilang
        if not flyBV or flyBV.Parent ~= currentHRP then
            setupBV(currentHRP)
        end

        local cam = workspace.CurrentCamera

        -- ── HORIZONTAL MOVEMENT ──────────────────────────────
        -- Pakai MoveDirection (works PC + Mobile joystick!)
        -- MoveDirection adalah world-space, kita project ke arah kamera
        local rawMove = currentHum.MoveDirection  -- Vector3, magnitude 0~1

        local camCF  = cam.CFrame
        local look   = Vector3.new(camCF.LookVector.X,  0, camCF.LookVector.Z)
        local right  = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)

        -- Normalize hanya kalau tidak zero (hindari NaN)
        if look.Magnitude  > 0 then look  = look.Unit  end
        if right.Magnitude > 0 then right = right.Unit end

        -- Project input joystick/WASD ke arah kamera
        -- rawMove.X = strafe (kiri/kanan), rawMove.Z = maju/mundur
        local hDir = right * rawMove.X + look * (-rawMove.Z)

        -- ── VERTICAL MOVEMENT ────────────────────────────────
        -- PC: Space / LeftControl
        -- Mobile: bisa tambah tombol UI sendiri nanti
        local upDown = (UserInputService:IsKeyDown(Enum.KeyCode.Space)       and 1 or 0)
                     - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0)

        local finalDir = hDir + Vector3.yAxis * upDown

        -- ── APPLY VELOCITY ───────────────────────────────────
        if flyBV then
            if finalDir.Magnitude > 0 then
                flyBV.Velocity = finalDir.Unit * Fly.speed
            else
                flyBV.Velocity = Vector3.zero  -- Hover stabil
            end
        end
    end)
end

-- =========================================================
-- DISABLE
-- =========================================================
function Fly.disable()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV   then flyBV:Destroy();      flyBV   = nil end
    local currentChar = lp.Character
    if currentChar then
        local currentHum = currentChar:FindFirstChild("Humanoid")
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

print("[TIOO] fly.lua loaded! (PC + Mobile)")
return Fly
