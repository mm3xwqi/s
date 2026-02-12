-- ================================
-- X2ZU UI + Auto Chest Farm (Remote Version)
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

-- ========== EXAMPLE SECTION (optional) ==========
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

-- ========== CHEST FARM SECTION (REMOTE) ==========
Tab:Section({Title = "Chest Farm"})

-- Variables
local SelectedTier = "Tier 1"   -- Default tier
local AutoChestEnabled = false
local AutoChestCoroutine = nil

-- Remote function reference
local UnlockChestRemote = game:GetService("ReplicatedStorage"):WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ChestService"):WaitForChild("RF"):WaitForChild("UnlockChest")

-- Stop auto chest loop
local function stopAutoChest()
    AutoChestEnabled = false
    if AutoChestCoroutine then
        coroutine.close(AutoChestCoroutine)
        AutoChestCoroutine = nil
    end
end

-- Main collection function using remote
local function collectChests(tierName)
    -- Check chest folder exists
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

    -- Get all numbered chest children
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

    Window:Notify({Title = "Auto Chest", Desc = "Starting " .. tierName .. " collection via remote...", Time = 3})

    for _, chest in ipairs(chests) do
        if not AutoChestEnabled then break end

        -- Chest number as string (e.g., "1", "2", ...)
        local chestNumber = chest.Name

        -- Invoke remote with tier name and chest number
        local success, result = pcall(function()
            return UnlockChestRemote:InvokeServer(tierName, chestNumber)
        end)

        if success then
            print(string.format("Unlocked %s - %s", tierName, chestNumber))
        else
            warn(string.format("Failed to unlock %s - %s: %s", tierName, chestNumber, result))
        end

        wait(0.2)   -- small delay to avoid flooding
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
    Desc = "Automatically unlock all chests in selected tier using remote",
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

print("✅ Auto Chest Farm (Remote) ready! Select a tier and enable the toggle.")
