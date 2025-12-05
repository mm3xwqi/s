-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "The Forge2",
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

-- Function to get all Models inside SpawnLocations
local function getFarmModels()
    local farmData = {}
    
    -- Define paths to check
    local paths = {
        "Island1CaveStart",
        "Island1CaveMid",
        "Island1CaveDeep",
        "Roof"
    }
    
    local rocksFolder = workspace:FindFirstChild("Rocks")
    if not rocksFolder then
        warn("Rocks folder not found in workspace!")
        return farmData
    end
    
    for _, locationName in ipairs(paths) do
        local locationFolder = rocksFolder:FindFirstChild(locationName)
        if locationFolder then
            print("Checking folder:", locationName)
            
            -- Check each Model in the location folder
            for _, model in ipairs(locationFolder:GetChildren()) do
                if model:IsA("Model") then
                    print("Found model:", model.Name)
                    
                    -- Look for SpawnLocation inside the model
                    local spawnLocation = model:FindFirstChild("SpawnLocation")
                    if spawnLocation and spawnLocation:IsA("BasePart") then
                        print("Found SpawnLocation in model:", model.Name)
                        
                        -- Now look for Models inside the SpawnLocation
                        for _, child in ipairs(spawnLocation:GetChildren()) do
                            if child:IsA("Model") then
                                -- Look for a PrimaryPart in the model to tween to
                                local targetPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                                if targetPart then
                                    table.insert(farmData, {
                                        DisplayName = child.Name .. " [" .. locationName .. "]",
                                        ModelName = child.Name,
                                        LocationName = locationName,
                                        ParentModel = model.Name,
                                        TargetPart = targetPart,
                                        FullModel = child
                                    })
                                    print("Added farm model:", child.Name, "in", locationName)
                                end
                            end
                        end
                    end
                end
            end
        else
            warn("Location not found:", locationName)
        end
    end
    
    return farmData
end

-- Function to get model by display name
local function getFarmModelByName(displayName)
    local farmData = getFarmModels()
    
    for _, data in ipairs(farmData) do
        if data.DisplayName == displayName then
            return data.TargetPart
        end
    end
    
    return nil
end

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

-- Tween function to Model inside SpawnLocation
local function tweenToModel(displayName)
    if not displayName or displayName == "" then return end
    
    local targetPart = getFarmModelByName(displayName)
    if not targetPart or not targetPart:IsA("BasePart") then 
        print("Target part not found for:", displayName)
        return 
    end
    
    print("Tweening to:", displayName, "at position:", targetPart.Position)
    
    -- Enable noclip during tween if setting is on
    local wasNoclipEnabled = noclipEnabled
    if noclipEnabled then
        enableNoclip()
    end
    
    -- Create tween info
    local distance = (humanoidRootPart.Position - targetPart.Position).Magnitude
    local duration = distance / tweenSpeed
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    -- Create tween to the part
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetPart.CFrame})
    tween:Play()
    
    -- Wait for tween to complete
    local success, errorMsg = pcall(function()
        tween.Completed:Wait()
    end)
    
    if success then
        print("Tween completed successfully")
        -- Activate tool
        toolRemote:InvokeServer("Pickaxe")
    else
        warn("Tween failed:", errorMsg)
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
        while autoFarmEnabled and selectedFarm ~= "" do
            pcall(function()
                tweenToModel(selectedFarm)
            end)
            task.wait(0.1) -- Small delay between cycles
        end
    end)
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Get initial farm models
    local initialFarmModels = getFarmModels()
    local displayNames = {}
    
    for _, data in ipairs(initialFarmModels) do
        table.insert(displayNames, data.DisplayName)
    end
    
    -- Debug info
    print("Found", #displayNames, "farm models")
    for i, name in ipairs(displayNames) do
        print(i .. ". " .. name)
    end
    
    -- Create dropdown
    local farmDropdown
    if #displayNames > 0 then
        farmDropdown = MainTab:Dropdown({
            Title = "Select Farm",
            Desc = "Choose a model to farm",
            List = displayNames,
            Value = displayNames[1],
            Callback = function(choice)
                selectedFarm = choice
                print("Selected Farm:", choice)
            end
        })
        selectedFarm = displayNames[1]
    else
        farmDropdown = MainTab:Dropdown({
            Title = "Select Farm",
            Desc = "No models found",
            List = {"No models found in SpawnLocations"},
            Value = "No models found in SpawnLocations",
            Callback = function() end
        })
        selectedFarm = ""
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
        Desc = "Enable/Disable automatic farming",
        Value = false,
        Callback = function(v)
            autoFarmEnabled = v
            if v then
                if selectedFarm == "" or selectedFarm == "No models found in SpawnLocations" then
                    Window:Notify({
                        Title = "Error",
                        Desc = "No farm model selected!",
                        Time = 3
                    })
                    autoFarmEnabled = false
                    return
                end
                
                -- Refresh model list before starting
                local currentModels = getFarmModels()
                local found = false
                for _, model in ipairs(currentModels) do
                    if model.DisplayName == selectedFarm then
                        found = true
                        break
                    end
                end
                
                if not found then
                    Window:Notify({
                        Title = "Error",
                        Desc = "Selected model no longer exists!",
                        Time = 3
                    })
                    autoFarmEnabled = false
                    return
                end
                
                startAutoFarm()
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Started farming: " .. selectedFarm,
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
    
    -- Teleport Button
    MainTab:Button({
        Title = "Teleport to Farm",
        Desc = "Teleport once to selected farm model",
        Callback = function()
            if selectedFarm == "" or selectedFarm == "No models found in SpawnLocations" then
                Window:Notify({
                    Title = "Error",
                    Desc = "No farm model selected!",
                    Time = 3
                })
                return
            end
            
            pcall(function()
                tweenToModel(selectedFarm)
                Window:Notify({
                    Title = "Teleport",
                    Desc = "Teleported to: " .. selectedFarm,
                    Time = 3
                })
            end)
        end
    })
    
    -- Refresh Button
    MainTab:Button({
        Title = "Refresh Models",
        Desc = "Refresh the list of farm models",
        Callback = function()
            local farmModels = getFarmModels()
            
            if #farmModels > 0 then
                local newDisplayNames = {}
                for _, data in ipairs(farmModels) do
                    table.insert(newDisplayNames, data.DisplayName)
                end
                
                -- Check if current selection still exists
                local currentExists = false
                for _, name in ipairs(newDisplayNames) do
                    if name == selectedFarm then
                        currentExists = true
                        break
                    end
                end
                
                if not currentExists and #newDisplayNames > 0 then
                    selectedFarm = newDisplayNames[1]
                    Window:Notify({
                        Title = "Selection Updated",
                        Desc = "Found " .. #newDisplayNames .. " models. Selection reset to first.",
                        Time = 3
                    })
                else
                    Window:Notify({
                        Title = "Models Refreshed",
                        Desc = "Found " .. #newDisplayNames .. " models.",
                        Time = 3
                    })
                end
            else
                selectedFarm = ""
                Window:Notify({
                    Title = "No Models Found",
                    Desc = "No models found in SpawnLocations",
                    Time = 3
                })
            end
        end
    })
    
    -- Debug Info Button
    MainTab:Button({
        Title = "Debug Info",
        Desc = "Show current farm structure info",
        Callback = function()
            local farmModels = getFarmModels()
            local info = "Farm Structure:\n"
            
            if #farmModels == 0 then
                info = info .. "No models found.\n"
                info = info .. "Checking workspace.Rocks..."
                
                if workspace:FindFirstChild("Rocks") then
                    info = info .. "\n✓ Rocks folder exists"
                    local rocks = workspace.Rocks
                    for _, child in ipairs(rocks:GetChildren()) do
                        info = info .. "\n- " .. child.Name
                    end
                else
                    info = info .. "\n✗ Rocks folder not found!"
                end
            else
                info = info .. "Found " .. #farmModels .. " models:\n"
                for i, model in ipairs(farmModels) do
                    info = info .. i .. ". " .. model.DisplayName .. "\n"
                end
            end
            
            print(info)
            Window:Notify({
                Title = "Debug Info",
                Desc = "Check console (F9) for details",
                Time = 3
            })
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
local farmModels = getFarmModels()
if #farmModels > 0 then
    Window:Notify({
        Title = "Auto Farm Loaded",
        Desc = "Found " .. #farmModels .. " farm models. Select one and enable Auto Farm.",
        Time = 4
    })
else
    Window:Notify({
        Title = "Warning",
        Desc = "No models found in SpawnLocations. Click Debug Info to check structure.",
        Time = 5
    })
end
