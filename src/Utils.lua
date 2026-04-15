local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Utils = {}

function Utils.GetMyShip(ShipVisuals, SHIP_TYPES)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    local function isShip(model)
        if not model or not model:IsA("Model") then return false end
        if ShipVisuals[model] or model:FindFirstChild("MainHull") or model:FindFirstChild("Hull") then return true end
        local name = model.Name:lower()
        local shipKeywords = {"ship", "boat", "hull", "sloop", "brig", "galleon", "brigantine", "frigate", "raft"}
        for _, keyword in ipairs(shipKeywords) do
            if name:find(keyword) then return true end
        end
        for sName, _ in pairs(SHIP_TYPES) do
            if name:find(sName:lower()) then return true end
        end
        return false
    end

    -- Strategy 1: If in a seat, find the seat's model
    if hum and hum.SeatPart then
        local current = hum.SeatPart
        while current and current ~= workspace do
            if isShip(current) then return current end
            current = current.Parent
        end
    end

    -- Strategy 2: If standing on the ship, look up from the char
    local current = char.Parent
    while current and current ~= workspace do
        if isShip(current) then return current end
        current = current.Parent
    end

    -- Strategy 3: Raycast down (if standing on it but not parented)
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(root.Position, Vector3.new(0, -20, 0), params)
        if result and result.Instance then
            local p = result.Instance
            while p and p ~= workspace do
                if isShip(p) then return p end
                p = p.Parent
            end
        end
    end

    return nil
end

function Utils.GetClosestTarget(Settings, NPCVisuals)
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

    -- Check NPCs
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

function Utils.UpdateHighlight(highlight, Settings)
    if not highlight then return end
    highlight.Enabled = Settings.Chams
    highlight.FillColor = Settings.FillColor
    highlight.OutlineColor = Settings.OutlineColor
    highlight.FillTransparency = Settings.FillTransparency
    highlight.OutlineTransparency = Settings.OutlineTransparency
end

function Utils.GetBestPart(model)
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

return Utils
