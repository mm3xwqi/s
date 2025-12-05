-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "the forge1",
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

-- Function to get ALL rock locations with SpawnLocation (ALL of them)
local function getAllRockLocations()
    local allLocations = {}
    
    if not workspace:FindFirstChild("Rocks") then
        print("❌ No Rocks folder found!")
        return allLocations
    end
    
    print("🔍 Scanning ALL Rocks locations...")
    
    for _, rock in ipairs(workspace.Rocks:GetChildren()) do
        -- Function to find ANY SpawnLocation in this rock
        local function findAnySpawnLocation(parent)
            -- Check direct children
            if parent:FindFirstChild("SpawnLocation") then
                return parent:FindFirstChild("SpawnLocation")
            end
            
            -- Check all descendants recursively
            for _, child in ipairs(parent:GetDescendants()) do
                if child.Name == "SpawnLocation" then
                    return child
                end
            end
            
            return nil
        end
        
        local spawnLocation = findAnySpawnLocation(rock)
        
        if spawnLocation then
            table.insert(allLocations, rock.Name)
            print("✓ Found: " .. rock.Name .. " (has SpawnLocation)")
        else
            print("✗ Skipping: " .. rock.Name .. " (no SpawnLocation found)")
        end
    end
    
    -- Sort alphabetically
    table.sort(allLocations)
    print("✅ Total found: " .. #allLocations .. " locations")
    return allLocations
end

-- Auto farm variables
local AutoFarmEnabled = false
local TweenSpeed = 100
local Mining = false
local CurrentTween = nil
local SelectedLocation = nil

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

-- Function to find SpawnLocation in rock (deep search)
local function findSpawnLocationDeep(rock)
    -- Check direct child
    if rock:FindFirstChild("SpawnLocation") then
        return rock:FindFirstChild("SpawnLocation")
    end
    
    -- Search all descendants
    for _, descendant in ipairs(rock:GetDescendants()) do
        if descendant.Name == "SpawnLocation" then
            return descendant
        end
    end
    
    return nil
end

-- Function to find ANY Model in SpawnLocation
local function findAnyModelInSpawnLocation(spawnLoc)
    -- First priority: Models directly in SpawnLocation
    for _, child in ipairs(spawnLoc:GetChildren()) do
        if child:IsA("Model") then
            return child
        end
    end
    
    -- Second priority: Models in subfolders of SpawnLocation
    for _, child in ipairs(spawnLoc:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            for _, subChild in ipairs(child:GetChildren()) do
                if subChild:IsA("Model") then
                    return subChild
                end
            end
        end
    end
    
    -- If no Model found at all (shouldn't happen based on your info)
    print("⚠️ Warning: No Model found in SpawnLocation")
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

-- Tween to specific rock location
local function tweenToRockLocation(locationName)
    if not AutoFarmEnabled then return end
    
    print("🎯 Targeting: " .. locationName)
    
    -- Get the rock
    local rock = workspace.Rocks:FindFirstChild(locationName)
    if not rock then 
        print("❌ Rock not found:", locationName)
        return 
    end
    
    -- Find SpawnLocation (deep search)
    local spawnLocation = findSpawnLocationDeep(rock)
    if not spawnLocation then 
        print("❌ No SpawnLocation found in:", locationName)
        return 
    end
    
    print("📍 Found SpawnLocation in:", locationName)
    
    -- Find Model in SpawnLocation
    local targetModel = findAnyModelInSpawnLocation(spawnLocation)
    if not targetModel then 
        print("⚠️ No Model found in SpawnLocation of:", locationName)
        return 
    end
    
    print("🎯 Target Model:", targetModel.Name, "in", locationName)
    
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
        print("📌 Using PrimaryPart at:", targetCFrame.Position)
    else
        for _, part in ipairs(targetModel:GetDescendants()) do
            if part:IsA("BasePart") then
                targetCFrame = part.CFrame
                print("📌 Using BasePart at:", targetCFrame.Position)
                break
            end
        end
    end
    
    if not targetCFrame then 
        print("❌ Cannot get position of model in:", locationName)
        return 
    end
    
    -- Calculate tween time
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local tweenTime = distance / TweenSpeed
    
    print("📏 Distance:", math.floor(distance), "Speed:", TweenSpeed, "Time:", string.format("%.2f", tweenTime) .. "s")
    
    -- Cancel current tween
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
    
    -- Create tween
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    CurrentTween:Play()
    
    print("🚀 Started tweening to", locationName)
    
    -- When tween completes
    CurrentTween.Completed:Connect(function()
        if AutoFarmEnabled then
            print("✅ Reached", locationName)
            startMining()
            task.wait(1)
            tweenToRockLocation(locationName)
        end
    end)
end

-- Main auto farm function
local function startAutoFarm()
    while AutoFarmEnabled do
        if SelectedLocation then
            tweenToRockLocation(SelectedLocation)
        end
        
        -- Wait for current process to finish
        while Mining and AutoFarmEnabled do
            task.wait(1)
        end
        
        if not AutoFarmEnabled then break end
        task.wait(1)
    end
end

-- Get ALL rock locations
local allRockLocations = getAllRockLocations()

-- Set default location if available
if #allRockLocations > 0 then
    SelectedLocation = allRockLocations[1]
else
    SelectedLocation = nil
    Window:Notify({
        Title = "Error",
        Desc = "No rock locations found!",
        Time = 3
    })
end

-- Location dropdown (shows ALL locations)
Tab:Dropdown({
    Title = "Select Rock Location",
    Desc = "All locations with SpawnLocation",
    List = allRockLocations,
    Value = SelectedLocation,
    Callback = function(choice)
        SelectedLocation = choice
        print("📍 Selected:", choice)
        
        -- If auto farm is running, restart with new location
        if AutoFarmEnabled then
            Mining = false
            if CurrentTween then
                CurrentTween:Cancel()
                CurrentTween = nil
            end
            task.wait(0.5)
            tweenToRockLocation(SelectedLocation)
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
        print("⚡ Speed set to:", val)
    end
})

-- Auto Farm toggle
Tab:Toggle({
    Title = "Auto Farm",
    Desc = "Farm at selected location",
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
            
            -- Start auto farm
            task.spawn(startAutoFarm)
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
LocalPlayer.CharacterAdded:Connect(function(newChar)
    print("🔄 Character respawned")
    task.wait(1)
    
    if AutoFarmEnabled and SelectedLocation then
        print("🔄 Restarting auto farm...")
        task.wait(0.5)
        tweenToRockLocation(SelectedLocation)
    end
end)

-- Final notification
if #allRockLocations > 0 then
    Window:Notify({
        Title = "x2zu Auto Farm",
        Desc = "Loaded " .. #allRockLocations .. " rock locations!",
        Time = 4
    })
end

print("\n" .. string.rep("=", 50))
print("✅ AUTO FARM SCRIPT LOADED")
print("📊 Total Locations: " .. #allRockLocations)
print(string.rep("=", 50))
for i, loc in ipairs(allRockLocations) do
    print(string.format("%3d. %s", i, loc))
end
print(string.rep("=", 50))
