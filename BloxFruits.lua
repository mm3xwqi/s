local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "KKKK Hub",
    Footer = "by Z",
    ShowCustomCursor = true,
    NotifySide = "Right",
})

local Tabs = {
    Main            = Window:AddTab("Main", "sword"),
    FarmSettings    = Window:AddTab("Farm Settings", "settings-2"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

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

-- ==================== CONFIG ====================
local SESSION_ID   = "32501259"
local MAX_DISTANCE = 100
local MIN_DISTANCE = 1
local SPEED        = 250
local REACH        = 6
local ATTACK_RATE  = 0.05
local WEAPON_TYPES = {"Melee", "Sword", "Gun", "Fruit"}

local OFFSET_X     = 0
local OFFSET_Y     = 25
local OFFSET_Z     = 0
local BRING_RADIUS = 300
local BRING_COUNT  = 1

-- ==================== STATE ====================
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
local lockConn           = nil  -- ใหม่: ใช้ล็อคตำแหน่ง

local cachedSpawnPositions = {}
local spawnCacheBuilt      = false
local enemyCacheBuilt      = false

-- ==================== NOCLIP ====================
local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
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

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

-- ==================== POSITION LOCK ====================
-- ล็อคตำแหน่งให้นิ่งสนิท ไม่ให้สกิล/dash ดันออก
local function startPositionLock(targetCFrame)
    if lockConn then lockConn:Disconnect() end
    lockConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            HRP.CFrame = targetCFrame
            HRP.AssemblyLinearVelocity  = Vector3.zero
            HRP.AssemblyAngularVelocity = Vector3.zero
        end)
    end)
end

local function stopPositionLock()
    if lockConn then lockConn:Disconnect() lockConn = nil end
end

-- ==================== CHARACTER ====================
local function updateCharacter()
    Character = LocalPlayer.Character
    if not Character then return false end
    HRP      = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChild("Humanoid")
    return HRP ~= nil and Humanoid ~= nil
end

-- ==================== UTILITY ====================
local function cleanMonsterName(name)
    return (name:gsub("%s*%[.-%]", "")):match("^%s*(.-)%s*$")
end

local function getHitPart(enemy)
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

-- ตำแหน่งลอยเหนือมอน
local function getHoverPosition(rootPart)
    local rcf    = rootPart.CFrame
    local offset = Vector3.new(OFFSET_X, OFFSET_Y, OFFSET_Z)
    return CFrame.new(rcf.Position + offset) * (rcf - rcf.Position)
end

local function snapHeightToEnemy(rootPart)
    if not rootPart or not HRP then return end
    pcall(function()
        HRP.AssemblyLinearVelocity = Vector3.zero
        local targetY = rootPart.Position.Y + OFFSET_Y
        HRP.CFrame = CFrame.new(HRP.Position.X, targetY, HRP.Position.Z) * HRP.CFrame.Rotation
    end)
end

-- ==================== SPAWN CACHE ====================
local function buildSpawnCache(monsterName)
    if spawnCacheBuilt then return end
    cachedSpawnPositions = {}
    local spawns = workspace:FindFirstChild("_WorldOrigin")
    if spawns then spawns = spawns:FindFirstChild("EnemySpawns") end
    if spawns then
        for _, part in ipairs(spawns:GetChildren()) do
            if cleanMonsterName(part.Name) == monsterName then
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

local function buildEnemyCache(monsterName)
    if enemyCacheBuilt then return end
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return end
    for _, model in ipairs(folder:GetChildren()) do
        if cleanMonsterName(model.Name) == monsterName then
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

local function ensureSpawnCache(monsterName)
    buildSpawnCache(monsterName)
    buildEnemyCache(monsterName)
end

-- ==================== ENEMY FINDER ====================
local function getAllEnemies()
    local list   = {}
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

local function getClosestEnemy()
    local best, bestDist = nil, math.huge
    for _, model in ipairs(getAllEnemies()) do
        local root = model:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (HRP.Position - root.Position).Magnitude
            if dist < bestDist then best, bestDist = model, dist end
        end
    end
    return best
end

local function findEnemyByName(monsterName)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    local best, bestDist = nil, math.huge
    for _, model in ipairs(folder:GetChildren()) do
        if cleanMonsterName(model.Name) == monsterName then
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
                local part = getHitPart(enemy)
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

local function getMonsterNames()
    local seen = {}
    local list = {}
    local spawns = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then
        for _, part in ipairs(spawns:GetChildren()) do
            local clean = cleanMonsterName(part.Name)
            if clean ~= "" and not seen[clean] then
                seen[clean] = true
                table.insert(list, clean)
            end
        end
    end
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            local clean = cleanMonsterName(model.Name)
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

-- ==================== WEAPON ====================
local function findWeapon(keyword)
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

local function equipWeapon(keyword)
    if not keyword or not Character then return end
    local tool, alreadyEquipped = findWeapon(keyword)
    if alreadyEquipped then return end
    if not tool then return end
    if Humanoid then Humanoid:EquipTool(tool) end
end

-- ==================== BRING MOB ====================
local function pullNearbyMobs(targetEnemy)
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
    for i = 1, math.min(BRING_COUNT, #candidates) do
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
        bringIndex = bringIndex + 1
    end
end

local function pullSameTypeMobs(targetEnemy, monsterName)
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
        if model ~= targetEnemy and cleanMonsterName(model.Name) == monsterName then
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
    for i = 1, math.min(BRING_COUNT, #candidates) do
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
        bringIndex = bringIndex + 1
    end
end

-- ==================== M1 AURA ====================
local function stopAttackLoop()
    if m1AuraThread then task.cancel(m1AuraThread) m1AuraThread = nil end
end

local function startAttackLoop(shouldRun)
    stopAttackLoop()
    m1AuraThread = task.spawn(function()
        while shouldRun() do
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

local function startAuraWithFarm()       startAttackLoop(function() return autoNearEnabled or autoFarmEnabled end) end
local function startAuraStandalone()     startAttackLoop(function() return m1AuraEnabled end) end

-- ==================== MOVEMENT ====================
local function moveToTarget(hrp, targetCF, dt)
    local targetPos  = targetCF.Position
    local currentPos = hrp.Position
    local fromPos    = Vector3.new(currentPos.X, targetPos.Y, currentPos.Z)
    local delta      = targetPos - fromPos
    local dist       = delta.Magnitude
    local step       = SPEED * dt
    local newPos     = (dist <= step or dist < 0.01) and targetPos or fromPos + (delta / dist) * step

    local lookDir = targetPos - newPos
    local finalCF
    if lookDir.Magnitude > 0.01 then
        lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
        finalCF = CFrame.new(newPos, newPos + lookDir)
    else
        finalCF = CFrame.new(newPos) * targetCF.Rotation
    end

    -- ล็อคแรงทุก frame ระหว่างเดินทาง ไม่ให้สกิลดัน
    pcall(function()
        hrp.CFrame = finalCF
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- ==================== AUTO NEAR ====================
local function startAutoNear()
    if followConn then followConn:Disconnect() end
    local prevEnemy = nil

    followConn = RunService.Heartbeat:Connect(function(dt)
        if not autoNearEnabled then
            followConn:Disconnect()
            followConn = nil
            stopAttackLoop()
            stopPositionLock()
            return
        end
        if not updateCharacter() then return end
        equipWeapon(selectedWeaponType)

        local enemyHum  = currentEnemy and currentEnemy:FindFirstChildOfClass("Humanoid")
        local enemyRoot = currentEnemy and currentEnemy:FindFirstChild("HumanoidRootPart")

        if not currentEnemy or not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
            stopAttackLoop()
            stopPositionLock()
            trackedRoot  = nil
            currentEnemy = getClosestEnemy()
            prevEnemy    = nil
            if not currentEnemy then return end
            trackedRoot = getEnemyRoot(currentEnemy)
            snapHeightToEnemy(trackedRoot)
        end

        if not trackedRoot or not trackedRoot.Parent then
            trackedRoot = getEnemyRoot(currentEnemy)
            if not trackedRoot then return end
            snapHeightToEnemy(trackedRoot)
        end

        if bringMobEnabled then pullNearbyMobs(currentEnemy) end

        local targetCF = getHoverPosition(trackedRoot)
        local dist     = (targetCF.Position - HRP.Position).Magnitude

        if dist > REACH then
            -- กำลังเดินทาง: หยุดล็อค แล้วเดินตรงๆ
            stopPositionLock()
            stopAttackLoop()
            prevEnemy = nil
            moveToTarget(HRP, targetCF, dt)
        else
            -- ถึงแล้ว: ล็อคตำแหน่งไว้เลย ไม่ให้ขยับ
            startPositionLock(targetCF)
            if currentEnemy ~= prevEnemy then
                prevEnemy = currentEnemy
                startAuraWithFarm()
            end
        end
    end)
end

-- ==================== AUTO FARM ====================
local function startAutoFarm()
    if farmConn then farmConn:Disconnect() end
    local prevEnemy    = nil
    local spawnIdx     = 1
    local isSnapping   = false
    local snapDone     = false
    local lastSpawnPos = nil

    farmConn = RunService.Heartbeat:Connect(function(dt)
        if not autoFarmEnabled then
            farmConn:Disconnect()
            farmConn = nil
            stopAttackLoop()
            stopPositionLock()
            return
        end
        if not updateCharacter() then return end
        if not selectedMonster then return end
        equipWeapon(selectedWeaponType)

        ensureSpawnCache(selectedMonster)

        local target = findEnemyByName(selectedMonster)

        if target then
            isSnapping   = false
            snapDone     = false
            lastSpawnPos = nil
            spawnIdx     = 1

            local enemyHum  = target:FindFirstChildOfClass("Humanoid")
            local enemyRoot = target:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
                trackedRoot = nil return
            end

            if currentEnemy ~= target then
                currentEnemy = target
                trackedRoot  = nil
            end

            if trackedRoot == nil or trackedRoot.Parent == nil or not target:IsAncestorOf(trackedRoot) then
                trackedRoot = getEnemyRoot(target)
                snapHeightToEnemy(trackedRoot)
            end
            if not trackedRoot then return end

            if bringMobEnabled then pullSameTypeMobs(target, selectedMonster) end

            local targetCF = getHoverPosition(trackedRoot)
            local dist     = (targetCF.Position - HRP.Position).Magnitude

            if dist > REACH then
                stopPositionLock()
                stopAttackLoop()
                prevEnemy = nil
                moveToTarget(HRP, targetCF, dt)
            else
                -- ถึงแล้ว: ล็อคตำแหน่งไว้เลย
                startPositionLock(targetCF)
                if target ~= prevEnemy then
                    prevEnemy = target
                    startAuraWithFarm()
                end
            end
        else
            stopAttackLoop()
            stopPositionLock()
            prevEnemy    = nil
            currentEnemy = nil
            trackedRoot  = nil

            if #cachedSpawnPositions == 0 then return end
            if spawnIdx > #cachedSpawnPositions then spawnIdx = 1 end

            local spawnPos = cachedSpawnPositions[spawnIdx] + Vector3.new(OFFSET_X, OFFSET_Y, OFFSET_Z)

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
                    HRP.AssemblyLinearVelocity  = Vector3.zero
                    HRP.AssemblyAngularVelocity = Vector3.zero
                    HRP.CFrame = CFrame.new(newPos)
                end)
            else
                snapDone = false
                spawnIdx = spawnIdx % #cachedSpawnPositions + 1
            end
        end
    end)
end

-- ==================== UI: MAIN TAB ====================
local LeftGroup  = Tabs.Main:AddLeftGroupbox("Combat")
local RightGroup = Tabs.Main:AddRightGroupbox("Farm")

LeftGroup:AddDropdown("WeaponSelect", {
    Values  = WEAPON_TYPES,
    Default = 1,
    Multi   = false,
    Text    = "Equip Item",
})
Options.WeaponSelect:OnChanged(function()
    selectedWeaponType = Options.WeaponSelect.Value
    if autoNearEnabled or autoFarmEnabled then equipWeapon(Options.WeaponSelect.Value) end
end)
selectedWeaponType = WEAPON_TYPES[1]

LeftGroup:AddToggle("AutoNear", {
    Text    = "Auto Farm Nears",
    Default = false,
})
Toggles.AutoNear:OnChanged(function()
    autoNearEnabled = Toggles.AutoNear.Value
    if autoNearEnabled then
        currentEnemy = nil
        trackedRoot  = nil
        startNoclip()
        startAutoNear()
        Library:Notify({ Title = "Auto Nears", Description = "Enabled", Time = 3 })
    else
        stopAttackLoop()
        stopPositionLock()
        stopNoclip()
        if m1AuraEnabled then startAuraStandalone() end
        Library:Notify({ Title = "Auto Nears", Description = "Disabled", Time = 3 })
    end
end)

LeftGroup:AddToggle("M1Aura", {
    Text    = "M1 Aura",
    Default = false,
})
Toggles.M1Aura:OnChanged(function()
    m1AuraEnabled = Toggles.M1Aura.Value
    if m1AuraEnabled then
        if not autoNearEnabled and not autoFarmEnabled then startAuraStandalone() end
        Library:Notify({ Title = "M1 Aura", Description = "Enabled", Time = 3 })
    else
        if not autoNearEnabled and not autoFarmEnabled then stopAttackLoop() end
        Library:Notify({ Title = "M1 Aura", Description = "Disabled", Time = 3 })
    end
end)

local spawnNames = getMonsterNames()
selectedMonster  = spawnNames[1]

RightGroup:AddDropdown("MonsterSelect", {
    Values     = spawnNames,
    Default    = 1,
    Multi      = false,
    Text       = "Select Monster",
    Searchable = true,
})
Options.MonsterSelect:OnChanged(function()
    selectedMonster      = Options.MonsterSelect.Value
    currentEnemy         = nil
    trackedRoot          = nil
    cachedSpawnPositions = {}
    spawnCacheBuilt      = false
    enemyCacheBuilt      = false
end)

RightGroup:AddButton({
    Text = "Refresh Monster List",
    Func = function()
        local newNames = getMonsterNames()
        Options.MonsterSelect:SetValues(newNames)
        selectedMonster      = newNames[1]
        cachedSpawnPositions = {}
        spawnCacheBuilt      = false
        enemyCacheBuilt      = false
        Library:Notify({ Title = "Refreshed", Description = #newNames .. " monsters found", Time = 3 })
    end,
})

RightGroup:AddToggle("AutoFarm", {
    Text    = "Auto Farm Select",
    Default = false,
})
Toggles.AutoFarm:OnChanged(function()
    autoFarmEnabled = Toggles.AutoFarm.Value
    if autoFarmEnabled then
        currentEnemy         = nil
        trackedRoot          = nil
        cachedSpawnPositions = {}
        spawnCacheBuilt      = false
        enemyCacheBuilt      = false
        startNoclip()
        startAutoFarm()
        Library:Notify({ Title = "Auto Farm", Description = "Farming: " .. (selectedMonster or "?"), Time = 3 })
    else
        stopAttackLoop()
        stopPositionLock()
        stopNoclip()
        if m1AuraEnabled then startAuraStandalone() end
        Library:Notify({ Title = "Auto Farm", Description = "Disabled", Time = 3 })
    end
end)

RightGroup:AddToggle("BringMob", {
    Text    = "Bring Mob",
    Default = true,
})
Toggles.BringMob:OnChanged(function()
    bringMobEnabled = Toggles.BringMob.Value
    Library:Notify({ Title = "Bring Mob", Description = bringMobEnabled and "ON" or "OFF", Time = 3 })
end)

-- ==================== UI: FARM SETTINGS TAB ====================
local FarmLeft  = Tabs.FarmSettings:AddLeftGroupbox("Position Offset")
local FarmRight = Tabs.FarmSettings:AddRightGroupbox("Bring Mob Settings")

FarmLeft:AddSlider("OffsetX", {
    Text = "Offset X", Min = -50, Max = 50, Default = 0, Rounding = 0,
})
Options.OffsetX:OnChanged(function()
    OFFSET_X = tonumber(Options.OffsetX.Value) or 0
end)

FarmLeft:AddSlider("OffsetY", {
    Text = "Offset Y", Min = 0, Max = 100, Default = 25, Rounding = 0,
})
Options.OffsetY:OnChanged(function()
    OFFSET_Y = tonumber(Options.OffsetY.Value) or 25
end)

FarmLeft:AddSlider("OffsetZ", {
    Text = "Offset Z", Min = -50, Max = 50, Default = 0, Rounding = 0,
})
Options.OffsetZ:OnChanged(function()
    OFFSET_Z = tonumber(Options.OffsetZ.Value) or 0
end)

FarmRight:AddSlider("BringRadius", {
    Text = "BringMob Distance", Min = 50, Max = 2000, Default = 300, Rounding = 10,
})
Options.BringRadius:OnChanged(function()
    BRING_RADIUS = tonumber(Options.BringRadius.Value) or 300
end)

FarmRight:AddSlider("BringCount", {
    Text = "Bring Mob count", Min = 1, Max = 6, Default = 1, Rounding = 0,
})
Options.BringCount:OnChanged(function()
    BRING_COUNT = tonumber(Options.BringCount.Value) or 1
end)

FarmRight:AddButton({
    Text = "Reset Value Default",
    Func = function()
        OFFSET_X     = 0
        OFFSET_Y     = 25
        OFFSET_Z     = 0
        BRING_RADIUS = 300
        BRING_COUNT  = 1
        Options.OffsetX:SetValue(0)
        Options.OffsetY:SetValue(25)
        Options.OffsetZ:SetValue(0)
        Options.BringRadius:SetValue(300)
        Options.BringCount:SetValue(1)
        Library:Notify({ Title = "Reset", Description = "Reset", Time = 3 })
    end,
})

-- ==================== UI: UI SETTINGS TAB ====================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightAlt", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        autoNearEnabled = false
        autoFarmEnabled = false
        m1AuraEnabled   = false
        stopAttackLoop()
        stopPositionLock()
        stopNoclip()
        if followConn then followConn:Disconnect() followConn = nil end
        if farmConn   then farmConn:Disconnect()   farmConn   = nil end
        Library:Unload()
    end,
})

Library.ToggleKeybind = Options.MenuKeybind

-- ==================== CHARACTER RESPAWN ====================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character    = newChar
    HRP          = newChar:WaitForChild("HumanoidRootPart")
    Humanoid     = newChar:WaitForChild("Humanoid")
    currentEnemy = nil
    trackedRoot  = nil
    stopPositionLock()
    task.wait(1)
    if autoNearEnabled then
        startNoclip()
        startAutoNear()
    end
    if autoFarmEnabled then
        cachedSpawnPositions = {}
        spawnCacheBuilt      = false
        enemyCacheBuilt      = false
        startNoclip()
        startAutoFarm()
    end
    if m1AuraEnabled and not autoNearEnabled and not autoFarmEnabled then
        startAuraStandalone()
    end
end)

-- ==================== SAVE / THEME ====================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("KKKKHub")
SaveManager:SetFolder("KKKKHub/config")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:Notify({ Title = "KKKK Hub", Description = "Loaded.", Time = 6 })
SaveManager:LoadAutoloadConfig()
