local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()
local win = DiscordLib:Window("MM</>2")

local serv = win:Server("Preview", "")
local btns = serv:Channel("Buttons")
local tgls = serv:Channel("Toggles")

local TweenService = game:GetService("TweenService")
local plr = game:GetService("Players").LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

local panPos, shakePos = nil, nil
local args = {1}
local running, runningShake, runningSell = false, false, false
local fillTextObj = nil
local invTextObj = nil

-- Cache GUI
local function cacheGUI()
    local toolUI = plr.PlayerGui:FindFirstChild("ToolUI")
    if toolUI then
        local fillingPan = toolUI:FindFirstChild("FillingPan")
        if fillingPan then
            fillTextObj = fillingPan:FindFirstChild("FillText")
        end
    end

    local backpackGui = plr.PlayerGui:FindFirstChild("BackpackGui")
    if backpackGui then
        local backpack = backpackGui:FindFirstChild("Backpack")
        if backpack then
            local inventory = backpack:FindFirstChild("Inventory")
            if inventory then
                local topButtons = inventory:FindFirstChild("TopButtons")
                if topButtons then
                    local unaffected = topButtons:FindFirstChild("Unaffected")
                    if unaffected then
                        invTextObj = unaffected:FindFirstChild("InventorySize")
                    end
                end
            end
        end
    end
end

cacheGUI() -- initial cache

-- หา Pan tool
local function findPan()
    for _, tool in ipairs(plr.Character:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("pan") then
            return tool
        end
    end
    for _, tool in ipairs(plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("pan") then
            return tool
        end
    end
    return nil
end

-- Equip Pan
local function equipPan()
    local panTool = findPan()
    if panTool then
        panTool.Parent = plr.Character
        task.wait(0.1)
    end
end

-- Tween ไปยังตำแหน่ง
local function tweenTo(pos, duration)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        local info = TweenInfo.new(duration or 0.5, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(pos)})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Auto-Pan
tgls:Toggle("Auto-Pan", false, function(state)
    running = state
    if running then equipPan() end
    task.spawn(function()
        while running do
            if fillTextObj then
                local current, max = fillTextObj.Text:match("(%d+)%s*/%s*(%d+)")
                current, max = tonumber(current), tonumber(max)
                if current and max then
                    local panTool = findPan()
                    if current < max and panTool then
                        if panPos then tweenTo(panPos, 0.3) end
                        pcall(function()
                            panTool:WaitForChild("Scripts"):WaitForChild("Collect"):InvokeServer(unpack(args))
                        end)
                    elseif current >= max and panTool and shakePos then
                        tweenTo(shakePos, 0.5)
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end)

-- Auto-Shake
tgls:Toggle("Auto-Shake", false, function(state)
    runningShake = state
    task.spawn(function()
        while runningShake do
            local panTool = findPan()
            if panTool then
                pcall(function()
                    local scriptsFolder = panTool:FindFirstChild("Scripts")
                    if scriptsFolder then
                        local shakeEvent = scriptsFolder:FindFirstChild("Shake")
                        if shakeEvent then shakeEvent:FireServer() end
                        local panEvent = scriptsFolder:FindFirstChild("Pan")
                        if panEvent then panEvent:InvokeServer() end
                    end
                end)
            end
            task.wait(0.1) -- delay เพิ่มเพื่อลด lag
        end
    end)
end)

-- วาร์ปไป Merchant
local function goToMerchant()
    local merchant = workspace:FindFirstChild("NPCs")
        and workspace.NPCs:FindFirstChild("RiverTown")
        and workspace.NPCs.RiverTown:FindFirstChild("Merchant")
    if merchant then tweenTo(merchant.Position + Vector3.new(0,3,0), 0.5) end
    return merchant
end

-- Auto-Sell
tgls:Toggle("Auto-Sell", false, function(state)
    runningSell = state
    task.spawn(function()
        while runningSell do
            -- ค้น InventorySize ทุก loop เผื่อ GUI update
            local invTextObj = plr.PlayerGui:FindFirstChild("BackpackGui")
                and plr.PlayerGui.BackpackGui:FindFirstChild("Backpack")
                and plr.PlayerGui.BackpackGui.Backpack:FindFirstChild("Inventory")
                and plr.PlayerGui.BackpackGui.Backpack.Inventory:FindFirstChild("TopButtons")
                and plr.PlayerGui.BackpackGui.Backpack.Inventory.TopButtons:FindFirstChild("Unaffected")
                and plr.PlayerGui.BackpackGui.Backpack.Inventory.TopButtons.Unaffected:FindFirstChild("InventorySize")

            if invTextObj then
                local current, max = invTextObj.Text:match("(%d+)%s*/%s*(%d+)")
                current, max = tonumber(current), tonumber(max)

                if current and max and current >= max then
                    -- หา NPC Merchant
                    local merchant = workspace:WaitForChild("NPCs")
                        :WaitForChild("RiverTown")
                        :WaitForChild("Merchant")

                    if merchant and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        -- Tween ไป Merchant
                        local hrp = plr.Character.HumanoidRootPart
                        local tween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(merchant.Position + Vector3.new(0,3,0))})
                        tween:Play()
                        tween.Completed:Wait() -- รอให้ถึงตำแหน่งก่อน

                        -- ขายของ
                        pcall(function()
                            RepStorage.Remotes.Shop.SellAll:InvokeServer()
                        end)
                        task.wait(0.5) -- รอ GUI update
                    end
                end
            end
            task.wait(0.5) -- ลดตรวจหนักเกินไป
        end
    end)
end)

