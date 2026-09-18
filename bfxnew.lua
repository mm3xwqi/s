local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/mm3xwqi/s/refs/heads/main/FluentModed.lua"))()
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
	Name = "KKKK Cyber Neon",
	Accent = Color3.fromHex("#8a2be2"), 
	AcrylicMain = Color3.fromHex("#080811"), 
	AcrylicBorder = Color3.fromHex("#00e5ff"), 
	AcrylicGradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("#090814")),
		ColorSequenceKeypoint.new(0.5, Color3.fromHex("#120b29")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("#1a0e3b")),
	}),
	AcrylicNoise = 0.85,
	TitleBarLine = Color3.fromHex("#00e5ff"),
	Tab = Color3.fromHex("#0d0a1a"),
	Element = Color3.fromHex("#0e0b1c"),
	ElementBorder = Color3.fromHex("#1f1a3a"),
	InElementBorder = Color3.fromHex("#2b2252"),
	ElementTransparency = 0.85,
	ElementBorderThickness = 1,
	ToggleSlider = Color3.fromHex("#1c1133"),
	ToggleToggled = Color3.fromHex("#a855f7"),
	SliderRail = Color3.fromHex("#130c24"),
	CheckboxUnchecked = Color3.fromHex("#130c24"),
	CheckboxChecked = Color3.fromHex("#a855f7"),
	CheckboxCheck = Color3.fromHex("#ffffff"),
	ProgressBarRail = Color3.fromHex("#130c24"),
	ProgressBarFill = Color3.fromHex("#00e5ff"),
	DropdownFrame = Color3.fromHex("#0c0919"),
	DropdownHolder = Color3.fromHex("#110c24"),
	DropdownBorder = Color3.fromHex("#8a2be2"),
	DropdownOption = Color3.fromHex("#171033"),
	DropdownBorderThickness = 1,
	Keybind = Color3.fromHex("#150d2e"),
	Input = Color3.fromHex("#110c24"),
	InputFocused = Color3.fromHex("#1e133d"),
	InputIndicator = Color3.fromHex("#00e5ff"),
	Dialog = Color3.fromHex("#0b0817"),
	DialogHolder = Color3.fromHex("#100c24"),
	DialogHolderLine = Color3.fromHex("#8a2be2"),
	DialogButton = Color3.fromHex("#221342"),
	DialogButtonBorder = Color3.fromHex("#8a2be2"),
	DialogBorder = Color3.fromHex("#00e5ff"),
	DialogInput = Color3.fromHex("#100c24"),
	DialogInputLine = Color3.fromHex("#00e5ff"),
	Text = Color3.fromHex("#f3f4f6"),
	SubText = Color3.fromHex("#9ca3af"),
	Hover = Color3.fromHex("#1f1442"),
	HoverChange = 0.08,
	Background = "https://raw.githubusercontent.com/StyearX/Assets/main/backgrounds.png",
	BackgroundTransparency = 0,
	ShineEnabled = true,
	Shine = {
		Speed = 2.5,
		RotationSpeed = 1.2,
		ColorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#000000")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8a2be2")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#00e5ff")),
		}),
	},
	StrokeShine = true,
	StrokeDark = Color3.fromHex("#0c0817"),
	ButtonGradient = {
		Background = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#261247")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#110a24")),
		}),
		Stroke = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#00e5ff")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("#8a2be2")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#00e5ff")),
		}),
	},
	DiscordJoinButton = Color3.fromHex("#5865f2"),
	WarningNotifyColor = Color3.fromHex("#f59e0b"),
	SuccessNotifyColor = Color3.fromHex("#10b981"),
	ErrorNotifyColor = Color3.fromHex("#ef4444"),
	InfoNotifyColor = Color3.fromHex("#8a2be2"),
})

local Window = Fluent:CreateWindow({
	Title = "KKKK x Hub",
	SubTitle = "By Z.",
	TabWidth = G.isMobile and 132 or 158,
	Size = G.isMobile and UDim2.fromOffset(610, 540) or UDim2.fromOffset(700, 610),
	Acrylic = true,
	Theme = "KKKK Cyber Neon",
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
    AutoSkill = Window:AddTab({ Title = "Skill Settings", Icon = "solar/magic-stick-3-bold" }),
    FarmSetting = Window:AddTab({ Title = "Farm Setting", Icon = "solar/settings-bold" }),
	Main = Window:AddTab({ Title = "Main", Icon = "lucide/swords" }),
	Dungeon = Window:AddTab({ Title = "Dungeon", Icon = "lucide/door-open" }),
    Stat = Window:AddTab({ Title = "Stat", Icon = "solar/chart-2-bold" }),
	Esp = Window:AddTab({ Title = "Visual", Icon = "solar/eye-bold" }),
    Pvp = Window:AddTab({ Title = "PVP", Icon = "solar/target-bold" }),
	Island = Window:AddTab({ Title = "Tarvel", Icon = "solar/map-point-bold" }),
	Settings = Window:AddTabsInHeader({ Title = " Configuration", Icon = "solar/settings-bold" }),
}

local Tabs = {
	Info = RawTabs.Info:AddSection("Live Status", "solar/pulse-2-bold"),
	InfoServer = RawTabs.Info:AddSection("Server & Time", "solar/global-bold"),
	InfoIsland = RawTabs.Info:AddSection("Island Spawn Check", "solar/map-point-wave-bold"),
	InfoBoss = RawTabs.Info:AddSection("Boss & Raid Check", "lucide/skull"),
	InfoTyrant = RawTabs.Info:AddSection("Tyrant Sky - Eye Check", "solar/eye-bold"),
	InfoItem = RawTabs.Info:AddSection("Items & Dealer", "solar/box-bold"),
	LocalPlayer = RawTabs.LocalPlayer:AddSection("Player Utilities", "solar/user-id-bold"),
	Stat = RawTabs.Stat:AddSection("Stat Allocation", "solar/chart-square-bold"),
	Main = RawTabs.Main:AddSection("Farming", "lucide/swords"),
	TyrantSection = RawTabs.Main:AddSection("Tyrant Sky Boss", "lucide/feather"),
    KatakuriSection = RawTabs.Main:AddSection("Katakuri Boss", "lucide/cake"),
	MagnetSection = RawTabs.Main:AddSection("Event Magnet", "lucide/magnet"),
	AutoSkillSection = RawTabs.AutoSkill:AddSection("Skill Config", "solar/magic-stick-3-bold"),
	AutoSkillTiming = RawTabs.AutoSkill:AddSection("Skill Timing", "solar/clock-circle-bold"),
	Island = RawTabs.Island:AddSection("Island Travel", "solar/map-arrow-square-bold"),
    NpcSection = RawTabs.Island:AddSection("NPC Travel", "solar/user-speak-bold"),
	FarmSetting = RawTabs.FarmSetting:AddSection("Farm Tuning", "solar/tuning-2-bold"),
	Esp = RawTabs.Esp:AddSection("Visual ESP", "solar/eye-scan-bold"),
    Pvp = RawTabs.Pvp:AddSection("PVP Tools", "solar/target-bold"),
    PvpSpectate = RawTabs.Pvp:AddSection("Spectate", "solar/eye-bold"),
	Dungeon = RawTabs.Dungeon:AddSection("Auto Dungeon", "lucide/door-open"),
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
	clearingMobs = false,
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
	BRING_INTERVAL = 0.05,
	SPAWN_TELEPORT_INTERVAL = 0.3,
	isMovingToSpawn = false,
	spawnPointList = {},
	spawnPointIndex = 1,
	spawnPointChecked = {},
	lastSpawnPointKey = nil,
	spawnCyclePauseUntil = 0,
	spawnDwellUntil = 0,
	SPAWN_DWELL = 0.05,
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
	State.activeTweenEta = nil
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
        :gsub("%s*%[Lv%s*%d+%]", "")
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
    ["Saber Expert"] = true,
    ["The Gorilla King"] = true,
    ["Chef"] = true,
    ["Cyborg"] = true,
    ["Fishman Lord"] = true,
    ["Ice Admiral"] = true,
    ["Thunder God"] = true,
    ["Magma Admiral"] = true,
    ["Mob Leader"] = true,
    ["Wysper"] = true,
    ["Vice Admiral"] = true,
    ["Warden"] = true,
    ["Yeti"] = true,
    ["The Saw"] = true,
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
    if not State.selectedIslandPos then return end
    State.teleportTweenEnabled = true

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then State.currentFlyCF = hrp.CFrame end

    State.islandRoute      = G.buildIslandRoute(State.selectedIslandName, State.selectedIslandPos, hrp and hrp.Position)
    State.islandRouteIndex = 1

    G.Conns.tweenIsland = RunService.Heartbeat:Connect(function(dt)
        if not State.teleportTweenEnabled then
            G.stopTweenIsland()
            return
        end

        local c   = player.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        if State.waitingForWarpPos then
            local movedDist = (hrp.Position - State.waitingForWarpPos).Magnitude
            local timedOut  = (tick() - State.warpWaitStart) > State.WARP_WAIT_TIMEOUT
            if movedDist > State.WARP_TRIGGER_DIST or timedOut then
                State.waitingForWarpPos    = nil
                State.currentFlyCF         = hrp.CFrame
                State.islandRouteIndex     = (State.islandRouteIndex or 1) + 1
                G.stopMomentum()
            else
                pcall(function()
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end
        end

        local route = State.islandRoute
        if not route or #route == 0 then
            route = G.buildIslandRoute(State.selectedIslandName, State.selectedIslandPos, hrp.Position)
            State.islandRoute      = route
            State.islandRouteIndex = 1
        end

        if State.islandRouteIndex > #route then
            local finalCF = CFrame.new(State.selectedIslandPos)
            pcall(function()
                hrp.CFrame                  = finalCF
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            return
        end

        local idx      = math.clamp(State.islandRouteIndex, 1, #route)
        local targetCF = route[idx]
        local isLast   = (idx >= #route)

        local currentPos = State.currentFlyCF and State.currentFlyCF.Position or hrp.Position
        local dist       = (targetCF.Position - currentPos).Magnitude

        if dist > 6 then
            G.moveToTarget(hrp, targetCF, dt)
            return
        end

        State.currentFlyCF = targetCF
        pcall(function()
            hrp.CFrame                  = targetCF
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        if isLast then
            State.islandRouteIndex = State.islandRouteIndex + 1
            Fluent:Notify({
                Title   = "Island",
                Content = "Arrived at " .. (State.selectedIslandName or ""),
                Duration = 3,
            })
            return
        end

        State.waitingForWarpPos = targetCF.Position
        State.warpWaitStart     = tick()
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
	State.selectedMobIndex = (State.selectedMobIndex % #names) + 1
	return true
end

function G.rotateSelectedMob()
	local names = State.selectedMobNames
	if not names or #names == 0 then
		return false
	end
	local startIndex = State.selectedMobIndex
	G.advanceSelectedMobIndex()
	if State.selectedMobIndex == startIndex then
		return false
	end
	State.spawnDwellUntil = 0
	State.spawnCyclePauseUntil = 0
	State.currentTarget = nil
	G.resetSpawnScan(true)
	return true
end

function G.anySelectedMobHasSpawn()
	local names = State.selectedMobNames
	if not names or #names == 0 then
		return false
	end
	for _, name in ipairs(names) do
		if G.getSpawnCount(name) > 0 then
			return true
		end
	end
	return false
end

function G.isActiveSelectedSpawnFull()
	local activeName = G.getActiveSelectedMobName()
	if not activeName then
		return false
	end
	return G.isSpawnFull(activeName)
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

function FastAttackModule.IsMeleeOrSwordEquipped(char)
	local tool = char and char:FindFirstChildOfClass("Tool")
	if not tool then
		return false
	end
	local weaponType = tool:GetAttribute("Type")
	if weaponType == "Melee" or weaponType == "Sword" then
		return true
	end
	local tooltip = tool:FindFirstChild("ToolTip")
	if tooltip and tooltip:IsA("StringValue") then
		local value = tooltip.Value
		if value == "Melee" or value == "Sword" then
			return true
		end
	end
	return false
end

function FastAttackModule.ExecuteFastAttack()
	local char = player.Character
	if not char then
		return
	end
	if not FastAttackModule.IsMeleeOrSwordEquipped(char) then
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
	FastAttackModule.Enabled = false
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

                local dir = (targetPos - hrp.Position)
                local mag = dir.Magnitude
                local direction = mag > 0.01 and (dir / mag) or hrp.CFrame.LookVector

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
				pcall(FastAttackModule.ExecuteFastAttack)
				pcall(G.HitRegistrationModule.Execute)
				task.wait(FastAttackModule.Rate)
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
				if bp then bp:Destroy() end
			end
		end
		G.activeBringBodies[mob] = nil
	end
	for mob in pairs(G.bringSnapped) do
		G.bringSnapped[mob] = nil
	end
	for mob, state in pairs(G.originalMobStates) do
		G.restoreMobState(mob, state)
		local mobRoot = mob and mob.FindFirstChild and mob:FindFirstChild("HumanoidRootPart")
		if mobRoot then
			local anchor = mobRoot:FindFirstChild("AnchorBodyPos")
			if anchor then anchor:Destroy() end
		end
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
    local tyrantEnabled = G.tyrantActive == true
    local katakuriEnabled = G.katakuriActive == true
    local dungeonEnabled = G.AutoDungeon and G.AutoDungeon.enabled == true
    local farmActive = State.autoFarmEnabled or State.autoFarmSelectEnabled or tyrantEnabled or katakuriEnabled or dungeonEnabled
	
	if not State.bringMobEnabled or not farmActive then
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

		pcall(function()
			sethiddenproperty(targetRoot, "NetworkOwnershipRule", 0)
		end)
		for _, p in ipairs(target:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
				pcall(function()
					sethiddenproperty(p, "NetworkOwnershipRule", 0)
				end)
			end
		end

		local bp = targetRoot:FindFirstChild("AnchorBodyPos")
		if not bp then
			bp = Instance.new("BodyPosition")
			bp.Name = "AnchorBodyPos"
			bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bp.P = 100000
			bp.D = 5000
			bp.Position = targetRoot.Position
			bp.Parent = targetRoot
		end
		bp.Position = targetRoot.Position

		local bv = targetRoot:FindFirstChild("AnchorBodyVel")
		if not bv then
			bv = Instance.new("BodyVelocity")
			bv.Name = "AnchorBodyVel"
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.Velocity = Vector3.zero
			bv.Parent = targetRoot
		end
		bv.Velocity = Vector3.zero

		targetRoot.AssemblyLinearVelocity = Vector3.zero
		targetRoot.AssemblyAngularVelocity = Vector3.zero
		State.targetAnchorCFrame = nil
	end

	local pullPos = targetRoot.Position
	local bringCount = math.max(0, math.floor(tonumber(State.BRING_MOB_COUNT) or 0))

    local validMobs = {}
    for _, mob in ipairs(enemiesFolder:GetChildren()) do
        if mob == target then continue end
        
        if mob.Name == "PropHitboxPlaceholder" then continue end
        
        local mr = mob:FindFirstChild("HumanoidRootPart")
        local mh = mob:FindFirstChildOfClass("Humanoid")
        if not mr or not mh or mh.Health <= 0 then continue end

        local rawName = G.getMobDisplayName(mob)
        if rawName:find("%[Boss%]") or rawName:find("%[Raid Boss%]") then continue end
        local dungeonActive = G.AutoDungeon and G.AutoDungeon.enabled == true
        if not dungeonActive and not G.sameMobType(mob, target) then continue end

        local dist = (mr.Position - pullPos).Magnitude
        if dist > State.BRING_DISTANCE then continue end

        table.insert(validMobs, { mob = mob, mr = mr, mh = mh, dist = dist })
    end
    table.sort(validMobs, function(a, b)
        return a.dist < b.dist
    end)

	local seenMobs = {}
	local dungeonActive = G.AutoDungeon and G.AutoDungeon.enabled == true
    local slots = dungeonActive and #validMobs or math.min(bringCount, #validMobs)
	for i = 1, slots do
		local data = validMobs[i]
		local mob = data.mob
		local mr = data.mr
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

			local bp = mr:FindFirstChild("BringBodyPos")
			if not bp then
				bp = Instance.new("BodyPosition")
				bp.Name = "BringBodyPos"
				bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				bp.P = 30000
				bp.D = 900
				bp.Parent = mr
			end
			bp.Position = pullPos
			G.activeBringBodies[mob] = { bp = bp }
			G.bringSnapped[mob] = nil
		end)
	end

	for mob in pairs(G.activeBringBodies) do
		if not seenMobs[mob] then
			local mobRoot = mob:FindFirstChild("HumanoidRootPart")
			if mobRoot then
				local bp = mobRoot:FindFirstChild("BringBodyPos")
				if bp then bp:Destroy() end
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
				if bp then bp:Destroy() end
			end
		end
		G.activeBringBodies[mob] = nil
	end
	for mob in pairs(G.bringSnapped) do
		G.bringSnapped[mob] = nil
	end
	for mob, state in pairs(G.originalMobStates) do
		G.restoreMobState(mob, state)
		local mobRoot = mob and mob.FindFirstChild and mob:FindFirstChild("HumanoidRootPart")
		if mobRoot then
			local anchor = mobRoot:FindFirstChild("AnchorBodyPos")
			if anchor then anchor:Destroy() end
			local anchorVel = mobRoot:FindFirstChild("AnchorBodyVel")
			if anchorVel then anchorVel:Destroy() end
		end
		G.originalMobStates[mob] = nil
	end
	State.bringAnchor = nil
	State.lastBringUpdate = 0
	State.targetAnchorCFrame = nil
end

function G.tweenToSpawn(root, spawnPos)
    if not root or not spawnPos then return false end
    G.cancelTween()
    State.tweenTargetPosition = spawnPos
    State.lastTweenStartTime = tick()
    State.isMovingToSpawn = true
    State.spawnDestCF = CFrame.new(spawnPos + Vector3.new(0, 10, 0))
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
	State.spawnCyclePauseUntil = tick() + 0.2
	return false
end

G.FS = {
	scanList = {},
	scanIndex = 1,
	engaged = {},
	exhausted = {},
	dwellUntil = 0,
	pauseUntil = 0,
	activeName = nil,
}

function G.fsClearScan()
	local FS = G.FS
	FS.scanList = {}
	FS.scanIndex = 1
	FS.dwellUntil = 0
	State.isMovingToSpawn = false
	State.spawnDestCF = nil
	G.cancelTween()
end

function G.fsReset()
	local FS = G.FS
	FS.engaged = {}
	FS.exhausted = {}
	FS.pauseUntil = 0
	FS.activeName = nil
	State.selectedMobIndex = 1
	State.clearingMobs = false
	G.fsClearScan()
end

function G.fsNextIndex()
	local names = State.selectedMobNames
	local count = #names
	if count == 0 then
		return
	end
	local FS = G.FS
	G.fsClearScan()
	local allDone = true
	for i = 1, count do
		if not FS.exhausted[i] then
			allDone = false
		end
	end
	if allDone then
		FS.exhausted = {}
		FS.engaged = {}
		FS.activeName = nil
		State.selectedMobIndex = 1
		FS.pauseUntil = tick() + 0.2
		return
	end
	local idx = State.selectedMobIndex
	for _ = 1, count do
		idx = (idx % count) + 1
		if not FS.exhausted[idx] then
			break
		end
	end
	State.selectedMobIndex = idx
	FS.pauseUntil = tick() + 0.1
end

function G.fsHoldPosition(root)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	if not State.idleAnchorCFrame then
		State.idleAnchorCFrame = root.CFrame
	end
	local dist = (root.Position - State.idleAnchorCFrame.Position).Magnitude
	if dist > 150 then
		State.idleAnchorCFrame = root.CFrame
	elseif dist > 2 then
		root.CFrame = State.idleAnchorCFrame
	end
end

function G.fsSkipPoint()
	local FS = G.FS
	G.cancelTween()
	State.isMovingToSpawn = false
	State.spawnDestCF = nil
	FS.scanIndex = FS.scanIndex + 1
	FS.dwellUntil = 0
end

function G.spawnStuck(root)
	if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
		G.fsSkipPoint()
		return true
	end
	return G.advanceSpawnPoint(root)
end

function G.farmSelectStep(root, dt)
	local names = State.selectedMobNames
	local count = #names
	if count == 0 then
		return false
	end
	local FS = G.FS
	if State.selectedMobIndex < 1 or State.selectedMobIndex > count then
		State.selectedMobIndex = 1
	end

	if State.currentTarget and not G.isEnemyAlive(State.currentTarget) then
		State.currentTarget = nil
		State.isLocked = false
		State.lockStartTime = nil
		State.tweenTargetPosition = nil
		G.cancelTween()
		G.clearBringMobs()
	end

	local name = names[State.selectedMobIndex]
	if not name then
		State.selectedMobIndex = 1
		return false
	end
	if FS.activeName ~= name then
		FS.activeName = name
		G.fsClearScan()
	end

	if not State.currentTarget then
		local found = G.getClosestAliveEnemy(root.Position, name)
		if found then
			State.currentTarget = found
			State.lastTargetSwitchTime = tick()
		end
	end

	if State.currentTarget then
		FS.engaged[State.selectedMobIndex] = true
		State.clearingMobs = true
		G.fsClearScan()
		State.idleAnchorCFrame = nil
		return true
	end

	State.clearingMobs = false

	if FS.engaged[State.selectedMobIndex] then
		FS.engaged[State.selectedMobIndex] = nil
		FS.exhausted[State.selectedMobIndex] = true
		G.fsNextIndex()
		return false
	end

	if State.isMovingToSpawn and State.spawnDestCF then
		local dist = (State.spawnDestCF.Position - root.Position).Magnitude
		if dist > 5 then
			G.moveToTarget(root, State.spawnDestCF, dt)
			return false
		end
		root.CFrame = State.spawnDestCF
		G.stopMomentum()
		State.isMovingToSpawn = false
		State.spawnDestCF = nil
		FS.scanIndex = FS.scanIndex + 1
		FS.dwellUntil = tick() + State.SPAWN_DWELL
		return false
	end

	local now = tick()
	if now < FS.dwellUntil or now < FS.pauseUntil then
		G.fsHoldPosition(root)
		return false
	end

	if #FS.scanList == 0 then
		local ok, list = pcall(G.getSpawnPositionsForMob, name)
		if not ok or not list or #list == 0 then
			FS.exhausted[State.selectedMobIndex] = true
			G.fsNextIndex()
			return false
		end
		G.sortPositionsByDistance(list, root.Position)
		FS.scanList = list
		FS.scanIndex = 1
	end

	if FS.scanIndex > #FS.scanList then
		FS.exhausted[State.selectedMobIndex] = true
		G.fsNextIndex()
		return false
	end

	local point = FS.scanList[FS.scanIndex]
	if not point then
		FS.scanIndex = FS.scanIndex + 1
		return false
	end
	State.lastSpawnPointKey = G.positionKey(point)
	State.lastSpawnTeleportTime = now
	if G.tweenToSpawn(root, point) then
		State.idleAnchorCFrame = nil
	end
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
						4050.31104, -1.68800354, -1814.12402,
						-0.955315053, 0, -0.295594245,
						0, 1, 0,
						0.295594245, 0, -0.955315053
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
					G.spawnStuck(root)
					return
				end
				G.cancelTween()
			end
		end

		local tweenTimeLimit = State.TWEEN_TIMEOUT
		if State.isMovingToSpawn and State.activeTweenEta then
			tweenTimeLimit = math.max(State.TWEEN_TIMEOUT, State.activeTweenEta * 1.5 + 2)
		end
		if
			State.activeTween
			and State.activeTween.PlaybackState == Enum.PlaybackState.Playing
			and nowTick - State.lastTweenStartTime > tweenTimeLimit
		then
			State.currentTarget = nil
			State.activeTweenEta = nil
			if State.isMovingToSpawn then
				G.spawnStuck(root)
				return
			end
			G.cancelTween()
		end

		if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
			if not G.farmSelectStep(root, dt) then
				return
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
			if State.isMovingToSpawn and State.spawnDestCF then
				local distToSpawn = (State.spawnDestCF.Position - root.Position).Magnitude
				if distToSpawn > 5 then
					G.moveToTarget(root, State.spawnDestCF, dt)
					return
				else
					root.CFrame = State.spawnDestCF
					G.stopMomentum()
					State.isMovingToSpawn = false
					State.spawnDestCF = nil
					if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
						State.spawnDwellUntil = tick() + State.SPAWN_DWELL
					end
				end
			end

			if State.isMovingToSpawn then
				local earlyTarget = nil
				if not State.clearingMobs then
					if State.autoFarmSelectEnabled and #State.selectedMobNames > 0 then
						local activeName = G.getActiveSelectedMobName()
						if activeName then
							earlyTarget = G.getClosestAliveEnemy(root.Position, activeName)
						end
					elseif State.autoFarmEnabled then
						earlyTarget = G.getClosestAliveEnemyNears(root.Position)
					end
				end

			if earlyTarget then
					G.cancelTween()
					State.isMovingToSpawn = false
					State.spawnDestCF = nil
					State.currentTarget = earlyTarget
					State.lastTargetSwitchTime = tick()
					State.idleAnchorCFrame = nil
				else
					G.spawnStuck(root)
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
					if farmSelect and G.isActiveSelectedSpawnFull() then
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
								local activeName = G.getActiveSelectedMobName()
								if activeName then
									list = G.getSpawnPositionsForMob(activeName)
								end
								if #list == 0 then
									if G.anySelectedMobHasSpawn() then
										G.rotateSelectedMob()
									end
									return
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
			State.spawnDestCF = nil
		end

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
				G.moveToTarget(root, targetCFrame, dt)
				State.tweenTargetPosition = targetPosition
				State.lastTweenStartTime = tick()
			else
				G.stopMomentum()
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
		G.fsReset()
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
		G.fsReset()
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

Tabs.Main:AddButton({
	Title = "Reset Dropdown",
	Callback = function()
		State.selectedMobNames = { G.rawMobNames[1] }
		State.selectedMobIndex = 1
		State.currentTarget = nil
		State.lastSpawnTeleportTime = 0
		State.autoFarmSelectEnabled = false
		G.resetSpawnScan(true)
		G.fsReset()
		G.clearBringMobs()
		if not State.autoFarmEnabled then
			G.cleanup()
			G.stopNoclipLoop()
		end
		pcall(function()
			if MobSelectDropdown and MobSelectDropdown.SetValue then
				MobSelectDropdown:SetValue({ [G.mobLabelList[1]] = true })
			end
		end)
		Fluent:Notify({ Title = "Reset Dropdown", Content = "Default: " .. G.mobLabelList[1], Duration = 2 })
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

local TyrantSky = {
    enabled = false,
    phase = "idle",
    _lastPhaseChange = 0,
    PHASE_CHANGE_COOLDOWN = 3,

    targetMobNames = {
        "Isle Champion",
        "Serpent Hunter",
        "Skull Slayer",
        "Sun-kissed Warrior",
    },

    _currentWeaponIndex = 1,
    _lastWeaponSwitch = 0,
    WEAPON_SWITCH_INTERVAL = 1,

    currentTarget = nil,
    lastAttackTime = 0,
    ATTACK_RATE = 0.25,
    ATTACK_RANGE = 120,

    _spawnList = {},
    _spawnIndex = 1,
    _lastSpawnCheck = 0,
    SPAWN_CHECK_INTERVAL = 0.5,
    _spawnPatrolCF = nil,
    _spawnDwellUntil = 0,
    SPAWN_DWELL = 0.2,

    _bossGoneTick = nil,
    BOSS_GONE_CONFIRM = 1.0,
}



function TyrantSky.getAllTrees()
    local trees = {}
    local ok, arena = pcall(function()
        return workspace.Map.TikiOutpost.IslandModel.IslandChunks.D.EagleBossArena
    end)
    if not ok or not arena then return trees end
    for _, obj in ipairs(arena:GetChildren()) do
        if obj.Name == "Tree" and obj:IsA("Model") then
            table.insert(trees, obj)
        end
    end
    return trees
end

function TyrantSky.getEyes()
    local eyes = {}
    local paths = {
        function() return workspace.Map.TikiOutpost.IslandModel.Eye1 end,
        function() return workspace.Map.TikiOutpost.IslandModel.Eye2 end,
        function() return workspace.Map.TikiOutpost.IslandModel.IslandChunks.E.Eye3 end,
        function() return workspace.Map.TikiOutpost.IslandModel.IslandChunks.E.Eye4 end,
    }
    for _, fn in ipairs(paths) do
        local ok, obj = pcall(fn)
        if ok and obj then table.insert(eyes, obj) end
    end
    return eyes
end

function TyrantSky.allEyesLit()
    local eyes = TyrantSky.getEyes()
    if #eyes < 4 then return false end
    local litCount = 0
    for _, eye in ipairs(eyes) do
        if eye and eye.Parent and eye:IsA("BasePart") and eye.Transparency < 0.5 then
            litCount += 1
        end
    end
    return litCount >= 4
end

function TyrantSky.isTreeAlive()
    local trees = TyrantSky.getAllTrees()
    for _, tree in ipairs(trees) do
        if tree and tree.Parent then
            local alreadyDestroyed = tree:GetAttribute("AlreadyDestroyedClient")
            if not alreadyDestroyed then return true end
        end
    end
    return false
end

function TyrantSky.getBoss()
    for _, mob in ipairs(workspace.Enemies:GetChildren()) do
        if mob.Name == "Tyrant of the Skies" then
            local hum  = mob:FindFirstChildOfClass("Humanoid")
            local root = mob:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then return mob end
        end
    end
    return nil
end

function TyrantSky.getClosestMob(position)
    local closest, best = nil, math.huge
    for _, name in ipairs(TyrantSky.targetMobNames) do
        for _, mob in ipairs(workspace.Enemies:GetChildren()) do
            if mob.Name == name then
                local hum  = mob:FindFirstChildOfClass("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local d = (root.Position - position).Magnitude
                    if d < best then best = d; closest = mob end
                end
            end
        end
    end
    return closest
end

local function tyrantSendKey(keyName, holdTime)
    local key = Enum.KeyCode[keyName]
    if not key then return end
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true,  key, false, game); task.wait(holdTime or 0.06)
    vim:SendKeyEvent(false, key, false, game)
end

function TyrantSky.getSkillKeys()
    if G.AutoSkill and #G.AutoSkill.keys > 0 then return G.AutoSkill.keys end
    return { "Z", "X", "C" }
end

function TyrantSky.getWeaponModes()
    if G.AutoSkill and #G.AutoSkill.weaponTypes > 0 then return G.AutoSkill.weaponTypes end
    return { "Melee" }
end

function TyrantSky.fireSkills()
    for _, k in ipairs(TyrantSky.getSkillKeys()) do
        if not TyrantSky.enabled then break end
        local hold, waitAfter = G.getSkillTiming(k)
        tyrantSendKey(k, hold)
        task.wait(waitAfter)
    end
    if G.AutoSkill and G.AutoSkill.delay and G.AutoSkill.delay > 0 then
        task.wait(G.AutoSkill.delay)
    end
end

function TyrantSky.equipWeapon()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local modes = TyrantSky.getWeaponModes()
    if #modes == 0 then return end

    local now = tick()
    if TyrantSky._currentWeaponIndex > #modes then TyrantSky._currentWeaponIndex = 1 end
    if now - TyrantSky._lastWeaponSwitch >= TyrantSky.WEAPON_SWITCH_INTERVAL then
        TyrantSky._currentWeaponIndex = (TyrantSky._currentWeaponIndex % #modes) + 1
        TyrantSky._lastWeaponSwitch = now
    end

    local wType = modes[TyrantSky._currentWeaponIndex]
    if not wType then return end

    local keywords = G.WEAPON_TYPE_KEYWORDS[wType] or {}
    local cur = char:FindFirstChildOfClass("Tool")
    if cur then
        local tip = G.getToolTooltip(cur):lower()
        for _, kw in ipairs(keywords) do
            if tip:find(kw, 1, true) then return end
        end
    end

    local weapon = G.findWeaponByType(wType)
    if weapon then pcall(function() hum:EquipTool(weapon) end) end
end



function TyrantSky.moveLikeIsland(hrp, targetCF, dt)
    if not hrp or not hrp.Parent or not targetCF then return false end

    local currentPos = State.currentFlyCF and State.currentFlyCF.Position or hrp.Position
    local dist = (targetCF.Position - currentPos).Magnitude

    if dist > 6 then
        G.moveToTarget(hrp, targetCF, dt)
        return false
    end

    State.currentFlyCF = targetCF
    pcall(function()
        hrp.CFrame = targetCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    return true
end



function TyrantSky.doAttack(target, dt)
    if not target or not target.Parent then return false end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local root = (target:IsA("Model") and target:FindFirstChild("HumanoidRootPart"))
               or (target:IsA("BasePart") and target)
    if not root then return false end

    local targetCF = root.CFrame * CFrame.new(0, State.Y_OFFSET, 8)
    if not TyrantSky.moveLikeIsland(hrp, targetCF, dt) then
        return false
    end

    if State.bringMobEnabled then
        G.updateBringMobs(target, tick())
    end

    G.autoEquipWeapon()

    local now = tick()
    if now - TyrantSky.lastAttackTime < State.ATTACK_RATE then return true end
    TyrantSky.lastAttackTime = now

    local char2 = player.Character
    local currentTool = char2 and char2:FindFirstChildOfClass("Tool")
    local isFruit = false
    if currentTool then
        local hasLeftClick = currentTool:FindFirstChild("LeftClickRemote", true)
        if hasLeftClick then isFruit = true end
        if not isFruit then
            local tooltip = G.getToolTooltip(currentTool):lower()
            local toolName = currentTool.Name:lower()
            if tooltip:find("fruit") or toolName:find("fruit")
            or tooltip:find("devil") or toolName:find("devil") then
                isFruit = true
            end
        end
    end

    if isFruit then
        local remote = currentTool and currentTool:FindFirstChild("LeftClickRemote", true)
        local targetPos = root.Position
        if remote and targetPos and not G.fruitAttackBusy then
            G.fruitAttackBusy = true
            local capturedPos = targetPos
            local capturedHrp = hrp
            task.spawn(function()
                local dir = (capturedPos - capturedHrp.Position)
                dir = Vector3.new(dir.X, 0, dir.Z)
                local mag = dir.Magnitude
                local direction = mag > 0.01 and (dir / mag) or capturedHrp.CFrame.LookVector
                for action = 1, 4 do
                    if not remote or not remote.Parent then break end
                    pcall(function() remote:FireServer(direction, action) end)
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

    return true
end



TyrantSky._smashConn = nil

function TyrantSky.stopSmash()
    if TyrantSky._smashConn then
        TyrantSky._smashConn:Disconnect()
        TyrantSky._smashConn = nil
    end
end

function TyrantSky.smashTree(onDone)
    TyrantSky.stopSmash()

    local function getTreeDestCF(tree)
        if not tree or not tree.Parent then return nil end
        local ok, piv = pcall(function() return tree:GetPivot() end)
        local cf = ok and piv or nil
        if not cf then
            local ok2, bb = pcall(function() return tree:GetBoundingBox() end)
            cf = ok2 and bb or nil
        end
        return cf and (cf * CFrame.new(0, 5, 8)) or nil
    end

    local function isTreeStillAlive(tree)
        if not tree or not tree.Parent then return false end
        local alreadyDestroyed = tree:GetAttribute("AlreadyDestroyedClient")
        return not alreadyDestroyed
    end

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and not State.currentFlyCF then State.currentFlyCF = hrp.CFrame end

    TyrantSky._smashConn = RunService.Heartbeat:Connect(function(dt)
        if not TyrantSky.enabled or TyrantSky.phase ~= "tree" then
            TyrantSky.stopSmash()
            return
        end

        local c = player.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not h or not hum or hum.Health <= 0 then return end

        if TyrantSky.getBoss() then
            TyrantSky.stopSmash()
            if onDone then onDone() end
            return
        end

        local trees = TyrantSky.getAllTrees()
        local closestTree = nil
        local closestDist = math.huge
        for _, tree in ipairs(trees) do
            if isTreeStillAlive(tree) then
                local destCF = getTreeDestCF(tree)
                if destCF then
                    local d = (destCF.Position - h.Position).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closestTree = tree
                    end
                end
            end
        end

        if not closestTree then
            TyrantSky.stopSmash()
            if onDone then onDone() end
            return
        end

        local destCF = getTreeDestCF(closestTree)
        if not destCF then
            TyrantSky.stopSmash()
            if onDone then onDone() end
            return
        end

        if not TyrantSky.moveLikeIsland(h, destCF, dt) then
            return
        end

        local now = tick()
        if now - TyrantSky.lastAttackTime >= TyrantSky.ATTACK_RATE then
            TyrantSky.lastAttackTime = now
            TyrantSky.equipWeapon()
            if #TyrantSky.getSkillKeys() > 0 then task.spawn(TyrantSky.fireSkills) end
            pcall(FastAttackModule.ExecuteFastAttack)
            pcall(G.HitRegistrationModule.Execute)
        end
    end)
end
function TyrantSky.buildSpawnList()
    local list = {}
    local seen = {}

    local function push(pos)
        local key = G.positionKey(pos)
        if not seen[key] then
            seen[key] = true
            table.insert(list, pos)
        end
    end

    local spawns = workspace:FindFirstChild("_WorldOrigin")
        and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then
        for _, obj in ipairs(spawns:GetChildren()) do
            for _, name in ipairs(TyrantSky.targetMobNames) do
                if G.normalizeMobName(obj.Name) == G.normalizeMobName(name) then
                    local pos = G.collectSpawnPosition(obj)
                    if pos then push(pos) end
                end
            end
        end
    end

    if #list == 0 then
        local repFolder = G.getReplicatedSpawnFolder()
        if repFolder then
            for _, obj in ipairs(repFolder:GetChildren()) do
                for _, name in ipairs(TyrantSky.targetMobNames) do
                    if G.normalizeMobName(obj.Name) == G.normalizeMobName(name) then
                        local pos = G.collectSpawnPosition(obj)
                        if pos then push(pos) end
                    end
                end
            end
        end
    end

    return list
end

function TyrantSky.getNextSpawnCF(hrpPos)
    local now = tick()

    if #TyrantSky._spawnList == 0 or now - TyrantSky._lastSpawnCheck > 30 then
        TyrantSky._spawnList = TyrantSky.buildSpawnList()
        TyrantSky._lastSpawnCheck = now
        TyrantSky._spawnIndex = 1
        if hrpPos and #TyrantSky._spawnList > 0 then
            G.sortPositionsByDistance(TyrantSky._spawnList, hrpPos)
        end
    end

    if #TyrantSky._spawnList == 0 then return nil end

    if TyrantSky._spawnIndex > #TyrantSky._spawnList then
        TyrantSky._spawnIndex = 1
    end

    local pos = TyrantSky._spawnList[TyrantSky._spawnIndex]
    TyrantSky._spawnIndex = TyrantSky._spawnIndex + 1

    return CFrame.new(pos + Vector3.new(0, State.Y_OFFSET, 0))
end



TyrantSky._mainConn = nil

function TyrantSky.stop()
    TyrantSky.enabled = false
    G.tyrantActive = false
    TyrantSky.phase = "idle"
    TyrantSky.currentTarget = nil
    TyrantSky._bossGoneTick = nil
    TyrantSky._spawnList = {}
    TyrantSky._spawnIndex = 1
    TyrantSky._spawnPatrolCF = nil
    TyrantSky._spawnDwellUntil = 0
    State.currentFlyCF = nil
    G.stopMomentum()
    TyrantSky.stopSmash()
    G.clearBringMobs()
    if TyrantSky._mainConn then
        TyrantSky._mainConn:Disconnect()
        TyrantSky._mainConn = nil
    end
end

function TyrantSky.start()
    TyrantSky.stop()
    TyrantSky.enabled = true
    G.tyrantActive = true
    TyrantSky.phase = "farming"
    TyrantSky._bossGoneTick = nil
    TyrantSky._spawnList = {}
    TyrantSky._spawnIndex = 1
    TyrantSky._spawnPatrolCF = nil
    TyrantSky._spawnDwellUntil = 0

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    State.currentFlyCF = hrp and hrp.CFrame or nil

    TyrantSky._mainConn = RunService.Heartbeat:Connect(function(dt)
        if not TyrantSky.enabled then
            TyrantSky.stop()
            return
        end

        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        
        if TyrantSky.phase == "farming" then

            local eyes = TyrantSky.getEyes()
            local litCount = 0
            for _, eye in ipairs(eyes) do
                if eye and eye.Parent and eye:IsA("BasePart") and eye.Transparency < 0.5 then
                    litCount += 1
                end
            end

            local now = tick()
            if litCount >= 4 and (now - TyrantSky._lastPhaseChange) > TyrantSky.PHASE_CHANGE_COOLDOWN then
                TyrantSky._lastPhaseChange = now
                TyrantSky.phase = "tree"
                TyrantSky.currentTarget = nil
                TyrantSky._spawnPatrolCF = nil
                TyrantSky._bossGoneTick = nil
                Fluent:Notify({ Title = "Tyrant Sky", Content = "All eyes Active! Break Tree...", Duration = 3 })
                TyrantSky.smashTree(function()
                    if TyrantSky.enabled then
                        TyrantSky._lastPhaseChange = tick()
                        TyrantSky.phase = "boss"
                        TyrantSky._bossGoneTick = nil
                        Fluent:Notify({ Title = "Tyrant Sky", Content = "Boss Spawn! Hunting Tyrant...", Duration = 3 })
                    end
                end)
                return
            end

            local mob = TyrantSky.getClosestMob(hrp.Position)
            if mob then
                TyrantSky.currentTarget = mob
                TyrantSky._spawnPatrolCF = nil
                TyrantSky._spawnDwellUntil = 0
                TyrantSky.doAttack(mob, dt)
                return
            end

            TyrantSky.currentTarget = nil
            now = tick()

            if now < TyrantSky._spawnDwellUntil then
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                return
            end

            if not TyrantSky._spawnPatrolCF then
                local destCF = TyrantSky.getNextSpawnCF(hrp.Position)
                if not destCF then return end
                TyrantSky._spawnPatrolCF = destCF
            end

            if TyrantSky.moveLikeIsland(hrp, TyrantSky._spawnPatrolCF, dt) then
                TyrantSky._spawnPatrolCF = nil
                TyrantSky._spawnDwellUntil = tick() + TyrantSky.SPAWN_DWELL
            end

        
        elseif TyrantSky.phase == "tree" then
            if not TyrantSky._smashConn then
                TyrantSky.smashTree(function()
                    if TyrantSky.enabled then
                        TyrantSky._lastPhaseChange = tick()
                        TyrantSky.phase = "boss"
                        TyrantSky._bossGoneTick = nil
                        Fluent:Notify({ Title = "Tyrant Sky", Content = "Boss Spawn! Hunting Tyrant...", Duration = 3 })
                    end
                end)
            end
            return


        
        elseif TyrantSky.phase == "boss" then
            local boss = TyrantSky.getBoss()
            if boss then
                TyrantSky._bossGoneTick = nil
                TyrantSky.currentTarget = boss
                TyrantSky.doAttack(boss, dt)
            else
                local now = tick()
                if not TyrantSky._bossGoneTick then
                    TyrantSky._bossGoneTick = now
                end

                if now - TyrantSky._bossGoneTick >= TyrantSky.BOSS_GONE_CONFIRM then
                    TyrantSky.currentTarget = nil
                    TyrantSky._bossGoneTick = nil
                    TyrantSky._spawnList = {}
                    TyrantSky._spawnIndex = 1
                    TyrantSky._spawnPatrolCF = nil
                    TyrantSky._spawnDwellUntil = 0
                    TyrantSky._lastPhaseChange = now
                    TyrantSky.phase = "farming"
                    G.clearBringMobs()
                    Fluent:Notify({ Title = "Tyrant Sky", Content = "Boss confirmed dead! Back to farming...", Duration = 3 })
                end
            end
        end
    end)
end


Tabs.TyrantSection:AddToggle("TyrantSkyToggle", {
    Title   = "Auto Tyrant Sky",
    Default = false,
    Callback = function(v)
        if v then TyrantSky.start(); Fluent:Notify({ Title = "Tyrant Sky", Content = "Started!", Duration = 3 })
        else     TyrantSky.stop();  Fluent:Notify({ Title = "Tyrant Sky", Content = "Stopped.", Duration = 2 }) end
    end,
})


local AutoKatakuri = {
    enabled = false,
    phase = "farming", 
    ATTACK_RATE = 0.25,
    ATTACK_RANGE = 120,
    currentTarget = nil,
    lastAttackTime = 0,
    _spawnList = {},
    _spawnIndex = 1,
    _lastSpawnCheck = 0,
    _spawnPatrolCF = nil,
    _spawnDwellUntil = 0,
    SPAWN_DWELL = 0.2,
    _bossGoneTick = nil,
    BOSS_GONE_CONFIRM = 1.5,
    _spawnAttemptTick = nil,
    SPAWN_ATTEMPT_TIMEOUT = 8,
    _mirrorTouched = false,
    _mirrorTouchTick = nil,
    MIRROR_TOUCH_TIMEOUT = 6,
    _mainConn = nil,

    targetMobNames = {
        "Baking Staff",
        "Cake Guard",
        "Cookie Crafter",
        "Head Baker",
    },
}
G.AutoKatakuri = AutoKatakuri



function AutoKatakuri.getCakePrinceKillCount()
    local ok, result = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")
    end)
    if not ok or type(result) ~= "string" then return nil end
    local remaining = result:match("<Color=Yellow>(%d+)<Color=/>")
    if remaining then
        return tonumber(remaining)
    end
    return nil
end

function AutoKatakuri.getBoss()
    local repBoss = game:GetService("ReplicatedStorage"):FindFirstChild("Cake Prince")
    if repBoss then return repBoss end
    
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do
            if mob.Name == "Cake Prince" then
                local hum  = mob:FindFirstChildOfClass("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then return mob end
            end
        end
    end
    return nil
end

function AutoKatakuri.getClosestMob(position)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local closest, best = nil, math.huge
    for _, name in ipairs(AutoKatakuri.targetMobNames) do
        for _, mob in ipairs(enemies:GetChildren()) do
            if mob.Name == name then
                local hum  = mob:FindFirstChildOfClass("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local d = (root.Position - position).Magnitude
                    if d < best then best = d; closest = mob end
                end
            end
        end
    end
    return closest
end

function AutoKatakuri.getDripMamaPos()
    local function checkFolder(folder)
        if not folder then return nil end
        for _, npc in ipairs(folder:GetChildren()) do
            if npc.Name == "drip_mama" then
                local root = npc:FindFirstChild("HumanoidRootPart")
                          or npc:FindFirstChildWhichIsA("BasePart")
                if root then return root.Position end
                local ok, piv = pcall(function() return npc:GetPivot() end)
                if ok then return piv.Position end
            end
        end
        return nil
    end
    return checkFolder(workspace:FindFirstChild("NPCs"))
        or checkFolder(game:GetService("ReplicatedStorage"):FindFirstChild("NPCs"))
end

function AutoKatakuri.buildSpawnList()
    local list = {}
    local seen = {}
    local function push(pos)
        local key = G.positionKey(pos)
        if not seen[key] then seen[key] = true; table.insert(list, pos) end
    end

    
    local spawns = workspace:FindFirstChild("_WorldOrigin")
        and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if spawns then
        for _, obj in ipairs(spawns:GetChildren()) do
            for _, name in ipairs(AutoKatakuri.targetMobNames) do
                if G.normalizeMobName(obj.Name) == G.normalizeMobName(name) then
                    local pos = G.collectSpawnPosition(obj)
                    if pos then push(pos) end
                end
            end
        end
    end

    
    if #list == 0 then
        local repFolder = G.getReplicatedSpawnFolder()
        if repFolder then
            for _, obj in ipairs(repFolder:GetChildren()) do
                for _, name in ipairs(AutoKatakuri.targetMobNames) do
                    if G.normalizeMobName(obj.Name) == G.normalizeMobName(name) then
                        local pos = G.collectSpawnPosition(obj)
                        if pos then push(pos) end
                    end
                end
            end
        end
    end

    
    if #list == 0 then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in ipairs(enemies:GetChildren()) do
                for _, name in ipairs(AutoKatakuri.targetMobNames) do
                    if mob.Name == name then
                        local root = mob:FindFirstChild("HumanoidRootPart")
                        local hum  = mob:FindFirstChildOfClass("Humanoid")
                        if root and hum and hum.Health > 0 then
                            push(root.Position)
                        end
                    end
                end
            end
        end
    end

    return list
end

function AutoKatakuri.getNextSpawnCF(hrpPos)
    local now = tick()
    if #AutoKatakuri._spawnList == 0 or now - AutoKatakuri._lastSpawnCheck > 30 then
        AutoKatakuri._spawnList = AutoKatakuri.buildSpawnList()
        AutoKatakuri._lastSpawnCheck = now
        AutoKatakuri._spawnIndex = 1
        if hrpPos and #AutoKatakuri._spawnList > 0 then
            G.sortPositionsByDistance(AutoKatakuri._spawnList, hrpPos)
        end
    end
    if #AutoKatakuri._spawnList == 0 then return nil end

    if AutoKatakuri._spawnIndex > #AutoKatakuri._spawnList then
        AutoKatakuri._spawnIndex = 1
        if hrpPos then
            G.sortPositionsByDistance(AutoKatakuri._spawnList, hrpPos)
        end
    end

    local pos = AutoKatakuri._spawnList[AutoKatakuri._spawnIndex]
    AutoKatakuri._spawnIndex = AutoKatakuri._spawnIndex + 1

    if hrpPos and (pos - hrpPos).Magnitude < 15 then
        if AutoKatakuri._spawnIndex <= #AutoKatakuri._spawnList then
            pos = AutoKatakuri._spawnList[AutoKatakuri._spawnIndex]
            AutoKatakuri._spawnIndex = AutoKatakuri._spawnIndex + 1
        end
    end

    return CFrame.new(pos + Vector3.new(0, State.Y_OFFSET, 0))
end

function AutoKatakuri.moveLikeIsland(hrp, targetCF, dt)
    if not hrp or not hrp.Parent or not targetCF then return false end
    local currentPos = State.currentFlyCF and State.currentFlyCF.Position or hrp.Position
    local dist = (targetCF.Position - currentPos).Magnitude
    if dist > 6 then
        G.moveToTarget(hrp, targetCF, dt)
        return false
    end
    State.currentFlyCF = targetCF
    pcall(function()
        hrp.CFrame = targetCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    return true
end

function AutoKatakuri.doAttack(target, dt)
    if not target or not target.Parent then return false end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local root = target:IsA("Model") and target:FindFirstChild("HumanoidRootPart")
        or (target:IsA("BasePart") and target)
    if not root then return false end

    local targetCF = root.CFrame * CFrame.new(0, State.Y_OFFSET, 8)
    if not AutoKatakuri.moveLikeIsland(hrp, targetCF, dt) then return false end

    if State.bringMobEnabled then G.updateBringMobs(target, tick()) end
    G.autoEquipWeapon()

    local now = tick()
    if now - AutoKatakuri.lastAttackTime < State.ATTACK_RATE then return true end
    AutoKatakuri.lastAttackTime = now

    local char2 = player.Character
    local currentTool = char2 and char2:FindFirstChildOfClass("Tool")
    local isFruit = false
    if currentTool then
        local hasLeftClick = currentTool:FindFirstChild("LeftClickRemote", true)
        if hasLeftClick then isFruit = true end
        if not isFruit then
            local tip = G.getToolTooltip(currentTool):lower()
            if tip:find("fruit") or tip:find("devil") or currentTool.Name:lower():find("fruit") then
                isFruit = true
            end
        end
    end

    if isFruit then
        local remote = currentTool and currentTool:FindFirstChild("LeftClickRemote", true)
        local targetPos = root.Position
        if remote and targetPos and not G.fruitAttackBusy then
            G.fruitAttackBusy = true
            local capturedPos = targetPos
            local capturedHrp = hrp
            task.spawn(function()
                local dir = (capturedPos - capturedHrp.Position)
                dir = Vector3.new(dir.X, 0, dir.Z)
                local mag = dir.Magnitude
                local direction = mag > 0.01 and (dir / mag) or capturedHrp.CFrame.LookVector
                for action = 1, 4 do
                    if not remote or not remote.Parent then break end
                    pcall(function() remote:FireServer(direction, action) end)
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
    return true
end

function AutoKatakuri.touchMirror()
end

function AutoKatakuri.start()
    AutoKatakuri.stop()
    AutoKatakuri.enabled = true
    AutoKatakuri._spawnArriveTimeout = nil
    G.katakuriActive = true
    AutoKatakuri.phase = "farming"

    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    State.currentFlyCF = hrp and hrp.CFrame or nil

    AutoKatakuri._mainConn = RunService.Heartbeat:Connect(function(dt)
        if not AutoKatakuri.enabled then AutoKatakuri.stop(); return end

        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        
        local ag = hrp:FindFirstChild("KatakuriAntiGrav")
        if not ag then
            ag = Instance.new("BodyForce")
            ag.Name = "KatakuriAntiGrav"
            ag.Parent = hrp
        end
        ag.Force = Vector3.new(0, hrp.AssemblyMass * workspace.Gravity, 0)

        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        
        local bossInWorld = false
        local bossInWorldMob = nil
        pcall(function()
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, mob in ipairs(enemies:GetChildren()) do
                    if mob.Name == "Cake Prince" then
                        local h = mob:FindFirstChildOfClass("Humanoid")
                        local r = mob:FindFirstChild("HumanoidRootPart")
                        if h and r and h.Health > 0 then
                            bossInWorld = true
                            bossInWorldMob = mob
                        end
                    end
                end
            end
        end)

        
        local bossInRep = false
        pcall(function()
            local repBoss = game:GetService("ReplicatedStorage"):FindFirstChild("Cake Prince")
            if repBoss then
                local h = repBoss:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    bossInRep = true
                end
            end
        end)

        if bossInWorld and AutoKatakuri.phase ~= "boss" then
            AutoKatakuri.phase = "boss"
            AutoKatakuri._mirrorTouched = true
            AutoKatakuri._bossGoneTick = nil
            AutoKatakuri.currentTarget = bossInWorldMob
            State.currentFlyCF = hrp.CFrame
            Fluent:Notify({ Title = "Auto Katakuri", Content = "บอสอยู่แล้ว! ตีเลย!", Duration = 3 })
        elseif not bossInWorld and bossInRep
            and (AutoKatakuri.phase == "spawning" or AutoKatakuri.phase == "farming") then
            AutoKatakuri.phase = "mirror"
            AutoKatakuri._mirrorTouched = false
            AutoKatakuri._mirrorTouchTick = nil
            AutoKatakuri._spawnAttemptTick = nil
            AutoKatakuri.currentTarget = nil
            State.currentFlyCF = hrp.CFrame
            Fluent:Notify({ Title = "Auto Katakuri", Content = "บอสเกิดแล้ว! บินไป mirror...", Duration = 3 })
        end

        
        if AutoKatakuri.phase == "farming" then
            local now = tick()
            if not AutoKatakuri._lastKillCheck or now - AutoKatakuri._lastKillCheck >= 3 then
                AutoKatakuri._lastKillCheck = now
                local count = AutoKatakuri.getCakePrinceKillCount()
                if count ~= nil and count <= 0 then
                    AutoKatakuri.phase = "spawning"
                    AutoKatakuri.currentTarget = nil
                    AutoKatakuri._spawnPatrolCF = nil
                    AutoKatakuri._spawnAttemptTick = nil
                    G.clearBringMobs()
                    Fluent:Notify({ Title = "Auto Katakuri", Content = "500 kills! ไป spawn Cake Prince...", Duration = 3 })
                    return
                end
            end

            local mob = AutoKatakuri.getClosestMob(hrp.Position)
            if mob then
                AutoKatakuri.currentTarget = mob
                AutoKatakuri._spawnPatrolCF = nil
                AutoKatakuri._spawnDwellUntil = 0
                AutoKatakuri.doAttack(mob, dt)
                return
            end

            AutoKatakuri.currentTarget = nil
            local now2 = tick()
            if now2 < AutoKatakuri._spawnDwellUntil then
                return
            end

            if not AutoKatakuri._spawnPatrolCF then
                local destCF = AutoKatakuri.getNextSpawnCF(hrp.Position)
                if not destCF then
                    AutoKatakuri._spawnList = {}
                    AutoKatakuri._spawnIndex = 1
                    return
                end
                AutoKatakuri._spawnPatrolCF = destCF
                AutoKatakuri._spawnArriveTimeout = tick() + 8
            end

            if tick() > (AutoKatakuri._spawnArriveTimeout or 0) then
                AutoKatakuri._spawnPatrolCF = nil
                AutoKatakuri._spawnArriveTimeout = nil
                AutoKatakuri._spawnDwellUntil = 0
                return
            end

            if AutoKatakuri.moveLikeIsland(hrp, AutoKatakuri._spawnPatrolCF, dt) then
                AutoKatakuri._spawnPatrolCF = nil
                AutoKatakuri._spawnArriveTimeout = nil
                AutoKatakuri._spawnDwellUntil = tick() + AutoKatakuri.SPAWN_DWELL
            end

        
        elseif AutoKatakuri.phase == "spawning" then
            local dripPos = AutoKatakuri.getDripMamaPos()
            if dripPos then
                local destCF = CFrame.new(dripPos + Vector3.new(0, 3, 4))
                local dist = (destCF.Position - hrp.Position).Magnitude

                if dist > 6 then
                    AutoKatakuri.moveLikeIsland(hrp, destCF, dt)
                    return
                end

                if not AutoKatakuri._spawnAttemptTick then
                    AutoKatakuri._spawnAttemptTick = tick()
                    pcall(function()
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner", true)
                    end)
                    Fluent:Notify({ Title = "Auto Katakuri", Content = "Invoke spawn! รอ Cake Prince...", Duration = 3 })
                end

                if tick() - AutoKatakuri._spawnAttemptTick > AutoKatakuri.SPAWN_ATTEMPT_TIMEOUT then
                    AutoKatakuri._spawnAttemptTick = nil
                end
            end

        
        elseif AutoKatakuri.phase == "mirror" then
            local mirrorCF = nil
            pcall(function()
                mirrorCF = workspace.Map.CakeLoaf.BigMirror.Main.CFrame * CFrame.new(0, 2, 0)
            end)

            if not mirrorCF then
                AutoKatakuri.phase = "boss"
                AutoKatakuri._bossGoneTick = nil
                return
            end

            G.moveToTarget(hrp, mirrorCF, dt)
            State.currentFlyCF = mirrorCF

            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, mob in ipairs(enemies:GetChildren()) do
                        if mob.Name == "Cake Prince" then
                            local h = mob:FindFirstChildOfClass("Humanoid")
                            local r = mob:FindFirstChild("HumanoidRootPart")
                            if h and r and h.Health > 0 then
                                AutoKatakuri._mirrorTouched = true
                                AutoKatakuri.phase = "boss"
                                AutoKatakuri._bossGoneTick = nil
                                AutoKatakuri.currentTarget = mob
                                State.currentFlyCF = hrp.CFrame
                                Fluent:Notify({ Title = "Auto Katakuri", Content = "เข้า mirror แล้ว! ตี Cake Prince!", Duration = 3 })
                            end
                        end
                    end
                end
            end)

        elseif AutoKatakuri.phase == "boss" then
            local bossTarget = nil
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, mob in ipairs(enemies:GetChildren()) do
                        if mob.Name == "Cake Prince" then
                            local h = mob:FindFirstChildOfClass("Humanoid")
                            local r = mob:FindFirstChild("HumanoidRootPart")
                            if h and r and h.Health > 0 then
                                bossTarget = mob
                            end
                        end
                    end
                end
            end)

            if bossTarget then
                AutoKatakuri._bossGoneTick = nil
                AutoKatakuri.currentTarget = bossTarget

                local bossHum = bossTarget:FindFirstChildOfClass("Humanoid")
                if bossHum and bossHum.Health <= 0 then
                    AutoKatakuri.currentTarget = nil
                    AutoKatakuri._bossGoneTick = nil
                    AutoKatakuri._spawnList = {}
                    AutoKatakuri._spawnIndex = 1
                    AutoKatakuri._spawnPatrolCF = nil
                    AutoKatakuri._spawnDwellUntil = 0
                    AutoKatakuri._mirrorTouched = false
                    AutoKatakuri._mirrorTouchTick = nil
                    AutoKatakuri._spawnAttemptTick = nil
                    AutoKatakuri._lastKillCheck = nil
                    AutoKatakuri.phase = "farming"
                    G.clearBringMobs()
                    pcall(function()
                        local c = player.Character
                        local r = c and c:FindFirstChild("HumanoidRootPart")
                        if r then
                            local ag = r:FindFirstChild("KatakuriAntiGrav")
                            if ag then ag:Destroy() end
                            r.AssemblyLinearVelocity = Vector3.zero
                            r.AssemblyAngularVelocity = Vector3.zero
                        end
                        local hum = c and c:FindFirstChildOfClass("Humanoid")
                        if hum then hum.AutoRotate = true end
                    end)
                    State.currentFlyCF = nil
                    Fluent:Notify({ Title = "Auto Katakuri", Content = "Cake Prince ตายแล้ว! นับใหม่ 0/500...", Duration = 3 })
                    return
                end

                AutoKatakuri.doAttack(bossTarget, dt)
            else
                AutoKatakuri.currentTarget = nil
                AutoKatakuri._bossGoneTick = nil
                AutoKatakuri._spawnList = {}
                AutoKatakuri._spawnIndex = 1
                AutoKatakuri._spawnPatrolCF = nil
                AutoKatakuri._spawnDwellUntil = 0
                AutoKatakuri._mirrorTouched = false
                AutoKatakuri._mirrorTouchTick = nil
                AutoKatakuri._spawnAttemptTick = nil
                AutoKatakuri._lastKillCheck = nil
                AutoKatakuri.phase = "farming"
                G.clearBringMobs()
                pcall(function()
                    local c = player.Character
                    local r = c and c:FindFirstChild("HumanoidRootPart")
                    if r then
                        local ag = r:FindFirstChild("KatakuriAntiGrav")
                        if ag then ag:Destroy() end
                        r.AssemblyLinearVelocity = Vector3.zero
                        r.AssemblyAngularVelocity = Vector3.zero
                    end
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    if hum then hum.AutoRotate = true end
                end)
                State.currentFlyCF = nil
                Fluent:Notify({ Title = "Auto Katakuri", Content = "Cake Prince ตายแล้ว! นับใหม่ 0/500...", Duration = 3 })
            end
        end
    end)
end  

function AutoKatakuri.stop()
    AutoKatakuri.enabled = false
    G.katakuriActive = false
    AutoKatakuri._spawnArriveTimeout = nil
    AutoKatakuri.phase = "farming"
    AutoKatakuri.currentTarget = nil
    AutoKatakuri._bossGoneTick = nil
    AutoKatakuri._spawnList = {}
    AutoKatakuri._spawnIndex = 1
    AutoKatakuri._spawnPatrolCF = nil
    AutoKatakuri._spawnDwellUntil = 0
    AutoKatakuri._spawnAttemptTick = nil
    AutoKatakuri._mirrorTouched = false
    AutoKatakuri._mirrorTouchTick = nil
    AutoKatakuri._lastKillCheck = nil
    State.currentFlyCF = nil
    G.stopMomentum()
    G.clearBringMobs()

    pcall(function()
        local c = player.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if r then
            local ag = r:FindFirstChild("KatakuriAntiGrav")
            if ag then ag:Destroy() end
        end
    end)

    if AutoKatakuri._mainConn then
        AutoKatakuri._mainConn:Disconnect()
        AutoKatakuri._mainConn = nil
    end
end

Tabs.KatakuriSection:AddToggle("AutoKatakuriToggle", {
    Title   = "Auto Katakuri",
    Default = false,
    Callback = function(v)
        if v then
            AutoKatakuri.start()
            Fluent:Notify({ Title = "Auto Katakuri", Content = "Started!", Duration = 3 })
        else
            AutoKatakuri.stop()
            Fluent:Notify({ Title = "Auto Katakuri", Content = "Stopped.", Duration = 2 })
        end
    end,
})


G.EventMagnet = {
	enabled = false,
	phase = "idle",          
	visitedNames = {},       
	spawnList = {},
	targetSpawn = nil,       
	destCF = nil,
	scanUntil = 0,
	currentTarget = nil,
	lastAttackTime = 0,
	ATTACK_RATE = 0.12,
	SCAN_TIME = 1.5,
	_conn = nil,
}

local EM = G.EventMagnet

EM.IGNORE_NAMES = {
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["Part"] = true,
	["HumanoidRootPart"] = true,
	["Spawn"] = true,
}


function EM.isIgnored(nameOrInstance)
	if not nameOrInstance then
		return false
	end
	local raw, base
	if typeof and typeof(nameOrInstance) == "Instance" then
		raw = nameOrInstance.Name
		pcall(function()
			base = G.getMobBaseName(nameOrInstance)
		end)
	elseif type(nameOrInstance) == "userdata" then
		raw = nameOrInstance.Name
	else
		raw = tostring(nameOrInstance)
	end
	if raw and EM.IGNORE_NAMES[raw] then
		return true
	end
	local nRaw = G.normalizeMobName(raw or "")
	local nBase = G.normalizeMobName(base or "")
	for key, on in pairs(EM.IGNORE_NAMES) do
		if on then
			local nKey = G.normalizeMobName(key)
			if nKey ~= "" and (nKey == nRaw or (nBase ~= "" and nKey == nBase)) then
				return true
			end
		end
	end
	return false
end

function EM.buildSpawnList()
	local list = {}
	local folder = G.getReplicatedSpawnFolder()
	if not folder then
		return list
	end
	pcall(function()
		for _, obj in ipairs(folder:GetDescendants()) do
			if not EM.isIgnored(obj) and not EM.visitedNames[obj.Name] then
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
					table.insert(list, { name = obj.Name, pos = pos })
				end
			end
		end
	end)
	return list
end

function EM.pickNextSpawn(fromPos)
	EM.spawnList = EM.buildSpawnList()
	local best, bestDist = nil, math.huge
	for _, item in ipairs(EM.spawnList) do
		if not EM.visitedNames[item.name] then
			local d = (item.pos - fromPos).Magnitude
			if d < bestDist then
				bestDist = d
				best = item
			end
		end
	end
	return best
end


function EM.hasMagnetRig(enemy)
	if not enemy or not enemy.Parent then
		return false
	end
	local found = false
	pcall(function()
		if enemy:FindFirstChild("MagnetTransformedRigObject", true) then
			found = true
		end
	end)
	return found
end


function EM.isBossEnemy(enemy)
	if not enemy then
		return false
	end
	local bossType = nil
	pcall(function()
		bossType = G.bossTypeFromInstance(enemy)
	end)
	if bossType then
		return true
	end
	pcall(function()
		bossType = G.isMobBoss(G.getMobBaseName(enemy) or enemy.Name)
	end)
	return bossType ~= nil
end

function EM.getMagnetTargets()
	local list = {}
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if
			G.isEnemyAlive(enemy)
			and EM.hasMagnetRig(enemy)
			and not EM.isBossEnemy(enemy)
			and not EM.isIgnored(enemy)
		then
			table.insert(list, enemy)
		end
	end
	return list
end

function EM.getClosestMagnetTarget(fromPos)
	local best, bestDist = nil, math.huge
	for _, enemy in ipairs(EM.getMagnetTargets()) do
		local root = enemy:FindFirstChild("HumanoidRootPart")
		if root then
			local d = (root.Position - fromPos).Magnitude
			if d < bestDist then
				bestDist = d
				best = enemy
			end
		end
	end
	return best
end


function EM.moveTo(hrp, targetCF, dt)
	if not hrp or not hrp.Parent or not targetCF then
		return false
	end
	local currentPos = State.currentFlyCF and State.currentFlyCF.Position or hrp.Position
	local dist = (targetCF.Position - currentPos).Magnitude
	if dist > 6 then
		G.moveToTarget(hrp, targetCF, dt)
		return false
	end
	State.currentFlyCF = targetCF
	pcall(function()
		hrp.CFrame = targetCF
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end)
	return true
end

function EM.attack(target, dt)
	if not target or not target.Parent then
		return false
	end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false
	end
	local root = target:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end

	
	local targetCF = root.CFrame * CFrame.new(0, State.Y_OFFSET or 8, 8)
	if not EM.moveTo(hrp, targetCF, dt) then
		return false
	end

	G.updateBringMobs(target, tick())

	G.autoEquipWeapon()

	local now = tick()
    if now - EM.lastAttackTime < State.ATTACK_RATE then return true end
	EM.lastAttackTime = now

	pcall(FastAttackModule.ExecuteFastAttack)
	pcall(G.HitRegistrationModule.Execute)
	return true
end

function EM.stop()
	EM.enabled = false
	EM.phase = "idle"
	EM.targetSpawn = nil
	EM.destCF = nil
	EM.currentTarget = nil
	EM.spawnList = {}
	EM.scanUntil = 0
	State.currentFlyCF = nil
	G.stopMomentum()
	G.clearBringMobs()
	if EM._conn then
		EM._conn:Disconnect()
		EM._conn = nil
	end
end

function EM.resetVisited()
	EM.visitedNames = {}
	EM.spawnList = {}
	EM.targetSpawn = nil
	EM.destCF = nil
end

function EM.start()
	EM.stop()
	EM.enabled = true
	EM.phase = "travel"

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	State.currentFlyCF = hrp and hrp.CFrame or nil

	EM._conn = RunService.Heartbeat:Connect(function(dt)
		if not EM.enabled then
			EM.stop()
			return
		end

		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then
			return
		end

		
		if EM.phase ~= "kill" then
			local magnetMob = EM.getClosestMagnetTarget(hrp.Position)
			if magnetMob then
				EM.currentTarget = magnetMob
				EM.phase = "kill"
			end
		end

		
		if EM.phase == "kill" then
			if not G.isEnemyAlive(EM.currentTarget) or not EM.hasMagnetRig(EM.currentTarget) then
				EM.currentTarget = EM.getClosestMagnetTarget(hrp.Position)
			end
			if EM.currentTarget then
				EM.attack(EM.currentTarget, dt)
				return
			end
			
			if EM.targetSpawn then
				EM.visitedNames[EM.targetSpawn.name] = true
			end
			G.clearBringMobs()
			EM.targetSpawn = nil
			EM.destCF = nil
			EM.phase = "travel"
			return
		end

		
		if EM.phase == "travel" then
			if not EM.targetSpawn then
				local nextSpawn = EM.pickNextSpawn(hrp.Position)
				if not nextSpawn then
					
					EM.resetVisited()
					return
				end
				EM.targetSpawn = nextSpawn
				EM.destCF = CFrame.new(nextSpawn.pos + Vector3.new(0, State.Y_OFFSET or 8, 0))
			end

			if EM.moveTo(hrp, EM.destCF, dt) then
				EM.phase = "scan"
				EM.scanUntil = tick() + EM.SCAN_TIME
			end
			return
		end

		
		if EM.phase == "scan" then
			
			if EM.destCF then
				State.currentFlyCF = EM.destCF
				pcall(function()
					hrp.CFrame = EM.destCF
				end)
			end
			pcall(function()
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)

			local magnetMob = EM.getClosestMagnetTarget(hrp.Position)
			if magnetMob then
				EM.currentTarget = magnetMob
				EM.phase = "kill"
				return
			end

			if tick() >= EM.scanUntil then
				if EM.targetSpawn then
					EM.visitedNames[EM.targetSpawn.name] = true
				end
				EM.targetSpawn = nil
				EM.destCF = nil
				EM.phase = "travel"
			end
			return
		end
	end)
end


EM.armed = false
EM.START_MINUTE = 0
EM.END_MINUTE = 11      
EM.RESET_MINUTE = 12    
EM._lastResetStamp = nil
EM._schedulerRunning = false

function EM.inWindow()
	local t = os.date("*t")
	return t.min >= EM.START_MINUTE and t.min < EM.END_MINUTE
end

function EM.startScheduler()
	if EM._schedulerRunning then
		return
	end
	EM._schedulerRunning = true
	task.spawn(function()
		while true do
			local ok = pcall(function()
				local t = os.date("*t")

				
				if t.min == EM.RESET_MINUTE then
					local stamp = string.format("%d-%d-%d-%d", t.year, t.yday, t.hour, t.min)
					if EM._lastResetStamp ~= stamp then
						EM._lastResetStamp = stamp
						EM.resetVisited()
						Fluent:Notify({
							Title = "Event Magnet",
							Content = "Auto reset checked spawns (" .. string.format("%02d:%02d", t.hour, t.min) .. ")",
							Duration = 3,
						})
					end
				end

				if EM.armed then
					if EM.inWindow() then
						if not EM.enabled then
							EM.resetVisited()
							EM.start()
							Fluent:Notify({
								Title = "Event Magnet",
								Content = "Event time! Running until **:" .. string.format("%02d", EM.END_MINUTE),
								Duration = 3,
							})
						end
					else
						if EM.enabled then
							EM.stop()
							Fluent:Notify({ Title = "Event Magnet", Content = "Window closed. Waiting for **:00", Duration = 3 })
						end
						
						local nowSec = t.hour * 3600 + t.min * 60 + t.sec
						local remain = ((t.hour + 1) % 24) * 3600 - nowSec
						if remain < 0 then
							remain = remain + 86400
						end
						Fluent:Notify({
							Title = "Event Magnet",
							Content = string.format(
								"Now %02d:%02d:%02d — event starts in %d min %02d sec",
								t.hour, t.min, t.sec, math.floor(remain / 60), remain % 60
							),
							Duration = 1,
						})
					end
				elseif EM.enabled then
					EM.stop()
				end
			end)
			if not ok then
				task.wait(1)
			end
			task.wait(1)
		end
	end)
end

EM.startScheduler()



Tabs.MagnetSection:AddToggle("EventMagnetToggle", {
	Title = "Auto Event Magnet",
	Default = false,
	Callback = function(v)
		EM.armed = v
		if v then
			if EM.inWindow() then
				EM.resetVisited()
				EM.start()
				Fluent:Notify({ Title = "Event Magnet", Content = "Event time! Started.", Duration = 3 })
			else
				Fluent:Notify({ Title = "Event Magnet", Content = "Armed. Waiting for **:00", Duration = 3 })
			end
		else
			EM.stop()
			Fluent:Notify({ Title = "Event Magnet", Content = "Stopped.", Duration = 2 })
		end
	end,
})


G.AutoSkill = {
	enabled = false,
	weaponTypes = { "Melee", "Sword" },
	keys = { "Z", "X", "C" },
	delay = 0.35,
	timing = {
		Z = { hold = 0.06, wait = 0.15 },
		X = { hold = 0.06, wait = 0.15 },
		C = { hold = 0.06, wait = 0.15 },
		V = { hold = 0.06, wait = 0.15 },
		F = { hold = 0.06, wait = 0.15 },
	},
}

function G.getSkillTiming(keyName)
	local t = G.AutoSkill.timing[keyName]
	if not t then return 0.06, 0.15 end
	return t.hold or 0.06, t.wait or 0.15
end

local autoSkillWeaponValues = { "Melee", "Sword", "Fruit", "Gun" }
local autoSkillKeyValues = { "Z", "X", "C", "V", "F" }

Tabs.AutoSkillSection:AddToggle("AutoSkillToggle", {
	Title = "Auto Skill",
	Default = false,
	Callback = function(v)
		G.AutoSkill.enabled = v
		Fluent:Notify({
			Title = "Auto Skill",
			Content = v and "Enabled" or "Disabled",
			Duration = 2,
		})
	end,
})

Tabs.AutoSkillSection:AddDropdown("AutoSkillWeaponDropdown", {
	Title = "Skill Mode (Weapon Type)",
	Values = autoSkillWeaponValues,
	Multi = true,
	Default = { Melee = true, Sword = true },
	Callback = function(selected)
		local modes = {}
		for _, v in ipairs(autoSkillWeaponValues) do
			if selected[v] then
				table.insert(modes, v)
			end
		end
		G.AutoSkill.weaponTypes = modes
	end,
})

Tabs.AutoSkillSection:AddDropdown("AutoSkillKeysDropdown", {
	Title = "Skill Keys to Press",
	Values = autoSkillKeyValues,
	Multi = true,
	Default = { Z = true, X = true, C = true },
	Callback = function(selected)
		local keys = {}
		for _, k in ipairs(autoSkillKeyValues) do
			if selected[k] then
				table.insert(keys, k)
			end
		end
		G.AutoSkill.keys = keys
	end,
})

Tabs.AutoSkillSection:AddSlider("AutoSkillDelaySlider", {
	Title = "Skill Delay (sec)",
	Default = 0.35,
	Min = 0.1,
	Max = 2,
	Rounding = 2,
	Callback = function(v)
		G.AutoSkill.delay = v
	end,
})

for _, skillKey in ipairs(autoSkillKeyValues) do
	local thisKey = skillKey

	Tabs.AutoSkillTiming:AddSlider("AutoSkillHold_" .. thisKey, {
		Title = thisKey .. " - Hold (sec)",
		Default = 0.06,
		Min = 0.01,
		Max = 3,
		Rounding = 2,
		Callback = function(v)
			G.AutoSkill.timing[thisKey].hold = v
		end,
	})

	Tabs.AutoSkillTiming:AddSlider("AutoSkillWait_" .. thisKey, {
		Title = thisKey .. " - Wait after (sec)",
		Default = 0.15,
		Min = 0,
		Max = 5,
		Rounding = 2,
		Callback = function(v)
			G.AutoSkill.timing[thisKey].wait = v
		end,
	})
end

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

function G.getAvailableNpcNames()
    local names = {}
    local seen  = {}

    local function addFromFolder(folder)
        if not folder then return end
        for _, npc in ipairs(folder:GetChildren()) do
            local name = npc.Name
            if name and name ~= "" and not seen[name] then
                seen[name] = true
                table.insert(names, name)
            end
        end
    end

    addFromFolder(game:GetService("ReplicatedStorage"):FindFirstChild("NPCs"))
    addFromFolder(workspace:FindFirstChild("NPCs"))

    table.sort(names)
    return names
end

function G.getNpcPosition(wantedName)
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local playerPos = hrp and hrp.Position

    local closest    = nil
    local closestDist = math.huge

    local function checkFolder(folder)
        if not folder then return end
        for _, npc in ipairs(folder:GetChildren()) do
            if npc.Name == wantedName then
                local pos = nil
                local root = npc:FindFirstChild("HumanoidRootPart")
                          or npc:FindFirstChildWhichIsA("BasePart")
                if root then
                    pos = root.Position
                elseif npc:IsA("Model") then
                    local ok, pivot = pcall(function() return npc:GetPivot() end)
                    if ok then pos = pivot.Position end
                elseif npc:IsA("BasePart") then
                    pos = npc.Position
                end

                if pos then
                    local dist = playerPos and (pos - playerPos).Magnitude or 0
                    if dist < closestDist then
                        closestDist = dist
                        closest     = pos
                    end
                end
            end
        end
    end

    checkFolder(workspace:FindFirstChild("NPCs"))

    if not closest then
        checkFolder(game:GetService("ReplicatedStorage"):FindFirstChild("NPCs"))
    end

    return closest
end


State.selectedNpcName       = nil
State.npcTweenEnabled       = false
State.npcTweenConn          = nil
State.currentNpcFlyCF       = nil

function G.stopTweenNpc()
    State.npcTweenEnabled = false
    if State.npcTweenConn then
        State.npcTweenConn:Disconnect()
        State.npcTweenConn = nil
    end
    State.currentNpcFlyCF = nil
    G.stopMomentum()
end

function G.startTweenNpc()
    G.stopTweenNpc()

    local npcName = State.selectedNpcName
    if not npcName then
        Fluent:Notify({ Title = "NPC", Content = "Select NPC first", Duration = 2 })
        return
    end

    local npcPos = G.getNpcPosition(npcName)
    if not npcPos then
        Fluent:Notify({ Title = "NPC", Content = "NPC not found in world: " .. npcName, Duration = 3 })
        return
    end

    State.npcTweenEnabled = true

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then State.currentNpcFlyCF = hrp.CFrame end

    Fluent:Notify({ Title = "NPC", Content = "Going to " .. npcName, Duration = 2 })

    State.npcTweenConn = RunService.Heartbeat:Connect(function(dt)
        if not State.npcTweenEnabled then
            G.stopTweenNpc()
            return
        end

        local c   = player.Character
        local h   = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not h or not hum or hum.Health <= 0 then return end

        
        local currentNpcPos = G.getNpcPosition(npcName)
        if not currentNpcPos then return end

        local destCF = CFrame.new(currentNpcPos) * CFrame.new(0, 3, 4)

        if not State.currentNpcFlyCF
        or (State.currentNpcFlyCF.Position - h.Position).Magnitude > 150 then
            State.currentNpcFlyCF = h.CFrame
        end

        local currentPos = State.currentNpcFlyCF.Position
        local dist = (destCF.Position - currentPos).Magnitude

        if dist > 3 then
            
            State.currentFlyCF = State.currentNpcFlyCF
            G.moveToTarget(h, CFrame.new(destCF.Position), dt)
            State.currentNpcFlyCF = State.currentFlyCF
        else
            
            State.currentNpcFlyCF = destCF
            pcall(function()
                h.CFrame                  = destCF
                h.AssemblyLinearVelocity  = Vector3.zero
                h.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end


local npcNames = G.getAvailableNpcNames()
if #npcNames == 0 then table.insert(npcNames, "No NPC found") end
State.selectedNpcName = npcNames[1]

local NpcDropdown
NpcDropdown = Tabs.NpcSection:AddDropdown("NpcDropdown", {
    Title   = "Select NPC",
    Values  = npcNames,
    Multi   = false,
    Default = 1,
    Search  = true,
    Callback = function(value)
        State.selectedNpcName = value
    end,
})

Tabs.NpcSection:AddButton({   
    Title    = "Refresh NPC List",
    Callback = function()
        local newNames = G.getAvailableNpcNames()
        if #newNames == 0 then table.insert(newNames, "No NPC found") end

        pcall(function()
            if NpcDropdown and NpcDropdown.SetValues then
                NpcDropdown:SetValues(newNames)
            end
        end)

        local stillExists = false
        for _, n in ipairs(newNames) do
            if n == State.selectedNpcName then stillExists = true; break end
        end
        if not stillExists then
            State.selectedNpcName = newNames[1]
            pcall(function()
                if NpcDropdown and NpcDropdown.SetValue then
                    NpcDropdown:SetValue(newNames[1])
                end
            end)
        end

        Fluent:Notify({ Title = "NPC", Content = "Refreshed: " .. #newNames .. " NPCs", Duration = 2 })
    end,
})

local NpcTravelToggle
NpcTravelToggle = Tabs.NpcSection:AddToggle("NpcTravelToggle", {   
    Title    = "Go to NPC",
    Default  = false,
    Callback = function(value)
        if value then
            if not State.selectedNpcName or State.selectedNpcName == "No NPC found" then
                Fluent:Notify({ Title = "NPC", Content = "Select NPC first", Duration = 2 })
                pcall(function() NpcTravelToggle:SetValue(false) end)
                return
            end
            G.startTweenNpc()
        else
            G.stopTweenNpc()
            Fluent:Notify({ Title = "NPC", Content = "Stopped", Duration = 2 })
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
	Min = -120,
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
	while task.wait(0.1) do
		if _G.AutoObservation then
			pcall(function()
				local dodgesLabel = game:GetService("Players").LocalPlayer.PlayerGui.Main.BottomHUDList.UniversalContextButtons.BoundActionKen.DodgesLeftLabel
				if not dodgesLabel.Visible then
					game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
					task.wait(0.05)
					game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
				end
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
function sendKey(keyName)
	local key = Enum.KeyCode[keyName]
	if not key then
		return
	end
	local vim = game:GetService("VirtualInputManager")
	vim:SendKeyEvent(true, key, false, game)
	task.wait(0.06)
	vim:SendKeyEvent(false, key, false, game)
end

function getRaceCooldownGui()
	local LP = game:GetService("Players").LocalPlayer
	local gui = LP:FindFirstChild("PlayerGui")
	local node = gui
	for _, name in ipairs({ "Main", "BottomHUDList", "UniversalContextButtons", "BoundActionRaceAbility", "Cooldown" }) do
		if not node then
			return nil
		end
		node = node:FindFirstChild(name)
	end
	return node
end

task.spawn(function()
	while task.wait(0.1) do
		if _G.RaceClickAutov3 then
			pcall(function()
				local LP = game:GetService("Players").LocalPlayer
				local gui = LP:FindFirstChild("PlayerGui")
				local gradient = gui
					and gui:FindFirstChild("Main")
					and gui.Main:FindFirstChild("BottomHUDList")
					and gui.Main.BottomHUDList:FindFirstChild("UniversalContextButtons")
					and gui.Main.BottomHUDList.UniversalContextButtons:FindFirstChild("BoundActionRaceAbility")
					and gui.Main.BottomHUDList.UniversalContextButtons.BoundActionRaceAbility:FindFirstChild("Cooldown")
					and gui.Main.BottomHUDList.UniversalContextButtons.BoundActionRaceAbility.Cooldown:FindFirstChild("Frame1")
					and gui.Main.BottomHUDList.UniversalContextButtons.BoundActionRaceAbility.Cooldown.Frame1:FindFirstChild("Frame")
					and gui.Main.BottomHUDList.UniversalContextButtons.BoundActionRaceAbility.Cooldown.Frame1.Frame:FindFirstChild("UIGradient")

				if (not gradient) or (gradient.Rotation == 180) then
					local remotes = replicated and replicated:FindFirstChild("Remotes")
					local commE = remotes and remotes:FindFirstChild("CommE")
					if commE then
						commE:FireServer("ActivateAbility")
					else
						sendKey("T")
					end
				end
			end)
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
				local LP = game:GetService("Players").LocalPlayer
				local char = LP.Character
				if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
					return
				end

				local data = LP:FindFirstChild("Data")
				local race = data and data:FindFirstChild("Race")

				if race and race.Value == "Draco" then
					local backpack = LP:FindFirstChild("Backpack")
					local awakening = (backpack and backpack:FindFirstChild("Awakening")) or char:FindFirstChild("Awakening")
					local remote = awakening and awakening:FindFirstChild("RemoteFunction")
					if remote then
						remote:InvokeServer(true)
					else
						sendKey("Y")
					end
				else
					local energy = char:FindFirstChild("RaceEnergy")
					if (not energy) or energy.Value >= 1 then
						sendKey("Y")
					end
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


local PVP = {
    enabled      = false,
    spectating   = false,
    targetPlayer = nil,
    conn         = nil,
    spectateConn = nil,
    Y_OFFSET     = 5,
}

function PVP.getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then table.insert(list, "(No players)") end
    return list
end

function PVP.getTargetHRP()
    local p = PVP.targetPlayer
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild("HumanoidRootPart")
end


function PVP.stopGoto()
    PVP.enabled = false
    if PVP.conn then PVP.conn:Disconnect(); PVP.conn = nil end

    
    local c = player.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if r then
        local ag = r:FindFirstChild("PVP_AntiGrav")
        if ag then ag:Destroy() end
        local bg = r:FindFirstChild("PVP_BodyGyro")
        if bg then bg:Destroy() end
        pcall(function()
            r.AssemblyLinearVelocity  = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.AutoRotate = true end

    State.currentFlyCF = nil
    G.stopMomentum()
end


function PVP.stopSpectate()
    PVP.spectating = false
    if PVP.spectateConn then
        PVP.spectateConn:Disconnect()
        PVP.spectateConn = nil
    end
    pcall(function()
        local cam = workspace.CurrentCamera
        cam.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        cam.CameraType    = Enum.CameraType.Follow
    end)
end


function PVP.startGoto()
    PVP.stopGoto()
    if not PVP.targetPlayer then
        Fluent:Notify({ Title = "PVP", Content = "Select a player first", Duration = 2 })
        return
    end

    PVP.enabled = true

    local c = player.Character
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if r then State.currentFlyCF = r.CFrame end

    local function getOrCreateMovers(root)
        local ag = root:FindFirstChild("PVP_AntiGrav")
        if not ag then
            ag = Instance.new("BodyForce")
            ag.Name = "PVP_AntiGrav"
            ag.Parent = root
        end
        ag.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)

        local bg = root:FindFirstChild("PVP_BodyGyro")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name   = "PVP_BodyGyro"
            bg.MaxTorque = Vector3.zero
            bg.P      = 50000
            bg.D      = 1500
            bg.Parent = root
        end
        return ag, bg
    end

    PVP.conn = RunService.Heartbeat:Connect(function(dt)
        if not PVP.enabled then
            PVP.stopGoto()
            return
        end

        local myChar = player.Character
        local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not myHRP or not myHum or myHum.Health <= 0 then return end

        local antiGrav, bodyGyro = getOrCreateMovers(myHRP)
        antiGrav.Force = Vector3.new(0, myHRP.AssemblyMass * workspace.Gravity, 0)

        
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        myHRP.AssemblyLinearVelocity  = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero

        local tgtHRP = PVP.getTargetHRP()
        if not tgtHRP then
            
            G.fsHoldPosition(myHRP)
            return
        end

        local targetCF = tgtHRP.CFrame * CFrame.new(0, PVP.Y_OFFSET, 6)
        local currentPos = State.currentFlyCF and State.currentFlyCF.Position or myHRP.Position
        local dist = (targetCF.Position - currentPos).Magnitude

        if dist > 8 then
            G.moveToTarget(myHRP, targetCF, dt)
        else
            
            State.currentFlyCF = targetCF
            pcall(function()
                myHRP.CFrame                  = targetCF
                myHRP.AssemblyLinearVelocity  = Vector3.zero
                myHRP.AssemblyAngularVelocity = Vector3.zero
            end)

            
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.CFrame    = CFrame.new(myHRP.Position, tgtHRP.Position)
            myHum.AutoRotate   = false
        end
    end)
end


function PVP.startSpectate()
    PVP.stopSpectate()
    if not PVP.targetPlayer then
        Fluent:Notify({ Title = "Spectate", Content = "Select a player first", Duration = 2 })
        return
    end

    PVP.spectating = true

    PVP.spectateConn = RunService.RenderStepped:Connect(function()
        if not PVP.spectating then
            PVP.stopSpectate()
            return
        end

        local tgtChar = PVP.targetPlayer and PVP.targetPlayer.Character
        local tgtHum  = tgtChar and tgtChar:FindFirstChildOfClass("Humanoid")
        local cam     = workspace.CurrentCamera

        if tgtHum then
            cam.CameraSubject = tgtHum
            cam.CameraType    = Enum.CameraType.Follow
        else
            cam.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            cam.CameraType    = Enum.CameraType.Follow
        end
    end)
end


local pvpPlayerList = PVP.getPlayerList()

local PvpPlayerDropdown
PvpPlayerDropdown = Tabs.Pvp:AddDropdown("PvpPlayerDropdown", {
    Title    = "Select Player",
    Values   = pvpPlayerList,
    Multi    = false,
    Default  = 1,
    Callback = function(value)
        PVP.targetPlayer = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == value then
                PVP.targetPlayer = p
                break
            end
        end
        Fluent:Notify({ Title = "PVP", Content = "Target: " .. tostring(value), Duration = 2 })
    end,
})

Tabs.Pvp:AddButton({
    Title    = "Refresh Player List",
    Callback = function()
        local newList = PVP.getPlayerList()
        pvpPlayerList  = newList
        pcall(function()
            if PvpPlayerDropdown and PvpPlayerDropdown.SetValues then
                PvpPlayerDropdown:SetValues(newList)
            end
        end)
        Fluent:Notify({ Title = "PVP", Content = "Refreshed: " .. #newList .. " players", Duration = 2 })
    end,
})

local GotoPlayerToggle
GotoPlayerToggle = Tabs.Pvp:AddToggle("GotoPlayerToggle", {
    Title       = "Go to Player",
    Description = "",
    Default     = false,
    Callback    = function(value)
        if value then
            local currentVal = PvpPlayerDropdown and PvpPlayerDropdown.Value
            if currentVal and currentVal ~= "(No players)" then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Name == currentVal then
                        PVP.targetPlayer = p
                        break
                    end
                end
            end

            if not PVP.targetPlayer then
                Fluent:Notify({ Title = "PVP", Content = "Selected player not found", Duration = 2 })
                pcall(function() GotoPlayerToggle:SetValue(false) end)
                return
            end

            PVP.startGoto()
            Fluent:Notify({ Title = "Go to Player", Content = "Chasing: " .. PVP.targetPlayer.Name, Duration = 2 })
        else
            PVP.stopGoto()
            Fluent:Notify({ Title = "Go to Player", Content = "Stopped", Duration = 2 })
        end
    end,
})

local SpectateToggle
SpectateToggle = Tabs.PvpSpectate:AddToggle("SpectateToggle", {
    Title       = "Spectate Player",
    Description = "",
    Default     = false,
    Callback    = function(value)
        if value then
            local currentVal = PvpPlayerDropdown and PvpPlayerDropdown.Value
            if currentVal and currentVal ~= "(No players)" then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Name == currentVal then
                        PVP.targetPlayer = p
                        break
                    end
                end
            end

            if not PVP.targetPlayer then
                Fluent:Notify({ Title = "Spectate", Content = "Selected player not found", Duration = 2 })
                pcall(function() SpectateToggle:SetValue(false) end)
                return
            end

            PVP.startSpectate()
            Fluent:Notify({ Title = "Spectate", Content = "Spectating: " .. PVP.targetPlayer.Name, Duration = 2 })
        else
            PVP.stopSpectate()
            Fluent:Notify({ Title = "Spectate", Content = "Stopped", Duration = 2 })
        end
    end,
})


Players.PlayerRemoving:Connect(function(p)
    if p == PVP.targetPlayer then
        PVP.stopGoto()
        PVP.stopSpectate()
        PVP.targetPlayer = nil
        pcall(function() GotoPlayerToggle:SetValue(false) end)
        pcall(function() SpectateToggle:SetValue(false) end)
        Fluent:Notify({ Title = "PVP", Content = p.Name .. " left the game", Duration = 3 })
    end
end)



TimeZone = P(Tabs.InfoServer, "Time Zone", "Your local date, time and region code.")

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

GameTime = P(Tabs.InfoServer, "Game Time", "Server uptime (how long this server has been alive).")

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

FullMoonCheck = P(Tabs.InfoServer, "Full Moon", "Moon phase 0/5 - 5/5. Full Moon is needed Wait.")

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



MirageCheck = P(Tabs.InfoIsland, "Mirage Island", "Random island used for Mystic Droplet and Full Moon items.")

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

KitsuneCheck = P(Tabs.InfoIsland, "Kitsune Island", "Rare island where Kitsune fruit and Kitsune quests spawn.")

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

PrehistoricCheck = P(Tabs.InfoIsland, "Prehistoric Island", "Third Sea island with dinosaurs and Primal Egg drops.")

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

FrozenCheck = P(Tabs.InfoIsland, "Frozen Dimension", "Limited dimension used for the Winter / Ice related farm.")

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



AwakenBossCheck = P(Tabs.InfoBoss, "Awaken Boss", "Status: Checking...\nNext raid hint from the server (boss name + island).")

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

CakePrinceStatus = P(Tabs.InfoBoss, "Cake Prince", "Cake Prince door progress. Needs 500 kills to open.")

spawn(function()
    while task.wait(1) do
        local ok, result = pcall(function()
            return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")
        end)

        local killStatus = "Status: Unknown"

        local bossAlive = false
        pcall(function()
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, mob in ipairs(enemies:GetChildren()) do
                    if mob.Name == "Cake Prince" then
                        local hum = mob:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            bossAlive = true
                        end
                    end
                end
            end
        end)

        if bossAlive then
            killStatus = "Boss Spawn! (Cake Prince alive)"
        elseif ok and type(result) == "string" then
            local remaining = result:match("<Color=Yellow>(%d+)<Color=/>")
            if remaining then
                local remaining_num = tonumber(remaining)
                local killed = 500 - remaining_num
                if remaining_num <= 0 then
                    killStatus = "Can Spawn! (500/500)"
                else
                    killStatus = "Killed: " .. killed .. "/500 (left " .. remaining_num .. ")"
                end
            else
                killStatus = "Boss Spawn!"
            end
        end

        CakePrinceStatus:SetDesc(killStatus)
    end
end)

RipIndraCheck = P(Tabs.InfoBoss, "Rip Indra", "True Form raid boss in Third Sea. Spawned = he is alive in this server.")

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

DoughKingCheck = P(Tabs.InfoBoss, "Dough King", "Dough raid boss. Spawned = he is alive in this server.")

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


TyrantEyeCheck = P(Tabs.InfoTyrant, "Eye Check", "Eyes: Checking...")

G.previousEyeSummary = ""

task.spawn(function()
	while task.wait(1) do
		pcall(function()
			local eyes = {}
			if TyrantSky and TyrantSky.getEyes then
				eyes = TyrantSky.getEyes()
			end

			local lit = 0
			for index = 1, 4 do
				local eye = eyes[index]
				if eye and eye.Parent and eye:IsA("BasePart") and eye.Transparency < 0.5 then
					lit += 1
				end
			end

			local summary = "Eyes: " .. lit .. "/4"
			if summary ~= G.previousEyeSummary then
				TyrantEyeCheck:SetDesc(summary)
				G.previousEyeSummary = summary
			end
		end)
	end
end)



LegendarySwordCheck = P(Tabs.InfoItem, "Legendary Sword", "Which legendary sword the dealer is selling right now.")

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

BoneCount = P(Tabs.InfoItem, "Bone", "Bones you own, used for Soul Guitar and Cursed Dual Katana.")

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
	Frame.Size = UDim2.new(0, 530, 0, 45)
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

    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Parent = Frame
    SpeedLabel.Size = UDim2.new(0, 105, 1, -10)
    SpeedLabel.Position = UDim2.new(0, 418, 0, 5)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.Font = Enum.Font.GothamBlack
    SpeedLabel.TextSize = 13
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Center
    SpeedLabel.TextYAlignment = Enum.TextYAlignment.Center
    SpeedLabel.Text = "0 st/s | 0 km/h"
    SpeedLabel.ZIndex = -7
    SpeedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    SpeedLabel.TextStrokeTransparency = 0.3
    local SpeedLabelGrad = Instance.new("UIGradient")
    SpeedLabelGrad.Color = Grad.Stroke
    SpeedLabelGrad.Rotation = 0
    SpeedLabelGrad.Parent = SpeedLabel
    table.insert(LabelGradients, SpeedLabelGrad)

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

    local Divider4 = Instance.new("Frame")
    Divider4.Parent = Frame
    Divider4.Size = UDim2.new(0, 1, 0.6, 0)
    Divider4.Position = UDim2.new(0, 413, 0.2, 0)
    Divider4.BackgroundColor3 = StrokeColor3
    Divider4.BackgroundTransparency = 0
    Divider4.BorderSizePixel = 0
    Divider4.ZIndex = -7
    local DividerGradient4 = Instance.new("UIGradient")
    DividerGradient4.Color = Grad.Stroke
    DividerGradient4.Rotation = 0
    DividerGradient4.Parent = Divider4
    table.insert(DividerFrames, Divider4)
    table.insert(DividerGradients, DividerGradient4)

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
    local LastPos = nil
    local LastPosTime = tick()
    local CurrentSpeedStuds = 0
    local LastSpeedUpdate = 0 
	local LastUpdateTime = tick()
	local FrameCount = 0

	FpsData.Connection = RunService.RenderStepped:Connect(function()
		FrameCount = FrameCount + 1
		local Now = tick()
		local Dt = Now - LastUpdateTime

		pcall(function()
			local char = game:GetService("Players").LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local nowPos = hrp.Position
				local nowTime = tick()
				if LastPos then
					local dt2 = nowTime - LastPosTime
					if dt2 > 0 then
						CurrentSpeedStuds = (nowPos - LastPos).Magnitude / dt2
					end
				end
				LastPos = nowPos
				LastPosTime = nowTime
			end
		end)

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

		local SpeedUpdateInterval = 0.1
		if Now - (LastSpeedUpdate or 0) >= SpeedUpdateInterval then
			LastSpeedUpdate = Now
			local kmh = math.round(CurrentSpeedStuds * 0.28 * 3.6)
			local sts = math.round(CurrentSpeedStuds)
			SpeedLabel.Text = string.format("%d st/s | %d km/h", sts, kmh)
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




local AutoDungeon = {
	enabled = false,
	PLACE_ID = 73902483975735,
	IGNORE = { ["Blank Buddy"] = true },
	PRIORITY = { ["PropHitboxPlaceholder"] = true },
	lastRoom = 0,
	waiting = false,
	returning = false,
	conn = nil,
	deathConn = nil,
	charConn = nil,
	currentTarget = nil,
	OFFSET_Z = 10,
	LOCK_DISTANCE = 60,
	lastAttackTime = 0,
}
G.AutoDungeon = AutoDungeon

local ADRun = game:GetService("RunService")

function AutoDungeon.getEnemies()
	local folder = workspace:FindFirstChild("Enemies")
	if not folder then return nil, nil end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil, nil end
	local prio, prioD = nil, math.huge
	local normal, normalD = nil, math.huge
	for _, mob in ipairs(folder:GetChildren()) do
		if not AutoDungeon.IGNORE[mob.Name] then
			local hum = mob:FindFirstChildOfClass("Humanoid")
			local root = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
			if hum and root and hum.Health > 0 then
				local d = (root.Position - hrp.Position).Magnitude
				if AutoDungeon.PRIORITY[mob.Name] then
					if d < prioD then prioD, prio = d, mob end
				elseif d < normalD then
					normalD, normal = d, mob
				end
			end
		end
	end
	return prio or normal, (prio ~= nil)
end

function AutoDungeon.getRooms()
	local dungeon = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Dungeon")
	if not dungeon then return {} end
	local rooms = {}
	for _, model in ipairs(dungeon:GetChildren()) do
		local num = tonumber(model.Name)
		if num then table.insert(rooms, { num = num, model = model }) end
	end
	table.sort(rooms, function(a, b) return a.num < b.num end)
	return rooms
end

function AutoDungeon.getCurrentRoom()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local best, bestD = nil, math.huge
	for _, room in ipairs(AutoDungeon.getRooms()) do
		local ok, cf = pcall(function() return room.model:GetPivot() end)
		if ok and cf then
			local d = (cf.Position - hrp.Position).Magnitude
			if d < bestD then bestD, best = d, room end
		end
	end
	return best
end

function AutoDungeon.getExitCF(room)
	if not room or not room.model then return nil end
	local exit = room.model:FindFirstChild("ExitTeleporter", true)
	if not exit then return nil end
	local ok, cf = pcall(function()
		if exit:IsA("BasePart") then return exit.CFrame end
		return exit:GetPivot()
	end)
	if not ok or not cf then return nil end
	return CFrame.new(cf.Position + Vector3.new(0, 5, 0))
end


AutoDungeon._antiGrav = nil
AutoDungeon._bodyGyro = nil

function AutoDungeon.getOrCreateMovers(root)
	local ag = root:FindFirstChild("DungeonAntiGrav")
	if not ag then
		ag = Instance.new("BodyForce")
		ag.Name = "DungeonAntiGrav"
		ag.Parent = root
	end
	ag.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity, 0)
	AutoDungeon._antiGrav = ag

	local bg = root:FindFirstChild("DungeonBodyGyro")
	if not bg then
		bg = Instance.new("BodyGyro")
		bg.Name = "DungeonBodyGyro"
		bg.MaxTorque = Vector3.zero
		bg.P = 50000
		bg.D = 1500
		bg.Parent = root
	end
	AutoDungeon._bodyGyro = bg
	return ag, bg
end

function AutoDungeon.destroyMovers()
	if AutoDungeon._antiGrav and AutoDungeon._antiGrav.Parent then
		AutoDungeon._antiGrav:Destroy()
	end
	AutoDungeon._antiGrav = nil
	if AutoDungeon._bodyGyro and AutoDungeon._bodyGyro.Parent then
		AutoDungeon._bodyGyro:Destroy()
	end
	AutoDungeon._bodyGyro = nil

	local char = player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local ag2 = root:FindFirstChild("DungeonAntiGrav")
			if ag2 then ag2:Destroy() end
			local bg2 = root:FindFirstChild("DungeonBodyGyro")
			if bg2 then bg2:Destroy() end
		end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = true end
	end
end

function AutoDungeon.doAttack(char, target, hrp, bg)
    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso")
    if not root then return end

    if bg then
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = CFrame.new(hrp.Position, root.Position)
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = false end

    if State.bringMobEnabled then
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        local targetHum = target:FindFirstChildOfClass("Humanoid")
        if targetRoot and targetHum and targetHum.Health > 0 then
            G.updateBringMobs(target, tick())
        end
    end

    G.autoEquipWeapon()

    local now = tick()
    if now - AutoDungeon.lastAttackTime < State.ATTACK_RATE then return end
    AutoDungeon.lastAttackTime = now

    local currentTool = char:FindFirstChildOfClass("Tool")
    local isFruit = false
    if currentTool then
        local hasLeftClick = currentTool:FindFirstChild("LeftClickRemote", true)
        if hasLeftClick then isFruit = true end
        if not isFruit then
            local tooltip = G.getToolTooltip(currentTool):lower()
            local toolName = currentTool.Name:lower()
            if tooltip:find("fruit") or toolName:find("fruit")
            or tooltip:find("devil") or toolName:find("devil") then
                isFruit = true
            end
        end
    end

    if isFruit then
        local remote = currentTool and currentTool:FindFirstChild("LeftClickRemote", true)
        local targetPos = root.Position
        if remote and targetPos and not G.fruitAttackBusy then
            G.fruitAttackBusy = true
            local capturedPos = targetPos
            local capturedHrp = hrp
            task.spawn(function()
                local dir = (capturedPos - capturedHrp.Position)
                dir = Vector3.new(dir.X, 0, dir.Z)
                local mag = dir.Magnitude
                local direction = mag > 0.01 and (dir / mag) or capturedHrp.CFrame.LookVector
                for action = 1, 4 do
                    if not remote or not remote.Parent then break end
                    pcall(function() remote:FireServer(direction, action) end)
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

function AutoDungeon.step(dt)
	if not AutoDungeon.enabled then return end

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return end

	
	local ag, bg = AutoDungeon.getOrCreateMovers(hrp)
	ag.Force = Vector3.new(0, hrp.AssemblyMass * workspace.Gravity, 0)

	
	G.applyNoclip(char)

	
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	
	local room = AutoDungeon.getCurrentRoom()
	if room and room.num > AutoDungeon.lastRoom then
		AutoDungeon.lastRoom = room.num
	end
	if AutoDungeon.returning and room and room.num >= AutoDungeon.lastRoom then
		AutoDungeon.returning = false
	end

	
	local target = AutoDungeon.getEnemies()

	if target then
		AutoDungeon.waiting = false
		local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Torso")
		if root then
			if AutoDungeon.currentTarget ~= target then
				AutoDungeon.currentTarget = target
				
				State.currentFlyCF = hrp.CFrame
			end

			
			local goalCF = root.CFrame * CFrame.new(0, State.Y_OFFSET, AutoDungeon.OFFSET_Z)
			local dist = (goalCF.Position - hrp.Position).Magnitude

			if dist <= AutoDungeon.LOCK_DISTANCE then
				
				State.currentFlyCF = goalCF
				pcall(function()
					hrp.CFrame = goalCF
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
				end)
				
				AutoDungeon.doAttack(char, target, hrp, bg)
			else
				
				
				bg.MaxTorque = Vector3.zero
				hum.AutoRotate = true
				G.moveToTarget(hrp, goalCF, dt)
			end
		end
		return
	end

	
	AutoDungeon.currentTarget = nil
	bg.MaxTorque = Vector3.zero
	hum.AutoRotate = true

	if AutoDungeon.waiting and not AutoDungeon.returning then
		
		if not State.currentFlyCF then
			State.currentFlyCF = hrp.CFrame
		end
		local anchorDist = (hrp.Position - State.currentFlyCF.Position).Magnitude
		if anchorDist > 2 then
			hrp.CFrame = State.currentFlyCF
		end
		return
	end

	
	local exitCF = AutoDungeon.getExitCF(room)
	if exitCF then
		local beforeRoom = room and room.num or -1
		local distToExit = (exitCF.Position - hrp.Position).Magnitude

		if distToExit > 4 then
			G.moveToTarget(hrp, exitCF, dt)
		else
			
			State.currentFlyCF = exitCF
			pcall(function()
				hrp.CFrame = exitCF
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		
		local nowRoom = AutoDungeon.getCurrentRoom()
		if nowRoom and nowRoom.num ~= beforeRoom then
			AutoDungeon.waiting = not AutoDungeon.returning
			State.currentFlyCF = hrp.CFrame
		end
	else
		
		if not State.currentFlyCF then
			State.currentFlyCF = hrp.CFrame
		end
		local anchorDist = (hrp.Position - State.currentFlyCF.Position).Magnitude
		if anchorDist > 2 then
			hrp.CFrame = State.currentFlyCF
		end
	end
end

function AutoDungeon.hookCharacter(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	if AutoDungeon.deathConn then AutoDungeon.deathConn:Disconnect() end
	AutoDungeon.deathConn = hum.Died:Connect(function()
		if AutoDungeon.enabled then
			AutoDungeon.returning = true
			AutoDungeon.waiting = false
			State.currentFlyCF = nil
		end
	end)
end

function AutoDungeon.start()
	AutoDungeon.stop()
	AutoDungeon.enabled = true
	AutoDungeon.waiting = false
	AutoDungeon.returning = false
	AutoDungeon.currentTarget = nil
	AutoDungeon.lastRoom = 0
	AutoDungeon.lastAttackTime = 0
	State.currentFlyCF = nil

	
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then State.currentFlyCF = hrp.CFrame end

	if char then AutoDungeon.hookCharacter(char) end

	AutoDungeon.charConn = player.CharacterAdded:Connect(function(newChar)
		AutoDungeon.hookCharacter(newChar)
		task.wait(1.5)
		State.currentFlyCF = nil
		local newHrp = newChar:FindFirstChild("HumanoidRootPart")
		if newHrp then State.currentFlyCF = newHrp.CFrame end
	end)

	AutoDungeon.conn = ADRun.Heartbeat:Connect(function(dt)
		if not AutoDungeon.enabled then
			AutoDungeon.stop()
			return
		end
		pcall(AutoDungeon.step, dt)
	end)

	Fluent:Notify({ Title = "Auto Dungeon", Content = "Started - Flying mode enabled", Duration = 3 })
end

function AutoDungeon.stop()
	AutoDungeon.enabled = false
	if AutoDungeon.conn then AutoDungeon.conn:Disconnect(); AutoDungeon.conn = nil end
	if AutoDungeon.charConn then AutoDungeon.charConn:Disconnect(); AutoDungeon.charConn = nil end
	if AutoDungeon.deathConn then AutoDungeon.deathConn:Disconnect(); AutoDungeon.deathConn = nil end
	AutoDungeon.destroyMovers()
	AutoDungeon.currentTarget = nil
	State.currentFlyCF = nil
	G.clearBringMobs()
	G.restoreCollision()
	pcall(function() G.forceCleanGyro() end)
end

local isDungeonPlace = (game.PlaceId == 73902483975735)

Tabs.Dungeon:AddParagraph({
	Title = isDungeonPlace and "Dungeon Mode" or " Wrong Place",
	Content = isDungeonPlace
		and "PlaceId " .. game.PlaceId .. " | Ready"
		or "Feature Only PlaceId 73902483975735 \nPlaceId Here: " .. game.PlaceId,
})

local DungeonToggle
DungeonToggle = Tabs.Dungeon:AddToggle("AutoDungeonToggle", {
	Title = "Auto Dungeon",
	Description = isDungeonPlace and "" or "Only PlaceId 73902483975735",
	Default = false,
	Callback = function(Value)
		if not Value then
			AutoDungeon.stop()
			Fluent:Notify({ Title = "Auto Dungeon", Content = "Stopped", Duration = 2 })
			return
		end

		if not isDungeonPlace then
			Fluent:Notify({
				Title = "Auto Dungeon",
				Content = "Work for PlaceId 73902483975735 Only\nCurrent: " .. game.PlaceId,
				Duration = 4,
			})
			task.defer(function()
				pcall(function()
					DungeonToggle:SetValue(false)
				end)
			end)
			return
		end

		AutoDungeon.start()
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
		Fluent:SetTheme("KKKK Cyber Neon")
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
