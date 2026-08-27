local cloneref = cloneref or function(o) return o end

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
    Info            = Window:AddTab("Info", "monitor"),
    Main            = Window:AddTab("Main", "sword"),
    Teleport        = Window:AddTab("Teleport", "map-pin"),
    FarmSettings    = Window:AddTab("Farm Settings", "settings-2"),
    Misc            = Window:AddTab("Misc", "box"),
    Esp             = Window:AddTab("ESP", "eye"),
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

local pSats = 10

local sea1 = (game.PlaceId == 2753915549 or game.PlaceId == 85211729168715)
local sea2 = (game.PlaceId == 4442272183 or game.PlaceId == 79091703265657)
local sea3 = (game.PlaceId == 7449423635 or game.PlaceId == 100117331123089)

local discoveredMonsters  = {}
local masterMonsterList   = {}
local cachedSpawnsByName  = {}
local selectedMonsterList = {}
local selectedWeaponType  = "Melee"

local autoNearEnabled      = false
local autoFarmEnabled      = false
local bringMobEnabled      = true
local bringMobMode         = "Instant"
local teleportTweenEnabled = false
local currentEnemy         = nil
local trackedRoot          = nil
local followConn           = nil
local farmConn             = nil
local teleportConn         = nil
local noclipConn           = nil
local lockConn             = nil
local currentFlyCF         = nil
local selectedIslandName   = nil
local selectedIslandPos    = nil
local safeHealthThreshold  = 25

local WEAPON_TYPES = {"Melee", "Sword", "Gun", "Fruit"}
local BRING_MODES  = {"Instant (BestPrivate server)", "Smooth (Best Public Server)"}

local shouldTween = false
local block = Instance.new("Part", workspace)
block.Size = Vector3.new(1, 1, 1)
block.Name = "KKKK_TweenBlock"
block.Anchored = true
block.CanCollide = false
block.CanTouch = false
block.Transparency = 1

local existingBlock = workspace:FindFirstChild("KKKK_TweenBlock")
if existingBlock and existingBlock ~= block then existingBlock:Destroy() end

task.spawn(function()
    local a = LocalPlayer
    repeat task.wait() until a.Character and a.Character.PrimaryPart
    block.CFrame = a.Character.PrimaryPart.CFrame
    while task.wait() do
        pcall(function()
            if shouldTween then
                if block and block.Parent == workspace then
                    local b = a.Character and a.Character.PrimaryPart
                    if b and (b.Position - block.Position).Magnitude <= 200 then
                        b.CFrame = block.CFrame
                    else
                        block.CFrame = b.CFrame
                    end
                end
                local c = a.Character
                if c then
                    for _, e in pairs(c:GetChildren()) do
                        if e:IsA("BasePart") then e.CanCollide = false end
                    end
                end
            else
                local c = a.Character
                if c then
                    for _, e in pairs(c:GetChildren()) do
                        if e:IsA("BasePart") then e.CanCollide = true end
                    end
                end
            end
        end)
    end
end)

local function Convert_CFrame(x)
    if not x then return end
    if typeof(x) == "Vector3" then return CFrame.new(x)
    elseif typeof(x) == "CFrame" then return x
    elseif typeof(x) == "Model" then return x:GetPivot()
    elseif x.CFrame then return x.CFrame
    end
    return nil
end

local function GetDistance(POS_1, POS_2)
    if POS_1 == nil then return 9e9 end
    local c = LocalPlayer.Character
    if not c then return 9e9 end
    local h = c:FindFirstChild("Humanoid")
    if not h or h.Health <= 0 then return 9e9 end
    if POS_2 == nil then
        POS_2 = c:FindFirstChild("HumanoidRootPart")
        if not POS_2 then return 9e9 end
    end
    local pos1 = Convert_CFrame(POS_1)
    local pos2 = Convert_CFrame(POS_2)
    return (pos1.Position - pos2.Position).Magnitude
end

local function getdis(a, b)
    local char = LocalPlayer.Character
    b = b or (char and char.HumanoidRootPart and char.HumanoidRootPart.CFrame)
    if not b then return 9e9 end
    local _a = CFrame.new(a.X, b.Y, a.Z)
    local _b = CFrame.new(b.X, b.Y, b.Z)
    return (_a.Position - _b.Position).Magnitude
end

local function InArea(POS)
    local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
    if not WorldOrigin then return {Name = ""} end
    local pos = Convert_CFrame(POS)
    for _, v in next, WorldOrigin.Locations:GetChildren() do
        if v:FindFirstChild("Mesh") and (pos.Position - v.Position).Magnitude <= v.Mesh.Scale.X then
            return v
        end
    end
    return {Name = ""}
end

local function GetSpawnPoint(x)
    local Spawns = workspace:FindFirstChild("_WorldOrigin")
        and workspace._WorldOrigin:FindFirstChild("PlayerSpawns")
        and workspace._WorldOrigin.PlayerSpawns:FindFirstChild("Pirates")
    if not Spawns then return end
    for _, v in next, Spawns:GetChildren() do
        if v:FindFirstChild("Part") and (v.Part.Position - x.Position).Magnitude <= 2500 then
            return v
        end
    end
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
    local AreaName = InArea(x).Name
    if AreaName == "" then return false end
    if AreaName:find("Dimension") or AreaName:find("Submerged") or AreaName == "Sealed Cavern"
        or AreaName:lower():find("under") or CheckLegendaryItems() then
        return false
    end
    if LocalPlayer.Data and LocalPlayer.Data.LastSpawnPoint
        and LocalPlayer.Data.LastSpawnPoint.Value == "SubmergedIsland" then
        return false
    end
    if GetDistance(x.Position) <= 1500 then return false end
    return true
end

local function GetBypassCFrame(x)
    local WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
    if not WorldOrigin then return nil end
    local Spawns = WorldOrigin:FindFirstChild("PlayerSpawns")
    if not Spawns then return nil end
    local Pirates = Spawns:FindFirstChild("Pirates")
    if not Pirates then return nil end
    local Max = math.huge
    local Pos
    local charHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not charHRP then return nil end
    for _, v in next, Pirates:GetChildren() do
        if v:FindFirstChild("Part") then
            if (x.Position - charHRP.Position).Magnitude >= 3000
                and GetSpawnPoint(v.Part) ~= GetSpawnPoint(charHRP)
                and (v.Part.Position - charHRP.Position).Magnitude <= 10000
                and (v.Part.Position - x.Position).Magnitude <= Max then
                Max = (v.Part.Position - x.Position).Magnitude
                Pos = v
            end
        end
    end
    return Pos
end

local function WaitForHumanoid()
    local c = LocalPlayer.Character
    if not c then return nil end
    local h = c:FindFirstChild("Humanoid")
    if h then return h end
    local t = tick() + 5
    while tick() < t do
        h = c:FindFirstChild("Humanoid")
        if h then return h end
        task.wait(0.1)
    end
    return nil
end

local function BypassTP(Target)
    local c = LocalPlayer.Character
    if not c then return end
    local h = WaitForHumanoid()
    if not h or h.Health <= 0 then return end
    if CanBypassTeleport(Target) and GetBypassCFrame(Target) then
        local TargetTP = GetBypassCFrame(Target)
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
            repeat task.wait(0.1) until LocalPlayer.Character and WaitForHumanoid() and WaitForHumanoid().Health > 0
        end
    end
end

local newdao = CFrame.new(10641.0918, -1953.92981, 9825.07031,
    -0.652825892, -9.2805891e-08, -0.757508039,
    -2.73638356e-08, 1, -9.89323823e-08,
    0.757508039, -4.38572947e-08, -0.652825892)
local cframenpc = CFrame.new(-16271.126, 25.5847301, 1371.98755,
    0.999396622, -5.78875188e-08, -0.0347310975,
    5.52972779e-08, 1, -8.7544322e-08,
    0.034731105, 8.28877091e-08, 0.999396741)

local function checkinventory(v)
    if v then
        pcall(function()
            for _, vl in pairs(ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")) do
                if vl.Name == v then return true end
            end
        end)
    end
    return false
end

local function requestentrance(pos)
    local tb = {}
    local targetPos = pos
    if typeof(pos) == "CFrame" then targetPos = pos.Position end
    if sea1 then
        tb = {
            ["Sky3"]            = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"]        = Vector3.new(-4607, 874, -1667),
            ["UnderWater"]      = Vector3.new(61163, 11, 1819),
            ["Underwater City"] = Vector3.new(61165.19140625, 0.187, 1897.38),
            ["Pirate Village"]  = Vector3.new(-1242.46, 4.79, 3901.28),
            ["UnderwaterExit"]  = Vector3.new(4050, -1, -1814),
        }
    elseif sea2 then
        tb = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"]    = Vector3.new(2285, 15, 905),
            ["Cursed Ship"]  = Vector3.new(923, 126, 32852),
            ["Zombie Island"]= Vector3.new(-6509, 83, -133),
        }
    else
        tb = {
            ["Hydra Island"]   = Vector3.new(5657.88, 1013.08, -335.50),
            ["Mansion"]        = Vector3.new(-12462, 375, -7552),
            ["Castle"]         = Vector3.new(-5036, 315, -3179),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103),
            ["Greate Tree"]    = Vector3.new(3024.17, 2280.69, -7325.13),
        }
        if not checkinventory("Valkyrie Helm") then return end
    end
    local x, y = nil, math.huge
    for _, v in pairs(tb) do
        local distance = (typeof(v) == "Vector3" and (v - targetPos).Magnitude)
            or (v.Position - targetPos).Magnitude
        if distance < y then y = distance; x = v end
    end
    if x and y then
        local charHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if charHRP and y < getdis(typeof(pos) == "CFrame" and pos.Position or pos, charHRP.CFrame) then
            local requestPos = typeof(x) == "Vector3" and x or x.Position
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", requestPos)
            end)
            task.wait(1)
        end
    end
end

local function old_tp(p)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = p
    end
end

local function _tp(target)
    local gg
    if typeof(target) == "Vector3" then
        gg = CFrame.new(target)
    elseif typeof(target) == "CFrame" then
        gg = target
    else
        gg = target and target.CFrame
    end
    if not gg then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart
    pcall(function()
        if CanBypassTeleport(gg) then
            BypassTP(gg)
            task.wait(0.5)
        end
    end)
    pcall(function() requestentrance(target) end)
    if sea3 then
        pcall(function()
            if getdis(gg.Position, newdao.Position) < 2000 then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                if math.abs(newdao.Position.Y - hrp.CFrame.Y) > 1000 then
                    repeat
                        task.wait()
                        old_tp(cframenpc)
                        if getdis(cframenpc.Position) < 10 then
                            local netMod = ReplicatedStorage.Modules.Net
                            netMod["RF/SubmarineWorkerSpeak"]:InvokeServer("AskKilledTikiBoss")
                            task.wait(0.5)
                            netMod["RF/SubmarineWorkerSpeak"]:InvokeServer("TravelToSubmergedIsland")
                        end
                    until getdis(gg.Position) < 2000
                    task.wait(0.6)
                    pcall(function()
                        if hrp:FindFirstChild("BodyClip") then hrp.BodyClip:Destroy() end
                    end)
                end
            end
        end)
    end
    local distance = (gg.Position - rootPart.Position).Magnitude
    local tweenSpeed = math.max(distance / 300, 0.1)
    local tweenInfo = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(block, tweenInfo, {CFrame = gg})
    if LocalPlayer.Character and LocalPlayer.Character.Humanoid
        and LocalPlayer.Character.Humanoid.Sit == true then
        block.CFrame = CFrame.new(block.Position.X, gg.Y, block.Position.Z)
    end
    shouldTween = true
    tween:Play()
    local deadline = tick() + tweenSpeed + 2
    repeat task.wait(0.05) until not tween
        or tween.PlaybackState ~= Enum.PlaybackState.Playing
        or tick() > deadline
    return tween
end

local FastAttackModule      = {}
local HitRegistrationModule = {}

local EnemiesFolder    = Workspace:FindFirstChild("Enemies")
local CharactersFolder = Workspace:FindFirstChild("Characters")

local function safeWaitForChild(parent, childName)
    local ok, result = pcall(function() return parent:WaitForChild(childName, 5) end)
    return ok and result or parent:FindFirstChild(childName)
end

local function refreshFolders()
    EnemiesFolder    = safeWaitForChild(Workspace, "Enemies")
    CharactersFolder = safeWaitForChild(Workspace, "Characters")
end
refreshFolders()

FastAttackModule.Rate    = 0.05
FastAttackModule.Enabled = false

function FastAttackModule.GetNearbyTargets(character, folder)
    if not folder or not character then return {} end
    local characterPosition = character:GetPivot().Position
    local nearbyTargets = {}
    local children = folder:GetChildren()
    for i = 1, #children do
        local target = children[i]
        local humanoid = target:FindFirstChild("Humanoid")
        local rootPart = target:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and humanoid.Health > 0 then
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
    if not EnemiesFolder    then EnemiesFolder    = Workspace:FindFirstChild("Enemies")    end
    if not CharactersFolder then CharactersFolder = Workspace:FindFirstChild("Characters") end
    local enemies         = FastAttackModule.GetNearbyTargets(character, EnemiesFolder)
    local otherCharacters = FastAttackModule.GetNearbyTargets(character, CharactersFolder)
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
    if #targetParts < 1 then return end
    RegisterAttack:FireServer(FastAttackModule.Rate)
    local targetHead = targetParts[1][2]
    RegisterHit:FireServer(targetHead, targetParts)
end

local AttackRemoteTarget
local AttackRemoteId

local function initHitRegistration()
    local foldersToCheck = {}
    for _, name in ipairs({"Util", "Common", "Remotes", "Assets", "FX"}) do
        local f = ReplicatedStorage:FindFirstChild(name)
        if f then table.insert(foldersToCheck, f) end
    end
    for _, folder in ipairs(foldersToCheck) do
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                AttackRemoteTarget = child
                AttackRemoteId     = child:GetAttribute("Id")
            end
        end
        folder.ChildAdded:Connect(function(child)
            if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                AttackRemoteTarget = child
                AttackRemoteId     = child:GetAttribute("Id")
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
    if not EnemiesFolder    then EnemiesFolder    = Workspace:FindFirstChild("Enemies")    end
    if not CharactersFolder then CharactersFolder = Workspace:FindFirstChild("Characters") end
    local hitTargets = {}
    local function scanFolder(folder)
        if not folder then return end
        local children = folder:GetChildren()
        for i = 1, #children do
            local target   = children[i]
            local humanoid = target:FindFirstChild("Humanoid")
            local rootPart = target:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart and humanoid.Health > 0 and target ~= character then
                local distance = (rootPart.Position - humanoidRootPart.Position).Magnitude
                if distance <= 60 then
                    for _, child in ipairs(target:GetChildren()) do
                        if child:IsA("BasePart") then table.insert(hitTargets, {target, child}) end
                    end
                end
            end
        end
    end
    scanFolder(EnemiesFolder)
    scanFolder(CharactersFolder)
    local tool = character:FindFirstChildOfClass("Tool")
    local weaponType = tool and tool:GetAttribute("WeaponType")
    if #hitTargets > 0 and tool and (weaponType == "Melee" or weaponType == "Sword") then
        local ok, seed = pcall(function()
            return Net:FindFirstChild("seed") and Net.seed:InvokeServer()
        end)
        if not ok or not seed then seed = math.random(1000, 9999) end
        RegisterAttack:FireServer()
        local targetHead = hitTargets[1][1]:FindFirstChild("Head")
        if not targetHead then return end
        RegisterHit:FireServer(targetHead, hitTargets, {})
        if AttackRemoteTarget and AttackRemoteId then
            pcall(function()
                local remoteCode    = "RE/RegisterHit"
                local encryptionKey = math.floor(Workspace:GetServerTimeNow() / 10 % 10) + 1
                local encodedString = string.gsub(remoteCode, ".", function(char)
                    return string.char(bit32.bxor(string.byte(char), encryptionKey))
                end)
                local finalId = bit32.bxor(AttackRemoteId + 909090, seed * 2)
                cloneref(AttackRemoteTarget):FireServer(encodedString, finalId, targetHead, hitTargets)
            end)
        end
    end
end

local fastAttackThread = nil

local function startFastAttack()
    if fastAttackThread then task.cancel(fastAttackThread); fastAttackThread = nil end
    fastAttackThread = task.spawn(function()
        while FastAttackModule.Enabled do
            pcall(FastAttackModule.ExecuteFastAttack)
            task.wait(FastAttackModule.Rate)
        end
        fastAttackThread = nil
    end)
end

local function stopFastAttack()
    FastAttackModule.Enabled = false
    if fastAttackThread then task.cancel(fastAttackThread); fastAttackThread = nil end
end

local hitRegConn = nil

local function startHitRegistration()
    if hitRegConn then hitRegConn:Disconnect() end
    hitRegConn = RunService.Heartbeat:Connect(function()
        if FastAttackModule.Enabled then
            pcall(HitRegistrationModule.Execute)
        end
    end)
end

local function stopHitRegistration()
    if hitRegConn then hitRegConn:Disconnect(); hitRegConn = nil end
end

local TELEPORT_LOCATIONS = {
    [2753915549] = {
        WorldName = "Old World (Sea 1)",
        Locations = {
            { Name = "Pirate Starter",    Pos = Vector3.new(885, 17, 1429) },
            { Name = "Middle Island",     Pos = Vector3.new(-690, 15, 1584) },
            { Name = "Marine Starter",    Pos = Vector3.new(-2600, 7, 2068) },
            { Name = "Jungle island",     Pos = Vector3.new(-1445, 62, -34) },
            { Name = "Pirate island",     Pos = Vector3.new(-1218, 5, 3922) },
            { Name = "Desert island",     Pos = Vector3.new(942, 21, 4372) },
            { Name = "Snow island",       Pos = Vector3.new(1345, 106, -1319) },
            { Name = "Sky",               Pos = Vector3.new(-4817, 718, -2628) },
            { Name = "sky 1",             Pos = Vector3.new(-4714, 853, -1932) },
            { Name = "sky 2",             Pos = Vector3.new(-7921, 5566, -379) },
            { Name = "Usop",              Pos = Vector3.new(-7990, 5756, -1927) },
            { Name = "Colosseum island",  Pos = Vector3.new(-1453, 7, -2848) },
            { Name = "Fishmen island",    Pos = Vector3.new(3906, 5, -1893) },
            { Name = "Prison island",     Pos = Vector3.new(5010, 89, 738) },
            { Name = "Fountain island",   Pos = Vector3.new(5273, 81, 3987) },
            { Name = "Magma island",      Pos = Vector3.new(-5241, 9, 8413) },
            { Name = "MarineBase island", Pos = Vector3.new(-4816, 21, 4360) },
            { Name = "Mob Leader",        Pos = Vector3.new(-2844, 7, 5309) },
        }
    },
    [4442272183] = {
        WorldName = "Second World (Sea 2)",
        Locations = {
            { Name = "Dock 1",               Pos = Vector3.new(-10, 39, 2703) },
            { Name = "Mansion",              Pos = Vector3.new(-393, 360, 546) },
            { Name = "Cafe",                 Pos = Vector3.new(-373, 73, 296) },
            { Name = "Race Evo",             Pos = Vector3.new(-2007, 126, -74) },
            { Name = "Dock 2",               Pos = Vector3.new(-1917, 6, -2546) },
            { Name = "Green Zone",           Pos = Vector3.new(-2456, 87, -3188) },
            { Name = "TTk",                  Pos = Vector3.new(-2573, 1626, -3742) },
            { Name = "Ice island",           Pos = Vector3.new(-5897, 29, -5055) },
            { Name = "Hot island",           Pos = Vector3.new(-5012, 176, -5320) },
            { Name = "Forgotten island",     Pos = Vector3.new(-3043, 240, -10140) },
            { Name = "IceCastle island",     Pos = Vector3.new(6000, 294, -6611) },
            { Name = "SnowMountain island",  Pos = Vector3.new(800, 412, -5250) },
            { Name = "Raid",                 Pos = Vector3.new(-6483, 305, -4736) },
            { Name = "ZombieVampire island", Pos = Vector3.new(-5648, 185, -888) },
            { Name = "Ship island",          Pos = Vector3.new(-6525, 83, -156) },
        }
    },
    [7449423635] = {
        WorldName = "Third World (Sea 3)",
        Locations = {
            { Name = "port town",        Pos = Vector3.new(-340, 21, 5538) },
            { Name = "Castle island",    Pos = Vector3.new(-5135, 314, -2957) },
            { Name = "Hydra town",       Pos = Vector3.new(5295, 1005, 380) },
            { Name = "Hydra Arena",      Pos = Vector3.new(5016, 59, -1556) },
            { Name = "Mansion turtle",   Pos = Vector3.new(-12551, 337, -7481) },
            { Name = "beautiful pirate", Pos = Vector3.new(5372, 22, -306) },
            { Name = "Tiki island",      Pos = Vector3.new(-16398, 528, 403) },
            { Name = "Haunted Castle",   Pos = Vector3.new(-9512, 142, 5540) },
            { Name = "Katakuri island",  Pos = Vector3.new(-2094, 70, -12125) },
            { Name = "Bigmom island",    Pos = Vector3.new(-890, 66, -10899) },
            { Name = "Chocolate island", Pos = Vector3.new(-6, 21, -12049) },
            { Name = "North Pole",       Pos = Vector3.new(-1096, 64, -14515) },
            { Name = "Great tree",       Pos = Vector3.new(2391, 74, -7006) },
            { Name = "Upper Great tree", Pos = Vector3.new(3038, 2281, -7325) },
        }
    }
}

local function getIslandNamesAndMap(placeId)
    local data
    if placeId == 2753915549 or placeId == 85211729168715 then
        data = TELEPORT_LOCATIONS[2753915549]
    elseif placeId == 4442272183 or placeId == 79091703265657 then
        data = TELEPORT_LOCATIONS[4442272183]
    elseif placeId == 7449423635 or placeId == 100117331123089 then
        data = TELEPORT_LOCATIONS[7449423635]
    else
        data = TELEPORT_LOCATIONS[2753915549]
    end
    local names, map = {}, {}
    for _, loc in ipairs(data.Locations) do
        table.insert(names, loc.Name)
        map[loc.Name] = loc.Pos
    end
    return names, map, data.WorldName
end

local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
        if HRP then
            pcall(function()
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
                for _, child in ipairs(HRP:GetChildren()) do
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
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

local function startPositionLock()
    if lockConn then lockConn:Disconnect() end
    if Humanoid then pcall(function() Humanoid.AutoRotate = false end) end
    lockConn = RunService.RenderStepped:Connect(function()
        if not (autoNearEnabled or autoFarmEnabled or teleportTweenEnabled) then
            if lockConn then lockConn:Disconnect(); lockConn = nil end
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if currentFlyCF then
            pcall(function()
                hrp.CFrame = currentFlyCF
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end)
        end
    end)
end

local function stopPositionLock()
    if lockConn then lockConn:Disconnect(); lockConn = nil end
    currentFlyCF = nil
    if Humanoid then pcall(function() Humanoid.AutoRotate = true end) end
end

local function updateCharacter()
    Character = LocalPlayer.Character
    if not Character then return false end
    HRP      = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChild("Humanoid")
    if not HRP or not HRP.Parent then return false end
    if not Humanoid or Humanoid.Health <= 0 then return false end
    if Humanoid and (autoNearEnabled or autoFarmEnabled or teleportTweenEnabled) then
        Humanoid.AutoRotate = false
    end
    return HRP ~= nil and Humanoid ~= nil
end

local function cleanMonsterName(name)
    if not name then return "" end
    return (name:gsub("%s*%[.-%]", "")):match("^%s*(.-)%s*$") or ""
end

local function getEnemyRoot(enemy)
    if not enemy or not enemy.Parent then return nil end
    return enemy:FindFirstChild("HumanoidRootPart")
end

local function snapHeightToEnemy(rootPart)
    if not rootPart or not HRP then return end
    pcall(function()
        HRP.AssemblyLinearVelocity = Vector3.zero
        local targetY = rootPart.Position.Y + CFG.OFFSET_Y
        local baseCF  = currentFlyCF or HRP.CFrame
        currentFlyCF  = CFrame.new(baseCF.Position.X, targetY, baseCF.Position.Z) * baseCF.Rotation
        HRP.CFrame    = currentFlyCF
    end)
end

local function getSpawnPositionsForMonster(monsterName)
    if not monsterName or monsterName == "" then return {} end
    if cachedSpawnsByName[monsterName] and #cachedSpawnsByName[monsterName] > 0 then
        return cachedSpawnsByName[monsterName]
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
    local folder = EnemiesFolder or Workspace:FindFirstChild("Enemies")
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
    if #list > 0 then cachedSpawnsByName[monsterName] = list end
    return list
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
    local spawns = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then for _, part in ipairs(spawns:GetChildren()) do if addDiscoveredMonster(part.Name) then newlyFound = true end end end
    local enemies = EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if enemies then for _, model in ipairs(enemies:GetChildren()) do if addDiscoveredMonster(model.Name) then newlyFound = true end end end
    return newlyFound
end

local function getAllEnemies()
    local list   = {}
    local folder = EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if not folder then return list end
    for _, model in ipairs(folder:GetChildren()) do
        local hum  = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 then table.insert(list, model) end
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
    local folder = EnemiesFolder or Workspace:FindFirstChild("Enemies")
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
    local folder = EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if not folder or #monsterList == 0 then return nil, nil end
    for _, mobName in ipairs(monsterList) do
        local enemy = findEnemyByName(mobName)
        if enemy then return enemy, mobName end
    end
    return nil, nil
end

local function updateSelectedMonstersList()
    local currentVal  = Options.MonsterSelect and Options.MonsterSelect.Value
    local updatedList = {}
    if typeof(currentVal) == "table" then
        for _, name in ipairs(selectedMonsterList) do
            if currentVal[name] == true and not table.find(updatedList, name) then
                table.insert(updatedList, name)
            end
        end
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
        local currentVal        = Options.MonsterSelect.Value or {}
        local currentSelections = {}
        if typeof(currentVal) == "table" then
            for k, v in pairs(currentVal) do if v == true then currentSelections[k] = true end end
        elseif typeof(currentVal) == "string" and currentVal ~= "" and currentVal ~= "(ไม่พบมอน)" then
            currentSelections[currentVal] = true
        end
        local displayList = #masterMonsterList > 0 and masterMonsterList or {"(ไม่พบมอน)"}
        Options.MonsterSelect:SetValues(displayList)
        if next(currentSelections) then Options.MonsterSelect:SetValue(currentSelections) end
        updateSelectedMonstersList()
        if isManual then
            Library:Notify({ Title = "Refreshed", Description = #masterMonsterList .. " monsters found", Time = 3 })
        end
    end
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

local bringMobData       = {}
local bringMobRunning    = false
local bringMobThread     = nil
local bringMobNoclipConn = nil
local bringMobPinConn    = nil
local instantBringConn   = nil
local currentLockPos     = nil

local function bmReleaseMob(enemy)
    local d = bringMobData[enemy]
    if d then
        for _, k in ipairs({"bp", "bv", "bg"}) do
            if d[k] and d[k].Parent then pcall(function() d[k]:Destroy() end) end
        end
        bringMobData[enemy] = nil
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
    for enemy in pairs(bringMobData) do pcall(bmReleaseMob, enemy) end
    bringMobData = {}
end

local function stopBringMobLoop()
    bringMobRunning = false
    if bringMobThread     then task.cancel(bringMobThread);     bringMobThread     = nil end
    if bringMobPinConn    then bringMobPinConn:Disconnect();    bringMobPinConn    = nil end
    if bringMobNoclipConn then bringMobNoclipConn:Disconnect(); bringMobNoclipConn = nil end
    bmCleanAll()
end

local function stopInstantBring()
    if instantBringConn then instantBringConn:Disconnect(); instantBringConn = nil end
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

local function startInstantBring()
    stopInstantBring()
    local elapsed = 0
    instantBringConn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        if elapsed < 0.1 then return end
        elapsed = 0

        if not currentEnemy or not currentEnemy.Parent then return end
        local enemyRoot = currentEnemy:FindFirstChild("HumanoidRootPart")
        if not enemyRoot then return end
        local lockPos = enemyRoot.Position

        local folder = EnemiesFolder or Workspace:FindFirstChild("Enemies")
        if not folder then return end
        local count = 0
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy == currentEnemy then continue end
            if count >= CFG.BRING_COUNT then break end
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp or hum.Health <= 0 then continue end
            local dist = (lockPos - hrp.Position).Magnitude
            if dist > CFG.BRING_RADIUS then continue end
            pcall(function()
                for _, p in ipairs(enemy:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
                hrp.CFrame = CFrame.new(lockPos)
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            count = count + 1
        end
    end)
end
local function startSmoothBring(getLockPos)
    if bringMobRunning then return end
    bringMobRunning = true
    if bringMobNoclipConn then bringMobNoclipConn:Disconnect() end
    bringMobNoclipConn = RunService.RenderStepped:Connect(function()
        for enemy in pairs(bringMobData) do
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
    if bringMobPinConn then bringMobPinConn:Disconnect() end
    bringMobPinConn = RunService.Heartbeat:Connect(function()
        pinFrame = pinFrame + 1
        if pinFrame % 2 ~= 0 then return end
        local lockPos = getLockPos()
        if not lockPos then return end
        for enemy, d in pairs(bringMobData) do
            if not enemy or not enemy.Parent or not d or not d.arrived then continue end
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum.PlatformStand = true
                    hum.WalkSpeed     = 0
                    hum.JumpPower     = 0
                end)
            end
            pcall(function()
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            if not d.bp or not d.bp.Parent then
                local fbp = Instance.new("BodyPosition", hrp)
                fbp.Name     = "BringMobBP_Fixed"
                fbp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                fbp.P        = 500000
                fbp.D        = 10000
                fbp.Position = d.fixedPos or lockPos
                d.bp = fbp
            end
            if not d.bg or not d.bg.Parent then
                local bg = Instance.new("BodyGyro", hrp)
                bg.Name      = "BringMobBG"
                bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                bg.P         = 100000
                bg.D         = 2000
                bg.CFrame    = hrp.CFrame
                d.bg = bg
            end
        end
    end)
    bringMobThread = task.spawn(function()
        local PULL_TIME  = 5
        local HOLD_TIME  = 3
        local phase      = "pull"
        local phaseTimer = 0
        local lastTick   = tick()
        while bringMobRunning do
            task.wait(0.025)
            local now = tick()
            local dt  = now - lastTick
            lastTick  = now
            phaseTimer = phaseTimer + dt
            local lockPos = getLockPos()
            if not lockPos then continue end
            local folder = EnemiesFolder or Workspace:FindFirstChild("Enemies")
            if not folder then task.wait(0.3); continue end
            for enemy in pairs(bringMobData) do
                if not enemy or not enemy.Parent then
                    pcall(bmReleaseMob, enemy)
                else
                    local h = enemy:FindFirstChildOfClass("Humanoid")
                    if not h or h.Health <= 0 then pcall(bmReleaseMob, enemy) end
                end
            end
            if phase == "pull" and phaseTimer >= PULL_TIME then
                for enemy, d in pairs(bringMobData) do
                    if not d.arrived then
                        local hrp = enemy:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if d.bp and d.bp.Parent then pcall(function() d.bp:Destroy() end) end
                            local fbp = Instance.new("BodyPosition", hrp)
                            fbp.Name = "BringMobBP_Fixed"; fbp.MaxForce = Vector3.new(1e9,1e9,1e9)
                            fbp.P = 500000; fbp.D = 10000; fbp.Position = hrp.Position
                            local bg = Instance.new("BodyGyro", hrp)
                            bg.Name = "BringMobBG"; bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
                            bg.P = 100000; bg.D = 2000; bg.CFrame = hrp.CFrame
                            local hum = enemy:FindFirstChildOfClass("Humanoid")
                            if hum then pcall(function() hum.PlatformStand=true; hum.WalkSpeed=0; hum.JumpPower=0 end) end
                            d.bp = fbp; d.bg = bg; d.arrived = true; d.fixedPos = hrp.Position
                        end
                    end
                end
                phase = "hold"; phaseTimer = 0
            elseif phase == "hold" and phaseTimer >= HOLD_TIME then
                bmCleanAll(); phase = "pull"; phaseTimer = 0
            end
            if phase == "hold" then continue end
            local pulling = 0
            for _, d in pairs(bringMobData) do if not d.arrived then pulling = pulling + 1 end end
            for _, enemy in ipairs(folder:GetChildren()) do
                if not bringMobRunning then break end
                if not enemy or not enemy.Parent then continue end
                if enemy == currentEnemy then continue end
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp or hum.Health <= 0 then continue end
                local dist = (lockPos - hrp.Position).Magnitude
                if dist > CFG.BRING_RADIUS then
                    if bringMobData[enemy] and not bringMobData[enemy].arrived then
                        pcall(bmReleaseMob, enemy)
                    end
                    continue
                end
                if not bringMobData[enemy] then
                    if pulling >= CFG.BRING_COUNT then continue end
                    local off = bmGetOffset()
                    local tp  = Vector3.new((lockPos+off).X, lockPos.Y-15, (lockPos+off).Z)
                    local bp  = Instance.new("BodyPosition", hrp)
                    bp.Name="BringMobBP"; bp.MaxForce=Vector3.new(1e9,1e9,1e9); bp.P=150000; bp.D=2000; bp.Position=tp
                    if hum then pcall(function() hum.PlatformStand=true; hum.WalkSpeed=0; hum.JumpPower=0 end) end
                    pcall(function()
                        for _, p in ipairs(enemy:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end)
                    bringMobData[enemy] = {bp=bp, arrived=false, offset=off, stuckTime=0, lastPos=hrp.Position}
                    pulling = pulling + 1
                end
                local d = bringMobData[enemy]
                if not d or not d.bp or not d.bp.Parent then pcall(bmReleaseMob, enemy); continue end
                if d.arrived then continue end
                local tp    = Vector3.new((lockPos+d.offset).X, lockPos.Y-15, (lockPos+d.offset).Z)
                local dist2 = (hrp.Position - tp).Magnitude
                local moved = (hrp.Position - d.lastPos).Magnitude
                d.lastPos   = hrp.Position
                d.stuckTime = moved < 0.05 and d.stuckTime + 0.025 or 0
                if hum then pcall(function() hum.PlatformStand=true; hum.WalkSpeed=0; hum.JumpPower=0 end) end
                pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero; d.bp.Position=tp end)
                if dist2 <= 12 then
                    pcall(function() d.bp:Destroy() end)
                    pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero end)
                    local bv = Instance.new("BodyVelocity", hrp)
                    bv.Name="BringMobBV"; bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Velocity=Vector3.zero
                    task.wait()
                    local fbp = Instance.new("BodyPosition", hrp)
                    fbp.Name="BringMobBP_Fixed"; fbp.MaxForce=Vector3.new(1e9,1e9,1e9)
                    fbp.P=500000; fbp.D=10000; fbp.Position=hrp.Position
                    local bg = Instance.new("BodyGyro", hrp)
                    bg.Name="BringMobBG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
                    bg.P=100000; bg.D=2000; bg.CFrame=hrp.CFrame
                    if hum then pcall(function() hum.PlatformStand=true; hum.WalkSpeed=0; hum.JumpPower=0 end) end
                    task.delay(0.5, function() if bv and bv.Parent then pcall(function() bv:Destroy() end) end end)
                    d.bp=fbp; d.bg=bg; d.bv=bv; d.arrived=true; d.fixedPos=hrp.Position
                elseif d.stuckTime >= 0.7 then
                    d.offset=bmGetOffset(); d.stuckTime=0
                    pcall(function() d.bp.P=100000 end)
                end
            end
        end
        if bringMobPinConn    then bringMobPinConn:Disconnect();    bringMobPinConn    = nil end
        if bringMobNoclipConn then bringMobNoclipConn:Disconnect(); bringMobNoclipConn = nil end
        bmCleanAll(); bringMobThread = nil
    end)
end

local function lockAndBringMobs(targetEnemy, lockPos)
    if not targetEnemy or not targetEnemy.Parent or not lockPos then
        stopBringMobLoop(); stopInstantBring(); return
    end
    local targetRoot = targetEnemy:FindFirstChild("HumanoidRootPart")
    local targetHum  = targetEnemy:FindFirstChildOfClass("Humanoid")
    if not targetRoot or not targetHum or targetHum.Health <= 0 then
        stopBringMobLoop(); stopInstantBring(); return
    end
    pcall(function()
        for _, part in ipairs(targetEnemy:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        targetRoot.CFrame = CFrame.new(lockPos)
        targetRoot.AssemblyLinearVelocity  = Vector3.zero
        targetRoot.AssemblyAngularVelocity = Vector3.zero
    end)
    if not bringMobEnabled then
        stopBringMobLoop(); stopInstantBring(); return
    end
    currentLockPos = lockPos
    local function getLockPos() return currentLockPos end
    if string.find(bringMobMode, "Instant") then
        if bringMobRunning then stopBringMobLoop() end
        if not instantBringConn then startInstantBring() end
    else
        stopInstantBring()
        startSmoothBring(getLockPos)
    end
end

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
    local step       = CFG.SPEED * dt
    local newPos     = (dist <= step or dist < 0.01) and targetPos or fromPos + (delta / dist) * step
    local lookDir    = targetPos - newPos
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

local function startAutoNear()
    if followConn then followConn:Disconnect() end
    local prevEnemy = nil
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then currentFlyCF = hrp.CFrame end
    startPositionLock()
    followConn = RunService.Heartbeat:Connect(function(dt)
        if not autoNearEnabled then
            followConn:Disconnect(); followConn = nil
            stopFastAttack(); stopHitRegistration(); stopPositionLock(); stopNoclip(); smoothCleanAll()
            return
        end
        local c = LocalPlayer.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChild("Humanoid")
        if not hrp or not hrp.Parent then return end
        if not hum or hum.Health <= 0 then
            stopFastAttack()
            currentEnemy = nil; trackedRoot = nil; prevEnemy = nil; currentFlyCF = nil
            return
        end
        HRP = hrp; Humanoid = hum; Character = c
        if Humanoid then pcall(function() Humanoid.AutoRotate = false end) end
        equipWeapon(selectedWeaponType)
        local enemyHum  = currentEnemy and currentEnemy:FindFirstChildOfClass("Humanoid")
        local enemyRoot = currentEnemy and currentEnemy:FindFirstChild("HumanoidRootPart")
        if not currentEnemy or not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
            stopFastAttack()
            trackedRoot = nil; currentEnemy = getClosestEnemy(); prevEnemy = nil
            if not currentEnemy then
                local spawnsFolder = Workspace:FindFirstChild("_WorldOrigin")
                    and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
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
                    local targetCF = CFrame.new(bestPos + Vector3.new(CFG.OFFSET_X, CFG.OFFSET_Y, CFG.OFFSET_Z))
                    local dist = (targetCF.Position - hrp.Position).Magnitude
                    if dist > CFG.REACH then moveToTarget(hrp, targetCF, dt) end
                end
                return
            end
            trackedRoot = getEnemyRoot(currentEnemy)
            snapHeightToEnemy(trackedRoot)
        end
        if not trackedRoot or not trackedRoot.Parent then
            trackedRoot = getEnemyRoot(currentEnemy)
            if not trackedRoot then return end
            snapHeightToEnemy(trackedRoot)
        end
        local spawnPos = getEnemySpawnPosition(currentEnemy) or trackedRoot.Position
        lockAndBringMobs(currentEnemy, spawnPos)
        local targetPos = spawnPos + Vector3.new(CFG.OFFSET_X, CFG.OFFSET_Y, CFG.OFFSET_Z)
        local targetCF  = CFrame.new(targetPos)
        local dist      = (targetPos - hrp.Position).Magnitude
        if dist > CFG.REACH then
            stopFastAttack(); prevEnemy = nil
            moveToTarget(hrp, targetCF, dt)
        else
            currentFlyCF = targetCF
            pcall(function()
                hrp.CFrame = targetCF
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            if currentEnemy ~= prevEnemy then
                prevEnemy = currentEnemy
                FastAttackModule.Enabled = true
                startFastAttack(); startHitRegistration()
            end
        end
    end)
end

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
            farmConn:Disconnect(); farmConn = nil
            stopFastAttack(); stopHitRegistration(); stopPositionLock(); stopNoclip(); smoothCleanAll()
            return
        end
        if not updateCharacter() then return end
        local activeList = updateSelectedMonstersList()
        if #activeList == 0 then return end
        equipWeapon(selectedWeaponType)
        local target, targetMonsterName = findPriorityEnemy(activeList)
        if target and targetMonsterName then
            isSnapping = false; snapDone = false; lastSpawnPos = nil; spawnIdx = 1
            local enemyHum  = target:FindFirstChildOfClass("Humanoid")
            local enemyRoot = target:FindFirstChild("HumanoidRootPart")
            if not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
                trackedRoot = nil; currentEnemy = nil; return
            end
            if currentEnemy ~= target then
                if currentEnemy then smoothCleanAll() end
                currentEnemy = target; trackedRoot = nil
            end
            if trackedRoot == nil or trackedRoot.Parent == nil or not target:IsAncestorOf(trackedRoot) then
                trackedRoot = getEnemyRoot(target)
                snapHeightToEnemy(trackedRoot)
            end
            if not trackedRoot then return end
            local spawnPos = getEnemySpawnPosition(target) or trackedRoot.Position
            lockAndBringMobs(target, spawnPos)
            local targetCF = CFrame.new(spawnPos + Vector3.new(CFG.OFFSET_X, CFG.OFFSET_Y, CFG.OFFSET_Z))
            local dist = (targetCF.Position - (currentFlyCF and currentFlyCF.Position or HRP.Position)).Magnitude
            if dist > CFG.REACH then
                stopFastAttack(); prevEnemy = nil
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
                    FastAttackModule.Enabled = true
                    startFastAttack(); startHitRegistration()
                end
            end
        else
            stopFastAttack(); stopHitRegistration()
            prevEnemy = nil; currentEnemy = nil; trackedRoot = nil; smoothCleanAll()
            local spawns = {}
            for _, mobName in ipairs(activeList) do
                local s = getSpawnPositionsForMonster(mobName)
                if #s > 0 then spawns = s; break end
            end
            if #spawns == 0 then return end
            if spawnIdx > #spawns then spawnIdx = 1 end
            local spawnPos = spawns[spawnIdx] + Vector3.new(CFG.OFFSET_X, CFG.OFFSET_Y, CFG.OFFSET_Z)
            pcall(function() HRP.AssemblyLinearVelocity = Vector3.zero end)
            if lastSpawnPos ~= spawnPos then lastSpawnPos = spawnPos; snapDone = false; isSnapping = false end
            if not snapDone and not isSnapping then
                isSnapping = true
                task.spawn(function()
                    pcall(function()
                        local baseCF = currentFlyCF or HRP.CFrame
                        currentFlyCF = CFrame.new(baseCF.Position.X, spawnPos.Y, baseCF.Position.Z) * baseCF.Rotation
                        HRP.CFrame   = currentFlyCF
                    end)
                    task.wait(0.5)
                    isSnapping = false; snapDone = true
                end)
                return
            end
            if isSnapping then return end
            local targetCF = CFrame.new(spawnPos)
            local dist = (spawnPos - (currentFlyCF and currentFlyCF.Position or HRP.Position)).Magnitude
            if dist > CFG.REACH then
                moveToTarget(HRP, targetCF, dt)
            else
                snapDone = false; spawnIdx = spawnIdx % #spawns + 1
            end
        end
    end)
end

local function stopTeleportTween()
    if teleportConn then teleportConn:Disconnect(); teleportConn = nil end
    shouldTween = false
    if not (autoNearEnabled or autoFarmEnabled) then stopPositionLock(); stopNoclip() end
end

local function startTeleportTween()
    stopTeleportTween()
    if not selectedIslandPos then return end
    if HRP then currentFlyCF = HRP.CFrame end
    startNoclip(); startPositionLock()
    shouldTween = false
    teleportConn = RunService.Heartbeat:Connect(function(dt)
        if not teleportTweenEnabled then stopTeleportTween(); return end
        if not updateCharacter() then return end
        if not selectedIslandPos then return end
        local targetCF   = CFrame.new(selectedIslandPos)
        local currentPos = currentFlyCF and currentFlyCF.Position or HRP.Position
        local dist       = (selectedIslandPos - currentPos).Magnitude
        if dist > CFG.REACH then
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

local function isnil(thing) return (thing == nil) end
local function round(n) return math.floor(tonumber(n) + 0.5) end

local EspPly = function()
    for _, v in next, Players:GetChildren() do
        pcall(function()
            if not isnil(v.Character) then
                if ESP.Player then
                    if not isnil(v.Character.Head) and not v.Character.Head:FindFirstChild('NameEsp'..ESP.Number) then
                        local bill = Instance.new('BillboardGui', v.Character.Head)
                        bill.Name = 'NameEsp'..ESP.Number
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(1, 200, 1, 30)
                        bill.Adornee = v.Character.Head
                        bill.AlwaysOnTop = true
                        local name = Instance.new('TextLabel', bill)
                        name.Font = Enum.Font.Code
                        name.FontSize = "Size14"
                        name.TextWrapped = true
                        name.Text = (v.Name ..' \n'.. round((LocalPlayer.Character.Head.Position - v.Character.Head.Position).Magnitude/3) ..' M')
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
                        if v.Character.Head:FindFirstChild('NameEsp'..ESP.Number) then
                            v.Character.Head['NameEsp'..ESP.Number].TextLabel.Text = (v.Name ..' | '.. round((LocalPlayer.Character.Head.Position - v.Character.Head.Position).Magnitude/3) ..' M\nHP: ' .. round(v.Character.Humanoid.Health*100/v.Character.Humanoid.MaxHealth) .. '%')
                        end
                    end
                else
                    if v.Character.Head:FindFirstChild('NameEsp'..ESP.Number) then
                        v.Character.Head:FindFirstChild('NameEsp'..ESP.Number):Destroy()
                    end
                end
            end
        end)
    end
end

local DevEsp = function()
    for _, v in next, workspace:GetChildren() do
        pcall(function()
            if ESP.DevilFruit then
                if string.find(v.Name, "Fruit") then
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
                        name.Text = (v.Name ..' \n'.. round((LocalPlayer.Character.Head.Position - v.Handle.Position).Magnitude/3) ..' M')
                    else
                        v.Handle['NameEsp'..ESP.Number].TextLabel.Text = ('[' ..v.Name ..']' ..'   \n'.. round((LocalPlayer.Character.Head.Position - v.Handle.Position).Magnitude/3) ..' M')
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
    for _, v in next, workspace["_WorldOrigin"].Locations:GetChildren() do
        pcall(function()
            if ESP.Island then
                if v.Name ~= "Sea" then
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
                        name.Text = (v.Name ..'   \n'.. round((LocalPlayer.Character.Head.Position - v.Position).Magnitude/3) ..' M')
                    else
                        v['NameEsp'].TextLabel.Text = (v.Name ..'   \n'.. round((LocalPlayer.Character.Head.Position - v.Position).Magnitude/3) ..' M')
                    end
                end
            else
                if v:FindFirstChild('NameEsp') then v:FindFirstChild('NameEsp'):Destroy() end
            end
        end)
    end
end

local flowerEsp = function()
    for _, v in pairs(workspace:GetChildren()) do
        pcall(function()
            if v.Name == "Flower2" or v.Name == "Flower1" then
                if ESP.Flower then
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
                            name.Text = ("Blue Flower" ..' \n'.. round((LocalPlayer.Character.Head.Position - v.Position).Magnitude/3) ..' M')
                        elseif v.Name == "Flower2" then
                            name.Text = ("Red Flower" ..' \n'.. round((LocalPlayer.Character.Head.Position - v.Position).Magnitude/3) ..' M')
                        end
                    else
                        v['NameEsp'..ESP.Number].TextLabel.Text = (v.Name ..'   \n'.. round((LocalPlayer.Character.Head.Position - v.Position).Magnitude/3) ..' M')
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
    if ESP.Chest then
        local CollectionService = game:GetService("CollectionService")
        local Chests = CollectionService:GetTagged("_ChestTagged")
        for _, Chest in ipairs(Chests) do
            pcall(function()
                local chestPos = Chest:GetPivot().Position
                local distanceMagnitude = (chestPos - LocalPlayer.Character.Head.Position).Magnitude
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
    for _, v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
        pcall(function()
            if ESP.EventIsland then
                if v.Name == "Mirage Island" or v.Name == "Prehistoric Island" or v.Name == "Kitsune Island" then
                    if not v:FindFirstChild("NameEsp") then
                        local bill = Instance.new("BillboardGui", v)
                        bill.Name = "NameEsp"; bill.ExtentsOffset = Vector3.new(0,1,0)
                        bill.Size = UDim2.new(1,200,1,30); bill.Adornee = v; bill.AlwaysOnTop = true
                        local name = Instance.new("TextLabel", bill)
                        name.Font = "Code"; name.FontSize = "Size14"; name.TextWrapped = true
                        name.Size = UDim2.new(1,0,1,0); name.TextYAlignment = "Top"
                        name.BackgroundTransparency = 1; name.TextStrokeTransparency = 0.5
                        name.TextColor3 = Color3.fromRGB(80, 245, 245)
                        name.Text = (v.Name .. "   \n" .. round((LocalPlayer.Character.Head.Position - v.Position).Magnitude / 3) .. " M")
                    else
                        v.NameEsp.TextLabel.Text = v.Name .. "   \n" .. round((LocalPlayer.Character.Head.Position - v.Position).Magnitude / 3) .. " M"
                    end
                end
            else
                if v:FindFirstChild("NameEsp") then v:FindFirstChild("NameEsp"):Destroy() end
            end
        end)
    end
end

local LegenSword = function()
    if ESP.LegenSword then
        for _, v in pairs(ReplicatedStorage.NPCs:GetChildren()) do
            if v.Name == "Legendary Sword Dealer" then
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
                        name.Text = (v.Name .."   \n" ..round((LocalPlayer.Character.Head.Position - v.HumanoidRootPart.Position).Magnitude /3) .." M")
                    else
                        Lgd["NameEsp"].TextLabel.Text = (v.Name .."   \n" ..round((LocalPlayer.Character.Head.Position - v.HumanoidRootPart.Position).Magnitude /3) .." M")
                    end
                end
            end
        end
    else
        if workspace:FindFirstChild("LgdKKKK") then workspace.LgdKKKK:Destroy() end
    end
end

local berriesEsp = function()
    if ESP.Berry then
        local CollectionService = game:GetService("CollectionService")
        local BerryBushes = CollectionService:GetTagged("BerryBush")
        for _, Bush in ipairs(BerryBushes) do
            pcall(function()
                local bushPosition = Bush.Parent:GetPivot().Position
                for _, BerryName in pairs(Bush:GetAttributes()) do
                    if BerryName then
                        local espPartName = "BerryEspKKKK_" .. tostring(bushPosition.X):sub(1,6)
                        local existingEsp = workspace:FindFirstChild(espPartName)
                        if not existingEsp then
                            existingEsp = Instance.new("Part")
                            existingEsp.Name = espPartName; existingEsp.Transparency = 1
                            existingEsp.Size = Vector3.new(1,1,1); existingEsp.Anchored = true
                            existingEsp.CanCollide = false; existingEsp.Parent = workspace
                            existingEsp.CFrame = CFrame.new(bushPosition)
                        end
                        if not existingEsp:FindFirstChild("NameEsp") then
                            local nameEsp = Instance.new("BillboardGui", existingEsp)
                            nameEsp.Name = "NameEsp"; nameEsp.ExtentsOffset = Vector3.new(0,1,0)
                            nameEsp.Size = UDim2.new(0,200,0,30); nameEsp.Adornee = existingEsp; nameEsp.AlwaysOnTop = true
                            local nameLabel = Instance.new("TextLabel", nameEsp)
                            nameLabel.Font = Enum.Font.Code; nameLabel.TextSize = 14; nameLabel.TextWrapped = true
                            nameLabel.Size = UDim2.new(1,0,1,0); nameLabel.TextYAlignment = Enum.TextYAlignment.Top
                            nameLabel.BackgroundTransparency = 1; nameLabel.TextStrokeTransparency = 0.5
                            nameLabel.TextColor3 = Color3.fromRGB(80, 245, 245)
                        end
                        local nameEsp = existingEsp:FindFirstChild("NameEsp")
                        if nameEsp then
                            local distance = (LocalPlayer.Character.Head.Position - bushPosition).Magnitude / 3
                            nameEsp.TextLabel.Text = ('[' .. tostring(BerryName) .. '] ' .. math.floor(distance) .. ' M')
                        end
                    end
                end
            end)
        end
    else
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name:match("BerryEspKKKK_.*") then v:Destroy() end
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
    if LocalPlayer.Data.Points.Value == 0 then return end
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
startHitRegistration()
local initialMonsterList = #masterMonsterList > 0 and masterMonsterList or {"(ไม่พบมอน)"}

local LeftGroup  = Tabs.Main:AddLeftGroupbox("Combat")
local RightGroup = Tabs.Main:AddRightGroupbox("Farm")
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
        pcall(function()
            local date = os.date("*t")
            local hour = date.hour % 24
            local ampm = hour < 12 and "AM" or "PM"
            local h12 = ((hour - 1) % 12) + 1
            tzLabel:SetText("TZ: " .. string.format("%02d/%02d/%04d", date.day, date.month, date.year) .. " " .. string.format("%02i:%02i:%02i %s", h12, date.min, date.sec, ampm) .. " [" .. countryCode .. "]")
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local t = math.floor(workspace.DistributedGameTime + 0.5)
            gtLabel:SetText(string.format("Game Time: %dh %dm %ds", math.floor(t/3600)%24, math.floor(t/60)%60, t%60))
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function() mirLabel:SetText("Mirage Island: " .. (workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") and "✓ Spawned" or "✗ Not Found")) end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function() kitLabel:SetText("Kitsune Island: " .. (workspace._WorldOrigin.Locations:FindFirstChild("Kitsune Island") and "✓ Spawned" or "✗ Not Found")) end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function() preLabel:SetText("Prehistoric: " .. (workspace._WorldOrigin.Locations:FindFirstChild("Prehistoric Island") and "✓ Spawned" or "✗ Not Found")) end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function() froLabel:SetText("Frozen Dim: " .. (workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension") and "✓ Spawned" or "✗ Not Found")) end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
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
        end)
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local exists = ReplicatedStorage:FindFirstChild("rip_indra True Form") ~= nil
                or workspace.Enemies:FindFirstChild("rip_indra") ~= nil
            ripLabel:SetText("Rip Indra: " .. (exists and "✓ Spawned" or "✗ Not Spawned"))
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local exists = ReplicatedStorage:FindFirstChild("Dough King") ~= nil
                or workspace.Enemies:FindFirstChild("Dough King") ~= nil
            doughLabel:SetText("Dough King: " .. (exists and "✓ Spawned" or "✗ Not Spawned"))
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local s1 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")
            local s2 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2")
            local s3 = ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "3")
            local result = (s1 and "Shisui " or "") .. (s2 and "Wando " or "") .. (s3 and "Saddi" or "")
            lgdLabel:SetText("Lgd Sword: " .. (result ~= "" and result or "Not Found"))
        end)
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local bones = ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check")
            boneLabel:SetText("Bones: " .. tostring(bones or 0))
        end)
        task.wait(3)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local res = ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
            local killed = type(res) == "string" and tonumber(string.match(res, "%d+")) or nil
            if killed then
                cakeLabel:SetText("Cake Prince Killed: " .. tostring(500 - killed))
            else
                cakeLabel:SetText("Cake Prince: N/A")
            end
        end)
        task.wait(3)
    end
end)

LeftGroup:AddDropdown("WeaponSelect", {
    Values = WEAPON_TYPES, Default = 1, Multi = false, Text = "Equip Item",
})
Options.WeaponSelect:OnChanged(function()
    selectedWeaponType = Options.WeaponSelect.Value
    if autoNearEnabled or autoFarmEnabled then equipWeapon(Options.WeaponSelect.Value) end
end)
selectedWeaponType = WEAPON_TYPES[1]

LeftGroup:AddToggle("FastAttack", { Text = "Fast Attack", Default = false })
Toggles.FastAttack:OnChanged(function()
    FastAttackModule.Enabled = Toggles.FastAttack.Value
    if FastAttackModule.Enabled then
        if not autoNearEnabled and not autoFarmEnabled then startFastAttack() end
        Library:Notify({ Title = "Fast Attack", Description = "Enabled", Time = 3 })
    else
        if not autoNearEnabled and not autoFarmEnabled then stopFastAttack() end
        Library:Notify({ Title = "Fast Attack", Description = "Disabled", Time = 3 })
    end
end)

LeftGroup:AddToggle("AutoNear", { Text = "Auto Farm Nears", Default = false })
Toggles.AutoNear:OnChanged(function()
    autoNearEnabled = Toggles.AutoNear.Value
    if autoNearEnabled then
        if teleportTweenEnabled then Toggles.TweenToIsland:SetValue(false) end
        currentEnemy = nil; trackedRoot = nil; currentFlyCF = HRP and HRP.CFrame or nil
        startNoclip(); startAutoNear()
        Library:Notify({ Title = "Auto Nears", Description = "Enabled", Time = 3 })
    else
        stopFastAttack(); stopHitRegistration(); stopPositionLock(); stopNoclip(); smoothCleanAll()
        if Toggles.FastAttack.Value then FastAttackModule.Enabled = true; startFastAttack() end
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
    if currentEnemy and currentEnemy.Parent then
        local currentMobName = cleanMonsterName(currentEnemy.Name)
        if not table.find(selectedMonsterList, currentMobName) then
            currentEnemy = nil; trackedRoot = nil; smoothCleanAll()
        end
    end
end)
updateSelectedMonstersList()

RightGroup:AddButton({ Text = "Refresh Monster List", Func = function() updateMonsterDropdown(true) end })

local enemiesFolder2 = Workspace:FindFirstChild("Enemies")
if enemiesFolder2 then
    enemiesFolder2.ChildAdded:Connect(function(child)
        if addDiscoveredMonster(child.Name) then updateMonsterDropdown(false) end
    end)
end
local spawnsFolder2 = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
if spawnsFolder2 then
    spawnsFolder2.ChildAdded:Connect(function(child)
        if addDiscoveredMonster(child.Name) then updateMonsterDropdown(false) end
    end)
end

RightGroup:AddToggle("AutoFarm", { Text = "Auto Farm Select", Default = false })
Toggles.AutoFarm:OnChanged(function()
    autoFarmEnabled = Toggles.AutoFarm.Value
    if autoFarmEnabled then
        if teleportTweenEnabled then Toggles.TweenToIsland:SetValue(false) end
        currentEnemy = nil; trackedRoot = nil; currentFlyCF = HRP and HRP.CFrame or nil
        cachedSpawnsByName = {}
        local activeList = updateSelectedMonstersList()
        startNoclip(); startAutoFarm()
        Library:Notify({ Title = "Auto Farm", Description = "Targeting: " .. (#activeList > 0 and table.concat(activeList, ", ") or "None"), Time = 3 })
    else
        stopFastAttack(); stopHitRegistration(); stopPositionLock(); stopNoclip(); smoothCleanAll()
        if Toggles.FastAttack.Value then FastAttackModule.Enabled = true; startFastAttack() end
        Library:Notify({ Title = "Auto Farm", Description = "Disabled", Time = 3 })
    end
end)

RightGroup:AddToggle("BringMob", { Text = "Bring Mob", Default = true })
Toggles.BringMob:OnChanged(function()
    bringMobEnabled = Toggles.BringMob.Value
    if not bringMobEnabled then stopBringMobLoop(); stopInstantBring() end
    Library:Notify({ Title = "Bring Mob", Description = bringMobEnabled and "ON" or "OFF", Time = 3 })
end)

local TeleportLeft  = Tabs.Teleport:AddLeftGroupbox("Island Teleport")
local TeleportRight = Tabs.Teleport:AddRightGroupbox("Teleport Info")

local islandNames, islandMap, worldName = getIslandNamesAndMap(game.PlaceId)
selectedIslandName = islandNames[1]
selectedIslandPos  = islandMap[selectedIslandName]

TeleportLeft:AddLabel("Current Sea: " .. worldName)
TeleportLeft:AddDropdown("IslandSelect", {
    Values = islandNames, Default = 1, Multi = false, Text = "Select Island", Searchable = true,
})
Options.IslandSelect:OnChanged(function()
    selectedIslandName = Options.IslandSelect.Value
    selectedIslandPos  = islandMap[selectedIslandName]
end)

TeleportLeft:AddToggle("TweenToIsland", { Text = "Tween to Island", Default = false })
Toggles.TweenToIsland:OnChanged(function()
    teleportTweenEnabled = Toggles.TweenToIsland.Value
    if teleportTweenEnabled then
        if not selectedIslandPos then
            Library:Notify({ Title = "Teleport", Description = "No destination selected!", Time = 3 })
            Toggles.TweenToIsland:SetValue(false); return
        end
        if autoFarmEnabled then Toggles.AutoFarm:SetValue(false) end
        if autoNearEnabled then Toggles.AutoNear:SetValue(false) end
        startNoclip(); startTeleportTween()
        Library:Notify({ Title = "Teleport", Description = "Going to: " .. tostring(selectedIslandName), Time = 3 })
    else
        stopTeleportTween()
        Library:Notify({ Title = "Teleport", Description = "Stopped", Time = 3 })
    end
end)

TeleportLeft:AddButton({
    Text = "Bypass Teleport",
    Func = function()
        if not selectedIslandPos then
            Library:Notify({ Title = "Teleport", Description = "No destination selected!", Time = 3 }); return
        end
        Library:Notify({ Title = "Bypass Teleport", Description = "Teleporting to " .. tostring(selectedIslandName) .. "...", Time = 3 })
        task.spawn(function()
            _tp(CFrame.new(selectedIslandPos))
            shouldTween = false
            Library:Notify({ Title = "Bypass Teleport", Description = "Arrived at " .. tostring(selectedIslandName), Time = 3 })
        end)
    end,
})

TeleportRight:AddLabel("Place ID: " .. tostring(game.PlaceId))
TeleportRight:AddLabel("Total Islands: " .. tostring(#islandNames))
TeleportRight:AddLabel("Sea: " .. worldName)
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

local FarmLeft  = Tabs.FarmSettings:AddLeftGroupbox("Movement & Position Offset")
local FarmRight = Tabs.FarmSettings:AddRightGroupbox("Bring Mob Settings")

FarmLeft:AddSlider("TweenSpeed", { Text = "Tween Speed", Min = 0, Max = 500, Default = 250, Rounding = 0 })
Options.TweenSpeed:OnChanged(function() CFG.SPEED = tonumber(Options.TweenSpeed.Value) or 250 end)

FarmLeft:AddSlider("OffsetX", { Text = "Offset X", Min = -50, Max = 50, Default = 0, Rounding = 0 })
Options.OffsetX:OnChanged(function() CFG.OFFSET_X = tonumber(Options.OffsetX.Value) or 0 end)

FarmLeft:AddSlider("OffsetY", { Text = "Offset Y", Min = 0, Max = 100, Default = 25, Rounding = 0 })
Options.OffsetY:OnChanged(function() CFG.OFFSET_Y = tonumber(Options.OffsetY.Value) or 25 end)

FarmLeft:AddSlider("OffsetZ", { Text = "Offset Z", Min = -50, Max = 50, Default = 0, Rounding = 0 })
Options.OffsetZ:OnChanged(function() CFG.OFFSET_Z = tonumber(Options.OffsetZ.Value) or 0 end)

FarmLeft:AddSlider("HitRange", { Text = "Hit Range", Min = 10, Max = 200, Default = 100, Rounding = 0 })
Options.HitRange:OnChanged(function() CFG.MAX_DISTANCE = tonumber(Options.HitRange.Value) or 100 end)

FarmRight:AddDropdown("BringMobMode", {
    Values = BRING_MODES, Default = 1, Multi = false, Text = "Bring Mob Mode",
})
Options.BringMobMode:OnChanged(function()
    local raw = Options.BringMobMode.Value
    bringMobMode = string.find(raw, "Instant") and "Instant" or "Smooth"
    Library:Notify({ Title = "Bring Mob Mode", Description = bringMobMode, Time = 3 })
end)

FarmRight:AddSlider("BringRadius", { Text = "BringMob Distance", Min = 0, Max = 500, Default = 300, Rounding = 0 })
Options.BringRadius:OnChanged(function() CFG.BRING_RADIUS = tonumber(Options.BringRadius.Value) or 300 end)

FarmRight:AddSlider("BringCount", { Text = "Bring Mob count", Min = 1, Max = 10, Default = 1, Rounding = 0 })
Options.BringCount:OnChanged(function() CFG.BRING_COUNT = tonumber(Options.BringCount.Value) or 1 end)

FarmRight:AddButton({
    Text = "Reset Value Default",
    Func = function()
        CFG.SPEED = 250; CFG.OFFSET_X = 0; CFG.OFFSET_Y = 25; CFG.OFFSET_Z = 0
        CFG.MAX_DISTANCE = 100; CFG.BRING_RADIUS = 300; CFG.BRING_COUNT = 1; bringMobMode = "Instant"
        Options.TweenSpeed:SetValue(250); Options.OffsetX:SetValue(0)
        Options.OffsetY:SetValue(25); Options.OffsetZ:SetValue(0)
        Options.HitRange:SetValue(100); Options.BringMobMode:SetValue("Instant")
        Options.BringRadius:SetValue(300); Options.BringCount:SetValue(1)
        smoothCleanAll()
        Library:Notify({ Title = "Reset", Description = "Reset to Default", Time = 3 })
    end,
})

local MiscLeft  = Tabs.Misc:AddLeftGroupbox("Settings")
local MiscRight = Tabs.Misc:AddRightGroupbox("Stats Upgrade")

MiscLeft:AddToggle("AutoBuso", { Text = "Auto Turn on Buso", Default = true })
Toggles.AutoBuso:OnChanged(function()
    if Toggles.AutoBuso.Value then Library:Notify({ Title = "Buso Haki", Description = "Auto Buso ON", Time = 3 }) end
end)
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            if Toggles.AutoBuso and Toggles.AutoBuso.Value then
                local char = LocalPlayer.Character
                if char and not char:FindFirstChild("HasBuso") then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
                end
            end
        end)
    end
end)

MiscLeft:AddToggle("AutoObservation", { Text = "Auto Haki Observation", Default = false })
Toggles.AutoObservation:OnChanged(function()
    Library:Notify({ Title = "Observation", Description = Toggles.AutoObservation.Value and "ON" or "OFF", Time = 3 })
end)
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if Toggles.AutoObservation and Toggles.AutoObservation.Value then
                ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
            end
        end)
    end
end)

MiscLeft:AddToggle("AutoRaceV3", { Text = "Auto Turn on Race V3", Default = false })
Toggles.AutoRaceV3:OnChanged(function()
    Library:Notify({ Title = "Race V3", Description = Toggles.AutoRaceV3.Value and "ON" or "OFF", Time = 3 })
end)
task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function()
            if Toggles.AutoRaceV3 and Toggles.AutoRaceV3.Value then
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
                task.wait(30)
            end
        end)
    end
end)

MiscLeft:AddToggle("AutoRaceV4", { Text = "Auto Turn on Race V4", Default = false })
Toggles.AutoRaceV4:OnChanged(function()
    Library:Notify({ Title = "Race V4", Description = Toggles.AutoRaceV4.Value and "ON" or "OFF", Time = 3 })
end)
task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function()
            if Toggles.AutoRaceV4 and Toggles.AutoRaceV4.Value then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("RaceEnergy") and char.RaceEnergy.Value == 1 then
                    local vim1 = game:GetService("VirtualInputManager")
                    vim1:SendKeyEvent(true, "Y", false, game)
                    vim1:SendKeyEvent(false, "Y", false, game)
                end
            end
        end)
    end
end)

MiscLeft:AddToggle("SafeMode", { Text = "Safe Mode (Fly up when low HP)", Default = false })
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if Toggles.SafeMode and Toggles.SafeMode.Value then
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    local hrp2 = char:FindFirstChild("HumanoidRootPart")
                    if hum and hrp2 and (hum.Health / hum.MaxHealth * 100) < safeHealthThreshold then
                        shouldTween = true
                        _tp(hrp2.CFrame * CFrame.new(0, 500, 0))
                    end
                end
            end
        end)
    end
end)

MiscLeft:AddToggle("WalkOnWater", { Text = "Walk on Water", Default = true })
Toggles.WalkOnWater:OnChanged(function()
    pcall(function()
        workspace.Map["WaterBase-Plane"].Size = Toggles.WalkOnWater.Value
            and Vector3.new(1000, 112, 1000)
            or Vector3.new(1000, 80, 1000)
    end)
    Library:Notify({ Title = "Walk on Water", Description = Toggles.WalkOnWater.Value and "ON" or "OFF", Time = 3 })
end)
pcall(function() workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000, 112, 1000) end)

MiscLeft:AddToggle("IceWalk", { Text = "Ice Walk", Default = false })
Toggles.IceWalk:OnChanged(function()
    local oldIce = workspace:FindFirstChild("IceWalkPlatform_KKKK")
    if oldIce then oldIce:Destroy() end
    Library:Notify({ Title = "Ice Walk", Description = Toggles.IceWalk.Value and "ON" or "OFF", Time = 3 })
end)
task.spawn(function()
    while true do
        task.wait()
        pcall(function()
            if not Toggles.IceWalk or not Toggles.IceWalk.Value then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local spike = ReplicatedStorage.Assets.Models.IceSpikes4:Clone()
            spike.Parent = workspace
            spike.Size = Vector3.new(3 + math.random(10, 12), 1.7, 3 + math.random(10, 12))
            spike.Color = Color3.fromRGB(128, 187, 219)
            spike.CFrame = CFrame.new(hrp.Position.X, -3.8, hrp.Position.Z)
                * CFrame.Angles((math.random()-0.5)*0.06, math.random()*7, (math.random()-0.5)*0.07)
            spike.Anchored = true; spike.CanCollide = true; spike.CanTouch = false
            local tween = TweenService:Create(spike, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = Vector3.new(0, 0.3, 0)})
            tween.Completed:Connect(function() spike:Destroy() end)
            tween:Play()
        end)
    end
end)

MiscLeft:AddToggle("AntiAFK", { Text = "Anti AFK", Default = true })
do
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAFK and Toggles.AntiAFK.Value then
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end)
end

MiscLeft:AddToggle("AntiAdmin", { Text = "Auto Anti-Admin Join Server", Default = true })
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
            if Toggles.AntiAdmin and Toggles.AntiAdmin.Value then
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

local MiscServ = Tabs.Misc:AddLeftGroupbox("Server")

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
    Text = "Hop Server",
    Func = function()
        task.spawn(function()
            pcall(function()
                local Http = game:GetService("HttpService")
                local TPS2 = game:GetService("TeleportService")
                local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
                local data = Http:JSONDecode(req)
                for _, sv in pairs(data.data) do
                    if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                        TPS2:TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                        return
                    end
                end
            end)
        end)
    end,
})

MiscServ:AddButton({
    Text = "Copy Job ID",
    Func = function()
        setclipboard(tostring(game.JobId))
        Library:Notify({ Title = "Copied", Description = "Job ID copied to clipboard", Time = 3 })
    end,
})

local MiscGfx = Tabs.Misc:AddRightGroupbox("Graphics")

MiscGfx:AddToggle("FullBright", { Text = "Full Bright", Default = false })
Toggles.FullBright:OnChanged(function()
    if Toggles.FullBright.Value then
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.ColorShift_Bottom = Color3.new(1,1,1)
        Lighting.ColorShift_Top = Color3.new(1,1,1)
    else
        Lighting.Ambient = Color3.new(0,0,0)
        Lighting.ColorShift_Bottom = Color3.new(0,0,0)
        Lighting.ColorShift_Top = Color3.new(0,0,0)
    end
    Library:Notify({ Title = "Full Bright", Description = Toggles.FullBright.Value and "ON" or "OFF", Time = 3 })
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

MiscRight:AddSlider("StatValue", { Text = "Stats Value", Min = 1, Max = 1000, Default = 10, Rounding = 0 })
Options.StatValue:OnChanged(function() pSats = tonumber(Options.StatValue.Value) or 10 end)

MiscRight:AddToggle("AutoMelee",    { Text = "Auto Melee",      Default = false })
MiscRight:AddToggle("AutoSword",    { Text = "Auto Sword",      Default = false })
MiscRight:AddToggle("AutoGun",      { Text = "Auto Gun",        Default = false })
MiscRight:AddToggle("AutoBloxFruit",{ Text = "Auto Blox Fruit", Default = false })
MiscRight:AddToggle("AutoDefense",  { Text = "Auto Defense",    Default = false })

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            if Toggles.AutoMelee     and Toggles.AutoMelee.Value     then statsSetings("Melee",   pSats) end
            if Toggles.AutoSword     and Toggles.AutoSword.Value     then statsSetings("Sword",   pSats) end
            if Toggles.AutoGun       and Toggles.AutoGun.Value       then statsSetings("Gun",     pSats) end
            if Toggles.AutoBloxFruit and Toggles.AutoBloxFruit.Value then statsSetings("Devil",   pSats) end
            if Toggles.AutoDefense   and Toggles.AutoDefense.Value   then statsSetings("Defense", pSats) end
        end)
    end
end)

local EspLeft  = Tabs.Esp:AddLeftGroupbox("ESP Options")
local EspRight = Tabs.Esp:AddRightGroupbox("ESP Info")

EspLeft:AddToggle("EspPlayer", { Text = "ESP Player", Default = false })
Toggles.EspPlayer:OnChanged(function()
    ESP.Player = Toggles.EspPlayer.Value
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
    ESP.DevilFruit = Toggles.EspFruit.Value
    Library:Notify({ Title = "ESP Fruit", Description = ESP.DevilFruit and "ON" or "OFF", Time = 2 })
end)

EspLeft:AddToggle("EspIsland", { Text = "ESP Island", Default = false })
Toggles.EspIsland:OnChanged(function()
    ESP.Island = Toggles.EspIsland.Value
    if not ESP.Island then
        for _, v in next, workspace["_WorldOrigin"].Locations:GetChildren() do
            pcall(function()
                if v:FindFirstChild('NameEsp') then v:FindFirstChild('NameEsp'):Destroy() end
            end)
        end
    end
    Library:Notify({ Title = "ESP Island", Description = ESP.Island and "ON" or "OFF", Time = 2 })
end)

EspLeft:AddToggle("EspFlower", { Text = "ESP Flower", Default = false })
Toggles.EspFlower:OnChanged(function()
    ESP.Flower = Toggles.EspFlower.Value
    Library:Notify({ Title = "ESP Flower", Description = ESP.Flower and "ON" or "OFF", Time = 2 })
end)

EspLeft:AddToggle("EspChest", { Text = "ESP Chest", Default = false })
Toggles.EspChest:OnChanged(function()
    ESP.Chest = Toggles.EspChest.Value
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
    ESP.EventIsland = Toggles.EspEventIsland.Value
    Library:Notify({ Title = "ESP Event Island", Description = ESP.EventIsland and "ON" or "OFF", Time = 2 })
end)

EspLeft:AddToggle("EspLegenSword", { Text = "ESP Legendary Sword Dealer", Default = false })
Toggles.EspLegenSword:OnChanged(function()
    ESP.LegenSword = Toggles.EspLegenSword.Value
    if not ESP.LegenSword then
        if workspace:FindFirstChild("LgdKKKK") then workspace.LgdKKKK:Destroy() end
    end
    Library:Notify({ Title = "ESP Legendary", Description = ESP.LegenSword and "ON" or "OFF", Time = 2 })
end)

EspLeft:AddToggle("EspBerry", { Text = "ESP Berry Bush", Default = false })
Toggles.EspBerry:OnChanged(function()
    ESP.Berry = Toggles.EspBerry.Value
    if not ESP.Berry then
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name:match("BerryEspKKKK_.*") then v:Destroy() end
        end
    end
    Library:Notify({ Title = "ESP Berry", Description = ESP.Berry and "ON" or "OFF", Time = 2 })
end)

EspRight:AddLabel("All ESP updates every 0.1s")
EspRight:AddLabel("Blue = Same Team")
EspRight:AddLabel("Red = Enemy Team")

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightAlt", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        autoNearEnabled = false; autoFarmEnabled = false; teleportTweenEnabled = false
        FastAttackModule.Enabled = false; shouldTween = false
        stopFastAttack(); stopHitRegistration(); stopPositionLock()
        stopNoclip(); smoothCleanAll(); stopTeleportTween()
        if followConn then followConn:Disconnect(); followConn = nil end
        if farmConn   then farmConn:Disconnect();   farmConn   = nil end
        pcall(function() block:Destroy() end)
        ESP.Player = false; ESP.Island = false; ESP.DevilFruit = false
        ESP.Flower = false; ESP.Chest = false; ESP.EventIsland = false
        ESP.LegenSword = false; ESP.Berry = false
        if workspace:FindFirstChild("LgdKKKK") then workspace.LgdKKKK:Destroy() end
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name:match("BerryEspKKKK_.*") then v:Destroy() end
        end
        Library:Unload()
    end,
})
Library.ToggleKeybind = Options.MenuKeybind

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HRP       = newChar:WaitForChild("HumanoidRootPart")
    Humanoid  = newChar:WaitForChild("Humanoid")
    currentEnemy = nil; trackedRoot = nil; currentFlyCF = nil
    cachedSpawnsByName = {}; shouldTween = false
    refreshFolders()
    stopPositionLock(); smoothCleanAll()
    task.wait(1)
    startHitRegistration()
    if autoNearEnabled then startNoclip(); startAutoNear() end
    if autoFarmEnabled then startNoclip(); startAutoFarm() end
    if teleportTweenEnabled then startNoclip(); startTeleportTween() end
    if Toggles.FastAttack.Value and not autoNearEnabled and not autoFarmEnabled then
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

Library:Notify({ Title = "KKKK Hub", Description = "Loaded - Enhanced Edition", Time = 6 })
SaveManager:LoadAutoloadConfig()
