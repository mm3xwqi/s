local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "x2zu on top",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 450)
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
local currentTween
local selectedFishName = "" -- เก็บชื่อปลาที่เลือก
local selectedFishIds = {} -- เก็บไอดีทั้งหมดของปลาที่มีชื่อเดียวกัน
local fishingCoroutine
local sellingCoroutine
local tweenSpeed = 100 -- ความเร็วเริ่มต้น
local oxygenCheckCoroutine
local oxygenRefillPosition = Vector3.new(-59, 4883, -49)
local autoSellInterval = 10 -- วินาที
local fishNameToIds = {} -- ตารางเก็บชื่อปลา -> ไอดีทั้งหมด
local activeFishIds = {} -- ไอดีปลาที่กำลังไล่จับ

-- ฟังก์ชันดึงรายชื่อปลาทั้งหมด (แสดงชื่อปลาที่ไม่ซ้ำกัน)
local function getUniqueFishNames()
    local uniqueNames = {}
    local fishFolder = workspace.Game.Fish.client
    
    -- ล้างตารางเก่า
    fishNameToIds = {}
    
    if fishFolder then
        for _, fish in pairs(fishFolder:GetChildren()) do
            if fish:IsA("Model") then
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

-- ฟังก์ชันตรวจสอบ CatchingBar UI
local function waitForCatchingSuccess(timeout)
    local startTime = tick()
    local maxWaitTime = timeout or 5
    
    while tick() - startTime < maxWaitTime do
        local catchingBar = game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("CatchingBar")
        
        if catchingBar then
            if catchingBar.Visible then
                local successIndicator = catchingBar:FindFirstChild("Check") or 
                                        catchingBar:FindFirstChild("Success") or
                                        catchingBar:FindFirstChild("Tick")
                
                if successIndicator then
                    if successIndicator.Visible then
                        print("Catching successful - tick mark visible")
                        return true
                    end
                else
                    for _, child in pairs(catchingBar:GetChildren()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            if child.Text and (child.Text:find("Success") or child.Text:find("Caught") or child.Text:find("Got it")) then
                                print("Catching successful - success text found")
                                return true
                            end
                        end
                    end
                end
            end
        else
            print("CatchingBar disappeared - assuming success")
            return true
        end
        
        wait(0.1)
    end
    
    print("Timeout waiting for catching success")
    return false
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
    
    currentTween = game:GetService("TweenService"):Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = CFrame.new(position.X, position.Y, position.Z)}
    )
    
    currentTween:Play()
    currentTween.Completed:Wait()
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
        while isAutoFishing do
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

-- ฟังก์ชันไล่จับปลาตามชื่อที่เลือก
local function startAutoFishingLoop()
    while isAutoFishing do
        -- อัปเดตรายการปลาที่มีชีวิตอยู่
        local aliveFishIds = {}
        for _, fishId in ipairs(selectedFishIds) do
            local health = getFishHealth(fishId)
            if health > 0 then
                table.insert(aliveFishIds, fishId)
            end
        end
        
        if #aliveFishIds == 0 then
            Window:Notify({
                Title = "No Active Fish",
                Desc = "All " .. selectedFishName .. " are dead or not found",
                Time = 3
            })
            wait(5)
            
            -- รีเฟรชรายการปลาใหม่
            if fishNameToIds[selectedFishName] then
                selectedFishIds = fishNameToIds[selectedFishName]
            else
                break
            end
            continue
        end
        
        -- ไล่จับปลาทีละตัวตามรายการ
        for _, fishId in ipairs(aliveFishIds) do
            if not isAutoFishing then break end
            
            -- หาปลา
            local fish = workspace.Game.Fish.client:FindFirstChild(fishId)
            if not fish then goto continue end
            
            local fishHead = fish:FindFirstChild("Head")
            if not fishHead then goto continue end
            
            -- ตรวจสอบเลือดก่อน
            local health = getFishHealth(fishId)
            if health <= 0 then goto continue end
            
            -- Teleport ไปหาปลา
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
            
            -- รอ 2 วินาทีให้ UI ขึ้นมา
            wait(2)
            
            -- ตรวจสอบว่า CatchingBar แสดงว่าจับปลาได้สำเร็จ
            local catchingSuccess = waitForCatchingSuccess(5)
            
            if catchingSuccess then
                -- รอจนกว่าปลาจะตาย (เลือด = 0)
                while getFishHealth(fishId) > 0 and isAutoFishing do
                    wait(1)
                end
                
                -- รันรีโมท SaveHotbar เมื่อปลาตาย
                local args2 = {
                    {
                        ["1"] = "1",
                        ["3"] = fishId,
                        ["2"] = "36e94fbc4fcc4e38b16242dc3aea0730"
                    }
                }
                
                -- พิมพ์ข้อความเพื่อตรวจสอบ
                print("=== FISH CATCHED ===")
                print("Fish ID:", fishId)
                print("Fish Name:", selectedFishName)
                print("Health:", getFishHealth(fishId))
                print("Running SaveHotbar...")
                
                local success, result = pcall(function()
                    return game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args2))
                end)
                
                if success then
                    print("SaveHotbar executed successfully!")
                else
                    print("ERROR executing SaveHotbar:", result)
                end
                print("==================")
            else
                Window:Notify({
                    Title = "Catching Failed",
                    Desc = "Fish catching did not complete successfully",
                    Time = 2
                })
            end
            
            -- รอสักครู่ก่อนไปหาปลาตัวต่อไป
            wait(2)
            
            ::continue::
        end
        
        -- รอสักครู่ก่อนเริ่มรอบใหม่
        wait(3)
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
        if fishNameToIds[choice] then
            selectedFishIds = fishNameToIds[choice]
        else
            selectedFishIds = {}
        end
        
        print("=== FISH SELECTED ===")
        print("Fish Name:", selectedFishName)
        print("Fish IDs Count:", #selectedFishIds)
        print("Fish IDs:", table.concat(selectedFishIds, ", "))
        print("===================")
        
        Window:Notify({
            Title = "Fish Selected",
            Desc = "Selected " .. selectedFishName .. " (" .. #selectedFishIds .. " fish)",
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
        for name, ids in pairs(fishNameToIds) do
            print("Fish Name:", name, "| Count:", #ids, "| IDs:", table.concat(ids, ", "))
        end
        print("======================")
        
        Window:Notify({
            Title = "Refreshed",
            Desc = "Fish list updated! Found " .. #uniqueNames .. " fish types",
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
            if selectedFishName == "" or #selectedFishIds == 0 then
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
        if selectedFishName == "" or #selectedFishIds == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish type first!",
                Time = 3
            })
            return
        end
        
        -- ใช้ไอดีปลาตัวแรกในรายการ
        local fishId = selectedFishIds[1]
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
        if selectedFishName == "" or #selectedFishIds == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish type first!",
                Time = 3
            })
            return
        end
        
        local healthInfo = "Fish Health for " .. selectedFishName .. ":\n"
        local aliveCount = 0
        
        for i, fishId in ipairs(selectedFishIds) do
            local health = getFishHealth(fishId)
            if health > 0 then
                aliveCount = aliveCount + 1
            end
            healthInfo = healthInfo .. "Fish " .. i .. " (" .. fishId .. "): " .. health .. " HP\n"
        end
        
        print("=== FISH HEALTH CHECK ===")
        print(healthInfo)
        print("Alive: " .. aliveCount .. "/" .. #selectedFishIds)
        print("========================")
        
        Window:Notify({
            Title = "Fish Health",
            Desc = healthInfo .. "\nAlive: " .. aliveCount .. "/" .. #selectedFishIds,
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
        if selectedFishName == "" or #selectedFishIds == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish type first!",
                Time = 3
            })
            return
        end
        
        local fishId = selectedFishIds[1]
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

-- ปุ่มตรวจสอบ CatchingBar
Tab:Button({
    Title = "Check CatchingBar",
    Desc = "Debug: Check CatchingBar UI status",
    Callback = function()
        local catchingBar = game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("CatchingBar")
        
        if catchingBar then
            local details = "CatchingBar found:\n"
            details = details .. "Visible: " .. tostring(catchingBar.Visible) .. "\n"
            
            for _, child in pairs(catchingBar:GetChildren()) do
                details = details .. child.Name .. " (" .. child.ClassName .. ")"
                if child:IsA("GuiObject") then
                    details = details .. " - Visible: " .. tostring(child.Visible)
                end
                details = details .. "\n"
            end
            
            print(details)
            Window:Notify({
                Title = "CatchingBar Status",
                Desc = details,
                Time = 5
            })
        else
            Window:Notify({
                Title = "CatchingBar Not Found",
                Desc = "CatchingBar UI is not visible",
                Time = 3
            })
        end
    end
})

Window:Notify({
    Title = "UI Loaded",
    Desc = "Auto Fish & Auto Sell UI loaded successfully!",
    Time = 3
})

-- พิมพ์ข้อมูลเริ่มต้น
print("=== AUTO FISH UI LOADED ===")
print("Select a fish type to start hunting")
print("============================")
