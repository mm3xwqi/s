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
local noclipEnabled = false
local noclipConnection = nil

-- Remote setup
local toolRemote = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")

-- Function to get the single farm location from SpawnLocation
local function getFarmLocation()
    local locations = {
        "workspace.Rocks.Island1CaveStart.SpawnLocation",
        "workspace.Rocks.Island1CaveMid.SpawnLocation", 
        "workspace.Rocks.Island1CaveDeep.SpawnLocation",
        "workspace.Rocks.Roof.SpawnLocation"
    }
    
    for _, path in ipairs(locations) do
        local parts = path:split(".")
        local current = workspace
        
        for i = 2, #parts do
            current = current:FindFirstChild(parts[i])
            if not current then
                break
            end
        end
        
        if current and current:IsA("BasePart") then
            -- Get the Model name that contains the SpawnLocation
            local modelName = current.Parent and current.Parent.Name or "Unknown"
            return {
                Path = path,
                Location = current,
                ModelName = modelName
            }
        end
    end
    
    return nil
end

-- Get the single farm location
local farmLocation = getFarmLocation()

-- Noclip functions
local function enableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if character and noclipEnabled then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Tween function with noclip
local function tweenToLocation()
    if not farmLocation or not farmLocation.Location:IsA("BasePart") then return end
    
    -- Enable noclip during tween if setting is on
    local wasNoclipEnabled = noclipEnabled
    if noclipEnabled then
        enableNoclip()
    end
    
    -- Create tween info
    local location = farmLocation.Location
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
    local success, errorMsg = pcall(function()
        tween.Completed:Wait()
    end)
    
    -- Activate tool
    if success then
        toolRemote:InvokeServer("Pickaxe")
    end
    
    -- Disable noclip after tween if it wasn't enabled before
    if noclipEnabled and not wasNoclipEnabled then
        disableNoclip()
    end
    
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
        while autoFarmEnabled do
            pcall(function()
                tweenToLocation()
            end)
            task.wait(0.1) -- Small delay between cycles
        end
    end)
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Status display
    MainTab:Label({
        Title = "Farm Location Status",
        Desc = farmLocation and ("Found: " .. farmLocation.ModelName) or "No SpawnLocation found!"
    })
    
    if farmLocation then
        MainTab:Label({
            Title = "Path",
            Desc = farmLocation.Path
        })
    end
    
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
    
    -- Noclip Toggle
    MainTab:Toggle({
        Title = "Noclip during Tween",
        Desc = "Enable noclip while moving to target",
        Value = false,
        Callback = function(v)
            noclipEnabled = v
            if v then
                Window:Notify({
                    Title = "Noclip",
                    Desc = "Noclip will be active during tween",
                    Time = 3
                })
            else
                disableNoclip()
            end
            print("Noclip during Tween:", v)
        end
    })
    
    -- Auto Farm Toggle
    MainTab:Toggle({
        Title = "Auto Farm",
        Desc = farmLocation and ("Enable/Disable automatic farming at: " .. farmLocation.ModelName) or "No farm location found",
        Value = false,
        Callback = function(v)
            if not farmLocation then
                Window:Notify({
                    Title = "Error",
                    Desc = "No farm location found!",
                    Time = 3
                })
                return
            end
            
            autoFarmEnabled = v
            if v then
                startAutoFarm()
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Started farming at: " .. farmLocation.ModelName,
                    Time = 3
                })
            else
                if autoFarmThread then
                    task.cancel(autoFarmThread)
                    autoFarmThread = nil
                end
                disableNoclip() -- Ensure noclip is disabled when stopping
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
        Title = "Teleport to Farm",
        Desc = "Teleport once to farm location",
        Callback = function()
            if not farmLocation then
                Window:Notify({
                    Title = "Error",
                    Desc = "No farm location found!",
                    Time = 3
                })
                return
            end
            
            pcall(function()
                tweenToLocation()
                Window:Notify({
                    Title = "Teleport",
                    Desc = "Teleported to " .. farmLocation.ModelName,
                    Time = 3
                })
            end)
        end
    })
    
    -- Refresh Button
    MainTab:Button({
        Title = "Refresh Location",
        Desc = "Reload farm location",
        Callback = function()
            farmLocation = getFarmLocation()
            if farmLocation then
                Window:Notify({
                    Title = "Refreshed",
                    Desc = "Found farm: " .. farmLocation.ModelName,
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Not Found",
                    Desc = "No SpawnLocation found in any of the paths",
                    Time = 3
                })
            end
        end
    })
end

-- Character handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    repeat task.wait() until character:FindFirstChild("HumanoidRootPart")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- Re-enable noclip if it was on
    if noclipEnabled then
        enableNoclip()
    end
end)

-- Disable noclip when script stops
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    disableNoclip()
end)

-- Initial Notification
if farmLocation then
    Window:Notify({
        Title = "Auto Farm Loaded",
        Desc = "Found farm at: " .. farmLocation.ModelName .. ". Enable Auto Farm to start!",
        Time = 4
    })
else
    Window:Notify({
        Title = "Warning",
        Desc = "No SpawnLocation found in any of the 4 paths. Click Refresh to retry.",
        Time = 5
    })
end
