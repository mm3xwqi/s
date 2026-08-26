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
    Main            = Window:AddTab("Main", "sword"),
    Teleport        = Window:AddTab("Teleport", "map-pin"),
    FarmSettings    = Window:AddTab("Farm Settings", "settings-2"),
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

-- CONFIG 
local SESSION_ID   = "32501259"
local MAX_DISTANCE = 100
local MIN_DISTANCE = 1
local SPEED        = 250
local REACH        = 6
local WEAPON_TYPES = {"Melee", "Sword", "Gun", "Fruit"}

local OFFSET_X     = 0
local OFFSET_Y     = 25
local OFFSET_Z     = 0
local BRING_RADIUS = 300
local BRING_COUNT  = 1
local BRING_MODES  = {"Instant (BestPrivate server)", "Smooth (Best Public Server)"}

-- BYPASS TELEPORT SYSTEM 
local sea1 = (game.PlaceId == 2753915549 or game.PlaceId == 85211729168715)
local sea2 = (game.PlaceId == 4442272183 or game.PlaceId == 79091703265657)
local sea3 = (game.PlaceId == 7449423635 or game.PlaceId == 100117331123089)

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
    if GetDistance(x.Position) <= 3500 then return false end
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
                c.LastSpawnPoint.Disabled = true
            end)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetLastSpawnPoint", TargetTP.Name)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
            c:PivotTo(TargetTP.Part.CFrame)
            h:ChangeState(15)
            repeat task.wait() until LocalPlayer.Character and WaitForHumanoid() and WaitForHumanoid().Health > 0
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
            ["Hydra Island"]    = Vector3.new(5657.88, 1013.08, -335.50),
            ["Mansion"]         = Vector3.new(-12462, 375, -7552),
            ["Castle"]          = Vector3.new(-5036, 315, -3179),
            ["Temple of Time"]  = Vector3.new(28286, 14897, 103),
            ["Greate Tree"]     = Vector3.new(3024.17, 2280.69, -7325.13),
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

    pcall(function()
        requestentrance(target)
    end)

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

-- FastAttackModule 
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

function FastAttackModule.IsAlive(target)
    local humanoid = target:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

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

-- Fast Attack Loop 
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

-- TELEPORT DATA 
local TELEPORT_LOCATIONS = {
    [2753915549] = {
        WorldName = "Old World (Sea 1)",
        Locations = {
            { Name = "Pirate Starter",      Pos = Vector3.new(885, 17, 1429) },
            { Name = "Middle Island",       Pos = Vector3.new(-690, 15, 1584) },
            { Name = "Marine Starter",      Pos = Vector3.new(-2600, 7, 2068) },
            { Name = "Jungle island",       Pos = Vector3.new(-1445, 62, -34) },
            { Name = "Pirate island",       Pos = Vector3.new(-1218, 5, 3922) },
            { Name = "Desert island",       Pos = Vector3.new(942, 21, 4372) },
            { Name = "Snow island",         Pos = Vector3.new(1345, 106, -1319) },
            { Name = "Sky",                 Pos = Vector3.new(-4817, 718, -2628) },
            { Name = "sky 1",               Pos = Vector3.new(-4714, 853, -1932) },
            { Name = "sky 2",               Pos = Vector3.new(-7921, 5566, -379) },
            { Name = "Usop",                Pos = Vector3.new(-7990, 5756, -1927) },
            { Name = "Colosseum island",    Pos = Vector3.new(-1453, 7, -2848) },
            { Name = "Fishmen island",      Pos = Vector3.new(3906, 5, -1893) },
            { Name = "Prison island",       Pos = Vector3.new(5010, 89, 738) },
            { Name = "Fountain island",     Pos = Vector3.new(5273, 81, 3987) },
            { Name = "Magma island",        Pos = Vector3.new(-5241, 9, 8413) },
            { Name = "MarineBase island",   Pos = Vector3.new(-4816, 21, 4360) },
            { Name = "Mob Leader",          Pos = Vector3.new(-2844, 7, 5309) },
        }
    },
    [4442272183] = {
        WorldName = "Second World (Sea 2)",
        Locations = {
            { Name = "Dock 1",              Pos = Vector3.new(-10, 39, 2703) },
            { Name = "Mansion",             Pos = Vector3.new(-393, 360, 546) },
            { Name = "Cafe",                Pos = Vector3.new(-373, 73, 296) },
            { Name = "Race Evo",            Pos = Vector3.new(-2007, 126, -74) },
            { Name = "Dock 2",              Pos = Vector3.new(-1917, 6, -2546) },
            { Name = "Green Zone",          Pos = Vector3.new(-2456, 87, -3188) },
            { Name = "TTk",                 Pos = Vector3.new(-2573, 1626, -3742) },
            { Name = "Ice island",          Pos = Vector3.new(-5897, 29, -5055) },
            { Name = "Hot island",          Pos = Vector3.new(-5012, 176, -5320) },
            { Name = "Forgotten island",    Pos = Vector3.new(-3043, 240, -10140) },
            { Name = "IceCastle island",    Pos = Vector3.new(6000, 294, -6611) },
            { Name = "SnowMountain island", Pos = Vector3.new(800, 412, -5250) },
            { Name = "Raid",                Pos = Vector3.new(-6483, 305, -4736) },
            { Name = "ZombieVampire island",Pos = Vector3.new(-5648, 185, -888) },
            { Name = "Ship island",         Pos = Vector3.new(-6525, 83, -156) },
        }
    },
    [7449423635] = {
        WorldName = "Third World (Sea 3)",
        Locations = {
            { Name = "port town",           Pos = Vector3.new(-340, 21, 5538) },
            { Name = "Castle island",       Pos = Vector3.new(-5135, 314, -2957) },
            { Name = "Hydra town",          Pos = Vector3.new(5295, 1005, 380) },
            { Name = "Hydra Arena",         Pos = Vector3.new(5016, 59, -1556) },
            { Name = "Mansion turtle",      Pos = Vector3.new(-12551, 337, -7481) },
            { Name = "beautiful pirate",    Pos = Vector3.new(5372, 22, -306) },
            { Name = "Tiki island",         Pos = Vector3.new(-16398, 528, 403) },
            { Name = "Haunted Castle",      Pos = Vector3.new(-9512, 142, 5540) },
            { Name = "Katakuri island",     Pos = Vector3.new(-2094, 70, -12125) },
            { Name = "Bigmom island",       Pos = Vector3.new(-890, 66, -10899) },
            { Name = "Chocolate island",    Pos = Vector3.new(-6, 21, -12049) },
            { Name = "North Pole",          Pos = Vector3.new(-1096, 64, -14515) },
            { Name = "Great tree",          Pos = Vector3.new(2391, 74, -7006) },
            { Name = "Upper Great tree",    Pos = Vector3.new(3038, 2281, -7325) },
        }
    }
}

local function getIslandNamesAndMap(placeId)
    local data = TELEPORT_LOCATIONS[placeId] or TELEPORT_LOCATIONS[2753915549]
    local names, map = {}, {}
    for _, loc in ipairs(data.Locations) do
        table.insert(names, loc.Name)
        map[loc.Name] = loc.Pos
    end
    return names, map, data.WorldName
end

-- STATE 
local autoNearEnabled      = false
local autoFarmEnabled      = false
local bringMobEnabled      = true
local bringMobMode         = "Instant"
local teleportTweenEnabled = false

local selectedWeaponType   = "Melee"
local selectedMonsterList  = {}
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

local cachedSpawnsByName   = {}
local smoothData           = {}

local discoveredMonsters   = {}
local masterMonsterList    = {}

-- NOCLIP 
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

-- POSITION LOCK 
local function startPositionLock()
    if lockConn then lockConn:Disconnect() end
    if Humanoid then pcall(function() Humanoid.AutoRotate = false end) end
    lockConn = RunService.RenderStepped:Connect(function()
        if not (autoNearEnabled or autoFarmEnabled or teleportTweenEnabled) then
            if lockConn then lockConn:Disconnect(); lockConn = nil end
            return
        end
        if currentFlyCF and HRP then
            pcall(function()
                HRP.CFrame = currentFlyCF
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end

local function stopPositionLock()
    if lockConn then lockConn:Disconnect(); lockConn = nil end
    currentFlyCF = nil
    if Humanoid then pcall(function() Humanoid.AutoRotate = true end) end
end

-- CHARACTER 
local function updateCharacter()
    Character = LocalPlayer.Character
    if not Character then return false end
    HRP      = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid and (autoNearEnabled or autoFarmEnabled or teleportTweenEnabled) then
        Humanoid.AutoRotate = false
    end
    return HRP ~= nil and Humanoid ~= nil
end

-- UTILITY 
local function cleanMonsterName(name)
    if not name then return "" end
    return (name:gsub("%s*%[.-%]", "")):match("^%s*(.-)%s*$") or ""
end

local function getHitPart(enemy)
    if not enemy or not enemy.Parent then return nil end
    for _, name in ipairs({"LeftLowerLeg", "Head", "HumanoidRootPart"}) do
        local p = enemy:FindFirstChild(name)
        if p and p:IsA("BasePart") then return p end
    end
    for _, child in ipairs(enemy:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

local function getEnemyRoot(enemy)
    if not enemy or not enemy.Parent then return nil end
    return enemy:FindFirstChild("HumanoidRootPart")
end

local function snapHeightToEnemy(rootPart)
    if not rootPart or not HRP then return end
    pcall(function()
        HRP.AssemblyLinearVelocity = Vector3.zero
        local targetY = rootPart.Position.Y + OFFSET_Y
        local baseCF  = currentFlyCF or HRP.CFrame
        currentFlyCF  = CFrame.new(baseCF.Position.X, targetY, baseCF.Position.Z) * baseCF.Rotation
        HRP.CFrame    = currentFlyCF
    end)
end

-- SPAWN CACHE 
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

-- ENEMY FINDER 
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

-- WEAPON 
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

-- SMOOTH CLEANUP 
local function smoothRelease(enemy)
    local d = smoothData[enemy]
    if d then
        for _, k in ipairs({"bp", "bv", "bg"}) do
            if d[k] and d[k].Parent then pcall(function() d[k]:Destroy() end) end
        end
        smoothData[enemy] = nil
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

local function smoothCleanAll()
    for enemy in pairs(smoothData) do pcall(smoothRelease, enemy) end
    smoothData = {}
end

-- BRING MOB 
local function lockAndBringMobs(targetEnemy, lockPos, isSameTypeOnly, monsterName)
    if not targetEnemy or not targetEnemy.Parent or not lockPos then return end
    local targetRoot = targetEnemy:FindFirstChild("HumanoidRootPart")
    local targetHum  = targetEnemy:FindFirstChildOfClass("Humanoid")
    if not targetRoot or not targetHum or targetHum.Health <= 0 then return end
    pcall(function()
        for _, part in ipairs(targetEnemy:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        targetRoot.CFrame = CFrame.new(lockPos)
        targetRoot.AssemblyLinearVelocity  = Vector3.zero
        targetRoot.AssemblyAngularVelocity = Vector3.zero
    end)
    if not bringMobEnabled then
        if next(smoothData) then smoothCleanAll() end
        return
    end
    local folder = EnemiesFolder or Workspace:FindFirstChild("Enemies")
    if not folder then return end
    local candidates = {}
    for _, model in ipairs(folder:GetChildren()) do
        if model ~= targetEnemy and model.Parent then
            local match = true
            if isSameTypeOnly and monsterName then match = (cleanMonsterName(model.Name) == monsterName) end
            if match then
                local hum  = model:FindFirstChildOfClass("Humanoid")
                local root = model:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - lockPos).Magnitude
                    if dist <= BRING_RADIUS then
                        table.insert(candidates, {model = model, root = root, hum = hum, dist = dist})
                    end
                end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    local countToBring = math.min(BRING_COUNT, #candidates)
    if bringMobMode == "Instant" then
        if next(smoothData) then smoothCleanAll() end
        for i = 1, countToBring do
            local entry = candidates[i]
            pcall(function()
                for _, part in ipairs(entry.model:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                entry.root.CFrame = CFrame.new(lockPos)
                entry.root.AssemblyLinearVelocity  = Vector3.zero
                entry.root.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
end

-- MOVEMENT 
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
    local step       = SPEED * dt
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

-- AUTO NEAR 
local function startAutoNear()
    if followConn then followConn:Disconnect() end
    local prevEnemy = nil
    if HRP then currentFlyCF = HRP.CFrame end
    startPositionLock()

    followConn = RunService.Heartbeat:Connect(function(dt)
        if not autoNearEnabled then
            followConn:Disconnect(); followConn = nil
            stopFastAttack(); stopHitRegistration(); stopPositionLock(); stopNoclip(); smoothCleanAll()
            return
        end
        if not updateCharacter() then return end
        equipWeapon(selectedWeaponType)

        local enemyHum  = currentEnemy and currentEnemy:FindFirstChildOfClass("Humanoid")
        local enemyRoot = currentEnemy and currentEnemy:FindFirstChild("HumanoidRootPart")

        if not currentEnemy or not enemyRoot or not enemyHum or enemyHum.Health <= 0 then
            stopFastAttack()
            trackedRoot  = nil
            currentEnemy = getClosestEnemy()
            prevEnemy    = nil
            if not currentEnemy then return end
            trackedRoot = getEnemyRoot(currentEnemy)
            snapHeightToEnemy(trackedRoot)
        end

        if not trackedRoot or not trackedRoot.Parent then
            trackedRoot = getEnemyRoot(currentEnemy)
            if not trackedRoot then return end
            snapHeightToEnemy(trackedRoot)
        end

        local spawnPos = getEnemySpawnPosition(currentEnemy) or trackedRoot.Position
        lockAndBringMobs(currentEnemy, spawnPos, false, nil)

        local targetCF = CFrame.new(spawnPos + Vector3.new(OFFSET_X, OFFSET_Y, OFFSET_Z))
        local dist = (targetCF.Position - (currentFlyCF and currentFlyCF.Position or HRP.Position)).Magnitude

        if dist > REACH then
            stopFastAttack()
            prevEnemy = nil
            moveToTarget(HRP, targetCF, dt)
        else
            currentFlyCF = targetCF
            pcall(function()
                HRP.CFrame = targetCF
                HRP.AssemblyLinearVelocity  = Vector3.zero
                HRP.AssemblyAngularVelocity = Vector3.zero
            end)
            if currentEnemy ~= prevEnemy then
                prevEnemy = currentEnemy
                FastAttackModule.Enabled = true
                startFastAttack()
                startHitRegistration()
            end
        end
    end)
end

-- AUTO FARM 
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
            lockAndBringMobs(target, spawnPos, true, targetMonsterName)

            local targetCF = CFrame.new(spawnPos + Vector3.new(OFFSET_X, OFFSET_Y, OFFSET_Z))
            local dist = (targetCF.Position - (currentFlyCF and currentFlyCF.Position or HRP.Position)).Magnitude

            if dist > REACH then
                stopFastAttack()
                prevEnemy = nil
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
                    startFastAttack()
                    startHitRegistration()
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

            local spawnPos = spawns[spawnIdx] + Vector3.new(OFFSET_X, OFFSET_Y, OFFSET_Z)
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
            if dist > REACH then
                moveToTarget(HRP, targetCF, dt)
            else
                snapDone = false; spawnIdx = spawnIdx % #spawns + 1
            end
        end
    end)
end

-- TELEPORT TWEEN
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
        if dist > REACH then
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

-- SCAN INITIAL 
scanAllMonsters()
startHitRegistration()
local initialMonsterList = #masterMonsterList > 0 and masterMonsterList or {"(ไม่พบมอน)"}

-- UI: MAIN TAB 
local LeftGroup  = Tabs.Main:AddLeftGroupbox("Combat")
local RightGroup = Tabs.Main:AddRightGroupbox("Farm")

LeftGroup:AddDropdown("WeaponSelect", {
    Values  = WEAPON_TYPES,
    Default = 1,
    Multi   = false,
    Text    = "Equip Item",
})
Options.WeaponSelect:OnChanged(function()
    selectedWeaponType = Options.WeaponSelect.Value
    if autoNearEnabled or autoFarmEnabled then equipWeapon(Options.WeaponSelect.Value) end
end)
selectedWeaponType = WEAPON_TYPES[1]

LeftGroup:AddToggle("FastAttack", {
    Text    = "Fast Attack",
    Default = false,
})
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

LeftGroup:AddToggle("AutoNear", {
    Text    = "Auto Farm Nears",
    Default = false,
})
Toggles.AutoNear:OnChanged(function()
    autoNearEnabled = Toggles.AutoNear.Value
    if autoNearEnabled then
        if teleportTweenEnabled then Toggles.TweenToIsland:SetValue(false) end
        currentEnemy = nil; trackedRoot = nil; currentFlyCF = HRP and HRP.CFrame or nil
        startNoclip(); startAutoNear()
        Library:Notify({ Title = "Auto Nears", Description = "Enabled", Time = 3 })
    else
        stopFastAttack(); stopHitRegistration(); stopPositionLock(); stopNoclip(); smoothCleanAll()
        if Toggles.FastAttack.Value then
            FastAttackModule.Enabled = true
            startFastAttack()
        end
        Library:Notify({ Title = "Auto Nears", Description = "Disabled", Time = 3 })
    end
end)

RightGroup:AddDropdown("MonsterSelect", {
    Values     = initialMonsterList,
    Default    = initialMonsterList[1] and { [initialMonsterList[1]] = true } or {},
    Multi      = true,
    Text       = "Select Monsters (Multi)",
    Searchable = true,
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

RightGroup:AddButton({
    Text = "Refresh Monster List",
    Func = function() updateMonsterDropdown(true) end,
})

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

RightGroup:AddToggle("AutoFarm", {
    Text    = "Auto Farm Select",
    Default = false,
})
Toggles.AutoFarm:OnChanged(function()
    autoFarmEnabled = Toggles.AutoFarm.Value
    if autoFarmEnabled then
        if teleportTweenEnabled then Toggles.TweenToIsland:SetValue(false) end
        currentEnemy = nil; trackedRoot = nil; currentFlyCF = HRP and HRP.CFrame or nil
        cachedSpawnsByName = {}
        local activeList = updateSelectedMonstersList()
        startNoclip(); startAutoFarm()
        local desc = #activeList > 0 and table.concat(activeList, ", ") or "None"
        Library:Notify({ Title = "Auto Farm", Description = "Targeting: " .. desc, Time = 3 })
    else
        stopFastAttack(); stopHitRegistration(); stopPositionLock(); stopNoclip(); smoothCleanAll()
        if Toggles.FastAttack.Value then
            FastAttackModule.Enabled = true
            startFastAttack()
        end
        Library:Notify({ Title = "Auto Farm", Description = "Disabled", Time = 3 })
    end
end)

RightGroup:AddToggle("BringMob", {
    Text    = "Bring Mob",
    Default = true,
})
Toggles.BringMob:OnChanged(function()
    bringMobEnabled = Toggles.BringMob.Value
    if not bringMobEnabled then smoothCleanAll() end
    Library:Notify({ Title = "Bring Mob", Description = bringMobEnabled and "ON" or "OFF", Time = 3 })
end)

-- TELEPORT TAB 
local TeleportLeft  = Tabs.Teleport:AddLeftGroupbox("Island Teleport")
local TeleportRight = Tabs.Teleport:AddRightGroupbox("Teleport Info")

local islandNames, islandMap, worldName = getIslandNamesAndMap(game.PlaceId)
selectedIslandName = islandNames[1]
selectedIslandPos  = islandMap[selectedIslandName]

TeleportLeft:AddLabel("Current Sea: " .. worldName)

TeleportLeft:AddDropdown("IslandSelect", {
    Values     = islandNames,
    Default    = 1,
    Multi      = false,
    Text       = "Select Island",
    Searchable = true,
})
Options.IslandSelect:OnChanged(function()
    selectedIslandName = Options.IslandSelect.Value
    selectedIslandPos  = islandMap[selectedIslandName]
end)

-- tween to Island
TeleportLeft:AddToggle("TweenToIsland", {
    Text    = "Tween to Island",
    Default = false,
})
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
            Library:Notify({ Title = "Teleport", Description = "No destination selected!", Time = 3 })
            return
        end
        Library:Notify({
            Title = "Bypass Teleport",
            Description = "Teleporting to " .. tostring(selectedIslandName) .. " (with bypass)...",
            Time = 3
        })
        task.spawn(function()
            _tp(CFrame.new(selectedIslandPos))
            shouldTween = false
            Library:Notify({
                Title = "Bypass Teleport",
                Description = "Arrived at " .. tostring(selectedIslandName),
                Time = 3
            })
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
        Library:Notify({
            Title = "Teleport",
            Description = "Reloaded " .. #newNames .. " locations (" .. newWorld .. ")",
            Time = 3
        })
    end,
})

-- FARM SETTINGS TAB 
local FarmLeft  = Tabs.FarmSettings:AddLeftGroupbox("Movement & Position Offset")
local FarmRight = Tabs.FarmSettings:AddRightGroupbox("Bring Mob Settings")

FarmLeft:AddSlider("TweenSpeed", {
    Text = "Tween Speed", Min = 0, Max = 500, Default = 250, Rounding = 0,
})
Options.TweenSpeed:OnChanged(function() SPEED = tonumber(Options.TweenSpeed.Value) or 250 end)

FarmLeft:AddSlider("OffsetX", { Text = "Offset X", Min = -50, Max = 50, Default = 0, Rounding = 0 })
Options.OffsetX:OnChanged(function() OFFSET_X = tonumber(Options.OffsetX.Value) or 0 end)

FarmLeft:AddSlider("OffsetY", { Text = "Offset Y", Min = 0, Max = 100, Default = 25, Rounding = 0 })
Options.OffsetY:OnChanged(function() OFFSET_Y = tonumber(Options.OffsetY.Value) or 25 end)

FarmLeft:AddSlider("OffsetZ", { Text = "Offset Z", Min = -50, Max = 50, Default = 0, Rounding = 0 })
Options.OffsetZ:OnChanged(function() OFFSET_Z = tonumber(Options.OffsetZ.Value) or 0 end)

FarmLeft:AddSlider("HitRange", {
    Text = "Hit Range", Min = 10, Max = 200, Default = 100, Rounding = 0,
})
Options.HitRange:OnChanged(function() MAX_DISTANCE = tonumber(Options.HitRange.Value) or 100 end)

FarmRight:AddDropdown("BringMobMode", {
    Values  = BRING_MODES,
    Default = 1,
    Multi   = false,
    Text    = "Bring Mob Mode",
})
Options.BringMobMode:OnChanged(function()
    bringMobMode = Options.BringMobMode.Value
    smoothCleanAll()
    Library:Notify({ Title = "Bring Mob Mode", Description = bringMobMode, Time = 3 })
end)

FarmRight:AddSlider("BringRadius", {
    Text = "BringMob Distance", Min = 50, Max = 2000, Default = 300, Rounding = 0,
})
Options.BringRadius:OnChanged(function() BRING_RADIUS = tonumber(Options.BringRadius.Value) or 300 end)

FarmRight:AddSlider("BringCount", {
    Text = "Bring Mob count", Min = 1, Max = 10, Default = 1, Rounding = 0,
})
Options.BringCount:OnChanged(function() BRING_COUNT = tonumber(Options.BringCount.Value) or 1 end)

FarmRight:AddButton({
    Text = "Reset Value Default",
    Func = function()
        SPEED = 250; OFFSET_X = 0; OFFSET_Y = 25; OFFSET_Z = 0
        MAX_DISTANCE = 100; BRING_RADIUS = 300; BRING_COUNT = 1; bringMobMode = "Instant"
        Options.TweenSpeed:SetValue(250); Options.OffsetX:SetValue(0)
        Options.OffsetY:SetValue(25);     Options.OffsetZ:SetValue(0)
        Options.HitRange:SetValue(100)
        Options.BringMobMode:SetValue("Instant")
        Options.BringRadius:SetValue(300); Options.BringCount:SetValue(1)
        smoothCleanAll()
        Library:Notify({ Title = "Reset", Description = "Reset to Default", Time = 3 })
    end,
})

-- UI SETTINGS TAB 
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightAlt", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        autoNearEnabled = false; autoFarmEnabled = false
        teleportTweenEnabled = false
        FastAttackModule.Enabled = false
        shouldTween = false
        stopFastAttack(); stopHitRegistration(); stopPositionLock()
        stopNoclip(); smoothCleanAll(); stopTeleportTween()
        if followConn then followConn:Disconnect(); followConn = nil end
        if farmConn   then farmConn:Disconnect();   farmConn   = nil end
        pcall(function() block:Destroy() end)
        Library:Unload()
    end,
})
Library.ToggleKeybind = Options.MenuKeybind

-- CHARACTER RESPAWN 
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HRP       = newChar:WaitForChild("HumanoidRootPart")
    Humanoid  = newChar:WaitForChild("Humanoid")
    currentEnemy = nil; trackedRoot = nil; currentFlyCF = nil
    cachedSpawnsByName = {}
    shouldTween = false
    refreshFolders()
    stopPositionLock(); smoothCleanAll()
    task.wait(1)
    startHitRegistration()
    if autoNearEnabled then startNoclip(); startAutoNear() end
    if autoFarmEnabled then startNoclip(); startAutoFarm() end
    if teleportTweenEnabled then startNoclip(); startTeleportTween() end
    if Toggles.FastAttack.Value and not autoNearEnabled and not autoFarmEnabled then
        FastAttackModule.Enabled = true
        startFastAttack()
    end
end)

-- SAVE / THEME 
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("KKKKHub")
SaveManager:SetFolder("KKKKHub/config")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:Notify({
    Title = "KKKK Hub",
    Description = "Loaded",
    Time = 6
})
SaveManager:LoadAutoloadConfig()
