-- ============================================
-- Roblox Game Dumper + Rayfield GUI v8.0
-- ============================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Workspace = game:GetService("Workspace")
local Players   = game:GetService("Players")
local MPS       = game:GetService("MarketplaceService")

if not writefile then
    warn("[Dumper] writefile not available.")
    return
end

local BaseFolder = "Dump Filter"

local MapName = "Map_" .. tostring(game.PlaceId)
local ok, info = pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
if ok and info and info.Name and info.Name ~= "" then
    local raw = tostring(info.Name):gsub("[\\/:%*%?\"<>|%c]", "_"):sub(1, 50)
    if raw ~= "" and not raw:match("^_+$") then MapName = raw end
end
print("[Dumper] Map: " .. MapName)

-- ============================================
-- Helpers
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
    if not content or content == "" then return false end
    local ok2, err = pcall(writefile, path, content)
    if not ok2 then
        warn("[Dumper] writefile failed: " .. path .. " | " .. tostring(err))
        return false
    end
    print("[Dumper] Saved " .. #content .. " bytes → " .. path)
    return true
end

local function BuildPath(instance)
    local chain, cur, limit = {}, instance, 32
    while cur and cur ~= game and limit > 0 do
        local p_ok, p = pcall(function() return cur.Parent end)
        if not p_ok or p == nil then break end
        table.insert(chain, 1, cur)
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
    Players=true, ScriptContext=true, Selection=true,
    Stats=true, TestService=true, TimerService=true,
}

local RemoteClasses = {
    RemoteEvent=true, RemoteFunction=true,
    BindableEvent=true, BindableFunction=true,
}

-- ============================================
-- Rayfield GUI
-- ============================================
local Window = Rayfield:CreateWindow({
    Name = "Game Dumper v8.0",
    LoadingTitle = "Game Dumper",
    LoadingSubtitle = "by Dumper",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local function Notify(title, text, duration)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = duration or 4,
        Image = 4483362458,
    })
end

-- ============================================
-- GetAll
-- ============================================
local function GetAll()
    local ok2, all = pcall(function() return Workspace:GetDescendants() end)
    if not ok2 or not all then
        warn("[Dumper] GetDescendants() failed!")
        return nil
    end
    task.wait()
    print("[Dumper] Total descendants: " .. #all)
    return all
end

-- ============================================
-- Dump Instances
-- ============================================
local function DumpInstances(all, folder)
    local chunk, count, chunkSize = {}, 0, 500
    local fileIndex = 1
    local total = #all

    local charSet = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then charSet[p.Character] = true end
    end

    local function IsPChar(inst)
        local cur = inst
        for _ = 1, 10 do
            local ok2, par = pcall(function() return cur.Parent end)
            if not ok2 or par == nil then break end
            if charSet[par] then return true end
            cur = par
        end
        return false
    end

    for i, inst in ipairs(all) do
        if i % 50 == 0 then
            task.wait()
            print(string.format("[Instances] %d%% (%d/%d) found:%d",
                math.floor((i/total)*100), i, total, count))
        end

        local cls_ok, cls = pcall(function() return inst.ClassName end)
        if cls_ok and ImportantClasses[cls] and not IsPChar(inst) then
            local par_ok, par = pcall(function() return inst.Parent end)
            local skip = par_ok and par == game and (function()
                local nm_ok, nm = pcall(function() return inst.Name end)
                return nm_ok and SkipServices[nm]
            end)()

            if not skip then
                local nm_ok2, nm2 = pcall(function() return inst.Name end)
                table.insert(chunk, string.format('%s  -- [%s] "%s"',
                    BuildPath(inst), cls, nm_ok2 and nm2 or "?"))

                local attr_ok, attrs = pcall(function() return inst:GetAttributes() end)
                if attr_ok and attrs then
                    for k, v in pairs(attrs) do
                        table.insert(chunk, string.format('--   .Attr[%s] = %s', k, tostring(v)))
                    end
                end

                if cls == "Animation" then
                    local ok2, v = pcall(function() return inst.AnimationId end)
                    if ok2 then table.insert(chunk, '--   .AnimationId = "' .. v .. '"') end
                elseif cls == "Sound" then
                    local ok2, sid = pcall(function() return inst.SoundId end)
                    local ok3, vol = pcall(function() return inst.Volume end)
                    if ok2 then
                        table.insert(chunk, string.format('--   .SoundId = "%s" Volume=%s',
                            sid, ok3 and tostring(vol) or "?"))
                    end
                elseif cls == "SpecialMesh" or cls == "MeshPart" then
                    local ok2, mid = pcall(function() return inst.MeshId end)
                    local ok3, tid = pcall(function() return inst.TextureId end)
                    table.insert(chunk, string.format('--   .MeshId="%s" .TextureId="%s"',
                        ok2 and mid or "N/A", ok3 and tid or "N/A"))
                end

                table.insert(chunk, "")
                count = count + 1

                if count % chunkSize == 0 then
                    local path = folder .. "/Instances_" .. fileIndex .. ".txt"
                    print("[Dumper] Writing " .. path)
                    SaveFile(path, table.concat(chunk, "\n"))
                    chunk = {}
                    fileIndex = fileIndex + 1
                    task.wait(0.5)
                end
            end
        end
    end

    if #chunk > 0 then
        local path = folder .. "/Instances_" .. fileIndex .. ".txt"
        SaveFile(path, table.concat(chunk, "\n"))
        task.wait(0.3)
    end

    print("[Dumper] Instances found: " .. count)
    return count
end

-- ============================================
-- Dump Remotes
-- ============================================
local function DumpRemotes(all, folder)
    local chunk, count, chunkSize = {}, 0, 300
    local fileIndex = 1
    local total = #all

    for i, inst in ipairs(all) do
        if i % 50 == 0 then
            task.wait()
            print(string.format("[Remotes] %d%% (%d/%d) found:%d",
                math.floor((i/total)*100), i, total, count))
        end

        local cls_ok, cls = pcall(function() return inst.ClassName end)
        if cls_ok and RemoteClasses[cls] then
            table.insert(chunk, string.format('%s  -- [%s]', BuildPath(inst), cls))
            local attr_ok, attrs = pcall(function() return inst:GetAttributes() end)
            if attr_ok and attrs then
                for k, v in pairs(attrs) do
                    table.insert(chunk, string.format('--   .Attr[%s] = %s', k, tostring(v)))
                end
            end
            table.insert(chunk, "")
            count = count + 1

            if count % chunkSize == 0 then
                local path = folder .. "/Remotes_" .. fileIndex .. ".txt"
                print("[Dumper] Writing " .. path)
                SaveFile(path, table.concat(chunk, "\n"))
                chunk = {}
                fileIndex = fileIndex + 1
                task.wait(0.3)
            end
        end
    end

    if #chunk > 0 then
        local path = folder .. "/Remotes_" .. fileIndex .. ".txt"
        SaveFile(path, table.concat(chunk, "\n"))
        task.wait(0.3)
    end

    print("[Dumper] Remotes found: " .. count)
    return count
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
-- Core Dump Runner
-- ============================================
local function RunDump(doInstances, doRemotes, doGameInfo, labelPrefix)
    local prefix = labelPrefix or ""

    if not EnsureFolder(BaseFolder) then
        Notify(prefix .. "Error", "Cannot create base folder", 5)
        return
    end

    local folder = BaseFolder .. "/" .. MapName .. "_" .. tostring(os.time())
    if not EnsureFolder(folder) then
        Notify(prefix .. "Error", "Cannot create subfolder", 5)
        return
    end

    local all = GetAll()
    if not all then
        Notify(prefix .. "Error", "GetDescendants() failed", 5)
        return
    end

    local instanceCount, remoteCount = 0, 0

    if doInstances then
        Notify(prefix .. "Instances", "Scanning...", 3)
        instanceCount = DumpInstances(all, folder)
        Notify(prefix .. "Instances Done", instanceCount .. " saved", 4)
    end

    if doRemotes then
        Notify(prefix .. "Remotes", "Scanning...", 3)
        remoteCount = DumpRemotes(all, folder)
        Notify(prefix .. "Remotes Done", remoteCount .. " saved", 4)
    end

    if doGameInfo then
        Notify(prefix .. "Game Info", "Saving...", 3)
        SaveFile(folder .. "/GameInfo.txt", DumpGameInfo())
        Notify(prefix .. "Game Info Done", "Saved", 4)
    end

    local summary = {}
    if doInstances then table.insert(summary, "Instances: " .. instanceCount) end
    if doRemotes   then table.insert(summary, "Remotes: " .. remoteCount) end
    if doGameInfo  then table.insert(summary, "GameInfo: saved") end

    Notify(prefix .. "Complete", table.concat(summary, " | "), 8)
    print("[Dumper] Output: " .. folder)
end

-- ============================================
-- Tabs
-- ============================================
local MainTab = Window:CreateTab("Dump", 4483362458)
local SpyTab  = Window:CreateTab("Remote Spy", 4483362458)

MainTab:CreateButton({
    Name = "Full Dump",
    Description = "Instances + Remotes + Game Info",
    Callback = function() task.spawn(RunDump, true, true, true, "[Full] ") end,
})

MainTab:CreateButton({
    Name = "Dump Instances",
    Description = "Scan all whitelisted instances",
    Callback = function() task.spawn(RunDump, true, false, false, "[Instances] ") end,
})

MainTab:CreateButton({
    Name = "Dump Remotes",
    Description = "RemoteEvent / RemoteFunction / Bindable",
    Callback = function() task.spawn(RunDump, false, true, false, "[Remotes] ") end,
})

MainTab:CreateButton({
    Name = "Dump Game Info",
    Description = "DataModel + Workspace properties",
    Callback = function() task.spawn(RunDump, false, false, true, "[GameInfo] ") end,
})

MainTab:CreateButton({
    Name = "Clear All Dumps",
    Description = "Delete the entire Dump Filter folder",
    Callback = function()
        if delfolder then
            pcall(delfolder, BaseFolder)
            Notify("Clear Complete", "Dump folder deleted", 3)
        else
            Notify("Not Supported", "delfolder unavailable", 3)
        end
    end,
})

SpyTab:CreateToggle({
    Name = "Remote Spy",
    CurrentValue = false,
    Description = "Hook FireServer / InvokeServer — saves every 10s",
    Callback = function(state)
        if state then
            StartRemoteSpy()
            Notify("[Spy] Active", "Hooking remotes — saves every 10s", 4)
        else
            StopRemoteSpy()
            Notify("[Spy] Stopped", "Final log flushed", 4)
        end
    end,
})

Notify("Game Dumper v8.0", "Map: " .. MapName, 5)
print("=== Game Dumper v8.0 ===")
print("[Dumper] Map:  " .. MapName)
print("[Dumper] Base: " .. BaseFolder)
