-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "The Forge",
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

-- Function to find target model in SpawnLocation Model
local function findTargetModel(spawnLocationModel)
    if not spawnLocationModel or not spawnLocationModel:IsA("Model") then
        return nil
    end
    
    -- ถ้า SpawnLocation Model เองมี PrimaryPart ก็ใช้มันเลย
    if spawnLocationModel.PrimaryPart then
        return spawnLocationModel
    end
    
    -- ลองหา Model อื่นภายใน SpawnLocation
    for _, child in ipairs(spawnLocationModel:GetChildren()) do
        if child:IsA("Model") and child ~= spawnLocationModel then
            if child.PrimaryPart then
                return child
            end
        end
    end
    
    -- ถ้าไม่เจออะไรเลย ก็ใช้ SpawnLocation Model เอง
    return spawnLocationModel
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

-- Function to tween to location
local function tweenToLocation()
    if not AutoFarmEnabled or not SelectedLocation then
        return
    end
    
    -- รอให้ Character พร้อม
    Character = LocalPlayer.Character
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- หา location ใน workspace.Rocks
    local locationFolder = workspace.Rocks:FindFirstChild(SelectedLocation)
    if not locationFolder then
        Window:Notify({
            Title = "Auto Farm",
            Desc = "Location not found: " .. SelectedLocation,
            Time = 3
        })
        stopCurrentTween()
        return
    end
    
    -- หา SpawnLocation Model
    local spawnLocationModel = locationFolder:FindFirstChild("SpawnLocation")
    if not spawnLocationModel then
        Window:Notify({
            Title = "Auto Farm",
            Desc = "No SpawnLocation found in " .. SelectedLocation,
            Time = 3
        })
        stopCurrentTween()
        return
    end
    
    -- หา target model
    local targetModel = findTargetModel(spawnLocationModel)
    if not targetModel then
        Window:Notify({
            Title = "Auto Farm",
            Desc = "No valid target model found",
            Time = 3
        })
        stopCurrentTween()
        return
    end
    
    -- ตรวจสอบว่ายังมี targetModel อยู่หรือไม่ (ป้องกันถ้ามันหายไป)
    if not targetModel:IsDescendantOf(workspace) then
        Window:Notify({
            Title = "Auto Farm",
            Desc = "Target model disappeared, skipping...",
            Time = 3
        })
        stopCurrentTween()
        task.wait(0.5)
        tweenToLocation()
        return
    end
    
    -- หา CFrame เป้าหมาย
    local targetCFrame = getTargetCFrame(targetModel)
    if not targetCFrame then
        Window:Notify({
            Title = "Auto Farm",
            Desc = "Cannot get target position",
            Time = 3
        })
        stopCurrentTween()
        return
    end
    
    -- คำนวณระยะทางและเวลา tween
    local distance = (HumanoidRootPart.Position - targetCFrame.Position).Magnitude
    if distance < 5 then
        -- ถ้าอยู่ใกล้แล้วให้รอสักครู่แล้วเริ่มใหม่
        task.wait(1)
        tweenToLocation()
        return
    end
    
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
    tween.Completed:Connect(function()
        CurrentTween = nil
        
        if AutoFarmEnabled then
            -- รอสักครู่แล้วเริ่มใหม่
            task.wait(0.5)
            tweenToLocation()
        end
    end)
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
            task.wait(0.1)
            tweenToLocation()
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
            
            -- เริ่ม tweening
            task.spawn(tweenToLocation)
        else
            -- ปิด Auto Farm
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Stopped auto farming",
                Time = 3
            })
            
            stopCurrentTween()
            disableNoclip()
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
        if AutoFarmEnabled then
            stopCurrentTween()
            task.wait(1)
            tweenToLocation()
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
end)

-- Final Notification
Window:Notify({
    Title = "x2zu",
    Desc = "Auto Farm system loaded successfully!",
    Time = 4
})

print("Auto Farm Script Loaded")
print("Available Locations:")
print("1. Island1CaveStart")
print("2. Island1CaveMid")
print("3. Island1CaveDeep")
print("4. Roof")
