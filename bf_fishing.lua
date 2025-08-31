local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local char = player.Character or player.CharacterAdded:Wait()
local notifGui = player:WaitForChild("PlayerGui"):WaitForChild("Notifications")

local req = ReplicatedStorage:WaitForChild("FishReplicated"):WaitForChild("FishingRequest")
local sellRF = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/JobsRemoteFunction")
local craftRF = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft")
local jobsRF = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/JobsRemoteFunction")

local Fishing = false
local autoQuest = false
local AutoSell = false
local AutoNotif = false
local autosc = false
local savedSpot = nil
local rainbow = false

-- ==============================
-- Functions
-- ==============================

local function getForwardCastPosition()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.new(0, 0, 0) end
    return hrp.Position + hrp.CFrame.LookVector * 35
end

local function onCharacterAdded(newChar)
    char = newChar
    task.wait(1)
end
player.CharacterAdded:Connect(onCharacterAdded)

local function equipRodWeapon()
    if not char or not player.Backpack then return end
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Rod") then
            tool.Parent = char
            return
        end
    end
end

local function removeBodyVelocity()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChild("Lock")
        if bv then bv:Destroy() end
    end
end

local function tweenTo()
    while Fishing do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if savedSpot and hrp then
            local bv = hrp:FindFirstChild("Lock")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "Lock"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hrp
            end

            local distance = (hrp.Position - savedSpot.Position).Magnitude
            local speed = 350
            local travelTime = distance / speed

            local tween = TweenService:Create(hrp, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {CFrame = savedSpot})
            tween:Play()
            tween.Completed:Wait()
        end
        task.wait(0.1)
    end
end

-- ==============================
-- UI
-- ==============================

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("CXSMIC 1.2.0.6", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)
local tab = win:Tab("Auto")
local tab2 = win:Tab("sell and buy bait")

lib:Notification("Notification", "Welcome! Have fun using the cheat", "SURE")

-- ==============================
-- Auto Fishing Toggle
-- ==============================

tab:Toggle("Auto Fishing", Fishing, function(state)
    Fishing = state
    if Fishing then
        task.spawn(tweenTo)

        task.spawn(function()
            while Fishing do
                equipRodWeapon()

                local pos = getForwardCastPosition()
                req:InvokeServer("CastLineAtLocation", pos, 100, true)
                task.wait(1)
                req:InvokeServer("Catching", true, {fastBite = true})
                task.wait(0.2)
                req:InvokeServer("Catch", 1, 0, 1)
                task.wait(0.2)
                req:InvokeServer("RemoveBobberFish")

                game:GetService("ReplicatedStorage")
                    :WaitForChild("Modules")
                    :WaitForChild("Net")
                    :WaitForChild("RF/JobToolAbilities")
                    :InvokeServer("Z", true)

                task.wait(.5)
            end
            removeBodyVelocity()
        end)
    else
        removeBodyVelocity()
    end
end)
-- ==============================
-- Save Fishing Spot
-- ==============================

tab:Button("Save Fishing Spot", function()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        savedSpot = hrp.CFrame
        lib:Notification("Save Fishing Spot", "Spot saved!", "Ok")
    end
end)

-- ==============================
-- Auto Quest Toggle
-- ==============================

local questGui = player:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Quest")
tab:Toggle("Auto Quest", autoQuest, function(state)
    autoQuest = state
    if autoQuest then
        task.spawn(function()
            local jobsRF = game:GetService("ReplicatedStorage")
                :WaitForChild("Modules")
                :WaitForChild("Net")
                :WaitForChild("RF/JobsRemoteFunction")
            
            while autoQuest do
                local askArgs = {"FishingNPC", "Angler", "AskQuest"}
                local success, err = pcall(function()
                    jobsRF:InvokeServer(unpack(askArgs))
                end)
                if not success then warn("AskQuest failed:", err) end

                task.wait(0.5)

                local checkArgs = {"FishingNPC", "Angler", "CheckQuest"}
                local success2, err2 = pcall(function()
                    jobsRF:InvokeServer(unpack(checkArgs))
                end)
                if not success2 then warn("CheckQuest failed:", err2) end

                task.wait(2)
            end
        end)
    end
end)

-- ==============================
-- Teleport Button
-- ==============================

tab:Button("Teleport To OniTemple", function() 
local args = { 
"InitiateTeleportToTemple" 
    
} 
game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/OniTempleTransportation"):InvokeServer(unpack(args)) 
lib:Notification("Notification", "Success", "Done") 
end)

-- ==============================
-- Sell / Craft Toggles
-- ==============================

tab2:Toggle("Auto Sell Fish", AutoSell, function(state)
    AutoSell = state
    if AutoSell then
        task.spawn(function()
            while AutoSell do
                sellRF:InvokeServer("FishingNPC", "SellFish")
                task.wait(1)
            end
        end)
    end
end)

tab2:Toggle("Auto Craft Basic Bait", AutoCraft, function(state)
    AutoCraft = state
    if AutoCraft then
        task.spawn(function()
            while AutoCraft do
                craftRF:InvokeServer("Craft", "Basic Bait", {})
                task.wait(1)
            end
        end)
    end
end)

tab2:Toggle("Disable/Enable Notification", AutoNotif, function(state)
    AutoNotif = state
    if AutoNotif then
        task.spawn(function()
            while AutoNotif do
                if notifGui then notifGui.Enabled = false end
                task.wait(0.5)
            end
        end)
    else
        if notifGui then notifGui.Enabled = true end
    end
end)

tab2:Toggle("Auto SellCorruptedFish", autosc, function(state)
    autosc = state
    if autosc then
        task.spawn(function()
            while autosc do
                sellRF:InvokeServer("FishingNPC", "SellCorruptedFish")
                task.wait(1)
            end
        end)
    end
end)

-- ==============================
-- UI Color / Rainbow
-- ==============================

local changeclr = win:Tab("Change UI Color")
changeclr:Toggle("Rainbow UI", false, function(state)
    rainbow = state
    if rainbow then
        task.spawn(function()
            local hue = 0
            while rainbow do
                hue = (hue + 0.005) % 1
                local rainbowColor = Color3.fromHSV(hue, 1, 1)
                lib:ChangePresetColor(rainbowColor)
                task.wait(0.03)
            end
        end)
    end
end)

-- ==============================
-- Toggle UI Button
-- ==============================

local ui = CoreGui:WaitForChild("ui")
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleUI"
toggleGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 45)
button.Position = UDim2.new(1, -150, 1, -400)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = ui.Enabled and "UI: ON" or "UI: OFF"
button.Parent = toggleGui

button.MouseButton1Click:Connect(function()
    if ui then
        ui.Enabled = not ui.Enabled
        button.Text = ui.Enabled and "UI: ON" or "UI: OFF"
    end
end)
