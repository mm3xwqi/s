-- โหลด UI Library ด้วยการป้องกัน error
local Library
local success, errorMsg = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
end)

if not success then
    -- ถ้าโหลดไม่ได้ ให้พยายามโหลดจาก mirror อื่น
    warn("ไม่สามารถโหลด UI จากลิงค์หลักได้: " .. tostring(errorMsg))
    
    local success2, errorMsg2 = pcall(function()
        Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
    end)
    
    if not success2 then
        error("ไม่สามารถโหลด UI Library ได้: " .. tostring(errorMsg2))
    end
end

-- ตรวจสอบว่า Library เป็น function หรือไม่
if type(Library) ~= "function" then
    error("UI Library โหลดมาไม่ได้เป็น function")
end

-- เรียกใช้ Library เพื่อสร้าง Window
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

-- หลังจากนี้จะเป็นโค้ดเดิมทั้งหมด...

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

-- ตั้งค่า
local chaseSettings = {
    speed = 30,
    distance = Vector3.new(0, 2, 0),
    catchDelay = 0.5,
    minHealth = 0.1
}

-- ฟังก์ชันดึงปลาจาก workspace
local function GetFishList()
    local fishList = {}
    
    local success, result = pcall(function()
        local fishFolder = workspace:WaitForChild("Game", 5)
        if fishFolder then
            fishFolder = fishFolder:WaitForChild("Fish", 5)
            if fishFolder then
                fishFolder = fishFolder:WaitForChild("client", 5)
                if fishFolder then
                    for _, fish in ipairs(fishFolder:GetChildren()) do
                        if fish:IsA("Model") then
                            table.insert(fishList, fish.Name)
                        end
                    end
                end
            end
        end
    end)
    
    if not success then
        print("Error loading fish list:", result)
    end
    
    return fishList
end

-- ฟังก์ชันหา Fish Model จากชื่อ
local function GetFishModel(fishName)
    local success, result = pcall(function()
        local fishFolder = workspace:WaitForChild("Game", 5)
        if fishFolder then
            fishFolder = fishFolder:WaitForChild("Fish", 5)
            if fishFolder then
                fishFolder = fishFolder:WaitForChild("client", 5)
                if fishFolder then
                    return fishFolder:FindFirstChild(fishName)
                end
            end
        end
        return nil
    end)
    
    if not success then
        print("Error getting fish model:", result)
        return nil
    end
    
    return result
end

-- ฟังก์ชันเช็คเลือดปลา
local function CheckFishHealth(fishModel)
    if not fishModel or not fishModel:IsDescendantOf(workspace) then
        return 0, false
    end
    
    local success, healthValue = pcall(function()
        local head = fishModel:FindFirstChild("Head")
        if not head then return 0 end
        
        local stats = head:FindFirstChild("stats")
        if not stats then return 0 end
        
        local health = stats:FindFirstChild("Health")
        if not health then return 0 end
        
        local amount = health:FindFirstChild("Amount")
        if not amount or not amount:IsA("TextLabel") then return 0 end
        
        local healthText = amount.Text
        local num = healthText:match("%d+%.?%d*")
        if num then
            return tonumber(num)
        end
        return 0
    end)
    
    if not success then
        print("Error checking fish health:", healthValue)
        return 100, true
    end
    
    local isAlive = healthValue > chaseSettings.minHealth
    return healthValue, isAlive
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
    
    local function updateChase()
        while isChasing and fishModel and fishModel:IsDescendantOf(workspace) do
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
            
            local targetPosition = fishPrimaryPart.Position + chaseSettings.distance
            local distance = (humanoidRootPart.Position - targetPosition).Magnitude
            local duration = distance / chaseSettings.speed
            
            local tweenInfo = TweenInfo.new(
                math.max(0.1, math.min(duration, 5)),
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
            
            local completed = false
            local connection
            connection = currentTween.Completed:Connect(function()
                completed = true
                if connection then
                    connection:Disconnect()
                end
            end)
            
            local startTime = tick()
            while not completed and (tick() - startTime) < 6 and isChasing and fishModel:IsDescendantOf(workspace) do
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
            
            wait(0.1)
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
local function ShootFishUntilDead(fishName)
    if not fishName or isCatching then return end
    
    isCatching = true
    
    while isCatching do
        local fishModel = GetFishModel(fishName)
        if not fishModel or not fishModel:IsDescendantOf(workspace) then
            isCatching = false
            break
        end
        
        local healthValue, isAlive = CheckFishHealth(fishModel)
        
        if not isAlive or healthValue <= chaseSettings.minHealth then
            Window:Notify({
                Title = "ปลาตายแล้ว",
                Desc = "เลือดปลาเหลือ: " .. healthValue,
                Time = 2
            })
            break
        end
        
        local args = {
            {
                ["1"] = "1",
                ["3"] = "1ab2acaef12541558d69b19f6ad8d012",
                ["2"] = "9888203f88e8482e9b38218c199affba",
                ["5"] = "d73b2f8a88744c1e8cf4d83dcb969e32",
                ["4"] = fishName
            }
        }
        
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args))
        end)
        
        if success then
            print("ยิงปลา - เลือดเหลือ: " .. healthValue)
        else
            print("ยิงปลาล้มเหลว: " .. tostring(result))
            break
        end
        
        wait(chaseSettings.catchDelay)
    end
    
    isCatching = false
end

-- ฟังก์ชันเช็ค Oxygen
local function GetOxygenLevel()
    local success, oxygenLevel = pcall(function()
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui", 5)
        if not playerGui then return 100 end
        
        local main = playerGui:FindFirstChild("Main")
        if not main then return 100 end
        
        local oxygen = main:FindFirstChild("Oxygen")
        if not oxygen then return 100 end
        
        local canvasGroup = oxygen:FindFirstChild("CanvasGroup")
        if not canvasGroup then return 100 end
        
        local oxygenText = canvasGroup:FindFirstChild("Oxygen")
        if not oxygenText or not oxygenText:IsA("TextLabel") then return 100 end
        
        local text = oxygenText.Text
        local number = tonumber(text:match("%d+"))
        return number or 100
    end)
    
    if not success then
        print("Error getting oxygen level:", oxygenLevel)
        return 100
    end
    
    return oxygenLevel
end

-- ระบบ Auto Oxygen
local function StartOxygenMonitor()
    if oxygenThread then
        oxygenThread:Disconnect()
        oxygenThread = nil
    end
    
    oxygenThread = game:GetService("RunService").Heartbeat:Connect(function()
        if not autoOxygenEnabled then
            if oxygenThread then
                oxygenThread:Disconnect()
                oxygenThread = nil
            end
            return
        end
        
        local oxygenLevel = GetOxygenLevel()
        
        if oxygenLevel < 10 then
            isChasing = false
            isCatching = false
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local targetPosition = Vector3.new(-59, 4883, -49)
                    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
                    local duration = distance / chaseSettings.speed
                    
                    local tweenInfo = TweenInfo.new(
                        math.max(0.1, math.min(duration, 10)),
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
                    
                    local startTime = tick()
                    while autoOxygenEnabled and GetOxygenLevel() < 95 and (tick() - startTime) < 30 do
                        wait(1)
                    end
                end
            end
        end
    end)
end

-- สร้าง UI Elements
local fishDropdown = Tab:Dropdown({
    Title = "เลือกปลา",
    List = GetFishList(),
    Value = "",
    Callback = function(choice)
        selectedFish = choice
        if choice then
            local fishModel = GetFishModel(choice)
            if fishModel then
                local healthValue, isAlive = CheckFishHealth(fishModel)
                Window:Notify({
                    Title = "เลือกปลา: " .. choice,
                    Desc = "เลือดปลา: " .. healthValue .. " HP",
                    Time = 2
                })
            end
        end
    end
})

Tab:Button({
    Title = "รีเฟรชลิสต์ปลา",
    Callback = function()
        local newList = GetFishList()
        if #newList > 0 then
            fishDropdown:Refresh(newList)
            Window:Notify({
                Title = "อัพเดทแล้ว",
                Desc = "พบปลา " .. #newList .. " ตัว",
                Time = 2
            })
        else
            Window:Notify({
                Title = "ไม่พบปลา",
                Desc = "ตรวจสอบว่าเกมโหลดเสร็จแล้วหรือไม่",
                Time = 3
            })
        end
    end
})

Tab:Slider({
    Title = "ความเร็ว Tween",
    Min = 10,
    Max = 100,
    Value = 30,
    Callback = function(value)
        chaseSettings.speed = value
    end
})

Tab:Slider({
    Title = "ระยะห่าง X",
    Min = -10,
    Max = 10,
    Value = 0,
    Callback = function(value)
        chaseSettings.distance = Vector3.new(value, chaseSettings.distance.Y, chaseSettings.distance.Z)
    end
})

Tab:Slider({
    Title = "ระยะห่าง Y",
    Min = -10,
    Max = 10,
    Value = 2,
    Callback = function(value)
        chaseSettings.distance = Vector3.new(chaseSettings.distance.X, value, chaseSettings.distance.Z)
    end
})

Tab:Slider({
    Title = "ระยะห่าง Z",
    Min = -10,
    Max = 10,
    Value = 0,
    Callback = function(value)
        chaseSettings.distance = Vector3.new(chaseSettings.distance.X, chaseSettings.distance.Y, value)
    end
})

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

Tab:Button({
    Title = "เช็คเลือดปลา",
    Callback = function()
        if not selectedFish then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local fishModel = GetFishModel(selectedFish)
        if not fishModel then
            Window:Notify({
                Title = "ไม่พบปลา",
                Desc = "ปลา " .. selectedFish .. " หายไปแล้ว",
                Time = 2
            })
            return
        end
        
        local healthValue, isAlive = CheckFishHealth(fishModel)
        Window:Notify({
            Title = "เลือดปลา: " .. selectedFish,
            Desc = "HP: " .. healthValue .. " | " .. (isAlive and "ยังมีชีวิต" or "ตายแล้ว"),
            Time = 3
        })
    end
})

Tab:Button({
    Title = "เริ่มติดตามปลา",
    Callback = function()
        if not selectedFish then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local fishModel = GetFishModel(selectedFish)
        if not fishModel then
            Window:Notify({
                Title = "ไม่พบปลา",
                Desc = "ปลา " .. selectedFish .. " หายไปแล้ว",
                Time = 2
            })
            return
        end
        
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
                    Desc = "ไม่สามารถติดตามปลาได้",
                    Time = 2
                })
            end
        end
    end
})

Tab:Button({
    Title = "ยิงจนเลือดหมด",
    Callback = function()
        if not selectedFish then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local fishModel = GetFishModel(selectedFish)
        if not fishModel then
            Window:Notify({
                Title = "ไม่พบปลา",
                Desc = "ปลา " .. selectedFish .. " หายไปแล้ว",
                Time = 2
            })
            return
        end
        
        local healthValue, isAlive = CheckFishHealth(fishModel)
        
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
            ShootFishUntilDead(selectedFish)
        end)
    end
})

Tab:Button({
    Title = "ติดตามและยิงจนตาย",
    Callback = function()
        if not selectedFish then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local fishModel = GetFishModel(selectedFish)
        if not fishModel then
            Window:Notify({
                Title = "ไม่พบปลา",
                Desc = "ปลา " .. selectedFish .. " หายไปแล้ว",
                Time = 2
            })
            return
        end
        
        local healthValue, isAlive = CheckFishHealth(fishModel)
        if not isAlive then
            Window:Notify({
                Title = "ปลาตายแล้ว",
                Desc = "ไม่สามารถติดตามปลาที่ตายแล้วได้",
                Time = 2
            })
            return
        end
        
        isChasing = true
        local chaseSuccess = ChaseFish(fishModel)
        
        if chaseSuccess then
            Window:Notify({
                Title = "เริ่มติดตามและยิง",
                Desc = "กำลังติดตามและยิงปลา " .. selectedFish .. " (HP: " .. healthValue .. ")",
                Time = 2
            })
            
            wait(1.5)
            
            spawn(function()
                ShootFishUntilDead(selectedFish)
                
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

local autoFarmEnabled = false
Tab:Toggle({
    Title = "Auto Farm (ยิงจนตาย)",
    Desc = "ออโต้ติดตามและยิงปลาทั้งหมดจนเลือดหมด",
    Value = false,
    Callback = function(v)
        autoFarmEnabled = v
        
        if v then
            autoOxygenEnabled = true
            StartOxygenMonitor()
            
            spawn(function()
                while autoFarmEnabled do
                    local fishList = GetFishList()
                    
                    if #fishList == 0 then
                        Window:Notify({
                            Title = "ไม่พบปลา",
                            Desc = "กำลังรอให้ปลาโหลด...",
                            Time = 2
                        })
                        wait(5)
                        goto continue
                    end
                    
                    for _, fishName in ipairs(fishList) do
                        if not autoFarmEnabled then break end
                        
                        if GetOxygenLevel() < 20 then
                            wait(3)
                        end
                        
                        selectedFish = fishName
                        local fishModel = GetFishModel(fishName)
                        
                        if fishModel then
                            local healthValue, isAlive = CheckFishHealth(fishModel)
                            if not isAlive then
                                print("ข้ามปลา " .. fishName .. " เพราะตายแล้ว")
                                goto next_fish
                            end
                            
                            print("เริ่มยิงปลา: " .. fishName .. " (HP: " .. healthValue .. ")")
                            
                            isChasing = true
                            ChaseFish(fishModel)
                            
                            wait(1.5)
                            
                            ShootFishUntilDead(fishName)
                            
                            isChasing = false
                            if currentTween then
                                currentTween:Cancel()
                                currentTween = nil
                            end
                            
                            wait(1)
                        end
                        
                        ::next_fish::
                    end
                    
                    ::continue::
                    wait(2)
                end
            end)
            
            Window:Notify({
                Title = "เริ่ม Auto Farm",
                Desc = "กำลังยิงปลาทั้งหมดจนเลือดหมด",
                Time = 2
            })
        else
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
            
            Window:Notify({
                Title = "หยุด Auto Farm",
                Desc = "หยุดการยิงปลาอัตโนมัติ",
                Time = 2
            })
        end
    end
})

Tab:Button({
    Title = "หยุดทั้งหมด",
    Callback = function()
        isChasing = false
        isCatching = false
        autoFarmEnabled = false
        
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
        
        if oxygenThread then
            oxygenThread:Disconnect()
            oxygenThread = nil
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

print("=== Smart Fishing System Started ===")
print("Made by x2zu")
print("UI Library loaded successfully")
