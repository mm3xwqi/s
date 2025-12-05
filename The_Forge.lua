-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "the forge3",
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

-- Function to teleport to location instantly
local function teleportToPosition(position)
    local char = LocalPlayer.Character
    if not char then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    hrp.CFrame = CFrame.new(position)
    print("✅ Teleported to position")
end

-- Function to get ALL SpawnLocations with Models and check IsOccupied attribute
local function getOccupiedSpawnLocations()
    local occupiedLocations = {}
    
    if not workspace:FindFirstChild("Rocks") then
        return occupiedLocations
    end
    
    print("🔍 Checking ALL SpawnLocations for IsOccupied...")
    
    -- Check direct SpawnLocations in Rocks
    for _, item in ipairs(workspace.Rocks:GetChildren()) do
        if item.Name == "SpawnLocation" then
            -- Check if this SpawnLocation has a Model AND IsOccupied is true
            local hasOccupiedModel = false
            local targetModel = nil
            
            for _, child in ipairs(item:GetChildren()) do
                if child:IsA("Model") then
                    -- Check if model has IsOccupied attribute
                    if child:GetAttribute("IsOccupied") == true then
                        hasOccupiedModel = true
                        targetModel = child
                        break
                    end
                end
            end
            
            if hasOccupiedModel and targetModel then
                table.insert(occupiedLocations, {
                    DisplayName = "SpawnLocation_" .. #occupiedLocations + 1,
                    SpawnLocation = item,
                    TargetModel = targetModel
                })
                print("✓ Found occupied SpawnLocation (direct)")
            end
        end
    end
    
    -- Check named folders with SpawnLocation inside
    for _, item in ipairs(workspace.Rocks:GetChildren()) do
        if item.Name ~= "SpawnLocation" then
            local spawnLoc = item:FindFirstChild("SpawnLocation")
            if spawnLoc then
                -- Check if SpawnLocation has an occupied model
                local hasOccupiedModel = false
                local targetModel = nil
                
                for _, child in ipairs(spawnLoc:GetChildren()) do
                    if child:IsA("Model") then
                        if child:GetAttribute("IsOccupied") == true then
                            hasOccupiedModel = true
                            targetModel = child
                            break
                        end
                    end
                end
                
                if hasOccupiedModel and targetModel then
                    table.insert(occupiedLocations, {
                        DisplayName = item.Name,
                        SpawnLocation = spawnLoc,
                        TargetModel = targetModel
                    })
                    print("✓ Found occupied in " .. item.Name)
                end
            end
        end
    end
    
    print("✅ Total occupied locations: " .. #occupiedLocations)
    return occupiedLocations
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
                    IsDirect = true
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
                        IsDirect = false,
                        ParentFolder = item
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
local CurrentScanIndex = 1

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

-- Find first occupied model in SpawnLocation
local function findOccupiedModel(spawnLoc)
    for _, child in ipairs(spawnLoc:GetChildren()) do
        if child:IsA("Model") then
            if child:GetAttribute("IsOccupied") == true then
                return child
            end
        end
    end
    return nil
end

-- Mining function
local function startMining()
    if not ToolService or not AutoFarmEnabled then
        return
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
end

-- Tween to target model
local function tweenToModel(targetModel)
    if not AutoFarmEnabled or not targetModel then return end
    
    local char, hrp = getCharacter()
    if not char or not hrp then return end
    
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
    
    if not targetCFrame then return end
    
    -- Calculate tween time
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local tweenTime = distance / TweenSpeed
    
    -- Cancel current tween
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
    
    -- Create tween
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    CurrentTween:Play()
    
    -- When tween completes
    CurrentTween.Completed:Connect(function()
        if AutoFarmEnabled then
            startMining()
        end
    end)
end

-- Scan and farm ALL occupied locations
local function scanAndFarmAllOccupied()
    while AutoFarmEnabled do
        print("🔄 Scanning for occupied locations...")
        local occupiedLocations = getOccupiedSpawnLocations()
        
        if #occupiedLocations == 0 then
            print("⏳ No occupied locations found, waiting...")
            task.wait(2)
            continue
        end
        
        -- Farm each occupied location
        for _, locationData in ipairs(occupiedLocations) do
            if not AutoFarmEnabled then break end
            
            print("🎯 Farming occupied: " .. locationData.DisplayName)
            
            -- Teleport to SpawnLocation first
            local spawnPos = locationData.SpawnLocation.Position
            teleportToPosition(spawnPos)
            task.wait(0.5)
            
            -- Check if still occupied
            local targetModel = findOccupiedModel(locationData.SpawnLocation)
            if targetModel and targetModel:GetAttribute("IsOccupied") == true then
                print("✅ Still occupied, tweening to model...")
                tweenToModel(targetModel)
                
                -- Wait for mining to finish
                while Mining and AutoFarmEnabled do
                    task.wait(1)
                end
            else
                print("❌ No longer occupied, skipping...")
            end
            
            if not AutoFarmEnabled then break end
            task.wait(1)
        end
        
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
        
        -- Check if occupied
        local occupiedModel = findOccupiedModel(targetLocation.SpawnLocation)
        if occupiedModel then
            print("✅ " .. SelectedLocation .. " is occupied")
            
            -- Teleport to SpawnLocation
            local spawnPos = targetLocation.SpawnLocation.Position
            teleportToPosition(spawnPos)
            task.wait(0.5)
            
            -- Tween to model
            tweenToModel(occupiedModel)
            
            -- Wait for mining
            while Mining and AutoFarmEnabled do
                task.wait(1)
            end
        else
            print("❌ " .. SelectedLocation .. " not occupied, waiting...")
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
local FarmMode = "Selected" -- Selected or All
Tab:Dropdown({
    Title = "Farm Mode",
    List = {"Selected Location", "All Occupied"},
    Value = "Selected Location",
    Callback = function(choice)
        if choice == "Selected Location" then
            FarmMode = "Selected"
            print("📍 Mode: Farm selected location only")
        else
            FarmMode = "All"
            print("📍 Mode: Farm all occupied locations")
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
    Desc = "Start auto farming",
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
                task.spawn(scanAndFarmAllOccupied)
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
            task.spawn(scanAndFarmAllOccupied)
        end
    end
end)

-- Final notification
if #displayNames > 0 then
    Window:Notify({
        Title = "x2zu Auto Farm",
        Desc = "Found " .. #displayNames .. " SpawnLocations",
        Time = 4
    })
end

print("\n" .. string.rep("=", 50))
print("✅ OCCUPIED AUTO FARM SCRIPT LOADED")
print("📊 Total SpawnLocations: " .. #displayNames)
print("📍 Mode: Check IsOccupied attribute")
print(string.rep("=", 50))
