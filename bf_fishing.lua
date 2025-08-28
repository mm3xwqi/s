local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local notifGui = player:WaitForChild("PlayerGui"):WaitForChild("Notifications")
local water = workspace:WaitForChild("Map"):WaitForChild("WaterBase-Plane")
local pos = water.Position
local req = game:GetService("ReplicatedStorage"):WaitForChild("FishReplicated"):WaitForChild("FishingRequest")

local sellRF = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/JobsRemoteFunction")
local craftRF = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft")

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("WASD", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)
local tab = win:Tab("Auto")

local Fishing = false

tab:Toggle("Auto Fishing", AutoFishing, function(state)
    AutoFishing = state
    if AutoFishing then
        task.spawn(function()
            while AutoFishing do
                req:InvokeServer("CastLineAtLocation", pos, 100, true)
                task.wait(.1)
                req:InvokeServer("Catching", true, {fastBite = false})
                task.wait(.1)
                req:InvokeServer("Catch", 1, 0, 1)
                task.wait(.1)
                req:InvokeServer("RemoveBobberFish")
                task.wait(.1)
            end
        end)
    end
end)


local tab2 = win:Tab("sell and buy bait")

local AutoSell = false

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


tab2:Toggle("Auto Craft Bait", AutoCraft, function(state)
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
local AutoNotif = false

tab2:Toggle("Disabled Notification", AutoNotif, function(state)
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
