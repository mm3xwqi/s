-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "the forge",
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

-- Function to check ALL SpawnLocations and get ONLY those with Models
local function getValidRockLocations()
    local validLocations = {}
    
    if not workspace:FindFirstChild("Rocks") then
        return validLocations
    end
    
    for _, rock in ipairs(workspace.Rocks:GetChildren()) do
        -- Function to find SpawnLocation in rock or subfolders
        local function findSpawnLocation(parent)
            -- Check direct child
            if parent:FindFirstChild("SpawnLocation") then
                return parent:FindFirstChild("SpawnLocation")
            end
            
            -- Check subfolders
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("Folder") or child:IsA("Model") then
                    if child:FindFirstChild("SpawnLocation") then
                        return child:FindFirstChild("SpawnLocation")
                    end
                end
            end
            
            return nil
        end
        
        local spawnLocation = findSpawnLocation(rock)
        
        if spawnLocation then
            -- Check if SpawnLocation has ANY Model inside
            local hasModel = false
            for _, child in ipairs(spawnLocation:GetChildren()) do
                if child:IsA("Model") then
                    hasModel = true
                    break
                end
            end
            
            if hasModel then
                table.insert(validLocations, rock.Name)
                print("✓ Found valid location: " .. rock.Name .. " (has Model in SpawnLocation)")
            else
                print("✗ Skipping " .. rock.Name .. " (no Model in SpawnLocation)")
            end
        end
    end
    
    -- Sort alphabetically
    table.sort(validLocations)
    return validLocations
end

-- Auto farm variables
local AutoFarmEnabled = false
local TweenSpeed = 100
local Mining = false
local CurrentTween = nil
local SelectedLocation = nil
local FarmingLoop = false

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

-- Function to find SpawnLocation in rock
local function findSpawnLocation(rock)
    -- Check rock itself
    local spawnLoc = rock:FindFirstChild("SpawnLocation")
    if spawnLoc then return spawnLoc end
    
    -- Check subfolders
    for _, child in ipairs(rock:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            spawnLoc = child:FindFirstChild("SpawnLocation")
            if spawnLoc then return spawnLoc end
        end
    end
    
    return nil
end

-- Function to find FIRST Model in SpawnLocation
local function findModelInSpawnLocation(spawnLoc)
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

-- Tween to specific rock location
local function tweenToRockLocation(locationName)
    if not AutoFarmEnabled then return end
    
    -- Get the rock
    local rock = workspace.Rocks:FindFirstChild(locationName)
    if not rock then 
        print("Rock not found:", locationName)
        return 
    end
    
    -- Find SpawnLocation
    local spawnLocation = findSpawnLocation(rock)
    if not spawnLocation then 
        print("No SpawnLocation in:", locationName)
        return 
    end
    
    -- Find Model in SpawnLocation
    local targetModel = findModelInSpawnLocation(spawnLocation)
    if not targetModel then 
        print("No Model found in SpawnLocation of:", locationName)
        return 
    end
    
    print("Going to:", locationName, "Model:", targetModel.Name)
    
    -- Get character
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
    
    if not targetCFrame then 
        print("Cannot get position of model in:", locationName)
        return 
    end
    
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
            print("Reached model at:", locationName)
            startMining()
            task.wait(1)
            tweenToRockLocation(locationName)
        end
    end)
end

-- Main auto farm loop for multiple locations
local function autoFarmAllLocations()
    if FarmingLoop then return end
    FarmingLoop = true
    
    local validLocations = getValidRockLocations()
    
    while AutoFarmEnabled and #validLocations > 0 do
        for _, locationName in ipairs(validLocations) do
            if not AutoFarmEnabled then break end
            
            print("Farming at:", locationName)
            tweenToRockLocation(locationName)
            
            -- Wait at this location for a while
            local waitTime = 0
            while Mining and AutoFarmEnabled and waitTime < 10 do
                task.wait(1)
                waitTime = waitTime + 1
            end
            
            Mining = false
            if CurrentTween then
                CurrentTween:Cancel()
                CurrentTween = nil
            end
            
            if not AutoFarmEnabled then break end
            task.wait(1)
        end
        
        if AutoFarmEnabled then
            print("Completed cycle, starting over...")
            task.wait(2)
        end
    end
    
    FarmingLoop = false
end

-- Get ALL valid rock locations (only those with Models in SpawnLocation)
local validRockLocations = getValidRockLocations()

-- Set default location if available
if #validRockLocations > 0 then
    SelectedLocation = validRockLocations[1]
end

-- Location dropdown (shows ONLY locations with Models)
Tab:Dropdown({
    Title = "Select Rock Location",
    List = validRockLocations,
    Value = SelectedLocation,
    Callback = function(choice)
        SelectedLocation = choice
        print("Selected:", choice)
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
        print("Speed:", val)
    end
})

-- Auto Farm toggle
Tab:Toggle({
    Title = "Auto Farm",
    Desc = "Toggle auto farming",
    Value = false,
    Callback = function(v)
        AutoFarmEnabled = v
        
        if v then
            if #validRockLocations == 0 then
                Window:Notify({
                    Title = "Error",
                    Desc = "No valid rock locations found!",
                    Time = 3
                })
                return
            end
            
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Started farming at selected location",
                Time = 3
            })
            
            -- Start farming at selected location
            task.spawn(function()
                tweenToRockLocation(SelectedLocation)
            end)
        else
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Stopped farming",
                Time = 3
            })
            
            Mining = false
            FarmingLoop = false
            if CurrentTween then
                CurrentTween:Cancel()
                CurrentTween = nil
            end
        end
    end
})

-- Button to farm ALL locations
Tab:Button({
    Title = "Farm All Locations",
    Desc = "Farm ALL valid locations",
    Callback = function()
        if #validRockLocations == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "No valid locations to farm!",
                Time = 3
            })
            return
        end
        
        Window:Notify({
            Title = "Auto Farm",
            Desc = "Starting to farm ALL " .. #validRockLocations .. " locations",
            Time = 4
        })
        
        AutoFarmEnabled = true
        task.spawn(autoFarmAllLocations)
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
        if FarmingLoop then
            task.spawn(autoFarmAllLocations)
        else
            task.spawn(function()
                tweenToRockLocation(SelectedLocation)
            end)
        end
    end
end)

-- Final notification
Window:Notify({
    Title = "x2zu Auto Farm",
    Desc = "Found " .. #validRockLocations .. " locations with Models",
    Time = 5
})

print("=== VALID ROCK LOCATIONS (with Models) ===")
print("Total valid locations:", #validRockLocations)
for i, loc in ipairs(validRockLocations) do
    print(i .. ". " .. loc)
end
print("=========================================")
