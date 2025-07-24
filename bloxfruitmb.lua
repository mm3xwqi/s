local args = {
    "SetTeam",
    "Marines"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

-- main local
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local enemiesFolder = workspace:WaitForChild("Enemies")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
if not humanoidRootPart then
    warn("HumanoidRootPart ไม่เจอในตัวละคร")
    return
end

local backpack = player:WaitForChild("Backpack")

local SPEED = 350
local running = false
local killBossEnabled = false
local offsetY = 50
local killAuraRange = 300
local bringRange = 100

-- table
local selectedBosses = {
    Boss1 = "",
    Boss2 = "",
    Boss3 = ""
}

local boss = {
    "The Gorilla King", "Chef", "The Saw", "Mob Leader", "Vice Admiral",
    "Yeti", "Saber Expert", "Warden", "Chief Warden", "Swan",
    "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God",
    "Cyborg", "Ice Admiral", "Greybeard"
}
local boss2 = {
    "Diamond", "Jeremy", "Orbitus", "Don Swan", "Smoke Admiral",
    "Awakened Ice Admiral", "Tide Keeper", "rip_indra", "Darkbeard",
    "Order", "Cursed Captain"
}
local boss3 = {
    "Stone", "Hydra Leader", "Kilo Admiral", "Captain Elephant",
    "Beautiful Pirate", "Longma", "Cursed Skeleton Boss", "Cake Queen",
    "Heaven's Guardian", "Hell's Messenger", "rip_indra True Form",
    "Soul Reaper", "Cake Prince", "Dough King", "Tyrant of the Skies"
}

local melee = {
    "Combat", "Black Leg", "Electric", "Water Kung Fu", "Dragon Breath",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

local sword = {
    "Cutlass", "Dual Katana", "Katana", "Iron Mace", "Shark Saw", "Triple Katana",
    "Twin Hooks", "Dragon Trident", "Dual-Headed Blade", "Flail", "Gravity Blade", "Longsword",
    "Pipe", "Soul Cane", "Trident", "Wardens Sword", "Bisento", "Buddy Sword",
    "Canvander", "Dark Dagger", "Dragonheart", "Fox Lamp", "Koko", "Midnight Blade",
    "Oroshi", "Pole (1st Form)", "Pole (2nd Form)", "Rengoku", "Saber", "Saishi",
    "Shark Anchor", "Shizu", "Spikey Trident", "Tushita", "Yama", "Cursed Dual Katana",
    "Dark Blade", "Hollow Scythe", "Triple Dark Blade", "True Triple Katana",
}

local gun = {
	"Slingshot", "Flintlock", "Musket", "Acidum Rifle", "Bizarre Revolver",
	"Cannon", "Dual Flintlock", "Magma Blaster", "Refined Slingshot",
	"Bazooka", "Kabucha", "Venom Bow", "Dragonstorm", "Skull Guitar"
}

local fruit = {
    "Rocket-Rocket", "Spin-Spin", "Blade-Blade", "Spring-Spring", "Bomb-Bomb",
    "Smoke-Smoke", "Flame-Flame", "Ice-Ice", "Sand-Sand", "Dark-Dark",
    "Eagle-Eagle", "Diamond-Diamond", "Light-Light", "Rubber-Rubber", "Ghost-Ghost",
    "Magmma-Magmma", "Quake-Quake", "Buddha-Buddha", "Love-Love", "Creation-Creation",
    "Spider-Spider", "Sound-Sound", "Phoenix-Phoenix", "Portal-Portal", "Rumble-Rumble",
    "Pain-Pain", "Blizzard-Blizzard", "Gravity-Gravity", "Mammoth-Mammoth", "T-Rex-T-Rex",
    "Dough-Dough", "Shadow-Shadow", "Venom-Venom", "Control-Control", "Gas-Gas",
    "Spirit-Spirit", "Leopard-Leopard", "Yeti-Yeti", "Kitsune-Kitsune",
    "Dragon-Dragon"
}

--  Noclip
local function enableNoclip()
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

local function disableNoclip()
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = true
        end
    end
end

-- weapon & Buso
local function equipWeapon()
    local tool = player.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        tool.Parent = character
    end
end

local function unequipWeapon()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        tool.Parent = player.Backpack
    end
end

local function activateBusoLoop()
    if character:FindFirstChild("HasBuso") then return end

    local args = {"Buso"}
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
end

-- Tween
local function tweenToPosition(part, targetPosition)
    local distance = (part.Position - targetPosition).Magnitude
    local duration = distance / SPEED

    spawn(function()
        while noclipActive do
            pcall(function()
                if not humanoidRootPart:FindFirstChild("Lock") then
                    if character:WaitForChild("Humanoid").Sit then
                        character.Humanoid.Sit = false
                    end
                    local Noclip = Instance.new("BodyVelocity")
                    Noclip.Name = "Lock"
                    Noclip.Parent = humanoidRootPart
                    Noclip.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    Noclip.Velocity = Vector3.new(0, 0, 0)
                end
            end)
            task.wait()
        end
    end)

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = { CFrame = CFrame.new(targetPosition) }
    TweenService:Create(part, tweenInfo, goal):Play()
    task.wait(duration)
end
--noclip mob
local function enableNoclipForEnemy(enemy)
    for _, part in ipairs(enemy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- bring mobs
local function bringEnemiesToTargetInstant(targetEnemy)
    local targetHRP = targetEnemy.HumanoidRootPart

    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if enemy ~= targetEnemy and enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            local dist = (enemy.HumanoidRootPart.Position - targetHRP.Position).Magnitude
            if dist <= bringRange and enemy.Humanoid.Health > 0 then
                enableNoclipForEnemy(enemy)
		enemy.HumanoidRootPart.CFrame = targetHRP.CFrame
            end
        end
    end
end

-- Kill Aura
local function attackAllEnemies()
    while running and not killBossEnabled do
        local targetEnemy = nil

        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                local humanoid = enemy.Humanoid
                local dist = (enemy.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                if humanoid.Health > 0 and dist <= killAuraRange then
                    targetEnemy = enemy
                    break
                end
            end
        end

        if targetEnemy then
            local targetHRP = targetEnemy.HumanoidRootPart
            local targetHumanoid = targetEnemy.Humanoid
            local targetPos = targetHRP.Position + Vector3.new(0, offsetY, 0)
            tweenToPosition(humanoidRootPart, targetPos)

            equipWeapon()
            activateBusoLoop()

            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                    local dist = (enemy.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    if dist <= bringRange then
                        bringEnemiesToTargetInstant(targetEnemy)
                    end
                end
            end

            pcall(function()
                ReplicatedStorage.Modules.Net.RE.RegisterAttack:FireServer(0.1)
                ReplicatedStorage.Modules.Net.RE.RegisterHit:FireServer(targetHRP, {})
            end)
        end
        task.wait(0.1)
    end
end

--Kill Boss 
local function attackBossesOnly()
    enableNoclip()
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if not running or not killBossEnabled then break end

        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            local name = enemy.Name
            local humanoid = enemy.Humanoid
            local hrp = enemy.HumanoidRootPart
            local isBoss = name == selectedBosses.Boss1 or name == selectedBosses.Boss2 or name == selectedBosses.Boss3

            if isBoss and humanoid.Health > 0 then
                equipWeapon()
                activateBusoLoop()

                while humanoid and humanoid.Health > 0 and running and killBossEnabled do
                    local targetPos = hrp.Position + Vector3.new(0, offsetY, 0)
                    tweenToPosition(humanoidRootPart, targetPos)

                    pcall(function()
                        ReplicatedStorage.Modules.Net.RE.RegisterAttack:FireServer(0.1)
                        ReplicatedStorage.Modules.Net.RE.RegisterHit:FireServer(hrp, {})
                    end)

                    task.wait(0.1)
                end
                break
            end
        end
    end
    disableNoclip()
end

-- startFarming
local function startFarming()
    running = true
    enableNoclip()
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.PlatformStand = true
    end
    task.spawn(attackAllEnemies)
end

-- startKillBoss
local function startKillBoss()
    running = true
    killBossEnabled = true
    task.spawn(function()
        while running and killBossEnabled do
            attackBossesOnly()
            task.wait(0.2)
        end
    end)
end

-- stopFarming
local function stopFarming()
    running = false
    disableNoclip()
    unequipWeapon()
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.PlatformStand = false
    end
end

--stopKillBoss
local function stopKillBoss()
    running = false
    killBossEnabled = false
    unequipWeapon()
end

-- UI 
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Beta v1.2.5",
    SubTitle = "made by mxw",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "sword" }),
}

Tabs.Main:AddToggle("MyToggle", {
    Title = "Kill aura",
    Default = false
}):OnChanged(function(value)
    if value then
        startFarming()
    else
        stopFarming()
        Fluent:Notify({
            Title = "Notification",
            Content = "Tyrant of the Skie is stopped",
            Duration = 3
        })
    end
end)

Tabs.Main:AddDropdown("Dropdown_Boss1", {
    Title = "Select Boss world 1",
    Values = boss,
    Multi = false
}):OnChanged(function(value)
    selectedBosses.Boss1 = value
    print("Selected Boss1:", value)
end)

Tabs.Main:AddDropdown("Dropdown_Boss2", {
    Title = "Select Boss world 2",
    Values = boss2,
    Multi = false
}):OnChanged(function(value)
    selectedBosses.Boss2 = value
    print("Selected Boss2:", value)
end)

Tabs.Main:AddDropdown("Dropdown_Boss3", {
    Title = "Select Boss world 3",
    Values = boss3,
    Multi = false
}):OnChanged(function(value)
    selectedBosses.Boss3 = value
    print("Selected Boss3:", value)
end)

Tabs.Main:AddToggle("Toggle_KillBoss", {
    Title = "Kill Boss",
    Default = false
}):OnChanged(function(state)
    print("Kill Boss Toggle:", state)
    if state then
        startKillBoss()
    else
        stopKillBoss()
        Fluent:Notify({
            Title = "Notification",
            Content = "Kill Boss stopped",
            Duration = 3
        })
    end
end)

Tabs.Main:AddSlider("AuraRangeSlider", {
    Title = "Kill Aura Range",
    Description = "Range to kill enemies",
    Default = killAuraRange,
    Min = 10,
    Max = 10000,
    Rounding = 0,
}):OnChanged(function(value)
    killAuraRange = value
    print("Kill aura range set to:", killAuraRange)
end)
Tabs.Main:AddSlider("PullRangeSlider", {
    Title = "BringRange",
    Default = bringRange,
    Min = 10,
    Max = 250,
    Rounding = 0,
}):OnChanged(function(value)
    pullRange = value
    print("Pull range set to:", pullRange)
end)

Tabs.Main:AddDropdown("Dropdown", {
    Title = "Select weapon",
    Values = {"melee", "sword", "gun", "fruit"},
    Multi = false,
    Default = 1,
}):OnChanged(function(value)
    selectedWeaponName = value
    print("Selected weapon:", value)
end)

local Tabs = Window:AddTab({ Title = "Player", Icon = "person-standing" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local toggles = {
    Melee = false,
    Defense = false,
    Sword = false,
    Gun = false,
    ["Demon Fruit"] = false
}

local function addStatPoint(statName)
    local args = {
        "AddPoint",
        statName,
        1
    }
    local success, err = pcall(function()
        CommF_:InvokeServer(unpack(args))
    end)
    if not success then
        warn("Failed to add point to", statName, ":", err)
    end
end

for statName, _ in pairs(toggles) do
    Tabs:AddToggle("Toggle_" .. statName, {
        Title = "Auto Add " .. statName,
        Default = false
    }):OnChanged(function(state)
        toggles[statName] = state

        if state then
            spawn(function()
                while toggles[statName] do
                    addStatPoint(statName)
                    task.wait(.1)
                end
            end)
        end
    end)
    end


Tabs:AddToggle("Toggle_V3", {
    Title = "Activate V3",
    Default = false,
}):OnChanged(function(value)
    useV3 = value
    if value then
        task.spawn(runV3Loop)
    end
end)

Tabs:AddToggle("Toggle_V4", {
    Title = "Activate V4",
    Default = false,
}):OnChanged(function(value)
    useV4 = value
    if value then
        task.spawn(runV4Loop)
    end
end)

local Tabq = Window:AddTab({ Title = "islands", Icon = "door-closed" })

local mapFolder = workspace:WaitForChild("Map")

local function getIslandPositions()
    local parts = {}
    local unwantedNames = {
        ["WaterBase-Plane"] = true,
        ["Fishmen"] = true,
        ["TempleHitboxes"] = true,
        ["MiniSky"] = true,
        ["MiniSky1"] = true,
        ["MiniSky2"] = true,
        ["MiniSky3"] = true,
    }

    for _, obj in ipairs(mapFolder:GetChildren()) do
        if unwantedNames[obj.Name] then
            continue
        end

        if obj:IsA("BasePart") then
            table.insert(parts, obj.Name)
        elseif obj:IsA("Model") then
            if obj.PrimaryPart then
                table.insert(parts, obj.Name)
            else
                local part = obj:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    table.insert(parts, obj.Name)
                end
            end
        end
    end

    return parts
end

local locationNames = getIslandPositions()

Tabq:AddDropdown("IslandDropdown", {
    Title = "Teleport to Island",
    Values = locationNames,
    Multi = false,
}):OnChanged(function(value)
    local targetPos = nil

    local success, result = pcall(function()
        local obj = mapFolder:FindFirstChild(value)
        if obj then
            if obj:IsA("BasePart") then
                return obj.Position
            elseif obj:IsA("Model") then
                if obj.PrimaryPart then
                    return obj.PrimaryPart.Position
                else
                    local part = obj:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        return part.Position
                    end
                end
            end
        end
        return nil
    end)

    targetPos = success and result or nil

    if targetPos and humanoidRootPart then
        tweenToPosition(humanoidRootPart, targetPos + Vector3.new(0, 50, 0))
        Fluent:Notify({
            Title = "Teleporting",
            Content = "Going to: " .. value,
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Error",
            Content = "Destination not found or invalid.",
            Duration = 3
        })
    end
end)

local Taba = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" })

Taba:AddButton({
    Title = "Black leg",
    Description = "Buy the Black Leg",
    Callback = function()
        local args = {
            "BuyBlackLeg"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})

Taba:AddButton({
    Title = "Electro",
    Description = "Buy the Electro",
    Callback = function()
        local args = {
            "BuyElectro"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})

Taba:AddButton({
    Title = "FishmanKarate",
    Description = "Buy the FishmanKarate",
    Callback = function()
        local args = {
            "BuyFishmanKarate"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})

Taba:AddButton({
    Title = "DragonClaw",
    Description = "Buy the DragonClaw",
    Callback = function()
        local args = {
            "BlackbeardReward",
            "DragonClaw",
            "2"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})

Taba:AddButton({
    Title = "Superhuman",
    Description = "Buy the Superhuman",
    Callback = function()
        local args = {
            "BuySuperhuman"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})

Taba:AddButton({
    Title = "DeathStep",
    Description = "Buy the DeathStep",
    Callback = function()
        local args = {
            "BuyDeathStep"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})

Taba:AddButton({
    Title = "SharkmanKarate",
    Description = "Buy the SharkmanKarate",
    Callback = function()
        local args = {
            "BuySharkmanKarate"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})


Taba:AddButton({
    Title = "DragonTalon",
    Description = "Buy the DragonTalon",
    Callback = function()
        local args = {
            "BuyDragonTalon"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})

Taba:AddButton({
    Title = "ElectricClaw",
    Description = "Buy the ElectricClaw",
    Callback = function()
        local args = {
	    "BuyElectricClaw"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        end
})


Taba:AddButton({
    Title = "Godhuman",
    Description = "Buy the Godhuman",
    Callback = function()
        local args = {
            "BuyGodhuman"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})

Taba:AddButton({
    Title = "SanguineArt",
    Description = "Buy the SanguineArt",
    Callback = function()
        local args = {
            "BuySanguineArt",
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end
})


local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local fluentUI = CoreGui:FindFirstChild("ScreenGui")

local toggleUI = Instance.new("ScreenGui")
toggleUI.Name = "Uigame"
toggleUI.ResetOnSpawn = false
toggleUI.IgnoreGuiInset = true
toggleUI.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 45)
button.Position = UDim2.new(1, -130, 1, -70)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Text = "Toggle UI"
button.Parent = toggleUI

button.MouseButton1Click:Connect(function()
    fluentUI.Enabled = not fluentUI.Enabled
    button.Text = fluentUI.Enabled and "Disabled Ui" or "Enabled UI"
end)
