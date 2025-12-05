-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "The Forge1",
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
local farmDropdown = nil
local farmPartsCache = {}

-- Remote setup
local toolRemote = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")

-- Function to get all parts inside SpawnLocations
local function getFarmParts()
    local farmData = {}
    
    -- Define paths to check
    local paths = {
        "workspace.Rocks.Island1CaveStart",
        "workspace.Rocks.Island1CaveMid",
        "workspace.Rocks.Island1CaveDeep",
        "workspace.Rocks.Roof"
    }
    
    for _, path in ipairs(paths) do
        local parts = path:split(".")
        local current = workspace
        
        for i = 2, #parts do
            current = current:FindFirstChild(parts[i])
            if not current then
                break
            end
        end
        
        if current then
            for _, model in ipairs(current:GetChildren()) do
                if model:IsA("Model") then
                    local spawnLocation = model:FindFirstChild("SpawnLocation")
                    if spawnLocation and spawnLocation:IsA("BasePart") then
                        -- Get all BaseParts inside the SpawnLocation
                        for _, child in ipairs(spawnLocation:GetChildren()) do
                            if child:IsA("BasePart") then
                                table.insert(farmData, {
                                    Name = child.Name .. " [" .. model.Name .. "]",
                                    ModelName = model.Name,
                                    PartName = child.Name,
                                    Location = child,
                                    ParentModel = model
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    
    farmPartsCache = farmData
    return farmData
end

-- Function to get part by display name
local function getPartByName(displayName)
    for _, data in ipairs(farmPartsCache) do
        if data.Name == displayName then
            return data.Location
        end
    end
    
    -- If not in cache, search again
    local farmData = getFarmParts()
    for _, data in ipairs(farmData) do
        if data.Name == displayName then
            return data.Location
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

-- Tween function to part inside SpawnLocation
local function tweenToPart(partName)
    if not partName or partName == "" then return end
    
    local targetPart = getPartByName(partName)
    if not targetPart or not targetPart:IsA("BasePart") then return end
    
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
        while autoFarmEnabled and selectedFarm ~= "" do
            pcall(function()
                tweenToPart(selectedFarm)
            end)
            task.wait(0.1) -- Small delay between cycles
        end
    end)
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Auto Farm Section
    MainTab:Section({Title = "Auto Farm"})
    
    -- Get initial farm parts
    local initialFarmParts = getFarmParts()
    local initialDisplayNames = {}
    
    for _, data in ipairs(initialFarmParts) do
        table.insert(initialDisplayNames, data.Name)
    end
    
    -- Create dropdown with initial data
    if #initialDisplayNames > 0 then
        farmDropdown = MainTab:Dropdown({
            Title = "Select Farm",
            List = initialDisplayNames,
            Value = initialDisplayNames[1],
            Callback = function(choice)
                selectedFarm = choice
                print("Selected Farm:", choice)
            end
        })
        selectedFarm = initialDisplayNames[1]
    else
        farmDropdown = MainTab:Dropdown({
            Title = "Select Farm",
            List = {"No Parts found in SpawnLocations"},
            Value = "No Parts found in SpawnLocations",
            Callback = function(choice)
                selectedFarm = choice
            end
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
                if selectedFarm == "" or selectedFarm == "No Parts found in SpawnLocations" then
                    Window:Notify({
                        Title = "Error",
                        Desc = "No farm part available!",
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
        Desc = "Teleport once to selected farm part",
        Callback = function()
            if selectedFarm == "" or selectedFarm == "No Parts found in SpawnLocations" then
                Window:Notify({
                    Title = "Error",
                    Desc = "No farm part selected!",
                    Time = 3
                })
                return
            end
            
            pcall(function()
                tweenToPart(selectedFarm)
                Window:Notify({
                    Title = "Teleport",
                    Desc = "Teleported to: " .. selectedFarm,
                    Time = 3
                })
            end)
        end
    })
    
    -- Manual Refresh Button
    MainTab:Button({
        Title = "Refresh Farm List",
        Desc = "Refresh and update farm parts list",
        Callback = function()
            local farmData = getFarmParts()
            
            if #farmData > 0 then
                local displayNames = {}
                for _, data in ipairs(farmData) do
                    table.insert(displayNames, data.Name)
                end
                
                -- Recreate the dropdown with new data
                if farmDropdown then
                    -- Since we can't update, we'll notify user to reselect
                    Window:Notify({
                        Title = "Farm List Updated",
                        Desc = #farmData .. " parts found. Please check the list.",
                        Time = 3
                    })
                    
                    -- Update selected farm if the previous selection still exists
                    local found = false
                    for _, name in ipairs(displayNames) do
                        if name == selectedFarm then
                            found = true
                            break
                        end
                    end
                    
                    if not found and #displayNames > 0 then
                        selectedFarm = displayNames[1]
                        Window:Notify({
                            Title = "Selection Reset",
                            Desc = "Previous selection not found. Reset to: " .. displayNames[1],
                            Time = 3
                        })
                    end
                end
            else
                Window:Notify({
                    Title = "No Parts Found",
                    Desc = "No parts found inside SpawnLocations",
                    Time = 3
                })
                selectedFarm = ""
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
local farmData = getFarmParts()
if #farmData > 0 then
    Window:Notify({
        Title = "Auto Farm Loaded",
        Desc = #farmData .. " parts found in SpawnLocations",
        Time = 4
    })
else
    Window:Notify({
        Title = "Warning",
        Desc = "No parts found inside SpawnLocations. Click Refresh to retry.",
        Time = 5
    })
end
