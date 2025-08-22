-- Player / Services
local player = game.Players.LocalPlayer
local entitiesFolder = workspace:WaitForChild("Entities")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local remote = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")

-- Settings
local autoFollow = false
local autoUseSkills = false

-- Character refs
local character, hrp, bv
local originalCanCollide = {}

-- Skills
local Skills = {
    Z = function()
        local args = { buffer.fromstring("\a\003\001"), {1755858750.110956} }
        remote:FireServer(unpack(args))
    end,

    X = function()
        local args = { buffer.fromstring("\a\005\001"), {1755858758.302091} }
        remote:FireServer(unpack(args))
    end,

    C = function()
        local args = { buffer.fromstring("\a\006\001"), {1755858762.557009} }
        remote:FireServer(unpack(args))
    end,

    G = function()
        local args = { buffer.fromstring("\a\a\001"), {1755858775.553812} }
        remote:FireServer(unpack(args))
    end,
    E = function()
        local args = { buffer.fromstring("\v") }
        remote:FireServer(unpack(args))
    end,
}

-- Noclip
local function enableNoclip()
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCanCollide[part] = part.CanCollide
                part.CanCollide = false
            end
        end
    end
end

local function disableNoclip()
    for part, state in pairs(originalCanCollide) do
        if part and part.Parent then
            part.CanCollide = state
        end
    end
    originalCanCollide = {}
end

-- Velocity Lock
local function enableVelocity()
    if hrp then
        if not hrp:FindFirstChild("Lock") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "Lock"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
        end
    end
end

local function disableVelocity()
    if hrp then
        local bv = hrp:FindFirstChild("Lock")
        if bv then
            bv:Destroy()
        end
    end
end

-- Attack
local function attackMonster(mon)
    if mon and mon:FindFirstChild("HumanoidRootPart") then
        local args = { buffer.fromstring("\a\004\001"), {mon.HumanoidRootPart.Position.Magnitude} }
        remote:FireServer(unpack(args))
    end
end

-- Character setup
local function setupCharacter(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then
        warn("HumanoidRootPart ไม่พบ!")
        return
    end
    bv = hrp:FindFirstChild("Lock")
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
    setupCharacter(player.Character)
end

-- Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "TEST v1.3",
    SubTitle = "by MW",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
}

-- AutoFarm Toggle
local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "AutoFarm",
    Default = false,
    Callback = function(state)
        autoFollow = state
        if autoFollow then
            enableNoclip()
            enableVelocity()

            task.spawn(function()
                while autoFollow do
                    if not hrp then
                        task.wait(0.1)
                        continue
                    end

                    local targetEntity = nil
                    for _, e in ipairs(entitiesFolder:GetChildren()) do
                        if e:IsA("Model") and e:FindFirstChild("HumanoidRootPart") then
                            targetEntity = e
                            break
                        end
                    end

if targetEntity and targetEntity:FindFirstChild("HumanoidRootPart") then
    local hrpMon = targetEntity.HumanoidRootPart

    local backOffset = -hrpMon.CFrame.LookVector * 2
    local targetPos = hrpMon.Position + backOffset + Vector3.new(0, 4, 0)

    local step = 0.6
    hrp.CFrame = hrp.CFrame:lerp(
        CFrame.new(targetPos, hrpMon.Position), 
        step
    )

    local bv = hrp:FindFirstChild("Lock")
    if bv then
        bv.Velocity = Vector3.new(0, 0, 0)
    end

    attackMonster(targetEntity)
end

                    task.wait(0.03)
                end
            end)
        else
            disableNoclip()
            disableVelocity()
        end
    end
})

-- Skill Dropdown
local SkillMultiDropdown = Tabs.Main:AddDropdown("SkillMultiDropdown", {
    Title = "Select Skills",
    Description = "",
    Values = {"Z", "X", "C", "G", "E"},
    Multi = true,
    Default = {"Z", "C"},
})

local selectedSkills = { Z = true, X = false, C = true, G = false, E = false }
SkillMultiDropdown:SetValue(selectedSkills)

SkillMultiDropdown:OnChanged(function(Value)
    for k, v in pairs(selectedSkills) do
        selectedSkills[k] = false
    end

    for k, v in pairs(Value) do
        if Skills[k] then
            selectedSkills[k] = v
        end
    end

    local activeSkills = {}
    for k, v in pairs(selectedSkills) do
        if v then
            table.insert(activeSkills, k)
        end
    end

    print("Selected Skills:", table.concat(activeSkills, ", "))
end)

-- Auto Use Skill Toggle
local SkillToggle = Tabs.Main:AddToggle("SkillToggle", {
    Title = "Auto Use Skill",
    Default = false,
    Callback = function(state)
        autoUseSkills = state
        if state then
            task.spawn(function()
                while autoUseSkills do
                    for skill, active in pairs(selectedSkills) do
                        if active and Skills[skill] then
                            pcall(function()
                                Skills[skill]()
                            end)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

local screenGui = game:GetService("CoreGui"):WaitForChild("ScreenGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ToggleButtonGui"
gui.Parent = game:GetService("CoreGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 45)
button.Position = UDim2.new(1, -150, 1, -400)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Text = "Close ui"
button.Parent = toggleUI

button.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
    button.Text = screenGui.Enabled and "Enabled" or "Disabled"
end)
