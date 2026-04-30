local _, library = pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/TrixAde/Osmium/main/OsmiumLibrary.lua")))
if not game:IsLoaded() then game.Loaded:Wait() end

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local RepStorage      = game:GetService("ReplicatedStorage")
local VIM             = game:GetService("VirtualInputManager")

local interactRemote   = RepStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")
local changeModeRemote = RepStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode")

local player = Players.LocalPlayer

local cfg = {
    farmEnabled      = false,
    beeFarm          = true,
    safeZone         = true,
    autoRevive       = false,
    reviveAura       = false,
    hopEnabled       = false,
    antiAfk          = true,
    leadTime         = 0.3,
    reviveCooldown   = 0,
    safezoneCooldown = 2,
}

local ZERO          = Vector3.new(0, 0, 0)
local TICKET_OFFSET = Vector3.new(0, -10, 0)
local REVIVE_OFFSET = Vector3.new(0, -7, 0)
local SAFE_SPOTS    = {
    Vector3.new(-230, 280, -200),
    Vector3.new(0, 280, 0),
    Vector3.new(230, 280, 200),
}

local state = {
    isTeleporting  = false,
    isReviving     = false,
    isFarming      = false,
    lastNPCPos     = nil,
    lastNPCTime    = nil,
    safeTarget     = SAFE_SPOTS[1],
    safeIndex      = 1,
    lastSafeUpdate = 0,
}

local SAVE_FILE = "evade_autofarm.json"

local function saveSettings()
    pcall(function()
        writefile(SAVE_FILE, HttpService:JSONEncode(cfg))
    end)
end

local function loadSettings()
    local ok, content = pcall(readfile, SAVE_FILE)
    if not ok or not content or content == "" then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, content)
    if not ok2 or type(data) ~= "table" then return end
    for k, v in pairs(data) do
        if cfg[k] ~= nil then cfg[k] = v end
    end
end

loadSettings()

local function getChar()
    return player.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function isDowned(model)
    return model and model:GetAttribute("Downed") == true
end

local function isCarried(model)
    return model and model:GetAttribute("Carried") == true
end

local function isInGame()
    local g  = workspace:FindFirstChild("Game")
    local gp = g and g:FindFirstChild("Players")
    return gp and gp:FindFirstChild(player.Name) ~= nil
end

local function getGamePlayers()
    local g = workspace:FindFirstChild("Game")
    return g and g:FindFirstChild("Players")
end

local function warp(hrp, pos)
    if not hrp or not hrp.Parent then return end
    hrp.CFrame = CFrame.new(pos)
    hrp.AssemblyLinearVelocity  = ZERO
    hrp.AssemblyAngularVelocity = ZERO
end

local function refreshSafeTarget()
    local now = tick()
    if (now - state.lastSafeUpdate) >= cfg.safezoneCooldown then
        state.lastSafeUpdate = now
        state.safeTarget = SAFE_SPOTS[state.safeIndex]
    end
end

local function goSafe()
    local hrp = getHRP()
    if not hrp then return end
    state.lastSafeUpdate = 0
    refreshSafeTarget()
    warp(hrp, state.safeTarget)
end

local function predictNPC(npcHRP)
    local pos = npcHRP.Position
    local now = tick()
    if state.lastNPCPos and state.lastNPCTime then
        local dt = now - state.lastNPCTime
        if dt > 0 then
            local vel = (pos - state.lastNPCPos) / dt
            state.lastNPCPos  = pos
            state.lastNPCTime = now
            return pos + vel * cfg.leadTime
        end
    end
    state.lastNPCPos  = pos
    state.lastNPCTime = now
    return pos
end

-- =====================
--  No Collide
-- =====================
RunService.Stepped:Connect(function()
    local char = getChar()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- =====================
--  SafeZone Loop
-- =====================
RunService.Heartbeat:Connect(function()
    if not cfg.safeZone  then return end
    if state.isReviving  then return end
    if state.isFarming   then return end
    local hrp = getHRP()
    if not hrp then return end
    refreshSafeTarget()
    hrp.CFrame = CFrame.new(state.safeTarget)
    hrp.AssemblyLinearVelocity  = ZERO
    hrp.AssemblyAngularVelocity = ZERO
end)

task.spawn(function()
    while true do
        task.wait(3)
        if not cfg.safeZone then continue end
        state.safeIndex  = (state.safeIndex % #SAFE_SPOTS) + 1
        state.safeTarget = SAFE_SPOTS[state.safeIndex]
        state.lastSafeUpdate = tick()
    end
end)

-- =====================
--  Farm Loop
-- =====================
RunService.Heartbeat:Connect(function()
    if not cfg.farmEnabled then state.isFarming = false; return end
    if state.isReviving    then state.isFarming = false; return end
    local hrp = getHRP()
    if not hrp then state.isFarming = false; return end

    local gameFolder = workspace:FindFirstChild("Game")
    local gp         = gameFolder and gameFolder:FindFirstChild("Players")
    local effects    = gameFolder and gameFolder:FindFirstChild("Effects")
    local tickets    = effects and effects:FindFirstChild("Tickets")

    if cfg.beeFarm and gp then
        local bee    = gp:FindFirstChild("Bee")
        local beeHRP = bee and bee:FindFirstChild("HumanoidRootPart")
        if beeHRP then
            state.isFarming = true
            warp(hrp, predictNPC(beeHRP))
            return
        else
            state.lastNPCPos  = nil
            state.lastNPCTime = nil
        end
    end

    if tickets then
        for _, t in ipairs(tickets:GetChildren()) do
            local m = t:FindFirstChild("Mover")
            if m and m:IsA("BasePart") then
                state.isFarming = true
                warp(hrp, m.Position + TICKET_OFFSET)
                return
            end
        end
    end

    state.isFarming = false
    if cfg.safeZone then warp(hrp, state.safeTarget) end
end)

-- =====================
--  Self Revive + Rejoin
-- =====================
task.spawn(function()
    while true do
        task.wait(0.3)
        if not cfg.farmEnabled then continue end
        local char = getChar()
        if isDowned(char) then
            repeat
                pcall(function() interactRemote:FireServer("Revive", true, player.Name) end)
                task.wait(0.05)
            until not isDowned(getChar())
            continue
        end
        if not isInGame() then
            pcall(function()
                local menu = player.PlayerGui:FindFirstChild("Menu")
                if menu then changeModeRemote:FireServer(true) end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not cfg.farmEnabled then continue end
        pcall(function()
            local menu = player.PlayerGui:FindFirstChild("Menu")
            if menu then changeModeRemote:FireServer(true) end
        end)
    end
end)

-- =====================
--  Auto Revive
-- =====================
task.spawn(function()
    while true do
        task.wait(0.1)
        if not cfg.autoRevive then continue end
        local hrp = getHRP()
        if not hrp then continue end

        if isDowned(getChar()) then
            repeat
                pcall(function() interactRemote:FireServer("Revive", true, player.Name) end)
                task.wait(0.05)
            until not isDowned(getChar())
            continue
        end

        local gp = getGamePlayers()
        if not gp then
            if cfg.safeZone then goSafe() end
            continue
        end

        local target, tHRP = nil, nil
        local closestDist  = math.huge

        for _, model in ipairs(gp:GetChildren()) do
            if model.Name ~= player.Name
            and model:GetAttribute("Team") ~= "Nextbot"
            and isDowned(model)
            and not isCarried(model) then
                local h = model:FindFirstChild("HumanoidRootPart")
                if h then
                    local d = (h.Position - hrp.Position).Magnitude
                    if d < closestDist then
                        closestDist = d
                        target = model
                        tHRP   = h
                    end
                end
            end
        end

        if not target then
            if cfg.safeZone then goSafe() end
            continue
        end

        state.isReviving = true
        local t0 = tick()

        pcall(function()
            while isDowned(target) do
                if not target.Parent         then break end
                if not hrp or not hrp.Parent then break end
                if isDowned(getChar())       then break end
                if tick() - t0 > 5           then break end
                if isCarried(target)         then break end
                if tHRP and tHRP.Parent then
                    warp(hrp, tHRP.Position + REVIVE_OFFSET)
                end
                interactRemote:FireServer("Revive", true, target.Name)
                task.wait(0.05)
            end
        end)

        state.isReviving = false
        if cfg.safeZone then goSafe() end
        task.wait(cfg.reviveCooldown)
    end
end)

-- =====================
--  Revive Aura
-- =====================
task.spawn(function()
    while true do
        task.wait(0.05)
        if not cfg.reviveAura then continue end

        if isDowned(getChar()) then
            pcall(function() interactRemote:FireServer("Revive", true, player.Name) end)
            continue
        end

        local gp = getGamePlayers()
        if not gp then continue end

        for _, model in ipairs(gp:GetChildren()) do
            if model.Name ~= player.Name
            and model:GetAttribute("Team") ~= "Nextbot"
            and isDowned(model)
            and not isCarried(model) then
                pcall(function() interactRemote:FireServer("Revive", true, model.Name) end)
            end
        end
    end
end)

-- =====================
--  Anti-AFK
-- =====================
task.spawn(function()
    while true do
        task.wait(60)
        if not cfg.antiAfk then continue end
        pcall(function()
            VIM:SendKeyEvent(true,  Enum.KeyCode.F24, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.F24, false, game)
        end)
    end
end)

-- =============================================
--  HOP SERVER (แก้ใหม่ทั้งหมด)
-- =============================================
local PlaceID        = game.PlaceId
local HOP_DELAY      = 1.5
local RETRY_COOLDOWN = 8
local BL_EXPIRE_SEC  = 120  -- blacklist หมดอายุใน 5 นาที

-- เก็บ blacklist เป็น {id = timestamp} แทน array ธรรมดา
local blacklistMap = {}
local hopStartTime = 0
local hopNotifyFrame, hopInfoLabel, hopCountdownLabel

pcall(function() delfile("HopBlacklist.json") end)

-- ล้าง entry ที่หมดอายุแล้ว
local function cleanBlacklist()
    local now = tick()
    for id, t in pairs(blacklistMap) do
        if now - t > BL_EXPIRE_SEC then
            blacklistMap[id] = nil
        end
    end
end

local function isBlacklisted(id)
    if not blacklistMap[id] then return false end
    if tick() - blacklistMap[id] > BL_EXPIRE_SEC then
        blacklistMap[id] = nil
        return false
    end
    return true
end

local function getServerList(cursor)
    local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor and cursor ~= "" then
        url = url .. "&cursor=" .. cursor
    end
    local raw = game:HttpGet(url)
    return HttpService:JSONDecode(raw)
end

-- Watchdog: reset isTeleporting อัตโนมัติถ้าค้างเกิน 12 วิ
task.spawn(function()
    while true do
        task.wait(1)
        if state.isTeleporting and (tick() - hopStartTime) > 12 then
            warn("[Hop] isTeleporting stuck → reset")
            state.isTeleporting = false
            hopStartTime = 0
            if hopNotifyFrame then hopNotifyFrame.Visible = false end
        end
    end
end)

local function findAndHop()
    if state.isTeleporting then return false end
    cleanBlacklist()

    local cursor, attempts = nil, 0
    repeat
        local success, data = pcall(getServerList, cursor)
        if not success or not data or not data.data then
            task.wait(2)
            break
        end

        for _, server in ipairs(data.data) do
            local id      = server.id
            local playing = server.playing    or 0
            local maxP    = server.maxPlayers or 0

            -- buffer -2 ป้องกันห้องเต็มพอดีตอนกระโดดถึง
            if id ~= game.JobId
            and playing >= 1
            and playing <= (maxP - 2)
            and not isBlacklisted(id) then
                blacklistMap[id] = tick()
                state.isTeleporting = true
                hopStartTime = tick()

                if hopNotifyFrame then
                    hopNotifyFrame.Visible = true
                    hopInfoLabel.Text = string.format(
                        "ย้ายไป Server %s (%d/%d)",
                        tostring(id):sub(1, 12), playing, maxP
                    )
                    hopCountdownLabel.Text = "⏳ กำลังย้าย..."
                end

                task.wait(HOP_DELAY)

                local ok = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceID, id, player)
                end)

                if not ok then
                    -- teleport ล้มเหลวทันที → reset แล้วหาใหม่
                    state.isTeleporting = false
                    hopStartTime = 0
                    blacklistMap[id] = nil
                    if hopNotifyFrame then hopNotifyFrame.Visible = false end
                    return false
                end

                return true
            end
        end

        cursor = data.nextPageCursor
        attempts += 1
        if attempts >= 8 then break end  -- เพิ่มจาก 5 → 8 หน้า
    until cursor == nil or cursor == ""

    return false
end

local function hopServer()
    if state.isTeleporting then return end

    local hopped = findAndHop()
    if not hopped then
        warn("[Hop] ไม่เจอ server ที่เหมาะสม → ล้าง blacklist แล้ว retry")
        task.wait(RETRY_COOLDOWN)
        blacklistMap = {}  -- reset blacklist ทั้งหมด
        findAndHop()
    end
end

-- =====================
--  Hop UI
-- =====================
local function buildHopUI()
    local existing = player.PlayerGui:FindFirstChild("HopNotifyUI")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "HopNotifyUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 380, 0, 100)
    frame.Position = UDim2.new(0.5, -190, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(100, 200, 255)
    stroke.Thickness = 2

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "🚀 Auto Hop"
    title.TextColor3 = Color3.fromRGB(80, 200, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold

    local info = Instance.new("TextLabel", frame)
    info.Size = UDim2.new(1, -20, 0, 40)
    info.Position = UDim2.new(0, 10, 0, 38)
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.fromRGB(220, 225, 255)
    info.TextSize = 13
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextWrapped = true

    local cd = Instance.new("TextLabel", frame)
    cd.Size = UDim2.new(1, 0, 0, 25)
    cd.Position = UDim2.new(0, 0, 0, 75)
    cd.BackgroundTransparency = 1
    cd.TextColor3 = Color3.fromRGB(255, 210, 70)
    cd.TextSize = 15
    cd.Font = Enum.Font.GothamBold

    hopNotifyFrame = frame
    hopInfoLabel = info
    hopCountdownLabel = cd
end
buildHopUI()

TeleportService.TeleportInitFailed:Connect(function(plr)
    if plr ~= player then return end
    state.isTeleporting = false
    hopStartTime = 0
    if hopNotifyFrame then hopNotifyFrame.Visible = false end
end)

-- =============================================
--  เงื่อนไขการ Hop
-- =============================================

-- ตายในเกม → hop
task.spawn(function()
    while true do
        task.wait(0.5)
        if not (cfg.farmEnabled and cfg.hopEnabled) then continue end
        local char = getChar()
        if not char or not isInGame() then continue end
        if isDowned(char) or (char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0) then
            hopServer()
            while cfg.farmEnabled and cfg.hopEnabled and state.isTeleporting do
                task.wait(0.5)
            end
        end
    end
end)

-- เจอ Rewards UI → hop
task.spawn(function()
    while true do
        task.wait(0.5)
        if not (cfg.farmEnabled and cfg.hopEnabled) then continue end
        if state.isTeleporting then continue end
        local gui = player.PlayerGui:FindFirstChild("Global")
        local rf  = gui and gui:FindFirstChild("Rewards")
        if rf and rf.Visible then
            task.wait(2)
            if rf.Visible and cfg.farmEnabled and cfg.hopEnabled then
                hopServer()
            end
        end
    end
end)

-- Server เต็ม → hop
task.spawn(function()
    while true do
        task.wait(3)
        if not (cfg.farmEnabled and cfg.hopEnabled) then continue end
        if state.isTeleporting then continue end
        local ok, data = pcall(getServerList, nil)
        if not ok then continue end
        for _, s in ipairs(data.data or {}) do
            if s.id == game.JobId and s.playing >= s.maxPlayers then
                hopServer()
                break
            end
        end
    end
end)

-- =====================
--  UI
-- =====================
local window    = library:CreateWindow("Evade")
local mainTab   = window:CreateTab("Farm")
local configTab = window:CreateTab("Config")

mainTab:CreateToggle("AutoFarm", cfg.farmEnabled, function(v)
    cfg.farmEnabled = v; saveSettings()
end)
mainTab:CreateToggle("Bee Farm", cfg.beeFarm, function(v)
    cfg.beeFarm = v
    state.lastNPCPos  = nil
    state.lastNPCTime = nil
    saveSettings()
end)
mainTab:CreateToggle("SafeZone", cfg.safeZone, function(v)
    cfg.safeZone = v; saveSettings()
end)
mainTab:CreateToggle("Auto Revive", cfg.autoRevive, function(v)
    cfg.autoRevive = v; saveSettings()
end)
mainTab:CreateToggle("Revive Aura", cfg.reviveAura, function(v)
    cfg.reviveAura = v; saveSettings()
end)
mainTab:CreateToggle("Anti-AFK", cfg.antiAfk, function(v)
    cfg.antiAfk = v; saveSettings()
end)
mainTab:CreateToggle("Hop Server", cfg.hopEnabled, function(v)
    cfg.hopEnabled = v; saveSettings()
end)
mainTab:CreateButton("Hop Now", function() hopServer() end)

configTab:CreateSlider("NPC Lead Time (x0.1)", 1, 10, function(v)
    cfg.leadTime = v / 10; saveSettings()
end)
configTab:CreateSlider("Revive Cooldown (x0.1)", 0, 50, function(v)
    cfg.reviveCooldown = v / 10; saveSettings()
end)
configTab:CreateSlider("SafeZone Cooldown (s)", 1, 10, function(v)
    cfg.safezoneCooldown = v; saveSettings()
end)
