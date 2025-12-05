-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "the forge7",
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

local SelectedLocation = "Island1CaveStart"
local AutoFarmEnabled = false
local TweenSpeed = 100
local Moving = false
local CurrentTarget = nil
local Farming = false
local Mining = false
local ToolService
local Velocity = nil

-- Function to get character safely
local function getCharacter()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nil
    end
    
    return char, hrp
end

-- Function to setup ToolService reference
local function setupToolService()
    local success, result = pcall(function()
        ToolService = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
        return true
    end)
    
    if not success then
        print("Failed to setup ToolService:", result)
        ToolService = nil
    end
    
    return success
end

-- Setup ToolService
setupToolService()

-- Function to check all possible location names
local function getAllPossibleLocations()
    local possibleNames = {}
    
    -- Check for locations in Rocks folder
    if workspace:FindFirstChild("Rocks") then
        for _, child in ipairs(workspace.Rocks:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                if child:FindFirstChild("SpawnLocation") then
                    table.insert(possibleNames, child.Name)
                end
            end
        end
    end
    
    -- If no locations found, use default names
    if #possibleNames == 0 then
        possibleNames = {"Island1CaveStart", "Island1CaveMid", "Island1CaveDeep", "Roof"}
    end
    
    return possibleNames
end

-- Function to find spawn location by name
local function findSpawnLocationByName(locationName)
    if not workspace:FindFirstChild("Rocks") then
        return nil
    end
    
    -- Try to find exact match first
    local rockFolder = workspace.Rocks:FindFirstChild(locationName)
    if rockFolder then
        local spawnLoc = rockFolder:FindFirstChild("SpawnLocation")
        if spawnLoc then
            return spawnLoc
        end
    end
    
    -- Try case insensitive search
    for _, child in ipairs(workspace.Rocks:GetChildren()) do
        if string.lower(child.Name) == string.lower(locationName) then
            local spawnLoc = child:FindFirstChild("SpawnLocation")
            if spawnLoc then
                return spawnLoc
            end
        end
    end
    
    -- Try partial match
    for _, child in ipairs(workspace.Rocks:GetChildren()) do
        if string.find(string.lower(child.Name), string.lower(locationName)) then
            local spawnLoc = child:FindFirstChild("SpawnLocation")
            if spawnLoc then
                return spawnLoc
            end
        end
    end
    
    return nil
end

-- Function to mine the target continuously
local function mineTarget()
    if not ToolService or not AutoFarmEnabled then
        return false
    end
    
    if not CurrentTarget then
        return false
    end
    
    Mining = true
    local mineAttempts = 0
    local maxAttempts = 20
    
    print("Starting mining...")
    
    while Mining and AutoFarmEnabled and CurrentTarget and mineAttempts < maxAttempts do
        local args = {"Pickaxe"}
        
        -- Invoke the mining server
        local success, result = pcall(function()
            ToolService:InvokeServer(unpack(args))
            return true
        end)
        
        if success then
            print("Mining attempt " .. mineAttempts + 1 .. " successful")
        else
            print("Mining failed:", result)
        end
        
        mineAttempts = mineAttempts + 1
        
        -- Check if target is still alive
        if not isModelAlive(CurrentTarget) then
            print("Target mined successfully!")
            break
        end
        
        task.wait(0.2)
    end
    
    Mining = false
    return true
end

-- Function to enable noclip
local function enableNoclip()
    local char, hrp = getCharacter()
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Function to disable noclip
local function disableNoclip()
    local char, hrp = getCharacter()
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- Function to stop movement
local function stopMovement()
    Moving = false
    
    -- Remove BodyVelocity
    if Velocity then
        pcall(function()
            Velocity:Destroy()
        end)
        Velocity = nil
    end
end

-- Function to check if model has health and if it's alive
local function isModelAlive(model)
    if not model or not model.Parent then
        return false
    end
    
    -- Look for Humanoid
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health then
        return humanoid.Health > 0
    end
    
    -- Check for custom health value
    local healthValue = model:FindFirstChild("Health") or model:FindFirstChild("health") or model:FindFirstChild("HP")
    if healthValue then
        if healthValue:IsA("NumberValue") or healthValue:IsA("IntValue") then
            return healthValue.Value > 0
        end
    end
    
    -- Check for BoolValue
    local aliveValue = model:FindFirstChild("Alive") or model:FindFirstChild("alive")
    if aliveValue and aliveValue:IsA("BoolValue") then
        return aliveValue.Value == true
    end
    
    -- Default to true if no health system
    return true
end

-- Function to find alive model in SpawnLocation
local function findAliveModelInSpawnLocation(spawnLocation)
    if not spawnLocation then
        return nil
    end
    
    -- Look for models inside SpawnLocation
    for _, child in ipairs(spawnLocation:GetChildren()) do
        if child:IsA("Model") then
            if isModelAlive(child) then
                return child
            else
                print("Model " .. child.Name .. " is dead, skipping...")
            end
        end
    end
    
    return nil
end

-- Function to get valid target position
local function getTargetPosition(targetModel)
    if not targetModel then
        return nil
    end
    
    -- If Model has PrimaryPart use its position
    if targetModel.PrimaryPart then
        return targetModel.PrimaryPart.Position
    end
    
    -- If no PrimaryPart, find first BasePart
    for _, child in ipairs(targetModel:GetDescendants()) do
        if child:IsA("BasePart") then
            return child.Position
        end
    end
    
    -- If no BasePart found
    return nil
end

-- Function to move to target using BodyVelocity only
local function moveToTarget(targetPosition)
    if not AutoFarmEnabled or not targetPosition then
        return false
    end
    
    local char, hrp = getCharacter()
    if not char or not hrp then
        return false
    end
    
    stopMovement()
    Moving = true
    
    -- Create BodyVelocity
    Velocity = Instance.new("BodyVelocity")
    Velocity.MaxForce = Vector3.new(400000, 400000, 400000)
    Velocity.P = 10000
    Velocity.Velocity = Vector3.new(0, 0, 0)
    Velocity.Parent = hrp
    
    local startTime = tick()
    local timeout = 10 -- seconds
    
    while Moving and AutoFarmEnabled do
        -- Check character
        local currentChar, currentHrp = getCharacter()
        if not currentChar or not currentHrp then
            stopMovement()
            return false
        end
        
        -- Check timeout
        if tick() - startTime > timeout then
            print("Movement timeout")
            stopMovement()
            return false
        end
        
        -- Check distance
        local distance = (currentHrp.Position - targetPosition).Magnitude
        
        if distance < 5 then
            print("Reached target")
            stopMovement()
            return true
        end
        
        -- Calculate direction
        local direction = (targetPosition - currentHrp.Position).Unit
        
        -- Set velocity
        if Velocity and Velocity.Parent then
            Velocity.Velocity = direction * TweenSpeed
        else
            stopMovement()
            return false
        end
        
        task.wait(0.1)
    end
    
    stopMovement()
    return false
end

-- Main farming function
local function startFarming()
    if Farming or not AutoFarmEnabled then
        return
    end
    
    Farming = true
    
    while AutoFarmEnabled do
        -- Check character
        local char, hrp = getCharacter()
        if not char or not hrp then
            task.wait(1)
            continue
        end
        
        -- Find spawn location
        local spawnLocation = findSpawnLocationByName(SelectedLocation)
        
        if not spawnLocation then
            print("Could not find spawn location: " .. SelectedLocation)
            task.wait(2)
            continue
        end
        
        -- Find alive model
        local targetModel = findAliveModelInSpawnLocation(spawnLocation)
        
        if not targetModel then
            print("No alive models found at " .. SelectedLocation)
            task.wait(2)
            continue
        end
        
        CurrentTarget = targetModel
        
        -- Get target position
        local targetPosition = getTargetPosition(targetModel)
        
        if not targetPosition then
            print("Could not get target position")
            CurrentTarget = nil
            task.wait(1)
            continue
        end
        
        print("Moving to target at " .. SelectedLocation)
        
        -- Move to target
        local reached = moveToTarget(targetPosition)
        
        if reached and AutoFarmEnabled and CurrentTarget and isModelAlive(CurrentTarget) then
            print("Starting mining process...")
            mineTarget()
        end
        
        -- Wait before next cycle
        CurrentTarget = nil
        task.wait(1)
    end
    
    Farming = false
end

-- Get available locations
local availableLocations = getAllPossibleLocations()

-- Dropdown for selecting location
Tab:Dropdown({
    Title = "Select Tween Location",
    List = availableLocations,
    Value = SelectedLocation,
    Callback = function(choice)
        SelectedLocation = choice
        print("Selected location:", choice)
    end
})

-- Slider for Movement Speed
Tab:Slider({
    Title = "Movement Speed",
    Min = 50,
    Max = 300,
    Rounding = 0,
    Value = TweenSpeed,
    Callback = function(val)
        TweenSpeed = val
        print("Movement Speed set to:", val)
    end
})

-- Auto Farm Toggle
Tab:Toggle({
    Title = "Auto Farm",
    Desc = "Toggle to start/stop auto farming",
    Value = false,
    Callback = function(v)
        AutoFarmEnabled = v
        
        if v then
            -- เปิด Auto Farm
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Started auto farming at: " .. SelectedLocation,
                Time = 3
            })
            
            -- Start farming process
            task.spawn(startFarming)
        else
            -- ปิด Auto Farm
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Stopped auto farming",
                Time = 3
            })
            
            stopMovement()
            disableNoclip()
            Farming = false
            Mining = false
            CurrentTarget = nil
        end
    end
})

-- Character added event
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    
    -- Reconnect ToolService
    setupToolService()
    
    -- Restart farming if enabled
    if AutoFarmEnabled then
        stopMovement()
        task.wait(0.5)
        if not Farming then
            task.spawn(startFarming)
        end
    end
end)

-- Auto noclip when auto farming is enabled
RunService.Stepped:Connect(function()
    if AutoFarmEnabled then
        local char, hrp = getCharacter()
        if char then
            enableNoclip()
        end
    end
end)

-- Cleanup on character removal
LocalPlayer.CharacterRemoving:Connect(function()
    stopMovement()
    CurrentTarget = nil
    Mining = false
end)

-- Heartbeat for safety checks
RunService.Heartbeat:Connect(function()
    if AutoFarmEnabled then
        -- Check character
        local char, hrp = getCharacter()
        if not char or not hrp then
            stopMovement()
        end
        
        -- Check target while mining
        if Mining and CurrentTarget then
            if not isModelAlive(CurrentTarget) then
                Mining = false
                print("Target died during mining")
            end
        end
    end
end)

-- Final Notification
Window:Notify({
    Title = "x2zu",
    Desc = "Auto Farm system loaded successfully!",
    Time = 4
})

print("Auto Farm Script Loaded")
print("Available locations: " .. table.concat(availableLocations, ", "))
print("Using BodyVelocity only for movement")
