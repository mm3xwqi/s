--local config = (function() return {
--	["Remove Death Effect"] = false,
--	["Lock Fps"] = { ["Enabled"] = true, ["FPS"] = 120 },
--	["White Screen"] = false,
--	["Boost FPS V1"] = false,
--	["Boost FPS V2"] = false,
--	["Hide Players"] = true,
--	["Hide Enemies"] = true,
--} end)()

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StatsService = game:GetService("Stats")
local WS           = game:GetService("Workspace")

local player = Players.LocalPlayer
local pg     = player:WaitForChild("PlayerGui")
if pg:FindFirstChild("IntegratedStatusHUD") then pg.IntegratedStatusHUD:Destroy() end
if player.Character and player.Character:FindFirstChild("ESP_SelfHL") then player.Character.ESP_SelfHL:Destroy() end

local MAX_PLAYERS = Players.MaxPlayers
local COMBAT_CAP  = 2800
local FPS_CAP     = config["Lock Fps"]["Enabled"] and config["Lock Fps"]["FPS"] or 60

if config["Lock Fps"]["Enabled"] then
	pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate = FPS_CAP end)
	pcall(function() setfpscap(FPS_CAP) end)
end

local C = {
	BG      = Color3.fromRGB(6,6,6),       PANEL  = Color3.fromRGB(10,10,10),
	CARD    = Color3.fromRGB(22,22,22),     HOVER  = Color3.fromRGB(32,32,32),
	SEP     = Color3.fromRGB(50,50,50),     BORDER = Color3.fromRGB(70,70,70),
	BORDER2 = Color3.fromRGB(100,100,100),  WHITE  = Color3.fromRGB(255,255,255),
	OFFWHITE= Color3.fromRGB(235,235,235),  MUTED  = Color3.fromRGB(180,180,180),
	DIM     = Color3.fromRGB(140,140,140),  SUCCESS= Color3.fromRGB(100,220,130),
	WARN    = Color3.fromRGB(255,210,80),   DANGER = Color3.fromRGB(255,100,100),
	FRIEND  = Color3.fromRGB(100,180,255),  DIST   = Color3.fromRGB(180,180,255),
	V1COL   = Color3.fromRGB(80,190,255),   V2COL  = Color3.fromRGB(255,195,60),
	BOUNTY  = Color3.fromRGB(255,160,60),
}

local boostV1Active = false
local hiddenParts   = {}
local boostV1Conn   = nil

local function setMapVisibility(invisible)
	if invisible then
		hiddenParts = {}
		for _, v in ipairs(WS:GetDescendants()) do
			pcall(function()
				if v:IsA("BasePart") then
					hiddenParts[#hiddenParts+1] = {obj=v, trans=v.Transparency}
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

local boostV2Active    = false
local v2DescConn       = nil
local v2OrigSettings   = {}
local V2_SKIP_ANCESTORS= {}

local function buildSkipList()
	V2_SKIP_ANCESTORS = {}
	for _, svc in ipairs({pg, game:GetService("ReplicatedStorage"), game:GetService("Players"), game:GetService("CoreGui")}) do
		V2_SKIP_ANCESTORS[svc] = true
	end
	if player.Character then V2_SKIP_ANCESTORS[player.Character] = true end
end

local function shouldSkip(obj)
	local cur = obj.Parent
	while cur do
		if V2_SKIP_ANCESTORS[cur] then return true end
		cur = cur.Parent
	end
	return false
end

local function applyObjGraphic(obj)
	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
		obj.Enabled = false
	elseif obj:IsA("Explosion") then
		obj.BlastPressure=1; obj.BlastRadius=1; obj.Visible=false
	elseif obj:IsA("BasePart") and not obj:IsA("MeshPart") then
		obj.Material=Enum.Material.Plastic; obj.Reflectance=0
	elseif obj:IsA("MeshPart") then
		obj.RenderFidelity=2; obj.Reflectance=0; obj.Material=Enum.Material.Plastic
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		obj.Transparency=1
	elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
		obj.Enabled=false
	end
end

local function applyLowGraphic()
	buildSkipList()
	local L = game:GetService("Lighting")
	v2OrigSettings.GlobalShadows  = L.GlobalShadows
	v2OrigSettings.FogEnd         = L.FogEnd
	v2OrigSettings.ShadowSoftness = L.ShadowSoftness
	L.GlobalShadows=false; L.FogEnd=9e9; L.ShadowSoftness=0
	pcall(function() sethiddenproperty(L,"Technology",2) end)
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
		terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0
		terrain.WaterReflectance=0; terrain.WaterTransparency=0
		pcall(function() sethiddenproperty(terrain,"Decoration",false) end)
	end
	task.spawn(function()
		local all = WS:GetDescendants()
		for i = 1, #all, 150 do
			if not boostV2Active then break end
			for j = i, math.min(i+149, #all) do
				if not shouldSkip(all[j]) then pcall(applyObjGraphic, all[j]) end
			end
			task.wait()
		end
	end)
	if v2DescConn then v2DescConn:Disconnect() end
	v2DescConn = game.DescendantAdded:Connect(function(obj)
		if not boostV2Active then return end
		if not obj:IsDescendantOf(WS) then return end
		if shouldSkip(obj) then return end
		task.wait(0.3)
		if boostV2Active then pcall(applyObjGraphic, obj) end
	end)
end

local function removeLowGraphic()
	if v2DescConn then v2DescConn:Disconnect(); v2DescConn=nil end
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

if config["Boost FPS V1"] then task.spawn(function() task.wait(2); boostV1Active=true; setMapVisibility(true) end) end
if config["Boost FPS V2"] then task.spawn(function() task.wait(2); boostV2Active=true; applyLowGraphic()    end) end

player.CharacterAdded:Connect(function(char)
	if boostV2Active then V2_SKIP_ANCESTORS[char]=true end
end)

local hidePlayersActive = config["Hide Players"]
local hiddenPlayersData = {}
local hidePlayersConns  = {}

local function setPlayerVisibility(plr, visible)
	local char = plr.Character
	if not char then return end
	if not visible then
		if hiddenPlayersData[plr.UserId] then return end
		local partsData = {}
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				partsData[#partsData+1] = {obj=part, trans=part.Transparency}
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
		if hidePlayersConns.playerAdded    then hidePlayersConns.playerAdded:Disconnect();    hidePlayersConns.playerAdded=nil    end
		if hidePlayersConns.characterAdded then hidePlayersConns.characterAdded:Disconnect(); hidePlayersConns.characterAdded=nil end
	end
end

if hidePlayersActive then task.spawn(function() task.wait(1); toggleHidePlayers(true) end) end

local hideEnemiesActive = config["Hide Enemies"]
local hiddenEnemyParts  = {}
local enemyDescConn     = nil

local function setEnemyPartHidden(part, hidden)
	if hidden then
		if hiddenEnemyParts[part] ~= nil then return end
		hiddenEnemyParts[part] = part.Transparency
		part.Transparency = 1
	else
		if hiddenEnemyParts[part] == nil then return end
		if part and part.Parent then part.Transparency = hiddenEnemyParts[part] end
		hiddenEnemyParts[part] = nil
	end
end

local function applyHideEnemies(active)
	local ef = WS:FindFirstChild("Enemies")
	if not ef then return end
	for _, obj in ipairs(ef:GetDescendants()) do
		if obj:IsA("BasePart") then pcall(setEnemyPartHidden, obj, active) end
	end
end

local function toggleHideEnemies(active)
	hideEnemiesActive = active
	applyHideEnemies(active)
	if active then
		if not enemyDescConn then
			local ef = WS:FindFirstChild("Enemies")
			if ef then
				enemyDescConn = ef.DescendantAdded:Connect(function(obj)
					if hideEnemiesActive and obj:IsA("BasePart") then
						task.wait(0.1); pcall(setEnemyPartHidden, obj, true)
					end
				end)
			end
		end
	else
		if enemyDescConn then enemyDescConn:Disconnect(); enemyDescConn=nil end
		for part, origTr in pairs(hiddenEnemyParts) do
			if part and part.Parent then pcall(function() part.Transparency=origTr end) end
		end
		hiddenEnemyParts = {}
	end
end

if hideEnemiesActive then task.spawn(function() task.wait(2); toggleHideEnemies(true) end) end

local function removeDeathEffect()
	pcall(function()
		local rs    = game:GetService("ReplicatedStorage")
		local death = rs:WaitForChild("Effect",10):WaitForChild("Container",10):WaitForChild("Death",10)
		if death then death:Destroy() end
	end)
end
if config["Remove Death Effect"] then
	removeDeathEffect()
	player.CharacterAdded:Connect(function() task.wait(0.5); removeDeathEffect() end)
end

local statCache = {}
local STAT_PATHS = {
	Level          = {"leaderstats.Level","leaderstats.Lv.","Data.Level"},
	Beli           = {"leaderstats.Beli","leaderstats.Money","Data.Beli"},
	Fragments      = {"leaderstats.Fragments","leaderstats.Fragment","Data.Fragments"},
	Melee          = {"leaderstats.Melee","Data.Stats.Melee.Level"},
	Defense        = {"leaderstats.Defense","Data.Stats.Defense.Level"},
	Sword          = {"leaderstats.Sword","Data.Stats.Sword.Level"},
	Gun            = {"leaderstats.Gun","Data.Stats.Gun.Level"},
	["Blox Fruit"] = {"leaderstats.Blox Fruit","leaderstats.Demon Fruit","Data.Stats.Blox Fruit.Level","Data.Stats.Demon Fruit.Level"},
	Bounty         = {"leaderstats.Bounty/Honor","leaderstats.Bounty","leaderstats.Honor"},
	SpawnPoint     = {"Data.LastSpawnPoint"},
}

local function resolvePath(root, path)
	local obj = root
	for part in path:gmatch("[^%.]+") do
		if not obj then return nil end
		obj = obj:FindFirstChild(part)
	end
	if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue")) then return obj end
	return nil
end

local function getStatObj(plr, key)
	local uid = plr.UserId
	if not statCache[uid] then statCache[uid]={} end
	local cached = statCache[uid][key]
	if cached ~= nil and cached ~= false then return cached end
	local paths = STAT_PATHS[key] or {"leaderstats."..key,"Data."..key}
	for _, path in ipairs(paths) do
		local obj = resolvePath(plr, path)
		if obj then statCache[uid][key]=obj; return obj end
	end
	return false
end

local function getStat(key, root)
	local obj = getStatObj(root or player, key)
	return obj and obj.Value or nil
end

local function formatVal(v, key)
	if type(v) ~= "number" then return tostring(v or "?") end
	if key=="Beli" or key=="Fragments" or key=="Level" then
		return tostring(math.floor(v)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
	end
	if     v>=1e6 then return ("%.1fM"):format(v/1e6)
	elseif v>=1e3 then return ("%.1fK"):format(v/1e3)
	else               return tostring(math.floor(v)) end
end

local function fmtComma(n)
	if type(n)~="number" then return "?" end
	return tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end

local STUDS_TO_M    = 0.28
local playerInfoCache = {}
local spawnWatchers   = {}
local raceWatchers    = {}
local bountyWatchers  = {}

playerInfoCache[player.UserId] = {joinTime=tick()}

local function watchPlayerSpawn(p)
	if p==player then return end
	local uid = p.UserId
	if spawnWatchers[uid] then spawnWatchers[uid]:Disconnect(); spawnWatchers[uid]=nil end
	task.spawn(function()
		local dataF = p:FindFirstChild("Data") or p:WaitForChild("Data",30)
		if not dataF then return end
		local spawnObj = dataF:FindFirstChild("LastSpawnPoint") or dataF:WaitForChild("LastSpawnPoint",30)
		if not spawnObj then return end
		if not playerInfoCache[uid] then playerInfoCache[uid]={} end
		playerInfoCache[uid].spawn = spawnObj.Value
		spawnWatchers[uid] = spawnObj.Changed:Connect(function(v)
			if not playerInfoCache[uid] then playerInfoCache[uid]={} end
			playerInfoCache[uid].spawn = v
		end)
	end)
end

local function watchPlayerRace(p)
	if p==player then return end
	local uid = p.UserId
	if raceWatchers[uid] then raceWatchers[uid]:Disconnect(); raceWatchers[uid]=nil end
	task.spawn(function()
		local dataF = p:FindFirstChild("Data") or p:WaitForChild("Data",30)
		if not dataF then return end
		local raceObj = dataF:FindFirstChild("Race") or dataF:WaitForChild("Race",30)
		if not raceObj then return end
		if not playerInfoCache[uid] then playerInfoCache[uid]={} end
		if raceObj:IsA("ValueBase") and raceObj.Value~="" then
			playerInfoCache[uid].race = tostring(raceObj.Value)
		end
		local cObj = raceObj:FindFirstChild("C")
		if cObj and (cObj:IsA("NumberValue") or cObj:IsA("IntValue")) then
			playerInfoCache[uid].raceTier = cObj.Value
		end
		raceWatchers[uid] = raceObj.Changed:Connect(function(v)
			if not playerInfoCache[uid] then playerInfoCache[uid]={} end
			if v~="" then playerInfoCache[uid].race=tostring(v) end
		end)
	end)
end

local function watchPlayerBounty(p)
	if p==player then return end
	local uid = p.UserId
	if bountyWatchers[uid] then bountyWatchers[uid]:Disconnect(); bountyWatchers[uid]=nil end
	task.spawn(function()
		local bObj = getStatObj(p,"Bounty")
		if not bObj then task.wait(3); bObj=getStatObj(p,"Bounty") end
		if not bObj then return end
		if not playerInfoCache[uid] then playerInfoCache[uid]={} end
		playerInfoCache[uid].bounty = bObj.Value
		bountyWatchers[uid] = bObj.Changed:Connect(function(v)
			if not playerInfoCache[uid] then playerInfoCache[uid]={} end
			playerInfoCache[uid].bounty = v
		end)
	end)
end

local function startWatchingPlayer(p)
	if p==player then return end
	local uid = p.UserId
	if not playerInfoCache[uid] then playerInfoCache[uid]={} end
	if not playerInfoCache[uid].joinTime then playerInfoCache[uid].joinTime=tick() end
	watchPlayerSpawn(p); watchPlayerRace(p); watchPlayerBounty(p)
end

local THEMES = {
	{name="Default", accent=Color3.fromRGB(255,255,255), accentDim=Color3.fromRGB(180,180,180), bg=Color3.fromRGB(6,6,6),    panel=Color3.fromRGB(10,10,10), card=Color3.fromRGB(22,22,22), hover=Color3.fromRGB(32,32,32), sep=Color3.fromRGB(50,50,50),  border=Color3.fromRGB(70,70,70),   border2=Color3.fromRGB(100,100,100), dim=Color3.fromRGB(140,140,140)},
	{name="Cyan",    accent=Color3.fromRGB(80,220,255),  accentDim=Color3.fromRGB(60,160,200),  bg=Color3.fromRGB(2,10,14),  panel=Color3.fromRGB(4,16,22),  card=Color3.fromRGB(6,26,36),  hover=Color3.fromRGB(10,40,54),  sep=Color3.fromRGB(20,70,90), border=Color3.fromRGB(30,100,130), border2=Color3.fromRGB(50,160,200),  dim=Color3.fromRGB(80,160,190)},
	{name="Green",   accent=Color3.fromRGB(100,220,130), accentDim=Color3.fromRGB(70,160,100),  bg=Color3.fromRGB(4,12,6),   panel=Color3.fromRGB(6,18,10),  card=Color3.fromRGB(8,28,14),  hover=Color3.fromRGB(12,42,20),  sep=Color3.fromRGB(20,70,35), border=Color3.fromRGB(30,100,50),  border2=Color3.fromRGB(50,160,80),   dim=Color3.fromRGB(80,160,100)},
	{name="Orange",  accent=Color3.fromRGB(255,160,60),  accentDim=Color3.fromRGB(200,120,40),  bg=Color3.fromRGB(14,8,2),   panel=Color3.fromRGB(20,12,4),  card=Color3.fromRGB(30,18,6),  hover=Color3.fromRGB(44,26,8),   sep=Color3.fromRGB(80,48,14), border=Color3.fromRGB(110,70,20),  border2=Color3.fromRGB(180,110,40),  dim=Color3.fromRGB(180,120,60)},
	{name="Pink",    accent=Color3.fromRGB(255,120,180), accentDim=Color3.fromRGB(200,80,140),  bg=Color3.fromRGB(14,4,10),  panel=Color3.fromRGB(20,6,14),  card=Color3.fromRGB(30,8,22),  hover=Color3.fromRGB(44,12,32),  sep=Color3.fromRGB(80,24,58), border=Color3.fromRGB(110,36,82),  border2=Color3.fromRGB(180,70,130),  dim=Color3.fromRGB(180,90,140)},
	{name="Purple",  accent=Color3.fromRGB(180,120,255), accentDim=Color3.fromRGB(130,80,200),  bg=Color3.fromRGB(8,4,14),   panel=Color3.fromRGB(12,6,20),  card=Color3.fromRGB(18,8,32),  hover=Color3.fromRGB(28,12,48),  sep=Color3.fromRGB(50,22,90), border=Color3.fromRGB(70,36,120),  border2=Color3.fromRGB(110,60,190),  dim=Color3.fromRGB(130,90,190)},
}
local currentThemeIdx = 1

local HUD_W=640; local HUD_H=600; local PAD=10

local function mk(class, parent, props)
	local obj = Instance.new(class)
	if parent then obj.Parent=parent end
	if props then for k,v in pairs(props) do pcall(function() obj[k]=v end) end end
	return obj
end
local function corner(p,r) return mk("UICorner",p,{CornerRadius=UDim.new(0,r or 5)}) end
local function stroke(p,col,t) return mk("UIStroke",p,{Color=col or C.BORDER,Thickness=t or 1,Transparency=0}) end
local function lbl(parent, props)
	return mk("TextLabel", parent, {
		BackgroundTransparency=1, Font=props.font or Enum.Font.GothamBold,
		TextSize=props.size or 13, TextColor3=props.color or C.OFFWHITE,
		Text=props.text or "", Size=props.sz or UDim2.new(1,0,0,18),
		Position=props.pos or UDim2.new(0,0,0,0),
		TextXAlignment=props.align or Enum.TextXAlignment.Left,
		TextYAlignment=props.yalign or Enum.TextYAlignment.Center,
		TextTruncate=props.trunc or Enum.TextTruncate.None, ZIndex=props.z or 2,
	})
end

local gui = mk("ScreenGui", pg, {Name="IntegratedStatusHUD",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=10})
local hudPos = UDim2.new(0.5,-HUD_W/2,0.5,-HUD_H/2)

-- Notif
local notifQueue={};  local notifActive=false
local notifFrame = mk("Frame",gui,{Size=UDim2.new(0,260,0,44),Position=UDim2.new(1,-270,0,60),BackgroundColor3=C.PANEL,BorderSizePixel=0,ZIndex=60,Visible=false})
stroke(notifFrame,C.BORDER2,1); corner(notifFrame,6)
local notifDot    = mk("Frame",notifFrame,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,10,0,10),BackgroundColor3=C.SUCCESS,BorderSizePixel=0,ZIndex=61}); corner(notifDot,4)
local notifNameLbl= lbl(notifFrame,{sz=UDim2.new(1,-28,0,16),pos=UDim2.new(0,24,0,4), size=11,color=C.WHITE,text="",trunc=Enum.TextTruncate.AtEnd,z=61})
local notifSubLbl = lbl(notifFrame,{sz=UDim2.new(1,-28,0,12),pos=UDim2.new(0,24,0,24),font=Enum.Font.Gotham,size=9,color=C.DIM,text="",z=61})
local NTI_IN=TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local NTI_OUT=TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In)

local function notifSetAlpha(c,a)
	if c:IsA("TextLabel") then c.TextTransparency=a
	elseif c:IsA("Frame") and c~=notifFrame then c.BackgroundTransparency=a
	elseif c:IsA("UIStroke") then c.Transparency=a end
end
local function notifTweenAlpha(c,a,ti)
	if c:IsA("TextLabel") then TweenService:Create(c,ti,{TextTransparency=a}):Play()
	elseif c:IsA("Frame") and c~=notifFrame then TweenService:Create(c,ti,{BackgroundTransparency=a}):Play()
	elseif c:IsA("UIStroke") then TweenService:Create(c,ti,{Transparency=a}):Play() end
end

local function showNotif(name,action,col)
	notifQueue[#notifQueue+1]={name=name,action=action,col=col}
	if notifActive then return end
	notifActive=true
	task.spawn(function()
		while #notifQueue>0 do
			local item=table.remove(notifQueue,1)
			notifDot.BackgroundColor3=item.col or C.SUCCESS
			notifNameLbl.Text=item.name; notifSubLbl.Text=item.action
			notifFrame.Visible=true; notifFrame.BackgroundTransparency=1
			for _,c in ipairs(notifFrame:GetDescendants()) do pcall(notifSetAlpha,c,1) end
			TweenService:Create(notifFrame,NTI_IN,{BackgroundTransparency=0}):Play()
			for _,c in ipairs(notifFrame:GetDescendants()) do pcall(notifTweenAlpha,c,0,NTI_IN) end
			task.wait(3)
			TweenService:Create(notifFrame,NTI_OUT,{BackgroundTransparency=1}):Play()
			for _,c in ipairs(notifFrame:GetDescendants()) do pcall(notifTweenAlpha,c,1,NTI_OUT) end
			task.wait(0.3); notifFrame.Visible=false
			if #notifQueue==0 then task.wait(0.1) end
		end
		notifActive=false
	end)
end

Players.PlayerAdded:Connect(function(p)
	task.wait(1)
	local uid=p.UserId
	if not playerInfoCache[uid] then playerInfoCache[uid]={} end
	playerInfoCache[uid].joinTime=tick()
	startWatchingPlayer(p)
	showNotif(p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name,"joined the server",C.SUCCESS)
end)
Players.PlayerRemoving:Connect(function(p)
	showNotif(p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name,"left the server",C.DANGER)
end)
for _,p in ipairs(Players:GetPlayers()) do if p~=player then startWatchingPlayer(p) end end
Players.PlayerRemoving:Connect(function(p)
	local uid=p.UserId
	if spawnWatchers[uid]  then spawnWatchers[uid]:Disconnect();  spawnWatchers[uid]=nil  end
	if raceWatchers[uid]   then raceWatchers[uid]:Disconnect();   raceWatchers[uid]=nil   end
	if bountyWatchers[uid] then bountyWatchers[uid]:Disconnect(); bountyWatchers[uid]=nil end
	playerInfoCache[uid]=nil; statCache[uid]=nil
end)

local VALID_STAT_TYPES={Melee=true,Sword=true,Gun=true,["Blox Fruit"]=true,Defense=true}
local function getToolStatType(toolObj)
	local tip=""
	pcall(function() tip=toolObj.ToolTip or "" end)
	if VALID_STAT_TYPES[tip] then return tip end
	local found
	pcall(function()
		local t=toolObj:FindFirstChild("Type") or toolObj:FindFirstChild("WeaponType") or toolObj:FindFirstChild("StatType")
		if t and t:IsA("StringValue") and VALID_STAT_TYPES[t.Value] then found=t.Value end
	end)
	return found
end
local function getToolLevel(obj)
	local lv
	pcall(function()
		local lo=obj:FindFirstChild("Level") or obj:FindFirstChildOfClass("NumberValue") or obj:FindFirstChildOfClass("IntValue")
		if lo then lv=lo.Value end
	end)
	return lv
end
local function getEquippedItem()
	local char=player.Character
	if not char then return "None",nil end
	for _,obj in ipairs(char:GetChildren()) do
		if obj:IsA("Tool") then return obj.Name,getToolLevel(obj) end
	end
	return "None",nil
end
local function getInventory()
	local items={}
	local bp=player:FindFirstChild("Backpack")
	if not bp then return items end
	for _,obj in ipairs(bp:GetChildren()) do
		if obj:IsA("Tool") and obj.Name~="Tool" then
			local lv=getToolLevel(obj)
			if lv~=nil then items[#items+1]={name=obj.Name,level=lv,statType=getToolStatType(obj)} end
		end
	end
	return items
end
local function getRace(p)
	local raceName,tier
	pcall(function()
		local ro=p:FindFirstChild("Data") and p.Data:FindFirstChild("Race")
		if not ro then return end
		if ro:IsA("ValueBase") and ro.Value~="" then raceName=tostring(ro.Value) end
		for _,n in ipairs({"C","V","Tier","Level","T"}) do
			local c=ro:FindFirstChild(n)
			if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then tier=c.Value; break end
		end
	end)
	return raceName,tier
end

-- UI Panels
local fullPanel=mk("Frame",gui,{Size=UDim2.new(0,HUD_W,0,HUD_H),Position=hudPos,BackgroundColor3=C.PANEL,BackgroundTransparency=0,BorderSizePixel=0,ClipsDescendants=false})
stroke(fullPanel,C.BORDER2,2); corner(fullPanel,8)
local miniPanel=mk("Frame",gui,{Size=UDim2.new(0,HUD_W,0,40),Position=hudPos,BackgroundColor3=C.PANEL,BackgroundTransparency=0,BorderSizePixel=0,Visible=false})
stroke(miniPanel,C.BORDER2,2); corner(miniPanel,5)
local loadOverlay=mk("Frame",gui,{Size=UDim2.new(0,HUD_W,0,HUD_H),Position=hudPos,BackgroundColor3=C.BG,BackgroundTransparency=0,BorderSizePixel=0,ZIndex=50})
corner(loadOverlay,8); stroke(loadOverlay,C.BORDER2,2)

lbl(loadOverlay,{sz=UDim2.new(1,0,0,28),pos=UDim2.new(0,0,0.38,-14),size=16,color=C.WHITE,text="Account Info",align=Enum.TextXAlignment.Center,z=52})
local loadStepLbl=lbl(loadOverlay,{sz=UDim2.new(1,-60,0,16),pos=UDim2.new(0,30,0.38,18),font=Enum.Font.Gotham,size=12,color=C.MUTED,text="Initializing...",align=Enum.TextXAlignment.Center,z=52})
local loadTrackBg=mk("Frame",loadOverlay,{Size=UDim2.new(1,-60,0,3),Position=UDim2.new(0,30,0.38,40),BackgroundColor3=C.BORDER,BorderSizePixel=0,ZIndex=52}); corner(loadTrackBg,2)
local loadBarFill=mk("Frame",loadTrackBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.WHITE,BorderSizePixel=0,ZIndex=53}); corner(loadBarFill,2)
local loadPctLbl=lbl(loadOverlay,{sz=UDim2.new(1,-60,0,14),pos=UDim2.new(0,30,0.38,48),font=Enum.Font.GothamBold,size=10,color=C.DIM,text="0%",align=Enum.TextXAlignment.Right,z=52})

local isMini=false
local function setView(mini)
	isMini=mini
	if mini then
		fullPanel.Visible=true
		TweenService:Create(fullPanel,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
		task.delay(0.18,function() fullPanel.Visible=false; fullPanel.BackgroundTransparency=0 end)
		miniPanel.BackgroundTransparency=1; miniPanel.Visible=true
		TweenService:Create(miniPanel,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
	else
		miniPanel.Visible=true
		TweenService:Create(miniPanel,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
		task.delay(0.18,function() miniPanel.Visible=false; miniPanel.BackgroundTransparency=0 end)
		fullPanel.BackgroundTransparency=1; fullPanel.Visible=true
		TweenService:Create(fullPanel,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
	end
end

local dragging,dragStart,dragStartPos=false,nil,nil
fullPanel.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1 then
		if not (fullPanel and fullPanel.Parent) then return end
		dragging=true; dragStart=inp.Position; dragStartPos=fullPanel.Position
	end
end)
UIS.InputChanged:Connect(function(inp)
	if dragging and dragStart and dragStartPos and inp.UserInputType==Enum.UserInputType.MouseMovement then
		local ok,delta=pcall(function() return inp.Position-dragStart end)
		if not ok then dragging=false; return end
		local np=UDim2.new(dragStartPos.X.Scale,dragStartPos.X.Offset+delta.X,dragStartPos.Y.Scale,dragStartPos.Y.Offset+delta.Y)
		if fullPanel and fullPanel.Parent then fullPanel.Position=np end
		if miniPanel and miniPanel.Parent then miniPanel.Position=np end
		if loadOverlay and loadOverlay.Parent then loadOverlay.Position=np end
	end
end)
UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; dragStart=nil; dragStartPos=nil end
end)

local HALF=HUD_W/2
mk("Frame",fullPanel,{Size=UDim2.new(0,1,0,HUD_H-PAD*2),Position=UDim2.new(0,HALF,0,PAD),BackgroundColor3=C.SEP,BorderSizePixel=0,ZIndex=3})
mk("Frame",fullPanel,{Size=UDim2.new(0,HUD_W-PAD*2,0,1),Position=UDim2.new(0,PAD,0,HUD_H/2),BackgroundColor3=C.SEP,BorderSizePixel=0,ZIndex=3})

local function statBlock(x,y,w,labelTxt,valInit,barColor)
	lbl(fullPanel,{sz=UDim2.new(0,w-4,0,12),pos=UDim2.new(0,x,0,y),size=9,color=C.DIM,text=labelTxt,z=4})
	local vl=lbl(fullPanel,{sz=UDim2.new(0,w-4,0,17),pos=UDim2.new(0,x,0,y+12),size=13,color=C.OFFWHITE,text=valInit,trunc=Enum.TextTruncate.AtEnd,z=4})
	local bf=nil
	if barColor then
		local barBg=mk("Frame",fullPanel,{Size=UDim2.new(0,w-8,0,3),Position=UDim2.new(0,x,0,y+31),BackgroundColor3=C.BORDER,BorderSizePixel=0,ZIndex=4}); corner(barBg,1)
		bf=mk("Frame",barBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=barColor,BorderSizePixel=0,ZIndex=5}); corner(bf,1)
	end
	return vl,bf
end

local Q1X=PAD;       local Q1Y=PAD;          local Q1W=HALF-PAD*2
local Q2X=HALF+PAD;  local Q2Y=PAD;          local Q2W=HALF-PAD*2
local Q3X=PAD;       local Q3Y=HUD_H/2+PAD;  local Q3W=HALF-PAD*2
local Q4X=HALF+PAD;  local Q4Y=HUD_H/2+PAD;  local Q4W=HALF-PAD*2

-- group UI labels into a table to save local slots
local UI = {}
UI.avatar=mk("ImageLabel",fullPanel,{Size=UDim2.new(0,56,0,56),Position=UDim2.new(0,Q1X,0,Q1Y),BackgroundColor3=C.CARD,BorderSizePixel=0,ZIndex=4})
stroke(UI.avatar,C.BORDER2,2); corner(UI.avatar,5)
UI.charLabel=lbl(fullPanel,{sz=UDim2.new(0,Q1W-64,0,18),pos=UDim2.new(0,Q1X+62,0,Q1Y),   size=13,color=C.WHITE, text="Loading...",trunc=Enum.TextTruncate.AtEnd,z=4})
UI.lvlLabel =lbl(fullPanel,{sz=UDim2.new(0,Q1W-64,0,14),pos=UDim2.new(0,Q1X+62,0,Q1Y+20),size=11,color=C.MUTED,text="LV. 0",z=4})
UI.onlineDot=mk("Frame",fullPanel,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,Q1X+62,0,Q1Y+40),BackgroundColor3=C.SUCCESS,BorderSizePixel=0,ZIndex=4}); corner(UI.onlineDot,4)
lbl(fullPanel,{sz=UDim2.new(0,60,0,12),pos=UDim2.new(0,Q1X+74,0,Q1Y+38),size=9,color=C.DIM,text="ONLINE",z=4})

task.spawn(function()
	while true do
		TweenService:Create(UI.onlineDot,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0.5}):Play()
		task.wait(0.8)
		TweenService:Create(UI.onlineDot,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0}):Play()
		task.wait(0.8)
	end
end)

local function miniStatRow2(x,y,w,labelTxt,valTxt)
	lbl(fullPanel,{sz=UDim2.new(0,w,0,12),pos=UDim2.new(0,x,0,y),size=9,color=C.DIM,text=labelTxt,z=4})
	local v=lbl(fullPanel,{sz=UDim2.new(0,w,0,14),pos=UDim2.new(0,x,0,y+12),size=12,color=C.OFFWHITE,text=valTxt,trunc=Enum.TextTruncate.AtEnd,z=4})
	return v
end

local colW3=math.floor(Q1W/3)
UI.raceValLbl =miniStatRow2(Q1X,        Q1Y+68,colW3-4,"RACE","???")
UI.teamValLbl =miniStatRow2(Q1X+colW3,  Q1Y+68,colW3-4,"TEAM","N/A")
UI.spawnValLbl=miniStatRow2(Q1X+colW3*2,Q1Y+68,colW3-4,"SPAWN","???")
UI.fpsLabel   =lbl(fullPanel,{sz=UDim2.new(0,Q1W,0,16),pos=UDim2.new(0,Q1X,0,Q1Y+100),size=13,color=C.OFFWHITE,text="FPS 0",z=4})
UI.pingLabel  =lbl(fullPanel,{sz=UDim2.new(0,Q1W,0,16),pos=UDim2.new(0,Q1X,0,Q1Y+118),size=13,color=C.OFFWHITE,text="PING 0ms",z=4})
UI.timeLabel  =lbl(fullPanel,{sz=UDim2.new(0,Q1W,0,14),pos=UDim2.new(0,Q1X,0,Q1Y+136),font=Enum.Font.Gotham,size=11,color=C.DIM,text="00:00:00",z=4})

local function makeSmallBtn(x,y,w,h,txt,col,state)
	local btn=mk("TextButton",fullPanel,{Size=UDim2.new(0,w,0,h),Position=UDim2.new(0,x,0,y),BackgroundColor3=state and col or C.CARD,BorderSizePixel=0,Text=txt,TextColor3=state and C.BG or C.MUTED,TextSize=10,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4})
	stroke(btn,C.BORDER2,1); corner(btn,4); return btn
end

local btnW=math.floor((Q1W-6)/2)
UI.v1Btn   =makeSmallBtn(Q1X,        Q1Y+158,btnW,20,config["Boost FPS V1"] and "V1 ON" or "V1 OFF",C.V1COL,config["Boost FPS V1"])
UI.v2Btn   =makeSmallBtn(Q1X+btnW+6, Q1Y+158,btnW,20,config["Boost FPS V2"] and "V2 ON" or "V2 OFF",C.V2COL,config["Boost FPS V2"])
UI.hideBtn =makeSmallBtn(Q1X,        Q1Y+182,btnW,20,hidePlayersActive and "HIDE ON" or "HIDE OFF",C.WHITE,hidePlayersActive)
UI.miniBtn =makeSmallBtn(Q1X+btnW+6, Q1Y+182,btnW,20,"MINIMIZE",C.CARD,false); UI.miniBtn.TextColor3=C.MUTED
UI.enemyBtn=makeSmallBtn(Q1X,        Q1Y+206,btnW,20,hideEnemiesActive and "ENEMY ON" or "ENEMY OFF",C.DANGER,hideEnemiesActive)
UI.themeBtn=makeSmallBtn(Q1X+btnW+6, Q1Y+230,btnW,20,"THEME: Default",C.CARD,false); UI.themeBtn.TextColor3=C.MUTED
UI.capBox=mk("TextBox",fullPanel,{Size=UDim2.new(0,btnW-36,0,20),Position=UDim2.new(0,Q1X,0,Q1Y+230),BackgroundColor3=C.CARD,BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.WHITE,Text="",PlaceholderText=tostring(FPS_CAP),PlaceholderColor3=C.DIM,ZIndex=4})
stroke(UI.capBox,C.BORDER2,1); corner(UI.capBox,4)
UI.setCapBtn=makeSmallBtn(Q1X+btnW-30,Q1Y+230,30,20,"SET",C.WHITE,false)
UI.setCapBtn.BackgroundColor3=C.WHITE; UI.setCapBtn.TextColor3=C.BG

local function applyFpsCap()
	local num=tonumber(UI.capBox.Text)
	if num and num>0 then
		pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate=num end)
		pcall(function() setfpscap(num) end)
		FPS_CAP=num; UI.capBox.Text=""
	end
end
UI.setCapBtn.MouseButton1Click:Connect(applyFpsCap)
UI.capBox.FocusLost:Connect(function(enter) if enter then applyFpsCap() end end)

local sRH=36
UI.beliLbl,_          =statBlock(Q2X,Q2Y+0,    Q2W,"BELI","0")
UI.fragLbl,_          =statBlock(Q2X,Q2Y+sRH,  Q2W,"FRAGMENTS","0")
UI.meleeLbl,UI.meleeBar=statBlock(Q2X,Q2Y+sRH*2,Q2W,"MELEE","0",C.V1COL)
UI.defLbl,  UI.defBar  =statBlock(Q2X,Q2Y+sRH*3,Q2W,"DEFENSE","0",C.V1COL)
UI.swordLbl,UI.swordBar=statBlock(Q2X,Q2Y+sRH*4,Q2W,"SWORD","0",C.V1COL)
UI.gunLbl,  UI.gunBar  =statBlock(Q2X,Q2Y+sRH*5,Q2W,"GUN","0",C.V1COL)
UI.fruitLbl,UI.fruitBar=statBlock(Q2X,Q2Y+sRH*6,Q2W,"BLOX FRUIT","0",C.WARN)

lbl(fullPanel,{sz=UDim2.new(0,Q3W,0,12),pos=UDim2.new(0,Q3X,0,Q3Y),size=9,color=C.DIM,text="PLAYERS",z=4})
UI.pcCountLbl=lbl(fullPanel,{sz=UDim2.new(0,100,0,18),pos=UDim2.new(0,Q3X,0,Q3Y+12),size=14,color=C.WHITE,text="? / "..MAX_PLAYERS,z=4})
local svrBarBg=mk("Frame",fullPanel,{Size=UDim2.new(0,Q3W,0,3),Position=UDim2.new(0,Q3X,0,Q3Y+32),BackgroundColor3=C.BORDER,BorderSizePixel=0,ZIndex=4}); corner(svrBarBg,1)
UI.serverBarFill=mk("Frame",svrBarBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.WHITE,BorderSizePixel=0,ZIndex=5}); corner(UI.serverBarFill,1)
lbl(fullPanel,{sz=UDim2.new(0,Q3W/2,0,12),pos=UDim2.new(0,Q3X+Q3W/2,0,Q3Y),size=9,color=C.DIM,text="TOTAL BOUNTY",align=Enum.TextXAlignment.Right,z=4})
UI.totalBountyLbl=lbl(fullPanel,{sz=UDim2.new(0,Q3W/2,0,18),pos=UDim2.new(0,Q3X+Q3W/2,0,Q3Y+12),size=12,color=C.BOUNTY,text="0",align=Enum.TextXAlignment.Right,z=4})

local plrScroll=mk("ScrollingFrame",fullPanel,{Size=UDim2.new(0,Q3W,0,HUD_H/2-PAD*2-42),Position=UDim2.new(0,Q3X,0,Q3Y+38),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BORDER2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=3})
mk("UIListLayout",plrScroll,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding",plrScroll,{PaddingBottom=UDim.new(0,2)})

local playerMiniRows={}
for i=1,20 do
	local row=mk("Frame",plrScroll,{Size=UDim2.new(1,-4,0,58),BackgroundColor3=C.CARD,BorderSizePixel=0,ZIndex=4,LayoutOrder=i,Visible=false})
	stroke(row,C.BORDER2,1); corner(row,4)
	playerMiniRows[i]={
		row=row,
		nameLbl =lbl(row,{sz=UDim2.new(1,-62,0,14),pos=UDim2.new(0,6,0,2), size=11,color=C.WHITE, text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		lvlLbl  =lbl(row,{sz=UDim2.new(0,56,0,14), pos=UDim2.new(1,-60,0,2),size=10,color=C.MUTED, text="",align=Enum.TextXAlignment.Right,z=5}),
		raceLbl =lbl(row,{sz=UDim2.new(0,90,0,12), pos=UDim2.new(0,6,0,18), font=Enum.Font.Gotham,size=9,color=C.FRIEND,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		spawnLbl=lbl(row,{sz=UDim2.new(1,-100,0,12),pos=UDim2.new(0,100,0,18),font=Enum.Font.Gotham,size=9,color=C.DIM,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		bountyLbl=lbl(row,{sz=UDim2.new(1,-90,0,12),pos=UDim2.new(0,6,0,32), font=Enum.Font.Gotham,size=9,color=C.BOUNTY,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		distLbl =lbl(row,{sz=UDim2.new(0,80,0,12), pos=UDim2.new(1,-84,0,32),font=Enum.Font.Gotham,size=9,color=C.DIST,text="",align=Enum.TextXAlignment.Right,z=5}),
		timeLbl =lbl(row,{sz=UDim2.new(1,-6,0,12), pos=UDim2.new(0,6,0,46), font=Enum.Font.Gotham,size=9,color=Color3.fromRGB(180,220,255),text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
	}
end

lbl(fullPanel,{sz=UDim2.new(0,Q4W,0,12),pos=UDim2.new(0,Q4X,0,Q4Y),size=9,color=C.DIM,text="EQUIPPED",z=4})
UI.equipValLbl=lbl(fullPanel,{sz=UDim2.new(0,Q4W,0,17),pos=UDim2.new(0,Q4X,0,Q4Y+12),size=13,color=C.OFFWHITE,text="None",trunc=Enum.TextTruncate.AtEnd,z=4})
UI.equipLvlLbl=lbl(fullPanel,{sz=UDim2.new(0,Q4W,0,13),pos=UDim2.new(0,Q4X,0,Q4Y+30),font=Enum.Font.GothamBold,size=10,color=C.WARN,text="",z=4})
lbl(fullPanel,{sz=UDim2.new(0,Q4W,0,12),pos=UDim2.new(0,Q4X,0,Q4Y+48),size=9,color=C.DIM,text="INVENTORY",z=4})

local invScroll=mk("ScrollingFrame",fullPanel,{Size=UDim2.new(0,Q4W,0,HUD_H/2-PAD-62-2),Position=UDim2.new(0,Q4X,0,Q4Y+62),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BORDER2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=3})
mk("UIListLayout",invScroll,{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding",invScroll,{PaddingBottom=UDim.new(0,2)})

local invTextRows={}
for i=1,20 do
	local cell=mk("Frame",invScroll,{Size=UDim2.new(1,-4,0,26),BackgroundColor3=C.CARD,BorderSizePixel=0,ZIndex=4,LayoutOrder=i,Visible=false})
	stroke(cell,C.BORDER2,1); corner(cell,4)
	invTextRows[i]={
		cell=cell,
		nameLbl=lbl(cell,{sz=UDim2.new(1,-64,0,26),pos=UDim2.new(0,8,0,0), size=11,color=C.OFFWHITE,text="",trunc=Enum.TextTruncate.AtEnd,z=5}),
		lvlLbl =lbl(cell,{sz=UDim2.new(0,58,0,26), pos=UDim2.new(1,-62,0,0),size=10,color=C.WARN,text="",align=Enum.TextXAlignment.Right,z=5}),
	}
end

-- Mini panel
UI.miniAva=mk("ImageLabel",miniPanel,{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,6,0,6),BackgroundColor3=C.CARD,BorderSizePixel=0,ZIndex=3}); stroke(UI.miniAva,C.BORDER2,1); corner(UI.miniAva,4)
task.spawn(function()
	local ok,t=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
	if ok and t then UI.miniAva.Image=t end
end)
UI.miniNameLbl=lbl(miniPanel,{sz=UDim2.new(0,120,0,16),pos=UDim2.new(0,38,0,4), size=12,color=C.WHITE,text="Loading...",z=3})
UI.miniLvlLbl =lbl(miniPanel,{sz=UDim2.new(0,90,0,12), pos=UDim2.new(0,38,0,22),font=Enum.Font.Gotham,size=10,color=C.DIM,text="LV. 0",z=3})
lbl(miniPanel,{sz=UDim2.new(0,50,0,12),pos=UDim2.new(0,170,0,4), size=9,color=C.DIM,text="FPS",z=3})
UI.miniFpsLbl =lbl(miniPanel,{sz=UDim2.new(0,80,0,16),pos=UDim2.new(0,170,0,20),size=12,color=C.WHITE,text="...",z=3})
lbl(miniPanel,{sz=UDim2.new(0,50,0,12),pos=UDim2.new(0,270,0,4), size=9,color=C.DIM,text="PING",z=3})
UI.miniPingLbl=lbl(miniPanel,{sz=UDim2.new(0,80,0,16),pos=UDim2.new(0,270,0,20),size=12,color=C.WHITE,text="...",z=3})
lbl(miniPanel,{sz=UDim2.new(0,50,0,12),pos=UDim2.new(0,370,0,4), size=9,color=C.DIM,text="BELI",z=3})
UI.miniBeliLbl=lbl(miniPanel,{sz=UDim2.new(0,100,0,16),pos=UDim2.new(0,370,0,20),size=12,color=C.WHITE,text="...",z=3})
local expandBtn=mk("TextButton",miniPanel,{Size=UDim2.new(0,30,0,22),Position=UDim2.new(1,-36,0,9),BackgroundColor3=C.CARD,BorderSizePixel=0,Text="▼",TextColor3=C.MUTED,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=5})
stroke(expandBtn,C.BORDER2,1); corner(expandBtn,4)
expandBtn.MouseEnter:Connect(function() TweenService:Create(expandBtn,TweenInfo.new(0.12),{BackgroundColor3=C.HOVER}):Play() end)
expandBtn.MouseLeave:Connect(function() TweenService:Create(expandBtn,TweenInfo.new(0.12),{BackgroundColor3=C.CARD}):Play()  end)
expandBtn.MouseButton1Click:Connect(function() setView(false) end)

local function addHover(btn,baseCol)
	btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C.HOVER}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=baseCol()}):Play()  end)
end
local function smoothToggleBtn(btn,active,onCol,offCol,onTxt,offTxt)
	TweenService:Create(btn,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{BackgroundColor3=active and onCol or offCol}):Play()
	btn.Text=active and onTxt or offTxt; btn.TextColor3=active and C.BG or C.MUTED
end

UI.v1Btn.MouseButton1Click:Connect(function()
	boostV1Active=not boostV1Active
	if boostV1Active then task.spawn(function() setMapVisibility(true) end) else task.spawn(function() setMapVisibility(false) end) end
	smoothToggleBtn(UI.v1Btn,boostV1Active,C.V1COL,C.CARD,"V1 ON","V1 OFF")
end)
UI.v2Btn.MouseButton1Click:Connect(function()
	boostV2Active=not boostV2Active
	if boostV2Active then task.spawn(function() applyLowGraphic() end) else task.spawn(function() removeLowGraphic() end) end
	smoothToggleBtn(UI.v2Btn,boostV2Active,C.V2COL,C.CARD,"V2 ON","V2 OFF")
end)
UI.hideBtn.MouseButton1Click:Connect(function()
	hidePlayersActive=not hidePlayersActive; toggleHidePlayers(hidePlayersActive)
	smoothToggleBtn(UI.hideBtn,hidePlayersActive,C.WHITE,C.CARD,"HIDE ON","HIDE OFF")
end)
UI.enemyBtn.MouseButton1Click:Connect(function()
	hideEnemiesActive=not hideEnemiesActive; task.spawn(function() toggleHideEnemies(hideEnemiesActive) end)
	smoothToggleBtn(UI.enemyBtn,hideEnemiesActive,C.DANGER,C.CARD,"ENEMY ON","ENEMY OFF")
end)
addHover(UI.v1Btn,    function() return boostV1Active     and C.V1COL or C.CARD end)
addHover(UI.v2Btn,    function() return boostV2Active     and C.V2COL or C.CARD end)
addHover(UI.hideBtn,  function() return hidePlayersActive and C.WHITE  or C.CARD end)
addHover(UI.enemyBtn, function() return hideEnemiesActive and C.DANGER or C.CARD end)
addHover(UI.miniBtn,  function() return C.CARD end)
addHover(UI.setCapBtn,function() return C.WHITE end)
UI.miniBtn.MouseButton1Click:Connect(function() setView(true) end)

local function twC(obj,props,dur)
	TweenService:Create(obj,TweenInfo.new(dur or 0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end

local function applyTheme(idx)
	currentThemeIdx=idx
	local t=THEMES[idx]
	C.BG=t.bg; C.PANEL=t.panel; C.CARD=t.card; C.HOVER=t.hover
	C.SEP=t.sep; C.BORDER=t.border; C.BORDER2=t.border2; C.DIM=t.dim
	C.WHITE=t.accent; C.OFFWHITE=t.accent; C.MUTED=t.accentDim
	UI.themeBtn.Text="THEME: "..t.name
	twC(fullPanel,{BackgroundColor3=t.panel}); twC(miniPanel,{BackgroundColor3=t.panel})
	twC(notifFrame,{BackgroundColor3=t.panel}); twC(loadOverlay,{BackgroundColor3=t.bg})
	local function recolorPanel(panel)
		for _,obj in ipairs(panel:GetDescendants()) do
			if obj:IsA("Frame") and obj.BackgroundTransparency<1 then
				local bc=obj.BackgroundColor3; local r,g,b=bc.R*255,bc.G*255,bc.B*255
				if r<30 and g<30 and b<30 and r>14 then twC(obj,{BackgroundColor3=t.card})
				elseif r<=14 and g<=14 and b<=14 and r>8 then twC(obj,{BackgroundColor3=t.panel})
				elseif r<=8  and g<=8  and b<=8 then twC(obj,{BackgroundColor3=t.bg})
				elseif r>=40 and r<80 and g==r and b==r then twC(obj,{BackgroundColor3=t.sep}) end
			end
			if obj:IsA("UIStroke") then twC(obj,{Color=t.border2}) end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				local tc=obj.TextColor3; local r,g,b=tc.R*255,tc.G*255,tc.B*255
				if r>200 and g>200 and b>200 then twC(obj,{TextColor3=t.accent})
				elseif r>=160 and r<=200 and math.abs(r-g)<10 and math.abs(r-b)<10 then twC(obj,{TextColor3=t.accentDim})
				elseif r>=120 and r<=160 and math.abs(r-g)<10 and math.abs(r-b)<10 then twC(obj,{TextColor3=t.dim}) end
			end
		end
	end
	recolorPanel(fullPanel); recolorPanel(miniPanel)
	for _,pf in ipairs(playerMiniRows) do
		if pf.row and pf.row.Parent then
			twC(pf.row,{BackgroundColor3=t.card})
			for _,s in ipairs(pf.row:GetChildren()) do if s:IsA("UIStroke") then twC(s,{Color=t.border2}) end end
		end
	end
	for _,pf in ipairs(invTextRows) do
		if pf.cell and pf.cell.Parent then
			twC(pf.cell,{BackgroundColor3=t.card})
			for _,s in ipairs(pf.cell:GetChildren()) do if s:IsA("UIStroke") then twC(s,{Color=t.border2}) end end
		end
	end
	twC(UI.serverBarFill,{BackgroundColor3=t.accent}); twC(loadBarFill,{BackgroundColor3=t.accent})
	twC(UI.onlineDot,{BackgroundColor3=C.SUCCESS}); twC(notifDot,{BackgroundColor3=C.SUCCESS})
	twC(UI.avatar,{BackgroundColor3=t.card}); twC(UI.miniAva,{BackgroundColor3=t.card})
	twC(UI.setCapBtn,{BackgroundColor3=t.accent,TextColor3=t.bg}); twC(UI.capBox,{BackgroundColor3=t.card})
	twC(expandBtn,{BackgroundColor3=t.card,TextColor3=t.accentDim})
end
UI.themeBtn.MouseButton1Click:Connect(function() applyTheme((currentThemeIdx%#THEMES)+1) end)
addHover(UI.themeBtn,function() return C.CARD end)

local blackoutFrame=mk("Frame",gui,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0,BorderSizePixel=0,ZIndex=1,Visible=false})
local restoreBtn=mk("TextButton",gui,{Size=UDim2.new(0,96,0,32),AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,-30),BackgroundColor3=C.WHITE,BorderSizePixel=0,Text="RESTORE",TextColor3=C.BG,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,Visible=false,ZIndex=51})
local blackoutActive=false
local function setBlackout(state) blackoutActive=state; blackoutFrame.Visible=state; restoreBtn.Visible=state end
if config["White Screen"] then setBlackout(true) end
restoreBtn.MouseButton1Click:Connect(function() setBlackout(false) end)

local selfHL
local function applyHighlight(char)
	if selfHL and selfHL.Parent then selfHL:Destroy() end; selfHL=nil
	if not char then return end
	local hl=Instance.new("Highlight")
	hl.Name="ESP_SelfHL"; hl.FillColor=Color3.fromRGB(255,255,255); hl.OutlineColor=Color3.fromRGB(0,0,0)
	hl.FillTransparency=0.5; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee=char; hl.Parent=char; selfHL=hl
end
if player.Character then task.delay(0.5,function() applyHighlight(player.Character) end) end
player.CharacterAdded:Connect(function(char) task.wait(0.5); applyHighlight(char) end)

task.spawn(function()
	local ok,t=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
	if ok and t then UI.avatar.Image=t end
end)

local fps,frameCount,lastFpsTime=0,0,tick()
RunService.RenderStepped:Connect(function()
	frameCount+=1; local now=tick()
	if now-lastFpsTime>=0.5 then fps=math.floor(frameCount/(now-lastFpsTime)); frameCount=0; lastFpsTime=now end
end)
local function getPing()
	local ok,p=pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"] end)
	return ok and type(p)=="number" and math.floor(p) or math.floor(player:GetNetworkPing()*1000)
end

local scriptStart=tick()
local lastText={};  local lastSize={};  local lastColor3={}
local barTweens={}; local colorTweens={}; local textTweens={}

local function setText(lb,val,animate)
	if lastText[lb]==val then return end; lastText[lb]=val
	if not (lb and lb.Parent) then return end; lb.Text=val
	if animate then
		if textTweens[lb] then textTweens[lb]:Cancel() end
		lb.TextTransparency=0.5
		local tw2=TweenService:Create(lb,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0}); tw2:Play(); textTweens[lb]=tw2
	else lb.TextTransparency=0 end
end
local function setBarX(frame,scale)
	local s=math.clamp(scale,0,1); if lastSize[frame]==s then return end; lastSize[frame]=s
	if barTweens[frame] then barTweens[frame]:Cancel() end
	local tw2=TweenService:Create(frame,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(s,0,1,0)}); tw2:Play(); barTweens[frame]=tw2
end
local function setColor(lb,col)
	if lastColor3[lb]==col then return end; lastColor3[lb]=col
	if colorTweens[lb] then colorTweens[lb]:Cancel() end
	local tw2=TweenService:Create(lb,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextColor3=col}); tw2:Play(); colorTweens[lb]=tw2
end
local function setBgColor(frame,col)
	TweenService:Create(frame,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundColor3=col}):Play()
end

local function updateFast()
	local e=tick()-scriptStart; local ping=getPing()
	setText(UI.fpsLabel,"FPS "..fps,false); setText(UI.pingLabel,"PING "..ping.."ms",false)
	setText(UI.timeLabel,("%02d:%02d:%02d"):format(math.floor(e/3600),math.floor(e%3600/60),math.floor(e%60)),false)
	setColor(UI.pingLabel,ping<80 and C.SUCCESS or ping<150 and C.WARN or C.DANGER)
	setText(UI.miniFpsLbl,"FPS "..fps,false); setText(UI.miniPingLbl,ping.."ms",false)
	setText(UI.miniBeliLbl,formatVal(getStat("Beli"),"Beli"),false)
	UI.capBox.PlaceholderText=tostring(FPS_CAP)
end

local function updateStats()
	local disp,name2=player.DisplayName,player.Name
	local nameStr=disp~=name2 and (disp.." (@"..name2..")") or name2
	setText(UI.charLabel,nameStr,true); setText(UI.miniNameLbl,nameStr,false)
	local lv=getStat("Level"); local lvStr="LV. "..formatVal(lv,"Level")
	setText(UI.lvlLabel,lvStr,true); setText(UI.miniLvlLbl,lvStr,false)
	setText(UI.beliLbl,formatVal(getStat("Beli"),"Beli"),true)
	setText(UI.fragLbl,formatVal(getStat("Fragments"),"Fragments"),true)
	local function doStat(vl,bar,key)
		local v=getStat(key); setText(vl,formatVal(v),true)
		if bar then setBarX(bar,tonumber(v) and tonumber(v)/COMBAT_CAP or 0) end
	end
	doStat(UI.meleeLbl,UI.meleeBar,"Melee"); doStat(UI.defLbl,UI.defBar,"Defense")
	doStat(UI.swordLbl,UI.swordBar,"Sword"); doStat(UI.gunLbl,UI.gunBar,"Gun")
	local fv=getStat("Blox Fruit"); setText(UI.fruitLbl,formatVal(fv),true)
	if UI.fruitBar then setBarX(UI.fruitBar,tonumber(fv) and tonumber(fv)/COMBAT_CAP or 0) end
	local rn,rt=getRace(player)
	setText(UI.raceValLbl,rn and (rn..(rt and " [V"..rt.."]" or "")) or "Not V4",true)
	setText(UI.teamValLbl,player.Team and player.Team.Name or "N/A",true)
	local sp=getStat("SpawnPoint"); setText(UI.spawnValLbl,sp~=nil and tostring(sp) or "??",true)
end

local INV_STAT_COLORS={Sword=C.SUCCESS,Gun=C.FRIEND,["Blox Fruit"]=Color3.fromRGB(200,140,255),Defense=C.DIST,Melee=C.WARN}
local function updateInventory()
	local en,elv=getEquippedItem(); setText(UI.equipValLbl,en,true)
	if elv~=nil then setText(UI.equipLvlLbl,"LV "..fmtComma(elv),true); setColor(UI.equipLvlLbl,C.WARN)
	else setText(UI.equipLvlLbl,en~="None" and "No Level" or "",true); setColor(UI.equipLvlLbl,C.DIM) end
	local items=getInventory()
	for i=1,20 do
		local pf=invTextRows[i]; local item=items[i]
		if item then
			pf.cell.Visible=true
			local dn=item.statType and ("["..item.statType.."] "..item.name) or item.name
			setText(pf.nameLbl,dn,true); setColor(pf.nameLbl,INV_STAT_COLORS[item.statType] or C.OFFWHITE)
			setText(pf.lvlLbl,"LV "..math.floor(item.level),true)
		else pf.cell.Visible=false end
	end
end

local function formatSessionTime(jt)
	if not jt then return "Time: ?" end
	local e=math.floor(tick()-jt); local h=math.floor(e/3600); local m=math.floor((e%3600)/60); local s=e%60
	if h>0 then return ("In server: %dh %02dm %02ds"):format(h,m,s)
	elseif m>0 then return ("In server: %dm %02ds"):format(m,s)
	else return ("In server: %ds"):format(s) end
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
		if cache and cache.bounty then totalBounty=totalBounty+cache.bounty
		else local bObj=getStatObj(p,"Bounty"); if bObj then totalBounty=totalBounty+(bObj.Value or 0) end end
	end
	setText(UI.totalBountyLbl,fmtComma(totalBounty),false)
	local myChar=player.Character; local myRoot=myChar and myChar:FindFirstChild("HumanoidRootPart")
	local distCache={}
	for _,p in ipairs(list) do
		if p~=player then
			local d=math.huge
			if myRoot then
				local thR=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
				if thR then local ok,mag=pcall(function() return (myRoot.Position-thR.Position).Magnitude end); if ok then d=mag end end
			end
			distCache[p.UserId]=d
		end
	end
	table.sort(list,function(a,b)
		if a==player then return true end; if b==player then return false end
		return (distCache[a.UserId] or math.huge)<(distCache[b.UserId] or math.huge)
	end)
	for i=1,20 do
		local pf=playerMiniRows[i]; local p=list[i]
		if p and pf then
			pf.row.Visible=true
			local ns=p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name
			setText(pf.nameLbl,ns,true); setColor(pf.nameLbl,p==player and C.SUCCESS or C.WHITE)
			local plv=getStat("Level",p); setText(pf.lvlLbl,plv~=nil and ("LV"..formatVal(plv,"Level")) or "LV??",true)
			if p~=player then
				local sv,rv,rt2,bv
				pcall(function()
					local cache=playerInfoCache[p.UserId]
					if cache then sv=cache.spawn; rv=cache.race; rt2=cache.raceTier; bv=cache.bounty end
					if not sv or not rv then
						local d=p:FindFirstChild("Data")
						if d then
							if not sv then local sp=d:FindFirstChild("LastSpawnPoint"); if sp then sv=sp.Value end end
							if not rv then
								local rc=d:FindFirstChild("Race")
								if rc then
									if rc:IsA("ValueBase") and rc.Value~="" then rv=tostring(rc.Value) end
									for _,n in ipairs({"C","V","Tier","Level","T"}) do
										local c=rc:FindFirstChild(n)
										if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then rt2=c.Value; break end
									end
								end
							end
						end
					end
					if not bv then local bObj=getStatObj(p,"Bounty"); if bObj then bv=bObj.Value end end
				end)
				setText(pf.raceLbl,rv and ("Race: "..rv..(rt2 and " V/T "..rt2 or "")) or "Race: ?",true)
				setText(pf.spawnLbl,sv and ("LOCATION: "..sv) or "LOCATION: ?",true)
				setText(pf.bountyLbl,bv~=nil and ("Bounty: "..fmtComma(bv)) or "Bounty: ?",true)
				local rd=distCache[p.UserId] or math.huge
				setText(pf.distLbl,rd==math.huge and "?" or (fmtComma(math.floor(rd*STUDS_TO_M)).."m"),false)
				setColor(pf.distLbl,C.DIST)
				setText(pf.timeLbl,formatSessionTime(playerInfoCache[p.UserId] and playerInfoCache[p.UserId].joinTime),false)
			else
				setText(pf.raceLbl,"",false); setText(pf.spawnLbl,"",false); setText(pf.bountyLbl,"",false)
				setText(pf.distLbl,"YOU",false); setColor(pf.distLbl,C.SUCCESS)
				setText(pf.timeLbl,formatSessionTime(playerInfoCache[player.UserId] and playerInfoCache[player.UserId].joinTime),false)
			end
		elseif pf then pf.row.Visible=false end
	end
end

UIS.InputBegan:Connect(function(inp,gp)
	if gp then return end
	if inp.KeyCode==Enum.KeyCode.B            then setBlackout(not blackoutActive) end
	if inp.KeyCode==Enum.KeyCode.RightControl then setView(not isMini) end
end)

-- Load sequence
local LOAD_ELEMENTS={
	{"Loading account...",      UI.avatar},
	{"Loading username...",     UI.charLabel},
	{"Loading level...",        UI.lvlLabel},
	{"Loading beli...",         UI.beliLbl},
	{"Loading fragments...",    UI.fragLbl},
	{"Loading fruit...",        UI.fruitLbl},
	{"Loading melee stats...",  UI.meleeLbl},
	{"Loading defense...",      UI.defLbl},
	{"Loading sword...",        UI.swordLbl},
	{"Loading gun...",          UI.gunLbl},
	{"Loading equipped...",     UI.equipValLbl},
	{"Loading inventory...",    invTextRows[1] and invTextRows[1].cell},
	{"Loading players...",      UI.pcCountLbl},
	{"Loading performance...",  UI.fpsLabel},
}

local origTrans={}
local loadTargets={}
for _,item in ipairs(LOAD_ELEMENTS) do if item[2] then loadTargets[#loadTargets+1]=item[2] end end

local function snapChild(list,c)
	if (c:IsA("Frame") or c:IsA("ImageLabel") or c:IsA("TextLabel") or c:IsA("TextButton")) and c.BackgroundTransparency<1 then list[#list+1]={c,"BackgroundTransparency",c.BackgroundTransparency} end
	if (c:IsA("TextLabel") or c:IsA("TextButton")) and c.TextTransparency<1 then list[#list+1]={c,"TextTransparency",c.TextTransparency} end
	if c:IsA("ImageLabel") and c.ImageTransparency<1 then list[#list+1]={c,"ImageTransparency",c.ImageTransparency} end
	if c:IsA("UIStroke") and c.Transparency<1 then list[#list+1]={c,"Transparency",c.Transparency} end
end
local function snapTrans(obj)
	if not obj then return nil end; local list={}
	pcall(function() if obj.BackgroundTransparency<1 then list[#list+1]={obj,"BackgroundTransparency",obj.BackgroundTransparency} end end)
	for _,c in ipairs(obj:GetDescendants()) do pcall(snapChild,list,c) end
	return list
end
local function hideEl(obj)
	if not obj then return end
	pcall(function() obj.BackgroundTransparency=1 end)
	for _,c in ipairs(obj:GetDescendants()) do
		pcall(function()
			if c:IsA("Frame") or c:IsA("ImageLabel") or c:IsA("TextLabel") or c:IsA("TextButton") then c.BackgroundTransparency=1 end
			if c:IsA("TextLabel") or c:IsA("TextButton") then c.TextTransparency=1 end
			if c:IsA("ImageLabel") then c.ImageTransparency=1 end
			if c:IsA("UIStroke") then c.Transparency=1 end
		end)
	end
end

local FADE_TI=TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local function fadeIn(obj)
	local list=origTrans[obj]; if not list then return end
	for _,entry in ipairs(list) do
		local o,prop,val=entry[1],entry[2],entry[3]
		if o and o.Parent then TweenService:Create(o,FADE_TI,{[prop]=val}):Play() end
	end
end

for _,obj in ipairs(loadTargets) do origTrans[obj]=snapTrans(obj); hideEl(obj) end

task.spawn(function()
	local TOTAL=#LOAD_ELEMENTS; local STEP_DUR=0.18; local totalDur=TOTAL*STEP_DUR; local done=false
	task.spawn(function()
		for _,item in ipairs(LOAD_ELEMENTS) do
			loadStepLbl.Text=item[1]; if item[2] then fadeIn(item[2]) end; task.wait(STEP_DUR)
		end; done=true
	end)
	local s=tick()
	repeat
		local r=math.min((tick()-s)/totalDur,1); local ease=r*r*(3-2*r)
		if loadBarFill and loadBarFill.Parent then loadBarFill.Size=UDim2.new(ease,0,1,0) end
		if loadPctLbl  and loadPctLbl.Parent  then loadPctLbl.Text=math.floor(ease*100).."%" end
		if loadOverlay and loadOverlay.Parent  then loadOverlay.BackgroundTransparency=0.05+0.15*ease end
		RunService.Heartbeat:Wait()
	until done
	if loadBarFill and loadBarFill.Parent then loadBarFill.Size=UDim2.new(1,0,1,0) end
	if loadPctLbl  and loadPctLbl.Parent  then loadPctLbl.Text="100%" end
	task.wait(0.1)
	if loadOverlay and loadOverlay.Parent then
		local sa=loadOverlay.BackgroundTransparency; local s2=tick()
		while loadOverlay and loadOverlay.Parent do
			local r=math.min((tick()-s2)/0.4,1); local ease=r*r*(3-2*r); local a=sa+(1-sa)*ease
			loadOverlay.BackgroundTransparency=a
			for _,c in ipairs(loadOverlay:GetDescendants()) do
				pcall(function()
					if c:IsA("TextLabel") or c:IsA("TextButton") then c.TextTransparency=ease
					elseif c:IsA("Frame") then c.BackgroundTransparency=a
					elseif c:IsA("UIStroke") then c.Transparency=ease end
				end)
			end
			if r>=1 then break end; RunService.Heartbeat:Wait()
		end
		if loadOverlay and loadOverlay.Parent then loadOverlay:Destroy() end
	end
	task.spawn(function() while true do updateFast(); task.wait(0.05) end end)
	task.spawn(function() updateStats(); updateInventory(); while true do task.wait(0.2); updateStats(); updateInventory() end end)
	task.spawn(function() updatePlayers(); while true do task.wait(0.3); updatePlayers() end end)
end)
