repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 

-- Services & Player
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetReliable = ReplicatedStorage:WaitForChild("ByteNetReliable")
local CoreGui = game:GetService("CoreGui")
local zombiesFolder = workspace:WaitForChild("Entities"):WaitForChild("Zombie")

-- Character
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local noclipTouchedParts = {}
local offset = Vector3.new(0, 7.5, 0)

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    table.clear(noclipTouchedParts)
end)

-- Noclip Functions
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

-- Movement Function
function moveToTarget(targetPos)
    if not hrp or not targetPos then return end
    local speed = 100

    local bv = hrp:FindFirstChild("Lock")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "Lock"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = hrp
    end

    repeat
        local direction = targetPos - hrp.Position
        local distance = direction.Magnitude

        if distance > 0.5 then
            bv.Velocity = direction.Unit * speed
        else
            bv.Velocity = Vector3.new(0,0,0)
        end

        enableNoclip(char)
        RunService.Heartbeat:Wait()
    until (hrp.Position - targetPos).Magnitude < 1

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

                    local school = workspace:FindFirstChild("School")
                    if school and school:FindFirstChild("Rooms") then
                        local rooftop = school.Rooms:FindFirstChild("RooftopBoss")
                        if rooftop and rooftop:FindFirstChild("RadioObjective") then
                            local radioPrompt = rooftop.RadioObjective:FindFirstChildOfClass("ProximityPrompt")
                            if radioPrompt and radioPrompt.Enabled then
                                moveToTarget(rooftop.RadioObjective.Position + Vector3.new(0,6,0), speed)
                                task.wait(0.5)
                                fireproximityprompt(radioPrompt)
                                task.wait(5)
                                if guiLabel and guiLabel.ContentText == "0" then
                                    task.wait(5)
                                    local heliPrompt = rooftop:FindFirstChild("HeliObjective") 
                                                        and rooftop.HeliObjective:FindFirstChildOfClass("ProximityPrompt")
                                    if heliPrompt and heliPrompt.Enabled then
                                        moveToTarget(rooftop.HeliObjective.Position + Vector3.new(0,6,0), speed)
                                        task.wait(0.5)
                                        fireproximityprompt(heliPrompt)
                                    end
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

-- Auto Attack
local Toggle = Tabs.Main:AddToggle("MyToggle", { Title = "Auto Attack", Default = false })
Toggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            while Toggle.Value do
                local args = { buffer.fromstring("\b\004\000") }
                ByteNetReliable:FireServer(unpack(args))
                task.wait(0.1)
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

-- Bring Mobs
local BringMobsToggle = Tabs.Main:AddToggle("BringMobs", { Title = "Bring Mobs", Default = false })
BringMobsToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            while BringMobsToggle.Value do
                -- Sewers Doors
                local sewers = workspace:FindFirstChild("Sewers")
                if sewers and sewers:FindFirstChild("Doors") then
                    for _, door in ipairs(sewers.Doors:GetChildren()) do
                        local args = { buffer.fromstring("\a\001"), {door} }
                        ByteNetReliable:FireServer(unpack(args))
                        task.wait(0.1)
                    end
                end

                -- School Doors
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

Fluent:Notify({ Title = "Fluent", Content = "The script has been loaded.", Duration = 8 })
SaveManager:LoadAutoloadConfig()

-- Toggle UI Button
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
