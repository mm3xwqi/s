local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ================== Setting ==================
local SETTINGS_FILE = "FishingAutoSettings.json"

local Settings = {
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
	AutoSell = false,
    TpToIsland = false,
    SelectedIsland = nil,
    SavedPosition = nil
}

if pcall(function() return readfile(SETTINGS_FILE) end) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    if success and data then
        Settings = data
    end
end

local function SaveSettings()
    writefile(SETTINGS_FILE, HttpService:JSONEncode(Settings))
end

local autocast = Settings.AutoCast
local autoreel = Settings.AutoReel
local autoshake = Settings.AutoShake
local autosell = Settings.AutoSell
local teleporting = Settings.TpToIsland
local selectedIsland = Settings.SelectedIsland
local savedPosition = Settings.SavedPosition

local tpFolder = workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")

local tpNames = {}
for _, spot in ipairs(tpFolder:GetChildren()) do
    table.insert(tpNames, spot.Name)
end
table.sort(tpNames, function(a,b) return a:lower() < b:lower() end)

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))();
local Windows = NothingLibrary.new({
	Title = "test",
	Description = "Alpha",
	Keybind = Enum.KeyCode.LeftControl,
	Logo = 'http://www.roblox.com/asset/?id=18898582662'
})
local TabFrame = Windows:NewTab({Title = "Main", Description = "etc", Icon = "rbxassetid://7733960981"})
local Section = TabFrame:NewSection({Title = "Farms", Icon = "rbxassetid://7743869054", Position = "Left"})

local function EquipRods()
    local char = player.Character or player.CharacterAdded:Wait()
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Rod") then
            tool.Parent = char
        end
    end
end


Section:NewToggle({
    Title = "Auto Cast",
    Default = autocast,
    Callback = function(state)
        autocast = state
        Settings.AutoCast = state
        SaveSettings()

        if autocast then
            task.spawn(function()
                while autocast do
                    local char = player.Character or player.CharacterAdded:Wait()
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp and savedPosition then
                        pcall(function() hrp.CFrame = savedPosition end)
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
                            pcall(function() cast:FireServer(100, true) end)
                        end
                    end

                    task.wait(0.2)
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
        Settings.SavedPosition = savedPosition
        SaveSettings()
        print("Saved Position:", savedPosition)
    end,
})

Section:NewToggle({
    Title = "Auto Reel",
    Default = autoreel,
    Callback = function(state)
        autoreel = state
        Settings.AutoReel = state
        SaveSettings()

        if autoreel then
            task.spawn(function()
                while autoreel do
                    local success, _ = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, true)
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end,
})

Section:NewToggle({
    Title = "Auto Shake",
    Default = autoshake,
    Callback = function(state)
        autoshake = state
        Settings.AutoShake = state
        SaveSettings()

        if autoshake then
            task.spawn(function()
                while autoshake do
                    local shakeButton = player.PlayerGui:FindFirstChild("shakeui")
                    shakeButton = shakeButton and shakeButton:FindFirstChild("safezone")
                    shakeButton = shakeButton and shakeButton:FindFirstChild("button")
                    shakeButton = shakeButton and shakeButton:FindFirstChild("shake")

                    if shakeButton then
                        pcall(function() shakeButton:FireServer() end)
                    end
                    task.wait(0.05)
                end
            end)
        end
    end,
})


Section:NewToggle({
    Title = "Auto Sell",
    Default = autosell,
    Callback = function(state)
        autosell = state
        Settings.AutoSell = state
        SaveSettings()

        if autosell then
            task.spawn(function()
                while autosell do
                    local success, err = pcall(function()
                        local npcFolder = workspace:WaitForChild("world"):WaitForChild("npcs")
                        local targetNpc = nil
                        for _, npc in ipairs(npcFolder:GetChildren()) do
                            if string.find(npc.Name, "Merchant") then
                                targetNpc = npc
                                break
                            end
                        end

                        if targetNpc then
                            local args = {{
                                voice = 12,
                                npc = targetNpc,
                                idle = targetNpc:WaitForChild("description"):WaitForChild("idle")
                            }}
                            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer(unpack(args))
                        end
                    end)
                    if not success then
                        warn("Auto Sell failed:", err)
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})
Section:NewDropdown({
    Title = "Select Islands",
    Data = tpNames,
    Default = selectedIsland or tpNames[1],
    Callback = function(choice)
        selectedIsland = choice
        Settings.SelectedIsland = choice
        SaveSettings()
    end,
})

Section:NewToggle({
    Title = "Tp to Island",
    Default = teleporting,
    Callback = function(state)
        teleporting = state
        Settings.TpToIsland = state
        SaveSettings()

        if teleporting then
            task.spawn(function()
                while teleporting do
                    local char = player.Character or player.CharacterAdded:Wait()
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local spot = tpFolder:FindFirstChild(selectedIsland)
                    if hrp and spot then
                        pcall(function() hrp.CFrame = spot.CFrame + Vector3.new(0,5,0) end)
                    end
                    task.wait()
                end
            end)
        end
    end,
})

if Settings.AutoCast then
    autocast = true
    Section:FindToggle("Auto Cast").SetState(autocast)
end
if Settings.AutoReel then
    autoreel = true
    Section:FindToggle("Auto Reel").SetState(autoreel)
end
if Settings.AutoShake then
    autoshake = true
    Section:FindToggle("Auto Shake").SetState(autoshake)
end
if Settings.AutoSell then
    autosell = true
    Section:FindToggle("Auto Sell").SetState(autosell)
end
if Settings.TpToIsland then
    teleporting = true
    Section:FindToggle("Tp to Island").SetState(teleporting)
end
