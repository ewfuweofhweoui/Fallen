local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

return function(VisualsTab, Settings, Utils, ESPGuis, NPCVisuals, ShipVisuals, SHIP_TYPES, Highlights, FOVCircle, CrosshairLines)
    -- [[ UI Elements ]]
    local targetingSection = VisualsTab:Section("Targeting Visuals")
    targetingSection:Toggle("Show FOV Circle", function(v) Settings.ShowFOV = v end)
    targetingSection:Slider("FOV Radius", function(v) Settings.FOVSize = v end, 600, 20)
    targetingSection:ColorWheel("FOV Color", function(v) Settings.FOVColor = v end)
    
    local crosshairSection = VisualsTab:Section("Custom Crosshair")
    crosshairSection:Toggle("Enable Crosshair", function(v) Settings.Crosshair = v end)
    crosshairSection:Slider("Crosshair Size", function(v) Settings.CrosshairSize = v end, 50, 5)
    crosshairSection:ColorWheel("Crosshair Color", function(v) Settings.CrosshairColor = v end)

    local chamsSection = VisualsTab:Section("Player Chams")
    chamsSection:Toggle("Enable Chams", function(v) Settings.Chams = v for _, h in pairs(Highlights) do Utils.UpdateHighlight(h, Settings) end end)
    chamsSection:ColorWheel("Chams Color", function(v) Settings.FillColor = v for _, h in pairs(Highlights) do Utils.UpdateHighlight(h, Settings) end end)

    local espSection = VisualsTab:Section("Player ESP Extras")
    espSection:Toggle("Show Gamertag", function(v) Settings.ShowGamertag = v end)
    espSection:Toggle("Show Health", function(v) Settings.ShowHealth = v end)
    espSection:Toggle("Show Distance", function(v) Settings.ShowDistance = v end)
    espSection:ColorWheel("ESP Text Color", function(v) Settings.ESPColor = v end)
    
    local npcSection = VisualsTab:Section("NPC ESP")
    npcSection:Toggle("Enable Global NPC ESP", function(v) Settings.NPCESP = v end)
    npcSection:ColorWheel("NPC ESP Color", function(v) Settings.NPCColor = v end)

    local npcDropdown = npcSection:Dropdown("Select NPC Types")
    local npcToggles = {}

    local function UpdateNPCToggles()
        for _, name in pairs(Settings.KnownNPCs) do
            if not npcToggles[name] then
                npcToggles[name] = npcDropdown:Toggle(name, function(v)
                    Settings.NPCFilters[name] = v
                end)
            end
        end
    end


    -- [[ Handlers ]]
    local function ApplyPlayerVisuals(player)
        if player == LocalPlayer then return end
        player.CharacterAdded:Connect(function(character)
            local highlight = Instance.new("Highlight", character)
            highlight.Name = "FallenHighlight"
            Highlights[player] = highlight
            Utils.UpdateHighlight(highlight, Settings)
            
            local billboard = Instance.new("BillboardGui", character)
            billboard.Name = "FallenESP"
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
        end)
        if player.Character then 
            -- Reuse logic for current character
            local character = player.Character
            local highlight = character:FindFirstChild("FallenHighlight") or Instance.new("Highlight", character)
            highlight.Name = "FallenHighlight"
            Highlights[player] = highlight
            Utils.UpdateHighlight(highlight, Settings)
            
            local billboard = character:FindFirstChild("FallenESP") or Instance.new("BillboardGui", character)
            billboard.Name = "FallenESP"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.Adornee = character:FindFirstChild("Head") or character.PrimaryPart
            billboard.AlwaysOnTop = true
            
            local label = billboard:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel", billboard)
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 1, 0)
            label.TextColor3 = Settings.ESPColor
            ESPGuis[player] = label
        end
    end

    local function ApplyNPCVisuals(model)
        if not model or NPCVisuals[model] then return end
        local head = model:FindFirstChild("Head") or model:FindFirstChild("Eye") or model:FindFirstChildWhichIsA("BasePart")
        if not head then return end

        -- Auto-add to KnownNPCs if new
        local isKnown = false
        for _, name in pairs(Settings.KnownNPCs) do if name == model.Name then isKnown = true break end end
        if not isKnown then 
            table.insert(Settings.KnownNPCs, model.Name)
            Settings.NPCFilters[model.Name] = true -- ENABLE BY DEFAULT
            UpdateNPCToggles()
        end


        local billboard = Instance.new("BillboardGui", model)
        billboard.Name = "FallenNPCESP"
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

    -- Update Loops
    RunService.RenderStepped:Connect(function()
        local mousePos = LocalPlayer:GetMouse()
        local center = Vector2.new(mousePos.X, mousePos.Y + 36)

        -- FOV Circle
        if FOVCircle then
            FOVCircle.Position = center
            FOVCircle.Radius = Settings.FOVSize
            FOVCircle.Visible = Settings.ShowFOV
            FOVCircle.Color = Settings.FOVColor
        end

        -- Crosshair
        if CrosshairLines then
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
        end

        -- Player ESP Update
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

        -- NPC ESP Update
        for model, label in pairs(NPCVisuals) do
            local isFiltered = Settings.NPCFilters[model.Name] == true
            if model.Parent and Settings.NPCESP and isFiltered then
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

    -- Inits
    UpdateNPCToggles()
    for _, player in pairs(Players:GetPlayers()) do ApplyPlayerVisuals(player) end

    Players.PlayerAdded:Connect(ApplyPlayerVisuals)

    -- Initial NPC Scan
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
