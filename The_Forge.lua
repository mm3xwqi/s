local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Auto Farm Variables
local allRocks = {}
local isAutoFarming = false
local Dropdown, Toggle, TweenSpeedSlider, Button
local noclipEnabled = false
local noclipConnection
local selectedRockType = "All Rocks"
local miningActive = false
local currentTargetRock = nil
local isFollowingRock = false
local stopMiningFlag = false

-- Teleport Variables
local isAutoTP = false
local selectedProximity = ""
local tpUpdateConnection = nil

-- Auto Farm Enemies Variables
local isAutoFarmEnemies = false
local selectedEnemyType = "All Enemies"
local currentTargetEnemy = nil
local isFollowingEnemy = false

-- Tween Variables
local TWEEN_OFFSET = Vector3.new(0, 5, 0)
local currentTweenSpeed = 50

-- Tween Functions (ใช้แบบเดียวกับในรูป)
local function tweenToPosition(targetPosition)
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    -- ใช้ offset
    local finalPosition = targetPosition + TWEEN_OFFSET
    
    -- คำนวณระยะทางและเวลา
    local distance = (humanoidRootPart.Position - finalPosition).Magnitude
    local travelTime = distance / currentTweenSpeed
    
    -- จำกัดเวลา tween
    if travelTime < 0.1 then travelTime = 0.1 end
    if travelTime > 2 then travelTime = 2 end
    
    -- สร้าง tween แบบเดียวกับในรูป
    local tweenInfo = TweenInfo.new(
        travelTime,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = TweenService:Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = CFrame.new(finalPosition)}
    )
    
    return tween
end

-- เพิ่ม NoClip
local function toggleNoClip(state)
    noclipEnabled = state
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide == true then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- อุปกรณ์สำหรับ Auto Farm
local function equipPickaxe()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    local pickaxe = backpack:FindFirstChild("Pickaxe")
    if not pickaxe then return nil end
    
    local character = LocalPlayer.Character
    if not character then return nil end
    
    pickaxe.Parent = character
    
    return pickaxe
end

local function startContinuousMining()
    miningActive = true
    stopMiningFlag = false
    
    while miningActive and isAutoFarming and not stopMiningFlag do
        local success = pcall(function()
            local args = {"Pickaxe"}
            ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated"):InvokeServer(unpack(args))
        end)
        
        wait(0.1)
    end
    miningActive = false
end

local function stopMining()
    stopMiningFlag = true
    miningActive = false
end

local function getRockHealth(rockModel)
    if not rockModel or not rockModel.Parent then
        return 0, 0
    end
    
    local health = rockModel:GetAttribute("Health") or 0
    local maxHealth = rockModel:GetAttribute("MaxHealth") or 0
    
    if health == 0 and rockModel:FindFirstChild("Humanoid") then
        health = rockModel.Humanoid.Health
        maxHealth = rockModel.Humanoid.MaxHealth
    end
    
    return health, maxHealth
end

local function checkRockHealth(rockModel)
    if not rockModel or not rockModel.Parent then
        return false
    end
    
    local health, _ = getRockHealth(rockModel)
    return health > 0
end

local function findAllRocks()
    allRocks = {}
    
    local function exploreUntilModel(obj)
        if obj.ClassName == "Model" then
            local health = obj:GetAttribute("Health")
            if health and health > 0 then
                local rockName = obj.Name
                
                local isSelectedType = false
                if selectedRockType == "All Rocks" then
                    isSelectedType = true
                else
                    if rockName:find(selectedRockType) or rockName == selectedRockType then
                        isSelectedType = true
                    end
                end
                
                if isSelectedType then
                    table.insert(allRocks, obj)
                end
            end
            return
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            exploreUntilModel(child)
        end
    end
    
    if workspace:FindFirstChild("Rocks") then
        exploreUntilModel(workspace.Rocks)
    end
    
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.ClassName == "Model" and obj:GetAttribute("Health") then
            local health = obj:GetAttribute("Health")
            if health and health > 0 then
                local rockName = obj.Name
                
                local isSelectedType = false
                if selectedRockType == "All Rocks" then
                    isSelectedType = true
                else
                    if rockName:find(selectedRockType) or rockName == selectedRockType then
                        isSelectedType = true
                    end
                end
                
                if isSelectedType then
                    table.insert(allRocks, obj)
                end
            end
        end
    end
    
    return #allRocks
end

local function isPlayerNearRock(rockModel, minDistance)
    if not rockModel then return false end
    
    local rockPosition
    if rockModel:FindFirstChild("PrimaryPart") then
        rockPosition = rockModel.PrimaryPart.Position
    elseif rockModel:FindFirstChild("HumanoidRootPart") then
        rockPosition = rockModel.HumanoidRootPart.Position
    else
        rockPosition = rockModel:GetPivot().Position
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - rockPosition).Magnitude
                if distance <= minDistance then
                    return true
                end
            end
        end
    end
    
    return false
end

local function isShinyRock(rockModel)
    if not rockModel then return false end
    
    local isShiny = rockModel:GetAttribute("IsShiny")
    if isShiny == true then
        return true
    end
    
    for _, part in pairs(rockModel:GetDescendants()) do
        if part:GetAttribute("IsShiny") == true then
            return true
        end
    end
    
    return false
end

local function followRock(rockModel)
    if not rockModel or not isAutoFarming then 
        isFollowingRock = false
        return false 
    end
    
    isFollowingRock = true
    currentTargetRock = rockModel
    
    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then 
        isFollowingRock = false
        return false 
    end
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        isFollowingRock = false
        return false
    end
    
    humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
    
    while isFollowingRock and currentTargetRock == rockModel and isAutoFarming do
        if not rockModel or not rockModel.Parent then
            break
        end
        
        if not checkRockHealth(rockModel) then
            break
        end
        
        if isPlayerNearRock(rockModel, 15) then
            break
        end
        
        local rockPosition
        if rockModel:FindFirstChild("PrimaryPart") then
            rockPosition = rockModel.PrimaryPart.Position
        elseif rockModel:FindFirstChild("HumanoidRootPart") then
            rockPosition = rockModel.HumanoidRootPart.Position
        else
            rockPosition = rockModel:GetPivot().Position
        end
        
        -- ใช้ tween แบบเดียวกับในรูป
        local tween = tweenToPosition(rockPosition)
        if tween then
            tween:Play()
            
            -- รอสักครู่
            wait(0.5)
        end
        
        wait(0.1)
    end
    
    isFollowingRock = false
    return true
end

local function farmSingleRock(rockModel)
    if not rockModel or not isAutoFarming then return false end
    
    if not checkRockHealth(rockModel) then
        return false
    end
    
    if isPlayerNearRock(rockModel, 15) then
        return false
    end
    
    if not miningActive then
        task.spawn(startContinuousMining)
    end
    
    task.spawn(function()
        followRock(rockModel)
    end)
    
    while isAutoFarming and currentTargetRock == rockModel do
        wait(0.5)
        
        if not rockModel or not rockModel.Parent then
            break
        end
        
        if isPlayerNearRock(rockModel, 15) then
            break
        end
        
        local currentHealth = getRockHealth(rockModel)
        
        if currentHealth <= 0 then
            break
        end
    end
    
    isFollowingRock = false
    currentTargetRock = nil
    
    wait(0.5)
    return true
end

local function selectClosestRockByType()
    findAllRocks()
    
    if #allRocks == 0 then
        return nil
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        for _, rock in ipairs(allRocks) do
            if checkRockHealth(rock) and not isPlayerNearRock(rock, 15) then
                if isShinyRock(rock) then
                    return rock
                end
            end
        end
        for _, rock in ipairs(allRocks) do
            if checkRockHealth(rock) and not isPlayerNearRock(rock, 15) then
                return rock
            end
        end
        return nil
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local closestRock = nil
    local minDistance = math.huge
    local shinyRocks = {}
    local normalRocks = {}
    
    for _, rock in ipairs(allRocks) do
        if checkRockHealth(rock) then
            if rock == currentTargetRock then
                continue
            end
            
            if isPlayerNearRock(rock, 15) then
                continue
            end
            
            if isShinyRock(rock) then
                table.insert(shinyRocks, rock)
            else
                table.insert(normalRocks, rock)
            end
        end
    end
    
    if #shinyRocks > 0 then
        for _, rock in ipairs(shinyRocks) do
            local rockPosition
            if rock:FindFirstChild("PrimaryPart") then
                rockPosition = rock.PrimaryPart.Position
            elseif rock:FindFirstChild("HumanoidRootPart") then
                rockPosition = rock.HumanoidRootPart.Position
            else
                rockPosition = rock:GetPivot().Position
            end
            
            local distance = (humanoidRootPart.Position - rockPosition).Magnitude
            
            if distance < minDistance then
                minDistance = distance
                closestRock = rock
            end
        end
        if closestRock then
            return closestRock
        end
    end
    
    minDistance = math.huge
    closestRock = nil
    
    for _, rock in ipairs(normalRocks) do
        local rockPosition
        if rock:FindFirstChild("PrimaryPart") then
            rockPosition = rock.PrimaryPart.Position
        elseif rock:FindFirstChild("HumanoidRootPart") then
            rockPosition = rock.HumanoidRootPart.Position
        else
            rockPosition = rock:GetPivot().Position
        end
        
        local distance = (humanoidRootPart.Position - rockPosition).Magnitude
        
        if distance < minDistance then
            minDistance = distance
            closestRock = rock
        end
    end
    
    if closestRock then
        return closestRock
    else
        for _, rock in ipairs(allRocks) do
            if checkRockHealth(rock) and rock ~= currentTargetRock then
                return rock
            end
        end
        return nil
    end
end

-- Auto Farm Enemies Functions
local function getEnemyOptions()
    local enemyNames = {
        "Axe Skeleton",
        "Blazing Slime", 
        "Blight Pyromancer",
        "Deathaxe Skeleton",
        "Elite Deathaxe Skeleton",
        "Elite Rogue Skeleton", 
        "Skeleton Rogue",
        "Slime"
    }
    
    local availableEnemies = {}
    
    table.insert(availableEnemies, "All Enemies")
    
    if workspace:FindFirstChild("Living") then
        for _, enemyName in ipairs(enemyNames) do
            local found = false
            for _, enemy in pairs(workspace.Living:GetChildren()) do
                if enemy:IsA("Model") and enemy.Name == enemyName then
                    local isPlayer = false
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character == enemy then
                            isPlayer = true
                            break
                        end
                    end
                    
                    if not isPlayer then
                        found = true
                        break
                    end
                end
            end
            
            if found then
                table.insert(availableEnemies, enemyName)
            end
        end
    end
    
    return availableEnemies
end

local function getAllEnemies()
    local enemies = {}
    
    if workspace:FindFirstChild("Living") then
        for _, enemy in pairs(workspace.Living:GetChildren()) do
            if enemy:IsA("Model") then
                local isPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character == enemy then
                        isPlayer = true
                        break
                    end
                end
                
                if not isPlayer then
                    local humanoid = enemy:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local enemyName = enemy.Name
                        local isSelectedType = false
                        
                        if selectedEnemyType == "All Enemies" then
                            isSelectedType = true
                        elseif enemyName == selectedEnemyType then
                            isSelectedType = true
                        end
                        
                        if isSelectedType then
                            table.insert(enemies, enemy)
                        end
                    end
                end
            end
        end
    end
    
    return enemies
end

local function isEnemyAlive(enemy)
    if not enemy or not enemy.Parent then
        return false
    end
    
    local humanoid = enemy:FindFirstChild("Humanoid")
    if not humanoid then
        return false
    end
    
    return humanoid.Health > 0
end

local function followEnemy(enemy)
    if not enemy or not isAutoFarmEnemies then 
        isFollowingEnemy = false
        return false 
    end
    
    isFollowingEnemy = true
    currentTargetEnemy = enemy
    
    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then 
        isFollowingEnemy = false
        return false 
    end
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        isFollowingEnemy = false
        return false
    end
    
    humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
    
    while isFollowingEnemy and currentTargetEnemy == enemy and isAutoFarmEnemies do
        if not enemy or not enemy.Parent then
            break
        end
        
        if not isEnemyAlive(enemy) then
            break
        end
        
        local enemyPosition
        if enemy:FindFirstChild("HumanoidRootPart") then
            enemyPosition = enemy.HumanoidRootPart.Position
        elseif enemy:FindFirstChild("PrimaryPart") then
            enemyPosition = enemy.PrimaryPart.Position
        else
            enemyPosition = enemy:GetPivot().Position
        end
        
        -- ใช้ tween แบบเดียวกับในรูป
        local tween = tweenToPosition(enemyPosition)
        if tween then
            tween:Play()
            wait(0.5)
        end
        
        wait(0.1)
    end
    
    isFollowingEnemy = false
    return true
end

local function farmSingleEnemy(enemy)
    if not enemy or not isAutoFarmEnemies then return false end
    
    if not isEnemyAlive(enemy) then
        return false
    end
    
    task.spawn(function()
        followEnemy(enemy)
    end)
    
    while isAutoFarmEnemies and currentTargetEnemy == enemy do
        wait(0.5)
        
        if not enemy or not enemy.Parent then
            break
        end
        
        if not isEnemyAlive(enemy) then
            break
        end
    end
    
    isFollowingEnemy = false
    currentTargetEnemy = nil
    
    wait(0.5)
    return true
end

local function selectClosestEnemyByType()
    local enemies = getAllEnemies()
    
    if #enemies == 0 then
        return nil
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        for _, enemy in ipairs(enemies) do
            if isEnemyAlive(enemy) then
                return enemy
            end
        end
        return nil
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local closestEnemy = nil
    local minDistance = math.huge
    
    for _, enemy in ipairs(enemies) do
        if isEnemyAlive(enemy) then
            if enemy == currentTargetEnemy then
                continue
            end
            
            local enemyPosition
            if enemy:FindFirstChild("HumanoidRootPart") then
                enemyPosition = enemy.HumanoidRootPart.Position
            elseif enemy:FindFirstChild("PrimaryPart") then
                enemyPosition = enemy.PrimaryPart.Position
            else
                enemyPosition = enemy:GetPivot().Position
            end
            
            local distance = (humanoidRootPart.Position - enemyPosition).Magnitude
            
            if distance < minDistance then
                minDistance = distance
                closestEnemy = enemy
            end
        end
    end
    
    return closestEnemy
end

local function startAutoFarmEnemies()
    isAutoFarmEnemies = true
    toggleNoClip(true)
    
    while isAutoFarmEnemies do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            isFollowingEnemy = false
            currentTargetEnemy = nil
            
            local characterAdded
            repeat
                characterAdded = LocalPlayer.CharacterAdded:Wait()
                wait(1)
            until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            toggleNoClip(true)
            wait(1)
        end
        
        if not currentTargetEnemy or not currentTargetEnemy.Parent or not isEnemyAlive(currentTargetEnemy) then
            isFollowingEnemy = false
            currentTargetEnemy = nil
            
            local enemy = selectClosestEnemyByType()
            
            if enemy then
                farmSingleEnemy(enemy)
            else
                wait(1)
            end
        else
            wait(0.5)
        end
    end
    
    toggleNoClip(false)
    isAutoFarmEnemies = false
end

local function startAutoFarm()
    isAutoFarming = true
    toggleNoClip(true)
    
    equipPickaxe()
    
    while isAutoFarming do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            isFollowingRock = false
            currentTargetRock = nil
            
            local characterAdded
            repeat
                characterAdded = LocalPlayer.CharacterAdded:Wait()
                wait(1)
            until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            equipPickaxe()
            toggleNoClip(true)
            
            if not miningActive then
                task.spawn(startContinuousMining)
            end
            
            wait(1)
        end
        
        if not currentTargetRock or not currentTargetRock.Parent or not checkRockHealth(currentTargetRock) or isPlayerNearRock(currentTargetRock, 15) then
            isFollowingRock = false
            currentTargetRock = nil
            
            local rockModel = selectClosestRockByType()
            
            if rockModel then
                farmSingleRock(rockModel)
            else
                wait(1)
            end
        else
            wait(0.5)
        end
    end
    
    stopMining()
    toggleNoClip(false)
    isAutoFarming = false
end

-- Teleport Functions
local function getProximityOptions()
    local options = {}
    
    if workspace:FindFirstChild("Proximity") then
        for _, proximity in pairs(workspace.Proximity:GetChildren()) do
            if proximity:IsA("Model") then
                table.insert(options, proximity.Name)
            end
        end
    end
    
    return options
end

local function getSelectedProximityObject()
    local proximityName = selectedProximity
    if type(proximityName) == "table" then
        proximityName = proximityName[1] or ""
    end
    
    if proximityName == "" then
        return nil
    end
    
    if workspace:FindFirstChild("Proximity") then
        local proximityObject = workspace.Proximity:FindFirstChild(proximityName)
        if proximityObject and proximityObject:IsA("Model") then
            return proximityObject
        end
    end
    
    return nil
end

local function startAutoTP()
    isAutoTP = true
    toggleNoClip(true)
    
    while isAutoTP do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            wait(1)
            continue
        end
        
        local proximityObject = getSelectedProximityObject()
        if not proximityObject then
            isAutoTP = false
            toggleNoClip(false)
            
            Rayfield:Notify({
                Title = "Teleport Error",
                Content = "Proximity not found!",
                Duration = 3,
                Image = 4483362458,
            })
            break
        end
        
        local targetPosition
        if proximityObject:FindFirstChild("PrimaryPart") then
            targetPosition = proximityObject.PrimaryPart.Position
        elseif proximityObject:FindFirstChild("HumanoidRootPart") then
            targetPosition = proximityObject.HumanoidRootPart.Position
        elseif proximityObject:FindFirstChild("Position") then
            targetPosition = proximityObject.Position
        else
            targetPosition = proximityObject:GetPivot().Position
        end
        
        -- ใช้ tween แบบเดียวกับในรูป
        local tween = tweenToPosition(targetPosition)
        if tween then
            tween:Play()
            wait(1)
        end
        
        wait(0.1)
    end
    
    toggleNoClip(false)
    isAutoTP = false
end

local Window = Rayfield:CreateWindow({
   Name = "Miau hub",
   LoadingTitle = "Miau hub",
   LoadingSubtitle = "by MX",
   Theme = "Default",
   ToggleUIKeybind = "K",
   ConfigurationSaving = {
      Enabled = true,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink"
   },
   KeySystem = false,
})

-- Main Tab (Auto Farm)
local MainTab = Window:CreateTab("Main", 4483362458)
local Section = MainTab:CreateSection("Auto Farm Settings")

local function updateDropdownOptions()
    local rockTypes = {}
    
    local function collectRockTypes(obj)
        if obj.ClassName == "Model" and obj:GetAttribute("Health") then
            local rockName = obj.Name
            rockTypes[rockName] = true
            return
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            collectRockTypes(child)
        end
    end
    
    if workspace:FindFirstChild("Rocks") then
        collectRockTypes(workspace.Rocks)
    end
    
    local options = {"All Rocks"}
    for rockType, _ in pairs(rockTypes) do
        table.insert(options, rockType)
    end
    
    return options
end

Dropdown = MainTab:CreateDropdown({
    Name = "Select Rock Type",
    Options = {"All Rocks"},
    CurrentOption = "All Rocks",
    MultipleOptions = false,
    Flag = "RockDropdown",
    Callback = function(Option)
        local selected = Option
        if type(Option) == "table" then
            selected = Option[1] or "All Rocks"
        end
        
        selectedRockType = selected
    end,
})

TweenSpeedSlider = MainTab:CreateSlider({
    Name = "Move Speed",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs/sec",
    CurrentValue = 50,
    Flag = "TweenSpeed",
    Callback = function(Value)
        currentTweenSpeed = Value  -- อัปเดตความเร็ว tween
    end,
})

Button = MainTab:CreateButton({
    Name = "Refresh Rocks",
    Callback = function()
        findAllRocks()
        local newOptions = updateDropdownOptions()
        pcall(function()
            Dropdown:Refresh(newOptions, selectedRockType)
        end)
    end,
})

Toggle = MainTab:CreateToggle({
   Name = "Auto Farm",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
        if Value then
            if not LocalPlayer.Character then
                Toggle:Set(false)
                return
            end
            
            task.spawn(startAutoFarm)
        else
            stopMining()
            isAutoFarming = false
            
            toggleNoClip(false)
            currentTargetRock = nil
            isFollowingRock = false
        end
   end,
})

-- Auto Farm Enemies Section ใน Main Tab
local EnemiesSection = MainTab:CreateSection("Auto Farm Enemies")

local EnemiesDropdown = MainTab:CreateDropdown({
    Name = "Select Enemies",
    Options = getEnemyOptions(),
    CurrentOption = "All Enemies",
    MultipleOptions = false,
    Flag = "EnemiesDropdown",
    Callback = function(Option)
        local selected = Option
        if type(Option) == "table" then
            selected = Option[1] or "All Enemies"
        end
        
        selectedEnemyType = selected
        
        if selected == "All Enemies" then
            Rayfield:Notify({
                Title = "Target Mode",
                Content = "Targeting ALL enemies",
                Duration = 2,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Target Selected",
                Content = "Targeting: " .. selected,
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

MainTab:CreateButton({
    Name = "Refresh Enemies List",
    Callback = function()
        local newOptions = getEnemyOptions()
        pcall(function()
            EnemiesDropdown:Refresh(newOptions, selectedEnemyType)
        end)
        
        local enemies = getAllEnemies()
        if #enemies > 0 then
            Rayfield:Notify({
                Title = "Enemies Found",
                Content = "Found " .. #enemies .. " enemies",
                Duration = 3,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "No Enemies",
                Content = "No enemies found matching selection",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

local AutoFarmEnemiesToggle = MainTab:CreateToggle({
    Name = "Auto Farm Enemies",
    CurrentValue = false,
    Flag = "AutoFarmEnemiesToggle",
    Callback = function(Value)
        if Value then
            if not LocalPlayer.Character then
                if AutoFarmEnemiesToggle and typeof(AutoFarmEnemiesToggle.Set) == "function" then
                    task.wait(0.1)
                    AutoFarmEnemiesToggle:Set(false)
                end
                return
            end
            
            local enemies = getAllEnemies()
            if #enemies == 0 then
                Rayfield:Notify({
                    Title = "No Targets",
                    Content = "No enemies found for: " .. (selectedEnemyType == "All Enemies" and "All Enemies" or selectedEnemyType),
                    Duration = 3,
                    Image = 4483362458,
                })
                if AutoFarmEnemiesToggle and typeof(AutoFarmEnemiesToggle.Set) == "function" then
                    task.wait(0.1)
                    AutoFarmEnemiesToggle:Set(false)
                end
                return
            end
            
            task.spawn(startAutoFarmEnemies)
            
            Rayfield:Notify({
                Title = "Auto Farm Enemies Started",
                Content = "Targeting: " .. (selectedEnemyType == "All Enemies" and "All Enemies" or selectedEnemyType),
                Duration = 3,
                Image = 4483362458,
            })
        else
            isAutoFarmEnemies = false
            
            toggleNoClip(false)
            currentTargetEnemy = nil
            isFollowingEnemy = false
            
            Rayfield:Notify({
                Title = "Auto Farm Enemies Stopped",
                Content = "Stopped farming enemies",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

-- Teleport Tab
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local TeleportSection = TeleportTab:CreateSection("Auto Teleport Settings")

local ProximityDropdown = TeleportTab:CreateDropdown({
    Name = "Select Proximity",
    Options = getProximityOptions(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "ProximityDropdown",
    Callback = function(Option)
        if type(Option) == "table" then
            selectedProximity = Option[1] or ""
        else
            selectedProximity = Option or ""
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Refresh Proximity",
    Callback = function()
        local newOptions = getProximityOptions()
        pcall(function()
            ProximityDropdown:Refresh(newOptions, selectedProximity)
        end)
    end,
})

local AutoTPToggle = TeleportTab:CreateToggle({
    Name = "Auto TP",
    CurrentValue = false,
    Flag = "AutoTPToggle",
    Callback = function(Value)
        if Value then
            if not LocalPlayer.Character then
                if AutoTPToggle and typeof(AutoTPToggle.Set) == "function" then
                    task.wait(0.1)
                    AutoTPToggle:Set(false)
                end
                return
            end
            
            local checkProximity = selectedProximity
            if type(checkProximity) == "table" then
                checkProximity = checkProximity[1] or ""
            end
            
            if checkProximity == "" then
                Rayfield:Notify({
                    Title = "Teleport Error",
                    Content = "Please select a proximity first!",
                    Duration = 3,
                    Image = 4483362458,
                })
                if AutoTPToggle and typeof(AutoTPToggle.Set) == "function" then
                    task.wait(0.1)
                    AutoTPToggle:Set(false)
                end
                return
            end
            
            task.spawn(startAutoTP)
        else
            isAutoTP = false
            toggleNoClip(false)
        end
    end,
})

task.spawn(function()
    wait(2)
    Button.Callback()
    
    wait(1)
    local newOptions = getProximityOptions()
    pcall(function()
        ProximityDropdown:Refresh(newOptions, selectedProximity)
    end)
    
    wait(1)
    local enemyOptions = getEnemyOptions()
    pcall(function()
        EnemiesDropdown:Refresh(enemyOptions, selectedEnemyType)
    end)
    
    local enemyList = getEnemyOptions()
    if #enemyList > 1 then
        Rayfield:Notify({
            Title = "Enemies Available",
            Content = "Found " .. (#enemyList - 1) .. " enemy types",
            Duration = 4,
            Image = 4483362458,
        })
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if isAutoFarming then
        isFollowingRock = false
        currentTargetRock = nil
    end
    if isAutoFarmEnemies then
        isFollowingEnemy = false
        currentTargetEnemy = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if isAutoFarming then
        wait(2)
        
        if character:FindFirstChild("HumanoidRootPart") then
            equipPickaxe()
            toggleNoClip(true)
            
            if not miningActive then
                task.spawn(startContinuousMining)
            end
        end
    end
    
    if isAutoTP then
        wait(2)
        
        if character:FindFirstChild("HumanoidRootPart") then
            toggleNoClip(true)
            
            wait(1)
            if isAutoTP then
                task.spawn(startAutoTP)
            end
        end
    end
    
    if isAutoFarmEnemies then
        wait(2)
        
        if character:FindFirstChild("HumanoidRootPart") then
            toggleNoClip(true)
            
            wait(1)
            if isAutoFarmEnemies then
                task.spawn(startAutoFarmEnemies)
            end
        end
    end
end)
