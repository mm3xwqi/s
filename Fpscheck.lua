local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local HudGui = Instance.new("ScreenGui")
HudGui.Name = "PerfHUD"
HudGui.ResetOnSpawn = false
HudGui:SetAttribute("BloxFruitByIndex", true)
HudGui.Parent = LP:WaitForChild("PlayerGui")

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 160, 0, 100)
Card.Position = UDim2.new(0, 12, 0, 12)
Card.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Card.BackgroundTransparency = 0.15
Card.BorderSizePixel = 0
Card.Active = true
Card.Draggable = true
Card.Parent = HudGui

local CardCorner = Instance.new("UICorner", Card)
CardCorner.CornerRadius = UDim.new(0, 8)

local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Color = Color3.fromRGB(60, 60, 80)
CardStroke.Thickness = 1
CardStroke.Transparency = 0.3

local Accent = Instance.new("Frame", Card)
Accent.Size = UDim2.new(0, 3, 1, -12)
Accent.Position = UDim2.new(0, 0, 0, 6)
Accent.BackgroundColor3 = Color3.fromRGB(255, 160, 60)
Accent.BorderSizePixel = 0
Instance.new("UICorner", Accent).CornerRadius = UDim.new(1, 0)

local function makeRow(parent, yOffset)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -18, 0, 28)
    row.Position = UDim2.new(0, 10, 0, yOffset)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    return row
end

local function makeLabel(parent, text, size, color, xAlign, xOffset, width)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(0, width or 50, 1, 0)
    lbl.Position = UDim2.new(0, xOffset or 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.new(1, 1, 1)
    lbl.TextSize = size or 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    lbl.TextStrokeTransparency = 0.8
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    return lbl
end

local fpsRow   = makeRow(Card, 6)
local fpsTag   = makeLabel(fpsRow, "FPS",  10, Color3.fromRGB(150,150,160), Enum.TextXAlignment.Left,  8, 30)
local fpsValue = makeLabel(fpsRow, "---",  18, Color3.fromRGB(255,220,80),  Enum.TextXAlignment.Left, 38, 50)
local fpsBar   = Instance.new("Frame", fpsRow)
fpsBar.Size             = UDim2.new(0, 0, 0, 3)
fpsBar.Position         = UDim2.new(0, 8, 1, -4)
fpsBar.BackgroundColor3 = Color3.fromRGB(255,220,80)
fpsBar.BorderSizePixel  = 0
Instance.new("UICorner", fpsBar).CornerRadius = UDim.new(1, 0)

local pingRow   = makeRow(Card, 36)
local pingTag   = makeLabel(pingRow, "PING", 10, Color3.fromRGB(150,150,160), Enum.TextXAlignment.Left,  8, 30)
local pingValue = makeLabel(pingRow, "---",  18, Color3.fromRGB(80,220,160),  Enum.TextXAlignment.Left, 38, 70)
local pingBar   = Instance.new("Frame", pingRow)
pingBar.Size             = UDim2.new(0, 0, 0, 3)
pingBar.Position         = UDim2.new(0, 8, 1, -4)
pingBar.BackgroundColor3 = Color3.fromRGB(80,220,160)
pingBar.BorderSizePixel  = 0
Instance.new("UICorner", pingBar).CornerRadius = UDim.new(1, 0)

do
    local timeRow   = makeRow(Card, 66)
    local timeTag   = makeLabel(timeRow, "TIME", 10, Color3.fromRGB(150,150,160), Enum.TextXAlignment.Left, 8, 35)
    local timeValue = makeLabel(timeRow, "00:00", 15, Color3.fromRGB(180,160,255), Enum.TextXAlignment.Left, 46, 100)
    local _start    = tick()
    RunService.Heartbeat:Connect(function()
        local e = math.floor(tick() - _start)
        local h = math.floor(e / 3600)
        local m = math.floor((e % 3600) / 60)
        local s = e % 60
        timeValue.Text = h > 0 and string.format("%d:%02d:%02d", h, m, s) or string.format("%02d:%02d", m, s)
    end)
end

local _fps        = 0
local _frameCount = 0
local _lastTime   = tick()
local _maxBarW    = 130

RunService.RenderStepped:Connect(function()
    _frameCount = _frameCount + 1
    local now = tick()
    if now - _lastTime >= 0.5 then
        _fps = math.clamp(_frameCount, 0, 9999)
        _frameCount = 0
        _lastTime = now
        local ratio = math.min(_fps, 120) / 120
        local fCol = _fps >= 60 and Color3.fromRGB(80,220,80) or (_fps >= 30 and Color3.fromRGB(255,200,40) or Color3.fromRGB(255,70,70))
        fpsValue.Text           = tostring(_fps)
        fpsValue.TextColor3     = fCol
        fpsBar.Size             = UDim2.new(0, math.floor(ratio * _maxBarW), 0, 3)
        fpsBar.BackgroundColor3 = fCol
        Accent.BackgroundColor3 = fCol
    end
end)

RunService.Heartbeat:Connect(function()
    local ok, ping = pcall(function() return math.floor(LP:GetNetworkPing() * 1000) end)
    if not ok then return end
    ping = math.max(0, ping)
    local pCol = ping <= 80 and Color3.fromRGB(60,220,150) or (ping <= 200 and Color3.fromRGB(255,200,40) or Color3.fromRGB(255,70,70))
    pingValue.Text        = tostring(ping) .. " ms"
    pingValue.TextColor3  = pCol
    pingBar.Size          = UDim2.new(0, math.floor((1 - math.min(ping/400,1)) * _maxBarW), 0, 3)
    pingBar.BackgroundColor3 = pCol
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PerformanceGui"
ScreenGui.ResetOnSpawn = false
ScreenGui:SetAttribute("BloxFruitByIndex", true)
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
