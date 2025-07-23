local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local enemiesFolder = workspace:WaitForChild("Enemies")
local killAuraRange = 300
local bringRange = 200


local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
if not humanoidRootPart then
    warn("HumanoidRootPart ไม่เจอในตัวละคร")
    return
end
local backpack = player:WaitForChild("Backpack")

local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoidRootPart then
        warn("HumanoidRootPart ไม่เจอในตัวละคร")
    end
end

player.CharacterAdded:Connect(function()
	updateCharacter()

	-- อัปเดต backpack ใหม่หลังรีตัวละคร
	backpack = player:WaitForChild("Backpack")

	-- ถืออาวุธทันที (ไม่รอ delay)
	if selectedWeaponName then
		equipWeapon()
	end

	if running then
		startFarming()
	end
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
    if not selectedWeaponName then return end

    local tools = backpack:GetChildren()

    for _, tool in ipairs(tools) do
        if tool:IsA("Tool") then
            if selectedWeaponName == "melee" and table.find(melee, tool.Name) then
                tool.Parent = character
                return
            elseif selectedWeaponName == "sword" and table.find(sword, tool.Name) then
                tool.Parent = character
                return
            elseif selectedWeaponName == "gun" and table.find(gun, tool.Name) then
                tool.Parent = character
                return
            elseif selectedWeaponName == "fruit" and table.find(fruit, tool.Name) then
                tool.Parent = character
                return
            end
        end
    end
    -- ไม่มีการแจ้งเตือนใดๆ เมื่อไม่เจออาวุธ
end



-- unequip
local function unequipWeapon()
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid:UnequipTools()
        print("Unequipped all tools safely")
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
    while running do
        local targetEnemy = nil

        -- หา monster ในระยะ killAuraRange เท่านั้น (เป้าหมายหลัก)
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

        if not targetEnemy then
            task.wait(0.5)
        else
            local targetHRP = targetEnemy.HumanoidRootPart
            local targetHumanoid = targetEnemy.Humanoid

            print("Attacking monster:", targetEnemy.Name)
            attackedMonsters[targetEnemy.Name] = true

            tweenToPosition(humanoidRootPart, targetHRP.Position + Vector3.new(0, 15, 3))

            while targetHumanoid.Health > 0 and running do
                equipWeapon()

                tweenToPosition(humanoidRootPart, targetHRP.Position + Vector3.new(0, 15, 5))

                -- หา monster รอบๆ target ภายใน pullRange เพื่อดึงมาช่วยโจมตี
                local nearbyEnemies = {}
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if enemy ~= targetEnemy and enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                        local dist = (enemy.HumanoidRootPart.Position - targetHRP.Position).Magnitude
                        if dist <= bringRange and enemy.Humanoid.Health > 0 then
                            table.insert(nearbyEnemies, enemy)
                        end
                    end
                end

                -- Tween monster รอบๆ ให้มาอยู่ตำแหน่งเดียวกับ target
                for _, enemy in ipairs(nearbyEnemies) do
                    local enemyHRP = enemy.HumanoidRootPart
                    spawn(function()
                        tweenToPosition(enemyHRP, targetHRP.Position)
                    end)
                end

                -- ยิง event ไป server เพื่อโจมตี target
                ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack"):FireServer(0.1)
                ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit"):FireServer(targetHRP, {})

                -- โจมตี monster รอบๆ ด้วย (ถ้าต้องการ)
                for _, enemy in ipairs(nearbyEnemies) do
                    if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit"):FireServer(enemy.HumanoidRootPart, {})
                    end
                end

                task.wait(0.1)
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
    if lock then
        lock:Destroy()
    end
end

local function startFarming()
    enableNoclip()

    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.PlatformStand = true
    end

    equipWeapon()
    attackEnemies()
end

local function stopFarming()
    disableNoclip()
    running = false
    attackedMonsters = {} -- เคลียร์ตารางตอนหยุดฟาร์มด้วย
    unequipWeapon()

    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.PlatformStand = false
        character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    local lock = humanoidRootPart:FindFirstChild("Lock")
    if lock then
        lock:Destroy()
    end
end

-- UI 
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Beta v1.1",
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

Tabs.Main:AddSlider("AuraRangeSlider", {
    Title = "Kill Aura Range",
    Description = "Range to kill enemies",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
}):OnChanged(function(value)
    killAuraRange = value
    print("Kill aura range set to:", killAuraRange)
end)

Tabs.Main:AddSlider("PullRangeSlider", {
    Title = "Bringmob Range",
    Default = 200,
    Min = 10,
    Max = 350,
    Rounding = 0,
}):OnChanged(function(value)
    pullRange = value
    print("Pull range set to:", pullRange)
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

local mapFolder = workspace:WaitForChild("Map")

local function getIslandPositions()
    local parts = {}

    for _, obj in ipairs(mapFolder:GetChildren()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj.Name)
        elseif obj:IsA("Model") then
            -- ใช้ PrimaryPart ของ Model ถ้ามี
            if obj.PrimaryPart then
                table.insert(parts, obj.Name)
            else
                -- ถ้าไม่มี PrimaryPart, หาจุดกลางจาก BasePart แรกใน Model
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

Tabs.Main:AddDropdown("IslandDropdown", {
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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- เก็บสถานะเปิด/ปิดของแต่ละสแตท
local toggles = {
    Melee = false,
    Defense = false,
    Sword = false,
    Gun = false,
    ["Demon Fruit"] = false
}

-- ฟังก์ชันสำหรับเพิ่มแต้ม
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

-- สร้างลูปอัตโนมัติสำหรับแต่ละสแตท
for statName, _ in pairs(toggles) do
    Tabs.Main:AddToggle("Toggle_" .. statName, {
        Title = "Auto Add " .. statName,
        Default = false
    }):OnChanged(function(state)
        toggles[statName] = state

        if state then
            spawn(function()
                while toggles[statName] do
                    addStatPoint(statName)
                    task.wait(0.2)
                end
            end)
        end
    end)
    end


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:BuildConfigSection(Tabs.Main)
InterfaceManager:BuildInterfaceSection(Tabs.Main)
SaveManager:LoadAutoloadConfig()
