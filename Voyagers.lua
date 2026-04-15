-- [[ Voyagers | Visuals Script ]]
-- Tailored for "Sea of Pirates" and general player ESP
task.wait(10)
print("Voyagers: Initializing after 10s safety delay...")

local success, err = pcall(function()
    -- [[ Services ]]
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer

    -- [[ Settings & Mapping ]]
    local Settings = {
        -- Player Visuals
        Chams = false,
        FillColor = Color3.fromRGB(255, 0, 0),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0,
        ShowGamertag = false,
        ShowDistance = false,
        ShowHealth = false,
        ESPColor = Color3.fromRGB(255, 255, 255),
        -- Ship ESP Settings
        ShowShipESP = false,
        ShipColor = Color3.fromRGB(0, 255, 255),
        -- Movement Settings
        CFrameSpeed = false,
        CFrameMultiplier = 1,
        StealthFly = false,
        FlySpeed = 50,
        -- Combat Settings
        Fullbright = false,
        Aimbot = false,
        CannonAim = false,
        CannonSpeed = 150,
        CannonGravity = 196,
        -- Ship Settings
        ShipSpeed = false,
        ShipMultiplier = 1,
        FOVSize = 100,
        ShowFOV = false,
        FOVColor = Color3.fromRGB(255, 255, 255),
        Crosshair = false,
        CrosshairSize = 10,
        CrosshairColor = Color3.fromRGB(0, 255, 0),
        CombatTarget = nil,
        -- Damage Mods
        Instakill = false,
        DamageMultiplier = 1,
        -- NPC Visuals
        NPCESP = false,
        NPCColor = Color3.fromRGB(255, 165, 0), -- Orange for enemies
        NPCAimbot = false,
    }

    local SHIP_TYPES = {
        ["Brigantine"] = "Brigantine",
        ["TinySloop"] = "Sloop",
        ["SailBoat"] = "Sailboat"
    }

    -- [[ Data Storage ]]
    local Highlights = {}
    local ESPGuis = {}
    local ShipVisuals = {}
    local NPCVisuals = {}
    local LastCombatRemote = nil
    
    -- [[ Environmental Backups ]]
    local OriginalLighting = {
        ClockTime = game:GetService("Lighting").ClockTime,
        Brightness = game:GetService("Lighting").Brightness,
    }
    -- [[ Drawing Visuals ]]
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 64
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Settings.FOVColor
    FOVCircle.Visible = false

    local CrosshairLines = {
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line")
    }

    for _, line in pairs(CrosshairLines) do
        line.Thickness = 1
        line.Transparency = 1
        line.Color = Settings.CrosshairColor
        line.Visible = false
    end

    local CannonAimCircle = Drawing.new("Circle")
    CannonAimCircle.Thickness = 2
    CannonAimCircle.NumSides = 32
    CannonAimCircle.Radius = 15
    CannonAimCircle.Filled = false
    CannonAimCircle.Transparency = 1
    CannonAimCircle.Color = Color3.fromRGB(255, 0, 0)
    CannonAimCircle.Visible = false

    -- [[ UI Initialization ]]
    local Window = Rayfield:CreateWindow({
        Name = "Voyagers | Visuals",
        LoadingTitle = "Voyagers Execution",
        LoadingSubtitle = "by Antigravity",
        ConfigurationSaving = { Enabled = true, FolderName = "Voyagers", FileName = "VisualsConfig" },
        KeySystem = false,
    })

    local CombatTab = Window:CreateTab("Combat", nil)
    local VisualsTab = Window:CreateTab("Visuals", nil)
    local WorldTab = Window:CreateTab("World", nil)
    local MovementTab = Window:CreateTab("Movement", nil)
    local MiscTab = Window:CreateTab("Misc", nil)

    -- [[ Combat Utils ]]

    local function GetMyShip()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Strategy 1: If in a seat, find the seat's model
        if hum and hum.SeatPart then
            local current = hum.SeatPart
            while current and current ~= workspace do
                if ShipVisuals[current] or SHIP_TYPES[current.Name] or current:FindFirstChild("MainHull") then
                    return current
                end
                current = current.Parent
            end
        end

        -- Strategy 2: If standing on the ship, look up from the char
        local current = char.Parent
        while current and current ~= workspace do
            if ShipVisuals[current] or SHIP_TYPES[current.Name] or current:FindFirstChild("MainHull") then
                return current
            end
            current = current.Parent
        end

        return nil
    end

    local function GetClosestPlayerInFOV()
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mousePos = LocalPlayer:GetMouse()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if distance < shortestDistance and distance <= Settings.FOVSize then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
        return closestPlayer
    end

    local function ApplyNPCVisuals(model)
        if not model or NPCVisuals[model] then return end
        local head = model:FindFirstChild("Head") or model:FindFirstChild("Eye") or model:FindFirstChildWhichIsA("BasePart")
        if not head then return end

        local billboard = Instance.new("BillboardGui", model)
        billboard.Name = "VoyagerNPCESP"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = head
        
        local label = Instance.new("TextLabel", billboard)
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextColor3 = Settings.NPCColor
        label.TextStrokeTransparency = 0.5
        label.Text = model.Name
        label.Visible = Settings.NPCESP
        
        NPCVisuals[model] = label
    end

    local function GetClosestTarget()
        local closest = nil
        local shortestDistance = math.huge
        local mousePos = LocalPlayer:GetMouse()
        local cam = workspace.CurrentCamera

        -- Check Players
        if Settings.Aimbot then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local pos, onScreen = cam:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if distance < shortestDistance and distance <= Settings.FOVSize then
                            closest = player.Character:FindFirstChild("Head") or player.Character.HumanoidRootPart
                            shortestDistance = distance
                        end
                    end
                end
            end
        end

        -- Check NPCs (If Aimbotting NPCs is enabled)
        if Settings.NPCAimbot then
            for model, _ in pairs(NPCVisuals) do
                if model.Parent and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 then
                    local targetPart = model:FindFirstChild("Head") or model:FindFirstChild("Eye") or model:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local pos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                            if distance < shortestDistance and distance <= Settings.FOVSize then
                                closest = targetPart
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end

        return closest
    end

    -- [[ Visual Handlers ]]

    local function UpdateHighlight(highlight)
        if not highlight then return end
        highlight.Enabled = Settings.Chams
        highlight.FillColor = Settings.FillColor
        highlight.OutlineColor = Settings.OutlineColor
        highlight.FillTransparency = Settings.FillTransparency
        highlight.OutlineTransparency = Settings.OutlineTransparency
    end

    local function GetBestPart(model)
        if model.PrimaryPart then return model.PrimaryPart end
        local largestPart = nil
        local maxVolume = 0
        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                local volume = part.Size.X * part.Size.Y * part.Size.Z
                if volume > maxVolume then
                    maxVolume = volume
                    largestPart = part
                end
            end
        end
        return largestPart
    end

    local function ApplyPlayerVisuals(player)
        if player == LocalPlayer then return end
        local function OnCharacterAdded(character)
            if not character then return end
            local highlight = Instance.new("Highlight", character)
            highlight.Name = "VoyagerHighlight"
            Highlights[player] = highlight
            UpdateHighlight(highlight)
            
            local billboard = Instance.new("BillboardGui", character)
            billboard.Name = "VoyagerESP"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.Adornee = character:WaitForChild("Head", 5) or character.PrimaryPart
            billboard.AlwaysOnTop = true
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            
            local label = Instance.new("TextLabel", billboard)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Settings.ESPColor
            label.TextStrokeTransparency = 0.5
            ESPGuis[player] = label
        end
        player.CharacterAdded:Connect(OnCharacterAdded)
        if player.Character then OnCharacterAdded(player.Character) end
    end

    local function ApplyShipVisuals(model)
        if not model or not model.Parent or ShipVisuals[model] then return end
        local displayName = SHIP_TYPES[model.Name] or "Boat"
        local targetPart = model:FindFirstChild("MainHull") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        
        if not targetPart then
            task.spawn(function()
                targetPart = model:WaitForChild("MainHull", 5) or model:FindFirstChildWhichIsA("BasePart")
                if targetPart then ApplyShipVisuals(model) end
            end)
            return
        end
        
        local billboard = Instance.new("BillboardGui", model)
        billboard.Name = "VoyagerShipESP"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 15, 0)
        billboard.Adornee = targetPart
        
        local label = Instance.new("TextLabel", billboard)
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 18
        label.TextColor3 = Settings.ShipColor
        label.TextStrokeTransparency = 0.5
        label.Text = displayName
        
        ShipVisuals[model] = {label = label, model = model, displayName = displayName}
        label.Visible = Settings.ShowShipESP
    end

    -- [[ Update Loops ]]

    RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        local mousePos = LocalPlayer:GetMouse()
        local center = Vector2.new(mousePos.X, mousePos.Y + 36) -- Offset for top bar

        -- FOV Circle Visuals
        FOVCircle.Position = center
        FOVCircle.Radius = Settings.FOVSize
        FOVCircle.Visible = Settings.ShowFOV
        FOVCircle.Color = Settings.FOVColor

        -- Crosshair Visuals
        local s = Settings.CrosshairSize
        CrosshairLines.Top.From = center - Vector2.new(0, 5)
        CrosshairLines.Top.To = center - Vector2.new(0, 5 + s)
        CrosshairLines.Bottom.From = center + Vector2.new(0, 5)
        CrosshairLines.Bottom.To = center + Vector2.new(0, 5 + s)
        CrosshairLines.Left.From = center - Vector2.new(5, 0)
        CrosshairLines.Left.To = center - Vector2.new(5 + s, 0)
        CrosshairLines.Right.From = center + Vector2.new(5, 0)
        CrosshairLines.Right.To = center + Vector2.new(5 + s, 0)
        
        for _, line in pairs(CrosshairLines) do
            line.Visible = Settings.Crosshair
            line.Color = Settings.CrosshairColor
        end

        -- Ship Speed (Hold Keybind)
        if Settings.ShipSpeed and UserInputService:IsKeyDown(Enum.KeyCode.F) then
            local ship = GetMyShip()
            if ship and ship.PrimaryPart then
                local moveDir = ship.PrimaryPart.CFrame.LookVector
                ship:PivotTo(ship:GetPivot() + (moveDir * (Settings.ShipMultiplier * 0.5)))
            end
        end

        -- Camera Aimbot (Updated for NPCs)
        if (Settings.Aimbot or Settings.NPCAimbot) then
            local targetPart = GetClosestTarget()
            if targetPart then
                local isFirstPerson = (cam.CFrame.Position - cam.Focus.Position).Magnitude < 0.6
                if isFirstPerson then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPart.Position)
                end
            end
        end

        -- Cannon Aim Helper
        local myShip = GetMyShip()
        local targetShip = nil
        local shortestShipDist = math.huge
        for _, ship in pairs(ShipVisuals) do
            if ship.model and ship.model.Parent and ship.model ~= myShip then
                local dist = (ship.model:GetPivot().Position - cam.CFrame.Position).Magnitude
                if dist < shortestShipDist then
                    targetShip = ship
                    shortestShipDist = dist
                end
            end
        end

        if Settings.CannonAim and targetShip and LocalPlayer.Character then
            local targetPos = targetShip.model:GetPivot().Position
            local targetVel = targetShip.model.PrimaryPart and targetShip.model.PrimaryPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
            local myPos = cam.CFrame.Position
            local dist = (targetPos - myPos).Magnitude
            
            -- Basic Ballistics
            local projectileSpeed = Settings.CannonSpeed
            local gravity = Settings.CannonGravity
            local timeToHit = dist / projectileSpeed
            
            -- Prediction (Lead Target)
            local leadPos = targetPos + (targetVel * timeToHit)
            
            -- Gravity Compensation (Aim Higher)
            local dropOffset = 0.5 * gravity * (timeToHit ^ 2)
            local aimPos = leadPos + Vector3.new(0, dropOffset, 0)
            
            local screenPos, onScreen = cam:WorldToViewportPoint(aimPos)
            if onScreen then
                CannonAimCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
                CannonAimCircle.Visible = true
            else
                CannonAimCircle.Visible = false
            end
        else
            CannonAimCircle.Visible = false
        end

        -- Player ESP
        for player, label in pairs(ESPGuis) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local text = Settings.ShowGamertag and player.Name or ""
                local stats = {}
                if Settings.ShowHealth and player.Character:FindFirstChild("Humanoid") then
                    table.insert(stats, string.format("Health: %d", math.floor(player.Character.Humanoid.Health)))
                end
                if Settings.ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(stats, string.format("[%d studs]", math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)))
                end
                if #stats > 0 then text = (text ~= "" and text .. "\n" or "") .. table.concat(stats, " | ") end
                label.Text = text
                label.Visible = (Settings.ShowHealth or Settings.ShowDistance or Settings.ShowGamertag)
                label.TextColor3 = Settings.ESPColor
            end
        end

        -- Ship ESP
        for model, data in pairs(ShipVisuals) do
            if model:IsDescendantOf(workspace) and Settings.ShowShipESP then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((model:GetPivot().Position - LocalPlayer.Character:GetPivot().Position).Magnitude)
                    data.label.Text = string.format("%s\n[%d studs]", data.displayName, dist)
                else data.label.Text = data.displayName end
                data.label.Visible = true
                data.label.TextColor3 = Settings.ShipColor
            else data.label.Visible = false end
        end

        -- NPC ESP Update
        for model, label in pairs(NPCVisuals) do
            if model.Parent and Settings.NPCESP then
                if model:FindFirstChild("Humanoid") and model.Humanoid.Health <= 0 then
                    label.Visible = false
                else
                    label.Visible = true
                    label.TextColor3 = Settings.NPCColor
                end
            else
                label.Visible = false
            end
        end
    end)

    -- Persistent Movement Loop
    RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local char = LocalPlayer.Character
        local hum = char.Humanoid
        local hrp = char.HumanoidRootPart

        -- Stealth CFrame Speed (Bypass)
        if Settings.CFrameSpeed and (hum.MoveDirection.Magnitude > 0) then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Settings.CFrameMultiplier / 5))
        end

        -- Stealth Fly (Bypass)
        if Settings.StealthFly then
            hum.PlatformStand = false -- Keeping it off to avoid state detection
            local moveDir = hum.MoveDirection
            local vertical = 0
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then vertical = 1
            elseif game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -1 end
            
            hrp.Velocity = Vector3.new(0, 0.1, 0) -- Tiny hover velocity
            -- Move in world space for predictable controls
            local flyVec = (moveDir * (Settings.FlySpeed / 25)) + Vector3.new(0, vertical * (Settings.FlySpeed / 25), 0)
            hrp.CFrame = hrp.CFrame + flyVec
        elseif not Settings.StealthFly and hrp.Velocity.Y == 0.1 then
            -- One-time reset when turning off fly
            hrp.Velocity = Vector3.new(0, 0, 0)
        end

        -- Combat Target Update
        if Settings.Aimbot then
            Settings.CombatTarget = GetClosestPlayerInFOV()
        else
            Settings.CombatTarget = nil
        end

        -- Fullbright
        local Lighting = game:GetService("Lighting")
        if Settings.Fullbright then
            if Lighting.ClockTime ~= 12 then Lighting.ClockTime = 12 end
            if Lighting.Brightness ~= 2 then Lighting.Brightness = 2 end
        elseif Lighting.ClockTime == 12 or Lighting.Brightness == 2 then
            -- Only restore if they haven't been manually changed away from Fullbright defaults
            Lighting.ClockTime = OriginalLighting.ClockTime
            Lighting.Brightness = OriginalLighting.Brightness
        end

        -- Safe Click TP (Stealth Version)
        if Settings.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local mousePos = LocalPlayer:GetMouse().Hit
            if mousePos then
                local targetPos = mousePos.Position + Vector3.new(0, 3, 0)
                local startPos = hrp.Position
                local distance = (targetPos - startPos).Magnitude
                
                if distance > 1 then
                    -- Movement using TweenService for smoother bypass
                    local tweenTime = distance / Settings.TPSpeed
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    
                    if hum then hum.PlatformStand = true end
                    
                    local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
                    tween:Play()
                    
                    tween.Completed:Wait()
                    if hum then hum.PlatformStand = false end
                end
                task.wait(0.5) 
            end
        end

        -- Instakill / Damage Multiplier Logic
        if Settings.Instakill and LastCombatRemote and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            -- Spam the last detected combat remote to simulate high damage
            for i = 1, math.floor(Settings.DamageMultiplier * 5) do
                -- This assumes the remote was captured by our observer below
                -- We re-fire it with the same arguments if possible, or just fire it
                pcall(function()
                    LastCombatRemote:FireServer() 
                end)
            end
        end
    end)

    -- [[ Combat Remote Observer ]]
    -- This helps find the "Hit" remote automatically when you attack
    local canHook = (getrawmetatable and setreadonly and newcclosure)
    if canHook then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "FireServer" and (tostring(self):lower():find("hit") or tostring(self):lower():find("damage") or tostring(self):lower():find("combat")) then
                LastCombatRemote = self
            end
            
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    else
        warn("Voyagers: Executor lacks metatable support (getrawmetatable). Damage Hacks will be limited.")
    end

    -- [[ UI Setup ]]

    -- Combat Tab
    -- Combat Tab
    CombatTab:CreateSection("Player Targeting")
    CombatTab:CreateToggle({Name = "Enable Player Aimbot", CurrentValue = false, Callback = function(v) Settings.Aimbot = v end})
    CombatTab:CreateToggle({Name = "Enable NPC Aimbot", CurrentValue = false, Callback = function(v) Settings.NPCAimbot = v end})

    CombatTab:CreateSection("Cannon Targeting")
    CombatTab:CreateToggle({Name = "Enable Cannon Helper", CurrentValue = false, Callback = function(v) Settings.CannonAim = v end})
    CombatTab:CreateSlider({Name = "Launch Speed (Range)", Range = {50, 1000}, Increment = 5, Suffix = " studs/s", CurrentValue = 150, Callback = function(v) Settings.CannonSpeed = v end})
    CombatTab:CreateSlider({Name = "Cannon Gravity", Range = {0, 500}, Increment = 5, Suffix = " grav", CurrentValue = 196, Callback = function(v) Settings.CannonGravity = v end})

    CombatTab:CreateSection("Targeting Visuals")
    CombatTab:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) Settings.ShowFOV = v end})
    CombatTab:CreateSlider({Name = "FOV Radius", Range = {20, 600}, Increment = 1, Suffix = "px", CurrentValue = 100, Callback = function(v) Settings.FOVSize = v end})
    CombatTab:CreateColorPicker({Name = "FOV Color", Color = Settings.FOVColor, Callback = function(v) Settings.FOVColor = v end})
    
    CombatTab:CreateSection("Custom Crosshair")
    CombatTab:CreateToggle({Name = "Enable Crosshair", CurrentValue = false, Callback = function(v) Settings.Crosshair = v end})
    CombatTab:CreateSlider({Name = "Crosshair Size", Range = {5, 50}, Increment = 1, Suffix = "px", CurrentValue = 10, Callback = function(v) Settings.CrosshairSize = v end})
    CombatTab:CreateColorPicker({Name = "Crosshair Color", Color = Settings.CrosshairColor, Callback = function(v) Settings.CrosshairColor = v end})

    CombatTab:CreateSection("Damage Hacks")
    CombatTab:CreateToggle({Name = "Enable Instakill", CurrentValue = false, Callback = function(v) Settings.Instakill = v end})
    CombatTab:CreateSlider({Name = "Damage Multiplier", Range = {1, 50}, Increment = 1, Suffix = "x", CurrentValue = 1, Callback = function(v) Settings.DamageMultiplier = v end})
    CombatTab:CreateLabel("Note: Uses remote spam. Requires one manual hit to detect remote.")

    -- Visuals Tab
    VisualsTab:CreateSection("Player Chams")
    VisualsTab:CreateToggle({Name = "Enable Chams", CurrentValue = false, Callback = function(v) Settings.Chams = v for _, h in pairs(Highlights) do UpdateHighlight(h) end end})
    VisualsTab:CreateColorPicker({Name = "Chams Color", Color = Settings.FillColor, Callback = function(v) Settings.FillColor = v for _, h in pairs(Highlights) do UpdateHighlight(h) end end})
    VisualsTab:CreateSection("Player ESP Extras")
    VisualsTab:CreateToggle({Name = "Show Gamertag", CurrentValue = false, Callback = function(v) Settings.ShowGamertag = v end})
    VisualsTab:CreateToggle({Name = "Show Health", CurrentValue = false, Callback = function(v) Settings.ShowHealth = v end})
    VisualsTab:CreateToggle({Name = "Show Distance", CurrentValue = false, Callback = function(v) Settings.ShowDistance = v end})
    VisualsTab:CreateColorPicker({Name = "ESP Text Color", Color = Settings.ESPColor, Callback = function(v) Settings.ESPColor = v end})
    
    VisualsTab:CreateSection("NPC ESP")
    VisualsTab:CreateToggle({Name = "Enable NPC ESP", CurrentValue = false, Callback = function(v) Settings.NPCESP = v end})
    VisualsTab:CreateColorPicker({Name = "NPC ESP Color", Color = Settings.NPCColor, Callback = function(v) Settings.NPCColor = v end})

    -- World Tab
    WorldTab:CreateSection("Atmosphere")
    WorldTab:CreateToggle({Name = "Enable Fullbright", CurrentValue = false, Callback = function(v) Settings.Fullbright = v end})

    WorldTab:CreateSection("Ship ESP")
    WorldTab:CreateToggle({Name = "Enable Boat ESP", CurrentValue = false, Callback = function(v) Settings.ShowShipESP = v end})
    WorldTab:CreateColorPicker({Name = "Boat Text Color", Color = Settings.ShipColor, Callback = function(v) Settings.ShipColor = v end})

    -- Movement Tab
    MovementTab:CreateSection("Bypass Movement")
    MovementTab:CreateToggle({Name = "Enable CFrame Speed", CurrentValue = false, Callback = function(v) Settings.CFrameSpeed = v end})
    MovementTab:CreateSlider({Name = "Speed Multiplier", Range = {1, 5}, Increment = 0.1, Suffix = "x", CurrentValue = 1, Callback = function(v) Settings.CFrameMultiplier = v end})
    MovementTab:CreateToggle({Name = "Stealth Fly", CurrentValue = false, Callback = function(v) Settings.StealthFly = v end})
    MovementTab:CreateSlider({Name = "Fly Speed", Range = {5, 20}, Increment = 1, Suffix = "Speed", CurrentValue = 10, Callback = function(v) Settings.FlySpeed = v end})

    -- Ship Tab
    local ShipTab = Window:CreateTab("Ship", nil)
    ShipTab:CreateSection("Mobility")
    ShipTab:CreateToggle({Name = "Enable Ship Speed", CurrentValue = false, Callback = function(v) Settings.ShipSpeed = v end})
    ShipTab:CreateLabel("Hold 'F' to boost ship speed")
    ShipTab:CreateSlider({Name = "Speed Multiplier", Range = {1, 5}, Increment = 0.1, Suffix = "x", CurrentValue = 1, Callback = function(v) Settings.ShipMultiplier = v end})
    
    ShipTab:CreateSection("Visuals")
    ShipTab:CreateToggle({Name = "Show Ship ESP", CurrentValue = false, Callback = function(v) 
        Settings.ShowShipESP = v 
        for _, ship in pairs(ShipVisuals) do ship.label.Visible = v end
    end})

    -- [[ Initialization ]]
    for _, player in pairs(Players:GetPlayers()) do ApplyPlayerVisuals(player) end
    Players.PlayerAdded:Connect(ApplyPlayerVisuals)

    local function StartShipDetection()
        for _, ship in pairs(CollectionService:GetTagged("Ship")) do ApplyShipVisuals(ship) end
        local shipFolder = workspace:FindFirstChild("Ships")
        if shipFolder then
            for _, ship in pairs(shipFolder:GetChildren()) do ApplyShipVisuals(ship) end
            shipFolder.ChildAdded:Connect(ApplyShipVisuals)
        end
        CollectionService:GetInstanceAddedSignal("Ship"):Connect(ApplyShipVisuals)
    end
    StartShipDetection()

    local function StartNPCDetection()
        for _, model in pairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                ApplyNPCVisuals(model)
            end
        end
        workspace.DescendantAdded:Connect(function(model)
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                ApplyNPCVisuals(model)
            end
        end)
        workspace.DescendantRemoving:Connect(function(model)
            if NPCVisuals[model] then
                NPCVisuals[model]:Destroy()
                NPCVisuals[model] = nil
            end
        end)
    end
    StartNPCDetection()

    Rayfield:LoadConfiguration()
    print("Voyagers: Initialized Successfully")
end)

if not success then warn("Voyagers Error:", err) end