-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
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

-- Sidebar Vertical Separator
local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui")

-- Auto Fishing Variables
local player = game:GetService("Players").LocalPlayer
local isFishing = false
local isAutoShake = false
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

-- Hookmetamethod หลักสำหรับ Auto Fishing
local originalNamecall
originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Hook สำหรับ castAsync (Auto Fishing)
    if isFishing and method == "InvokeServer" and tostring(self) == "castAsync" then
        print("🎣 Auto fishing sequence started")

        -- เรียก cast ด้วยค่า max
        local result = originalNamecall(self, 100, 1)

        task.spawn(function()
            if not isFishing then return end

            -- รอ reel GUI ด้วยการตรวจสอบอย่างต่อเนื่อง
            local startTime = tick()
            local reelGuiFound = false
            
            while (tick() - startTime) < 15 and isFishing do
                local reelGui = player.PlayerGui:FindFirstChild("reel")
                if reelGui then
                    reelGuiFound = true
                    print("🎯 Reel detected, waiting 1 second...")
                    
                    -- รอ 1 วินาที
                    task.wait(1)
                    
                    if isFishing then
                        -- เรียก reelfinished
                        local reelEvent = game:GetService("ReplicatedStorage"):FindFirstChild("events"):FindFirstChild("reelfinished")
                        if reelEvent then
                            reelEvent:FireServer(100, true)
                            print("✅ Auto reel completed")
                        end
                        
                        -- รอจนกว่า reel GUI จะหายไป หรือ timeout 5 วินาที
                        local reelEndTime = tick()
                        while player.PlayerGui:FindFirstChild("reel") and (tick() - reelEndTime) < 5 and isFishing do
                            task.wait(0.1)
                        end
                        
                        break
                    end
                end
                task.wait(0.1)
            end
            
            if not reelGuiFound and isFishing then
                print("⏰ No reel GUI found within 15 seconds, recasting...")
            end
            
            -- รอ 2 วินาทีแล้วเริ่มกระบวนการใหม่
            if isFishing then
                task.wait(2)
                
                -- หาเบ็ดในมือหรือใน backpack
                local foundRod = nil
                for _, tool in ipairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("events") then
                        local castEvent = tool.events:FindFirstChild("castAsync")
                        if castEvent then
                            foundRod = {tool = tool, castEvent = castEvent}
                            break
                        end
                    end
                end
                
                -- ถ้าไม่มีเบ็ดในมือ ให้หาใน backpack
                if not foundRod then
                    for _, tool in ipairs(player.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("events") then
                            local castEvent = tool.events:FindFirstChild("castAsync")
                            if castEvent then
                                foundRod = {tool = tool, castEvent = castEvent}
                                break
                            end
                        end
                    end
                    
                    -- ถือเบ็ดถ้ายังไม่ได้ถือ
                    if foundRod and not player.Character:FindFirstChild(foundRod.tool.Name) then
                        player.Character.Humanoid:EquipTool(foundRod.tool)
                        task.wait(.1)
                    end
                end
                
                -- เรียก cast ใหม่
                if foundRod and isFishing then
                    print("🔄 Recasting with:", foundRod.tool.Name)
                    foundRod.castEvent:InvokeServer(100, 1)
                end
            end
        end)
        
        return result
    end

    return originalNamecall(self, ...)
end)

-- Auto Shake Function with Hookmetamethod
local function startAutoShake()
    if isAutoShake then return end
    isAutoShake = true
    
    task.spawn(function()
        while isAutoShake do
            task.wait(0.01)
            
            local PlayerGUI = player:WaitForChild("PlayerGui")
            local shakeUI = PlayerGUI:FindFirstChild("shakeui")
            
            if shakeUI and shakeUI.Enabled then
                local safezone = shakeUI:FindFirstChild("safezone")
                if safezone then
                    local button = safezone:FindFirstChild("button")
                    if button and button:IsA("ImageButton") and button.Visible then
                        -- ใช้ hookmetamethod สำหรับการกดปุ่ม
                        GuiService.SelectedObject = button
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        print("🔄 Auto shake activated")
                    end
                end
            end
        end
    end)
    
    Window:Notify({
        Title = "Auto Shake",
        Desc = "Auto shake started successfully!",
        Time = 3
    })
end

local function stopAutoShake()
    isAutoShake = false
    Window:Notify({
        Title = "Auto Shake",
        Desc = "Auto shake stopped!",
        Time = 3
    })
end

-- Auto Fishing Function
local function startAutoFishing()
    if isFishing then return end
    isFishing = true
    
    -- เริ่ม cast ครั้งแรก
    task.spawn(function()
        task.wait(0.1)
        if not isFishing then return end
        
        local foundRod = nil

        -- ตรวจสอบเบ็ดในมือก่อน
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("events") then
                local castEvent = tool.events:FindFirstChild("castAsync")
                if castEvent then
                    foundRod = {tool = tool, castEvent = castEvent}
                    break
                end
            end
        end

        -- ถ้าไม่มีเบ็ดในมือ ให้หาใน backpack
        if not foundRod then
            for _, tool in ipairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("events") then
                    local castEvent = tool.events:FindFirstChild("castAsync")
                    if castEvent then
                        foundRod = {tool = tool, castEvent = castEvent}
                        break
                    end
                end
            end

            -- ถือเบ็ดถ้ายังไม่ได้ถือ
            if foundRod and not player.Character:FindFirstChild(foundRod.tool.Name) then
                player.Character.Humanoid:EquipTool(foundRod.tool)
                task.wait(.1)
            end
        end

        -- เริ่ม cast ครั้งแรก
        if foundRod and isFishing then
            print("🚀 Starting first cast with:", foundRod.tool.Name)
            foundRod.castEvent:InvokeServer(100, 1)
        else
            print("❌ No fishing rod found")
        end
    end)
    
    Window:Notify({
        Title = "Auto Fishing",
        Desc = "Auto fishing started successfully!",
        Time = 3
    })
end

local function stopAutoFishing()
    isFishing = false
    Window:Notify({
        Title = "Auto Fishing",
        Desc = "Auto fishing stopped!",
        Time = 3
    })
end

-- Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"}) 
    -- Section
    Tab:Section({Title = "Fishing Features"})

    -- Auto Fishing Toggle
    Tab:Toggle({
        Title = "Auto Fishing",
        Desc = "",
        Value = false,
        Callback = function(v)
            if v then
                startAutoFishing()
            else
                stopAutoFishing()
            end
        end
    })

    -- Auto Shake Toggle
    Tab:Toggle({
        Title = "Auto Shake",
        Desc = "",
        Value = false,
        Callback = function(v)
            if v then
                startAutoShake()
            else
                stopAutoShake()
            end
        end
    })

-- Final Notification
Window:Notify({
    Title = "x2zu Fishing",
    Desc = "Auto fishing & shake loaded with hookmetamethod!",
    Time = 4
})

print("🎣 x2zu Auto Fishing & Shake with hookmetamethod loaded!")
