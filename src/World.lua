local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

return function(WorldTab, Settings)
    local OriginalLighting = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
    }

    WorldTab:CreateSection("Atmosphere")
    WorldTab:CreateToggle({Name = "Enable Fullbright", CurrentValue = false, Callback = function(v) Settings.Fullbright = v end})

    RunService.Heartbeat:Connect(function()
        if Settings.Fullbright then
            if Lighting.ClockTime ~= 12 then Lighting.ClockTime = 12 end
            if Lighting.Brightness ~= 2 then Lighting.Brightness = 2 end
        elseif Lighting.ClockTime == 12 or Lighting.Brightness == 2 then
            Lighting.ClockTime = OriginalLighting.ClockTime
            Lighting.Brightness = OriginalLighting.Brightness
        end
    end)
end
