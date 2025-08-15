local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()
local win = DiscordLib:Window("MM</>2.3")

local serv = win:Server("Preview", "")
local tgls = serv:Channel("Toggles")

local TweenService = game:GetService("TweenService")
local plr = game:GetService("Players").LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

local panPos, shakePos = nil, nil
local args = {1}
local running, runningShake, runningSell = false, false, false
local fillTextObj = nil

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
            local fillTextObj = plr.PlayerGui:FindFirstChild("ToolUI")
                and plr.PlayerGui.ToolUI:FindFirstChild("FillingPan")
                and plr.PlayerGui.ToolUI.FillingPan:FindFirstChild("FillText")

            if fillTextObj then
                local current, max = fillTextObj.Text:match("(%d+)%s*/%s*(%d+)")
                current, max = tonumber(current), tonumber(max)

                if current and max then
                    local panTool = findPan()
                    if current < max and panTool then
                        if panPos then moveToPositionSpeed(panPos, 300) end
                        pcall(function()
                            panTool:WaitForChild("Scripts"):WaitForChild("Collect"):InvokeServer(unpack(args))
                        end)
                    elseif current >= max and panTool and shakePos then
                        moveToPositionSpeed(shakePos, 300)
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
            task.wait(0.1)
        end
    end)
end)

-- Save Pan
tgls:Button("savepan", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        panPos = plr.Character.HumanoidRootPart.Position
        print("[Auto Pan] Saved pan position:", panPos)
    end
end)

-- Save Shake
tgls:Button("saveshake", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        shakePos = plr.Character.HumanoidRootPart.Position
        print("[Auto Pan] Saved shake position:", shakePos)
    end
end)

local runningSell = false

tgls:Toggle("Auto-Sell", false, function(state)
    runningSell = state
    task.spawn(function()
        while runningSell do
            pcall(function()
                RepStorage:WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("SellAll"):InvokeServer()
            end)
            task.wait(5)
        end
    end)
end)
