local _, library = pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/TrixAde/Osmium/main/OsmiumLibrary.lua")))

if not game:IsLoaded() then game.Loaded:Wait() end

local window    = library:CreateWindow("Eavde")
window:Minimize()
local mainTab   = window:CreateTab("Farm")
local configTab = window:CreateTab("Config")

local NPC_LEAD_TIME         = 0.3
local REVIVE_COOLDOWN       = 0
local NEXTBOT_DANGER_RADIUS = 30
local TICKET_OFFSET         = Vector3.new(0, -10, 0)
local OFFSET_UNDER          = Vector3.new(0, -7,  0)
local ZERO_VEC              = Vector3.new(0,  0,  0)
local SAFEZONE_COOLDOWN     = 2

local SAFE_POSITIONS = {
    Vector3.new(-230, 280, -200),
    Vector3.new(0, 280, 0),
    Vector3.new(230, 280, 200)
}
local safeCount = #SAFE_POSITIONS

_G.SafeZone     = true
_G.NPC_AutoFarm = true
_G.TP_Cooldown  = 0.05

local farmRunning        = false
local reviveRunning      = false
local reviveAuraRunning  = false
local hopRunning         = false
local isActivelyReviving = false
local isFarmingTarget    = false
local isTeleporting      = false

local lastNPCPos  = nil
local lastNPCTime = nil

local player          = game.Players.LocalPlayer
local RunService      = game:GetService("RunService")
local VU              = game:GetService("VirtualUser")
local HttpService     = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local interactRemote  = game:GetService("ReplicatedStorage")
    :WaitForChild("Events")
    :WaitForChild("Character")
    :WaitForChild("Interact")

local function clickButton(btn)
    local absPos  = btn.AbsolutePosition
    local absSize = btn.AbsoluteSize
    local center  = Vector2.new(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2)
    VU:CaptureController()
    VU:ClickButton1(center, CFrame.new())
end

local SAVE_FILE = "autofarm_settings.json"

local function saveSettings()
    local ok, enc = pcall(function()
        return HttpService:JSONEncode({
            farmRunning=farmRunning, NPC_AutoFarm=_G.NPC_AutoFarm,
            SafeZone=_G.SafeZone, reviveRunning=reviveRunning,
            reviveAuraRunning=reviveAuraRunning, hopRunning=hopRunning,
            TP_Cooldown=_G.TP_Cooldown, NPC_LEAD_TIME=NPC_LEAD_TIME,
            REVIVE_COOLDOWN=REVIVE_COOLDOWN, NEXTBOT_DANGER_RADIUS=NEXTBOT_DANGER_RADIUS,
            SAFEZONE_COOLDOWN=SAFEZONE_COOLDOWN,
        })
    end)
    if ok then pcall(writefile, SAVE_FILE, enc) end
end

local function loadSettings()
    local ok, content = pcall(readfile, SAVE_FILE)
    if not ok or not content or content == "" then return nil end
    local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
    if ok2 and type(data) == "table" then return data end
end

local saved = loadSettings()
local function getSaved(k, d) return (saved and saved[k] ~= nil) and saved[k] or d end
farmRunning           = getSaved("farmRunning",           false)
_G.NPC_AutoFarm       = getSaved("NPC_AutoFarm",          true)
_G.SafeZone           = getSaved("SafeZone",              true)
reviveRunning         = getSaved("reviveRunning",         false)
reviveAuraRunning     = getSaved("reviveAuraRunning",     false)
hopRunning            = getSaved("hopRunning",            false)
_G.TP_Cooldown        = getSaved("TP_Cooldown",           0.05)
NPC_LEAD_TIME         = getSaved("NPC_LEAD_TIME",         0.3)
REVIVE_COOLDOWN       = getSaved("REVIVE_COOLDOWN",       0)
NEXTBOT_DANGER_RADIUS = getSaved("NEXTBOT_DANGER_RADIUS", 30)
SAFEZONE_COOLDOWN     = getSaved("SAFEZONE_COOLDOWN",     2)

local function getGamePlayers()
    local g = workspace:FindFirstChild("Game")
    return g and g:FindFirstChild("Players")
end

local function isInGame()
    local gp = getGamePlayers()
    return gp ~= nil and gp:FindFirstChild(player.Name) ~= nil
end

local function warp(hrp, pos)
    hrp.CFrame = CFrame.new(pos)
    hrp.AssemblyLinearVelocity  = ZERO_VEC
    hrp.AssemblyAngularVelocity = ZERO_VEC
end

local function isDowned(character)
    return character ~= nil and character:GetAttribute("Downed") == true
end

local function predictNPC(npcHRP, leadTime)
    local pos = npcHRP.Position
    local now = tick()
    if lastNPCPos and lastNPCTime then
        local dt = now - lastNPCTime
        if dt > 0 then
            local vel = (pos - lastNPCPos) / dt
            lastNPCPos = pos; lastNPCTime = now
            return pos + vel * leadTime
        end
    end
    lastNPCPos = pos; lastNPCTime = now
    return pos
end

local function getSafestZone()
    local gp = getGamePlayers()
    local nb = {}
    if gp then
        for _, m in ipairs(gp:GetChildren()) do
            if m:GetAttribute("Team") == "Nextbot" then
                local h = m:FindFirstChild("HumanoidRootPart")
                if h then table.insert(nb, h.Position) end
            end
        end
    end
    if #nb == 0 then return SAFE_POSITIONS[math.random(1, safeCount)] end
    local best, bestD = SAFE_POSITIONS[1], 0
    for _, sp in ipairs(SAFE_POSITIONS) do
        local minD = math.huge
        for _, n in ipairs(nb) do
            local d = (sp - n).Magnitude
            if d < minD then minD = d end
        end
        if minD > bestD then bestD = minD; best = sp end
    end
    return best
end

local lastSafeTime = 0
local safeTarget   = SAFE_POSITIONS[1]
local safeIndex    = 1

local function refreshSafeTarget()
    if (tick() - lastSafeTime) >= SAFEZONE_COOLDOWN then
        lastSafeTime = tick()
        safeTarget   = getSafestZone()
    end
end

local function lockToSafe(hrp)
    refreshSafeTarget()
    warp(hrp, safeTarget)
end

local function goSafe(hrp)
    if hrp and hrp.Parent then
        lastSafeTime = 0
        lockToSafe(hrp)
    end
end

task.spawn(function()
    while true do
        task.wait(3)
        if not _G.SafeZone then continue end
        safeIndex    = (safeIndex % safeCount) + 1
        safeTarget   = SAFE_POSITIONS[safeIndex]
        lastSafeTime = tick()
    end
end)

RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not _G.SafeZone    then return end
    if isActivelyReviving then return end
    if isFarmingTarget    then return end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(safeTarget)
    hrp.AssemblyLinearVelocity  = ZERO_VEC
    hrp.AssemblyAngularVelocity = ZERO_VEC
end)

RunService.Heartbeat:Connect(function()
    if not farmRunning    then isFarmingTarget = false; return end
    if isActivelyReviving then isFarmingTarget = false; return end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then isFarmingTarget = false; return end
    local gameFolder    = workspace:FindFirstChild("Game")
    local effects       = gameFolder and gameFolder:FindFirstChild("Effects")
    local tickets       = effects and effects:FindFirstChild("Tickets")
    local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")
    if _G.NPC_AutoFarm and playersFolder then
        local npc    = playersFolder:FindFirstChild("Bee")
        local npcHRP = npc and npc:FindFirstChild("HumanoidRootPart")
        if npcHRP then
            isFarmingTarget = true
            warp(hrp, predictNPC(npcHRP, NPC_LEAD_TIME))
            return
        else
            lastNPCPos  = nil
            lastNPCTime = nil
        end
    end
    if tickets then
        local mover = nil
        for _, t in ipairs(tickets:GetChildren()) do
            local m = t:FindFirstChild("Mover")
            if m and m:IsA("BasePart") then mover = m; break end
        end
        if mover then
            isFarmingTarget = true
            warp(hrp, mover.Position + TICKET_OFFSET)
            return
        end
    end
    isFarmingTarget = false
    if _G.SafeZone then warp(hrp, safeTarget) end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not farmRunning then continue end
        local char = player.Character
        if isDowned(char) then
            while isDowned(player.Character) do
                interactRemote:FireServer("Revive", true, player.Name)
                task.wait(0.05)
            end
        elseif not isInGame() then
            while not isInGame() do
                pcall(function()
                    local mainMenu = player.PlayerGui.Menu.Views.Default.MainMenu
                    local btnB     = mainMenu.Center.Buttons.Frame.B
                    if not mainMenu.Visible or not btnB.Visible then return end
                    clickButton(btnB)
                end)
                task.wait(0.5)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not reviveRunning then continue end
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        if isDowned(char) then
            while isDowned(player.Character) do
                interactRemote:FireServer("Revive", true, player.Name)
                task.wait(0.05)
            end
            continue
        end
        local gp = getGamePlayers()
        if not gp then
            if _G.SafeZone then lockToSafe(hrp) end
            continue
        end
        local target, tHRP = nil, nil
        for _, model in ipairs(gp:GetChildren()) do
            if model.Name ~= player.Name
            and model:GetAttribute("Team") ~= "Nextbot"
            and isDowned(model) then
                local h = model:FindFirstChild("HumanoidRootPart")
                if h then target = model; tHRP = h; break end
            end
        end
        if not target then
            if _G.SafeZone then lockToSafe(hrp) end
            continue
        end
        isActivelyReviving = true
        local reviveStart = tick()
        pcall(function()
            while isDowned(target) do
                if not target.Parent          then break end
                if not hrp or not hrp.Parent  then break end
                if isDowned(player.Character) then break end
                if tick() - reviveStart > 5   then break end
                if tHRP and tHRP.Parent then
                    warp(hrp, tHRP.Position + OFFSET_UNDER)
                end
                interactRemote:FireServer("Revive", true, target.Name)
                task.wait(0.05)
            end
        end)
        isActivelyReviving = false
        if _G.SafeZone and hrp and hrp.Parent then goSafe(hrp) end
        task.wait(REVIVE_COOLDOWN)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if not reviveAuraRunning then continue end
        local char = player.Character
        if isDowned(char) then
            interactRemote:FireServer("Revive", true, player.Name)
            continue
        end
        local gp = getGamePlayers()
        if not gp then continue end
        for _, model in ipairs(gp:GetChildren()) do
            if model.Name ~= player.Name
            and model:GetAttribute("Team") ~= "Nextbot"
            and isDowned(model) then
                interactRemote:FireServer("Revive", true, model.Name)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local mainMenu = player.PlayerGui.Menu.Views.Default.MainMenu
            local btnB     = mainMenu.Center.Buttons.Frame.B
            if not mainMenu.Visible or not btnB.Visible then return end
            clickButton(btnB)
        end)
    end
end)

local PlaceID       = game.PlaceId
local AllIDs        = {}
local foundAnything = ""
local actualHour    = os.date("!*t").hour

local fileOk = pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
end)
if not fileOk then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
end

TeleportService.TeleportInitFailed:Connect(function(plr, result, msg)
    if plr ~= player then return end
    isTeleporting = false
end)

local function TPReturner()
    local Site
    local ok = pcall(function()
        local url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Desc&limit=100'
        if foundAnything ~= "" then url = url .. '&cursor=' .. foundAnything end
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
        local ID = tostring(v.id)
        if ID == game.JobId then Possible = false end
        if tonumber(v.playing) < 10 then Possible = false end
        if tonumber(v.maxPlayers) > tonumber(v.playing) and Possible then
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
                task.wait()
                isTeleporting = true
                pcall(function()
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                    task.wait()
                    TeleportService:TeleportToPlaceInstance(PlaceID, ID, player)
                end)
                task.delay(15, function()
                    if isTeleporting then isTeleporting = false end
                end)
                task.wait(4)
                return true
            end
        end
    end
    return false
end

local function hopServer()
    if isTeleporting then return false end
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
        task.wait(0.5)
        if not (farmRunning and hopRunning) then continue end
        if isTeleporting then continue end
        local ok, gui = pcall(function() return player.PlayerGui:WaitForChild("Global", 10) end)
        if not ok or not gui then continue end
        local rf = gui:FindFirstChild("Rewards")
        if not rf or not rf.Visible then continue end
        task.wait(5)
        while farmRunning and hopRunning and rf.Visible do
            if not isTeleporting then hopServer() end
            task.wait(3)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if not (farmRunning and hopRunning) then continue end
        if isTeleporting then continue end
        local ok, raw = pcall(function()
            return game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Desc&limit=100')
        end)
        if not ok then continue end
        local ok2, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok2 or not decoded.data then continue end
        for _, s in ipairs(decoded.data) do
            if s.id == game.JobId then
                if s.playing >= s.maxPlayers then
                    while farmRunning and hopRunning do
                        if not isTeleporting then hopServer() end
                        task.wait(3)
                        if not isTeleporting then break end
                    end
                end
                break
            end
        end
    end
end)

mainTab:CreateToggle("AutoFarm Ticket", farmRunning, function(v) farmRunning=v; saveSettings() end)
mainTab:CreateToggle("Bee Farm", _G.NPC_AutoFarm, function(v) _G.NPC_AutoFarm=v; lastNPCPos=nil; lastNPCTime=nil; saveSettings() end)
mainTab:CreateToggle("SafeZone", _G.SafeZone, function(v) _G.SafeZone=v; saveSettings() end)
mainTab:CreateToggle("Auto Revive All", reviveRunning, function(v) reviveRunning=v; saveSettings() end)
mainTab:CreateToggle("Revive Aura", reviveAuraRunning, function(v) reviveAuraRunning=v; saveSettings() end)
mainTab:CreateToggle("HopServer With Auto Farm", hopRunning, function(v) hopRunning=v; saveSettings() end)
mainTab:CreateButton("Hop Server", function() hopServer() end)
configTab:CreateSlider("TP Cooldown (ms)", 0, 50, function(v) _G.TP_Cooldown=v/1000; saveSettings() end)
configTab:CreateSlider("NPC Lead Time (x0.1)", 3, 10, function(v) NPC_LEAD_TIME=v/10; saveSettings() end)
configTab:CreateSlider("Revive Cooldown (x0.1)", 0, 50, function(v) REVIVE_COOLDOWN=v/10; saveSettings() end)
configTab:CreateSlider("Nextbot Danger Radius", 30, 60, function(v) NEXTBOT_DANGER_RADIUS=v; saveSettings() end)
configTab:CreateSlider("SafeZone Cooldown (s)", 1, 10, function(v) SAFEZONE_COOLDOWN=v; saveSettings() end)
