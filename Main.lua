-- [[ Voyagers | Modular Main ]]
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(5) -- Safety delay to ensure NPCs and Ships are spawned

local BaseURL = "https://raw.githubusercontent.com/ewfuweofhweoui/Fallen/main/" 

local function load(path)
    local success, content = pcall(game.HttpGet, game, BaseURL .. path)
    if not success or not content or content == "" or content:find("404") then 
        warn("Voyagers: Failed to load " .. path) 
        return function() end -- Return empty function to prevent crash
    end
    local func, err = loadstring(content)
    if not func then
        warn("Voyagers: Syntax error in " .. path .. " | " .. tostring(err))
        return function() end
    end
    return func()
end

-- [[ Shared Data ]]
local NPCVisuals = {}
local ShipVisuals = {}
local ESPGuis = {}
local Highlights = {}
local SHIP_TYPES = {
    ["Brigantine"] = "Brigantine",
    ["TinySloop"] = "Sloop",
    ["SailBoat"] = "Sailboat"
}

-- [[ Load Core ]]
local Settings = load("src/Settings.lua")
local Utils = load("src/Utils.lua")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ UI Setup ]]
local Window = Rayfield:CreateWindow({
    Name = "Voyagers | Visuals (Modular)",
    LoadingTitle = "Voyagers Elite",
    LoadingSubtitle = "by Antigravity",
    ConfigurationSaving = { Enabled = true, FolderName = "Voyagers", FileName = "ModularConfig" },
    KeySystem = false,
})

-- [[ Initialize Tabs ]]
local CombatTab = Window:CreateTab("Combat", nil)
local VisualsTab = Window:CreateTab("Visuals", nil)
local MovementTab = Window:CreateTab("Movement", nil)
local WorldTab = Window:CreateTab("World", nil)
local ShipTab = Window:CreateTab("Ship", nil)

-- [[ Drawing Visuals ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVSize
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Settings.FOVColor
FOVCircle.Visible = false

local CannonAimCircle = Drawing.new("Circle")
CannonAimCircle.Thickness = 2
CannonAimCircle.NumSides = 32
CannonAimCircle.Radius = 15
CannonAimCircle.Filled = false
CannonAimCircle.Transparency = 1
CannonAimCircle.Color = Color3.fromRGB(255, 0, 0)
CannonAimCircle.Visible = false

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

-- [[ Load Features ]]
load("src/Combat.lua")(CombatTab, Settings, Utils, NPCVisuals, ShipVisuals, SHIP_TYPES, CannonAimCircle)
load("src/Visuals.lua")(VisualsTab, Settings, Utils, ESPGuis, NPCVisuals, ShipVisuals, SHIP_TYPES, Highlights, FOVCircle, CrosshairLines)
load("src/Movement.lua")(MovementTab, Settings, Utils)
load("src/World.lua")(WorldTab, Settings)
load("src/Ship.lua")(ShipTab, Settings, Utils, ShipVisuals, SHIP_TYPES)

Rayfield:LoadConfiguration()
print("Voyagers: Modular Version Initialized.")
