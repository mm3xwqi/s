local _loadPlrs = game:GetService("Players")
local _loadPG   = _loadPlrs.LocalPlayer:WaitForChild("PlayerGui")
local _loadTS   = game:GetService("TweenService")

local _loadGui = Instance.new("ScreenGui")
_loadGui.Name = "Panel Loader"
_loadGui.ResetOnSpawn = false
_loadGui.IgnoreGuiInset = true
_loadGui.DisplayOrder = 999
_loadGui.Parent = _loadPG

local _loadBG = Instance.new("Frame")
_loadBG.Size = UDim2.new(1,0,1,0)
_loadBG.BackgroundColor3 = Color3.fromRGB(4,4,4)
_loadBG.BorderSizePixel = 0
_loadBG.ZIndex = 100
_loadBG.Parent = _loadGui

local _loadCard = Instance.new("Frame")
_loadCard.Size = UDim2.new(0,380,0,300)
_loadCard.Position = UDim2.new(0.5,-190,0.5,-150)
_loadCard.BackgroundColor3 = Color3.fromRGB(10,10,10)
_loadCard.BorderSizePixel = 0
_loadCard.ZIndex = 101
_loadCard.Parent = _loadBG
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,10); c.Parent=_loadCard end
do local s=Instance.new("UIStroke"); s.Color=Color3.fromRGB(60,60,60); s.Thickness=1.5; s.Parent=_loadCard end

local _loadAccent = Instance.new("Frame")
_loadAccent.Size = UDim2.new(1,0,0,3)
_loadAccent.Position = UDim2.new(0,0,0,0)
_loadAccent.BackgroundColor3 = Color3.fromRGB(100,220,130)
_loadAccent.BorderSizePixel = 0
_loadAccent.ZIndex = 102
_loadAccent.Parent = _loadCard
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,10); c.Parent=_loadAccent end

local _loadTitle = Instance.new("TextLabel")
_loadTitle.Size = UDim2.new(1,0,0,32)
_loadTitle.Position = UDim2.new(0,0,0,16)
_loadTitle.BackgroundTransparency = 1
_loadTitle.Font = Enum.Font.GothamBold
_loadTitle.TextSize = 22
_loadTitle.TextColor3 = Color3.fromRGB(255,255,255)
_loadTitle.Text = "BloxHub"
_loadTitle.TextXAlignment = Enum.TextXAlignment.Center
_loadTitle.ZIndex = 102
_loadTitle.Parent = _loadCard

local _loadSub = Instance.new("TextLabel")
_loadSub.Size = UDim2.new(1,0,0,16)
_loadSub.Position = UDim2.new(0,0,0,46)
_loadSub.BackgroundTransparency = 1
_loadSub.Font = Enum.Font.Gotham
_loadSub.TextSize = 11
_loadSub.TextColor3 = Color3.fromRGB(100,100,100)
_loadSub.Text = "v2 — Optimized Edition"
_loadSub.TextXAlignment = Enum.TextXAlignment.Center
_loadSub.ZIndex = 102
_loadSub.Parent = _loadCard

local _loadStep = Instance.new("TextLabel")
_loadStep.Size = UDim2.new(1,-100,0,16)
_loadStep.Position = UDim2.new(0,20,0,78)
_loadStep.BackgroundTransparency = 1
_loadStep.Font = Enum.Font.GothamBold
_loadStep.TextSize = 11
_loadStep.TextColor3 = Color3.fromRGB(100,220,130)
_loadStep.Text = "Initializing..."
_loadStep.TextXAlignment = Enum.TextXAlignment.Left
_loadStep.ZIndex = 102
_loadStep.Parent = _loadCard

local _loadPct = Instance.new("TextLabel")
_loadPct.Size = UDim2.new(0,60,0,16)
_loadPct.Position = UDim2.new(1,-80,0,78)
_loadPct.BackgroundTransparency = 1
_loadPct.Font = Enum.Font.GothamBold
_loadPct.TextSize = 11
_loadPct.TextColor3 = Color3.fromRGB(180,180,180)
_loadPct.Text = "0%"
_loadPct.TextXAlignment = Enum.TextXAlignment.Right
_loadPct.ZIndex = 102
_loadPct.Parent = _loadCard

local _barBG = Instance.new("Frame")
_barBG.Size = UDim2.new(1,-40,0,6)
_barBG.Position = UDim2.new(0,20,0,98)
_barBG.BackgroundColor3 = Color3.fromRGB(25,25,25)
_barBG.BorderSizePixel = 0
_barBG.ZIndex = 102
_barBG.Parent = _loadCard
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=_barBG end

local _barFill = Instance.new("Frame")
_barFill.Size = UDim2.new(0,0,1,0)
_barFill.BackgroundColor3 = Color3.fromRGB(100,220,130)
_barFill.BorderSizePixel = 0
_barFill.ZIndex = 103
_barFill.Parent = _barBG
do local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,3); c.Parent=_barFill end

local _logFrame = Instance.new("ScrollingFrame")
_logFrame.Size = UDim2.new(1,-40,0,145)
_logFrame.Position = UDim2.new(0,20,0,116)
_logFrame.BackgroundTransparency = 1
_logFrame.BorderSizePixel = 0
_logFrame.ScrollBarThickness = 2
_logFrame.ScrollBarImageColor3 = Color3.fromRGB(60,60,60)
_logFrame.CanvasSize = UDim2.new(0,0,0,0)
_logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
_logFrame.ZIndex = 102
_logFrame.Parent = _loadCard

local _logLayout = Instance.new("UIListLayout")
_logLayout.Padding = UDim.new(0,3)
_logLayout.SortOrder = Enum.SortOrder.LayoutOrder
_logLayout.Parent = _logFrame

local _loadFooter = Instance.new("TextLabel")
_loadFooter.Size = UDim2.new(1,0,0,14)
_loadFooter.Position = UDim2.new(0,0,1,-20)
_loadFooter.BackgroundTransparency = 1
_loadFooter.Font = Enum.Font.Gotham
_loadFooter.TextSize = 9
_loadFooter.TextColor3 = Color3.fromRGB(50,50,50)
_loadFooter.Text = "Panel • Private"
_loadFooter.TextXAlignment = Enum.TextXAlignment.Center
_loadFooter.ZIndex = 102
_loadFooter.Parent = _loadCard

local _logCount   = 0
local _totalSteps = 11

local function _logStep(text, isOK)
	_logCount = _logCount + 1
	local ok  = isOK ~= false
	local col = ok and Color3.fromRGB(100,220,130) or Color3.fromRGB(255,100,100)
	_loadStep.Text = text
	_loadStep.TextColor3 = col
	local pct = math.clamp(_logCount/_totalSteps, 0, 1)
	_loadPct.Text = math.floor(pct*100).."%"
	_loadTS:Create(_barFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(pct,0,1,0)}):Play()

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,16)
	row.BackgroundTransparency = 1
	row.LayoutOrder = _logCount
	row.ZIndex = 103
	row.Parent = _logFrame

	local iconL = Instance.new("TextLabel")
	iconL.Size = UDim2.new(0,16,1,0)
	iconL.BackgroundTransparency = 1
	iconL.Font = Enum.Font.GothamBold
	iconL.TextSize = 10
	iconL.TextColor3 = col
	iconL.Text = ok and "🟢" or "🔴"
	iconL.TextXAlignment = Enum.TextXAlignment.Center
	iconL.ZIndex = 104
	iconL.Parent = row

	local textL = Instance.new("TextLabel")
	textL.Size = UDim2.new(1,-20,1,0)
	textL.Position = UDim2.new(0,18,0,0)
	textL.BackgroundTransparency = 1
	textL.Font = Enum.Font.Gotham
	textL.TextSize = 10
	textL.TextColor3 = Color3.fromRGB(180,180,180)
	textL.Text = text
	textL.TextXAlignment = Enum.TextXAlignment.Left
	textL.TextTruncate = Enum.TextTruncate.AtEnd
	textL.ZIndex = 104
	textL.Parent = row

	task.defer(function()
		_logFrame.CanvasPosition = Vector2.new(0, _logLayout.AbsoluteContentSize.Y)
	end)
	task.wait(0.05)
end

local function _closeLoader()
	_loadStep.Text = "Load complete!"
	_loadStep.TextColor3 = Color3.fromRGB(100,220,130)
	_loadPct.Text = "100%"
	_loadTS:Create(_barFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(1,0,1,0)}):Play()
	task.wait(0.8)
	_loadTS:Create(_loadBG, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}):Play()
	_loadTS:Create(_loadCard, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5,-190,0.6,-150), BackgroundTransparency = 1}):Play()
	task.wait(0.5)
	_loadGui:Destroy()
end

_logStep("Waiting for Roblox game to load...")
if not game:IsLoaded() then game.Loaded:Wait() end
_logStep("Game loaded ✓")

_logStep("Waiting for LocalPlayer and PlayerGui...")
local Plrs = game:GetService("Players")
repeat task.wait(0.1) until Plrs.LocalPlayer and Plrs.LocalPlayer:FindFirstChild("PlayerGui")
local lp = Plrs.LocalPlayer
local pg = lp.PlayerGui
_logStep("LocalPlayer ready ✓")

_logStep("Clearing old GUIs...")
for _, v in ipairs(pg:GetChildren()) do
	if v.Name == "IntegratedStatusHUD" then v:Destroy() end
end
if lp.Character and lp.Character:FindFirstChild("ESP_SelfHL") then
	lp.Character.ESP_SelfHL:Destroy()
end
_logStep("Old GUIs cleared ✓")

_logStep("Loading Roblox Services...")
local Run  = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local TS   = game:GetService("TweenService")
local WS   = game:GetService("Workspace")
local HTTP = game:GetService("HttpService")
_logStep("Services loaded ✓")

_logStep("Waiting for Workspace / Map to load...")
local _mapWait = 0
repeat task.wait(0.1); _mapWait = _mapWait + 0.1
until WS:FindFirstChildOfClass("Terrain") or _mapWait > 5
_logStep("Workspace ready ✓")

_logStep("Waiting for Leaderstats / Data...")
local _lsWait = 0
repeat task.wait(0.2); _lsWait = _lsWait + 0.2
until lp:FindFirstChild("leaderstats") or lp:FindFirstChild("Data") or _lsWait > 8
local _lsFound = lp:FindFirstChild("leaderstats") or lp:FindFirstChild("Data")
_logStep(_lsFound and "Leaderstats loaded ✓" or "Leaderstats not found (skipped)", _lsFound ~= nil)

_logStep("Waiting for player Character...")
local _charWait = 0
repeat task.wait(0.1); _charWait = _charWait + 0.1
until lp.Character or _charWait > 8
_logStep(lp.Character and "Character ready ✓" or "Character not spawned (skipped)", lp.Character ~= nil)

_logStep("Waiting for HumanoidRootPart...")
if lp.Character then
	local _hrpWait = 0
	repeat task.wait(0.1); _hrpWait = _hrpWait + 0.1
	until (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) or _hrpWait > 6
	local _hrpOK = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") ~= nil
	_logStep(_hrpOK and "HumanoidRootPart ready ✓" or "HumanoidRootPart not found (skipped)", _hrpOK)
else
	_logStep("Skipped (no Character)", false)
end

_logStep("Waiting for Enemies folder...")
local _efWait = 0
repeat task.wait(0.2); _efWait = _efWait + 0.2
until WS:FindFirstChild("Enemies") or _efWait > 6
local _efOK = WS:FindFirstChild("Enemies") ~= nil
_logStep(_efOK and "Enemies folder found ✓" or "Enemies folder not found (skipped)", _efOK)

_logStep("Loading Config...")

--local cfg={
--	RemoveDeathEffect=true,
--	LockFps={on=false,fps=120},
--	WhiteScreen=false,
--	BoostV1=false,BoostV2=false,BoostV3=false,
--	HidePlayers=false,HideEnemies=false,
--	AutoHop=false,HopInterval=45,HopServer="singapore",
--	WebhookEnabled=false,
--	WebhookURL="https://discord.com/api/webhooks/1426870143916707840/1d9rXLCZSRTlnTBE-V0AX0CxgQLodNt-zXXSggbS6MjFpPKMTfbNR8V1VrhCcm4wgnmh",
--	WebhookName="Panel",
--	WebhookInterval=30,
--}
_logStep("Config loaded ✓")

_logStep("Building Panel GUI...")

-- Colors
local C={
	BG=Color3.fromRGB(6,6,6),PAN=Color3.fromRGB(10,10,10),CARD=Color3.fromRGB(22,22,22),
	HOV=Color3.fromRGB(32,32,32),SEP=Color3.fromRGB(50,50,50),BOR=Color3.fromRGB(70,70,70),
	BOR2=Color3.fromRGB(100,100,100),WHT=Color3.fromRGB(255,255,255),
	OFF=Color3.fromRGB(235,235,235),MUT=Color3.fromRGB(180,180,180),DIM=Color3.fromRGB(140,140,140),
	OK=Color3.fromRGB(100,220,130),WRN=Color3.fromRGB(255,210,80),ERR=Color3.fromRGB(255,100,100),
	BELI=Color3.fromRGB(100,220,130),FRAG=Color3.fromRGB(180,100,255),
	HOP=Color3.fromRGB(255,80,180),WH=Color3.fromRGB(88,176,255),
	PULL=Color3.fromRGB(255,100,100),
	V1=Color3.fromRGB(80,190,255),V2=Color3.fromRGB(255,195,60),V3=Color3.fromRGB(255,100,200),
}

-- Constants
local K={HW=640,HH=860,PAD=10,COMBAT=2800,MAX=Plrs.MaxPlayers,S2M=0.28,HMAX=60,HINT=10}
K.HF=K.HW/2
K.Q1W=K.HF-K.PAD*2; K.Q2X=K.HF+K.PAD; K.Q2W=K.HF-K.PAD*2
K.Q3X=K.PAD; K.Q3Y=K.HH/2+K.PAD; K.Q3W=K.Q1W
K.Q4X=K.Q2X; K.Q4Y=K.Q3Y; K.Q4W=K.Q2W

-- State
local S={
	v1=false,v2=false,v3=false,
	hidPlr=cfg.HidePlayers,hidPlrData={},hidPlrCC={},
	hidEnm=cfg.HideEnemies,hidEnmP={},enmConn=nil,
	hop=cfg.AutoHop,hopThread=nil,hopCD=(cfg.HopInterval or 45)*60,
	hopTick=tick(),hopTotal=0,hopTarget=(cfg.HopServer or ""):lower(),
	wh=cfg.WebhookEnabled,whTimer=false,whThread=nil,
	whCD=(cfg.WebhookInterval or 30)*60,whTick=tick(),whTotal=0,
	sessB=nil,sessF=nil,sessOK=false,sessDeaths=0,
	beliHist={},fragHist={},bPM=0,fPM=0,
	fps=0,fc=0,fpsT=tick(),
	drag=false,dragS=nil,dragP=nil,
	last={},lastSz={},lastCol={},barTw={},colTw={},
	isMini=false,selfHL=nil,start=tick(),
	statC={},skillC={},plrC={[lp.UserId]={join=tick()}},
	spawnW={},raceW={},bountyW={},
	v1Parts={},v2Conn=nil,v2Orig={},v3Conns={},
	hidPlrC={},
}
S.hopCD=(cfg.HopInterval or 45)*60

-- BringMob state
local BM={
	on=false,task=nil,data={},noclip=nil,pin=nil,
	dist=1000,batch=20,force=60000,snap=30,yOff=-20,
}
local bmTick=0

-- Utility
local function mk(cl,par,props)
	local o=Instance.new(cl); if par then o.Parent=par end
	if props then for k,v in pairs(props) do pcall(function() o[k]=v end) end end
	return o
end
local function corner(p,r) return mk("UICorner",p,{CornerRadius=UDim.new(0,r or 5)}) end
local function stroke(p,c,t) return mk("UIStroke",p,{Color=c or C.BOR,Thickness=t or 1,Transparency=0}) end
local function lbl(par,p)
	return mk("TextLabel",par,{
		BackgroundTransparency=1,Font=p.font or Enum.Font.GothamBold,
		TextSize=p.sz or 13,TextColor3=p.col or C.OFF,Text=p.txt or "",
		Size=p.size or UDim2.new(1,0,0,18),Position=p.pos or UDim2.new(0,0,0,0),
		TextXAlignment=p.ax or Enum.TextXAlignment.Left,
		TextYAlignment=p.ay or Enum.TextYAlignment.Center,
		TextTruncate=p.tr or Enum.TextTruncate.None,ZIndex=p.z or 2,
	})
end
local function btn(par,x,y,w,h,txt,on,col)
	local b=mk("TextButton",par,{
		Size=UDim2.new(0,w,0,h),Position=UDim2.new(0,x,0,y),
		BackgroundColor3=on and col or C.CARD,BorderSizePixel=0,
		Text=txt,TextColor3=on and C.BG or C.MUT,TextSize=10,
		Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4,
	}); stroke(b,C.BOR2,1); corner(b,4); return b
end
local function box(par,x,y,w,h,ph)
	local b=mk("TextBox",par,{
		Size=UDim2.new(0,w,0,h),Position=UDim2.new(0,x,0,y),
		BackgroundColor3=C.CARD,BorderSizePixel=0,Font=Enum.Font.Gotham,
		TextSize=11,TextColor3=C.WHT,Text="",PlaceholderText=ph,
		PlaceholderColor3=C.DIM,ZIndex=4,
	}); stroke(b,C.BOR2,1); corner(b,4); return b
end
local function tw(obj,props,dur) TS:Create(obj,TweenInfo.new(dur or .2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play() end
local function setText(lb,v) if not lb or S.last[lb]==v then return end; S.last[lb]=v; lb.Text=v end
local function setCol(lb,c) if not lb or S.lastCol[lb]==c then return end; S.lastCol[lb]=c; if S.colTw[lb] then S.colTw[lb]:Cancel() end; S.colTw[lb]=TS:Create(lb,TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextColor3=c}); S.colTw[lb]:Play() end
local function setBar(f,sc) local sv=math.clamp(sc,0,1); if S.lastSz[f]==sv then return end; S.lastSz[f]=sv; if S.barTw[f] then S.barTw[f]:Cancel() end; S.barTw[f]=TS:Create(f,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(sv,0,1,0)}); S.barTw[f]:Play() end
local function fmtN(n) if type(n)~="number" then return "?" end; return tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","") end
local function fmtV(v,k) if type(v)~="number" then return tostring(v or "?") end; if k=="Beli" or k=="Fragments" or k=="Level" then return fmtN(v) end; if v>=1e6 then return("%.1fM"):format(v/1e6) elseif v>=1e3 then return("%.1fK"):format(v/1e3) else return tostring(math.floor(v)) end end
local function fmtS(n) n=math.max(0,math.floor(n)); local h=math.floor(n/3600); n=n%3600; local m=math.floor(n/60); n=n%60; return h>0 and("%dh %02dm %02ds"):format(h,m,n) or m>0 and("%dm %02ds"):format(m,n) or("%ds"):format(n) end
local function wFmt(n) return(n<0 and"-" or"+")..tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","") end
local function getPing() local ok,p=pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"] end); return ok and type(p)=="number" and math.floor(p) or math.floor(lp:GetNetworkPing()*1000) end
local function ts() local ok,s=pcall(function() return os.date("!%Y-%m-%dT%H:%M:%SZ") end); return ok and s or nil end
local function localT() local ok,s=pcall(function() return os.date("%Y-%m-%d %H:%M:%S") end); return ok and s or("~"..math.floor(tick())) end
local function serverT(jt) if not jt then return"In server: ?" end; local e=math.floor(tick()-jt); local h=math.floor(e/3600); local m=math.floor((e%3600)/60); local sc=e%60; return h>0 and("In server: %dh %02dm %02ds"):format(h,m,sc) or m>0 and("In server: %dm %02ds"):format(m,sc) or("In server: %ds"):format(sc) end

-- Stat bar string helpers
local function hpBar(cur,max) if not cur or max<=0 then return"N/A" end; local p=math.clamp(cur/max,0,1); local f=math.floor(p*10); return string.rep("█",f)..string.rep("░",10-f)..string.format(" %.0f%%",p*100) end
local function statBar(v,cap) if not v then return string.rep("░",8).." ?" end; local p=math.clamp(v/cap,0,1); local f=math.floor(p*8); return string.rep("▓",f)..string.rep("░",8-f).."  "..fmtN(v) end
local function trendIcon(n) return(not n or n==0)and"➡️" or n>0 and"📈" or"📉" end

-- History / rates
local function pushH(t,v) if type(v)~="number" then return end; t[#t+1]={t=tick(),v=v}; while #t>K.HMAX do table.remove(t,1) end end
local function calcRate(t) if #t<2 then return 0 end; local e=t[#t].t-t[1].t; if e<1 then return 0 end; return math.floor((t[#t].v-t[1].v)/(e/60)) end

-- Stat resolution
local SPATHS={
	Level={"Data.Level","leaderstats.Level","leaderstats.Lv."},
	Beli={"Data.Beli","leaderstats.Beli","leaderstats.Money"},
	Fragments={"Data.Fragments","leaderstats.Fragments","leaderstats.Fragment"},
	Melee={"leaderstats.Melee","Data.Stats.Melee.Level"},
	Defense={"leaderstats.Defense","Data.Stats.Defense.Level"},
	Sword={"leaderstats.Sword","Data.Stats.Sword.Level"},
	Gun={"leaderstats.Gun","Data.Stats.Gun.Level"},
	["Blox Fruit"]={"leaderstats.Blox Fruit","leaderstats.Demon Fruit"},
	Bounty={"leaderstats.Bounty/Honor","leaderstats.Bounty","leaderstats.Honor"},
	SpawnPoint={"Data.LastSpawnPoint"},
}
local function resolvePath(root,path)
	local obj=root
	for part in path:gmatch("[^%.]+") do
		if not obj then return nil end
		local c=obj:FindFirstChild(part) or pcall(function() return obj:WaitForChild(part,1) end) and obj:FindFirstChild(part)
		obj=c
	end
	if obj and obj:IsA("ValueBase") then return obj end
end
local function getStatObj(plr,key)
	local uid=plr.UserId; S.statC[uid]=S.statC[uid] or {}
	if S.statC[uid][key] then return S.statC[uid][key] end
	for _,path in ipairs(SPATHS[key] or {"leaderstats."..key,"Data."..key}) do
		local obj=resolvePath(plr,path)
		if obj then S.statC[uid][key]=obj; return obj end
	end
end
local function getStat(key,root) local obj=getStatObj(root or lp,key); return obj and obj.Value or nil end

-- Notif
local gui=mk("ScreenGui",pg,{Name="IntegratedStatusHUD",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=10})
local notifF=mk("Frame",gui,{Size=UDim2.new(0,260,0,44),Position=UDim2.new(1,-270,0,60),BackgroundColor3=C.PAN,ZIndex=60,Visible=false})
stroke(notifF,C.BOR2,1); corner(notifF,6)
local nDot=mk("Frame",notifF,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,10,0,10),BackgroundColor3=C.OK,ZIndex=61}); corner(nDot,4)
local nName=lbl(notifF,{size=UDim2.new(1,-28,0,16),pos=UDim2.new(0,24,0,4),sz=11,col=C.WHT,txt="",tr=Enum.TextTruncate.AtEnd,z=61})
local nSub=lbl(notifF,{size=UDim2.new(1,-28,0,12),pos=UDim2.new(0,24,0,24),font=Enum.Font.Gotham,sz=9,col=C.DIM,txt="",z=61})
local nQ,nBusy={},false
local function showN(name,sub,col)
	if #nQ>=5 then table.remove(nQ,1) end; nQ[#nQ+1]={name=name,sub=sub,col=col}
	if nBusy then return end; nBusy=true
	task.spawn(function()
		while #nQ>0 do
			local item=table.remove(nQ,1); nDot.BackgroundColor3=item.col or C.OK
			nName.Text=item.name; nSub.Text=item.sub; notifF.Visible=true; notifF.BackgroundTransparency=1
			for _,c in ipairs(notifF:GetDescendants()) do pcall(function()
				if c:IsA("TextLabel") then c.TextTransparency=1 elseif c:IsA("Frame") and c~=notifF then c.BackgroundTransparency=1 elseif c:IsA("UIStroke") then c.Transparency=1 end
			end) end
			tw(notifF,{BackgroundTransparency=0},.2)
			for _,c in ipairs(notifF:GetDescendants()) do pcall(function()
				if c:IsA("TextLabel") then tw(c,{TextTransparency=0},.2) elseif c:IsA("Frame") and c~=notifF then tw(c,{BackgroundTransparency=0},.2) elseif c:IsA("UIStroke") then tw(c,{Transparency=0},.2) end
			end) end
			task.wait(3)
			tw(notifF,{BackgroundTransparency=1},.25)
			for _,c in ipairs(notifF:GetDescendants()) do pcall(function()
				if c:IsA("TextLabel") then tw(c,{TextTransparency=1},.25) elseif c:IsA("Frame") and c~=notifF then tw(c,{BackgroundTransparency=1},.25) elseif c:IsA("UIStroke") then tw(c,{Transparency=1},.25) end
			end) end
			task.wait(.3); notifF.Visible=false
		end; nBusy=false
	end)
end

-- Boost V1 (hide map)
local function setV1(on)
	if on then
		S.v1Parts={}
		for _,v in ipairs(WS:GetDescendants()) do pcall(function() if v:IsA("BasePart") then S.v1Parts[#S.v1Parts+1]={o=v,t=v.Transparency}; v.Transparency=1 end end) end
		if S.v1Conn then S.v1Conn:Disconnect() end
		S.v1Conn=WS.DescendantAdded:Connect(function(v) pcall(function() if v:IsA("BasePart") then v.Transparency=1 end end) end)
	else
		if S.v1Conn then S.v1Conn:Disconnect(); S.v1Conn=nil end
		for _,d in ipairs(S.v1Parts) do if d.o and d.o.Parent then d.o.Transparency=d.t end end
		S.v1Parts={}
	end
end

-- Boost V2 (low graphic)
local function killFX(m) if not m then return end; for _,o in ipairs(m:GetDescendants()) do pcall(function()
	if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then o.Enabled=false; o.Rate=0
	elseif o:IsA("Beam") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then o.Enabled=false
	elseif o:IsA("BillboardGui") or o:IsA("SurfaceGui") then o.Enabled=false end
end) end end
local function setV2(on)
	local L=game:GetService("Lighting")
	if on then
		S.v2Orig={GS=L.GlobalShadows,FE=L.FogEnd,FS=L.FogStart,SS=L.ShadowSoftness,BR=L.Brightness,AM=L.Ambient,OA=L.OutdoorAmbient,CT=L.ClockTime,QL=settings().Rendering.QualityLevel}
		L.GlobalShadows=false; L.FogEnd=9e9; L.FogStart=9e9; L.ShadowSoftness=0; L.Brightness=0
		L.Ambient=Color3.new(.5,.5,.5); L.OutdoorAmbient=Color3.new(.5,.5,.5); L.ClockTime=14
		pcall(function() sethiddenproperty(L,"Technology",2) end)
		settings().Rendering.QualityLevel=1
		local ter=WS:FindFirstChildOfClass("Terrain")
		if ter then S.v2Orig.WW=ter.WaterWaveSize; S.v2Orig.WS=ter.WaterWaveSpeed; ter.WaterWaveSize=0; ter.WaterWaveSpeed=0; ter.WaterReflectance=0; ter.WaterTransparency=1 end
		for _,c in ipairs(L:GetChildren()) do if c:IsA("PostEffect") then c.Enabled=false end end
		task.spawn(function()
			for _,p in ipairs(Plrs:GetPlayers()) do if p.Character then killFX(p.Character) end end
			killFX(WS:FindFirstChild("Enemies"))
		end)
		S.v2Conn=game.DescendantAdded:Connect(function(o)
			if not S.v2 then return end
			pcall(function()
				if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then o.Enabled=false; o.Rate=0
				elseif o:IsA("Beam") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then o.Enabled=false
				elseif o:IsA("BasePart") and o:IsDescendantOf(WS) then o.Material=Enum.Material.SmoothPlastic; o.Reflectance=0; o.CastShadow=false
				elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
				elseif o:IsA("BillboardGui") or o:IsA("SurfaceGui") then o.Enabled=false end
			end)
		end)
	else
		if S.v2Conn then S.v2Conn:Disconnect(); S.v2Conn=nil end
		local o=S.v2Orig
		if o.GS~=nil then L.GlobalShadows=o.GS end; if o.FE~=nil then L.FogEnd=o.FE end
		if o.SS~=nil then L.ShadowSoftness=o.SS end; pcall(function() settings().Rendering.QualityLevel=o.QL or 5 end)
		local ter=WS:FindFirstChildOfClass("Terrain")
		if ter and o.WW~=nil then ter.WaterWaveSize=o.WW; ter.WaterWaveSpeed=o.WS end
		S.v2Orig={}
	end
end
local function stripCharCosmetics(char)
	if not char then return end

	for _, obj in ipairs(char:GetChildren()) do
		pcall(function()
			if obj:IsA("Accessory") then
				obj:Destroy()
			elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
				obj:Destroy()
			end
		end)
	end

	for _, obj in ipairs(char:GetDescendants()) do
		pcall(function()
			if obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 1
			elseif obj:IsA("SpecialMesh") then
				obj.TextureId = ""
			elseif obj:IsA("MeshPart") then
				obj.TextureID = ""
				obj.RenderFidelity = Enum.RenderFidelity.Performance
				obj.CastShadow = false
			elseif obj:IsA("BasePart") then
				obj.Material = Enum.Material.SmoothPlastic
				obj.Reflectance = 0
				obj.CastShadow = false
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail")
				or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
				obj.Enabled = false
				if obj:IsA("ParticleEmitter") then obj.Rate = 0 end
			elseif obj:IsA("Beam") then
				obj.Enabled = false
			end
		end)
	end
end

local function setV3(on)
	if on then
		for _,o in ipairs(WS:GetDescendants()) do pcall(function()
			if o:IsA("MeshPart") then o.RenderFidelity=Enum.RenderFidelity.Performance; o.CastShadow=false
			elseif o:IsA("BasePart") then o.CastShadow=false; if o.Material~=Enum.Material.Neon and o.Material~=Enum.Material.ForceField then o.Material=Enum.Material.SmoothPlastic; o.Reflectance=0 end
			elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
			elseif o:IsA("Sound") then if o.Name:lower():find("ambient") or o.Name:lower():find("music") then o.Volume=0 end end
		end) end

		stripCharCosmetics(lp.Character)

		S.v3Conns[2] = lp.CharacterAdded:Connect(function(char)
			task.wait(0.5)
			if S.v3 then stripCharCosmetics(char) end
		end)
		S.v3Conns[1] = WS.DescendantAdded:Connect(function(o)
			if not S.v3 then return end
			task.defer(function() pcall(function()
				if o:IsA("MeshPart") then o.RenderFidelity=Enum.RenderFidelity.Performance; o.CastShadow=false
				elseif o:IsA("BasePart") then o.CastShadow=false; if o.Material~=Enum.Material.Neon then o.Material=Enum.Material.SmoothPlastic; o.Reflectance=0 end
				elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Sparkles") then o.Enabled=false
				elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1 end
			end) end)
		end)

		S.v3Conns[3] = lp.CharacterAdded:Connect(function(char)
			task.wait(0.3)
			if not S.v3 then return end
			char.ChildAdded:Connect(function(child)
				if not S.v3 then return end
				pcall(function()
					if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
						task.wait(0.1)
						if S.v3 then child:Destroy() end
					end
				end)
			end)
		end)

		if lp.Character then
			lp.Character.ChildAdded:Connect(function(child)
				if not S.v3 then return end
				pcall(function()
					if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
						task.wait(0.1)
						if S.v3 then child:Destroy() end
					end
				end)
			end)
		end
	else
		for _,c in ipairs(S.v3Conns) do pcall(function() c:Disconnect() end) end
		S.v3Conns={}
	end
end

-- Hide players
local function setPlrVis(p,vis)
	if not vis then
		if S.hidPlrData[p.UserId] then return end
		S.hidPlrData[p.UserId]=true
		pcall(function()
			if p.Character then
				p.Character:Destroy()
			end
		end)
	else
		S.hidPlrData[p.UserId]=nil
	end
end
local function toggleHidePlr(on)
	S.hidPlr=on
	for _,p in ipairs(Plrs:GetPlayers()) do if p~=lp then setPlrVis(p,not on) end end
	if on then
		for _,p in ipairs(Plrs:GetPlayers()) do if p~=lp then
			if S.hidPlrC[p.UserId] then S.hidPlrC[p.UserId]:Disconnect() end
			S.hidPlrC[p.UserId]=p.CharacterAdded:Connect(function() S.hidPlrData[p.UserId]=nil; if S.hidPlr then task.wait(.5); setPlrVis(p,false) end end)
		end end
		if not S.hidPlrCC.pa then S.hidPlrCC.pa=Plrs.PlayerAdded:Connect(function(p) if p==lp then return end; task.spawn(function() if not p.Character then p.CharacterAdded:Wait() end; task.wait(.5); if S.hidPlr then setPlrVis(p,false) end end) end) end
	else
		if S.hidPlrCC.pa then S.hidPlrCC.pa:Disconnect(); S.hidPlrCC.pa=nil end
		for uid,c in pairs(S.hidPlrC) do c:Disconnect(); S.hidPlrC[uid]=nil end
	end
end

-- Hide enemies
local function toggleHidEnm(on)
	S.hidEnm=on
	local ef=WS:FindFirstChild("Enemies"); if not ef then return end
	for _,o in ipairs(ef:GetDescendants()) do if o:IsA("BasePart") then
		if on then if S.hidEnmP[o]==nil then S.hidEnmP[o]=o.Transparency; o.Transparency=1 end
		else if S.hidEnmP[o]~=nil then if o.Parent then o.Transparency=S.hidEnmP[o] end; S.hidEnmP[o]=nil end end
	end end
	if on then
		S.enmConn=S.enmConn or ef.DescendantAdded:Connect(function(o) if S.hidEnm and o:IsA("BasePart") then task.wait(.1); if S.hidEnmP[o]==nil and o.Parent then S.hidEnmP[o]=o.Transparency; o.Transparency=1 end end end)
	else
		if S.enmConn then S.enmConn:Disconnect(); S.enmConn=nil end
		for p,t in pairs(S.hidEnmP) do if p and p.Parent then pcall(function() p.Transparency=t end) end end
		S.hidEnmP={}
	end
end

-- BringMob
local function bmHRP(e) return e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso") end
local function bmHum(e) return e:FindFirstChildOfClass("Humanoid") end
local function bmAlive(e) local h=bmHum(e); return h and h.Health>0 end
local function bmRelease(e)
	local d=BM.data[e]; if not d then return end
	for _,k in ipairs({"bp","bv","bg"}) do if d[k] and d[k].Parent then pcall(function() d[k]:Destroy() end) end end
	local hrp=bmHRP(e)
	if hrp then for _,c in ipairs(hrp:GetChildren()) do if c.Name:find("BringMob") then pcall(function() c:Destroy() end) end end; pcall(function() hrp.Anchored=false; hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero end) end
	local h=bmHum(e); if h then pcall(function() h.PlatformStand=false; h.WalkSpeed=16; h.JumpPower=50 end) end
	if e.Parent then for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end end end
	BM.data[e]=nil
end
local function bmClean() for e in pairs(BM.data) do pcall(bmRelease,e) end; BM.data={} end
local function bmGetOff() local a=math.random()*math.pi*2; local r=math.random(2,5); return Vector3.new(math.cos(a)*r,0,math.sin(a)*r) end
local function bmMyRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end

local function startBM()
	BM.on=true; bmClean()
	if BM.noclip then BM.noclip:Disconnect() end
	BM.noclip=Run.Heartbeat:Connect(function() for e in pairs(BM.data) do if e and e.Parent then for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then pcall(function() p.CanCollide=false end) end end end end end)
	if BM.pin then BM.pin:Disconnect() end
	bmTick=0
	BM.pin=Run.Heartbeat:Connect(function()
		bmTick = bmTick + 1; if bmTick%3~=0 then return end
		local mr=bmMyRoot(); if not mr then return end
		for e,d in pairs(BM.data) do
			if not e or not e.Parent or not d or not d.arrived then continue end
			local hrp=bmHRP(e); if not hrp then continue end
			d.anchorPos=d.anchorPos or mr.Position
			if (mr.Position-d.anchorPos).Magnitude>3 then
				d.anchorPos=mr.Position
				local nt=Vector3.new((mr.Position+d.offset).X,mr.Position.Y+BM.yOff,(mr.Position+d.offset).Z)
				d.fixedPos=nt; if d.bp and d.bp.Parent then pcall(function() d.bp.Position=nt end) else d.bp=mk("BodyPosition",hrp,{Name="BringMobBP_Fixed",MaxForce=Vector3.new(1e9,1e9,1e9),P=500000,D=10000,Position=nt}) end
			end
			if not d.bp or not d.bp.Parent then d.bp=mk("BodyPosition",hrp,{Name="BringMobBP_Fixed",MaxForce=Vector3.new(1e9,1e9,1e9),P=500000,D=10000,Position=d.fixedPos or mr.Position+d.offset}) end
			if not d.bg or not d.bg.Parent then d.bg=mk("BodyGyro",hrp,{Name="BringMobBG",MaxTorque=Vector3.new(1e9,1e9,1e9),P=100000,D=2000,CFrame=hrp.CFrame}) end
			pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero end)
		end
	end)
	BM.task=task.spawn(function()
		local PULL,HOLD=8,5; local phase="pull"; local pT=0; local lt=tick()
		while BM.on do
			task.wait(.05); local now=tick(); local dt=now-lt; lt=now; pT=pT+dt
			local mr=bmMyRoot(); if not mr then continue end
			local ap=mr.Position; local ef=WS:FindFirstChild("Enemies"); if not ef then task.wait(.3); continue end
			for e in pairs(BM.data) do if not e or not e.Parent or not bmAlive(e) then pcall(bmRelease,e) end end
			if phase=="pull" and pT>=PULL then
				for e,d in pairs(BM.data) do if not d.arrived then
					local hrp=bmHRP(e); if hrp then
						pcall(function() if d.bp and d.bp.Parent then d.bp:Destroy() end end)
						local fbp=mk("BodyPosition",hrp,{Name="BringMobBP_Fixed",MaxForce=Vector3.new(1e9,1e9,1e9),P=500000,D=10000,Position=hrp.Position})
						local bg=mk("BodyGyro",hrp,{Name="BringMobBG",MaxTorque=Vector3.new(1e9,1e9,1e9),P=100000,D=2000,CFrame=hrp.CFrame})
						pcall(function() local h=bmHum(e); if h then h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0 end end)
						d.bp=fbp; d.bg=bg; d.arrived=true; d.fixedPos=hrp.Position
					end
				end end
				phase="hold"; pT=0
			elseif phase=="hold" and pT>=HOLD then bmClean(); phase="pull"; pT=0 end
			if phase=="hold" then continue end
			local pulling=0; for _,d in pairs(BM.data) do if not d.arrived then pulling=pulling+1 end end
			for _,e in ipairs(ef:GetChildren()) do
				if not BM.on then break end
				if not e or not e.Parent or not bmAlive(e) then continue end
				local hrp=bmHRP(e); if not hrp then continue end
				if (ap-hrp.Position).Magnitude>BM.dist then if BM.data[e] and not BM.data[e].arrived then pcall(bmRelease,e) end; continue end
				if not BM.data[e] then
					if pulling>=BM.batch then continue end
					local off=bmGetOff()
					local bp=mk("BodyPosition",hrp,{Name="BringMobBP",MaxForce=Vector3.new(1e9,1e9,1e9),P=BM.force,D=2000,Position=ap+off})
					pcall(function() local h=bmHum(e); if h then h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0 end end)
					pcall(function() for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
					BM.data[e]={bp=bp,arrived=false,offset=off,stuckTime=0,lastPos=hrp.Position}; pulling=pulling+1
				end
				local d=BM.data[e]; if not d or not d.bp or not d.bp.Parent then pcall(bmRelease,e); continue end
				if d.arrived then continue end
				local tp=Vector3.new((ap+d.offset).X,ap.Y+BM.yOff,(ap+d.offset).Z)
				local dist=(hrp.Position-tp).Magnitude
				local moved=(hrp.Position-d.lastPos).Magnitude; d.lastPos=hrp.Position
				d.stuckTime=moved<.05 and d.stuckTime+.05 or 0
				pcall(function() d.bp.Position=tp end)
				if dist<=BM.snap then
					pcall(function() d.bp:Destroy() end); pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero end)
					local bv=mk("BodyVelocity",hrp,{Name="BringMobBV",MaxForce=Vector3.new(1e9,1e9,1e9),Velocity=Vector3.zero})
					task.wait()
					local fbp=mk("BodyPosition",hrp,{Name="BringMobBP_Fixed",MaxForce=Vector3.new(1e9,1e9,1e9),P=500000,D=10000,Position=hrp.Position})
					local bg=mk("BodyGyro",hrp,{Name="BringMobBG",MaxTorque=Vector3.new(1e9,1e9,1e9),P=100000,D=2000,CFrame=hrp.CFrame})
					pcall(function() local h=bmHum(e); if h then h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0 end end)
					task.delay(.5,function() if bv and bv.Parent then pcall(function() bv:Destroy() end) end end)
					d.bp=fbp; d.bg=bg; d.bv=bv; d.arrived=true; d.fixedPos=hrp.Position
				elseif d.stuckTime>=1.5 then d.offset=bmGetOff(); pcall(function() d.bp.P=100000 end); d.stuckTime=0 end
			end
		end
		if BM.pin then BM.pin:Disconnect(); BM.pin=nil end
		if BM.noclip then BM.noclip:Disconnect(); BM.noclip=nil end
		bmClean(); BM.task=nil
	end)
end
local function stopBM()
	BM.on=false
	if BM.task then task.cancel(BM.task); BM.task=nil end
	if BM.pin then BM.pin:Disconnect(); BM.pin=nil end
	if BM.noclip then BM.noclip:Disconnect(); BM.noclip=nil end
	bmClean()
end

-- Skill keys / inventory helpers
local SKILL_KEYS={"Z","X","C","V","F"}
local function getToolLv(o) local lv; pcall(function() local lo=o:FindFirstChild("Level") or o:FindFirstChildOfClass("NumberValue") or o:FindFirstChildOfClass("IntValue"); if lo then lv=lo.Value end end); return lv end
local function getEquipped() local c=lp.Character; if not c then return "None",nil end; for _,o in ipairs(c:GetChildren()) do if o:IsA("Tool") then return o.Name,getToolLv(o) end end; return "None",nil end
local function getInv()
	local items={}; local bp=lp:FindFirstChild("Backpack"); if not bp then return items end
	for _,o in ipairs(bp:GetChildren()) do if o:IsA("Tool") and o.Name~="Tool" then local lv=getToolLv(o); if lv~=nil then items[#items+1]={name=o.Name,level=lv} end end end
	return items
end
local function getSkillLevels(name)
	if S.skillC[name] and next(S.skillC[name]) then return S.skillC[name] end
	local res={}
	pcall(function()
		local main=pg:FindFirstChild("Main"); if not main then return end
		local sf=main:FindFirstChild("Skills"); if not sf then return end
		local iF=sf:FindFirstChild(name); if not iF then return end
		for _,child in ipairs(iF:GetChildren()) do
			if child.Name=="Template" or not child:IsA("Frame") then continue end
			local lo=child:FindFirstChild("Level"); if lo then
				local v
				if lo:IsA("TextLabel") or lo:IsA("TextButton") then v=tonumber(lo.Text:match("%d+"))
				elseif lo:IsA("IntValue") or lo:IsA("NumberValue") then v=lo.Value end
				if v then res[child.Name]=v end
			end
		end
	end)
	if next(res) then S.skillC[name]=res end
	return res
end
local function getRace(p)
	local rn,rt
	pcall(function()
		local ro=p:FindFirstChild("Data") and p.Data:FindFirstChild("Race"); if not ro then return end
		if ro:IsA("ValueBase") and ro.Value~="" then rn=tostring(ro.Value) end
		for _,n in ipairs({"C","V","Tier","Level","T"}) do local c=ro:FindFirstChild(n); if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then rt=c.Value; break end end
	end); return rn,rt
end

-- Watch player data
local function watchPlr(p)
	if p==lp then return end
	local uid=p.UserId; S.plrC[uid]=S.plrC[uid] or {join=tick()}
	task.spawn(function()
		local d=p:FindFirstChild("Data") or p:WaitForChild("Data",30); if not d then return end
		local sp=d:FindFirstChild("LastSpawnPoint") or d:WaitForChild("LastSpawnPoint",30); if not sp then return end
		S.plrC[uid].spawn=sp.Value
		if S.spawnW[uid] then S.spawnW[uid]:Disconnect() end
		S.spawnW[uid]=sp.Changed:Connect(function(v) S.plrC[uid]=S.plrC[uid] or {}; S.plrC[uid].spawn=v end)
	end)
	task.spawn(function()
		local d=p:FindFirstChild("Data") or p:WaitForChild("Data",30); if not d then return end
		local rc=d:FindFirstChild("Race") or d:WaitForChild("Race",30); if not rc then return end
		S.plrC[uid].race=rc:IsA("ValueBase") and rc.Value~="" and tostring(rc.Value) or nil
		local cObj=rc:FindFirstChild("C"); if cObj then S.plrC[uid].raceTier=cObj.Value end
		if S.raceW[uid] then S.raceW[uid]:Disconnect() end
		S.raceW[uid]=rc.Changed:Connect(function(v) S.plrC[uid]=S.plrC[uid] or {}; if v~="" then S.plrC[uid].race=tostring(v) end end)
	end)
	task.spawn(function()
		local bObj=getStatObj(p,"Bounty"); if not bObj then task.wait(3); bObj=getStatObj(p,"Bounty") end; if not bObj then return end
		S.plrC[uid].bounty=bObj.Value
		if S.bountyW[uid] then S.bountyW[uid]:Disconnect() end
		S.bountyW[uid]=bObj.Changed:Connect(function(v) S.plrC[uid]=S.plrC[uid] or {}; S.plrC[uid].bounty=v end)
	end)
end

-- Webhook
local function sendWebhook(sessBeli,sessFrags,elapsed,source)
	if not cfg.WebhookEnabled then return end
	local url=cfg.WebhookURL; if not url or url=="" or url:find("YOUR_ID") then return end
	source=source or "Manual"; S.whTotal=S.whTotal+1
	local function gs(k) return getStat(k) or 0 end
	local lv,beli,frag=gs("Level"),gs("Beli"),gs("Fragments")
	local melee,sword,gun,def,fruit,bounty=gs("Melee"),gs("Sword"),gs("Gun"),gs("Defense"),gs("Blox Fruit"),gs("Bounty")
	local spawn=getStat("SpawnPoint") or "Unknown"
	local raceN,raceTier="Unknown",""
	pcall(function()
		local d=lp:FindFirstChild("Data"); if not d then return end
		local rc=d:FindFirstChild("Race"); if not rc then return end
		if rc:IsA("ValueBase") and rc.Value~="" then raceN=tostring(rc.Value) end
		for _,n in ipairs({"C","V","Tier","Level","T"}) do local c=rc:FindFirstChild(n); if c and(c:IsA("NumberValue") or c:IsA("IntValue")) then raceTier="V"..c.Value; break end end
	end)
	local curHP,maxHP=0,0
	pcall(function() local c=lp.Character; if not c then return end; local h=c:FindFirstChildOfClass("Humanoid"); if h then curHP=math.floor(h.Health); maxHP=math.floor(h.MaxHealth) end end)
	local pName=lp.DisplayName~=lp.Name and(lp.DisplayName.." (@"..lp.Name..")") or lp.Name
	local minIn=math.max((elapsed or 0)/60,.01)
	local bPM=math.floor(sessBeli/minIn); local fPM2=math.floor(sessFrags/minIn)
	local grade=bPM>=50000 and "S (Very Fast)" or bPM>=20000 and "A (Good)" or bPM>=5000 and "B (Average)" or "C (Slow)"
	local srcIcon=({["Auto Hop"]="🔀",["Instant Hop"]="⚡",["Webhook Time"]="⏰",["Manual"]="🖐",["Test"]="🧪"})[source] or "📡"
	local jobId="unknown"; pcall(function() jobId=game.JobId end)
	local invLines={}; local bp=lp:FindFirstChild("Backpack")
	if bp then for _,o in ipairs(bp:GetChildren()) do if o:IsA("Tool") and o.Name~="Tool" and #invLines<5 then local lv2=getToolLv(o); invLines[#invLines+1]=lv2~=nil and("• "..o.Name.." — LV "..fmtN(math.floor(lv2))) or("• "..o.Name) end end end
	local eqStr,eqLv="Nothing",nil
	pcall(function() for _,o in ipairs((lp.Character or {}):GetChildren()) do if o:IsA("Tool") then eqStr=o.Name; eqLv=getToolLv(o); break end end end)
	local eqDisp=eqStr~="Nothing" and(eqStr..(eqLv and" [LV "..fmtN(eqLv).."]" or "")) or "None equipped"
	local skillLines={}; if eqStr~="Nothing" then local rl=getSkillLevels(eqStr); for _,k in ipairs(SKILL_KEYS) do local r=rl[k]; if r then local ready=eqLv and eqLv>=r; skillLines[#skillLines+1]=k..": "..(ready and "Ready" or("Need LV "..fmtN(r))) end end end
	local skillStr=#skillLines>0 and table.concat(skillLines,"\n") or "-"
	local fields={
		{name="👤 Player",          value="```"..pName.."```",                       inline=true},
		{name="⭐ Level",            value="```"..fmtN(math.floor(lv)).."```",         inline=true},
		{name="🧬 Race",             value="```"..raceN..(raceTier~="" and" "..raceTier or "").."```", inline=true},
		{name="❤️ HP",               value="```"..hpBar(curHP,maxHP).."```",           inline=true},
		{name="💀 Deaths",           value="```"..S.sessDeaths.."```",                 inline=true},
		{name="🏆 Bounty",           value="```"..fmtN(bounty).."```",                 inline=true},
		{name="💰 Total Beli",        value="```"..fmtN(beli).."```",                  inline=true},
		{name="💎 Total Frags",       value="```"..fmtN(frag).."```",                  inline=true},
		{name="📊 Grade",            value="```"..grade.."```",                        inline=true},
		{name="📈 Beli Gained",       value="```"..wFmt(sessBeli).."```",              inline=true},
		{name="📈 Frags Gained",      value="```"..wFmt(sessFrags).."```",             inline=true},
		{name="⏱ Session",           value="```"..fmtS(elapsed or 0).."```",          inline=true},
		{name="⚡ Beli/Min",          value="```"..wFmt(bPM).."```",                   inline=true},
		{name="⚡ Beli/Hr",           value="```"..wFmt(bPM*60).."```",                inline=true},
		{name="⚡ Frag/Min",          value="```"..wFmt(fPM2).."```",                  inline=true},
		{name="⚔️ Stats",            value="```\nMelee   "..statBar(melee,K.COMBAT).."\nSword   "..statBar(sword,K.COMBAT).."\nGun     "..statBar(gun,K.COMBAT).."\nDefense "..statBar(def,K.COMBAT).."\nFruit   "..statBar(fruit,K.COMBAT).."\n```", inline=false},
		{name="🗡️ Equipped",          value="```"..eqDisp.."```",                     inline=true},
		{name="🎯 Skills",            value="```\n"..skillStr.."\n```",                inline=true},
		{name="📍 Spawn",            value="```"..tostring(spawn).."```",              inline=true},
		{name="👥 Players",          value="```"..#Plrs:GetPlayers().."/"..K.MAX.."```", inline=true},
		{name="🖥 FPS / Ping",       value="```"..S.fps.." FPS | "..getPing().."ms```", inline=true},
		{name="🎒 Backpack",         value="```\n"..( #invLines>0 and table.concat(invLines,"\n") or "-").."\n```", inline=false},
		{name="📨 Report #",         value="```#"..S.whTotal.."```",                   inline=true},
		{name="📡 Source",           value="```"..source.."```",                        inline=true},
		{name="🕐 Time",             value="```"..localT().."```",                      inline=true},
	}
	if source=="Auto Hop" or source=="Instant Hop" then
		fields[#fields+1]={name="🔀 Hop #",value="```#"..S.hopTotal.."```",inline=true}
		fields[#fields+1]={name="🌐 Target",value="```"..(S.hopTarget~="" and S.hopTarget or "all").."```",inline=true}
		fields[#fields+1]={name="🆔 Prev Job",value="```"..tostring(jobId):sub(1,36).."```",inline=false}
	end
	local payload={username=cfg.WebhookName or "BloxHub",embeds={{
		author={name="Panel — "..source},
		title=srcIcon.."  Session Report — "..source,
		description="**"..pName.."** | Session: **"..fmtS(elapsed or 0).."**\n\n"..trendIcon(bPM).."  Beli "..wFmt(sessBeli).." ("..wFmt(bPM).."/min)\n"..trendIcon(fPM2).."  Frags "..wFmt(sessFrags).." ("..wFmt(fPM2).."/min)\n\nEfficiency: **"..grade.."**",
		color=sessBeli>=0 and 3066993 or 15158332,fields=fields,
		footer={text="Panel • Report #"..S.whTotal.." • "..source},timestamp=ts(),
	}}}
	local ok,json=pcall(function() return HTTP:JSONEncode(payload) end); if not ok then return end
	local opts={Url=url,Method="POST",Headers={["Content-Type"]="application/json"},Body=json}
	local sent=false
	local function tryR(fn)
		if sent or not fn then return end
		local ok2,r=pcall(fn,opts)
		if ok2 and r then print("[WH] #"..S.whTotal,r.StatusCode,source); sent=true end
	end
	tryR(typeof(request)=="function" and request)
	tryR(typeof(http_request)=="function" and http_request)
	tryR(syn and typeof(syn.request)=="function" and syn.request)
	tryR(http and typeof(http.request)=="function" and http.request)
	tryR(getgenv and typeof(getgenv().request)=="function" and getgenv().request)
	tryR(fluxus and typeof(fluxus.request)=="function" and fluxus.request)
	if not sent then warn("[WH] No request function found") end
end

-- Webhook timer
local function startWHTimer()
	S.whTimer=true; S.whCD=cfg.WebhookInterval*60; S.whTick=tick()
	if S.whThread then task.cancel(S.whThread) end
	S.whThread=task.spawn(function()
		while S.whTimer do
			task.wait(1); local now=tick(); S.whCD=S.whCD-(now-S.whTick); S.whTick=now
			if S.whCD<=0 then
				S.whCD=cfg.WebhookInterval*60
				if S.whTimer and cfg.WebhookEnabled then task.spawn(function()
					local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0
					local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick()
					sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0,S.sessOK and math.floor(cf-(S.sessF or cf)) or 0,tick()-jt,"Webhook Time")
				end) end
			end
		end
	end)
end
local function stopWHTimer()
	S.whTimer=false; if S.whThread then task.cancel(S.whThread); S.whThread=nil end; S.whCD=cfg.WebhookInterval*60
end

-- Auto hop
local function doHop()
	local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0
	local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick()
	S.hopTotal=S.hopTotal+1
	task.spawn(function() sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0,S.sessOK and math.floor(cf-(S.sessF or cf)) or 0,tick()-jt,"Auto Hop") end)
	local sb=pg:FindFirstChild("ServerBrowser"); if not sb then return end
	sb.Enabled=true; local frame=sb:FindFirstChild("Frame")
	if frame then pcall(function() frame.Visible=true end) end
	pcall(function() frame.Filters.SearchRegion.TextBox.Text=S.hopTarget~="" and S.hopTarget or "" end)
	pcall(function() frame.Refresh:Activate() end); task.wait(3)
	local inside=frame and frame:FindFirstChild("FakeScroll") and frame.FakeScroll:FindFirstChild("Inside"); if not inside then return end
	local tried={}
	local function tryHop()
		for _,child in ipairs(inside:GetChildren()) do
			if not child:IsA("Frame") then continue end
			local jb=child:FindFirstChild("Join"); if not jb or jb.Text~="Join" then continue end
			local tl=child:FindFirstChildOfClass("TextLabel"); if not tl or tl.Text:find("ERROR") then continue end
			local cur,max=tl.Text:match("Players: (%d+)/(%d+)"); cur=tonumber(cur); max=tonumber(max)
			if cur and max and cur>=max-1 then continue end
			local jobId=jb:GetAttribute("Job"); if not jobId or tried[jobId] then continue end
			tried[jobId]=true
			local fc; fc=game:GetService("TeleportService").TeleportInitFailed:Connect(function(_,_,msg) print("[Hop] Failed:",msg); if fc then fc:Disconnect(); fc=nil end; task.wait(1); tryHop() end)
			for _,c in ipairs(getconnections(jb.MouseButton1Click)) do c:Fire() end
			task.delay(5,function() if fc then fc:Disconnect(); fc=nil end end); return
		end
		tried={}; pcall(function() frame.Refresh:Activate() end); task.wait(3); tryHop()
	end
	tryHop()
end
local function startHop()
	S.hop=true; S.hopCD=(cfg.HopInterval or 45)*60; S.hopTick=tick()
	if S.hopThread then task.cancel(S.hopThread) end
	S.hopThread=task.spawn(function()
		while S.hop do
			task.wait(1); local now=tick(); S.hopCD=S.hopCD-(now-S.hopTick); S.hopTick=now
			if S.hopCD<=0 then S.hopCD=(cfg.HopInterval or 45)*60; if S.hop then task.spawn(doHop) end end
		end
	end)
end
local function stopHop()
	S.hop=false; if S.hopThread then task.cancel(S.hopThread); S.hopThread=nil end
	S.hopCD=(cfg.HopInterval or 45)*60
	pcall(function() local sb=pg:FindFirstChild("ServerBrowser"); if sb then sb.Enabled=false; local f=sb:FindFirstChild("Frame"); if f then f.Visible=false end end end)
end

-- === GUI ===
local hudPos=UDim2.new(.5,-K.HW/2,.5,-K.HH/2)
local full=mk("Frame",gui,{Size=UDim2.new(0,K.HW,0,K.HH),Position=hudPos,BackgroundColor3=C.PAN,BorderSizePixel=0,ClipsDescendants=true})
stroke(full,C.BOR2,2); corner(full,8)
mk("Frame",full,{Size=UDim2.new(0,1,0,K.HH-K.PAD*2),Position=UDim2.new(0,K.HF,0,K.PAD),BackgroundColor3=C.SEP,ZIndex=3})
mk("Frame",full,{Size=UDim2.new(0,K.HW-K.PAD*2,0,1),Position=UDim2.new(0,K.PAD,0,K.HH/2),BackgroundColor3=C.SEP,ZIndex=3})

local mini=mk("Frame",gui,{Size=UDim2.new(0,740,0,44),Position=UDim2.new(.5,-370,.5,-K.HH/2),BackgroundColor3=C.PAN,BorderSizePixel=0,Visible=false})
stroke(mini,C.BOR2,2); corner(mini,5)

-- Drag
full.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then S.drag=true; S.dragS=i.Position; S.dragP=full.Position end end)
UIS.InputChanged:Connect(function(i) if S.drag and i.UserInputType==Enum.UserInputType.MouseMovement then local ok,d=pcall(function() return i.Position-S.dragS end); if not ok then S.drag=false; return end; local np=UDim2.new(S.dragP.X.Scale,S.dragP.X.Offset+d.X,S.dragP.Y.Scale,S.dragP.Y.Offset+d.Y); full.Position=np; mini.Position=np end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then S.drag=false end end)

-- Helper: scroll frame
local function scroll(par,x,y,w,h) local sf=mk("ScrollingFrame",par,{Size=UDim2.new(0,w,0,h),Position=UDim2.new(0,x,0,y),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BOR2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=3}); local inn=mk("Frame",sf,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ZIndex=3}); return sf,inn end

-- Q1 (controls left top)
local _,q1=scroll(full,K.PAD,K.PAD,K.Q1W+K.PAD,K.HH/2-K.PAD*2)
local UI={}
UI.ava=mk("ImageLabel",q1,{Size=UDim2.new(0,52,0,52),BackgroundColor3=C.CARD,ZIndex=4}); stroke(UI.ava,C.BOR2,2); corner(UI.ava,5)
UI.charLbl=lbl(q1,{size=UDim2.new(0,K.Q1W-58,0,16),pos=UDim2.new(0,56,0,0), sz=12,col=C.WHT,txt="Loading...",tr=Enum.TextTruncate.AtEnd,z=4})
UI.lvlLbl =lbl(q1,{size=UDim2.new(0,K.Q1W-58,0,13),pos=UDim2.new(0,56,0,18),sz=10,col=C.MUT,txt="LV. 0",z=4})
local dot=mk("Frame",q1,{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,56,0,36),BackgroundColor3=C.OK,ZIndex=4}); corner(dot,4)
lbl(q1,{size=UDim2.new(0,55,0,11),pos=UDim2.new(0,67,0,34),sz=9,col=C.DIM,txt="ONLINE",z=4})
task.spawn(function() while true do tw(dot,{BackgroundTransparency=.5},.8); task.wait(.8); tw(dot,{BackgroundTransparency=0},.8); task.wait(.8) end end)
local cW=math.floor(K.Q1W/3)
local function mRow(x,y,w,lb) lbl(q1,{size=UDim2.new(0,w,0,11),pos=UDim2.new(0,x,0,y),sz=9,col=C.DIM,txt=lb,z=4}); return lbl(q1,{size=UDim2.new(0,w,0,13),pos=UDim2.new(0,x,0,y+11),sz=11,col=C.OFF,txt="???",tr=Enum.TextTruncate.AtEnd,z=4}) end
UI.raceLbl=mRow(0,64,cW-4,"RACE"); UI.teamLbl=mRow(cW,64,cW-4,"TEAM"); UI.spawnLbl=mRow(cW*2,64,cW-4,"SPAWN")
UI.fpsLbl =lbl(q1,{size=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,92),sz=12,col=C.OFF,txt="FPS 0",z=4})
UI.pingLbl=lbl(q1,{size=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,108),sz=12,col=C.OFF,txt="PING 0ms",z=4})
UI.timeLbl=lbl(q1,{size=UDim2.new(0,K.Q1W,0,13),pos=UDim2.new(0,0,0,124),font=Enum.Font.Gotham,sz=10,col=C.DIM,txt="00:00:00",z=4})
local bW3=math.floor((K.Q1W-8)/3); local bW=math.floor((K.Q1W-6)/2)
UI.v1Btn =btn(q1,0,      142,bW3,20,"Boost V1: Off",false,C.V1)
UI.v2Btn =btn(q1,bW3+4,  142,bW3,20,"Boost V2: Off",false,C.V2)
UI.v3Btn =btn(q1,bW3*2+8,142,bW3,20,"Boost V3: Off",false,C.V3)
UI.hidBtn=btn(q1,0,      166,bW, 20,"Del Players: Off",false,C.WHT)
UI.minBtn=btn(q1,bW+6,   166,bW, 20,"Minimize",false,C.CARD); UI.minBtn.TextColor3=C.MUT
UI.enmBtn=btn(q1,0,      190,bW, 20,"Hide Enemies: Off",false,C.ERR)
UI.hopBtn=btn(q1,bW+6,   190,bW-28,20,"Auto Hop: Off",false,C.HOP)
UI.hopNowBtn=btn(q1,K.Q1W-22,190,22,20,"▶",true,C.HOP); UI.hopNowBtn.TextColor3=C.BG
local capBox=box(q1,0,214,bW-34,20,tostring(cfg.LockFps.fps))
local setCapBtn=btn(q1,bW-28,214,28,20,"SET",true,C.WHT); setCapBtn.TextColor3=C.BG
local WHW=math.floor((K.Q1W-4)*.60)
UI.whBtn    =btn(q1,0,    238,WHW,          20,"Webhook: Off",false,C.WH)
UI.whTestBtn=btn(q1,WHW+4,238,K.Q1W-WHW-4, 20,"Test",false,C.CARD); UI.whTestBtn.TextColor3=Color3.fromRGB(255,200,60)
UI.whTimBtn =btn(q1,0,    262,K.Q1W-26,20,"WH Timer: Off",false,C.CARD); UI.whTimBtn.TextColor3=C.MUT
lbl(q1,{size=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,0,0,286),sz=8,col=C.DIM,txt="HOP COUNTDOWN",z=4})
UI.hopCD=lbl(q1,{size=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,296),font=Enum.Font.GothamBold,sz=11,col=C.HOP,txt="DISABLED",z=4})
lbl(q1,{size=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,0,0,314),sz=8,col=C.DIM,txt="WH TIMER",z=4})
UI.whCD=lbl(q1,{size=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,324),font=Enum.Font.GothamBold,sz=11,col=C.WH,txt="DISABLED",z=4})
lbl(q1,{size=UDim2.new(0,K.Q1W,0,10),pos=UDim2.new(0,0,0,342),sz=8,col=C.DIM,txt="BRING MOBS",z=4})
UI.pullBtn=btn(q1,0,352,bW,20,"BringMobs: Off",false,C.CARD); UI.pullBtn.TextColor3=C.MUT
local distBox=box(q1,bW+6,352,bW-30,20,"Dist: 1000")
local setDistBtn=btn(q1,K.Q1W-24,352,24,20,"SET",true,C.WHT); setDistBtn.TextColor3=C.BG
UI.bmCountLbl=lbl(q1,{size=UDim2.new(0,K.Q1W,0,14),pos=UDim2.new(0,0,0,378),font=Enum.Font.GothamBold,sz=10,col=C.DIM,txt="BringMobs: Off",z=4})

-- Q2 (stats right top)
local _,q2=scroll(full,K.Q2X,K.PAD,K.Q2W,K.HH/2-K.PAD*2)
local rH=36
local function sBlock(iy,lb,col)
	lbl(q2,{size=UDim2.new(0,K.Q2W-4,0,12),pos=UDim2.new(0,0,0,iy),sz=9,col=C.DIM,txt=lb,z=4})
	local vl=lbl(q2,{size=UDim2.new(0,K.Q2W-4,0,17),pos=UDim2.new(0,0,0,iy+12),sz=13,col=C.OFF,txt="0",tr=Enum.TextTruncate.AtEnd,z=4})
	local bf; if col then local bb=mk("Frame",q2,{Size=UDim2.new(0,K.Q2W-8,0,3),Position=UDim2.new(0,0,0,iy+31),BackgroundColor3=C.BOR,ZIndex=4}); corner(bb,1); bf=mk("Frame",bb,{Size=UDim2.new(0,0,1,0),BackgroundColor3=col,ZIndex=5}); corner(bf,1) end
	return vl,bf
end
UI.beliLbl,_=sBlock(0,"BELI",nil); UI.fragLbl,_=sBlock(rH,"FRAGMENTS",nil)
UI.meleeLbl,UI.meleeBar=sBlock(rH*2,"MELEE",C.V1); UI.defLbl,UI.defBar=sBlock(rH*3,"DEFENSE",C.V1)
UI.swordLbl,UI.swordBar=sBlock(rH*4,"SWORD",C.V1); UI.gunLbl,UI.gunBar=sBlock(rH*5,"GUN",C.V1)
UI.fruitLbl,UI.fruitBar=sBlock(rH*6,"BLOX FRUIT",C.WRN)
local sY=rH*7+4; local cL=math.floor(K.Q2W/2)-4; local cR=K.Q2W-math.floor(K.Q2W/2)-8; local xR=math.floor(K.Q2W/2)+2
mk("Frame",q2,{Size=UDim2.new(0,K.Q2W-4,0,1),Position=UDim2.new(0,0,0,sY-3),BackgroundColor3=C.SEP,ZIndex=4})
lbl(q2,{size=UDim2.new(0,cL,0,10),pos=UDim2.new(0,0,0,sY),sz=8,col=C.DIM,txt="SESSION BELI",z=4})
UI.sessBLbl=lbl(q2,{size=UDim2.new(0,cL,0,15),pos=UDim2.new(0,0,0,sY+10),sz=12,col=C.BELI,txt="+0",z=4})
lbl(q2,{size=UDim2.new(0,cR,0,10),pos=UDim2.new(0,xR,0,sY),sz=8,col=C.DIM,txt="SESSION FRAG",ax=Enum.TextXAlignment.Right,z=4})
UI.sessFLbl=lbl(q2,{size=UDim2.new(0,cR,0,15),pos=UDim2.new(0,xR,0,sY+10),sz=12,col=C.FRAG,txt="+0",ax=Enum.TextXAlignment.Right,z=4})
mk("Frame",q2,{Size=UDim2.new(0,K.Q2W-4,0,1),Position=UDim2.new(0,0,0,sY+28),BackgroundColor3=C.SEP,ZIndex=4})
lbl(q2,{size=UDim2.new(0,cL,0,10),pos=UDim2.new(0,0,0,sY+44),sz=8,col=C.DIM,txt="BELI/MIN",z=4}); lbl(q2,{size=UDim2.new(0,cR,0,10),pos=UDim2.new(0,xR,0,sY+44),sz=8,col=C.DIM,txt="BELI/HR",ax=Enum.TextXAlignment.Right,z=4})
UI.bPMLbl=lbl(q2,{size=UDim2.new(0,cL,0,15),pos=UDim2.new(0,0,0,sY+54),sz=12,col=C.BELI,txt="+0",z=4})
UI.bHRLbl=lbl(q2,{size=UDim2.new(0,cR,0,15),pos=UDim2.new(0,xR,0,sY+54),sz=12,col=C.BELI,txt="+0",ax=Enum.TextXAlignment.Right,z=4})
lbl(q2,{size=UDim2.new(0,cL,0,10),pos=UDim2.new(0,0,0,sY+72),sz=8,col=C.DIM,txt="FRAG/MIN",z=4}); lbl(q2,{size=UDim2.new(0,cR,0,10),pos=UDim2.new(0,xR,0,sY+72),sz=8,col=C.DIM,txt="FRAG/HR",ax=Enum.TextXAlignment.Right,z=4})
UI.fPMLbl=lbl(q2,{size=UDim2.new(0,cL,0,15),pos=UDim2.new(0,0,0,sY+82),sz=12,col=C.FRAG,txt="+0",z=4})
UI.fHRLbl=lbl(q2,{size=UDim2.new(0,cR,0,15),pos=UDim2.new(0,xR,0,sY+82),sz=12,col=C.FRAG,txt="+0",ax=Enum.TextXAlignment.Right,z=4})

-- Q3 (players left bottom)
lbl(full,{size=UDim2.new(0,K.Q3W,0,12),pos=UDim2.new(0,K.Q3X,0,K.Q3Y),sz=9,col=C.DIM,txt="PLAYERS",z=4})
UI.pcLbl=lbl(full,{size=UDim2.new(0,100,0,18),pos=UDim2.new(0,K.Q3X,0,K.Q3Y+12),sz=14,col=C.WHT,txt="? / "..K.MAX,z=4})
local svrBg=mk("Frame",full,{Size=UDim2.new(0,K.Q3W,0,3),Position=UDim2.new(0,K.Q3X,0,K.Q3Y+32),BackgroundColor3=C.BOR,ZIndex=4}); corner(svrBg,1)
UI.svrBar=mk("Frame",svrBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.WHT,ZIndex=5}); corner(UI.svrBar,1)
lbl(full,{size=UDim2.new(0,K.Q3W/2,0,12),pos=UDim2.new(0,K.Q3X+K.Q3W/2,0,K.Q3Y),sz=9,col=C.DIM,txt="TOTAL BOUNTY",ax=Enum.TextXAlignment.Right,z=4})
UI.bountyLbl=lbl(full,{size=UDim2.new(0,K.Q3W/2,0,18),pos=UDim2.new(0,K.Q3X+K.Q3W/2,0,K.Q3Y+12),sz=12,col=Color3.fromRGB(255,160,60),txt="0",ax=Enum.TextXAlignment.Right,z=4})
local plrSF=mk("ScrollingFrame",full,{Size=UDim2.new(0,K.Q3W,0,K.HH/2-K.PAD*2-42),Position=UDim2.new(0,K.Q3X,0,K.Q3Y+38),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BOR2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=3})
mk("UIListLayout",plrSF,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
local plrRows={}
for i=1,20 do
	local row=mk("Frame",plrSF,{Size=UDim2.new(1,-4,0,58),BackgroundColor3=C.CARD,ZIndex=4,LayoutOrder=i,Visible=false}); stroke(row,C.BOR2,1); corner(row,4)
	plrRows[i]={row=row,
		nameLbl =lbl(row,{size=UDim2.new(1,-62,0,14),pos=UDim2.new(0,6,0,2), sz=11,col=C.WHT, txt="",tr=Enum.TextTruncate.AtEnd,z=5}),
		lvlLbl  =lbl(row,{size=UDim2.new(0,56,0,14), pos=UDim2.new(1,-60,0,2), sz=10,col=C.MUT,txt="",ax=Enum.TextXAlignment.Right,z=5}),
		raceLbl =lbl(row,{size=UDim2.new(0,90,0,12), pos=UDim2.new(0,6,0,18),font=Enum.Font.Gotham,sz=9,col=Color3.fromRGB(100,180,255),txt="",tr=Enum.TextTruncate.AtEnd,z=5}),
		spawnLbl=lbl(row,{size=UDim2.new(1,-100,0,12),pos=UDim2.new(0,100,0,18),font=Enum.Font.Gotham,sz=9,col=C.DIM,txt="",tr=Enum.TextTruncate.AtEnd,z=5}),
		bountyLbl=lbl(row,{size=UDim2.new(1,-90,0,12),pos=UDim2.new(0,6,0,32),font=Enum.Font.Gotham,sz=9,col=Color3.fromRGB(255,160,60),txt="",tr=Enum.TextTruncate.AtEnd,z=5}),
		distLbl =lbl(row,{size=UDim2.new(0,80,0,12), pos=UDim2.new(1,-84,0,32),font=Enum.Font.Gotham,sz=9,col=Color3.fromRGB(180,180,255),txt="",ax=Enum.TextXAlignment.Right,z=5}),
		timeLbl =lbl(row,{size=UDim2.new(1,-6,0,12), pos=UDim2.new(0,6,0,46),font=Enum.Font.Gotham,sz=9,col=Color3.fromRGB(180,220,255),txt="",tr=Enum.TextTruncate.AtEnd,z=5}),
	}
end

-- Q4 (inventory right bottom)
lbl(full,{size=UDim2.new(0,K.Q4W,0,12),pos=UDim2.new(0,K.Q4X,0,K.Q4Y),sz=9,col=C.DIM,txt="EQUIPPED",z=4})
UI.eqNameLbl=lbl(full,{size=UDim2.new(0,K.Q4W,0,17),pos=UDim2.new(0,K.Q4X,0,K.Q4Y+12),sz=13,col=C.OFF,txt="None",tr=Enum.TextTruncate.AtEnd,z=4})
UI.eqLvLbl  =lbl(full,{size=UDim2.new(0,K.Q4W,0,13),pos=UDim2.new(0,K.Q4X,0,K.Q4Y+30),font=Enum.Font.GothamBold,sz=10,col=C.WRN,txt="",z=4})
lbl(full,{size=UDim2.new(0,K.Q4W,0,12),pos=UDim2.new(0,K.Q4X,0,K.Q4Y+48),sz=9,col=C.DIM,txt="INVENTORY",z=4})
local invSF=mk("ScrollingFrame",full,{Size=UDim2.new(0,K.Q4W,0,K.HH/2-K.PAD-62-2),Position=UDim2.new(0,K.Q4X,0,K.Q4Y+62),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BOR2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=3})
mk("UIListLayout",invSF,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
local invRows={}
for i=1,20 do
	local cell=mk("Frame",invSF,{Size=UDim2.new(1,-4,0,56),BackgroundColor3=C.CARD,ZIndex=4,LayoutOrder=i,Visible=false}); stroke(cell,C.BOR2,1); corner(cell,4)
	local skillLbls={}
	for si,key in ipairs(SKILL_KEYS) do
		local x=8+(si-1)*40
		local kl=lbl(cell,{size=UDim2.new(0,38,0,11),pos=UDim2.new(0,x,0,27),sz=8,col=C.DIM,txt=key,ax=Enum.TextXAlignment.Center,z=5})
		local cl=lbl(cell,{size=UDim2.new(0,38,0,16),pos=UDim2.new(0,x,0,38),sz=13,col=C.OK,txt="",ax=Enum.TextXAlignment.Center,z=5})
		kl.Visible=false; cl.Visible=false; skillLbls[key]={kl=kl,cl=cl}
	end
	invRows[i]={cell=cell,
		nameLbl=lbl(cell,{size=UDim2.new(1,-68,0,16),pos=UDim2.new(0,8,0,4),sz=11,col=C.OFF,txt="",tr=Enum.TextTruncate.AtEnd,z=5}),
		lvlLbl =lbl(cell,{size=UDim2.new(0,60,0,16),pos=UDim2.new(1,-66,0,4),sz=10,col=C.WRN,txt="",ax=Enum.TextXAlignment.Right,z=5}),
		skillLbls=skillLbls,
	}
	mk("Frame",cell,{Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,0,23),BackgroundColor3=C.SEP,ZIndex=5})
end

-- Minibar
UI.miniAva=mk("ImageLabel",mini,{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,6,0,8),BackgroundColor3=C.CARD,ZIndex=3}); stroke(UI.miniAva,C.BOR2,1); corner(UI.miniAva,4)
UI.miniName=lbl(mini,{size=UDim2.new(0,120,0,16),pos=UDim2.new(0,38,0,6),sz=12,col=C.WHT,txt="Loading...",z=3})
UI.miniLvl =lbl(mini,{size=UDim2.new(0,90,0,12),pos=UDim2.new(0,38,0,24),font=Enum.Font.Gotham,sz=10,col=C.DIM,txt="LV. 0",z=3})
local function miniCol(x,lb,col) lbl(mini,{size=UDim2.new(0,90,0,12),pos=UDim2.new(0,x,0,6),sz=9,col=C.DIM,txt=lb,z=3}); return lbl(mini,{size=UDim2.new(0,90,0,16),pos=UDim2.new(0,x,0,22),sz=12,col=col or C.WHT,txt="...",z=3}) end
UI.miniFps=miniCol(170,"FPS"); UI.miniPing=miniCol(270,"PING"); UI.miniBeli=miniCol(370,"BELI",C.BELI); UI.miniFrag=miniCol(470,"FRAG",C.FRAG)
local expandBtn=mk("TextButton",mini,{Size=UDim2.new(0,30,0,26),Position=UDim2.new(1,-36,0,9),BackgroundColor3=C.CARD,BorderSizePixel=0,Text="▼",TextColor3=C.MUT,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=5}); stroke(expandBtn,C.BOR2,1); corner(expandBtn,4)
task.spawn(function() local ok,t=pcall(function() return Plrs:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end); if ok and t then UI.ava.Image=t; UI.miniAva.Image=t end end)

-- View toggle
local function setView(isMini)
	S.isMini=isMini
	if isMini then tw(full,{BackgroundTransparency=1},.18); task.delay(.18,function() full.Visible=false; full.BackgroundTransparency=0 end); mini.BackgroundTransparency=1; mini.Visible=true; tw(mini,{BackgroundTransparency=0},.18)
	else tw(mini,{BackgroundTransparency=1},.18); task.delay(.18,function() mini.Visible=false; mini.BackgroundTransparency=0 end); full.BackgroundTransparency=1; full.Visible=true; tw(full,{BackgroundTransparency=0},.18) end
end
expandBtn.MouseButton1Click:Connect(function() setView(false) end)
UI.minBtn.MouseButton1Click:Connect(function() setView(true) end)
UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightControl then setView(not S.isMini) end end)

-- Button toggle helper
local function tog(b,on,onC,offC,onT,offT) tw(b,{BackgroundColor3=on and onC or offC},.18); b.Text=on and onT or offT; b.TextColor3=on and C.BG or C.MUT end
local function addHov(b,getC) b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=C.HOV},.12) end); b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=getC()},.12) end) end

-- Button connections
UI.v1Btn.MouseButton1Click:Connect(function() S.v1=not S.v1; task.spawn(setV1,S.v1); tog(UI.v1Btn,S.v1,C.V1,C.CARD,"Boost V1: On","Boost V1: Off"); showN("Boost V1",S.v1 and "On - Map hidden" or "Off - Map restored",S.v1 and C.V1 or C.ERR) end)
UI.v2Btn.MouseButton1Click:Connect(function() S.v2=not S.v2; task.spawn(setV2,S.v2); tog(UI.v2Btn,S.v2,C.V2,C.CARD,"Boost V2: On","Boost V2: Off"); showN("Boost V2",S.v2 and "On - Low graphics" or "Off - Graphics restored",S.v2 and C.V2 or C.ERR) end)
UI.v3Btn.MouseButton1Click:Connect(function() S.v3=not S.v3; task.spawn(setV3,S.v3); tog(UI.v3Btn,S.v3,C.V3,C.CARD,"Boost V3: On","Boost V3: Off"); showN("Boost V3",S.v3 and "On - Cosmetics/Mesh/FX removed" or "Off",S.v3 and C.V3 or C.ERR) end)
UI.hidBtn.MouseButton1Click:Connect(function() S.hidPlr=not S.hidPlr; toggleHidePlr(S.hidPlr); tog(UI.hidBtn,S.hidPlr,C.WHT,C.CARD,"Del Players: On","Del Players: Off"); showN("Delete Players",S.hidPlr and "All players hidden" or "Players restored",S.hidPlr and C.OK or C.ERR) end)
UI.enmBtn.MouseButton1Click:Connect(function() S.hidEnm=not S.hidEnm; task.spawn(toggleHidEnm,S.hidEnm); tog(UI.enmBtn,S.hidEnm,C.ERR,C.CARD,"Hide Enemies: On","Hide Enemies: Off"); showN("Hide Enemies",S.hidEnm and "Enemies hidden" or "Enemies restored",S.hidEnm and C.ERR or C.DIM) end)
UI.whBtn.MouseButton1Click:Connect(function() S.wh=not S.wh; cfg.WebhookEnabled=S.wh; tog(UI.whBtn,S.wh,C.WH,C.CARD,"Webhook: On","Webhook: Off"); showN("Webhook",S.wh and "Enabled" or "Disabled",S.wh and C.WH or C.ERR) end)
UI.whTestBtn.MouseButton1Click:Connect(function() task.spawn(function() local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0; local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick(); sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0,S.sessOK and math.floor(cf-(S.sessF or cf)) or 0,tick()-jt,"Test"); showN("Test Webhook","Sent! #"..S.whTotal,C.WH) end) end)
UI.whTimBtn.MouseButton1Click:Connect(function()
	if S.whTimer then stopWHTimer(); tog(UI.whTimBtn,false,C.WH,C.CARD,"WH Timer: On","WH Timer: Off"); showN("WH Timer","Disabled",C.ERR)
	else if not S.wh then S.wh=true; cfg.WebhookEnabled=true; tog(UI.whBtn,true,C.WH,C.CARD,"Webhook: On","Webhook: Off") end; startWHTimer(); tog(UI.whTimBtn,true,C.WH,C.CARD,"WH Timer: On","WH Timer: Off"); showN("WH Timer","Sending every "..cfg.WebhookInterval.." min",C.WH) end
end)
UI.hopBtn.MouseButton1Click:Connect(function()
	if S.hop then stopHop(); tog(UI.hopBtn,false,C.HOP,C.CARD,"Auto Hop: On","Auto Hop: Off"); showN("Auto Hop","Disabled",C.ERR)
	else startHop(); tog(UI.hopBtn,true,C.HOP,C.CARD,"Auto Hop: On","Auto Hop: Off"); showN("Auto Hop","Every "..(cfg.HopInterval).." min",C.HOP) end
end)
UI.hopNowBtn.MouseButton1Click:Connect(function() showN("Hop Now","Hopping...",C.HOP); task.spawn(function() local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0; local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick(); S.hopTotal=S.hopTotal+1; sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0,S.sessOK and math.floor(cf-(S.sessF or cf)) or 0,tick()-jt,"Instant Hop"); doHop() end) end)
UI.pullBtn.MouseButton1Click:Connect(function()
	if BM.on then stopBM(); tog(UI.pullBtn,false,C.PULL,C.CARD,"BringMobs: On","BringMobs: Off"); UI.pullBtn.TextColor3=C.MUT; showN("BringMobs","Disabled - Mobs released",C.ERR)
	else startBM(); tog(UI.pullBtn,true,C.PULL,C.CARD,"BringMobs: On","BringMobs: Off"); showN("BringMobs","Enabled | Dist: "..BM.dist,C.PULL) end
end)
setDistBtn.MouseButton1Click:Connect(function() local n=tonumber(distBox.Text); if n and n>0 then BM.dist=n; distBox.Text=""; distBox.PlaceholderText="Dist: "..n; showN("BringMobs","Dist → "..n,C.WRN) end end)
setCapBtn.MouseButton1Click:Connect(function() local n=tonumber(capBox.Text); if n and n>0 then pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate=n end); pcall(function() setfpscap(n) end); capBox.Text=""; capBox.PlaceholderText=tostring(n); showN("FPS Cap","Set to "..n.." FPS",C.OK) end end)
capBox.FocusLost:Connect(function(e) if e then local n=tonumber(capBox.Text); if n and n>0 then pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate=n end); pcall(function() setfpscap(n) end); capBox.Text=""; capBox.PlaceholderText=tostring(n); showN("FPS Cap","Set to "..n.." FPS",C.OK) end end end)

-- Hover effects
for _,h in ipairs({
	{UI.v1Btn,function() return S.v1 and C.V1 or C.CARD end},{UI.v2Btn,function() return S.v2 and C.V2 or C.CARD end},{UI.v3Btn,function() return S.v3 and C.V3 or C.CARD end},
	{UI.hidBtn,function() return S.hidPlr and C.WHT or C.CARD end},{UI.enmBtn,function() return S.hidEnm and C.ERR or C.CARD end},
	{UI.hopBtn,function() return S.hop and C.HOP or C.CARD end},{UI.hopNowBtn,function() return C.HOP end},
	{UI.minBtn,function() return C.CARD end},{setCapBtn,function() return C.WHT end},
	{UI.whBtn,function() return S.wh and C.WH or C.CARD end},{UI.whTestBtn,function() return C.CARD end},
	{UI.whTimBtn,function() return S.whTimer and C.WH or C.CARD end},
	{UI.pullBtn,function() return BM.on and C.PULL or C.CARD end},{setDistBtn,function() return C.WHT end},
}) do addHov(h[1],h[2]) end

-- Self highlight
local function applyHL(char)
	if S.selfHL and S.selfHL.Parent then S.selfHL:Destroy() end; S.selfHL=nil
	if not char then return end
	S.selfHL=mk("Highlight",char,{Name="ESP_SelfHL",FillColor=Color3.fromRGB(255,255,255),OutlineColor=Color3.new(0,0,0),FillTransparency=.5,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Adornee=char})
end
if lp.Character then task.delay(.5,function() applyHL(lp.Character) end) end
lp.CharacterAdded:Connect(function(char) task.wait(.5); applyHL(char) end)

-- FPS counter
Run.RenderStepped:Connect(function() S.fc=S.fc+1; local n=tick(); if n-S.fpsT>=.5 then S.fps=math.floor(S.fc/(n-S.fpsT)); S.fc=0; S.fpsT=n end end)

-- Update functions
local function updateFast()
	local ping=getPing(); local e=tick()-S.start
	setText(UI.fpsLbl,"FPS "..S.fps); setText(UI.pingLbl,"PING "..ping.."ms")
	setText(UI.timeLbl,("%02d:%02d:%02d"):format(math.floor(e/3600),math.floor(e%3600/60),math.floor(e%60)))
	setCol(UI.pingLbl,ping<80 and C.OK or ping<150 and C.WRN or C.ERR)
	setText(UI.miniFps,"FPS "..S.fps); setText(UI.miniPing,ping.."ms")
	setText(UI.miniBeli,fmtV(getStat("Beli"),"Beli")); setText(UI.miniFrag,fmtV(getStat("Fragments"),"Fragments"))
	local hopStr=S.hop and (function() local sv=math.max(0,math.floor(S.hopCD)); local h=math.floor(sv/3600); sv=sv%3600; local m=math.floor(sv/60); sv=sv%60; return h>0 and("%d:%02d:%02d"):format(h,m,sv) or("%02d:%02d"):format(m,sv) end)() or "DISABLED"
	setText(UI.hopCD,hopStr); setCol(UI.hopCD,S.hop and C.HOP or C.DIM)
	local whStr=S.whTimer and (function() local sv=math.max(0,math.floor(S.whCD)); local h=math.floor(sv/3600); sv=sv%3600; local m=math.floor(sv/60); sv=sv%60; return h>0 and("%d:%02d:%02d next send"):format(h,m,sv) or("%02d:%02d next send"):format(m,sv) end)() or "DISABLED"
	setText(UI.whCD,whStr); setCol(UI.whCD,S.whTimer and C.WH or C.DIM)
	local pc=0; for _ in pairs(BM.data) do pc=pc+1 end
	setText(UI.bmCountLbl,BM.on and("Pulled: "..pc.." | Dist:"..BM.dist.." Y:"..BM.yOff) or "BringMobs: Off"); setCol(UI.bmCountLbl,BM.on and C.PULL or C.DIM)
end

local function updateStats()
	local ns=lp.DisplayName~=lp.Name and(lp.DisplayName.." (@"..lp.Name..")") or lp.Name
	setText(UI.charLbl,ns); setText(UI.miniName,ns)
	local lv=getStat("Level"); local lvS="LV. "..fmtV(lv,"Level")
	setText(UI.lvlLbl,lvS); setText(UI.miniLvl,lvS)
	setText(UI.beliLbl,fmtV(getStat("Beli"),"Beli")); setCol(UI.beliLbl,C.BELI)
	setText(UI.fragLbl,fmtV(getStat("Fragments"),"Fragments")); setCol(UI.fragLbl,C.FRAG)
	local cb=getStat("Beli"); local cf=getStat("Fragments")
	if not S.sessOK and cb and cf then S.sessB=cb; S.sessF=cf; S.sessOK=true end
	if S.sessOK then
		local gb=math.floor((cb or 0)-S.sessB); local gf=math.floor((cf or 0)-S.sessF)
		setText(UI.sessBLbl,(gb>=0 and "+" or "")..fmtV(gb,"Beli")); setCol(UI.sessBLbl,gb>=0 and C.BELI or C.ERR)
		setText(UI.sessFLbl,(gf>=0 and "+" or "")..fmtV(gf,"Fragments")); setCol(UI.sessFLbl,gf>=0 and C.FRAG or C.ERR)
	end
	local function doStat(vl,bar,key) local v=getStat(key); setText(vl,fmtV(v)); if bar then setBar(bar,tonumber(v) and tonumber(v)/K.COMBAT or 0) end end
	doStat(UI.meleeLbl,UI.meleeBar,"Melee"); doStat(UI.defLbl,UI.defBar,"Defense")
	doStat(UI.swordLbl,UI.swordBar,"Sword"); doStat(UI.gunLbl,UI.gunBar,"Gun")
	local fv=getStat("Blox Fruit"); setText(UI.fruitLbl,fmtV(fv)); if UI.fruitBar then setBar(UI.fruitBar,tonumber(fv) and tonumber(fv)/K.COMBAT or 0) end
	local rn,rt=getRace(lp); setText(UI.raceLbl,rn and(rn..(rt and" [V"..rt.."]" or "")) or "Not V4")
	setText(UI.teamLbl,lp.Team and lp.Team.Name or "N/A")
	local sp=getStat("SpawnPoint"); setText(UI.spawnLbl,sp~=nil and tostring(sp) or "??")
end

local function updateRates()
	local bPM2=calcRate(S.beliHist); local fPM2=calcRate(S.fragHist)
	local function rs(v) local sg=v>=0 and"+" or""; return math.abs(v)>=1e6 and sg..("%.1fM"):format(v/1e6) or math.abs(v)>=1e3 and sg..("%.1fK"):format(v/1e3) or sg..tostring(v) end
	setText(UI.bPMLbl,rs(bPM2)); setCol(UI.bPMLbl,bPM2>=0 and C.BELI or C.ERR)
	setText(UI.bHRLbl,rs(bPM2*60)); setCol(UI.bHRLbl,bPM2>=0 and C.BELI or C.ERR)
	setText(UI.fPMLbl,rs(fPM2)); setCol(UI.fPMLbl,fPM2>=0 and C.FRAG or C.ERR)
	setText(UI.fHRLbl,rs(fPM2*60)); setCol(UI.fHRLbl,fPM2>=0 and C.FRAG or C.ERR)
end

local function updateInv()
	local en,elv=getEquipped(); setText(UI.eqNameLbl,en)
	if elv~=nil then setText(UI.eqLvLbl,"LV "..fmtN(elv)); setCol(UI.eqLvLbl,C.WRN)
	else setText(UI.eqLvLbl,en~="None" and "No Level" or ""); setCol(UI.eqLvLbl,C.DIM) end
	local items=getInv()
	for i=1,20 do
		local pf=invRows[i]; local item=items[i]
		if item then
			pf.cell.Visible=true; setText(pf.nameLbl,item.name); setText(pf.lvlLbl,"LV "..math.floor(item.level))
			for _,key in ipairs(SKILL_KEYS) do pf.skillLbls[key].kl.Visible=false; pf.skillLbls[key].cl.Visible=false end
			local rl=getSkillLevels(item.name); local idx=0
			for _,key in ipairs(SKILL_KEYS) do local r=rl[key]; if r~=nil and item.level~=nil then
				local sl=pf.skillLbls[key]; sl.kl.Position=UDim2.new(0,8+idx*40,0,27); sl.cl.Position=UDim2.new(0,8+idx*40,0,38)
				sl.kl.Visible=true; sl.cl.Visible=true; setText(sl.cl,item.level>=r and "🟢" or "🔴"); setCol(sl.cl,item.level>=r and C.OK or C.ERR); idx=idx+1
			end end
		else pf.cell.Visible=false end
	end
end

local function updatePlayers()
	local list=Plrs:GetPlayers(); local total=#list; local ratio=math.clamp(total/K.MAX,0,1)
	setText(UI.pcLbl,total.." / "..K.MAX)
	local barCol=ratio>=1 and C.ERR or ratio>=.75 and C.WRN or C.WHT
	tw(UI.svrBar,{BackgroundColor3=barCol},.2); setCol(UI.pcLbl,barCol); setBar(UI.svrBar,ratio)
	local totalB=0; for _,p in ipairs(list) do local c=S.plrC[p.UserId]; if c and c.bounty then totalB=totalB+c.bounty else local bo=getStatObj(p,"Bounty"); if bo then totalB=totalB+(bo.Value or 0) end end end
	setText(UI.bountyLbl,fmtN(totalB))
	local myC=lp.Character; local myR=myC and myC:FindFirstChild("HumanoidRootPart"); local distC={}
	for _,p in ipairs(list) do if p~=lp then local d=math.huge; if myR then local th=p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if th then local ok,mag=pcall(function() return(myR.Position-th.Position).Magnitude end); if ok then d=mag end end end; distC[p.UserId]=d end end
	table.sort(list,function(a,b) if a==lp then return true end; if b==lp then return false end; return(distC[a.UserId] or math.huge)<(distC[b.UserId] or math.huge) end)
	for i=1,20 do
		local pf=plrRows[i]; local p=list[i]
		if p and pf then
			pf.row.Visible=true
			local ns=p.DisplayName~=p.Name and(p.DisplayName.." (@"..p.Name..")") or p.Name
			setText(pf.nameLbl,ns); setCol(pf.nameLbl,p==lp and C.OK or C.WHT)
			local plv=getStat("Level",p); setText(pf.lvlLbl,plv~=nil and("LV"..fmtV(plv,"Level")) or "LV??")
			if p~=lp then
				local cache=S.plrC[p.UserId] or {}
				setText(pf.raceLbl,cache.race and("Race: "..cache.race..(cache.raceTier and" V/T "..cache.raceTier or "")) or "Race: ?")
				setText(pf.spawnLbl,cache.spawn and("LOCATION: "..cache.spawn) or "LOCATION: ?")
				setText(pf.bountyLbl,cache.bounty~=nil and("Bounty: "..fmtN(cache.bounty)) or "Bounty: ?")
				local rd=distC[p.UserId] or math.huge
				setText(pf.distLbl,rd==math.huge and "?" or(fmtN(math.floor(rd*K.S2M)).."m"))
				setText(pf.timeLbl,serverT(cache.join))
			else
				setText(pf.raceLbl,""); setText(pf.spawnLbl,""); setText(pf.bountyLbl,"")
				setText(pf.distLbl,"YOU"); setCol(pf.distLbl,C.OK)
				setText(pf.timeLbl,serverT(S.plrC[lp.UserId] and S.plrC[lp.UserId].join))
			end
		elseif pf then pf.row.Visible=false end
	end
end

-- Player events
Plrs.PlayerAdded:Connect(function(p) task.wait(1); S.plrC[p.UserId]=S.plrC[p.UserId] or {}; S.plrC[p.UserId].join=tick(); watchPlr(p); showN(p.DisplayName~=p.Name and(p.DisplayName.." (@"..p.Name..")") or p.Name,"Joined",C.OK) end)
Plrs.PlayerRemoving:Connect(function(p) local uid=p.UserId; showN(p.DisplayName~=p.Name and(p.DisplayName.." (@"..p.Name..")") or p.Name,"Left",C.ERR); for _,t in ipairs({S.spawnW,S.raceW,S.bountyW,S.hidPlrC}) do if t[uid] then t[uid]:Disconnect(); t[uid]=nil end end; S.plrC[uid]=nil; S.statC[uid]=nil end)
for _,p in ipairs(Plrs:GetPlayers()) do if p~=lp then watchPlr(p) end end
lp.CharacterAdded:Connect(function(char)
	S.skillC={}; S.sessDeaths=S.sessDeaths+1; showN("Died 💀","Death #"..S.sessDeaths.." this session",C.ERR)
	if S.v2 then task.spawn(function() if not char:FindFirstChild("HumanoidRootPart") then char.ChildAdded:Wait() end end) end
	task.spawn(function()
		while not char:FindFirstChild("HumanoidRootPart") do task.wait(.1) end
		local hum=char:WaitForChild("Humanoid",10); if not hum then return end
		local bp; for _=1,20 do bp=lp:FindFirstChild("Backpack"); if bp and #bp:GetChildren()>0 then break end; task.wait(.3) end
		if not bp then return end; task.wait(.5)
		for _,tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") then
			pcall(function() hum:EquipTool(tool) end); task.wait(.15)
			S.skillC[tool.Name]=getSkillLevels(tool.Name)
			pcall(function() hum:UnequipTools() end); task.wait(.15)
		end end
	end)
end)

-- Init
if cfg.RemoveDeathEffect then
	local function rde() pcall(function() local r=game:GetService("ReplicatedStorage"); local d=r:WaitForChild("Effect",10):WaitForChild("Container",10):WaitForChild("Death",10); if d then d:Destroy() end end) end
	rde(); lp.CharacterAdded:Connect(function() task.wait(.5); rde() end)
end
if cfg.BoostV1 then task.spawn(function() task.wait(2); S.v1=true; setV1(true); tog(UI.v1Btn,true,C.V1,C.CARD,"Boost V1: On","Boost V1: Off") end) end
if cfg.BoostV2 then task.spawn(function() task.wait(2); S.v2=true; setV2(true); tog(UI.v2Btn,true,C.V2,C.CARD,"Boost V2: On","Boost V2: Off") end) end
if cfg.BoostV3 then task.spawn(function() task.wait(2); S.v3=true; setV3(true); tog(UI.v3Btn,true,C.V3,C.CARD,"Boost V3: On","Boost V3: Off") end) end
if cfg.HidePlayers then task.spawn(function() task.wait(1); toggleHidePlr(true) end) end
if cfg.HideEnemies  then task.spawn(function() task.wait(2); toggleHidEnm(true) end) end
if cfg.AutoHop      then task.spawn(function() task.wait(6); startHop() end) end
if cfg.WebhookEnabled then S.wh=true; tog(UI.whBtn,true,C.WH,C.CARD,"Webhook: On","Webhook: Off") end
if cfg.LockFps.on then pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate=cfg.LockFps.fps end); pcall(function() setfpscap(cfg.LockFps.fps) end) end

-- Preload skills on spawn
task.spawn(function()
	if not lp.Character then lp.CharacterAdded:Wait() end
	local char=lp.Character
	while not char:FindFirstChild("HumanoidRootPart") do task.wait(.1) end
	local bp=lp:WaitForChild("Backpack",10); if not bp then return end
	local hum=char:WaitForChild("Humanoid",10); if not hum then return end
	task.wait(1)
	for _,tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") then
		pcall(function() hum:EquipTool(tool) end); task.wait(1)
		S.skillC[tool.Name]=getSkillLevels(tool.Name)
		pcall(function() hum:UnequipTools() end); task.wait(.2)
	end end
end)

-- Main loops
task.spawn(function() while true do updateFast(); task.wait(.05) end end)
task.spawn(function() task.wait(.3); updateStats(); updateInv(); while true do task.wait(.2); updateStats(); updateInv() end end)
task.spawn(function() task.wait(.5); updatePlayers(); while true do task.wait(.3); updatePlayers() end end)
task.spawn(function() task.wait(2); while true do pushH(S.beliHist,getStat("Beli")); pushH(S.fragHist,getStat("Fragments")); task.wait(K.HINT) end end)
task.spawn(function() task.wait(12); while true do updateRates(); task.wait(5) end end)

print("[Panel] Loaded OK")

-- Close loading GUI
_closeLoader()
