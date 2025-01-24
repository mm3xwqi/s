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

local win = DiscordLib:Window("test1")

local serv = win:Server("Main", "")

local tgls = serv:Channel("Auto")
local lp = game.Players.LocalPlayer
local re = game.ReplicatedStorage



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

getgenv().config = getgenv().config or {}
getgenv().config.auto_thorown_rod = false

tgls:Toggle(
    "Auto Throw Rod", "Automatically throw the rod", function(state)
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
                        if re and re.events and re.events.reelfinished then
                            print("Attempting to fire reelfinished event")
                            local success, errorMsg = pcall(function()
                                re.events.reelfinished:FireServer(1, 1)
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


local isTeleporting = false  

tgls:Toggle(
    "Teleport to Saved Position (Loop)", "Continuously teleport character to saved position", function(state)
    if state then
        isTeleporting = true

        spawn(function()
            while isTeleporting do
                task.wait(0)  

                if getgenv().position and lp.Character and lp.Character.HumanoidRootPart then
                    lp.Character.HumanoidRootPart.CFrame = getgenv().position
                    break 
                end
            end
        end)
    else
        isTeleporting = false
    end
end
)


tgls:Button(
    "Save Position", "Save your character's position permanently", function()
    if lp.Character and lp.Character.HumanoidRootPart then
        getgenv().position = lp.Character.HumanoidRootPart.CFrame
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


