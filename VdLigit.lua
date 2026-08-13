if _G.vdHub and _G.vdHub.stop then
    pcall(_G.vdHub.stop)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer
if not lp then
    repeat task.wait(0.5) until Players.LocalPlayer
    lp = Players.LocalPlayer
end

local state = {
    running = true,
    cfg = {
        p_enabled         = false,
        interactionRadius = 8,
        stunReach         = 7,
        cooldown          = 0.15,
        hz                = 240,
        p_dropKey         = 32,
        antiBait          = true,
        sc_enabled        = false,
        sc_lead           = 2,
        sc_offset         = 102,
        sc_key            = 32,
        fv_enabled        = false,
        fv_radius         = 8,
        fv_minSpeed       = 14.0,
        fv_deadband       = 35,
        fv_ignoreAxis     = false,
        ap_enabled        = false,
        ap_cooldown       = 0.05,
        ap_showCircle     = true,
        ap_circleColor    = Color3.fromRGB(0, 255, 200),
        ap_animRadius     = 14,
        ap_animPreDelay   = 0,
        ap_pendingRadius  = 22,
        ap_hitboxRadius   = 16,
        ap_hitboxPreDelay = 0.0,
        esp_enabled  = false,
        esp_showName = true,
        esp_showDist = true,
        esp_showBox  = true,
        esp_maxDist  = 500,
        -- Player ESP
        p_esp_enabled  = false,
        p_esp_showDist = true,
        p_esp_maxDist  = 500,
    }
}
_G.vdHub = state

-- ============================================================
-- ANIMATION ID WHITELIST
-- ============================================================
local HIT_ANIM_IDS = {
    [113255068724446] = true,
    [110355011987939] = true,
    [117042998468241] = true,
    [133963973694098] = true,
    [132817836308238] = true,
    [82666958311998]  = true,
    [78432063483146]  = true,
    [78935059863801]  = true,
    [92098503722633]  = true,
    [105374834496520] = true,
    [111920872708571] = true,
    [117070354890871] = false,
    [106871536134254] = true,
    [109402730355822] = true,
    [115244153053858] = true,
    [130593238885843] = true,
    [138720291317243] = true,
    [135002183282873] = true,
    [122812055447896] = true,
    [78935059863801] = true,
}

local SKILL_ANIM_IDS = {
    [109928123357793] = true,
    [98163597193511]  = true,
    [125224839697689] = true,
    [117886494230451] = true,
    [80411309607666]  = true,
    [138045669415653] = true,
    [93136435416899]  = true,
    [139928639611415] = true,
    [84093948968516]  = true,
    [137688077908355] = true,
    [86266790353635]  = true,
    [92125118598365]  = true,
    [78165980406995]  = true,
    [135403091566760] = true,
    [121108316060822] = true,
    [99210996402874]  = true,
    [137846825408335] = true,
    [75258958842388] = true,
    [96744338559260] = true,
    [96839438835309] = true,
    
}

local function getAnimAssetId(track)
    local ok, animId = pcall(function()
        return track.Animation and track.Animation.AnimationId or ""
    end)
    if not ok then return nil end
    local id = tonumber(animId:match("(%d+)$"))
    return id
end

-- ============================================================

local function pressKey(keyCodeEnum, keyCodeNum)
    task.spawn(function()
        if typeof(keypress) == "function" and typeof(keyrelease) == "function" then
            pcall(function() keypress(keyCodeNum or 32); task.wait(0.01); keyrelease(keyCodeNum or 32) end)
        else
            pcall(function()
                VirtualInputManager:SendKeyEvent(true,  keyCodeEnum or Enum.KeyCode.Space, false, game)
                task.wait(0.01)
                VirtualInputManager:SendKeyEvent(false, keyCodeEnum or Enum.KeyCode.Space, false, game)
            end)
        end
    end)
end

local function doRightClick()
    pcall(function()
        if typeof(mouse2click) == "function" then mouse2click(); return end
        if typeof(mouse2press) == "function" and typeof(mouse2release) == "function" then
            mouse2press(); task.wait(0.01); mouse2release(); return
        end
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true,  game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
end

local pallets, vaults = {}, {}
local killerRoots = {}
local lastDrop, droppedPallets = {}, {}
local uiLabels = { status = nil, killerDist = nil }
local pStat = { elig=false, inZone=false, hp=true, nearD=nil, killD=nil, baiting=false }
local fvStat = { near=false, holding=false, nearD=nil, vaults=0, ang=nil, spd=0 }
local scLast = { l=nil, g=nil, win=nil }
local scHits, scFired = 0, false

local function myRoot()
    local ch = lp.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function healthOk()
    local ch = lp.Character
    local hum = ch and ch:FindFirstChild("Humanoid")
    if not hum then return true end
    local h = hum.Health
    return (type(h) ~= "number") or (h > 50)
end

local function busy()
    local ch = lp.Character
    local sc = ch and ch:FindFirstChild("CheckInterractable")
    if not sc then return false end
    local ok, v = pcall(function() return sc:GetAttribute("isDroppingPallet") end)
    return ok and (v == true)
end

local function isPalletDropped(pal)
    if not pal or not pal.board or not pal.board.Parent then return true end
    if droppedPallets[pal.id] then return true end
    local b = pal.board
    local p = b.Parent
    if b:GetAttribute("isDropped") or b:GetAttribute("Dropped") or b:GetAttribute("isDown") then
        droppedPallets[pal.id] = true; return true
    end
    if p and (p:GetAttribute("isDropped") or p:GetAttribute("Dropped") or p:GetAttribute("isDown")) then
        droppedPallets[pal.id] = true; return true
    end
    return false
end

local lastTeamName = ""
task.spawn(function()
    while state.running do
        task.wait(1.0)
        pcall(function()
            local team = lp.Team
            local teamName = team and string.lower(tostring(team.Name or "")) or ""
            if teamName:find("spectator") or teamName:find("spec") or teamName:find("lobby") then
                if next(droppedPallets) ~= nil then droppedPallets = {} end
            end
            if lastTeamName ~= teamName then droppedPallets = {}; lastTeamName = teamName end
        end)
    end
end)

local function refreshPallets()
    local out, byParent, vaultPts = {}, {}, {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        local ok, nm = pcall(function() return string.lower(d.Name) end)
        if not ok then continue end
        if (nm:find("pallet") or nm:find("board")) and d:IsA("BasePart") then
            local par = d.Parent
            if par then
                local e = byParent[par]
                if not e then
                    local board = par:FindFirstChild("PrimaryPartPallet")
                             or par:FindFirstChild("Board")
                             or d
                    local boardId
                    pcall(function() boardId = board:GetDebugId(0) end)
                    if not boardId then boardId = tostring(board) end
                    e = { board = board, pts = {}, id = boardId }
                    byParent[par] = e
                    out[#out + 1] = e
                end
                local p = d.Position
                if p then e.pts[#e.pts + 1] = { p.X, p.Y, p.Z } end
            end
        end
        if nm:find("vaulttrigger") and d:IsA("BasePart") then
            local cf = d.CFrame
            if cf then
                local lv = cf.LookVector
                local mag = math.sqrt(lv.X*lv.X + lv.Z*lv.Z)
                if mag > 0.0001 then
                    vaultPts[#vaultPts + 1] = {
                        cf.Position.X, cf.Position.Y, cf.Position.Z,
                        lv.X / mag, lv.Z / mag
                    }
                end
            end
        end
    end
    pallets, vaults = out, vaultPts
end

local killerTeamKeywords = {
    "killer","jason","hunter","slasher","beast",
    "monster","murder","threat","chaser","entity",
}

local function isKillerPlayer(plr)
    if plr == lp then return false end
    local tn = plr.Team and string.lower(tostring(plr.Team.Name or "")) or ""
    for _, kw in ipairs(killerTeamKeywords) do
        if tn:find(kw) then return true end
    end
    if lp.Team and plr.Team and plr.Team ~= lp.Team then
        return true
    end
    return false
end

local function refreshKiller()
    local killers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and isKillerPlayer(plr) then
            local ch = plr.Character
            local root = ch and ch:FindFirstChild("HumanoidRootPart")
            if root then killers[#killers + 1] = root end
        end
    end
    killerRoots = killers
    local me = myRoot()
    local mp = me and me.Position
    if not mp then pStat.killD = nil; return end
    local best
    for i = 1, #killerRoots do
        local kp = killerRoots[i].Position
        if kp then
            local dx,dy,dz = mp.X-kp.X, mp.Y-kp.Y, mp.Z-kp.Z
            local d2 = dx*dx+dy*dy+dz*dz
            if not best or d2 < best then best = d2 end
        end
    end
    pStat.killD = best and math.sqrt(best) or nil
end

pcall(refreshPallets); pcall(refreshKiller)
task.spawn(function() while state.running do pcall(refreshPallets); task.wait(1.5) end end)
task.spawn(function() while state.running do pcall(refreshKiller); task.wait(0.3) end end)

-- ============================================================
-- FIX: antiBait — ถ้า killer ยืนนิ่ง (speed < 1) → drop เลย
-- ============================================================
local function checkKillerApproach(kRoot, palPos, maxReach)
    local kPos = kRoot.Position
    local dx,dy,dz = palPos.X-kPos.X, palPos.Y-kPos.Y, palPos.Z-kPos.Z
    local dist = math.sqrt(dx*dx+dy*dy+dz*dz)
    if dist > maxReach then return false, false end
    if state.cfg.antiBait then
        local dirX = dx / (dist > 0.001 and dist or 1)
        local dirZ = dz / (dist > 0.001 and dist or 1)
        local kVel = kRoot.AssemblyLinearVelocity or kRoot.Velocity
        local speed = math.sqrt(kVel.X*kVel.X + kVel.Z*kVel.Z)
        -- killer ยืนนิ่ง → drop ทันที ไม่ถือว่า bait
        if speed < 1 then return true, true end
        if (kVel.X*dirX + kVel.Z*dirZ) < -2.5 then return true, false end
    end
    return true, true
end

-- ============================================================
-- PALLET LOOP
-- ============================================================
task.spawn(function()
    while state.running do
        local c = state.cfg
        local elig, zone, isBaiting = false, false, false
        local nearD = nil
        if c.p_enabled then
            local root = myRoot()
            local hpOk = healthOk()
            pStat.hp = hpOk
            if root and hpOk then
                local myp = root.Position
                local mx,my,mz = myp.X, myp.Y, myp.Z
                local now = tick()
                local ir2 = c.interactionRadius * c.interactionRadius
                for i = 1, #pallets do
                    local pal = pallets[i]
                    if not isPalletDropped(pal) and pal.board and pal.board.Parent then
                        local palPos = pal.board.Position
                        local dx,dy,dz = mx-palPos.X, my-palPos.Y, mz-palPos.Z
                        local d2 = dx*dx+dy*dy+dz*dz
                        if not nearD or d2 < nearD then nearD = d2 end
                        if d2 <= ir2 then
                            elig = true
                            for j = 1, #killerRoots do
                                local kRoot = killerRoots[j]
                                local inRange, valid = checkKillerApproach(kRoot, palPos, c.stunReach)
                                if inRange then
                                    zone = true
                                    if not valid then
                                        isBaiting = true
                                    elseif (now - (lastDrop[pal.id] or 0)) >= c.cooldown and not busy() then
                                        pressKey(Enum.KeyCode.Space, c.p_dropKey)
                                        lastDrop[pal.id] = tick()
                                        droppedPallets[pal.id] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        pStat.elig = elig; pStat.inZone = zone; pStat.baiting = isBaiting
        local nd = nearD and math.sqrt(nearD) or nil
        pStat.nearD = (nd and nd <= 200) and nd or nil
        task.wait(1 / (c.hz or 240))
    end
end)

-- ============================================================
-- SKILLCHECK
-- ============================================================
local function readSkillRots(Line, Goal)
    local lr, gr
    pcall(function() lr = Line.Rotation; gr = Goal.Rotation end)
    if not lr or not gr then
        pcall(function()
            lr = Line:GetAttribute("Rotation") or Line:GetAttribute("Value")
            gr = Goal:GetAttribute("Rotation") or Goal:GetAttribute("Value")
        end)
    end
    if not lr or not gr then return nil, nil end
    lr = lr < 0 and (lr % 360) or lr
    gr = gr < 0 and (gr % 360) or gr
    return lr, gr
end

task.spawn(function()
    while state.running do
        local c = state.cfg
        if c.sc_enabled then
            local pg  = lp:FindFirstChild("PlayerGui")
            local scr = pg  and pg:FindFirstChild("SkillCheckPromptGui")
            local chk = scr and scr:FindFirstChild("Check")
            local Line = chk and chk:FindFirstChild("Line")
            local Goal = chk and chk:FindFirstChild("Goal")
            if Line and Goal then
                local lr, gr = readSkillRots(Line, Goal)
                if lr and gr then
                    local lo = gr + (c.sc_offset or 102) + (c.sc_lead or 2)
                    scLast.l = lr; scLast.g = gr
                    scLast.win = string.format("%.0f°..%.0f°", lo, lo+14)
                    local diff = (lr - lo) % 360
                    if diff > 180 then diff = diff - 360 end
                    if diff >= 0 and diff <= 14 and not scFired then
                        pressKey(Enum.KeyCode.Space, c.sc_key)
                        scFired = true; scHits = scHits + 1
                    elseif diff > 15 or diff < -10 then
                        scFired = false
                    end
                else
                    scLast.l, scLast.g, scLast.win = nil,nil,nil; scFired = false
                end
            else
                scFired = false
            end
        end
        task.wait(1/240)
    end
end)

-- ============================================================
-- FAST VAULT — FIX: force face direction ทันที ไม่รอ lerp
-- ============================================================
local function fvAngle(tfx,tfz,lx,lz)
    local d = math.clamp(tfx*lx + tfz*lz, -1, 1)
    local a = math.deg(math.acos(d))
    return a > 90 and (180-a) or a
end

local function fvNearest(mx,my,mz,lx,lz,r2)
    local best,bd
    for i = 1, #vaults do
        local v = vaults[i]
        local dx,dy,dz = mx-v[1], my-v[2], mz-v[3]
        local d2 = dx*dx+dy*dy+dz*dz
        if (not bd or d2 < bd) and d2 <= r2 then bd,best = d2,v end
    end
    if not best then return nil end
    return best, math.sqrt(bd), fvAngle(best[4],best[5],lx,lz)
end

-- หา HRP ของ character โดย pcall ป้องกัน race condition
local function getHRP()
    local ch = lp.Character
    if not ch then return nil end
    local ok, hrp = pcall(function() return ch:WaitForChild("HumanoidRootPart", 0) end)
    if ok and hrp then return hrp end
    return ch:FindFirstChild("HumanoidRootPart")
end

task.spawn(function()
    local lastVaultTarget = nil   -- vault trigger ที่กำลัง lock อยู่
    local lockFrames = 0          -- จำนวน frame ที่ยัง lock ทิศ

    while state.running do
        local c = state.cfg
        if c.fv_enabled then
            local root = getHRP()
            if root and #vaults > 0 then
                local cf = root.CFrame
                local p  = cf and cf.Position
                if p then
                    -- ดึง look vector จาก camera ก่อน ถ้าได้
                    local lx, lz
                    pcall(function()
                        local cam = workspace.CurrentCamera
                        if cam then
                            local clv = cam.CFrame.LookVector
                            lx, lz = clv.X, clv.Z
                        end
                    end)
                    if not lx then
                        local lv = cf.LookVector
                        lx, lz = lv.X, lv.Z
                    end

                    -- normalize
                    local lm = math.sqrt(lx*lx + lz*lz)
                    if lm > 0.0001 then lx,lz = lx/lm, lz/lm end

                    local trig, dist, ang = fvNearest(p.X, p.Y, p.Z, lx, lz, c.fv_radius * c.fv_radius)
                    fvStat.near = trig ~= nil
                    fvStat.nearD = dist
                    fvStat.ang = ang

                    local spd = 0
                    pcall(function()
                        local v = root.AssemblyLinearVelocity or root.Velocity
                        spd = math.sqrt(v.X*v.X + v.Z*v.Z)
                    end)
                    fvStat.spd = spd

                    local angOK = c.fv_ignoreAxis or (ang and ang > c.fv_deadband)

                    if trig and spd > c.fv_minSpeed and angOK then
                        -- FIX: เปลี่ยน target → reset lock counter
                        if lastVaultTarget ~= trig then
                            lastVaultTarget = trig
                            lockFrames = 12  -- lock 12 frame (~50ms ที่ 240hz)
                        end

                        -- force face ทิศ vault trigger ทันทีทุก frame ที่ lock อยู่
                        if lockFrames > 0 then
                            lockFrames = lockFrames - 1
                            local pos = root.Position
                            local targetDir = Vector3.new(trig[4], 0, trig[5])
                            -- ใช้ pcall ป้องกัน network ownership error
                            local ok2, err = pcall(function()
                                root.CFrame = CFrame.new(pos, pos + targetDir)
                            end)
                            if not ok2 then
                                -- fallback: ใช้BodyGyro ถ้า CFrame ตรง set ไม่ได้
                                local bg = root:FindFirstChildOfClass("BodyGyro")
                                if not bg then
                                    bg = Instance.new("BodyGyro")
                                    bg.MaxTorque = Vector3.new(0, 4e5, 0)
                                    bg.P = 1e6
                                    bg.D = 0
                                    bg.Name = "VDHub_FV_Gyro"
                                    bg.Parent = root
                                end
                                bg.CFrame = CFrame.new(pos, pos + targetDir)
                            else
                                -- ลบ gyro ถ้า CFrame ตรงได้แล้ว
                                local bg = root:FindFirstChild("VDHub_FV_Gyro")
                                if bg then bg:Destroy() end
                            end
                        end
                        fvStat.holding = true
                        fvStat.vaults  = fvStat.vaults + 1
                    else
                        -- ออกจาก vault zone → clear lock
                        if not trig then
                            lastVaultTarget = nil
                            lockFrames = 0
                            -- ลบ gyro ถ้ายังค้างอยู่
                            if root then
                                local bg = root:FindFirstChild("VDHub_FV_Gyro")
                                if bg then bg:Destroy() end
                            end
                        end
                        fvStat.holding = false
                    end
                end
            else
                fvStat.near, fvStat.holding, fvStat.nearD, fvStat.ang = false, false, nil, nil
            end
        else
            -- fv disabled → ลบ gyro ทิ้ง
            fvStat.near, fvStat.holding = false, false
            local root2 = getHRP()
            if root2 then
                local bg = root2:FindFirstChild("VDHub_FV_Gyro")
                if bg then bg:Destroy() end
            end
        end
        task.wait(1/240)
    end
end)

-- ============================================================
-- AUTO PARRY
-- ============================================================
local ignoredKW = {
    "break","pallet","kick","destroy","gen","generator","vault","window",
    "pickup","carry","hook","drop","search","stun","blind","cabinet",
    "locker","open","close","repair","interact","idle","walk","run","stomp",
    "emote","taunt","dance","laugh","point","wave",
}
local attackKW = {
    "attack","swing","slash","strike","hit","m1","lunge",
    "weapon","swipe","cleave","chop","stab","bash","smash",
}

local function isIgnoredAnim(n)
    n = string.lower(n or "")
    for _,kw in ipairs(ignoredKW) do if n:find(kw) then return true end end
    return false
end

local function isAttackAnim(n)
    n = string.lower(n or "")
    if isIgnoredAnim(n) then return false end
    for _,kw in ipairs(attackKW) do if n:find(kw) then return true end end
    return false
end

local function getSwingScore(track)
    if not track then return 0, false end
    local animId = getAnimAssetId(track)
    if animId and SKILL_ANIM_IDS[animId] then return -999, true end
    if animId and HIT_ANIM_IDS[animId]   then return 100,  false end
    local nm = string.lower(track.Name or "")
    if isIgnoredAnim(nm) then return 0, false end
    local score = 0
    if isAttackAnim(nm) then score = score + 50 end
    local pri = track.Priority
    local isAction = pri == Enum.AnimationPriority.Action
                  or pri == Enum.AnimationPriority.Action1
                  or pri == Enum.AnimationPriority.Action2
                  or pri == Enum.AnimationPriority.Action3
                  or pri == Enum.AnimationPriority.Action4
    if isAction then score = score + 20 end
    local len = track.Length or 0
    if len > 0.25 and len < 2.0 then score = score + 20
    elseif len == 0 then score = score + 5 end
    if nm:match("^%d+$") and isAction then score = score + 15 end
    return score, false
end

local lastParryTime = 0
local PARRY_COOLDOWN = 0.2

local function parry(reason, extraDelay)
    if not state.cfg.ap_enabled then return end
    local now = tick()
    if (now - lastParryTime) < PARRY_COOLDOWN then return end
    lastParryTime = now
    task.spawn(function()
        if (extraDelay or 0) > 0 then task.wait(extraDelay) end
        doRightClick()
    end)
    if uiLabels.killerDist then
        pcall(function()
            uiLabels.killerDist:SetText("PARRY: "..(reason or "?").." @ "..os.date("%H:%M:%S"))
        end)
    end
end

local pendingSwings = {}

local function pushPending(kRoot, trackName, score, animLen)
    for _, sw in ipairs(pendingSwings) do
        if sw.killerRoot == kRoot and not sw.fired then
            sw.deadline = math.max(sw.deadline, tick() + animLen)
            return
        end
    end
    pendingSwings[#pendingSwings + 1] = {
        killerRoot = kRoot,
        trackName  = trackName,
        score      = score,
        deadline   = tick() + animLen,
        fired      = false,
    }
end

local monitoredKillers = {}
local killerAnimConns  = {}

local function onKillerAnimPlayed(track, kRoot)
    if not state.cfg.ap_enabled then return end
    local score, isSkill = getSwingScore(track)
    if isSkill or score < 20 then return end
    local me = myRoot()
    if not me then return end
    if not (kRoot and kRoot.Parent) then return end
    local dist = (me.Position - kRoot.Position).Magnitude
    local animR = state.cfg.ap_animRadius or 12
    if dist <= animR then
        local preDelay = state.cfg.ap_animPreDelay or 0
        parry("Anim:"..track.Name..string.format("(%.1f)",dist),
              preDelay * math.clamp(dist/animR, 0.2, 1.0))
    else
        local pendR = state.cfg.ap_pendingRadius or 22
        if dist <= pendR then
            local animLen = math.min((track.Length and track.Length > 0) and track.Length or 2.0, 2.5)
            pushPending(kRoot, track.Name, score, animLen)
        end
    end
end

local function findAnimator(char)
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local a = hum:FindFirstChildOfClass("Animator")
        if a then return a end
    end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("Animator") then return v end
    end
end

local function attachAnimListener(kRoot)
    local char = kRoot and kRoot.Parent
    if not char or monitoredKillers[char] then return end
    monitoredKillers[char] = true
    killerAnimConns[char] = {}
    local attached = false
    local function doAttach()
        if attached then return end
        local anim = findAnimator(char)
        if not anim then return end
        attached = true
        local conn = anim.AnimationPlayed:Connect(function(track)
            onKillerAnimPlayed(track, kRoot)
        end)
        killerAnimConns[char][#killerAnimConns[char]+1] = conn
    end
    doAttach()
    if not attached then
        local c2 = char.DescendantAdded:Connect(function(obj)
            if obj:IsA("Animator") then task.wait(0.05); doAttach() end
        end)
        killerAnimConns[char][#killerAnimConns[char]+1] = c2
    end
    char.AncestryChanged:Connect(function()
        if char.Parent then return end
        for _,c in ipairs(killerAnimConns[char] or {}) do pcall(c.Disconnect,c) end
        killerAnimConns[char] = nil
        monitoredKillers[char] = nil
    end)
end

local hitboxKW = {
    "wallhitboxcollider","hitboxcollider","attackhitbox",
    "weaponhitbox","swinghitbox","strikebox","meleerange",
}

local function isHitboxName(name)
    local n = string.lower(name or "")
    for _,kw in ipairs(hitboxKW) do if n:find(kw,1,true) then return true end end
    return false
end

local function attachHitboxListener(char)
    char.DescendantAdded:Connect(function(obj)
        if not state.cfg.ap_enabled then return end
        if not obj:IsA("BasePart") or not isHitboxName(obj.Name) then return end
        local me = myRoot(); if not me then return end
        local ok,dist = pcall(function() return (me.Position-obj.Position).Magnitude end)
        if ok and dist <= (state.cfg.ap_hitboxRadius or 16) then
            parry("HitboxSpawn:"..obj.Name, state.cfg.ap_hitboxPreDelay or 0)
        end
        pcall(function()
            obj:GetPropertyChangedSignal("Size"):Connect(function()
                if not state.cfg.ap_enabled then return end
                local me2 = myRoot(); if not me2 then return end
                local ok2,d2 = pcall(function() return (me2.Position-obj.Position).Magnitude end)
                if ok2 and d2 <= (state.cfg.ap_hitboxRadius or 16) then
                    parry("HitboxSize:"..obj.Name, 0)
                end
            end)
        end)
    end)
    pcall(function()
        for _,obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") and isHitboxName(obj.Name) then
                obj:GetPropertyChangedSignal("Size"):Connect(function()
                    if not state.cfg.ap_enabled then return end
                    local me = myRoot(); if not me then return end
                    local ok,d = pcall(function() return (me.Position-obj.Position).Magnitude end)
                    if ok and d <= (state.cfg.ap_hitboxRadius or 16) then
                        parry("HitboxSize:"..obj.Name, 0)
                    end
                end)
            end
        end
    end)
end

Workspace.DescendantAdded:Connect(function(obj)
    if not state.cfg.ap_enabled then return end
    if not obj:IsA("BasePart") or not isHitboxName(obj.Name) then return end
    local me = myRoot(); if not me then return end
    local ok,dist = pcall(function() return (me.Position-obj.Position).Magnitude end)
    if ok and dist <= ((state.cfg.ap_hitboxRadius or 16) + 5) then
        parry("WSHitbox:"..obj.Name, 0)
    end
end)

local hitboxMonitored = {}

task.spawn(function()
    while state.running do
        if state.cfg.ap_enabled then
            local me       = myRoot()
            local now      = tick()
            local animR    = state.cfg.ap_animRadius or 12
            local preDelay = state.cfg.ap_animPreDelay or 0
            local closestDist = nil
            local remaining = {}
            for _, sw in ipairs(pendingSwings) do
                if sw.fired or now > sw.deadline then
                elseif not (sw.killerRoot and sw.killerRoot.Parent) then
                elseif not me then
                    remaining[#remaining+1] = sw
                else
                    local ok,dist = pcall(function()
                        return (me.Position - sw.killerRoot.Position).Magnitude
                    end)
                    if ok then
                        if dist <= animR then
                            sw.fired = true
                            parry("PendingAnim:"..sw.trackName..string.format("(%.1f)",dist),
                                  preDelay * math.clamp(dist/animR, 0.2, 1.0))
                        else
                            remaining[#remaining+1] = sw
                        end
                    else
                        remaining[#remaining+1] = sw
                    end
                end
            end
            pendingSwings = remaining
            for _, kRoot in ipairs(killerRoots) do
                attachAnimListener(kRoot)
                local char = kRoot.Parent
                if char and not hitboxMonitored[char] then
                    hitboxMonitored[char] = true
                    attachHitboxListener(char)
                end
                if me then
                    local ok,d = pcall(function() return (me.Position-kRoot.Position).Magnitude end)
                    if ok and (not closestDist or d < closestDist) then closestDist = d end
                end
            end
            if uiLabels.killerDist and closestDist then
                pcall(function()
                    if (tick() - lastParryTime) > 1.0 then
                        uiLabels.killerDist:SetText(string.format("Killer: %.1f studs", closestDist))
                    end
                end)
            end
        end
        task.wait(0.02)
    end
end)

-- ============================================================
-- KILLER ESP
-- ============================================================
local espObjects     = {}
local espTrackedChars = {}

local function removeESP(char)
    if espObjects[char] then
        for _, obj in pairs(espObjects[char]) do pcall(function() obj:Destroy() end) end
        espObjects[char] = nil
    end
end

local function createESP(char, kRoot)
    removeESP(char)
    local store = {}
    espObjects[char] = store

    local highlight = Instance.new("Highlight")
    highlight.Name                = "VDHub_ESP_Highlight"
    highlight.FillColor           = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor        = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency    = 0.6
    highlight.OutlineTransparency = 0
    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee             = char
    highlight.Parent              = char
    store.highlight               = highlight

    local billGui = Instance.new("BillboardGui")
    billGui.Name        = "VDHub_ESP_Bill"
    billGui.AlwaysOnTop = true
    billGui.Size        = UDim2.new(0, 120, 0, 44)
    billGui.StudsOffset = Vector3.new(0, 3.5, 0)
    billGui.Adornee     = kRoot
    billGui.Parent      = game:GetService("CoreGui")

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size                   = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position               = UDim2.new(0, 0, 0, 0)
    nameLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font                   = Enum.Font.GothamBold
    nameLabel.TextSize               = 13
    nameLabel.Text                   = char.Name
    nameLabel.Parent                 = billGui

    local distLabel = Instance.new("TextLabel")
    distLabel.BackgroundTransparency = 1
    distLabel.Size                   = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position               = UDim2.new(0, 0, 0.5, 0)
    distLabel.TextColor3             = Color3.fromRGB(255, 200, 0)
    distLabel.TextStrokeTransparency = 0
    distLabel.Font                   = Enum.Font.Gotham
    distLabel.TextSize               = 11
    distLabel.Text                   = ""
    distLabel.Parent                 = billGui

    store.billGui   = billGui
    store.nameLabel = nameLabel
    store.distLabel = distLabel
end

task.spawn(function()
    while state.running do
        local c = state.cfg
        if c.esp_enabled then
            local me = myRoot()
            for _, kRoot in ipairs(killerRoots) do
                local char = kRoot and kRoot.Parent
                if char then
                    if not espTrackedChars[char] then
                        espTrackedChars[char] = true
                        createESP(char, kRoot)
                        char.AncestryChanged:Connect(function()
                            if not char.Parent then
                                removeESP(char)
                                espTrackedChars[char] = nil
                            end
                        end)
                    end
                    local store = espObjects[char]
                    if store then
                        local dist = nil
                        if me then pcall(function() dist = (me.Position - kRoot.Position).Magnitude end) end
                        local inRange = (not dist) or (dist <= c.esp_maxDist)
                        if store.highlight then store.highlight.Enabled = c.esp_showBox and inRange end
                        if store.billGui   then store.billGui.Enabled   = inRange end
                        if store.nameLabel then store.nameLabel.Visible = c.esp_showName end
                        if store.distLabel then
                            store.distLabel.Visible = c.esp_showDist
                            if dist then store.distLabel.Text = string.format("[%.0f studs]", dist) end
                        end
                    end
                end
            end
            for char in pairs(espTrackedChars) do
                local stillKiller = false
                for _, kRoot in ipairs(killerRoots) do
                    if kRoot.Parent == char then stillKiller = true; break end
                end
                if not stillKiller then removeESP(char); espTrackedChars[char] = nil end
            end
        else
            for char in pairs(espTrackedChars) do removeESP(char); espTrackedChars[char] = nil end
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- PLAYER ESP (สีฟ้า — ระยะใต้เท้า)
-- ============================================================
local playerEspObjects = {}
local playerEspTracked = {}

local function removePlayerESP(char)
    if playerEspObjects[char] then
        for _, obj in pairs(playerEspObjects[char]) do pcall(function() obj:Destroy() end) end
        playerEspObjects[char] = nil
    end
end

local function createPlayerESP(char, root)
    removePlayerESP(char)
    local store = {}
    playerEspObjects[char] = store

    local highlight = Instance.new("Highlight")
    highlight.Name                = "VDHub_PlayerESP_Highlight"
    highlight.FillColor           = Color3.fromRGB(0, 150, 255)
    highlight.OutlineColor        = Color3.fromRGB(0, 200, 255)
    highlight.FillTransparency    = 0.6
    highlight.OutlineTransparency = 0
    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee             = char
    highlight.Parent              = char
    store.highlight               = highlight

    -- BillboardGui ติดใต้เท้า
    local billGui = Instance.new("BillboardGui")
    billGui.Name        = "VDHub_PlayerESP_Bill"
    billGui.AlwaysOnTop = true
    billGui.Size        = UDim2.new(0, 100, 0, 20)
    billGui.StudsOffset = Vector3.new(0, -3.2, 0)
    billGui.Adornee     = root
    billGui.Parent      = game:GetService("CoreGui")

    local distLabel = Instance.new("TextLabel")
    distLabel.BackgroundTransparency = 1
    distLabel.Size                   = UDim2.new(1, 0, 1, 0)
    distLabel.TextColor3             = Color3.fromRGB(0, 200, 255)
    distLabel.TextStrokeTransparency = 0
    distLabel.Font                   = Enum.Font.GothamBold
    distLabel.TextSize               = 11
    distLabel.Text                   = ""
    distLabel.Parent                 = billGui

    store.billGui   = billGui
    store.distLabel = distLabel
end

task.spawn(function()
    while state.running do
        local c = state.cfg
        if c.p_esp_enabled then
            local me = myRoot()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and not isKillerPlayer(plr) then
                    local char = plr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if char and root then
                        if not playerEspTracked[char] then
                            playerEspTracked[char] = true
                            createPlayerESP(char, root)
                            char.AncestryChanged:Connect(function()
                                if not char.Parent then
                                    removePlayerESP(char)
                                    playerEspTracked[char] = nil
                                end
                            end)
                        end
                        local store = playerEspObjects[char]
                        if store then
                            local dist = nil
                            if me then pcall(function() dist = (me.Position - root.Position).Magnitude end) end
                            local inRange = (not dist) or (dist <= c.p_esp_maxDist)
                            if store.highlight then store.highlight.Enabled = inRange end
                            if store.billGui   then store.billGui.Enabled   = inRange and c.p_esp_showDist end
                            if store.distLabel and dist then
                                store.distLabel.Text = string.format("%.0f studs", dist)
                            end
                        end
                    end
                end
            end
            -- cleanup คนที่ออกไปแล้ว
            for char in pairs(playerEspTracked) do
                local alive = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character == char then alive = true; break end
                end
                if not alive then removePlayerESP(char); playerEspTracked[char] = nil end
            end
        else
            for char in pairs(playerEspTracked) do
                removePlayerESP(char); playerEspTracked[char] = nil
            end
        end
        task.wait(0.1)
    end
end)

-- ============================================================
-- PARRY RING
-- ============================================================
local parryAdornment = Instance.new("CylinderHandleAdornment")
parryAdornment.Name         = "VDHub_ParryHollowRing"
parryAdornment.Height       = 0.05
parryAdornment.Color3       = Color3.fromRGB(0, 255, 200)
parryAdornment.Transparency = 0.1
parryAdornment.AlwaysOnTop  = true
parryAdornment.Parent       = Workspace

RunService.RenderStepped:Connect(function()
    if state.running and state.cfg.ap_enabled and state.cfg.ap_showCircle then
        local me = myRoot()
        if me then
            local radius = math.max(1, state.cfg.ap_animRadius or 12)
            parryAdornment.Radius      = radius
            parryAdornment.InnerRadius = math.max(0.1, radius - 0.15)
            parryAdornment.Color3      = state.cfg.ap_circleColor or Color3.fromRGB(0,255,200)
            parryAdornment.Adornee     = me
            parryAdornment.CFrame      = CFrame.new(0,-2.8,0) * CFrame.Angles(math.rad(90),0,0)
            parryAdornment.Visible     = true
            parryAdornment.Parent      = Workspace
        else
            parryAdornment.Visible = false
        end
    else
        parryAdornment.Visible = false
    end
end)

-- ============================================================
-- UI
-- ============================================================
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
Library     = loadstring(game:HttpGet(repo.."Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo.."addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo.."addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title            = "Violence District Hub",
    Footer           = "v3.0 | Player ESP + FV Fix",
    Icon             = 95816097006870,
    NotifySide       = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main            = Window:AddTab("Main Features","user"),
    Parry           = Window:AddTab("Auto Parry","shield"),
    ESP             = Window:AddTab("ESP","eye"),
    ["UI Settings"] = Window:AddTab("UI Settings","settings"),
}

-- ── Main Tab ──────────────────────────────────────────────
local PalletBox = Tabs.Main:AddLeftGroupbox("Auto Pallet Stun")
local VaultBox  = Tabs.Main:AddRightGroupbox("Fast Vault")
local SkillBox  = Tabs.Main:AddRightGroupbox("Auto Skillcheck")

PalletBox:AddToggle("AutoPallet",{Text="Auto Pallet Stun",Default=state.cfg.p_enabled,
    Tooltip="Automatically drop pallets on Killers",
    Callback=function(v) state.cfg.p_enabled=v end})
PalletBox:AddToggle("AntiBait",{Text="Anti-Bait Protection",Default=state.cfg.antiBait,
    Callback=function(v) state.cfg.antiBait=v end})
PalletBox:AddSlider("StunReach",{Text="Stun Reach",Default=state.cfg.stunReach,Min=4,Max=20,Rounding=0,Suffix=" studs",
    Callback=function(v) state.cfg.stunReach=v end})
PalletBox:AddSlider("InteractRadius",{Text="Interact Radius",Default=state.cfg.interactionRadius,Min=4,Max=25,Rounding=0,Suffix=" studs",
    Callback=function(v) state.cfg.interactionRadius=v end})
PalletBox:AddSlider("PalletCooldown",{Text="Drop Cooldown",Default=state.cfg.cooldown,
    Min=0.05,Max=1.5,Rounding=2,Suffix="s",
    Callback=function(v) state.cfg.cooldown=v end})

VaultBox:AddToggle("AutoVault",{Text="Always Fast Vault",Default=state.cfg.fv_enabled,
    Callback=function(v) state.cfg.fv_enabled=v end})
VaultBox:AddSlider("ArmRadius",{Text="Arm Radius",Default=state.cfg.fv_radius,Min=4,Max=20,Rounding=0,Suffix=" studs",
    Callback=function(v) state.cfg.fv_radius=v end})
VaultBox:AddSlider("TurnLimit",{Text="Turn Limit Angle",Default=state.cfg.fv_deadband,Min=0,Max=50,Rounding=0,Suffix="°",
    Callback=function(v) state.cfg.fv_deadband=v end})
VaultBox:AddToggle("IgnoreOffAxis",{Text="Ignore Off-Axis",Default=state.cfg.fv_ignoreAxis,
    Callback=function(v) state.cfg.fv_ignoreAxis=v end})

SkillBox:AddToggle("AutoSkillcheck",{Text="Auto Skillcheck",Default=state.cfg.sc_enabled,
    Callback=function(v) state.cfg.sc_enabled=v end})
SkillBox:AddSlider("ScOffset",{Text="Hit Zone Offset",Default=state.cfg.sc_offset,Min=80,Max=130,Rounding=0,Suffix="°",
    Callback=function(v) state.cfg.sc_offset=v end})
SkillBox:AddSlider("ScLead",{Text="Lead Angle",Default=state.cfg.sc_lead,Min=0,Max=10,Rounding=0,Suffix="°",
    Callback=function(v) state.cfg.sc_lead=v end})

-- ── Parry Tab ─────────────────────────────────────────────
local ParryBox  = Tabs.Parry:AddLeftGroupbox("Auto Parry Settings")
local TimingBox = Tabs.Parry:AddLeftGroupbox("Timing Settings")
local StatusBox = Tabs.Parry:AddRightGroupbox("Parry Live Status")

ParryBox:AddToggle("AutoParry",{Text="Auto Parry (Right Click)",Default=state.cfg.ap_enabled,
    Callback=function(v)
        state.cfg.ap_enabled=v
        if uiLabels.status then uiLabels.status:SetText("Status: "..(v and "Active" or "Disabled")) end
    end})
ParryBox:AddToggle("ShowParryCircle",{Text="Show Anim Detect Radius",Default=state.cfg.ap_showCircle,
    Callback=function(v)
        state.cfg.ap_showCircle=v
        if parryAdornment then parryAdornment.Visible=v end
    end}):AddColorPicker("ParryCircleColor",{Default=state.cfg.ap_circleColor,Title="Ring Color",
    Callback=function(v) state.cfg.ap_circleColor=v end})
ParryBox:AddSlider("AnimParryRadius",{Text="Anim Detect Radius",Default=state.cfg.ap_animRadius,
    Min=5,Max=20,Rounding=0,Suffix=" studs",
    Callback=function(v) state.cfg.ap_animRadius=v end})
ParryBox:AddSlider("PendingRadius",{Text="Pending Swing Radius",Default=state.cfg.ap_pendingRadius,
    Min=10,Max=35,Rounding=0,Suffix=" studs",
    Callback=function(v) state.cfg.ap_pendingRadius=v end})
ParryBox:AddSlider("HitboxRadius",{Text="Hitbox Detect Buffer",Default=state.cfg.ap_hitboxRadius,
    Min=5,Max=25,Rounding=0,Suffix=" studs",
    Callback=function(v) state.cfg.ap_hitboxRadius=v end})
ParryBox:AddSlider("ParryCooldown",{Text="Parry Cooldown",Default=state.cfg.ap_cooldown,
    Min=0.05,Max=2.0,Rounding=2,Suffix="s",
    Callback=function(v) state.cfg.ap_cooldown=v; PARRY_COOLDOWN=v end})

TimingBox:AddSlider("AnimPreDelay",{Text="Anim Pre-Delay",Default=state.cfg.ap_animPreDelay,
    Min=0.0,Max=0.3,Rounding=2,Suffix="s",
    Callback=function(v) state.cfg.ap_animPreDelay=v end})

uiLabels.status     = StatusBox:AddLabel("Status: Disabled")
uiLabels.killerDist = StatusBox:AddLabel("Killer: None")

if state.cfg.ap_enabled and uiLabels.status then
    uiLabels.status:SetText("Status: Active")
end

-- ── ESP Tab ───────────────────────────────────────────────
local ESPBox       = Tabs.ESP:AddLeftGroupbox("Killer ESP")
local PlayerESPBox = Tabs.ESP:AddRightGroupbox("Player ESP")

ESPBox:AddToggle("ESPEnabled",{Text="Enable Killer ESP",Default=state.cfg.esp_enabled,
    Callback=function(v) state.cfg.esp_enabled=v end})
ESPBox:AddToggle("ESPShowBox",{Text="Show Highlight",Default=state.cfg.esp_showBox,
    Callback=function(v) state.cfg.esp_showBox=v end})
ESPBox:AddToggle("ESPShowName",{Text="Show Name",Default=state.cfg.esp_showName,
    Callback=function(v) state.cfg.esp_showName=v end})
ESPBox:AddToggle("ESPShowDist",{Text="Show Distance",Default=state.cfg.esp_showDist,
    Callback=function(v) state.cfg.esp_showDist=v end})
ESPBox:AddSlider("ESPMaxDist",{Text="Max Distance",Default=state.cfg.esp_maxDist,
    Min=50,Max=1000,Rounding=0,Suffix=" studs",
    Callback=function(v) state.cfg.esp_maxDist=v end})

PlayerESPBox:AddToggle("PlayerESPEnabled",{Text="Enable Player ESP",Default=state.cfg.p_esp_enabled,
    Callback=function(v) state.cfg.p_esp_enabled=v end})
PlayerESPBox:AddToggle("PlayerESPShowDist",{Text="Show Distance (under feet)",Default=state.cfg.p_esp_showDist,
    Callback=function(v) state.cfg.p_esp_showDist=v end})
PlayerESPBox:AddSlider("PlayerESPMaxDist",{Text="Max Distance",Default=state.cfg.p_esp_maxDist,
    Min=50,Max=1000,Rounding=0,Suffix=" studs",
    Callback=function(v) state.cfg.p_esp_maxDist=v end})

-- ── UI Settings Tab ───────────────────────────────────────
pcall(function() ThemeManager:SetLibrary(Library) end)
pcall(function() SaveManager:SetLibrary(Library) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({"MenuKeybind"}) end)
pcall(function() ThemeManager:SetFolder("ViolenceDistrictHub") end)
pcall(function() SaveManager:SetFolder("ViolenceDistrictHub/settings") end)
pcall(function() SaveManager:BuildConfigSection(Tabs["UI Settings"]) end)
pcall(function() ThemeManager:ApplyToTab(Tabs["UI Settings"]) end)

local UnloadBox = Tabs["UI Settings"]:AddLeftGroupbox("Unload Script")
UnloadBox:AddButton({Text="Unload Script",Func=function() Library:Unload() end,
    DoubleClick=false,Tooltip="Stops all loops and destroys the UI."})

-- ── Unload
Library:OnUnload(function()
    state.running = false
    for char,conns in pairs(killerAnimConns) do
        for _,c in ipairs(conns) do pcall(c.Disconnect,c) end
    end
    for char in pairs(espTrackedChars) do removeESP(char) end
    for char in pairs(playerEspTracked) do removePlayerESP(char) end
    local root = getHRP()
    if root then
        local bg = root:FindFirstChild("VDHub_FV_Gyro")
        if bg then pcall(function() bg:Destroy() end) end
    end
    pcall(function() parryAdornment:Destroy() end)
    _G.vdHub = nil
    print("[vdHub v3.0] Unloaded!")
end)
