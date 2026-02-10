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

-- ตัวแปรเก็บสถานะ
local isAutoFishing = false
local currentTween
local selectedFishId = ""
local fishHealthConnection

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

-- ฟังก์ชันจับปลา
local function catchFish(fishId)
    local args = {
        fishId
    }
    
    -- รันรีโมทจับปลาจนกว่าปลาจะตาย
    local fish = workspace.Game.Fish.client:FindFirstChild(fishId)
    if not fish then return false end
    
    local healthPart = fish:FindFirstChild("Head")
    if healthPart then
        local stats = healthPart:FindFirstChild("stats")
        if stats then
            local health = stats:FindFirstChild("Health")
            if health then
                local amount = health:FindFirstChild("Amount")
                if amount then
                    -- เชื่อมต่อตรวจสอบเลือดปลา
                    fishHealthConnection = amount:GetPropertyChangedSignal("Value"):Connect(function()
                        if amount.Value <= 0 then
                            -- เมื่อปลาตาย ให้ใช้รีโมท SaveHotbar
                            local saveArgs = {
                                {
                                    ["1"] = "1",
                                    ["3"] = "1ab2acaef12541558d69b19f6ad8d012",
                                    ["2"] = "9888203f88e8482e9b38218c199affba",
                                    ["5"] = "d73b2f8a88744c1e8cf4d83dcb969e32",
                                    ["4"] = "a42fbe3c032b42c4812d499514545df2"
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BackpackService"):WaitForChild("RF"):WaitForChild("SaveHotbar"):InvokeServer(unpack(saveArgs))
                            
                            -- ปิดการเชื่อมต่อ
                            if fishHealthConnection then
                                fishHealthConnection:Disconnect()
                                fishHealthConnection = nil
                            end
                        end
                    end)
                    
                    -- รันรีโมทจับปลา
                    while amount.Value > 0 and isAutoFishing do
                        game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("HarpoonService"):WaitForChild("RF"):WaitForChild("StartCatching"):InvokeServer(unpack(args))
                        task.wait(1) -- รอ 1 วินาทีก่อนจับครั้งต่อไป
                    end
                end
            end
        end
    end
    
    return true
end

-- ฟังก์ชันเริ่ม Auto Fish
local function startAutoFishing()
    if selectedFishId == "" then
        Window:Notify({
            Title = "Error",
            Desc = "Please select a fish first!",
            Time = 3
        })
        return false
    end
    
    -- Teleport ไปหาปลา
    local success = teleportToFish(selectedFishId)
    if not success then
        Window:Notify({
            Title = "Error",
            Desc = "Fish not found!",
            Time = 3
        })
        return false
    end
    
    -- เริ่มจับปลา
    catchFish(selectedFishId)
    
    return true
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
            
            Window:Notify({
                Title = "Auto Fish Started",
                Desc = "Teleporting to fish: " .. selectedFishId,
                Time = 3
            })
            
            -- เริ่ม Auto Fishing ใน coroutine แยก
            coroutine.wrap(function()
                startAutoFishing()
            end)()
        else
            -- หยุด Auto Fishing
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            
            if fishHealthConnection then
                fishHealthConnection:Disconnect()
                fishHealthConnection = nil
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
        local args = {
            {
                ["1"] = "1",
                ["3"] = "1ab2acaef12541558d69b19f6ad8d012",
                ["2"] = "9888203f88e8482e9b38218c199affba",
                ["5"] = "d73b2f8a88744c1e8cf4d83dcb969e32",
                ["4"] = "a42fbe3c032b42c4812d499514545df2"
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

Window:Notify({
    Title = "UI Loaded",
    Desc = "Auto Fish UI loaded successfully!",
    Time = 3
})
