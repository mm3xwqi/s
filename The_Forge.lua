-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "The Forge6",
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

-- Define all possible locations
local ALL_LOCATIONS = {
    "workspace.Rocks.Island1CaveStart.SpawnLocation",
    "workspace.Rocks.Island1CaveMid.SpawnLocation",
    "workspace.Rocks.Island1CaveDeep.SpawnLocation",
    "workspace.Rocks.Roof.SpawnLocation"
}

-- Cache for found models
local foundModelsCache = {}
local lastSearchTime = 0
local SEARCH_COOLDOWN = 5 -- seconds

-- Function to safely get an object from path
local function getObjectFromPath(path)
    local parts = string.split(path, ".")
    local current = workspace
    
    for i = 2, #parts do
        current = current:FindFirstChild(parts[i])
        if not current then
            return nil
        end
    end
    
    return current
end

-- Main function to find ALL models in ALL SpawnLocations
local function findAllFarmModels()
    local now = tick()
    
    -- Use cache if recently searched
    if now - lastSearchTime < SEARCH_COOLDOWN and #foundModelsCache > 0 then
        return foundModelsCache
    end
    
    local allFoundModels = {}
    print("[AutoFarm] 🔍 Searching for farm models...")
    
    for _, path in ipairs(ALL_LOCATIONS) do
        -- Get the SpawnLocation part
        local spawnLocation = getObjectFromPath(path)
        
        if spawnLocation and spawnLocation:IsA("BasePart") then
            -- Extract location name from path
            local locationName = string.split(path, ".")[3] -- Gets Island1CaveStart, Island1CaveMid, etc.
            
            print("[AutoFarm] 📍 Checking: " .. locationName)
            
            -- Check all children inside this SpawnLocation
            for _, child in ipairs(spawnLocation:GetChildren()) do
                if child:IsA("Model") then
                    print("[AutoFarm]   🎯 Found Model: " .. child.Name .. " inside " .. locationName)
                    
                    -- Find a BasePart to tween to
                    local targetPart = child.PrimaryPart
                    if not targetPart then
                        -- Try to find any BasePart in the model
                        for _, part in ipairs(child:GetChildren()) do
                            if part:IsA("BasePart") then
                                targetPart = part
                                break
                            end
                        end
                    end
                    
                    -- Also check for MeshPart which is also a BasePart
                    if not targetPart then
                        for _, part in ipairs(child:GetChildren()) do
                            if part:IsA("MeshPart") then
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
                            SpawnLocation = spawnLocation,
                            Path = path
                        })
                        
                        print("[AutoFarm]   ✅ Added: " .. displayName .. " (Part: " .. targetPart.Name .. ")")
                    else
                        print("[AutoFarm]   ⚠️ Model has no BasePart/MeshPart: " .. child.Name)
                    end
                end
            end
            
            -- If no models found in this SpawnLocation, list what's there
            if #spawnLocation:GetChildren() == 0 then
                print("[AutoFarm]   📭 SpawnLocation is empty")
            else
                local hasNonModel = false
                for _, child in ipairs(spawnLocation:GetChildren()) do
                    if not child:IsA("Model") then
                        hasNonModel = true
                        print("[AutoFarm]   📦 Other item: " .. child.Name .. " (" .. child.ClassName .. ")")
                    end
                end
            end
        else
            if spawnLocation then
                print("[AutoFarm]   ❌ Not a BasePart: " .. spawnLocation.ClassName)
            else
                print("[AutoFarm]   ❌ Path not found: " .. path)
            end
        end
    end
    
    -- Update cache
    foundModelsCache = allFoundModels
    lastSearchTime = now
    
    print("[AutoFarm] 📊 Search complete. Found " .. #allFoundModels .. " models total.")
    
    return allFoundModels
end

-- Function to get target by display name
local function getTargetByDisplayName(displayName)
    -- First check cache
    for _, modelData in ipairs(foundModelsCache) do
        if modelData.DisplayName == displayName then
            return modelData.TargetPart
        end
    end
    
    -- If not in cache, do a fresh search
    local allModels = findAllFarmModels()
    for _, modelData in ipairs(allModels) do
        if modelData.DisplayName == displayName then
            return modelData.TargetPart
        end
    end
    
    -- Try to find it manually
    for _, path in ipairs(ALL_LOCATIONS) do
        local spawnLocation = getObjectFromPath(path)
        if spawnLocation then
            for _, child in ipairs(spawnLocation:GetChildren()) do
                if child:IsA("Model") then
                    local locationName = string.split(path, ".")[3]
                    local testName = child.Name .. " [" .. locationName .. "]"
                    
                    if testName == displayName then
                        local targetPart = child.PrimaryPart
                        if not targetPart then
                            for _, part in ipairs(child:GetChildren()) do
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
        warn("[AutoFarm] ❌ No target selected!")
        return false
    end
    
    print("[AutoFarm] 🔧 Starting tween to: " .. displayName)
    
    -- Get target part
    local targetPart = getTargetByDisplayName(displayName)
    
    if not targetPart then
        warn("[AutoFarm] ❌ Target not found: " .. displayName)
        
        -- Try one more time with fresh search
        findAllFarmModels()
        targetPart = getTargetByDisplayName(displayName)
        
        if not targetPart then
            Window:Notify({
                Title = "Target Error",
                Desc = "Could not find: " .. displayName,
                Time = 3
            })
            return false
        end
    end
    
    if not targetPart:IsA("BasePart") and not targetPart:IsA("MeshPart") then
        warn("[AutoFarm] ❌ Invalid target type: " .. targetPart.ClassName)
        return false
    end
    
    -- Enable noclip if needed
    if noclipEnabled then
        enableNoclip()
    end
    
    -- Calculate tween
    local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
    local duration = distance / tweenSpeed
    
    print(string.format("[AutoFarm] 📏 Distance: %.2f | Duration: %.2fs | Speed: %d", distance, duration, tweenSpeed))
    
    -- Create and play tween
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetPart.CFrame})
    
    local tweenSuccess = pcall(function()
        tween:Play()
        tween.Completed:Wait()
    end)
    
    -- Disable noclip
    if noclipEnabled then
        disableNoclip()
    end
    
    if tweenSuccess then
        print("[AutoFarm] ✅ Tween complete!")
        
        -- Use pickaxe
        local pickaxeSuccess = pcall(function()
            toolRemote:InvokeServer("Pickaxe")
        end)
        
        if pickaxeSuccess then
            print("[AutoFarm] ⚒️ Pickaxe used successfully")
        else
            warn("[AutoFarm] ⚠️ Failed to use pickaxe")
        end
        
        return true
    else
        warn("[AutoFarm] ❌ Tween failed")
        return false
    end
end

-- Auto farm loop
local autoFarmThread
local function startAutoFarm()
    -- Stop existing thread
    if autoFarmThread then
        task.cancel(autoFarmThread)
        autoFarmThread = nil
    end
    
    -- Start new thread
    autoFarmThread = task.spawn(function()
        print("[AutoFarm] 🚀 Starting auto farm for: " .. selectedFarm)
        
        while autoFarmEnabled and selectedFarm ~= "" do
            local success = pcall(function()
                tweenToTarget(selectedFarm)
            end)
            
            if not success then
                warn("[AutoFarm] ⚠️ Farm cycle failed, retrying...")
            end
            
            task.wait(0.5) -- Wait between cycles
        end
        
        print("[AutoFarm] ⏹️ Auto farm stopped")
    end)
end

-- Function to update dropdown with fresh data
local function refreshFarmList()
    print("[AutoFarm] 🔄 Refreshing farm list...")
    
    local allModels = findAllFarmModels()
    local displayNames = {}
    
    for _, modelData in ipairs(allModels) do
        table.insert(displayNames, modelData.DisplayName)
    end
    
    -- Sort alphabetically
    table.sort(displayNames)
    
    return displayNames, allModels
end

-- Create main tab
local MainTab
local farmDropdown

MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Initial farm list
    local initialDisplayNames, initialModels = refreshFarmList()
    
    -- Create dropdown
    farmDropdown = MainTab:Dropdown({
        Title = "Select Farm",
        Desc = "Choose model to farm",
        List = #initialDisplayNames > 0 and initialDisplayNames or {"No models found"},
        Value = #initialDisplayNames > 0 and initialDisplayNames[1] or "No models found",
        Callback = function(choice)
            if choice ~= "No models found" then
                selectedFarm = choice
                print("[AutoFarm] 📌 Selected: " .. choice)
            else
                selectedFarm = ""
            end
        end
    })
    
    -- Set initial selection
    if #initialDisplayNames > 0 then
        selectedFarm = initialDisplayNames[1]
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
            print("[AutoFarm] 🎚️ Speed: " .. val)
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
                    Desc = "Noclip enabled during tween",
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
        Desc = "Enable/disable automatic farming",
        Value = false,
        Callback = function(v)
            autoFarmEnabled = v
            
            if v then
                -- Validate selection
                if selectedFarm == "" or selectedFarm == "No models found" then
                    Window:Notify({
                        Title = "Error",
                        Desc = "Please select a farm model first!",
                        Time = 3
                    })
                    autoFarmEnabled = false
                    return
                end
                
                -- Verify target still exists
                local targetPart = getTargetByDisplayName(selectedFarm)
                if not targetPart then
                    Window:Notify({
                        Title = "Error",
                        Desc = "Selected model not found! Refresh list.",
                        Time = 3
                    })
                    autoFarmEnabled = false
                    return
                end
                
                -- Start auto farm
                startAutoFarm()
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Started: " .. selectedFarm,
                    Time = 3
                })
            else
                -- Stop auto farm
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
            if selectedFarm == "" or selectedFarm == "No models found" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Select a farm model first!",
                    Time = 3
                })
                return
            end
            
            local success = pcall(function()
                tweenToTarget(selectedFarm)
            end)
            
            if success then
                Window:Notify({
                    Title = "Success",
                    Desc = "Teleported to: " .. selectedFarm,
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "Failed to teleport!",
                    Time = 3
                })
            end
        end
    })
    
    -- Refresh Button
    MainTab:Button({
        Title = "Refresh List",
        Desc = "Reload all farm models",
        Callback = function()
            local displayNames, models = refreshFarmList()
            
            if #displayNames > 0 then
                Window:Notify({
                    Title = "Refreshed",
                    Desc = "Found " .. #displayNames .. " models",
                    Time = 3
                })
                
                -- Update selection if current doesn't exist
                local currentExists = false
                for _, name in ipairs(displayNames) do
                    if name == selectedFarm then
                        currentExists = true
                        break
                    end
                end
                
                if not currentExists and #displayNames > 0 then
                    selectedFarm = displayNames[1]
                    print("[AutoFarm] 🔄 Selection updated to: " .. selectedFarm)
                end
            else
                Window:Notify({
                    Title = "No Models",
                    Desc = "No farm models found",
                    Time = 3
                })
                selectedFarm = ""
            end
        end
    })
    
    -- Debug Button
    MainTab:Button({
        Title = "Debug Info",
        Desc = "Show detailed structure info",
        Callback = function()
            print("\n=== DEBUG INFORMATION ===")
            
            -- Check workspace structure
            if workspace:FindFirstChild("Rocks") then
                local rocks = workspace.Rocks
                print("📁 Rocks folder found")
                
                for _, location in ipairs(rocks:GetChildren()) do
                    print("\n📍 " .. location.Name .. ":")
                    
                    for _, item in ipairs(location:GetChildren()) do
                        if item:IsA("Model") then
                            print("  ├─ " .. item.Name)
                            local spawn = item:FindFirstChild("SpawnLocation")
                            if spawn then
                                print("  │  └─ SpawnLocation (" .. spawn.ClassName .. ")")
                                print("  │     ├─ Position: " .. tostring(spawn.Position))
                                print("  │     └─ Children: " .. #spawn:GetChildren())
                                
                                for _, child in ipairs(spawn:GetChildren()) do
                                    print("  │        ├─ " .. child.Name .. " (" .. child.ClassName .. ")")
                                end
                            end
                        end
                    end
                end
            else
                print("❌ No Rocks folder!")
            end
            
            print("\n=== CACHE INFO ===")
            print("Cached models: " .. #foundModelsCache)
            for i, model in ipairs(foundModelsCache) do
                print(i .. ". " .. model.DisplayName)
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
    print("[AutoFarm] 🎭 Character loaded")
    
    -- Re-enable noclip if it was on
    if noclipEnabled then
        enableNoclip()
    end
end)

-- Initial setup
task.spawn(function()
    task.wait(2) -- Wait a bit for game to load
    
    local displayNames = refreshFarmList()
    
    if #displayNames > 0 then
        Window:Notify({
            Title = "Auto Farm Ready",
            Desc = "Found " .. #displayNames .. " farm models",
            Time = 4
        })
        print("[AutoFarm] ✅ Script loaded successfully!")
    else
        Window:Notify({
            Title = "Setup Needed",
            Desc = "No models found. Check Debug Info.",
            Time = 5
        })
        print("[AutoFarm] ⚠️ No farm models found on initial search")
    end
end)

-- Auto-refresh every 30 seconds
task.spawn(function()
    while true do
        task.wait(30)
        if MainTab then
            refreshFarmList()
            print("[AutoFarm] 🔄 Auto-refresh complete")
        end
    end
end)

print("\n=================================")
print("🚀 x2zu Auto Farm Script Loaded")
print("=================================")
