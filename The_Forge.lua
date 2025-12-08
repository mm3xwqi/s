local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ประกาศตัวแปรทั้งหมดก่อน
local allRocks = {} -- ตารางเก็บหินทั้งหมด
local isAutoFarming = false
local currentTween = nil
local isHoldingAtRock = false
local Dropdown, Toggle, SpeedSlider, TweenSpeedSlider, Button
local noclipEnabled = false
local noclipConnection
local selectedRockType = "All Rocks"
local xOffset, yOffset, zOffset = 0, 5, 0 -- Offset สำหรับตำแหน่ง
local miningActive = false -- สำหรับควบคุมการตีหิน
local floatPosition = nil -- สำหรับควบคุมการลอย
local currentTargetRock = nil -- หินเป้าหมายปัจจุบัน
local pickaxeInHand = nil -- เก็บ Pickaxe ที่อยู่ในมือ
local isMovingToRock = false -- สำหรับตรวจสอบว่ากำลังเคลื่อนที่ไปหาหินหรือไม่

-- ฟังก์ชันเปิด/ปิด NoClip
local function toggleNoClip(state)
    noclipEnabled = state
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if state then
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide == true then
                        part.CanCollide = false
                    end
                end
            end
        end)
        print("NoClip enabled")
    else
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        print("NoClip disabled")
    end
end

-- ฟังก์ชันถือ Pickaxe
local function equipPickaxe()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    local pickaxe = backpack:FindFirstChild("Pickaxe")
    if not pickaxe then 
        print("Pickaxe not found in backpack")
        return nil 
    end
    
    local character = LocalPlayer.Character
    if not character then return nil end
    
    -- ถ่ายโอน Pickaxe ไปที่ตัวละครเลย
    pickaxe.Parent = character
    pickaxeInHand = pickaxe
    print("Pickaxe equipped to character")
    
    return pickaxe
end

-- ฟังก์ชันใช้ Pickaxe รัวๆ ตลอดเวลา
local function startContinuousMining()
    miningActive = true
    
    while miningActive and isAutoFarming do
        local success, error = pcall(function()
            local args = {"Pickaxe"}
            ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated"):InvokeServer(unpack(args))
        end)
        
        if not success then
            print("Error using Pickaxe:", error)
        end
        
        -- รอตามความเร็วที่ตั้ง (ใช้ความเร็วต่ำสุด 0.05 วินาทีเพื่อตีเร็วๆ)
        local delayTime = math.max(SpeedSlider.CurrentValue, 0.05)
        wait(delayTime)
    end
end

-- ฟังก์ชันหยุดการตีหิน
local function stopMining()
    miningActive = false
end

-- ฟังก์ชันสร้างและควบคุม FloatPosition
local function setupFloatControl()
    spawn(function()
        local player = LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")
        
        -- ลบ Float เดิมถ้ามี
        if floatPosition then
            floatPosition:Destroy()
            floatPosition = nil
        end
        
        while isAutoFarming do
            task.wait(0.005)
            
            pcall(function()
                if isAutoFarming then
                    -- ยืนขึ้นถ้านั่ง
                    if character:WaitForChild("Humanoid").Sit then
                        character:WaitForChild("Humanoid").Sit = false
                    end
                    
                    -- ถ้ายังไม่มีส่วนควบคุมการลอย
                    if not root:FindFirstChild("FloatPosition") then
                        floatPosition = Instance.new("BodyPosition")
                        floatPosition.Name = "FloatPosition"
                        floatPosition.Parent = root
                        floatPosition.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                        floatPosition.Position = root.Position
                        
                        print("FloatPosition created")
                    else
                        floatPosition = root:FindFirstChild("FloatPosition")
                    end
                    
                    -- อัพเดทตำแหน่ง FloatPosition
                    if floatPosition then
                        floatPosition.Position = root.Position
                    end
                else
                    -- ลบส่วนควบคุมการลอย
                    if floatPosition then
                        floatPosition:Destroy()
                        floatPosition = nil
                        print("FloatPosition destroyed")
                    end
                end
            end)
        end
        
        -- ลบ FloatPosition เมื่อออกจาก loop
        if floatPosition then
            floatPosition:Destroy()
            floatPosition = nil
        end
    end)
end

-- ฟังก์ชันตรวจสอบเลือดหิน
local function getRockHealth(rockModel)
    if not rockModel or not rockModel.Parent then
        return 0, 0
    end
    
    local health = rockModel:GetAttribute("Health") or 0
    local maxHealth = rockModel:GetAttribute("MaxHealth") or 0
    
    if health == 0 and rockModel:FindFirstChild("Humanoid") then
        health = rockModel.Humanoid.Health
        maxHealth = rockModel.Humanoid.MaxHealth
    end
    
    return health, maxHealth
end

-- ฟังก์ชันตรวจสอบว่าหินยังมีเลือดอยู่หรือไม่
local function checkRockHealth(rockModel)
    local health, _ = getRockHealth(rockModel)
    return health > 0
end

-- ฟังก์ชันค้นหาหินทั้งหมดตามประเภทที่เลือก (ไม่เอา currentTargetRock)
local function findAllRocks()
    allRocks = {}
    local rockTypes = {}
    
    local function exploreUntilModel(obj)
        if obj.ClassName == "Model" then
            local health = obj:GetAttribute("Health")
            if health and health > 0 then
                local rockName = obj.Name
                if selectedRockType == "All Rocks" or rockName == selectedRockType then
                    -- ไม่เอาหินที่เป็นเป้าหมายปัจจุบัน (ถ้ามี)
                    if not currentTargetRock or obj ~= currentTargetRock then
                        table.insert(allRocks, obj)
                        
                        if not rockTypes[rockName] then
                            rockTypes[rockName] = 0
                        end
                        rockTypes[rockName] = rockTypes[rockName] + 1
                    end
                end
            end
            return
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            exploreUntilModel(child)
        end
    end
    
    if workspace:FindFirstChild("Rocks") then
        exploreUntilModel(workspace.Rocks)
    end
    
    if #allRocks > 0 then
        print("=== Found Rock Types ===")
        for rockType, count in pairs(rockTypes) do
            print(rockType .. ": " .. count .. "x")
        end
        print("Total rocks with health: " .. #allRocks)
        print("Selected type: " .. selectedRockType)
        print("====================")
    end
    
    return #allRocks
end

-- ฟังก์ชันหยุดการเคลื่อนที่และ farm หินปัจจุบัน
local function stopCurrentFarm()
    print("Stopping current farm...")
    
    -- หยุดค้างตำแหน่ง
    isHoldingAtRock = false
    isMovingToRock = false
    
    -- หยุด Tween ปัจจุบัน
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    
    -- ล้างหินเป้าหมายปัจจุบัน
    currentTargetRock = nil
    
    -- รอเล็กน้อยให้ระบบหยุดทำงาน
    wait(0.5)
end

-- ฟังก์ชัน Tween ไปยังหิน (แก้ไขปัญหาหินใกล้เกินไป)
local function tweenToRock(rockModel)
    if not rockModel or not isAutoFarming then 
        isMovingToRock = false
        return false 
    end
    
    isMovingToRock = true
    
    -- ตั้งหินเป้าหมายปัจจุบัน
    currentTargetRock = rockModel
    
    -- หาตำแหน่งของหิน
    local rockPosition
    if rockModel:FindFirstChild("PrimaryPart") then
        rockPosition = rockModel.PrimaryPart.Position
    elseif rockModel:FindFirstChild("HumanoidRootPart") then
        rockPosition = rockModel.HumanoidRootPart.Position
    else
        rockPosition = rockModel:GetPivot().Position
    end
    
    -- ตำแหน่งเป้าหมาย = ตำแหน่งหิน + offset
    local targetPosition = rockPosition + Vector3.new(xOffset, yOffset, zOffset)
    
    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then 
        isMovingToRock = false
        return false 
    end
    
    -- ตรวจสอบระยะทาง
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    
    print(string.format("Moving to rock: %s | Distance: %.2f studs", rockModel.Name, distance))
    
    -- ถ้าอยู่ใกล้เกินไป (น้อยกว่า 5 studs) ให้ใช้วิธี teleport แทน tween
    if distance < 5 then
        print("Rock is very close, teleporting instead of tweening...")
        
        -- ตรวจสอบว่า FloatPosition มีอยู่หรือไม่
        if not humanoidRootPart:FindFirstChild("FloatPosition") then
            floatPosition = Instance.new("BodyPosition")
            floatPosition.Name = "FloatPosition"
            floatPosition.Parent = humanoidRootPart
            floatPosition.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
            floatPosition.Position = targetPosition
        else
            floatPosition = humanoidRootPart:FindFirstChild("FloatPosition")
            floatPosition.Position = targetPosition
        end
        
        -- Teleport ไปเลย
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
        print("Teleported to rock")
        isMovingToRock = false
        return true
    end
    
    -- ถ้าอยู่ในระยะปานกลาง (5-20 studs) ให้ใช้วิธีเคลื่อนที่ธรรมดา
    local speed = TweenSpeedSlider.CurrentValue
    local travelTime = distance / speed
    
    -- จำกัดเวลาเดินทาง
    if travelTime < 0.3 then
        travelTime = 0.3
    elseif travelTime > 8 then
        travelTime = 8
    end
    
    print(string.format("Using tween: Speed: %.2f studs/sec | Time: %.2f sec", speed, travelTime))
    
    -- หยุด Tween เดิมถ้ามี
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    
    -- สร้าง Tween ใหม่
    local tweenInfo = TweenInfo.new(
        travelTime,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    currentTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    currentTween:Play()
    
    -- ใช้ FloatPosition ช่วยในการเคลื่อนที่
    if not humanoidRootPart:FindFirstChild("FloatPosition") then
        floatPosition = Instance.new("BodyPosition")
        floatPosition.Name = "FloatPosition"
        floatPosition.Parent = humanoidRootPart
        floatPosition.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
        floatPosition.Position = humanoidRootPart.Position
    end
    
    local moveStartTime = tick()
    local maxMoveTime = 10
    
    while isAutoFarming and currentTargetRock == rockModel and distance > 2 and (tick() - moveStartTime) < maxMoveTime and isMovingToRock do
        if floatPosition and floatPosition.Parent then
            local direction = (targetPosition - humanoidRootPart.Position)
            if direction.Magnitude > 0 then
                floatPosition.Position = humanoidRootPart.Position + (direction.Unit * speed * 0.1)
            end
        end
        wait(0.1)
        distance = (humanoidRootPart.Position - targetPosition).Magnitude
        
        -- แสดง progress ทุก 2 วินาที
        if math.floor(tick() - moveStartTime) % 2 == 0 then
            print(string.format("Moving... Distance: %.2f studs", distance))
        end
    end
    
    -- รอให้ Tween เสร็จ (ถ้ายังไม่ถูก cancel)
    if currentTween and isMovingToRock then
        local success = pcall(function()
            currentTween.Completed:Wait()
        end)
        
        currentTween = nil
    end
    
    if distance <= 2 and currentTargetRock == rockModel then
        print("Arrived at rock: " .. rockModel.Name)
        isMovingToRock = false
        return true
    else
        print("Failed to reach rock or target changed")
        isMovingToRock = false
        return false
    end
end

-- ฟังก์ชัน farm หินเดียว (แก้ไขปัญหาหินเลือดหมดแล้วไม่ไปหาตัวใหม่)
local function farmSingleRock(rockModel)
    if not rockModel or not isAutoFarming then return false end
    
    local initialHealth, maxHealth = getRockHealth(rockModel)
    
    print(string.format("Starting to farm rock: %s | Initial health: %d/%d", rockModel.Name, initialHealth, maxHealth))
    
    -- Tween ไปหินใหม่
    local arrived = tweenToRock(rockModel)
    if not arrived then return false end
    
    -- รอจนกว่าหินจะเลือดหมด (ตีทำงานใน background)
    local checkStartTime = tick()
    local lastCheckTime = tick()
    local healthCheckInterval = 1 -- ตรวจสอบทุก 1 วินาที
    
    while isAutoFarming and currentTargetRock == rockModel and checkRockHealth(rockModel) do
        wait(0.5)
        
        -- ตรวจสอบเลือดปัจจุบัน (แค่แสดงข้อมูล)
        if tick() - lastCheckTime > healthCheckInterval then
            local currentHealth, _ = getRockHealth(rockModel)
            local healthPercent = (currentHealth / maxHealth) * 100
            
            -- แสดง progress ทุก 5 วินาที หรือเมื่อเลือดลดลงมาก
            if tick() - checkStartTime > 5 or currentHealth < initialHealth then
                print(string.format("Rock health: %d/%d (%.1f%%) | Time: %.1f sec", 
                    currentHealth, maxHealth, healthPercent, tick() - checkStartTime))
                lastCheckTime = tick()
            end
            
            initialHealth = currentHealth
        end
        
        -- ถ้ารอนานเกิน 60 วินาทีให้ข้าม (ป้องกันการค้าง)
        if tick() - checkStartTime > 60 then
            print("Farming taking too long, moving to next rock...")
            break
        end
    end
    
    -- ตรวจสอบผลลัพธ์
    local finalHealth, _ = getRockHealth(rockModel)
    if finalHealth <= 0 and currentTargetRock == rockModel then
        print("Successfully destroyed rock!")
        return true
    else
        print("Rock still has health or target changed")
        return false
    end
end

-- ฟังก์ชันเลือกหินใหม่ตามประเภท (ให้เลือกหินที่อยู่ไกลที่สุดก่อน)
local function selectNewRockByType()
    findAllRocks()
    
    if #allRocks == 0 then
        print("No rocks found for type: " .. selectedRockType)
        return nil
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        -- เลือกหินที่ยังมีเลือดอยู่เป็นอันแรก
        for _, rock in ipairs(allRocks) do
            if checkRockHealth(rock) then
                return rock
            end
        end
        return nil
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    
    -- หาหินที่อยู่ไกลที่สุด (เพื่อหลีกเลี่ยงปัญหาหินใกล้เกินไป)
    local farthestRock = nil
    local maxDistance = 0
    
    for _, rock in ipairs(allRocks) do
        if checkRockHealth(rock) then
            local rockPosition
            if rock:FindFirstChild("PrimaryPart") then
                rockPosition = rock.PrimaryPart.Position
            elseif rock:FindFirstChild("HumanoidRootPart") then
                rockPosition = rock.HumanoidRootPart.Position
            else
                rockPosition = rock:GetPivot().Position
            end
            
            local distance = (humanoidRootPart.Position - rockPosition).Magnitude
            
            if distance > maxDistance then
                maxDistance = distance
                farthestRock = rock
            end
        end
    end
    
    if farthestRock then
        print("Selected farthest rock: " .. farthestRock.Name .. " | Distance: " .. math.floor(maxDistance) .. " studs")
        return farthestRock
    else
        -- ถ้าไม่เจอหินไกล ให้เลือกหินแรกที่เจอ
        for _, rock in ipairs(allRocks) do
            if checkRockHealth(rock) then
                return rock
            end
        end
        return nil
    end
end

-- ฟังก์ชัน Auto Farm หลัก (แก้ไขปัญหาหินหมดแล้วไม่ไปหาตัวใหม่)
local function startAutoFarm()
    isAutoFarming = true
    toggleNoClip(true)
    setupFloatControl()
    
    -- ถือ Pickaxe ทันทีที่เริ่ม
    equipPickaxe()
    
    -- เริ่มตีหินทันที (ไม่ต้องรอถึงหิน)
    task.spawn(startContinuousMining)
    
    while isAutoFarming do
        -- เลือกหินตามประเภทที่เลือกใน dropdown
        local rockModel = selectNewRockByType()
        
        if not rockModel then
            print("No valid rocks found for type: " .. selectedRockType)
            
            -- ลองรีเฟรชลิสต์หิน
            wait(1)
            findAllRocks()
            
            if #allRocks == 0 then
                print("Still no rocks, waiting 3 seconds...")
                wait(3)
            end
            continue
        end
        
        print("Selected new rock: " .. rockModel.Name)
        
        -- Farm หินนี้
        local destroyed = farmSingleRock(rockModel)
        
        if destroyed and isAutoFarming and currentTargetRock == rockModel then
            print("Rock destroyed! Removing from list and finding next rock...")
            
            -- ลบหินนี้ออกจากลิสต์
            for i, r in ipairs(allRocks) do
                if r == rockModel then
                    table.remove(allRocks, i)
                    break
                end
            end
            
            -- รอสักครู่ก่อนหาหินใหม่
            wait(0.5)
            
            -- ล้าง target ปัจจุบัน
            currentTargetRock = nil
            isMovingToRock = false
            
        elseif isAutoFarming then
            print("Could not destroy rock or target changed, moving to next...")
            
            -- ถ้าหินยังไม่หมดเลือดและ target ไม่ได้เปลี่ยน ให้ลบออกจากลิสต์ชั่วคราว
            if currentTargetRock == rockModel then
                for i, r in ipairs(allRocks) do
                    if r == rockModel then
                        table.remove(allRocks, i)
                        break
                    end
                end
                
                -- ล้าง target
                currentTargetRock = nil
                isMovingToRock = false
            end
            
            wait(0.5)
        end
        
        -- รีเซ็ตตัวแปรเพื่อป้องกันการค้าง
        isMovingToRock = false
    end
    
    -- เมื่อหยุด farm
    stopCurrentFarm()
    stopMining()
    
    -- ลบ FloatPosition
    if floatPosition then
        floatPosition:Destroy()
        floatPosition = nil
    end
    
    toggleNoClip(false)
    isAutoFarming = false
    print("Auto Farm stopped")
end

-- สร้าง UI
local Window = Rayfield:CreateWindow({
   Name = "Miau hub",
   Icon = 0,
   LoadingTitle = "Miau hub",
   LoadingSubtitle = "by MX",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)
local Section = Tab:CreateSection("Auto Farm Settings")
Section:Set("Main")

-- สร้าง Dropdown
local function updateDropdownOptions()
    local rockTypes = {}
    
    local function collectRockTypes(obj)
        if obj.ClassName == "Model" and obj:GetAttribute("Health") then
            local rockName = obj.Name
            rockTypes[rockName] = true
            return
        end
        
        for _, child in ipairs(obj:GetChildren()) do
            collectRockTypes(child)
        end
    end
    
    if workspace:FindFirstChild("Rocks") then
        collectRockTypes(workspace.Rocks)
    end
    
    local options = {"All Rocks"}
    for rockType, _ in pairs(rockTypes) do
        table.insert(options, rockType)
    end
    
    return options
end

Dropdown = Tab:CreateDropdown({
    Name = "Select Rock Type",
    Options = {"All Rocks"},
    CurrentOption = "All Rocks",
    MultipleOptions = false,
    Flag = "RockDropdown",
    Callback = function(Option)
        local selected = Option
        if type(Option) == "table" then
            selected = Option[1] or "All Rocks"
        end
        
        local oldType = selectedRockType
        selectedRockType = selected
        
        print("Rock type changed: " .. oldType .. " → " .. selectedRockType)
        
        -- ถ้า Auto Farm กำลังทำงานอยู่ ให้เปลี่ยนเป้าหมายทันที
        if isAutoFarming then
            print("Auto Farm is running, switching to new rock type...")
            stopCurrentFarm()
            
            -- รอเล็กน้อยให้ระบบหยุด
            wait(0.5)
            
            -- ค้นหาหินใหม่ตามประเภท
            findAllRocks()
            
            if #allRocks > 0 then
                print("Found " .. #allRocks .. " rocks of type: " .. selectedRockType)
                Rayfield:Notify({
                    Title = "Target Changed",
                    Content = "Switching to " .. selectedRockType,
                    Duration = 3,
                    Image = 4483362458,
                })
            else
                print("No rocks found for new type")
                Rayfield:Notify({
                    Title = "No Rocks Found",
                    Content = "No " .. selectedRockType .. " found",
                    Duration = 3,
                    Image = 4483362458,
                })
            end
        end
    end,
})

-- Slider สำหรับปรับแกน X (จากหินเป็นศูนย์กลาง)
local XSlider = Tab:CreateSlider({
    Name = "X Offset from Rock",
    Range = {-10, 10},
    Increment = 0.5,
    Suffix = "studs",
    CurrentValue = 0,
    Flag = "XOffset",
    Callback = function(Value)
        xOffset = Value
        print("X Offset from rock center: " .. Value .. " studs")
    end,
})

-- Slider สำหรับปรับแกน Y (จากหินเป็นศูนย์กลาง)
local YSlider = Tab:CreateSlider({
    Name = "Y Offset from Rock",
    Range = {-5, 15},
    Increment = 0.5,
    Suffix = "studs",
    CurrentValue = 5,
    Flag = "YOffset",
    Callback = function(Value)
        yOffset = Value
        print("Y Offset from rock center: " .. Value .. " studs")
    end,
})

-- Slider สำหรับปรับแกน Z (จากหินเป็นศูนย์กลาง)
local ZSlider = Tab:CreateSlider({
    Name = "Z Offset from Rock",
    Range = {-10, 10},
    Increment = 0.5,
    Suffix = "studs",
    CurrentValue = 0,
    Flag = "ZOffset",
    Callback = function(Value)
        zOffset = Value
        print("Z Offset from rock center: " .. Value .. " studs")
    end,
})

SpeedSlider = Tab:CreateSlider({
    Name = "Mining Speed",
    Range = {0.05, 2}, -- ต่ำสุด 0.05 วินาทีสำหรับตีเร็ว
    Increment = 0.05,
    Suffix = "seconds",
    CurrentValue = 0.1,
    Flag = "MiningSpeed",
    Callback = function(Value)
        print("Mining speed: " .. Value .. " seconds (lower = faster)")
    end,
})

TweenSpeedSlider = Tab:CreateSlider({
    Name = "Tween Speed",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs/sec",
    CurrentValue = 50,
    Flag = "TweenSpeed",
    Callback = function(Value)
        print("Tween speed: " .. Value .. " studs/sec")
    end,
})

Button = Tab:CreateButton({
    Name = "Refresh Rocks",
    Callback = function()
        local rockCount = findAllRocks()
        
        local newOptions = updateDropdownOptions()
        pcall(function()
            Dropdown:Refresh(newOptions, selectedRockType)
        end)
        
        if rockCount > 0 then
            Rayfield:Notify({
                Title = "Rocks Loaded",
                Content = "Found " .. rockCount .. " " .. selectedRockType .. " with health",
                Duration = 3,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "No Rocks Found",
                Content = "No rocks with health found",
                Duration = 3,
                Image = 4483362458,
            })
        end
    end,
})

Toggle = Tab:CreateToggle({
   Name = "Auto Farm",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
        if Value then
            print("Starting Auto Farm...")
            print("Auto-equipping Pickaxe...")
            print("Current rock type: " .. selectedRockType)
            print("Offsets from rock - X:" .. xOffset .. " Y:" .. yOffset .. " Z:" .. zOffset)
            print("Fixed: Teleports when rock is close, finds farthest rocks first")
            
            if not LocalPlayer.Character then
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Character not found!",
                    Duration = 3,
                    Image = 4483362458,
                })
                Toggle:Set(false)
                return
            end
            
            task.spawn(startAutoFarm)
            
        else
            print("Stopping Auto Farm...")
            stopCurrentFarm()
            stopMining()
            isAutoFarming = false
            
            -- ลบ FloatPosition
            if floatPosition then
                floatPosition:Destroy()
                floatPosition = nil
            end
        end
   end,
})

-- Auto-refresh
task.spawn(function()
    wait(2)
    Button.Callback()
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function()
    if isAutoFarming then
        wait(2)
        print("Character respawned, continuing...")
        
        -- ถือ Pickaxe ใหม่เมื่อ respawn
        equipPickaxe()
        
        toggleNoClip(true)
        setupFloatControl()
        
        -- เริ่มตีใหม่
        if not miningActive then
            task.spawn(startContinuousMining)
        end
    end
end)

print("=== Miau Hub loaded ===")
print("Fixed issues:")
print("- Teleports when rock is too close (less than 5 studs)")
print("- Selects farthest rocks first to avoid close-range bugs")
print("- Properly moves to next rock after current is destroyed")
print("- Continuous mining from start")
print("- Dynamic target switching")
