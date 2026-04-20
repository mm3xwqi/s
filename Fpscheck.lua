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

local PerfCard = Instance.new("Frame")
PerfCard.Size = UDim2.new(0,280,0,54)
PerfCard.Position = UDim2.new(0,12,0,12)
PerfCard.BackgroundColor3 = Color3.fromRGB(14,14,24)
PerfCard.BackgroundTransparency = 0.35
PerfCard.BorderSizePixel = 0
PerfCard.Active = true; PerfCard.Draggable = true
PerfCard.Parent = HudGui
Instance.new("UICorner",PerfCard).CornerRadius = UDim.new(1,0)
local perfStroke = Instance.new("UIStroke",PerfCard)
perfStroke.Color = Color3.fromRGB(255,255,255)
perfStroke.Thickness = 1; perfStroke.Transparency = 0.82

local function makeSep(xPos)
    local s = Instance.new("Frame",PerfCard)
    s.Size = UDim2.new(0,1,0,26); s.Position = UDim2.new(0,xPos,0.5,-13)
    s.BackgroundColor3 = Color3.fromRGB(255,255,255)
    s.BackgroundTransparency = 0.8; s.BorderSizePixel = 0
end
makeSep(92); makeSep(188)

local function makePerfSection(tagText, xCenter)
    local tag = Instance.new("TextLabel",PerfCard)
    tag.Size = UDim2.new(0,80,0,16); tag.Position = UDim2.new(0,xCenter-40,0,7)
    tag.BackgroundTransparency = 1; tag.Text = tagText
    tag.TextColor3 = Color3.fromRGB(180,180,200); tag.TextSize = 10
    tag.Font = Enum.Font.GothamBold; tag.TextXAlignment = Enum.TextXAlignment.Center
    tag.TextStrokeTransparency = 0.6; tag.TextStrokeColor3 = Color3.new(0,0,0)
    local val = Instance.new("TextLabel",PerfCard)
    val.Size = UDim2.new(0,80,0,26); val.Position = UDim2.new(0,xCenter-40,0,22)
    val.BackgroundTransparency = 1; val.Text = "---"; val.TextSize = 20
    val.Font = Enum.Font.GothamBold; val.TextXAlignment = Enum.TextXAlignment.Center
    val.TextStrokeTransparency = 0.5; val.TextStrokeColor3 = Color3.new(0,0,0)
    return val
end

local fpsVal  = makePerfSection("FPS",  46)
local pingVal = makePerfSection("PING", 140)
local timeVal = makePerfSection("TIME", 234)
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
    return s:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end

local function fmt(v, key)
    local NO_ABBREV = { Beli=true, Fragments=true, Level=true }
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
    local s = str:gsub(",",""):gsub("%s+","")
    local a,suf = s:match("([%d%.]+)([MmKk])")
    if a then
        local n = tonumber(a) or 0
        if suf:lower()=="m" then return math.floor(n*1e6)
        elseif suf:lower()=="k" then return math.floor(n*1e3) end
    end
    local p = s:match("(%d+)")
    return p and tonumber(p) or nil
end

local function parseExpBar(str)
    if not str then return nil,nil end
    local s = str:gsub(",","")
    local cur,needed = s:match("(%d+)/(%d+)")
    return cur and tonumber(cur) or nil, needed and tonumber(needed) or nil
end

local function parseBeli(rt)
    if not rt then return nil end
    local b = nil
    for line in rt:gmatch("[^\n]+") do
        local s = line:match("^%s*(.-)%s*$")
        if s:find("^%$") or s:lower():find("beli") then
            local n = parseNumber(s); if n and n>0 then b=n end
        end
    end
    if not b and rt:find("%$") then
        local n = rt:gsub(",",""):match("%$%s*(%d+)"); if n then b=tonumber(n) end
    end
    return b
end

local function parseQuestExp(rt)
    if not rt then return nil end
    for line in rt:gmatch("[^\n]+") do
        local s = line:match("^%s*(.-)%s*$")
        if s:lower():find("exp") or s:lower():find("xp") then
            local n = parseNumber(s); if n and n>0 then return n end
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
    local f = Instance.new("Frame",parent)
    f.Size=size; f.Position=pos
    f.BackgroundColor3=bg or Color3.fromRGB(10,10,18)
    f.BackgroundTransparency=bgTrans or 0
    f.BorderSizePixel=0
    if radius then Instance.new("UICorner",f).CornerRadius=radius end
    return f
end

local function newLabel(parent, text, size, color, font, xAlign, sizeUDim, pos)
    local l = Instance.new("TextLabel",parent)
    l.Size=sizeUDim; l.Position=pos; l.BackgroundTransparency=1
    l.Text=text; l.TextColor3=color; l.TextSize=size
    l.Font=font or Enum.Font.Gotham
    l.TextXAlignment=xAlign or Enum.TextXAlignment.Left
    l.TextStrokeTransparency=0.4; l.TextStrokeColor3=Color3.new(0,0,0)
    return l
end

local function newDivH(parent, y)
    local d = Instance.new("Frame",parent)
    d.Size=UDim2.new(1,-16,0,1); d.Position=UDim2.new(0,8,0,y)
    d.BackgroundColor3=Color3.fromRGB(255,255,255)
    d.BackgroundTransparency=0.88; d.BorderSizePixel=0
end

local P_DIV1_Y     = 68
local P_INFO_Y     = 76
local P_DIV2_Y     = 136
local P_COMBAT_Y   = 142
local P_COMBAT_ROW = 158

local Q_Y    = 278
local FULL_H = Q_Y + 212

local MINI_H = 56

local PC = newFrame(MainGui,
    UDim2.new(0,CARD_W,0,FULL_H),
    UDim2.new(0,12,0,78),
    Color3.fromRGB(10,10,18),0.15,UDim.new(0,10))
local pcStroke = Instance.new("UIStroke",PC)
pcStroke.Color=Color3.fromRGB(255,255,255)
pcStroke.Thickness=0.8; pcStroke.Transparency=0.85
PC.Active=true; PC.Draggable=true
PC.ClipsDescendants=true

local miniBar = Instance.new("Frame",PC)
miniBar.Size = UDim2.new(1,0,0,MINI_H)
miniBar.Position = UDim2.new(0,0,0,0)
miniBar.BackgroundColor3 = Color3.fromRGB(10,10,18)
miniBar.BackgroundTransparency = 0.15
miniBar.BorderSizePixel = 0
miniBar.Visible = false
Instance.new("UICorner",miniBar).CornerRadius = UDim.new(0,10)
local miniStroke = Instance.new("UIStroke",miniBar)
miniStroke.Color = Color3.fromRGB(255,255,255)
miniStroke.Thickness = 0.8; miniStroke.Transparency = 0.85

local miniName = newLabel(miniBar,"",13,Color3.fromRGB(255,255,255),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(1,-48,0,16),UDim2.new(0,10,0,8))
local miniQuest = newLabel(miniBar,"",10,Color3.fromRGB(200,200,220),
    Enum.Font.Gotham,Enum.TextXAlignment.Left,
    UDim2.new(1,-48,0,14),UDim2.new(0,10,0,28))

local isMinimised = false

local minBtn = Instance.new("TextButton",PC)
minBtn.Size = UDim2.new(0,26,0,18)
minBtn.Position = UDim2.new(1,-32,0,14)
minBtn.BackgroundColor3 = Color3.fromRGB(30,30,48)
minBtn.BorderSizePixel = 0
minBtn.Text = "▲"
minBtn.TextColor3 = Color3.fromRGB(160,160,200)
minBtn.TextSize = 9
minBtn.Font = Enum.Font.GothamBold
minBtn.AutoButtonColor = false
Instance.new("UICorner",minBtn).CornerRadius = UDim.new(0,4)
local minStroke = Instance.new("UIStroke",minBtn)
minStroke.Color = Color3.fromRGB(255,255,255); minStroke.Thickness=0.6; minStroke.Transparency=0.8

local body = Instance.new("Frame",PC)
body.Size = UDim2.new(1,0,0,FULL_H)
body.Position = UDim2.new(0,0,0,0)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0

local function applyMinimise()
    if isMinimised then
        PC.Size = UDim2.new(0,CARD_W,0,MINI_H)
        PC.BackgroundTransparency = 1
        pcStroke.Transparency = 1
        body.Visible = false
        miniBar.Visible = true
        minBtn.Text = "▼"
        minBtn.Position = UDim2.new(1,-32,0,19)
    else
        PC.Size = UDim2.new(0,CARD_W,0,FULL_H)
        PC.BackgroundTransparency = 0.15
        pcStroke.Transparency = 0.85
        body.Visible = true
        miniBar.Visible = false
        minBtn.Text = "▲"
        minBtn.Position = UDim2.new(1,-32,0,14)
    end
end

minBtn.MouseButton1Click:Connect(function()
    isMinimised = not isMinimised
    applyMinimise()
end)
local function bFrame(size,pos,bg,bgT,radius)
    local f=Instance.new("Frame",body)
    f.Size=size; f.Position=pos
    f.BackgroundColor3=bg or Color3.fromRGB(10,10,18)
    f.BackgroundTransparency=bgT or 0; f.BorderSizePixel=0
    if radius then Instance.new("UICorner",f).CornerRadius=radius end
    return f
end
local function bLabel(text,size,color,font,xAlign,sizeUDim,pos)
    local l=Instance.new("TextLabel",body)
    l.Size=sizeUDim; l.Position=pos; l.BackgroundTransparency=1
    l.Text=text; l.TextColor3=color; l.TextSize=size
    l.Font=font or Enum.Font.Gotham
    l.TextXAlignment=xAlign or Enum.TextXAlignment.Left
    l.TextStrokeTransparency=0.4; l.TextStrokeColor3=Color3.new(0,0,0)
    return l
end
local function bDivH(y)
    local d=Instance.new("Frame",body)
    d.Size=UDim2.new(1,-16,0,1); d.Position=UDim2.new(0,8,0,y)
    d.BackgroundColor3=Color3.fromRGB(255,255,255)
    d.BackgroundTransparency=0.88; d.BorderSizePixel=0
end

local avFrame = bFrame(UDim2.new(0,50,0,50),UDim2.new(0,10,0,10),
    Color3.fromRGB(30,30,45),0,UDim.new(1,0))
local avStroke = Instance.new("UIStroke",avFrame)
avStroke.Color=Color3.fromRGB(192,132,252); avStroke.Thickness=1.5; avStroke.Transparency=0.2
local avImg = Instance.new("ImageLabel",avFrame)
avImg.Size=UDim2.new(1,0,1,0); avImg.BackgroundTransparency=1; avImg.BorderSizePixel=0
Instance.new("UICorner",avImg).CornerRadius=UDim.new(1,0)
local okT,th = pcall(function()
    return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
end)
if okT then avImg.Image=th end

bLabel(LP.DisplayName,15,Color3.fromRGB(255,255,255),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(0,150,0,18),UDim2.new(0,66,0,10))
bLabel("@"..LP.Name,10,Color3.fromRGB(180,180,210),
    Enum.Font.Gotham,Enum.TextXAlignment.Left,
    UDim2.new(0,150,0,14),UDim2.new(0,66,0,30))

bDivH(P_DIV1_Y)

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
    bLabel(s.tag,9,Color3.fromRGB(180,180,210),
        Enum.Font.GothamBold,Enum.TextXAlignment.Left,
        UDim2.new(0,114,0,11),UDim2.new(0,x,0,y))
    local vl = bLabel("...",14,s.color,
        Enum.Font.GothamBold,Enum.TextXAlignment.Left,
        UDim2.new(0,114,0,15),UDim2.new(0,x,0,y+12))
    infoLabels[s.key] = vl
end
local vs=Instance.new("Frame",body)
vs.Size=UDim2.new(0,1,0,52); vs.Position=UDim2.new(0,126,0,74)
vs.BackgroundColor3=Color3.fromRGB(255,255,255)
vs.BackgroundTransparency=0.88; vs.BorderSizePixel=0

bDivH(P_DIV2_Y)

bLabel("COMBAT STATS",10,Color3.fromRGB(200,200,230),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(1,-16,0,12),UDim2.new(0,10,0,P_COMBAT_Y))

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
    local ico=Instance.new("TextLabel",body)
    ico.Size=UDim2.new(0,20,0,20); ico.Position=UDim2.new(0,8,0,y)
    ico.BackgroundTransparency=1; ico.Text=s.icon; ico.TextSize=14
    ico.Font=Enum.Font.Gotham; ico.TextXAlignment=Enum.TextXAlignment.Center
    ico.TextStrokeTransparency=1
    bLabel(s.tag,12,Color3.fromRGB(220,220,240),
        Enum.Font.GothamBold,Enum.TextXAlignment.Left,
        UDim2.new(0,100,0,20),UDim2.new(0,30,0,y))
    local barBg=bFrame(UDim2.new(0,95,0,4),UDim2.new(0,30,0,y+17),
        Color3.fromRGB(50,50,70),0,UDim.new(1,0))
    local barFill=newFrame(barBg,UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),
        s.color,0,UDim.new(1,0))
    local vl=bLabel("...",12,s.color,
        Enum.Font.GothamBold,Enum.TextXAlignment.Right,
        UDim2.new(0,50,0,20),UDim2.new(0,200,0,y))
    combatLabels[s.tag]={label=vl,bar=barFill}
end

bDivH(Q_Y)

bLabel("📋  QUEST",10,Color3.fromRGB(255,200,60),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(0,120,0,16),UDim2.new(0,8,0,Q_Y+10))

bDivH(Q_Y+30)

bLabel("QUEST NAME",9,Color3.fromRGB(160,160,190),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(1,-16,0,11),UDim2.new(0,8,0,Q_Y+38))

local qTitleVal = Instance.new("TextLabel",body)
qTitleVal.Size=UDim2.new(1,-16,0,26); qTitleVal.Position=UDim2.new(0,8,0,Q_Y+50)
qTitleVal.BackgroundTransparency=1; qTitleVal.Text="ไม่มีเควส"
qTitleVal.TextColor3=Color3.fromRGB(160,160,190); qTitleVal.TextSize=13
qTitleVal.Font=Enum.Font.GothamBold; qTitleVal.TextXAlignment=Enum.TextXAlignment.Left
qTitleVal.TextWrapped=true; qTitleVal.TextStrokeTransparency=0.4
qTitleVal.TextStrokeColor3=Color3.new(0,0,0)

bDivH(Q_Y+80)

bLabel("REWARD",9,Color3.fromRGB(160,160,190),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(1,-16,0,11),UDim2.new(0,8,0,Q_Y+90))

bLabel("⚡",13,Color3.fromRGB(255,255,255),
    Enum.Font.Gotham,Enum.TextXAlignment.Center,
    UDim2.new(0,18,0,16),UDim2.new(0,8,0,Q_Y+104))
local qExpVal1 = bLabel("---",11,Color3.fromRGB(74,222,128),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(1,-32,0,16),UDim2.new(0,28,0,Q_Y+104))

bLabel("⚡×2",11,Color3.fromRGB(255,215,60),
    Enum.Font.GothamBold,Enum.TextXAlignment.Center,
    UDim2.new(0,28,0,16),UDim2.new(0,8,0,Q_Y+122))
local qExpVal2 = bLabel("---",11,Color3.fromRGB(255,215,60),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(1,-40,0,16),UDim2.new(0,38,0,Q_Y+122))

local expBarBg = bFrame(UDim2.new(1,-16,0,4),UDim2.new(0,8,0,Q_Y+140),
    Color3.fromRGB(40,40,60),0,UDim.new(1,0))
local expBarCur = newFrame(expBarBg,UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),
    Color3.fromRGB(74,222,128),0,UDim.new(1,0))
local expBarAdd = newFrame(expBarBg,UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),
    Color3.fromRGB(255,215,60),0.4,UDim.new(1,0))

bDivH(Q_Y+148)

bLabel("💰",13,Color3.fromRGB(255,255,255),
    Enum.Font.Gotham,Enum.TextXAlignment.Center,
    UDim2.new(0,18,0,16),UDim2.new(0,8,0,Q_Y+156))
local qBeliVal1 = bLabel("---",11,Color3.fromRGB(80,235,140),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(1,-32,0,16),UDim2.new(0,28,0,Q_Y+156))

bLabel("💰×2",11,Color3.fromRGB(255,200,60),
    Enum.Font.GothamBold,Enum.TextXAlignment.Center,
    UDim2.new(0,28,0,16),UDim2.new(0,8,0,Q_Y+174))
local qBeliVal2 = bLabel("---",11,Color3.fromRGB(255,200,60),
    Enum.Font.GothamBold,Enum.TextXAlignment.Left,
    UDim2.new(1,-40,0,16),UDim2.new(0,38,0,Q_Y+174))

local MAX_STAT = 2550

local function updateData()
    local Data = LP:FindFirstChild("Data")
    if not Data then return end
    for _, k in ipairs({"Level","Beli","Fragments","Race"}) do
        local c = Data:FindFirstChild(k)
        if c and infoLabels[k] then infoLabels[k].Text = fmt(c.Value, k) end
    end
    local lvNode = Data:FindFirstChild("Level")
    if lvNode then
        miniName.Text = LP.DisplayName .. "  |  Lv. " .. addCommas(lvNode.Value or 0)
    end
    local Stats = Data:FindFirstChild("Stats")
    if not Stats then return end
    for _, s in ipairs(combatStats) do
        local node = Stats:FindFirstChild(s.tag)
        if node then
            local lvN = node:FindFirstChild("Level")
            if lvN and combatLabels[s.tag] then
                local v = lvN.Value or 0
                combatLabels[s.tag].label.Text = tostring(v)
                combatLabels[s.tag].bar.Size = UDim2.new(math.clamp(v/MAX_STAT,0,1),0,1,0)
            end
        end
    end
end

task.spawn(function()
    local Data = LP:WaitForChild("Data",10)
    if not Data then return end
    updateData()
    local function watch(obj) if obj then obj.Changed:Connect(updateData) end end
    for _, k in ipairs({"Level","Beli","Fragments","Race"}) do
        watch(Data:WaitForChild(k,5))
    end
    local Stats = Data:WaitForChild("Stats",5)
    if Stats then
        for _, s in ipairs(combatStats) do
            local node = Stats:WaitForChild(s.tag,5)
            if node then watch(node:WaitForChild("Level",5)) end
        end
    end
end)

local function updateQuest()
    local questVisible = false
    local rawTitle, rawReward = "", ""
    pcall(function()
        local qf = LP.PlayerGui.Main.Quest
        questVisible = qf.Visible
        if questVisible then
            rawTitle  = qf.Container.QuestTitle.Title.ContentText  or ""
            rawReward = qf.Container.QuestReward.Title.ContentText or ""
        end
    end)

    if not questVisible or rawTitle=="" then
        miniQuest.Text = "No quests"
    else
        miniQuest.Text = rawTitle
    end

    if not questVisible or rawTitle=="" then
        qTitleVal.Text="No quests"; qTitleVal.TextColor3=Color3.fromRGB(160,160,190)
        qExpVal1.Text="---"; qExpVal2.Text="---"
        qBeliVal1.Text="---"; qBeliVal2.Text="---"
        expBarCur.Size=UDim2.new(0,0,1,0); expBarAdd.Size=UDim2.new(0,0,1,0)
        expBarCur.BackgroundColor3=Color3.fromRGB(74,222,128)
        return
    end

    qTitleVal.Text=rawTitle; qTitleVal.TextColor3=Color3.fromRGB(255,255,255)

    local currentExp, neededExp = nil, nil
    pcall(function()
        currentExp, neededExp = parseExpBar(LP.PlayerGui.Main.Level.Exp.ContentText)
    end)

    local currentLevel = 0
    pcall(function() currentLevel = LP.Data.Level.Value or 0 end)

    local currentBeli = 0
    pcall(function() currentBeli = LP.Data.Beli.Value or 0 end)

    local baseExp = parseQuestExp(rawReward)

    if baseExp and currentExp and neededExp and neededExp>0 then
        local exp1x   = baseExp
        local exp2x   = baseExp * 2
        local after1x = currentExp + exp1x
        local after2x = currentExp + exp2x

        local pctCur   = math.clamp(currentExp/neededExp,0,1)
        local pctAfter = math.clamp(after1x/neededExp,0,1)
        expBarCur.Size = UDim2.new(pctCur,0,1,0)
        expBarAdd.Size = UDim2.new(pctAfter-pctCur,0,1,0)
        expBarAdd.Position = UDim2.new(pctCur,0,0,0)

        if after1x >= neededExp then
            qExpVal1.Text = string.format("+%s  🎉  Lv.%d → Lv.%d",
                addCommas(exp1x), currentLevel, currentLevel+1)
            qExpVal1.TextColor3 = Color3.fromRGB(255,215,60)
            expBarCur.BackgroundColor3 = Color3.fromRGB(255,215,60)
        else
            local remaining = neededExp - after1x
            local quests1x  = math.ceil(remaining / exp1x)
            qExpVal1.Text = string.format("+%s  →  %s / %s",
                addCommas(exp1x), addCommas(after1x), addCommas(neededExp))
            qExpVal1.TextColor3 = Color3.fromRGB(74,222,128)
            expBarCur.BackgroundColor3 = Color3.fromRGB(74,222,128)
        end

        if after2x >= neededExp then
            qExpVal2.Text = string.format("+%s  🎉  Lv.%d → Lv.%d",
                addCommas(exp2x), currentLevel, currentLevel+1)
        else
            local rem2x    = neededExp - after2x
            local quests2x = math.ceil(rem2x / exp2x)
            qExpVal2.Text = string.format("+%s  →  %s / %s  (อีก %d)",
                addCommas(exp2x), addCommas(after2x), addCommas(neededExp), quests2x)
        end
        qExpVal2.TextColor3 = Color3.fromRGB(255,215,60)

        local pct = math.floor((after1x/neededExp)*100)
        miniQuest.Text = rawTitle .. string.format("  |  EXP %d%%", math.min(pct,100))
    else
        local expLine="---"
        for line in rawReward:gmatch("[^\n]+") do
            local s=line:match("^%s*(.-)%s*$")
            if s:lower():find("exp") or s:lower():find("xp") then expLine=s; break end
        end
        qExpVal1.Text=expLine; qExpVal1.TextColor3=Color3.fromRGB(160,160,190)
        qExpVal2.Text="---";  qExpVal2.TextColor3=Color3.fromRGB(160,160,190)
        expBarCur.Size=UDim2.new(0,0,1,0); expBarAdd.Size=UDim2.new(0,0,1,0)
    end

    local baseBeli = parseBeli(rawReward)
    if baseBeli then
        local b1 = baseBeli
        local b2 = baseBeli * 2
        qBeliVal1.Text = string.format("+%s  →  %s",
            addCommas(b1), addCommas(currentBeli + b1))
        qBeliVal1.TextColor3 = Color3.fromRGB(80,235,140)
        qBeliVal2.Text = string.format("+%s  →  %s",
            addCommas(b2), addCommas(currentBeli + b2))
        qBeliVal2.TextColor3 = Color3.fromRGB(255,200,60)
    else
        qBeliVal1.Text="---"; qBeliVal1.TextColor3=Color3.fromRGB(160,160,190)
        qBeliVal2.Text="---"; qBeliVal2.TextColor3=Color3.fromRGB(160,160,190)
    end
end

task.spawn(function()
    while true do
        pcall(updateQuest)
        task.wait(1)
    end
end)
