-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "The Forge3",
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
    print("=== Searching for SpawnLocations ===")
    
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
        print("\n🔍 Checking:", locationName)
        local locationFolder = rocksFolder:FindFirstChild(locationName)
        
        if locationFolder then
            print("   ✓ Folder found")
            
            -- Check each Model in the location folder
            for _, outerModel in ipairs(locationFolder:GetChildren()) do
                if outerModel:IsA("Model") then
                    print("   • Checking model:", outerModel.Name)
                    
                    -- Look for SpawnLocation inside this outer model
                    local spawnLocation = outerModel:FindFirstChild("SpawnLocation")
                    if spawnLocation then
                        print("     ✓ Found SpawnLocation")
                        
                        if spawnLocation:IsA("BasePart") then
                            print("     ✓ SpawnLocation is a BasePart")
                            
                            -- Now check what's INSIDE the SpawnLocation part
                            if #spawnLocation:GetChildren() == 0 then
                                print("     ℹ️ SpawnLocation is empty (no children)")
                            else
                                print("     📦 SpawnLocation has", #spawnLocation:GetChildren(), "children:")
                                
                                -- List all children
                                for _, child in ipairs(spawnLocation:GetChildren()) do
                                    print("       - " .. child.Name .. " (" .. child.ClassName .. ")")
                                end
                                
                                -- Look for Models inside SpawnLocation
                                for _, child in ipairs(spawnLocation:GetChildren()) do
                                    if child:IsA("Model") then
                                        print("     🎯 Found Model inside SpawnLocation:", child.Name)
                                        
                                        -- Find a part to tween to (PrimaryPart or any BasePart)
                                        local targetPart = child.PrimaryPart
                                        if not targetPart then
                                            -- Look for any BasePart in the model
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
                                                ParentModel = outerModel.Name,
                                                TargetPart = targetPart,
                                                FullModel = child
                                            })
                                            print("     ✅ Added to farm list:", child.Name)
                                        else
                                            print("     ⚠️ Model has no BasePart to tween to:", child.Name)
                                        end
                                    end
                                end
                            end
                        else
                            print("     ⚠️ SpawnLocation is not a BasePart (it's a " .. spawnLocation.ClassName .. ")")
                        end
                    else
                        print("     ❌ No SpawnLocation found in this model")
                    end
                end
            end
        else
            print("   ❌ Folder not found:", locationName)
        end
    end
    
    print("\n=== Search Complete ===")
    print("Found " .. #farmData .. " farm models total")
    for i, data in ipairs(farmData) do
        print(i .. ". " .. data.DisplayName)
    end
    
    return farmData
end

-- Function to get model by display name
local function getFarmModelByName(displayName)
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

-- Tween function to Model inside SpawnLocation
local function tweenToModel(displayName)
    if not displayName or displayName == "" then 
        warn("No farm model selected!")
        return 
    end
    
    print("🔧 Attempting to tween to:", displayName)
    
    local targetPart = getFarmModelByName(displayName)
    if not targetPart then 
        warn("❌ Target part not found for:", displayName)
        
        -- Try to find it again
        local farmData = getFarmModels()
        for _, data in ipairs(farmData) do
            if data.DisplayName == displayName then
                targetPart = data.TargetPart
                print("✅ Found target part on second search")
                break
            end
        end
        
        if not targetPart then
            warn("❌ Still not found after second search")
            return 
        end
    end
    
    if not targetPart:IsA("BasePart") then
        warn("❌ Target is not a BasePart:", targetPart.ClassName)
        return
    end
    
    print("📍 Tweening to position:", targetPart.Position)
    print("📏 Distance:", (humanoidRootPart.Position - targetPart.Position).Magnitude)
    
    -- Enable noclip during tween if setting is on
    local wasNoclipEnabled = noclipEnabled
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
    
    print("🚀 Creating tween (Duration: " .. duration .. "s, Speed: " .. tweenSpeed .. ")")
    
    -- Create tween to the part
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetPart.CFrame})
    tween:Play()
    
    -- Wait for tween to complete
    local success, errorMsg = pcall(function()
        tween.Completed:Wait()
    end)
    
    if success then
        print("✅ Tween completed successfully")
        -- Activate tool
        print("⚒️ Activating pickaxe...")
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
    
    -- Disable noclip after tween if it wasn't enabled before
    if noclipEnabled and not wasNoclipEnabled then
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
            print("\n🔄 Auto Farm cycle starting...")
            pcall(function()
                tweenToModel(selectedFarm)
            end)
            task.wait(0.5) -- Small delay between cycles
        end
        print("⏹️ Auto Farm stopped")
    end)
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Get initial farm models
    print("📋 Initializing farm models...")
    local initialFarmModels = getFarmModels()
    local displayNames = {}
    
    for _, data in ipairs(initialFarmModels) do
        table.insert(displayNames, data.DisplayName)
    end
    
    -- Create dropdown
    local farmDropdown
    if #displayNames > 0 then
        farmDropdown = MainTab:Dropdown({
            Title = "Select Farm",
            Desc = "Choose a model inside SpawnLocation",
            List = displayNames,
            Value = displayNames[1],
            Callback = function(choice)
                selectedFarm = choice
                print("📌 Selected Farm:", choice)
            end
        })
        selectedFarm = displayNames[1]
        print("✅ Dropdown created with", #displayNames, "options")
    else
        farmDropdown = MainTab:Dropdown({
            Title = "Select Farm",
            Desc = "No models found in SpawnLocations",
            List = {"No models found"},
            Value = "No models found",
            Callback = function() end
        })
        selectedFarm = ""
        print("⚠️ No farm models found")
    end
    
    -- Tween Speed Slider
    MainTab:Slider({
        Title = "Tween Speed",
        Desc = "Higher = faster movement (10-200)",
        Min = 10,
        Max = 200,
        Rounding = 0,
        Value = 50,
        Callback = function(val)
            tweenSpeed = val
            print("🎚️ Tween Speed set to:", val)
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
                print("🛡️ Noclip enabled")
            else
                disableNoclip()
                print("🛡️ Noclip disabled")
            end
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
                if selectedFarm == "" or selectedFarm == "No models found" then
                    Window:Notify({
                        Title = "Error",
                        Desc = "No farm model selected!",
                        Time = 3
                    })
                    autoFarmEnabled = false
                    print("❌ Cannot start Auto Farm: No model selected")
                    return
                end
                
                print("🚀 Starting Auto Farm for:", selectedFarm)
                startAutoFarm()
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Started farming: " .. selectedFarm,
                    Time = 3
                })
            else
                print("⏹️ Stopping Auto Farm...")
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
    
    -- Teleport Button
    MainTab:Button({
        Title = "Test Teleport",
        Desc = "Teleport once to test",
        Callback = function()
            if selectedFarm == "" or selectedFarm == "No models found" then
                Window:Notify({
                    Title = "Error",
                    Desc = "No farm model selected!",
                    Time = 3
                })
                print("❌ Cannot teleport: No model selected")
                return
            end
            
            print("🚀 Testing teleport to:", selectedFarm)
            pcall(function()
                tweenToModel(selectedFarm)
                Window:Notify({
                    Title = "Teleport",
                    Desc = "Teleported to: " .. selectedFarm,
                    Time = 3
                })
                print("✅ Teleport completed")
            end)
        end
    })
    
    -- Refresh Button
    MainTab:Button({
        Title = "Refresh List",
        Desc = "Refresh farm models list",
        Callback = function()
            print("🔄 Refreshing farm models list...")
            local farmModels = getFarmModels()
            
            if #farmModels > 0 then
                local newDisplayNames = {}
                for _, data in ipairs(farmModels) do
                    table.insert(newDisplayNames, data.DisplayName)
                end
                
                -- Check if current selection still exists
                local currentExists = false
                for _, name in ipairs(newDisplayNames) do
                    if name == selectedFarm then
                        currentExists = true
                        break
                    end
                end
                
                if not currentExists and #newDisplayNames > 0 then
                    selectedFarm = newDisplayNames[1]
                    Window:Notify({
                        Title = "Selection Updated",
                        Desc = "Found " .. #newDisplayNames .. " models. Reset to: " .. selectedFarm,
                        Time = 4
                    })
                    print("🔄 Selection reset to:", selectedFarm)
                else
                    Window:Notify({
                        Title = "Models Refreshed",
                        Desc = "Found " .. #newDisplayNames .. " models.",
                        Time = 3
                    })
                end
                print("✅ Found", #newDisplayNames, "models")
            else
                selectedFarm = ""
                Window:Notify({
                    Title = "No Models",
                    Desc = "No models found in SpawnLocations",
                    Time = 3
                })
                print("⚠️ No models found after refresh")
            end
        end
    })
    
    -- Structure Check Button
    MainTab:Button({
        Title = "Check Structure",
        Desc = "Check workspace structure for debugging",
        Callback = function()
            print("\n=== WORKSPACE STRUCTURE CHECK ===")
            
            if not workspace:FindFirstChild("Rocks") then
                print("❌ No 'Rocks' folder in workspace!")
                Window:Notify({
                    Title = "Structure Error",
                    Desc = "No 'Rocks' folder found in workspace!",
                    Time = 5
                })
                return
            end
            
            local rocks = workspace.Rocks
            print("✅ Found Rocks folder")
            print("Contents of Rocks folder:")
            
            for _, child in ipairs(rocks:GetChildren()) do
                print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
                
                if child:IsA("Folder") or child:IsA("Model") then
                    print("    Sub-contents of " .. child.Name .. ":")
                    for _, subChild in ipairs(child:GetChildren()) do
                        print("      - " .. subChild.Name .. " (" .. subChild.ClassName .. ")")
                        
                        -- Check for SpawnLocation
                        if subChild:IsA("Model") then
                            local spawn = subChild:FindFirstChild("SpawnLocation")
                            if spawn then
                                print("        ✓ Has SpawnLocation (" .. spawn.ClassName .. ")")
                                print("        Contents of SpawnLocation:")
                                if #spawn:GetChildren() == 0 then
                                    print("        (empty)")
                                else
                                    for _, spawnChild in ipairs(spawn:GetChildren()) do
                                        print("        - " .. spawnChild.Name .. " (" .. spawnChild.ClassName .. ")")
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            print("=== END STRUCTURE CHECK ===")
            Window:Notify({
                Title = "Structure Check",
                Desc = "Check console (F9) for detailed structure",
                Time = 4
            })
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
    print("🎭 Character loaded")
end)

-- Disable noclip when script stops
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    disableNoclip()
    print("🎭 Character removed, noclip disabled")
end)

-- Initial Notification
local farmModels = getFarmModels()
if #farmModels > 0 then
    Window:Notify({
        Title = "Auto Farm Loaded",
        Desc = "Found " .. #farmModels .. " farm models. Select one and enable Auto Farm.",
        Time = 4
    })
    print("✅ Script loaded successfully with", #farmModels, "farm models")
else
    Window:Notify({
        Title = "Setup Required",
        Desc = "No models found. Click 'Check Structure' to debug.",
        Time = 5
    })
    print("⚠️ Script loaded but no farm models found")
end

print("\n=== x2zu Auto Farm Script Loaded ===")
