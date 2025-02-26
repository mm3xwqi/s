-- credit Deity Hub

_G.AutoFish = not _G.AutoFish ; print("_G.AutoFish:",_G.AutoFish)
_G.ReelMethod = "Instant" -- "Instant" or "Smooth"
_G.FishingRod = "Zeus Rod"

local Collection = {} ; Collection.__index = Collection

local Players = game:GetService("Players") 
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local events = ReplicatedStorage:FindFirstChild("events")
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
local packages = ReplicatedStorage:FindFirstChild("packages")
local Net = packages:FindFirstChild("Net")
local RE_Backpack_Equip = Net:FindFirstChild("RE/Backpack/Equip")

function Collection:fireclickbutton(button)
	if not button then return end 
	xpcall(function()
		local VisibleUI = playerGui:FindFirstChild("") or Instance.new("Frame")
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
                    LocalPlayer.Character[_G.FishingRod].events.reset:FireServer()
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
                if LocalPlayer.Character:FindFirstChild(_G.FishingRod) then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2517.10181, -11223.1348, 6930.07373, -0.518772662, 1.07716094e-08, -0.854912221, -2.59621729e-08, 1, 2.83538757e-08, 0.854912221, 3.69045949e-08, -0.518772662)
                    if (LocalPlayer.Character.HumanoidRootPart.Position - CFrame.new(-2517.10181, -11223.1348, 6930.07373).Position).Magnitude < 5 then
                        LocalPlayer.Character[_G.FishingRod].events.cast:FireServer(math.random(1,25), 1)
                    end
                else
                    if LocalPlayer.Backpack:FindFirstChild(_G.FishingRod) then
                        RE_Backpack_Equip:FireServer(LocalPlayer.Backpack:FindFirstChild(_G.FishingRod))
                        if LocalPlayer.Character:FindFirstChild(_G.FishingRod) then
                            LocalPlayer.Character[_G.FishingRod].events.reset:FireServer()
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

