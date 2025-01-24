local LocalPlayer = game.Players.LocalPlayer
local re = game.ReplicatedStorage


local Player = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local islandOptions = {}

for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
    if teleport_island:IsA("BasePart") then
        table.insert(islandOptions, teleport_island.Name)
    end
end

equipitem = function(v)
    if LocalPlayer.Backpack:FindFirstChild(v) then
        local Eq = LocalPlayer.Backpack:FindFirstChild(v)
        LocalPlayer.Character.Humanoid:EquipTool(Eq)
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

local rod = LocalPlayer.Character:FindFirstChild("Tool")
if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
    rod.events.cast:FireServer(1, 1)
end

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("test5")

local serv = win:Server("Main", "")

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

getgenv().config = getgenv().config or {}
getgenv().config.auto_thorown_rod = false

tgls:Toggle(
    "Auto Cast",  function(state)
    if state then
			
	getgenv().config.auto_Cast = true
        spawn(function()
            while getgenv().config.auto_Cast do
                task.wait()
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local castEvent = tool:FindFirstChild("events") and tool.events:FindFirstChild("cast")
                if castEvent then
                    castEvent:FireServer(1)
                end
            end
        end
    end)
end
end
)


local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local GuiService = game:GetService("GuiService")

local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager") 

tgls:Toggle(
    "Auto Shake", "Navigate", function(state)
    if state then
        getgenv().config.auto_shake = true

        
        spawn(function()
            while getgenv().config.auto_shake do
                task.wait()

                
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
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
tgls:Toggle(
    "auto reel", "ToggleInfo", function(state)
    if state then
        getgenv().config.auto_reel = true

        spawn(function()
            while getgenv().config.auto_reel do
                task.wait(0)  

                
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local reel = playerGui:FindFirstChild("reel")
                        if ReplicatedStorage and ReplicatedStorage.events and ReplicatedStorage.events.reelfinished then
                            local success, errorMsg = pcall(function()
                                ReplicatedStorage.events.reelfinished:FireServer(100, 1)
                        end)
                end
            end
        end
        getgenv().config.auto_reel = false
    end)
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

tgls:Toggle(
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

local tgls = serv:Channel("Sell")

tgls:Toggle(
    "Sell-all", "ToggleInfo", function(state)
    if state then
        getgenv().config.auto_sell = true

        spawn(function()
            while getgenv().config.auto_sell do
                task.wait(0)  
			game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
            end
        getgenv().config.auto_sell = false
        end)
    end
end
)


local btns = serv:Channel("Misc")

btns:Button(
    "anti-afk",
    function()

local thisoneissocoldww = Instance.new("ScreenGui")
local madebybloodofbatus = Instance.new("Frame")
local UICornerw = Instance.new("UICorner")
local DestroyButton = Instance.new("TextButton")
local uselesslabelone = Instance.new("TextLabel")
local timerlabel = Instance.new("TextLabel")
local uselesslabeltwo = Instance.new("TextLabel")
local fpslabel = Instance.new("TextLabel")
local uselesslabelthree = Instance.new("TextLabel")
local pinglabel = Instance.new("TextLabel")
local uselessframeone = Instance.new("Frame")
local UICornerww = Instance.new("UICorner")
local uselesslabelfour = Instance.new("TextLabel")

--Properties:

thisoneissocoldww.Name = "thisoneissocoldww"
thisoneissocoldww.Parent = game.CoreGui
thisoneissocoldww.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

madebybloodofbatus.Name = "madebybloodofbatus"
madebybloodofbatus.Parent = thisoneissocoldww
madebybloodofbatus.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
madebybloodofbatus.Position = UDim2.new(0.0854133144, 0, 0.13128835, 0)
madebybloodofbatus.Size = UDim2.new(0, 225, 0, 96)

UICornerw.Name = "UICornerw"
UICornerw.Parent = madebybloodofbatus

DestroyButton.Name = "DestroyButton"
DestroyButton.Parent = madebybloodofbatus
DestroyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DestroyButton.BackgroundTransparency = 1.000
DestroyButton.Position = UDim2.new(0.871702373, 0, 0.0245379955, 0)
DestroyButton.Size = UDim2.new(0, 27, 0, 15)
DestroyButton.Font = Enum.Font.SourceSans
DestroyButton.Text = "X"
DestroyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyButton.TextSize = 14.000

DestroyButton.MouseButton1Click:connect(function()
	getgenv().AntiAfkExecuted = false
	
	wait(0.1)
	thisoneissocoldww:Destroy()
end)

uselesslabelone.Name = "uselesslabelone"
uselesslabelone.Parent = madebybloodofbatus
uselesslabelone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelone.BackgroundTransparency = 1.000
uselesslabelone.Position = UDim2.new(0.302473009, 0, 0, 0)
uselesslabelone.Size = UDim2.new(0, 95, 0, 24)
uselesslabelone.Font = Enum.Font.SourceSans
uselesslabelone.Text = "Anti Afk V1 By Evxn#6765"
uselesslabelone.TextColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelone.TextSize = 14.000

timerlabel.Name = "timerlabel"
timerlabel.Parent = madebybloodofbatus
timerlabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
timerlabel.BackgroundTransparency = 1.000
timerlabel.Position = UDim2.new(0.65344125, 0, 0.68194294, 0)
timerlabel.Size = UDim2.new(0, 60, 0, 24)
timerlabel.Font = Enum.Font.SourceSans
timerlabel.Text = "0:0:0"
timerlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerlabel.TextSize = 14.000

uselesslabeltwo.Name = "uselesslabeltwo"
uselesslabeltwo.Parent = madebybloodofbatus
uselesslabeltwo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselesslabeltwo.BackgroundTransparency = 1.000
uselesslabeltwo.Position = UDim2.new(0.038864471, 0, 0.373806685, 0)
uselesslabeltwo.Size = UDim2.new(0, 29, 0, 24)
uselesslabeltwo.Font = Enum.Font.SourceSans
uselesslabeltwo.Text = "Ping: "
uselesslabeltwo.TextColor3 = Color3.fromRGB(255, 255, 255)
uselesslabeltwo.TextSize = 14.000

fpslabel.Name = "fpslabel"
fpslabel.Parent = madebybloodofbatus
fpslabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fpslabel.BackgroundTransparency = 1.000
fpslabel.Position = UDim2.new(0.724226236, 0, 0.358796299, 0)
fpslabel.Size = UDim2.new(0, 55, 0, 24)
fpslabel.Font = Enum.Font.SourceSans
fpslabel.Text = "this contact dev"
fpslabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpslabel.TextSize = 14.000

uselesslabelthree.Name = "uselesslabelthree"
uselesslabelthree.Parent = madebybloodofbatus
uselesslabelthree.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelthree.BackgroundTransparency = 1.000
uselesslabelthree.Position = UDim2.new(0.506917477, 0, 0.352585167, 0)
uselesslabelthree.Size = UDim2.new(0, 26, 0, 24)
uselesslabelthree.Font = Enum.Font.SourceSans
uselesslabelthree.Text = "Fps: "
uselesslabelthree.TextColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelthree.TextSize = 14.000

pinglabel.Name = "pinglabel"
pinglabel.Parent = madebybloodofbatus
pinglabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
pinglabel.BackgroundTransparency = 1.000
pinglabel.Position = UDim2.new(0.20330891, 0, 0.371578127, 0)
pinglabel.Size = UDim2.new(0, 55, 0, 24)
pinglabel.Font = Enum.Font.SourceSans
pinglabel.Text = "if you see this"
pinglabel.TextColor3 = Color3.fromRGB(255, 255, 255)
pinglabel.TextSize = 14.000
pinglabel.TextWrapped = true

uselessframeone.Name = "uselessframeone"
uselessframeone.Parent = madebybloodofbatus
uselessframeone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselessframeone.BackgroundTransparency = 1.000
uselessframeone.Position = UDim2.new(0.444, 0, 0.252, 0)
uselessframeone.Size = UDim2.new(0, 16, 0, 17)

UICornerww.CornerRadius = UDim.new(0, 7)
UICornerww.Parent = uselessframeone

uselesslabelfour.Name = "uselesslabelfour"
uselesslabelfour.Parent = uselessframeone
uselesslabelfour.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelfour.BackgroundTransparency = 1.000
uselesslabelfour.Position = UDim2.new(0.597, 0, 0.736, 0)
uselesslabelfour.Size = UDim2.new(0, 47, 0, 16)
uselesslabelfour.Font = Enum.Font.SourceSans
uselesslabelfour.Text = "Made By: Exvn#6765"
uselesslabelfour.TextColor3 = Color3.fromRGB(255, 255, 255)
uselesslabelfour.TextSize = 14.000

local userService = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local stats = game:GetService("Stats")

getgenv().AntiAfkExecuted = false

rs.RenderStepped:Connect(function()
if not getgenv().AntiAfkExecuted then
		game:GetService("VirtualUser"):CaptureController()
		game:GetService("VirtualUser"):ClickButton1(Vector2.new())
end
end)

end)
