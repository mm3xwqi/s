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

-- Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"})
Tab:Section({Title = "Auto Farm"})

-- Variables
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")

local SelectedLocation = "Island1CaveStart"
local AutoFarmEnabled = false
local TweenSpeed = 50
local CurrentTween = nil
local CurrentTarget = nil
local Farming = false
local Mining = false
local ToolService

-- Function to setup ToolService reference
local function setupToolService()
    ToolService = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
end

-- Setup ToolService
pcall(setupToolService)

-- Function to mine the target
local function mineTarget()
    if not ToolService or not AutoFarmEnabled then
        return false
    end
    
    Mining = true
    
    -- Try to mine continuously
    local startTime = tick()
    local maxMineTime = 10 -- maximum mining time in seconds
    
    while Mining and AutoFarmEnabled and CurrentTarget do
        local args = {"Pickaxe"}
        
        -- Invoke the mining server
        local success, result = pcall(function()
            return ToolService:InvokeServer(unpack(args))
        end)
        
        if not success then
            print("Mining failed:", result)
            break
        end
        
        -- Check if target is still alive
        if not isModelAlive(CurrentTarget) then
            print("Target mined successfully!")
            break
        end
        
        -- Check mining time
        if tick() - startTime > maxMineTime then
            print("Mining timeout")
            break
        end
        
        -- Wait a bit before next mining attempt
        task.wait(0.1)
    end
    
    Mining = false
    return true
end

-- Function to enable noclip
local function enableNoclip()
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Function to disable noclip
local function disableNoclip()
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Function to stop current tween
local function stopCurrentTween()
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
end

-- Function to check if model has health and if it's alive
local function isModelAlive(model)
    if not model or not model.Parent then
        return false
    end
    
    -- Look for Humanoid or Health value
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.Health > 0
    end
    
    -- Check for custom health value
    local healthValue = model:FindFirstChild("Health") or model:FindFirstChild("health") or model:FindFirstChild("HP")
    if healthValue and healthValue:IsA("NumberValue") then
        return healthValue.Value > 0
    end
    
    -- Check for BoolValue indicating alive/dead
    local aliveValue = model:FindFirstChild("Alive") or model:FindFirstChild("alive")
    if aliveValue and aliveValue:IsA("BoolValue") then
        return aliveValue.Value == true
    end
    
    -- If no health system found, assume it's alive
    return true
end

-- Function to find alive model in SpawnLocation
local function findAliveModelInSpawnLocation(spawnLocationPart)
    if not spawnLocationPart then
        return nil
    end
    
    -- Look for models inside SpawnLocation
    for _, child in ipairs(spawnLocationPart:GetChildren()) do
        if child:IsA("Model") then
            -- Check if model is alive
            if isModelAlive(child) then
                return child
            else
                print("Model " .. child.Name .. " is dead (health 0), skipping...")
            end
        end
    end
    
    return nil
end

-- Function to get valid target CFrame
local function getTargetCFrame(targetModel)
    if not targetModel then
        return nil
    end
    
    -- If Model has PrimaryPart use GetPivot()
    if targetModel.PrimaryPart then
        return targetModel:GetPivot()
    end
    
    -- If no PrimaryPart, find first BasePart
    for _, child in ipairs(targetModel:GetDescendants()) do
        if child:IsA("BasePart") then
            return child.CFrame
        end
    end
    
    -- If no BasePart found
    return nil
end

-- Function to get all locations in workspace.Rocks
local function getAllRockLocations()
    local locations = {}
    
    if workspace:FindFirstChild("Rocks") then
        for _, child in ipairs(workspace.Rocks:GetChildren()) do
            -- Check if this location has a SpawnLocation
            if child:FindFirstChild("SpawnLocation") then
                table.insert(locations, child.Name)
            end
        end
    end
    
    return locations
end

-- Function to check and farm all locations in sequence
local function checkAndFarmLocations()
    if not AutoFarmEnabled then
        Farming = false
        return
    end
    
    Farming = true
    
    -- Get all available locations
    local allLocations = getAllRockLocations()
    
    -- If specific location is selected and exists
    local locations = {}
    if SelectedLocation ~= "All" then
        -- Check if selected location exists
        local found = false
        for _, loc in ipairs(allLocations) do
            if loc == SelectedLocation then
                found = true
                break
            end
        end
        
        if found then
            locations = {SelectedLocation}
        else
            print("Selected location not found, using all available locations")
            locations = allLocations
        end
    else
        locations = allLocations
    end
    
    if #locations == 0 then
        Window:Notify({
            Title = "Auto Farm",
            Desc = "No rock locations found!",
            Time = 3
        })
        Farming = false
        return
    end
    
    print("Available locations: " .. table.concat(locations, ", "))
    
    -- Check each location
    for _, locationName in ipairs(locations) do
        if not AutoFarmEnabled then break end
        
        print("Checking location: " .. locationName)
        
        -- หา location ใน workspace.Rocks
        local locationFolder = workspace.Rocks:FindFirstChild(locationName)
        if not locationFolder then
            print("Location not found in Rocks folder: " .. locationName)
            task.wait(0.5)
            continue
        end
        
        -- หา SpawnLocation Part
        local spawnLocationPart = locationFolder:FindFirstChild("SpawnLocation")
        if not spawnLocationPart then
            print("No SpawnLocation found in " .. locationName)
            task.wait(0.5)
            continue
        end
        
        -- หา model ที่ยังมีชีวิตอยู่ใน SpawnLocation
        local targetModel = findAliveModelInSpawnLocation(spawnLocationPart)
        if not targetModel then
            print("No alive models found in " .. locationName .. ", skipping...")
            task.wait(0.5)
            continue
        end
        
        -- ตั้งค่า CurrentTarget
        CurrentTarget = targetModel
        
        -- ตรวจสอบว่ายังมีชีวิตอยู่หรือไม่
        if not isModelAlive(targetModel) then
            print("Model died before reaching, skipping...")
            task.wait(0.5)
            continue
        end
        
        print("Found alive model: " .. targetModel.Name .. " in " .. locationName)
        
        -- หา CFrame เป้าหมาย
        local targetCFrame = getTargetCFrame(targetModel)
        if not targetCFrame then
            print("Cannot get target position")
            task.wait(0.5)
            continue
        end
        
        -- เดินทางไปหา target
        Character = LocalPlayer.Character
        if not Character then
            Character = LocalPlayer.CharacterAdded:Wait()
        end
        
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        
        -- คำนวณระยะทางและเวลา tween
        local distance = (HumanoidRootPart.Position - targetCFrame.Position).Magnitude
        local tweenTime = distance / TweenSpeed
        if tweenTime < 0.1 then
            tweenTime = 0.1
        end
        
        -- สร้างและเริ่ม tween
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        
        CurrentTween = tween
        tween:Play()
        
        -- รอให้ tween เสร็จ
        local completed = false
        tween.Completed:Connect(function()
            completed = true
        end)
        
        -- รอจนกว่า tween จะเสร็จหรือ target ตาย
        while not completed and AutoFarmEnabled do
            -- ตรวจสอบว่า target ยังมีชีวิตอยู่หรือไม่
            if not isModelAlive(CurrentTarget) then
                print("Target died while traveling, canceling tween...")
                stopCurrentTween()
                break
            end
            
            -- ตรวจสอบว่า target ยังอยู่ใน workspace หรือไม่
            if not CurrentTarget:IsDescendantOf(workspace) then
                print("Target removed from workspace, canceling tween...")
                stopCurrentTween()
                break
            end
            
            task.wait(0.1)
        end
        
        if completed then
            print("Successfully reached target at " .. locationName)
            
            -- เริ่มทำการขุดทันทีที่ถึง
            if AutoFarmEnabled and CurrentTarget and isModelAlive(CurrentTarget) then
                print("Starting mining...")
                mineTarget()
            end
        end
        
        -- รอสักครู่ก่อนไปที่อันต่อไป
        task.wait(1)
        
        -- Clear current target
        CurrentTarget = nil
    end
    
    -- ถ้ายังเปิด AutoFarm อยู่ ให้เริ่มใหม่
    if AutoFarmEnabled then
        print("Finished checking all locations, starting over...")
        task.wait(1)
        checkAndFarmLocations()
    else
        Farming = false
    end
end

-- Get initial locations
local availableLocations = getAllRockLocations()
if #availableLocations == 0 then
    availableLocations = {"Island1CaveStart", "Island1CaveMid", "Island1CaveDeep", "Roof"}
end

-- Dropdown for selecting location
Tab:Dropdown({
    Title = "Select Tween Location",
    List = availableLocations,
    Value = SelectedLocation,
    Callback = function(choice)
        SelectedLocation = choice
        print("Selected location:", choice)
        
        -- ถ้า AutoFarm กำลังทำงานอยู่ ให้รีสตาร์ทด้วย location ใหม่
        if AutoFarmEnabled then
            stopCurrentTween()
            Mining = false
            task.wait(0.5)
            if Farming then
                task.wait(0.1)
                checkAndFarmLocations()
            end
        end
    end
})

-- Slider for Tween Speed
Tab:Slider({
    Title = "Tween Speed",
    Min = 10,
    Max = 200,
    Rounding = 0,
    Value = TweenSpeed,
    Callback = function(val)
        TweenSpeed = val
        print("Tween Speed set to:", val)
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
                Desc = "Started auto farming",
                Time = 3
            })
            
            -- เริ่ม farming process
            task.spawn(checkAndFarmLocations)
        else
            -- ปิด Auto Farm
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Stopped auto farming",
                Time = 3
            })
            
            stopCurrentTween()
            disableNoclip()
            Farming = false
            Mining = false
            CurrentTarget = nil
        end
    end
})

-- Character added event to update references
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    task.wait(0.5) -- รอให้ Character โหลดเสร็จ
    if Character then
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        
        -- Reconnect ToolService when character respawns
        pcall(setupToolService)
        
        -- ถ้า AutoFarm กำลังทำงานอยู่ ให้รีสตาร์ท
        if AutoFarmEnabled and Farming then
            stopCurrentTween()
            task.wait(1)
            checkAndFarmLocations()
        end
    end
end)

-- Auto noclip when auto farming is enabled
RunService.Stepped:Connect(function()
    if AutoFarmEnabled and Character then
        enableNoclip()
    end
end)

-- Character removed event
LocalPlayer.CharacterRemoving:Connect(function()
    stopCurrentTween()
    CurrentTarget = nil
    Mining = false
end)

-- Monitor target health
RunService.Heartbeat:Connect(function()
    if AutoFarmEnabled and CurrentTarget and Character then
        -- ตรวจสอบว่า target ยังมีชีวิตอยู่หรือไม่
        if not isModelAlive(CurrentTarget) then
            print("Target died, stopping tween...")
            stopCurrentTween()
            CurrentTarget = nil
            Mining = false
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
print("Will auto-detect available rock locations")
print("Will mine automatically when reaching target")
print("ToolService initialized: " .. tostring(ToolService ~= nil))
