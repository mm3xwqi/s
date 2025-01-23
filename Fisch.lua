local Player = game:GetService("Players")
local LocalPlayer = Player.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Char = LocalPlayer.Character

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

local win = DiscordLib:Window("Fisch-v0.13.1")

local serv = win:Server("Main", "")

local btns = serv:Channel("Fising")

btns:Button(
    "SellAll 1Time",
    function ()
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
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

local sellE = false
local run = false

tgls:Toggle(
    "SellAll",
    function()
        sellE = not sellE
        if sellE then
            run = true
            while sellAll and run do
                game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
                wait(2)
            end
        else
            run = false
        end
    end
)

local castE = false 

local castE = false  
local running = false  

tgls:Toggle(
    "Cast",
    function()
        castE = not castE  
        if castE then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                running = true
                while castE and running do  
                    tool.events.cast:FireServer(1,1)
                    wait(0.1)
                end
            end
        else
            running = false 
        end
    end
)

local reelE = false
local run = false  

tgls:Toggle(
    "reel",
    function()
        reelE = not reelE  
        if reelE then
            run = true
            while reelE and run do  
                game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100,1)
                wait(0)
            end
        else
            run = false  
        end
    end
)

local reelP = false
local run = false 

tgls:Toggle(
        "reel(No-Perfect)",
        function()
        reelP = not reelP
        if reelP then
            run = true
        while reelP and run do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
            wait(0)
        end
        else
            run = false
    end
end
)

local shakeE = false
local run = false 

local PlayerGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
tgls:Toggle(
        "Shake",
        function()
            shakeE = not shakeE
            if shakeE then
                run = true
            while shakeE and run do
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
            wait(0.1)
        end
     else
        run = false
    end
end
)


local AutoChestActive = false

tgls:Toggle(
    "Auto-Chest",
    false,
    function ()
        if not AutoChestActive then
            AutoChestActive = true
            local originalPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            local chest = workspace.ActiveChestsFolder.Pad.Chests:GetChildren()
            if chest and chest:FindFirstChild("Position") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = chest.Position
                wait(2)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                wait(0)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
            end
            AutoChestActive = false
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



