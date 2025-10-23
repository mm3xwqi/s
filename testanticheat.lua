local Library
local success, errorMsg = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
end)

if not success or not Library then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
end

local Window = Library:Window({
    Title = "_mm3",
    Desc = "mm3 hub",
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

-- Variables
local AR = false
local AC = false
local AS = false
local TP = false
local autoEquipRodEnabled = false
local LCT = 0
local LRT = 0
local CI = 0.5
local RI = 2
local SI = 0.1
local casting = false
local teleporting = false
local autoshake_running = false
local autoEquipRod_running = false
local autoreel_running = false
local sellAllEnabled = false
local sellAllRunning = false
local sellInterval = 5

-- Saved Position
local savedCFrame = nil

-- Services
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local LocalPlayer = player
local PlayerGUI = player:WaitForChild("PlayerGui")

-- Get all rod names
local rodNames = {}
local rodsFolder = ReplicatedStorage:WaitForChild("resources"):WaitForChild("items"):WaitForChild("rods")
for _, rod in ipairs(rodsFolder:GetChildren()) do
    table.insert(rodNames, rod.Name)
end

-- Auto Equip Rod Functions
local function EquipRods()
    local char = player.Character
    if not char then return end
    
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end

    local hasRodInHand = false
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and table.find(rodNames, tool.Name) then
            hasRodInHand = true
            break
        end
    end

    if hasRodInHand then return end

    for _, rodName in ipairs(rodNames) do
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == rodName then
                tool.Parent = char
                return
            end
        end
    end
end

local function StartAutoEquipRod()
    if autoEquipRod_running then return end
    autoEquipRod_running = true
    task.spawn(function()
        while autoEquipRodEnabled do
            EquipRods()
            task.wait(.1)
        end
        autoEquipRod_running = false
    end)
end

local selectedIsland = ""
local teleportingToIsland = false
local extraTPs = {
    {Name = "Carrot Garden", Position = Vector3.new(3744, -1116, -1108)},
    {Name = "Crystal Cove", Position = Vector3.new(1364, -612, 2472)},
    {Name = "Underground Music Venue", Position = Vector3.new(2043, -645, 2471)},
    {Name = "Castaway Cliffs", Position = Vector3.new(655, 179, -1793)},
    {Name = "Luminescent Cavern", Position = Vector3.new(-1016, -337, -4071)},
    {Name = "Crimson Cavern", Position = Vector3.new(-1013, -340, -4891)},
    {Name = "Oscar's Locker", Position = Vector3.new(266, -387, 3407)},
    {Name = "The Boom Ball", Position = Vector3.new(-1296, -900, -3479)},
    {Name = "Lost Jungle", Position = Vector3.new(-2690, 149, -2051)}
}

local function TeleportToIsland()
    if not selectedIsland or selectedIsland == "" then
        Window:Notify({
            Title = "Error",
            Desc = "กรุณาเลือกเกาะก่อน!",
            Time = 3
        })
        return
    end

    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Window:Notify({
            Title = "Error",
            Desc = "ไม่พบตัวละคร!",
            Time = 3
        })
        return
    end

    local targetPosition = nil
    for _, tp in ipairs(extraTPs) do
        if tp.Name == selectedIsland then
            targetPosition = tp.Position
            break
        end
    end

    if not targetPosition then
        local success, tpFolder = pcall(function()
            return workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
        end)
        if success and tpFolder then
            local spot = tpFolder:FindFirstChild(selectedIsland)
            if spot and spot:IsA("Part") then
                targetPosition = spot.Position
            end
        end
    end

    if targetPosition then
        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        Window:Notify({
            Title = "Teleported",
            Desc = "วาปไปยัง " .. selectedIsland .. " แล้ว!",
            Time = 3
        })
    else
        Window:Notify({
            Title = "Error",
            Desc = "ไม่พบตำแหน่งเกาะ: " .. selectedIsland,
            Time = 3
        })
    end
end

local function StartIslandTeleport()
    if teleportingToIsland then return end
    teleportingToIsland = true
    
    task.spawn(function()
        while teleportingToIsland do
            TeleportToIsland()
            task.wait(2)
        end
    end)
end

local function LoadIslandList()
    local tpNames = {}

    local success, tpFolder = pcall(function()
        return workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
    end)
    
    if success and tpFolder then
        for _, spot in ipairs(tpFolder:GetChildren()) do
            table.insert(tpNames, spot.Name)
        end
    end

    for _, tp in ipairs(extraTPs) do
        table.insert(tpNames, tp.Name)
    end

    table.sort(tpNames, function(a, b) 
        return a:lower() < b:lower() 
    end)
    
    return tpNames
end

local hookEnabled = true
local originalFireServer
local originalInvokeServer
-- เพิ่มใน hook functions
local function setupHooks()
    if not hookEnabled then return end
    
    if not originalFireServer then
        originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
            local args = {...}
            
            if AR and self.Name == "reelfinished" then
                if #args >= 2 then
                    Window:Notify({
                        Title = "Bypass Anti-Cheat!",
                        Desc = "Auto Reel Bypass ทำงานแล้ว!",
                        Time = 3
                    })
                    return originalFireServer(self, 100, true)
                end
            end
            
            -- เพิ่ม bypass สำหรับ SellAll
            if sellAllEnabled and self.Name == "SellAll" then
                Window:Notify({
                    Title = "Bypass Anti-Cheat!",
                    Desc = "Sell All Bypass ทำงานแล้ว!",
                    Time = 3
                })
                return originalFireServer(self, ...)
            end
            
            return originalFireServer(self, ...)
        end)
    end
    
    if not originalInvokeServer then
        originalInvokeServer = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(self, ...)
            local args = {...}
            
            if AC and self.Name == "castAsync" then
                if #args >= 2 then
                    Window:Notify({
                        Title = "Bypass Anti-Cheat!",
                        Desc = "Auto Cast Bypass ทำงานแล้ว!",
                        Time = 3
                    })
                    return originalInvokeServer(self, 100, true)
                end
            end
            
            return originalInvokeServer(self, ...)
        end)
    end
    
    Window:Notify({
        Title = "Anti-Cheat Bypass ทำงานแล้ว!",
        Desc = "ระบบป้องกันถูกเปิดใช้งานสำเร็จ",
        Time = 5
    })
end

-- ฟังก์ชัน Sell All
local function SellAllItems()
    pcall(function()
        local events = ReplicatedStorage:FindFirstChild("events")
        if events then
            local sellAll = events:FindFirstChild("SellAll")
            if sellAll then
                sellAll:FireServer()
                Window:Notify({
                    Title = "ขายของแล้ว!",
                    Desc = "ขายไอเท็มทั้งหมดสำเร็จ",
                    Time = 3
                })
            end
        end
    end)
end

-- ฟังก์ชันเริ่ม Sell All อัตโนมัติ
local function StartAutoSellAll()
    if sellAllRunning then return end
    sellAllRunning = true
    
    task.spawn(function()
        while sellAllEnabled do
            SellAllItems()
            task.wait(sellInterval) -- รอตามเวลาที่กำหนดใน Textbox
        end
        sellAllRunning = false
    end)
end

local function restoreHooks()
    if originalFireServer then
        hookfunction(Instance.new("RemoteEvent").FireServer, originalFireServer)
        originalFireServer = nil
    end
    
    if originalInvokeServer then
        hookfunction(Instance.new("RemoteFunction").InvokeServer, originalInvokeServer)
        originalInvokeServer = nil
    end
end

setupHooks()

local function HR()
    local character = LocalPlayer.Character
    if not character then return false end
    
    for _, rodName in ipairs(rodNames) do
        if character:FindFirstChild(rodName) then
            return true
        end
    end
    return false
end

local function GR()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    for _, rodName in ipairs(rodNames) do
        local rod = character:FindFirstChild(rodName)
        if rod then
            return rod
        end
    end
    return nil
end

local function HB()
    local playerName = LocalPlayer.Name
    local playerWorkspace = workspace:FindFirstChild(playerName)
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

local function GetProgressBarScale()
    local ok, result = pcall(function()
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then return nil end
        local reel = gui:FindFirstChild("reel")
        if not reel then return nil end
        local bar = reel:FindFirstChild("bar")
        if not bar then return nil end
        local progress = bar:FindFirstChild("progress")
        if not progress then return nil end
        local inner = progress:FindFirstChild("bar")
        if not inner then return nil end
        if inner.Size and inner.Size.X and type(inner.Size.X.Scale) == "number" then
            return inner.Size.X.Scale
        end
        return nil
    end)
    if ok then
        return result
    else
        return nil
    end
end

local function StartAutoReel()
    if autoreel_running then return end
    autoreel_running = true

    task.spawn(function()
        while AR do
            local gui = player:FindFirstChild("PlayerGui")
            local reel = gui and gui:FindFirstChild("reel")

            while AR and gui and not reel do
                reel = gui:FindFirstChild("reel")
                task.wait(0.1)
            end

            if reel then
                local char = player.Character
                if char then
                    for _, rodName in ipairs(rodNames) do
                        local rod = char:FindFirstChild(rodName)
                        if rod then
                            while AR and reel and reel.Parent and rod.Parent == char do
                                local bar = reel:FindFirstChild("bar")
                                if bar then
                                    local fish = bar:FindFirstChild("fish")
                                    local playerbar = bar:FindFirstChild("playerbar")
                                    
                                    if fish and playerbar and fish:IsA("GuiObject") and playerbar:IsA("GuiObject") then
                                        pcall(function()
                                            playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
                                        end)
                                    end
                                end
                                local prog = GetProgressBarScale()
                                if prog and prog >= 0.45 then
                                    pcall(function()
                                        local events = ReplicatedStorage:FindFirstChild("events")
                                        if events then
                                            local reelfinished = events:FindFirstChild("reelfinished")
                                            if reelfinished then
                                                reelfinished:FireServer(100, false)
                                            end
                                        end
                                    end)
                                end
                                
                                task.wait()
                            end
                        end
                    end
                end
            end
            task.wait()
        end
        autoreel_running = false
    end)
end

-- Save current position
local function SavePosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        savedCFrame = character.HumanoidRootPart.CFrame
        Window:Notify({
            Title = "Position Saved",
            Desc = "ตำแหน่งถูกบันทึกแล้ว!",
            Time = 3
        })
    else
        Window:Notify({
            Title = "Error",
            Desc = "ไม่พบตัวละคร!",
            Time = 3
        })
    end
end

-- Teleport to saved position
local function TeleportToSavedPosition()
    if savedCFrame then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = savedCFrame
            Window:Notify({
                Title = "Teleported",
                Desc = "วาปไปยังตำแหน่งที่บันทึกแล้ว!",
                Time = 3
            })
        end
    else
        Window:Notify({
            Title = "Error",
            Desc = "ยังไม่ได้บันทึกตำแหน่ง!",
            Time = 3
        })
    end
end

-- Auto Shake
local function StartAutoShake()
    if autoshake_running then return end
    autoshake_running = true
    task.spawn(function()
        while AS do
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
            task.wait(SI)
        end
        autoshake_running = false
    end)
end

local castConn
local function SAC()
    if castConn then castConn:Disconnect() end
    
    castConn = RunService.Heartbeat:Connect(function()
        if not AC then return end
        
        local currentTime = tick()
        
        if HR() and not HB() and not casting and (currentTime - LCT) >= CI then
            casting = true
            
            pcall(function()
                local currentRod = GR()
                if currentRod and currentRod:FindFirstChild("events") then
                    local castAsync = currentRod.events:FindFirstChild("castAsync")
                    if castAsync then
                        castAsync:InvokeServer(50, false)
                    end
                end
            end)
            
            LCT = currentTime
            
            task.delay(0.1, function()
                casting = false
            end)
        end
    end)
end

local teleportConn
local function SAT()
    if teleportConn then teleportConn:Disconnect() end
    
    teleportConn = RunService.Heartbeat:Connect(function()
        if not TP then return end
        if not savedCFrame or teleporting then return end
        
        teleporting = true
        
        pcall(function()
            TeleportToSavedPosition()
        end)
        
        task.delay(1, function()
            teleporting = false
        end)
    end)
end

local Tab = Window:Tab({Title = "Main", Icon = "star"})

Tab:Section({Title = "Fishing"})

Tab:Toggle({
    Title = "Auto Reel",
    Desc = "",
    Value = false,
    Callback = function(value)
        AR = value
        if value then
            StartAutoReel()
            Window:Notify({
                Title = "Auto Reel [80% LEGIT]",
                Desc = "Bypass Anti-Cheat",
                Time = 3
            })
        else
            autoreel_running = false
        end
    end
})

Tab:Toggle({
    Title = "Auto Cast",
    Desc = "",
    Value = false,
    Callback = function(value)
        AC = value
        if value then
            SAC()
            LCT = tick()
            Window:Notify({
                Title = "Auto Casted",
                Desc = "Bypass Anti-Cheat",
                Time = 3
            })
        else
            if castConn then
                castConn:Disconnect()
                castConn = nil
            end
            casting = false
        end
    end
})

Tab:Toggle({
    Title = "Auto Shake",
    Desc = "",
    Value = false,
    Callback = function(value)
        AS = value
        if value then
            StartAutoShake()
            Window:Notify({
                Title = "Auto Shaked",
                Desc = "",
                Time = 3
            })
        else
            autoshake_running = false
        end
    end
})

Tab:Toggle({
    Title = "Auto Equip Rod",
    Desc = "Automatically equip fishing rod",
    Value = false,
    Callback = function(state)
        autoEquipRodEnabled = state
        if state then
            StartAutoEquipRod()
            Window:Notify({
                Title = "Auto Equip Roded",
                Desc = "",
                Time = 3
            })
        else
            autoEquipRod_running = false
        end
    end
})

Tab:Toggle({
    Title = "Auto Sell All",
    Desc = "",
    Value = false,
    Callback = function(value)
        sellAllEnabled = value
        if value then
            StartAutoSellAll()
            Window:Notify({
                Title = "Auto Sell All",
                Desc = "เปิดใช้งานขายของอัตโนมัติทุก " .. sellInterval .. " วินาที",
                Time = 3
            })
        else
            sellAllRunning = false
        end
    end
})

Tab:Textbox({
    Title = "Sell Delay",
    Desc = "",
    Placeholder = "5",
    Value = "5",
    ClearTextOnFocus = false,
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            sellInterval = num
            Window:Notify({
                Title = "ตั้งค่าเวลาแล้ว",
                Desc = "จะขายของทุก " .. sellDelay .. " วินาที",
                Time = 3
            })
        else
            Window:Notify({
                Title = "Error",
                Desc = "กรุณากรอกตัวเลขที่ถูกต้อง",
                Time = 3
            })
        end
    end
})

Tab:Button({
    Title = "Sell All Now",
    Desc = "",
    Callback = function()
        SellAllItems()
    end
})

Tab:Section({Title = "Teleport"})

Tab:Button({
    Title = "Save Position",
    Desc = "",
    Callback = SavePosition
})

Tab:Toggle({
    Title = "Auto Teleport",
    Desc = "",
    Value = false,
    Callback = function(value)
        TP = value
        if value then
            if savedCFrame then
                SAT()
                Window:Notify({
                    Title = "Auto Teleported!",
                    Desc = "",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "",
                    Time = 3
                })
                TP = false
            end
        else
            if teleportConn then
                teleportConn:Disconnect()
                teleportConn = nil
            end
            teleporting = false
        end
    end
})

Tab:Section({Title = "Settings"})

Tab:Slider({
    Title = "Cast Delay",
    Desc = "",
    Value = 0.5,
    Min = 0.1,
    Max = 5,
    Callback = function(value)
        CI = value
    end
})

Tab:Slider({
    Title = "Shake Delay",
    Desc = "",
    Value = 0.1,
    Min = 0.1,
    Max = 1,
    Callback = function(value)
        SI = value
    end
})

local TPTab = Window:Tab({Title = "Teleport", Icon = "map-pin"})

TPTab:Section({Title = "Island Teleport"})

local islandList = LoadIslandList()
TPTab:Dropdown({
    Title = "Select Island",
    Desc = "เลือกเกาะที่ต้องการวาป",
    List = islandList,
    Value = islandList[1] or "",
    Callback = function(value)
        selectedIsland = value
    end
})

TPTab:Button({
    Title = "Teleport to Island",
    Desc = "วาปไปยังเกาะที่เลือก",
    Callback = function()
        TeleportToIsland()
    end
})

-- Cleanup function
local function cleanup()
    restoreHooks()
    
    if castConn then castConn:Disconnect() end
    if teleportConn then teleportConn:Disconnect() end
    autoshake_running = false
    autoEquipRod_running = false
    autoreel_running = false
    teleportingToIsland = false
    sellAllRunning = false
end

-- Auto cleanup when GUI is closed
Window:OnClose(cleanup)
