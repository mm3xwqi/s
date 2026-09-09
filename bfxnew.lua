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
    SPEED                  = 200,
    Y_OFFSET               = 30,
    ATTACK_RATE            = 0.15,
    ATTACK_RANGE           = 60,
    SNAP_RANGE             = 10,
    BRING_DISTANCE         = 250,
    BRING_INTERVAL         = 0.1,
    SPAWN_TELEPORT_INTERVAL = 0.3,
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
    bypassTpEnabled        = false,
    bypassMoving           = false,
    farmBypassEnabled      = true,
    lastFarmBypassStartTime = 0,
    FARM_BYPASS_TIMEOUT     = 8,
    lastTweenStartTime      = 0,
    TWEEN_TIMEOUT           = 10,
}

local bypassTpArrived = false
local bypassActive    = false
local farmBypassActive   = false
local entranceCooldownTick = 0
local ENTRANCE_TWEEN_LOCKOUT = 0.3
local lastEntrancePos = nil
State.autoEquipEnabled  = true
State.selectedWeaponType = "Melee"
State.lastEquippedTool   = nil
local lastFarmBypassTick = 0
local BYPASS_CD_ENTRANCE = 4
local BYPASS_CD_SPAWN    = 3
local FARM_NEAR_DISTANCE = 2000

local activeBringBodies  = {}
local originalMobStates  = {}
local originalCanCollide = {}

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
    local function CheckItem(name)
        for _, v in next, player.Backpack:GetChildren() do
            if v:IsA("Tool") and (v.Name == name or string.find(v.Name, name)) then return v end
        end
        if player.Character then
            for _, v in next, player.Character:GetChildren() do
                if v:IsA("Tool") and (v.Name == name or string.find(v.Name, name)) then return v end
            end
        end
    end
    return CheckItem("God's Chalice") or CheckItem("Fist of Darkness")
        or CheckItem("Sweet Chalice") or CheckItem("Hallow Essence") or CheckItem("Flower1")
end

local function WaitForHumanoid()
    local c = player.Character
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

local function CanBypassTeleport(x)
    if not x then return false end
    local targetCF = Convert_CFrame(x)
    if not targetCF then return false end
    local char = player.Character
    if not char then return false end
    local hrpCheck = char:FindFirstChild("HumanoidRootPart")
    if not hrpCheck then return false end
    local humCheck = char:FindFirstChildOfClass("Humanoid")
    if not humCheck or not humCheck.Health or humCheck.Health <= 0 then return false end
    local AreaName = InArea(targetCF).Name
    if AreaName:find("Dimension") or AreaName:find("Submerged") or AreaName == "Sealed Cavern"
        or CheckLegendaryItems() then return false end
    local data = player:FindFirstChild("Data")
    local lastSpawn = data and data:FindFirstChild("LastSpawnPoint")
    if lastSpawn and lastSpawn:IsA("StringValue") and lastSpawn.Value == "SubmergedIsland" then return false end
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
    local charHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
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

local function getEntranceForTarget(targetPos)
    if not targetPos then return nil end
    local charHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local playerPos = charHRP and charHRP.Position or Vector3.zero

    if sea1 then
        if playerPos.X > 50000 and targetPos.X < 50000 then
            return { entrance = Vector3.new(3864.69, 6.74, -1926.21), dest = Vector3.new(3874, 5, -1904), name = "Whirlpool" }
        end
        if targetPos.X > 50000 then
            return { entrance = Vector3.new(61163.85, 11.68, 1819.78), dest = Vector3.new(61170, 6, 1824), name = "Underwater" }
        end
        local function flatDistance(a, b)
            return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
        end
        local SKY1_DEST = Vector3.new(-4831, 776, -2602)
        local SKY2_DEST = Vector3.new(-7922, 5566, -378)
        local SKY3_DEST = Vector3.new(-7987, 5756, -1925)
        if flatDistance(targetPos, SKY1_DEST) <= 1800 then
            return { entrance = Vector3.new(-4700.82, 874.39, -1700.56), dest = SKY1_DEST, name = "Sky1" }
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

local function getAllEntrances()
    if sea1 then
        return {
            { pos = Vector3.new(3864.69, 6.74, -1926.21),   name = "Whirlpool" },
            { pos = Vector3.new(-4700.82, 874.39, -1700.56), name = "Sky1" },
            { pos = Vector3.new(-7894.62, 5547.14, -380.29), name = "Sky2" },
            { pos = Vector3.new(61163.85, 11.68, 1819.78),   name = "Underwater" },
        }
    elseif sea2 then
        return {
            { pos = Vector3.new(2284.91, 15.54, 905.46),     name = "Dock" },
            { pos = Vector3.new(-286.99, 350.14, 597.90),    name = "Cafe" },
            { pos = Vector3.new(-6508.56, 89.04, -132.84),   name = "CursedShip" },
            { pos = Vector3.new(923.21, 126.98, 32852.83),   name = "Far" },
        }
    elseif sea3 then
        return {
            { pos = Vector3.new(-12463.60, 378.33, -7533.08), name = "Mansion" },
            { pos = Vector3.new(-5060.41, 318.50, -3160.22),  name = "Castle" },
            { pos = Vector3.new(5650.95, 1017.27, -300.38),   name = "Hydra" },
        }
    end
    return {}
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

local function tryFarmBypass(targetPos)
    if not State.farmBypassEnabled then return false end
    if not targetPos then return false end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local targetCF = Convert_CFrame(targetPos)
    if not targetCF then return false end
    local currentDist = (hrp.Position - targetCF.Position).Magnitude

    if currentDist <= FARM_NEAR_DISTANCE then return false end
    if farmBypassActive then return true end

    local now = tick()
    if now - entranceCooldownTick < ENTRANCE_TWEEN_LOCKOUT then return true end

    local entranceInfo = getEntranceForTarget(targetCF.Position)
    if entranceInfo then
        local distPlayerToEntrance = (hrp.Position - entranceInfo.entrance).Magnitude
        local distEntranceToTarget = (entranceInfo.entrance - targetCF.Position).Magnitude

        if currentDist > 4000
            and distPlayerToEntrance > 500
            and distEntranceToTarget < currentDist - 500 then
            if now - lastFarmBypassTick < BYPASS_CD_ENTRANCE then return true end
            lastFarmBypassTick            = now
            entranceCooldownTick          = now
            lastEntrancePos               = entranceInfo.entrance
            farmBypassActive              = true
            State.lastFarmBypassStartTime = tick()
            task.spawn(function()
                cancelTween()
                State.tweenTargetPosition = nil
                pcall(function()
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                task.wait(0.1)
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", entranceInfo.entrance)
                end)
                State.idleAnchorCFrame     = nil
                State.tweenTargetPosition  = nil
                local nc  = player.Character
                local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
                if nhr then State.currentFlyCF = nhr.CFrame end
                State.lastFarmBypassEndTime = tick()
                farmBypassActive = false
            end)
            return true
        end
        return false
    end

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
                bestDist = dToTarget; bestSpawn = v
            end
        end
    end
    if not bestSpawn then return false end
    if now - lastFarmBypassTick < BYPASS_CD_SPAWN then return true end
    lastFarmBypassTick            = now
    farmBypassActive              = true
    State.lastFarmBypassStartTime = tick()
    task.spawn(function()
        local curChar = player.Character
        local curHrp  = curChar and curChar:FindFirstChild("HumanoidRootPart")
        local curHum  = curChar and curChar:FindFirstChildOfClass("Humanoid")
        if not curHrp or not curHum or curHum.Health <= 0 then farmBypassActive = false; return end
        cancelTween()
        State.tweenTargetPosition = nil
        pcall(function()
            local h = curChar:FindFirstChildOfClass("Humanoid")
            if not h then return end
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetLastSpawnPoint", bestSpawn.Name)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
            curChar:PivotTo(bestSpawn.Part.CFrame)
            h:ChangeState(15)
        end)
        task.wait(0.5)
        local nc, nhr = waitForAlive(12)
        if nhr then
            task.wait(0.2)
            State.currentFlyCF = nhr.CFrame
        end
        State.idleAnchorCFrame      = nil
        State.lastFarmBypassEndTime = tick()
        farmBypassActive = false
    end)
    return true
end

local Conns = { tweenIsland = nil, bypassTp = nil }

local function stopTweenIsland()
    State.teleportTweenEnabled = false
    if Conns.tweenIsland then Conns.tweenIsland:Disconnect(); Conns.tweenIsland = nil end
end

local function startTweenIsland()
    stopTweenIsland()
    if not State.selectedIslandPos then return end
    State.teleportTweenEnabled = true

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then State.currentFlyCF = hrp.CFrame end

    task.spawn(function()
        local targetPos   = State.selectedIslandPos
        local usedEntrances = {}

        local function getBestEntrance()
            local hrpNow = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrpNow then return nil end
            local playerPos    = hrpNow.Position
            local distToTarget = (playerPos - targetPos).Magnitude
            if distToTarget <= 1000 then return nil end
            local best, bestScore = nil, math.huge
            for _, e in ipairs(getAllEntrances()) do
                if usedEntrances[e.name] then continue end
                local dEntranceToTarget = (e.pos - targetPos).Magnitude
                if dEntranceToTarget < distToTarget - 200 then
                    if dEntranceToTarget < bestScore then
                        bestScore = dEntranceToTarget; best = e
                    end
                end
            end
            return best
        end

        for _ = 1, 5 do
            if not State.teleportTweenEnabled then return end
            local entrance = getBestEntrance()
            if not entrance then break end
            Fluent:Notify({ Title = "Island", Content = "Entrance: " .. entrance.name, Duration = 2 })
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", entrance.pos)
            end)
            usedEntrances[entrance.name] = true
            local nc  = player.Character
            local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
            if nhr then State.currentFlyCF = nhr.CFrame end
        end

        local nc  = player.Character
        local nhr = nc and nc:FindFirstChild("HumanoidRootPart")
        if nhr then State.currentFlyCF = nhr.CFrame end
    end)

    Conns.tweenIsland = RunService.Heartbeat:Connect(function(dt)
        if not State.teleportTweenEnabled then stopTweenIsland(); return end
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        local targetPos  = State.selectedIslandPos
        local targetCF   = CFrame.new(targetPos)
        local currentPos = State.currentFlyCF and State.currentFlyCF.Position or hrp.Position
        local dist       = (targetPos - currentPos).Magnitude

        if dist > 6 then
            moveToTarget(hrp, targetCF, dt)
        else
            State.currentFlyCF = targetCF
            pcall(function()
                hrp.CFrame = targetCF
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            stopTweenIsland()
            Fluent:Notify({ Title = "Island", Content = "arrived " .. (State.selectedIslandName or ""), Duration = 3 })
        end
    end)
end

local function stopBypassTp()
    State.bypassTpEnabled = false
    State.bypassMoving    = false
    bypassActive          = false
    if Conns.bypassTp then Conns.bypassTp:Disconnect(); Conns.bypassTp = nil end
    pcall(function()
        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.AutoRotate    = true
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
            Fluent:Notify({ Title = "Bypass TP", Content = "Entrance: " .. entranceInfo.name, Duration = 2 })
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", entranceInfo.entrance)
            end)
            local afterHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if afterHrp then
                State.currentFlyCF     = afterHrp.CFrame
                State.idleAnchorCFrame = nil
            end
        end

        if not State.bypassTpEnabled then State.bypassMoving = false; bypassActive = false; return end

        local hopCount = 0
        local maxHops  = 10
        while hopCount < maxHops and State.bypassTpEnabled do
            local char, hrp, hum = waitForAlive(12)
            if not char then break end
            if not State.bypassTpEnabled then break end

            local dist = (hrp.Position - targetPos).Magnitude
            if dist <= 1200 then break end

            local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
            local Pirates = WorldOrigin
                and WorldOrigin:FindFirstChild("PlayerSpawns")
                and WorldOrigin.PlayerSpawns:FindFirstChild("Pirates")
            if not Pirates then break end

            local playerPos = hrp.Position
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
                    if dot > bestDot then bestDot = dot; best = v end
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
            local nc, nhr = waitForAlive(12)
            if nhr then
                task.wait(0.2)
                State.currentFlyCF = nhr.CFrame
            end
        end

        if not State.bypassTpEnabled then State.bypassMoving = false; bypassActive = false; return end

        local nc  = player.Character
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

        Conns.bypassTp = RunService.Heartbeat:Connect(function(dt)
            if not State.bypassTpEnabled then stopBypassTp(); return end
            local char = player.Character
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
                stopBypassTp()
                Fluent:Notify({ Title = "Bypass TP", Content = "Arrived at " .. tostring(State.selectedIslandName), Duration = 3 })
                task.delay(2, function() bypassTpArrived = false; bypassActive = false end)
            end
        end)
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

-- Detect boss tags from a raw string
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

-- Boss info is collected from the ONLY two valid sources
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
        or mobRawName:find(wanted, 1, true) ~= nil
        or mobBaseName:find(wanted, 1, true) ~= nil
        or wanted:find(mobBaseName, 1, true) ~= nil
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

local function getSpawnPositionsForMob(wantedName)
    if not wantedName or wantedName == "" then return {} end
    local positions = {}
    for _, entry in ipairs(getSpawnFolders()) do
        for _, obj in ipairs(entry.folder:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                if normalizeMobName(obj.Name) == wantedName then
                    local pos
                    if obj:IsA("Model") then
                        local r = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                        if r then pos = r.Position end
                    else
                        pos = obj.Position
                    end
                    if pos then table.insert(positions, pos) end
                end
            end
        end
    end
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
pcall(function()
    local Modules = ReplicatedStorage:WaitForChild("Modules")
    local Net     = Modules:WaitForChild("Net")
    RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
    RegisterHit    = Net:FindFirstChild("RE/RegisterHit")
end)

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
    if not State.autoFarmEnabled and not State.autoFarmSelectEnabled then return end
    local char = player.Character
    if not char then return end
    autoEquipWeapon()
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local targets = FastAttackModule.GetAllTargets(char)
    if #targets < 1 then return end
    local targetParts = FastAttackModule.GetTargetParts(targets)
    if #targetParts < 1 then return end

    if RegisterAttack and RegisterHit then
        RegisterAttack:FireServer(FastAttackModule.Rate)
        local targetHead = targetParts[1][2]
        if targetHead then RegisterHit:FireServer(targetHead, targetParts) end
    end

    if Refs2.AttackRemoteTarget and Refs2.AttackRemoteId then
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
            local finalId = bit32.bxor(Refs2.AttackRemoteId + 909090, seed * 2)
            local cloneref2 = cloneref or function(o) return o end
            local targetHead = targetParts[1][2]
            if targetHead then
                cloneref2(Refs2.AttackRemoteTarget):FireServer(encodedString, finalId, targetHead, targetParts)
            end
        end)
    end
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

local function clearBringMobs()
    for mob in pairs(activeBringBodies) do
        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        if mobRoot then
            local bp = mobRoot:FindFirstChild("BringBodyPos")
            if bp then bp:Destroy() end
        end
        activeBringBodies[mob] = nil
    end
    for mob, state in pairs(originalMobStates) do
        restoreMobState(mob, state)
        originalMobStates[mob] = nil
    end
    State.bringAnchor        = nil
    State.lastBringUpdate    = 0
    State.targetAnchorCFrame = nil
end

local function updateBringMobs(target, now)
    if not State.bringMobEnabled or (not State.autoFarmEnabled and not State.autoFarmSelectEnabled) then
        clearBringMobs(); return
    end
    if not isEnemyAlive(target) then clearBringMobs(); return end
    if State.bringAnchor ~= target then
        clearBringMobs()
        State.bringAnchor = target
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            State.targetAnchorCFrame = targetRoot.CFrame
        end
    end
    if now - State.lastBringUpdate < State.BRING_INTERVAL then return end
    State.lastBringUpdate = now

    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then clearBringMobs(); return end

    if State.targetAnchorCFrame
        and (targetRoot.Position - State.targetAnchorCFrame.Position).Magnitude > 150 then
        State.targetAnchorCFrame = targetRoot.CFrame
    end

    if State.targetAnchorCFrame then
        local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then
            if not originalMobStates[target] then
                local state = { parts = {}, humanoid = targetHumanoid,
                    walkSpeed = targetHumanoid.WalkSpeed, jumpPower = targetHumanoid.JumpPower, jumpHeight = targetHumanoid.JumpHeight }
                for _, part in ipairs(target:GetDescendants()) do
                    if part:IsA("BasePart") then state.parts[part] = part.CanCollide; part.CanCollide = false end
                end
                originalMobStates[target] = state
            else
                for part in pairs(originalMobStates[target].parts) do
                    if part and part.Parent then part.CanCollide = false end
                end
            end
            targetHumanoid.WalkSpeed = 0; targetHumanoid.JumpPower = 0; targetHumanoid.JumpHeight = 0
        end
        local staleBP = targetRoot:FindFirstChild("BringBodyPos")
        if staleBP then staleBP:Destroy() end
        activeBringBodies[target] = nil
        target:PivotTo(State.targetAnchorCFrame)
        targetRoot.AssemblyLinearVelocity  = Vector3.zero
        targetRoot.AssemblyAngularVelocity = Vector3.zero
    end

    local pullPosition = State.targetAnchorCFrame and State.targetAnchorCFrame.Position or targetRoot.Position
    local seenMobs     = {}
    local validMobs    = {}

    for _, mob in ipairs(enemiesFolder:GetChildren()) do
        if mob ~= target and isEnemyAlive(mob) then
            local mobRoot     = mob:FindFirstChild("HumanoidRootPart")
            local mobHumanoid = mob:FindFirstChildOfClass("Humanoid")
            local distance    = mobRoot and (mobRoot.Position - pullPosition).Magnitude
            local rawMobName  = getMobDisplayName(mob)
            local isBoss      = rawMobName:find("%[Boss%]") or rawMobName:find("%[Raid Boss%]")
            if mobRoot and mobHumanoid and mobHumanoid.Health > 0
                and sameMobType(mob, target) and not isBoss
                and distance <= State.BRING_DISTANCE then
                table.insert(validMobs, { mob = mob, root = mobRoot, humanoid = mobHumanoid, distance = distance })
            end
        end
    end

    table.sort(validMobs, function(a, b) return a.distance < b.distance end)

    local bringCount = math.max(0, math.floor(tonumber(State.BRING_MOB_COUNT) or 0))
    for index = 1, math.min(bringCount, #validMobs) do
        local data        = validMobs[index]
        local mob         = data.mob
        local mobRoot     = data.root
        local mobHumanoid = data.humanoid
        seenMobs[mob]     = true

        if not originalMobStates[mob] then
            local state = { parts = {}, humanoid = mobHumanoid,
                walkSpeed = mobHumanoid.WalkSpeed, jumpPower = mobHumanoid.JumpPower, jumpHeight = mobHumanoid.JumpHeight }
            for _, part in ipairs(mob:GetDescendants()) do
                if part:IsA("BasePart") then state.parts[part] = part.CanCollide; part.CanCollide = false end
            end
            originalMobStates[mob] = state
        else
            for part in pairs(originalMobStates[mob].parts) do
                if part and part.Parent then part.CanCollide = false end
            end
        end

        mobHumanoid.WalkSpeed = 0; mobHumanoid.JumpPower = 0; mobHumanoid.JumpHeight = 0

        pcall(function()
            for _, part in ipairs(mob:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() sethiddenproperty(part, "NetworkOwnershipRule", 0) end)
                end
            end
            pcall(function() sethiddenproperty(mobRoot, "NetworkOwnershipRule", 0) end)
        end)

        local angle   = (index - 1) * (math.pi * 2 / math.max(1, math.min(bringCount, #validMobs)))
        local destPos = pullPosition + Vector3.new(math.cos(angle) * 3, 0, math.sin(angle) * 3)

        local oldBP = mobRoot:FindFirstChild("BringBodyPos")
        if oldBP then oldBP:Destroy() end
        activeBringBodies[mob] = nil

        mobRoot.CFrame = CFrame.new(destPos)
        mobRoot.AssemblyLinearVelocity  = Vector3.zero
        mobRoot.AssemblyAngularVelocity = Vector3.zero

    end

    for mob in pairs(activeBringBodies) do
        if not seenMobs[mob] then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            if mobRoot then
                local bp = mobRoot:FindFirstChild("BringBodyPos")
                if bp then bp:Destroy() end
            end
            activeBringBodies[mob] = nil
        end
    end
    for mob, state in pairs(originalMobStates) do
        if not seenMobs[mob] and mob ~= target then
            restoreMobState(mob, state)
            originalMobStates[mob] = nil
        end
    end
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
        if tweenPlaying or not farmBypassActive then
            root.AssemblyLinearVelocity  = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end

        local nowTick = tick()

        if State.isLocked then
            State.lastMovePosition = root.Position
            State.lastMoveTime     = nowTick
        elseif not farmBypassActive then
            if not State.lastMovePosition
                or (root.Position - State.lastMovePosition).Magnitude > 5 then
                State.lastMovePosition = root.Position
                State.lastMoveTime     = nowTick
            elseif nowTick - State.lastMoveTime > 2.5 then
                State.lastMovePosition = root.Position
                State.lastMoveTime     = nowTick
                farmBypassActive       = false
                cancelTween()
                State.currentTarget    = nil
                State.isMovingToSpawn  = false
            end
        end

        if farmBypassActive and nowTick - State.lastFarmBypassStartTime > State.FARM_BYPASS_TIMEOUT then
            farmBypassActive      = false
            cancelTween()
            State.currentTarget   = nil
            State.isMovingToSpawn = false
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
                else
                    if not State.activeTween or State.activeTween.PlaybackState ~= Enum.PlaybackState.Playing then
                        State.isMovingToSpawn = false
                        local newTarget2, _ = getHighestPriorityAliveEnemy(root.Position)
                        if not newTarget2 and State.autoFarmEnabled then
                            newTarget2 = getClosestAliveEnemyNears(root.Position)
                        end
                        if newTarget2 then
                            State.currentTarget        = newTarget2
                            State.lastTargetSwitchTime = tick()
                            cancelTween()
                            return
                        end
                        if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 and #State.spawnPointList > 0 then
                            State.spawnPointIndex = (State.spawnPointIndex % #State.spawnPointList) + 1
                            local spawnPos = State.spawnPointList[State.spawnPointIndex]
                            local dist     = (spawnPos - root.Position).Magnitude
                            cancelTween()
                            State.activeTween = TweenService:Create(root,
                                TweenInfo.new(math.max(dist / math.max(State.SPEED, 1), 0.05), Enum.EasingStyle.Linear),
                                { CFrame = CFrame.new(spawnPos + Vector3.new(0, 5, 0)) })
                            State.tweenTargetPosition = spawnPos
                            State.activeTween:Play()
                            State.lastTweenStartTime = tick()
                            State.isMovingToSpawn    = true
                        end
                    end
                    return
                end
            end

            if not State.currentTarget then
                if farmBypassActive then State.idleAnchorCFrame = nil; return end
                if tick() - (State.lastFarmBypassEndTime or 0) < 1.5 then
                    State.idleAnchorCFrame = root.CFrame
                end
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

                if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
                    local now = tick()
                    if now - State.lastSpawnTeleportTime >= 0.05 then
                        State.lastSpawnTeleportTime = now
                        local targetMobName = State.selectedMobNames[1]
                        for _, wn in ipairs(State.selectedMobNames) do
                            if not mobTypeExistsInFolder(wn) then
                                targetMobName = wn; break
                            elseif getClosestAliveEnemy(root.Position, wn) then
                                targetMobName = wn; break
                            end
                        end
                        if #State.spawnPointList == 0 then
                            State.spawnPointList  = getSpawnPositionsForMob(targetMobName)
                            State.spawnPointIndex = 1
                        end
                        if #State.spawnPointList > 0 then
                            local spawnPos = State.spawnPointList[State.spawnPointIndex]
                            local spawnTweenPlaying = State.activeTween
                                and State.activeTween.PlaybackState == Enum.PlaybackState.Playing
                            if not spawnTweenPlaying then
                                tryFarmBypass(spawnPos)
                            end
                            if not farmBypassActive then
                                local dist = (spawnPos - root.Position).Magnitude
                                cancelTween()
                                State.activeTween = TweenService:Create(root,
                                    TweenInfo.new(math.max(dist / math.max(State.SPEED, 1), 0.05), Enum.EasingStyle.Linear),
                                    { CFrame = CFrame.new(spawnPos + Vector3.new(0, 5, 0)) })
                                State.tweenTargetPosition = spawnPos
                                State.activeTween:Play()
                                State.lastTweenStartTime = tick()
                                State.isMovingToSpawn    = true
                                State.idleAnchorCFrame   = nil
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
                local currentTweenPlaying = State.activeTween
                    and State.activeTween.PlaybackState == Enum.PlaybackState.Playing
                if not currentTweenPlaying then
                    tryFarmBypass(targetPosition)
                end
                if farmBypassActive then return end
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
    if not State.bypassTpEnabled then
        bypassTpArrived = false
        bypassActive    = false
    end
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

-- Main Tab UI

local rawMobNames   = getAvailableMobNames()
local mobLabelList  = {}
for _, rawName in ipairs(rawMobNames) do
    table.insert(mobLabelList, makeMobLabel(rawName))
end

if #mobLabelList == 0 then
    table.insert(mobLabelList, "No mob spawn found")
    table.insert(rawMobNames,  "No mob spawn found")
end

State.selectedMobNames = { rawMobNames[1]}
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
            Fluent:Notify({ Title = "Refresh", Content = "ไม่พบมอบ", Duration = 2 })
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
            Fluent:Notify({ Title = "Auto Farm", Content = "Enabled — attacking nearest enemy", Duration = 2 })
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

-- Island Tab UI
Tabs.Island:AddParagraph({ Title = worldName, Content = "Select island first Enable Toggle" })

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
    Title = "Tween to Island",
    Default = false,
    Callback = function(value)
        State.teleportTweenEnabled = value
        if value then
            if not State.selectedIslandPos then
                Fluent:Notify({ Title = "Island", Content = "Select island first", Duration = 2 })
                return
            end
            if State.bypassTpEnabled then stopBypassTp() end
            Fluent:Notify({ Title = "Island", Content = "Tween Going " .. (State.selectedIslandName or ""), Duration = 2 })
            startTweenIsland()
        else
            stopTweenIsland()
            Fluent:Notify({ Title = "Island", Content = "Disable Tween", Duration = 2 })
        end
    end
})

Tabs.Island:AddToggle("BypassIslandToggle", {
    Title = "Bypass Teleport",
    Default = false,
    Callback = function(value)
        if bypassTpArrived then return end
        State.bypassTpEnabled = value
        if value then
            if not State.selectedIslandPos then
                Fluent:Notify({ Title = "Island", Content = "Select island first", Duration = 2 })
                return
            end
            if State.teleportTweenEnabled then stopTweenIsland() end
            Fluent:Notify({ Title = "Bypass TP", Content = "Doing Bypass " .. (State.selectedIslandName or ""), Duration = 2 })
            startBypassTp()
        else
            stopBypassTp()
            Fluent:Notify({ Title = "Bypass TP", Content = "Disabled", Duration = 2 })
        end
    end
})

-- Farm Setting Tab UI
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
    Title = "Y Offset", Default = State.Y_OFFSET, Min = 0, Max = 60, Rounding = 0,
    Callback = function(value) State.Y_OFFSET = value end
})

Tabs.FarmSetting:AddSlider("AttackRateSlider", {
    Title = "Attack Rate", Default = State.ATTACK_RATE, Min = 0.05, Max = 1.0, Rounding = 2,
    Callback = function(value) State.ATTACK_RATE = value; FastAttackModule.Rate = value end
})

Tabs.FarmSetting:AddSlider("AttackRangeSlider", {
    Title = "Attack Range", Default = State.ATTACK_RANGE, Min = 10, Max = 150, Rounding = 0,
    Callback = function(value) State.ATTACK_RANGE = value end
})

Tabs.FarmSetting:AddToggle("FarmBypassToggle", {
    Title = "Bypass Teleport (Farm)",
    Default = State.farmBypassEnabled,
    Callback = function(value)
        State.farmBypassEnabled = value
        Fluent:Notify({
            Title   = "Farm Bypass",
            Content = value and "Enabled - use Bypass while farming" or "Disabled - direct Tween while farming",
            Duration = 2
        })
    end
})

-- Settings Tab
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
