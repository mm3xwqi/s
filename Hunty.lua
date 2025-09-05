
local Players = game:GetService("Players")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetReliable = ReplicatedStorage:WaitForChild("ByteNetReliable")
local CoreGui = game:GetService("CoreGui")
local zombiesFolder = workspace:WaitForChild("Entities"):WaitForChild("Zombie")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local noclipTouchedParts = {}
local offset = Vector3.new(1, 6, 0)

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    table.clear(noclipTouchedParts)
end)
local function enableNoclip(character)
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            noclipTouchedParts[part] = true
            part.CanCollide = false
        end
    end
end

local function disableNoclip(character)
    for part in pairs(noclipTouchedParts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    table.clear(noclipTouchedParts)

    if hrp then
        local bv = hrp:FindFirstChild("Lock")
        if bv then bv:Destroy() end
    end
end

function moveToTarget(targetHRP, offset)
    if not hrp or not targetHRP then return end
    local speed = 100
    offset = offset

    local bv = hrp:FindFirstChild("Lock")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "Lock"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = hrp
    end

    repeat
        local targetPos = targetHRP.Position + offset
        local direction = targetPos - hrp.Position
        local distance = direction.Magnitude

        if distance > 0.5 then
            bv.Velocity = direction.Unit * speed
        else
            bv.Velocity = Vector3.new(0,0,0)
        end

        enableNoclip(char)
        RunService.Heartbeat:Wait()
    until not targetHRP.Parent or (hrp.Position - targetHRP.Position - offset).Magnitude <= 0.5

    bv.Velocity = Vector3.new(0,0,0)
end

-- Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Hunty Zombies",
    SubTitle = "by MW",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Auto Clear Wave
local TeleportToggle = Tabs.Main:AddToggle("TpToZombie", {
    Title = "Auto Clear Wave",
    Default = false
})

TeleportToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            enableNoclip(char)
            local player = game:GetService("Players").LocalPlayer
            local guiLabel = player.PlayerGui.MainScreen.ObjectiveDisplay.ObjectiveElement.List.Value.Label

            while TeleportToggle.Value do
                local targetZombie = nil
                for _, zombie in ipairs(zombiesFolder:GetChildren()) do
                    local hrpZ = zombie:FindFirstChild("HumanoidRootPart")
                    if hrpZ and hrpZ.Position.Y > -20 then
                        targetZombie = hrpZ
                        break
                    end
                end

                if targetZombie then
                    moveToTarget(targetZombie, Vector3.new(0,5,0))
                    repeat
                        if not targetZombie.Parent or targetZombie.Position.Y < -20 or not TeleportToggle.Value then
                            break
                        end
                        moveToTarget(targetZombie, Vector3.new(0,5,0))
                        RunService.Heartbeat:Wait()
                    until not targetZombie.Parent or not TeleportToggle.Value

                else
                    local bossRoom = workspace:FindFirstChild("Sewers") 
                                     and workspace.Sewers:FindFirstChild("Rooms") 
                                     and workspace.Sewers.Rooms:FindFirstChild("BossRoom")
                    
                    if bossRoom and bossRoom:FindFirstChild("generator") and bossRoom.generator:FindFirstChild("gen") then
                        local gen = bossRoom.generator.gen
                        local pom = gen:FindFirstChild("pom")
                        if pom and pom:IsA("ProximityPrompt") and pom.Enabled then
                            moveToTarget(gen, Vector3.new(0,0,0))
                            task.wait(0.5)
                            fireproximityprompt(pom)
                            task.wait(1)
                        end
                    end
                    local school = workspace:FindFirstChild("School")
                    if school and school:FindFirstChild("Rooms") then
                        local rooftop = school.Rooms:FindFirstChild("RooftopBoss")
                        if rooftop and rooftop:FindFirstChild("RadioObjective") then
                            local radioPrompt = rooftop.RadioObjective:FindFirstChildOfClass("ProximityPrompt")
                            if radioPrompt and radioPrompt.Enabled then
                                moveToTarget(rooftop.RadioObjective, Vector3.new(0,0,0))
                                task.wait(0.5)
                                fireproximityprompt(radioPrompt)
                                task.wait(10)

                                repeat
                                    task.wait(1)
                                until guiLabel and guiLabel.ContentText == "0" or not TeleportToggle.Value

                                local heliPrompt = rooftop:FindFirstChild("HeliObjective") 
                                                    and rooftop.HeliObjective:FindFirstChildOfClass("ProximityPrompt")
                                if heliPrompt and heliPrompt.Enabled then
                                    moveToTarget(rooftop.HeliObjective, Vector3.new(0,0,0))
                                    task.wait(0.5)
                                    fireproximityprompt(heliPrompt)
                                end
                            end
                        end
                    end
                end

                task.wait(0.1)
            end

            disableNoclip(char)
        end)
    else
        disableNoclip(char)
    end
end)

local Toggle = Tabs.Main:AddToggle("MyToggle", { Title = "Auto Attack", Default = false })
Toggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            while Toggle.Value do
                VirtualUser:Button1Down(Vector2.new(958, 466))
                task.wait(1)
            end
        end)
    end
end)

local SwapToggle = Tabs.Main:AddToggle("AutoSwapWeapons", {
    Title = "Auto Swap Weapons",
    Default = false
})

SwapToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local keys = { Enum.KeyCode.One, Enum.KeyCode.Two }
            local current = 1

            while SwapToggle.Value do
                local key = keys[current]
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                VirtualInputManager:SendKeyEvent(false, key, false, game)

                current = current == 1 and 2 or 1

                task.wait(2)
            end
        end)
    end
end)

-- Auto Collect
local DropWarpToggle = Tabs.Main:AddToggle("DropWarpToggle", { Title = "Auto Collect", Default = false })
DropWarpToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local DropItemsFolder = workspace:WaitForChild("DropItems")
            while DropWarpToggle.Value do
                if hrp then
                    for _, item in ipairs(DropItemsFolder:GetChildren()) do
                        local targetPos
                        if item:IsA("Model") and item.PrimaryPart then
                            targetPos = item.PrimaryPart.Position
                        elseif item:IsA("BasePart") then
                            targetPos = item.Position
                        end
                        if targetPos then
                            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end
end)

-- Auto Skills
local SkillToggle = Tabs.Main:AddToggle("AutoSkills", { Title = "Auto Skills", Default = false })
SkillToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local keys = { Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.G }

            while SkillToggle.Value do
                for _, key in ipairs(keys) do
                    if not SkillToggle.Value then break end
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end
end)

local PerkToggle = Tabs.Main:AddToggle("UsePerk", {
    Title = "Use Perk",
    Default = false
})

PerkToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local args = { buffer.fromstring("\f") }

            while PerkToggle.Value do
                ByteNetReliable:FireServer(unpack(args))
                RunService.Heartbeat:Wait()
            end
        end)
    end
end)

-- Bring Mobs
local BringMobsToggle = Tabs.Main:AddToggle("BringMobs", { Title = "Bring Mobs", Default = false })
BringMobsToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            while BringMobsToggle.Value do
                local sewers = workspace:FindFirstChild("Sewers")
                if sewers and sewers:FindFirstChild("Doors") then
                    for _, door in ipairs(sewers.Doors:GetChildren()) do
                        local args = { buffer.fromstring("\a\001"), {door} }
                        ByteNetReliable:FireServer(unpack(args))
                        task.wait(0.1)
                    end
                end
                local school = workspace:FindFirstChild("School")
                if school and school:FindFirstChild("Doors") then
                    for _, door in ipairs(school.Doors:GetChildren()) do
                        local args = { buffer.fromstring("\a\001"), {door} }
                        ByteNetReliable:FireServer(unpack(args))
                        task.wait(0.1)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- Auto Replay
local ReplayToggle = Tabs.Main:AddToggle("ReplayToggle", { Title = "Auto Replay", Default = false })
ReplayToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            local voteReplay = ReplicatedStorage:WaitForChild("external"):WaitForChild("Packets"):WaitForChild("voteReplay")
            while ReplayToggle.Value do
                voteReplay:FireServer()
                task.wait(0.5)
            end
        end)
    end
end)

-- Save & Interface Manager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({ Title = "Fluent", Content = "ENJOY!", Duration = 10 })
SaveManager:LoadAutoloadConfig()

-- Toggle UI Button
local ui = CoreGui:WaitForChild("ScreenGui")
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleUI"
toggleGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 45)
button.Position = UDim2.new(1, -150, 1, -350)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = ui.Enabled and "MW" or "MW"
button.Parent = toggleGui

button.MouseButton1Click:Connect(function()
    if ui then
        ui.Enabled = not ui.Enabled
        button.Text = ui.Enabled and "MW" or "MW"
    end
end)

local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    button.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
