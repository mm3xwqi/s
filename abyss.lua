local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

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

Tab:Section({Title = "Features"})

-- ตัวแปรเก็บ ID ของปลา (ตัวอย่างจากรหัสที่คุณให้)
local fishData = {
    ["Example Fish 1"] = {
        fishId = "df220f0e597b485ea9b05c5483554031",
        rodId = "9888203f88e8482e9b38218c199affba",
        baitId = "d73b2f8a88744c1e8cf4d83dcb969e32"
    },
    ["Example Fish 2"] = {
        fishId = "OTHER_FISH_ID_HERE",
        rodId = "OTHER_ROD_ID_HERE",
        baitId = "OTHER_BAIT_ID_HERE"
    }
}

-- ฟังก์ชันดึงปลาจาก workspace และพยายามดึงข้อมูล ID
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
                        -- พยายามดึง ID จากปลา (อาจมีเก็บอยู่ใน Attribute หรือ Value)
                        local fishName = fish.Name
                        
                        -- ตรวจสอบ Attribute สำหรับ ID
                        local fishId = fish:GetAttribute("FishId") or 
                                      fish:GetAttribute("ID") or 
                                      fishName -- ถ้าไม่มีใช้ชื่อเป็นฐาน
                        
                        -- เก็บข้อมูลปลา
                        if not fishData[fishName] then
                            fishData[fishName] = {
                                fishId = fishId,
                                rodId = "9888203f88e8482e9b38218c199affba", -- ตัวอย่างจากโค้ด
                                baitId = "d73b2f8a88744c1e8cf4d83dcb969e32" -- ตัวอย่างจากโค้ด
                            }
                        end
                        
                        table.insert(fishList, fishName)
                    end
                end
            end
        end
    end
    
    -- ถ้าไม่พบปลาจาก workspace ให้ใช้ตัวอย่าง
    if #fishList == 0 then
        for fishName, _ in pairs(fishData) do
            table.insert(fishList, fishName)
        end
    end
    
    return fishList
end

-- ฟังก์ชันหา Model ปลาจากชื่อ
local function FindFishByName(fishName)
    local fishFolder = workspace:FindFirstChild("Game")
    if fishFolder then
        fishFolder = fishFolder:FindFirstChild("Fish")
        if fishFolder then
            fishFolder = fishFolder:FindFirstChild("client")
            if fishFolder then
                return fishFolder:FindFirstChild(fishName)
            end
        end
    end
    return nil
end

-- ฟังก์ชัน Tween ไปหาปลา
local function TweenToPosition(position)
    local humanoidRootPart = game.Players.LocalPlayer.Character and 
                            game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return false end
    
    local targetCFrame = CFrame.new(position)
    
    -- สร้าง Tween
    local tweenInfo = TweenInfo.new(
        3, -- ระยะเวลา
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        0,
        false,
        0
    )
    
    local tween = game:GetService("TweenService"):Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = targetCFrame}
    )
    
    tween:Play()
    tween.Completed:Wait()
    wait(0.5)
    return true
end

local function TweenToFish(fishModel)
    if not fishModel then return false end
    
    local fishPrimaryPart = fishModel.PrimaryPart or fishModel:FindFirstChild("Head") or 
                           fishModel:FindFirstChild("Torso") or fishModel:FindFirstChild("UpperTorso")
    
    if not fishPrimaryPart then return false end
    
    local targetPosition = fishPrimaryPart.Position + Vector3.new(0, 3, 0)
    return TweenToPosition(targetPosition)
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
                        -- ดึงตัวเลขจาก Text (เช่น "100%" -> 100)
                        local text = oxygenText.Text
                        local number = tonumber(text:match("%d+"))
                        return number or 100
                    end
                end
            end
        end
    end
    return 100 -- ถ้าไม่เจอให้ถือว่ามีเต็ม
end

-- ระบบ Auto Oxygen
local autoOxygenEnabled = false
local oxygenThread = nil

local function StartOxygenMonitor()
    if oxygenThread then
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
            -- แจ้งเตือน
            Window:Notify({
                Title = "ออกซิเจนต่ำ",
                Desc = "ออกซิเจนเหลือ " .. oxygenLevel .. "% กำลังกลับผิวน้ำ",
                Time = 3
            })
            
            -- Tween ไปยังตำแหน่งผิวน้ำ
            local success = TweenToPosition(Vector3.new(-59, 4883, -49))
            
            if success then
                -- รอจนออกซิเจนเต็ม
                while autoOxygenEnabled and GetOxygenLevel() < 95 do
                    wait(1)
                end
                
                if autoOxygenEnabled then
                    Window:Notify({
                        Title = "ออกซิเจนเต็มแล้ว",
                        Desc = "พร้อมดำน้ำอีกครั้ง!",
                        Time = 3
                    })
                end
            end
        end
    end)
end

-- ตัวแปรเก็บปลาที่เลือก
local selectedFish = nil
local fishDropdown = nil

-- สร้าง Dropdown
fishDropdown = Tab:Dropdown({
    Title = "เลือกปลา",
    List = GetFishList(),
    Value = "",
    Callback = function(choice)
        selectedFish = choice
        print("เลือกปลา:", choice)
        
        -- แสดงข้อมูลปลาที่เลือก
        if fishData[choice] then
            print("Fish ID:", fishData[choice].fishId)
            print("Rod ID:", fishData[choice].rodId)
            print("Bait ID:", fishData[choice].baitId)
        end
    end
})

-- ปุ่มรีเฟรชลิสต์ปลา
Tab:Button({
    Title = "รีเฟรชลิสต์ปลา",
    Callback = function()
        fishDropdown:Refresh(GetFishList())
        Window:Notify({
            Title = "อัพเดทแล้ว",
            Desc = "อัพเดทลิสต์ปลาสำเร็จ!",
            Time = 3
        })
    end
})

-- ปุ่มไปหาปลา
Tab:Button({
    Title = "ไปหาปลา",
    Desc = "Tween ไปหาปลาที่เลือก",
    Callback = function()
        if not selectedFish or selectedFish == "" then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 3
            })
            return
        end
        
        local fishModel = FindFishByName(selectedFish)
        if not fishModel then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "ไม่พบปลา: " .. selectedFish,
                Time = 3
            })
            return
        end
        
        Window:Notify({
            Title = "กำลังเคลื่อนที่",
            Desc = "กำลังไปหาปลา: " .. selectedFish,
            Time = 3
        })
        
        local success = TweenToFish(fishModel)
        
        if success then
            Window:Notify({
                Title = "สำเร็จ",
                Desc = "ถึงตำแหน่งปลาแล้ว: " .. selectedFish,
                Time = 3
            })
        end
    end
})

-- ปุ่มจับปลา
Tab:Button({
    Title = "จับปลา",
    Desc = "ใช้รีโมทจับปลาที่เลือก",
    Callback = function()
        if not selectedFish or selectedFish == "" then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "กรุณาเลือกปลาก่อน!",
                Time = 3
            })
            return
        end
        
        -- ดึงข้อมูลปลาจาก fishData
        local data = fishData[selectedFish]
        if not data then
            Window:Notify({
                Title = "ผิดพลาด",
                Desc = "ไม่พบข้อมูล ID สำหรับปลา: " .. selectedFish,
                Time = 3
            })
            return
        end
        
        -- ใช้รีโมทจับปลาตามโค้ดที่คุณให้มาใหม่
        local args = {
            {
                ["1"] = "1", -- Slot number
                ["3"] = "", -- ชื่อ (ว่าง)
                ["2"] = data.rodId, -- Rod ID
                ["5"] = data.baitId, -- Bait ID
                ["4"] = data.fishId -- Fish ID
            }
        }
        
        Window:Notify({
            Title = "กำลังจับปลา",
            Desc = "กำลังจับปลา: " .. selectedFish,
            Time = 3
        })
        
        local success, errorMsg = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args))
        end)
        
        if success then
            Window:Notify({
                Title = "สำเร็จ",
                Desc = "จับปลาสำเร็จ: " .. selectedFish,
                Time = 3
            })
            
            -- อัพเดท ID (ถ้ามีการเปลี่ยนแปลง)
            -- ตัวอย่าง: อ่าน ID ใหม่จาก response หรือ attribute
        else
            Window:Notify({
                Title = "ข้อผิดพลาด",
                Desc = "ไม่สามารถจับปลาได้: " .. tostring(errorMsg),
                Time = 5
            })
        end
    end
})

-- Toggle สำหรับ Auto Oxygen
Tab:Toggle({
    Title = "Auto Oxygen Recovery",
    Desc = "กลับผิวน้ำเมื่อออกซิเจนต่ำ",
    Value = false,
    Callback = function(v)
        autoOxygenEnabled = v
        
        if v then
            Window:Notify({
                Title = "เปิดใช้งาน Auto Oxygen",
                Desc = "ระบบจะพาคุณกลับผิวน้ำเมื่อออกซิเจนต่ำกว่า 10%",
                Time = 3
            })
            StartOxygenMonitor()
        else
            Window:Notify({
                Title = "ปิดใช้งาน Auto Oxygen",
                Desc = "ระบบ Auto Oxygen ถูกปิดแล้ว",
                Time = 3
            })
            if oxygenThread then
                oxygenThread:Disconnect()
                oxygenThread = nil
            end
        end
    end
})

-- Toggle สำหรับ Auto Farm
local autoFarmEnabled = false
local autoFarmToggle = Tab:Toggle({
    Title = "Auto Farm ปลา",
    Desc = "ออโต้จับปลาทั้งหมด + Auto Oxygen",
    Value = false,
    Callback = function(v)
        autoFarmEnabled = v
        
        if v then
            -- เปิด Auto Oxygen อัตโนมัติ
            autoOxygenEnabled = true
            StartOxygenMonitor()
            
            -- เริ่ม Auto Farm
            spawn(function()
                while autoFarmEnabled do
                    local fishList = GetFishList()
                    
                    for _, fishName in ipairs(fishList) do
                        if not autoFarmEnabled then break end
                        
                        selectedFish = fishName
                        local fishModel = FindFishByName(fishName)
                        local data = fishData[fishName]
                        
                        if fishModel and data then
                            -- ตรวจสอบออกซิเจนก่อน
                            if GetOxygenLevel() < 20 then
                                Window:Notify({
                                    Title = "ออกซิเจนต่ำ",
                                    Desc = "รอออกซิเจนเพิ่มขึ้นก่อนจับปลา...",
                                    Time = 3
                                })
                                wait(5)
                            end
                            
                            -- Tween ไปหาปลา
                            TweenToFish(fishModel)
                            wait(0.5)
                            
                            -- จับปลา
                            local args = {
                                {
                                    ["1"] = "1",
                                    ["3"] = "",
                                    ["2"] = data.rodId,
                                    ["5"] = data.baitId,
                                    ["4"] = data.fishId
                                }
                            }
                            
                            pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args))
                            end)
                            
                            wait(3) -- รอระหว่างจับปลาแต่ละตัว
                        end
                    end
                    
                    wait(2) -- รอก่อนลูปถัดไป
                end
            end)
            
            Window:Notify({
                Title = "เริ่ม Auto Farm",
                Desc = "กำลังจับปลาอัตโนมัติ + Auto Oxygen",
                Time = 3
            })
        else
            -- ปิด Auto Oxygen
            autoOxygenEnabled = false
            if oxygenThread then
                oxygenThread:Disconnect()
                oxygenThread = nil
            end
            
            Window:Notify({
                Title = "หยุด Auto Farm",
                Desc = "หยุดการจับปลาอัตโนมัติแล้ว",
                Time = 3
            })
        end
    end
})

-- ปุ่มไปผิวน้ำ (Manual)
Tab:Button({
    Title = "ไปผิวน้ำ",
    Desc = "Tween ไปยังตำแหน่งผิวน้ำ",
    Callback = function()
        Window:Notify({
            Title = "กำลังไปผิวน้ำ",
            Desc = "ตำแหน่ง: (-59, 4883, -49)",
            Time = 3
        })
        
        local success = TweenToPosition(Vector3.new(-59, 4883, -49))
        
        if success then
            Window:Notify({
                Title = "ถึงผิวน้ำแล้ว",
                Desc = "รอออกซิเจนเพิ่มขึ้น...",
                Time = 3
            })
        end
    end
})

-- แสดง Oxygen Level ปัจจุบัน
Tab:Button({
    Title = "ตรวจสอบออกซิเจน",
    Desc = "แสดงระดับออกซิเจนปัจจุบัน",
    Callback = function()
        local oxygenLevel = GetOxygenLevel()
        Window:Notify({
            Title = "ระดับออกซิเจน",
            Desc = "ออกซิเจนปัจจุบัน: " .. oxygenLevel .. "%",
            Time = 3
        })
    end
})

Window:Notify({
    Title = "UI โหลดแล้ว",
    Desc = "ระบบจับปลาและ Auto Oxygen พร้อมใช้งาน!",
    Time = 3
})

-- ฟังก์ชันช่วยในการดึง ID จริงจากปลา (สำหรับ Development)
local function DebugFishInfo(fishName)
    local fishModel = FindFishByName(fishName)
    if fishModel then
        print("=== Debug Info for " .. fishName .. " ===")
        
        -- ตรวจสอบ Attribute ทั้งหมด
        for _, attr in pairs(fishModel:GetAttributes()) do
            print("Attribute:", _, "=", attr)
        end
        
        -- ตรวจสอบ Value
        for _, child in pairs(fishModel:GetDescendants()) do
            if child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("ObjectValue") then
                print("Value:", child.Name, "=", child.Value)
            end
        end
    else
        print("ไม่พบปลา:", fishName)
    end
end

-- ปุ่ม Debug สำหรับ Developer
Tab:Button({
    Title = "[Debug] ข้อมูลปลาที่เลือก",
    Callback = function()
        if selectedFish then
            DebugFishInfo(selectedFish)
            Window:Notify({
                Title = "Debug Info",
                Desc = "ตรวจสอบข้อมูลปลาใน Console (F9)",
                Time = 3
            })
        end
    end
})
