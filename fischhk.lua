-- Fischsv Hook Edition - Complete Stealth Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Stealth Initialization
local randomDelay = math.random(3, 8)
task.wait(randomDelay)

-- Settings Management
local SETTINGS_FILE = "Fischsv_Hook.json"

local DefaultSettings = {
    AutoCast = false,
    AutoReel = false,
    AutoEquipRod = false,
    AutoShake = false,
    AutoSell = false,
    TpToIsland = false,
    SelectedIsland = nil,
    SavedPosition = nil,
    CatchMethod = "Perfect",
    ReelMethod = "Legit(Safe to Use)",
    ShakeMethod = "Shake Normal",
    WalkOnWater = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    InfinityJump = false,
    Fly = false,
    Fullbright = false,
    AntiAFK = true,
    InstantBobberV1 = false,
    InstantBobberV2 = false
}

local Settings = table.clone(DefaultSettings)

-- Stealth Settings Load
if pcall(function() return readfile(SETTINGS_FILE) end) then
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(SETTINGS_FILE))
    end)
    if success and data then
        for k, v in pairs(data) do
            if DefaultSettings[k] ~= nil then
                Settings[k] = v
            end
        end
    end
end

local function SaveSettings()
    pcall(function()
        writefile(SETTINGS_FILE, HttpService:JSONEncode(Settings))
    end)
end

-- Game Data
local rodNames = {}
local rodsFolder = ReplicatedStorage:WaitForChild("resources"):WaitForChild("items"):WaitForChild("rods")
for _, rod in ipairs(rodsFolder:GetChildren()) do
    table.insert(rodNames, rod.Name)
end

local extraTPs = {
    {Name = "Carrot Garden", Position = Vector3.new(3744, -1116, -1108)},
    {Name = "Crystal Cove", Position = Vector3.new(1364, -612, 2472)},
    {Name = "Underground Music Venue", Position = Vector3.new(2043, -645, 2471)},
    {Name = "Castaway Cliffs", Position = Vector3.new (655, 179, -1793)},
    {Name = "Luminescent Cavern", Position = Vector3.new (-1016, -337, -4071)},
    {Name = "Crimson Cavern", Position = Vector3.new (-1013, -340, -4891)},
    {Name = "Oscar's Locker", Position = Vector3.new (266, -387, 3407)},
    {Name = "The Boom Ball", Position = Vector3.new (-1296, -900, -3479)}
}

local tpFolder = workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
local tpNames = {}

for _, spot in ipairs(tpFolder:GetChildren()) do
    table.insert(tpNames, spot.Name)
end

for _, tp in ipairs(extraTPs) do
    table.insert(tpNames, tp.Name)
end

table.sort(tpNames, function(a, b) return a:lower() < b:lower() end)

-- Master Hook System
local MasterHookSystem = {
    _hooks = {},
    _original = {},
    _enabled = true
}

function MasterHookSystem:HookMethod(obj, methodName, callback)
    if not self._enabled then return end
    
    local key = tostring(obj) .. ":" .. methodName
    if self._hooks[key] then return end

    local oldMethod = obj[methodName]
    self._original[key] = oldMethod

    obj[methodName] = function(self, ...)
        local args = {...}
        local shouldCallOriginal = callback(args, self)
        
        if shouldCallOriginal ~= false then
            return oldMethod(self, unpack(args))
        end
    end

    self._hooks[key] = true
end

function MasterHookSystem:HookRemoteEvent(remote, callback)
    self:HookMethod(remote, "FireServer", callback)
end

function MasterHookSystem:HookRemoteFunction(func, callback)
    self:HookMethod(func, "InvokeServer", callback)
end

function MasterHookSystem:RestoreAll()
    for key, oldMethod in pairs(self._original) do
        local parts = string.split(key, ":")
        local obj = loadstring("return " .. parts[1])()
        local methodName = parts[2]
        
        if obj and methodName then
            obj[methodName] = oldMethod
        end
    end
    self._hooks = {}
    self._original = {}
end

-- Main Hook Manager
local HookManager = {
    _initialized = false,
    _connections = {},
    _activeHooks = {}
}

function HookManager:Initialize()
    if self._initialized then return end
    
    self:SetupFishingHooks()
    self:SetupPlayerHooks()
    self:SetupMovementHooks()
    self:SetupUIHooks()
    self:SetupAntiDetection()
    
    self._initialized = true
end

-- Fishing Hooks
function HookManager:SetupFishingHooks()
    -- Hook Cast Events
    for _, rod in pairs(rodsFolder:GetChildren()) do
        local events = rod:FindFirstChild("events")
        if events then
            local castEvent = events:FindFirstChild("cast")
            if castEvent then
                MasterHookSystem:HookRemoteEvent(castEvent, function(args, self)
                    if Settings.AutoCast then
                        self:ScheduleNextCast()
                    end
                    return true
                end)
            end
        end
    end

    -- Hook Reel Finished
    local reelFinished = ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished")
    if reelFinished then
        MasterHookSystem:HookRemoteEvent(reelFinished, function(args, self)
            if Settings.AutoReel then
                self:HandleReelFinished(args)
            end
            return true
        end)
    end

    -- Hook Sell System
    local sellAll = ReplicatedStorage:WaitForChild("events"):WaitForChild("SellAll")
    if sellAll then
        MasterHookSystem:HookRemoteFunction(sellAll, function(args, self)
            if Settings.AutoSell then
                self:ScheduleAutoSell()
            end
            return true
        end)
    end

    -- Bobber Monitoring
    self._connections.characterAdded = player.CharacterAdded:Connect(function(char)
        task.wait(1)
        self:MonitorBobbers(char)
    end)
    
    if player.Character then
        self:MonitorBobbers(player.Character)
    end
end

function HookManager:ScheduleNextCast()
    task.spawn(function()
        local delay = 2.0 + math.random(0.5, 1.5)
        task.wait(delay)
        
        if not Settings.AutoCast then return end
        
        local char = player.Character
        if not char then return end
        
        -- Check for equipped rod without bobber
        for _, rodName in ipairs(rodNames) do
            local rod = char:FindFirstChild(rodName)
            if rod and not rod:FindFirstChild("bobber") then
                -- Auto equip if needed
                if Settings.AutoEquipRod then
                    self:EquipBestRod()
                end
                
                -- Cast with random delay
                task.wait(0.5 + math.random(0, 0.3))
                local castEvent = rod:FindFirstChild("events") and rod.events:FindFirstChild("cast")
                if castEvent then
                    local power = 95 + math.random(0, 10)
                    castEvent:FireServer(power, true)
                end
                break
            end
        end
    end)
end

function HookManager:HandleReelFinished(args)
    if Settings.ReelMethod == "Instant(Risk Ban)" then
        local isPerfect = Settings.CatchMethod == "Perfect" or 
                         (Settings.CatchMethod == "Random" and math.random(0, 1) == 1)
        ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, isPerfect)
    end
end

function HookManager:ScheduleAutoSell()
    task.spawn(function()
        local delay = 45 + math.random(0, 30)
        task.wait(delay)
        
        if Settings.AutoSell then
            ReplicatedStorage:WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
        end
    end)
end

function HookManager:MonitorBobbers(char)
    for _, rodName in ipairs(rodNames) do
        local rod = char:FindFirstChild(rodName)
        if rod then
            -- Monitor bobber addition
            self._connections["bobberAdded_" .. rodName] = rod.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "bobber" then
                    self:HandleBobberAdded(rod)
                end
            end)
            
            -- Monitor bobber removal
            self._connections["bobberRemoved_" .. rodName] = rod.DescendantRemoving:Connect(function(descendant)
                if descendant.Name == "bobber" then
                    self:HandleBobberRemoved()
                end
            end)
        end
    end
end

function HookManager:HandleBobberAdded(rod)
    -- Start shake if enabled
    if Settings.AutoShake then
        self:StartAutoShake()
    end
    
    -- Instant bobber positioning
    if Settings.InstantBobberV1 or Settings.InstantBobberV2 then
        task.spawn(function()
            while rod and rod:FindFirstChild("bobber") and (Settings.InstantBobberV1 or Settings.InstantBobberV2) do
                local bobber = rod:FindFirstChild("bobber")
                local char = player.Character
                if bobber and char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local targetPos = hrp.Position + Vector3.new(0, -3, 0)
                        bobber.CFrame = CFrame.new(targetPos)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end

function HookManager:HandleBobberRemoved()
    -- Schedule next cast if auto cast is enabled
    if Settings.AutoCast then
        task.delay(1.0 + math.random(0.5, 1.0), function()
            self:ScheduleNextCast()
        end)
    end
end

function HookManager:StartAutoShake()
    task.spawn(function()
        local PlayerGUI = player:WaitForChild("PlayerGui")
        local shakeUI = PlayerGUI:WaitForChild("shakeui")
        
        while shakeUI and shakeUI.Enabled and Settings.AutoShake do
            if Settings.ShakeMethod == "Shake Normal" then
                local safezone = shakeUI:FindFirstChild("safezone")
                local button = safezone and safezone:FindFirstChild("button")
                local shake = button and button:FindFirstChild("shake")
                
                if shake then
                    task.wait(0.15 + math.random(0, 0.1))
                    shake:FireServer()
                end
            elseif Settings.ShakeMethod == "Shake Fast(Not Safe)" then
                local safezone = shakeUI:FindFirstChild("safezone")
                local button = safezone and safezone:FindFirstChild("button")
                local shake = button and button:FindFirstChild("shake")
                
                if shake then
                    shake:FireServer()
                    task.wait(0.05)
                end
            end
            task.wait(0.1)
        end
    end)
end

function HookManager:EquipBestRod()
    local char = player.Character
    local backpack = player:WaitForChild("Backpack")
    
    if not char then return end
    
    -- Check if already has rod equipped
    for _, rodName in ipairs(rodNames) do
        if char:FindFirstChild(rodName) then
            return
        end
    end
    
    -- Equip best available rod
    for _, rodName in ipairs(rodNames) do
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == rodName then
                tool.Parent = char
                return
            end
        end
    end
end

-- Player Hooks
function HookManager:SetupPlayerHooks()
    -- Character monitoring
    self._connections.playerCharacter = player.CharacterAdded:Connect(function(char)
        task.wait(1)
        self:ApplyPlayerModifications(char)
    end)
    
    if player.Character then
        self:ApplyPlayerModifications(player.Character)
    end
    
    -- Humanoid property hooks
    self._connections.heartbeat = RunService.Heartbeat:Connect(function()
        self:UpdatePlayerProperties()
    end)
end

function HookManager:ApplyPlayerModifications(char)
    -- Walk on water
    if Settings.WalkOnWater then
        task.spawn(function()
            local fishingZone = workspace:WaitForChild("zones"):WaitForChild("fishing")
            for _, part in ipairs(fishingZone:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
    end
    
    -- Fullbright
    if Settings.Fullbright then
        self:ToggleFullbright(true)
    end
end

function HookManager:UpdatePlayerProperties()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        -- WalkSpeed and JumpPower
        humanoid.WalkSpeed = Settings.WalkSpeed
        humanoid.JumpPower = Settings.JumpPower
        
        -- Noclip
        if Settings.Noclip then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        -- Fly system
        if Settings.Fly then
            self:UpdateFlySystem(humanoid, rootPart)
        end
    end
end

function HookManager:UpdateFlySystem(humanoid, rootPart)
    if not rootPart then return end
    
    humanoid.PlatformStand = true
    
    local camera = workspace.CurrentCamera
    local controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local direction = controlModule:GetMoveVector()
    
    local speed = 100 * 50
    local vel = Vector3.new()
    vel = vel + camera.CFrame.RightVector * direction.X * speed
    vel = vel - camera.CFrame.LookVector * direction.Z * speed
    
    rootPart.Velocity = vel
end

function HookManager:ToggleFullbright(enabled)
    local Lighting = game:GetService("Lighting")
    
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end

-- Movement Hooks
function HookManager:SetupMovementHooks()
    -- Infinity Jump
    self._connections.jumpRequest = UserInputService.JumpRequest:Connect(function()
        if Settings.InfinityJump then
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
    
    -- Teleport System
    self._connections.teleport = RunService.Heartbeat:Connect(function()
        if Settings.TpToIsland and Settings.SelectedIsland then
            self:HandleTeleport()
        end
    end)
end

function HookManager:HandleTeleport()
    local char = player.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local spot = tpFolder:FindFirstChild(Settings.SelectedIsland)
    if not spot then
        for _, tp in ipairs(extraTPs) do
            if tp.Name == Settings.SelectedIsland then
                spot = {CFrame = CFrame.new(tp.Position)}
                break
            end
        end
    end
    
    if spot then
        rootPart.CFrame = spot.CFrame + Vector3.new(0, 5, 0)
    end
end

-- UI Hooks
function HookManager:SetupUIHooks()
    -- Reel UI Monitoring
    self._connections.guiChildAdded = player.PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "reel" then
            self:MonitorReelUI(child)
        end
    end)
    
    for _, child in pairs(player.PlayerGui:GetChildren()) do
        if child.Name == "reel" then
            self:MonitorReelUI(child)
        end
    end
end

function HookManager:MonitorReelUI(reelUI)
    task.spawn(function()
        while reelUI and reelUI.Parent do
            if Settings.AutoReel then
                self:HandleReelUI(reelUI)
            end
            task.wait(0.1)
        end
    end)
end

function HookManager:HandleReelUI(reelUI)
    local bar = reelUI:FindFirstChild("bar")
    if not bar then return end
    
    local fish = bar:FindFirstChild("fish")
    local playerbar = bar:FindFirstChild("playerbar")
    local progress = bar:FindFirstChild("progress")
    local innerBar = progress and progress:FindFirstChild("bar")
    
    if Settings.ReelMethod == "Legit(Safe to Use)" then
        if fish and playerbar then
            playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
        end
    elseif Settings.ReelMethod == "80% legit" then
        if fish and playerbar then
            playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
        end
        
        if innerBar and innerBar.Size.X.Scale >= 0.8 then
            ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, true)
        end
    end
end

-- Anti-Detection System
function HookManager:SetupAntiDetection()
    -- Random behavior patterns
    task.spawn(function()
        while true do
            if math.random(1, 500) == 1 then
                -- Occasional break
                local breakTime = math.random(3, 10)
                task.wait(breakTime)
            end
            task.wait(1)
        end
    end)
    
    -- Anti-AFK
    if Settings.AntiAFK then
        self._connections.antiAFK = game:GetService("Players").LocalPlayer.Idled:Connect(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end

-- Initialize Hook System
task.spawn(function()
    task.wait(2)
    HookManager:Initialize()
end)

-- UI Library (Compkiller)
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
local Notifier = Compkiller.newNotify();
local ConfigManager = Compkiller:ConfigManager({
    Directory = "Compkiller-UI",
    Config = "Fisch-Hook"
});

Compkiller:Loader("rbxassetid://74493757521216", 2.5).yield();

local userId1 = player.UserId
local thumbType1 = Enum.ThumbnailType.HeadShot
local thumbSize1 = Enum.ThumbnailSize.Size420x420
local content1, isReady1 = Players:GetUserThumbnailAsync(userId1, thumbType1, thumbSize1)

local Window = Compkiller.new({
    Name = "Cxsmic",
    Keybind = "RightControl",
    Logo = content1,
    Scale = Compkiller.Scale.Window,
    TextSize = 10
})

Notifier.new({
    Title = "Cxsmic",
    Content = "Script Loaded Successfully!",
    Duration = 5,
    Icon = "rbxassetid://74493757521216"
});

local Watermark = Window:Watermark()

local userId = player.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size48x48
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

Watermark:AddText({
    Icon = content,
    Text = player.Name,
})

Watermark:AddText({
    Icon = "server",
    Text = "Bypass",
});

local MainTab = Window:DrawTab({Name = "Fishing", Icon = "fishing-pole", EnableScrolling = true})

local FishingSection = MainTab:DrawSection({Name = "Fishing Features", Position = "left"})

FishingSection:AddToggle({
    Name = "Auto Cast",
    Default = Settings.AutoCast,
    Callback = function(state)
        Settings.AutoCast = state
        SaveSettings()
    end
})

FishingSection:AddToggle({
    Name = "Auto Reel",
    Default = Settings.AutoReel,
    Callback = function(state)
        Settings.AutoReel = state
        SaveSettings()
    end
})

FishingSection:AddToggle({
    Name = "Auto Equip Rod",
    Default = Settings.AutoEquipRod,
    Callback = function(state)
        Settings.AutoEquipRod = state
        SaveSettings()
    end
})

FishingSection:AddToggle({
    Name = "Auto Shake",
    Default = Settings.AutoShake,
    Callback = function(state)
        Settings.AutoShake = state
        SaveSettings()
    end
})

FishingSection:AddToggle({
    Name = "Auto Sell",
    Default = Settings.AutoSell,
    Callback = function(state)
        Settings.AutoSell = state
        SaveSettings()
    end
})

local SettingsSection = MainTab:DrawSection({Name = "Fishing Settings", Position = "right"})

SettingsSection:AddDropdown({
    Name = "Catch Method",
    Values = {"Perfect", "Random"},
    Default = Settings.CatchMethod,
    Callback = function(choice)
        Settings.CatchMethod = choice
        SaveSettings()
    end
})

SettingsSection:AddDropdown({
    Name = "Reel Method",
    Values = {"Legit(Safe to Use)", "80% legit", "Instant(Risk Ban)"},
    Default = Settings.ReelMethod,
    Callback = function(choice)
        Settings.ReelMethod = choice
        SaveSettings()
    end
})

SettingsSection:AddDropdown({
    Name = "Shake Method",
    Values = {"Shake Normal", "Shake Fast(Not Safe)"},
    Default = Settings.ShakeMethod,
    Callback = function(choice)
        Settings.ShakeMethod = choice
        SaveSettings()
    end
})

SettingsSection:AddToggle({
    Name = "Instant Bobber V1",
    Default = Settings.InstantBobberV1,
    Callback = function(state)
        Settings.InstantBobberV1 = state
        SaveSettings()
    end
})

SettingsSection:AddToggle({
    Name = "Instant Bobber V2",
    Default = Settings.InstantBobberV2,
    Callback = function(state)
        Settings.InstantBobberV2 = state
        SaveSettings()
    end
})

SettingsSection:AddButton({
    Name = "Save Current Position",
    Callback = function()
        local char = player.Character
        if char then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                Settings.SavedPosition = {
                    X = rootPart.Position.X,
                    Y = rootPart.Position.Y,
                    Z = rootPart.Position.Z
                }
                SaveSettings()
                Notifier.new({
                    Title = "Position Saved",
                    Content = "Current position has been saved!",
                    Duration = 3,
                    Icon = "rbxassetid://74493757521216"
                })
            end
        end
    end
})

-- Player Tab
local PlayerTab = Window:DrawTab({Name = "Player", Icon = "user", Type = "Single"})

local PlayerSection = PlayerTab:DrawSection({Name = "Player Modifications", Position = "left"})

PlayerSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = Settings.WalkSpeed,
    Round = 0,
    Callback = function(value)
        Settings.WalkSpeed = value
        SaveSettings()
    end
})

PlayerSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    Default = Settings.JumpPower,
    Round = 0,
    Callback = function(value)
        Settings.JumpPower = value
        SaveSettings()
    end
})

PlayerSection:AddToggle({
    Name = "Noclip",
    Default = Settings.Noclip,
    Callback = function(state)
        Settings.Noclip = state
        SaveSettings()
    end
})

PlayerSection:AddToggle({
    Name = "Infinity Jump",
    Default = Settings.InfinityJump,
    Callback = function(state)
        Settings.InfinityJump = state
        SaveSettings()
    end
})

PlayerSection:AddToggle({
    Name = "Fly",
    Default = Settings.Fly,
    Callback = function(state)
        Settings.Fly = state
        SaveSettings()
    end
})

PlayerSection:AddToggle({
    Name = "Walk on Water",
    Default = Settings.WalkOnWater,
    Callback = function(state)
        Settings.WalkOnWater = state
        SaveSettings()
        HookManager:ApplyPlayerModifications(player.Character)
    end
})

PlayerSection:AddToggle({
    Name = "Fullbright",
    Default = Settings.Fullbright,
    Callback = function(state)
        Settings.Fullbright = state
        SaveSettings()
        HookManager:ToggleFullbright(state)
    end
})

PlayerSection:AddToggle({
    Name = "Anti-AFK",
    Default = Settings.AntiAFK,
    Callback = function(state)
        Settings.AntiAFK = state
        SaveSettings()
        
        if state and not HookManager._connections.antiAFK then
            HookManager._connections.antiAFK = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        elseif not state and HookManager._connections.antiAFK then
            HookManager._connections.antiAFK:Disconnect()
            HookManager._connections.antiAFK = nil
        end
    end
})

-- Teleport Tab
local TeleportTab = Window:DrawTab({Name = "Teleport", Icon = "map-pin", EnableScrolling = true})

local IslandSection = TeleportTab:DrawSection({Name = "Island Teleport", Position = "left"})

IslandSection:AddDropdown({
    Name = "Select Island",
    Values = tpNames,
    Default = Settings.SelectedIsland or tpNames[1],
    Callback = function(choice)
        Settings.SelectedIsland = choice
        SaveSettings()
    end
})

IslandSection:AddToggle({
    Name = "Teleport to Island",
    Default = Settings.TpToIsland,
    Callback = function(state)
        Settings.TpToIsland = state
        SaveSettings()
    end
})

IslandSection:AddButton({
    Name = "Teleport to Saved Position",
    Callback = function()
        if Settings.SavedPosition then
            local char = player.Character
            if char then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(
                        Settings.SavedPosition.X,
                        Settings.SavedPosition.Y,
                        Settings.SavedPosition.Z
                    )
                end
            end
        end
    end
})

-- Settings Tab
local SettingsTab = Window:DrawTab({Name = "Settings", Icon = "settings", Type = "Single"})

local UISection = SettingsTab:DrawSection({Name = "UI Settings"})

UISection:AddButton({
    Name = "Save Configuration",
    Callback = function()
        SaveSettings()
        Notifier.new({
            Title = "Settings Saved",
            Content = "All settings have been saved!",
            Duration = 3,
            Icon = "rbxassetid://74493757521216"
        })
    end
})

UISection:AddButton({
    Name = "Load Configuration",
    Callback = function()
        if pcall(function() return readfile(SETTINGS_FILE) end) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(SETTINGS_FILE))
            end)
            if success and data then
                for k, v in pairs(data) do
                    if DefaultSettings[k] ~= nil then
                        Settings[k] = v
                    end
                end
                Notifier.new({
                    Title = "Settings Loaded",
                    Content = "Configuration loaded successfully!",
                    Duration = 3,
                    Icon = "rbxassetid://74493757521216"
                })
            end
        end
    end
})

UISection:AddButton({
    Name = "Reset to Default",
    Callback = function()
        Settings = table.clone(DefaultSettings)
        SaveSettings()
        Notifier.new({
            Title = "Settings Reset",
            Content = "All settings reset to default!",
            Duration = 3,
            Icon = "rbxassetid://74493757521216"
        })
    end
})

game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        MasterHookSystem:RestoreAll()

        for _, conn in pairs(HookManager._connections) do
            conn:Disconnect()
        end

        HookManager:ToggleFullbright(false)
    end
end)

Notifier.new({
    Title = "Bypass AntiCheat",
    Content = "Bypass AntiCheat!",
    Duration = 5,
    Icon = "rbxassetid://74493757521216"
})

task.spawn(function()
    while true do
        if math.random(1, 100) > 85 then
            task.wait(math.random(0.1, 0.3))
        end
        task.wait(0.5)
    end
end)
