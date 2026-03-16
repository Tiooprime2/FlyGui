-- =========================================================
-- TIOO Fly Script - Roblox
-- by Tiooprime2
-- Executor: Delta / Codex
-- =========================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp   = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
local hum  = char:WaitForChild("Humanoid")

local flyEnabled = false
local flySpeed   = 50
local bodyVel, bodyGyro

-- =========================================================
-- FLY LOGIC
-- =========================================================

local function enableFly()
    if bodyVel  then bodyVel:Destroy()  end
    if bodyGyro then bodyGyro:Destroy() end

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 1e4
    bodyGyro.Parent = hrp

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.zero
    bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVel.Parent = hrp

    hum.PlatformStand = true
end

local function disableFly()
    if bodyVel  then bodyVel:Destroy();  bodyVel  = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    hum.PlatformStand = false
end

RunService.Heartbeat:Connect(function()
    if not flyEnabled or not bodyVel or not bodyGyro then return end

    local cam = workspace.CurrentCamera
    local dir = Vector3.zero

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir = dir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end

    bodyVel.Velocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * flySpeed
    bodyGyro.CFrame  = cam.CFrame
end)

lp.CharacterAdded:Connect(function(c)
    char = c
    hrp  = c:WaitForChild("HumanoidRootPart")
    hum  = c:WaitForChild("Humanoid")
    flyEnabled = false
    disableFly()
end)

-- =========================================================
-- GUI
-- =========================================================

local guiParent = gethui and gethui() or game:GetService("CoreGui")
local old = guiParent:FindFirstChild("TIOOFly")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name          = "TIOOFly"
gui.ResetOnSpawn  = false
gui.Parent        = guiParent

local frame = Instance.new("Frame")
frame.Size                = UDim2.new(0, 160, 0, 115)
frame.Position            = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3    = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel     = 0
frame.Active              = true
frame.Draggable           = true
frame.Parent              = gui

local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(51, 51, 51)
stroke.Thickness = 1
stroke.Parent    = frame

-- Header
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 22)
header.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
header.BorderSizePixel  = 0
header.Parent           = frame

local title = Instance.new("TextLabel")
title.Text             = "TIOO Fly"
title.Size             = UDim2.new(1, -8, 1, 0)
title.Position         = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3       = Color3.fromRGB(255, 255, 255)
title.TextXAlignment   = Enum.TextXAlignment.Left
title.Font             = Enum.Font.GothamBold
title.TextSize         = 11
title.Parent           = header

local underline = Instance.new("Frame")
underline.Size             = UDim2.new(1, 0, 0, 3)
underline.Position         = UDim2.new(0, 0, 1, -3)
underline.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
underline.BorderSizePixel  = 0
underline.Parent           = header

-- ON/OFF Button
local btn = Instance.new("TextButton")
btn.Size             = UDim2.new(1, -20, 0, 22)
btn.Position         = UDim2.new(0, 10, 0, 30)
btn.BackgroundColor3 = Color3.fromRGB(61, 26, 26)
btn.BorderSizePixel  = 0
btn.Text             = "OFF"
btn.TextColor3       = Color3.fromRGB(255, 85, 85)
btn.Font             = Enum.Font.GothamBold
btn.TextSize         = 11
btn.Parent           = frame

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

local btnStroke = Instance.new("UIStroke")
btnStroke.Color     = Color3.fromRGB(255, 85, 85)
btnStroke.Thickness = 1
btnStroke.Parent    = btn

-- Speed label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size             = UDim2.new(0.5, 0, 0, 14)
speedLabel.Position         = UDim2.new(0, 10, 0, 62)
speedLabel.BackgroundTransparency = 1
speedLabel.Text             = "Speed"
speedLabel.TextColor3       = Color3.fromRGB(170, 170, 170)
speedLabel.TextXAlignment   = Enum.TextXAlignment.Left
speedLabel.Font             = Enum.Font.Gotham
speedLabel.TextSize         = 10
speedLabel.Parent           = frame

local speedVal = Instance.new("TextLabel")
speedVal.Size             = UDim2.new(0.5, -10, 0, 14)
speedVal.Position         = UDim2.new(0.5, 0, 0, 62)
speedVal.BackgroundTransparency = 1
speedVal.Text             = tostring(flySpeed)
speedVal.TextColor3       = Color3.fromRGB(255, 119, 204)
speedVal.TextXAlignment   = Enum.TextXAlignment.Right
speedVal.Font             = Enum.Font.GothamBold
speedVal.TextSize         = 10
speedVal.Parent           = frame

-- Slider
local track = Instance.new("Frame")
track.Size             = UDim2.new(1, -20, 0, 3)
track.Position         = UDim2.new(0, 10, 0, 82)
track.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
track.BorderSizePixel  = 0
track.Parent           = frame
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size             = UDim2.new((flySpeed-1)/499, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
fill.BorderSizePixel  = 0
fill.Parent           = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local thumb = Instance.new("Frame")
thumb.Size            = UDim2.new(0, 10, 0, 16)
thumb.AnchorPoint     = Vector2.new(0.5, 0.5)
thumb.Position        = UDim2.new((flySpeed-1)/499, 0, 0.5, 0)
thumb.BackgroundColor3 = Color3.fromRGB(255, 119, 204)
thumb.BorderSizePixel = 0
thumb.ZIndex          = 3
thumb.Parent          = track
Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 3)

local hint = Instance.new("TextLabel")
hint.Size             = UDim2.new(1, 0, 0, 12)
hint.Position         = UDim2.new(0, 0, 1, -14)
hint.BackgroundTransparency = 1
hint.Text             = "WASD + Space / Ctrl"
hint.TextColor3       = Color3.fromRGB(80, 80, 80)
hint.Font             = Enum.Font.Gotham
hint.TextSize         = 9
hint.Parent           = frame

-- =========================================================
-- BUTTON LOGIC
-- =========================================================

btn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        enableFly()
        btn.Text             = "ON"
        btn.TextColor3       = Color3.fromRGB(85, 255, 85)
        btn.BackgroundColor3 = Color3.fromRGB(26, 61, 26)
        btnStroke.Color      = Color3.fromRGB(85, 255, 85)
    else
        disableFly()
        btn.Text             = "OFF"
        btn.TextColor3       = Color3.fromRGB(255, 85, 85)
        btn.BackgroundColor3 = Color3.fromRGB(61, 26, 26)
        btnStroke.Color      = Color3.fromRGB(255, 85, 85)
    end
end)

-- =========================================================
-- SLIDER LOGIC
-- =========================================================

local sliding = false

thumb.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        sliding = true
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if not sliding then return end
    if i.UserInputType ~= Enum.UserInputType.MouseMovement
    and i.UserInputType ~= Enum.UserInputType.Touch then return end

    local rel = math.clamp(
        (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
        0, 1
    )
    flySpeed       = math.floor(1 + rel * 499)
    speedVal.Text  = tostring(flySpeed)
    fill.Size      = UDim2.new(rel, 0, 1, 0)
    thumb.Position = UDim2.new(rel, 0, 0.5, 0)
end)

print("[TIOO] Fly loaded! Speed: " .. flySpeed)
