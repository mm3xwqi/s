local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/1.6.0/main.lua"))()
local SaveManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/mm3xwqi/s/refs/heads/main/InterfaceManager.lua"))()
local G = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
G.isMobile = UserInputService.TouchEnabled
	and not UserInputService.MouseEnabled
	and not UserInputService.KeyboardEnabled

G.Minimizer = Fluent:CreateMinimizer({
	Icon = "rbxassetid://109639117875913",
	Size = UDim2.fromOffset(58, 58),
	Position = UDim2.new(0.04, 0, 0.16, 0),
	Corner = 12,
	BackgroundTransparency = 0.08,
	IconCorner = 10,
	Transparency = 0,
	Lockable = true,
	LockHoldTime = 1,
	Draggable = true,
})
G.Minimizer.Visible = true

G.placeId = game.PlaceId
G.sea1 = (G.placeId == 2753915549 or G.placeId == 85211729168715)
G.sea2 = (G.placeId == 4442272183 or G.placeId == 79091703265657)
G.sea3 = (G.placeId == 7449423635 or G.placeId == 100117331123089)

local seaName = G.sea1 and "First Sea" or G.sea2 and "Second Sea" or G.sea3 and "Third Sea" or "Unknown Sea"
local ok, gameName = pcall(function()
	return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)
if not ok then
	gameName = "Blox Fruits"
end

Fluent:AddTheme({
	Name = "KKKK Blue",
	Accent = Color3.fromHex("#00aaff"),
	AcrylicMain = Color3.fromHex("#00050f"),
	AcrylicBorder = Color3.fromHex("#0a1a2d"),
	AcrylicGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("#00050f")),
		ColorSequenceKeypoint.new(0.5, Color3.fromHex("#050d1a")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("#0a1220")),
	}),
	AcrylicNoise = 0.9,
	TitleBarLine = Color3.fromHex("#1a4a7a"),
	Tab = Color3.fromHex("#030d1a"),
	Element = Color3.fromHex("#020b16"),
	ElementBorder = Color3.fromHex("#0f3a5e"),
	InElementBorder = Color3.fromHex("#0a2440"),
	ElementTransparency = 0.92,
	ElementBorderThickness = 1,
	ToggleSlider = Color3.fromHex("#0f2d4a"),
	ToggleToggled = Color3.fromHex("#00aaff"),
	SliderRail = Color3.fromHex("#0a1f33"),
	CheckboxUnchecked = Color3.fromHex("#0a1f33"),
	CheckboxChecked = Color3.fromHex("#00aaff"),
	CheckboxCheck = Color3.fromHex("#00050f"),
	ProgressBarRail = Color3.fromHex("#0a1f33"),
	ProgressBarFill = Color3.fromHex("#00aaff"),
	DropdownFrame = Color3.fromHex("#030b16"),
	DropdownHolder = Color3.fromHex("#050f1e"),
	DropdownBorder = Color3.fromHex("#0f3a5e"),
	DropdownOption = Color3.fromHex("#08152a"),
	DropdownBorderThickness = 1,
	Keybind = Color3.fromHex("#081828"),
	Input = Color3.fromHex("#050f1e"),
	InputFocused = Color3.fromHex("#0a1f33"),
	InputIndicator = Color3.fromHex("#55ccff"),
	Dialog = Color3.fromHex("#040c18"),
	DialogHolder = Color3.fromHex("#060f1e"),
	DialogHolderLine = Color3.fromHex("#0f3a5e"),
	DialogButton = Color3.fromHex("#0f2d4a"),
	DialogButtonBorder = Color3.fromHex("#1a5080"),
	DialogBorder = Color3.fromHex("#0a2440"),
	DialogInput = Color3.fromHex("#060f1e"),
	DialogInputLine = Color3.fromHex("#55ccff"),
	Text = Color3.fromHex("#f0f8ff"),
	SubText = Color3.fromHex("#7aaac8"),
	Hover = Color3.fromHex("#0a1f33"),
	HoverChange = 0.06,
	Background = "https://raw.githubusercontent.com/StyearX/Assets/main/backgrounds.png",
	BackgroundTransparency = 0,
	ShineEnabled = true,
	Shine = {
		Speed = 3,
		RotationSpeed = 1.5,
		ColorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#000000")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#00aaff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#000000")),
		}),
	},
	StrokeShine = true,
	StrokeDark = Color3.fromHex("#050f1e"),
	ButtonGradient = {
		Background = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#0f2d4a")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#050f1e")),
		}),
		Stroke = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#0088cc")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#005580")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#0088cc")),
		}),
	},
	DiscordJoinButton = Color3.fromHex("#5865f2"),
	WarningNotifyColor = Color3.fromHex("#d6ac3d"),
	SuccessNotifyColor = Color3.fromHex("#4fc773"),
	ErrorNotifyColor = Color3.fromHex("#ff4444"),
	InfoNotifyColor = Color3.fromHex("#00aaff"),
})

local Window = Fluent:CreateWindow({
	Title = "KKKK x Hub",
	SubTitle = "By Z.",
	TabWidth = G.isMobile and 132 or 158,
	Size = G.isMobile and UDim2.fromOffset(610, 540) or UDim2.fromOffset(700, 610),
	Acrylic = true,
	Theme = "KKKK Noir",
	Background = true,
	Font = "GothamSSm",
	TitleIcon = "rbxassetid://109639117875913",
	MinimizeKey = "LeftAlt",
	FolderName = "KKKKHubNew",
	ScreenGuiName = "KKKKHubNew",
	Tags = { { Text = gameName .. " | " .. seaName, Color = Color3.fromRGB(0, 0, 0) } },
	Search = {
		Search = true,
		Highlight = true,
		HighlightColor = Color3.fromRGB(231, 231, 238),
	},
	UserInfo = {
		UserInfo = true,
		UserInfoTitle = player.Name,
		UserInfoSubtitle = player.DisplayName,
		UserInfoColor = Color3.fromRGB(231, 231, 238),
	},
	Anonymous = {
		Default = false,
		ShowAno = true,
		AnoUserInfoTitle = "Free Fire Max",
		AnoUserInfoSubTitle = "Identity hidden",
		Icons = "rbxassetid://109639117875913",
	},
})

local RawTabs = {
	Info = Window:AddTab({ Title = "Info & Status", Icon = "solar/info-circle-bold" }),
	LocalPlayer = Window:AddTab({ Title = "Local Player", Icon = "solar/user-bold" }),
	Stat = Window:AddTab({ Title = "Stat", Icon = "solar/chart-2-bold" }),
	Main = Window:AddTab({ Title = "Main", Icon = "lucide/swords" }),
	Island = Window:AddTab({ Title = "Island", Icon = "solar/map-point-bold" }),
	FarmSetting = Window:AddTab({ Title = "Farm Setting", Icon = "solar/settings-bold" }),
	Event = Window:AddTab({ Title = "Event", Icon = "solar/balloon-bold" }),
	Esp = Window:AddTab({ Title = "Visual", Icon = "solar/eye-bold" }),
	Settings = Window:AddTabsInHeader({ Title = " Configuration", Icon = "solar/settings-bold" }),
}

local Tabs = {
	Info = RawTabs.Info:AddSection("Live Status", "solar/pulse-2-bold"),
	LocalPlayer = RawTabs.LocalPlayer:AddSection("Player Utilities", "solar/user-id-bold"),
	Stat = RawTabs.Stat:AddSection("Stat Allocation", "solar/chart-square-bold"),
	Main = RawTabs.Main:AddSection("Farming", "lucide/swords"),
	Island = RawTabs.Island:AddSection("Island Travel", "solar/map-arrow-square-bold"),
	FarmSetting = RawTabs.FarmSetting:AddSection("Farm Tuning", "solar/tuning-2-bold"),
	Event = RawTabs.Event:AddSection("Event Automation", "solar/calendar-bold"),
	Esp = RawTabs.Esp:AddSection("Visual ESP", "solar/eye-scan-bold"),
	Settings = RawTabs.Settings,
}

Fluent.NotifyInsideWindow = true

G.placeId = game.PlaceId
G.sea1 = (G.placeId == 2753915549 or G.placeId == 85211729168715)
G.sea2 = (G.placeId == 4442272183 or G.placeId == 79091703265657)
G.sea3 = (G.placeId == 7449423635 or G.placeId == 100117331123089)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local enemiesFolder = workspace:WaitForChild("Enemies")

local State = {
	autoFarmEnabled = false,
	bringMobEnabled = true,
	autoFarmSelectEnabled = false,
	fruitAndMeleeEnabled = false,
	lockMobCFrame = true,
	selectedMobNames = {},
	selectedMobIndex = 1,
	currentTarget = nil,
	isLocked = false,
	lockStartTime = nil,
	BRING_MOB_COUNT = 1,
	SPEED = 190,
	Y_OFFSET = 30,
	ATTACK_RATE = 0.3,
	ATTACK_RANGE = 120,
	SNAP_RANGE = 5,
	BRING_DISTANCE = 350,
	BRING_INTERVAL = 0.005,
	SPAWN_TELEPORT_INTERVAL = 0.3,
	isMovingToSpawn = false,
	spawnPointList = {},
	spawnPointIndex = 1,
	spawnPointChecked = {},
	lastSpawnPointKey = nil,
	spawnCyclePauseUntil = 0,
	lastSpawnTeleportTime = 0,
	lastAttackTime = 0,
	lastTargetSwitchTime = 0,
	TARGET_SWITCH_COOLDOWN = 0.5,
	lastMovePosition = nil,
	lastMoveTime = 0,
	idleAnchorCFrame = nil,
	lastBringUpdate = 0,
	bringAnchor = nil,
	targetAnchorCFrame = nil,
	followConnection = nil,
	activeBodyGyro = nil,
	activeAntiGravity = nil,
	activeTween = nil,
	tweenTargetPosition = nil,
	activeHumanoid = nil,
	selectedIslandName = nil,
	selectedIslandPos = nil,
	currentFlyCF = nil,
	lastTweenStartTime = 0,
	TWEEN_TIMEOUT = 10,
	teleportTweenEnabled = false,
	islandRoute = nil,
	islandRouteIndex = 1,
	waitingForWarpPos = nil,
	warpWaitStart = 0,
	WARP_TRIGGER_DIST = 80,
	WARP_WAIT_TIMEOUT = 8,
	_entryRouteActive = false,
	_entryRouteCooldown = 0,
	_exitRouteCooldown = 0,
}

State.autoEquipEnabled = true
State.selectedWeaponType = "Melee"
State.lastEquippedTool = nil

G.activeBringBodies = {}
G.bringSnapped = {}
G.originalMobStates = {}
G.originalCanCollide = {}
G.mobTweens = {}

G.noclipConn = nil

function G.startNoclipLoop()
	if G.noclipConn then
		return
	end
	G.noclipConn = RunService.Stepped:Connect(function()
		local farmActive = State.autoFarmEnabled or State.autoFarmSelectEnabled

		if not farmActive then
			G.stopNoclipLoop()
			G.restoreCollision()
			return
		end

		local c = player.Character
		if not c then
			return
		end

		for _, v in ipairs(c:GetDescendants()) do
			if v:IsA("BasePart") then
				if G.originalCanCollide[v] == nil then
					G.originalCanCollide[v] = v.CanCollide
				end
				v.CanCollide = false
			end
		end
	end)
end

function G.stopNoclipLoop()
	if G.noclipConn then
		G.noclipConn:Disconnect()
		G.noclipConn = nil
	end
end

function G.stopMomentum()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

function G.waitForAlive(timeout)
	local deadline = tick() + (timeout or 12)
	while tick() < deadline do
		local c = player.Character
		local h = c and c:FindFirstChildOfClass("Humanoid")
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if c and c.Parent and h and r and h.Health > 0 then
			return c, r, h
		end
		task.wait(0.1)
	end
	return nil
end

function G.cancelTween()
	if State.activeTween then
		State.activeTween:Cancel()
		State.activeTween = nil
	end
	State.tweenTargetPosition = nil
	G.stopMomentum()
end

function G.getIslandNamesAndMap(pid)
	local islandMap = {}
	local worldName = "Unknown"
	if pid == 2753915549 or pid == 85211729168715 then
		worldName = "First Sea"
		islandMap = {
			["Starter Island"] = Vector3.new(1122, 16, 1424),
			["Marine Starter"] = Vector3.new(-2750, 32, 2041),
			["Jungle island"] = Vector3.new(-1432, 62, 2),
			["Pirate island"] = Vector3.new(-1190, 66, 3879),
			["Desert island"] = Vector3.new(942, 21, 4378),
			["Middle Town"] = Vector3.new(-785, 74, 1606),
			["Snow island"] = Vector3.new(1353, 106, -1326),
			["MarineBase island"] = Vector3.new(-4684, 6, 4185),
			["Sky 1"] = Vector3.new(-4879, 960, -833),
			["Sky 2"] = Vector3.new(-6000, 5494, 2136),
			["Sky 3"] = Vector3.new(-7347, 5793, 374),
			["Colosseum"] = Vector3.new(-1366, 13, -2902),
			["Magma island"] = Vector3.new(-5395, 27, 8527),
			["Prison island"] = Vector3.new(5008, 89, 740),
			["Whirl Pool"] = Vector3.new(3874, 5, -1904),
			["Underwater city"] = Vector3.new(61170, 6, 1824),
			["Fountain City"] = Vector3.new(5168, 76, 4049),
		}
	elseif pid == 4442272183 or pid == 79091703265657 then
		worldName = "Second Sea"
		islandMap = {
			["Dock 1"] = Vector3.new(-13, 39, 2702),
			["Dock 2"] = Vector3.new(-1917, 6, -2549),
			["Cafe"] = Vector3.new(-386, 73, 297),
			["Upper Green Zone"] = Vector3.new(-2577, 1628, -3742),
			["Green Zone"] = Vector3.new(-2456, 87, -3188),
			["Graveyard"] = Vector3.new(-5645, 185, -886),
			["Snow Mountain"] = Vector3.new(722, 406, -5290),
			["Hot and Cold"] = Vector3.new(-5557, 123, -5088),
			["Cursed Ship"] = Vector3.new(-6505, 83, -128),
			["Ice Castle"] = Vector3.new(6001, 294, -6614),
			["Forgotten Island"] = Vector3.new(-3045, 240, -10144),
			["Dark Arena"] = Vector3.new(3382, 13, -3449),
			["Usopp"] = Vector3.new(4752, 8, 2850),
		}
	elseif pid == 7449423635 or pid == 100117331123089 then
		worldName = "Third Sea"
		islandMap = {
			["Port Town"] = Vector3.new(-341, 21, 5541),
			["Hydra Town"] = Vector3.new(5293, 1005, 391),
			["Hydra Arena"] = Vector3.new(5028, 174, -2007),
			["Great Tree"] = Vector3.new(4325, 566, -6152),
			["Upper Great Tree"] = Vector3.new(3038, 2282, -7337),
			["Haunted Castle"] = Vector3.new(-9514, 142, 5536),
			["Bigmom island"] = Vector3.new(-887, 66, -10905),
			["Tiki Outpost"] = Vector3.new(-16410, 528, 415),
			["Mansion"] = Vector3.new(-12462, 375, -7552),
			["Castle on the Sea"] = Vector3.new(-4994, 315, -3007),
			["Peanut island"] = Vector3.new(-2122, 38, -10139),
			["Katakuri island"] = Vector3.new(-2094, 70, -12112),
			["Chocolate island"] = Vector3.new(66, 25, -12073),
			["North Pole"] = Vector3.new(-1091, 64, -14522),
		}
	else
		worldName = "Unknown Sea"
		islandMap = { ["Unknown"] = Vector3.new(0, 0, 0) }
	end
	local names = {}
	for k in pairs(islandMap) do
		table.insert(names, k)
	end
	table.sort(names)
	return names, islandMap, worldName
end

local islandNames, islandMap, worldName = G.getIslandNamesAndMap(G.placeId)

function G.Convert_CFrame(x)
	if not x then
		return nil
	end
	if typeof(x) == "Vector3" then
		return CFrame.new(x)
	elseif typeof(x) == "CFrame" then
		return x
	elseif typeof(x) == "Instance" and x:IsA("Model") then
		return x:GetPivot()
	elseif typeof(x) == "Instance" and x:IsA("BasePart") then
		return x.CFrame
	elseif typeof(x) == "table" and x.CFrame then
		return x.CFrame
	end
	return nil
end

function G.GetDistance(POS_1, POS_2)
	if POS_1 == nil then
		return 9e9
	end
	local c = player.Character
	if not c then
		return 9e9
	end
	local h = c:FindFirstChildOfClass("Humanoid")
	if not h or not h.Health or h.Health <= 0 then
		return 9e9
	end
	if POS_2 == nil then
		POS_2 = c:FindFirstChild("HumanoidRootPart")
		if not POS_2 then
			return 9e9
		end
	end
	local pos1 = G.Convert_CFrame(POS_1)
	local pos2 = G.Convert_CFrame(POS_2)
	if not pos1 or not pos2 then
		return 9e9
	end
	return (pos1.Position - pos2.Position).Magnitude
end

function G.moveToTarget(hrp, targetCF, dt)
	if not hrp or not hrp.Parent or not targetCF then
		return
	end
	local hrpPos = hrp.Position
	if
		not State.currentFlyCF
		or not State.currentFlyCF.Position
		or (State.currentFlyCF.Position - hrpPos).Magnitude > 150
	then
		State.currentFlyCF = hrp.CFrame
	end
	local targetPos = targetCF.Position
	local currentPos = State.currentFlyCF.Position
	local delta = targetPos - currentPos
	local dist = delta.Magnitude
	local step = (State.SPEED or 200) * dt
	local newPos = (dist <= step or dist < 0.01) and targetPos or currentPos + (delta / dist) * step
	local rx, ry, rz = targetCF:ToEulerAnglesXYZ()
	local finalCF = CFrame.new(newPos) * CFrame.fromEulerAnglesXYZ(rx, ry, rz)
	State.currentFlyCF = finalCF
	pcall(function()
		hrp.CFrame = finalCF
	end)
end

G.Conns = { tweenIsland = nil }

G.UNDERWATER_GATE = CFrame.new(
	4050.31104,
	-1.68800354,
	-1814.12402,
	-0.955315053,
	0,
	-0.295594245,
	0,
	1,
	0,
	0.295594245,
	0,
	-0.955315053
)
G.SKY_GATE = CFrame.new(
	-4192.70508,
	1087.56738,
	-366.055603,
	0.49432373,
	0.0971033573,
	0.863837361,
	-0.014543999,
	0.994526088,
	-0.103471309,
	-0.869156241,
	0.0385846794,
	0.493030131
)
G.SKY_EXIT =
	CFrame.new(-6022.23535, 5470.49902, 2217.33374, -0.990270376, 0, 0.13915664, 0, 1, 0, -0.13915664, 0, -0.990270376)
G.UNDERWATER_EXIT =
	CFrame.new(61170.0469, -2, 1952.83398, 0.922186494, 0, 0.386753023, 0, 1, 0, -0.386753023, 0, 0.922186494)

G.SKY_AREA_POS = Vector3.new(-7000, 5500, 0)
G.SKY_AREA_RADIUS = 5000

G.SKY_MOB_NAMES = {
	["Sky 2"] = true,
	["Sky 3"] = true,
	["Shanda"] = true,
	["Royal Soldier"] = true,
	["Royal Squad"] = true,
	["Thunder God"] = true,
	["God's Guard"] = true,
	["Dark Master"] = true,
	["Sky Bandit"] = true,
	["Sky Warlord"] = true,
}

G.UNDERWATER_MOB_NAMES = {
	["Underwater city"] = true,
	["Fishman Warrior"] = true,
	["Fishman Commando"] = true,
	["Fishman Lord"] = true,
}

G.SKY_DEST_POSITIONS = {
	["Sky 2"] = Vector3.new(-5999, 5494, 2135),
	["Sky 3"] = Vector3.new(-7332, 5792, 378),
	["Shanda"] = Vector3.new(-5929, 5469, 1829),
	["Royal Soldier"] = Vector3.new(-7054, 5541, 933),
	["Royal Squad"] = Vector3.new(-6807, 5550, 1185),
	["Thunder God"] = Vector3.new(-7121, 5594, 199),
	["Sky Warlord"] = Vector3.new(-6257, 5474, 1829),
	["God's Guard"] = Vector3.new(-4307, 1087, -459),
	["Dark Master"] = Vector3.new(-5300, 502, -358),
	["Sky Bandit"] = Vector3.new(-5110, 280, -1014),
}

G.UNDERWATER_DEST_POSITIONS = {
	["Underwater city"] = Vector3.new(61170, 6, 1824),
	["Fishman Warrior"] = Vector3.new(61170, 6, 1824),
	["Fishman Commando"] = Vector3.new(61170, 6, 1824),
	["Fishman Lord"] = Vector3.new(61170, 6, 1824),
}

function G.inSkyArea(pos)
	if not pos then
		return false
	end
	return pos.Y > 3000 or (pos - G.SKY_AREA_POS).Magnitude <= G.SKY_AREA_RADIUS
end

function G.inUnderwaterArea(pos)
	if not pos then
		return false
	end
	return pos.X > 50000 or pos.X < -50000
end

G.exitRouteActive = false
G.exitRouteList = {}
G.exitRouteIndex = 1
G.exitRouteConn = nil

function G.stopExitRoute()
	G.exitRouteActive = false
	G.exitRouteList = {}
	G.exitRouteIndex = 1
	if G.exitRouteConn then
		G.exitRouteConn:Disconnect()
		G.exitRouteConn = nil
	end
end

function G.getExitRoute(currentPos)
	local route = {}
	if G.inSkyArea(currentPos) then
		table.insert(route, G.SKY_EXIT)
	elseif G.inUnderwaterArea(currentPos) then
		table.insert(route, G.UNDERWATER_EXIT)
	end
	return route
end

function G.startExitRoute(onDone)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		if onDone then
			onDone()
		end
		return
	end

	local exits = G.getExitRoute(hrp.Position)
	if #exits == 0 then
		if onDone then
			onDone()
		end
		return
	end

	G.stopExitRoute()
	G.exitRouteActive = true
	G.exitRouteList = exits
	G.exitRouteIndex = 1

	local waitingForWarp = false
	local warpWaitPos = nil
	local warpWaitStart = 0
	local WARP_TRIGGER = 30
	local WARP_TIMEOUT = 10

	G.exitRouteConn = RunService.Heartbeat:Connect(function(dt)
		if not G.exitRouteActive then
			G.stopExitRoute()
			return
		end

		local c = player.Character
		local h = c and c:FindFirstChild("HumanoidRootPart")
		local hum = c and c:FindFirstChildOfClass("Humanoid")
		if not h or not hum or hum.Health <= 0 then
			return
		end

		if waitingForWarp then
			local movedDist = (h.Position - warpWaitPos).Magnitude
			local timedOut = (tick() - warpWaitStart) > WARP_TIMEOUT
			if movedDist > WARP_TRIGGER or timedOut then
				waitingForWarp = false
				warpWaitPos = nil
				State.currentFlyCF = h.CFrame
				G.exitRouteIndex = G.exitRouteIndex + 1
				G.stopMomentum()
			else
				pcall(function()
					h.AssemblyLinearVelocity = Vector3.zero
					h.AssemblyAngularVelocity = Vector3.zero
				end)
				return
			end
		end

		if G.exitRouteIndex > #G.exitRouteList then
			G.stopExitRoute()
			State.currentFlyCF = h.CFrame
			if onDone then
				onDone()
			end
			return
		end

		local targetCF = G.exitRouteList[G.exitRouteIndex]
		local currentPos = State.currentFlyCF and State.currentFlyCF.Position or h.Position
		local dist = (targetCF.Position - currentPos).Magnitude

		if dist > 6 then
			G.moveToTarget(h, targetCF, dt)
		else
			State.currentFlyCF = targetCF
			pcall(function()
				h.CFrame = targetCF
				h.AssemblyLinearVelocity = Vector3.zero
				h.AssemblyAngularVelocity = Vector3.zero
			end)

			local isLast = (G.exitRouteIndex >= #G.exitRouteList)
			if isLast then
				G.stopExitRoute()
				State.currentFlyCF = h.CFrame
				if onDone then
					onDone()
				end
			else
				waitingForWarp = true
				warpWaitPos = targetCF.Position
				warpWaitStart = tick()
			end
		end
	end)
end

function G.normalizeMobName(name)
	local normalized = name or ""
	normalized = normalized:gsub("%b[]", "")
	normalized = normalized:gsub("%s+", " ")
	normalized = normalized:gsub("^%s+", "")
	normalized = normalized:gsub("%s+$", "")
	return normalized
end

function G.stripDisplayName(displayName)
	local stripped = displayName
		:gsub("%s*%[Lv%.?%s*%d+%]", "")
		:gsub("%s*%[Raid Boss%]", "")
		:gsub("%s*%[Boss%]", "")
		:gsub("%s+$", "")
		:gsub("^%s+", "")
	return stripped
end

function G.getMobDisplayName(mob)
	local humanoid = mob and mob:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.DisplayName and humanoid.DisplayName ~= "" then
		return humanoid.DisplayName
	end
	return mob and mob.Name or ""
end

function G.getMobBaseName(mob)
	local humanoid = mob and mob:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.DisplayName and humanoid.DisplayName ~= "" then
		return G.stripDisplayName(humanoid.DisplayName)
	end
	return G.normalizeMobName(mob and mob.Name or "")
end

function G.getEnemySpawnsFolder()
	local ok, folder = pcall(function()
		local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
		return worldOrigin and worldOrigin:FindFirstChild("EnemySpawns")
	end)
	if ok then
		return folder
	end
	return nil
end

function G.bossTypeFromText(text)
	if not text or text == "" then
		return nil
	end
	local lower = tostring(text):lower()
	if lower:find("%[raid boss%]") or lower:find("raid boss") or lower:find("raidboss") then
		return "raidboss"
	elseif lower:find("%[boss%]") or lower:find("boss") then
		return "boss"
	end
	return nil
end

function G.bossTypeFromInstance(inst)
	if not inst then
		return nil
	end
	local best = G.bossTypeFromText(inst.Name)
	local okAttr, attrs = pcall(function()
		return inst:GetAttributes()
	end)
	if okAttr and attrs then
		for key, value in pairs(attrs) do
			local keyType = G.bossTypeFromText(key)
			if keyType and value then
				if keyType == "raidboss" then
					return "raidboss"
				end
				best = best or keyType
			end
			if type(value) == "string" then
				local valType = G.bossTypeFromText(value)
				if valType == "raidboss" then
					return "raidboss"
				end
				best = best or valType
			end
		end
	end
	local okDesc, descendants = pcall(function()
		return inst:GetDescendants()
	end)
	if okDesc and descendants then
		for _, child in ipairs(descendants) do
			if child:IsA("Humanoid") and child.DisplayName and child.DisplayName ~= "" then
				local dnType = G.bossTypeFromText(child.DisplayName)
				if dnType == "raidboss" then
					return "raidboss"
				end
				best = best or dnType
			elseif child:IsA("StringValue") then
				local vType = G.bossTypeFromText(child.Value)
				if vType == "raidboss" then
					return "raidboss"
				end
				best = best or vType
			end
		end
	end
	return best
end

function G.buildBossMap()
	local map = {}

	local function register(inst)
		if not inst then
			return
		end
		local bossType = G.bossTypeFromInstance(inst)
		if not bossType then
			return
		end
		local keys = {
			G.normalizeMobName(inst.Name),
			G.normalizeMobName(G.getMobBaseName(inst)),
		}
		local hum = inst:FindFirstChildOfClass("Humanoid")
		if hum and hum.DisplayName and hum.DisplayName ~= "" then
			table.insert(keys, G.normalizeMobName(G.stripDisplayName(hum.DisplayName)))
		end
		for _, key in ipairs(keys) do
			if key ~= "" then
				if bossType == "raidboss" or not map[key] then
					map[key] = bossType
				end
			end
		end
	end

	if enemiesFolder then
		for _, mob in ipairs(enemiesFolder:GetChildren()) do
			register(mob)
		end
	end
	local spawns = G.getEnemySpawnsFolder()
	if spawns then
		for _, obj in ipairs(spawns:GetChildren()) do
			register(obj)
		end
	end
	return map
end

G.bossMapCache = nil

function G.refreshBossMap()
	G.bossMapCache = G.buildBossMap()
	return G.bossMapCache
end

function G.isMobBoss(rawName)
	local wanted = G.normalizeMobName(rawName)
	if wanted == "" then
		return nil
	end
	local map = G.bossMapCache or G.refreshBossMap()
	if map[wanted] then
		return map[wanted]
	end
	map = G.refreshBossMap()
	if map[wanted] then
		return map[wanted]
	end
	return G.bossTypeFromText(rawName)
end

function G.makeMobLabel(rawName)
	local bossType = G.isMobBoss(rawName)
	if bossType == "raidboss" then
		return rawName .. "  [Raid Boss]"
	elseif bossType == "boss" then
		return rawName .. "  [Boss]"
	end
	return rawName
end

function G.labelToRawName(label)
	local raw = label:gsub("%s*%[Raid Boss%]", ""):gsub("%s*%[Boss%]", "")
	return raw
end

function G.mobMatchesName(mob, wantedName)
	if not mob or not wantedName or wantedName == "" then
		return false
	end
	local mobRawName = G.normalizeMobName(mob.Name)
	local mobDispName = G.normalizeMobName(G.getMobDisplayName(mob))
	local mobBaseName = G.normalizeMobName(G.getMobBaseName(mob))
	local wanted = G.normalizeMobName(wantedName)
	return mobRawName == wanted or mobDispName == wanted or mobBaseName == wanted
end

function G.sameMobType(firstMob, secondMob)
	if not firstMob or not secondMob then
		return false
	end
	local fn = G.getMobBaseName(firstMob)
	local sn = G.getMobBaseName(secondMob)
	return G.normalizeMobName(fn) == G.normalizeMobName(sn)
		or G.normalizeMobName(firstMob.Name) == G.normalizeMobName(secondMob.Name)
end

G.SPAWN_IGNORE_NAMES = {
	["Part"] = true,
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["HumanoidRootPart"] = true,
	["Spawn"] = true,
}

function G.getReplicatedSpawnFolder()
	local ok, folder = pcall(function()
		return game:GetService("ReplicatedStorage"):FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
	end)
	if ok and folder then
		return folder
	end
	return nil
end

function G.getSpawnFolders()
	local folders = {}
	local repSpawn = G.getReplicatedSpawnFolder()
	if repSpawn then
		table.insert(folders, { source = "REP", folder = repSpawn })
	end
	local spawns = G.getEnemySpawnsFolder()
	if spawns then
		table.insert(folders, { source = "WS", folder = spawns })
	end
	if enemiesFolder then
		table.insert(folders, { source = "ENEMIES", folder = enemiesFolder })
	end
	return folders
end

function G.collectSpawnPosition(obj)
	if G.SPAWN_IGNORE_NAMES[obj.Name] then
		return nil
	end
	if obj:IsA("Model") then
		local r = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
		if r then
			return r.Position
		end
	elseif obj:IsA("BasePart") then
		return obj.Position
	end
	return nil
end

function G.getSpawnPositionsForMob(wantedName)
	local wanted = G.normalizeMobName(wantedName or "")
	if wanted == "" then
		return {}
	end
	local positions, seen = {}, {}

	local repFolder = G.getReplicatedSpawnFolder()
	if repFolder then
		pcall(function()
			for _, obj in ipairs(repFolder:GetChildren()) do
				if G.SPAWN_IGNORE_NAMES[obj.Name] then
					continue
				end
				if G.normalizeMobName(obj.Name) == wanted then
					local pos = nil
					if obj:IsA("BasePart") then
						pos = obj.Position
					elseif obj:IsA("Model") then
						local r = obj.PrimaryPart
							or obj:FindFirstChild("HumanoidRootPart")
							or obj:FindFirstChildWhichIsA("BasePart")
						if r then
							pos = r.Position
						end
					elseif obj:IsA("CFrameValue") then
						pos = obj.Value.Position
					elseif obj:IsA("Vector3Value") then
						pos = obj.Value
					end
					if pos then
						local key = G.positionKey(pos)
						if not seen[key] then
							seen[key] = true
							table.insert(positions, pos)
						end
					end
				end
				for _, child in ipairs(obj:GetChildren()) do
					if G.SPAWN_IGNORE_NAMES[child.Name] then
						continue
					end
					if G.normalizeMobName(child.Name) == wanted or G.normalizeMobName(obj.Name) == wanted then
						local pos = nil
						if child:IsA("BasePart") then
							pos = child.Position
						elseif child:IsA("CFrameValue") then
							pos = child.Value.Position
						elseif child:IsA("Vector3Value") then
							pos = child.Value
						end
						if pos then
							local key = G.positionKey(pos)
							if not seen[key] then
								seen[key] = true
								table.insert(positions, pos)
							end
						end
					end
				end
			end
		end)
	end

	if #positions == 0 then
		for _, entry in ipairs(G.getSpawnFolders()) do
			if entry.source == "REP" then
				continue
			end
			pcall(function()
				for _, obj in ipairs(entry.folder:GetDescendants()) do
					if (obj:IsA("BasePart") or obj:IsA("Model")) and G.spawnObjMatchesName(obj, wanted) then
						local pos = G.collectSpawnPosition(obj)
						if pos then
							local key = G.positionKey(pos)
							if not seen[key] then
								seen[key] = true
								table.insert(positions, pos)
							end
						end
					end
				end
			end)
		end
	end

	return positions
end

function G.getAllSpawnPositions()
	local positions, seen = {}, {}

	local function push(pos)
		if not pos then
			return
		end
		local key = G.positionKey(pos)
		if not seen[key] then
			seen[key] = true
			table.insert(positions, pos)
		end
	end

	local repFolder = G.getReplicatedSpawnFolder()
	if repFolder then
		pcall(function()
			for _, obj in ipairs(repFolder:GetChildren()) do
				if G.SPAWN_IGNORE_NAMES[obj.Name] then
					continue
				end
				if obj:IsA("BasePart") then
					push(obj.Position)
				elseif obj:IsA("Model") then
					local r = obj.PrimaryPart
						or obj:FindFirstChild("HumanoidRootPart")
						or obj:FindFirstChildWhichIsA("BasePart")
					if r then
						push(r.Position)
					end
				elseif obj:IsA("CFrameValue") then
					push(obj.Value.Position)
				elseif obj:IsA("Vector3Value") then
					push(obj.Value)
				end
				for _, child in ipairs(obj:GetChildren()) do
					if G.SPAWN_IGNORE_NAMES[child.Name] then
						continue
					end
					if child:IsA("BasePart") then
						push(child.Position)
					elseif child:IsA("CFrameValue") then
						push(child.Value.Position)
					elseif child:IsA("Vector3Value") then
						push(child.Value)
					end
				end
			end
		end)
	end

	if #positions == 0 then
		local spawns = G.getEnemySpawnsFolder()
		if spawns then
			pcall(function()
				for _, obj in ipairs(spawns:GetDescendants()) do
					if obj:IsA("BasePart") or obj:IsA("Model") then
						if not G.SPAWN_IGNORE_NAMES[obj.Name] then
							push(G.collectSpawnPosition(obj))
						end
					end
				end
			end)
		end
		if #positions == 0 and enemiesFolder then
			for _, mob in ipairs(enemiesFolder:GetChildren()) do
				local r = mob:FindFirstChild("HumanoidRootPart")
				if r then
					push(r.Position)
				end
			end
		end
	end

	return positions
end

function G.spawnObjMatchesName(obj, wanted)
	if G.normalizeMobName(obj.Name) == wanted then
		return true
	end
	if G.normalizeMobName(G.getMobBaseName(obj)) == wanted then
		return true
	end
	local hum = obj:FindFirstChildOfClass("Humanoid")
	if hum and hum.DisplayName and hum.DisplayName ~= "" then
		if G.normalizeMobName(G.stripDisplayName(hum.DisplayName)) == wanted then
			return true
		end
	end
	return false
end

function G.positionKey(pos)
	local grid = 5
	return string.format(
		"%d_%d_%d",
		math.floor((pos.X / grid) + 0.5),
		math.floor((pos.Y / grid) + 0.5),
		math.floor((pos.Z / grid) + 0.5)
	)
end

function G.countAliveByName(wantedName)
	local count = 0
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if G.mobMatchesName(enemy, wantedName) then
			local hum = enemy:FindFirstChildOfClass("Humanoid")
			local root = enemy:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 then
				count = count + 1
			end
		end
	end
	return count
end

G.spawnCountCache = {}
G.spawnCountCacheTime = {}
G.SPAWN_CACHE_TTL = 30

function G.getSpawnCount(wantedName)
	local now = tick()
	local cached = G.spawnCountCache[wantedName]
	local cachedTime = G.spawnCountCacheTime[wantedName] or 0
	if cached and (now - cachedTime) < G.SPAWN_CACHE_TTL then
		return cached
	end
	local count = #G.getSpawnPositionsForMob(wantedName)
	G.spawnCountCache[wantedName] = count
	G.spawnCountCacheTime[wantedName] = now
	return count
end

function G.isSpawnFull(wantedName)
	local spawnCount = G.getSpawnCount(wantedName)
	if spawnCount == 0 then
		return false
	end
	local aliveCount = G.countAliveByName(wantedName)
	return aliveCount >= spawnCount
end

function G.isAllSelectedSpawnFull()
	local names = State.selectedMobNames
	if not names or #names == 0 then
		return false
	end
	for _, name in ipairs(names) do
		if not G.isSpawnFull(name) then
			return false
		end
	end
	return true
end

G.skyRouteCache = {}
G.underwaterRouteCache = {}

function G.isSkyRoute(name)
	if G.skyRouteCache[name] ~= nil then
		return G.skyRouteCache[name]
	end
	if G.SKY_MOB_NAMES[name] == true then
		G.skyRouteCache[name] = true
		return true
	end
	local ok, positions = pcall(G.getSpawnPositionsForMob, name)
	if not ok or not positions then
		G.skyRouteCache[name] = false
		return false
	end
	for _, pos in ipairs(positions) do
		if G.inSkyArea(pos) then
			G.skyRouteCache[name] = true
			return true
		end
	end
	G.skyRouteCache[name] = false
	return false
end

function G.isUnderwaterRoute(name)
	if G.underwaterRouteCache[name] ~= nil then
		return G.underwaterRouteCache[name]
	end
	if G.UNDERWATER_MOB_NAMES[name] == true then
		G.underwaterRouteCache[name] = true
		return true
	end
	local ok, positions = pcall(G.getSpawnPositionsForMob, name)
	if not ok or not positions then
		G.underwaterRouteCache[name] = false
		return false
	end
	for _, pos in ipairs(positions) do
		if G.inUnderwaterArea(pos) then
			G.underwaterRouteCache[name] = true
			return true
		end
	end
	G.underwaterRouteCache[name] = false
	return false
end

function G.buildIslandRoute(name, destPos, currentPos)
	local route = {}

	if not G.sea1 then
		table.insert(route, CFrame.new(destPos))
		return route, true
	end

	local fromSky = G.inSkyArea(currentPos)
	local fromUnderwater = G.inUnderwaterArea(currentPos)

	if G.isUnderwaterRoute(name) then
		if fromSky then
			table.insert(route, G.SKY_EXIT)
		end
		if not fromUnderwater then
			table.insert(route, G.UNDERWATER_GATE)
		end
		local finalPos = G.UNDERWATER_DEST_POSITIONS[name] or destPos
		table.insert(route, CFrame.new(finalPos))
		return route, true
	end

	if G.isSkyRoute(name) then
		if fromUnderwater then
			table.insert(route, G.UNDERWATER_EXIT)
		end
		if not fromSky then
			table.insert(route, G.SKY_GATE)
		end
		local finalPos = G.SKY_DEST_POSITIONS[name] or destPos
		table.insert(route, CFrame.new(finalPos))
		return route, true
	end

	if fromSky then
		table.insert(route, G.SKY_EXIT)
	elseif fromUnderwater then
		table.insert(route, G.UNDERWATER_EXIT)
	end
	table.insert(route, CFrame.new(destPos))
	return route, true
end

function G.stopTweenIsland()
	State.teleportTweenEnabled = false
	State.islandRoute = nil
	State.islandRouteIndex = 1
	State.waitingForWarpPos = nil
	if G.Conns.tweenIsland then
		G.Conns.tweenIsland:Disconnect()
		G.Conns.tweenIsland = nil
	end
end

function G.startTweenIsland()
	G.stopTweenIsland()
	if not State.selectedIslandPos then
		return
	end
	State.teleportTweenEnabled = true

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		State.currentFlyCF = hrp.CFrame
	end

	State.islandRoute = G.buildIslandRoute(State.selectedIslandName, State.selectedIslandPos, hrp and hrp.Position)
	State.islandRouteIndex = 1

	G.Conns.tweenIsland = RunService.Heartbeat:Connect(function(dt)
		if not State.teleportTweenEnabled then
			G.stopTweenIsland()
			return
		end
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then
			return
		end

		if State.waitingForWarpPos then
			local waitPos = State.waitingForWarpPos
			local movedDist = (hrp.Position - waitPos).Magnitude
			local timedOut = (tick() - State.warpWaitStart) > State.WARP_WAIT_TIMEOUT
			if movedDist > State.WARP_TRIGGER_DIST or timedOut then
				State.waitingForWarpPos = nil
				State.currentFlyCF = hrp.CFrame
				State.islandRouteIndex = (State.islandRouteIndex or 1) + 1
				G.stopMomentum()
			else
				pcall(function()
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
				end)
				return
			end
		end

		local route = State.islandRoute
		if not route or #route == 0 then
			route = G.buildIslandRoute(State.selectedIslandName, State.selectedIslandPos, hrp.Position)
			State.islandRoute = route
			State.islandRouteIndex = 1
		end

		if State.islandRouteIndex > #route then
			G.stopTweenIsland()
			Fluent:Notify({
				Title = "Island",
				Content = "Arrived at " .. (State.selectedIslandName or ""),
				Duration = 3,
			})
			return
		end

		local idx = math.clamp(State.islandRouteIndex, 1, #route)
		local targetCF = route[idx]
		local isLast = (idx >= #route)

		local currentPos = State.currentFlyCF and State.currentFlyCF.Position or hrp.Position
		local dist = (targetCF.Position - currentPos).Magnitude

		if dist > 6 then
			G.moveToTarget(hrp, targetCF, dt)
			return
		end

		State.currentFlyCF = targetCF
		pcall(function()
			hrp.CFrame = targetCF
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end)

		if isLast then
			G.stopTweenIsland()
			Fluent:Notify({
				Title = "Island",
				Content = "Arrived at " .. (State.selectedIslandName or ""),
				Duration = 3,
			})
			return
		end

		State.waitingForWarpPos = targetCF.Position
		State.warpWaitStart = tick()
	end)
end

function G.sortPositionsByDistance(positions, fromPos)
	table.sort(positions, function(a, b)
		return (a - fromPos).Magnitude < (b - fromPos).Magnitude
	end)
	return positions
end

function G.getAvailableMobNames()
	local names = {}
	local seen = {}

	local function add(name)
		local clean = G.normalizeMobName(name)
		if clean ~= "" and not seen[clean] then
			seen[clean] = true
			table.insert(names, clean)
		end
	end

	local spawns = G.getEnemySpawnsFolder()
	if spawns then
		for _, obj in ipairs(spawns:GetChildren()) do
			add(obj.Name)
		end
	end

	if enemiesFolder then
		for _, mob in ipairs(enemiesFolder:GetChildren()) do
			add(mob.Name)
			add(G.getMobBaseName(mob))
		end
	end

	G.refreshBossMap()
	table.sort(names)
	return names
end

function G.mobTypeExistsInFolder(wantedName)
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if G.mobMatchesName(enemy, wantedName) then
			local hum = enemy:FindFirstChildOfClass("Humanoid")
			local root = enemy:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 then
				return true
			end
		end
	end
	return false
end

function G.getActiveSelectedMobName()
	local names = State.selectedMobNames
	if not names or #names == 0 then
		return nil
	end
	if State.selectedMobIndex < 1 or State.selectedMobIndex > #names then
		State.selectedMobIndex = 1
	end
	return names[State.selectedMobIndex]
end

function G.advanceSelectedMobIndex()
	local names = State.selectedMobNames
	if not names or #names == 0 then
		return false
	end
	for _ = 1, #names do
		State.selectedMobIndex = (State.selectedMobIndex % #names) + 1
		if G.mobTypeExistsInFolder(names[State.selectedMobIndex]) then
			return true
		end
	end
	State.selectedMobIndex = 1
	return false
end

function G.getHighestPriorityAliveEnemy(position)
	local names = State.selectedMobNames
	if not names or #names == 0 then
		return nil, nil
	end

	if State.selectedMobIndex < 1 or State.selectedMobIndex > #names then
		State.selectedMobIndex = 1
	end

	local wantedName = names[State.selectedMobIndex]
	local closestEnemy = nil
	local closestDistance = math.huge
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if G.mobMatchesName(enemy, wantedName) then
			local hum = enemy:FindFirstChildOfClass("Humanoid")
			local root = enemy:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 then
				local dist = (root.Position - position).Magnitude
				if dist < closestDistance then
					closestDistance = dist
					closestEnemy = enemy
				end
			end
		end
	end
	return closestEnemy, wantedName
end

function G.getClosestAliveEnemyNears(position)
	local closestEnemy = nil
	local closestDistance = math.huge
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		local hum = enemy:FindFirstChildOfClass("Humanoid")
		local root = enemy:FindFirstChild("HumanoidRootPart")
		if hum and root and hum.Health > 0 then
			local distance = (root.Position - position).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestEnemy = enemy
			end
		end
	end
	return closestEnemy
end

function G.getClosestAliveEnemy(position, wantedName)
	if wantedName and wantedName ~= "" then
		local closestEnemy = nil
		local closestDistance = math.huge
		for _, enemy in ipairs(enemiesFolder:GetChildren()) do
			if G.mobMatchesName(enemy, wantedName) then
				local hum = enemy:FindFirstChildOfClass("Humanoid")
				local root = enemy:FindFirstChild("HumanoidRootPart")
				if hum and root and hum.Health > 0 then
					local dist = (root.Position - position).Magnitude
					if dist < closestDistance then
						closestDistance = dist
						closestEnemy = enemy
					end
				end
			end
		end
		return closestEnemy
	end
	return G.getClosestAliveEnemyNears(position)
end

function G.isEnemyAlive(enemy)
	if not enemy or not enemy.Parent then
		return false
	end
	local humanoid = enemy:FindFirstChildOfClass("Humanoid")
	local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
	if not humanoid or not enemyRoot then
		return false
	end
	return humanoid.Health > 0
end

local RegisterAttack, RegisterHit

function G.findRemotes()
	pcall(function()
		local Modules = ReplicatedStorage:FindFirstChild("Modules")
		if not Modules then
			return
		end
		local Net = Modules:FindFirstChild("Net")
		if not Net then
			return
		end
		RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
		RegisterHit = Net:FindFirstChild("RE/RegisterHit")
	end)

	if not RegisterHit or not RegisterAttack then
		pcall(function()
			for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
				if obj:IsA("RemoteEvent") then
					local n = obj.Name:lower()
					if n:find("registerhit") or n:find("register_hit") or n == "re/registerhit" then
						RegisterHit = obj
					end
					if n:find("registerattack") or n:find("register_attack") or n == "re/registerattack" then
						RegisterAttack = obj
					end
				end
			end
		end)
	end
end

G.findRemotes()

G.HitRegistrationModule = {}

function G.HitRegistrationModule.Execute()
	local char = player.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local hitTargets = {}

	local function scanFolder(folder)
		if not folder then
			return
		end
		for _, target in ipairs(folder:GetChildren()) do
			local hum = target:FindFirstChildOfClass("Humanoid")
			local root = target:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 and target ~= char then
				local dist = (root.Position - hrp.Position).Magnitude
				if dist <= State.ATTACK_RANGE then
					for _, child in ipairs(target:GetChildren()) do
						if child:IsA("BasePart") then
							table.insert(hitTargets, { target, child })
						end
					end
				end
			end
		end
	end

	local chars = workspace:FindFirstChild("Characters")
	scanFolder(enemiesFolder)
	scanFolder(chars)

	local tool = char:FindFirstChildOfClass("Tool")
	local weaponType = tool and tool:GetAttribute("WeaponType")

	if #hitTargets > 0 and tool and (weaponType == "Melee" or weaponType == "Sword") then
		local ok, seed = pcall(function()
			return Net and Net:FindFirstChild("seed") and Net.seed:InvokeServer()
		end)
		if not ok or not seed then
			seed = math.random(1000, 9999)
		end

		RegisterAttack:FireServer()
		local targetHead = hitTargets[1][1]:FindFirstChild("Head")
		if not targetHead then
			return
		end
		RegisterHit:FireServer(targetHead, hitTargets, {})

		if Refs2.AttackRemoteTarget and Refs2.AttackRemoteId then
			pcall(function()
				local remoteCode = "RE/RegisterHit"
				local encryptionKey = math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1
				local encodedString = string.gsub(remoteCode, ".", function(ch)
					return string.char(bit32.bxor(string.byte(ch), encryptionKey))
				end)
				local finalId = bit32.bxor(Refs2.AttackRemoteId + 909090, seed * 2)
				local cloneref2 = cloneref or function(o)
					return o
				end
				cloneref2(Refs2.AttackRemoteTarget):FireServer(encodedString, finalId, targetHead, hitTargets)
			end)
		end
	end
end

G.WEAPON_TYPE_KEYWORDS = {
	Melee = { "Melee", "melee" },
	Sword = { "Sword", "sword" },
	Fruit = { "Fruit", "fruit" },
	Gun = { "Gun", "gun" },
}

function G.getToolTooltip(tool)
	local tooltipAttr = tool:GetAttribute("ToolTip")
		or tool:GetAttribute("Tooltip")
		or tool:GetAttribute("Type")
		or tool:GetAttribute("WeaponType")
	if tooltipAttr then
		return tostring(tooltipAttr):lower()
	end
	local tooltipVal = tool:FindFirstChild("ToolTip") or tool:FindFirstChild("Tooltip") or tool:FindFirstChild("Type")
	if tooltipVal and (tooltipVal:IsA("StringValue") or tooltipVal:IsA("IntValue")) then
		return tostring(tooltipVal.Value):lower()
	end
	return tool.Name:lower()
end

function G.findWeaponByType(wantedType)
	if not wantedType then
		return nil
	end
	local keywords = G.WEAPON_TYPE_KEYWORDS[wantedType]
	if not keywords then
		return nil
	end
	local sources = { player.Backpack }
	if player.Character then
		table.insert(sources, player.Character)
	end
	for _, container in ipairs(sources) do
		for _, item in ipairs(container:GetChildren()) do
			if item:IsA("Tool") then
				local tooltip = G.getToolTooltip(item)
				for _, kw in ipairs(keywords) do
					if tooltip:find(kw, 1, true) then
						return item
					end
				end
			end
		end
	end
	return nil
end

function G.autoEquipWeapon()
	if not State.autoEquipEnabled then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return
	end
	local currentTool = char:FindFirstChildOfClass("Tool")
	if currentTool then
		local tooltip = G.getToolTooltip(currentTool)
		local keywords = G.WEAPON_TYPE_KEYWORDS[State.selectedWeaponType] or {}
		for _, kw in ipairs(keywords) do
			if tooltip:find(kw, 1, true) then
				return
			end
		end
	end
	local target = G.findWeaponByType(State.selectedWeaponType)
	if target then
		pcall(function()
			hum:EquipTool(target)
		end)
	end
end

local FastAttackModule = { Rate = State.ATTACK_RATE }
G.Refs = {}

function FastAttackModule.GetNearbyTargets(char, folder)
	if not folder or not char then
		return {}
	end
	local charPos = char:GetPivot().Position
	local nearby = {}
	for _, target in ipairs(folder:GetChildren()) do
		local hum = target:FindFirstChildOfClass("Humanoid")
		local root = target:FindFirstChild("HumanoidRootPart")
		local matchesSelected = true
		if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
			local activeName = G.getActiveSelectedMobName()
			matchesSelected = activeName ~= nil and G.mobMatchesName(target, activeName)
		end
		if hum and root and hum.Health > 0 and matchesSelected then
			if (root.Position - charPos).Magnitude <= State.ATTACK_RANGE then
				table.insert(nearby, target)
			end
		end
	end
	return nearby
end

function FastAttackModule.GetTargetParts(targetList)
	local result = {}
	for _, target in ipairs(targetList) do
		local head = target:FindFirstChild("Head") or target.PrimaryPart
		if head then
			table.insert(result, { target, head })
		end
	end
	return result
end

function FastAttackModule.GetAllTargets(char)
	if not G.Refs.EnemiesFolder then
		G.Refs.EnemiesFolder = workspace:FindFirstChild("Enemies")
	end
	return FastAttackModule.GetNearbyTargets(char, G.Refs.EnemiesFolder)
end

local Refs2 = {
	AttackRemoteTarget = nil,
	AttackRemoteId = nil,
}

function G.initHitRegistration()
	local foldersToCheck = {}
	for _, name in ipairs({ "Util", "Common", "Remotes", "Assets", "FX" }) do
		local f = ReplicatedStorage:FindFirstChild(name)
		if f then
			table.insert(foldersToCheck, f)
		end
	end
	for _, folder in ipairs(foldersToCheck) do
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
				Refs2.AttackRemoteTarget = child
				Refs2.AttackRemoteId = child:GetAttribute("Id")
			end
		end
		folder.ChildAdded:Connect(function(child)
			if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
				Refs2.AttackRemoteTarget = child
				Refs2.AttackRemoteId = child:GetAttribute("Id")
			end
		end)
	end
end
pcall(G.initHitRegistration)

function FastAttackModule.ExecuteFastAttack()
	local char = player.Character
	if not char then
		return
	end
	local targets = FastAttackModule.GetAllTargets(char)
	if #targets < 1 then
		return
	end
	local targetParts = FastAttackModule.GetTargetParts(targets)
	if #targetParts < 1 then
		return
	end

	if RegisterAttack and RegisterHit then
		RegisterAttack:FireServer(FastAttackModule.Rate)
		local targetHead = targetParts[1][2]
		if targetHead then
			RegisterHit:FireServer(targetHead, targetParts)
		end
	end

	local r2target = Refs2 and Refs2.AttackRemoteTarget
	local r2id = Refs2 and Refs2.AttackRemoteId
	if r2target and r2id and r2target.Parent then
		pcall(function()
			local ok, seed = pcall(function()
				local Net2 = ReplicatedStorage:FindFirstChild("Modules")
					and ReplicatedStorage.Modules:FindFirstChild("Net")
				return Net2 and Net2:FindFirstChild("seed") and Net2.seed:InvokeServer()
			end)
			if not ok or not seed then
				seed = math.random(1000, 9999)
			end
			local remoteCode = "RE/RegisterHit"
			local encryptionKey = math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1
			local encodedString = string.gsub(remoteCode, ".", function(ch)
				return string.char(bit32.bxor(string.byte(ch), encryptionKey))
			end)
			local finalId = bit32.bxor(r2id + 909090, seed * 2)
			local cloneref2 = cloneref or function(o)
				return o
			end
			local targetHead = targetParts[1][2]
			if targetHead then
				cloneref2(r2target):FireServer(encodedString, finalId, targetHead, targetParts)
			end
		end)
	end
end

G.fastAttackThread = nil

function G.stopFastAttack()
	if G.fastAttackThread then
		task.cancel(G.fastAttackThread)
		G.fastAttackThread = nil
	end
end

local FastFruitAttack = {
	enabled = false,
	rate = 0.7,
	cycleDelay = 0.8,
	range = 150,
	thread = nil,
}

function FastFruitAttack.getRemote()
	local char = player.Character
	if not char then
		return nil
	end
	for _, obj in ipairs(char:GetDescendants()) do
		if obj.Name == "LeftClickRemote" and obj:IsA("RemoteEvent") then
			return obj
		end
	end
	return nil
end

function FastFruitAttack.getDirection(targetPos)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return Vector3.new(0, 0, 1)
	end
	local dir = (targetPos - hrp.Position)
	local mag = dir.Magnitude
	if mag < 0.01 then
		return Vector3.new(0, 0, 1)
	end
	return dir / mag
end

function FastFruitAttack.getTarget()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return nil
	end

	if State.currentTarget and G.isEnemyAlive(State.currentTarget) then
		local tr = State.currentTarget:FindFirstChild("HumanoidRootPart")
		if tr then
			return tr.Position
		end
	end

	local closest, closestDist = nil, math.huge
	local enemies = workspace:FindFirstChild("Enemies")
	if not enemies then
		return nil
	end

	for _, mob in ipairs(enemies:GetChildren()) do
		local hum = mob:FindFirstChildOfClass("Humanoid")
		local root = mob:FindFirstChild("HumanoidRootPart")
		if hum and root and hum.Health > 0 then
			local dist = (root.Position - hrp.Position).Magnitude
			if dist < closestDist and dist <= FastFruitAttack.range then
				closestDist = dist
				closest = root.Position
			end
		end
	end

	return closest
end

function FastFruitAttack.fire()
	local remote = FastFruitAttack.getRemote()
	if not remote then
		return
	end

	local targetPos = FastFruitAttack.getTarget()
	if not targetPos then
		return
	end

	local direction = FastFruitAttack.getDirection(targetPos)

	for action = 1, 4 do
		if not FastFruitAttack.enabled then
			break
		end
		pcall(function()
			remote:FireServer(direction, action)
		end)
		task.wait(FastFruitAttack.rate)
	end
end

function FastFruitAttack.stop()
	FastFruitAttack.enabled = false
	if FastFruitAttack.thread then
		task.cancel(FastFruitAttack.thread)
		FastFruitAttack.thread = nil
	end
end

function FastFruitAttack.start()
	FastFruitAttack.stop()
	FastFruitAttack.enabled = true
	FastFruitAttack.thread = task.spawn(function()
		while FastFruitAttack.enabled do
			pcall(FastFruitAttack.fire)

			task.wait(FastFruitAttack.cycleDelay)
		end
	end)
end

local AlwaysFruitAttack = {
	enabled = false,
	thread = nil,
}

function AlwaysFruitAttack.stop()
	AlwaysFruitAttack.enabled = false
	if AlwaysFruitAttack.thread then
		task.cancel(AlwaysFruitAttack.thread)
		AlwaysFruitAttack.thread = nil
	end
end

function AlwaysFruitAttack.start()
    AlwaysFruitAttack.stop()
    AlwaysFruitAttack.enabled = true
    AlwaysFruitAttack.thread = task.spawn(function()
        while AlwaysFruitAttack.enabled do
            pcall(function()
                local char = player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- หา remote
                local remote = nil
                for _, tool in ipairs(player.Backpack:GetChildren()) do
                    local r = tool:FindFirstChild("LeftClickRemote")
                    if r and r:IsA("RemoteEvent") then remote = r; break end
                end
                if not remote then
                    for _, tool in ipairs(char:GetChildren()) do
                        local r = tool:FindFirstChild("LeftClickRemote")
                        if r and r:IsA("RemoteEvent") then remote = r; break end
                    end
                end
                if not remote then return end

                -- หา target ที่ใกล้ที่สุด
                local targetPos = nil
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    local closest, closestDist = nil, math.huge
                    for _, mob in ipairs(enemies:GetChildren()) do
                        local hum  = mob:FindFirstChildOfClass("Humanoid")
                        local root = mob:FindFirstChild("HumanoidRootPart")
                        if hum and root and hum.Health > 0 then
                            local dist = (root.Position - hrp.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = root.Position
                            end
                        end
                    end
                    targetPos = closest
                end
                if not targetPos then return end

                -- direction หันไปหา target จริงๆ
                local dir = (targetPos - hrp.Position)
                local mag = dir.Magnitude
                local direction = mag > 0.01 and (dir / mag) or hrp.CFrame.LookVector

                -- ยิง action 1-4
                for action = 1, 4 do
                    if not AlwaysFruitAttack.enabled then break end
                    pcall(function() remote:FireServer(direction, action) end)
                    task.wait(FastFruitAttack.rate)
                end
            end)

            task.wait(FastFruitAttack.cycleDelay)
        end
    end)
end

function G.startFastAttack()
	G.stopFastAttack()
	FastAttackModule.Enabled = true
	G.fastAttackThread = task.spawn(function()
		while FastAttackModule.Enabled do
			local char = player.Character

			if State.fruitAndMeleeEnabled then
				local remote = nil
				if char then
					for _, obj in ipairs(char:GetDescendants()) do
						if obj.Name == "LeftClickRemote" and obj:IsA("RemoteEvent") then
							remote = obj
							break
						end
					end
				end
				local targetPos = FastFruitAttack.getTarget()
				if remote and targetPos and not G.fruitAttackBusy then
					G.fruitAttackBusy = true
					task.spawn(function()
						local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						local dir = hrp and (targetPos - hrp.Position) or Vector3.new(0, 0, 1)
						dir = Vector3.new(dir.X, 0, dir.Z)
						local mag = dir.Magnitude
						local direction = mag > 0.01 and (dir / mag) or Vector3.new(0, 0, 1)
						for action = 1, 4 do
							if not remote or not remote.Parent then
								break
							end
							pcall(function()
								remote:FireServer(direction, action)
							end)
							task.wait(FastFruitAttack.rate)
						end
						task.wait(FastFruitAttack.cycleDelay)
						G.fruitAttackBusy = false
					end)
				end
				pcall(FastAttackModule.ExecuteFastAttack)
				pcall(G.HitRegistrationModule.Execute)
				task.wait(FastAttackModule.Rate)
			else
				local currentTool = char and char:FindFirstChildOfClass("Tool")
				local isFruit = false
				if currentTool then
					local hasLeftClick = currentTool:FindFirstChild("LeftClickRemote", true)
					if hasLeftClick then
						isFruit = true
					end
					if not isFruit then
						local tooltip = G.getToolTooltip(currentTool):lower()
						local toolName = currentTool.Name:lower()
						if
							tooltip:find("blox fruit")
							or tooltip:find("fruit")
							or toolName:find("fruit")
							or tooltip:find("devil")
							or toolName:find("devil")
						then
							isFruit = true
						end
					end
				end

				if isFruit then
					local remote = FastFruitAttack.getRemote()
					local targetPos = FastFruitAttack.getTarget()
					if remote and targetPos and not G.fruitAttackBusy then
						G.fruitAttackBusy = true
						task.spawn(function()
							local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
							local dir = hrp and (targetPos - hrp.Position) or Vector3.new(0, 0, 1)
							dir = Vector3.new(dir.X, 0, dir.Z)
							local mag = dir.Magnitude
							local direction = mag > 0.01 and (dir / mag) or Vector3.new(0, 0, 1)
							for action = 1, 4 do
								if not remote or not remote.Parent then
									break
								end
								pcall(function()
									remote:FireServer(direction, action)
								end)
								task.wait(FastFruitAttack.rate)
							end
							task.wait(FastFruitAttack.cycleDelay)
							G.fruitAttackBusy = false
						end)
					end
				else
					pcall(FastAttackModule.ExecuteFastAttack)
					pcall(G.HitRegistrationModule.Execute)
					task.wait(FastAttackModule.Rate)
				end
			end
		end
		G.fastAttackThread = nil
	end)
end

function G.applyNoclip(character)
	if not character then
		return
	end
	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			if G.originalCanCollide[object] == nil then
				G.originalCanCollide[object] = object.CanCollide
			end
			object.CanCollide = false
		end
	end
	if not character:GetAttribute("_NoclipTagged") then
		character:SetAttribute("_NoclipTagged", true)
		character.DescendantAdded:Connect(function(obj)
			local farmActive = State.autoFarmEnabled or State.autoFarmSelectEnabled

			if farmActive and obj:IsA("BasePart") then
				if G.originalCanCollide[obj] == nil then
					G.originalCanCollide[obj] = obj.CanCollide
				end
				obj.CanCollide = false
			end
		end)
	end
end

function G.restoreCollision()
	for object, originalValue in pairs(G.originalCanCollide) do
		if object and object.Parent then
			object.CanCollide = originalValue
		end
	end
	table.clear(G.originalCanCollide)
end

function G.restoreMobState(mob, state)
	if not state then
		return
	end
	for part, canCollide in pairs(state.parts) do
		if part and part.Parent then
			part.CanCollide = canCollide
		end
	end
	local humanoid = state.humanoid
	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = state.walkSpeed
		humanoid.JumpPower = state.jumpPower
		humanoid.JumpHeight = state.jumpHeight
	end
end

G.BRING_SNAP_DISTANCE = 8

function G.clearBringMobs()
	for mob, bodies in pairs(G.activeBringBodies) do
		if type(bodies) == "table" then
			if bodies.bp and bodies.bp.Parent then
				bodies.bp:Destroy()
			end
			if bodies.bv and bodies.bv.Parent then
				bodies.bv:Destroy()
			end
		else
			local mobRoot = mob and mob.FindFirstChild and mob:FindFirstChild("HumanoidRootPart")
			if mobRoot then
				local bp = mobRoot:FindFirstChild("BringBodyPos")
				if bp then
					bp:Destroy()
				end
			end
		end
		G.activeBringBodies[mob] = nil
	end
	for mob in pairs(G.bringSnapped) do
		G.bringSnapped[mob] = nil
	end
	for mob, state in pairs(G.originalMobStates) do
		G.restoreMobState(mob, state)
		G.originalMobStates[mob] = nil
	end
	State.bringAnchor = nil
	State.lastBringUpdate = 0
	State.targetAnchorCFrame = nil
end

function G.freezeMob(mob, mobRoot, mobHumanoid)
	if not G.originalMobStates[mob] then
		local state = {
			parts = {},
			humanoid = mobHumanoid,
			walkSpeed = mobHumanoid.WalkSpeed,
			jumpPower = mobHumanoid.JumpPower,
			jumpHeight = mobHumanoid.JumpHeight,
		}
		for _, part in ipairs(mob:GetDescendants()) do
			if part:IsA("BasePart") then
				state.parts[part] = part.CanCollide
				part.CanCollide = false
			end
		end
		G.originalMobStates[mob] = state
	else
		for part in pairs(G.originalMobStates[mob].parts) do
			if part and part.Parent then
				part.CanCollide = false
			end
		end
	end
	mobHumanoid.WalkSpeed = 0
	mobHumanoid.JumpPower = 0
	mobHumanoid.JumpHeight = 0
end

function G.updateBringMobs(target, now)
	if not State.bringMobEnabled or (not State.autoFarmEnabled and not State.autoFarmSelectEnabled) then
		G.clearBringMobs()
		return
	end
	if not G.isEnemyAlive(target) then
		G.clearBringMobs()
		return
	end

	if State.bringAnchor ~= target then
		G.clearBringMobs()
		State.bringAnchor = target
	end

	if now - State.lastBringUpdate < State.BRING_INTERVAL then
		return
	end
	State.lastBringUpdate = now

	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		G.clearBringMobs()
		return
	end

	local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
	if targetHumanoid then
		if not G.originalMobStates[target] then
			local state = {
				parts = {},
				humanoid = targetHumanoid,
				walkSpeed = targetHumanoid.WalkSpeed,
				jumpPower = targetHumanoid.JumpPower,
				jumpHeight = targetHumanoid.JumpHeight,
			}
			for _, part in ipairs(target:GetDescendants()) do
				if part:IsA("BasePart") then
					state.parts[part] = part.CanCollide
					part.CanCollide = false
				end
			end
			G.originalMobStates[target] = state
		end
		targetHumanoid.WalkSpeed = 0
		targetHumanoid.JumpPower = 0
		targetHumanoid.JumpHeight = 0

		if State.lockMobCFrame then
			if not State.targetAnchorCFrame then
				State.targetAnchorCFrame = targetRoot.CFrame
			end
			pcall(function()
				sethiddenproperty(targetRoot, "NetworkOwnershipRule", 0)
			end)
			targetRoot.CFrame = State.targetAnchorCFrame
			targetRoot.AssemblyLinearVelocity = Vector3.zero
			targetRoot.AssemblyAngularVelocity = Vector3.zero
		else
			State.targetAnchorCFrame = nil
			pcall(function()
				sethiddenproperty(targetRoot, "NetworkOwnershipRule", 0)
			end)
			targetRoot.AssemblyLinearVelocity = Vector3.zero
			targetRoot.AssemblyAngularVelocity = Vector3.zero
		end
	end

	local pullPos = targetRoot.Position
	local bringCount = math.max(0, math.floor(tonumber(State.BRING_MOB_COUNT) or 0))

	local validMobs = {}
	for _, mob in ipairs(enemiesFolder:GetChildren()) do
		if mob == target then
			continue
		end
		local mr = mob:FindFirstChild("HumanoidRootPart")
		local mh = mob:FindFirstChildOfClass("Humanoid")
		if not mr or not mh or mh.Health <= 0 then
			continue
		end

		local rawName = G.getMobDisplayName(mob)
		if rawName:find("%[Boss%]") or rawName:find("%[Raid Boss%]") then
			continue
		end
		if not G.sameMobType(mob, target) then
			continue
		end

		local dist = (mr.Position - pullPos).Magnitude
		if dist > State.BRING_DISTANCE then
			continue
		end

		table.insert(validMobs, { mob = mob, mr = mr, mh = mh, dist = dist })
	end
	table.sort(validMobs, function(a, b)
		return a.dist < b.dist
	end)

	local seenMobs = {}
	local slots = math.min(bringCount, #validMobs)
	for i = 1, slots do
		local data = validMobs[i]
		local mob = data.mob
		local mr = data.mr
		local mh = data.mh
		seenMobs[mob] = true

		pcall(function()
			for _, p in ipairs(mob:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CanCollide = false
					pcall(function()
						sethiddenproperty(p, "NetworkOwnershipRule", 0)
					end)
				end
			end
			pcall(function()
				sethiddenproperty(mr, "NetworkOwnershipRule", 0)
			end)

			mh.WalkSpeed = 0
			mh.JumpPower = 0
			mh.JumpHeight = 0

			local angle = (i - 1) * (math.pi * 2 / math.max(1, slots))
			local destPos = pullPos + Vector3.new(math.cos(angle) * 3, 0, math.sin(angle) * 3)
			local dist = (mr.Position - destPos).Magnitude

			if State.lockMobCFrame then
				if G.bringSnapped[mob] or dist <= G.BRING_SNAP_DISTANCE then
					G.bringSnapped[mob] = true
					local oldBP = mr:FindFirstChild("BringBodyPos")
					if oldBP then
						oldBP:Destroy()
					end
					G.activeBringBodies[mob] = true
					mr.CFrame = CFrame.new(destPos, pullPos)
					mr.AssemblyLinearVelocity = Vector3.zero
					mr.AssemblyAngularVelocity = Vector3.zero
				else
					local bp = mr:FindFirstChild("BringBodyPos")
					if not bp then
						bp = Instance.new("BodyPosition")
						bp.Name = "BringBodyPos"
						bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
						bp.P = 30000
						bp.D = 900
						bp.Parent = mr
					end
					bp.Position = destPos
					G.activeBringBodies[mob] = { bp = bp }
				end
			else
				local bp = mr:FindFirstChild("BringBodyPos")
				if not bp then
					bp = Instance.new("BodyPosition")
					bp.Name = "BringBodyPos"
					bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
					bp.P = 30000
					bp.D = 900
					bp.Parent = mr
				end
				bp.Position = destPos
				G.activeBringBodies[mob] = { bp = bp }
				G.bringSnapped[mob] = nil
			end
		end)
	end

	for mob in pairs(G.activeBringBodies) do
		if not seenMobs[mob] then
			local mobRoot = mob:FindFirstChild("HumanoidRootPart")
			if mobRoot then
				local bp = mobRoot:FindFirstChild("BringBodyPos")
				if bp then
					bp:Destroy()
				end
			end
			G.activeBringBodies[mob] = nil
			G.bringSnapped[mob] = nil
		end
	end
	for mob, state in pairs(G.originalMobStates) do
		if not seenMobs[mob] and mob ~= target then
			G.restoreMobState(mob, state)
			G.originalMobStates[mob] = nil
		end
	end
end

function G.tweenToSpawn(root, spawnPos)
	if not root or not spawnPos then
		return false
	end
	local dist = (spawnPos - root.Position).Magnitude
	G.cancelTween()
	State.activeTween = TweenService:Create(
		root,
		TweenInfo.new(math.max(dist / math.max(State.SPEED, 1), 0.05), Enum.EasingStyle.Linear),
		{ CFrame = CFrame.new(spawnPos + Vector3.new(0, 5, 0)) }
	)
	State.tweenTargetPosition = spawnPos
	State.activeTween:Play()
	State.lastTweenStartTime = tick()
	State.isMovingToSpawn = true
	return true
end

function G.resetSpawnScan(clearLastPoint)
	G.cancelTween()
	State.isMovingToSpawn = false
	State.spawnPointList = {}
	State.spawnPointIndex = 1
	State.spawnPointChecked = {}
	State.spawnCyclePauseUntil = 0
	if clearLastPoint then
		State.lastSpawnPointKey = nil
	end
end

function G.advanceSpawnPoint(root)
	local currentPoint = State.spawnPointList[State.spawnPointIndex]
	if currentPoint then
		local key = G.positionKey(currentPoint)
		State.spawnPointChecked[key] = true
		State.lastSpawnPointKey = key
	end

	G.cancelTween()
	State.isMovingToSpawn = false
	State.spawnPointIndex = State.spawnPointIndex + 1

	while State.spawnPointIndex <= #State.spawnPointList do
		local nextPoint = State.spawnPointList[State.spawnPointIndex]
		if nextPoint and not State.spawnPointChecked[G.positionKey(nextPoint)] then
			if root then
				G.tweenToSpawn(root, nextPoint)
			end
			return true
		end
		State.spawnPointIndex = State.spawnPointIndex + 1
	end

	State.spawnPointList = {}
	State.spawnPointIndex = 1
	State.spawnPointChecked = {}
	State.spawnCyclePauseUntil = tick() + 0.75
	return false
end

G.SCRIPT_MOVER_NAMES = {
	FollowBodyGyro = true,
	TweenAntiGravity = true,
}

function G.clearScriptMovers(character)
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	for _, obj in ipairs(root:GetChildren()) do
		if G.SCRIPT_MOVER_NAMES[obj.Name] and (obj:IsA("BodyGyro") or obj:IsA("BodyForce")) then
			obj:Destroy()
		end
	end
end

local savedAutoRotate = setmetatable({}, { __mode = "k" })

function G.disableAutoRotate(humanoid)
	if not humanoid then
		return
	end
	if savedAutoRotate[humanoid] == nil then
		savedAutoRotate[humanoid] = humanoid.AutoRotate
	end
	humanoid.AutoRotate = false
end

function G.restoreAutoRotate(humanoid)
	if not humanoid then
		return
	end
	local prev = savedAutoRotate[humanoid]
	if prev ~= nil then
		humanoid.AutoRotate = prev
	else
		humanoid.AutoRotate = true
	end
	savedAutoRotate[humanoid] = nil
end

function G.holdRotation(gyro, humanoid, cf)
	if gyro then
		gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		if cf then
			gyro.CFrame = cf
		end
	end
	G.disableAutoRotate(humanoid)
end

function G.releaseRotation(gyro, humanoid)
	if gyro then
		gyro.MaxTorque = Vector3.zero
		local c = player.Character
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if r then
			gyro.CFrame = r.CFrame
		end
	end
	if humanoid then
		humanoid.AutoRotate = true
		savedAutoRotate[humanoid] = nil
	end
end

function G.scriptFeatureActive()
	return State.autoFarmEnabled or State.autoFarmSelectEnabled
end

function G.cleanup()
	G.stopNoclipLoop()
	G.stopExitRoute()
	if State.followConnection then
		State.followConnection:Disconnect()
		State.followConnection = nil
	end
	G.cancelTween()

	if State.activeAntiGravity and State.activeAntiGravity.Parent then
		State.activeAntiGravity:Destroy()
	end
	State.activeAntiGravity = nil
	if State.activeBodyGyro and State.activeBodyGyro.Parent then
		State.activeBodyGyro:Destroy()
	end
	State.activeBodyGyro = nil

	local _char = player.Character
	local _root = _char and _char:FindFirstChild("HumanoidRootPart")
	if _root then
		local _ag = _root:FindFirstChild("TweenAntiGravity")
		if _ag then
			_ag:Destroy()
		end
		local _bg = _root:FindFirstChild("FollowBodyGyro")
		if _bg then
			_bg:Destroy()
		end
	end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		for _, obj in ipairs(root:GetChildren()) do
			if
				obj:IsA("BodyGyro")
				or obj:IsA("BodyForce")
				or obj:IsA("BodyVelocity")
				or obj:IsA("BodyPosition")
				or obj:IsA("BodyAngularVelocity")
			then
				pcall(function()
					obj:Destroy()
				end)
			end
		end
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end)
	end

	if State.activeHumanoid then
		State.activeHumanoid.AutoRotate = true
		savedAutoRotate[State.activeHumanoid] = nil
		State.activeHumanoid = nil
	end
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.AutoRotate = true
			savedAutoRotate[hum] = nil
		end
	end

	G.clearBringMobs()
	G.restoreCollision()
	G.resetSpawnScan(true)
	State.currentTarget = nil
	State.isLocked = false
	State.lockStartTime = nil
	State.idleAnchorCFrame = nil
	State.lastMovePosition = nil
	State.lastMoveTime = 0
	State._entryRouteActive = false
	State._entryRouteCooldown = 0
	State._exitRouteCooldown = 0
end

function G.setupCharacter(character)
	G.cleanup()

	local root = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	State.activeHumanoid = humanoid
	humanoid.AutoRotate = true

	State.activeAntiGravity = nil
	State.activeBodyGyro = nil

	root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)

	local function getOrCreateMovers()
		local ag = root:FindFirstChild("TweenAntiGravity")
		if not ag then
			ag = Instance.new("BodyForce")
			ag.Name = "TweenAntiGravity"
			ag.Parent = root
		end
		ag.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)
		State.activeAntiGravity = ag

		local bg = root:FindFirstChild("FollowBodyGyro")
		if not bg then
			bg = Instance.new("BodyGyro")
			bg.Name = "FollowBodyGyro"
			bg.MaxTorque = Vector3.zero
			bg.P = 50000
			bg.D = 1500
			bg.CFrame = root.CFrame
			bg.Parent = root
		end
		State.activeBodyGyro = bg
		return ag, bg
	end

	local function destroyMovers()
		if State.activeAntiGravity and State.activeAntiGravity.Parent then
			State.activeAntiGravity:Destroy()
		end
		State.activeAntiGravity = nil
		if State.activeBodyGyro and State.activeBodyGyro.Parent then
			State.activeBodyGyro:Destroy()
		end
		State.activeBodyGyro = nil

		local ag2 = root:FindFirstChild("TweenAntiGravity")
		if ag2 then
			ag2:Destroy()
		end
		local bg2 = root:FindFirstChild("FollowBodyGyro")
		if bg2 then
			bg2:Destroy()
		end

		if humanoid and humanoid.Parent then
			humanoid.AutoRotate = true
			savedAutoRotate[humanoid] = nil
		end
	end

	local function runEntryRoute(entryRoute, notifyMsg)
		G.exitRouteList = entryRoute
		G.exitRouteIndex = 1
		G.exitRouteActive = true

		if G.exitRouteConn then
			G.exitRouteConn:Disconnect()
			G.exitRouteConn = nil
		end

		local waitingForWarp = false
		local warpWaitPos = nil
		local warpWaitStart = 0
		local WARP_TRIGGER = 80
		local WARP_TIMEOUT = 15

		G.exitRouteConn = RunService.Heartbeat:Connect(function(dt)
			if not G.exitRouteActive then
				State._entryRouteActive = false
				State._entryRouteCooldown = tick() + 5
				G.stopExitRoute()
				return
			end

			local c = player.Character
			local h = c and c:FindFirstChild("HumanoidRootPart")
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			if not h or not hum or hum.Health <= 0 then
				return
			end

			if waitingForWarp then
				local movedDist = (h.Position - warpWaitPos).Magnitude
				local timedOut = (tick() - warpWaitStart) > WARP_TIMEOUT
				if movedDist > WARP_TRIGGER or timedOut then
					waitingForWarp = false
					warpWaitPos = nil
					State.currentFlyCF = h.CFrame
					G.exitRouteIndex = G.exitRouteIndex + 1
					G.stopMomentum()
				else
					pcall(function()
						h.AssemblyLinearVelocity = Vector3.zero
						h.AssemblyAngularVelocity = Vector3.zero
					end)
					return
				end
			end

			if G.exitRouteIndex > #G.exitRouteList then
				State._entryRouteActive = false
				State._entryRouteCooldown = tick() + 5
				State.currentFlyCF = h.CFrame
				G.stopExitRoute()
				Fluent:Notify({ Title = "Entry", Content = notifyMsg, Duration = 3 })
				return
			end

			local targetCF = G.exitRouteList[G.exitRouteIndex]
			local currentPos = State.currentFlyCF and State.currentFlyCF.Position or h.Position
			local dist = (targetCF.Position - currentPos).Magnitude

			if dist > 6 then
				G.moveToTarget(h, targetCF, dt)
			else
				State.currentFlyCF = targetCF
				pcall(function()
					h.CFrame = targetCF
					h.AssemblyLinearVelocity = Vector3.zero
					h.AssemblyAngularVelocity = Vector3.zero
				end)

				local isLast = (G.exitRouteIndex >= #G.exitRouteList)
				if isLast then
					State._entryRouteActive = false
					State._entryRouteCooldown = tick() + 5
					State.currentFlyCF = h.CFrame
					G.stopExitRoute()
					Fluent:Notify({ Title = "Entry", Content = notifyMsg, Duration = 3 })
				else
					waitingForWarp = true
					warpWaitPos = targetCF.Position
					warpWaitStart = tick()
				end
			end
		end)
	end

	State.followConnection = RunService.Heartbeat:Connect(function(dt)
		local farmActive = State.autoFarmEnabled or State.autoFarmSelectEnabled
		if not farmActive then
			destroyMovers()
			for part, _ in pairs(G.originalCanCollide) do
				if part and part.Parent then
					part.CanCollide = true
				end
			end
			table.clear(G.originalCanCollide)
			if State.followConnection then
				State.followConnection:Disconnect()
				State.followConnection = nil
			end
			G.cleanup()
			return
		end

		if not character.Parent or not root.Parent then
			G.cleanup()
			return
		end

		local antiGravity, bodyGyro = getOrCreateMovers()

		antiGravity.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)
		G.applyNoclip(character)

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero

		local nowTick = tick()

		if G.exitRouteActive then
			return
		end

		local pos = root.Position

		if not G.exitRouteActive then
			local targetNeedsUnderwater = false
			local targetNeedsSky = false

			if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
				local activeName = G.getActiveSelectedMobName()
				if activeName then
					if G.isUnderwaterRoute(activeName) then
						targetNeedsUnderwater = true
					end
					if G.isSkyRoute(activeName) then
						targetNeedsSky = true
					end
				end
			elseif State.autoFarmEnabled and State.currentTarget then
				local tr = State.currentTarget:FindFirstChild("HumanoidRootPart")
				if tr then
					if G.inUnderwaterArea(tr.Position) then
						targetNeedsUnderwater = true
					end
					if G.inSkyArea(tr.Position) then
						targetNeedsSky = true
					end
				end
			end

			if
				targetNeedsUnderwater
				and not G.inUnderwaterArea(pos)
				and not State._entryRouteActive
				and tick() > State._entryRouteCooldown
			then
				State._entryRouteActive = true
				State.currentTarget = nil
				G.cancelTween()
				G.clearBringMobs()
				local entryRoute = {
					CFrame.new(
						4050.31104,
						-1.68800354,
						-1814.12402,
						-0.955315053,
						0,
						-0.295594245,
						0,
						1,
						0,
						0.295594245,
						0,
						-0.955315053
					),
				}
				local activeName = G.getActiveSelectedMobName()
				local destPos = activeName and G.UNDERWATER_DEST_POSITIONS[activeName]
				if destPos then
					table.insert(entryRoute, CFrame.new(destPos))
				end
				runEntryRoute(entryRoute, "Entered underwater city")
				return
			end

			if
				targetNeedsSky
				and not G.inSkyArea(pos)
				and not State._entryRouteActive
				and tick() > State._entryRouteCooldown
			then
				State._entryRouteActive = true
				State.currentTarget = nil
				G.cancelTween()
				G.clearBringMobs()
				local entryRoute = { G.SKY_GATE }
				local activeName = G.getActiveSelectedMobName()
				local destPos = activeName and G.SKY_DEST_POSITIONS[activeName]
				if destPos then
					table.insert(entryRoute, CFrame.new(destPos))
				end
				runEntryRoute(entryRoute, "Entered sky area")
				return
			end

			local needExit = G.inSkyArea(pos) or G.inUnderwaterArea(pos)
			if needExit then
				local targetIsInArea = false
				if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
					local activeName = G.getActiveSelectedMobName()
					if activeName and (G.isSkyRoute(activeName) or G.isUnderwaterRoute(activeName)) then
						targetIsInArea = true
					end
				elseif State.autoFarmEnabled then
					local nearest = G.getClosestAliveEnemyNears(pos)
					if nearest then
						local nr = nearest:FindFirstChild("HumanoidRootPart")
						if nr then
							if G.inSkyArea(nr.Position) or G.inUnderwaterArea(nr.Position) then
								targetIsInArea = true
							end
						end
					end
				end
				if not targetIsInArea then
					State.currentTarget = nil
					G.cancelTween()
					G.clearBringMobs()
					State.isLocked = false
					if tick() > State._exitRouteCooldown then
						State._exitRouteCooldown = tick() + 3
						G.startExitRoute(function()
							Fluent:Notify({ Title = "Route", Content = "Exited area, resuming farm", Duration = 2 })
						end)
					end
					return
				end
			end
		end

		if State.isLocked then
			State.lastMovePosition = root.Position
			State.lastMoveTime = nowTick
		else
			if not State.lastMovePosition or (root.Position - State.lastMovePosition).Magnitude > 5 then
				State.lastMovePosition = root.Position
				State.lastMoveTime = nowTick
			elseif nowTick - State.lastMoveTime > 2.5 then
				State.lastMovePosition = root.Position
				State.lastMoveTime = nowTick
				State.currentTarget = nil
				if State.isMovingToSpawn then
					G.advanceSpawnPoint(root)
					return
				end
				G.cancelTween()
			end
		end

		if
			State.activeTween
			and State.activeTween.PlaybackState == Enum.PlaybackState.Playing
			and nowTick - State.lastTweenStartTime > State.TWEEN_TIMEOUT
		then
			State.currentTarget = nil
			if State.isMovingToSpawn then
				G.advanceSpawnPoint(root)
				return
			end
			G.cancelTween()
		end

		if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
			if State.currentTarget and not G.isEnemyAlive(State.currentTarget) then
				State.currentTarget = nil
				State.isLocked = false
				State.lockStartTime = nil
				State.tweenTargetPosition = nil
				G.cancelTween()
				G.clearBringMobs()
			end

			if not State.currentTarget then
				local foundTarget = nil
				local foundIndex = nil
				for i, name in ipairs(State.selectedMobNames) do
					local target = G.getClosestAliveEnemy(root.Position, name)
					if target then
						foundTarget = target
						foundIndex = i
						break
					end
				end

				if foundTarget then
					State.selectedMobIndex = foundIndex
					State.currentTarget = foundTarget
					State.lastTargetSwitchTime = tick()
					G.cancelTween()
					G.resetSpawnScan(true)
				else
					local alreadyScanning = State.isMovingToSpawn and #State.spawnPointList > 0
					if not alreadyScanning then
						if G.isAllSelectedSpawnFull() then
							root.AssemblyLinearVelocity = Vector3.zero
							root.AssemblyAngularVelocity = Vector3.zero
							if State.idleAnchorCFrame then
								local anchorDist = (root.Position - State.idleAnchorCFrame.Position).Magnitude
								if anchorDist > 2 then
									root.CFrame = State.idleAnchorCFrame
								end
							else
								State.idleAnchorCFrame = root.CFrame
							end
							return
						end

						local allSpawns, seenKeys = {}, {}
						for _, name in ipairs(State.selectedMobNames) do
							if G.isSpawnFull(name) then
								continue
							end
							local spawnList = G.getSpawnPositionsForMob(name)
							for _, spawnPos in ipairs(spawnList) do
								local key = G.positionKey(spawnPos)
								if not seenKeys[key] then
									seenKeys[key] = true
									table.insert(allSpawns, spawnPos)
								end
							end
						end

						if #allSpawns > 0 then
							G.sortPositionsByDistance(allSpawns, root.Position)
							State.spawnPointList = allSpawns
							State.spawnPointIndex = 1
							State.spawnPointChecked = {}
							if G.tweenToSpawn(root, allSpawns[1]) then
								State.idleAnchorCFrame = nil
							end
							return
						end
					end
				end
			end
		elseif State.autoFarmEnabled then
			if not G.isEnemyAlive(State.currentTarget) then
				State.currentTarget = G.getClosestAliveEnemyNears(root.Position)
			else
				local nearest = G.getClosestAliveEnemyNears(root.Position)
				if nearest and nearest ~= State.currentTarget and tick() - State.lastTargetSwitchTime >= 0.1 then
					local curRoot = State.currentTarget:FindFirstChild("HumanoidRootPart")
					local newRoot = nearest:FindFirstChild("HumanoidRootPart")
					if curRoot and newRoot then
						local curDist = (curRoot.Position - root.Position).Magnitude
						local newDist = (newRoot.Position - root.Position).Magnitude
						if newDist < curDist - 20 then
							State.currentTarget = nearest
							State.lastTargetSwitchTime = tick()
							G.cancelTween()
						end
					end
				end
			end
		end

		if not State.currentTarget then
			local tweenActive = State.activeTween and State.activeTween.PlaybackState == Enum.PlaybackState.Playing

			if State.isMovingToSpawn then
				local earlyTarget = nil
				if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
					for _, name in ipairs(State.selectedMobNames) do
						local t = G.getClosestAliveEnemy(root.Position, name)
						if t then
							earlyTarget = t
							break
						end
					end
				elseif State.autoFarmEnabled then
					earlyTarget = G.getClosestAliveEnemyNears(root.Position)
				end

				if earlyTarget then
					G.cancelTween()
					State.isMovingToSpawn = false
					State.currentTarget = earlyTarget
					State.lastTargetSwitchTime = tick()
					State.idleAnchorCFrame = nil
					G.resetSpawnScan(true)
				elseif tweenActive then
					return
				else
					G.advanceSpawnPoint(root)
					return
				end
			end

			if not State.currentTarget then
				G.cancelTween()
				G.clearBringMobs()
				State.isLocked = false

				bodyGyro.MaxTorque = Vector3.zero
				humanoid.AutoRotate = true
				savedAutoRotate[humanoid] = nil

				if not State.idleAnchorCFrame then
					State.idleAnchorCFrame = root.CFrame
				end
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				local anchorDist = (root.Position - State.idleAnchorCFrame.Position).Magnitude
				if anchorDist > 150 then
					State.idleAnchorCFrame = root.CFrame
				elseif anchorDist > 2 then
					root.CFrame = State.idleAnchorCFrame
				end

				local farmSelect = State.autoFarmSelectEnabled and #State.selectedMobNames > 0
				if farmSelect or State.autoFarmEnabled then
					if farmSelect and G.isAllSelectedSpawnFull() then
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
						if State.idleAnchorCFrame then
							local anchorDist = (root.Position - State.idleAnchorCFrame.Position).Magnitude
							if anchorDist > 2 then
								root.CFrame = State.idleAnchorCFrame
							end
						else
							State.idleAnchorCFrame = root.CFrame
						end
						return
					end

					local now = tick()
					if
						now >= State.spawnCyclePauseUntil
						and now - State.lastSpawnTeleportTime >= State.SPAWN_TELEPORT_INTERVAL
					then
						State.lastSpawnTeleportTime = now
						if #State.spawnPointList == 0 then
							local list = {}
							if farmSelect then
								local seenPos = {}
								for _, mobName in ipairs(State.selectedMobNames) do
									if G.isSpawnFull(mobName) then
										continue
									end
									for _, p in ipairs(G.getSpawnPositionsForMob(mobName)) do
										local key = G.positionKey(p)
										if not seenPos[key] then
											seenPos[key] = true
											table.insert(list, p)
										end
									end
								end
							else
								list = G.getAllSpawnPositions()
							end
							G.sortPositionsByDistance(list, root.Position)
							if
								#list > 1
								and State.lastSpawnPointKey
								and G.positionKey(list[1]) == State.lastSpawnPointKey
							then
								table.insert(list, table.remove(list, 1))
							end
							State.spawnPointList = list
							State.spawnPointIndex = 1
							State.spawnPointChecked = {}
						end
						if #State.spawnPointList > 0 then
							if State.spawnPointIndex > #State.spawnPointList then
								State.spawnPointIndex = 1
							end
							if G.tweenToSpawn(root, State.spawnPointList[State.spawnPointIndex]) then
								State.idleAnchorCFrame = nil
							end
						end
					end
				end
				return
			end
		end

		State.idleAnchorCFrame = nil
		if State.isMovingToSpawn then
			G.cancelTween()
			State.isMovingToSpawn = false
		end
		G.resetSpawnScan(true)

		local targetRoot = State.currentTarget:FindFirstChild("HumanoidRootPart")
		if not targetRoot then
			State.currentTarget = nil
			G.cancelTween()
			G.clearBringMobs()
			State.isLocked = false
			return
		end

		G.updateBringMobs(State.currentTarget, tick())

		local targetCFrame = targetRoot.CFrame * CFrame.new(0, State.Y_OFFSET, 10)
		local targetPosition = targetCFrame.Position
		local distance = (targetPosition - root.Position).Magnitude

		if distance <= 60 then
			if not State.isLocked then
				State.lockStartTime = tick()
			end
			State.isLocked = true
			G.autoEquipWeapon()

			G.cancelTween()
			State.tweenTargetPosition = nil
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			root.CFrame = targetCFrame

			if State.lockStartTime and tick() - State.lockStartTime > 12 then
				State.isLocked = false
				State.lockStartTime = nil
				State.currentTarget = nil
				G.clearBringMobs()
				return
			end

			G.holdRotation(bodyGyro, humanoid, CFrame.new(root.Position, targetRoot.Position))

			local now = tick()
			if now - State.lastAttackTime >= State.ATTACK_RATE then
				local currentTool = character:FindFirstChildOfClass("Tool")

				if State.fruitAndMeleeEnabled then
					local remote = nil
					for _, obj in ipairs(character:GetDescendants()) do
						if obj.Name == "LeftClickRemote" and obj:IsA("RemoteEvent") then
							remote = obj
							break
						end
					end
					if remote and not G.fruitAttackBusy then
						G.fruitAttackBusy = true
						local capturedTargetPos = targetRoot.Position
						local capturedRoot = root
						task.spawn(function()
							local dir = (capturedTargetPos - capturedRoot.Position)
							dir = Vector3.new(dir.X, 0, dir.Z)
							local mag = dir.Magnitude
							local direction = mag > 0.01 and (dir / mag) or capturedRoot.CFrame.LookVector
							for action = 1, 4 do
								if not remote or not remote.Parent then
									break
								end
								pcall(function()
									remote:FireServer(direction, action)
								end)
								task.wait(FastFruitAttack.rate)
							end
							task.wait(FastFruitAttack.cycleDelay)
							G.fruitAttackBusy = false
						end)
					end
					pcall(FastAttackModule.ExecuteFastAttack)
					pcall(G.HitRegistrationModule.Execute)
				else
					local isFruit = false
					if currentTool then
						local hasLeftClick = currentTool:FindFirstChild("LeftClickRemote", true)
						if hasLeftClick then
							isFruit = true
						end
						if not isFruit then
							local tooltip = G.getToolTooltip(currentTool):lower()
							local toolName = currentTool.Name:lower()
							if
								tooltip:find("blox fruit")
								or tooltip:find("fruit")
								or toolName:find("fruit")
								or tooltip:find("devil")
								or toolName:find("devil")
							then
								isFruit = true
							end
						end
						if not isFruit then
							local wt = currentTool:GetAttribute("WeaponType")
							if wt and tostring(wt):lower():find("fruit") then
								isFruit = true
							end
							local t = currentTool:GetAttribute("Type")
							if t and tostring(t):lower():find("fruit") then
								isFruit = true
							end
						end
					end

					if isFruit then
						local remote = currentTool:FindFirstChild("LeftClickRemote", true)
						local targetPos = targetRoot.Position
						if remote and targetPos and not G.fruitAttackBusy then
							G.fruitAttackBusy = true
							task.spawn(function()
								local dir = (targetPos - root.Position)
								dir = Vector3.new(dir.X, 0, dir.Z)
								local mag = dir.Magnitude
								local direction = mag > 0.01 and (dir / mag) or root.CFrame.LookVector
								for action = 1, 4 do
									if not remote or not remote.Parent then
										break
									end
									pcall(function()
										remote:FireServer(direction, action)
									end)
									task.wait(FastFruitAttack.rate)
								end
								task.wait(FastFruitAttack.cycleDelay)
								G.fruitAttackBusy = false
							end)
						end
					else
						pcall(FastAttackModule.ExecuteFastAttack)
						pcall(G.HitRegistrationModule.Execute)
					end
				end

				State.lastAttackTime = now
			end
		else
			State.isLocked = false
			State.lockStartTime = nil

			bodyGyro.MaxTorque = Vector3.zero
			humanoid.AutoRotate = true
			savedAutoRotate[humanoid] = nil

			if distance > 0.1 then
				local tweenDur = math.max(distance / math.max(State.SPEED, 1), 0.05)
				local targetMoved = not State.tweenTargetPosition
					or (State.tweenTargetPosition - targetPosition).Magnitude > 2
				local tweenFinished = not State.activeTween
					or State.activeTween.PlaybackState ~= Enum.PlaybackState.Playing
				if targetMoved or tweenFinished then
					G.cancelTween()
					State.activeTween = TweenService:Create(
						root,
						TweenInfo.new(tweenDur, Enum.EasingStyle.Linear),
						{ CFrame = targetCFrame }
					)
					State.tweenTargetPosition = targetPosition
					State.activeTween:Play()
					State.lastTweenStartTime = tick()
				end
			else
				G.cancelTween()
			end
		end
	end)
end

player.CharacterAdded:Connect(function(newChar)
	State.currentFlyCF = nil
	task.wait(1)
	local newRoot = newChar:FindFirstChild("HumanoidRootPart")
	if newRoot then
		for _, obj in ipairs(newRoot:GetChildren()) do
			if
				obj:IsA("BodyGyro")
				or obj:IsA("BodyForce")
				or obj:IsA("BodyVelocity")
				or obj:IsA("BodyPosition")
				or obj:IsA("BodyAngularVelocity")
			then
				pcall(function()
					obj:Destroy()
				end)
			end
		end
		pcall(function()
			newRoot.AssemblyLinearVelocity = Vector3.zero
			newRoot.AssemblyAngularVelocity = Vector3.zero
		end)
	end
	G.clearScriptMovers(newChar)
	local hum = newChar:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.AutoRotate = true
		savedAutoRotate[hum] = nil
	end
	State.activeBodyGyro = nil
	State.activeAntiGravity = nil
	State.activeHumanoid = nil

	if State.autoFarmEnabled or State.autoFarmSelectEnabled then
		G.setupCharacter(newChar)
		G.startNoclipLoop()
	end

	task.spawn(function()
		task.wait(1.5)
		if not State.autoEquipEnabled then
			return
		end
		local char = player.Character
		if not char then
			return
		end
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if not hum2 or hum2.Health <= 0 then
			return
		end
		local deadline = tick() + 5
		while tick() < deadline do
			local weapon = G.findWeaponByType(State.selectedWeaponType)
			if weapon then
				pcall(function()
					hum2:EquipTool(weapon)
				end)
				break
			end
			task.wait(0.3)
		end
	end)
end)

function G.forceCleanGyro()
	local char = player.Character
	if not char then
		return
	end
	G.clearScriptMovers(char)
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		for _, obj in ipairs(root:GetChildren()) do
			if
				obj:IsA("BodyGyro")
				or obj:IsA("BodyForce")
				or obj:IsA("BodyVelocity")
				or obj:IsA("BodyPosition")
				or obj:IsA("BodyAngularVelocity")
			then
				pcall(function()
					obj:Destroy()
				end)
			end
		end
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end)
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.AutoRotate = true
		savedAutoRotate[hum] = nil
	end
	State.activeBodyGyro = nil
	State.activeAntiGravity = nil
	State.activeHumanoid = nil
end

G.forceCleanGyro()
task.delay(1, G.forceCleanGyro)
task.delay(3, G.forceCleanGyro)

G.rawMobNames = G.getAvailableMobNames()
G.mobLabelList = {}
for _, rawName in ipairs(G.rawMobNames) do
	table.insert(G.mobLabelList, G.makeMobLabel(rawName))
end

if #G.mobLabelList == 0 then
	table.insert(G.mobLabelList, "No mob spawn found")
	table.insert(G.rawMobNames, "No mob spawn found")
end

State.selectedMobNames = { G.rawMobNames[1] }
local MobSelectDropdown
MobSelectDropdown = Tabs.Main:AddDropdown("MobSelectDropdown", {
	Title = "Select Mob",
	Values = G.mobLabelList,
	Multi = true,
	Default = { G.mobLabelList[1] },
	Search = true,
	Callback = function(selectedTable)
		local orderedNames = {}
		for idx, label in ipairs(G.mobLabelList) do
			if selectedTable[label] then
				local raw = G.labelToRawName(label)
				if raw ~= "" and raw ~= "No mob spawn found" then
					table.insert(orderedNames, G.normalizeMobName(raw))
				end
			end
		end
		State.selectedMobNames = orderedNames
		State.selectedMobIndex = 1
		State.currentTarget = nil
		State.lastSpawnTeleportTime = 0
		G.resetSpawnScan(true)
		G.clearBringMobs()
		local names = #orderedNames > 0 and table.concat(orderedNames, ", ") or "None"
		Fluent:Notify({ Title = "Select Mob", Content = "Priority: " .. names, Duration = 3 })
	end,
})

Tabs.Main:AddToggle("AutoFarmSelectToggle", {
	Title = "Auto Farm Select",
	Default = State.autoFarmSelectEnabled,
	Callback = function(value)
		State.autoFarmSelectEnabled = value and #State.selectedMobNames > 0
		State.selectedMobIndex = 1
		State.currentTarget = nil
		State.lastSpawnTeleportTime = 0
		G.resetSpawnScan(true)
		G.clearBringMobs()
		if State.autoFarmSelectEnabled and not State.autoFarmEnabled then
			local char = player.Character
			if char then
				G.setupCharacter(char)
			end
			G.startNoclipLoop()
		elseif not State.autoFarmSelectEnabled and not State.autoFarmEnabled then
			G.cleanup()
			G.stopNoclipLoop()
		end
		Fluent:Notify({
			Title = "Auto Farm Select",
			Content = State.autoFarmSelectEnabled and "Enabled" or "Disabled",
			Duration = 2,
		})
	end,
})

Tabs.Main:AddButton({
	Title = "Refresh Mob List",
	Callback = function()
		local success, names = pcall(G.getAvailableMobNames)
		if not success or not names or #names == 0 then
			Fluent:Notify({ Title = "Refresh", Content = "No mob found", Duration = 2 })
			return
		end

		local labels = {}
		for _, rawName in ipairs(names) do
			table.insert(labels, G.makeMobLabel(rawName))
		end

		local selectedSet = {}
		for _, raw in ipairs(State.selectedMobNames) do
			selectedSet[G.normalizeMobName(raw)] = true
		end

		local stillSelected = {}
		local hasSelection = false
		for _, label in ipairs(labels) do
			local raw = G.normalizeMobName(G.labelToRawName(label))
			if selectedSet[raw] then
				stillSelected[label] = true
				hasSelection = true
			end
		end

		G.rawMobNames = names
		G.mobLabelList = labels

		pcall(function()
			if MobSelectDropdown.SetValues then
				MobSelectDropdown:SetValues(G.mobLabelList)
			end
		end)

		task.defer(function()
			if hasSelection and MobSelectDropdown and MobSelectDropdown.SetValue then
				pcall(function()
					MobSelectDropdown:SetValue(stillSelected)
				end)
			end
		end)

		Fluent:Notify({ Title = "Refresh", Content = "Update " .. #names .. " Mobs", Duration = 2 })
	end,
})

Tabs.Main:AddToggle("AutoFarmToggle", {
	Title = "Auto Farm Nears",
	Default = State.autoFarmEnabled,
	Callback = function(value)
		State.autoFarmEnabled = value
		if value then
			State.currentTarget = nil
			local char = player.Character
			if char then
				G.setupCharacter(char)
			end
			G.startNoclipLoop()
			Fluent:Notify({ Title = "Auto Farm", Content = "Enabled - attacking nearest enemy", Duration = 2 })
		else
			if not State.autoFarmSelectEnabled then
				G.cleanup()
				G.stopNoclipLoop()
			end
			Fluent:Notify({ Title = "Auto Farm", Content = "Disabled", Duration = 2 })
		end
	end,
})

Tabs.Main:AddToggle("BringMobToggle", {
	Title = "Bring Mob",
	Default = State.bringMobEnabled,
	Callback = function(value)
		State.bringMobEnabled = value
		if not value then
			G.clearBringMobs()
		end
		Fluent:Notify({ Title = "Bring Mob", Content = value and "Enabled" or "Disabled", Duration = 2 })
	end,
})

Tabs.Main:AddToggle("LockMobCFrameToggle", {
	Title = "Anchored Mob",
	Default = true,
	Callback = function(value)
		State.lockMobCFrame = value
		Fluent:Notify({ Title = "Anchored Mob", Content = value and "Enabled" or "Disabled", Duration = 2 })
	end,
})

Tabs.Main:AddToggle("StandaloneFastAttackToggle", {
	Title = "Fast Attack",
	Default = false,
	Callback = function(value)
		FastAttackModule.Enabled = value
		if value then
			G.startFastAttack()
			if State.fruitAndMeleeEnabled then
				AlwaysFruitAttack.start()
			end
			Fluent:Notify({
				Title = "Fast Attack",
				Content = "Enabled | Range: " .. State.ATTACK_RANGE .. " | Rate: " .. State.ATTACK_RATE,
				Duration = 2,
			})
		else
			G.stopFastAttack()
			AlwaysFruitAttack.stop()
			Fluent:Notify({ Title = "Fast Attack", Content = "Disabled", Duration = 2 })
		end
	end,
})

Tabs.Island:AddParagraph({ Title = worldName, Content = "Select island then enable toggle" })

Tabs.Island:AddDropdown("IslandDropdown", {
	Title = "Select Island",
	Values = islandNames,
	Multi = false,
	Default = 1,
	Callback = function(value)
		State.selectedIslandName = value
		State.selectedIslandPos = islandMap[value]
	end,
})
State.selectedIslandName = islandNames[1]
State.selectedIslandPos = islandMap[islandNames[1]]

Tabs.Island:AddToggle("TweenToIslandToggle", {
	Title = "Go to Island",
	Default = false,
	Callback = function(value)
		State.teleportTweenEnabled = value
		if value then
			if not State.selectedIslandPos then
				Fluent:Notify({ Title = "Island", Content = "Select island first", Duration = 2 })
				return
			end
			Fluent:Notify({ Title = "Island", Content = "Going to " .. (State.selectedIslandName or ""), Duration = 2 })
			G.startTweenIsland()
		else
			G.stopTweenIsland()
			Fluent:Notify({ Title = "Island", Content = "Stopped", Duration = 2 })
		end
	end,
})

Tabs.FarmSetting:AddParagraph({ Title = "EquipWeapon", Content = "Weapon Tab" })

Tabs.FarmSetting:AddDropdown("WeaponTypeDropdown", {
	Title = "Weapon Type",
	Values = { "Melee", "Sword", "Fruit", "Gun" },
	Multi = false,
	Default = 1,
	Callback = function(value)
		State.selectedWeaponType = value
		Fluent:Notify({ Title = "Weapon Type", Content = "Selected " .. value, Duration = 2 })
	end,
})

Tabs.FarmSetting:AddToggle("AutoEquipToggle", {
	Title = "Auto Equip Weapon",
	Default = State.autoEquipEnabled,
	Callback = function(value)
		State.autoEquipEnabled = value
		Fluent:Notify({
			Title = "Auto Equip",
			Content = value and ("Enabled Equip " .. State.selectedWeaponType) or "Disabled",
			Duration = 2,
		})
	end,
})

Tabs.FarmSetting:AddParagraph({ Title = "TweenSpeed Etc", Content = "Setting Tab" })

Tabs.FarmSetting:AddToggle("FruitAndMeleeToggle", {
	Title = "Always Fruit Attack",
	Description = "",
	Default = false,
	Callback = function(value)
		State.fruitAndMeleeEnabled = value
		if value then
			AlwaysFruitAttack.start()
		else
			AlwaysFruitAttack.stop()
		end
		Fluent:Notify({
			Title = "Always Fruit",
			Content = value and "Enabled" or "Disabled",
			Duration = 2,
		})
	end,
})

Tabs.FarmSetting:AddSlider("FruitActionRateSlider", {
	Title = "Fruit Action Delay",
	Default = 0.3,
	Min = 0.1,
	Max = 2.0,
	Rounding = 1,
	Callback = function(value)
		FastFruitAttack.rate = value
	end,
})

Tabs.FarmSetting:AddSlider("FruitCycleDelaySlider", {
	Title = "Fruit Cycle Delay",
	Description = "",
	Default = 0.4,
	Min = 0.1,
	Max = 3.0,
	Rounding = 1,
	Callback = function(value)
		FastFruitAttack.cycleDelay = value
	end,
})

Tabs.FarmSetting:AddSlider("BringMobCountSlider", {
	Title = "Bring Mob Count",
	Default = State.BRING_MOB_COUNT,
	Min = 1,
	Max = 5,
	Rounding = 0,
	Callback = function(value)
		State.BRING_MOB_COUNT = math.floor(value)
	end,
})

Tabs.FarmSetting:AddSlider("SpeedSlider", {
	Title = "Farm Tween Speed",
	Default = State.SPEED,
	Min = 50,
	Max = 300,
	Rounding = 0,
	Callback = function(value)
		State.SPEED = value
	end,
})

Tabs.FarmSetting:AddSlider("YOffsetSlider", {
	Title = "Y Offset",
	Default = State.Y_OFFSET,
	Min = 0,
	Max = 120,
	Rounding = 0,
	Callback = function(value)
		State.Y_OFFSET = value
	end,
})

Tabs.FarmSetting:AddSlider("AttackRateSlider", {
	Title = "Attack Rate",
	Default = State.ATTACK_RATE,
	Min = 0.05,
	Max = 1.0,
	Rounding = 1,
	Callback = function(value)
		State.ATTACK_RATE = value
		FastAttackModule.Rate = value
	end,
})

Tabs.FarmSetting:AddSlider("AttackRangeSlider", {
	Title = "Attack Range",
	Default = State.ATTACK_RANGE,
	Min = 10,
	Max = 300,
	Rounding = 0,
	Callback = function(value)
		State.ATTACK_RANGE = value
	end,
})

local EventMagnet = {
	enabled = false,
	killedSpawns = {},
	currentTarget = nil,
	_currentTargetName = nil,
	currentSpawnPos = nil,
	phase = "idle",
	conn = nil,
	lastMinute = -1,
	memCleared = false,
	waitStartTime = 0,
	WAIT_MOB_TIMEOUT = 5,
	attackConn = nil,
}

function EventMagnet.isEventTime()
	local min = tonumber(os.date("%M"))
	return min ~= nil and (min >= 0 and min <= 9)
end

function EventMagnet.isClearTime()
	local min = tonumber(os.date("%M"))
	return min ~= nil and min >= 11
end

function EventMagnet.spawnKey(pos)
	return G.positionKey(pos)
end

function EventMagnet.getPendingSpawns()
	local result = {}
	local folder = game:GetService("ReplicatedStorage"):FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
	if not folder then
		return result
	end

	for _, obj in ipairs(folder:GetChildren()) do
		if G.SPAWN_IGNORE_NAMES[obj.Name] then
			continue
		end

		local pos = nil
		if obj:IsA("BasePart") then
			pos = obj.Position
		elseif obj:IsA("Model") then
			local r = obj.PrimaryPart
				or obj:FindFirstChild("HumanoidRootPart")
				or obj:FindFirstChildWhichIsA("BasePart")
			if r then
				pos = r.Position
			end
		elseif obj:IsA("CFrameValue") then
			pos = obj.Value.Position
		elseif obj:IsA("Vector3Value") then
			pos = obj.Value
		end

		if pos then
			local key = EventMagnet.spawnKey(pos)
			if not EventMagnet.killedSpawns[key] then
				table.insert(result, { name = obj.Name, pos = pos, key = key })
			end
		end
		for _, child in ipairs(obj:GetChildren()) do
			if G.SPAWN_IGNORE_NAMES[child.Name] then
				continue
			end
			local cpos = nil
			if child:IsA("BasePart") then
				cpos = child.Position
			elseif child:IsA("CFrameValue") then
				cpos = child.Value.Position
			elseif child:IsA("Vector3Value") then
				cpos = child.Value
			end
			if cpos then
				local ckey = EventMagnet.spawnKey(cpos)
				if not EventMagnet.killedSpawns[ckey] then
					table.insert(result, { name = obj.Name, pos = cpos, key = ckey })
				end
			end
		end
	end

	return result
end

function EventMagnet.findMagnetMob(wantedName, spawnPos, searchRadius)
	searchRadius = searchRadius or 80
	local enemies = workspace:FindFirstChild("Enemies")
	if not enemies then
		return nil
	end

	for _, mob in ipairs(enemies:GetChildren()) do
		local mobName = G.normalizeMobName(mob.Name)
		local wanted = G.normalizeMobName(wantedName)
		local nameMatch = (mobName == wanted) or (G.normalizeMobName(G.getMobBaseName(mob)) == wanted)

		local root = mob:FindFirstChild("HumanoidRootPart")
		local hum = mob:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 then
			continue
		end

		local dist = (root.Position - spawnPos).Magnitude
		local inRange = dist <= searchRadius

		if not (nameMatch or inRange) then
			continue
		end

		local magnet = mob:FindFirstChild("MagnetTransformedRigObject", true)
		if magnet then
			return mob, magnet
		end
	end
	return nil, nil
end

function EventMagnet.getMagnetPart(mob)
	if not mob then
		return nil
	end
	return mob:FindFirstChild("MagnetTransformedRigObject", true)
end

function EventMagnet.stopAttack()
	if EventMagnet.attackConn then
		EventMagnet.attackConn:Disconnect()
		EventMagnet.attackConn = nil
	end
end

function EventMagnet.startAttackMob(mob)
	EventMagnet.stopAttack()
	EventMagnet.currentTarget = mob

	local root = mob:FindFirstChild("HumanoidRootPart")
	local magnetPart = EventMagnet.getMagnetPart(mob)
	if not root or not magnetPart then
		return
	end

	if State.autoEquipEnabled then
		G.autoEquipWeapon()
	end

	EventMagnet.phase = "attacking"

	local mobPos = root.Position
	local needSky = G.inSkyArea(mobPos)
	local needUnderwater = G.inUnderwaterArea(mobPos)

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local playerPos = hrp and hrp.Position

	local needEntry = false
	local entryRoute = {}

	if needSky and playerPos and not G.inSkyArea(playerPos) then
		needEntry = true
		table.insert(entryRoute, G.SKY_GATE)
		table.insert(entryRoute, CFrame.new(mobPos + Vector3.new(0, State.Y_OFFSET, 8)))
	elseif needUnderwater and playerPos and not G.inUnderwaterArea(playerPos) then
		needEntry = true
		table.insert(entryRoute, G.UNDERWATER_GATE)
		table.insert(entryRoute, CFrame.new(mobPos + Vector3.new(0, State.Y_OFFSET, 8)))
	end

	if needEntry then
		EventMagnet.phase = "moving"
		Fluent:Notify({
			Title = "Event Magnet",
			Content = "Going through gate to reach: " .. (mob.Name or "?"),
			Duration = 2,
		})

		G.exitRouteList = entryRoute
		G.exitRouteIndex = 1
		G.exitRouteActive = true

		if G.exitRouteConn then
			G.exitRouteConn:Disconnect()
			G.exitRouteConn = nil
		end

		local waitingForWarp = false
		local warpWaitPos = nil
		local warpWaitStart = 0
		local WARP_TRIGGER = 80
		local WARP_TIMEOUT = 15

		G.exitRouteConn = RunService.Heartbeat:Connect(function(dt)
			if not G.exitRouteActive then
				return
			end
			if not EventMagnet.enabled then
				G.stopExitRoute()
				return
			end

			local c = player.Character
			local h = c and c:FindFirstChild("HumanoidRootPart")
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			if not h or not hum or hum.Health <= 0 then
				return
			end

			if not G.isEnemyAlive(mob) then
				G.stopExitRoute()
				EventMagnet.currentTarget = nil
				EventMagnet.currentSpawnPos = nil
				EventMagnet.phase = "idle"
				return
			end

			if waitingForWarp then
				local movedDist = (h.Position - warpWaitPos).Magnitude
				local timedOut = (tick() - warpWaitStart) > WARP_TIMEOUT
				if movedDist > WARP_TRIGGER or timedOut then
					waitingForWarp = false
					warpWaitPos = nil
					State.currentFlyCF = h.CFrame
					G.exitRouteIndex = G.exitRouteIndex + 1
					G.stopMomentum()
				else
					pcall(function()
						h.AssemblyLinearVelocity = Vector3.zero
						h.AssemblyAngularVelocity = Vector3.zero
					end)
					return
				end
			end

			if G.exitRouteIndex > #G.exitRouteList then
				G.stopExitRoute()
				State.currentFlyCF = h.CFrame
				Fluent:Notify({
					Title = "Event Magnet",
					Content = "Entered area, attacking: " .. (mob.Name or "?"),
					Duration = 2,
				})
				EventMagnet._beginAttackLoop(mob, magnetPart)
				return
			end

			local targetCF = G.exitRouteList[G.exitRouteIndex]
			local currentPos = State.currentFlyCF and State.currentFlyCF.Position or h.Position
			local dist = (targetCF.Position - currentPos).Magnitude

			if dist > 6 then
				G.moveToTarget(h, targetCF, dt)
			else
				State.currentFlyCF = targetCF
				pcall(function()
					h.CFrame = targetCF
					h.AssemblyLinearVelocity = Vector3.zero
					h.AssemblyAngularVelocity = Vector3.zero
				end)

				local isLast = (G.exitRouteIndex >= #G.exitRouteList)
				if isLast then
					G.stopExitRoute()
					State.currentFlyCF = h.CFrame
					Fluent:Notify({
						Title = "Event Magnet",
						Content = "Entered area, attacking: " .. (mob.Name or "?"),
						Duration = 2,
					})
					EventMagnet._beginAttackLoop(mob, magnetPart)
				else
					waitingForWarp = true
					warpWaitPos = targetCF.Position
					warpWaitStart = tick()
				end
			end
		end)
	else
		EventMagnet._beginAttackLoop(mob, magnetPart)
	end
end

function EventMagnet._beginAttackLoop(mob, magnetPart)
	if State.bringMobEnabled then
		G.updateBringMobs(mob, tick())
	end

	EventMagnet.phase = "attacking"

	local ATTACK_LOCK_DIST = 20

	EventMagnet.attackConn = RunService.Heartbeat:Connect(function(dt)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then
			return
		end

		if not G.isEnemyAlive(mob) then
			if EventMagnet.currentSpawnPos then
				local key = EventMagnet.spawnKey(EventMagnet.currentSpawnPos)
				EventMagnet.killedSpawns[key] = {
					name = mob.Name,
					pos = EventMagnet.currentSpawnPos,
				}
			end
			EventMagnet.currentTarget = nil
			EventMagnet.currentSpawnPos = nil
			EventMagnet.phase = "idle"
			EventMagnet.stopAttack()
			G.clearBringMobs()

			local currentPos = hrp.Position
			if G.inSkyArea(currentPos) or G.inUnderwaterArea(currentPos) then
				G.startExitRoute(function()
					Fluent:Notify({
						Title = "Event Magnet",
						Content = "Killed: " .. (mob.Name or "?") .. " → exited area",
						Duration = 2,
					})
				end)
			else
				Fluent:Notify({
					Title = "Event Magnet",
					Content = "Killed: " .. (mob.Name or "?") .. " → next spawn",
					Duration = 2,
				})
			end
			return
		end

		local magnetTarget = magnetPart
		if magnetPart and magnetPart:IsA("ObjectValue") then
			magnetTarget = magnetPart.Value
		end

		local mobRoot = mob:FindFirstChild("HumanoidRootPart")
		local magnetCF = nil
		if magnetTarget and magnetTarget.Parent and magnetTarget:IsA("BasePart") then
			magnetCF = magnetTarget.CFrame * CFrame.new(0, State.Y_OFFSET, 8)
		elseif mobRoot then
			magnetCF = mobRoot.CFrame * CFrame.new(0, State.Y_OFFSET, 8)
		end

		if not magnetCF then
			return
		end

		local distToTarget = (magnetCF.Position - hrp.Position).Magnitude

		if distToTarget > ATTACK_LOCK_DIST then
			G.moveToTarget(hrp, magnetCF, dt)
			return
		end

		pcall(function()
			hrp.CFrame = magnetCF
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end)

		if State.bringMobEnabled then
			G.updateBringMobs(mob, tick())
		end

		if State.autoEquipEnabled then
			G.autoEquipWeapon()
		end

		local currentTool = char:FindFirstChildOfClass("Tool")
		local isFruit = false
		if currentTool then
			local hasLC = currentTool:FindFirstChild("LeftClickRemote", true)
			if hasLC then
				isFruit = true
			end
			if not isFruit then
				local tooltip = G.getToolTooltip(currentTool):lower()
				local toolName = currentTool.Name:lower()
				if
					tooltip:find("blox fruit")
					or tooltip:find("fruit")
					or toolName:find("fruit")
					or tooltip:find("devil")
					or toolName:find("devil")
				then
					isFruit = true
				end
			end
		end

		if isFruit then
			local remote = currentTool and currentTool:FindFirstChild("LeftClickRemote", true)
			local targetPos = mobRoot and mobRoot.Position
			if remote and targetPos then
				local dir = (targetPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				local mag = dir.Magnitude
				local direction = mag > 0.01 and (dir / mag) or hrp.CFrame.LookVector
				for action = 1, 4 do
					pcall(function()
						remote:FireServer(direction, action)
					end)
				end
			end
		else
			pcall(FastAttackModule.ExecuteFastAttack)
			pcall(G.HitRegistrationModule.Execute)
		end
	end)
end

function EventMagnet.stop()
	EventMagnet.enabled = false
	EventMagnet.phase = "idle"
	EventMagnet.currentTarget = nil
	EventMagnet.currentSpawnPos = nil
	EventMagnet.stopAttack()
	G.clearBringMobs()
	G.cancelTween()
	if EventMagnet.conn then
		EventMagnet.conn:Disconnect()
		EventMagnet.conn = nil
	end
end

function EventMagnet.start()
	EventMagnet.stop()
	EventMagnet.enabled = true
	EventMagnet.phase = "idle"

	EventMagnet.conn = RunService.Heartbeat:Connect(function(dt)
		if not EventMagnet.enabled then
			EventMagnet.stop()
			return
		end

		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		local nowMin = tonumber(os.date("%M")) or 0

		if nowMin >= 11 then
			if not EventMagnet.memCleared then
				EventMagnet.killedSpawns = {}
				EventMagnet.memCleared = true
				EventMagnet.currentTarget = nil
				EventMagnet.currentSpawnPos = nil
				EventMagnet.phase = "idle"
				EventMagnet.stopAttack()
				G.clearBringMobs()
				G.cancelTween()
				Fluent:Notify({
					Title = "Event Magnet",
					Content = "Memory cleared - waiting for next :00",
					Duration = 3,
				})
			end
			return
		end

		if nowMin < 11 then
			EventMagnet.memCleared = false
		end

		if not EventMagnet.isEventTime() then
			if EventMagnet.phase == "attacking" then
				EventMagnet.stopAttack()
				G.clearBringMobs()
				EventMagnet.phase = "idle"
			end
			return
		end

		if EventMagnet.phase == "attacking" then
			return
		end

		if not hrp or not hum or hum.Health <= 0 then
			return
		end

		local pending = EventMagnet.getPendingSpawns()
		if #pending == 0 then
			return
		end

		table.sort(pending, function(a, b)
			return (a.pos - hrp.Position).Magnitude < (b.pos - hrp.Position).Magnitude
		end)

		local target = pending[1]
		if not target then
			return
		end

		local distToSpawn = (target.pos - hrp.Position).Magnitude

		if EventMagnet.phase == "idle" then
			EventMagnet.currentSpawnPos = target.pos
			EventMagnet.phase = "moving"
			EventMagnet._currentTargetName = target.name
			State.currentFlyCF = hrp.CFrame

			Fluent:Notify({
				Title = "Event Magnet",
				Content = "Moving to spawn: " .. target.name,
				Duration = 2,
			})
		end

		if EventMagnet.phase == "moving" then
			if distToSpawn > 15 then
				G.moveToTarget(hrp, CFrame.new(target.pos + Vector3.new(0, 5, 0)), dt)
				return
			end

			EventMagnet.phase = "waiting"
			EventMagnet._currentTargetName = target.name
			EventMagnet.waitStartTime = tick()
			Fluent:Notify({
				Title = "Event Magnet",
				Content = "Waiting for mob: " .. target.name,
				Duration = 2,
			})
		end

		if EventMagnet.phase == "waiting" then
			local mob, magnetPart = EventMagnet.findMagnetMob(target.name, target.pos)

			if mob and magnetPart then
				EventMagnet.currentSpawnPos = target.pos
				EventMagnet.startAttackMob(mob)
			else
				local waited = tick() - (EventMagnet.waitStartTime or tick())

				if waited >= EventMagnet.WAIT_MOB_TIMEOUT then
					local allSpawns = EventMagnet.getPendingSpawns()
					for _, sp in ipairs(allSpawns) do
						if G.normalizeMobName(sp.name) == G.normalizeMobName(target.name) then
							EventMagnet.killedSpawns[sp.key] = { name = sp.name, pos = sp.pos }
						end
					end
					EventMagnet.currentSpawnPos = nil
					EventMagnet.phase = "idle"
					Fluent:Notify({
						Title = "Event Magnet",
						Content = "No magnet: " .. target.name .. " - skip all spawns of this mob",
						Duration = 2,
					})
				else
					pcall(function()
						hrp.CFrame = CFrame.new(target.pos + Vector3.new(0, 8, 0))
						hrp.AssemblyLinearVelocity = Vector3.zero
						hrp.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end
		end
	end)
end

Tabs.Event:AddToggle("EventMagnetToggle", {
	Title = "Auto Event Magnet",
	Default = false,
	Callback = function(value)
		if value then
			EventMagnet.start()
			Fluent:Notify({
				Title = "Event Magnet",
				Content = "Enabled - will activate at **:00",
				Duration = 3,
			})
		else
			EventMagnet.stop()
			Fluent:Notify({
				Title = "Event Magnet",
				Content = "Disabled",
				Duration = 2,
			})
		end
	end,
})

local EventStatusParagraph = Tabs.Event:AddParagraph({
	Title = "Status",
	Content = "Idle",
})

task.spawn(function()
	while task.wait(1) do
		if not EventMagnet.enabled then
			EventStatusParagraph:SetDesc("Disabled")
			continue
		end

		local nowHour = tonumber(os.date("%H")) or 0
		local nowMin = tonumber(os.date("%M")) or 0
		local nowSec = tonumber(os.date("%S")) or 0
		local killed = 0
		for _ in pairs(EventMagnet.killedSpawns) do
			killed = killed + 1
		end

		local timeStatus
		if nowMin >= 11 then
			local secToNext = (60 - nowSec) + (59 - nowMin) * 60
			timeStatus = string.format(
				"Waiting %02d:%02d:%02d (next event in %dm %ds)",
				nowHour,
				nowMin,
				nowSec,
				math.floor(secToNext / 60),
				secToNext % 60
			)
		elseif nowMin == 10 then
			timeStatus = string.format("Event ended %02d:%02d:%02d - waiting for :11", nowHour, nowMin, nowSec)
		else
			local secLeft = (9 - nowMin) * 60 + (60 - nowSec)
			timeStatus = string.format(
				"ACTIVE %02d:%02d:%02d (ends in %dm %ds)",
				nowHour,
				nowMin,
				nowSec,
				math.floor(secLeft / 60),
				secLeft % 60
			)
		end

		local mobName = EventMagnet.currentTarget and EventMagnet.currentTarget.Name
			or (EventMagnet.currentSpawnPos and EventMagnet._currentTargetName)
			or "?"

		local phaseDesc
		if EventMagnet.phase == "idle" then
			phaseDesc = "Idle / searching next spawn"
		elseif EventMagnet.phase == "moving" then
			phaseDesc = string.format(
				"Moving to: [%s]  pos(%.0f, %.0f, %.0f)",
				EventMagnet._currentTargetName or "?",
				EventMagnet.currentSpawnPos and EventMagnet.currentSpawnPos.X or 0,
				EventMagnet.currentSpawnPos and EventMagnet.currentSpawnPos.Y or 0,
				EventMagnet.currentSpawnPos and EventMagnet.currentSpawnPos.Z or 0
			)
		elseif EventMagnet.phase == "waiting" then
			local waited = tick() - (EventMagnet.waitStartTime or tick())
			phaseDesc = string.format(
				"Waiting for [%s] to spawn... (%.0fs / %ds)",
				EventMagnet._currentTargetName or "?",
				waited,
				EventMagnet.WAIT_MOB_TIMEOUT
			)
		elseif EventMagnet.phase == "attacking" then
			phaseDesc = "Attacking: [" .. (EventMagnet.currentTarget and EventMagnet.currentTarget.Name or "?") .. "]"
		else
			phaseDesc = EventMagnet.phase
		end

		local desc = string.format("Time: %s\nPhase: %s\nKilled: %d spawns", timeStatus, phaseDesc, killed)
		EventStatusParagraph:SetDesc(desc)

		if EventMagnet.phase ~= "idle" and EventMagnet.enabled then
			Fluent:Notify({
				Title = "Event Magnet",
				Content = phaseDesc,
				Duration = 1,
			})
		end
	end
end)

G.addonPlayers = game:GetService("Players")
G.addonRep = game:GetService("ReplicatedStorage")
G.addonRun = game:GetService("RunService")
G.addonVU = game:GetService("VirtualUser")
G.addonTPS = game:GetService("TeleportService")

plr = G.addonPlayers.LocalPlayer
replicated = G.addonRep
Sec = Sec or 0.1

local function P(tab, title, content)
	local obj = tab:AddParagraph({ Title = title, Content = content })
	if obj and not obj.SetDesc and obj.SetContent then
		obj.SetDesc = obj.SetContent
	end
	return obj
end

function G.AddonHop()
	pcall(function()
		local Http = game:GetService("HttpService")
		local PlaceID = game.PlaceId
		local Cursor, found = "", false
		repeat
			local ok, result = pcall(function()
				return game:HttpGet(
					"https://games.roblox.com/v1/games/"
						.. PlaceID
						.. "/servers/Public?sortOrder=Asc&limit=100&cursor="
						.. Cursor
				)
			end)
			if ok and result then
				local data = Http:JSONDecode(result)
				if data.data then
					for _, v in pairs(data.data) do
						if v.playing < v.maxPlayers and v.id ~= game.JobId then
							found = true
							G.addonTPS:TeleportToPlaceInstance(PlaceID, v.id)
							break
						end
					end
					Cursor = data.nextPageCursor or ""
				end
			end
		until not Cursor or Cursor == "" or found
	end)
end

function G.statsSetings(Num, value)
	local map = {
		Melee = "Melee",
		Defense = "Defense",
		Sword = "Sword",
		Gun = "Gun",
		Devil = "Demon Fruit",
	}
	local target = map[Num]
	if not target then
		return
	end
	if plr.Data and plr.Data.Points and plr.Data.Points.Value ~= 0 then
		replicated.Remotes.CommF_:InvokeServer("AddPoint", target, value)
	end
end

function G.getInfinity_Ability(Method, Var)
	if Method == "Soru" and Var then
		for _, gc in next, getgc() do
			if plr.Character and plr.Character:FindFirstChild("Soru") then
				if (typeof(gc) == "function") and (getfenv(gc).script == plr.Character.Soru) then
					for _, v in next, getupvalues(gc) do
						if typeof(v) == "table" then
							repeat
								task.wait(Sec)
								v.LastUse = 0
							until not Var or (plr.Character.Humanoid.Health <= 0)
						end
					end
				end
			end
		end
	elseif Method == "Energy" and Var then
		if plr.Character and plr.Character:FindFirstChild("Energy") then
			local energy = plr.Character.Energy
			local maxEnergy = energy.Value
			energy.Changed:Connect(function()
				if Var then
					energy.Value = maxEnergy
				end
			end)
		end
	elseif Method == "Observation" and Var then
		pcall(function()
			plr.VisionRadius.Value = math.huge
		end)
	end
end

Tabs.LocalPlayer:AddParagraph({ Title = "Character", Content = "Player features / Haki / Race / Observation" })

Tabs.LocalPlayer:AddToggle("AntiAfkToggle", {
	Title = "Anti AFK",
	Default = true,
	Callback = function(Value)
		_G.AntiAfk = Value
		if Value and not _G.AntiAfkHooked then
			_G.AntiAfkHooked = true
			plr.Idled:Connect(function()
				if not _G.AntiAfk then
					return
				end
				G.addonVU:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				task.wait(1)
				G.addonVU:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end)
		end
	end,
})

Tabs.LocalPlayer:AddToggle("AntiLavaToggle", {
	Title = "Anti Lava",
	Default = false,
	Callback = function(Value)
		_G.AntiLava = Value
		if Value then
			pcall(function()
				for _, v in ipairs(workspace.Map:GetDescendants()) do
					if v.Name == "Lava" and v:IsA("BasePart") then
						v:Destroy()
					end
				end
			end)
			task.spawn(function()
				while _G.AntiLava do
					pcall(function()
						for _, v in ipairs(workspace.Map:GetDescendants()) do
							if v.Name == "Lava" and v:IsA("BasePart") then
								v:Destroy()
							end
						end
					end)
					task.wait(1)
				end
			end)
			Fluent:Notify({ Title = "Anti Lava", Content = "Enabled - Lava removed", Duration = 2 })
		else
			Fluent:Notify({ Title = "Anti Lava", Content = "Disabled", Duration = 2 })
		end
	end,
})

Tabs.LocalPlayer:AddToggle("AutoBusoToggle", {
	Title = "Auto Buso Haki",
	Default = true,
	Callback = function(Value)
		_G.AutoBuso = Value
	end,
})
task.spawn(function()
	while task.wait(Sec) do
		if _G.AutoBuso then
			pcall(function()
				if plr.Character and not plr.Character:FindFirstChild("HasBuso") then
					replicated.Remotes.CommF_:InvokeServer("Buso")
				end
			end)
		end
	end
end)

Tabs.LocalPlayer:AddToggle("AutoObservationToggle", {
	Title = "Auto Observation Haki",
	Default = false,
	Callback = function(Value)
		_G.AutoObservation = Value
	end,
})
task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoObservation then
			pcall(function()
				replicated.Remotes.CommE:FireServer("Ken", true)
			end)
		end
	end
end)

Tabs.LocalPlayer:AddToggle("AutoRaceV3Toggle", {
	Title = "Auto Race V3",
	Default = false,
	Callback = function(Value)
		_G.RaceClickAutov3 = Value
	end,
})
task.spawn(function()
	while task.wait(0.5) do
		if _G.RaceClickAutov3 then
			pcall(function()
				replicated.Remotes.CommE:FireServer("ActivateAbility")
			end)
			for _ = 1, 60 do
				if not _G.RaceClickAutov3 then
					break
				end
				task.wait(0.5)
			end
		end
	end
end)

Tabs.LocalPlayer:AddToggle("AutoRaceV4Toggle", {
	Title = "Auto Race V4",
	Default = false,
	Callback = function(Value)
		_G.RaceClickAutov4 = Value
	end,
})
task.spawn(function()
	while task.wait(0.3) do
		if _G.RaceClickAutov4 then
			pcall(function()
				local energy = plr.Character and plr.Character:FindFirstChild("RaceEnergy")
				if energy and energy.Value == 1 then
					pressKey("Y")
				end
			end)
		end
	end
end)

Tabs.LocalPlayer:AddParagraph({ Title = "Anti / modified", Content = "Anti Admin Noclip InfAbility Etc." })

Tabs.LocalPlayer:AddToggle("AntiAdminToggle", {
	Title = "Anti Admin (Auto Hop)",
	Default = false,
	Callback = function(Value)
		_G.HopServerAdmin = Value
	end,
})
task.spawn(function()
	local blacklist = {
		"red_game43",
		"rip_indra",
		"Axiore",
		"Polkster",
		"wenlocktoad",
		"Daigrock",
		"toilamvidamme",
		"oofficialnoobie",
		"Uzoth",
		"Azarth",
		"arlthmetic",
		"Death_King",
		"Lunoven",
		"TheGreateAced",
		"rip_fud",
		"drip_mama",
		"layandikit12",
		"Hingoi",
	}
	while task.wait(1) do
		if _G.HopServerAdmin then
			pcall(function()
				for _, v in pairs(G.addonPlayers:GetPlayers()) do
					if table.find(blacklist, v.Name) then
						Fluent:Notify({
							Title = "Anti Admin",
							Content = "Admin found: " .. v.Name .. " - hopping server",
							Duration = 5,
						})
						G.AddonHop()
						break
					end
				end
			end)
		end
	end
end)

Tabs.LocalPlayer:AddToggle("NoClipToggle", {
	Title = "No Clip",
	Default = false,
	Callback = function(Value)
		_G.NoClip = Value
	end,
})
G.addonRun.Stepped:Connect(function()
	local farmActive = State.autoFarmEnabled or State.autoFarmSelectEnabled

	if _G.NoClip and plr.Character then
		pcall(function()
			for _, v in pairs(plr.Character:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end)
	end
end)

Tabs.LocalPlayer:AddToggle("InfEnergyToggle", {
	Title = "Inf Energy",
	Default = false,
	Callback = function(Value)
		_G.infEnergy = Value
		if Value then
			G.getInfinity_Ability("Energy", true)
		end
	end,
})

Tabs.LocalPlayer:AddToggle("InfSoruToggle", {
	Title = "Soru NoCD (Risk)",
	Default = false,
	Callback = function(Value)
		_G.InfSoru = Value
		if Value then
			task.spawn(G.getInfinity_Ability, "Soru", true)
		end
	end,
})

Tabs.LocalPlayer:AddToggle("InfObsRangeToggle", {
	Title = "Observation Inf Range",
	Default = false,
	Callback = function(Value)
		_G.InfiniteObRange = Value
		if Value then
			G.getInfinity_Ability("Observation", true)
		end
	end,
})

Tabs.LocalPlayer:AddToggle("AcceptAllyToggle", {
	Title = "Accept Allies",
	Default = false,
	Callback = function(Value)
		_G.AcceptAlly = Value
	end,
})
task.spawn(function()
	while task.wait(1) do
		if _G.AcceptAlly then
			pcall(function()
				for _, v in pairs(G.addonPlayers:GetPlayers()) do
					if v.Name ~= plr.Name then
						replicated.Remotes.CommF_:InvokeServer("AcceptAlly", v.Name)
					end
				end
			end)
		end
	end
end)

Tabs.Stat:AddParagraph({ Title = "Auto Up Stats", Content = "Select amount then enable" })

G.pSats = 10
Tabs.Stat:AddSlider("StatsValueSlider", {
	Title = "Stats Value",
	Default = 10,
	Min = 1,
	Max = 1000,
	Rounding = 0,
	Callback = function(Value)
		G.pSats = Value
	end,
})

local statOptions = {
	{ flag = "AutoMeleeToggle", title = "Auto Melee", key = "Melee", desc = "Upgrade melee" },
	{ flag = "AutoSwordToggle", title = "Auto Sword", key = "Sword", desc = "Upgrade sword" },
	{ flag = "AutoGunToggle", title = "Auto Gun", key = "Gun", desc = "Upgrade gun" },
	{ flag = "AutoFruitToggle", title = "Auto Blox Fruit", key = "Devil", desc = "Upgrade fruit" },
	{ flag = "AutoDefenseToggle", title = "Auto Defense", key = "Defense", desc = "Upgrade defense" },
}

local statEnabled = {}
for _, opt in ipairs(statOptions) do
	Tabs.Stat:AddToggle(opt.flag, {
		Title = opt.title,
		Default = false,
		Callback = function(Value)
			statEnabled[opt.key] = Value
		end,
	})
end

task.spawn(function()
	while task.wait(0.5) do
		for _, opt in ipairs(statOptions) do
			if statEnabled[opt.key] then
				pcall(G.statsSetings, opt.key, G.pSats)
			end
		end
	end
end)

Tabs.Esp:AddParagraph({ Title = "ESP", Content = "Toggle what you want to see" })

function isnil(thing)
	return (thing == nil)
end

function round(n)
	return math.floor(tonumber(n) + 0.5)
end
Number = math.random(1, 1000000)

plr = game:GetService("Players").LocalPlayer
replicated = game:GetService("ReplicatedStorage")
G.TeamSelf = plr.Team

EspPly = function()
	for _, v in next, game.Players:GetChildren() do
		pcall(function()
			if not isnil(v.Character) then
				if PlayerEsp then
					if not isnil(v.Character.Head) and not v.Character.Head:FindFirstChild("NameEsp" .. Number) then
						local bill = Instance.new("BillboardGui", v.Character.Head)
						bill.Name = "NameEsp" .. Number
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = v.Character.Head
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = Enum.Font.Code
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Text = (
							v.Name
							.. " \n"
							.. round((plr.Character.Head.Position - v.Character.Head.Position).Magnitude / 3)
							.. " M"
						)
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = Enum.TextYAlignment.Top
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						if v.Team == G.TeamSelf then
							name.TextColor3 = Color3.new(0, 0, 254)
						else
							name.TextColor3 = Color3.new(255, 0, 0)
						end
					else
						if v.Character.Head:FindFirstChild("NameEsp" .. Number) then
							v.Character.Head["NameEsp" .. Number].TextLabel.Text = (
								v.Name
								.. " | "
								.. round((plr.Character.Head.Position - v.Character.Head.Position).Magnitude / 3)
								.. " M\nHealth : "
								.. round(v.Character.Humanoid.Health * 100 / v.Character.Humanoid.MaxHealth)
								.. "%"
							)
						end
					end
				else
					if v.Character.Head:FindFirstChild("NameEsp" .. Number) then
						v.Character.Head:FindFirstChild("NameEsp" .. Number):Destroy()
					end
				end
			end
		end)
	end
end

LocationEsp = function()
	for _, v in next, workspace["_WorldOrigin"].Locations:GetChildren() do
		pcall(function()
			if IslandESP then
				if v.Name ~= "Sea" then
					if not v:FindFirstChild("NameEsp") then
						local bill = Instance.new("BillboardGui", v)
						bill.Name = "NameEsp"
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = v
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = Enum.Font.Code
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = Enum.TextYAlignment.Top
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						name.TextColor3 = Color3.fromRGB(98, 252, 252)
						name.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
							.. " M"
						)
					else
						v["NameEsp"].TextLabel.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
							.. " M"
						)
					end
				end
			else
				if v:FindFirstChild("NameEsp") then
					v:FindFirstChild("NameEsp"):Destroy()
				end
			end
		end)
	end
end

DevEsp = function()
	for i, v in next, workspace:GetChildren() do
		pcall(function()
			if DevilFruitESP then
				if string.find(v.Name, "Fruit") then
					if not v.Handle:FindFirstChild("NameEsp" .. Number) then
						local bill = Instance.new("BillboardGui", v.Handle)
						bill.Name = "NameEsp" .. Number
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = v.Handle
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = Enum.Font.Code
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = Enum.TextYAlignment.Top
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						name.TextColor3 = Color3.fromRGB(255, 255, 255)
						name.Text = (
							v.Name
							.. " \n"
							.. round((plr.Character.Head.Position - v.Handle.Position).Magnitude / 3)
							.. " M"
						)
					else
						v.Handle["NameEsp" .. Number].TextLabel.Text = (
							"["
							.. v.Name
							.. "]"
							.. "   \n"
							.. round((plr.Character.Head.Position - v.Handle.Position).Magnitude / 3)
							.. " M"
						)
					end
				end
			else
				if v:FindFirstChild("Handle") and v.Handle:FindFirstChild("NameEsp" .. Number) then
					v.Handle:FindFirstChild("NameEsp" .. Number):Destroy()
				end
			end
		end)
	end
end

flowerEsp = function()
	for i, v in pairs(workspace:GetChildren()) do
		pcall(function()
			if v.Name == "Flower2" or v.Name == "Flower1" then
				if FlowerESP then
					if not v:FindFirstChild("NameEsp" .. Number) then
						local bill = Instance.new("BillboardGui", v)
						bill.Name = "NameEsp" .. Number
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = v
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = Enum.Font.Code
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = Enum.TextYAlignment.Top
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						name.TextColor3 = Color3.fromRGB(88, 214, 252)
						if v.Name == "Flower1" then
							name.Text = (
								"Blue Flower"
								.. " \n"
								.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
								.. " M"
							)
						elseif v.Name == "Flower2" then
							name.Text = (
								"Red Flower"
								.. " \n"
								.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
								.. " M"
							)
						end
					else
						v["NameEsp" .. Number].TextLabel.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
							.. " M"
						)
					end
				else
					if v:FindFirstChild("NameEsp" .. Number) then
						v:FindFirstChild("NameEsp" .. Number):Destroy()
					end
				end
			end
		end)
	end
end

EventIslandEsp = function()
	for i, v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
		pcall(function()
			if EspEventIsland then
				if v.Name == "Mirage Island" or v.Name == "Prehistoric Island" or v.Name == "Kitsune Island" then
					if not v:FindFirstChild("NameEsp") then
						local bill = Instance.new("BillboardGui", v)
						bill.Name = "NameEsp"
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = v
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = "Code"
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = "Top"
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						name.TextColor3 = Color3.fromRGB(80, 245, 245)
						name.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
							.. " M"
						)
					else
						v.NameEsp.TextLabel.Text = v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
							.. " M"
					end
				end
			else
				if v:FindFirstChild("NameEsp") then
					v:FindFirstChild("NameEsp"):Destroy()
				end
			end
		end)
	end
end

gearEsp = function()
	for _, v in pairs(workspace.Map.MysticIsland:GetDescendants()) do
		pcall(function()
			if ESPGear then
				if v.Name == "Part" and v.Material == Enum.Material.Neon then
					if not v:FindFirstChild("NameEsp") then
						local bill = Instance.new("BillboardGui", v)
						bill.Name = "NameEsp"
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = v
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = "Code"
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = "Top"
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						name.TextColor3 = Color3.fromRGB(80, 245, 245)
						name.Text = (
							"Gear"
							.. "   \n"
							.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
							.. " M"
						)
					else
						v["NameEsp"].TextLabel.Text = (
							"Gear"
							.. "   \n"
							.. round((plr.Character.Head.Position - v.Position).Magnitude / 3)
							.. " M"
						)
					end
				end
			else
				if v:FindFirstChild("NameEsp") then
					v:FindFirstChild("NameEsp"):Destroy()
				end
			end
		end)
	end
end

AdvanFruitEsp = function()
	if advanEsp then
		for _, v in pairs(replicated.NPCs:GetChildren()) do
			if v.Name == "Advanced Fruit Dealer" then
				if not workspace:FindFirstChild("Adv") then
					Adv = Instance.new("Part")
					Adv.Name = "Adv"
					Adv.Transparency = 1
					Adv.Size = Vector3.new(1, 1, 1)
					Adv.Anchored = true
					Adv.CanCollide = false
					Adv.Parent = workspace
					Adv.CFrame = v.HumanoidRootPart.CFrame
				elseif workspace:FindFirstChild("Adv") then
					if not Adv:FindFirstChild("NameEsp") then
						local bill = Instance.new("BillboardGui", Adv)
						bill.Name = "NameEsp"
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = Adv
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = "Code"
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = "Top"
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						name.TextColor3 = Color3.fromRGB(80, 245, 245)
						name.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.HumanoidRootPart.Position).Magnitude / 3)
							.. " M"
						)
					else
						Adv["NameEsp"].TextLabel.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.HumanoidRootPart.Position).Magnitude / 3)
							.. " M"
						)
					end
				end
			end
		end
	else
		if workspace:FindFirstChild("Adv") then
			workspace:FindFirstChild("Adv"):Destroy()
		end
	end
end

HakiClorEsp = function()
	if ColorEsp then
		for _, v in pairs(replicated.NPCs:GetChildren()) do
			if v.Name == "Barista Cousin" then
				if not workspace:FindFirstChild("Gay") then
					Gay = Instance.new("Part")
					Gay.Name = "Gay"
					Gay.Transparency = 1
					Gay.Size = Vector3.new(1, 1, 1)
					Gay.Anchored = true
					Gay.CanCollide = false
					Gay.Parent = workspace
					Gay.CFrame = v.HumanoidRootPart.CFrame
				elseif workspace:FindFirstChild("Gay") then
					if not Gay:FindFirstChild("NameEsp") then
						local bill = Instance.new("BillboardGui", Gay)
						bill.Name = "NameEsp"
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = Gay
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = "Code"
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = "Top"
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						name.TextColor3 = Color3.fromRGB(80, 245, 245)
						name.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.HumanoidRootPart.Position).Magnitude / 3)
							.. " M"
						)
					else
						Gay["NameEsp"].TextLabel.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.HumanoidRootPart.Position).Magnitude / 3)
							.. " M"
						)
					end
				end
			end
		end
	else
		if workspace:FindFirstChild("Gay") then
			workspace:FindFirstChild("Gay"):Destroy()
		end
	end
end

LegenSword = function()
	if LegenS then
		for _, v in pairs(replicated.NPCs:GetChildren()) do
			if v.Name == "Legendary Sword Dealer" then
				if not workspace:FindFirstChild("Lgd") then
					Lgd = Instance.new("Part")
					Lgd.Name = "Lgd"
					Lgd.Transparency = 1
					Lgd.Size = Vector3.new(1, 1, 1)
					Lgd.Anchored = true
					Lgd.CanCollide = false
					Lgd.Parent = workspace
					Lgd.CFrame = v.HumanoidRootPart.CFrame
				elseif workspace:FindFirstChild("Lgd") then
					if not Lgd:FindFirstChild("NameEsp") then
						local bill = Instance.new("BillboardGui", Lgd)
						bill.Name = "NameEsp"
						bill.ExtentsOffset = Vector3.new(0, 1, 0)
						bill.Size = UDim2.new(1, 200, 1, 30)
						bill.Adornee = Lgd
						bill.AlwaysOnTop = true
						local name = Instance.new("TextLabel", bill)
						name.Font = "Code"
						name.FontSize = "Size14"
						name.TextWrapped = true
						name.Size = UDim2.new(1, 0, 1, 0)
						name.TextYAlignment = "Top"
						name.BackgroundTransparency = 1
						name.TextStrokeTransparency = 0.5
						name.TextColor3 = Color3.fromRGB(80, 245, 245)
						name.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.HumanoidRootPart.Position).Magnitude / 3)
							.. " M"
						)
					else
						Lgd["NameEsp"].TextLabel.Text = (
							v.Name
							.. "   \n"
							.. round((plr.Character.Head.Position - v.HumanoidRootPart.Position).Magnitude / 3)
							.. " M"
						)
					end
				end
			end
		end
	else
		if workspace:FindFirstChild("Lgd") then
			workspace:FindFirstChild("Lgd"):Destroy()
		end
	end
end

G.chestEspTracked = {}
G.ChestCollection = game:GetService("CollectionService")

function G.chestIsGone(Chest)
	if not Chest or not Chest.Parent then
		return true
	end
	if not G.ChestCollection:HasTag(Chest, "_ChestTagged") then
		return true
	end
	local visible = false
	for _, p in ipairs(Chest:GetDescendants()) do
		if p:IsA("BasePart") and p.Transparency < 1 and p.Name ~= "ChestEspAttachment" then
			visible = true
			break
		end
	end
	if Chest:IsA("BasePart") and Chest.Transparency < 1 then
		visible = true
	end
	return not visible
end

function G.clearChestEsp(Chest)
	if not Chest then
		return
	end
	local att = Chest:FindFirstChild("ChestEspAttachment")
	if att then
		att:Destroy()
	end
	G.chestEspTracked[Chest] = nil
end

function G.clearAllChestEsp()
	for Chest in pairs(G.chestEspTracked) do
		G.clearChestEsp(Chest)
	end
	for _, Chest in ipairs(G.ChestCollection:GetTagged("_ChestTagged")) do
		local att = Chest:FindFirstChild("ChestEspAttachment")
		if att then
			att:Destroy()
		end
	end
	G.chestEspTracked = {}
end

G.ChestCollection:GetInstanceRemovedSignal("_ChestTagged"):Connect(function(Chest)
	G.clearChestEsp(Chest)
end)

ChestEsp = function()
	if not ChestESP then
		for _, Chest in ipairs(game:GetService("CollectionService"):GetTagged("_ChestTagged")) do
			local espAttachment = Chest:FindFirstChild("ChestEspAttachment")
			if espAttachment then
				espAttachment:Destroy()
			end
		end
		return
	end

	local CollectionService = game:GetService("CollectionService")
	local Chests = CollectionService:GetTagged("_ChestTagged")

	for _, Chest in ipairs(Chests) do
		pcall(function()
			local chestPos = Chest:GetPivot().Position
			local distanceMagnitude = (chestPos - plr.Character.Head.Position).Magnitude
			local existingEsp = Chest:FindFirstChild("ChestEspAttachment")

			if not existingEsp then
				local attachment = Instance.new("Attachment")
				attachment.Name = "ChestEspAttachment"
				attachment.Parent = Chest
				attachment.Position = Vector3.new(0, 3, 0)

				local nameEsp = Instance.new("BillboardGui")
				nameEsp.Name = "NameEsp"
				nameEsp.Size = UDim2.new(0, 200, 0, 30)
				nameEsp.Adornee = attachment
				nameEsp.ExtentsOffset = Vector3.new(0, 1, 0)
				nameEsp.AlwaysOnTop = true
				nameEsp.Parent = attachment

				local nameLabel = Instance.new("TextLabel")
				nameLabel.Font = Enum.Font.Code
				nameLabel.TextSize = 14
				nameLabel.TextWrapped = true
				nameLabel.Size = UDim2.new(1, 0, 1, 0)
				nameLabel.TextYAlignment = Enum.TextYAlignment.Top
				nameLabel.BackgroundTransparency = 1
				nameLabel.TextStrokeTransparency = 0.5
				nameLabel.TextColor3 = Color3.fromRGB(80, 245, 245)
				nameLabel.Parent = nameEsp

				existingEsp = attachment
			end

			local nameEsp = existingEsp and existingEsp:FindFirstChild("NameEsp")
			if nameEsp and nameEsp:FindFirstChild("TextLabel") then
				local displayDistance = math.floor(distanceMagnitude / 3)
				local chestName = Chest.Name:gsub("Label", "")
				nameEsp.TextLabel.Text = string.format("[%s] %d M", chestName, displayDistance)
			end
		end)
	end
end

berriesEsp = function()
	if BerryEsp then
		local CollectionService = game:GetService("CollectionService")
		local BerryBushes = CollectionService:GetTagged("BerryBush")
		for _, Bush in ipairs(BerryBushes) do
			pcall(function()
				local bushPosition = Bush.Parent:GetPivot().Position
				for _, BerryName in pairs(Bush:GetAttributes()) do
					if BerryName then
						local espPartName = "BerryEspPart_" .. BerryName .. "_" .. tostring(bushPosition)
						local existingEsp = workspace:FindFirstChild(espPartName)

						if not existingEsp then
							existingEsp = Instance.new("Part")
							existingEsp.Name = espPartName
							existingEsp.Transparency = 1
							existingEsp.Size = Vector3.new(1, 1, 1)
							existingEsp.Anchored = true
							existingEsp.CanCollide = false
							existingEsp.Parent = workspace
							existingEsp.CFrame = CFrame.new(bushPosition)
						end

						if not existingEsp:FindFirstChild("NameEsp") then
							local nameEsp = Instance.new("BillboardGui", existingEsp)
							nameEsp.Name = "NameEsp"
							nameEsp.ExtentsOffset = Vector3.new(0, 1, 0)
							nameEsp.Size = UDim2.new(0, 200, 0, 30)
							nameEsp.Adornee = existingEsp
							nameEsp.AlwaysOnTop = true

							local nameLabel = Instance.new("TextLabel", nameEsp)
							nameLabel.Font = Enum.Font.Code
							nameLabel.TextSize = 14
							nameLabel.TextWrapped = true
							nameLabel.Size = UDim2.new(1, 0, 1, 0)
							nameLabel.TextYAlignment = Enum.TextYAlignment.Top
							nameLabel.BackgroundTransparency = 1
							nameLabel.TextStrokeTransparency = 0.5
							nameLabel.TextColor3 = Color3.fromRGB(80, 245, 245)
						end

						local nameEsp = existingEsp:FindFirstChild("NameEsp")
						local distance = (plr.Character.Head.Position - bushPosition).Magnitude / 3
						if nameEsp then
							nameEsp.TextLabel.Text = ("[" .. BerryName .. "]" .. " " .. math.round(distance) .. " M")
						end
					end
				end
			end)
		end
	else
		for _, v in ipairs(workspace:GetChildren()) do
			if v:IsA("Part") and v.Name:match("BerryEspPart_.*") then
				v:Destroy()
			end
		end
	end
end

Tabs.Esp:AddToggle("EspBerryToggle", {
	Title = "Esp Berry",
	Default = false,
	Callback = function(Value)
		BerryEsp = Value
		if not Value then
			for _, v in ipairs(workspace:GetChildren()) do
				if v:IsA("Part") and v.Name:match("BerryEspPart_.*") then
					v:Destroy()
				end
			end
		else
			task.spawn(function()
				while BerryEsp do
					berriesEsp()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspPlayerToggle", {
	Title = "Esp Player",
	Default = false,
	Callback = function(Value)
		PlayerEsp = Value
		if not Value then
			for _, v in next, game.Players:GetChildren() do
				pcall(function()
					if not isnil(v.Character) and not isnil(v.Character.Head) then
						if v.Character.Head:FindFirstChild("NameEsp" .. Number) then
							v.Character.Head:FindFirstChild("NameEsp" .. Number):Destroy()
						end
					end
				end)
			end
		else
			task.spawn(function()
				while PlayerEsp do
					EspPly()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspChestToggle", {
	Title = "Esp Chest",
	Default = false,
	Callback = function(Value)
		ChestESP = Value
		if not Value then
			for _, Chest in ipairs(game:GetService("CollectionService"):GetTagged("_ChestTagged")) do
				local espAttachment = Chest:FindFirstChild("ChestEspAttachment")
				if espAttachment then
					espAttachment:Destroy()
				end
			end
		else
			task.spawn(function()
				while ChestESP do
					ChestEsp()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspFruitToggle", {
	Title = "Esp Fruit",
	Default = false,
	Callback = function(Value)
		DevilFruitESP = Value
		if not Value then
			for i, v in next, workspace:GetChildren() do
				pcall(function()
					if v:FindFirstChild("Handle") and v.Handle:FindFirstChild("NameEsp" .. Number) then
						v.Handle:FindFirstChild("NameEsp" .. Number):Destroy()
					end
				end)
			end
		else
			task.spawn(function()
				while DevilFruitESP do
					DevEsp()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspIslandToggle", {
	Title = "Esp Island",
	Default = false,
	Callback = function(Value)
		IslandESP = Value
		if not Value then
			for _, v in next, workspace["_WorldOrigin"].Locations:GetChildren() do
				pcall(function()
					if v:FindFirstChild("NameEsp") then
						v:FindFirstChild("NameEsp"):Destroy()
					end
				end)
			end
		else
			task.spawn(function()
				while IslandESP do
					LocationEsp()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspFlowerToggle", {
	Title = "Esp Flower",
	Default = false,
	Callback = function(Value)
		FlowerESP = Value
		if not Value then
			for i, v in pairs(workspace:GetChildren()) do
				pcall(function()
					if (v.Name == "Flower2" or v.Name == "Flower1") and v:FindFirstChild("NameEsp" .. Number) then
						v:FindFirstChild("NameEsp" .. Number):Destroy()
					end
				end)
			end
		else
			task.spawn(function()
				while FlowerESP do
					flowerEsp()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspLegendarySwordToggle", {
	Title = "Esp Legendary Sword",
	Default = false,
	Callback = function(Value)
		LegenS = Value
		if not Value then
			if workspace:FindFirstChild("Lgd") then
				workspace:FindFirstChild("Lgd"):Destroy()
			end
		else
			task.spawn(function()
				while LegenS do
					LegenSword()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspHakiColorToggle", {
	Title = "Esp Haki Color",
	Default = false,
	Callback = function(Value)
		ColorEsp = Value
		if not Value then
			if workspace:FindFirstChild("Gay") then
				workspace:FindFirstChild("Gay"):Destroy()
			end
		else
			task.spawn(function()
				while ColorEsp do
					HakiClorEsp()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspGearToggle", {
	Title = "Esp Gear",
	Default = false,
	Callback = function(Value)
		ESPGear = Value
		if not Value then
			for _, v in pairs(workspace.Map.MysticIsland:GetDescendants()) do
				pcall(function()
					if v:FindFirstChild("NameEsp") then
						v:FindFirstChild("NameEsp"):Destroy()
					end
				end)
			end
		else
			task.spawn(function()
				while ESPGear do
					gearEsp()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspSeaEventIslandToggle", {
	Title = "Esp SeaEvent Island",
	Default = false,
	Callback = function(Value)
		EspEventIsland = Value
		if not Value then
			for i, v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
				pcall(function()
					if v:FindFirstChild("NameEsp") then
						v:FindFirstChild("NameEsp"):Destroy()
					end
				end)
			end
		else
			task.spawn(function()
				while EspEventIsland do
					EventIslandEsp()
					task.wait()
				end
			end)
		end
	end,
})

Tabs.Esp:AddToggle("EspAdvancedDealerToggle", {
	Title = "Esp Advanced Dealer",
	Default = false,
	Callback = function(Value)
		advanEsp = Value
		if not Value then
			if workspace:FindFirstChild("Adv") then
				workspace:FindFirstChild("Adv"):Destroy()
			end
		else
			task.spawn(function()
				while advanEsp do
					AdvanFruitEsp()
					task.wait()
				end
			end)
		end
	end,
})

P(Tabs.Info, "Information", "Server / island / boss status")
TimeZone = P(Tabs.Info, "Time Zone", "")

function UpdateOS()
	local date = os.date("*t")
	local hour = date.hour % 24
	local ampm = hour < 12 and "AM" or "PM"
	local timezone = string.format("%02i:%02i:%02i %s", ((hour - 1) % 12) + 1, date.min, date.sec, ampm)
	local datetime = string.format("%02d/%02d/%04d", date.day, date.month, date.year)

	local LocalizationService = game:GetService("LocalizationService")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local result, code

	if not getgenv().countryRegionCode then
		result, code = pcall(function()
			return LocalizationService:GetCountryRegionForPlayerAsync(player)
		end)
		if result then
			getgenv().countryRegionCode = code
		else
			getgenv().countryRegionCode = "Unknown"
		end
	else
		code = getgenv().countryRegionCode
	end

	TimeZone:SetDesc(datetime .. " - " .. timezone .. " [ " .. code .. " ]")
end

spawn(function()
	while true do
		UpdateOS()
		wait(1)
	end
end)

GameTime = P(Tabs.Info, "Game Time", "")

function UpdateGameTime()
	local GameTimeValue = math.floor(workspace.DistributedGameTime + 0.5)
	local Hour = math.floor(GameTimeValue / (60 ^ 2)) % 24
	local Minute = math.floor(GameTimeValue / (60 ^ 1)) % 60
	local Second = math.floor(GameTimeValue / (60 ^ 0)) % 60
	GameTime:SetDesc(Hour .. " Hour (h) " .. Minute .. " Minute (m) " .. Second .. " Second (s)")
end

spawn(function()
	while true do
		UpdateGameTime()
		wait(1)
	end
end)

AwakenBossCheck = P(Tabs.Info, "Awaken Boss", "Status: Checking...")

G.previousAwakenBossState = ""
task.spawn(function()
	while task.wait(5) do
		pcall(function()
			local Event = game:GetService("ReplicatedStorage").Modules.Net["RF/RequestNextRaidHint"]
			local result = Event:InvokeServer()

			local bossName = "Unknown"
			local islandName = "Unknown"
			local seconds = 0
			local state = "Unknown"

			if type(result) == "table" then
				bossName = tostring(result.Boss or result.boss or "Unknown")
				islandName = tostring(result.Island or result.island or "Unknown")
				seconds = tostring(result.Seconds or result.seconds or 0)
				state = tostring(result.State or result.state or "Unknown")
			elseif type(result) == "string" then
				local ok, decoded = pcall(function()
					return game:GetService("HttpService"):JSONDecode(result)
				end)
				if ok and type(decoded) == "table" then
					bossName = tostring(decoded.Boss or decoded.boss or "Unknown")
					islandName = tostring(decoded.Island or decoded.island or "Unknown")
					seconds = tostring(decoded.Seconds or decoded.seconds or 0)
					state = tostring(decoded.State or decoded.state or "Unknown")
				end
			end

			local display = bossName .. " | " .. islandName
			if display ~= G.previousAwakenBossState then
				AwakenBossCheck:SetDesc("Boss: " .. bossName .. "\nIsland: " .. islandName)
				G.previousAwakenBossState = display
			end
		end)
	end
end)

MirageCheck = P(Tabs.Info, "Mirage Island", "Status: Not Found")

G.previousMirageStatus = ""
spawn(function()
	pcall(function()
		while true do
			task.wait(1)
			local mirageIslandExists = game.Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") ~= nil
			local currentStatus = mirageIslandExists and "Spawned" or "Not Found"
			if currentStatus ~= G.previousMirageStatus then
				MirageCheck:SetDesc("Status: " .. currentStatus)
				G.previousMirageStatus = currentStatus
			end
		end
	end)
end)

KitsuneCheck = P(Tabs.Info, "Kitsune Island", "Status: Not Found")

G.previousKitsuneStatus = ""
spawn(function()
	while task.wait(1) do
		local currentStatus = game:GetService("Workspace").Map:FindFirstChild("KitsuneIsland") and "Spawned"
			or "Not Found"
		if currentStatus ~= G.previousKitsuneStatus then
			KitsuneCheck:SetDesc("Status: " .. currentStatus)
			G.previousKitsuneStatus = currentStatus
		end
	end
end)

PrehistoricCheck = P(Tabs.Info, "Prehistoric Island", "Status: Not Found")

G.previousPrehistoricStatus = ""
task.spawn(function()
	while task.wait(1) do
		local currentStatus = game.Workspace._WorldOrigin.Locations:FindFirstChild("Prehistoric Island") and "Spawned"
			or "Not Found"
		if currentStatus ~= G.previousPrehistoricStatus then
			PrehistoricCheck:SetDesc("Status: " .. currentStatus)
			G.previousPrehistoricStatus = currentStatus
		end
	end
end)

FrozenCheck = P(Tabs.Info, "Frozen Dimension", "Status: Not Found")

G.previousFrozenStatus = ""
spawn(function()
	while task.wait(1) do
		local currentStatus = game.Workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension") and "Spawned"
			or "Not Found"
		if currentStatus ~= G.previousFrozenStatus then
			FrozenCheck:SetDesc("Status: " .. currentStatus)
			G.previousFrozenStatus = currentStatus
		end
	end
end)

CakePrinceStatus = P(Tabs.Info, "Cake Prince", "Status: Checking")

spawn(function()
	while task.wait(1) do
		local cakePrince = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")
		local killStatus = "Status: Not Spawned"
		if type(cakePrince) == "string" and string.len(cakePrince) >= 86 then
			local killCount = string.sub(cakePrince, 39, 41)
			killStatus = "Killed: " .. killCount
		end
		CakePrinceStatus:SetDesc(killStatus)
	end
end)

RipIndraCheck = P(Tabs.Info, "Rip Indra", "Status: Not Spawned")

G.previousRipStatus = ""
spawn(function()
	while task.wait(1) do
		local currentStatus = (
			game:GetService("ReplicatedStorage"):FindFirstChild("rip_indra True Form")
			or game:GetService("Workspace").Enemies:FindFirstChild("rip_indra")
		)
				and "Spawned"
			or "Not Spawned"
		if currentStatus ~= G.previousRipStatus then
			RipIndraCheck:SetDesc("Status: " .. currentStatus)
			G.previousRipStatus = currentStatus
		end
	end
end)

DoughKingCheck = P(Tabs.Info, "Dough King", "Status: Not Spawned")

G.previousDoughStatus = ""
spawn(function()
	while task.wait(1) do
		local currentStatus = (
			game:GetService("ReplicatedStorage"):FindFirstChild("Dough King")
			or game:GetService("Workspace").Enemies:FindFirstChild("Dough King")
		)
				and "Spawned"
			or "Not Spawned"
		if currentStatus ~= G.previousDoughStatus then
			DoughKingCheck:SetDesc("Status: " .. currentStatus)
			G.previousDoughStatus = currentStatus
		end
	end
end)

FullMoonCheck = P(Tabs.Info, "Full Moon", "")

task.spawn(function()
	while task.wait(1) do
		local moonTextureId = game:GetService("Lighting").Sky.MoonTextureId
		local moonStatus = "Moon: 0/5"

		if moonTextureId == "http://www.roblox.com/asset/?id=9709149431" then
			moonStatus = "Moon: 5/5 (Full Moon)"
		elseif moonTextureId == "http://www.roblox.com/asset/?id=9709149052" then
			moonStatus = "Moon: 4/5"
		elseif moonTextureId == "http://www.roblox.com/asset/?id=9709148705" then
			moonStatus = "Moon: 3/5"
		elseif moonTextureId == "http://www.roblox.com/asset/?id=9709148386" then
			moonStatus = "Moon: 2/5"
		elseif moonTextureId == "http://www.roblox.com/asset/?id=9709147983" then
			moonStatus = "Moon: 1/5"
		end

		FullMoonCheck:SetDesc(moonStatus)
	end
end)
LegendarySwordCheck = P(Tabs.Info, "Legendary Sword", "Status: ")

spawn(function()
	while wait(1) do
		local swordStatus = "Not Found"

		if game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1") then
			swordStatus = "Shisui ??"
		elseif game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LegendarySwordDealer", "2") then
			swordStatus = "Wando ??"
		elseif game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LegendarySwordDealer", "3") then
			swordStatus = "Saddi ??"
		end

		LegendarySwordCheck:SetDesc(swordStatus)
	end
end)

BoneCount = P(Tabs.Info, "Bone", "")

spawn(function()
	while wait(1) do
		local bones = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Bones", "Check")
		BoneCount:SetDesc("You Have: " .. tostring(bones) .. " Bones")
	end
end)

local Stats = game:GetService("Stats")

FpsData = {
	GUI = nil,
	Connection = nil,
	AnimatedConnections = {},
	ShineCheckConnection = nil,
	Enabled = true,
}

G.FpsStartTime = tick()

function G.MakeDraggableFps(TopbarObject, Object, Locked, Fluent)
	local Dragging, DragInput, DragStart, StartPosition = false, nil, nil, nil
	local Holding, HoldTime, MoveCancelThreshold, HoldToken = false, 1.0, 6, 0
	Object:SetAttribute("Locked", Locked or false)

	local function Update(Input)
		if Object:GetAttribute("Locked") then
			return
		end
		local Delta = Input.Position - DragStart
		Object.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end

	local function ToggleLock()
		local NewState = not Object:GetAttribute("Locked")
		Object:SetAttribute("Locked", NewState)
		if Fluent and Fluent.Notify then
			Fluent:Notify({
				Title = NewState and "Button Locked" or "Button Unlocked",
				Content = NewState and "Locked in place." or "Can now be moved.",
				Duration = 2,
			})
		end
	end

	TopbarObject.InputBegan:Connect(function(Input)
		if
			Input.UserInputType ~= Enum.UserInputType.MouseButton1
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		Dragging = not Object:GetAttribute("Locked")
		Holding = true
		DragStart = Input.Position
		StartPosition = Object.Position
		HoldToken += 1
		local Token = HoldToken
		task.delay(HoldTime, function()
			if Holding and Token == HoldToken then
				ToggleLock()
			end
		end)
		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
				Holding = false
			end
		end)
	end)

	TopbarObject.InputChanged:Connect(function(Input)
		if not DragStart then
			return
		end
		if
			Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			if (Input.Position - DragStart).Magnitude > MoveCancelThreshold then
				Holding = false
			end
			DragInput = Input
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			Update(Input)
		end
	end)
end

function G.SetupFpsAnimations(
	Frame,
	Gradient,
	GradientStroke,
	UIStroke,
	BackgroundGradient,
	DividerFrames,
	DividerGradients,
	LabelGradients,
	Fluent
)
	for _, conn in ipairs(FpsData.AnimatedConnections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	FpsData.AnimatedConnections = {}

	if FpsData.ShineCheckConnection then
		pcall(function()
			FpsData.ShineCheckConnection:Disconnect()
		end)
		FpsData.ShineCheckConnection = nil
	end

	local t = 0
	local lastShineState = Fluent and Fluent.ShineEnabled == true

	local conn = RunService.RenderStepped:Connect(function(dt)
		if not Frame or not Frame.Parent then
			for _, c in ipairs(FpsData.AnimatedConnections) do
				pcall(function()
					c:Disconnect()
				end)
			end
			FpsData.AnimatedConnections = {}
			return
		end

		local Animated = Fluent and Fluent.ShineEnabled == true

		if Animated ~= lastShineState then
			lastShineState = Animated
			t = 0
		end

		local Grad = Fluent and (Fluent:GetButtonGradient() or Fluent.ButtonGradients) or Fluent.ButtonGradients

		Gradient.Color = Grad.Background
		GradientStroke.Color = Grad.Stroke

		if BackgroundGradient then
			BackgroundGradient.Color = Grad.Background
		end

		for _, divGrad in ipairs(DividerGradients) do
			if divGrad and divGrad.Parent then
				divGrad.Color = Grad.Stroke
			end
		end

		for _, labelGrad in ipairs(LabelGradients) do
			if labelGrad and labelGrad.Parent then
				labelGrad.Color = Grad.Stroke
			end
		end

		if Animated then
			t = t + dt

			Gradient.Rotation = (t * 30) % 360
			GradientStroke.Rotation = (t * 15) % 360

			if BackgroundGradient then
				BackgroundGradient.Rotation = (t * -20) % 360
				BackgroundGradient.Offset = Vector2.new(math.sin(t * 0.3) * 0.1, math.cos(t * 0.25) * 0.1)
			end

			local Pulse = (math.sin(t * 0.5 * math.pi) + 1) / 2
			local MainThickness = 1.25 + Pulse * 1.25
			UIStroke.Thickness = MainThickness
			Frame.BackgroundTransparency = 0.27 + (math.sin(t * 0.4) * 0.05)

			for _, divGrad in ipairs(DividerGradients) do
				if divGrad and divGrad.Parent then
					divGrad.Rotation = GradientStroke.Rotation
				end
			end

			for _, divider in ipairs(DividerFrames) do
				if divider and divider.Parent then
					divider.BackgroundTransparency = 0.1 + (1 - Pulse) * 0.4
				end
			end

			for i, labelGrad in ipairs(LabelGradients) do
				if labelGrad and labelGrad.Parent then
					labelGrad.Rotation = (t * 25 + i * 45) % 360
				end
			end
		else
			Gradient.Rotation = 0
			GradientStroke.Rotation = 0

			if BackgroundGradient then
				BackgroundGradient.Rotation = 0
				BackgroundGradient.Offset = Vector2.new(0, 0)
			end

			UIStroke.Thickness = 2
			Frame.BackgroundTransparency = 0.27

			for _, divGrad in ipairs(DividerGradients) do
				if divGrad and divGrad.Parent then
					divGrad.Rotation = 0
				end
			end

			for _, divider in ipairs(DividerFrames) do
				if divider and divider.Parent then
					divider.BackgroundTransparency = 0
				end
			end

			for _, labelGrad in ipairs(LabelGradients) do
				if labelGrad and labelGrad.Parent then
					labelGrad.Rotation = 0
				end
			end
		end
	end)

	table.insert(FpsData.AnimatedConnections, conn)

	if Fluent then
		FpsData.ShineCheckConnection = RunService.Heartbeat:Connect(function()
			if Fluent then
				local currentShine = Fluent.ShineEnabled == true
				if currentShine ~= lastShineState then
					lastShineState = currentShine
					t = 0
				end
			end
		end)
	end
end

function G.CreateFpsCounter()
	if FpsData.GUI then
		FpsData.GUI:Destroy()
		FpsData.GUI = nil
	end
	for _, conn in ipairs(FpsData.AnimatedConnections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	FpsData.AnimatedConnections = {}
	if FpsData.ShineCheckConnection then
		pcall(function()
			FpsData.ShineCheckConnection:Disconnect()
		end)
		FpsData.ShineCheckConnection = nil
	end
	if FpsData.Connection then
		FpsData.Connection:Disconnect()
		FpsData.Connection = nil
	end

	local FpsCounter = Instance.new("ScreenGui")
	FpsCounter.Name = "FPSCounter"
	FpsCounter.Parent = game.CoreGui
	FpsCounter.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	FpsCounter.ResetOnSpawn = false
	FpsCounter.DisplayOrder = 0

	FpsData.GUI = FpsCounter

	local Grad = Fluent:GetButtonGradient() or Fluent.ButtonGradients
	local StrokeColor3 = Grad.Stroke.Keypoints[1].Value

	local Frame = Instance.new("Frame")
	Frame.Parent = FpsCounter
	Frame.Size = UDim2.new(0, 420, 0, 45)
	Frame.Position = UDim2.new(0, 300, 0, 10)
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Frame.BackgroundTransparency = 0.85
	Frame.ZIndex = -10
	Frame.ClipsDescendants = true

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 12)
	Corner.Parent = Frame

	local BackgroundGradient = Instance.new("UIGradient")
	BackgroundGradient.Color = Grad.Background
	BackgroundGradient.Rotation = 0
	BackgroundGradient.Parent = Frame

	local Gradient = Instance.new("UIGradient")
	Gradient.Color = Grad.Background
	Gradient.Rotation = 0
	Gradient.Parent = Frame

	local GlassLayer = Instance.new("Frame")
	GlassLayer.Name = "_FBGlass"
	GlassLayer.Size = UDim2.fromScale(1, 1)
	GlassLayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	GlassLayer.BackgroundTransparency = 0.88
	GlassLayer.BorderSizePixel = 0
	GlassLayer.ZIndex = -9
	GlassLayer.Parent = Frame
	local GlassCorner = Instance.new("UICorner")
	GlassCorner.CornerRadius = UDim.new(0, 12)
	GlassCorner.Parent = GlassLayer
	local GlassGradient = Instance.new("UIGradient")
	GlassGradient.Rotation = 90
	GlassGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180)),
	})
	GlassGradient.Parent = GlassLayer

	local Noise = Instance.new("ImageLabel")
	Noise.Name = "_FBNoise"
	Noise.Image = "rbxassetid://9968344227"
	Noise.ScaleType = Enum.ScaleType.Tile
	Noise.TileSize = UDim2.new(0, 128, 0, 128)
	Noise.Size = UDim2.fromScale(1, 1)
	Noise.BackgroundTransparency = 1
	Noise.ImageTransparency = 0.92
	Noise.ZIndex = -8
	Noise.Parent = Frame
	local NoiseCorner = Instance.new("UICorner")
	NoiseCorner.CornerRadius = UDim.new(0, 12)
	NoiseCorner.Parent = Noise

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Thickness = 2
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Color = Color3.new(1, 1, 1)
	UIStroke.Parent = Frame

	local GradientStroke = Instance.new("UIGradient")
	GradientStroke.Color = Grad.Stroke
	GradientStroke.Rotation = 0
	GradientStroke.Parent = UIStroke

	local LabelGradients = {}

	local FPSLabel = Instance.new("TextLabel")
	FPSLabel.Parent = Frame
	FPSLabel.Size = UDim2.new(0, 90, 1, -10)
	FPSLabel.Position = UDim2.new(0, 6, 0, 5)
	FPSLabel.BackgroundTransparency = 1
	FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	FPSLabel.Font = Enum.Font.GothamBlack
	FPSLabel.TextSize = 13
	FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
	FPSLabel.TextYAlignment = Enum.TextYAlignment.Center
	FPSLabel.Text = "FPS: 0"
	FPSLabel.ZIndex = -7
	FPSLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	FPSLabel.TextStrokeTransparency = 0.3
	local FPSLabelGrad = Instance.new("UIGradient")
	FPSLabelGrad.Color = Grad.Stroke
	FPSLabelGrad.Rotation = 0
	FPSLabelGrad.Parent = FPSLabel
	table.insert(LabelGradients, FPSLabelGrad)

	local PingLabel = Instance.new("TextLabel")
	PingLabel.Parent = Frame
	PingLabel.Size = UDim2.new(0, 90, 1, -10)
	PingLabel.Position = UDim2.new(0, 108, 0, 5)
	PingLabel.BackgroundTransparency = 1
	PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	PingLabel.Font = Enum.Font.GothamBlack
	PingLabel.TextSize = 13
	PingLabel.TextXAlignment = Enum.TextXAlignment.Center
	PingLabel.TextYAlignment = Enum.TextYAlignment.Center
	PingLabel.Text = "Ping: 0 ms"
	PingLabel.ZIndex = -7
	PingLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	PingLabel.TextStrokeTransparency = 0.3
	local PingLabelGrad = Instance.new("UIGradient")
	PingLabelGrad.Color = Grad.Stroke
	PingLabelGrad.Rotation = 0
	PingLabelGrad.Parent = PingLabel
	table.insert(LabelGradients, PingLabelGrad)

	local PlaytimeLabel = Instance.new("TextLabel")
	PlaytimeLabel.Parent = Frame
	PlaytimeLabel.Size = UDim2.new(0, 100, 1, -10)
	PlaytimeLabel.Position = UDim2.new(0, 214, 0, 5)
	PlaytimeLabel.BackgroundTransparency = 1
	PlaytimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	PlaytimeLabel.Font = Enum.Font.GothamBlack
	PlaytimeLabel.TextSize = 13
	PlaytimeLabel.TextXAlignment = Enum.TextXAlignment.Center
	PlaytimeLabel.TextYAlignment = Enum.TextYAlignment.Center
	PlaytimeLabel.Text = "0h 0m 0s"
	PlaytimeLabel.ZIndex = -7
	PlaytimeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	PlaytimeLabel.TextStrokeTransparency = 0.3
	local PlaytimeLabelGrad = Instance.new("UIGradient")
	PlaytimeLabelGrad.Color = Grad.Stroke
	PlaytimeLabelGrad.Rotation = 0
	PlaytimeLabelGrad.Parent = PlaytimeLabel
	table.insert(LabelGradients, PlaytimeLabelGrad)

	local ClockLabel = Instance.new("TextLabel")
	ClockLabel.Parent = Frame
	ClockLabel.Size = UDim2.new(0, 95, 1, -10)
	ClockLabel.Position = UDim2.new(0, 318, 0, 5)
	ClockLabel.BackgroundTransparency = 1
	ClockLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ClockLabel.Font = Enum.Font.GothamBlack
	ClockLabel.TextSize = 13
	ClockLabel.TextXAlignment = Enum.TextXAlignment.Center
	ClockLabel.TextYAlignment = Enum.TextYAlignment.Center
	ClockLabel.Text = os.date("%H:%M:%S")
	ClockLabel.ZIndex = -7
	ClockLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	ClockLabel.TextStrokeTransparency = 0.3
	local ClockLabelGrad = Instance.new("UIGradient")
	ClockLabelGrad.Color = Grad.Stroke
	ClockLabelGrad.Rotation = 0
	ClockLabelGrad.Parent = ClockLabel
	table.insert(LabelGradients, ClockLabelGrad)

	local DividerFrames = {}
	local DividerGradients = {}

	local Divider1 = Instance.new("Frame")
	Divider1.Parent = Frame
	Divider1.Size = UDim2.new(0, 1, 0.6, 0)
	Divider1.Position = UDim2.new(0, 97, 0.2, 0)
	Divider1.BackgroundColor3 = StrokeColor3
	Divider1.BackgroundTransparency = 0
	Divider1.BorderSizePixel = 0
	Divider1.ZIndex = -7

	local DividerGradient1 = Instance.new("UIGradient")
	DividerGradient1.Color = Grad.Stroke
	DividerGradient1.Rotation = 0
	DividerGradient1.Parent = Divider1
	table.insert(DividerFrames, Divider1)
	table.insert(DividerGradients, DividerGradient1)

	local Divider2 = Instance.new("Frame")
	Divider2.Parent = Frame
	Divider2.Size = UDim2.new(0, 1, 0.6, 0)
	Divider2.Position = UDim2.new(0, 199, 0.2, 0)
	Divider2.BackgroundColor3 = StrokeColor3
	Divider2.BackgroundTransparency = 0
	Divider2.BorderSizePixel = 0
	Divider2.ZIndex = -7

	local DividerGradient2 = Instance.new("UIGradient")
	DividerGradient2.Color = Grad.Stroke
	DividerGradient2.Rotation = 0
	DividerGradient2.Parent = Divider2
	table.insert(DividerFrames, Divider2)
	table.insert(DividerGradients, DividerGradient2)

	local Divider3 = Instance.new("Frame")
	Divider3.Parent = Frame
	Divider3.Size = UDim2.new(0, 1, 0.6, 0)
	Divider3.Position = UDim2.new(0, 311, 0.2, 0)
	Divider3.BackgroundColor3 = StrokeColor3
	Divider3.BackgroundTransparency = 0
	Divider3.BorderSizePixel = 0
	Divider3.ZIndex = -7

	local DividerGradient3 = Instance.new("UIGradient")
	DividerGradient3.Color = Grad.Stroke
	DividerGradient3.Rotation = 0
	DividerGradient3.Parent = Divider3
	table.insert(DividerFrames, Divider3)
	table.insert(DividerGradients, DividerGradient3)

	G.SetupFpsAnimations(
		Frame,
		Gradient,
		GradientStroke,
		UIStroke,
		BackgroundGradient,
		DividerFrames,
		DividerGradients,
		LabelGradients,
		Fluent
	)

	local Glow = Instance.new("ImageLabel")
	Glow.Name = "_Glow"
	Glow.Size = UDim2.new(1.2, 0, 1.2, 0)
	Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Glow.AnchorPoint = Vector2.new(0.5, 0.5)
	Glow.BackgroundTransparency = 1
	Glow.Image = "rbxassetid://5028857081"
	Glow.ImageTransparency = 0.7
	Glow.ZIndex = -11
	Glow.Parent = Frame
	local GlowCorner = Instance.new("UICorner")
	GlowCorner.CornerRadius = UDim.new(0, 12)
	GlowCorner.Parent = Glow

	G.MakeDraggableFps(Frame, Frame, false, Fluent)

	local LastUpdateTime = tick()
	local FrameCount = 0

	FpsData.Connection = RunService.RenderStepped:Connect(function()
		FrameCount = FrameCount + 1
		local Now = tick()
		local Dt = Now - LastUpdateTime

		if Dt >= 1 then
			local Fps = math.round(FrameCount / Dt)
			local Elapsed = Now - G.FpsStartTime
			local H = math.floor(Elapsed / 3600)
			local M = math.floor((Elapsed % 3600) / 60)
			local S = math.floor(Elapsed % 60)

			local Ping = 0
			pcall(function()
				Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)

			FPSLabel.Text = string.format("FPS: %d", Fps)
			PingLabel.Text = string.format("Ping: %d ms", Ping)
			PlaytimeLabel.Text = string.format("%dh %dm %ds", H, M, S)
			ClockLabel.Text = os.date("%H:%M:%S")

			LastUpdateTime = Now
			FrameCount = 0
		end
	end)

	local function Cleanup()
		if FpsData.Connection then
			FpsData.Connection:Disconnect()
			FpsData.Connection = nil
		end
		for _, conn in ipairs(FpsData.AnimatedConnections) do
			pcall(function()
				conn:Disconnect()
			end)
		end
		FpsData.AnimatedConnections = {}
		if FpsData.ShineCheckConnection then
			pcall(function()
				FpsData.ShineCheckConnection:Disconnect()
			end)
			FpsData.ShineCheckConnection = nil
		end
		if FpsData.GUI then
			FpsData.GUI:Destroy()
			FpsData.GUI = nil
		end
	end

	return FpsCounter, Cleanup
end

function G.ToggleFpsCounter(State)
	FpsData.Enabled = State

	if State then
		if not FpsData.GUI then
			G.CreateFpsCounter()
		end
	else
		if FpsData.GUI then
			if FpsData.Connection then
				FpsData.Connection:Disconnect()
				FpsData.Connection = nil
			end
			for _, conn in ipairs(FpsData.AnimatedConnections) do
				pcall(function()
					conn:Disconnect()
				end)
			end
			FpsData.AnimatedConnections = {}
			if FpsData.ShineCheckConnection then
				pcall(function()
					FpsData.ShineCheckConnection:Disconnect()
				end)
				FpsData.ShineCheckConnection = nil
			end
			FpsData.GUI:Destroy()
			FpsData.GUI = nil
		end
	end
end

G.ToggleFpsCounter(true)

G.secSettingsFps = Tabs.Settings:AddSection("FPS Counter", "solar/gauge-bold")
G.secSettingsFps:AddToggle("FPSCounterToggle", {
	Title = "Show FPS / Time Counter",
	Description = "FPS, Ping, Playtime and clock overlay",
	Default = true,
	Callback = function(Value)
		G.ToggleFpsCounter(Value)
	end,
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "Background", "BackgroundTransparency" })
InterfaceManager:SetFolder("KKKKHubNew/Interface")
SaveManager:SetFolder("KKKKHubNew/Config")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
pcall(function()
	InterfaceManager:LoadSettings()
end)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

task.defer(function()
	task.wait(0.2)
	if not G.scriptFeatureActive() then
		G.forceCleanGyro()
	end
end)

task.spawn(function()
	task.wait(0.5)
	pcall(function()
		Fluent:SetTheme("KKKK Blue")
	end)
end)

Fluent:Notify({
	Title = "KKKK Hub New",
	Content = "Fluent Modded UI loaded successfully",
	SubContent = "Ready",
	Image = "solar/check-circle-bold",
	Duration = 5,
})
Window:SelectTab(1)
