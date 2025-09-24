
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	{Name = "Crimson Cavern", Position = Vector3.new (-1013, -340, -4891)}
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
local autoshake = Settings.AutoShake
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
local function StartAutoCastThrow()
    if autocast_running then return end
    autocast_running = true
    task.spawn(function()
        while autocast do
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
            task.wait(.3)
        end
        autocast_running = false
    end)
end

local teleport_running = false
local function StartAutoCastTeleport()
	if teleport_running then return end
	teleport_running = true
	task.spawn(function()
		while autocast or fishingZoneEnabled do
			local hrp = GetHumanoidRootPart()
			if hrp then
				local zoneTarget = nil

				if fishingZoneEnabled then
					local selectedZone = Settings.SelectedFishingZone
					if type(selectedZone) == "table" then
						selectedZone = selectedZone[1]
					end

					if selectedZone and selectedZone ~= "None" then
						local zonePart = fishingZoneFolder:FindFirstChild(selectedZone)
						if zonePart and zonePart:IsA("BasePart") then
							zoneTarget = zonePart
						end
					end
				end

				if zoneTarget then
					pcall(function()
						hrp.CFrame = zoneTarget.CFrame + Vector3.new(0,5,0)
					end)
				elseif autocast and savedPosition then
					pcall(function()
						hrp.CFrame = savedPosition
					end)
				end
			end
			task.wait(0.5)
		end
		teleport_running = false
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
                            local resetEvent = rod:FindFirstChild("events") and rod.events:FindFirstChild("reset")
                            if resetEvent then
                                while autoreel and reel and reel.Parent and rod.Parent == char do
                                    pcall(function()
                                        resetEvent:FireServer()
                                    end)

                                    local bar = reel:FindFirstChild("bar")
                                    local fish = bar and bar:FindFirstChild("fish")
                                    local playerbar = bar and bar:FindFirstChild("playerbar")

                                    pcall(function()
                                        if reelMethod == "Legit" then
                                            if fish and playerbar and fish:IsA("GuiObject") and playerbar:IsA("GuiObject") then
                                                playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
                                            end

                                        elseif reelMethod == "Safe" then
                                            if fish and playerbar and fish:IsA("GuiObject") and playerbar:IsA("GuiObject") then
                                                playerbar.Position = UDim2.new(fish.Position.X.Scale, 0, playerbar.Position.Y.Scale, 0)
                                            end
                                            local prog = GetProgressBarScale()
                                            if prog and prog >= 0.80 then
                                                pcall(function()
                                                    ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, true)
                                                end)
                                            end

                                        elseif reelMethod == "Instant" then
                                            local isPerfect
                                            if CatchMethod == "Perfect" then
                                                isPerfect = true
                                            elseif CatchMethod == "Random" then
                                                isPerfect = (math.random(0, 1) == 1)
                                            else
                                                isPerfect = true
                                            end
                                            pcall(function()
                                                ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, isPerfect)
                                            end)
                                        end
                                    end)

                                    task.wait()
                                end
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
			if shakeButton then pcall(function() shakeButton:FireServer() end) end
			task.wait(0.2)
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
				if string.find(npc.Name,"Merchant") then targetNpc = npc break end
			end
			if targetNpc then
				local args = {{voice = 12,npc = targetNpc,idle = targetNpc:WaitForChild("description"):WaitForChild("idle")}}
				pcall(function() ReplicatedStorage:WaitForChild("events"):WaitForChild("SellAll"):InvokeServer(unpack(args)) end)
			end
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

local instantBobberConnection = nil

local function StartInstantBobber()
    local player = game.Players.LocalPlayer
    local RunService = game:GetService("RunService")

    if instantBobberConnection then
        instantBobberConnection:Disconnect()
        instantBobberConnection = nil
    end

    local shouldTeleport = true -- ตัวแปรควบคุมการวาร์ป bobber

    instantBobberConnection = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end

        -- หา rod ที่ถืออยู่
        local rod
        for _, rodName in ipairs(rodNames) do
            rod = char:FindFirstChild(rodName)
            if rod then break end
        end
        if not rod then
            shouldTeleport = true -- รีเซ็ตเมื่อ rod หาย
            return
        end

        -- หา bobber
        local bobber = rod:FindFirstChild("bobber", true)
        if bobber and bobber:IsA("BasePart") then
            -- ถ้าเรายังต้องวาร์ป
            if shouldTeleport then
                local targetPos = bobber.Position - Vector3.new(0, 1, 0)
                pcall(function()
                    bobber.CFrame = CFrame.new(targetPos)
                end)
            end

            -- ตรวจสอบ shakeui → ถ้ามีให้หยุดวาร์ป
            local shakeUI = player.PlayerGui:FindFirstChild("shakeui")
            if shakeUI then
                shouldTeleport = false
            end

            -- ตรวจสอบ reel GUI → ถ้า reel ไม่อยู่แล้วให้วาร์ปใหม่ครั้งหน้า
            local reelGUI = player.PlayerGui:FindFirstChild("reel")
            if not reelGUI then
                shouldTeleport = true
            end
        else
            -- bobber หายไป → รีเซ็ต flag
            shouldTeleport = true
        end
    end)
end

-- ================== Compkiller UI ==================
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
local Notifier = Compkiller.newNotify();
local ConfigManager = Compkiller:ConfigManager({
	Directory = "Compkiller-UI",
	Config = "Example-Configs"
});
Compkiller:Loader("rbxassetid://74493757521216" , 2.5).yield();
local ConfigManager = Compkiller:ConfigManager({Directory="Compkiller-UI",Config="Fisch-Configs"})
local Window = Compkiller.new({Name="Cxsmic Risk BAN", Keybind="LeftAlt", Logo="rbxassetid://74493757521216",Scale=Compkiller.Scale.Window,TextSize=15})

Notifier.new({
	Title = "Notification",
	Content = "Thank you for use this script!",
	Duration = 25,
	Icon = "rbxassetid://74493757521216"
});

local Watermark = Window:Watermark();

Watermark:AddText({
	Icon = "user",
	Text = "Yo",
});

Watermark:AddText({
	Icon = "clock",
	Text = Compkiller:GetDate(),
});

local Time = Watermark:AddText({
	Icon = "timer",
	Text = "TIME",
});

task.spawn(function()
	while true do task.wait()
		Time:SetText(Compkiller:GetTimeNow());
	end
end)

Watermark:AddText({
	Icon = "server",
	Text = Compkiller.Version,
});

Notifier.new({Title="Fisch UI",Content="Loaded!",Duration=5,Icon="rbxassetid://120245531583106"})

local MainTab = Window:DrawTab({Name="Main",Icon="apple",EnableScrolling=true})

local FischSection = MainTab:DrawSection({Name="Fisch Features",Position="left"})

local tab2 = Window:DrawTab({
	Name = "Local Player",
	Icon = "user",
	Type = "Single"
});

local plTab = tab2:DrawSection({Name="Local Player",Position="left"})

local tab3 = Window:DrawTab({
	Name = "Islands & Player",
	Icon = "home",
	EnableScrolling=true
});

local tpTab = tab3:DrawSection({Name="Island",Position="left"})

local tpTabRight = tab3:DrawSection({Name="Player",Position="right"})


FischSection:AddToggle({
	Name="Auto Cast",
	Flag="AutoCast",
	Default=autocast,
	Callback=function(state)
		autocast = state
		Settings.AutoCast = state
		SaveSettings()
		if state then
			StartAutoCastThrow()
			StartAutoCastTeleport()
		end
	end
})

FischSection:AddToggle({Name="Auto Reel",Flag="AutoReel",Default=autoreel,Callback=function(state)
	autoreel = state
	Settings.AutoReel = state
	SaveSettings()
	if state then StartAutoReel() end
end})

FischSection:AddToggle({
    Name = "Auto Equip Rod",
    Default = autoEquipRodEnabled,
    Callback = function(state)
        autoEquipRodEnabled = state
        Settings.AutoEquipRod = state
        SaveSettings()
        if state then
            StartAutoEquipRod()
        end
    end
})

FischSection:AddToggle({Name="Auto Shake",Flag="AutoShake",Default=autoshake,Callback=function(state)
	autoshake = state
	Settings.AutoShake = state
	SaveSettings()
	if state then StartAutoShake() end
end})

FischSection:AddToggle({Name="Auto Sell",Flag="AutoSell",Default=autosell,Callback=function(state)
	autosell = state
	Settings.AutoSell = state
	SaveSettings()
	if state then StartAutoSell() end
end})


local SettingSection = MainTab:DrawSection({Name="Setting Farm",Position="right"})

SettingSection:AddDropdown({
    Name = "Catch Method",
    Values = {"Perfect", "Random(Work For Instant)"},
    Default = CatchMethod or "Perfect",
    Callback = function(choice)
        CatchMethod = choice
        Settings.CatchMethod = choice
        SaveSettings()
    end
})

SettingSection:AddDropdown({
    Name = "Reel Method",
    Values = {"Legit", "Instant", "Safe"},
    Default = reelMethod or "Safe",
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


SettingSection:AddToggle({
    Name = "Instant Bobber V1",
    Default = Settings.InstantBobber or false,
    Callback = function(state)
        Settings.InstantBobber = state
        SaveSettings()

        if state then
            StartInstantBobber()
        else
            if instantBobberConnection then
                instantBobberConnection:Disconnect()
                instantBobberConnection = nil
            end
        end
    end
})

SettingSection:AddToggle({
    Name = "Instant Bobber V2",
    Default = Settings.InstantBobber or false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local RunService = game:GetService("RunService")

        if instantBobberConnection then
            instantBobberConnection:Disconnect()
            instantBobberConnection = nil
        end

        Settings.InstantBobber = state
        SaveSettings()

        if state then
            instantBobberConnection = RunService.RenderStepped:Connect(function()
                local char = player.Character
                if not char then return end

                local rod = nil
                for _, rodName in ipairs(rodNames) do
                    rod = char:FindFirstChild(rodName)
                    if rod then break end
                end
                if not rod then return end

                local bobber = rod:FindFirstChild("bobber")
                if not bobber then return end

                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local targetPos = hrp.Position + Vector3.new(0, -3, 0)
                pcall(function()
                    bobber.CFrame = CFrame.new(targetPos)
                end)
            end)
        end
    end
})

SettingSection:AddButton({Name="Save Position",Callback=function()
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
	end
end})



plTab:AddSlider({
    Name = "Walkspeed",
    Min = 50,
    Max = 500,
    Default = 100,
    Round = 0,
    Flag = "Walk_power",
    Callback = function(value)
        walkspeedValue = value
    end
});

plTab:AddSlider({
    Name = "Jumppower",
    Min = 50,
    Max = 500,
    Default = 50,
    Round = 0,
    Flag = "Jump_power",
    Callback = function(value)
        jumppowerValue = value
    end
});

local changePlayerEnabled = false
plTab:AddToggle({
    Name = "Change Player",
    Default = false,
    Callback = function(state)
        changePlayerEnabled = state
    end
})

local antiAFKEnabled = false
local antiAFKConnection = nil

plTab:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(state)
        antiAFKEnabled = state

        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end

        if state then
            local VirtualUser = game:GetService("VirtualUser")
            antiAFKConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

task.spawn(function()
    local toggle = plTab:GetToggle("Anti-AFK")
    if toggle then
        toggle.Callback(true)
    end
end)

plTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
    end
})

plTab:AddToggle({
    Name = "Infinity Jump",
    Default = false,
    Callback = function(state)
        infinityJumpEnabled = state
    end
})

local walkOnWaterEnabled = true

plTab:AddToggle({
    Name = "Walk on Water",
    Default = walkOnWaterEnabled,
    Callback = function(state)
        SetWalkOnWater(state)
    end
})

tpTab:AddDropdown({
    Name = "Select Islands",
    Values = tpNames,
    Default = selectedIsland or tpNames[1],
    Callback = function(choice)
        selectedIsland = choice
        Settings.SelectedIsland = choice
        SaveSettings()
    end
})

tpTab:AddToggle({
    Name = "Tp to Island",
    Default = teleporting,
    Callback = function(state)
        teleporting = state
        Settings.TpToIsland = state
        SaveSettings()
        if teleporting then StartTeleport() end
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

Window:DrawCategory({
	Name = "Misc"
});

local SettingTab = Window:DrawTab({
	Icon = "settings-3",
	Name = "Settings",
	Type = "Single",
	EnableScrolling = true
});

local ThemeTab = Window:DrawTab({
	Icon = "paintbrush",
	Name = "Themes",
	Type = "Single"
});

local Settings = SettingTab:DrawSection({
	Name = "UI Settings",
});

Settings:AddToggle({
	Name = "Alway Show Frame",
	Default = false,
	Callback = function(v)
		Window.AlwayShowTab = v;
	end,
});

Settings:AddColorPicker({
	Name = "Highlight",
	Default = Compkiller.Colors.Highlight,
	Callback = function(v)
		Compkiller.Colors.Highlight = v;
		Compkiller:RefreshCurrentColor();
	end,
});

Settings:AddColorPicker({
	Name = "Toggle Color",
	Default = Compkiller.Colors.Toggle,
	Callback = function(v)
		Compkiller.Colors.Toggle = v;
		
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Drop Color",
	Default = Compkiller.Colors.DropColor,
	Callback = function(v)
		Compkiller.Colors.DropColor = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Risky",
	Default = Compkiller.Colors.Risky,
	Callback = function(v)
		Compkiller.Colors.Risky = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Mouse Enter",
	Default = Compkiller.Colors.MouseEnter,
	Callback = function(v)
		Compkiller.Colors.MouseEnter = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Block Color",
	Default = Compkiller.Colors.BlockColor,
	Callback = function(v)
		Compkiller.Colors.BlockColor = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Background Color",
	Default = Compkiller.Colors.BGDBColor,
	Callback = function(v)
		Compkiller.Colors.BGDBColor = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Block Background Color",
	Default = Compkiller.Colors.BlockBackground,
	Callback = function(v)
		Compkiller.Colors.BlockBackground = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Stroke Color",
	Default = Compkiller.Colors.StrokeColor,
	Callback = function(v)
		Compkiller.Colors.StrokeColor = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "High Stroke Color",
	Default = Compkiller.Colors.HighStrokeColor,
	Callback = function(v)
		Compkiller.Colors.HighStrokeColor = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Switch Color",
	Default = Compkiller.Colors.SwitchColor,
	Callback = function(v)
		Compkiller.Colors.SwitchColor = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Line Color",
	Default = Compkiller.Colors.LineColor,
	Callback = function(v)
		Compkiller.Colors.LineColor = v;

		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddButton({
	Name = "Get Theme",
	Callback = function()
		print(Compkiller:GetTheme())
		
		Notifier.new({
			Title = "Notification",
			Content = "Copied Them Color to your clipboard",
			Duration = 5,
			Icon = "rbxassetid://120245531583106"
		});
	end,
});

ThemeTab:DrawSection({
	Name = "UI Themes"
}):AddDropdown({
	Name = "Select Theme",
	Default = "Default",
	Values = {
		"Default",
		"Dark Green",
		"Dark Blue",
		"Purple Rose",
		"Skeet"
	},
	Callback = function(v)
		Compkiller:SetTheme(v)
	end,
})

-- Creating Config Tab --
local ConfigUI = Window:DrawConfig({
	Name = "Config",
	Icon = "folder",
	Config = ConfigManager
});

ConfigUI:Init();

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

if Settings.InstantBobber then
    task.spawn(function()
        local player = game.Players.LocalPlayer
        while true do
            task.wait(0.1)
            local char = player.Character
            if not char then continue end

            local rod
            for _, rodName in ipairs(rodNames) do
                rod = char:FindFirstChild(rodName)
                if rod then break end
            end
            if rod and rod:FindFirstChild("bobber", true) then
                StartInstantBobber()
                break
            end
        end
    end)
end

if autoEquipRodEnabled then StartAutoEquipRod() end
if instantReelEnabled then StartInstantReel() end
