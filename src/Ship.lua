local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

return function(ShipTab, Settings, Utils, ShipVisuals, SHIP_TYPES)
    ShipTab:CreateSection("Mobility")
    ShipTab:CreateToggle({Name = "Enable Ship Speed", CurrentValue = false, Description = "Boosts your ship's speed (Hold F)", Callback = function(v) Settings.ShipSpeed = v end})
    ShipTab:CreateSlider({Name = "Speed Multiplier", Range = {1, 5}, Increment = 0.1, CurrentValue = 1, Description = "Speed multiplier for ship boost", Callback = function(v) Settings.ShipMultiplier = v end})
    
    ShipTab:CreateSection("Visuals")
    ShipTab:CreateToggle({Name = "Show Ship ESP", CurrentValue = false, Description = "Shows ESP for nearby ships", Callback = function(v) 
        Settings.ShowShipESP = v 
        for _, ship in pairs(ShipVisuals) do ship.label.Visible = v end
    end})
    ShipTab:CreateColorPicker({Name = "Boat Text Color", Color = Settings.ShipColor, Description = "Color of the ship ESP labels", Callback = function(v) Settings.ShipColor = v end})

    local function ApplyShipVisuals(model)
        if not model or not model.Parent or ShipVisuals[model] then return end
        local displayName = SHIP_TYPES[model.Name] or "Boat"
        local targetPart = model:FindFirstChild("MainHull") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        
        if not targetPart then return end
        
        local billboard = Instance.new("BillboardGui", model)
        billboard.Name = "FallenShipESP"
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

    -- Logic Loop
    RunService.RenderStepped:Connect(function()
        -- Ship Speed
        if Settings.ShipSpeed and UserInputService:IsKeyDown(Enum.KeyCode.F) then
            local ship = Utils.GetMyShip(ShipVisuals, SHIP_TYPES)
            if ship then
                local pivot = ship:GetPivot()
                local movePart = ship:FindFirstChild("MainHull") or ship:FindFirstChild("Hull") or ship.PrimaryPart or ship:FindFirstChildWhichIsA("BasePart")
                local moveDir = movePart and movePart.CFrame.LookVector or pivot.LookVector
                
                -- [[ Diagnostic ]]
                -- warn("Fallen: Boosting ship " .. ship.Name .. " at multiplier " .. tostring(Settings.ShipMultiplier))
                
                ship:PivotTo(pivot + (moveDir * (Settings.ShipMultiplier * 0.5)))
            else
                -- [[ Diagnostic ]]
                -- warn("Fallen: Ship Speed active but no ship found under player.")
            end
        end

        -- Ship ESP Update
        for model, data in pairs(ShipVisuals) do
            if model.Parent and Settings.ShowShipESP then
                local lp = game:GetService("Players").LocalPlayer
                if lp.Character then
                    local dist = math.floor((model:GetPivot().Position - lp.Character:GetPivot().Position).Magnitude)
                    data.label.Text = string.format("%s\n[%d studs]", data.displayName, dist)
                end
                data.label.Visible = true
                data.label.TextColor3 = Settings.ShipColor
            else data.label.Visible = false end
        end
    end)

    -- Detect Ships
    for _, ship in pairs(CollectionService:GetTagged("Ship")) do ApplyShipVisuals(ship) end
    local shipFolder = workspace:FindFirstChild("Ships")
    if shipFolder then
        for _, ship in pairs(shipFolder:GetChildren()) do ApplyShipVisuals(ship) end
        shipFolder.ChildAdded:Connect(ApplyShipVisuals)
    end
    CollectionService:GetInstanceAddedSignal("Ship"):Connect(ApplyShipVisuals)
end
