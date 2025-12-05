-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "Auto Farm Script",
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

-- Variables
local tweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local autoFarmEnabled = false
local selectedFarm = ""
local tweenSpeed = 50

-- Remote setup
local toolRemote = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")

-- Farm locations
local farmLocations = {
    ["Island1 Cave Start"] = workspace.Rocks.Island1CaveStart.SpawnLocation,
    ["Island1 Cave Mid"] = workspace.Rocks.Island1CaveMid.SpawnLocation,
    ["Island1 Cave Deep"] = workspace.Rocks.Island1CaveDeep.SpawnLocation,
    ["Roof"] = workspace.Rocks.Roof.SpawnLocation
}

-- Function to get rock name from location
local function getRockName(locationPart)
    local parent = locationPart.Parent
    if parent and parent:IsA("Model") then
        return parent.Name
    end
    return "Rock"
end

-- Tween function
local function tweenToLocation(location)
    if not location or not location:IsA("BasePart") then return end
    
    -- Create tween info
    local distance = (humanoidRootPart.Position - location.Position).Magnitude
    local duration = distance / tweenSpeed
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    -- Create tween
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = location.CFrame})
    tween:Play()
    
    -- Wait for tween to complete
    tween.Completed:Wait()
    
    -- Activate tool
    toolRemote:InvokeServer("Pickaxe")
    
    -- Small delay before returning
    task.wait(0.5)
end

-- Auto farm loop
local autoFarmThread
local function startAutoFarm()
    if autoFarmThread then
        task.cancel(autoFarmThread)
        autoFarmThread = nil
    end
    
    autoFarmThread = task.spawn(function()
        while autoFarmEnabled and selectedFarm ~= "" do
            local location = farmLocations[selectedFarm]
            if location then
                pcall(function()
                    tweenToLocation(location)
                end)
            end
            task.wait(0.1) -- Small delay between cycles
        end
    end)
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Farm Selection Dropdown
    local farmDropdown = MainTab:Dropdown({
        Title = "Select Farm",
        List = {"Island1 Cave Start", "Island1 Cave Mid", "Island1 Cave Deep", "Roof"},
        Value = "Island1 Cave Start",
        Callback = function(choice)
            selectedFarm = choice
            print("Selected Farm:", choice)
        end
    })
    
    -- Tween Speed Slider
    MainTab:Slider({
        Title = "Tween Speed",
        Desc = "Higher = faster movement",
        Min = 10,
        Max = 200,
        Rounding = 0,
        Value = 50,
        Callback = function(val)
            tweenSpeed = val
            print("Tween Speed set to:", val)
        end
    })
    
    -- Auto Farm Toggle
    MainTab:Toggle({
        Title = "Auto Farm",
        Desc = "Enable/Disable automatic farming",
        Value = false,
        Callback = function(v)
            autoFarmEnabled = v
            if v then
                if selectedFarm == "" then
                    Window:Notify({
                        Title = "Error",
                        Desc = "Please select a farm location first!",
                        Time = 3
                    })
                    autoFarmEnabled = false
                    return
                end
                startAutoFarm()
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Started farming at: " .. selectedFarm,
                    Time = 3
                })
            else
                if autoFarmThread then
                    task.cancel(autoFarmThread)
                    autoFarmThread = nil
                end
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Stopped farming",
                    Time = 3
                })
            end
            print("Auto Farm:", v)
        end
    })
    
    -- Teleport Button (for testing)
    MainTab:Button({
        Title = "Teleport to Selected",
        Desc = "Teleport once to selected location",
        Callback = function()
            if selectedFarm == "" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Please select a farm location first!",
                    Time = 3
                })
                return
            end
            
            local location = farmLocations[selectedFarm]
            if location then
                pcall(function()
                    tweenToLocation(location)
                    Window:Notify({
                        Title = "Teleport",
                        Desc = "Teleported to " .. selectedFarm,
                        Time = 3
                    })
                end)
            end
        end
    })
end

-- Character handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    repeat task.wait() until character:FindFirstChild("HumanoidRootPart")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
end)

-- Initial Notification
Window:Notify({
    Title = "Auto Farm Loaded",
    Desc = "Select a location and toggle Auto Farm to start!",
    Time = 4
})
