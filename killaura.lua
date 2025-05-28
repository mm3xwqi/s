local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local enemiesFolder = workspace:WaitForChild("Enemies")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local backpack = player:WaitForChild("Backpack")


local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(function()
    updateCharacter()
    
    task.delay(1, function()
        -- ตรวจว่ามีศัตรูอยู่ไหม
        local firstEnemy = enemiesFolder:FindFirstChildWhichIsA("Model")
        if firstEnemy and firstEnemy:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = firstEnemy:FindFirstChild("HumanoidRootPart")
            enableNoclip()
            tweenToPosition(humanoidRootPart, enemyHRP.Position + Vector3.new(0, 10, 0))
        end

        if selectedWeaponName then
            equipWeapon()
        end

        if running then
            startFarming()
        end
    end)
end)



updateCharacter()


-- Table เก็บชื่ออาวุธ
local melee = {
    "Combat", "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
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

local SPEED = 350
local running = false
local selectedWeaponName = nil
local noclipActive = false



-- equip
local function equipWeapon()
    if selectedWeaponName == "melee" then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and table.find(melee, tool.Name) then
                tool.Parent = character
                print("Equipped melee:", tool.Name)
                return
            end
        end
    elseif selectedWeaponName == "sword" then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and table.find(sword, tool.Name) then
                tool.Parent = character
                print("Equipped sword:", tool.Name)
                return
            end
        end
    elseif selectedWeaponName == "gun" then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and table.find(gun, tool.Name) then
                tool.Parent = character
                print("Equipped gun:", tool.Name)
                return
            end
        end
    elseif selectedWeaponName == "fruit" then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and table.find(fruit, tool.Name) then
                tool.Parent = character
                print("Equipped fruit:", tool.Name)
                return
            end
        end
        local tool = backpack:FindFirstChild(selectedWeaponName)
        if tool then
            tool.Parent = character
            print("Equipped:", tool.Name)
        end
    end
end


-- unequip
local function unequipWeapon()
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = backpack
            print("Unequipped:", tool.Name)
        end
    end
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

-- fast attack
local function attackAllEnemies()
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if not running then break end

        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")

            tweenToPosition(humanoidRootPart, enemyHRP.Position + Vector3.new(0, 10, 0))

            equipWeapon()  

            while enemyHumanoid.Health > 0 and running do
                tweenToPosition(humanoidRootPart, enemyHRP.Position + Vector3.new(0, 10, 0))
                ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack"):FireServer(0.4)
                ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit"):FireServer(enemyHRP, {})
                task.wait(0.2)
            end
        end
    end
end

local function attackEnemies()
    running = true
    while running do
        attackAllEnemies()
        task.wait(0.2)
    end
end

local function enableNoclip()
    if not noclipActive then
        noclipActive = true
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
    end
end

local function disableNoclip()
    noclipActive = false
    local lock = humanoidRootPart:FindFirstChild("Lock")
    if lock then lock:Destroy() end
end



local function startFarming()
    enableNoclip()
    attackEnemies()
end


local function stopFarming()
    disableNoclip()
    running = false
    unequipWeapon() 
end

-- UI 
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Beta v0.0.3",
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
        character.Humanoid.PlatformStand = true
    else
        stopFarming()
        character.Humanoid.PlatformStand = false
        Fluent:Notify({
            Title = "Notification",
            Content = "Tyrant of the Skie is stopped",
            Duration = 3
        })
    end
end)

-- Select weapon
Tabs.Main:AddDropdown("Dropdown", {
    Title = "Select weapon",
    Values = {"melee", "sword", "gun", "fruit"},
    Multi = false,
    Default = 1,
}):OnChanged(function(value)
    selectedWeaponName = value
    print("Selected weapon:", value)
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:BuildConfigSection(Tabs.Main)
InterfaceManager:BuildInterfaceSection(Tabs.Main)
SaveManager:LoadAutoloadConfig()
