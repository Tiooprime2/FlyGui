-- =========================================================
-- TIOO Fly Script - Roblox
-- by Tiooprime2 | Style: TIOO Beta V1
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
local bodyVel, bodyGyro

-- =========================================================
-- THEME (sama kayak TIOO Beta V1)
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
    RED          = Color3.fromRGB(255, 70,  70),
    TEXT_PRIMARY = Color3.fromRGB(235, 235, 245),
    TEXT_MUTED   = Color3.fromRGB(130, 130, 160),
    BORDER       = Color3.fromRGB(40,  40,  60),
    PINK         = Color3.fromRGB(255, 119, 204),
}

-- =========================================================
-- UTILS
-- =========================================================
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or T.BORDER
    s.Thickness = thick or 1
    s.Parent = obj
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
            tw(frame, 0.08, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            })
        end
    end)
end

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
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
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
local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
local old = guiParent:FindFirstChild("TIOOFly")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name         = "TIOOFly"
gui.ResetOnSpawn = false
gui.Parent       = guiParent

-- Main Frame (mini 180x170)
local frame = Instance.new("Frame")
frame.Name             = "Main"
frame.Size             = UDim2.new(0, 180, 0, 0)
frame.Position         = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = T.BG_DARK
frame.BorderSizePixel  = 0
frame.ClipsDescendants = true
frame.Parent           = gui
corner(frame, 12)
stroke(frame, T.BORDER, 1)

-- Top accent glow
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
header.Size             = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = T.BG_PANEL
header.BorderSizePixel  = 0
header.Parent           = frame
corner(header, 12)

-- Header bottom fix (nutup rounded bawah header)
local hfix = Instance.new("Frame")
hfix.Size             = UDim2.new(1, 0, 0, 8)
hfix.Position         = UDim2.new(0, 0, 1, -8)
hfix.BackgroundColor3 = T.BG_PANEL
hfix.BorderSizePixel  = 0
hfix.Parent           = header

-- Logo box
local logoBox = Instance.new("Frame")
logoBox.Size             = UDim2.new(0, 24, 0, 24)
logoBox.Position         = UDim2.new(0, 8, 0.5, -12)
logoBox.BackgroundColor3 = T.ACCENT
logoBox.BorderSizePixel  = 0
logoBox.Parent           = header
corner(logoBox, 6)
local g = Instance.new("UIGradient")
g.Color    = ColorSequence.new(T.ACCENT, T.ACCENT_GLOW)
g.Rotation = 135
g.Parent   = logoBox

local logoTxt = Instance.new("TextLabel")
logoTxt.Size                = UDim2.new(1, 0, 1, 0)
logoTxt.BackgroundTransparency = 1
logoTxt.Text                = "T"
logoTxt.TextColor3          = Color3.fromRGB(255,255,255)
logoTxt.Font                = Enum.Font.GothamBold
logoTxt.TextSize            = 13
logoTxt.Parent              = logoBox

-- Title
local titleLbl = Instance.new("TextLabel")
titleLbl.Size                = UDim2.new(1, -70, 0, 14)
titleLbl.Position            = UDim2.new(0, 38, 0, 6)
titleLbl.BackgroundTransparency = 1
titleLbl.Text                = "TIOO Fly"
titleLbl.TextColor3          = T.TEXT_PRIMARY
titleLbl.Font                = Enum.Font.GothamBold
titleLbl.TextSize            = 12
titleLbl.TextXAlignment      = Enum.TextXAlignment.Left
titleLbl.Parent              = header

local subLbl = Instance.new("TextLabel")
subLbl.Size                = UDim2.new(1, -70, 0, 11)
subLbl.Position            = UDim2.new(0, 38, 0, 22)
subLbl.BackgroundTransparency = 1
subLbl.Text                = "by Tiooprime2"
subLbl.TextColor3          = T.TEXT_MUTED
subLbl.Font                = Enum.Font.Gotham
subLbl.TextSize            = 9
subLbl.TextXAlignment      = Enum.TextXAlignment.Left
subLbl.Parent              = header

-- Close button
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
body.Size             = UDim2.new(1, -16, 0, 120)
body.Position         = UDim2.new(0, 8, 0, 44)
body.BackgroundTransparency = 1
body.Parent           = frame

local bodyLayout = Instance.new("UIListLayout")
bodyLayout.Padding        = UDim.new(0, 6)
bodyLayout.Parent         = body

-- ── Toggle Row ────────────────────────────────────────────
local toggleRow = Instance.new("Frame")
toggleRow.Size             = UDim2.new(1, 0, 0, 44)
toggleRow.BackgroundColor3 = T.BG_CARD
toggleRow.BorderSizePixel  = 0
toggleRow.Parent           = body
corner(toggleRow, 8)
stroke(toggleRow, T.BORDER, 1)

local toggleName = Instance.new("TextLabel")
toggleName.Size             = UDim2.new(1, -60, 0, 16)
toggleName.Position         = UDim2.new(0, 10, 0, 6)
toggleName.BackgroundTransparency = 1
toggleName.Text             = "Fly"
toggleName.TextColor3       = T.TEXT_PRIMARY
toggleName.Font             = Enum.Font.GothamSemibold
toggleName.TextSize         = 12
toggleName.TextXAlignment   = Enum.TextXAlignment.Left
toggleName.Parent           = toggleRow

local toggleDesc = Instance.new("TextLabel")
toggleDesc.Size             = UDim2.new(1, -60, 0, 12)
toggleDesc.Position         = UDim2.new(0, 10, 0, 26)
toggleDesc.BackgroundTransparency = 1
toggleDesc.Text             = "WASD + Space / Ctrl"
toggleDesc.TextColor3       = T.TEXT_MUTED
toggleDesc.Font             = Enum.Font.Gotham
toggleDesc.TextSize         = 9
toggleDesc.TextXAlignment   = Enum.TextXAlignment.Left
toggleDesc.Parent           = toggleRow

-- Switch
local switch = Instance.new("Frame")
switch.Size             = UDim2.new(0, 40, 0, 22)
switch.Position         = UDim2.new(1, -50, 0.5, -11)
switch.BackgroundColor3 = T.BG_HOVER
switch.BorderSizePixel  = 0
switch.Parent           = toggleRow
corner(switch, 11)

local knob = Instance.new("Frame")
knob.Size             = UDim2.new(0, 16, 0, 16)
knob.Position         = UDim2.new(0, 3, 0.5, -8)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel  = 0
knob.Parent           = switch
corner(knob, 8)

-- ── Slider Row ────────────────────────────────────────────
local sliderRow = Instance.new("Frame")
sliderRow.Size             = UDim2.new(1, 0, 0, 52)
sliderRow.BackgroundColor3 = T.BG_CARD
sliderRow.BorderSizePixel  = 0
sliderRow.Parent           = body
corner(sliderRow, 8)
stroke(sliderRow, T.BORDER, 1)

local sliderName = Instance.new("TextLabel")
sliderName.Size             = UDim2.new(0.6, 0, 0, 14)
sliderName.Position         = UDim2.new(0, 10, 0, 6)
sliderName.BackgroundTransparency = 1
sliderName.Text             = "Speed"
sliderName.TextColor3       = T.TEXT_PRIMARY
sliderName.Font             = Enum.Font.GothamSemibold
sliderName.TextSize         = 11
sliderName.TextXAlignment   = Enum.TextXAlignment.Left
sliderName.Parent           = sliderRow

local speedVal = Instance.new("TextLabel")
speedVal.Size             = UDim2.new(0.4, -10, 0, 14)
speedVal.Position         = UDim2.new(0.6, 0, 0, 6)
speedVal.BackgroundTransparency = 1
speedVal.Text             = tostring(flySpeed)
speedVal.TextColor3       = T.ACCENT
speedVal.Font             = Enum.Font.GothamBold
speedVal.TextSize         = 11
speedVal.TextXAlignment   = Enum.TextXAlignment.Right
speedVal.Parent           = sliderRow

-- Track
local track = Instance.new("Frame")
track.Size             = UDim2.new(1, -20, 0, 4)
track.Position         = UDim2.new(0, 10, 0, 32)
track.BackgroundColor3 = T.BG_HOVER
track.BorderSizePixel  = 0
track.Parent           = sliderRow
corner(track, 2)

local fill = Instance.new("Frame")
fill.Size             = UDim2.new((flySpeed-1)/499, 0, 1, 0)
fill.BackgroundColor3 = T.ACCENT
fill.BorderSizePixel  = 0
fill.Parent           = track
corner(fill, 2)

local thumb = Instance.new("Frame")
thumb.Size             = UDim2.new(0, 12, 0, 18)
thumb.AnchorPoint      = Vector2.new(0.5, 0.5)
thumb.Position         = UDim2.new((flySpeed-1)/499, 0, 0.5, 0)
thumb.BackgroundColor3 = T.ACCENT
thumb.BorderSizePixel  = 0
thumb.ZIndex           = 3
thumb.Parent           = track
corner(thumb, 4)
stroke(thumb, T.ACCENT_GLOW, 1)

-- =========================================================
-- TOGGLE LOGIC
-- =========================================================
local function setFly(state)
    flyEnabled = state
    if state then
        enableFly()
        tw(switch, 0.2, {BackgroundColor3 = T.GREEN})
        tw(knob,   0.2, {Position = UDim2.new(1, -19, 0.5, -8)})
        tw(toggleRow, 0.2, {BackgroundColor3 = Color3.fromRGB(15, 35, 20)})
    else
        disableFly()
        tw(switch, 0.2, {BackgroundColor3 = T.BG_HOVER})
        tw(knob,   0.2, {Position = UDim2.new(0, 3, 0.5, -8)})
        tw(toggleRow, 0.2, {BackgroundColor3 = T.BG_CARD})
    end
end

toggleRow.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        setFly(not flyEnabled)
    end
end)

-- =========================================================
-- SLIDER LOGIC (touch friendly)
-- =========================================================
local sliding = false

local function updateSlider(posX)
    local rel = math.clamp(
        (posX - track.AbsolutePosition.X) / track.AbsoluteSize.X,
        0, 1
    )
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
local isOpen = true

-- Mini open button
local openBtn = Instance.new("TextButton")
openBtn.Size             = UDim2.new(0, 40, 0, 40)
openBtn.Position         = UDim2.new(0.02, 0, 0.3, 0)
openBtn.BackgroundColor3 = T.BG_DARK
openBtn.Text             = "T"
openBtn.TextColor3       = T.ACCENT
openBtn.Font             = Enum.Font.GothamBold
openBtn.TextSize         = 18
openBtn.Visible          = false
openBtn.BorderSizePixel  = 0
openBtn.Parent           = gui
corner(openBtn, 12)
stroke(openBtn, T.ACCENT, 2)
makeDraggable(openBtn)

closeBtn.MouseButton1Click:Connect(function()
    isOpen = false
    tw(frame, 0.2, {Size = UDim2.new(0, 180, 0, 0)})
    task.delay(0.2, function()
        frame.Visible  = false
        openBtn.Visible = true
    end)
end)

openBtn.MouseButton1Click:Connect(function()
    isOpen = true
    frame.Visible = true
    frame.Size    = UDim2.new(0, 180, 0, 0)
    tw(frame, 0.25, {Size = UDim2.new(0, 180, 0, 170)})
    openBtn.Visible = false
end)

-- Animasi buka pertama kali
tw(frame, 0.3, {Size = UDim2.new(0, 180, 0, 170)})

print("[TIOO] Fly loaded! Speed: " .. flySpeed)
