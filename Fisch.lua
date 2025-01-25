local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()

local win = DiscordLib:Window("Fisch-1.5.4")

local serv = win:Server("Main", "")

local tgls = serv:Channel("Auto")

local islandOptions = {}

for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
    if teleport_island:IsA("BasePart") then
        table.insert(islandOptions, teleport_island.Name)
    end
end

local Char = LocalPlayer.Character
local Humanoid = Char.Humanoid

local lp = game.Players.LocalPlayer
local re = game.ReplicatedStorage

getgenv().config = getgenv().config or {}
getgenv().config.auto_thorown_rod = false

tgls:Toggle(
    "Auto Cast", "Automatically throw the rod", function(state)
    if state then
        
        getgenv().config.auto_thorown_rod = true
        spawn(function()
            while getgenv().config.auto_thorown_rod do
                task.wait()

                
                local rod_name = re.playerstats[lp.Name].Stats.rod.Value
                local equipped_rod = lp.Character:FindFirstChild(rod_name)

                if equipped_rod and equipped_rod:FindFirstChild("events") and equipped_rod.events:FindFirstChild("cast") then
                    equipped_rod.events.cast:FireServer(100) 
                end
            end
        end)
    else
        
        getgenv().config.auto_thorown_rod = false
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
tgls:Toggle(
    "auto reel", "ToggleInfo", function(state)
    if state then
        getgenv().config.auto_reel = true

        spawn(function()
            while getgenv().config.auto_reel do
                task.wait(0)  

                
                local playerGui = lp:FindFirstChild("PlayerGui")
                if playerGui then
                    local reel = playerGui:FindFirstChild("reel")

                    if reel then
                        print("Reel found!")

                        
                        if re and re.events and re.events.reelfinished then
                            print("Attempting to fire reelfinished event")
                            local success, errorMsg = pcall(function()
                                re.events.reelfinished:FireServer(100, 1)
                            end)

                            if success then
                                print("Reel event fired successfully")
                            else
                                warn("Failed to fire reel event:", errorMsg)
                            end
                        else
                            warn("Event reelfinished not found")
                        end
                    else
                        warn("Reel GUI not found in PlayerGui")
                    end
                else
                    warn("PlayerGui not found")
                end
            end
        end)

    else
        getgenv().config.auto_reel = false
        print("Auto Reel has been disabled")
    end
end
)

tgls:Toggle(
    "Freeze Character", "", function(v)
    Char.HumanoidRootPart.Anchored = v
end
)

tgls:Button(
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
