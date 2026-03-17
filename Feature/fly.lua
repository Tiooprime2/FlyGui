-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
-- =========================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer

-- State (diakses dari luar via module)
local Fly = {}
Fly.enabled = false
Fly.speed   = 50

local flyConn = nil
local flyBV   = nil

-- =========================================================
-- ENABLE
-- =========================================================
function Fly.enable()
    if flyConn then flyConn:Disconnect() end

    local currentChar = lp.Character
    if not currentChar then return end
    local currentHRP = currentChar:FindFirstChild("HumanoidRootPart")
    local currentHum = currentChar:FindFirstChild("Humanoid")
    if not currentHRP or not currentHum then return end

    currentHum.PlatformStand = true

    -- Bersihkan BV lama
    if flyBV then flyBV:Destroy() end
    local bv        = Instance.new("BodyVelocity")
    bv.Velocity     = Vector3.zero
    bv.MaxForce     = Vector3.new(1e5, 1e5, 1e5)
    bv.P            = 1e4
    bv.Parent       = currentHRP
    flyBV = bv

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not Fly.enabled then return end

        local char2 = lp.Character
        if not char2 then return end
        local hrp2  = char2:FindFirstChild("HumanoidRootPart")
        local hum2  = char2:FindFirstChild("Humanoid")
        if not hrp2 or not hum2 then return end

        -- Pindahkan BV kalau karakter respawn
        if flyBV and flyBV.Parent ~= hrp2 then
            flyBV:Destroy()
            local newBV     = Instance.new("BodyVelocity")
            newBV.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
            newBV.P         = 1e4
            newBV.Parent    = hrp2
            flyBV = newBV
        end

        hum2.PlatformStand = true

        local cam   = workspace.CurrentCamera
        local look  = Vector3.new(cam.CFrame.LookVector.X,  0, cam.CFrame.LookVector.Z).Unit
        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit

        local inputX = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0)
                     - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
        local inputZ = (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                     - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)

        local dir = right * inputX + look * (-inputZ)

        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end

        if flyBV then
            flyBV.Velocity = (dir.Magnitude > 0) and (dir.Unit * Fly.speed) or Vector3.zero
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

-- Auto cleanup kalau respawn
lp.CharacterAdded:Connect(function()
    Fly.enabled = false
    Fly.disable()
end)

print("[TIOO] fly.lua loaded!")
return Fly
