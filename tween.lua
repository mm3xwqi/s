local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("tween bodylock v1.2")
local controls = win:Server("Controls", "ServerIcon")

local TweenService = game:GetService("TweenService")
local Speed = 300  -- Set Speed to 300

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
        local currentTween = nil -- ใช้เก็บ Tween ที่กำลังทำงาน

        -- ฟังก์ชันล็อกการเคลื่อนไหว
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

        task.spawn(function()
            while _G.TPPlayer do
                local targetPlayer = game.Players:FindFirstChild(PlayerTP)
                if humanoidRootPart and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = targetPlayer.Character.HumanoidRootPart
                    local targetPosition = targetHRP.Position
                    local currentPosition = humanoidRootPart.Position

                    local distance = (targetPosition - currentPosition).Magnitude
                    local travelTime = distance / Speed  -- Use fixed Speed of 300

                    -- ยกเลิก Tween เดิมถ้ามี
                    if currentTween then
                        currentTween:Cancel()
                    end

                    local tweenInfo = TweenInfo.new(
                        travelTime,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    )

                    applyBodyVelocity(humanoidRootPart)

                    currentTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetHRP.CFrame})
                    currentTween:Play()

                    task.wait(travelTime)

                    removeBodyVelocity(humanoidRootPart)
                else
                    break
                end
                task.wait(0.05)
            end
        end)
    end
)

-- 🛡️ ระบบ Noclip Toggle
local noclipEnabled = false

mainChannel:Toggle(
    "Noclip",
    false,
    function(state)
        noclipEnabled = state

        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()

        task.spawn(function()
            while noclipEnabled do
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
                task.wait(0.1)
            end

            -- ถ้าปิด noclip ให้เปิด collide กลับ (ถ้าต้องการ)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
    end
)
