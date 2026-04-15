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
    TPSpeed = 50,
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
    -- UI Visuals
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
    NPCFilters = {
        ["VikingSkeletonBoss"] = true,
        ["SkeletonTutorial"] = true,
        ["SkeletonTutorialBoss"] = true,
        ["RockMonsterBoss"] = true,
        ["Dungeon1Boss"] = true,
        ["SkeletonBoss"] = true
    },
    KnownNPCs = { "VikingSkeletonBoss", "SkeletonTutorial", "SkeletonTutorialBoss", "RockMonsterBoss", "Dungeon1Boss", "SkeletonBoss" },
}

return Settings
