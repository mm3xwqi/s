local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local SETTINGS_FILE = "Fischsv.json"

local Settings = {
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    AutoSell = false,
    TpToIsland = false,
    SelectedIsland = nil,
    SavedPosition = nil,
    ReelMethod = "Perfect",
    ReelMethod2 = "Instant"
}

if pcall(function() return readfile(SETTINGS_FILE) end) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    if success and data then
        for k,v in pairs(data) do Settings[k] = v end
    end
end

local savedPosition = nil
if Settings.SavedPosition then
    local sp = Settings.SavedPosition
    if sp.X and sp.Y and sp.Z then
        savedPosition = CFrame.new(sp.X, sp.Y, sp.Z)
    end
end

local function SaveSettings()
    pcall(function()
        local dataToSave = {}

        for k,v in pairs(Settings) do
            dataToSave[k] = v
        end

        if savedPosition then
            local pos = savedPosition.Position
            dataToSave.SavedPosition = {X=pos.X, Y=pos.Y, Z=pos.Z}
        else
            dataToSave.SavedPosition = nil
        end

        writefile(SETTINGS_FILE, HttpService:JSONEncode(dataToSave))
    end)
end

local autocast = Settings.AutoCast
local autoreel = Settings.AutoReel
local reelMethod = Settings.ReelMethod
local autoshake = Settings.AutoShake
local autosell = Settings.AutoSell
local teleporting = Settings.TpToIsland
local selectedIsland = Settings.SelectedIsland
local savedPosition = Settings.SavedPosition
local reelMethod2 = Settings.ReelMethod2 or "Instant"

-- ================== Teleport spots ==================
local tpFolder = workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")

local tpNames = {}
for _, spot in ipairs(tpFolder:GetChildren()) do
    table.insert(tpNames, spot.Name)
end
table.sort(tpNames, function(a,b) return a:lower() < b:lower() end)

-- ================== UI library ==================
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))();
local Windows = NothingLibrary.new({
    Title = "Fisch 0.0.1",
    Description = "Alpha",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

-- Create tabs & sections (use the same 'Windows' object)
local TabFrame = Windows:NewTab({Title = "Main", Description = "etc", Icon = "rbxassetid://7733960981"})
local Section = TabFrame:NewSection({Title = "Farms", Icon = "rbxassetid://7743869054", Position = "Left"})

local TabFrame2 = Windows:NewTab({Title = "Teleport", Description = "Islands", Icon = ""})
local Section2 = TabFrame2:NewSection({Title = "Teleport", Icon = "rbxassetid://7743869054", Position = "Left"})

local TabFrame3 = Windows:NewTab({Title = "Setting Farm", Description = "Method", Icon = ""})
local Section3 = TabFrame3:NewSection({Title = "Reel Settings", Icon = "rbxassetid://7743869054", Position = "Left"})

-- ================== Helper functions ==================
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

-- ================== Auto Cast ==================
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
            task.wait()
        end
    end)
end

-- ================== Auto Reel ==================
--local autoreel_running = false
--local function StartAutoReel()
 --   if autoreel_running then return end
 --   autoreel_running = true
 --   task.spawn(function()
 --       while autoreel do
 --           pcall(function()
 --               local isPerfect
 --               if reelMethod == "Perfect" then
 --                   isPerfect = true
 --               elseif reelMethod == "Random" then
 --                   isPerfect = (math.random(0,1) == 1)
 --               else
 --                   isPerfect = true
  --              end
--
  --              ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, isPerfect)
  --          end)
 --           task.wait(0.1)
 --       end
 --       autoreel_running = false
 --   end)
--end

-- ================== Auto Shake ==================
local autoshake_running = false
local function StartAutoShake()
    if autoshake_running then return end
    autoshake_running = true
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
        autoshake_running = false
    end)
end

-- ================== Auto Sell ==================
local autosell_running = false
local function StartAutoSell()
    if autosell_running then return end
    autosell_running = true
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
                    ReplicatedStorage:WaitForChild("events"):WaitForChild("SellAll"):InvokeServer(unpack(args))
                end)
            end
            task.wait(1)
        end
        autosell_running = false
    end)
end

-- ================== Teleport ==================
local teleport_running = false
local function StartTeleport()
    if teleport_running then return end
    teleport_running = true
    task.spawn(function()
        while teleporting do
            local hrp = GetHumanoidRootPart()
            local spot = tpFolder:FindFirstChild(selectedIsland)
            if hrp and spot then
                pcall(function() hrp.CFrame = spot.CFrame + Vector3.new(0,5,0) end)
            end
            task.wait()
        end
        teleport_running = false
    end)
end

-- ================== Reel Method 2 (Legit / Instant) ==================
local autoreel_running = false

local function StartAutoReel()
    if autoreel_running then return end
    autoreel_running = true
    task.spawn(function()
        while autoreel do
            local gui = player:FindFirstChild("PlayerGui")
            local reel = gui and gui:FindFirstChild("reel")
            local bar = reel and reel:FindFirstChild("bar")
            local fish = bar and bar:FindFirstChild("fish")
            local playerbar = bar and bar:FindFirstChild("playerbar")

            pcall(function()
                if reelMethod2 == "Legit" then
                    if fish and playerbar then
                        playerbar.Position = fish.Position
                    end
                elseif reelMethod2 == "Instant" then
                    local isPerfect
                    if reelMethod == "Perfect" then
                        isPerfect = true
                    elseif reelMethod == "Random" then
                        isPerfect = (math.random(0,1) == 1)
                    else
                        isPerfect = true
                    end
                    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, isPerfect)
                end
            end)

            task.wait()
        end
        autoreel_running = false
    end)
end

-- ================== UI (สร้าง Toggle/Dropdown) ==================
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

Section3:NewDropdown({
    Title = "Reel Method 2",
    Data = {"Legit", "Instant"},
    Default = reelMethod2 or "Legit",
    Callback = function(choice)
        reelMethod2 = choice
        Settings.ReelMethod2 = choice
        SaveSettings()

        if autoreel then
            autoreel_running = false
            StartAutoReel()
        end

        if reelMethod2 == "Instant" then
            local isPerfect = (reelMethod == "Perfect") or (reelMethod == "Random" and math.random(0,1) == 1)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, isPerfect)
            end)
        end
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
        if hrp then
            savedPosition = hrp.CFrame
            Settings.SavedPosition = savedPosition
            SaveSettings()
            print("Saved Position:", savedPosition)
        end
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

-- ================== Start any modes that were saved as on ==================
if autocast then StartAutoCast() end
if autoreel then StartAutoReel() end
if autoshake then StartAutoShake() end
if autosell then StartAutoSell() end
if teleporting then StartTeleport() end
