-- getenv = function() return {
--	["Remove Death Effect"] = true,
--	["Lock Fps"] = { ["Enabled"] = true, ["FPS"] = 120 },
--	["White Screen"] = false,
--	["Boost FPS V1"] = false,
--	["Boost FPS V2"] = false,
--	["Hide Players"] = true,
-- } end

local config = getenv()
local Players, RunService, UIS, TweenService, StatsService, WS =
	game:GetService("Players"), game:GetService("RunService"),
	game:GetService("UserInputService"), game:GetService("TweenService"),
	game:GetService("Stats"), game:GetService("Workspace")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
if pg:FindFirstChild("IntegratedStatusHUD") then pg.IntegratedStatusHUD:Destroy() end
if player.Character and player.Character:FindFirstChild("ESP_SelfHL") then player.Character.ESP_SelfHL:Destroy() end

local MAX_PLAYERS = Players.MaxPlayers
local COMBAT_CAP  = 2800
local FPS_CAP     = config["Lock Fps"]["Enabled"] and config["Lock Fps"]["FPS"] or 60

if config["Lock Fps"]["Enabled"] then
	pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate = FPS_CAP end)
	pcall(function() setfpscap(FPS_CAP) end)
end

local boostV1Active = false
local hiddenParts, boostV1Conn = {}, nil

local function setMapVisibility(invisible)
	if invisible then
		hiddenParts = {}
		for _, v in ipairs(WS:GetDescendants()) do
			pcall(function()
				if v:IsA("BasePart") then
					hiddenParts[#hiddenParts + 1] = { obj = v, trans = v.Transparency }
					v.Transparency = 1
				end
			end)
		end
		if boostV1Conn then boostV1Conn:Disconnect() end
		boostV1Conn = WS.DescendantAdded:Connect(function(v)
			pcall(function() if v:IsA("BasePart") then v.Transparency = 1 end end)
		end)
	else
		if boostV1Conn then boostV1Conn:Disconnect(); boostV1Conn = nil end
		for _, d in ipairs(hiddenParts) do
			if d.obj and d.obj.Parent then d.obj.Transparency = d.trans end
		end
		hiddenParts = {}
	end
end

local boostV2Active  = false
local v2DescConn     = nil
local v2OrigSettings = {}

local function applyObjGraphic(obj)
	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
		obj.Enabled = false
	elseif obj:IsA("Explosion") then
		obj.BlastPressure = 1; obj.BlastRadius = 1; obj.Visible = false
	elseif obj:IsA("BasePart") and not obj:IsA("MeshPart") then
		obj.Material = Enum.Material.Plastic; obj.Reflectance = 0
	elseif obj:IsA("MeshPart") then
		obj.RenderFidelity = 2; obj.Reflectance = 0; obj.Material = Enum.Material.Plastic
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		obj.Transparency = 1
	elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
		obj.Enabled = false
	end
end

local function applyLowGraphic()
	local L = game:GetService("Lighting")
	v2OrigSettings.GlobalShadows  = L.GlobalShadows
	v2OrigSettings.FogEnd         = L.FogEnd
	v2OrigSettings.ShadowSoftness = L.ShadowSoftness
	L.GlobalShadows = false; L.FogEnd = 9e9; L.ShadowSoftness = 0
	pcall(function() sethiddenproperty(L, "Technology", 2) end)
	v2OrigSettings.QualityLevel = settings().Rendering.QualityLevel
	settings().Rendering.QualityLevel = 1
	pcall(function()
		v2OrigSettings.MeshPartDetailLevel = settings().Rendering.MeshPartDetailLevel
		settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
	end)
	local terrain = WS:FindFirstChildOfClass("Terrain")
	if terrain then
		v2OrigSettings.WaterWaveSize    = terrain.WaterWaveSize
		v2OrigSettings.WaterWaveSpeed   = terrain.WaterWaveSpeed
		v2OrigSettings.WaterReflectance = terrain.WaterReflectance
		v2OrigSettings.WaterTransparency= terrain.WaterTransparency
		terrain.WaterWaveSize = 0; terrain.WaterWaveSpeed = 0
		terrain.WaterReflectance = 0; terrain.WaterTransparency = 0
		pcall(function() sethiddenproperty(terrain, "Decoration", false) end)
	end
	for _, obj in ipairs(game:GetDescendants()) do pcall(applyObjGraphic, obj) end
	if v2DescConn then v2DescConn:Disconnect() end
	v2DescConn = game.DescendantAdded:Connect(function(obj)
		task.wait(0.3)
		if boostV2Active then pcall(applyObjGraphic, obj) end
	end)
end

local function removeLowGraphic()
	if v2DescConn then v2DescConn:Disconnect(); v2DescConn = nil end
	local L = game:GetService("Lighting")
	if v2OrigSettings.GlobalShadows  ~= nil then L.GlobalShadows  = v2OrigSettings.GlobalShadows  end
	if v2OrigSettings.FogEnd         ~= nil then L.FogEnd         = v2OrigSettings.FogEnd         end
	if v2OrigSettings.ShadowSoftness ~= nil then L.ShadowSoftness = v2OrigSettings.ShadowSoftness end
	pcall(function() settings().Rendering.QualityLevel = v2OrigSettings.QualityLevel or 5 end)
	pcall(function()
		if v2OrigSettings.MeshPartDetailLevel then
			settings().Rendering.MeshPartDetailLevel = v2OrigSettings.MeshPartDetailLevel
		end
	end)
	local terrain = WS:FindFirstChildOfClass("Terrain")
	if terrain then
		if v2OrigSettings.WaterWaveSize     ~= nil then terrain.WaterWaveSize     = v2OrigSettings.WaterWaveSize     end
		if v2OrigSettings.WaterWaveSpeed    ~= nil then terrain.WaterWaveSpeed    = v2OrigSettings.WaterWaveSpeed    end
		if v2OrigSettings.WaterReflectance  ~= nil then terrain.WaterReflectance  = v2OrigSettings.WaterReflectance  end
		if v2OrigSettings.WaterTransparency ~= nil then terrain.WaterTransparency = v2OrigSettings.WaterTransparency end
	end
	v2OrigSettings = {}
end

if config["Boost FPS V1"] then task.spawn(function() task.wait(2); boostV1Active = true; setMapVisibility(true) end) end
if config["Boost FPS V2"] then task.spawn(function() task.wait(2); boostV2Active = true; applyLowGraphic()    end) end

local hidePlayersActive    = config["Hide Players"]
local hiddenPlayersData    = {}
local hidePlayersConns     = {}

local function setPlayerVisibility(plr, visible)
	local char = plr.Character
	if not char then return end
	if not visible then
		if hiddenPlayersData[plr.UserId] then return end
		local partsData = {}
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				partsData[#partsData + 1] = { obj = part, trans = part.Transparency }
				part.Transparency = 1
			end
		end
		hiddenPlayersData[plr.UserId] = partsData
	else
		local data = hiddenPlayersData[plr.UserId]
		if not data then return end
		for _, d in ipairs(data) do
			if d.obj and d.obj.Parent then d.obj.Transparency = d.trans end
		end
		hiddenPlayersData[plr.UserId] = nil
	end
end

local function applyHidePlayers(active)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then setPlayerVisibility(p, not active) end
	end
end

local function toggleHidePlayers(active)
	hidePlayersActive = active
	applyHidePlayers(active)
	if active then
		if not hidePlayersConns.playerAdded then
			hidePlayersConns.playerAdded = Players.PlayerAdded:Connect(function(p)
				if p ~= player then task.wait(0.5); setPlayerVisibility(p, false) end
			end)
		end
		if not hidePlayersConns.characterAdded then
			hidePlayersConns.characterAdded = player.CharacterAdded:Connect(function()
				task.wait(0.5); applyHidePlayers(true)
			end)
		end
	else
		if hidePlayersConns.playerAdded    then hidePlayersConns.playerAdded:Disconnect();    hidePlayersConns.playerAdded    = nil end
		if hidePlayersConns.characterAdded then hidePlayersConns.characterAdded:Disconnect(); hidePlayersConns.characterAdded = nil end
	end
end

if hidePlayersActive then task.spawn(function() task.wait(1); toggleHidePlayers(true) end) end

local function removeDeathEffect()
	pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local death = rs:WaitForChild("Effect", 10)
			:WaitForChild("Container", 10)
			:WaitForChild("Death", 10)
		if death then death:Destroy() end
	end)
end
if config["Remove Death Effect"] then
	removeDeathEffect()
	player.CharacterAdded:Connect(function() task.wait(0.5); removeDeathEffect() end)
end

local statCache = {}

local STAT_PATHS = {
	Level      = { "leaderstats.Level", "leaderstats.Lv.", "Data.Level" },
	Beli       = { "leaderstats.Beli",  "leaderstats.Money", "Data.Beli" },
	Fragments  = { "leaderstats.Fragments", "leaderstats.Fragment", "Data.Fragments" },
	Melee      = { "leaderstats.Melee",   "Data.Stats.Melee.Level" },
	Defense    = { "leaderstats.Defense", "Data.Stats.Defense.Level" },
	Sword      = { "leaderstats.Sword",   "Data.Stats.Sword.Level" },
	Gun        = { "leaderstats.Gun",     "Data.Stats.Gun.Level" },
	["Blox Fruit"] = { "leaderstats.Blox Fruit", "leaderstats.Demon Fruit", "Data.Stats.Blox Fruit.Level", "Data.Stats.Demon Fruit.Level" },
	Bounty     = { "leaderstats.Bounty/Honor", "leaderstats.Bounty", "leaderstats.Honor" },
	SpawnPoint = { "Data.LastSpawnPoint" },
}

local function resolvePath(root, path)
	local obj = root
	for part in path:gmatch("[^%.]+") do
		if not obj then return nil end
		obj = obj:FindFirstChild(part)
	end
	if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue")) then
		return obj
	end
	return nil
end

local function getStatObj(plr, key)
	local uid = plr.UserId
	if not statCache[uid] then statCache[uid] = {} end
	local cached = statCache[uid][key]
	if cached ~= nil then return cached end

	local paths = STAT_PATHS[key]
	if not paths then paths = { "leaderstats." .. key, "Data." .. key } end
	for _, path in ipairs(paths) do
		local obj = resolvePath(plr, path)
		if obj then
			statCache[uid][key] = obj
			return obj
		end
	end
	statCache[uid][key] = false
	return false
end

Players.PlayerRemoving:Connect(function(p) statCache[p.UserId] = nil end)

local function getStat(key, root)
	local obj = getStatObj(root or player, key)
	return obj and obj.Value or nil
end

local function formatVal(v, key)
	if type(v) ~= "number" then return tostring(v or "?") end
	if key == "Beli" or key == "Fragments" or key == "Level" then
		return tostring(math.floor(v)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end
	if     v >= 1e6 then return ("%.1fM"):format(v / 1e6)
	elseif v >= 1e3 then return ("%.1fK"):format(v / 1e3)
	else                 return tostring(math.floor(v)) end
end

local function fmtComma(n)
	if type(n) ~= "number" then return "?" end
	return tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local STUDS_TO_M = 0.28
local playerInfoCache = {}

local function refreshPlayerInfo(p)
	if p == player then return end
	local uid = p.UserId
	local info = playerInfoCache[uid] or {}

	-- Race
	pcall(function()
		local dataF = p:FindFirstChild("Data")
		if not dataF then return end
		local raceObj = dataF:FindFirstChild("Race")
		if not raceObj then return end
		if raceObj:IsA("ValueBase") and raceObj.Value ~= "" then info.race = tostring(raceObj.Value) end
		local cObj = raceObj:FindFirstChild("C")
		if cObj and (cObj:IsA("NumberValue") or cObj:IsA("IntValue")) then info.raceTier = cObj.Value end
	end)

	-- Spawn
	pcall(function()
		local dataF = p:FindFirstChild("Data")
		if not dataF then return end
		local spawnObj = dataF:FindFirstChild("LastSpawnPoint")
		if spawnObj and spawnObj:IsA("StringValue") then info.spawn = spawnObj.Value end
	end)

	-- Bounty
	local bObj = getStatObj(p, "Bounty")
	info.bounty = bObj and bObj.Value or nil

	playerInfoCache[uid] = info
end

Players.PlayerRemoving:Connect(function(p) playerInfoCache[p.UserId] = nil end)

local VALID_STAT_TYPES = { Melee=true, Sword=true, Gun=true, ["Blox Fruit"]=true, Defense=true }

local function getToolStatType(toolObj)
	local tip = ""
	pcall(function() tip = toolObj.ToolTip or "" end)
	if VALID_STAT_TYPES[tip] then return tip end
	local found
	pcall(function()
		local t = toolObj:FindFirstChild("Type") or toolObj:FindFirstChild("WeaponType") or toolObj:FindFirstChild("StatType")
		if t and t:IsA("StringValue") and VALID_STAT_TYPES[t.Value] then found = t.Value end
	end)
	return found
end

local function getToolLevel(obj)
	local lv
	pcall(function()
		local lvObj = obj:FindFirstChild("Level") or obj:FindFirstChildOfClass("NumberValue") or obj:FindFirstChildOfClass("IntValue")
		if lvObj then lv = lvObj.Value end
	end)
	return lv
end

local function getEquippedItem()
	local char = player.Character
	if not char then return "None", nil end
	for _, obj in ipairs(char:GetChildren()) do
		if obj:IsA("Tool") then
			return obj.Name, getToolLevel(obj)
		end
	end
	return "None", nil
end

local function getInventory()
	local items = {}
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return items end
	for _, obj in ipairs(backpack:GetChildren()) do
		if obj:IsA("Tool") and obj.Name ~= "Tool" then
			local level = getToolLevel(obj)
			if level ~= nil then
				items[#items + 1] = { name = obj.Name, level = level, statType = getToolStatType(obj) }
			end
		end
	end
	return items
end
local function getRace(p)
	local raceName, tier
	pcall(function()
		local raceObj = p:FindFirstChild("Data") and p.Data:FindFirstChild("Race")
		if not raceObj then return end
		if raceObj:IsA("ValueBase") and raceObj.Value ~= "" then raceName = tostring(raceObj.Value) end
		for _, n in ipairs({ "C", "V", "Tier", "Level", "T" }) do
			local c = raceObj:FindFirstChild(n)
			if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then tier = c.Value; break end
		end
	end)
	return raceName, tier
end

local C = {
	BG      = Color3.fromRGB(6, 6, 6),
	PANEL   = Color3.fromRGB(10, 10, 10),
	SECT    = Color3.fromRGB(16, 16, 16),
	CARD    = Color3.fromRGB(22, 22, 22),
	HOVER   = Color3.fromRGB(32, 32, 32),
	HDR     = Color3.fromRGB(18, 18, 18),
	SEP     = Color3.fromRGB(50, 50, 50),
	BORDER  = Color3.fromRGB(70, 70, 70),
	BORDER2 = Color3.fromRGB(100, 100, 100),
	WHITE   = Color3.fromRGB(255, 255, 255),
	OFFWHITE= Color3.fromRGB(235, 235, 235),
	MUTED   = Color3.fromRGB(180, 180, 180),
	DIM     = Color3.fromRGB(140, 140, 140),
	SUCCESS = Color3.fromRGB(100, 220, 130),
	WARN    = Color3.fromRGB(255, 210, 80),
	DANGER  = Color3.fromRGB(255, 100, 100),
	FRIEND  = Color3.fromRGB(100, 180, 255),
	DIST    = Color3.fromRGB(180, 180, 255),
	V1COL   = Color3.fromRGB(80, 190, 255),
	V2COL   = Color3.fromRGB(255, 195, 60),
	BOUNTY  = Color3.fromRGB(255, 160, 60),
}

local HUD_W = 640
local HUD_H = 600
local PAD   = 10

local function mk(class, parent, props)
	local obj = Instance.new(class)
	if parent then obj.Parent = parent end
	if props then for k, v in pairs(props) do pcall(function() obj[k] = v end) end end
	return obj
end

local function corner(p, r) return mk("UICorner", p, { CornerRadius = UDim.new(0, r or 5) }) end
local function stroke(p, col, t) return mk("UIStroke", p, { Color = col or C.BORDER, Thickness = t or 1, Transparency = 0 }) end

local function lbl(parent, props)
	return mk("TextLabel", parent, {
		BackgroundTransparency = 1,
		Font                   = props.font  or Enum.Font.GothamBold,
		TextSize               = props.size  or 13,
		TextColor3             = props.color or C.OFFWHITE,
		Text                   = props.text  or "",
		Size                   = props.sz    or UDim2.new(1, 0, 0, 18),
		Position               = props.pos   or UDim2.new(0, 0, 0, 0),
		TextXAlignment         = props.align  or Enum.TextXAlignment.Left,
		TextYAlignment         = props.yalign or Enum.TextYAlignment.Center,
		TextTruncate           = props.trunc  or Enum.TextTruncate.None,
		ZIndex                 = props.z      or 2,
	})
end

local function dividerH(parent, y, w)
	mk("Frame", parent, { Size=UDim2.new(0, w or HUD_W-PAD*2, 0, 1), Position=UDim2.new(0, PAD, 0, y), BackgroundColor3=C.SEP, BorderSizePixel=0, ZIndex=3 })
end
local function dividerV(parent, x, h)
	mk("Frame", parent, { Size=UDim2.new(0, 1, 0, h or HUD_H-PAD*2), Position=UDim2.new(0, x, 0, PAD), BackgroundColor3=C.SEP, BorderSizePixel=0, ZIndex=3 })
end

local gui = mk("ScreenGui", pg, {
	Name="IntegratedStatusHUD", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=10,
})

local startPos = UDim2.new(0.5, -HUD_W/2, 0.5, -HUD_H/2)

local fullPanel = mk("Frame", gui, {
	Size=UDim2.new(0,HUD_W,0,HUD_H), Position=startPos,
	BackgroundColor3=C.PANEL, BackgroundTransparency=0, BorderSizePixel=0, ClipsDescendants=false,
})
stroke(fullPanel, C.BORDER2, 2); corner(fullPanel, 8)

local miniPanel = mk("Frame", gui, {
	Size=UDim2.new(0,HUD_W,0,40), Position=startPos,
	BackgroundColor3=C.PANEL, BackgroundTransparency=0, BorderSizePixel=0, Visible=false,
})
stroke(miniPanel, C.BORDER2, 2); corner(miniPanel, 5)

local loadOverlay = mk("Frame", gui, {
	Size=UDim2.new(0,HUD_W,0,HUD_H), Position=startPos,
	BackgroundColor3=C.BG, BackgroundTransparency=0, BorderSizePixel=0, ZIndex=50,
})
corner(loadOverlay, 8); stroke(loadOverlay, C.BORDER2, 2)

lbl(loadOverlay, { sz=UDim2.new(1,0,0,28), pos=UDim2.new(0,0,0.38,-14), size=16, color=C.WHITE, text="Account Info", align=Enum.TextXAlignment.Center, z=52 })
local loadStepLbl = lbl(loadOverlay, { sz=UDim2.new(1,-60,0,16), pos=UDim2.new(0,30,0.38,18), font=Enum.Font.Gotham, size=12, color=C.MUTED, text="Initializing...", align=Enum.TextXAlignment.Center, z=52 })
local loadTrackBg = mk("Frame", loadOverlay, { Size=UDim2.new(1,-60,0,3), Position=UDim2.new(0,30,0.38,40), BackgroundColor3=C.BORDER, BorderSizePixel=0, ZIndex=52 })
corner(loadTrackBg, 2)
local loadBarFill = mk("Frame", loadTrackBg, { Size=UDim2.new(0,0,1,0), BackgroundColor3=C.WHITE, BorderSizePixel=0, ZIndex=53 })
corner(loadBarFill, 2)
local loadPctLbl  = lbl(loadOverlay, { sz=UDim2.new(1,-60,0,14), pos=UDim2.new(0,30,0.38,48), font=Enum.Font.GothamBold, size=10, color=C.DIM, text="0%", align=Enum.TextXAlignment.Right, z=52 })

local isMini = false
local function setView(mini)
	isMini = mini
	fullPanel.Visible = not mini
	miniPanel.Visible = mini
end

-- Drag
local dragging, dragStart, dragStartPos = false, nil, nil
fullPanel.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging=true; dragStart=inp.Position; dragStartPos=fullPanel.Position
	end
end)
UIS.InputChanged:Connect(function(inp)
	if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
		local d  = inp.Position - dragStart
		local np = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset+d.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset+d.Y)
		fullPanel.Position = np; miniPanel.Position = np
		if loadOverlay and loadOverlay.Parent then loadOverlay.Position = np end
	end
end)
UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local HALF = HUD_W / 2
dividerV(fullPanel, HALF)
dividerH(fullPanel, HUD_H / 2)

local function statBlock(x, y, w, labelTxt, valInit, barColor)
	lbl(fullPanel, { sz=UDim2.new(0,w-4,0,12), pos=UDim2.new(0,x,0,y), size=9, color=C.DIM, text=labelTxt, z=4 })
	local vl = lbl(fullPanel, { sz=UDim2.new(0,w-4,0,17), pos=UDim2.new(0,x,0,y+12), size=13, color=C.OFFWHITE, text=valInit, trunc=Enum.TextTruncate.AtEnd, z=4 })
	local bf = nil
	if barColor then
		local barBg = mk("Frame", fullPanel, { Size=UDim2.new(0,w-8,0,3), Position=UDim2.new(0,x,0,y+31), BackgroundColor3=C.BORDER, BorderSizePixel=0, ZIndex=4 })
		corner(barBg, 1)
		bf = mk("Frame", barBg, { Size=UDim2.new(0,0,1,0), BackgroundColor3=barColor, BorderSizePixel=0, ZIndex=5 })
		corner(bf, 1)
	end
	return vl, bf
end

local Q1X=PAD;    local Q1Y=PAD;             local Q1W=HALF-PAD*2
local Q2X=HALF+PAD; local Q2Y=PAD;           local Q2W=HALF-PAD*2
local Q3X=PAD;    local Q3Y=HUD_H/2+PAD;     local Q3W=HALF-PAD*2
local Q4X=HALF+PAD; local Q4Y=HUD_H/2+PAD;  local Q4W=HALF-PAD*2

-- Avatar
local avatar = mk("ImageLabel", fullPanel, {
	Size=UDim2.new(0,56,0,56), Position=UDim2.new(0,Q1X,0,Q1Y),
	BackgroundColor3=C.CARD, BorderSizePixel=0, ZIndex=4,
})
stroke(avatar, C.BORDER2, 2); corner(avatar, 5)

local charLabel = lbl(fullPanel, { sz=UDim2.new(0,Q1W-64,0,18), pos=UDim2.new(0,Q1X+62,0,Q1Y),    size=13, color=C.WHITE,  text="Loading...", trunc=Enum.TextTruncate.AtEnd, z=4 })
local lvlLabel  = lbl(fullPanel, { sz=UDim2.new(0,Q1W-64,0,14), pos=UDim2.new(0,Q1X+62,0,Q1Y+20), size=11, color=C.MUTED, text="LV. 0", z=4 })
local onlineDot = mk("Frame", fullPanel, { Size=UDim2.new(0,8,0,8), Position=UDim2.new(0,Q1X+62,0,Q1Y+40), BackgroundColor3=C.SUCCESS, BorderSizePixel=0, ZIndex=4 })
corner(onlineDot, 4)
lbl(fullPanel, { sz=UDim2.new(0,60,0,12), pos=UDim2.new(0,Q1X+74,0,Q1Y+38), size=9, color=C.DIM, text="ONLINE", z=4 })

local function miniStatRow2(x, y, w, labelTxt, valTxt)
	lbl(fullPanel, { sz=UDim2.new(0,w,0,12), pos=UDim2.new(0,x,0,y), size=9, color=C.DIM, text=labelTxt, z=4 })
	local v = lbl(fullPanel, { sz=UDim2.new(0,w,0,14), pos=UDim2.new(0,x,0,y+12), size=12, color=C.OFFWHITE, text=valTxt, trunc=Enum.TextTruncate.AtEnd, z=4 })
	return v
end

local colW3       = math.floor(Q1W / 3)
local raceValLbl  = miniStatRow2(Q1X,             Q1Y+68, colW3-4, "RACE",  "???")
local teamValLbl  = miniStatRow2(Q1X+colW3,       Q1Y+68, colW3-4, "TEAM",  "N/A")
local spawnValLbl = miniStatRow2(Q1X+colW3*2,     Q1Y+68, colW3-4, "SPAWN", "???")

local fpsLabel  = lbl(fullPanel, { sz=UDim2.new(0,Q1W,0,16), pos=UDim2.new(0,Q1X,0,Q1Y+100), size=13, color=C.OFFWHITE, text="FPS 0",    z=4 })
local pingLabel = lbl(fullPanel, { sz=UDim2.new(0,Q1W,0,16), pos=UDim2.new(0,Q1X,0,Q1Y+118), size=13, color=C.OFFWHITE, text="PING 0ms", z=4 })
local timeLabel = lbl(fullPanel, { sz=UDim2.new(0,Q1W,0,14), pos=UDim2.new(0,Q1X,0,Q1Y+136), font=Enum.Font.Gotham, size=11, color=C.DIM, text="00:00:00", z=4 })

local function makeSmallBtn(x, y, w, h, txt, col, state)
	local btn = mk("TextButton", fullPanel, {
		Size=UDim2.new(0,w,0,h), Position=UDim2.new(0,x,0,y),
		BackgroundColor3=state and col or C.CARD, BorderSizePixel=0,
		Text=txt, TextColor3=state and C.BG or C.MUTED,
		TextSize=10, Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=4,
	})
	stroke(btn, C.BORDER2, 1); corner(btn, 4)
	return btn
end

local btnW  = math.floor((Q1W - 6) / 2)
local v1Btn   = makeSmallBtn(Q1X,          Q1Y+158, btnW, 20, config["Boost FPS V1"] and "V1 ON" or "V1 OFF", C.V1COL, config["Boost FPS V1"])
local v2Btn   = makeSmallBtn(Q1X+btnW+6,   Q1Y+158, btnW, 20, config["Boost FPS V2"] and "V2 ON" or "V2 OFF", C.V2COL, config["Boost FPS V2"])
local hideBtn = makeSmallBtn(Q1X,          Q1Y+182, btnW, 20, hidePlayersActive and "HIDE ON" or "HIDE OFF",   C.WHITE, hidePlayersActive)
local miniBtn = makeSmallBtn(Q1X+btnW+6,   Q1Y+182, btnW, 20, "MINIMIZE", C.CARD, false)
miniBtn.TextColor3 = C.MUTED

local capBox = mk("TextBox", fullPanel, {
	Size=UDim2.new(0,btnW-36,0,20), Position=UDim2.new(0,Q1X,0,Q1Y+206),
	BackgroundColor3=C.CARD, BorderSizePixel=0, Font=Enum.Font.Gotham, TextSize=11,
	TextColor3=C.WHITE, Text="", PlaceholderText=tostring(FPS_CAP), PlaceholderColor3=C.DIM, ZIndex=4,
})
stroke(capBox, C.BORDER2, 1); corner(capBox, 4)
local setCapBtn = makeSmallBtn(Q1X+btnW-30, Q1Y+206, 30, 20, "SET", C.WHITE, false)
setCapBtn.BackgroundColor3=C.WHITE; setCapBtn.TextColor3=C.BG

local function applyFpsCap()
	local num = tonumber(capBox.Text)
	if num and num > 0 then
		pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate = num end)
		pcall(function() setfpscap(num) end)
		FPS_CAP = num; capBox.Text = ""
	end
end
setCapBtn.MouseButton1Click:Connect(applyFpsCap)
capBox.FocusLost:Connect(function(enter) if enter then applyFpsCap() end end)

local statRowH     = 36
local beliLbl                    = statBlock(Q2X, Q2Y+0,         Q2W, "BELI",       "0")
local fragLbl                    = statBlock(Q2X, Q2Y+statRowH,  Q2W, "FRAGMENTS",  "0")
local meleeLbl, meleeBar         = statBlock(Q2X, Q2Y+statRowH*2,Q2W, "MELEE",      "0", C.V1COL)
local defLbl,   defBar           = statBlock(Q2X, Q2Y+statRowH*3,Q2W, "DEFENSE",    "0", C.V1COL)
local swordLbl, swordBar         = statBlock(Q2X, Q2Y+statRowH*4,Q2W, "SWORD",      "0", C.V1COL)
local gunLbl,   gunBar           = statBlock(Q2X, Q2Y+statRowH*5,Q2W, "GUN",        "0", C.V1COL)
local fruitLbl, fruitBar         = statBlock(Q2X, Q2Y+statRowH*6,Q2W, "BLOX FRUIT", "0", C.WARN)

lbl(fullPanel, { sz=UDim2.new(0,Q3W,0,12), pos=UDim2.new(0,Q3X,0,Q3Y), size=9, color=C.DIM, text="PLAYERS", z=4 })
local pcCountLbl = lbl(fullPanel, { sz=UDim2.new(0,100,0,18), pos=UDim2.new(0,Q3X,0,Q3Y+12), size=14, color=C.WHITE, text="? / "..MAX_PLAYERS, z=4 })

local serverBarBg = mk("Frame", fullPanel, { Size=UDim2.new(0,Q3W,0,3), Position=UDim2.new(0,Q3X,0,Q3Y+32), BackgroundColor3=C.BORDER, BorderSizePixel=0, ZIndex=4 })
corner(serverBarBg, 1)
local serverBarFill = mk("Frame", serverBarBg, { Size=UDim2.new(0,0,1,0), BackgroundColor3=C.WHITE, BorderSizePixel=0, ZIndex=5 })
corner(serverBarFill, 1)

local PM_ROW_H   = 46
local PM_SCROLL_H= HUD_H/2 - PAD*2 - 42
local playerScroll = mk("ScrollingFrame", fullPanel, {
	Size=UDim2.new(0,Q3W,0,PM_SCROLL_H), Position=UDim2.new(0,Q3X,0,Q3Y+38),
	BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
	ScrollBarImageColor3=C.BORDER2, CanvasSize=UDim2.new(0,0,0,0),
	AutomaticCanvasSize=Enum.AutomaticSize.Y, ClipsDescendants=true, ZIndex=3,
})
mk("UIListLayout", playerScroll, { Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder })
mk("UIPadding",    playerScroll, { PaddingBottom=UDim.new(0,2) })

local playerMiniRows = {}
local PM_MAX = 20
for i = 1, PM_MAX do
	local row = mk("Frame", playerScroll, {
		Size=UDim2.new(1,-4,0,PM_ROW_H), BackgroundColor3=C.CARD, BorderSizePixel=0, ZIndex=4, LayoutOrder=i, Visible=false,
	})
	stroke(row, C.BORDER2, 1); corner(row, 4)
	local nl = lbl(row, { sz=UDim2.new(1,-62,0,14),   pos=UDim2.new(0,6,0,2),    size=11, color=C.WHITE,   text="", trunc=Enum.TextTruncate.AtEnd, z=5 })
	local ll = lbl(row, { sz=UDim2.new(0,56,0,14),    pos=UDim2.new(1,-60,0,2),  size=10, color=C.MUTED,   text="", align=Enum.TextXAlignment.Right, z=5 })
	local rl = lbl(row, { sz=UDim2.new(0,100,0,12),   pos=UDim2.new(0,6,0,18),   font=Enum.Font.Gotham, size=9, color=C.FRIEND, text="", trunc=Enum.TextTruncate.AtEnd, z=5 })
	local sl = lbl(row, { sz=UDim2.new(0,100,0,12),   pos=UDim2.new(0,110,0,18), font=Enum.Font.Gotham, size=9, color=C.DIM,    text="", trunc=Enum.TextTruncate.AtEnd, z=5 })
	local bl = lbl(row, { sz=UDim2.new(0,120,0,12),   pos=UDim2.new(0,6,0,32),   font=Enum.Font.Gotham, size=9, color=C.BOUNTY, text="", trunc=Enum.TextTruncate.AtEnd, z=5 })
	local dl = lbl(row, { sz=UDim2.new(0,80,0,12),    pos=UDim2.new(1,-84,0,32), font=Enum.Font.Gotham, size=9, color=C.DIST,   text="", align=Enum.TextXAlignment.Right, z=5 })
	playerMiniRows[i] = { row=row, nameLbl=nl, lvlLbl=ll, raceLbl=rl, spawnLbl=sl, bountyLbl=bl, distLbl=dl }
end

lbl(fullPanel, { sz=UDim2.new(0,Q4W,0,12), pos=UDim2.new(0,Q4X,0,Q4Y),    size=9,  color=C.DIM,     text="EQUIPPED", z=4 })
local equipValLbl = lbl(fullPanel, { sz=UDim2.new(0,Q4W,0,17), pos=UDim2.new(0,Q4X,0,Q4Y+12), size=13, color=C.OFFWHITE, text="None", trunc=Enum.TextTruncate.AtEnd, z=4 })
local equipLvlLbl = lbl(fullPanel, { sz=UDim2.new(0,Q4W,0,13), pos=UDim2.new(0,Q4X,0,Q4Y+30), font=Enum.Font.GothamBold, size=10, color=C.WARN, text="", z=4 })
lbl(fullPanel, { sz=UDim2.new(0,Q4W,0,12), pos=UDim2.new(0,Q4X,0,Q4Y+48), size=9,  color=C.DIM,     text="INVENTORY", z=4 })

local INV_ROW_H   = 26
local INV_SCROLL_H= HUD_H/2 - PAD - 62 - 2
local invScroll = mk("ScrollingFrame", fullPanel, {
	Size=UDim2.new(0,Q4W,0,INV_SCROLL_H), Position=UDim2.new(0,Q4X,0,Q4Y+62),
	BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
	ScrollBarImageColor3=C.BORDER2, CanvasSize=UDim2.new(0,0,0,0),
	AutomaticCanvasSize=Enum.AutomaticSize.Y, ClipsDescendants=true, ZIndex=3,
})
mk("UIListLayout", invScroll, { Padding=UDim.new(0,3), SortOrder=Enum.SortOrder.LayoutOrder })
mk("UIPadding",    invScroll, { PaddingBottom=UDim.new(0,2) })

local INV_MAX_ROWS = 20
local invTextRows  = {}
for i = 1, INV_MAX_ROWS do
	local cell = mk("Frame", invScroll, {
		Size=UDim2.new(1,-4,0,INV_ROW_H), BackgroundColor3=C.CARD, BorderSizePixel=0, ZIndex=4, LayoutOrder=i, Visible=false,
	})
	stroke(cell, C.BORDER2, 1); corner(cell, 4)
	local nl = lbl(cell, { sz=UDim2.new(1,-64,0,INV_ROW_H),  pos=UDim2.new(0,8,0,0),   size=11, color=C.OFFWHITE, text="", trunc=Enum.TextTruncate.AtEnd, z=5 })
	local ll = lbl(cell, { sz=UDim2.new(0,58,0,INV_ROW_H),   pos=UDim2.new(1,-62,0,0), size=10, color=C.WARN,     text="", align=Enum.TextXAlignment.Right, z=5 })
	invTextRows[i] = { cell=cell, nameLbl=nl, lvlLbl=ll }
end

-- ===== Mini panel =====
local miniAva = mk("ImageLabel", miniPanel, { Size=UDim2.new(0,28,0,28), Position=UDim2.new(0,6,0,6), BackgroundColor3=C.CARD, BorderSizePixel=0, ZIndex=3 })
stroke(miniAva, C.BORDER2, 1); corner(miniAva, 4)
task.spawn(function()
	local ok, t = pcall(function() return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
	if ok and t then miniAva.Image = t end
end)
local miniNameLbl = lbl(miniPanel, { sz=UDim2.new(0,120,0,16), pos=UDim2.new(0,38,0,4),  size=12, color=C.WHITE, text="Loading...", z=3 })
local miniLvlLbl  = lbl(miniPanel, { sz=UDim2.new(0,90,0,12),  pos=UDim2.new(0,38,0,22), font=Enum.Font.Gotham, size=10, color=C.DIM, text="LV. 0", z=3 })

lbl(miniPanel, { sz=UDim2.new(0,50,0,12), pos=UDim2.new(0,170,0,4),  size=9, color=C.DIM, text="FPS",  z=3 })
local miniFpsLbl  = lbl(miniPanel, { sz=UDim2.new(0,80,0,16), pos=UDim2.new(0,170,0,20), size=12, color=C.WHITE, text="...", z=3 })
lbl(miniPanel, { sz=UDim2.new(0,50,0,12), pos=UDim2.new(0,270,0,4),  size=9, color=C.DIM, text="PING", z=3 })
local miniPingLbl = lbl(miniPanel, { sz=UDim2.new(0,80,0,16), pos=UDim2.new(0,270,0,20), size=12, color=C.WHITE, text="...", z=3 })
lbl(miniPanel, { sz=UDim2.new(0,50,0,12), pos=UDim2.new(0,370,0,4),  size=9, color=C.DIM, text="BELI", z=3 })
local miniBeliLbl = lbl(miniPanel, { sz=UDim2.new(0,100,0,16), pos=UDim2.new(0,370,0,20), size=12, color=C.WHITE, text="...", z=3 })

local expandBtn = mk("TextButton", miniPanel, {
	Size=UDim2.new(0,30,0,22), Position=UDim2.new(1,-36,0,9),
	BackgroundColor3=C.CARD, BorderSizePixel=0, Text="▼", TextColor3=C.MUTED,
	TextSize=12, Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=5,
})
stroke(expandBtn, C.BORDER2, 1); corner(expandBtn, 4)
expandBtn.MouseButton1Click:Connect(function() setView(false) end)

-- Button logic
v1Btn.MouseButton1Click:Connect(function()
	boostV1Active = not boostV1Active
	if boostV1Active then task.spawn(function() setMapVisibility(true)  end); v1Btn.Text="V1 ON"; v1Btn.BackgroundColor3=C.V1COL; v1Btn.TextColor3=C.BG
	else               task.spawn(function() setMapVisibility(false) end); v1Btn.Text="V1 OFF"; v1Btn.BackgroundColor3=C.CARD;  v1Btn.TextColor3=C.MUTED end
end)
v2Btn.MouseButton1Click:Connect(function()
	boostV2Active = not boostV2Active
	if boostV2Active then task.spawn(function() applyLowGraphic()   end); v2Btn.Text="V2 ON"; v2Btn.BackgroundColor3=C.V2COL; v2Btn.TextColor3=C.BG
	else               task.spawn(function() removeLowGraphic() end); v2Btn.Text="V2 OFF"; v2Btn.BackgroundColor3=C.CARD;  v2Btn.TextColor3=C.MUTED end
end)
hideBtn.MouseButton1Click:Connect(function()
	hidePlayersActive = not hidePlayersActive
	toggleHidePlayers(hidePlayersActive)
	hideBtn.Text = hidePlayersActive and "HIDE ON" or "HIDE OFF"
	hideBtn.BackgroundColor3 = hidePlayersActive and C.WHITE or C.CARD
	hideBtn.TextColor3 = hidePlayersActive and C.BG or C.MUTED
end)
miniBtn.MouseButton1Click:Connect(function() setView(true) end)

-- Blackout
local blackoutFrame = mk("Frame", gui, { Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0, BorderSizePixel=0, ZIndex=1, Visible=false })
local restoreBtn = mk("TextButton", gui, { Size=UDim2.new(0,96,0,32), AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-30), BackgroundColor3=C.WHITE, BorderSizePixel=0, Text="RESTORE", TextColor3=C.BG, Font=Enum.Font.GothamBold, TextSize=12, AutoButtonColor=false, Visible=false, ZIndex=51 })
local blackoutActive = false
local function setBlackout(state) blackoutActive=state; blackoutFrame.Visible=state; restoreBtn.Visible=state end
if config["White Screen"] then setBlackout(true) end
restoreBtn.MouseButton1Click:Connect(function() setBlackout(false) end)

-- Self highlight
local selfHL
local function applyHighlight(char)
	if selfHL and selfHL.Parent then selfHL:Destroy() end; selfHL = nil
	if not char then return end
	local hl = Instance.new("Highlight")
	hl.Name="ESP_SelfHL"; hl.FillColor=Color3.fromRGB(255,255,255)
	hl.OutlineColor=Color3.fromRGB(0,0,0); hl.FillTransparency=0.5
	hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee=char; hl.Parent=char; selfHL=hl
end
if player.Character then task.delay(0.5, function() applyHighlight(player.Character) end) end
player.CharacterAdded:Connect(function(char) task.wait(0.5); applyHighlight(char) end)

-- Avatar (full panel)
task.spawn(function()
	local ok, t = pcall(function() return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
	if ok and t then avatar.Image = t end
end)

local fps, frameCount, lastFpsTime = 0, 0, tick()
RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	if now - lastFpsTime >= 0.5 then
		fps = math.floor(frameCount / (now - lastFpsTime))
		frameCount = 0; lastFpsTime = now
	end
end)

local function getPing()
	local ok, p = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"] end)
	return ok and type(p)=="number" and math.floor(p) or math.floor(player:GetNetworkPing()*1000)
end

local scriptStart = tick()

local lastText   = {}
local lastSize   = {}
local lastColor3 = {}

local function setText(lbl2, val)
	if lastText[lbl2] == val then return end
	lastText[lbl2] = val; lbl2.Text = val
end
local function setBarX(frame, scale)
	local s = math.clamp(scale, 0, 1)
	if lastSize[frame] == s then return end
	lastSize[frame] = s; frame.Size = UDim2.new(s, 0, 1, 0)
end
local function setColor(lbl2, col)
	if lastColor3[lbl2] == col then return end
	lastColor3[lbl2] = col; lbl2.TextColor3 = col
end

local function updateFast()
	local e    = tick() - scriptStart
	local ping = getPing()
	local fpsStr  = "FPS " .. fps
	local pingStr = "PING " .. ping .. "ms"
	local timeStr = ("%02d:%02d:%02d"):format(math.floor(e/3600), math.floor(e%3600/60), math.floor(e%60))

	setText(fpsLabel,  fpsStr)
	setText(pingLabel, pingStr)
	setText(timeLabel, timeStr)

	local pingCol = ping < 80 and C.SUCCESS or ping < 150 and C.WARN or C.DANGER
	setColor(pingLabel, pingCol)

	if miniFpsLbl  then setText(miniFpsLbl,  "FPS "..fps)    end
	if miniPingLbl then setText(miniPingLbl, ping.."ms")     end
	if miniBeliLbl then setText(miniBeliLbl, formatVal(getStat("Beli"), "Beli")) end

	capBox.PlaceholderText = tostring(FPS_CAP)
end

local function updateStats()
	local disp, name2 = player.DisplayName, player.Name
	local nameStr = disp ~= name2 and (disp .. " (@"..name2..")") or name2
	setText(charLabel, nameStr); setText(miniNameLbl, nameStr)

	local lv    = getStat("Level")
	local lvStr = "LV. " .. formatVal(lv, "Level")
	setText(lvlLabel, lvStr); setText(miniLvlLbl, lvStr)

	setText(beliLbl, formatVal(getStat("Beli"),      "Beli"))
	setText(fragLbl, formatVal(getStat("Fragments"), "Fragments"))

	local function doStat(valueLbl, bar, key)
		local v = getStat(key)
		setText(valueLbl, formatVal(v))
		if bar then setBarX(bar, tonumber(v) and tonumber(v)/COMBAT_CAP or 0) end
	end
	doStat(meleeLbl, meleeBar, "Melee")
	doStat(defLbl,   defBar,   "Defense")
	doStat(swordLbl, swordBar, "Sword")
	doStat(gunLbl,   gunBar,   "Gun")
	local fruitVal = getStat("Blox Fruit")
	setText(fruitLbl, formatVal(fruitVal))
	if fruitBar then setBarX(fruitBar, tonumber(fruitVal) and tonumber(fruitVal)/COMBAT_CAP or 0) end

	local rn, rt = getRace(player)
	setText(raceValLbl, rn and (rn .. (rt and " [V"..rt.."]" or "")) or "Not V4")
	setText(teamValLbl, player.Team and player.Team.Name or "N/A")
	local sp = getStat("SpawnPoint")
	setText(spawnValLbl, sp ~= nil and tostring(sp) or "??")
end

local INV_STAT_COLORS = {
	Sword        = C.SUCCESS,
	Gun          = C.FRIEND,
	["Blox Fruit"]= Color3.fromRGB(200, 140, 255),
	Defense      = C.DIST,
	Melee        = C.WARN,
}

local function updateInventory()
	local equipName, equipLv = getEquippedItem()
	setText(equipValLbl, equipName)
	if equipLv ~= nil then
		setText(equipLvlLbl, "LV " .. fmtComma(equipLv)); setColor(equipLvlLbl, C.WARN)
	else
		setText(equipLvlLbl, equipName ~= "None" and "No Level" or ""); setColor(equipLvlLbl, C.DIM)
	end

	local items = getInventory()
	for i = 1, INV_MAX_ROWS do
		local pf   = invTextRows[i]
		local item = items[i]
		if item then
			pf.cell.Visible = true
			local dispName = item.statType and ("[" .. item.statType .. "] " .. item.name) or item.name
			setText(pf.nameLbl, dispName)
			setColor(pf.nameLbl, INV_STAT_COLORS[item.statType] or C.OFFWHITE)
			setText(pf.lvlLbl, "LV " .. math.floor(item.level))
		else
			pf.cell.Visible = false
		end
	end
end

local function updatePlayers()
	local list  = Players:GetPlayers()
	local total = #list
	local ratio = math.clamp(total / MAX_PLAYERS, 0, 1)
	setText(pcCountLbl, total .. " / " .. MAX_PLAYERS)

	local barCol   = ratio >= 1 and C.DANGER or ratio >= 0.75 and C.WARN or C.WHITE
	serverBarFill.BackgroundColor3 = barCol
	setColor(pcCountLbl, barCol)
	setBarX(serverBarFill, ratio)

	for _, p in ipairs(list) do
		if p ~= player then
			refreshPlayerInfo(p)
		end
	end

	table.sort(list, function(a, b)
		if a == player then return true end
		if b == player then return false end
		return a.Name < b.Name
	end)

	for i = 1, PM_MAX do
		local pf = playerMiniRows[i]
		local p  = list[i]
		if p and pf then
			pf.row.Visible = true
			local nameStr = p.DisplayName ~= p.Name and (p.DisplayName .. " (@"..p.Name..")") or p.Name
			setText(pf.nameLbl, nameStr)
			setColor(pf.nameLbl, p == player and C.SUCCESS or C.WHITE)

			local plv = getStat("Level", p)
			setText(pf.lvlLbl, plv ~= nil and ("LV"..formatVal(plv,"Level")) or "LV??")

			if p ~= player then
				local info = playerInfoCache[p.UserId] or {}
				setText(pf.raceLbl,   info.race and ("Race: "..info.race..(info.raceTier and " V/T "..info.raceTier or "")) or "Race: ?")
				setText(pf.spawnLbl,  info.spawn and ("LOCATION: "..info.spawn) or "LOCATION: ?")
				setText(pf.bountyLbl, info.bounty ~= nil and ("Bounty: "..fmtComma(info.bounty)) or "Bounty: ?")

				local myC, thC = player.Character, p.Character
				local distStr = "?"
				if myC and thC then
					local myR = myC:FindFirstChild("HumanoidRootPart")
					local thR = thC:FindFirstChild("HumanoidRootPart")
					if myR and thR then
						local ok, mag = pcall(function() return (myR.Position - thR.Position).Magnitude end)
						if ok then distStr = fmtComma(math.floor(mag * STUDS_TO_M)) .. "m" end
					end
				end
				setText(pf.distLbl, distStr)
				setColor(pf.distLbl, C.DIST)
			else
				setText(pf.raceLbl, ""); setText(pf.spawnLbl, ""); setText(pf.bountyLbl, "")
				setText(pf.distLbl, "YOU"); setColor(pf.distLbl, C.SUCCESS)
			end
		elseif pf then
			pf.row.Visible = false
		end
	end
end

UIS.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.B           then setBlackout(not blackoutActive) end
	if inp.KeyCode == Enum.KeyCode.RightControl then setView(not isMini) end
end)

local LOAD_ELEMENTS = {
	{ "Loading account...",      avatar },
	{ "Loading username...",     charLabel },
	{ "Loading level...",        lvlLabel },
	{ "Loading beli...",         beliLbl },
	{ "Loading fragments...",    fragLbl },
	{ "Loading fruit...",        fruitLbl },
	{ "Loading melee stats...",  meleeLbl },
	{ "Loading defense...",      defLbl },
	{ "Loading sword...",        swordLbl },
	{ "Loading gun...",          gunLbl },
	{ "Loading equipped...",     equipValLbl },
	{ "Loading inventory...",    invTextRows[1] and invTextRows[1].cell },
	{ "Loading players...",      pcCountLbl },
	{ "Loading performance...",  fpsLabel },
}

local origTrans = {}

local function snapshotTrans(obj)
	if not obj then return nil end
	local snap = { bg=obj.BackgroundTransparency, children={} }
	for _, c in ipairs(obj:GetDescendants()) do
		local cd = {}
		if c:IsA("Frame") or c:IsA("ImageLabel") or c:IsA("TextLabel") or c:IsA("TextButton") then cd.bg = c.BackgroundTransparency end
		if c:IsA("TextLabel") or c:IsA("TextButton") then cd.text = c.TextTransparency end
		if c:IsA("ImageLabel") then cd.img = c.ImageTransparency end
		if c:IsA("UIStroke") then cd.stroke = c.Transparency end
		snap.children[c] = cd
	end
	return snap
end

local function hideElement(obj)
	if not obj then return end
	pcall(function() obj.BackgroundTransparency = 1 end)
	for _, c in ipairs(obj:GetDescendants()) do
		if c:IsA("Frame") or c:IsA("ImageLabel") or c:IsA("TextLabel") or c:IsA("TextButton") then pcall(function() c.BackgroundTransparency = 1 end) end
		if c:IsA("TextLabel") or c:IsA("TextButton") then pcall(function() c.TextTransparency = 1 end) end
		if c:IsA("ImageLabel") then pcall(function() c.ImageTransparency = 1 end) end
		if c:IsA("UIStroke") then pcall(function() c.Transparency = 1 end) end
	end
end

local function fadeIn(obj)
	local snap = origTrans[obj]
	if not snap then return end
	task.spawn(function()
		local s=tick(); local DUR=0.25
		while true do
			local r = math.min((tick()-s)/DUR, 1); local ease = r*r*(3-2*r); local inv = 1-ease
			if obj and obj.Parent then pcall(function() obj.BackgroundTransparency = snap.bg + (1-snap.bg)*inv end) end
			for c, cd in pairs(snap.children) do
				if c and c.Parent then
					if cd.bg     ~= nil then pcall(function() c.BackgroundTransparency = cd.bg    +(1-cd.bg)   *inv end) end
					if cd.text   ~= nil then pcall(function() c.TextTransparency       = cd.text  +(1-cd.text) *inv end) end
					if cd.img    ~= nil then pcall(function() c.ImageTransparency      = cd.img   +(1-cd.img)  *inv end) end
					if cd.stroke ~= nil then pcall(function() c.Transparency           = cd.stroke+(1-cd.stroke)*inv end) end
				end
			end
			if r >= 1 then break end
			RunService.Heartbeat:Wait()
		end
	end)
end

local loadTargets = {}
for _, item in ipairs(LOAD_ELEMENTS) do if item[2] then table.insert(loadTargets, item[2]) end end
for _, obj in ipairs(loadTargets) do origTrans[obj] = snapshotTrans(obj); hideElement(obj) end

task.spawn(function()
	local TOTAL    = #LOAD_ELEMENTS
	local STEP_DUR = 0.18
	local totalDur = TOTAL * STEP_DUR
	local done     = false

	task.spawn(function()
		for _, item in ipairs(LOAD_ELEMENTS) do
			loadStepLbl.Text = item[1]
			if item[2] then fadeIn(item[2]) end
			task.wait(STEP_DUR)
		end
		done = true
	end)

	local s = tick()
	repeat
		local elapsed = tick() - s
		local r    = math.min(elapsed / totalDur, 1)
		local ease = r*r*(3-2*r)
		if loadBarFill and loadBarFill.Parent then loadBarFill.Size = UDim2.new(ease, 0, 1, 0) end
		if loadPctLbl  and loadPctLbl.Parent  then loadPctLbl.Text  = math.floor(ease*100) .. "%" end
		if loadOverlay and loadOverlay.Parent  then loadOverlay.BackgroundTransparency = 0.05+0.15*ease end
		RunService.Heartbeat:Wait()
	until done

	if loadBarFill and loadBarFill.Parent then loadBarFill.Size = UDim2.new(1,0,1,0) end
	if loadPctLbl  and loadPctLbl.Parent  then loadPctLbl.Text  = "100%" end
	task.wait(0.1)

	if loadOverlay and loadOverlay.Parent then
		local startAlpha = loadOverlay.BackgroundTransparency
		local s2 = tick()
		while loadOverlay and loadOverlay.Parent do
			local r    = math.min((tick()-s2)/0.4, 1)
			local ease = r*r*(3-2*r)
			local a    = startAlpha + (1-startAlpha)*ease
			loadOverlay.BackgroundTransparency = a
			for _, c in ipairs(loadOverlay:GetDescendants()) do
				if c:IsA("TextLabel") or c:IsA("TextButton") then pcall(function() c.TextTransparency = ease end)
				elseif c:IsA("Frame") then pcall(function() c.BackgroundTransparency = a end)
				elseif c:IsA("UIStroke") then pcall(function() c.Transparency = ease end) end
			end
			if r >= 1 then break end
			RunService.Heartbeat:Wait()
		end
		if loadOverlay and loadOverlay.Parent then loadOverlay:Destroy() end
	end

	task.spawn(function()
		while true do
			updateFast()
			task.wait(0.15)
		end
	end)

	task.spawn(function()
		updateStats()
		updateInventory()
		while true do
			task.wait(0.5)
			updateStats()
			updateInventory()
		end
	end)

	task.spawn(function()
		updatePlayers()
		while true do
			task.wait(1.0)
			updatePlayers()
		end
	end)
end)
