-- โหลด NothingLibrary
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
local Notification = NothingLibrary.Notification()

-- ===== GLOBAL VARIABLES =====
_G.AutoFarmEnabled = false
_G.QuestModeEnabled = false 
_G.CurrentTween = nil
_G.TargetIsland = nil
_G.ChestBlacklist = {} 
_G.ShardBlacklist = {} 
_G.ChestWaitTime = 0
_G.FarmMode = "random"   

-- Patrol state variables
_G.CurrentPatrolIsland = nil
_G.CurrentPatrolIndex = 1
_G.CurrentPatrolRound = 1

local SPEED = 350 
local THIRSTY_POS = Vector3.new(-1188, 10, 1296)
local MOLTEN_POS = Vector3.new(-5227, 200, -5497)
local FRIENDLY_POS = Vector3.new(-3053, 240, -10144)

local ExcludedMaps = {
    ["FortBuilderPlacedSurfaces"] = true,
    ["FortBuilderPotentialSurfaces"] = true,
    ["Fishmen"] = true,
    ["MiniSky"] = true,
    ["RaidMap"] = true,
    ["WaterBase-Plane"] = true,
    ["IndraIsland"] = true,
    ["EventInstances"] = true,
    ["GhostShipInterior"] = true,
    ["GhostShip"] = true,
}

-- ===== CUSTOM PATROL ROUTES =====
local IslandRoutes = {
    ForgottenIsland = {
        Vector3.new(-2792.612, 6.151, -9489.092),
        Vector3.new(-3319.633, 6.156, -9406.701),
        Vector3.new(-3723.911, 6.156, -9899.021),
        Vector3.new(-4394.900, 122.851, -10715.470),
        Vector3.new(-3951.024, 123.336, -11537.139),
        Vector3.new(-3087.306, 281.155, -10971.061),
        Vector3.new(-2619.042, 317.928, -10402.976),
        Vector3.new(-2512.719, 6.156, -9541.841),
        Vector3.new(-2792.603, 6.153, -9498.146)
    },
    Dressrosa = {
        Vector3.new(-382.166, 73.071, 217.102),
        Vector3.new(-281.807, 73.071, 215.005),
        Vector3.new(-281.125, 73.002, 395.918),
        Vector3.new(-490.960, 73.002, 386.886),
        Vector3.new(-225.164, 370.002, 547.916),
        Vector3.new(-228.155, 370.002, 822.693),
        Vector3.new(-560.809, 370.002, 820.613),
        Vector3.new(-562.119, 370.002, 549.666),
        Vector3.new(-184.705, 73.002, 1608.106),
        Vector3.new(-976.461, 73.051, 1526.228),
        Vector3.new(-1038.249, 73.002, 776.786),
        Vector3.new(-1871.038, 73.002, 448.122),
        Vector3.new(-2230.802, 73.000, -263.154),
        Vector3.new(-1279.016, 73.200, -764.401),
        Vector3.new(-207.002, 73.000, -955.060),
        Vector3.new(867.520, 73.002, -537.579),
        Vector3.new(1290.360, 73.002, 448.933),
        Vector3.new(1294.695, 227.001, 679.579),
        Vector3.new(1313.344, 73.002, 913.958),
        Vector3.new(1120.239, 73.002, 1597.852),
        Vector3.new(638.665, 73.001, 1771.723),
        Vector3.new(43.028, 73.001, 1719.230),
        Vector3.new(8.190, 118.202, 1241.055),
        Vector3.new(-490.229, 118.202, 1244.256)
    },
    GraveIsland = {
        Vector3.new(-5828.728, 48.522, -664.228),
        Vector3.new(-6066.852, 192.232, -1105.444),
        Vector3.new(-5636.473, 179.535, -1354.075),
        Vector3.new(-5181.129, 122.694, -928.748),
        Vector3.new(-5450.169, 48.522, -696.602),
        Vector3.new(-5849.864, 254.658, -415.851)
    },
    CircleIsland = {
        Vector3.new(-6061.861, 80.430, -3842.269),
        Vector3.new(-6505.915, 29.224, -4128.707),
        Vector3.new(-6935.194, 81.363, -4653.365),
        Vector3.new(-6926.797, 81.865, -5253.373),
        Vector3.new(-6797.530, 61.106, -5617.261),
        Vector3.new(-6654.725, 29.224, -6111.343),
        Vector3.new(-6352.736, 85.321, -6204.132),
        Vector3.new(-5870.917, 81.295, -5988.430),
        Vector3.new(-5624.509, 29.209, -5444.182),
        Vector3.new(-5240.445, 175.768, -5395.823),
        Vector3.new(-5347.583, 219.409, -5958.787),
        Vector3.new(-4944.605, 175.768, -6003.676),
        Vector3.new(-4488.611, 175.768, -5613.406),
        Vector3.new(-4541.907, 175.768, -5087.333),
        Vector3.new(-4694.477, 175.768, -4540.690)
    },
    GreenBit = {
        Vector3.new(-2236.883, 73.312, -2654.799),
        Vector3.new(-1724.826, 73.004, -2893.391),
        Vector3.new(-1400.249, 73.008, -3570.906),
        Vector3.new(-1926.891, 72.384, -4440.530),
        Vector3.new(-2666.597, 72.383, -4357.104),
        Vector3.new(-3391.223, 73.009, -3521.937),
        Vector3.new(-3370.572, 73.008, -3000.550),
        Vector3.new(-2855.085, 73.005, -2447.016),
        Vector3.new(-2232.458, 73.312, -2642.876)
    },
    SnowMountain = {
        Vector3.new(-66.768, 8.518, -4954.692),
        Vector3.new(-219.630, 2.465, -5446.675),
        Vector3.new(-8.583, 12.464, -5862.012),
        Vector3.new(356.511, 1.874, -6282.376),
        Vector3.new(829.074, 42.684, -5960.455),
        Vector3.new(1253.673, 52.489, -5812.354),
        Vector3.new(1851.510, 76.472, -5532.257),
        Vector3.new(1798.399, 51.739, -5070.247),
        Vector3.new(1619.942, 45.633, -4480.307),
        Vector3.new(1200.262, 5.410, -4264.189),
        Vector3.new(650.247, 60.252, -4640.002),
        Vector3.new(786.209, 429.464, -4785.480),
        Vector3.new(1281.058, 428.017, -4553.571),
        Vector3.new(1651.708, 429.464, -5374.660),
        Vector3.new(1152.688, 429.464, -5610.507),
        Vector3.new(762.597, 406.029, -5776.699),
        Vector3.new(243.972, 414.211, -5962.319),
        Vector3.new(-39.410, 413.141, -5164.655),
        Vector3.new(424.563, 401.464, -4948.608)
    },
    IceCastle = {
        Vector3.new(5512.187, 28.232, -6120.979),
        Vector3.new(5159.295, 283.606, -6488.404),
        Vector3.new(5656.009, 258.007, -6972.112),
        Vector3.new(6136.604, 294.428, -7393.519),
        Vector3.new(6855.872, 294.428, -7209.615),
        Vector3.new(7069.927, 496.212, -6708.433),
        Vector3.new(6735.651, 294.429, -6422.289),
        Vector3.new(6195.232, 167.238, -6291.690),
        Vector3.new(5853.233, 146.496, -6076.269)
    },
    DarkbeardArena = {
        Vector3.new(4074.911, 13.390, -3800.093),
        Vector3.new(4233.600, 30.160, -3353.118),
        Vector3.new(3962.525, 42.552, -3018.284),
        Vector3.new(3431.821, 13.391, -3244.932),
        Vector3.new(3340.237, 30.324, -3686.796),
        Vector3.new(3597.007, 13.391, -3902.315),
        Vector3.new(3841.871, 32.851, -3933.289)
    }
}

local function getRouteForIsland(islandName)
    if IslandRoutes[islandName] then
        return IslandRoutes[islandName]
    end
    local lowerName = string.lower(islandName)
    for routeName, route in pairs(IslandRoutes) do
        if string.lower(routeName) == lowerName then
            return route
        end
    end
    if string.find(lowerName, "dressrosa") then return IslandRoutes.Dressrosa end
    if string.find(lowerName, "forgotten") then return IslandRoutes.ForgottenIsland end
    if string.find(lowerName, "grave") then return IslandRoutes.GraveIsland end
    return nil
end

local lastNotifiedTarget = nil

-- ===== HELPER FUNCTIONS =====
local function isCharacterAlive()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function getNextIsland()
    local islands = {}
    for _, island in ipairs(workspace.Map:GetChildren()) do
        if island:IsA("Model") and not ExcludedMaps[island.Name] then 
            table.insert(islands, island) 
        end
    end
    if #islands > 0 then
        return islands[math.random(1, #islands)]
    end
    return nil
end

local function clickButton(button)
    if button and button:IsA("GuiButton") and button.Visible then
        local VIM = game:GetService("VirtualInputManager")
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize
        local centerX = pos.X + (size.X / 2)
        local centerY = pos.Y + (size.Y / 2) + 58 
        VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end
end

local function getSpecialEgg()
    local p = game.Players.LocalPlayer
    local c = p.Character
    local eggs = {"Falling Sky Egg", "Thirsty Egg", "Molten Egg", "Friendly Neighborhood Egg", "Firefly Egg"}
    for _, name in ipairs(eggs) do
        local found = p.Backpack:FindFirstChild(name) or (c and c:FindFirstChild(name))
        if found then return found end
    end
    return nil
end

local function hasPriorityTarget()
    for _, v in ipairs(workspace:GetChildren()) do
        if (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then
            return true
        end
    end
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
            return true
        end
    end
    return false
end

-- ===== SAFE GET POSITION (แก้ error nil value) =====
local function getPosition(obj)
    if not obj then return Vector3.new(0, 0, 0) end
    if obj:IsA("Model") then
        return obj:GetPivot().Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    else
        return obj.Position or (obj.GetPivot and obj:GetPivot().Position) or Vector3.new(0, 0, 0)
    end
end

local function moveTo(targetPos, targetInstance, targetType)
    if not targetPos and not targetInstance then return end
    local character = game.Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local old = hrp:FindFirstChild("Lock")
    if old then old:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "Lock"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    while _G.AutoFarmEnabled do
        local hrpNow = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrpNow then break end

        if _G.QuestModeEnabled and getSpecialEgg() and targetType ~= "Quest" then
            break
        end

        if targetInstance then
            if not targetInstance.Parent then break end
            targetPos = getPosition(targetInstance)
        end

        local dist = (hrpNow.Position - targetPos).Magnitude
        if dist < 3 then break end

        bv.Velocity = (targetPos - hrpNow.Position).Unit * SPEED
        task.wait()
    end

    bv.Velocity = Vector3.new(0, 0, 0)
    task.wait(0.05)
    bv:Destroy()
end

-- ===== HOVER MOVEMENT =====
local function hoverMoveTo(targetPos, hoverY, isHovering)
    if not targetPos then return false end
    local character = game.Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local oldBV = hrp:FindFirstChild("HoverBV")
    if oldBV then oldBV:Destroy() end
    local oldBP = hrp:FindFirstChild("HoverBP")
    if oldBP then oldBP:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "HoverBV"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local bp = Instance.new("BodyPosition")
    bp.Name = "HoverBP"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 10000
    bp.Position = Vector3.new(hrp.Position.X, hoverY, hrp.Position.Z)
    bp.Parent = hrp

    local result = false
    while _G.AutoFarmEnabled and isHovering and hrp.Parent do
        local dist = (hrp.Position - targetPos).Magnitude
        if dist < 3 then
            result = true
            break
        end

        local direction = (targetPos - hrp.Position).Unit
        direction = Vector3.new(direction.X, 0, direction.Z)
        bv.Velocity = direction * SPEED
        bp.Position = Vector3.new(hrp.Position.X, hoverY, hrp.Position.Z)

        task.wait()
    end

    bv:Destroy()
    bp:Destroy()
    return result
end

-- ===== FLOAT AND DROP WITH HOVER COLLECTION =====
local function deliverEggWithMove(targetPos, eggInHand, optionButton)
    moveTo(targetPos, nil, "Quest")

    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local hoverY = hrp.Position.Y
    local isHovering = true

    local bv = Instance.new("BodyVelocity")
    bv.Name = "HoverBV"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local bp = Instance.new("BodyPosition")
    bp.Name = "HoverBP"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 10000
    bp.Position = Vector3.new(hrp.Position.X, hoverY, hrp.Position.Z)
    bp.Parent = hrp

    local elapsed = 0
    local timeout = 10
    while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character and elapsed < timeout do
        clickButton(optionButton)
        task.wait(0.2)
        elapsed = elapsed + 0.2
    end

    local waitStart = tick()
    local waitDuration = 10
    local targetSpawned = false
    while _G.AutoFarmEnabled and tick() - waitStart < waitDuration do
        if hasPriorityTarget() then
            targetSpawned = true
            break
        end
        task.wait(0.5)
    end

    if targetSpawned then
        Notification.new({ Title = "Quest", Description = "Target spawned, collecting while hovering!", Duration = 2, Icon = "rbxassetid://8997385628" })

        local function collectWhileHovering()
            local player = game.Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return false end

            -- Shards (เก็บเร็วสุด ไม่มีรอ)
            local closestShard, closestShardDist = nil, math.huge
            for _, v in ipairs(workspace:GetChildren()) do
                if (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then
                    local sPos = getPosition(v)
                    local d = (rootPart.Position - sPos).Magnitude
                    if d < closestShardDist then
                        closestShardDist = d
                        closestShard = v
                    end
                end
            end
            if closestShard then
                local targetPos = getPosition(closestShard)
                notifyOnce(closestShard, "Collect", "Shard")
                local success = hoverMoveTo(targetPos, hoverY, true)
                if success then
                    _G.ShardBlacklist[closestShard] = true
                end
                return true
            end

            -- Eggs
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                    notifyOnce(v, "Collect", "Egg")
                    hoverMoveTo(getPosition(v), hoverY, true)
                    return true
                end
            end

            -- Chests (ไม่มี notify)
            local folder = workspace:FindFirstChild("ChestModels")
            if folder then
                local nearestDist = math.huge
                local chestTarget = nil
                local chestPos = nil
                for _, v in ipairs(folder:GetChildren()) do
                    if not _G.ChestBlacklist[v] then
                        local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                        if p then
                            local d = (rootPart.Position - getPosition(p)).Magnitude
                            if d < nearestDist then
                                nearestDist = d
                                chestTarget = v
                                chestPos = getPosition(p)
                            end
                        end
                    end
                end
                if chestTarget then
                    hoverMoveTo(chestPos, hoverY, true)
                    _G.ChestBlacklist[chestTarget] = true
                    if _G.ChestWaitTime > 0 then task.wait(_G.ChestWaitTime) end
                    return true
                end
            end

            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj.Name == "EasterChest" or obj.Name == "Chest") and not _G.ChestBlacklist[obj] then
                    local p = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                    if p then
                        hoverMoveTo(getPosition(p), hoverY, true)
                        _G.ChestBlacklist[obj] = true
                        if _G.ChestWaitTime > 0 then task.wait(_G.ChestWaitTime) end
                        return true
                    end
                end
            end
            return false
        end

        while collectWhileHovering() do
            task.wait(0.1)
        end
    end

    bv:Destroy()
    bp:Destroy()
end

-- Friendly egg
local function deliverFriendlyEgg(eggInHand)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local npc = workspace.NPCs:FindFirstChild("Forgotten Quest Giver")
    local targetPos = npc and getPosition(npc) or FRIENDLY_POS
    moveTo(targetPos, nil, "Quest")

    hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bp = Instance.new("BodyPosition")
    bp.Name = "QuestFloat"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 10000
    bp.Position = hrp.Position
    bp.Parent = hrp

    if eggInHand.Parent == character then
        game:GetService("ReplicatedStorage").Modules.Net["RF/EasterServiceRF"]:InvokeServer("NPC.TravelingQuest", workspace.NPCs:FindFirstChild("Forgotten Quest Giver"))
    end

    task.wait(5)
    bp:Destroy()
end

-- ===== NOCLIP =====
local NoclipConnection = nil
local Clip = true

local function enableNoclip()
    Clip = false
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if Clip == false then
            local character = game.Players.LocalPlayer.Character
            if character then
                for _, child in pairs(character:GetDescendants()) do
                    if child:IsA("BasePart") then
                        if child.CanCollide == true then child.CanCollide = false end
                        if _G.CurrentTween then child.AssemblyLinearVelocity = Vector3.zero end
                    end
                end
            end
        end
    end)
end

local function disableNoclip()
    Clip = true
    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
end

-- ===== ANTI SIT =====
local AntiSitConnection = nil

local function enableAntiSit()
    if AntiSitConnection then AntiSitConnection:Disconnect() end
    AntiSitConnection = game:GetService("RunService").Stepped:Connect(function()
        local character = game.Players.LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Sit then
            humanoid.Sit = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end
    end)
end

local function disableAntiSit()
    if AntiSitConnection then AntiSitConnection:Disconnect() AntiSitConnection = nil end
end

-- ===== NOTIFY ONCE =====
local function notifyOnce(target, title, description)
    if lastNotifiedTarget ~= target then
        lastNotifiedTarget = target
        Notification.new({ Title = title, Description = description, Duration = 2, Icon = "rbxassetid://8997385628" })
    end
end

-- ===== CHECK HAS TARGET =====
local function hasAnyTarget()
    if _G.QuestModeEnabled and getSpecialEgg() then return false end

    for _, v in ipairs(workspace:GetChildren()) do
        if (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then return true end
    end
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then return true end
    end
    local folder = workspace:FindFirstChild("ChestModels")
    if folder then
        for _, v in ipairs(folder:GetChildren()) do
            if not _G.ChestBlacklist[v] then return true end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj.Name == "EasterChest" or obj.Name == "Chest") and not _G.ChestBlacklist[obj] then return true end
    end
    return false
end

-- ===== COLLECT TARGETS =====
local function collectTargets()
    if not isCharacterAlive() then return false end
    if _G.QuestModeEnabled and getSpecialEgg() then return false end

    local player = game.Players.LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    -- Shards (เร็วสุด ไม่มีรอ)
    local closestShard, closestShardDist = nil, math.huge
    for _, v in ipairs(workspace:GetChildren()) do
        if (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then
            local sPos = getPosition(v)
            local d = (rootPart.Position - sPos).Magnitude
            if d < closestShardDist then
                closestShardDist = d
                closestShard = v
            end
        end
    end
    if closestShard then
        local targetPos = getPosition(closestShard)
        notifyOnce(closestShard, "Collect", "Shard")
        moveTo(targetPos, closestShard, "Shard")
        _G.ShardBlacklist[closestShard] = true
        return true
    end

    -- Eggs
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
            notifyOnce(v, "Collect", "Egg")
            moveTo(getPosition(v), v, "Egg")
            return true 
        end
    end

    -- Chests (ไม่มี notify)
    local folder = workspace:FindFirstChild("ChestModels")
    if folder then
        local nearestDist = math.huge
        local chestTarget = nil
        local chestPos = nil
        for _, v in ipairs(folder:GetChildren()) do
            if not _G.ChestBlacklist[v] then
                local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if p then
                    local d = (rootPart.Position - getPosition(p)).Magnitude
                    if d < nearestDist then
                        nearestDist = d
                        chestTarget = v
                        chestPos = getPosition(p)
                    end
                end
            end
        end
        if chestTarget then
            moveTo(chestPos, chestTarget, "Chest")
            _G.ChestBlacklist[chestTarget] = true
            if _G.ChestWaitTime > 0 then task.wait(_G.ChestWaitTime) end
            return true
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj.Name == "EasterChest" or obj.Name == "Chest") and not _G.ChestBlacklist[obj] then
            local p = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if p then
                moveTo(getPosition(p), obj, "Chest")
                _G.ChestBlacklist[obj] = true
                if _G.ChestWaitTime > 0 then task.wait(_G.ChestWaitTime) end
                return true
            end
        end
    end
    return false
end

-- ===== GENERATE BOUNDING BOX ROUTE =====
local function generateBoundingBoxRoute(island)
    local minX, minZ, maxX, maxZ = math.huge, math.huge, -math.huge, -math.huge
    local avgY = 0
    local count = 0
    for _, part in ipairs(island:GetDescendants()) do
        if part:IsA("BasePart") then
            local p = part.Position
            if p.X < minX then minX = p.X end
            if p.X > maxX then maxX = p.X end
            if p.Z < minZ then minZ = p.Z end
            if p.Z > maxZ then maxZ = p.Z end
            avgY = avgY + p.Y
            count = count + 1
        end
    end
    if count == 0 then return nil end
    avgY = avgY / count
    local offset = 30
    local patrolY = avgY + 80
    local cx, cz = (minX + maxX) / 2, (minZ + maxZ) / 2
    local rx = (maxX - minX) / 2 + offset
    local rz = (maxZ - minZ) / 2 + offset
    return {
        Vector3.new(cx,      patrolY, cz - rz),
        Vector3.new(cx + rx, patrolY, cz - rz),
        Vector3.new(cx + rx, patrolY, cz),
        Vector3.new(cx + rx, patrolY, cz + rz),
        Vector3.new(cx,      patrolY, cz + rz),
        Vector3.new(cx - rx, patrolY, cz + rz),
        Vector3.new(cx - rx, patrolY, cz),
        Vector3.new(cx - rx, patrolY, cz - rz),
    }
end

-- ===== PATROL STEP =====
local function patrolStep(route)
    if not route or #route == 0 then return false end
    if not isCharacterAlive() then return "dead" end

    if _G.CurrentPatrolIndex > #route then
        _G.CurrentPatrolRound = _G.CurrentPatrolRound + 1
        _G.CurrentPatrolIndex = 1
        if _G.CurrentPatrolRound > 2 then 
            return "finished" 
        else
            Notification.new({ 
                Title = "circle", 
                Description = string.format("Starting round %d on %s", _G.CurrentPatrolRound, _G.CurrentPatrolIsland.Name), 
                Duration = 3, 
                Icon = "rbxassetid://8997385628" 
            })
        end
    end

    local waypoint = route[_G.CurrentPatrolIndex]
    if not waypoint then return false end

    Notification.new({ 
        Title = "circle", 
        Description = string.format("Moving to waypoint %d/%d (Round %d) on %s", 
            _G.CurrentPatrolIndex, #route, _G.CurrentPatrolRound, _G.CurrentPatrolIsland.Name), 
        Duration = 2, 
        Icon = "rbxassetid://8997385628" 
    })

    moveTo(waypoint, nil, "Waypoint")
    
    if hasAnyTarget() then 
        return "target_found" 
    end
    
    _G.CurrentPatrolIndex = _G.CurrentPatrolIndex + 1
    return "continue"
end

-- ===== MAIN AUTO-FARM LOOP =====
local function StartFarming()
    task.spawn(function()
        local player = game.Players.LocalPlayer
        task.spawn(function()
            while _G.AutoFarmEnabled do
                task.wait(15)
                _G.ChestBlacklist = {}
                _G.ShardBlacklist = {}
            end
        end)

        while _G.AutoFarmEnabled do
            while not isCharacterAlive() and _G.AutoFarmEnabled do
                lastNotifiedTarget = nil
                task.wait(2)
            end

            local eggInHand = getSpecialEgg()
            if _G.QuestModeEnabled and eggInHand then
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if not rootPart then task.wait(0.5) continue end
                
                local humanoid = character:FindFirstChild("Humanoid")
                if eggInHand.Parent ~= character and humanoid then
                    humanoid:EquipTool(eggInHand)
                    task.wait(0.3)
                end

                local optionButton = player.PlayerGui.Main.Dialogue:FindFirstChild("Option1")

                if eggInHand.Name == "Firefly Egg" or eggInHand.Name == "Friendly Neighborhood Egg" then
                    notifyOnce(eggInHand, "Quest", "Give " .. eggInHand.Name)
                    deliverFriendlyEgg(eggInHand)
                elseif string.find(eggInHand.Name, "Falling") then
                    notifyOnce(eggInHand, "Quest", "Drop " .. eggInHand.Name)
                    deliverEggWithMove(rootPart.Position + Vector3.new(0, 150, 0), eggInHand, optionButton)
                elseif string.find(eggInHand.Name, "Thirsty") then
                    notifyOnce(eggInHand, "Quest", "Drop " .. eggInHand.Name)
                    deliverEggWithMove(THIRSTY_POS, eggInHand, optionButton)
                elseif string.find(eggInHand.Name, "Molten") then
                    notifyOnce(eggInHand, "Quest", "Give " .. eggInHand.Name)
                    deliverEggWithMove(MOLTEN_POS, eggInHand, optionButton)
                else
                    task.wait(1)
                end

                task.wait(1.5)
                _G.CurrentPatrolIsland = nil
                while collectTargets() do task.wait(0.1) end
                continue
            end

            if not _G.CurrentPatrolIsland or not _G.CurrentPatrolIsland.Parent then
                _G.CurrentPatrolIsland = getNextIsland()
                if not _G.CurrentPatrolIsland then task.wait(1) continue end
                _G.CurrentPatrolIndex = 1
                _G.CurrentPatrolRound = 1
                local ok, pivot = pcall(function() return _G.CurrentPatrolIsland:GetPivot().Position end)
                if ok then
                    notifyOnce(_G.CurrentPatrolIsland, "Move", "Going to " .. _G.CurrentPatrolIsland.Name)
                    moveTo(pivot + Vector3.new(0, 80, 0), nil, "Travel")
                end
                Notification.new({ 
                    Title = "circle", 
                    Description = string.format("Starting circle on %s (Round 1)", _G.CurrentPatrolIsland.Name), 
                    Duration = 3, 
                    Icon = "rbxassetid://8997385628" 
                })
            end

            if _G.FarmMode == "random" then
                if hasAnyTarget() then collectTargets() else _G.CurrentPatrolIsland = nil end
                task.wait(0.1)
                continue
            end

            local route = getRouteForIsland(_G.CurrentPatrolIsland.Name)
            if not route or #route == 0 then
                route = generateBoundingBoxRoute(_G.CurrentPatrolIsland)
            end
            if not route or #route == 0 then
                if hasAnyTarget() then collectTargets() else _G.CurrentPatrolIsland = nil end
                task.wait(0.5)
                continue
            end

            local result = patrolStep(route)
            if result == "target_found" then
                while collectTargets() do task.wait(0.05) end
                _G.CurrentPatrolIndex = _G.CurrentPatrolIndex + 1
            elseif result == "finished" then
                _G.CurrentPatrolIsland = nil
                Notification.new({ 
                    Title = "circle", 
                    Description = "No targets found after 2 rounds, moving to next island", 
                    Duration = 3, 
                    Icon = "rbxassetid://8997385628" 
                })
            elseif result == "dead" then
            end
            task.wait(0.1)
        end
    end)
end

-- ===== UI =====
local Windows = NothingLibrary.new({
    Title = "Easter Event Farm",
    Description = "",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

local MainTab = Windows:NewTab({ Title = "Main", Description = "Auto Farm", Icon = "rbxassetid://4483362458" })
local FarmSection = MainTab:NewSection({ Title = "Farming", Icon = "rbxassetid://7743869054", Position = "Left" })

FarmSection:NewDropdown({
    Title = "Farm Mode",
    Data = {"Random", "AroundIsland"},
    Default = "Random",
    Callback = function(Value)
        if Value == "Random" then
            _G.FarmMode = "random"
        else
            _G.FarmMode = "aroundisland"
        end
    end,
})

FarmSection:NewToggle({
    Title = "Enable Auto Farm",
    Default = false,
    Callback = function(Value)
        _G.AutoFarmEnabled = Value
        if Value then 
            StartFarming() 
            enableNoclip() 
            enableAntiSit()
        else 
            if _G.CurrentTween then _G.CurrentTween:Cancel() end 
            lastNotifiedTarget = nil 
            disableNoclip() 
            disableAntiSit() 
        end
    end,
})

FarmSection:NewToggle({ Title = "Enable Quest Delivery", Default = false, Callback = function(Value) _G.QuestModeEnabled = Value lastNotifiedTarget = nil end })

local SettingsTab = Windows:NewTab({ Title = "Settings", Description = "Configuration", Icon = "rbxassetid://7733960981" })
local ConfigSection = SettingsTab:NewSection({ Title = "Configuration", Icon = "rbxassetid://7743869054", Position = "Left" })

ConfigSection:NewSlider({ Title = "Tween Speed", Min = 100, Max = 400, Default = 300, Callback = function(Value) SPEED = Value end })
ConfigSection:NewSlider({ Title = "Chest Wait Time (ms)", Min = 10, Max = 500, Default = 10, Callback = function(Value) _G.ChestWaitTime = Value / 1000 end })
