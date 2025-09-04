local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local char = player.Character or player.CharacterAdded:Wait()
local questGui = player:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Quest")
local notifGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Notifications")
local notifEnabled = true

local req = ReplicatedStorage:WaitForChild("FishReplicated"):WaitForChild("FishingRequest")
local sellRF = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/JobsRemoteFunction")
local craftRF = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/Craft")
local jobsRF = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/JobsRemoteFunction")

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

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "CXSMIC New UI!",
    Desc = "Welcome! Have fun using the cheat",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "MW"
    }
})

-- Sidebar Vertical Separator
local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0) -- adjust if needed
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui") -- Or Window.Gui if accessible

-- Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"})
    -- Section
    Tab:Section({Title = "Main"})

    -- Toggle
    Tab:Toggle({
        Title = "Auto Fishing",
        Desc = "",
        Value = false,
        Callback = function(state)
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
end
})

    Tab:Toggle({
        Title = "Auto Sell",
        Desc = "",
        Value = false,
        Callback = function(state)
            AutoSell = state
    if AutoSell then
        task.spawn(function()
            while AutoSell do
                sellRF:InvokeServer("FishingNPC", "SellFish")
                task.wait(1)
            end
        end)
end
end
})

    Tab:Toggle({
        Title = "Auto SellCorruptedFish",
        Desc = "Event Oni",
        Value = false,
        Callback = function(state)
                autosc = state
    if autosc then
        task.spawn(function()
            while autosc do
                sellRF:InvokeServer("FishingNPC", "SellCorruptedFish")
                task.wait(1)
            end
        end)
end
end
    })

    Tab:Toggle({
            Title = "Auto Craft Bait",
            Desc = "",
            Value = false,
            Callback = function(state)
                AutoCraft = state
        if AutoCraft then
            task.spawn(function()
                while AutoCraft do
                    craftRF:InvokeServer("Craft", "Basic Bait", {})
                    task.wait(1)
                end
            end)
        end
    end
})

    Tab:Toggle({
        Title = "Auto Quest",
        Desc = "Unlock Rods",
        Value = false,
        Callback = function(state)
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
end
})

    -- Button
Tab:Button({
    Title = "Save Fishing Spot",
    Desc = "",
    Callback = function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            savedSpot = hrp.CFrame
            local pos = hrp.Position

            Window:Notify({
                Title = "Save Fishing",
                Desc = "Save Success at: X="..math.floor(pos.X)..", Y="..math.floor(pos.Y)..", Z="..math.floor(pos.Z),
                Time = 3 
            })
        end
    end
})

Window:Line()

local Extra = Window:Tab({Title = "Teleport", Icon = ""}) do
    Extra:Section({Title = "Config"})
    
    Extra:Button({
        Title = "Teleport to Oni Temple",
        Desc = "",
        Callback = function()
        local args = { 
            "InitiateTeleportToTemple" 
                
            } 
            game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/OniTempleTransportation"):InvokeServer(unpack(args))
        end
    })
end

Window:Line()

-- Another Tab Example
local Extra = Window:Tab({Title = "Misc", Icon = "tag"})
    Extra:Section({Title = "About"})

Extra:Button({
    Title = "Notifications",
    Desc = "Click to enable/disable notifications",
    Callback = function()
        if notifGui then
            notifEnabled = not notifEnabled
            notifGui.Enabled = notifEnabled

            Window:Notify({
                Title = "Notifications",
                Desc = notifEnabled and "Notifications Enabled!" or "Notifications Disabled!",
                Time = 3
            })
        end
    end
})
