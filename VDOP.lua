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
    CheckingExit = false
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
    
    -- หา Generator Models ทั้งหมดใน workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Generator" and obj:IsA("Model") then
            table.insert(generators, obj)
        end
    end
    
    return generators
end

local function hasGeneratorPoint(generatorModel)
    if not generatorModel then 
        return false 
    end
    
    -- เช็คว่ามี GeneratorPoint 1-4 หรือไม่
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

local function checkRepairProgress(generatorModel)
    if not generatorModel then return 0 end
    
    -- เช็ค RepairProgress ใน Generator Model โดยตรง
    local repairProgress = generatorModel:FindFirstChild("RepairProgress")
    if repairProgress and repairProgress:IsA("NumberValue") then
        return repairProgress.Value
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

local function findGeneratorPoint(generatorModel)
    if not generatorModel then return nil end
    
    -- หา GeneratorPoint ใน Generator Model (จุดยืนปั่น)
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
        -- วาปไปด้านหน้า Generator Point โดยห่างประมาณ 3 หน่วย
        local cframe = generatorPoint.CFrame
        LocalPlayer.Character:SetPrimaryPartCFrame(cframe + cframe.LookVector * -3)
        print("✅ วาปไปหา Generator สำเร็จ: " .. generatorModel:GetFullName())
        State.CurrentGenerator = generatorModel
        return true
    else
        print("❌ วาปไปหา Generator ไม่สำเร็จ: " .. (generatorModel and generatorModel:GetFullName() or "ไม่พบ Generator"))
        State.CurrentGenerator = nil
        return false
    end
end

-- ฟังก์ชันเช็คสถานะ Generator ปัจจุบัน
local function checkCurrentGeneratorStatus()
    if not State.CurrentGenerator then
        return false
    end
    
    -- เช็คว่า Generator ยังอยู่หรือไม่
    if not State.CurrentGenerator.Parent then
        State.CurrentGenerator = nil
        return false
    end
    
    -- เช็คว่ายังมี GeneratorPoint หรือไม่
    local hasPoint = hasGeneratorPoint(State.CurrentGenerator)
    if not hasPoint then
        State.CurrentGenerator = nil
        return false
    end
    
    -- เช็คความคืบหน้า
    local progress = checkRepairProgress(State.CurrentGenerator)
    if progress >= 100 then
        State.CurrentGenerator = nil
        return false
    end
    
    return true
end

-- ฟังก์ชันปั่น Generator
local function repairGenerator(generatorModel)
    if not generatorModel then 
        return false 
    end
    
    -- หา Generator Point สำหรับใช้เป็น argument
    local generatorPoint = findGeneratorPoint(generatorModel)
    if not generatorPoint then
        return false
    end
    
    -- ลองทั้ง 2 รูปแบบของการส่ง arguments
    local success1, result1 = pcall(function()
        -- รูปแบบที่ 1: ส่ง GeneratorPoint และ true
        local args = { generatorPoint, true }
        GeneratorRemote:FireServer(unpack(args))
        return true
    end)
    
    if not success1 then
        -- รูปแบบที่ 2: ส่งเฉพาะ GeneratorPoint
        local success2, result2 = pcall(function()
            local args = { generatorPoint }
            GeneratorRemote:FireServer(unpack(args))
            return true
        end)
        
        if not success2 then
            return false
        end
    end
    
    return true
end

-- ฟังก์ชันปั่น Generator อย่างต่อเนื่อง
local function continuousRepair()
    local startTime = os.time()
    local maxRepairTime = 120 -- สูงสุด 2 นาที
    
    while State.AutoRepair and State.CurrentGenerator do
        -- เช็คสถานะ Generator ปัจจุบันตลอดเวลา
        if not checkCurrentGeneratorStatus() then
            print("🔍 Generator ปัจจุบันไม่พร้อม -> หาเครื่องใหม่")
            State.CurrentGenerator = nil
            break
        end
        
        -- เช็คว่าใช้เวลานานเกินไปหรือไม่
        if os.time() - startTime > maxRepairTime then
            print("⏰ ใช้เวลาปั่นนานเกินไป -> เปลี่ยนเครื่อง")
            State.CurrentGenerator = nil
            break
        end
        
        -- ปั่น Generator
        repairGenerator(State.CurrentGenerator)
        
        -- เช็คความคืบหน้าจาก Model โดยตรง
        local currentProgress = checkRepairProgress(State.CurrentGenerator)
        
        -- ถ้า Generator เสร็จ
        if currentProgress >= 100 then
            print("🎉 Generator ซ่อมเสร็จแล้ว!")
            State.CurrentGenerator = nil
            break
        end
        
        -- รอสักครู่ก่อนปั่นครั้งต่อไป
        task.wait(0.3)
    end
end

-- Exit Functions
local function findExitLever()
    local Map = workspace:FindFirstChild("Map")
    if not Map then return nil end
    
    local Gate = Map:FindFirstChild("Gate")
    if not Gate then return nil end
    
    local ExitLever = Gate:FindFirstChild("ExitLever")
    if not ExitLever then return nil end
    
    local Tp = ExitLever:FindFirstChild("Tp")
    local Main = ExitLever:FindFirstChild("Main")
    
    return Tp, Main
end

local function teleportToExit()
    local Tp, Main = findExitLever()
    if Tp and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        LocalPlayer.Character:SetPrimaryPartCFrame(Tp.CFrame)
        return true, Main
    end
    return false, nil
end

local function activateExitLever()
    local Tp, Main = findExitLever()
    if Main then
        local args = { Main, true }
        ExitRemote:FireServer(unpack(args))
        return true
    end
    return false
end

local function teleportForward()
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        local currentCFrame = LocalPlayer.Character.PrimaryPart.CFrame
        LocalPlayer.Character:SetPrimaryPartCFrame(currentCFrame + currentCFrame.LookVector * 50)
        return true
    end
    return false
end

-- ฟังก์ชันเปิดประตูทางออก
local function openExitGate()
    if State.CheckingExit then
        return false
    end
    
    State.CheckingExit = true
    print("🚪 กำลังพยายามเปิดประตูทางออก...")
    
    -- วาปไปที่ประตู
    local teleportSuccess, mainPart = teleportToExit()
    if teleportSuccess then
        task.wait(0.5)
        
        -- เปิดประตู
        local leverSuccess = activateExitLever()
        if leverSuccess then
            task.wait(0.5)
            
            -- วาปออกไปด้านนอก
            teleportForward()
            print("🎉 เปิดประตูทางออกสำเร็จ!")
            State.CheckingExit = false
            return true
        else
            print("❌ เปิดประตูไม่สำเร็จ")
        end
    else
        print("❌ วาปไปประตูไม่สำเร็จ")
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
        lowHealth = (humanoid.Health <= 100)
    }
end

local function teleportBehindPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character.PrimaryPart then
        return false
    end
    
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        local behindPosition = targetPlayer.Character.PrimaryPart.CFrame * CFrame.new(0, 0, 0)
        LocalPlayer.Character:SetPrimaryPartCFrame(behindPosition)
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
        
        -- วิธีที่ 1: หาใน Rooftop (ด่านเก่า)
        local Rooftop = Map:FindFirstChild("Rooftop")
        if Rooftop then
            local Hook = Rooftop:FindFirstChild("Hook")
            if Hook then
                return Hook
            end
        end
        
        -- วิธีที่ 2: หาในพื้นที่อื่นๆ ของ Map
        local Hook = Map:FindFirstChild("Hook")
        if Hook then
            return Hook
        end
        
        -- วิธีที่ 3: หาโดยชื่อที่เกี่ยวข้อง
        for _, obj in pairs(Map:GetDescendants()) do
            if obj.Name == "Hook" and obj:IsA("Model") then
                return obj
            end
        end
        
        -- วิธีที่ 4: หาโดยคำที่เกี่ยวข้องกับ Hook
        local hookKeywords = {"hook", "Hook", "HOOK", "hanger", "Hanger", "HANGER"}
        for _, obj in pairs(Map:GetDescendants()) do
            if obj:IsA("Model") then
                for _, keyword in ipairs(hookKeywords) do
                    if string.find(obj.Name, keyword) then
                        return obj
                    end
                end
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
        
        -- หา Part ใดๆ ใน Hook Model
        for _, child in pairs(hookModel:GetChildren()) do
            if child:IsA("Part") then
                return child
            end
        end
        
        -- ถ้า hookModel เป็น Part โดยตรง
        if hookModel:IsA("Part") then
            return hookModel
        end
        
        -- หาใน descendants
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
            -- วาปไปที่ Hook Part
            LocalPlayer.Character:SetPrimaryPartCFrame(hookPart.CFrame * CFrame.new(0, 0, -3))
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
        return true
    end)
    
    if not success then
        return false
    end
    
    return result
end

-- Auto Repair Function (Survivors)
local function autoRepair()
    while State.AutoRepair and isSurvivor(LocalPlayer) do
        -- เช็คจำนวน Generator ที่มี GeneratorPoint
        local generatorsWithPoints = countGeneratorsWithPoints()
        print("🔧 จำนวน Generator ที่มี Point: " .. generatorsWithPoints .. " เครื่อง")
        
        -- ถ้ามี Generator น้อยกว่าหรือเท่ากับ 5 เครื่อง -> ไปเปิดประตู
        if generatorsWithPoints == 5 then
            print("🚨 มี Generator น้อยกว่าหรือเท่ากับ 5 เครื่อง -> ไปเปิดประตูทางออก")
            if openExitGate() then
                print("✅ เปิดประตูสำเร็จ -> รอสักครู่")
                task.wait(10)
            else
                print("❌ เปิดประตูไม่สำเร็จ -> พยายามใหม่ใน 5 วินาที")
                task.wait(5)
            end
            continue
        end
        
        -- ถ้ามี Generator ปัจจุบันอยู่ ให้เช็คสถานะและปั่นต่อ
        if State.CurrentGenerator then
            continuousRepair()
        end
        
        -- หา Generator ใหม่ถ้าไม่มีปัจจุบันหรือปัจจุบันไม่พร้อม
        if not State.CurrentGenerator then
            local generators = findGenerators()
            local foundValidGenerator = false
            
            for i, generator in ipairs(generators) do
                if not State.AutoRepair then break end
                
                -- เช็ค RepairProgress จาก Model โดยตรง
                local progress = checkRepairProgress(generator)
                
                -- เช็คว่า Generator นี้มี GeneratorPoint หรือไม่
                local hasPoint = hasGeneratorPoint(generator)
                
                if progress < 100 and hasPoint then
                    print("🔧 พบ Generator ที่พร้อมซ่อม -> เริ่มวาป")
                    foundValidGenerator = true
                    
                    -- วาปไปหา Generator
                    if teleportToGenerator(generator) then
                        task.wait(0.5)
                        
                        -- เริ่มปั่น Generator อย่างต่อเนื่อง
                        continuousRepair()
                        
                    else
                        State.CurrentGenerator = nil
                    end
                    
                    break
                end
            end
            
            if not foundValidGenerator then
                task.wait(3.0)
            end
        end
        
        task.wait(1.0)
    end
end

-- Auto Farm Function (Killer)
local function autoFarmKiller()
    while State.AutoFarm and isKiller(LocalPlayer) do
        local allPlayers = {}
        
        -- หาผู้เล่นทั้งหมด
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(allPlayers, player)
            end
        end
        
        if #allPlayers == 0 then
            task.wait(3.0)
            continue
        end
        
        local foundTarget = false
        
        for i, player in ipairs(allPlayers) do
            if not State.AutoFarm then break end
            
            if isSpectator(player) then
                continue
            end
            
            if not isSurvivor(player) then
                continue
            end
            
            local healthInfo = checkPlayerHealth(player.Name)
            
            if healthInfo.found and healthInfo.hasHumanoid then
                if healthInfo.lowHealth then
                    foundTarget = true
                    
                    -- วาปไปข้างหลังผู้เล่น
                    if teleportBehindPlayer(player) then
                        task.wait(0.5)
                        
                        -- พยายามอุ้ม
                        tryCarryPlayer(player)
                        
                        -- วาปไปหา Hook
                        if teleportToHook() then
                            task.wait(0.5)
                            
                            -- สแปม HookEvent
                            spamHookEvent()
                            
                            task.wait(1.0)
                        end
                    end
                    
                    break
                end
            end
        end
        
        if not foundTarget then
            local targetSurvivor = nil
            for _, player in pairs(allPlayers) do
                if isSurvivor(player) and not isSpectator(player) then
                    targetSurvivor = player
                    break
                end
            end
            
            if targetSurvivor then
                if teleportBehindPlayer(targetSurvivor) then
                    task.wait(0.5)
                    BasicAttack:FireServer()
                end
            end
        end
        
        task.wait(1)
    end
end

-- Combined Auto Farm Function
local function autoFarmCombined()
    local lastTeam = nil
    
    while State.AutoFarm do
        local currentTeam = LocalPlayer.Team and LocalPlayer.Team.Name or "ไม่มีทีม"
        
        -- ถ้าเปลี่ยนทีม ให้แจ้งเตือน
        if lastTeam ~= currentTeam then
            print("🔄 เปลี่ยนทีม: " .. (lastTeam or "ไม่มี") .. " -> " .. currentTeam)
            lastTeam = currentTeam
        end
        
        if isSpectator(LocalPlayer) then
            task.wait(3.0)
            continue
        end
        
        if isSurvivor(LocalPlayer) then
            State.AutoRepair = true
            autoRepair()
        elseif isKiller(LocalPlayer) then
            State.AutoRepair = false
            State.CurrentGenerator = nil
            autoFarmKiller()
        else
            State.AutoRepair = false
            State.CurrentGenerator = nil
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
        Desc = "โจมตีอัตโนมัติ",
        Value = State.AutoAttack,
        Callback = function(value)
            State.AutoAttack = value
            if value then
                spawn(autoAttack)
                Window:Notify({
                    Title = "Auto Attack",
                    Desc = "เปิดโจมตีอัตโนมัติแล้ว!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Auto Attack",
                    Desc = "ปิดโจมตีอัตโนมัติแล้ว!",
                    Time = 3
                })
            end
        end
    })

    AutoTab:Toggle({
        Title = "Auto Farm",
        Desc = "โหมดอัจฉริยะ: ซ่อมสำหรับ Survivors, ล่าสำหรับ Killer",
        Value = State.AutoFarm,
        Callback = function(value)
            State.AutoFarm = value
            if value then
                local currentTeam = LocalPlayer.Team and LocalPlayer.Team.Name or "ไม่มีทีม"
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "เปิด Auto Farm แล้ว! (" .. currentTeam .. ")",
                    Time = 3
                })
                spawn(autoFarmCombined)
            else
                State.AutoRepair = false
                State.CurrentGenerator = nil
                Window:Notify({
                    Title = "Auto Farm",
                    Desc = "ปิด Auto Farm แล้ว!",
                    Time = 3
                })
            end
        end
    })
    
    AutoTab:Section({Title = "เครื่องมือ"})
    
    AutoTab:Button({
        Title = "เช็คสถานะ Generator",
        Desc = "แสดงความคืบหน้าซ่อมแซม Generator",
        Callback = function()
            local completed, total = countCompletedGenerators()
            local generatorsWithPoints = countGeneratorsWithPoints()
            Window:Notify({
                Title = "สถานะ Generator",
                Desc = "ซ่อมเสร็จ: " .. completed .. "/" .. total .. ", มี Point: " .. generatorsWithPoints .. " เครื่อง",
                Time = 5
            })
        end
    })
    
    AutoTab:Button({
        Title = "เปิดประตูทางออก",
        Desc = "วาปไปเปิดประตูทางออกทันที",
        Callback = function()
            if openExitGate() then
                Window:Notify({
                    Title = "เปิดประตูสำเร็จ",
                    Desc = "เปิดประตูทางออกเรียบร้อย!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "เปิดประตูไม่สำเร็จ",
                    Desc = "เปิดประตูทางออกไม่สำเร็จ!",
                    Time = 3
                })
            end
        end
    })
    
    AutoTab:Button({
        Title = "ทดสอบวาป Hook",
        Desc = "ทดสอบวาปไปหา Hook",
        Callback = function()
            if teleportToHook() then
                Window:Notify({
                    Title = "สำเร็จ",
                    Desc = "วาปไปหา Hook สำเร็จ!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "ผิดพลาด",
                    Desc = "วาปไปหา Hook ไม่สำเร็จ!",
                    Time = 3
                })
            end
        end
    })
end

Window:Notify({
    Title = "x2zu",
    Desc = "โหลดระบบอัตโนมัติสำเร็จ!",
    Time = 3
})

print("✅ โหลดระบบอัตโนมัติสำเร็จ!")
