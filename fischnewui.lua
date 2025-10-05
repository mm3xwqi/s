local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local spearfishingWater = Workspace["Spearfishing Water"]
local spearRemote = ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/SpearFishing/Minigame")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

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
	{Name = "The Boom Ball", Position = Vector3.new (-1296, -900, -3479)},
    {Name = "Lost Jungle", Position = Vector3.new (-2690, 149, -2051)}
}

local tpFolder = workspace:WaitForChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")

local tpNames = {}
for _, spot in ipairs(tpFolder:GetChildren()) do
    table.insert(tpNames, spot.Name)
end

for _, tp in ipairs(extraTPs) do
    table.insert(tpNames, tp.Name)
end

table.sort(tpNames,function(a,b) return a:lower() < b:lower() end)

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
	ReelMethod = "Legit(Safe to Use)",
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
	if sp.X and sp.Y and sp.Z and sp.Yaw then
		local pos = Vector3.new(sp.X, sp.Y, sp.Z)
		local yawRad = math.rad(sp.Yaw)
		savedPosition = CFrame.new(pos) * CFrame.Angles(0, yawRad, 0)
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
            local _, yRot, _ = savedPosition:ToEulerAnglesXYZ()
            dataToSave.SavedPosition = {
                X = pos.X,
                Y = pos.Y,
                Z = pos.Z,
                Yaw = math.deg(yRot)
            }
        else
            dataToSave.SavedPosition = nil
        end
        writefile(SETTINGS_FILE, HttpService:JSONEncode(dataToSave))
    end)
end

local autocast = Settings.AutoCast
local autoreel = Settings.AutoReel
local autoEquipRodEnabled = Settings.AutoEquipRod
local CatchMethod = Settings.CatchMethod
local shakeMethod = Settings.ShakeMethod or "Shake Normal"
local autosell = Settings.AutoSell
local teleporting = Settings.TpToIsland
local selectedIsland = Settings.SelectedIsland
local reelMethod = Settings.ReelMethod
local walkOnWaterEnabled = Settings.WalkOnWater
local walkspeedValue = 16
local jumppowerValue = 50
local noclipEnabled = false
local infinityJumpEnabled = false
local changePlayerEnabled = false
local selectedPlayer = nil
local tpToPlayerEnabled = false
local autoEquipRod_running = false

local waitingAnim = ReplicatedStorage.resources.animations.fishing.waiting
local throwAnim = ReplicatedStorage.resources.animations.fishing.throw
local castholdAnim = ReplicatedStorage.resources.animations.fishing.casthold

local originalFunctions = {}

local function HookFunction(object, functionName, newFunction)
    if object and typeof(object) == "Instance" and object[functionName] then
        originalFunctions[object] = originalFunctions[object] or {}
        originalFunctions[object][functionName] = object[functionName]
        
        object[functionName] = function(...)
            return newFunction(object, ...)
        end
    end
end

local function RestoreFunction(object, functionName)
    if originalFunctions[object] and originalFunctions[object][functionName] then
        object[functionName] = originalFunctions[object][functionName]
        originalFunctions[object][functionName] = nil
    end
end

local function EquipRods()
    local char = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack")

    local hasRodInHand = false
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and table.find(rodNames, tool.Name) then
            hasRodInHand = true
            break
        end
    end

    if hasRodInHand then return end

    for _, rodName in ipairs(rodNames) do
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == rodName then
                tool.Parent = char
                return
            end
        end
    end
end

local function GetPlayerNames()
	local names = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		table.insert(names, plr.Name)
	end
	table.sort(names, function(a,b) return a:lower() < b:lower() end)
	return names
end

local function GetHumanoidRootPart()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local function StartAutoEquipRod()
    if autoEquipRod_running then return end
    autoEquipRod_running = true
    task.spawn(function()
        while autoEquipRodEnabled do
            EquipRods()
            task.wait(.1)
        end
        autoEquipRod_running = false
    end)
end

local autocast_running = false
local originalCastAsync = {}

local function HookCastFunctions()
    for _, rodName in ipairs(rodNames) do
        local rod = rodsFolder:FindFirstChild(rodName)
        if rod then
            local events = rod:FindFirstChild("events")
            if events then
                local castAsync = events:FindFirstChild("castAsync")
                if castAsync and castAsync:IsA("RemoteFunction") then
                    originalCastAsync[rodName] = castAsync.InvokeServer
                    
                    castAsync.InvokeServer = function(self, ...)
                        local args = {...}

                        if autocast then
                            if #args >= 2 then
                                args[1] = math.random(10, 55)
                                args[2] = true
                            end
                        end
                        
                        return originalCastAsync[rodName](self, unpack(args))
                    end
                end
            end
        end
    end
end

local function StartAutoCastThrow()
    if autocast_running then return end
    autocast_running = true
    
    task.spawn(function()
        while autocast do
            local char = player.Character
            if not char then
                task.wait()
                continue
            end
            
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then
                task.wait()
                continue
            end
            
            local rod = nil
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and table.find(rodNames, tool.Name) then 
                    rod = tool 
                    break 
                end
            end
            
            if rod then
                local bobber = rod:FindFirstChild("bobber")
                if bobber then
                    task.wait()
                    continue
                end

                local throwTrack = humanoid:LoadAnimation(throwAnim)
                throwTrack:Play()

                if originalCastAsync[rod.Name] then
                    pcall(function() 
                        originalCastAsync[rod.Name](rod.events.castAsync, math.random(10, 55), true)
                    end)
                else
                    local castAsync = rod:FindFirstChild("events") and rod.events:FindFirstChild("castAsync")
                    if castAsync then 
                        pcall(function() 
                            castAsync:InvokeServer(math.random(10, 55), true)
                        end) 
                    end
                end

                local waitingTrack = humanoid:LoadAnimation(waitingAnim)
                waitingTrack:Play()
            end
            task.wait()
        end
        autocast_running = false
    end)
end

local autoreel_running = false
local function GetProgressBarScale()
    local ok, result = pcall(function()
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then return nil end
        local reel = gui:FindFirstChild("reel")
        if not reel then return nil end
        local bar = reel:FindFirstChild("bar")
        if not bar then return nil end
        local progress = bar:FindFirstChild("progress")
        if not progress then return nil end
        local inner = progress:FindFirstChild("bar")
        if not inner then return nil end
        if inner.Size and inner.Size.X and type(inner.Size.X.Scale) == "number" then
            return inner.Size.X.Scale
        end
        return nil
    end)
    if ok then
        return result
    else
        return nil
    end
end

local function HookReelFunction()
    local events = ReplicatedStorage:WaitForChild("events")
    local reelfinished = events:WaitForChild("reelfinished")
    
    if reelfinished and reelfinished:IsA("RemoteEvent") then
        if hookfunction then
            local oldFireServer = reelfinished.FireServer
            hookfunction(reelfinished.FireServer, function(self, ...)
                local args = {...}
                
                if autoreel then
                    if reelMethod == "Instant(Risk Ban)" then
                        if #args >= 2 then
                            args[1] = 100
                            if CatchMethod == "Perfect" then
                                args[2] = true
                            elseif CatchMethod == "Random" then
                                args[2] = (math.random(0, 1) == 1)
                            else
                                args[2] = true
                            end
                        end
                    elseif reelMethod == "80% legit" or reelMethod == "Legit(Safe to Use)" then
                        if #args >= 2 then
                            if CatchMethod == "Perfect" then
                                args[2] = true
                            elseif CatchMethod == "Random" then
                                args[2] = (math.random(0, 1) == 1)
                            end
                        end
                    end
                end
                
                return oldFireServer(self, unpack(args))
            end)
        else
            local oldFireServer = reelfinished.FireServer
            reelfinished.FireServer = function(self, ...)
                local args = {...}
                
                if autoreel then
                    if reelMethod == "Instant(Risk Ban)" then
                        if #args >= 2 then
                            args[1] = 100
                            if CatchMethod == "Perfect" then
                                args[2] = true
                            elseif CatchMethod == "Random" then
                                args[2] = (math.random(0, 1) == 1)
                            else
                                args[2] = true
                            end
                        end
                    elseif reelMethod == "80% legit" or reelMethod == "Legit(Safe to Use)" then
                        if #args >= 2 then
                            if CatchMethod == "Perfect" then
                                args[2] = true
                            elseif CatchMethod == "Random" then
                                args[2] = (math.random(0, 1) == 1)
                            end
                        end
                    end
                end
                
                return oldFireServer(self, unpack(args))
            end
        end
    end
end

local function StartPlayerBarTracking()
    task.spawn(function()
        while autoreel and (reelMethod == "Legit(Safe to Use)" or reelMethod == "80% legit") do
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local reel = playerGui:FindFirstChild("reel")
                if reel then
                    local bar = reel:FindFirstChild("bar")
                    if bar then
                        local fish = bar:FindFirstChild("fish")
                        local playerbar = bar:FindFirstChild("playerbar")
                        
                        if fish and playerbar and fish:IsA("GuiObject") and playerbar:IsA("GuiObject") then
                            pcall(function()
                                playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
                            end)
                        end
                    end
                end
            end
            task.wait()
        end
    end)
end

local function HookResetFunction()
    for _, rodName in ipairs(rodNames) do
        local rod = rodsFolder:FindFirstChild(rodName)
        if rod then
            local events = rod:FindFirstChild("events")
            if events then
                local reset = events:FindFirstChild("reset")
                if reset and reset:IsA("RemoteEvent") then
                    if hookfunction then
                        local oldResetFireServer = reset.FireServer
                        hookfunction(reset.FireServer, function(self, ...)
                            local result = oldResetFireServer(self, ...)

                            if autoreel and (reelMethod == "Legit(Safe to Use)" or reelMethod == "80% legit") then
                                task.spawn(function()
                                    local gui = player:FindFirstChild("PlayerGui")
                                    local reel = gui and gui:FindFirstChild("reel")
                                    if reel then
                                        local bar = reel:FindFirstChild("bar")
                                        local fish = bar and bar:FindFirstChild("fish")
                                        local playerbar = bar and bar:FindFirstChild("playerbar")
                                        
                                        if fish and playerbar and fish:IsA("GuiObject") and playerbar:IsA("GuiObject") then
                                            while autoreel and reel and reel.Parent do
                                                pcall(function()
                                                    playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
                                                end)
                                                task.wait()
                                            end
                                        end
                                    end
                                end)
                            end
                            
                            return result
                        end)
                    end
                end
            end
        end
    end
end

local function StartAutoReel()
    if autoreel_running then return end
    autoreel_running = true

    task.spawn(function()
        while autoreel do
            local gui = player:FindFirstChild("PlayerGui")
            local reel = gui and gui:FindFirstChild("reel")

            while autoreel and gui and not reel do
                reel = gui:FindFirstChild("reel")
                task.wait(0.1)
            end

            if reel then
                local char = player.Character
                if char then
                    for _, rodName in ipairs(rodNames) do
                        local rod = char:FindFirstChild(rodName)
                        if rod then
                            while autoreel and reel and reel.Parent and rod.Parent == char do

                                if reelMethod == "Legit(Safe to Use)" or reelMethod == "80% legit" then
                                    local bar = reel:FindFirstChild("bar")
                                    if bar then
                                        local fish = bar:FindFirstChild("fish")
                                        local playerbar = bar:FindFirstChild("playerbar")
                                        
                                        if fish and playerbar and fish:IsA("GuiObject") and playerbar:IsA("GuiObject") then
                                            pcall(function()
                                                playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
                                            end)
                                        end
                                    end
                                end

                                if reelMethod == "80% legit" then
                                    local prog = GetProgressBarScale()
                                    if prog and prog >= 0.80 then
                                        local isPerfect
                                        if CatchMethod == "Perfect" then
                                            isPerfect = true
                                        elseif CatchMethod == "Random" then
                                            isPerfect = (math.random(0, 1) == 1)
                                        else
                                            isPerfect = true
                                        end
                                        pcall(function()
                                            ReplicatedStorage.events.reelfinished:FireServer(100, isPerfect)
                                        end)
                                    end

                                elseif reelMethod == "Instant(Risk Ban)" then
                                    local isPerfect
                                    if CatchMethod == "Perfect" then
                                        isPerfect = true
                                    elseif CatchMethod == "Random" then
                                        isPerfect = (math.random(0, 1) == 1)
                                    else
                                        isPerfect = true
                                    end
                                    pcall(function()
                                        ReplicatedStorage.events.reelfinished:FireServer(100, isPerfect)
                                    end)
                                end
                                
                                task.wait()
                            end
                        end
                    end
                end
            end
            task.wait()
        end
        autoreel_running = false
    end)
end

local function HookShakeFunction()
    local PlayerGUI = player:WaitForChild("PlayerGui")
    local shakeUI = PlayerGUI:FindFirstChild("shakeui")
    
    if shakeUI then
        local safezone = shakeUI:FindFirstChild("safezone")
        if safezone then
            local button = safezone:FindFirstChild("button")
            if button then
                local shake = button:FindFirstChild("shake")
                if shake and shake:IsA("RemoteEvent") then
                    HookFunction(shake, "FireServer", function(self, ...)
                        if autoshake and shakeMethod == "Shake Fast(Not Safe)" then
                            for i = 1, 3 do
                                originalFunctions[shake].FireServer(self, ...)
                            end
                            return
                        end
                        return originalFunctions[shake].FireServer(self, ...)
                    end)
                end
            end
        end
    end
end

local autoshake_running = false
local function StartAutoShake()
	if autoshake_running then return end
	autoshake_running = true
	task.spawn(function()
		while autoshake do
			if shakeMethod == "Shake Fast(Not Safe)" then
				local shakeButton = player.PlayerGui:FindFirstChild("shakeui")
				shakeButton = shakeButton and shakeButton:FindFirstChild("safezone")
				shakeButton = shakeButton and shakeButton:FindFirstChild("button")
				shakeButton = shakeButton and shakeButton:FindFirstChild("shake")
				if shakeButton then pcall(function() shakeButton:FireServer() end) end
				
			elseif shakeMethod == "Shake Normal" then
				local PlayerGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
				local shakeUI = PlayerGUI:FindFirstChild("shakeui")
				if shakeUI and shakeUI.Enabled then
					local safezone = shakeUI:FindFirstChild("safezone")
					if safezone then
						local button = safezone:FindFirstChild("button")
						if button and button:IsA("ImageButton") and button.Visible then
							local GuiService = game:GetService("GuiService")
							local VirtualInputManager = game:GetService("VirtualInputManager")

							GuiService.SelectedObject = button
							task.wait()
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
							task.wait()
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
						end
					end
				end
			end
			task.wait(.001)
		end
		autoshake_running = false
	end)
end

local autosell_running = false
local originalSellAll = nil

local function HookSellFunction()
    local events = ReplicatedStorage:WaitForChild("events")
    local sellAll = events:WaitForChild("SellAll")
    
    if sellAll and sellAll:IsA("RemoteFunction") then
        originalSellAll = sellAll.InvokeServer
        
        sellAll.InvokeServer = function(self, ...)
            if autosell then
                return true
            end
            return originalSellAll(self, ...)
        end
    end
end

local function StartAutoSell()
    if autosell_running then return end
    autosell_running = true
    
    task.spawn(function()
        while autosell do
            pcall(function() 
                if originalSellAll then
                    originalSellAll(ReplicatedStorage.events.SellAll)
                else
                    ReplicatedStorage.events.SellAll:InvokeServer()
                end
            end)
            task.wait(1)
        end
        autosell_running = false
    end)
end

local teleport_running = false
local function StartAutoCastTeleport()
    if teleport_running then return end
    teleport_running = true

    task.spawn(function()
        while autocast do
            local hrp = GetHumanoidRootPart()
            if hrp and savedPosition then
                pcall(function()
                    hrp.CFrame = savedPosition
                end)
            end
            task.wait()
        end
        teleport_running = false
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

local teleport_running = false
local function StartTeleport()
    if teleport_running then return end
    teleport_running = true
    task.spawn(function()
        while teleporting do
            local hrp = GetHumanoidRootPart()
            local spot = tpFolder:FindFirstChild(selectedIsland)

            if not spot then
                for _, tp in ipairs(extraTPs) do
                    if tp.Name == selectedIsland then
                        spot = {CFrame = CFrame.new(tp.Position)}
                        break
                    end
                end
            end

            if hrp and spot then
                pcall(function() hrp.CFrame = spot.CFrame + Vector3.new(0,5,0) end)
            end
            task.wait()
        end
        teleport_running = false
    end)
end

local function HookSpearFunction()
    if spearRemote and spearRemote:IsA("RemoteEvent") then
        local oldFireServer = spearRemote.FireServer
        
        if hookfunction then
            hookfunction(spearRemote.FireServer, function(self, fishUID, isSecondCall, ...)
                if autoSpearEnabled and isSecondCall then
                    task.wait(0.1)
                end
                return oldFireServer(self, fishUID, isSecondCall, ...)
            end)
        else
            spearRemote.FireServer = function(self, fishUID, isSecondCall, ...)
                if autoSpearEnabled and isSecondCall then
                    task.wait(0.1)
                end
                return oldFireServer(self, fishUID, isSecondCall, ...)
            end
        end
    end
end

local autoSpearEnabled = false
local autoSpearThread = nil

local function AutoSpearLoop()
    while autoSpearEnabled do
        pcall(function()
            for _, waterPart in pairs(spearfishingWater:GetChildren()) do
                if waterPart.Name == "WaterPart" and waterPart:FindFirstChild("ZoneFish") then
                    local zoneFish = waterPart.ZoneFish
                    for _, fishModel in pairs(zoneFish:GetChildren()) do
                        if fishModel:IsA("Model") and autoSpearEnabled then
                            local fishUID = fishModel:GetAttribute("UID")
                            if fishUID then
                                spearRemote:FireServer(fishUID)
                                task.wait(0.15)
                                spearRemote:FireServer(fishUID, true)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end

local instantReel_running = false
local instantReelEnabled = false

local function HookUIDestruction()
    if hookfunction then
        local originalDestroy = nil
        originalDestroy = hookfunction(Instance.new("Part").Destroy, function(self, ...)
            if instantReelEnabled and self:IsA("GuiObject") and self.Name == "reel" then
                if self:FindFirstAncestorWhichIsA("ScreenGui") then
                    self.Visible = false
                    self.Enabled = false
                    return
                end
            end
            return originalDestroy(self, ...)
        end)
    end
end

local function HookRodParent()
    if hookfunction then
        local originalSetParent = nil
        originalSetParent = hookfunction(Instance.new("Tool").SetParent, function(self, newParent, ...)
            if instantReelEnabled and table.find(rodNames, self.Name) then
                return originalSetParent(self, newParent, ...)
            end
            return originalSetParent(self, newParent, ...)
        end)
    end
end

local function HookResetEvents()
    for _, rodName in ipairs(rodNames) do
        local rod = rodsFolder:FindFirstChild(rodName)
        if rod then
            local events = rod:FindFirstChild("events")
            if events then
                local reset = events:FindFirstChild("reset")
                if reset and reset:IsA("RemoteEvent") then
                    if hookfunction then
                        local oldReset = reset.FireServer
                        hookfunction(reset.FireServer, function(self, ...)
                            if instantReelEnabled then
                                task.wait(0.1)
                            end
                            return oldReset(self, ...)
                        end)
                    end
                end
            end
        end
    end
end

local function StartInstantReelWithHook()
    if instantReel_running then return end
    instantReel_running = true
    
    task.spawn(function()
        while instantReelEnabled do
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local reel = playerGui:FindFirstChild("reel")
                if reel then
                    task.wait(.3)

                    pcall(function()
                        local char = player.Character
                        if char then
                            for _, rodName in ipairs(rodNames) do
                                local rod = char:FindFirstChild(rodName)
                                if rod then
                                    local resetEvent = rod:FindFirstChild("events"):FindFirstChild("reset")
                                    if resetEvent then
                                        resetEvent:FireServer()
                                    end
                                    break
                                end
                            end
                        end
                    end)
                    
                    task.wait(.3)
                    
                    pcall(function()
                        reel:Destroy()
                    end)

                    local char = player.Character
                    if char then
                        for _, rodName in ipairs(rodNames) do
                            local rod = char:FindFirstChild(rodName)
                            if rod then
                                pcall(function()
                                    rod.Parent = player.Backpack
                                end)
                                break
                            end
                        end
                    end
                end
            end
            
            task.wait(.3)
        end
        instantReel_running = false
    end)
end

local function InitializeHooks()
    local success, err = pcall(function()
        if not hookfunction then
            error("hookfunction not available")
        end
        
        HookReelFunction()
        HookResetFunction()
        HookShakeFunction() 
        HookSpearFunction()
    end)
    
    if not success then
        InitializeFallbackHooks()
    end
end

local function InitializeInstantReelHooks()
    pcall(function()
        if hookfunction then
            HookUIDestruction()
            HookRodParent()
            HookResetEvents()
        end
    end)
end

task.spawn(function()
    task.wait(3)
    InitializeInstantReelHooks()
end)

task.spawn(function()
    task.wait(3)
    HookReelFunction()
end)

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "Cxsmic",
    Desc = "Fisch Script by Cxsmic",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "Cxsmic"
    }
})

local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    MainTab:Section({Title = "Fishing Features"})
    
    MainTab:Toggle({
    Title = "Auto Cast",
    Desc = "Automatically cast fishing rod",
    Value = autocast,
    Callback = function(state)
        autocast = state
        Settings.AutoCast = state
        SaveSettings()
        if state then
            StartAutoCastThrow()
            StartAutoCastTeleport()
        end
    end
})

-- ฟังก์ชันดึงค่าจากทุกเบ็ด
local function GetSimpleUsableRods()
    local lines = {}
    local usableCount = 0
    
    for _, rodName in ipairs(rodNames) do
        local rodFolder = workspace.testchtfisch:FindFirstChild(rodName)
        if rodFolder and rodFolder:FindFirstChild("values") and rodFolder.values:FindFirstChild("lure") then
            local lureValue = rodFolder.values.lure.Value
            if lureValue ~= 100 then
                table.insert(lines, string.format("🎣 %s: %s", rodName, tostring(lureValue)))
                usableCount = usableCount + 1
            end
        end
    end
    
    if usableCount == 0 then
        table.insert(lines, "❌ No equip rods")
    else
        table.insert(lines, "")
        table.insert(lines, "Total: " .. usableCount)
    end
    
    table.insert(lines, os.date("%H:%M:%S"))
    
    return table.concat(lines, "\n")
end

local simpleDisplay = MainTab:Code({
    Title = "Show Lure",
    Code = GetSimpleUsableRods()
})

task.spawn(function()
    while true do
        task.wait(.001)
        simpleDisplay:SetCode(GetSimpleUsableRods())
    end
end)
    
    MainTab:Toggle({
        Title = "Auto Spear (BANNABLE)",
        Desc = "Automatically spear fish",
        Value = autoSpearEnabled,
        Callback = function(state)
            autoSpearEnabled = state
            if state then
                autoSpearThread = task.spawn(AutoSpearLoop)
            elseif autoSpearThread then
                task.cancel(autoSpearThread)
                autoSpearThread = nil
            end
        end
    })
    
    MainTab:Toggle({
        Title = "Auto Reel",
        Desc = "Automatically reel fish",
        Value = autoreel,
        Callback = function(state)
            autoreel = state
            Settings.AutoReel = state
            SaveSettings()
            if state then 
                StartAutoReel() 
            end
        end
    })
    
    MainTab:Toggle({
        Title = "Instant Reel",
        Desc = "Instant reel fish",
        Value = false,
        Callback = function(state)
            instantReelEnabled = state
            if state then
                StartInstantReelWithHook()
            end
        end
    })
    
    MainTab:Toggle({
        Title = "Auto Equip Rod",
        Desc = "Automatically equip fishing rod",
        Value = autoEquipRodEnabled,
        Callback = function(state)
            autoEquipRodEnabled = state
            Settings.AutoEquipRod = state
            SaveSettings()
            if state then
                StartAutoEquipRod()
            end
        end
    })
    
    MainTab:Toggle({
        Title = "Auto Shake",
        Desc = "Automatically shake fish",
        Value = autoshake,
        Callback = function(state)
            autoshake = state
            Settings.AutoShake = state
            SaveSettings()
            if state then StartAutoShake() end
        end
    })
    
    MainTab:Toggle({
        Title = "Auto Sell",
        Desc = "Automatically sell fish",
        Value = autosell,
        Callback = function(state)
            autosell = state
            Settings.AutoSell = state
            SaveSettings()
            if state then StartAutoSell() end
        end
    })
    
    -- Settings Section
    MainTab:Section({Title = "Farm Settings"})
    
    MainTab:Dropdown({
        Title = "Catch Method",
        Desc = "Select catch method",
        List = {"Perfect", "Random(Does work with legit)"},
        Value = CatchMethod or "Perfect",
        Callback = function(choice)
            CatchMethod = choice
            Settings.CatchMethod = choice
            SaveSettings()
        end
    })
    
    MainTab:Dropdown({
        Title = "Reel Method",
        Desc = "Select reel method",
        List = {"Legit(Safe to Use)", "Instant(Risk Ban)", "80% legit"},
        Value = reelMethod or "Legit(Safe to Use)",
        Callback = function(choice)
            reelMethod = choice
            Settings.ReelMethod = choice
            SaveSettings()

            if autoreel then
                autoreel_running = false
                StartAutoReel()
            end
        end
    })
    
    MainTab:Dropdown({
        Title = "Shake Method",
        Desc = "Select shake method",
        List = {"Shake Normal", "Shake Fast(Not Safe)"},
        Value = shakeMethod or "Shake Normal",
        Callback = function(choice)
            shakeMethod = choice
            Settings.ShakeMethod = choice
            SaveSettings()

            if autoshake then
                autoshake_running = false
                task.wait(0.1)
                StartAutoShake()
            end
        end
    })
    
    MainTab:Button({
    Title = "Save Position",
    Desc = "Save current position",
    Callback = function()
        local hrp = GetHumanoidRootPart()
        if hrp then
            savedPosition = hrp.CFrame
            local pos = savedPosition.Position
            local _, yRot, _ = savedPosition:ToEulerAnglesXYZ()
            Settings.SavedPosition = {
                X = pos.X,
                Y = pos.Y,
                Z = pos.Z,
                Yaw = math.deg(yRot)
            }
            SaveSettings()
            Window:Notify({
                Title = "Position Saved",
                Desc = "Save Position successfully!",
                Time = 3
            })
        end
    end
})

MainTab:Button({
    Title = "Reset Saved Position",
    Desc = "Reset saved position data",
    Callback = function()
        savedPosition = nil
        Settings.SavedPosition = nil
        SaveSettings()
        Window:Notify({
            Title = "Position Reset",
            Desc = "Reset successfully!",
            Time = 3
        })
    end
})

-- Player Tab
Window:Line()
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"}) do
    PlayerTab:Section({Title = "Player Settings"})
    
    PlayerTab:Slider({
        Title = "WalkSpeed",
        Desc = "Set player walk speed",
        Min = 50,
        Max = 500,
        Rounding = 0,
        Value = 100,
        Callback = function(val)
            walkspeedValue = val
        end
    })
    
    PlayerTab:Slider({
        Title = "JumpPower",
        Desc = "Set player jump power",
        Min = 50,
        Max = 500,
        Rounding = 0,
        Value = 50,
        Callback = function(val)
            jumppowerValue = val
        end
    })
    
    PlayerTab:Toggle({
        Title = "Change Player Stats",
        Desc = "Enable to change walk speed and jump power",
        Value = changePlayerEnabled,
        Callback = function(state)
            changePlayerEnabled = state
        end
    })
    
    PlayerTab:Toggle({
        Title = "Noclip",
        Desc = "Walk through walls",
        Value = noclipEnabled,
        Callback = function(state)
            noclipEnabled = state
        end
    })

local mobileFlyConnection1, mobileFlyConnection2
local FLYING = false
local iyflyspeed = 3
local vehicleflyspeed = 3
local velocityHandlerName = "FlyVelocity"
local gyroHandlerName = "FlyGyro"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
end

local function stopMobileFly(speaker)
    FLYING = false
    if mobileFlyConnection1 then mobileFlyConnection1:Disconnect() mobileFlyConnection1 = nil end
    if mobileFlyConnection2 then mobileFlyConnection2:Disconnect() mobileFlyConnection2 = nil end

    local char = speaker.Character
    if char then
        local root = getRoot(char)
        if root then
            local bv = root:FindFirstChild(velocityHandlerName)
            local bg = root:FindFirstChild(gyroHandlerName)
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

local function mobilefly(speaker, vfly)
    stopMobileFly(speaker)
    FLYING = true

    local char = speaker.Character or speaker.CharacterAdded:Wait()
    local root = getRoot(char)
    local camera = workspace.CurrentCamera
    local v3none = Vector3.new()
    local v3inf = Vector3.new(9e9, 9e9, 9e9)

    local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = Vector3.new()
    bv.Velocity = v3none

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50

    mobileFlyConnection1 = char:WaitForChild("HumanoidRootPart").AncestryChanged:Connect(function()
        if not char:IsDescendantOf(game) then
            stopMobileFly(speaker)
        end
    end)

    mobileFlyConnection2 = RunService.RenderStepped:Connect(function()
        root = getRoot(speaker.Character)
        camera = workspace.CurrentCamera
        if not root then return end

        local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end

        local VelocityHandler = root:FindFirstChild(velocityHandlerName)
        local GyroHandler = root:FindFirstChild(gyroHandlerName)
        if not VelocityHandler or not GyroHandler then return end

        if not vfly then humanoid.PlatformStand = true end
        GyroHandler.CFrame = camera.CoordinateFrame
        VelocityHandler.MaxForce = v3inf

        local direction = controlModule:GetMoveVector()
        local speed = (vfly and vehicleflyspeed or iyflyspeed) * 50
        local vel = Vector3.new()
        vel = vel + camera.CFrame.RightVector * direction.X * speed
        vel = vel - camera.CFrame.LookVector * direction.Z * speed
        VelocityHandler.Velocity = vel
    end)
end

    PlayerTab:Toggle({
    Title = "Fly",
    Desc = "Enable flying mode",
    Value = false,
    Callback = function(state)
        local player = Players.LocalPlayer
        if state then
            mobilefly(player, false)
        else
            stopMobileFly(player)
        end
    end
})
    
    PlayerTab:Toggle({
        Title = "Infinity Jump",
        Desc = "Jump infinitely",
        Value = infinityJumpEnabled,
        Callback = function(state)
            infinityJumpEnabled = state
        end
    })
    
    PlayerTab:Toggle({
        Title = "Walk on Water",
        Desc = "Walk on water surfaces",
        Value = walkOnWaterEnabled,
        Callback = function(state)
            SetWalkOnWater(state)
        end
    })
    
    PlayerTab:Toggle({
        Title = "Disable Notifications",
        Desc = "Hide game notifications",
        Value = false,
        Callback = function(state)
            disableNotifications = state
            if state then
                task.spawn(function()
                    while disableNotifications do
                        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
                        local hud = playerGui:FindFirstChild("hud")
                        if hud then
                            local safezone = hud:FindFirstChild("safezone")
                            if safezone then
                                local announcements = safezone:FindFirstChild("announcements")
                                if announcements then
                                    announcements.Visible = false
                                end
                            end
                        end
                        task.wait(0.5)
                    end

                    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
                    local hud = playerGui:FindFirstChild("hud")
                    if hud then
                        local safezone = hud:FindFirstChild("safezone")
                        if safezone then
                            local announcements = safezone:FindFirstChild("announcements")
                            if announcements then
                                announcements.Visible = true
                            end
                        end
                    end
                end)
            end
        end
    })
    
    PlayerTab:Button({
        Title = "Vip Server",
        Desc = "Join VIP server",
        Callback = function()
            -- VIP Server code here
            local md5 = {}
            local hmac = {}
            local base64 = {}

            do
                do
                    local T = {
                        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
                    }

                    local function add(a, b)
                        local lsw = bit32.band(a, 0xFFFF) + bit32.band(b, 0xFFFF)
                        local msw = bit32.rshift(a, 16) + bit32.rshift(b, 16) + bit32.rshift(lsw, 16)
                        return bit32.bor(bit32.lshift(msw, 16), bit32.band(lsw, 0xFFFF))
                    end

                    local function rol(x, n)
                        return bit32.bor(bit32.lshift(x, n), bit32.rshift(x, 32 - n))
                    end

                    local function F(x, y, z)
                        return bit32.bor(bit32.band(x, y), bit32.band(bit32.bnot(x), z))
                    end
                    local function G(x, y, z)
                        return bit32.bor(bit32.band(x, z), bit32.band(y, bit32.bnot(z)))
                    end
                    local function H(x, y, z)
                        return bit32.bxor(x, bit32.bxor(y, z))
                    end
                    local function I(x, y, z)
                        return bit32.bxor(y, bit32.bor(x, bit32.bnot(z)))
                    end

                    function md5.sum(message)
                        local a, b, c, d = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476

                        local message_len = #message
                        local padded_message = message .. "\128"
                        while #padded_message % 64 ~= 56 do
                            padded_message = padded_message .. "\0"
                        end

                        local len_bytes = ""
                        local len_bits = message_len * 8
                        for i = 0, 7 do
                            len_bytes = len_bytes .. string.char(bit32.band(bit32.rshift(len_bits, i * 8), 0xFF))
                        end
                        padded_message = padded_message .. len_bytes

                        for i = 1, #padded_message, 64 do
                            local chunk = padded_message:sub(i, i + 63)
                            local X = {}
                            for j = 0, 15 do
                                local b1, b2, b3, b4 = chunk:byte(j * 4 + 1, j * 4 + 4)
                                X[j] = bit32.bor(b1, bit32.lshift(b2, 8), bit32.lshift(b3, 16), bit32.lshift(b4, 24))
                            end

                            local aa, bb, cc, dd = a, b, c, d

                            local s = { 7, 12, 17, 22, 5, 9, 14, 20, 4, 11, 16, 23, 6, 10, 15, 21 }

                            for j = 0, 63 do
                                local f, k, shift_index
                                if j < 16 then
                                    f = F(b, c, d)
                                    k = j
                                    shift_index = j % 4
                                elseif j < 32 then
                                    f = G(b, c, d)
                                    k = (1 + 5 * j) % 16
                                    shift_index = 4 + (j % 4)
                                elseif j < 48 then
                                    f = H(b, c, d)
                                    k = (5 + 3 * j) % 16
                                    shift_index = 8 + (j % 4)
                                else
                                    f = I(b, c, d)
                                    k = (7 * j) % 16
                                    shift_index = 12 + (j % 4)
                                end

                                local temp = add(a, f)
                                temp = add(temp, X[k])
                                temp = add(temp, T[j + 1])
                                temp = rol(temp, s[shift_index + 1])

                                local new_b = add(b, temp)
                                a, b, c, d = d, new_b, b, c
                            end

                            a = add(a, aa)
                            b = add(b, bb)
                            c = add(c, cc)
                            d = add(d, dd)
                        end

                        local function to_le_hex(n)
                            local s = ""
                            for i = 0, 3 do
                                s = s .. string.char(bit32.band(bit32.rshift(n, i * 8), 0xFF))
                            end
                            return s
                        end

                        return to_le_hex(a) .. to_le_hex(b) .. to_le_hex(c) .. to_le_hex(d)
                    end
                end

                do
                    function hmac.new(key, msg, hash_func)
                        if #key > 64 then
                            key = hash_func(key)
                        end

                        local o_key_pad = ""
                        local i_key_pad = ""
                        for i = 1, 64 do
                            local byte = (i <= #key and string.byte(key, i)) or 0
                            o_key_pad = o_key_pad .. string.char(bit32.bxor(byte, 0x5C))
                            i_key_pad = i_key_pad .. string.char(bit32.bxor(byte, 0x36))
                        end

                        return hash_func(o_key_pad .. hash_func(i_key_pad .. msg))
                    end
                end

                do
                    local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

                    function base64.encode(data)
                        return (
                            (data:gsub(".", function(x)
                                local r, b_val = "", x:byte()
                                for i = 8, 1, -1 do
                                    r = r .. (b_val % 2 ^ i - b_val % 2 ^ (i - 1) > 0 and "1" or "0")
                                end
                                return r
                            end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
                                if #x < 6 then
                                    return ""
                                end
                                local c = 0
                                for i = 1, 6 do
                                    c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
                                end
                                return b:sub(c + 1, c + 1)
                            end) .. ({ "", "==", "=" })[#data % 3 + 1]
                        )
                    end
                end
            end

            local function GenerateReservedServerCode(placeId)
                local uuid = {}
                for i = 1, 16 do
                    uuid[i] = math.random(0, 255)
                end

                uuid[7] = bit32.bor(bit32.band(uuid[7], 0x0F), 0x40) -- v4
                uuid[9] = bit32.bor(bit32.band(uuid[9], 0x3F), 0x80) -- RFC 4122

                local firstBytes = ""
                for i = 1, 16 do
                    firstBytes = firstBytes .. string.char(uuid[i])
                end

                local gameCode =
                    string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", table.unpack(uuid))

                local placeIdBytes = ""
                local pIdRec = placeId
                for _ = 1, 8 do
                    placeIdBytes = placeIdBytes .. string.char(pIdRec % 256)
                    pIdRec = math.floor(pIdRec / 256)
                end

                local content = firstBytes .. placeIdBytes

                local SUPERDUPERSECRETROBLOXKEYTHATTHEYDIDNTCHANGEEVERSINCEFOREVER = "e4Yn8ckbCJtw2sv7qmbg" -- legacy leaked key from ages ago that still works due to roblox being roblox.
                local signature = hmac.new(SUPERDUPERSECRETROBLOXKEYTHATTHEYDIDNTCHANGEEVERSINCEFOREVER, content, md5.sum)

                local accessCodeBytes = signature .. content

                local accessCode = base64.encode(accessCodeBytes)
                accessCode = accessCode:gsub("+", "-"):gsub("/", "_")

                local pdding = 0
                accessCode, _ = accessCode:gsub("=", function()
                    pdding = pdding + 1
                    return ""
                end)

                accessCode = accessCode .. tostring(pdding)

                return accessCode, gameCode
            end

            local accessCode, _ = GenerateReservedServerCode(game.PlaceId)
            game.RobloxReplicatedStorage.ContactListIrisInviteTeleport:FireServer(game.PlaceId, "", accessCode)
        end
    })
end

local fullbrightEnabled = false
local originalLightingSettings = nil
local connections = {}

local function EnableFullbright()
    local Lighting = game:GetService("Lighting")
    originalLightingSettings = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient
    }

    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

    local propertiesToWatch = {"Brightness", "ClockTime", "FogEnd", "GlobalShadows", "OutdoorAmbient"}
    
    for _, property in ipairs(propertiesToWatch) do
        if connections[property] then
            connections[property]:Disconnect()
        end
        
        connections[property] = Lighting:GetPropertyChangedSignal(property):Connect(function()
            if fullbrightEnabled then
                if property == "Brightness" then
                    Lighting.Brightness = 2
                elseif property == "ClockTime" then
                    Lighting.ClockTime = 14
                elseif property == "FogEnd" then
                    Lighting.FogEnd = 100000
                elseif property == "GlobalShadows" then
                    Lighting.GlobalShadows = false
                elseif property == "OutdoorAmbient" then
                    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                end
            end
        end)
    end
end

local function DisableFullbright()
    local Lighting = game:GetService("Lighting")

    for property, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
            connections[property] = nil
        end
    end

    if originalLightingSettings then
        Lighting.Brightness = originalLightingSettings.Brightness
        Lighting.ClockTime = originalLightingSettings.ClockTime
        Lighting.FogEnd = originalLightingSettings.FogEnd
        Lighting.GlobalShadows = originalLightingSettings.GlobalShadows
        Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient
    end
end

PlayerTab:Toggle({
    Title = "Fullbright",
    Desc = "",
    Default = false,
    Callback = function(state)
        fullbrightEnabled = state
        if state then
            EnableFullbright()
        else
            DisableFullbright()
        end
    end
})

-- Islands Tab
Window:Line()
local IslandsTab = Window:Tab({Title = "Islands", Icon = "home"}) do
    IslandsTab:Section({Title = "Teleport Settings"})
    
    IslandsTab:Dropdown({
        Title = "Select Island",
        Desc = "Choose island to teleport to",
        List = tpNames,
        Value = selectedIsland or tpNames[1],
        Callback = function(choice)
            selectedIsland = choice
            Settings.SelectedIsland = choice
            SaveSettings()
        end
    })
    
    IslandsTab:Toggle({
        Title = "Teleport to Island",
        Desc = "Automatically teleport to selected island",
        Value = teleporting,
        Callback = function(state)
            teleporting = state
            Settings.TpToIsland = state
            SaveSettings()
            if teleporting then StartTeleport() end
        end
    })
end

-- Final Notification
Window:Notify({
    Title = "Fisch Script",
    Desc = "Script loaded successfully! Enjoy fishing!",
    Time = 4
})

-- Background loops
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

-- Initialize features based on saved settings
if autocast then
    StartAutoCastThrow()
    StartAutoCastTeleport()
end

if autoreel then
    StartAutoReel()
end

if autoshake then
    StartAutoShake()
end

if autosell then
    StartAutoSell()
end

if teleporting then
    StartTeleport()
end

if walkOnWaterEnabled then
    SetWalkOnWater(true)
end

if autoEquipRodEnabled then 
    StartAutoEquipRod() 
end

game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        for obj, funcs in pairs(originalFunctions) do
            for funcName, originalFunc in pairs(funcs) do
                if obj and obj[funcName] then
                    obj[funcName] = originalFunc
                end
            end
        end

        if instantBobberConnection then
            instantBobberConnection:Disconnect()
        end
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
        end
        if mobileFlyConnection1 then
            mobileFlyConnection1:Disconnect()
        end
        if mobileFlyConnection2 then
            mobileFlyConnection2:Disconnect()
        end
    end
end)
end
