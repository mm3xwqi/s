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

equipitem = function(v)
    if LocalPlayer.Backpack:FindFirstChild(v) then
        local Eq = LocalPlayer.Backpack:FindFirstChild(v)
        LocalPlayer.Character.Humanoid:EquipTool(Eq)
    end
end

local rod = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Tool")
if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
    rod.events.cast:FireServer(1, 1)
end

local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("test 4")
local serv = win:Server("Main", "")
local btns = serv:Channel("Fishing-PERMANENT")

btns:Button(
    "Sellall-1Time",
    function ()
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
    end
)

btns:Button(
    "SellAll-InHand",
    function ()
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("Sell"):InvokeServer()
    end
)

btns:Button(
    "SellAll-Loop",
    function()
        while true do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
            wait(2)
        end
    end
)


btns:Button(
    "Reel-Perfect",
    function()
        while true do
            rod.GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChildOfClass("Tool"):FireServer(100)
            wait(0)
        end
    end
)

btns:Button(
    "Reel-NoPerfect",
    function()
        while true do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
            wait(0)
        end
    end
)

local PlayerGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
tgls:Toggle(
        "Shake-Loop",
        function()
            while true do
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
    end
)



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






