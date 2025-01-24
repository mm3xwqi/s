local Player = game:GetService("Players")
local LocalPlayer = Player.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Char = LocalPlayer.Character

-- Assuming 'serv' was meant to be ReplicatedStorage, change it
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Assuming getgenv().config.auto_shake is set somewhere else, or set it here.
getgenv().config = getgenv().config or {}
getgenv().config.auto_shake = getgenv().config.auto_shake or false

-- Assuming 'tgls' is a reference to something controlling toggle state
-- Update this to a valid method if necessary
local tgls = ReplicatedStorage:WaitForChild("Auto") -- Adjust to the actual service you need

tgls:Toggle(
    "auto_shake",
    false,
    spawn(function()
        while getgenv().config.auto_shake do
            task.wait()

            -- Fixing the issue of using 'lp', use 'LocalPlayer' instead
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            local shake_button = playerGui:FindFirstChild("shakeui") 
            and playerGui.shakeui:FindFirstChild("safezone") 
            and playerGui.shakeui.safezone:FindFirstChild("button")

            -- You can trigger the shake action here, if button is found
            if shake_button then
                -- Perform the shake action, e.g. click the button or simulate input
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            end
        end
    end)
)
