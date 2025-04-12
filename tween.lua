local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("tween bodylock")
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
        local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        -- ฟังก์ชันสำหรับการล็อกการเคลื่อนไหว
        local function applyBodyVelocity(hrp)
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Name = "TweenLock"
            bv.Parent = hrp
        end

        local function removeBodyVelocity(hrp)
            local existing = hrp:FindFirstChild("TweenLock")
            if existing then
                existing:Destroy()
            end
        end

        while _G.TPPlayer do
            local targetPlayer = game.Players:FindFirstChild(PlayerTP)
            if humanoidRootPart and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = targetPlayer.Character.HumanoidRootPart
                local targetPosition = targetHRP.Position
                local currentPosition = humanoidRootPart.Position

                local distance = (targetPosition - currentPosition).Magnitude
                local travelTime = distance / Speed

                local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                -- ล็อกการเคลื่อนไหว
                applyBodyVelocity(humanoidRootPart)

                local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetHRP.CFrame})
                tween:Play()
                tween.Completed:Wait()

                -- ปลดล็อกหลัง Tween
                removeBodyVelocity(humanoidRootPart)
            else
                break
            end
            task.wait(0.1)
        end
    end
)
