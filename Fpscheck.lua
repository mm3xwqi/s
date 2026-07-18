--config = (function() return {
--	["Remove Death Effect"] = false,
--	["Lock Fps"]      = { ["Enabled"] = true, ["FPS"] = 120 },
--	["White Screen"]  = false,
--	["Boost FPS V1"]  = false,
--	["Boost FPS V2"]  = false,
--	["Hide Players"]  = true,
--	["Hide Enemies"]  = true,
--	["Auto Hop"]      = false,
--	["Hop Interval"]  = 45,
--	["Hop Server"]    = "singapore",
--	["Webhook Enabled"] = false,
--	["Webhook URL"]   = "YOUR_WEBHOOK",
--	["Webhook Name"]  = "Blox fruit Webhook",
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

-- ── Services ──────────────────────────────────────────────────────────
local Players   = game:GetService("Players")
local Run       = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local TS        = game:GetService("TweenService")
local Stats     = game:GetService("Stats")
local WS        = game:GetService("Workspace")
local player    = Players.LocalPlayer
local pg        = player:WaitForChild("PlayerGui")

if player.Character and player.Character:FindFirstChild("ESP_SelfHL") then
	player.Character.ESP_SelfHL:Destroy()
end

-- ── Colors ────────────────────────────────────────────────────────────
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
}

-- ── Themes ────────────────────────────────────────────────────────────
local THEMES = {
	{name="Default", accent=Color3.fromRGB(255,255,255), accentDim=Color3.fromRGB(180,180,180), bg=Color3.fromRGB(6,6,6),   panel=Color3.fromRGB(10,10,10), card=Color3.fromRGB(22,22,22), hover=Color3.fromRGB(32,32,32), sep=Color3.fromRGB(50,50,50),  border=Color3.fromRGB(70,70,70),  border2=Color3.fromRGB(100,100,100), dim=Color3.fromRGB(140,140,140)},
	{name="Cyan",    accent=Color3.fromRGB(80,220,255),  accentDim=Color3.fromRGB(60,160,200),  bg=Color3.fromRGB(2,10,14), panel=Color3.fromRGB(4,16,22),  card=Color3.fromRGB(6,26,36),  hover=Color3.fromRGB(10,40,54),  sep=Color3.fromRGB(20,70,90), border=Color3.fromRGB(30,100,130),border2=Color3.fromRGB(50,160,200),  dim=Color3.fromRGB(80,160,190)},
	{name="Green",   accent=Color3.fromRGB(100,220,130), accentDim=Color3.fromRGB(70,160,100),  bg=Color3.fromRGB(4,12,6),  panel=Color3.fromRGB(6,18,10),  card=Color3.fromRGB(8,28,14),  hover=Color3.fromRGB(12,42,20),  sep=Color3.fromRGB(20,70,35), border=Color3.fromRGB(30,100,50), border2=Color3.fromRGB(50,160,80),   dim=Color3.fromRGB(80,160,100)},
	{name="Orange",  accent=Color3.fromRGB(255,160,60),  accentDim=Color3.fromRGB(200,120,40),  bg=Color3.fromRGB(14,8,2),  panel=Color3.fromRGB(20,12,4),  card=Color3.fromRGB(30,18,6),  hover=Color3.fromRGB(44,26,8),   sep=Color3.fromRGB(80,48,14), border=Color3.fromRGB(110,70,20), border2=Color3.fromRGB(180,110,40),  dim=Color3.fromRGB(180,120,60)},
	{name="Pink",    accent=Color3.fromRGB(255,120,180), accentDim=Color3.fromRGB(200,80,140),  bg=Color3.fromRGB(14,4,10), panel=Color3.fromRGB(20,6,14),  card=Color3.fromRGB(30,8,22),  hover=Color3.fromRGB(44,12,32),  sep=Color3.fromRGB(80,24,58), border=Color3.fromRGB(110,36,82), border2=Color3.fromRGB(180,70,130),  dim=Color3.fromRGB(180,90,140)},
	{name="Purple",  accent=Color3.fromRGB(180,120,255), accentDim=Color3.fromRGB(130,80,200),  bg=Color3.fromRGB(8,4,14),  panel=Color3.fromRGB(12,6,20),  card=Color3.fromRGB(18,8,32),  hover=Color3.fromRGB(28,12,48),  sep=Color3.fromRGB(50,22,90), border=Color3.fromRGB(70,36,120), border2=Color3.fromRGB(110,60,190),  dim=Color3.fromRGB(130,90,190)},
}
local curTheme = 1

-- ── Constants ─────────────────────────────────────────────────────────
local MAX_PLAYERS  = Players.MaxPlayers
local COMBAT_CAP   = 2800
local STUDS_TO_M   = 0.28
local SKILL_KEYS   = {"Z","X","C","V","F"}
local HUD_W, HUD_H, PAD = 640, 600, 10
local HALF = HUD_W / 2

local FPS_CAP = config["Lock Fps"]["Enabled"] and config["Lock Fps"]["FPS"] or 60
if config["Lock Fps"]["Enabled"] then
	pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate = FPS_CAP end)
	pcall(function() setfpscap(FPS_CAP) end)
end

-- ── State ─────────────────────────────────────────────────────────────
local skillCache = {}
local boostV1Active, hiddenParts, boostV1Conn = false, {}, nil
local boostV2Active, v2DescConn, v2Orig = false, nil, {}
local hidePlayersActive = config["Hide Players"]
local hiddenPlayersData, hidePlayersConns, hideCharConns = {}, {}, {}
local hideEnemiesActive = config["Hide Enemies"]
local hiddenEnemyParts, enemyDescConn = {}, nil
local autoHopActive = config["Auto Hop"]
local autoHopThread = nil
local hopIntervalSecs = (config["Hop Interval"] or 30) * 60
local hopTargetServer = (config["Hop Server"] or ""):lower()
local hopCountdown, hopLastTick = hopIntervalSecs, tick()
local totalHopCount = 0
local webhookActive = config["Webhook Enabled"]
local sessionStartBeli, sessionStartFragments, sessionInit = nil, nil, false
local statCache = {}
local playerInfoCache = { [player.UserId] = { joinTime = tick() } }
local spawnWatchers, raceWatchers, bountyWatchers = {}, {}, {}

-- ── Helpers ───────────────────────────────────────────────────────────
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

-- ── Stat System ───────────────────────────────────────────────────────
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
		local ok,child = pcall(function() return obj:WaitForChild(part,5) end)
		if not ok or not child then return nil end
		obj = child
	end
	if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue")) then return obj end
	return nil
end
local function getStatObj(plr, key)
	local uid = plr.UserId
	if not statCache[uid] then statCache[uid]={} end
	local c = statCache[uid][key]
	if c ~= nil then return c ~= false and c or nil end
	local paths = STAT_PATHS[key] or {"leaderstats."..key,"Data."..key}
	for _, path in ipairs(paths) do
		local obj = resolvePath(plr, path)
		if obj then statCache[uid][key]=obj; return obj end
	end
	statCache[uid][key]=false; return nil
end
local function getStat(key, root)
	local obj = getStatObj(root or player, key)
	return obj and obj.Value or nil
end

-- ── FPS boost helpers ─────────────────────────────────────────────────
local function setMapVisibility(hide)
	if hide then
		hiddenParts={}
		for _,v in ipairs(WS:GetDescendants()) do
			pcall(function()
				if v:IsA("BasePart") then hiddenParts[#hiddenParts+1]={obj=v,tr=v.Transparency}; v.Transparency=1 end
			end)
		end
		if boostV1Conn then boostV1Conn:Disconnect() end
		boostV1Conn = WS.DescendantAdded:Connect(function(v)
			pcall(function() if v:IsA("BasePart") then v.Transparency=1 end end)
		end)
	else
		if boostV1Conn then boostV1Conn:Disconnect(); boostV1Conn=nil end
		for _,d in ipairs(hiddenParts) do
			if d.obj and d.obj.Parent then d.obj.Transparency=d.tr end
		end
		hiddenParts={}
	end
end

local V2_SKIP={}
local function buildV2Skip()
	V2_SKIP={}
	for _,s in ipairs({pg,game:GetService("ReplicatedStorage"),Players,game:GetService("CoreGui")}) do V2_SKIP[s]=true end
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
local function applyLowGraphic()
	buildV2Skip()
	local L=game:GetService("Lighting")
	v2Orig={GlobalShadows=L.GlobalShadows,FogEnd=L.FogEnd,ShadowSoftness=L.ShadowSoftness}
	L.GlobalShadows=false; L.FogEnd=9e9; L.ShadowSoftness=0
	pcall(function() sethiddenproperty(L,"Technology",2) end)
	v2Orig.QualityLevel=settings().Rendering.QualityLevel; settings().Rendering.QualityLevel=1
	pcall(function() v2Orig.MeshDetail=settings().Rendering.MeshPartDetailLevel; settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level04 end)
	local ter=WS:FindFirstChildOfClass("Terrain")
	if ter then
		v2Orig.WW=ter.WaterWaveSize; v2Orig.WS=ter.WaterWaveSpeed; v2Orig.WR=ter.WaterReflectance; v2Orig.WT=ter.WaterTransparency
		ter.WaterWaveSize=0; ter.WaterWaveSpeed=0; ter.WaterReflectance=0; ter.WaterTransparency=0
		pcall(function() sethiddenproperty(ter,"Decoration",false) end)
	end
	task.spawn(function()
		local all=WS:GetDescendants()
		for i=1,#all,150 do
			if not boostV2Active then break end
			for j=i,math.min(i+149,#all) do if not shouldSkip(all[j]) then pcall(applyObjGraphic,all[j]) end end
			task.wait()
		end
	end)
	if v2DescConn then v2DescConn:Disconnect() end
	v2DescConn=game.DescendantAdded:Connect(function(obj)
		if not boostV2Active or not obj:IsDescendantOf(WS) or shouldSkip(obj) then return end
		task.wait(0.3); if boostV2Active then pcall(applyObjGraphic,obj) end
	end)
end
local function removeLowGraphic()
	if v2DescConn then v2DescConn:Disconnect(); v2DescConn=nil end
	local L=game:GetService("Lighting")
	if v2Orig.GlobalShadows~=nil then L.GlobalShadows=v2Orig.GlobalShadows end
	if v2Orig.FogEnd~=nil then L.FogEnd=v2Orig.FogEnd end
	if v2Orig.ShadowSoftness~=nil then L.ShadowSoftness=v2Orig.ShadowSoftness end
	pcall(function() settings().Rendering.QualityLevel=v2Orig.QualityLevel or 5 end)
	pcall(function() if v2Orig.MeshDetail then settings().Rendering.MeshPartDetailLevel=v2Orig.MeshDetail end end)
	local ter=WS:FindFirstChildOfClass("Terrain")
	if ter then
		if v2Orig.WW~=nil then ter.WaterWaveSize=v2Orig.WW end
		if v2Orig.WS~=nil then ter.WaterWaveSpeed=v2Orig.WS end
		if v2Orig.WR~=nil then ter.WaterReflectance=v2Orig.WR end
		if v2Orig.WT~=nil then ter.WaterTransparency=v2Orig.WT end
	end
	v2Orig={}
end

-- ── Hide Players ──────────────────────────────────────────────────────
local function setPlayerVis(plr, visible)
	local char=plr.Character; if not char then return end
	if not visible then
		if hiddenPlayersData[plr.UserId] then return end
		hiddenPlayersData[plr.UserId]=true; pcall(function() char:Destroy() end)
	else hiddenPlayersData[plr.UserId]=nil end
end
local function watchChar(p)
	if p==player then return end
	local uid=p.UserId
	if hideCharConns[uid] then hideCharConns[uid]:Disconnect() end
	hideCharConns[uid]=p.CharacterAdded:Connect(function()
		hiddenPlayersData[uid]=nil
		if hidePlayersActive then task.wait(0.5); setPlayerVis(p,false) end
	end)
end
local function toggleHidePlayers(active)
	hidePlayersActive=active
	for _,p in ipairs(Players:GetPlayers()) do if p~=player then setPlayerVis(p,not active) end end
	if active then
		for _,p in ipairs(Players:GetPlayers()) do if p~=player then watchChar(p) end end
		if not hidePlayersConns.pa then
			hidePlayersConns.pa=Players.PlayerAdded:Connect(function(p)
				if p==player then return end
				watchChar(p)
				task.spawn(function()
					if not p.Character then p.CharacterAdded:Wait() end
					task.wait(0.5); if hidePlayersActive then setPlayerVis(p,false) end
				end)
			end)
		end
		if not hidePlayersConns.ca then
			hidePlayersConns.ca=player.CharacterAdded:Connect(function()
				task.wait(0.5)
				for _,p in ipairs(Players:GetPlayers()) do if p~=player then setPlayerVis(p,true) end end
			end)
		end
	else
		if hidePlayersConns.pa then hidePlayersConns.pa:Disconnect(); hidePlayersConns.pa=nil end
		if hidePlayersConns.ca then hidePlayersConns.ca:Disconnect(); hidePlayersConns.ca=nil end
		for uid,conn in pairs(hideCharConns) do conn:Disconnect(); hideCharConns[uid]=nil end
	end
end

-- ── Hide Enemies ──────────────────────────────────────────────────────
local function setEnemyHide(part, hide)
	if hide then
		if hiddenEnemyParts[part]~=nil then return end
		hiddenEnemyParts[part]=part.Transparency; part.Transparency=1
	else
		if hiddenEnemyParts[part]==nil then return end
		if part and part.Parent then part.Transparency=hiddenEnemyParts[part] end
		hiddenEnemyParts[part]=nil
	end
end
local function toggleHideEnemies(active)
	hideEnemiesActive=active
	local ef=WS:FindFirstChild("Enemies"); if not ef then return end
	for _,obj in ipairs(ef:GetDescendants()) do if obj:IsA("BasePart") then pcall(setEnemyHide,obj,active) end end
	if active then
		if not enemyDescConn then
			enemyDescConn=ef.DescendantAdded:Connect(function(obj)
				if hideEnemiesActive and obj:IsA("BasePart") then task.wait(0.1); pcall(setEnemyHide,obj,true) end
			end)
		end
	else
		if enemyDescConn then enemyDescConn:Disconnect(); enemyDescConn=nil end
		for part,tr in pairs(hiddenEnemyParts) do if part and part.Parent then pcall(function() part.Transparency=tr end) end end
		hiddenEnemyParts={}
	end
end

-- ── Player Data Watchers ──────────────────────────────────────────────
local function watchPlayerData(p)
	if p==player then return end
	local uid=p.UserId
	if not playerInfoCache[uid] then playerInfoCache[uid]={joinTime=tick()} end
	-- spawn
	task.spawn(function()
		local d=p:FindFirstChild("Data") or p:WaitForChild("Data",30); if not d then return end
		local sp=d:FindFirstChild("LastSpawnPoint") or d:WaitForChild("LastSpawnPoint",30); if not sp then return end
		playerInfoCache[uid].spawn=sp.Value
		if spawnWatchers[uid] then spawnWatchers[uid]:Disconnect() end
		spawnWatchers[uid]=sp.Changed:Connect(function(v) playerInfoCache[uid]=playerInfoCache[uid] or {}; playerInfoCache[uid].spawn=v end)
	end)
	-- race
	task.spawn(function()
		local d=p:FindFirstChild("Data") or p:WaitForChild("Data",30); if not d then return end
		local rc=d:FindFirstChild("Race") or d:WaitForChild("Race",30); if not rc then return end
		playerInfoCache[uid].race=rc:IsA("ValueBase") and rc.Value~="" and tostring(rc.Value) or nil
		local cObj=rc:FindFirstChild("C")
		if cObj then playerInfoCache[uid].raceTier=cObj.Value end
		if raceWatchers[uid] then raceWatchers[uid]:Disconnect() end
		raceWatchers[uid]=rc.Changed:Connect(function(v) playerInfoCache[uid]=playerInfoCache[uid] or {}; if v~="" then playerInfoCache[uid].race=tostring(v) end end)
	end)
	-- bounty
	task.spawn(function()
		local bObj=getStatObj(p,"Bounty")
		if not bObj then task.wait(3); bObj=getStatObj(p,"Bounty") end; if not bObj then return end
		playerInfoCache[uid].bounty=bObj.Value
		if bountyWatchers[uid] then bountyWatchers[uid]:Disconnect() end
		bountyWatchers[uid]=bObj.Changed:Connect(function(v) playerInfoCache[uid]=playerInfoCache[uid] or {}; playerInfoCache[uid].bounty=v end)
	end)
end

-- ── Webhook ───────────────────────────────────────────────────────────
local function sendWebhook(sessBeli, sessFrags, sessElap)
	if not config["Webhook Enabled"] then return end
	local url=config["Webhook URL"]; if not url or url=="" or url:find("YOUR_ID") then return end
	local curLv=getStat("Level") or 0
	local pName=player.DisplayName~=player.Name and (player.DisplayName.." (@"..player.Name..")") or player.Name
	local minInSvr=math.max(sessElap/60,0.01)
	local jobId="unknown"; pcall(function() jobId=game.JobId end)
	local payload={
		username=config["Webhook Name"] or "Blox Hub",
		embeds={{
			author={name="Auto Hop Triggered"},
			title="Session Summary — Hopping Server",
			color=sessBeli>=0 and 5832543 or 15548997,
			fields={
				{name="Player",value="```"..pName.."```",inline=true},
				{name="Level",value="```"..math.floor(curLv).."```",inline=true},
				{name="Hop #",value="```#"..totalHopCount.."```",inline=true},
				{name="Time in Server",value="```"..elapsedStr(sessElap).."```",inline=true},
				{name="Beli Gained",value="```"..wFmt(sessBeli).."```",inline=true},
				{name="Fragments Gained",value="```"..wFmt(sessFrags).."```",inline=true},
				{name="Beli / Min",value="```"..wFmt(math.floor(sessBeli/minInSvr)).."```",inline=true},
				{name="Frags / Min",value="```"..wFmt(math.floor(sessFrags/minInSvr)).."```",inline=true},
				{name="Hop Target",value="```"..(hopTargetServer~="" and hopTargetServer or "all").."```",inline=true},
				{name="Hop Time",value="```"..getLocalTimeStr().."```",inline=true},
				{name="Job ID (Prev Server)",value="```"..tostring(jobId):sub(1,36).."```",inline=false},
			},
			footer={text="Blox Hub  •  Auto Hop"},
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
		if res then print("[Webhook] Status:",res.StatusCode) end
	end)
end

-- ── Inventory helpers ─────────────────────────────────────────────────
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
local SKIP_TOOLTIPS = { ["JobTool"] = true, [""] = true, ["Wear"] = true }

local function getInventory()
    local items = {}
    local skipItems = {}
    local bp = player:FindFirstChild("Backpack")
    if not bp then return items end
    
    for _, o in ipairs(bp:GetChildren()) do
        if o:IsA("Tool") and o.Name ~= "Tool" then
            local lv = getToolLevel(o)
            if lv ~= nil then
                local tip = ""
                pcall(function() tip = o.ToolTip or "" end)
                local statType = getToolStatType(o)
                
                if SKIP_TOOLTIPS[tip] then
                    skipItems[#skipItems + 1] = {name=o.Name, level=lv, statType=statType}
                else
                    items[#items + 1] = {name=o.Name, level=lv, statType=statType}
                end
            end
        end
    end
    for _, v in ipairs(skipItems) do
        items[#items + 1] = v
    end
    
    return items
end
local function getSkillLevels(itemName)
    if skillCache[itemName] then return skillCache[itemName] end

    local res = {}
    local SKIP_SKILL_ITEMS = { 
    ["Fishing Rod"] = true, 
    ["Kitsune Ribbon"] = true, 
    ["Tool"] = true,
    ["Awakening"] = true,
    ["Heightened Senses"] = true,
}
    if SKIP_SKILL_ITEMS[itemName] then return res end

    local ok, skillFolder = pcall(function()
        return pg:WaitForChild("Main", 3)
                  :WaitForChild("Skills", 3)
                  :WaitForChild(itemName, 3)
    end)
    if not ok or not skillFolder then return res end

    for _, child in ipairs(skillFolder:GetChildren()) do
        if child.Name == "Template" then continue end
        if not child:IsA("Frame") then continue end

        local key = child.Name
        local lvObj = child:FindFirstChild("Level")
        if lvObj then
            local val
            if lvObj:IsA("TextLabel") or lvObj:IsA("TextButton") then
                -- extract เฉพาะตัวเลขจาก text เช่น "Lv. 100" → 100
                val = tonumber(lvObj.Text:match("%d+"))
            elseif lvObj:IsA("IntValue") or lvObj:IsA("NumberValue") then
                val = lvObj.Value
            end
            if val then res[key] = val end
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

-- ═══════════════════════════════════════════════════════════════════════
-- ── GUI BUILD ──────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════
local gui = mk("ScreenGui",pg,{Name="IntegratedStatusHUD",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=10})
local hudPos = UDim2.new(0.5,-HUD_W/2,0.5,-HUD_H/2)

-- ── Full Panel ────────────────────────────────────────────────────────
local fullPanel = mk("Frame",gui,{Size=UDim2.new(0,HUD_W,0,HUD_H),Position=hudPos,BackgroundColor3=C.PANEL,BorderSizePixel=0,ClipsDescendants=false})
stroke(fullPanel,C.BORDER2,2); corner(fullPanel,8)

-- ── Mini Panel (wider: 740px to fit FRAG column) ──────────────────────
local MINI_W = 740
local miniPanel = mk("Frame",gui,{
	Size=UDim2.new(0,MINI_W,0,44),
	Position=UDim2.new(0.5,-MINI_W/2,0.5,-HUD_H/2),
	BackgroundColor3=C.PANEL,BorderSizePixel=0,Visible=false
})
stroke(miniPanel,C.BORDER2,2); corner(miniPanel,5)

-- ── Load overlay ──────────────────────────────────────────────────────
local loadOverlay = mk("Frame",gui,{Size=UDim2.new(0,HUD_W,0,HUD_H),Position=hudPos,BackgroundColor3=C.BG,ZIndex=50})
corner(loadOverlay,8); stroke(loadOverlay,C.BORDER2,2)
lbl(loadOverlay,{sz=UDim2.new(1,0,0,28),pos=UDim2.new(0,0,0.38,-14),size=16,color=C.WHITE,text="Account Info",align=Enum.TextXAlignment.Center,z=52})
local loadStepLbl  = lbl(loadOverlay,{sz=UDim2.new(1,-60,0,16),pos=UDim2.new(0,30,0.38,18),font=Enum.Font.Gotham,size=12,color=C.MUTED,text="Initializing...",align=Enum.TextXAlignment.Center,z=52})
local loadTrackBg  = mk("Frame",loadOverlay,{Size=UDim2.new(1,-60,0,3),Position=UDim2.new(0,30,0.38,40),BackgroundColor3=C.BORDER,BorderSizePixel=0,ZIndex=52}); corner(loadTrackBg,2)
local loadBarFill  = mk("Frame",loadTrackBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.WHITE,BorderSizePixel=0,ZIndex=53}); corner(loadBarFill,2)
local loadPctLbl   = lbl(loadOverlay,{sz=UDim2.new(1,-60,0,14),pos=UDim2.new(0,30,0.38,48),font=Enum.Font.GothamBold,size=10,color=C.DIM,text="0%",align=Enum.TextXAlignment.Right,z=52})

-- ── Notification ──────────────────────────────────────────────────────
local notifFrame = mk("Frame",gui,{Size=UDim2.new(0,260,0,44),Position=UDim2.new(1,-270,0,60),BackgroundColor3=C.PANEL,ZIndex=60,Visible=false})
stroke(notifFrame,C.BORDER2,1); corner(notifFrame,6)
local notifDot    = mk("Frame",notifFrame,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,10,0,10),BackgroundColor3=C.SUCCESS,ZIndex=61}); corner(notifDot,4)
local notifName   = lbl(notifFrame,{sz=UDim2.new(1,-28,0,16),pos=UDim2.new(0,24,0,4),size=11,color=C.WHITE,text="",trunc=Enum.TextTruncate.AtEnd,z=61})
local notifSub    = lbl(notifFrame,{sz=UDim2.new(1,-28,0,12),pos=UDim2.new(0,24,0,24),font=Enum.Font.Gotham,size=9,color=C.DIM,text="",z=61})
local notifQ={};  local notifBusy=false
local NI=TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local NO=TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
local function showNotif(name,action,col)
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

-- ── Drag ──────────────────────────────────────────────────────────────
local dragging,dragStart,dragStartPos=false,nil,nil
fullPanel.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true; dragStart=inp.Position; dragStartPos=fullPanel.Position
	end
end)
UIS.InputChanged:Connect(function(inp)
	if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
		local ok,d=pcall(function() return inp.Position-dragStart end); if not ok then dragging=false; return end
		local np=UDim2.new(dragStartPos.X.Scale,dragStartPos.X.Offset+d.X,dragStartPos.Y.Scale,dragStartPos.Y.Offset+d.Y)
		fullPanel.Position=np; miniPanel.Position=np; loadOverlay.Position=np
	end
end)
UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- ── Full panel separators ─────────────────────────────────────────────
mk("Frame",fullPanel,{Size=UDim2.new(0,1,0,HUD_H-PAD*2),Position=UDim2.new(0,HALF,0,PAD),BackgroundColor3=C.SEP,ZIndex=3})
mk("Frame",fullPanel,{Size=UDim2.new(0,HUD_W-PAD*2,0,1),Position=UDim2.new(0,PAD,0,HUD_H/2),BackgroundColor3=C.SEP,ZIndex=3})

-- ── Quadrant coords ───────────────────────────────────────────────────
local Q1X,Q1Y,Q1W = PAD,       PAD,         HALF-PAD*2
local Q2X,Q2Y,Q2W = HALF+PAD,  PAD,         HALF-PAD*2
local Q3X,Q3Y,Q3W = PAD,       HUD_H/2+PAD, HALF-PAD*2
local Q4X,Q4Y,Q4W = HALF+PAD,  HUD_H/2+PAD, HALF-PAD*2

-- ── stat block builder ────────────────────────────────────────────────
local function statBlock(x,y,w,labelTxt,barColor)
	lbl(fullPanel,{sz=UDim2.new(0,w-4,0,12),pos=UDim2.new(0,x,0,y),size=9,color=C.DIM,text=labelTxt,z=4})
	local vl=lbl(fullPanel,{sz=UDim2.new(0,w-4,0,17),pos=UDim2.new(0,x,0,y+12),size=13,color=C.OFFWHITE,text="0",trunc=Enum.TextTruncate.AtEnd,z=4})
	local bf
	if barColor then
		local bb=mk("Frame",fullPanel,{Size=UDim2.new(0,w-8,0,3),Position=UDim2.new(0,x,0,y+31),BackgroundColor3=C.BORDER,BorderSizePixel=0,ZIndex=4}); corner(bb,1)
		bf=mk("Frame",bb,{Size=UDim2.new(0,0,1,0),BackgroundColor3=barColor,BorderSizePixel=0,ZIndex=5}); corner(bf,1)
	end
	return vl,bf
end

-- ═══════════════ Q1 — Player Info ═════════════════════════════════════
local UI = {}
UI.avatar=mk("ImageLabel",fullPanel,{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,Q1X,0,Q1Y),BackgroundColor3=C.CARD,ZIndex=4})
stroke(UI.avatar,C.BORDER2,2); corner(UI.avatar,5)
UI.charLabel= lbl(fullPanel,{sz=UDim2.new(0,Q1W-58,0,16),pos=UDim2.new(0,Q1X+56,0,Q1Y),   size=12,color=C.WHITE, text="Loading...",trunc=Enum.TextTruncate.AtEnd,z=4})
UI.lvlLabel = lbl(fullPanel,{sz=UDim2.new(0,Q1W-58,0,13),pos=UDim2.new(0,Q1X+56,0,Q1Y+18),size=10,color=C.MUTED,text="LV. 0",z=4})
UI.onlineDot= mk("Frame",fullPanel,{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,Q1X+56,0,Q1Y+36),BackgroundColor3=C.SUCCESS,ZIndex=4}); corner(UI.onlineDot,4)
lbl(fullPanel,{sz=UDim2.new(0,55,0,11),pos=UDim2.new(0,Q1X+67,0,Q1Y+34),size=9,color=C.DIM,text="ONLINE",z=4})
task.spawn(function()
	while true do
		tween(UI.onlineDot,{BackgroundTransparency=0.5},0.8); task.wait(0.8)
		tween(UI.onlineDot,{BackgroundTransparency=0},0.8); task.wait(0.8)
	end
end)
local colW3=math.floor(Q1W/3)
local function miniRow(x,y,w,lbTxt,vlTxt)
	lbl(fullPanel,{sz=UDim2.new(0,w,0,11),pos=UDim2.new(0,x,0,y),size=9,color=C.DIM,text=lbTxt,z=4})
	return lbl(fullPanel,{sz=UDim2.new(0,w,0,13),pos=UDim2.new(0,x,0,y+11),size=11,color=C.OFFWHITE,text=vlTxt,trunc=Enum.TextTruncate.AtEnd,z=4})
end
UI.raceValLbl = miniRow(Q1X,        Q1Y+64,colW3-4,"RACE","???")
UI.teamValLbl = miniRow(Q1X+colW3,  Q1Y+64,colW3-4,"TEAM","N/A")
UI.spawnValLbl= miniRow(Q1X+colW3*2,Q1Y+64,colW3-4,"SPAWN","???")
UI.fpsLabel   = lbl(fullPanel,{sz=UDim2.new(0,Q1W,0,14),pos=UDim2.new(0,Q1X,0,Q1Y+92), size=12,color=C.OFFWHITE,text="FPS 0",z=4})
UI.pingLabel  = lbl(fullPanel,{sz=UDim2.new(0,Q1W,0,14),pos=UDim2.new(0,Q1X,0,Q1Y+108),size=12,color=C.OFFWHITE,text="PING 0ms",z=4})
UI.timeLabel  = lbl(fullPanel,{sz=UDim2.new(0,Q1W,0,13),pos=UDim2.new(0,Q1X,0,Q1Y+124),font=Enum.Font.Gotham,size=10,color=C.DIM,text="00:00:00",z=4})

local function mkBtn(x,y,w,h,txt,isOn,col)
	local b=mk("TextButton",fullPanel,{Size=UDim2.new(0,w,0,h),Position=UDim2.new(0,x,0,y),
		BackgroundColor3=isOn and col or C.CARD,BorderSizePixel=0,
		Text=txt,TextColor3=isOn and C.BG or C.MUTED,TextSize=10,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4})
	stroke(b,C.BORDER2,1); corner(b,4); return b
end
local bW=math.floor((Q1W-6)/2)
UI.v1Btn   =mkBtn(Q1X,        Q1Y+142,bW,20,config["Boost FPS V1"] and "V1 ON" or "V1 OFF",config["Boost FPS V1"],C.V1COL)
UI.v2Btn   =mkBtn(Q1X+bW+6,   Q1Y+142,bW,20,config["Boost FPS V2"] and "V2 ON" or "V2 OFF",config["Boost FPS V2"],C.V2COL)
UI.hideBtn =mkBtn(Q1X,        Q1Y+166,bW,20,hidePlayersActive and "Del Player ON" or "Del Player OFF",hidePlayersActive,C.WHITE)
UI.miniBtn =mkBtn(Q1X+bW+6,   Q1Y+166,bW,20,"MINIMIZE",false,C.CARD); UI.miniBtn.TextColor3=C.MUTED
UI.enemyBtn=mkBtn(Q1X,        Q1Y+190,bW,20,hideEnemiesActive and "HIDE ENEMY ON" or "HIDE ENEMY OFF",hideEnemiesActive,C.DANGER)
UI.hopBtn  =mkBtn(Q1X+bW+6,   Q1Y+190,bW,20,autoHopActive and "HOP ON" or "HOP OFF",autoHopActive,C.HOP)
UI.capBox  =mk("TextBox",fullPanel,{Size=UDim2.new(0,bW-34,0,20),Position=UDim2.new(0,Q1X,0,Q1Y+214),
	BackgroundColor3=C.CARD,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.WHITE,
	Text="",PlaceholderText=tostring(FPS_CAP),PlaceholderColor3=C.DIM,ZIndex=4})
stroke(UI.capBox,C.BORDER2,1); corner(UI.capBox,4)
UI.setCapBtn=mkBtn(Q1X+bW-28,Q1Y+214,28,20,"SET",true,C.WHITE); UI.setCapBtn.TextColor3=C.BG
UI.themeBtn =mkBtn(Q1X+bW+6, Q1Y+214,bW,20,"THEME: Default",false,C.CARD); UI.themeBtn.TextColor3=C.MUTED
local WH_W=math.floor((Q1W-4)*0.60); local TEST_W=Q1W-WH_W-4
UI.webhookBtn    =mkBtn(Q1X,       Q1Y+238,WH_W,20,webhookActive and "WEBHOOK ON" or "WEBHOOK OFF",webhookActive,Color3.fromRGB(88,176,255))
UI.testWebhookBtn=mkBtn(Q1X+WH_W+4,Q1Y+238,TEST_W,20,"TEST SEND",false,C.CARD); UI.testWebhookBtn.TextColor3=Color3.fromRGB(255,200,60)
lbl(fullPanel,{sz=UDim2.new(0,Q1W,0,10),pos=UDim2.new(0,Q1X,0,Q1Y+264),size=8,color=C.DIM,text="HOP COUNTDOWN",z=4})
UI.hopCountdownLbl=lbl(fullPanel,{sz=UDim2.new(0,Q1W,0,14),pos=UDim2.new(0,Q1X,0,Q1Y+274),font=Enum.Font.GothamBold,size=11,color=C.HOP,text="DISABLED",z=4})

-- Hop popup
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
local hopPopupOpen=false
local function showHopPopup()
	local ap=fullPanel.AbsolutePosition
	hopPopup.Position=UDim2.new(0,ap.X+Q1X+bW+6,0,ap.Y+Q1Y+190+24)
	hopPopup.Visible=true; hopPopupOpen=true
end
local function hideHopPopup() hopPopup.Visible=false; hopPopupOpen=false end

-- ═══════════════ Q2 — Stats ════════════════════════════════════════════
local sRH=36
UI.beliLbl,_          =statBlock(Q2X,Q2Y+0,    Q2W,"BELI",nil)
UI.fragLbl,_          =statBlock(Q2X,Q2Y+sRH,  Q2W,"FRAGMENTS",nil)
UI.meleeLbl,UI.meleeBar=statBlock(Q2X,Q2Y+sRH*2,Q2W,"MELEE",C.V1COL)
UI.defLbl,  UI.defBar  =statBlock(Q2X,Q2Y+sRH*3,Q2W,"DEFENSE",C.V1COL)
UI.swordLbl,UI.swordBar=statBlock(Q2X,Q2Y+sRH*4,Q2W,"SWORD",C.V1COL)
UI.gunLbl,  UI.gunBar  =statBlock(Q2X,Q2Y+sRH*5,Q2W,"GUN",C.V1COL)
UI.fruitLbl,UI.fruitBar=statBlock(Q2X,Q2Y+sRH*6,Q2W,"BLOX FRUIT",C.WARN)
local sessY=Q2Y+sRH*7+4
mk("Frame",fullPanel,{Size=UDim2.new(0,Q2W-4,0,1),Position=UDim2.new(0,Q2X,0,sessY-3),BackgroundColor3=C.SEP,ZIndex=4})
lbl(fullPanel,{sz=UDim2.new(0,Q2W/2-2,0,10),pos=UDim2.new(0,Q2X,0,sessY),size=8,color=C.DIM,text="SESSION BELI",z=4})
UI.sessionBeliLbl=lbl(fullPanel,{sz=UDim2.new(0,Q2W/2-2,0,15),pos=UDim2.new(0,Q2X,0,sessY+10),size=12,color=C.SUCCESS,text="+0",z=4})
lbl(fullPanel,{sz=UDim2.new(0,Q2W/2-2,0,10),pos=UDim2.new(0,Q2X+Q2W/2,0,sessY),size=8,color=C.DIM,text="SESSION FRAG",align=Enum.TextXAlignment.Right,z=4})
UI.sessionFragLbl=lbl(fullPanel,{sz=UDim2.new(0,Q2W/2-2,0,15),pos=UDim2.new(0,Q2X+Q2W/2,0,sessY+10),size=12,color=C.WARN,text="+0",align=Enum.TextXAlignment.Right,z=4})

-- ═══════════════ Q3 — Players ══════════════════════════════════════════
lbl(fullPanel,{sz=UDim2.new(0,Q3W,0,12),pos=UDim2.new(0,Q3X,0,Q3Y),size=9,color=C.DIM,text="PLAYERS",z=4})
UI.pcCountLbl=lbl(fullPanel,{sz=UDim2.new(0,100,0,18),pos=UDim2.new(0,Q3X,0,Q3Y+12),size=14,color=C.WHITE,text="? / "..MAX_PLAYERS,z=4})
local svrBarBg=mk("Frame",fullPanel,{Size=UDim2.new(0,Q3W,0,3),Position=UDim2.new(0,Q3X,0,Q3Y+32),BackgroundColor3=C.BORDER,ZIndex=4}); corner(svrBarBg,1)
UI.serverBarFill=mk("Frame",svrBarBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.WHITE,ZIndex=5}); corner(UI.serverBarFill,1)
lbl(fullPanel,{sz=UDim2.new(0,Q3W/2,0,12),pos=UDim2.new(0,Q3X+Q3W/2,0,Q3Y),size=9,color=C.DIM,text="TOTAL BOUNTY",align=Enum.TextXAlignment.Right,z=4})
UI.totalBountyLbl=lbl(fullPanel,{sz=UDim2.new(0,Q3W/2,0,18),pos=UDim2.new(0,Q3X+Q3W/2,0,Q3Y+12),size=12,color=C.BOUNTY,text="0",align=Enum.TextXAlignment.Right,z=4})
local plrScroll=mk("ScrollingFrame",fullPanel,{Size=UDim2.new(0,Q3W,0,HUD_H/2-PAD*2-42),Position=UDim2.new(0,Q3X,0,Q3Y+38),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BORDER2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=3})
mk("UIListLayout",plrScroll,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding",plrScroll,{PaddingBottom=UDim.new(0,2)})
local plrRows={}
for i=1,20 do
	local row=mk("Frame",plrScroll,{Size=UDim2.new(1,-4,0,58),BackgroundColor3=C.CARD,ZIndex=4,LayoutOrder=i,Visible=false})
	stroke(row,C.BORDER2,1); corner(row,4)
	plrRows[i]={
		row=row,
		nameLbl =lbl(row,{sz=UDim2.new(1,-62,0,14),pos=UDim2.new(0,6,0,2), size=11,color=C.WHITE, text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		lvlLbl  =lbl(row,{sz=UDim2.new(0,56,0,14), pos=UDim2.new(1,-60,0,2), size=10,color=C.MUTED,text="",align=Enum.TextXAlignment.Right,z=5}),
		raceLbl =lbl(row,{sz=UDim2.new(0,90,0,12), pos=UDim2.new(0,6,0,18), font=Enum.Font.Gotham,size=9,color=C.FRIEND,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		spawnLbl=lbl(row,{sz=UDim2.new(1,-100,0,12),pos=UDim2.new(0,100,0,18),font=Enum.Font.Gotham,size=9,color=C.DIM,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		bountyLbl=lbl(row,{sz=UDim2.new(1,-90,0,12),pos=UDim2.new(0,6,0,32),font=Enum.Font.Gotham,size=9,color=C.BOUNTY,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		distLbl =lbl(row,{sz=UDim2.new(0,80,0,12), pos=UDim2.new(1,-84,0,32),font=Enum.Font.Gotham,size=9,color=C.DIST,text="",align=Enum.TextXAlignment.Right,z=5}),
		timeLbl =lbl(row,{sz=UDim2.new(1,-6,0,12), pos=UDim2.new(0,6,0,46), font=Enum.Font.Gotham,size=9,color=Color3.fromRGB(180,220,255),text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
	}
end

-- ═══════════════ Q4 — Inventory ════════════════════════════════════════
lbl(fullPanel,{sz=UDim2.new(0,Q4W,0,12),pos=UDim2.new(0,Q4X,0,Q4Y),size=9,color=C.DIM,text="EQUIPPED",z=4})
UI.equipValLbl=lbl(fullPanel,{sz=UDim2.new(0,Q4W,0,17),pos=UDim2.new(0,Q4X,0,Q4Y+12),size=13,color=C.OFFWHITE,text="None",trunc=Enum.TextTruncate.AtEnd,z=4})
UI.equipLvlLbl=lbl(fullPanel,{sz=UDim2.new(0,Q4W,0,13),pos=UDim2.new(0,Q4X,0,Q4Y+30),font=Enum.Font.GothamBold,size=10,color=C.WARN,text="",z=4})
lbl(fullPanel,{sz=UDim2.new(0,Q4W,0,12),pos=UDim2.new(0,Q4X,0,Q4Y+48),size=9,color=C.DIM,text="INVENTORY",z=4})
local invScroll=mk("ScrollingFrame",fullPanel,{Size=UDim2.new(0,Q4W,0,HUD_H/2-PAD-62-2),Position=UDim2.new(0,Q4X,0,Q4Y+62),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BORDER2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=3})
mk("UIListLayout",invScroll,{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding",invScroll,{PaddingBottom=UDim.new(0,2)})
local invRows={}
for i=1,20 do
	local cell=mk("Frame",invScroll,{Size=UDim2.new(1,-4,0,42),BackgroundColor3=C.CARD,ZIndex=4,LayoutOrder=i,Visible=false})
	stroke(cell,C.BORDER2,1); corner(cell,4)
	local nameLbl=lbl(cell,{sz=UDim2.new(1,-70,0,20),pos=UDim2.new(0,8,0,0),size=11,color=C.OFFWHITE,text="",trunc=Enum.TextTruncate.AtEnd,z=5})
	local lvlLbl =lbl(cell,{sz=UDim2.new(0,60,0,20), pos=UDim2.new(1,-66,0,0),size=10,color=C.WARN,   text="",align=Enum.TextXAlignment.Right,z=5})
	local skillLbls={}
	local slotW=36
	for si,key in ipairs(SKILL_KEYS) do
		local kl=lbl(cell,{sz=UDim2.new(0,slotW,0,10),pos=UDim2.new(0,8+(si-1)*slotW,0,20),size=8,color=C.DIM,text=key,align=Enum.TextXAlignment.Center,z=5})
		local cl=lbl(cell,{sz=UDim2.new(0,slotW,0,14),pos=UDim2.new(0,8+(si-1)*slotW,0,28),size=12,color=C.SUCCESS,text="",align=Enum.TextXAlignment.Center,z=5})
		skillLbls[key]={kl=kl,cl=cl}
	end
	invRows[i]={cell=cell,nameLbl=nameLbl,lvlLbl=lvlLbl,skillLbls=skillLbls}
end

-- ═══════════════ MINI PANEL ════════════════════════════════════════════
-- Layout: [Avatar] [Name+LV] | [FPS] | [PING] | [BELI] | [FRAG] | [▼]
UI.miniAva=mk("ImageLabel",miniPanel,{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,6,0,8),BackgroundColor3=C.CARD,ZIndex=3})
stroke(UI.miniAva,C.BORDER2,1); corner(UI.miniAva,4)
task.spawn(function()
	local ok,t=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
	if ok and t then UI.miniAva.Image=t; UI.avatar.Image=t end
end)
UI.miniNameLbl=lbl(miniPanel,{sz=UDim2.new(0,120,0,16),pos=UDim2.new(0,38,0,6), size=12,color=C.WHITE,text="Loading...",z=3})
UI.miniLvlLbl =lbl(miniPanel,{sz=UDim2.new(0,90,0,12), pos=UDim2.new(0,38,0,24),font=Enum.Font.Gotham,size=10,color=C.DIM,text="LV. 0",z=3})

local function miniCol(x, labelTxt, isHighlight)
	local col = isHighlight and C.FRAG or C.WHITE
	lbl(miniPanel,{sz=UDim2.new(0,90,0,12),pos=UDim2.new(0,x,0,6), size=9, color=C.DIM, text=labelTxt,z=3})
	return lbl(miniPanel,{sz=UDim2.new(0,90,0,16),pos=UDim2.new(0,x,0,22),size=12,color=col,text="...",z=3})
end
UI.miniFpsLbl  = miniCol(170, "FPS")
UI.miniPingLbl = miniCol(270, "PING")
UI.miniBeliLbl = miniCol(370, "BELI")
UI.miniFragLbl = miniCol(470, "FRAG", true)  -- ← NEW: Fragment column

-- ── separator between BELI and FRAG ──────────────────────────────────
mk("Frame",miniPanel,{Size=UDim2.new(0,1,0,28),Position=UDim2.new(0,466,0,8),BackgroundColor3=C.SEP,ZIndex=3})

local expandBtn=mk("TextButton",miniPanel,{Size=UDim2.new(0,30,0,26),Position=UDim2.new(1,-36,0,9),BackgroundColor3=C.CARD,BorderSizePixel=0,Text="▼",TextColor3=C.MUTED,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=5})
stroke(expandBtn,C.BORDER2,1); corner(expandBtn,4)

-- ── Misc ──────────────────────────────────────────────────────────────
local blackoutFrame=mk("Frame",gui,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),ZIndex=1,Visible=false})
local restoreBtn=mk("TextButton",gui,{Size=UDim2.new(0,96,0,32),AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-30),BackgroundColor3=C.WHITE,BorderSizePixel=0,Text="RESTORE",TextColor3=C.BG,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,Visible=false,ZIndex=51})
local blackoutActive=false
local function setBlackout(state) blackoutActive=state; blackoutFrame.Visible=state; restoreBtn.Visible=state end
if config["White Screen"] then setBlackout(true) end
restoreBtn.MouseButton1Click:Connect(function() setBlackout(false) end)

local selfHL
local function applyHL(char)
	if selfHL and selfHL.Parent then selfHL:Destroy() end; selfHL=nil
	if not char then return end
	local hl=Instance.new("Highlight"); hl.Name="ESP_SelfHL"
	hl.FillColor=Color3.fromRGB(255,255,255); hl.OutlineColor=Color3.new(0,0,0)
	hl.FillTransparency=0.5; hl.OutlineTransparency=0
	hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=char; hl.Parent=char; selfHL=hl
end
if player.Character then task.delay(0.5,function() applyHL(player.Character) end) end
player.CharacterAdded:Connect(function(char) task.wait(0.5); applyHL(char) end)

-- ═══════════════════════════════════════════════════════════════════════
-- ── VIEW TOGGLE ────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════
local isMini=false
local function setView(mini)
	isMini=mini
	if mini then
		tween(fullPanel,{BackgroundTransparency=1},0.18)
		task.delay(0.18,function() fullPanel.Visible=false; fullPanel.BackgroundTransparency=0 end)
		miniPanel.BackgroundTransparency=1; miniPanel.Visible=true
		tween(miniPanel,{BackgroundTransparency=0},0.18)
	else
		tween(miniPanel,{BackgroundTransparency=1},0.18)
		task.delay(0.18,function() miniPanel.Visible=false; miniPanel.BackgroundTransparency=0 end)
		fullPanel.BackgroundTransparency=1; fullPanel.Visible=true
		tween(fullPanel,{BackgroundTransparency=0},0.18)
	end
end
expandBtn.MouseButton1Click:Connect(function() setView(false) end)
expandBtn.MouseEnter:Connect(function() tween(expandBtn,{BackgroundColor3=C.HOVER},0.12) end)
expandBtn.MouseLeave:Connect(function() tween(expandBtn,{BackgroundColor3=C.CARD},0.12) end)
UI.miniBtn.MouseButton1Click:Connect(function() setView(true) end)

-- ── Button logic ──────────────────────────────────────────────────────
local function addHover(btn,getCol)
	btn.MouseEnter:Connect(function() tween(btn,{BackgroundColor3=C.HOVER},0.12) end)
	btn.MouseLeave:Connect(function() tween(btn,{BackgroundColor3=getCol()},0.12) end)
end
local function smoothToggle(btn,active,onCol,offCol,onTxt,offTxt)
	tween(btn,{BackgroundColor3=active and onCol or offCol},0.18)
	btn.Text=active and onTxt or offTxt; btn.TextColor3=active and C.BG or C.MUTED
end

UI.v1Btn.MouseButton1Click:Connect(function()
	boostV1Active=not boostV1Active
	if boostV1Active then task.spawn(function() setMapVisibility(true) end) else task.spawn(function() setMapVisibility(false) end) end
	smoothToggle(UI.v1Btn,boostV1Active,C.V1COL,C.CARD,"V1 ON","V1 OFF")
end)
UI.v2Btn.MouseButton1Click:Connect(function()
	boostV2Active=not boostV2Active
	if boostV2Active then task.spawn(applyLowGraphic) else task.spawn(removeLowGraphic) end
	smoothToggle(UI.v2Btn,boostV2Active,C.V2COL,C.CARD,"V2 ON","V2 OFF")
end)
UI.hideBtn.MouseButton1Click:Connect(function()
	hidePlayersActive=not hidePlayersActive; toggleHidePlayers(hidePlayersActive)
	smoothToggle(UI.hideBtn,hidePlayersActive,C.WHITE,C.CARD,"DEL PLAYER ON","DEL PLAYER OFF")
end)
UI.enemyBtn.MouseButton1Click:Connect(function()
	hideEnemiesActive=not hideEnemiesActive; task.spawn(function() toggleHideEnemies(hideEnemiesActive) end)
	smoothToggle(UI.enemyBtn,hideEnemiesActive,C.DANGER,C.CARD,"HIDE ENEMY ON","HIDE ENEMY OFF")
end)
local WH_COL=Color3.fromRGB(88,176,255)
UI.webhookBtn.MouseButton1Click:Connect(function()
	webhookActive=not webhookActive; config["Webhook Enabled"]=webhookActive
	smoothToggle(UI.webhookBtn,webhookActive,WH_COL,C.CARD,"WEBHOOK ON","WEBHOOK OFF")
	showNotif("Webhook",webhookActive and "Enabled" or "Disabled",webhookActive and WH_COL or C.DANGER)
end)
UI.testWebhookBtn.MouseButton1Click:Connect(function()
	task.spawn(function()
		totalHopCount=totalHopCount+1
		local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0
		local sb=sessionInit and math.floor(cb-(sessionStartBeli or cb)) or 0
		local sf=sessionInit and math.floor(cf-(sessionStartFragments or cf)) or 0
		local se=tick()-(playerInfoCache[player.UserId] and playerInfoCache[player.UserId].joinTime or tick())
		sendWebhook(sb,sf,se); showNotif("Webhook","Test sent! #"..totalHopCount,WH_COL)
	end)
end)
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
	hopIntervalSecs=n*60; hopCountdown=hopIntervalSecs
	hopIntervalBox.Text=""; hopIntervalBox.PlaceholderText=tostring(n)
	showNotif("Auto Hop","Interval → "..n.." min",C.HOP)
end
setHopBtn.MouseButton1Click:Connect(applyHopInterval)
hopIntervalBox.FocusLost:Connect(function(e) if e then applyHopInterval() end end)
hopServerBox.FocusLost:Connect(function()
	hopTargetServer=hopServerBox.Text:lower()
	showNotif("Auto Hop",hopTargetServer=="" and "Target: all servers" or "Target: "..hopServerBox.Text,C.HOP)
end)
addHover(UI.v1Btn,   function() return boostV1Active    and C.V1COL  or C.CARD end)
addHover(UI.v2Btn,   function() return boostV2Active    and C.V2COL  or C.CARD end)
addHover(UI.hideBtn, function() return hidePlayersActive and C.WHITE  or C.CARD end)
addHover(UI.enemyBtn,function() return hideEnemiesActive and C.DANGER or C.CARD end)
addHover(UI.hopBtn,  function() return autoHopActive     and C.HOP   or C.CARD end)
addHover(UI.miniBtn, function() return C.CARD end)
addHover(UI.setCapBtn,function() return C.WHITE end)
addHover(UI.webhookBtn,function() return webhookActive and WH_COL or C.CARD end)
addHover(UI.testWebhookBtn,function() return C.CARD end)
addHover(UI.themeBtn,function() return C.CARD end)

-- ── Theme ─────────────────────────────────────────────────────────────
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

-- ═══════════════════════════════════════════════════════════════════════
-- ── UPDATE FUNCTIONS ───────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════
local lastText,lastSize,lastColor={},{},{}
local barTw,colTw={},{}
local function setText(lb,val)
	if not lb or not lb.Parent or lastText[lb]==val then return end; lastText[lb]=val; lb.Text=val
end
local function setBarX(f,scale)
	local s=math.clamp(scale,0,1); if lastSize[f]==s then return end; lastSize[f]=s
	if barTw[f] then barTw[f]:Cancel() end
	local tw=TS:Create(f,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(s,0,1,0)}); tw:Play(); barTw[f]=tw
end
local function setColor(lb,col)
	if not lb or not lb.Parent or lastColor[lb]==col then return end; lastColor[lb]=col
	if colTw[lb] then colTw[lb]:Cancel() end
	local tw=TS:Create(lb,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextColor3=col}); tw:Play(); colTw[lb]=tw
end
local function setBgColor(f,col) tween(f,{BackgroundColor3=col},0.2) end

local fps,frameCount,lastFpsT=0,0,tick()
Run.RenderStepped:Connect(function()
	frameCount+=1; local n=tick()
	if n-lastFpsT>=0.5 then fps=math.floor(frameCount/(n-lastFpsT)); frameCount=0; lastFpsT=n end
end)
local function getPing()
	local ok,p=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"] end)
	return ok and type(p)=="number" and math.floor(p) or math.floor(player:GetNetworkPing()*1000)
end

local scriptStart=tick()
local function updateFast()
	local ping=getPing(); local e=tick()-scriptStart
	setText(UI.fpsLabel,"FPS "..fps); setText(UI.pingLabel,"PING "..ping.."ms")
	setText(UI.timeLabel,("%02d:%02d:%02d"):format(math.floor(e/3600),math.floor(e%3600/60),math.floor(e%60)))
	setColor(UI.pingLabel,ping<80 and C.SUCCESS or ping<150 and C.WARN or C.DANGER)
	setText(UI.miniFpsLbl,"FPS "..fps); setText(UI.miniPingLbl,ping.."ms")
	setText(UI.miniBeliLbl,formatVal(getStat("Beli"),"Beli"))
	setText(UI.miniFragLbl,formatVal(getStat("Fragments"),"Fragments"))  -- ← FRAGMENT in mini
	UI.capBox.PlaceholderText=tostring(FPS_CAP)
	setText(UI.hopCountdownLbl,autoHopActive and (function()
		local s=math.max(0,math.floor(hopCountdown))
		local h=math.floor(s/3600); s=s%3600; local m=math.floor(s/60); s=s%60
		return h>0 and ("%d:%02d:%02d"):format(h,m,s) or ("%02d:%02d"):format(m,s)
	end)() or "DISABLED")
	setColor(UI.hopCountdownLbl,autoHopActive and C.HOP or C.DIM)
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
	if not sessionInit and cb and cf then sessionStartBeli=cb; sessionStartFragments=cf; sessionInit=true end
	if sessionInit then
		local gb=math.floor((cb or 0)-sessionStartBeli); local gf=math.floor((cf or 0)-sessionStartFragments)
		setText(UI.sessionBeliLbl,(gb>=0 and "+" or "")..formatVal(gb,"Beli"))
		setText(UI.sessionFragLbl,(gf>=0 and "+" or "")..formatVal(gf,"Fragments"))
		setColor(UI.sessionBeliLbl,gb>=0 and C.SUCCESS or C.DANGER)
		setColor(UI.sessionFragLbl,gf>=0 and C.SUCCESS or C.DANGER)
	end
	local function doStat(vl,bar,key)
		local v=getStat(key); setText(vl,formatVal(v))
		if bar then setBarX(bar,tonumber(v) and tonumber(v)/COMBAT_CAP or 0) end
	end
	doStat(UI.meleeLbl,UI.meleeBar,"Melee"); doStat(UI.defLbl,UI.defBar,"Defense")
	doStat(UI.swordLbl,UI.swordBar,"Sword"); doStat(UI.gunLbl,UI.gunBar,"Gun")
	local fv=getStat("Blox Fruit"); setText(UI.fruitLbl,formatVal(fv))
	if UI.fruitBar then setBarX(UI.fruitBar,tonumber(fv) and tonumber(fv)/COMBAT_CAP or 0) end
	local rn,rt=getRace(player)
	setText(UI.raceValLbl,rn and (rn..(rt and " [V"..rt.."]" or "")) or "Not V4")
	setText(UI.teamValLbl,player.Team and player.Team.Name or "N/A")
	local sp=getStat("SpawnPoint"); setText(UI.spawnValLbl,sp~=nil and tostring(sp) or "??")
end

local INV_STAT_COLORS={Sword=C.SUCCESS,Gun=C.FRIEND,["Blox Fruit"]=Color3.fromRGB(200,140,255),Defense=C.DIST,Melee=C.WARN}
local function updateInventory()
    local en, elv = getEquippedItem()
    setText(UI.equipValLbl, en)
    if elv ~= nil then
        setText(UI.equipLvlLbl, "LV " .. fmtComma(elv))
        setColor(UI.equipLvlLbl, C.WARN)
    else
        setText(UI.equipLvlLbl, en ~= "None" and "No Level" or "")
        setColor(UI.equipLvlLbl, C.DIM)
    end

    local items = getInventory()
    for i = 1, 20 do
        local pf = invRows[i]
        local item = items[i]
        if item then
            pf.cell.Visible = true
            local dn = item.statType and ("[" .. item.statType .. "] " .. item.name) or item.name
            setText(pf.nameLbl, dn)
            setColor(pf.nameLbl, INV_STAT_COLORS[item.statType] or C.OFFWHITE)
            setText(pf.lvlLbl, "LV " .. math.floor(item.level))

            local reqLevels = getSkillLevels(item.name)

            -- ซ่อนทุก slot ก่อน
            for _, key in ipairs(SKILL_KEYS) do
                local sl = pf.skillLbls[key]
                if sl then
                    sl.kl.Visible = false
                    sl.cl.Visible = false
                end
            end

            -- แสดงเฉพาะ key ที่มีจริง
            local slotIdx = 0
            local slotW = 36
            for key, reqLv in pairs(reqLevels) do
                -- สร้าง label ถ้ายังไม่มี
                if not pf.skillLbls[key] then
                    local kl = lbl(pf.cell, {
                        sz = UDim2.new(0, slotW, 0, 10),
                        pos = UDim2.new(0, 8 + slotIdx * slotW, 0, 20),
                        size = 8, color = C.DIM, text = key,
                        align = Enum.TextXAlignment.Center, z = 5
                    })
                    local cl = lbl(pf.cell, {
                        sz = UDim2.new(0, slotW, 0, 14),
                        pos = UDim2.new(0, 8 + slotIdx * slotW, 0, 28),
                        size = 12, color = C.SUCCESS, text = "",
                        align = Enum.TextXAlignment.Center, z = 5
                    })
                    pf.skillLbls[key] = { kl = kl, cl = cl }
                end

                local sl = pf.skillLbls[key]
                sl.kl.Visible = true
                sl.cl.Visible = true
                setText(sl.cl, item.level >= reqLv and "✔" or "✘")
                setColor(sl.cl, item.level >= reqLv and C.SUCCESS or C.DANGER)
                slotIdx = slotIdx + 1
            end
        else
            pf.cell.Visible = false
        end
    end
end

local function updatePlayers()
	local list=Players:GetPlayers(); local total=#list
	local ratio=math.clamp(total/MAX_PLAYERS,0,1)
	setText(UI.pcCountLbl,total.." / "..MAX_PLAYERS)
	local barCol=ratio>=1 and C.DANGER or ratio>=0.75 and C.WARN or C.WHITE
	setBgColor(UI.serverBarFill,barCol); setColor(UI.pcCountLbl,barCol); setBarX(UI.serverBarFill,ratio)
	local totalBounty=0
	for _,p in ipairs(list) do
		local cache=playerInfoCache[p.UserId]
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
					local cache=playerInfoCache[p.UserId]
					if cache then sv=cache.spawn; rv=cache.race; rt2=cache.raceTier; bv=cache.bounty end
					if not sv or not rv then
						local d=p:FindFirstChild("Data")
						if d then
							if not sv then local s=d:FindFirstChild("LastSpawnPoint"); if s then sv=s.Value end end
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
				setText(pf.distLbl,rd==math.huge and "?" or (fmtComma(math.floor(rd*STUDS_TO_M)).."m"))
				setColor(pf.distLbl,C.DIST)
				setText(pf.timeLbl,sessionTimeStr(playerInfoCache[p.UserId] and playerInfoCache[p.UserId].joinTime))
			else
				setText(pf.raceLbl,""); setText(pf.spawnLbl,""); setText(pf.bountyLbl,"")
				setText(pf.distLbl,"YOU"); setColor(pf.distLbl,C.SUCCESS)
				setText(pf.timeLbl,sessionTimeStr(playerInfoCache[player.UserId] and playerInfoCache[player.UserId].joinTime))
			end
		elseif pf then pf.row.Visible=false end
	end
end

-- ═══════════════════════════════════════════════════════════════════════
-- ── AUTO HOP ───────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════
local startAutoHop, stopAutoHop
local function doHop()
	local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0
	local sb=sessionInit and math.floor(cb-(sessionStartBeli or cb)) or 0
	local sf=sessionInit and math.floor(cf-(sessionStartFragments or cf)) or 0
	local se=tick()-(playerInfoCache[player.UserId] and playerInfoCache[player.UserId].joinTime or tick())
	totalHopCount+=1; task.spawn(function() sendWebhook(sb,sf,se) end)
	local sb2=pg:FindFirstChild("ServerBrowser"); if not sb2 then return end
	sb2.Enabled=true; local frame=sb2:FindFirstChild("Frame")
	if frame then pcall(function() frame.Visible=true end) end
	pcall(function() frame.Filters.SearchRegion.TextBox.Text=hopTargetServer~="" and hopTargetServer or "" end)
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
	hopLastTick=tick(); hopCountdown=hopIntervalSecs
	while autoHopActive do
		task.wait(1); local now=tick()
		hopCountdown=hopCountdown-(now-hopLastTick); hopLastTick=now
		if hopCountdown<=0 then hopCountdown=hopIntervalSecs; if autoHopActive then task.spawn(doHop) end end
	end
end
startAutoHop=function()
	autoHopActive=true; hopCountdown=hopIntervalSecs; hopLastTick=tick()
	if autoHopThread then task.cancel(autoHopThread) end
	autoHopThread=task.spawn(autoHopLoop)
end
stopAutoHop=function()
	autoHopActive=false
	if autoHopThread then task.cancel(autoHopThread); autoHopThread=nil end
	hopCountdown=hopIntervalSecs
	pcall(function() local sb=pg:FindFirstChild("ServerBrowser"); if sb then sb.Enabled=false; local f=sb:FindFirstChild("Frame"); if f then f.Visible=false end end end)
end
UI.hopBtn.MouseButton1Click:Connect(function()
	if autoHopActive then stopAutoHop(); smoothToggle(UI.hopBtn,false,C.HOP,C.CARD,"HOP ON","HOP OFF"); showNotif("Auto Hop","Disabled",C.DANGER); hideHopPopup()
	else startAutoHop(); smoothToggle(UI.hopBtn,true,C.HOP,C.CARD,"HOP ON","HOP OFF"); showNotif("Auto Hop","Enabled ("..math.floor(hopIntervalSecs/60).." min)",C.HOP) end
end)
UI.hopBtn.MouseButton2Click:Connect(function() if hopPopupOpen then hideHopPopup() else showHopPopup() end end)

-- ── Player events ─────────────────────────────────────────────────────
Players.PlayerAdded:Connect(function(p)
	task.wait(1); local uid=p.UserId
	if not playerInfoCache[uid] then playerInfoCache[uid]={} end
	playerInfoCache[uid].joinTime=tick()
	watchPlayerData(p)
	showNotif(p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name,"joined the server",C.SUCCESS)
end)
Players.PlayerRemoving:Connect(function(p)
	local uid=p.UserId
	showNotif(p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name,"left the server",C.DANGER)
	if spawnWatchers[uid]   then spawnWatchers[uid]:Disconnect();   spawnWatchers[uid]=nil   end
	if raceWatchers[uid]    then raceWatchers[uid]:Disconnect();    raceWatchers[uid]=nil    end
	if bountyWatchers[uid]  then bountyWatchers[uid]:Disconnect();  bountyWatchers[uid]=nil  end
	if hideCharConns[uid]   then hideCharConns[uid]:Disconnect();   hideCharConns[uid]=nil   end
	playerInfoCache[uid]=nil; statCache[uid]=nil; hiddenPlayersData[uid]=nil
end)
for _,p in ipairs(Players:GetPlayers()) do if p~=player then watchPlayerData(p) end end
player.CharacterAdded:Connect(function(char)
	if boostV2Active then V2_SKIP[char]=true end
end)

UIS.InputBegan:Connect(function(inp,gp)
	if gp then return end
	if inp.KeyCode==Enum.KeyCode.B then setBlackout(not blackoutActive) end
	if inp.KeyCode==Enum.KeyCode.RightControl then setView(not isMini) end
	if inp.UserInputType==Enum.UserInputType.MouseButton1 and hopPopupOpen then hideHopPopup() end
end)

if config["Boost FPS V1"] then task.spawn(function() task.wait(2); boostV1Active=true; setMapVisibility(true) end) end
if config["Boost FPS V2"] then task.spawn(function() task.wait(2); boostV2Active=true; applyLowGraphic() end) end
if config["Remove Death Effect"] then
	local function rde() pcall(function() local r=game:GetService("ReplicatedStorage"); local d=r:WaitForChild("Effect",10):WaitForChild("Container",10):WaitForChild("Death",10); if d then d:Destroy() end end) end
	rde(); player.CharacterAdded:Connect(function() task.wait(0.5); rde() end)
end
if hidePlayersActive then task.spawn(function() task.wait(1); toggleHidePlayers(true) end) end
if hideEnemiesActive then task.spawn(function() task.wait(2); toggleHideEnemies(true) end) end
if config["Auto Hop"] then task.spawn(function() task.wait(6); startAutoHop() end) end

-- ═══════════════════════════════════════════════════════════════════════
-- ── LOADING SEQUENCE ───────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════
local LOAD_STEPS={
	"Loading account...", "Loading username...", "Loading level...",
	"Loading beli...", "Loading fragments...", "Loading fruit...",
	"Loading combat stats...", "Loading inventory...", "Loading players...", "Loading performance..."
}
task.spawn(function()
	local N=#LOAD_STEPS; local DUR=0.15
	for i,step in ipairs(LOAD_STEPS) do
		loadStepLbl.Text=step; task.wait(DUR)
	end
	local s=tick()
	repeat
		local r=math.min((tick()-s)/(N*DUR),1); local ease=r*r*(3-2*r)
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
		local char = player.Character
		while not char:FindFirstChild("HumanoidRootPart") do task.wait(0.1) end
		local bp = player:WaitForChild("Backpack", 10)
		if not bp then return end
		local hum = char:WaitForChild("Humanoid", 10)
		if not hum then return end
		task.wait(1)
		for _, tool in ipairs(bp:GetChildren()) do
			if tool:IsA("Tool") then
				pcall(function() hum:EquipTool(tool) end)
				task.wait(.2)
				skillCache[tool.Name] = getSkillLevels(tool.Name)

				print("[Cache] tool:", tool.Name, "keys:")
				for k,v in pairs(skillCache[tool.Name]) do
					print("  ->", k, "=", v)
				end
				
				pcall(function() hum:UnequipTools() end)
				task.wait(0.2)
			end
		end
		end)
	-- ── Start update loops ───────────────────────────────────────────
	task.spawn(function() while true do updateFast(); task.wait(0.05) end end)
	task.spawn(function() updateStats(); updateInventory(); while true do task.wait(0.2); updateStats(); updateInventory() end end)
	task.spawn(function() updatePlayers(); while true do task.wait(0.3); updatePlayers() end end)
end)
