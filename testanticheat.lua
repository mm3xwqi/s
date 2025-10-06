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
local isAutoSell = false
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

-- Save Position Variables
local savedPosition = nil
local savedLookVector = nil

-- Fishing Rod Management
local currentRod = nil
local castCooldown = 2
local castThread = nil
local sellThread = nil

-- Reel Remote Storage
local reelRemote = nil
local sellRemote = nil
local originalNamecall
local isAutoReelEnabled = true

-- Function to find and store reel remote
local function findReelRemote()
    local eventsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("events")
    if eventsFolder then
        reelRemote = eventsFolder:FindFirstChild("reelfinished")
        sellRemote = eventsFolder:FindFirstChild("SellAll")
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

-- Function to sell all fish
local function sellAllFish()
    if sellRemote then
        sellRemote:InvokeServer()
    end
end

-- Auto Sell Function
local function startAutoSell()
    if isAutoSell then return end
    isAutoSell = true
    
    sellThread = task.spawn(function()
        while isAutoSell do
            sellAllFish()
            task.wait(1)
        end
    end)
    
    Window:Notify({
        Title = "Auto Sell",
        Desc = "Auto sell started successfully!",
        Time = 3
    })
end

local function stopAutoSell()
    isAutoSell = false
    if sellThread then
        task.cancel(sellThread)
        sellThread = nil
    end
    Window:Notify({
        Title = "Auto Sell",
        Desc = "Auto sell stopped!",
        Time = 3
    })
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

local function monitorReelGUI()
    while isAutoCast do
        task.wait(0.1)
        
        local reelGui = player.PlayerGui:FindFirstChild("reel")
        if reelGui and reelGui:IsA("ScreenGui") and reelGui.Enabled then
            task.wait(2)
            triggerInstantReel()

            while player.PlayerGui:FindFirstChild("reel") and isAutoCast do
                task.wait(0.1)
            end
        end
    end
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

local function startAutoCast()
    if isAutoCast then return end
    isAutoCast = true

    task.spawn(function()
        monitorReelGUI()
    end)
    
    castThread = task.spawn(function()
        continuousCast()
    end)
    
    Window:Notify({
        Title = "Auto Cast",
        Desc = "Auto cast started!",
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

local function restartCastWithNewCooldown()
    if isAutoCast then
        stopAutoCast()
        task.wait(0.5)
        startAutoCast()
    end
end

findReelRemote()
enableInstantReelHook()

-- Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"}) 
    Tab:Section({Title = "Fishing Features"})

    Tab:Toggle({
        Title = "Auto Cast",
        Desc = "",
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
        Desc = "",
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
        Desc = "Do not turn off the toggle if auto cast is enabled!",
        Value = true,
        Callback = function(v)
            isAutoReelEnabled = v
            end
    })

    Tab:Toggle({
        Title = "Auto Sell",
        Desc = "Sell all fish",
        Value = false,
        Callback = function(v)
            if v then
                startAutoSell()
            else
                stopAutoSell()
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
        Value = 1,
        Min = 0,
        Max = 10,
        Callback = function(v)
            castCooldown = v
            restartCastWithNewCooldown()
        end
    })

Window:Notify({
    Title = "x2zu Fishing",
    Desc = "Script loaded Successfully!",
    Time = 10
})
