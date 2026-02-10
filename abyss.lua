local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "x2zu on top",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 500)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "x2zu"
    }
})

local Tab = Window:Tab({Title = "Main", Icon = "star"})

Tab:Section({Title = "Fishing Settings"})

-- ตัวแปรเก็บสถานะ
local isAutoFishing = false
local isAutoSelling = false
local isFishAura = false
local currentTween
local selectedFishName = "" -- เก็บชื่อปลาที่เลือก
local selectedFishIds = {} -- เก็บไอดีทั้งหมดของปลาที่มีชื่อเดียวกัน
local fishingCoroutine
local sellingCoroutine
local fishAuraCoroutine
local tweenSpeed = 100 -- ความเร็วเริ่มต้น
local oxygenCheckCoroutine
local oxygenRefillPosition = Vector3.new(-59, 4883, -49)
local autoSellInterval = 10 -- วินาที
local fishNameToIds = {} -- ตารางเก็บชื่อปลา -> ไอดีทั้งหมด
local fishAuraMode = "Nearest" -- โหมด Fish Aura: Min HP, Max HP, Nearest
local allFishIds = {} -- เก็บไอดีปลาทั้งหมด (สำหรับโหมด All)

-- ฟังก์ชันดึงรายชื่อปลาทั้งหมด (แสดงชื่อปลาที่ไม่ซ้ำกัน)
local function getUniqueFishNames()
    local uniqueNames = {"All"} -- เพิ่มตัวเลือก All
    local fishFolder = workspace.Game.Fish.client
    
    -- ล้างตารางเก่า
    fishNameToIds = {}
    allFishIds = {}
    
    if fishFolder then
        for _, fish in pairs(fishFolder:GetChildren()) do
            if fish:IsA("Model") then
                -- เก็บไอดีปลาทั้งหมด
                table.insert(allFishIds, fish.Name)
                
                -- พยายามดึงชื่อปลาจริงจากปลา
                local displayName = fish.Name -- เริ่มต้นด้วย ID
                
                -- ลองหาชื่อปลาจาก Attribute
                if fish:GetAttribute("Name") then
                    displayName = fish:GetAttribute("Name")
                end
                
                -- ลองหาจาก Parts ที่อาจมีชื่อ
                local head = fish:FindFirstChild("Head")
                if head then
                    -- ลองหาจาก BillboardGui
                    local billboardGui = head:FindFirstChildWhichIsA("BillboardGui")
                    if billboardGui then
                        local textLabel = billboardGui:FindFirstChildWhichIsA("TextLabel")
                        if textLabel and textLabel.Text ~= "" then
                            displayName = textLabel.Text
                        end
                    end
                    
                    -- ลองหาจากอื่นๆ
                    for _, child in pairs(head:GetChildren()) do
                        if child:IsA("StringValue") and child.Name == "FishName" then
                            displayName = child.Value
                        elseif child:IsA("StringValue") and child.Name == "Name" then
                            displayName = child.Value
                        end
                    end
                end
                
                -- เก็บไอดีปลาตามชื่อ
                if not fishNameToIds[displayName] then
                    fishNameToIds[displayName] = {}
                    table.insert(uniqueNames, displayName)
                end
                table.insert(fishNameToIds[displayName], fish.Name)
            end
        end
    end
    
    return uniqueNames
end

-- ฟังก์ชันตรวจสอบเลือดปลา
local function getFishHealth(fishId)
    local fish = workspace.Game.Fish.client:FindFirstChild(fishId)
    if not fish then return 0 end
    
    local head = fish:FindFirstChild("Head")
    if not head then return 0 end
    
    local stats = head:FindFirstChild("stats")
    if not stats then return 0 end
    
    local health = stats:FindFirstChild("Health")
    if not health then return 0 end
    
    local amount = health:FindFirstChild("Amount")
    if not amount then return 0 end
    
    return amount.Value
end

-- ฟังก์ชันตรวจสอบระยะทาง
local function getDistanceToFish(fishId)
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return math.huge end
    
    local fish = workspace.Game.Fish.client:FindFirstChild(fishId)
    if not fish then return math.huge end
    
    local head = fish:FindFirstChild("Head")
    if not head then return math.huge end
    
    return (character.HumanoidRootPart.Position - head.Position).Magnitude
end

-- ฟังก์ชันค้นหาปลาตามเงื่อนไข Fish Aura
local function findBestFishForAura()
    local character = game.Players.LocalPlayer.Character
    if not character then return nil end
    
    local aliveFishIds = {}
    
    -- ตรวจสอบว่าจะค้นหาปลาแบบไหน
    if selectedFishName == "All" then
        -- ใช้ปลาทั้งหมด
        for _, fishId in ipairs(allFishIds) do
            if getFishHealth(fishId) > 0 then
                table.insert(aliveFishIds, fishId)
            end
        end
    else
        -- ใช้เฉพาะปลาที่เลือก
        if fishNameToIds[selectedFishName] then
            for _, fishId in ipairs(fishNameToIds[selectedFishName]) do
                if getFishHealth(fishId) > 0 then
                    table.insert(aliveFishIds, fishId)
                end
            end
        end
    end
    
    if #aliveFishIds == 0 then
        return nil
    end
    
    -- เลือกปลาตามโหมด
    if fishAuraMode == "Min HP" then
        -- หาปลาที่เลือดน้อยที่สุด
        local bestFish = aliveFishIds[1]
        local minHealth = getFishHealth(bestFish)
        
        for _, fishId in ipairs(aliveFishIds) do
            local health = getFishHealth(fishId)
            if health < minHealth then
                minHealth = health
                bestFish = fishId
            end
        end
        return bestFish
        
    elseif fishAuraMode == "Max HP" then
        -- หาปลาที่เลือดมากที่สุด
        local bestFish = aliveFishIds[1]
        local maxHealth = getFishHealth(bestFish)
        
        for _, fishId in ipairs(aliveFishIds) do
            local health = getFishHealth(fishId)
            if health > maxHealth then
                maxHealth = health
                bestFish = fishId
            end
        end
        return bestFish
        
    else -- Nearest
        -- หาปลาที่ใกล้ที่สุด
        local bestFish = aliveFishIds[1]
        local minDistance = getDistanceToFish(bestFish)
        
        for _, fishId in ipairs(aliveFishIds) do
            local distance = getDistanceToFish(fishId)
            if distance < minDistance then
                minDistance = distance
                bestFish = fishId
            end
        end
        return bestFish
    end
end

-- ฟังก์ชันตรวจสอบออกซิเจน
local function checkOxygen()
    local character = game.Players.LocalPlayer.Character
    if not character then return 100 end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        if humanoid:FindFirstChild("Oxygen") then
            return humanoid.Oxygen
        end
    end
    
    for _, child in pairs(character:GetChildren()) do
        if child.Name == "Oxygen" and child:IsA("NumberValue") then
            return child.Value
        end
    end
    
    return 100
end

-- ฟังก์ชัน teleport ไปหาตำแหน่ง
local function teleportToPosition(position, speed)
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local humanoidRootPart = character.HumanoidRootPart
    local currentPosition = humanoidRootPart.Position
    local distance = (position - currentPosition).Magnitude
    local time = distance / speed
    
    local tweenInfo = TweenInfo.new(
        time,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    if currentTween then
        currentTween:Cancel()
    end
    
    currentTween = game:GetService("TweenService"):Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = CFrame.new(position.X, position.Y, position.Z)}
    )
    
    currentTween:Play()
    currentTween.Completed:Wait()
    return true
end

-- ฟังก์ชันติดตามปลาไปเรื่อยๆจนกว่าจะตาย
local function followFishUntilDead(fishId, speed)
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local humanoidRootPart = character.HumanoidRootPart
    
    print("=== START FOLLOWING FISH ===")
    print("Fish ID:", fishId)
    print("Starting health:", getFishHealth(fishId))
    print("Mode:", fishAuraMode)
    
    -- ติดตามปลาไปเรื่อยๆจนกว่าปลาจะตาย
    while getFishHealth(fishId) > 0 and (isAutoFishing or isFishAura) do
        local fish = workspace.Game.Fish.client:FindFirstChild(fishId)
        if not fish then break end
        
        local fishHead = fish:FindFirstChild("Head")
        if not fishHead then break end
        
        local targetPosition = fishHead.Position
        local currentPosition = humanoidRootPart.Position
        local distance = (targetPosition - currentPosition).Magnitude
        
        -- ถ้าอยู่ไกลเกินไป ให้ teleport ไปหา
        if distance > 50 then
            local time = distance / speed
            local tweenInfo = TweenInfo.new(
                time,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out,
                0,
                false,
                0
            )
            
            if currentTween then
                currentTween:Cancel()
            end
            
            currentTween = game:GetService("TweenService"):Create(
                humanoidRootPart,
                tweenInfo,
                {CFrame = CFrame.new(targetPosition.X, targetPosition.Y, targetPosition.Z)}
            )
            
            currentTween:Play()
            currentTween.Completed:Wait()
        else
            -- ถ้าอยู่ใกล้แล้ว ให้เดินตามแบบ smooth
            local time = math.min(1, distance / speed)  -- จำกัดเวลาสูงสุดที่ 1 วินาที
            local tweenInfo = TweenInfo.new(
                time,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out,
                0,
                false,
                0
            )
            
            if currentTween then
                currentTween:Cancel()
            end
            
            currentTween = game:GetService("TweenService"):Create(
                humanoidRootPart,
                tweenInfo,
                {CFrame = CFrame.new(targetPosition.X, targetPosition.Y, targetPosition.Z)}
            )
            
            currentTween:Play()
            wait(time + 0.1)  -- รอจนกว่า tween จะเสร็จ + buffer
        end
        
        -- พิมพ์สถานะเลือดปลา
        local health = getFishHealth(fishId)
        print("Fish health:", health)
        
        wait(0.5)  -- ตรวจสอบทุก 0.5 วินาที
    end
    
    print("=== FISH DIED ===")
    print("Fish ID:", fishId)
    print("Final health:", getFishHealth(fishId))
    return true
end

-- ฟังก์ชันเติมออกซิเจน
local function refillOxygen()
    Window:Notify({
        Title = "Low Oxygen",
        Desc = "Teleporting to refill oxygen...",
        Time = 3
    })
    
    teleportToPosition(oxygenRefillPosition, tweenSpeed)
    
    while checkOxygen() < 100 do
        wait(1)
    end
    
    Window:Notify({
        Title = "Oxygen Refilled",
        Desc = "Oxygen is now full!",
        Time = 3
    })
end

-- ฟังก์ชันตรวจสอบและเติมออกซิเจน (รันในพื้นหลัง)
local function startOxygenCheck()
    oxygenCheckCoroutine = coroutine.create(function()
        while isAutoFishing or isFishAura do
            local oxygenLevel = checkOxygen()
            
            if oxygenLevel < 10 then
                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end
                
                refillOxygen()
            end
            
            wait(1)
        end
    end)
    
    coroutine.resume(oxygenCheckCoroutine)
end

-- ฟังก์ชันเริ่ม Auto Fishing (สำหรับโหมดปกติ)
local function startAutoFishingLoop()
    while isAutoFishing do
        if selectedFishName == "" then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish type first!",
                Time = 3
            })
            break
        end
        
        -- กำหนดรายการปลาที่จะจับ
        local targetFishIds = {}
        if selectedFishName == "All" then
            -- ใช้ปลาทั้งหมด
            for _, fishId in ipairs(allFishIds) do
                if getFishHealth(fishId) > 0 then
                    table.insert(targetFishIds, fishId)
                end
            end
        else
            -- ใช้เฉพาะปลาที่เลือก
            if fishNameToIds[selectedFishName] then
                for _, fishId in ipairs(fishNameToIds[selectedFishName]) do
                    if getFishHealth(fishId) > 0 then
                        table.insert(targetFishIds, fishId)
                    end
                end
            else
                targetFishIds = {}
            end
        end
        
        if #targetFishIds == 0 then
            Window:Notify({
                Title = "No Active Fish",
                Desc = "No fish available for fishing",
                Time = 3
            })
            wait(5)
            continue
        end
        
        -- ไล่จับปลาทีละตัวตามรายการ
        for _, fishId in ipairs(targetFishIds) do
            if not isAutoFishing then break end
            
            -- หาปลา
            local fish = workspace.Game.Fish.client:FindFirstChild(fishId)
            if not fish then 
                wait(0.5)
                continue
            end
            
            local fishHead = fish:FindFirstChild("Head")
            if not fishHead then 
                wait(0.5)
                continue
            end
            
            -- ตรวจสอบเลือดก่อน
            local health = getFishHealth(fishId)
            if health <= 0 then 
                wait(0.5)
                continue
            end
            
            print("=== STARTING TO CATCH FISH ===")
            print("Fish ID:", fishId)
            print("Fish Name:", selectedFishName)
            print("Initial health:", health)
            
            -- Teleport ไปหาปลาเริ่มต้น
            local success = teleportToPosition(fishHead.Position, tweenSpeed)
            if not success then
                Window:Notify({
                    Title = "Error",
                    Desc = "Failed to teleport to fish!",
                    Time = 3
                })
                break
            end
            
            -- รอ 1 วินาที
            wait(1)
            
            -- เมื่อถึงปลา: รันรีโมท StartCatching
            local args1 = { fishId }
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args1))
            
            print("StartCatching remote executed for fish:", fishId)
            
            -- ติดตามปลาไปเรื่อยๆจนกว่าปลาจะตาย
            followFishUntilDead(fishId, tweenSpeed)
            
            -- หลังจากปลาตายแล้ว รันรีโมท SaveHotbar
            local args2 = {
                {
                    ["1"] = "1",
                    ["3"] = fishId,
                    ["2"] = "36e94fbc4fcc4e38b16242dc3aea0730"
                }
            }
            
            print("=== RUNNING SAVE HOTBAR ===")
            print("Fish caught! Running SaveHotbar...")
            print("Fish ID for SaveHotbar:", fishId)
            print("Arguments:", args2)
            
            -- รันรีโมท SaveHotbar
            local success, result = pcall(function()
                return game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args2))
            end)
            
            if success then
                print("SaveHotbar executed successfully!")
                print("Result:", result)
                
                -- แจ้งเตือนผู้ใช้
                Window:Notify({
                    Title = "Fish Caught!",
                    Desc = "Fish has been caught and saved!",
                    Time = 3
                })
            else
                print("ERROR executing SaveHotbar:", result)
                
                -- ลองอีกครั้งถ้าไม่สำเร็จ
                wait(1)
                local retrySuccess, retryResult = pcall(function()
                    return game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args2))
                end)
                
                if retrySuccess then
                    print("SaveHotbar retry successful!")
                else
                    print("SaveHotbar retry failed:", retryResult)
                end
            end
            print("=======================")
            
            -- รอสักครู่ก่อนไปหาปลาตัวต่อไป
            wait(2)
        end
        
        -- รอสักครู่ก่อนเริ่มรอบใหม่
        wait(3)
    end
end

-- ฟังก์ชันเริ่ม Fish Aura
local function startFishAuraLoop()
    while isFishAura do
        -- ค้นหาปลาที่ดีที่สุดตามเงื่อนไข
        local bestFishId = findBestFishForAura()
        
        if not bestFishId then
            Window:Notify({
                Title = "No Fish Found",
                Desc = "No fish available for Fish Aura",
                Time = 3
            })
            wait(5)
            continue
        end
        
        local fish = workspace.Game.Fish.client:FindFirstChild(bestFishId)
        if not fish then
            wait(1)
            continue
        end
        
        local fishHead = fish:FindFirstChild("Head")
        if not fishHead then
            wait(1)
            continue
        end
        
        -- ตรวจสอบเลือดก่อน
        local health = getFishHealth(bestFishId)
        if health <= 0 then
            wait(1)
            continue
        end
        
        print("=== FISH AURA TARGET ===")
        print("Selected fish ID:", bestFishId)
        print("Health:", health)
        print("Distance:", getDistanceToFish(bestFishId))
        print("Mode:", fishAuraMode)
        
        -- Teleport ไปหาปลา
        local success = teleportToPosition(fishHead.Position, tweenSpeed)
        if not success then
            Window:Notify({
                Title = "Error",
                Desc = "Failed to teleport to fish!",
                Time = 3
            })
            wait(2)
            continue
        end
        
        -- รอ 1 วินาที
        wait(1)
        
        -- เมื่อถึงปลา: รันรีโมท StartCatching
        local args1 = { bestFishId }
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args1))
        
        print("StartCatching remote executed for fish:", bestFishId)
        
        -- ติดตามปลาไปเรื่อยๆจนกว่าปลาจะตาย
        followFishUntilDead(bestFishId, tweenSpeed)
        
        -- หลังจากปลาตายแล้ว รันรีโมท SaveHotbar
        local args2 = {
            {
                ["1"] = "1",
                ["3"] = bestFishId,
                ["2"] = "36e94fbc4fcc4e38b16242dc3aea0730"
            }
        }
        
        print("=== FISH AURA SAVE HOTBAR ===")
        print("Fish caught by aura! Running SaveHotbar...")
        
        -- รันรีโมท SaveHotbar
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args2))
        end)
        
        if success then
            print("SaveHotbar executed successfully!")
        else
            print("ERROR executing SaveHotbar:", result)
        end
        print("============================")
        
        -- รอสักครู่ก่อนค้นหาปลาตัวต่อไป
        wait(2)
    end
end

-- ฟังก์ชัน Auto Sell
local function startAutoSelling()
    sellingCoroutine = coroutine.create(function()
        while isAutoSelling do
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("SellService"):WaitForChild("RF"):WaitForChild("SellInventory"):InvokeServer()
            
            Window:Notify({
                Title = "Auto Sell",
                Desc = "Sold inventory every " .. autoSellInterval .. " seconds",
                Time = 2
            })
            
            wait(autoSellInterval)
        end
    end)
    
    coroutine.resume(sellingCoroutine)
end

-- สร้าง Dropdown สำหรับเลือกปลา (แสดงชื่อปลาที่ไม่ซ้ำกัน)
local fishDropdown = Tab:Dropdown({
    Title = "Select Fish Type",
    List = getUniqueFishNames(),
    Value = "",
    Callback = function(choice)
        selectedFishName = choice
        if choice == "All" then
            selectedFishIds = allFishIds
        elseif fishNameToIds[choice] then
            selectedFishIds = fishNameToIds[choice]
        else
            selectedFishIds = {}
        end
        
        print("=== FISH SELECTED ===")
        print("Fish Name:", selectedFishName)
        print("Fish IDs Count:", #selectedFishIds)
        if #selectedFishIds <= 10 then
            print("Fish IDs:", table.concat(selectedFishIds, ", "))
        else
            print("Fish IDs: (first 10)", table.concat({table.unpack(selectedFishIds, 1, 10)}, ", "), "...")
        end
        print("===================")
        
        Window:Notify({
            Title = "Fish Selected",
            Desc = "Selected " .. selectedFishName .. " (" .. #selectedFishIds .. " fish)",
            Time = 3
        })
    end
})

-- Dropdown สำหรับเลือกโหมด Fish Aura
local fishAuraDropdown = Tab:Dropdown({
    Title = "Fish Aura Mode",
    List = {"Nearest", "Min HP", "Max HP"},
    Value = "Nearest",
    Callback = function(choice)
        fishAuraMode = choice
        print("Fish Aura mode set to:", fishAuraMode)
        
        Window:Notify({
            Title = "Fish Aura Mode",
            Desc = "Mode set to: " .. fishAuraMode,
            Time = 3
        })
    end
})

-- ปุ่มรีเฟรชรายชื่อปลา
Tab:Button({
    Title = "Refresh Fish List",
    Desc = "Update available fish",
    Callback = function()
        local uniqueNames = getUniqueFishNames()
        fishDropdown:UpdateList(uniqueNames)
        
        -- พิมพ์ข้อมูลปลาทั้งหมดสำหรับ debugging
        print("=== FISH LIST DEBUG ===")
        print("Total unique fish types:", #uniqueNames)
        print("Total fish count:", #allFishIds)
        for name, ids in pairs(fishNameToIds) do
            print("Fish Name:", name, "| Count:", #ids)
        end
        print("======================")
        
        Window:Notify({
            Title = "Refreshed",
            Desc = "Fish list updated! Found " .. #uniqueNames .. " fish types, " .. #allFishIds .. " total fish",
            Time = 3
        })
    end
})

-- Slider สำหรับความเร็ว Tween
Tab:Slider({
    Title = "Tween Speed",
    Desc = "Speed for teleporting (1-500)",
    Value = 100,
    Min = 1,
    Max = 500,
    Callback = function(value)
        tweenSpeed = value
        print("Tween speed set to:", tweenSpeed)
    end
})

-- Slider สำหรับ Auto Sell Interval
Tab:Slider({
    Title = "Auto Sell Interval",
    Desc = "Seconds between auto sells (1-60)",
    Value = 10,
    Min = 1,
    Max = 60,
    Callback = function(value)
        autoSellInterval = value
        print("Auto sell interval set to:", autoSellInterval, "seconds")
    end
})

-- Toggle สำหรับ Auto Fishing
local autoFishToggle = Tab:Toggle({
    Title = "Auto Fish",
    Desc = "Teleport to selected fish and catch it",
    Value = false,
    Callback = function(v)
        isAutoFishing = v
        
        if v then
            -- ปิด Fish Aura ถ้ากำลังเปิดอยู่
            if isFishAura then
                isFishAura = false
                if fishAuraCoroutine then
                    coroutine.close(fishAuraCoroutine)
                    fishAuraCoroutine = nil
                end
                fishAuraToggle:Set(false)
            end
            
            if selectedFishName == "" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Please select a fish type first!",
                    Time = 3
                })
                autoFishToggle:Set(false)
                return
            end
            
            -- รันรีโมท Equip 1 รอบ
            local equipArgs = { "1" }
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("Equip"):InvokeServer(unpack(equipArgs))
            
            Window:Notify({
                Title = "Auto Fish Started",
                Desc = "Hunting " .. selectedFishName .. " (" .. #selectedFishIds .. " fish)",
                Time = 3
            })
            
            -- เริ่มตรวจสอบออกซิเจน
            startOxygenCheck()
            
            -- เริ่ม Auto Fishing ใน coroutine แยก
            fishingCoroutine = coroutine.create(startAutoFishingLoop)
            coroutine.resume(fishingCoroutine)
        else
            -- หยุดตรวจสอบออกซิเจน
            if oxygenCheckCoroutine then
                coroutine.close(oxygenCheckCoroutine)
                oxygenCheckCoroutine = nil
            end
            
            -- หยุด Auto Fishing
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            
            if fishingCoroutine then
                coroutine.close(fishingCoroutine)
                fishingCoroutine = nil
            end
            
            -- รันรีโมท Equip อีกครั้งเมื่อปิด
            local equipArgs = { "1" }
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("Equip"):InvokeServer(unpack(equipArgs))
            
            Window:Notify({
                Title = "Auto Fish Stopped",
                Desc = "Stopped fishing and re-equipped",
                Time = 3
            })
        end
    end
})

-- Toggle สำหรับ Fish Aura
local fishAuraToggle = Tab:Toggle({
    Title = "Fish Aura",
    Desc = "Auto target fish based on selected mode",
    Value = false,
    Callback = function(v)
        isFishAura = v
        
        if v then
            -- ปิด Auto Fishing ถ้ากำลังเปิดอยู่
            if isAutoFishing then
                isAutoFishing = false
                if fishingCoroutine then
                    coroutine.close(fishingCoroutine)
                    fishingCoroutine = nil
                end
                autoFishToggle:Set(false)
            end
            
            if selectedFishName == "" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Please select a fish type first!",
                    Time = 3
                })
                fishAuraToggle:Set(false)
                return
            end
            
            -- รันรีโมท Equip 1 รอบ
            local equipArgs = { "1" }
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("Equip"):InvokeServer(unpack(equipArgs))
            
            Window:Notify({
                Title = "Fish Aura Started",
                Desc = "Targeting fish with mode: " .. fishAuraMode,
                Time = 3
            })
            
            -- เริ่มตรวจสอบออกซิเจน
            startOxygenCheck()
            
            -- เริ่ม Fish Aura ใน coroutine แยก
            fishAuraCoroutine = coroutine.create(startFishAuraLoop)
            coroutine.resume(fishAuraCoroutine)
        else
            -- หยุดตรวจสอบออกซิเจน
            if oxygenCheckCoroutine then
                coroutine.close(oxygenCheckCoroutine)
                oxygenCheckCoroutine = nil
            end
            
            -- หยุด Fish Aura
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            
            if fishAuraCoroutine then
                coroutine.close(fishAuraCoroutine)
                fishAuraCoroutine = nil
            end
            
            -- รันรีโมท Equip อีกครั้งเมื่อปิด
            local equipArgs = { "1" }
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("Equip"):InvokeServer(unpack(equipArgs))
            
            Window:Notify({
                Title = "Fish Aura Stopped",
                Desc = "Stopped fish aura and re-equipped",
                Time = 3
            })
        end
    end
})

Tab:Section({Title = "Auto Sell"})

-- Toggle สำหรับ Auto Sell
local autoSellToggle = Tab:Toggle({
    Title = "Auto Sell",
    Desc = "Automatically sell inventory every " .. autoSellInterval .. " seconds",
    Value = false,
    Callback = function(v)
        isAutoSelling = v
        
        if v then
            Window:Notify({
                Title = "Auto Sell Started",
                Desc = "Will sell inventory every " .. autoSellInterval .. " seconds",
                Time = 3
            })
            
            startAutoSelling()
        else
            -- หยุด Auto Selling
            if sellingCoroutine then
                coroutine.close(sellingCoroutine)
                sellingCoroutine = nil
            end
            
            Window:Notify({
                Title = "Auto Sell Stopped",
                Desc = "Stopped auto selling",
                Time = 3
            })
        end
    end
})

Tab:Section({Title = "Utilities"})

-- ปุ่มสำหรับรันรีโมท SaveHotbar ด้วยตัวเอง
Tab:Button({
    Title = "Save Hotbar",
    Desc = "Run SaveHotbar remote manually",
    Callback = function()
        if selectedFishName == "" then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish type first!",
                Time = 3
            })
            return
        end
        
        -- ใช้ไอดีปลาตัวแรกในรายการ
        local fishId = ""
        if selectedFishName == "All" and #allFishIds > 0 then
            fishId = allFishIds[1]
        elseif #selectedFishIds > 0 then
            fishId = selectedFishIds[1]
        else
            Window:Notify({
                Title = "Error",
                Desc = "No fish available",
                Time = 3
            })
            return
        end
        
        local args = {
            {
                ["1"] = "1",
                ["3"] = fishId,
                ["2"] = "36e94fbc4fcc4e38b16242dc3aea0730"
            }
        }
        
        print("=== MANUAL SAVE HOTBAR ===")
        print("Fish ID:", fishId)
        print("Fish Name:", selectedFishName)
        print("Arguments:", args)
        
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args))
        end)
        
        if success then
            print("SaveHotbar executed successfully!")
            Window:Notify({
                Title = "Hotbar Saved",
                Desc = "SaveHotbar remote executed for " .. selectedFishName,
                Time = 3
            })
        else
            print("ERROR executing SaveHotbar:", result)
            Window:Notify({
                Title = "Error",
                Desc = "Failed to execute SaveHotbar",
                Time = 3
            })
        end
        print("==========================")
    end
})

-- ปุ่มตรวจสอบเลือดปลา
Tab:Button({
    Title = "Check Fish Health",
    Desc = "Debug: Check health of selected fish",
    Callback = function()
        if selectedFishName == "" then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish type first!",
                Time = 3
            })
            return
        end
        
        local fishIdsToCheck = {}
        if selectedFishName == "All" then
            fishIdsToCheck = allFishIds
        else
            fishIdsToCheck = selectedFishIds
        end
        
        if #fishIdsToCheck == 0 then
            Window:Notify({
                Title = "No Fish",
                Desc = "No fish to check",
                Time = 3
            })
            return
        end
        
        local healthInfo = "Fish Health for " .. selectedFishName .. ":\n"
        local aliveCount = 0
        
        for i, fishId in ipairs(fishIdsToCheck) do
            if i <= 20 then  -- แสดงแค่ 20 ตัวแรก
                local health = getFishHealth(fishId)
                if health > 0 then
                    aliveCount = aliveCount + 1
                end
                healthInfo = healthInfo .. fishId .. ": " .. health .. " HP\n"
            end
        end
        
        if #fishIdsToCheck > 20 then
            healthInfo = healthInfo .. "... and " .. (#fishIdsToCheck - 20) .. " more\n"
        end
        
        print("=== FISH HEALTH CHECK ===")
        print(healthInfo)
        print("Alive: " .. aliveCount .. "/" .. #fishIdsToCheck)
        print("========================")
        
        Window:Notify({
            Title = "Fish Health",
            Desc = healthInfo .. "\nAlive: " .. aliveCount .. "/" .. #fishIdsToCheck,
            Time = 5
        })
    end
})

-- ปุ่มสำหรับรันรีโมท Equip
Tab:Button({
    Title = "Equip",
    Desc = "Run Equip remote manually",
    Callback = function()
        local args = { "1" }
        
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("Equip"):InvokeServer(unpack(args))
        
        Window:Notify({
            Title = "Equipped",
            Desc = "Equip remote executed!",
            Time = 3
        })
    end
})

-- ปุ่มสำหรับรันรีโมท StartCatching
Tab:Button({
    Title = "Start Catching",
    Desc = "Run StartCatching remote manually",
    Callback = function()
        if selectedFishName == "" then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish type first!",
                Time = 3
            })
            return
        end
        
        local fishId = ""
        if selectedFishName == "All" and #allFishIds > 0 then
            fishId = allFishIds[1]
        elseif #selectedFishIds > 0 then
            fishId = selectedFishIds[1]
        else
            Window:Notify({
                Title = "Error",
                Desc = "No fish available",
                Time = 3
            })
            return
        end
        
        local args = { fishId }
        
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args))
        
        Window:Notify({
            Title = "Started Catching",
            Desc = "StartCatching remote executed for " .. selectedFishName,
            Time = 3
        })
    end
})

-- ปุ่มสำหรับรันรีโมท SellInventory
Tab:Button({
    Title = "Sell Inventory",
    Desc = "Run SellInventory remote manually",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("SellService"):WaitForChild("RF"):WaitForChild("SellInventory"):InvokeServer()
        
        Window:Notify({
            Title = "Sold Inventory",
            Desc = "Inventory sold successfully!",
            Time = 3
        })
    end
})

-- ปุ่มสำหรับไปเติมออกซิเจน
Tab:Button({
    Title = "Refill Oxygen",
    Desc = "Teleport to oxygen refill position",
    Callback = function()
        refillOxygen()
    end
})

-- ปุ่มค้นหาปลาใกล้ที่สุด (สำหรับทดสอบ Fish Aura)
Tab:Button({
    Title = "Find Nearest Fish",
    Desc = "Debug: Find nearest fish manually",
    Callback = function()
        local bestFish = findBestFishForAura()
        if bestFish then
            local health = getFishHealth(bestFish)
            local distance = getDistanceToFish(bestFish)
            
            print("=== NEAREST FISH ===")
            print("Fish ID:", bestFish)
            print("Health:", health)
            print("Distance:", distance)
            print("Mode:", fishAuraMode)
            
            Window:Notify({
                Title = "Nearest Fish Found",
                Desc = "Fish ID: " .. bestFish .. "\nHealth: " .. health .. "\nDistance: " .. math.floor(distance),
                Time = 5
            })
        else
            Window:Notify({
                Title = "No Fish Found",
                Desc = "No alive fish found",
                Time = 3
            })
        end
    end
})

Window:Notify({
    Title = "UI Loaded",
    Desc = "Auto Fish, Fish Aura & Auto Sell UI loaded successfully!",
    Time = 3
})

-- พิมพ์ข้อมูลเริ่มต้น
print("=== FISHING UI LOADED ===")
print("Select a fish type to start hunting")
print("Features: Auto Fish, Fish Aura (Nearest/Min HP/Max HP), Auto Sell")
print("==================================")
