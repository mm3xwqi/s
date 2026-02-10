local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local Window = Library:Window({
    Title = "abyss",
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

-- ตัวแปรเก็บสถานะ
local isAutoFishing = false
local currentTween
local selectedFishId = ""
local fishingCoroutine

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

-- ฟังก์ชัน teleport ไปหาปลา
local function teleportToFish(fishId)
    local fish = workspace.Game.Fish.client:FindFirstChild(fishId)
    if not fish then return false end
    
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local humanoidRootPart = character.HumanoidRootPart
    local fishHead = fish:FindFirstChild("Head")
    if not fishHead then return false end
    
    -- หาตำแหน่งปลา
    local targetPosition = fishHead.Position
    
    -- สร้าง Tween
    local tweenInfo = TweenInfo.new(
        10, -- เวลาเดินทาง (วินาที)
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0, -- รีพีต
        false, -- ย้อนกลับ
        0 -- เดลย์
    )
    
    currentTween = game:GetService("TweenService"):Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = CFrame.new(targetPosition.X, targetPosition.Y + 5, targetPosition.Z)}
    )
    
    currentTween:Play()
    
    -- รอจนถึงปลา
    currentTween.Completed:Wait()
    return true
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
        
        -- Teleport ไปหาปลา
        local success = teleportToFish(selectedFishId)
        if not success then
            Window:Notify({
                Title = "Error",
                Desc = "Failed to teleport to fish!",
                Time = 3
            })
            break
        end
        
        -- เมื่อถึงปลา: รันรีโมท StartCatching
        local args1 = {
            selectedFishId  -- ใช้ไอดีปลาที่เลือก
        }
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args1))
        
        -- หลังจากนั้น: รันรีโมท SaveHotbar
        local args2 = {
            {
                ["1"] = "1",
                ["3"] = selectedFishId,  -- ใช้ไอดีปลาที่เลือก
                ["2"] = "36e94fbc4fcc4e38b16242dc3aea0730"
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(args2))
        
        -- รอก่อนจับปลาตัวต่อไป (ป้องกันสแปม)
        wait(2)
    end
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
            
            -- เริ่ม Auto Fishing ใน coroutine แยก
            fishingCoroutine = coroutine.create(startAutoFishingLoop)
            coroutine.resume(fishingCoroutine)
        else
            -- หยุด Auto Fishing
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            
            if fishingCoroutine then
                coroutine.close(fishingCoroutine)
                fishingCoroutine = nil
            end
            
            Window:Notify({
                Title = "Auto Fish Stopped",
                Desc = "Stopped fishing",
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

Window:Notify({
    Title = "UI Loaded",
    Desc = "Auto Fish UI loaded successfully!",
    Time = 3
})
