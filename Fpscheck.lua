local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- cleanup old guis
for _, v in ipairs(lp:WaitForChild("PlayerGui"):GetChildren()) do
	if v.Name == "PerfHUD" or v.Name == "BloxHUD" then v:Destroy() end
end

-- ===== PERF HUD =====

local perfGui = Instance.new("ScreenGui")
perfGui.Name = "PerfHUD"
perfGui.ResetOnSpawn = false
perfGui.Parent = lp:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.Size = UDim2.new(0, 280, 0, 54)
card.Position = UDim2.new(0, 12, 0, 12)
card.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
card.BackgroundTransparency = 0.35
card.BorderSizePixel = 0
card.Active = true
card.Draggable = true
card.Parent = perfGui
Instance.new("UICorner", card).CornerRadius = UDim.new(1, 0)
local cStroke = Instance.new("UIStroke", card)
cStroke.Color = Color3.fromRGB(255, 255, 255)
cStroke.Thickness = 1
cStroke.Transparency = 0.82

local function makeSep(x)
	local f = Instance.new("Frame", card)
	f.Size = UDim2.new(0, 1, 0, 26)
	f.Position = UDim2.new(0, x, 0.5, -13)
	f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	f.BackgroundTransparency = 0.8
	f.BorderSizePixel = 0
end
makeSep(92); makeSep(188)

local function makeSection(tag, cx)
	local tl = Instance.new("TextLabel", card)
	tl.Size = UDim2.new(0, 80, 0, 16)
	tl.Position = UDim2.new(0, cx - 40, 0, 7)
	tl.BackgroundTransparency = 1
	tl.Text = tag
	tl.TextColor3 = Color3.fromRGB(180, 180, 200)
	tl.TextSize = 10
	tl.Font = Enum.Font.GothamBold
	tl.TextXAlignment = Enum.TextXAlignment.Center
	tl.TextStrokeTransparency = 0.6
	tl.TextStrokeColor3 = Color3.new(0, 0, 0)

	local vl = Instance.new("TextLabel", card)
	vl.Size = UDim2.new(0, 80, 0, 26)
	vl.Position = UDim2.new(0, cx - 40, 0, 22)
	vl.BackgroundTransparency = 1
	vl.Text = "---"
	vl.TextSize = 20
	vl.Font = Enum.Font.GothamBold
	vl.TextXAlignment = Enum.TextXAlignment.Center
	vl.TextStrokeTransparency = 0.5
	vl.TextStrokeColor3 = Color3.new(0, 0, 0)
	return vl
end

local lblFps  = makeSection("FPS", 46)
local lblPing = makeSection("PING", 140)
local lblTime = makeSection("TIME", 234)
lblFps.TextColor3  = Color3.fromRGB(74, 222, 128)
lblPing.TextColor3 = Color3.fromRGB(250, 200, 40)
lblTime.TextColor3 = Color3.fromRGB(192, 132, 252)

-- session timer
local startTime = tick()
RunService.Heartbeat:Connect(function()
	local e = math.floor(tick() - startTime)
	if e >= 3600 then
		lblTime.Text = string.format("%d:%02d:%02d", math.floor(e/3600), math.floor((e%3600)/60), e%60)
	else
		lblTime.Text = string.format("%02d:%02d", math.floor(e/60), e%60)
	end
end)

-- fps counter
local frameCount, lastTick = 0, tick()
RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	if now - lastTick >= 0.5 then
		local fps = math.floor(frameCount / (now - lastTick))
		frameCount = 0; lastTick = now
		local c = fps >= 60 and Color3.fromRGB(74, 222, 128)
			or fps >= 30 and Color3.fromRGB(250, 200, 40)
			or Color3.fromRGB(255, 70, 70)
		lblFps.Text = tostring(fps)
		lblFps.TextColor3 = c
	end
end)

-- ping
RunService.Heartbeat:Connect(function()
	local ok, ping = pcall(function() return math.floor(lp:GetNetworkPing() * 1000) end)
	if not ok then return end
	ping = math.max(0, ping)
	local c = ping <= 80 and Color3.fromRGB(74, 222, 128)
		or ping <= 200 and Color3.fromRGB(250, 200, 40)
		or Color3.fromRGB(255, 70, 70)
	lblPing.Text = tostring(ping) .. " ms"
	lblPing.TextColor3 = c
end)

-- ===== HELPERS =====

local function addCommas(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local NO_SHORT = { Beli = true, Fragments = true, Level = true }
local function fmt(v, key)
	if type(v) ~= "number" then return tostring(v or "?") end
	if NO_SHORT[key] then return addCommas(v) end
	if v >= 1e6 then return string.format("%.1fM", v / 1e6)
	elseif v >= 1e3 then return string.format("%.1fK", v / 1e3)
	else return tostring(math.floor(v)) end
end

local function parseNum(str)
	if not str then return nil end
	local s = str:gsub(",", ""):gsub("%s+", "")
	local a, suf = s:match("([%d%.]+)([MmKk])")
	if a then
		local n = tonumber(a) or 0
		if suf:lower() == "m" then return math.floor(n * 1e6) end
		if suf:lower() == "k" then return math.floor(n * 1e3) end
	end
	local p = s:match("(%d+)")
	return p and tonumber(p) or nil
end

local function parseExpBar(str)
	if not str then return nil, nil end
	local s = str:gsub(",", "")
	local cur, max = s:match("(%d+)/(%d+)")
	return cur and tonumber(cur) or nil, max and tonumber(max) or nil
end

local function parseBeli(raw)
	if not raw then return nil end
	local result = nil
	for line in raw:gmatch("[^\n]+") do
		local s = line:match("^%s*(.-)%s*$")
		if s:find("^%$") or s:lower():find("beli") then
			local n = parseNum(s)
			if n and n > 0 then result = n end
		end
	end
	if not result and raw:find("%$") then
		local n = raw:gsub(",", ""):match("%$%s*(%d+)")
		if n then result = tonumber(n) end
	end
	return result
end

local function parseQuestExp(raw)
	if not raw then return nil end
	for line in raw:gmatch("[^\n]+") do
		local s = line:match("^%s*(.-)%s*$")
		if s:lower():find("exp") or s:lower():find("xp") then
			local n = parseNum(s)
			if n and n > 0 then return n end
		end
	end
	return nil
end

-- ===== MAIN HUD =====

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "BloxHUD"
mainGui.ResetOnSpawn = false
mainGui.Parent = lp:WaitForChild("PlayerGui")

local CARD_W = 260
local FULL_H  = 540   -- เพิ่มความสูงเพื่อรองรับปุ่ม ESP
local MINI_H  = 56

-- main card
local pc = Instance.new("Frame")
pc.Size = UDim2.new(0, CARD_W, 0, FULL_H)
pc.Position = UDim2.new(0, 12, 0, 78)
pc.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
pc.BackgroundTransparency = 0.15
pc.BorderSizePixel = 0
pc.Active = true
pc.Draggable = true
pc.ClipsDescendants = true
pc.Parent = mainGui
Instance.new("UICorner", pc).CornerRadius = UDim.new(0, 10)
local pcSt = Instance.new("UIStroke", pc)
pcSt.Color = Color3.fromRGB(255, 255, 255)
pcSt.Thickness = 0.8
pcSt.Transparency = 0.85

-- mini bar (shown when minimised)
local miniBar = Instance.new("Frame", pc)
miniBar.Size = UDim2.new(1, 0, 0, MINI_H)
miniBar.Position = UDim2.new(0, 0, 0, 0)
miniBar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
miniBar.BackgroundTransparency = 0.15
miniBar.BorderSizePixel = 0
miniBar.Visible = false
Instance.new("UICorner", miniBar).CornerRadius = UDim.new(0, 10)
local miniSt = Instance.new("UIStroke", miniBar)
miniSt.Color = Color3.fromRGB(255, 255, 255)
miniSt.Thickness = 0.8
miniSt.Transparency = 0.85

local function mkLabel(parent, txt, ts, tc, font, xa, sz, pos)
	local l = Instance.new("TextLabel", parent)
	l.Size = sz; l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = txt; l.TextColor3 = tc; l.TextSize = ts
	l.Font = font or Enum.Font.Gotham
	l.TextXAlignment = xa or Enum.TextXAlignment.Left
	l.TextStrokeTransparency = 0.4
	l.TextStrokeColor3 = Color3.new(0, 0, 0)
	return l
end

local miniName  = mkLabel(miniBar, "", 13, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(1, -48, 0, 16), UDim2.new(0, 10, 0, 8))
local miniQuest = mkLabel(miniBar, "", 10, Color3.fromRGB(200, 200, 220), Enum.Font.Gotham,
	Enum.TextXAlignment.Left, UDim2.new(1, -48, 0, 14), UDim2.new(0, 10, 0, 28))

-- minimize button
local isMin = false
local minBtn = Instance.new("TextButton", pc)
minBtn.Size = UDim2.new(0, 26, 0, 18)
minBtn.Position = UDim2.new(1, -32, 0, 14)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
minBtn.BorderSizePixel = 0
minBtn.Text = "▲"
minBtn.TextColor3 = Color3.fromRGB(160, 160, 200)
minBtn.TextSize = 9
minBtn.Font = Enum.Font.GothamBold
minBtn.AutoButtonColor = false
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)
local minBtnSt = Instance.new("UIStroke", minBtn)
minBtnSt.Color = Color3.fromRGB(255, 255, 255)
minBtnSt.Thickness = 0.6
minBtnSt.Transparency = 0.8

-- body frame
local body = Instance.new("Frame", pc)
body.Size = UDim2.new(1, 0, 0, FULL_H)
body.Position = UDim2.new(0, 0, 0, 0)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0

local function applyMin()
	if isMin then
		pc.Size = UDim2.new(0, CARD_W, 0, MINI_H)
		pc.BackgroundTransparency = 1
		pcSt.Transparency = 1
		body.Visible = false
		miniBar.Visible = true
		minBtn.Text = "▼"
		minBtn.Position = UDim2.new(1, -32, 0, 19)
	else
		pc.Size = UDim2.new(0, CARD_W, 0, FULL_H)
		pc.BackgroundTransparency = 0.15
		pcSt.Transparency = 0.85
		body.Visible = true
		miniBar.Visible = false
		minBtn.Text = "▲"
		minBtn.Position = UDim2.new(1, -32, 0, 14)
	end
end

minBtn.MouseButton1Click:Connect(function()
	isMin = not isMin
	applyMin()
end)

-- ===== BODY LAYOUT =====

local function bFrame(sz, pos, bg, bgT, r)
	local f = Instance.new("Frame", body)
	f.Size = sz; f.Position = pos
	f.BackgroundColor3 = bg or Color3.fromRGB(10, 10, 18)
	f.BackgroundTransparency = bgT or 0
	f.BorderSizePixel = 0
	if r then Instance.new("UICorner", f).CornerRadius = r end
	return f
end

local function bLabel(txt, ts, tc, font, xa, sz, pos)
	local l = Instance.new("TextLabel", body)
	l.Size = sz; l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = txt; l.TextColor3 = tc; l.TextSize = ts
	l.Font = font or Enum.Font.Gotham
	l.TextXAlignment = xa or Enum.TextXAlignment.Left
	l.TextStrokeTransparency = 0.4
	l.TextStrokeColor3 = Color3.new(0, 0, 0)
	return l
end

local function bDiv(y)
	local d = Instance.new("Frame", body)
	d.Size = UDim2.new(1, -16, 0, 1)
	d.Position = UDim2.new(0, 8, 0, y)
	d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	d.BackgroundTransparency = 0.88
	d.BorderSizePixel = 0
end

-- avatar
local avFrame = bFrame(UDim2.new(0, 50, 0, 50), UDim2.new(0, 10, 0, 10),
	Color3.fromRGB(30, 30, 45), 0, UDim.new(1, 0))
local avSt = Instance.new("UIStroke", avFrame)
avSt.Color = Color3.fromRGB(192, 132, 252)
avSt.Thickness = 1.5
avSt.Transparency = 0.2
local avImg = Instance.new("ImageLabel", avFrame)
avImg.Size = UDim2.new(1, 0, 1, 0)
avImg.BackgroundTransparency = 1
avImg.BorderSizePixel = 0
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1, 0)
local ok, thumb = pcall(function()
	return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)
if ok then avImg.Image = thumb end

bLabel(lp.DisplayName, 15, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(0, 150, 0, 18), UDim2.new(0, 66, 0, 10))
bLabel("@" .. lp.Name, 10, Color3.fromRGB(180, 180, 210), Enum.Font.Gotham,
	Enum.TextXAlignment.Left, UDim2.new(0, 150, 0, 14), UDim2.new(0, 66, 0, 30))

bDiv(68)

-- info stats
local INFO = {
	{ tag = "LEVEL",     key = "Level",     color = Color3.fromRGB(255, 215, 60)  },
	{ tag = "BELI",      key = "Beli",      color = Color3.fromRGB(80, 235, 140)  },
	{ tag = "FRAGMENTS", key = "Fragments", color = Color3.fromRGB(200, 130, 255) },
	{ tag = "RACE",      key = "Race",      color = Color3.fromRGB(210, 150, 255) },
}
local infoLabels = {}
for i, s in ipairs(INFO) do
	local col = (i == 1 or i == 3) and 0 or 1
	local row = (i <= 2) and 0 or 1
	local x = 10 + col * 122
	local y = 76 + row * 28
	bLabel(s.tag, 9, Color3.fromRGB(180, 180, 210), Enum.Font.GothamBold,
		Enum.TextXAlignment.Left, UDim2.new(0, 114, 0, 11), UDim2.new(0, x, 0, y))
	infoLabels[s.key] = bLabel("...", 14, s.color, Enum.Font.GothamBold,
		Enum.TextXAlignment.Left, UDim2.new(0, 114, 0, 15), UDim2.new(0, x, 0, y + 12))
end
local vSep = Instance.new("Frame", body)
vSep.Size = UDim2.new(0, 1, 0, 52)
vSep.Position = UDim2.new(0, 126, 0, 74)
vSep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
vSep.BackgroundTransparency = 0.88
vSep.BorderSizePixel = 0

bDiv(136)

-- combat stats
bLabel("COMBAT STATS", 10, Color3.fromRGB(200, 200, 230), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(1, -16, 0, 12), UDim2.new(0, 10, 0, 142))

local COMBAT = {
	{ tag = "Melee",       icon = "👊", color = Color3.fromRGB(255, 175, 90)  },
	{ tag = "Defense",     icon = "🛡",  color = Color3.fromRGB(120, 190, 255) },
	{ tag = "Sword",       icon = "⚔",  color = Color3.fromRGB(225, 190, 255) },
	{ tag = "Gun",         icon = "🔫", color = Color3.fromRGB(90, 235, 150)  },
	{ tag = "Demon Fruit", icon = "🍎", color = Color3.fromRGB(255, 120, 150) },
}
local combatLabels = {}
for i, s in ipairs(COMBAT) do
	local y = 158 + (i - 1) * 22
	local ico = Instance.new("TextLabel", body)
	ico.Size = UDim2.new(0, 20, 0, 20); ico.Position = UDim2.new(0, 8, 0, y)
	ico.BackgroundTransparency = 1; ico.Text = s.icon; ico.TextSize = 14
	ico.Font = Enum.Font.Gotham; ico.TextXAlignment = Enum.TextXAlignment.Center
	ico.TextStrokeTransparency = 1
	bLabel(s.tag, 12, Color3.fromRGB(220, 220, 240), Enum.Font.GothamBold,
		Enum.TextXAlignment.Left, UDim2.new(0, 100, 0, 20), UDim2.new(0, 30, 0, y))
	local barBg = bFrame(UDim2.new(0, 95, 0, 4), UDim2.new(0, 30, 0, y + 17),
		Color3.fromRGB(50, 50, 70), 0, UDim.new(1, 0))
	local barFill = Instance.new("Frame", barBg)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = s.color
	barFill.BorderSizePixel = 0
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
	local vl = bLabel("...", 12, s.color, Enum.Font.GothamBold,
		Enum.TextXAlignment.Right, UDim2.new(0, 50, 0, 20), UDim2.new(0, 200, 0, y))
	combatLabels[s.tag] = { label = vl, bar = barFill }
end

-- quest section
local QY = 278
bDiv(QY)
bLabel("📋  QUEST", 10, Color3.fromRGB(255, 200, 60), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(0, 120, 0, 16), UDim2.new(0, 8, 0, QY + 10))
bDiv(QY + 30)
bLabel("QUEST NAME", 9, Color3.fromRGB(160, 160, 190), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(1, -16, 0, 11), UDim2.new(0, 8, 0, QY + 38))

local qTitle = Instance.new("TextLabel", body)
qTitle.Size = UDim2.new(1, -16, 0, 26); qTitle.Position = UDim2.new(0, 8, 0, QY + 50)
qTitle.BackgroundTransparency = 1; qTitle.Text = "No active quest"
qTitle.TextColor3 = Color3.fromRGB(160, 160, 190); qTitle.TextSize = 13
qTitle.Font = Enum.Font.GothamBold; qTitle.TextXAlignment = Enum.TextXAlignment.Left
qTitle.TextWrapped = true; qTitle.TextStrokeTransparency = 0.4
qTitle.TextStrokeColor3 = Color3.new(0, 0, 0)

bDiv(QY + 80)
bLabel("REWARD", 9, Color3.fromRGB(160, 160, 190), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(1, -16, 0, 11), UDim2.new(0, 8, 0, QY + 90))

-- exp rows
bLabel("⚡", 13, Color3.fromRGB(255, 255, 255), Enum.Font.Gotham,
	Enum.TextXAlignment.Center, UDim2.new(0, 18, 0, 16), UDim2.new(0, 8, 0, QY + 104))
local qExp1 = bLabel("---", 11, Color3.fromRGB(74, 222, 128), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(1, -32, 0, 16), UDim2.new(0, 28, 0, QY + 104))

bLabel("⚡×2", 11, Color3.fromRGB(255, 215, 60), Enum.Font.GothamBold,
	Enum.TextXAlignment.Center, UDim2.new(0, 28, 0, 16), UDim2.new(0, 8, 0, QY + 122))
local qExp2 = bLabel("---", 11, Color3.fromRGB(255, 215, 60), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(1, -40, 0, 16), UDim2.new(0, 38, 0, QY + 122))

-- exp progress bar
local expBg  = bFrame(UDim2.new(1, -16, 0, 4), UDim2.new(0, 8, 0, QY + 140),
	Color3.fromRGB(40, 40, 60), 0, UDim.new(1, 0))
local expCur = Instance.new("Frame", expBg)
expCur.Size = UDim2.new(0, 0, 1, 0)
expCur.BackgroundColor3 = Color3.fromRGB(74, 222, 128)
expCur.BorderSizePixel = 0
Instance.new("UICorner", expCur).CornerRadius = UDim.new(1, 0)
local expAdd = Instance.new("Frame", expBg)
expAdd.Size = UDim2.new(0, 0, 1, 0)
expAdd.BackgroundColor3 = Color3.fromRGB(255, 215, 60)
expAdd.BackgroundTransparency = 0.4
expAdd.BorderSizePixel = 0
Instance.new("UICorner", expAdd).CornerRadius = UDim.new(1, 0)

bDiv(QY + 148)

-- beli rows
bLabel("💰", 13, Color3.fromRGB(255, 255, 255), Enum.Font.Gotham,
	Enum.TextXAlignment.Center, UDim2.new(0, 18, 0, 16), UDim2.new(0, 8, 0, QY + 156))
local qBeli1 = bLabel("---", 11, Color3.fromRGB(80, 235, 140), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(1, -32, 0, 16), UDim2.new(0, 28, 0, QY + 156))

bLabel("💰×2", 11, Color3.fromRGB(255, 200, 60), Enum.Font.GothamBold,
	Enum.TextXAlignment.Center, UDim2.new(0, 28, 0, 16), UDim2.new(0, 8, 0, QY + 174))
local qBeli2 = bLabel("---", 11, Color3.fromRGB(255, 200, 60), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(1, -40, 0, 16), UDim2.new(0, 38, 0, QY + 174))

-- ===== ESP TOGGLE BUTTON =====

local ESP_Y = QY + 200
bDiv(ESP_Y)

bLabel("👁  ESP", 10, Color3.fromRGB(255, 100, 100), Enum.Font.GothamBold,
	Enum.TextXAlignment.Left, UDim2.new(0, 60, 0, 16), UDim2.new(0, 8, 0, ESP_Y + 10))

local espEnabled = true

local espBtn = Instance.new("TextButton", body)
espBtn.Size = UDim2.new(0, 80, 0, 22)
espBtn.Position = UDim2.new(1, -92, 0, ESP_Y + 8)
espBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
espBtn.BorderSizePixel = 0
espBtn.Text = "ON"
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 11
espBtn.Font = Enum.Font.GothamBold
espBtn.AutoButtonColor = false
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 4)
local espBtnSt = Instance.new("UIStroke", espBtn)
espBtnSt.Color = Color3.fromRGB(255, 255, 255)
espBtnSt.Thickness = 0.6
espBtnSt.Transparency = 0.7

-- ===== ESP SYSTEM =====

-- สีและค่า Highlight
local ESP_FILL_COLOR    = Color3.fromRGB(255, 60, 60)   -- สีเติมมอน (แดง)
local ESP_OUTLINE_COLOR = Color3.fromRGB(255, 140, 140) -- สีขอบมอน
local SELF_FILL_COLOR   = Color3.fromRGB(60, 220, 120)  -- สีเติมตัวเรา (เขียว)
local SELF_OUTLINE_COLOR= Color3.fromRGB(140, 255, 180) -- สีขอบตัวเรา
local BILL_DIST_COLOR   = Color3.fromRGB(255, 200, 60)  -- สีแสดงระยะทาง

local espObjects = {}  -- { highlight, billboard, model }

-- ลบ ESP ของมอนตัวนั้น
local function removeESP(model)
	if espObjects[model] then
		if espObjects[model].highlight and espObjects[model].highlight.Parent then
			espObjects[model].highlight:Destroy()
		end
		if espObjects[model].billboard and espObjects[model].billboard.Parent then
			espObjects[model].billboard:Destroy()
		end
		espObjects[model] = nil
	end
end

-- สร้าง Billboard แสดงชื่อ + ระยะห่าง (ไม่มีกรอบ/พื้นหลัง)
local function makeBillboard(model)
	local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
	if not root then return nil, nil end

	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_Billboard"
	bb.Size = UDim2.new(0, 140, 0, 36)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = root
	bb.Parent = root

	local nameLabel = Instance.new("TextLabel", bb)
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = model.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextStrokeTransparency = 0      -- shadow เข้มเพื่อให้อ่านได้โดยไม่มีกรอบ
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

	local distLabel = Instance.new("TextLabel", bb)
	distLabel.Name = "DistLabel"
	distLabel.Size = UDim2.new(1, 0, 0, 14)
	distLabel.Position = UDim2.new(0, 0, 0, 20)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "? studs"
	distLabel.TextColor3 = BILL_DIST_COLOR
	distLabel.TextSize = 10
	distLabel.Font = Enum.Font.Gotham
	distLabel.TextXAlignment = Enum.TextXAlignment.Center
	distLabel.TextStrokeTransparency = 0
	distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

	return bb, distLabel
end

-- สร้าง Billboard ชื่อตัวเรา (ไม่มีกรอบ สีเขียว)
local selfBillboard = nil
local function makeSelfBillboard(char)
	if selfBillboard and selfBillboard.Parent then selfBillboard:Destroy() end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_SelfBillboard"
	bb.Size = UDim2.new(0, 140, 0, 18)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = root
	bb.Parent = root

	local nameLabel = Instance.new("TextLabel", bb)
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = lp.DisplayName
	nameLabel.TextColor3 = SELF_OUTLINE_COLOR
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

	selfBillboard = bb
end

-- สร้าง Highlight + Billboard ให้มอนหนึ่งตัว
local function addESP(model)
	if espObjects[model] then return end

	-- รอ Humanoid โหลดเสร็จ (timeout 3 วิ)
	local hum = model:FindFirstChildWhichIsA("Humanoid")
	if not hum then
		local deadline = tick() + 3
		repeat task.wait(0.05) until model:FindFirstChildWhichIsA("Humanoid") or tick() > deadline
		hum = model:FindFirstChildWhichIsA("Humanoid")
	end
	if not hum then return end
	-- ตรวจอีกครั้งว่ายังไม่ถูก add ระหว่างรอ
	if espObjects[model] then return end

	local hl = Instance.new("Highlight")
	hl.Name = "ESP_Highlight"
	hl.FillColor = ESP_FILL_COLOR
	hl.OutlineColor = ESP_OUTLINE_COLOR
	hl.FillTransparency = 0.55
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = model
	hl.Parent = model

	local bb, distLabel = makeBillboard(model)

	-- เก็บ distLabel ตรงๆ เพื่อใช้ใน Heartbeat โดยไม่ต้อง Find
	espObjects[model] = { highlight = hl, billboard = bb, distLabel = distLabel }

	model.AncestryChanged:Connect(function()
		if not model:IsDescendantOf(game) then
			removeESP(model)
		end
	end)
end

-- Highlight ตัวเราเอง — รับ char ตรงเพื่อไม่ให้อ่าน lp.Character ผิดตัว
local selfHL = nil
local function applySelfHighlight(char)
	if selfHL and selfHL.Parent then selfHL:Destroy() end
	char = char or lp.Character
	if not char then return end
	local hl = Instance.new("Highlight")
	hl.Name = "ESP_SelfHighlight"
	hl.FillColor = SELF_FILL_COLOR
	hl.OutlineColor = SELF_OUTLINE_COLOR
	hl.FillTransparency = 0.65
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.Adornee = char
	hl.Parent = char
	selfHL = hl
	makeSelfBillboard(char)
end

lp.CharacterAdded:Connect(function(char)
	task.wait(0.5)  -- รอ character โหลดเสร็จก่อน
	if espEnabled then applySelfHighlight(char) end
end)

-- สแกนมอนทั้งหมดที่มีอยู่แล้ว
local function scanEnemies()
	local enemies = workspace:FindFirstChild("Enemies")
	if not enemies then return end
	for _, model in ipairs(enemies:GetChildren()) do
		if model:IsA("Model") and espEnabled then
			addESP(model)
		end
	end
end

-- ฟังมอนใหม่ที่เกิด
local function startESPListener()
	local enemies = workspace:WaitForChild("Enemies", 10)
	if not enemies then return end

	enemies.ChildAdded:Connect(function(model)
		if espEnabled and model:IsA("Model") then
			task.spawn(addESP, model)  -- spawn แยก thread เพื่อไม่ block event และรอ Humanoid ได้
		end
	end)

	enemies.ChildRemoved:Connect(function(model)
		removeESP(model)
	end)

	scanEnemies()
end

-- ลบ ESP ทั้งหมด
local function clearAllESP()
	for model, _ in pairs(espObjects) do
		removeESP(model)
	end
	if selfHL and selfHL.Parent then
		selfHL:Destroy()
		selfHL = nil
	end
	if selfBillboard and selfBillboard.Parent then
		selfBillboard:Destroy()
		selfBillboard = nil
	end
end

-- Toggle ESP
espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	if espEnabled then
		espBtn.Text = "ON"
		espBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
		scanEnemies()
		if lp.Character then applySelfHighlight(lp.Character) end
	else
		espBtn.Text = "OFF"
		espBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		clearAllESP()
	end
end)

-- อัปเดตระยะห่างทุก heartbeat — ใช้ distLabel ที่เก็บไว้โดยตรง ไม่ต้อง Find
RunService.Heartbeat:Connect(function()
	if not espEnabled then return end
	local char = lp.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local myPos = root.Position

	for model, data in pairs(espObjects) do
		-- ถ้า model หรือหายออกจาก workspace ให้ลบออก
		if not model or not model.Parent then
			espObjects[model] = nil
			continue
		end

		local distLabel = data.distLabel
		if distLabel and distLabel.Parent then
			local enemyRoot = model:FindFirstChild("HumanoidRootPart")
			if enemyRoot then
				local dist = math.floor((enemyRoot.Position - myPos).Magnitude)
				distLabel.Text = tostring(dist) .. " studs"
				if dist <= 30 then
					distLabel.TextColor3 = Color3.fromRGB(255, 80, 80)    -- แดง = ใกล้มาก
				elseif dist <= 80 then
					distLabel.TextColor3 = Color3.fromRGB(255, 200, 60)   -- เหลือง = กลาง
				else
					distLabel.TextColor3 = Color3.fromRGB(160, 220, 255)  -- ฟ้า = ไกล
				end
			end
		end
	end
end)

-- เริ่มทำงาน
task.spawn(startESPListener)
if lp.Character then
	task.spawn(function()
		task.wait(0.5)
		applySelfHighlight(lp.Character)
	end)
end

-- ===== DATA UPDATER =====

local MAX_STAT = 2550

local function updateData()
	local data = lp:FindFirstChild("Data")
	if not data then return end
	for _, k in ipairs({ "Level", "Beli", "Fragments", "Race" }) do
		local node = data:FindFirstChild(k)
		if node and infoLabels[k] then
			infoLabels[k].Text = fmt(node.Value, k)
		end
	end
	local lvNode = data:FindFirstChild("Level")
	if lvNode then
		miniName.Text = lp.DisplayName .. "  |  Lv. " .. addCommas(lvNode.Value or 0)
	end
	local stats = data:FindFirstChild("Stats")
	if not stats then return end
	for _, s in ipairs(COMBAT) do
		local node = stats:FindFirstChild(s.tag)
		if node then
			local lvN = node:FindFirstChild("Level")
			if lvN and combatLabels[s.tag] then
				local v = lvN.Value or 0
				combatLabels[s.tag].label.Text = tostring(v)
				combatLabels[s.tag].bar.Size = UDim2.new(math.clamp(v / MAX_STAT, 0, 1), 0, 1, 0)
			end
		end
	end
end

task.spawn(function()
	local data = lp:WaitForChild("Data", 10)
	if not data then return end
	updateData()
	local function watch(obj) if obj then obj.Changed:Connect(updateData) end end
	for _, k in ipairs({ "Level", "Beli", "Fragments", "Race" }) do
		watch(data:WaitForChild(k, 5))
	end
	local stats = data:WaitForChild("Stats", 5)
	if stats then
		for _, s in ipairs(COMBAT) do
			local node = stats:WaitForChild(s.tag, 5)
			if node then watch(node:WaitForChild("Level", 5)) end
		end
	end
end)

-- ===== QUEST UPDATER =====

local function updateQuest()
	local active = false
	local rawTitle, rawReward = "", ""
	pcall(function()
		local qf = lp.PlayerGui.Main.Quest
		active = qf.Visible
		if active then
			rawTitle  = qf.Container.QuestTitle.Title.ContentText  or ""
			rawReward = qf.Container.QuestReward.Title.ContentText or ""
		end
	end)

	if not active or rawTitle == "" then
		miniQuest.Text = "No active quest"
		qTitle.Text = "No active quest"
		qTitle.TextColor3 = Color3.fromRGB(160, 160, 190)
		qExp1.Text = "---"; qExp2.Text = "---"
		qBeli1.Text = "---"; qBeli2.Text = "---"
		expCur.Size = UDim2.new(0, 0, 1, 0)
		expAdd.Size = UDim2.new(0, 0, 1, 0)
		expCur.BackgroundColor3 = Color3.fromRGB(74, 222, 128)
		return
	end

	qTitle.Text = rawTitle
	qTitle.TextColor3 = Color3.fromRGB(255, 255, 255)

	local curExp, needExp = nil, nil
	pcall(function() curExp, needExp = parseExpBar(lp.PlayerGui.Main.Level.Exp.ContentText) end)

	local curLv, curBeli = 0, 0
	pcall(function() curLv   = lp.Data.Level.Value or 0 end)
	pcall(function() curBeli = lp.Data.Beli.Value  or 0 end)

	-- exp
	local baseExp = parseQuestExp(rawReward)
	if baseExp and curExp and needExp and needExp > 0 then
		local e1 = baseExp
		local e2 = baseExp * 2
		local a1 = curExp + e1
		local a2 = curExp + e2

		local pctCur = math.clamp(curExp / needExp, 0, 1)
		local pctAfter = math.clamp(a1 / needExp, 0, 1)
		expCur.Size = UDim2.new(pctCur, 0, 1, 0)
		expAdd.Size = UDim2.new(pctAfter - pctCur, 0, 1, 0)
		expAdd.Position = UDim2.new(pctCur, 0, 0, 0)

		if a1 >= needExp then
			qExp1.Text = string.format("+%s  LevelUP!  Lv.%d → Lv.%d", addCommas(e1), curLv, curLv + 1)
			qExp1.TextColor3 = Color3.fromRGB(255, 215, 60)
			expCur.BackgroundColor3 = Color3.fromRGB(255, 215, 60)
		else
			local rem1 = needExp - a1
			local need1 = math.ceil(rem1 / e1)
			qExp1.Text = string.format("+%s  →  %s / %s  (%d left)", addCommas(e1), addCommas(a1), addCommas(needExp), need1)
			qExp1.TextColor3 = Color3.fromRGB(74, 222, 128)
			expCur.BackgroundColor3 = Color3.fromRGB(74, 222, 128)
		end

		if a2 >= needExp then
			qExp2.Text = string.format("+%s  LevelUP!  Lv.%d → Lv.%d", addCommas(e2), curLv, curLv + 1)
		else
			local rem2 = needExp - a2
			local need2 = math.ceil(rem2 / e2)
			qExp2.Text = string.format("+%s  →  %s / %s  (%d left)", addCommas(e2), addCommas(a2), addCommas(needExp), need2)
		end
		qExp2.TextColor3 = Color3.fromRGB(255, 215, 60)

		local pct = math.floor((a1 / needExp) * 100)
		miniQuest.Text = rawTitle .. string.format("  |  EXP %d%%", math.min(pct, 100))
	else
		local expLine = "---"
		for line in rawReward:gmatch("[^\n]+") do
			local s = line:match("^%s*(.-)%s*$")
			if s:lower():find("exp") or s:lower():find("xp") then expLine = s; break end
		end
		qExp1.Text = expLine; qExp1.TextColor3 = Color3.fromRGB(160, 160, 190)
		qExp2.Text = "---";   qExp2.TextColor3 = Color3.fromRGB(160, 160, 190)
		expCur.Size = UDim2.new(0, 0, 1, 0)
		expAdd.Size = UDim2.new(0, 0, 1, 0)
	end

	-- beli
	local baseBeli = parseBeli(rawReward)
	if baseBeli then
		qBeli1.Text = string.format("+%s  →  %s", addCommas(baseBeli), addCommas(curBeli + baseBeli))
		qBeli1.TextColor3 = Color3.fromRGB(80, 235, 140)
		qBeli2.Text = string.format("+%s  →  %s", addCommas(baseBeli * 2), addCommas(curBeli + baseBeli * 2))
		qBeli2.TextColor3 = Color3.fromRGB(255, 200, 60)
	else
		qBeli1.Text = "---"; qBeli1.TextColor3 = Color3.fromRGB(160, 160, 190)
		qBeli2.Text = "---"; qBeli2.TextColor3 = Color3.fromRGB(160, 160, 190)
	end
end

task.spawn(function()
	while true do
		pcall(updateQuest)
		task.wait(1)
	end
end)
