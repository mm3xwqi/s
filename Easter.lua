local success, NothingLibrary = pcall(function()
    return loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
end)
if not success or type(NothingLibrary) ~= "table" then warn("Failed to load NothingLibrary: " .. tostring(NothingLibrary)) return end

local Notification = NothingLibrary.Notification()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local collectTargets

-- ===== GLOBALS =====
_G.AutoFarmEnabled = false
_G.QuestModeEnabled = false
_G.AutoJumpEnabled = true
_G.ChestBlacklist, _G.ShardBlacklist, _G.FruitBlacklist = {}, {}, {}
_G.ChestWaitTime = 0
_G.FarmMode = "random"
_G.AutoEquipEnabled = false
_G.SelectedWeaponType = "Melee"
_G.FarmAuraEnabled = false
_G.FarmAuraHeight = 50
_G.BringMobEnabled = false
_G.BringMobMaxDistance = 500
_G.BringMobMaxBatch = 3
_G.CurrentCircleIsland, _G.CurrentCircleIndex, _G.CurrentCircleRound = nil, 1, 1
_G.BringMobTweens = {}

local BRING_MOB_SPEED = 450
local BRING_MOB_HEIGHT = 0
local SPEED = 350
local THIRSTY_POS = Vector3.new(-1188, 10, 1296)
local MOLTEN_POS = Vector3.new(-5227, 200, -5497)
local FRIENDLY_POS = Vector3.new(-3053, 240, -10144)
local lastNotifiedTarget = nil

local ExcludedMaps = {
    FortBuilderPlacedSurfaces=true, FortBuilderPotentialSurfaces=true, Fishmen=true,
    MiniSky=true, RaidMap=true, ["WaterBase-Plane"]=true, IndraIsland=true,
    EventInstances=true, GhostShipInterior=true, GhostShip=true, Group=true,
}

local IslandRoutes = {
    ForgottenIsland = {Vector3.new(-2792.612,6.151,-9489.092),Vector3.new(-3319.633,6.156,-9406.701),Vector3.new(-3723.911,6.156,-9899.021),Vector3.new(-4394.900,122.851,-10715.470),Vector3.new(-3951.024,123.336,-11537.139),Vector3.new(-3087.306,281.155,-10971.061),Vector3.new(-2619.042,317.928,-10402.976),Vector3.new(-2512.719,6.156,-9541.841),Vector3.new(-2792.603,6.153,-9498.146)},
    Dressrosa = {Vector3.new(-382.166,73.071,217.102),Vector3.new(-281.807,73.071,215.005),Vector3.new(-281.125,73.002,395.918),Vector3.new(-490.960,73.002,386.886),Vector3.new(-225.164,370.002,547.916),Vector3.new(-228.155,370.002,822.693),Vector3.new(-560.809,370.002,820.613),Vector3.new(-562.119,370.002,549.666),Vector3.new(-184.705,73.002,1608.106),Vector3.new(-976.461,73.051,1526.228),Vector3.new(-1038.249,73.002,776.786),Vector3.new(-1871.038,73.002,448.122),Vector3.new(-2230.802,73.000,-263.154),Vector3.new(-1279.016,73.200,-764.401),Vector3.new(-207.002,73.000,-955.060),Vector3.new(867.520,73.002,-537.579),Vector3.new(1290.360,73.002,448.933),Vector3.new(1294.695,227.001,679.579),Vector3.new(1313.344,73.002,913.958),Vector3.new(1120.239,73.002,1597.852),Vector3.new(638.665,73.001,1771.723),Vector3.new(43.028,73.001,1719.230),Vector3.new(8.190,118.202,1241.055),Vector3.new(-490.229,118.202,1244.256)},
    GraveIsland = {Vector3.new(-5828.728,48.522,-664.228),Vector3.new(-6066.852,192.232,-1105.444),Vector3.new(-5636.473,179.535,-1354.075),Vector3.new(-5181.129,122.694,-928.748),Vector3.new(-5450.169,48.522,-696.602),Vector3.new(-5849.864,254.658,-415.851)},
    CircleIsland = {Vector3.new(-6061.861,80.430,-3842.269),Vector3.new(-6505.915,29.224,-4128.707),Vector3.new(-6935.194,81.363,-4653.365),Vector3.new(-6926.797,81.865,-5253.373),Vector3.new(-6797.530,61.106,-5617.261),Vector3.new(-6654.725,29.224,-6111.343),Vector3.new(-6352.736,85.321,-6204.132),Vector3.new(-5870.917,81.295,-5988.430),Vector3.new(-5624.509,29.209,-5444.182),Vector3.new(-5240.445,175.768,-5395.823),Vector3.new(-5347.583,219.409,-5958.787),Vector3.new(-4944.605,175.768,-6003.676),Vector3.new(-4488.611,175.768,-5613.406),Vector3.new(-4541.907,175.768,-5087.333),Vector3.new(-4694.477,175.768,-4540.690)},
    GreenBit = {Vector3.new(-2236.883,73.312,-2654.799),Vector3.new(-1724.826,73.004,-2893.391),Vector3.new(-1400.249,73.008,-3570.906),Vector3.new(-1926.891,72.384,-4440.530),Vector3.new(-2666.597,72.383,-4357.104),Vector3.new(-3391.223,73.009,-3521.937),Vector3.new(-3370.572,73.008,-3000.550),Vector3.new(-2855.085,73.005,-2447.016),Vector3.new(-2232.458,73.312,-2642.876)},
    SnowMountain = {Vector3.new(-66.768,8.518,-4954.692),Vector3.new(-219.630,2.465,-5446.675),Vector3.new(-8.583,12.464,-5862.012),Vector3.new(356.511,1.874,-6282.376),Vector3.new(829.074,42.684,-5960.455),Vector3.new(1253.673,52.489,-5812.354),Vector3.new(1851.510,76.472,-5532.257),Vector3.new(1798.399,51.739,-5070.247),Vector3.new(1619.942,45.633,-4480.307),Vector3.new(1200.262,5.410,-4264.189),Vector3.new(650.247,60.252,-4640.002),Vector3.new(786.209,429.464,-4785.480),Vector3.new(1281.058,428.017,-4553.571),Vector3.new(1651.708,429.464,-5374.660),Vector3.new(1152.688,429.464,-5610.507),Vector3.new(762.597,406.029,-5776.699),Vector3.new(243.972,414.211,-5962.319),Vector3.new(-39.410,413.141,-5164.655),Vector3.new(424.563,401.464,-4948.608)},
    IceCastle = {Vector3.new(5512.187,28.232,-6120.979),Vector3.new(5159.295,283.606,-6488.404),Vector3.new(5656.009,258.007,-6972.112),Vector3.new(6136.604,294.428,-7393.519),Vector3.new(6855.872,294.428,-7209.615),Vector3.new(7069.927,496.212,-6708.433),Vector3.new(6735.651,294.429,-6422.289),Vector3.new(6195.232,167.238,-6291.690),Vector3.new(5853.233,146.496,-6076.269)},
    DarkbeardArena = {Vector3.new(4074.911,13.390,-3800.093),Vector3.new(4233.600,30.160,-3353.118),Vector3.new(3962.525,42.552,-3018.284),Vector3.new(3431.821,13.391,-3244.932),Vector3.new(3340.237,30.324,-3686.796),Vector3.new(3597.007,13.391,-3902.315),Vector3.new(3841.871,32.851,-3933.289)},
}

-- ===== UTILS =====
local function notify(t, d, dur) Notification.new({Title=t, Description=d, Duration=dur or 2}) end
local function notifyOnce(target, t, d) if lastNotifiedTarget ~= target then lastNotifiedTarget = target notify(t, d) end end
local function getHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function getHumanoid(char) return char and char:FindFirstChildOfClass("Humanoid") end
local function isAlive(m) if not m or not m.Parent then return false end local h = getHumanoid(m) return h and h.Health > 0 end
local function isPlayerChar(m) for _, p in ipairs(Players:GetPlayers()) do if p.Character == m then return true end end return false end

local function getPos(obj)
    if not obj or not obj.Parent then return nil end
    if typeof(obj) == "Vector3" then return obj end
    if obj:IsA("Model") then local ok, p = pcall(function() return obj:GetPivot().Position end) return ok and p or nil
    elseif obj:IsA("BasePart") then return obj.Position
    else return obj.Position or (function() local ok, p = pcall(function() return obj:GetPivot().Position end) return ok and p end)() end
end

local function getRouteForIsland(name)
    if IslandRoutes[name] then return IslandRoutes[name] end
    local l = string.lower(name)
    for k, v in pairs(IslandRoutes) do if string.lower(k) == l then return v end end
    if l:find("dressrosa") then return IslandRoutes.Dressrosa end
    if l:find("forgotten") then return IslandRoutes.ForgottenIsland end
    if l:find("grave") then return IslandRoutes.GraveIsland end
end

local function getToolTip(tool)
    if not tool then return nil end
    local ok, tip = pcall(function() return tool.ToolTip end)
    if ok and tip and tip ~= "" then return tip end
    local c = tool:FindFirstChild("ToolTip")
    if c then return type(c.Value) == "string" and c.Value or nil end
    return tool:GetAttribute("ToolTip") or tool.Name
end

local function doJump()
    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game) task.wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

local function clickButton(btn)
    if not (btn and btn:IsA("GuiButton") and btn.Visible) then return end
    local p, s = btn.AbsolutePosition, btn.AbsoluteSize
    local cx, cy = p.X + s.X/2, p.Y + s.Y/2 + 58
    VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0) task.wait(0.05)
    VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
end

local function getSpecialEgg()
    local c = LP.Character
    for _, name in ipairs({"Falling Sky Egg","Thirsty Egg","Molten Egg","Friendly Neighborhood Egg","Firefly Egg"}) do
        local f = LP.Backpack:FindFirstChild(name) or (c and c:FindFirstChild(name))
        if f then return f end
    end
end

local function hasPriorityTarget()
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and (v.Name == "Shard" or v.Name == "EasterShard") and not _G.ShardBlacklist[v] then return true end
    end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then return true end
    end
    local ff = workspace:FindFirstChild("Fruit ")
    if ff then for _, f in ipairs(ff:GetChildren()) do if f.Parent and not _G.FruitBlacklist[f] then return true end end end
    return false
end

local function hasAnyTarget()
    if _G.QuestModeEnabled and getSpecialEgg() then return false end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and (v.Name=="Shard" or v.Name=="EasterShard") and not _G.ShardBlacklist[v] then return true end
    end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then return true end
    end
    local cm = workspace:FindFirstChild("ChestModels")
    if cm then for _, v in ipairs(cm:GetChildren()) do if v.Parent and not _G.ChestBlacklist[v] then return true end end end
    for _, o in ipairs(workspace:GetDescendants()) do
        if o.Parent and (o.Name=="EasterChest" or o.Name=="Chest") and not _G.ChestBlacklist[o] then return true end
    end
    local ff = workspace:FindFirstChild("Fruit ")
    if ff then for _, f in ipairs(ff:GetChildren()) do if f.Parent and not _G.FruitBlacklist[f] then return true end end end
    return false
end

local function getNextIsland()
    local t = {}
    for _, i in ipairs(workspace.Map:GetChildren()) do
        if i:IsA("Model") and not ExcludedMaps[i.Name] then table.insert(t, i) end
    end
    return #t > 0 and t[math.random(1, #t)] or nil
end

local function getClosestEnemy()
    local hrp = getHRP(LP.Character)
    if not hrp then return nil end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local closest, closestDist = nil, math.huge
    for _, e in ipairs(enemies:GetChildren()) do
        if e and e.Parent and isAlive(e) then
            local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (hrp.Position - p.Position).Magnitude
                if d < closestDist then closestDist = d closest = {enemy=e, part=p, dist=d} end
            end
        end
    end
    return closest
end

local function getEnemyLevel(e)
    if not e then return nil end
    local data = e:FindFirstChild("Data")
    if data then local l = data:FindFirstChild("Level") if l and l.Value then return l.Value end end
    local a = e:GetAttribute("Level") if a then return a end
    local l = e:FindFirstChild("Level") if l and l.Value then return l.Value end
    return tonumber(e.Name:match("%d+"))
end

-- ===== NOCLIP =====
local noclipLoop, Clip = nil, true
local function enableNoclip()
    Clip = false
    if noclipLoop then noclipLoop:Disconnect() end
    noclipLoop = RunService.Heartbeat:Connect(function()
        if Clip then return end
        local c = LP.Character if not c then return end
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end
    end)
end
local function disableNoclip() Clip = true if noclipLoop then noclipLoop:Disconnect() noclipLoop = nil end end

-- ===== ANTI SIT =====
local antiSitTask = nil
local function enableAntiSit()
    if antiSitTask then return end
    antiSitTask = task.spawn(function()
        while _G.AutoFarmEnabled do
            local h = getHumanoid(LP.Character)
            if h and h.Sit then h.Sit = false h:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
            task.wait(0.2)
        end
    end)
end
local function disableAntiSit() if antiSitTask then task.cancel(antiSitTask) antiSitTask = nil end end

-- ===== AUTO EQUIP =====
local autoEquipTask = nil
local function equipWeapon(wt)
    local c = LP.Character if not c then return end
    local function match(tool)
        local tip = getToolTip(tool)
        return tip and string.find(string.lower(tip), string.lower(wt))
    end
    local tool = nil
    for _, t in ipairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and match(t) then tool = t break end end
    if not tool and c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and match(t) then tool = t break end end end
    if tool then
        local h = getHumanoid(c)
        if h then
            if tool.Parent == LP.Backpack then tool.Parent = c task.wait(0.1) end
            h:EquipTool(tool)
            notify("Auto Equip", "Equipped " .. tool.Name)
        end
    else notify("Auto Equip", "No " .. wt .. " tool found!") end
end
local function startAutoEquip()
    if autoEquipTask then return end
    autoEquipTask = task.spawn(function()
        while _G.AutoEquipEnabled do
            local c = LP.Character
            local equipped = nil
            if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then equipped = t break end end end
            if not equipped then equipWeapon(_G.SelectedWeaponType) task.wait(0.5)
            else
                local tip = getToolTip(equipped)
                if not tip or not string.find(string.lower(tip), string.lower(_G.SelectedWeaponType)) then
                    equipped.Parent = LP.Backpack task.wait(0.2) equipWeapon(_G.SelectedWeaponType)
                end
            end
            task.wait(1)
        end
        autoEquipTask = nil
    end)
end
local function stopAutoEquip() _G.AutoEquipEnabled = false if autoEquipTask then task.cancel(autoEquipTask) autoEquipTask = nil end end

-- ===== COLLECTIBLE =====
local function getClosestCollectible()
    local hrp = getHRP(LP.Character) if not hrp then return nil end
    local closest, closestDist = nil, math.huge
    local function check(inst, type_)
        local pos = getPos(inst) if not pos then return end
        local d = (hrp.Position - pos).Magnitude
        if d < closestDist then closestDist = d closest = {type=type_, instance=inst, position=pos, distance=d} end
    end
    local ff = workspace:FindFirstChild("Fruit ")
    if ff then for _, f in ipairs(ff:GetChildren()) do if f.Parent and not _G.FruitBlacklist[f] then check(f, "Fruit") end end end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and (v.Name=="Shard" or v.Name=="EasterShard") and not _G.ShardBlacklist[v] then check(v, "Shard") end
    end
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then check(v, "Egg") end
    end
    local cm = workspace:FindFirstChild("ChestModels")
    if cm then
        for _, v in ipairs(cm:GetChildren()) do
            if v.Parent and not _G.ChestBlacklist[v] then
                local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if p then check(p, "Chest") end
            end
        end
    end
    for _, o in ipairs(workspace:GetDescendants()) do
        if o.Parent and (o.Name=="EasterChest" or o.Name=="Chest") and not _G.ChestBlacklist[o] then
            local p = o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or o
            if p then check(p, "Chest") end
        end
    end
    return closest
end

-- ===== MOVE TO =====
local function moveTo(targetPos, targetInst, targetType, dynamic, enableJump)
    if dynamic == nil then dynamic = true end
    if enableJump == nil then enableJump = false end
    if not targetPos and not targetInst then return false end
    if not targetPos then local p = getPos(targetInst) if p then targetPos = p end end
    local c = LP.Character
    local hrp = getHRP(c) if not hrp then return false end
    local old = hrp:FindFirstChild("Lock") if old then old:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "Lock" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
    local checkTimer, interrupted, lastJump = 0, false, 0
    while _G.AutoFarmEnabled do
        local hrpNow = getHRP(LP.Character) if not hrpNow then break end
        if _G.QuestModeEnabled and getSpecialEgg() and targetType ~= "Quest" then break end
        if targetInst and targetInst.Parent then local p = getPos(targetInst) if p then targetPos = p end end
        if not targetPos then break end
        local dist = (hrpNow.Position - targetPos).Magnitude
        if dist < 3 then break end
        if enableJump and _G.AutoJumpEnabled and dist < 15 then
            local now = tick() if now - lastJump > 0.3 then doJump() lastJump = now end
        end
        if dynamic then
            checkTimer = checkTimer + task.wait()
            if checkTimer >= 0.2 then
                checkTimer = 0
                local cl = getClosestCollectible()
                if cl then
                    local dc = (hrpNow.Position - cl.position).Magnitude
                    if dc < (targetPos - hrpNow.Position).Magnitude - 5 then interrupted = true break end
                end
            end
        else task.wait() end
        if not _G.AutoFarmEnabled then break end
        bv.Velocity = (targetPos - hrpNow.Position).Unit * SPEED
    end
    pcall(function() bv.Velocity = Vector3.zero end) task.wait(0.05) pcall(function() bv:Destroy() end)
    return interrupted
end

-- ===== FRUIT =====
local function processFruit(tool)
    if _G.FruitBlacklist[tool] then return end
    _G.FruitBlacklist[tool] = true
    local name = tool.Name
    local ok = pcall(function()
        RS:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("StoreFruit", name:gsub(" Fruit$",""), tool)
    end)
    notify("Fruit", (ok and "Stored " or "Failed: ") .. name)
end

-- ===== EGG DELIVERY =====
local function holdInPlace(hrp, pos, fn)
    local bv = Instance.new("BodyVelocity") bv.Name="HoldBV" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero bv.Parent=hrp
    local bp = Instance.new("BodyPosition") bp.Name="HoldBP" bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge) bp.P=10000 bp.Position=pos bp.Parent=hrp
    fn(bp)
    pcall(function() bv:Destroy() end) pcall(function() bp:Destroy() end)
end

local function deliverFallingSkyEgg(egg)
    local c = LP.Character local hrp = getHRP(c) if not hrp then return end
    local h = getHumanoid(c)
    if egg.Parent ~= c and h then h:EquipTool(egg) task.wait(0.3) end
    local btn = LP.PlayerGui.Main.Dialogue:FindFirstChild("Option1")
    local dropPos = Vector3.new(hrp.Position.X, hrp.Position.Y+100, hrp.Position.Z)
    holdInPlace(hrp, dropPos, function(bp)
        local t, elapsed = 10, 0
        while _G.AutoFarmEnabled and _G.QuestModeEnabled and egg.Parent == c and elapsed < t do
            clickButton(btn) task.wait(0.2) elapsed += 0.2 bp.Position = dropPos
        end
        local w = 0 while w < 10 and _G.AutoFarmEnabled do task.wait(0.5) w += 0.5 bp.Position = dropPos end
    end)
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
            notify("Quest","Collecting landed egg") moveTo(getPos(v), v, "Egg", false, true) break
        end
    end
end

local function deliverEggAndWaitForEgg(targetPos, egg, btn)
    moveTo(targetPos, nil, "Quest", false, false)
    local c = LP.Character local hrp = getHRP(c) if not hrp then return end
    holdInPlace(hrp, hrp.Position, function(bp)
        local dropPos = hrp.Position
        local elapsed, eggSpawned = 0, false
        while _G.AutoFarmEnabled and _G.QuestModeEnabled and egg.Parent == c and elapsed < 10 do
            clickButton(btn) task.wait(0.2) elapsed += 0.2 bp.Position = dropPos
        end
        local ws = tick()
        while _G.AutoFarmEnabled and tick()-ws < 15 do
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then eggSpawned = true break end
            end
            if eggSpawned then break end
            task.wait(0.5) bp.Position = dropPos
        end
    end)
    local hrp2 = getHRP(LP.Character)
    if hrp2 then
        local closest, cd = nil, math.huge
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                local p = getPos(v) if p then local d = (hrp2.Position-p).Magnitude if d < cd then cd=d closest=v end end
            end
        end
        if closest then notify("Quest","Collecting spawned egg") moveTo(getPos(closest), closest, "Egg", false, true) end
    end
end

local function deliverEggWithMove(targetPos, egg, btn)
    moveTo(targetPos, nil, "Quest", false, false)
    local c = LP.Character local hrp = getHRP(c) if not hrp then return end
    holdInPlace(hrp, hrp.Position, function(bp)
        local dropPos = hrp.Position
        local elapsed = 0
        while _G.AutoFarmEnabled and _G.QuestModeEnabled and egg.Parent == c and elapsed < 10 do
            clickButton(btn) task.wait(0.2) elapsed += 0.2 bp.Position = dropPos
        end
        local ws, spawned = tick(), false
        while _G.AutoFarmEnabled and tick()-ws < 10 do
            if hasPriorityTarget() then spawned = true break end
            task.wait(0.5) bp.Position = dropPos
        end
        if spawned then notify("Quest","Targets spawned!") end
    end)
    while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
end

local function deliverFriendlyEgg(egg)
    local c = LP.Character local hrp = getHRP(c) if not hrp then return end
    local npc = workspace.NPCs:FindFirstChild("Forgotten Quest Giver")
    moveTo(getPos(npc) or FRIENDLY_POS, nil, "Quest", false, false)
    hrp = getHRP(LP.Character) if not hrp then return end
    holdInPlace(hrp, hrp.Position, function(bp)
        if egg.Parent == c then
            RS.Modules.Net["RF/EasterServiceRF"]:InvokeServer("NPC.TravelingQuest", npc)
        end
        task.wait(5)
    end)
end

-- ===== COLLECT TARGETS =====
collectTargets = function()
    if not isAlive(LP.Character) then return false end
    if _G.QuestModeEnabled and getSpecialEgg() then return false end
    local hrp = getHRP(LP.Character) if not hrp then return false end

    local ff = workspace:FindFirstChild("Fruit ")
    if ff then
        local cf, cd = nil, math.huge
        for _, f in ipairs(ff:GetChildren()) do
            if f.Parent and not _G.FruitBlacklist[f] then
                local p = getPos(f) if p then local d=(hrp.Position-p).Magnitude if d<cd then cd=d cf=f end end
            end
        end
        if cf then
            notifyOnce(cf,"Collect","Fruit") moveTo(getPos(cf), cf, "Fruit", false, true)
            _G.FruitBlacklist[cf] = true task.wait(1)
            local tool = nil
            for _, t in ipairs(LP.Backpack:GetChildren()) do if t.Name:find("Fruit") then tool=t break end end
            if not tool and LP.Character then for _, t in ipairs(LP.Character:GetChildren()) do if t:IsA("Tool") and t.Name:find("Fruit") then tool=t break end end end
            if tool then
                local h = getHumanoid(LP.Character) if h then h:EquipTool(tool) task.wait(0.5) end
                processFruit(tool) pcall(function() tool:Destroy() end)
            end
            return true
        end
    end

    local cs, csd = nil, math.huge
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and (v.Name=="Shard" or v.Name=="EasterShard") and not _G.ShardBlacklist[v] then
            local p = getPos(v) if p then local d=(hrp.Position-p).Magnitude if d<csd then csd=d cs=v end end
        end
    end
    if cs then notifyOnce(cs,"Collect","Shard") moveTo(getPos(cs), cs, "Shard", false, true) _G.ShardBlacklist[cs]=true return true end

    for _, v in ipairs(workspace:GetChildren()) do
        if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
            local p = getPos(v) if p then notifyOnce(v,"Collect","Egg") moveTo(p, v, "Egg", false, true) return true end
        end
    end

    local cm = workspace:FindFirstChild("ChestModels")
    if cm then
        local ct, cp, cd = nil, nil, math.huge
        for _, v in ipairs(cm:GetChildren()) do
            if v.Parent and not _G.ChestBlacklist[v] then
                local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                if p then local pos=getPos(p) if pos then local d=(hrp.Position-pos).Magnitude if d<cd then cd=d ct=v cp=pos end end end
            end
        end
        if ct then moveTo(cp, ct, "Chest", false, true) _G.ChestBlacklist[ct]=true if _G.ChestWaitTime>0 then task.wait(_G.ChestWaitTime) end return true end
    end

    for _, o in ipairs(workspace:GetDescendants()) do
        if o.Parent and (o.Name=="EasterChest" or o.Name=="Chest") and not _G.ChestBlacklist[o] then
            local p = o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or o
            if p then local pos=getPos(p) if pos then moveTo(pos, o, "Chest", false, true) _G.ChestBlacklist[o]=true if _G.ChestWaitTime>0 then task.wait(_G.ChestWaitTime) end return true end end
        end
    end
    return false
end

-- ===== BOUNDING BOX ROUTE =====
local function generateBoundingBoxRoute(island)
    local minX, minZ, maxX, maxZ, avgY, count = math.huge, math.huge, -math.huge, -math.huge, 0, 0
    for _, p in ipairs(island:GetDescendants()) do
        if p:IsA("BasePart") then
            local pos = p.Position
            minX=math.min(minX,pos.X) maxX=math.max(maxX,pos.X)
            minZ=math.min(minZ,pos.Z) maxZ=math.max(maxZ,pos.Z)
            avgY += pos.Y count += 1
        end
    end
    if count == 0 then return nil end
    avgY = avgY/count
    local pY = avgY+80
    local cx, cz = (minX+maxX)/2, (minZ+maxZ)/2
    local rx, rz = (maxX-minX)/2+30, (maxZ-minZ)/2+30
    return {
        Vector3.new(cx,pY,cz-rz), Vector3.new(cx+rx,pY,cz-rz), Vector3.new(cx+rx,pY,cz),
        Vector3.new(cx+rx,pY,cz+rz), Vector3.new(cx,pY,cz+rz), Vector3.new(cx-rx,pY,cz+rz),
        Vector3.new(cx-rx,pY,cz), Vector3.new(cx-rx,pY,cz-rz),
    }
end

-- ===== CIRCLE STEP =====
local function circleStep(route)
    if not route or #route == 0 then return false end
    if not isAlive(LP.Character) then return "dead" end
    if _G.CurrentCircleIndex > #route then
        _G.CurrentCircleRound += 1
        _G.CurrentCircleIndex = 1
        if _G.CurrentCircleRound > 2 then return "finished" end
        notify("Circle", "Round " .. _G.CurrentCircleRound .. " on " .. _G.CurrentCircleIsland.Name, 3)
    end
    local wp = route[_G.CurrentCircleIndex]
    if not wp then return false end
    notify("Circle", string.format("WP %d/%d R%d %s", _G.CurrentCircleIndex, #route, _G.CurrentCircleRound, _G.CurrentCircleIsland.Name), 2)
    local interrupted = moveTo(wp, nil, "Waypoint", true, false)
    if interrupted then while collectTargets() do task.wait(0.1) end return "continue" end
    if hasAnyTarget() then return "target_found" end
    _G.CurrentCircleIndex += 1
    return "continue"
end

-- ===== MAIN FARM LOOP =====
local function StartFarming()
    task.spawn(function()
        task.spawn(function() while _G.AutoFarmEnabled do task.wait(15) _G.ChestBlacklist={} _G.ShardBlacklist={} end end)
        while _G.AutoFarmEnabled do
            while not isAlive(LP.Character) and _G.AutoFarmEnabled do
                lastNotifiedTarget = nil _G.CurrentCircleIsland = nil _G.CurrentCircleIndex = 1 _G.CurrentCircleRound = 1 task.wait(2)
            end
            if not _G.AutoFarmEnabled then break end
            local c = LP.Character
            local hrp = getHRP(c)
            local attempts = 0
            while (not c or not hrp) and attempts < 10 and _G.AutoFarmEnabled do
                task.wait(0.5) c = LP.Character hrp = getHRP(c) attempts += 1
            end
            if not hrp then task.wait(1) continue end

            local egg = getSpecialEgg()
            if egg and not _G.QuestModeEnabled then
                local h = getHumanoid(c) if h then h.Health = 0 task.wait(2) end continue
            end

            if _G.QuestModeEnabled and egg then
                local gui = LP.PlayerGui:FindFirstChild("Main")
                local dlg = gui and gui:FindFirstChild("Dialogue")
                local btn = dlg and dlg:FindFirstChild("Option1")
                local att = 0
                while (not btn or not btn.Visible) and att < 10 and _G.AutoFarmEnabled do
                    task.wait(0.5) gui = LP.PlayerGui:FindFirstChild("Main") dlg = gui and gui:FindFirstChild("Dialogue") btn = dlg and dlg:FindFirstChild("Option1") att += 1
                end
                c = LP.Character hrp = getHRP(c) if not hrp then task.wait(1) continue end
                local h = getHumanoid(c)
                if egg.Parent ~= c and h then h:EquipTool(egg) task.wait(0.3) end
                local n = egg.Name
                if n == "Firefly Egg" or n == "Friendly Neighborhood Egg" then
                    notifyOnce(egg,"Quest","Give "..n) deliverFriendlyEgg(egg)
                elseif n:find("Falling") then
                    notifyOnce(egg,"Quest","Drop "..n) deliverFallingSkyEgg(egg)
                elseif n:find("Thirsty") then
                    notifyOnce(egg,"Quest","Drop "..n) deliverEggAndWaitForEgg(THIRSTY_POS, egg, btn)
                elseif n:find("Molten") then
                    notifyOnce(egg,"Quest","Give "..n) deliverEggWithMove(MOLTEN_POS, egg, btn)
                else task.wait(1) end
                task.wait(1.5) _G.CurrentCircleIsland = nil
                while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
                continue
            end

            if not _G.CurrentCircleIsland or not _G.CurrentCircleIsland.Parent then
                _G.CurrentCircleIsland = getNextIsland()
                if not _G.CurrentCircleIsland then task.wait(1) continue end
                _G.CurrentCircleIndex = 1 _G.CurrentCircleRound = 1
                local ok, pivot = pcall(function() return _G.CurrentCircleIsland:GetPivot().Position end)
                if ok and _G.AutoFarmEnabled then
                    notifyOnce(_G.CurrentCircleIsland,"Move","Going to ".._G.CurrentCircleIsland.Name)
                    local int = moveTo(pivot + Vector3.new(0,80,0), nil, "Travel", true, false)
                    if int then while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end end
                end
                notify("Circle","Starting on ".._G.CurrentCircleIsland.Name.." (Round 1)", 3)
            end

            if _G.FarmMode == "random" then
                if hasAnyTarget() then collectTargets() else _G.CurrentCircleIsland = nil end
                task.wait(0.1) continue
            end

            local route = getRouteForIsland(_G.CurrentCircleIsland.Name) or generateBoundingBoxRoute(_G.CurrentCircleIsland)
            if not route or #route == 0 then
                if hasAnyTarget() then collectTargets() else _G.CurrentCircleIsland = nil end
                task.wait(0.5) continue
            end

            local result = circleStep(route)
            if result == "target_found" then while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end _G.CurrentCircleIndex += 1
            elseif result == "finished" then _G.CurrentCircleIsland = nil notify("Circle","No targets, moving to next island", 3) end
            task.wait(0.1)
        end
    end)
end

local damageAuraTask, damagePlayerAuraTask = nil, nil

local function getHitPart(model)
    for _, name in ipairs({"HumanoidRootPart","Head","UpperTorso","LowerTorso"}) do
        local p = model:FindFirstChild(name) if p then return p end
    end
    for _, p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then return p end end
end

local function fireHit(hitPart)
    local net = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
    if not net then return end
    local atk = net:FindFirstChild("RE/RegisterAttack")
    local hit = net:FindFirstChild("RE/RegisterHit")
    if atk and hit then pcall(function() atk:FireServer(0.5) hit:FireServer(hitPart, {}, "196f522a") end) end
end

-- ===== DAMAGE AURA =====
_G.DamageAuraEnabled = false
_G.DamageAuraPlayersEnabled = false
local function startDamageAura()
    if damageAuraTask then return end
    damageAuraTask = task.spawn(function()
        while _G.DamageAuraEnabled do
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                local aliveList = {}
                for _, e in ipairs(enemies:GetChildren()) do
                    if e and e.Parent and isAlive(e) then
                        local p = getHitPart(e)
                        if p then table.insert(aliveList, {enemy=e, part=p}) end
                    end
                end
                if #aliveList > 0 then
                    -- สุ่มเลือกตัวนึงแล้วตี จากนั้นวนไปเรื่อยๆ
                    local pick = aliveList[math.random(1, #aliveList)]
                    pcall(function() fireHit(pick.part) end)
                end
            end
            task.wait(0.05)
        end
        damageAuraTask = nil
    end)
end

local function stopDamageAura() if damageAuraTask then task.cancel(damageAuraTask) damageAuraTask = nil end end

local function startDamagePlayerAura()
    if damagePlayerAuraTask then return end
    damagePlayerAuraTask = task.spawn(function()
        while _G.DamageAuraPlayersEnabled do
            local cf = workspace:FindFirstChild("Characters")
            if cf then
                for _, c in ipairs(cf:GetChildren()) do
                    if c and c.Parent and c ~= LP.Character then
                        local p = getHitPart(c) if p then fireHit(p) end
                        task.wait(0.02)
                    end
                end
            end
            task.wait(0.1)
        end
        damagePlayerAuraTask = nil
    end)
end
local function stopDamagePlayerAura() if damagePlayerAuraTask then task.cancel(damagePlayerAuraTask) damagePlayerAuraTask = nil end end

-- ===== FARM AURA =====
local farmAuraTask, farmAuraActive = nil, false
local function startFarmAura()
    if farmAuraTask then return end
    farmAuraActive = true enableNoclip()
    farmAuraTask = task.spawn(function()
        while farmAuraActive do
            local c = LP.Character
            local hrp = getHRP(c) if not hrp then task.wait(0.5) continue end
            local old = hrp:FindFirstChild("FarmAuraBV") if old then old:Destroy() end
            local target = getClosestEnemy()
            if target then
                local tp = Vector3.new(target.part.Position.X, target.part.Position.Y + _G.FarmAuraHeight, target.part.Position.Z)
                local dist = (hrp.Position - tp).Magnitude
                local bv = Instance.new("BodyVelocity") bv.Name="FarmAuraBV" bv.MaxForce=Vector3.new(9e9,9e9,9e9)
                bv.Velocity = dist > 2 and (tp - hrp.Position).Unit * math.clamp(dist*8, 20, SPEED) or Vector3.zero
                bv.Parent = hrp task.wait(0.05)
            else
                local wt = nil
                local sf = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
                if sf then
                    local spawns = sf:GetChildren()
                    if #spawns > 0 then
                        local sp = spawns[math.random(1, #spawns)]
                        if sp:IsA("BasePart") then wt = sp.Position
                        elseif sp:IsA("Model") then local ok, p = pcall(function() return sp:GetPivot().Position end) if ok then wt = p end end
                    end
                end
                if not wt then
                    local parts = {}
                    for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and o ~= hrp then table.insert(parts, o) end end
                    if #parts > 0 then wt = parts[math.random(1,#parts)].Position end
                end
                if wt then
                    local locked = wt
                    local bv = Instance.new("BodyVelocity") bv.Name="FarmAuraBV" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Parent=hrp
                    while farmAuraActive do
                        hrp = getHRP(LP.Character) if not hrp then break end
                        local fe = getClosestEnemy()
                        if fe then
                            local ep = Vector3.new(fe.part.Position.X, fe.part.Position.Y+_G.FarmAuraHeight, fe.part.Position.Z)
                            bv.Velocity = (ep-hrp.Position).Unit * math.clamp((hrp.Position-ep).Magnitude*8, 20, SPEED)
                            task.wait(0.05) break
                        end
                        local d = (hrp.Position - locked).Magnitude
                        if d < 5 then break end
                        bv.Velocity = (locked-hrp.Position).Unit * math.clamp(d*5, 20, SPEED)
                        task.wait(0.1)
                    end
                    local bvc = hrp and hrp:FindFirstChild("FarmAuraBV") if bvc then bvc:Destroy() end
                else task.wait(0.5) end
            end
        end
    end)
end
local function stopFarmAura()
    farmAuraActive = false
    if farmAuraTask then task.cancel(farmAuraTask) farmAuraTask = nil end
    disableNoclip()
    local hrp = getHRP(LP.Character)
    if hrp then local bv = hrp:FindFirstChild("FarmAuraBV") if bv then bv:Destroy() end end
end

-- ===== BRING MOB =====
local bringMobTask, mobArrivedSet = nil, {}

local function setMobNoclip(enemy, enabled)
    if not enemy or not enemy.Parent then return end
    for _, p in ipairs(enemy:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = not enabled end end
end

local function releaseMob(enemy)
    if not enemy or not enemy.Parent then return end
    _G.BringMobTweens[enemy] = nil
    local h = getHumanoid(enemy) if h then h.PlatformStand = false end
    setMobNoclip(enemy, false)
    local hrp = enemy:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, n in ipairs({"BringMobBV","BringMobBP"}) do local o = hrp:FindFirstChild(n) if o then pcall(function() o:Destroy() end) end end
    end
end

local function startBringMob()
    if bringMobTask then return end
    mobArrivedSet = {} _G.BringMobTweens = {}
    notify("Bring Mob","Starting")
    bringMobTask = task.spawn(function()
        while _G.BringMobEnabled do
            local c = LP.Character
            local playerRoot = getHRP(c) if not playerRoot then task.wait(0.5) continue end
            local ef = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs") or workspace:FindFirstChild("Enemy")
            if not ef then notify("Bring Mob","No enemies folder!", 3) task.wait(3) continue end

            for enemy, _ in pairs(mobArrivedSet) do
                if not enemy or not enemy.Parent or not isAlive(enemy) then releaseMob(enemy) mobArrivedSet[enemy] = nil end
            end

            local targetEnemy, targetDist = nil, math.huge
            for _, e in ipairs(ef:GetChildren()) do
                if not e or not e.Parent then continue end
                if isPlayerChar(e) then continue end
                if not isAlive(e) then continue end
                local hrp = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                if hrp then
                    local d = (playerRoot.Position - hrp.Position).Magnitude
                    if d < targetDist then targetDist = d targetEnemy = e end
                end
            end
            if not targetEnemy then task.wait(1) continue end

            local targetHrp = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy:FindFirstChildWhichIsA("BasePart")
            if not targetHrp then task.wait(0.5) continue end

            local playerLevel = 9999
            local dl = LP:FindFirstChild("Data") if dl and dl:FindFirstChild("Level") then playerLevel = dl.Level.Value end

            local centerPos = targetHrp.Position
            local pullList = {}
            for _, e in ipairs(ef:GetChildren()) do
                if #pullList >= _G.BringMobMaxBatch then break end
                if e == targetEnemy or not e or not e.Parent then continue end
                if isPlayerChar(e) then continue end
                if not isAlive(e) then if mobArrivedSet[e] then releaseMob(e) mobArrivedSet[e]=nil end continue end
                if mobArrivedSet[e] or _G.BringMobTweens[e] then continue end
                local lvl = getEnemyLevel(e) or 0 if lvl >= playerLevel then continue end
                local hrp = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                if hrp and (centerPos - hrp.Position).Magnitude <= _G.BringMobMaxDistance then
                    table.insert(pullList, e)
                end
            end
            if #pullList == 0 then task.wait(0.5) continue end

            local stableList = {}
            for _, e in ipairs(pullList) do
                task.wait(0.05)
                if e and e.Parent and isAlive(e) then table.insert(stableList, e) end
            end
            if #stableList == 0 then task.wait(0.2) continue end

            -- เตรียม mob และเก็บ tween
            local tweenList = {}
            local playerHrp = getHRP(LP.Character)
            if not playerHrp then task.wait(0.5) continue end
            local destPos = playerHrp.Position + Vector3.new(0, BRING_MOB_HEIGHT, 0)

            for _, e in ipairs(stableList) do
                local h = getHumanoid(e)
                local hrp = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                if not hrp then continue end
                if h then h.PlatformStand = true end
                hrp.Anchored = false
                for _, p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end

                local dist = (hrp.Position - destPos).Magnitude
                local tweenTime = math.clamp(dist / BRING_MOB_SPEED, 0.1, 5)
                local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(destPos)})
                _G.BringMobTweens[e] = tween
                tween:Play()
                table.insert(tweenList, {enemy=e, hrp=hrp, tween=tween})
            end

            notify("Bring Mob","Pulling " .. #stableList .. " mobs")

            -- รอจนทุก tween เสร็จหรือถึงระยะแล้ว
            while _G.BringMobEnabled do
                -- อัปเดต dest ตาม player ตลอด
                playerHrp = getHRP(LP.Character)
                if not playerHrp then break end
                destPos = playerHrp.Position + Vector3.new(0, BRING_MOB_HEIGHT, 0)

                local allDone = true
                for _, data in ipairs(tweenList) do
                    local e, hrp, tween = data.enemy, data.hrp, data.tween
                    if not e or not e.Parent or not isAlive(e) then continue end
                    if not hrp or not hrp.Parent then continue end

                    -- noclip ทุก tick
                    for _, p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end

                    local d = (hrp.Position - destPos).Magnitude
                    if d > 15 then
                        -- ยังไม่ถึง ถ้า tween หยุดแล้วให้สร้างใหม่ไปหา destPos ปัจจุบัน
                        if tween.PlaybackState == Enum.PlaybackState.Completed or
                           tween.PlaybackState == Enum.PlaybackState.Stopped then
                            local newDist = (hrp.Position - destPos).Magnitude
                            local newTime = math.clamp(newDist / BRING_MOB_SPEED, 0.1, 5)
                            tween = TweenService:Create(hrp, TweenInfo.new(newTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(destPos)})
                            _G.BringMobTweens[e] = tween
                            data.tween = tween
                            tween:Play()
                        end
                        allDone = false
                    end
                end

                if allDone then break end
                task.wait(0.05)
            end

            -- ปล่อยทุกตัว
            for _, data in ipairs(tweenList) do
                local e, hrp, tween = data.enemy, data.hrp, data.tween
                pcall(function() tween:Cancel() end)
                if e and e.Parent then
                    local h = getHumanoid(e)
                    if h then h.PlatformStand = false end
                    for _, p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
                end
                if hrp and hrp.Parent then
                    pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
                end
                _G.BringMobTweens[e] = nil
                mobArrivedSet[e] = true
            end
            notify("Bring Mob", #stableList .. " mobs arrived")
            task.wait(0.5)
        end

        for e, _ in pairs(_G.BringMobTweens) do releaseMob(e) end
        for e, _ in pairs(mobArrivedSet) do releaseMob(e) end
        mobArrivedSet = {} _G.BringMobTweens = {} bringMobTask = nil
        notify("Bring Mob","Stopped")
    end)
end

local function stopBringMob()
    _G.BringMobEnabled = false
    if bringMobTask then task.cancel(bringMobTask) bringMobTask = nil end
    local ef = workspace:FindFirstChild("Enemies")
    if ef then for _, e in ipairs(ef:GetChildren()) do releaseMob(e) end end
    for e, _ in pairs(mobArrivedSet) do releaseMob(e) end
    mobArrivedSet = {} _G.BringMobTweens = {}
end

-- ===== UI =====
local Windows = NothingLibrary.new({ Title = "Easter Event", Description = "Blox fruits | by Index", Keybind = Enum.KeyCode.LeftControl, Logo = 'http://www.roblox.com/asset/?id=18898582662' })

local MainTab = Windows:NewTab({ Title = "Main", Description = "Easter Farm", Icon = "rbxassetid://4483362458" })
local FarmSection = MainTab:NewSection({ Title = "Farming", Icon = "rbxassetid://7743869054", Position = "Left" })
FarmSection:NewDropdown({ Title = "Farm Mode", Data = {"Random","Circle"}, Default = "Random", Callback = function(v) _G.FarmMode = v == "Random" and "random" or "circle" end })
FarmSection:NewToggle({ Title = "Enable Auto Farm", Default = false, Callback = function(v)
    _G.AutoFarmEnabled = v
    if v then StartFarming() enableNoclip() enableAntiSit()
    else
        lastNotifiedTarget = nil _G.CurrentCircleIsland = nil disableNoclip() disableAntiSit()
        local hrp = getHRP(LP.Character)
        if hrp then for _, n in ipairs({"Lock","HoverBV","HoverBP","QuestFloat"}) do local o = hrp:FindFirstChild(n) if o then pcall(function() o:Destroy() end) end end end
    end
end })
FarmSection:NewToggle({ Title = "Enable Quest Delivery", Default = false, Callback = function(v) _G.QuestModeEnabled = v lastNotifiedTarget = nil end })

local SettingsTab = Windows:NewTab({ Title = "Settings", Description = "Configuration", Icon = "rbxassetid://7733960981" })
local ConfigSection = SettingsTab:NewSection({ Title = "Configuration", Icon = "rbxassetid://7743869054", Position = "Left" })
ConfigSection:NewSlider({ Title = "Tween Speed", Min = 100, Max = 400, Default = 300, Callback = function(v) SPEED = v end })
ConfigSection:NewSlider({ Title = "Chest Wait Time (ms)", Min = 10, Max = 500, Default = 10, Callback = function(v) _G.ChestWaitTime = v/1000 end })
ConfigSection:NewToggle({ Title = "Auto Jump", Default = true, Callback = function(v) _G.AutoJumpEnabled = v end })

local CombatSection = SettingsTab:NewSection({ Title = "Combat", Icon = "rbxassetid://7743869054", Position = "Right" })
CombatSection:NewToggle({ Title = "Damage Aura (Enemies)", Default = false, Callback = function(v) _G.DamageAuraEnabled = v if v then startDamageAura() else stopDamageAura() end end })
CombatSection:NewToggle({ Title = "Damage Aura (Players)", Default = false, Callback = function(v) _G.DamageAuraPlayersEnabled = v if v then startDamagePlayerAura() else stopDamagePlayerAura() end end })

local EquipSection = SettingsTab:NewSection({ Title = "Auto Equip", Icon = "rbxassetid://7743869054", Position = "Right" })
EquipSection:NewToggle({ Title = "Enable Auto Equip", Default = false, Callback = function(v) _G.AutoEquipEnabled = v if v then startAutoEquip() else stopAutoEquip() end end })
EquipSection:NewDropdown({ Title = "Weapon Type", Data = {"Melee","Sword","Gun","Fruit"}, Default = "Melee", Callback = function(v) _G.SelectedWeaponType = v if _G.AutoEquipEnabled then equipWeapon(v) end end })

local MobTab = Windows:NewTab({ Title = "Farm Mobs", Description = "", Icon = "rbxassetid://7733960981" })
local MobSection = MobTab:NewSection({ Title = "Auto Combat Control", Icon = "rbxassetid://7743869054", Position = "Left" })
MobSection:NewToggle({ Title = "Farm Aura", Default = false, Callback = function(v) _G.FarmAuraEnabled = v if v then startFarmAura() else stopFarmAura() end end })
MobSection:NewSlider({ Title = "Y Offset", Min = 10, Max = 100, Default = 50, Callback = function(v) _G.FarmAuraHeight = v end })
MobSection:NewToggle({ Title = "Bring Mob", Default = false, Callback = function(v) _G.BringMobEnabled = v if v then startBringMob() else stopBringMob() end end })
MobSection:NewSlider({ Title = "Bring Distance", Min = 100, Max = 1200, Default = 500, Callback = function(v) _G.BringMobMaxDistance = v end })
MobSection:NewSlider({ Title = "Batch Pull Count (max 6)", Min = 1, Max = 6, Default = 3, Callback = function(v) _G.BringMobMaxBatch = v end })

print("UI loaded successfully")
