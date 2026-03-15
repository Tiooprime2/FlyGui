-- =========================================================
-- TIOO Fly Script
-- by Tiooprime2
-- =========================================================

local flyEnabled = false
local flySpeed   = 10
local dragging   = false
local dragOffX   = 0
local dragOffY   = 0

-- GUI position
local guiX = 20
local guiY = 80

-- GUI size
local W  = 160
local H  = 110

-- Colors (ARGB)
local C_BG       = 0xE0000000  -- hitam transparan
local C_HEADER   = 0xFF141414  -- header gelap
local C_GREEN    = 0xFF55FF55  -- hijau aktif
local C_RED      = 0xFFFF5555  -- merah nonaktif
local C_WHITE    = 0xFFFFFFFF
local C_GRAY     = 0xFFAAAAAA
local C_PINK     = 0xFFFF77CC  -- slider handle
local C_TRACK    = 0xFF333333  -- slider track
local C_FILL     = 0xFF55FF55  -- slider fill
local C_DIVIDER  = 0xFF333333
local C_HOVER    = 0x18FFFFFF
local C_BTN_ON   = 0xFF1A3D1A  -- bg tombol ON
local C_BTN_OFF  = 0xFF3D1A1A  -- bg tombol OFF

-- =========================================================
-- FLY LOGIC
-- =========================================================

local function doFly()
    if not flyEnabled then return end
    local lp = GetLocalPlayer()
    if not lp then return end

    local spd = flySpeed * 0.1  -- scale speed

    if IsKeyDown(0x26) or IsKeyDown(0x57) then  -- UP / W
        lp.y = lp.y - spd
    end
    if IsKeyDown(0x28) or IsKeyDown(0x53) then  -- DOWN / S
        lp.y = lp.y + spd
    end
    if IsKeyDown(0x25) or IsKeyDown(0x41) then  -- LEFT / A
        lp.x = lp.x - spd
    end
    if IsKeyDown(0x27) or IsKeyDown(0x44) then  -- RIGHT / D
        lp.x = lp.x + spd
    end

    -- Cancel gravity
    lp.velocityY = 0
    lp.velocityX = 0
end

-- =========================================================
-- GUI RENDER
-- =========================================================

local function drawRect(x, y, w, h, color)
    DrawRect(x, y, x + w, y + h, color)
end

local function drawText(text, x, y, color, size)
    DrawText(text, x, y, color, size or 10)
end

local function renderGUI()
    -- BG
    drawRect(guiX, guiY, W, H, C_BG)

    -- Border
    DrawRect(guiX,       guiY,       guiX+W,   guiY+1,   C_DIVIDER)
    DrawRect(guiX,       guiY+H-1,   guiX+W,   guiY+H,   C_DIVIDER)
    DrawRect(guiX,       guiY,       guiX+1,   guiY+H,   C_DIVIDER)
    DrawRect(guiX+W-1,   guiY,       guiX+W,   guiY+H,   C_DIVIDER)

    -- Header
    drawRect(guiX, guiY, W, 22, C_HEADER)
    drawText("TIOO Fly", guiX + 8, guiY + 6, C_WHITE, 11)
    -- Green underline header
    drawRect(guiX, guiY+19, W, 3, C_GREEN)

    -- ON/OFF Button
    local btnY   = guiY + 30
    local btnX   = guiX + 10
    local btnW   = W - 20
    local btnH   = 20
    local btnCol = flyEnabled and C_BTN_ON or C_BTN_OFF
    local btnTxt = flyEnabled and "ON" or "OFF"
    local btnTxtCol = flyEnabled and C_GREEN or C_RED

    drawRect(btnX, btnY, btnW, btnH, btnCol)
    -- Border tombol
    DrawRect(btnX,        btnY,        btnX+btnW,   btnY+1,    flyEnabled and C_GREEN or C_RED)
    DrawRect(btnX,        btnY+btnH-1, btnX+btnW,   btnY+btnH, flyEnabled and C_GREEN or C_RED)
    DrawRect(btnX,        btnY,        btnX+1,      btnY+btnH, flyEnabled and C_GREEN or C_RED)
    DrawRect(btnX+btnW-1, btnY,        btnX+btnW,   btnY+btnH, flyEnabled and C_GREEN or C_RED)

    local tw = GetTextWidth(btnTxt, 11)
    drawText(btnTxt, btnX + btnW/2 - tw/2, btnY + 5, btnTxtCol, 11)

    -- Slider label + value
    local slLabelY = guiY + 60
    drawText("Speed", guiX + 10, slLabelY, C_GRAY, 10)
    local valTxt = tostring(flySpeed)
    local vw = GetTextWidth(valTxt, 10)
    drawText(valTxt, guiX + W - 10 - vw, slLabelY, C_PINK, 10)

    -- Slider track
    local tX1 = guiX + 10
    local tX2 = guiX + W - 10
    local tY  = guiY + 76
    drawRect(tX1, tY, tX2 - tX1, 3, C_TRACK)

    -- Slider fill
    local ratio = (flySpeed - 1) / (500 - 1)
    local fillW = math.floor(ratio * (tX2 - tX1))
    drawRect(tX1, tY, fillW, 3, C_FILL)

    -- Slider thumb (pink)
    local thumbX = tX1 + fillW - 4
    drawRect(thumbX, tY - 5, 8, 13, C_PINK)

    -- Bottom hint
    drawText("Drag to move", guiX + W/2 - 28, guiY + H - 14, C_GRAY, 9)
end

-- =========================================================
-- INPUT HANDLING
-- =========================================================

local sliderDragging = false

AddHook(function(x, y, btn, state)
    -- state 1 = press, 0 = release
    local btnY  = guiY + 30
    local btnX  = guiX + 10
    local btnW  = W - 20
    local btnH  = 20

    local tX1   = guiX + 10
    local tX2   = guiX + W - 10
    local tY    = guiY + 76

    if state == 1 then
        -- Klik tombol ON/OFF
        if x >= btnX and x <= btnX+btnW and y >= btnY and y <= btnY+btnH then
            flyEnabled = not flyEnabled
            return true
        end

        -- Klik slider
        if x >= tX1 and x <= tX2 and y >= tY-6 and y <= tY+9 then
            sliderDragging = true
            local ratio = (x - tX1) / (tX2 - tX1)
            flySpeed = math.floor(1 + ratio * (500 - 1))
            flySpeed = math.max(1, math.min(500, flySpeed))
            return true
        end

        -- Drag header
        if x >= guiX and x <= guiX+W and y >= guiY and y <= guiY+22 then
            dragging = true
            dragOffX = x - guiX
            dragOffY = y - guiY
            return true
        end

    elseif state == 0 then
        dragging      = false
        sliderDragging = false
    end

end, "OnMouseEvent")

AddHook(function(x, y)
    if dragging then
        guiX = x - dragOffX
        guiY = y - dragOffY
    end
    if sliderDragging then
        local tX1 = guiX + 10
        local tX2 = guiX + W - 10
        local ratio = (x - tX1) / (tX2 - tX1)
        flySpeed = math.floor(1 + ratio * (500 - 1))
        flySpeed = math.max(1, math.min(500, flySpeed))
    end
end, "OnMouseMove")

-- =========================================================
-- MAIN HOOKS
-- =========================================================

AddHook(function()
    doFly()
end, "OnTick")

AddHook(function()
    renderGUI()
end, "OnRender")

-- Startup message
SendPacket(2, "action|input\n|text|`2[TIOO]`0 Fly loaded! Speed: `b" .. flySpeed)
