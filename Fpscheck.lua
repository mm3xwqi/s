-- [ Example Config
-- getenv = function() return {
--    ["Lock Fps"] = { ["Enabled"] = true, ["FPS"] = 25 },
--    ["White Screen"] = true,
-- } end ]
local Players = game:GetService("Players")
local StatsService = game:GetService("Stats")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Teams = pcall(function() return game:GetService("Teams") end) and game:GetService("Teams") or nil

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "IntegratedStatusHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

-- ================== Global Settings ==================
local MAX_PLAYERS = 12
local COMBAT_CAP = 2800
local FPS_CAP = 60

-- ================== Data Helpers ==================
local function getValueByPaths(...)
	for _, path in ipairs({...}) do
		local obj = player
		for part in string.gmatch(path, "[^%.]+") do
			if not obj then break end
			obj = obj:FindFirstChild(part)
		end
		if obj then
			if obj:IsA("IntValue") or obj:IsA("NumberValue") then return obj.Value
			elseif obj:IsA("StringValue") then return obj.Value end
		end
	end
	return nil
end

local STAT_PATHS = {
	Level = {"leaderstats.Level", "leaderstats.Lv.", "Data.Level"},
	Beli = {"leaderstats.Beli", "leaderstats.Money", "Data.Beli"},
	Fragments = {"leaderstats.Fragments", "leaderstats.Fragment", "Data.Fragments"},
	Race = {"leaderstats.Race", "Data.Race"},
	Melee = {"leaderstats.Melee", "Data.Stats.Melee.Level"},
	Defense = {"leaderstats.Defense", "Data.Stats.Defense.Level"},
	Sword = {"leaderstats.Sword", "Data.Stats.Sword.Level"},
	Gun = {"leaderstats.Gun", "Data.Stats.Gun.Level"},
	["Blox Fruit"] = {"leaderstats.Blox Fruit", "leaderstats.Demon Fruit", "Data.Stats.Blox Fruit.Level", "Data.Stats.Demon Fruit.Level"},
}

local function getStat(key)
	local paths = STAT_PATHS[key]
	if not paths then
		return getValueByPaths("leaderstats."..key, "Data."..key)
	end
	for _, path in ipairs(paths) do
		local val = getValueByPaths(path)
		if val ~= nil then return val end
	end
	return nil
end

local function safeStat(key) return getStat(key) or "N/A" end

local function formatVal(v, key)
	if type(v) ~= "number" then return tostring(v or "?") end
	local shortKeys = {Beli = true, Fragments = true, Level = true}
	if shortKeys[key] then
		return tostring(math.floor(v)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
	end
	if v >= 1e6 then return string.format("%.1fM", v/1e6)
	elseif v >= 1e3 then return string.format("%.1fK", v/1e3)
	else return tostring(math.floor(v)) end
end

-- ================== Main Panel ==================
local fullPanel = Instance.new("Frame")
fullPanel.Name = "FullPanel"
fullPanel.Size = UDim2.new(0, 520, 0, 430)   -- กลับมา 430 ตามเดิม (ไม่มี Inventory)
fullPanel.Position = UDim2.new(0.02, 0, 0.08, 0)
fullPanel.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
fullPanel.BackgroundTransparency = 0.4
fullPanel.BorderSizePixel = 0
fullPanel.Active = true
fullPanel.ClipsDescendants = true
fullPanel.Visible = true
fullPanel.Parent = gui

local corner = Instance.new("UICorner", fullPanel)
corner.CornerRadius = UDim.new(0, 18)

local shadow = Instance.new("Frame", fullPanel)
shadow.Size = UDim2.new(1, 16, 1, 16)
shadow.Position = UDim2.new(0, -8, 0, -8)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.75
shadow.BorderSizePixel = 0
shadow.ZIndex = -1
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 22)

local bgGrad = Instance.new("UIGradient", fullPanel)
bgGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 38)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 28))
}
bgGrad.Rotation = 135

-- ================== Mini Panel ==================
local miniPanel = Instance.new("Frame")
miniPanel.Name = "MiniPanel"
miniPanel.Size = UDim2.new(0, 520, 0, 70)
miniPanel.Position = fullPanel.Position
miniPanel.BackgroundColor3 = fullPanel.BackgroundColor3
miniPanel.BackgroundTransparency = 0.4
miniPanel.BorderSizePixel = 0
miniPanel.ClipsDescendants = true
miniPanel.Visible = false
miniPanel.Parent = gui

Instance.new("UICorner", miniPanel).CornerRadius = UDim.new(0, 18)
miniPanel.BackgroundColor3 = fullPanel.BackgroundColor3
miniPanel.BackgroundTransparency = 0.4
local miniGrad = bgGrad:Clone()
miniGrad.Parent = miniPanel

-- ================== Collapse / Expand Buttons ==================
local function makeToggleBtn(parent, txt, yPos, size)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0, size, 0, size-8)
	btn.Position = UDim2.new(1, -size-6, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(30,30,48)
	btn.BorderSizePixel = 0
	btn.Text = txt
	btn.TextColor3 = Color3.fromRGB(160,160,200)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(255,255,255)
	return btn
end

local collapseBtn = makeToggleBtn(fullPanel, "▲", 12, 30)
local expandBtn = makeToggleBtn(miniPanel, "▼", 8, 30)

local isMini = false
local function setView(miniMode)
	isMini = miniMode
	fullPanel.Visible = not miniMode
	miniPanel.Visible = miniMode
end
collapseBtn.MouseButton1Click:Connect(function() setView(true) end)
expandBtn.MouseButton1Click:Connect(function() setView(false) end)

-- ================== Draggable ==================
local dragging = false
local dragStart, startPos
fullPanel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = fullPanel.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		fullPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		miniPanel.Position = fullPanel.Position
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ================== Full Panel Content ==================
-- Title Bar
local titleBar = Instance.new("Frame", fullPanel)
titleBar.Size = UDim2.new(1, 0, 0, 68)
titleBar.BackgroundTransparency = 1

local avatar = Instance.new("ImageLabel", titleBar)
avatar.Size = UDim2.new(0, 50, 0, 50)
avatar.Position = UDim2.new(0, 10, 0, 10)
avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
avatar.BackgroundTransparency = 0.4
avatar.BorderSizePixel = 0
Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 25)

task.spawn(function()
	local ok, thumb = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if ok and thumb then avatar.Image = thumb end
end)

local charLabel = Instance.new("TextLabel", titleBar)
charLabel.Size = UDim2.new(1, -110, 0, 22)
charLabel.Position = UDim2.new(0, 70, 0, 10)
charLabel.BackgroundTransparency = 1
charLabel.Font = Enum.Font.GothamBold
charLabel.TextSize = 18
charLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
charLabel.Text = "Loading..."
charLabel.TextXAlignment = Enum.TextXAlignment.Left

local lvlLabel = Instance.new("TextLabel", titleBar)
lvlLabel.Size = UDim2.new(1, -110, 0, 18)
lvlLabel.Position = UDim2.new(0, 70, 0, 32)
lvlLabel.BackgroundTransparency = 1
lvlLabel.Font = Enum.Font.GothamBold
lvlLabel.TextSize = 14
lvlLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
lvlLabel.Text = "⭐ Lv.0"
lvlLabel.TextXAlignment = Enum.TextXAlignment.Left

local onlineDot = Instance.new("Frame", titleBar)
onlineDot.Size = UDim2.new(0, 8, 0, 8)
onlineDot.Position = UDim2.new(0, 70, 0, 54)
onlineDot.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
onlineDot.BorderSizePixel = 0
Instance.new("UICorner", onlineDot).CornerRadius = UDim.new(1, 0)

local onlineLabel = Instance.new("TextLabel", titleBar)
onlineLabel.Size = UDim2.new(0, 50, 0, 14)
onlineLabel.Position = UDim2.new(0, 84, 0, 51)
onlineLabel.BackgroundTransparency = 1
onlineLabel.Font = Enum.Font.Gotham
onlineLabel.TextSize = 11
onlineLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
onlineLabel.Text = "Online"
onlineLabel.TextXAlignment = Enum.TextXAlignment.Left

local underline = Instance.new("Frame", titleBar)
underline.Size = UDim2.new(1, -20, 0, 1)
underline.Position = UDim2.new(0, 10, 0, 67)
underline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
underline.BackgroundTransparency = 0.85
underline.BorderSizePixel = 0

-- ================== Cards Area ==================
local content = Instance.new("Frame", fullPanel)
content.Size = UDim2.new(1, -20, 0, 210)
content.Position = UDim2.new(0, 10, 0, 76)
content.BackgroundTransparency = 1

local function createCard(parent, x, y, icon, title, defaultValue, isCombat)
	local card = Instance.new("Frame", parent)
	card.Size = UDim2.new(0, 240, 0, 40)
	card.Position = UDim2.new(0, x, 0, y)
	card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	card.BackgroundTransparency = 0.5
	card.BorderSizePixel = 0
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 9)

	local iconLbl = Instance.new("TextLabel", card)
	iconLbl.Size = UDim2.new(0, 28, 1, 0)
	iconLbl.Position = UDim2.new(0, 4, 0, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = Enum.Font.Gotham
	iconLbl.TextSize = 20
	iconLbl.TextColor3 = Color3.fromRGB(220, 220, 255)
	iconLbl.Text = icon
	iconLbl.TextXAlignment = Enum.TextXAlignment.Center

	local titleLbl = Instance.new("TextLabel", card)
	titleLbl.Size = UDim2.new(0, 80, 0, 16)
	titleLbl.Position = UDim2.new(0, 36, 0, 4)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Font = Enum.Font.Gotham
	titleLbl.TextSize = 12
	titleLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	titleLbl.Text = title
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left

	local valueLbl = Instance.new("TextLabel", card)
	valueLbl.Size = UDim2.new(1, -40, 0, 18)
	valueLbl.Position = UDim2.new(0, 36, 0, 18)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.TextSize = 14
	valueLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLbl.Text = defaultValue
	valueLbl.TextXAlignment = Enum.TextXAlignment.Left
	valueLbl.TextTruncate = Enum.TextTruncate.AtEnd

	if isCombat then
		local bar = Instance.new("Frame", card)
		bar.Size = UDim2.new(1, -40, 0, 4)
		bar.Position = UDim2.new(0, 36, 0, 36)
		bar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		bar.BorderSizePixel = 0
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
		local fill = Instance.new("Frame", bar)
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
		fill.BorderSizePixel = 0
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
		return {card = card, icon = iconLbl, title = titleLbl, value = valueLbl, barFill = fill}
	end
	return {card = card, icon = iconLbl, title = titleLbl, value = valueLbl}
end

local leftCards = {}
local rightCards = {}
local yPos = 0
local leftX = 4
local rightX = 254

leftCards.Beli = createCard(content, leftX, yPos, "💰", "Beli", "0")
yPos += 42
leftCards.Frag = createCard(content, leftX, yPos, "💎", "Fragments", "0")
yPos += 42
leftCards.Team = createCard(content, leftX, yPos, "🏴‍☠️", "Team", "N/A")
yPos += 42
leftCards.Players = createCard(content, leftX, yPos, "👥", "Players", "0/0")
yPos += 42
leftCards.Time = createCard(content, leftX, yPos, "⏱️", "Runtime", "00:00:00")

yPos = 0
rightCards.Melee = createCard(content, rightX, yPos, "👊", "Melee", "0", true)
yPos += 42
rightCards.Defense = createCard(content, rightX, yPos, "🛡️", "Defense", "0", true)
yPos += 42
rightCards.Sword = createCard(content, rightX, yPos, "⚔️", "Sword", "0", true)
yPos += 42
rightCards.Gun = createCard(content, rightX, yPos, "🔫", "Gun", "0", true)
yPos += 42
rightCards.Fruit = createCard(content, rightX, yPos, "🍈", "Blox Fruit", "0", true)

local combatColors = {
	Melee = Color3.fromRGB(255, 175, 90),
	Defense = Color3.fromRGB(120, 190, 255),
	Sword = Color3.fromRGB(225, 190, 255),
	Gun = Color3.fromRGB(90, 235, 150),
	["Blox Fruit"] = Color3.fromRGB(255, 120, 150),
}
for name, card in pairs(rightCards) do
	if card.barFill then
		card.barFill.BackgroundColor3 = combatColors[name] or Color3.fromRGB(200,200,200)
	end
end

-- ================== Player Count Bar ==================
local pcBarY = 76 + 210 + 8
local pcBar = Instance.new("Frame", fullPanel)
pcBar.Size = UDim2.new(1, -20, 0, 40)
pcBar.Position = UDim2.new(0, 10, 0, pcBarY)
pcBar.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
pcBar.BackgroundTransparency = 0.3
pcBar.BorderSizePixel = 0
Instance.new("UICorner", pcBar).CornerRadius = UDim.new(0, 10)

local pcBarStroke = Instance.new("UIStroke", pcBar)
pcBarStroke.Color = Color3.fromRGB(255,255,255)
pcBarStroke.Thickness = 1
pcBarStroke.Transparency = 0.85

local pcTag = Instance.new("TextLabel", pcBar)
pcTag.Size = UDim2.new(0, 70, 0, 14)
pcTag.Position = UDim2.new(0, 8, 0, 4)
pcTag.BackgroundTransparency = 1
pcTag.Text = "👥 PLAYERS"
pcTag.TextColor3 = Color3.fromRGB(180, 180, 200)
pcTag.TextSize = 11
pcTag.Font = Enum.Font.GothamBold
pcTag.TextXAlignment = Enum.TextXAlignment.Left

local pcCount = Instance.new("TextLabel", pcBar)
pcCount.Size = UDim2.new(0, 80, 0, 14)
pcCount.Position = UDim2.new(1, -88, 0, 4)
pcCount.BackgroundTransparency = 1
pcCount.Text = "? / "..MAX_PLAYERS
pcCount.TextColor3 = Color3.fromRGB(100, 200, 255)
pcCount.TextSize = 13
pcCount.Font = Enum.Font.GothamBold
pcCount.TextXAlignment = Enum.TextXAlignment.Right

local barBg = Instance.new("Frame", pcBar)
barBg.Size = UDim2.new(1, -16, 0, 6)
barBg.Position = UDim2.new(0, 8, 1, -10)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
barBg.BorderSizePixel = 0
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(74, 222, 128)
barFill.BorderSizePixel = 0
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local fullBadge = Instance.new("TextLabel", pcBar)
fullBadge.Size = UDim2.new(0, 40, 0, 14)
fullBadge.Position = UDim2.new(0, 8, 0, 3)
fullBadge.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
fullBadge.BackgroundTransparency = 0.25
fullBadge.Text = "FULL"
fullBadge.TextColor3 = Color3.fromRGB(255, 220, 220)
fullBadge.TextSize = 9
fullBadge.Font = Enum.Font.GothamBold
fullBadge.TextXAlignment = Enum.TextXAlignment.Center
fullBadge.Visible = false
fullBadge.BorderSizePixel = 0
Instance.new("UICorner", fullBadge).CornerRadius = UDim.new(0, 4)

-- ================== Teams Row ==================
local teamsY = pcBarY + 40 + 6
local teamsRow = Instance.new("Frame", fullPanel)
teamsRow.Size = UDim2.new(1, -20, 0, 52)
teamsRow.Position = UDim2.new(0, 10, 0, teamsY)
teamsRow.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
teamsRow.BackgroundTransparency = 0.3
teamsRow.BorderSizePixel = 0
teamsRow.Visible = false
Instance.new("UICorner", teamsRow).CornerRadius = UDim.new(0, 10)

local teamsStroke = Instance.new("UIStroke", teamsRow)
teamsStroke.Color = Color3.fromRGB(255,255,255)
teamsStroke.Thickness = 1
teamsStroke.Transparency = 0.85

local teamTag = Instance.new("TextLabel", teamsRow)
teamTag.Size = UDim2.new(0, 55, 0, 14)
teamTag.Position = UDim2.new(0, 8, 0, 4)
teamTag.BackgroundTransparency = 1
teamTag.Text = "⚔ TEAMS"
teamTag.TextColor3 = Color3.fromRGB(180, 180, 200)
teamTag.TextSize = 11
teamTag.Font = Enum.Font.GothamBold
teamTag.TextXAlignment = Enum.TextXAlignment.Left

local chipHolder = Instance.new("Frame", teamsRow)
chipHolder.Size = UDim2.new(1, -70, 1, -8)
chipHolder.Position = UDim2.new(0, 66, 0, 4)
chipHolder.BackgroundTransparency = 1
chipHolder.BorderSizePixel = 0

local chipList = Instance.new("UIListLayout", chipHolder)
chipList.FillDirection = Enum.FillDirection.Horizontal
chipList.SortOrder = Enum.SortOrder.LayoutOrder
chipList.Padding = UDim.new(0, 4)
chipList.VerticalAlignment = Enum.VerticalAlignment.Center

local teamChips = {}
local function rebuildTeamChips()
	for _, c in pairs(teamChips) do
		if c.frame and c.frame.Parent then c.frame:Destroy() end
	end
	teamChips = {}
	if not Teams then
		teamsRow.Visible = false
		return
	end
	local list = Teams:GetTeams()
	if #list == 0 then
		teamsRow.Visible = false
		return
	end
	teamsRow.Visible = true
	local chipW = math.clamp(math.floor((480 - (#list-1)*4) / math.max(#list,1)), 36, 100)
	for i, team in ipairs(list) do
		local tc = team.TeamColor and team.TeamColor.Color or Color3.fromRGB(120,120,180)
		local bright = Color3.new(math.clamp(tc.R*1.4+0.08,0,1), math.clamp(tc.G*1.4+0.08,0,1), math.clamp(tc.B*1.4+0.08,0,1))
		local chip = Instance.new("Frame", chipHolder)
		chip.Size = UDim2.new(0, chipW, 1, -2)
		chip.BackgroundColor3 = Color3.fromRGB(20, 20, 36)
		chip.BackgroundTransparency = 0.1
		chip.BorderSizePixel = 0
		chip.LayoutOrder = i
		Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 5)

		local cs = Instance.new("UIStroke", chip)
		cs.Color = bright
		cs.Thickness = 1
		cs.Transparency = 0.35

		local strip = Instance.new("Frame", chip)
		strip.Size = UDim2.new(1, 0, 0, 3)
		strip.BackgroundColor3 = bright
		strip.BorderSizePixel = 0
		Instance.new("UICorner", strip).CornerRadius = UDim.new(0, 5)

		local nm = Instance.new("TextLabel", chip)
		nm.Size = UDim2.new(1, 0, 0, 14)
		nm.Position = UDim2.new(0, 0, 0, 5)
		nm.BackgroundTransparency = 1
		nm.Text = #team.Name > 8 and team.Name:sub(1,7).."…" or team.Name
		nm.TextColor3 = bright
		nm.TextSize = 10
		nm.Font = Enum.Font.GothamBold
		nm.TextXAlignment = Enum.TextXAlignment.Center
		nm.ClipsDescendants = true

		local cntLbl = Instance.new("TextLabel", chip)
		cntLbl.Size = UDim2.new(1, 0, 0, 16)
		cntLbl.Position = UDim2.new(0, 0, 0, 19)
		cntLbl.BackgroundTransparency = 1
		cntLbl.Text = "0"
		cntLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		cntLbl.TextSize = 13
		cntLbl.Font = Enum.Font.GothamBold
		cntLbl.TextXAlignment = Enum.TextXAlignment.Center

		teamChips[team.Name] = {frame = chip, cntLbl = cntLbl, team = team}
	end
end

local function updatePlayerCount()
	local players = Players:GetPlayers()
	local total = #players
	local ratio = math.clamp(total / MAX_PLAYERS, 0, 1)
	pcCount.Text = total .. " / " .. MAX_PLAYERS
	local color
	if ratio >= 1 then
		color = Color3.fromRGB(255, 70, 70)
		pcCount.TextColor3 = Color3.fromRGB(255, 100, 100)
		fullBadge.Visible = true
	elseif ratio >= 0.75 then
		color = Color3.fromRGB(255, 190, 40)
		pcCount.TextColor3 = Color3.fromRGB(255, 210, 80)
		fullBadge.Visible = false
	else
		color = Color3.fromRGB(74, 222, 128)
		pcCount.TextColor3 = Color3.fromRGB(100, 200, 255)
		fullBadge.Visible = false
	end
	barFill.BackgroundColor3 = color
	barFill.Size = UDim2.new(ratio, 0, 1, 0)

	if not Teams then return end
	for _, c in pairs(teamChips) do
		if c.team then
			local cnt = 0
			for _, p in ipairs(players) do
				if p.Team == c.team then cnt += 1 end
			end
			c.cntLbl.Text = tostring(cnt)
			c.frame.BackgroundTransparency = player.Team == c.team and 0 or 0.1
		end
	end
end

task.spawn(function()
	task.wait(1)
	rebuildTeamChips()
	updatePlayerCount()
end)
if Teams then
	Teams.ChildAdded:Connect(function() task.wait(0.1); rebuildTeamChips(); updatePlayerCount() end)
	Teams.ChildRemoved:Connect(function() task.wait(0.1); rebuildTeamChips(); updatePlayerCount() end)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); updatePlayerCount() end)
Players.PlayerRemoving:Connect(function() task.wait(0.3); updatePlayerCount() end)

-- ================== Bottom Performance Bar ==================
local bottomY = teamsY + 52 + 6   -- (ไม่มี Inventory แถบนี้อยู่ต่อจาก Teams)
local bottomBar = Instance.new("Frame", fullPanel)
bottomBar.Size = UDim2.new(1, -20, 0, 38)
bottomBar.Position = UDim2.new(0, 10, 0, bottomY)
bottomBar.BackgroundTransparency = 1

local fpsLabel = Instance.new("TextLabel", bottomBar)
fpsLabel.Size = UDim2.new(0, 90, 1, 0)
fpsLabel.Position = UDim2.new(0, 2, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 15
fpsLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
fpsLabel.Text = "🖥️ FPS 0"
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left

local pingLabel = Instance.new("TextLabel", bottomBar)
pingLabel.Size = UDim2.new(0, 130, 1, 0)
pingLabel.Position = UDim2.new(0, 100, 0, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 15
pingLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
pingLabel.Text = "📶 Ping 0 ms"
pingLabel.TextXAlignment = Enum.TextXAlignment.Left

local timeLabel = Instance.new("TextLabel", bottomBar)
timeLabel.Size = UDim2.new(0, 110, 1, 0)
timeLabel.Position = UDim2.new(0, 240, 0, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.Font = Enum.Font.GothamBold
timeLabel.TextSize = 15
timeLabel.TextColor3 = Color3.fromRGB(192, 132, 252)
timeLabel.Text = "⏱ 00:00:00"
timeLabel.TextXAlignment = Enum.TextXAlignment.Left

local capGroup = Instance.new("Frame", bottomBar)
capGroup.Size = UDim2.new(0, 150, 1, 0)
capGroup.Position = UDim2.new(1, -150, 0, 0)
capGroup.BackgroundTransparency = 1

local capIcon = Instance.new("TextLabel", capGroup)
capIcon.Size = UDim2.new(0, 20, 1, 0)
capIcon.BackgroundTransparency = 1
capIcon.Font = Enum.Font.Gotham
capIcon.TextSize = 18
capIcon.TextColor3 = Color3.fromRGB(200, 220, 255)
capIcon.Text = "🎯"
capIcon.TextXAlignment = Enum.TextXAlignment.Center

local capBox = Instance.new("TextBox", capGroup)
capBox.Size = UDim2.new(0, 50, 1, -8)
capBox.Position = UDim2.new(0, 22, 0, 4)
capBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
capBox.BackgroundTransparency = 0.3
capBox.BorderSizePixel = 0
capBox.Font = Enum.Font.Gotham
capBox.TextSize = 14
capBox.TextColor3 = Color3.fromRGB(255, 255, 255)
capBox.Text = ""
capBox.PlaceholderText = tostring(FPS_CAP)
capBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
Instance.new("UICorner", capBox).CornerRadius = UDim.new(0, 5)

local setCapBtn = Instance.new("TextButton", capGroup)
setCapBtn.Size = UDim2.new(0, 45, 1, -8)
setCapBtn.Position = UDim2.new(0, 76, 0, 4)
setCapBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 255)
setCapBtn.BorderSizePixel = 0
setCapBtn.Font = Enum.Font.GothamBold
setCapBtn.TextSize = 13
setCapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setCapBtn.Text = "SET"
Instance.new("UICorner", setCapBtn).CornerRadius = UDim.new(0, 7)

setCapBtn.MouseEnter:Connect(function()
	TweenService:Create(setCapBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(110, 130, 255)}):Play()
end)
setCapBtn.MouseLeave:Connect(function()
	TweenService:Create(setCapBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 100, 255)}):Play()
end)

local function applyFpsCap()
	local num = tonumber(capBox.Text)
	if num and num > 0 then
		pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate = num end)
		pcall(function() setfpscap(num) end)
		FPS_CAP = num
		capBox.Text = ""
	end
end
setCapBtn.MouseButton1Click:Connect(applyFpsCap)
capBox.FocusLost:Connect(function(enterPressed) if enterPressed then applyFpsCap() end end)

-- ================== Mini Panel Content ==================
local miniAvatar = Instance.new("ImageLabel", miniPanel)
miniAvatar.Size = UDim2.new(0, 40, 0, 40)
miniAvatar.Position = UDim2.new(0, 10, 0, 15)
miniAvatar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
miniAvatar.BackgroundTransparency = 0.4
miniAvatar.BorderSizePixel = 0
Instance.new("UICorner", miniAvatar).CornerRadius = UDim.new(0, 20)

task.spawn(function()
	local ok, thumb = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if ok and thumb then miniAvatar.Image = thumb end
end)

local miniName = Instance.new("TextLabel", miniPanel)
miniName.Size = UDim2.new(0, 160, 0, 18)
miniName.Position = UDim2.new(0, 60, 0, 15)
miniName.BackgroundTransparency = 1
miniName.Font = Enum.Font.GothamBold
miniName.TextSize = 14
miniName.TextColor3 = Color3.fromRGB(255, 255, 255)
miniName.Text = "Loading..."
miniName.TextXAlignment = Enum.TextXAlignment.Left

local miniLvl = Instance.new("TextLabel", miniPanel)
miniLvl.Size = UDim2.new(0, 100, 0, 14)
miniLvl.Position = UDim2.new(0, 60, 0, 33)
miniLvl.BackgroundTransparency = 1
miniLvl.Font = Enum.Font.GothamBold
miniLvl.TextSize = 12
miniLvl.TextColor3 = Color3.fromRGB(255, 215, 0)
miniLvl.Text = "⭐ Lv.0"
miniLvl.TextXAlignment = Enum.TextXAlignment.Left

local miniStats = {}
local statNames = {"Level", "Beli", "Fragments"}
local miniIcons = {"⚔", "💰", "💎"}
local miniColors = {Color3.fromRGB(255,215,60), Color3.fromRGB(80,235,140), Color3.fromRGB(200,130,255)}
for i, key in ipairs(statNames) do
	local x = 230 + (i-1)*90
	local icon = Instance.new("TextLabel", miniPanel)
	icon.Size = UDim2.new(0, 16, 0, 16)
	icon.Position = UDim2.new(0, x, 0, 16)
	icon.BackgroundTransparency = 1
	icon.Font = Enum.Font.Gotham
	icon.TextSize = 13
	icon.TextColor3 = Color3.fromRGB(200,200,200)
	icon.Text = miniIcons[i]
	icon.TextXAlignment = Enum.TextXAlignment.Center

	local val = Instance.new("TextLabel", miniPanel)
	val.Size = UDim2.new(0, 70, 0, 16)
	val.Position = UDim2.new(0, x+20, 0, 16)
	val.BackgroundTransparency = 1
	val.Font = Enum.Font.GothamBold
	val.TextSize = 13
	val.TextColor3 = miniColors[i]
	val.Text = "..."
	val.TextXAlignment = Enum.TextXAlignment.Left
	val.TextTruncate = Enum.TextTruncate.AtEnd
	miniStats[key] = val
end

-- ================== Blackout Feature ==================
local blackoutFrame = Instance.new("Frame", gui)
blackoutFrame.Size = UDim2.new(1, 0, 1, 0)
blackoutFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackoutFrame.BackgroundTransparency = 1
blackoutFrame.BorderSizePixel = 0
blackoutFrame.Visible = false
blackoutFrame.ZIndex = 100

local restoreBtn = Instance.new("TextButton", blackoutFrame)
restoreBtn.Size = UDim2.new(0, 100, 0, 40)
restoreBtn.AnchorPoint = Vector2.new(0.5, 1)
restoreBtn.Position = UDim2.new(0.5, 0, 1, -30)
restoreBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
restoreBtn.BorderSizePixel = 0
restoreBtn.Text = "Restore"
restoreBtn.TextColor3 = Color3.fromRGB(255, 230, 80)
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 14
restoreBtn.AutoButtonColor = false
restoreBtn.Visible = false
restoreBtn.ZIndex = 101
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 8)

local blackoutActive = false
local function setBlackout(state)
	blackoutActive = state
	blackoutFrame.Visible = state
	restoreBtn.Visible = state
	blackoutFrame.BackgroundTransparency = state and 0.001 or 1
end
restoreBtn.MouseButton1Click:Connect(function() setBlackout(false) end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.B then
		setBlackout(not blackoutActive)
	end
end)

-- ================== Self Highlight ==================
local selfHL = nil
local function applyHighlight(character)
	if selfHL and selfHL.Parent then selfHL:Destroy() end
	selfHL = nil
	if not character then return end
	local hl = Instance.new("Highlight")
	hl.Name = "ESP_SelfHL"
	hl.FillColor = Color3.fromRGB(60, 220, 120)
	hl.OutlineColor = Color3.fromRGB(140, 255, 180)
	hl.FillTransparency = 0.65
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.Adornee = character
	hl.Parent = character
	selfHL = hl
end
if player.Character then
	task.delay(0.5, function() applyHighlight(player.Character) end)
end
player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	applyHighlight(char)
end)

-- ================== FPS / Ping / Time ==================
local fps = 0
local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	if now - lastTime >= 0.5 then
		fps = math.floor(frameCount / (now - lastTime))
		frameCount = 0
		lastTime = now
	end
end)

local function getPing()
	local ok, p = pcall(function()
		return StatsService.Network.ServerStatsItem.Data.Ping
	end)
	return (ok and type(p) == "number") and math.floor(p) or 0
end

local scriptStart = tick()

-- ================== Update Loop ==================
local function update()
	local disp = player.DisplayName
	local name = player.Name
	charLabel.Text = "👤 " .. (disp ~= name and disp .. " (@"..name..")" or name)
	miniName.Text = disp ~= name and disp .. " (@"..name..")" or name

	local lv = getStat("Level")
	lvlLabel.Text = "⭐ Lv." .. formatVal(lv, "Level")
	miniLvl.Text = "⭐ Lv." .. formatVal(lv, "Level")

	leftCards.Beli.value.Text = formatVal(getStat("Beli"), "Beli")
	leftCards.Frag.value.Text = formatVal(getStat("Fragments"), "Fragments")
	leftCards.Team.value.Text = player.Team and player.Team.Name or "N/A"
	leftCards.Players.value.Text = #Players:GetPlayers() .. " / " .. MAX_PLAYERS
	local elapsed = tick() - scriptStart
	local h = math.floor(elapsed / 3600)
	local m = math.floor((elapsed % 3600) / 60)
	local s = math.floor(elapsed % 60)
	leftCards.Time.value.Text = string.format("%02d:%02d:%02d", h, m, s)
	timeLabel.Text = "⏱ " .. string.format("%02d:%02d:%02d", h, m, s)

	rightCards.Melee.value.Text = formatVal(getStat("Melee"))
	rightCards.Defense.value.Text = formatVal(getStat("Defense"))
	rightCards.Sword.value.Text = formatVal(getStat("Sword"))
	rightCards.Gun.value.Text = formatVal(getStat("Gun"))
	rightCards.Fruit.value.Text = formatVal(getStat("Blox Fruit"))

	for name, card in pairs(rightCards) do
		local val = getStat(name == "Fruit" and "Blox Fruit" or name)
		if val and card.barFill then
			card.barFill.Size = UDim2.new(math.clamp(tonumber(val) / COMBAT_CAP, 0, 1), 0, 1, 0)
		elseif card.barFill then
			card.barFill.Size = UDim2.new(0, 0, 1, 0)
		end
	end

	fpsLabel.Text = "🖥️ FPS " .. fps
	local ping = getPing()
	pingLabel.Text = "📶 Ping " .. ping .. " ms"
	pingLabel.TextColor3 = ping < 80 and Color3.fromRGB(130,255,130) or (ping < 150 and Color3.fromRGB(255,255,100) or Color3.fromRGB(255,120,100))

	if miniStats["Level"] then miniStats["Level"].Text = formatVal(lv, "Level") end
	if miniStats["Beli"] then miniStats["Beli"].Text = formatVal(getStat("Beli"), "Beli") end
	if miniStats["Fragments"] then miniStats["Fragments"].Text = formatVal(getStat("Fragments"), "Fragments") end

	local curCap = 0
	pcall(function() curCap = settings().Rendering.FrameRateManager.MaxFrameRate end)
	capBox.PlaceholderText = curCap > 0 and tostring(curCap) or "∞"

	updatePlayerCount()
end

update()
task.spawn(function() while true do update() task.wait(0.5) end end)

-- ================== Toggle GUI Visibility ==================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		fullPanel.Visible = not fullPanel.Visible
		miniPanel.Visible = isMini and fullPanel.Visible
	end
end)
