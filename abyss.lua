-- ลองใช้ UI Library อื่นถ้าโหลดไม่ได้
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
end)

if not success then
    -- ถ้าโหลดไม่ได้ ให้ใช้ UI Library แบบง่ายๆ
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
end

-- หรือใช้ Library ที่เสถียรกว่า
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "x2zu [ Stellar ]",
    LoadingTitle = "x2zu on top",
    LoadingSubtitle = "by x2zu",
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458) -- Star icon

Tab:CreateSection("Fish Settings")

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
                task.wait(0.1)
            end
            
            if connection then
                connection:Disconnect()
            end
            
            task.wait(0.1)
        end
        
        isChasing = false
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end
    
    task.spawn(updateChase)
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
            Rayfield:Notify({
                Title = "ปลาตายแล้ว",
                Content = "เลือดปลาเหลือ: " .. healthValue,
                Duration = 2,
                Image = 4483362458
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
        
        task.wait(chaseSettings.catchDelay)
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
                        task.wait(1)
                    end
                end
            end
        end
    end)
end

-- สร้าง Dropdown สำหรับเลือกปลา
local fishDropdown = Tab:CreateDropdown({
    Name = "เลือกปลา",
    Options = GetFishList(),
    CurrentOption = "",
    Flag = "FishSelect",
    Callback = function(choice)
        selectedFish = choice
        if choice then
            local fishModel = GetFishModel(choice)
            if fishModel then
                local healthValue, isAlive = CheckFishHealth(fishModel)
                Rayfield:Notify({
                    Title = "เลือกปลา: " .. choice,
                    Content = "เลือดปลา: " .. healthValue .. " HP",
                    Duration = 2,
                    Image = 4483362458
                })
            end
        end
    end,
})

Tab:CreateButton({
    Name = "รีเฟรชลิสต์ปลา",
    Callback = function()
        local newList = GetFishList()
        if #newList > 0 then
            fishDropdown:SetOptions(newList)
            Rayfield:Notify({
                Title = "อัพเดทแล้ว",
                Content = "พบปลา " .. #newList .. " ตัว",
                Duration = 2,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "ไม่พบปลา",
                Content = "ตรวจสอบว่าเกมโหลดเสร็จแล้วหรือไม่",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

Tab:CreateSlider({
    Name = "ความเร็ว Tween",
    Range = {10, 100},
    Increment = 1,
    Suffix = "หน่วย/วินาที",
    CurrentValue = 30,
    Flag = "SpeedSetting",
    Callback = function(value)
        chaseSettings.speed = value
    end,
})

Tab:CreateSlider({
    Name = "ระยะห่าง X",
    Range = {-10, 10},
    Increment = 1,
    Suffix = "หน่วย",
    CurrentValue = 0,
    Flag = "DistanceX",
    Callback = function(value)
        chaseSettings.distance = Vector3.new(value, chaseSettings.distance.Y, chaseSettings.distance.Z)
    end,
})

Tab:CreateSlider({
    Name = "ระยะห่าง Y",
    Range = {-10, 10},
    Increment = 1,
    Suffix = "หน่วย",
    CurrentValue = 2,
    Flag = "DistanceY",
    Callback = function(value)
        chaseSettings.distance = Vector3.new(chaseSettings.distance.X, value, chaseSettings.distance.Z)
    end,
})

Tab:CreateSlider({
    Name = "ระยะห่าง Z",
    Range = {-10, 10},
    Increment = 1,
    Suffix = "หน่วย",
    CurrentValue = 0,
    Flag = "DistanceZ",
    Callback = function(value)
        chaseSettings.distance = Vector3.new(chaseSettings.distance.X, chaseSettings.distance.Y, value)
    end,
})

Tab:CreateSlider({
    Name = "ดีเลย์การยิง",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "วินาที",
    CurrentValue = 0.5,
    Flag = "CatchDelay",
    Callback = function(value)
        chaseSettings.catchDelay = value
    end,
})

Tab:CreateButton({
    Name = "เช็คเลือดปลา",
    Callback = function()
        if not selectedFish then
            Rayfield:Notify({
                Title = "ผิดพลาด",
                Content = "กรุณาเลือกปลาก่อน!",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local fishModel = GetFishModel(selectedFish)
        if not fishModel then
            Rayfield:Notify({
                Title = "ไม่พบปลา",
                Content = "ปลา " .. selectedFish .. " หายไปแล้ว",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local healthValue, isAlive = CheckFishHealth(fishModel)
        Rayfield:Notify({
            Title = "เลือดปลา: " .. selectedFish,
            Content = "HP: " .. healthValue .. " | " .. (isAlive and "ยังมีชีวิต" or "ตายแล้ว"),
            Duration = 3,
            Image = 4483362458
        })
    end,
})

Tab:CreateButton({
    Name = "เริ่มติดตามปลา",
    Callback = function()
        if not selectedFish then
            Rayfield:Notify({
                Title = "ผิดพลาด",
                Content = "กรุณาเลือกปลาก่อน!",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local fishModel = GetFishModel(selectedFish)
        if not fishModel then
            Rayfield:Notify({
                Title = "ไม่พบปลา",
                Content = "ปลา " .. selectedFish .. " หายไปแล้ว",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local healthValue, isAlive = CheckFishHealth(fishModel)
        if not isAlive then
            Rayfield:Notify({
                Title = "ปลาตายแล้ว",
                Content = "ไม่สามารถติดตามปลาที่ตายแล้วได้",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        if isChasing then
            isChasing = false
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            Rayfield:Notify({
                Title = "หยุดติดตาม",
                Content = "หยุดติดตามปลาแล้ว",
                Duration = 2,
                Image = 4483362458
            })
        else
            isChasing = true
            local success = ChaseFish(fishModel)
            
            if success then
                Rayfield:Notify({
                    Title = "เริ่มติดตาม",
                    Content = "กำลังติดตามปลา: " .. selectedFish .. " (HP: " .. healthValue .. ")",
                    Duration = 2,
                    Image = 4483362458
                })
            else
                isChasing = false
                Rayfield:Notify({
                    Title = "ผิดพลาด",
                    Content = "ไม่สามารถติดตามปลาได้",
                    Duration = 2,
                    Image = 4483362458
                })
            end
        end
    end,
})

Tab:CreateButton({
    Name = "ยิงจนเลือดหมด",
    Callback = function()
        if not selectedFish then
            Rayfield:Notify({
                Title = "ผิดพลาด",
                Content = "กรุณาเลือกปลาก่อน!",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local fishModel = GetFishModel(selectedFish)
        if not fishModel then
            Rayfield:Notify({
                Title = "ไม่พบปลา",
                Content = "ปลา " .. selectedFish .. " หายไปแล้ว",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local healthValue, isAlive = CheckFishHealth(fishModel)
        
        if not isAlive then
            Rayfield:Notify({
                Title = "ปลาตายแล้ว",
                Content = "เลือดปลาเหลือ: " .. healthValue,
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        Rayfield:Notify({
            Title = "เริ่มยิงปลา",
            Content = "กำลังยิงปลา " .. selectedFish .. " (HP: " .. healthValue .. ")",
            Duration = 2,
            Image = 4483362458
        })
        
        task.spawn(function()
            ShootFishUntilDead(selectedFish)
        end)
    end,
})

Tab:CreateButton({
    Name = "ติดตามและยิงจนตาย",
    Callback = function()
        if not selectedFish then
            Rayfield:Notify({
                Title = "ผิดพลาด",
                Content = "กรุณาเลือกปลาก่อน!",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local fishModel = GetFishModel(selectedFish)
        if not fishModel then
            Rayfield:Notify({
                Title = "ไม่พบปลา",
                Content = "ปลา " .. selectedFish .. " หายไปแล้ว",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        local healthValue, isAlive = CheckFishHealth(fishModel)
        if not isAlive then
            Rayfield:Notify({
                Title = "ปลาตายแล้ว",
                Content = "ไม่สามารถติดตามปลาที่ตายแล้วได้",
                Duration = 2,
                Image = 4483362458
            })
            return
        end
        
        isChasing = true
        local chaseSuccess = ChaseFish(fishModel)
        
        if chaseSuccess then
            Rayfield:Notify({
                Title = "เริ่มติดตามและยิง",
                Content = "กำลังติดตามและยิงปลา " .. selectedFish .. " (HP: " .. healthValue .. ")",
                Duration = 2,
                Image = 4483362458
            })
            
            task.wait(1.5)
            
            task.spawn(function()
                ShootFishUntilDead(selectedFish)
                
                isChasing = false
                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end
                
                Rayfield:Notify({
                    Title = "ยิงเสร็จสิ้น",
                    Content = "ยิงปลา " .. selectedFish .. " จนเลือดหมด",
                    Duration = 2,
                    Image = 4483362458
                })
            end)
        end
    end,
})

Tab:CreateToggle({
    Name = "Auto Oxygen",
    CurrentValue = false,
    Flag = "AutoOxygen",
    Callback = function(value)
        autoOxygenEnabled = value
        if value then
            StartOxygenMonitor()
            Rayfield:Notify({
                Title = "เปิด Auto Oxygen",
                Content = "จะกลับผิวน้ำเมื่อออกซิเจน < 10%",
                Duration = 2,
                Image = 4483362458
            })
        else
            if oxygenThread then
                oxygenThread:Disconnect()
                oxygenThread = nil
            end
            Rayfield:Notify({
                Title = "ปิด Auto Oxygen",
                Content = "ระบบ Auto Oxygen ถูกปิดแล้ว",
                Duration = 2,
                Image = 4483362458
            })
        end
    end,
})

local autoFarmEnabled = false
Tab:CreateToggle({
    Name = "Auto Farm (ยิงจนตาย)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(value)
        autoFarmEnabled = value
        
        if value then
            autoOxygenEnabled = true
            StartOxygenMonitor()
            
            task.spawn(function()
                while autoFarmEnabled do
                    local fishList = GetFishList()
                    
                    if #fishList == 0 then
                        Rayfield:Notify({
                            Title = "ไม่พบปลา",
                            Content = "กำลังรอให้ปลาโหลด...",
                            Duration = 2,
                            Image = 4483362458
                        })
                        task.wait(5)
                        goto continue
                    end
                    
                    for _, fishName in ipairs(fishList) do
                        if not autoFarmEnabled then break end
                        
                        if GetOxygenLevel() < 20 then
                            task.wait(3)
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
                            
                            task.wait(1.5)
                            
                            ShootFishUntilDead(fishName)
                            
                            isChasing = false
                            if currentTween then
                                currentTween:Cancel()
                                currentTween = nil
                            end
                            
                            task.wait(1)
                        end
                        
                        ::next_fish::
                    end
                    
                    ::continue::
                    task.wait(2)
                end
            end)
            
            Rayfield:Notify({
                Title = "เริ่ม Auto Farm",
                Content = "กำลังยิงปลาทั้งหมดจนเลือดหมด",
                Duration = 2,
                Image = 4483362458
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
            
            Rayfield:Notify({
                Title = "หยุด Auto Farm",
                Content = "หยุดการยิงปลาอัตโนมัติ",
                Duration = 2,
                Image = 4483362458
            })
        end
    end,
})

Tab:CreateButton({
    Name = "หยุดทั้งหมด",
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
        
        Rayfield:Notify({
            Title = "หยุดทั้งหมด",
            Content = "หยุดการติดตามและยิงปลาแล้ว",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

Rayfield:Notify({
    Title = "ระบบพร้อมใช้งาน",
    Content = "Smart Fishing System Loaded",
    Duration = 2,
    Image = 4483362458
})

print("=== Smart Fishing System Started ===")
print("Made by x2zu")
