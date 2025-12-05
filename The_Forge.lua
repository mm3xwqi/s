-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "The Forge4",
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

-- Function to get all Models inside SpawnLocations
local function getFarmModels()
    local farmData = {}
    print("=== Searching for Models inside SpawnLocations ===")
    
    -- Define paths to check
    local paths = {
        "Island1CaveStart",
        "Island1CaveMid", 
        "Island1CaveDeep",
        "Roof"
    }
    
    -- Check if Rocks folder exists
    if not workspace:FindFirstChild("Rocks") then
        warn("❌ Rocks folder not found in workspace!")
        return farmData
    end
    
    local rocksFolder = workspace.Rocks
    
    for _, locationName in ipairs(paths) do
        print("\n🔍 Checking location:", locationName)
        local locationFolder = rocksFolder:FindFirstChild(locationName)
        
        if locationFolder then
            print("   ✓ Folder found")
            
            -- Check EVERY item in the location folder
            for _, item in ipairs(locationFolder:GetChildren()) do
                print("   • Checking:", item.Name, "(" .. item.ClassName .. ")")
                
                -- If it's a Model, check for SpawnLocation
                if item:IsA("Model") then
                    local spawnLocation = item:FindFirstChild("SpawnLocation")
                    if spawnLocation then
                        print("     ✓ Found SpawnLocation in", item.Name)
                        
                        -- Now check what's INSIDE the SpawnLocation
                        print("     📦 Checking contents of SpawnLocation...")
                        
                        -- Check ALL children inside SpawnLocation
                        for _, child in ipairs(spawnLocation:GetChildren()) do
                            print("       - " .. child.Name .. " (" .. child.ClassName .. ")")
                            
                            -- If we find a Model inside SpawnLocation
                            if child:IsA("Model") then
                                print("       🎯 Found Model inside SpawnLocation:", child.Name)
                                
                                -- Try to find a BasePart to tween to
                                local targetPart = child.PrimaryPart
                                if not targetPart then
                                    -- Look for ANY BasePart in the model
                                    for _, part in ipairs(child:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            targetPart = part
                                            break
                                        end
                                    end
                                end
                                
                                if targetPart then
                                    table.insert(farmData, {
                                        DisplayName = child.Name .. " [" .. locationName .. "]",
                                        ModelName = child.Name,
                                        LocationName = locationName,
                                        ParentModel = item.Name,
                                        TargetPart = targetPart,
                                        FullModel = child
                                    })
                                    print("       ✅ Added to farm list:", child.Name)
                                else
                                    print("       ⚠️ Model has no BasePart to tween to")
                                end
                            end
                        end
                    else
                        print("     ❌ No SpawnLocation in this model")
                    end
                end
            end
        else
            print("   ❌ Folder not found:", locationName)
        end
    end
    
    -- If no models found inside SpawnLocations, try another approach
    if #farmData == 0 then
        print("\n🔍 No models found inside SpawnLocations. Trying alternative search...")
        
        for _, locationName in ipairs(paths) do
            local locationFolder = rocksFolder:FindFirstChild(locationName)
            if locationFolder then
                -- Look for Models named "Pebble" or similar
                for _, model in ipairs(locationFolder:GetChildren()) do
                    if model:IsA("Model") and (model.Name:lower():find("pebble") or model.Name:lower():find("rock") or model.Name:lower():find("stone")) then
                        print("   • Found potential model:", model.Name)
                        
                        -- Check if this model has any BasePart
                        local targetPart = model.PrimaryPart
                        if not targetPart then
                            for _, part in ipairs(model:GetChildren()) do
                                if part:IsA("BasePart") then
                                    targetPart = part
                                    break
                                end
                            end
                        end
                        
                        if targetPart then
                            table.insert(farmData, {
                                DisplayName = model.Name .. " [" .. locationName .. "]",
                                ModelName = model.Name,
                                LocationName = locationName,
                                ParentModel = model.Name,
                                TargetPart = targetPart,
                                FullModel = model
                            })
                            print("   ✅ Added model to list:", model.Name)
                        end
                    end
                end
            end
        end
    end
    
    print("\n=== Search Complete ===")
    print("Found " .. #farmData .. " farm targets total")
    for i, data in ipairs(farmData) do
        print(i .. ". " .. data.DisplayName .. " (Part: " .. data.TargetPart.Name .. ")")
    end
    
    return farmData
end

-- Function to get target by display name
local function getFarmTargetByName(displayName)
    local farmData = getFarmModels()
    
    for _, data in ipairs(farmData) do
        if data.DisplayName == displayName then
            return data.TargetPart
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

-- Tween function to farm target
local function tweenToTarget(displayName)
    if not displayName or displayName == "" then 
        warn("No farm target selected!")
        return 
    end
    
    print("🔧 Attempting to tween to:", displayName)
    
    local targetPart = getFarmTargetByName(displayName)
    if not targetPart then 
        warn("❌ Target not found for:", displayName)
        return 
    end
    
    if not targetPart:IsA("BasePart") then
        warn("❌ Target is not a BasePart:", targetPart.ClassName)
        return
    end
    
    print("📍 Tweening to position:", targetPart.Position)
    
    -- Enable noclip during tween if setting is on
    if noclipEnabled then
        print("🛡️ Enabling noclip...")
        enableNoclip()
    end
    
    -- Create tween info
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
    
    print("🚀 Creating tween (Duration: " .. string.format("%.2f", duration) .. "s)")
    
    -- Create tween to the target
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetPart.CFrame})
    tween:Play()
    
    -- Wait for tween to complete
    local success, errorMsg = pcall(function()
        tween.Completed:Wait()
    end)
    
    if success then
        print("✅ Tween completed successfully")
        -- Activate tool
        local toolSuccess, toolError = pcall(function()
            toolRemote:InvokeServer("Pickaxe")
        end)
        
        if toolSuccess then
            print("✅ Pickaxe activated")
        else
            warn("❌ Failed to activate pickaxe:", toolError)
        end
    else
        warn("❌ Tween failed:", errorMsg)
    end
    
    -- Disable noclip
    if noclipEnabled then
        print("🛡️ Disabling noclip...")
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
            print("\n🔄 Auto Farm cycle...")
            pcall(function()
                tweenToTarget(selectedFarm)
            end)
            task.wait(0.5) -- Delay between cycles
        end
        print("⏹️ Auto Farm stopped")
    end)
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Get initial farm models
    local initialFarmModels = getFarmModels()
    local displayNames = {}
    
    for _, data in ipairs(initialFarmModels) do
        table.insert(displayNames, data.DisplayName)
    end
    
    -- Create dropdown
    if #displayNames > 0 then
        MainTab:Dropdown({
            Title = "Select Farm",
            Desc = "Choose a model to farm",
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
            Desc = "No models found",
            List = {"No farm targets found"},
            Value = "No farm targets found",
            Callback = function() end
        })
        selectedFarm = ""
    end
    
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
            print("🎚️ Tween Speed:", val)
        end
    })
    
    -- Noclip Toggle
    MainTab:Toggle({
        Title = "Noclip during Tween",
        Desc = "Enable noclip while moving",
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
        Desc = "Enable/Disable farming",
        Value = false,
        Callback = function(v)
            autoFarmEnabled = v
            if v then
                if selectedFarm == "" or selectedFarm == "No farm targets found" then
                    Window:Notify({
                        Title = "Error",
                        Desc = "Select a farm target first!",
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
        Desc = "Test teleport to selected",
        Callback = function()
            if selectedFarm == "" or selectedFarm == "No farm targets found" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Select a farm target first!",
                    Time = 3
                })
                return
            end
            
            pcall(function()
                tweenToTarget(selectedFarm)
                Window:Notify({
                    Title = "Test",
                    Desc = "Teleported to: " .. selectedFarm,
                    Time = 3
                })
            end)
        end
    })
    
    -- Debug Button
    MainTab:Button({
        Title = "Debug Structure",
        Desc = "Print detailed structure info",
        Callback = function()
            print("\n=== DETAILED STRUCTURE DEBUG ===")
            
            if not workspace:FindFirstChild("Rocks") then
                print("❌ No Rocks folder!")
                return
            end
            
            local rocks = workspace.Rocks
            print("Rocks folder contents:")
            
            for _, location in ipairs(rocks:GetChildren()) do
                print("\n📍 " .. location.Name .. " (" .. location.ClassName .. "):")
                
                for _, item in ipairs(location:GetChildren()) do
                    print("  ├─ " .. item.Name .. " (" .. item.ClassName .. ")")
                    
                    if item:IsA("Model") then
                        -- Check for SpawnLocation
                        local spawn = item:FindFirstChild("SpawnLocation")
                        if spawn then
                            print("  │  └─ SpawnLocation (" .. spawn.ClassName .. ")")
                            
                            -- List contents of SpawnLocation
                            if #spawn:GetChildren() == 0 then
                                print("       (empty)")
                            else
                                for _, child in ipairs(spawn:GetChildren()) do
                                    print("       ├─ " .. child.Name .. " (" .. child.ClassName .. ")")
                                    
                                    -- If child is a Model, list its parts
                                    if child:IsA("Model") then
                                        for _, part in ipairs(child:GetChildren()) do
                                            if part:IsA("BasePart") then
                                                print("       │  └─ " .. part.Name .. " (" .. part.ClassName .. ")")
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            print("\n=== END DEBUG ===")
            Window:Notify({
                Title = "Debug Complete",
                Desc = "Check console (F9) for details",
                Time = 3
            })
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

-- Initial load
local farmModels = getFarmModels()
if #farmModels > 0 then
    Window:Notify({
        Title = "Auto Farm Ready",
        Desc = "Found " .. #farmModels .. " targets",
        Time = 4
    })
else
    Window:Notify({
        Title = "No Targets",
        Desc = "Click Debug Structure to investigate",
        Time = 5
    })
end

print("\n✅ x2zu Auto Farm Script Loaded")
