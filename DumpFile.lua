-- ============================================
-- Roblox Game Dumper + Mercury GUI v7.5
-- Fix: BuildPath safe | continue → if/else | makefolder robust
-- ============================================

local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
local HttpService = game:GetService("HttpService")
local Workspace   = game:GetService("Workspace")
local Players     = game:GetService("Players")

if not writefile then
    warn("writefile not available! Executor required.")
    return
end

local BaseFolder = "Dump Filter"

-- ============================================
-- Safe Map Name (MarketplaceService)
-- ============================================
local MapName = "Map_" .. tostring(game.PlaceId)

local ok, info = pcall(function()
    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
end)

if ok and info and info.Name and info.Name ~= "" then
    local raw = tostring(info.Name)
    MapName = raw:gsub("[\\/:%*%?\"<>|%c]", "_"):sub(1, 50)
    if MapName == "" or MapName:match("^_+$") then
        MapName = "Map_" .. tostring(game.PlaceId)
    end
end

print("[Dumper] Map Name: " .. MapName)

-- ============================================
-- File / Folder Helpers
-- ============================================
local function EnsureFolder(path)
    local parts = {}
    for seg in path:gmatch("[^/]+") do
        table.insert(parts, seg)
    end
    local built = ""
    for i, seg in ipairs(parts) do
        built = (i == 1) and seg or (built .. "/" .. seg)
        local ok, err = pcall(makefolder, built)
        if not ok then
            local existOk = pcall(function()
                listfiles(built)
            end)
            if not existOk then
                warn("[Dumper] makefolder FAILED: " .. built .. " | " .. tostring(err))
                return false
            end
        end
    end
    print("[Dumper] Folder ready: " .. path)
    return true
end

local function SaveFile(path, content)
    if not content or content == "" then
        warn("[Dumper] SaveFile skipped (empty content): " .. path)
        return false
    end
    local ok, err = pcall(writefile, path, content)
    if not ok then
        warn("[Dumper] writefile FAILED: " .. tostring(err) .. " | " .. path)
        return false
    end
    print("[Dumper] Saved (" .. #content .. " bytes): " .. path)
    return true
end

-- ============================================
-- BuildPath
-- ============================================
local function BuildPath(instance)
    local chain = {}
    local cur   = instance
    local limit = 64
    while cur and cur ~= game and limit > 0 do
        table.insert(chain, 1, cur)
        local ok, p = pcall(function() return cur.Parent end)
        if not ok then break end
        cur   = p
        limit = limit - 1
    end

    if #chain == 0 then return '"unknown"' end

    local root    = chain[1]
    local rootOk, rootParent = pcall(function() return root.Parent end)
    local result

    if rootOk and rootParent == game then
        local ok2, cn = pcall(function() return root.ClassName end)
        result = ok2 and string.format('game:GetService("%s")', cn) or string.format('game["%s"]', root.Name or "?")
    else
        result = string.format('["%s"]', root.Name or "?")
    end

    for i = 2, #chain do
        local seg   = chain[i]
        local ok3, nm = pcall(function() return seg.Name end)
        result = result .. string.format('["%s"]', ok3 and nm or "?")
    end

    return result
end

-- ============================================
-- Whitelist
-- ============================================
local ImportantClasses = {
    Part=true, MeshPart=true, UnionOperation=true, WedgePart=true,
    CornerWedgePart=true, TrussPart=true, Seat=true, VehicleSeat=true,
    SpawnLocation=true, Model=true, Folder=true,
    ScreenGui=true, BillboardGui=true, SurfaceGui=true,
    Frame=true, TextLabel=true, TextButton=true, TextBox=true,
    ImageLabel=true, ImageButton=true, ScrollingFrame=true, CanvasGroup=true,
    StringValue=true, IntValue=true, BoolValue=true, NumberValue=true,
    ObjectValue=true, Color3Value=true, Vector3Value=true, CFrameValue=true,
    Configuration=true, Tool=true, HopperBin=true,
    Humanoid=true, HumanoidDescription=true,
    ParticleEmitter=true, Trail=true, Beam=true, Fire=true, Smoke=true, Sparkles=true,
    Decal=true, Texture=true, SpecialMesh=true, BlockMesh=true, CylinderMesh=true,
    Attachment=true, ModuleScript=true, LocalScript=true, Script=true,
    Animation=true, Sound=true,
}

local SkipServices = {
    Chat=true, TextChatService=true, SoundService=true, AdService=true,
    AnalyticsService=true, AvatarChatService=true, LocalizationService=true,
    PolicyService=true, PointsService=true, SocialService=true,
    StarterGui=true, StarterPack=true, StarterPlayer=true,
    TeleportService=true, TweenService=true, UserInputService=true,
    VRService=true, ContextActionService=true, GuiService=true,
    HapticService=true, HttpService=true, InsertService=true,
    JointsService=true, LogService=true, MarketplaceService=true,
    MaterialService=true, NetworkClient=true, NetworkServer=true,
    NotificationService=true, PathfindingService=true, PhysicsService=true,
    Players=true, ProximityPromptService=true, ReplicatedFirst=true,
    RunService=true, ScriptContext=true, Selection=true,
    Stats=true, Team=true, Teams=true, TestService=true, TimerService=true,
}

-- ============================================
-- Player Character Check
-- ============================================
local function IsPlayerCharacter(instance)
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char then
            local ok, result = pcall(function() return instance:IsDescendantOf(char) end)
            if ok and result then return true end
        end
    end
    return false
end

-- ============================================
-- Dump Instances
-- ============================================
local function DumpFilter()
    local lines = {}
    local count = 0
    local BATCH = 50

    local ok, all = pcall(function() return game:GetDescendants() end)
    if not ok or not all then
        warn("[Dumper] GetDescendants() failed!")
        return "", 0
    end
    print("[Dumper] Total descendants: " .. #all)

    for i, instance in ipairs(all) do
        if i % BATCH == 0 then
            task.wait()
        end

        local alive = pcall(function() return instance.Parent end)

        if alive and not IsPlayerCharacter(instance) then
            local parentOk, parent = pcall(function() return instance.Parent end)
            local isSkipService = false
            if parentOk and parent == game then
                local nameOk, nm = pcall(function() return instance.Name end)
                if nameOk and SkipServices[nm] then
                    isSkipService = true
                end
            end

            if not isSkipService then
                local classOk, cls = pcall(function() return instance.ClassName end)

                if classOk and ImportantClasses[cls] then
                    local path = BuildPath(instance)
                    local nameOk2, nm2 = pcall(function() return instance.Name end)
                    local dispName = nameOk2 and nm2 or "?"

                    table.insert(lines, string.format('%s  -- [%s] "%s"', path, cls, dispName))

                    local attrOk, attrs = pcall(function() return instance:GetAttributes() end)
                    if attrOk and attrs then
                        for attrName, attrVal in pairs(attrs) do
                            table.insert(lines, string.format('--   .Attr[%s] = %s', attrName, tostring(attrVal)))
                        end
                    end

                    if cls == "Animation" then
                        local ok2, v = pcall(function() return instance.AnimationId end)
                        if ok2 then table.insert(lines, string.format('--   .AnimationId = "%s"', v)) end
                    elseif cls == "Sound" then
                        local ok2, sid = pcall(function() return instance.SoundId end)
                        local ok3, vol = pcall(function() return instance.Volume end)
                        if ok2 then table.insert(lines, string.format('--   .SoundId = "%s" Volume=%s', sid, ok3 and tostring(vol) or "?")) end
                    elseif cls == "SpecialMesh" or cls == "MeshPart" then
                        local ok2, mid = pcall(function() return instance.MeshId end)
                        local ok3, tid = pcall(function() return instance.TextureId end)
                        table.insert(lines, string.format('--   .MeshId="%s" .TextureId="%s"',
                            ok2 and mid or "N/A", ok3 and tid or "N/A"))
                    end

                    count = count + 1
                    table.insert(lines, "")
                end
            end
        end
    end

    print("[Dumper] Filtered instances: " .. count)
    return table.concat(lines, "\n"), count
end

-- ============================================
-- Dump Remotes
-- ============================================
local function DumpRemotes()
    local lines = {}
    local count = 0
    local BATCH = 100

    local ok, all = pcall(function() return game:GetDescendants() end)
    if not ok or not all then return "", 0 end

    for i, instance in ipairs(all) do
        if i % BATCH == 0 then
            task.wait()
        end

        local classOk, cls = pcall(function() return instance.ClassName end)
        if classOk then
            if cls == "RemoteEvent" or cls == "RemoteFunction"
            or cls == "BindableEvent" or cls == "BindableFunction" then
                local path = BuildPath(instance)
                table.insert(lines, string.format('%s  -- [%s]', path, cls))
                local attrOk, attrs = pcall(function() return instance:GetAttributes() end)
                if attrOk and attrs then
                    for k, v in pairs(attrs) do
                        table.insert(lines, string.format('--   .Attr[%s] = %s', k, tostring(v)))
                    end
                end
                count = count + 1
                table.insert(lines, "")
            end
        end
    end
    return table.concat(lines, "\n"), count
end

-- ============================================
-- Dump Game Info
-- ============================================
local function DumpGameInfo()
    local function safe(fn) local ok, v = pcall(fn); return ok and tostring(v) or "N/A" end
    local lines = {
        "-- === GAME INFO ===",
        "-- Map Name:         " .. safe(function() return game.Name end),
        "-- PlaceId:          " .. safe(function() return game.PlaceId end),
        "-- GameId:           " .. safe(function() return game.GameId end),
        "-- PlaceVersion:     " .. safe(function() return game.PlaceVersion end),
        "-- JobId:            " .. safe(function() return game.JobId end),
        "-- CreatorId:        " .. safe(function() return game.CreatorId end),
        "-- CreatorType:      " .. safe(function() return game.CreatorType end),
        "-- PrivateServerId:  " .. safe(function() return game.PrivateServerId end),
        "",
        "-- === WORKSPACE INFO ===",
        "-- Gravity:                  " .. safe(function() return Workspace.Gravity end),
        "-- StreamingEnabled:         " .. safe(function() return Workspace.StreamingEnabled end),
        "-- FallenPartsDestroyHeight: " .. safe(function() return Workspace.FallenPartsDestroyHeight end),
    }
    return table.concat(lines, "\n")
end

-- ============================================
-- Remote Spy
-- ============================================
local SpyActive = false
local SpyLines  = {}

local function StartRemoteSpy()
    if SpyActive then return end
    SpyActive = true
    SpyLines  = {}

    local function argsToStr(args)
        local t = {}
        for i, v in ipairs(args) do
            table.insert(t, string.format("[%d]=%s(%s)", i, tostring(v), typeof(v)))
        end
        return table.concat(t, ", ")
    end

    local ok, all = pcall(function() return game:GetDescendants() end)
    if not ok or not all then return end

    for _, remote in ipairs(all) do
        local classOk, cls = pcall(function() return remote.ClassName end)
        if classOk then
            if cls == "RemoteEvent" then
                local old = remote.FireServer
                remote.FireServer = function(self, ...)
                    local args = {...}
                    table.insert(SpyLines, BuildPath(remote) .. ":FireServer(" .. argsToStr(args) .. ")")
                    return old(self, table.unpack(args))
                end
            elseif cls == "RemoteFunction" then
                local old = remote.InvokeServer
                remote.InvokeServer = function(self, ...)
                    local args = {...}
                    table.insert(SpyLines, BuildPath(remote) .. ":InvokeServer(" .. argsToStr(args) .. ")")
                    return old(self, table.unpack(args))
                end
            end
        end
    end

    spawn(function()
        while SpyActive do
            wait(10)
            if #SpyLines > 0 then
                local sf = BaseFolder .. "/SpyLogs"
                EnsureFolder(sf)
                local snap = table.concat(SpyLines, "\n")
                SpyLines = {}
                SaveFile(sf .. "/Spy_" .. os.time() .. ".txt", snap)
            end
        end
    end)
end

local function StopRemoteSpy()
    SpyActive = false
    if #SpyLines > 0 then
        local sf = BaseFolder .. "/SpyLogs"
        EnsureFolder(sf)
        SaveFile(sf .. "/Spy_Final_" .. os.time() .. ".txt", table.concat(SpyLines, "\n"))
        SpyLines = {}
    end
end

-- ============================================
-- Mercury GUI
-- ============================================
local GUI = Mercury:Create{
    Name = "Game Dumper v7.5",
    Size = UDim2.fromOffset(520, 420),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/deeeity/mercury-lib"
}

local MainTab = GUI:Tab{Name = "Dump", Icon = "rbxassetid://8569322835"}

MainTab:Button{
    Name = "Full Dump",
    Description = "Dump Instances + Remotes + Game Info",
    Callback = function()
        task.spawn(function()
            GUI:Notification{Title = "Starting Dump...", Text = "Creating folders", Duration = 3}

            local rootOk = EnsureFolder(BaseFolder)
            if not rootOk then
                GUI:Notification{Title = "Folder Error", Text = "Failed to create: " .. BaseFolder, Duration = 5}
                return
            end

            local folder = BaseFolder .. "/" .. MapName .. "_" .. tostring(os.time())
            local fOk = EnsureFolder(folder)
            if not fOk then
                GUI:Notification{Title = "Subfolder Error", Text = "Failed to create subfolder", Duration = 5}
                return
            end

            GUI:Notification{Title = "[1/3] Dumping Instances", Text = "Scanning instances...", Duration = 99}
            local filterText, filterCount = DumpFilter()
            SaveFile(folder .. "/Dump Filter.txt", filterText ~= "" and filterText or "-- (no instances found)")
            GUI:Notification{Title = "[1/3] Instances Done", Text = filterCount .. " instances saved", Duration = 4}

            GUI:Notification{Title = "[2/3] Dumping Remotes", Text = "Scanning remotes...", Duration = 99}
            local remText, remCount = DumpRemotes()
            SaveFile(folder .. "/Remotes.txt", remText ~= "" and remText or "-- (no remotes found)")
            GUI:Notification{Title = "[2/3] Remotes Done", Text = remCount .. " remotes saved", Duration = 4}

            GUI:Notification{Title = "[3/3] Dumping Game Info", Text = "Collecting game info...", Duration = 99}
            local infoText = DumpGameInfo()
            SaveFile(folder .. "/GameInfo.txt", infoText)
            GUI:Notification{Title = "[3/3] Game Info Done", Text = "Saved", Duration = 4}

            task.wait(1)
            GUI:Notification{
                Title = "Dump Complete",
                Text = string.format("Instances: %d | Remotes: %d\n%s", filterCount, remCount, folder),
                Duration = 8
            }
            if setclipboard then setclipboard(folder) end
        end)
    end
}

MainTab:Button{
    Name = "Dump Instances",
    Description = "Scan and save all whitelisted instances",
    Callback = function()
        EnsureFolder(BaseFolder)
        local f = BaseFolder .. "/" .. MapName .. "_Instances_" .. os.time()
        EnsureFolder(f)

        local text, count = DumpFilter()
        if text == "" then text = "-- (no instances found)" end

        local saved = SaveFile(f .. "/Dump Filter.txt", text)
        if saved then
            GUI:Notification{Title = "Instances Done", Text = count .. " instances | " .. f, Duration = 5}
        else
            GUI:Notification{Title = "Save Failed", Text = "Check console", Duration = 5}
        end
    end
}

MainTab:Button{
    Name = "Dump Remotes",
    Description = "Scan and save RemoteEvent / RemoteFunction / Bindable",
    Callback = function()
        EnsureFolder(BaseFolder)
        local f = BaseFolder .. "/" .. MapName .. "_Remotes_" .. os.time()
        EnsureFolder(f)
        local text, count = DumpRemotes()
        if text == "" then text = "-- (no remotes found)" end
        SaveFile(f .. "/Remotes.txt", text)
        GUI:Notification{Title = "Remotes Done", Text = "Remotes: " .. count, Duration = 3}
    end
}

MainTab:Button{
    Name = "Clear All Dumps",
    Description = "Delete the entire Dump Filter folder",
    Callback = function()
        if delfolder then
            pcall(delfolder, BaseFolder)
            GUI:Notification{Title = "Cleared", Text = "Dump folder deleted", Duration = 3}
        else
            GUI:Notification{Title = "delfolder Not Supported", Text = "Delete manually in workspace", Duration = 3}
        end
    end
}

-- ============================================
-- Spy Tab
-- ============================================
local SpyTab = GUI:Tab{Name = "Remote Spy", Icon = "rbxassetid://8569322835"}

SpyTab:Toggle{
    Name = "Remote Spy",
    StartingState = false,
    Description = "Hook FireServer / InvokeServer — auto-saves every 10s",
    Callback = function(state)
        if state then StartRemoteSpy() else StopRemoteSpy() end
    end
}

GUI:Credit{Name = "Game Dumper", Description = "v7.5 – Safe BuildPath + layered makefolder", V3rm = "N/A", Discord = "N/A"}
GUI:Notification{Title = "Game Dumper v7.5 Loaded", Text = "Map: " .. MapName, Duration = 5}

print("=== Game Dumper v7.5 ===")
print("[Dumper] Map: " .. MapName)
print("[Dumper] Base: " .. BaseFolder)
