-- โหลด DiscordLib UI
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

-- สร้างหน้าต่าง UI
local win = DiscordLib:Window("discord library")
local controls = win:Server("main", "ServerIcon")

-- ตัวแปร Tween และความเร็ว
local TweenService = game:GetService("TweenService")
local Speed = 350 

-- รวบรวมรายชื่อผู้เล่น
Plr = {}
for i, v in pairs(game:GetService("Players"):GetChildren()) do
    table.insert(Plr, v.Name)
end

-- ช่องหลัก
local mainChannel = controls:Channel("Tween")

-- Dropdown เลือกผู้เล่นเป้าหมาย
local drop = mainChannel:Dropdown(
    "Select Player!",
    Plr,
    function(t)
        PlayerTP = t
    end
)

-- Toggle สำหรับ Body Lock Teleport
mainChannel:Toggle(
    "Auto Tp (Body Lock)",
    false,
    function(t)
        _G.TPPlayer = t
        local player = game.Players.LocalPlayer
        local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        -- ตรวจสอบ BodyVelocity เดิม
        if humanoidRootPart and humanoidRootPart:FindFirstChild("FollowVelocity") then
            humanoidRootPart:FindFirstChild("FollowVelocity"):Destroy()
        end

        -- สร้าง BodyVelocity ใหม่
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FollowVelocity"
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.P = 1250
        bodyVelocity.Parent = humanoidRootPart

        -- เริ่มการติดตาม
        while _G.TPPlayer do
            local targetPlayer = game.Players:FindFirstChild(PlayerTP)

            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = targetPlayer.Character.HumanoidRootPart.Position
                local currentPos = humanoidRootPart.Position
                local direction = (targetPos - currentPos).Unit
                local distance = (targetPos - currentPos).Magnitude

                -- เคลื่อนที่ไปยังเป้าหมาย
                bodyVelocity.Velocity = direction * Speed

                -- หยุดถ้าใกล้เกินไป
                if distance < 3 then
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end

            task.wait(0.1)
        end

        -- ปิด toggle จะลบ BodyVelocity ออก
        if humanoidRootPart and humanoidRootPart:FindFirstChild("FollowVelocity") then
            humanoidRootPart:FindFirstChild("FollowVelocity"):Destroy()
        end
    end
)
