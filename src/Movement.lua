local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer

return function(MovementTab, Settings, Utils)
    -- [[ UI Elements ]]
    MovementTab:CreateSection("Bypass Movement")
    MovementTab:CreateToggle({Name = "Enable CFrame Speed", CurrentValue = false, Callback = function(v) Settings.CFrameSpeed = v end})
    MovementTab:CreateSlider({Name = "Speed Multiplier", Range = {1, 5}, Increment = 0.1, CurrentValue = 1, Callback = function(v) Settings.CFrameMultiplier = v end})
    MovementTab:CreateToggle({Name = "Stealth Fly", CurrentValue = false, Callback = function(v) Settings.StealthFly = v end})
    MovementTab:CreateSlider({Name = "Fly Speed", Range = {5, 20}, Increment = 1, CurrentValue = 10, Callback = function(v) Settings.FlySpeed = v end})

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

    -- Click TP
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if Settings.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = LocalPlayer:GetMouse().Hit
            if mousePos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local targetPos = mousePos.Position + Vector3.new(0, 3, 0)
                local distance = (targetPos - hrp.Position).Magnitude
                
                if distance > 1 then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.PlatformStand = true end
                    local tween = TweenService:Create(hrp, TweenInfo.new(distance / Settings.TPSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
                    tween:Play()
                    tween.Completed:Wait()
                    if hum then hum.PlatformStand = false end
                end
            end
        end
    end)
end
