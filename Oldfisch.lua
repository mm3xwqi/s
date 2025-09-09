local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local fishingZoneFolder = workspace:WaitForChild("zones"):WaitForChild("fishing")
local fishingZones = {"Isonade", "Orcas Pool"}

local noclipEnabled = false
local infinityJumpEnabled = false
local walkspeedValue = 16
local jumppowerValue = 50

local SETTINGS_FILE = "Fischsv.json"

local Settings = {
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    AutoSell = false,
    TpToIsland = false,
    SelectedIsland = nil,
    SavedPosition = nil,
    CatchMethod = "Perfect",
    ReelMethod = "Instant",
    WalkOnWater = false
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
local CatchMethod = Settings.CatchMethod
local autoshake = Settings.AutoShake
local autosell = Settings.AutoSell
local teleporting = Settings.TpToIsland
local selectedIsland = Settings.SelectedIsland
local savedPosition = Settings.SavedPosition
local reelMethod = Settings.ReelMethod or "Instant"
local walkOnWaterEnabled = Settings.WalkOnWater or false

local tpFolder = workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")

local tpNames = {}
for _, spot in ipairs(tpFolder:GetChildren()) do
    table.insert(tpNames, spot.Name)
end
table.sort(tpNames, function(a,b) return a:lower() < b:lower() end)

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))();
local Windows = NothingLibrary.new({
    Title = "Fisch 0.0.3",
    Description = "Alpha",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

local TabFrame = Windows:NewTab({Title = "Main", Description = "etc", Icon = "rbxassetid://7733960981"})
local Section = TabFrame:NewSection({Title = "Farms", Icon = "rbxassetid://7743869054", Position = "Left"})

local TabFrame2 = Windows:NewTab({Title = "Local Player", Description = "Islands", Icon = ""})
local Section2 = TabFrame2:NewSection({Title = "Player", Icon = "rbxassetid://7743869054", Position = "Left"})
local SectionRight = TabFrame2:NewSection({
    Title = "Player",
    Icon = "rbxassetid://7743869054",
    Position = "Right"
})

local TabFrame3 = Windows:NewTab({Title = "Setting Farm", Description = "Method", Icon = ""})
local Section3 = TabFrame3:NewSection({Title = "Reel Settings", Icon = "rbxassetid://7743869054", Position = "Left"})

local TabFrame4 = Windows:NewTab({Title = "Teleport", Description = "Player Settings", Icon = ""})
local Section4 = TabFrame4:NewSection({Title = "Teleport", Icon = "rbxassetid://7743869054", Position = "Left"})


local rodNames = {}
local rodsFolder = ReplicatedStorage:WaitForChild("resources"):WaitForChild("items"):WaitForChild("rods")
for _, rod in ipairs(rodsFolder:GetChildren()) do
    table.insert(rodNames, rod.Name)
end

local function EquipRods()
    local char = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack")

    for _, rodName in ipairs(rodNames) do
        local hasRodInChar = false
        local hasRodInBackpack = false

        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == rodName then
                hasRodInChar = true
                break
            end
        end

        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == rodName then
                hasRodInBackpack = true
                break
            end
        end

        if not hasRodInChar and hasRodInBackpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == rodName then
                    tool.Parent = char
                    break
                end
            end
        end
    end
end

local function GetHumanoidRootPart()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local autocast_running = false
local teleport_running = false

local function StartAutoCastThrow()
    if autocast_running then return end
    autocast_running = true
    task.spawn(function()
        while autocast do
            EquipRods()

            local char = player.Character
            local rod = nil
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and table.find(rodNames, tool.Name) then
                    rod = tool
                    break
                end
            end

            if rod then
                local cast = rod:FindFirstChild("events") and rod.events:FindFirstChild("cast")
                if cast then
                    pcall(function() cast:FireServer(100,true) end)
                end
            end

            task.wait(0.3)
        end
        autocast_running = false
    end)
end

local function TeleportNoFall(targetCFrame)
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    humanoid.PlatformStand = true
    hrp.CFrame = targetCFrame + Vector3.new(0,110,0)

    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if hrp and humanoid.PlatformStand then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.CFrame = hrp.CFrame
        else
            if connection then
                connection:Disconnect()
            end
        end
    end)

    task.delay(0.1, function()
        if humanoid then
            humanoid.PlatformStand = false
        end
    end)
end

local function StartAutoCastTeleport()
    if teleport_running then return end
    teleport_running = true
    task.spawn(function()
        while autocast do
            local hrp = GetHumanoidRootPart()
            if hrp then
                if Settings.SelectedFishingZone and Settings.SelectedFishingZone ~= "None" then
                    local fishingZone = workspace:WaitForChild("zones"):WaitForChild("fishing")
                    local zonePart = fishingZone:FindFirstChild(Settings.SelectedFishingZone)
                    if zonePart and zonePart:IsA("BasePart") then
                        TeleportNoFall(zonePart.CFrame)
                    end
                elseif savedPosition then
                    TeleportNoFall(savedPosition)
                end
            end
            task.wait()
        end
        teleport_running = false
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
                if reelMethod == "Legit" then
                    if fish and playerbar then
                        playerbar.Position = fish.Position
                    end
                elseif reelMethod == "Instant" then
                    local isPerfect
                    if CatchMethod == "Perfect" then
                        isPerfect = true
                    elseif CatchMethod == "Random" then
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

local function SetWalkOnWater(state)
    walkOnWaterEnabled = state
    Settings.WalkOnWater = state
    SaveSettings()

    local fishingZone = workspace:WaitForChild("zones"):WaitForChild("fishing")
    for _, part in ipairs(fishingZone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = walkOnWaterEnabled
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
            StartAutoCastThrow()
            StartAutoCastTeleport()
        end
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
    Title = "Catch Method",
    Data = {"Perfect", "Random"},
    Default = CatchMethod or "Perfect",
    Callback = function(choice)
        CatchMethod = choice
        Settings.CatchMethod = choice
        SaveSettings()
    end
})

Section3:NewDropdown({
    Title = "Reel Method",
    Data = {"Legit", "Instant"},
    Default = reelMethod or "Legit",
    Callback = function(choice)
        reelMethod = choice
        Settings.ReelMethod = choice
        SaveSettings()

        if autoreel then
            autoreel_running = false
            StartAutoReel()
        end

        if reelMethod == "Instant" then
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

Section:NewDropdown({
    Title = "Select Fishing Zone",
    Data = fishingZones,
    Default = Settings.SelectedFishingZone or "None",
    Callback = function(choice)
        Settings.SelectedFishingZone = choice
        SaveSettings()
    end
})

Section:NewButton({
    Title = "Save Position",
    Callback = function()
        local hrp = GetHumanoidRootPart()
        if hrp then
            savedPosition = hrp.CFrame
            local pos = savedPosition.Position
            Settings.SavedPosition = {X=pos.X, Y=pos.Y, Z=pos.Z}
            SaveSettings()
            print("Saved Position:", savedPosition)
        end
    end
})

Section4:NewDropdown({
    Title = "Select Islands",
    Data = tpNames,
    Default = selectedIsland or tpNames[1],
    Callback = function(choice)
        selectedIsland = choice
        Settings.SelectedIsland = choice
        SaveSettings()
    end
})

Section4:NewToggle({
    Title = "Tp to Island",
    Default = teleporting,
    Callback = function(state)
        teleporting = state
        Settings.TpToIsland = state
        SaveSettings()
        if teleporting then StartTeleport() end
    end
})

Section2:NewSlider({
    Title = "Walkspeed",
    Min = 15,
    Max = 500,
    Default = 16,
    Callback = function(value)
        walkspeedValue = value
    end
})

Section2:NewSlider({
    Title = "Jumppower",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(value)
        jumppowerValue = value
    end
})

local changePlayerEnabled = false
Section2:NewToggle({
    Title = "Change Player",
    Default = false,
    Callback = function(state)
        changePlayerEnabled = state
    end
})

SectionRight:NewToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
    end
})

SectionRight:NewToggle({
    Title = "Infinity Jump",
    Default = false,
    Callback = function(state)
        infinityJumpEnabled = state
    end
})

local walkOnWaterEnabled = true

SectionRight:NewToggle({
    Title = "Walk on Water",
    Default = walkOnWaterEnabled,
    Callback = function(state)
        SetWalkOnWater(state)
    end
})

SectionRight:NewButton({
    Title = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end
})


task.spawn(function()
    while true do
        task.wait(0.1)
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if changePlayerEnabled then
                    humanoid.WalkSpeed = walkspeedValue
                    humanoid.JumpPower = jumppowerValue
                end
            end

            if noclipEnabled then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infinityJumpEnabled then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

if autocast then StartAutoCast() end
if autoreel then StartAutoReel() end
if autoshake then StartAutoShake() end
if autosell then StartAutoSell() end
if teleporting then StartTeleport() end
if walkOnWaterEnabled then
    SetWalkOnWater(true)
end
