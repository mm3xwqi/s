local TweenService = game:GetService("TweenService")
local Speed = 350

local Plr = {}
for i, v in pairs(game:GetService("Players"):GetChildren()) do
    table.insert(Plr, v.Name)
end

local win = DiscordLib:Window("tween bodylock v1.1")
local controls = win:Server("Controls", "ServerIcon")
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
        local currentTween = nil

        -- ฟังก์ชันล็อกการเคลื่อนไหว
        local function applyBodyVelocity(hrp)
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0) -- ไม่ให้มีความเร็วโดยตรง
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

        -- ฟังก์ชันล็อกการหมุนของตัวละคร
        local function applyBodyGyro(hrp)
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(400000, 400000, 400000)
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
        end

        -- ฟังก์ชันลบ BodyGyro
        local function removeBodyGyro(hrp)
            local existing = hrp:FindFirstChild("BodyGyro")
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
                    local travelTime = distance / Speed

                    -- ยกเลิก Tween เดิมถ้ามี
                    if currentTween then
                        currentTween:Cancel()
                    end

                    -- ใช้ EasingStyle ที่ลื่นไหล
                    local tweenInfo = TweenInfo.new(
                        travelTime,
                        Enum.EasingStyle.Linear,  -- Easing Style ที่เหมาะสมสำหรับการเคลื่อนไหวที่ลื่นไหล
                        Enum.EasingDirection.InOut
                    )

                    -- ใช้ BodyVelocity ในการล็อกการเคลื่อนไหว
                    applyBodyVelocity(humanoidRootPart)
                    applyBodyGyro(humanoidRootPart)

                    currentTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetHRP.CFrame})
                    currentTween:Play()

                    -- รอจนกว่าจะถึงปลายทางแล้วลบ BodyVelocity และ BodyGyro
                    task.wait(travelTime * 0.5) -- รอให้การเคลื่อนไหวครึ่งทางแล้วค่อยลบ BodyVelocity

                    removeBodyVelocity(humanoidRootPart)
                    removeBodyGyro(humanoidRootPart)
                else
                    break
                end
                task.wait(0.05)
            end
        end)
    end
)
