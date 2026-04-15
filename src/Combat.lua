local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

return function(CombatTab, Settings, Utils, NPCVisuals, ShipVisuals, SHIP_TYPES, CannonAimCircle)
    -- [[ UI Elements ]]
    CombatTab:CreateSection("Player Targeting")
    CombatTab:CreateToggle({Name = "Enable Player Aimbot", CurrentValue = false, Callback = function(v) Settings.Aimbot = v end})
    CombatTab:CreateToggle({Name = "Enable NPC Aimbot", CurrentValue = false, Callback = function(v) Settings.NPCAimbot = v end})
    CombatTab:CreateToggle({Name = "Enable Silent Aim", CurrentValue = false, Callback = function(v) Settings.SilentAim = v end})
    CombatTab:CreateToggle({Name = "Silent Ballistics (Lead/Drop)", CurrentValue = true, Callback = function(v) Settings.SilentBallistics = v end})

    CombatTab:CreateSection("Ballistic Settings (Flintlocks & Cannons)")
    CombatTab:CreateToggle({Name = "Enable Cannon Helper", CurrentValue = false, Callback = function(v) Settings.CannonAim = v end})
    CombatTab:CreateSlider({Name = "Projectile Speed", Range = {50, 1000}, Increment = 5, CurrentValue = 150, Callback = function(v) Settings.CannonSpeed = v end})
    CombatTab:CreateSlider({Name = "Projectile Gravity", Range = {0, 500}, Increment = 5, CurrentValue = 196, Callback = function(v) Settings.CannonGravity = v end})

    CombatTab:CreateSection("Damage Hacks")
    CombatTab:CreateToggle({Name = "Enable Instakill", CurrentValue = false, Callback = function(v) Settings.Instakill = v end})
    CombatTab:CreateSlider({Name = "Damage Multiplier", Range = {1, 50}, Increment = 1, CurrentValue = 1, Callback = function(v) Settings.DamageMultiplier = v end})
    
    -- [[ Logic Loops ]]
    local LastCombatRemote = nil

    -- Aimbot Loop
    RunService.RenderStepped:Connect(function()
        if (Settings.Aimbot or Settings.NPCAimbot) then
            local targetPart = Utils.GetClosestTarget(Settings, NPCVisuals)
            if targetPart then
                local cam = workspace.CurrentCamera
                local isFirstPerson = (cam.CFrame.Position - cam.Focus.Position).Magnitude < 0.6
                if isFirstPerson then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPart.Position)
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

    -- Instakill Heartbeat
    RunService.Heartbeat:Connect(function()
        if Settings.Instakill and _G.LastCombatRemote and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            for i = 1, math.floor(Settings.DamageMultiplier * 5) do
                pcall(function() _G.LastCombatRemote:FireServer() end)
            end
        end
    end)

    -- Metatable Hook for Silent Aim and Remote Discovery
    local canHook = (getrawmetatable and setreadonly and newcclosure)
    if canHook then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            -- Remote Discovery (for Instakill)
            if method == "FireServer" and (tostring(self):lower():find("hit") or tostring(self):lower():find("damage") or tostring(self):lower():find("combat")) then
                _G.LastCombatRemote = self
            end

            -- Silent Aim Logic (Raycast Redirection with Ballistics)
            if Settings.SilentAim and not checkcaller() then
                local targetPart = Utils.GetClosestTarget(Settings, NPCVisuals)
                if targetPart then
                    local aimPos = targetPart.Position
                    
                    if Settings.SilentBallistics then
                        local origin = (method == "Raycast" and args[1]) or (method:find("Ray") and args[1] and args[1].Origin) or workspace.CurrentCamera.CFrame.Position
                        local targetVel = targetPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
                        local dist = (aimPos - origin).Magnitude
                        local timeToHit = dist / Settings.CannonSpeed
                        
                        -- Lead and Drop Compensation (No Spread included by overwriting direction)
                        local leadPos = aimPos + (targetVel * timeToHit)
                        local dropOffset = 0.5 * Settings.CannonGravity * (timeToHit ^ 2)
                        aimPos = leadPos + Vector3.new(0, dropOffset, 0)
                    end

                    if method == "Raycast" then
                        local origin, direction = args[1], args[2]
                        local redirectedDirection = (aimPos - origin).Unit * direction.Magnitude
                        return oldNamecall(self, origin, redirectedDirection, select(3, ...))
                    elseif method:find("FindPartOnRay") then
                        local oldRay = args[1]
                        local redirectedRay = Ray.new(oldRay.Origin, (aimPos - oldRay.Origin).Unit * oldRay.Direction.Magnitude)
                        return oldNamecall(self, redirectedRay, select(2, ...))
                    end
                end
            end

            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end
