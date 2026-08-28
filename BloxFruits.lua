local cloneref = cloneref or function(o) return o end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local function T(name)
    local ok, val = pcall(function()
        return Toggles and Toggles[name] and Toggles[name].Value
    end)
    return (ok and val == true) or false
end

local function O(name)
    local ok, val = pcall(function()
        return Options and Options[name] and Options[name].Value
    end)
    return (ok and val) or nil
end

local Window = Library:CreateWindow({
    Title = "KKKK Hub",
    Footer = "by Z",
    ShowCustomCursor = true,
    NotifySide = "Right",
})

local Tabs = {
    Info            = Window:AddTab("Info Server", "monitor"),
    FarmSettings    = Window:AddTab("Farm Settings", "settings-2"),
    Main            = Window:AddTab("Main", "sword"),
    Sea             = Window:AddTab("Sea", "anchor"),
    LocalPlayer     = Window:AddTab("Local Player", "user"),
    Esp             = Window:AddTab("ESP", "eye"),
    Stats           = Window:AddTab("Stats", "chart-no-axes-column"),
    Teleport        = Window:AddTab("Teleport", "map-pin"),
    Misc            = Window:AddTab("Misc", "box"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService   = game:GetService("TeleportService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local LocalPlayer       = Players.LocalPlayer
local Character         = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP               = Character:WaitForChild("HumanoidRootPart")
local Humanoid          = Character:WaitForChild("Humanoid")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net     = Modules:WaitForChild("Net")

local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
if not RegisterAttack or not RegisterHit then error("Remote events missing") end

local CFG = {
    SESSION_ID   = "32501259",
    MAX_DISTANCE = 100,
    MIN_DISTANCE = 1,
    SPEED        = 250,
    REACH        = 6,
    OFFSET_X     = 0,
    OFFSET_Y     = 25,
    OFFSET_Z     = 0,
    BRING_RADIUS = 300,
    BRING_COUNT  = 1,
}

local State = {
    autoNearEnabled      = false,
    autoFarmEnabled      = false,
    autoBossEnabled      = false,
    farmBypassEnabled    = true,
    bringMobEnabled      = true,
    bringMobMode         = "Instant",
    teleportTweenEnabled = false,
    bypassTpEnabled      = false,
    bypassMoving         = false,
    boatSpeedEnabled     = false,
    boatSpeedValue       = 250,
    boatTargetMode       = "Owner",
    boatNoclipEnabled    = false,
    playerNoclipEnabled  = false,
    currentEnemy         = nil,
    trackedRoot          = nil,
    currentFlyCF         = nil,
    selectedIslandName   = nil,
    selectedIslandPos    = nil,
    safeHealthThreshold  = 25,
    pSats                = 10,
    selectedWeaponType   = "Melee",
    currentLockPos       = nil,
    bringMobRunning      = false,
    currentBossIndex     = 1,
    bossWaitTick         = nil,
    bossSpawnIdx         = 1,
}

local bypassTpArrived = false

local HopState = {
    hopThread = nil,
    hopCD = 0,
    hopTick = tick(),
    hopTotal = 0,
    hopTarget = "singapore",
    hopMaxPlayers = 3,
}

local Lists = {
    discoveredMonsters  = {},
    masterMonsterList   = {},
    cachedSpawnsByName  = {},
    selectedMonsterList = {},
    discoveredBosses    = {},
    masterBossList      = {},
    selectedBossList    = {},
    bringMobData        = {},
    defaultBoatSpeeds   = {},
    WEAPON_TYPES        = {"Melee", "Sword", "Gun", "Fruit"},
    BRING_MODES         = {"Instant [Fast] ", "Smooth [Best]"},
    islandNames         = {},
    islandMap           = {},
    worldName           = "",
}

local Conns = {
    follow           = nil,
    farm             = nil,
    boss             = nil,
    teleport         = nil,
    noclip           = nil,
    lock             = nil,
    bypassTp         = nil,
    hitReg           = nil,
    bringMobNoclip   = nil,
    bringMobPin      = nil,
    instantBring     = nil,
    boatNoclip       = nil,
    playerNoclip     = nil,
    fastAttackThread = nil,
    bringMobThread   = nil,
}

local Refs = {
    EnemiesFolder      = Workspace:FindFirstChild("Enemies"),
    CharactersFolder   = Workspace:FindFirstChild("Characters"),
    AttackRemoteTarget = nil,
    AttackRemoteId     = nil,
}

local ESP = {
    Number      = math.random(1, 1000000),
    Player      = false,
    Island      = false,
    DevilFruit  = false,
    Flower      = false,
    Chest       = false,
    EventIsland = false,
    LegenSword  = false,
    Berry       = false,
}

local sea1 = (game.PlaceId == 2753915549 or game.PlaceId == 85211729168715)
local sea2 = (game.PlaceId == 4442272183 or game.PlaceId == 79091703265657)
local sea3 = (game.PlaceId == 7449423635 or game.PlaceId == 100117331123089)

local function getIslandNamesAndMap(placeId)
    local islandMap = {}
    local worldName = "Unknown"

    if placeId == 2753915549 or placeId == 85211729168715 then
        worldName = "First Sea"
        islandMap = {
            ["Starter Island"]   = Vector3.new(1122, 16, 1424),
            ["Marine Starter"]   = Vector3.new(-2750, 25, 2041),
            ["Jungle island"]    = Vector3.new(-1432, 62, 2),
            ["Pirate island"]    = Vector3.new(-1182, 61, 4036),
            ["Desert island"]    = Vector3.new(942, 21, 4378),
            ["Middle Town"]      = Vector3.new(-785, 74, 1606),
            ["Snow island"]      = Vector3.new(1353, 106, -1326),
            ["MarineBase island"]= Vector3.new(-4981, 85, 4164),
            ["Sky 1"]            = Vector3.new(-4831, 776, -2602),
            ["Sky 2"]            = Vector3.new(-7922, 5566, -378),
            ["Sky 3"]            = Vector3.new(-7987, 5756, -1925),
            ["Colosseum"]        = Vector3.new(-1468, 7, -2880),
            ["Magma island"]     = Vector3.new(-5395, 27, 8527),
            ["Prison island"]    = Vector3.new(5008, 89, 740),
            ["Whirl Pool"]       = Vector3.new(3874, 5, -1904),
            ["Fountain City"]    = Vector3.new(5305, 60, 4082),
        }
    elseif placeId == 4442272183 or placeId == 79091703265657 then
        worldName = "Second Sea"
        islandMap = {
            ["Dock 1"]           = Vector3.new(-13, 39, 2702),
            ["Dock 2"]           = Vector3.new(-1917, 6, -2549),
            ["Cafe"]             = Vector3.new(-386, 73, 297),
            ["Upper Green Zone"] = Vector3.new(-2577, 1628, -3742),
            ["Green Zone"]       = Vector3.new(-2456, 87, -3188),
            ["Graveyard"]        = Vector3.new(-5645, 185, -886),
            ["Snow Mountain"]    = Vector3.new(722, 406, -5290),
            ["Hot and Cold"]     = Vector3.new(-5557, 123, -5088),
            ["Cursed Ship"]      = Vector3.new(-6505, 83, -128),
            ["Ice Castle"]       = Vector3.new(6001, 294, -6614),
            ["Forgotten Island"] = Vector3.new(-3045, 240, -10144),
            ["Dark Arena"]       = Vector3.new(3382, 13, -3449),
            ["Usopp"]            = Vector3.new(4752, 8, 2850),
        }
    elseif placeId == 7449423635 or placeId == 100117331123089 then
        worldName = "Third Sea"
        islandMap = {
            ["Port Town"]         = Vector3.new(-341, 21, 5541),
            ["Hydra Town"]      = Vector3.new(5293, 1005, 391),
            ["Hydra Arena"]     = Vector3.new(5028, 174, -2007),
            ["Great Tree"]        = Vector3.new(4325, 566, -6152),
            ["Upper Great Tree"]    = Vector3.new(3038, 2282, -7337),
            ["Haunted Castle"]    = Vector3.new(-9514, 142, 5536),
            ["Bigmom island"]     = Vector3.new(-887, 66, -10905),
            ["Tiki Outpost"]      = Vector3.new(-16410, 528, 415),
            ["Mansion"]           = Vector3.new(-12462, 375, -7552),
            ["Castle on the Sea"] = Vector3.new(-4994, 315, -3007),
            ["Peanut island"]      = Vector3.new(-2122, 38, -10139),
            ["Katakuri island"]     = Vector3.new(-2094, 70, -12112),
            ["Chocolate island"]    = Vector3.new(66, 25, -12073),
            ["North Pole"]      = Vector3.new(-1091, 64, -14522),
        }
    else
        worldName = "Unknown Sea"
        islandMap = { ["Unknown"] = Vector3.new(0, 0, 0) }
    end

    local names = {}
    for k in pairs(islandMap) do table.insert(names, k) end
    table.sort(names)
    return names, islandMap, worldName
end

local function Convert_CFrame(x)
    if not x then return nil end
    if typeof(x) == "Vector3" then return CFrame.new(x)
    elseif typeof(x) == "CFrame" then return x
    elseif typeof(x) == "Instance" and x:IsA("Model") then return x:GetPivot()
    elseif typeof(x) == "Instance" and x:IsA("BasePart") then return x.CFrame
    elseif typeof(x) == "table" and x.CFrame then return x.CFrame
    end
    return nil
end

local function GetDistance(POS_1, POS_2)
    if POS_1 == nil then return 9e9 end
    local c = LocalPlayer.Character
    if not c then return 9e9 end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h or not h.Health or h.Health <= 0 then return 9e9 end
    if POS_2 == nil then
        POS_2 = c:FindFirstChild("HumanoidRootPart")
        if not POS_2 then return 9e9 end
    end
    local pos1 = Convert_CFrame(POS_1)
    local pos2 = Convert_CFrame(POS_2)
    if not pos1 or not pos2 then return 9e9 end
    return (pos1.Position - pos2.Position).Magnitude
end

local function getdis(a, b)
    local char = LocalPlayer.Character
    b = b or (char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame)
    if not b then return 9e9 end
    local _a = CFrame.new(a.X, b.Y, a.Z)
    local _b = CFrame.new(b.X, b.Y, b.Z)
    return (_a.Position - _b.Position).Magnitude
end

local function InArea(POS)
    local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
    if not WorldOrigin then return {Name = ""} end
    local locations = WorldOrigin:FindFirstChild("Locations")
    if not locations then return {Name = ""} end
    local pos = Convert_CFrame(POS)
    if not pos then return {Name = ""} end
    for _, v in next, locations:GetChildren() do
        local mesh = v:FindFirstChild("Mesh")
        if mesh and mesh:IsA("DataModelMesh") and (pos.Position - v.Position).Magnitude <= mesh.Scale.X then
            return v
        end
    end
    return {Name = ""}
end

local function GetSpawnPoint(x)
    if not x then return nil end
    local Spawns = workspace:FindFirstChild("_WorldOrigin")
        and workspace._WorldOrigin:FindFirstChild("PlayerSpawns")
        and workspace._WorldOrigin.PlayerSpawns:FindFirstChild("Pirates")
    if not Spawns then return nil end
    local posObj = Convert_CFrame(x)
    if not posObj then return nil end
    for _, v in next, Spawns:GetChildren() do
        local part = v:FindFirstChild("Part")
        if part and (part.Position - posObj.Position).Magnitude <= 2500 then
            return v
        end
    end
    return nil
end

local function CheckLegendaryItems()
    local function CheckItem(ITEM_NAME)
        for _, v in next, LocalPlayer.Backpack:GetChildren() do
            if v:IsA("Tool") and (v.Name == ITEM_NAME or string.find(v.Name, ITEM_NAME)) then return v end
        end
        for _, v in next, LocalPlayer.Character:GetChildren() do
            if v:IsA("Tool") and (v.Name == ITEM_NAME or string.find(v.Name, ITEM_NAME)) then return v end
        end
    end
    if CheckItem("God's Chalice") or CheckItem("Fist of Darkness") or CheckItem("Sweet Chalice") or CheckItem("Hallow Essence") then
        return true
    end
    return false
end

local function CanBypassTeleport(x)
    if not x then return false end
    local targetCF = Convert_CFrame(x)
    if not targetCF then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrpCheck = char:FindFirstChild("HumanoidRootPart")
    if not hrpCheck then return false end
    local humCheck = char:FindFirstChildOfClass("Humanoid")
    if not humCheck or not humCheck.Health or humCheck.Health <= 0 then return false end
    local AreaName = InArea(targetCF).Name
    if AreaName == "" then return false end
    if AreaName:find("Dimension") or AreaName:find("Submerged") or AreaName == "Sealed Cavern"
        or AreaName:lower():find("under") or CheckLegendaryItems() then
        return false
    end
    local data = LocalPlayer:FindFirstChild("Data")
    local lastSpawn = data and data:FindFirstChild("LastSpawnPoint")
    if lastSpawn and lastSpawn:IsA("StringValue") and lastSpawn.Value == "SubmergedIsland" then
        return false
    end
    if GetDistance(targetCF.Position) <= 1500 then return false end
    return true
end

local function GetBypassCFrame(x)
    local targetCF = Convert_CFrame(x)
    if not targetCF then return nil end
    local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
    if not WorldOrigin then return nil end
    local Spawns = WorldOrigin:FindFirstChild("PlayerSpawns")
    if not Spawns then return nil end
    local Pirates = Spawns:FindFirstChild("Pirates")
    if not Pirates then return nil end
    local Max = math.huge
    local Pos = nil
    local charHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not charHRP then return nil end
    for _, v in next, Pirates:GetChildren() do
        if v:FindFirstChild("Part") then
            if (targetCF.Position - charHRP.Position).Magnitude >= 3000
                and GetSpawnPoint(v.Part) ~= GetSpawnPoint(charHRP)
                and (v.Part.Position - charHRP.Position).Magnitude <= 10000
                and (v.Part.Position - targetCF.Position).Magnitude <= Max then
                Max = (v.Part.Position - targetCF.Position).Magnitude
                Pos = v
            end
        end
    end
    return Pos
end

local function WaitForHumanoid()
    local c = LocalPlayer.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then return h end
    local t = tick() + 5
    while tick() < t do
        h = c:FindFirstChildOfClass("Humanoid")
        if h then return h end
        task.wait(0.1)
    end
    return nil
end

local function BypassTP(Target)
    local c = LocalPlayer.Character
    if not c then return end
    local h = WaitForHumanoid()
    if not h or not h.Health or h.Health <= 0 then return end
    local targetCF = Convert_CFrame(Target)
    if not targetCF then return end
    if CanBypassTeleport(targetCF) and GetBypassCFrame(targetCF) then
        local TargetTP = GetBypassCFrame(targetCF)
        if TargetTP and TargetTP:FindFirstChild("Part") then
            pcall(function()
                if c:FindFirstChild("LastSpawnPoint") then
                    c.LastSpawnPoint.Disabled = true
                end
            end)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetLastSpawnPoint", TargetTP.Name)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
            c:PivotTo(TargetTP.Part.CFrame)
            h:ChangeState(15)
            task.wait(0.3)
            local waitStart = tick()
            while tick() - waitStart < 10 do
                task.wait(0.1)
                local newChar = LocalPlayer.Character
                if newChar then
                    local newHum = newChar:FindFirstChildOfClass("Humanoid")
                    if newHum and newHum.Health and newHum.Health > 0 then
                        break
                    end
                end
            end
        end
    end
end

local function checkinventory(v)
    if not v then return false end
    local ok, inv = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")
    end)
    if not ok or type(inv) ~= "table" then return false end
    for _, vl in pairs(inv) do
        if type(vl) == "table" and vl.Name == v then
            return true
        end
    end
    return false
end

local function requestentrance(pos)
    local targetPos = pos
    if typeof(pos) == "CFrame" then targetPos = pos.Position end
    if not targetPos then return end

    local charHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not charHRP then return end

    local playerPos = charHRP.Position
    local distPlayerToTarget = (playerPos - targetPos).Magnitude

    if distPlayerToTarget <= 1500 then return end

    local tb = {}

    if sea1 then
        tb = {
            Vector3.new(-7894.6181640625, 5547.1420898438, -380.29098510742),
            Vector3.new(-4607.8232421875, 874.39099121094, -1667.5570068359),
            Vector3.new(61163.8515625, 11.68000793457, 1819.7840576172),
            Vector3.new(3864.6879882812, 6.7369995117188, -1926.2139892578),
        }
    elseif sea2 then
        tb = {
            Vector3.new(2284.9091796875, 15.537796020508, 905.46417236328),
            Vector3.new(-286.98596191406, 306.13739013672, 597.89910888672),
            Vector3.new(-6508.5581054688, 89.035003662109, -132.83999633789),
            Vector3.new(923.21301269531, 126.9759979248, 32852.83203125),
        }
    elseif sea3 then
        tb = {
            Vector3.new(-12463.602539062, 378.32705688477, -7533.0830078125),
            Vector3.new(-5060.4116210938, 318.50201416016, -3160.2248535156),
            Vector3.new(5650.9477539062, 1017.2747802734, -300.3791809082),
        }
    else
        return
    end

    local bestPos = nil
    local bestDist = math.huge
    for _, v in ipairs(tb) do
        local dist = (v - targetPos).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestPos = v
        end
    end

    if not bestPos then return end

    local entranceToTarget = (bestPos - targetPos).Magnitude
    if entranceToTarget >= distPlayerToTarget then return end

    local distPlayerToEntrance = (playerPos - bestPos).Magnitude
    if distPlayerToEntrance <= 1500 then return end

    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", bestPos)
    end)

    task.wait(1.5)

    local newChar = LocalPlayer.Character
    local newHRP = newChar and newChar:FindFirstChild("HumanoidRootPart")
    if newHRP then
        State.currentFlyCF = newHRP.CFrame
    end
end

local function safeModeFlyUp(hrp)
    if not hrp or not hrp.Parent then return end
    local char = hrp.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.Health or hum.Health <= 0 then return end
    local SPEED = 300
    local bv = Instance.new("BodyVelocity")
    bv.Name     = "SafeModeBV"
    bv.MaxForce = Vector3.new(0, 1e9, 0)
    bv.P        = 1e6
    bv.Velocity = Vector3.new(0, SPEED, 0)
    bv.Parent   = hrp
    task.delay(500 / SPEED + 0.5, function()
        pcall(function()
            if bv and bv.Parent then bv:Destroy() end
        end)
    end)
end

local function updateCharacter()
    Character = LocalPlayer.Character
    if not Character then return false end
    HRP      = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not HRP or not HRP.Parent then return false end
    if not Humanoid or not Humanoid.Health or Humanoid.Health <= 0 then return false end
    if State.autoNearEnabled or State.autoFarmEnabled or State.autoBossEnabled or State.teleportTweenEnabled then
        pcall(function() Humanoid.AutoRotate = false end)
    end
    return true
end

local function cleanMonsterName(name)
    if not name then return "" end
    return (name:gsub("%s*%[.-%]", "")):match("^%s*(.-)%s*$") or ""
end

local function getEnemyRoot(enemy)
    if not enemy or not enemy.Parent then return nil end
    return enemy:FindFirstChild("HumanoidRootPart")
end

local function getSpawnPositionsForMonster(monsterName)
    if not monsterName or monsterName == "" then return {} end
    if Lists.cachedSpawnsByName[monsterName] and #Lists.cachedSpawnsByName[monsterName] > 0 then
        return Lists.cachedSpawnsByName[monsterName]
    end
    local list   = {}
    local spawns = Workspace:FindFirstChild("_WorldOrigin")
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
                    for _, cp in ipairs(list) do if (cp - pos).Magnitude < 5 then dup = true; break end end
                    if not dup then table.insert(list, pos) end
                end
            end
        end
    end
    local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            if cleanMonsterName(model.Name) == monsterName then
                local root = model:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos = root.Position
                    local dup = false
                    for _, cp in ipairs(list) do if (cp - pos).Magnitude < 10 then dup = true; break end end
                    if not dup then table.insert(list, pos) end
                end
            end
        end
    end
    if #list > 0 then Lists.cachedSpawnsByName[monsterName] = list end
    return list
end

local function addDiscoveredMonster(rawName)
    local clean = cleanMonsterName(rawName)
    if clean and clean ~= "" and clean ~= "(No monster found)" and not Lists.discoveredMonsters[clean] then
        Lists.discoveredMonsters[clean] = true
        table.insert(Lists.masterMonsterList, clean)
        table.sort(Lists.masterMonsterList, function(a, b) return a:lower() < b:lower() end)
        return true
    end
    return false
end

local function scanAllMonsters()
    local newlyFound = false
    local spawns = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then for _, part in ipairs(spawns:GetChildren()) do if addDiscoveredMonster(part.Name) then newlyFound = true end end end
    local enemies = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if enemies then for _, model in ipairs(enemies:GetChildren()) do if addDiscoveredMonster(model.Name) then newlyFound = true end end end
    return newlyFound
end

local function getAllEnemies()
    local list   = {}
    local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if not folder then return list end
    for _, model in ipairs(folder:GetChildren()) do
        local hum  = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health and hum.Health > 0 then table.insert(list, model) end
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

local function findPriorityEnemy(monsterList)
    local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if not folder then return nil, nil end
    local best, bestDist, bestName = nil, math.huge, nil
    local charPos = (HRP and HRP.Position) or (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position)
    local searchList = monsterList
    if #searchList == 0 then return nil, nil end
    for _, model in ipairs(folder:GetChildren()) do
        local mobName = cleanMonsterName(model.Name)
        if table.find(searchList, mobName) then
            local hum  = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health and hum.Health > 0 then
                local dist = charPos and (charPos - root.Position).Magnitude or 0
                if dist < bestDist then
                    best     = model
                    bestDist = dist
                    bestName = mobName
                end
            end
        end
    end
    return best, bestName
end

local function updateSelectedMonstersList()
    local currentVal  = O("MonsterSelect")
    local updatedList = {}
    if typeof(currentVal) == "table" then
        for _, name in ipairs(Lists.selectedMonsterList) do
            if currentVal[name] == true and not table.find(updatedList, name) then
                table.insert(updatedList, name)
            end
        end
        for name, isSelected in pairs(currentVal) do
            if isSelected == true and not table.find(updatedList, name) then
                table.insert(updatedList, name)
            end
        end
    elseif typeof(currentVal) == "string" and currentVal ~= "" and currentVal ~= "(No monster found)" then
        table.insert(updatedList, currentVal)
    end
    Lists.selectedMonsterList = updatedList
    return Lists.selectedMonsterList
end

local function updateMonsterDropdown(isManual)
    local hasNew = scanAllMonsters()
    if (hasNew or isManual) and Options and Options.MonsterSelect then
        local currentVal        = O("MonsterSelect") or {}
        local currentSelections = {}
        if typeof(currentVal) == "table" then
            for k, v in pairs(currentVal) do if v == true then currentSelections[k] = true end end
        elseif typeof(currentVal) == "string" and currentVal ~= "" and currentVal ~= "(No monster found)" then
            currentSelections[currentVal] = true
        end
        local displayList = #Lists.masterMonsterList > 0 and Lists.masterMonsterList or {"(No monster found)"}
        Options.MonsterSelect:SetValues(displayList)
        if next(currentSelections) then Options.MonsterSelect:SetValue(currentSelections) end
        updateSelectedMonstersList()
        if isManual then
            Library:Notify({ Title = "Refreshed", Description = #Lists.masterMonsterList .. " monsters found", Time = 3 })
        end
    end
end

local function updateSelectedBossesList()
    local currentVal  = O("BossSelect")
    local updatedList = {}
    if typeof(currentVal) == "table" then
        for _, name in ipairs(Lists.selectedBossList) do
            if currentVal[name] == true and not table.find(updatedList, name) then
                table.insert(updatedList, name)
            end
        end
        for name, isSelected in pairs(currentVal) do
            if isSelected == true and not table.find(updatedList, name) then
                table.insert(updatedList, name)
            end
        end
    elseif typeof(currentVal) == "string" and currentVal ~= "" and currentVal ~= "(No Boss found)" then
        table.insert(updatedList, currentVal)
    end
    Lists.selectedBossList = updatedList
    return Lists.selectedBossList
end

local function refreshBossDropdown()
    Lists.masterBossList = {}
    Lists.discoveredBosses = {}

    local spawns = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then
        for _, part in ipairs(spawns:GetChildren()) do
            if string.find(part.Name, "%[Boss%]") then
                local name = cleanMonsterName(part.Name)
                if name and name ~= "" and not Lists.discoveredBosses[name] then
                    Lists.discoveredBosses[name] = true
                    table.insert(Lists.masterBossList, name)
                end
            end
        end
    end

    local enemies = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            local hum = model:FindFirstChildOfClass("Humanoid")
            local displayName = hum and hum.DisplayName or ""
            local checkName = (displayName ~= "" and string.find(displayName, "%[Boss%]")) and displayName or model.Name
            if string.find(checkName, "%[Boss%]") then
                local name = cleanMonsterName(checkName)
                if name and name ~= "" and not Lists.discoveredBosses[name] then
                    Lists.discoveredBosses[name] = true
                    table.insert(Lists.masterBossList, name)
                end
            end
        end
    end

    table.sort(Lists.masterBossList, function(a, b) return a:lower() < b:lower() end)

    local displayList = #Lists.masterBossList > 0 and Lists.masterBossList or {"(No Boss found)"}
    if Options and Options.BossSelect then
        Options.BossSelect:SetValues(displayList)
    end

    Library:Notify({
        Title = "Boss List Refreshed",
        Description = #Lists.masterBossList > 0
            and ("Found " .. #Lists.masterBossList .. " boss(es): " .. table.concat(Lists.masterBossList, ", "))
            or "No bosses found",
        Time = 5,
    })
end

local function findBossByPriority(activeList)
    local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if not folder or #activeList == 0 then return nil, nil end

    for _, bossName in ipairs(activeList) do
        for _, model in ipairs(folder:GetChildren()) do
            if cleanMonsterName(model.Name) == bossName then
                local hum  = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health and hum.Health > 0 then
                    return model, bossName
                end
            end
        end
    end

    return nil, nil
end

local function addDiscoveredBoss(rawName)
    if not rawName or not string.find(rawName, "%[Boss%]") then return false end
    local clean = cleanMonsterName(rawName)
    if clean and clean ~= "" and clean ~= "(No Boss found)" and not Lists.discoveredBosses[clean] then
        Lists.discoveredBosses[clean] = true
        table.insert(Lists.masterBossList, clean)
        table.sort(Lists.masterBossList, function(a, b) return a:lower() < b:lower() end)
        return true
    end
    return false
end

local FastAttackModule      = { Rate = 0.05, Enabled = false }
local HitRegistrationModule = {}

local function safeWaitForChild(parent, childName)
    local ok, result = pcall(function() return parent:WaitForChild(childName, 5) end)
    return ok and result or parent:FindFirstChild(childName)
end

local function refreshFolders()
    Refs.EnemiesFolder    = safeWaitForChild(Workspace, "Enemies")
    Refs.CharactersFolder = safeWaitForChild(Workspace, "Characters")
end
refreshFolders()

function FastAttackModule.GetNearbyTargets(character, folder)
    if not folder or not character then return {} end
    local characterPosition = character:GetPivot().Position
    local nearbyTargets = {}
    local children = folder:GetChildren()
    for i = 1, #children do
        local target = children[i]
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        local rootPart = target:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and humanoid.Health and humanoid.Health > 0 then
            local distance = (rootPart.Position - characterPosition).Magnitude
            if distance <= 60 then table.insert(nearbyTargets, target) end
        end
    end
    return nearbyTargets
end

function FastAttackModule.GetTargetParts(targetList)
    local result = {}
    for i = 1, #targetList do
        local target = targetList[i]
        local head = target:FindFirstChild("Head") or target.PrimaryPart
        if head then table.insert(result, {target, head}) end
    end
    return result
end

function FastAttackModule.GetAllTargets(character)
    if not Refs.EnemiesFolder    then Refs.EnemiesFolder    = Workspace:FindFirstChild("Enemies")    end
    if not Refs.CharactersFolder then Refs.CharactersFolder = Workspace:FindFirstChild("Characters") end
    local enemies         = FastAttackModule.GetNearbyTargets(character, Refs.EnemiesFolder)
    local otherCharacters = FastAttackModule.GetNearbyTargets(character, Refs.CharactersFolder)
    local allTargets = {}
    for i = 1, #enemies         do table.insert(allTargets, enemies[i])         end
    for i = 1, #otherCharacters do table.insert(allTargets, otherCharacters[i]) end
    return allTargets
end

function FastAttackModule.ExecuteFastAttack()
    local character = LocalPlayer.Character
    if not character then return end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local targets = FastAttackModule.GetAllTargets(character)
    if #targets < 1 then return end
    local targetParts = FastAttackModule.GetTargetParts(targets)
    if #targetParts < 1 or not targetParts[1] then return end
    
    local weaponType = tool:GetAttribute("WeaponType") or State.selectedWeaponType

        RegisterAttack:FireServer(FastAttackModule.Rate)
        local targetHead = targetParts[1][2]
        if targetHead then
            RegisterHit:FireServer(targetHead, targetParts)
        end
    end
local function initHitRegistration()
    local foldersToCheck = {}
    for _, name in ipairs({"Util", "Common", "Remotes", "Assets", "FX"}) do
        local f = ReplicatedStorage:FindFirstChild(name)
        if f then table.insert(foldersToCheck, f) end
    end
    for _, folder in ipairs(foldersToCheck) do
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                Refs.AttackRemoteTarget = child
                Refs.AttackRemoteId     = child:GetAttribute("Id")
            end
        end
        folder.ChildAdded:Connect(function(child)
            if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                Refs.AttackRemoteTarget = child
                Refs.AttackRemoteId     = child:GetAttribute("Id")
            end
        end)
    end
end
pcall(initHitRegistration)

function HitRegistrationModule.Execute()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    if not Refs.EnemiesFolder    then Refs.EnemiesFolder    = Workspace:FindFirstChild("Enemies")    end
    if not Refs.CharactersFolder then Refs.CharactersFolder = Workspace:FindFirstChild("Characters") end
    local hitTargets = {}
    local function scanFolder(folder)
        if not folder then return end
        local children = folder:GetChildren()
        for i = 1, #children do
            local target   = children[i]
            local humanoid = target:FindFirstChildOfClass("Humanoid")
            local rootPart = target:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart and humanoid.Health and humanoid.Health > 0 and target ~= character then
                local distance = (rootPart.Position - humanoidRootPart.Position).Magnitude
                if distance <= 60 then
                    for _, child in ipairs(target:GetChildren()) do
                        if child:IsA("BasePart") then table.insert(hitTargets, {target, child}) end
                    end
                end
            end
        end
    end
    scanFolder(Refs.EnemiesFolder)
    scanFolder(Refs.CharactersFolder)
    local tool = character:FindFirstChildOfClass("Tool")
    local weaponType = tool and tool:GetAttribute("WeaponType")
    if #hitTargets > 0 and tool and (weaponType == "Melee" or weaponType == "Sword") then
        local ok, seed = pcall(function()
            return Net:FindFirstChild("seed") and Net.seed:InvokeServer()
        end)
        if not ok or not seed then seed = math.random(1000, 9999) end
        RegisterAttack:FireServer()
        local targetHead = hitTargets[1] and hitTargets[1][1] and hitTargets[1][1]:FindFirstChild("Head")
        if not targetHead then return end
        RegisterHit:FireServer(targetHead, hitTargets, {})
        if Refs.AttackRemoteTarget and Refs.AttackRemoteId then
            pcall(function()
                local remoteCode    = "RE/RegisterHit"
                local encryptionKey = math.floor(Workspace:GetServerTimeNow() / 10 % 10) + 1
                local encodedString = string.gsub(remoteCode, ".", function(char)
                    return string.char(bit32.bxor(string.byte(char), encryptionKey))
                end)
                local finalId = bit32.bxor(Refs.AttackRemoteId + 909090, seed * 2)
                cloneref(Refs.AttackRemoteTarget):FireServer(encodedString, finalId, targetHead, hitTargets)
            end)
        end
    end
end

local function startFastAttack()
    FastAttackModule.Enabled = true
    if Conns.fastAttackThread then task.cancel(Conns.fastAttackThread); Conns.fastAttackThread = nil end
    Conns.fastAttackThread = task.spawn(function()
        while FastAttackModule.Enabled do
            pcall(FastAttackModule.ExecuteFastAttack)
            task.wait(FastAttackModule.Rate)
        end
        Conns.fastAttackThread = nil
    end)
end

local function stopFastAttack()
    if not T("FastAttack") then
        FastAttackModule.Enabled = false
    end
    if Conns.fastAttackThread then task.cancel(Conns.fastAttackThread); Conns.fastAttackThread = nil end
end

local function startHitRegistration()
    if Conns.hitReg then Conns.hitReg:Disconnect() end
    Conns.hitReg = RunService.Heartbeat:Connect(function()
        if FastAttackModule.Enabled then
            pcall(HitRegistrationModule.Execute)
        end
    end)
end

local function stopHitRegistration()
    if not T("FastAttack") then
        if Conns.hitReg then Conns.hitReg:Disconnect(); Conns.hitReg = nil end
    end
end

local function checkAndResumeFastAttack()
    if T("FastAttack") then
        FastAttackModule.Enabled = true
        startFastAttack()
        startHitRegistration()
    else
        FastAttackModule.Enabled = false
        if Conns.fastAttackThread then task.cancel(Conns.fastAttackThread); Conns.fastAttackThread = nil end
        if Conns.hitReg then Conns.hitReg:Disconnect(); Conns.hitReg = nil end
    end
end

local function bmReleaseMob(enemy)
    local d = Lists.bringMobData[enemy]
    if d then
        for _, k in ipairs({"bp", "bv", "bg"}) do
            if d[k] and d[k].Parent then pcall(function() d[k]:Destroy() end) end
        end
        Lists.bringMobData[enemy] = nil
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

local function bmCleanAll()
    for enemy in pairs(Lists.bringMobData) do pcall(bmReleaseMob, enemy) end
    Lists.bringMobData = {}
end

local function stopBringMobLoop()
    State.bringMobRunning = false
    if Conns.bringMobThread     then task.cancel(Conns.bringMobThread);     Conns.bringMobThread     = nil end
    if Conns.bringMobPin        then Conns.bringMobPin:Disconnect();        Conns.bringMobPin        = nil end
    if Conns.bringMobNoclip     then Conns.bringMobNoclip:Disconnect();     Conns.bringMobNoclip     = nil end
    bmCleanAll()
end

local function stopInstantBring()
    if Conns.instantBring then Conns.instantBring:Disconnect(); Conns.instantBring = nil end
end

local function smoothCleanAll()
    stopBringMobLoop()
    stopInstantBring()
end

local function bmGetOffset()
    local a = math.random() * math.pi * 2
    local r = math.random(2, 5)
    return Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
end

local function trySetNetworkOwner(part, player)
    pcall(function()
        if part:IsA("BasePart") then
            part:SetNetworkOwner(player)
        end
    end)
end

local function forceSetNetworkOwnerOnModel(model, player)
    pcall(function()
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p:SetNetworkOwner(player) end)
            end
        end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function() hrp:SetNetworkOwner(player) end)
        end
    end)
end

local function startInstantBring()
    stopInstantBring()

    local SNAP_DISTANCE = 10
    local PULL_FORCE    = 65000
    local PULL_P        = 40000
    local PULL_D        = 1500

    local mobData = {}

    local function attachMob(enemy)
        if mobData[enemy] then return end
        local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
        if not hrp then return end

        for _, p in ipairs(enemy:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
        end

        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(PULL_FORCE, PULL_FORCE, PULL_FORCE)
        bp.P = PULL_P; bp.D = PULL_D
        bp.Position = hrp.Position
        bp.Parent = hrp

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(0, PULL_FORCE, 0)
        bg.P = PULL_P; bg.D = PULL_D
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        mobData[enemy] = { root = hrp, bp = bp, bg = bg, snapped = false }
    end

    local function detachMob(enemy)
        local d = mobData[enemy]
        if not d then return end
        if d.bp and d.bp.Parent then pcall(function() d.bp:Destroy() end) end
        if d.bg and d.bg.Parent then pcall(function() d.bg:Destroy() end) end
        local hum = enemy and enemy:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function()
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.PlatformStand = false
        end) end
        if enemy and enemy.Parent then
            for _, p in ipairs(enemy:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
            end
        end
        mobData[enemy] = nil
    end

    Conns.instantBring = RunService.Heartbeat:Connect(function()
        local targetRoot = State.currentEnemy and State.currentEnemy.Parent
            and State.currentEnemy:FindFirstChild("HumanoidRootPart")
        if targetRoot and targetRoot.Parent then
            State.currentLockPos = targetRoot.Position
        end
        if not State.currentLockPos then return end
        local lockPos = State.currentLockPos

        local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
        if not folder then return end

        for enemy in pairs(mobData) do
            if not enemy or not enemy.Parent then
                mobData[enemy] = nil; continue
            end
            local h = enemy:FindFirstChildOfClass("Humanoid")
            if not h or not h.Health or h.Health <= 0 then
                detachMob(enemy)
            end
        end

        local count = 0
        for _, d in pairs(mobData) do
            if not d.snapped and d.bp and d.bp.Parent then count = count + 1 end
        end

        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy == State.currentEnemy then continue end
            if mobData[enemy] then continue end
            if count >= CFG.BRING_COUNT then break end

            local hum = enemy:FindFirstChildOfClass("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
            if not hum or not hrp or not hum.Health or hum.Health <= 0 then continue end

            if (lockPos - hrp.Position).Magnitude > CFG.BRING_RADIUS then continue end

            attachMob(enemy)
            count = count + 1
        end

        local mobIndex = 0
        for enemy, d in pairs(mobData) do
            if enemy == State.currentEnemy then
                detachMob(enemy); continue
            end
            if not enemy.Parent or not d.root.Parent then
                detachMob(enemy); continue
            end

            local dist = (lockPos - d.root.Position).Magnitude

            if not d.snapped then
                if dist <= SNAP_DISTANCE then
                    pcall(function()
                        d.root.CFrame = CFrame.new(lockPos)
                        d.root.AssemblyLinearVelocity  = Vector3.zero
                        d.root.AssemblyAngularVelocity = Vector3.zero
                    end)
                    if d.bp and d.bp.Parent then d.bp:Destroy() end
                    if d.bg and d.bg.Parent then d.bg:Destroy() end
                    d.bp = nil; d.bg = nil

                    local hum = enemy:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function()
                        hum.WalkSpeed = 0
                        hum.JumpPower = 0
                        hum.PlatformStand = true
                    end) end
                    d.snapped = true
                else
                    if d.bp and d.bp.Parent then
                        pcall(function() d.bp.Position = lockPos end)
                    end
                    local dir = (lockPos - d.root.Position)
                    local lookDir = Vector3.new(dir.X, 0, dir.Z).Unit
                    if d.bg and d.bg.Parent and lookDir.Magnitude > 0 then
                        pcall(function()
                            d.bg.CFrame = CFrame.new(d.root.Position, d.root.Position + lookDir)
                        end)
                    end
                end
            else
                local offsetAngle = mobIndex * (math.pi * 2 / math.max(CFG.BRING_COUNT, 1))
                local offsetRadius = CFG.BRING_COUNT > 1 and 3 or 0
                local pinPos = lockPos + Vector3.new(
                    math.cos(offsetAngle) * offsetRadius,
                    0,
                    math.sin(offsetAngle) * offsetRadius
                )
                pcall(function()
                    d.root.CFrame = CFrame.new(pinPos)
                    d.root.AssemblyLinearVelocity  = Vector3.zero
                    d.root.AssemblyAngularVelocity = Vector3.zero
                end)
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function()
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    hum.PlatformStand = true
                end) end
                mobIndex = mobIndex + 1
            end
        end
    end)
end

local function startSmoothBring(getLockPos)
    if State.bringMobRunning then return end
    State.bringMobRunning = true

    local PULL_FORCE = 800000
    local PULL_P     = 80000
    local PULL_D     = 500

    if Conns.bringMobNoclip then Conns.bringMobNoclip:Disconnect() end
    Conns.bringMobNoclip = RunService.RenderStepped:Connect(function()
        for enemy in pairs(Lists.bringMobData) do
            if enemy == State.currentEnemy then
                pcall(bmReleaseMob, enemy); continue
            end
            if enemy and enemy.Parent then
                for _, p in ipairs(enemy:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        pcall(function() p.CanCollide = false end)
                    end
                end
            end
        end
    end)

    local pinFrame = 0
    if Conns.bringMobPin then Conns.bringMobPin:Disconnect() end
    Conns.bringMobPin = RunService.Heartbeat:Connect(function()
        pinFrame = pinFrame + 1
        if pinFrame % 2 ~= 0 then return end

        local targetRoot = State.currentEnemy and State.currentEnemy.Parent
            and State.currentEnemy:FindFirstChild("HumanoidRootPart")
        if targetRoot and targetRoot.Parent then
            State.currentLockPos = targetRoot.Position
        end

        local lockPos = getLockPos()
        if not lockPos then return end

        for enemy, d in pairs(Lists.bringMobData) do
            if enemy == State.currentEnemy then
                pcall(bmReleaseMob, enemy); continue
            end
            if not enemy or not enemy.Parent or not d then continue end
            local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
            if not hrp then continue end
            local hum = enemy:FindFirstChildOfClass("Humanoid")

            if d.bp and d.bp.Parent then
                pcall(function() d.bp.Position = lockPos end)

                if (lockPos - hrp.Position).Magnitude <= 5 then
                    pcall(function()
                        hrp.CFrame = CFrame.new(lockPos)
                        hrp.AssemblyLinearVelocity  = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                end

                local dir = (lockPos - hrp.Position)
                local lookDir = Vector3.new(dir.X, 0, dir.Z).Unit
                if d.bg and d.bg.Parent and lookDir.Magnitude > 0 then
                    pcall(function()
                        d.bg.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir)
                    end)
                end

                if hum then pcall(function()
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    hum.PlatformStand = true
                end) end
            end
        end
    end)

    Conns.bringMobThread = task.spawn(function()
        while State.bringMobRunning do
            task.wait(0.05)

            local targetRoot = State.currentEnemy and State.currentEnemy.Parent
                and State.currentEnemy:FindFirstChild("HumanoidRootPart")
            if targetRoot and targetRoot.Parent then
                State.currentLockPos = targetRoot.Position
            end

            local lockPos = getLockPos()
            if not lockPos then continue end

            local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
            if not folder then task.wait(0.3); continue end

            for enemy in pairs(Lists.bringMobData) do
                if enemy == State.currentEnemy then
                    pcall(bmReleaseMob, enemy); continue
                end
                if not enemy or not enemy.Parent then
                    pcall(bmReleaseMob, enemy); continue
                end
                local h = enemy:FindFirstChildOfClass("Humanoid")
                if not h or not h.Health or h.Health <= 0 then
                    pcall(bmReleaseMob, enemy)
                end
            end

            local pulling = 0
            for _, d in pairs(Lists.bringMobData) do
                if d.bp and d.bp.Parent then pulling = pulling + 1 end
            end

            for _, enemy in ipairs(folder:GetChildren()) do
                if not State.bringMobRunning then break end
                if not enemy or not enemy.Parent then continue end
                if enemy == State.currentEnemy then continue end
                if Lists.bringMobData[enemy] then continue end
                if pulling >= CFG.BRING_COUNT then break end

                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
                if not hum or not hrp or not hum.Health or hum.Health <= 0 then continue end

                if (lockPos - hrp.Position).Magnitude > CFG.BRING_RADIUS then continue end

                for _, p in ipairs(enemy:GetDescendants()) do
                    if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
                end

                pcall(function()
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    hum.PlatformStand = true
                end)

                local bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(PULL_FORCE, PULL_FORCE, PULL_FORCE)
                bp.P = PULL_P; bp.D = PULL_D
                bp.Position = lockPos
                bp.Parent = hrp

                local bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(0, PULL_FORCE, 0)
                bg.P = PULL_P; bg.D = PULL_D
                bg.CFrame = hrp.CFrame
                bg.Parent = hrp

                Lists.bringMobData[enemy] = { bp = bp, bg = bg }
                pulling = pulling + 1
            end
        end

        if Conns.bringMobPin    then Conns.bringMobPin:Disconnect();    Conns.bringMobPin    = nil end
        if Conns.bringMobNoclip then Conns.bringMobNoclip:Disconnect(); Conns.bringMobNoclip = nil end
        bmCleanAll()
        Conns.bringMobThread = nil
    end)
end

local function lockAndBringMobs(targetEnemy, lockPos)
    if not targetEnemy or not targetEnemy.Parent or not lockPos then
        stopBringMobLoop(); stopInstantBring(); return
    end
    local targetRoot = targetEnemy:FindFirstChild("HumanoidRootPart")
    local targetHum  = targetEnemy:FindFirstChildOfClass("Humanoid")
    if not targetRoot or not targetHum or not targetHum.Health or targetHum.Health <= 0 then
        stopBringMobLoop(); stopInstantBring(); return
    end

    forceSetNetworkOwnerOnModel(targetEnemy, LocalPlayer)

    if not State.bringMobEnabled then
        stopBringMobLoop(); stopInstantBring(); return
    end

    -- update lockPos จาก trackedRoot ที่ขยับตลอดเวลา
    State.currentLockPos = targetRoot.Position

    if string.find(State.bringMobMode, "Instant") then
        if not Conns.instantBring then
            startInstantBring()
        end
    else
        if not State.bringMobRunning then
            local function getLockPos() return State.currentLockPos end
            startSmoothBring(getLockPos)
        end
    end
end

local function startNoclip()
    if Conns.noclip then Conns.noclip:Disconnect() end
    Conns.noclip = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end

        -- noclip มอนเป้าหมายด้วยทุก frame
        if State.currentEnemy and State.currentEnemy.Parent then
            for _, p in ipairs(State.currentEnemy:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    pcall(function() p.CanCollide = false end)
                end
            end
        end

        if HRP then
            pcall(function()
                if not State.bypassMoving then
                    HRP.AssemblyLinearVelocity  = Vector3.zero
                    HRP.AssemblyAngularVelocity = Vector3.zero
                end
                for _, child in ipairs(HRP:GetChildren()) do
                    if child.Name == "BypassBV" then continue end
                    if child:IsA("BodyVelocity") or child:IsA("BodyGyro")
                       or child:IsA("BodyPosition") or child:IsA("LinearVelocity")
                       or child:IsA("VectorForce") or child:IsA("AlignPosition")
                       or child:IsA("AlignOrientation") then
                        child:Destroy()
                    end
                end
            end)
        end
    end)
end

local function stopNoclip()
    if Conns.noclip then Conns.noclip:Disconnect(); Conns.noclip = nil end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
end

local function startPositionLock()
    if Conns.lock then Conns.lock:Disconnect() end
    if Humanoid then pcall(function() Humanoid.AutoRotate = false end) end
    Conns.lock = RunService.RenderStepped:Connect(function()
        if not (State.autoNearEnabled or State.autoFarmEnabled or State.autoBossEnabled or State.teleportTweenEnabled or State.bypassTpEnabled) then
            if Conns.lock then Conns.lock:Disconnect(); Conns.lock = nil end
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum.Health or hum.Health <= 0 then return end

        -- ถ้ากำลัง farm/boss/near อยู่ให้ Heartbeat จัดการ rotation เอง ไม่ lock ซ้ำ
        if State.autoFarmEnabled or State.autoBossEnabled or State.autoNearEnabled then return end

        if State.currentFlyCF then
            pcall(function()
                hrp.CFrame = State.currentFlyCF
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end)
        end
    end)
end

local function stopPositionLock()
    if Conns.lock then Conns.lock:Disconnect(); Conns.lock = nil end
    State.currentFlyCF = nil
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.AutoRotate = true
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hrp then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

local function moveToTarget(hrp, targetCF, dt)
    if not hrp or not hrp.Parent or not targetCF then return end
    if not State.currentFlyCF or (State.currentFlyCF.Position - hrp.Position).Magnitude > 300 then
        State.currentFlyCF = hrp.CFrame
    end
    local targetPos  = targetCF.Position
    local currentPos = State.currentFlyCF.Position
    local delta      = targetPos - currentPos
    local dist       = delta.Magnitude
    local step       = (CFG.SPEED or 250) * dt
    local newPos     = (dist <= step or dist < 0.01) and targetPos or currentPos + (delta / dist) * step

    -- เอา rotation เต็มๆ จาก targetCF มาใช้เลย ไม่ตัด axis
    local rx, ry, rz = targetCF:ToEulerAnglesXYZ()
    local fullRot    = CFrame.fromEulerAnglesXYZ(rx, ry, rz)
    local finalCF    = CFrame.new(newPos) * fullRot

    State.currentFlyCF = finalCF
    pcall(function()
        hrp.CFrame = finalCF
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

local lastFarmBypassTick = 0
local function tryFarmBypass(targetPos)
    if not State.farmBypassEnabled then return false end
    if not targetPos then return false end
    if tick() - lastFarmBypassTick < 4 then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local targetCF = Convert_CFrame(targetPos)
    if not targetCF then return false end
    local dist = (hrp.Position - targetCF.Position).Magnitude
    if dist > 1500 and CanBypassTeleport(targetCF) then
        lastFarmBypassTick = tick()
        task.spawn(function()
            pcall(function()
                BypassTP(targetCF)
                task.wait(0.3)
                requestentrance(targetCF)
            end)
            local newChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
            if newHrp then
                State.currentFlyCF = newHrp.CFrame
            end
        end)
        return true
    end
    return false
end

local function getEnemySpawnPosition(targetEnemy)
    if not targetEnemy or not targetEnemy.Parent then return nil end
    local root = targetEnemy:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local currentPos  = root.Position
    local monsterName = cleanMonsterName(targetEnemy.Name)
    local spawns      = getSpawnPositionsForMonster(monsterName)
    if #spawns == 0 then return currentPos end
    local bestPos, bestDist = currentPos, math.huge
    for _, spawnPos in ipairs(spawns) do
        local dist = (spawnPos - currentPos).Magnitude
        if dist < bestDist then bestDist = dist; bestPos = spawnPos end
    end
    return bestPos
end

local function findWeapon(keyword)
    local char = LocalPlayer.Character
    if char then
        local held = char:FindFirstChildOfClass("Tool")
        if held and string.find(held.ToolTip or "", keyword, 1, true) then return held, true end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil, false end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.ToolTip or "", keyword, 1, true) then return tool, false end
    end
    return nil, false
end

local function equipWeapon(keyword)
    if not keyword or not Character then return end
    local tool, alreadyEquipped = findWeapon(keyword)
    if alreadyEquipped or not tool then return end
    if Humanoid then Humanoid:EquipTool(tool) end
end

local function noclipEnemy(enemy)
    if not enemy or not enemy.Parent then return end
    for _, p in ipairs(enemy:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then
            pcall(function() p.CanCollide = false end)
        end
    end
end

local function getOffsetCF(enemyCF)
    return enemyCF * CFrame.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 25, CFG.OFFSET_Z or 0)
end

local function startAutoNear()
    if Conns.follow then Conns.follow:Disconnect() end
    local prevEnemy = nil
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then State.currentFlyCF = hrp.CFrame end
    startPositionLock()
    Conns.follow = RunService.Heartbeat:Connect(function(dt)
        if not State.autoNearEnabled then
            if Conns.follow then Conns.follow:Disconnect(); Conns.follow = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            return
        end
        if not updateCharacter() then return end
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hrp.Parent then return end
        if not hum or not hum.Health or hum.Health <= 0 then
            stopFastAttack()
            State.currentEnemy = nil; State.trackedRoot = nil; prevEnemy = nil; State.currentFlyCF = nil
            return
        end
        HRP = hrp; Humanoid = hum; Character = c
        pcall(function() if Humanoid then Humanoid.AutoRotate = false end end)
        equipWeapon(State.selectedWeaponType)

        local enemyHum  = State.currentEnemy and State.currentEnemy:FindFirstChildOfClass("Humanoid")
        local enemyRoot = State.currentEnemy and State.currentEnemy:FindFirstChild("HumanoidRootPart")
        if not State.currentEnemy or not enemyRoot or not enemyRoot.Parent or not enemyHum or not enemyHum.Health or enemyHum.Health <= 0 then
            stopFastAttack()
            State.trackedRoot = nil; State.currentEnemy = getClosestEnemy(); prevEnemy = nil
            if not State.currentEnemy then
                local worldOrigin = Workspace:FindFirstChild("_WorldOrigin")
                local spawnsFolder = worldOrigin and worldOrigin:FindFirstChild("EnemySpawns")
                if not spawnsFolder then return end
                local bestPos, bestDist = nil, math.huge
                for _, part in ipairs(spawnsFolder:GetChildren()) do
                    local pos = nil
                    if part:IsA("BasePart") then
                        pos = part.Position
                    elseif part:IsA("Model") then
                        local root = part:FindFirstChild("HumanoidRootPart") or part.PrimaryPart
                        if root then pos = root.Position end
                    end
                    if pos then
                        local dist = (hrp.Position - pos).Magnitude
                        if dist < bestDist then bestDist = dist; bestPos = pos end
                    end
                end
                if bestPos then
                    tryFarmBypass(bestPos)
                    local targetCF = CFrame.new(bestPos + Vector3.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 25, CFG.OFFSET_Z or 0))
                    local dist = (targetCF.Position - hrp.Position).Magnitude
                    if dist > (CFG.REACH or 6) then moveToTarget(hrp, targetCF, dt) end
                end
                return
            end
            State.trackedRoot = getEnemyRoot(State.currentEnemy)
        end
        if not State.trackedRoot or not State.trackedRoot.Parent then
            State.trackedRoot = getEnemyRoot(State.currentEnemy)
            if not State.trackedRoot then return end
        end

        local target        = State.currentEnemy
        local enemyLiveRoot = State.trackedRoot
        if not enemyLiveRoot or not enemyLiveRoot.Parent then return end

        local enemyCF  = enemyLiveRoot.CFrame
        local enemyPos = enemyCF.Position

        lockAndBringMobs(target, enemyPos)
        noclipEnemy(target)

        local targetCF = getOffsetCF(enemyCF)
        local dist     = (targetCF.Position - hrp.Position).Magnitude

        if dist > (CFG.REACH or 6) then
            stopFastAttack(); prevEnemy = nil
            tryFarmBypass(targetCF.Position)
            moveToTarget(hrp, targetCF, dt)
        else
            local liveCF  = enemyLiveRoot.CFrame
            local finalCF = getOffsetCF(liveCF)

            State.currentFlyCF = finalCF
            pcall(function()
                hrp.CFrame = finalCF
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end)
            if State.currentEnemy ~= prevEnemy then
                prevEnemy = State.currentEnemy
                FastAttackModule.Enabled = true
                startFastAttack(); startHitRegistration()
            end
        end
    end)
end

local function startAutoFarm()
    if Conns.farm then Conns.farm:Disconnect() end
    local prevEnemy = nil
    local spawnIdx  = 1
    if HRP then State.currentFlyCF = HRP.CFrame end
    startPositionLock()
    Conns.farm = RunService.Heartbeat:Connect(function(dt)
        if not State.autoFarmEnabled then
            if Conns.farm then Conns.farm:Disconnect(); Conns.farm = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            return
        end
        if not updateCharacter() then return end
        local activeList = updateSelectedMonstersList()
        if #activeList == 0 then return end
        equipWeapon(State.selectedWeaponType)

        local target, targetMonsterName = findPriorityEnemy(activeList)
        if target and targetMonsterName then
            local enemyHum  = target:FindFirstChildOfClass("Humanoid")
            local enemyRoot = target:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyRoot.Parent or not enemyHum or not enemyHum.Health or enemyHum.Health <= 0 then
                State.trackedRoot = nil; State.currentEnemy = nil; return
            end
            if State.currentEnemy ~= target then
                if State.currentEnemy then smoothCleanAll() end
                State.currentEnemy = target; State.trackedRoot = nil
            end
            if State.trackedRoot == nil or State.trackedRoot.Parent == nil or not target:IsAncestorOf(State.trackedRoot) then
                State.trackedRoot = getEnemyRoot(target)
            end
            if not State.trackedRoot then return end

            local enemyLiveRoot = State.trackedRoot
            if not enemyLiveRoot or not enemyLiveRoot.Parent then return end

            local enemyCF  = enemyLiveRoot.CFrame
            local enemyPos = enemyCF.Position

            lockAndBringMobs(target, enemyPos)
            noclipEnemy(target)

            local targetCF = getOffsetCF(enemyCF)
            local hrpPos   = HRP and HRP.Position or targetCF.Position
            local dist     = (targetCF.Position - hrpPos).Magnitude

            if dist > (CFG.REACH or 6) then
                stopFastAttack(); prevEnemy = nil
                tryFarmBypass(targetCF.Position)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                local liveCF  = enemyLiveRoot.CFrame
                local finalCF = getOffsetCF(liveCF)

                State.currentFlyCF = finalCF
                pcall(function()
                    if HRP then
                        HRP.CFrame = finalCF
                        HRP.AssemblyLinearVelocity  = Vector3.zero
                        HRP.AssemblyAngularVelocity = Vector3.zero
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                end)
                if target ~= prevEnemy then
                    prevEnemy = target
                    FastAttackModule.Enabled = true
                    startFastAttack(); startHitRegistration()
                end
            end
        else
            stopFastAttack(); stopHitRegistration()
            prevEnemy = nil; State.currentEnemy = nil; State.trackedRoot = nil; smoothCleanAll()

            local allSpawns = {}
            local spawnsFolder = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
            if spawnsFolder then
                for _, monName in ipairs(activeList) do
                    for _, part in ipairs(spawnsFolder:GetChildren()) do
                        if part:IsA("BasePart") and cleanMonsterName(part.Name) == monName then
                            local dup = false
                            for _, existing in ipairs(allSpawns) do
                                if (existing.pos - part.Position).Magnitude < 5 then dup = true; break end
                            end
                            if not dup then
                                table.insert(allSpawns, { pos = part.Position, name = monName })
                            end
                        end
                    end
                end
            end

            if #allSpawns == 0 then return end
            if spawnIdx > #allSpawns then spawnIdx = 1 end

            local currentSpawn = allSpawns[spawnIdx]
            local spawnPos = currentSpawn.pos + Vector3.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 25, CFG.OFFSET_Z or 0)
            local targetCF = CFrame.new(spawnPos)
            local currentPos = (State.currentFlyCF and State.currentFlyCF.Position) or (HRP and HRP.Position)
            local dist = currentPos and (spawnPos - currentPos).Magnitude or math.huge

            if dist > (CFG.REACH or 6) then
                State.bossWaitTick = nil
                tryFarmBypass(spawnPos)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                if not State.bossWaitTick then
                    State.bossWaitTick = tick()
                    Library:Notify({
                        Title = "Auto Farm",
                        Description = "Waiting at " .. currentSpawn.name .. " spawn...",
                        Time = 3,
                    })
                elseif tick() - State.bossWaitTick >= 3 then
                    State.bossWaitTick = nil
                    spawnIdx = (spawnIdx % #allSpawns) + 1
                end
            end
        end
    end)
end

local function startAutoBoss()
    if Conns.boss then Conns.boss:Disconnect() end
    local prevEnemy   = nil
    State.bossSpawnIdx = 1
    if HRP then State.currentFlyCF = HRP.CFrame end
    startPositionLock()

    Conns.boss = RunService.Heartbeat:Connect(function(dt)
        if not State.autoBossEnabled then
            if Conns.boss then Conns.boss:Disconnect(); Conns.boss = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            return
        end
        if not updateCharacter() then return end

        local activeList = updateSelectedBossesList()
        if #activeList == 0 then return end
        equipWeapon(State.selectedWeaponType)

        local target, targetBossName = findBossByPriority(activeList)

        if target and targetBossName then
            State.bossWaitTick = nil
            local enemyHum  = target:FindFirstChildOfClass("Humanoid")
            local enemyRoot = target:FindFirstChild("HumanoidRootPart")

            if not enemyRoot or not enemyRoot.Parent or not enemyHum or not enemyHum.Health or enemyHum.Health <= 0 then
                State.trackedRoot = nil; State.currentEnemy = nil; return
            end

            if State.currentEnemy ~= target then
                if State.currentEnemy then smoothCleanAll() end
                State.currentEnemy = target
                State.trackedRoot  = nil
                Library:Notify({
                    Title = "Auto Boss",
                    Description = "Now targeting: " .. targetBossName,
                    Time = 3,
                })
            end

            if State.trackedRoot == nil or State.trackedRoot.Parent == nil or not target:IsAncestorOf(State.trackedRoot) then
                State.trackedRoot = getEnemyRoot(target)
            end
            if not State.trackedRoot then return end

            local bossHum = target:FindFirstChildOfClass("Humanoid")
            if bossHum and bossHum.Health and bossHum.Health <= 0 then
                Library:Notify({
                    Title = "Auto Boss",
                    Description = targetBossName .. " is dead, switching target...",
                    Time = 3,
                })
                State.currentEnemy = nil
                State.trackedRoot  = nil
                smoothCleanAll()
                return
            end

            local enemyLiveRoot = State.trackedRoot
            if not enemyLiveRoot or not enemyLiveRoot.Parent then return end

            local enemyCF  = enemyLiveRoot.CFrame
            local enemyPos = enemyCF.Position

            lockAndBringMobs(target, enemyPos)
            noclipEnemy(target)

            local targetCF = getOffsetCF(enemyCF)
            local hrpPos   = HRP and HRP.Position or targetCF.Position
            local dist     = (targetCF.Position - hrpPos).Magnitude

            if dist > (CFG.REACH or 6) then
                stopFastAttack(); stopHitRegistration(); prevEnemy = nil
                tryFarmBypass(targetCF.Position)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                local liveCF  = enemyLiveRoot.CFrame
                local finalCF = getOffsetCF(liveCF)

                State.currentFlyCF = finalCF
                pcall(function()
                    if HRP then
                        HRP.CFrame = finalCF
                        HRP.AssemblyLinearVelocity  = Vector3.zero
                        HRP.AssemblyAngularVelocity = Vector3.zero
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                end)
                if target ~= prevEnemy then
                    prevEnemy = target
                    FastAttackModule.Enabled = true
                    startFastAttack(); startHitRegistration()
                end
            end
        else
            stopFastAttack(); stopHitRegistration()
            prevEnemy = nil; State.currentEnemy = nil; State.trackedRoot = nil; smoothCleanAll()

            local allSpawns = {}
            local spawnsFolder = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
            if spawnsFolder then
                for _, bossName in ipairs(activeList) do
                    for _, part in ipairs(spawnsFolder:GetChildren()) do
                        if part:IsA("BasePart") and cleanMonsterName(part.Name) == bossName then
                            local dup = false
                            for _, existing in ipairs(allSpawns) do
                                if (existing.pos - part.Position).Magnitude < 5 then dup = true; break end
                            end
                            if not dup then
                                table.insert(allSpawns, { pos = part.Position, name = bossName })
                            end
                        end
                    end
                end
            end

            if #allSpawns == 0 then return end
            if State.bossSpawnIdx > #allSpawns then State.bossSpawnIdx = 1 end

            local currentSpawn = allSpawns[State.bossSpawnIdx]
            local spawnPos = currentSpawn.pos + Vector3.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 25, CFG.OFFSET_Z or 0)
            local targetCF = CFrame.new(spawnPos)
            local currentPos = (State.currentFlyCF and State.currentFlyCF.Position) or (HRP and HRP.Position)
            local dist = currentPos and (spawnPos - currentPos).Magnitude or math.huge

            if dist > (CFG.REACH or 6) then
                State.bossWaitTick = nil
                tryFarmBypass(spawnPos)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                if not State.bossWaitTick then
                    State.bossWaitTick = tick()
                elseif tick() - State.bossWaitTick >= 5 then
                    State.bossWaitTick = nil
                    State.bossSpawnIdx = (State.bossSpawnIdx % #allSpawns) + 1
                end
            end
        end
    end)
end

local function stopTeleportTween()
    if Conns.teleport then Conns.teleport:Disconnect(); Conns.teleport = nil end
    if not (State.autoNearEnabled or State.autoFarmEnabled or State.autoBossEnabled) then stopPositionLock(); stopNoclip() end
end

local function startTeleportTween()
    stopTeleportTween()
    if not State.selectedIslandPos then return end
    if HRP then State.currentFlyCF = HRP.CFrame end
    startNoclip(); startPositionLock()

    task.spawn(function()
        requestentrance(State.selectedIslandPos)
    end)

    Conns.teleport = RunService.Heartbeat:Connect(function(dt)
        if not State.teleportTweenEnabled then stopTeleportTween(); return end
        if not updateCharacter() then return end
        if not State.selectedIslandPos then return end
        if not HRP or not HRP.Parent then return end
        local targetCF   = CFrame.new(State.selectedIslandPos)
        local currentPos = State.currentFlyCF and State.currentFlyCF.Position or HRP.Position
        local dist       = (State.selectedIslandPos - currentPos).Magnitude
        if dist > (CFG.REACH or 6) then
            moveToTarget(HRP, targetCF, dt)
        else
            State.currentFlyCF = targetCF
            pcall(function()
                HRP.CFrame = targetCF
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
            end)
            task.spawn(function()
                requestentrance(State.selectedIslandPos)
            end)
            if Toggles and Toggles.TweenToIsland then
                Toggles.TweenToIsland:SetValue(false)
            end
            Library:Notify({ Title = "Teleport", Description = "Arrived at " .. tostring(State.selectedIslandName), Time = 3 })
        end
    end)
end

local function stopBypassTp()
    State.bypassTpEnabled = false
    State.bypassMoving = false
    if Conns.bypassTp then Conns.bypassTp:Disconnect(); Conns.bypassTp = nil end
    stopPositionLock()
    stopNoclip()
    if State.autoNearEnabled then
        startNoclip(); startAutoNear()
    elseif State.autoFarmEnabled then
        startNoclip(); startAutoFarm()
    elseif State.autoBossEnabled then
        startNoclip(); startAutoBoss()
    elseif State.teleportTweenEnabled then
        startNoclip(); startTeleportTween()
    end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.AutoRotate = true
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hrp then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    State.currentFlyCF = nil
end

local function startBypassTp()
    if bypassTpArrived then return end
    stopBypassTp()
    if not State.selectedIslandPos then return end
    State.bypassTpEnabled = true
    State.bypassMoving = true

    task.spawn(function()
        if not State.bypassTpEnabled then State.bypassMoving = false; return end
        pcall(function()
            local c = LocalPlayer.Character
            if not c then return end
            local h  = c:FindFirstChild("HumanoidRootPart")
            local hm = c:FindFirstChildOfClass("Humanoid")
            if not h or not hm or not hm.Health or hm.Health <= 0 then return end
            if not State.bypassTpEnabled then return end

            requestentrance(State.selectedIslandPos)
            task.wait(0.5)

            if CanBypassTeleport(CFrame.new(State.selectedIslandPos)) then
                BypassTP(CFrame.new(State.selectedIslandPos))
                task.wait(0.5)
            end
            if not State.bypassTpEnabled then return end
            requestentrance(State.selectedIslandPos)
        end)
        if not State.bypassTpEnabled then State.bypassMoving = false; return end
        local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = c:WaitForChild("HumanoidRootPart", 5)
        if hrp then State.currentFlyCF = hrp.CFrame end
        if not State.bypassTpEnabled then State.bypassMoving = false; return end
        startNoclip()
        startPositionLock()
        State.bypassMoving = false
        if not State.bypassTpEnabled then
            stopNoclip(); stopPositionLock(); return
        end
        Conns.bypassTp = RunService.Heartbeat:Connect(function(dt)
            if not State.bypassTpEnabled then
                stopBypassTp(); return
            end
            if not updateCharacter() then return end
            if not State.selectedIslandPos then return end
            if not HRP or not HRP.Parent then return end
            if not State.currentFlyCF or (State.currentFlyCF.Position - HRP.Position).Magnitude > 50 then
                State.currentFlyCF = HRP.CFrame
            end
            local targetCF   = CFrame.new(State.selectedIslandPos)
            local currentPos = State.currentFlyCF.Position
            local dist       = (State.selectedIslandPos - currentPos).Magnitude
            if dist > (CFG.REACH or 6) then
                moveToTarget(HRP, targetCF, math.min(dt, 0.05))
            else
                bypassTpArrived = true
                State.currentFlyCF = targetCF
                pcall(function()
                    HRP.CFrame = targetCF
                    HRP.AssemblyLinearVelocity  = Vector3.zero
                    HRP.AssemblyAngularVelocity = Vector3.zero
                end)
                requestentrance(State.selectedIslandPos)
                stopBypassTp()
                pcall(function()
                    if Toggles and Toggles.BypassTeleport then
                        Toggles.BypassTeleport:SetValue(false)
                    end
                end)
                Library:Notify({ Title = "Bypass Teleport", Description = "Arrived at " .. tostring(State.selectedIslandName), Time = 3 })
                task.delay(2, function() bypassTpArrived = false end)
            end
        end)
    end)
end

local function checkIsMyBoat(boat)
    if not boat then return false end
    local owner = boat:FindFirstChild("Owner")
    if owner then
        if owner:IsA("StringValue") or owner:IsA("ObjectValue") then
            if tostring(owner.Value) == LocalPlayer.Name or owner.Value == LocalPlayer then
                return true
            end
        elseif tostring(owner) == LocalPlayer.Name then
            return true
        end
    end
    if boat:GetAttribute("Owner") == LocalPlayer.Name then return true end
    local seat = boat:FindFirstChild("VehicleSeat") or boat:FindFirstChildOfClass("VehicleSeat")
    if seat and seat.Occupant and seat.Occupant.Parent == LocalPlayer.Character then return true end
    return false
end

local function applyBoatSpeed()
    local boatsFolder = workspace:FindFirstChild("Boats")
    if not boatsFolder then return end
    for _, boat in ipairs(boatsFolder:GetChildren()) do
        local seat = boat:FindFirstChild("VehicleSeat") or boat:FindFirstChildOfClass("VehicleSeat")
        if seat and seat:IsA("VehicleSeat") then
            local isMine = checkIsMyBoat(boat)
            local shouldApply = false
            if State.boatTargetMode == "All" then shouldApply = true
            elseif isMine then shouldApply = true end
            if shouldApply then
                if not Lists.defaultBoatSpeeds[seat] then
                    Lists.defaultBoatSpeeds[seat] = seat.MaxSpeed
                end
                seat.MaxSpeed = State.boatSpeedValue
            end
        end
    end
end

local function restoreBoatSpeed()
    for seat, originalSpeed in pairs(Lists.defaultBoatSpeeds) do
        if seat and seat.Parent then
            pcall(function() seat.MaxSpeed = originalSpeed end)
        end
    end
    Lists.defaultBoatSpeeds = {}
end

local function startBoatNoclip()
    if Conns.boatNoclip then Conns.boatNoclip:Disconnect() end
    Conns.boatNoclip = RunService.Stepped:Connect(function()
        if not State.boatNoclipEnabled then
            if Conns.boatNoclip then Conns.boatNoclip:Disconnect(); Conns.boatNoclip = nil end
            return
        end
        local boatsFolder = workspace:FindFirstChild("Boats")
        if not boatsFolder then return end
        for _, boat in ipairs(boatsFolder:GetChildren()) do
            local isMine = checkIsMyBoat(boat)
            local shouldNoclip = false
            if State.boatTargetMode == "All" then shouldNoclip = true
            elseif isMine then shouldNoclip = true end
            if shouldNoclip then
                for _, part in ipairs(boat:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

local function stopBoatNoclip()
    State.boatNoclipEnabled = false
    if Conns.boatNoclip then Conns.boatNoclip:Disconnect(); Conns.boatNoclip = nil end
    pcall(function()
        local boatsFolder = workspace:FindFirstChild("Boats")
        if not boatsFolder then return end
        for _, boat in ipairs(boatsFolder:GetChildren()) do
            for _, part in ipairs(boat:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(function()
            if T("BoatSpeed") then applyBoatSpeed() end
        end)
    end
end)

local function startPlayerNoclip()
    if Conns.playerNoclip then Conns.playerNoclip:Disconnect() end
    Conns.playerNoclip = RunService.Stepped:Connect(function()
        if not State.playerNoclipEnabled then
            if Conns.playerNoclip then Conns.playerNoclip:Disconnect(); Conns.playerNoclip = nil end
            return
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end)
end

local function stopPlayerNoclip()
    State.playerNoclipEnabled = false
    if Conns.playerNoclip then Conns.playerNoclip:Disconnect(); Conns.playerNoclip = nil end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
end

local function round(n) return math.floor(tonumber(n) + 0.5) end
local function getMyHeadPos()
    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    return head and head.Position or nil
end

local EspPly = function()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    for _, v in next, Players:GetChildren() do
        pcall(function()
            if not v or v == LocalPlayer then return end
            if not v.Character then return end
            local theirHead = v.Character:FindFirstChild("Head")
            if not theirHead then return end
            if ESP.Player then
                local distText = round((myHeadPos - theirHead.Position).Magnitude/3) ..' M'
                if not theirHead:FindFirstChild('NameEsp'..ESP.Number) then
                    local bill = Instance.new('BillboardGui', theirHead)
                    bill.Name = 'NameEsp'..ESP.Number
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size = UDim2.new(1, 200, 1, 30)
                    bill.Adornee = theirHead
                    bill.AlwaysOnTop = true
                    local name = Instance.new('TextLabel', bill)
                    name.Font = Enum.Font.Code
                    name.FontSize = "Size14"
                    name.TextWrapped = true
                    name.Text = (v.Name ..' \n'.. distText)
                    name.Size = UDim2.new(1, 0, 1, 0)
                    name.TextYAlignment = 'Top'
                    name.BackgroundTransparency = 1
                    name.TextStrokeTransparency = 0.5
                    if v.Team == LocalPlayer.Team then
                        name.TextColor3 = Color3.new(0, 0, 254)
                    else
                        name.TextColor3 = Color3.new(255, 0, 0)
                    end
                else
                    local existing = theirHead:FindFirstChild('NameEsp'..ESP.Number)
                    if existing and existing:FindFirstChild("TextLabel") then
                        local theirHum = v.Character:FindFirstChildOfClass("Humanoid")
                        local hpText = "N/A"
                        if theirHum and theirHum.MaxHealth and theirHum.MaxHealth > 0 then
                            hpText = round(theirHum.Health*100/theirHum.MaxHealth) .. '%'
                        end
                        existing.TextLabel.Text = (v.Name ..' | '.. distText ..'\nHP: ' .. hpText)
                    end
                end
            else
                local existing = theirHead:FindFirstChild('NameEsp'..ESP.Number)
                if existing then existing:Destroy() end
            end
        end)
    end
end

local DevEsp = function()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    for _, v in next, workspace:GetChildren() do
        pcall(function()
            if ESP.DevilFruit then
                if string.find(v.Name, "Fruit") and v:FindFirstChild("Handle") then
                    local distText = round((myHeadPos - v.Handle.Position).Magnitude/3) ..' M'
                    if not v.Handle:FindFirstChild('NameEsp'..ESP.Number) then
                        local bill = Instance.new('BillboardGui', v.Handle)
                        bill.Name = 'NameEsp'..ESP.Number
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(1, 200, 1, 30)
                        bill.Adornee = v.Handle
                        bill.AlwaysOnTop = true
                        local name = Instance.new('TextLabel', bill)
                        name.Font = Enum.Font.Code
                        name.FontSize = "Size14"
                        name.TextWrapped = true
                        name.Size = UDim2.new(1, 0, 1, 0)
                        name.TextYAlignment = 'Top'
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(255, 255, 255)
                        name.Text = (v.Name ..' \n'.. distText)
                    else
                        v.Handle['NameEsp'..ESP.Number].TextLabel.Text = ('[' ..v.Name ..']' ..'   \n'.. distText)
                    end
                end
            else
                if v:FindFirstChild('Handle') and v.Handle:FindFirstChild('NameEsp'..ESP.Number) then
                    v.Handle:FindFirstChild('NameEsp'..ESP.Number):Destroy()
                end
            end
        end)
    end
end

local LocationEsp = function()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
    local locs = worldOrigin and worldOrigin:FindFirstChild("Locations")
    if not locs then return end
    for _, v in next, locs:GetChildren() do
        pcall(function()
            if ESP.Island then
                if v.Name ~= "Sea" then
                    local distText = round((myHeadPos - v.Position).Magnitude/3) ..' M'
                    if not v:FindFirstChild('NameEsp') then
                        local bill = Instance.new('BillboardGui', v)
                        bill.Name = 'NameEsp'
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(1, 200, 1, 30)
                        bill.Adornee = v
                        bill.AlwaysOnTop = true
                        local name = Instance.new('TextLabel', bill)
                        name.Font = Enum.Font.Code
                        name.FontSize = "Size14"
                        name.TextWrapped = true
                        name.Size = UDim2.new(1, 0, 1, 0)
                        name.TextYAlignment = 'Top'
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(98, 252, 252)
                        name.Text = (v.Name ..'   \n'.. distText)
                    else
                        v['NameEsp'].TextLabel.Text = (v.Name ..'   \n'.. distText)
                    end
                end
            else
                if v:FindFirstChild('NameEsp') then v:FindFirstChild('NameEsp'):Destroy() end
            end
        end)
    end
end

local flowerEsp = function()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    for _, v in pairs(workspace:GetChildren()) do
        pcall(function()
            if v.Name == "Flower2" or v.Name == "Flower1" then
                if ESP.Flower then
                    local distText = round((myHeadPos - v.Position).Magnitude/3) ..' M'
                    if not v:FindFirstChild('NameEsp'..ESP.Number) then
                        local bill = Instance.new('BillboardGui', v)
                        bill.Name = 'NameEsp'..ESP.Number
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(1, 200, 1, 30)
                        bill.Adornee = v
                        bill.AlwaysOnTop = true
                        local name = Instance.new('TextLabel', bill)
                        name.Font = Enum.Font.Code
                        name.FontSize = "Size14"
                        name.TextWrapped = true
                        name.Size = UDim2.new(1, 0, 1, 0)
                        name.TextYAlignment = 'Top'
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(88, 214, 252)
                        if v.Name == "Flower1" then
                            name.Text = ("Blue Flower\n" .. distText)
                        elseif v.Name == "Flower2" then
                            name.Text = ("Red Flower\n" .. distText)
                        end
                    else
                        v['NameEsp'..ESP.Number].TextLabel.Text = (v.Name ..'   \n'.. distText)
                    end
                else
                    if v:FindFirstChild('NameEsp'..ESP.Number) then
                        v:FindFirstChild('NameEsp'..ESP.Number):Destroy()
                    end
                end
            end
        end)
    end
end

local ChestEsp = function()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    if ESP.Chest then
        local CollectionService = game:GetService("CollectionService")
        local Chests = CollectionService:GetTagged("_ChestTagged")
        for _, Chest in ipairs(Chests) do
            pcall(function()
                local chestPos = Chest:GetPivot().Position
                local distanceMagnitude = (chestPos - myHeadPos).Magnitude
                local existingEsp = Chest:FindFirstChild("ChestEspAttachment")
                if not existingEsp then
                    local attachment = Instance.new("Attachment")
                    attachment.Name = "ChestEspAttachment"
                    attachment.Parent = Chest
                    attachment.Position = Vector3.new(0, 3, 0)
                    local nameEsp = Instance.new("BillboardGui")
                    nameEsp.Name = "NameEsp"
                    nameEsp.Size = UDim2.new(0, 200, 0, 30)
                    nameEsp.Adornee = attachment
                    nameEsp.ExtentsOffset = Vector3.new(0, 1, 0)
                    nameEsp.AlwaysOnTop = true
                    nameEsp.Parent = attachment
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Font = Enum.Font.Code
                    nameLabel.TextSize = 14
                    nameLabel.TextWrapped = true
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.TextYAlignment = Enum.TextYAlignment.Top
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextStrokeTransparency = 0.5
                    nameLabel.TextColor3 = Color3.fromRGB(80, 245, 245)
                    nameLabel.Parent = nameEsp
                end
                local nameEsp = existingEsp and existingEsp:FindFirstChild("NameEsp")
                if nameEsp then
                    local displayDistance = math.floor(distanceMagnitude / 3)
                    nameEsp.TextLabel.Text = string.format("[%s] %d M", Chest.Name:gsub("Label", ""), displayDistance)
                end
            end)
        end
    else
        for _, Chest in ipairs(game:GetService("CollectionService"):GetTagged("_ChestTagged")) do
            local espAttachment = Chest:FindFirstChild("ChestEspAttachment")
            if espAttachment then espAttachment:Destroy() end
        end
    end
end

local EventIslandEsp = function()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
    local locs = worldOrigin and worldOrigin:FindFirstChild("Locations")
    if not locs then return end
    for _, v in pairs(locs:GetChildren()) do
        pcall(function()
            if ESP.EventIsland then
                if v.Name == "Mirage Island" or v.Name == "Prehistoric Island" or v.Name == "Kitsune Island" then
                    local distText = round((myHeadPos - v.Position).Magnitude / 3) .. " M"
                    if not v:FindFirstChild("NameEsp") then
                        local bill = Instance.new("BillboardGui", v)
                        bill.Name = "NameEsp"; bill.ExtentsOffset = Vector3.new(0,1,0)
                        bill.Size = UDim2.new(1,200,1,30); bill.Adornee = v; bill.AlwaysOnTop = true
                        local name = Instance.new("TextLabel", bill)
                        name.Font = "Code"; name.FontSize = "Size14"; name.TextWrapped = true
                        name.Size = UDim2.new(1,0,1,0); name.TextYAlignment = "Top"
                        name.BackgroundTransparency = 1; name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(80, 245, 245)
                        name.Text = (v.Name .. "   \n" .. distText)
                    else
                        v.NameEsp.TextLabel.Text = v.Name .. "   \n" .. distText
                    end
                end
            else
                if v:FindFirstChild("NameEsp") then v:FindFirstChild("NameEsp"):Destroy() end
            end
        end)
    end
end

local LegenSword = function()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    if ESP.LegenSword then
        local npcs = ReplicatedStorage:FindFirstChild("NPCs")
        if not npcs then return end
        for _, v in pairs(npcs:GetChildren()) do
            if v.Name == "Legendary Sword Dealer" and v:FindFirstChild("HumanoidRootPart") then
                local distText = round((myHeadPos - v.HumanoidRootPart.Position).Magnitude / 3) .. " M"
                if not workspace:FindFirstChild("LgdKKKK") then
                    local Lgd = Instance.new("Part")
                    Lgd.Name = "LgdKKKK"; Lgd.Transparency = 1; Lgd.Size = Vector3.new(1,1,1)
                    Lgd.Anchored = true; Lgd.CanCollide = false; Lgd.Parent = workspace
                    Lgd.CFrame = v.HumanoidRootPart.CFrame
                elseif workspace:FindFirstChild("LgdKKKK") then
                    local Lgd = workspace.LgdKKKK
                    if not Lgd:FindFirstChild("NameEsp") then
                        local bill = Instance.new("BillboardGui", Lgd)
                        bill.Name = "NameEsp"; bill.ExtentsOffset = Vector3.new(0,1,0)
                        bill.Size = UDim2.new(1,200,1,30); bill.Adornee = Lgd; bill.AlwaysOnTop = true
                        local name = Instance.new("TextLabel", bill)
                        name.Font = "Code"; name.FontSize = "Size14"; name.TextWrapped = true
                        name.Size = UDim2.new(1,0,1,0); name.TextYAlignment = "Top"
                        name.BackgroundTransparency = 1; name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(80, 245, 245)
                        name.Text = (v.Name .."   \n" .. distText)
                    else
                        Lgd["NameEsp"].TextLabel.Text = (v.Name .."   \n" .. distText)
                    end
                end
            end
        end
    else
        if workspace:FindFirstChild("LgdKKKK") then workspace.LgdKKKK:Destroy() end
    end
end

local berriesEsp = function()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    if ESP.Berry then
        local CollectionService = game:GetService("CollectionService")
        local BerryBushes = CollectionService:GetTagged("BerryBush")
        local activeEspSet = {}
        for _, Bush in ipairs(BerryBushes) do
            pcall(function()
                if not Bush or not Bush.Parent then return end
                local bushPosition = Bush:IsA("Model") and Bush:GetPivot().Position
                    or (Bush:IsA("BasePart") and Bush.Position or (Bush.Parent and Bush.Parent:GetPivot().Position))
                if not bushPosition then return end
                local hasBerry = false
                local berryNameFound = nil
                local attrs = Bush:GetAttributes()
                for _, attrVal in pairs(attrs) do
                    if attrVal and tostring(attrVal) ~= "" then
                        hasBerry = true
                        berryNameFound = tostring(attrVal)
                        break
                    end
                end
                local espPartName = "BerryEspKKKK_" .. tostring(math.floor(bushPosition.X)) .. "_" .. tostring(math.floor(bushPosition.Z))
                if hasBerry and berryNameFound then
                    activeEspSet[espPartName] = true
                    local existingEsp = workspace:FindFirstChild(espPartName)
                    if not existingEsp then
                        existingEsp = Instance.new("Part")
                        existingEsp.Name = espPartName
                        existingEsp.Transparency = 1
                        existingEsp.Size = Vector3.new(1, 1, 1)
                        existingEsp.Anchored = true
                        existingEsp.CanCollide = false
                        existingEsp.Parent = workspace
                        existingEsp.CFrame = CFrame.new(bushPosition)
                    else
                        existingEsp.CFrame = CFrame.new(bushPosition)
                    end
                    local nameEsp = existingEsp:FindFirstChild("NameEsp")
                    if not nameEsp then
                        nameEsp = Instance.new("BillboardGui", existingEsp)
                        nameEsp.Name = "NameEsp"
                        nameEsp.ExtentsOffset = Vector3.new(0, 1, 0)
                        nameEsp.Size = UDim2.new(0, 200, 0, 30)
                        nameEsp.Adornee = existingEsp
                        nameEsp.AlwaysOnTop = true
                        local nameLabel = Instance.new("TextLabel", nameEsp)
                        nameLabel.Font = Enum.Font.Code
                        nameLabel.TextSize = 14
                        nameLabel.TextWrapped = true
                        nameLabel.Size = UDim2.new(1, 0, 1, 0)
                        nameLabel.TextYAlignment = Enum.TextYAlignment.Top
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.TextColor3 = Color3.fromRGB(80, 245, 245)
                    end
                    local distance = (myHeadPos - bushPosition).Magnitude / 3
                    local label = nameEsp:FindFirstChildOfClass("TextLabel")
                    if label then
                        label.Text = string.format("[%s] %d M", berryNameFound, math.floor(distance))
                    end
                else
                    local existingEsp = workspace:FindFirstChild(espPartName)
                    if existingEsp then existingEsp:Destroy() end
                end
            end)
        end
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name:match("^BerryEspKKKK_") then
                if not activeEspSet[v.Name] then v:Destroy() end
            end
        end
    else
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name:match("^BerryEspKKKK_") then v:Destroy() end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if ESP.Player      then EspPly()        end
            if ESP.DevilFruit  then DevEsp()         end
            if ESP.Island      then LocationEsp()    end
            if ESP.Flower      then flowerEsp()      end
            if ESP.Chest       then ChestEsp()       end
            if ESP.EventIsland then EventIslandEsp() end
            if ESP.LegenSword  then LegenSword()     end
            if ESP.Berry       then berriesEsp()     end
        end)
    end
end)

local function statsSetings(Num, value)
    local data = LocalPlayer:FindFirstChild("Data")
    if not data then return end
    local points = data:FindFirstChild("Points")
    if not points or not points:IsA("ValueBase") or points.Value <= 0 then return end
    local statMap = {
        Melee   = "Melee",
        Defense = "Defense",
        Sword   = "Sword",
        Gun     = "Gun",
        Devil   = "Demon Fruit",
    }
    local statName = statMap[Num]
    if statName then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", statName, value)
    end
end

scanAllMonsters()
refreshBossDropdown()
startHitRegistration()

local initialMonsterList = #Lists.masterMonsterList > 0 and Lists.masterMonsterList or {"(No monster found)"}
local initialBossList    = #Lists.masterBossList > 0 and Lists.masterBossList or {"(No Boss found)"}

do
    local InfoLeft   = Tabs.Info:AddLeftGroupbox("Server Status")
    local InfoRight  = Tabs.Info:AddRightGroupbox("Event Status")

    local tzLabel    = InfoLeft:AddLabel("Time Zone: Loading...")
    local gtLabel    = InfoLeft:AddLabel("Game Time: Loading...")
    local mirLabel   = InfoLeft:AddLabel("Mirage Island: Checking...")
    local kitLabel   = InfoLeft:AddLabel("Kitsune Island: Checking...")
    local preLabel   = InfoLeft:AddLabel("Prehistoric Island: Checking...")
    local froLabel   = InfoLeft:AddLabel("Frozen Dimension: Checking...")
    local moonLabel  = InfoLeft:AddLabel("Full Moon: Checking...")
    local ripLabel   = InfoRight:AddLabel("Rip Indra: Checking...")
    local doughLabel = InfoRight:AddLabel("Dough King: Checking...")
    local lgdLabel   = InfoRight:AddLabel("Legendary Sword: Checking...")
    local boneLabel  = InfoRight:AddLabel("Bones: Checking...")
    local cakeLabel  = InfoRight:AddLabel("Cake Prince: Checking...")

    task.spawn(function()
        local LocalizationService = game:GetService("LocalizationService")
        local countryCode = "??"
        pcall(function() countryCode = LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer) end)
        while true do
            task.wait(1)
            pcall(function()
                if tzLabel and tzLabel.SetText then
                    local date = os.date("*t")
                    local hour = date.hour % 24
                    local ampm = hour < 12 and "AM" or "PM"
                    local h12 = ((hour - 1) % 12) + 1
                    tzLabel:SetText("TZ: " .. string.format("%02d/%02d/%04d", date.day, date.month, date.year) .. " " .. string.format("%02i:%02i:%02i %s", h12, date.min, date.sec, ampm) .. " [" .. countryCode .. "]")
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if gtLabel and gtLabel.SetText then
                    local t = math.floor(workspace.DistributedGameTime + 0.5)
                    gtLabel:SetText(string.format("Game Time: %dh %dm %ds", math.floor(t/3600)%24, math.floor(t/60)%60, t%60))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if mirLabel and mirLabel.SetText then
                    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
                    local spawned = locations and locations:FindFirstChild("Mirage Island")
                    mirLabel:SetText("Mirage Island: " .. (spawned and "✓ Spawned" or "✗ Not Found"))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if kitLabel and kitLabel.SetText then
                    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
                    local spawned = locations and locations:FindFirstChild("Kitsune Island")
                    kitLabel:SetText("Kitsune Island: " .. (spawned and "✓ Spawned" or "✗ Not Found"))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if preLabel and preLabel.SetText then
                    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
                    local spawned = locations and locations:FindFirstChild("Prehistoric Island")
                    preLabel:SetText("Prehistoric: " .. (spawned and "✓ Spawned" or "✗ Not Found"))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if froLabel and froLabel.SetText then
                    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
                    local spawned = locations and locations:FindFirstChild("Frozen Dimension")
                    froLabel:SetText("Frozen Dim: " .. (spawned and "✓ Spawned" or "✗ Not Found"))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function()
                if moonLabel and moonLabel.SetText then
                    if sea3 then
                        local sky = Lighting:FindFirstChildOfClass("Sky")
                        local moonId = sky and sky.MoonTextureId or ""
                        local moonStatus = "0/5"
                        if moonId:find("9709149431") then moonStatus = "5/5 ✓ Full Moon"
                        elseif moonId:find("9709149052") then moonStatus = "4/5"
                        elseif moonId:find("9709148705") then moonStatus = "3/5"
                        elseif moonId:find("9709148386") then moonStatus = "2/5"
                        elseif moonId:find("9709147983") then moonStatus = "1/5"
                        end
                        moonLabel:SetText("Moon: " .. moonStatus)
                    else
                        moonLabel:SetText("Moon: (Sea 3 only)")
                    end
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if ripLabel and ripLabel.SetText then
                    local exists = ReplicatedStorage:FindFirstChild("rip_indra True Form") ~= nil
                        or (workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("rip_indra") ~= nil)
                    ripLabel:SetText("Rip Indra: " .. (exists and "✓ Spawned" or "✗ Not Spawned"))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                if doughLabel and doughLabel.SetText then
                    local exists = ReplicatedStorage:FindFirstChild("Dough King") ~= nil
                        or (workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Dough King") ~= nil)
                    doughLabel:SetText("Dough King: " .. (exists and "✓ Spawned" or "✗ Not Spawned"))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(5)
            pcall(function()
                if lgdLabel and lgdLabel.SetText then
                    local s1 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")
                    local s2 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2")
                    local s3 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "3")
                    local result = (s1 and "Shisui " or "") .. (s2 and "Wando " or "") .. (s3 and "Saddi" or "")
                    lgdLabel:SetText("Lgd Sword: " .. (result ~= "" and result or "Not Found"))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(3)
            pcall(function()
                if boneLabel and boneLabel.SetText then
                    local bones = ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check")
                    boneLabel:SetText("Bones: " .. tostring(bones or 0))
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(3)
            pcall(function()
                if cakeLabel and cakeLabel.SetText then
                    local res = ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                    local killed = type(res) == "string" and tonumber(string.match(res, "%d+")) or nil
                    if killed then
                        cakeLabel:SetText("Cake Prince Killed: " .. tostring(500 - killed))
                    else
                        cakeLabel:SetText("Cake Prince: N/A")
                    end
                end
            end)
        end
    end)
end

do
    local FarmLeft  = Tabs.FarmSettings:AddLeftGroupbox("Movement & Position Offset")
    local FarmRight = Tabs.FarmSettings:AddRightGroupbox("Bring Mob Settings")

    FarmLeft:AddToggle("FarmBypass", { Text = "Farm Bypass TP", Default = true })
    Toggles.FarmBypass:OnChanged(function()
        State.farmBypassEnabled = T("FarmBypass")
        Library:Notify({ Title = "Farm Bypass TP", Description = State.farmBypassEnabled and "ON" or "OFF", Time = 3 })
    end)

    FarmLeft:AddSlider("TweenSpeed", { Text = "Tween Speed", Min = 0, Max = 500, Default = 250, Rounding = 0 })
    Options.TweenSpeed:OnChanged(function() CFG.SPEED = tonumber(O("TweenSpeed")) or 250 end)

    FarmLeft:AddSlider("OffsetX", { Text = "Offset X", Min = -50, Max = 50, Default = 0, Rounding = 0 })
    Options.OffsetX:OnChanged(function() CFG.OFFSET_X = tonumber(O("OffsetX")) or 0 end)

    FarmLeft:AddSlider("OffsetY", { Text = "Offset Y", Min = 0, Max = 100, Default = 25, Rounding = 0 })
    Options.OffsetY:OnChanged(function() CFG.OFFSET_Y = tonumber(O("OffsetY")) or 25 end)

    FarmLeft:AddSlider("OffsetZ", { Text = "Offset Z", Min = -50, Max = 50, Default = 0, Rounding = 0 })
    Options.OffsetZ:OnChanged(function() CFG.OFFSET_Z = tonumber(O("OffsetZ")) or 0 end)

    FarmLeft:AddSlider("HitRange", { Text = "Hit Range", Min = 10, Max = 200, Default = 100, Rounding = 0 })
    Options.HitRange:OnChanged(function() CFG.MAX_DISTANCE = tonumber(O("HitRange")) or 100 end)

    FarmRight:AddDropdown("BringMobMode", {
        Values = Lists.BRING_MODES, Default = 1, Multi = false, Text = "Bring Mob Mode",
    })
    Options.BringMobMode:OnChanged(function()
        local raw = O("BringMobMode") or ""
        State.bringMobMode = string.find(raw, "Instant") and "Instant" or "Smooth"
        Library:Notify({ Title = "Bring Mob Mode", Description = State.bringMobMode, Time = 3 })
    end)

    FarmRight:AddSlider("BringRadius", { Text = "BringMob Distance", Min = 0, Max = 500, Default = 300, Rounding = 0 })
    Options.BringRadius:OnChanged(function() CFG.BRING_RADIUS = tonumber(O("BringRadius")) or 300 end)

    FarmRight:AddSlider("BringCount", { Text = "Bring Mob count", Min = 1, Max = 10, Default = 1, Rounding = 0 })
    Options.BringCount:OnChanged(function() CFG.BRING_COUNT = tonumber(O("BringCount")) or 1 end)

    FarmRight:AddButton({
        Text = "Reset Value Default",
        Func = function()
            CFG.SPEED = 250; CFG.OFFSET_X = 0; CFG.OFFSET_Y = 25; CFG.OFFSET_Z = 0
            CFG.MAX_DISTANCE = 100; CFG.BRING_RADIUS = 300; CFG.BRING_COUNT = 1; State.bringMobMode = "Instant"
            Options.TweenSpeed:SetValue(250); Options.OffsetX:SetValue(0)
            Options.OffsetY:SetValue(25); Options.OffsetZ:SetValue(0)
            Options.HitRange:SetValue(100); Options.BringMobMode:SetValue("Instant")
            Options.BringRadius:SetValue(300); Options.BringCount:SetValue(1)
            smoothCleanAll()
            Library:Notify({ Title = "Reset", Description = "Reset to Default", Time = 3 })
        end,
    })
end

do
    local LeftGroup  = Tabs.Main:AddLeftGroupbox("Combat")
    local RightGroup = Tabs.Main:AddRightGroupbox("Farm")

    LeftGroup:AddDropdown("WeaponSelect", {
        Values = Lists.WEAPON_TYPES, Default = 1, Multi = false, Text = "Equip Item",
    })
    Options.WeaponSelect:OnChanged(function()
        State.selectedWeaponType = O("WeaponSelect") or Lists.WEAPON_TYPES[1]
        if State.autoNearEnabled or State.autoFarmEnabled or State.autoBossEnabled then equipWeapon(State.selectedWeaponType) end
    end)
    State.selectedWeaponType = Lists.WEAPON_TYPES[1]

    LeftGroup:AddToggle("FastAttack", { Text = "Fast Attack", Default = false })
    Toggles.FastAttack:OnChanged(function()
        checkAndResumeFastAttack()
        Library:Notify({ Title = "Fast Attack", Description = T("FastAttack") and "Enabled" or "Disabled", Time = 3 })
    end)

    LeftGroup:AddToggle("AutoNear", { Text = "Auto Farm Nears", Default = false })
    Toggles.AutoNear:OnChanged(function()
        State.autoNearEnabled = T("AutoNear")
        if State.autoNearEnabled then
            if State.teleportTweenEnabled and Toggles.TweenToIsland then Toggles.TweenToIsland:SetValue(false) end
            if State.autoFarmEnabled and Toggles.AutoFarm then Toggles.AutoFarm:SetValue(false) end
            if State.autoBossEnabled and Toggles.AutoBoss then Toggles.AutoBoss:SetValue(false) end
            State.currentEnemy = nil; State.trackedRoot = nil; State.currentFlyCF = HRP and HRP.CFrame or nil
            startNoclip(); startAutoNear()
            Library:Notify({ Title = "Auto Nears", Description = "Enabled", Time = 3 })
        else
            if Conns.follow then Conns.follow:Disconnect(); Conns.follow = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll()
            checkAndResumeFastAttack()
            Library:Notify({ Title = "Auto Nears", Description = "Disabled", Time = 3 })
        end
    end)

    RightGroup:AddDropdown("MonsterSelect", {
        Values = initialMonsterList,
        Default = initialMonsterList[1] and { [initialMonsterList[1]] = true } or {},
        Multi = true, Text = "Select Monsters (Multi)", Searchable = true,
    })
    Options.MonsterSelect:OnChanged(function()
        updateSelectedMonstersList()
        if State.currentEnemy and State.currentEnemy.Parent then
            local currentMobName = cleanMonsterName(State.currentEnemy.Name)
            if not table.find(Lists.selectedMonsterList, currentMobName) then
                State.currentEnemy = nil; State.trackedRoot = nil; smoothCleanAll()
            end
        end
    end)
    updateSelectedMonstersList()

    RightGroup:AddButton({ Text = "Refresh Monster List", Func = function() updateMonsterDropdown(true) end })

    RightGroup:AddToggle("AutoFarm", { Text = "Auto Farm Select", Default = false })
    Toggles.AutoFarm:OnChanged(function()
        State.autoFarmEnabled = T("AutoFarm")
        if State.autoFarmEnabled then
            if State.teleportTweenEnabled and Toggles.TweenToIsland then Toggles.TweenToIsland:SetValue(false) end
            if State.autoNearEnabled and Toggles.AutoNear then Toggles.AutoNear:SetValue(false) end
            if State.autoBossEnabled and Toggles.AutoBoss then Toggles.AutoBoss:SetValue(false) end
            State.currentEnemy = nil; State.trackedRoot = nil; State.currentFlyCF = HRP and HRP.CFrame or nil
            Lists.cachedSpawnsByName = {}
            local activeList = updateSelectedMonstersList()
            startNoclip(); startAutoFarm()
            Library:Notify({ Title = "Auto Farm", Description = "Targeting: " .. (#activeList > 0 and table.concat(activeList, ", ") or "None"), Time = 3 })
        else
            if Conns.farm then Conns.farm:Disconnect(); Conns.farm = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll()
            checkAndResumeFastAttack()
            Library:Notify({ Title = "Auto Farm", Description = "Disabled", Time = 3 })
        end
    end)

    RightGroup:AddDropdown("BossSelect", {
        Values = initialBossList,
        Default = {},
        Multi = true, Text = "Select Bosses (Multi)", Searchable = true,
    })
    Options.BossSelect:OnChanged(function()
        updateSelectedBossesList()
        if State.currentEnemy and State.currentEnemy.Parent then
            local currentMobName = cleanMonsterName(State.currentEnemy.Name)
            if not table.find(Lists.selectedBossList, currentMobName) then
                State.currentEnemy = nil; State.trackedRoot = nil; smoothCleanAll()
            end
        end
    end)
    updateSelectedBossesList()

    RightGroup:AddButton({ Text = "Refresh Boss List", Func = function() refreshBossDropdown() end })

    RightGroup:AddToggle("AutoBoss", { Text = "Auto Farm Boss", Default = false })
    Toggles.AutoBoss:OnChanged(function()
        State.autoBossEnabled = T("AutoBoss")
        if State.autoBossEnabled then
            if State.autoFarmEnabled and Toggles.AutoFarm then Toggles.AutoFarm:SetValue(false) end
            if State.autoNearEnabled and Toggles.AutoNear then Toggles.AutoNear:SetValue(false) end
            if State.teleportTweenEnabled and Toggles.TweenToIsland then Toggles.TweenToIsland:SetValue(false) end
            if State.bypassTpEnabled and Toggles.BypassTeleport then Toggles.BypassTeleport:SetValue(false) end
            State.currentEnemy = nil; State.trackedRoot = nil; State.currentFlyCF = HRP and HRP.CFrame or nil
            Lists.cachedSpawnsByName = {}
            local activeList = updateSelectedBossesList()
            startNoclip(); startAutoBoss()
            Library:Notify({ Title = "Auto Boss", Description = "Targeting: " .. (#activeList > 0 and table.concat(activeList, ", ") or "None"), Time = 3 })
        else
            if Conns.boss then Conns.boss:Disconnect(); Conns.boss = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll()
            checkAndResumeFastAttack()
            Library:Notify({ Title = "Auto Boss", Description = "Disabled", Time = 3 })
        end
    end)

    RightGroup:AddToggle("BringMob", { Text = "Bring Mob", Default = true })
    Toggles.BringMob:OnChanged(function()
        State.bringMobEnabled = T("BringMob")
        if not State.bringMobEnabled then stopBringMobLoop(); stopInstantBring() end
        Library:Notify({ Title = "Bring Mob", Description = State.bringMobEnabled and "ON" or "OFF", Time = 3 })
    end)

    local enemiesFolder2 = Workspace:FindFirstChild("Enemies")
    if enemiesFolder2 then
        enemiesFolder2.ChildAdded:Connect(function(child)
            if addDiscoveredMonster(child.Name) then updateMonsterDropdown(false) end
            task.wait(0.5)
            if not child or not child.Parent then return end
            local hum = child:FindFirstChildOfClass("Humanoid")
            if not hum then hum = child:WaitForChild("Humanoid", 3) end
            if not hum or not hum.Health or hum.Health <= 0 then return end
            local rawName = (hum.DisplayName and hum.DisplayName ~= "") and hum.DisplayName or child.Name
            if string.find(rawName, "%[Boss%]") then
                local isNew = addDiscoveredBoss(rawName)
                if isNew then
                    local displayList = #Lists.masterBossList > 0 and Lists.masterBossList or {"(No Boss found)"}
                    if Options and Options.BossSelect then
                        Options.BossSelect:SetValues(displayList)
                    end
                end
            end
        end)
    end
end
do
    local SeaLeft = Tabs.Sea:AddLeftGroupbox("Boat Settings")

    SeaLeft:AddToggle("BoatSpeed", { Text = "Enable Boat Speed", Default = false })
    Toggles.BoatSpeed:OnChanged(function()
        State.boatSpeedEnabled = T("BoatSpeed")
        if not State.boatSpeedEnabled then restoreBoatSpeed() end
        Library:Notify({ Title = "Boat Speed", Description = State.boatSpeedEnabled and "ON" or "OFF", Time = 3 })
    end)

    SeaLeft:AddToggle("BoatNoclip", { Text = "Boat NoClip", Default = false })
    Toggles.BoatNoclip:OnChanged(function()
        State.boatNoclipEnabled = T("BoatNoclip")
        if State.boatNoclipEnabled then startBoatNoclip() else stopBoatNoclip() end
        Library:Notify({ Title = "Boat NoClip", Description = State.boatNoclipEnabled and "ON" or "OFF", Time = 3 })
    end)

    SeaLeft:AddDropdown("BoatTargetMode", {
        Values = { "Owner", "All" }, Default = 1, Multi = false, Text = "Target Boats",
    })
    Options.BoatTargetMode:OnChanged(function()
        State.boatTargetMode = O("BoatTargetMode") or "Owner"
        if not T("BoatSpeed") then restoreBoatSpeed() end
        if not T("BoatNoclip") then stopBoatNoclip() end
    end)

    SeaLeft:AddSlider("BoatSpeedSlider", {
        Text = "Boat Speed", Min = 50, Max = 1000, Default = 250, Rounding = 0,
    })
    Options.BoatSpeedSlider:OnChanged(function()
        State.boatSpeedValue = tonumber(O("BoatSpeedSlider")) or 250
    end)

    SeaLeft:AddButton({
        Text = "Reset Speed Default",
        Func = function()
            Options.BoatSpeedSlider:SetValue(100)
            restoreBoatSpeed()
            Library:Notify({ Title = "Boat Speed", Description = "Reset to Default", Time = 3 })
        end
    })
end

do
    local LPLeft = Tabs.LocalPlayer:AddLeftGroupbox("Settings")

    LPLeft:AddToggle("PlayerNoclip", { Text = "NoClip", Default = false })
    Toggles.PlayerNoclip:OnChanged(function()
        State.playerNoclipEnabled = T("PlayerNoclip")
        if State.playerNoclipEnabled then startPlayerNoclip() else stopPlayerNoclip() end
        Library:Notify({ Title = "NoClip", Description = State.playerNoclipEnabled and "ON" or "OFF", Time = 3 })
    end)

    LPLeft:AddToggle("AutoBuso", { Text = "Auto Turn on Buso", Default = true })
    Toggles.AutoBuso:OnChanged(function()
        if T("AutoBuso") then Library:Notify({ Title = "Buso Haki", Description = "Auto Buso ON", Time = 3 }) end
    end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            pcall(function()
                if not T("AutoBuso") then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or not hum.Health or hum.Health <= 0 then return end
                if not char:FindFirstChild("HasBuso") then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
                end
            end)
        end
    end)

    LPLeft:AddToggle("AutoObservation", { Text = "Auto Haki Observation", Default = false })
    Toggles.AutoObservation:OnChanged(function()
        Library:Notify({ Title = "Observation", Description = T("AutoObservation") and "ON" or "OFF", Time = 3 })
    end)
    task.spawn(function()
        while true do
            task.wait(0.1)
            pcall(function()
                if not T("AutoObservation") then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or not hum.Health or hum.Health <= 0 then return end
                ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
            end)
        end
    end)

    LPLeft:AddToggle("AutoRaceV3", { Text = "Auto Turn on Race V3", Default = false })
    Toggles.AutoRaceV3:OnChanged(function()
        Library:Notify({ Title = "Race V3", Description = T("AutoRaceV3") and "ON" or "OFF", Time = 3 })
    end)
    task.spawn(function()
        while true do
            task.wait(0.2)
            pcall(function()
                if not T("AutoRaceV3") then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or not hum.Health or hum.Health <= 0 then return end
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
                task.wait(30)
            end)
        end
    end)

    LPLeft:AddToggle("AutoRaceV4", { Text = "Auto Turn on Race V4", Default = false })
    Toggles.AutoRaceV4:OnChanged(function()
        Library:Notify({ Title = "Race V4", Description = T("AutoRaceV4") and "ON" or "OFF", Time = 3 })
    end)
    task.spawn(function()
        while true do
            task.wait(0.2)
            pcall(function()
                if not T("AutoRaceV4") then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or not hum.Health or hum.Health <= 0 then return end
                local raceEnergy = char:FindFirstChild("RaceEnergy")
                if raceEnergy and raceEnergy:IsA("NumberValue") and raceEnergy.Value == 1 then
                    local vim1 = game:GetService("VirtualInputManager")
                    vim1:SendKeyEvent(true,  "Y", false, game)
                    vim1:SendKeyEvent(false, "Y", false, game)
                end
            end)
        end
    end)

    LPLeft:AddToggle("SafeMode", { Text = "Safe Mode", Default = false })
    task.spawn(function()
        while true do
            task.wait(0.1)
            pcall(function()
                if not T("SafeMode") then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hum  = char:FindFirstChildOfClass("Humanoid")
                local hrp2 = char:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp2 then return end
                if hum.MaxHealth and hum.MaxHealth > 0 and hum.Health and hum.Health > 0 then
                    local hpPct = hum.Health / hum.MaxHealth * 100
                    if hpPct < State.safeHealthThreshold then
                        for _, c in ipairs(hrp2:GetChildren()) do
                            if c.Name == "SafeModeBV" then pcall(function() c:Destroy() end) end
                        end
                        safeModeFlyUp(hrp2)
                    end
                end
            end)
        end
    end)

    LPLeft:AddToggle("WalkOnWater", { Text = "Walk on Water", Default = true })
    Toggles.WalkOnWater:OnChanged(function()
        pcall(function()
            local mapFolder = workspace:FindFirstChild("Map")
            local waterPlane = mapFolder and mapFolder:FindFirstChild("WaterBase-Plane")
            if waterPlane then
                waterPlane.Size = T("WalkOnWater") and Vector3.new(1000, 112, 1000) or Vector3.new(1000, 80, 1000)
            end
        end)
        Library:Notify({ Title = "Walk on Water", Description = T("WalkOnWater") and "ON" or "OFF", Time = 3 })
    end)
    pcall(function()
        local mapFolder = workspace:FindFirstChild("Map")
        local waterPlane = mapFolder and mapFolder:FindFirstChild("WaterBase-Plane")
        if waterPlane then waterPlane.Size = Vector3.new(1000, 112, 1000) end
    end)

    LPLeft:AddToggle("IceWalk", { Text = "Ice Walk", Default = false })
    Toggles.IceWalk:OnChanged(function()
        local oldIce = workspace:FindFirstChild("IceWalkPlatform_KKKK")
        if oldIce then oldIce:Destroy() end
        Library:Notify({ Title = "Ice Walk", Description = T("IceWalk") and "ON" or "OFF", Time = 3 })
    end)
    task.spawn(function()
        while true do
            task.wait()
            pcall(function()
                if not T("IceWalk") then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or not hum.Health or hum.Health <= 0 then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local spike = ReplicatedStorage.Assets.Models.IceSpikes4:Clone()
                spike.Parent = workspace
                spike.Size = Vector3.new(3 + math.random(10, 12), 1.7, 3 + math.random(10, 12))
                spike.Color = Color3.fromRGB(128, 187, 219)
                spike.CFrame = CFrame.new(hrp.Position.X, -3.8, hrp.Position.Z)
                    * CFrame.Angles((math.random()-0.5)*0.06, math.random()*7, (math.random()-0.5)*0.07)
                spike.Anchored = true; spike.CanCollide = true; spike.CanTouch = false
                local tween = TweenService:Create(spike,
                    TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Size = Vector3.new(0, 0.3, 0)})
                tween.Completed:Connect(function() spike:Destroy() end)
                tween:Play()
            end)
        end
    end)

    LPLeft:AddToggle("AntiAFK", { Text = "Anti AFK", Default = true })
    do
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if T("AntiAFK") then
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        end)
    end

    LPLeft:AddToggle("AntiAdmin", { Text = "Auto Anti-Admin Join Server", Default = true })
    local ADMIN_BLACKLIST = {
        "red_game43","rip_indra","Axiore","Polkster","wenlocktoad",
        "Daigrock","toilamvidamme","oofficialnoobie","Uzoth","Azarth",
        "arlthmetic","Death_King","Lunoven","TheGreateAced","rip_fud",
        "drip_mama","layandikit12","Hingoi"
    }
    task.spawn(function()
        while true do
            task.wait(5)
            pcall(function()
                if T("AntiAdmin") then
                    for _, v in pairs(Players:GetPlayers()) do
                        if table.find(ADMIN_BLACKLIST, v.Name) then
                            local Http = game:GetService("HttpService")
                            local TPS2 = game:GetService("TeleportService")
                            local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
                            local data = Http:JSONDecode(req)
                            for _, sv in pairs(data.data) do
                                if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                                    TPS2:TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

do
    local StatsLeft = Tabs.Stats:AddLeftGroupbox("Stats Upgrade")
    StatsLeft:AddSlider("StatValue", { Text = "Stats Value", Min = 1, Max = 1000, Default = 10, Rounding = 0 })
    Options.StatValue:OnChanged(function() State.pSats = tonumber(O("StatValue")) or 10 end)

    StatsLeft:AddToggle("AutoMelee",     { Text = "Auto Melee",      Default = false })
    StatsLeft:AddToggle("AutoSword",     { Text = "Auto Sword",      Default = false })
    StatsLeft:AddToggle("AutoGun",       { Text = "Auto Gun",        Default = false })
    StatsLeft:AddToggle("AutoBloxFruit", { Text = "Auto Blox Fruit", Default = false })
    StatsLeft:AddToggle("AutoDefense",   { Text = "Auto Defense",    Default = false })

    task.spawn(function()
        while true do
            task.wait(0.5)
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or not hum.Health or hum.Health <= 0 then return end
                local data = LocalPlayer:FindFirstChild("Data")
                local points = data and data:FindFirstChild("Points")
                if not points or not points:IsA("ValueBase") or points.Value <= 0 then return end
                if T("AutoMelee")     then statsSetings("Melee",   State.pSats) end
                if T("AutoSword")     then statsSetings("Sword",   State.pSats) end
                if T("AutoGun")       then statsSetings("Gun",     State.pSats) end
                if T("AutoBloxFruit") then statsSetings("Devil",   State.pSats) end
                if T("AutoDefense")   then statsSetings("Defense", State.pSats) end
            end)
        end
    end)
end

do
    local TeleportLeft  = Tabs.Teleport:AddLeftGroupbox("Island Teleport")
    local TeleportRight = Tabs.Teleport:AddRightGroupbox("Teleport Info")

    local names, map, world = getIslandNamesAndMap(game.PlaceId)
    Lists.islandNames = names
    Lists.islandMap   = map
    Lists.worldName   = world
    State.selectedIslandName = names[1]
    State.selectedIslandPos  = map[names[1]]

    TeleportLeft:AddLabel("Current Sea: " .. world)
    TeleportLeft:AddDropdown("IslandSelect", {
        Values = names, Default = 1, Multi = false, Text = "Select Island", Searchable = true,
    })
    Options.IslandSelect:OnChanged(function()
        State.selectedIslandName = O("IslandSelect")
        State.selectedIslandPos  = Lists.islandMap[State.selectedIslandName]
    end)

    TeleportLeft:AddToggle("TweenToIsland", { Text = "Tween to Island", Default = false })
    Toggles.TweenToIsland:OnChanged(function()
        State.teleportTweenEnabled = T("TweenToIsland")
        if State.teleportTweenEnabled then
            if not State.selectedIslandPos then
                Library:Notify({ Title = "Teleport", Description = "No destination selected!", Time = 3 })
                Toggles.TweenToIsland:SetValue(false); return
            end
            if State.autoFarmEnabled and Toggles.AutoFarm then Toggles.AutoFarm:SetValue(false) end
            if State.autoNearEnabled and Toggles.AutoNear then Toggles.AutoNear:SetValue(false) end
            if State.autoBossEnabled and Toggles.AutoBoss then Toggles.AutoBoss:SetValue(false) end
            startNoclip(); startTeleportTween()
            Library:Notify({ Title = "Teleport", Description = "Going to: " .. tostring(State.selectedIslandName), Time = 3 })
        else
            stopTeleportTween()
            Library:Notify({ Title = "Teleport", Description = "Stopped", Time = 3 })
        end
    end)

    TeleportLeft:AddToggle("BypassTeleport", { Text = "Bypass Teleport", Default = false })
    Toggles.BypassTeleport:OnChanged(function()
        if bypassTpArrived then return end
        State.bypassTpEnabled = T("BypassTeleport")
        if State.bypassTpEnabled then
            if not State.selectedIslandPos then
                Library:Notify({ Title = "Teleport", Description = "No destination selected!", Time = 3 })
                Toggles.BypassTeleport:SetValue(false); return
            end
            if State.autoFarmEnabled and Toggles.AutoFarm then Toggles.AutoFarm:SetValue(false) end
            if State.autoNearEnabled and Toggles.AutoNear then Toggles.AutoNear:SetValue(false) end
            if State.autoBossEnabled and Toggles.AutoBoss then Toggles.AutoBoss:SetValue(false) end
            if State.teleportTweenEnabled and Toggles.TweenToIsland then Toggles.TweenToIsland:SetValue(false) end
            Library:Notify({ Title = "Bypass Teleport", Description = "Going to: " .. tostring(State.selectedIslandName), Time = 3 })
            startBypassTp()
        else
            stopBypassTp()
            Library:Notify({ Title = "Bypass Teleport", Description = "Stopped", Time = 3 })
        end
    end)

    TeleportRight:AddLabel("Place ID: " .. tostring(game.PlaceId))
    TeleportRight:AddLabel("Total Islands: " .. tostring(#names))
    TeleportRight:AddLabel("Sea: " .. world)
    TeleportRight:AddButton({
        Text = "Refresh Islands",
        Func = function()
            local newNames, newMap, newWorld = getIslandNamesAndMap(game.PlaceId)
            Lists.islandMap = newMap
            Options.IslandSelect:SetValues(newNames)
            Options.IslandSelect:SetValue(newNames[1])
            State.selectedIslandName = newNames[1]
            State.selectedIslandPos  = newMap[newNames[1]]
            Library:Notify({ Title = "Teleport", Description = "Reloaded " .. #newNames .. " locations (" .. newWorld .. ")", Time = 3 })
        end,
    })
end

do
    local EspLeft  = Tabs.Esp:AddLeftGroupbox("ESP Options")
    local EspRight = Tabs.Esp:AddRightGroupbox("ESP Info")

    EspLeft:AddToggle("EspPlayer", { Text = "ESP Player", Default = false })
    Toggles.EspPlayer:OnChanged(function()
        ESP.Player = T("EspPlayer")
        if not ESP.Player then
            for _, v in next, Players:GetChildren() do
                pcall(function()
                    if v.Character and v.Character:FindFirstChild("Head") then
                        local esp = v.Character.Head:FindFirstChild('NameEsp'..ESP.Number)
                        if esp then esp:Destroy() end
                    end
                end)
            end
        end
        Library:Notify({ Title = "ESP Player", Description = ESP.Player and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspFruit", { Text = "ESP Devil Fruit", Default = false })
    Toggles.EspFruit:OnChanged(function()
        ESP.DevilFruit = T("EspFruit")
        Library:Notify({ Title = "ESP Fruit", Description = ESP.DevilFruit and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspIsland", { Text = "ESP Island", Default = false })
    Toggles.EspIsland:OnChanged(function()
        ESP.Island = T("EspIsland")
        if not ESP.Island then
            local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
            local locs = worldOrigin and worldOrigin:FindFirstChild("Locations")
            if locs then
                for _, v in next, locs:GetChildren() do
                    pcall(function()
                        if v:FindFirstChild('NameEsp') then v:FindFirstChild('NameEsp'):Destroy() end
                    end)
                end
            end
        end
        Library:Notify({ Title = "ESP Island", Description = ESP.Island and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspFlower", { Text = "ESP Flower", Default = false })
    Toggles.EspFlower:OnChanged(function()
        ESP.Flower = T("EspFlower")
        Library:Notify({ Title = "ESP Flower", Description = ESP.Flower and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspChest", { Text = "ESP Chest", Default = false })
    Toggles.EspChest:OnChanged(function()
        ESP.Chest = T("EspChest")
        if not ESP.Chest then
            for _, Chest in ipairs(game:GetService("CollectionService"):GetTagged("_ChestTagged")) do
                local att = Chest:FindFirstChild("ChestEspAttachment")
                if att then att:Destroy() end
            end
        end
        Library:Notify({ Title = "ESP Chest", Description = ESP.Chest and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspEventIsland", { Text = "ESP Sea Event Islands", Default = false })
    Toggles.EspEventIsland:OnChanged(function()
        ESP.EventIsland = T("EspEventIsland")
        Library:Notify({ Title = "ESP Event Island", Description = ESP.EventIsland and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspLegenSword", { Text = "ESP Legendary Sword Dealer", Default = false })
    Toggles.EspLegenSword:OnChanged(function()
        ESP.LegenSword = T("EspLegenSword")
        if not ESP.LegenSword then
            if workspace:FindFirstChild("LgdKKKK") then workspace.LgdKKKK:Destroy() end
        end
        Library:Notify({ Title = "ESP Legendary", Description = ESP.LegenSword and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspBerry", { Text = "ESP Berry Bush", Default = false })
    Toggles.EspBerry:OnChanged(function()
        ESP.Berry = T("EspBerry")
        if not ESP.Berry then
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Part") and v.Name:match("^BerryEspKKKK_") then v:Destroy() end
            end
        end
        Library:Notify({ Title = "ESP Berry", Description = ESP.Berry and "ON" or "OFF", Time = 2 })
    end)

    EspRight:AddLabel("Blue = Same Team")
    EspRight:AddLabel("Red = Enemy Team")
end

local function doHop()
    HopState.hopTotal = HopState.hopTotal + 1
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local sb = pg and pg:FindFirstChild("ServerBrowser")
    if not sb then Library:Notify({ Title = "Hop", Description = "ServerBrowser not found", Time = 3 }); return end
    local frame = sb:FindFirstChild("Frame")
    if not frame then Library:Notify({ Title = "Hop", Description = "Frame not found", Time = 3 }); return end

    local watching = true
    task.spawn(function()
        while watching do
            task.wait(0.5)
            if not sb.Enabled or not frame.Visible then
                sb.Enabled = true; frame.Visible = true
            end
        end
    end)

    if not sb.Enabled then sb.Enabled = true; task.wait(0.3) end
    if not frame.Visible then frame.Visible = true; task.wait(0.3) end

    pcall(function()
        local rb = frame.Filters.SearchRegion:FindFirstChildOfClass("TextBox")
        if rb then
            rb.Text = HopState.hopTarget ~= "" and HopState.hopTarget or ""
            rb:ReleaseFocus()
        end
    end)
    pcall(function() frame.Refresh:Activate() end)
    task.wait(3)

    local inside = frame:FindFirstChild("FakeScroll") and frame.FakeScroll:FindFirstChild("Inside")
    if not inside then watching = false; return end

    local maxP = HopState.hopMaxPlayers
    local tried = {}

    local function findBest()
        local best, bestC = nil, math.huge
        local fs = frame:FindFirstChild("FakeScroll"); if not fs then return nil end
        local absPos = fs.AbsolutePosition
        local absSz  = fs.AbsoluteSize
        local cx = absPos.X + absSz.X / 2
        local cy = absPos.Y + absSz.Y / 2

        local function scrollDown()
            pcall(function() game:GetService("VirtualInputManager"):SendMouseWheelEvent(cx, cy, false, game) end)
        end
        local function scrollUp()
            pcall(function() game:GetService("VirtualInputManager"):SendMouseWheelEvent(cx, cy, true, game) end)
        end

        local seenJobs = {}
        local function readRows()
            local foundNew = false
            for _, child in ipairs(inside:GetChildren()) do
                if not child:IsA("Frame") then continue end
                local jb = child:FindFirstChild("Join")
                if not jb or jb.Text ~= "Join" then continue end
                local jobId = jb:GetAttribute("Job")
                if not jobId or jobId == "1234567890123" then continue end
                if tried[jobId] or seenJobs[jobId] then continue end
                local sn = child:FindFirstChild("ServerName")
                if sn and sn.Text:find("Your Server") then continue end
                local tl = child:FindFirstChildOfClass("TextLabel")
                if tl then
                    local a = tl.Text:match("Players:%s*(%d+)%s*/%s*%d+")
                    if a then
                        local pc = tonumber(a)
                        seenJobs[jobId] = true
                        foundNew = true
                        if pc and pc <= maxP then
                            if not best or pc < bestC then
                                bestC = pc
                                best = { jb = jb, jobId = jobId, cur = pc }
                            end
                        end
                    end
                end
            end
            return foundNew
        end

        for pass = 1, 3 do
            for _ = 1, 30 do scrollUp() end
            task.wait(0.5)
            seenJobs = {}
            readRows()
            local noNew = 0
            while noNew < 10 do
                for _ = 1, 3 do scrollDown() end
                task.wait(0.25)
                if readRows() then noNew = 0 else noNew = noNew + 1 end
                if best then return best end
            end
            if pass < 3 then
                tried = {}
                pcall(function() frame.Refresh:Activate() end)
                task.wait(4)
            end
        end
        return best
    end

    local function tryHop()
        local server = findBest()
        if server then
            tried[server.jobId] = true
            local fc
            fc = TeleportService.TeleportInitFailed:Connect(function()
                if fc then fc:Disconnect(); fc = nil end
                task.wait(1)
                tryHop()
            end)
            for _, c in ipairs(getconnections(server.jb.MouseButton1Click)) do c:Fire() end
            task.delay(5, function() if fc then fc:Disconnect(); fc = nil end end)
        else
            Library:Notify({ Title = "Hop", Description = "No suitable server found", Time = 3 })
        end
    end

    tryHop()
    task.delay(10, function() watching = false end)
end

local function startAutoHop(intervalMinutes)
    HopState.hopCD = (intervalMinutes or 45) * 60
    HopState.hopTick = tick()
    if HopState.hopThread then task.cancel(HopState.hopThread); HopState.hopThread = nil end
    HopState.hopThread = task.spawn(function()
        while true do
            task.wait(1)
            local now = tick()
            HopState.hopCD = HopState.hopCD - (now - HopState.hopTick)
            HopState.hopTick = now
            if HopState.hopCD <= 0 then
                HopState.hopCD = (intervalMinutes or 45) * 60
                task.spawn(doHop)
            end
        end
    end)
end

local function stopAutoHop()
    if HopState.hopThread then task.cancel(HopState.hopThread); HopState.hopThread = nil end
    HopState.hopCD = 0
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local sb = pg and pg:FindFirstChild("ServerBrowser")
        if not sb then return end
        sb.Enabled = false
        local f = sb:FindFirstChild("Frame")
        if f then f.Visible = false end
    end)
end

do
    local MiscServ = Tabs.Misc:AddLeftGroupbox("Server")
    local MiscGfx  = Tabs.Misc:AddRightGroupbox("Graphics")

    MiscServ:AddButton({
        Text = "Redeem All Codes",
        Func = function()
            local codes = {
                "LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK",
                "BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS",
                "SUB2GAMERROBOT_RESET1","KITT_RESET","Bignews","CHANDLER","Fudd10",
                "fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming","TRIPLEABUSE",
                "Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK",
                "Starcodeheo","Bluxxy","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123",
                "Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie",
                "TheGreatAce","JULYUPDATE_RESET","ADMINHACKED","SEATROLLING","24NOADMIN",
                "ADMIN_TROLL","NEWTROLL","SECRET_ADMIN","staffbattle","NOEXPLOIT",
                "NOOB2ADMIN","CODESLIDE","fruitconcepts","krazydares"
            }
            local RedeemRemote = ReplicatedStorage.Remotes:FindFirstChild("Redeem")
            if not RedeemRemote then Library:Notify({ Title = "Codes", Description = "Redeem remote not found!", Time = 3 }); return end
            for _, code in ipairs(codes) do
                task.wait(0)
                pcall(function()
                    if RedeemRemote.InvokeServer then RedeemRemote:InvokeServer(code)
                    else RedeemRemote:FireServer(code) end
                end)
            end
            Library:Notify({ Title = "Codes", Description = "All codes redeemed!", Time = 3 })
        end,
    })

    MiscServ:AddButton({ Text = "Rejoin Server", Func = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end })

    MiscServ:AddButton({
        Text = "Hop Server (Smart)",
        Func = function()
            Library:Notify({ Title = "Hop", Description = "Finding server...", Time = 3 })
            task.spawn(doHop)
        end,
    })

    MiscServ:AddSlider("HopInterval", { Text = "Auto Hop Interval (min)", Min = 1, Max = 120, Default = 45, Rounding = 0 })

    MiscServ:AddToggle("AutoHop", { Text = "Auto Hop", Default = false })
    Toggles.AutoHop:OnChanged(function()
        if T("AutoHop") then
            startAutoHop(tonumber(Options.HopInterval and Options.HopInterval.Value) or 45)
            Library:Notify({ Title = "Auto Hop", Description = "Every " .. (Options.HopInterval and Options.HopInterval.Value or 45) .. " min", Time = 3 })
        else
            stopAutoHop()
            Library:Notify({ Title = "Auto Hop", Description = "Disabled", Time = 3 })
        end
    end)

    Options.HopInterval:OnChanged(function()
        if T("AutoHop") then
            stopAutoHop()
            startAutoHop(tonumber(O("HopInterval")) or 45)
        end
    end)

    MiscServ:AddInput("HopRegion", {
        Text = "Region Filter", Default = "singapore", Numeric = false, Finished = false, Placeholder = "e.g. singapore",
    })
    Options.HopRegion:OnChanged(function()
        HopState.hopTarget = tostring(O("HopRegion") or "singapore"):lower()
    end)

    MiscServ:AddSlider("HopMaxPlayers", { Text = "Max Players Filter", Min = 1, Max = 20, Default = 3, Rounding = 0 })
    Options.HopMaxPlayers:OnChanged(function() HopState.hopMaxPlayers = tonumber(O("HopMaxPlayers")) or 3 end)

    MiscServ:AddButton({
        Text = "Copy Job ID",
        Func = function()
            setclipboard(tostring(game.JobId))
            Library:Notify({ Title = "Copied", Description = "Job ID copied to clipboard", Time = 3 })
        end,
    })

    MiscGfx:AddToggle("FullBright", { Text = "Full Bright", Default = false })
    Toggles.FullBright:OnChanged(function()
        if T("FullBright") then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.ColorShift_Bottom = Color3.new(1,1,1)
            Lighting.ColorShift_Top = Color3.new(1,1,1)
        else
            Lighting.Ambient = Color3.new(0,0,0)
            Lighting.ColorShift_Bottom = Color3.new(0,0,0)
            Lighting.ColorShift_Top = Color3.new(0,0,0)
        end
        Library:Notify({ Title = "Full Bright", Description = T("FullBright") and "ON" or "OFF", Time = 3 })
    end)

    MiscGfx:AddButton({
        Text = "Low CPU Mode",
        Func = function()
            local t = workspace.Terrain
            t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0; t.WaterTransparency = 0
            Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9; Lighting.Brightness = 0
            settings().Rendering.QualityLevel = "Level01"
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("Part") or v:IsA("Union") then
                    v.Material = "Plastic"; v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
            for _, e in pairs(Lighting:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
                    or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                    e.Enabled = false
                end
            end
            Library:Notify({ Title = "Performance", Description = "Low CPU Mode activated", Time = 3 })
        end,
    })

    MiscGfx:AddButton({
        Text = "Remove Sky Fog",
        Func = function()
            if Lighting:FindFirstChild("LightingLayers") then Lighting.LightingLayers:Destroy() end
            if Lighting:FindFirstChild("SeaTerrorCC") then Lighting.SeaTerrorCC:Destroy() end
            if Lighting:FindFirstChild("FantasySky") then Lighting.FantasySky:Destroy() end
            Library:Notify({ Title = "Fog", Description = "Sky fog removed", Time = 3 })
        end,
    })
end

do
    local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightAlt", NoUI = true, Text = "Menu keybind" })

    MenuGroup:AddButton({
        Text = "Unload",
        Func = function()
            State.autoNearEnabled = false; State.autoFarmEnabled = false; State.autoBossEnabled = false; State.teleportTweenEnabled = false
            FastAttackModule.Enabled = false
            stopFastAttack(); stopHitRegistration(); stopPositionLock()
            stopNoclip(); smoothCleanAll(); stopTeleportTween(); stopBypassTp(); stopBoatNoclip(); stopPlayerNoclip()
            if Conns.follow then Conns.follow:Disconnect(); Conns.follow = nil end
            if Conns.farm   then Conns.farm:Disconnect();   Conns.farm   = nil end
            if Conns.boss   then Conns.boss:Disconnect();   Conns.boss   = nil end
            ESP.Player = false; ESP.Island = false; ESP.DevilFruit = false
            ESP.Flower = false; ESP.Chest = false; ESP.EventIsland = false
            ESP.LegenSword = false; ESP.Berry = false
            if workspace:FindFirstChild("LgdKKKK") then workspace.LgdKKKK:Destroy() end
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Part") and v.Name:match("^BerryEspKKKK_") then v:Destroy() end
            end
            Library:Unload()
        end,
    })
end

Library.ToggleKeybind = Options.MenuKeybind

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HRP       = newChar:WaitForChild("HumanoidRootPart", 10)
    Humanoid  = newChar:WaitForChild("Humanoid", 10)
    if not HRP or not Humanoid then return end
    State.currentEnemy       = nil
    State.trackedRoot        = nil
    State.currentFlyCF       = nil
    Lists.cachedSpawnsByName = {}
    State.bypassMoving       = false

    if Conns.bypassTp then Conns.bypassTp:Disconnect(); Conns.bypassTp = nil end
    State.bypassTpEnabled = false
    State.currentFlyCF = nil

    refreshFolders()
    stopPositionLock()
    smoothCleanAll()
    task.wait(1)
    startHitRegistration()
    if State.autoNearEnabled then startNoclip(); startAutoNear() end
    if State.autoFarmEnabled then startNoclip(); startAutoFarm() end
    if State.autoBossEnabled then startNoclip(); startAutoBoss() end
    if State.teleportTweenEnabled then startNoclip(); startTeleportTween() end
    if T("BypassTeleport") and not bypassTpArrived then
        task.wait(1)
        local newHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if newHrp then State.currentFlyCF = newHrp.CFrame end
        startBypassTp()
        Library:Notify({ Title = "Bypass Teleport", Description = "Restarted after respawn", Time = 3 })
    end
    if State.playerNoclipEnabled then startPlayerNoclip() end
    task.wait(1)
    if T("FastAttack") and not State.autoNearEnabled and not State.autoFarmEnabled and not State.autoBossEnabled then
        FastAttackModule.Enabled = true
        startFastAttack()
    end
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("KKKKHub")
SaveManager:SetFolder("KKKKHub/config")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

task.spawn(function()
    task.wait(5)
    while true do
        task.wait(10)
        pcall(function() SaveManager:Save(SaveManager.AutoloadLabel or "autoload") end)
    end
end)

Library:Notify({ Title = "KKKK Hub", Description = "Loaded - Enhanced Edition", Time = 6 })
SaveManager:LoadAutoloadConfig()
