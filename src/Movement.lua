local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer

return function(MovementTab, Settings, Utils)
    -- [[ UI Elements ]]
    local bypassSection = MovementTab:Section("Bypass Movement")
    bypassSection:Toggle("Enable CFrame Speed", function(v) Settings.CFrameSpeed = v end)
    bypassSection:Slider("Speed Multiplier", function(v) Settings.CFrameMultiplier = v end, 5, 1)
    bypassSection:Toggle("Stealth Fly", function(v) Settings.StealthFly = v end)
    bypassSection:Slider("Fly Speed", function(v) Settings.FlySpeed = v end, 20, 5)


    -- [[ Logic Loop ]]
    RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char.HumanoidRootPart

        -- CFrame Speed
        if Settings.CFrameSpeed and hum and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Settings.CFrameMultiplier / 5))
        end

        -- Stealth Fly
        if Settings.StealthFly then
            local moveDir = hum and hum.MoveDirection or Vector3.new(0,0,0)
            local vertical = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -1 end
            
            hrp.Velocity = Vector3.new(0, 0.1, 0)
            local flyVec = (moveDir * (Settings.FlySpeed / 25)) + Vector3.new(0, vertical * (Settings.FlySpeed / 25), 0)
            hrp.CFrame = hrp.CFrame + flyVec
        elseif not Settings.StealthFly and hrp.Velocity.Y == 0.1 then
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end
