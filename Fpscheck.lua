local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenSvc   = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local lp         = Players.LocalPlayer

for _, v in ipairs(lp:WaitForChild("PlayerGui"):GetChildren()) do
	if v.Name == "PerfHUD" or v.Name == "BloxHUD" or v.Name == "BlackoutGui" then v:Destroy() end
end

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local FPS_CAP    = 60
local _lastFrame = tick()

local function applyFpsCap(cap)
	RunService:UnbindFromRenderStep("FpsCap")
	FPS_CAP = cap
	if cap and cap > 0 then
		local ft = 1 / cap
		RunService:BindToRenderStep("FpsCap", Enum.RenderPriority.First.Value + 1, function()
			local now = tick()
			if now - _lastFrame < ft then
				local wu = _lastFrame + ft
				while tick() < wu do end
			end
			_lastFrame = tick()
		end)
	end
end
applyFpsCap(FPS_CAP)

local blackoutGui = Instance.new("ScreenGui")
blackoutGui.Name           = "BlackoutGui"
blackoutGui.ResetOnSpawn   = false
blackoutGui.IgnoreGuiInset = true
blackoutGui.DisplayOrder   = 999
blackoutGui.Parent         = lp:WaitForChild("PlayerGui")

local blackFrame = Instance.new("Frame", blackoutGui)
blackFrame.Size                   = UDim2.new(1,0,1,0)
blackFrame.BackgroundColor3       = Color3.new(0,0,0)
blackFrame.BackgroundTransparency = 1
blackFrame.BorderSizePixel        = 0
blackFrame.ZIndex                 = 10
blackFrame.Visible                = false

local blackHint = Instance.new("TextLabel", blackFrame)
blackHint.Size               = UDim2.new(0.8,0,0,40)
blackHint.AnchorPoint        = Vector2.new(0.5,0.5)
blackHint.Position           = UDim2.new(0.5,0,0.5,0)
blackHint.BackgroundTransparency = 1
blackHint.Text               = isMobile
	and "Black Screen  —  แตะปุ่ม Restore เพื่อเปิดจอ"
	or  "Black Screen  —  กด [B] หรือแตะปุ่ม Restore เพื่อเปิดจอ"
blackHint.TextColor3         = Color3.fromRGB(90,90,110)
blackHint.TextSize           = isMobile and 16 or 14
blackHint.Font               = Enum.Font.GothamBold
blackHint.TextXAlignment     = Enum.TextXAlignment.Center
blackHint.TextWrapped        = true
blackHint.ZIndex             = 11

local wakeBtn = Instance.new("TextButton", blackoutGui)
wakeBtn.Size         = UDim2.new(0, isMobile and 120 or 100, 0, isMobile and 50 or 40)
wakeBtn.AnchorPoint  = Vector2.new(0.5,1)
wakeBtn.Position     = UDim2.new(0.5,0,1,-30)
wakeBtn.BackgroundColor3 = Color3.fromRGB(30,30,50)
wakeBtn.BorderSizePixel  = 0
wakeBtn.Text         = "Restore"
wakeBtn.TextColor3   = Color3.fromRGB(255,230,80)
wakeBtn.TextSize     = isMobile and 16 or 14
wakeBtn.Font         = Enum.Font.GothamBold
wakeBtn.AutoButtonColor = false
wakeBtn.Visible      = false
wakeBtn.ZIndex       = 20
Instance.new("UICorner", wakeBtn).CornerRadius = UDim.new(0,8)
local wakeSt = Instance.new("UIStroke", wakeBtn)
wakeSt.Color=Color3.fromRGB(255,220,60); wakeSt.Thickness=1.2; wakeSt.Transparency=0.3

local blackoutOn = false

local function setBlackout(state)
	blackoutOn = state
	if state then
		blackFrame.Visible = true
		wakeBtn.Visible    = true
		blackFrame.BackgroundTransparency = 1
		TweenSvc:Create(blackFrame, TweenInfo.new(0.4,Enum.EasingStyle.Quad), {BackgroundTransparency=0}):Play()
	else
		wakeBtn.Visible    = false
		blackFrame.BackgroundTransparency = 1
		blackFrame.Visible = false
	end
end

wakeBtn.MouseButton1Click:Connect(function() setBlackout(false) end)

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.B then setBlackout(not blackoutOn) end
end)

local function addCommas(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end
local NO_SHORT={Beli=true,Fragments=true,Level=true}
local function fmt(v,key)
	if type(v)~="number" then return tostring(v or "?") end
	if NO_SHORT[key] then return addCommas(v) end
	if v>=1e6 then return string.format("%.1fM",v/1e6)
	elseif v>=1e3 then return string.format("%.1fK",v/1e3)
	else return tostring(math.floor(v)) end
end
local function parseNum(str)
	if not str then return nil end
	local s=str:gsub(",",""):gsub("%s+","")
	local a,suf=s:match("([%d%.]+)([MmKk])")
	if a then
		local n=tonumber(a) or 0
		if suf:lower()=="m" then return math.floor(n*1e6) end
		if suf:lower()=="k" then return math.floor(n*1e3) end
	end
	local p=s:match("(%d+)")
	return p and tonumber(p) or nil
end
local function parseExpBar(str)
	if not str then return nil,nil end
	local s=str:gsub(",","")
	local c,m=s:match("(%d+)/(%d+)")
	return c and tonumber(c) or nil, m and tonumber(m) or nil
end
local function parseBeli(raw)
	if not raw then return nil end
	local result
	for line in raw:gmatch("[^\n]+") do
		local s=line:match("^%s*(.-)%s*$")
		if s:find("^%$") or s:lower():find("beli") then
			local n=parseNum(s); if n and n>0 then result=n end
		end
	end
	if not result and raw:find("%$") then
		local n=raw:gsub(",",""):match("%$%s*(%d+)"); if n then result=tonumber(n) end
	end
	return result
end
local function parseQuestExp(raw)
	if not raw then return nil end
	for line in raw:gmatch("[^\n]+") do
		local s=line:match("^%s*(.-)%s*$")
		if s:lower():find("exp") or s:lower():find("xp") then
			local n=parseNum(s); if n and n>0 then return n end
		end
	end
	return nil
end

local perfGui = Instance.new("ScreenGui")
perfGui.Name="PerfHUD"; perfGui.ResetOnSpawn=false
perfGui.IgnoreGuiInset=true; perfGui.Parent=lp:WaitForChild("PlayerGui")

-- ── ROW 1: FPS / PING / TIME ───────────────────────────
local ROW1_W = isMobile and 280 or 260
local ROW1_H = isMobile and 60  or 54

local row1 = Instance.new("Frame")
row1.Size        = UDim2.new(0, ROW1_W, 0, ROW1_H)
row1.AnchorPoint = Vector2.new(0.5,0)
row1.Position    = UDim2.new(0.5,0,0, isMobile and 80 or 150)
row1.BackgroundColor3       = Color3.fromRGB(14,14,24)
row1.BackgroundTransparency = 0.3
row1.BorderSizePixel        = 0
row1.Parent                 = perfGui
Instance.new("UICorner",row1).CornerRadius=UDim.new(1,0)
local r1St=Instance.new("UIStroke",row1)
r1St.Color=Color3.fromRGB(255,255,255); r1St.Thickness=1; r1St.Transparency=0.82

local SEC_W = math.floor(ROW1_W/3)
local function makeSep1(x)
	local f=Instance.new("Frame",row1)
	f.Size=UDim2.new(0,1,0,26); f.Position=UDim2.new(0,x,0.5,-13)
	f.BackgroundColor3=Color3.fromRGB(255,255,255); f.BackgroundTransparency=0.8; f.BorderSizePixel=0
end
makeSep1(SEC_W); makeSep1(SEC_W*2)

local TS_TAG = isMobile and 11 or 10
local TS_VAL = isMobile and 19 or 17

local function makeSection1(tag, col)
	local cx = SEC_W*col + math.floor(SEC_W/2)
	local tl=Instance.new("TextLabel",row1)
	tl.Size=UDim2.new(0,SEC_W,0,16); tl.Position=UDim2.new(0,SEC_W*col,0,6)
	tl.BackgroundTransparency=1; tl.Text=tag; tl.TextColor3=Color3.fromRGB(180,180,200)
	tl.TextSize=TS_TAG; tl.Font=Enum.Font.GothamBold; tl.TextXAlignment=Enum.TextXAlignment.Center
	tl.TextStrokeTransparency=0.6; tl.TextStrokeColor3=Color3.new(0,0,0)
	local vl=Instance.new("TextLabel",row1)
	vl.Size=UDim2.new(0,SEC_W,0,26); vl.Position=UDim2.new(0,SEC_W*col,0,ROW1_H-32)
	vl.BackgroundTransparency=1; vl.Text="---"; vl.TextSize=TS_VAL
	vl.Font=Enum.Font.GothamBold; vl.TextXAlignment=Enum.TextXAlignment.Center
	vl.TextStrokeTransparency=0.5; vl.TextStrokeColor3=Color3.new(0,0,0)
	return vl
end

local lblFps  = makeSection1("FPS",  0); lblFps.TextColor3  = Color3.fromRGB(74,222,128)
local lblPing = makeSection1("PING", 1); lblPing.TextColor3 = Color3.fromRGB(250,200,40)
local lblTime = makeSection1("TIME", 2); lblTime.TextColor3 = Color3.fromRGB(192,132,252)

local ROW2_H = isMobile and 52 or 46
local ROW2_W = isMobile and 280 or 220

local row2 = Instance.new("Frame")
row2.Size        = UDim2.new(0, ROW2_W, 0, ROW2_H)
row2.AnchorPoint = Vector2.new(0.5,0)
row2.Position    = UDim2.new(0.5,0,0, (isMobile and 80 or 150) + ROW1_H + 6)
row2.BackgroundColor3       = Color3.fromRGB(14,14,24)
row2.BackgroundTransparency = 0.3
row2.BorderSizePixel        = 0
row2.Parent                 = perfGui
Instance.new("UICorner",row2).CornerRadius=UDim.new(1,0)
local r2St=Instance.new("UIStroke",row2)
r2St.Color=Color3.fromRGB(255,255,255); r2St.Thickness=1; r2St.Transparency=0.82

local sepR2=Instance.new("Frame",row2)
sepR2.Size=UDim2.new(0,1,0,26); sepR2.Position=UDim2.new(0.5,0,0.5,-13)
sepR2.BackgroundColor3=Color3.fromRGB(255,255,255); sepR2.BackgroundTransparency=0.8; sepR2.BorderSizePixel=0

local capLbl=Instance.new("TextLabel",row2)
capLbl.Size=UDim2.new(0.5,0,0,16); capLbl.Position=UDim2.new(0,0,0,0)
capLbl.BackgroundTransparency=1; capLbl.Text="Lock Fps"
capLbl.TextColor3=Color3.fromRGB(180,180,200); capLbl.TextSize=TS_TAG
capLbl.Font=Enum.Font.GothamBold; capLbl.TextXAlignment=Enum.TextXAlignment.Center
capLbl.TextStrokeTransparency=0.6; capLbl.TextStrokeColor3=Color3.new(0,0,0)

local capBox=Instance.new("TextBox",row2)
capBox.Size=UDim2.new(0, isMobile and 70 or 60, 0, isMobile and 28 or 24)
capBox.AnchorPoint=Vector2.new(0.5,1)
capBox.Position=UDim2.new(0.25,0,1,-6)
capBox.BackgroundColor3=Color3.fromRGB(22,22,38); capBox.BorderSizePixel=0
capBox.Text=tostring(FPS_CAP); capBox.PlaceholderText="60"
capBox.TextColor3=Color3.fromRGB(100,210,255); capBox.TextSize=isMobile and 16 or 15
capBox.Font=Enum.Font.GothamBold; capBox.TextXAlignment=Enum.TextXAlignment.Center
capBox.ClearTextOnFocus=true
Instance.new("UICorner",capBox).CornerRadius=UDim.new(0,5)
local capBoxSt=Instance.new("UIStroke",capBox)
capBoxSt.Color=Color3.fromRGB(100,180,255); capBoxSt.Thickness=1; capBoxSt.Transparency=0.4

local function commitCap()
	local n=tonumber(capBox.Text:gsub("%s+","")) or 60
	n=math.clamp(math.floor(n),0,999)
	applyFpsCap(n)
	capBox.Text=(n>0) and tostring(n) or "∞"
end
capBox.FocusLost:Connect(function(enter) if enter then commitCap() end end)

local dimBtn=Instance.new("TextButton",row2)
dimBtn.Size=UDim2.new(0.5,-8,0, isMobile and 36 or 30)
dimBtn.AnchorPoint=Vector2.new(0,0.5)
dimBtn.Position=UDim2.new(0.5,4,0.5,0)
dimBtn.BackgroundColor3=Color3.fromRGB(22,22,38); dimBtn.BorderSizePixel=0
dimBtn.Text="Black Screen"; dimBtn.TextColor3=Color3.fromRGB(180,180,220)
dimBtn.TextSize=isMobile and 15 or 13; dimBtn.Font=Enum.Font.GothamBold
dimBtn.AutoButtonColor=false
Instance.new("UICorner",dimBtn).CornerRadius=UDim.new(0,6)
local dimSt=Instance.new("UIStroke",dimBtn)
dimSt.Color=Color3.fromRGB(255,255,255); dimSt.Thickness=0.8; dimSt.Transparency=0.7

dimBtn.MouseButton1Click:Connect(function()
	setBlackout(not blackoutOn)
	dimBtn.Text    = blackoutOn and "Black Screen" or "Black Screen"
end)

-- ── FPS / PING / TIME loops ────────────────────────────
local startTime=tick()
RunService.Heartbeat:Connect(function()
	local e=math.floor(tick()-startTime)
	lblTime.Text = e>=3600
		and string.format("%d:%02d:%02d",math.floor(e/3600),math.floor((e%3600)/60),e%60)
		or  string.format("%02d:%02d",math.floor(e/60),e%60)
end)

local frameCount,lastTick2=0,tick()
RunService.RenderStepped:Connect(function()
	frameCount+=1
	local now=tick()
	if now-lastTick2>=0.5 then
		local fps=math.floor(frameCount/(now-lastTick2))
		frameCount=0; lastTick2=now
		lblFps.Text=tostring(fps)
		lblFps.TextColor3 = fps>=60 and Color3.fromRGB(74,222,128)
			or fps>=30 and Color3.fromRGB(250,200,40)
			or Color3.fromRGB(255,70,70)
	end
end)

RunService.Heartbeat:Connect(function()
	local ok,ping=pcall(function() return math.floor(lp:GetNetworkPing()*1000) end)
	if not ok then return end
	ping=math.max(0,ping)
	lblPing.Text=tostring(ping).." ms"
	lblPing.TextColor3 = ping<=80 and Color3.fromRGB(74,222,128)
		or ping<=200 and Color3.fromRGB(250,200,40)
		or Color3.fromRGB(255,70,70)
end)

local mainGui=Instance.new("ScreenGui")
mainGui.Name="BloxHUD"; mainGui.ResetOnSpawn=false
mainGui.IgnoreGuiInset=true; mainGui.Parent=lp:WaitForChild("PlayerGui")

local CARD_W  = isMobile and 290 or 260
local CARD_H  = isMobile and 380 or 320
local MINI_H  = isMobile and 66  or 56
local CONTENT_H = 500

local pc=Instance.new("Frame")
pc.Size        = UDim2.new(0,CARD_W,0,CARD_H)
if isMobile then
	pc.AnchorPoint = Vector2.new(0.5,1)
	pc.Position    = UDim2.new(0.5,0,1,-120)
else
	pc.AnchorPoint = Vector2.new(1,0)
	pc.Position    = UDim2.new(1,-12,0,175)
end
pc.BackgroundColor3       = Color3.fromRGB(10,10,18)
pc.BackgroundTransparency = 0.15
pc.BorderSizePixel        = 0
pc.ClipsDescendants       = true
pc.Parent                 = mainGui
Instance.new("UICorner",pc).CornerRadius=UDim.new(0,10)
local pcSt=Instance.new("UIStroke",pc)
pcSt.Color=Color3.fromRGB(255,255,255); pcSt.Thickness=0.8; pcSt.Transparency=0.85

-- miniBar
local miniBar=Instance.new("Frame",pc)
miniBar.Size=UDim2.new(1,0,0,MINI_H); miniBar.Position=UDim2.new(0,0,0,0)
miniBar.BackgroundColor3=Color3.fromRGB(10,10,18); miniBar.BackgroundTransparency=0.15
miniBar.BorderSizePixel=0; miniBar.Visible=false
Instance.new("UICorner",miniBar).CornerRadius=UDim.new(0,10)

local function mkLabel(parent,txt,ts,tc,font,xa,sz,pos)
	local l=Instance.new("TextLabel",parent)
	l.Size=sz; l.Position=pos; l.BackgroundTransparency=1
	l.Text=txt; l.TextColor3=tc; l.TextSize=ts
	l.Font=font or Enum.Font.Gotham
	l.TextXAlignment=xa or Enum.TextXAlignment.Left
	l.TextStrokeTransparency=0.4; l.TextStrokeColor3=Color3.new(0,0,0)
	return l
end

local miniName=mkLabel(miniBar,"",isMobile and 14 or 13,Color3.fromRGB(255,255,255),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-48,0,18),UDim2.new(0,10,0,8))
local miniQuest=mkLabel(miniBar,"",isMobile and 11 or 10,Color3.fromRGB(200,200,220),Enum.Font.Gotham,
	Enum.TextXAlignment.Left,UDim2.new(1,-48,0,16),UDim2.new(0,10,0,30))

-- collapse / expand
local isMin=false
local BTN_SZ = isMobile and 38 or 26
local minBtn=Instance.new("TextButton",pc)
minBtn.Size=UDim2.new(0,BTN_SZ,0,BTN_SZ-8); minBtn.Position=UDim2.new(1,-BTN_SZ-6,0,12)
minBtn.BackgroundColor3=Color3.fromRGB(30,30,48); minBtn.BorderSizePixel=0
minBtn.Text="▲"; minBtn.TextColor3=Color3.fromRGB(160,160,200)
minBtn.TextSize=isMobile and 12 or 9; minBtn.Font=Enum.Font.GothamBold; minBtn.AutoButtonColor=false
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",minBtn).Color=Color3.fromRGB(255,255,255)

local function applyMin()
	if isMin then
		pc.Size=UDim2.new(0,CARD_W,0,MINI_H)
		pc.BackgroundTransparency=1; pcSt.Transparency=1
		miniBar.Visible=true; minBtn.Text="▼"
		minBtn.Position=UDim2.new(1,-BTN_SZ-6,0,math.floor((MINI_H-BTN_SZ+8)/2))
	else
		pc.Size=UDim2.new(0,CARD_W,0,CARD_H)
		pc.BackgroundTransparency=0.15; pcSt.Transparency=0.85
		miniBar.Visible=false; minBtn.Text="▲"
		minBtn.Position=UDim2.new(1,-BTN_SZ-6,0,12)
	end
end
minBtn.MouseButton1Click:Connect(function() isMin=not isMin; applyMin() end)

-- ScrollingFrame
local scroll=Instance.new("ScrollingFrame",pc)
scroll.Size                   = UDim2.new(1,0,1,0)
scroll.Position               = UDim2.new(0,0,0,0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel        = 0
scroll.ScrollBarThickness     = isMobile and 4 or 3
scroll.ScrollBarImageColor3   = Color3.fromRGB(120,120,180)
scroll.CanvasSize             = UDim2.new(0,0,0,CONTENT_H)
scroll.ScrollingDirection     = Enum.ScrollingDirection.Y
scroll.ElasticBehavior        = Enum.ElasticBehavior.Never
scroll.ClipsDescendants       = true

local body=Instance.new("Frame",scroll)
body.Size=UDim2.new(1,0,0,CONTENT_H)
body.BackgroundTransparency=1; body.BorderSizePixel=0

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
	d.BackgroundColor3=Color3.fromRGB(255,255,255); d.BackgroundTransparency=0.88; d.BorderSizePixel=0
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

-- info grid
local INFO={
	{tag="LEVEL",    key="Level",    color=Color3.fromRGB(255,215,60)},
	{tag="BELI",     key="Beli",     color=Color3.fromRGB(80,235,140)},
	{tag="FRAGMENTS",key="Fragments",color=Color3.fromRGB(200,130,255)},
	{tag="RACE",     key="Race",     color=Color3.fromRGB(210,150,255)},
}
local infoLabels={}
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

-- combat stats
bLabel("COMBAT STATS",10,Color3.fromRGB(200,200,230),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-16,0,12),UDim2.new(0,10,0,142))
local COMBAT={
	{tag="Melee",      icon="👊",color=Color3.fromRGB(255,175,90)},
	{tag="Defense",    icon="🛡", color=Color3.fromRGB(120,190,255)},
	{tag="Sword",      icon="⚔", color=Color3.fromRGB(225,190,255)},
	{tag="Gun",        icon="🔫",color=Color3.fromRGB(90,235,150)},
	{tag="Demon Fruit",icon="🍎",color=Color3.fromRGB(255,120,150)},
}
local combatLabels={}
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

-- quest
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

local SELF_FILL=Color3.fromRGB(60,220,120)
local SELF_OUTLINE=Color3.fromRGB(140,255,180)
local selfHL=nil
local function safeDestroy(inst)
	if inst and inst.Parent then pcall(inst.Destroy,inst) end
end
local function applySelfHighlight(char)
	safeDestroy(selfHL); selfHL=nil
	char=char or lp.Character; if not char then return end
	local hl=Instance.new("Highlight")
	hl.Name="ESP_SelfHL"; hl.FillColor=SELF_FILL; hl.OutlineColor=SELF_OUTLINE
	hl.FillTransparency=0.65; hl.OutlineTransparency=0
	hl.DepthMode=Enum.HighlightDepthMode.Occluded
	hl.Adornee=char; hl.Parent=char; selfHL=hl
end
if lp.Character then task.delay(0.5,function() applySelfHighlight(lp.Character) end) end
lp.CharacterAdded:Connect(function(char) task.wait(0.5); applySelfHighlight(char) end)

local MAX_STAT=2550
local function updateData()
	local data=lp:FindFirstChild("Data"); if not data then return end
	for _,k in ipairs({"Level","Beli","Fragments","Race"}) do
		local node=data:FindFirstChild(k)
		if node and infoLabels[k] then infoLabels[k].Text=fmt(node.Value,k) end
	end
	local lvNode=data:FindFirstChild("Level")
	if lvNode then miniName.Text=lp.DisplayName.."  |  Lv. "..addCommas(lvNode.Value or 0) end
	local stats=data:FindFirstChild("Stats"); if not stats then return end
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
	local data=lp:WaitForChild("Data",10); if not data then return end
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

local function updateQuest()
	local active,rawTitle,rawReward=false,"",""
	pcall(function()
		local qf=lp.PlayerGui.Main.Quest; active=qf.Visible
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
		expCur.BackgroundColor3=Color3.fromRGB(74,222,128); return
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
