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
                        table.insert(fishList, fish.Name)
                    end
                end
            end
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
local function TweenToFish(fishModel)
    if not fishModel then return false end
    
    local humanoidRootPart = game.Players.LocalPlayer.Character and 
                            game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return false end
    
    local fishPrimaryPart = fishModel.PrimaryPart or fishModel:FindFirstChild("Head") or 
                           fishModel:FindFirstChild("Torso") or fishModel:FindFirstChild("UpperTorso")
    
    if not fishPrimaryPart then return false end
    
    -- คำนวณตำแหน่ง (เพิ่มความสูงเล็กน้อยเพื่อไม่ให้จมน้ำ)
    local targetPosition = fishPrimaryPart.Position + Vector3.new(0, 3, 0)
    
    -- สร้าง Tween
    local tweenInfo = TweenInfo.new(
        2, -- ระยะเวลา
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        0, -- จำนวนครั้งที่เล่นซ้ำ
        false, -- ย้อนกลับ
        0 -- delay
    )
    
    local tween = game:GetService("TweenService"):Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = CFrame.new(targetPosition)}
    )
    
    tween:Play()
    
    -- รอให้ Tween เสร็จ
    tween.Completed:Wait()
    wait(0.5) -- รอเพิ่มเล็กน้อยเพื่อให้มั่นใจว่าถึงตำแหน่งแล้ว
    return true
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
        
        -- Tween ไปหาปลา
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
        
        -- เนื่องจากเราไม่มี ID จริงของปลา
        -- เราจะใช้ชื่อปลาเป็นฐาน (คุณอาจต้องแก้ไขตามโครงสร้างจริงของเกม)
        local fishName = selectedFish
        local fishID = fishName -- หรืออาจต้องแปลงตามรูปแบบของเกม
        
        -- รีโมทแรก: StartCatching
        local args1 = { fishID }
        local success1 = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args1))
        end)
        
        if success1 then
            Window:Notify({
                Title = "กำลังจับปลา",
                Desc = "เริ่มจับปลา: " .. selectedFish,
                Time = 3
            })
            
            wait(1) -- รอสักครู่ก่อนใช้รีโมทถัดไป
            
            -- รีโมทที่สอง: SaveHotbar
            local args2 = {
                {
                    ["1"] = "1",
                    ["3"] = "Mossy", -- หรืออาจต้องเปลี่ยนตามชื่อแท่งที่คุณมี
                    ["2"] = fishID
                }
            }
            
            local success2 = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args2))
            end)
            
            if success2 then
                Window:Notify({
                    Title = "สำเร็จ",
                    Desc = "จับและบันทึกปลา: " .. selectedFish,
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "ข้อผิดพลาด",
                    Desc = "ไม่สามารถบันทึกลง hotbar ได้",
                    Time = 3
                })
            end
        else
            Window:Notify({
                Title = "ข้อผิดพลาด",
                Desc = "ไม่สามารถจับปลาได้",
                Time = 3
            })
        end
    end
})

-- Toggle สำหรับ Auto Farm
local autoFarmEnabled = false
local autoFarmToggle = Tab:Toggle({
    Title = "Auto Farm ปลา",
    Desc = "ออโต้จับปลาทั้งหมด",
    Value = false,
    Callback = function(v)
        autoFarmEnabled = v
        print("Auto Farm:", v)
        
        if v then
            -- เริ่ม Auto Farm
            spawn(function()
                while autoFarmEnabled do
                    local fishList = GetFishList()
                    
                    for _, fishName in ipairs(fishList) do
                        if not autoFarmEnabled then break end
                        
                        selectedFish = fishName
                        local fishModel = FindFishByName(fishName)
                        
                        if fishModel then
                            -- Tween ไปหาปลา
                            TweenToFish(fishModel)
                            wait(0.5)
                            
                            -- พยายามจับปลา
                            local fishID = fishName
                            local args1 = { fishID }
                            pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args1))
                            end)
                            
                            wait(2) -- รอระหว่างจับปลาแต่ละตัว
                        end
                    end
                    
                    wait(1) -- รอก่อนลูปถัดไป
                end
            end)
        end
    end
})

Window:Notify({
    Title = "UI โหลดแล้ว",
    Desc = "Main UI โหลดสำเร็จแล้ว!",
    Time = 3
})
