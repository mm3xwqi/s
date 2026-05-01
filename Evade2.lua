local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

if not game:IsLoaded() then game.Loaded:Wait() end

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local RepStorage      = game:GetService("ReplicatedStorage")
local VIM             = game:GetService("VirtualInputManager")

local interactRemote   = RepStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")
local changeModeRemote = RepStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode")

local lp = Players.LocalPlayer

local cfg = {
    farmEnabled      = false,
    beeFarm          = true,
    safeZone         = true,
    selfRevive       = true,
    autoRevive       = false,
    reviveAura       = false,
    hopEnabled       = false,
    antiAfk          = true,
    leadTime         = 0.3,
    reviveCooldown   = 0,
    safezoneCooldown = 2,
}

local ZERO          = Vector3.new(0, 0, 0)
local TICKET_OFFSET = Vector3.new(0, 3, 0)
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
    pcall(writefile, SAVE_FILE, HttpService:JSONEncode(cfg))
end

local function loadSettings()
    local ok, raw = pcall(readfile, SAVE_FILE)
    if not ok or not raw or raw == "" then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end
    for k, v in pairs(data) do
        if cfg[k] ~= nil then cfg[k] = v end
    end
end

loadSettings()

local function getChar()    return lp.Character end
local function getHRP()     local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function isDowned(m)  return m and m:GetAttribute("Downed") == true end
local function isCarried(m) return m and m:GetAttribute("Carried") == true end

local function isInGame()
    local gp = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    return gp and gp:FindFirstChild(lp.Name) ~= nil
end

local function getGamePlayers()
    local g = workspace:FindFirstChild("Game")
    return g and g:FindFirstChild("Players")
end

local function getMyModel()
    local gp = getGamePlayers()
    return gp and gp:FindFirstChild(lp.Name)
end

local function warp(hrp, pos)
    if not hrp or not hrp.Parent then return end
    hrp.CFrame = CFrame.new(pos)
    hrp.AssemblyLinearVelocity  = ZERO
    hrp.AssemblyAngularVelocity = ZERO
end

local function refreshSafeSpot()
    if (tick() - state.lastSafeUpdate) >= cfg.safezoneCooldown then
        state.lastSafeUpdate = tick()
        state.safeTarget = SAFE_SPOTS[state.safeIndex]
    end
end

local function goSafe()
    local hrp = getHRP()
    if not hrp then return end
    state.lastSafeUpdate = 0
    refreshSafeSpot()
    warp(hrp, state.safeTarget)
end

local function predictPos(npcHRP)
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
    if not cfg.safeZone or state.isReviving or state.isFarming then return end
    local hrp = getHRP()
    if not hrp then return end
    refreshSafeSpot()
    warp(hrp, state.safeTarget)
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
    if not cfg.farmEnabled or state.isReviving then
        state.isFarming = false; return
    end
    local hrp = getHRP()
    if not hrp then state.isFarming = false; return end

    local gameFolder = workspace:FindFirstChild("Game")
    local gp         = gameFolder and gameFolder:FindFirstChild("Players")
    local effects    = gameFolder and gameFolder:FindFirstChild("Effects")
    local tickets    = effects and effects:FindFirstChild("Tickets")

    if cfg.beeFarm and gp then
        local beeHRP = gp:FindFirstChild("Bee") and gp.Bee:FindFirstChild("HumanoidRootPart")
        if beeHRP then
            state.isFarming = true
            warp(hrp, predictPos(beeHRP))
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
        task.wait(0.1)
        if not cfg.selfRevive then continue end
        local myModel = getMyModel()
        if not myModel then continue end
        if isDowned(myModel) then
            repeat
                pcall(changeModeRemote.FireServer, changeModeRemote, true)
                task.wait(0.05)
                myModel = getMyModel()
            until not myModel or not isDowned(myModel)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not cfg.farmEnabled then continue end
        if not isInGame() then
            pcall(function()
                if lp.PlayerGui:FindFirstChild("Menu") then
                    changeModeRemote:FireServer(true)
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not cfg.autoRevive then continue end
        local hrp = getHRP()
        if not hrp then continue end
        if isDowned(getMyModel()) then continue end

        local gp = getGamePlayers()
        if not gp then if cfg.safeZone then goSafe() end; continue end

        local target, tHRP, closest = nil, nil, math.huge
        for _, model in ipairs(gp:GetChildren()) do
            if model.Name ~= lp.Name
            and model:GetAttribute("Team") ~= "Nextbot"
            and isDowned(model) and not isCarried(model) then
                local h = model:FindFirstChild("HumanoidRootPart")
                if h then
                    local d = (h.Position - hrp.Position).Magnitude
                    if d < closest then closest = d; target = model; tHRP = h end
                end
            end
        end

        if not target then if cfg.safeZone then goSafe() end; continue end

        state.isReviving = true
        local t0 = tick()
        pcall(function()
            while isDowned(target) do
                if not target.Parent or not hrp.Parent then break end
                if tick() - t0 > 5 or isCarried(target) then break end
                if tHRP and tHRP.Parent then warp(hrp, tHRP.Position + REVIVE_OFFSET) end
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
        if isDowned(getMyModel()) then continue end
        local gp = getGamePlayers()
        if not gp then continue end
        for _, model in ipairs(gp:GetChildren()) do
            if model.Name ~= lp.Name
            and model:GetAttribute("Team") ~= "Nextbot"
            and isDowned(model) and not isCarried(model) then
                pcall(interactRemote.FireServer, interactRemote, "Revive", true, model.Name)
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

task.spawn(function()
    while true do
        task.wait(0.2)
        if not cfg.farmEnabled then continue end
        pcall(function()
            local shared = lp.PlayerGui:FindFirstChild("Shared")
            local respawnGui = shared and shared:FindFirstChild("Respawn")
            if not respawnGui then return end

            local visible = false
            if respawnGui:IsA("ScreenGui") then
                for _, child in ipairs(respawnGui:GetChildren()) do
                    if child:IsA("GuiObject") and child.Visible then visible = true; break end
                end
            elseif respawnGui:IsA("GuiObject") then
                visible = respawnGui.Visible
            end

            if not visible then return end

            for _, obj in ipairs(respawnGui:GetDescendants()) do
                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                    obj.MouseButton1Click:Fire()
                end
            end
        end)
    end
end)

local PlaceID    = game.PlaceId

local hopFrame, hopInfo, hopCountdown

local visitedIDs = {}
local hopCursor  = ""

pcall(function()
    local data = HttpService:JSONDecode(readfile("EvadeFarmHop.json"))
    if type(data) == "table" then visitedIDs = data end
end)

local function isVisited(id)
    for _, v in ipairs(visitedIDs) do
        if tostring(v) == tostring(id) then return true end
    end
    return false
end

local function markVisited(id)
    table.insert(visitedIDs, id)
    pcall(writefile, "EvadeFarmHop.json", HttpService:JSONEncode(visitedIDs))
end

local function resetVisited()
    visitedIDs = {}
    hopCursor  = ""
    pcall(delfile, "EvadeFarmHop.json")
end

local function getPage()
    local url = "https://games.roblox.com/v1/games/" .. tostring(PlaceID) .. "/servers/Public?sortOrder=Desc&limit=100"
    if hopCursor ~= "" then url = url .. "&cursor=" .. hopCursor end
    local raw = nil
    pcall(function()
        local fn = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
        if typeof(fn) == "function" then
            local res = fn({ Url = url, Method = "GET" })
            if res and res.Body and #res.Body > 10 then raw = res.Body end
        end
    end)
    if not raw then
        pcall(function()
            local res = game:HttpGet(url)
            if res and #res > 10 then raw = res end
        end)
    end
    if not raw then return nil end
    local ok, body = pcall(HttpService.JSONDecode, HttpService, raw)
    return ok and body or nil
end

local function hopServer(fast)
    if state.isTeleporting then return end
    state.isTeleporting = true

    Library:Notify({ Title = "Auto Hop", Description = "กำลังค้นหาเซิร์ฟเวอร์...", Time = 3 })

    local MAX_PAGES = 10
    local tries = 0

    while tries < MAX_PAGES do
        local body = getPage()

        if not body then
            Library:Notify({ Title = "Auto Hop", Description = "ดึงข้อมูลไม่ได้ ลองใหม่...", Time = 2 })
            task.wait(3)
            tries += 1
            continue
        end

        if not body.data or #body.data == 0 then
            Library:Notify({ Title = "Auto Hop", Description = "ไม่มีข้อมูลเซิร์ฟเวอร์", Time = 2 })
            task.wait(3)
            tries += 1
            continue
        end

        table.sort(body.data, function(a, b)
            return (tonumber(a.playing) or 0) > (tonumber(b.playing) or 0)
        end)

        for _, v in ipairs(body.data) do
            local id      = tostring(v.id or "")
            local playing = tonumber(v.playing)    or 0
            local maxP    = tonumber(v.maxPlayers) or 0

            if id ~= ""
            and id ~= tostring(game.JobId)
            and playing < maxP
            and not isVisited(id) then
                markVisited(id)
                Library:Notify({
                    Title = "Auto Hop",
                    Description = string.format("กำลัง Hop → %d/%d คน", playing, maxP),
                    Time = 3
                })
                if hopFrame then
                    hopFrame.Visible = true
                    hopInfo.Text = string.format("Hopping → %s (%d/%d)", id:sub(1,12), playing, maxP)
                    hopCountdown.Text = "⏳ Teleporting..."
                end
                if not fast then task.wait(0.5) end
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceID, id, lp)
                end)
                if not ok then
                    Library:Notify({ Title = "Auto Hop", Description = "Teleport ล้มเหลว: " .. tostring(err), Time = 3 })
                    state.isTeleporting = false
                    if hopFrame then hopFrame.Visible = false end
                end
                return
            end
        end

        local nextCursor = body.nextPageCursor
        if nextCursor and nextCursor ~= "null" and nextCursor ~= "" then
            hopCursor = nextCursor
            Library:Notify({ Title = "Auto Hop", Description = "โหลดหน้าถัดไป...", Time = 1 })
        else
            resetVisited()
            Library:Notify({ Title = "Auto Hop", Description = "ครบทุกหน้าแล้ว รีเซ็ตใหม่...", Time = 2 })
        end

        tries += 1
        task.wait(3)
    end

    state.isTeleporting = false
    if hopFrame then hopFrame.Visible = false end
    Library:Notify({ Title = "Auto Hop", Description = "ไม่พบเซิร์ฟเวอร์", Time = 4 })
end

local function buildHopUI()
    local existing = lp.PlayerGui:FindFirstChild("HopUI")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui")
    sg.Name = "HopUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = lp.PlayerGui

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

    hopFrame = frame; hopInfo = info; hopCountdown = cd
end

buildHopUI()

TeleportService.TeleportInitFailed:Connect(function(plr)
    if plr ~= lp then return end
    state.isTeleporting = false
    if hopFrame then hopFrame.Visible = false end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if not (cfg.farmEnabled and cfg.hopEnabled) or state.isTeleporting then continue end
        local gui = lp.PlayerGui:FindFirstChild("Global")
        local rf  = gui and gui:FindFirstChild("Rewards")
        if rf and rf.Visible then
            hopServer(true)
        end
    end
end)

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Evade Farm",
    Footer = "by Index",
    Icon = 0,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Farm   = Window:AddTab("Farm",   "zap"),
    Config = Window:AddTab("Config", "sliders-horizontal"),
    UI     = Window:AddTab("UI Settings", "settings"),
}

local FarmBox = Tabs.Farm:AddLeftGroupbox("AutoFarm")

FarmBox:AddToggle("farmEnabled", {
    Text    = "AutoFarm",
    Default = cfg.farmEnabled,
    Tooltip = "Enable/disable all farming",
    Callback = function(v) cfg.farmEnabled = v; saveSettings() end,
})

FarmBox:AddToggle("beeFarm", {
    Text    = "Bee Farm",
    Default = cfg.beeFarm,
    Tooltip = "Follow the Bee NPC",
    Callback = function(v)
        cfg.beeFarm = v
        state.lastNPCPos  = nil
        state.lastNPCTime = nil
        saveSettings()
    end,
})

FarmBox:AddToggle("safeZone", {
    Text    = "SafeZone",
    Default = cfg.safeZone,
    Tooltip = "Lock position to a safe spot",
    Callback = function(v) cfg.safeZone = v; saveSettings() end,
})

FarmBox:AddDivider()

local ReviveBox = Tabs.Farm:AddRightGroupbox("Revive")

ReviveBox:AddToggle("selfRevive", {
    Text    = "Self Revive",
    Default = cfg.selfRevive,
    Tooltip = "Auto revive yourself when downed",
    Callback = function(v) cfg.selfRevive = v; saveSettings() end,
})

ReviveBox:AddToggle("autoRevive", {
    Text    = "Auto Revive (Others)",
    Default = cfg.autoRevive,
    Tooltip = "Walk to and revive downed teammates",
    Callback = function(v) cfg.autoRevive = v; saveSettings() end,
})

ReviveBox:AddToggle("reviveAura", {
    Text    = "Revive Aura",
    Default = cfg.reviveAura,
    Tooltip = "Fire revive remote to all downed players without moving",
    Callback = function(v) cfg.reviveAura = v; saveSettings() end,
})

ReviveBox:AddDivider()

local HopBox = Tabs.Farm:AddRightGroupbox("Server Hop")

HopBox:AddToggle("hopEnabled", {
    Text    = "Auto Hop",
    Default = cfg.hopEnabled,
    Tooltip = "Hop when Rewards appear",
    Callback = function(v) cfg.hopEnabled = v; saveSettings() end,
})

HopBox:AddToggle("antiAfk", {
    Text    = "Anti-AFK",
    Default = cfg.antiAfk,
    Tooltip = "Press F24 every 60s to prevent kick",
    Callback = function(v) cfg.antiAfk = v; saveSettings() end,
})

HopBox:AddButton({
    Text    = "Hop Now",
    Tooltip = "Manually hop to a new server",
    Func    = function() hopServer() end,
})

local CfgBox = Tabs.Config:AddLeftGroupbox("Settings")

CfgBox:AddSlider("leadTime", {
    Text    = "NPC Lead Time",
    Default = math.floor(cfg.leadTime * 10),
    Min     = 1, Max = 10, Rounding = 0,
    Suffix  = " (x0.1s)",
    Tooltip = "How far ahead to predict NPC position",
    Callback = function(v) cfg.leadTime = v / 10; saveSettings() end,
})

CfgBox:AddSlider("reviveCooldown", {
    Text    = "Revive Cooldown",
    Default = math.floor(cfg.reviveCooldown * 10),
    Min     = 0, Max = 50, Rounding = 0,
    Suffix  = " (x0.1s)",
    Tooltip = "Wait time after reviving someone",
    Callback = function(v) cfg.reviveCooldown = v / 10; saveSettings() end,
})

CfgBox:AddSlider("safezoneCooldown", {
    Text    = "SafeZone Cooldown",
    Default = cfg.safezoneCooldown,
    Min     = 1, Max = 10, Rounding = 0,
    Suffix  = "s",
    Tooltip = "How often to update safe spot",
    Callback = function(v) cfg.safezoneCooldown = v; saveSettings() end,
})

local MenuGroup = Tabs.UI:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default  = Library.KeybindFrame.Visible,
    Text     = "Open Keybind Menu",
    Callback = function(v) Library.KeybindFrame.Visible = v end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text     = "Custom Cursor",
    Default  = true,
    Callback = function(v) Library.ShowCustomCursor = v end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values   = { "Left", "Right" },
    Default  = "Right",
    Text     = "Notification Side",
    Callback = function(v) Library:SetNotifySide(v) end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton({
    Text = "Unload",
    Func = function() Library:Unload() end,
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("EvadeFarm")
SaveManager:SetFolder("EvadeFarm/configs")
SaveManager:BuildConfigSection(Tabs.UI)
ThemeManager:ApplyToTab(Tabs.UI)
SaveManager:LoadAutoloadConfig()

Library:Notify({
    Title       = "Evade Farm",
    Description = "Script loaded",
    Time        = 4,
})
