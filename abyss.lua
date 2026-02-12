-- ================================
-- X2ZU UI + Auto Chest Farm Script
-- ================================

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

-- Create Main Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"})

-- ========== EXAMPLE SECTION (keep for reference) ==========
Tab:Section({Title = "Features"})

Tab:Toggle({
    Title = "Enable Feature",
    Desc = "Toggle to enable or disable the feature",
    Value = false,
    Callback = function(v)
        print("Toggle:", v)
    end
})

Tab:Dropdown({
    Title = "Choose Option",
    List = {"Option 1", "Option 2", "Option 3"},
    Value = "Option 1",
    Callback = function(choice)
        print("Selected:", choice)
    end
})

-- ========== CHEST FARM SECTION ==========
Tab:Section({Title = "Chest Farm"})

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- Variables
local SelectedTier = "Tier 1"   -- Default tier
local AutoChestEnabled = false
local AutoChestCoroutine = nil

-- Helper: Get character safely
local function getCharacter()
    if not Player.Character then
        Player.CharacterAdded:Wait()
    end
    return Player.Character
end

-- Tween to position at 100 studs/sec
local function tweenToPosition(targetPosition)
    local Character = getCharacter()
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end

    local distance = (targetPosition - HumanoidRootPart.Position).Magnitude
    local duration = distance / 100   -- speed = 100 studs/sec

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(targetPosition)}
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, goal)
    
    tween:Play()
    tween.Completed:Wait()
end

-- Stop auto chest loop
local function stopAutoChest()
    AutoChestEnabled = false
    if AutoChestCoroutine then
        coroutine.close(AutoChestCoroutine)   -- if Luau supports; otherwise just flag
        AutoChestCoroutine = nil
    end
end

-- Main collection function
local function collectChests(tierName)
    -- Check chest folder
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

    -- Collect numbered chests (1,2,3...)
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

        -- Find RewardPart and Prompt
        local rewardPart = chest:FindFirstChild("Chest") and chest.Chest:FindFirstChild("Main") and chest.Chest.Main:FindFirstChild("BottomChest") and chest.Chest.Main.BottomChest:FindFirstChild("RewardPart")
        if not rewardPart then continue end

        local prompt = rewardPart:FindFirstChild("Prompt")
        if not prompt or not prompt:IsA("ProximityPrompt") then continue end

        -- Tween to chest
        local success, err = pcall(function()
            tweenToPosition(rewardPart.Position)
        end)
        if not success then
            warn("Tween failed:", err)
            continue
        end

        -- Fire prompt
        pcall(function()
            prompt:Fire()
        end)

        wait(0.3)   -- small delay
    end

    if AutoChestEnabled then
        Window:Notify({Title = "Auto Chest", Desc = "Finished " .. tierName .. " collection.", Time = 3})
        AutoChestEnabled = false   -- auto turn off flag
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
    Desc = "Automatically collect all chests in selected tier",
    Value = false,
    Callback = function(v)
        if v then
            stopAutoChest()               -- stop any previous loop
            AutoChestEnabled = true
            
            -- Start collection in a coroutine (non‑blocking)
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

print("✅ Auto Chest Farm ready! Select a tier and enable the toggle.")
