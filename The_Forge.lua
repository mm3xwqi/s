-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "the forge4",
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

-- Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"})
Tab:Section({Title = "Auto Farm"})

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Function to teleport to position instantly
local function teleportToPosition(position)
    local char = LocalPlayer.Character
    if not char then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    hrp.CFrame = CFrame.new(position)
    return true
end

-- Function to check model health
local function checkModelHealth(model)
    if not model then return false end
    
    -- Check for Humanoid health
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health then
        return humanoid.Health > 0
    end
    
    -- Check for Health value
    local healthValue = model:FindFirstChild("Health")
    if healthValue then
        if healthValue:IsA("NumberValue") or healthValue:IsA("IntValue") then
            return healthValue.Value > 0
        end
    end
    
    -- Check for health attribute
    local healthAttr = model:GetAttribute("Health")
    if healthAttr then
        return healthAttr > 0
    end
    
    -- If no health system found, assume it's alive
    return true
end

-- Function to get ALL occupied SpawnLocations with healthy models
local function getHealthyOccupiedSpawnLocations()
    local healthyLocations = {}
    
    if not workspace:FindFirstChild("Rocks") then
        return healthyLocations
    end
    
    print("🔍 Scanning for healthy occupied models...")
    
    -- Check direct SpawnLocations in Rocks
    for _, item in ipairs(workspace.Rocks:GetChildren()) do
        if item.Name == "SpawnLocation" then
            for _, child in ipairs(item:GetChildren()) do
                if child:IsA("Model") then
                    -- Check IsOccupied attribute
                    if child:GetAttribute("IsOccupied") == true then
                        -- Check model health
                        if checkModelHealth(child) then
                            table.insert(healthyLocations, {
                                DisplayName = "SpawnLocation_" .. #healthyLocations + 1,
                                SpawnLocation = item,
                                TargetModel = child,
                                Position = item.Position
                            })
                            print("✓ Found healthy occupied model (direct)")
                            break -- Move to next SpawnLocation
                        else
                            print("✗ Skipping - model health is 0")
                        end
                    end
                end
            end
        end
    end
    
    -- Check named folders with SpawnLocation inside
    for _, item in ipairs(workspace.Rocks:GetChildren()) do
        if item.Name ~= "SpawnLocation" then
            local spawnLoc = item:FindFirstChild("SpawnLocation")
            if spawnLoc then
                for _, child in ipairs(spawnLoc:GetChildren()) do
                    if child:IsA("Model") then
                        if child:GetAttribute("IsOccupied") == true then
                            if checkModelHealth(child) then
                                table.insert(healthyLocations, {
                                    DisplayName = item.Name,
                                    SpawnLocation = spawnLoc,
                                    TargetModel = child,
                                    Position = spawnLoc.Position
                                })
                                print("✓ Found healthy occupied in " .. item.Name)
                                break
                            else
                                print("✗ Skipping " .. item.Name .. " - model health is 0")
                            end
                        end
                    end
                end
            end
        end
    end
    
    print("✅ Total healthy occupied locations: " .. #healthyLocations)
    return healthyLocations
end

-- Function to scan ALL SpawnLocations (for dropdown)
local function getAllSpawnLocationsWithModels()
    local allLocations = {}
    
    if not workspace:FindFirstChild("Rocks") then
        return allLocations
    end
    
    -- Direct SpawnLocations
    local spawnCount = 1
    for _, item in ipairs(workspace.Rocks:GetChildren()) do
        if item.Name == "SpawnLocation" then
            local hasModel = false
            for _, child in ipairs(item:GetChildren()) do
                if child:IsA("Model") then
                    hasModel = true
                    break
                end
            end
            
            if hasModel then
                table.insert(allLocations, {
                    DisplayName = "SpawnLocation_" .. spawnCount,
                    SpawnLocation = item,
                    Position = item.Position
                })
                spawnCount = spawnCount + 1
            end
        end
    end
    
    -- Named folders
    for _, item in ipairs(workspace.Rocks:GetChildren()) do
        if item.Name ~= "SpawnLocation" then
            local spawnLoc = item:FindFirstChild("SpawnLocation")
            if spawnLoc then
                local hasModel = false
                for _, child in ipairs(spawnLoc:GetChildren()) do
                    if child:IsA("Model") then
                        hasModel = true
                        break
                    end
                end
                
                if hasModel then
                    table.insert(allLocations, {
                        DisplayName = item.Name,
                        SpawnLocation = spawnLoc,
                        Position = spawnLoc.Position
                    })
                end
            end
        end
    end
    
    return allLocations
end

-- Auto farm variables
local AutoFarmEnabled = false
local TweenSpeed = 100
local Mining = false
local CurrentTween = nil
local SelectedLocation = nil
local AllSpawnLocations = {}
local FarmMode = "Selected" -- Selected or All

-- Remote setup
local ToolService
local function setupRemote()
    ToolService = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
end
pcall(setupRemote)

-- Get character function
local function getCharacter()
    local char = LocalPlayer.Character
    if not char then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hrp
end

-- Enable noclip
local function enableNoclip(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Find first healthy occupied model in SpawnLocation
local function findHealthyOccupiedModel(spawnLoc)
    for _, child in ipairs(spawnLoc:GetChildren()) do
        if child:IsA("Model") then
            -- Check IsOccupied
            if child:GetAttribute("IsOccupied") == true then
                -- Check health
                if checkModelHealth(child) then
                    return child
                else
                    print("⚠️ Model found but health is 0")
                    return nil
                end
            end
        end
    end
    return nil
end

-- Mining function
local function startMining()
    if not ToolService or not AutoFarmEnabled then
        return false
    end
    
    Mining = true
    
    while Mining and AutoFarmEnabled do
        local args = {"Pickaxe"}
        local success, result = pcall(function()
            ToolService:InvokeServer(unpack(args))
        end)
        
        if not success then
            print("Mining error:", result)
        end
        
        task.wait(0.1)
    end
    
    Mining = false
    return true
end

-- Tween to target model
local function tweenToModel(targetModel)
    if not AutoFarmEnabled or not targetModel then 
        print("❌ Cannot tween - no target model")
        return false 
    end
    
    -- Double check health before tweening
    if not checkModelHealth(targetModel) then
        print("❌ Model health is 0, skipping...")
        return false
    end
    
    local char, hrp = getCharacter()
    if not char or not hrp then 
        print("❌ Character not found")
        return false 
    end
    
    -- Get target position
    local targetCFrame
    if targetModel.PrimaryPart then
        targetCFrame = targetModel:GetPivot()
    else
        for _, part in ipairs(targetModel:GetDescendants()) do
            if part:IsA("BasePart") then
                targetCFrame = part.CFrame
                break
            end
        end
    end
    
    if not targetCFrame then 
        print("❌ Cannot get model position")
        return false 
    end
    
    -- Calculate tween time
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local tweenTime = distance / TweenSpeed
    
    print("📏 Distance:", math.floor(distance), "Time:", string.format("%.2f", tweenTime) .. "s")
    
    -- Cancel current tween
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
    
    -- Create tween
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    CurrentTween:Play()
    
    print("🚀 Tweening to model...")
    
    -- When tween completes
    local reached = false
    CurrentTween.Completed:Connect(function()
        reached = true
    end)
    
    -- Wait for tween to complete or health check
    while not reached and AutoFarmEnabled do
        -- Check health during tween
        if not checkModelHealth(targetModel) then
            print("❌ Model died during tween, canceling...")
            if CurrentTween then
                CurrentTween:Cancel()
            end
            return false
        end
        task.wait(0.1)
    end
    
    return reached and AutoFarmEnabled
end

-- Scan and farm ALL healthy occupied locations
local function scanAndFarmAllHealthy()
    while AutoFarmEnabled do
        print("\n🔄 Scanning for healthy occupied locations...")
        local healthyLocations = getHealthyOccupiedSpawnLocations()
        
        if #healthyLocations == 0 then
            print("⏳ No healthy occupied locations found, waiting...")
            task.wait(2)
            continue
        end
        
        print("🎯 Found " .. #healthyLocations .. " healthy locations to farm")
        
        -- Farm each healthy occupied location
        for _, locationData in ipairs(healthyLocations) do
            if not AutoFarmEnabled then break end
            
            print("🎯 Processing: " .. locationData.DisplayName)
            
            -- Teleport to SpawnLocation first
            if teleportToPosition(locationData.Position) then
                task.wait(0.5)
                
                -- Re-check if still healthy and occupied
                local targetModel = findHealthyOccupiedModel(locationData.SpawnLocation)
                if targetModel then
                    print("✅ Still healthy and occupied, tweening...")
                    
                    -- Tween to model
                    local reached = tweenToModel(targetModel)
                    
                    if reached then
                        -- Start mining
                        print("⛏️ Starting mining...")
                        startMining()
                        
                        -- Wait for mining to finish (model should die)
                        while Mining and AutoFarmEnabled and checkModelHealth(targetModel) do
                            task.wait(1)
                        end
                        
                        print("✅ Finished mining " .. locationData.DisplayName)
                    else
                        print("❌ Failed to reach model")
                    end
                else
                    print("❌ No longer healthy/occupied, skipping...")
                end
            else
                print("❌ Failed to teleport")
            end
            
            if not AutoFarmEnabled then break end
            task.wait(1)
        end
        
        print("✅ Completed scan cycle")
        task.wait(1)
    end
end

-- Farm specific selected location
local function farmSelectedLocation()
    while AutoFarmEnabled and SelectedLocation do
        -- Find the selected location
        local targetLocation = nil
        for _, locData in ipairs(AllSpawnLocations) do
            if locData.DisplayName == SelectedLocation then
                targetLocation = locData
                break
            end
        end
        
        if not targetLocation then
            print("❌ Selected location not found")
            task.wait(2)
            continue
        end
        
        -- Check for healthy occupied model
        local healthyModel = findHealthyOccupiedModel(targetLocation.SpawnLocation)
        if healthyModel then
            print("✅ " .. SelectedLocation .. " has healthy occupied model")
            
            -- Teleport to SpawnLocation
            if teleportToPosition(targetLocation.Position) then
                task.wait(0.5)
                
                -- Re-check health after teleport
                if not checkModelHealth(healthyModel) then
                    print("❌ Model health became 0 after teleport, skipping...")
                    task.wait(2)
                    continue
                end
                
                -- Tween to model
                local reached = tweenToModel(healthyModel)
                
                if reached then
                    -- Start mining
                    startMining()
                    
                    -- Wait for mining to finish
                    while Mining and AutoFarmEnabled and checkModelHealth(healthyModel) do
                        task.wait(1)
                    end
                end
            end
        else
            print("❌ " .. SelectedLocation .. " no healthy occupied model, waiting...")
            task.wait(2)
        end
    end
end

-- Get all locations for dropdown
AllSpawnLocations = getAllSpawnLocationsWithModels()

-- Create display names list
local displayNames = {}
for _, data in ipairs(AllSpawnLocations) do
    table.insert(displayNames, data.DisplayName)
end

-- Set default if available
if #displayNames > 0 then
    SelectedLocation = displayNames[1]
else
    SelectedLocation = nil
end

-- Mode dropdown
Tab:Dropdown({
    Title = "Farm Mode",
    List = {"Selected Location", "All Healthy Occupied"},
    Value = "Selected Location",
    Callback = function(choice)
        if choice == "Selected Location" then
            FarmMode = "Selected"
            print("📍 Mode: Farm selected location only")
        else
            FarmMode = "All"
            print("📍 Mode: Farm all healthy occupied locations")
        end
    end
})

-- Location dropdown (for Selected mode)
Tab:Dropdown({
    Title = "Select SpawnLocation",
    List = displayNames,
    Value = SelectedLocation,
    Callback = function(choice)
        SelectedLocation = choice
        print("📍 Selected:", choice)
    end
})

-- Speed slider
Tab:Slider({
    Title = "Tween Speed",
    Min = 50,
    Max = 300,
    Rounding = 0,
    Value = TweenSpeed,
    Callback = function(val)
        TweenSpeed = val
        print("⚡ Speed:", val)
    end
})

-- Auto Farm toggle
Tab:Toggle({
    Title = "Auto Farm",
    Desc = "Start auto farming (checks health)",
    Value = false,
    Callback = function(v)
        AutoFarmEnabled = v
        
        if v then
            if FarmMode == "Selected" and not SelectedLocation then
                Window:Notify({
                    Title = "Error",
                    Desc = "Please select a location first!",
                    Time = 3
                })
                return
            end
            
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Started farming (" .. FarmMode .. " mode)",
                Time = 3
            })
            
            -- Start farming based on mode
            if FarmMode == "Selected" then
                task.spawn(farmSelectedLocation)
            else
                task.spawn(scanAndFarmAllHealthy)
            end
        else
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Stopped farming",
                Time = 3
            })
            
            Mining = false
            if CurrentTween then
                CurrentTween:Cancel()
                CurrentTween = nil
            end
        end
    end
})

-- Auto noclip
RunService.Stepped:Connect(function()
    if AutoFarmEnabled then
        local char = LocalPlayer.Character
        if char then
            enableNoclip(char)
        end
    end
end)

-- Handle character changes
LocalPlayer.CharacterAdded:Connect(function()
    if AutoFarmEnabled then
        task.wait(1)
        if FarmMode == "Selected" then
            task.spawn(farmSelectedLocation)
        else
            task.spawn(scanAndFarmAllHealthy)
        end
    end
end)

-- Final notification
if #displayNames > 0 then
    Window:Notify({
        Title = "x2zu Auto Farm",
        Desc = "Health Check Enabled - Only farms healthy models",
        Time = 4
    })
end

print("\n" .. string.rep("=", 60))
print("✅ HEALTH-CHECK AUTO FARM SCRIPT LOADED")
print("📊 Total SpawnLocations: " .. #displayNames)
print("⚕️  Health Check: ON (skips health = 0 models)")
print("📍 Occupied Check: ON (skips IsOccupied = false)")
print(string.rep("=", 60))
