-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "The Forge5",
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

-- Define farm locations with their specific models
local farmLocations = {
    {
        Location = "CaveStart",
        ModelName = "Pebble",
        DisplayName = "Pebble [CaveStart]"
    },
    {
        Location = "CaveMid",
        ModelName = "Rock",
        DisplayName = "Rock [CaveMid]"
    },
    {
        Location = "CaveDeep",
        ModelName = "Boulder",
        DisplayName = "Boulder [CaveDeep]"
    },
    {
        Location = "Roof",
        ModelName = "Lucky Block",
        DisplayName = "Lucky Block [Roof]"
    }
}

-- Function to get farm targets
local function getFarmTargets()
    local targets = {}
    
    print("=== Searching for Farm Targets ===")
    
    -- Check if Rocks folder exists
    if not workspace:FindFirstChild("Rocks") then
        warn("❌ Rocks folder not found!")
        return targets
    end
    
    local rocksFolder = workspace.Rocks
    
    for _, farmData in ipairs(farmLocations) do
        local locationName = farmData.Location
        local expectedModelName = farmData.ModelName
        local displayName = farmData.DisplayName
        
        print("\n🔍 Checking:", locationName, "for model:", expectedModelName)
        
        local locationFolder = rocksFolder:FindFirstChild(locationName)
        if locationFolder then
            print("   ✓ Location folder found")
            
            -- Search through all models in this location
            local foundTarget = nil
            
            for _, model in ipairs(locationFolder:GetChildren()) do
                if model:IsA("Model") then
                    print("   • Checking model:", model.Name)
                    
                    -- Look for SpawnLocation
                    local spawnLocation = model:FindFirstChild("SpawnLocation")
                    if spawnLocation and spawnLocation:IsA("BasePart") then
                        print("     ✓ Found SpawnLocation")
                        
                        -- Look for the expected model inside SpawnLocation
                        local targetModel = spawnLocation:FindFirstChild(expectedModelName)
                        if targetModel and targetModel:IsA("Model") then
                            print("     🎯 Found target model:", expectedModelName)
                            
                            -- Find a BasePart to tween to
                            local targetPart = targetModel.PrimaryPart
                            if not targetPart then
                                -- Look for any BasePart in the model
                                for _, part in ipairs(targetModel:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        targetPart = part
                                        break
                                    end
                                end
                            end
                            
                            if targetPart then
                                foundTarget = {
                                    DisplayName = displayName,
                                    ModelName = expectedModelName,
                                    LocationName = locationName,
                                    TargetPart = targetPart,
                                    FullModel = targetModel
                                }
                                print("     ✅ Target part found:", targetPart.Name)
                                break
                            else
                                print("     ⚠️ Model has no BasePart")
                            end
                        else
                            print("     ❌ Model", expectedModelName, "not found in SpawnLocation")
                            -- List what's actually in the SpawnLocation
                            print("     📦 Contents of SpawnLocation:")
                            for _, child in ipairs(spawnLocation:GetChildren()) do
                                print("       -", child.Name, "(" .. child.ClassName .. ")")
                            end
                        end
                    end
                end
            end
            
            if foundTarget then
                table.insert(targets, foundTarget)
            else
                print("   ❌ Could not find target for", locationName)
            end
        else
            print("   ❌ Location folder not found:", locationName)
        end
    end
    
    print("\n=== Search Complete ===")
    print("Found " .. #targets .. " farm targets:")
    for i, target in ipairs(targets) do
        print(i .. ". " .. target.DisplayName .. " (Part: " .. target.TargetPart.Name .. ")")
    end
    
    return targets
end

-- Function to get target by display name
local function getTargetByDisplayName(displayName)
    local targets = getFarmTargets()
    
    for _, target in ipairs(targets) do
        if target.DisplayName == displayName then
            return target.TargetPart
        end
    end
    
    -- If not found, search specifically
    for _, farmData in ipairs(farmLocations) do
        if farmData.DisplayName == displayName then
            -- Try to find it manually
            if workspace:FindFirstChild("Rocks") then
                local rocksFolder = workspace.Rocks
                local locationFolder = rocksFolder:FindFirstChild(farmData.Location)
                
                if locationFolder then
                    for _, model in ipairs(locationFolder:GetChildren()) do
                        if model:IsA("Model") then
                            local spawnLocation = model:FindFirstChild("SpawnLocation")
                            if spawnLocation then
                                local targetModel = spawnLocation:FindFirstChild(farmData.ModelName)
                                if targetModel and targetModel:IsA("Model") then
                                    local targetPart = targetModel.PrimaryPart
                                    if not targetPart then
                                        for _, part in ipairs(targetModel:GetChildren()) do
                                            if part:IsA("BasePart") then
                                                return part
                                            end
                                        end
                                    end
                                    return targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

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

-- Tween function
local function tweenToTarget(displayName)
    if not displayName or displayName == "" then
        warn("❌ No target selected!")
        return
    end
    
    print("🔧 Tweening to:", displayName)
    
    local targetPart = getTargetByDisplayName(displayName)
    if not targetPart then
        warn("❌ Target not found:", displayName)
        return
    end
    
    if not targetPart:IsA("BasePart") then
        warn("❌ Target is not a BasePart")
        return
    end
    
    print("📍 Target position:", targetPart.Position)
    print("📏 Distance:", (humanoidRootPart.Position - targetPart.Position).Magnitude)
    
    -- Enable noclip if setting is on
    if noclipEnabled then
        enableNoclip()
    end
    
    -- Create tween
    local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
    local duration = distance / tweenSpeed
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetPart.CFrame})
    tween:Play()
    
    -- Wait for completion
    local success = pcall(function()
        tween.Completed:Wait()
    end)
    
    if success then
        print("✅ Tween complete")
        -- Use pickaxe
        local toolSuccess = pcall(function()
            toolRemote:InvokeServer("Pickaxe")
        end)
        
        if toolSuccess then
            print("✅ Pickaxe used")
        else
            warn("❌ Failed to use pickaxe")
        end
    else
        warn("❌ Tween failed")
    end
    
    -- Disable noclip
    if noclipEnabled then
        disableNoclip()
    end
    
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
            pcall(function()
                tweenToTarget(selectedFarm)
            end)
            task.wait(0.5)
        end
    end)
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Get available targets
    local availableTargets = getFarmTargets()
    local displayNames = {}
    
    for _, target in ipairs(availableTargets) do
        table.insert(displayNames, target.DisplayName)
    end
    
    -- If no targets found, use default list
    if #displayNames == 0 then
        for _, farmData in ipairs(farmLocations) do
            table.insert(displayNames, farmData.DisplayName)
        end
    end
    
    -- Create dropdown
    if #displayNames > 0 then
        MainTab:Dropdown({
            Title = "Select Farm",
            Desc = "Choose location to farm",
            List = displayNames,
            Value = displayNames[1],
            Callback = function(choice)
                selectedFarm = choice
                print("📌 Selected:", choice)
            end
        })
        selectedFarm = displayNames[1]
    else
        MainTab:Dropdown({
            Title = "Select Farm",
            Desc = "No targets available",
            List = {"No targets found"},
            Value = "No targets found",
            Callback = function() end
        })
        selectedFarm = ""
    end
    
    -- Tween Speed Slider
    MainTab:Slider({
        Title = "Tween Speed",
        Desc = "Speed of movement (10-200)",
        Min = 10,
        Max = 200,
        Rounding = 0,
        Value = 50,
        Callback = function(val)
            tweenSpeed = val
            print("🎚️ Speed set to:", val)
        end
    })
    
    -- Noclip Toggle
    MainTab:Toggle({
        Title = "Noclip during Tween",
        Desc = "Pass through objects while moving",
        Value = false,
        Callback = function(v)
            noclipEnabled = v
            if v then
                Window:Notify({
                    Title = "Noclip",
                    Desc = "Noclip enabled for tween",
                    Time = 3
                })
            else
                disableNoclip()
            end
        end
    })
    
    -- Auto Farm Toggle
    MainTab:Toggle({
        Title = "Auto Farm",
        Desc = "Start/stop automatic farming",
        Value = false,
        Callback = function(v)
            autoFarmEnabled = v
            if v then
                if selectedFarm == "" or selectedFarm == "No targets found" then
                    Window:Notify({
                        Title = "Error",
                        Desc = "Select a farm location first!",
                        Time = 3
                    })
                    autoFarmEnabled = false
                    return
                end
                
                startAutoFarm()
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Started: " .. selectedFarm,
                    Time = 3
                })
            else
                if autoFarmThread then
                    task.cancel(autoFarmThread)
                    autoFarmThread = nil
                end
                disableNoclip()
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Stopped farming",
                    Time = 3
                })
            end
        end
    })
    
    -- Test Button
    MainTab:Button({
        Title = "Test Teleport",
        Desc = "Teleport to selected once",
        Callback = function()
            if selectedFarm == "" or selectedFarm == "No targets found" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Select a farm location first!",
                    Time = 3
                })
                return
            end
            
            pcall(function()
                tweenToTarget(selectedFarm)
                Window:Notify({
                    Title = "Teleport",
                    Desc = "Teleported to: " .. selectedFarm,
                    Time = 3
                })
            end)
        end
    })
    
    -- Refresh Button
    MainTab:Button({
        Title = "Refresh Targets",
        Desc = "Reload farm locations",
        Callback = function()
            local targets = getFarmTargets()
            
            if #targets > 0 then
                Window:Notify({
                    Title = "Refreshed",
                    Desc = "Found " .. #targets .. " farm targets",
                    Time = 3
                })
                print("✅ Refreshed targets")
            else
                Window:Notify({
                    Title = "No Targets",
                    Desc = "Could not find any farm targets",
                    Time = 3
                })
            end
        end
    })
    
    -- Info Button
    MainTab:Button({
        Title = "Farm Info",
        Desc = "Show available farm locations",
        Callback = function()
            local info = "Farm Locations:\n"
            for _, farmData in ipairs(farmLocations) do
                info = info .. "• " .. farmData.DisplayName .. "\n"
            end
            
            Window:Notify({
                Title = "Farm Locations",
                Desc = info,
                Time = 5
            })
            
            print("📋 Farm Locations:")
            for _, farmData in ipairs(farmLocations) do
                print("  • " .. farmData.DisplayName)
            end
        end
    })
end

-- Character handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    repeat task.wait() until character:FindFirstChild("HumanoidRootPart")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    print("🎭 Character loaded")
end)

-- Initial setup
local initialTargets = getFarmTargets()
if #initialTargets > 0 then
    Window:Notify({
        Title = "Auto Farm Ready",
        Desc = "Select a location and enable Auto Farm",
        Time = 4
    })
else
    Window:Notify({
        Title = "Farm Locations",
        Desc = "4 locations available. Use Test Teleport first.",
        Time = 5
    })
end

print("\n✅ x2zu Auto Farm Script Loaded")
print("📋 Available Farm Locations:")
for _, farmData in ipairs(farmLocations) do
    print("  • " .. farmData.DisplayName)
end
