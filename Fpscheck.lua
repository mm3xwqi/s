local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

for _, v in ipairs(LP:WaitForChild("PlayerGui"):GetChildren()) do
    if v.Name == "PerfHUD" or v.Name == "BloxHUD" then v:Destroy() end
end

local HudGui = Instance.new("ScreenGui")
HudGui.Name = "PerfHUD"
HudGui.ResetOnSpawn = false
HudGui.Parent = LP:WaitForChild("PlayerGui")

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 280, 0, 54)
Card.Position = UDim2.new(0, 12, 0, 12)
Card.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
Card.BackgroundTransparency = 0.35
Card.BorderSizePixel = 0
Card.Active = true
Card.Draggable = true
Card.Parent = HudGui
Instance.new("UICorner", Card).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", Card)
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Thickness = 1
stroke.Transparency = 0.82

local function makeSep(xPos)
    local sep = Instance.new("Frame", Card)
    sep.Size = UDim2.new(0, 1, 0, 26)
    sep.Position = UDim2.new(0, xPos, 0.5, -13)
    sep.BackgroundColor3 = Color3.fromRGB(255,255,255)
    sep.BackgroundTransparency = 0.8
    sep.BorderSizePixel = 0
end
makeSep(92); makeSep(188)

local function makeSection(tagText, xCenter)
    local tag = Instance.new("TextLabel", Card)
    tag.Size = UDim2.new(0, 80, 0, 16)
    tag.Position = UDim2.new(0, xCenter-40, 0, 7)
    tag.BackgroundTransparency = 1
    tag.Text = tagText
    tag.TextColor3 = Color3.fromRGB(180,180,200)
    tag.TextSize = 10
    tag.Font = Enum.Font.GothamBold
    tag.TextXAlignment = Enum.TextXAlignment.Center
    tag.TextStrokeTransparency = 0.6
    tag.TextStrokeColor3 = Color3.new(0,0,0)
    local val = Instance.new("TextLabel", Card)
    val.Size = UDim2.new(0, 80, 0, 26)
    val.Position = UDim2.new(0, xCenter-40, 0, 22)
    val.BackgroundTransparency = 1
    val.Text = "---"
    val.TextSize = 20
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Center
    val.TextStrokeTransparency = 0.5
    val.TextStrokeColor3 = Color3.new(0,0,0)
    return val
end

local fpsVal  = makeSection("FPS",  46)
local pingVal = makeSection("PING", 140)
local timeVal = makeSection("TIME", 234)
fpsVal.TextColor3  = Color3.fromRGB(74,222,128)
pingVal.TextColor3 = Color3.fromRGB(250,200,40)
timeVal.TextColor3 = Color3.fromRGB(192,132,252)

local _start = tick()
RunService.Heartbeat:Connect(function()
    local e = math.floor(tick()-_start)
    timeVal.Text = e>=3600
        and string.format("%d:%02d:%02d",math.floor(e/3600),math.floor((e%3600)/60),e%60)
        or  string.format("%02d:%02d",math.floor(e/60),e%60)
end)

local _fc, _lt = 0, tick()
RunService.RenderStepped:Connect(function()
    _fc += 1
    local now = tick(); local d = now-_lt
    if d >= 0.5 then
        local fps = math.floor(_fc/d); _fc=0; _lt=now
        local c = fps>=60 and Color3.fromRGB(74,222,128) or fps>=30 and Color3.fromRGB(250,200,40) or Color3.fromRGB(255,70,70)
        fpsVal.Text = tostring(fps); fpsVal.TextColor3 = c
    end
end)

RunService.Heartbeat:Connect(function()
    local ok, ping = pcall(function() return math.floor(LP:GetNetworkPing()*1000) end)
    if not ok then return end
    ping = math.max(0,ping)
    local c = ping<=80 and Color3.fromRGB(74,222,128) or ping<=200 and Color3.fromRGB(250,200,40) or Color3.fromRGB(255,70,70)
    pingVal.Text = tostring(ping).." ms"; pingVal.TextColor3 = c
end)

local function addCommas(n)
    local s = tostring(math.floor(n))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function fmt(v, key)
    local NO_ABBREV = {Beli=true, Fragments=true}
    if type(v)=="number" then
        if NO_ABBREV[key] then return addCommas(v) end
        if v>=1e6 then return string.format("%.1fM",v/1e6)
        elseif v>=1e3 then return string.format("%.1fK",v/1e3)
        else return tostring(math.floor(v)) end
    end
    return tostring(v or "?")
end

local function parseNumber(str)
    if not str then return nil end
    local s = str:gsub(",", ""):gsub("%s+", "")
    local abbrev, suffix = s:match("([%d%.]+)([MmKk])")
    if abbrev then
        local n = tonumber(abbrev) or 0
        if suffix:lower()=="m" then return math.floor(n*1e6)
        elseif suffix:lower()=="k" then return math.floor(n*1e3) end
    end
    local plain = s:match("(%d+)")
    return plain and tonumber(plain) or nil
end

local function parseExpBar(str)
    if not str then return nil, nil end
    local s = str:gsub(",", "")
    local cur, needed = s:match("(%d+)/(%d+)")
    return cur and tonumber(cur) or nil,
           needed and tonumber(needed) or nil
end

local function parseBeli(rewardText)
    if not rewardText then return nil end
    local questBeli = nil
    for line in rewardText:gmatch("[^\n]+") do
        local s = line:match("^%s*(.-)%s*$")
        if s:find("^%$") or s:lower():find("beli") then
            local n = parseNumber(s)
            if n and n > 0 then questBeli = n end
        end
    end
    if not questBeli and rewardText:find("%$") then
        local s = rewardText:gsub(",","")
        local n = s:match("%$%s*(%d+)")
        if n then questBeli = tonumber(n) end
    end
    return questBeli
end

local function parseQuestExp(rewardText)
    if not rewardText then return nil end
    for line in rewardText:gmatch("[^\n]+") do
        local s = line:match("^%s*(.-)%s*$")
        if s:lower():find("exp") or s:lower():find("xp") then
            local n = parseNumber(s)
            if n and n > 0 then return n end
        end
    end
    return nil
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "BloxHUD"
MainGui.ResetOnSpawn = false
MainGui.Parent = LP:WaitForChild("PlayerGui")

local CARD_W = 260

local function newFrame(parent, size, pos, bg, bgTrans, radius)
    local f = Instance.new("Frame", parent)
    f.Size = size; f.Position = pos
    f.BackgroundColor3 = bg or Color3.fromRGB(10,10,18)
    f.BackgroundTransparency = bgTrans or 0
    f.BorderSizePixel = 0
    if radius then Instance.new("UICorner", f).CornerRadius = radius end
    return f
end

local function newLabel(parent, text, size, color, font, xAlign, sizeUDim, pos)
    local l = Instance.new("TextLabel", parent)
    l.Size = sizeUDim; l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = text; l.TextColor3 = color; l.TextSize = size
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.TextStrokeTransparency = 0.4
    l.TextStrokeColor3 = Color3.new(0,0,0)
    return l
end

local function newDivH(parent, y)
    local d = Instance.new("Frame", parent)
    d.Size = UDim2.new(1,-16,0,1)
    d.Position = UDim2.new(0,8,0,y)
    d.BackgroundColor3 = Color3.fromRGB(255,255,255)
    d.BackgroundTransparency = 0.88
    d.BorderSizePixel = 0
end

local P_DIV1_Y     = 68
local P_INFO_Y     = 76
local P_DIV2_Y     = 136
local P_COMBAT_Y   = 142
local P_COMBAT_ROW = 158

local Q_Y = 278


local TOTAL_H = Q_Y + 184

local PC = newFrame(MainGui,
    UDim2.new(0, CARD_W, 0, TOTAL_H),
    UDim2.new(0, 12, 0, 78),
    Color3.fromRGB(10,10,18), 0.15, UDim.new(0,12))
local pcStroke = Instance.new("UIStroke", PC)
pcStroke.Color = Color3.fromRGB(255,255,255)
pcStroke.Thickness = 0.8; pcStroke.Transparency = 0.85
PC.Active = true; PC.Draggable = true

local avFrame = newFrame(PC, UDim2.new(0,50,0,50), UDim2.new(0,10,0,10),
    Color3.fromRGB(30,30,45), 0, UDim.new(1,0))
local avStroke = Instance.new("UIStroke", avFrame)
avStroke.Color = Color3.fromRGB(192,132,252); avStroke.Thickness = 1.5; avStroke.Transparency = 0.2
local avImg = Instance.new("ImageLabel", avFrame)
avImg.Size = UDim2.new(1,0,1,0); avImg.BackgroundTransparency = 1; avImg.BorderSizePixel = 0
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1,0)
local okT, th = pcall(function()
    return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)
if okT then avImg.Image = th end

newLabel(PC, LP.DisplayName, 15, Color3.fromRGB(255,255,255),
    Enum.Font.GothamBold, Enum.TextXAlignment.Left,
    UDim2.new(0,170,0,18), UDim2.new(0,66,0,10))
newLabel(PC, "@"..LP.Name, 10, Color3.fromRGB(180,180,210),
    Enum.Font.Gotham, Enum.TextXAlignment.Left,
    UDim2.new(0,170,0,14), UDim2.new(0,66,0,30))

newDivH(PC, P_DIV1_Y)

local infoStats = {
    {tag="LEVEL",     key="Level",     color=Color3.fromRGB(255,215,60)},
    {tag="BELI",      key="Beli",      color=Color3.fromRGB(80,235,140)},
    {tag="FRAGMENTS", key="Fragments", color=Color3.fromRGB(200,130,255)},
    {tag="RACE",      key="Race",      color=Color3.fromRGB(210,150,255)},
}
local infoLabels = {}
for i, s in ipairs(infoStats) do
    local col = (i==1 or i==3) and 0 or 1
    local row = (i<=2) and 0 or 1
    local x = 10 + col*122
    local y = P_INFO_Y + row*28
    newLabel(PC, s.tag, 9, Color3.fromRGB(180,180,210),
        Enum.Font.GothamBold, Enum.TextXAlignment.Left,
        UDim2.new(0,114,0,11), UDim2.new(0,x,0,y))
    local vl = newLabel(PC, "...", 14, s.color,
        Enum.Font.GothamBold, Enum.TextXAlignment.Left,
        UDim2.new(0,114,0,15), UDim2.new(0,x,0,y+12))
    infoLabels[s.key] = vl
end

local vs = Instance.new("Frame", PC)
vs.Size = UDim2.new(0,1,0,52); vs.Position = UDim2.new(0,126,0,74)
vs.BackgroundColor3 = Color3.fromRGB(255,255,255)
vs.BackgroundTransparency = 0.88; vs.BorderSizePixel = 0

newDivH(PC, P_DIV2_Y)

newLabel(PC, "COMBAT STATS", 10, Color3.fromRGB(200,200,230),
    Enum.Font.GothamBold, Enum.TextXAlignment.Left,
    UDim2.new(1,-16,0,12), UDim2.new(0,10,0,P_COMBAT_Y))

local combatStats = {
    {tag="Melee",       icon="👊", color=Color3.fromRGB(255,175,90)},
    {tag="Defense",     icon="🛡",  color=Color3.fromRGB(120,190,255)},
    {tag="Sword",       icon="⚔",  color=Color3.fromRGB(225,190,255)},
    {tag="Gun",         icon="🔫", color=Color3.fromRGB(90,235,150)},
    {tag="Demon Fruit", icon="🍎", color=Color3.fromRGB(255,120,150)},
}
local combatLabels = {}
for i, s in ipairs(combatStats) do
    local y = P_COMBAT_ROW + (i-1)*22
    local ico = Instance.new("TextLabel", PC)
    ico.Size = UDim2.new(0,20,0,20); ico.Position = UDim2.new(0,8,0,y)
    ico.BackgroundTransparency = 1; ico.Text = s.icon; ico.TextSize = 14
    ico.Font = Enum.Font.Gotham; ico.TextXAlignment = Enum.TextXAlignment.Center
    ico.TextStrokeTransparency = 1
    newLabel(PC, s.tag, 12, Color3.fromRGB(220,220,240),
        Enum.Font.GothamBold, Enum.TextXAlignment.Left,
        UDim2.new(0,100,0,20), UDim2.new(0,30,0,y))
    local barBg = newFrame(PC, UDim2.new(0,95,0,4), UDim2.new(0,30,0,y+17),
        Color3.fromRGB(50,50,70), 0, UDim.new(1,0))
    local barFill = newFrame(barBg, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0),
        s.color, 0, UDim.new(1,0))
    local vl = newLabel(PC, "...", 12, s.color,
        Enum.Font.GothamBold, Enum.TextXAlignment.Right,
        UDim2.new(0,50,0,20), UDim2.new(0,200,0,y))
    combatLabels[s.tag] = {label=vl, bar=barFill}
end

newDivH(PC, Q_Y)

local qHeader = Instance.new("TextLabel", PC)
qHeader.Size = UDim2.new(1,-16,0,16)
qHeader.Position = UDim2.new(0,8,0, Q_Y+10)
qHeader.BackgroundTransparency = 1
qHeader.Text = "📋  QUEST"
qHeader.TextColor3 = Color3.fromRGB(255,200,60)
qHeader.TextSize = 10
qHeader.Font = Enum.Font.GothamBold
qHeader.TextXAlignment = Enum.TextXAlignment.Left
qHeader.TextStrokeTransparency = 0.4
qHeader.TextStrokeColor3 = Color3.new(0,0,0)

newDivH(PC, Q_Y+30)

local qTitleTag = Instance.new("TextLabel", PC)
qTitleTag.Size = UDim2.new(1,-16,0,11)
qTitleTag.Position = UDim2.new(0,8,0, Q_Y+38)
qTitleTag.BackgroundTransparency = 1; qTitleTag.Text = "QUEST NAME"
qTitleTag.TextColor3 = Color3.fromRGB(160,160,190); qTitleTag.TextSize = 9
qTitleTag.Font = Enum.Font.GothamBold; qTitleTag.TextXAlignment = Enum.TextXAlignment.Left
qTitleTag.TextStrokeTransparency = 0.5; qTitleTag.TextStrokeColor3 = Color3.new(0,0,0)

local qTitleVal = Instance.new("TextLabel", PC)
qTitleVal.Size = UDim2.new(1,-16,0,26)
qTitleVal.Position = UDim2.new(0,8,0, Q_Y+50)
qTitleVal.BackgroundTransparency = 1; qTitleVal.Text = "No quests"
qTitleVal.TextColor3 = Color3.fromRGB(160,160,190); qTitleVal.TextSize = 13
qTitleVal.Font = Enum.Font.GothamBold; qTitleVal.TextXAlignment = Enum.TextXAlignment.Left
qTitleVal.TextWrapped = true; qTitleVal.TextStrokeTransparency = 0.4
qTitleVal.TextStrokeColor3 = Color3.new(0,0,0)

newDivH(PC, Q_Y+80)

local qRewardTag = Instance.new("TextLabel", PC)
qRewardTag.Size = UDim2.new(1,-16,0,11)
qRewardTag.Position = UDim2.new(0,8,0, Q_Y+90)
qRewardTag.BackgroundTransparency = 1; qRewardTag.Text = "REWARD"
qRewardTag.TextColor3 = Color3.fromRGB(160,160,190); qRewardTag.TextSize = 9
qRewardTag.Font = Enum.Font.GothamBold; qRewardTag.TextXAlignment = Enum.TextXAlignment.Left
qRewardTag.TextStrokeTransparency = 0.5; qRewardTag.TextStrokeColor3 = Color3.new(0,0,0)

local qExpIcon = Instance.new("TextLabel", PC)
qExpIcon.Size = UDim2.new(0,18,0,18)
qExpIcon.Position = UDim2.new(0,8,0, Q_Y+104)
qExpIcon.BackgroundTransparency = 1; qExpIcon.Text = "⚡"
qExpIcon.TextSize = 13; qExpIcon.Font = Enum.Font.Gotham
qExpIcon.TextXAlignment = Enum.TextXAlignment.Center; qExpIcon.TextStrokeTransparency = 1

local qExpVal = Instance.new("TextLabel", PC)
qExpVal.Size = UDim2.new(1,-32,0,18)
qExpVal.Position = UDim2.new(0,28,0, Q_Y+104)
qExpVal.BackgroundTransparency = 1; qExpVal.Text = "---"
qExpVal.TextColor3 = Color3.fromRGB(74,222,128); qExpVal.TextSize = 12
qExpVal.Font = Enum.Font.GothamBold; qExpVal.TextXAlignment = Enum.TextXAlignment.Left
qExpVal.TextStrokeTransparency = 0.4; qExpVal.TextStrokeColor3 = Color3.new(0,0,0)

local expBarBg = newFrame(PC,
    UDim2.new(1,-16,0,4),
    UDim2.new(0,8,0, Q_Y+124),
    Color3.fromRGB(40,40,60), 0, UDim.new(1,0))
local expBarCur = newFrame(expBarBg, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0),
    Color3.fromRGB(74,222,128), 0, UDim.new(1,0))
local expBarAdd = newFrame(expBarBg, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0),
    Color3.fromRGB(255,215,60), 0.4, UDim.new(1,0))

local qCountIcon = Instance.new("TextLabel", PC)
qCountIcon.Size = UDim2.new(0,18,0,18)
qCountIcon.Position = UDim2.new(0,8,0, Q_Y+132)
qCountIcon.BackgroundTransparency = 1; qCountIcon.Text = "LevelUp!"
qCountIcon.TextSize = 13; qCountIcon.Font = Enum.Font.Gotham
qCountIcon.TextXAlignment = Enum.TextXAlignment.Center; qCountIcon.TextStrokeTransparency = 1

local qCountVal = Instance.new("TextLabel", PC)
qCountVal.Size = UDim2.new(1,-32,0,18)
qCountVal.Position = UDim2.new(0,28,0, Q_Y+132)
qCountVal.BackgroundTransparency = 1; qCountVal.Text = "---"
qCountVal.TextColor3 = Color3.fromRGB(180,180,210); qCountVal.TextSize = 12
qCountVal.Font = Enum.Font.GothamBold; qCountVal.TextXAlignment = Enum.TextXAlignment.Left
qCountVal.TextStrokeTransparency = 0.4; qCountVal.TextStrokeColor3 = Color3.new(0,0,0)

newDivH(PC, Q_Y+154)

local qBeliIcon = Instance.new("TextLabel", PC)
qBeliIcon.Size = UDim2.new(0,18,0,18)
qBeliIcon.Position = UDim2.new(0,8,0, Q_Y+162)
qBeliIcon.BackgroundTransparency = 1; qBeliIcon.Text = "💰"
qBeliIcon.TextSize = 13; qBeliIcon.Font = Enum.Font.Gotham
qBeliIcon.TextXAlignment = Enum.TextXAlignment.Center; qBeliIcon.TextStrokeTransparency = 1

local qBeliVal = Instance.new("TextLabel", PC)
qBeliVal.Size = UDim2.new(1,-32,0,18)
qBeliVal.Position = UDim2.new(0,28,0, Q_Y+162)
qBeliVal.BackgroundTransparency = 1; qBeliVal.Text = "---"
qBeliVal.TextColor3 = Color3.fromRGB(80,235,140); qBeliVal.TextSize = 12
qBeliVal.Font = Enum.Font.GothamBold; qBeliVal.TextXAlignment = Enum.TextXAlignment.Left
qBeliVal.TextStrokeTransparency = 0.4; qBeliVal.TextStrokeColor3 = Color3.new(0,0,0)

local MAX_STAT = 2550

local function updateData()
    local Data = LP:FindFirstChild("Data")
    if not Data then return end
    for _, k in ipairs({"Level","Beli","Fragments","Race"}) do
        local c = Data:FindFirstChild(k)
        if c and infoLabels[k] then infoLabels[k].Text = fmt(c.Value, k) end
    end
    local Stats = Data:FindFirstChild("Stats")
    if not Stats then return end
    for _, s in ipairs(combatStats) do
        local node = Stats:FindFirstChild(s.tag)
        if node then
            local lvNode = node:FindFirstChild("Level")
            if lvNode and combatLabels[s.tag] then
                local v = lvNode.Value or 0
                combatLabels[s.tag].label.Text = tostring(v)
                combatLabels[s.tag].bar.Size = UDim2.new(math.clamp(v/MAX_STAT,0,1),0,1,0)
            end
        end
    end
end

task.spawn(function()
    local Data = LP:WaitForChild("Data", 10)
    if not Data then return end
    updateData()
    local function watch(obj) if obj then obj.Changed:Connect(updateData) end end
    for _, k in ipairs({"Level","Beli","Fragments","Race"}) do
        watch(Data:WaitForChild(k, 5))
    end
    local Stats = Data:WaitForChild("Stats", 5)
    if Stats then
        for _, s in ipairs(combatStats) do
            local node = Stats:WaitForChild(s.tag, 5)
            if node then watch(node:WaitForChild("Level", 5)) end
        end
    end
end)

local function updateQuest()
    local questVisible = false
    local rawTitle, rawReward = "", ""
    pcall(function()
        local questFrame = LP.PlayerGui.Main.Quest
        questVisible = questFrame.Visible
        if questVisible then
            rawTitle  = questFrame.Container.QuestTitle.Title.ContentText  or ""
            rawReward = questFrame.Container.QuestReward.Title.ContentText or ""
        end
    end)

    if not questVisible or rawTitle == "" then
        qTitleVal.Text       = "No quests"
        qTitleVal.TextColor3 = Color3.fromRGB(160,160,190)
        qExpVal.Text         = "---"
        qCountVal.Text       = "---"
        qBeliVal.Text        = "---"
        expBarCur.Size       = UDim2.new(0,0,1,0)
        expBarAdd.Size       = UDim2.new(0,0,1,0)
        expBarCur.BackgroundColor3 = Color3.fromRGB(74,222,128)
        return
    end

    qTitleVal.Text       = rawTitle
    qTitleVal.TextColor3 = Color3.fromRGB(255,255,255)

    local currentExp, neededExp = nil, nil
    pcall(function()
        local expText = LP.PlayerGui.Main.Level.Exp.ContentText
        currentExp, neededExp = parseExpBar(expText)
    end)

    local questExp = parseQuestExp(rawReward)

    local currentLevel = 0
    pcall(function() currentLevel = LP.Data.Level.Value or 0 end)

    if questExp and currentExp and neededExp and neededExp > 0 then
        local expAfter = currentExp + questExp
        local pctCur   = math.clamp(currentExp / neededExp, 0, 1)
        local pctAfter = math.clamp(expAfter   / neededExp, 0, 1)

        expBarCur.Size = UDim2.new(pctCur, 0, 1, 0)
        expBarAdd.Size = UDim2.new(pctAfter - pctCur, 0, 1, 0)
        expBarAdd.Position = UDim2.new(pctCur, 0, 0, 0)

        if expAfter >= neededExp then
            qExpVal.Text = string.format("+%s  Next  Lv.%d → Lv.%d",
                addCommas(questExp), currentLevel, currentLevel + 1)
            qExpVal.TextColor3 = Color3.fromRGB(255,215,60)
            expBarCur.BackgroundColor3 = Color3.fromRGB(255,215,60)
            qCountVal.Text = ""
        else
            qExpVal.Text = string.format("+%s  →  %s / %s",
                addCommas(questExp), addCommas(expAfter), addCommas(neededExp))
            qExpVal.TextColor3 = Color3.fromRGB(74,222,128)
            expBarCur.BackgroundColor3 = Color3.fromRGB(74,222,128)

            local expRemaining = neededExp - expAfter
            local questsNeeded = math.ceil(expRemaining / questExp)
            local targetLevel  = currentLevel + 1

            if questsNeeded <= 1 then
                qCountVal.Text       = string.format("อีก 1 quest → Lv.%d", targetLevel)
                qCountVal.TextColor3 = Color3.fromRGB(250,200,40)
            else
                qCountVal.Text       = string.format("อีก %d quests → Lv.%d", questsNeeded, targetLevel)
                qCountVal.TextColor3 = Color3.fromRGB(180,180,210)
            end
        end
    else
        local expLine = "---"
        for line in rawReward:gmatch("[^\n]+") do
            local s = line:match("^%s*(.-)%s*$")
            if s:lower():find("exp") or s:lower():find("xp") then
                expLine = s; break
            end
        end
        qExpVal.Text       = expLine
        qExpVal.TextColor3 = Color3.fromRGB(160,160,190)
        qCountVal.Text     = "---"
        expBarCur.Size     = UDim2.new(0,0,1,0)
        expBarAdd.Size     = UDim2.new(0,0,1,0)
    end

    local questBeli = parseBeli(rawReward)
    if questBeli then
        local currentBeli = 0
        pcall(function() currentBeli = LP.Data.Beli.Value or 0 end)
        qBeliVal.Text = string.format("+%s  →  %s",
            addCommas(questBeli), addCommas(currentBeli + questBeli))
        qBeliVal.TextColor3 = Color3.fromRGB(80,235,140)
    else
        qBeliVal.Text       = "---"
        qBeliVal.TextColor3 = Color3.fromRGB(160,160,190)
    end
end

task.spawn(function()
    while true do
        pcall(updateQuest)
        task.wait(1)
    end
end)
