local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

for _, v in ipairs(LP:WaitForChild("PlayerGui"):GetChildren()) do
    if v.Name == "PerfHUD" or v.Name == "PlayerCardHUD" then v:Destroy() end
end

local HudGui = Instance.new("ScreenGui")
HudGui.Name = "PerfHUD"
HudGui.ResetOnSpawn = false
HudGui:SetAttribute("BloxFruitByIndex", true)
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

local CardGui = Instance.new("ScreenGui")
CardGui.Name = "PlayerCardHUD"
CardGui.ResetOnSpawn = false
CardGui:SetAttribute("BloxFruitByIndex", true)
CardGui.Parent = LP:WaitForChild("PlayerGui")

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
    l.Text = text
    l.TextColor3 = color
    l.TextSize = size
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

local PC = newFrame(CardGui,
    UDim2.new(0,230,0,268),
    UDim2.new(0,12,0,78),
    Color3.fromRGB(10,10,18), 0.15,
    UDim.new(0,12))

local pcStroke = Instance.new("UIStroke", PC)
pcStroke.Color = Color3.fromRGB(255,255,255)
pcStroke.Thickness = 0.8
pcStroke.Transparency = 0.85
PC.Active = true; PC.Draggable = true

local avFrame = newFrame(PC,
    UDim2.new(0,50,0,50),
    UDim2.new(0,10,0,10),
    Color3.fromRGB(30,30,45), 0,
    UDim.new(1,0))
local avStroke = Instance.new("UIStroke", avFrame)
avStroke.Color = Color3.fromRGB(192,132,252)
avStroke.Thickness = 1.5; avStroke.Transparency = 0.2

local avImg = Instance.new("ImageLabel", avFrame)
avImg.Size = UDim2.new(1,0,1,0)
avImg.BackgroundTransparency = 1
avImg.BorderSizePixel = 0
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1,0)
local ok2, thumb = pcall(function()
    return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)
if ok2 then avImg.Image = thumb end

newLabel(PC, LP.DisplayName, 15, Color3.fromRGB(255,255,255),
    Enum.Font.GothamBold, Enum.TextXAlignment.Left,
    UDim2.new(0,158,0,18), UDim2.new(0,66,0,10))
newLabel(PC, "@"..LP.Name, 10, Color3.fromRGB(180,180,210),
    Enum.Font.Gotham, Enum.TextXAlignment.Left,
    UDim2.new(0,158,0,14), UDim2.new(0,66,0,30))

newDivH(PC, 68)

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
    local x = 10 + col*112
    local y = 76 + row*28
    newLabel(PC, s.tag, 9, Color3.fromRGB(180,180,210),
        Enum.Font.GothamBold, Enum.TextXAlignment.Left,
        UDim2.new(0,105,0,11), UDim2.new(0,x,0,y))
    local vl = newLabel(PC, "...", 14, s.color,
        Enum.Font.GothamBold, Enum.TextXAlignment.Left,
        UDim2.new(0,105,0,15), UDim2.new(0,x,0,y+12))
    infoLabels[s.key] = vl
end

local vs = Instance.new("Frame", PC)
vs.Size = UDim2.new(0,1,0,52); vs.Position = UDim2.new(0,116,0,74)
vs.BackgroundColor3 = Color3.fromRGB(255,255,255)
vs.BackgroundTransparency = 0.88; vs.BorderSizePixel = 0

newDivH(PC, 136)

newLabel(PC, "COMBAT STATS", 10, Color3.fromRGB(200,200,230),
    Enum.Font.GothamBold, Enum.TextXAlignment.Left,
    UDim2.new(1,-16,0,12), UDim2.new(0,10,0,142))

local combatStats = {
    {tag="Melee",       icon="👊", color=Color3.fromRGB(255,175,90)},
    {tag="Defense",     icon="🛡",  color=Color3.fromRGB(120,190,255)},
    {tag="Sword",       icon="⚔",  color=Color3.fromRGB(225,190,255)},
    {tag="Gun",         icon="🔫", color=Color3.fromRGB(90,235,150)},
    {tag="Demon Fruit", icon="🍎", color=Color3.fromRGB(255,120,150)},
}

local combatLabels = {}
for i, s in ipairs(combatStats) do
    local y = 158 + (i-1)*22

    local ico = Instance.new("TextLabel", PC)
    ico.Size = UDim2.new(0,20,0,20)
    ico.Position = UDim2.new(0,8,0,y)
    ico.BackgroundTransparency = 1
    ico.Text = s.icon
    ico.TextSize = 14
    ico.Font = Enum.Font.Gotham
    ico.TextXAlignment = Enum.TextXAlignment.Center
    ico.TextStrokeTransparency = 1

    newLabel(PC, s.tag, 12, Color3.fromRGB(220,220,240),
        Enum.Font.GothamBold, Enum.TextXAlignment.Left,
        UDim2.new(0,100,0,20), UDim2.new(0,30,0,y))

    local barBg = newFrame(PC,
        UDim2.new(0,95,0,4),
        UDim2.new(0,30,0,y+17),
        Color3.fromRGB(50,50,70), 0,
        UDim.new(1,0))

    local barFill = newFrame(barBg,
        UDim2.new(0,0,1,0),
        UDim2.new(0,0,0,0),
        s.color, 0,
        UDim.new(1,0))

    local vl = newLabel(PC, "...", 12, s.color,
        Enum.Font.GothamBold, Enum.TextXAlignment.Right,
        UDim2.new(0,50,0,20), UDim2.new(0,174,0,y))

    combatLabels[s.tag] = {label=vl, bar=barFill}
end

local NO_ABBREV = {Beli=true, Fragments=true}

local function addCommas(n)
    local s = tostring(math.floor(n))
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function fmt(v, key)
    if type(v)=="number" then
        if NO_ABBREV[key] then
            return addCommas(v)
        end
        if v>=1e6 then return string.format("%.1fM",v/1e6)
        elseif v>=1e3 then return string.format("%.1fK",v/1e3)
        else return tostring(math.floor(v)) end
    end
    return tostring(v or "?")
end

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
