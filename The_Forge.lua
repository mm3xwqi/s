-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "the forge8",
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

local AutoFarmEnabled = false
local TweenSpeed = 100
local Mining = false
local CurrentTween = nil

-- Remote setup
local ToolService
local function setupRemote()
    ToolService = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
end
pcall(setupRemote)

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

-- Tween to location function
local function tweenToLocation(locationName)
    if not AutoFarmEnabled then return end
    
    -- Get the location folder
    local locationFolder = workspace.Rocks:FindFirstChild(locationName)
    if not locationFolder then
        print("Location not found:", locationName)
        return
    end
    
    -- Find SpawnLocation inside
    local spawnLocation = locationFolder:FindFirstChild("SpawnLocation")
    if not spawnLocation then
        print("SpawnLocation not found in:", locationName)
        return
    end
    
    -- Find Model inside SpawnLocation
    local targetModel
    for _, child in ipairs(spawnLocation:GetChildren()) do
        if child:IsA("Model") then
            targetModel = child
            break
        end
    end
    
    if not targetModel then
        print("No Model found in SpawnLocation")
        return
    end
    
    -- Get character
    local char, hrp = getCharacter()
    if not char or not hrp then return end
    
    -- Get target position
    local targetCFrame
    if targetModel.PrimaryPart then
        targetCFrame = targetModel:GetPivot()
    else
        -- Find any BasePart
        for _, part in ipairs(targetModel:GetDescendants()) do
            if part:IsA("BasePart") then
                targetCFrame = part.CFrame
                break
            end
        end
    end
    
    if not targetCFrame then
        print("Cannot get target position")
        return
    end
    
    -- Calculate tween time based on distance and speed
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local tweenTime = distance / TweenSpeed
    
    -- Cancel current tween if exists
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
    
    -- Create and play tween
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    CurrentTween:Play()
    
    -- When tween completes
    CurrentTween.Completed:Connect(function()
        if AutoFarmEnabled then
            -- Start mining when reached
            startMining()
            -- Wait and go to next location
            task.wait(1)
            tweenToLocation(locationName)
        end
    end)
end

-- Main auto farm loop
local function autoFarmLoop()
    while AutoFarmEnabled do
        -- Get current selected location
        local currentLocation = SelectedLocation
        
        if currentLocation then
            tweenToLocation(currentLocation)
        else
            print("No location selected")
        end
        
        -- Wait before next check
        task.wait(1)
    end
end

-- Location dropdown
local SelectedLocation = "Island1CaveStart"
Tab:Dropdown({
    Title = "Select Location",
    List = {
        "Island1CaveStart",
        "Island1CaveMid",
        "Island1CaveDeep",
        "Roof"
    },
    Value = SelectedLocation,
    Callback = function(choice)
        SelectedLocation = choice
        print("Location selected:", choice)
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
        print("Speed set to:", val)
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
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Started farming at: " .. SelectedLocation,
                Time = 3
            })
            
            -- Start auto farm
            task.spawn(autoFarmLoop)
        else
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Stopped farming",
                Time = 3
            })
            
            -- Stop mining and tween
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
        task.wait(1) -- Wait for character to load
        task.spawn(autoFarmLoop)
    end
end)

-- Final notification
Window:Notify({
    Title = "x2zu Auto Farm",
    Desc = "Script loaded successfully!",
    Time = 4
})

print("Auto Farm Script Loaded")
print("Locations: Island1CaveStart, Island1CaveMid, Island1CaveDeep, Roof")
