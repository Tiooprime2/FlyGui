-- =========================================================
-- TIOO Fly - Core Fly Logic
-- by Tiooprime2
-- Fly logic: XNEO (murni 1:1)
-- =========================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

local Fly = {}
Fly.enabled = false
Fly.speed   = 50

-- =========================================================
-- ENABLE
-- =========================================================
function Fly.enable()
    Fly.disable()

    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Disable semua state (sama persis XNEO)
    hum:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    hum.PlatformStand = true

    task.spawn(function()
        if hum.RigType == Enum.HumanoidRigType.R6 then
            -- =============== R6 ===============
            local torso = char:FindFirstChild("Torso")
            if not torso then return end

            local ctrl     = {f=0, b=0, l=0, r=0}
            local lastctrl = {f=0, b=0, l=0, r=0}
            local maxspeed = Fly.speed
            local speed    = 0

            local bg = Instance.new("BodyGyro", torso)
            bg.P         = 9e4
            bg.maxTorque = Vector3.new(9e9,9e9,9e9)
            bg.cframe    = torso.CFrame

            local bv = Instance.new("BodyVelocity", torso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9,9e9,9e9)

            while Fly.enabled do
                RunService.RenderStepped:Wait()
                maxspeed = Fly.speed

                -- Input dari MoveDirection (works mobile + PC)
                local md = (lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") and lp.Character:FindFirstChildOfClass("Humanoid").MoveDirection) or Vector3.zero
                ctrl.f = md.Z < -0.1 and 1  or 0
                ctrl.b = md.Z >  0.1 and -1 or 0
                ctrl.r = md.X >  0.1 and 1  or 0
                ctrl.l = md.X < -0.1 and -1 or 0

                -- Accel/decel XNEO
                if ctrl.l+ctrl.r ~= 0 or ctrl.f+ctrl.b ~= 0 then
                    speed = speed+.5+(speed/maxspeed)
                    if speed > maxspeed then speed = maxspeed end
                elseif speed ~= 0 then
                    speed = speed-1
                    if speed < 0 then speed = 0 end
                end

                -- Velocity formula XNEO
                if (ctrl.l+ctrl.r) ~= 0 or (ctrl.f+ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector*(ctrl.f+ctrl.b))+((game.Workspace.CurrentCamera.CoordinateFrame*CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p)-game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                    lastctrl = {f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
                elseif (ctrl.l+ctrl.r) == 0 and (ctrl.f+ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector*(lastctrl.f+lastctrl.b))+((game.Workspace.CurrentCamera.CoordinateFrame*CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p)-game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
            end

            bg:Destroy()
            bv:Destroy()

        else
            -- =============== R15 ===============
            local UpperTorso = char:FindFirstChild("UpperTorso")
            if not UpperTorso then return end

            local ctrl     = {f=0, b=0, l=0, r=0}
            local lastctrl = {f=0, b=0, l=0, r=0}
            local maxspeed = Fly.speed
            local speed    = 0

            local bg = Instance.new("BodyGyro", UpperTorso)
            bg.P         = 9e4
            bg.maxTorque = Vector3.new(9e9,9e9,9e9)
            bg.cframe    = UpperTorso.CFrame

            local bv = Instance.new("BodyVelocity", UpperTorso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9,9e9,9e9)

            while Fly.enabled do
                RunService.RenderStepped:Wait()
                maxspeed = Fly.speed

                -- Input dari MoveDirection (works mobile + PC)
                local md = (lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") and lp.Character:FindFirstChildOfClass("Humanoid").MoveDirection) or Vector3.zero
                ctrl.f = md.Z < -0.1 and 1  or 0
                ctrl.b = md.Z >  0.1 and -1 or 0
                ctrl.r = md.X >  0.1 and 1  or 0
                ctrl.l = md.X < -0.1 and -1 or 0

                -- Accel/decel XNEO
                if ctrl.l+ctrl.r ~= 0 or ctrl.f+ctrl.b ~= 0 then
                    speed = speed+.5+(speed/maxspeed)
                    if speed > maxspeed then speed = maxspeed end
                elseif speed ~= 0 then
                    speed = speed-1
                    if speed < 0 then speed = 0 end
                end

                -- Velocity formula XNEO
                if (ctrl.l+ctrl.r) ~= 0 or (ctrl.f+ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector*(ctrl.f+ctrl.b))+((game.Workspace.CurrentCamera.CoordinateFrame*CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p)-game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                    lastctrl = {f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
                elseif (ctrl.l+ctrl.r) == 0 and (ctrl.f+ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector*(lastctrl.f+lastctrl.b))+((game.Workspace.CurrentCamera.CoordinateFrame*CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p)-game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
                else
                    bv.velocity = Vector3.new(0,0,0)
                end
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
            end

            bg:Destroy()
            bv:Destroy()
        end

        -- Restore state setelah fly OFF
        local hum2 = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum2 then
            hum2.PlatformStand = false
            hum2:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Running,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
            hum2:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
            hum2:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end)
end

-- =========================================================
-- DISABLE
-- =========================================================
function Fly.disable()
    Fly.enabled = false
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
end)

print("[TIOO] fly.lua loaded! (XNEO)")
return Fly
