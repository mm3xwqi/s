-- ================================
-- X2ZU UI + Auto Chest Farm
-- (Full Feature + Skip Opened Chests + Vehicle Noclip + Tubes Support)
-- ================================

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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

-- ========== CHEST FARM SECTION ==========
Tab:Section({Title = "Chest Farm"})

-- Variables
local SelectedTier = "Tier 1"
local AutoChestEnabled = false
local AutoChestCoroutine = nil
local NoclipEnabled = false
local NoclipConnection = nil
local TweenSpeed = 100
local FarmAllTiers = false

-- Cache for already unlocked chests
local UnlockedChests = {}

-- Remote reference
local UnlockChestRemote = ReplicatedStorage:WaitForChild("common"):WaitForChild("packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ChestService"):WaitForChild("RF"):WaitForChild("UnlockChest")

-- Oxygen refill position
local OXYGEN_REFILL_POS = Vector3.new(-59, 4883, -49)

-- Tier list for farming all
local TIER_LIST = {"Tier 1", "Tier 2", "Tier 3"}

-- Get character safely
local function getCharacter()
    if not Players.LocalPlayer.Character then
        Players.LocalPlayer.CharacterAdded:Wait()
    end
    return Players.LocalPlayer.Character
end

-- Tween to target position at current TweenSpeed
local function tweenToPosition(targetPosition)
    local character = getCharacter()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local distance = (targetPosition - rootPart.Position).Magnitude
    local duration = distance / TweenSpeed

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(targetPosition)}
    local tween = TweenService:Create(rootPart, tweenInfo, goal)

    tween:Play()
    tween.Completed:Wait()
end

-- ========== NOCLIP (Character + Vehicle – Supports boats in workspace.Game.Tubes) ==========
local CurrentVehicle = nil

local function enableNoclip()
    if NoclipEnabled then return end
    NoclipEnabled = true
    
    NoclipConnection = RunService.Stepped:Connect(function()
        if not NoclipEnabled then return end
        
        local character = Players.LocalPlayer.Character
        if not character then return end
        
        -- Noclip character
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- Check if player is seated
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local seat = character:FindFirstChildOfClass("VehicleSeat") or character:FindFirstChildOfClass("Seat")
        local vehicleModel = nil
        
        if seat and humanoid and seat.Occupant == humanoid then
            -- Climb up from the seat until we hit workspace, the character itself, or a reasonable container
            local parent = seat.Parent
            while parent and parent ~= workspace and parent ~= character do
                -- Accept any container (Model, Folder, etc.) that isn't the character
                vehicleModel = parent
                parent = parent.Parent
            end
        end
        
        -- Update current vehicle reference
        if vehicleModel and vehicleModel ~= CurrentVehicle then
            CurrentVehicle = vehicleModel
            print("🚤 Vehicle detected:", CurrentVehicle:GetFullName())
        elseif not vehicleModel then
            CurrentVehicle = nil
        end
        
        -- Apply noclip to current vehicle (works even if it's in workspace.Game.Tubes as a Folder)
        if CurrentVehicle then
            for _, part in ipairs(CurrentVehicle:GetDescendants()) do
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
    
    -- Restore collision on character
    local character = Players.LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    -- Restore collision on last known vehicle
    if CurrentVehicle then
        for _, part in ipairs(CurrentVehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        CurrentVehicle = nil
    end
end

-- ========== OXYGEN SYSTEM ==========
local function getOxygenPercent()
    local success, result = pcall(function()
        local mainGui = Players.LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not mainGui then return 100 end
        local oxygenFrame = mainGui:FindFirstChild("Oxygen")
        if not oxygenFrame then return 100 end
        local canvasGroup = oxygenFrame:FindFirstChild("CanvasGroup")
        if not canvasGroup then return 100 end
        local oxygenLabel = canvasGroup:FindFirstChild("Oxygen")
        if not oxygenLabel then return 100 end
        
        if oxygenLabel:IsA("TextLabel") or oxygenLabel:IsA("TextButton") then
            local text = oxygenLabel.ContentText or oxygenLabel.Text
            local num = tonumber(text:match("%d+"))
            return num or 100
        end
        return 100
    end)
    return success and result or 100
end

local function checkAndRefillOxygen()
    local oxygen = getOxygenPercent()
    if oxygen < 10 then
        Window:Notify({Title = "Oxygen Low", Desc = "Refilling oxygen... (" .. oxygen .. "%)", Time = 2})
        tweenToPosition(OXYGEN_REFILL_POS)
        repeat
            wait(0.5)
            oxygen = getOxygenPercent()
        until oxygen >= 90 or not AutoChestEnabled
        if AutoChestEnabled then
            Window:Notify({Title = "Oxygen Full", Desc = "Resuming chest collection", Time = 2})
        end
        wait(0.3)
    end
end

-- ========== CHEST COLLECTION ==========
local function stopAutoChest()
    AutoChestEnabled = false
    disableNoclip()
    if AutoChestCoroutine then
        pcall(coroutine.close, AutoChestCoroutine)
        AutoChestCoroutine = nil
    end
end

local function collectTier(tierName)
    local chestsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Chests")
    if not chestsFolder then
        Window:Notify({Title = "Error", Desc = "Chests folder not found!", Time = 3})
        return false
    end

    local tierFolder = chestsFolder:FindFirstChild(tierName)
    if not tierFolder then
        Window:Notify({Title = "Error", Desc = tierName .. " not found!", Time = 3})
        return false
    end

    local chests = {}
    for _, child in ipairs(tierFolder:GetChildren()) do
        if tonumber(child.Name) then
            table.insert(chests, child)
        end
    end

    table.sort(chests, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    Window:Notify({Title = "Auto Chest", Desc = "Starting " .. tierName .. " collection...", Time = 3})

    for _, chest in ipairs(chests) do
        if not AutoChestEnabled then break end

        local chestNumber = chest.Name
        local chestKey = tierName .. "_" .. chestNumber

        if UnlockedChests[chestKey] then
            print("Skipping already unlocked chest:", tierName, chestNumber)
            continue
        end

        checkAndRefillOxygen()
        if not AutoChestEnabled then break end

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

        local tweenSuccess, tweenErr = pcall(function()
            tweenToPosition(targetPosition)
        end)
        if not tweenSuccess then
            warn("Tween failed:", tweenErr)
            continue
        end

        wait(0.2)

        local remoteSuccess, remoteResult = pcall(function()
            return UnlockChestRemote:InvokeServer(tierName, chestNumber)
        end)

        if remoteSuccess then
            print(string.format("✅ Unlocked %s - %s", tierName, chestNumber))
            UnlockedChests[chestKey] = true
        else
            warn(string.format("❌ Remote failed for %s - %s: %s", tierName, chestNumber, remoteResult))
        end

        wait(0.3)
    end

    Window:Notify({Title = "Auto Chest", Desc = "Finished " .. tierName .. " collection.", Time = 3})
    return true
end

local function collectChests()
    if FarmAllTiers then
        for _, tierName in ipairs(TIER_LIST) do
            if not AutoChestEnabled then break end
            Window:Notify({Title = "Auto Chest", Desc = "Moving to " .. tierName, Time = 2})
            collectTier(tierName)
            wait(0.5)
        end
        if AutoChestEnabled then
            Window:Notify({Title = "Auto Chest", Desc = "All tiers completed!", Time = 3})
        end
    else
        collectTier(SelectedTier)
    end
    
    if AutoChestEnabled then
        AutoChestEnabled = false
        disableNoclip()
    end
end

-- ========== UI ELEMENTS ==========
Tab:Dropdown({
    Title = "Select Tier",
    Desc = "Choose which tier to collect (ignored if Farm All is on)",
    List = TIER_LIST,
    Value = "Tier 1",
    Callback = function(choice)
        SelectedTier = choice
        print("Selected tier:", SelectedTier)
    end
})

Tab:Toggle({
    Title = "Farm All Tiers",
    Desc = "Automatically farm Tier 1 → Tier 2 → Tier 3",
    Value = false,
    Callback = function(v)
        FarmAllTiers = v
        print("Farm All Tiers:", v)
    end
})

Tab:Slider({
    Title = "Tween Speed",
    Desc = "Movement speed (studs per second)",
    Min = 50,
    Max = 500,
    Value = 100,
    Callback = function(v)
        TweenSpeed = v
        print("Tween speed set to:", TweenSpeed)
    end
})

Tab:Toggle({
    Title = "Auto Chest",
    Desc = "Start/Stop chest collection (with vehicle noclip – works for boats in Tubes)",
    Value = false,
    Callback = function(v)
        if v then
            stopAutoChest()
            AutoChestEnabled = true
            enableNoclip()
            AutoChestCoroutine = coroutine.create(collectChests)
            coroutine.resume(AutoChestCoroutine)
        else
            stopAutoChest()
        end
    end
})

-- ========== NOTIFICATION ==========
Window:Notify({
    Title = "UI Loaded",
    Desc = "Auto Chest Farm ready! (Vehicle noclip + Tubes support)",
    Time = 3
})

print("✅ Auto Chest Farm fully loaded! Speed: " .. TweenSpeed .. ", All Tiers: " .. tostring(FarmAllTiers))
