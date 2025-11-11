-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "x2zu on top",
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

-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer

-- Remotes
local Attacks = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks")
local BasicAttack = Attacks:WaitForChild("BasicAttack")
local CarryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent")
local HookRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("HookEvent")
local GeneratorRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("RepairEvent")
local ExitRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Exit"):WaitForChild("LeverEvent")

-- State
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
    StatusAutoUpdate = true  -- เพิ่ม state สำหรับการอัพเดทอัตโนมัติ
}

-- Team Functions
local function getPlayerTeam(player)
    return player and player.Team
end

local function isSurvivor(player)
    local team = getPlayerTeam(player)
    return team and string.lower(team.Name) == "survivors"
end

local function isSpectator(player)
    local team = getPlayerTeam(player)
    return team and string.lower(team.Name) == "spectator"
end

local function isKiller(player)
    local team = getPlayerTeam(player)
    return team and string.lower(team.Name) == "killer"
end

-- Generator Functions
local function findGenerators()
    local generators = {}
    
    -- Find all Generator Models in workspace - including Rooftop
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Generator" and obj:IsA("Model") then
            table.insert(generators, obj)
        end
    end
    
    -- Also check specifically in Rooftop
    local Map = workspace:FindFirstChild("Map")
    if Map then
        local Rooftop = Map:FindFirstChild("Rooftop")
        if Rooftop then
            for _, obj in pairs(Rooftop:GetDescendants()) do
                if obj.Name == "Generator" and obj:IsA("Model") then
                    table.insert(generators, obj)
                end
            end
        end
    end
    
    return generators
end

local function hasGeneratorPoint(generatorModel)
    if not generatorModel then 
        return false 
    end
    
    -- Check if GeneratorPoint 1-4 exists
    for i = 1, 4 do
        local pointName = "GeneratorPoint" .. i
        local point = generatorModel:FindFirstChild(pointName)
        if point and point:IsA("Part") then
            return true
        end
    end
    
    return false
end

local function countGeneratorsWithPoints()
    local generators = findGenerators()
    local generatorsWithPoints = 0
    
    for _, generator in ipairs(generators) do
        if hasGeneratorPoint(generator) then
            generatorsWithPoints = generatorsWithPoints + 1
        end
    end
    
    return generatorsWithPoints
end

-- Function to check repair progress from Generator Model Attributes
local function checkRepairProgress(generatorModel)
    if not generatorModel then return 0 end
    
    -- Check RepairProgress from Attributes
    local success, repairProgress = pcall(function()
        return generatorModel:GetAttribute("RepairProgress") or 0
    end)
    
    if success and repairProgress then
        return repairProgress
    end
    
    -- Fallback: Check NumberValue child
    local repairProgressValue = generatorModel:FindFirstChild("RepairProgress")
    if repairProgressValue and repairProgressValue:IsA("NumberValue") then
        return repairProgressValue.Value
    end
    
    return 0
end

local function countCompletedGenerators()
    local generators = findGenerators()
    local completed = 0
    
    for _, generator in ipairs(generators) do
        local progress = checkRepairProgress(generator)
        if progress >= 100 then
            completed = completed + 1
        end
    end
    
    return completed, #generators
end

-- Function to get all generators status for display
local function getAllGeneratorsStatus()
    local generators = findGenerators()
    local statusText = "-- Generator Status (All 7)\n"
    local completedCount = 0
    
    -- Sort generators by name for consistent display
    table.sort(generators, function(a, b)
        return a.Name < b.Name
    end)
    
    for i, generator in ipairs(generators) do
        local progress = checkRepairProgress(generator)
        local hasPoint = hasGeneratorPoint(generator)
        local status = progress >= 100 and "✅ COMPLETED" or ("🔄 " .. math.floor(progress) .. "%")
        local pointStatus = hasPoint and "🟢" or "🔴"
        
        statusText = statusText .. string.format("Gen %d: %s %s\n", i, status, pointStatus)
        
        if progress >= 100 then
            completedCount = completedCount + 1
        end
    end
    
    statusText = statusText .. string.format("\n-- Summary: %d/7 Completed", completedCount)
    statusText = statusText .. string.format("\n-- Auto Update: %s", State.StatusAutoUpdate and "🟢 ON" or "🔴 OFF")
    return statusText
end

local function findGeneratorPoint(generatorModel)
    if not generatorModel then return nil end
    
    -- Find GeneratorPoint in Generator Model (repair point)
    for i = 1, 4 do
        local pointName = "GeneratorPoint" .. i
        local point = generatorModel:FindFirstChild(pointName)
        if point and point:IsA("Part") then
            return point
        end
    end
    
    return nil
end

local function teleportToGenerator(generatorModel)
    local generatorPoint = findGeneratorPoint(generatorModel)
    if generatorPoint and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        -- Teleport in front of Generator Point (about 3 units away)
        local cframe = generatorPoint.CFrame
        LocalPlayer.Character:SetPrimaryPartCFrame(cframe + cframe.LookVector * -3)
        print("✅ Teleported to Generator: " .. generatorModel:GetFullName())
        State.CurrentGenerator = generatorModel
        State.LastActionTime = os.time()
        return true
    else
        print("❌ Failed to teleport to Generator: " .. (generatorModel and generatorModel:GetFullName() or "Generator not found"))
        State.CurrentGenerator = nil
        return false
    end
end

-- Function to check current Generator status
local function checkCurrentGeneratorStatus()
    if not State.CurrentGenerator then
        return false
    end
    
    -- Check if Generator still exists
    if not State.CurrentGenerator.Parent then
        State.CurrentGenerator = nil
        return false
    end
    
    -- Check if GeneratorPoint still exists
    local hasPoint = hasGeneratorPoint(State.CurrentGenerator)
    if not hasPoint then
        State.CurrentGenerator = nil
        return false
    end
    
    -- Check progress
    local progress = checkRepairProgress(State.CurrentGenerator)
    if progress >= 100 then
        State.CurrentGenerator = nil
        return false
    end
    
    return true
end

-- Function to repair Generator
local function repairGenerator(generatorModel)
    if not generatorModel then 
        return false 
    end
    
    -- Find Generator Point for argument
    local generatorPoint = findGeneratorPoint(generatorModel)
    if not generatorPoint then
        return false
    end
    
    -- Try both argument formats
    local success1, result1 = pcall(function()
        -- Format 1: Send GeneratorPoint and true
        local args = { generatorPoint, true }
        GeneratorRemote:FireServer(unpack(args))
        State.LastActionTime = os.time()
        return true
    end)
    
    if not success1 then
        -- Format 2: Send only GeneratorPoint
        local success2, result2 = pcall(function()
            local args = { generatorPoint }
            GeneratorRemote:FireServer(unpack(args))
            State.LastActionTime = os.time()
            return true
        end)
        
        if not success2 then
            return false
        end
    end
    
    return true
end

-- Function to cancel repair
local function cancelRepair()
    if State.CurrentGenerator then
        local generatorPoint = findGeneratorPoint(State.CurrentGenerator)
        if generatorPoint then
            local args = { generatorPoint, false }
            GeneratorRemote:FireServer(unpack(args))
            print("🛑 Repair cancelled!")
            State.CurrentGenerator = nil
            State.CancelRepair = true
            return true
        end
    end
    return false
end

-- Continuous repair function
local function continuousRepair()
    local startTime = os.time()
    local maxRepairTime = 120 -- Maximum 2 minutes
    
    while State.AutoRepair and State.CurrentGenerator and not State.CancelRepair do
        -- Check current Generator status continuously
        if not checkCurrentGeneratorStatus() then
            print("🔍 Current Generator not ready -> Find new one")
            State.CurrentGenerator = nil
            break
        end
        
        -- Check if taking too long
        if os.time() - startTime > maxRepairTime then
            print("⏰ Repair taking too long -> Change Generator")
            State.CurrentGenerator = nil
            break
        end
        
        -- Repair Generator
        repairGenerator(State.CurrentGenerator)
        
        -- Check progress from Model directly
        local currentProgress = checkRepairProgress(State.CurrentGenerator)
        
        -- If Generator completed
        if currentProgress >= 100 then
            print("🎉 Generator repaired!")
            State.CurrentGenerator = nil
            break
        end
        
        -- Wait before next repair
        task.wait(0.3)
    end
    
    State.CancelRepair = false
end

-- Exit Functions
local function findExitLever()
    local Map = workspace:FindFirstChild("Map")
    if not Map then return nil end
    
    -- Check in Map directly
    local Gate = Map:FindFirstChild("Gate")
    if not Gate then
        -- Check in Rooftop
        local Rooftop = Map:FindFirstChild("Rooftop")
        if Rooftop then
            Gate = Rooftop:FindFirstChild("Gate")
        end
    end
    
    if not Gate then return nil end
    
    local ExitLever = Gate:FindFirstChild("ExitLever")
    if not ExitLever then return nil end
    
    local Tp = ExitLever:FindFirstChild("Tp")
    local Main = ExitLever:FindFirstChild("Main")
    
    return Tp, Main
end

-- Function to check if Exit Tp part exists
local function checkExitTpExists()
    local Tp, Main = findExitLever()
    return Tp ~= nil
end

local function teleportToExit()
    local Tp, Main = findExitLever()
    if Tp and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        LocalPlayer.Character:SetPrimaryPartCFrame(Tp.CFrame)
        State.LastActionTime = os.time()
        return true, Main
    end
    return false, nil
end

local function activateExitLever()
    local Tp, Main = findExitLever()
    if Main then
        local args = { Main, true }
        ExitRemote:FireServer(unpack(args))
        State.LastActionTime = os.time()
        return true
    end
    return false
end

local function teleportForward()
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        local Tp, Main = findExitLever()
        if Tp then
            -- วาปไปด้านนอกประตู (ปรับตำแหน่งตามต้องการ)
            local gatePosition = Tp.Position
            local outsidePosition = gatePosition + Vector3.new(0, 0, 50) -- วาปไปด้านหน้าประตู 50 หน่วย
            LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(outsidePosition))
            State.LastActionTime = os.time()
            return true
        else
            -- Fallback: วาปไปข้างหน้าตัวละคร
            local currentCFrame = LocalPlayer.Character.PrimaryPart.CFrame
            LocalPlayer.Character:SetPrimaryPartCFrame(currentCFrame + currentCFrame.LookVector * 50)
            State.LastActionTime = os.time()
            return true
        end
    end
    return false
end

-- Function to open exit gate
local function openExitGate()
    if State.CheckingExit then
        return false
    end
    
    State.CheckingExit = true
    print("🚪 Attempting to open exit gate...")
    
    -- Teleport to gate
    local teleportSuccess, mainPart = teleportToExit()
    if teleportSuccess then
        task.wait(0.5)
        
        -- Open gate
        local leverSuccess = activateExitLever()
        if leverSuccess then
            task.wait(0.5)
            
            -- Teleport outside
            teleportForward()
            print("🎉 Exit gate opened successfully!")
            State.CheckingExit = false
            return true
        else
            print("❌ Failed to open gate")
        end
    else
        print("❌ Failed to teleport to gate")
    end
    
    State.CheckingExit = false
    return false
end

-- Player Functions
local function checkPlayerHealth(playerName)
    local playerModel = workspace:FindFirstChild(playerName)
    if not playerModel then
        return {health = 0, maxHealth = 0, found = false}
    end
    
    local humanoid = playerModel:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return {health = 0, maxHealth = 0, found = true, hasHumanoid = false}
    end
    
    return {
        health = humanoid.Health,
        maxHealth = humanoid.MaxHealth,
        found = true,
        hasHumanoid = true,
        lowHealth = (humanoid.Health <= 20)
    }
end

local function teleportBehindPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character.PrimaryPart then
        return false
    end
    
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        local behindPosition = targetPlayer.Character.PrimaryPart.CFrame * CFrame.new(0, 0, 2)
        LocalPlayer.Character:SetPrimaryPartCFrame(behindPosition)
        State.LastActionTime = os.time()
        return true
    end
    return false
end

-- Hook Functions
local function findHookModel()
    local success, result = pcall(function()
        local Map = workspace:FindFirstChild("Map")
        if not Map then
            return nil
        end
        
        -- Method 1: Find in Rooftop (old map)
        local Rooftop = Map:FindFirstChild("Rooftop")
        if Rooftop then
            local Hook = Rooftop:FindFirstChild("Hook")
            if Hook then
                return Hook
            end
        end
        
        -- Method 2: Find in other areas of Map
        local Hook = Map:FindFirstChild("Hook")
        if Hook then
            return Hook
        end
        
        -- Method 3: Find by related names
        for _, obj in pairs(Map:GetDescendants()) do
            if obj.Name == "Hook" and obj:IsA("Model") then
                return obj
            end
        end
        
        return nil
    end)
    
    if not success then
        return nil
    end
    
    return result
end

local function findHookPart()
    local success, result = pcall(function()
        local hookModel = findHookModel()
        if not hookModel then 
            return nil 
        end
        
        -- Find any Part in Hook Model
        for _, child in pairs(hookModel:GetChildren()) do
            if child:IsA("Part") then
                return child
            end
        end
        
        -- If hookModel is Part directly
        if hookModel:IsA("Part") then
            return hookModel
        end
        
        -- Find in descendants
        for _, child in pairs(hookModel:GetDescendants()) do
            if child:IsA("Part") then
                return child
            end
        end
        
        return nil
    end)
    
    if not success then
        return nil
    end
    
    return result
end

local function teleportToHook()
    local success, result = pcall(function()
        local hookPart = findHookPart()
        if hookPart and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            -- Teleport to Hook Part
            LocalPlayer.Character:SetPrimaryPartCFrame(hookPart.CFrame * CFrame.new(0, 0, -3))
            State.LastActionTime = os.time()
            return true
        else
            return false
        end
    end)
    
    if not success then
        return false
    end
    
    return result
end

local function spamHookEvent()
    local success, result = pcall(function()
        local hookPart = findHookPart()
        if hookPart then
            local args = { hookPart }
            for i = 1, 20 do
                HookRemote:FireServer(unpack(args))
                task.wait(0.02)
            end
            return true
        else
            return false
        end
    end)
    
    if not success then
        return false
    end
    
    return result
end

local function tryCarryPlayer(player)
    local success, result = pcall(function()
        if not player or not player.Character then return false end
        
        local carryArgs = { player.Character }
        CarryRemote:FireServer(unpack(carryArgs))
        task.wait(1.5)
        State.LastActionTime = os.time()
        return true
    end)
    
    if not success then
        return false
    end
    
    return result
end

-- Function to find best generator to repair
local function findBestGenerator()
    local generators = findGenerators()
    local bestGenerator = nil
    local highestProgress = -1
    
    for _, generator in ipairs(generators) do
        if not hasGeneratorPoint(generator) then
            continue
        end
        
        local progress = checkRepairProgress(generator)
        
        -- Skip completed generators
        if progress >= 100 then
            continue
        end
        
        -- Prefer generators with higher progress (closer to completion)
        if progress > highestProgress then
            highestProgress = progress
            bestGenerator = generator
        end
    end
    
    -- If no generator with progress found, take any available
    if not bestGenerator then
        for _, generator in ipairs(generators) do
            if hasGeneratorPoint(generator) and checkRepairProgress(generator) < 100 then
                bestGenerator = generator
                break
            end
        end
    end
    
    if bestGenerator then
        local progress = checkRepairProgress(bestGenerator)
        print("🎯 Selected generator: " .. bestGenerator:GetFullName() .. " (Progress: " .. progress .. "%)")
    end
    
    return bestGenerator
end

-- Improved Auto Repair Function (Survivors)
local function autoRepair()
    local stuckCount = 0
    
    while State.AutoRepair and isSurvivor(LocalPlayer) do
        -- Update action time
        State.LastActionTime = os.time()
        
        -- Check if stuck (no action for 30 seconds)
        if os.time() - State.LastActionTime > 30 then
            print("🚨 Possible stuck detected, resetting...")
            State.CurrentGenerator = nil
            stuckCount = stuckCount + 1
            
            if stuckCount >= 3 then
                print("🔴 Multiple stuck detected, cancelling repair...")
                cancelRepair()
                task.wait(5)
                stuckCount = 0
            end
        else
            stuckCount = 0
        end
        
        -- Check number of completed generators
        local completed, total = countCompletedGenerators()
        print("🔧 Generator Progress: " .. completed .. "/" .. State.TargetGenerators .. " completed (Total: " .. total .. " generators)")
        
        -- If reached target number of generators, open exit gate
        if completed >= State.TargetGenerators then
            print("🎯 Target reached! " .. completed .. "/" .. State.TargetGenerators .. " generators completed -> Opening exit gate...")
            if openExitGate() then
                print("✅ Gate opened successfully!")
                task.wait(10)
            else
                print("❌ Failed to open gate -> Try again in 5 seconds")
                task.wait(5)
            end
            continue
        end
        
        -- If currently repairing a generator, continue
        if State.CurrentGenerator and checkCurrentGeneratorStatus() then
            local progress = checkRepairProgress(State.CurrentGenerator)
            print("🔧 Continuing repair on current generator... Progress: " .. progress .. "%")
            continuousRepair()
        else
            State.CurrentGenerator = nil
        end
        
        -- Find new generator if none is current
        if not State.CurrentGenerator then
            print("🔍 Searching for new generator to repair...")
            State.IsSearchingGenerator = true
            
            local bestGenerator = findBestGenerator()
            
            if bestGenerator then
                local progress = checkRepairProgress(bestGenerator)
                print("🎯 Found generator to repair: " .. bestGenerator:GetFullName() .. " (Progress: " .. progress .. "%)")
                
                if teleportToGenerator(bestGenerator) then
                    task.wait(1)
                    continuousRepair()
                else
                    print("❌ Failed to teleport to generator, searching again...")
                    task.wait(2)
                end
            else
                print("🔍 No available generators found, waiting...")
                if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                    local currentPos = LocalPlayer.Character.PrimaryPart.Position
                    LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(currentPos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))))
                end
                task.wait(3)
            end
            
            State.IsSearchingGenerator = false
        end
        
        task.wait(1)
    end
end

-- Killer continuous teleport and attack function
local function killerContinuousAttack()
    State.KillerLoopActive = true
    
    while State.AutoFarm and isKiller(LocalPlayer) and State.KillerLoopActive do
        State.LastActionTime = os.time()
        
        local allPlayers = {}
        
        -- Find all players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(allPlayers, player)
            end
        end
        
        if #allPlayers == 0 then
            task.wait(1.0)
            continue
        end
        
        local foundTarget = false
        
        for i, player in ipairs(allPlayers) do
            if not State.AutoFarm or not State.KillerLoopActive then break end
            
            if isSpectator(player) then
                continue
            end
            
            if not isSurvivor(player) then
                continue
            end
            
            local healthInfo = checkPlayerHealth(player.Name)
            
            if healthInfo.found and healthInfo.hasHumanoid then
                foundTarget = true
                State.KillerTarget = player
                
                -- Continuous teleport and attack until low health
                while State.KillerTarget and State.KillerLoopActive and healthInfo.health > 20 do
                    if not State.AutoFarm then break end
                    
                    teleportBehindPlayer(player)
                    task.wait(0.1)
                    
                    BasicAttack:FireServer()
                    task.wait(0.2)
                    
                    healthInfo = checkPlayerHealth(player.Name)
                    
                    if not healthInfo.found or not healthInfo.hasHumanoid or healthInfo.health <= 0 then
                        break
                    end
                end
                
                if healthInfo.lowHealth and healthInfo.health > 0 then
                    if tryCarryPlayer(player) then
                        task.wait(0.5)
                        
                        if teleportToHook() then
                            task.wait(0.5)
                            
                            spamHookEvent()
                            task.wait(1.0)
                        end
                    end
                end
                
                break
            end
        end
        
        if not foundTarget then
            State.KillerTarget = nil
            task.wait(1.0)
        end
        
        task.wait(0.5)
    end
    
    State.KillerTarget = nil
    State.KillerLoopActive = false
end

-- Combined Auto Farm Function
local function autoFarmCombined()
    local lastTeam = nil
    
    while State.AutoFarm do
        local currentTeam = LocalPlayer.Team and LocalPlayer.Team.Name or "No Team"
        
        if lastTeam ~= currentTeam then
            print("🔄 Team changed: " .. (lastTeam or "None") .. " -> " .. currentTeam)
            lastTeam = currentTeam
        end
        
        if isSpectator(LocalPlayer) then
            task.wait(3.0)
            continue
        end
        
        if isSurvivor(LocalPlayer) then
            State.AutoRepair = true
            State.KillerLoopActive = false
            autoRepair()
        elseif isKiller(LocalPlayer) then
            State.AutoRepair = false
            State.CurrentGenerator = nil
            killerContinuousAttack()
        else
            State.AutoRepair = false
            State.CurrentGenerator = nil
            State.KillerLoopActive = false
            task.wait(3.0)
        end
        
        task.wait(1.0)
    end
end

-- Auto Attack Function
local function autoAttack()
    while State.AutoAttack do
        BasicAttack:FireServer()
        task.wait(0.1)
    end
end

-- Create UI
local AutoTab = Window:Tab({Title = "Auto System", Icon = "swords"}) do
    AutoTab:Section({Title = "Combat"})

    AutoTab:Toggle({
        Title = "Auto Attack",
        Desc = "Automatic attacking",
        Value = State.AutoAttack,
        Callback = function(value)
            State.AutoAttack = value
            if value then
                spawn(autoAttack)
                Window:Notify({
                    Title = "Auto Attack",
                    Desc = "Auto Attack enabled!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Auto Attack",
                    Desc = "Auto Attack disabled!",
                    Time = 3
                })
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
                local currentTeam = LocalPlayer.Team and LocalPlayer.Team.Name or "No Team"
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Auto Farm enabled! (" .. currentTeam .. ")",
                    Time = 3
                })
                spawn(autoFarmCombined)
            else
                State.AutoRepair = false
                State.CurrentGenerator = nil
                State.KillerLoopActive = false
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "Auto Farm disabled!",
                    Time = 3
                })
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
            Window:Notify({
                Title = "Target Updated",
                Desc = "Will open gate after " .. value .. " generators completed",
                Time = 3
            })
        end
    })
    
    AutoTab:Section({Title = "Tools"})
    
    -- Generator Status Display
    local GeneratorStatus = AutoTab:Code({
        Title = "Generator Status",
        Code = getAllGeneratorsStatus()
    })

    -- Function to update generator status
    local function updateGeneratorStatus()
        if GeneratorStatus then
            GeneratorStatus:SetCode(getAllGeneratorsStatus())
        end
    end

    -- Auto update system
    local autoUpdateThread
    local function startAutoUpdate()
        if autoUpdateThread then
            return -- Already running
        end
        
        autoUpdateThread = task.spawn(function()
            while State.StatusAutoUpdate do
                updateGeneratorStatus()
                task.wait(2) -- อัพเดททุก 2 วินาที (ลดจาก 3 วินาที)
            end
            autoUpdateThread = nil
        end)
    end

    -- Start auto update initially
    startAutoUpdate()
    
    AutoTab:Button({
        Title = "🔄 Refresh Status",
        Desc = "Update generator status display manually",
        Callback = function()
            updateGeneratorStatus()
            Window:Notify({
                Title = "Generator Status",
                Desc = "Generator status updated!",
                Time = 2
            })
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
                Window:Notify({
                    Title = "Auto Update",
                    Desc = "Auto update enabled!",
                    Time = 2
                })
            else
                Window:Notify({
                    Title = "Auto Update",
                    Desc = "Auto update disabled!",
                    Time = 2
                })
            end
            -- อัพเดท display ทันทีเพื่อแสดงสถานะ
            updateGeneratorStatus()
        end
    })
    
    AutoTab:Button({
        Title = "Cancel Repair",
        Desc = "Cancel current generator repair",
        Callback = function()
            if cancelRepair() then
                Window:Notify({
                    Title = "Repair Cancelled",
                    Desc = "Successfully cancelled repair!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Cancel Failed",
                    Desc = "No active repair to cancel!",
                    Time = 3
                })
            end
        end
    })
    
    AutoTab:Button({
        Title = "Open Exit Gate Now",
        Desc = "Teleport to open exit gate immediately",
        Callback = function()
            if openExitGate() then
                Window:Notify({
                    Title = "Gate Opened",
                    Desc = "Exit gate opened successfully!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Gate Open Failed",
                    Desc = "Failed to open exit gate!",
                    Time = 3
                })
            end
        end
    })
    
    AutoTab:Button({
        Title = "Test Hook Teleport",
        Desc = "Test teleport to Hook",
        Callback = function()
            if teleportToHook() then
                Window:Notify({
                    Title = "Success",
                    Desc = "Teleported to Hook successfully!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "Failed to teleport to Hook!",
                    Time = 3
                })
            end
        end
    })
end

Window:Notify({
    Title = "x2zu",
    Desc = "Auto system loaded successfully! Target: " .. State.TargetGenerators .. " generators",
    Time = 3
})

print("✅ Auto system loaded successfully! Target: " .. State.TargetGenerators .. " generators")
