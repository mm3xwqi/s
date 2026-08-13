local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Workspace = game:GetService("Workspace")
local Players   = game:GetService("Players")
local MPS       = game:GetService("MarketplaceService")

if not writefile then
    warn("[Dumper] writefile not available")
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

local function EnsureFolder(path)
    local built = ""
    for seg in path:gmatch("[^/]+") do
        built = built == "" and seg or (built .. "/" .. seg)
        local ok2 = pcall(makefolder, built)
        if not ok2 and not pcall(listfiles, built) then
            return false
        end
    end
    return true
end

local function SaveFile(path, content)
    if not content or content == "" then return false end
    local ok2 = pcall(writefile, path, content)
    if not ok2 then return false end
    print("[Dumper] Saved -> " .. path)
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

local ScriptClasses = {
    ModuleScript = true,
    LocalScript  = true,
    Script       = true,
}

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
    Attachment=true, Animation=true, Sound=true,
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

local Window = Rayfield:CreateWindow({
    Name = "Game Dumper v9.5",
    LoadingTitle = "Game Dumper",
    LoadingSubtitle = "by Dumper",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Dump", 4483362458)
local SpyTab  = Window:CreateTab("Remote Spy", 4483362458)

local function Notify(title, text, duration)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = duration or 4,
        Image = 4483362458,
    })
end

local function GetAll()
    local ok2, all = pcall(function() return Workspace:GetDescendants() end)
    if not ok2 or not all then
        warn("[Dumper] GetDescendants() failed")
        return nil
    end
    task.wait()
    return all
end

local function BuildGameInfo()
    local function safe(fn) local ok2, v = pcall(fn); return ok2 and tostring(v) or "N/A" end
    return {
        "-- GAME INFO",
        "-- Map Name: " .. MapName,
        "-- PlaceId: " .. safe(function() return game.PlaceId end),
        "-- GameId: " .. safe(function() return game.GameId end),
        "-- PlaceVersion: " .. safe(function() return game.PlaceVersion end),
        "-- JobId: " .. safe(function() return game.JobId end),
        "-- CreatorId: " .. safe(function() return game.CreatorId end),
        "-- CreatorType: " .. safe(function() return game.CreatorType end),
        "-- PrivateServerId: " .. safe(function() return game.PrivateServerId end),
        "",
        "-- WORKSPACE INFO",
        "-- Gravity: " .. safe(function() return Workspace.Gravity end),
        "-- StreamingEnabled: " .. safe(function() return Workspace.StreamingEnabled end),
        "-- FallenPartsDestroyHeight: " .. safe(function() return Workspace.FallenPartsDestroyHeight end),
    }
end

local function BuildInstances(all)
    local lines = {}
    local count = 0

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
        if i % 50 == 0 then task.wait() end

        local cls_ok, cls = pcall(function() return inst.ClassName end)
        if cls_ok and ImportantClasses[cls] and not IsPChar(inst) then
            local par_ok, par = pcall(function() return inst.Parent end)
            local skip = par_ok and par == game and (function()
                local nm_ok, nm = pcall(function() return inst.Name end)
                return nm_ok and SkipServices[nm]
            end)()

            if not skip then
                local nm_ok2, nm2 = pcall(function() return inst.Name end)
                local path = BuildPath(inst)

                table.insert(lines, string.format('%s -- [%s] "%s"', path, cls, nm_ok2 and nm2 or "?"))

                local attr_ok, attrs = pcall(function() return inst:GetAttributes() end)
                if attr_ok and attrs then
                    for k, v in pairs(attrs) do
                        table.insert(lines, string.format('  .Attr[%s] = %s', k, tostring(v)))
                    end
                end

                if cls == "Animation" then
                    local ok2, v = pcall(function() return inst.AnimationId end)
                    if ok2 then table.insert(lines, '  .AnimationId = "' .. v .. '"') end

                elseif cls == "Sound" then
                    local ok2, sid = pcall(function() return inst.SoundId end)
                    local ok3, vol = pcall(function() return inst.Volume end)
                    if ok2 then
                        table.insert(lines, string.format('  .SoundId = "%s" Volume=%s', sid, ok3 and tostring(vol) or "?"))
                    end

                elseif cls == "SpecialMesh" or cls == "MeshPart" then
                    local ok2, mid = pcall(function() return inst.MeshId end)
                    local ok3, tid = pcall(function() return inst.TextureId end)
                    table.insert(lines, string.format('  .MeshId="%s" .TextureId="%s"', ok2 and mid or "N/A", ok3 and tid or "N/A"))
                end

                table.insert(lines, "")
                count = count + 1
            end
        end
    end

    return lines, count
end

local function BuildRemotes(all)
    local lines = {}
    local count = 0

    for i, inst in ipairs(all) do
        if i % 50 == 0 then task.wait() end

        local cls_ok, cls = pcall(function() return inst.ClassName end)
        if cls_ok and RemoteClasses[cls] then
            table.insert(lines, string.format('%s -- [%s]', BuildPath(inst), cls))
            local attr_ok, attrs = pcall(function() return inst:GetAttributes() end)
            if attr_ok and attrs then
                for k, v in pairs(attrs) do
                    table.insert(lines, string.format('  .Attr[%s] = %s', k, tostring(v)))
                end
            end
            table.insert(lines, "")
            count = count + 1
        end
    end

    return lines, count
end

local function BuildModules(all)
    local lines = {}
    local count = 0

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
        if i % 50 == 0 then task.wait() end

        local cls_ok, cls = pcall(function() return inst.ClassName end)
        if cls_ok and ScriptClasses[cls] and not IsPChar(inst) then
            local par_ok, par = pcall(function() return inst.Parent end)
            local skip = par_ok and par == game and (function()
                local nm_ok, nm = pcall(function() return inst.Name end)
                return nm_ok and SkipServices[nm]
            end)()

            if not skip then
                local nm_ok2, nm2 = pcall(function() return inst.Name end)
                local path = BuildPath(inst)

                table.insert(lines, string.format('%s -- [%s] "%s"', path, cls, nm_ok2 and nm2 or "?"))
                table.insert(lines, '  Path: ' .. path)

                local src_ok, src = pcall(function()
                    if decompile then
                        local d_ok, d_res = pcall(decompile, inst)
                        if d_ok and d_res and #d_res > 0 then return d_res end
                    end
                    return inst.Source
                end)

                if src_ok and src and src ~= "" then
                    local preview = (#src > 1000) and (src:sub(1, 1000) .. "\n  ... [TRUNCATED " .. #src .. " chars]") or src
                    table.insert(lines, "  Source:")
                    for line in preview:gmatch("[^\n]+") do
                        table.insert(lines, "    " .. line)
                    end
                else
                    table.insert(lines, "  Source: [N/A or protected]")
                end

                local attr_ok, attrs = pcall(function() return inst:GetAttributes() end)
                if attr_ok and attrs then
                    for k, v in pairs(attrs) do
                        table.insert(lines, string.format('  .Attr[%s] = %s', k, tostring(v)))
                    end
                end

                table.insert(lines, "")
                count = count + 1
            end
        end
    end

    return lines, count
end

-- ============================================
-- Stealth Hardened Remote Spy (Bypass Anti-Cheat)
-- ============================================
local SpyActive = false
local SpyLines  = {}
local Hooked    = false

local function safeToString(v)
    local ok, res = pcall(function()
        if typeof(v) == "Instance" then
            local pOk, p = pcall(BuildPath, v)
            return pOk and p or tostring(v)
        elseif typeof(v) == "string" then
            return '"' .. tostring(v) .. '"'
        elseif typeof(v) == "table" then
            return "{...}"
        else
            return tostring(v)
        end
    end)
    return ok and res or "[Unprintable]"
end

local function argsToStr(args)
    local t = {}
    for i, v in ipairs(args) do
        t[i] = string.format("[%d]=%s (%s)", i, safeToString(v), typeof(v))
    end
    return table.concat(t, ", ")
end

local OldNamecall
if hookmetamethod and getnamecallmethod then
    local newcc = newcclosure or function(f) return f end
    
    OldNamecall = hookmetamethod(game, "__namecall", newcc(function(self, ...)
        -- 1. ถ้าปิด Spy อยู่ -> คืนค่าทันทีไม่แตะอะไรเลย
        if not SpyActive then
            return OldNamecall(self, ...)
        end

        -- 2. เช็ค method ว่าเป็น FireServer หรือ InvokeServer หรือไม่
        local method = getnamecallmethod()
        if method ~= "FireServer" and method ~= "InvokeServer" then
            return OldNamecall(self, ...)
        end

        -- 3. Anti-Trap: เช็คว่าเป็น Instance จริงๆ ไม่ใช่ Proxy Table หลอกของ Anti-Cheat
        local isRealInstance = pcall(function() return typeof(self) == "Instance" and self.ClassName end)
        if not isRealInstance then
            return OldNamecall(self, ...)
        end

        -- 4. เช็ค ClassName แบบปลอดภัย
        local clsOk, cls = pcall(function() return self.ClassName end)
        if not clsOk or not (cls == "RemoteEvent" or cls == "RemoteFunction") then
            return OldNamecall(self, ...)
        end

        -- 5. ประมวลผลดักจับแบบ Async (ไม่ทำให้เกมกระตุก ไม่โดน Latency Check)
        local args = {...}
        task.spawn(function()
            local pathOk, path = pcall(BuildPath, self)
            if pathOk and path then
                local strOk, argStr = pcall(argsToStr, args)
                if strOk then
                    table.insert(SpyLines, string.format("%s:%s(%s)", path, method, argStr))
                end
            end
        end)

        -- 6. Restore state และคืนค่าให้เกมทำงานตามปกติ 100%
        if setnamecallmethod then setnamecallmethod(method) end
        return OldNamecall(self, ...)
    end))
    Hooked = true
end

local function FlushSpy(tag)
    if #SpyLines == 0 then return end
    local sf = BaseFolder .. "/SpyLogs"
    EnsureFolder(sf)
    SaveFile(sf .. "/Spy_" .. tag .. "_" .. os.time() .. ".txt", table.concat(SpyLines, "\n"))
    SpyLines = {}
end

local function StartRemoteSpy()
    if SpyActive then return end

    if not Hooked then
        warn("[Dumper] hookmetamethod is not supported by your executor.")
        Notify("Spy Error", "Executor does not support hookmetamethod", 5)
        return
    end

    SpyActive = true
    SpyLines  = {}

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

local function RunDump(doInstances, doRemotes, doGameInfo, doModules, labelPrefix)
    local prefix = labelPrefix or ""

    if not EnsureFolder(BaseFolder) then
        Notify(prefix .. "Error", "Cannot create base folder", 5)
        return
    end

    local folder = BaseFolder .. "/" .. MapName
    EnsureFolder(folder)

    local all = GetAll()
    if not all then
        Notify(prefix .. "Error", "GetDescendants() failed", 5)
        return
    end

    local ts = os.time()
    local savedFiles = {}
    local summary = {}

    if doGameInfo then
        Notify(prefix .. "Game Info", "Collecting...", 2)
        local infoLines = BuildGameInfo()
        local header = {
            "-- Game Info: " .. MapName,
            "-- Date: " .. os.date("%Y-%m-%d %H:%M:%S"),
            "",
        }
        local content = table.concat(header, "\n") .. "\n" .. table.concat(infoLines, "\n")
        local path = folder .. "/GameInfo_" .. tostring(ts) .. ".txt"
        if SaveFile(path, content) then
            table.insert(savedFiles, "GameInfo")
            table.insert(summary, "GameInfo")
        end
    end

    if doInstances then
        Notify(prefix .. "Instances", "Scanning...", 2)
        local instLines, instCount = BuildInstances(all)
        local header = {
            "-- Instances Dump: " .. MapName,
            "-- Date: " .. os.date("%Y-%m-%d %H:%M:%S"),
            "-- Total: " .. instCount,
            "",
        }
        local content = table.concat(header, "\n") .. "\n" .. table.concat(instLines, "\n")
        local path = folder .. "/Instances_" .. tostring(ts) .. ".txt"
        if SaveFile(path, content) then
            table.insert(savedFiles, "Instances")
            table.insert(summary, "Instances: " .. instCount)
        end
    end

    if doRemotes then
        Notify(prefix .. "Remotes", "Scanning...", 2)
        local remLines, remCount = BuildRemotes(all)
        local header = {
            "-- Remotes Dump: " .. MapName,
            "-- Date: " .. os.date("%Y-%m-%d %H:%M:%S"),
            "-- Total: " .. remCount,
            "",
        }
        local content = table.concat(header, "\n") .. "\n" .. table.concat(remLines, "\n")
        local path = folder .. "/Remotes_" .. tostring(ts) .. ".txt"
        if SaveFile(path, content) then
            table.insert(savedFiles, "Remotes")
            table.insert(summary, "Remotes: " .. remCount)
        end
    end

    if doModules then
        Notify(prefix .. "Modules", "Scanning...", 2)
        local modLines, modCount = BuildModules(all)
        local header = {
            "-- Modules Dump: " .. MapName,
            "-- Date: " .. os.date("%Y-%m-%d %H:%M:%S"),
            "-- Total: " .. modCount,
            "",
        }
        local content = table.concat(header, "\n") .. "\n" .. table.concat(modLines, "\n")
        local path = folder .. "/Modules_" .. tostring(ts) .. ".txt"
        if SaveFile(path, content) then
            table.insert(savedFiles, "Modules")
            table.insert(summary, "Modules: " .. modCount)
        end
    end

    Notify(prefix .. "Done", table.concat(summary, " | "), 5)
    print("[Dumper] Saved to: " .. folder)
end

local selectedMode = "Full Dump (4 Files)"

MainTab:CreateDropdown({
    Name = "Dump Mode",
    Options = {
        "Full Dump (4 Files)",
        "Instances Only",
        "Remotes Only",
        "Modules Only",
        "Game Info Only"
    },
    CurrentOption = {"Full Dump (4 Files)"},
    MultipleOptions = false,
    Flag = "DumpModeSelect",
    Callback = function(option)
        if type(option) == "table" then
            selectedMode = option[1]
        else
            selectedMode = option
        end
    end,
})

MainTab:CreateButton({
    Name = "Start Dump",
    Callback = function()
        if selectedMode == "Full Dump (4 Files)" then
            task.spawn(RunDump, true, true, true, true, "[Full] ")
        elseif selectedMode == "Instances Only" then
            task.spawn(RunDump, true, false, false, false, "[Instances] ")
        elseif selectedMode == "Remotes Only" then
            task.spawn(RunDump, false, true, false, false, "[Remotes] ")
        elseif selectedMode == "Modules Only" then
            task.spawn(RunDump, false, false, false, true, "[Modules] ")
        elseif selectedMode == "Game Info Only" then
            task.spawn(RunDump, false, false, true, false, "[GameInfo] ")
        end
    end,
})

MainTab:CreateButton({
    Name = "Clear Dump Folder",
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
    Description = "Hook FireServer / InvokeServer (Bypass AC)",
    Callback = function(state)
        if state then
            StartRemoteSpy()
            Notify("[Spy] Active", "Hooking remotes safely", 4)
        else
            StopRemoteSpy()
            Notify("[Spy] Stopped", "Saved logs", 4)
        end
    end,
})
