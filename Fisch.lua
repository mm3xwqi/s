local Player = game:GetService("Players")
local LocalPlayer = Player.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local islandOptions = {}

for _, teleport_island in pairs(Workspace.world.spawns.TpSpots:GetChildren()) do
    if teleport_island:IsA("BasePart") then
        table.insert(islandOptions, teleport_island.Name)
    end
end

local function equipItem(v)
    local tool = LocalPlayer.Backpack:FindFirstChild(v)
    if tool then
        LocalPlayer.Character.Humanoid:EquipTool(tool)
    end
end

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
                        equipItem(v.Name)
                        task.wait(2)
                        break
                    end
                end
            end
        end
        task.wait(1)
    end
end

local function stopAutoEquip()
    running = false
end

local rod = LocalPlayer.Character:FindFirstChild("Tool")
if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
    rod.events.cast:FireServer(1, 1)
end

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()
local win = DiscordLib:Window("Fisch 1.4.9")
local serv = win:Server("Main", "")

local lp = game.Players.LocalPlayer
local re = game.ReplicatedStorage

local tgls = serv:Channel("Auto")
tgls:Toggle(
    "Auto Equip",
    false,
    function(v)
        if v then
            startAutoEquip()  
        else
            stopAutoEquip() 
        end
    end
)

tgls:Button(
    "reel-Perfect",
    function()
            while true do
                game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, 1)
                wait(0.1)
            end
        end
)


tgls:Button(
    "Auto Cast",
    function()
        while true do
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local castEvent = tool:FindFirstChild("events") and tool.events:FindFirstChild("cast")
                if castEvent then
                    castEvent:FireServer(1)
                end
            end
            task.wait(0.1) 
        end
    end
)



local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local GuiService = game:GetService("GuiService")

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager") 

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
                    
                    shake_button.Selectable = true
                    GuiService.SelectedObject = shake_button 

                    
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil) -- กดปุ่ม Enter
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil) -- ปล่อยปุ่ม Enter
                end
            end
        end)
    else
        getgenv().config.auto_shake = false
    end
end
)
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
            for _, teleport_island in pairs(Workspace.world.spawns.TpSpots:GetChildren()) do
                if teleport_island.Name == currentOption and teleport_island:IsA("BasePart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = teleport_island.CFrame
                    return
                end
            end
        end
    end
)

local tgls = serv:Channel("Sell")
tgls:Toggle(
    "Sell-all", 
    false, 
    function(state)
        if state then
            getgenv().config.auto_sell = true
            spawn(function()
                while getgenv().config.auto_sell do
                    task.wait(5) 
                    local sellAllEvent = ReplicatedStorage:WaitForChild("events"):WaitForChild("SellAll")
                    if sellAllEvent then
                        sellAllEvent:InvokeServer()
                    end
                end
                getgenv().config.auto_sell = false
            end)
        else
            getgenv().config.auto_sell = false 
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

