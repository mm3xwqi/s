-- ================================
-- X2ZU UI + Auto Chest Farm (Tween + Remote + Oxygen + Noclip)
-- ================================

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Main Window
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

-- Main Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"})

-- ========== CHEST FARM SECTION (TWEEN + REMOTE) ==========
Tab:Section({Title = "Chest Farm"})

-- Variables
local SelectedTier = "Tier 1"
local AutoChestEnabled = false
local AutoChestCoroutine = nil
local NoclipEnabled = false
local NoclipConnection = nil

-- Remote reference
local UnlockChestRemote = ReplicatedStorage:WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ChestService"):WaitForChild("RF"):WaitForChild("UnlockChest")

-- Oxygen refill position
local OXYGEN_REFILL_POS = Vector3.new(-59, 4883, -49)

-- Get character safely
local function getCharacter()
    if not Players.LocalPlayer.Character then
        Players.LocalPlayer.CharacterAdded:Wait()
    end
    return Players.LocalPlayer.Character
end

-- Tween to target position at speed 100
local function tweenToPosition(targetPosition)
    local character = getCharacter()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local distance = (targetPosition - rootPart.Position).Magnitude
    local duration = distance / 100

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(targetPosition)}
    local tween = TweenService:Create(rootPart, tweenInfo, goal)

    tween:Play()
    tween.Completed:Wait()
end

-- Noclip control
local function enableNoclip()
    if NoclipEnabled then return end
    NoclipEnabled = true
    NoclipConnection = RunService.Stepped:Connect(function()
        if NoclipEnabled and Players.LocalPlayer.Character then
            for _, part in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    NoclipEnabled = false
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
end

-- Get current oxygen percentage from GUI
local function getOxygenPercent()
    local success, result = pcall(function()
        local oxygenLabel = Players.LocalPlayer.PlayerGui:FindFirstChild("Main")
            and Players.LocalPlayer.PlayerGui.Main:FindFirstChild("Oxygen")
            and Players.LocalPlayer.PlayerGui.Main.Oxygen:FindFirstChild("CanvasGroup")
            and Players.LocalPlayer.PlayerGui.Main.Oxygen.CanvasGroup:FindFirstChild("Oxygen")
        
        if oxygenLabel and oxygenLabel:IsA("TextLabel") then
            local text = oxygenLabel.Text
            -- Extract number from text (e.g., "75%", "50")
            local num = tonumber(text:match("%d+"))
            return num or 100
        end
        return 100 -- default if not found
    end)
    return success and result or 100
end

-- Check oxygen and refill if below 10%
local function checkAndRefillOxygen()
    local oxygen = getOxygenPercent()
    if oxygen < 10 then
        Window:Notify({Title = "Oxygen Low", Desc = "Refilling oxygen...", Time = 2})
        
        -- Tween to oxygen station
        tweenToPosition(OXYGEN_REFILL_POS)
        
        -- Wait until oxygen is full (above 90%)
        repeat
            wait(0.5)
            oxygen = getOxygenPercent()
        until oxygen >= 90 or not AutoChestEnabled
        
        Window:Notify({Title = "Oxygen Full", Desc = "Resuming chest collection", Time = 2})
        wait(0.3)
    end
end

-- Stop auto chest loop
local function stopAutoChest()
    AutoChestEnabled = false
    disableNoclip()
    if AutoChestCoroutine then
        coroutine.close(AutoChestCoroutine)
        AutoChestCoroutine = nil
    end
end

-- Main collection: tween to each chest, then invoke remote
local function collectChests(tierName)
    local chestsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Chests")
    if not chestsFolder then
        Window:Notify({Title = "Error", Desc = "Chests folder not found!", Time = 3})
        return
    end

    local tierFolder = chestsFolder:FindFirstChild(tierName)
    if not tierFolder then
        Window:Notify({Title = "Error", Desc = tierName .. " not found!", Time = 3})
        return
    end

    -- Collect numbered chests
    local chests = {}
    for _, child in ipairs(tierFolder:GetChildren()) do
        if tonumber(child.Name) then
            table.insert(chests, child)
        end
    end

    -- Sort by number
    table.sort(chests, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    Window:Notify({Title = "Auto Chest", Desc = "Starting " .. tierName .. " collection...", Time = 3})

    for _, chest in ipairs(chests) do
        if not AutoChestEnabled then break end

        -- Check oxygen before moving to next chest
        checkAndRefillOxygen()
        if not AutoChestEnabled then break end

        -- 1. Get target position (prefer RewardPart, fallback to chest position)
        local targetPosition = nil
        local rewardPart = chest:FindFirstChild("Chest") and chest.Chest:FindFirstChild("Main") and chest.Chest.Main:FindFirstChild("BottomChest") and chest.Chest.Main.BottomChest:FindFirstChild("RewardPart")
        if rewardPart then
            targetPosition = rewardPart.Position
        elseif chest:IsA("Model") and chest.PrimaryPart then
            targetPosition = chest.PrimaryPart.Position
        elseif chest:IsA("BasePart") then
            targetPosition = chest.Position
        else
            warn("No position found for chest:", chest:GetFullName())
            continue
        end

        -- 2. Tween to chest (noclip is already enabled globally)
        local tweenSuccess, tweenErr = pcall(function()
            tweenToPosition(targetPosition)
        end)
        if not tweenSuccess then
            warn("Tween failed:", tweenErr)
            continue
        end

        -- 3. Wait a tiny moment to ensure proximity
        wait(0.2)

        -- 4. Invoke remote to unlock chest
        local chestNumber = chest.Name
        local remoteSuccess, remoteResult = pcall(function()
            return UnlockChestRemote:InvokeServer(tierName, chestNumber)
        end)

        if remoteSuccess then
            print(string.format("Unlocked %s - %s", tierName, chestNumber))
        else
            warn(string.format("Remote failed for %s - %s: %s", tierName, chestNumber, remoteResult))
        end

        -- 5. Small delay between chests
        wait(0.3)
    end

    if AutoChestEnabled then
        Window:Notify({Title = "Auto Chest", Desc = "Finished " .. tierName .. " collection.", Time = 3})
        AutoChestEnabled = false
        disableNoclip()
    end
end

-- Dropdown: Select Tier
Tab:Dropdown({
    Title = "Select Tier",
    Desc = "Choose which tier to collect",
    List = {"Tier 1", "Tier 2", "Tier 3"},
    Value = "Tier 1",
    Callback = function(choice)
        SelectedTier = choice
        print("Selected tier:", SelectedTier)
    end
})

-- Toggle: Auto Chest
Tab:Toggle({
    Title = "Auto Chest",
    Desc = "Tween to chests then unlock via remote (with oxygen refill & noclip)",
    Value = false,
    Callback = function(v)
        if v then
            stopAutoChest() -- stop any previous loop
            AutoChestEnabled = true
            enableNoclip()   -- enable noclip while auto chest is on
            AutoChestCoroutine = coroutine.create(function()
                collectChests(SelectedTier)
            end)
            coroutine.resume(AutoChestCoroutine)
        else
            stopAutoChest()
        end
    end
})

-- ========== NOTIFICATION ==========
Window:Notify({
    Title = "UI Loaded",
    Desc = "Main UI loaded successfully!",
    Time = 3
})

print("✅ Auto Chest Farm (Tween + Remote + Oxygen + Noclip) ready!")
