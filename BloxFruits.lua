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
    Item            = Window:AddTab("Item", "package"),
    Sea             = Window:AddTab("Sea", "anchor"),
    LocalPlayer     = Window:AddTab("Local Player", "user"),
    Esp             = Window:AddTab("ESP", "eye"),
    Stats           = Window:AddTab("Stats", "chart-no-axes-column"),
    Teleport        = Window:AddTab("Teleport", "map-pin"),
    Misc            = Window:AddTab("Misc", "box"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

Players           = game:GetService("Players")
RunService        = game:GetService("RunService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
TeleportService   = game:GetService("TeleportService")
TweenService      = game:GetService("TweenService")
Lighting          = game:GetService("Lighting")
Workspace         = game:GetService("Workspace")
UserInputService  = game:GetService("UserInputService")

LocalPlayer = Players.LocalPlayer

pcall(function()
    local curTeam = (LocalPlayer.Team and LocalPlayer.Team.Name) or (LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Team") and tostring(LocalPlayer.Data.Team.Value))
    if not curTeam or curTeam == "" then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam2", "Pirates")
    end
end)

Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
HRP       = Character:WaitForChild("HumanoidRootPart")
Humanoid  = Character:WaitForChild("Humanoid")

Modules = ReplicatedStorage:WaitForChild("Modules")
Net     = Modules:WaitForChild("Net")

RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
if not RegisterAttack or not RegisterHit then error("Remote events missing") end

local CFG = {
    SESSION_ID   = "32501259",
    MAX_DISTANCE = 100,
    MIN_DISTANCE = 1,
    SPEED        = 250,
    REACH        = 6,
    OFFSET_X     = 0,
    OFFSET_Y     = 35,
    OFFSET_Z     = 0,
}

local State = {
    autoNearEnabled      = false,
    autoFarmEnabled      = false,
    autoBossEnabled      = false,
    farmBypassEnabled    = true,
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
    playerFlyEnabled     = false,
    playerFlySpeed       = 100,
    playerFlyVelocity    = Vector3.zero,
    playerTpwalkEnabled  = false,
    playerTpwalkDistance = 2,
    playerJumpPowerEnabled = false,
    playerJumpPowerValue = 100,
    infiniteJumpEnabled  = false,
    playerEditCharacter  = nil,
    playerOriginalJumpPower = nil,
    playerOriginalUseJumpPower = nil,
    currentBossIndex     = 1,
    bossWaitTick         = nil,
    bossSpawnIdx         = 1,
    autoBossAllEnabled      = false,
    autoBossAllHopEnabled   = false,
    bossAllSpawnIdx         = 1,
    bossAllWaitTick         = nil,
    bossAllHopWaitTick      = nil,
    bossAllNoBossCount      = 0,
}

local bypassTpArrived = false

local HopState = {
    hopThread     = nil,
    hopCD         = 0,
    hopTick       = tick(),
    hopTotal      = 0,
    hopTarget     = "singapore",
    hopMaxPlayers = 3,
}

local Lists = {
    discoveredMonsters  = {},
    masterMonsterList   = {},
    cachedSpawnsByName  = {},
    cachedMobSpawns     = {},
    masterBossSpawnList = {}, 
    selectedMonsterList = {},
    discoveredBosses    = {},
    masterBossList      = {},
    selectedBossList    = {},
    defaultBoatSpeeds   = {},
    WEAPON_TYPES        = {"Melee", "Sword", "Gun", "Fruit"},
    islandNames         = {},
    islandMap           = {},
    worldName           = "",
}

local BossIgnoreList = {
    sea1 = {
        "Ice Admiral",
        "Mob Leader",
        "Saber Expert",
    },
    sea2 = {
        "rip_indra",
    },
    sea3 = {
        -- "rip_indra",
    },
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
    boatNoclip       = nil,
    playerNoclip     = nil,
    playerFly        = nil,
    playerEdit       = nil,
    infiniteJump     = nil,
    fastAttackThread = nil,
    boatSpeedLoop    = nil,
    espLoop          = nil,
    bossAll    = nil,
    bossAllHop = nil,
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
    AnyActive   = false,
}

local sea1 = (game.PlaceId == 2753915549 or game.PlaceId == 85211729168715)
local sea2 = (game.PlaceId == 4442272183 or game.PlaceId == 79091703265657)
local sea3 = (game.PlaceId == 7449423635 or game.PlaceId == 100117331123089)

local ESP_INTERVAL = {
    Player      = 0.5,
    DevilFruit  = 1.0,
    Island      = 2.0,
    Flower      = 2.0,
    Chest       = 3.0,
    EventIsland = 2.0,
    LegenSword  = 3.0,
    Berry       = 3.0,
}

local ESP_lastUpdate = {}

local function HasNearbyPlayer(enemy)
    local root = enemy:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local plrHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if plrHrp and (plrHrp.Position - root.Position).Magnitude <= 10 then
                return true
            end
        end
    end
    return false
end


local function smoothCleanAll()
    State.currentLockPos = nil
    
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            pcall(function()
                for _, desc in ipairs(enemy:GetDescendants()) do
                    if desc:IsA("BodyVelocity") and desc.Name == "BodyVelocity" then
                        desc:Destroy()
                    end
                end
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                end
            end)
        end
    end
end

local function getCurrentIgnoreList()
    if sea1 then return BossIgnoreList.sea1
    elseif sea2 then return BossIgnoreList.sea2
    elseif sea3 then return BossIgnoreList.sea3
    end
    return {}
end

local function isBossIgnored(name)
    local ignoreList = getCurrentIgnoreList()
    for _, ignoredName in ipairs(ignoreList) do
        if ignoredName == name then return true end
    end
    return false
end

local function getIslandNamesAndMap(placeId)
    local islandMap = {}
    local worldName = "Unknown"
    if placeId == 2753915549 or placeId == 85211729168715 then
        worldName = "First Sea"
        islandMap = {
            ["Starter Island"]    = Vector3.new(1122, 16, 1424),
            ["Marine Starter"]    = Vector3.new(-2750, 25, 2041),
            ["Jungle island"]     = Vector3.new(-1432, 62, 2),
            ["Pirate island"]     = Vector3.new(-1182, 61, 4036),
            ["Desert island"]     = Vector3.new(942, 21, 4378),
            ["Middle Town"]       = Vector3.new(-785, 74, 1606),
            ["Snow island"]       = Vector3.new(1353, 106, -1326),
            ["MarineBase island"] = Vector3.new(-4981, 85, 4164),
            ["Sky 1"]             = Vector3.new(-4831, 776, -2602),
            ["Sky 2"]             = Vector3.new(-7922, 5566, -378),
            ["Sky 3"]             = Vector3.new(-7987, 5756, -1925),
            ["Colosseum"]         = Vector3.new(-1468, 7, -2880),
            ["Magma island"]      = Vector3.new(-5395, 27, 8527),
            ["Prison island"]     = Vector3.new(5008, 89, 740),
            ["Whirl Pool"]        = Vector3.new(3874, 5, -1904),
            ["Underwater city"]   = Vector3.new(61170, 6, 1824),
            ["Fountain City"]     = Vector3.new(5305, 60, 4082),
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
            ["Hydra Town"]        = Vector3.new(5293, 1005, 391),
            ["Hydra Arena"]       = Vector3.new(5028, 174, -2007),
            ["Great Tree"]        = Vector3.new(4325, 566, -6152),
            ["Upper Great Tree"]  = Vector3.new(3038, 2282, -7337),
            ["Haunted Castle"]    = Vector3.new(-9514, 142, 5536),
            ["Bigmom island"]     = Vector3.new(-887, 66, -10905),
            ["Tiki Outpost"]      = Vector3.new(-16410, 528, 415),
            ["Mansion"]           = Vector3.new(-12462, 375, -7552),
            ["Castle on the Sea"] = Vector3.new(-4994, 315, -3007),
            ["Peanut island"]     = Vector3.new(-2122, 38, -10139),
            ["Katakuri island"]   = Vector3.new(-2094, 70, -12112),
            ["Chocolate island"]  = Vector3.new(66, 25, -12073),
            ["North Pole"]        = Vector3.new(-1091, 64, -14522),
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
    if AreaName:find("Dimension") or AreaName:find("Submerged") or AreaName == "Sealed Cavern"
        or CheckLegendaryItems() then
        return false
    end
    
    local data = LocalPlayer:FindFirstChild("Data")
    local lastSpawn = data and data:FindFirstChild("LastSpawnPoint")
    if lastSpawn and lastSpawn:IsA("StringValue") and lastSpawn.Value == "SubmergedIsland" then
        return false
    end
    if GetDistance(targetCF.Position) <= 1200 then return false end
    return true
end

local function GetBypassCFrame(x)
    local targetCF = Convert_CFrame(x)
    if not targetCF then return nil end
    local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
    local Spawns = WorldOrigin and WorldOrigin:FindFirstChild("PlayerSpawns")
    if not Spawns then return nil end
    local Pirates = Spawns:FindFirstChild("Pirates")
    if not Pirates then return nil end
    local charHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not charHRP then return nil end
    local playerPos = charHRP.Position
    local curDist = (playerPos - targetCF.Position).Magnitude
    if curDist < 1200 then return nil end
    local bestSpawn = nil
    local Max = math.huge
    for _, v in ipairs(Pirates:GetChildren()) do
        local part = v:FindFirstChild("Part")
        if part then
            local dFromPlayer = (part.Position - playerPos).Magnitude
            local dToTarget   = (part.Position - targetCF.Position).Magnitude
            if dFromPlayer <= 6000 and dToTarget < curDist - 300 and dToTarget < Max then
                Max = dToTarget
                bestSpawn = v
            end
        end
    end
    return bestSpawn
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
            local newChar = LocalPlayer.Character
            local newHrp = newChar and newChar:FindFirstChild("HumanoidRootPart")
            if newHrp then State.currentFlyCF = newHrp.CFrame end
        end
    end
end

local ENTRANCE_ONLY_ISLANDS = {
    -- Sea 1
    ["Sky 1"]           = false,
    ["Sky 2"]           = true,
    ["Sky 3"]           = true,
    ["Underwater city"] = true,
    ["Whirl Pool"]      = true,
    -- Sea 2
    ["Cursed Ship"]     = true,
    ["Upper Green Zone"]= true,
    ["Cafe"]            = true,
    -- Sea 3
    ["Hydra Town"]      = true,
    ["Mansion"]         = true,
    ["Castle on the Sea"]= true,
}

local function getEntranceForTarget(targetPos)
    if not targetPos then return nil end
    local charHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local playerPos = charHRP and charHRP.Position or Vector3.zero

    if sea1 then
        if playerPos.X > 50000 and targetPos.X < 50000 then
            return { entrance = Vector3.new(3864.69, 6.74, -1926.21), dest = Vector3.new(3874, 5, -1904), name = "Whirlpool" }
        end
        if targetPos.X > 50000 then
            return { entrance = Vector3.new(61163.85, 11.68, 1819.78), dest = Vector3.new(61170, 6, 1824), name = "Underwater" }
        end

        -- Sky islands can have spawn points at different heights.  Do not
        -- identify them by Y only; Sky 1 mob spawns are often below Y=600
        -- and moving from Sky 2/3 back to Sky 1 has a high current Y.
        local function flatDistance(a, b)
            return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
        end

        local SKY1_DEST = Vector3.new(-4831, 776, -2602)
        local SKY2_DEST = Vector3.new(-7922, 5566, -378)
        local SKY3_DEST = Vector3.new(-7987, 5756, -1925)

        if flatDistance(targetPos, SKY1_DEST) <= 1800 then
            return { entrance = Vector3.new(-4607.82, 874.39, -1667.56), dest = SKY1_DEST, name = "Sky1" }
        end
        if flatDistance(targetPos, SKY2_DEST) <= 1200
            or flatDistance(targetPos, SKY3_DEST) <= 1200
            or (targetPos.Y > 4000 and playerPos.Y < 4000) then
            return { entrance = Vector3.new(-7894.62, 5547.14, -380.29), dest = SKY2_DEST, name = "Sky2" }
        end
        return nil

    elseif sea2 then
        local CAFE_DEST = Vector3.new(-386, 73, 297)
        local SHIP_DEST = Vector3.new(-6505, 83, -128)
        local DOCK_DEST = Vector3.new(-13, 39, 2702)

        if (SHIP_DEST - targetPos).Magnitude <= 1500 then
            return { entrance = Vector3.new(-6508.56, 89.04, -132.84), dest = SHIP_DEST, name = "CursedShip" }
        elseif (CAFE_DEST - targetPos).Magnitude <= 1500 then
            return { entrance = Vector3.new(-286.99, 350.14, 597.90), dest = CAFE_DEST, name = "Cafe" }
        elseif (DOCK_DEST - targetPos).Magnitude <= 1500 then
            return { entrance = Vector3.new(2284.91, 15.54, 905.46), dest = DOCK_DEST, name = "Dock" }
        end
        return nil

    elseif sea3 then
        local MANSION_DEST = Vector3.new(-12462, 375, -7552)
        local CASTLE_DEST  = Vector3.new(-4994, 315, -3007)
        local HYDRA_DEST   = Vector3.new(5293, 1005, 391)

        if (MANSION_DEST - targetPos).Magnitude <= 1500 then
            return { entrance = Vector3.new(-12463.60, 378.33, -7533.08), dest = MANSION_DEST, name = "Mansion" }
        elseif (CASTLE_DEST - targetPos).Magnitude <= 1500 then
            return { entrance = Vector3.new(-5060.41, 318.50, -3160.22), dest = CASTLE_DEST, name = "Castle" }
        elseif (HYDRA_DEST - targetPos).Magnitude <= 1500 then
            return { entrance = Vector3.new(5650.95, 1017.27, -300.38), dest = HYDRA_DEST, name = "Hydra" }
        end
        return nil
    end

    return nil
end

local function requestentrance(pos)
    local targetPos = pos
    if typeof(pos) == "CFrame" then targetPos = pos.Position end
    if not targetPos then return end
    local charHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not charHRP then return end
    local playerPos = charHRP.Position
    local distPlayerToTarget = (playerPos - targetPos).Magnitude
    if distPlayerToTarget <= 3000 then return end
    if sea1 and playerPos.X > 50000 and targetPos.X < 50000 then
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(3864.6879882812, 6.7369995117188, -1926.2139892578))
        end)
        local nhr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if nhr then State.currentFlyCF = nhr.CFrame end
        return
    end
    local tb = {}
    if sea1 then
        tb = {
            { pos = Vector3.new(3864.6879882812, 6.7369995117188, -1926.2139892578),   name = "Whirlpool" },
            { pos = Vector3.new(-4607.8232421875, 874.39099121094, -1667.5570068359),  name = "Sky1" },
            { pos = Vector3.new(-7894.6181640625, 5547.1420898438, -380.29098510742),  name = "Sky2" },
            { pos = Vector3.new(61163.8515625, 11.68000793457, 1819.7840576172),       name = "Underwater" },
        }
    elseif sea2 then
        tb = {
            { pos = Vector3.new(2284.9091796875, 15.537796020508, 905.46417236328),    name = "Dock" },
            { pos = Vector3.new(-286.98596191406, 306.13739013672, 597.89910888672),   name = "Cafe" },
            { pos = Vector3.new(-6508.5581054688, 89.035003662109, -132.83999633789),  name = "CursedShip" },
            { pos = Vector3.new(923.21301269531, 126.9759979248, 32852.83203125),      name = "Far" },
        }
    elseif sea3 then
        tb = {
            { pos = Vector3.new(-12463.602539062, 378.32705688477, -7533.0830078125),  name = "Mansion" },
            { pos = Vector3.new(-5060.4116210938, 318.50201416016, -3160.2248535156),  name = "Castle" },
            { pos = Vector3.new(5650.9477539062, 1017.2747802734, -300.3791809082),    name = "Hydra" },
        }
    else
        return
    end
    local bestPos = nil
    local bestDist = math.huge
    for _, v in ipairs(tb) do
        local dToTarget = (v.pos - targetPos).Magnitude
        local dFromPlayer = (v.pos - playerPos).Magnitude
        if dToTarget < distPlayerToTarget and dFromPlayer > 500 then
            if dToTarget < bestDist then
                bestDist = dToTarget
                bestPos = v.pos
            end
        end
    end
    if not bestPos then return end
    local distPlayerToEntrance = (playerPos - bestPos).Magnitude
    if distPlayerToEntrance <= 500 then return end
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", bestPos)
    end)
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

local lastAutoRotateSet = nil

local function updateCharacter()
    Character = LocalPlayer.Character
    if not Character then return false end
    HRP      = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not HRP or not HRP.Parent then return false end
    if not Humanoid or not Humanoid.Health or Humanoid.Health <= 0 then return false end

    local shouldDisable = State.autoNearEnabled or State.autoFarmEnabled
        or State.autoBossEnabled or State.teleportTweenEnabled
    if shouldDisable and lastAutoRotateSet ~= false then
        pcall(function() Humanoid.AutoRotate = false end)
        lastAutoRotateSet = false
    elseif not shouldDisable and lastAutoRotateSet ~= true then
        pcall(function() Humanoid.AutoRotate = true end)
        lastAutoRotateSet = true
    end
    return true
end

local function doBypassToPos(targetPos, onArrived)
    if not targetPos then if onArrived then onArrived() end return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then if onArrived then onArrived() end return end
    local dist = (hrp.Position - targetPos).Magnitude
    if dist <= 1200 then
        if onArrived then onArrived() end
        return
    end
    task.spawn(function()
        local targetCF = Convert_CFrame(targetPos)
        if not targetCF then if onArrived then onArrived() end return end

        local entranceInfo = getEntranceForTarget(targetPos)
        if entranceInfo then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", entranceInfo.entrance)
            end)
            local afterHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if afterHrp then
                State.currentFlyCF = afterHrp.CFrame
            end
        end

        local maxHops = 10
        local hopCount = 0
        while hopCount < maxHops do
            local curChar = LocalPlayer.Character
            local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
            local curHum  = curChar and curChar:FindFirstChildOfClass("Humanoid")
            if not curHrp or not curHum or curHum.Health <= 0 then break end

            local curDist = (curHrp.Position - targetPos).Magnitude
            if curDist <= 1200 then break end

            local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
            local Spawns = WorldOrigin and WorldOrigin:FindFirstChild("PlayerSpawns")
            local Pirates = Spawns and Spawns:FindFirstChild("Pirates")
            if not Pirates then break end

            local playerPos = curHrp.Position
            local bestSpawn = nil
            local bestDist  = math.huge

            for _, v in ipairs(Pirates:GetChildren()) do
                local part = v:FindFirstChild("Part")
                if part then
                    local dToTarget   = (part.Position - targetPos).Magnitude
                    local dFromPlayer = (part.Position - playerPos).Magnitude
                    if dToTarget < curDist - 100 and dFromPlayer < bestDist then
                        bestDist  = dFromPlayer
                        bestSpawn = v
                    end
                end
            end

            if not bestSpawn then break end

            pcall(function()
                local h = curChar:FindFirstChildOfClass("Humanoid")
                if not h then return end
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetLastSpawnPoint", bestSpawn.Name)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
                curChar:PivotTo(bestSpawn.Part.CFrame)
                h:ChangeState(15)
            end)

            hopCount = hopCount + 1
            task.wait(0.4)

            local newChar = LocalPlayer.Character
            if newChar then
                local newHrp = newChar:FindFirstChild("HumanoidRootPart")
                if newHrp then State.currentFlyCF = newHrp.CFrame end
            end
        end

        local nc  = LocalPlayer.Character
        local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
        if nhr then State.currentFlyCF = nhr.CFrame end
        if onArrived then onArrived() end
    end)
end

local function cleanMonsterName(name)
    if not name then return "" end
    return (name:gsub("%s*%[.-%]", "")):match("^%s*(.-)%s*$") or ""
end

local function getEnemyDisplayName(model)
    if not model then return "" end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local display = hum and hum.DisplayName or ""
    if display and display ~= "" then
        return cleanMonsterName(display)
    end
    return cleanMonsterName(model.Name)
end

local function getMonsterSpawnFolder()
    return ReplicatedStorage:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
end

local function getBossSpawnFolder()
    local worldOrigin = Workspace:FindFirstChild("_WorldOrigin")
    return worldOrigin and worldOrigin:FindFirstChild("EnemySpawns")
end

local function isEnemyDead(enemy)
    if not enemy then return true end
    if not enemy.Parent then return true end
    if not enemy:IsDescendantOf(game) then return true end
 
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder or not enemy:IsDescendantOf(enemiesFolder) then return true end
 
    local hum = enemy:FindFirstChildOfClass("Humanoid")
    if not hum then return true end
    if not hum.Health or hum.Health <= 0 then return true end
 
    local ok, state = pcall(function() return hum:GetState() end)
    if ok and state == Enum.HumanoidStateType.Dead then return true end
 
    local root = enemy:FindFirstChild("HumanoidRootPart")
    if not root or not root.Parent then return true end
 
    return false
end

local function scanBossSpawns()
    local result = {}
    local seen   = {}
    local spawns = getBossSpawnFolder()
    if not spawns then return result end
 
    for _, part in ipairs(spawns:GetChildren()) do
        if part:IsA("BasePart") then
            local rawName = part.Name
            if (string.find(rawName, "%[Boss%]") or string.find(rawName, "%[Raid Boss%]")) then
                local cleanName = cleanMonsterName(rawName)
                if cleanName and cleanName ~= "" and not isBossIgnored(cleanName) then
                    if not seen[cleanName] then
                        seen[cleanName] = true
                        table.insert(result, { name = cleanName, pos = part.Position })
                    else
                        table.insert(result, { name = cleanName, pos = part.Position })
                    end
                end
            end
        end
    end
 
    table.sort(result, function(a, b) return a.name:lower() < b.name:lower() end)
    return result
end

local function getAllLiveBosses()
    local result = {}
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return result end
 
    for _, model in ipairs(enemiesFolder:GetChildren()) do
        if not isEnemyDead(model) then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local display = hum and hum.DisplayName or ""
 
            local rawForCheck = display ~= "" and display or model.Name
            if (string.find(rawForCheck, "%[Boss%]") or string.find(rawForCheck, "%[Raid Boss%]")) then
                local cleanName = cleanMonsterName(rawForCheck)
                if not isBossIgnored(cleanName) then
                    table.insert(result, model)
                end
            end
        end
    end
    return result
end

local function findBossByDisplayName(activeList)
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder or #activeList == 0 then return nil, nil end
 
    local charPos = HRP and HRP.Position
    local best, bestDist, bestName = nil, math.huge, nil
 
    for _, model in ipairs(enemiesFolder:GetChildren()) do
        if not isEnemyDead(model) then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local displayName = hum and hum.DisplayName or ""
            local cleanDisplay = cleanMonsterName(displayName)
            local cleanName    = cleanMonsterName(model.Name)

            local matchName = nil
            if cleanDisplay ~= "" and table.find(activeList, cleanDisplay) then
                matchName = cleanDisplay
            elseif table.find(activeList, cleanName) then
                matchName = cleanName
            end

            if matchName then
                local root = model:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = charPos and (charPos - root.Position).Magnitude or 0
                    if dist < bestDist then
                        best     = model
                        bestDist = dist
                        bestName = matchName
                    end
                end
            end
        end
    end
    return best, bestName
end

local function findBossInEnemies(targetName)
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end
 
    for _, model in ipairs(enemiesFolder:GetChildren()) do
        if not isEnemyDead(model) then
            local name = getEnemyDisplayName(model)
            if name == targetName then
                return model
            end
        end
    end
    return nil
end

local function cacheAllSpawns()
    Lists.cachedMobSpawns = {}
    Lists.masterBossSpawnList = {}

    local function cacheSpawnFolder(spawnsFolder, cacheMonsters, cacheBosses)
        if not spawnsFolder then return end
        for _, part in ipairs(spawnsFolder:GetChildren()) do
            local rawName = part.Name
            local pos = nil

            if part:IsA("BasePart") then
                pos = part.Position
            elseif part:IsA("Model") then
                local root = part:FindFirstChild("HumanoidRootPart") or part.PrimaryPart
                if root then pos = root.Position
                else
                    local ok, pivot = pcall(function() return part:GetPivot() end)
                    if ok then pos = pivot.Position end
                end
            end

            if pos then
                local cleanName = cleanMonsterName(rawName)
                if cleanName and cleanName ~= "" then
                    local isBoss = (string.find(rawName, "%[Boss%]") or string.find(rawName, "%[Raid Boss%]")) ~= nil

                    local shouldCacheMob = (cacheMonsters and not isBoss) or (cacheBosses and isBoss)
                    if shouldCacheMob then
                        if not Lists.cachedMobSpawns[cleanName] then
                            Lists.cachedMobSpawns[cleanName] = {}
                        end
                        local dupMob = false
                        for _, existing in ipairs(Lists.cachedMobSpawns[cleanName]) do
                            if (existing.pos - pos).Magnitude < 5 then dupMob = true; break end
                        end
                        if not dupMob then
                            table.insert(Lists.cachedMobSpawns[cleanName], { pos = pos, name = cleanName })
                        end
                    end

                    if cacheBosses and isBoss and not isBossIgnored(cleanName) then
                        local dupBoss = false
                        for _, existing in ipairs(Lists.masterBossSpawnList) do
                            if existing.name == cleanName or (existing.pos - pos).Magnitude < 5 then
                                dupBoss = true; break
                            end
                        end
                        if not dupBoss then
                            table.insert(Lists.masterBossSpawnList, { pos = pos, name = cleanName })
                            table.sort(Lists.masterBossSpawnList, function(a, b) return a.name:lower() < b.name:lower() end)
                        end
                    end
                end
            end
        end
    end

    -- Normal monsters use the replicated spawn-position folder.
    cacheSpawnFolder(getMonsterSpawnFolder(), true, false)
    -- Bosses continue using the original EnemySpawns folder.
    cacheSpawnFolder(getBossSpawnFolder(), false, true)
end

local function getSpawnsForList(activeList)
    local result = {}
    if not Lists.cachedMobSpawns then
        cacheAllSpawns()
    end
    for _, name in ipairs(activeList) do
        local spawns = Lists.cachedMobSpawns[name]
        if spawns and #spawns > 0 then
            for _, sp in ipairs(spawns) do
                table.insert(result, sp)
            end
        end
    end
    return result
end

local function getEnemyRoot(enemy)
    if not enemy or not enemy.Parent then return nil end
    return enemy:FindFirstChild("HumanoidRootPart")
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
    local spawns = getMonsterSpawnFolder()
    if spawns then
        for _, part in ipairs(spawns:GetChildren()) do
            local rawName = part.Name
            if string.find(rawName, "%[Boss%]") or string.find(rawName, "%[Raid Boss%]") then continue end
            if addDiscoveredMonster(rawName) then newlyFound = true end
        end
    end
    local enemies = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, model in ipairs(enemies:GetChildren()) do
            local hum = model:FindFirstChildOfClass("Humanoid")
            if not hum or not hum.Health or hum.Health <= 0 then continue end
            local displayName = hum.DisplayName or ""
            local rawName = displayName ~= "" and displayName or model.Name
            if string.find(rawName, "%[Boss%]") or string.find(rawName, "%[Raid Boss%]") then continue end
            if addDiscoveredMonster(rawName) then newlyFound = true end
            if addDiscoveredMonster(model.Name) then newlyFound = true end
        end
    end
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
    local charPos = (HRP and HRP.Position) 
        or (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position)
    if #monsterList == 0 then return nil, nil end
    for _, model in ipairs(folder:GetChildren()) do
        local hum = model:FindFirstChildOfClass("Humanoid")
        local displayName = hum and hum.DisplayName or ""
        local cleanDisplay = cleanMonsterName(displayName)
        local cleanName    = cleanMonsterName(model.Name)
        if string.find(displayName, "%[Boss%]") or string.find(displayName, "%[Raid Boss%]")
            or string.find(model.Name, "%[Boss%]") or string.find(model.Name, "%[Raid Boss%]") then
            continue
        end
        
        local matchName = nil
        if table.find(monsterList, cleanName) then
            matchName = cleanName
        elseif cleanDisplay ~= "" and table.find(monsterList, cleanDisplay) then
            matchName = cleanDisplay
        end
        
        if matchName then
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health and hum.Health > 0 then
                local dist = charPos and (charPos - root.Position).Magnitude or 0
                if dist < bestDist then
                    best     = model
                    bestDist = dist
                    bestName = matchName
                end
            end
        end
    end
    return best, bestName
end

local function findPriorityEnemyIncludeBoss(monsterList)
    local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if not folder then return nil, nil end
    local best, bestDist, bestName = nil, math.huge, nil
    local charPos = (HRP and HRP.Position)
        or (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position)
    if #monsterList == 0 then return nil, nil end

    for _, model in ipairs(folder:GetChildren()) do
        local hum = model:FindFirstChildOfClass("Humanoid")
        local displayName = hum and hum.DisplayName or ""
        local cleanDisplay = cleanMonsterName(displayName)
        local cleanName    = cleanMonsterName(model.Name)

        local matchName = nil
        if table.find(monsterList, cleanName) then
            matchName = cleanName
        elseif cleanDisplay ~= "" and table.find(monsterList, cleanDisplay) then
            matchName = cleanDisplay
        end

        if matchName then
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health and hum.Health > 0 then
                local dist = charPos and (charPos - root.Position).Magnitude or 0
                if dist < bestDist then
                    best     = model
                    bestDist = dist
                    bestName = matchName
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
    Lists.masterBossList   = {}
    Lists.discoveredBosses = {}
    local spawns = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then
        for _, part in ipairs(spawns:GetChildren()) do
            if (string.find(part.Name, "%[Boss%]") or string.find(part.Name, "%[Raid Boss%]")) then
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
            if (string.find(checkName, "%[Boss%]") or string.find(checkName, "%[Raid Boss%]")) then
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

local function getAllBossesInMap()
    local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
    local result = {}
    if not folder then return result end
    for _, model in ipairs(folder:GetChildren()) do
        local hum  = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health and hum.Health > 0 then
            local rawName = (hum.DisplayName and hum.DisplayName ~= "") and hum.DisplayName or model.Name
            if (string.find(rawName, "%[Boss%]") or string.find(rawName, "%[Raid Boss%]")) then
                local cleanName = cleanMonsterName(rawName)
                if not isBossIgnored(cleanName) then
                    table.insert(result, model)
                end
            end
        end
    end
    return result
end

local function getAllBossSpawns()
    cacheAllSpawns()
    return Lists.masterBossSpawnList
end

local function addDiscoveredBoss(rawName)
    if not rawName or not (string.find(rawName, "%[Boss%]") or string.find(rawName, "%[Raid Boss%]")) then return false end
    local clean = cleanMonsterName(rawName)
    if clean and clean ~= "" and clean ~= "(No Boss found)" and not Lists.discoveredBosses[clean] then
        Lists.discoveredBosses[clean] = true
        table.insert(Lists.masterBossList, clean)
        table.sort(Lists.masterBossList, function(a, b) return a:lower() < b:lower() end)
        return true
    end
    return false
end

local FastAttackModule      = { Rate = 0.15, Enabled = false }
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

local BRING_DISTANCE = 250
local BRING_INTERVAL = 0.1
local bringMobThread = nil

local function stopBringMob()
    if bringMobThread then
        task.cancel(bringMobThread)
        bringMobThread = nil
    end
end

local function startBringMob()
    stopBringMob()
    bringMobThread = task.spawn(function()
        while true do
            task.wait(BRING_INTERVAL)
            pcall(function()
                if not T("BringMobEnabled") then return end

                local anyFarm = State.autoFarmEnabled
                    or State.autoBossEnabled
                    or State.autoNearEnabled
                    or State.autoBossAllEnabled
                    or State.autoBossAllHopEnabled
                if not anyFarm then return end

                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local folder = workspace:FindFirstChild("Enemies")
                if not folder then return end

                local target = State.currentEnemy

                if not target or not target.Parent or isEnemyDead(target) then
                    for _, mob in ipairs(folder:GetChildren()) do
                        pcall(function()
                            local mr = mob:FindFirstChild("HumanoidRootPart")
                            if not mr then return end
                            local bp = mr:FindFirstChild("BringBodyPos")
                            if bp then bp:Destroy() end
                            local mh = mob:FindFirstChildOfClass("Humanoid")
                            if mh then
                                mh.WalkSpeed = 16
                                mh.JumpPower = 50
                            end
                        end)
                    end
                    return
                end

                local targetRoot = target:FindFirstChild("HumanoidRootPart")
                if not targetRoot or not targetRoot.Parent then return end

                local pullPos = targetRoot.Position
                local maxCount = tonumber(O("BringMobCount")) or 5

                local targetMonsterName = nil
                if LevelFarmState and LevelFarmState.enabled and LevelFarmState.questMonster ~= "" then
                    targetMonsterName = LevelFarmState.questMonster
                else
                    local th = target:FindFirstChildOfClass("Humanoid")
                    local td = th and th.DisplayName or ""
                    targetMonsterName = cleanMonsterName(td ~= "" and td or target.Name)
                end

                local validMobs = {}
                for _, mob in ipairs(folder:GetChildren()) do
                    if mob == target then continue end
                    local mr = mob:FindFirstChild("HumanoidRootPart")
                    local mh = mob:FindFirstChildOfClass("Humanoid")
                    if not mr or not mh or mh.Health <= 0 then continue end

                    local rawName = (mh.DisplayName ~= "" and mh.DisplayName) or mob.Name
                    if rawName:find("%[Boss%]") or rawName:find("%[Raid Boss%]") then continue end

                    local mobCleanName = cleanMonsterName(rawName)
                    if targetMonsterName and mobCleanName ~= targetMonsterName then continue end

                    local distFromMe = (mr.Position - hrp.Position).Magnitude
                    if distFromMe > BRING_DISTANCE then continue end
                    table.insert(validMobs, { mob = mob, mr = mr, mh = mh, dist = distFromMe })
                end

                table.sort(validMobs, function(a, b) return a.dist < b.dist end)

                local grabbed = 0
                for _, data in ipairs(validMobs) do
                    if grabbed >= maxCount then break end
                    grabbed = grabbed + 1

                    local mr  = data.mr
                    local mh  = data.mh
                    local mob = data.mob

                    pcall(function()
                        local oldBP = mr:FindFirstChild("BringBodyPos")
                        if oldBP then oldBP:Destroy() end

                        for _, p in ipairs(mob:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                                pcall(function()
                                    sethiddenproperty(p, "NetworkOwnershipRule", 0)
                                end)
                            end
                        end
                        pcall(function()
                            sethiddenproperty(mr, "NetworkOwnershipRule", 0)
                        end)

                        mh.WalkSpeed = 0
                        mh.JumpPower = 0

                        local destPos = pullPos + Vector3.new(
                            math.random(-3, 3), 0, math.random(-3, 3)
                        )

                        local distToTarget = (mr.Position - destPos).Magnitude

                        if distToTarget > 5 then
                            local bp = Instance.new("BodyPosition")
                            bp.Name     = "BringBodyPos"
                            bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                            bp.P        = 1e4
                            bp.D        = 500
                            bp.Position = destPos
                            bp.Parent   = mr

                            task.delay(1, function()
                                pcall(function()
                                    if bp and bp.Parent then bp:Destroy() end
                                end)
                            end)
                        else
                            mr.CFrame = CFrame.new(destPos)
                            mr.AssemblyLinearVelocity  = Vector3.zero
                            mr.AssemblyAngularVelocity = Vector3.zero
                        end
                    end)
                end
            end)
        end
    end)
end

startBringMob()

LocalPlayer.CharacterAdded:Connect(function() end)

function FastAttackModule.GetNearbyTargets(character, folder)
    if not folder or not character then return {} end
    local characterPosition = character:GetPivot().Position
    local nearbyTargets = {}
    local children = folder:GetChildren()
    for i = 1, #children do
        local target   = children[i]
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
    if Conns.fastAttackThread then return end
    FastAttackModule.Enabled = true
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
    if Conns.hitReg then return end
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

local noclipCache     = {}
local noclipCacheTick = 0
local NOCLIP_REBUILD  = 10
local NOCLIP_INTERVAL = 0
local noclipApplyTick = 0

local function startNoclip()
    if Conns.noclip then Conns.noclip:Disconnect() end
    noclipCache = {}; noclipCacheTick = 0; noclipApplyTick = 0

    -- Stepped runs before physics, so collision stays disabled during tween movement.
    Conns.noclip = RunService.Stepped:Connect(function()
        local now = tick()
        if now - noclipApplyTick < NOCLIP_INTERVAL then return end
        noclipApplyTick = now

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if now - noclipCacheTick > NOCLIP_REBUILD then
            noclipCacheTick = now
            noclipCache = {}
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    noclipCache[#noclipCache + 1] = part
                end
            end
            if State.currentEnemy and State.currentEnemy.Parent then
                for _, p in ipairs(State.currentEnemy:GetDescendants()) do
                    if p:IsA("BasePart") then
                        noclipCache[#noclipCache + 1] = p
                    end
                end
            end
        end

        for i = 1, #noclipCache do
            local part = noclipCache[i]
            if part and part.Parent and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if Conns.noclip then Conns.noclip:Disconnect(); Conns.noclip = nil end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            pcall(function()
                for _, desc in ipairs(enemy:GetDescendants()) do
                    if desc:IsA("BodyVelocity") and desc.Name == "BodyVelocity" then
                        desc:Destroy()
                    end
                end
            end)
        end
    end
    noclipCache = {}
    noclipCacheTick = 0
    noclipApplyTick = 0
end

local LOCK_INTERVAL = 0.1
local lockLastTick  = 0

local function startPositionLock()
    if Conns.lock then Conns.lock:Disconnect() end
    if Humanoid then
        pcall(function() Humanoid.AutoRotate = false end)
    end
    lockLastTick = tick()

    Conns.lock = RunService.Stepped:Connect(function()
        local now = tick()
        if now - lockLastTick < LOCK_INTERVAL then return end
        lockLastTick = now

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or not hum.Health or hum.Health <= 0 then return end

        pcall(function() hum.AutoRotate = false end)

        if not State.currentFlyCF then return end

        local bp = hrp:FindFirstChild("__LockBP")
        if not bp then
            bp = Instance.new("BodyPosition")
            bp.Name     = "__LockBP"
            bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.P        = 1e5
            bp.D        = 500
            bp.Parent   = hrp
        end
        bp.Position = State.currentFlyCF.Position

        local bg = hrp:FindFirstChild("__LockBG")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name      = "__LockBG"
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.P         = 1e5
            bg.D         = 500
            bg.Parent    = hrp
        end
        bg.CFrame = State.currentFlyCF

        hrp.CFrame = State.currentFlyCF
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    end)
end

local function stopPositionLock()
    if Conns.lock then Conns.lock:Disconnect(); Conns.lock = nil end
    State.currentFlyCF = nil
    task.defer(function()
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                local bp = hrp:FindFirstChild("__LockBP")
                local bg = hrp:FindFirstChild("__LockBG")
                if bp then bp:Destroy() end
                if bg then bg:Destroy() end
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            if hum then
                hum.AutoRotate = true
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end)
end

local lastMoveTime = 0
local MOVE_INTERVAL = 0.05

local function moveToTarget(hrp, targetCF, dt)
    if not hrp or not hrp.Parent or not targetCF then return end
    local hrpPos = hrp.Position
    if not State.currentFlyCF
        or not State.currentFlyCF.Position
        or (State.currentFlyCF.Position - hrpPos).Magnitude > 500 then
        State.currentFlyCF = hrp.CFrame
    end
    local targetPos  = targetCF.Position
    local currentPos = State.currentFlyCF.Position
    local delta      = targetPos - currentPos
    local dist       = delta.Magnitude
    local step       = (CFG.SPEED or 250) * dt
    local newPos     = (dist <= step or dist < 0.01) and targetPos or currentPos + (delta / dist) * step
    local rx, ry, rz = targetCF:ToEulerAnglesXYZ()
    local fullRot    = CFrame.fromEulerAnglesXYZ(rx, ry, rz)
    local finalCF    = CFrame.new(newPos) * fullRot
    State.currentFlyCF = finalCF
    pcall(function()
        hrp.CFrame = finalCF
    end)
end


local lastFarmBypassTick = 0
local farmHopThread = nil

local function getEntranceList()
    if sea1 then
        return {
            Vector3.new(3864.6879882812, 6.7369995117188, -1926.2139892578),
            Vector3.new(-4607.8232421875, 874.39099121094, -1667.5570068359),
            Vector3.new(-7894.6181640625, 5547.1420898438, -380.29098510742),
            Vector3.new(61163.8515625, 11.68000793457, 1819.7840576172),
        }
    elseif sea2 then
        return {
            Vector3.new(2284.9091796875, 15.537796020508, 905.46417236328),
            Vector3.new(-286.98596191406, 306.13739013672, 597.89910888672),
            Vector3.new(-6508.5581054688, 89.035003662109, -132.83999633789),
            Vector3.new(923.21301269531, 126.9759979248, 32852.83203125),
        }
    elseif sea3 then
        return {
            Vector3.new(-12463.602539062, 378.32705688477, -7533.0830078125),
            Vector3.new(-5060.4116210938, 318.50201416016, -3160.2248535156),
            Vector3.new(5650.9477539062, 1017.2747802734, -300.3791809082),
        }
    end
    return {}
end

local lastFarmBypassTick = 0
local farmBypassActive   = false
local BYPASS_CD_ENTRANCE = 4
local BYPASS_CD_SPAWN    = 3
local FARM_NEAR_DISTANCE = 2000

local function tryFarmBypass(targetPos)
    if not targetPos then return false end

    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local targetCF = Convert_CFrame(targetPos)
    if not targetCF then return false end

    local currentDist = (hrp.Position - targetCF.Position).Magnitude

    -- Nearby mobs should be reached normally.  In particular, do not let
    -- an entrance/bypass task from a previous target affect close targets.
    if currentDist <= FARM_NEAR_DISTANCE then return false end
    if farmBypassActive then return true end

    local now = tick()

    local entranceInfo = getEntranceForTarget(targetCF.Position)
    if entranceInfo then
        local distPlayerToEntrance = (hrp.Position - entranceInfo.entrance).Magnitude
        local distEntranceToTarget = (entranceInfo.entrance - targetCF.Position).Magnitude
        if currentDist > 2000
            and distPlayerToEntrance > 500
            and distEntranceToTarget < currentDist - 500 then
            if now - lastFarmBypassTick < BYPASS_CD_ENTRANCE then return true end
            lastFarmBypassTick = now
            farmBypassActive   = true
            task.spawn(function()
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", entranceInfo.entrance)
                end)
                local nc  = LocalPlayer.Character
                local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
                if nhr then State.currentFlyCF = nhr.CFrame end
                farmBypassActive = false
            end)
            return true
        end
        return false
    end

    if not State.farmBypassEnabled then return false end

    local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
    local Pirates = WorldOrigin
        and WorldOrigin:FindFirstChild("PlayerSpawns")
        and WorldOrigin.PlayerSpawns:FindFirstChild("Pirates")
    if not Pirates then return false end

    local bestSpawn, bestDist = nil, currentDist
    for _, v in ipairs(Pirates:GetChildren()) do
        local part = v:FindFirstChild("Part")
        if part then
            local dToTarget   = (part.Position - targetCF.Position).Magnitude
            local dFromPlayer = (part.Position - hrp.Position).Magnitude
            if dToTarget < currentDist - 500 and dFromPlayer <= 6000 and dToTarget < bestDist then
                bestDist  = dToTarget
                bestSpawn = v
            end
        end
    end
    if not bestSpawn then return false end

    if now - lastFarmBypassTick < BYPASS_CD_SPAWN then return true end
    lastFarmBypassTick = now
    farmBypassActive   = true

    task.spawn(function()
        local curChar = LocalPlayer.Character
        local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
        local curHum  = curChar and curChar:FindFirstChildOfClass("Humanoid")
        if not curHrp or not curHum or curHum.Health <= 0 then
            farmBypassActive = false; return
        end
        pcall(function()
            local h = curChar:FindFirstChildOfClass("Humanoid")
            if not h then return end
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetLastSpawnPoint", bestSpawn.Name)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
            curChar:PivotTo(bestSpawn.Part.CFrame)
            h:ChangeState(15)
        end)
        task.wait(0.5)
        local nc  = LocalPlayer.Character
        local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
        if nhr then State.currentFlyCF = nhr.CFrame end
        farmBypassActive = false
    end)

    return true
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

local function getOffsetCF(enemyCF)
    return enemyCF * CFrame.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 25, CFG.OFFSET_Z or 0)
end

local function lockToEnemy(hrp, hum, enemyLiveRoot)
    if not hrp or not hrp.Parent then return end
    if not hum or not hum.Health or hum.Health <= 0 then return end
    if not enemyLiveRoot or not enemyLiveRoot.Parent then return end
    local finalCF = getOffsetCF(enemyLiveRoot.CFrame)
    State.currentFlyCF = finalCF
    pcall(function()
        hrp.CFrame = finalCF
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        local bp = hrp:FindFirstChild("__LockBP")
        if not bp then
            bp = Instance.new("BodyPosition")
            bp.Name     = "__LockBP"
            bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.P        = 1e5
            bp.D        = 500
            bp.Parent   = hrp
        end
        bp.Position = finalCF.Position

        local bg = hrp:FindFirstChild("__LockBG")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name      = "__LockBG"
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.P         = 1e5
            bg.D         = 500
            bg.Parent    = hrp
        end
        bg.CFrame = finalCF
    end)
end

local function startAutoNear()
    if Conns.follow then Conns.follow:Disconnect() end
    local lockedEnemy = nil
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then State.currentFlyCF = hrp.CFrame end
    startPositionLock()
    Conns.follow = RunService.Heartbeat:Connect(function(dt)
        if not State.autoNearEnabled then
            if Conns.follow then Conns.follow:Disconnect(); Conns.follow = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            lockedEnemy = nil
            return
        end
        if not updateCharacter() then return end
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hrp.Parent then return end
        if not hum or not hum.Health or hum.Health <= 0 then
            stopFastAttack()
            lockedEnemy = nil
            State.currentEnemy = nil; State.trackedRoot = nil; State.currentFlyCF = nil
            return
        end
        HRP = hrp; Humanoid = hum; Character = c
        pcall(function() if Humanoid then Humanoid.AutoRotate = false end end)
        equipWeapon(State.selectedWeaponType)

        local lockedAlive = false
        if lockedEnemy and lockedEnemy.Parent then
            local lhum = lockedEnemy:FindFirstChildOfClass("Humanoid")
            local lroot = lockedEnemy:FindFirstChild("HumanoidRootPart")
            if lhum and lroot and lroot.Parent and lhum.Health and lhum.Health > 0 then
                lockedAlive = true
            end
        end

        if not lockedAlive then
            stopFastAttack()
            State.trackedRoot = nil
            lockedEnemy = getClosestEnemy()
            State.currentEnemy = lockedEnemy
            if not lockedEnemy then
                local spawnsFolder = getMonsterSpawnFolder()
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
        end

        State.currentEnemy = lockedEnemy
        if not State.trackedRoot or not State.trackedRoot.Parent or not lockedEnemy:IsAncestorOf(State.trackedRoot) then
            State.trackedRoot = getEnemyRoot(lockedEnemy)
        end
        if not State.trackedRoot then return end

        local enemyLiveRoot = State.trackedRoot
        if not enemyLiveRoot or not enemyLiveRoot.Parent then return end

        local enemyCF  = enemyLiveRoot.CFrame
        local targetCF = getOffsetCF(enemyCF)
        local dist     = (targetCF.Position - hrp.Position).Magnitude
        if dist > (CFG.REACH or 6) then
            stopFastAttack()
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
            FastAttackModule.Enabled = true
            startFastAttack(); startHitRegistration()
        end
    end)
end

local function startAutoFarm()
    if Conns.farm then Conns.farm:Disconnect(); Conns.farm = nil end
    
    local myGen = (math.random(1, 999999))
    local lockedEnemy = nil
    local spawnIdx = 1
    local waitAtSpawnTick = nil
    if HRP then State.currentFlyCF = HRP.CFrame end
    local lockedEnemy = nil
    local spawnIdx  = 1
    local waitAtSpawnTick = nil
    if HRP then State.currentFlyCF = HRP.CFrame end

    local function cleanupBringMob()
        local folder = workspace:FindFirstChild("Enemies")
        if not folder then return end
        for _, mob in ipairs(folder:GetChildren()) do
            pcall(function()
                local mr = mob:FindFirstChild("HumanoidRootPart")
                if not mr then return end
                local bp = mr:FindFirstChild("BringBodyPos")
                if bp then bp:Destroy() end
                local mh = mob:FindFirstChildOfClass("Humanoid")
                if mh then
                    mh.WalkSpeed = 16
                    mh.JumpPower = 50
                end
            end)
        end
    end

    cacheAllSpawns()
    local initList = updateSelectedMonstersList()
    if #initList > 0 then
        local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                local hum  = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")
                if not hum or not root or not hum.Health or hum.Health <= 0 then continue end
                local rawName = (hum.DisplayName ~= "" and hum.DisplayName) or model.Name
                if string.find(rawName, "%[Boss%]") or string.find(rawName, "%[Raid Boss%]") then continue end
                local cleanName = cleanMonsterName(model.Name)
                if not Lists.cachedMobSpawns[cleanName] then
                    Lists.cachedMobSpawns[cleanName] = {}
                end
                local spawnPos = root.Position
                local spawnsFolder = getMonsterSpawnFolder()
                if spawnsFolder then
                    local best, bestDist = nil, math.huge
                    for _, part in ipairs(spawnsFolder:GetChildren()) do
                        if part:IsA("BasePart") and cleanMonsterName(part.Name) == cleanName then
                            local d = (part.Position - root.Position).Magnitude
                            if d < bestDist then bestDist = d; best = part.Position end
                        end
                    end
                    if best then spawnPos = best end
                end
                local dup = false
                for _, ex in ipairs(Lists.cachedMobSpawns[cleanName]) do
                    if (ex.pos - spawnPos).Magnitude < 10 then dup = true; break end
                end
                if not dup then
                    table.insert(Lists.cachedMobSpawns[cleanName], { pos = spawnPos, name = cleanName })
                end
            end
        end

        cleanupBringMob()

        local immediateTarget = findPriorityEnemyIncludeBoss(initList)
        if immediateTarget then
            lockedEnemy = immediateTarget
            State.currentEnemy = lockedEnemy
        end
    end

    startPositionLock()
    Conns.farm = RunService.Heartbeat:Connect(function(dt)
        if not State.autoFarmEnabled then
            if Conns.farm then Conns.farm:Disconnect(); Conns.farm = nil end
            stopPositionLock()
            smoothCleanAll(); checkAndResumeFastAttack()
            cleanupBringMob()
            lockedEnemy = nil
            return
        end
        if not updateCharacter() then return end
        local activeList = updateSelectedMonstersList()
        if #activeList == 0 then return end
        equipWeapon(State.selectedWeaponType)

        local lockedAlive = false
        if lockedEnemy and lockedEnemy.Parent then
            local lhum  = lockedEnemy:FindFirstChildOfClass("Humanoid")
            local lroot = lockedEnemy:FindFirstChild("HumanoidRootPart")
            local lname = cleanMonsterName(lockedEnemy.Name)
            local ldisplay = lhum and cleanMonsterName(lhum.DisplayName) or ""
            if lhum and lroot and lroot.Parent and lhum.Health and lhum.Health > 0
                and (table.find(activeList, lname) or (ldisplay ~= "" and table.find(activeList, ldisplay))) then
                lockedAlive = true
            end
        end

        if not lockedAlive then
            stopFastAttack(); stopHitRegistration()
            State.trackedRoot = nil
            smoothCleanAll()
            cleanupBringMob()
            local newTarget, _ = findPriorityEnemyIncludeBoss(activeList)
            lockedEnemy = newTarget
            State.currentEnemy = lockedEnemy
        end

        if lockedEnemy and lockedEnemy.Parent then
            waitAtSpawnTick = nil
            local enemyHum  = lockedEnemy:FindFirstChildOfClass("Humanoid")
            local enemyRoot = lockedEnemy:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyRoot.Parent or not enemyHum or not enemyHum.Health or enemyHum.Health <= 0 then
                lockedEnemy = nil; State.currentEnemy = nil; State.trackedRoot = nil; return
            end
            State.currentEnemy = lockedEnemy
            if not State.trackedRoot or not State.trackedRoot.Parent or not lockedEnemy:IsAncestorOf(State.trackedRoot) then
                State.trackedRoot = getEnemyRoot(lockedEnemy)
            end
            if not State.trackedRoot then return end
            local enemyLiveRoot = State.trackedRoot
            if not enemyLiveRoot or not enemyLiveRoot.Parent then return end
            local enemyCF  = enemyLiveRoot.CFrame
            local targetCF = getOffsetCF(enemyCF)
            local hrpPos   = HRP and HRP.Position or targetCF.Position
            local dist     = (targetCF.Position - hrpPos).Magnitude
            if dist > (CFG.REACH or 6) then
                stopFastAttack()
                stopPositionLock()
                tryFarmBypass(targetCF.Position)
                if HRP then
                    State.currentFlyCF = HRP.CFrame
                    moveToTarget(HRP, targetCF, dt)
                end
            else
                local liveCF  = enemyLiveRoot.CFrame
                local finalCF = getOffsetCF(liveCF)
                State.currentFlyCF = finalCF
                if not Conns.lock then startPositionLock() end
                pcall(function()
                    if HRP then
                        HRP.CFrame = finalCF
                        HRP.AssemblyLinearVelocity  = Vector3.zero
                        HRP.AssemblyAngularVelocity = Vector3.zero
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                end)
                FastAttackModule.Enabled = true
                startFastAttack(); startHitRegistration()
            end
        else
            stopFastAttack(); stopHitRegistration()
            lockedEnemy = nil; State.currentEnemy = nil; State.trackedRoot = nil
            smoothCleanAll(); cleanupBringMob()

            local allSpawns = getSpawnsForList(activeList)
            if #allSpawns == 0 then return end
            if spawnIdx > #allSpawns then spawnIdx = 1 end

            local folder = Refs.EnemiesFolder or Workspace:FindFirstChild("Enemies")
            if folder then
                local charPos = HRP and HRP.Position
                local bestIdx, bestDist2 = nil, math.huge
                for idx, sp in ipairs(allSpawns) do
                    for _, model in ipairs(folder:GetChildren()) do
                        local mhum  = model:FindFirstChildOfClass("Humanoid")
                        local mroot = model:FindFirstChild("HumanoidRootPart")
                        if mhum and mroot and mhum.Health and mhum.Health > 0
                            and cleanMonsterName(model.Name) == sp.name then
                            local d = charPos and (mroot.Position - charPos).Magnitude or 0
                            if d < bestDist2 then bestDist2 = d; bestIdx = idx end
                        end
                    end
                end
                if bestIdx then spawnIdx = bestIdx; waitAtSpawnTick = nil end
            end

            local currentSpawn = allSpawns[spawnIdx]
            local hrpPos   = HRP and HRP.Position
            local spawnPos = currentSpawn.pos + Vector3.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 35, CFG.OFFSET_Z or 0)
            local targetCF = CFrame.new(spawnPos)
            local dist     = hrpPos and (spawnPos - hrpPos).Magnitude or math.huge

            if dist > 10 then
                waitAtSpawnTick = nil
                if HRP then
                    stopPositionLock()
                    State.currentFlyCF = HRP.CFrame
                    tryFarmBypass(spawnPos)
                    moveToTarget(HRP, targetCF, dt)
                end
            else
                stopPositionLock()
                State.currentFlyCF = nil
                pcall(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.AutoRotate = true
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end)

                local immediateTarget = findPriorityEnemy(activeList)
                if immediateTarget then
                    cleanupBringMob()
                    lockedEnemy = immediateTarget
                    State.currentEnemy = lockedEnemy
                    waitAtSpawnTick = nil
                    return
                end
                if not waitAtSpawnTick then
                    waitAtSpawnTick = tick()
                    Library:Notify({ Title = "Auto Farm", Description = "Checking at " .. currentSpawn.name .. " spawn...", Time = 1 })
                elseif tick() - waitAtSpawnTick >= 0.5 then
                    waitAtSpawnTick = nil
                    spawnIdx = (spawnIdx % #allSpawns) + 1
                end
            end
        end
    end)
end

local function getNextBossName(currentName, bossFilter)
    local allSpawns = scanBossSpawns()
    if #allSpawns == 0 then return "No Boss Spawn" end
    if bossFilter and #bossFilter > 0 then
        local filtered = {}
        for _, sp in ipairs(allSpawns) do
            if table.find(bossFilter, sp.name) then
                table.insert(filtered, sp)
            end
        end
        allSpawns = filtered
    end
    if #allSpawns == 0 then return "No Boss Spawn" end
    for i, sp in ipairs(allSpawns) do
        if sp.name == currentName then
            local nextIdx = (i % #allSpawns) + 1
            return allSpawns[nextIdx].name
        end
    end
    return allSpawns[1].name
end

local function startAutoBoss()
    if Conns.boss then Conns.boss:Disconnect() end
    local lockedEnemy = nil
    local notified = false
    State.bossSpawnIdx = 1
    State.bossWaitTick = nil
    local searchCooldown = 0
    if HRP then State.currentFlyCF = HRP.CFrame end
    startPositionLock()
 
    Conns.boss = RunService.Heartbeat:Connect(function(dt)
        if not State.autoBossEnabled then
            if Conns.boss then Conns.boss:Disconnect(); Conns.boss = nil end
            stopPositionLock()
            smoothCleanAll(); checkAndResumeFastAttack()
            lockedEnemy = nil
            return
        end
        if not updateCharacter() then return end
        local activeList = updateSelectedBossesList()
        if #activeList == 0 then return end
        equipWeapon(State.selectedWeaponType)

        local lockedAlive = false
        if lockedEnemy then
            if not isEnemyDead(lockedEnemy) then
                local name = getEnemyDisplayName(lockedEnemy)
                if table.find(activeList, name) then
                    lockedAlive = true
                end
            end
            if not lockedAlive then
                lockedEnemy = nil
                notified = false
                State.currentEnemy = nil
                State.trackedRoot  = nil
                searchCooldown = tick() + 1
                stopFastAttack(); stopHitRegistration()
            end
        end

        if not lockedAlive and not lockedEnemy then
            if tick() < searchCooldown then return end

            local newTarget, newName = findBossByDisplayName(activeList)
            if newTarget and newName then
                lockedEnemy = newTarget
                State.currentEnemy = lockedEnemy
                State.bossWaitTick = nil
                notified = false
                local bossHum = lockedEnemy:FindFirstChildOfClass("Humanoid")
                if bossHum then
                    bossHum.Died:Once(function()
                        if lockedEnemy == newTarget then
                            lockedEnemy = nil
                            notified = false
                            State.currentEnemy = nil
                            State.trackedRoot  = nil
                            searchCooldown = tick() + 1
                            stopFastAttack(); stopHitRegistration()
                        end
                    end)
                end
                if not notified then
                    notified = true
                    local nextSpawn = getNextBossName(newName, activeList)
                    Library:Notify({ Title = "Auto Boss", Description = "Target: " .. newName .. " | Next: " .. nextSpawn, Time = 5 })
                end
            else
                lockedEnemy = nil; State.currentEnemy = nil
            end
        end

        if lockedEnemy and not isEnemyDead(lockedEnemy) then
            State.bossWaitTick = nil
            local enemyRoot = lockedEnemy:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyRoot.Parent then
                lockedEnemy = nil; notified = false; State.currentEnemy = nil; State.trackedRoot = nil
                searchCooldown = tick() + 1
                stopFastAttack(); stopHitRegistration()
                return
            end
 
            State.currentEnemy = lockedEnemy
            if not State.trackedRoot or not State.trackedRoot.Parent
                or not lockedEnemy:IsAncestorOf(State.trackedRoot) then
                State.trackedRoot = getEnemyRoot(lockedEnemy)
            end
            if not State.trackedRoot then return end
 
            local enemyLiveRoot = State.trackedRoot
            if not enemyLiveRoot or not enemyLiveRoot.Parent then return end
 
            local enemyCF = enemyLiveRoot.CFrame
            
            
 
            local targetCF = getOffsetCF(enemyCF)
            local dist = (targetCF.Position - (HRP and HRP.Position or targetCF.Position)).Magnitude
 
            if dist > (CFG.REACH or 6) then
                stopFastAttack(); stopHitRegistration()
                tryFarmBypass(targetCF.Position)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                if not Conns.lock then startPositionLock() end
                local finalCF = getOffsetCF(enemyLiveRoot.CFrame)
                State.currentFlyCF = finalCF
                pcall(function()
                    if HRP then
                        HRP.CFrame = finalCF
                        HRP.AssemblyLinearVelocity  = Vector3.zero
                        HRP.AssemblyAngularVelocity = Vector3.zero
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                end)
            FastAttackModule.Enabled = true
            startFastAttack(); startHitRegistration()
            end
        else
            stopFastAttack(); stopHitRegistration()
            notified = false
            lockedEnemy = nil; State.currentEnemy = nil; State.trackedRoot = nil; smoothCleanAll()
 
            local allSpawns = getSpawnsForList(activeList)
            if #allSpawns == 0 then
                allSpawns = {}
                for _, sp in ipairs(scanBossSpawns()) do
                    if table.find(activeList, sp.name) then
                        table.insert(allSpawns, sp)
                    end
                end
            end
            if #allSpawns == 0 then return end
 
            if State.bossSpawnIdx > #allSpawns then State.bossSpawnIdx = 1 end
            local currentSpawn = allSpawns[State.bossSpawnIdx]
            local spawnPos = currentSpawn.pos + Vector3.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 35, CFG.OFFSET_Z or 0)
            local targetCF = CFrame.new(spawnPos)
            local currentPos = (State.currentFlyCF and State.currentFlyCF.Position) or (HRP and HRP.Position)
            local dist = currentPos and (spawnPos - currentPos).Magnitude or math.huge
 
            if dist > 20 then
                State.bossWaitTick = nil
                tryFarmBypass(spawnPos)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                State.currentFlyCF = targetCF
                pcall(function()
                    if HRP then
                        HRP.CFrame = targetCF
                        HRP.AssemblyLinearVelocity  = Vector3.zero
                        HRP.AssemblyAngularVelocity = Vector3.zero
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                end)
                if not State.bossWaitTick then
                    State.bossWaitTick = tick()
                    Library:Notify({ Title = "Auto Boss", Description = "Checking at " .. currentSpawn.name .. " (10s)...", Time = 3 })
                elseif tick() - State.bossWaitTick >= 10 then
                    State.bossWaitTick = nil
                    State.bossSpawnIdx = (State.bossSpawnIdx % #allSpawns) + 1
                    Library:Notify({ Title = "Auto Boss", Description = currentSpawn.name .. " not spawned → next...", Time = 3 })
                end
            end
        end
    end)
end

local function startAutoBossAll()
    if Conns.bossAll then Conns.bossAll:Disconnect() end
    local lockedEnemy = nil
    local searchCooldown = 0
    State.bossAllSpawnIdx = 1
    State.bossAllWaitTick = nil
    if HRP then State.currentFlyCF = HRP.CFrame end

    Conns.bossAll = RunService.Heartbeat:Connect(function(dt)
        if not State.autoBossAllEnabled then
            if Conns.bossAll then Conns.bossAll:Disconnect(); Conns.bossAll = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            lockedEnemy = nil; return
        end
        if not updateCharacter() then return end
        equipWeapon(State.selectedWeaponType)

        local lockedAlive = false
        if lockedEnemy then
            if not isEnemyDead(lockedEnemy) then
                lockedAlive = true
            else
                lockedEnemy = nil
                State.currentEnemy = nil; State.trackedRoot = nil
                searchCooldown = tick() + 1
                stopFastAttack(); stopHitRegistration()
            end
        end

        if not lockedAlive and not lockedEnemy then
            if tick() < searchCooldown then return end
            local liveBosses = getAllLiveBosses()
            if #liveBosses > 0 then
                local curChar = LocalPlayer.Character
                local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                if not curHrp then return end
                local charPos = curHrp.Position
                local best, bestDist = nil, math.huge
                for _, boss in ipairs(liveBosses) do
                    local root = boss:FindFirstChild("HumanoidRootPart")
                    if root then
                        local d = (root.Position - charPos).Magnitude
                        if d < bestDist then bestDist = d; best = boss end
                    end
                end
                if best then
                    lockedEnemy = best
                    State.currentEnemy = lockedEnemy
                    State.bossAllWaitTick = nil
                    local bossHum = lockedEnemy:FindFirstChildOfClass("Humanoid")
                    if bossHum then
                        bossHum.Died:Once(function()
                            if lockedEnemy == best then
                                lockedEnemy = nil
                                State.currentEnemy = nil; State.trackedRoot = nil
                                searchCooldown = tick() + 1
                                stopFastAttack(); stopHitRegistration()
                            end
                        end)
                    end
                    local curName = getEnemyDisplayName(lockedEnemy)
                    local nextName = getNextBossName(curName, nil)
                    Library:Notify({ Title = "Boss All", Description = curName .. " | Next: " .. nextName, Time = 5 })
                end
            else
                lockedEnemy = nil; State.currentEnemy = nil
            end
        end

        if lockedEnemy and not isEnemyDead(lockedEnemy) then
            State.bossAllWaitTick = nil
            local enemyRoot = lockedEnemy:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyRoot.Parent then
                lockedEnemy = nil; State.currentEnemy = nil; State.trackedRoot = nil
                searchCooldown = tick() + 1
                stopFastAttack(); stopHitRegistration()
                return
            end
            State.currentEnemy = lockedEnemy
            if not State.trackedRoot or not State.trackedRoot.Parent
                or not lockedEnemy:IsAncestorOf(State.trackedRoot) then
                State.trackedRoot = getEnemyRoot(lockedEnemy)
            end
            if not State.trackedRoot then return end
            local enemyLiveRoot = State.trackedRoot
            if not enemyLiveRoot or not enemyLiveRoot.Parent then return end
            local enemyCF = enemyLiveRoot.CFrame
            
            
            local targetCF = getOffsetCF(enemyCF)
            local dist = (targetCF.Position - (HRP and HRP.Position or targetCF.Position)).Magnitude
            if dist > (CFG.REACH or 6) then
                stopFastAttack(); stopHitRegistration()
                tryFarmBypass(targetCF.Position)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                local finalCF = getOffsetCF(enemyLiveRoot.CFrame)
                State.currentFlyCF = finalCF
                pcall(function()
                    if HRP then
                        HRP.CFrame = finalCF
                        HRP.AssemblyLinearVelocity  = Vector3.zero
                        HRP.AssemblyAngularVelocity = Vector3.zero
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                end)
            FastAttackModule.Enabled = true
            startFastAttack(); startHitRegistration()
            end
        else
            stopFastAttack(); stopHitRegistration()
            lockedEnemy = nil; State.currentEnemy = nil; State.trackedRoot = nil; smoothCleanAll()
            local allSpawns = scanBossSpawns()
            if #allSpawns == 0 then return end
            if State.bossAllSpawnIdx > #allSpawns then State.bossAllSpawnIdx = 1 end
            local currentSpawn = allSpawns[State.bossAllSpawnIdx]
            local spawnPos = currentSpawn.pos + Vector3.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 25, CFG.OFFSET_Z or 0)
            local targetCF = CFrame.new(spawnPos)
            local currentPos = (State.currentFlyCF and State.currentFlyCF.Position) or (HRP and HRP.Position)
            local dist = currentPos and (spawnPos - currentPos).Magnitude or math.huge
            if dist > (CFG.REACH or 6) then
                State.bossAllWaitTick = nil
                tryFarmBypass(spawnPos)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                if not State.bossAllWaitTick then
                    State.bossAllWaitTick = tick()
                elseif tick() - State.bossAllWaitTick >= 5 then
                    State.bossAllWaitTick = nil
                    State.bossAllSpawnIdx = (State.bossAllSpawnIdx % #allSpawns) + 1
                end
            end
        end
    end)
end

local doHop

local function startAutoBossAllHop()
    if Conns.bossAllHop then Conns.bossAllHop:Disconnect() end
    local prevEnemy   = nil
    local lockedEnemy = nil
    local searchCooldown = 0
    State.bossAllSpawnIdx    = 1
    State.bossAllWaitTick    = nil
    State.bossAllHopWaitTick = nil
    State.bossAllNoBossCount = 0
    local visitedSpawnsCount = 0
    local checkedSpawns = {}
    if HRP then State.currentFlyCF = HRP.CFrame end

    Conns.bossAllHop = RunService.Heartbeat:Connect(function(dt)
        if not State.autoBossAllHopEnabled then
            if Conns.bossAllHop then Conns.bossAllHop:Disconnect(); Conns.bossAllHop = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            return
        end
        if not updateCharacter() then return end
        equipWeapon(State.selectedWeaponType)

        local lockedAlive = false
        if lockedEnemy then
            if not isEnemyDead(lockedEnemy) then
                lockedAlive = true
            else
                lockedEnemy = nil; prevEnemy = nil
                State.currentEnemy = nil; State.trackedRoot = nil
                searchCooldown = tick() + 1
                stopFastAttack(); stopHitRegistration()
            end
        end

        if not lockedAlive and not lockedEnemy then
            if tick() < searchCooldown then return end
            local liveBosses = getAllLiveBosses()
            if #liveBosses > 0 then
                local curChar = LocalPlayer.Character
                local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                if not curHrp then return end
                local charPos = curHrp.Position
                local best, bestDist = nil, math.huge
                for _, boss in ipairs(liveBosses) do
                    local root = boss:FindFirstChild("HumanoidRootPart")
                    if root then
                        local d = (root.Position - charPos).Magnitude
                        if d < bestDist then bestDist = d; best = boss end
                    end
                end
                if best then
                    lockedEnemy = best
                    prevEnemy = nil
                    State.currentEnemy = lockedEnemy
                    State.bossAllHopWaitTick = nil
                    local bossHum = lockedEnemy:FindFirstChildOfClass("Humanoid")
                    if bossHum then
                        bossHum.Died:Once(function()
                            if lockedEnemy == best then
                                lockedEnemy = nil; prevEnemy = nil
                                State.currentEnemy = nil; State.trackedRoot = nil
                                searchCooldown = tick() + 1
                                stopFastAttack(); stopHitRegistration()
                            end
                        end)
                    end
                    Library:Notify({ Title = "Auto Boss", Description = "Targeting: " .. getEnemyDisplayName(lockedEnemy), Time = 3 })
                end
            else
                lockedEnemy = nil; State.currentEnemy = nil
            end
        end

        if lockedEnemy and not isEnemyDead(lockedEnemy) then
            State.bossAllHopWaitTick = nil
            local enemyRoot = lockedEnemy:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyRoot.Parent then
                lockedEnemy = nil; prevEnemy = nil
                State.currentEnemy = nil; State.trackedRoot = nil
                searchCooldown = tick() + 1
                stopFastAttack(); stopHitRegistration()
                return
            end
            State.currentEnemy = lockedEnemy
            if State.trackedRoot == nil or State.trackedRoot.Parent == nil
                or not lockedEnemy:IsAncestorOf(State.trackedRoot) then
                State.trackedRoot = getEnemyRoot(lockedEnemy)
            end
            if not State.trackedRoot then return end
            local enemyLiveRoot = State.trackedRoot
            if not enemyLiveRoot or not enemyLiveRoot.Parent then return end
            local enemyCF = enemyLiveRoot.CFrame
            
            
            local targetCF = getOffsetCF(enemyCF)
            local dist = (targetCF.Position - (HRP and HRP.Position or targetCF.Position)).Magnitude
            if dist > (CFG.REACH or 6) then
                stopFastAttack(); stopHitRegistration(); prevEnemy = nil
                tryFarmBypass(targetCF.Position)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                local finalCF = getOffsetCF(enemyLiveRoot.CFrame)
                State.currentFlyCF = finalCF
                pcall(function()
                    if HRP then
                        HRP.CFrame = finalCF
                        HRP.AssemblyLinearVelocity  = Vector3.zero
                        HRP.AssemblyAngularVelocity = Vector3.zero
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                end)
                if lockedEnemy ~= prevEnemy then
                    prevEnemy = lockedEnemy
            FastAttackModule.Enabled = true
            startFastAttack(); startHitRegistration()
                end
            end
        else
            stopFastAttack(); stopHitRegistration()
            prevEnemy = nil; lockedEnemy = nil; State.currentEnemy = nil; State.trackedRoot = nil; smoothCleanAll()

            local allSpawns = scanBossSpawns()
            if #allSpawns == 0 then
                Library:Notify({ Title = "Auto Boss", Description = "No valid boss spawns found. Hopping now...", Time = 5 })
                if Conns.bossAllHop then Conns.bossAllHop:Disconnect(); Conns.bossAllHop = nil end
                stopPositionLock(); stopNoclip(); smoothCleanAll()
                task.spawn(function()
                    doHop()
                    task.wait(8)
                    if State.autoBossAllHopEnabled then
                        if Toggles and Toggles.AutoBossAllHop then
                            Toggles.AutoBossAllHop:SetValue(true)
                        end
                    end
                end)
                return
            end

            local totalSpawns = #allSpawns
            local checkedCount = 0
            for _ in pairs(checkedSpawns) do checkedCount = checkedCount + 1 end

            if checkedCount >= totalSpawns then
                Library:Notify({ Title = "Auto Boss", Description = "Checked all " .. totalSpawns .. " spawns, no boss found. Hopping now...", Time = 5 })
                visitedSpawnsCount = 0; checkedSpawns = {}
                State.bossAllSpawnIdx = 1; State.bossAllHopWaitTick = nil
                if Conns.bossAllHop then Conns.bossAllHop:Disconnect(); Conns.bossAllHop = nil end
                stopPositionLock(); stopNoclip(); smoothCleanAll()
                task.spawn(function()
                    doHop()
                    task.wait(8)
                    if State.autoBossAllHopEnabled then
                        if Toggles and Toggles.AutoBossAllHop then
                            Toggles.AutoBossAllHop:SetValue(true)
                        end
                    end
                end)
                return
            end

            if State.bossAllSpawnIdx > totalSpawns then State.bossAllSpawnIdx = 1 end
            local startIdx = State.bossAllSpawnIdx
            local foundUnchecked = false
            for i = 0, totalSpawns - 1 do
                local idx = ((startIdx - 1 + i) % totalSpawns) + 1
                if not checkedSpawns[idx] then
                    State.bossAllSpawnIdx = idx
                    foundUnchecked = true
                    break
                end
            end
            if not foundUnchecked then
                checkedSpawns = {}; visitedSpawnsCount = 0; State.bossAllSpawnIdx = 1
                return
            end

            local currentSpawn = allSpawns[State.bossAllSpawnIdx]
            local spawnPos = currentSpawn.pos + Vector3.new(CFG.OFFSET_X or 0, CFG.OFFSET_Y or 35, CFG.OFFSET_Z or 0)
            local targetCF = CFrame.new(spawnPos)
            local currentPos = (State.currentFlyCF and State.currentFlyCF.Position) or (HRP and HRP.Position)
            local dist = currentPos and (spawnPos - currentPos).Magnitude or math.huge

            if dist > 20 then
                State.bossAllHopWaitTick = nil
                tryFarmBypass(spawnPos)
                if HRP then moveToTarget(HRP, targetCF, dt) end
            else
                State.currentFlyCF = targetCF
                pcall(function()
                    if HRP then
                        HRP.CFrame = targetCF
                        HRP.AssemblyLinearVelocity  = Vector3.zero
                        HRP.AssemblyAngularVelocity = Vector3.zero
                        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    end
                end)
                if not State.bossAllHopWaitTick then
                    State.bossAllHopWaitTick = tick()
                    Library:Notify({ Title = "Auto Boss", Description = "Checking: " .. currentSpawn.name .. " (" .. (checkedCount + 1) .. "/" .. totalSpawns .. ") 10s...", Time = 3 })
                elseif tick() - State.bossAllHopWaitTick >= 10 then
                    State.bossAllHopWaitTick = nil
                    checkedSpawns[State.bossAllSpawnIdx] = true
                    visitedSpawnsCount = visitedSpawnsCount + 1

                    local liveBossCheck = getAllLiveBosses()
                    if #liveBossCheck > 0 then return end

                    local nextFound = false
                    for i = 1, totalSpawns do
                        local nextIdx = (State.bossAllSpawnIdx % totalSpawns) + 1
                        State.bossAllSpawnIdx = nextIdx
                        if not checkedSpawns[nextIdx] then
                            nextFound = true
                            Library:Notify({ Title = "Auto Boss", Description = "Next: " .. allSpawns[nextIdx].name .. " (" .. (visitedSpawnsCount + 1) .. "/" .. totalSpawns .. ")", Time = 3 })
                            break
                        end
                    end
                    if not nextFound then
                        Library:Notify({ Title = "Auto Boss", Description = "All spawns checked. Preparing to hop...", Time = 3 })
                    end
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
        local targetPos = State.selectedIslandPos

        local function getAllEntrances()
            if sea1 then
                return {
                    { pos = Vector3.new(3864.6879882812, 6.7369995117188, -1926.2139892578),  name = "Whirlpool" },
                    { pos = Vector3.new(-4607.8232421875, 874.39099121094, -1667.5570068359), name = "Sky1" },
                    { pos = Vector3.new(-7894.6181640625, 5547.1420898438, -380.29098510742), name = "Sky2" },
                    { pos = Vector3.new(61163.8515625, 11.68000793457, 1819.7840576172),      name = "Underwater" },
                }
            elseif sea2 then
                return {
                    { pos = Vector3.new(2284.9091796875, 15.537796020508, 905.46417236328),   name = "Dock" },
                    { pos = Vector3.new(-286.98596191406, 306.13739013672, 597.89910888672),  name = "Cafe" },
                    { pos = Vector3.new(-6508.5581054688, 89.035003662109, -132.83999633789), name = "CursedShip" },
                    { pos = Vector3.new(923.21301269531, 126.9759979248, 32852.83203125),     name = "Far" },
                }
            elseif sea3 then
                return {
                    { pos = Vector3.new(-12463.602539062, 378.32705688477, -7533.0830078125), name = "Mansion" },
                    { pos = Vector3.new(-5060.4116210938, 318.50201416016, -3160.2248535156), name = "Castle" },
                    { pos = Vector3.new(5650.9477539062, 1017.2747802734, -300.3791809082),   name = "Hydra" },
                }
            end
            return {}
        end

        local usedEntrances = {}

        local function getBestEntrance()
            local hrpNow = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrpNow then return nil end
            local playerPos  = hrpNow.Position
            local distToTarget = (playerPos - targetPos).Magnitude
            if distToTarget <= 1000 then return nil end

            local best, bestScore = nil, math.huge
            for _, e in ipairs(getAllEntrances()) do
                if usedEntrances[e.name] then continue end
                local dEntranceToTarget = (e.pos - targetPos).Magnitude
                local dPlayerToEntrance = (e.pos - playerPos).Magnitude
                if dEntranceToTarget < distToTarget - 200 then
                    local score = dEntranceToTarget
                    if score < bestScore then
                        bestScore = score
                        best = e
                    end
                end
            end
            return best
        end

        for _ = 1, 5 do
            local entrance = getBestEntrance()
            if not entrance then break end

            local hrpNow = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrpNow then break end

            Library:Notify({ Title = "Teleport", Description = "Entrance: " .. entrance.name, Time = 2 })
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", entrance.pos)
            end)
            usedEntrances[entrance.name] = true

            local nc  = LocalPlayer.Character
            local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
            if nhr then State.currentFlyCF = nhr.CFrame end
        end

        local nc  = LocalPlayer.Character
        local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
        if nhr then State.currentFlyCF = nhr.CFrame end
    end)

    Conns.teleport = RunService.Heartbeat:Connect(function(dt)
        if not State.teleportTweenEnabled then stopTeleportTween(); return end
        if not updateCharacter() then return end
        if not State.selectedIslandPos then return end
        if not HRP or not HRP.Parent then return end

        local targetPos  = State.selectedIslandPos
        local targetCF   = CFrame.new(targetPos)
        local currentPos = State.currentFlyCF and State.currentFlyCF.Position or HRP.Position
        local dist       = (targetPos - currentPos).Magnitude

        if dist > (CFG.REACH or 6) then
            local diffY = math.abs(currentPos.Y - targetPos.Y)
            if diffY <= 50 and diffY > 1 then
                snapYToTarget(HRP, targetPos.Y)
            end
            moveToTarget(HRP, targetCF, dt)
        else
            State.currentFlyCF = targetCF
            pcall(function()
                HRP.CFrame = targetCF
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
            end)
            if Toggles and Toggles.TweenToIsland then
                Toggles.TweenToIsland:SetValue(false)
            end
            Library:Notify({ Title = "Teleport", Description = "Arrived at " .. tostring(State.selectedIslandName), Time = 3 })
        end
    end)
end

local bypassTpArrived = false
local bypassActive    = false

local function stopBypassTp()
    State.bypassTpEnabled = false
    State.bypassMoving    = false
    bypassActive          = false
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
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hum then
        hum.AutoRotate    = true
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end
    if hrp then
        pcall(function()
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    State.currentFlyCF = nil
end

local function startBypassTp()
    if bypassTpArrived then return end

    bypassActive          = false
    State.bypassMoving    = false
    State.bypassTpEnabled = true

    if Conns.bypassTp then Conns.bypassTp:Disconnect(); Conns.bypassTp = nil end
    if not State.selectedIslandPos then return end

    bypassActive = true

    task.spawn(function()
        local targetPos = State.selectedIslandPos
        local targetCF  = CFrame.new(targetPos)

        local entranceInfo = getEntranceForTarget(targetPos)
        if entranceInfo then
            Library:Notify({ Title = "Bypass TP", Description = "Entrance: " .. entranceInfo.name, Time = 2 })
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", entranceInfo.entrance)
            end)
            local afterHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if afterHrp then State.currentFlyCF = afterHrp.CFrame end
        end

        if not State.bypassTpEnabled then
            State.bypassMoving = false; bypassActive = false; return
        end

        local hopCount = 0
        local maxHops  = 10

    while hopCount < maxHops and State.bypassTpEnabled do
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            task.wait(0.3); break
        end

        local playerPos = hrp.Position
        local dist = (playerPos - targetPos).Magnitude
        if dist <= 1200 then break end

        local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
        local Pirates = WorldOrigin
            and WorldOrigin:FindFirstChild("PlayerSpawns")
            and WorldOrigin.PlayerSpawns:FindFirstChild("Pirates")
        if not Pirates then break end

        local dirToTarget = (Vector3.new(targetPos.X, 0, targetPos.Z) 
                        - Vector3.new(playerPos.X, 0, playerPos.Z)).Unit

        local best, bestDot = nil, -math.huge

        for _, v in ipairs(Pirates:GetChildren()) do
            local part = v:FindFirstChild("Part")
            if part then
                local spawnPos = part.Position
                local dToTarget   = (spawnPos - targetPos).Magnitude
                local dFromPlayer = (spawnPos - playerPos).Magnitude

                if dToTarget >= dist - 100 then continue end
                if dFromPlayer > 6000 then continue end

                local dirToSpawn = (Vector3.new(spawnPos.X, 0, spawnPos.Z) 
                                - Vector3.new(playerPos.X, 0, playerPos.Z))
                if dirToSpawn.Magnitude < 1 then continue end
                dirToSpawn = dirToSpawn.Unit

                local dot = dirToTarget:Dot(dirToSpawn)

                if dot > bestDot then
                    bestDot = dot
                    best    = v
                end
            end
        end

        if not best then break end

        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetLastSpawnPoint", best.Name)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
            char:PivotTo(best.Part.CFrame)
            hum:ChangeState(15)
        end)

        hopCount = hopCount + 1
        task.wait(0.35)

        local nc  = LocalPlayer.Character
        local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
        if nhr then State.currentFlyCF = nhr.CFrame end
    end

        if not State.bypassTpEnabled then
            State.bypassMoving = false; bypassActive = false; return
        end

        local nc  = LocalPlayer.Character
        local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
        if nhr then
            local snapDist = (nhr.Position - targetPos).Magnitude
            if snapDist <= 1200 then
                State.currentFlyCF = nhr.CFrame
            else
                pcall(function()
                    nhr.CFrame = targetCF
                    nhr.AssemblyLinearVelocity  = Vector3.zero
                    nhr.AssemblyAngularVelocity = Vector3.zero
                end)
                State.currentFlyCF = targetCF
            end
        end

        State.bypassMoving = false
        startNoclip()
        startPositionLock()

        local lastTick = tick()

        Conns.bypassTp = RunService.Heartbeat:Connect(function(dt)
            if not State.bypassTpEnabled then stopBypassTp(); return end

            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then return end

            if not State.currentFlyCF
                or (State.currentFlyCF.Position - hrp.Position).Magnitude > 500 then
                State.currentFlyCF = hrp.CFrame
            end

            local dist = (targetPos - State.currentFlyCF.Position).Magnitude

            if dist > 8 then
                moveToTarget(hrp, targetCF, dt)
            else
                bypassTpArrived    = true
                State.currentFlyCF = targetCF
                pcall(function()
                    hrp.CFrame = targetCF
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                pcall(function()
                    if Toggles.BypassTeleport then
                        Toggles.BypassTeleport:SetValue(false)
                    end
                end)
                stopBypassTp()
                Library:Notify({ Title = "Bypass TP", Description = "Arrived: " .. tostring(State.selectedIslandName), Time = 3 })
                task.delay(2, function() bypassTpArrived = false; bypassActive = false end)
            end
        end)
    end)
end

local function checkIsMyBoat(boat)
    if not boat then return false end
    local owner = boat:FindFirstChild("Owner")
    if owner then
        if owner:IsA("StringValue") or owner:IsA("ObjectValue") then
            if tostring(owner.Value) == LocalPlayer.Name or owner.Value == LocalPlayer then return true end
        elseif tostring(owner) == LocalPlayer.Name then return true end
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
            local shouldApply = (State.boatTargetMode == "All") or isMine
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

local function startBoatSpeedLoop()
    if Conns.boatSpeedLoop then return end
    Conns.boatSpeedLoop = task.spawn(function()
        while T("BoatSpeed") do
            pcall(applyBoatSpeed)
            task.wait(1.0)
        end
        Conns.boatSpeedLoop = nil
    end)
end

local function stopBoatSpeedLoop()
    Conns.boatSpeedLoop = nil
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
            local shouldNoclip = (State.boatTargetMode == "All") or checkIsMyBoat(boat)
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

local function getPlayerHumanoid()
    local char = LocalPlayer.Character
    return char, char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart")
end

local function rememberPlayerDefaults(char, hum)
    if State.playerEditCharacter ~= char then
        State.playerEditCharacter = char
        State.playerOriginalJumpPower = hum.JumpPower
        State.playerOriginalUseJumpPower = hum.UseJumpPower
    else
        if State.playerOriginalJumpPower == nil then State.playerOriginalJumpPower = hum.JumpPower end
        if State.playerOriginalUseJumpPower == nil then State.playerOriginalUseJumpPower = hum.UseJumpPower end
    end
end

local function restorePlayerEdits()
    local char, hum = getPlayerHumanoid()
    if hum and State.playerEditCharacter == char then
        pcall(function()
            if State.playerOriginalJumpPower ~= nil and not State.playerJumpPowerEnabled then
                hum.JumpPower = State.playerOriginalJumpPower
            end
            if State.playerOriginalUseJumpPower ~= nil and not State.playerJumpPowerEnabled then
                hum.UseJumpPower = State.playerOriginalUseJumpPower
            end
        end)
    end
end

local function startPlayerEditLoop()
    if Conns.playerEdit then return end
    Conns.playerEdit = RunService.Heartbeat:Connect(function()
        if not State.playerTpwalkEnabled and not State.playerJumpPowerEnabled then
            restorePlayerEdits()
            if Conns.playerEdit then Conns.playerEdit:Disconnect(); Conns.playerEdit = nil end
            return
        end

        local char, hum, hrp = getPlayerHumanoid()
        if not char or not hum or not hrp or not hum.Parent or hum.Health <= 0 then return end
        rememberPlayerDefaults(char, hum)

        pcall(function()
            if State.playerTpwalkEnabled and hum.MoveDirection.Magnitude > 0.01 then
                local distance = math.max(0, tonumber(State.playerTpwalkDistance) or 2)
                hrp.CFrame = hrp.CFrame + hum.MoveDirection.Unit * distance
            end

            if State.playerJumpPowerEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = math.max(0, tonumber(State.playerJumpPowerValue) or 100)
            else
                if State.playerOriginalJumpPower ~= nil then hum.JumpPower = State.playerOriginalJumpPower end
                if State.playerOriginalUseJumpPower ~= nil then hum.UseJumpPower = State.playerOriginalUseJumpPower end
            end
        end)
    end)
end

local function stopPlayerEditLoop()
    if Conns.playerEdit then Conns.playerEdit:Disconnect(); Conns.playerEdit = nil end
    restorePlayerEdits()
    if State.playerTpwalkEnabled or State.playerJumpPowerEnabled then
        startPlayerEditLoop()
    else
        State.playerEditCharacter = nil
        State.playerOriginalJumpPower = nil
        State.playerOriginalUseJumpPower = nil
    end
end

local function startPlayerFly()
    if Conns.playerFly then Conns.playerFly:Disconnect(); Conns.playerFly = nil end
    State.playerFlyVelocity = Vector3.zero
    Conns.playerFly = RunService.RenderStepped:Connect(function(dt)
        if not State.playerFlyEnabled then
            if Conns.playerFly then Conns.playerFly:Disconnect(); Conns.playerFly = nil end
            return
        end

        local char, hum, hrp = getPlayerHumanoid()
        local camera = workspace.CurrentCamera
        if not char or not hum or not hrp or not camera or hum.Health <= 0 then return end

        -- Use the camera direction for W/S so looking up or down naturally
        -- controls altitude.  Keep A/D level for easier steering.
        local look = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        local rightFlat = Vector3.new(right.X, 0, right.Z)
        if rightFlat.Magnitude > 0 then rightFlat = rightFlat.Unit end

        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - look end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + rightFlat end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - rightFlat end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)
            or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            direction = direction - Vector3.new(0, 1, 0)
        end

        if direction.Magnitude > 0 then direction = direction.Unit end
        local speed = math.max(1, tonumber(State.playerFlySpeed) or 100)
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 1.5 end

        -- Smooth acceleration and braking make small corrections much easier.
        local desiredVelocity = direction * speed
        local blend = direction.Magnitude > 0
            and math.clamp(dt * 14, 0, 1)
            or math.clamp(dt * 18, 0, 1)
        State.playerFlyVelocity = (State.playerFlyVelocity or Vector3.zero):Lerp(desiredVelocity, blend)
        local moveDelta = State.playerFlyVelocity * math.min(dt, 0.1)

        pcall(function()
            hum.PlatformStand = true
            hum.AutoRotate = false
            hrp.CFrame = hrp.CFrame + moveDelta
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if hum:GetState() ~= Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end)
    end)
end

local function stopPlayerFly()
    State.playerFlyEnabled = false
    State.playerFlyVelocity = Vector3.zero
    if Conns.playerFly then Conns.playerFly:Disconnect(); Conns.playerFly = nil end
    local _, hum = getPlayerHumanoid()
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

local function startInfiniteJump()
    if Conns.infiniteJump then return end
    Conns.infiniteJump = UserInputService.JumpRequest:Connect(function()
        if not State.infiniteJumpEnabled then return end
        local _, hum = getPlayerHumanoid()
        if hum and hum.Health > 0 then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
    end)
end

local function stopInfiniteJump()
    State.infiniteJumpEnabled = false
    if Conns.infiniteJump then Conns.infiniteJump:Disconnect(); Conns.infiniteJump = nil end
end

local function round(n) return math.floor(tonumber(n) + 0.5) end

local function getMyHeadPos()
    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    return head and head.Position or nil
end

local function EspPly()
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
                    name.TextColor3 = v.Team == LocalPlayer.Team and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
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

local function DevEsp()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    for _, v in next, workspace:GetChildren() do
        pcall(function()
            if not string.find(v.Name, "Fruit") then return end
            local handle = v:FindFirstChild("Handle")
            if not handle or not handle.Parent then
                local esp = v:FindFirstChild("NameEsp"..ESP.Number)
                if esp then esp:Destroy() end
                return
            end
            if ESP.DevilFruit then
                local distText = round((myHeadPos - handle.Position).Magnitude/3) .." M"
                local esp = handle:FindFirstChild("NameEsp"..ESP.Number)
                if not esp then
                    local bill = Instance.new("BillboardGui", handle)
                    bill.Name = "NameEsp"..ESP.Number
                    bill.ExtentsOffset = Vector3.new(0, 1, 0)
                    bill.Size = UDim2.new(1, 200, 1, 30)
                    bill.Adornee = handle
                    bill.AlwaysOnTop = true
                    local name = Instance.new("TextLabel", bill)
                    name.Font = Enum.Font.Code
                    name.FontSize = "Size14"
                    name.TextWrapped = true
                    name.Size = UDim2.new(1, 0, 1, 0)
                    name.TextYAlignment = "Top"
                    name.BackgroundTransparency = 1
                    name.TextStrokeTransparency = 0.5
                    name.TextColor3 = Color3.fromRGB(255, 255, 255)
                    name.Text = "[" .. v.Name .. "]\n" .. distText
                    handle.AncestryChanged:Connect(function()
                        if bill and bill.Parent then pcall(function() bill:Destroy() end) end
                    end)
                else
                    local label = esp:FindFirstChildOfClass("TextLabel")
                    if label then label.Text = "[" .. v.Name .. "]\n" .. distText end
                end
            else
                local esp = handle:FindFirstChild("NameEsp"..ESP.Number)
                if esp then esp:Destroy() end
            end
        end)
    end
end

local function LocationEsp()
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

local function flowerEsp()
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
                        name.Text = (v.Name == "Flower1" and "Blue Flower\n" or "Red Flower\n") .. distText
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

local function ChestEsp()
    local myHeadPos = getMyHeadPos()
    if not myHeadPos then return end
    if ESP.Chest then
        local CollectionService = game:GetService("CollectionService")
        for _, Chest in ipairs(CollectionService:GetTagged("_ChestTagged")) do
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
                    nameEsp.TextLabel.Text = string.format("[%s] %d M", Chest.Name:gsub("Label", ""), math.floor(distanceMagnitude / 3))
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

local function EventIslandEsp()
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

local function LegenSword()
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

local function berriesEsp()
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

local function updateESPActive()
    ESP.AnyActive = ESP.Player or ESP.DevilFruit or ESP.Island or ESP.Flower
        or ESP.Chest or ESP.EventIsland or ESP.LegenSword or ESP.Berry
end

local function startEspLoop()
    if Conns.espLoop then return end
    Conns.espLoop = task.spawn(function()
        while ESP.AnyActive do
            local now = tick()
            pcall(function()
                if ESP.Player and (now - (ESP_lastUpdate.Player or 0)) >= ESP_INTERVAL.Player then
                    ESP_lastUpdate.Player = now; EspPly()
                end
                if ESP.DevilFruit and (now - (ESP_lastUpdate.DevilFruit or 0)) >= ESP_INTERVAL.DevilFruit then
                    ESP_lastUpdate.DevilFruit = now; DevEsp()
                end
                if ESP.Island and (now - (ESP_lastUpdate.Island or 0)) >= ESP_INTERVAL.Island then
                    ESP_lastUpdate.Island = now; LocationEsp()
                end
                if ESP.Flower and (now - (ESP_lastUpdate.Flower or 0)) >= ESP_INTERVAL.Flower then
                    ESP_lastUpdate.Flower = now; flowerEsp()
                end
                if ESP.Chest and (now - (ESP_lastUpdate.Chest or 0)) >= ESP_INTERVAL.Chest then
                    ESP_lastUpdate.Chest = now; ChestEsp()
                end
                if ESP.EventIsland and (now - (ESP_lastUpdate.EventIsland or 0)) >= ESP_INTERVAL.EventIsland then
                    ESP_lastUpdate.EventIsland = now; EventIslandEsp()
                end
                if ESP.LegenSword and (now - (ESP_lastUpdate.LegenSword or 0)) >= ESP_INTERVAL.LegenSword then
                    ESP_lastUpdate.LegenSword = now; LegenSword()
                end
                if ESP.Berry and (now - (ESP_lastUpdate.Berry or 0)) >= ESP_INTERVAL.Berry then
                    ESP_lastUpdate.Berry = now; berriesEsp()
                end
            end)
            task.wait(0.1)
        end
        Conns.espLoop = nil
    end)
end

local function statsSetings(Num, value)
    local data = LocalPlayer:FindFirstChild("Data")
    if not data then return end
    local points = data:FindFirstChild("Points")
    if not points or not points:IsA("ValueBase") or points.Value <= 0 then return end
    local statMap = { Melee = "Melee", Defense = "Defense", Sword = "Sword", Gun = "Gun", Devil = "Demon Fruit" }
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

        local tick_tz   = 0
        local tick_gt   = 0
        local tick_loc  = 0
        local tick_moon = 0
        local tick_rip  = 0
        local tick_dough = 0
        local tick_lgd  = 0
        local tick_bone = 0
        local tick_cake = 0

        while true do
            task.wait(1)
            local now = tick()
            pcall(function()
                if tzLabel and tzLabel.SetText then
                    local date = os.date("*t")
                    local hour = date.hour % 24
                    local ampm = hour < 12 and "AM" or "PM"
                    local h12 = ((hour - 1) % 12) + 1
                    tzLabel:SetText("TZ: " .. string.format("%02d/%02d/%04d", date.day, date.month, date.year) .. " " .. string.format("%02i:%02i:%02i %s", h12, date.min, date.sec, ampm) .. " [" .. countryCode .. "]")
                end
                if gtLabel and gtLabel.SetText then
                    local t = math.floor(workspace.DistributedGameTime + 0.5)
                    gtLabel:SetText(string.format("Game Time: %dh %dm %ds", math.floor(t/3600)%24, math.floor(t/60)%60, t%60))
                end
                if now - tick_loc >= 2 then
                    tick_loc = now
                    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
                    if mirLabel and mirLabel.SetText then
                        mirLabel:SetText("Mirage Island: " .. (locations and locations:FindFirstChild("Mirage Island") and "✓ Spawned" or "✗ Not Found"))
                    end
                    if kitLabel and kitLabel.SetText then
                        kitLabel:SetText("Kitsune Island: " .. (locations and locations:FindFirstChild("Kitsune Island") and "✓ Spawned" or "✗ Not Found"))
                    end
                    if preLabel and preLabel.SetText then
                        preLabel:SetText("Prehistoric: " .. (locations and locations:FindFirstChild("Prehistoric Island") and "✓ Spawned" or "✗ Not Found"))
                    end
                    if froLabel and froLabel.SetText then
                        froLabel:SetText("Frozen Dim: " .. (locations and locations:FindFirstChild("Frozen Dimension") and "✓ Spawned" or "✗ Not Found"))
                    end
                end
                if now - tick_moon >= 3 then
                    tick_moon = now
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
                end
                if now - tick_rip >= 2 then
                    tick_rip = now
                    if ripLabel and ripLabel.SetText then
                        local exists = ReplicatedStorage:FindFirstChild("rip_indra True Form") ~= nil
                            or (workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("rip_indra") ~= nil)
                        ripLabel:SetText("Rip Indra: " .. (exists and "✓ Spawned" or "✗ Not Spawned"))
                    end
                    if doughLabel and doughLabel.SetText then
                        local exists = ReplicatedStorage:FindFirstChild("Dough King") ~= nil
                            or (workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Dough King") ~= nil)
                        doughLabel:SetText("Dough King: " .. (exists and "✓ Spawned" or "✗ Not Spawned"))
                    end
                end
                if now - tick_lgd >= 10 then
                    tick_lgd = now
                    if lgdLabel and lgdLabel.SetText then
                        local s1 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")
                        local s2 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2")
                        local s3 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "3")
                        local result = (s1 and "Shisui " or "") .. (s2 and "Wando " or "") .. (s3 and "Saddi" or "")
                        lgdLabel:SetText("Lgd Sword: " .. (result ~= "" and result or "Not Found"))
                    end
                end
                if now - tick_bone >= 10 then
                    tick_bone = now
                    if boneLabel and boneLabel.SetText then
                        local bones = ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check")
                        boneLabel:SetText("Bones: " .. tostring(bones or 0))
                    end
                end
                if now - tick_cake >= 10 then
                    tick_cake = now
                    if cakeLabel and cakeLabel.SetText then
                        local res = ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                        local killed = type(res) == "string" and tonumber(string.match(res, "%d+")) or nil
                        if killed then
                            cakeLabel:SetText("Cake Prince Killed: " .. tostring(500 - killed))
                        else
                            cakeLabel:SetText("Cake Prince: N/A")
                        end
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

    FarmRight:AddToggle("BringMobEnabled", {
    Text    = "Bring Mob",
    Default = true,
})
Toggles.BringMobEnabled:OnChanged(function()
    Library:Notify({
        Title       = "Bring Mob",
        Description = T("BringMobEnabled") and "ON" or "OFF",
        Time        = 2,
    })
end)

FarmRight:AddSlider("BringMobCount", {
    Text    = "Bring Mob Count",
    Min     = 1,
    Max     = 5,
    Default = 1,
    Rounding = 0,
})
Options.BringMobCount:OnChanged(function()
    BRING_COUNT = tonumber(O("BringMobCount")) or 1
end)

    FarmLeft:AddSlider("TweenSpeed", { Text = "Tween Speed", Min = 0, Max = 500, Default = 250, Rounding = 0 })
    Options.TweenSpeed:OnChanged(function() CFG.SPEED = tonumber(O("TweenSpeed")) or 250 end)

    FarmLeft:AddSlider("OffsetX", { Text = "Offset X", Min = -50, Max = 50, Default = 0, Rounding = 0 })
    Options.OffsetX:OnChanged(function() CFG.OFFSET_X = tonumber(O("OffsetX")) or 0 end)

    FarmLeft:AddSlider("OffsetY", { Text = "Offset Y", Min = 0, Max = 100, Default = 35, Rounding = 0 })
    Options.OffsetY:OnChanged(function() CFG.OFFSET_Y = tonumber(O("OffsetY")) or 35 end)

    FarmLeft:AddSlider("OffsetZ", { Text = "Offset Z", Min = -50, Max = 50, Default = 0, Rounding = 0 })
    Options.OffsetZ:OnChanged(function() CFG.OFFSET_Z = tonumber(O("OffsetZ")) or 0 end)

    FarmLeft:AddSlider("HitRange", { Text = "Hit Range", Min = 10, Max = 200, Default = 100, Rounding = 0 })
    Options.HitRange:OnChanged(function() CFG.MAX_DISTANCE = tonumber(O("HitRange")) or 100 end)

    FarmRight:AddButton({
        Text = "Reset Value Default",
        Func = function()
            CFG.SPEED = 250; CFG.OFFSET_X = 0; CFG.OFFSET_Y = 25; CFG.OFFSET_Z = 0; CFG.MAX_DISTANCE = 100
            Options.TweenSpeed:SetValue(250); Options.OffsetX:SetValue(0)
            Options.OffsetY:SetValue(25); Options.OffsetZ:SetValue(0); Options.HitRange:SetValue(100)
            smoothCleanAll()
            Library:Notify({ Title = "Reset", Description = "Reset to Default", Time = 3 })
        end,
    })
end
do
    local LevelLeft  = Tabs.Main:AddLeftGroupbox("Auto Level")
    local LevelRight = Tabs.Main:AddRightGroupbox("Level Status")
 
local LevelFarmState = {
    enabled        = false,
    phase          = "idle",   -- "idle" | "going_quest" | "accepting" | "farming" | "farming_boss"
    thread         = nil,
    lastQuestTier  = nil,
    isBossMode     = false,
    questMonster   = "",
    normalQuestIndex = 1,

    -- Quest List (Sea 1)
    questList = {
        --  Starter Island 
        { lvMin = 1,   lvMax = 10,  remote = "BanditQuest1",
          giverPos = Vector3.new(1060, 16, 1548),
          variants = {
            { variant = 1, monster = "Bandit",           isBoss = false },
          }
        },

        --  Jungle 
        { lvMin = 11,  lvMax = 15,  remote = "JungleQuest",
          giverPos = Vector3.new(-1602, 37, 151),
          variants = {
            { variant = 1, monster = "Monkey",           isBoss = false },
          }
        },
        { lvMin = 16,  lvMax = 20,  remote = "JungleQuest",
          giverPos = Vector3.new(-1602, 37, 151),
          variants = {
            { variant = 1, monster = "Monkey",           isBoss = false },
            { variant = 2, monster = "Gorilla",          isBoss = false },
          }
        },
        { lvMin = 21,  lvMax = 30,  remote = "JungleQuest",
          giverPos = Vector3.new(-1602, 37, 151),
          variants = {
            { variant = 1, monster = "Monkey",           isBoss = false },
            { variant = 2, monster = "Gorilla",          isBoss = false },
            { variant = 3, monster = "The Gorilla King", isBoss = true  },
          }
        },

        --  Pirate Island 
        { lvMin = 31,  lvMax = 40,  remote = "BuggyQuest1",
          giverPos = Vector3.new(-1141, 5, 3829),
          variants = {
            { variant = 1, monster = "Pirate",           isBoss = false },
          }
        },
        { lvMin = 41,  lvMax = 55,  remote = "BuggyQuest1",
          giverPos = Vector3.new(-1141, 5, 3829),
          variants = {
            { variant = 1, monster = "Pirate",           isBoss = false },
            { variant = 2, monster = "Brute",            isBoss = false },
          }
        },
        { lvMin = 56,  lvMax = 60,  remote = "BuggyQuest1",
          giverPos = Vector3.new(-1141, 5, 3829),
          variants = {
            { variant = 1, monster = "Pirate",           isBoss = false },
            { variant = 2, monster = "Brute",            isBoss = false },
            { variant = 3, monster = "Chef",             isBoss = true  },
          }
        },

        -- Desert
        { lvMin = 61,  lvMax = 75,  remote = "DesertQuest",
          giverPos = Vector3.new(897, 7, 4390),
          variants = {
            { variant = 1, monster = "Desert Bandit",    isBoss = false },
          }
        },
        { lvMin = 76,  lvMax = 90,  remote = "DesertQuest",
          giverPos = Vector3.new(897, 7, 4390),
          variants = {
            { variant = 1, monster = "Desert Bandit",    isBoss = false },
            { variant = 2, monster = "Desert Officer",   isBoss = false },
          }
        },

        -- Snow
        { lvMin = 91,  lvMax = 100, remote = "SnowQuest",
          giverPos = Vector3.new(1385, 87, -1296),
          variants = {
            { variant = 1, monster = "Snow Bandit",      isBoss = false },
          }
        },
        { lvMin = 101, lvMax = 105, remote = "SnowQuest",
          giverPos = Vector3.new(1385, 87, -1296),
          variants = {
            { variant = 1, monster = "Snow Bandit",      isBoss = false },
            { variant = 2, monster = "Snowman",          isBoss = false },
          }
        },
        { lvMin = 106, lvMax = 120, remote = "SnowQuest",
          giverPos = Vector3.new(1385, 87, -1296),
          variants = {
            { variant = 1, monster = "Snow Bandit",      isBoss = false },
            { variant = 2, monster = "Snowman",          isBoss = false },
            { variant = 3, monster = "Yeti",             isBoss = true  },
          }
        },

        -- Marine Base 
        { lvMin = 121, lvMax = 130, remote = "MarineQuest2",
          giverPos = Vector3.new(-5037, 29, 4322),
          variants = {
            { variant = 1, monster = "Chief Petty Officer", isBoss = false },
          }
        },
        { lvMin = 131, lvMax = 150, remote = "MarineQuest2",
          giverPos = Vector3.new(-5037, 29, 4322),
          variants = {
            { variant = 1, monster = "Chief Petty Officer", isBoss = false },
            { variant = 2, monster = "Vice Admiral",        isBoss = true  },
          }
        },

        -- Sky
        { lvMin = 151, lvMax = 175, remote = "SkyQuest",
          giverPos = Vector3.new(-4843, 718, -2617),
          variants = {
            { variant = 1, monster = "Sky Bandit",       isBoss = false },
          }
        },
        { lvMin = 175, lvMax = 190, remote = "SkyQuest",
          giverPos = Vector3.new(-4843, 718, -2617),
          variants = {
            { variant = 1, monster = "Sky Bandit",       isBoss = false },
            { variant = 2, monster = "Dark Master",      isBoss = false },
          }
        },

        -- prison
        { lvMin = 191, lvMax = 210, remote = "PrisonerQuest",
          giverPos = Vector3.new(5306, 2, 474),
          variants = {
            { variant = 1, monster = "Prisoner",              isBoss = false },
          }
        },
        { lvMin = 210, lvMax = 220, remote = "PrisonerQuest",
          giverPos = Vector3.new(5306, 2, 474),
          variants = {
            { variant = 1, monster = "Prisoner",              isBoss = false },
            { variant = 2, monster = "Dangerous Prisoner",    isBoss = false },
          }
        },

        -- Boss prison
        { lvMin = 221, lvMax = 230, remote = "ImpelQuest",
          giverPos = Vector3.new(5189, 4, 687),
          variants = {
            { variant = 1, monster = "Warden",           isBoss = true  },
          }
        },
        { lvMin = 231, lvMax = 240, remote = "ImpelQuest",
          giverPos = Vector3.new(5189, 4, 687),
          variants = {
            { variant = 1, monster = "Warden",           isBoss = true  },
            { variant = 2, monster = "Chief Warden",     isBoss = true  },
          }
        },
        { lvMin = 241, lvMax = 250, remote = "ImpelQuest",
          giverPos = Vector3.new(5189, 4, 687),
          variants = {
            { variant = 1, monster = "Warden",           isBoss = true  },
            { variant = 2, monster = "Chief Warden",     isBoss = true  },
            { variant = 3, monster = "Swan",             isBoss = true  },
          }
        },

        -- Colosseum
        { lvMin = 251, lvMax = 275, remote = "ColosseumQuest",
          giverPos = Vector3.new(-1577, 7, -2987),
          variants = {
            { variant = 1, monster = "Toga Warrior",     isBoss = false },
          }
        },
        { lvMin = 276, lvMax = 300, remote = "ColosseumQuest",
          giverPos = Vector3.new(-1577, 7, -2987),
          variants = {
            { variant = 1, monster = "Toga Warrior",     isBoss = false },
            { variant = 2, monster = "Gladiator",        isBoss = false },
          }
        },

        -- Magma
        { lvMin = 301, lvMax = 325, remote = "MagmaQuest",
          giverPos = Vector3.new(-5315, 12, 8517),
          variants = {
            { variant = 1, monster = "Military Soldier",  isBoss = false },
          }
        },

        { lvMin = 326, lvMax = 350, remote = "MagmaQuest",
          giverPos = Vector3.new(-5315, 12, 8517),
          variants = {
            { variant = 1, monster = "Military Soldier",  isBoss = false },
            { variant = 2, monster = "Military Spy",      isBoss = false },
          }
        },

        { lvMin = 351, lvMax = 375, remote = "MagmaQuest",
          giverPos = Vector3.new(-5315, 12, 8517),
          variants = {
            { variant = 1, monster = "Military Soldier",  isBoss = false },
            { variant = 2, monster = "Military Spy",      isBoss = false },
            { variant = 3, monster = "Magma Admiral",     isBoss = true  },
          }
        },

        -- underwater
        { lvMin = 376, lvMax = 400, remote = "FishmanQuest",
          giverPos = Vector3.new(61124, 19, 1567),
          variants = {
            { variant = 1, monster = "Fishman Warrior",  isBoss = false },
          }
        },

        { lvMin = 401, lvMax = 425, remote = "FishmanQuest",
          giverPos = Vector3.new(61124, 19, 1567),
          variants = {
            { variant = 1, monster = "Fishman Warrior",  isBoss = false },
            { variant = 2, monster = "Fishman Commando",      isBoss = false },
          }
        },

        { lvMin = 425, lvMax = 450, remote = "FishmanQuest",
          giverPos = Vector3.new(61124, 19, 1567),
          variants = {
            { variant = 1, monster = "Fishman Warrior",  isBoss = false },
            { variant = 2, monster = "Fishman Commando",      isBoss = false },
            { variant = 3, monster = "Fishman Lord",     isBoss = true  },
          }
        },

        -- sky 1.5 and sky 2
        { lvMin = 451, lvMax = 475, remote = "SkyExp1Quest",
          giverPos = Vector3.new(-4722, 845, -1952),
          variants = {
            { variant = 1, monster = "God's Guard",  isBoss = false },
          }
        },

        { lvMin = 476, lvMax = 500, remote = "SkyExp1Quest",
          giverPos = Vector3.new(-4722, 845, -1952),
          variants = {
            { variant = 1, monster = "God's Guard",  isBoss = false },
            { variant = 2, monster = "Shanda",  isBoss = false },
          }
        },

        { lvMin = 501, lvMax = 525, remote = "SkyExp1Quest",
          giverPos = Vector3.new(-4722, 845, -1952),
          variants = {
            { variant = 1, monster = "God's Guard",  isBoss = false },
            { variant = 2, monster = "Shanda",  isBoss = false },
            { variant = 3, monster = "Wysper",  isBoss = true },
          }
        },

        -- sky 3
        { lvMin = 526, lvMax = 550, remote = "SkyExp2Quest",
          giverPos = Vector3.new(-7903, 5636, -1410),
          variants = {
            { variant = 1, monster = "Royal Squad",  isBoss = false },
          }
        },

        { lvMin = 551, lvMax = 575, remote = "SkyExp2Quest",
          giverPos = Vector3.new(-7903, 5636, -1410),
          variants = {
            { variant = 1, monster = "Royal Squad",  isBoss = false },
            { variant = 2, monster = "Royal Soldier",  isBoss = false },
          }
        },

        { lvMin = 576, lvMax = 600, remote = "SkyExp2Quest",
          giverPos = Vector3.new(-7903, 5636, -1410),
          variants = {  
            { variant = 1, monster = "Royal Squad",  isBoss = false },
            { variant = 2, monster = "Royal Soldier",  isBoss = false },
            { variant = 3, monster = "Thunder God",  isBoss = true },
          }
        },
    },
}

    local function cleanupLock()
        pcall(function()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            local m = c and c:FindFirstChildOfClass("Humanoid")
            if h then
                for _, name in ipairs({"__LvlLockBP","__LvlLockBG"}) do
                    local obj = h:FindFirstChild(name)
                    if obj then obj:Destroy() end
                end
                h.AssemblyLinearVelocity  = Vector3.zero
                h.AssemblyAngularVelocity = Vector3.zero
            end
            if m then
                m.PlatformStand = false
                m:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
 
    local function stopCurrentFarm()
        State.autoFarmEnabled = false
        State.autoBossEnabled = false
        if Conns.farm then Conns.farm:Disconnect(); Conns.farm = nil end
        if Conns.boss then Conns.boss:Disconnect(); Conns.boss = nil end
        stopPositionLock()
        smoothCleanAll()
        State.currentEnemy = nil
        State.trackedRoot  = nil
        State.currentFlyCF = nil
    end
 
    local function getPlayerLevel()
        local d = LocalPlayer:FindFirstChild("Data")
        return d and d:FindFirstChild("Level") and d.Level.Value or 0
    end
 
    local function hasActiveQuest()
        local ok, r = pcall(function()
            local q = LocalPlayer.PlayerGui.Main.Quest
            if not q.Visible then return false end
            local t = q.Container.QuestTitle.Title
            return (t.ContentText ~= "" and t.ContentText or t.Text or "") ~= ""
        end)
        return ok and r == true
    end

    local function getQuestMonsterName()
    local ok, result = pcall(function()
        local q = LocalPlayer.PlayerGui.Main.Quest
        if not q.Visible then return nil end
        local t = q.Container.QuestTitle.Title
        local txt = t.ContentText ~= "" and t.ContentText or t.Text or ""
        local name = txt:match("^%s*Defeat%s+(.-)%s*%(%d+/%d+%)")
        if name and name ~= "" then return name end
        return nil
    end)
    return (ok and result) or nil
end
 
    local function isQuestComplete()
        local ok, r = pcall(function()
            local q = LocalPlayer.PlayerGui.Main.Quest
            if not q.Visible then return false end
            local t = q.Container.QuestTitle.Title
            local txt = t.ContentText ~= "" and t.ContentText or t.Text or ""
            local cur, max = txt:match("%((%d+)/(%d+)%)")
            return cur and max and tonumber(cur) >= tonumber(max)
        end)
        return ok and r == true
    end
 
    local function abandonQuest()
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest") end)
        task.wait(0.5)
    end

    local levelFarmVThread = nil
    local levelFarmVToken = 0

    local function getBlackLegInCharacter()
        local character = LocalPlayer.Character
        local charactersFolder = Workspace:FindFirstChild("Characters")
        local workspaceCharacter = charactersFolder and charactersFolder:FindFirstChild(LocalPlayer.Name)

        if workspaceCharacter then
            local blackLeg = workspaceCharacter:FindFirstChild("Black Leg")
            if blackLeg then return blackLeg end
        end
        return character and character:FindFirstChild("Black Leg")
    end

    local function startLevelFarmBlackLegV()
        if levelFarmVThread then return end

        levelFarmVToken = levelFarmVToken + 1
        local myToken = levelFarmVToken
        levelFarmVThread = task.spawn(function()
            while levelFarmVToken == myToken and LevelFarmState.enabled do
                local blackLeg = getBlackLegInCharacter()
                if blackLeg then
                    pcall(function()
                        local vim = game:GetService("VirtualInputManager")
                        vim:SendKeyEvent(true, "V", false, game)
                        vim:SendKeyEvent(false, "V", false, game)
                    end)
                    task.wait(0.08)
                else
                    task.wait(0.2)
                end
            end
            if levelFarmVToken == myToken then
                levelFarmVThread = nil
            end
        end)
    end

    local function stopLevelFarmBlackLegV()
        levelFarmVToken = levelFarmVToken + 1
        levelFarmVThread = nil
    end
 
    local function hasBossInWorldSmart(name)
        local folder = workspace:FindFirstChild("Enemies")
        if not folder then return false end
        local norm = name and name:lower():gsub("%s+","") or nil
        for _, m in ipairs(folder:GetChildren()) do
            if isEnemyDead(m) then continue end
            local hum = m:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health and hum.Health > 0 then
                local raw   = (hum.DisplayName ~= "" and hum.DisplayName) or m.Name
                local clean = cleanMonsterName(raw)
                if norm and clean:lower():gsub("%s+","") == norm then return true end
                if not norm and (raw:find("%[Boss%]") or raw:find("%[Raid Boss%]"))
                    and not isBossIgnored(clean) then return true end
            end
        end
        return false
    end
 
    local function travelToPos(targetPos, timeoutSec)
        timeoutSec = timeoutSec or 60
        if not targetPos then return false end

        -- Use the proper entrance before travelling to quest givers inside
        -- restricted areas such as Underwater City.
        local entranceInfo = getEntranceForTarget(targetPos)
        local currentChar = LocalPlayer.Character
        local currentHrp  = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        local currentDist = currentHrp and (currentHrp.Position - targetPos).Magnitude or math.huge
        if entranceInfo and currentDist > FARM_NEAR_DISTANCE then
            if currentHrp and (currentHrp.Position - entranceInfo.entrance).Magnitude > 500 then
                Library:Notify({
                    Title = "Level Farm",
                    Description = "Using entrance: " .. entranceInfo.name,
                    Time = 2,
                })
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", entranceInfo.entrance)
                end)
                local newChar = LocalPlayer.Character
                local newHrp  = newChar and newChar:FindFirstChild("HumanoidRootPart")
                if newHrp then State.currentFlyCF = newHrp.CFrame end
            end
        end

        startNoclip()
        startPositionLock()

        local arrived = false
        local deadline = tick() + timeoutSec
        local targetCF = CFrame.new(targetPos)

        local conn
        conn = RunService.Heartbeat:Connect(function(dt)
            if tick() > deadline or not LevelFarmState.enabled then
                if conn then conn:Disconnect() end
                arrived = true
                return
            end
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local dist = (h.Position - targetPos).Magnitude
            if dist <= 8 then
                if conn then conn:Disconnect() end
                arrived = true
                return
            end
            moveToTarget(h, targetCF, dt)
        end)

        local waitDeadline = tick() + timeoutSec + 2
        while not arrived and tick() < waitDeadline do
            task.wait(0.05)
        end
        if conn then conn:Disconnect() end

        if not arrived then
            pcall(function()
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h then
                    h.CFrame = targetCF
                    h.AssemblyLinearVelocity = Vector3.zero
                    h.AssemblyAngularVelocity = Vector3.zero
                    State.currentFlyCF = targetCF
                end
            end)
            arrived = true
        end
        return arrived
    end

    local function acceptQuestSync(remote, variant, giverPos)
        LevelFarmState.phase = "going_quest"

        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then State.currentFlyCF = hrp.CFrame end

        local arrived = travelToPos(giverPos, 90)
        if not arrived or not LevelFarmState.enabled then
            LevelFarmState.phase = "idle"
            return false
        end

        LevelFarmState.phase = "accepting"
        State.currentFlyCF = CFrame.new(giverPos)

        startPositionLock()

        local deadline = tick() + 10
        local accepted = false
        while tick() < deadline and LevelFarmState.enabled do
            pcall(function()
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                local m = c and c:FindFirstChildOfClass("Humanoid")
                if h and m then
                    h.CFrame = CFrame.new(giverPos)
                    h.AssemblyLinearVelocity  = Vector3.zero
                    h.AssemblyAngularVelocity = Vector3.zero
                    m:ChangeState(Enum.HumanoidStateType.Physics)
                end
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", remote, variant)
            end)
            task.wait(0.35)
            if hasActiveQuest() then accepted = true; break end
        end

        if not accepted then
            Library:Notify({ Title = "Level Farm", Description = "Accept failed, will retry", Time = 2 })
            LevelFarmState.phase = "idle"
            stopPositionLock()
            return false
        end

        stopPositionLock()
        State.currentFlyCF = nil

        pcall(function()
            local c = LocalPlayer.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.AutoRotate = true
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)

        return true
    end

 local function startFarmMonster(monsterName)
    stopCurrentFarm()
    task.wait(0.3)

    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local m = c and c:FindFirstChildOfClass("Humanoid")
    if not h or not m or m.Health <= 0 then return end

    State.currentFlyCF = nil
    task.wait(0.05)
    State.currentFlyCF = h.CFrame

    Lists.selectedMonsterList = { monsterName }
    if Options and Options.MonsterSelect then
        Options.MonsterSelect:SetValue({ [monsterName] = true })
    end

    cacheAllSpawns()

     if not Lists.cachedMobSpawns[monsterName] or #Lists.cachedMobSpawns[monsterName] == 0 then
        local spawnsFolder = getMonsterSpawnFolder()
        if spawnsFolder then
            Lists.cachedMobSpawns[monsterName] = {}
            local lowerMonster = monsterName:lower()
            for _, obj in ipairs(spawnsFolder:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local cleanSelf   = cleanMonsterName(obj.Name):lower()
                    local cleanParent = cleanMonsterName(obj.Parent and obj.Parent.Name or ""):lower()
                    if cleanSelf == lowerMonster or cleanParent == lowerMonster then
                        local dup = false
                        for _, ex in ipairs(Lists.cachedMobSpawns[monsterName]) do
                            if (ex.pos - obj.Position).Magnitude < 5 then dup = true; break end
                        end
                        if not dup then
                            table.insert(Lists.cachedMobSpawns[monsterName], { pos = obj.Position, name = monsterName })
                        end
                    end
                end
            end
        end
    end
 
    if not Lists.cachedMobSpawns[monsterName] or #Lists.cachedMobSpawns[monsterName] == 0 then
        local folder = Workspace:FindFirstChild("Enemies")
        if folder then
            Lists.cachedMobSpawns[monsterName] = {}
            local lowerMonster = monsterName:lower()
            for _, model in ipairs(folder:GetChildren()) do
                local hum2 = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")
                if root then
                    local rawName   = (hum2 and hum2.DisplayName ~= "" and hum2.DisplayName) or model.Name
                    local cleanName = cleanMonsterName(rawName):lower()
                    if cleanName == lowerMonster then
                        table.insert(Lists.cachedMobSpawns[monsterName], { pos = root.Position, name = monsterName })
                    end
                end
            end
        end
    end

    if not Lists.cachedMobSpawns[monsterName] or #Lists.cachedMobSpawns[monsterName] == 0 then
        Library:Notify({ Title = "Level Farm", Description = "ไม่พบ spawn เฉพาะ ใช้พื้นที่ปัจจุบัน: " .. monsterName, Time = 2 })
        Lists.cachedMobSpawns[monsterName] = {{ pos = h.Position, name = monsterName }}
    end

    HRP = h; Humanoid = m; Character = c
    State.autoFarmEnabled = true

    if Conns.noclip then Conns.noclip:Disconnect(); Conns.noclip = nil end
    noclipCache = {}; noclipCacheTick = 0; noclipApplyTick = 0
    startNoclip()

    startAutoFarm()
end

    local function startBossMonster(monsterName)
        stopCurrentFarm()
        task.wait(0.15)

        local c = LocalPlayer.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local m = c and c:FindFirstChildOfClass("Humanoid")
        if not h or not m or m.Health <= 0 then return end

        State.currentFlyCF = h.CFrame
        Lists.selectedBossList = { monsterName }
        if Options and Options.BossSelect then
            Options.BossSelect:SetValue({ [monsterName] = true })
        end

        local bossSpawnPos = nil
        local spawnsFolder = getBossSpawnFolder()
        if spawnsFolder then
            for _, part in ipairs(spawnsFolder:GetChildren()) do
                if part:IsA("BasePart") then
                    local cleanName = cleanMonsterName(part.Name)
                    if cleanName == monsterName then
                        bossSpawnPos = part.Position
                        break
                    end
                end
            end
        end

        HRP = h; Humanoid = m; Character = c
        State.autoBossEnabled = true

        if Conns.noclip then Conns.noclip:Disconnect(); Conns.noclip = nil end
        noclipCache = {}; noclipCacheTick = 0; noclipApplyTick = 0
        startNoclip()

        startAutoBoss()

        if bossSpawnPos and not hasBossInWorldSmart(monsterName) then
            task.spawn(function()
                Library:Notify({ Title = "Auto Boss", Description = "Boss not in Enemies → going to spawn: " .. monsterName, Time = 3 })
                local spawnCF = CFrame.new(
                    bossSpawnPos.X + (CFG.OFFSET_X or 0),
                    bossSpawnPos.Y + (CFG.OFFSET_Y or 35),
                    bossSpawnPos.Z + (CFG.OFFSET_Z or 0)
                )
                local waitDeadline = tick() + 60
                while tick() < waitDeadline and LevelFarmState.enabled and State.autoBossEnabled do
                    if hasBossInWorldSmart(monsterName) then
                        Library:Notify({ Title = "Auto Boss", Description = monsterName .. " spawned! Attacking...", Time = 3 })
                        break
                    end
                    local cc = LocalPlayer.Character
                    local hh = cc and cc:FindFirstChild("HumanoidRootPart")
                    local mm = cc and cc:FindFirstChildOfClass("Humanoid")
                    if not hh or not mm or mm.Health <= 0 then break end
                    local dist = (hh.Position - spawnCF.Position).Magnitude
                    if dist > (CFG.REACH or 6) then
                        if not State.currentFlyCF
                            or (State.currentFlyCF.Position - hh.Position).Magnitude > 300 then
                            State.currentFlyCF = hh.CFrame
                        end
                        tryFarmBypass(bossSpawnPos)
                        moveToTarget(hh, spawnCF, 0.05)
                    else
                        State.currentFlyCF = spawnCF
                        pcall(function()
                            hh.CFrame = spawnCF
                            hh.AssemblyLinearVelocity  = Vector3.zero
                            hh.AssemblyAngularVelocity = Vector3.zero
                            mm:ChangeState(Enum.HumanoidStateType.Physics)
                        end)
                    end
                    task.wait(0.05)
                end
            end)
        end
    end

    local function runLevelFarmLoop()
        while LevelFarmState.enabled do
            task.wait(0.1)

            local lv = getPlayerLevel()
            if lv <= 0 then task.wait(0.5); continue end

            local questCfg = nil
            local maxLv    = 0
            for _, cfg in ipairs(LevelFarmState.questList) do
                if cfg.lvMax > maxLv then maxLv = cfg.lvMax end
                if lv >= cfg.lvMin and lv <= cfg.lvMax then questCfg = cfg end
            end

            if lv > maxLv then
                LevelFarmState.enabled = false
                stopLevelFarmBlackLegV()
                stopCurrentFarm()
                Library:Notify({ Title = "Level Farm", Description = "Max level reached", Time = 5 })
                pcall(function() if Toggles.AutoLevelFarm then Toggles.AutoLevelFarm:SetValue(false) end end)
                break
            end
            if not questCfg then task.wait(0.5); continue end

            local tierId = questCfg.remote .. tostring(questCfg.lvMin)
            if LevelFarmState.lastQuestTier ~= tierId then
                LevelFarmState.lastQuestTier = tierId
                LevelFarmState.isBossMode    = false
                LevelFarmState.questMonster  = ""
                LevelFarmState.normalQuestIndex = 1
                -- Keep the quest that is already active when Level Farm starts
                -- or when the level tier changes. It can be farmed normally.
                stopCurrentFarm()
                LevelFarmState.phase = "idle"
                task.wait(0.3); continue
            end

            local normalVariants = {}
            local bossVs  = {}
            for _, v in ipairs(questCfg.variants) do
                if not v.isBoss then
                    table.insert(normalVariants, v)
                end
                if v.isBoss then
                    table.insert(bossVs, v)
                end
            end
            local normalV = nil
            if #normalVariants > 0 then
                if LevelFarmState.normalQuestIndex < 1
                    or LevelFarmState.normalQuestIndex > #normalVariants then
                    LevelFarmState.normalQuestIndex = 1
                end
                normalV = normalVariants[LevelFarmState.normalQuestIndex]
            end

            local fallbackCfg = nil
            if not normalV then
                for _, cfg in ipairs(LevelFarmState.questList) do
                    if cfg.lvMax < questCfg.lvMin then
                        for _, v in ipairs(cfg.variants) do
                            if not v.isBoss then
                                if not fallbackCfg or cfg.lvMax > fallbackCfg.lvMax then
                                    fallbackCfg = cfg
                                end
                                break
                            end
                        end
                    end
                end
            end

            local function liveBossVariants()
                local r = {}
                for _, v in ipairs(bossVs) do
                    if hasBossInWorldSmart(v.monster) then table.insert(r, v) end
                end
                return r
            end

            if LevelFarmState.isBossMode then
                if LevelFarmState.phase == "farming_boss" then
                    local active = hasActiveQuest()
                    local done   = active and isQuestComplete()

                    if not State.autoBossEnabled and active and not done then
                        startBossMonster(LevelFarmState.questMonster)
                        task.wait(0.5); continue
                    end

                    if active and not done then
                        task.wait(0.2); continue
                    end

                    stopCurrentFarm()
                    LevelFarmState.isBossMode = false
                    LevelFarmState.phase      = "idle"

                    local lvNow = getPlayerLevel()
                    local questCfgNow = nil
                    for _, cfg in ipairs(LevelFarmState.questList) do
                        if lvNow >= cfg.lvMin and lvNow <= cfg.lvMax then questCfgNow = cfg end
                    end

                    if questCfgNow then
                        local normalVNow = nil
                        for _, v in ipairs(questCfgNow.variants) do
                            if not v.isBoss then
                                normalVNow = v
                                break
                            end
                        end
                        LevelFarmState.normalQuestIndex = 1
                        if normalVNow then
                            Library:Notify({ Title = "Level Farm", Description = "Boss done! Back to normal farm...", Time = 3 })
                            local ok = acceptQuestSync(questCfgNow.remote, normalVNow.variant, questCfgNow.giverPos)
                            if ok then
                                LevelFarmState.phase        = "farming"
                                LevelFarmState.questMonster = normalVNow.monster
                                startFarmMonster(normalVNow.monster)
                            else
                                LevelFarmState.phase = "idle"
                            end
                        end
                    end

                    task.wait(0.3); continue
                end

                LevelFarmState.isBossMode = false
                LevelFarmState.phase      = "idle"
                task.wait(0.2); continue
            end

            local live = liveBossVariants()
            if #live > 0 then
                Library:Notify({ Title = "Level Farm", Description = "Boss spawned! Switching to boss quest", Time = 3 })
                stopCurrentFarm()
                if hasActiveQuest() then abandonQuest() end

                local fb = live[1]
                local ok = acceptQuestSync(questCfg.remote, fb.variant, questCfg.giverPos)
                if ok then
                    LevelFarmState.isBossMode   = true
                    LevelFarmState.questMonster = fb.monster
                    LevelFarmState.phase        = "farming_boss"
                    startBossMonster(fb.monster)
                    Library:Notify({ Title = "Level Farm", Description = "Farming boss: " .. fb.monster, Time = 3 })
                else
                    LevelFarmState.phase = "idle"
                end
                task.wait(0.3); continue
            end

            if LevelFarmState.phase == "farming" then
                local active = hasActiveQuest()
                local done   = active and isQuestComplete()

                if not State.autoFarmEnabled and active and not done then
                    startFarmMonster(LevelFarmState.questMonster)
                    task.wait(0.5); continue
                end

                if active and not done then
                    task.wait(0.2); continue
                end

                stopCurrentFarm()
                LevelFarmState.phase = "idle"

                local lvNow = getPlayerLevel()
                local questCfgNow = nil
                for _, cfg in ipairs(LevelFarmState.questList) do
                    if lvNow >= cfg.lvMin and lvNow <= cfg.lvMax then questCfgNow = cfg end
                end

                if questCfgNow then
                    local normalVNow = nil
                    local normalVariantsNow = {}
                    for _, v in ipairs(questCfgNow.variants) do
                        if not v.isBoss then
                            table.insert(normalVariantsNow, v)
                        end
                    end

                    if #normalVariantsNow > 0 then
                        local currentIndex = LevelFarmState.normalQuestIndex
                        if currentIndex < 1 or currentIndex > #normalVariantsNow then
                            currentIndex = 1
                        end
                        LevelFarmState.normalQuestIndex = (#normalVariantsNow > 1)
                            and (currentIndex % #normalVariantsNow) + 1
                            or 1
                        normalVNow = normalVariantsNow[LevelFarmState.normalQuestIndex]
                    end

                    if normalVNow then
                        Library:Notify({ Title = "Level Farm", Description = "Quest done! Re-accepting...", Time = 2 })
                        local ok = acceptQuestSync(questCfgNow.remote, normalVNow.variant, questCfgNow.giverPos)
                        if ok then
                            LevelFarmState.phase        = "farming"
                            LevelFarmState.questMonster = normalVNow.monster
                            startFarmMonster(normalVNow.monster)
                            Library:Notify({ Title = "Level Farm", Description = "Farming: " .. normalVNow.monster, Time = 2 })
                        else
                            LevelFarmState.phase = "idle"
                        end
                    elseif fallbackCfg then
                        local fbNormal = nil
                        for _, v in ipairs(fallbackCfg.variants) do
                            if not v.isBoss then fbNormal = v; break end
                        end
                        if fbNormal then
                            local ok = acceptQuestSync(fallbackCfg.remote, fbNormal.variant, fallbackCfg.giverPos)
                            if ok then
                                LevelFarmState.phase        = "farming"
                                LevelFarmState.questMonster = fbNormal.monster
                                startFarmMonster(fbNormal.monster)
                            else
                                LevelFarmState.phase = "idle"
                            end
                        end
                    end
                end

                task.wait(0.3); continue
            end

            if not normalV then
                if fallbackCfg then
                    local fbNormal = nil
                    for _, v in ipairs(fallbackCfg.variants) do
                        if not v.isBoss then fbNormal = v; break end
                    end
                    if fbNormal then
                        if not hasActiveQuest() then
                            Library:Notify({ Title = "Level Farm", Description = "No boss → fallback farm: " .. fbNormal.monster, Time = 3 })
                            local ok = acceptQuestSync(fallbackCfg.remote, fbNormal.variant, fallbackCfg.giverPos)
                            if ok then
                                LevelFarmState.phase        = "farming"
                                LevelFarmState.questMonster = fbNormal.monster
                                startFarmMonster(fbNormal.monster)
                                Library:Notify({ Title = "Level Farm", Description = "Fallback farming: " .. fbNormal.monster, Time = 2 })
                            else
                                LevelFarmState.phase = "idle"
                            end
                        else
                            if LevelFarmState.phase ~= "farming" then
                                LevelFarmState.phase        = "farming"
                                LevelFarmState.questMonster = fbNormal.monster
                                startFarmMonster(fbNormal.monster)
                            end
                        end
                    end
                else
                    Library:Notify({ Title = "Level Farm", Description = "No normal quest & no fallback, waiting for boss...", Time = 5 })
                    task.wait(5)
                end
                task.wait(0.5); continue
            end

            if hasActiveQuest() then
                if LevelFarmState.phase ~= "farming" then
                    local detectedMonster = getQuestMonsterName()
                    local monsterToFarm = detectedMonster or (normalV and normalV.monster) or ""
                    if monsterToFarm ~= "" then
                        LevelFarmState.phase        = "farming"
                        LevelFarmState.questMonster = monsterToFarm
                        local isBossQuest = false
                        for _, v in ipairs(questCfg.variants) do
                            if v.monster == monsterToFarm and v.isBoss then
                                isBossQuest = true; break
                            end
                        end
                        if isBossQuest then
                            LevelFarmState.isBossMode = true
                            LevelFarmState.phase = "farming_boss"
                            startBossMonster(monsterToFarm)
                        else
                            startFarmMonster(monsterToFarm)
                        end
                        Library:Notify({ Title = "Level Farm", Description = "Detected quest: " .. monsterToFarm, Time = 2 })
                    end
                end
                task.wait(0.3)
                continue
            end

            Library:Notify({ Title = "Level Farm", Description = "Accepting quest: " .. normalV.monster, Time = 2 })
            local ok = acceptQuestSync(questCfg.remote, normalV.variant, questCfg.giverPos)
            if ok then
                LevelFarmState.phase        = "farming"
                LevelFarmState.questMonster = normalV.monster
                startFarmMonster(normalV.monster)
                Library:Notify({ Title = "Level Farm", Description = "Farming: " .. normalV.monster, Time = 2 })
            else
                LevelFarmState.phase = "idle"
            end
            task.wait(0.3)
        end

        LevelFarmState.phase = "idle"
        stopCurrentFarm()
    end
 
    --  UI 
    local levelLabel = LevelRight:AddLabel("Level: --")
    local phaseLabel = LevelRight:AddLabel("Phase: idle")
    local questLabel = LevelRight:AddLabel("Quest: --")
    local modeLabel  = LevelRight:AddLabel("Mode: -")
 
    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                local d  = LocalPlayer:FindFirstChild("Data")
                local lv = d and d:FindFirstChild("Level") and d.Level.Value or "?"
                if levelLabel and levelLabel.SetText then levelLabel:SetText("Level: " .. tostring(lv)) end
                if phaseLabel and phaseLabel.SetText then phaseLabel:SetText("Phase: " .. LevelFarmState.phase) end
                pcall(function()
                    local q   = LocalPlayer.PlayerGui.Main.Quest
                    local txt = ""
                    if q.Visible then
                        local t = q.Container.QuestTitle.Title
                        txt = t.ContentText ~= "" and t.ContentText or t.Text or ""
                    end
                    if questLabel and questLabel.SetText then
                        questLabel:SetText("Quest: " .. (q.Visible and txt or "(none)"))
                    end
                end)
                if modeLabel and modeLabel.SetText then
                    local m = LevelFarmState.isBossMode and "Boss" or "Normal"
                    modeLabel:SetText("Mode: " .. m .. " (" .. (LevelFarmState.questMonster or "-") .. ")")
                end
            end)
        end
    end)
 
    --  Toggle 
    LevelLeft:AddToggle("AutoLevelFarm", { Text = "Auto Level Farm", Default = false })
    Toggles.AutoLevelFarm:OnChanged(function()
        LevelFarmState.enabled = T("AutoLevelFarm")
        if LevelFarmState.enabled then
            if State.autoFarmEnabled       and Toggles.AutoFarm       then Toggles.AutoFarm:SetValue(false)       end
            if State.autoNearEnabled       and Toggles.AutoNear       then Toggles.AutoNear:SetValue(false)       end
            if State.autoBossEnabled       and Toggles.AutoBoss       then Toggles.AutoBoss:SetValue(false)       end
            if State.autoBossAllEnabled    and Toggles.AutoBossAll    then Toggles.AutoBossAll:SetValue(false)    end
            if State.autoBossAllHopEnabled and Toggles.AutoBossAllHop then Toggles.AutoBossAllHop:SetValue(false) end
 
            LevelFarmState.phase         = "idle"
            LevelFarmState.lastQuestTier = nil
            LevelFarmState.isBossMode    = false
            LevelFarmState.questMonster  = ""
            LevelFarmState.normalQuestIndex = 1
            cleanupLock()
            startNoclip()
            startLevelFarmBlackLegV()
 
            if LevelFarmState.thread then
                task.cancel(LevelFarmState.thread)
                LevelFarmState.thread = nil
            end
            LevelFarmState.thread = task.spawn(runLevelFarmLoop)
            Library:Notify({ Title = "Level Farm", Description = "Started", Time = 3 })
        else
            LevelFarmState.enabled = false
            LevelFarmState.phase   = "idle"
            if LevelFarmState.thread then
                task.cancel(LevelFarmState.thread)
                LevelFarmState.thread = nil
            end
            stopLevelFarmBlackLegV()
            cleanupLock()
            stopCurrentFarm()
            stopNoclip()
            FastAttackModule.Enabled = false
            stopFastAttack()
            stopHitRegistration()
            Library:Notify({ Title = "Level Farm", Description = "Stopped", Time = 3 })
        end
    end)
 
    LevelLeft:AddToggle("AutoNear", { Text = "Auto Farm Nears", Default = false })
    Toggles.AutoNear:OnChanged(function()
        State.autoNearEnabled = T("AutoNear")
        if State.autoNearEnabled then
            if State.teleportTweenEnabled and Toggles.TweenToIsland then Toggles.TweenToIsland:SetValue(false) end
            if State.autoFarmEnabled and Toggles.AutoFarm then Toggles.AutoFarm:SetValue(false) end
            if State.autoBossEnabled and Toggles.AutoBoss then Toggles.AutoBoss:SetValue(false) end
            State.currentEnemy = nil; State.trackedRoot = nil
            State.currentFlyCF = HRP and HRP.CFrame or nil
            startNoclip(); startAutoNear()
            Library:Notify({ Title = "Auto Nears", Description = "Enabled", Time = 3 })
        else
            if Conns.follow then Conns.follow:Disconnect(); Conns.follow = nil end
            stopPositionLock(); smoothCleanAll(); checkAndResumeFastAttack()
            Library:Notify({ Title = "Auto Nears", Description = "Disabled", Time = 3 })
        end
    end)
end

do
    local RightGroup = Tabs.Main:AddRightGroupbox("Farm Boss / Farm Select")

    RightGroup:AddDropdown("MonsterSelect", {
        Values = initialMonsterList, Default = initialMonsterList[1] and { [initialMonsterList[1]] = true } or {},
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
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            Library:Notify({ Title = "Auto Farm", Description = "Disabled", Time = 3 })
        end
    end)

    RightGroup:AddDropdown("BossSelect", {
        Values = initialBossList, Default = {}, Multi = true, Text = "Select Bosses (Multi)", Searchable = true,
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
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            Library:Notify({ Title = "Auto Boss", Description = "Disabled", Time = 3 })
        end
    end)

    RightGroup:AddToggle("AutoBossAll", { Text = "Auto Farm All Boss", Default = false })
    Toggles.AutoBossAll:OnChanged(function()
        State.autoBossAllEnabled = T("AutoBossAll")
        if State.autoBossAllEnabled then
            if State.autoFarmEnabled    and Toggles.AutoFarm       then Toggles.AutoFarm:SetValue(false)       end
            if State.autoNearEnabled    and Toggles.AutoNear       then Toggles.AutoNear:SetValue(false)       end
            if State.autoBossEnabled    and Toggles.AutoBoss       then Toggles.AutoBoss:SetValue(false)       end
            if State.autoBossAllHopEnabled and Toggles.AutoBossAllHop then Toggles.AutoBossAllHop:SetValue(false) end
            if State.teleportTweenEnabled  and Toggles.TweenToIsland  then Toggles.TweenToIsland:SetValue(false)  end
            State.currentEnemy = nil; State.trackedRoot = nil
            State.currentFlyCF = HRP and HRP.CFrame or nil
            startNoclip(); startAutoBossAll()
            Library:Notify({ Title = "Boss All", Description = "Enabled – farming all bosses", Time = 3 })
        else
            if Conns.bossAll then Conns.bossAll:Disconnect(); Conns.bossAll = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            Library:Notify({ Title = "Boss All", Description = "Disabled", Time = 3 })
        end
    end)

    RightGroup:AddToggle("AutoBossAllHop", { Text = "Auto Farm All Boss Hop", Default = false })
    Toggles.AutoBossAllHop:OnChanged(function()
        State.autoBossAllHopEnabled = T("AutoBossAllHop")
        if State.autoBossAllHopEnabled then
            if State.autoFarmEnabled    and Toggles.AutoFarm    then Toggles.AutoFarm:SetValue(false)    end
            if State.autoNearEnabled    and Toggles.AutoNear    then Toggles.AutoNear:SetValue(false)    end
            if State.autoBossEnabled    and Toggles.AutoBoss    then Toggles.AutoBoss:SetValue(false)    end
            if State.autoBossAllEnabled and Toggles.AutoBossAll then Toggles.AutoBossAll:SetValue(false) end
            if State.teleportTweenEnabled and Toggles.TweenToIsland then Toggles.TweenToIsland:SetValue(false) end
            State.currentEnemy = nil; State.trackedRoot = nil
            State.currentFlyCF = HRP and HRP.CFrame or nil
            startNoclip(); startAutoBossAllHop()
            Library:Notify({ Title = "Auto Boss", Description = "Enabled – will hop if no boss", Time = 3 })
        else
            if Conns.bossAllHop then Conns.bossAllHop:Disconnect(); Conns.bossAllHop = nil end
            stopPositionLock(); stopNoclip(); smoothCleanAll(); checkAndResumeFastAttack()
            Library:Notify({ Title = "Auto Boss", Description = "Disabled", Time = 3 })
        end
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
            if string.find(rawName, "%[Boss%]") or string.find(rawName, "%[Raid Boss%]") then
                local isNew = addDiscoveredBoss(rawName)
                if isNew then
                    local displayList = #Lists.masterBossList > 0 and Lists.masterBossList or {"(No Boss found)"}
                    if Options and Options.BossSelect then Options.BossSelect:SetValues(displayList) end
                end
                return
            end
            local root = child:FindFirstChild("HumanoidRootPart")
            if root then
                local cleanName = cleanMonsterName(child.Name)
                if cleanName ~= "" then
                    if not Lists.cachedMobSpawns[cleanName] then
                        Lists.cachedMobSpawns[cleanName] = {}
                    end
                    local spawnPos = root.Position
                    local spawnsFolder = getMonsterSpawnFolder()
                    if spawnsFolder then
                        local best, bestDist = nil, math.huge
                        for _, part in ipairs(spawnsFolder:GetChildren()) do
                            if part:IsA("BasePart") and cleanMonsterName(part.Name) == cleanName then
                                local d = (part.Position - root.Position).Magnitude
                                if d < bestDist then bestDist = d; best = part.Position end
                            end
                        end
                        if best then spawnPos = best end
                    end
                    local dup = false
                    for _, ex in ipairs(Lists.cachedMobSpawns[cleanName]) do
                        if (ex.pos - spawnPos).Magnitude < 10 then dup = true; break end
                    end
                    if not dup then
                        table.insert(Lists.cachedMobSpawns[cleanName], { pos = spawnPos, name = cleanName })
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
        if State.boatSpeedEnabled then
            startBoatSpeedLoop()
        else
            restoreBoatSpeed()
        end
        Library:Notify({ Title = "Boat Speed", Description = State.boatSpeedEnabled and "ON" or "OFF", Time = 3 })
    end)

    SeaLeft:AddToggle("BoatNoclip", { Text = "Boat NoClip", Default = false })
    Toggles.BoatNoclip:OnChanged(function()
        State.boatNoclipEnabled = T("BoatNoclip")
        if State.boatNoclipEnabled then startBoatNoclip() else stopBoatNoclip() end
        Library:Notify({ Title = "Boat NoClip", Description = State.boatNoclipEnabled and "ON" or "OFF", Time = 3 })
    end)

    SeaLeft:AddDropdown("BoatTargetMode", { Values = { "Owner", "All" }, Default = 1, Multi = false, Text = "Target Boats" })
    Options.BoatTargetMode:OnChanged(function()
        State.boatTargetMode = O("BoatTargetMode") or "Owner"
        if not T("BoatSpeed") then restoreBoatSpeed() end
        if not T("BoatNoclip") then stopBoatNoclip() end
    end)

    SeaLeft:AddSlider("BoatSpeedSlider", { Text = "Boat Speed", Min = 50, Max = 1000, Default = 250, Rounding = 0 })
    Options.BoatSpeedSlider:OnChanged(function() State.boatSpeedValue = tonumber(O("BoatSpeedSlider")) or 250 end)

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
    local EditPlayer = Tabs.LocalPlayer:AddRightGroupbox("modified Player")
    local LPTeam = Tabs.LocalPlayer:AddRightGroupbox("Team Settings")

    EditPlayer:AddToggle("PlayerFly", { Text = "Fly Speed Hack", Default = false })
    Toggles.PlayerFly:OnChanged(function()
        State.playerFlyEnabled = T("PlayerFly")
        if State.playerFlyEnabled then
            startPlayerFly()
        else
            stopPlayerFly()
        end
        Library:Notify({ Title = "Fly", Description = State.playerFlyEnabled and "ON (WASD / Space-E up / Ctrl-Q down / Shift boost)" or "OFF", Time = 3 })
    end)

    EditPlayer:AddSlider("PlayerFlySpeed", {
        Text = "Fly Speed",
        Min = 10,
        Max = 1000,
        Default = 100,
        Rounding = 0,
    })
    Options.PlayerFlySpeed:OnChanged(function()
        State.playerFlySpeed = tonumber(O("PlayerFlySpeed")) or 100
    end)

    EditPlayer:AddToggle("Tpwalk", { Text = "Tpwalk", Default = false })
    Toggles.Tpwalk:OnChanged(function()
        State.playerTpwalkEnabled = T("Tpwalk")
        if State.playerTpwalkEnabled then
            startPlayerEditLoop()
        else
            stopPlayerEditLoop()
        end
        Library:Notify({ Title = "Tpwalk", Description = State.playerTpwalkEnabled and "ON" or "OFF", Time = 3 })
    end)

    EditPlayer:AddSlider("TpwalkDistance", {
        Text = "Tpwalk Distance",
        Min = 0.5,
        Max = 10,
        Default = 2,
        Rounding = 1,
    })
    Options.TpwalkDistance:OnChanged(function()
        State.playerTpwalkDistance = tonumber(O("TpwalkDistance")) or 2
    end)

    EditPlayer:AddSlider("PlayerJumpPower", {
        Text = "JumpPower",
        Min = 50,
        Max = 1000,
        Default = 100,
        Rounding = 0,
    })
    Options.PlayerJumpPower:OnChanged(function()
        State.playerJumpPowerValue = tonumber(O("PlayerJumpPower")) or 100
    end)

    EditPlayer:AddToggle("JumpPowerHack", { Text = "JumpPower Hack", Default = false })
    Toggles.JumpPowerHack:OnChanged(function()
        State.playerJumpPowerEnabled = T("JumpPowerHack")
        if State.playerJumpPowerEnabled then
            startPlayerEditLoop()
        else
            stopPlayerEditLoop()
        end
        Library:Notify({ Title = "JumpPower", Description = State.playerJumpPowerEnabled and "ON" or "OFF", Time = 3 })
    end)

    EditPlayer:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false })
    Toggles.InfiniteJump:OnChanged(function()
        State.infiniteJumpEnabled = T("InfiniteJump")
        if State.infiniteJumpEnabled then startInfiniteJump() else stopInfiniteJump() end
        Library:Notify({ Title = "Infinite Jump", Description = State.infiniteJumpEnabled and "ON" or "OFF", Time = 3 })
    end)

    local function getMyTeam()
        if LocalPlayer.Team then
            return tostring(LocalPlayer.Team.Name)
        end
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local teamVal = data:FindFirstChild("Team")
            if teamVal and teamVal.Value ~= "" then 
                return tostring(teamVal.Value) 
            end
        end
        return ""
    end

     local function setTeam(teamName)
        local currentTeam = getMyTeam()
        if currentTeam ~= "" and string.find(currentTeam:lower(), teamName:lower(), 1, true) then
            Library:Notify({ Title = "Team", Description = "Already on " .. currentTeam .. " team", Time = 3 })
            return
        end
        local ok, err = pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam2", teamName)
        end)
        if ok then
            Library:Notify({ Title = "Team", Description = "Switched to " .. teamName, Time = 3 })
        else
            Library:Notify({ Title = "Team", Description = "Failed: " .. tostring(err), Time = 3 })
        end
    end

    LPTeam:AddDropdown("TeamSelect", {
        Values = { "Pirates", "Marines" },
        Default = 1,
        Multi = false,
        Text = "Select Team",
    })
    LPTeam:AddButton({
        Text = "Change Team",
        Func = function()
            local selected = O("TeamSelect") or "Pirates"
            setTeam(selected)
        end,
    })
    local teamStatusLabel = LPTeam:AddLabel("Current Team: Checking...")
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function()
                if teamStatusLabel and teamStatusLabel.SetText then
                    local t = getMyTeam()
                    teamStatusLabel:SetText("Current Team: " .. (t ~= "" and t or "Unknown"))
                end
            end)
        end
    end)
    task.spawn(function()
        task.wait(2)
        pcall(function()
            local selectedTeam = O("TeamSelect") or "Pirates"
            local currentTeam = getMyTeam()
            if currentTeam ~= "" and string.find(currentTeam:lower(), selectedTeam:lower(), 1, true) then
                Library:Notify({ Title = "Team", Description = "Already on " .. currentTeam, Time = 3 })
                return
            end
            Library:Notify({ Title = "Auto Team", Description = "Setting team to " .. selectedTeam .. "...", Time = 3 })
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam2", selectedTeam)
        end)
    end)

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

    LPLeft:AddDropdown("WeaponSelect", { Values = Lists.WEAPON_TYPES, Default = 1, Multi = false, Text = "Equip Item" })
    Options.WeaponSelect:OnChanged(function()
        State.selectedWeaponType = O("WeaponSelect") or Lists.WEAPON_TYPES[1]
        if State.autoNearEnabled or State.autoFarmEnabled or State.autoBossEnabled then equipWeapon(State.selectedWeaponType) end
    end)
    State.selectedWeaponType = Lists.WEAPON_TYPES[1]

    LPLeft:AddToggle("FastAttack", { Text = "Fast Attack", Default = false })
    Toggles.FastAttack:OnChanged(function()
        checkAndResumeFastAttack()
        Library:Notify({ Title = "Fast Attack", Description = T("FastAttack") and "Enabled" or "Disabled", Time = 3 })
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
            task.wait(0.2)
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
            task.wait(0.15)
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
                local anyStatActive = T("AutoMelee") or T("AutoSword") or T("AutoGun") or T("AutoBloxFruit") or T("AutoDefense")
                if not anyStatActive then return end
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
    local TravelGroup = Tabs.Teleport:AddRightGroupbox("Travel World")

    local names, map, world = getIslandNamesAndMap(game.PlaceId)
    Lists.islandNames = names; Lists.islandMap = map; Lists.worldName = world
    State.selectedIslandName = names[1]; State.selectedIslandPos = map[names[1]]

    TeleportLeft:AddLabel("Current Sea: " .. world)
    TeleportLeft:AddDropdown("IslandSelect", { Values = names, Default = 1, Multi = false, Text = "Select Island", Searchable = true })
    Options.IslandSelect:OnChanged(function()
        State.selectedIslandName = O("IslandSelect")
        State.selectedIslandPos  = Lists.islandMap[State.selectedIslandName]
    end)

    TravelGroup:AddLabel("Current: " .. Lists.worldName)

    TravelGroup:AddButton({
        Text = "Go to First Sea",
        Func = function()
            if sea1 then
                Library:Notify({ Title = "Travel", Description = "Already in First Sea", Time = 3 })
                return
            end
            Library:Notify({ Title = "Travel", Description = "Traveling to First Sea...", Time = 3 })
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")
            end)
        end,
    })

    TravelGroup:AddButton({
        Text = "Go to Second Sea",
        Func = function()
            if sea2 then
                Library:Notify({ Title = "Travel", Description = "Already in Second Sea", Time = 3 })
                return
            end
            Library:Notify({ Title = "Travel", Description = "Traveling to Second Sea...", Time = 3 })
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
            end)
        end,
    })

    TravelGroup:AddButton({
        Text = "Go to Third Sea",
        Func = function()
            if sea3 then
                Library:Notify({ Title = "Travel", Description = "Already in Third Sea", Time = 3 })
                return
            end
            Library:Notify({ Title = "Travel", Description = "Traveling to Third Sea...", Time = 3 })
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
            end)
        end,
    })

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
            State.selectedIslandName = newNames[1]; State.selectedIslandPos = newMap[newNames[1]]
            Library:Notify({ Title = "Teleport", Description = "Reloaded " .. #newNames .. " locations (" .. newWorld .. ")", Time = 3 })
        end,
    })
end

do
    local EspLeft  = Tabs.Esp:AddLeftGroupbox("ESP Options")
    local EspRight = Tabs.Esp:AddRightGroupbox("ESP Info")

    local function onEspToggle(field, key)
        return function()
            ESP[field] = T(key)
            updateESPActive()
            if ESP.AnyActive then
                startEspLoop()
            end
            Library:Notify({ Title = "ESP " .. field, Description = ESP[field] and "ON" or "OFF", Time = 2 })
        end
    end

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
        updateESPActive(); if ESP.AnyActive then startEspLoop() end
        Library:Notify({ Title = "ESP Player", Description = ESP.Player and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspFruit", { Text = "ESP Devil Fruit", Default = false })
    Toggles.EspFruit:OnChanged(onEspToggle("DevilFruit", "EspFruit"))

    EspLeft:AddToggle("EspIsland", { Text = "ESP Island", Default = false })
    Toggles.EspIsland:OnChanged(function()
        ESP.Island = T("EspIsland")
        if not ESP.Island then
            local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
            local locs = worldOrigin and worldOrigin:FindFirstChild("Locations")
            if locs then
                for _, v in next, locs:GetChildren() do
                    pcall(function() if v:FindFirstChild('NameEsp') then v:FindFirstChild('NameEsp'):Destroy() end end)
                end
            end
        end
        updateESPActive(); if ESP.AnyActive then startEspLoop() end
        Library:Notify({ Title = "ESP Island", Description = ESP.Island and "ON" or "OFF", Time = 2 })
    end)

    EspLeft:AddToggle("EspFlower",       { Text = "ESP Flower",                  Default = false })
    EspLeft:AddToggle("EspChest",        { Text = "ESP Chest",                   Default = false })
    EspLeft:AddToggle("EspEventIsland",  { Text = "ESP Sea Event Islands",       Default = false })
    EspLeft:AddToggle("EspLegenSword",   { Text = "ESP Legendary Sword Dealer",  Default = false })
    EspLeft:AddToggle("EspBerry",        { Text = "ESP Berry Bush",              Default = false })

    Toggles.EspFlower:OnChanged(onEspToggle("Flower", "EspFlower"))
    Toggles.EspChest:OnChanged(function()
        ESP.Chest = T("EspChest")
        if not ESP.Chest then
            for _, Chest in ipairs(game:GetService("CollectionService"):GetTagged("_ChestTagged")) do
                local att = Chest:FindFirstChild("ChestEspAttachment")
                if att then att:Destroy() end
            end
        end
        updateESPActive(); if ESP.AnyActive then startEspLoop() end
        Library:Notify({ Title = "ESP Chest", Description = ESP.Chest and "ON" or "OFF", Time = 2 })
    end)
    Toggles.EspEventIsland:OnChanged(onEspToggle("EventIsland", "EspEventIsland"))
    Toggles.EspLegenSword:OnChanged(function()
        ESP.LegenSword = T("EspLegenSword")
        if not ESP.LegenSword then
            if workspace:FindFirstChild("LgdKKKK") then workspace.LgdKKKK:Destroy() end
        end
        updateESPActive(); if ESP.AnyActive then startEspLoop() end
        Library:Notify({ Title = "ESP Legendary", Description = ESP.LegenSword and "ON" or "OFF", Time = 2 })
    end)
    Toggles.EspBerry:OnChanged(function()
        ESP.Berry = T("EspBerry")
        if not ESP.Berry then
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Part") and v.Name:match("^BerryEspKKKK_") then v:Destroy() end
            end
        end
        updateESPActive(); if ESP.AnyActive then startEspLoop() end
        Library:Notify({ Title = "ESP Berry", Description = ESP.Berry and "ON" or "OFF", Time = 2 })
    end)

    EspRight:AddLabel("Blue = Same Team")
    EspRight:AddLabel("Red = Enemy Team")
end

local HopState2 = HopState

doHop = function()
    HopState2.hopTotal = HopState2.hopTotal + 1
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
        if rb then rb.Text = HopState2.hopTarget ~= "" and HopState2.hopTarget or ""; rb:ReleaseFocus() end
    end)
    pcall(function() frame.Refresh:Activate() end)
    task.wait(3)

    local inside = frame:FindFirstChild("FakeScroll") and frame.FakeScroll:FindFirstChild("Inside")
    if not inside then watching = false; return end

    local maxP = HopState2.hopMaxPlayers
    local tried = {}

    local function findBest()
        local best, bestC = nil, math.huge
        local fs = frame:FindFirstChild("FakeScroll"); if not fs then return nil end
        local absPos = fs.AbsolutePosition
        local absSz  = fs.AbsoluteSize
        local cx = absPos.X + absSz.X / 2
        local cy = absPos.Y + absSz.Y / 2

        local function scrollDown() pcall(function() game:GetService("VirtualInputManager"):SendMouseWheelEvent(cx, cy, false, game) end) end
        local function scrollUp()   pcall(function() game:GetService("VirtualInputManager"):SendMouseWheelEvent(cx, cy, true, game) end) end

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
                        seenJobs[jobId] = true; foundNew = true
                        if pc and pc <= maxP then
                            if not best or pc < bestC then bestC = pc; best = { jb = jb, jobId = jobId, cur = pc } end
                        end
                    end
                end
            end
            return foundNew
        end

        for pass = 1, 3 do
            for _ = 1, 30 do scrollUp() end
            task.wait(0.5); seenJobs = {}; readRows()
            local noNew = 0
            while noNew < 10 do
                for _ = 1, 3 do scrollDown() end
                task.wait(0.25)
                if readRows() then noNew = 0 else noNew = noNew + 1 end
                if best then return best end
            end
            if pass < 3 then tried = {}; pcall(function() frame.Refresh:Activate() end); task.wait(4) end
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
                task.wait(1); tryHop()
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
    HopState2.hopCD = (intervalMinutes or 45) * 60
    HopState2.hopTick = tick()
    if HopState2.hopThread then task.cancel(HopState2.hopThread); HopState2.hopThread = nil end
    HopState2.hopThread = task.spawn(function()
        while true do
            task.wait(1)
            local now = tick()
            HopState2.hopCD = HopState2.hopCD - (now - HopState2.hopTick)
            HopState2.hopTick = now
            if HopState2.hopCD <= 0 then
                HopState2.hopCD = (intervalMinutes or 45) * 60
                task.spawn(doHop)
            end
        end
    end)
end

local function stopAutoHop()
    if HopState2.hopThread then task.cancel(HopState2.hopThread); HopState2.hopThread = nil end
    HopState2.hopCD = 0
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
        if T("AutoHop") then stopAutoHop(); startAutoHop(tonumber(O("HopInterval")) or 45) end
    end)

    MiscServ:AddInput("HopRegion", { Text = "Region Filter", Default = "singapore", Numeric = false, Finished = false, Placeholder = "e.g. singapore" })
    Options.HopRegion:OnChanged(function() HopState2.hopTarget = tostring(O("HopRegion") or "singapore"):lower() end)

    MiscServ:AddSlider("HopMaxPlayers", { Text = "Max Players Filter", Min = 1, Max = 20, Default = 3, Rounding = 0 })
    Options.HopMaxPlayers:OnChanged(function() HopState2.hopMaxPlayers = tonumber(O("HopMaxPlayers")) or 3 end)

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
            FastAttackModule.Enabled = false; _B = false
            stopFastAttack(); stopHitRegistration(); stopPositionLock()
            stopNoclip(); smoothCleanAll(); stopTeleportTween(); stopBypassTp(); stopBoatNoclip(); stopPlayerNoclip()
            State.playerTpwalkEnabled = false
            State.playerJumpPowerEnabled = false
            stopPlayerFly(); stopPlayerEditLoop(); stopInfiniteJump()
            if Conns.follow then Conns.follow:Disconnect(); Conns.follow = nil end
            if Conns.farm   then Conns.farm:Disconnect();   Conns.farm   = nil end
            if Conns.boss   then Conns.boss:Disconnect();   Conns.boss   = nil end
            State.autoBossAllEnabled    = false
            State.autoBossAllHopEnabled = false
            if Conns.bossAll    then Conns.bossAll:Disconnect();    Conns.bossAll    = nil end
            if Conns.bossAllHop then Conns.bossAllHop:Disconnect(); Conns.bossAllHop = nil end
            ESP.Player = false; ESP.Island = false; ESP.DevilFruit = false
            ESP.Flower = false; ESP.Chest = false; ESP.EventIsland = false
            ESP.LegenSword = false; ESP.Berry = false; ESP.AnyActive = false
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

    farmBypassActive   = false
    bypassTpArrived    = false
    bypassActive       = false
    noclipCache        = {}
    noclipCacheTick    = 0
    State.currentEnemy = nil
    State.trackedRoot  = nil
    State.currentFlyCF = nil
    State.playerEditCharacter = nil
    State.playerOriginalJumpPower = nil
    State.playerOriginalUseJumpPower = nil
    Lists.cachedSpawnsByName = {}
    State.bypassMoving = false

    if Conns.bypassTp then Conns.bypassTp:Disconnect(); Conns.bypassTp = nil end

    refreshFolders()
    stopPositionLock()
    smoothCleanAll()
    task.wait(1)

    startHitRegistration()
    if State.autoNearEnabled    then startNoclip(); startAutoNear()       end
    if State.autoFarmEnabled    then startNoclip(); startAutoFarm()       end
    if State.autoBossEnabled    then startNoclip(); startAutoBoss()       end
    if State.autoBossAllEnabled    then startNoclip(); startAutoBossAll()    end
    if State.autoBossAllHopEnabled then startNoclip(); startAutoBossAllHop() end
    if State.teleportTweenEnabled  then startNoclip(); startTeleportTween()  end

    if T("BypassTeleport") and State.selectedIslandPos then
        task.wait(0.5)
        State.bypassTpEnabled = true
        local newHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if newHrp then State.currentFlyCF = newHrp.CFrame end
        startBypassTp()
        Library:Notify({ Title = "Bypass TP", Description = "Resuming after respawn...", Time = 3 })
    end

    if State.playerNoclipEnabled then startPlayerNoclip() end
    if State.playerFlyEnabled then startPlayerFly() end
    if State.playerTpwalkEnabled or State.playerJumpPowerEnabled then startPlayerEditLoop() end
    if State.infiniteJumpEnabled then startInfiniteJump() end
    task.wait(1)
    if T("FastAttack") and not State.autoNearEnabled and not State.autoFarmEnabled and not State.autoBossEnabled then
        FastAttackModule.Enabled = true; startFastAttack()
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

Library:Notify({ Title = "KKKK Hub", Description = "Loaded - Freemium", Time = 6 })
SaveManager:LoadAutoloadConfig()
