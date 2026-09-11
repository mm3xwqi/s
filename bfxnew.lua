local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/mm3xwqi/s/refs/heads/main/FluentModed.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/mm3xwqi/s/refs/heads/main/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "KKKK Hub New",
    SubTitle = "by your script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local Tabs = {
    Main        = Window:AddTab({ Title = "Main",        Icon = "sword" }),
    Island      = Window:AddTab({ Title = "Island",      Icon = "map-pin" }),
    FarmSetting = Window:AddTab({ Title = "Farm Setting", Icon = "sliders-horizontal" }),
    Event       = Window:AddTab({ Title = "Event",       Icon = "balloon" }),
    Settings    = Window:AddTab({ Title = "Settings",    Icon = "settings" })
}

-- Sea detection
local placeId = game.PlaceId
local sea1 = (placeId == 2753915549 or placeId == 85211729168715)
local sea2 = (placeId == 4442272183 or placeId == 79091703265657)
local sea3 = (placeId == 7449423635 or placeId == 100117331123089)

-- Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player      = Players.LocalPlayer
local enemiesFolder = workspace:WaitForChild("Enemies")

-- State
local State = {
    autoFarmEnabled        = false,
    bringMobEnabled        = true,
    autoFarmSelectEnabled  = false,
    selectedMobNames       = {},
    currentTarget          = nil,
    isLocked               = false,
    lockStartTime          = nil,
    BRING_MOB_COUNT        = 1,
    SPEED                  = 170,
    Y_OFFSET               = 30,
    ATTACK_RATE            = 0.3,
    ATTACK_RANGE           = 120,
    SNAP_RANGE             = 5,
    BRING_DISTANCE         = 250,
    BRING_INTERVAL         = 0.3,
    SPAWN_TELEPORT_INTERVAL = 0.1,
    isMovingToSpawn        = false,
    spawnPointList         = {},
    spawnPointIndex        = 1,
    lastSpawnTeleportTime  = 0,
    lastAttackTime         = 0,
    lastTargetSwitchTime   = 0,
    TARGET_SWITCH_COOLDOWN = 0.5,
    lastMovePosition       = nil,
    lastMoveTime           = 0,
    idleAnchorCFrame       = nil,
    lastBringUpdate        = 0,
    bringAnchor            = nil,
    targetAnchorCFrame     = nil,
    followConnection       = nil,
    activeBodyGyro         = nil,
    activeAntiGravity      = nil,
    activeTween            = nil,
    tweenTargetPosition    = nil,
    activeHumanoid         = nil,
    selectedIslandName     = nil,
    selectedIslandPos      = nil,
    currentFlyCF           = nil,
    lastTweenStartTime      = 0,
    TWEEN_TIMEOUT           = 10,
    teleportTweenEnabled   = false,
    islandRoute            = nil,
    islandRouteIndex       = 1,
    waitingForWarpPos      = nil,
    warpWaitStart          = 0,
    WARP_TRIGGER_DIST      = 30,
    WARP_WAIT_TIMEOUT      = 8,
}

State.autoEquipEnabled  = true
State.selectedWeaponType = "Melee"
State.lastEquippedTool   = nil

local activeBringBodies  = {}
local bringSnapped       = {}
local originalMobStates  = {}
local originalCanCollide = {}
local mobTweens          = {} 

local function stopMomentum()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity  = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function waitForAlive(timeout)
    local deadline = tick() + (timeout or 12)
    while tick() < deadline do
        local c = player.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if c and c.Parent and h and r and h.Health > 0 then
            return c, r, h
        end
        task.wait(0.1)
    end
    return nil
end

local function cancelTween()
    if State.activeTween then State.activeTween:Cancel(); State.activeTween = nil end
    State.tweenTargetPosition = nil
    stopMomentum()
end

local function getIslandNamesAndMap(pid)
    local islandMap = {}
    local worldName = "Unknown"
    if pid == 2753915549 or pid == 85211729168715 then
        worldName = "First Sea"
        islandMap = {
            ["Starter Island"]    = Vector3.new(1122, 16, 1424),
            ["Marine Starter"]    = Vector3.new(-2750, 32, 2041),
            ["Jungle island"]     = Vector3.new(-1432, 62, 2),
            ["Pirate island"]     = Vector3.new(-1190, 66, 3879),
            ["Desert island"]     = Vector3.new(942, 21, 4378),
            ["Middle Town"]       = Vector3.new(-785, 74, 1606),
            ["Snow island"]       = Vector3.new(1353, 106, -1326),
            ["MarineBase island"] = Vector3.new(-4684, 6, 4185),
            ["Sky 1"]             = Vector3.new(-4879, 960, -833),
            ["Sky 2"]             = Vector3.new(-6000, 5494, 2136),
            ["Sky 3"]             = Vector3.new(-7347, 5793, 374),
            ["Colosseum"]         = Vector3.new(-1366, 13, -2902),
            ["Magma island"]      = Vector3.new(-5395, 27, 8527),
            ["Prison island"]     = Vector3.new(5008, 89, 740),
            ["Whirl Pool"]        = Vector3.new(3874, 5, -1904),
            ["Underwater city"]   = Vector3.new(61170, 6, 1824),
            ["Fountain City"]     = Vector3.new(5168, 76, 4049),
        }
    elseif pid == 4442272183 or pid == 79091703265657 then
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
    elseif pid == 7449423635 or pid == 100117331123089 then
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

local islandNames, islandMap, worldName = getIslandNamesAndMap(placeId)

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
    local c = player.Character
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

local function moveToTarget(hrp, targetCF, dt)
    if not hrp or not hrp.Parent or not targetCF then return end
    local hrpPos = hrp.Position
    if not State.currentFlyCF
        or not State.currentFlyCF.Position
        or (State.currentFlyCF.Position - hrpPos).Magnitude > 150 then
        State.currentFlyCF = hrp.CFrame
    end
    local targetPos  = targetCF.Position
    local currentPos = State.currentFlyCF.Position
    local delta      = targetPos - currentPos
    local dist       = delta.Magnitude
    local step       = (State.SPEED or 200) * dt
    local newPos     = (dist <= step or dist < 0.01) and targetPos or currentPos + (delta / dist) * step
    local rx, ry, rz = targetCF:ToEulerAnglesXYZ()
    local finalCF    = CFrame.new(newPos) * CFrame.fromEulerAnglesXYZ(rx, ry, rz)
    State.currentFlyCF = finalCF
    pcall(function() hrp.CFrame = finalCF end)
end

local Conns = { tweenIsland = nil }

-- SPECIAL ROUTE WAYPOINTS (First Sea)
local UNDERWATER_GATE = CFrame.new(4050.31104, -1.68800354, -1814.12402, -0.244956568, 0, 0.969534814, 0, 1, 0, -0.969534814, 0, -0.244956568)
local SKY_GATE        = CFrame.new(-4192.70508, 1087.56738, -366.055603, 0.49432373, 0.0971033573, 0.863837361, -0.014543999, 0.994526088, -0.103471309, -0.869156241, 0.0385846794, 0.493030131)
local SKY_EXIT        = CFrame.new(-6022.23535, 5470.49902, 2217.33374, -0.990270376, 0, 0.13915664, 0, 1, 0, -0.13915664, 0, -0.990270376)
local UNDERWATER_EXIT = CFrame.new(61170.0469, -2, 1952.83398, 0.922186494, 0, 0.386753023, 0, 1, 0, -0.386753023, 0, 0.922186494)

local SKY_AREA_POS    = Vector3.new(-6000, 5494, 2136) -- Sky 2 / Sky 3 area
local SKY_AREA_RADIUS = 4000

local function isSkyRoute(name)
    return name == "Sky 2" or name == "Sky 3"
end

local function isUnderwaterRoute(name)
    return name == "Underwater city" or name == "Whirl Pool"
end

local function inSkyArea(pos)
    if not pos then return false end
    return pos.Y > 3000 or (pos - SKY_AREA_POS).Magnitude <= SKY_AREA_RADIUS
end

local function inUnderwaterArea(pos)
    if not pos then return false end
    return math.abs(pos.X) > 30000 or math.abs(pos.Z) > 30000
end

local function buildIslandRoute(name, destPos, currentPos)
    local route = {}
    local fromSky = inSkyArea(currentPos)
    local fromUnderwater = inUnderwaterArea(currentPos)

    if isUnderwaterRoute(name) then
        if fromSky then table.insert(route, SKY_EXIT) end
        if not fromUnderwater then table.insert(route, UNDERWATER_GATE) end
        return route, true
    end

    if fromUnderwater then table.insert(route, UNDERWATER_EXIT) end

    if isSkyRoute(name) then
        if not fromSky then table.insert(route, SKY_GATE) end
        table.insert(route, CFrame.new(destPos))
        return route, true
    end
    if fromSky then table.insert(route, SKY_EXIT) end
    table.insert(route, CFrame.new(destPos))
    return route, true
end

local function stopTweenIsland()
    State.teleportTweenEnabled = false
    State.islandRoute = nil
    State.islandRouteIndex = 1
    State.waitingForWarpPos = nil
    if Conns.tweenIsland then Conns.tweenIsland:Disconnect(); Conns.tweenIsland = nil end
end

local function startTweenIsland()
    stopTweenIsland()
    if not State.selectedIslandPos then return end
    State.teleportTweenEnabled = true

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then State.currentFlyCF = hrp.CFrame end

    State.islandRoute      = buildIslandRoute(State.selectedIslandName, State.selectedIslandPos, hrp and hrp.Position)
    State.islandRouteIndex = 1

    Conns.tweenIsland = RunService.Heartbeat:Connect(function(dt)
        if not State.teleportTweenEnabled then stopTweenIsland(); return end
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        if State.waitingForWarpPos then
            local waitPos   = State.waitingForWarpPos
            local movedDist = (hrp.Position - waitPos).Magnitude
            local timedOut  = (tick() - State.warpWaitStart) > State.WARP_WAIT_TIMEOUT
            if movedDist > State.WARP_TRIGGER_DIST or timedOut then
                State.waitingForWarpPos = nil
                State.currentFlyCF = hrp.CFrame
                State.islandRouteIndex = (State.islandRouteIndex or 1) + 1
                stopMomentum()
            else
                pcall(function()
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end
        end

        local route = State.islandRoute
        if not route or #route == 0 then
            route = buildIslandRoute(State.selectedIslandName, State.selectedIslandPos, hrp.Position)
            State.islandRoute      = route
            State.islandRouteIndex = 1
        end

        local idx      = math.clamp(State.islandRouteIndex or 1, 1, #route)
        local targetCF = route[idx]
        local isLast   = (idx >= #route)

        local currentPos = State.currentFlyCF and State.currentFlyCF.Position or hrp.Position
        local dist       = (targetCF.Position - currentPos).Magnitude

        if dist > 6 then
            moveToTarget(hrp, targetCF, dt)
            return
        end

        State.currentFlyCF = targetCF
        pcall(function()
            hrp.CFrame = targetCF
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        if not isLast then
            State.islandRouteIndex = idx
            State.waitingForWarpPos = targetCF.Position
            State.warpWaitStart = tick()
            return
        end

        stopTweenIsland()
        Fluent:Notify({ Title = "Island", Content = "Arrived at " .. (State.selectedIslandName or ""), Duration = 3 })
    end)
end

-- MOB NAME / LABEL HELPERS
local function normalizeMobName(name)
    local normalized = name or ""
    normalized = normalized:gsub("%b[]", "")
    normalized = normalized:gsub("%s+", " ")
    normalized = normalized:gsub("^%s+", "")
    normalized = normalized:gsub("%s+$", "")
    return normalized
end

local function stripDisplayName(displayName)
    local stripped = displayName
        :gsub("%s*%[Lv%.?%s*%d+%]", "")
        :gsub("%s*%[Raid Boss%]", "")
        :gsub("%s*%[Boss%]", "")
        :gsub("%s+$", "")
        :gsub("^%s+", "")
    return stripped
end

local function getMobDisplayName(mob)
    local humanoid = mob and mob:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.DisplayName and humanoid.DisplayName ~= "" then
        return humanoid.DisplayName
    end
    return mob and mob.Name or ""
end

local function getMobBaseName(mob)
    local humanoid = mob and mob:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.DisplayName and humanoid.DisplayName ~= "" then
        return stripDisplayName(humanoid.DisplayName)
    end
    return normalizeMobName(mob and mob.Name or "")
end

local function getEnemySpawnsFolder()
    local ok, folder = pcall(function()
        local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
        return worldOrigin and worldOrigin:FindFirstChild("EnemySpawns")
    end)
    if ok then return folder end
    return nil
end

local function bossTypeFromText(text)
    if not text or text == "" then return nil end
    local lower = tostring(text):lower()
    if lower:find("%[raid boss%]") or lower:find("raid boss") or lower:find("raidboss") then
        return "raidboss"
    elseif lower:find("%[boss%]") or lower:find("boss") then
        return "boss"
    end
    return nil
end

local function bossTypeFromInstance(inst)
    if not inst then return nil end
    local best = bossTypeFromText(inst.Name)
    local okAttr, attrs = pcall(function() return inst:GetAttributes() end)
    if okAttr and attrs then
        for key, value in pairs(attrs) do
            local keyType = bossTypeFromText(key)
            if keyType and value then
                if keyType == "raidboss" then return "raidboss" end
                best = best or keyType
            end
            if type(value) == "string" then
                local valType = bossTypeFromText(value)
                if valType == "raidboss" then return "raidboss" end
                best = best or valType
            end
        end
    end
    local okDesc, descendants = pcall(function() return inst:GetDescendants() end)
    if okDesc and descendants then
        for _, child in ipairs(descendants) do
            if child:IsA("Humanoid") and child.DisplayName and child.DisplayName ~= "" then
                local dnType = bossTypeFromText(child.DisplayName)
                if dnType == "raidboss" then return "raidboss" end
                best = best or dnType
            elseif child:IsA("StringValue") then
                local vType = bossTypeFromText(child.Value)
                if vType == "raidboss" then return "raidboss" end
                best = best or vType
            end
        end
    end
    return best
end

local function buildBossMap()
    local map = {}
    local function register(inst)
        if not inst then return end
        local bossType = bossTypeFromInstance(inst)
        if not bossType then return end
        local keys = {
            normalizeMobName(inst.Name),
            normalizeMobName(getMobBaseName(inst)),
        }
        local hum = inst:FindFirstChildOfClass("Humanoid")
        if hum and hum.DisplayName and hum.DisplayName ~= "" then
            table.insert(keys, normalizeMobName(stripDisplayName(hum.DisplayName)))
        end
        for _, key in ipairs(keys) do
            if key ~= "" then
                if bossType == "raidboss" or not map[key] then
                    map[key] = bossType
                end
            end
        end
    end

    if enemiesFolder then
        for _, mob in ipairs(enemiesFolder:GetChildren()) do register(mob) end
    end
    local spawns = getEnemySpawnsFolder()
    if spawns then
        for _, obj in ipairs(spawns:GetChildren()) do register(obj) end
    end
    return map
end

local bossMapCache = nil
local function refreshBossMap()
    bossMapCache = buildBossMap()
    return bossMapCache
end

local function isMobBoss(rawName)
    local wanted = normalizeMobName(rawName)
    if wanted == "" then return nil end
    local map = bossMapCache or refreshBossMap()
    if map[wanted] then return map[wanted] end
    map = refreshBossMap()
    if map[wanted] then return map[wanted] end
    return bossTypeFromText(rawName)
end

local function makeMobLabel(rawName)
    local bossType = isMobBoss(rawName)
    if bossType == "raidboss" then return rawName .. "  [Raid Boss]"
    elseif bossType == "boss"  then return rawName .. "  [Boss]"
    end
    return rawName
end

local function labelToRawName(label)
    local raw = label:gsub("%s*%[Raid Boss%]", ""):gsub("%s*%[Boss%]", "")
    return raw
end

local function mobMatchesName(mob, wantedName)
    if not mob or not wantedName or wantedName == "" then return false end
    local mobRawName  = normalizeMobName(mob.Name)
    local mobDispName = normalizeMobName(getMobDisplayName(mob))
    local mobBaseName = normalizeMobName(getMobBaseName(mob))
    local wanted      = normalizeMobName(wantedName)
    return mobRawName == wanted
        or mobDispName == wanted
        or mobBaseName == wanted
end

local function sameMobType(firstMob, secondMob)
    if not firstMob or not secondMob then return false end
    local fn = getMobBaseName(firstMob)
    local sn = getMobBaseName(secondMob)
    return normalizeMobName(fn) == normalizeMobName(sn)
        or normalizeMobName(firstMob.Name) == normalizeMobName(secondMob.Name)
end

local function getSpawnFolders()
    local folders = {}
    local spawns = getEnemySpawnsFolder()
    if spawns then table.insert(folders, { source = "WS", folder = spawns }) end
    if enemiesFolder then table.insert(folders, { source = "ENEMIES", folder = enemiesFolder }) end
    return folders
end

local function collectSpawnPosition(obj)
    if obj:IsA("Model") then
        local r = obj.PrimaryPart
            or obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChildWhichIsA("BasePart")
        if r then return r.Position end
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

local function spawnObjMatchesName(obj, wanted)
    if normalizeMobName(obj.Name) == wanted then return true end
    if normalizeMobName(getMobBaseName(obj)) == wanted then return true end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum and hum.DisplayName and hum.DisplayName ~= "" then
        if normalizeMobName(stripDisplayName(hum.DisplayName)) == wanted then return true end
    end
    return false
end

local function positionKey(pos)
    return string.format("%d_%d_%d", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
end

local function getSpawnPositionsForMob(wantedName)
    local wanted = normalizeMobName(wantedName or "")
    if wanted == "" then return {} end
    local positions, seen = {}, {}
    for _, entry in ipairs(getSpawnFolders()) do
        local ok = pcall(function()
            for _, obj in ipairs(entry.folder:GetDescendants()) do
                if (obj:IsA("BasePart") or obj:IsA("Model")) and spawnObjMatchesName(obj, wanted) then
                    local pos = collectSpawnPosition(obj)
                    if pos then
                        local key = positionKey(pos)
                        if not seen[key] then
                            seen[key] = true
                            table.insert(positions, pos)
                        end
                    end
                end
            end
        end)
        if not ok then end
    end
    return positions
end

-- every known mob spawn point
local function getAllSpawnPositions()
    local positions, seen = {}, {}
    local function push(pos)
        if not pos then return end
        local key = positionKey(pos)
        if not seen[key] then
            seen[key] = true
            table.insert(positions, pos)
        end
    end
    local spawns = getEnemySpawnsFolder()
    if spawns then
        pcall(function()
            for _, obj in ipairs(spawns:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    push(collectSpawnPosition(obj))
                end
            end
        end)
    end
    if #positions == 0 and enemiesFolder then
        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            local r = mob:FindFirstChild("HumanoidRootPart")
            if r then push(r.Position) end
        end
    end
    return positions
end

local function sortPositionsByDistance(positions, fromPos)
    table.sort(positions, function(a, b)
        return (a - fromPos).Magnitude < (b - fromPos).Magnitude
    end)
    return positions
end

local function getAvailableMobNames()
    local names = {}
    local seen  = {}

    local function add(name)
        local clean = normalizeMobName(name)
        if clean ~= "" and not seen[clean] then
            seen[clean] = true
            table.insert(names, clean)
        end
    end

    local spawns = getEnemySpawnsFolder()
    if spawns then
        for _, obj in ipairs(spawns:GetChildren()) do
            add(obj.Name)
        end
    end

    if enemiesFolder then
        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            add(mob.Name)
            add(getMobBaseName(mob))
        end
    end

    refreshBossMap()
    table.sort(names)
    return names
end

local function mobTypeExistsInFolder(wantedName)
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if mobMatchesName(enemy, wantedName) then
            return true
        end
    end
    return false
end

local function getHighestPriorityAliveEnemy(position)
    local names = State.selectedMobNames
    if not names or #names == 0 then return nil, nil end

    for priorityIndex, wantedName in ipairs(names) do
        if not mobTypeExistsInFolder(wantedName) then
            continue
        end
        local closestEnemy    = nil
        local closestDistance = math.huge
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if mobMatchesName(enemy, wantedName) then
                local hum  = enemy:FindFirstChildOfClass("Humanoid")
                local root = enemy:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestEnemy    = enemy
                    end
                end
            end
        end
        if closestEnemy then
            return closestEnemy, wantedName
        end
    end
    return nil, nil
end

local function getClosestAliveEnemyNears(position)
    local closestEnemy    = nil
    local closestDistance = math.huge
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        local hum  = enemy:FindFirstChildOfClass("Humanoid")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 then
            local distance = (root.Position - position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestEnemy    = enemy
            end
        end
    end
    return closestEnemy
end

local function getClosestAliveEnemy(position, wantedName)
    if wantedName and wantedName ~= "" then
        local closestEnemy    = nil
        local closestDistance = math.huge
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            if mobMatchesName(enemy, wantedName) then
                local hum  = enemy:FindFirstChildOfClass("Humanoid")
                local root = enemy:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestEnemy    = enemy
                    end
                end
            end
        end
        return closestEnemy
    end
    return getClosestAliveEnemyNears(position)
end

local function isEnemyAlive(enemy)
    if not enemy or not enemy.Parent then return false end
    local humanoid  = enemy:FindFirstChildOfClass("Humanoid")
    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
    if not humanoid or not enemyRoot then return false end
    return humanoid.Health > 0
end

-- Attack / weapon
local RegisterAttack, RegisterHit

local function findRemotes()
    pcall(function()
        local Modules = ReplicatedStorage:FindFirstChild("Modules")
        if not Modules then return end
        local Net = Modules:FindFirstChild("Net")
        if not Net then return end
        RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
        RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
    end)

    if not RegisterHit or not RegisterAttack then
        pcall(function()
            for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local n = obj.Name:lower()
                    if n:find("registerhit") or n:find("register_hit") or n == "re/registerhit" then
                        RegisterHit = obj
                    end
                    if n:find("registerattack") or n:find("register_attack") or n == "re/registerattack" then
                        RegisterAttack = obj
                    end
                end
            end
        end)
    end
end

findRemotes()

local WEAPON_TYPE_KEYWORDS = {
    Melee = { "Melee","melee"},
    Sword = { "Sword","sword"},
    Fruit = { "Fruit","fruit"},
    Gun   = { "Gun","gun"},
}

local function getToolTooltip(tool)
    local tooltipAttr = tool:GetAttribute("ToolTip")
        or tool:GetAttribute("Tooltip")
        or tool:GetAttribute("Type")
        or tool:GetAttribute("WeaponType")
    if tooltipAttr then return tostring(tooltipAttr):lower() end
    local tooltipVal = tool:FindFirstChild("ToolTip")
        or tool:FindFirstChild("Tooltip")
        or tool:FindFirstChild("Type")
    if tooltipVal and (tooltipVal:IsA("StringValue") or tooltipVal:IsA("IntValue")) then
        return tostring(tooltipVal.Value):lower()
    end
    return tool.Name:lower()
end

local function findWeaponByType(wantedType)
    if not wantedType then return nil end
    local keywords = WEAPON_TYPE_KEYWORDS[wantedType]
    if not keywords then return nil end
    local sources = { player.Backpack }
    if player.Character then table.insert(sources, player.Character) end
    for _, container in ipairs(sources) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local tooltip = getToolTooltip(item)
                for _, kw in ipairs(keywords) do
                    if tooltip:find(kw, 1, true) then return item end
                end
            end
        end
    end
    return nil
end

local function autoEquipWeapon()
    if not State.autoEquipEnabled then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        local tooltip = getToolTooltip(currentTool)
        local keywords = WEAPON_TYPE_KEYWORDS[State.selectedWeaponType] or {}
        for _, kw in ipairs(keywords) do
            if tooltip:find(kw, 1, true) then return end
        end
    end
    local target = findWeaponByType(State.selectedWeaponType)
    if target then pcall(function() hum:EquipTool(target) end) end
end

local FastAttackModule = { Rate = State.ATTACK_RATE }
local Refs = {}

function FastAttackModule.GetNearbyTargets(char, folder)
    if not folder or not char then return {} end
    local charPos = char:GetPivot().Position
    local nearby  = {}
    for _, target in ipairs(folder:GetChildren()) do
        local hum  = target:FindFirstChildOfClass("Humanoid")
        local root = target:FindFirstChild("HumanoidRootPart")
        local matchesSelected
        if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
            matchesSelected = false
            for _, wn in ipairs(State.selectedMobNames) do
                if mobMatchesName(target, wn) then matchesSelected = true; break end
            end
        else
            matchesSelected = true
        end
        if hum and root and hum.Health > 0 and matchesSelected then
            if (root.Position - charPos).Magnitude <= State.ATTACK_RANGE then
                table.insert(nearby, target)
            end
        end
    end
    return nearby
end

function FastAttackModule.GetTargetParts(targetList)
    local result = {}
    for _, target in ipairs(targetList) do
        local head = target:FindFirstChild("Head") or target.PrimaryPart
        if head then table.insert(result, {target, head}) end
    end
    return result
end

function FastAttackModule.GetAllTargets(char)
    if not Refs.EnemiesFolder then Refs.EnemiesFolder = workspace:FindFirstChild("Enemies") end
    return FastAttackModule.GetNearbyTargets(char, Refs.EnemiesFolder)
end

local Refs2 = {
    AttackRemoteTarget = nil,
    AttackRemoteId     = nil,
}

local function initHitRegistration()
    local foldersToCheck = {}
    for _, name in ipairs({"Util", "Common", "Remotes", "Assets", "FX"}) do
        local f = ReplicatedStorage:FindFirstChild(name)
        if f then table.insert(foldersToCheck, f) end
    end
    for _, folder in ipairs(foldersToCheck) do
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                Refs2.AttackRemoteTarget = child
                Refs2.AttackRemoteId     = child:GetAttribute("Id")
            end
        end
        folder.ChildAdded:Connect(function(child)
            if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                Refs2.AttackRemoteTarget = child
                Refs2.AttackRemoteId     = child:GetAttribute("Id")
            end
        end)
    end
end
pcall(initHitRegistration)

function FastAttackModule.ExecuteFastAttack()
    local char = player.Character
    if not char then return end
    local targets = FastAttackModule.GetAllTargets(char)
    if #targets < 1 then return end
    local targetParts = FastAttackModule.GetTargetParts(targets)
    if #targetParts < 1 then return end

    if RegisterAttack and RegisterHit then
        RegisterAttack:FireServer(FastAttackModule.Rate)
        local targetHead = targetParts[1][2]
        if targetHead then RegisterHit:FireServer(targetHead, targetParts) end
    end

    local r2target = Refs2 and Refs2.AttackRemoteTarget
    local r2id     = Refs2 and Refs2.AttackRemoteId
    if r2target and r2id and r2target.Parent then
        pcall(function()
            local ok, seed = pcall(function()
                local Net2 = ReplicatedStorage:FindFirstChild("Modules")
                    and ReplicatedStorage.Modules:FindFirstChild("Net")
                return Net2 and Net2:FindFirstChild("seed") and Net2.seed:InvokeServer()
            end)
            if not ok or not seed then seed = math.random(1000, 9999) end
            local remoteCode    = "RE/RegisterHit"
            local encryptionKey = math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1
            local encodedString = string.gsub(remoteCode, ".", function(ch)
                return string.char(bit32.bxor(string.byte(ch), encryptionKey))
            end)
            local finalId    = bit32.bxor(r2id + 909090, seed * 2)
            local cloneref2  = cloneref or function(o) return o end
            local targetHead = targetParts[1][2]
            if targetHead then
                cloneref2(r2target):FireServer(encodedString, finalId, targetHead, targetParts)
            end
        end)
    end
end

local fastAttackThread = nil

local function stopFastAttack()
    if fastAttackThread then
        task.cancel(fastAttackThread)
        fastAttackThread = nil
    end
end

local function startFastAttack()
    stopFastAttack()
    FastAttackModule.Enabled = true
    fastAttackThread = task.spawn(function()
        while FastAttackModule.Enabled do
            pcall(FastAttackModule.ExecuteFastAttack)
            task.wait(FastAttackModule.Rate)
        end
        fastAttackThread = nil
    end)
end

-- Bring Mob
local function applyNoclip(character)
    if not character then return end
    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") then
            if originalCanCollide[object] == nil then
                originalCanCollide[object] = object.CanCollide
            end
            object.CanCollide = false
        end
    end
end

local function restoreCollision()
    for object, canCollide in pairs(originalCanCollide) do
        if object and object.Parent then object.CanCollide = canCollide end
    end
    table.clear(originalCanCollide)
end

local function restoreMobState(mob, state)
    if not state then return end
    for part, canCollide in pairs(state.parts) do
        if part and part.Parent then part.CanCollide = canCollide end
    end
    local humanoid = state.humanoid
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed  = state.walkSpeed
        humanoid.JumpPower  = state.jumpPower
        humanoid.JumpHeight = state.jumpHeight
    end
end

local BRING_SNAP_DISTANCE = 8

local function clearBringMobs()
    for mob, bodies in pairs(activeBringBodies) do
        if type(bodies) == "table" then
            if bodies.bp and bodies.bp.Parent then bodies.bp:Destroy() end
            if bodies.bv and bodies.bv.Parent then bodies.bv:Destroy() end
        else
            local mobRoot = mob and mob.FindFirstChild and mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                local bp = mobRoot:FindFirstChild("BringBodyPos")
                if bp then bp:Destroy() end
            end
        end
        activeBringBodies[mob] = nil
    end
    for mob in pairs(bringSnapped) do bringSnapped[mob] = nil end
    for mob, state in pairs(originalMobStates) do
        restoreMobState(mob, state)
        originalMobStates[mob] = nil
    end
    State.bringAnchor        = nil
    State.lastBringUpdate    = 0
    State.targetAnchorCFrame = nil
end

local function freezeMob(mob, mobRoot, mobHumanoid)
    if not originalMobStates[mob] then
        local state = {
            parts      = {},
            humanoid   = mobHumanoid,
            walkSpeed  = mobHumanoid.WalkSpeed,
            jumpPower  = mobHumanoid.JumpPower,
            jumpHeight = mobHumanoid.JumpHeight,
        }
        for _, part in ipairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                state.parts[part] = part.CanCollide
                part.CanCollide   = false
            end
        end
        originalMobStates[mob] = state
    else
        for part in pairs(originalMobStates[mob].parts) do
            if part and part.Parent then part.CanCollide = false end
        end
    end
    mobHumanoid.WalkSpeed  = 0
    mobHumanoid.JumpPower  = 0
    mobHumanoid.JumpHeight = 0
end

local function updateBringMobs(target, now)
    if not State.bringMobEnabled or (not State.autoFarmEnabled and not State.autoFarmSelectEnabled and not State.eventMagnetActive) then
        clearBringMobs(); return
    end
    if not isEnemyAlive(target) then clearBringMobs(); return end

    if State.bringAnchor ~= target then
        clearBringMobs()
        State.bringAnchor = target
    end

    if now - State.lastBringUpdate < State.BRING_INTERVAL then return end
    State.lastBringUpdate = now

    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then clearBringMobs(); return end

    local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
    if targetHumanoid then
        if not originalMobStates[target] then
            local state = { parts = {}, humanoid = targetHumanoid,
                walkSpeed = targetHumanoid.WalkSpeed, jumpPower = targetHumanoid.JumpPower, jumpHeight = targetHumanoid.JumpHeight }
            for _, part in ipairs(target:GetDescendants()) do
                if part:IsA("BasePart") then state.parts[part] = part.CanCollide; part.CanCollide = false end
            end
            originalMobStates[target] = state
        end
        targetHumanoid.WalkSpeed = 0
        targetHumanoid.JumpPower = 0
        targetHumanoid.JumpHeight = 0
        if not State.targetAnchorCFrame then State.targetAnchorCFrame = targetRoot.CFrame end
        pcall(function() sethiddenproperty(targetRoot, "NetworkOwnershipRule", 0) end)
        targetRoot.CFrame                  = State.targetAnchorCFrame
        targetRoot.AssemblyLinearVelocity  = Vector3.zero
        targetRoot.AssemblyAngularVelocity = Vector3.zero
    end

    local pullPos  = targetRoot.Position
    local bringCount = math.max(0, math.floor(tonumber(State.BRING_MOB_COUNT) or 0))

    local validMobs = {}
    for _, mob in ipairs(enemiesFolder:GetChildren()) do
        if mob == target then continue end
        local mr = mob:FindFirstChild("HumanoidRootPart")
        local mh = mob:FindFirstChildOfClass("Humanoid")
        if not mr or not mh or mh.Health <= 0 then continue end

        local rawName = getMobDisplayName(mob)
        if rawName:find("%[Boss%]") or rawName:find("%[Raid Boss%]") then continue end
        if not sameMobType(mob, target) then continue end

        local dist = (mr.Position - pullPos).Magnitude
        if dist > State.BRING_DISTANCE then continue end

        table.insert(validMobs, { mob = mob, mr = mr, mh = mh, dist = dist })
    end
    table.sort(validMobs, function(a, b) return a.dist < b.dist end)

    local seenMobs = {}
    local slots = math.min(bringCount, #validMobs)
    for i = 1, slots do
        local data = validMobs[i]
        local mob  = data.mob
        local mr   = data.mr
        local mh   = data.mh
        seenMobs[mob] = true

        pcall(function()
            for _, p in ipairs(mob:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                    pcall(function() sethiddenproperty(p, "NetworkOwnershipRule", 0) end)
                end
            end
            pcall(function() sethiddenproperty(mr, "NetworkOwnershipRule", 0) end)

            mh.WalkSpeed  = 0
            mh.JumpPower  = 0
            mh.JumpHeight = 0

            local angle   = (i - 1) * (math.pi * 2 / math.max(1, slots))
            local destPos = pullPos + Vector3.new(math.cos(angle) * 3, 0, math.sin(angle) * 3)
            local dist    = (mr.Position - destPos).Magnitude

            if bringSnapped[mob] or dist <= BRING_SNAP_DISTANCE then
                bringSnapped[mob] = true
                local oldBP = mr:FindFirstChild("BringBodyPos")
                if oldBP then oldBP:Destroy() end
                activeBringBodies[mob]     = true
                mr.CFrame                  = CFrame.new(destPos, pullPos)
                mr.AssemblyLinearVelocity  = Vector3.zero
                mr.AssemblyAngularVelocity = Vector3.zero
            else
                local bp = mr:FindFirstChild("BringBodyPos")
                if not bp then
                    bp = Instance.new("BodyPosition")
                    bp.Name        = "BringBodyPos"
                    bp.MaxForce    = Vector3.new(1e9, 1e9, 1e9)
                    bp.P           = 30000
                    bp.D           = 900
                    bp.Parent      = mr
                end
                bp.Position            = destPos
                activeBringBodies[mob] = { bp = bp }
            end
        end)
    end

    for mob in pairs(activeBringBodies) do
        if not seenMobs[mob] then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                local bp = mobRoot:FindFirstChild("BringBodyPos")
                if bp then bp:Destroy() end
            end
            activeBringBodies[mob] = nil
            bringSnapped[mob]      = nil

        end
    end
    for mob, state in pairs(originalMobStates) do
        if not seenMobs[mob] and mob ~= target then
            restoreMobState(mob, state)
            originalMobStates[mob] = nil
        end
    end
end

local function tweenToSpawn(root, spawnPos)
    if not root or not spawnPos then return false end
    local dist = (spawnPos - root.Position).Magnitude
    cancelTween()
    State.activeTween = TweenService:Create(root,
        TweenInfo.new(math.max(dist / math.max(State.SPEED, 1), 0.05), Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(spawnPos + Vector3.new(0, 5, 0)) })
    State.tweenTargetPosition = spawnPos
    State.activeTween:Play()
    State.lastTweenStartTime  = tick()
    State.isMovingToSpawn     = true
    return true
end


-- cleanup / setup
local function cleanup()
    if State.followConnection then State.followConnection:Disconnect(); State.followConnection = nil end
    cancelTween()
    if State.activeAntiGravity then State.activeAntiGravity:Destroy(); State.activeAntiGravity = nil end
    if State.activeBodyGyro then State.activeBodyGyro:Destroy(); State.activeBodyGyro = nil end
    clearBringMobs()
    if State.activeHumanoid then State.activeHumanoid.AutoRotate = true; State.activeHumanoid = nil end
    restoreCollision()
    State.isMovingToSpawn      = false
    State.spawnPointList       = {}
    State.spawnPointIndex      = 1
    State.currentTarget        = nil
    State.isLocked             = false
    State.lockStartTime        = nil
    State.idleAnchorCFrame     = nil
    State.lastMovePosition     = nil
    State.lastMoveTime         = 0
end

local function setupCharacter(character)
    cleanup()

    local root     = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    State.activeHumanoid  = humanoid
    humanoid.AutoRotate   = false

    local antiGravity     = Instance.new("BodyForce")
    antiGravity.Name      = "TweenAntiGravity"
    antiGravity.Force     = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)
    antiGravity.Parent    = root

    local bodyGyro        = Instance.new("BodyGyro")
    bodyGyro.Name         = "FollowBodyGyro"
    bodyGyro.MaxTorque    = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P            = 50000
    bodyGyro.D            = 1500
    bodyGyro.CFrame       = root.CFrame
    bodyGyro.Parent       = root

    State.activeAntiGravity = antiGravity
    State.activeBodyGyro    = bodyGyro
    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)

    State.followConnection = RunService.Heartbeat:Connect(function(dt)
        local farmActive = State.autoFarmEnabled or State.autoFarmSelectEnabled
        if not farmActive then cleanup(); return end
        if not character.Parent or not root.Parent then cleanup(); return end

        antiGravity.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)
        applyNoclip(character)

        local tweenPlaying = State.activeTween
            and State.activeTween.PlaybackState == Enum.PlaybackState.Playing
        if true then
            root.AssemblyLinearVelocity  = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end

        local nowTick = tick()

        if State.isLocked then
            State.lastMovePosition = root.Position
            State.lastMoveTime     = nowTick
        else
            if not State.lastMovePosition
                or (root.Position - State.lastMovePosition).Magnitude > 5 then
                State.lastMovePosition = root.Position
                State.lastMoveTime     = nowTick
            elseif nowTick - State.lastMoveTime > 2.5 then
                State.lastMovePosition = root.Position
                State.lastMoveTime     = nowTick
                cancelTween()
                State.currentTarget    = nil
                State.isMovingToSpawn  = false
            end
        end

        if State.activeTween
            and State.activeTween.PlaybackState == Enum.PlaybackState.Playing
            and nowTick - State.lastTweenStartTime > State.TWEEN_TIMEOUT then
            cancelTween()
            State.currentTarget   = nil
            State.isMovingToSpawn = false
        end

        if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
            local currentPriority = math.huge
            if State.currentTarget and isEnemyAlive(State.currentTarget) then
                for idx, wn in ipairs(State.selectedMobNames) do
                    if mobMatchesName(State.currentTarget, wn) then
                        currentPriority = idx; break
                    end
                end
            end

            if not isEnemyAlive(State.currentTarget) or currentPriority == math.huge then
                local newTarget, _ = getHighestPriorityAliveEnemy(root.Position)
                if newTarget ~= State.currentTarget then
                    State.lastTargetSwitchTime = tick()
                    cancelTween()
                end
                State.currentTarget = newTarget
            else
                if tick() - State.lastTargetSwitchTime >= 0.1 then
                    local betterTarget, _ = getHighestPriorityAliveEnemy(root.Position)
                    if betterTarget and betterTarget ~= State.currentTarget then
                        local betterPriority = math.huge
                        for idx, wn in ipairs(State.selectedMobNames) do
                            if mobMatchesName(betterTarget, wn) then betterPriority = idx; break end
                        end
                        if betterPriority < currentPriority then
                            State.currentTarget         = betterTarget
                            State.lastTargetSwitchTime  = tick()
                            cancelTween()
                        end
                    end
                end
            end

        elseif State.autoFarmEnabled then
            if not isEnemyAlive(State.currentTarget) then
                State.currentTarget = getClosestAliveEnemyNears(root.Position)
            else
                local nearest = getClosestAliveEnemyNears(root.Position)
                if nearest and nearest ~= State.currentTarget
                    and tick() - State.lastTargetSwitchTime >= 0.1 then
                    local curRoot = State.currentTarget:FindFirstChild("HumanoidRootPart")
                    local newRoot = nearest:FindFirstChild("HumanoidRootPart")
                    if curRoot and newRoot then
                        local curDist = (curRoot.Position - root.Position).Magnitude
                        local newDist = (newRoot.Position - root.Position).Magnitude
                        if newDist < curDist - 20 then
                            State.currentTarget        = nearest
                            State.lastTargetSwitchTime = tick()
                            cancelTween()
                        end
                    end
                end
            end
        end

        if not State.currentTarget then
            local tweenActive = State.activeTween
                and State.activeTween.PlaybackState == Enum.PlaybackState.Playing

            if State.isMovingToSpawn then
                local earlyTarget, _ = getHighestPriorityAliveEnemy(root.Position)
                if not earlyTarget and State.autoFarmEnabled then
                    earlyTarget = getClosestAliveEnemyNears(root.Position)
                end
                if earlyTarget then
                    cancelTween()
                    State.isMovingToSpawn      = false
                    State.currentTarget        = earlyTarget
                    State.lastTargetSwitchTime = tick()
                    State.idleAnchorCFrame     = nil
                    State.spawnPointList       = {}
                    State.spawnPointIndex      = 1
                elseif tweenActive then
                    return
                else
                    State.isMovingToSpawn = false
                    if #State.spawnPointList > 1 then
                        State.spawnPointIndex = (State.spawnPointIndex % #State.spawnPointList) + 1
                        tweenToSpawn(root, State.spawnPointList[State.spawnPointIndex])
                        return
                    end
                    State.spawnPointList  = {}
                    State.spawnPointIndex = 1
                end
            end

            if not State.currentTarget then
                cancelTween(); clearBringMobs(); State.isLocked = false

                if not State.idleAnchorCFrame then
                    State.idleAnchorCFrame = root.CFrame
                end
                root.AssemblyLinearVelocity  = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                local anchorDist = (root.Position - State.idleAnchorCFrame.Position).Magnitude
                if anchorDist > 150 then
                    State.idleAnchorCFrame = root.CFrame
                elseif anchorDist > 2 then
                    root.CFrame = State.idleAnchorCFrame
                end

                local farmSelect = State.autoFarmSelectEnabled and #State.selectedMobNames > 0
                if farmSelect or State.autoFarmEnabled then
                    local now = tick()
                    if now - State.lastSpawnTeleportTime >= 0.05 then
                        State.lastSpawnTeleportTime = now

                        if #State.spawnPointList == 0 then
                            local list = {}
                            if farmSelect then
                                local seenPos = {}
                                for _, wn in ipairs(State.selectedMobNames) do
                                    for _, p in ipairs(getSpawnPositionsForMob(wn)) do
                                        local key = positionKey(p)
                                        if not seenPos[key] then
                                            seenPos[key] = true
                                            table.insert(list, p)
                                        end
                                    end
                                end
                            else
                                list = getAllSpawnPositions()
                            end
                            sortPositionsByDistance(list, root.Position)
                            State.spawnPointList  = list
                            State.spawnPointIndex = 1
                        end

                        if #State.spawnPointList > 0 then
                            if State.spawnPointIndex > #State.spawnPointList then
                                State.spawnPointIndex = 1
                            end
                            if tweenToSpawn(root, State.spawnPointList[State.spawnPointIndex]) then
                                State.idleAnchorCFrame = nil
                            end
                        end
                    end
                end
                return
            end
        end

        State.idleAnchorCFrame = nil
        if State.isMovingToSpawn then
            cancelTween()
            State.isMovingToSpawn = false
        end
        State.spawnPointList  = {}
        State.spawnPointIndex = 1

        local targetRoot = State.currentTarget:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            State.currentTarget = nil; cancelTween(); clearBringMobs(); State.isLocked = false; return
        end

        updateBringMobs(State.currentTarget, tick())

        local targetCFrame   = targetRoot.CFrame * CFrame.new(0, State.Y_OFFSET, 3)
        local targetPosition = targetCFrame.Position
        local distance       = (targetPosition - root.Position).Magnitude

        if distance <= State.ATTACK_RANGE then
            if not State.isLocked then
                State.lockStartTime = tick()
            end
            State.isLocked = true
            autoEquipWeapon()

            cancelTween()
            State.tweenTargetPosition = nil
            root.AssemblyLinearVelocity  = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = targetCFrame

            if State.lockStartTime and tick() - State.lockStartTime > 12 then
                State.isLocked      = false
                State.lockStartTime = nil
                State.currentTarget = nil
                clearBringMobs()
                return
            end

            bodyGyro.CFrame = CFrame.new(root.Position, targetRoot.Position)
            local now = tick()
            if now - State.lastAttackTime >= State.ATTACK_RATE then
                pcall(FastAttackModule.ExecuteFastAttack)
                State.lastAttackTime = now
            end
        else
            State.isLocked      = false
            State.lockStartTime = nil
            if distance > 0.1 then
                local tweenDur    = math.max(distance / math.max(State.SPEED, 1), 0.05)
                local targetMoved = not State.tweenTargetPosition
                    or (State.tweenTargetPosition - targetPosition).Magnitude > 2
                local tweenFinished = not State.activeTween
                    or State.activeTween.PlaybackState ~= Enum.PlaybackState.Playing
                if targetMoved or tweenFinished then
                    cancelTween()
                    State.activeTween = TweenService:Create(root,
                        TweenInfo.new(tweenDur, Enum.EasingStyle.Linear), { CFrame = targetCFrame })
                    State.tweenTargetPosition = targetPosition
                    State.activeTween:Play()
                    State.lastTweenStartTime  = tick()
                end
            else
                cancelTween()
            end
            bodyGyro.CFrame = CFrame.new(root.Position, targetRoot.Position)
        end
    end)
end

local character = player.Character or player.CharacterAdded:Wait()
setupCharacter(character)
player.CharacterAdded:Connect(function(newChar)
    State.currentFlyCF = nil
    setupCharacter(newChar)

    task.spawn(function()
        task.wait(1.5)
        if not State.autoEquipEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local deadline = tick() + 5
        while tick() < deadline do
            local weapon = findWeaponByType(State.selectedWeaponType)
            if weapon then
                pcall(function() hum:EquipTool(weapon) end)
                break
            end
            task.wait(0.3)
        end
    end)
end)


local rawMobNames   = getAvailableMobNames()
local mobLabelList  = {}
for _, rawName in ipairs(rawMobNames) do
    table.insert(mobLabelList, makeMobLabel(rawName))
end

if #mobLabelList == 0 then
    table.insert(mobLabelList, "No mob spawn found")
    table.insert(rawMobNames,  "No mob spawn found")
end

State.selectedMobNames = { rawMobNames[1] }
local MobSelectDropdown
MobSelectDropdown = Tabs.Main:AddDropdown("MobSelectDropdown", {
    Title   = "Select Mob",
    Values  = mobLabelList,
    Multi   = true,
    Default = { mobLabelList[1] },
    Callback = function(selectedTable)
        local orderedNames = {}
        for idx, label in ipairs(mobLabelList) do
            if selectedTable[label] then
                local raw = labelToRawName(label)
                if raw ~= "" and raw ~= "No mob spawn found" then
                    table.insert(orderedNames, normalizeMobName(raw))
                end
            end
        end
        State.selectedMobNames      = orderedNames
        State.currentTarget         = nil
        State.lastSpawnTeleportTime = 0
        State.spawnPointList        = {}
        State.spawnPointIndex       = 1
        State.isMovingToSpawn       = false
        clearBringMobs()
        local names = #orderedNames > 0 and table.concat(orderedNames, ", ") or "None"
        Fluent:Notify({ Title = "Select Mob", Content = "Priority: " .. names, Duration = 3 })
    end
})

Tabs.Main:AddToggle("AutoFarmSelectToggle", {
    Title = "Auto Farm Select", Default = State.autoFarmSelectEnabled,
    Callback = function(value)
        State.autoFarmSelectEnabled = value and #State.selectedMobNames > 0
        State.currentTarget         = nil
        State.lastSpawnTeleportTime = 0
        State.spawnPointList        = {}
        State.spawnPointIndex       = 1
        State.isMovingToSpawn       = false
        clearBringMobs()
        if State.autoFarmSelectEnabled and not State.autoFarmEnabled then
            local char = player.Character; if char then setupCharacter(char) end
        elseif not State.autoFarmSelectEnabled and not State.autoFarmEnabled then
            cleanup()
        end
        Fluent:Notify({ Title = "Auto Farm Select", Content = State.autoFarmSelectEnabled and "Enabled" or "Disabled", Duration = 2 })
    end
})

Tabs.Main:AddButton({
    Title = "Refresh Mob List",
    Description = "",
    Callback = function()
        local success, names = pcall(getAvailableMobNames)
        if not success or not names or #names == 0 then
            Fluent:Notify({ Title = "Refresh", Content = "à¹„à¸¡à¹ˆà¸žà¸šà¸¡à¸­à¸š", Duration = 2 })
            return
        end

        local labels = {}
        for _, rawName in ipairs(names) do
            table.insert(labels, makeMobLabel(rawName))
        end

        local selectedSet = {}
        for _, raw in ipairs(State.selectedMobNames) do
            selectedSet[normalizeMobName(raw)] = true
        end

        local stillSelected = {}
        local hasSelection = false
        for _, label in ipairs(labels) do
            local raw = normalizeMobName(labelToRawName(label))
            if selectedSet[raw] then
                stillSelected[label] = true
                hasSelection = true
            end
        end

        rawMobNames  = names
        mobLabelList = labels

        pcall(function()
            if MobSelectDropdown.SetValues then
                MobSelectDropdown:SetValues(mobLabelList)
            end
        end)

        task.defer(function()
            if hasSelection and MobSelectDropdown and MobSelectDropdown.SetValue then
                pcall(function()
                    MobSelectDropdown:SetValue(stillSelected)
                end)
            end
        end)

        Fluent:Notify({ Title = "Refresh", Content = "Update " .. #names .. " Mobs", Duration = 2 })
    end
})

Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm Nears", Default = State.autoFarmEnabled,
    Callback = function(value)
        State.autoFarmEnabled = value
        if value then
            State.currentTarget = nil
            local char = player.Character; if char then setupCharacter(char) end
            Fluent:Notify({ Title = "Auto Farm", Content = "Enabled â€” attacking nearest enemy", Duration = 2 })
        else
            if not State.autoFarmSelectEnabled then cleanup() end
            Fluent:Notify({ Title = "Auto Farm", Content = "Disabled", Duration = 2 })
        end
    end
})

Tabs.Main:AddToggle("BringMobToggle", {
    Title = "Bring Mob", Default = State.bringMobEnabled,
    Callback = function(value)
        State.bringMobEnabled = value
        if not value then clearBringMobs() end
        Fluent:Notify({ Title = "Bring Mob", Content = value and "Enabled" or "Disabled", Duration = 2 })
    end
})

Tabs.Main:AddToggle("StandaloneFastAttackToggle", {
    Title = "Fast Attack",
    Description = "",
    Default = false,
    Callback = function(value)
        FastAttackModule.Enabled = value
        if value then
            startFastAttack()
            Fluent:Notify({
                Title   = "Fast Attack",
                Content = "Enabled â€” Range: " .. State.ATTACK_RANGE .. " | Rate: " .. State.ATTACK_RATE,
                Duration = 2
            })
        else
            stopFastAttack()
            Fluent:Notify({ Title = "Fast Attack", Content = "Disabled", Duration = 2 })
        end
    end
})

Tabs.Island:AddParagraph({ Title = worldName, Content = "Select island then enable toggle" })

Tabs.Island:AddDropdown("IslandDropdown", {
    Title = "Select Island", Values = islandNames, Multi = false, Default = 1,
    Callback = function(value)
        State.selectedIslandName = value
        State.selectedIslandPos  = islandMap[value]
    end
})
State.selectedIslandName = islandNames[1]
State.selectedIslandPos  = islandMap[islandNames[1]]

Tabs.Island:AddToggle("TweenToIslandToggle", {
    Title = "Go to Island",
    Default = false,
    Callback = function(value)
        State.teleportTweenEnabled = value
        if value then
            if not State.selectedIslandPos then
                Fluent:Notify({ Title = "Island", Content = "Select island first", Duration = 2 })
                return
            end
            Fluent:Notify({ Title = "Island", Content = "Going to " .. (State.selectedIslandName or ""), Duration = 2 })
            startTweenIsland()
        else
            stopTweenIsland()
            Fluent:Notify({ Title = "Island", Content = "Stopped", Duration = 2 })
        end
    end
})

Tabs.FarmSetting:AddParagraph({ Title = "EquipWeapon", Content = "Weapon Tab" })

Tabs.FarmSetting:AddDropdown("WeaponTypeDropdown", {
    Title = "Weapon Type",
    Values = { "Melee", "Sword", "Fruit", "Gun" },
    Multi = false,
    Default = 1,
    Callback = function(value)
        State.selectedWeaponType = value
        Fluent:Notify({ Title = "Weapon Type", Content = "Selected " .. value, Duration = 2 })
    end
})

Tabs.FarmSetting:AddToggle("AutoEquipToggle", {
    Title = "Auto Equip Weapon",
    Default = State.autoEquipEnabled,
    Callback = function(value)
        State.autoEquipEnabled = value
        Fluent:Notify({
            Title = "Auto Equip",
            Content = value and ("Enabled Equip " .. State.selectedWeaponType) or "Disabled",
            Duration = 2
        })
    end
})

Tabs.FarmSetting:AddParagraph({ Title = "TweenSpeed Etc", Content = "Setting Tab" })

Tabs.FarmSetting:AddSlider("BringMobCountSlider", {
    Title = "Bring Mob Count", Default = State.BRING_MOB_COUNT, Min = 1, Max = 20, Rounding = 0,
    Callback = function(value) State.BRING_MOB_COUNT = math.floor(value) end
})

Tabs.FarmSetting:AddSlider("SpeedSlider", {
    Title = "Farm Tween Speed", Default = State.SPEED, Min = 50, Max = 500, Rounding = 0,
    Callback = function(value) State.SPEED = value end
})

Tabs.FarmSetting:AddSlider("YOffsetSlider", {
    Title = "Y Offset", Default = State.Y_OFFSET, Min = 0, Max = 120, Rounding = 0,
    Callback = function(value) State.Y_OFFSET = value end
})

Tabs.FarmSetting:AddSlider("AttackRateSlider", {
    Title = "Attack Rate", Default = State.ATTACK_RATE, Min = 0.05, Max = 1.0, Rounding = 2,
    Callback = function(value)
        State.ATTACK_RATE = value
        FastAttackModule.Rate = value
    end
})

Tabs.FarmSetting:AddSlider("AttackRangeSlider", {
    Title = "Attack Range", Default = State.ATTACK_RANGE, Min = 10, Max = 300, Rounding = 0,
    Callback = function(value)
        State.ATTACK_RANGE = value
    end
})


-- Auto Event Magnet
local MAGNET_OBJECT_NAME = "MagnetTransformedRigObject"

State.autoEventMagnetEnabled = false
State.eventMagnetActive      = false
State.EVENT_POINT_WAIT       = 0.5
State.EVENT_TZ_OFFSET        = 7
State.EVENT_START_MINUTE     = 0
State.EVENT_END_MINUTE       = 10

local eventThread        = nil
local eventClockThread   = nil
local lastEventCycleKey  = nil
local eventLockedMobName = nil
local eventLockedPosition = nil
local eventLockLostTime   = nil
local eventScanPoints     = {}
local eventScanIndex      = 1
State.EVENT_LOCK_GRACE       = 3
State.EVENT_SAME_NAME_LIMIT    = 2
State.EVENT_SAME_SPAWN_LIMIT   = 1

-- memory for this event round
local eventThread        = nil
local eventClockThread   = nil
local lastEventCycleKey  = nil
local eventLockedMobName = nil
local eventLockedPosition = nil
local eventLockLostTime   = nil
local eventScanPoints     = {}
local eventScanIndex      = 1

local eventVisitedKeys     = {}
local eventNameKillCount   = {}
local eventSpawnCheckCount = {}
local eventSkipSpawnNames  = {}
local eventSkipNames       = {}
local eventDoneMobs        = setmetatable({}, { __mode = "k" })

local function eventPointKey(pos)
    return math.floor(pos.X / 15) .. "_" .. math.floor(pos.Y / 15) .. "_" .. math.floor(pos.Z / 15)
end

local function eventResetMemory()
    eventVisitedKeys     = {}
    eventNameKillCount   = {}
    eventSpawnCheckCount = {}
    eventSkipSpawnNames  = {}
    eventSkipNames       = {}
    eventDoneMobs        = setmetatable({}, { __mode = "k" })
end

local function eventNotify(msg)
    Fluent:Notify({ Title = "Event Magnet", Content = msg, Duration = 3 })
end

local function isMagnetMob(mob)
    if not mob or not mob.Parent then return false end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not mob:FindFirstChild("HumanoidRootPart") then return false end
    return mob:FindFirstChild(MAGNET_OBJECT_NAME, true) ~= nil
end

local function findMagnetMob(requiredName, nearPosition)
    local best, bestDist = nil, math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local from = nearPosition or (root and root.Position) or Vector3.zero
    for _, mob in ipairs(enemiesFolder:GetChildren()) do
        if eventDoneMobs[mob] then continue end
        if eventSkipNames[mob.Name] then continue end
        if requiredName and mob.Name ~= requiredName then continue end
        if not isMagnetMob(mob) then continue end
        local d = (mob.HumanoidRootPart.Position - from).Magnitude
        if d < bestDist then best, bestDist = mob, d end
    end
    return best
end

local function getEventSpawnPoints()
    local points, seen = {}, {}
    local queuedPerName = {}

    local function addPos(pos, rawName)
        local spawnName = normalizeMobName(rawName or "Unknown Spawn")
        if spawnName == "" then spawnName = "Unknown Spawn" end
        if eventSkipSpawnNames[spawnName] then return end
        local alreadyChecked = eventSpawnCheckCount[spawnName] or 0
        local alreadyQueued  = queuedPerName[spawnName] or 0
        if alreadyChecked + alreadyQueued >= State.EVENT_SAME_SPAWN_LIMIT then return end
        local key = eventPointKey(pos)
        if not seen[key] and not eventVisitedKeys[key] then
            seen[key] = true
            queuedPerName[spawnName] = alreadyQueued + 1
            table.insert(points, { position = pos, spawnName = spawnName })
        end
    end

    local spawns = getEnemySpawnsFolder()
    if spawns then
        pcall(function()
            for _, obj in ipairs(spawns:GetChildren()) do
                local pos = collectSpawnPosition(obj)
                if not pos then
                    local part = obj:FindFirstChildWhichIsA("BasePart", true)
                    if part then pos = part.Position end
                end
                if pos then addPos(pos, obj.Name) end
            end
        end)
    end

    if enemiesFolder then
        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            local r = mob:FindFirstChild("HumanoidRootPart")
            if r then addPos(r.Position, mob.Name) end
        end
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local from = root.Position
        table.sort(points, function(a, b)
            return (a.position - from).Magnitude < (b.position - from).Magnitude
        end)
    end
    return points
end

local eventNoclipConn = nil

local function eventPrepare(char)
    if not char then return end
    applyNoclip(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = false end
    if root then
        local ag = root:FindFirstChild("EventAntiGravity")
        if not ag then
            ag        = Instance.new("BodyForce")
            ag.Name   = "EventAntiGravity"
            ag.Parent = root
        end
        ag.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)
        if not root:FindFirstChild("EventBodyGyro") then
            local gyro     = Instance.new("BodyGyro")
            gyro.Name      = "EventBodyGyro"
            gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            gyro.P         = 50000
            gyro.D         = 1500
            gyro.CFrame    = root.CFrame
            gyro.Parent    = root
        end
    end
    if not eventNoclipConn then
        eventNoclipConn = RunService.Heartbeat:Connect(function()
            if not State.eventMagnetActive then return end
            local c = player.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not r then return end
            applyNoclip(c)
            local ag = r:FindFirstChild("EventAntiGravity")
            if ag then ag.Force = Vector3.new(0, r.AssemblyMass * workspace.Gravity, 0) end
            r.AssemblyLinearVelocity  = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

local function eventClearPrepare()
    if eventNoclipConn then eventNoclipConn:Disconnect(); eventNoclipConn = nil end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local ag = root:FindFirstChild("EventAntiGravity")
        if ag then ag:Destroy() end
        local gyro = root:FindFirstChild("EventBodyGyro")
        if gyro then gyro:Destroy() end
    end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    if not State.autoFarmEnabled and not State.autoFarmSelectEnabled then
        restoreCollision()
    end
end

local function eventTweenTo(pos, timeout)
    local char, root = waitForAlive(10)
    if not root then return false end
    eventPrepare(char)
    local dist = (pos - root.Position).Magnitude
    if dist < 5 then return true end
    local dur  = math.clamp(dist / math.max(State.SPEED, 1), 0.05, 20)
    cancelTween()
    State.activeTween = TweenService:Create(root,
        TweenInfo.new(dur, Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(pos + Vector3.new(0, State.Y_OFFSET, 0)) })
    State.activeTween:Play()
    local deadline = tick() + (timeout or (dur + 3))
    while tick() < deadline do
        if not State.eventMagnetActive then cancelTween(); return false end
        if not State.activeTween or State.activeTween.PlaybackState ~= Enum.PlaybackState.Playing then break end
        if findMagnetMob() then cancelTween(); break end
        task.wait(0.1)
    end
    cancelTween()
    return true
end

local function eventAttack(mob)
    local char = player.Character
    if not char then return end
    local head = mob:FindFirstChild("Head") or mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart")
    if not head then return end
    pcall(FastAttackModule.ExecuteFastAttack)
    local parts = { { mob, head } }
    if RegisterAttack and RegisterHit then
        pcall(function()
            RegisterAttack:FireServer(State.ATTACK_RATE)
            RegisterHit:FireServer(head, parts)
        end)
    end
end

local function eventKillMagnetMob(mob)
    local hum   = mob:FindFirstChildOfClass("Humanoid")
    local mroot = mob:FindFirstChild("HumanoidRootPart")
    if not hum or not mroot then return end
    eventNotify("Magnet mob found: " .. tostring(mob.Name))

    if mroot.Parent then
        eventTweenTo(mroot.Position, 15)
    end

    local lastAttack = 0
    while State.eventMagnetActive and mob.Parent and hum.Health > 0 and isMagnetMob(mob) do
        local char, root = waitForAlive(5)
        if not root then break end
        if not mroot.Parent then break end
        eventPrepare(char)
        cancelTween()

        local targetCFrame = mroot.CFrame * CFrame.new(0, State.Y_OFFSET, 3)
        root.AssemblyLinearVelocity  = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = targetCFrame

        local gyro = root:FindFirstChild("EventBodyGyro")
        if gyro then gyro.CFrame = CFrame.new(root.Position, mroot.Position) end

        if State.bringMobEnabled then
            pcall(updateBringMobs, mob, tick())
        end

        local now = tick()
        if now - lastAttack >= State.ATTACK_RATE then
            lastAttack = now
            eventAttack(mob)
        end
        RunService.Heartbeat:Wait()
    end
    clearBringMobs()
end

local function runEventMagnet()
    if State.eventMagnetActive then return end
    State.eventMagnetActive = true
    eventThread = task.spawn(function()
        eventNotify("Started - scanning monster spawn points")
        while State.eventMagnetActive do
            local mob = findMagnetMob(eventLockedMobName, eventLockedPosition)
            if not mob and eventLockedMobName then
                mob = findMagnetMob()
                if mob then eventLockedMobName = mob.Name end
            end

            if mob then
                eventLockLostTime = nil
                local mobName = mob.Name
                if not eventLockedMobName then
                    eventLockedMobName = mobName
                    eventNotify("Locked: " .. tostring(mobName))
                end
                eventLockedPosition = mob.HumanoidRootPart.Position
                eventVisitedKeys[eventPointKey(eventLockedPosition)] = true
                eventKillMagnetMob(mob)

                if mob.Parent == nil or not isMagnetMob(mob) then
                    eventDoneMobs[mob] = true
                    eventNameKillCount[mobName] = (eventNameKillCount[mobName] or 0) + 1
                    if eventNameKillCount[mobName] >= State.EVENT_SAME_NAME_LIMIT then
                        eventSkipNames[mobName] = true
                        eventNotify(tostring(mobName) .. " done - moving on")
                    end
                    eventLockedMobName  = nil
                    eventLockedPosition = nil
                    eventLockLostTime   = nil
                    eventScanPoints     = {}
                    eventScanIndex      = 1
                end

            elseif eventLockedMobName then
                eventLockLostTime = eventLockLostTime or tick()
                if tick() - eventLockLostTime > State.EVENT_LOCK_GRACE then
                    eventNotify("No magnet mob here - scanning other points")
                    eventLockedMobName  = nil
                    eventLockedPosition = nil
                    eventLockLostTime   = nil
                    eventScanPoints     = {}
                    eventScanIndex      = 1
                else
                    local char = player.Character
                    if char then eventPrepare(char) end
                    task.wait(0.3)
                end
            else
                if #eventScanPoints == 0 or eventScanIndex > #eventScanPoints then
                    eventScanPoints = getEventSpawnPoints()
                    eventScanIndex  = 1
                    if #eventScanPoints == 0 then task.wait(0.5) end
                end
                if #eventScanPoints > 0 then
                    local point = eventScanPoints[eventScanIndex]
                    eventScanIndex = eventScanIndex + 1
                    local pos       = point.position
                    local spawnName = point.spawnName
                    eventVisitedKeys[eventPointKey(pos)] = true
                    eventSpawnCheckCount[spawnName] = (eventSpawnCheckCount[spawnName] or 0) + 1
                    if eventSpawnCheckCount[spawnName] >= State.EVENT_SAME_SPAWN_LIMIT then
                        eventSkipSpawnNames[spawnName] = true
                    end
                    eventTweenTo(pos, 25)
                    local deadline = tick() + State.EVENT_POINT_WAIT
                    local found = nil
                    while tick() < deadline and State.eventMagnetActive do
                        found = findMagnetMob()
                        if found then break end
                        task.wait(0.05)
                    end
                    if found then
                        eventLockedMobName  = found.Name
                        eventLockedPosition = found.HumanoidRootPart.Position
                        eventLockLostTime   = nil
                        eventNotify("Locked: " .. tostring(found.Name))
                    end
                end
            end
            task.wait(0.1)
        end
        State.eventMagnetActive = false
        cancelTween()
        eventClearPrepare()
        eventThread = nil
        eventNotify("Stopped")
    end)
end

local function stopEventMagnet()
    State.eventMagnetActive = false
    cancelTween()
    clearBringMobs()
    eventClearPrepare()
end

local function startEventClock()
    if eventClockThread then return end
    eventClockThread = task.spawn(function()
        while State.autoEventMagnetEnabled do
            local t = os.date("!*t", os.time() + State.EVENT_TZ_OFFSET * 3600)
            local inWindow = (t.min >= State.EVENT_START_MINUTE and t.min < State.EVENT_END_MINUTE)
            local cycleKey = string.format("%04d-%03d-%02d", t.year, t.yday, t.hour)
            if inWindow then
                if lastEventCycleKey ~= cycleKey then
                    lastEventCycleKey = cycleKey
                    eventLockedMobName  = nil
                    eventLockedPosition = nil
                    eventLockLostTime   = nil
                    eventScanPoints     = {}
                    eventScanIndex      = 1
                    clearBringMobs()
                    eventResetMemory()
                    eventNotify(string.format("Time %02d:%02d - new event round", t.hour, t.min))
                end
                if not State.eventMagnetActive and not eventThread then
                    runEventMagnet()
                end
            elseif State.eventMagnetActive then
                stopEventMagnet()
                eventNotify(string.format("Time %02d:%02d - event window ended", t.hour, t.min))
            end
            task.wait(1)
        end
        eventClockThread = nil
    end)
end

Tabs.Event:AddToggle("AutoEventMagnetToggle", {
    Title = "Auto Event Magnet",
    Default = false,
    Callback = function(value)
        State.autoEventMagnetEnabled = value
        if value then
            startEventClock()
            local t = os.date("!*t", os.time() + State.EVENT_TZ_OFFSET * 3600)
            local inWindow = (t.min >= State.EVENT_START_MINUTE and t.min < State.EVENT_END_MINUTE)
            local cycleKey = string.format("%04d-%03d-%02d", t.year, t.yday, t.hour)
            if inWindow then
                if lastEventCycleKey ~= cycleKey then
                    lastEventCycleKey = cycleKey
                    eventLockedMobName  = nil
                    eventLockedPosition = nil
                    eventLockLostTime   = nil
                    eventScanPoints     = {}
                    eventScanIndex      = 1
                    clearBringMobs()
                    eventResetMemory()
                end
                eventNotify(string.format("Already in event window %02d:%02d - starting now", t.hour, t.min))
                runEventMagnet()
            else
                eventNotify(string.format("Waiting for event window %02d:%02d-%02d:%02d (now %02d:%02d)",
                    t.hour, State.EVENT_START_MINUTE, t.hour, State.EVENT_END_MINUTE, t.hour, t.min))
            end
        else
            stopEventMagnet()
            eventNotify("Scheduler disabled")
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AutoFarmScript")
SaveManager:SetFolder("AutoFarmScript/config")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({ Title = "KKKK New", Content = "KKKK Hub Loaded!", Duration = 5 })
Window:SelectTab(1)
