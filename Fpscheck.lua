-- getenv = function() return {
--    ["Remove Death Effect"] = true,
--    ["Lock Fps"] = { ["Enabled"] = true, ["FPS"] = 120 },
--    ["White Screen"] = false,
-- } end

local config = getenv()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local StatsService     = game:GetService("Stats")

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

-- Stat helpers
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
    Level      = {"leaderstats.Level", "leaderstats.Lv.", "Data.Level"},
    Beli       = {"leaderstats.Beli", "leaderstats.Money", "Data.Beli"},
    Fragments  = {"leaderstats.Fragments", "leaderstats.Fragment", "Data.Fragments"},
    Melee      = {"leaderstats.Melee", "Data.Stats.Melee.Level"},
    Defense    = {"leaderstats.Defense", "Data.Stats.Defense.Level"},
    Sword      = {"leaderstats.Sword", "Data.Stats.Sword.Level"},
    Gun        = {"leaderstats.Gun", "Data.Stats.Gun.Level"},
    ["Blox Fruit"] = {"leaderstats.Blox Fruit","leaderstats.Demon Fruit","Data.Stats.Blox Fruit.Level","Data.Stats.Demon Fruit.Level"},
}

local function getStat(key)
    local paths = STAT_PATHS[key]
    if not paths then return getValueByPaths("leaderstats."..key, "Data."..key) end
    for _, path in ipairs(paths) do
        local val = getValueByPaths(path)
        if val ~= nil then return val end
    end
    return nil
end

local function formatVal(v, key)
    if type(v) ~= "number" then return tostring(v or "?") end
    if key == "Beli" or key == "Fragments" or key == "Level" then
        return tostring(math.floor(v)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
    end
    if v >= 1e6 then return string.format("%.1fM", v/1e6)
    elseif v >= 1e3 then return string.format("%.1fK", v/1e3)
    else return tostring(math.floor(v)) end
end

local function getEquippedItem()
    local char = player.Character
    if not char then return "None" end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then return obj.Name end
    end
    return "None"
end

-- Colors
local C = {
    BG        = Color3.fromRGB(10,  10,  10),
    PANEL     = Color3.fromRGB(0,   0,   0),
    CARD      = Color3.fromRGB(20,  20,  20),
    CARDHOVER = Color3.fromRGB(28,  28,  28),
    BORDER    = Color3.fromRGB(40,  40,  40),
    BORDER2   = Color3.fromRGB(60,  60,  60),
    WHITE     = Color3.fromRGB(255, 255, 255),
    OFFWHITE  = Color3.fromRGB(220, 220, 220),
    MUTED     = Color3.fromRGB(140, 140, 140),
    DIM       = Color3.fromRGB(80,  80,  80),
    SUCCESS   = Color3.fromRGB(200, 255, 200),
    WARN      = Color3.fromRGB(255, 240, 180),
    DANGER    = Color3.fromRGB(255, 180, 180),
}

-- UI builders
local function addCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or C.BORDER
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    return s
end

local function makeLabel(parent, props)
    local lbl = Instance.new("TextLabel", parent)
    lbl.BackgroundTransparency = 1
    lbl.Font = props.font or Enum.Font.GothamBold
    lbl.TextSize = props.size or 13
    lbl.TextColor3 = props.color or C.OFFWHITE
    lbl.Text = props.text or ""
    lbl.Size = props.sz or UDim2.new(1,0,0,20)
    lbl.Position = props.pos or UDim2.new(0,0,0,0)
    lbl.TextXAlignment = props.align or Enum.TextXAlignment.Left
    lbl.TextYAlignment = props.yalign or Enum.TextYAlignment.Center
    lbl.TextTruncate = props.truncate or Enum.TextTruncate.None
    lbl.ZIndex = props.zindex or 2
    return lbl
end

local function makeToggleBtn(parent, txt, yPos)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,26,0,20)
    btn.Position = UDim2.new(1,-32,0,yPos)
    btn.BackgroundColor3 = C.CARD
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = txt
    btn.TextColor3 = C.MUTED
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    addCorner(btn,5)
    addStroke(btn, C.BORDER,1,0)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=C.CARDHOVER,TextColor3=C.WHITE}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=C.CARD,TextColor3=C.MUTED}):Play()
    end)
    return btn
end

-- ========== MAIN GUI SETUP ==========
local gui = Instance.new("ScreenGui")
gui.Name = "Status BF"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10
gui.Parent = pg

-- Full panel (main)
local fullPanel = Instance.new("Frame")
fullPanel.Size = UDim2.new(0,520,0,470)
fullPanel.Position = UDim2.new(0.02,0,0.08,0)
fullPanel.BackgroundColor3 = C.PANEL
fullPanel.BackgroundTransparency = 0.06
fullPanel.BorderSizePixel = 0
fullPanel.Active = true
fullPanel.ClipsDescendants = true
fullPanel.Visible = true
fullPanel.Parent = gui
addCorner(fullPanel,16)
addStroke(fullPanel, C.BORDER2,1,0)

local miniPanel = Instance.new("Frame")
miniPanel.Size = UDim2.new(0,520,0,68)
miniPanel.Position = fullPanel.Position
miniPanel.BackgroundColor3 = C.PANEL
miniPanel.BackgroundTransparency = 0.06
miniPanel.BorderSizePixel = 0
miniPanel.ClipsDescendants = true
miniPanel.Visible = false
miniPanel.Parent = gui
addCorner(miniPanel,16)
addStroke(miniPanel, C.BORDER2,1,0)

-- ========== LOADING OVERLAY ==========
local loadOverlay = Instance.new("Frame", gui)
loadOverlay.Size = fullPanel.Size
loadOverlay.Position = fullPanel.Position
loadOverlay.BackgroundColor3 = Color3.fromRGB(8,8,8)
loadOverlay.BackgroundTransparency = 0.4
loadOverlay.BorderSizePixel = 0
loadOverlay.ZIndex = 50
addCorner(loadOverlay,16)
addStroke(loadOverlay, C.BORDER2,1,0)

-- Loading text / progress
makeLabel(loadOverlay, {
    sz = UDim2.new(1,0,0,20), pos = UDim2.new(0,0,0,180),
    font = Enum.Font.GothamBold, size = 14, color = C.WHITE,
    text = "INTEGRATED HUD", align = Enum.TextXAlignment.Center, zindex = 52,
})
local loadStepLabel = makeLabel(loadOverlay, {
    sz = UDim2.new(1,-60,0,14), pos = UDim2.new(0,30,0,210),
    font = Enum.Font.Gotham, size = 10, color = C.MUTED,
    text = "Initializing...", align = Enum.TextXAlignment.Center, zindex = 52,
})
local loadTrackBg = Instance.new("Frame", loadOverlay)
loadTrackBg.Size = UDim2.new(1,-60,0,2)
loadTrackBg.Position = UDim2.new(0,30,0,232)
loadTrackBg.BackgroundColor3 = C.BORDER
loadTrackBg.BackgroundTransparency = 0
loadTrackBg.BorderSizePixel = 0
loadTrackBg.ZIndex = 52
addCorner(loadTrackBg,1)
local loadBarFill = Instance.new("Frame", loadTrackBg)
loadBarFill.Size = UDim2.new(0,0,1,0)
loadBarFill.BackgroundColor3 = C.WHITE
loadBarFill.BorderSizePixel = 0
loadBarFill.ZIndex = 53
addCorner(loadBarFill,1)
local loadPctLabel = makeLabel(loadOverlay, {
    sz = UDim2.new(1,-60,0,14), pos = UDim2.new(0,30,0,240),
    font = Enum.Font.GothamBold, size = 9, color = C.DIM,
    text = "0%", align = Enum.TextXAlignment.Right, zindex = 52,
})

-- ========== HEADER & CONTENT ==========
local collapseBtn = makeToggleBtn(fullPanel, "▲", 10)
local expandBtn   = makeToggleBtn(miniPanel, "▼", 8)

local isMini = false
local function setView(miniMode)
    isMini = miniMode
    fullPanel.Visible = not miniMode
    miniPanel.Visible = miniMode
end
collapseBtn.MouseButton1Click:Connect(function() setView(true) end)
expandBtn.MouseButton1Click:Connect(function() setView(false) end)

-- Dragging
local dragging, dragStart, startPos = false, nil, nil
fullPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragStart, startPos = true, input.Position, fullPanel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        fullPanel.Position = newPos
        miniPanel.Position = newPos
        if loadOverlay and loadOverlay.Parent then loadOverlay.Position = newPos end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local titleBar = Instance.new("Frame", fullPanel)
titleBar.Size = UDim2.new(1,0,0,64)
titleBar.BackgroundTransparency = 1
titleBar.ZIndex = 2

local avatar = Instance.new("ImageLabel", titleBar)
avatar.Size = UDim2.new(0,44,0,44)
avatar.Position = UDim2.new(0,14,0,10)
avatar.BackgroundColor3 = C.CARD
avatar.BackgroundTransparency = 0
avatar.BorderSizePixel = 0
avatar.ZIndex = 3
addCorner(avatar,22)
addStroke(avatar, C.BORDER2,1,0)

task.spawn(function()
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and thumb then avatar.Image = thumb end
end)

local charLabel = makeLabel(titleBar, {
    sz = UDim2.new(1,-120,0,20), pos = UDim2.new(0,68,0,8),
    font = Enum.Font.GothamBold, size = 15, color = C.WHITE, text = "Loading...", zindex = 3
})
local lvlLabel = makeLabel(titleBar, {
    sz = UDim2.new(0,140,0,16), pos = UDim2.new(0,68,0,28),
    font = Enum.Font.GothamBold, size = 12, color = C.MUTED, text = "LV. 0", zindex = 3
})
local onlineDot = Instance.new("Frame", titleBar)
onlineDot.Size = UDim2.new(0,6,0,6)
onlineDot.Position = UDim2.new(0,68,0,48)
onlineDot.BackgroundColor3 = C.WHITE
onlineDot.BorderSizePixel = 0
onlineDot.ZIndex = 3
addCorner(onlineDot,3)
makeLabel(titleBar, {sz=UDim2.new(0,60,0,14), pos=UDim2.new(0,80,0,44), size=10, color=C.DIM, text="ONLINE", zindex=3})
makeLabel(titleBar, {sz=UDim2.new(0,80,0,14), pos=UDim2.new(1,-116,0,44), size=10, color=C.DIM, text="BLOX FRUITS", align=Enum.TextXAlignment.Right, zindex=3})

local divider = Instance.new("Frame", titleBar)
divider.Size = UDim2.new(1,-28,0,1)
divider.Position = UDim2.new(0,14,0,63)
divider.BackgroundColor3 = C.BORDER
divider.BackgroundTransparency = 0
divider.BorderSizePixel = 0
divider.ZIndex = 2

local content = Instance.new("Frame", fullPanel)
content.Size = UDim2.new(1,-28,0,252)
content.Position = UDim2.new(0,14,0,72)
content.BackgroundTransparency = 1
content.ZIndex = 2
makeLabel(content, {sz=UDim2.new(0,240,0,14), pos=UDim2.new(0,0,0,0), size=9, color=C.DIM, text="ACCOUNT"})
makeLabel(content, {sz=UDim2.new(0,240,0,14), pos=UDim2.new(0,252,0,0), size=9, color=C.DIM, text="COMBAT STATS"})

local function createCard(parent, x, y, label, defaultValue, isCombat)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(0,240,0,36)
    card.Position = UDim2.new(0,x,0,y)
    card.BackgroundColor3 = C.CARD
    card.BackgroundTransparency = 0.1
    card.BorderSizePixel = 0
    card.ZIndex = 3
    addCorner(card,7)
    addStroke(card, C.BORDER,1,0)
    makeLabel(card, {sz=UDim2.new(0,100,0,14), pos=UDim2.new(0,10,0,4), size=9, color=C.DIM, text=string.upper(label), zindex=4})
    local valLbl = makeLabel(card, {
        sz = UDim2.new(1,-20,0,16), pos = UDim2.new(0,10,0,17),
        font = Enum.Font.GothamBold, size = 13, color = C.WHITE,
        text = defaultValue, truncate = Enum.TextTruncate.AtEnd, zindex = 4
    })
    if isCombat then
        local trackBg = Instance.new("Frame", card)
        trackBg.Size = UDim2.new(1,-20,0,2)
        trackBg.Position = UDim2.new(0,10,1,-5)
        trackBg.BackgroundColor3 = C.BORDER
        trackBg.BackgroundTransparency = 0
        trackBg.BorderSizePixel = 0
        trackBg.ZIndex = 5
        addCorner(trackBg,1)
        local fill = Instance.new("Frame", trackBg)
        fill.Size = UDim2.new(0,0,1,0)
        fill.BackgroundColor3 = C.WHITE
        fill.BackgroundTransparency = 0
        fill.BorderSizePixel = 0
        fill.ZIndex = 6
        addCorner(fill,1)
        return {card=card, value=valLbl, barFill=fill}
    end
    return {card=card, value=valLbl}
end

local leftX, rightX = 0, 252
local yBase = 16
local leftCards = {
    Beli    = createCard(content, leftX, yBase+0,   "Beli",      "0"),
    Frag    = createCard(content, leftX, yBase+40,  "Fragments", "0"),
    Team    = createCard(content, leftX, yBase+80,  "Team",      "N/A"),
    Players = createCard(content, leftX, yBase+120, "Players",   "0/0"),
    Time    = createCard(content, leftX, yBase+160, "Runtime",   "00:00:00"),
    Equip   = createCard(content, leftX, yBase+200, "Equipped",  "None"),
}
local rightCards = {
    Melee   = createCard(content, rightX, yBase+0,   "Melee",      "0", true),
    Defense = createCard(content, rightX, yBase+40,  "Defense",    "0", true),
    Sword   = createCard(content, rightX, yBase+80,  "Sword",      "0", true),
    Gun     = createCard(content, rightX, yBase+120, "Gun",        "0", true),
    Fruit   = createCard(content, rightX, yBase+160, "Blox Fruit", "0", true),
}

-- Player count bar
local pcBar = Instance.new("Frame", fullPanel)
pcBar.Size = UDim2.new(1,-28,0,38)
pcBar.Position = UDim2.new(0,14,0, 72+252+8)
pcBar.BackgroundColor3 = C.CARD
pcBar.BackgroundTransparency = 0.1
pcBar.BorderSizePixel = 0
pcBar.ZIndex = 2
addCorner(pcBar,8)
addStroke(pcBar, C.BORDER,1,0)
makeLabel(pcBar, {sz=UDim2.new(0,80,0,14), pos=UDim2.new(0,10,0,4), size=9, color=C.DIM, text="PLAYERS IN SERVER", zindex=3})
local pcCount = makeLabel(pcBar, {
    sz=UDim2.new(0,80,0,14), pos=UDim2.new(1,-90,0,4),
    font=Enum.Font.GothamBold, size=11, color=C.WHITE,
    text="? / "..MAX_PLAYERS, align=Enum.TextXAlignment.Right, zindex=3
})
local barBg = Instance.new("Frame", pcBar)
barBg.Size = UDim2.new(1,-20,0,3)
barBg.Position = UDim2.new(0,10,1,-8)
barBg.BackgroundColor3 = C.BORDER
barBg.BorderSizePixel = 0
barBg.ZIndex = 3
addCorner(barBg,2)
local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0,0,1,0)
barFill.BackgroundColor3 = C.WHITE
barFill.BorderSizePixel = 0
barFill.ZIndex = 4
addCorner(barFill,2)
local fullBadge = Instance.new("TextLabel", pcBar)
fullBadge.Size = UDim2.new(0,36,0,14)
fullBadge.Position = UDim2.new(1,-46,0,4)
fullBadge.BackgroundColor3 = C.WHITE
fullBadge.BackgroundTransparency = 0
fullBadge.Text = "FULL"
fullBadge.TextColor3 = C.BG
fullBadge.TextSize = 8
fullBadge.Font = Enum.Font.GothamBold
fullBadge.TextXAlignment = Enum.TextXAlignment.Center
fullBadge.Visible = false
fullBadge.BorderSizePixel = 0
fullBadge.ZIndex = 4
addCorner(fullBadge,4)

-- Teams row
local Teams
pcall(function() Teams = game:GetService("Teams") end)
local teamsRow = Instance.new("Frame", fullPanel)
teamsRow.Size = UDim2.new(1,-28,0,48)
teamsRow.Position = UDim2.new(0,14,0, pcBar.Position.Y.Offset + 38 + 6)
teamsRow.BackgroundColor3 = C.CARD
teamsRow.BackgroundTransparency = 0.1
teamsRow.BorderSizePixel = 0
teamsRow.Visible = false
teamsRow.ZIndex = 2
addCorner(teamsRow,8)
addStroke(teamsRow, C.BORDER,1,0)
makeLabel(teamsRow, {sz=UDim2.new(0,55,0,14), pos=UDim2.new(0,10,0,4), size=9, color=C.DIM, text="TEAMS", zindex=3})
local chipHolder = Instance.new("Frame", teamsRow)
chipHolder.Size = UDim2.new(1,-70,1,-8)
chipHolder.Position = UDim2.new(0,64,0,4)
chipHolder.BackgroundTransparency = 1
chipHolder.BorderSizePixel = 0
chipHolder.ZIndex = 3
local chipList = Instance.new("UIListLayout", chipHolder)
chipList.FillDirection = Enum.FillDirection.Horizontal
chipList.SortOrder = Enum.SortOrder.LayoutOrder
chipList.Padding = UDim.new(0,4)
chipList.VerticalAlignment = Enum.VerticalAlignment.Center

local teamChips = {}
local function rebuildTeamChips()
    for _, c in pairs(teamChips) do if c.frame then c.frame:Destroy() end end
    teamChips = {}
    if not Teams then teamsRow.Visible = false; return end
    local list = Teams:GetTeams()
    if #list == 0 then teamsRow.Visible = false; return end
    teamsRow.Visible = true
    local chipW = math.clamp(math.floor((480 - (#list-1)*4) / math.max(#list,1)), 36, 100)
    for i, team in ipairs(list) do
        local chip = Instance.new("Frame", chipHolder)
        chip.Size = UDim2.new(0, chipW, 1, -2)
        chip.BackgroundColor3 = C.BORDER
        chip.BackgroundTransparency = 0.2
        chip.BorderSizePixel = 0
        chip.LayoutOrder = i
        chip.ZIndex = 4
        addCorner(chip,5)
        addStroke(chip, C.BORDER2,1,0)
        local strip = Instance.new("Frame", chip)
        strip.Size = UDim2.new(1,0,0,2)
        strip.BackgroundColor3 = C.WHITE
        strip.BorderSizePixel = 0
        strip.ZIndex = 5
        addCorner(strip,5)
        makeLabel(chip, {sz=UDim2.new(1,0,0,14), pos=UDim2.new(0,0,0,4), size=10, color=C.MUTED, text=#team.Name>8 and team.Name:sub(1,7).."…" or team.Name, align=Enum.TextXAlignment.Center, zindex=5})
        local cntLbl = makeLabel(chip, {sz=UDim2.new(1,0,0,16), pos=UDim2.new(0,0,0,18), font=Enum.Font.GothamBold, size=12, color=C.WHITE, text="0", align=Enum.TextXAlignment.Center, zindex=5})
        teamChips[team.Name] = {frame=chip, cntLbl=cntLbl, team=team}
    end
end

local function updatePlayerCount()
    local list = Players:GetPlayers()
    local total = #list
    local ratio = math.clamp(total / MAX_PLAYERS, 0, 1)
    pcCount.Text = total .. " / " .. MAX_PLAYERS
    if ratio >= 1 then
        barFill.BackgroundColor3 = C.DANGER
        pcCount.TextColor3 = C.DANGER
        pcCount.Position = UDim2.new(1,-132,0,4)
        fullBadge.Visible = true
    elseif ratio >= 0.75 then
        barFill.BackgroundColor3 = C.WARN
        pcCount.TextColor3 = C.WARN
        pcCount.Position = UDim2.new(1,-90,0,4)
        fullBadge.Visible = false
    else
        barFill.BackgroundColor3 = C.WHITE
        pcCount.TextColor3 = C.WHITE
        pcCount.Position = UDim2.new(1,-90,0,4)
        fullBadge.Visible = false
    end
    barFill.Size = UDim2.new(ratio,0,1,0)
    if Teams then
        for _, c in pairs(teamChips) do
            if c.team then
                local cnt = 0
                for _, p in ipairs(list) do if p.Team == c.team then cnt = cnt + 1 end end
                c.cntLbl.Text = tostring(cnt)
                c.frame.BackgroundTransparency = player.Team == c.team and 0 or 0.2
            end
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

-- Bottom bar
local bottomBar = Instance.new("Frame", fullPanel)
bottomBar.Size = UDim2.new(1,-28,0,34)
bottomBar.Position = UDim2.new(0,14,0, teamsRow.Position.Y.Offset + 48 + 6)
bottomBar.BackgroundTransparency = 1
bottomBar.ZIndex = 2
local fpsLabel = makeLabel(bottomBar, {sz=UDim2.new(0,100,1,0), pos=UDim2.new(0,0,0,0), font=Enum.Font.GothamBold, size=13, color=C.OFFWHITE, text="FPS 0"})
local pingLabel = makeLabel(bottomBar, {sz=UDim2.new(0,120,1,0), pos=UDim2.new(0,104,0,0), font=Enum.Font.GothamBold, size=13, color=C.OFFWHITE, text="PING 0 ms"})
local timeLabel = makeLabel(bottomBar, {sz=UDim2.new(0,110,1,0), pos=UDim2.new(0,232,0,0), font=Enum.Font.GothamBold, size=13, color=C.MUTED, text="00:00:00"})

local capGroup = Instance.new("Frame", bottomBar)
capGroup.Size = UDim2.new(0,140,1,0)
capGroup.Position = UDim2.new(1,-140,0,0)
capGroup.BackgroundTransparency = 1
capGroup.ZIndex = 3
makeLabel(capGroup, {sz=UDim2.new(0,28,1,0), pos=UDim2.new(0,0,0,0), size=8, color=C.DIM, text="FPSCAP", zindex=5})
local capBox = Instance.new("TextBox", capGroup)
capBox.Size = UDim2.new(0,46,1,-8)
capBox.Position = UDim2.new(0,30,0,4)
capBox.BackgroundColor3 = C.CARD
capBox.BackgroundTransparency = 0.1
capBox.BorderSizePixel = 0
capBox.Font = Enum.Font.Gotham
capBox.TextSize = 12
capBox.TextColor3 = C.WHITE
capBox.Text = ""
capBox.PlaceholderText = tostring(FPS_CAP)
capBox.PlaceholderColor3 = C.DIM
capBox.ZIndex = 4
addCorner(capBox,5)
addStroke(capBox, C.BORDER,1,0)
local setCapBtn = Instance.new("TextButton", capGroup)
setCapBtn.Size = UDim2.new(0,42,1,-8)
setCapBtn.Position = UDim2.new(0,82,0,4)
setCapBtn.BackgroundColor3 = C.WHITE
setCapBtn.BackgroundTransparency = 0
setCapBtn.BorderSizePixel = 0
setCapBtn.Font = Enum.Font.GothamBold
setCapBtn.TextSize = 11
setCapBtn.TextColor3 = C.BG
setCapBtn.Text = "SET"
setCapBtn.ZIndex = 4
addCorner(setCapBtn,5)
setCapBtn.MouseEnter:Connect(function() TweenService:Create(setCapBtn, TweenInfo.new(0.15), {BackgroundColor3=C.OFFWHITE}):Play() end)
setCapBtn.MouseLeave:Connect(function() TweenService:Create(setCapBtn, TweenInfo.new(0.15), {BackgroundColor3=C.WHITE}):Play() end)
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

local miniAvatar = Instance.new("ImageLabel", miniPanel)
miniAvatar.Size = UDim2.new(0,38,0,38)
miniAvatar.Position = UDim2.new(0,14,0,15)
miniAvatar.BackgroundColor3 = C.CARD
miniAvatar.BackgroundTransparency = 0
miniAvatar.BorderSizePixel = 0
miniAvatar.ZIndex = 3
addCorner(miniAvatar,19)
addStroke(miniAvatar, C.BORDER2,1,0)
task.spawn(function()
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and thumb then miniAvatar.Image = thumb end
end)
local miniName = makeLabel(miniPanel, {sz=UDim2.new(0,160,0,18), pos=UDim2.new(0,62,0,12), font=Enum.Font.GothamBold, size=13, color=C.WHITE, text="Loading...", zindex=3})
local miniLvl = makeLabel(miniPanel, {sz=UDim2.new(0,100,0,14), pos=UDim2.new(0,62,0,30), size=10, color=C.DIM, text="LV. 0", zindex=3})
local miniStats = {}
local statNames = {"Level","Beli","Fragments"}
local miniIcons = {"LV","G","◈"}
for i, key in ipairs(statNames) do
    local x = 240 + (i-1)*92
    makeLabel(miniPanel, {sz=UDim2.new(0,20,0,14), pos=UDim2.new(0,x,0,10), size=9, color=C.DIM, text=miniIcons[i], align=Enum.TextXAlignment.Center, zindex=3})
    local val = makeLabel(miniPanel, {sz=UDim2.new(0,68,0,16), pos=UDim2.new(0,x+22,0,8), font=Enum.Font.GothamBold, size=12, color=C.WHITE, text="...", truncate=Enum.TextTruncate.AtEnd, zindex=3})
    makeLabel(miniPanel, {sz=UDim2.new(0,70,0,12), pos=UDim2.new(0,x+22,0,26), size=8, color=C.DIM, text=string.upper(key), zindex=3})
    miniStats[key] = val
end

local blackoutFrame = Instance.new("Frame", gui)
blackoutFrame.Size = UDim2.new(1,0,1,0)
blackoutFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
blackoutFrame.BackgroundTransparency = 0
blackoutFrame.BorderSizePixel = 0
blackoutFrame.ZIndex = 1
blackoutFrame.Visible = false
local restoreBtn = Instance.new("TextButton", gui)
restoreBtn.Size = UDim2.new(0,90,0,32)
restoreBtn.AnchorPoint = Vector2.new(0.5,1)
restoreBtn.Position = UDim2.new(0.5,0,1,-30)
restoreBtn.BackgroundColor3 = C.WHITE
restoreBtn.BorderSizePixel = 0
restoreBtn.Text = "RESTORE"
restoreBtn.TextColor3 = C.BG
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.TextSize = 12
restoreBtn.AutoButtonColor = false
restoreBtn.Visible = false
restoreBtn.ZIndex = 51
addCorner(restoreBtn,6)
local blackoutActive = false
local function setBlackout(state)
    blackoutActive = state
    blackoutFrame.Visible = state
    restoreBtn.Visible = state
end
if config["White Screen"] then setBlackout(true) end
restoreBtn.MouseButton1Click:Connect(function() setBlackout(false) end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then setBlackout(not blackoutActive) end
end)

-- Self highlight
local selfHL = nil
local function applyHighlight(character)
    if selfHL and selfHL.Parent then selfHL:Destroy() end
    selfHL = nil
    if not character then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_SelfHL"
    hl.FillColor = Color3.fromRGB(255,255,255)
    hl.OutlineColor = Color3.fromRGB(0,0,0)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = character
    hl.Parent = character
    selfHL = hl
end
if player.Character then task.delay(0.5, function() applyHighlight(player.Character) end) end
player.CharacterAdded:Connect(function(char) task.wait(0.5); applyHighlight(char) end)

-- FPS counter
local fps = 0
local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 0.5 then
        fps = math.floor(frameCount / (now - lastTime))
        frameCount, lastTime = 0, now
    end
end)

local function getPing()
    local ok, p = pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"] end)
    if ok and type(p) == "number" then return math.floor(p) end
    return math.floor(player:GetNetworkPing() * 1000)
end

local scriptStart = tick()

-- ========== UPDATE FUNCTION ==========
local function update()
    local disp = player.DisplayName
    local name = player.Name
    charLabel.Text = disp ~= name and disp.." (@"..name..")" or name
    miniName.Text  = charLabel.Text
    local lv = getStat("Level")
    lvlLabel.Text = "LV. " .. formatVal(lv, "Level")
    miniLvl.Text  = "LV. " .. formatVal(lv, "Level")
    leftCards.Beli.value.Text   = formatVal(getStat("Beli"), "Beli")
    leftCards.Frag.value.Text   = formatVal(getStat("Fragments"), "Fragments")
    leftCards.Team.value.Text   = player.Team and player.Team.Name or "N/A"
    leftCards.Players.value.Text = #Players:GetPlayers() .. " / " .. MAX_PLAYERS
    local elapsed = tick() - scriptStart
    local h = math.floor(elapsed/3600)
    local m = math.floor((elapsed%3600)/60)
    local s = math.floor(elapsed%60)
    local timeStr = string.format("%02d:%02d:%02d",h,m,s)
    leftCards.Time.value.Text = timeStr
    timeLabel.Text = timeStr
    leftCards.Equip.value.Text = getEquippedItem()
    for name2, card in pairs(rightCards) do
        local statKey = name2 == "Fruit" and "Blox Fruit" or name2
        local val = getStat(statKey)
        card.value.Text = formatVal(val)
        if card.barFill then
            card.barFill.Size = UDim2.new(math.clamp(tonumber(val)/COMBAT_CAP,0,1),0,1,0)
        end
    end
    fpsLabel.Text = "FPS "..fps
    local ping = getPing()
    pingLabel.Text = "PING "..ping.." ms"
    pingLabel.TextColor3 = ping<80 and C.SUCCESS or ping<150 and C.WARN or C.DANGER
    if miniStats.Level then miniStats.Level.Text = formatVal(lv,"Level") end
    if miniStats.Beli then miniStats.Beli.Text = formatVal(getStat("Beli"),"Beli") end
    if miniStats.Fragments then miniStats.Fragments.Text = formatVal(getStat("Fragments"),"Fragments") end
    local curCap = 0
    pcall(function() curCap = settings().Rendering.FrameRateManager.MaxFrameRate end)
    capBox.PlaceholderText = curCap>0 and tostring(curCap) or "∞"
    updatePlayerCount()
end

local fadeTargets = {
    avatar, charLabel, lvlLabel, onlineDot,
    leftCards.Beli.card, leftCards.Frag.card, leftCards.Team.card,
    leftCards.Players.card, leftCards.Time.card, leftCards.Equip.card,
    rightCards.Melee.card, rightCards.Defense.card, rightCards.Sword.card,
    rightCards.Gun.card, rightCards.Fruit.card,
    pcBar, bottomBar,
}

local originalTransparency = {}
local function snapshotTransparency(obj)
    local snap = { bg = obj.BackgroundTransparency, children = {} }
    for _, child in ipairs(obj:GetDescendants()) do
        local cd = {}
        if child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("TextLabel") or child:IsA("TextButton") then
            cd.bg = child.BackgroundTransparency
        end
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            cd.text = child.TextTransparency
        end
        if child:IsA("ImageLabel") then
            cd.img = child.ImageTransparency
        end
        if child:IsA("UIStroke") then
            cd.stroke = child.Transparency
        end
        snap.children[child] = cd
    end
    return snap
end

local function hideElement(obj)
    obj.BackgroundTransparency = 1
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("ImageLabel") or child:IsA("TextLabel") or child:IsA("TextButton") then
            child.BackgroundTransparency = 1
        end
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextTransparency = 1
        end
        if child:IsA("ImageLabel") then
            child.ImageTransparency = 1
        end
        if child:IsA("UIStroke") then
            child.Transparency = 1
        end
    end
end

for _, obj in ipairs(fadeTargets) do
    originalTransparency[obj] = snapshotTransparency(obj)
    hideElement(obj)
end

local function fadeInElement(obj)
    local snap = originalTransparency[obj]
    if not snap then return end
    task.spawn(function()
        local s = tick()
        local DUR = 0.35
        while true do
            local r = math.min((tick() - s) / DUR, 1)
            local ease = r * r * (3 - 2 * r)
            local inv = 1 - ease
            if obj and obj.Parent then
                obj.BackgroundTransparency = snap.bg + (1 - snap.bg) * inv
            end
            for child, cd in pairs(snap.children) do
                if child and child.Parent then
                    if cd.bg    ~= nil then child.BackgroundTransparency = cd.bg    + (1 - cd.bg)    * inv end
                    if cd.text  ~= nil then child.TextTransparency       = cd.text  + (1 - cd.text)  * inv end
                    if cd.img   ~= nil then child.ImageTransparency      = cd.img   + (1 - cd.img)   * inv end
                    if cd.stroke~= nil then child.Transparency           = cd.stroke+ (1 - cd.stroke)* inv end
                end
            end
            if r >= 1 then break end
            RunService.Heartbeat:Wait()
        end
    end)
end

local LOAD_ELEMENTS = {
    { text = "Loading account...",      key = "avatar" },
    { text = "Loading username...",     key = "charLabel" },
    { text = "Loading level...",        key = "lvlLabel" },
    { text = "Loading status...",       key = "onlineDot" },
    { text = "Loading beli...",         key = "leftCards.Beli" },
    { text = "Loading fragments...",    key = "leftCards.Frag" },
    { text = "Loading team...",         key = "leftCards.Team" },
    { text = "Loading players...",      key = "leftCards.Players" },
    { text = "Loading runtime...",      key = "leftCards.Time" },
    { text = "Loading equipped...",     key = "leftCards.Equip" },
    { text = "Loading melee...",        key = "rightCards.Melee" },
    { text = "Loading defense...",      key = "rightCards.Defense" },
    { text = "Loading sword...",        key = "rightCards.Sword" },
    { text = "Loading gun...",          key = "rightCards.Gun" },
    { text = "Loading blox fruit...",   key = "rightCards.Fruit" },
    { text = "Loading player bar...",   key = "pcBar" },
    { text = "Loading bottom bar...",   key = "bottomBar" },
}

local fadeTargetNames = {
    avatar                = avatar,
    charLabel             = charLabel,
    lvlLabel              = lvlLabel,
    onlineDot             = onlineDot,
    ["leftCards.Beli"]    = leftCards.Beli.card,
    ["leftCards.Frag"]    = leftCards.Frag.card,
    ["leftCards.Team"]    = leftCards.Team.card,
    ["leftCards.Players"] = leftCards.Players.card,
    ["leftCards.Time"]    = leftCards.Time.card,
    ["leftCards.Equip"]   = leftCards.Equip.card,
    ["rightCards.Melee"]   = rightCards.Melee.card,
    ["rightCards.Defense"] = rightCards.Defense.card,
    ["rightCards.Sword"]   = rightCards.Sword.card,
    ["rightCards.Gun"]     = rightCards.Gun.card,
    ["rightCards.Fruit"]   = rightCards.Fruit.card,
    pcBar                 = pcBar,
    bottomBar             = bottomBar,
}

local TOTAL = #LOAD_ELEMENTS

local function hbWait(n)
    local s = tick()
    repeat RunService.Heartbeat:Wait() until tick() - s >= n
end

local function animateStep(fromPct, toPct, dur, overlayFrom, overlayTo)
    local s = tick()
    while true do
        local r = math.min((tick() - s) / dur, 1)
        local ease = r * r * (3 - 2 * r)
        local v = fromPct + (toPct - fromPct) * ease
        loadBarFill.Size  = UDim2.new(v, 0, 1, 0)
        loadPctLabel.Text = math.floor(v * 100) .. "%"
        local oa = overlayFrom + (overlayTo - overlayFrom) * ease
        loadOverlay.BackgroundTransparency = oa
        for _, child in ipairs(loadOverlay:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                child.TextTransparency = math.max(0, oa - 0.3) / 0.7
            elseif child:IsA("ImageLabel") then
                child.ImageTransparency = math.max(0, oa - 0.3) / 0.7
                child.BackgroundTransparency = oa
            elseif child:IsA("Frame") then
                child.BackgroundTransparency = oa
            elseif child:IsA("UIStroke") then
                child.Transparency = math.max(0, oa - 0.3) / 0.7
            end
        end
        if r >= 1 then break end
        RunService.Heartbeat:Wait()
    end
end

task.spawn(function()
    update()

    for i, item in ipairs(LOAD_ELEMENTS) do
        local fromPct = (i - 1) / TOTAL
        local toPct   = i / TOTAL

        loadStepLabel.Text = item.text

        local obj = fadeTargetNames[item.key]
        if obj then fadeInElement(obj) end

        local overlayFrom = 0.4 + (0.2 * ((i-1)/TOTAL))
        local overlayTo   = 0.4 + (0.2 * (i/TOTAL))

        animateStep(fromPct, toPct, 0.45, overlayFrom, overlayTo)
        hbWait(0.05)
    end

    local startAlpha = loadOverlay.BackgroundTransparency
    local s = tick()
    while true do
        local r = math.min((tick() - s) / 0.5, 1)
        local ease = r * r * (3 - 2 * r)
        local a = startAlpha + (1 - startAlpha) * ease
        loadOverlay.BackgroundTransparency = a
        for _, child in ipairs(loadOverlay:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                child.TextTransparency = ease
            elseif child:IsA("ImageLabel") then
                child.ImageTransparency = ease
                child.BackgroundTransparency = a
            elseif child:IsA("Frame") then
                child.BackgroundTransparency = a
            elseif child:IsA("UIStroke") then
                child.Transparency = ease
            end
        end
        if r >= 1 then break end
        RunService.Heartbeat:Wait()
    end

    loadOverlay:Destroy()

    task.spawn(function()
        while true do update(); task.wait(0.1) end
    end)
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if isMini then setView(false) else setView(true) end
    end
end)
