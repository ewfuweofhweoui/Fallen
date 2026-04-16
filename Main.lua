-- [[ Fallen | Modular Main ]]
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(5) -- Safety delay to ensure NPCs and Ships are spawned

local BaseURL = "https://raw.githubusercontent.com/ewfuweofhweoui/Fallen/main/" 

-- Clear stale test hooks for a clean start
if getgenv().FallenLocalLoad and not _G.FallenLocalForce then
    getgenv().FallenLocalLoad = nil
end

-- Super Noop object: Can be called or indexed infinitely without crashing
local SuperNoop = setmetatable({}, {
    __call = function(self) return self end,
    __index = function(self) return self end
})

local function load(path)
    local function notify(title, msg)
        pcall(function()
            Window:Notification({
                Title = title,
                Content = msg,
                Duration = 5
            })
        end)
    end

    if getgenv().FallenLocalLoad then
        local res = getgenv().FallenLocalLoad(path)
        return type(res) == "function" and res or SuperNoop
    end
    local success, content = pcall(game.HttpGet, game, BaseURL .. path)
    if not success or not content or content == "" or content:find("404") then 
        warn("Fallen: Missing module -> " .. path) 
        notify("Module Error", "Missing: " .. path)
        return SuperNoop
    end
    local func, err = loadstring(content)
    if not func then
        warn("Fallen: Syntax error in " .. path .. " | " .. tostring(err))
        notify("Syntax Error", path .. " failed to parse.")
        return SuperNoop
    end
    local status, result = pcall(func)
    if not status then
        warn("Fallen: Runtime error in " .. path .. " | " .. tostring(result))
        notify("Runtime Error", path .. " failed to execute.")
        return SuperNoop
    end
    return type(result) == "function" and result or SuperNoop
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

-- [[ Logic Loops ]]
-- [[ Load Core ]]
local Settings = load("src/Settings.lua")
local Utils = load("src/Utils.lua")
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- [[ UI Setup ]]
local Window = Luna:CreateWindow({
    Name = "Fallen | Visuals",
    Subtitle = "by Antigravity",
    LogoID = "11384025064",
    LoadingEnabled = true,
    LoadingTitle = "Fallen Elite",
    LoadingSubtitle = "by Antigravity",
    ConfigSettings = {
        RootFolder = "Fallen",
        ConfigFolder = "ModularConfig"
    },
    KeySystem = true,
    KeySettings = {
        Title = "Fallen Elite | Authentication",
        Subtitle = "Key System",
        Note = "Enter your key to continue.",
        SaveKey = true,
        Key = {"9XK2-7BQM-4LRT-8ZWP"},
        SecondAction = {
            Enabled = true,
            Type = "Discord",
            Parameter = "dkFrq5g9"
        }
    }
})

-- [[ Initialize Tabs ]]
local CombatTab = Window:CreateTab({Name = "Combat", Icon = "gavel", ImageSource = "Material", ShowTitle = true})
local VisualsTab = Window:CreateTab({Name = "Visuals", Icon = "visibility", ImageSource = "Material", ShowTitle = true})
local MovementTab = Window:CreateTab({Name = "Movement", Icon = "directions_run", ImageSource = "Material", ShowTitle = true})
local WorldTab = Window:CreateTab({Name = "World", Icon = "public", ImageSource = "Material", ShowTitle = true})
local ShipTab = Window:CreateTab({Name = "Ship", Icon = "anchor", ImageSource = "Material", ShowTitle = true})

-- [[ Home Tab ]]
Window:CreateHomeTab({
    Icon = 1,
    SupportedExecutors = {"Xeno", "Vega X", "Delta", "Nihon", "Fluxus", "Hydrogen"},
    DiscordInvite = "dkFrq5g9"
})

-- [[ Drawing Visuals ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOVSize or 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Settings.FOVColor or Color3.fromRGB(255, 255, 255)
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

Window:LoadConfiguration()
print("Fallen: Modular Version Initialized.")
