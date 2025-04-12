local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("tween")
local controls = win:Server("Controls", "ServerIcon")

local TweenService = game:GetService("TweenService")
local Speed = 350 

Plr = {}
for i, v in pairs(game:GetService("Players"):GetChildren()) do
    table.insert(Plr, v.Name)
end

local mainChannel = controls:Channel("Main Controls")

local drop = mainChannel:Dropdown(
    "Select Player!",
    Plr,
    function(t)
        PlayerTP = t
    end
)

mainChannel:Toggle(
    "Auto Tp",
    false,
    function(t)
        _G.TPPlayer = t
        local player = game.Players.LocalPlayer
        local targetPlayer = game.Players:FindFirstChild(PlayerTP)

        while _G.TPPlayer do
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = player.Character.HumanoidRootPart
                local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                local currentPosition = humanoidRootPart.Position

                local distance = (targetPosition - currentPosition).Magnitude
                local travelTime = distance / Speed
                local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetPlayer.Character.HumanoidRootPart.CFrame})
                tween:Play()
                tween.Completed:Wait() -- Ensure the tween completes
            else
                break
            end
        end
    end
)
