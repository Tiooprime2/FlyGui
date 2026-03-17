-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
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
-- SETUP BODY VELOCITY HELPER
-- =========================================================
local function setupBV(part)
    if flyBV then flyBV:Destroy() end
    local bv       = Instance.new("BodyVelocity")
    bv.Name        = "TIOO_FlyForce"
    bv.Velocity    = Vector3.zero
    bv.MaxForce    = Vector3.new(9e9, 9e9, 9e9)  -- Cukup kuat abaikan berat karakter
    bv.P           = 1250                          -- Respon instan
    bv.Parent      = part
    flyBV = bv
end

-- =========================================================
-- ENABLE
-- =========================================================
function Fly.enable()
    if flyConn then flyConn:Disconnect() end

    -- Setup BV di awal sebelum loop
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then setupBV(hrp) end

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not Fly.enabled then return end

        local currentChar = lp.Character
        local currentHRP  = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        local currentHum  = currentChar and currentChar:FindFirstChild("Humanoid")
        if not currentHRP or not currentHum then return end

        -- Pastikan PlatformStand aktif tiap frame
        currentHum.PlatformStand = true

        -- Rebuild BV kalau hilang atau pindah karakter (respawn)
        if not flyBV or flyBV.Parent ~= currentHRP then
            setupBV(currentHRP)
        end

        local cam   = workspace.CurrentCamera
        local look  = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector

        -- Horizontal movement relatif kamera
        local moveDir =
            (right * (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or
                     (UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0))) +
            (Vector3.new(look.X, 0, look.Z).Unit * (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or
                                                    (UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0)))

        -- Vertikal
        local upDown = (UserInputService:IsKeyDown(Enum.KeyCode.Space)       and 1 or 0)
                     - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0)

        local finalDir = moveDir + (Vector3.yAxis * upDown)

        if flyBV then
            if finalDir.Magnitude > 0 then
                flyBV.Velocity = finalDir.Unit * Fly.speed
            else
                flyBV.Velocity = Vector3.zero  -- Hover diam
            end
        end

        -- Paksa physics Roblox tidak bentrok dengan BV
        currentHRP.AssemblyLinearVelocity = Vector3.zero
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

print("[TIOO] fly.lua loaded!")
return Fly
