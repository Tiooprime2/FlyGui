-- =========================================================
-- TIOO Fly Script - Roblox
-- by Tiooprime2 | Ninja Legends fix
-- =========================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local lp   = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp  = char:WaitForChild("HumanoidRootPart")
local hum  = char:WaitForChild("Humanoid")

local flyEnabled = false
local flySpeed   = 50

-- =========================================================
-- THEME
-- =========================================================
local T = {
    BG_DARK      = Color3.fromRGB(8,   8,  12),
    BG_PANEL     = Color3.fromRGB(14,  14, 20),
    BG_CARD      = Color3.fromRGB(20,  20, 30),
    BG_HOVER     = Color3.fromRGB(28,  28, 42),
    BG_ACTIVE    = Color3.fromRGB(35,  55, 85),
    ACCENT       = Color3.fromRGB(80,  140, 255),
    ACCENT_GLOW  = Color3.fromRGB(60,  100, 220),
    GREEN        = Color3.fromRGB(50,  210, 120),
    GREEN_BG     = Color3.fromRGB(15,  35,  20),
    RED          = Color3.fromRGB(255, 70,  70),
    TEXT_PRIMARY = Color3.fromRGB(235, 235, 245),
    TEXT_MUTED   = Color3.fromRGB(130, 130, 160),
    BORDER       = Color3.fromRGB(40,  40,  60),
}

-- =========================================================
-- UTILS
-- =========================================================
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

local function stroke(obj, color, thick)
    local s = Instance.new("UIStroke")
    s.Color     = color or T.BORDER
    s.Thickness = thick or 1
    s.Parent    = obj
    return s
end

local function tw(obj, t, props)
    TweenService:Create(obj,
        TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props):Play()
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = input.Position - dragStart
            tw(frame, 0.06, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            })
        end
    end)
end

-- =========================================================
-- FLY LOGIC — CFrame based (works on Ninja Legends)
-- =========================================================
local flyConn

local function enableFly()
    -- Matikan gravity & physics
    hum.PlatformStand = true

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled then return end

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero
        local spd = flySpeed * 0.8

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir += cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir -= cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir -= cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir += cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir += Vector3.yAxis
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir -= Vector3.yAxis
        end

        if moveDir.Magnitude > 0 then
            local newCF = hrp.CFrame + (moveDir.Unit * spd * dt * 60)
            hrp.CFrame = newCF
        end

        -- Keep freezed in place when not moving
        hrp.Velocity        = Vector3.zero
        hrp.RotVelocity     = Vector3.zero
    end)
end

local function disableFly()
    hum.PlatformStand = false
    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
end

lp.CharacterAdded:Connect(function(c)
    char       = c
    hrp        = c:WaitForChild("HumanoidRootPart")
    hum        = c:WaitForChild("Humanoid")
    flyEnabled = false
    disableFly()
end)

-- =========================================================
-- GUI
-- =========================================================
local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
local old = guiParent:FindFirstChild("TIOOFly")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name         = "TIOOFly"
gui.ResetOnSpawn = false
gui.Parent       = guiParent

-- Main Frame
local frame = Instance.new("Frame")
frame.Name             = "Main"
frame.Size             = UDim2.new(0, 185, 0, 0)
frame.Position         = UDim2.new(0.02, 0, 0.28, 0)
frame.BackgroundColor3 = T.BG_DARK
frame.BorderSizePixel  = 0
frame.ClipsDescendants = true
frame.Parent           = gui
corner(frame, 12)
stroke(frame, T.BORDER, 1)

-- Top accent line
local topGlow = Instance.new("Frame")
topGlow.Size             = UDim2.new(0.5, 0, 0, 2)
topGlow.Position         = UDim2.new(0.25, 0, 0, 0)
topGlow.BackgroundColor3 = T.ACCENT
topGlow.BorderSizePixel  = 0
topGlow.ZIndex           = 5
topGlow.Parent           = frame
corner(topGlow, 2)

-- Header
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = T.BG_PANEL
header.BorderSizePixel  = 0
header.Parent           = frame
corner(header, 12)

local hfix = Instance.new("Frame")
hfix.Size             = UDim2.new(1, 0, 0, 8)
hfix.Position         = UDim2.new(0, 0, 1, -8)
hfix.BackgroundColor3 = T.BG_PANEL
hfix.BorderSizePixel  = 0
hfix.Parent           = header

-- Logo
local logoBox = Instance.new("Frame")
logoBox.Size             = UDim2.new(0, 26, 0, 26)
logoBox.Position         = UDim2.new(0, 8, 0.5, -13)
logoBox.BackgroundColor3 = T.ACCENT
logoBox.BorderSizePixel  = 0
logoBox.Parent           = header
corner(logoBox, 7)
local g = Instance.new("UIGradient")
g.Color    = ColorSequence.new(T.ACCENT, T.ACCENT_GLOW)
g.Rotation = 135
g.Parent   = logoBox

local logoTxt = Instance.new("TextLabel")
logoTxt.Size                  = UDim2.new(1, 0, 1, 0)
logoTxt.BackgroundTransparency = 1
logoTxt.Text                  = "T"
logoTxt.TextColor3            = Color3.fromRGB(255, 255, 255)
logoTxt.Font                  = Enum.Font.GothamBold
logoTxt.TextSize              = 13
logoTxt.Parent                = logoBox

local titleLbl = Instance.new("TextLabel")
titleLbl.Size                  = UDim2.new(1, -76, 0, 15)
titleLbl.Position              = UDim2.new(0, 40, 0, 5)
titleLbl.BackgroundTransparency = 1
titleLbl.Text                  = "TIOO Fly"
titleLbl.TextColor3            = T.TEXT_PRIMARY
titleLbl.Font                  = Enum.Font.GothamBold
titleLbl.TextSize              = 12
titleLbl.TextXAlignment        = Enum.TextXAlignment.Left
titleLbl.Parent                = header

local subLbl = Instance.new("TextLabel")
subLbl.Size                  = UDim2.new(1, -76, 0, 11)
subLbl.Position              = UDim2.new(0, 40, 0, 23)
subLbl.BackgroundTransparency = 1
subLbl.Text                  = "by Tiooprime2"
subLbl.TextColor3            = T.TEXT_MUTED
subLbl.Font                  = Enum.Font.Gotham
subLbl.TextSize              = 9
subLbl.TextXAlignment        = Enum.TextXAlignment.Left
subLbl.Parent                = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 22, 0, 22)
closeBtn.Position         = UDim2.new(1, -30, 0.5, -11)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = T.RED
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 11
closeBtn.BorderSizePixel  = 0
closeBtn.Parent           = header
corner(closeBtn, 6)
stroke(closeBtn, T.RED, 1)

makeDraggable(frame, header)

-- Body
local body = Instance.new("Frame")
body.Size                  = UDim2.new(1, -16, 0, 112)
body.Position              = UDim2.new(0, 8, 0, 46)
body.BackgroundTransparency = 1
body.Parent                = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent  = body

-- ── Fly Toggle Card ──────────────────────────────────────
local flyCard = Instance.new("Frame")
flyCard.Size             = UDim2.new(1, 0, 0, 48)
flyCard.BackgroundColor3 = T.BG_CARD
flyCard.BorderSizePixel  = 0
flyCard.Parent           = body
corner(flyCard, 8)
stroke(flyCard, T.BORDER, 1)

-- Emoji + Label
local flyEmoji = Instance.new("TextLabel")
flyEmoji.Size                  = UDim2.new(0, 28, 1, 0)
flyEmoji.Position              = UDim2.new(0, 8, 0, 0)
flyEmoji.BackgroundTransparency = 1
flyEmoji.Text                  = "🪂"
flyEmoji.TextSize              = 18
flyEmoji.Font                  = Enum.Font.GothamBold
flyEmoji.Parent                = flyCard

local flyLabel = Instance.new("TextLabel")
flyLabel.Size                  = UDim2.new(1, -80, 0, 18)
flyLabel.Position              = UDim2.new(0, 40, 0, 6)
flyLabel.BackgroundTransparency = 1
flyLabel.Text                  = "Fly"
flyLabel.TextColor3            = T.TEXT_PRIMARY
flyLabel.Font                  = Enum.Font.GothamSemibold
flyLabel.TextSize              = 13
flyLabel.TextXAlignment        = Enum.TextXAlignment.Left
flyLabel.Parent                = flyCard

local flyDesc = Instance.new("TextLabel")
flyDesc.Size                  = UDim2.new(1, -80, 0, 12)
flyDesc.Position              = UDim2.new(0, 40, 0, 28)
flyDesc.BackgroundTransparency = 1
flyDesc.Text                  = "WASD + Space / Ctrl"
flyDesc.TextColor3            = T.TEXT_MUTED
flyDesc.Font                  = Enum.Font.Gotham
flyDesc.TextSize              = 9
flyDesc.TextXAlignment        = Enum.TextXAlignment.Left
flyDesc.Parent                = flyCard

-- Status badge
local badge = Instance.new("TextLabel")
badge.Size             = UDim2.new(0, 42, 0, 20)
badge.Position         = UDim2.new(1, -50, 0.5, -10)
badge.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
badge.Text             = "OFF"
badge.TextColor3       = T.RED
badge.Font             = Enum.Font.GothamBold
badge.TextSize         = 10
badge.BorderSizePixel  = 0
badge.Parent           = flyCard
corner(badge, 6)
stroke(badge, T.RED, 1)

-- ── Speed Slider Card ────────────────────────────────────
local speedCard = Instance.new("Frame")
speedCard.Size             = UDim2.new(1, 0, 0, 52)
speedCard.BackgroundColor3 = T.BG_CARD
speedCard.BorderSizePixel  = 0
speedCard.Parent           = body
corner(speedCard, 8)
stroke(speedCard, T.BORDER, 1)

local speedName = Instance.new("TextLabel")
speedName.Size                  = UDim2.new(0.55, 0, 0, 16)
speedName.Position              = UDim2.new(0, 10, 0, 6)
speedName.BackgroundTransparency = 1
speedName.Text                  = "Speed"
speedName.TextColor3            = T.TEXT_PRIMARY
speedName.Font                  = Enum.Font.GothamSemibold
speedName.TextSize              = 11
speedName.TextXAlignment        = Enum.TextXAlignment.Left
speedName.Parent                = speedCard

local speedVal = Instance.new("TextLabel")
speedVal.Size                  = UDim2.new(0.45, -10, 0, 16)
speedVal.Position              = UDim2.new(0.55, 0, 0, 6)
speedVal.BackgroundTransparency = 1
speedVal.Text                  = tostring(flySpeed)
speedVal.TextColor3            = T.ACCENT
speedVal.Font                  = Enum.Font.GothamBold
speedVal.TextSize              = 11
speedVal.TextXAlignment        = Enum.TextXAlignment.Right
speedVal.Parent                = speedCard

local track = Instance.new("Frame")
track.Size             = UDim2.new(1, -20, 0, 5)
track.Position         = UDim2.new(0, 10, 0, 34)
track.BackgroundColor3 = T.BG_HOVER
track.BorderSizePixel  = 0
track.Parent           = speedCard
corner(track, 3)

local fill = Instance.new("Frame")
fill.Size             = UDim2.new((flySpeed-1)/499, 0, 1, 0)
fill.BackgroundColor3 = T.ACCENT
fill.BorderSizePixel  = 0
fill.Parent           = track
corner(fill, 3)

local thumb = Instance.new("Frame")
thumb.Size             = UDim2.new(0, 14, 0, 20)
thumb.AnchorPoint      = Vector2.new(0.5, 0.5)
thumb.Position         = UDim2.new((flySpeed-1)/499, 0, 0.5, 0)
thumb.BackgroundColor3 = T.ACCENT
thumb.BorderSizePixel  = 0
thumb.ZIndex           = 3
thumb.Parent           = track
corner(thumb, 4)

-- =========================================================
-- TOGGLE LOGIC
-- =========================================================
local function setFly(state)
    flyEnabled = state
    if state then
        enableFly()
        -- Card hijau
        tw(flyCard, 0.2, {BackgroundColor3 = T.GREEN_BG})
        -- Badge ON hijau
        tw(badge, 0.2, {BackgroundColor3 = Color3.fromRGB(15, 45, 25), TextColor3 = T.GREEN})
        badge.Text = "ON"
        -- Stroke badge ganti hijau
        local bs = badge:FindFirstChildOfClass("UIStroke")
        if bs then tw(bs, 0.2, {Color = T.GREEN}) end
    else
        disableFly()
        tw(flyCard, 0.2, {BackgroundColor3 = T.BG_CARD})
        tw(badge, 0.2, {BackgroundColor3 = Color3.fromRGB(45, 20, 20), TextColor3 = T.RED})
        badge.Text = "OFF"
        local bs = badge:FindFirstChildOfClass("UIStroke")
        if bs then tw(bs, 0.2, {Color = T.RED}) end
    end
end

flyCard.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        setFly(not flyEnabled)
    end
end)

-- =========================================================
-- SLIDER LOGIC
-- =========================================================
local sliding = false

local function updateSlider(posX)
    local rel      = math.clamp((posX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
    flySpeed       = math.floor(1 + rel * 499)
    speedVal.Text  = tostring(flySpeed)
    fill.Size      = UDim2.new(rel, 0, 1, 0)
    thumb.Position = UDim2.new(rel, 0, 0.5, 0)
end

track.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        sliding = true
        updateSlider(i.Position.X)
    end
end)

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
    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then
        updateSlider(i.Position.X)
    end
end)

-- =========================================================
-- OPEN / CLOSE
-- =========================================================
local openBtn = Instance.new("TextButton")
openBtn.Size             = UDim2.new(0, 40, 0, 40)
openBtn.Position         = UDim2.new(0.02, 0, 0.28, 0)
openBtn.BackgroundColor3 = T.BG_DARK
openBtn.Text             = "🪂"
openBtn.TextSize         = 20
openBtn.Font             = Enum.Font.GothamBold
openBtn.Visible          = false
openBtn.BorderSizePixel  = 0
openBtn.Parent           = gui
corner(openBtn, 12)
stroke(openBtn, T.ACCENT, 2)
makeDraggable(openBtn)

closeBtn.MouseButton1Click:Connect(function()
    tw(frame, 0.2, {Size = UDim2.new(0, 185, 0, 0)})
    task.delay(0.2, function()
        frame.Visible   = false
        openBtn.Visible = true
    end)
end)

openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    frame.Size    = UDim2.new(0, 185, 0, 0)
    tw(frame, 0.25, {Size = UDim2.new(0, 185, 0, 172)})
    openBtn.Visible = false
end)

-- Animasi buka pertama kali
tw(frame, 0.3, {Size = UDim2.new(0, 185, 0, 172)})

print("[TIOO] Fly loaded! Speed: " .. flySpeed)
