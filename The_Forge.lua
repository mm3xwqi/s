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
    -- Look for Humanoid or Health value
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.Health > 0
    end
    
    -- Check for custom health value
    local healthValue = model:FindFirstChild("Health") or model:FindFirstChild("health")
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
    
    -- ถ้า Model มี PrimaryPart ใช้ GetPivot()
    if targetModel.PrimaryPart then
        return targetModel:GetPivot()
    end
    
    -- ถ้าไม่มี PrimaryPart ให้หา BasePart แรกที่เจอ
    for _, child in ipairs(targetModel:GetDescendants()) do
        if child:IsA("BasePart") then
            return child.CFrame
        end
    end
    
    -- ถ้าไม่เจอ BasePart เลย
    return nil
end

-- Function to check and farm all locations in sequence
local function checkAndFarmLocations()
    if not AutoFarmEnabled then
        Farming = false
        return
    end
    
    Farming = true
    
    -- List of locations to check in order
    local locations = {
        "Island1CaveStart",
        "Island1CaveMid", 
        "Island1CaveDeep",
        "Roof"
    }
    
    -- If specific location is selected, only check that one
    if SelectedLocation ~= "All" then
        locations = {SelectedLocation}
    end
    
    -- Check each location
    for _, locationName in ipairs(locations) do
        if not AutoFarmEnabled then break end
        
        print("Checking location: " .. locationName)
        
        -- หา location ใน workspace.Rocks
        local locationFolder = workspace.Rocks:FindFirstChild(locationName)
        if not locationFolder then
            print("Location not found: " .. locationName)
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
        
        -- รอสักครู่ก่อนไปที่อันต่อไป
        task.wait(1)
        
        -- ตรวจสอบอีกครั้งว่า target ยังมีชีวิตอยู่
        if CurrentTarget and isModelAlive(CurrentTarget) then
            print("Successfully reached target at " .. locationName)
            -- รอสักครู่ที่ target
            task.wait(2)
        end
        
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

-- Dropdown for selecting location
Tab:Dropdown({
    Title = "Select Tween Location",
    List = {
        "Island1CaveStart",
        "Island1CaveMid", 
        "Island1CaveDeep",
        "Roof"
    },
    Value = SelectedLocation,
    Callback = function(choice)
        SelectedLocation = choice
        print("Selected location:", choice)
        
        -- ถ้า AutoFarm กำลังทำงานอยู่ ให้รีสตาร์ทด้วย location ใหม่
        if AutoFarmEnabled then
            stopCurrentTween()
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
            if not SelectedLocation then
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Please select a location first!",
                    Time = 3
                })
                return
            end
            
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Started auto farming at: " .. SelectedLocation,
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
end)

-- Monitor target health
RunService.Heartbeat:Connect(function()
    if AutoFarmEnabled and CurrentTarget and Character then
        -- ตรวจสอบว่า target ยังมีชีวิตอยู่หรือไม่
        if not isModelAlive(CurrentTarget) then
            print("Target died, stopping tween...")
            stopCurrentTween()
            CurrentTarget = nil
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
print("Will check health of models before tweening")
print("If health is 0, will skip to next location")
