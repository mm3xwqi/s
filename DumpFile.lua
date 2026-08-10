-- ============================================
-- Roblox Game Dumper + Mercury GUI v7.5
-- ============================================

local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
local Workspace = game:GetService("Workspace")
local Players   = game:GetService("Players")
local MPS       = game:GetService("MarketplaceService")

if not writefile then
    warn("[Dumper] writefile not available. Executor required.")
    return
end

local BaseFolder = "Dump Filter"

-- ============================================
-- Map Name via MarketplaceService
-- ============================================
local MapName = "Map_" .. tostring(game.PlaceId)

local ok, info = pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
if ok and info and info.Name and info.Name ~= "" then
    local raw = tostring(info.Name):gsub("[\\/:%*%?\"<>|%c]", "_"):sub(1, 50)
    if raw ~= "" and not raw:match("^_+$") then MapName = raw end
end

print("[Dumper] Map: " .. MapName)

-- ============================================
-- Folder / File Helpers
-- ============================================
local function EnsureFolder(path)
    local built = ""
    for seg in path:gmatch("[^/]+") do
        built = built == "" and seg or (built .. "/" .. seg)
        local ok2, err = pcall(makefolder, built)
        if not ok2 then
            local exists = pcall(listfiles, built)
            if not exists then
                warn("[Dumper] makefolder failed: " .. built .. " | " .. tostring(err))
                return false
            end
        end
    end
    return true
end

local function SaveFile(path, content)
    if not content or content == "" then
        warn("[Dumper] Skipped empty file: " .. path)
        return false
    end
    local ok2, err = pcall(writefile, path, content)
    if not ok2 then
        warn("[Dumper] writefile failed: " .. path .. " | " .. tostring(err))
        return false
    end
    print("[Dumper] Saved " .. #content .. " bytes → " .. path)
    return true
end

-- ============================================
-- BuildPath (iterative, stack-safe)
-- ============================================
local function BuildPath(instance)
    local chain, cur, limit = {}, instance, 64
    while cur and cur ~= game and limit > 0 do
        table.insert(chain, 1, cur)
        local p_ok, p = pcall(function() return cur.Parent end)
        if not p_ok then break end
        cur, limit = p, limit - 1
    end
    if #chain == 0 then return '"unknown"' end

    local root = chain[1]
    local rp_ok, rp = pcall(function() return root.Parent end)
    local result
    if rp_ok and rp == game then
        local cn_ok, cn = pcall(function() return root.ClassName end)
        result = cn_ok and ('game:GetService("' .. cn .. '")') or ('game["' .. (root.Name or "?") .. '"]')
    else
        result = '["' .. (root.Name or "?") .. '"]'
    end

    for i = 2, #chain do
        local nm_ok, nm = pcall(function() return chain[i].Name end)
        result = result .. '["' .. (nm_ok and nm or "?") .. '"]'
    end
    return result
end

-- ============================================
-- Whitelists
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
-- Player Character Guard
-- ============================================
local function IsPlayerCharacter(instance)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local ok2, res = pcall(function() return instance:IsDescendantOf(p.Character) end)
            if ok2 and res then return true end
        end
    end
    return false
end

-- ============================================
-- GetDescendants with progress (shared)
-- ============================================
local function GetAll()
    local ok2, all = pcall(function() return game:GetDescendants() end)
    if not ok2 or not all then
        warn("[Dumper] GetDescendants() failed!")
        return nil
    end
    print("[Dumper] Total descendants: " .. #all)
    return all
end

-- ============================================
-- Notify Helper  (ลด boilerplate)
-- ============================================
local GUI  -- forward declare; assigned below
local function Notify(title, text, duration)
    GUI:Notification{ Title = title, Text = text, Duration = duration or 4 }
end

-- ============================================
-- Dump Instances
-- ============================================
local function DumpInstances(all)
    local lines, count = {}, 0
    for i, inst in ipairs(all) do
        if i % 50 == 0 then task.wait() end

        local alive = pcall(function() return inst.Parent end)
        if alive and not IsPlayerCharacter(inst) then

            local par_ok, par = pcall(function() return inst.Parent end)
            local skip = par_ok and par == game and (function()
                local nm_ok, nm = pcall(function() return inst.Name end)
                return nm_ok and SkipServices[nm]
            end)()

            if not skip then
                local cls_ok, cls = pcall(function() return inst.ClassName end)
                if cls_ok and ImportantClasses[cls] then
                    local nm_ok2, nm2 = pcall(function() return inst.Name end)
                    table.insert(lines, string.format('%s  -- [%s] "%s"', BuildPath(inst), cls, nm_ok2 and nm2 or "?"))

                    local attr_ok, attrs = pcall(function() return inst:GetAttributes() end)
                    if attr_ok and attrs then
                        for k, v in pairs(attrs) do
                            table.insert(lines, string.format('--   .Attr[%s] = %s', k, tostring(v)))
                        end
                    end

                    if cls == "Animation" then
                        local ok2, v = pcall(function() return inst.AnimationId end)
                        if ok2 then table.insert(lines, '--   .AnimationId = "' .. v .. '"') end
                    elseif cls == "Sound" then
                        local ok2, sid = pcall(function() return inst.SoundId end)
                        local ok3, vol = pcall(function() return inst.Volume end)
                        if ok2 then
                            table.insert(lines, string.format('--   .SoundId = "%s" Volume=%s', sid, ok3 and tostring(vol) or "?"))
                        end
                    elseif cls == "SpecialMesh" or cls == "MeshPart" then
                        local ok2, mid = pcall(function() return inst.MeshId end)
                        local ok3, tid = pcall(function() return inst.TextureId end)
                        table.insert(lines, string.format('--   .MeshId="%s" .TextureId="%s"',
                            ok2 and mid or "N/A", ok3 and tid or "N/A"))
                    end

                    count = count + 1
                    table.insert(lines, "")
                end
            end
        end
    end
    print("[Dumper] Instances found: " .. count)
    return table.concat(lines, "\n"), count
end

-- ============================================
-- Dump Remotes
-- ============================================
local RemoteClasses = {
    RemoteEvent=true, RemoteFunction=true,
    BindableEvent=true, BindableFunction=true,
}

local function DumpRemotes(all)
    local lines, count = {}, 0
    for i, inst in ipairs(all) do
        if i % 100 == 0 then task.wait() end
        local cls_ok, cls = pcall(function() return inst.ClassName end)
        if cls_ok and RemoteClasses[cls] then
            table.insert(lines, string.format('%s  -- [%s]', BuildPath(inst), cls))
            local attr_ok, attrs = pcall(function() return inst:GetAttributes() end)
            if attr_ok and attrs then
                for k, v in pairs(attrs) do
                    table.insert(lines, string.format('--   .Attr[%s] = %s', k, tostring(v)))
                end
            end
            count = count + 1
            table.insert(lines, "")
        end
    end
    print("[Dumper] Remotes found: " .. count)
    return table.concat(lines, "\n"), count
end

-- ============================================
-- Dump Game Info
-- ============================================
local function DumpGameInfo()
    local function safe(fn) local ok2, v = pcall(fn); return ok2 and tostring(v) or "N/A" end
    return table.concat({
        "-- === GAME INFO ===",
        "-- Map Name:         " .. MapName,
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
    }, "\n")
end

-- ============================================
-- Remote Spy
-- ============================================
local SpyActive = false
local SpyLines  = {}

local function FlushSpy(tag)
    if #SpyLines == 0 then return end
    local sf = BaseFolder .. "/SpyLogs"
    EnsureFolder(sf)
    SaveFile(sf .. "/Spy_" .. tag .. "_" .. os.time() .. ".txt", table.concat(SpyLines, "\n"))
    SpyLines = {}
end

local function StartRemoteSpy()
    if SpyActive then return end
    SpyActive = true
    SpyLines  = {}

    local function argsToStr(args)
        local t = {}
        for i, v in ipairs(args) do
            t[i] = string.format("[%d]=%s(%s)", i, tostring(v), typeof(v))
        end
        return table.concat(t, ", ")
    end

    local ok2, all = pcall(function() return game:GetDescendants() end)
    if not ok2 or not all then return end

    for _, remote in ipairs(all) do
        local cls_ok, cls = pcall(function() return remote.ClassName end)
        if cls_ok then
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

    task.spawn(function()
        while SpyActive do
            task.wait(10)
            FlushSpy("Auto")
        end
    end)
end

local function StopRemoteSpy()
    SpyActive = false
    FlushSpy("Final")
end

-- ============================================
-- Core Dump Runner (shared between buttons)
-- ============================================
local function RunDump(doInstances, doRemotes, doGameInfo, labelPrefix)
    local prefix = labelPrefix or ""

    -- Setup folders
    Notify(prefix .. "Starting...", "Creating output folder", 3)
    if not EnsureFolder(BaseFolder) then
        Notify(prefix .. "Folder Error", "Cannot create: " .. BaseFolder, 5)
        return
    end

    local folder = BaseFolder .. "/" .. MapName .. "_" .. tostring(os.time())
    if not EnsureFolder(folder) then
        Notify(prefix .. "Folder Error", "Cannot create subfolder", 5)
        return
    end

    -- Fetch descendants once for all tasks
    local all = GetAll()
    if not all then
        Notify(prefix .. "Scan Failed", "GetDescendants() returned nothing", 5)
        return
    end

    local instanceCount, remoteCount = 0, 0

    if doInstances then
        Notify(prefix .. "Scanning Instances...", "This may take a moment", 99)
        local text, count = DumpInstances(all)
        instanceCount = count
        SaveFile(folder .. "/Instances.txt", text ~= "" and text or "-- (no instances found)")
        Notify(prefix .. "Instances Done", count .. " instances saved", 4)
    end

    if doRemotes then
        Notify(prefix .. "Scanning Remotes...", "Searching for Remote/Bindable", 99)
        local text, count = DumpRemotes(all)
        remoteCount = count
        SaveFile(folder .. "/Remotes.txt", text ~= "" and text or "-- (no remotes found)")
        Notify(prefix .. "Remotes Done", count .. " remotes saved", 4)
    end

    if doGameInfo then
        Notify(prefix .. "Collecting Game Info...", "Reading DataModel properties", 99)
        SaveFile(folder .. "/GameInfo.txt", DumpGameInfo())
        Notify(prefix .. "Game Info Done", "Saved to " .. folder, 4)
    end

    -- Summary
    task.wait(0.5)
    local summary = {}
    if doInstances then table.insert(summary, "Instances: " .. instanceCount) end
    if doRemotes   then table.insert(summary, "Remotes: "   .. remoteCount)   end
    if doGameInfo  then table.insert(summary, "GameInfo: saved")               end

    Notify(
        prefix .. "Dump Complete",
        table.concat(summary, " | ") .. "\n" .. folder,
        8
    )

    if setclipboard then setclipboard(folder) end
    print("[Dumper] Output: " .. folder)
end

-- ============================================
-- Mercury GUI
-- ============================================
GUI = Mercury:Create{
    Name = "Game Dumper v7.5",
    Size = UDim2.fromOffset(520, 420),
    Theme = Mercury.Themes.Dark,
    Link  = "https://github.com/deeeity/mercury-lib"
}

local MainTab = GUI:Tab{ Name = "Dump", Icon = "rbxassetid://8569322835" }

MainTab:Button{
    Name        = "Full Dump",
    Description = "Scan Instances + Remotes + Game Info in one pass",
    Callback    = function()
        task.spawn(RunDump, true, true, true, "[Full] ")
    end
}

MainTab:Button{
    Name        = "Dump Instances",
    Description = "Scan and save all whitelisted instances",
    Callback    = function()
        task.spawn(RunDump, true, false, false, "[Instances] ")
    end
}

MainTab:Button{
    Name        = "Dump Remotes",
    Description = "Scan and save RemoteEvent / RemoteFunction / Bindable",
    Callback    = function()
        task.spawn(RunDump, false, true, false, "[Remotes] ")
    end
}

MainTab:Button{
    Name        = "Dump Game Info",
    Description = "Save DataModel + Workspace properties",
    Callback    = function()
        task.spawn(RunDump, false, false, true, "[GameInfo] ")
    end
}

MainTab:Button{
    Name        = "Clear All Dumps",
    Description = "Delete the entire Dump Filter folder",
    Callback    = function()
        if delfolder then
            pcall(delfolder, BaseFolder)
            Notify("Clear Complete", "Dump folder deleted", 3)
        else
            Notify("Not Supported", "delfolder unavailable — delete manually", 3)
        end
    end
}

-- ============================================
-- Spy Tab
-- ============================================
local SpyTab = GUI:Tab{ Name = "Remote Spy", Icon = "rbxassetid://8569322835" }

SpyTab:Toggle{
    Name         = "Remote Spy",
    StartingState = false,
    Description  = "Hook FireServer / InvokeServer — auto-saves every 10s",
    Callback     = function(state)
        if state then
            StartRemoteSpy()
            Notify("[Spy] Active", "Hooking FireServer / InvokeServer — saves every 10s", 4)
        else
            StopRemoteSpy()
            Notify("[Spy] Stopped", "Final log flushed to SpyLogs/", 4)
        end
    end
}

GUI:Credit{
    Name        = "Game Dumper",
    Description = "v7.5 – Safe BuildPath | shared scan | unified notify",
    V3rm        = "N/A",
    Discord     = "N/A"
}

Notify("Game Dumper v7.5 Loaded", "Map: " .. MapName, 5)
print("=== Game Dumper v7.5 ===")
print("[Dumper] Map:  " .. MapName)
print("[Dumper] Base: " .. BaseFolder)
