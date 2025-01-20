local Player = game:GetService("Players")
local LocalPlayer = Player.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Char = LocalPlayer.Character

equipitem = function(v)
    if LocalPlayer.Backpack:FindFirstChild(v) then
        local a = LocalPlayer.Backpack:FindFirstChild(v)
        Humanoid:EquipTool(a)
    end
end


local rod = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Tool")
if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
    rod.events.cast:FireServer(1, 1)
end



local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()

local win = DiscordLib:Window("Fisch-v0.01")

local serv = win:Server("Preview", "")

local btns = serv:Channel("Buttons")

btns:Button(
        "SellAll",
        function()
        while true do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
            wait(2)
        end
    end
)

btns:Button(
        "reel",
        function()
        while true do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100,1)
            wait(0)
        end
    end
)

local PlayerGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
btns:Button(
        "Shake",
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
            wait(0.001)
        end
    end
)

btns:Button(
    "Cast",
    function()
    while true do
        local R = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        R.events.cast:FireServer(1,1)
        wait(0.1)
    end
end
)


local tgls = serv:Channel("Toggles")

tgls:Toggle(
    "Auto Equip",
    false,
    function(v)
        if v then
            for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("rod") then
                    equipitem(v.Name)  
                    break 
                end
            end
        else
        end
    end
)


for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
    if v:IsA("Tool") and v.Name:lower():find("rod") then
        equipitem(v.Name)
        break  
    end
end
