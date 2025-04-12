-- โหลด DiscordLib UI
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

-- สร้างหน้าต่าง UI
local win = DiscordLib:Window("Tween v1.1")
local controls = win:Server("main", "ServerIcon")

-- ตัวแปร Tween และความเร็ว
local TweenService = game:GetService("TweenService")
local Speed = 350 -- ความเร็วในการ tween

-- รวบรวมรายชื่อผู้เล่น
local Plr = {}
for i, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v ~= game.Players.LocalPlayer then
        table.insert(Plr, v.Name)
    end
end

-- ช่องหลัก
local mainChannel = controls:Channel("Tween")

-- Dropdown เลือกผู้เล่นเป้าหมาย
local PlayerTP = nil
local drop = mainChannel:Dropdown(
    "Select Player!",
    Plr,
    function(t)
        PlayerTP = t
    end
)

-- ฟังก์ชัน Tween เคลื่อนที่ไปหาตำแหน่ง
local function SmoothMoveTo(targetPosition)
    local player = game.Players.LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if rootPart then
        local distance = (targetPosition - rootPart.Position).Magnitude
        local time = distance / Speed

        local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(rootPart, tweenInfo, {
            CFrame = CFrame.new(targetPosition)
        })
        tween:Play()
        return tween
    end
end

-- Toggle สำหรับ Auto Tween ติดตามผู้เล่น
mainChannel:Toggle(
    "Auto Tween To Player",
    false,
    function(t)
        _G.TweenToPlayer = t
        local currentTween = nil

        while _G.TweenToPlayer do
            local player = game.Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local targetPlayer = PlayerTP and game.Players:FindFirstChild(PlayerTP)

            if rootPart and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, 2) -- Offset ด้านหลังเป้าหมาย

                if currentTween then
                    currentTween:Cancel()
                end

                currentTween = SmoothMoveTo(targetPos)
            end

            task.wait(0.3) -- รอให้ Tween ไปก่อนจะอัปเดตตำแหน่งใหม่
        end

        -- ปิด Tween หาก toggle ถูกปิด
        if currentTween then
            currentTween:Cancel()
        end
    end
)
