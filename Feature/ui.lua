-- =========================================================
-- TIOO Fly - GUI (Sidebar Style)
-- by Tiooprime2
-- Compatible dengan fly.lua + main.lua
-- =========================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UI = {}

-- =========================================================
-- THEME
-- =========================================================
local T = {
    BG_DARK      = Color3.fromRGB(8,   8,  12),
    BG_PANEL     = Color3.fromRGB(14,  14, 20),
    BG_CARD      = Color3.fromRGB(20,  20, 30),
    BG_HOVER     = Color3.fromRGB(28,  28, 42),
    BG_ACTIVE    = Color3.fromRGB(35,  55, 85),
    BG_CARD_ON   = Color3.fromRGB(15,  35, 20),
    ACCENT       = Color3.fromRGB(80,  140, 255),
    ACCENT_GLOW  = Color3.fromRGB(60,  100, 220),
    GREEN        = Color3.fromRGB(50,  210, 120),
    RED          = Color3.fromRGB(255, 70,  70),
    TEXT_PRIMARY = Color3.fromRGB(235, 235, 245),
    TEXT_MUTED   = Color3.fromRGB(130, 130, 160),
    BORDER       = Color3.fromRGB(40,  40,  60),
    SIDEBAR      = Color3.fromRGB(11,  11,  17),
}

-- =========================================================
-- UTILS
-- =========================================================
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

local function stroke(obj, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color        = color or T.BORDER
    s.Thickness    = thick or 1
    s.Transparency = trans or 0
    s.Parent       = obj
end

local function tw(obj, t, props)
    TweenService:Create(obj,
        TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props):Play()
end

-- =========================================================
-- DRAGGABLE — fix mobile: pakai threshold biar gak ke-trigger
-- =========================================================
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragStart, startPos
    local dragging   = false
    local THRESHOLD  = 12  -- pixel, geser > 12px baru dianggap drag

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = false
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging  = false
                    dragStart = nil
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragStart then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if not dragging and (math.abs(d.X) > THRESHOLD or math.abs(d.Y) > THRESHOLD) then
                dragging = true
            end
            if dragging then
                tw(frame, 0.06, {
                    Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + d.X,
                        startPos.Y.Scale, startPos.Y.Offset + d.Y
                    )
                })
            end
        end
    end)

    -- Expose isDragging supaya tombol bisa cek sebelum trigger
    return function() return dragging end
end

-- =========================================================
-- TOGGLE BUILDER (switch style)
-- =========================================================
local function createToggle(page, name, desc, defaultState, callback)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = T.BG_CARD
    row.BorderSizePixel  = 0
    row.Parent           = page
    corner(row, 8)
    stroke(row, T.BORDER, 1, 0.5)

    local nameL = Instance.new("TextLabel")
    nameL.Size                  = UDim2.new(1, -70, 0, 20)
    nameL.Position              = UDim2.new(0, 12, 0, 8)
    nameL.BackgroundTransparency = 1
    nameL.Text                  = name
    nameL.TextColor3            = T.TEXT_PRIMARY
    nameL.Font                  = Enum.Font.GothamSemibold
    nameL.TextSize              = 12
    nameL.TextXAlignment        = Enum.TextXAlignment.Left
    nameL.Parent                = row

    local descL = Instance.new("TextLabel")
    descL.Size                  = UDim2.new(1, -70, 0, 16)
    descL.Position              = UDim2.new(0, 12, 0, 30)
    descL.BackgroundTransparency = 1
    descL.Text                  = desc or ""
    descL.TextColor3            = T.TEXT_MUTED
    descL.Font                  = Enum.Font.Gotham
    descL.TextSize              = 10
    descL.TextXAlignment        = Enum.TextXAlignment.Left
    descL.Parent                = row

    -- Switch background
    local switch = Instance.new("Frame")
    switch.Size             = UDim2.new(0, 44, 0, 24)
    switch.Position         = UDim2.new(1, -56, 0.5, -12)
    switch.BackgroundColor3 = defaultState and T.GREEN or T.BG_HOVER
    switch.BorderSizePixel  = 0
    switch.Parent           = row
    corner(switch, 12)

    -- Knob
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 18, 0, 18)
    knob.Position         = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    knob.Parent           = switch
    corner(knob, 9)

    local state = defaultState or false

    local function doToggle()
        state = not state
        if state then
            tw(switch, 0.2, {BackgroundColor3 = T.GREEN})
            tw(knob,   0.2, {Position = UDim2.new(1, -21, 0.5, -9)})
            tw(row,    0.2, {BackgroundColor3 = T.BG_CARD_ON})
        else
            tw(switch, 0.2, {BackgroundColor3 = T.BG_HOVER})
            tw(knob,   0.2, {Position = UDim2.new(0, 3, 0.5, -9)})
            tw(row,    0.2, {BackgroundColor3 = T.BG_CARD})
        end
        if callback then callback(state) end
    end

    -- TAP DETECTION — fix mobile: toggle hanya kalau tidak geser
    local TAP_THRESHOLD = 10
    local tapStart = nil

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            tapStart = input.Position
        end
    end)
    row.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) and tapStart then
            local dist = (Vector2.new(input.Position.X, input.Position.Y)
                        - Vector2.new(tapStart.X, tapStart.Y)).Magnitude
            if dist < TAP_THRESHOLD then
                doToggle()
            end
            tapStart = nil
        end
    end)

    return {
        getState  = function() return state end,
        setState  = function(s) if state ~= s then doToggle() end end,
        descLabel = descL,
    }
end

-- Section header
local function createSection(page, title)
    local sec = Instance.new("TextLabel")
    sec.Size                  = UDim2.new(1, 0, 0, 22)
    sec.BackgroundTransparency = 1
    sec.Text                  = "  " .. title:upper()
    sec.TextColor3            = T.ACCENT
    sec.Font                  = Enum.Font.GothamBold
    sec.TextSize              = 10
    sec.TextXAlignment        = Enum.TextXAlignment.Left
    sec.Parent                = page
end

-- =========================================================
-- INIT
-- =========================================================
function UI.init(Fly)
    local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
    local old = guiParent:FindFirstChild("TIOOFly")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name           = "TIOOFly"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent         = guiParent

    -- ── Main Frame ───────────────────────────────────────
    local frame = Instance.new("Frame")
    frame.Name             = "Main"
    frame.Size             = UDim2.new(0, 320, 0, 0)
    frame.Position         = UDim2.new(0.5, -160, 0.5, -150)
    frame.BackgroundColor3 = T.BG_DARK
    frame.BorderSizePixel  = 0
    frame.ClipsDescendants = false
    frame.Parent           = gui
    corner(frame, 14)
    stroke(frame, T.BORDER, 1, 0)

    -- Top accent line
    local topGlow = Instance.new("Frame")
    topGlow.Size             = UDim2.new(0.5, 0, 0, 2)
    topGlow.Position         = UDim2.new(0.25, 0, 0, 0)
    topGlow.BackgroundColor3 = T.ACCENT
    topGlow.BorderSizePixel  = 0
    topGlow.Parent           = frame
    corner(topGlow, 2)

    -- ── Header ───────────────────────────────────────────
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
    logoBox.Position         = UDim2.new(0, 12, 0.5, -15)
    logoBox.BackgroundColor3 = T.ACCENT
    logoBox.BorderSizePixel  = 0
    logoBox.Parent           = header
    corner(logoBox, 8)
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new(T.ACCENT, T.ACCENT_GLOW)
    g.Rotation = 135
    g.Parent   = logoBox

    local lt = Instance.new("TextLabel", logoBox)
    lt.Size                  = UDim2.new(1, 0, 1, 0)
    lt.BackgroundTransparency = 1
    lt.Text                  = "T"
    lt.TextColor3            = Color3.fromRGB(255, 255, 255)
    lt.Font                  = Enum.Font.GothamBold
    lt.TextSize              = 16

    local titleMain = Instance.new("TextLabel")
    titleMain.Size                  = UDim2.new(1, -160, 0, 18)
    titleMain.Position              = UDim2.new(0, 50, 0, 7)
    titleMain.BackgroundTransparency = 1
    titleMain.Text                  = "TIOO FLY"
    titleMain.TextColor3            = T.TEXT_PRIMARY
    titleMain.Font                  = Enum.Font.GothamBold
    titleMain.TextSize              = 13
    titleMain.TextXAlignment        = Enum.TextXAlignment.Left
    titleMain.Parent                = header

    local titleSub = Instance.new("TextLabel")
    titleSub.Size                  = UDim2.new(1, -160, 0, 14)
    titleSub.Position              = UDim2.new(0, 50, 0, 27)
    titleSub.BackgroundTransparency = 1
    titleSub.Text                  = "Ninja Legends  •  by Tiooprime2"
    titleSub.TextColor3            = T.TEXT_MUTED
    titleSub.Font                  = Enum.Font.Gotham
    titleSub.TextSize              = 10
    titleSub.TextXAlignment        = Enum.TextXAlignment.Left
    titleSub.Parent                = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size             = UDim2.new(0, 28, 0, 28)
    closeBtn.Position         = UDim2.new(1, -40, 0.5, -14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
    closeBtn.Text             = "✕"
    closeBtn.TextColor3       = T.RED
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.TextSize         = 13
    closeBtn.BorderSizePixel  = 0
    closeBtn.Parent           = header
    corner(closeBtn, 8)
    stroke(closeBtn, T.RED, 1, 0.6)

    makeDraggable(frame, header)

    -- ── Body ─────────────────────────────────────────────
    local body = Instance.new("Frame")
    body.Size                  = UDim2.new(1, -16, 1, -54)
    body.Position              = UDim2.new(0, 8, 0, 50)
    body.BackgroundTransparency = 1
    body.Parent                = frame

    -- ── Sidebar kiri ─────────────────────────────────────
    local sidebar = Instance.new("Frame")
    sidebar.Size             = UDim2.new(0, 80, 1, 0)
    sidebar.BackgroundColor3 = T.SIDEBAR
    sidebar.BorderSizePixel  = 0
    sidebar.Parent           = body
    corner(sidebar, 10)
    stroke(sidebar, T.BORDER, 1, 0.5)

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 4)
    sideLayout.Parent  = sidebar

    local sidePad = Instance.new("UIPadding")
    sidePad.PaddingTop    = UDim.new(0, 8)
    sidePad.PaddingBottom = UDim.new(0, 8)
    sidePad.PaddingLeft   = UDim.new(0, 6)
    sidePad.PaddingRight  = UDim.new(0, 6)
    sidePad.Parent        = sidebar

    -- ── Content panel kanan ──────────────────────────────
    local contentPanel = Instance.new("Frame")
    contentPanel.Size             = UDim2.new(1, -88, 1, 0)
    contentPanel.Position         = UDim2.new(0, 88, 0, 0)
    contentPanel.BackgroundColor3 = T.BG_PANEL
    contentPanel.BorderSizePixel  = 0
    contentPanel.ClipsDescendants = true
    contentPanel.Parent           = body
    corner(contentPanel, 10)
    stroke(contentPanel, T.BORDER, 1, 0.5)

    local pageTitle = Instance.new("TextLabel")
    pageTitle.Size                  = UDim2.new(1, -16, 0, 32)
    pageTitle.Position              = UDim2.new(0, 12, 0, 6)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text                  = "🏠  Main"
    pageTitle.TextColor3            = T.TEXT_PRIMARY
    pageTitle.Font                  = Enum.Font.GothamBold
    pageTitle.TextSize              = 13
    pageTitle.TextXAlignment        = Enum.TextXAlignment.Left
    pageTitle.Parent                = contentPanel

    local divider = Instance.new("Frame")
    divider.Size             = UDim2.new(1, -16, 0, 1)
    divider.Position         = UDim2.new(0, 8, 0, 38)
    divider.BackgroundColor3 = T.BORDER
    divider.BorderSizePixel  = 0
    divider.Parent           = contentPanel

    -- ── Pages system ─────────────────────────────────────
    local pages    = {}
    local activeTab = nil

    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Size                 = UDim2.new(1, -8, 1, -48)
        page.Position             = UDim2.new(0, 4, 0, 44)
        page.BackgroundTransparency = 1
        page.BorderSizePixel      = 0
        page.ScrollBarThickness   = 3
        page.ScrollBarImageColor3 = T.ACCENT
        page.CanvasSize           = UDim2.new(0, 0, 0, 0)
        page.Visible              = false
        page.Parent               = contentPanel

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.Parent  = page

        local pad = Instance.new("UIPadding")
        pad.PaddingTop   = UDim.new(0, 4)
        pad.PaddingLeft  = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 8)
        pad.Parent       = page

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        pages[name] = page
        return page
    end

    local function switchTab(name, tabBtn, icon)
        for _, p in pairs(pages) do p.Visible = false end
        if pages[name] then pages[name].Visible = true end
        pageTitle.Text = icon .. "  " .. name
        for _, child in pairs(sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundTransparency = 1
                local lbl = child:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.TextColor3 = T.TEXT_MUTED end
            end
        end
        if tabBtn then
            tabBtn.BackgroundTransparency = 0
            tw(tabBtn, 0.15, {BackgroundColor3 = T.BG_ACTIVE})
            local lbl = tabBtn:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.TextColor3 = T.TEXT_PRIMARY end
        end
        activeTab = name
    end

    local function createTab(icon, name)
        createPage(name)

        local btn = Instance.new("TextButton")
        btn.Size                 = UDim2.new(1, 0, 0, 36)
        btn.BackgroundTransparency = 1
        btn.BackgroundColor3     = T.BG_ACTIVE
        btn.Text                 = ""
        btn.BorderSizePixel      = 0
        btn.Parent               = sidebar
        corner(btn, 8)

        local iconLbl = Instance.new("TextLabel")
        iconLbl.Size                  = UDim2.new(0, 22, 1, 0)
        iconLbl.Position              = UDim2.new(0, 4, 0, 0)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Text                  = icon
        iconLbl.TextSize              = 15
        iconLbl.Font                  = Enum.Font.GothamBold
        iconLbl.Parent                = btn

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size                  = UDim2.new(1, -30, 1, 0)
        nameLbl.Position              = UDim2.new(0, 28, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text                  = name
        nameLbl.TextColor3            = T.TEXT_MUTED
        nameLbl.Font                  = Enum.Font.GothamSemibold
        nameLbl.TextSize              = 11
        nameLbl.TextXAlignment        = Enum.TextXAlignment.Left
        nameLbl.Parent                = btn

        btn.MouseButton1Click:Connect(function()
            switchTab(name, btn, icon)
        end)

        return btn, pages[name]
    end

    -- ── Buat tabs ─────────────────────────────────────────
    local mainTabBtn, mainPage = createTab("🏠", "Main")
    createTab("⚙️", "Settings")

    -- Default ke Main
    switchTab("Main", mainTabBtn, "🏠")

    -- ── Isi Main page: Fly toggle ─────────────────────────
    createSection(mainPage, "Movement")

    local flyToggle = createToggle(
        mainPage,
        "Fly",
        "Joystick / WASD + kamera",
        false,
        function(state)
            Fly.enabled = state
            if state then
                Fly.enable()
            else
                Fly.disable()
            end
        end
    )

    -- ── Open Button (minimized) ───────────────────────────
    local openBtn = Instance.new("TextButton")
    openBtn.Size             = UDim2.new(0, 46, 0, 46)
    openBtn.Position         = UDim2.new(0.02, 0, 0.45, 0)
    openBtn.BackgroundColor3 = T.BG_DARK
    openBtn.Text             = "T"
    openBtn.TextColor3       = T.ACCENT
    openBtn.Font             = Enum.Font.GothamBold
    openBtn.TextSize         = 22
    openBtn.Visible          = false
    openBtn.BorderSizePixel  = 0
    openBtn.Parent           = gui
    corner(openBtn, 14)
    stroke(openBtn, T.ACCENT, 2, 0.3)
    makeDraggable(openBtn)

    local FULL_H = 260

    -- ── Open / Close ─────────────────────────────────────
    closeBtn.MouseButton1Click:Connect(function()
        tw(frame, 0.2, {Size = UDim2.new(0, 320, 0, 0)})
        task.delay(0.2, function()
            frame.Visible   = false
            openBtn.Visible = true
        end)
    end)

    openBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        frame.Size    = UDim2.new(0, 320, 0, 0)
        tw(frame, 0.25, {Size = UDim2.new(0, 320, 0, FULL_H)})
        openBtn.Visible = false
    end)

    -- Animasi buka pertama kali
    tw(frame, 0.3, {Size = UDim2.new(0, 320, 0, FULL_H)})

    print("[TIOO] ui.lua loaded! (Sidebar style)")
end

return UI
