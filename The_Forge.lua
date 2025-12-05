-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "the forge2",
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

-- Function to get ALL SpawnLocation folders in Rocks (direct children)
local function getAllSpawnLocations()
    local spawnLocations = {}
    
    if not workspace:FindFirstChild("Rocks") then
        return spawnLocations
    end
    
    print("🔍 Scanning Rocks folder...")
    
    for _, item in ipairs(workspace.Rocks:GetChildren()) do
        -- Check if this is a SpawnLocation folder directly in Rocks
        if item.Name == "SpawnLocation" then
            -- Check if this SpawnLocation has at least one Model inside
            local hasModel = false
            for _, child in ipairs(item:GetChildren()) do
                if child:IsA("Model") then
                    hasModel = true
                    break
                end
            end
            
            if hasModel then
                -- Create a unique display name
                local displayName = "SpawnLocation_" .. #spawnLocations + 1
                table.insert(spawnLocations, {
                    DisplayName = displayName,
                    RealObject = item,
                    HasModel = true
                })
                print("✓ Found SpawnLocation with Model: " .. displayName)
            else
                print("✗ Skipping SpawnLocation (no Model inside)")
            end
        end
    end
    
    -- Also check for named folders (like Island1CaveStart, etc.)
    for _, item in ipairs(workspace.Rocks:GetChildren()) do
        if item.Name ~= "SpawnLocation" then
            -- Check if this folder has a SpawnLocation inside
            local spawnLoc = item:FindFirstChild("SpawnLocation")
            if spawnLoc then
                -- Check if SpawnLocation has at least one Model
                local hasModel = false
                for _, child in ipairs(spawnLoc:GetChildren()) do
                    if child:IsA("Model") then
                        hasModel = true
                        break
                    end
                end
                
                if hasModel then
                    table.insert(spawnLocations, {
                        DisplayName = item.Name,
                        RealObject = spawnLoc,
                        HasModel = true
                    })
                    print("✓ Found " .. item.Name .. " with SpawnLocation (has Model)")
                else
                    print("✗ Skipping " .. item.Name .. " (SpawnLocation has no Model)")
                end
            end
        end
    end
    
    print("✅ Total valid locations: " .. #spawnLocations)
    return spawnLocations
end

-- Auto farm variables
local AutoFarmEnabled = false
local TweenSpeed = 100
local Mining = false
local CurrentTween = nil
local SelectedLocation = nil
local SpawnLocationsData = {}

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

-- Function to find first Model in SpawnLocation
local function findFirstModel(spawnLoc)
    for _, child in ipairs(spawnLoc:GetChildren()) do
        if child:IsA("Model") then
            return child
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

-- Tween to SpawnLocation
local function tweenToSpawnLocation(locationData)
    if not AutoFarmEnabled then return end
    
    print("🎯 Targeting: " .. locationData.DisplayName)
    
    -- Find first Model in this SpawnLocation
    local targetModel = findFirstModel(locationData.RealObject)
    if not targetModel then 
        print("❌ No Model found in " .. locationData.DisplayName)
        return 
    end
    
    print("🎯 Target Model:", targetModel.Name)
    
    -- Get character
    local char, hrp = getCharacter()
    if not char or not hrp then 
        print("❌ Character not found")
        return 
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
        return 
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
    
    print("🚀 Started tweening to " .. locationData.DisplayName)
    
    -- When tween completes
    CurrentTween.Completed:Connect(function()
        if AutoFarmEnabled then
            print("✅ Reached " .. locationData.DisplayName)
            startMining()
            task.wait(1)
            tweenToSpawnLocation(locationData)
        end
    end)
end

-- Get ALL valid SpawnLocations
SpawnLocationsData = getAllSpawnLocations()

-- Create display names list for dropdown
local displayNames = {}
for _, data in ipairs(SpawnLocationsData) do
    table.insert(displayNames, data.DisplayName)
end

-- Set default if available
if #displayNames > 0 then
    SelectedLocation = displayNames[1]
else
    SelectedLocation = nil
    Window:Notify({
        Title = "Error",
        Desc = "No SpawnLocations with Models found!",
        Time = 3
    })
end

-- Location dropdown
Tab:Dropdown({
    Title = "Select SpawnLocation",
    Desc = "Only shows SpawnLocations with Models",
    List = displayNames,
    Value = SelectedLocation,
    Callback = function(choice)
        SelectedLocation = choice
        print("📍 Selected:", choice)
        
        -- If auto farm is running, restart
        if AutoFarmEnabled then
            Mining = false
            if CurrentTween then
                CurrentTween:Cancel()
                CurrentTween = nil
            end
            task.wait(0.5)
            
            -- Find the selected location data
            for _, data in ipairs(SpawnLocationsData) do
                if data.DisplayName == choice then
                    tweenToSpawnLocation(data)
                    break
                end
            end
        end
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
    Desc = "Farm at selected SpawnLocation",
    Value = false,
    Callback = function(v)
        AutoFarmEnabled = v
        
        if v then
            if not SelectedLocation then
                Window:Notify({
                    Title = "Error",
                    Desc = "Please select a location first!",
                    Time = 3
                })
                return
            end
            
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Started farming at: " .. SelectedLocation,
                Time = 3
            })
            
            -- Find and start farming at selected location
            for _, data in ipairs(SpawnLocationsData) do
                if data.DisplayName == SelectedLocation then
                    task.spawn(function()
                        tweenToSpawnLocation(data)
                    end)
                    break
                end
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
    if AutoFarmEnabled and SelectedLocation then
        task.wait(1)
        for _, data in ipairs(SpawnLocationsData) do
            if data.DisplayName == SelectedLocation then
                tweenToSpawnLocation(data)
                break
            end
        end
    end
end)

-- Final notification
if #displayNames > 0 then
    Window:Notify({
        Title = "x2zu Auto Farm",
        Desc = "Found " .. #displayNames .. " SpawnLocations with Models!",
        Time = 4
    })
end

print("\n" .. string.rep("=", 50))
print("✅ AUTO FARM SCRIPT LOADED")
print("📊 Total SpawnLocations with Models: " .. #displayNames)
print(string.rep("=", 50))
