local ok, NothingLibrary = pcall(function() return loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))() end)
if not ok or type(NothingLibrary) ~= "table" then warn("Failed to load NothingLibrary: "..tostring(NothingLibrary)) return end

local Notification = NothingLibrary.Notification()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local collectTargets

_G.AutoFarmEnabled = false
_G.QuestModeEnabled = false
_G.AutoJumpEnabled = true
_G.ChestBlacklist, _G.ShardBlacklist, _G.FruitBlacklist = {}, {}, {}
_G.ChestWaitTime = 0
_G.FarmMode = "random"
_G.AutoEquipEnabled = false
_G.SelectedWeaponType = "Melee"
_G.FarmAuraEnabled = false
_G.FarmAuraHeight = 35
_G.BringMobEnabled = true
_G.BringMobMaxDistance = 500
_G.BringMobMaxBatch = 6
_G.CurrentCircleIsland, _G.CurrentCircleIndex, _G.CurrentCircleRound = nil, 1, 1
_G.BringMobTweens = {}
_G.CurrentFarmTarget = nil
_G.GunLockRange = 300

local BRING_MOB_SPEED = 450
local SPEED = 350
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

-- ============================================================
-- UTILS
-- ============================================================
local function notify(t, d, dur) Notification.new({Title=t, Description=d, Duration=dur or 2}) end
local function notifyOnce(target, t, d) if lastNotifiedTarget ~= target then lastNotifiedTarget = target notify(t, d) end end
local function getHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function getHumanoid(char) return char and char:FindFirstChildOfClass("Humanoid") end
local function isAlive(m) if not m or not m.Parent then return false end local h = getHumanoid(m) return h and h.Health > 0 end
local function isPlayerChar(m) for _, p in ipairs(Players:GetPlayers()) do if p.Character == m then return true end end return false end
local function getEnemyHRP(e) return e and e.Parent and (e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")) end

local function getPos(obj)
    if not obj or not obj.Parent then return nil end
    if typeof(obj) == "Vector3" then return obj end
    if obj:IsA("Model") then local ok2, p = pcall(function() return obj:GetPivot().Position end) return ok2 and p or nil
    elseif obj:IsA("BasePart") then return obj.Position end
    local ok2, p = pcall(function() return obj:GetPivot().Position end) return ok2 and p
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
    local ok2, tip = pcall(function() return tool.ToolTip end)
    if ok2 and tip and tip ~= "" then return tip end
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

-- Sealed Egg detection
local sealedEggBlacklist = {}
local sealedEggTargetIsland = nil

local function findSealedEgg()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "SealedShowdownEgg" and not sealedEggBlacklist[obj] then
            local primary = obj:FindFirstChild("_PrimaryPart")
            if primary then return obj, primary end
        end
    end
    return nil, nil
end

local function getNextIsland()
    local t = {}
    for _, i in ipairs(workspace.Map:GetChildren()) do
        if i:IsA("Model") and not ExcludedMaps[i.Name] then table.insert(t, i) end
    end
    return #t > 0 and t[math.random(1, #t)] or nil
end

local function getClosestEnemy()
    local hrp = getHRP(LP.Character) if not hrp then return nil end
    local enemies = workspace:FindFirstChild("Enemies") if not enemies then return nil end
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

local function getHitPart(model)
    for _, name in ipairs({"HumanoidRootPart","Head","UpperTorso","LowerTorso"}) do
        local p = model:FindFirstChild(name) if p then return p end
    end
    for _, p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then return p end end
end

-- ============================================================
-- NOCLIP
-- ============================================================
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

-- ============================================================
-- ANTI SIT
-- ============================================================
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

-- ============================================================
-- AUTO EQUIP
-- ============================================================
local autoEquipTask = nil
local function equipWeapon(wt)
    local c = LP.Character if not c then return end
    local function match(tool) local tip = getToolTip(tool) return tip and string.find(string.lower(tip), string.lower(wt)) end
    local tool = nil
    for _, t in ipairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and match(t) then tool = t break end end
    if not tool and c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and match(t) then tool = t break end end end
    if tool then
        local h = getHumanoid(c)
        if h then
            if tool.Parent == LP.Backpack then tool.Parent = c task.wait(0.1) end
            h:EquipTool(tool) notify("Auto Equip", "Equipped "..tool.Name)
        end
    else notify("Auto Equip", "No "..wt.." tool found!") end
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

-- ============================================================
-- COLLECTIBLE
-- ============================================================
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

-- ============================================================
-- MOVE TO
-- ============================================================
local function moveTo(targetPos, targetInst, targetType, dynamic, enableJump)
    if dynamic == nil then dynamic = true end
    if enableJump == nil then enableJump = false end
    if not targetPos and not targetInst then return false end
    if not targetPos then local p = getPos(targetInst) if p then targetPos = p end end
    local hrp = getHRP(LP.Character) if not hrp then return false end
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

-- ============================================================
-- FRUIT
-- ============================================================
local function processFruit(tool)
    if _G.FruitBlacklist[tool] then return end
    _G.FruitBlacklist[tool] = true
    local name = tool.Name
    local ok2 = pcall(function()
        RS:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("StoreFruit", name:gsub(" Fruit$",""), tool)
    end)
    notify("Fruit", (ok2 and "Stored " or "Failed: ")..name)
end

-- ============================================================
-- HOLD IN PLACE
-- ============================================================
local function holdInPlace(hrp, pos, fn)
    local bv = Instance.new("BodyVelocity") bv.Name="HoldBV" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero bv.Parent=hrp
    local bp = Instance.new("BodyPosition") bp.Name="HoldBP" bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge) bp.P=10000 bp.Position=pos bp.Parent=hrp
    fn(bp)
    pcall(function() bv:Destroy() end) pcall(function() bp:Destroy() end)
end

-- ============================================================
-- EGG DELIVERY
-- ============================================================

-- FALLING SKY EGG
-- drop ปุ๊บแล้วลอยค้าง รอไข่ falling sky egg เกิดใหม่ใน workspace จึงค่อยออก
local function deliverFallingSkyEgg(egg)
    local c = LP.Character local hrp = getHRP(c) if not hrp then return end
    local h = getHumanoid(c)
    if egg.Parent ~= c and h then h:EquipTool(egg) task.wait(0.3) end

    local btn = LP.PlayerGui.Main.Dialogue:FindFirstChild("Option1")
    local dropPos = Vector3.new(hrp.Position.X, hrp.Position.Y + 100, hrp.Position.Z)

    holdInPlace(hrp, dropPos, function(bp)
        bp.Position = dropPos

        -- กด drop จนไข่ออกจากมือ
        local elapsed = 0
        while _G.AutoFarmEnabled and _G.QuestModeEnabled and egg.Parent == c and elapsed < 15 do
            clickButton(btn)
            task.wait(0.2)
            elapsed += 0.2
            bp.Position = dropPos
        end

        -- ลอยค้างรอไข่ falling sky egg เกิดใน workspace (ไม่ limit เวลา)
        notify("Quest", "Dropped! Waiting for egg to fall...", 3)
        while _G.AutoFarmEnabled and _G.QuestModeEnabled do
            bp.Position = dropPos
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                    notify("Quest", "Falling egg appeared! Collecting...", 3)
                    return
                end
            end
            task.wait(0.3)
        end
    end)

    -- เก็บไข่ที่ตกลงมา
    local hrp2 = getHRP(LP.Character)
    if hrp2 then
        local closest, cd = nil, math.huge
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                local p = getPos(v) if p then local d = (hrp2.Position-p).Magnitude if d < cd then cd=d closest=v end end
            end
        end
        if closest then notify("Quest","Collecting landed egg") moveTo(getPos(closest), closest, "Egg", false, true) end
    end
end

-- FRIENDLY NEIGHBORHOOD EGG: tween ไปหา part ชื่อขึ้นต้น "Friendly Neighborhood Egg" ใน workspace
local function deliverFriendlyEgg(egg)
    local c = LP.Character local hrp = getHRP(c) if not hrp then return end
    local h = getHumanoid(c)
    if egg.Parent ~= c and h then h:EquipTool(egg) task.wait(0.3) end

    local targetPart = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:find("Friendly Neighborhood Egg") then
            targetPart = obj break
        end
    end

    if not targetPart then
        notify("Quest", "Friendly Egg part not found!", 3) return
    end

    notify("Quest", "Tweening to: "..targetPart.Name, 2)
    hrp = getHRP(LP.Character) if not hrp then return end
    local old = hrp:FindFirstChild("FriendlyLock") if old then old:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FriendlyLock" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
    while _G.AutoFarmEnabled do
        hrp = getHRP(LP.Character) if not hrp then break end
        if not targetPart or not targetPart.Parent then break end
        local dist = (hrp.Position - targetPart.Position).Magnitude
        if dist < 5 then break end
        bv.Velocity = (targetPart.Position - hrp.Position).Unit * SPEED
        task.wait(0.03)
    end
    pcall(function() bv.Velocity = Vector3.zero end) task.wait(0.1) pcall(function() bv:Destroy() end)

    hrp = getHRP(LP.Character) if not hrp then return end
    holdInPlace(hrp, hrp.Position, function(bp)
        if egg.Parent == c then
            pcall(function()
                local npc = workspace.NPCs:FindFirstChild("Forgotten Quest Giver")
                RS.Modules.Net["RF/EasterServiceRF"]:InvokeServer("NPC.TravelingQuest", npc)
            end)
        end
        task.wait(5)
    end)
end

-- THIRSTY EGG: tween ไปหา WaterBase-Plane ที่ใกล้ที่สุดโดยไม่กรองอะไร ลอยสูงกว่าน้ำเสมอ แล้ว drop
local function deliverThirstyEgg(egg)
    local c = LP.Character local hrp = getHRP(c) if not hrp then return end
    local gui = LP.PlayerGui:FindFirstChild("Main")
    local dlg = gui and gui:FindFirstChild("Dialogue")
    local btn = dlg and dlg:FindFirstChild("Option1")

    -- หา WaterBase-Plane ที่ใกล้ที่สุด ไม่กรองอะไรทั้งนั้น
    local closestWaterPart, closestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "WaterBase-Plane" and obj:IsA("BasePart") then
            local d = (hrp.Position - obj.Position).Magnitude
            if d < closestDist then closestDist = d closestWaterPart = obj end
        end
    end

    if not closestWaterPart then
        notify("Quest", "WaterBase-Plane not found!", 3) return
    end

    notify("Quest", "Tweening above Water (Thirsty Egg)", 2)

    -- tween ไปโดยให้ Y สูงกว่า water + 20 เสมอ
    hrp = getHRP(LP.Character) if not hrp then return end
    local old = hrp:FindFirstChild("ThirstyLock") if old then old:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "ThirstyLock" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
    while _G.AutoFarmEnabled do
        hrp = getHRP(LP.Character) if not hrp then break end
        if not closestWaterPart or not closestWaterPart.Parent then break end
        -- target คือ XZ ของ water แต่ Y สูงกว่า water เสมอ
        local targetPos = Vector3.new(
            closestWaterPart.Position.X,
            closestWaterPart.Position.Y + 20,
            closestWaterPart.Position.Z
        )
        local dist = (hrp.Position - targetPos).Magnitude
        if dist < 4 then bv.Velocity = Vector3.zero break end
        bv.Velocity = (targetPos - hrp.Position).Unit * SPEED
        task.wait(0.03)
    end
    pcall(function() bv.Velocity = Vector3.zero end) task.wait(0.1) pcall(function() bv:Destroy() end)

    hrp = getHRP(LP.Character) if not hrp then return end

    -- hold ลอยอยู่เหนือน้ำเสมอ แล้ว drop + รอไข่เกิด
    holdInPlace(hrp, hrp.Position, function(bp)
        local function getHoverPos()
            if closestWaterPart and closestWaterPart.Parent then
                return Vector3.new(closestWaterPart.Position.X, closestWaterPart.Position.Y + 20, closestWaterPart.Position.Z)
            end
            return bp.Position
        end
        bp.Position = getHoverPos()

        local elapsed, eggSpawned = 0, false
        while _G.AutoFarmEnabled and _G.QuestModeEnabled and egg.Parent == c and elapsed < 10 do
            bp.Position = getHoverPos()
            clickButton(btn)
            task.wait(0.2)
            elapsed += 0.2
        end
        local ws = tick()
        while _G.AutoFarmEnabled and tick()-ws < 15 do
            bp.Position = getHoverPos()
            for _, v in ipairs(workspace:GetChildren()) do
                if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                    eggSpawned = true break
                end
            end
            if eggSpawned then break end
            task.wait(0.5)
        end
    end)

    hrp = getHRP(LP.Character)
    if hrp then
        local closest2, cd = nil, math.huge
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                local p = getPos(v) if p then local d = (hrp.Position-p).Magnitude if d < cd then cd=d closest2=v end end
            end
        end
        if closest2 then notify("Quest","Collecting spawned egg") moveTo(getPos(closest2), closest2, "Egg", false, true) end
    end
end

-- MOLTEN EGG: หา LavaPart ใกล้ที่สุด hover สูงกว่า 15 แล้ว drop
local function deliverMoltenEgg(egg)
    local c = LP.Character local hrp = getHRP(c) if not hrp then return end
    local gui = LP.PlayerGui:FindFirstChild("Main")
    local dlg = gui and gui:FindFirstChild("Dialogue")
    local btn = dlg and dlg:FindFirstChild("Option1")

    local closestLava, closestDist = nil, math.huge
    local circleIsland = workspace.Map:FindFirstChild("CircleIsland")
    if circleIsland then
        local lavaParts = circleIsland:FindFirstChild("LavaParts")
        if lavaParts then
            for _, obj in ipairs(lavaParts:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local d = (hrp.Position - obj.Position).Magnitude
                    if d < closestDist then closestDist = d closestLava = obj end
                end
            end
        end
    end

    if not closestLava then notify("Quest", "LavaPart not found!", 3) return end

    local dropPos = Vector3.new(closestLava.Position.X, closestLava.Position.Y + 15, closestLava.Position.Z)
    notify("Quest", "Hovering above Lava (Molten Egg)", 2)

    hrp = getHRP(LP.Character) if not hrp then return end
    local old = hrp:FindFirstChild("MoltenLock") if old then old:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "MoltenLock" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
    while _G.AutoFarmEnabled do
        hrp = getHRP(LP.Character) if not hrp then break end
        local dist = (hrp.Position - dropPos).Magnitude
        if dist < 4 then break end
        bv.Velocity = (dropPos - hrp.Position).Unit * SPEED
        task.wait(0.03)
    end
    pcall(function() bv.Velocity = Vector3.zero end) task.wait(0.1) pcall(function() bv:Destroy() end)

    hrp = getHRP(LP.Character) if not hrp then return end
    holdInPlace(hrp, dropPos, function(bp)
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

-- ============================================================
-- COLLECT TARGETS
-- ============================================================
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

-- ============================================================
-- BOUNDING BOX ROUTE
-- ============================================================
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

-- ============================================================
-- SEALED EGG HELPERS
-- ============================================================
local function triggerProximityPrompt(part)
    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        for _, v in ipairs(part:GetDescendants()) do
            if v:IsA("ProximityPrompt") then prompt = v break end
        end
    end
    if prompt then fireproximityprompt(prompt) return true end
    return false
end

local function tweenToSealedEgg(targetPart)
    local hrp = getHRP(LP.Character) if not hrp then return false end
    local old = hrp:FindFirstChild("SealedEggLock") if old then old:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "SealedEggLock" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
    local arrived = false
    while _G.AutoFarmEnabled do
        hrp = getHRP(LP.Character) if not hrp then break end
        if not targetPart or not targetPart.Parent then break end
        if (hrp.Position - targetPart.Position).Magnitude < 5 then arrived = true break end
        bv.Velocity = (targetPart.Position - hrp.Position).Unit * SPEED
        task.wait(0.03)
    end
    pcall(function() bv.Velocity = Vector3.zero end) task.wait(0.05) pcall(function() bv:Destroy() end)
    return arrived
end

-- วน bounding box ทั่วเกาะหา SealedEgg ตรวจระหว่างเดินทางด้วย
local function searchIslandForSealedEgg(island)
    if not island or not island.Parent then return nil, nil end
    -- บินไปกึ่งกลางก่อน
    local ok2, pivot = pcall(function() return island:GetPivot().Position end)
    if ok2 and pivot then
        local hrp = getHRP(LP.Character) if not hrp then return nil, nil end
        local goPos = pivot + Vector3.new(0, 80, 0)
        local bv = Instance.new("BodyVelocity")
        bv.Name = "SealedEggLock" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
        while _G.AutoFarmEnabled do
            hrp = getHRP(LP.Character) if not hrp then pcall(function() bv:Destroy() end) return nil, nil end
            if (hrp.Position - goPos).Magnitude < 15 then break end
            bv.Velocity = (goPos - hrp.Position).Unit * SPEED
            task.wait(0.05)
            local e, p = findSealedEgg() if e then pcall(function() bv:Destroy() end) return e, p end
        end
        pcall(function() bv.Velocity = Vector3.zero end) task.wait(0.05) pcall(function() bv:Destroy() end)
        local e, p = findSealedEgg() if e then return e, p end
    end
    -- วน bounding box
    local route = generateBoundingBoxRoute(island)
    if not route or #route == 0 then return nil, nil end
    for _, wp in ipairs(route) do
        if not _G.AutoFarmEnabled then return nil, nil end
        local hrp = getHRP(LP.Character) if not hrp then return nil, nil end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "SealedEggLock" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
        while _G.AutoFarmEnabled do
            hrp = getHRP(LP.Character) if not hrp then pcall(function() bv:Destroy() end) return nil, nil end
            if (hrp.Position - wp).Magnitude < 8 then break end
            bv.Velocity = (wp - hrp.Position).Unit * SPEED
            task.wait(0.05)
            local e, p = findSealedEgg() if e then pcall(function() bv:Destroy() end) return e, p end
        end
        pcall(function() bv.Velocity = Vector3.zero end) task.wait(0.05) pcall(function() bv:Destroy() end)
        local e, p = findSealedEgg() if e then return e, p end
    end
    return nil, nil
end

-- ============================================================
-- CIRCLE STEP
-- ============================================================
local function circleStep(route)
    if not route or #route == 0 then return false end
    if not isAlive(LP.Character) then return "dead" end
    if _G.CurrentCircleIndex > #route then
        _G.CurrentCircleRound += 1
        _G.CurrentCircleIndex = 1
        if _G.CurrentCircleRound > 2 then return "finished" end
        notify("Circle", "Round ".._G.CurrentCircleRound.." on ".._G.CurrentCircleIsland.Name, 3)
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

-- ============================================================
-- MAIN FARM LOOP (รวม Sealed Egg ไว้ในนี้เลย)
-- ============================================================
local function StartFarming()
    task.spawn(function()
        -- Chat detect สำหรับ Sealed Egg (ทำงานตลอดที่ AutoFarm เปิด)
        local chatDetectConn = nil
        local TextChatService = game:GetService("TextChatService")
        pcall(function()
            chatDetectConn = TextChatService.MessageReceived:Connect(function(msg)
                if not _G.AutoFarmEnabled then return end
                local text = msg.Text or ""
                local lower = text:lower()
                if lower:find("sealed showdown egg") and lower:find("spawned") then
                    local islandName = text:match("[Ss]pawned on ([%w%s%-_]+)")
                        or text:match("[Ss]pawned at ([%w%s%-_]+)")
                    if islandName then
                        islandName = islandName:match("^%s*(.-)%s*$"):gsub("[%!%.]+$",""):match("^%s*(.-)%s*$")
                        sealedEggTargetIsland = islandName
                        sealedEggBlacklist = {}
                        notify("Sealed Egg", "Chat: Egg on "..islandName.."!", 4)
                    else
                        sealedEggBlacklist = {}
                        notify("Sealed Egg", "Chat: Egg spawned!", 3)
                    end
                end
            end)
        end)

        -- Blacklist reset loop
        task.spawn(function()
            while _G.AutoFarmEnabled do task.wait(15) _G.ChestBlacklist={} _G.ShardBlacklist={} end
        end)

        while _G.AutoFarmEnabled do
            -- ====================================================
            -- PRIORITY 1: Sealed Showdown Egg
            -- ====================================================
            local sealedEgg, sealedPrimary = findSealedEgg()
            if not sealedEgg and sealedEggTargetIsland then
                local targetName = sealedEggTargetIsland
                local island = workspace.Map:FindFirstChild(targetName)
                if not island then
                    for _, child in ipairs(workspace.Map:GetChildren()) do
                        if child:IsA("Model") and child.Name:lower():find(targetName:lower()) then island = child break end
                    end
                end
                if island then
                    notify("Sealed Egg", "Searching: "..island.Name, 3)
                    Clip = false
                    sealedEgg, sealedPrimary = searchIslandForSealedEgg(island)
                    Clip = true
                else
                    notify("Sealed Egg", "Island not found: "..targetName, 3)
                end
                sealedEggTargetIsland = nil
            end
            if sealedEgg and sealedPrimary then
                notify("Sealed Egg", "Found! Rushing...", 3)
                Clip = false
                local arrived = tweenToSealedEgg(sealedPrimary)
                Clip = true
                if arrived and sealedPrimary and sealedPrimary.Parent then
                    task.wait(0.1)
                    local success = triggerProximityPrompt(sealedPrimary)
                    notify("Sealed Egg", success and "Triggered!" or "No ProximityPrompt", 2)
                end
                sealedEggBlacklist[sealedEgg] = true
                task.wait(1)
                continue
            end

            -- ====================================================
            -- รอ character
            -- ====================================================
            while not isAlive(LP.Character) and _G.AutoFarmEnabled do
                lastNotifiedTarget = nil _G.CurrentCircleIsland = nil
                _G.CurrentCircleIndex = 1 _G.CurrentCircleRound = 1
                task.wait(2)
            end
            if not _G.AutoFarmEnabled then break end

            local c = LP.Character
            local hrp = getHRP(c)
            local attempts = 0
            while (not c or not hrp) and attempts < 10 and _G.AutoFarmEnabled do
                task.wait(0.5) c = LP.Character hrp = getHRP(c) attempts += 1
            end
            if not hrp then task.wait(1) continue end

            -- ====================================================
            -- PRIORITY 2: Quest Egg delivery
            -- ====================================================
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
                    task.wait(0.5)
                    gui = LP.PlayerGui:FindFirstChild("Main")
                    dlg = gui and gui:FindFirstChild("Dialogue")
                    btn = dlg and dlg:FindFirstChild("Option1")
                    att += 1
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
                    notifyOnce(egg,"Quest","Drop "..n) deliverThirstyEgg(egg)
                elseif n:find("Molten") then
                    notifyOnce(egg,"Quest","Give "..n) deliverMoltenEgg(egg)
                else task.wait(1) end
                task.wait(1.5) _G.CurrentCircleIsland = nil
                while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
                continue
            end

            -- ====================================================
            -- Circle / Random farm
            -- ====================================================
            if not _G.CurrentCircleIsland or not _G.CurrentCircleIsland.Parent then
                _G.CurrentCircleIsland = getNextIsland()
                if not _G.CurrentCircleIsland then task.wait(1) continue end
                _G.CurrentCircleIndex = 1 _G.CurrentCircleRound = 1
                local ok3, pivot = pcall(function() return _G.CurrentCircleIsland:GetPivot().Position end)
                if ok3 and _G.AutoFarmEnabled then
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
            if result == "target_found" then
                while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
                _G.CurrentCircleIndex += 1
            elseif result == "finished" then
                _G.CurrentCircleIsland = nil
                notify("Circle","No targets, moving to next island", 3)
            end
            task.wait(0.1)
        end

        -- cleanup chat detect
        if chatDetectConn then pcall(function() chatDetectConn:Disconnect() end) end
    end)
end

-- ============================================================
-- DAMAGE AURA
-- ============================================================
_G.DamageAuraEnabled = false
_G.DamageAuraPlayersEnabled = false
local damageAuraTask, damagePlayerAuraTask = nil, nil

local function getMeleeRemotes()
    local net = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
    if not net then return nil, nil end
    return net:FindFirstChild("RE/RegisterAttack"), net:FindFirstChild("RE/RegisterHit")
end
local function getGunRemote()
    return RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net") and RS.Modules.Net:FindFirstChild("RE/ShootGunEvent")
end
local function getWeaponInfo()
    local char = LP.Character
    local heldTool = char and (function() for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then return t end end end)()
    if not heldTool then local a, b = getMeleeRemotes() return a, b, "melee" end
    local leftClick = heldTool:FindFirstChild("LeftClickRemote")
    if leftClick and leftClick:IsA("RemoteEvent") then return leftClick, nil, "fruit" end
    local lowerTip = (getToolTip(heldTool) or heldTool.Name):lower()
    if lowerTip:find("gun") or lowerTip:find("pistol") or lowerTip:find("rifle")
        or lowerTip:find("shotgun") or lowerTip:find("bazooka") or lowerTip:find("cannon") then
        local shootRemote = getGunRemote()
        if shootRemote then return shootRemote, nil, "gun" end
    end
    local a, b = getMeleeRemotes() return a, b, "melee"
end
local function fireGunNormal(targetPart)
    if not targetPart or not targetPart.Parent then return end
    local remote = getGunRemote()
    if remote then
        local hitPart = targetPart.Parent:FindFirstChild("HumanoidRootPart") or getHitPart(targetPart.Parent) or targetPart
        pcall(function() remote:FireServer(hitPart.Position, {hitPart}) end)
    end
    local vp = workspace.CurrentCamera.ViewportSize
    local cx, cy = vp.X/2, vp.Y/2
    VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0) task.wait(0.05)
    VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
end
local function fireDamage(targetPart)
    if not targetPart or not targetPart.Parent then return end
    local hrp = getHRP(LP.Character) if not hrp then return end
    local remote, extra, weaponType = getWeaponInfo()
    if not remote then return end
    if weaponType == "gun" then fireGunNormal(targetPart)
    elseif weaponType == "fruit" then remote:FireServer((targetPart.Position - hrp.Position).Unit, 1)
    elseif remote and extra then pcall(function() remote:FireServer(0.5) extra:FireServer(targetPart, {}, "196f522a") end) end
end
local function getNearbyTargets(range)
    local hrp = getHRP(LP.Character) if not hrp then return {} end
    local enemies = workspace:FindFirstChild("Enemies") if not enemies then return {} end
    local targets = {}
    for _, enemy in ipairs(enemies:GetChildren()) do
        if isAlive(enemy) and not isPlayerChar(enemy) then
            local part = getEnemyHRP(enemy) or getHitPart(enemy)
            if part and (hrp.Position - part.Position).Magnitude <= range then table.insert(targets, part) end
        end
    end
    return targets
end
local function getNearbyPlayers(range)
    local hrp = getHRP(LP.Character) if not hrp then return {} end
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and isAlive(plr.Character) then
            local part = getHitPart(plr.Character) or getHRP(plr.Character)
            if part and (hrp.Position - part.Position).Magnitude <= range then table.insert(players, part) end
        end
    end
    return players
end
local function startDamageAura()
    if damageAuraTask then return end
    local _, _, wt = getWeaponInfo()
    notify("Damage Aura", "Auto detected: "..(wt=="fruit" and "Fruit M1" or (wt=="gun" and "Gun" or "Melee")))
    damageAuraTask = task.spawn(function()
        while _G.DamageAuraEnabled do
            local _, _, currentWT = getWeaponInfo()
            local targets = getNearbyTargets(50)
            if #targets > 0 then
                if currentWT == "gun" then
                    for _, part in ipairs(targets) do fireGunNormal(part) task.wait(0.08) end
                else
                    for i = 1, math.random(1, math.min(2, #targets)) do fireDamage(targets[math.random(1, #targets)]) end
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
            for _, targetPart in ipairs(getNearbyPlayers(50)) do fireDamage(targetPart) task.wait(0.02) end
            task.wait(0.1)
        end
        damagePlayerAuraTask = nil
    end)
end
local function stopDamagePlayerAura() if damagePlayerAuraTask then task.cancel(damagePlayerAuraTask) damagePlayerAuraTask = nil end end

-- ============================================================
-- FARM AURA
-- ============================================================
local farmAuraTask, farmAuraActive = nil, false
local currentTargetPos = nil

local function getRandomSpawnPoint()
    local spawnsFolder = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawnsFolder then
        local spawns = spawnsFolder:GetChildren()
        if #spawns > 0 then
            local sp = spawns[math.random(1, #spawns)]
            local pos
            if sp:IsA("BasePart") then pos = sp.Position
            elseif sp:IsA("Model") then local ok2, p = pcall(function() return sp:GetPivot().Position end) if ok2 then pos = p end end
            if pos then return pos + Vector3.new(0, 50, 0) end
        end
    end
    if _G.CurrentCircleIsland and _G.CurrentCircleIsland.Parent then
        local parts = {}
        for _, p in ipairs(_G.CurrentCircleIsland:GetDescendants()) do if p:IsA("BasePart") then table.insert(parts, p) end end
        if #parts > 0 then return parts[math.random(1, #parts)].Position + Vector3.new(0, 80, 0) end
    end
    return nil
end

local function makeBV(hrp, name)
    local old = hrp:FindFirstChild(name) if old then old:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name = name bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
    return bv
end

local function startFarmAura()
    if farmAuraTask then return end
    farmAuraActive = true currentTargetPos = nil
    enableNoclip()
    farmAuraTask = task.spawn(function()
        while farmAuraActive do
            local hrp = getHRP(LP.Character) if not hrp then task.wait(0.5) continue end
            local closest = getClosestEnemy()
            if closest and closest.enemy then
                _G.CurrentFarmTarget = closest.enemy
                local bv = makeBV(hrp, "FarmAuraBV")
                local bp = Instance.new("BodyPosition")
                bp.Name = "FarmAuraBP" bp.MaxForce = Vector3.new(9e9,9e9,9e9) bp.P = 50000 bp.D = 2500 bp.Parent = hrp
                while farmAuraActive do
                    hrp = getHRP(LP.Character) if not hrp then break end
                    local c2 = getClosestEnemy() if not c2 then break end
                    local tp = Vector3.new(c2.part.Position.X, c2.part.Position.Y + _G.FarmAuraHeight, c2.part.Position.Z)
                    local dist = (hrp.Position - tp).Magnitude
                    if dist > 8 then bv.Velocity = (tp - hrp.Position).Unit * math.clamp(dist*8, 30, SPEED) bp.MaxForce = Vector3.zero
                    else bv.Velocity = Vector3.zero bp.Position = tp bp.MaxForce = Vector3.new(9e9,9e9,9e9) end
                    task.wait(0.05)
                end
                pcall(function() bv:Destroy() end) pcall(function() bp:Destroy() end)
            else
                if not currentTargetPos or (hrp.Position - currentTargetPos).Magnitude < 15 then
                    currentTargetPos = getRandomSpawnPoint()
                    if not currentTargetPos then task.wait(1) continue end
                    notify("Farm Aura", "No enemies → Moving to spawn", 2)
                end
                local bv = makeBV(hrp, "FarmAuraBV")
                local bp = Instance.new("BodyPosition")
                bp.Name = "FarmAuraBP" bp.P = 50000 bp.D = 2500 bp.MaxForce = Vector3.zero bp.Parent = hrp
                while farmAuraActive do
                    hrp = getHRP(LP.Character) if not hrp then break end
                    local dist = (hrp.Position - currentTargetPos).Magnitude
                    if dist < 12 then bv.Velocity = Vector3.zero bp.Position = currentTargetPos bp.MaxForce = Vector3.new(9e9,9e9,9e9) break end
                    bv.Velocity = (currentTargetPos - hrp.Position).Unit * math.clamp(dist*5.5, 30, SPEED)
                    bp.MaxForce = Vector3.zero task.wait(0.08)
                end
                local waitStart = tick()
                while farmAuraActive do
                    hrp = getHRP(LP.Character) if not hrp then break end
                    bp.Position = currentTargetPos
                    if getClosestEnemy() then notify("Farm Aura", "Enemy spawned!", 1) break end
                    if tick()-waitStart >= 30 then
                        notify("Farm Aura", "No spawn → trying next", 2)
                        local newPos = getRandomSpawnPoint() if newPos then currentTargetPos = newPos end
                        waitStart = tick()
                    end
                    task.wait(0.2)
                end
                pcall(function() bv:Destroy() end) pcall(function() bp:Destroy() end)
                currentTargetPos = nil
            end
            task.wait(0.1)
        end
    end)
end
local function stopFarmAura()
    farmAuraActive = false currentTargetPos = nil
    if farmAuraTask then task.cancel(farmAuraTask) farmAuraTask = nil end
    disableNoclip()
    local hrp = getHRP(LP.Character)
    if hrp then local bv = hrp:FindFirstChild("FarmAuraBV") if bv then bv:Destroy() end end
end

-- ============================================================
-- AUTO BUSO
-- ============================================================
_G.AutoBusoEnabled = true
local autoBusoTask = nil
local function startAutoBuso()
    if autoBusoTask then return end
    autoBusoTask = task.spawn(function()
        while _G.AutoBusoEnabled do
            local char = LP.Character
            if char and not char:FindFirstChild("HasBuso") then
                RS:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("Buso") task.wait(0.3)
            end
            task.wait(0.5)
        end
        autoBusoTask = nil
    end)
end
local function stopAutoBuso() if autoBusoTask then task.cancel(autoBusoTask) autoBusoTask = nil end end

-- ============================================================
-- BRING MOB
-- ============================================================
local bringMobTask, mobArrivedSet = nil, {}
local function setMobNoclip(enemy, enabled)
    if not enemy or not enemy.Parent then return end
    for _, part in ipairs(enemy:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.CanCollide = not enabled end) end
    end
end
local function releaseMob(enemy)
    if not enemy or not enemy.Parent then return end
    _G.BringMobTweens[enemy] = nil
    local h = getHumanoid(enemy) if h then pcall(function() h.PlatformStand = false end) end
    setMobNoclip(enemy, false)
    local hrp = getEnemyHRP(enemy)
    if hrp then pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero hrp.AssemblyAngularVelocity = Vector3.zero end) end
end
local function startBringMob()
    if bringMobTask then return end
    mobArrivedSet = {} _G.BringMobTweens = {} _G.BringMobOffsets = {}
    notify("Bring Mob", "Starting")
    bringMobTask = task.spawn(function()
        local lastFarmTarget, targetLock = nil, nil
        while _G.BringMobEnabled and _G.FarmAuraEnabled do
            local farmTarget = _G.CurrentFarmTarget
            if not farmTarget or not farmTarget.Parent or not isAlive(farmTarget) then
                local closest = getClosestEnemy()
                farmTarget = closest and closest.enemy or nil _G.CurrentFarmTarget = farmTarget
            end
            if not farmTarget then task.wait(0.5) continue end
            if farmTarget ~= lastFarmTarget then
                if targetLock then targetLock:Destroy() targetLock = nil end
                if lastFarmTarget then releaseMob(lastFarmTarget) end
                for enemy in pairs(mobArrivedSet) do releaseMob(enemy) end
                _G.BringMobOffsets = {} mobArrivedSet = {}
                lastFarmTarget = farmTarget
                local hrp = getEnemyHRP(farmTarget)
                if hrp then
                    targetLock = Instance.new("BodyPosition") targetLock.Name = "FarmTargetLock"
                    targetLock.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                    targetLock.P = 20000 targetLock.D = 1000 targetLock.Position = hrp.Position targetLock.Parent = hrp
                    setMobNoclip(farmTarget, true)
                end
            end
            local farmTargetHrp = getEnemyHRP(farmTarget) if not farmTargetHrp then task.wait(0.5) continue end
            local centerPos = farmTargetHrp.Position
            local ef = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs") or workspace:FindFirstChild("Enemy")
            if not ef then task.wait(3) continue end
            for enemy in pairs(mobArrivedSet) do
                if not enemy or not enemy.Parent or not isAlive(enemy) then releaseMob(enemy) mobArrivedSet[enemy] = nil
                elseif not _G.BringMobTweens[enemy] then
                    local ehrp = getEnemyHRP(enemy)
                    if ehrp and (ehrp.Position - centerPos).Magnitude > 15 then mobArrivedSet[enemy] = nil end
                end
            end
            local playerLevel = 9999
            local dl = LP:FindFirstChild("Data") if dl and dl:FindFirstChild("Level") then playerLevel = dl.Level.Value end
            local mobBVs = _G.BringMobBVs or {} _G.BringMobBVs = mobBVs
            for e, bv in pairs(mobBVs) do
                if not e or not e.Parent or not isAlive(e) then pcall(function() bv:Destroy() end) mobBVs[e] = nil releaseMob(e) end
            end
            local pullingCount = 0 for _ in pairs(mobBVs) do pullingCount += 1 end
            for _, e in ipairs(ef:GetChildren()) do
                if e == farmTarget or not e or not e.Parent or isPlayerChar(e) or not isAlive(e) then continue end
                local lvl = getEnemyLevel(e) or 0 if lvl >= playerLevel then continue end
                local hrp = getEnemyHRP(e)
                if not hrp or (centerPos - hrp.Position).Magnitude > _G.BringMobMaxDistance then continue end
                if not mobBVs[e] or not mobBVs[e].Parent then
                    if pullingCount >= _G.BringMobMaxBatch then continue end
                    if not _G.BringMobOffsets[e] then
                        _G.BringMobOffsets[e] = Vector3.new(math.random(-8,8), math.random(3,9), math.random(-8,8))
                    end
                    pcall(function()
                        local h = getHumanoid(e) if h then h.PlatformStand = true end
                        hrp.Anchored = false
                        local old = hrp:FindFirstChild("BringMobBV") if old then old:Destroy() end
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "BringMobBV" bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                        bv.Velocity = Vector3.zero bv.Parent = hrp mobBVs[e] = bv
                    end)
                    setMobNoclip(e, true) pullingCount += 1
                end
                local bv = mobBVs[e]
                if bv and bv.Parent then
                    local targetPos = centerPos + (_G.BringMobOffsets[e] or Vector3.zero)
                    local d = (hrp.Position - targetPos).Magnitude
                    bv.Velocity = d > 10 and (targetPos - hrp.Position).Unit * math.clamp(d*5, 15, BRING_MOB_SPEED) or Vector3.zero
                end
            end
            task.wait(0.05)
        end
        if targetLock then targetLock:Destroy() end
        if _G.BringMobBVs then for e, bv in pairs(_G.BringMobBVs) do pcall(function() bv:Destroy() end) releaseMob(e) end _G.BringMobBVs = {} end
        for e in pairs(mobArrivedSet) do releaseMob(e) end
        _G.BringMobOffsets = {} mobArrivedSet = {} bringMobTask = nil
    end)
end
local function stopBringMob()
    _G.BringMobEnabled = false
    if bringMobTask then task.cancel(bringMobTask) bringMobTask = nil end
    if _G.BringMobBVs then for e, bv in pairs(_G.BringMobBVs) do pcall(function() bv:Destroy() end) releaseMob(e) end _G.BringMobBVs = {} end
    for e in pairs(mobArrivedSet) do releaseMob(e) end
    _G.BringMobOffsets = {} mobArrivedSet = {}
end

-- ============================================================
-- FARM SELECT ENEMIES
-- ============================================================
_G.FarmSelectEnabled = false
_G.SelectedEnemyNames = {}
local farmSelectTask = nil

local function getEnemyNamesFromSpawns()
    local seen, names = {}, {}
    local spawnsFolder = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if not spawnsFolder then return names end
    
    -- แสดงทุก Part ใน EnemySpawns (แก้ปัญหาแสดงไม่ครบ)
    for _, spawn in ipairs(spawnsFolder:GetDescendants()) do
        if spawn:IsA("BasePart") or spawn:IsA("Model") then
            local baseName = (spawn.Name:match("^(.-)%s*%[") or spawn.Name):match("^%s*(.-)%s*$")
            if baseName ~= "" and not seen[baseName] then
                seen[baseName] = true
                table.insert(names, baseName)
            end
        end
    end
    
    table.sort(names) -- เรียง A-Z
    return names
end

local function isSelectedEnemy(enemy)
    if not enemy or not enemy.Parent then return false end
    local eName = enemy.Name
    for _, sel in ipairs(_G.SelectedEnemyNames) do
        if eName == sel or eName:find(sel, 1, true) or sel:find(eName:match("^(.-)%s*%[") or eName, 1, true) then return true end
    end
    return false
end

local function findSelectedEnemy()
    local hrp = getHRP(LP.Character) if not hrp then return nil end
    local enemiesFolder = workspace:FindFirstChild("Enemies") if not enemiesFolder then return nil end
    local closest, closestDist = nil, math.huge
    for _, e in ipairs(enemiesFolder:GetChildren()) do
        if e and e.Parent and isAlive(e) and isSelectedEnemy(e) then
            local part = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if part then
                local d = (hrp.Position - part.Position).Magnitude
                if d < closestDist then closestDist = d closest = {enemy=e, part=part} end
            end
        end
    end
    return closest
end

local function getSelectedEnemySpawnPoints()
    local spawnsFolder = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if not spawnsFolder then return {} end
    
    local points = {}
    local selectedSet = {}
    for _, sel in ipairs(_G.SelectedEnemyNames) do selectedSet[sel] = true end
    
    -- เก็บทุก Part ใน EnemySpawns
    for _, spawn in ipairs(spawnsFolder:GetDescendants()) do
        if spawn:IsA("BasePart") or spawn:IsA("Model") then
            local baseName = (spawn.Name:match("^(.-)%s*%[") or spawn.Name):match("^%s*(.-)%s*$")
            if selectedSet[baseName] then
                local pos = nil
                if spawn:IsA("BasePart") then
                    pos = spawn.Position
                elseif spawn:IsA("Model") then
                    local ok2, p = pcall(function() return spawn:GetPivot().Position end)
                    if ok2 then pos = p end
                end
                if pos then
                    table.insert(points, {pos = pos + Vector3.new(0, 5, 0), name = spawn.Name})
                end
            end
        end
    end
    
    table.sort(points, function(a, b) return a.name < b.name end)
    
    local purePoints = {}
    for _, p in ipairs(points) do table.insert(purePoints, p.pos) end
    return purePoints
end

local function startFarmSelect()
    if farmSelectTask then return end
    farmSelectTask = task.spawn(function()
        local spawnIndex = 1
        while _G.FarmSelectEnabled do
            if not isAlive(LP.Character) then task.wait(2) continue end
            if #_G.SelectedEnemyNames == 0 then task.wait(1) continue end

            local hrp = getHRP(LP.Character) 
            if not hrp then task.wait(1) continue end

            local target = findSelectedEnemy()

            if target then
                _G.CurrentFarmTarget = target.enemy
                notifyOnce(target.enemy, "Farm Select", "Found & Hovering: "..target.enemy.Name)

                -- Tween เหมือน Farm Aura (ลอยเหนือหัว)
                local bv = Instance.new("BodyVelocity")
                bv.Name = "FarmSelectBV" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp

                local bp = Instance.new("BodyPosition")
                bp.Name = "FarmSelectBP" bp.MaxForce = Vector3.new(9e9,9e9,9e9) bp.P = 50000 bp.D = 2500 bp.Parent = hrp

                while _G.FarmSelectEnabled do
                    hrp = getHRP(LP.Character) 
                    if not hrp then break end

                    local c2 = findSelectedEnemy()
                    if not c2 then _G.CurrentFarmTarget = nil break end

                    local tp = Vector3.new(c2.part.Position.X, c2.part.Position.Y + _G.FarmAuraHeight, c2.part.Position.Z)
                    local dist = (hrp.Position - tp).Magnitude

                    if dist > 8 then
                        bv.Velocity = (tp - hrp.Position).Unit * math.clamp(dist*8, 30, SPEED)
                        bp.MaxForce = Vector3.zero
                    else
                        bv.Velocity = Vector3.zero
                        bp.Position = tp
                        bp.MaxForce = Vector3.new(9e9,9e9,9e9)
                    end
                    task.wait(0.05)
                end

                pcall(function() bv:Destroy() end)
                pcall(function() bp:Destroy() end)

            else
                -- =============================================
                -- ไม่เจอมอน → Tween วนรอบ Spawn Points (A-Z)
                -- =============================================
                local points = getSelectedEnemySpawnPoints()
                if #points == 0 then task.wait(1) continue end

                notify("Farm Select", "Patrolling spawn points ("..#points.." points) A-Z", 3)

                local patrolIndex = 1
                while _G.FarmSelectEnabled and not findSelectedEnemy() do
                    local wp = points[patrolIndex]
                    hrp = getHRP(LP.Character) 
                    if not hrp then break end

                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "FarmSelectBV"
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    bv.Velocity = Vector3.zero
                    bv.Parent = hrp

                    -- Tween ไปจุดเกิด
                    while (hrp.Position - wp).Magnitude > 8 and _G.FarmSelectEnabled and not findSelectedEnemy() do
                        hrp = getHRP(LP.Character)
                        if not hrp then break end
                        bv.Velocity = (wp - hrp.Position).Unit * SPEED
                        task.wait(0.05)
                    end

                    pcall(function() bv:Destroy() end)
                    if not _G.FarmSelectEnabled or findSelectedEnemy() then break end

                    -- วนไปจุดถัดไป (loop)
                    patrolIndex = (patrolIndex % #points) + 1
                    task.wait(0.8) -- พักเล็กน้อยที่แต่ละจุด
                end
            end
            task.wait(0.1)
        end

        -- Cleanup
        local hrp2 = getHRP(LP.Character)
        if hrp2 then
            pcall(function() hrp2:FindFirstChild("FarmSelectBV"):Destroy() end)
            pcall(function() hrp2:FindFirstChild("FarmSelectBP"):Destroy() end)
        end
        farmSelectTask = nil
    end)
end

local function stopFarmSelect()
    _G.FarmSelectEnabled = false
    if farmSelectTask then task.cancel(farmSelectTask) farmSelectTask = nil end
    local hrp = getHRP(LP.Character)
    if hrp then local bv = hrp:FindFirstChild("FarmSelectBV") if bv then pcall(function() bv:Destroy() end) end end
    lastNotifiedTarget = nil
end

-- ============================================================
-- UI
-- ============================================================
local Windows = NothingLibrary.new({
    Title = "Easter Event",
    Description = "Blox fruits | by Index",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
})
local MainTab = Windows:NewTab({ Title = "Main", Description = "Auto Farm X Event", Icon = "rbxassetid://4483362458" })

-- Easter Egg Section (Sealed Egg รวมอยู่ใน Auto Farm นี้แล้ว)
local FarmSection = MainTab:NewSection({ Title = "Easter Egg", Icon = "rbxassetid://7743869054", Position = "Left" })
FarmSection:NewDropdown({ Title = "Farm Mode", Data = {"Random","Circle"}, Default = "Random", Callback = function(v)
    _G.FarmMode = v == "Random" and "random" or "circle"
end })
FarmSection:NewToggle({ Title = "Auto Farm (Easter + Sealed Egg)", Default = false, Callback = function(v)
    _G.AutoFarmEnabled = v
    if v then
        sealedEggBlacklist = {}
        sealedEggTargetIsland = nil
        StartFarming()
        enableNoclip()
        enableAntiSit()
    else
        lastNotifiedTarget = nil
        _G.CurrentCircleIsland = nil
        sealedEggBlacklist = {}
        sealedEggTargetIsland = nil
        disableNoclip()
        disableAntiSit()
        local hrp = getHRP(LP.Character)
        if hrp then
            for _, n in ipairs({"Lock","HoverBV","HoverBP","QuestFloat","SealedEggLock","FriendlyLock","ThirstyLock","MoltenLock"}) do
                local o = hrp:FindFirstChild(n) if o then pcall(function() o:Destroy() end) end
            end
        end
    end
end })
FarmSection:NewToggle({ Title = "Quest Delivery (Egg)", Default = false, Callback = function(v)
    _G.QuestModeEnabled = v lastNotifiedTarget = nil
end })

-- Farm Main Section
local MobControlSection = MainTab:NewSection({ Title = "Farm Main", Icon = "rbxassetid://7743869054", Position = "Right" })
_G.BringMobRequested = false
local bringMobToggle = MobControlSection:NewToggle({ Title = "Bring Mob", Default = true, Callback = function(v)
    if v then
        _G.BringMobRequested = true
        if _G.FarmAuraEnabled then
            if bringMobTask then stopBringMob() end
            _G.BringMobEnabled = true startBringMob()
        else
            _G.BringMobEnabled = false notify("Bring Mob", "Enable Farm Aura First")
        end
    else
        _G.BringMobRequested = false _G.BringMobEnabled = false stopBringMob()
    end
end })
MobControlSection:NewToggle({ Title = "Farm Aura", Default = false, Callback = function(v)
    _G.FarmAuraEnabled = v
    if v then
        startFarmAura()
        if _G.BringMobRequested and not _G.BringMobEnabled then
            _G.BringMobEnabled = true startBringMob()
            if bringMobToggle then bringMobToggle:SetValue(true) end
        end
    else
        stopFarmAura()
        if _G.BringMobEnabled then stopBringMob() _G.BringMobEnabled = false end
    end
end })
MobControlSection:NewSlider({ Title = "Y Offset", Min = 10, Max = 100, Default = 35, Callback = function(v) _G.FarmAuraHeight = v end })
MobControlSection:NewSlider({ Title = "Bring Distance", Min = 100, Max = 1200, Default = 500, Callback = function(v) _G.BringMobMaxDistance = v end })
MobControlSection:NewSlider({ Title = "Bring Max", Min = 1, Max = 6, Default = 6, Callback = function(v) _G.BringMobMaxBatch = v end })

-- Farm Select Enemy Section
local FarmSelectSection = MainTab:NewSection({ 
    Title = "Farm Select Enemy", 
    Icon = "rbxassetid://7743869054", 
    Position = "Right" 
})

local enemyNameList = getEnemyNamesFromSpawns()
if #enemyNameList == 0 then enemyNameList = {"(No spawns found)"} end

FarmSelectSection:NewDropdown({
    Title = "Select Enemy (Single)",
    Data = enemyNameList,
    Default = enemyNameList[1] or "",
    Callback = function(selected)
        if selected and selected ~= "" and selected ~= "(No spawns found)" then
            _G.SelectedEnemyNames = {selected}
        else
            _G.SelectedEnemyNames = {}
        end
        lastNotifiedTarget = nil
    end
})

FarmSelectSection:NewToggle({
    Title = "Farm Selected Enemy",
    Default = false,
    Callback = function(v)
        _G.FarmSelectEnabled = v
        if v then
            if #_G.SelectedEnemyNames == 0 then
                notify("Farm Select", "Please select enemy first!", 3)
                _G.FarmSelectEnabled = false 
                return
            end
            enableNoclip()
            startFarmSelect()

            -- Auto เปิด Bring Mob ถ้าผู้ใช้กดไว้
            if _G.BringMobRequested and not _G.BringMobEnabled then
                _G.BringMobEnabled = true 
                startBringMob()
                if bringMobToggle then bringMobToggle:SetValue(true) end
            end
        else
            stopFarmSelect()
        end
    end
})

-- Settings Tab
local SettingsTab = Windows:NewTab({ Title = "Settings", Description = "Configuration", Icon = "rbxassetid://7733960981" })
local ConfigSection = SettingsTab:NewSection({ Title = "Configuration", Icon = "rbxassetid://7743869054", Position = "Left" })
ConfigSection:NewSlider({ Title = "Tween Speed", Min = 100, Max = 400, Default = 300, Callback = function(v) SPEED = v end })
ConfigSection:NewSlider({ Title = "Chest Wait Time (ms)", Min = 10, Max = 500, Default = 10, Callback = function(v) _G.ChestWaitTime = v/1000 end })
ConfigSection:NewToggle({ Title = "Auto Jump", Default = true, Callback = function(v) _G.AutoJumpEnabled = v end })

local CombatSection = SettingsTab:NewSection({ Title = "Combat", Icon = "rbxassetid://7743869054", Position = "Right" })
CombatSection:NewToggle({ Title = "Damage Aura (Enemies)", Default = false, Callback = function(v)
    _G.DamageAuraEnabled = v if v then startDamageAura() else stopDamageAura() end
end })
CombatSection:NewToggle({ Title = "Damage Aura (Players)", Default = false, Callback = function(v)
    _G.DamageAuraPlayersEnabled = v if v then startDamagePlayerAura() else stopDamagePlayerAura() end
end })
local autoBusoToggle = CombatSection:NewToggle({ Title = "Auto Buso", Default = true, Callback = function(v)
    _G.AutoBusoEnabled = v if v then startAutoBuso() else stopAutoBuso() end
end })
if _G.AutoBusoEnabled then startAutoBuso() end

local EquipSection = SettingsTab:NewSection({ Title = "Auto Equip", Icon = "rbxassetid://7743869054", Position = "Right" })
EquipSection:NewToggle({ Title = "Enable Auto Equip", Default = false, Callback = function(v)
    _G.AutoEquipEnabled = v if v then startAutoEquip() else stopAutoEquip() end
end })
EquipSection:NewDropdown({ Title = "Weapon Type", Data = {"Melee","Sword","Gun","Fruit"}, Default = "Melee", Callback = function(v)
    _G.SelectedWeaponType = v if _G.AutoEquipEnabled then equipWeapon(v) end
end })

print("Script loaded successfully")
