local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

return function(CombatTab, Settings, Utils, NPCVisuals, ShipVisuals, SHIP_TYPES, CannonAimCircle)
    -- [[ UI Elements ]]
    CombatTab:CreateSection("Targeting & Aimbot")
    CombatTab:CreateToggle({Name = "Enable Player Aimbot", CurrentValue = false, Callback = function(v) Settings.Aimbot = v end})
    CombatTab:CreateToggle({Name = "Enable NPC Aimbot", CurrentValue = false, Callback = function(v) Settings.NPCAimbot = v end})
    CombatTab:CreateSlider({Name = "Aim Smoothing", Range = {1, 10}, Increment = 1, CurrentValue = 1, Callback = function(v) Settings.AimSmoothing = v end})
    CombatTab:CreateToggle({Name = "Aim Ballistics (Lead/Drop)", CurrentValue = true, Callback = function(v) Settings.AimBallistics = v end})

    CombatTab:CreateSection("Silent Aim Alternative (Xeno)")
    CombatTab:CreateToggle({Name = "Enable Hitbox Expander", CurrentValue = false, Callback = function(v) Settings.HitboxExpander = v end})
    CombatTab:CreateSlider({Name = "Hitbox Size", Range = {2, 15}, Increment = 0.5, CurrentValue = 2, Callback = function(v) Settings.HitboxSize = v end})

    CombatTab:CreateSection("Ballistic Settings (Flintlocks & Cannons)")
    CombatTab:CreateToggle({Name = "Enable Cannon Helper", CurrentValue = false, Callback = function(v) Settings.CannonAim = v end})
    CombatTab:CreateSlider({Name = "Projectile Speed", Range = {50, 1000}, Increment = 5, CurrentValue = 150, Callback = function(v) Settings.CannonSpeed = v end})
    CombatTab:CreateSlider({Name = "Projectile Gravity", Range = {0, 500}, Increment = 5, CurrentValue = 196, Callback = function(v) Settings.CannonGravity = v end})

    -- [[ Logic Loops ]]

    -- Aimbot Loop
    RunService.RenderStepped:Connect(function()
        if (Settings.Aimbot or Settings.NPCAimbot) then
            local targetPart = Utils.GetClosestTarget(Settings, NPCVisuals)
            if targetPart then
                local cam = workspace.CurrentCamera
                local aimPos = targetPart.Position

                -- Apply Ballistics
                if Settings.AimBallistics then
                    local origin = cam.CFrame.Position
                    local targetVel = targetPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
                    local dist = (aimPos - origin).Magnitude
                    local timeToHit = dist / Settings.CannonSpeed
                    
                    local leadPos = aimPos + (targetVel * timeToHit)
                    local dropOffset = 0.5 * Settings.CannonGravity * (timeToHit ^ 2)
                    aimPos = leadPos + Vector3.new(0, dropOffset, 0)
                end

                -- Aimbot Logic: Snaps only on Mouse1, with smoothing
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local lookCF = CFrame.new(cam.CFrame.Position, aimPos)
                    if Settings.AimSmoothing > 1 then
                        cam.CFrame = cam.CFrame:Lerp(lookCF, 1 / Settings.AimSmoothing)
                    else
                        cam.CFrame = lookCF
                    end
                end
            end
        end

        -- Cannon Helper Logic
        local myShip = Utils.GetMyShip(ShipVisuals, SHIP_TYPES)
        local targetShip = nil
        local shortestShipDist = math.huge
        for _, ship in pairs(ShipVisuals) do
            if ship.model and ship.model.Parent and ship.model ~= myShip then
                local dist = (ship.model:GetPivot().Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                if dist < shortestShipDist then
                    targetShip = ship
                    shortestShipDist = dist
                end
            end
        end

        if Settings.CannonAim and targetShip then
            local targetPos = targetShip.model:GetPivot().Position
            local targetVel = targetShip.model.PrimaryPart and targetShip.model.PrimaryPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            local myPos = workspace.CurrentCamera.CFrame.Position
            local dist = (targetPos - myPos).Magnitude
            
            local timeToHit = dist / Settings.CannonSpeed
            local leadPos = targetPos + (targetVel * timeToHit)
            local dropOffset = 0.5 * Settings.CannonGravity * (timeToHit ^ 2)
            local aimPos = leadPos + Vector3.new(0, dropOffset, 0)
            
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(aimPos)
            if onScreen then
                CannonAimCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
                CannonAimCircle.Visible = true
            else CannonAimCircle.Visible = false end
        else CannonAimCircle.Visible = false end
    end)

    -- Core Loops
    RunService.Heartbeat:Connect(function()
        -- [[ Hitbox Expander Logic ]]
        if Settings.HitboxExpander then
            local size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            -- Players
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Size = size
                        root.Transparency = 0.7
                        root.BrickColor = BrickColor.new("Really blue")
                        root.Material = Enum.Material.Neon
                        root.CanCollide = false
                    end
                end
            end
            -- NPCs
            for model, _ in pairs(NPCVisuals) do
                if model.Parent then
                    local root = model:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Size = size
                        root.Transparency = 0.7
                        root.BrickColor = BrickColor.new("Really blue")
                        root.Material = Enum.Material.Neon
                        root.CanCollide = false
                    end
                end
            end
        else
            -- Cleanup Players
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root and root.Transparency ~= 1 then
                        root.Size = Vector3.new(2, 2, 1)
                        root.Transparency = 1
                        root.BrickColor = BrickColor.new("Medium stone grey")
                        root.Material = Enum.Material.Plastic
                        root.CanCollide = false
                    end
                end
            end
            -- Cleanup NPCs
            for model, _ in pairs(NPCVisuals) do
                if model.Parent then
                    local root = model:FindFirstChild("HumanoidRootPart")
                    if root and root.Transparency ~= 1 then
                        root.Size = Vector3.new(2, 2, 1)
                        root.Transparency = 1
                        root.BrickColor = BrickColor.new("Medium stone grey")
                        root.Material = Enum.Material.Plastic
                        root.CanCollide = false
                    end
                end
            end
        end
    end)

    -- Note: Removed hook-based Silent Aim as Xeno doesn't support metatable/function hooks reliably.
    -- Magnetic Aim (Camera Snapping) implemented in RenderStepped loop above.
end
