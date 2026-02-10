local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
print("HIIIIIII")

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

local Tab = Window:Tab({Title = "Main", Icon = "star"})

Tab:Section({Title = "Fish Settings"})

-- ตัวแปรระบบ
local fishData = {}
local selectedFish = nil
local isChasing = false
local currentTween = nil
local autoOxygenEnabled = false
local oxygenThread = nil
local isCatching = false
local fishHealthConnection = nil

-- ตั้งค่า
local chaseSettings = {
    speed = 30,
    distance = Vector3.new(0, 2, 0),
    catchDelay = 0.5,
    minHealth = 0.1 -- หยุดยิงเมื่อเลือดปลาน้อยกว่านี้
}

-- ฟังก์ชันดึงปลาจาก workspace
local function GetFishList()
    local fishList = {}
    local fishFolder = workspace:FindFirstChild("Game")
    
    if fishFolder then
        fishFolder = fishFolder:FindFirstChild("Fish")
        if fishFolder then
            fishFolder = fishFolder:FindFirstChild("client")
            if fishFolder then
                for _, fish in ipairs(fishFolder:GetChildren()) do
                    if fish:IsA("Model") then
                        local fishName = fish.Name
                        local fishId = fishName -- ใช้ชื่อปลาเป็น ID
                        
                        fishData[fishName] = {
                            model = fish,
                            fishId = fishId,
                            rodId = "9888203f88e8482e9b38218c199affba",
                            baitId = "d73b2f8a88744c1e8cf4d83dcb969e32",
                            harpoonId = "1ab2acaef12541558d69b19f6ad8d012",
                            health = 0,
                            isAlive = true
                        }
                        
                        table.insert(fishList, fishName)
                    end
                end
            end
        end
    end
    
    return fishList
end

-- ฟังก์ชันเช็คเลือดปลา
local function CheckFishHealth(fishModel)
    if not fishModel or not fishModel:IsDescendantOf(workspace) then
        return 0, false
    end
    
    local head = fishModel:FindFirstChild("Head")
    if not head then return 0, false end
    
    local stats = head:FindFirstChild("stats")
    if not stats then return 0, false end
    
    local health = stats:FindFirstChild("Health")
    if not health then return 0, false end
    
    local amount = health:FindFirstChild("Amount")
    if not amount or not amount:IsA("TextLabel") then return 0, false end
    
    local healthText = amount.Text
    local healthValue = tonumber(healthText:match("%d+%.?%d*")) or 0
    
    return healthValue, healthValue > chaseSettings.minHealth
end

-- ฟังก์ชันอัพเดทเลือดปลา
local function UpdateFishHealth()
    if fishHealthConnection then
        fishHealthConnection:Disconnect()
    end
    
    fishHealthConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if selectedFish and fishData[selectedFish] then
            local fishInfo = fishData[selectedFish]
            local healthValue, isAlive = CheckFishHealth(fishInfo.model)
            fishInfo.health = healthValue
            fishInfo.isAlive = isAlive
            
            -- ถ้าเลือดหมด ให้หยุดยิง
            if not isAlive then
                isCatching = false
            end
        end
    end)
end

-- ฟังก์ชัน Tween ติดตามปลา
local function ChaseFish(fishModel)
    if not fishModel or not fishModel:IsDescendantOf(workspace) then
        return false
    end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- หยุด Tween เก่า
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
    
    -- ฟังก์ชัน Tween ติดตามต่อเนื่อง
    local function updateChase()
        while isChasing and fishModel and fishModel:IsDescendantOf(workspace) do
            -- เช็คเลือดปลาก่อน
            local _, isAlive = CheckFishHealth(fishModel)
            if not isAlive then
                isChasing = false
                break
            end
            
            local fishPrimaryPart = fishModel.PrimaryPart or 
                                   fishModel:FindFirstChild("Head") or 
                                   fishModel:FindFirstChild("Torso") or 
                                   fishModel:FindFirstChild("UpperTorso")
            
            if not fishPrimaryPart then break end
            
            -- คำนวณตำแหน่งปลายทาง
            local targetPosition = fishPrimaryPart.Position + chaseSettings.distance
            
            -- คำนวณระยะทางและเวลา
            local distance = (humanoidRootPart.Position - targetPosition).Magnitude
            local duration = distance / chaseSettings.speed
            
            -- สร้าง Tween
            local tweenInfo = TweenInfo.new(
                math.max(0.1, duration),
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut,
                0,
                false,
                0
            )
            
            currentTween = game:GetService("TweenService"):Create(
                humanoidRootPart,
                tweenInfo,
                {CFrame = CFrame.new(targetPosition)}
            )
            
            currentTween:Play()
            
            -- รอจน Tween เสร็จหรือปลาหายไป
            local finished = false
            local connection
            connection = currentTween.Completed:Connect(function()
                finished = true
                if connection then
                    connection:Disconnect()
                end
            end)
            
            local startTime = tick()
            while not finished and (tick() - startTime) < 10 and isChasing and fishModel:IsDescendantOf(workspace) do
                local _, alive = CheckFishHealth(fishModel)
                if not alive then
                    isChasing = false
                    break
                end
                wait(0.1)
            end
            
            if connection then
                connection:Disconnect()
            end
        end
        
        isChasing = false
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end
    
    spawn(updateChase)
    return true
end

-- ฟังก์ชันยิงปลาจนเลือดหมด
local function ShootFishUntilDead(fishInfo)
    if not fishInfo or isCatching then return end
    
    isCatching = true
    
    while isCatching and fishInfo.model:IsDescendantOf(workspace) do
        -- เช็คเลือดปลา
        local healthValue, isAlive = CheckFishHealth(fishInfo.model)
        fishInfo.health = healthValue
        fishInfo.isAlive = isAlive
        
        -- ถ้าเลือดหมดให้หยุด
        if not isAlive or healthValue <= chaseSettings.minHealth then
            Window:Notify({
                Title = "ปลาตายแล้ว",
                Desc = "เลือดปลาเหลือ: " .. healthValue,
                Time = 2
            })
            break
        end
        
        -- ยิงปลา
        local args = {
            {
                ["1"] = "1",
                ["3"] = fishInfo.harpoonId,
                ["2"] = fishInfo.rodId,
                ["5"] = fishInfo.baitId,
                ["4"] = fishInfo.fishId
            }
        }
        
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args))
        end)
        
        if success then
            print("ยิงปลา - เลือดเหลือ: " .. healthValue)
        else
            print("ยิงปลาล้มเหลว: " .. tostring(result))
        end
        
        wait(chaseSettings.catchDelay)
    end
    
    isCatching = false
end

-- ฟังก์ชันเช็ค Oxygen
local function GetOxygenLevel()
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local main = playerGui:FindFirstChild("Main")
        if main then
            local oxygen = main:FindFirstChild("Oxygen")
            if oxygen then
                local canvasGroup = oxygen:FindFirstChild("CanvasGroup")
                if canvasGroup then
                    local oxygenText = canvasGroup:FindFirstChild("Oxygen")
                    if oxygenText and oxygenText:IsA("TextLabel") then
                        local text = oxygenText.Text
                        local number = tonumber(text:match("%d+"))
                        return number or 100
                    end
                end
            end
        end
    end
    return 100
end

-- ระบบ Auto Oxygen
local function StartOxygenMonitor()
    if oxygenThread then
        oxygenThread:Disconnect()
    end
    
    oxygenThread = game:GetService("RunService").Heartbeat:Connect(function()
        if not autoOxygenEnabled then
            if oxygenThread then
                oxygenThread:Disconnect()
                oxygenThread = nil
            end
            return
        end
        
        if GetOxygenLevel() < 10 then
            -- หยุด chase และ catch
            isChasing = false
            isCatching = false
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            
            -- Tween ไปผิวน้ำ
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local targetPosition = Vector3.new(-59, 4883, -49)
                    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
                    local duration = distance / chaseSettings.speed
                    
                    local tweenInfo = TweenInfo.new(
                        math.max(0.1, duration),
                        Enum.EasingStyle.Linear,
                        Enum.EasingDirection.InOut,
                        0,
                        false,
                        0
                    )
                    
                    local surfaceTween = game:GetService("TweenService"):Create(
                        humanoidRootPart,
                        tweenInfo,
                        {CFrame = CFrame.new(targetPosition)}
                    )
                    
                    surfaceTween:Play()
                    surfaceTween.Completed:Wait()
                    
                    -- รอจนออกซิเจนเต็ม
                    while autoOxygenEnabled and GetOxygenLevel() < 95 do
                        wait(1)
                    end
                end
            end
        end
    end)
end

-- UI Elements
local fishDropdown = Tab:Dropdown({
    Title = "เลือกปลา",
    List = GetFishList(),
    Value = "",
    Callback = function(choice)
        selectedFish = choice
        if choice and fishData[choice] then
            UpdateFishHealth()
            local healthValue, isAlive = CheckFishHealth(fishData[choice].model)
            Window:Notify({
                Title = "เลือกปลา: " .. choice,
                Desc = "เลือดปลา: " .. healthValue .. " HP",
                Time = 2
            })
        end
    end
})

-- ปุ่มรีเฟรช
Tab:Button({
    Title = "รีเฟรชลิสต์ปลา",
    Callback = function()
        fishDropdown:Refresh(GetFishList())
        Window:Notify({
            Title = "อัพเดทแล้ว",
            Desc = "อัพเดทลิสต์ปลาสำเร็จ!",
            Time = 2
        })
    end
})

-- Slider ความเร็ว
Tab:Slider({
    Title = "ความเร็ว Tween",
    Min = 10,
    Max = 100,
    Value = 30,
    Callback = function(value)
        chaseSettings.speed = value
    end
})

-- Slider ระยะห่าง X
Tab:Slider({
    Title = "ระยะห่าง X",
    Min = -10,
    Max = 10,
    Value = 0,
    Callback = function(value)
        chaseSettings.distance = Vector3.new(value, chaseSettings.distance.Y, chaseSettings.distance.Z)
    end
})

-- Slider ระยะห่าง Y
Tab:Slider({
    Title = "ระยะห่าง Y",
    Min = -10,
    Max = 10,
    Value = 2,
    Callback = function(value)
        chaseSettings.distance = Vector3.new(chaseSettings.distance.X, value, chaseSettings.distance.Z)
    end
})

-- Slider ระยะห่าง Z
Tab:Slider({
    Title = "ระยะห่าง Z",
    Min = -10,
    Max = 10,
    Value = 0,
    Callback = function(value)
        chaseSettings.distance = Vector3.new(chaseSettings.distance.X, chaseSettings.distance.Y, value)
    end
})

-- Slider ดีเลย์การยิง
Tab:Slider({
    Title = "ดีเลย์การยิง",
    Desc = "วินาทีระหว่างการยิงแต่ละครั้ง",
    Min = 0.1,
    Max = 2,
    Value = 0.5,
    Precise = 1,
    Callback = function(value)
        chaseSettings.catchDelay = value
    end
})

-- ปุ่มเช็คเลือดปลา
Tab:Button({
    Title = "เช็คเลือดปลา",
    Callback = function()
        if not selectedFish or not fishData[selectedFish] then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local healthValue, isAlive = CheckFishHealth(fishData[selectedFish].model)
        Window:Notify({
            Title = "เลือดปลา: " .. selectedFish,
            Desc = "HP: " .. healthValue .. " | " .. (isAlive and "ยังมีชีวิต" or "ตายแล้ว"),
            Time = 3
        })
    end
})

-- ปุ่มเริ่มติดตาม
Tab:Button({
    Title = "เริ่มติดตามปลา",
    Callback = function()
        if not selectedFish or not fishData[selectedFish] then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local fishModel = fishData[selectedFish].model
        
        -- เช็คเลือดปลาก่อน
        local healthValue, isAlive = CheckFishHealth(fishModel)
        if not isAlive then
            Window:Notify({
                Title = "ปลาตายแล้ว",
                Desc = "ไม่สามารถติดตามปลาที่ตายแล้วได้",
                Time = 2
            })
            return
        end
        
        if isChasing then
            isChasing = false
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            Window:Notify({
                Title = "หยุดติดตาม",
                Desc = "หยุดติดตามปลาแล้ว",
                Time = 2
            })
        else
            isChasing = true
            local success = ChaseFish(fishModel)
            
            if success then
                Window:Notify({
                    Title = "เริ่มติดตาม",
                    Desc = "กำลังติดตามปลา: " .. selectedFish .. " (HP: " .. healthValue .. ")",
                    Time = 2
                })
            else
                isChasing = false
                Window:Notify({
                    Title = "ผิดพลาด",
                    Desc = "ไม่พบปลาหรือปลาหายไป",
                    Time = 2
                })
            end
        end
    end
})

-- ปุ่มยิงปลาจนตาย
Tab:Button({
    Title = "ยิงจนเลือดหมด",
    Callback = function()
        if not selectedFish or not fishData[selectedFish] then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local fishInfo = fishData[selectedFish]
        local healthValue, isAlive = CheckFishHealth(fishInfo.model)
        
        if not isAlive then
            Window:Notify({
                Title = "ปลาตายแล้ว",
                Desc = "เลือดปลาเหลือ: " .. healthValue,
                Time = 2
            })
            return
        end
        
        Window:Notify({
            Title = "เริ่มยิงปลา",
            Desc = "กำลังยิงปลา " .. selectedFish .. " (HP: " .. healthValue .. ")",
            Time = 2
        })
        
        spawn(function()
            ShootFishUntilDead(fishInfo)
        end)
    end
})

-- ปุ่มติดตามและยิงจนตาย
Tab:Button({
    Title = "ติดตามและยิงจนตาย",
    Callback = function()
        if not selectedFish or not fishData[selectedFish] then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local fishModel = fishData[selectedFish].model
        local fishInfo = fishData[selectedFish]
        
        -- เช็คเลือดปลาก่อน
        local healthValue, isAlive = CheckFishHealth(fishModel)
        if not isAlive then
            Window:Notify({
                Title = "ปลาตายแล้ว",
                Desc = "ไม่สามารถติดตามปลาที่ตายแล้วได้",
                Time = 2
            })
            return
        end
        
        -- เริ่มติดตาม
        isChasing = true
        local chaseSuccess = ChaseFish(fishModel)
        
        if chaseSuccess then
            Window:Notify({
                Title = "เริ่มติดตามและยิง",
                Desc = "กำลังติดตามและยิงปลา " .. selectedFish .. " (HP: " .. healthValue .. ")",
                Time = 2
            })
            
            -- รอให้เข้าใกล้ปลาก่อนยิง
            wait(1)
            
            -- ยิงปลาจนตาย
            spawn(function()
                ShootFishUntilDead(fishInfo)
                
                -- ยิงเสร็จแล้วหยุดติดตาม
                isChasing = false
                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end
                
                Window:Notify({
                    Title = "ยิงเสร็จสิ้น",
                    Desc = "ยิงปลา " .. selectedFish .. " จนเลือดหมด",
                    Time = 2
                })
            end)
        end
    end
})

-- Toggle Auto Oxygen
Tab:Toggle({
    Title = "Auto Oxygen",
    Desc = "กลับผิวน้ำเมื่อออกซิเจนต่ำ",
    Value = false,
    Callback = function(v)
        autoOxygenEnabled = v
        if v then
            StartOxygenMonitor()
            Window:Notify({
                Title = "เปิด Auto Oxygen",
                Desc = "จะกลับผิวน้ำเมื่อออกซิเจน < 10%",
                Time = 2
            })
        else
            if oxygenThread then
                oxygenThread:Disconnect()
                oxygenThread = nil
            end
            Window:Notify({
                Title = "ปิด Auto Oxygen",
                Desc = "ระบบ Auto Oxygen ถูกปิดแล้ว",
                Time = 2
            })
        end
    end
})

-- Toggle Auto Farm
local autoFarmEnabled = false
Tab:Toggle({
    Title = "Auto Farm (ยิงจนตาย)",
    Desc = "ออโต้ติดตามและยิงปลาทั้งหมดจนเลือดหมด",
    Value = false,
    Callback = function(v)
        autoFarmEnabled = v
        
        if v then
            -- เปิด Auto Oxygen
            autoOxygenEnabled = true
            StartOxygenMonitor()
            
            -- เริ่ม Auto Farm
            spawn(function()
                while autoFarmEnabled do
                    local fishList = GetFishList()
                    
                    for _, fishName in ipairs(fishList) do
                        if not autoFarmEnabled then break end
                        
                        -- เช็คออกซิเจน
                        if GetOxygenLevel() < 20 then
                            wait(3)
                        end
                        
                        selectedFish = fishName
                        local fishInfo = fishData[fishName]
                        local fishModel = fishInfo and fishInfo.model
                        
                        if fishInfo and fishModel then
                            -- เช็คเลือดปลาก่อน
                            local healthValue, isAlive = CheckFishHealth(fishModel)
                            if not isAlive then
                                print("ข้ามปลา " .. fishName .. " เพราะตายแล้ว")
                                goto continue
                            end
                            
                            print("เริ่มยิงปลา: " .. fishName .. " (HP: " .. healthValue .. ")")
                            
                            -- เริ่มติดตาม
                            isChasing = true
                            ChaseFish(fishModel)
                            
                            -- รอให้เข้าใกล้ปลา
                            wait(1.5)
                            
                            -- ยิงปลาจนตาย
                            ShootFishUntilDead(fishInfo)
                            
                            -- หยุดติดตาม
                            isChasing = false
                            if currentTween then
                                currentTween:Cancel()
                                currentTween = nil
                            end
                            
                            wait(1) -- รอระหว่างปลา
                        end
                        
                        ::continue::
                    end
                    
                    wait(2) -- รอก่อนลูปถัดไป
                end
            end)
            
            Window:Notify({
                Title = "เริ่ม Auto Farm",
                Desc = "กำลังยิงปลาทั้งหมดจนเลือดหมด",
                Time = 2
            })
        else
            -- หยุด Auto Farm
            isChasing = false
            isCatching = false
            autoOxygenEnabled = false
            
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            
            if oxygenThread then
                oxygenThread:Disconnect()
                oxygenThread = nil
            end
            
            if fishHealthConnection then
                fishHealthConnection:Disconnect()
                fishHealthConnection = nil
            end
            
            Window:Notify({
                Title = "หยุด Auto Farm",
                Desc = "หยุดการยิงปลาอัตโนมัติ",
                Time = 2
            })
        end
    end
})

-- ปุ่มหยุดทั้งหมด
Tab:Button({
    Title = "หยุดทั้งหมด",
    Callback = function()
        isChasing = false
        isCatching = false
        
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
        
        if fishHealthConnection then
            fishHealthConnection:Disconnect()
            fishHealthConnection = nil
        end
        
        Window:Notify({
            Title = "หยุดทั้งหมด",
            Desc = "หยุดการติดตามและยิงปลาแล้ว",
            Time = 2
        })
    end
})

Window:Notify({
    Title = "ระบบพร้อมใช้งาน",
    Desc = "Smart Fishing System Loaded",
    Time = 2
})

-- เริ่มอัพเดทเลือดปลา
spawn(function()
    while true do
        if selectedFish and fishData[selectedFish] then
            local healthValue, isAlive = CheckFishHealth(fishData[selectedFish].model)
            fishData[selectedFish].health = healthValue
            fishData[selectedFish].isAlive = isAlive
        end
        wait(1)
    end
end)
