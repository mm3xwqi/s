local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
local Notification = NothingLibrary.Notification()

-- ===== GLOBAL VARIABLES =====
_G.AutoFarmEnabled = false
_G.QuestModeEnabled = false 
_G.AutoJumpEnabled = true
_G.CurrentTween = nil
_G.TargetIsland = nil
_G.ChestBlacklist = {} 
_G.ShardBlacklist = {} 
_G.FruitBlacklist = {}
_G.ChestWaitTime = 0
_G.FarmMode = "random"   

-- Circle state variables
_G.CurrentCircleIsland = nil
_G.CurrentCircleIndex = 1
_G.CurrentCircleRound = 1

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
    ["Group"] = true,
}

-- ===== CUSTOM ROUTES =====
local IslandRoutes = {
    ForgottenIsland = {Vector3.new(-2792.612, 6.151, -9489.092), Vector3.new(-3319.633, 6.156, -9406.701), Vector3.new(-3723.911, 6.156, -9899.021), Vector3.new(-4394.900, 122.851, -10715.470), Vector3.new(-3951.024, 123.336, -11537.139), Vector3.new(-3087.306, 281.155, -10971.061), Vector3.new(-2619.042, 317.928, -10402.976), Vector3.new(-2512.719, 6.156, -9541.841), Vector3.new(-2792.603, 6.153, -9498.146)},
    Dressrosa = {Vector3.new(-382.166, 73.071, 217.102), Vector3.new(-281.807, 73.071, 215.005), Vector3.new(-281.125, 73.002, 395.918), Vector3.new(-490.960, 73.002, 386.886), Vector3.new(-225.164, 370.002, 547.916), Vector3.new(-228.155, 370.002, 822.693), Vector3.new(-560.809, 370.002, 820.613), Vector3.new(-562.119, 370.002, 549.666), Vector3.new(-184.705, 73.002, 1608.106), Vector3.new(-976.461, 73.051, 1526.228), Vector3.new(-1038.249, 73.002, 776.786), Vector3.new(-1871.038, 73.002, 448.122), Vector3.new(-2230.802, 73.000, -263.154), Vector3.new(-1279.016, 73.200, -764.401), Vector3.new(-207.002, 73.000, -955.060), Vector3.new(867.520, 73.002, -537.579), Vector3.new(1290.360, 73.002, 448.933), Vector3.new(1294.695, 227.001, 679.579), Vector3.new(1313.344, 73.002, 913.958), Vector3.new(1120.239, 73.002, 1597.852), Vector3.new(638.665, 73.001, 1771.723), Vector3.new(43.028, 73.001, 1719.230), Vector3.new(8.190, 118.202, 1241.055), Vector3.new(-490.229, 118.202, 1244.256)},
    GraveIsland = {Vector3.new(-5828.728, 48.522, -664.228), Vector3.new(-6066.852, 192.232, -1105.444), Vector3.new(-5636.473, 179.535, -1354.075), Vector3.new(-5181.129, 122.694, -928.748), Vector3.new(-5450.169, 48.522, -696.602), Vector3.new(-5849.864, 254.658, -415.851)},
    CircleIsland = {Vector3.new(-6061.861, 80.430, -3842.269), Vector3.new(-6505.915, 29.224, -4128.707), Vector3.new(-6935.194, 81.363, -4653.365), Vector3.new(-6926.797, 81.865, -5253.373), Vector3.new(-6797.530, 61.106, -5617.261), Vector3.new(-6654.725, 29.224, -6111.343), Vector3.new(-6352.736, 85.321, -6204.132), Vector3.new(-5870.917, 81.295, -5988.430), Vector3.new(-5624.509, 29.209, -5444.182), Vector3.new(-5240.445, 175.768, -5395.823), Vector3.new(-5347.583, 219.409, -5958.787), Vector3.new(-4944.605, 175.768, -6003.676), Vector3.new(-4488.611, 175.768, -5613.406), Vector3.new(-4541.907, 175.768, -5087.333), Vector3.new(-4694.477, 175.768, -4540.690)},
    GreenBit = {Vector3.new(-2236.883, 73.312, -2654.799), Vector3.new(-1724.826, 73.004, -2893.391), Vector3.new(-1400.249, 73.008, -3570.906), Vector3.new(-1926.891, 72.384, -4440.530), Vector3.new(-2666.597, 72.383, -4357.104), Vector3.new(-3391.223, 73.009, -3521.937), Vector3.new(-3370.572, 73.008, -3000.550), Vector3.new(-2855.085, 73.005, -2447.016), Vector3.new(-2232.458, 73.312, -2642.876)},
    SnowMountain = {Vector3.new(-66.768, 8.518, -4954.692), Vector3.new(-219.630, 2.465, -5446.675), Vector3.new(-8.583, 12.464, -5862.012), Vector3.new(356.511, 1.874, -6282.376), Vector3.new(829.074, 42.684, -5960.455), Vector3.new(1253.673, 52.489, -5812.354), Vector3.new(1851.510, 76.472, -5532.257), Vector3.new(1798.399, 51.739, -5070.247), Vector3.new(1619.942, 45.633, -4480.307), Vector3.new(1200.262, 5.410, -4264.189), Vector3.new(650.247, 60.252, -4640.002), Vector3.new(786.209, 429.464, -4785.480), Vector3.new(1281.058, 428.017, -4553.571), Vector3.new(1651.708, 429.464, -5374.660), Vector3.new(1152.688, 429.464, -5610.507), Vector3.new(762.597, 406.029, -5776.699), Vector3.new(243.972, 414.211, -5962.319), Vector3.new(-39.410, 413.141, -5164.655), Vector3.new(424.563, 401.464, -4948.608)},
    IceCastle = {Vector3.new(5512.187, 28.232, -6120.979), Vector3.new(5159.295, 283.606, -6488.404), Vector3.new(5656.009, 258.007, -6972.112), Vector3.new(6136.604, 294.428, -7393.519), Vector3.new(6855.872, 294.428, -7209.615), Vector3.new(7069.927, 496.212, -6708.433), Vector3.new(6735.651, 294.429, -6422.289), Vector3.new(6195.232, 167.238, -6291.690), Vector3.new(5853.233, 146.496, -6076.269)},
    DarkbeardArena = {Vector3.new(4074.911, 13.390, -3800.093), Vector3.new(4233.600, 30.160, -3353.118), Vector3.new(3962.525, 42.552, -3018.284), Vector3.new(3431.821, 13.391, -3244.932), Vector3.new(3340.237, 30.324, -3686.796), Vector3.new(3597.007, 13.391, -3902.315), Vector3.new(3841.871, 32.851, -3933.289)}
}

local function getRouteForIsland(islandName)
    if IslandRoutes[islandName] then return IslandRoutes[islandName] end
    local lowerName = string.lower(islandName)
    for routeName, route in pairs(IslandRoutes) do
        if string.lower(routeName) == lowerName then return route end
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
        if v.Parent and (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then return true end
    end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then return true end
    end
    local fruitFolder = workspace:FindFirstChild("Fruit ")
    if fruitFolder then
        for _, fruit in ipairs(fruitFolder:GetChildren()) do
            if fruit.Parent and not _G.FruitBlacklist[fruit] then return true end
        end
    end
    return false
end

-- ===== FIX: getPosition always returns Vector3 =====
local function getPosition(obj)
    if not obj or not obj.Parent then return nil end  -- return nil so callers can guard
    if typeof(obj) == "Vector3" then return obj end
    if obj:IsA("Model") then
        local ok, pos = pcall(function() return obj:GetPivot().Position end)
        return ok and pos or nil
    elseif obj:IsA("BasePart") then
        return obj.Position
    else
        if obj.Position then return obj.Position end
        local ok, pos = pcall(function() return obj:GetPivot().Position end)
        return ok and pos or nil
    end
end

-- ===== JUMP FUNCTION =====
local function doJump()
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

-- ===== GET CLOSEST COLLECTIBLE =====
local function getClosestCollectible()
    local player = game.Players.LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local closest = nil
    local closestDist = math.huge

    local fruitFolder = workspace:FindFirstChild("Fruit ")
    if fruitFolder then
        for _, fruit in ipairs(fruitFolder:GetChildren()) do
            if fruit.Parent and not _G.FruitBlacklist[fruit] then
                local pos = getPosition(fruit)
                if pos then
                    local d = (rootPart.Position - pos).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closest = {type="Fruit", instance=fruit, position=pos, distance=d}
                    end
                end
            end
        end
    end

    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then
            local pos = getPosition(v)
            if pos then
                local d = (rootPart.Position - pos).Magnitude
                if d < closestDist then
                    closestDist = d
                    closest = {type="Shard", instance=v, position=pos, distance=d}
                end
            end
        end
    end

    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
            local pos = getPosition(v)
            if pos then
                local d = (rootPart.Position - pos).Magnitude
                if d < closestDist then
                    closestDist = d
                    closest = {type="Egg", instance=v, position=pos, distance=d}
                end
            end
        end
    end

    local folder = workspace:FindFirstChild("ChestModels")
    if folder then
        for _, v in ipairs(folder:GetChildren()) do
            if v.Parent and not _G.ChestBlacklist[v] then
                local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if p then
                    local pos = getPosition(p)
                    if pos then
                        local d = (rootPart.Position - pos).Magnitude
                        if d < closestDist then
                            closestDist = d
                            closest = {type="Chest", instance=v, position=pos, distance=d}
                        end
                    end
                end
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Parent and (obj.Name == "EasterChest" or obj.Name == "Chest") and not _G.ChestBlacklist[obj] then
            local p = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if p then
                local pos = getPosition(p)
                if pos then
                    local d = (rootPart.Position - pos).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closest = {type="Chest", instance=obj, position=pos, distance=d}
                    end
                end
            end
        end
    end

    return closest
end

-- ===== MOVE TO =====
local function moveTo(targetPos, targetInstance, targetType, dynamic, enableJump)
    if dynamic == nil then dynamic = true end
    if enableJump == nil then enableJump = false end
    if not targetPos and not targetInstance then return false end

    -- Resolve initial position from instance if targetPos not given
    if not targetPos and targetInstance then
        local p = getPosition(targetInstance)
        if p then targetPos = p end
    end

    local character = game.Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local old = hrp:FindFirstChild("Lock")
    if old then old:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "Lock"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local checkTimer = 0
    local interrupted = false
    local lastJumpTime = 0

    while _G.AutoFarmEnabled do
        local hrpNow = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrpNow then break end

        if _G.QuestModeEnabled and getSpecialEgg() and targetType ~= "Quest" then break end

        -- Update target position from instance if available
        if targetInstance and targetInstance.Parent then
            local p = getPosition(targetInstance)
            if p then targetPos = p end
        end

        if not targetPos then break end

        local dist = (hrpNow.Position - targetPos).Magnitude
        if dist < 3 then break end

        if enableJump and _G.AutoJumpEnabled and dist < 15 then
            local now = tick()
            if now - lastJumpTime > 0.3 then
                doJump()
                lastJumpTime = now
            end
        end

        if dynamic then
            checkTimer = checkTimer + task.wait()
            if checkTimer >= 0.2 then
                checkTimer = 0
                local closest = getClosestCollectible()
                if closest then
                    local distToCollect = (hrpNow.Position - closest.position).Magnitude
                    local remainingDist = (targetPos - hrpNow.Position).Magnitude
                    if distToCollect < remainingDist - 5 then
                        interrupted = true
                        break
                    end
                end
            end
        else
            task.wait()
        end

        if not _G.AutoFarmEnabled then break end

        bv.Velocity = (targetPos - hrpNow.Position).Unit * SPEED
    end

    -- FIX: stop and destroy cleanly, no stutter
    pcall(function() bv.Velocity = Vector3.new(0, 0, 0) end)
    task.wait(0.05)
    pcall(function() bv:Destroy() end)

    return interrupted
end

-- ===== HOVER MOVEMENT =====
local function hoverMoveTo(target, hoverY, isHovering, enableJump)
    if enableJump == nil then enableJump = false end
    if not target then return false end

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
    -- ตำแหน่งของ target โดยตรงไม่บวก Y
    local targetPosition
    if typeof(target) == "Vector3" then
        targetPosition = target
    elseif typeof(target) == "Instance" then
        targetPosition = getPosition(target)
    end
    if targetPosition then
        bp.Position = Vector3.new(targetPosition.X, targetPosition.Y, targetPosition.Z)
    else
        bp.Position = Vector3.new(hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
    end
    bp.Parent = hrp

    local result = false
    local lastJumpTime = 0

    while _G.AutoFarmEnabled and isHovering and hrp.Parent do
        -- ตรงนี้ก็ใช้ตำแหน่งของ target โดยตรง
        local currentTargetPos
        if typeof(target) == "Vector3" then
            currentTargetPos = target
        elseif typeof(target) == "Instance" then
            currentTargetPos = getPosition(target)
        end

        if not currentTargetPos then break end  -- target gone, exit cleanly

        local dist = (hrp.Position - currentTargetPos).Magnitude
        if dist < 3 then
            result = true
            break
        end

        if enableJump and _G.AutoJumpEnabled and dist < 15 then
            local now = tick()
            if now - lastJumpTime > 0.3 then
                doJump()
                lastJumpTime = now
            end
        end

        local direction = (currentTargetPos - hrp.Position).Unit
        direction = Vector3.new(direction.X, 0, direction.Z)
        bv.Velocity = direction * SPEED
        bp.Position = Vector3.new(hrp.Position.X, hoverY, hrp.Position.Z)

        task.wait()
    end

    -- FIX: clean stop
    pcall(function() bv.Velocity = Vector3.new(0, 0, 0) end)
    pcall(function() bv:Destroy() end)
    pcall(function() bp:Destroy() end)
    return result
end

-- ===== FRUIT PROCESSING =====
local function processFruit(fruitTool)
    if _G.FruitBlacklist[fruitTool] then return end
    _G.FruitBlacklist[fruitTool] = true
    local fruitName = fruitTool.Name
    local fruitType = fruitName:gsub(" Fruit$", "")
    local args = { "StoreFruit", fruitType, fruitTool }
    local success, _ = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
    end)
    if not success then
        Notification.new({ Title = "Fruit", Description = "Failed to store " .. fruitName, Duration = 2, Icon = "rbxassetid://8997385628" })
    else
        Notification.new({ Title = "Fruit", Description = "Stored " .. fruitName, Duration = 2, Icon = "rbxassetid://8997385628" })
    end
end

-- ===== DELIVER FALLING SKY EGG =====
local function deliverFallingSkyEgg(eggInHand)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local optionButton = player.PlayerGui.Main.Dialogue:FindFirstChild("Option1")

    -- Equip the egg
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if eggInHand.Parent ~= character and humanoid then
        humanoid:EquipTool(eggInHand)
        task.wait(0.3)
    end

    -- Hover at current position + 200 studs up
    local hoverY = hrp.Position.Y + 100
    local dropPos = Vector3.new(hrp.Position.X, hoverY, hrp.Position.Z)

    -- Create holding mechanisms (no horizontal movement)
    local bv = Instance.new("BodyVelocity")
    bv.Name = "HoldBV"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local bp = Instance.new("BodyPosition")
    bp.Name = "HoldBP"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 10000
    bp.Position = dropPos
    bp.Parent = hrp

    -- Click to drop the egg
    local elapsed = 0
    local timeout = 10
    while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character and elapsed < timeout do
        clickButton(optionButton)
        task.wait(0.2)
        elapsed = elapsed + 0.2
        bp.Position = dropPos   -- keep locked
    end

    -- Wait for the egg to fall and land (give it 10 seconds)
    local landWait = 0
    while landWait < 10 and _G.AutoFarmEnabled do
        task.wait(0.5)
        landWait = landWait + 0.5
        bp.Position = dropPos
    end

    -- Clean up the holding mechanism
    pcall(function() bv:Destroy() end)
    pcall(function() bp:Destroy() end)

    -- Now find the landed egg on the ground and collect it
    local landedEgg = nil
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
            landedEgg = v
            break
        end
    end

    if landedEgg then
        Notification.new({ Title = "Quest", Description = "Collecting landed egg", Duration = 2, Icon = "rbxassetid://8997385628" })
        moveTo(getPosition(landedEgg), landedEgg, "Egg", false, true)
    end
end

-- ===== DELIVER EGG AND WAIT FOR EGG SPAWN (Thirsty) =====
local function deliverEggAndWaitForEgg(targetPos, eggInHand, optionButton)
    -- First, move to the drop location (ground level)
    moveTo(targetPos, nil, "Quest", false, false)

    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Lock position at the drop point (X, Y, Z)
    local dropPos = hrp.Position
    local bv = Instance.new("BodyVelocity")
    bv.Name = "HoldBV"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)   -- no movement
    bv.Parent = hrp

    local bp = Instance.new("BodyPosition")
    bp.Name = "HoldBP"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 10000
    bp.Position = dropPos
    bp.Parent = hrp

    -- Click the dialogue button repeatedly to drop the egg
    local elapsed = 0
    local timeout = 10
    while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character and elapsed < timeout do
        clickButton(optionButton)
        task.wait(0.2)
        elapsed = elapsed + 0.2
        -- Keep refreshing the locked position
        bp.Position = dropPos
    end

    -- Wait for the new egg to appear (15 seconds max)
    local waitStart = tick()
    local waitDuration = 15
    local eggSpawned = false
    while _G.AutoFarmEnabled and tick() - waitStart < waitDuration do
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                eggSpawned = true
                break
            end
        end
        if eggSpawned then break end
        task.wait(0.5)
        bp.Position = dropPos  -- stay locked
    end

    -- Clean up the holding mechanism
    pcall(function() bv:Destroy() end)
    pcall(function() bp:Destroy() end)

    -- Collect the spawned egg (without any extra hovering)
    if eggSpawned then
        local closestEgg = nil
        local closestDist = math.huge
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                    local pos = getPosition(v)
                    if pos then
                        local d = (rootPart.Position - pos).Magnitude
                        if d < closestDist then
                            closestDist = d
                            closestEgg = v
                        end
                    end
                end
            end
        end
        if closestEgg then
            Notification.new({ Title = "Quest", Description = "Collecting spawned egg", Duration = 2, Icon = "rbxassetid://8997385628" })
            moveTo(getPosition(closestEgg), closestEgg, "Egg", false, true)
        end
    end
end

-- ===== DELIVER EGG WITH MOVE (Molten) =====
local function deliverEggWithMove(targetPos, eggInHand, optionButton)
    moveTo(targetPos, nil, "Quest", false, false)

    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Lock position at the drop point
    local dropPos = hrp.Position
    local bv = Instance.new("BodyVelocity")
    bv.Name = "HoldBV"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    local bp = Instance.new("BodyPosition")
    bp.Name = "HoldBP"
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 10000
    bp.Position = dropPos
    bp.Parent = hrp

    -- Click the dialogue button repeatedly to give the egg
    local elapsed = 0
    local timeout = 10
    while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character and elapsed < timeout do
        clickButton(optionButton)
        task.wait(0.2)
        elapsed = elapsed + 0.2
        bp.Position = dropPos
    end

    -- Wait for any target to spawn (shards, eggs, etc.)
    local waitStart = tick()
    local waitDuration = 10
    local targetSpawned = false
    while _G.AutoFarmEnabled and tick() - waitStart < waitDuration do
        if hasPriorityTarget() then
            targetSpawned = true
            break
        end
        task.wait(0.5)
        bp.Position = dropPos
    end

    pcall(function() bv:Destroy() end)
    pcall(function() bp:Destroy() end)

    -- If targets appeared, collect them normally
    if targetSpawned then
        Notification.new({ Title = "Quest", Description = "Targets spawned, collecting!", Duration = 2, Icon = "rbxassetid://8997385628" })
        -- Keep collecting until none remain (using the existing collectTargets)
        while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
    end
end

-- ===== FRIENDLY EGG =====
local function deliverFriendlyEgg(eggInHand)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local npc = workspace.NPCs:FindFirstChild("Forgotten Quest Giver")
    local targetPos = npc and getPosition(npc) or FRIENDLY_POS
    if not targetPos then targetPos = FRIENDLY_POS end
    moveTo(targetPos, nil, "Quest", false, false)

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
    pcall(function() bp:Destroy() end)
end

-- ===== NOCLIP =====
local noclipLoop = nil
local Clip = true

local function enableNoclip()
    Clip = false
    if noclipLoop then noclipLoop:Disconnect() end
    noclipLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if Clip then return end
        local character = game.Players.LocalPlayer.Character
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    Clip = true
    if noclipLoop then noclipLoop:Disconnect() noclipLoop = nil end
end

-- ===== ANTI SIT =====
local antiSitTask = nil

local function enableAntiSit()
    if antiSitTask then return end
    antiSitTask = task.spawn(function()
        while _G.AutoFarmEnabled do
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Sit then
                    humanoid.Sit = false
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                end
            end
            task.wait(0.2)
        end
    end)
end

local function disableAntiSit()
    if antiSitTask then
        task.cancel(antiSitTask)
        antiSitTask = nil
    end
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
        if v.Parent and (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then return true end
    end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then return true end
    end
    local folder = workspace:FindFirstChild("ChestModels")
    if folder then
        for _, v in ipairs(folder:GetChildren()) do
            if v.Parent and not _G.ChestBlacklist[v] then return true end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Parent and (obj.Name == "EasterChest" or obj.Name == "Chest") and not _G.ChestBlacklist[obj] then return true end
    end
    local fruitFolder = workspace:FindFirstChild("Fruit ")
    if fruitFolder then
        for _, fruit in ipairs(fruitFolder:GetChildren()) do
            if fruit.Parent and not _G.FruitBlacklist[fruit] then return true end
        end
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

    local fruitFolder = workspace:FindFirstChild("Fruit ")
    if fruitFolder then
        local closestFruit, closestFruitDist = nil, math.huge
        for _, fruit in ipairs(fruitFolder:GetChildren()) do
            if fruit.Parent and not _G.FruitBlacklist[fruit] then
                local fPos = getPosition(fruit)
                if fPos then
                    local d = (rootPart.Position - fPos).Magnitude
                    if d < closestFruitDist then
                        closestFruitDist = d
                        closestFruit = fruit
                    end
                end
            end
        end
        if closestFruit then
            local targetPos = getPosition(closestFruit)
            if targetPos then
                notifyOnce(closestFruit, "Collect", "Fruit")
                moveTo(targetPos, closestFruit, "Fruit", false, true)
                _G.FruitBlacklist[closestFruit] = true
                task.wait(1)
                local fruitTool = nil
                for _, tool in ipairs(player.Backpack:GetChildren()) do
                    if string.find(tool.Name, "Fruit") then fruitTool = tool break end
                end
                if not fruitTool and player.Character then
                    for _, tool in ipairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then fruitTool = tool break end
                    end
                end
                if fruitTool then
                    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid:EquipTool(fruitTool) task.wait(0.5) end
                    processFruit(fruitTool)
                    pcall(function() fruitTool:Destroy() end)
                end
                return true
            end
        end
    end

    local closestShard, closestShardDist = nil, math.huge
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then
            local sPos = getPosition(v)
            if sPos then
                local d = (rootPart.Position - sPos).Magnitude
                if d < closestShardDist then
                    closestShardDist = d
                    closestShard = v
                end
            end
        end
    end
    if closestShard then
        local targetPos = getPosition(closestShard)
        if targetPos then
            notifyOnce(closestShard, "Collect", "Shard")
            moveTo(targetPos, closestShard, "Shard", false, true)
            _G.ShardBlacklist[closestShard] = true
            return true
        end
    end

    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
            local pos = getPosition(v)
            if pos then
                notifyOnce(v, "Collect", "Egg")
                moveTo(pos, v, "Egg", false, true)
                return true
            end
        end
    end

    local folder = workspace:FindFirstChild("ChestModels")
    if folder then
        local nearestDist = math.huge
        local chestTarget = nil
        local chestPos = nil
        for _, v in ipairs(folder:GetChildren()) do
            if v.Parent and not _G.ChestBlacklist[v] then
                local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if p then
                    local pos = getPosition(p)
                    if pos then
                        local d = (rootPart.Position - pos).Magnitude
                        if d < nearestDist then
                            nearestDist = d
                            chestTarget = v
                            chestPos = pos
                        end
                    end
                end
            end
        end
        if chestTarget then
            moveTo(chestPos, chestTarget, "Chest", false, true)
            _G.ChestBlacklist[chestTarget] = true
            if _G.ChestWaitTime > 0 then task.wait(_G.ChestWaitTime) end
            return true
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Parent and (obj.Name == "EasterChest" or obj.Name == "Chest") and not _G.ChestBlacklist[obj] then
            local p = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if p then
                local pos = getPosition(p)
                if pos then
                    moveTo(pos, obj, "Chest", false, true)
                    _G.ChestBlacklist[obj] = true
                    if _G.ChestWaitTime > 0 then task.wait(_G.ChestWaitTime) end
                    return true
                end
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

-- ===== CIRCLE STEP =====
local function circleStep(route)
    if not route or #route == 0 then return false end
    if not isCharacterAlive() then return "dead" end

    if _G.CurrentCircleIndex > #route then
        _G.CurrentCircleRound = _G.CurrentCircleRound + 1
        _G.CurrentCircleIndex = 1
        if _G.CurrentCircleRound > 2 then 
            return "finished" 
        else
            Notification.new({ Title = "Circle", Description = string.format("Starting round %d on %s", _G.CurrentCircleRound, _G.CurrentCircleIsland.Name), Duration = 3, Icon = "rbxassetid://8997385628" })
        end
    end

    local waypoint = route[_G.CurrentCircleIndex]
    if not waypoint then return false end

    Notification.new({ Title = "Circle", Description = string.format("Moving to waypoint %d/%d (Round %d) on %s", _G.CurrentCircleIndex, #route, _G.CurrentCircleRound, _G.CurrentCircleIsland.Name), Duration = 2, Icon = "rbxassetid://8997385628" })

    local interrupted = moveTo(waypoint, nil, "Waypoint", true, false)
    
    if interrupted then
        while collectTargets() do task.wait(0.1) end
        return "continue"
    end
    
    if hasAnyTarget() then return "target_found" end
    
    _G.CurrentCircleIndex = _G.CurrentCircleIndex + 1
    return "continue"
end
-- ===== MAIN AUTO-FARM LOOP =====
local function StartFarming()
    task.spawn(function()
        local player = game.Players.LocalPlayer
        task.spawn(function()
            while _G.AutoFarmEnabled do task.wait(15) _G.ChestBlacklist = {} _G.ShardBlacklist = {} end
        end)

        while _G.AutoFarmEnabled do
            -- Wait until character is alive
            while not isCharacterAlive() and _G.AutoFarmEnabled do
                lastNotifiedTarget = nil
                -- FIX: Also reset island state while dead to avoid leftover state
                _G.CurrentCircleIsland = nil
                _G.CurrentCircleIndex = 1
                _G.CurrentCircleRound = 1
                task.wait(2)
            end
            if not _G.AutoFarmEnabled then break end

            -- FIX: Wait for character to fully load after respawn
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local loadAttempts = 0
            while (not character or not hrp) and loadAttempts < 10 and _G.AutoFarmEnabled do
                task.wait(0.5)
                character = player.Character
                hrp = character and character:FindFirstChild("HumanoidRootPart")
                loadAttempts = loadAttempts + 1
            end
            if not hrp then
                -- If still no HRP, skip this iteration
                task.wait(1)
                continue
            end

            local eggInHand = getSpecialEgg()

            -- If we have an egg but Quest Mode is off, kill the player to drop it (prevents getting stuck)
            if eggInHand and not _G.QuestModeEnabled then
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                        task.wait(2)
                        continue
                    end
                end
            end

            if _G.QuestModeEnabled and eggInHand then
                -- FIX: Ensure the dialogue GUI is available before delivering
                local gui = player.PlayerGui:FindFirstChild("Main")
                local dialogue = gui and gui:FindFirstChild("Dialogue")
                local optionButton = dialogue and dialogue:FindFirstChild("Option1")
                local attempts = 0
                while (not optionButton or not optionButton.Visible) and attempts < 10 and _G.AutoFarmEnabled do
                    task.wait(0.5)
                    gui = player.PlayerGui:FindFirstChild("Main")
                    dialogue = gui and gui:FindFirstChild("Dialogue")
                    optionButton = dialogue and dialogue:FindFirstChild("Option1")
                    attempts = attempts + 1
                end

                -- Re-check character again after waiting
                character = player.Character
                hrp = character and character:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    task.wait(1)
                    continue
                end

                local humanoid = character:FindFirstChild("Humanoid")
                if eggInHand.Parent ~= character and humanoid then
                    humanoid:EquipTool(eggInHand)
                    task.wait(0.3)
                end

                if eggInHand.Name == "Firefly Egg" or eggInHand.Name == "Friendly Neighborhood Egg" then
                    notifyOnce(eggInHand, "Quest", "Give " .. eggInHand.Name)
                    deliverFriendlyEgg(eggInHand)
                elseif string.find(eggInHand.Name, "Falling") then
                    notifyOnce(eggInHand, "Quest", "Drop " .. eggInHand.Name)
                    deliverFallingSkyEgg(eggInHand)
                elseif string.find(eggInHand.Name, "Thirsty") then
                    notifyOnce(eggInHand, "Quest", "Drop " .. eggInHand.Name)
                    deliverEggAndWaitForEgg(THIRSTY_POS, eggInHand, optionButton)
                elseif string.find(eggInHand.Name, "Molten") then
                    notifyOnce(eggInHand, "Quest", "Give " .. eggInHand.Name)
                    deliverEggWithMove(MOLTEN_POS, eggInHand, optionButton)
                else
                    task.wait(1)
                end

                task.wait(1.5)
                _G.CurrentCircleIsland = nil
                while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
                continue
            end

            if not _G.CurrentCircleIsland or not _G.CurrentCircleIsland.Parent then
                _G.CurrentCircleIsland = getNextIsland()
                if not _G.CurrentCircleIsland then task.wait(1) continue end
                _G.CurrentCircleIndex = 1
                _G.CurrentCircleRound = 1
                local ok, pivot = pcall(function() return _G.CurrentCircleIsland:GetPivot().Position end)
                if ok and _G.AutoFarmEnabled then
                    notifyOnce(_G.CurrentCircleIsland, "Move", "Going to " .. _G.CurrentCircleIsland.Name)
                    local interrupted = moveTo(pivot + Vector3.new(0, 80, 0), nil, "Travel", true, false)
                    if interrupted then
                        while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
                    end
                end
                Notification.new({ Title = "Circle", Description = string.format("Starting circle on %s (Round 1)", _G.CurrentCircleIsland.Name), Duration = 3, Icon = "rbxassetid://8997385628" })
            end

            if _G.FarmMode == "random" then
                if hasAnyTarget() then collectTargets() else _G.CurrentCircleIsland = nil end
                task.wait(0.1)
                continue
            end

            local route = getRouteForIsland(_G.CurrentCircleIsland.Name)
            if not route or #route == 0 then route = generateBoundingBoxRoute(_G.CurrentCircleIsland) end
            if not route or #route == 0 then
                if hasAnyTarget() then collectTargets() else _G.CurrentCircleIsland = nil end
                task.wait(0.5)
                continue
            end

            local result = circleStep(route)
            if result == "target_found" then
                while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
                _G.CurrentCircleIndex = _G.CurrentCircleIndex + 1
            elseif result == "finished" then
                _G.CurrentCircleIsland = nil
                Notification.new({ Title = "Circle", Description = "No targets found after 2 rounds, moving to next island", Duration = 3, Icon = "rbxassetid://8997385628" })
            end
            task.wait(0.1)
        end
    end)
end

-- ===== DAMAGE AURA =====
_G.DamageAuraEnabled = false

local damageAuraTask = nil

local function damageEnemy(enemy)
    if not enemy or not enemy.Parent then return end

    -- Find a suitable part to hit (prefer HumanoidRootPart, then Head, else any BasePart)
    local hitPart = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head")
    if not hitPart then
        for _, part in ipairs(enemy:GetDescendants()) do
            if part:IsA("BasePart") then
                hitPart = part
                break
            end
        end
    end
    if not hitPart then return end

    -- Fire RegisterAttack
    local attackArgs = { 0.4000000059604645 }
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack"):FireServer(unpack(attackArgs))
    end)

    -- Fire RegisterHit with the actual enemy part and the correct ID
    local hitArgs = { hitPart, {}, [4] = "196f522a" }
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit"):FireServer(unpack(hitArgs))
    end)
end

local function startDamageAura()
    if damageAuraTask then return end
    damageAuraTask = task.spawn(function()
        while _G.DamageAuraEnabled do
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in ipairs(enemies:GetChildren()) do
                    if enemy and enemy.Parent then
                        damageEnemy(enemy)
                        task.wait()  -- small delay between enemies
                    end
                end
            end
            task.wait()  -- wait before scanning again
        end
        damageAuraTask = nil
    end)
end

local function stopDamageAura()
    if damageAuraTask then
        task.cancel(damageAuraTask)
        damageAuraTask = nil
    end
end

-- ===== DAMAGE AURA PLAYERS =====
_G.DamageAuraPlayersEnabled = false

local damagePlayerAuraTask = nil

local function damagePlayer(character)
    if not character or not character.Parent then return end

    local hitPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
    if not hitPart then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                hitPart = part
                break
            end
        end
    end
    if not hitPart then return end

    local attackArgs = { 0.4000000059604645 }
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack"):FireServer(unpack(attackArgs))
    end)

    local hitArgs = { hitPart, {}, [4] = "196f522a" }
    pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit"):FireServer(unpack(hitArgs))
    end)
end

local function startDamagePlayerAura()
    if damagePlayerAuraTask then return end
    damagePlayerAuraTask = task.spawn(function()
        local localPlayer = game.Players.LocalPlayer
        while _G.DamageAuraPlayersEnabled do
            local playersFolder = workspace:FindFirstChild("Characters")
            if playersFolder then
                for _, character in ipairs(playersFolder:GetChildren()) do
                    if character and character.Parent and character ~= localPlayer.Character then
                        damagePlayer(character)
                        task.wait()
                    end
                end
            end
            task.wait()
        end
        damagePlayerAuraTask = nil
    end)
end

local function stopDamagePlayerAura()
    if damagePlayerAuraTask then
        task.cancel(damagePlayerAuraTask)
        damagePlayerAuraTask = nil
    end
end

_G.BringMobEnabled = false
_G.BringMobSpeed = 450
_G.BringMobHeight = 10
_G.BringMobMaxDistance = 500     -- ระยะสูงสุด (studs)
_G.BringMobMaxCount = 25

-- ===== BRING MOB - FAST + ไม่หล่น + NOCLIP =====
local TweenService = game:GetService("TweenService")
local bringMobTask = nil
local activeMobTweens = {}
local activeMobBVs = {}
local mobNoclipConnections = {}  -- เก็บ connection สำหรับแต่ละมอน

local function stopMobControl(enemy)
    if activeMobTweens[enemy] then
        pcall(function() activeMobTweens[enemy]:Cancel() end)
        activeMobTweens[enemy] = nil
    end
    if activeMobBVs[enemy] then
        pcall(function() activeMobBVs[enemy]:Destroy() end)
        activeMobBVs[enemy] = nil
    end
    -- หยุด noclip loop สำหรับมอนนี้
    if mobNoclipConnections[enemy] then
        pcall(function() mobNoclipConnections[enemy]:Disconnect() end)
        mobNoclipConnections[enemy] = nil
    end
end

local function enableMobNoclip(enemy)
    -- ถ้ามี connection อยู่แล้ว ไม่ต้องสร้างใหม่
    if mobNoclipConnections[enemy] then return end
    
    mobNoclipConnections[enemy] = game:GetService("RunService").Heartbeat:Connect(function()
        if not enemy or not enemy.Parent then
            if mobNoclipConnections[enemy] then
                mobNoclipConnections[enemy]:Disconnect()
                mobNoclipConnections[enemy] = nil
            end
            return
        end
        
        -- ปิด CanCollide ของทุก part ในมอน
        for _, part in ipairs(enemy:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function startBringMob()
    if bringMobTask then return end

    bringMobTask = task.spawn(function()
        while _G.BringMobEnabled do
            local playerRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not playerRoot then 
                task.wait(0.5) 
                continue 
            end

            local enemiesFolder = workspace:FindFirstChild("Enemies")
            if not enemiesFolder then 
                task.wait(1) 
                continue 
            end

            -- ล้างตัวที่หายไป
            for enemy, _ in pairs(activeMobTweens) do
                if not enemy or not enemy.Parent then
                    stopMobControl(enemy)
                end
            end

            local broughtCount = 0
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if broughtCount >= _G.BringMobMaxCount then break end
                
                if enemy and enemy.Parent then
                    local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                    if hrp then
                        local distance = (playerRoot.Position - hrp.Position).Magnitude

                        if distance > 8 and distance <= _G.BringMobMaxDistance then
                            stopMobControl(enemy)

                            -- เปิด noclip สำหรับมอนนี้
                            enableMobNoclip(enemy)

                            -- === สร้าง BodyVelocity เพื่อป้องกันการหล่น ===
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "BringMobAntiFall"
                            bv.MaxForce = Vector3.new(4000, 4000, 4000)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = hrp
                            activeMobBVs[enemy] = bv

                            -- Tween หลัก (ดึงเร็ว)
                            local tweenTime = math.clamp(distance / _G.BringMobSpeed, 0.08, 0.25)

                            local tweenInfo = TweenInfo.new(
                                tweenTime,
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.Out
                            )

                            local targetPos = playerRoot.Position + Vector3.new(0, _G.BringMobHeight, 0)
                            local targetCFrame = CFrame.new(targetPos) * CFrame.new(0, 0, -5)

                            local goal = { CFrame = targetCFrame }

                            local tween = TweenService:Create(hrp, tweenInfo, goal)
                            activeMobTweens[enemy] = tween
                            tween:Play()

                            broughtCount += 1
                        else
                            stopMobControl(enemy)
                        end
                    end
                end
            end

            task.wait(0.05)
        end

        stopBringMob()
    end)
end

local function stopBringMob()
    if bringMobTask then
        task.cancel(bringMobTask)
        bringMobTask = nil
    end

    for enemy, _ in pairs(activeMobTweens) do
        stopMobControl(enemy)
    end
    activeMobTweens = {}
    activeMobBVs = {}
    mobNoclipConnections = {}
end
-- ===== UI =====
local Windows = NothingLibrary.new({ Title = "Easter Event Farm", Description = "FrostByte | by Arrays (Mobile Ready)", Keybind = Enum.KeyCode.LeftControl, Logo = 'http://www.roblox.com/asset/?id=18898582662' })

local MainTab = Windows:NewTab({ Title = "Main", Description = "Auto Farm Controls", Icon = "rbxassetid://4483362458" })
local FarmSection = MainTab:NewSection({ Title = "Farming", Icon = "rbxassetid://7743869054", Position = "Left" })

FarmSection:NewDropdown({ Title = "Farm Mode", Data = {"Random", "Circle"}, Default = "Random", Callback = function(Value) _G.FarmMode = Value == "Random" and "random" or "circle" end })

FarmSection:NewToggle({ Title = "Enable Auto Farm", Default = false, Callback = function(Value) 
    _G.AutoFarmEnabled = Value 
    if Value then 
        StartFarming() 
        enableNoclip() 
        enableAntiSit() 
    else 
        lastNotifiedTarget = nil
        _G.CurrentCircleIsland = nil
        disableNoclip() 
        disableAntiSit()
        -- FIX: destroy any leftover movers so stutter stops immediately
        local character = game.Players.LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, name in ipairs({"Lock","HoverBV","HoverBP","QuestFloat"}) do
                    local obj = hrp:FindFirstChild(name)
                    if obj then pcall(function() obj:Destroy() end) end
                end
            end
        end
    end 
end })

FarmSection:NewToggle({ Title = "Enable Quest Delivery", Default = false, Callback = function(Value) _G.QuestModeEnabled = Value lastNotifiedTarget = nil end })

local SettingsTab = Windows:NewTab({ Title = "Settings", Description = "Configuration", Icon = "rbxassetid://7733960981" })
local ConfigSection = SettingsTab:NewSection({ Title = "Configuration", Icon = "rbxassetid://7743869054", Position = "Left" })
local ConfigSection2 = SettingsTab:NewSection({ Title = "Combat", Icon = "rbxassetid://7743869054", Position = "Right" })

ConfigSection:NewSlider({ Title = "Tween Speed", Min = 100, Max = 400, Default = 300, Callback = function(Value) SPEED = Value end })
ConfigSection:NewSlider({ Title = "Chest Wait Time (ms)", Min = 10, Max = 500, Default = 10, Callback = function(Value) _G.ChestWaitTime = Value / 1000 end })
ConfigSection:NewToggle({ Title = "Auto Jump", Default = true, Callback = function(Value) _G.AutoJumpEnabled = Value end })

ConfigSection2:NewToggle({
    Title = "Damage Aura",
    Default = false,
    Callback = function(Value)
        _G.DamageAuraEnabled = Value
        if Value then
            startDamageAura()
        else
            stopDamageAura()
        end
    end
})

ConfigSection2:NewToggle({
    Title = "Damage Aura (Players)",
    Default = false,
    Callback = function(Value)
        _G.DamageAuraPlayersEnabled = Value
        if Value then
            startDamagePlayerAura()
        else
            stopDamagePlayerAura()
        end
    end
})

ConfigSection2:NewToggle({
    Title = "Bring Mob (All Mobs - Fast)",
    Default = false,
    Callback = function(Value)
        _G.BringMobEnabled = Value
        if Value then
            startBringMob()
        else
            stopBringMob()
        end
    end
})

ConfigSection2:NewSlider({ Title = "Bring Mob Speed", Min = 200, Max = 900, Default = 450, Callback = function(v) _G.BringMobSpeed = v end })
ConfigSection2:NewSlider({ Title = "Bring Mob Height (Y)", Min = -100, Max = 100, Default = 12, Callback = function(v) _G.BringMobHeight = v end })
ConfigSection2:NewSlider({ Title = "Max Bring Distance", Min = 100, Max = 1200, Default = 600, Callback = function(v) _G.BringMobMaxDistance = v end })
ConfigSection2:NewSlider({ Title = "Max Mobs to Bring", Min = 5, Max = 40, Default = 20, Callback = function(v) _G.BringMobMaxCount = v end })
