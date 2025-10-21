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
    Desc = "x2zu on top - Advanced Anti-Cheat Bypass",
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

-- Advanced Anti-Cheat Bypass System
local hookEnabled = true
local originalFunctions = {}

-- Hook __namecall method
local function setupNamecallHook()
    if not hookEnabled then return end
    
    local mt = getrawmetatable(game)
    if mt then
        local isReadOnly = make_writeable(mt) or (isreadonly and setreadonly(mt, false))
        
        originalFunctions.namecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Auto Reel bypass
            if AR and method == "FireServer" and tostring(self) == "reelfinished" then
                return nil
            end
            
            -- Auto Cast bypass
            if AC and method == "InvokeServer" and tostring(self) == "castAsync" then
                return nil
            end
            
            -- Anti-detection: Block certain checks
            if method == "FindFirstChild" and args[1] and tostring(args[1]):lower():find("script") then
                return nil
            end
            
            return originalFunctions.namecall(self, ...)
        end)
        
        if isReadOnly then
            setreadonly(mt, true)
        end
    end
end

-- Hook FireServer
local function setupFireServerHook()
    if not hookEnabled then return end
    
    originalFunctions.fireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
        local args = {...}
        
        -- Auto Reel hook
        if AR and self.Name == "reelfinished" then
            if args[1] == 100 and args[2] == true then
                return originalFunctions.fireServer(self, ...)
            else
                return originalFunctions.fireServer(self, 100, true)
            end
        end
        
        -- Anti-cheat detection bypass
        if self.Name:lower():find("check") or self.Name:lower():find("detect") then
            return nil
        end
        
        return originalFunctions.fireServer(self, ...)
    end)
end

-- Hook InvokeServer
local function setupInvokeServerHook()
    if not hookEnabled then return end
    
    originalFunctions.invokeServer = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(self, ...)
        local args = {...}
        
        -- Auto Cast hook
        if AC and self.Name == "castAsync" then
            if args[1] == 100 and args[2] == true then
                return originalFunctions.invokeServer(self, ...)
            else
                return originalFunctions.invokeServer(self, 100, true)
            end
        end
        
        -- Anti-cheat detection bypass
        if self.Name:lower():find("check") or self.Name:lower():find("detect") then
            return nil
        end
        
        return originalFunctions.invokeServer(self, ...)
    end)
end

-- Hook Index for property protection
local function setupIndexHook()
    if not hookEnabled then return end
    
    local mt = getrawmetatable(game)
    if mt then
        local isReadOnly = make_writeable(mt) or (isreadonly and setreadonly(mt, false))
        
        originalFunctions.index = mt.__index
        mt.__index = newcclosure(function(self, key)
            -- Hide certain properties from anti-cheat
            if tostring(key):lower():find("script") or tostring(key):lower():find("hook") then
                return nil
            end
            
            return originalFunctions.index(self, key)
        end)
        
        if isReadOnly then
            setreadonly(mt, true)
        end
    end
end

-- Setup all hooks
local function setupHooks()
    pcall(setupNamecallHook)
    pcall(setupFireServerHook)
    pcall(setupInvokeServerHook)
    pcall(setupIndexHook)
end

-- Restore all hooks
local function restoreHooks()
    hookEnabled = false
    
    -- Restore namecall
    if originalFunctions.namecall then
        local mt = getrawmetatable(game)
        if mt then
            local isReadOnly = make_writeable(mt) or (isreadonly and setreadonly(mt, false))
            mt.__namecall = originalFunctions.namecall
            if isReadOnly then setreadonly(mt, true) end
        end
    end
    
    -- Restore FireServer
    if originalFunctions.fireServer then
        hookfunction(Instance.new("RemoteEvent").FireServer, originalFunctions.fireServer)
    end
    
    -- Restore InvokeServer
    if originalFunctions.invokeServer then
        hookfunction(Instance.new("RemoteFunction").InvokeServer, originalFunctions.invokeServer)
    end
    
    -- Restore Index
    if originalFunctions.index then
        local mt = getrawmetatable(game)
        if mt then
            local isReadOnly = make_writeable(mt) or (isreadonly and setreadonly(mt, false))
            mt.__index = originalFunctions.index
            if isReadOnly then setreadonly(mt, true) end
        end
    end
end

-- Initialize hooks
setupHooks()

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
            -- Use CFrame for smooth teleport
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

-- Auto Reel with hook protection
local reelConn
local function SAR()
    if reelConn then return end
    
    reelConn = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        if AR and IRV() and not reeling and (currentTime - LRT) >= RI then
            reeling = true
            
            -- ใช้ hook เพื่อส่งค่า 100, true อัตโนมัติ
            pcall(function()
                local reelEvent = ReplicatedStorage:FindFirstChild("events")
                if reelEvent then
                    local reelfinished = reelEvent:FindFirstChild("reelfinished")
                    if reelfinished then
                        -- ส่งค่าใดๆ ก็ได้ เพราะ hook จะจัดการให้เป็น 100, true
                        reelfinished:FireServer(50, false)
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

-- Auto Cast with hook protection
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
                        -- ส่งค่าใดๆ ก็ได้ เพราะ hook จะจัดการให้เป็น 100, true
                        castAsync:InvokeServer(50, false)
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
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
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
    Title = "Refresh Hooks",
    Desc = "รีเฟรชระบบ Hook ใหม่",
    Callback = function()
        restoreHooks()
        task.wait(0.5)
        setupHooks()
        Window:Notify({
            Title = "Hooks Refreshed",
            Desc = "รีเฟรชระบบ Hook เรียบร้อยแล้ว!",
            Time = 3
        })
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
LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "x2zu" then
        cleanup()
    end
end)

-- Notify when loaded
Window:Notify({
    Title = "x2zu Stellar Loaded",
    Desc = "Advanced Anti-Cheat Bypass Activated!",
    Time = 5
})

print("x2zu Stellar Script with Anti-Cheat Bypass Loaded Successfully!")
