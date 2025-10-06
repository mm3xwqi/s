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

-- Sidebar Vertical Separator
local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui")

-- Auto Fishing Variables
local player = game:GetService("Players").LocalPlayer
local isAutoCast = false
local isAutoShake = false
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

-- Save Position Variables
local savedPosition = nil
local savedLookVector = nil

-- Fishing Rod Management
local currentRod = nil
local castCooldown = 2
local castThread = nil

-- Reel Remote Storage
local reelRemote = nil
local originalNamecall
local isAutoReelEnabled = true

-- Function to find and store reel remote
local function findReelRemote()
    local eventsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("events")
    if eventsFolder then
        reelRemote = eventsFolder:FindFirstChild("reelfinished")
    end
    return reelRemote
end

-- Hookmetamethod สำหรับดึงปลาทันที
local function enableInstantReelHook()
    if originalNamecall then return end
    
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if not checkcaller() then
            local method = getnamecallmethod()
            local args = {...}

            if method == "FireServer" and self == reelRemote and isAutoReelEnabled then
                return originalNamecall(self, 100, true)
            end
        end
        return originalNamecall(self, ...)
    end)
end

local function disableInstantReelHook()
    if originalNamecall then
        unhookmetamethod(game, "__namecall", originalNamecall)
        originalNamecall = nil
    end
end

-- Function to manually trigger reel (เรียกใช้ตรงๆ)
local function triggerInstantReel()
    if reelRemote and isAutoReelEnabled then
        reelRemote:FireServer(100, true)
    end
end

-- Function to find fishing rod
local function findFishingRod()
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") then
            local castEvent = tool.events:FindFirstChild("castAsync")
            if castEvent then
                return {tool = tool, castEvent = castEvent}
            end
        end
    end

    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") then
            local castEvent = tool.events:FindFirstChild("castAsync")
            if castEvent then
                return {tool = tool, castEvent = castEvent}
            end
        end
    end
    return nil
end

-- Function to equip fishing rod
local function equipFishingRod(rodData)
    if rodData and not player.Character:FindFirstChild(rodData.tool.Name) then
        player.Character.Humanoid:EquipTool(rodData.tool)
        task.wait(0.5)
    end
    return rodData
end

-- Function to cast fishing rod continuously
local function continuousCast()
    while isAutoCast do
        local currentCooldown = castCooldown
        
        if not currentRod then
            currentRod = findFishingRod()
            if currentRod then
                currentRod = equipFishingRod(currentRod)
            else
                task.wait(3)
                continue
            end
        end

        if savedPosition then
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.CFrame = CFrame.new(savedPosition, savedPosition + savedLookVector)
                end
            end
        end

        local success, result = pcall(function()
            return currentRod.castEvent:InvokeServer(100, 1)
        end)

        if not success then
            currentRod = nil
            task.wait(1)
            continue
        end

        task.spawn(function()
            local startTime = tick()
            while tick() - startTime < 10 and isAutoCast do
                local reelGui = player.PlayerGui:FindFirstChild("reel")
                if reelGui and reelGui.Enabled then
                    triggerInstantReel()
                    break
                end
                task.wait(0.1)
            end
        end)

        if isAutoCast then
            local waitStart = tick()
            while (tick() - waitStart) < currentCooldown and isAutoCast do
                task.wait(0.1)
            end
        end
    end
end

-- Save Position Function
local function savePosition()
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            savedPosition = nil
            savedLookVector = nil
            
            savedPosition = humanoidRootPart.Position
            savedLookVector = humanoidRootPart.CFrame.LookVector
            
            Window:Notify({
                Title = "Position Saved",
                Desc = "ตำแหน่งปัจจุบันถูกบันทึกแล้ว!",
                Time = 3
            })
        end
    end
end

-- Auto Shake Function
local function startAutoShake()
    if isAutoShake then return end
    isAutoShake = true
    
    task.spawn(function()
        while isAutoShake do
            task.wait(0.01)
            
            local PlayerGUI = player:WaitForChild("PlayerGui")
            local shakeUI = PlayerGUI:FindFirstChild("shakeui")
            
            if shakeUI and shakeUI.Enabled then
                local safezone = shakeUI:FindFirstChild("safezone")
                if safezone then
                    local button = safezone:FindFirstChild("button")
                    if button and button:IsA("ImageButton") and button.Visible then
                        GuiService.SelectedObject = button
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                end
            end
        end
    end)
    
    Window:Notify({
        Title = "Auto Shake",
        Desc = "Auto shake started successfully!",
        Time = 3
    })
end

local function stopAutoShake()
    isAutoShake = false
    Window:Notify({
        Title = "Auto Shake",
        Desc = "Auto shake stopped!",
        Time = 3
    })
end

-- Auto Cast Function
local function startAutoCast()
    if isAutoCast then return end
    isAutoCast = true
    
    castThread = task.spawn(function()
        continuousCast()
    end)
    
    Window:Notify({
        Title = "Auto Cast",
        Desc = "Auto cast started successfully!",
        Time = 3
    })
end

local function stopAutoCast()
    isAutoCast = false
    currentRod = nil
    
    if castThread then
        task.cancel(castThread)
        castThread = nil
    end
    Window:Notify({
        Title = "Auto Cast",
        Desc = "Auto cast stopped!",
        Time = 3
    })
end

-- Function to restart cast with new cooldown
local function restartCastWithNewCooldown()
    if isAutoCast then
        stopAutoCast()
        task.wait(0.5)
        startAutoCast()
    end
end

-- ค้นหาและเก็บ reel remote ทันทีเมื่อโหลดสคริปต์
findReelRemote()
enableInstantReelHook()

-- Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"}) 
    Tab:Section({Title = "Fishing Features"})

    Tab:Toggle({
        Title = "Auto Cast",
        Desc = "Cast เบ็ดอัตโนมัติเรื่อยๆ",
        Value = false,
        Callback = function(v)
            if v then
                startAutoCast()
            else
                stopAutoCast()
            end
        end
    })

    Tab:Toggle({
        Title = "Auto Shake",
        Desc = "Auto shake เมื่อมีปลากินเบ็ด",
        Value = false,
        Callback = function(v)
            if v then
                startAutoShake()
            else
                stopAutoShake()
            end
        end
    })

    Tab:Toggle({
        Title = "Instant Auto Reel",
        Desc = "",
        Value = true,
        Callback = function(v)
            isAutoReelEnabled = v
            if v then
                enableInstantReelHook()
                Window:Notify({
                    Title = "Instant Auto Reel",
                    Desc = "",
                    Time = 3
                })
            else
                disableInstantReelHook()
                Window:Notify({
                    Title = "Instant Auto Reel", 
                    Desc = "",
                    Time = 3
                })
            end
        end
    })

    Tab:Button({
        Title = "Save Position",
        Desc = "",
        Callback = savePosition
    })

    Tab:Slider({
        Title = "Cast Cooldown",
        Desc = "",
        Value = 2,
        Min = 0,
        Max = 10,
        Callback = function(v)
            castCooldown = v
            restartCastWithNewCooldown()
        end
    })

Window:Notify({
    Title = "x2zu Fishing",
    Desc = "Instant Auto Reel with direct remote call activated!",
    Time = 4
})
