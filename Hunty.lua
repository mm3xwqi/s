repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local zombiesFolder = workspace:WaitForChild("Entities"):WaitForChild("Zombie")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetReliable = ReplicatedStorage:WaitForChild("ByteNetReliable")
local Doors = workspace:WaitForChild("Sewers"):WaitForChild("Doors")

local offset = Vector3.new(1, -8, -1)

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    enableNoclip(char)
end)

local function enableNoclip(character)
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end


function moveToTarget(targetPos, speed)
    if not hrp or not targetPos then return end

    local bv = hrp:FindFirstChild("Lock")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "Lock"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = hrp
    end

    repeat
        local direction = (targetPos - hrp.Position)
        local distance = direction.Magnitude

        if distance > 0.5 then
            bv.Velocity = bv.Velocity:Lerp(direction.Unit * speed, 0.15)
        else
            bv.Velocity = bv.Velocity:Lerp(Vector3.new(0,0,0), 0.2)
        end

        -- หันหน้าไปตามเป้าหมาย
        local lookPos = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        hrp.CFrame = CFrame.lookAt(hrp.Position, lookPos)

        enableNoclip(char)
        RunService.Heartbeat:Wait()
    until (hrp.Position - targetPos).Magnitude < 1

    bv.Velocity = Vector3.new(0,0,0)
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Hunty Zombies v1.0",
    SubTitle = "by MW",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local TeleportToggle = Tabs.Main:AddToggle("TpToZombie", { Title = "Auto Clear Wave W2", Default = false })

TeleportToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            enableNoclip(char)
            local speed = 200

            while TeleportToggle.Value do
                local targetZombie = nil
                for _, zombie in ipairs(zombiesFolder:GetChildren()) do
                    local hrpZ = zombie:FindFirstChild("HumanoidRootPart")
                    if hrpZ then
                        targetZombie = hrpZ
                        break
                    end
                end

                if targetZombie then
                    moveToTarget(targetZombie.Position + offset, speed)

                    repeat
                        if not targetZombie.Parent then break end
                        moveToTarget(targetZombie.Position + offset, speed)
                        RunService.Heartbeat:Wait()
                    until not targetZombie.Parent or not TeleportToggle.Value
                else
                    task.wait(0.1)
                end

                local bossRoom = workspace:FindFirstChild("Sewers")
                    and workspace.Sewers:FindFirstChild("Rooms")
                    and workspace.Sewers.Rooms:FindFirstChild("BossRoom")

                if bossRoom and bossRoom:FindFirstChild("generator") and bossRoom.generator:FindFirstChild("gen") then
                    local gen = bossRoom.generator.gen
                    local pom = gen:FindFirstChild("pom")
                    if pom and pom:IsA("ProximityPrompt") and pom.Enabled then
                        moveToTarget(gen.Position + Vector3.new(0,6,0), speed)
                        task.wait(0.5)
                        fireproximityprompt(pom)
                        task.wait(1)
                    end
                end

                task.wait(0.1)
            end
        end)
    end
end)

local Toggle = Tabs.Main:AddToggle("MyToggle", {
    Title = "Auto Attack",
    Default = false
})

Toggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            while Toggle.Value do
                local args = {
                    buffer.fromstring("\b\004\000")
                }
                game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
end)

local DropWarpToggle = Tabs.Main:AddToggle("DropWarpToggle", {
    Title = "Auto Warp DropItems",
    Default = false
})

DropWarpToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local hrp = player.Character and player.Character:WaitForChild("HumanoidRootPart")
            local RunService = game:GetService("RunService")
            local DropItemsFolder = workspace:WaitForChild("DropItems")

            while DropWarpToggle.Value do
                for _, item in ipairs(DropItemsFolder:GetChildren()) do
                    if item:IsA("BasePart") or item:IsA("Model") then
                        local targetPos
                        if item:IsA("Model") and item:FindFirstChild("PrimaryPart") then
                            targetPos = item.PrimaryPart.Position
                        elseif item:IsA("BasePart") then
                            targetPos = item.Position
                        end

                        if targetPos then
                            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0,3,0)) -- ลอยเล็กน้อยเหนือไอเท็ม
                        end
                    end
                    task.wait(0.05)
                end
                task.wait(0.2)
            end
        end)
    end
end)

local SkillToggle = Tabs.Main:AddToggle("AutoSkills", {
    Title = "Auto Skills",
    Default = false
})

SkillToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local ByteNetReliable = ReplicatedStorage:WaitForChild("ByteNetReliable")
            local skills = {
                buffer.fromstring("\b\003\000"),
                buffer.fromstring("\b\005\000"),
                buffer.fromstring("\b\006\000"),
	            buffer.fromstring("\f")
            }

            while SkillToggle.Value do
                for _, skill in ipairs(skills) do
                    if not SkillToggle.Value then break end
                    ByteNetReliable:FireServer(skill)
                    task.wait(0.1)
                end
                task.wait(0.2)
            end
        end)
    end
end)

local BringMobsToggle = Tabs.Main:AddToggle("BringMobs", { Title = "Bring Mobs", Default = false })

BringMobsToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local ByteNetReliable = ReplicatedStorage:WaitForChild("ByteNetReliable")
            local Doors = workspace:WaitForChild("Sewers"):WaitForChild("Doors")

            while BringMobsToggle.Value do
                for _, door in ipairs(Doors:GetChildren()) do
                    if door:IsA("Model") or door:IsA("Folder") or door:IsA("Part") then
                        local args = {
                            buffer.fromstring("\a\001"),
                            {door}
                        }
                        ByteNetReliable:FireServer(unpack(args))
                        task.wait(0.1)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

local ReplayToggle = Tabs.Main:AddToggle("ReplayToggle", {
    Title = "Auto Replay",
    Default = false
})

ReplayToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local voteReplay = game:GetService("ReplicatedStorage"):WaitForChild("external")
                                :WaitForChild("Packets"):WaitForChild("voteReplay")
            while ReplayToggle.Value do
                voteReplay:FireServer()
                task.wait(0.5)
            end
        end)
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})
SaveManager:LoadAutoloadConfig()

local CoreGui = game:GetService("CoreGui")
local screenGui = CoreGui:WaitForChild("ScreenGui")

local ui = CoreGui:WaitForChild("ScreenGui")
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleUI"
toggleGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 45)
button.Position = UDim2.new(1, -150, 1, -400)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = ui.Enabled and "UI: ON" or "UI: OFF"
button.Parent = toggleGui

button.MouseButton1Click:Connect(function()
    if ui then
        ui.Enabled = not ui.Enabled
        button.Text = ui.Enabled and "UI: ON" or "UI: OFF"
    end
end)
