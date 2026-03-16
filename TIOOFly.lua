-- =========================================================
-- TIOO Fly Script - Roblox | Ninja Legends
-- by Tiooprime2
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
local flyConn    = nil

-- =========================================================
-- THEME
-- =========================================================
local T = {
    BG_DARK      = Color3.fromRGB(8,   8,  12),
    BG_PANEL     = Color3.fromRGB(14,  14, 20),
    BG_CARD      = Color3.fromRGB(20,  20, 30),
    BG_CARD_ON   = Color3.fromRGB(18,  42, 24),
    BG_HOVER     = Color3.fromRGB(28,  28, 42),
    ACCENT       = Color3.fromRGB(80,  140, 255),
    ACCENT_GLOW  = Color3.fromRGB(60,  100, 220),
    GREEN        = Color3.fromRGB(50,  210, 120),
    GREEN_PILL   = Color3.fromRGB(40,  180, 100),
    RED          = Color3.fromRGB(255, 70,  70),
    GRAY_PILL    = Color3.fromRGB(45,  45,  60),
    TEXT_PRIMARY = Color3.fromRGB(235, 235, 245),
    TEXT_MUTED   = Color3.fromRGB(130, 130, 160),
    TEXT_ON      = Color3.fromRGB(120, 230, 160),
    BORDER       = Color3.fromRGB(40,  40,  60),
    LEFT_BAR     = Color3.fromRGB(60,  60,  80),
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
-- FLY LOGIC
-- =========================================================
local function enableFly()
    if flyConn then flyConn:Disconnect() end
    hum.PlatformStand = true

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled then return end
        local spd = flySpeed
        local moveDir = hum.MoveDirection
        local cam = workspace.CurrentCamera

        local dir =
            cam.CFrame.RightVector * moveDir.X +
            cam.CFrame.LookVector  * moveDir.Z

        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end

        if dir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + dir.Unit * spd * dt
        end

        -- Freeze physics
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function disableFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    hum.PlatformStand = false
end

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

-- Main Frame
local frame = Instance.new("Frame")
frame.Name             = "Main"
frame.Size             = UDim2.new(0, 220, 0, 0)
frame.Position         = UDim2.new(0.02, 0, 0.28, 0)
frame.BackgroundColor3 = T.BG_DARK
frame.BorderSizePixel  = 0
frame.ClipsDescendants = true
frame.Parent           = gui
corner(frame, 14)
stroke(frame, T.BORDER, 1)

-- Top accent line
local topGlow = Instance.new("Frame")
topGlow.Size             = UDim2.new(0.45, 0, 0, 2)
topGlow.Position         = UDim2.new(0.275, 0, 0, 0)
topGlow.BackgroundColor3 = T.ACCENT
topGlow.BorderSizePixel  = 0
topGlow.ZIndex           = 5
topGlow.Parent           = frame
corner(topGlow, 2)

-- Header
local header = Instance.new("Frame")
header.Size             = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = T.BG_PANEL
header.BorderSizePixel  = 0
header.Parent           = frame
corner(header, 14)

local hfix = Instance.new("Frame")
hfix.Size             = UDim2.new(1, 0, 0, 10)
hfix.Position         = UDim2.new(0, 0, 1, -10)
hfix.BackgroundColor3 = T.BG_PANEL
hfix.BorderSizePixel  = 0
hfix.Parent           = header

-- Logo
local logoBox = Instance.new("Frame")
logoBox.Size             = UDim2.new(0, 30, 0, 30)
logoBox.Position         = UDim2.new(0, 10, 0.5, -15)
logoBox.BackgroundColor3 = T.ACCENT
logoBox.BorderSizePixel  = 0
logoBox.Parent           = header
corner(logoBox, 8)
local g = Instance.new("UIGradient")
g.Color    = ColorSequence.new(T.ACCENT, T.ACCENT_GLOW)
g.Rotation = 135
g.Parent   = logoBox

Instance.new("TextLabel", logoBox).Size = UDim2.new(1,0,1,0)
local lt = logoBox:FindFirstChildOfClass("TextLabel")
lt.BackgroundTransparency = 1
lt.Text      = "T"
lt.TextColor3 = Color3.fromRGB(255,255,255)
lt.Font      = Enum.Font.GothamBold
lt.TextSize  = 15

local titleLbl = Instance.new("TextLabel")
titleLbl.Size                  = UDim2.new(1, -90, 0, 16)
titleLbl.Position              = UDim2.new(0, 48, 0, 6)
titleLbl.BackgroundTransparency = 1
titleLbl.Text                  = "TIOO FLY"
titleLbl.TextColor3            = T.TEXT_PRIMARY
titleLbl.Font                  = Enum.Font.GothamBold
titleLbl.TextSize              = 13
titleLbl.TextXAlignment        = Enum.TextXAlignment.Left
titleLbl.Parent                = header

local subLbl = Instance.new("TextLabel")
subLbl.Size                  = UDim2.new(1, -90, 0, 12)
subLbl.Position              = UDim2.new(0, 48, 0, 25)
subLbl.BackgroundTransparency = 1
subLbl.Text                  = "Ninja Legends  •  by Tiooprime2"
subLbl.TextColor3            = T.TEXT_MUTED
subLbl.Font                  = Enum.Font.Gotham
subLbl.TextSize              = 9
subLbl.TextXAlignment        = Enum.TextXAlignment.Left
subLbl.Parent                = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 26, 0, 26)
closeBtn.Position         = UDim2.new(1, -36, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = T.RED
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 12
closeBtn.BorderSizePixel  = 0
closeBtn.Parent           = header
corner(closeBtn, 8)
stroke(closeBtn, T.RED, 1)

makeDraggable(frame, header)

-- Body
local body = Instance.new("Frame")
body.Size                  = UDim2.new(1, -16, 0, 130)
body.Position              = UDim2.new(0, 8, 0, 50)
body.BackgroundTransparency = 1
body.Parent                = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent  = body

-- =========================================================
-- CARD BUILDER (style kayak screenshot)
-- =========================================================
local function createCard(parent, emoji, name, desc)
    -- Outer card
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = T.BG_CARD
    card.BorderSizePixel  = 0
    card.Parent           = parent
    corner(card, 10)
    stroke(card, T.BORDER, 1)

    -- Left accent bar (abu default, hijau kalau ON)
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 0.7, 0)
    bar.Position         = UDim2.new(0, 0, 0.15, 0)
    bar.BackgroundColor3 = T.LEFT_BAR
    bar.BorderSizePixel  = 0
    bar.Parent           = card
    corner(bar, 2)

    -- Emoji
    local emojiLbl = Instance.new("TextLabel")
    emojiLbl.Size                  = UDim2.new(0, 30, 1, 0)
    emojiLbl.Position              = UDim2.new(0, 10, 0, 0)
    emojiLbl.BackgroundTransparency = 1
    emojiLbl.Text                  = emoji
    emojiLbl.TextSize              = 18
    emojiLbl.Font                  = Enum.Font.GothamBold
    emojiLbl.Parent                = card

    -- Name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size                  = UDim2.new(1, -110, 0, 20)
    nameLbl.Position              = UDim2.new(0, 44, 0, 8)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text                  = name
    nameLbl.TextColor3            = T.TEXT_PRIMARY
    nameLbl.Font                  = Enum.Font.GothamSemibold
    nameLbl.TextSize              = 13
    nameLbl.TextXAlignment        = Enum.TextXAlignment.Left
    nameLbl.Parent                = card

    -- Desc
    local descLbl = Instance.new("TextLabel")
    descLbl.Size                  = UDim2.new(1, -110, 0, 14)
    descLbl.Position              = UDim2.new(0, 44, 0, 32)
    descLbl.BackgroundTransparency = 1
    descLbl.Text                  = desc
    descLbl.TextColor3            = T.TEXT_MUTED
    descLbl.Font                  = Enum.Font.Gotham
    descLbl.TextSize              = 10
    descLbl.TextXAlignment        = Enum.TextXAlignment.Left
    descLbl.Parent                = card

    -- Pill button (OFF/ON)
    local pill = Instance.new("TextButton")
    pill.Size             = UDim2.new(0, 52, 0, 26)
    pill.Position         = UDim2.new(1, -62, 0.5, -13)
    pill.BackgroundColor3 = T.GRAY_PILL
    pill.Text             = "OFF"
    pill.TextColor3       = T.TEXT_MUTED
    pill.Font             = Enum.Font.GothamBold
    pill.TextSize         = 11
    pill.BorderSizePixel  = 0
    pill.Parent           = card
    corner(pill, 13)

    return card, pill, bar, descLbl
end

-- ── Fly Card ─────────────────────────────────────────────
local flyCard, flyPill, flyBar, flyDesc = createCard(body, "🪂", "Fly", "WASD + Space / Ctrl")

-- ── Speed Card ───────────────────────────────────────────
local speedCard = Instance.new("Frame")
speedCard.Size             = UDim2.new(1, 0, 0, 60)
speedCard.BackgroundColor3 = T.BG_CARD
speedCard.BorderSizePixel  = 0
speedCard.Parent           = body
corner(speedCard, 10)
stroke(speedCard, T.BORDER, 1)

local speedBar = Instance.new("Frame")
speedBar.Size             = UDim2.new(0, 3, 0.7, 0)
speedBar.Position         = UDim2.new(0, 0, 0.15, 0)
speedBar.BackgroundColor3 = T.ACCENT
speedBar.BorderSizePixel  = 0
speedBar.Parent           = speedCard
corner(speedBar, 2)

local speedName = Instance.new("TextLabel")
speedName.Size                  = UDim2.new(0.55, 0, 0, 18)
speedName.Position              = UDim2.new(0, 14, 0, 6)
speedName.BackgroundTransparency = 1
speedName.Text                  = "Speed"
speedName.TextColor3            = T.TEXT_PRIMARY
speedName.Font                  = Enum.Font.GothamSemibold
speedName.TextSize              = 12
speedName.TextXAlignment        = Enum.TextXAlignment.Left
speedName.Parent                = speedCard

local speedVal = Instance.new("TextLabel")
speedVal.Size                  = UDim2.new(0.4, -10, 0, 18)
speedVal.Position              = UDim2.new(0.55, 0, 0, 6)
speedVal.BackgroundTransparency = 1
speedVal.Text                  = tostring(flySpeed)
speedVal.TextColor3            = T.ACCENT
speedVal.Font                  = Enum.Font.GothamBold
speedVal.TextSize              = 12
speedVal.TextXAlignment        = Enum.TextXAlignment.Right
speedVal.Parent                = speedCard

local track = Instance.new("Frame")
track.Size             = UDim2.new(1, -24, 0, 5)
track.Position         = UDim2.new(0, 12, 0, 38)
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
        tw(flyCard, 0.2, {BackgroundColor3 = T.BG_CARD_ON})
        tw(flyBar,  0.2, {BackgroundColor3 = T.GREEN})
        tw(flyPill, 0.2, {BackgroundColor3 = T.GREEN_PILL, TextColor3 = Color3.fromRGB(255,255,255)})
        flyPill.Text  = "ON"
        flyDesc.TextColor3 = T.TEXT_ON
        flyDesc.Text  = "Flying active!"
    else
        disableFly()
        tw(flyCard, 0.2, {BackgroundColor3 = T.BG_CARD})
        tw(flyBar,  0.2, {BackgroundColor3 = T.LEFT_BAR})
        tw(flyPill, 0.2, {BackgroundColor3 = T.GRAY_PILL, TextColor3 = T.TEXT_MUTED})
        flyPill.Text  = "OFF"
        flyDesc.TextColor3 = T.TEXT_MUTED
        flyDesc.Text  = "WASD + Space / Ctrl"
    end
end

-- Klik card atau pill = toggle
flyCard.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        setFly(not flyEnabled)
    end
end)
flyPill.MouseButton1Click:Connect(function()
    setFly(not flyEnabled)
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
openBtn.Size             = UDim2.new(0, 44, 0, 44)
openBtn.Position         = UDim2.new(0.02, 0, 0.28, 0)
openBtn.BackgroundColor3 = T.BG_DARK
openBtn.Text             = "🪂"
openBtn.TextSize         = 22
openBtn.Font             = Enum.Font.GothamBold
openBtn.Visible          = false
openBtn.BorderSizePixel  = 0
openBtn.Parent           = gui
corner(openBtn, 14)
stroke(openBtn, T.ACCENT, 2)
makeDraggable(openBtn)

local FULL_H = 196

closeBtn.MouseButton1Click:Connect(function()
    tw(frame, 0.2, {Size = UDim2.new(0, 220, 0, 0)})
    task.delay(0.2, function()
        frame.Visible   = false
        openBtn.Visible = true
    end)
end)
openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    frame.Size    = UDim2.new(0, 220, 0, 0)
    tw(frame, 0.25, {Size = UDim2.new(0, 220, 0, FULL_H)})
    openBtn.Visible = false
end)

-- Animasi buka pertama kali
tw(frame, 0.3, {Size = UDim2.new(0, 220, 0, FULL_H)})

print("[TIOO] Fly loaded!")
