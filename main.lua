-- =========================================================
-- TIOO Fly - Main Entry Point
-- by Tiooprime2
-- Execute file ini di executor kamu!
-- =========================================================

local FLY_URL = "https://raw.githubusercontent.com/Tiooprime2/FlyGui/main/fly.lua"
local UI_URL  = "https://raw.githubusercontent.com/Tiooprime2/FlyGui/main/ui.lua"

-- =========================================================
-- LOADER HELPER
-- =========================================================
local function loadModule(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if not ok then
        warn("[TIOO] Gagal load: " .. url)
        warn("[TIOO] Error: " .. tostring(result))
        return nil
    end
    return result
end

-- =========================================================
-- LOAD MODULES
-- =========================================================
print("[TIOO] Loading fly.lua...")
local Fly = loadModule(FLY_URL)
if not Fly then return end

print("[TIOO] Loading ui.lua...")
local UI = loadModule(UI_URL)
if not UI then return end

-- =========================================================
-- INIT
-- =========================================================
UI.init(Fly)

print("[TIOO] Semua module berhasil dimuat! ✅")
