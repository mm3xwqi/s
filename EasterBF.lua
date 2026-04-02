local success, NothingLibrary = pcall(function()
    return loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
end)

if not success or type(NothingLibrary) ~= "table" then
    warn("Failed to load NothingLibrary")
    return
end

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

_G.AutoEquipEnabled = false
_G.SelectedWeaponType = "Melee"

_G.FarmAuraEnabled = false
_G.FarmAuraHeight = 50
_G.BringMobEnabled = false
_G.BringMobMaxDistance = 500

-- Auto Farm Boss
_G.AutoFarmBossEnabled = false
_G.SelectedBossName = nil

-- ค่า Default
local BRING_MOB_SPEED = 450
local BRING_MOB_HEIGHT = 0
local SPEED = 350
local THIRSTY_POS = Vector3.new(-1188, 10, 1296)
local MOLTEN_POS = Vector3.new(-5227, 200, -5497)
local FRIENDLY_POS = Vector3.new(-3053, 240, -10144)
local TweenService = game:GetService("TweenService")

-- Circle state
_G.CurrentCircleIsland = nil
_G.CurrentCircleIndex = 1
_G.CurrentCircleRound = 1

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

-- ===== UTILITY FUNCTIONS =====
local function getToolTip(tool)
    if not tool then return nil end
    local success, tip = pcall(function() return tool.ToolTip end)
    if success and tip and tip ~= "" then return tip end
    local tipChild = tool:FindFirstChild("ToolTip")
    if tipChild then
        if tipChild:IsA("StringValue") or tipChild:IsA("ObjectValue") then
            return tipChild.Value
        elseif type(tipChild.Value) == "string" then
            return tipChild.Value
        end
    end
    local attrTip = tool:GetAttribute("ToolTip")
    if attrTip then return attrTip end
    return tool.Name
end

local function findToolByType(weaponType)
    local player = game.Players.LocalPlayer
    local backpack = player.Backpack
    local character = player.Character
    local function matchesType(tool)
        local tip = getToolTip(tool)
        if tip then
            local tipLower = string.lower(tip)
            local typeLower = string.lower(weaponType)
            if string.find(tipLower, typeLower) then return true end
        end
        return false
    end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and matchesType(tool) then return tool end
    end
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and matchesType(tool) then return tool end
        end
    end
    return nil
end

local function equipWeapon(weaponType)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    local toolToEquip = findToolByType(weaponType)
    if toolToEquip then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if toolToEquip.Parent == player.Backpack then
                toolToEquip.Parent = character
                task.wait(0.1)
            end
            humanoid:EquipTool(toolToEquip)
            Notification.new({ Title = "Auto Equip", Description = "Equipped " .. toolToEquip.Name, Duration = 2 })
        end
    else
        Notification.new({ Title = "Auto Equip", Description = "No " .. weaponType .. " tool found!", Duration = 2 })
    end
end

local autoEquipTask = nil
local function startAutoEquip()
    if autoEquipTask then return end
    autoEquipTask = task.spawn(function()
        while _G.AutoEquipEnabled do
            local character = game.Players.LocalPlayer.Character
            local currentlyEquipped = nil
            if character then
                for _, tool in ipairs(character:GetChildren()) do
                    if tool:IsA("Tool") and tool.Parent == character then
                        currentlyEquipped = tool
                        break
                    end
                end
            end
            if not currentlyEquipped then
                equipWeapon(_G.SelectedWeaponType)
                task.wait(0.5)
            else
                local currentTip = getToolTip(currentlyEquipped)
                local expectedType = _G.SelectedWeaponType
                if not currentTip or not string.find(string.lower(currentTip), string.lower(expectedType)) then
                    currentlyEquipped.Parent = game.Players.LocalPlayer.Backpack
                    task.wait(0.2)
                    equipWeapon(expectedType)
                end
            end
            task.wait(1)
        end
        autoEquipTask = nil
    end)
end

local function stopAutoEquip()
    _G.AutoEquipEnabled = false
    if autoEquipTask then task.cancel(autoEquipTask) autoEquipTask = nil end
end

-- ===== ROUTES =====
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
    return humanoid and humanoid.Health > 0
end

local function isEnemyAlive(enemy)
    if not enemy or not enemy.Parent then return false end
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
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

local function getPosition(obj)
    if not obj or not obj.Parent then return nil end
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

local function doJump()
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

-- ===== COLLECTIBLE =====
local function getClosestCollectible()
    local player = game.Players.LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local closest = nil
    local closestDist = math.huge
    -- Fruit
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
    -- Shard
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
    -- Egg
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
    -- Chest
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
        local currentTargetPos
        if typeof(target) == "Vector3" then
            currentTargetPos = target
        elseif typeof(target) == "Instance" then
            currentTargetPos = getPosition(target)
        end
        if not currentTargetPos then break end
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
    pcall(function() bv:Velocity = Vector3.new(0, 0, 0) end)
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
        Notification.new({ Title = "Fruit", Description = "Failed to store " .. fruitName, Duration = 2 })
    else
        Notification.new({ Title = "Fruit", Description = "Stored " .. fruitName, Duration = 2 })
    end
end

-- ===== EGG DELIVERY (ย่อ) =====
local function deliverFallingSkyEgg(eggInHand)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local optionButton = player.PlayerGui.Main.Dialogue:FindFirstChild("Option1")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if eggInHand.Parent ~= character and humanoid then
        humanoid:EquipTool(eggInHand)
        task.wait(0.3)
    end
    local hoverY = hrp.Position.Y + 100
    local dropPos = Vector3.new(hrp.Position.X, hoverY, hrp.Position.Z)
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
    local elapsed = 0
    local timeout = 10
    while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character and elapsed < timeout do
        clickButton(optionButton)
        task.wait(0.2)
        elapsed = elapsed + 0.2
        bp.Position = dropPos
    end
    local landWait = 0
    while landWait < 10 and _G.AutoFarmEnabled do
        task.wait(0.5)
        landWait = landWait + 0.5
        bp.Position = dropPos
    end
    pcall(function() bv:Destroy() end)
    pcall(function() bp:Destroy() end)
    local landedEgg = nil
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
            landedEgg = v
            break
        end
    end
    if landedEgg then
        Notification.new({ Title = "Quest", Description = "Collecting landed egg", Duration = 2 })
        moveTo(getPosition(landedEgg), landedEgg, "Egg", false, true)
    end
end

local function deliverEggAndWaitForEgg(targetPos, eggInHand, optionButton)
    moveTo(targetPos, nil, "Quest", false, false)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
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
    local elapsed = 0
    local timeout = 10
    while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character and elapsed < timeout do
        clickButton(optionButton)
        task.wait(0.2)
        elapsed = elapsed + 0.2
        bp.Position = dropPos
    end
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
        bp.Position = dropPos
    end
    pcall(function() bv:Destroy() end)
    pcall(function() bp:Destroy() end)
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
            Notification.new({ Title = "Quest", Description = "Collecting spawned egg", Duration = 2 })
            moveTo(getPosition(closestEgg), closestEgg, "Egg", false, true)
        end
    end
end

local function deliverEggWithMove(targetPos, eggInHand, optionButton)
    moveTo(targetPos, nil, "Quest", false, false)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
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
    local elapsed = 0
    local timeout = 10
    while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character and elapsed < timeout do
        clickButton(optionButton)
        task.wait(0.2)
        elapsed = elapsed + 0.2
        bp.Position = dropPos
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
        bp.Position = dropPos
    end
    pcall(function() bv:Destroy() end)
    pcall(function() bp:Destroy() end)
    if targetSpawned then
        Notification.new({ Title = "Quest", Description = "Targets spawned, collecting!", Duration = 2 })
        while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
    end
end

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
        Notification.new({ Title = title, Description = description, Duration = 2 })
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
    -- Fruit
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
    -- Shard
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
    -- Egg
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
    -- Chest
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
        Vector3.new(cx, patrolY, cz - rz),
        Vector3.new(cx + rx, patrolY, cz - rz),
        Vector3.new(cx + rx, patrolY, cz),
        Vector3.new(cx + rx, patrolY, cz + rz),
        Vector3.new(cx, patrolY, cz + rz),
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
            Notification.new({ Title = "Circle", Description = string.format("Starting round %d on %s", _G.CurrentCircleRound, _G.CurrentCircleIsland.Name), Duration = 3 })
        end
    end
    local waypoint = route[_G.CurrentCircleIndex]
    if not waypoint then return false end
    Notification.new({ Title = "Circle", Description = string.format("Moving to waypoint %d/%d (Round %d) on %s", _G.CurrentCircleIndex, #route, _G.CurrentCircleRound, _G.CurrentCircleIsland.Name), Duration = 2 })
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
            while not isCharacterAlive() and _G.AutoFarmEnabled do
                lastNotifiedTarget = nil
                _G.CurrentCircleIsland = nil
                _G.CurrentCircleIndex = 1
                _G.CurrentCircleRound = 1
                task.wait(2)
            end
            if not _G.AutoFarmEnabled then break end
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
                task.wait(1)
                continue
            end
            local eggInHand = getSpecialEgg()
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
                Notification.new({ Title = "Circle", Description = string.format("Starting circle on %s (Round 1)", _G.CurrentCircleIsland.Name), Duration = 3 })
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
                Notification.new({ Title = "Circle", Description = "No targets found after 2 rounds, moving to next island", Duration = 3 })
            end
            task.wait(0.1)
        end
    end)
end

local function getClosestEnemy()
    local player = game.Players.LocalPlayer
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local closest = nil
    local closestDist = math.huge
    for _, enemy in ipairs(enemies:GetChildren()) do
        if enemy and enemy.Parent and isEnemyAlive(enemy) then
            local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
            if hrp then
                local dist = (rootPart.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = {enemy = enemy, part = hrp, dist = dist}
                end
            end
        end
    end
    return closest
end

-- ===== DAMAGE AURA =====
_G.DamageAuraEnabled = false
local damageAuraTask = nil
local function damageEnemy(enemy)
    if not enemy or not enemy.Parent then return end
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local hitPart = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head") or enemy:FindFirstChild("UpperTorso") or enemy:FindFirstChild("LowerTorso")
    if not hitPart then
        for _, part in ipairs(enemy:GetDescendants()) do
            if part:IsA("BasePart") then
                hitPart = part
                break
            end
        end
    end
    if not hitPart then return end
    local repStorage = game:GetService("ReplicatedStorage")
    local modules = repStorage:FindFirstChild("Modules")
    if modules then
        local net = modules:FindFirstChild("Net")
        if net then
            local attackRemote = net:FindFirstChild("RE/RegisterAttack")
            local hitRemote = net:FindFirstChild("RE/RegisterHit")
            if attackRemote and hitRemote then
                pcall(function()
                    attackRemote:FireServer(0.5)
                    hitRemote:FireServer(hitPart, {}, "196f522a")
                end)
            end
        end
    end
end
local function startDamageAura()
    if damageAuraTask then return end
    damageAuraTask = task.spawn(function()
        while _G.DamageAuraEnabled do
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                local aliveEnemies = {}
                for _, enemy in ipairs(enemies:GetChildren()) do
                    if enemy and enemy.Parent and isEnemyAlive(enemy) then
                        table.insert(aliveEnemies, enemy)
                    end
                end
                if #aliveEnemies > 0 then
                    local numToHit = math.random(1, math.max(1, math.floor(#aliveEnemies / 2)))
                    for i = 1, numToHit do
                        local randIndex = math.random(1, #aliveEnemies)
                        local target = aliveEnemies[randIndex]
                        if target then
                            damageEnemy(target)
                        end
                        table.remove(aliveEnemies, randIndex)
                        if #aliveEnemies == 0 then break end
                    end
                end
            end
            task.wait(0.05)
        end
        damageAuraTask = nil
    end)
end
local function stopDamageAura()
    if damageAuraTask then task.cancel(damageAuraTask) damageAuraTask = nil end
end

_G.DamageAuraPlayersEnabled = false
local damagePlayerAuraTask = nil
local function damagePlayer(character)
    if not character or not character.Parent then return end
    local hitPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("LowerTorso")
    if not hitPart then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then hitPart = part break end
        end
    end
    if not hitPart then return end
    local repStorage = game:GetService("ReplicatedStorage")
    local modules = repStorage:FindFirstChild("Modules")
    if modules then
        local net = modules:FindFirstChild("Net")
        if net then
            local attackRemote = net:FindFirstChild("RE/RegisterAttack")
            local hitRemote = net:FindFirstChild("RE/RegisterHit")
            if attackRemote and hitRemote then
                pcall(function()
                    attackRemote:FireServer(0.5)
                    hitRemote:FireServer(hitPart, {}, "196f522a")
                end)
            end
        end
    end
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
                        task.wait(0.02)
                    end
                end
            end
            task.wait(0.1)
        end
        damagePlayerAuraTask = nil
    end)
end
local function stopDamagePlayerAura()
    if damagePlayerAuraTask then task.cancel(damagePlayerAuraTask) damagePlayerAuraTask = nil end
end

-- ===== FARM AURA =====
local farmAuraTask = nil
local farmAuraActive = false
local function startFarmAura()
    if farmAuraTask then return end
    farmAuraActive = true
    enableNoclip()
    farmAuraTask = task.spawn(function()
        while farmAuraActive do
            local player = game.Players.LocalPlayer
            local character = player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end
            local oldBV = hrp:FindFirstChild("FarmAuraBV")
            if oldBV then oldBV:Destroy() end
            local target = getClosestEnemy()
            if target then
                local targetPos = Vector3.new(target.part.Position.X, target.part.Position.Y + _G.FarmAuraHeight, target.part.Position.Z)
                local dist = (hrp.Position - targetPos).Magnitude
                if dist > 2 then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "FarmAuraBV"
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    local dir = (targetPos - hrp.Position).Unit
                    local speed = math.clamp(dist * 8, 20, SPEED)
                    bv.Velocity = dir * speed
                    bv.Parent = hrp
                else
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "FarmAuraBV"
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = hrp
                end
                task.wait(0.05)
            else
                task.wait(0.2)
            end
        end
    end)
end
local function stopFarmAura()
    farmAuraActive = false
    if farmAuraTask then task.cancel(farmAuraTask) farmAuraTask = nil end
    disableNoclip()
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChild("FarmAuraBV")
        if bv then bv:Destroy() end
    end
end

-- ===== BRING MOB =====
local bringMobTask = nil
local mobArrivedSet = {}
_G.BringMobTweens = {}
local function setMobNoclip(enemy, enabled)
    if not enemy or not enemy.Parent then return end
    for _, part in ipairs(enemy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enabled
        end
    end
end
local function releaseMob(enemy)
    if not enemy or not enemy.Parent then return end
    if _G.BringMobTweens[enemy] then
        pcall(function() _G.BringMobTweens[enemy]:Cancel() end)
        _G.BringMobTweens[enemy] = nil
    end
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
    setMobNoclip(enemy, false)
    local hrp = enemy:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChild("BringMobBV")
        if bv then pcall(function() bv:Destroy() end) end
        local bp = hrp:FindFirstChild("BringMobBP")
        if bp then pcall(function() bp:Destroy() end) end
    end
end
local function getEnemyLevel(enemy)
    if not enemy then return nil end
    local data = enemy:FindFirstChild("Data")
    if data then
        local lvl = data:FindFirstChild("Level")
        if lvl and lvl.Value then return lvl.Value end
    end
    local attr = enemy:GetAttribute("Level")
    if attr then return attr end
    local lvlObj = enemy:FindFirstChild("Level")
    if lvlObj and lvlObj.Value then return lvlObj.Value end
    local name = enemy.Name
    local num = tonumber(name:match("%d+"))
    if num then return num end
    return nil
end
local function startBringMob()
    if bringMobTask then return end
    mobArrivedSet = {}
    _G.BringMobTweens = {}
    Notification.new({ Title = "Bring Mob", Description = "Starting", Duration = 2 })
    bringMobTask = task.spawn(function()
        while _G.BringMobEnabled do
            local player = game.Players.LocalPlayer
            local character = player.Character
            local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
            if not playerRoot then task.wait(0.5) continue end
            local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs") or workspace:FindFirstChild("Enemy")
            if not enemiesFolder then
                Notification.new({ Title = "Bring Mob", Description = "No enemies folder!", Duration = 3 })
                task.wait(3)
                continue
            end
            for enemy, _ in pairs(mobArrivedSet) do
                if not enemy or not enemy.Parent or not isEnemyAlive(enemy) then
                    releaseMob(enemy)
                    mobArrivedSet[enemy] = nil
                end
            end
            local pullingEnemy = nil
            for enemy, tween in pairs(_G.BringMobTweens) do
                if tween and tween.PlaybackState ~= Enum.PlaybackState.Completed then
                    pullingEnemy = enemy
                    break
                end
            end
            if pullingEnemy then
                task.wait(0.1)
                continue
            end
            local targetEnemy = nil
            local targetDist = math.huge
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if not enemy or not enemy.Parent then continue end
                if not isEnemyAlive(enemy) then continue end
                local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                if hrp then
                    local dist = (playerRoot.Position - hrp.Position).Magnitude
                    if dist < targetDist then
                        targetDist = dist
                        targetEnemy = enemy
                    end
                end
            end
            if not targetEnemy then
                task.wait(1)
                continue
            end
            local targetHrp = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy:FindFirstChildWhichIsA("BasePart")
            if not targetHrp then
                task.wait(0.5)
                continue
            end
            local centerPos = targetHrp.Position
            local playerLevel = 9999
            local dataLevel = player:FindFirstChild("Data")
            if dataLevel and dataLevel:FindFirstChild("Level") then
                playerLevel = dataLevel.Level.Value
            end
            local closestOther = nil
            local closestDist = _G.BringMobMaxDistance + 1
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if enemy == targetEnemy then continue end
                if not enemy or not enemy.Parent then continue end
                if not isEnemyAlive(enemy) then
                    if mobArrivedSet[enemy] then
                        releaseMob(enemy)
                        mobArrivedSet[enemy] = nil
                    end
                    continue
                end
                if mobArrivedSet[enemy] then continue end
                if _G.BringMobTweens[enemy] then continue end
                local enemyLevel = getEnemyLevel(enemy) or 0
                if enemyLevel >= playerLevel then continue end
                local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                if not hrp then continue end
                local dist = (centerPos - hrp.Position).Magnitude
                if dist <= _G.BringMobMaxDistance and dist < closestDist then
                    closestDist = dist
                    closestOther = enemy
                end
            end
            if closestOther then
                local otherHrp = closestOther:FindFirstChild("HumanoidRootPart") or closestOther:FindFirstChildWhichIsA("BasePart")
                if not otherHrp then
                    mobArrivedSet[closestOther] = true
                    task.wait(0.2)
                    continue
                end
                setMobNoclip(closestOther, true)
                local humanoid = closestOther:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = true
                    otherHrp.Anchored = false
                end
                local pullTargetPos = centerPos + Vector3.new(0, BRING_MOB_HEIGHT, 0)
                local distance = (otherHrp.Position - pullTargetPos).Magnitude
                local tweenTime = math.clamp(distance / BRING_MOB_SPEED, 0.2, 3)
                local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(otherHrp, tweenInfo, { CFrame = CFrame.new(pullTargetPos) })
                _G.BringMobTweens[closestOther] = tween
                tween:Play()
                Notification.new({ Title = "Bring Mob", Description = "Pulling " .. closestOther.Name, Duration = 2 })
                local startWait = tick()
                while tween.PlaybackState ~= Enum.PlaybackState.Completed and tick() - startWait < 5 do
                    task.wait(0.05)
                end
                local finalDist = (otherHrp.Position - centerPos).Magnitude
                if finalDist <= 10 then
                    Notification.new({ Title = "Bring Mob", Description = closestOther.Name .. " arrived", Duration = 1 })
                else
                    Notification.new({ Title = "Bring Mob", Description = "Pull failed", Duration = 2 })
                end
                releaseMob(closestOther)
                mobArrivedSet[closestOther] = true
                _G.BringMobTweens[closestOther] = nil
                task.wait(0.5)
            else
                task.wait(1)
            end
        end
        for enemy, _ in pairs(_G.BringMobTweens) do releaseMob(enemy) end
        for enemy, _ in pairs(mobArrivedSet) do releaseMob(enemy) end
        mobArrivedSet = {}
        _G.BringMobTweens = {}
        bringMobTask = nil
        Notification.new({ Title = "Bring Mob", Description = "Stopped", Duration = 2 })
    end)
end
local function stopBringMob()
    _G.BringMobEnabled = false
    if bringMobTask then task.cancel(bringMobTask) bringMobTask = nil end
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            releaseMob(enemy)
            pcall(function() enemy:SetAttribute("BringMobTracked", nil) end)
        end
    end
    for enemy, _ in pairs(mobArrivedSet) do
        releaseMob(enemy)
        pcall(function() enemy:SetAttribute("BringMobTracked", nil) end)
    end
    mobArrivedSet = {}
    _G.BringMobTweens = {}
end

-- ===== AUTO FARM BOSS (ใหม่ ปลอดภัย) =====
local function cleanBossName(name)
    if not name then return "" end
    local cleaned = name:gsub("%[Boss%]", ""):gsub("%[Lv[.]?%s*%d+%]", ""):gsub("%[Level%s*%d+%]", ""):gsub("%(.*%)", "")
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
    return cleaned
end

local function getBossListFromSpawns()
    local list = {}
    local ok, origin = pcall(function() return workspace:FindFirstChild("_WorldOrigin") end)
    if not ok or not origin then return list end
    local ok2, spawns = pcall(function() return origin:FindFirstChild("EnemySpawns") end)
    if not ok2 or not spawns then return list end
    for _, spawn in ipairs(spawns:GetChildren()) do
        if spawn:IsA("Model") and string.find(spawn.Name, "%[Boss%]") then
            local clean = cleanBossName(spawn.Name)
            if clean ~= "" then table.insert(list, clean) end
        end
    end
    return list
end

local function getBossSpawnPosition(bossName)
    local ok, origin = pcall(function() return workspace:FindFirstChild("_WorldOrigin") end)
    if not ok or not origin then return nil end
    local ok2, spawns = pcall(function() return origin:FindFirstChild("EnemySpawns") end)
    if not ok2 or not spawns then return nil end
    local cleanTarget = cleanBossName(bossName)
    for _, spawn in ipairs(spawns:GetChildren()) do
        if spawn:IsA("Model") then
            local cleanSpawn = cleanBossName(spawn.Name)
            if cleanSpawn == cleanTarget then
                return getPosition(spawn)
            end
        end
    end
    return nil
end

local function findAliveBoss(bossName)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local cleanTarget = cleanBossName(bossName)
    for _, enemy in ipairs(enemies:GetChildren()) do
        if enemy:IsA("Model") and isEnemyAlive(enemy) then
            local enemyClean = cleanBossName(enemy.Name)
            if enemyClean == cleanTarget then
                return enemy
            end
        end
    end
    return nil
end

local autoFarmBossTask = nil
local function startAutoFarmBoss()
    if autoFarmBossTask then return end
    if not _G.SelectedBossName or _G.SelectedBossName == "" then
        Notification.new({ Title = "Auto Boss", Description = "No boss selected", Duration = 2 })
        return
    end
    autoFarmBossTask = task.spawn(function()
        local bossName = _G.SelectedBossName
        local spawnPos = getBossSpawnPosition(bossName)
        if not spawnPos then
            Notification.new({ Title = "Auto Boss", Description = "Spawn not found for " .. bossName, Duration = 2 })
            _G.AutoFarmBossEnabled = false
            autoFarmBossTask = nil
            return
        end
        while _G.AutoFarmBossEnabled do
            -- 1. เดินทางไปจุดเกิด
            local character = game.Players.LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - spawnPos).Magnitude > 10 then
                Notification.new({ Title = "Auto Boss", Description = "Moving to spawn: " .. bossName, Duration = 2 })
                moveTo(spawnPos, nil, "BossSpawn", false, true)
            end
            -- 2. รอให้บอสเกิด
            local boss = nil
            local waitTime = 0
            while _G.AutoFarmBossEnabled and not boss do
                boss = findAliveBoss(bossName)
                if not boss then
                    task.wait(1)
                    waitTime = waitTime + 1
                    if waitTime > 60 then
                        Notification.new({ Title = "Auto Boss", Description = "Boss not spawning, retrying...", Duration = 2 })
                        break
                    end
                end
            end
            if not boss then
                task.wait(2)
                goto continue
            end
            Notification.new({ Title = "Auto Boss", Description = bossName .. " found! Engaging.", Duration = 2 })
            -- 3. ไล่ตามและโจมตี (บินเหนือหัว)
            local followTask = task.spawn(function()
                while _G.AutoFarmBossEnabled and boss and boss.Parent and isEnemyAlive(boss) do
                    local char = game.Players.LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local bossRoot = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChildWhichIsA("BasePart")
                    if not hrp or not bossRoot then
                        task.wait(0.1)
                        continue
                    end
                    local height = _G.FarmAuraHeight or 50
                    local targetPos = bossRoot.Position + Vector3.new(0, height, 0)
                    local dist = (hrp.Position - targetPos).Magnitude
                    local bv = hrp:FindFirstChild("BossFollowBV")
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "BossFollowBV"
                        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        bv.Parent = hrp
                    end
                    if dist > 3 then
                        local dir = (targetPos - hrp.Position).Unit
                        local speed = math.clamp(dist * 6, 30, SPEED)
                        bv.Velocity = dir * speed
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                    damageEnemy(boss)
                    task.wait(0.05)
                end
            end)
            while _G.AutoFarmBossEnabled and boss and boss.Parent and isEnemyAlive(boss) do
                task.wait(0.5)
            end
            task.cancel(followTask)
            local char = game.Players.LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = hrp:FindFirstChild("BossFollowBV")
                    if bv then bv:Destroy() end
                end
            end
            if boss and not isEnemyAlive(boss) then
                Notification.new({ Title = "Auto Boss", Description = bossName .. " defeated. Waiting for respawn.", Duration = 2 })
                task.wait(5)
            else
                task.wait(2)
            end
            ::continue::
        end
        autoFarmBossTask = nil
        _G.AutoFarmBossEnabled = false
        Notification.new({ Title = "Auto Boss", Description = "Stopped", Duration = 2 })
    end)
end

local function stopAutoFarmBoss()
    _G.AutoFarmBossEnabled = false
    if autoFarmBossTask then
        task.cancel(autoFarmBossTask)
        autoFarmBossTask = nil
    end
    local char = game.Players.LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("BossFollowBV")
            if bv then bv:Destroy() end
        end
    end
end

-- ===== UI สร้างทันที (ไม่มี task.wait ขัดจังหวะ) =====
local Windows = NothingLibrary.new({ Title = "Easter Event Farm", Description = "FrostByte | by Arrays", Keybind = Enum.KeyCode.LeftControl, Logo = 'http://www.roblox.com/asset/?id=18898582662' })

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
ConfigSection:NewSlider({ Title = "Tween Speed", Min = 100, Max = 400, Default = 300, Callback = function(Value) SPEED = Value end })
ConfigSection:NewSlider({ Title = "Chest Wait Time (ms)", Min = 10, Max = 500, Default = 10, Callback = function(Value) _G.ChestWaitTime = Value / 1000 end })
ConfigSection:NewToggle({ Title = "Auto Jump", Default = true, Callback = function(Value) _G.AutoJumpEnabled = Value end })

local CombatSection = SettingsTab:NewSection({ Title = "Combat", Icon = "rbxassetid://7743869054", Position = "Right" })
CombatSection:NewToggle({ Title = "Damage Aura (Enemies)", Default = false, Callback = function(Value) _G.DamageAuraEnabled = Value; if Value then startDamageAura() else stopDamageAura() end end })
CombatSection:NewToggle({ Title = "Damage Aura (Players)", Default = false, Callback = function(Value) _G.DamageAuraPlayersEnabled = Value; if Value then startDamagePlayerAura() else stopDamagePlayerAura() end end })

local AutoCombatTab = Windows:NewTab({ Title = "Auto Combat", Description = "Follow & Pull Mobs", Icon = "rbxassetid://7733960981" })
local AutoCombatSection = AutoCombatTab:NewSection({ Title = "Auto Combat Control", Icon = "rbxassetid://7743869054", Position = "Left" })
AutoCombatSection:NewToggle({ Title = "Farm Aura (Follow Enemy)", Default = false, Callback = function(v)
    _G.FarmAuraEnabled = v
    if v then startFarmAura() else stopFarmAura() end
end })
AutoCombatSection:NewSlider({ Title = "Follow Height (Y offset)", Min = 10, Max = 100, Default = 50, Callback = function(v) _G.FarmAuraHeight = v end })
AutoCombatSection:NewToggle({ Title = "Bring Mob (Pull Enemies)", Default = false, Callback = function(v)
    _G.BringMobEnabled = v
    if v then startBringMob() else stopBringMob() end
end })
AutoCombatSection:NewSlider({ Title = "Max Pull Distance", Min = 100, Max = 1200, Default = 500, Callback = function(v) _G.BringMobMaxDistance = v end })

-- ===== AUTO FARM BOSS UI (ปลอดภัย) =====
local BossSection = AutoCombatTab:NewSection({ Title = "Auto Farm Boss", Icon = "rbxassetid://7743869054", Position = "Right" })

local bossNames = getBossListFromSpawns()
_G.AutoFarmBossEnabled = false
_G.SelectedBossName = nil

if #bossNames > 0 then
    local bossDropdown = BossSection:NewDropdown({
        Title = "Select Boss",
        Data = bossNames,
        Default = bossNames[1],
        Callback = function(selected)
            _G.SelectedBossName = selected
        end
    })
    _G.SelectedBossName = bossNames[1]

    BossSection:NewToggle({ Title = "Farm Boss", Default = false, Callback = function(v)
        _G.AutoFarmBossEnabled = v
        if v then
            if not _G.SelectedBossName then
                Notification.new({ Title = "Auto Boss", Description = "Please select a boss first", Duration = 2 })
                _G.AutoFarmBossEnabled = false
                return
            end
            startAutoFarmBoss()
        else
            stopAutoFarmBoss()
        end
    end })
else
    BossSection:NewDropdown({
        Title = "Select Boss",
        Data = {"(No bosses found)"},
        Default = "(No bosses found)",
        Callback = function() end
    })
    BossSection:NewButton({ Title = "Refresh Boss List", Callback = function()
        local newList = getBossListFromSpawns()
        if #newList > 0 then
            Notification.new({ Title = "Auto Boss", Description = "Found " .. #newList .. " bosses. Please re-run script.", Duration = 3 })
        else
            Notification.new({ Title = "Auto Boss", Description = "Still no bosses.", Duration = 2 })
        end
    end })
end

local EquipSection = SettingsTab:NewSection({ Title = "Auto Equip", Icon = "rbxassetid://7743869054", Position = "Right" })
EquipSection:NewToggle({ Title = "Enable Auto Equip", Default = false, Callback = function(v)
    _G.AutoEquipEnabled = v
    if v then startAutoEquip() else stopAutoEquip() end
end })
EquipSection:NewDropdown({ Title = "Weapon Type", Data = {"Melee", "Sword", "Gun", "Fruit"}, Default = "Melee", Callback = function(v)
    _G.SelectedWeaponType = v
    if _G.AutoEquipEnabled then
        equipWeapon(v)
    end
end })

print("UI loaded successfully")
