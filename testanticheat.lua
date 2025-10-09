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
local CI = 1.5
local RI = 1.5
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

-- Setup Anti-Cheat Bypass
local mt = getrawmetatable(game)
local onc = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod()
    
    -- Hook for reel
    if AR and m == "FireServer" and self.Name == "reelfinished" then
        return onc(self, 100, true)
    end
    
    -- Hook for cast
    if AC and m == "InvokeServer" and self.Name == "castAsync" then
        return onc(self, 100, true)
    end
    
    return onc(self, ...)
end)
setreadonly(mt, true)

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

-- Save current position (ใช้ CFrame)
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

-- Teleport to saved position (ใช้ CFrame)
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

-- Auto Reel Loop
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

-- Auto Cast Loop
local CAC
local function SAC()
    if CAC then return end
    
    CAC = game:GetService("RunService").Heartbeat:Connect(function()
        local CT = tick()
        
        if AC and HR() and not HB() and not casting and (CT - LCT) >= CI then
            casting = true
            
            local currentRod = GR()
            if currentRod and currentRod:FindFirstChild("events") then
                -- โยนเบ็ดก่อน
                local CR = currentRod.events.castAsync
                CR:InvokeServer(100, true)
                
                -- รอ 1 วินาทีแล้วค่อยเล่น animation
                task.wait()
                
                -- เล่น throw animation
                PTA()
                
                -- เล่น waiting animation หลังจาก throw
                PWA()
                
                LCT = CT
                
                task.delay(CI, function()
                    casting = false
                end)
            end
        end
    end)
end

-- Auto Shake Loop
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

-- Auto Teleport Loop
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

Window:Notify({
    Title = "x2zu",
    Desc = "UI loaded!",
    Time = 3
})
