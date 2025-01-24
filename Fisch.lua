local Player = game:GetService("Players")
local LocalPlayer = Player.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Char = LocalPlayer.Character

local lp = game.Players.LocalPlayer
local re = game.ReplicatedStorage

local islandOptions = {}

for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
    if teleport_island:IsA("BasePart") then
        table.insert(islandOptions, teleport_island.Name)
    end
end

equipitem = function (v)
    if LocalPlayer.Backpack:FindFirstChild(v) then
        local Eq = LocalPlayer.Backpack:FindFirstChild(v)
        LocalPlayer.Character.Humanoid:EquipTool(Eq)
    end
end


local rod = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Tool")
if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
    rod.events.cast:FireServer(1, 1)
end



local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()

local win = DiscordLib:Window("Fisch-1.5.2")

local serv = win:Server("Main", "")

local btns = serv:Channel("Main")

btns:Button(
    "reel-Perfect",
    function()
            while true do
                game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, 1)
                wait(0.1)
            end
        end
)

btns:Button(
    "Cast",
    function()
        while true do
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local castEvent = tool:FindFirstChild("events") and tool.events:FindFirstChild("cast")
                if castEvent then
                    castEvent:FireServer(1)
                end
            end
            wait(0.1) 
        end
    end
)


local isToggledOn = false
local originalSize = nil

local function setFixedSize()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerBar = player.PlayerGui:FindFirstChild("reel") and player.PlayerGui.reel:FindFirstChild("bar") and player.PlayerGui.reel.bar:FindFirstChild("playerbar")

    if playerBar then
        originalSize = playerBar.Size
        playerBar.Size = UDim2.new(1, 30, 0, 33)
    end
end

local function restoreOriginalSize()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerBar = player.PlayerGui:FindFirstChild("reel") and player.PlayerGui.reel:FindFirstChild("bar") and player.PlayerGui.reel.bar:FindFirstChild("playerbar")

    if playerBar and originalSize then
        playerBar.Size = originalSize
    end
end

btns:Toggle(
    "legit",
    false,
    function(state)
        isToggledOn = state

        if isToggledOn then
            spawn(function()
                while isToggledOn do
                    setFixedSize()
                    wait(0.1)
                end
            end)
        else
            restoreOriginalSize() 
        end
    end
)

local running = false  
local function startAutoEquip()
    running = true  
    while running do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local holdingRod = false
            for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                    holdingRod = true
                    break
                end
            end
            
            if not holdingRod then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v.Name:lower():find("rod") then
                        equipitem(v.Name)
                        wait(2) 
                        break
                    end
                end
            end
        end
        wait(1) 
    end
end

local function stopAutoEquip()
    running = false  
end

local tgls = serv:Channel("Auto")

tgls:Toggle(
    "Auto-Equip",
    false,
    function(v)
        if v then
            startAutoEquip()  
        else
            stopAutoEquip() 
        end
    end
)

tgls:Toggle(
    "Auto Shake", "Navigate", function(state)
        if state then
            getgenv().config.auto_shake = true

            spawn(function()
                while getgenv().config.auto_shake do
                    task.wait()

                    local playerGui = lp:WaitForChild("PlayerGui")
                    local shake_button = playerGui:FindFirstChild("shakeui") 
                        and playerGui.shakeui:FindFirstChild("safezone") 
                        and playerGui.shakeui.safezone:FindFirstChild("button")

                    if shake_button then

                        GuiService.SelectedObject = shake_button 

                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil) 
                        task.wait(0.05) 
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil) 
                    end
                end
            end)
        else
            getgenv().config.auto_shake = false
        end
    end
)

local btns = serv:Channel("Sell")

btns:Button(
    "SellAll-1Time",
    function ()
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
    end
)

btns:Button(
    "Sell-InHand",
    function ()
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("Sell"):InvokeServer()
    end
)

btns:Button(
    "SellAll-Loop",
    function ()
        while true do
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
        wait(10)
    end
end
)



local serv = win:Server("Teleport", "")

local drops = serv:Channel("tp-Islands")

local currentOption = nil

local drop = drops:Dropdown(
    "Island",
    islandOptions,
    function(option)
        currentOption = option
    end
)

drops:Button(
    "Teleport",
    function()
    if currentOption then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
                if teleport_island.Name == currentOption and teleport_island:IsA("BasePart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = teleport_island.CFrame
                    return
                end
            end
        end
    end
end
)

local btns = serv:Channel("Misc")
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
