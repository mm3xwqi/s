local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

for _, v in ipairs(LP:WaitForChild("PlayerGui"):GetChildren()) do
    if v.Name == "PerfHUD" or v.Name == "PerformanceGui" then v:Destroy() end
end

local HudGui = Instance.new("ScreenGui")
HudGui.Name = "PerfHUD"
HudGui.ResetOnSpawn = false
HudGui:SetAttribute("BloxFruitByIndex", true)
HudGui.Parent = LP:WaitForChild("PlayerGui")

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 280, 0, 54)
Card.Position = UDim2.new(0, 12, 0, 12)  -- ตำแหน่งเดิม บนซ้าย
Card.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
Card.BackgroundTransparency = 0.35        -- โปร่งใส
Card.BorderSizePixel = 0
Card.Active = true
Card.Draggable = true
Card.Parent = HudGui

local corner = Instance.new("UICorner", Card)
corner.CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", Card)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1
stroke.Transparency = 0.82               -- ขอบบางๆ

local function makeSep(xPos)
    local sep = Instance.new("Frame", Card)
    sep.Size = UDim2.new(0, 1, 0, 26)
    sep.Position = UDim2.new(0, xPos, 0.5, -13)
    sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sep.BackgroundTransparency = 0.8
    sep.BorderSizePixel = 0
end

makeSep(92)
makeSep(188)

local function makeSection(tagText, xCenter)
    local tag = Instance.new("TextLabel", Card)
    tag.Size = UDim2.new(0, 80, 0, 16)
    tag.Position = UDim2.new(0, xCenter - 40, 0, 7)
    tag.BackgroundTransparency = 1
    tag.Text = tagText
    tag.TextColor3 = Color3.fromRGB(180, 180, 200)
    tag.TextSize = 10
    tag.Font = Enum.Font.GothamBold
    tag.TextXAlignment = Enum.TextXAlignment.Center
    tag.TextStrokeTransparency = 0.6
    tag.TextStrokeColor3 = Color3.new(0,0,0)

    local val = Instance.new("TextLabel", Card)
    val.Size = UDim2.new(0, 80, 0, 26)
    val.Position = UDim2.new(0, xCenter - 40, 0, 22)
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

fpsVal.TextColor3  = Color3.fromRGB(74, 222, 128)
pingVal.TextColor3 = Color3.fromRGB(250, 200, 40)
timeVal.TextColor3 = Color3.fromRGB(192, 132, 252)

-- Timer
local _start = tick()
RunService.Heartbeat:Connect(function()
    local e = math.floor(tick() - _start)
    local h = math.floor(e / 3600)
    local m = math.floor((e % 3600) / 60)
    local s = e % 60
    timeVal.Text = h > 0
        and string.format("%d:%02d:%02d", h, m, s)
        or  string.format("%02d:%02d", m, s)
end)

-- FPS
local _frameCount = 0
local _lastTime = tick()
RunService.RenderStepped:Connect(function()
    _frameCount += 1
    local now = tick()
    local delta = now - _lastTime
    if delta >= 0.5 then
        local fps = math.floor(_frameCount / delta)
        _frameCount = 0
        _lastTime = now
        local fCol = fps >= 60 and Color3.fromRGB(74,222,128)
            or fps >= 30 and Color3.fromRGB(250,200,40)
            or Color3.fromRGB(255,70,70)
        fpsVal.Text = tostring(fps)
        fpsVal.TextColor3 = fCol
    end
end)

-- Ping
RunService.Heartbeat:Connect(function()
    local ok, ping = pcall(function()
        return math.floor(LP:GetNetworkPing() * 1000)
    end)
    if not ok then return end
    ping = math.max(0, ping)
    local pCol = ping <= 80  and Color3.fromRGB(74,222,128)
        or ping <= 200 and Color3.fromRGB(250,200,40)
        or Color3.fromRGB(255,70,70)
    pingVal.Text = tostring(ping) .. " ms"
    pingVal.TextColor3 = pCol
end)
