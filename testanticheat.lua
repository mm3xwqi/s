local Library
local success, errorMsg = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
end)

if not success or not Library then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
end

-- Create Main Window
local Window = Library:Window({
    Title = "_mm3",
    Desc = "",
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
local LCT = 0
local LRT = 0
local CI = 0.5
local RI = 2
local SI = 0.1
local casting = false
local reeling = false
local teleporting = false
local autoshake_running = false
local autoEquipRodEnabled = false
local autoEquipRod_running = false
local player = game.Players.LocalPlayer

-- Saved Position
local savedCFrame = nil

-- Services
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGUI = LocalPlayer:WaitForChild("PlayerGui")

-- Get all rod names
local rodNames = {}
local rodsFolder = ReplicatedStorage:WaitForChild("resources"):WaitForChild("items"):WaitForChild("rods")
for _, rod in ipairs(rodsFolder:GetChildren()) do
    table.insert(rodNames, rod.Name)
end

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

-- Simple Anti-Cheat Bypass
local hookEnabled = true
local originalFireServer
local originalInvokeServer

local function setupHooks()
    if not hookEnabled then return end
    
    if not originalFireServer then
        originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
            local args = {...}
            
            if AR and self.Name == "reelfinished" then
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
            
            if AC and self.Name == "castAsync" then
                if #args >= 2 then
                    return originalInvokeServer(self, 100, true)
                end
            end
            
            return originalInvokeServer(self, ...)
        end)
    end
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

-- Check functions
local function IRV()
    local RG = PlayerGUI:FindFirstChild("reel")
    return RG and RG.Enabled
end

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

-- Auto Shake แบบใหม่
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

-- Auto Reel
local reelConn
local function SAR()
    if reelConn then reelConn:Disconnect() end
    
    reelConn = RunService.Heartbeat:Connect(function()
        if not AR then return end
        
        local currentTime = tick()
        
        if IRV() and not reeling and (currentTime - LRT) >= RI then
            reeling = true
            
            pcall(function()
                local events = ReplicatedStorage:FindFirstChild("events")
                if events then
                    local reelfinished = events:FindFirstChild("reelfinished")
                    if reelfinished then
                        reelfinished:FireServer(100, false)
                    end
                end
            end)
            
            LRT = currentTime
            
            task.delay(0.1, function()
                reeling = false
            end)
        end
    end)
end

-- Auto Cast
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

-- Auto Teleport
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

-- Create UI
local Tab = Window:Tab({Title = "Main", Icon = "star"})

Tab:Section({Title = "Fishing - Anti-Cheat Bypass"})

Tab:Toggle({
    Title = "Auto Reel",
    Desc = "",
    Value = false,
    Callback = function(value)
        AR = value
        if value then
            SAR()
            LRT = tick()
            Window:Notify({
                Title = "Auto Reeled",
                Desc = "",
                Time = 3
            })
        else
            if reelConn then
                reelConn:Disconnect()
                reelConn = nil
            end
            reeling = false
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
                Desc = "",
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
    Desc = "",
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
                    Title = "Auto Teleport",
                    Desc = "เปิดใช้งานการวาปอัตโนมัติ!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "กรุณาบันทึกตำแหน่งก่อน!",
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
    Title = "Reel Delay",
    Desc = "",
    Value = 1,
    Min = 0.1,
    Max = 5,
    Callback = function(value)
        RI = value
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

Tab:Section({Title = "Anti-Cheat System"})

Tab:Toggle({
    Title = "Bypass anti-Cheat (DONT CLOSE)",
    Desc = "",
    Value = true,
    Callback = function(value)
        hookEnabled = value
        if value then
            setupHooks()
            Window:Notify({
                Title = "Bypass anti-Cheat",
                Desc = "",
                Time = 3
            })
        else
            restoreHooks()
            Window:Notify({
                Title = "Bypass anti-Cheat (CLOSE RISK BAN)",
                Desc = "",
                Time = 3
            })
        end
    end
})

-- Cleanup function
local function cleanup()
    restoreHooks()
    
    if reelConn then reelConn:Disconnect() end
    if castConn then castConn:Disconnect() end
    if teleportConn then teleportConn:Disconnect() end
    autoshake_running = false
    autoEquipRod_running = false
end

-- Auto cleanup when GUI is closed
Window:OnClose(cleanup)

-- Notify when loaded
Window:Notify({
    Title = "Script Loaded",
    Desc = "Bypass anti-Cheat!",
    Time = 5
})

