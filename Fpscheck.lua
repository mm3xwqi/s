-- [ Example Config
-- getenv = function() return {
--    ["Lock Fps"] = { ["Enabled"] = true, ["FPS"] = 25 },
--    ["White Screen"] = true,
--    ["FPS Boost"] = true,
-- } end ]

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenSvc   = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local lp         = Players.LocalPlayer

local _cfg = {}
pcall(function()
	local env = getenv and getenv() or {}
	_cfg = type(env) == "table" and env or {}
end)

local function cfgGet(key, default)
	if _cfg[key] == nil then return default end
	return _cfg[key]
end
local function cfgGetSub(key, sub, default)
	local t = _cfg[key]
	if type(t) ~= "table" then return default end
	if t[sub] == nil then return default end
	return t[sub]
end

for _, v in ipairs(lp:WaitForChild("PlayerGui"):GetChildren()) do
	if v.Name == "PerfHUD" or v.Name == "BloxHUD" or v.Name == "BlackoutGui" then v:Destroy() end
end

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- FPS cap (config only, no UI)
local FPS_CAP = cfgGetSub("Lock Fps", "Enabled", false) and cfgGetSub("Lock Fps", "FPS", 60) or 999
local function applyFpsCap(cap)
	if cap and cap > 0 then
		if setfpscap then pcall(function() setfpscap(cap) end) return end
		pcall(function() settings().Rendering.FrameRateManager = Enum.FramerateManagerMode.On end)
	else
		if setfpscap then pcall(function() setfpscap(0) end) return end
		pcall(function() settings().Rendering.FrameRateManager = Enum.FramerateManagerMode.Automatic end)
	end
end
applyFpsCap(FPS_CAP)

-- FPS Boost (config only, no UI)
local boostOn = false
local _origLighting = {}
local function setBoost(state)
	boostOn = state
	local lighting = game:GetService("Lighting")
	if state then
		pcall(function() lp.PlayerGui.Main.Enabled = false end)
		_origLighting = {GlobalShadows=lighting.GlobalShadows,FogEnd=lighting.FogEnd,Brightness=lighting.Brightness}
		pcall(function() lighting.GlobalShadows=false end)
		pcall(function() lighting.FogEnd=9e8 end)
		pcall(function() lighting.FogStart=9e8 end)
		pcall(function() lighting.Brightness=1 end)
		for _,v in ipairs(lighting:GetChildren()) do
			if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect")
				or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
				pcall(function() v.Enabled=false end)
			end
		end
		pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
		for _,obj in ipairs(workspace:GetDescendants()) do
			pcall(function()
				if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
					obj.Enabled=false
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency=1
				elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
					obj.Enabled=false
				end
			end)
		end
		pcall(function() settings().Rendering.EagerBulkExecution=true end)
	else
		if not blackoutOn then pcall(function() lp.PlayerGui.Main.Enabled = true end) end
		pcall(function() lighting.GlobalShadows=_origLighting.GlobalShadows end)
		pcall(function() lighting.FogEnd=_origLighting.FogEnd end)
		pcall(function() lighting.Brightness=_origLighting.Brightness end)
		for _,v in ipairs(lighting:GetChildren()) do
			if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect")
				or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
				pcall(function() v.Enabled=true end)
			end
		end
		pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end)
		for _,obj in ipairs(workspace:GetDescendants()) do
			pcall(function()
				if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
					obj.Enabled=true
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency=0
				elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
					obj.Enabled=true
				end
			end)
		end
	end
end
if cfgGet("FPS Boost", false) then task.defer(function() setBoost(true) end) end

-- ── Blackout ────────────────────────────────────────────────────────────────
local blackoutGui = Instance.new("ScreenGui")
blackoutGui.Name = "BlackoutGui"
blackoutGui.ResetOnSpawn = false
blackoutGui.IgnoreGuiInset = true
blackoutGui.DisplayOrder = 1
blackoutGui.Parent = lp:WaitForChild("PlayerGui")

local blackFrame = Instance.new("Frame", blackoutGui)
blackFrame.Size = UDim2.new(1,0,1,0)
blackFrame.BackgroundColor3 = Color3.new(0,0,0)
blackFrame.BackgroundTransparency = 1
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 10
blackFrame.Visible = false

local blackHint = Instance.new("TextLabel", blackFrame)
blackHint.Size = UDim2.new(0.8,0,0,40)
blackHint.AnchorPoint = Vector2.new(0.5,0.5)
blackHint.Position = UDim2.new(0.5,0,0.5,0)
blackHint.BackgroundTransparency = 1
blackHint.Text = isMobile and "Black Screen  —  แตะปุ่ม Restore เพื่อเปิดจอ" or "Black Screen  —  กด [B] หรือแตะปุ่ม Restore เพื่อเปิดจอ"
blackHint.TextColor3 = Color3.fromRGB(90,90,110)
blackHint.TextSize = isMobile and 16 or 14
blackHint.Font = Enum.Font.GothamBold
blackHint.TextXAlignment = Enum.TextXAlignment.Center
blackHint.TextWrapped = true
blackHint.ZIndex = 11

local wakeBtn = Instance.new("TextButton", blackoutGui)
wakeBtn.Size = UDim2.new(0, isMobile and 120 or 100, 0, isMobile and 50 or 40)
wakeBtn.AnchorPoint = Vector2.new(0.5,1)
wakeBtn.Position = UDim2.new(0.5,0,1,-30)
wakeBtn.BackgroundColor3 = Color3.fromRGB(30,30,50)
wakeBtn.BorderSizePixel = 0
wakeBtn.Text = "Restore"
wakeBtn.TextColor3 = Color3.fromRGB(255,230,80)
wakeBtn.TextSize = isMobile and 16 or 14
wakeBtn.Font = Enum.Font.GothamBold
wakeBtn.AutoButtonColor = false
wakeBtn.Visible = false
wakeBtn.ZIndex = 20
Instance.new("UICorner", wakeBtn).CornerRadius = UDim.new(0,8)
local wakeSt = Instance.new("UIStroke", wakeBtn)
wakeSt.Color = Color3.fromRGB(255,220,60); wakeSt.Thickness = 1.2; wakeSt.Transparency = 0.3

local blackoutOn = false
local function setBlackout(state)
	blackoutOn = state
	if state then
		pcall(function() lp.PlayerGui.Main.Enabled = false end)
		blackFrame.Visible = true
		wakeBtn.Visible = true
		blackFrame.BackgroundTransparency = 1
		TweenSvc:Create(blackFrame, TweenInfo.new(0.4,Enum.EasingStyle.Quad), {BackgroundTransparency=0}):Play()
	else
		if not boostOn then pcall(function() lp.PlayerGui.Main.Enabled = true end) end
		wakeBtn.Visible = false
		blackFrame.BackgroundTransparency = 1
		blackFrame.Visible = false
	end
end

if cfgGet("White Screen", false) then task.defer(function() setBlackout(true) end) end

wakeBtn.MouseButton1Click:Connect(function() setBlackout(false) end)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.B then setBlackout(not blackoutOn) end
end)

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function addCommas(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end
local NO_SHORT = {Beli=true,Fragments=true,Level=true}
local function fmt(v,key)
	if type(v)~="number" then return tostring(v or "?") end
	if NO_SHORT[key] then return addCommas(v) end
	if v>=1e6 then return string.format("%.1fM",v/1e6)
	elseif v>=1e3 then return string.format("%.1fK",v/1e3)
	else return tostring(math.floor(v)) end
end
local function parseNum(str)
	if not str then return nil end
	local s = str:gsub(",",""):gsub("%s+","")
	local a,suf = s:match("([%d%.]+)([MmKk])")
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
	local c,m = s:match("(%d+)/(%d+)")
	return c and tonumber(c) or nil, m and tonumber(m) or nil
end
local function parseBeli(raw)
	if not raw then return nil end
	local result
	for line in raw:gmatch("[^\n]+") do
		local s = line:match("^%s*(.-)%s*$")
		if s:find("^%$") or s:lower():find("beli") then
			local n = parseNum(s); if n and n>0 then result=n end
		end
	end
	if not result and raw:find("%$") then
		local n = raw:gsub(",",""):match("%$%s*(%d+)"); if n then result=tonumber(n) end
	end
	return result
end
local function parseQuestExp(raw)
	if not raw then return nil end
	for line in raw:gmatch("[^\n]+") do
		local s = line:match("^%s*(.-)%s*$")
		if s:lower():find("exp") or s:lower():find("xp") then
			local n = parseNum(s); if n and n>0 then return n end
		end
	end
	return nil
end

-- ── PerfHUD (FPS / PING / TIME) ─────────────────────────────────────────────
local perfGui = Instance.new("ScreenGui")
perfGui.Name = "PerfHUD"; perfGui.ResetOnSpawn = false
perfGui.DisplayOrder = 10
perfGui.IgnoreGuiInset = true; perfGui.Parent = lp:WaitForChild("PlayerGui")

local ROW1_W = isMobile and 280 or 260
local ROW1_H = isMobile and 60 or 54
local TS_TAG = isMobile and 11 or 10
local TS_VAL = isMobile and 19 or 17

local row1 = Instance.new("Frame")
row1.Size = UDim2.new(0,ROW1_W,0,ROW1_H)
row1.AnchorPoint = Vector2.new(0.5,0)
row1.Position = UDim2.new(0.5,0,0, isMobile and 80 or 150)
row1.BackgroundColor3 = Color3.fromRGB(14,14,24)
row1.BackgroundTransparency = 0.3
row1.BorderSizePixel = 0
row1.Parent = perfGui
Instance.new("UICorner",row1).CornerRadius = UDim.new(1,0)
local r1St = Instance.new("UIStroke",row1)
r1St.Color = Color3.fromRGB(255,255,255); r1St.Thickness = 1; r1St.Transparency = 0.82

local SEC_W = math.floor(ROW1_W/3)
local function makeSep1(x)
	local f = Instance.new("Frame",row1)
	f.Size = UDim2.new(0,1,0,26); f.Position = UDim2.new(0,x,0.5,-13)
	f.BackgroundColor3 = Color3.fromRGB(255,255,255); f.BackgroundTransparency = 0.8; f.BorderSizePixel = 0
end
makeSep1(SEC_W); makeSep1(SEC_W*2)

local function makeSection1(tag, col)
	local tl = Instance.new("TextLabel",row1)
	tl.Size = UDim2.new(0,SEC_W,0,16); tl.Position = UDim2.new(0,SEC_W*col,0,6)
	tl.BackgroundTransparency = 1; tl.Text = tag; tl.TextColor3 = Color3.fromRGB(180,180,200)
	tl.TextSize = TS_TAG; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Center
	tl.TextStrokeTransparency = 0.6; tl.TextStrokeColor3 = Color3.new(0,0,0)
	local vl = Instance.new("TextLabel",row1)
	vl.Size = UDim2.new(0,SEC_W,0,26); vl.Position = UDim2.new(0,SEC_W*col,0,ROW1_H-32)
	vl.BackgroundTransparency = 1; vl.Text = "---"; vl.TextSize = TS_VAL
	vl.Font = Enum.Font.GothamBold; vl.TextXAlignment = Enum.TextXAlignment.Center
	vl.TextStrokeTransparency = 0.5; vl.TextStrokeColor3 = Color3.new(0,0,0)
	return vl
end

local lblFps  = makeSection1("FPS",  0); lblFps.TextColor3  = Color3.fromRGB(74,222,128)
local lblPing = makeSection1("PING", 1); lblPing.TextColor3 = Color3.fromRGB(250,200,40)
local lblTime = makeSection1("TIME", 2); lblTime.TextColor3 = Color3.fromRGB(192,132,252)

local startTime = tick()
RunService.Heartbeat:Connect(function()
	local e = math.floor(tick()-startTime)
	lblTime.Text = e>=3600
		and string.format("%d:%02d:%02d",math.floor(e/3600),math.floor((e%3600)/60),e%60)
		or  string.format("%02d:%02d",math.floor(e/60),e%60)
end)

local frameCount,lastTick2 = 0,tick()
RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	if now-lastTick2 >= 0.5 then
		local fps = math.floor(frameCount/(now-lastTick2))
		frameCount=0; lastTick2=now
		lblFps.Text = tostring(fps)
		lblFps.TextColor3 = fps>=60 and Color3.fromRGB(74,222,128) or fps>=30 and Color3.fromRGB(250,200,40) or Color3.fromRGB(255,70,70)
	end
end)

RunService.Heartbeat:Connect(function()
	local ok,ping = pcall(function() return math.floor(lp:GetNetworkPing()*1000) end)
	if not ok then return end
	ping = math.max(0,ping)
	lblPing.Text = tostring(ping).." ms"
	lblPing.TextColor3 = ping<=80 and Color3.fromRGB(74,222,128) or ping<=200 and Color3.fromRGB(250,200,40) or Color3.fromRGB(255,70,70)
end)

-- ── BloxHUD ──────────────────────────────────────────────────────────────────
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "BloxHUD"; mainGui.ResetOnSpawn = false
mainGui.DisplayOrder = 10
mainGui.IgnoreGuiInset = true; mainGui.Parent = lp:WaitForChild("PlayerGui")

local CARD_W    = isMobile and 290 or 260
local CARD_H    = isMobile and 380 or 320
local MINI_H2   = isMobile and 64  or 54
local CONTENT_H = 500

local pc = Instance.new("Frame")
pc.Size = UDim2.new(0,CARD_W,0,CARD_H)
if isMobile then
	pc.AnchorPoint = Vector2.new(0.5,1)
	pc.Position    = UDim2.new(0.5,0,1,-120)
else
	pc.AnchorPoint = Vector2.new(1,0)
	pc.Position    = UDim2.new(1,-12,0,175)
end
pc.BackgroundColor3 = Color3.fromRGB(10,10,18)
pc.BackgroundTransparency = 0.15
pc.BorderSizePixel = 0
pc.ClipsDescendants = true
pc.Parent = mainGui
Instance.new("UICorner",pc).CornerRadius = UDim.new(0,10)
local pcSt = Instance.new("UIStroke",pc)
pcSt.Color = Color3.fromRGB(255,255,255); pcSt.Thickness = 0.8; pcSt.Transparency = 0.85

local miniContainer = Instance.new("Frame")
miniContainer.Size = UDim2.new(0,CARD_W,0,MINI_H2)
if isMobile then
	miniContainer.AnchorPoint = Vector2.new(0.5,1)
	miniContainer.Position    = UDim2.new(0.5,0,1,-120)
else
	miniContainer.AnchorPoint = Vector2.new(1,0)
	miniContainer.Position    = UDim2.new(1,-12,0,175)
end
miniContainer.BackgroundColor3 = Color3.fromRGB(10,10,18)
miniContainer.BackgroundTransparency = 0.18
miniContainer.BorderSizePixel = 0
miniContainer.ClipsDescendants = true
miniContainer.Visible = false
miniContainer.Parent = mainGui
Instance.new("UICorner",miniContainer).CornerRadius = UDim.new(0,10)
local miniContSt = Instance.new("UIStroke",miniContainer)
miniContSt.Color = Color3.fromRGB(255,255,255); miniContSt.Thickness = 0.7; miniContSt.Transparency = 0.82

local function mkLabel(parent,txt,ts,tc,font,xa,sz,pos)
	local l = Instance.new("TextLabel",parent)
	l.Size=sz; l.Position=pos; l.BackgroundTransparency=1
	l.Text=txt; l.TextColor3=tc; l.TextSize=ts
	l.Font=font or Enum.Font.Gotham
	l.TextXAlignment=xa or Enum.TextXAlignment.Left
	l.TextStrokeTransparency=0.4; l.TextStrokeColor3=Color3.new(0,0,0)
	return l
end

local BTN_RESERVED = isMobile and 44 or 36
local AV_SIZE      = isMobile and 30 or 26
local AV_X         = 8
local AV_Y         = 7
local TEXT_X       = AV_X + AV_SIZE + 8
local TEXT_W       = CARD_W - TEXT_X - BTN_RESERVED
local mROW1_Y      = 7
local mROW2_Y      = mROW1_Y + (isMobile and 17 or 15)
local mDIV_Y       = mROW2_Y + (isMobile and 15 or 13) + 2
local mSTAT_Y      = mDIV_Y + 4

local miniAvFrame = Instance.new("Frame",miniContainer)
miniAvFrame.Size = UDim2.new(0,AV_SIZE,0,AV_SIZE)
miniAvFrame.Position = UDim2.new(0,AV_X,0,AV_Y)
miniAvFrame.BackgroundColor3 = Color3.fromRGB(40,30,60); miniAvFrame.BorderSizePixel = 0
Instance.new("UICorner",miniAvFrame).CornerRadius = UDim.new(1,0)
local miniAvSt = Instance.new("UIStroke",miniAvFrame)
miniAvSt.Color = Color3.fromRGB(192,132,252); miniAvSt.Thickness = 1.2; miniAvSt.Transparency = 0.15
local miniAvImg = Instance.new("ImageLabel",miniAvFrame)
miniAvImg.Size = UDim2.new(1,0,1,0); miniAvImg.BackgroundTransparency = 1; miniAvImg.BorderSizePixel = 0
Instance.new("UICorner",miniAvImg).CornerRadius = UDim.new(1,0)
local okMini,thMini = pcall(function()
	return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
end)
if okMini then miniAvImg.Image = thMini end

local miniName = mkLabel(miniContainer,lp.DisplayName,isMobile and 13 or 12,Color3.fromRGB(255,255,255),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(0,TEXT_W,0,isMobile and 16 or 14),UDim2.new(0,TEXT_X,0,mROW1_Y))
mkLabel(miniContainer,"@"..lp.Name,isMobile and 10 or 9,Color3.fromRGB(150,130,190),Enum.Font.Gotham,
	Enum.TextXAlignment.Left,UDim2.new(0,TEXT_W,0,isMobile and 13 or 11),UDim2.new(0,TEXT_X,0,mROW2_Y))

local miniDiv = Instance.new("Frame",miniContainer)
miniDiv.Size = UDim2.new(1,-16,0,1); miniDiv.Position = UDim2.new(0,8,0,mDIV_Y)
miniDiv.BackgroundColor3 = Color3.fromRGB(255,255,255); miniDiv.BackgroundTransparency = 0.88; miniDiv.BorderSizePixel = 0

local SCOLS = {
	{icon="⚔",  key="Level",     color=Color3.fromRGB(255,215,60)},
	{icon="💰", key="Beli",      color=Color3.fromRGB(80,235,140)},
	{icon="💎", key="Fragments", color=Color3.fromRGB(200,130,255)},
	{icon="🧬", key="Race",      color=Color3.fromRGB(210,160,255)},
}
local miniStatLabels = {}
local SW = math.floor(CARD_W/4)
for i,s in ipairs(SCOLS) do
	local sx = (i-1)*SW
	local ico = Instance.new("TextLabel",miniContainer)
	ico.Size=UDim2.new(0,14,0,14); ico.Position=UDim2.new(0,sx+4,0,mSTAT_Y)
	ico.BackgroundTransparency=1; ico.Text=s.icon; ico.TextSize=isMobile and 11 or 10
	ico.Font=Enum.Font.Gotham; ico.TextXAlignment=Enum.TextXAlignment.Center; ico.TextStrokeTransparency=1
	local vl = Instance.new("TextLabel",miniContainer)
	vl.Size=UDim2.new(0,SW-20,0,14); vl.Position=UDim2.new(0,sx+19,0,mSTAT_Y)
	vl.BackgroundTransparency=1; vl.Text="..."; vl.TextSize=isMobile and 11 or 10
	vl.Font=Enum.Font.GothamBold; vl.TextColor3=s.color
	vl.TextXAlignment=Enum.TextXAlignment.Left; vl.ClipsDescendants=true
	vl.TextStrokeTransparency=0.4; vl.TextStrokeColor3=Color3.new(0,0,0)
	miniStatLabels[s.key] = vl
end

local BTN_SZ = isMobile and 38 or 26

local expandBtn = Instance.new("TextButton",miniContainer)
expandBtn.Size = UDim2.new(0,BTN_SZ,0,BTN_SZ-8)
expandBtn.Position = UDim2.new(1,-BTN_SZ-6,0,7)
expandBtn.BackgroundColor3 = Color3.fromRGB(30,30,48); expandBtn.BorderSizePixel = 0
expandBtn.Text = "▼"; expandBtn.TextColor3 = Color3.fromRGB(160,160,200)
expandBtn.TextSize = isMobile and 12 or 9; expandBtn.Font = Enum.Font.GothamBold; expandBtn.AutoButtonColor = false
Instance.new("UICorner",expandBtn).CornerRadius = UDim.new(0,5)
Instance.new("UIStroke",expandBtn).Color = Color3.fromRGB(255,255,255)

local collapseBtn = Instance.new("TextButton",pc)
collapseBtn.Size = UDim2.new(0,BTN_SZ,0,BTN_SZ-8)
collapseBtn.Position = UDim2.new(1,-BTN_SZ-6,0,12)
collapseBtn.BackgroundColor3 = Color3.fromRGB(30,30,48); collapseBtn.BorderSizePixel = 0
collapseBtn.Text = "▲"; collapseBtn.TextColor3 = Color3.fromRGB(160,160,200)
collapseBtn.TextSize = isMobile and 12 or 9; collapseBtn.Font = Enum.Font.GothamBold; collapseBtn.AutoButtonColor = false
Instance.new("UICorner",collapseBtn).CornerRadius = UDim.new(0,5)
Instance.new("UIStroke",collapseBtn).Color = Color3.fromRGB(255,255,255)

local isMin = false
local function applyMin()
	if isMin then
		pc.Visible = false
		miniContainer.Visible = true
	else
		pc.Visible = true
		miniContainer.Visible = false
	end
end

collapseBtn.MouseButton1Click:Connect(function() isMin=true;  applyMin() end)
expandBtn.MouseButton1Click:Connect(function()   isMin=false; applyMin() end)

local scroll = Instance.new("ScrollingFrame",pc)
scroll.Size = UDim2.new(1,0,1,0)
scroll.Position = UDim2.new(0,0,0,0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = isMobile and 4 or 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(120,120,180)
scroll.CanvasSize = UDim2.new(0,0,0,CONTENT_H)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ElasticBehavior = Enum.ElasticBehavior.Never
scroll.ClipsDescendants = true

local body = Instance.new("Frame",scroll)
body.Size = UDim2.new(1,0,0,CONTENT_H)
body.BackgroundTransparency = 1; body.BorderSizePixel = 0

local function bFrame(sz,pos,bg,bgT,r)
	local f = Instance.new("Frame",body)
	f.Size=sz; f.Position=pos
	f.BackgroundColor3=bg or Color3.fromRGB(10,10,18)
	f.BackgroundTransparency=bgT or 0; f.BorderSizePixel=0
	if r then Instance.new("UICorner",f).CornerRadius=r end
	return f
end
local function bLabel(txt,ts,tc,font,xa,sz,pos)
	local l = Instance.new("TextLabel",body)
	l.Size=sz; l.Position=pos; l.BackgroundTransparency=1
	l.Text=txt; l.TextColor3=tc; l.TextSize=ts
	l.Font=font or Enum.Font.Gotham
	l.TextXAlignment=xa or Enum.TextXAlignment.Left
	l.TextStrokeTransparency=0.4; l.TextStrokeColor3=Color3.new(0,0,0)
	return l
end
local function bDiv(y)
	local d = Instance.new("Frame",body)
	d.Size=UDim2.new(1,-16,0,1); d.Position=UDim2.new(0,8,0,y)
	d.BackgroundColor3=Color3.fromRGB(255,255,255); d.BackgroundTransparency=0.88; d.BorderSizePixel=0
end

local avFrame = bFrame(UDim2.new(0,50,0,50),UDim2.new(0,10,0,10),Color3.fromRGB(30,30,45),0,UDim.new(1,0))
local avSt = Instance.new("UIStroke",avFrame)
avSt.Color=Color3.fromRGB(192,132,252); avSt.Thickness=1.5; avSt.Transparency=0.2
local avImg = Instance.new("ImageLabel",avFrame)
avImg.Size=UDim2.new(1,0,1,0); avImg.BackgroundTransparency=1; avImg.BorderSizePixel=0
Instance.new("UICorner",avImg).CornerRadius=UDim.new(1,0)
local okT,th = pcall(function()
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
local vSep = Instance.new("Frame",body)
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
	local y = 158+(i-1)*22
	local ico = Instance.new("TextLabel",body)
	ico.Size=UDim2.new(0,20,0,20); ico.Position=UDim2.new(0,8,0,y)
	ico.BackgroundTransparency=1; ico.Text=s.icon; ico.TextSize=14
	ico.Font=Enum.Font.Gotham; ico.TextXAlignment=Enum.TextXAlignment.Center; ico.TextStrokeTransparency=1
	bLabel(s.tag,12,Color3.fromRGB(220,220,240),Enum.Font.GothamBold,
		Enum.TextXAlignment.Left,UDim2.new(0,100,0,20),UDim2.new(0,30,0,y))
	local barBg = bFrame(UDim2.new(0,95,0,4),UDim2.new(0,30,0,y+17),Color3.fromRGB(50,50,70),0,UDim.new(1,0))
	local barFill = Instance.new("Frame",barBg)
	barFill.Size=UDim2.new(0,0,1,0); barFill.BackgroundColor3=s.color; barFill.BorderSizePixel=0
	Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)
	local vl = bLabel("...",12,s.color,Enum.Font.GothamBold,
		Enum.TextXAlignment.Right,UDim2.new(0,50,0,20),UDim2.new(0,200,0,y))
	combatLabels[s.tag] = {label=vl,bar=barFill}
end

local QY = 278
bDiv(QY)
bLabel("📋  QUEST",10,Color3.fromRGB(255,200,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(0,120,0,16),UDim2.new(0,8,0,QY+10))
bDiv(QY+30)
bLabel("QUEST NAME",9,Color3.fromRGB(160,160,190),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-16,0,11),UDim2.new(0,8,0,QY+38))

local qTitle = Instance.new("TextLabel",body)
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
local qExp1 = bLabel("---",11,Color3.fromRGB(74,222,128),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-32,0,16),UDim2.new(0,28,0,QY+104))
bLabel("⚡×2",11,Color3.fromRGB(255,215,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Center,UDim2.new(0,28,0,16),UDim2.new(0,8,0,QY+122))
local qExp2 = bLabel("---",11,Color3.fromRGB(255,215,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-40,0,16),UDim2.new(0,38,0,QY+122))

local expBg = bFrame(UDim2.new(1,-16,0,4),UDim2.new(0,8,0,QY+140),Color3.fromRGB(40,40,60),0,UDim.new(1,0))
local expCur = Instance.new("Frame",expBg)
expCur.Size=UDim2.new(0,0,1,0); expCur.BackgroundColor3=Color3.fromRGB(74,222,128); expCur.BorderSizePixel=0
Instance.new("UICorner",expCur).CornerRadius=UDim.new(1,0)
local expAdd = Instance.new("Frame",expBg)
expAdd.Size=UDim2.new(0,0,1,0); expAdd.BackgroundColor3=Color3.fromRGB(255,215,60)
expAdd.BackgroundTransparency=0.4; expAdd.BorderSizePixel=0
Instance.new("UICorner",expAdd).CornerRadius=UDim.new(1,0)
bDiv(QY+148)

bLabel("💰",13,Color3.fromRGB(255,255,255),Enum.Font.Gotham,
	Enum.TextXAlignment.Center,UDim2.new(0,18,0,16),UDim2.new(0,8,0,QY+156))
local qBeli1 = bLabel("---",11,Color3.fromRGB(80,235,140),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-32,0,16),UDim2.new(0,28,0,QY+156))
bLabel("💰×2",11,Color3.fromRGB(255,200,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Center,UDim2.new(0,28,0,16),UDim2.new(0,8,0,QY+174))
local qBeli2 = bLabel("---",11,Color3.fromRGB(255,200,60),Enum.Font.GothamBold,
	Enum.TextXAlignment.Left,UDim2.new(1,-40,0,16),UDim2.new(0,38,0,QY+174))

local SELF_FILL    = Color3.fromRGB(60,220,120)
local SELF_OUTLINE = Color3.fromRGB(140,255,180)
local selfHL = nil
local function safeDestroy(inst)
	if inst and inst.Parent then pcall(inst.Destroy,inst) end
end
local function applySelfHighlight(char)
	safeDestroy(selfHL); selfHL=nil
	char = char or lp.Character; if not char then return end
	local hl = Instance.new("Highlight")
	hl.Name="ESP_SelfHL"; hl.FillColor=SELF_FILL; hl.OutlineColor=SELF_OUTLINE
	hl.FillTransparency=0.65; hl.OutlineTransparency=0
	hl.DepthMode=Enum.HighlightDepthMode.Occluded
	hl.Adornee=char; hl.Parent=char; selfHL=hl
end
if lp.Character then task.delay(0.5,function() applySelfHighlight(lp.Character) end) end
lp.CharacterAdded:Connect(function(char) task.wait(0.5); applySelfHighlight(char) end)

local MAX_STAT = 2550
local function updateData()
	local data = lp:FindFirstChild("Data"); if not data then return end
	for _,k in ipairs({"Level","Beli","Fragments","Race"}) do
		local node = data:FindFirstChild(k)
		if node and infoLabels[k] then infoLabels[k].Text=fmt(node.Value,k) end
	end
	if data:FindFirstChild("Level") then miniName.Text=lp.DisplayName end
	for _,k in ipairs({"Level","Beli","Fragments","Race"}) do
		local node = data:FindFirstChild(k)
		if node and miniStatLabels[k] then miniStatLabels[k].Text=fmt(node.Value,k) end
	end
	local stats = data:FindFirstChild("Stats"); if not stats then return end
	for _,s in ipairs(COMBAT) do
		local node = stats:FindFirstChild(s.tag)
		if node then
			local lvN = node:FindFirstChild("Level")
			if lvN and combatLabels[s.tag] then
				local v = lvN.Value or 0
				combatLabels[s.tag].label.Text=tostring(v)
				combatLabels[s.tag].bar.Size=UDim2.new(math.clamp(v/MAX_STAT,0,1),0,1,0)
			end
		end
	end
end
task.spawn(function()
	local data = lp:WaitForChild("Data",10); if not data then return end
	updateData()
	local function watch(obj) if obj then obj.Changed:Connect(updateData) end end
	for _,k in ipairs({"Level","Beli","Fragments","Race"}) do watch(data:WaitForChild(k,5)) end
	local stats = data:WaitForChild("Stats",5)
	if stats then
		for _,s in ipairs(COMBAT) do
			local node = stats:WaitForChild(s.tag,5)
			if node then watch(node:WaitForChild("Level",5)) end
		end
	end
end)

local function updateQuest()
	local active,rawTitle,rawReward = false,"",""
	pcall(function()
		local qf = lp.PlayerGui.Main.Quest; active=qf.Visible
		if active then
			rawTitle  = qf.Container.QuestTitle.Title.ContentText  or ""
			rawReward = qf.Container.QuestReward.Title.ContentText or ""
		end
	end)
	if not active or rawTitle=="" then
		qTitle.Text="No active quest"; qTitle.TextColor3=Color3.fromRGB(160,160,190)
		qExp1.Text="---"; qExp2.Text="---"; qBeli1.Text="---"; qBeli2.Text="---"
		expCur.Size=UDim2.new(0,0,1,0); expAdd.Size=UDim2.new(0,0,1,0)
		expCur.BackgroundColor3=Color3.fromRGB(74,222,128); return
	end
	qTitle.Text=rawTitle; qTitle.TextColor3=Color3.fromRGB(255,255,255)
	local curExp,needExp
	pcall(function() curExp,needExp=parseExpBar(lp.PlayerGui.Main.Level.Exp.ContentText) end)
	local curLv,curBeli = 0,0
	pcall(function() curLv  =lp.Data.Level.Value or 0 end)
	pcall(function() curBeli=lp.Data.Beli.Value  or 0 end)
	local baseExp = parseQuestExp(rawReward)
	if baseExp and curExp and needExp and needExp>0 then
		local e1,e2 = baseExp,baseExp*2
		local a1,a2 = curExp+e1,curExp+e2
		local pctCur   = math.clamp(curExp/needExp,0,1)
		local pctAfter = math.clamp(a1/needExp,0,1)
		expCur.Size = UDim2.new(pctCur,0,1,0)
		expAdd.Size = UDim2.new(pctAfter-pctCur,0,1,0)
		expAdd.Position = UDim2.new(pctCur,0,0,0)
		if a1>=needExp then
			qExp1.Text=string.format("+%s  LevelUP!  Lv.%d → Lv.%d",addCommas(e1),curLv,curLv+1)
			qExp1.TextColor3=Color3.fromRGB(255,215,60)
			expCur.BackgroundColor3=Color3.fromRGB(255,215,60)
		else
			local need1 = math.ceil((needExp-a1)/e1)
			qExp1.Text=string.format("+%s  →  %s / %s  (%d left)",addCommas(e1),addCommas(a1),addCommas(needExp),need1)
			qExp1.TextColor3=Color3.fromRGB(74,222,128)
			expCur.BackgroundColor3=Color3.fromRGB(74,222,128)
		end
		if a2>=needExp then
			qExp2.Text=string.format("+%s  LevelUP!  Lv.%d → Lv.%d",addCommas(e2),curLv,curLv+1)
		else
			local need2 = math.ceil((needExp-a2)/e2)
			qExp2.Text=string.format("+%s  →  %s / %s  (%d left)",addCommas(e2),addCommas(a2),addCommas(needExp),need2)
		end
		qExp2.TextColor3=Color3.fromRGB(255,215,60)
	else
		local expLine = "---"
		for line in rawReward:gmatch("[^\n]+") do
			local s = line:match("^%s*(.-)%s*$")
			if s:lower():find("exp") or s:lower():find("xp") then expLine=s; break end
		end
		qExp1.Text=expLine; qExp1.TextColor3=Color3.fromRGB(160,160,190)
		qExp2.Text="---";   qExp2.TextColor3=Color3.fromRGB(160,160,190)
		expCur.Size=UDim2.new(0,0,1,0); expAdd.Size=UDim2.new(0,0,1,0)
	end
	local baseBeli = parseBeli(rawReward)
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
