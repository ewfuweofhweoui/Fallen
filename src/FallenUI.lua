local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local FallenUI = {}
FallenUI.__index = FallenUI

-- [[ Theme Configuration ]]
local Theme = {
    Main = Color3.fromRGB(15, 10, 25),
    Accent = Color3.fromRGB(130, 50, 255),
    Outline = Color3.fromRGB(60, 20, 100),
    Text = Color3.fromRGB(240, 240, 255),
    TextDim = Color3.fromRGB(180, 160, 200),
    Section = Color3.fromRGB(25, 15, 45),
    Item = Color3.fromRGB(35, 20, 60),
    ItemHover = Color3.fromRGB(45, 25, 75),
}

local function Create(class, properties, parent)
    local obj = Instance.new(class)
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    if parent then obj.Parent = parent end
    return obj
end

function FallenUI:CreateWindow(options)
    options = options or {}
    local Name = options.Name or "Fallen"
    
    local gui = Create("ScreenGui", {
        Name = "FallenUI",
        ResetOnSpawn = false,
        DisplayOrder = 100
    }, (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui")) or game:GetService("CoreGui"))

    local main = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 550, 0, 380),
        Position = UDim2.new(0.5, -275, 0.5, -190),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true -- Legacy draggable for simplicity
    }, gui)

    -- [[ Branding / TopBar ]]
    local topBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0
    }, main)

    Create("Frame", {
        Name = "Separator",
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0
    }, topBar)

    local title = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = Name,
        TextColor3 = Theme.Accent,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, topBar)

    -- [[ Star Background ]]
    local starContainer = Create("Frame", {
        Name = "StarContainer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 0
    }, main)

    for i = 1, 50 do
        local star = Create("Frame", {
            Name = "Star",
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            Size = UDim2.new(0, math.random(1, 2), 0, math.random(1, 2)),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = math.random(5, 8) / 10,
            BorderSizePixel = 0,
            ZIndex = 0
        }, starContainer)
        
        -- Subtle Twinkle
        task.spawn(function()
            while task.wait(math.random(2, 5)) do
                TweenService:Create(star, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
                task.wait(1)
                TweenService:Create(star, TweenInfo.new(1), {BackgroundTransparency = 0.5}):Play()
            end
        end)
    end

    -- [[ Navigation ]]
    local nav = Create("Frame", {
        Name = "Nav",
        Size = UDim2.new(0, 140, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = Theme.Main,
        BorderSizePixel = 0
    }, main)

    Create("Frame", {
        Name = "NavSeparator",
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0
    }, nav)

    local navList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -1, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, nav)

    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    }, navList)

    -- [[ Pages ]]
    local pages = Create("Frame", {
        Name = "Pages",
        Size = UDim2.new(1, -140, 1, -35),
        Position = UDim2.new(0, 140, 0, 35),
        BackgroundTransparency = 1
    }, main)

    local window = {
        GUI = gui,
        Main = main,
        NavList = navList,
        Pages = pages,
        Tabs = {},
        CurrentTab = nil
    }

    function window:CreateTab(name)
        local page = Create("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Outline,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, pages)

        Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        }, page)
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        }, page)

        local tabBtn = Create("TextButton", {
            Name = name .. "Tab",
            Size = UDim2.new(0, 120, 0, 30),
            BackgroundColor3 = Theme.Item,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 14
        }, navList)

        local tab = {
            Name = name,
            Page = page,
            Button = tabBtn
        }

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(window.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = Theme.Item
                t.Button.TextColor3 = Theme.TextDim
            end
            page.Visible = true
            tabBtn.BackgroundColor3 = Theme.Section
            tabBtn.TextColor3 = Theme.Accent
        end)

        if not window.CurrentTab then
            page.Visible = true
            tabBtn.BackgroundColor3 = Theme.Section
            tabBtn.TextColor3 = Theme.Accent
            window.CurrentTab = tab
        end

        table.insert(window.Tabs, tab)

        -- [[ Tab Methods ]]
        function tab:CreateSection(text)
            local secFrame = Create("Frame", {
                Size = UDim2.new(0, 380, 0, 25),
                BackgroundColor3 = Theme.Section,
                BorderSizePixel = 0
            }, page)
            Create("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text:upper(),
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            }, secFrame)
            
            -- Adjust CanvasSize
            page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 20)
        end

        function tab:CreateToggle(opts)
            local enabled = opts.CurrentValue or false
            local toggleFrame = Create("Frame", {
                Size = UDim2.new(0, 380, 0, 35),
                BackgroundColor3 = Theme.Item,
                BorderSizePixel = 0
            }, page)
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }, toggleFrame)
            
            local btn = Create("TextButton", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = enabled and Theme.Accent or Theme.Section,
                BorderSizePixel = 0,
                Text = ""
            }, toggleFrame)

            btn.MouseButton1Click:Connect(function()
                enabled = not enabled
                btn.BackgroundColor3 = enabled and Theme.Accent or Theme.Section
                opts.Callback(enabled)
            end)

            page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 20)
        end

        function tab:CreateSlider(opts)
            local val = opts.CurrentValue or opts.Range[1]
            local sliderFrame = Create("Frame", {
                Size = UDim2.new(0, 380, 0, 45),
                BackgroundColor3 = Theme.Item,
                BorderSizePixel = 0
            }, page)
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -10, 0, 25),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name .. ": " .. tostring(val),
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }, sliderFrame)

            local tray = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 4),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundColor3 = Theme.Section,
                BorderSizePixel = 0
            }, sliderFrame)
            
            local fill = Create("Frame", {
                Size = UDim2.new((val - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0
            }, tray)

            local dragging = false
            local function update()
                local mousePos = UserInputService:GetMouseLocation().X
                local trayPos = tray.AbsolutePosition.X
                local traySize = tray.AbsoluteSize.X
                local perc = math.clamp((mousePos - trayPos) / traySize, 0, 1)
                val = math.floor(opts.Range[1] + (opts.Range[2] - opts.Range[1]) * perc)
                if opts.Increment then
                    val = math.floor(val / opts.Increment + 0.5) * opts.Increment
                    perc = (val - opts.Range[1]) / (opts.Range[2] - opts.Range[1])
                end
                fill.Size = UDim2.new(perc, 0, 1, 0)
                label.Text = opts.Name .. ": " .. tostring(val)
                opts.Callback(val)
            end

            tray.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update() end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update() end
            end)

            page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 20)
        end

        function tab:CreateDropdown(opts)
            local dropdownFrame = Create("Frame", {
                Size = UDim2.new(0, 380, 0, 35),
                BackgroundColor3 = Theme.Item,
                BorderSizePixel = 0,
                ClipsDescendants = true
            }, page)
            local label = Create("TextLabel", {
                Size = UDim2.new(1, -40, 0, 35),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name .. ": " .. tostring(opts.CurrentValue or "None"),
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }, dropdownFrame)

            local arrow = Create("TextLabel", {
                Size = UDim2.new(0, 30, 0, 35),
                Position = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                Text = ">",
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.GothamBold,
                TextSize = 14
            }, dropdownFrame)

            local list = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 35),
                BackgroundColor3 = Theme.Section,
                BorderSizePixel = 0,
                Visible = false
            }, dropdownFrame)
            Create("UIListLayout", {}, list)

            local open = false
            local function toggle()
                open = not open
                list.Visible = open
                dropdownFrame.Size = UDim2.new(0, 380, 0, open and (35 + (#opts.Options * 25)) or 35)
                arrow.Rotation = open and 90 or 0
                page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 20)
            end

            local function updateOptions(newOptions)
                for _, child in pairs(list:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                opts.Options = newOptions
                for _, opt in pairs(opts.Options) do
                    local optBtn = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundColor3 = Theme.Section,
                        BorderSizePixel = 0,
                        Text = tostring(opt),
                        TextColor3 = Theme.TextDim,
                        Font = Enum.Font.Gotham,
                        TextSize = 12
                    }, list)
                    optBtn.MouseButton1Click:Connect(function()
                        label.Text = opts.Name .. ": " .. tostring(opt)
                        opts.Callback(opt)
                        toggle()
                    end)
                end
            end

            updateOptions(opts.Options)
            
            local clickBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
                Text = ""
            }, dropdownFrame)
            clickBtn.MouseButton1Click:Connect(toggle)

            return {Set = updateOptions}
        end

        function tab:CreateColorPicker(opts)
            -- Simplified ColorPicker: Toggles through a few presets or just stays static for now
            local pickerFrame = Create("Frame", {
                Size = UDim2.new(0, 380, 0, 35),
                BackgroundColor3 = Theme.Item,
                BorderSizePixel = 0
            }, page)
            Create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }, pickerFrame)

            local colorBox = Create("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = opts.Color or Color3.new(1, 1, 1),
                BorderSizePixel = 1,
                BorderColor3 = Theme.Outline
            }, pickerFrame)

            -- Just a notification that color picker is static for now or could implement a small popup
            page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 20)
        end

        return tab
    end

    function window:LoadConfiguration()
        -- Stub for compatibility with Rayfield:LoadConfiguration()
    end

    return window
end

return FallenUI
