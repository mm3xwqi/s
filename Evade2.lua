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

RunService.Stepped:Connect(function()
    local char = getChar()
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

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

local PlaceID       = game.PlaceId
local AllIDs        = {}
local foundAnything = ""
local actualHour    = os.date("!*t").hour
local HOP_COUNTDOWN = 3

local fileOk = pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
end)
if not fileOk then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
end

local hopNotifyFrame, hopInfoLabel, hopCountdownLabel

local function buildHopUI()
    local existing = player.PlayerGui:FindFirstChild("HopNotifyUI")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "HopNotifyUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 440, 0, 140)
    frame.Position = UDim2.new(0.5, -220, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 170, 255)
    stroke.Thickness = 2
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 34)
    titleLabel.Position = UDim2.new(0, 0, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🚀  กำลัง Hop Server..."
    titleLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = frame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 52)
    infoLabel.Position = UDim2.new(0, 10, 0, 44)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = ""
    infoLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    infoLabel.TextSize = 13
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextWrapped = true
    infoLabel.Parent = frame

    local cdLabel = Instance.new("TextLabel")
    cdLabel.Size = UDim2.new(1, 0, 0, 28)
    cdLabel.Position = UDim2.new(0, 0, 0, 104)
    cdLabel.BackgroundTransparency = 1
    cdLabel.Text = ""
    cdLabel.TextColor3 = Color3.fromRGB(255, 215, 70)
    cdLabel.TextSize = 15
    cdLabel.Font = Enum.Font.GothamBold
    cdLabel.Parent = frame

    hopNotifyFrame    = frame
    hopInfoLabel      = infoLabel
    hopCountdownLabel = cdLabel
end

buildHopUI()

local function getTimezoneStr()
    local utcH   = os.date("!*t").hour
    local localH = os.date("*t").hour
    local offset = localH - utcH
    if offset > 12  then offset = offset - 24 end
    if offset < -12 then offset = offset + 24 end
    return string.format("UTC%+d", offset)
end

local function showHopNotify(serverId, playing, maxP)
    if not hopNotifyFrame then return end
    local shortId = string.sub(tostring(serverId), 1, 20) .. "..."
    hopInfoLabel.Text = string.format(
        "🌐  Server  :  %s\n👥  Players :  %d / %d     🕒  Timezone :  %s",
        shortId, playing, maxP, getTimezoneStr()
    )
    hopNotifyFrame.Visible = true
    for i = HOP_COUNTDOWN, 1, -1 do
        if not hopNotifyFrame.Visible then break end
        hopCountdownLabel.Text = string.format("⏳  ย้ายใน  %d  วินาที...", i)
        task.wait(1)
    end
    hopCountdownLabel.Text = "✅  กำลังเชื่อมต่อ..."
    task.wait(1.2)
    hopNotifyFrame.Visible = false
end

TeleportService.TeleportInitFailed:Connect(function(plr)
    if plr ~= player then return end
    state.isTeleporting = false
    if hopNotifyFrame then hopNotifyFrame.Visible = false end
end)

local function TPReturner()
    local Site
    local ok = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100"
        if foundAnything ~= "" then url = url .. "&cursor=" .. foundAnything end
        Site = HttpService:JSONDecode(game:HttpGet(url))
    end)
    if not ok or not Site or not Site.data then return false end

    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    else
        foundAnything = ""
    end

    local num = 0
    for _, v in pairs(Site.data) do
        local Possible = true
        local ID      = tostring(v.id)
        local playing = tonumber(v.playing)    or 0
        local maxP    = tonumber(v.maxPlayers) or 0

        if ID == game.JobId then Possible = false end
        if playing < 2      then Possible = false end

        if maxP > playing and Possible then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then Possible = false end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end

            if Possible then
                table.insert(AllIDs, ID)
                state.isTeleporting = true

                task.spawn(function()
                    showHopNotify(ID, playing, maxP)
                end)

                task.wait(HOP_COUNTDOWN)

                pcall(function()
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                    TeleportService:TeleportToPlaceInstance(PlaceID, ID, player)
                end)

                task.delay(8, function()
                    if state.isTeleporting then
                        state.isTeleporting = false
                        if hopNotifyFrame then hopNotifyFrame.Visible = false end
                    end
                end)
                return true
            end
        end
    end
    return false
end

local function hopServer()
    if state.isTeleporting then return false end
    local success = false
    pcall(function()
        success = TPReturner()
        if not success and foundAnything ~= "" then
            success = TPReturner()
        end
    end)
    return success
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not (cfg.farmEnabled and cfg.hopEnabled) then continue end
        local char = getChar()
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if isDowned(char) or (hum and hum.Health <= 0) then
            while cfg.farmEnabled and cfg.hopEnabled do
                if not state.isTeleporting then
                    local done = hopServer()
                    if done then break end
                end
                task.wait(0.5)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not (cfg.farmEnabled and cfg.hopEnabled) then continue end
        if state.isTeleporting then continue end
        local gui = player.PlayerGui:FindFirstChild("Global")
        if not gui then continue end
        local rf = gui:FindFirstChild("Rewards")
        if not rf or not rf.Visible then continue end
        task.wait(3)
        if cfg.farmEnabled and cfg.hopEnabled then hopServer() end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if not (cfg.farmEnabled and cfg.hopEnabled) then continue end
        if state.isTeleporting then continue end
        local ok, raw = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Desc&limit=100")
        end)
        if not ok then continue end
        local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok2 or not decoded.data then continue end
        for _, s in ipairs(decoded.data) do
            if tostring(s.id) == game.JobId then
                if s.playing >= s.maxPlayers then
                    while cfg.farmEnabled and cfg.hopEnabled do
                        if not state.isTeleporting then
                            local done = hopServer()
                            if done then break end
                        end
                        task.wait(0.5)
                    end
                end
                break
            end
        end
    end
end)

local window    = library:CreateWindow("Eavde")
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
