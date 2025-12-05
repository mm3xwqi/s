-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "The Forge7",
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

-- Define all locations to search
local SEARCH_LOCATIONS = {
    "Island1CaveStart",
    "Island1CaveMid", 
    "Island1CaveDeep",
    "Roof"
}

-- Cache for found models
local foundModelsCache = {}

-- Function to find models in SpawnLocation (NEW IMPROVED VERSION)
local function findFarmModels()
    print("\n=== STARTING NEW SEARCH ===")
    
    local allFoundModels = {}
    
    -- Check if Rocks folder exists
    if not workspace:FindFirstChild("Rocks") then
        warn("❌ No Rocks folder found!")
        return allFoundModels
    end
    
    local rocksFolder = workspace.Rocks
    print("✅ Found Rocks folder")
    
    -- Search in each location
    for _, locationName in ipairs(SEARCH_LOCATIONS) do
        print("\n🔍 Checking location: " .. locationName)
        
        local locationFolder = rocksFolder:FindFirstChild(locationName)
        
        if locationFolder then
            print("   ✅ Location folder found")
            
            -- Check ALL items in this location folder
            for _, item in ipairs(locationFolder:GetChildren()) do
                print("   • Checking: " .. item.Name .. " (" .. item.ClassName .. ")")
                
                -- Look for SpawnLocation
                local spawnLocation = item:FindFirstChild("SpawnLocation")
                
                if spawnLocation then
                    print("     ✅ Found SpawnLocation")
                    
                    -- Check if SpawnLocation is a BasePart
                    if spawnLocation:IsA("BasePart") then
                        print("     ✅ SpawnLocation is BasePart")
                        
                        -- Now check what's INSIDE the SpawnLocation
                        local childCount = #spawnLocation:GetChildren()
                        print("     📦 SpawnLocation has " .. childCount .. " children")
                        
                        -- List ALL children
                        for _, child in ipairs(spawnLocation:GetChildren()) do
                            print("       - " .. child.Name .. " (" .. child.ClassName .. ")")
                            
                            -- If child is a Model, add it to list
                            if child:IsA("Model") then
                                print("       🎯 Found Model inside SpawnLocation: " .. child.Name)
                                
                                -- Find a target part to tween to
                                local targetPart = child.PrimaryPart
                                
                                -- If no PrimaryPart, look for any BasePart
                                if not targetPart then
                                    for _, part in ipairs(child:GetChildren()) do
                                        if part:IsA("BasePart") or part:IsA("MeshPart") then
                                            targetPart = part
                                            break
                                        end
                                    end
                                end
                                
                                if targetPart then
                                    local displayName = child.Name .. " [" .. locationName .. "]"
                                    
                                    table.insert(allFoundModels, {
                                        DisplayName = displayName,
                                        ModelName = child.Name,
                                        LocationName = locationName,
                                        TargetPart = targetPart,
                                        FullModel = child,
                                        ParentItem = item.Name
                                    })
                                    
                                    print("       ✅ Added: " .. displayName)
                                else
                                    print("       ⚠️ Model has no BasePart/MeshPart")
                                end
                            end
                        end
                    else
                        print("     ⚠️ SpawnLocation is not BasePart (" .. spawnLocation.ClassName .. ")")
                    end
                else
                    print("     ❌ No SpawnLocation in this item")
                end
            end
        else
            print("   ❌ Location folder not found: " .. locationName)
        end
    end
    
    -- SPECIAL SEARCH: Check for any Model that might contain a SpawnLocation
    if #allFoundModels == 0 then
        print("\n🔍 Starting special search...")
        
        for _, locationName in ipairs(SEARCH_LOCATIONS) do
            local locationFolder = rocksFolder:FindFirstChild(locationName)
            if locationFolder then
                for _, model in ipairs(locationFolder:GetChildren()) do
                    if model:IsA("Model") then
                        -- Check if this model has any BasePart we can use
                        local targetPart = model.PrimaryPart
                        if not targetPart then
                            for _, part in ipairs(model:GetChildren()) do
                                if part:IsA("BasePart") or part:IsA("MeshPart") then
                                    targetPart = part
                                    break
                                end
                            end
                        end
                        
                        if targetPart then
                            local displayName = model.Name .. " [" .. locationName .. "] (Direct)"
                            
                            table.insert(allFoundModels, {
                                DisplayName = displayName,
                                ModelName = model.Name,
                                LocationName = locationName,
                                TargetPart = targetPart,
                                FullModel = model,
                                ParentItem = "Direct"
                            })
                            
                            print("🎯 Added direct model: " .. displayName)
                        end
                    end
                end
            end
        end
    end
    
    print("\n=== SEARCH COMPLETE ===")
    print("Found " .. #allFoundModels .. " farm targets:")
    
    for i, model in ipairs(allFoundModels) do
        print(i .. ". " .. model.DisplayName)
    end
    
    -- Update cache
    foundModelsCache = allFoundModels
    
    return allFoundModels
end

-- Function to get target by display name
local function getTargetByDisplayName(displayName)
    -- Check cache first
    for _, modelData in ipairs(foundModelsCache) do
        if modelData.DisplayName == displayName then
            return modelData.TargetPart
        end
    end
    
    -- If not in cache, search manually
    for _, locationName in ipairs(SEARCH_LOCATIONS) do
        if string.find(displayName, locationName) then
            if workspace:FindFirstChild("Rocks") then
                local rocksFolder = workspace.Rocks
                local locationFolder = rocksFolder:FindFirstChild(locationName)
                
                if locationFolder then
                    -- Extract model name from display name
                    local modelName = string.match(displayName, "(.+) %[")
                    
                    -- Search through all items
                    for _, item in ipairs(locationFolder:GetChildren()) do
                        if item:IsA("Model") then
                            local spawnLocation = item:FindFirstChild("SpawnLocation")
                            if spawnLocation then
                                local targetModel = spawnLocation:FindFirstChild(modelName)
                                if targetModel and targetModel:IsA("Model") then
                                    local targetPart = targetModel.PrimaryPart
                                    if not targetPart then
                                        for _, part in ipairs(targetModel:GetChildren()) do
                                            if part:IsA("BasePart") or part:IsA("MeshPart") then
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
        return false
    end
    
    print("🔧 Tweening to: " .. displayName)
    
    -- Get target
    local targetPart = getTargetByDisplayName(displayName)
    
    if not targetPart then
        warn("❌ Target not found!")
        
        -- Try to find it with fresh search
        local models = findFarmModels()
        for _, modelData in ipairs(models) do
            if modelData.DisplayName == displayName then
                targetPart = modelData.TargetPart
                break
            end
        end
        
        if not targetPart then
            Window:Notify({
                Title = "Error",
                Desc = "Target not found: " .. displayName,
                Time = 3
            })
            return false
        end
    end
    
    if not targetPart:IsA("BasePart") and not targetPart:IsA("MeshPart") then
        warn("❌ Invalid target type!")
        return false
    end
    
    -- Enable noclip if needed
    if noclipEnabled then
        enableNoclip()
    end
    
    -- Calculate distance and duration
    local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
    local duration = distance / tweenSpeed
    
    print("📏 Distance: " .. string.format("%.2f", distance) .. " | Duration: " .. string.format("%.2f", duration) .. "s")
    
    -- Create tween
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetPart.CFrame})
    
    local success = pcall(function()
        tween:Play()
        tween.Completed:Wait()
    end)
    
    -- Disable noclip
    if noclipEnabled then
        disableNoclip()
    end
    
    if success then
        print("✅ Tween complete!")
        
        -- Use pickaxe
        local pickSuccess = pcall(function()
            toolRemote:InvokeServer("Pickaxe")
        end)
        
        if pickSuccess then
            print("✅ Pickaxe used")
        else
            warn("❌ Failed to use pickaxe")
        end
        
        return true
    else
        warn("❌ Tween failed!")
        return false
    end
end

-- Auto farm loop
local autoFarmThread
local function startAutoFarm()
    if autoFarmThread then
        task.cancel(autoFarmThread)
    end
    
    autoFarmThread = task.spawn(function()
        print("🚀 Starting Auto Farm: " .. selectedFarm)
        
        while autoFarmEnabled and selectedFarm ~= "" do
            local success = tweenToTarget(selectedFarm)
            
            if not success then
                warn("⚠️ Farm cycle failed!")
                break
            end
            
            task.wait(0.5)
        end
        
        print("⏹️ Auto Farm stopped")
    end)
end

-- Function to refresh farm list
local function refreshFarmList()
    print("🔄 Refreshing farm list...")
    
    local models = findFarmModels()
    local displayNames = {}
    
    for _, modelData in ipairs(models) do
        table.insert(displayNames, modelData.DisplayName)
    end
    
    -- If no models found, show default names
    if #displayNames == 0 then
        displayNames = {
            "Pebble [Island1CaveStart]",
            "Rock [Island1CaveMid]",
            "Boulder [Island1CaveDeep]",
            "Lucky Block [Roof]"
        }
    end
    
    table.sort(displayNames)
    
    return displayNames
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    MainTab:Section({Title = "Auto Farm"})
    
    -- Initial refresh
    local initialNames = refreshFarmList()
    
    -- Create dropdown
    local farmDropdown = MainTab:Dropdown({
        Title = "Select Farm",
        Desc = "Choose model to farm",
        List = initialNames,
        Value = initialNames[1],
        Callback = function(choice)
            selectedFarm = choice
            print("📌 Selected: " .. choice)
        end
    })
    
    selectedFarm = initialNames[1]
    
    -- Tween Speed
    MainTab:Slider({
        Title = "Tween Speed",
        Desc = "Movement speed (10-200)",
        Min = 10,
        Max = 200,
        Rounding = 0,
        Value = 50,
        Callback = function(val)
            tweenSpeed = val
            print("🎚️ Speed: " .. val)
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
                enableNoclip()
                Window:Notify({
                    Title = "Noclip",
                    Desc = "Noclip enabled",
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
        Desc = "Enable automatic farming",
        Value = false,
        Callback = function(v)
            autoFarmEnabled = v
            
            if v then
                if selectedFarm == "" then
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
            if selectedFarm == "" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Select a target first!",
                    Time = 3
                })
                return
            end
            
            local success = tweenToTarget(selectedFarm)
            
            if success then
                Window:Notify({
                    Title = "Success",
                    Desc = "Teleported to: " .. selectedFarm,
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Failed",
                    Desc = "Teleport failed!",
                    Time = 3
                })
            end
        end
    })
    
    -- Refresh Button
    MainTab:Button({
        Title = "Refresh Now",
        Desc = "Force refresh farm list",
        Callback = function()
            local names = refreshFarmList()
            
            Window:Notify({
                Title = "Refreshed",
                Desc = "Found " .. #names .. " targets",
                Time = 3
            })
            
            print("✅ List refreshed")
        end
    })
    
    -- Debug Button (IMPORTANT)
    MainTab:Button({
        Title = "Debug Structure",
        Desc = "Show detailed structure info",
        Callback = function()
            print("\n=== DETAILED DEBUG INFO ===")
            
            -- Check workspace structure
            if not workspace:FindFirstChild("Rocks") then
                print("❌ NO ROCKS FOLDER!")
                return
            end
            
            local rocks = workspace.Rocks
            print("✅ Rocks folder exists")
            print("Contents of Rocks folder:")
            
            for _, child in ipairs(rocks:GetChildren()) do
                print("📁 " .. child.Name .. " (" .. child.ClassName .. ")")
            end
            
            -- Check each location
            for _, locationName in ipairs(SEARCH_LOCATIONS) do
                print("\n📍 CHECKING: " .. locationName)
                
                local location = rocks:FindFirstChild(locationName)
                if location then
                    print("   ✅ Folder found")
                    print("   📊 Contents:")
                    
                    for _, item in ipairs(location:GetChildren()) do
                        print("   ├─ " .. item.Name .. " (" .. item.ClassName .. ")")
                        
                        if item:IsA("Model") then
                            local spawn = item:FindFirstChild("SpawnLocation")
                            if spawn then
                                print("   │  └─ ✅ SpawnLocation (" .. spawn.ClassName .. ")")
                                print("   │     ├─ Position: " .. tostring(spawn.Position))
                                print("   │     ├─ Size: " .. tostring(spawn.Size))
                                print("   │     └─ Children (" .. #spawn:GetChildren() .. "):")
                                
                                if #spawn:GetChildren() == 0 then
                                    print("   │        (empty)")
                                else
                                    for _, child in ipairs(spawn:GetChildren()) do
                                        print("   │        ├─ " .. child.Name .. " (" .. child.ClassName .. ")")
                                        
                                        -- If it's a Model, show its parts
                                        if child:IsA("Model") then
                                            for _, part in ipairs(child:GetChildren()) do
                                                if part:IsA("BasePart") or part:IsA("MeshPart") then
                                                    print("   │        │  └─ " .. part.Name .. " (" .. part.ClassName .. ")")
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                print("   │  └─ ❌ No SpawnLocation")
                            end
                        end
                    end
                else
                    print("   ❌ Folder NOT FOUND")
                end
            end
            
            print("\n=== END DEBUG ===")
            
            Window:Notify({
                Title = "Debug Complete",
                Desc = "Check console (F9) for details",
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
    print("🎭 Character loaded")
    
    if noclipEnabled then
        enableNoclip()
    end
end)

-- Initial setup
task.spawn(function()
    task.wait(2) -- Wait for game to load
    
    local names = refreshFarmList()
    
    if #names > 0 then
        Window:Notify({
            Title = "Ready",
            Desc = "Found " .. #names .. " farm targets",
            Time = 4
        })
    else
        Window:Notify({
            Title = "Warning",
            Desc = "No targets found. Use Debug Structure.",
            Time = 5
        })
    end
end)

print("\n==================================")
print("🚀 x2zu Auto Farm Script Loaded")
print("==================================")
