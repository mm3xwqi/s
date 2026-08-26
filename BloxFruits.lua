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
    Teleport        = Window:AddTab("Teleport", "map-pin"),
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
local BRING_MODES  = {"Instant (BestPrivate server)", "Smooth (Best Public Server)"}

-- ==================== TELEPORT DATA ====================
local TELEPORT_LOCATIONS = {
    [2753915549] = {
        WorldName = "Old World (Sea 1)",
        Locations = {
            { Name = "Pirate Starter",      Pos = Vector3.new(885, 17, 1429) },
            { Name = "Middle Island",       Pos = Vector3.new(-690, 15, 1584) },
            { Name = "Marine Starter",      Pos = Vector3.new(-2600, 7, 2068) },
            { Name = "Jungle island",       Pos = Vector3.new(-1445, 62, -34) },
            { Name = "Pirate island",       Pos = Vector3.new(-1218, 5, 3922) },
            { Name = "Desert island",       Pos = Vector3.new(942, 21, 4372) },
            { Name = "Snow island",         Pos = Vector3.new(1345, 106, -1319) },
            { Name = "Sky",                 Pos = Vector3.new(-4817, 718, -2628) },
            { Name = "sky 1",               Pos = Vector3.new(-4714, 853, -1932) },
            { Name = "sky 2",               Pos = Vector3.new(-7921, 5566, -379) },
            { Name = "Usop",                Pos = Vector3.new(-7990, 5756, -1927) },
            { Name = "Colosseum island",    Pos = Vector3.new(-1453, 7, -2848) },
            { Name = "Fishmen island",      Pos = Vector3.new(3906, 5, -1893) },
            { Name = "Prison island",       Pos = Vector3.new(5010, 89, 738) },
            { Name = "Fountain island",     Pos = Vector3.new(5273, 81, 3987) },
            { Name = "Magma island",        Pos = Vector3.new(-5241, 9, 8413) },
            { Name = "MarineBase island",   Pos = Vector3.new(-4816, 21, 4360) },
            { Name = "Mob Leader",          Pos = Vector3.new(-2844, 7, 5309) },
        }
    },
    [4442272183] = {
        WorldName = "Second World (Sea 2)",
        Locations = {
            { Name = "Dock 1",              Pos = Vector3.new(-10, 39, 2703) },
            { Name = "Mansion",             Pos = Vector3.new(-393, 360, 546) },
            { Name = "Cafe",                Pos = Vector3.new(-373, 73, 296) },
            { Name = "Race Evo",            Pos = Vector3.new(-2007, 126, -74) },
            { Name = "Dock 2",              Pos = Vector3.new(-1917, 6, -2546) },
            { Name = "Green Zone",          Pos = Vector3.new(-2456, 87, -3188) },
            { Name = "TTk",                 Pos = Vector3.new(-2573, 1626, -3742) },
            { Name = "Ice island",          Pos = Vector3.new(-5897, 29, -5055) },
            { Name = "Hot island",          Pos = Vector3.new(-5012, 176, -5320) },
            { Name = "Forgotten island",    Pos = Vector3.new(-3043, 240, -10140) },
            { Name = "IceCastle island",    Pos = Vector3.new(6000, 294, -6611) },
            { Name = "SnowMountain island", Pos = Vector3.new(800, 412, -5250) },
            { Name = "Raid",                Pos = Vector3.new(-6483, 305, -4736) },
            { Name = "ZombieVampire island",Pos = Vector3.new(-5648, 185, -888) },
            { Name = "Ship island",         Pos = Vector3.new(-6525, 83, -156) },
        }
    },
    [7449423635] = {
        WorldName = "Third World (Sea 3)",
        Locations = {
            { Name = "port town",           Pos = Vector3.new(-340, 21, 5538) },
            { Name = "Castle island",       Pos = Vector3.new(-5135, 314, -2957) },
            { Name = "Hydra town",          Pos = Vector3.new(5295, 1005, 380) },
            { Name = "Hydra Arena",         Pos = Vector3.new(5016, 59, -1556) },
            { Name = "Mansion turtle",      Pos = Vector3.new(-12551, 337, -7481) },
            { Name = "beautiful pirate",    Pos = Vector3.new(5372, 22, -306) },
            { Name = "Tiki island",         Pos = Vector3.new(-16398, 528, 403) },
            { Name = "Haunted Castle",      Pos = Vector3.new(-9512, 142, 5540) },
            { Name = "Katakuri island",     Pos = Vector3.new(-2094, 70, -12125) },
            { Name = "Bigmom island",       Pos = Vector3.new(-890, 66, -10899) },
            { Name = "Chocolate island",    Pos = Vector3.new(-6, 21, -12049) },
            { Name = "North Pole",          Pos = Vector3.new(-1096, 64, -14515) },
            { Name = "Great tree",          Pos = Vector3.new(2391, 74, -7006) },
            { Name = "Upper Great tree",    Pos = Vector3.new(3038, 2281, -7325) },
        }
    }
}

local function getIslandNamesAndMap(placeId)
    local data = TELEPORT_LOCATIONS[placeId] or TELEPORT_LOCATIONS[2753915549]
    local names = {}
    local map = {}
    for _, loc in ipairs(data.Locations) do
        table.insert(names, loc.Name)
        map[loc.Name] = loc.Pos
    end
    return names, map, data.WorldName
end

-- ==================== STATE ====================
local autoNearEnabled      = false
local autoFarmEnabled      = false
local bringMobEnabled      = true
local bringMobMode         = "Instant"
local m1AuraEnabled        = false
local teleportTweenEnabled = false

local selectedWeaponType   = "Melee"
local selectedMonsterList  = {} -- ลิสต์มอนสเตอร์เรียงตามลำดับ Priority
local currentEnemy         = nil
local trackedRoot          = nil
local followConn           = nil
local farmConn             = nil
local teleportConn         = nil
local m1AuraThread         = nil
local noclipConn           = nil
local lockConn             = nil
local currentFlyCF         = nil

local selectedIslandName   = nil
local selectedIslandPos    = nil

local cachedSpawnsByName   = {}
local smoothData           = {}

-- Master Database สำหรับจดจำมอนสเตอร์ถาวร
local discoveredMonsters   = {}
local masterMonsterList    = {}

-- ==================== NOCLIP & ANTI-FORCE ====================
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
        if HRP then
            pcall(function()
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
                for _, child in ipairs(HRP:GetChildren()) do
                    if child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child:IsA("BodyPosition")
                       or child:IsA("LinearVelocity") or child:IsA("VectorForce")
                       or child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
                        child:Destroy()
                    end
                end
            end)
        end
    end)
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

-- ==================== POSITION & DIRECTION LOCK ====================
local function startPositionLock()
    if lockConn then lockConn:Disconnect() end
    if Humanoid then
        pcall(function() Humanoid.AutoRotate = false end)
    end
    lockConn = RunService.RenderStepped:Connect(function()
        if not (autoNearEnabled or autoFarmEnabled or teleportTweenEnabled) then
            if lockConn then lockConn:Disconnect() lockConn = nil end
            return
        end
        if currentFlyCF and HRP then
            pcall(function()
                HRP.CFrame = currentFlyCF
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end

local function stopPositionLock()
    if lockConn then lockConn:Disconnect() lockConn = nil end
    currentFlyCF = nil
    if Humanoid then
        pcall(function() Humanoid.AutoRotate = true end)
    end
end

-- ==================== CHARACTER ====================
local function updateCharacter()
    Character = LocalPlayer.Character
    if not Character then return false end
    HRP      = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid and (autoNearEnabled or autoFarmEnabled or teleportTweenEnabled) then
        Humanoid.AutoRotate = false
    end
    return HRP ~= nil and Humanoid ~= nil
end

-- ==================== UTILITY ====================
local function cleanMonsterName(name)
    if not name then return "" end
    return (name:gsub("%s*%[.-%]", "")):match("^%s*(.-)%s*$") or ""
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

local function snapHeightToEnemy(rootPart)
    if not rootPart or not HRP then return end
    pcall(function()
        HRP.AssemblyLinearVelocity = Vector3.zero
        local targetY = rootPart.Position.Y + OFFSET_Y
        local baseCF = currentFlyCF or HRP.CFrame
        currentFlyCF = CFrame.new(baseCF.Position.X, targetY, baseCF.Position.Z) * baseCF.Rotation
        HRP.CFrame = currentFlyCF
    end)
end

-- ==================== SPAWN CACHE ====================
local function getSpawnPositionsForMonster(monsterName)
    if not monsterName or monsterName == "" then return {} end
    if cachedSpawnsByName[monsterName] and #cachedSpawnsByName[monsterName] > 0 then
        return cachedSpawnsByName[monsterName]
    end

    local list = {}
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
                    for _, cp in ipairs(list) do
                        if (cp - pos).Magnitude < 5 then dup = true break end
                    end
                    if not dup then table.insert(list, pos) end
                end
            end
        end
    end

    local folder = workspace:FindFirstChild("Enemies")
    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if cleanMonsterName(model.Name) == monsterName then
                local root = model:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos = root.Position
                    local dup = false
                    for _, cp in ipairs(list) do
                        if (cp - pos).Magnitude < 10 then dup = true break end
                    end
                    if not dup then table.insert(list, pos) end
                end
            end
        end
    end

    if #list > 0 then
        cachedSpawnsByName[monsterName] = list
    end
    return list
end

local function getEnemySpawnPosition(targetEnemy)
    if not targetEnemy or not targetEnemy.Parent then return nil end
    local root = targetEnemy:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local currentPos = root.Position
    local monsterName = cleanMonsterName(targetEnemy.Name)
    local spawns = getSpawnPositionsForMonster(monsterName)

    if #spawns == 0 then
        return currentPos
    end

    local bestPos, bestDist = currentPos, math.huge
    for _, spawnPos in ipairs(spawns) do
        local dist = (spawnPos - currentPos).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestPos  = spawnPos
        end
    end

    return bestPos
end

-- ==================== ENEMY FINDER & PERSISTENT CACHE ====================
local function addDiscoveredMonster(rawName)
    local clean = cleanMonsterName(rawName)
    if clean and clean ~= "" and clean ~= "(ไม่พบมอน)" and not discoveredMonsters[clean] then
        discoveredMonsters[clean] = true
        table.insert(masterMonsterList, clean)
        table.sort(masterMonsterList, function(a, b) return a:lower() < b:lower() end)
        return true
    end
    return false
end

local function scanAllMonsters()
    local newlyFound = false

    local spawns = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then
        for _, part in ipairs(spawns:GetChildren()) do
            if addDiscoveredMonster(part.Name) then
                newlyFound = true
            end
        end
    end

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            if addDiscoveredMonster(model.Name) then
                newlyFound = true
            end
        end
    end

    return newlyFound
end

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

local function findPriorityEnemy(monsterList)
    local folder = workspace:FindFirstChild("Enemies")
    if not folder or #monsterList == 0 then return nil, nil end

    for _, mobName in ipairs(monsterList) do
        local enemy = findEnemyByName(mobName)
        if enemy then
            return enemy, mobName
        end
    end
    return nil, nil
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

local function updateSelectedMonstersList()
    local currentVal = Options.MonsterSelect and Options.MonsterSelect.Value
    local updatedList = {}

    if typeof(currentVal) == "table" then
        -- 1. คงลำดับเดิมที่ผู้ใช้เลือกไว้ก่อนหน้า
        for _, name in ipairs(selectedMonsterList) do
            if currentVal[name] == true and not table.find(updatedList, name) then
                table.insert(updatedList, name)
            end
        end
        -- 2. เพิ่มตัวใหม่ที่เพิ่งถูกเลือก
        for name, isSelected in pairs(currentVal) do
            if isSelected == true and not table.find(updatedList, name) then
                table.insert(updatedList, name)
            end
        end
    elseif typeof(currentVal) == "string" and currentVal ~= "" and currentVal ~= "(ไม่พบมอน)" then
        table.insert(updatedList, currentVal)
    end

    selectedMonsterList = updatedList
    return selectedMonsterList
end

local function updateMonsterDropdown(isManual)
    local hasNew = scanAllMonsters()
    if (hasNew or isManual) and Options.MonsterSelect then
        local currentVal = Options.MonsterSelect.Value or {}
        local currentSelections = {}

        if typeof(currentVal) == "table" then
            for k, v in pairs(currentVal) do
                if v == true then currentSelections[k] = true end
            end
        elseif typeof(currentVal) == "string" and currentVal ~= "" and currentVal ~= "(ไม่พบมอน)" then
            currentSelections[currentVal] = true
        end

        local displayList = #masterMonsterList > 0 and masterMonsterList or {"(ไม่พบมอน)"}
        Options.MonsterSelect:SetValues(displayList)

        -- คืนค่าที่เลือกไว้เดิมแบบ 100% ไม่ให้ติ๊กหลุด
        if next(currentSelections) then
            Options.MonsterSelect:SetValue(currentSelections)
        end
        updateSelectedMonstersList()

        if isManual then
            Library:Notify({ Title = "Refreshed", Description = #masterMonsterList .. " monsters found", Time = 3 })
        end
    end
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

-- ==================== ULTRA SMOOTH CLEANUP ====================
local function smoothRelease(enemy)
    local d = smoothData[enemy]
    if d then
        for _, k in ipairs({"bp", "bv", "bg"}) do
            if d[k] and d[k].Parent then pcall(function() d[k]:Destroy() end) end
        end
        smoothData[enemy] = nil
    end
    if enemy and enemy.Parent then
        local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
        if hrp then
            for _, c in ipairs(hrp:GetChildren()) do
                if c.Name:find("BringMob") then pcall(function() c:Destroy() end) end
            end
            pcall(function()
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.PlatformStand = false
                hum.WalkSpeed     = 16
                hum.JumpPower     = 50
            end)
        end
        for _, p in ipairs(enemy:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
        end
    end
end

local function smoothCleanAll()
    for enemy in pairs(smoothData) do
        pcall(smoothRelease, enemy)
    end
    smoothData = {}
end

-- ==================== MOB POSITION LOCK & BRING ====================
local function lockAndBringMobs(targetEnemy, lockPos, isSameTypeOnly, monsterName)
    if not targetEnemy or not targetEnemy.Parent or not lockPos then return end
    local targetRoot = targetEnemy:FindFirstChild("HumanoidRootPart")
    local targetHum  = targetEnemy:FindFirstChildOfClass("Humanoid")
    if not targetRoot or not targetHum or targetHum.Health <= 0 then return end

    pcall(function()
        for _, part in ipairs(targetEnemy:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        targetRoot.CFrame = CFrame.new(lockPos)
        targetRoot.AssemblyLinearVelocity  = Vector3.zero
        targetRoot.AssemblyAngularVelocity = Vector3.zero
    end)

    if not bringMobEnabled then
        if next(smoothData) then smoothCleanAll() end
        return
    end

    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return end

    local candidates = {}
    for _, model in ipairs(folder:GetChildren()) do
        if model ~= targetEnemy and model.Parent then
            local match = true
            if isSameTypeOnly and monsterName then
                match = (cleanMonsterName(model.Name) == monsterName)
            end
            if match then
                local hum  = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - lockPos).Magnitude
                    if dist <= BRING_RADIUS then
                        table.insert(candidates, {model = model, root = root, hum = hum, dist = dist})
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    local countToBring = math.min(BRING_COUNT, #candidates)

    if bringMobMode == "Instant" then
        if next(smoothData) then smoothCleanAll() end
        for i = 1, countToBring do
            local entry = candidates[i]
            pcall(function()
                for _, part in ipairs(entry.model:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                entry.root.CFrame = CFrame.new(lockPos)
                entry.root.AssemblyLinearVelocity  = Vector3.zero
                entry.root.AssemblyAngularVelocity = Vector3.zero
            end)
        end

    elseif bringMobMode == "Ultra Smooth" then
        for e in pairs(smoothData) do
            local hum = e:FindFirstChildOfClass("Humanoid")
            if not e or not e.Parent or not hum or hum.Health <= 0 then
                pcall(smoothRelease, e)
            end
        end

        local activeSet = {}
        for i = 1, countToBring do
            local entry = candidates[i]
            local model = entry.model
            local root  = entry.root
            local hum   = entry.hum
            activeSet[model] = true

            pcall(function()
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
                hum.PlatformStand = true
                hum.WalkSpeed     = 0
                hum.JumpPower     = 0
            end)

            if not smoothData[model] then
                local bp = Instance.new("BodyPosition", root)
                bp.Name = "BringMobBP"
                bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bp.P = 150000
                bp.D = 2000
                bp.Position = lockPos

                smoothData[model] = { bp = bp, arrived = false }
            end

            local d = smoothData[model]
            if d and d.bp and d.bp.Parent then
                local curDist = (root.Position - lockPos).Magnitude
                if curDist <= 12 then
                    if not d.arrived then
                        pcall(function() d.bp:Destroy() end)
                        root.AssemblyLinearVelocity = Vector3.zero

                        local fbp = Instance.new("BodyPosition", root)
                        fbp.Name = "BringMobBP_Fixed"
                        fbp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                        fbp.P = 500000
                        fbp.D = 10000
                        fbp.Position = lockPos

                        local bg = Instance.new("BodyGyro", root)
                        bg.Name = "BringMobBG"
                        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                        bg.P = 100000
                        bg.D = 2000
                        bg.CFrame = root.CFrame

                        d.bp = fbp
                        d.bg = bg
                        d.arrived = true
                    else
                        pcall(function() d.bp.Position = lockPos end)
                    end
                else
                    pcall(function() d.bp.Position = lockPos end)
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end

        for e in pairs(smoothData) do
            if not activeSet[e] then
                pcall(smoothRelease, e)
            end
        end
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

local function startAuraWithFarm()   startAttackLoop(function() return autoNearEnabled or autoFarmEnabled end) end
local function startAuraStandalone() startAttackLoop(function() return m1AuraEnabled end) end

-- ==================== MOVEMENT ====================
local function moveToTarget(hrp, targetCF, dt)
    if not hrp then return end
    if not currentFlyCF or (currentFlyCF.Position - hrp.Position).Magnitude > 300 then
        currentFlyCF = hrp.CFrame
    end

    local targetPos  = targetCF.Position
    local currentPos = currentFlyCF.Position
    local fromPos    = Vector3.new(currentPos.X, targetPos.Y, currentPos.Z)
    local delta      = targetPos - fromPos
    local dist       = delta.Magnitude
    local step       = SPEED * dt
    local newPos     = (dist <= step or dist < 0.01) and targetPos or fromPos + (delta / dist) * step

    local lookDir = targetPos - newPos
    local finalCF
    if dist > 0.5 and lookDir.Magnitude > 0.01 then
        lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
        finalCF = CFrame.new(newPos, newPos + lookDir)
    else
        finalCF = CFrame.new(newPos) * (targetCF - targetPos)
    end

    currentFlyCF = finalCF
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
    if HRP then currentFlyCF = HRP.CFrame end
    startPositionLock()

    followConn = RunService.Heartbeat:Connect(function(dt)
        if not autoNearEnabled then
            followConn:Disconnect()
            followConn = nil
            stopAttackLoop()
            stopPositionLock()
            smoothCleanAll()
            return
        end
        if not updateCharacter() then return end
        equipWeapon(selectedWeaponType)

        local enemyHum  = currentEnemy and currentEnemy:FindFirstChildOfClass("Humanoid")
        local enemyRoot = currentEnemy and currentEnemy:FindFirstChild("HumanoidRootPart")

        if not currentEnemy or not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
            stopAttackLoop()
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

        local spawnPos = getEnemySpawnPosition(currentEnemy) or trackedRoot.Position
        lockAndBringMobs(currentEnemy, spawnPos, false, nil)

        local targetCF = CFrame.new(spawnPos + Vector3.new(OFFSET_X, OFFSET_Y, OFFSET_Z))
        local dist     = (targetCF.Position - (currentFlyCF and currentFlyCF.Position or HRP.Position)).Magnitude

        if dist > REACH then
            stopAttackLoop()
            prevEnemy = nil
            moveToTarget(HRP, targetCF, dt)
        else
            currentFlyCF = targetCF
            pcall(function()
                HRP.CFrame = targetCF
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
            end)
            if currentEnemy ~= prevEnemy then
                prevEnemy = currentEnemy
                startAuraWithFarm()
            end
        end
    end)
end

-- ==================== AUTO FARM (MULTI PRIORITY) ====================
local function startAutoFarm()
    if farmConn then farmConn:Disconnect() end
    local prevEnemy    = nil
    local spawnIdx     = 1
    local isSnapping   = false
    local snapDone     = false
    local lastSpawnPos = nil
    if HRP then currentFlyCF = HRP.CFrame end
    startPositionLock()

    farmConn = RunService.Heartbeat:Connect(function(dt)
        if not autoFarmEnabled then
            farmConn:Disconnect()
            farmConn = nil
            stopAttackLoop()
            stopPositionLock()
            stopNoclip()
            smoothCleanAll()
            return
        end
        if not updateCharacter() then return end
        
        local activeList = updateSelectedMonstersList()
        if #activeList == 0 then return end
        
        equipWeapon(selectedWeaponType)

        -- ตรวจสอบหาศัตรูตามลำดับความสำคัญ (Priority 1 -> 2 -> 3...)
        local target, targetMonsterName = findPriorityEnemy(activeList)

        if target and targetMonsterName then
            isSnapping   = false
            snapDone     = false
            lastSpawnPos = nil
            spawnIdx     = 1

            local enemyHum  = target:FindFirstChildOfClass("Humanoid")
            local enemyRoot = target:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
                trackedRoot  = nil
                currentEnemy = nil
                return
            end

            if currentEnemy ~= target then
                if currentEnemy then smoothCleanAll() end
                currentEnemy = target
                trackedRoot  = nil
            end

            if trackedRoot == nil or trackedRoot.Parent == nil or not target:IsAncestorOf(trackedRoot) then
                trackedRoot = getEnemyRoot(target)
                snapHeightToEnemy(trackedRoot)
            end
            if not trackedRoot then return end

            local spawnPos = getEnemySpawnPosition(target) or trackedRoot.Position
            lockAndBringMobs(target, spawnPos, true, targetMonsterName)

            local targetCF = CFrame.new(spawnPos + Vector3.new(OFFSET_X, OFFSET_Y, OFFSET_Z))
            local dist     = (targetCF.Position - (currentFlyCF and currentFlyCF.Position or HRP.Position)).Magnitude

            if dist > REACH then
                stopAttackLoop()
                prevEnemy = nil
                moveToTarget(HRP, targetCF, dt)
            else
                currentFlyCF = targetCF
                pcall(function()
                    HRP.CFrame = targetCF
                    HRP.AssemblyLinearVelocity  = Vector3.zero
                    HRP.AssemblyAngularVelocity = Vector3.zero
                end)
                if target ~= prevEnemy then
                    prevEnemy = target
                    startAuraWithFarm()
                end
            end
        else
            -- หากไม่มีมอนสเตอร์ที่เลือกอยู่ใน Enemies ให้บินไปรอที่จุดเกิดของมอนสเตอร์ตัวแรกตามลำดับที่มีจุดเกิด
            stopAttackLoop()
            prevEnemy    = nil
            currentEnemy = nil
            trackedRoot  = nil
            smoothCleanAll()

            local spawns = {}
            for _, mobName in ipairs(activeList) do
                local s = getSpawnPositionsForMonster(mobName)
                if #s > 0 then
                    spawns = s
                    break
                end
            end

            if #spawns == 0 then return end
            if spawnIdx > #spawns then spawnIdx = 1 end

            local spawnPos = spawns[spawnIdx] + Vector3.new(OFFSET_X, OFFSET_Y, OFFSET_Z)

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
                        local baseCF = currentFlyCF or HRP.CFrame
                        currentFlyCF = CFrame.new(baseCF.Position.X, spawnPos.Y, baseCF.Position.Z) * baseCF.Rotation
                        HRP.CFrame = currentFlyCF
                    end)
                    task.wait(0.5)
                    isSnapping = false
                    snapDone   = true
                end)
                return
            end

            if isSnapping then return end

            local targetCF = CFrame.new(spawnPos)
            local dist = (spawnPos - (currentFlyCF and currentFlyCF.Position or HRP.Position)).Magnitude
            if dist > REACH then
                moveToTarget(HRP, targetCF, dt)
            else
                snapDone = false
                spawnIdx = spawnIdx % #spawns + 1
            end
        end
    end)
end

-- ==================== TELEPORT TWEEN ====================
local function stopTeleportTween()
    if teleportConn then
        teleportConn:Disconnect()
        teleportConn = nil
    end
    if not (autoNearEnabled or autoFarmEnabled) then
        stopPositionLock()
        stopNoclip()
    end
end

local function startTeleportTween()
    stopTeleportTween()
    if not selectedIslandPos then return end

    if HRP then currentFlyCF = HRP.CFrame end
    startNoclip()
    startPositionLock()

    teleportConn = RunService.Heartbeat:Connect(function(dt)
        if not teleportTweenEnabled then
            stopTeleportTween()
            return
        end
        if not updateCharacter() then return end
        if not selectedIslandPos then return end

        local targetCF   = CFrame.new(selectedIslandPos)
        local currentPos = currentFlyCF and currentFlyCF.Position or HRP.Position
        local dist       = (selectedIslandPos - currentPos).Magnitude

        if dist > REACH then
            moveToTarget(HRP, targetCF, dt)
        else
            currentFlyCF = targetCF
            pcall(function()
                HRP.CFrame = targetCF
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end

-- สแกนค้นหามอนสเตอร์ทั้งหมดก่อนสร้าง UI
scanAllMonsters()
local initialMonsterList = #masterMonsterList > 0 and masterMonsterList or {"(ไม่พบมอน)"}

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
        if teleportTweenEnabled then Toggles.TweenToIsland:SetValue(false) end
        currentEnemy = nil
        trackedRoot  = nil
        currentFlyCF = HRP and HRP.CFrame or nil
        startNoclip()
        startAutoNear()
        Library:Notify({ Title = "Auto Nears", Description = "Enabled", Time = 3 })
    else
        stopAttackLoop()
        stopPositionLock()
        stopNoclip()
        smoothCleanAll()
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

RightGroup:AddDropdown("MonsterSelect", {
    Values     = initialMonsterList,
    Default    = initialMonsterList[1] and { [initialMonsterList[1]] = true } or {},
    Multi      = true,
    Text       = "Select Monsters (Multi)",
    Searchable = true,
})
Options.MonsterSelect:OnChanged(function()
    updateSelectedMonstersList()
    if currentEnemy and currentEnemy.Parent then
        local currentMobName = cleanMonsterName(currentEnemy.Name)
        if not table.find(selectedMonsterList, currentMobName) then
            currentEnemy = nil
            trackedRoot  = nil
            smoothCleanAll()
        end
    end
end)

-- โหลดรายชื่อเริ่มต้นเข้าคิว Priority
updateSelectedMonstersList()

RightGroup:AddButton({
    Text = "Refresh Monster List",
    Func = function()
        updateMonsterDropdown(true)
    end,
})

-- ==================== DYNAMIC DISCOVERY (ไม่ลบตัวเก่า) ====================
local enemiesFolder = workspace:FindFirstChild("Enemies")
if enemiesFolder then
    enemiesFolder.ChildAdded:Connect(function(child)
        if addDiscoveredMonster(child.Name) then
            updateMonsterDropdown(false)
        end
    end)
end

local spawnsFolder = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
if spawnsFolder then
    spawnsFolder.ChildAdded:Connect(function(child)
        if addDiscoveredMonster(child.Name) then
            updateMonsterDropdown(false)
        end
    end)
end

RightGroup:AddToggle("AutoFarm", {
    Text    = "Auto Farm Select",
    Default = false,
})
Toggles.AutoFarm:OnChanged(function()
    autoFarmEnabled = Toggles.AutoFarm.Value
    if autoFarmEnabled then
        if teleportTweenEnabled then Toggles.TweenToIsland:SetValue(false) end
        currentEnemy       = nil
        trackedRoot        = nil
        currentFlyCF       = HRP and HRP.CFrame or nil
        cachedSpawnsByName = {}
        local activeList   = updateSelectedMonstersList()
        startNoclip()
        startAutoFarm()
        local desc = #activeList > 0 and table.concat(activeList, ", ") or "None"
        Library:Notify({ Title = "Auto Farm", Description = "Targeting: " .. desc, Time = 3 })
    else
        stopAttackLoop()
        stopPositionLock()
        stopNoclip()
        smoothCleanAll()
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
    if not bringMobEnabled then smoothCleanAll() end
    Library:Notify({ Title = "Bring Mob", Description = bringMobEnabled and "ON" or "OFF", Time = 3 })
end)

-- ==================== UI: TELEPORT TAB ====================
local TeleportLeft  = Tabs.Teleport:AddLeftGroupbox("Island Teleport")
local TeleportRight = Tabs.Teleport:AddRightGroupbox("Teleport Info")

local islandNames, islandMap, worldName = getIslandNamesAndMap(game.PlaceId)
selectedIslandName = islandNames[1]
selectedIslandPos  = islandMap[selectedIslandName]

TeleportLeft:AddLabel("Current Sea: " .. worldName)

TeleportLeft:AddDropdown("IslandSelect", {
    Values     = islandNames,
    Default    = 1,
    Multi      = false,
    Text       = "Select Island",
    Searchable = true,
})
Options.IslandSelect:OnChanged(function()
    selectedIslandName = Options.IslandSelect.Value
    selectedIslandPos  = islandMap[selectedIslandName]
end)

TeleportLeft:AddToggle("TweenToIsland", {
    Text    = "Tween to Island (Fly)",
    Default = false,
})
Toggles.TweenToIsland:OnChanged(function()
    teleportTweenEnabled = Toggles.TweenToIsland.Value
    if teleportTweenEnabled then
        if not selectedIslandPos then
            Library:Notify({ Title = "Teleport", Description = "No destination selected!", Time = 3 })
            Toggles.TweenToIsland:SetValue(false)
            return
        end
        if autoFarmEnabled then Toggles.AutoFarm:SetValue(false) end
        if autoNearEnabled then Toggles.AutoNear:SetValue(false) end
        startNoclip()
        startTeleportTween()
        Library:Notify({ Title = "Teleport", Description = "Flying to: " .. tostring(selectedIslandName), Time = 3 })
    else
        stopTeleportTween()
        Library:Notify({ Title = "Teleport", Description = "Stopped", Time = 3 })
    end
end)

TeleportLeft:AddButton({
    Text = "Instant Teleport",
    Func = function()
        if selectedIslandPos and HRP then
            pcall(function()
                HRP.CFrame = CFrame.new(selectedIslandPos)
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
            end)
            Library:Notify({ Title = "Teleport", Description = "Teleported to " .. tostring(selectedIslandName), Time = 3 })
        end
    end,
})

TeleportRight:AddLabel("Place ID: " .. tostring(game.PlaceId))
TeleportRight:AddLabel("Total Islands: " .. tostring(#islandNames))

TeleportRight:AddButton({
    Text = "Refresh Islands",
    Func = function()
        local newNames, newMap, newWorld = getIslandNamesAndMap(game.PlaceId)
        islandMap = newMap
        Options.IslandSelect:SetValues(newNames)
        Options.IslandSelect:SetValue(newNames[1])
        selectedIslandName = newNames[1]
        selectedIslandPos  = newMap[newNames[1]]
        Library:Notify({ Title = "Teleport", Description = "Reloaded " .. #newNames .. " locations (" .. newWorld .. ")", Time = 3 })
    end,
})

-- ==================== UI: FARM SETTINGS TAB ====================
local FarmLeft  = Tabs.FarmSettings:AddLeftGroupbox("Movement & Position Offset")
local FarmRight = Tabs.FarmSettings:AddRightGroupbox("Bring Mob Settings")

FarmLeft:AddSlider("TweenSpeed", {
    Text = "Tween Speed", Min = 0, Max = 500, Default = 250, Rounding = 0,
})
Options.TweenSpeed:OnChanged(function()
    SPEED = tonumber(Options.TweenSpeed.Value) or 250
end)

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

FarmRight:AddDropdown("BringMobMode", {
    Values  = BRING_MODES,
    Default = 1,
    Multi   = false,
    Text    = "Bring Mob Mode",
})
Options.BringMobMode:OnChanged(function()
    bringMobMode = Options.BringMobMode.Value
    smoothCleanAll()
    Library:Notify({ Title = "Bring Mob Mode", Description = bringMobMode, Time = 3 })
end)

FarmRight:AddSlider("BringRadius", {
    Text = "BringMob Distance", Min = 50, Max = 2000, Default = 300, Rounding = 10,
})
Options.BringRadius:OnChanged(function()
    BRING_RADIUS = tonumber(Options.BringRadius.Value) or 300
end)

FarmRight:AddSlider("BringCount", {
    Text = "Bring Mob count", Min = 1, Max = 10, Default = 1, Rounding = 0,
})
Options.BringCount:OnChanged(function()
    BRING_COUNT = tonumber(Options.BringCount.Value) or 1
end)

FarmRight:AddButton({
    Text = "Reset Value Default",
    Func = function()
        SPEED        = 250
        OFFSET_X     = 0
        OFFSET_Y     = 25
        OFFSET_Z     = 0
        BRING_RADIUS = 300
        BRING_COUNT  = 1
        bringMobMode = "Instant"
        Options.TweenSpeed:SetValue(250)
        Options.OffsetX:SetValue(0)
        Options.OffsetY:SetValue(25)
        Options.OffsetZ:SetValue(0)
        Options.BringMobMode:SetValue("Instant")
        Options.BringRadius:SetValue(300)
        Options.BringCount:SetValue(1)
        smoothCleanAll()
        Library:Notify({ Title = "Reset", Description = "Reset to Default", Time = 3 })
    end,
})

-- ==================== UI: UI SETTINGS TAB ====================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightAlt", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        autoNearEnabled      = false
        autoFarmEnabled      = false
        m1AuraEnabled        = false
        teleportTweenEnabled = false
        stopAttackLoop()
        stopPositionLock()
        stopNoclip()
        smoothCleanAll()
        stopTeleportTween()
        if followConn then followConn:Disconnect() followConn = nil end
        if farmConn   then farmConn:Disconnect()   farmConn   = nil end
        Library:Unload()
    end,
})

Library.ToggleKeybind = Options.MenuKeybind

-- ==================== CHARACTER RESPAWN ====================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character          = newChar
    HRP                = newChar:WaitForChild("HumanoidRootPart")
    Humanoid           = newChar:WaitForChild("Humanoid")
    currentEnemy       = nil
    trackedRoot        = nil
    currentFlyCF       = nil
    cachedSpawnsByName = {}
    stopPositionLock()
    smoothCleanAll()
    task.wait(1)
    if autoNearEnabled then
        startNoclip()
        startAutoNear()
    end
    if autoFarmEnabled then
        startNoclip()
        startAutoFarm()
    end
    if teleportTweenEnabled then
        startNoclip()
        startTeleportTween()
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
