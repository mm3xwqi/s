local Library
local success, errorMsg = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
end)

if not success or not Library then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
end

local Window = Library:Window({
    Title = "_mm3",
    Desc = "_mm3 Undetected",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "_mm3"
    }
})

-- Services
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerGUI = player:WaitForChild("PlayerGui")

-- Fishing variables
local autoReel = false
local autoCast = false
local autoShake = false
local autoEquip = false
local autoSell = false
local autoTeleport = false
local perfectCatch = false
local perfectCast = false
local safeMode = true
local reelAfterSeconds = 2

local castDelay = 0.5
local shakeDelay = 0.1
local sellDelay = 5

local isCasting = false
local reelRunning = false
local shakeRunning = false
local equipRunning = false
local sellRunning = false
local teleportRunning = false

local savedPosition = nil
local selectedIsland = ""

-- Get fishing rod names
local rodNames = {}
local rodsFolder = ReplicatedStorage:WaitForChild("resources"):WaitForChild("items"):WaitForChild("rods")
for _, rod in ipairs(rodsFolder:GetChildren()) do
    table.insert(rodNames, rod.Name)
end

-- Island teleport locations
local islandLocations = {
    {Name = "Carrot Garden", Position = Vector3.new(3744, -1116, -1108)},
    {Name = "Underground Music Venue", Position = Vector3.new(2043, -645, 2471)},
    {Name = "Luminescent Cavern", Position = Vector3.new(-1016, -337, -4071)},
    {Name = "Crimson Cavern", Position = Vector3.new(-1013, -340, -4891)},
    {Name = "Oscar's Locker", Position = Vector3.new(266, -387, 3407)},
    {Name = "The Boom Ball", Position = Vector3.new(-1296, -900, -3479)},
    {Name = "Lost Jungle", Position = Vector3.new(-2690, 149, -2051)},
    {Name = "XP Farm", Position = Vector3.new(1373, -603, 2336)}
}

-- Anti-cheat bypass system
local bypassEnabled = true
local originalFireServer
local originalInvokeServer

local function SetupBypass()
    if not bypassEnabled then return end
    
    if not originalFireServer then
        originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
            local args = {...}
            
            if autoReel and self.Name == "reelfinished" then
                if #args >= 2 then
                    return originalFireServer(self, 100, true)
                end
            end
            
            return originalFireServer(self, ...)
        end)
    end
    
    if not originalInvokeServer then
        originalInvokeServer = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(self, ...)
            local args = {...}
            
            if autoCast and self.Name == "castAsync" then
                if #args >= 2 then
                    return originalInvokeServer(self, 100, true)
                end
            end

            if autoSell and self.Name == "SellAll" then
                return originalInvokeServer(self, ...)
            end
            
            return originalInvokeServer(self, ...)
        end)
    end
end

local function RestoreBypass()
    if originalFireServer then
        hookfunction(Instance.new("RemoteEvent").FireServer, originalFireServer)
        originalFireServer = nil
    end
    
    if originalInvokeServer then
        hookfunction(Instance.new("RemoteFunction").InvokeServer, originalInvokeServer)
        originalInvokeServer = nil
    end
end

-- Auto equip rod system
local function EquipBestRod()
    local character = player.Character
    if not character then return end
    
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end

    local hasRod = false
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and table.find(rodNames, tool.Name) then
            hasRod = true
            break
        end
    end

    if hasRod then return end

    for _, rodName in ipairs(rodNames) do
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == rodName then
                tool.Parent = character
                return
            end
        end
    end
end

local function StartAutoEquip()
    if equipRunning then return end
    equipRunning = true
    
    task.spawn(function()
        while autoEquip do
            EquipBestRod()
            task.wait(0.1)
        end
        equipRunning = false
    end)
end

-- Island teleport system
local function LoadIslandList()
    local islands = {}

    local success, tpFolder = pcall(function()
        return workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
    end)
    
    if success and tpFolder then
        for _, spot in ipairs(tpFolder:GetChildren()) do
            table.insert(islands, spot.Name)
        end
    end

    for _, location in ipairs(islandLocations) do
        table.insert(islands, location.Name)
    end

    table.sort(islands, function(a, b) 
        return a:lower() < b:lower() 
    end)
    
    return islands
end

local function TeleportToSelectedIsland()
    if not selectedIsland or selectedIsland == "" then
        Window:Notify({
            Title = "Error",
            Desc = "Please select an island first!",
            Time = 3
        })
        return
    end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Window:Notify({
            Title = "Error",
            Desc = "Character not found!",
            Time = 3
        })
        return
    end

    local targetPos = nil
    for _, location in ipairs(islandLocations) do
        if location.Name == selectedIsland then
            targetPos = location.Position
            break
        end
    end

    if not targetPos then
        local success, tpFolder = pcall(function()
            return workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
        end)
        if success and tpFolder then
            local spot = tpFolder:FindFirstChild(selectedIsland)
            if spot and spot:IsA("Part") then
                targetPos = spot.Position
            end
        end
    end

    if targetPos then
        character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        Window:Notify({
            Title = "Teleported",
            Desc = "Warped to " .. selectedIsland,
            Time = 3
        })
    else
        Window:Notify({
            Title = "Error",
            Desc = "Island location not found: " .. selectedIsland,
            Time = 3
        })
    end
end

-- Sell system
local function SellAllItems()
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("events")
        if events then
            local sellAll = events:FindFirstChild("SellAll")
            if sellAll then
                sellAll:InvokeServer()
                Window:Notify({
                    Title = "Items Sold",
                    Desc = "All items sold successfully",
                    Time = 2
                })
            end
        end
    end)
end

local function StartAutoSell()
    if sellRunning then return end
    sellRunning = true
    
    task.spawn(function()
        while autoSell do
            SellAllItems()
            task.wait(sellDelay)
        end
        sellRunning = false
    end)
end

-- Fishing functions
local function HasRodEquipped()
    local character = player.Character
    if not character then return false end
    
    for _, rodName in ipairs(rodNames) do
        if character:FindFirstChild(rodName) then
            return true
        end
    end
    return false
end

local function GetCurrentRod()
    local character = player.Character
    if not character then return nil end
    
    for _, rodName in ipairs(rodNames) do
        local rod = character:FindFirstChild(rodName)
        if rod then
            return rod
        end
    end
    return nil
end

local function HasBobber()
    local playerWorkspace = workspace:FindFirstChild(player.Name)
    if playerWorkspace then
        for _, rodName in ipairs(rodNames) do
            local rod = playerWorkspace:FindFirstChild(rodName)
            if rod and rod:FindFirstChild("bobber") then
                return true
            end
        end
    end
    return false
end

local function FollowFishBar()
    local ok, result = pcall(function()
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then return false end
        
        local reel = gui:FindFirstChild("reel")
        if not reel then return false end
        
        local bar = reel:FindFirstChild("bar")
        if not bar then return false end
        
        local fish = bar:FindFirstChild("fish")
        local playerBar = bar:FindFirstChild("playerbar")
        
        if fish and playerBar and fish:IsA("GuiObject") and playerBar:IsA("GuiObject") then
            playerBar.Position = UDim2.new(fish.Position.X.Scale, 0, playerBar.Position.Y.Scale, 0)
            return true
        end
        
        return false
    end)
    
    if not ok then
        return false
    end
    
    return result
end

local function IsReelGUIVisible()
    local ok, result = pcall(function()
        local reel = player.PlayerGui:FindFirstChild("reel")
        return reel and reel:IsA("ScreenGui") and reel.Enabled
    end)
    return ok and result
end

local function SetReelAfterSeconds(value)
    reelAfterSeconds = value
    Window:Notify({
        Title = "Reel Timer Set",
        Desc = "Will reel after " .. value .. " seconds when fishing starts",
        Time = 3
    })
end

-- Auto reel system
local function StartAutoReel()
    if reelRunning then return end
    reelRunning = true

    task.spawn(function()
        while autoReel do
            while autoReel and not IsReelGUIVisible() do
                task.wait(0.1)
            end
            
            if autoReel and IsReelGUIVisible() then
                local startTime = tick()
                while autoReel and IsReelGUIVisible() and (tick() - startTime) < reelAfterSeconds do
                    if safeMode then
                        FollowFishBar()
                    end
                    task.wait()
                end
                
                if autoReel and IsReelGUIVisible() then
                    pcall(function()
                        local events = ReplicatedStorage:FindFirstChild("events")
                        if events then
                            local reelFinish = events:FindFirstChild("reelfinished")
                            if reelFinish then
                                local isPerfect = perfectCatch
                                reelFinish:FireServer(100, isPerfect)
                            end
                        end
                    end)

                    while autoReel and IsReelGUIVisible() do
                        task.wait(0.1)
                    end
                end
            end
            
            task.wait(0.1)
        end
        reelRunning = false
    end)
end

local followConnection

local function StartFollowFishBar()
    if followConnection then 
        followConnection:Disconnect()
        followConnection = nil
    end
    
    if safeMode then
        followConnection = RunService.Heartbeat:Connect(function()
            if IsReelGUIVisible() then
                FollowFishBar()
            end
        end)
    end
end

-- Auto cast system
local castConnection
local lastCastTime = 0

local function StartAutoCast()
    if castConnection then castConnection:Disconnect() end
    
    castConnection = RunService.Heartbeat:Connect(function()
        if not autoCast then return end
        
        local currentTime = tick()
        
        if HasRodEquipped() and not HasBobber() and not isCasting and (currentTime - lastCastTime) >= castDelay then
            isCasting = true
            
            pcall(function()
                local rod = GetCurrentRod()
                if rod and rod:FindFirstChild("events") then
                    local castFunc = rod.events:FindFirstChild("castAsync")
                    if castFunc then
                        local castValue = perfectCast and 100 or 50
                        castFunc:InvokeServer(castValue, perfectCast)
                    end
                end
            end)
            
            lastCastTime = currentTime
            
            task.delay(0.1, function()
                isCasting = false
            end)
        end
    end)
end

-- Auto shake system
local function StartAutoShake()
    if shakeRunning then return end
    shakeRunning = true
    
    task.spawn(function()
        while autoShake do
            local shakeUI = PlayerGUI:FindFirstChild("shakeui")
            if shakeUI and shakeUI.Enabled then
                local safezone = shakeUI:FindFirstChild("safezone")
                if safezone then
                    local button = safezone:FindFirstChild("button")
                    if button and button:IsA("ImageButton") and button.Visible then
                        GuiService.SelectedObject = button
                        task.wait()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait()
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                end
            end
            task.wait(shakeDelay)
        end
        shakeRunning = false
    end)
end

-- Position system
local function SaveCurrentPosition()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        savedPosition = character.HumanoidRootPart.CFrame
        Window:Notify({
            Title = "Position Saved",
            Desc = "Current position saved!",
            Time = 3
        })
    else
        Window:Notify({
            Title = "Error",
            Desc = "Character not found!",
            Time = 3
        })
    end
end

local function TeleportToSavedPosition()
    if savedPosition then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = savedPosition
            Window:Notify({
                Title = "Teleported",
                Desc = "Warped to saved position!",
                Time = 3
            })
        end
    else
        Window:Notify({
            Title = "Error",
            Desc = "No position saved!",
            Time = 3
        })
    end
end

-- Auto teleport system
local teleportConnection
local function StartAutoTeleport()
    if teleportConnection then teleportConnection:Disconnect() end
    
    teleportConnection = RunService.Heartbeat:Connect(function()
        if not autoTeleport then return end
        if not savedPosition or teleportRunning then return end
        
        teleportRunning = true
        
        pcall(function()
            TeleportToSavedPosition()
        end)
        
        task.delay(1, function()
            teleportRunning = false
        end)
    end)
end

-- Initialize bypass
SetupBypass()

-- Create main tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"})

-- Fishing section
MainTab:Section({Title = "Fishing"})

MainTab:Toggle({
    Title = "Auto Reel",
    Desc = "Automatically reel fish after set seconds when fishing starts",
    Value = false,
    Callback = function(value)
        autoReel = value
        if value then
            StartAutoReel()
            Window:Notify({
                Title = "Auto Reel",
                Desc = "Auto reel enabled - Will reel after " .. reelAfterSeconds .. " seconds when fishing starts",
                Time = 3
            })
        else
            reelRunning = false
        end
    end
})

MainTab:Toggle({
    Title = "Auto Cast",
    Desc = "Automatically cast rod",
    Value = false,
    Callback = function(value)
        autoCast = value
        if value then
            StartAutoCast()
            Window:Notify({
                Title = "Auto Cast",
                Desc = "Auto cast enabled",
                Time = 3
            })
        else
            if castConnection then
                castConnection:Disconnect()
                castConnection = nil
            end
            isCasting = false
        end
    end
})

MainTab:Toggle({
    Title = "Auto Shake",
    Desc = "Automatically shake rod",
    Value = false,
    Callback = function(value)
        autoShake = value
        if value then
            StartAutoShake()
            Window:Notify({
                Title = "Auto Shake",
                Desc = "Auto shake enabled",
                Time = 3
            })
        else
            shakeRunning = false
        end
    end
})

MainTab:Toggle({
    Title = "Auto Equip Rod",
    Desc = "Automatically equip fishing rod",
    Value = false,
    Callback = function(value)
        autoEquip = value
        if value then
            StartAutoEquip()
            Window:Notify({
                Title = "Auto Equip",
                Desc = "Auto equip enabled",
                Time = 3
            })
        else
            equipRunning = false
        end
    end
})

-- Reel Settings section
MainTab:Section({Title = "Reel Settings"})

MainTab:Slider({
    Title = "Reel After Seconds",
    Desc = "Recommend 2 sec+",
    Value = 2,
    Min = 1,
    Max = 10,
    Callback = function(value)
        SetReelAfterSeconds(value)
    end
})

MainTab:Toggle({
    Title = "Safe Mode",
    Desc = "Bar follow fish automatically",
    Value = true,
    Callback = function(value)
        safeMode = value
        StartFollowFishBar()
        Window:Notify({
            Title = "Safe Mode",
            Desc = value and "Safe mode enabled" or "Safe mode disabled",
            Time = 3
        })
    end
})

MainTab:Section({Title = "Perfect Settings"})

MainTab:Toggle({
    Title = "Perfect Catch",
    Desc = "Always get perfect catch",
    Value = false,
    Callback = function(value)
        perfectCatch = value
        Window:Notify({
            Title = "Perfect Catch",
            Desc = value and "Perfect catch enabled" or "Perfect catch disabled",
            Time = 3
        })
    end
})

MainTab:Toggle({
    Title = "Perfect Cast",
    Desc = "Always perfect cast",
    Value = false,
    Callback = function(value)
        perfectCast = value
        Window:Notify({
            Title = "Perfect Cast",
            Desc = value and "Perfect cast enabled" or "Perfect cast disabled",
            Time = 3
        })
    end
})

-- Sell section
MainTab:Section({Title = "Selling"})

MainTab:Toggle({
    Title = "Auto Sell All",
    Desc = "Automatically sell all items",
    Value = false,
    Callback = function(value)
        autoSell = value
        if value then
            StartAutoSell()
            Window:Notify({
                Title = "Auto Sell",
                Desc = "Selling every " .. sellDelay .. " seconds",
                Time = 3
            })
        else
            sellRunning = false
        end
    end
})

MainTab:Textbox({
    Title = "Sell Interval",
    Desc = "Time between auto sells (seconds)",
    Placeholder = "5",
    Value = "5",
    ClearTextOnFocus = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            sellDelay = num
            Window:Notify({
                Title = "Interval Set",
                Desc = "Sell interval: " .. sellDelay .. " seconds",
                Time = 3
            })
        else
            Window:Notify({
                Title = "Error",
                Desc = "Please enter a valid number",
                Time = 3
            })
        end
    end
})

MainTab:Button({
    Title = "Sell All Now",
    Desc = "Sell all items immediately",
    Callback = SellAllItems
})

-- Teleport section
MainTab:Section({Title = "Teleport"})

MainTab:Button({
    Title = "Save Position",
    Desc = "Save current position",
    Callback = SaveCurrentPosition
})

MainTab:Toggle({
    Title = "Auto Teleport",
    Desc = "Automatically teleport to saved position",
    Value = false,
    Callback = function(value)
        autoTeleport = value
        if value then
            if savedPosition then
                StartAutoTeleport()
                Window:Notify({
                    Title = "Auto Teleport",
                    Desc = "Auto teleport enabled",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "No position saved!",
                    Time = 3
                })
                autoTeleport = false
            end
        else
            if teleportConnection then
                teleportConnection:Disconnect()
                teleportConnection = nil
            end
            teleportRunning = false
        end
    end
})

-- Settings section
MainTab:Section({Title = "Settings"})

MainTab:Slider({
    Title = "Cast Delay",
    Desc = "Delay between casts (seconds)",
    Value = 0.5,
    Min = 0.1,
    Max = 5,
    Callback = function(value)
        castDelay = value
    end
})

MainTab:Slider({
    Title = "Shake Delay",
    Desc = "Delay between shakes (seconds)",
    Value = 0.1,
    Min = 0.1,
    Max = 1,
    Callback = function(value)
        shakeDelay = value
    end
})

-- Island teleport tab
local TeleportTab = Window:Tab({Title = "Islands", Icon = "map-pin"})

TeleportTab:Section({Title = "Island Teleport"})

local availableIslands = LoadIslandList()
TeleportTab:Dropdown({
    Title = "Select Island",
    Desc = "Choose island to teleport to",
    List = availableIslands,
    Value = availableIslands[1] or "",
    Callback = function(value)
        selectedIsland = value
    end
})

TeleportTab:Button({
    Title = "Teleport to Island",
    Desc = "Teleport to selected island",
    Callback = TeleportToSelectedIsland
})

-- Cleanup function
local function Cleanup()
    RestoreBypass()
    
    if castConnection then castConnection:Disconnect() end
    if teleportConnection then teleportConnection:Disconnect() end
    if followConnection then followConnection:Disconnect() end
    
    reelRunning = false
    shakeRunning = false
    equipRunning = false
    sellRunning = false
    teleportRunning = false
end

-- Auto cleanup when GUI is closed
Window:OnClose(Cleanup)

-- เริ่มต้นติดตาม fish bar ทันที
StartFollowFishBar()

-- Initial notification
Window:Notify({
    Title = "mm3 Hub Loaded",
    Desc = "Script ready!",
    Time = 5
})
