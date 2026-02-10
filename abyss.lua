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
local selectedFishId = ""
local fishingCoroutine
local sellingCoroutine
local tweenSpeed = 100 -- ความเร็วเริ่มต้น
local oxygenCheckCoroutine
local oxygenRefillPosition = Vector3.new(-59, 4883, -49)
local autoSellInterval = 10 -- วินาที

-- ฟังก์ชันดึงรายชื่อปลาทั้งหมด
local function getFishList()
    local fishList = {}
    local fishFolder = workspace.Game.Fish.client
    
    if fishFolder then
        for _, fish in pairs(fishFolder:GetChildren()) do
            if fish:IsA("Model") then
                table.insert(fishList, fish.Name)
            end
        end
    end
    
    return fishList
end

-- ฟังก์ชันตรวจสอบออกซิเจน
local function checkOxygen()
    local character = game.Players.LocalPlayer.Character
    if not character then return 100 end
    
    -- ตรวจสอบว่าออกซิเจนอยู่ที่ไหน (อาจต้องปรับตามเกม)
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- กรณีที่ออกซิเจนอยู่ใน Humanoid
        if humanoid:FindFirstChild("Oxygen") then
            return humanoid.Oxygen
        end
    end
    
    -- กรณีอื่นๆ
    for _, child in pairs(character:GetChildren()) do
        if child.Name == "Oxygen" and child:IsA("NumberValue") then
            return child.Value
        end
    end
    
    return 100 -- ถ้าไม่พบ คืนค่า 100
end

-- ฟังก์ชันตรวจสอบ CatchingBar UI
local function waitForCatchingSuccess(timeout)
    local startTime = tick()
    local maxWaitTime = timeout or 5 -- รอสูงสุด 5 วินาที
    
    while tick() - startTime < maxWaitTime do
        -- ตรวจสอบว่า CatchingBar ปรากฏขึ้น
        local catchingBar = game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("CatchingBar")
        
        if catchingBar then
            -- ตรวจสอบว่า CatchingBar มีการติ๊กถูก (เช่น มีการแสดงว่าจับปลาได้)
            -- อาจตรวจสอบจาก Visible, Image, หรือคุณสมบัติอื่นๆ
            if catchingBar.Visible then
                -- ตรวจสอบว่ามี indication ของการจับปลาสำเร็จหรือไม่
                -- เช่น มี ImageLabel ที่แสดงเครื่องหมายถูก
                local successIndicator = catchingBar:FindFirstChild("Check") or 
                                        catchingBar:FindFirstChild("Success") or
                                        catchingBar:FindFirstChild("Tick")
                
                if successIndicator then
                    if successIndicator.Visible then
                        print("Catching successful - tick mark visible")
                        return true
                    end
                else
                    -- ถ้าไม่มี indicator เฉพาะ ตรวจสอบจากคุณสมบัติอื่น
                    -- เช่น CatchingBar หายไป หรือมีข้อความสำเร็จ
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
            -- ถ้า CatchingBar หายไป อาจหมายถึงการจับปลาเสร็จสิ้น
            print("CatchingBar disappeared - assuming success")
            return true
        end
        
        wait(0.1) -- ตรวจสอบทุก 0.1 วินาที
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
    
    -- สร้าง Tween
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
    
    -- รอจนออกซิเจนเต็ม
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
                -- หยุดการจับปลาชั่วคราว
                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end
                
                -- ไปเติมออกซิเจน
                refillOxygen()
            end
            
            wait(1) -- ตรวจสอบทุก 1 วินาที
        end
    end)
    
    coroutine.resume(oxygenCheckCoroutine)
end

-- ฟังก์ชันเริ่ม Auto Fishing
local function startAutoFishingLoop()
    while isAutoFishing do
        if selectedFishId == "" or not workspace.Game.Fish.client:FindFirstChild(selectedFishId) then
            Window:Notify({
                Title = "Error",
                Desc = "Fish not found or not selected!",
                Time = 3
            })
            break
        end
        
        -- หาปลา
        local fish = workspace.Game.Fish.client:FindFirstChild(selectedFishId)
        if not fish then
            wait(2)
            continue
        end
        
        local fishHead = fish:FindFirstChild("Head")
        if not fishHead then
            wait(2)
            continue
        end
        
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
        local args1 = {
            selectedFishId
        }
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args1))
        
        -- รอ 2 วินาทีให้ UI ขึ้นมา
        wait(2)
        
        -- ตรวจสอบว่า CatchingBar แสดงว่าจับปลาได้สำเร็จ
        local catchingSuccess = waitForCatchingSuccess(5) -- รอสูงสุด 5 วินาที
        
        if catchingSuccess then
            -- รันรีโมท SaveHotbar เมื่อจับปลาได้สำเร็จ
            local args2 = {
                {
                    ["1"] = "1",
                    ["3"] = selectedFishId,
                    ["2"] = "36e94fbc4fcc4e38b16242dc3aea0730"
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args2))
            
            print("SaveHotbar executed after catching success")
        else
            Window:Notify({
                Title = "Catching Failed",
                Desc = "Fish catching did not complete successfully",
                Time = 2
            })
        end
        
        -- รอก่อนจับปลาตัวต่อไป
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

-- สร้าง Dropdown สำหรับเลือกปลา
local fishDropdown = Tab:Dropdown({
    Title = "Select Fish",
    List = getFishList(),
    Value = "",
    Callback = function(choice)
        selectedFishId = choice
        print("Selected Fish ID:", selectedFishId)
    end
})

-- ปุ่มรีเฟรชรายชื่อปลา
Tab:Button({
    Title = "Refresh Fish List",
    Desc = "Update available fish",
    Callback = function()
        fishDropdown:UpdateList(getFishList())
        Window:Notify({
            Title = "Refreshed",
            Desc = "Fish list updated!",
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
            if selectedFishId == "" then
                Window:Notify({
                    Title = "Error",
                    Desc = "Please select a fish first!",
                    Time = 3
                })
                autoFishToggle:Set(false)
                return
            end
            
            -- รันรีโมท Equip 1 รอบ
            local equipArgs = {
                "1"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("Equip"):InvokeServer(unpack(equipArgs))
            
            Window:Notify({
                Title = "Auto Fish Started",
                Desc = "Equipped and starting to fish: " .. selectedFishId,
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
            local equipArgs = {
                "1"
            }
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
        if selectedFishId == "" then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish first!",
                Time = 3
            })
            return
        end
        
        local args = {
            {
                ["1"] = "1",
                ["3"] = selectedFishId,
                ["2"] = "36e94fbc4fcc4e38b16242dc3aea0730"
            }
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args))
        
        Window:Notify({
            Title = "Hotbar Saved",
            Desc = "SaveHotbar remote executed!",
            Time = 3
        })
    end
})

-- ปุ่มสำหรับรันรีโมท Equip
Tab:Button({
    Title = "Equip",
    Desc = "Run Equip remote manually",
    Callback = function()
        local args = {
            "1"
        }
        
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
        if selectedFishId == "" then
            Window:Notify({
                Title = "Error",
                Desc = "Please select a fish first!",
                Time = 3
            })
            return
        end
        
        local args = {
            selectedFishId
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args))
        
        Window:Notify({
            Title = "Started Catching",
            Desc = "StartCatching remote executed!",
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
            
            -- ตรวจสอบ children
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
    Time = 2
})
