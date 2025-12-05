-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "Mwqq",
    Desc = "The Forge",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "x2zu"
    }
})

-- Variables
local tweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local autoFarmEnabled = false
local selectedFarm = ""
local tweenSpeed = 50
local noclipEnabled = false
local noclipConnection = nil

-- Remote setup
local toolRemote = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")

-- Function to get farm locations
local function getFarmLocations()
    local locations = {}
    
    -- Check Island1CaveStart
    local island1Start = workspace.Rocks:FindFirstChild("Island1CaveStart")
    if island1Start then
        for _, model in ipairs(island1Start:GetChildren()) do
            if model:IsA("Model") then
                local spawnLocation = model:FindFirstChild("SpawnLocation")
                if spawnLocation and spawnLocation:IsA("BasePart") then
                    table.insert(locations, {
                        Name = model.Name,
                        DisplayName = model.Name .. " (Island1 Start)",
                        Location = spawnLocation
                    })
                end
            end
        end
    end
    
    -- Check Island1CaveMid
    local island1Mid = workspace.Rocks:FindFirstChild("Island1CaveMid")
    if island1Mid then
        for _, model in ipairs(island1Mid:GetChildren()) do
            if model:IsA("Model") then
                local spawnLocation = model:FindFirstChild("SpawnLocation")
                if spawnLocation and spawnLocation:IsA("BasePart") then
                    table.insert(locations, {
                        Name = model.Name,
                        DisplayName = model.Name .. " (Island1 Mid)",
                        Location = spawnLocation
                    })
                end
            end
        end
    end
    
    -- Check Island1CaveDeep
    local island1Deep = workspace.Rocks:FindFirstChild("Island1CaveDeep")
    if island1Deep then
        for _, model in ipairs(island1Deep:GetChildren()) do
            if model:IsA("Model") then
                local spawnLocation = model:FindFirstChild("SpawnLocation")
                if spawnLocation and spawnLocation:IsA("BasePart") then
                    table.insert(locations, {
                        Name = model.Name,
                        DisplayName = model.Name .. " (Island1 Deep)",
                        Location = spawnLocation
                    })
                end
            end
        end
    end
    
    -- Check Roof
    local roof = workspace.Rocks:FindFirstChild("Roof")
    if roof then
        for _, model in ipairs(roof:GetChildren()) do
            if model:IsA("Model") then
                local spawnLocation = model:FindFirstChild("SpawnLocation")
                if spawnLocation and spawnLocation:IsA("BasePart") then
                    table.insert(locations, {
                        Name = model.Name,
                        DisplayName = model.Name .. " (Roof)",
                        Location = spawnLocation
                    })
                end
            end
        end
    end
    
    return locations
end

-- Get all available farm locations
local farmLocations = getFarmLocations()

-- Noclip functions
local function enableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if character and noclipEnabled then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Tween function with noclip
local function tweenToLocation(location)
    if not location or not location:IsA("BasePart") then return end
    
    -- Enable noclip during tween if setting is on
    local wasNoclipEnabled = noclipEnabled
    if noclipEnabled then
        enableNoclip()
    end
    
    -- Create tween info
    local distance = (humanoidRootPart.Position - location.Position).Magnitude
    local duration = distance / tweenSpeed
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    -- Create tween
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = location.CFrame})
    tween:Play()
    
    -- Wait for tween to complete
    local success, errorMsg = pcall(function()
        tween.Completed:Wait()
    end)
    
    -- Activate tool
    if success then
        toolRemote:InvokeServer("Pickaxe")
    end
    
    -- Disable noclip after tween if it wasn't enabled before
    if noclipEnabled and not wasNoclipEnabled then
        disableNoclip()
    end
    
    -- Small delay before returning
    task.wait(0.5)
end

-- Auto farm loop
local autoFarmThread
local function startAutoFarm()
    if autoFarmThread then
        task.cancel(autoFarmThread)
        autoFarmThread = nil
    end
    
    autoFarmThread = task.spawn(function()
        while autoFarmEnabled and selectedFarm ~= "" do
            -- Find the selected location
            local targetLocation = nil
            for _, locationData in ipairs(farmLocations) do
                if locationData.DisplayName == selectedFarm then
                    targetLocation = locationData.Location
                    break
                end
            end
            
            if targetLocation then
                pcall(function()
                    tweenToLocation(targetLocation)
                end)
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "Selected location not found!",
                    Time = 3
                })
                autoFarmEnabled = false
                break
            end
            task.wait(0.1) -- Small delay between cycles
        end
    end)
end

-- Function to refresh farm locations
local function refreshFarmLocations()
    farmLocations = getFarmLocations()
    
    -- Update dropdown list
    local locationNames = {}
    for _, locationData in ipairs(farmLocations) do
        table.insert(locationNames, locationData.DisplayName)
    end
    
    return locationNames
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Refresh Button
    MainTab:Button({
        Title = "Refresh Locations",
        Desc = "Update available farm locations",
        Callback = function()
            local locations = refreshFarmLocations()
            if #locations == 0 then
                Window:Notify({
                    Title = "Info",
                    Desc = "No farm locations found with SpawnLocation",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Refreshed",
                    Desc = "Found " .. #locations .. " locations",
                    Time = 3
                })
            end
        end
    })
    
    -- Farm Selection Dropdown
    local farmDropdown
    local function updateDropdown()
        local locations = refreshFarmLocations()
        if farmDropdown then
            farmDropdown:UpdateList(locations)
        else
            farmDropdown = MainTab:Dropdown({
                Title = "Select Farm",
                List = locations,
                Value = #locations > 0 and locations[1] or "No locations found",
                Callback = function(choice)
                    selectedFarm = choice
                    print("Selected Farm:", choice)
                end
            })
        end
    end
    
    -- Initial dropdown setup
    updateDropdown()
    
    -- Tween Speed Slider
    MainTab:Slider({
        Title = "Tween Speed",
        Desc = "Higher = faster movement",
        Min = 10,
        Max = 200,
        Rounding = 0,
        Value = 50,
        Callback = function(val)
            tweenSpeed = val
            print("Tween Speed set to:", val)
        end
    })
    
    -- Noclip Toggle
    MainTab:Toggle({
        Title = "Noclip during Tween",
        Desc = "Enable noclip while moving to target",
        Value = false,
        Callback = function(v)
            noclipEnabled = v
            if v then
                Window:Notify({
                    Title = "Noclip",
                    Desc = "Noclip will be active during tween",
                    Time = 3
                })
            else
                disableNoclip()
            end
            print("Noclip during Tween:", v)
        end
    })
    
    -- Auto Farm Toggle
    MainTab:Toggle({
        Title = "Auto Farm",
        Desc = "Enable/Disable automatic farming",
        Value = false,
        Callback = function(v)
            autoFarmEnabled = v
            if v then
                if selectedFarm == "" or selectedFarm == "No locations found" then
                    Window:Notify({
                        Title = "Error",
                        Desc = "Please select a farm location first!",
                        Time = 3
                    })
                    autoFarmEnabled = false
                    return
                end
                startAutoFarm()
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Started farming at: " .. selectedFarm,
                    Time = 3
                })
            else
                if autoFarmThread then
                    task.cancel(autoFarmThread)
                    autoFarmThread = nil
                end
                disableNoclip() -- Ensure noclip is disabled when stopping
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Stopped farming",
                    Time = 3
                })
            end
            print("Auto Farm:", v)
        end
    })
    
    -- Teleport Button (for testing)
    MainTab:Button({
        Title = "Teleport to Selected",
        Desc = "Teleport once to selected location",
        Callback = function()
            if selectedFarm == "" or selectedFarm == "No locations found" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Please select a farm location first!",
                    Time = 3
                })
                return
            end
            
            -- Find the selected location
            local targetLocation = nil
            for _, locationData in ipairs(farmLocations) do
                if locationData.DisplayName == selectedFarm then
                    targetLocation = locationData.Location
                    break
                end
            end
            
            if targetLocation then
                pcall(function()
                    tweenToLocation(targetLocation)
                    Window:Notify({
                        Title = "Teleport",
                        Desc = "Teleported to " .. selectedFarm,
                        Time = 3
                    })
                end)
            end
        end
    })
end

-- Character handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    repeat task.wait() until character:FindFirstChild("HumanoidRootPart")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- Re-enable noclip if it was on
    if noclipEnabled then
        enableNoclip()
    end
end)

-- Disable noclip when script stops
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    disableNoclip()
end)

-- Initial Notification
Window:Notify({
    Title = "Auto Farm Loaded",
    Desc = "Refresh locations, select one, and toggle Auto Farm to start!",
    Time = 4
})

-- Initial refresh
task.spawn(function()
    local locations = refreshFarmLocations()
    if #locations == 0 then
        Window:Notify({
            Title = "No Locations",
            Desc = "No SpawnLocation parts found. Click Refresh.",
            Time = 5
        })
    end
end)
