local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("Fisch-1.5.4f2")

local serv = win:Server("Main", "")

local tgls = serv:Channel("Auto")

local islandOptions = {}

-- Get all teleport islands in the game
for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
    if teleport_island:IsA("BasePart") then
        table.insert(islandOptions, teleport_island.Name)
    end
end

local player = game.Players.LocalPlayer
local character = player.Character
local humanoid = character and character:FindFirstChild("Humanoid")
local re = game.ReplicatedStorage

getgenv().config = getgenv().config or {}
getgenv().config.auto_throw_rod = false

-- Auto Cast Toggle
tgls:Toggle(
    "Auto Cast", "Automatically throw the rod", function(state)
    if state then
        getgenv().config.auto_throw_rod = true
        spawn(function()
            while getgenv().config.auto_throw_rod do
                task.wait()

                local rod_name = re.playerstats[player.Name].Stats.rod.Value
                local equipped_rod = player.Character:FindFirstChild(rod_name)

                if equipped_rod and equipped_rod:FindFirstChild("events") and equipped_rod.events:FindFirstChild("cast") then
                    equipped_rod.events.cast:FireServer(1)
                end
            end
        end)
    else
        getgenv().config.auto_throw_rod = false
    end
end)

local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Auto Shake Toggle
tgls:Toggle(
    "Auto Shake", "Navigate", function(state)
    if state then
        getgenv().config.auto_shake = true

        spawn(function()
            while getgenv().config.auto_shake do
                task.wait()

                local playerGui = player:WaitForChild("PlayerGui")
                local shake_button = playerGui:FindFirstChild("shakeui") 
                    and playerGui.shakeui:FindFirstChild("safezone") 
                    and playerGui.shakeui.safezone:FindFirstChild("button")

                if shake_button then
                    shake_button.Selectable = true
                    GuiService.SelectedObject = shake_button 

                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil) -- Press Enter
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil) -- Release Enter
                end
            end
        end)
    else
        getgenv().config.auto_shake = false
    end
end)

-- Auto Reel Toggle
tgls:Toggle(
    "Auto Reel", "ToggleInfo", function(state)
    if state then
        getgenv().config.auto_reel = true

        spawn(function()
            while getgenv().config.auto_reel do
                task.wait(0)  

                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local reel = playerGui:FindFirstChild("reel")

                    if reel then
                        if re and re.events and re.events.reelfinished then
                            local success, errorMsg = pcall(function()
                                re.events.reelfinished:FireServer(100, 1)
                            end)

                            if not success then
                                -- Handle failure to fire event if needed
                            end
                        end
                    end
                end
            end
        end)

    else
        getgenv().config.auto_reel = false
    end
end)

-- Freeze Character Toggle
tgls:Toggle(
    "Freeze Character", "Freeze your character in place", function(state)
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Anchored = state
        end
    end
end)

-- SellAll-Loop Button
tgls:Button(
    "SellAll-Loop 10 sec",
    function()
        while true do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
            wait(10)
        end
    end
)

tgls:Button(
    "SellAll-Loop 1min",
    function()
        while true do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
            wait(60)
        end
    end
)

-- Teleport Section
local serv2 = win:Server("Teleport", "")
local drops = serv2:Channel("tp-Islands")

local currentOption = nil

local drop = drops:Dropdown(
    "Island", islandOptions, function(option)
        currentOption = option
    end
)

drops:Button(
    "Teleport",
    function()
        if currentOption then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
                    if teleport_island.Name == currentOption and teleport_island:IsA("BasePart") then
                        player.Character.HumanoidRootPart.CFrame = teleport_island.CFrame
                        return
                    end
                end
            end
        end
    end
)

-- Anti-AFK Button
local btns = serv2:Channel("Misc")
btns:Button(
    "anti-afk",
    function()
        local antiAfkGui = Instance.new("ScreenGui")
        antiAfkGui.Parent = game.CoreGui
        game:GetService("RunService").RenderStepped:Connect(function()
            if not getgenv().AntiAfkExecuted then
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton1(Vector2.new())
            end
        end)
    end
)
