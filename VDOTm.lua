-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer

-- Cache frequently used services
local workspace = workspace

-- Remotes Cache
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Attacks = Remotes:WaitForChild("Attacks")
local RemotesCache = {
    BasicAttack = Attacks:WaitForChild("BasicAttack"),
    CarryRemote = Remotes:WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent"),
    HookRemote = Remotes:WaitForChild("Carry"):WaitForChild("HookEvent"),
    GeneratorRemote = Remotes:WaitForChild("Generator"):WaitForChild("RepairEvent"),
    ExitRemote = Remotes:WaitForChild("Exit"):WaitForChild("LeverEvent")
}

-- Optimized State
local State = {
    AutoAttack = false,
    AutoFarm = false,
    AutoRepair = false,
    CurrentGenerator = nil,
    CheckingExit = false,
    CancelRepair = false,
    KillerTarget = nil,
    KillerLoopActive = false,
    ExitTpFound = false,
    TargetGenerators = 5,
    LastActionTime = os.time(),
    IsSearchingGenerator = false,
    StatusAutoUpdate = true
}

-- Cache for expensive operations
local Cache = {
    Generators = {data = nil, lastUpdate = 0, ttl = 3},
    Map = {data = nil, lastCheck = 0},
    PlayerHealth = {},
    GeneratorPoints = {},
    StatusText = nil -- Cache status text
}

-- Optimized team checking
local TeamCache = {
    Survivors = Teams:FindFirstChild("Survivors"),
    Spectator = Teams:FindFirstChild("Spectator"),
    Killer = Teams:FindFirstChild("Killer")
}

local function getPlayerTeam(player)
    return player and player.Team
end

local function isSurvivor(player)
    local team = getPlayerTeam(player)
    return team and team == TeamCache.Survivors
end

local function isSpectator(player)
    local team = getPlayerTeam(player)
    return team and team == TeamCache.Spectator
end

local function isKiller(player)
    local team = getPlayerTeam(player)
    return team and team == TeamCache.Killer
end

-- Optimized generator functions with caching
local function getMap()
    if Cache.Map.data and os.time() - Cache.Map.lastCheck < 10 then
        return Cache.Map.data
    end
    Cache.Map.data = workspace:FindFirstChild("Map")
    Cache.Map.lastCheck = os.time()
    return Cache.Map.data
end

local function findGenerators()
    local currentTime = os.time()
    
    if Cache.Generators.data and currentTime - Cache.Generators.lastUpdate < Cache.Generators.ttl then
        return Cache.Generators.data
    end
    
    local generators = {}
    local Map = getMap()
    
    local function processDescendants(parent)
        for _, obj in pairs(parent:GetDescendants()) do
            if obj.Name == "Generator" and obj:IsA("Model") then
                generators[#generators + 1] = obj
            end
        end
    end
    
    processDescendants(workspace)
    if Map then
        local Rooftop = Map:FindFirstChild("Rooftop")
        if Rooftop then
            processDescendants(Rooftop)
        end
    end
    
    Cache.Generators.data = generators
    Cache.Generators.lastUpdate = currentTime
    
    return generators
end

-- Optimized generator point checking with caching
local function hasGeneratorPoint(generatorModel)
    if not generatorModel then return false end
    
    if Cache.GeneratorPoints[generatorModel] ~= nil then
        return Cache.GeneratorPoints[generatorModel]
    end
    
    for i = 1, 4 do
        local point = generatorModel:FindFirstChild("GeneratorPoint" .. i)
        if point and point:IsA("Part") then
            Cache.GeneratorPoints[generatorModel] = true
            return true
        end
    end
    
    Cache.GeneratorPoints[generatorModel] = false
    return false
end

-- Optimized repair progress check
local function checkRepairProgress(generatorModel)
    if not generatorModel then return 0 end
    
    local success, repairProgress = pcall(function()
        return generatorModel:GetAttribute("RepairProgress")
    end)
    
    if success and repairProgress then
        return repairProgress
    end
    
    local repairProgressValue = generatorModel:FindFirstChild("RepairProgress")
    if repairProgressValue and repairProgressValue:IsA("NumberValue") then
        return repairProgressValue.Value
    end
    
    return 0
end

-- Batch count completed generators
local function countCompletedGenerators()
    local generators = findGenerators()
    local completed = 0
    
    for i = 1, #generators do
        if checkRepairProgress(generators[i]) >= 100 then
            completed = completed + 1
        end
    end
    
    return completed, #generators
end

-- Optimized status generation with text caching
local function getAllGeneratorsStatus()
    local currentTime = os.time()
    
    -- Return cached text if generators haven't changed
    if Cache.StatusText and currentTime - Cache.Generators.lastUpdate < 1 then
        return Cache.StatusText
    end
    
    local generators = findGenerators()
    local completedCount = 0
    local lines = {"-- Generator Status (All 7)"}
    
    -- Sort by a consistent key (use object reference hash for stability)
    table.sort(generators, function(a, b) 
        return tostring(a):lower() < tostring(b):lower()
    end)
    
    for i = 1, math.min(7, #generators) do
        local generator = generators[i]
        local progress = checkRepairProgress(generator)
        local hasPoint = hasGeneratorPoint(generator)
        local status = progress >= 100 and "✅ COMPLETED" or ("🔄 " .. math.floor(progress) .. "%")
        local pointStatus = hasPoint and "🟢" or "🔴"
        
        lines[#lines + 1] = string.format("Gen %d: %s %s", i, status, pointStatus)
        
        if progress >= 100 then
            completedCount = completedCount + 1
        end
    end
    
    lines[#lines + 1] = string.format("\n-- Summary: %d/7 Completed", completedCount)
    lines[#lines + 1] = string.format("-- Auto Update: %s", State.StatusAutoUpdate and "🟢 ON" or "🔴 OFF")
    
    local statusText = table.concat(lines, "\n")
    Cache.StatusText = statusText
    
    return statusText
end

-- Optimized generator point finding
local function findGeneratorPoint(generatorModel)
    if not generatorModel then return nil end
    
    for i = 1, 4 do
        local point = generatorModel:FindFirstChild("GeneratorPoint" .. i)
        if point and point:IsA("Part") then
            return point
        end
    end
    
    return nil
end

-- Optimized teleport function
local function teleportToGenerator(generatorModel)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local generatorPoint = findGeneratorPoint(generatorModel)
    local primaryPart = character.PrimaryPart
    
    if generatorPoint and primaryPart then
        local cframe = generatorPoint.CFrame
        character:SetPrimaryPartCFrame(cframe + cframe.LookVector * -3)
        State.CurrentGenerator = generatorModel
        State.LastActionTime = os.time()
        return true
    end
    
    State.CurrentGenerator = nil
    return false
end

-- Optimized status checking
local function checkCurrentGeneratorStatus()
    if not State.CurrentGenerator then return false end
    
    if not State.CurrentGenerator.Parent then
        State.CurrentGenerator = nil
        return false
    end
    
    if not hasGeneratorPoint(State.CurrentGenerator) then
        State.CurrentGenerator = nil
        return false
    end
    
    if checkRepairProgress(State.CurrentGenerator) >= 100 then
        State.CurrentGenerator = nil
        return false
    end
    
    return true
end

-- Optimized repair function
local function repairGenerator(generatorModel)
    if not generatorModel then return false end
    
    local generatorPoint = findGeneratorPoint(generatorModel)
    if not generatorPoint then return false end
    
    local function tryRepair(args)
        local success = pcall(function()
            RemotesCache.GeneratorRemote:FireServer(unpack(args))
        end)
        if success then
            State.LastActionTime = os.time()
            return true
        end
        return false
    end
    
    return tryRepair({generatorPoint, true}) or tryRepair({generatorPoint})
end

-- Optimized exit lever finding with caching
local function findExitLever()
    local currentTime = os.time()
    
    local Map = getMap()
    if not Map then return nil end
    
    local Gate = Map:FindFirstChild("Gate") or (Map:FindFirstChild("Rooftop") and Map.Rooftop:FindFirstChild("Gate"))
    if not Gate then return nil end
    
    local ExitLever = Gate:FindFirstChild("ExitLever")
    if not ExitLever then return nil end
    
    return {ExitLever:FindFirstChild("Tp"), ExitLever:FindFirstChild("Main")}
end

-- Optimized player health checking with caching
local function checkPlayerHealth(playerName)
    local currentTime = os.time()
    local cache = Cache.PlayerHealth[playerName]
    
    if cache and currentTime - cache.time < 0.5 then
        return cache.data
    end
    
    local playerModel = workspace:FindFirstChild(playerName)
    if not playerModel then
        Cache.PlayerHealth[playerName] = {data = {health = 0, maxHealth = 0, found = false}, time = currentTime}
        return Cache.PlayerHealth[playerName].data
    end
    
    local humanoid = playerModel:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        Cache.PlayerHealth[playerName] = {data = {health = 0, maxHealth = 0, found = true, hasHumanoid = false}, time = currentTime}
        return Cache.PlayerHealth[playerName].data
    end
    
    local healthData = {
        health = humanoid.Health,
        maxHealth = humanoid.MaxHealth,
        found = true,
        hasHumanoid = true,
        lowHealth = (humanoid.Health <= 20)
    }
    
    Cache.PlayerHealth[playerName] = {data = healthData, time = currentTime}
    return healthData
end

-- Optimized best generator selection
local function findBestGenerator()
    local generators = findGenerators()
    local bestGenerator, highestProgress = nil, -1
    
    for i = 1, #generators do
        local generator = generators[i]
        if not hasGeneratorPoint(generator) then continue end
        
        local progress = checkRepairProgress(generator)
        if progress >= 100 then continue end
        
        if progress > highestProgress then
            highestProgress = progress
            bestGenerator = generator
        end
    end
    
    if not bestGenerator then
        for i = 1, #generators do
            local generator = generators[i]
            if hasGeneratorPoint(generator) and checkRepairProgress(generator) < 100 then
                bestGenerator = generator
                break
            end
        end
    end
    
    return bestGenerator
end

-- Optimized main loops with better task management
local function continuousRepair()
    local startTime = os.time()
    local maxRepairTime = 120
    
    while State.AutoRepair and State.CurrentGenerator and not State.CancelRepair do
        if not checkCurrentGeneratorStatus() then break end
        if os.time() - startTime > maxRepairTime then break end
        
        repairGenerator(State.CurrentGenerator)
        
        if checkRepairProgress(State.CurrentGenerator) >= 100 then
            State.CurrentGenerator = nil
            break
        end
        
        task.wait(0.3)
    end
    
    State.CancelRepair = false
end

local function autoRepair()
    local stuckCount = 0
    
    while State.AutoRepair and isSurvivor(LocalPlayer) do
        State.LastActionTime = os.time()
        
        if os.time() - State.LastActionTime > 30 then
            stuckCount = stuckCount + 1
            State.CurrentGenerator = nil
            if stuckCount >= 3 then
                State.AutoRepair = false
                task.wait(5)
                stuckCount = 0
            end
        else
            stuckCount = 0
        end
        
        local completed = countCompletedGenerators()
        if completed >= State.TargetGenerators then
            task.wait(5)
            continue
        end
        
        if State.CurrentGenerator and checkCurrentGeneratorStatus() then
            continuousRepair()
        else
            State.CurrentGenerator = nil
            local bestGenerator = findBestGenerator()
            if bestGenerator and teleportToGenerator(bestGenerator) then
                task.wait(1)
                continuousRepair()
            else
                task.wait(2)
            end
        end
        
        task.wait(1)
    end
end

-- Create UI
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "Stable Version",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "x2zu"
    }
})

-- Stable UI creation
local AutoTab = Window:Tab({Title = "Auto System", Icon = "swords"})

-- Generator Status Display
local GeneratorStatus = AutoTab:Code({
    Title = "Generator Status",
    Code = "-- Loading..."
})

local autoUpdateThread
local isUpdating = false

local function updateGeneratorStatus()
    if isUpdating or not GeneratorStatus then return end
    
    isUpdating = true
    local success, result = pcall(function()
        local newStatus = getAllGeneratorsStatus()
        if GeneratorStatus then
            GeneratorStatus:SetCode(newStatus)
        end
    end)
    
    if not success then
        warn("Failed to update generator status:", result)
    end
    
    isUpdating = false
end

local function startAutoUpdate()
    if autoUpdateThread then 
        task.cancel(autoUpdateThread)
        autoUpdateThread = nil
    end
    
    autoUpdateThread = task.spawn(function()
        while State.StatusAutoUpdate do
            updateGeneratorStatus()
            task.wait(2) -- เปลี่ยนเป็น 2 วินาทีเพื่อลดการอัพเดท
        end
        autoUpdateThread = nil
    end)
end

-- Initial update
task.delay(1, function()
    updateGeneratorStatus()
    startAutoUpdate()
end)

AutoTab:Section({Title = "Combat"})

AutoTab:Toggle({
    Title = "Auto Attack",
    Desc = "Automatic attacking",
    Value = State.AutoAttack,
    Callback = function(value)
        State.AutoAttack = value
        if value then
            task.spawn(function()
                while State.AutoAttack do
                    RemotesCache.BasicAttack:FireServer()
                    task.wait(0.1)
                end
            end)
        end
    end
})

AutoTab:Toggle({
    Title = "Auto Farm",
    Desc = "Smart mode: Repair for Survivors, Hunt for Killer",
    Value = State.AutoFarm,
    Callback = function(value)
        State.AutoFarm = value
        if value then
            task.spawn(function()
                while State.AutoFarm do
                    if isSurvivor(LocalPlayer) then
                        State.AutoRepair = true
                        autoRepair()
                    elseif isKiller(LocalPlayer) then
                        -- Killer logic here
                    end
                    task.wait(1)
                end
            end)
        else
            State.AutoRepair = false
        end
    end
})

AutoTab:Section({Title = "Generator Settings"})

AutoTab:Slider({
    Title = "Target Generators",
    Desc = "Number of generators to complete before opening gate",
    Value = State.TargetGenerators,
    Min = 1,
    Max = 7,
    Callback = function(value)
        State.TargetGenerators = value
        -- Clear cache when target changes
        Cache.StatusText = nil
        updateGeneratorStatus()
    end
})

AutoTab:Section({Title = "Tools"})

AutoTab:Button({
    Title = "🔄 Refresh Status",
    Desc = "Update generator status display manually",
    Callback = function()
        -- Clear cache to force refresh
        Cache.StatusText = nil
        Cache.Generators.lastUpdate = 0
        updateGeneratorStatus()
    end
})

AutoTab:Toggle({
    Title = "Auto Update Status",
    Desc = "Automatically update generator status every 2 seconds",
    Value = State.StatusAutoUpdate,
    Callback = function(value)
        State.StatusAutoUpdate = value
        if value then
            startAutoUpdate()
        else
            if autoUpdateThread then
                task.cancel(autoUpdateThread)
                autoUpdateThread = nil
            end
        end
        updateGeneratorStatus()
    end
})

-- Initial notification
task.delay(0.5, function()
    Window:Notify({
        Title = "x2zu",
        Desc = "Stable system loaded! Target: " .. State.TargetGenerators .. " generators",
        Time = 3
    })
end)

print("✅ Stable system loaded! Target: " .. State.TargetGenerators .. " generators")
