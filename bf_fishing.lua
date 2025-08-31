local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local notifGui = player:WaitForChild("PlayerGui"):WaitForChild("Notifications")
local req = game:GetService("ReplicatedStorage"):WaitForChild("FishReplicated"):WaitForChild("FishingRequest")

local sellRF = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/JobsRemoteFunction")
local craftRF = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft")

local Fishing = false
local AutoSell = false
local AutoNotif = false
local autosc = false

local function getForwardCastPosition()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.new(0,0,0) end

    local forwardPos = hrp.Position + hrp.CFrame.LookVector * 35

    return forwardPos
end

local function equipRodWeapon()
    if not char or not player.Backpack then return end
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Rod") then
            tool.Parent = char
            return
        end
    end
end

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("CXSMIC 1.0.0.2", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)
local tab = win:Tab("Auto")

tab:Toggle("Auto Fishing", Fishing, function(state)
    Fishing = state
    if Fishing then
        task.spawn(function()
            while Fishing do
                equipRodWeapon()

                local pos = getForwardCastPosition()
                req:InvokeServer("CastLineAtLocation", pos, 100, true)
                print("[AutoFishing] throwed:", pos)

                task.wait(1)
                req:InvokeServer("Catching", true, {fastBite = false})
                task.wait(0.2)
                req:InvokeServer("Catch", 1, 0, 1)
                task.wait(0.2)
                req:InvokeServer("RemoveBobberFish")
                task.wait(1)
            end
        end)
    end
end)

local tab2 = win:Tab("sell and buy bait")

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
                if notifGui then
                    notifGui.Enabled = false
                end
                task.wait(0.5)
            end
        end)
    else
        if notifGui then
            notifGui.Enabled = true
        end
    end
end)

tab2:Toggle("Auto SellCorruptedFish", autosc, function(state)
    autosc = state
    if autosc then
        task.spawn(function()
            while autosc do
                local args = {
                    "FishingNPC",
                    "SellCorruptedFish"
                }
                sellRF:InvokeServer(unpack(args))
                task.wait(1)
            end
        end)
    end
end)

local ui = CoreGui:WaitForChild("ui")
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleUI"
toggleGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,120,0,45)
button.Position = UDim2.new(1,-150,1,-400)
button.BackgroundColor3 = Color3.fromRGB(50,50,50)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Text = ui.Enabled and "UI: ON" or "UI: OFF"
button.Parent = toggleGui

button.MouseButton1Click:Connect(function()
    if ui then
        ui.Enabled = not ui.Enabled
        button.Text = ui.Enabled and "UI: ON" or "UI: OFF"
    end
end)
