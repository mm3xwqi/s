-- Load UI Library แบบปลอดภัย
local Library
local success, errorMsg = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
end)

if not success or not Library then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
end

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "x2zu on top - Anti-Cheat Bypass",
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

-- Simple Anti-Cheat Bypass (แบบเบาๆ ไม่ทำให้ค้าง)
local hookEnabled = true

-- ใช้เฉพาะ hookfunction เฉพาะที่จำเป็น
local originalFireServer
local originalInvokeServer

local function setupHooks()
    if not hookEnabled then return end
    
    -- Hook FireServer สำหรับ Auto Reel
    if not originalFireServer then
        originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
            local args = {...}
            
            -- Auto Reel hook
            if AR and self.Name == "reelfinished" then
                if #args >= 2 then
                    return originalFireServer(self, 100, true)
                end
            end
            
            return originalFireServer(self, ...)
        end)
    end
    
    -- Hook InvokeServer สำหรับ Auto Cast
    if not originalInvokeServer then
        originalInvokeServer = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(self, ...)
            local args = {...}
            
            -- Auto Cast hook
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

-- Initialize hooks
setupHooks()

-- Check functions
local function IRV()
    local RG = PlayerGUI:FindFirstChild("reel")
    return RG and RG.Enabled
end

-- Check if shake UI exists (แบบใหม่)
local function ISV()
    local shakeUI = PlayerGUI:FindFirstChild("shakeui")
    if shakeUI and shakeUI.Enabled then
        local safezone = shakeUI:FindFirstChild("safezone")
        if safezone then
            local button = safezone:FindFirstChild("button")
            if button and button:IsA("ImageButton") then
                return button.Visible
            end
        end
    end
    return false
end

-- Get shake button position (สำหรับ debug)
local function GetShakeButton()
    local shakeUI = PlayerGUI:FindFirstChild("shakeui")
    if shakeUI and shakeUI.Enabled then
        local safezone = shakeUI:FindFirstChild("safezone")
        if safezone then
            return safezone:FindFirstChild("button")
        end
    end
    return nil
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
        print("Saved position:", savedCFrame)
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
                        reelfinished:FireServer(100, true)
                        print("Auto Reel: Fired")
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
                        print("Auto Cast: Invoked")
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

-- Auto Shake (ใช้ Return แทน Space)
local shakeConn
local function SAS()
    if shakeConn then shakeConn:Disconnect() end
    
    shakeConn = RunService.Heartbeat:Connect(function()
        if not AS then return end
        
        local currentTime = tick()
        
        if not shaking and (currentTime - LST) >= SI then
            shaking = true
            
            pcall(function()
                local button = GetShakeButton()
                if button and button.Visible then
                    -- กดปุ่ม Return แทน Space
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    print("Auto Shake: Pressed Return")
                end
            end)
            
            LST = currentTime
            
            task.delay(0.1, function()
                shaking = false
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
    Title = "Auto Reel [HOOKED]",
    Desc = "รีดอัตโนมัติ + Anti-Cheat Bypass",
    Value = false,
    Callback = function(value)
        AR = value
        if value then
            SAR()
            LRT = tick()
            Window:Notify({
                Title = "Auto Reel [HOOKED]",
                Desc = "เปิดใช้งาน Auto Reel ด้วย Hook Protection!",
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
    Title = "Auto Cast [HOOKED]",
    Desc = "เหวี่ยงเบ็ดอัตโนมัติ + Anti-Cheat Bypass",
    Value = false,
    Callback = function(value)
        AC = value
        if value then
            SAC()
            LCT = tick()
            Window:Notify({
                Title = "Auto Cast [HOOKED]",
                Desc = "เปิดใช้งาน Auto Cast ด้วย Hook Protection!",
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
    Title = "Auto Shake [RETURN]",
    Desc = "สะบัดเบ็ดอัตโนมัติ (กดปุ่ม Return)",
    Value = false,
    Callback = function(value)
        AS = value
        if value then
            SAS()
            LST = tick()
            Window:Notify({
                Title = "Auto Shake [RETURN]",
                Desc = "เปิดใช้งาน Auto Shake (กด Return)!",
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

Tab:Section({Title = "Anti-Cheat System"})

Tab:Toggle({
    Title = "Hook Protection",
    Desc = "เปิด/ปิดระบบป้องกัน Anti-Cheat",
    Value = true,
    Callback = function(value)
        hookEnabled = value
        if value then
            setupHooks()
            Window:Notify({
                Title = "Hook Protection",
                Desc = "เปิดใช้งานระบบป้องกัน Anti-Cheat แล้ว!",
                Time = 3
            })
        else
            restoreHooks()
            Window:Notify({
                Title = "Hook Protection",
                Desc = "ปิดใช้งานระบบป้องกัน Anti-Cheat แล้ว!",
                Time = 3
            })
        end
    end
})

Tab:Button({
    Title = "Debug Shake UI",
    Desc = "ตรวจสอบ Shake UI",
    Callback = function()
        local button = GetShakeButton()
        if button then
            Window:Notify({
                Title = "Debug Shake UI",
                Desc = "พบปุ่ม Shake: " .. tostring(button.Visible),
                Time = 5
            })
            print("Shake button found:", button, "Visible:", button.Visible)
        else
            Window:Notify({
                Title = "Debug Shake UI",
                Desc = "ไม่พบปุ่ม Shake!",
                Time = 5
            })
            print("Shake button not found")
        end
    end
})

-- Cleanup function
local function cleanup()
    restoreHooks()
    
    if reelConn then reelConn:Disconnect() end
    if castConn then castConn:Disconnect() end
    if shakeConn then shakeConn:Disconnect() end
    if teleportConn then teleportConn:Disconnect() end
end

-- Auto cleanup when GUI is closed
Window:OnClose(cleanup)

-- Player leaving cleanup
game:GetService("UserInputService").WindowFocused:Connect(function()
    -- รีเฟรช connections เมื่อกลับมาเล่น
    if AR and not reelConn then SAR() end
    if AC and not castConn then SAC() end
    if AS and not shakeConn then SAS() end
    if TP and not teleportConn then SAT() end
end)

-- Notify when loaded
Window:Notify({
    Title = "x2zu Stellar Loaded",
    Desc = "Fixed Version - No Lag!",
    Time = 5
})

print("x2zu Stellar Script Fixed Version Loaded Successfully!")
