--config = (function() return {
--	["Remove Death Effect"] = false,
--	["Lock Fps"]      = { ["Enabled"] = false, ["FPS"] = 120 },
--	["White Screen"]  = false,
--	["Boost FPS V1"]  = false,
--	["Boost FPS V2"]  = false,
--	["Hide Players"]  = false,
--	["Hide Enemies"]  = false,
--	["Auto Hop"]      = false,
--	["Hop Interval"]  = 45,
--	["Hop Server"]    = "singapore",
--	["Webhook Enabled"] = false,
--	["Webhook URL"]   = "",
--	["Webhook Name"]  = "Blox fruit Webhook",
--	["Webhook Interval"] = 30,
--} end)()

if not game:IsLoaded() then game.Loaded:Wait() end
while not game:GetService("Players").LocalPlayer do task.wait(0.1) end
while not game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") do task.wait(0.1) end

do
	local _pg = game:GetService("Players").LocalPlayer.PlayerGui
	for _, v in ipairs(_pg:GetChildren()) do
		if v.Name == "IntegratedStatusHUD" then v:Destroy() end
	end
end
_G.__FpsCheckRunning = nil
_G.__FpsCheckRunning = true

local Players = game:GetService("Players")
local Run     = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local Stats   = game:GetService("Stats")
local WS      = game:GetService("Workspace")
local player  = Players.LocalPlayer
local pg      = player:WaitForChild("PlayerGui")

if player.Character and player.Character:FindFirstChild("ESP_SelfHL") then
	player.Character.ESP_SelfHL:Destroy()
end

local C = {
	BG=Color3.fromRGB(6,6,6), PANEL=Color3.fromRGB(10,10,10),
	CARD=Color3.fromRGB(22,22,22), HOVER=Color3.fromRGB(32,32,32),
	SEP=Color3.fromRGB(50,50,50), BORDER=Color3.fromRGB(70,70,70),
	BORDER2=Color3.fromRGB(100,100,100), WHITE=Color3.fromRGB(255,255,255),
	OFFWHITE=Color3.fromRGB(235,235,235), MUTED=Color3.fromRGB(180,180,180),
	DIM=Color3.fromRGB(140,140,140), SUCCESS=Color3.fromRGB(100,220,130),
	WARN=Color3.fromRGB(255,210,80), DANGER=Color3.fromRGB(255,100,100),
	FRIEND=Color3.fromRGB(100,180,255), DIST=Color3.fromRGB(180,180,255),
	V1COL=Color3.fromRGB(80,190,255), V2COL=Color3.fromRGB(255,195,60),
	BOUNTY=Color3.fromRGB(255,160,60), HOP=Color3.fromRGB(255,80,180),
	FRAG=Color3.fromRGB(160,120,255),
	WEBHOOK=Color3.fromRGB(88,176,255),
	PULL=Color3.fromRGB(255,100,100),
}

local THEMES = {
	{name="Default", accent=Color3.fromRGB(255,255,255), accentDim=Color3.fromRGB(180,180,180), bg=Color3.fromRGB(6,6,6),   panel=Color3.fromRGB(10,10,10), card=Color3.fromRGB(22,22,22), hover=Color3.fromRGB(32,32,32), sep=Color3.fromRGB(50,50,50),  border=Color3.fromRGB(70,70,70),  border2=Color3.fromRGB(100,100,100), dim=Color3.fromRGB(140,140,140)},
	{name="Cyan",    accent=Color3.fromRGB(80,220,255),  accentDim=Color3.fromRGB(60,160,200),  bg=Color3.fromRGB(2,10,14), panel=Color3.fromRGB(4,16,22),  card=Color3.fromRGB(6,26,36),  hover=Color3.fromRGB(10,40,54),  sep=Color3.fromRGB(20,70,90), border=Color3.fromRGB(30,100,130),border2=Color3.fromRGB(50,160,200),  dim=Color3.fromRGB(80,160,190)},
	{name="Green",   accent=Color3.fromRGB(100,220,130), accentDim=Color3.fromRGB(70,160,100),  bg=Color3.fromRGB(4,12,6),  panel=Color3.fromRGB(6,18,10),  card=Color3.fromRGB(8,28,14),  hover=Color3.fromRGB(12,42,20),  sep=Color3.fromRGB(20,70,35), border=Color3.fromRGB(30,100,50), border2=Color3.fromRGB(50,160,80),   dim=Color3.fromRGB(80,160,100)},
	{name="Orange",  accent=Color3.fromRGB(255,160,60),  accentDim=Color3.fromRGB(200,120,40),  bg=Color3.fromRGB(14,8,2),  panel=Color3.fromRGB(20,12,4),  card=Color3.fromRGB(30,18,6),  hover=Color3.fromRGB(44,26,8),   sep=Color3.fromRGB(80,48,14), border=Color3.fromRGB(110,70,20), border2=Color3.fromRGB(180,110,40),  dim=Color3.fromRGB(180,120,60)},
	{name="Pink",    accent=Color3.fromRGB(255,120,180), accentDim=Color3.fromRGB(200,80,140),  bg=Color3.fromRGB(14,4,10), panel=Color3.fromRGB(20,6,14),  card=Color3.fromRGB(30,8,22),  hover=Color3.fromRGB(44,12,32),  sep=Color3.fromRGB(80,24,58), border=Color3.fromRGB(110,36,82), border2=Color3.fromRGB(180,70,130),  dim=Color3.fromRGB(180,90,140)},
	{name="Purple",  accent=Color3.fromRGB(180,120,255), accentDim=Color3.fromRGB(130,80,200),  bg=Color3.fromRGB(8,4,14),  panel=Color3.fromRGB(12,6,20),  card=Color3.fromRGB(18,8,32),  hover=Color3.fromRGB(28,12,48),  sep=Color3.fromRGB(50,22,90), border=Color3.fromRGB(70,36,120), border2=Color3.fromRGB(110,60,190),  dim=Color3.fromRGB(130,90,190)},
}
local curTheme = 1

local SKILL_KEYS = {"Z","X","C","V","F"}

local K = {
	MAX_PLAYERS  = Players.MaxPlayers,
	COMBAT_CAP   = 2800,
	STUDS_TO_M   = 0.28,
	SKILL_KEYS   = SKILL_KEYS,
	HUD_W = 640, HUD_H = 860, PAD = 10,
	MINI_W = 740,
	HISTORY_MAX = 60,
	HISTORY_INTERVAL = 10,
}
K.HALF = K.HUD_W / 2
K.Q1X = K.PAD;         K.Q1Y = K.PAD;             K.Q1W = K.HALF - K.PAD*2
K.Q2X = K.HALF+K.PAD;  K.Q2Y = K.PAD;             K.Q2W = K.HALF - K.PAD*2
K.Q3X = K.PAD;         K.Q3Y = K.HUD_H/2+K.PAD;  K.Q3W = K.HALF - K.PAD*2
K.Q4X = K.HALF+K.PAD;  K.Q4Y = K.HUD_H/2+K.PAD;  K.Q4W = K.HALF - K.PAD*2

local FPS_CAP = config["Lock Fps"]["Enabled"] and config["Lock Fps"]["FPS"] or 60
if config["Lock Fps"]["Enabled"] then
	pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate = FPS_CAP end)
	pcall(function() setfpscap(FPS_CAP) end)
end

local _cfgWHInterval = tonumber(config["Webhook Interval"]) or 30

local S = {
	skillCache = {},
	boostV1Active = false, hiddenParts = {}, boostV1Conn = nil,
	boostV2Active = false, v2DescConn = nil, v2Orig = {},
	hidePlayersActive = config["Hide Players"],
	hiddenPlayersData = {}, hidePlayersConns = {}, hideCharConns = {},
	hideEnemiesActive = config["Hide Enemies"],
	hiddenEnemyParts = {}, enemyDescConn = nil,
	autoHopActive = config["Auto Hop"],
	autoHopThread = nil,
	hopIntervalSecs = (config["Hop Interval"] or 30) * 60,
	hopTargetServer = (config["Hop Server"] or ""):lower(),
	hopCountdown = 0, hopLastTick = 0,
	totalHopCount = 0,
	webhookActive = config["Webhook Enabled"],
	webhookTimerActive    = false,
	webhookIntervalSecs   = _cfgWHInterval * 60,
	webhookTimerCountdown = _cfgWHInterval * 60,
	webhookTimerLastTick  = 0,
	webhookTimerThread    = nil,
	webhookTimerPopupOpen = false,
	totalWebhookCount     = 0,
	sessionStartBeli = nil, sessionStartFragments = nil, sessionInit = false,
	statCache = {},
	playerInfoCache = { [player.UserId] = { joinTime = tick() } },
	spawnWatchers = {}, raceWatchers = {}, bountyWatchers = {},
	beliHistory = {}, fragHistory = {},
	beliPerMin = 0, beliPerHour = 0,
	fragPerMin = 0, fragPerHour = 0,
	hopPopupOpen = false,
	fps = 0, frameCount = 0, lastFpsT = tick(),
	dragging = false, dragStart = nil, dragStartPos = nil,
	lastText = {}, lastSize = {}, lastColor = {},
	barTw = {}, colTw = {},
	blackoutActive = false,
	isMini = false,
	selfHL = nil,
	scriptStart = tick(),
}
S.hopCountdown  = S.hopIntervalSecs
S.hopLastTick   = tick()

-- BRING MOB STATE
local BM = {
	active       = false,
	task         = nil,
	mobData      = {},
	noclipConn   = nil,
	pinConn      = nil,
	maxDist      = 1000,
	maxBatch     = 20,
	pullForce    = 60000,
	snapDist     = 30,
	useCustomOff = false,
	customOffset = Vector3.new(0, 0, 0),
	yOffset      = -20,
}

local bmPinTick = 0

local V2_SKIP = {}

local function mk(cl, par, props)
	local o = Instance.new(cl)
	if par  then o.Parent = par end
	if props then for k,v in pairs(props) do pcall(function() o[k]=v end) end end
	return o
end
local function corner(p,r) return mk("UICorner",p,{CornerRadius=UDim.new(0,r or 5)}) end
local function stroke(p,col,t) return mk("UIStroke",p,{Color=col or C.BORDER,Thickness=t or 1,Transparency=0}) end
local function lbl(par, props)
	return mk("TextLabel", par, {
		BackgroundTransparency=1, Font=props.font or Enum.Font.GothamBold,
		TextSize=props.size or 13, TextColor3=props.color or C.OFFWHITE,
		Text=props.text or "", Size=props.sz or UDim2.new(1,0,0,18),
		Position=props.pos or UDim2.new(0,0,0,0),
		TextXAlignment=props.align or Enum.TextXAlignment.Left,
		TextYAlignment=props.yalign or Enum.TextYAlignment.Center,
		TextTruncate=props.trunc or Enum.TextTruncate.None, ZIndex=props.z or 2,
	})
end
local function tween(obj, props, dur)
	TS:Create(obj, TweenInfo.new(dur or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function fmtComma(n)
	if type(n)~="number" then return "?" end
	return tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end
local function formatVal(v, key)
	if type(v)~="number" then return tostring(v or "?") end
	if key=="Beli" or key=="Fragments" or key=="Level" then return fmtComma(v) end
	if v>=1e6 then return ("%.1fM"):format(v/1e6)
	elseif v>=1e3 then return ("%.1fK"):format(v/1e3)
	else return tostring(math.floor(v)) end
end
local function wFmt(n)
	if type(n)~="number" then return "?" end
	local s = n<0 and "-" or "+"
	return s..tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end
local function elapsedStr(s)
	s = math.max(0,math.floor(s))
	local h=math.floor(s/3600); s=s%3600
	local m=math.floor(s/60);   s=s%60
	if h>0 then return ("%dh %02dm %02ds"):format(h,m,s) end
	if m>0 then return ("%dm %02ds"):format(m,s) end
	return ("%ds"):format(s)
end
local function sessionTimeStr(jt)
	if not jt then return "Time: ?" end
	local e=math.floor(tick()-jt)
	local h=math.floor(e/3600); local m=math.floor((e%3600)/60); local s=e%60
	if h>0 then return ("In server: %dh %02dm %02ds"):format(h,m,s) end
	if m>0 then return ("In server: %dm %02ds"):format(m,s) end
	return ("In server: %ds"):format(s)
end
local function getTimestamp()
	local ok,str=pcall(function() return os.date("!%Y-%m-%dT%H:%M:%SZ") end)
	return (ok and str and str~="") and str or nil
end
local function getLocalTimeStr()
	local ok,str=pcall(function() return os.date("%Y-%m-%d %H:%M:%S") end)
	return ok and str or ("~"..math.floor(tick()))
end

local function pushHistory(tbl, val, maxLen)
	if type(val) ~= "number" then return end
	tbl[#tbl + 1] = { t = tick(), v = val }
	while #tbl > maxLen do table.remove(tbl, 1) end
end
local function calcRate(tbl)
	if #tbl < 2 then return 0, 0 end
	local oldest, newest = tbl[1], tbl[#tbl]
	local elapsedSec = newest.t - oldest.t
	if elapsedSec < 1 then return 0, 0 end
	local perMin = (newest.v - oldest.v) / (elapsedSec / 60)
	return math.floor(perMin), math.floor(perMin * 60)
end

local STAT_PATHS = {
	Level={"Data.Level","leaderstats.Level","leaderstats.Lv."},
	Beli={"Data.Beli","leaderstats.Beli","leaderstats.Money"},
	Fragments={"Data.Fragments","leaderstats.Fragments","leaderstats.Fragment"},
	Melee={"leaderstats.Melee","Data.Stats.Melee.Level"},
	Defense={"leaderstats.Defense","Data.Stats.Defense.Level"},
	Sword={"leaderstats.Sword","Data.Stats.Sword.Level"},
	Gun={"leaderstats.Gun","Data.Stats.Gun.Level"},
	["Blox Fruit"]={"leaderstats.Blox Fruit","leaderstats.Demon Fruit","Data.Stats.Blox Fruit.Level","Data.Stats.Demon Fruit.Level"},
	Bounty={"leaderstats.Bounty/Honor","leaderstats.Bounty","leaderstats.Honor"},
	SpawnPoint={"Data.LastSpawnPoint"},
}
local function resolvePath(root, path)
	local obj = root
	for part in path:gmatch("[^%.]+") do
		if not obj then return nil end
		local child = obj:FindFirstChild(part)
		if not child then
			local ok2, c2 = pcall(function() return obj:WaitForChild(part, 1) end)
			if ok2 and c2 then child = c2 end
		end
		if not child then return nil end
		obj = child
	end
	if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue")) then return obj end
	return nil
end
local function getStatObj(plr, key)
	local uid = plr.UserId
	if not S.statCache[uid] then S.statCache[uid]={} end
	local c = S.statCache[uid][key]
	if c and c ~= false then return c end
	local paths = STAT_PATHS[key] or {"leaderstats."..key,"Data."..key}
	for _, path in ipairs(paths) do
		local obj = resolvePath(plr, path)
		if obj then S.statCache[uid][key]=obj; return obj end
	end
	return nil
end
local function getStat(key, root)
	local obj = getStatObj(root or player, key)
	return obj and obj.Value or nil
end

local function setMapVisibility(hide)
	if hide then
		S.hiddenParts={}
		for _,v in ipairs(WS:GetDescendants()) do
			pcall(function()
				if v:IsA("BasePart") then S.hiddenParts[#S.hiddenParts+1]={obj=v,tr=v.Transparency}; v.Transparency=1 end
			end)
		end
		if S.boostV1Conn then S.boostV1Conn:Disconnect() end
		S.boostV1Conn = WS.DescendantAdded:Connect(function(v)
			pcall(function() if v:IsA("BasePart") then v.Transparency=1 end end)
		end)
	else
		if S.boostV1Conn then S.boostV1Conn:Disconnect(); S.boostV1Conn=nil end
		for _,d in ipairs(S.hiddenParts) do
			if d.obj and d.obj.Parent then d.obj.Transparency=d.tr end
		end
		S.hiddenParts={}
	end
end
local function buildV2Skip()
	V2_SKIP={}
	for _,sv in ipairs({pg,game:GetService("ReplicatedStorage"),Players,game:GetService("CoreGui")}) do V2_SKIP[sv]=true end
	if player.Character then V2_SKIP[player.Character]=true end
end
local function shouldSkip(obj)
	local c=obj.Parent; while c do if V2_SKIP[c] then return true end; c=c.Parent end; return false
end
local function applyObjGraphic(obj)
	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled=false
	elseif obj:IsA("Explosion") then obj.BlastPressure=1; obj.BlastRadius=1; obj.Visible=false
	elseif obj:IsA("BasePart") and not obj:IsA("MeshPart") then obj.Material=Enum.Material.Plastic; obj.Reflectance=0
	elseif obj:IsA("MeshPart") then obj.RenderFidelity=2; obj.Reflectance=0; obj.Material=Enum.Material.Plastic
	elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1
	elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then obj.Enabled=false end
end
local function applyEffectReduce(model)
	if not model then return end
	for _, obj in ipairs(model:GetDescendants()) do
		pcall(function()
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
				or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
			then
				obj.Enabled = false
				obj.Rate = 0
			elseif obj:IsA("Beam") then
				obj.Enabled = false
			elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
				obj.Enabled = false
			elseif obj:IsA("SelectionBox") or obj:IsA("SelectionSphere") then
				obj.Visible = false
			elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
				obj.Enabled = false
			end
		end)
	end
end
local function applyLowGraphic()
	buildV2Skip()
	local L = game:GetService("Lighting")

	S.v2Orig = {
		GlobalShadows    = L.GlobalShadows,
		FogEnd           = L.FogEnd,
		FogStart         = L.FogStart,
		ShadowSoftness   = L.ShadowSoftness,
		Brightness       = L.Brightness,
		Ambient          = L.Ambient,
		OutdoorAmbient   = L.OutdoorAmbient,
		ClockTime        = L.ClockTime,
		QualityLevel     = settings().Rendering.QualityLevel,
	}
	pcall(function() S.v2Orig.MeshDetail = settings().Rendering.MeshPartDetailLevel end)

	L.GlobalShadows  = false
	L.FogEnd         = 9e9
	L.FogStart       = 9e9
	L.ShadowSoftness = 0
	L.Brightness     = 0
	L.Ambient        = Color3.new(0.5, 0.5, 0.5)
	L.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
	L.ClockTime      = 14
	pcall(function() sethiddenproperty(L, "Technology", 2) end)
	settings().Rendering.QualityLevel = 1
	pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)

	local ter = WS:FindFirstChildOfClass("Terrain")
	if ter then
		S.v2Orig.WW = ter.WaterWaveSize
		S.v2Orig.WS = ter.WaterWaveSpeed
		S.v2Orig.WR = ter.WaterReflectance
		S.v2Orig.WT = ter.WaterTransparency
		ter.WaterWaveSize    = 0
		ter.WaterWaveSpeed   = 0
		ter.WaterReflectance = 0
		ter.WaterTransparency = 1
		pcall(function() sethiddenproperty(ter, "Decoration", false) end)
	end

	for _, child in ipairs(L:GetChildren()) do
		if child:IsA("PostEffect")
			or child:IsA("BloomEffect")
			or child:IsA("BlurEffect")
			or child:IsA("ColorCorrectionEffect")
			or child:IsA("DepthOfFieldEffect")
			or child:IsA("SunRaysEffect")
		then
			child.Enabled = false
		end
	end

	task.spawn(function()
		local effectFolders = {"Effects","Effect","VFX","Particles","SkillEffects"}
		for _, folderName in ipairs(effectFolders) do
			local folder = WS:FindFirstChild(folderName, true)
			if folder then applyEffectReduce(folder) end
		end

		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then applyEffectReduce(p.Character) end
			p.CharacterAdded:Connect(function(char)
				task.wait(0.1)
				if S.boostV2Active then applyEffectReduce(char) end
			end)
		end

		local ef = WS:FindFirstChild("Enemies")
		if ef then applyEffectReduce(ef) end
	end)

	if S.v2DescConn then S.v2DescConn:Disconnect() end
	S.v2DescConn = game.DescendantAdded:Connect(function(obj)
		if not S.boostV2Active or shouldSkip(obj) then return end
		pcall(function()
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
				or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
			then
				obj.Enabled = false
				obj.Rate = 0
			elseif obj:IsA("Beam") then
				obj.Enabled = false
			elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
				obj.Enabled = false
			elseif obj:IsA("BasePart") and obj:IsDescendantOf(WS) then
				obj.Material    = Enum.Material.SmoothPlastic
				obj.Reflectance = 0
				obj.CastShadow  = false
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 1
			elseif obj:IsA("SpecialMesh") then
				obj.TextureId = ""
			elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
				obj.Enabled = false
			end
		end)
	end)
end
local function removeLowGraphic()
	if S.v2DescConn then S.v2DescConn:Disconnect(); S.v2DescConn=nil end
	local L=game:GetService("Lighting")
	if S.v2Orig.GlobalShadows~=nil then L.GlobalShadows=S.v2Orig.GlobalShadows end
	if S.v2Orig.FogEnd~=nil then L.FogEnd=S.v2Orig.FogEnd end
	if S.v2Orig.ShadowSoftness~=nil then L.ShadowSoftness=S.v2Orig.ShadowSoftness end
	pcall(function() settings().Rendering.QualityLevel=S.v2Orig.QualityLevel or 5 end)
	pcall(function() if S.v2Orig.MeshDetail then settings().Rendering.MeshPartDetailLevel=S.v2Orig.MeshDetail end end)
	local ter=WS:FindFirstChildOfClass("Terrain")
	if ter then
		if S.v2Orig.WW~=nil then ter.WaterWaveSize=S.v2Orig.WW end
		if S.v2Orig.WS~=nil then ter.WaterWaveSpeed=S.v2Orig.WS end
		if S.v2Orig.WR~=nil then ter.WaterReflectance=S.v2Orig.WR end
		if S.v2Orig.WT~=nil then ter.WaterTransparency=S.v2Orig.WT end
	end
	S.v2Orig={}
end

local function setPlayerVis(plr, visible)
	local char=plr.Character; if not char then return end
	if not visible then
		if S.hiddenPlayersData[plr.UserId] then return end
		S.hiddenPlayersData[plr.UserId]=true; pcall(function() char:Destroy() end)
	else S.hiddenPlayersData[plr.UserId]=nil end
end
local function watchChar(p)
	if p==player then return end
	local uid=p.UserId
	if S.hideCharConns[uid] then S.hideCharConns[uid]:Disconnect() end
	S.hideCharConns[uid]=p.CharacterAdded:Connect(function()
		S.hiddenPlayersData[uid]=nil
		if S.hidePlayersActive then task.wait(0.5); setPlayerVis(p,false) end
	end)
end
local function toggleHidePlayers(active)
	S.hidePlayersActive=active
	for _,p in ipairs(Players:GetPlayers()) do if p~=player then setPlayerVis(p,not active) end end
	if active then
		for _,p in ipairs(Players:GetPlayers()) do if p~=player then watchChar(p) end end
		if not S.hidePlayersConns.pa then
			S.hidePlayersConns.pa=Players.PlayerAdded:Connect(function(p)
				if p==player then return end; watchChar(p)
				task.spawn(function()
					if not p.Character then p.CharacterAdded:Wait() end
					task.wait(0.5); if S.hidePlayersActive then setPlayerVis(p,false) end
				end)
			end)
		end
		if not S.hidePlayersConns.ca then
			S.hidePlayersConns.ca=player.CharacterAdded:Connect(function()
				task.wait(0.5)
				for _,p in ipairs(Players:GetPlayers()) do if p~=player then setPlayerVis(p,true) end end
			end)
		end
	else
		if S.hidePlayersConns.pa then S.hidePlayersConns.pa:Disconnect(); S.hidePlayersConns.pa=nil end
		if S.hidePlayersConns.ca then S.hidePlayersConns.ca:Disconnect(); S.hidePlayersConns.ca=nil end
		for uid,conn in pairs(S.hideCharConns) do conn:Disconnect(); S.hideCharConns[uid]=nil end
	end
end

local function setEnemyHide(part, hide)
	if hide then
		if S.hiddenEnemyParts[part]~=nil then return end
		S.hiddenEnemyParts[part]=part.Transparency; part.Transparency=1
	else
		if S.hiddenEnemyParts[part]==nil then return end
		if part and part.Parent then part.Transparency=S.hiddenEnemyParts[part] end
		S.hiddenEnemyParts[part]=nil
	end
end
local function toggleHideEnemies(active)
	S.hideEnemiesActive=active
	local ef=WS:FindFirstChild("Enemies"); if not ef then return end
	for _,obj in ipairs(ef:GetDescendants()) do if obj:IsA("BasePart") then pcall(setEnemyHide,obj,active) end end
	if active then
		if not S.enemyDescConn then
			S.enemyDescConn=ef.DescendantAdded:Connect(function(obj)
				if S.hideEnemiesActive and obj:IsA("BasePart") then task.wait(0.1); pcall(setEnemyHide,obj,true) end
			end)
		end
	else
		if S.enemyDescConn then S.enemyDescConn:Disconnect(); S.enemyDescConn=nil end
		for part,tr in pairs(S.hiddenEnemyParts) do if part and part.Parent then pcall(function() part.Transparency=tr end) end end
		S.hiddenEnemyParts={}
	end
end

local function watchPlayerData(p)
	if p==player then return end
	local uid=p.UserId
	if not S.playerInfoCache[uid] then S.playerInfoCache[uid]={joinTime=tick()} end
	task.spawn(function()
		local d=p:FindFirstChild("Data") or p:WaitForChild("Data",30); if not d then return end
		local sp=d:FindFirstChild("LastSpawnPoint") or d:WaitForChild("LastSpawnPoint",30); if not sp then return end
		S.playerInfoCache[uid].spawn=sp.Value
		if S.spawnWatchers[uid] then S.spawnWatchers[uid]:Disconnect() end
		S.spawnWatchers[uid]=sp.Changed:Connect(function(v) S.playerInfoCache[uid]=S.playerInfoCache[uid] or {}; S.playerInfoCache[uid].spawn=v end)
	end)
	task.spawn(function()
		local d=p:FindFirstChild("Data") or p:WaitForChild("Data",30); if not d then return end
		local rc=d:FindFirstChild("Race") or d:WaitForChild("Race",30); if not rc then return end
		S.playerInfoCache[uid].race=rc:IsA("ValueBase") and rc.Value~="" and tostring(rc.Value) or nil
		local cObj=rc:FindFirstChild("C")
		if cObj then S.playerInfoCache[uid].raceTier=cObj.Value end
		if S.raceWatchers[uid] then S.raceWatchers[uid]:Disconnect() end
		S.raceWatchers[uid]=rc.Changed:Connect(function(v) S.playerInfoCache[uid]=S.playerInfoCache[uid] or {}; if v~="" then S.playerInfoCache[uid].race=tostring(v) end end)
	end)
	task.spawn(function()
		local bObj=getStatObj(p,"Bounty")
		if not bObj then task.wait(3); bObj=getStatObj(p,"Bounty") end; if not bObj then return end
		S.playerInfoCache[uid].bounty=bObj.Value
		if S.bountyWatchers[uid] then S.bountyWatchers[uid]:Disconnect() end
		S.bountyWatchers[uid]=bObj.Changed:Connect(function(v) S.playerInfoCache[uid]=S.playerInfoCache[uid] or {}; S.playerInfoCache[uid].bounty=v end)
	end)
end

-- BRING MOB FUNCTIONS
local function bmGetEHRP(e)
	return e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso")
end
local function bmGetHum(e)
	return e:FindFirstChildOfClass("Humanoid")
end
local function bmIsAlive(e)
	local h = bmGetHum(e)
	return h and h.Health > 0
end
local function bmGetMyRoot()
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end
local function bmGetOffset()
	if BM.useCustomOff then return BM.customOffset end
	local angle = math.random() * math.pi * 2
	local radius = math.random(2, 5)
	return Vector3.new(
		math.cos(angle) * radius,
		0,
		math.sin(angle) * radius
	)
end

local function bmRelease(e)
	local data = BM.mobData[e]; if not data then return end

	if data.bp and data.bp.Parent then pcall(function() data.bp:Destroy() end) end
	if data.bv and data.bv.Parent then pcall(function() data.bv:Destroy() end) end
	if data.bg and data.bg.Parent then pcall(function() data.bg:Destroy() end) end

	local ehrp = bmGetEHRP(e)
	if ehrp then
		for _, child in ipairs(ehrp:GetChildren()) do
			if child.Name:find("BringMob") then pcall(function() child:Destroy() end) end
		end
		pcall(function() ehrp.Anchored = false end)
		pcall(function() ehrp.AssemblyLinearVelocity  = Vector3.zero end)
		pcall(function() ehrp.AssemblyAngularVelocity = Vector3.zero end)
	end

	local h = bmGetHum(e)
	if h then
		pcall(function() h.PlatformStand = false end)
		pcall(function() h.WalkSpeed     = 16 end)
		pcall(function() h.JumpPower     = 50 end)
	end

	if e.Parent then
		for _, p in ipairs(e:GetDescendants()) do
			if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
		end
	end
	BM.mobData[e] = nil
end

local function bmCleanup()
	local snap = {}
	for e in pairs(BM.mobData) do table.insert(snap, e) end
	for _, e in ipairs(snap) do pcall(bmRelease, e) end
	BM.mobData = {}
end

local function bmStartNoclip()
	if BM.noclipConn then return end
	BM.noclipConn = Run.Heartbeat:Connect(function()
		for e in pairs(BM.mobData) do
			if e and e.Parent then
				for _, p in ipairs(e:GetDescendants()) do
					if p:IsA("BasePart") and p.CanCollide then
						pcall(function() p.CanCollide = false end)
					end
				end
			end
		end
	end)
end
local function bmStopNoclip()
	if BM.noclipConn then BM.noclipConn:Disconnect(); BM.noclipConn = nil end
end

local function startBringMob()
	BM.active = true
	bmCleanup()
	bmStartNoclip()
	bmPinTick = 0

	if BM.pinConn then BM.pinConn:Disconnect() end

	BM.pinConn = Run.Heartbeat:Connect(function()
		bmPinTick = bmPinTick + 1
		if bmPinTick % 3 ~= 0 then return end
		local myRoot2 = bmGetMyRoot()
		if not myRoot2 then return end
		local myPos2 = myRoot2.Position

		for e, data in pairs(BM.mobData) do
			if not e or not e.Parent or not data or not data.arrived then continue end
			local ehrp = bmGetEHRP(e); if not ehrp then continue end

			if not data.anchorPos then
				data.anchorPos = myPos2
			end

			local moved = (myPos2 - data.anchorPos).Magnitude
			if moved > 3 then
				data.anchorPos = myPos2
				local newTarget = myPos2 + data.offset
				newTarget = Vector3.new(newTarget.X, myPos2.Y + BM.yOffset, newTarget.Z)
				data.fixedPos = newTarget

				if data.bp and data.bp.Parent then
					pcall(function() data.bp.Position = newTarget end)
				else
					local fbp = Instance.new("BodyPosition")
					fbp.Name = "BringMobBP_Fixed"
					fbp.MaxForce = Vector3.new(1e9,1e9,1e9)
					fbp.P = 500000; fbp.D = 10000
					fbp.Position = newTarget
					pcall(function() fbp.Parent = ehrp end)
					data.bp = fbp
				end
			end

			if not data.bp or not data.bp.Parent then
				local fbp = Instance.new("BodyPosition")
				fbp.Name = "BringMobBP_Fixed"
				fbp.MaxForce = Vector3.new(1e9,1e9,1e9)
				fbp.P = 500000; fbp.D = 10000
				fbp.Position = data.fixedPos or myPos2 + data.offset
				pcall(function() fbp.Parent = ehrp end)
				data.bp = fbp
			end

			if not data.bg or not data.bg.Parent then
				local bg = Instance.new("BodyGyro")
				bg.Name = "BringMobBG"
				bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
				bg.P = 100000; bg.D = 2000
				bg.CFrame = ehrp.CFrame
				pcall(function() bg.Parent = ehrp end)
				data.bg = bg
			end

			pcall(function()
				ehrp.AssemblyLinearVelocity  = Vector3.zero
				ehrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end)

	BM.task = task.spawn(function()
		local PULL_TIME  = 8
		local HOLD_TIME  = 5
		local cyclePhase = "pull"
		local phaseTimer = 0
		local lastTick   = tick()

		while BM.active do
			task.wait(0.05)
			local now = tick()
			local dt  = now - lastTick
			lastTick  = now
			phaseTimer = phaseTimer + dt

			local myRoot = bmGetMyRoot(); if not myRoot then continue end
			local ap = myRoot.Position
			local ef = WS:FindFirstChild("Enemies"); if not ef then task.wait(0.3); continue end

			local snap = {}
			for e in pairs(BM.mobData) do table.insert(snap, e) end
			for _, e in ipairs(snap) do
				if not e or not e.Parent or not bmIsAlive(e) then pcall(bmRelease, e) end
			end

			if cyclePhase == "pull" and phaseTimer >= PULL_TIME then
				for e, data in pairs(BM.mobData) do
					if not data.arrived then
						local ehrp = bmGetEHRP(e)
						if ehrp then
							pcall(function() if data.bp and data.bp.Parent then data.bp:Destroy() end end)
							pcall(function()
								ehrp.AssemblyLinearVelocity  = Vector3.zero
								ehrp.AssemblyAngularVelocity = Vector3.zero
							end)
							local fixedTP = ehrp.Position
							local fixedCF = ehrp.CFrame
							local fbp = Instance.new("BodyPosition")
							fbp.Name="BringMobBP_Fixed"; fbp.MaxForce=Vector3.new(1e9,1e9,1e9)
							fbp.P=500000; fbp.D=10000; fbp.Position=fixedTP
							pcall(function() fbp.Parent=ehrp end)
							local bg = Instance.new("BodyGyro")
							bg.Name="BringMobBG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
							bg.P=100000; bg.D=2000; bg.CFrame=fixedCF
							pcall(function() bg.Parent=ehrp end)
							pcall(function() local h=bmGetHum(e); if h then
								h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0
							end end)
							data.bp=fbp; data.bg=bg; data.arrived=true
							data.fixedPos=fixedTP; data.fixedCFrame=fixedCF
						end
					end
				end
				cyclePhase = "hold"
				phaseTimer = 0

			elseif cyclePhase == "hold" and phaseTimer >= HOLD_TIME then
				bmCleanup()
				cyclePhase = "pull"
				phaseTimer = 0
			end

			if cyclePhase == "hold" then continue end

			local pulling = 0
			for _, data in pairs(BM.mobData) do
				if not data.arrived then pulling = pulling + 1 end
			end

			for _, e in ipairs(ef:GetChildren()) do
				if not BM.active then break end
				if not e or not e.Parent or not bmIsAlive(e) then continue end

				local ehrp = bmGetEHRP(e); if not ehrp then continue end
				if (ap - ehrp.Position).Magnitude > BM.maxDist then
					if BM.mobData[e] and not BM.mobData[e].arrived then
						pcall(bmRelease, e)
					end
					continue
				end

				if not BM.mobData[e] then
					if pulling >= BM.maxBatch then continue end
					local off = bmGetOffset()
					local bp = Instance.new("BodyPosition")
					bp.Name="BringMobBP"; bp.MaxForce=Vector3.new(1e9,1e9,1e9)
					bp.P=BM.pullForce; bp.D=2000; bp.Position=ap+off
					pcall(function() bp.Parent=ehrp end)
					pcall(function() local h=bmGetHum(e); if h then
						h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0
					end end)
					pcall(function()
						for _,p in ipairs(e:GetDescendants()) do
							if p:IsA("BasePart") then p.CanCollide=false end
						end
					end)
					BM.mobData[e]={bp=bp,bv=nil,bg=nil,arrived=false,offset=off,stuckTime=0,lastPos=ehrp.Position}
					pulling = pulling + 1
				end

				local data = BM.mobData[e]
				if not data or not data.bp or not data.bp.Parent then pcall(bmRelease,e); continue end
				if data.arrived then continue end

				local tp = ap + data.offset
				tp = Vector3.new(tp.X, ap.Y + BM.yOffset, tp.Z)
				local dist  = (ehrp.Position - tp).Magnitude
				local moved = (ehrp.Position - data.lastPos).Magnitude
				data.lastPos = ehrp.Position

				if moved < 0.05 then data.stuckTime = data.stuckTime + 0.05
				else data.stuckTime = 0 end

				pcall(function() data.bp.Position = tp end)

				if dist <= BM.snapDist then
					pcall(function() data.bp:Destroy() end)
					pcall(function()
						ehrp.AssemblyLinearVelocity  = Vector3.zero
						ehrp.AssemblyAngularVelocity = Vector3.zero
					end)
					local fixedTP = ehrp.Position
					local fixedCF = ehrp.CFrame

					local bv = Instance.new("BodyVelocity")
					bv.Name="BringMobBV"; bv.MaxForce=Vector3.new(1e9,1e9,1e9)
					bv.Velocity=Vector3.zero
					pcall(function() bv.Parent=ehrp end)

					task.wait()

					local fbp = Instance.new("BodyPosition")
					fbp.Name="BringMobBP_Fixed"; fbp.MaxForce=Vector3.new(1e9,1e9,1e9)
					fbp.P=500000; fbp.D=10000; fbp.Position=fixedTP
					pcall(function() fbp.Parent=ehrp end)

					local bg = Instance.new("BodyGyro")
					bg.Name="BringMobBG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
					bg.P=100000; bg.D=2000; bg.CFrame=fixedCF
					pcall(function() bg.Parent=ehrp end)

					pcall(function() local h=bmGetHum(e); if h then
						h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0
					end end)

					task.delay(0.5,function()
						if bv and bv.Parent then pcall(function() bv:Destroy() end) end
					end)

					data.bp=fbp; data.bg=bg; data.bv=bv
					data.arrived=true
					data.fixedPos=fixedTP; data.fixedCFrame=fixedCF

				elseif data.stuckTime >= 1.5 then
					data.offset = bmGetOffset()
					pcall(function() data.bp.P=100000 end)
					data.stuckTime = 0
				end
			end
		end

		if BM.pinConn then BM.pinConn:Disconnect(); BM.pinConn=nil end
		bmStopNoclip(); bmCleanup()
		BM.task = nil
	end)
end

local function stopBringMob()
	BM.active = false
	if BM.task    then task.cancel(BM.task);    BM.task    = nil end
	if BM.pinConn then BM.pinConn:Disconnect(); BM.pinConn = nil end
	bmStopNoclip(); bmCleanup()
end

-- WEBHOOK
local function getPing()
	local ok,p=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"] end)
	return ok and type(p)=="number" and math.floor(p) or math.floor(player:GetNetworkPing()*1000)
end

local function sendWebhook(sessBeli, sessFrags, sessElap, source)
	if not config["Webhook Enabled"] then return end
	local url=config["Webhook URL"]; if not url or url=="" or url:find("YOUR_ID") then return end

	source = source or "Manual"
	S.totalWebhookCount = S.totalWebhookCount + 1

	local curLv    = getStat("Level")     or 0
	local curBeli  = getStat("Beli")      or 0
	local curFrag  = getStat("Fragments") or 0
	local melee    = getStat("Melee")     or 0
	local sword    = getStat("Sword")     or 0
	local gun      = getStat("Gun")       or 0
	local defense  = getStat("Defense")   or 0
	local bloxFruit= getStat("Blox Fruit")or 0
	local bounty   = getStat("Bounty")    or 0
	local spawn    = getStat("SpawnPoint") or "?"
	local raceN, raceTier = "", ""
	pcall(function()
		local d=player:FindFirstChild("Data"); if not d then return end
		local rc=d:FindFirstChild("Race"); if not rc then return end
		if rc:IsA("ValueBase") and rc.Value~="" then raceN=tostring(rc.Value) end
		for _,n in ipairs({"C","V","Tier","Level","T"}) do
			local c=rc:FindFirstChild(n)
			if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then raceTier="V"..tostring(c.Value); break end
		end
	end)
	if raceN=="" then raceN="Unknown" end

	local pName = player.DisplayName~=player.Name and (player.DisplayName.." (@"..player.Name..")") or player.Name
	local minInSvr = math.max((sessElap or 0)/60, 0.01)
	local beliPM   = math.floor(sessBeli/minInSvr)
	local fragPM   = math.floor(sessFrags/minInSvr)

	local jobId="unknown"; pcall(function() jobId=game.JobId end)
	local plrCount = #Players:GetPlayers()

	local equippedStr = "None"
	local equippedLv  = nil
	pcall(function()
		local char = player.Character
		if char then
			for _, o in ipairs(char:GetChildren()) do
				if o:IsA("Tool") then
					equippedStr = o.Name
					local lo = o:FindFirstChild("Level")
						or o:FindFirstChildOfClass("NumberValue")
						or o:FindFirstChildOfClass("IntValue")
					if lo then equippedLv = math.floor(lo.Value) end
					break
				end
			end
		end
	end)
	local equippedLine = equippedLv ~= nil
		and ("⚔ "..equippedStr.." [LV"..equippedLv.."]")
		or  ("⚔ "..equippedStr)

	local invLines = {}
	local bp = player:FindFirstChild("Backpack")
	if bp then
		local count = 0
		for _,o in ipairs(bp:GetChildren()) do
			if o:IsA("Tool") and o.Name~="Tool" and count<5 then
				local lv=nil; pcall(function()
					local lo=o:FindFirstChild("Level") or o:FindFirstChildOfClass("NumberValue") or o:FindFirstChildOfClass("IntValue")
					if lo then lv=lo.Value end
				end)
				invLines[#invLines+1] = lv~=nil and ("• "..o.Name.." [LV"..math.floor(lv).."]") or ("• "..o.Name)
				count=count+1
			end
		end
	end
	local invStr = #invLines>0 and (equippedLine.."\n"..table.concat(invLines,"\n")) or equippedLine

	local embedColor = sessBeli>=0 and 5832543 or 15548997
	local sourceIcon = ({["Auto Hop"]="🔀", ["Timer"]="⏰", ["Manual"]="🖐", ["Test"]="🧪"})[source] or "📡"
	local title = sourceIcon.." Session Report — "..source

	local fields = {
		{name="👤 Player",         value="```"..pName.."```",                     inline=true},
		{name="⭐ Level",          value="```"..fmtComma(math.floor(curLv)).."```",inline=true},
		{name="🧬 Race",           value="```"..(raceN..(raceTier~="" and " "..raceTier or "")).."```", inline=true},
		{name="💰 Beli (Total)",   value="```"..fmtComma(curBeli).."```",          inline=true},
		{name="💎 Fragments (Total)",value="```"..fmtComma(curFrag).."```",        inline=true},
		{name="🏆 Bounty",         value="```"..fmtComma(bounty).."```",           inline=true},
		{name="📈 Session Beli",   value="```"..wFmt(sessBeli).."```",             inline=true},
		{name="📈 Session Frag",   value="```"..wFmt(sessFrags).."```",            inline=true},
		{name="⏱ Session Time",   value="```"..elapsedStr(sessElap or 0).."```",   inline=true},
		{name="⚡ Beli / Min",     value="```"..wFmt(beliPM).."```",               inline=true},
		{name="⚡ Beli / Hr",      value="```"..wFmt(beliPM*60).."```",             inline=true},
		{name="⚡ Frag / Min",     value="```"..wFmt(fragPM).."```",               inline=true},
		{name="⚔️ Combat Stats",
		 value="```\nMelee:  "..fmtComma(melee).."\nSword:  "..fmtComma(sword).."\nGun:    "..fmtComma(gun).."\nDefense:"..fmtComma(defense).."\nFruit:  "..fmtComma(bloxFruit).."\n```",
		 inline=false},
		{name="📍 Spawn Point",    value="```"..tostring(spawn).."```",             inline=true},
		{name="👥 Players in Server",value="```"..plrCount.."/"..K.MAX_PLAYERS.."```",inline=true},
		{name="🖥 FPS / Ping",    value="```"..S.fps.." FPS | "..getPing().."ms```",inline=true},
		{name="🎒 Equipped + Backpack (Top 5)",value="```\n"..invStr.."\n```",      inline=false},
		{name="📨 Webhook #",      value="```#"..S.totalWebhookCount.."```",         inline=true},
		{name="📡 Source",         value="```"..source.."```",                       inline=true},
		{name="🕐 Local Time",     value="```"..getLocalTimeStr().."```",            inline=true},
	}

	if source=="Auto Hop" then
		fields[#fields+1]={name="🔀 Hop #",value="```#"..S.totalHopCount.."```",inline=true}
		fields[#fields+1]={name="🌐 Hop Target",value="```"..(S.hopTargetServer~="" and S.hopTargetServer or "all").."```",inline=true}
		fields[#fields+1]={name="🆔 Prev Job ID",value="```"..tostring(jobId):sub(1,36).."```",inline=false}
	end

	local payload={
		username=config["Webhook Name"] or "Blox Hub",
		embeds={{
			author={name="Blox Hub — "..source.." Report"},
			title=title,
			color=embedColor,
			fields=fields,
			footer={text="Blox Hub  •  v2  •  "..source},
			timestamp=getTimestamp(),
		}}
	}

	local ok,json=pcall(function() return game:GetService("HttpService"):JSONEncode(payload) end)
	if not ok then return end
	local opts={Url=url,Method="POST",Headers={["Content-Type"]="application/json"},Body=json}
	pcall(function()
		local res
		if typeof(request)=="function" then res=request(opts)
		elseif typeof(http_request)=="function" then res=http_request(opts)
		elseif syn and syn.request then res=syn.request(opts)
		elseif http and http.request then res=http.request(opts)
		elseif getgenv and getgenv().request then res=getgenv().request(opts) end
		if res then print("[Webhook] Status:",res.StatusCode,"| #"..S.totalWebhookCount.." |",source) end
	end)
end

-- WEBHOOK TIMER
local startWebhookTimer, stopWebhookTimer

local function webhookTimerLoop()
	S.webhookTimerLastTick   = tick()
	S.webhookTimerCountdown  = S.webhookIntervalSecs
	while S.webhookTimerActive do
		task.wait(1)
		local now = tick()
		S.webhookTimerCountdown = S.webhookTimerCountdown - (now - S.webhookTimerLastTick)
		S.webhookTimerLastTick  = now
		if S.webhookTimerCountdown <= 0 then
			S.webhookTimerCountdown = S.webhookIntervalSecs
			if S.webhookTimerActive and config["Webhook Enabled"] then
				task.spawn(function()
					local cb = getStat("Beli") or 0
					local cf = getStat("Fragments") or 0
					local sb = S.sessionInit and math.floor(cb-(S.sessionStartBeli or cb)) or 0
					local sf = S.sessionInit and math.floor(cf-(S.sessionStartFragments or cf)) or 0
					local se = tick() - (S.playerInfoCache[player.UserId] and S.playerInfoCache[player.UserId].joinTime or tick())
					sendWebhook(sb, sf, se, "Timer")
				end)
			end
		end
	end
end

startWebhookTimer = function()
	S.webhookTimerActive    = true
	S.webhookTimerCountdown = S.webhookIntervalSecs
	S.webhookTimerLastTick  = tick()
	if S.webhookTimerThread then task.cancel(S.webhookTimerThread) end
	S.webhookTimerThread = task.spawn(webhookTimerLoop)
end

stopWebhookTimer = function()
	S.webhookTimerActive = false
	if S.webhookTimerThread then task.cancel(S.webhookTimerThread); S.webhookTimerThread=nil end
	S.webhookTimerCountdown = S.webhookIntervalSecs
end

-- SKILL / INVENTORY HELPERS
local function getToolLevel(obj)
	local lv; pcall(function()
		local lo=obj:FindFirstChild("Level") or obj:FindFirstChildOfClass("NumberValue") or obj:FindFirstChildOfClass("IntValue")
		if lo then lv=lo.Value end
	end); return lv
end
local VALID_STATS={Melee=true,Sword=true,Gun=true,["Blox Fruit"]=true,Defense=true}
local function getToolStatType(obj)
	local tip=""; pcall(function() tip=obj.ToolTip or "" end)
	if VALID_STATS[tip] then return tip end
	local found; pcall(function()
		local t=obj:FindFirstChild("Type") or obj:FindFirstChild("WeaponType") or obj:FindFirstChild("StatType")
		if t and t:IsA("StringValue") and VALID_STATS[t.Value] then found=t.Value end
	end); return found
end
local function getEquippedItem()
	local char=player.Character; if not char then return "None",nil end
	for _,o in ipairs(char:GetChildren()) do if o:IsA("Tool") then return o.Name,getToolLevel(o) end end
	return "None",nil
end
local SKIP_TOOLTIPS={["JobTool"]=true,[""]=true,["Wear"]=true}
local function getInventory()
	local items,skipItems={},{}
	local bp=player:FindFirstChild("Backpack"); if not bp then return items end
	for _,o in ipairs(bp:GetChildren()) do
		if o:IsA("Tool") and o.Name~="Tool" then
			local lv=getToolLevel(o)
			if lv~=nil then
				local tip=""; pcall(function() tip=o.ToolTip or "" end)
				local statType=getToolStatType(o)
				if SKIP_TOOLTIPS[tip] then skipItems[#skipItems+1]={name=o.Name,level=lv,statType=statType}
				else items[#items+1]={name=o.Name,level=lv,statType=statType} end
			end
		end
	end
	for _,v in ipairs(skipItems) do items[#items+1]=v end
	return items
end
local function getSkillLevels(itemName)
	if S.skillCache[itemName] then return S.skillCache[itemName] end
	local res={}
	local SKIP_SKILL_ITEMS={["Fishing Rod"]=true,["Kitsune Ribbon"]=true,["Tool"]=true,["Awakening"]=true,["Heightened Senses"]=true}
	if SKIP_SKILL_ITEMS[itemName] then return res end
	local ok,skillFolder=pcall(function()
		return pg:WaitForChild("Main",3):WaitForChild("Skills",3):WaitForChild(itemName,3)
	end)
	if not ok or not skillFolder then return res end
	for _,child in ipairs(skillFolder:GetChildren()) do
		if child.Name=="Template" then continue end
		if not child:IsA("Frame") then continue end
		local lvObj=child:FindFirstChild("Level")
		if lvObj then
			local val
			if lvObj:IsA("TextLabel") or lvObj:IsA("TextButton") then val=tonumber(lvObj.Text:match("%d+"))
			elseif lvObj:IsA("IntValue") or lvObj:IsA("NumberValue") then val=lvObj.Value end
			if val then res[child.Name]=val end
		end
	end
	return res
end
local function getRace(p)
	local rn,rt
	pcall(function()
		local ro=p:FindFirstChild("Data") and p.Data:FindFirstChild("Race"); if not ro then return end
		if ro:IsA("ValueBase") and ro.Value~="" then rn=tostring(ro.Value) end
		for _,n in ipairs({"C","V","Tier","Level","T"}) do
			local c=ro:FindFirstChild(n)
			if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then rt=c.Value; break end
		end
	end); return rn,rt
end
-- GUI BUILD
local gui=mk("ScreenGui",pg,{Name="IntegratedStatusHUD",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=10})
local hudPos=UDim2.new(0.5,-K.HUD_W/2,0.5,-K.HUD_H/2)

local fullPanel=mk("Frame",gui,{Size=UDim2.new(0,K.HUD_W,0,K.HUD_H),Position=hudPos,BackgroundColor3=C.PANEL,BorderSizePixel=0,ClipsDescendants=true})
stroke(fullPanel,C.BORDER2,2); corner(fullPanel,8)

local miniPanel=mk("Frame",gui,{Size=UDim2.new(0,K.MINI_W,0,44),Position=UDim2.new(0.5,-K.MINI_W/2,0.5,-K.HUD_H/2),BackgroundColor3=C.PANEL,BorderSizePixel=0,Visible=false})
stroke(miniPanel,C.BORDER2,2); corner(miniPanel,5)

local loadOverlay=mk("Frame",gui,{Size=UDim2.new(0,K.HUD_W,0,K.HUD_H),Position=hudPos,BackgroundColor3=C.BG,ZIndex=50})
corner(loadOverlay,8); stroke(loadOverlay,C.BORDER2,2)
lbl(loadOverlay,{sz=UDim2.new(1,0,0,28),pos=UDim2.new(0,0,0.38,-14),size=16,color=C.WHITE,text="Account Info",align=Enum.TextXAlignment.Center,z=52})
local loadStepLbl=lbl(loadOverlay,{sz=UDim2.new(1,-60,0,16),pos=UDim2.new(0,30,0.38,18),font=Enum.Font.Gotham,size=12,color=C.MUTED,text="Initializing...",align=Enum.TextXAlignment.Center,z=52})
local loadTrackBg=mk("Frame",loadOverlay,{Size=UDim2.new(1,-60,0,3),Position=UDim2.new(0,30,0.38,40),BackgroundColor3=C.BORDER,BorderSizePixel=0,ZIndex=52}); corner(loadTrackBg,2)
local loadBarFill=mk("Frame",loadTrackBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.WHITE,BorderSizePixel=0,ZIndex=53}); corner(loadBarFill,2)
local loadPctLbl=lbl(loadOverlay,{sz=UDim2.new(1,-60,0,14),pos=UDim2.new(0,30,0.38,48),font=Enum.Font.GothamBold,size=10,color=C.DIM,text="0%",align=Enum.TextXAlignment.Right,z=52})

local notifFrame=mk("Frame",gui,{Size=UDim2.new(0,260,0,44),Position=UDim2.new(1,-270,0,60),BackgroundColor3=C.PANEL,ZIndex=60,Visible=false})
stroke(notifFrame,C.BORDER2,1); corner(notifFrame,6)
local notifDot=mk("Frame",notifFrame,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,10,0,10),BackgroundColor3=C.SUCCESS,ZIndex=61}); corner(notifDot,4)
local notifName=lbl(notifFrame,{sz=UDim2.new(1,-28,0,16),pos=UDim2.new(0,24,0,4),size=11,color=C.WHITE,text="",trunc=Enum.TextTruncate.AtEnd,z=61})
local notifSub=lbl(notifFrame,{sz=UDim2.new(1,-28,0,12),pos=UDim2.new(0,24,0,24),font=Enum.Font.Gotham,size=9,color=C.DIM,text="",z=61})
local notifQ,notifBusy={},false
local NI=TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local NO=TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
local function showNotif(name,action,col)
	if #notifQ >= 5 then table.remove(notifQ, 1) end
	notifQ[#notifQ+1]={name=name,action=action,col=col}
	if notifBusy then return end; notifBusy=true
	task.spawn(function()
		while #notifQ>0 do
			local item=table.remove(notifQ,1)
			notifDot.BackgroundColor3=item.col or C.SUCCESS
			notifName.Text=item.name; notifSub.Text=item.action
			notifFrame.Visible=true; notifFrame.BackgroundTransparency=1
			for _,c in ipairs(notifFrame:GetDescendants()) do pcall(function()
				if c:IsA("TextLabel") then c.TextTransparency=1
				elseif c:IsA("Frame") and c~=notifFrame then c.BackgroundTransparency=1
				elseif c:IsA("UIStroke") then c.Transparency=1 end
			end) end
			TS:Create(notifFrame,NI,{BackgroundTransparency=0}):Play()
			for _,c in ipairs(notifFrame:GetDescendants()) do pcall(function()
				if c:IsA("TextLabel") then TS:Create(c,NI,{TextTransparency=0}):Play()
				elseif c:IsA("Frame") and c~=notifFrame then TS:Create(c,NI,{BackgroundTransparency=0}):Play()
				elseif c:IsA("UIStroke") then TS:Create(c,NI,{Transparency=0}):Play() end
			end) end
			task.wait(3)
			TS:Create(notifFrame,NO,{BackgroundTransparency=1}):Play()
			for _,c in ipairs(notifFrame:GetDescendants()) do pcall(function()
				if c:IsA("TextLabel") then TS:Create(c,NO,{TextTransparency=1}):Play()
				elseif c:IsA("Frame") and c~=notifFrame then TS:Create(c,NO,{BackgroundTransparency=1}):Play()
				elseif c:IsA("UIStroke") then TS:Create(c,NO,{Transparency=1}):Play() end
			end) end
			task.wait(0.3); notifFrame.Visible=false
		end
		notifBusy=false
	end)
end

-- Drag
fullPanel.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1 then
		S.dragging=true; S.dragStart=inp.Position; S.dragStartPos=fullPanel.Position
	end
end)
UIS.InputChanged:Connect(function(inp)
	if S.dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
		local ok,d=pcall(function() return inp.Position-S.dragStart end); if not ok then S.dragging=false; return end
		local np=UDim2.new(S.dragStartPos.X.Scale,S.dragStartPos.X.Offset+d.X,S.dragStartPos.Y.Scale,S.dragStartPos.Y.Offset+d.Y)
		fullPanel.Position=np; miniPanel.Position=np; loadOverlay.Position=np
	end
end)
UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1 then S.dragging=false end
end)

mk("Frame",fullPanel,{Size=UDim2.new(0,1,0,K.HUD_H-K.PAD*2),Position=UDim2.new(0,K.HALF,0,K.PAD),BackgroundColor3=C.SEP,ZIndex=3})
mk("Frame",fullPanel,{Size=UDim2.new(0,K.HUD_W-K.PAD*2,0,1),Position=UDim2.new(0,K.PAD,0,K.HUD_H/2),BackgroundColor3=C.SEP,ZIndex=3})

local function statBlock(par, x, y, w, labelTxt, barColor)
	lbl(par,{sz=UDim2.new(0,w-4,0,12),pos=UDim2.new(0,x,0,y),size=9,color=C.DIM,text=labelTxt,z=4})
	local vl=lbl(par,{sz=UDim2.new(0,w-4,0,17),pos=UDim2.new(0,x,0,y+12),size=13,color=C.OFFWHITE,text="0",trunc=Enum.TextTruncate.AtEnd,z=4})
	local bf
	if barColor then
		local bb=mk("Frame",par,{Size=UDim2.new(0,w-8,0,3),Position=UDim2.new(0,x,0,y+31),BackgroundColor3=C.BORDER,BorderSizePixel=0,ZIndex=4}); corner(bb,1)
		bf=mk("Frame",bb,{Size=UDim2.new(0,0,1,0),BackgroundColor3=barColor,BorderSizePixel=0,ZIndex=5}); corner(bf,1)
	end
	return vl,bf
end

--Q1: ScrollingFrame
local UI={}
local Q1_PANEL_H = K.HUD_H/2 - K.PAD*2

local q1Scroll = mk("ScrollingFrame", fullPanel, {
	Size                   = UDim2.new(0, K.Q1W + K.PAD, 0, Q1_PANEL_H),
	Position               = UDim2.new(0, K.PAD, 0, K.PAD),
	BackgroundTransparency = 1,
	BorderSizePixel        = 0,
	ScrollBarThickness     = 3,
	ScrollBarImageColor3   = C.BORDER2,
	CanvasSize             = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize    = Enum.AutomaticSize.Y,
	ClipsDescendants       = true,
	ZIndex                 = 3,
})

local q1Inner = mk("Frame", q1Scroll, {
	Size                   = UDim2.new(1, -6, 0, 500),
	AutomaticSize          = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	BorderSizePixel        = 0,
	ZIndex                 = 3,
})

local function q1lbl(props)
	return lbl(q1Inner, props)
end
local function q1mk(cl, props)
	local o = Instance.new(cl)
	o.Parent = q1Inner
	if props then for k,v in pairs(props) do pcall(function() o[k]=v end) end end
	return o
end

--avatar row
UI.avatar=mk("ImageLabel",q1Inner,{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,0,0,0),BackgroundColor3=C.CARD,ZIndex=4})
stroke(UI.avatar,C.BORDER2,2); corner(UI.avatar,5)
UI.charLabel=q1lbl({sz=UDim2.new(0,K.Q1W-58,0,16),pos=UDim2.new(0,56,0,0),   size=12,color=C.WHITE, text="Loading...",trunc=Enum.TextTruncate.AtEnd,z=4})
UI.lvlLabel =q1lbl({sz=UDim2.new(0,K.Q1W-58,0,13),pos=UDim2.new(0,56,0,18),size=10,color=C.MUTED,text="LV. 0",z=4})
UI.onlineDot=mk("Frame",q1Inner,{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,56,0,36),BackgroundColor3=C.SUCCESS,ZIndex=4}); corner(UI.onlineDot,4)
q1lbl({sz=UDim2.new(0,55,0,11),pos=UDim2.new(0,67,0,34),size=9,color=C.DIM,text="ONLINE",z=4})
task.spawn(function()
	while true do tween(UI.onlineDot,{BackgroundTransparency=0.5},0.8); task.wait(0.8); tween(UI.onlineDot,{BackgroundTransparency=0},0.8); task.wait(0.8) end
end)

--mini info row
local colW3=math.floor(K.Q1W/3)
local function miniRow(x,y,w,lbTxt,vlTxt)
	q1lbl({sz=UDim2.new(0,w,0,11),pos=UDim2.new(0,x,0,y),size=9,color=C.DIM,text=lbTxt,z=4})
	return q1lbl({sz=UDim2.new(0,w,0,13),pos=UDim2.new(0,x,0,y+11),size=11,color=C.OFFWHITE,text=vlTxt,trunc=Enum.TextTruncate.AtEnd,z=4})
end
UI.raceValLbl =miniRow(0,          64,colW3-4,"RACE","???")
UI.teamValLbl =miniRow(colW3,      64,colW3-4,"TEAM","N/A")
UI.spawnValLbl=miniRow(colW3*2,    64,colW3-4,"SPAWN","???")
UI.fpsLabel  =q1lbl({sz=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,92), size=12,color=C.OFFWHITE,text="FPS 0",z=4})
UI.pingLabel =q1lbl({sz=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,108),size=12,color=C.OFFWHITE,text="PING 0ms",z=4})
UI.timeLabel =q1lbl({sz=UDim2.new(0,K.Q1W,0,13),pos=UDim2.new(0,0,0,124),font=Enum.Font.Gotham,size=10,color=C.DIM,text="00:00:00",z=4})

--buttons
local function mkBtn(x,y,w,h,txt,isOn,col)
	local b=mk("TextButton",q1Inner,{Size=UDim2.new(0,w,0,h),Position=UDim2.new(0,x,0,y),
		BackgroundColor3=isOn and col or C.CARD,BorderSizePixel=0,
		Text=txt,TextColor3=isOn and C.BG or C.MUTED,TextSize=10,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4})
	stroke(b,C.BORDER2,1); corner(b,4); return b
end
local bW=math.floor((K.Q1W-6)/2)

UI.v1Btn   =mkBtn(0,       142,bW,20,config["Boost FPS V1"] and "V1 ON" or "V1 OFF",config["Boost FPS V1"],C.V1COL)
UI.v2Btn   =mkBtn(bW+6,    142,bW,20,config["Boost FPS V2"] and "V2 ON" or "V2 OFF",config["Boost FPS V2"],C.V2COL)
UI.hideBtn =mkBtn(0,       166,bW,20,S.hidePlayersActive and "Del Player ON" or "Del Player OFF",S.hidePlayersActive,C.WHITE)
UI.miniBtn =mkBtn(bW+6,    166,bW,20,"MINIMIZE",false,C.CARD); UI.miniBtn.TextColor3=C.MUTED
UI.enemyBtn=mkBtn(0,       190,bW,20,S.hideEnemiesActive and "HIDE ENEMY ON" or "HIDE ENEMY OFF",S.hideEnemiesActive,C.DANGER)
UI.hopBtn  =mkBtn(bW+6,    190,bW,20,S.autoHopActive and "HOP ON" or "HOP OFF",S.autoHopActive,C.HOP)

local capBoxW = mk("TextBox",q1Inner,{Size=UDim2.new(0,bW-34,0,20),Position=UDim2.new(0,0,0,214),
	BackgroundColor3=C.CARD,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.WHITE,
	Text="",PlaceholderText=tostring(FPS_CAP),PlaceholderColor3=C.DIM,ZIndex=4})
UI.capBox = capBoxW
stroke(UI.capBox,C.BORDER2,1); corner(UI.capBox,4)
UI.setCapBtn=mkBtn(bW-28,   214,28,20,"SET",true,C.WHITE); UI.setCapBtn.TextColor3=C.BG
UI.themeBtn =mkBtn(bW+6,    214,bW,20,"THEME: Default",false,C.CARD); UI.themeBtn.TextColor3=C.MUTED

local WH_W = math.floor((K.Q1W-4)*0.60)
UI.webhookBtn    =mkBtn(0,         238, WH_W,          20, S.webhookActive and "WEBHOOK ON" or "WEBHOOK OFF", S.webhookActive, C.WEBHOOK)
UI.testWebhookBtn=mkBtn(WH_W+4,    238, K.Q1W-WH_W-4, 20, "TEST SEND", false, C.CARD)
UI.testWebhookBtn.TextColor3=Color3.fromRGB(255,200,60)

local WH_T_W = K.Q1W - 26
UI.whTimerBtn=mkBtn(0,         262, WH_T_W, 20, "WH TIMER OFF", false, C.CARD)
UI.whTimerBtn.TextColor3=C.MUTED
UI.whTimerCfgBtn=mkBtn(WH_T_W+4, 262, 20, 20, "⚙", false, C.CARD)
UI.whTimerCfgBtn.TextColor3=C.MUTED

q1lbl({sz=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,0,0,286),size=8,color=C.DIM,text="HOP COUNTDOWN",z=4})
UI.hopCountdownLbl=q1lbl({sz=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,296),font=Enum.Font.GothamBold,size=11,color=C.HOP,text="DISABLED",z=4})

q1lbl({sz=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,0,0,314),size=8,color=C.DIM,text="WH TIMER COUNTDOWN",z=4})
UI.whTimerCountdownLbl=q1lbl({sz=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,324),font=Enum.Font.GothamBold,size=11,color=C.WEBHOOK,text="DISABLED",z=4})

--Bring Mob UI
q1lbl({sz=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,0,0,342),size=8,color=C.DIM,text="BRING MOB",z=4})

UI.pullBtn = mkBtn(0, 352, bW, 20, "PULL OFF", false, C.CARD)
UI.pullBtn.TextColor3 = C.MUTED

local distBox = mk("TextBox", q1Inner, {
	Size=UDim2.new(0,bW-30,0,20), Position=UDim2.new(0,bW+6,0,352),
	BackgroundColor3=C.CARD, BorderSizePixel=0,
	Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.WHITE,
	Text="", PlaceholderText="Dist: 1000", PlaceholderColor3=C.DIM, ZIndex=4
})
stroke(distBox,C.BORDER2,1); corner(distBox,4)
local setDistBtn = mkBtn(K.Q1W-24, 352, 24, 20, "SET", true, C.WHITE)
setDistBtn.TextColor3 = C.BG

q1lbl({sz=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,0,0,376),size=8,color=C.DIM,text="PULL FORCE",z=4})
local forceBox = mk("TextBox", q1Inner, {
	Size=UDim2.new(0,bW-30,0,20), Position=UDim2.new(0,0,0,386),
	BackgroundColor3=C.CARD, BorderSizePixel=0,
	Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.WHITE,
	Text="", PlaceholderText="Force: 60000", PlaceholderColor3=C.DIM, ZIndex=4
})
stroke(forceBox,C.BORDER2,1); corner(forceBox,4)
local setForceBtn = mkBtn(bW-24, 386, 24, 20, "SET", true, C.WHITE)
setForceBtn.TextColor3 = C.BG

q1lbl({sz=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,bW+6,0,376),size=8,color=C.DIM,text="SNAP DIST",z=4})
local snapBox = mk("TextBox", q1Inner, {
	Size=UDim2.new(0,bW-30,0,20), Position=UDim2.new(0,bW+6,0,386),
	BackgroundColor3=C.CARD, BorderSizePixel=0,
	Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.WHITE,
	Text="", PlaceholderText="Snap: 30", PlaceholderColor3=C.DIM, ZIndex=4
})
stroke(snapBox,C.BORDER2,1); corner(snapBox,4)
local setSnapBtn = mkBtn(K.Q1W-24, 386, 24, 20, "SET", true, C.WHITE)
setSnapBtn.TextColor3 = C.BG

q1lbl({sz=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,0,0,410),size=8,color=C.DIM,text="Y OFFSET",z=4})
local yOffBox = mk("TextBox", q1Inner, {
	Size=UDim2.new(0,bW-30,0,20), Position=UDim2.new(0,0,0,420),
	BackgroundColor3=C.CARD, BorderSizePixel=0,
	Font=Enum.Font.Gotham, TextSize=11, TextColor3=C.WHITE,
	Text="", PlaceholderText="Y: -20", PlaceholderColor3=C.DIM, ZIndex=4
})
stroke(yOffBox,C.BORDER2,1); corner(yOffBox,4)
local setYOffBtn = mkBtn(bW-24, 420, 24, 20, "SET", true, C.WHITE)
setYOffBtn.TextColor3 = C.BG

q1lbl({sz=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,bW+6,0,410),size=8,color=C.DIM,text="MAX BATCH",z=4})

UI.pullCountLbl = q1lbl({sz=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,446),font=Enum.Font.GothamBold,size=10,color=C.DIM,text="Pull: OFF",z=4})

q1lbl({sz=UDim2.new(0,1,0,8),pos=UDim2.new(0,0,0,462),size=1,color=C.BG,text="",z=1})

--Webhook Timer Config Popup
local whTimerPopup=mk("Frame",gui,{Size=UDim2.new(0,220,0,76),BackgroundColor3=C.PANEL,ZIndex=20,Visible=false})
stroke(whTimerPopup,C.BORDER2,1); corner(whTimerPopup,6)
lbl(whTimerPopup,{sz=UDim2.new(1,-10,0,12),pos=UDim2.new(0,8,0,6),size=9,color=C.DIM,text="SEND WEBHOOK EVERY (MIN)",z=21})
local whIntervalBox=mk("TextBox",whTimerPopup,{Size=UDim2.new(0,140,0,20),Position=UDim2.new(0,8,0,22),BackgroundColor3=C.CARD,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.WHITE,Text="",PlaceholderText=tostring(math.floor(S.webhookIntervalSecs/60)),PlaceholderColor3=C.DIM,ZIndex=21})
stroke(whIntervalBox,C.BORDER2,1); corner(whIntervalBox,4)
local setWhIntervalBtn=mk("TextButton",whTimerPopup,{Size=UDim2.new(0,56,0,20),Position=UDim2.new(0,156,0,22),BackgroundColor3=C.WEBHOOK,BorderSizePixel=0,Text="SET",TextColor3=C.BG,TextSize=10,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=21})
stroke(setWhIntervalBtn,C.BORDER2,1); corner(setWhIntervalBtn,4)
local whTimerInfoLbl=lbl(whTimerPopup,{sz=UDim2.new(1,-10,0,12),pos=UDim2.new(0,8,0,48),font=Enum.Font.Gotham,size=9,color=C.DIM,text="Sends full session report periodically",z=21})

local function showWhTimerPopup()
	local ap=fullPanel.AbsolutePosition
	whTimerPopup.Position=UDim2.new(0,ap.X+K.PAD,0,ap.Y+K.PAD+262+24)
	whTimerPopup.Visible=true; S.webhookTimerPopupOpen=true
end
local function hideWhTimerPopup()
	whTimerPopup.Visible=false; S.webhookTimerPopupOpen=false
end

--Hop Popup
local hopPopup=mk("Frame",gui,{Size=UDim2.new(0,220,0,110),BackgroundColor3=C.PANEL,ZIndex=20,Visible=false})
stroke(hopPopup,C.BORDER2,1); corner(hopPopup,6)
lbl(hopPopup,{sz=UDim2.new(1,-10,0,12),pos=UDim2.new(0,8,0,6),size=9,color=C.DIM,text="HOP EVERY (MIN)",z=21})
local hopIntervalBox=mk("TextBox",hopPopup,{Size=UDim2.new(0,140,0,20),Position=UDim2.new(0,8,0,20),BackgroundColor3=C.CARD,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.WHITE,Text="",PlaceholderText=tostring(config["Hop Interval"]),PlaceholderColor3=C.DIM,ZIndex=21})
stroke(hopIntervalBox,C.BORDER2,1); corner(hopIntervalBox,4)
local setHopBtn=mk("TextButton",hopPopup,{Size=UDim2.new(0,56,0,20),Position=UDim2.new(0,156,0,20),BackgroundColor3=C.HOP,BorderSizePixel=0,Text="SET",TextColor3=C.BG,TextSize=10,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=21})
stroke(setHopBtn,C.BORDER2,1); corner(setHopBtn,4)
lbl(hopPopup,{sz=UDim2.new(1,-10,0,12),pos=UDim2.new(0,8,0,48),size=9,color=C.DIM,text="HOP SERVER (BLANK = ALL)",z=21})
local hopServerBox=mk("TextBox",hopPopup,{Size=UDim2.new(0,204,0,20),Position=UDim2.new(0,8,0,62),BackgroundColor3=C.CARD,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.WHITE,Text=config["Hop Server"],PlaceholderText="e.g. singapore",PlaceholderColor3=C.DIM,ZIndex=21})
stroke(hopServerBox,C.BORDER2,1); corner(hopServerBox,4)
local function showHopPopup()
	local ap=fullPanel.AbsolutePosition
	hopPopup.Position=UDim2.new(0,ap.X+K.PAD+bW+6,0,ap.Y+K.PAD+190+24)
	hopPopup.Visible=true; S.hopPopupOpen=true
end
local function hideHopPopup() hopPopup.Visible=false; S.hopPopupOpen=false end

-- Q2 Stats + Session
local Q2_HEIGHT = K.HUD_H/2 - K.PAD*2

local q2Scroll = mk("ScrollingFrame", fullPanel, {
	Size            = UDim2.new(0, K.Q2W, 0, Q2_HEIGHT),
	Position        = UDim2.new(0, K.Q2X, 0, K.Q2Y),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness     = 4,
	ScrollBarImageColor3   = C.BORDER2,
	CanvasSize             = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize    = Enum.AutomaticSize.Y,
	ClipsDescendants       = true,
	ZIndex                 = 3,
})
local q2Inner = mk("Frame", q2Scroll, {
	Size                   = UDim2.new(1, 0, 0, 500),
	AutomaticSize          = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	BorderSizePixel        = 0,
	ZIndex                 = 3,
})

local sRH = 36
local function q2StatBlock(iy, labelTxt, barColor)
	return statBlock(q2Inner, 0, iy, K.Q2W, labelTxt, barColor)
end

UI.beliLbl,_            = q2StatBlock(sRH*0,       "BELI",         nil)
UI.fragLbl,_            = q2StatBlock(sRH*1,       "FRAGMENTS",    nil)
UI.meleeLbl,UI.meleeBar = q2StatBlock(sRH*2,       "MELEE",        C.V1COL)
UI.defLbl,  UI.defBar   = q2StatBlock(sRH*3,       "DEFENSE",      C.V1COL)
UI.swordLbl,UI.swordBar = q2StatBlock(sRH*4,       "SWORD",        C.V1COL)
UI.gunLbl,  UI.gunBar   = q2StatBlock(sRH*5,       "GUN",          C.V1COL)
UI.fruitLbl,UI.fruitBar = q2StatBlock(sRH*6,       "BLOX FRUIT",   C.WARN)

local sessY = sRH*7 + 4
local _cL = math.floor(K.Q2W/2) - 4
local _cR = K.Q2W - math.floor(K.Q2W/2) - 8
local _xR = math.floor(K.Q2W/2) + 2

mk("Frame",q2Inner,{Size=UDim2.new(0,K.Q2W-4,0,1),Position=UDim2.new(0,0,0,sessY-3),BackgroundColor3=C.SEP,ZIndex=4})
lbl(q2Inner,{sz=UDim2.new(0,_cL,0,10),pos=UDim2.new(0,0,0,sessY),size=8,color=C.DIM,text="SESSION BELI",z=4})
UI.sessionBeliLbl=lbl(q2Inner,{sz=UDim2.new(0,_cL,0,15),pos=UDim2.new(0,0,0,sessY+10),size=12,color=C.SUCCESS,text="+0",z=4})
lbl(q2Inner,{sz=UDim2.new(0,_cR,0,10),pos=UDim2.new(0,_xR,0,sessY),size=8,color=C.DIM,text="SESSION FRAG",align=Enum.TextXAlignment.Right,z=4})
UI.sessionFragLbl=lbl(q2Inner,{sz=UDim2.new(0,_cR,0,15),pos=UDim2.new(0,_xR,0,sessY+10),size=12,color=C.WARN,text="+0",align=Enum.TextXAlignment.Right,z=4})

mk("Frame",q2Inner,{Size=UDim2.new(0,K.Q2W-4,0,1),Position=UDim2.new(0,0,0,sessY+28),BackgroundColor3=C.SEP,ZIndex=4})
lbl(q2Inner,{sz=UDim2.new(0,K.Q2W-4,0,10),pos=UDim2.new(0,0,0,sessY+32),size=8,color=C.DIM,text="RATE (LIVE ESTIMATE)",z=4})
lbl(q2Inner,{sz=UDim2.new(0,_cL,0,10),pos=UDim2.new(0,0,0,sessY+44),size=8,color=C.DIM,text="BELI / MIN",z=4})
lbl(q2Inner,{sz=UDim2.new(0,_cR,0,10),pos=UDim2.new(0,_xR,0,sessY+44),size=8,color=C.DIM,text="BELI / HR",align=Enum.TextXAlignment.Right,z=4})
UI.beliPerMinLbl  =lbl(q2Inner,{sz=UDim2.new(0,_cL,0,15),pos=UDim2.new(0,0,0,sessY+54),size=12,color=C.SUCCESS,text="+0",z=4})
UI.beliPerHourLbl =lbl(q2Inner,{sz=UDim2.new(0,_cR,0,15),pos=UDim2.new(0,_xR,0,sessY+54),size=12,color=C.SUCCESS,text="+0",align=Enum.TextXAlignment.Right,z=4})
lbl(q2Inner,{sz=UDim2.new(0,_cL,0,10),pos=UDim2.new(0,0,0,sessY+72),size=8,color=C.DIM,text="FRAG / MIN",z=4})
lbl(q2Inner,{sz=UDim2.new(0,_cR,0,10),pos=UDim2.new(0,_xR,0,sessY+72),size=8,color=C.DIM,text="FRAG / HR",align=Enum.TextXAlignment.Right,z=4})
UI.fragPerMinLbl  =lbl(q2Inner,{sz=UDim2.new(0,_cL,0,15),pos=UDim2.new(0,0,0,sessY+82),size=12,color=C.FRAG,text="+0",z=4})
UI.fragPerHourLbl =lbl(q2Inner,{sz=UDim2.new(0,_cR,0,15),pos=UDim2.new(0,_xR,0,sessY+82),size=12,color=C.FRAG,text="+0",align=Enum.TextXAlignment.Right,z=4})

--Q3 Players
lbl(fullPanel,{sz=UDim2.new(0,K.Q3W,0,12),pos=UDim2.new(0,K.Q3X,0,K.Q3Y),size=9,color=C.DIM,text="PLAYERS",z=4})
UI.pcCountLbl=lbl(fullPanel,{sz=UDim2.new(0,100,0,18),pos=UDim2.new(0,K.Q3X,0,K.Q3Y+12),size=14,color=C.WHITE,text="? / "..K.MAX_PLAYERS,z=4})
local svrBarBg=mk("Frame",fullPanel,{Size=UDim2.new(0,K.Q3W,0,3),Position=UDim2.new(0,K.Q3X,0,K.Q3Y+32),BackgroundColor3=C.BORDER,ZIndex=4}); corner(svrBarBg,1)
UI.serverBarFill=mk("Frame",svrBarBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.WHITE,ZIndex=5}); corner(UI.serverBarFill,1)
lbl(fullPanel,{sz=UDim2.new(0,K.Q3W/2,0,12),pos=UDim2.new(0,K.Q3X+K.Q3W/2,0,K.Q3Y),size=9,color=C.DIM,text="TOTAL BOUNTY",align=Enum.TextXAlignment.Right,z=4})
UI.totalBountyLbl=lbl(fullPanel,{sz=UDim2.new(0,K.Q3W/2,0,18),pos=UDim2.new(0,K.Q3X+K.Q3W/2,0,K.Q3Y+12),size=12,color=C.BOUNTY,text="0",align=Enum.TextXAlignment.Right,z=4})
local plrScroll=mk("ScrollingFrame",fullPanel,{Size=UDim2.new(0,K.Q3W,0,K.HUD_H/2-K.PAD*2-42),Position=UDim2.new(0,K.Q3X,0,K.Q3Y+38),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BORDER2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=3})
mk("UIListLayout",plrScroll,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding",plrScroll,{PaddingBottom=UDim.new(0,2)})
local plrRows={}
for i=1,20 do
	local row=mk("Frame",plrScroll,{Size=UDim2.new(1,-4,0,58),BackgroundColor3=C.CARD,ZIndex=4,LayoutOrder=i,Visible=false})
	stroke(row,C.BORDER2,1); corner(row,4)
	plrRows[i]={row=row,
		nameLbl =lbl(row,{sz=UDim2.new(1,-62,0,14),pos=UDim2.new(0,6,0,2), size=11,color=C.WHITE, text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		lvlLbl  =lbl(row,{sz=UDim2.new(0,56,0,14), pos=UDim2.new(1,-60,0,2), size=10,color=C.MUTED,text="",align=Enum.TextXAlignment.Right,z=5}),
		raceLbl =lbl(row,{sz=UDim2.new(0,90,0,12), pos=UDim2.new(0,6,0,18), font=Enum.Font.Gotham,size=9,color=C.FRIEND,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		spawnLbl=lbl(row,{sz=UDim2.new(1,-100,0,12),pos=UDim2.new(0,100,0,18),font=Enum.Font.Gotham,size=9,color=C.DIM,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		bountyLbl=lbl(row,{sz=UDim2.new(1,-90,0,12),pos=UDim2.new(0,6,0,32),font=Enum.Font.Gotham,size=9,color=C.BOUNTY,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		distLbl =lbl(row,{sz=UDim2.new(0,80,0,12), pos=UDim2.new(1,-84,0,32),font=Enum.Font.Gotham,size=9,color=C.DIST,text="",align=Enum.TextXAlignment.Right,z=5}),
		timeLbl =lbl(row,{sz=UDim2.new(1,-6,0,12), pos=UDim2.new(0,6,0,46), font=Enum.Font.Gotham,size=9,color=Color3.fromRGB(180,220,255),text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
	}
end

--Q4 Inventory
lbl(fullPanel,{sz=UDim2.new(0,K.Q4W,0,12),pos=UDim2.new(0,K.Q4X,0,K.Q4Y),size=9,color=C.DIM,text="EQUIPPED",z=4})
UI.equipValLbl=lbl(fullPanel,{sz=UDim2.new(0,K.Q4W,0,17),pos=UDim2.new(0,K.Q4X,0,K.Q4Y+12),size=13,color=C.OFFWHITE,text="None",trunc=Enum.TextTruncate.AtEnd,z=4})
UI.equipLvlLbl=lbl(fullPanel,{sz=UDim2.new(0,K.Q4W,0,13),pos=UDim2.new(0,K.Q4X,0,K.Q4Y+30),font=Enum.Font.GothamBold,size=10,color=C.WARN,text="",z=4})
lbl(fullPanel,{sz=UDim2.new(0,K.Q4W,0,12),pos=UDim2.new(0,K.Q4X,0,K.Q4Y+48),size=9,color=C.DIM,text="INVENTORY",z=4})

local invScroll=mk("ScrollingFrame",fullPanel,{
	Size=UDim2.new(0,K.Q4W,0,K.HUD_H/2-K.PAD-62-2),
	Position=UDim2.new(0,K.Q4X,0,K.Q4Y+62),
	BackgroundTransparency=1,BorderSizePixel=0,
	ScrollBarThickness=3,ScrollBarImageColor3=C.BORDER2,
	CanvasSize=UDim2.new(0,0,0,0),
	AutomaticCanvasSize=Enum.AutomaticSize.Y,
	ClipsDescendants=true,ZIndex=3
})
mk("UIListLayout",invScroll,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding",invScroll,{PaddingBottom=UDim.new(0,2)})

local invRows={}
for i=1,20 do
	local cell=mk("Frame",invScroll,{
		Size=UDim2.new(1,-4,0,56),
		BackgroundColor3=C.CARD,ZIndex=4,LayoutOrder=i,Visible=false
	})
	stroke(cell,C.BORDER2,1); corner(cell,4)
	local nameLbl=lbl(cell,{
		sz=UDim2.new(1,-68,0,16),pos=UDim2.new(0,8,0,4),
		size=11,color=C.OFFWHITE,text="",trunc=Enum.TextTruncate.AtEnd,z=5
	})
	local lvlLbl=lbl(cell,{
		sz=UDim2.new(0,60,0,16),pos=UDim2.new(1,-66,0,4),
		size=10,color=C.WARN,text="",align=Enum.TextXAlignment.Right,z=5
	})
	mk("Frame",cell,{Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,0,23),BackgroundColor3=C.SEP,ZIndex=5})
	local skillLbls={}
	for si,key in ipairs(SKILL_KEYS) do
		local xPos=8+(si-1)*40
		local kl=lbl(cell,{sz=UDim2.new(0,38,0,11),pos=UDim2.new(0,xPos,0,27),size=8,color=C.DIM,text=key,align=Enum.TextXAlignment.Center,z=5})
		local cl=lbl(cell,{sz=UDim2.new(0,38,0,16),pos=UDim2.new(0,xPos,0,38),size=13,color=C.SUCCESS,text="",align=Enum.TextXAlignment.Center,z=5})
		kl.Visible=false; cl.Visible=false
		skillLbls[key]={kl=kl,cl=cl}
	end
	invRows[i]={cell=cell,nameLbl=nameLbl,lvlLbl=lvlLbl,skillLbls=skillLbls}
end

--Mini Panel
UI.miniAva=mk("ImageLabel",miniPanel,{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,6,0,8),BackgroundColor3=C.CARD,ZIndex=3})
stroke(UI.miniAva,C.BORDER2,1); corner(UI.miniAva,4)
task.spawn(function()
	local ok,t=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
	if ok and t then UI.miniAva.Image=t; UI.avatar.Image=t end
end)
UI.miniNameLbl=lbl(miniPanel,{sz=UDim2.new(0,120,0,16),pos=UDim2.new(0,38,0,6),size=12,color=C.WHITE,text="Loading...",z=3})
UI.miniLvlLbl =lbl(miniPanel,{sz=UDim2.new(0,90,0,12), pos=UDim2.new(0,38,0,24),font=Enum.Font.Gotham,size=10,color=C.DIM,text="LV. 0",z=3})
local function miniCol(x,labelTxt,isHighlight)
	lbl(miniPanel,{sz=UDim2.new(0,90,0,12),pos=UDim2.new(0,x,0,6),size=9,color=C.DIM,text=labelTxt,z=3})
	return lbl(miniPanel,{sz=UDim2.new(0,90,0,16),pos=UDim2.new(0,x,0,22),size=12,color=isHighlight and C.FRAG or C.WHITE,text="...",z=3})
end
UI.miniFpsLbl  =miniCol(170,"FPS")
UI.miniPingLbl =miniCol(270,"PING")
UI.miniBeliLbl =miniCol(370,"BELI")
UI.miniFragLbl =miniCol(470,"FRAG",true)
mk("Frame",miniPanel,{Size=UDim2.new(0,1,0,28),Position=UDim2.new(0,466,0,8),BackgroundColor3=C.SEP,ZIndex=3})
local expandBtn=mk("TextButton",miniPanel,{Size=UDim2.new(0,30,0,26),Position=UDim2.new(1,-36,0,9),BackgroundColor3=C.CARD,BorderSizePixel=0,Text="▼",TextColor3=C.MUTED,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=5})
stroke(expandBtn,C.BORDER2,1); corner(expandBtn,4)

local blackoutFrame=mk("Frame",gui,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),ZIndex=1,Visible=false})
local restoreBtn=mk("TextButton",gui,{Size=UDim2.new(0,96,0,32),AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-30),BackgroundColor3=C.WHITE,BorderSizePixel=0,Text="RESTORE",TextColor3=C.BG,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,Visible=false,ZIndex=51})
if config["White Screen"] then S.blackoutActive=true; blackoutFrame.Visible=true; restoreBtn.Visible=true end
restoreBtn.MouseButton1Click:Connect(function() S.blackoutActive=false; blackoutFrame.Visible=false; restoreBtn.Visible=false end)

local function applyHL(char)
	if S.selfHL and S.selfHL.Parent then S.selfHL:Destroy() end; S.selfHL=nil
	if not char then return end
	local hl=Instance.new("Highlight"); hl.Name="ESP_SelfHL"
	hl.FillColor=Color3.fromRGB(255,255,255); hl.OutlineColor=Color3.new(0,0,0)
	hl.FillTransparency=0.5; hl.OutlineTransparency=0
	hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=char; hl.Parent=char; S.selfHL=hl
end
if player.Character then task.delay(0.5,function() applyHL(player.Character) end) end
player.CharacterAdded:Connect(function(char) task.wait(0.5); applyHL(char) end)

local function setView(mini)
	S.isMini=mini
	if mini then
		tween(fullPanel,{BackgroundTransparency=1},0.18); task.delay(0.18,function() fullPanel.Visible=false; fullPanel.BackgroundTransparency=0 end)
		miniPanel.BackgroundTransparency=1; miniPanel.Visible=true; tween(miniPanel,{BackgroundTransparency=0},0.18)
	else
		tween(miniPanel,{BackgroundTransparency=1},0.18); task.delay(0.18,function() miniPanel.Visible=false; miniPanel.BackgroundTransparency=0 end)
		fullPanel.BackgroundTransparency=1; fullPanel.Visible=true; tween(fullPanel,{BackgroundTransparency=0},0.18)
	end
end
expandBtn.MouseButton1Click:Connect(function() setView(false) end)
expandBtn.MouseEnter:Connect(function() tween(expandBtn,{BackgroundColor3=C.HOVER},0.12) end)
expandBtn.MouseLeave:Connect(function() tween(expandBtn,{BackgroundColor3=C.CARD},0.12) end)
UI.miniBtn.MouseButton1Click:Connect(function() setView(true) end)

local function addHover(btn,getCol)
	btn.MouseEnter:Connect(function() tween(btn,{BackgroundColor3=C.HOVER},0.12) end)
	btn.MouseLeave:Connect(function() tween(btn,{BackgroundColor3=getCol()},0.12) end)
end
local function smoothToggle(btn,active,onCol,offCol,onTxt,offTxt)
	tween(btn,{BackgroundColor3=active and onCol or offCol},0.18)
	btn.Text=active and onTxt or offTxt; btn.TextColor3=active and C.BG or C.MUTED
end

-- BUTTON HANDLERS
UI.v1Btn.MouseButton1Click:Connect(function()
	S.boostV1Active=not S.boostV1Active
	if S.boostV1Active then task.spawn(function() setMapVisibility(true) end) else task.spawn(function() setMapVisibility(false) end) end
	smoothToggle(UI.v1Btn,S.boostV1Active,C.V1COL,C.CARD,"V1 ON","V1 OFF")
end)
UI.v2Btn.MouseButton1Click:Connect(function()
	S.boostV2Active=not S.boostV2Active
	if S.boostV2Active then task.spawn(applyLowGraphic) else task.spawn(removeLowGraphic) end
	smoothToggle(UI.v2Btn,S.boostV2Active,C.V2COL,C.CARD,"V2 ON","V2 OFF")
end)
UI.hideBtn.MouseButton1Click:Connect(function()
	S.hidePlayersActive=not S.hidePlayersActive; toggleHidePlayers(S.hidePlayersActive)
	smoothToggle(UI.hideBtn,S.hidePlayersActive,C.WHITE,C.CARD,"DEL PLAYER ON","DEL PLAYER OFF")
end)
UI.enemyBtn.MouseButton1Click:Connect(function()
	S.hideEnemiesActive=not S.hideEnemiesActive; task.spawn(function() toggleHideEnemies(S.hideEnemiesActive) end)
	smoothToggle(UI.enemyBtn,S.hideEnemiesActive,C.DANGER,C.CARD,"HIDE ENEMY ON","HIDE ENEMY OFF")
end)

UI.webhookBtn.MouseButton1Click:Connect(function()
	S.webhookActive=not S.webhookActive; config["Webhook Enabled"]=S.webhookActive
	smoothToggle(UI.webhookBtn,S.webhookActive,C.WEBHOOK,C.CARD,"WEBHOOK ON","WEBHOOK OFF")
	showNotif("Webhook",S.webhookActive and "Enabled" or "Disabled",S.webhookActive and C.WEBHOOK or C.DANGER)
	if not S.webhookActive and S.webhookTimerActive then
		stopWebhookTimer()
		smoothToggle(UI.whTimerBtn,false,C.WEBHOOK,C.CARD,"WH TIMER ON","WH TIMER OFF")
		showNotif("WH Timer","Disabled (Webhook off)",C.DANGER)
	end
end)
UI.testWebhookBtn.MouseButton1Click:Connect(function()
	task.spawn(function()
		local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0
		local sb=S.sessionInit and math.floor(cb-(S.sessionStartBeli or cb)) or 0
		local sf=S.sessionInit and math.floor(cf-(S.sessionStartFragments or cf)) or 0
		local se=tick()-(S.playerInfoCache[player.UserId] and S.playerInfoCache[player.UserId].joinTime or tick())
		sendWebhook(sb,sf,se,"Test")
		showNotif("Webhook","Test sent! #"..S.totalWebhookCount,C.WEBHOOK)
	end)
end)
UI.whTimerBtn.MouseButton1Click:Connect(function()
	if not S.webhookActive then showNotif("WH Timer","Enable Webhook first!",C.DANGER); return end
	if S.webhookTimerActive then
		stopWebhookTimer()
		smoothToggle(UI.whTimerBtn,false,C.WEBHOOK,C.CARD,"WH TIMER ON","WH TIMER OFF")
		showNotif("WH Timer","Disabled",C.DANGER)
	else
		startWebhookTimer()
		smoothToggle(UI.whTimerBtn,true,C.WEBHOOK,C.CARD,"WH TIMER ON","WH TIMER OFF")
		showNotif("WH Timer","Every "..math.floor(S.webhookIntervalSecs/60).." min",C.WEBHOOK)
	end
end)
UI.whTimerCfgBtn.MouseButton1Click:Connect(function()
	if S.webhookTimerPopupOpen then hideWhTimerPopup() else showWhTimerPopup() end
end)

local function applyWhInterval()
	local n=tonumber(whIntervalBox.Text); if not n or n<=0 then return end
	S.webhookIntervalSecs=n*60; S.webhookTimerCountdown=S.webhookIntervalSecs
	whIntervalBox.Text=""; whIntervalBox.PlaceholderText=tostring(n)
	whTimerInfoLbl.Text="Send every "..n.." min | Next in "..n.." min"
	if S.webhookTimerActive then stopWebhookTimer(); startWebhookTimer() end
	showNotif("WH Timer","Interval → "..n.." min",C.WEBHOOK)
end
setWhIntervalBtn.MouseButton1Click:Connect(applyWhInterval)
whIntervalBox.FocusLost:Connect(function(e) if e then applyWhInterval() end end)

local function applyFpsCap()
	local n=tonumber(UI.capBox.Text); if not n or n<=0 then return end
	pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate=n end)
	pcall(function() setfpscap(n) end)
	FPS_CAP=n; UI.capBox.Text=""; UI.capBox.PlaceholderText=tostring(n)
end
UI.setCapBtn.MouseButton1Click:Connect(applyFpsCap)
UI.capBox.FocusLost:Connect(function(e) if e then applyFpsCap() end end)

local function applyHopInterval()
	local n=tonumber(hopIntervalBox.Text); if not n or n<=0 then return end
	S.hopIntervalSecs=n*60; S.hopCountdown=S.hopIntervalSecs
	hopIntervalBox.Text=""; hopIntervalBox.PlaceholderText=tostring(n)
	showNotif("Auto Hop","Interval → "..n.." min",C.HOP)
end
setHopBtn.MouseButton1Click:Connect(applyHopInterval)
hopIntervalBox.FocusLost:Connect(function(e) if e then applyHopInterval() end end)
hopServerBox.FocusLost:Connect(function()
	S.hopTargetServer=hopServerBox.Text:lower()
	showNotif("Auto Hop",S.hopTargetServer=="" and "Target: all servers" or "Target: "..hopServerBox.Text,C.HOP)
end)

--Bring Mob handlers
UI.pullBtn.MouseButton1Click:Connect(function()
	if BM.active then
		stopBringMob()
		smoothToggle(UI.pullBtn, false, C.PULL, C.CARD, "PULL ON", "PULL OFF")
		showNotif("Bring Mob", "Disabled", C.DANGER)
	else
		startBringMob()
		smoothToggle(UI.pullBtn, true, C.PULL, C.CARD, "PULL ON", "PULL OFF")
		showNotif("Bring Mob", "Active | Dist="..BM.maxDist.." Batch="..BM.maxBatch, C.PULL)
	end
end)

local function applyDist()
	local n = tonumber(distBox.Text); if not n or n <= 0 then return end
	BM.maxDist = n
	distBox.Text = ""; distBox.PlaceholderText = "Dist: "..n
	showNotif("Bring Mob", "Max Dist → "..n, C.WARN)
end
setDistBtn.MouseButton1Click:Connect(applyDist)
distBox.FocusLost:Connect(function(e) if e then applyDist() end end)

local function applyForce()
	local n = tonumber(forceBox.Text); if not n or n <= 0 then return end
	BM.pullForce = n
	forceBox.Text = ""; forceBox.PlaceholderText = "Force: "..n
	showNotif("Bring Mob", "Force → "..n, C.WARN)
end
setForceBtn.MouseButton1Click:Connect(applyForce)
forceBox.FocusLost:Connect(function(e) if e then applyForce() end end)

local function applySnap()
	local n = tonumber(snapBox.Text); if not n or n <= 0 then return end
	BM.snapDist = n
	snapBox.Text = ""; snapBox.PlaceholderText = "Snap: "..n
	showNotif("Bring Mob", "Snap → "..n, C.WARN)
end
setSnapBtn.MouseButton1Click:Connect(applySnap)
snapBox.FocusLost:Connect(function(e) if e then applySnap() end end)

local function applyYOff()
	local n = tonumber(yOffBox.Text)
	if n == nil then return end
	BM.yOffset = n
	yOffBox.Text = ""; yOffBox.PlaceholderText = "Y: "..n
	showNotif("Bring Mob", "Y Offset → "..n, C.WARN)
end
setYOffBtn.MouseButton1Click:Connect(applyYOff)
yOffBox.FocusLost:Connect(function(e) if e then applyYOff() end end)

-- Hover effects
addHover(UI.v1Btn,   function() return S.boostV1Active    and C.V1COL  or C.CARD end)
addHover(UI.v2Btn,   function() return S.boostV2Active    and C.V2COL  or C.CARD end)
addHover(UI.hideBtn, function() return S.hidePlayersActive and C.WHITE  or C.CARD end)
addHover(UI.enemyBtn,function() return S.hideEnemiesActive and C.DANGER or C.CARD end)
addHover(UI.hopBtn,  function() return S.autoHopActive     and C.HOP   or C.CARD end)
addHover(UI.miniBtn, function() return C.CARD end)
addHover(UI.setCapBtn,function() return C.WHITE end)
addHover(UI.webhookBtn,function() return S.webhookActive and C.WEBHOOK or C.CARD end)
addHover(UI.testWebhookBtn,function() return C.CARD end)
addHover(UI.themeBtn,function() return C.CARD end)
addHover(UI.whTimerBtn,function() return S.webhookTimerActive and C.WEBHOOK or C.CARD end)
addHover(UI.whTimerCfgBtn,function() return C.CARD end)
addHover(UI.pullBtn,  function() return BM.active and C.PULL or C.CARD end)
addHover(setDistBtn,  function() return C.WHITE end)
addHover(setForceBtn, function() return C.WHITE end)
addHover(setSnapBtn,  function() return C.WHITE end)
addHover(setYOffBtn,  function() return C.WHITE end)

local function applyTheme(idx)
	curTheme=idx; local t=THEMES[idx]
	C.BG=t.bg; C.PANEL=t.panel; C.CARD=t.card; C.HOVER=t.hover
	C.SEP=t.sep; C.BORDER=t.border; C.BORDER2=t.border2; C.DIM=t.dim
	C.WHITE=t.accent; C.OFFWHITE=t.accent; C.MUTED=t.accentDim
	UI.themeBtn.Text="THEME: "..t.name
	local function recolor(panel)
		for _,obj in ipairs(panel:GetDescendants()) do
			if obj:IsA("Frame") and obj.BackgroundTransparency<1 then
				local r,g,b=obj.BackgroundColor3.R*255,obj.BackgroundColor3.G*255,obj.BackgroundColor3.B*255
				if r<30 and g<30 and b<30 and r>14 then tween(obj,{BackgroundColor3=t.card})
				elseif r<=14 and g<=14 and b<=14 and r>8 then tween(obj,{BackgroundColor3=t.panel})
				elseif r<=8 and g<=8 and b<=8 then tween(obj,{BackgroundColor3=t.bg})
				elseif r>=40 and r<80 and g==r and b==r then tween(obj,{BackgroundColor3=t.sep}) end
			end
			if obj:IsA("UIStroke") then tween(obj,{Color=t.border2}) end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				local r,g,b=obj.TextColor3.R*255,obj.TextColor3.G*255,obj.TextColor3.B*255
				if r>200 and g>200 and b>200 then tween(obj,{TextColor3=t.accent})
				elseif r>=160 and r<=200 and math.abs(r-g)<10 and math.abs(r-b)<10 then tween(obj,{TextColor3=t.accentDim})
				elseif r>=120 and r<=160 and math.abs(r-g)<10 and math.abs(r-b)<10 then tween(obj,{TextColor3=t.dim}) end
			end
		end
	end
	recolor(fullPanel); recolor(miniPanel)
	for _,pf in ipairs(plrRows) do if pf.row and pf.row.Parent then tween(pf.row,{BackgroundColor3=t.card}) end end
	for _,pf in ipairs(invRows) do if pf.cell and pf.cell.Parent then tween(pf.cell,{BackgroundColor3=t.card}) end end
	tween(fullPanel,{BackgroundColor3=t.panel}); tween(miniPanel,{BackgroundColor3=t.panel})
	tween(loadBarFill,{BackgroundColor3=t.accent}); tween(UI.serverBarFill,{BackgroundColor3=t.accent})
end
UI.themeBtn.MouseButton1Click:Connect(function() applyTheme((curTheme%#THEMES)+1) end)

-- UPDATE FUNCTIONS
local function setText(lb,val)
	if not lb or not lb.Parent or S.lastText[lb]==val then return end; S.lastText[lb]=val; lb.Text=val
end
local function setBarX(f,scale)
	local sv=math.clamp(scale,0,1); if S.lastSize[f]==sv then return end; S.lastSize[f]=sv
	if S.barTw[f] then S.barTw[f]:Cancel() end
	local tw=TS:Create(f,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(sv,0,1,0)}); tw:Play(); S.barTw[f]=tw
end
local function setColor(lb,col)
	if not lb or not lb.Parent or S.lastColor[lb]==col then return end; S.lastColor[lb]=col
	if S.colTw[lb] then S.colTw[lb]:Cancel() end
	local tw=TS:Create(lb,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextColor3=col}); tw:Play(); S.colTw[lb]=tw
end
local function setBgColor(f,col) tween(f,{BackgroundColor3=col},0.2) end

Run.RenderStepped:Connect(function()
	S.frameCount+=1; local n=tick()
	if n-S.lastFpsT>=0.5 then S.fps=math.floor(S.frameCount/(n-S.lastFpsT)); S.frameCount=0; S.lastFpsT=n end
end)

local function updateFast()
	local ping=getPing(); local e=tick()-S.scriptStart
	setText(UI.fpsLabel,"FPS "..S.fps); setText(UI.pingLabel,"PING "..ping.."ms")
	setText(UI.timeLabel,("%02d:%02d:%02d"):format(math.floor(e/3600),math.floor(e%3600/60),math.floor(e%60)))
	setColor(UI.pingLabel,ping<80 and C.SUCCESS or ping<150 and C.WARN or C.DANGER)
	setText(UI.miniFpsLbl,"FPS "..S.fps); setText(UI.miniPingLbl,ping.."ms")
	setText(UI.miniBeliLbl,formatVal(getStat("Beli"),"Beli"))
	setText(UI.miniFragLbl,formatVal(getStat("Fragments"),"Fragments"))
	UI.capBox.PlaceholderText=tostring(FPS_CAP)

	setText(UI.hopCountdownLbl,S.autoHopActive and (function()
		local sv=math.max(0,math.floor(S.hopCountdown))
		local h=math.floor(sv/3600); sv=sv%3600; local m=math.floor(sv/60); sv=sv%60
		return h>0 and ("%d:%02d:%02d"):format(h,m,sv) or ("%02d:%02d"):format(m,sv)
	end)() or "DISABLED")
	setColor(UI.hopCountdownLbl,S.autoHopActive and C.HOP or C.DIM)

	setText(UI.whTimerCountdownLbl, S.webhookTimerActive and (function()
		local sv=math.max(0,math.floor(S.webhookTimerCountdown))
		local h=math.floor(sv/3600); sv=sv%3600; local m=math.floor(sv/60); sv=sv%60
		return h>0 and ("%d:%02d:%02d  next send"):format(h,m,sv) or ("%02d:%02d  next send"):format(m,sv)
	end)() or "DISABLED")
	setColor(UI.whTimerCountdownLbl, S.webhookTimerActive and C.WEBHOOK or C.DIM)

	local pulledCount = 0
	for _ in pairs(BM.mobData) do pulledCount = pulledCount + 1 end
	setText(UI.pullCountLbl, BM.active and ("Pulled: "..pulledCount.." | Dist:"..BM.maxDist.." Y:"..BM.yOffset) or "Pull: OFF")
	setColor(UI.pullCountLbl, BM.active and C.PULL or C.DIM)
end

local function updateStats()
	local disp,name2=player.DisplayName,player.Name
	local ns=disp~=name2 and (disp.." (@"..name2..")") or name2
	setText(UI.charLabel,ns); setText(UI.miniNameLbl,ns)
	local lv=getStat("Level"); local lvStr="LV. "..formatVal(lv,"Level")
	setText(UI.lvlLabel,lvStr); setText(UI.miniLvlLbl,lvStr)
	setText(UI.beliLbl,formatVal(getStat("Beli"),"Beli"))
	setText(UI.fragLbl,formatVal(getStat("Fragments"),"Fragments"))
	local cb=getStat("Beli"); local cf=getStat("Fragments")
	if not S.sessionInit and cb and cf then S.sessionStartBeli=cb; S.sessionStartFragments=cf; S.sessionInit=true end
	if S.sessionInit then
		local gb=math.floor((cb or 0)-S.sessionStartBeli); local gf=math.floor((cf or 0)-S.sessionStartFragments)
		setText(UI.sessionBeliLbl,(gb>=0 and "+" or "")..formatVal(gb,"Beli"))
		setText(UI.sessionFragLbl,(gf>=0 and "+" or "")..formatVal(gf,"Fragments"))
		setColor(UI.sessionBeliLbl,gb>=0 and C.SUCCESS or C.DANGER)
		setColor(UI.sessionFragLbl,gf>=0 and C.SUCCESS or C.DANGER)
	end
	local function doStat(vl,bar,key)
		local v=getStat(key); setText(vl,formatVal(v))
		if bar then setBarX(bar,tonumber(v) and tonumber(v)/K.COMBAT_CAP or 0) end
	end
	doStat(UI.meleeLbl,UI.meleeBar,"Melee"); doStat(UI.defLbl,UI.defBar,"Defense")
	doStat(UI.swordLbl,UI.swordBar,"Sword"); doStat(UI.gunLbl,UI.gunBar,"Gun")
	local fv=getStat("Blox Fruit"); setText(UI.fruitLbl,formatVal(fv))
	if UI.fruitBar then setBarX(UI.fruitBar,tonumber(fv) and tonumber(fv)/K.COMBAT_CAP or 0) end
	local rn,rt=getRace(player)
	setText(UI.raceValLbl,rn and (rn..(rt and " [V"..rt.."]" or "")) or "Not V4")
	setText(UI.teamValLbl,player.Team and player.Team.Name or "N/A")
	local sp=getStat("SpawnPoint"); setText(UI.spawnValLbl,sp~=nil and tostring(sp) or "??")
end

local function updateRates()
	S.beliPerMin, S.beliPerHour = calcRate(S.beliHistory)
	S.fragPerMin, S.fragPerHour = calcRate(S.fragHistory)
	local function rateStr(v)
		local sg=v>=0 and "+" or ""
		if math.abs(v)>=1e6 then return sg..("%.1fM"):format(v/1e6)
		elseif math.abs(v)>=1e3 then return sg..("%.1fK"):format(v/1e3)
		else return sg..tostring(v) end
	end
	setText(UI.beliPerMinLbl,  rateStr(S.beliPerMin));  setColor(UI.beliPerMinLbl,  S.beliPerMin>=0  and C.SUCCESS or C.DANGER)
	setText(UI.beliPerHourLbl, rateStr(S.beliPerHour)); setColor(UI.beliPerHourLbl, S.beliPerHour>=0 and C.SUCCESS or C.DANGER)
	setText(UI.fragPerMinLbl,  rateStr(S.fragPerMin));  setColor(UI.fragPerMinLbl,  S.fragPerMin>=0  and C.SUCCESS or C.DANGER)
	setText(UI.fragPerHourLbl, rateStr(S.fragPerHour)); setColor(UI.fragPerHourLbl, S.fragPerHour>=0 and C.SUCCESS or C.DANGER)
end

local INV_STAT_COLORS={
	Sword=C.SUCCESS, Gun=C.FRIEND,
	["Blox Fruit"]=Color3.fromRGB(200,140,255),
	Defense=C.DIST, Melee=C.WARN
}

local function updateInventory()
	local en,elv=getEquippedItem()
	setText(UI.equipValLbl,en)
	if elv~=nil then
		setText(UI.equipLvlLbl,"LV "..fmtComma(elv)); setColor(UI.equipLvlLbl,C.WARN)
	else
		setText(UI.equipLvlLbl,en~="None" and "No Level" or ""); setColor(UI.equipLvlLbl,C.DIM)
	end
	local items=getInventory()
	for i=1,20 do
		local pf=invRows[i]; local item=items[i]
		if item then
			pf.cell.Visible=true
			local dn=item.statType and ("["..item.statType.."] "..item.name) or item.name
			setText(pf.nameLbl,dn); setColor(pf.nameLbl,INV_STAT_COLORS[item.statType] or C.OFFWHITE)
			setText(pf.lvlLbl,"LV "..math.floor(item.level))
			for _,key in ipairs(SKILL_KEYS) do pf.skillLbls[key].kl.Visible=false; pf.skillLbls[key].cl.Visible=false end
			local reqLevels=getSkillLevels(item.name); local slotIdx=0
			for _,key in ipairs(SKILL_KEYS) do
				local reqLv=reqLevels[key]
				if reqLv ~= nil and item.level ~= nil then
					local sl=pf.skillLbls[key]; local xPos=8+slotIdx*40
					sl.kl.Position=UDim2.new(0,xPos,0,27); sl.cl.Position=UDim2.new(0,xPos,0,38)
					sl.kl.Visible=true; sl.cl.Visible=true
					setText(sl.cl,item.level>=reqLv and "🟢" or "🔴")
					setColor(sl.cl,item.level>=reqLv and C.SUCCESS or C.DANGER)
					slotIdx=slotIdx+1
				end
			end
		else pf.cell.Visible=false end
	end
end

local function updatePlayers()
	local list=Players:GetPlayers(); local total=#list
	local ratio=math.clamp(total/K.MAX_PLAYERS,0,1)
	setText(UI.pcCountLbl,total.." / "..K.MAX_PLAYERS)
	local barCol=ratio>=1 and C.DANGER or ratio>=0.75 and C.WARN or C.WHITE
	setBgColor(UI.serverBarFill,barCol); setColor(UI.pcCountLbl,barCol); setBarX(UI.serverBarFill,ratio)
	local totalBounty=0
	for _,p in ipairs(list) do
		local cache=S.playerInfoCache[p.UserId]
		if cache and cache.bounty then totalBounty+=cache.bounty
		else local bObj=getStatObj(p,"Bounty"); if bObj then totalBounty+=bObj.Value or 0 end end
	end
	setText(UI.totalBountyLbl,fmtComma(totalBounty))
	local myChar=player.Character; local myRoot=myChar and myChar:FindFirstChild("HumanoidRootPart")
	local distCache={}
	for _,p in ipairs(list) do if p~=player then
		local d=math.huge
		if myRoot then local th=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if th then local ok,mag=pcall(function() return (myRoot.Position-th.Position).Magnitude end); if ok then d=mag end end end
		distCache[p.UserId]=d
	end end
	table.sort(list,function(a,b)
		if a==player then return true end; if b==player then return false end
		return (distCache[a.UserId] or math.huge)<(distCache[b.UserId] or math.huge)
	end)
	for i=1,20 do
		local pf=plrRows[i]; local p=list[i]
		if p and pf then
			pf.row.Visible=true
			local ns=p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name
			setText(pf.nameLbl,ns); setColor(pf.nameLbl,p==player and C.SUCCESS or C.WHITE)
			local plv=getStat("Level",p); setText(pf.lvlLbl,plv~=nil and ("LV"..formatVal(plv,"Level")) or "LV??")
			if p~=player then
				local sv,rv,rt2,bv
				pcall(function()
					local cache=S.playerInfoCache[p.UserId]
					if cache then sv=cache.spawn; rv=cache.race; rt2=cache.raceTier; bv=cache.bounty end
					if not sv or not rv then
						local d=p:FindFirstChild("Data")
						if d then
							if not sv then local sp=d:FindFirstChild("LastSpawnPoint"); if sp then sv=sp.Value end end
							if not rv then local rc=d:FindFirstChild("Race")
								if rc then
									if rc:IsA("ValueBase") and rc.Value~="" then rv=tostring(rc.Value) end
									for _,n in ipairs({"C","V","Tier","Level","T"}) do local c=rc:FindFirstChild(n)
										if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then rt2=c.Value; break end end
								end
							end
						end
					end
					if not bv then local bObj=getStatObj(p,"Bounty"); if bObj then bv=bObj.Value end end
				end)
				setText(pf.raceLbl,rv and ("Race: "..rv..(rt2 and " V/T "..rt2 or "")) or "Race: ?")
				setText(pf.spawnLbl,sv and ("LOCATION: "..sv) or "LOCATION: ?")
				setText(pf.bountyLbl,bv~=nil and ("Bounty: "..fmtComma(bv)) or "Bounty: ?")
				local rd=distCache[p.UserId] or math.huge
				setText(pf.distLbl,rd==math.huge and "?" or (fmtComma(math.floor(rd*K.STUDS_TO_M)).."m"))
				setColor(pf.distLbl,C.DIST)
				setText(pf.timeLbl,sessionTimeStr(S.playerInfoCache[p.UserId] and S.playerInfoCache[p.UserId].joinTime))
			else
				setText(pf.raceLbl,""); setText(pf.spawnLbl,""); setText(pf.bountyLbl,"")
				setText(pf.distLbl,"YOU"); setColor(pf.distLbl,C.SUCCESS)
				setText(pf.timeLbl,sessionTimeStr(S.playerInfoCache[player.UserId] and S.playerInfoCache[player.UserId].joinTime))
			end
		elseif pf then pf.row.Visible=false end
	end
end

-- AUTO HOP
local startAutoHop, stopAutoHop
local function doHop()
	local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0
	local sb=S.sessionInit and math.floor(cb-(S.sessionStartBeli or cb)) or 0
	local sf=S.sessionInit and math.floor(cf-(S.sessionStartFragments or cf)) or 0
	local se=tick()-(S.playerInfoCache[player.UserId] and S.playerInfoCache[player.UserId].joinTime or tick())
	S.totalHopCount+=1
	task.spawn(function() sendWebhook(sb,sf,se,"Auto Hop") end)
	local sb2=pg:FindFirstChild("ServerBrowser"); if not sb2 then return end
	sb2.Enabled=true; local frame=sb2:FindFirstChild("Frame")
	if frame then pcall(function() frame.Visible=true end) end
	pcall(function() frame.Filters.SearchRegion.TextBox.Text=S.hopTargetServer~="" and S.hopTargetServer or "" end)
	pcall(function() frame.Refresh:Activate() end); task.wait(3)
	local inside=frame and frame:FindFirstChild("FakeScroll") and frame.FakeScroll:FindFirstChild("Inside")
	if not inside then return end
	local tried={}
	local function tryHop()
		for _,child in ipairs(inside:GetChildren()) do
			if not child:IsA("Frame") then continue end
			local jb=child:FindFirstChild("Join"); if not jb or jb.Text~="Join" then continue end
			local tl=child:FindFirstChildOfClass("TextLabel"); if not tl then continue end
			if tl.Text:find("ERROR") then continue end
			local cur,max=tl.Text:match("Players: (%d+)/(%d+)"); cur=tonumber(cur); max=tonumber(max)
			if cur and max and cur>=max-1 then continue end
			local jobId=jb:GetAttribute("Job"); if not jobId or tried[jobId] then continue end
			tried[jobId]=true
			local fc; fc=game:GetService("TeleportService").TeleportInitFailed:Connect(function(_,_,msg)
				print("[AutoHop] Failed:",msg); if fc then fc:Disconnect(); fc=nil end; task.wait(1); tryHop()
			end)
			for _,c in ipairs(getconnections(jb.MouseButton1Click)) do c:Fire() end
			task.delay(5,function() if fc then fc:Disconnect(); fc=nil end end)
			return
		end
		tried={}; pcall(function() frame.Refresh:Activate() end); task.wait(3); tryHop()
	end
	tryHop()
end
local function autoHopLoop()
	S.hopLastTick=tick(); S.hopCountdown=S.hopIntervalSecs
	while S.autoHopActive do
		task.wait(1); local now=tick()
		S.hopCountdown=S.hopCountdown-(now-S.hopLastTick); S.hopLastTick=now
		if S.hopCountdown<=0 then S.hopCountdown=S.hopIntervalSecs; if S.autoHopActive then task.spawn(doHop) end end
	end
end
startAutoHop=function()
	S.autoHopActive=true; S.hopCountdown=S.hopIntervalSecs; S.hopLastTick=tick()
	if S.autoHopThread then task.cancel(S.autoHopThread) end
	S.autoHopThread=task.spawn(autoHopLoop)
end
stopAutoHop=function()
	S.autoHopActive=false
	if S.autoHopThread then task.cancel(S.autoHopThread); S.autoHopThread=nil end
	S.hopCountdown=S.hopIntervalSecs
	pcall(function() local sb=pg:FindFirstChild("ServerBrowser"); if sb then sb.Enabled=false; local f=sb:FindFirstChild("Frame"); if f then f.Visible=false end end end)
end
UI.hopBtn.MouseButton1Click:Connect(function()
	if S.autoHopActive then stopAutoHop(); smoothToggle(UI.hopBtn,false,C.HOP,C.CARD,"HOP ON","HOP OFF"); showNotif("Auto Hop","Disabled",C.DANGER); hideHopPopup()
	else startAutoHop(); smoothToggle(UI.hopBtn,true,C.HOP,C.CARD,"HOP ON","HOP OFF"); showNotif("Auto Hop","Enabled ("..math.floor(S.hopIntervalSecs/60).." min)",C.HOP) end
end)
UI.hopBtn.MouseButton2Click:Connect(function() if S.hopPopupOpen then hideHopPopup() else showHopPopup() end end)

Players.PlayerAdded:Connect(function(p)
	task.wait(1); local uid=p.UserId
	if not S.playerInfoCache[uid] then S.playerInfoCache[uid]={} end
	S.playerInfoCache[uid].joinTime=tick(); watchPlayerData(p)
	showNotif(p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name,"joined the server",C.SUCCESS)
end)
Players.PlayerRemoving:Connect(function(p)
	local uid=p.UserId
	showNotif(p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name,"left the server",C.DANGER)
	if S.spawnWatchers[uid]  then S.spawnWatchers[uid]:Disconnect();  S.spawnWatchers[uid]=nil  end
	if S.raceWatchers[uid]   then S.raceWatchers[uid]:Disconnect();   S.raceWatchers[uid]=nil   end
	if S.bountyWatchers[uid] then S.bountyWatchers[uid]:Disconnect(); S.bountyWatchers[uid]=nil end
	if S.hideCharConns[uid]  then S.hideCharConns[uid]:Disconnect();  S.hideCharConns[uid]=nil  end
	S.playerInfoCache[uid]=nil; S.statCache[uid]=nil; S.hiddenPlayersData[uid]=nil
	if S.spawnWatchers[uid] then S.spawnWatchers[uid]:Disconnect(); S.spawnWatchers[uid]=nil end
end)
for _,p in ipairs(Players:GetPlayers()) do if p~=player then watchPlayerData(p) end end
player.CharacterAdded:Connect(function(char)
    S.skillCache = {}
    if S.boostV2Active then V2_SKIP[char]=true end
end)

UIS.InputBegan:Connect(function(inp,gp)
	if gp then return end
	if inp.KeyCode==Enum.KeyCode.B then S.blackoutActive=not S.blackoutActive; blackoutFrame.Visible=S.blackoutActive; restoreBtn.Visible=S.blackoutActive end
	if inp.KeyCode==Enum.KeyCode.RightControl then setView(not S.isMini) end
	if inp.UserInputType==Enum.UserInputType.MouseButton1 then
		if S.hopPopupOpen then hideHopPopup() end
		if S.webhookTimerPopupOpen then hideWhTimerPopup() end
	end
end)

if config["Boost FPS V1"] then task.spawn(function() task.wait(2); S.boostV1Active=true; setMapVisibility(true) end) end
if config["Boost FPS V2"] then task.spawn(function() task.wait(2); S.boostV2Active=true; applyLowGraphic() end) end
if config["Remove Death Effect"] then
	local function rde() pcall(function() local r=game:GetService("ReplicatedStorage"); local d=r:WaitForChild("Effect",10):WaitForChild("Container",10):WaitForChild("Death",10); if d then d:Destroy() end end) end
	rde(); player.CharacterAdded:Connect(function() task.wait(0.5); rde() end)
end
if S.hidePlayersActive then task.spawn(function() task.wait(1); toggleHidePlayers(true) end) end
if S.hideEnemiesActive then task.spawn(function() task.wait(2); toggleHideEnemies(true) end) end
if config["Auto Hop"] then task.spawn(function() task.wait(6); startAutoHop() end) end

-- LOADING SEQUENCE
local LOAD_STEPS={"Loading account...","Loading username...","Loading level...","Loading beli...","Loading fragments...","Loading fruit...","Loading combat stats...","Loading inventory...","Loading players...","Loading performance..."}
task.spawn(function()
	local N=#LOAD_STEPS
	for _,step in ipairs(LOAD_STEPS) do loadStepLbl.Text=step; task.wait(0.08) end
	local s=tick()
	repeat
		local r=math.min((tick()-s)/(N*0.08),1); local ease=r*r*(3-2*r)
		if loadBarFill.Parent then loadBarFill.Size=UDim2.new(ease,0,1,0) end
		if loadPctLbl.Parent  then loadPctLbl.Text=math.floor(ease*100).."%" end
		if loadOverlay.Parent then loadOverlay.BackgroundTransparency=0.05+0.15*ease end
		Run.Heartbeat:Wait()
	until r >= 1
	if loadBarFill.Parent then loadBarFill.Size=UDim2.new(1,0,1,0) end
	if loadPctLbl.Parent  then loadPctLbl.Text="100%" end
	task.wait(0.1)
	if loadOverlay.Parent then
		local s2=tick()
		while loadOverlay.Parent do
			local r2=math.min((tick()-s2)/0.4,1); local ease=r2*r2*(3-2*r2)
			loadOverlay.BackgroundTransparency=ease
			for _,c in ipairs(loadOverlay:GetDescendants()) do pcall(function()
				if c:IsA("TextLabel") or c:IsA("TextButton") then c.TextTransparency=ease
				elseif c:IsA("Frame") then c.BackgroundTransparency=ease
				elseif c:IsA("UIStroke") then c.Transparency=ease end
			end) end
			if r2>=1 then break end; Run.Heartbeat:Wait()
		end
		if loadOverlay.Parent then loadOverlay:Destroy() end
	end
	task.spawn(function()
		if not player.Character then player.CharacterAdded:Wait() end
		local char=player.Character
		while not char:FindFirstChild("HumanoidRootPart") do task.wait(0.1) end
		local bp=player:WaitForChild("Backpack",10); if not bp then return end
		local hum=char:WaitForChild("Humanoid",10); if not hum then return end
		task.wait(1)
		for _,tool in ipairs(bp:GetChildren()) do
			if tool:IsA("Tool") then
				pcall(function() hum:EquipTool(tool) end); task.wait(0.08)
				S.skillCache[tool.Name]=getSkillLevels(tool.Name)
				pcall(function() hum:UnequipTools() end); task.wait(0.08)
			end
		end
	end)
	task.spawn(function() task.wait(0.1); while true do updateFast(); task.wait(0.05) end end)
	task.spawn(function() task.wait(0.3); updateStats(); updateInventory(); while true do task.wait(0.2); updateStats(); updateInventory() end end)
	task.spawn(function() task.wait(0.5); updatePlayers(); while true do task.wait(0.3); updatePlayers() end end)
	task.spawn(function()
		task.wait(2)
		while true do
			pushHistory(S.beliHistory, getStat("Beli"), K.HISTORY_MAX)
			pushHistory(S.fragHistory, getStat("Fragments"), K.HISTORY_MAX)
			task.wait(K.HISTORY_INTERVAL)
		end
	end)
	task.spawn(function()
		task.wait(12)
		while true do updateRates(); task.wait(5) end
	end)
end)
