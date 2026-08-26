local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title       = "KKKK Hub",
    SubTitle    = "by Z",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(400, 320),
    Acrylic     = true,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightAlt
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "sword"    }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer
local Character         = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP               = Character:WaitForChild("HumanoidRootPart")
local Humanoid          = Character:WaitForChild("Humanoid")

local Net = ReplicatedStorage:FindFirstChild("Modules")
if Net then Net = Net:FindFirstChild("Net") end
if not Net then error("Net module not found!") end

local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
if not RegisterAttack or not RegisterHit then error("Remote events missing") end

local SESSION_ID   = "32501259"
local MAX_DISTANCE = 100
local MIN_DISTANCE = 1
local SPEED        = 250
local HOVER_Y      = 25
local REACH        = 6
local ATTACK_RATE  = 0.05
local BRING_RADIUS = 300
local WEAPON_TYPES = {"Melee", "Sword", "Gun", "Fruit"}

local autoNearEnabled    = false
local autoFarmEnabled    = false
local bringMobEnabled    = true
local m1AuraEnabled      = false
local selectedWeaponType = "Melee"
local selectedMonster    = nil
local currentEnemy       = nil
local trackedRoot        = nil
local followConn         = nil
local farmConn           = nil
local m1AuraThread       = nil
local bringIndex         = 1
local noclipConn         = nil

local cachedSpawnPositions = {}
local spawnCacheBuilt      = false
local enemyCacheBuilt      = false

local function enableNoclip()
    pcall(function() if noclipConn then noclipConn:Disconnect() end end)
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    pcall(function() if noclipConn then noclipConn:Disconnect() end end)
    noclipConn = nil
end

local function refreshChar()
    Character = LocalPlayer.Character
    if not Character then return false end
    HRP      = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChild("Humanoid")
    return HRP ~= nil and Humanoid ~= nil
end

local function stripLevel(name)
    return (name:gsub("%s*%[.-%]", "")):match("^%s*(.-)%s*$")
end

local function getTargetPart(enemy)
    if not enemy or not enemy.Parent then return nil end
    for _, name in ipairs({"LeftLowerLeg", "Head", "HumanoidRootPart"}) do
        local p = enemy:FindFirstChild(name)
        if p and p:IsA("BasePart") then return p end
    end
    for _, child in ipairs(enemy:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

local function getEnemyRoot(enemy)
    if not enemy or not enemy.Parent then return nil end
    return enemy:FindFirstChild("HumanoidRootPart")
end

local function getHoverCFrame(rootPart)
    local rcf = rootPart.CFrame
    return CFrame.new(rcf.Position + Vector3.new(0, HOVER_Y, 0)) * (rcf - rcf.Position)
end

local function snapYToEnemy(rootPart)
    if not rootPart or not HRP then return end
    pcall(function()
        HRP.AssemblyLinearVelocity = Vector3.zero
        local targetY = rootPart.Position.Y + HOVER_Y
        HRP.CFrame = CFrame.new(HRP.Position.X, targetY, HRP.Position.Z) * HRP.CFrame.Rotation
    end)
end

local function buildSpawnCache(monsterName)
    if spawnCacheBuilt then return end
    cachedSpawnPositions = {}
    local spawns = workspace:FindFirstChild("_WorldOrigin")
    if spawns then spawns = spawns:FindFirstChild("EnemySpawns") end
    if spawns then
        for _, part in ipairs(spawns:GetChildren()) do
            if stripLevel(part.Name) == monsterName then
                local pos = nil
                if part:IsA("BasePart") then
                    pos = part.Position
                elseif part:IsA("Model") then
                    local root = part:FindFirstChild("HumanoidRootPart") or part.PrimaryPart
                    if root then pos = root.Position end
                end
                if pos then
                    local dup = false
                    for _, cp in ipairs(cachedSpawnPositions) do
                        if (cp - pos).Magnitude < 5 then dup = true break end
                    end
                    if not dup then table.insert(cachedSpawnPositions, pos) end
                end
            end
        end
    end
    spawnCacheBuilt = true
end

local function buildEnemyPositionCache(monsterName)
    if enemyCacheBuilt then return end
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return end
    for _, model in ipairs(folder:GetChildren()) do
        if stripLevel(model.Name) == monsterName then
            local root = model:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                local dup = false
                for _, cp in ipairs(cachedSpawnPositions) do
                    if (cp - pos).Magnitude < 10 then dup = true break end
                end
                if not dup then table.insert(cachedSpawnPositions, pos) end
            end
        end
    end
    enemyCacheBuilt = true
end

local function ensureCache(monsterName)
    buildSpawnCache(monsterName)
    buildEnemyPositionCache(monsterName)
end

local function getEnemies()
    local list = {}
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return list end
    for _, model in ipairs(folder:GetChildren()) do
        local hum  = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 then
            table.insert(list, model)
        end
    end
    return list
end

local function getNearestEnemy()
    local best, bestDist = nil, math.huge
    for _, model in ipairs(getEnemies()) do
        local root = model:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (HRP.Position - root.Position).Magnitude
            if dist < bestDist then best, bestDist = model, dist end
        end
    end
    return best
end

local function getEnemyByName(monsterName)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    local best, bestDist = nil, math.huge
    for _, model in ipairs(folder:GetChildren()) do
        if stripLevel(model.Name) == monsterName then
            local hum  = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local dist = (HRP.Position - root.Position).Magnitude
                if dist < bestDist then best, bestDist = model, dist end
            end
        end
    end
    return best
end

local function getEnemiesInRange()
    local char = LocalPlayer.Character
    if not char then return {} end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    local myPos  = hrp.Position
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return {} end
    local results = {}
    for _, enemy in ipairs(folder:GetChildren()) do
        if enemy and enemy.Parent then
            local hum = enemy:FindFirstChild("Humanoid")
            if hum and hum.Health and hum.Health > 0 then
                local part = getTargetPart(enemy)
                if part and part.Parent then
                    local ok, pos = pcall(function() return part.Position end)
                    if ok and pos then
                        local dist = (pos - myPos).Magnitude
                        if dist <= MAX_DISTANCE and dist >= MIN_DISTANCE then
                            table.insert(results, {enemy = enemy, part = part, dist = dist})
                        end
                    end
                end
            end
        end
    end
    return results
end

local function getSpawnNames()
    local seen = {}
    local list = {}
    local spawns = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then
        for _, part in ipairs(spawns:GetChildren()) do
            local clean = stripLevel(part.Name)
            if clean ~= "" and not seen[clean] then
                seen[clean] = true
                table.insert(list, clean)
            end
        end
    end
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            local clean = stripLevel(model.Name)
            if clean ~= "" and not seen[clean] then
                seen[clean] = true
                table.insert(list, clean)
            end
        end
    end
    if #list == 0 then return {"(ไม่พบมอน)"} end
    table.sort(list, function(a, b) return a:lower() < b:lower() end)
    return list
end

local function findToolByTooltip(keyword)
    local char = LocalPlayer.Character
    if char then
        local held = char:FindFirstChildOfClass("Tool")
        if held and string.find(held.ToolTip or "", keyword, 1, true) then
            return held, true
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil, false end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.ToolTip or "", keyword, 1, true) then
            return tool, false
        end
    end
    return nil, false
end

local function equipByTooltip(keyword)
    if not keyword or not Character then return end
    local tool, alreadyEquipped = findToolByTooltip(keyword)
    if alreadyEquipped then return end
    if not tool then return end
    if Humanoid then Humanoid:EquipTool(tool) end
end

local function bringTickNearTarget(targetEnemy)
    local targetRoot = targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local targetPos = targetRoot.Position
    pcall(function()
        targetRoot.CFrame = CFrame.new(targetPos)
        targetRoot.AssemblyLinearVelocity  = Vector3.zero
        targetRoot.AssemblyAngularVelocity = Vector3.zero
    end)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return end
    local candidates = {}
    for _, model in ipairs(folder:GetChildren()) do
        if model ~= targetEnemy then
            local hum  = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                if (root.Position - targetPos).Magnitude <= BRING_RADIUS then
                    table.insert(candidates, {model = model, root = root})
                end
            end
        end
    end
    if #candidates == 0 then bringIndex = 1 return end
    bringIndex = (bringIndex - 1) % #candidates + 1
    local entry = candidates[bringIndex]
    pcall(function()
        for _, part in ipairs(entry.model:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        entry.root.CFrame = CFrame.new(targetPos)
        entry.root.AssemblyLinearVelocity  = Vector3.zero
        entry.root.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function bringTickNearTargetByName(targetEnemy, monsterName)
    local targetRoot = targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local targetPos = targetRoot.Position
    pcall(function()
        targetRoot.CFrame = CFrame.new(targetPos)
        targetRoot.AssemblyLinearVelocity  = Vector3.zero
        targetRoot.AssemblyAngularVelocity = Vector3.zero
    end)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return end
    local candidates = {}
    for _, model in ipairs(folder:GetChildren()) do
        if model ~= targetEnemy and stripLevel(model.Name) == monsterName then
            local hum  = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                if (root.Position - targetPos).Magnitude <= BRING_RADIUS then
                    table.insert(candidates, {model = model, root = root})
                end
            end
        end
    end
    if #candidates == 0 then bringIndex = 1 return end
    bringIndex = (bringIndex - 1) % #candidates + 1
    local entry = candidates[bringIndex]
    pcall(function()
        for _, part in ipairs(entry.model:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        entry.root.CFrame = CFrame.new(targetPos)
        entry.root.AssemblyLinearVelocity  = Vector3.zero
        entry.root.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function stopM1Aura()
    if m1AuraThread then task.cancel(m1AuraThread) m1AuraThread = nil end
end

local function spawnAuraLoop(runCondition)
    stopM1Aura()
    m1AuraThread = task.spawn(function()
        while runCondition() do
            local enemies = getEnemiesInRange()
            if #enemies > 0 then
                table.sort(enemies, function(a, b) return a.dist < b.dist end)
                local hitTable    = {}
                local primaryPart = nil
                for _, entry in ipairs(enemies) do
                    if entry.enemy and entry.enemy.Parent and entry.part and entry.part.Parent then
                        table.insert(hitTable, {entry.enemy, entry.part})
                        if not primaryPart then primaryPart = entry.part end
                    end
                end
                if primaryPart and #hitTable > 0 then
                    RegisterAttack:FireServer(0.5)
                    task.wait()
                    RegisterHit:FireServer(primaryPart, hitTable, nil, SESSION_ID)
                end
            end
            task.wait(ATTACK_RATE)
        end
        m1AuraThread = nil
    end)
end

local function startM1Aura()           spawnAuraLoop(function() return autoNearEnabled or autoFarmEnabled end) end
local function startM1AuraStandalone() spawnAuraLoop(function() return m1AuraEnabled end) end

local function moveCFrameToward(hrp, targetCF, dt)
    pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
    local targetPos  = targetCF.Position
    local currentPos = hrp.Position
    local fromPos    = Vector3.new(currentPos.X, targetPos.Y, currentPos.Z)
    local delta      = targetPos - fromPos
    local dist       = delta.Magnitude
    local step       = SPEED * dt
    local newPos     = (dist <= step or dist < 0.01) and targetPos or fromPos + (delta / dist) * step
    pcall(function()
        hrp.CFrame = CFrame.new(newPos) * targetCF.Rotation
    end)
end

local function startFollow()
    if followConn then followConn:Disconnect() end
    local prevEnemy = nil

    followConn = RunService.Heartbeat:Connect(function(dt)
        if not autoNearEnabled then
            followConn:Disconnect() followConn = nil
            stopM1Aura()
            return
        end
        if not refreshChar() then return end
        equipByTooltip(selectedWeaponType)

        local enemyHum  = currentEnemy and currentEnemy:FindFirstChildOfClass("Humanoid")
        local enemyRoot = currentEnemy and currentEnemy:FindFirstChild("HumanoidRootPart")

        if not currentEnemy or not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
            stopM1Aura()
            trackedRoot  = nil
            currentEnemy = getNearestEnemy()
            prevEnemy    = nil
            if not currentEnemy then return end
            trackedRoot = getEnemyRoot(currentEnemy)
            snapYToEnemy(trackedRoot)
        end

        if not trackedRoot or not trackedRoot.Parent then
            trackedRoot = getEnemyRoot(currentEnemy)
            if not trackedRoot then return end
            snapYToEnemy(trackedRoot)
        end

        if bringMobEnabled then bringTickNearTarget(currentEnemy) end

        local targetCF = getHoverCFrame(trackedRoot)
        local dist     = (targetCF.Position - HRP.Position).Magnitude

        if dist > REACH then
            stopM1Aura()
            prevEnemy = nil
            moveCFrameToward(HRP, targetCF, dt)
        else
            pcall(function()
                HRP.AssemblyLinearVelocity = Vector3.zero
                HRP.CFrame = targetCF
            end)
            if currentEnemy ~= prevEnemy then
                prevEnemy = currentEnemy
                startM1Aura()
            end
        end
    end)
end

local function startFarm()
    if farmConn then farmConn:Disconnect() end
    local prevEnemy     = nil
    local spawnIdx      = 1
    local isSnapping    = false
    local snapDone      = false
    local lastSpawnPos  = nil

    farmConn = RunService.Heartbeat:Connect(function(dt)
        if not autoFarmEnabled then
            farmConn:Disconnect() farmConn = nil
            stopM1Aura()
            return
        end
        if not refreshChar() then return end
        if not selectedMonster then return end
        equipByTooltip(selectedWeaponType)

        ensureCache(selectedMonster)

        local target = getEnemyByName(selectedMonster)

        if target then
            isSnapping   = false
            snapDone     = false
            lastSpawnPos = nil
            spawnIdx     = 1

            local enemyHum  = target:FindFirstChildOfClass("Humanoid")
            local enemyRoot = target:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
                trackedRoot = nil
                return
            end

            if currentEnemy ~= target then
                currentEnemy = target
                trackedRoot  = nil
            end

            if trackedRoot == nil or trackedRoot.Parent == nil or not target:IsAncestorOf(trackedRoot) then
                trackedRoot = getEnemyRoot(target)
                snapYToEnemy(trackedRoot)
            end
            if not trackedRoot then return end

            if bringMobEnabled then bringTickNearTargetByName(target, selectedMonster) end

            local targetCF = getHoverCFrame(trackedRoot)
            local dist     = (targetCF.Position - HRP.Position).Magnitude

            if dist > REACH then
                stopM1Aura()
                prevEnemy = nil
                moveCFrameToward(HRP, targetCF, dt)
            else
                pcall(function()
                    HRP.AssemblyLinearVelocity = Vector3.zero
                    HRP.CFrame = targetCF
                end)
                if target ~= prevEnemy then
                    prevEnemy = target
                    startM1Aura()
                end
            end
        else
            stopM1Aura()
            prevEnemy    = nil
            currentEnemy = nil
            trackedRoot  = nil

            if #cachedSpawnPositions == 0 then return end
            if spawnIdx > #cachedSpawnPositions then spawnIdx = 1 end

            local spawnPos = cachedSpawnPositions[spawnIdx] + Vector3.new(0, HOVER_Y, 0)

            pcall(function() HRP.AssemblyLinearVelocity = Vector3.zero end)

            if lastSpawnPos ~= spawnPos then
                lastSpawnPos = spawnPos
                snapDone     = false
                isSnapping   = false
            end

            if not snapDone and not isSnapping then
                isSnapping = true
                task.spawn(function()
                    pcall(function()
                        HRP.CFrame = CFrame.new(HRP.Position.X, spawnPos.Y, HRP.Position.Z) * HRP.CFrame.Rotation
                    end)
                    task.wait(0.5)
                    isSnapping = false
                    snapDone   = true
                end)
                return
            end

            if isSnapping then return end

            local dist = (spawnPos - HRP.Position).Magnitude
            if dist > REACH then
                local delta  = spawnPos - HRP.Position
                local step   = SPEED * dt
                local newPos = HRP.Position + delta.Unit * step
                pcall(function()
                    HRP.AssemblyLinearVelocity = Vector3.zero
                    HRP.CFrame = CFrame.new(newPos)
                end)
            else
                snapDone = false
                spawnIdx = spawnIdx % #cachedSpawnPositions + 1
            end
        end
    end)
end

local weaponDropdown = Tabs.Main:AddDropdown("WeaponSelect", {
    Title   = "Equip Item",
    Values  = WEAPON_TYPES,
    Multi   = false,
    Default = 1,
})
weaponDropdown:OnChanged(function(value)
    selectedWeaponType = value
    if autoNearEnabled or autoFarmEnabled then equipByTooltip(value) end
end)
selectedWeaponType = WEAPON_TYPES[1]

local ToggleAuto = Tabs.Main:AddToggle("AutoNear", { Title = "Auto Nears", Default = false })
ToggleAuto:OnChanged(function()
    autoNearEnabled = Options.AutoNear.Value
    if autoNearEnabled then
        currentEnemy = nil
        trackedRoot  = nil
        enableNoclip()
        startFollow()
        Fluent:Notify({ Title = "Auto Nears", Content = "Enabled", Duration = 3 })
    else
        stopM1Aura()
        disableNoclip()
        if m1AuraEnabled then startM1AuraStandalone() end
        Fluent:Notify({ Title = "Auto Nears", Content = "Disabled", Duration = 3 })
    end
end)

local spawnNames = getSpawnNames()
selectedMonster  = spawnNames[1]

local monsterDropdown = Tabs.Main:AddDropdown("MonsterSelect", {
    Title   = "Select Monster",
    Values  = spawnNames,
    Multi   = false,
    Default = 1,
})
monsterDropdown:OnChanged(function(value)
    selectedMonster      = value
    currentEnemy         = nil
    trackedRoot          = nil
    cachedSpawnPositions = {}
    spawnCacheBuilt      = false
    enemyCacheBuilt      = false
end)

Tabs.Main:AddButton({
    Title    = "Refresh Monster List",
    Callback = function()
        local newNames = getSpawnNames()
        monsterDropdown:SetValues(newNames)
        selectedMonster      = newNames[1]
        cachedSpawnPositions = {}
        spawnCacheBuilt      = false
        enemyCacheBuilt      = false
        Fluent:Notify({ Title = "Refreshed", Content = #newNames .. " monsters found", Duration = 3 })
    end
})

local ToggleFarm = Tabs.Main:AddToggle("AutoFarm", { Title = "Auto Farm Select", Default = false })
ToggleFarm:OnChanged(function()
    autoFarmEnabled = Options.AutoFarm.Value
    if autoFarmEnabled then
        currentEnemy         = nil
        trackedRoot          = nil
        cachedSpawnPositions = {}
        spawnCacheBuilt      = false
        enemyCacheBuilt      = false
        enableNoclip()
        startFarm()
        Fluent:Notify({ Title = "Auto Farm Select", Content = "Farming: " .. (selectedMonster or "?"), Duration = 3 })
    else
        stopM1Aura()
        disableNoclip()
        if m1AuraEnabled then startM1AuraStandalone() end
        Fluent:Notify({ Title = "Auto Farm Select", Content = "Disabled", Duration = 3 })
    end
end)

local ToggleBring = Tabs.Main:AddToggle("BringMob", { Title = "Bring Mob", Default = true })
ToggleBring:OnChanged(function()
    bringMobEnabled = Options.BringMob.Value
    Fluent:Notify({ Title = "Bring Mob", Content = bringMobEnabled and "ON" or "OFF", Duration = 3 })
end)

local ToggleM1 = Tabs.Main:AddToggle("M1Aura", { Title = "M1 Aura", Default = false })
ToggleM1:OnChanged(function()
    m1AuraEnabled = Options.M1Aura.Value
    if m1AuraEnabled then
        if not autoNearEnabled and not autoFarmEnabled then startM1AuraStandalone() end
        Fluent:Notify({ Title = "M1 Aura", Content = "Enabled", Duration = 3 })
    else
        if not autoNearEnabled and not autoFarmEnabled then stopM1Aura() end
        Fluent:Notify({ Title = "M1 Aura", Content = "Disabled", Duration = 3 })
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character    = newChar
    HRP          = newChar:WaitForChild("HumanoidRootPart")
    Humanoid     = newChar:WaitForChild("Humanoid")
    currentEnemy = nil
    trackedRoot  = nil
    task.wait(1)
    if autoNearEnabled then
        enableNoclip()
        startFollow()
    end
    if autoFarmEnabled then
        cachedSpawnPositions = {}
        spawnCacheBuilt      = false
        enemyCacheBuilt      = false
        enableNoclip()
        startFarm()
    end
    if m1AuraEnabled and not autoNearEnabled and not autoFarmEnabled then
        startM1AuraStandalone()
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AutoMonsterHub")
SaveManager:SetFolder("AutoMonsterHub/config")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({ Title = "KKKK Hub", Content = "Loaded.", Duration = 6 })
SaveManager:LoadAutoloadConfig()
