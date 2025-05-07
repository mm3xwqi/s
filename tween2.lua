local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("tween v2")
local controls = win:Server("Controls", "ServerIcon")
local mainChannel = controls:Channel("Main Controls")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Speed = 300 
local PlayerTP = nil
local Players = game:GetService("Players")
local Plr = {}

for i, v in pairs(Players:GetChildren()) do
    table.insert(Plr, v.Name)
end

-- Noclip toggle state
_G.Noclip = false

-- Setup efficient noclip
local function setupNoclip()
    local conn
    conn = RunService.Stepped:Connect(function()
        if not _G.Noclip then
            if conn then conn:Disconnect() end
            return
        end
        local char = Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Dropdown เลือกผู้เล่น
mainChannel:Dropdown(
    "Select Player!",
    Plr,
    function(t)
        PlayerTP = t
    end
)

-- Toggle: Noclip
mainChannel:Toggle(
    "Noclip",
    false,
    function(t)
        _G.Noclip = t
        if t then
            setupNoclip()
        else
            -- คืนค่า CanCollide
            local char = Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
)

-- Toggle: Auto TP
mainChannel:Toggle(
    "Auto Tp",
    false,
    function(t)
        _G.TPPlayer = t
        local player = Players.LocalPlayer

        spawn(function()
            while _G.TPPlayer and task.wait() do
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        local humanoid = char:FindFirstChild("Humanoid")

                        -- ป้องกันติดเก้าอี้
                        if humanoid and humanoid.Sit then
                            humanoid.Sit = false
                        end
                    end
                end)
            end
        end)

        -- Tween TP
        spawn(function()
            while _G.TPPlayer and task.wait() do
                local targetPlayer = Players:FindFirstChild(PlayerTP)
                if player and player.Character and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                    local currentPosition = humanoidRootPart.Position

                    local distance = (targetPosition - currentPosition).Magnitude
                    local travelTime = distance / Speed
                    local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

                    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
                        CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    })
                    tween:Play()
                    tween.Completed:Wait()
                end
            end
        end)
    end
)
