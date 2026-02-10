local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
print("HI")

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

-- ตั้งค่า
local chaseSettings = {
    speed = 30, -- หน่วยต่อวินาที
    distance = Vector3.new(0, 2, 0), -- ระยะห่าง XYZ
    autoCatch = false
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
                        local fishId = fish:GetAttribute("FishId") or 
                                      fish:GetAttribute("ID") or 
                                      fishName
                        
                        fishData[fishName] = {
                            model = fish,
                            fishId = fishId
                        }
                        
                        table.insert(fishList, fishName)
                    end
                end
            end
        end
    end
    
    return fishList
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
            local fishPrimaryPart = fishModel.PrimaryPart or 
                                   fishModel:FindFirstChild("Head") or 
                                   fishModel:FindFirstChild("Torso") or 
                                   fishModel:FindFirstChild("UpperTorso")
            
            if not fishPrimaryPart then break end
            
            -- คำนวณตำแหน่งปลายทาง (รวมระยะห่าง)
            local targetPosition = fishPrimaryPart.Position + chaseSettings.distance
            
            -- คำนวณระยะทางและเวลา
            local distance = (humanoidRootPart.Position - targetPosition).Magnitude
            local duration = distance / chaseSettings.speed
            
            -- สร้าง Tween
            local tweenInfo = TweenInfo.new(
                math.max(0.1, duration), -- ไม่น้อยกว่า 0.1 วินาที
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
                wait(0.1)
            end
            
            if connection then
                connection:Disconnect()
            end
        end
        
        -- ถ้าออกจาก loop ให้หยุด chase
        isChasing = false
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end
    
    -- เริ่มติดตาม
    spawn(updateChase)
    return true
end

-- ฟังก์ชันจับปลา
local function CatchFish(fishId)
    local args = { fishId }
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args))
    end)
    return success, result
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
            -- หยุด chase ปัจจุบัน
            isChasing = false
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
    Desc = "ความเร็วในการเคลื่อนที่ (หน่วย/วินาที)",
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
    Desc = "ระยะห่างแกน X จากปลา",
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
    Desc = "ระยะห่างแกน Y จากปลา",
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
    Desc = "ระยะห่างแกน Z จากปลา",
    Min = -10,
    Max = 10,
    Value = 0,
    Callback = function(value)
        chaseSettings.distance = Vector3.new(chaseSettings.distance.X, chaseSettings.distance.Y, value)
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
                    Desc = "กำลังติดตามปลา: " .. selectedFish,
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

-- ปุ่มจับปลา
Tab:Button({
    Title = "จับปลา",
    Callback = function()
        if not selectedFish or not fishData[selectedFish] then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 2
            })
            return
        end
        
        local fishId = fishData[selectedFish].fishId
        local success, result = CatchFish(fishId)
        
        if success then
            Window:Notify({
                Title = "สำเร็จ",
                Desc = "จับปลา: " .. selectedFish,
                Time = 2
            })
        else
            Window:Notify({
                Title = "ข้อผิดพลาด",
                Desc = "ไม่สามารถจับปลาได้",
                Time = 2
            })
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
    Title = "Auto Farm",
    Desc = "ออโต้ติดตามและจับปลาทั้งหมด",
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
                        
                        if fishInfo and fishInfo.model then
                            -- เริ่มติดตาม
                            isChasing = true
                            ChaseFish(fishInfo.model)
                            
                            -- รอให้เข้าใกล้ปลา
                            wait(2)
                            
                            -- ลองจับปลา
                            if fishInfo.model:IsDescendantOf(workspace) then
                                local catchSuccess, _ = CatchFish(fishInfo.fishId)
                                if catchSuccess then
                                    wait(1) -- รอหลังจับสำเร็จ
                                end
                            end
                            
                            -- หยุดติดตาม
                            isChasing = false
                            if currentTween then
                                currentTween:Cancel()
                                currentTween = nil
                            end
                            
                            wait(1) -- รอระหว่างปลา
                        end
                    end
                    
                    wait(2) -- รอก่อนลูปถัดไป
                end
            end)
            
            Window:Notify({
                Title = "เริ่ม Auto Farm",
                Desc = "กำลังจับปลาอัตโนมัติ",
                Time = 2
            })
        else
            -- หยุด Auto Farm
            isChasing = false
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
                Desc = "หยุดการจับปลาอัตโนมัติ",
                Time = 2
            })
        end
    end
})

Window:Notify({
    Title = "ระบบพร้อมใช้งาน",
    Desc = "Tween Chase System Loaded",
    Time = 2
})
