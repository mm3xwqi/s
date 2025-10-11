-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

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

-- Saved Position (ใช้ CFrame)
local savedCFrame = nil

-- Services
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local Animations = game:GetService("ReplicatedStorage").resources.animations.fishing

-- Get all rod names
local rodNames = {}
local rodsFolder = game:GetService("ReplicatedStorage"):WaitForChild("resources"):WaitForChild("items"):WaitForChild("rods")
for _, rod in ipairs(rodsFolder:GetChildren()) do
    table.insert(rodNames, rod.Name)
end

-- Setup Anti-Cheat Bypass using getrawmetatable and hookfunction
local mt = getrawmetatable(game)
local originalNamecall
local hookedRemotes = {}

-- Hook __namecall method
if mt and not originalNamecall then
    local isReadOnly = isreadonly and isreadonly(mt) or false
    if isReadOnly then
        setreadonly(mt, false)
    end
    
    originalNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Auto Reel hook
        if AR and method == "FireServer" and self.Name == "reelfinished" then
            return originalNamecall(self, 100, true)
        end
        
        -- Auto Cast hook  
        if AC and method == "InvokeServer" and self.Name == "castAsync" then
            return originalNamecall(self, 100, true)
        end
        
        return originalNamecall(self, ...)
    end)
    
    if isReadOnly then
        setreadonly(mt, true)
    end
end

-- Additional hookfunction for extra protection
local originalFireServer
local originalInvokeServer

local function setupHookFunction()
    if not originalFireServer then
        originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
            local args = {...}
            
            if AR and self.Name == "reelfinished" then
                return originalFireServer(self, 100, true)
            end
            
            return originalFireServer(self, ...)
        end)
    end

    if not originalInvokeServer then
        originalInvokeServer = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(self, ...)
            local args = {...}
            
            if AC and self.Name == "castAsync" then
                return originalInvokeServer(self, 100, true)
            end
            
            return originalInvokeServer(self, ...)
        end)
    end
end

-- Setup both hooks
setupHookFunction()

-- Restore original functions
local function restoreHooks()
    
    if originalNamecall and mt then
        local isReadOnly = isreadonly and isreadonly(mt) or false
        if isReadOnly then
            setreadonly(mt, false)
        end
        
        mt.__namecall = originalNamecall
        
        if isReadOnly then
            setreadonly(mt, true)
        end
        originalNamecall = nil
    end

    if originalFireServer then
        hookfunction(Instance.new("RemoteEvent").FireServer, originalFireServer)
        originalFireServer = nil
    end
    
    if originalInvokeServer then
        hookfunction(Instance.new("RemoteFunction").InvokeServer, originalInvokeServer)
        originalInvokeServer = nil
    end
end

-- Check functions
local function IRV()
    local RG = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("reel")
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
    local C = game:GetService("Players").LocalPlayer.Character
    if not C then return false end
    
    for _, rodName in ipairs(rodNames) do
        if C:FindFirstChild(rodName) then
            return true
        end
    end
    return false
end

-- Get current equipped rod
local function GR()
    local C = game:GetService("Players").LocalPlayer.Character
    if not C then return nil end
    
    for _, rodName in ipairs(rodNames) do
        local rod = C:FindFirstChild(rodName)
        if rod then
            return rod
        end
    end
    return nil
end

-- Check if bobber exists
local function HB()
    local PN = game:GetService("Players").LocalPlayer.Name
    local RW = workspace:FindFirstChild(PN)
    if RW then
        for _, rodName in ipairs(rodNames) do
            local rod = RW:FindFirstChild(rodName)
            if rod and rod:FindFirstChild("bobber") then
                return true
            end
        end
    end
    return false
end

-- Play throw animation
local function PTA()
    local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and Animations:FindFirstChild("throw") then
        local throwAnimation = humanoid:LoadAnimation(Animations.throw)
        if throwAnimation then
            throwAnimation:Play()
        end
    end
end

-- Play waiting animation
local function PWA()
    local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and Animations:FindFirstChild("waiting") then
        local waitingAnimation = humanoid:LoadAnimation(Animations.waiting)
        if waitingAnimation then
            waitingAnimation:Play()
        end
    end
end

-- Save current position
local function SavePosition()
    local character = game:GetService("Players").LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        savedCFrame = character.HumanoidRootPart.CFrame
        Window:Notify({
            Title = "Position Saved",
            Desc = "ตำแหน่งถูกบันทึกแล้ว! (CFrame)",
            Time = 3
        })
        print("ตำแหน่งถูกบันทึก (CFrame): " .. tostring(savedCFrame))
    end
end

-- Teleport to saved position
local function TeleportToSavedPosition()
    if savedCFrame then
        local character = game:GetService("Players").LocalPlayer.Character
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
    
    reelConn = game:GetService("RunService").Heartbeat:Connect(function()
        local CT = tick()
        
        if AR and IRV() and not reeling and (CT - LRT) >= RI then
            reeling = true
            
            local RR = game:GetService("ReplicatedStorage").events.reelfinished
            RR:FireServer(100, true)
            
            LRT = CT
            
            task.delay(RI, function()
                reeling = false
            end)
        end
    end)
end

-- Auto Cast
local CAC
local function SAC()
    if CAC then return end
    
    CAC = game:GetService("RunService").Heartbeat:Connect(function()
        local CT = tick()
        
        if AC and HR() and not HB() and not casting and (CT - LCT) >= CI then
            casting = true
            
            local currentRod = GR()
            if currentRod and currentRod:FindFirstChild("events") then
                local CR = currentRod.events.castAsync
                CR:InvokeServer(100, true)

                task.wait()

                PTA()

                PWA()
                
                LCT = CT
                
                task.delay(CI, function()
                    casting = false
                end)
            end
        end
    end)
end

local shakeConn
local function SAS()
    if shakeConn then return end
    
    shakeConn = game:GetService("RunService").Heartbeat:Connect(function()
        local CT = tick()
        
        if AS and not shaking and (CT - LST) >= SI then
            shaking = true
            
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
            
            LST = CT
            
            task.delay(SI, function()
                shaking = false
            end)
        end
    end)
end

local teleportConn
local function SAT()
    if teleportConn then return end
    
    teleportConn = game:GetService("RunService").Heartbeat:Connect(function()
        if TP and savedCFrame and not teleporting then
            teleporting = true
            
            TeleportToSavedPosition()
            
            task.delay(1, function()
                teleporting = false
            end)
        end
    end)
end

-- Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"}) do
    Tab:Section({Title = "Fishing"})

    Tab:Toggle({
        Title = "Auto Reel",
        Desc = "",
        Value = false,
        Callback = function(v)
            AR = v
            if v then
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
        Desc = "",
        Value = false,
        Callback = function(v)
            AC = v
            if v then
                SAC()
                LCT = tick()
                Window:Notify({
                    Title = "Auto Cast",
                    Desc = "เปิดใช้งาน Auto Cast แล้ว!",
                    Time = 3
                })
            else
                if CAC then
                    CAC:Disconnect()
                    CAC = nil
                end
                casting = false
            end
        end
    })

    Tab:Toggle({
        Title = "Auto Shake",
        Desc = "",
        Value = false,
        Callback = function(v)
            AS = v
            if v then
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
        Desc = "",
        Callback = function()
            SavePosition()
        end
    })

    Tab:Toggle({
        Title = "Tp to saveposition",
        Desc = "",
        Value = false,
        Callback = function(v)
            TP = v
            if v then
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
end

local function cleanup()
    restoreHooks()
    
    if reelConn then
        reelConn:Disconnect()
    end
    if CAC then
        CAC:Disconnect()
    end
    if shakeConn then
        shakeConn:Disconnect()
    end
    if teleportConn then
        teleportConn:Disconnect()
    end
end

game:GetService("Players").LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "x2zu" then
        cleanup()
    end
end)

game:GetService("Players").LocalPlayer.PlayerGui.DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "x2zu" then
        cleanup()
    end
end)

Window:Notify({
    Title = "x2zu",
    Desc = "UI loaded with advanced hook protection!",
    Time = 3
})
