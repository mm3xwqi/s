local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ================== Settings ==================
local SETTINGS_FILE = "FishingAutoSettings.json"

local Settings = {
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    AutoSell = false,
    TpToIsland = false,
    SelectedIsland = nil,
    SavedPosition = nil,
    ReelMethod = "Perfect"
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
local reelMethod = Settings.ReelMethod
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
    Title = "Fisch 0.0.1",
    Description = "Alpha",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
})
local TabFrame = Windows:NewTab({Title = "Main", Description = "etc", Icon = "rbxassetid://7733960981"})
local Section = TabFrame:NewSection({Title = "Farms", Icon = "rbxassetid://7743869054", Position = "Left"})
local TabFrame2 = Windows2:NewTab({Title = "Teleport",Description = "Islands",Icon = ""})
local Section2 = TabFrame2:NewSection({Title = "Section",Icon = "rbxassetid://7743869054",Position = "Left"})
local TabFrame3 = Windows3:NewTab({Title = "Setting Farm",Description = "Method",Icon = ""})
local Section3 = TabFrame3:NewSection({Title = "Section",Icon = "rbxassetid://7743869054",Position = "Left"})


local function EquipRods()
    local char = player.Character or player.CharacterAdded:Wait()
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Rod") then
            tool.Parent = char
        end
    end
end

local function GetHumanoidRootPart()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function StartAutoCast()
    task.spawn(function()
        while autocast do
            local hrp = GetHumanoidRootPart()
            if hrp and savedPosition then
                pcall(function() hrp.CFrame = savedPosition end)
            end

            local char = player.Character
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
                local cast = rod:FindFirstChild("events") and rod.events:FindFirstChild("cast")
                if cast then
                    pcall(function() cast:FireServer(100,true) end)
                end
            end
            task.wait(0.2)
        end
    end)
end

-- ================== Auto Reel ==================
local function StartAutoReel()
    task.spawn(function()
        while autoreel do
            pcall(function()
                local isPerfect
                if reelMethod == "Perfect" then
                    isPerfect = true
                elseif reelMethod == "Random" then
                    isPerfect = (math.random(0,1) == 1)
                end

                game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, isPerfect)
            end)
            task.wait(0.1)
        end
    end)
end

-- ================== Auto Shake ==================
local function StartAutoShake()
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

-- ================== Auto Sell ==================
local function StartAutoSell()
    task.spawn(function()
        while autosell do
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
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer(unpack(args))
                end)
            end
            task.wait(1)
        end
    end)
end

-- ================== Teleport ==================
local function StartTeleport()
    task.spawn(function()
        while teleporting do
            local hrp = GetHumanoidRootPart()
            local spot = tpFolder:FindFirstChild(selectedIsland)
            if hrp and spot then
                pcall(function() hrp.CFrame = spot.CFrame + Vector3.new(0,5,0) end)
            end
            task.wait()
        end
    end)
end

-- ================== UI ==================
Section:NewToggle({
    Title = "Auto Cast",
    Default = autocast,
    Callback = function(state)
        autocast = state
        Settings.AutoCast = state
        SaveSettings()
        if autocast then StartAutoCast() end
    end
})

Section:NewToggle({
    Title = "Auto Reel",
    Default = autoreel,
    Callback = function(state)
        autoreel = state
        Settings.AutoReel = state
        SaveSettings()
        if autoreel then StartAutoReel() end
    end
})

Section3:NewDropdown({
    Title = "Reel Method",
    Data = {"Perfect", "Random"},
    Default = reelMethod or "Perfect",
    Callback = function(choice)
        reelMethod = choice
        Settings.ReelMethod = choice
        SaveSettings()
    end
})

Section:NewToggle({
    Title = "Auto Shake",
    Default = autoshake,
    Callback = function(state)
        autoshake = state
        Settings.AutoShake = state
        SaveSettings()
        if autoshake then StartAutoShake() end
    end
})

Section:NewToggle({
    Title = "Auto Sell",
    Default = autosell,
    Callback = function(state)
        autosell = state
        Settings.AutoSell = state
        SaveSettings()
        if autosell then StartAutoSell() end
    end
})

Section:NewButton({
    Title = "Save Position",
    Callback = function()
        local hrp = GetHumanoidRootPart()
        savedPosition = hrp.CFrame
        Settings.SavedPosition = savedPosition
        SaveSettings()
        print("Saved Position:", savedPosition)
    end
})

Section2:NewDropdown({
    Title = "Select Islands",
    Data = tpNames,
    Default = selectedIsland or tpNames[1],
    Callback = function(choice)
        selectedIsland = choice
        Settings.SelectedIsland = choice
        SaveSettings()
    end
})

Section2:NewToggle({
    Title = "Tp to Island",
    Default = teleporting,
    Callback = function(state)
        teleporting = state
        Settings.TpToIsland = state
        SaveSettings()
        if teleporting then StartTeleport() end
    end
})

if autocast then StartAutoCast() end
if autoreel then StartAutoReel() end
if autoshake then StartAutoShake() end
if autosell then StartAutoSell() end
if teleporting then StartTeleport() end
