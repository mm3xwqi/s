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

local SelectedLocation = nil
local AutoFarmEnabled = false
local TweenSpeed = 50

-- Function to find target model in SpawnLocation
local function findTargetModel(spawnLocation)
    if spawnLocation then
        for _, child in ipairs(spawnLocation:GetChildren()) do
            if child:IsA("Model") and child ~= spawnLocation then
                return child
            end
        end
    end
    return nil
end

-- Function to enable noclip
local function enableNoclip()
    if Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

-- Function to tween to location
local function tweenToLocation()
    if not AutoFarmEnabled or not SelectedLocation then
        return
    end
    
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    local spawnLocation = workspace.Rocks:FindFirstChild(SelectedLocation)
    if not spawnLocation then
        Window:Notify({
            Title = "Auto Farm",
            Desc = "Location not found: " .. SelectedLocation,
            Time = 3
        })
        return
    end
    
    local targetModel = findTargetModel(spawnLocation)
    if not targetModel then
        Window:Notify({
            Title = "Auto Farm",
            Desc = "No target model found in " .. SelectedLocation,
            Time = 3
        })
        return
    end
    
    local targetCFrame = targetModel:GetPivot()
    
    enableNoclip()
    
    local tweenInfo = TweenInfo.new(
        (HumanoidRootPart.Position - targetCFrame.Position).Magnitude / TweenSpeed,
        Enum.EasingStyle.Linear
    )
    
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    tween.Completed:Connect(function()
        if AutoFarmEnabled then
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
    Value = "Island1CaveStart",
    Callback = function(choice)
        SelectedLocation = choice
        print("Selected location:", choice)
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

-- Auto Farm Toggle with integrated functionality
Tab:Toggle({
    Title = "Auto Farm",
    Desc = "Toggle to start/stop auto farming",
    Value = false,
    Callback = function(v)
        AutoFarmEnabled = v
        
        if v then
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
            
            -- Start tweening
            task.spawn(tweenToLocation)
        else
            Window:Notify({
                Title = "Auto Farm",
                Desc = "Stopped auto farming",
                Time = 3
            })
        end
    end
})

-- Character added event to update references
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Character:WaitForChild("HumanoidRootPart")
end)

-- Auto noclip when auto farming is enabled
game:GetService("RunService").Stepped:Connect(function()
    if AutoFarmEnabled and Character then
        enableNoclip()
    end
end)

-- Final Notification
Window:Notify({
    Title = "x2zu",
    Desc = "Auto Farm system loaded successfully!",
    Time = 4
})
