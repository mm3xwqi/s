local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humroot = char:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shakeRemote = ReplicatedStorage:WaitForChild("resources")
    .replicated
    .fishing
    .shakeui
    .safezone
    .shakeui
    .button
    .shake


local function EquipRods()
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Rod") then
            tool.Parent = player.Character
        end
    end

    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Rod") then
            tool.Parent = player.Character
        end
    end
end

local tpFolder = workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")

local tpNames = {}
for _, spot in ipairs(tpFolder:GetChildren()) do
    table.insert(tpNames, spot.Name)
end
table.sort(tpNames, function(a, b)
    return a:lower() < b:lower()
end)

local selectedIsland = tpNames[1] or nil

local autocast = false
local autoreel = false
local autoshake = false

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))();
local Windows = NothingLibrary.new({
	Title = "test",
	Description = "Alpha",
	Keybind = Enum.KeyCode.LeftControl,
	Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

local TabFrame = Windows:NewTab({
	Title = "Main",
	Description = "etc",
	Icon = "rbxassetid://7733960981"
})

local Section = TabFrame:NewSection({
	Title = "Farms",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})


Section:NewToggle({
    Title = "Auto Farm",
    Default = false,
    Callback = function(state)
        autocast = state
        if autocast then
            task.spawn(function()
                while autocast do
                    local char = player.Character
                    if not char or not char.Parent then
                        char = player.CharacterAdded:Wait()
                    end

                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and savedPosition then
                        pcall(function()
                            hrp.CFrame = savedPosition
                        end)
                    end

                    local rod = nil
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and string.find(tool.Name, "Rod") then
                            rod = tool
                            break
                        end
                    end

                    if not rod then
                        EquipRods()
                    else
                        local events = rod:FindFirstChild("events")
                        local cast = events and events:FindFirstChild("cast")
                        if cast then
                            cast:FireServer(100, true)
                        end
                    end

                    task.wait(.2)
                end
            end)
        end
    end,
})

Section:NewButton({
    Title = "Save Position",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        savedPosition = hrp.CFrame
    end,
})

Section:NewToggle({
    Title = "Auto Reel",
    Default = false,
    Callback = function(state)
        autoreel = state
        if autoreel then
            task.spawn(function()
                while autoreel do
                    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, true)
                    task.wait(.1)
                end
            end)
        end
    end,
})

Section:NewToggle({
    Title = "Auto shake",
    Default = false,
    Callback = function(state)
        autoshake = state
        if autoshake then
            task.spawn(function()
                local player = game:GetService("Players").LocalPlayer

                while autoshake do
                    local shakeButton = player.PlayerGui:FindFirstChild("shakeui")
                    shakeButton = shakeButton and shakeButton:FindFirstChild("safezone")
                    shakeButton = shakeButton and shakeButton:FindFirstChild("button")
                    shakeButton = shakeButton and shakeButton:FindFirstChild("shake")

                    if shakeButton then
                        shakeButton:FireServer()
                    end

                    task.wait(0.05)
                end
            end)
        end
    end,
})

Section:NewDropdown({
    Title = "Select Islands",
    Data = tpNames,
    Default = selectedIsland,
    Callback = function(choice)
        selectedIsland = choice
    end,
})

Section:NewToggle({
    Title = "Tp to island",
    Default = false,
    Callback = function(state)
        if state == teleporting then return end
        teleporting = state

        if teleporting then
            task.spawn(function()
                while teleporting do
                    local char = player.Character
                    if not char or not char.Parent then
                        char = player.CharacterAdded:Wait()
                    end

                    local success, hrp = pcall(function()
                        return char:WaitForChild("HumanoidRootPart", 10)
                    end)

                    local spot = tpFolder:FindFirstChild(selectedIsland)
                    if success and hrp and hrp:IsA("BasePart") and spot and spot:IsA("BasePart") then
                        pcall(function()
                            hrp.CFrame = spot.CFrame + Vector3.new(0, 5, 0)
                        end)
                    end

                    task.wait()
                end
            end)
        end
    end,
})
