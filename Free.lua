_G.AutoFish = not _G.AutoFish
print("_G.AutoFish:", _G.AutoFish)
_G.ReelMethod = "Instant" -- "Instant" or "Smooth"

local Collection = {} 
Collection.__index = Collection

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local events = ReplicatedStorage:FindFirstChild("events")
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
local packages = ReplicatedStorage:FindFirstChild("packages")
local Net = packages:FindFirstChild("Net")
local RE_Backpack_Equip = Net:FindFirstChild("RE/Backpack/Equip")

-- Assuming the rod name is tied to the player's stats
local rod_name = LocalPlayer.PlayerStats[player.Name].Stats.rod.Value
local equipped_rod = LocalPlayer.Character:FindFirstChild(rod_name)

function Collection:fireclickbutton(button)
    if not button then return end
    xpcall(function()
        local VisibleUI = playerGui:FindFirstChild("_") or Instance.new("Frame")
        VisibleUI.Name = "_"
        VisibleUI.BackgroundTransparency = 1
        VisibleUI.Parent = playerGui
        playerGui.SelectionImageObject = VisibleUI
        GuiService.SelectedObject = button
        VirtualInputManager:SendKeyEvent(true, 'Return', false, game)
        VirtualInputManager:SendKeyEvent(false, 'Return', false, game)
    end, warn)
end

while (_G.AutoFish and task.wait()) do
    local success, err = pcall(function()
        if LocalPlayer.PlayerGui:FindFirstChild("reel") then
            if (_G.ReelMethod == "Instant") then
                events["reelfinished "]:FireServer(100, false)
                pcall(function()
                    LocalPlayer.Character[rod_name].events.reset:FireServer()
                end)
            else
                LocalPlayer.PlayerGui.reel.bar.playerbar.Position = UDim2.new(LocalPlayer.PlayerGui.reel.bar.fish.Position.X.Scale, LocalPlayer.PlayerGui.reel.bar.fish.Position.X.Offset, LocalPlayer.PlayerGui.reel.bar.fish.Position.Y.Scale, LocalPlayer.PlayerGui.reel.bar.fish.Position.Y.Offset)
            end
        else
            if LocalPlayer.PlayerGui:FindFirstChild("shakeui") then
                print("Click the button")
                if LocalPlayer.PlayerGui["shakeui"]:FindFirstChild("safezone"):FindFirstChild("button") then
                    Collection:fireclickbutton(LocalPlayer.PlayerGui["shakeui"]["safezone"]["button"])
                end
            else
                if LocalPlayer.Character:FindFirstChild(rod_name) then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-4283.25049, -996.260437, 2156.16602, 0.990811765, 8.07792375e-08, 0.135247916, -7.54419887e-08, 1, -4.4587928e-08, -0.135247916, 3.39748709e-08, 0.990811765)
                    if (LocalPlayer.Character.HumanoidRootPart.Position - CFrame.new(-4283.25049, -996.260437, 2156.16602).Position).Magnitude < 5 then
                        LocalPlayer.Character[rod_name].events.cast:FireServer(math.random(95,100), 1)
                    end
                else
                    if LocalPlayer.Backpack:FindFirstChild(rod_name) then
                        RE_Backpack_Equip:FireServer(LocalPlayer.Backpack:FindFirstChild(rod_name))
                        if LocalPlayer.Character:FindFirstChild(rod_name) then
                            LocalPlayer.Character[rod_name].events.reset:FireServer()
                        end 
                        wait(.5)
                    else
                        print("No rod found")
                    end
                end
            end
        end
    end)
    if err then
        warn("Caught error: " .. err)
    end
end

-- # // Copy HumanoidRootPart Position
setclipboard(tostring(LocalPlayer.Character.HumanoidRootPart.CFrame))
