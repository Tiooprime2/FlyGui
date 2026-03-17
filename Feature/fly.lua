-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
-- Logic fly dari script XNEO, support R6 + R15
-- =========================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

local Fly = {}
Fly.enabled = false
Fly.speed   = 50

local flyThread = nil
local flyBG     = nil
local flyBV     = nil

-- =========================================================
-- ENABLE
-- =========================================================
function Fly.enable()
    Fly.disable()

    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Disable semua state biar gak jatuh
    local states = {
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Flying,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Landed,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.Swimming,
    }
    for _, s in ipairs(states) do hum:SetStateEnabled(s, false) end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    hum.PlatformStand = true

    -- Detect R6 atau R15
    local isR6 = hum.RigType == Enum.HumanoidRigType.R6
    local torso = isR6 and char:FindFirstChild("Torso")
                       or  char:FindFirstChild("UpperTorso")
    if not torso then return end

    -- BodyGyro + BodyVelocity sama persis kayak script asli
    local bg = Instance.new("BodyGyro")
    bg.P          = 9e4
    bg.MaxTorque  = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame     = torso.CFrame
    bg.Parent     = torso
    flyBG = bg

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0.1, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent   = torso
    flyBV = bv

    -- Loop fly sama persis kayak script asli
    -- ctrl di-drive dari MoveDirection (mobile joystick + PC WASD)
    flyThread = task.spawn(function()
        local ctrl     = {f = 0, b = 0, l = 0, r = 0}
        local lastctrl = {f = 0, b = 0, l = 0, r = 0}
        local speed    = 0
        local maxspeed = Fly.speed

        while Fly.enabled do
            RunService.RenderStepped:Wait()

            maxspeed = Fly.speed

            -- Ambil input dari MoveDirection (works mobile + PC)
            local char2 = lp.Character
            if not char2 then break end
            local hum2 = char2:FindFirstChildOfClass("Humanoid")
            if not hum2 then break end

            local md = hum2.MoveDirection
            -- Konversi MoveDirection ke ctrl persis format script asli
            ctrl.f =  (md.Z < -0.1) and 1 or 0   -- maju
            ctrl.b =  (md.Z >  0.1) and -1 or 0  -- mundur
            ctrl.r =  (md.X >  0.1) and 1 or 0   -- kanan
            ctrl.l =  (md.X < -0.1) and -1 or 0  -- kiri

            -- Smooth acceleration/deceleration SAMA PERSIS script asli
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = speed + 0.5 + (speed / maxspeed)
                if speed > maxspeed then speed = maxspeed end
            elseif speed ~= 0 then
                speed = speed - 1
                if speed < 0 then speed = 0 end
            end

            local camCF = workspace.CurrentCamera.CoordinateFrame

            -- Velocity formula SAMA PERSIS script asli
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.Velocity = (
                    (camCF.LookVector * (ctrl.f + ctrl.b)) +
                    ((camCF * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).Position) - camCF.Position)
                ) * speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}

            elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                -- Masih meluncur (deceleration)
                bv.Velocity = (
                    (camCF.LookVector * (lastctrl.f + lastctrl.b)) +
                    ((camCF * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).Position) - camCF.Position)
                ) * speed
            else
                bv.Velocity = Vector3.zero
            end

            -- Gyro tilt ikut arah gerak
            bg.CFrame = camCF * CFrame.Angles(
                -math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0
            )
        end

        -- Cleanup setelah loop selesai
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if flyBV then flyBV:Destroy(); flyBV = nil end
    end)
end

-- =========================================================
-- DISABLE
-- =========================================================
function Fly.disable()
    Fly.enabled = false  -- stop loop

    if flyBG then flyBG:Destroy(); flyBG = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    flyThread = nil

    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.PlatformStand = false

    local states = {
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Flying,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Landed,
        Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.Swimming,
    }
    for _, s in ipairs(states) do hum:SetStateEnabled(s, true) end
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
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

print("[TIOO] fly.lua loaded! (XNEO logic | R6+R15 | Mobile+PC)")
return Fly
