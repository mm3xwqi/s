-- Load UI Library แบบปลอดภัย
local Library
local success, errorMsg = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
end)

if not success or not Library then
    -- ถ้าโหลดไม่สำเร็จ ให้ใช้ UI อื่นแทน
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
end

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "x2zu on top",
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
local AR = false
local AC = false
local AS = false
local TP = false
local LCT = 0
local LRT = 0
local LST = 0
local CI = 0.5
local RI = 2
local SI = 0.1
local casting = false
local reeling = false
local shaking = false
local teleporting = false

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

-- Check functions
local function IRV()
    local RG = PlayerGUI:FindFirstChild("reel")
    return RG and RG.Enabled
end

-- Check if shake UI exists
local function ISV()
    local shakeUI = PlayerGUI:FindFirstChild("shakeui")
    if shakeUI and shakeUI.Enabled then
        local safezone = shakeUI:FindFirstChild("safezone")
        if safezone then
            local button = safezone:FindFirstChild("button")
            return button and button:IsA("ImageButton") and button.Visible
        end
    end
    return false
end

-- Check if player has any fishing rod
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

-- Get current equipped rod
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

-- Check if bobber exists
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

-- Auto Reel
local reelConn
local function SAR()
    if reelConn then return end
    
    reelConn = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        if AR and IRV() and not reeling and (currentTime - LRT) >= RI then
            reeling = true
            
            -- ใช้ pcall เพื่อป้องกัน error
            pcall(function()
                local reelEvent = ReplicatedStorage:FindFirstChild("events")
                if reelEvent then
                    local reelfinished = reelEvent:FindFirstChild("reelfinished")
                    if reelfinished then
                        reelfinished:FireServer(100, true)
                    end
                end
            end)
            
            LRT = currentTime
            
            task.delay(RI, function()
                reeling = false
            end)
        end
    end)
end

-- Auto Cast
local castConn
local function SAC()
    if castConn then return end
    
    castConn = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        if AC and HR() and not HB() and not casting and (currentTime - LCT) >= CI then
            casting = true
            
            pcall(function()
                local currentRod = GR()
                if currentRod and currentRod:FindFirstChild("events") then
                    local castAsync = currentRod.events:FindFirstChild("castAsync")
                    if castAsync then
                        castAsync:InvokeServer(100, true)
                    end
                end
            end)
            
            LCT = currentTime
            
            task.delay(CI, function()
                casting = false
            end)
        end
    end)
end

-- Auto Shake
local shakeConn
local function SAS()
    if shakeConn then return end
    
    shakeConn = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        if AS and not shaking and (currentTime - LST) >= SI then
            shaking = true
            
            pcall(function()
                if ISV() then
                    GuiService.SelectedObject = nil
                    task.wait()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    task.wait()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
            end)
            
            LST = currentTime
            
            task.delay(SI, function()
                shaking = false
            end)
        end
    end)
end

-- Auto Teleport
local teleportConn
local function SAT()
    if teleportConn then return end
    
    teleportConn = RunService.Heartbeat:Connect(function()
        if TP and savedCFrame and not teleporting then
            teleporting = true
            
            pcall(function()
                TeleportToSavedPosition()
            end)
            
            task.delay(1, function()
                teleporting = false
            end)
        end
    end)
end

-- Create UI
local Tab = Window:Tab({Title = "Main", Icon = "star"})

Tab:Section({Title = "Fishing"})

Tab:Toggle({
    Title = "Auto Reel",
    Desc = "รีดอัตโนมัติเมื่อมีปลาติดเบ็ด",
    Value = false,
    Callback = function(value)
        AR = value
        if value then
            SAR()
            LRT = tick()
            Window:Notify({
                Title = "Auto Reel",
                Desc = "เปิดใช้งาน Auto Reel แล้ว!",
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
    Desc = "เหวี่ยงเบ็ดอัตโนมัติ",
    Value = false,
    Callback = function(value)
        AC = value
        if value then
            SAC()
            LCT = tick()
            Window:Notify({
                Title = "Auto Cast",
                Desc = "เปิดใช้งาน Auto Cast แล้ว!",
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
    Desc = "สะบัดเบ็ดอัตโนมัติ",
    Value = false,
    Callback = function(value)
        AS = value
        if value then
            SAS()
            LST = tick()
            Window:Notify({
                Title = "Auto Shake",
                Desc = "เปิดใช้งาน Auto Shake แล้ว!",
                Time = 3
            })
        else
            if shakeConn then
                shakeConn:Disconnect()
                shakeConn = nil
            end
            shaking = false
        end
    end
})

Tab:Section({Title = "Teleport"})

Tab:Button({
    Title = "Save Position",
    Desc = "บันทึกตำแหน่งปัจจุบัน",
    Callback = SavePosition
})

Tab:Toggle({
    Title = "Auto Teleport",
    Desc = "วาปไปยังตำแหน่งที่บันทึกอัตโนมัติ",
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
    Title = "Cast Interval",
    Desc = "ความเร็วในการเหวี่ยงเบ็ด",
    Value = 0.5,
    Min = 0.1,
    Max = 5,
    Callback = function(value)
        CI = value
    end
})

Tab:Slider({
    Title = "Reel Interval",
    Desc = "ความเร็วในการรีดเบ็ด",
    Value = 2,
    Min = 0.1,
    Max = 5,
    Callback = function(value)
        RI = value
    end
})

Tab:Slider({
    Title = "Shake Interval",
    Desc = "ความเร็วในการสะบัดเบ็ด",
    Value = 0.1,
    Min = 0.1,
    Max = 1,
    Callback = function(value)
        SI = value
    end
})

-- Cleanup function
local function cleanup()
    if reelConn then reelConn:Disconnect() end
    if castConn then castConn:Disconnect() end
    if shakeConn then shakeConn:Disconnect() end
    if teleportConn then teleportConn:Disconnect() end
end

-- Auto cleanup when GUI is closed
Window:OnClose(cleanup)

-- Notify when loaded
Window:Notify({
    Title = "x2zu Stellar Loaded",
    Desc = "Fishing script loaded successfully!",
    Time = 5
})

print("x2zu Stellar Script Loaded Successfully!")
