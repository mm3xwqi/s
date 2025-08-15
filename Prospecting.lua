local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()
local win = DiscordLib:Window("MM</>1")

local serv = win:Server("Preview", "")
local btns = serv:Channel("Buttons")
local tgls = serv:Channel("Toggles")

local plr = game:GetService("Players").LocalPlayer
local panPos, shakePos = nil, nil
local args = {1}
local running = false
local runningShake = false
local runningSell = false

-- ฟังก์ชันหา Pan
local function findPan()
    if plr.Character then
        for _, tool in ipairs(plr.Character:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name:lower(), "pan") then
                return tool
            end
        end
    end
    for _, tool in ipairs(plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name:lower(), "pan") then
            return tool
        end
    end
    return nil
end

-- ฟังก์ชัน Equip Pan
local function equipPan()
    local panTool = findPan()
    if panTool then
        panTool.Parent = plr.Character
        task.wait(0.1)
    end
end

-- Save Pan
btns:Button("savepan", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        panPos = plr.Character.HumanoidRootPart.Position
        print("[Auto Pan] Saved pan position:", panPos)
    end
end)

-- Save Shake
btns:Button("saveshake", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        shakePos = plr.Character.HumanoidRootPart.Position
        print("[Auto Pan] Saved shake position:", shakePos)
    end
end)

-- Auto-Pan Toggle
tgls:Toggle("Auto-Pan", false, function(state)
    running = state
    if running then equipPan() end
    task.spawn(function()
        while running do
            local fillTextObj = plr.PlayerGui:FindFirstChild("ToolUI")
                and plr.PlayerGui.ToolUI:FindFirstChild("FillingPan")
                and plr.PlayerGui.ToolUI.FillingPan:FindFirstChild("FillText")

            if fillTextObj then
                local current, max = fillTextObj.Text:match("(%d+)%s*/%s*(%d+)")
                current, max = tonumber(current), tonumber(max)
                if current and max then
                    if current < max then
                        if panPos and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            plr.Character.HumanoidRootPart.CFrame = CFrame.new(panPos)
                        end
                        local panTool = findPan()
                        if panTool then
                            pcall(function()
                                panTool:WaitForChild("Scripts"):WaitForChild("Collect"):InvokeServer(unpack(args))
                            end)
                        end
                    else
                        if shakePos and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            plr.Character.HumanoidRootPart.CFrame = CFrame.new(shakePos)
                        end
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end)

-- Auto-Shake Toggle
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
            task.wait(0.3)
        end
    end)
end)

-- ฟังก์ชันวาร์ปไป Merchant
local function goToMerchant()
    local merchant = workspace:FindFirstChild("NPCs")
        and workspace.NPCs:FindFirstChild("RiverTown")
        and workspace.NPCs.RiverTown:FindFirstChild("Merchant")
    if merchant and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(merchant.Position + Vector3.new(0,3,0))
        return merchant
    end
    return nil
end

-- Auto-Sell Toggle
tgls:Toggle("Auto-Sell", false, function(state)
    runningSell = state
    task.spawn(function()
        while runningSell do
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
                    local merchant = goToMerchant()
                    if merchant then
                        task.wait(0.2)
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
                                :WaitForChild("Shop")
                                :WaitForChild("SellAll")
                                :InvokeServer()
                        end)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)
