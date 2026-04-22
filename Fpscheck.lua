local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

-- ลบ HUD เก่าทิ้งก่อน
for _, v in ipairs(lp:WaitForChild("PlayerGui"):GetChildren()) do
	if v.Name == "PerfHUD" or v.Name == "BloxHUD" then v:Destroy() end
end

-- ===================================================
-- FPS CAP
-- ===================================================

local FPS_CAP = 60          -- เปลี่ยนตัวเลขนี้ได้เลย (30 / 60 / 144 / 0 = ไม่จำกัด)
local _lastFrame = tick()

if FPS_CAP and FPS_CAP > 0 then
	local frameTime = 1 / FPS_CAP
	RunService:BindToRenderStep("FpsCap", Enum.RenderPriority.First.Value + 1, function()
		local now = tick()
		local delta = now - _lastFrame
		if delta < frameTime then
			-- busy-wait แทน task.wait เพราะ task.wait ใน RenderStep ทำไม่ได้
			-- ใช้ os.clock loop สั้น ๆ เพื่อ block frame ถัดไป
			local waitUntil = _lastFrame + frameTime
			while tick() < waitUntil do end
		end
		_lastFrame = tick()
	end)
end

-- ===================================================
-- HELPERS
-- ===================================================

local function addCommas(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local NO_SHORT = { Beli = true, Fragments = true, Level = true }
local function fmt(v, key)
	if type(v) ~= "number" then return tostring(v or "?") end
	if NO_SHORT[key] then return addCommas(v) end
	if     v >= 1e6 then return string.format("%.1fM", v/1e6)
	elseif v >= 1e3 then return string.format("%.1fK", v/1e3)
	else return tostring(math.floor(v)) end
end

local function parseNum(str)
	if not str then return nil end
	local s = str:gsub(",",""):gsub("%s+","")
	local a, suf = s:match("([%d%.]+)([MmKk])")
	if a then
		local n = tonumber(a) or 0
		if suf:lower()=="m" then return math.floor(n*1e6) end
		if suf:lower()=="k" then return math.floor(n*1e3) end
	end
	local p = s:match("(%d+)")
	return p and tonumber(p) or nil
end

local function parseExpBar(str)
	if not str then return nil,nil end
	local s = str:gsub(",","")
	local cur,max = s:match("(%d+)/(%d+)")
	return cur and tonumber(cur) or nil, max and tonumber(max) or nil
end

local function parseBeli(raw)
	if not raw then return nil end
	local result
	for line in raw:gmatch("[^\n]+") do
		local s = line:match("^%s*(.-)%s*$")
		if s:find("^%$") or s:lower():find("beli") then
			local n = parseNum(s)
			if n and n>0 then result=n end
		end
	end
	if not result and raw:find("%$") then
		local n = raw:gsub(",",""):match("%$%s*(%d+)")
		if n then result=tonumber(n) end
	end
	return result
end

local function parseQuestExp(raw)
	if not raw then return nil end
	for line in raw:gmatch("[^\n]+") do
		local s = line:match("^%s*(.-)%s*$")
		if s:lower():find("exp") or s:lower():find("xp") then
			local n = parseNum(s)
			if n and n>0 then return n end
		end
	end
	return nil
end

-- ===================================================
-- PERF HUD (FPS / PING / TIME)
-- ===================================================

local perfGui = Instance.new("ScreenGui")
perfGui.Name = "PerfHUD"
perfGui.ResetOnSpawn = false
perfGui.IgnoreGuiInset = true
perfGui.Parent = lp:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.Size        = UDim2.new(0, 340, 0, 54)   -- กว้างขึ้นเพื่อรองรับ FPS Cap
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position    = UDim2.new(0.5, 0, 0, 150)
card.BackgroundColor3    = Color3.fromRGB(14,14,24)
card.BackgroundTransparency = 0.35
card.BorderSizePixel = 0
card.Parent    = perfGui
Instance.new("UICorner", card).CornerRadius = UDim.new(1,0)
local cStroke = Instance.new("UIStroke", card)
cStroke.Color=Color3.fromRGB(255,255,255); cStroke.Thickness=1; cStroke.Transparency=0.82

local function makeSep(x)
	local f = Instance.new("Frame", card)
	f.Size=UDim2.new(0,1,0,26); f.Position=UDim2.new(0,x,0.5,-13)
	f.BackgroundColor3=Color3.fromRGB(255,255,255)
	f.BackgroundTransparency=0.8; f.BorderSizePixel=0
end
makeSep(84); makeSep(168); makeSep(252)

local function makeSection(tag, cx)
	local tl = Instance.new("TextLabel", card)
	tl.Size=UDim2.new(0,80,0,16); tl.Position=UDim2.new(0,cx-40,0,7)
	tl.BackgroundTransparency=1; tl.Text=tag
	tl.TextColor3=Color3.fromRGB(180,180,200); tl.TextSize=10
	tl.Font=Enum.Font.GothamBold; tl.TextXAlignment=Enum.TextXAlignment.Center
	tl.TextStrokeTransparency=0.6; tl.TextStrokeColor3=Color3.new(0,0,0)
	local vl = Instance.new("TextLabel", card)
	vl.Size=UDim2.new(0,80,0,26); vl.Position=UDim2.new(0,cx-40,0,22)
	vl.BackgroundTransparency=1; vl.Text="---"; vl.TextSize=18
	vl.Font=Enum.Font.GothamBold; vl.TextXAlignment=Enum.TextXAlignment.Center
	vl.TextStrokeTransparency=0.5; vl.TextStrokeColor3=Color3.new(0,0,0)
	return vl
end

local lblFps    = makeSection("FPS",    42)
local lblPing   = makeSection("PING",  126)
local lblTime   = makeSection("TIME",  210)
local lblCapLbl = makeSection("CAP",   294)   -- ส่วนแสดง FPS Cap

lblFps.TextColor3    = Color3.fromRGB(74,222,128)
lblPing.TextColor3   = Color3.fromRGB(250,200,40)
lblTime.TextColor3   = Color3.fromRGB(192,132,252)
lblCapLbl.TextColor3 = Color3.fromRGB(100,200,255)
lblCapLbl.Text       = (FPS_CAP and FPS_CAP > 0) and tostring(FPS_CAP) or "OFF"

-- ปุ่มปรับ FPS Cap (+/-)
local capValues = {30, 60, 90, 120, 144, 0}   -- 0 = unlimited
local capIdx = 2   -- เริ่มที่ 60

local function updateCapDisplay()
	local v = capValues[capIdx]
	lblCapLbl.Text = (v > 0) and tostring(v) or "∞"
	FPS_CAP = v
	if v > 0 then
		-- อัปเดต frameTime ใหม่
		RunService:UnbindFromRenderStep("FpsCap")
		local ft = 1/v
		RunService:BindToRenderStep("FpsCap", Enum.RenderPriority.First.Value + 1, function()
			local now = tick()
			if now - _lastFrame < ft then
				local wu = _lastFrame + ft
				while tick() < wu do end
			end
			_lastFrame = tick()
		end)
	else
		RunService:UnbindFromRenderStep("FpsCap")
	end
end

local capDownBtn = Instance.new("TextButton", card)
capDownBtn.Size=UDim2.new(0,14,0,14); capDownBtn.Position=UDim2.new(0,255,0.5,-7)
capDownBtn.BackgroundColor3=Color3.fromRGB(30,30,50); capDownBtn.BorderSizePixel=0
capDownBtn.Text="◀"; capDownBtn.TextSize=8; capDownBtn.Font=Enum.Font.GothamBold
capDownBtn.TextColor3=Color3.fromRGB(160,180,255); capDownBtn.AutoButtonColor=false
Instance.new("UICorner",capDownBtn).CornerRadius=UDim.new(0,3)
capDownBtn.MouseButton1Click:Connect(function()
	capIdx = (capIdx - 2) % #capValues + 1
	updateCapDisplay()
end)

local capUpBtn = Instance.new("TextButton", card)
capUpBtn.Size=UDim2.new(0,14,0,14); capUpBtn.Position=UDim2.new(0,324,0.5,-7)
capUpBtn.BackgroundColor3=Color3.fromRGB(30,30,50); capUpBtn.BorderSizePixel=0
capUpBtn.Text="▶"; capUpBtn.TextSize=8; capUpBtn.Font=Enum.Font.GothamBold
capUpBtn.TextColor3=Color3.fromRGB(160,180,255); capUpBtn.AutoButtonColor=false
Instance.new("UICorner",capUpBtn).CornerRadius=UDim.new(0,3)
capUpBtn.MouseButton1Click:Connect(function()
	capIdx = capIdx % #capValues + 1
	updateCapDisplay()
end)

local startTime = tick()
RunService.Heartbeat:Connect(function()
	local e = math.floor(tick()-startTime)
	if e>=3600 then
		lblTime.Text=string.format("%d:%02d:%02d",math.floor(e/3600),math.floor((e%3600)/60),e%60)
	else
		lblTime.Text=string.format("%02d:%02d",math.floor(e/60),e%60)
	end
end)

local frameCount,lastTick2 = 0,tick()
RunService.RenderStepped:Connect(function()
	frameCount+=1
	local now=tick()
	if now-lastTick2>=0.5 then
		local fps=math.floor(frameCount/(now-lastTick2))
		frameCount=0; lastTick2=now
		local c = fps>=60 and Color3.fromRGB(74,222,128)
			or fps>=30 and Color3.fromRGB(250,200,40)
			or Color3.fromRGB(255,70,70)
		lblFps.Text=tostring(fps); lblFps.TextColor3=c
	end
end)

RunService.Heartbeat:Connect(function()
	local ok,ping = pcall(function() return math.floor(lp:GetNetworkPing()*1000) end)
	if not ok then return end
	ping=math.max(0,ping)
	local c = ping<=80  and Color3.fromRGB(74,222,128)
		or ping<=200 and Color3.fromRGB(250,200,40)
		or Color3.fromRGB(255,70,70)
	lblPing.Text=tostring(ping).." ms"; lblPing.TextColor3=c
end)

-- ===================================================
-- MAIN HUD — ติดขวามือ
-- ===================================================

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "BloxHUD"
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.Parent = lp:WaitForChild("PlayerGui")

local CARD_W = 260
local FULL_H = 440
local MINI_H = 56

local pc = Instance.new("Frame")
pc.Size        = UDim2.new(0, CARD_W, 0, FULL_H)
pc.AnchorPoint = Vector2.new(1, 0)
pc.Position    = UDim2.new(1, -12, 0, 175)
pc.BackgroundColor3    = Color3.fromRGB(10,10,18)
pc.BackgroundTransparency = 0.15
pc.BorderSizePixel = 0
pc.ClipsDescendants = true
pc.Parent = mainGui
Instance.new("UICorner", pc).CornerRadius = UDim.new(0,10)
local pcSt = Instance.new("UIStroke", pc)
pcSt.Color=Color3.fromRGB(255,255,255); pcSt.Thickness=0.8; pcSt.Transparency=0.85

local miniBar = Instance.new("Frame", pc)
miniBar.Size=UDim2.new(1,0,0,MINI_H); miniBar.Position=UDim2.new(0,0,0,0)
miniBar.BackgroundColor3=Color3.fromRGB(10,10,18); miniBar.BackgroundTransparency=0.15
miniBar.BorderSizePixel=0; miniBar.Visible=false
Instance.new("UICorner", miniBar).CornerRadius=UDim.new(0,10)
local miniSt = Instance.new("UIStroke", miniBar)
miniSt.Color=Color3.fromRGB(255,255,255); miniSt.Thickness=0.8; miniSt.Transparency=0.85

local function mkLabel(parent,txt,ts,tc,font,xa,sz,pos)
	local l = Instance.new("TextLabel", parent)
	l.Size=sz; l.Position=pos; l.BackgroundTransparency=1
	l.Text=txt; l.TextColor3=tc; l.TextSize=ts
	l.Font=font or Enum.Font.Gotham
	l.TextXAlignment=xa or Enum.TextXAlignment.Left
	l.TextStrokeTransparency=0.4; l.TextStrokeColor3=Color3.new(0,0,0)
	return l
end

local miniName  = mkLabel(miniBar,"",13,Color3.fromRGB(255,255,255),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-48,0,16),UDim2.new(0,10,0,8))
local miniQuest = mkLabel(miniBar,"",10,Color3.fromRGB(200,200,220),Enum.Font.Gotham,
	Enum.TextXAlignment.Left,UDim2.new(1,-48,0,14),UDim2.new(0,10,0,28))

local isMin = false
local minBtn = Instance.new("TextButton", pc)
minBtn.Size=UDim2.new(0,26,0,18); minBtn.Position=UDim2.new(1,-32,0,14)
minBtn.BackgroundColor3=Color3.fromRGB(30,30,48); minBtn.BorderSizePixel=0
minBtn.Text="▲"; minBtn.TextColor3=Color3.fromRGB(160,160,200)
minBtn.TextSize=9; minBtn.Font=Enum.Font.GothamBold; minBtn.AutoButtonColor=false
Instance.new("UICorner", minBtn).CornerRadius=UDim.new(0,4)
local minBtnSt=Instance.new("UIStroke",minBtn)
minBtnSt.Color=Color3.fromRGB(255,255,255); minBtnSt.Thickness=0.6; minBtnSt.Transparency=0.8

local body = Instance.new("Frame", pc)
body.Size=UDim2.new(1,0,0,FULL_H); body.Position=UDim2.new(0,0,0,0)
body.BackgroundTransparency=1; body.BorderSizePixel=0

local function applyMin()
	if isMin then
		pc.Size=UDim2.new(0,CARD_W,0,MINI_H)
		pc.BackgroundTransparency=1; pcSt.Transparency=1
		body.Visible=false; miniBar.Visible=true
		minBtn.Text="▼"; minBtn.Position=UDim2.new(1,-32,0,19)
	else
		pc.Size=UDim2.new(0,CARD_W,0,FULL_H)
		pc.BackgroundTransparency=0.15; pcSt.Transparency=0.85
		body.Visible=true; miniBar.Visible=false
		minBtn.Text="▲"; minBtn.Position=UDim2.new(1,-32,0,14)
	end
end
minBtn.MouseButton1Click:Connect(function() isMin=not isMin; applyMin() end)

-- ===================================================
-- BODY HELPERS
-- ===================================================

local function bFrame(sz,pos,bg,bgT,r)
	local f=Instance.new("Frame",body)
	f.Size=sz; f.Position=pos
	f.BackgroundColor3=bg or Color3.fromRGB(10,10,18)
	f.BackgroundTransparency=bgT or 0; f.BorderSizePixel=0
	if r then Instance.new("UICorner",f).CornerRadius=r end
	return f
end
local function bLabel(txt,ts,tc,font,xa,sz,pos)
	local l=Instance.new("TextLabel",body)
	l.Size=sz; l.Position=pos; l.BackgroundTransparency=1
	l.Text=txt; l.TextColor3=tc; l.TextSize=ts
	l.Font=font or Enum.Font.Gotham
	l.TextXAlignment=xa or Enum.TextXAlignment.Left
	l.TextStrokeTransparency=0.4; l.TextStrokeColor3=Color3.new(0,0,0)
	return l
end
local function bDiv(y)
	local d=Instance.new("Frame",body)
	d.Size=UDim2.new(1,-16,0,1); d.Position=UDim2.new(0,8,0,y)
	d.BackgroundColor3=Color3.fromRGB(255,255,255)
	d.BackgroundTransparency=0.88; d.BorderSizePixel=0
end

-- avatar
local avFrame=bFrame(UDim2.new(0,50,0,50),UDim2.new(0,10,0,10),Color3.fromRGB(30,30,45),0,UDim.new(1,0))
local avSt=Instance.new("UIStroke",avFrame)
avSt.Color=Color3.fromRGB(192,132,252); avSt.Thickness=1.5; avSt.Transparency=0.2
local avImg=Instance.new("ImageLabel",avFrame)
avImg.Size=UDim2.new(1,0,1,0); avImg.BackgroundTransparency=1; avImg.BorderSizePixel=0
Instance.new("UICorner",avImg).CornerRadius=UDim.new(1,0)
local okT,th=pcall(function()
	return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
end)
if okT then avImg.Image=th end

bLabel(lp.DisplayName,15,Color3.fromRGB(255,255,255),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(0,150,0,18),UDim2.new(0,66,0,10))
bLabel("@"..lp.Name,10,Color3.fromRGB(180,180,210),Enum.Font.Gotham,
	Enum.TextXAlignment.Left,UDim2.new(0,150,0,14),UDim2.new(0,66,0,30))
bDiv(68)

local INFO = {
	{tag="LEVEL",    key="Level",    color=Color3.fromRGB(255,215,60)},
	{tag="BELI",     key="Beli",     color=Color3.fromRGB(80,235,140)},
	{tag="FRAGMENTS",key="Fragments",color=Color3.fromRGB(200,130,255)},
	{tag="RACE",     key="Race",     color=Color3.fromRGB(210,150,255)},
}
local infoLabels = {}
for i,s in ipairs(INFO) do
	local col=(i==1 or i==3) and 0 or 1; local row=(i<=2) and 0 or 1
	local x=10+col*122; local y=76+row*28
	bLabel(s.tag,9,Color3.fromRGB(180,180,210),Enum.Font.GothamBold,
		Enum.TextXAlignment.Left,UDim2.new(0,114,0,11),UDim2.new(0,x,0,y))
	infoLabels[s.key]=bLabel("...",14,s.color,Enum.Font.GothamBold,
		Enum.TextXAlignment.Left,UDim2.new(0,114,0,15),UDim2.new(0,x,0,y+12))
end
local vSep=Instance.new("Frame",body)
vSep.Size=UDim2.new(0,1,0,52); vSep.Position=UDim2.new(0,126,0,74)
vSep.BackgroundColor3=Color3.fromRGB(255,255,255); vSep.BackgroundTransparency=0.88; vSep.BorderSizePixel=0
bDiv(136)

bLabel("COMBAT STATS",10,Color3.fromRGB(200,200,230),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-16,0,12),UDim2.new(0,10,0,142))
local COMBAT = {
	{tag="Melee",      icon="👊",color=Color3.fromRGB(255,175,90)},
	{tag="Defense",    icon="🛡", color=Color3.fromRGB(120,190,255)},
	{tag="Sword",      icon="⚔", color=Color3.fromRGB(225,190,255)},
	{tag="Gun",        icon="🔫",color=Color3.fromRGB(90,235,150)},
	{tag="Demon Fruit",icon="🍎",color=Color3.fromRGB(255,120,150)},
}
local combatLabels = {}
for i,s in ipairs(COMBAT) do
	local y=158+(i-1)*22
	local ico=Instance.new("TextLabel",body)
	ico.Size=UDim2.new(0,20,0,20); ico.Position=UDim2.new(0,8,0,y)
	ico.BackgroundTransparency=1; ico.Text=s.icon; ico.TextSize=14
	ico.Font=Enum.Font.Gotham; ico.TextXAlignment=Enum.TextXAlignment.Center; ico.TextStrokeTransparency=1
	bLabel(s.tag,12,Color3.fromRGB(220,220,240),Enum.Font.GothamBold,
		Enum.TextXAlignment.Left,UDim2.new(0,100,0,20),UDim2.new(0,30,0,y))
	local barBg=bFrame(UDim2.new(0,95,0,4),UDim2.new(0,30,0,y+17),Color3.fromRGB(50,50,70),0,UDim.new(1,0))
	local barFill=Instance.new("Frame",barBg)
	barFill.Size=UDim2.new(0,0,1,0); barFill.BackgroundColor3=s.color; barFill.BorderSizePixel=0
	Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)
	local vl=bLabel("...",12,s.color,Enum.Font.GothamBold,
		Enum.TextXAlignment.Right,UDim2.new(0,50,0,20),UDim2.new(0,200,0,y))
	combatLabels[s.tag]={label=vl,bar=barFill}
end

local QY=278
bDiv(QY)
bLabel("📋  QUEST",10,Color3.fromRGB(255,200,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(0,120,0,16),UDim2.new(0,8,0,QY+10))
bDiv(QY+30)
bLabel("QUEST NAME",9,Color3.fromRGB(160,160,190),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-16,0,11),UDim2.new(0,8,0,QY+38))

local qTitle=Instance.new("TextLabel",body)
qTitle.Size=UDim2.new(1,-16,0,26); qTitle.Position=UDim2.new(0,8,0,QY+50)
qTitle.BackgroundTransparency=1; qTitle.Text="No active quest"
qTitle.TextColor3=Color3.fromRGB(160,160,190); qTitle.TextSize=13
qTitle.Font=Enum.Font.GothamBold; qTitle.TextXAlignment=Enum.TextXAlignment.Left
qTitle.TextWrapped=true; qTitle.TextStrokeTransparency=0.4; qTitle.TextStrokeColor3=Color3.new(0,0,0)

bDiv(QY+80)
bLabel("REWARD",9,Color3.fromRGB(160,160,190),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-16,0,11),UDim2.new(0,8,0,QY+90))
bLabel("⚡",13,Color3.fromRGB(255,255,255),Enum.Font.Gotham,
	Enum.TextXAlignment.Center,UDim2.new(0,18,0,16),UDim2.new(0,8,0,QY+104))
local qExp1=bLabel("---",11,Color3.fromRGB(74,222,128),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-32,0,16),UDim2.new(0,28,0,QY+104))
bLabel("⚡×2",11,Color3.fromRGB(255,215,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Center,UDim2.new(0,28,0,16),UDim2.new(0,8,0,QY+122))
local qExp2=bLabel("---",11,Color3.fromRGB(255,215,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-40,0,16),UDim2.new(0,38,0,QY+122))

local expBg=bFrame(UDim2.new(1,-16,0,4),UDim2.new(0,8,0,QY+140),Color3.fromRGB(40,40,60),0,UDim.new(1,0))
local expCur=Instance.new("Frame",expBg)
expCur.Size=UDim2.new(0,0,1,0); expCur.BackgroundColor3=Color3.fromRGB(74,222,128); expCur.BorderSizePixel=0
Instance.new("UICorner",expCur).CornerRadius=UDim.new(1,0)
local expAdd=Instance.new("Frame",expBg)
expAdd.Size=UDim2.new(0,0,1,0); expAdd.BackgroundColor3=Color3.fromRGB(255,215,60)
expAdd.BackgroundTransparency=0.4; expAdd.BorderSizePixel=0
Instance.new("UICorner",expAdd).CornerRadius=UDim.new(1,0)
bDiv(QY+148)

bLabel("💰",13,Color3.fromRGB(255,255,255),Enum.Font.Gotham,
	Enum.TextXAlignment.Center,UDim2.new(0,18,0,16),UDim2.new(0,8,0,QY+156))
local qBeli1=bLabel("---",11,Color3.fromRGB(80,235,140),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-32,0,16),UDim2.new(0,28,0,QY+156))
bLabel("💰×2",11,Color3.fromRGB(255,200,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Center,UDim2.new(0,28,0,16),UDim2.new(0,8,0,QY+174))
local qBeli2=bLabel("---",11,Color3.fromRGB(255,200,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-40,0,16),UDim2.new(0,38,0,QY+174))

-- ===================================================
-- SELF HIGHLIGHT — เปิดอัตโนมัติ ไม่มี toggle
-- ===================================================

local SELF_FILL    = Color3.fromRGB(60, 220, 120)
local SELF_OUTLINE = Color3.fromRGB(140, 255, 180)

local selfHL = nil

local function safeDestroy(inst)
	if inst and inst.Parent then pcall(inst.Destroy, inst) end
end

local function applySelfHighlight(char)
	safeDestroy(selfHL); selfHL = nil
	char = char or lp.Character
	if not char then return end

	local hl = Instance.new("Highlight")
	hl.Name              = "ESP_SelfHL"
	hl.FillColor         = SELF_FILL
	hl.OutlineColor      = SELF_OUTLINE
	hl.FillTransparency  = 0.65
	hl.OutlineTransparency = 0
	hl.DepthMode         = Enum.HighlightDepthMode.Occluded
	hl.Adornee           = char
	hl.Parent            = char
	selfHL = hl
end

-- เปิดทันทีเมื่อ script รัน
if lp.Character then
	task.delay(0.5, function() applySelfHighlight(lp.Character) end)
end

-- รีเซ็ตเมื่อ respawn
lp.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	applySelfHighlight(char)
end)

-- ===================================================
-- DATA UPDATER
-- ===================================================

local MAX_STAT = 2550

local function updateData()
	local data=lp:FindFirstChild("Data")
	if not data then return end
	for _,k in ipairs({"Level","Beli","Fragments","Race"}) do
		local node=data:FindFirstChild(k)
		if node and infoLabels[k] then infoLabels[k].Text=fmt(node.Value,k) end
	end
	local lvNode=data:FindFirstChild("Level")
	if lvNode then
		miniName.Text=lp.DisplayName.."  |  Lv. "..addCommas(lvNode.Value or 0)
	end
	local stats=data:FindFirstChild("Stats")
	if not stats then return end
	for _,s in ipairs(COMBAT) do
		local node=stats:FindFirstChild(s.tag)
		if node then
			local lvN=node:FindFirstChild("Level")
			if lvN and combatLabels[s.tag] then
				local v=lvN.Value or 0
				combatLabels[s.tag].label.Text=tostring(v)
				combatLabels[s.tag].bar.Size=UDim2.new(math.clamp(v/MAX_STAT,0,1),0,1,0)
			end
		end
	end
end

task.spawn(function()
	local data=lp:WaitForChild("Data",10)
	if not data then return end
	updateData()
	local function watch(obj) if obj then obj.Changed:Connect(updateData) end end
	for _,k in ipairs({"Level","Beli","Fragments","Race"}) do watch(data:WaitForChild(k,5)) end
	local stats=data:WaitForChild("Stats",5)
	if stats then
		for _,s in ipairs(COMBAT) do
			local node=stats:WaitForChild(s.tag,5)
			if node then watch(node:WaitForChild("Level",5)) end
		end
	end
end)

-- ===================================================
-- QUEST UPDATER
-- ===================================================

local function updateQuest()
	local active,rawTitle,rawReward=false,"",""
	pcall(function()
		local qf=lp.PlayerGui.Main.Quest
		active=qf.Visible
		if active then
			rawTitle  = qf.Container.QuestTitle.Title.ContentText  or ""
			rawReward = qf.Container.QuestReward.Title.ContentText or ""
		end
	end)

	if not active or rawTitle=="" then
		miniQuest.Text="No active quest"
		qTitle.Text="No active quest"; qTitle.TextColor3=Color3.fromRGB(160,160,190)
		qExp1.Text="---"; qExp2.Text="---"; qBeli1.Text="---"; qBeli2.Text="---"
		expCur.Size=UDim2.new(0,0,1,0); expAdd.Size=UDim2.new(0,0,1,0)
		expCur.BackgroundColor3=Color3.fromRGB(74,222,128)
		return
	end

	qTitle.Text=rawTitle; qTitle.TextColor3=Color3.fromRGB(255,255,255)

	local curExp,needExp
	pcall(function() curExp,needExp=parseExpBar(lp.PlayerGui.Main.Level.Exp.ContentText) end)
	local curLv,curBeli=0,0
	pcall(function() curLv  =lp.Data.Level.Value or 0 end)
	pcall(function() curBeli=lp.Data.Beli.Value  or 0 end)

	local baseExp=parseQuestExp(rawReward)
	if baseExp and curExp and needExp and needExp>0 then
		local e1,e2=baseExp,baseExp*2
		local a1,a2=curExp+e1,curExp+e2
		local pctCur=math.clamp(curExp/needExp,0,1)
		local pctAfter=math.clamp(a1/needExp,0,1)
		expCur.Size=UDim2.new(pctCur,0,1,0)
		expAdd.Size=UDim2.new(pctAfter-pctCur,0,1,0)
		expAdd.Position=UDim2.new(pctCur,0,0,0)
		if a1>=needExp then
			qExp1.Text=string.format("+%s  LevelUP!  Lv.%d → Lv.%d",addCommas(e1),curLv,curLv+1)
			qExp1.TextColor3=Color3.fromRGB(255,215,60)
			expCur.BackgroundColor3=Color3.fromRGB(255,215,60)
		else
			local need1=math.ceil((needExp-a1)/e1)
			qExp1.Text=string.format("+%s  →  %s / %s  (%d left)",addCommas(e1),addCommas(a1),addCommas(needExp),need1)
			qExp1.TextColor3=Color3.fromRGB(74,222,128)
			expCur.BackgroundColor3=Color3.fromRGB(74,222,128)
		end
		if a2>=needExp then
			qExp2.Text=string.format("+%s  LevelUP!  Lv.%d → Lv.%d",addCommas(e2),curLv,curLv+1)
		else
			local need2=math.ceil((needExp-a2)/e2)
			qExp2.Text=string.format("+%s  →  %s / %s  (%d left)",addCommas(e2),addCommas(a2),addCommas(needExp),need2)
		end
		qExp2.TextColor3=Color3.fromRGB(255,215,60)
		miniQuest.Text=rawTitle..string.format("  |  EXP %d%%",math.min(math.floor((a1/needExp)*100),100))
	else
		local expLine="---"
		for line in rawReward:gmatch("[^\n]+") do
			local s=line:match("^%s*(.-)%s*$")
			if s:lower():find("exp") or s:lower():find("xp") then expLine=s; break end
		end
		qExp1.Text=expLine; qExp1.TextColor3=Color3.fromRGB(160,160,190)
		qExp2.Text="---";   qExp2.TextColor3=Color3.fromRGB(160,160,190)
		expCur.Size=UDim2.new(0,0,1,0); expAdd.Size=UDim2.new(0,0,1,0)
	end

	local baseBeli=parseBeli(rawReward)
	if baseBeli then
		qBeli1.Text=string.format("+%s  →  %s",addCommas(baseBeli),addCommas(curBeli+baseBeli))
		qBeli1.TextColor3=Color3.fromRGB(80,235,140)
		qBeli2.Text=string.format("+%s  →  %s",addCommas(baseBeli*2),addCommas(curBeli+baseBeli*2))
		qBeli2.TextColor3=Color3.fromRGB(255,200,60)
	else
		qBeli1.Text="---"; qBeli1.TextColor3=Color3.fromRGB(160,160,190)
		qBeli2.Text="---"; qBeli2.TextColor3=Color3.fromRGB(160,160,190)
	end
end

task.spawn(function()
	while true do pcall(updateQuest); task.wait(1) end
end)
