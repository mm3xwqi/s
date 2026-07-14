local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local VIM          = game:GetService("VirtualInputManager")
local VU           = game:GetService("VirtualUser")
local RS           = game:GetService("ReplicatedStorage")
local HttpService  = game:GetService("HttpService")
local LP           = Players.LocalPlayer

-- ─── HUD ───────────────────────────────────────────────────────────────────
local HudGui = Instance.new("ScreenGui")
HudGui.Name = "PerfHUD"
HudGui.ResetOnSpawn = false
HudGui:SetAttribute("BloxFruitByIndex", true)
HudGui.Parent = LP:WaitForChild("PlayerGui")

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 160, 0, 100)
Card.Position = UDim2.new(0, 12, 0, 12)
Card.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Card.BackgroundTransparency = 0.15
Card.BorderSizePixel = 0
Card.Active = true
Card.Draggable = true
Card.Parent = HudGui

local CardCorner = Instance.new("UICorner", Card)
CardCorner.CornerRadius = UDim.new(0, 8)

local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Color = Color3.fromRGB(60, 60, 80)
CardStroke.Thickness = 1
CardStroke.Transparency = 0.3

local Accent = Instance.new("Frame", Card)
Accent.Size = UDim2.new(0, 3, 1, -12)
Accent.Position = UDim2.new(0, 0, 0, 6)
Accent.BackgroundColor3 = Color3.fromRGB(255, 160, 60)
Accent.BorderSizePixel = 0
Instance.new("UICorner", Accent).CornerRadius = UDim.new(1, 0)

local function makeRow(parent, yOffset)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -18, 0, 28)
    row.Position = UDim2.new(0, 10, 0, yOffset)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    return row
end

local function makeLabel(parent, text, size, color, xAlign, xOffset, width)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(0, width or 50, 1, 0)
    lbl.Position = UDim2.new(0, xOffset or 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.new(1, 1, 1)
    lbl.TextSize = size or 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    lbl.TextStrokeTransparency = 0.8
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    return lbl
end

local fpsRow   = makeRow(Card, 6)
local fpsTag   = makeLabel(fpsRow, "FPS",  10, Color3.fromRGB(150,150,160), Enum.TextXAlignment.Left,  8, 30)
local fpsValue = makeLabel(fpsRow, "---",  18, Color3.fromRGB(255,220,80),  Enum.TextXAlignment.Left, 38, 50)
local fpsBar   = Instance.new("Frame", fpsRow)
fpsBar.Size             = UDim2.new(0, 0, 0, 3)
fpsBar.Position         = UDim2.new(0, 8, 1, -4)
fpsBar.BackgroundColor3 = Color3.fromRGB(255,220,80)
fpsBar.BorderSizePixel  = 0
Instance.new("UICorner", fpsBar).CornerRadius = UDim.new(1, 0)

local pingRow   = makeRow(Card, 36)
local pingTag   = makeLabel(pingRow, "PING", 10, Color3.fromRGB(150,150,160), Enum.TextXAlignment.Left,  8, 30)
local pingValue = makeLabel(pingRow, "---",  18, Color3.fromRGB(80,220,160),  Enum.TextXAlignment.Left, 38, 70)
local pingBar   = Instance.new("Frame", pingRow)
pingBar.Size             = UDim2.new(0, 0, 0, 3)
pingBar.Position         = UDim2.new(0, 8, 1, -4)
pingBar.BackgroundColor3 = Color3.fromRGB(80,220,160)
pingBar.BorderSizePixel  = 0
Instance.new("UICorner", pingBar).CornerRadius = UDim.new(1, 0)

do
    local timeRow   = makeRow(Card, 66)
    local timeTag   = makeLabel(timeRow, "TIME", 10, Color3.fromRGB(150,150,160), Enum.TextXAlignment.Left, 8, 35)
    local timeValue = makeLabel(timeRow, "00:00", 15, Color3.fromRGB(180,160,255), Enum.TextXAlignment.Left, 46, 100)
    local _start    = tick()
    RunService.Heartbeat:Connect(function()
        local e = math.floor(tick() - _start)
        local h = math.floor(e / 3600)
        local m = math.floor((e % 3600) / 60)
        local s = e % 60
        timeValue.Text = h > 0 and string.format("%d:%02d:%02d", h, m, s) or string.format("%02d:%02d", m, s)
    end)
end

local _fps        = 0
local _frameCount = 0
local _lastTime   = tick()
local _maxBarW    = 130

RunService.RenderStepped:Connect(function()
    _frameCount = _frameCount + 1
    local now = tick()
    if now - _lastTime >= 1 then
        _fps = math.clamp(_frameCount, 0, 9999)
        _frameCount = 0
        _lastTime = now
        local ratio = math.min(_fps, 120) / 120
        local fCol = _fps >= 60 and Color3.fromRGB(80,220,80) or (_fps >= 30 and Color3.fromRGB(255,200,40) or Color3.fromRGB(255,70,70))
        fpsValue.Text           = tostring(_fps)
        fpsValue.TextColor3     = fCol
        fpsBar.Size             = UDim2.new(0, math.floor(ratio * _maxBarW), 0, 3)
        fpsBar.BackgroundColor3 = fCol
        Accent.BackgroundColor3 = fCol
    end
end)

RunService.Heartbeat:Connect(function()
    local ok, ping = pcall(function() return math.floor(LP:GetNetworkPing() * 1000) end)
    if not ok then return end
    ping = math.max(0, ping)
    local pCol = ping <= 80 and Color3.fromRGB(60,220,150) or (ping <= 200 and Color3.fromRGB(255,200,40) or Color3.fromRGB(255,70,70))
    pingValue.Text        = tostring(ping) .. " ms"
    pingValue.TextColor3  = pCol
    pingBar.Size          = UDim2.new(0, math.floor((1 - math.min(ping/400,1)) * _maxBarW), 0, 3)
    pingBar.BackgroundColor3 = pCol
end)

-- ─── WindUI ────────────────────────────────────────────────────────────────
local WindUI
do
    local ok, ui = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok and ui then
        WindUI = ui
    else
        WindUI = {
            Notify = function(self, data)
                local msg = data.Title .. ": " .. (data.Content or "")
                print("[Notify]", msg)
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = data.Title, Text = data.Content, Duration = data.Duration or 3
                    })
                end)
            end
        }
    end
end

-- ─── Settings ──────────────────────────────────────────────────────────────
local Tasks = { autoEquip=nil, autoSkill=nil, autoJump=nil }

local F = { clip=true, farmAura=false }
local Refs = { noclip=nil }

local S = {
    AutoJumpEnabled     = true,
    SelectedWeaponType  = "Melee",
    AutoEquipEnabled    = false,

    -- ★ ค่าใหม่: ระบบการเคลื่อนที่แบบ Heartbeat/CFrame
    MoveSpeed           = 250,     -- studs/วินาที
    YOffset             = 35,      -- ความสูงเหนือมอน

    PlayerOffsetMode    = "random",
    PlayerOffsetCustom  = Vector3.new(0,35,0),
    PlayerOffsetRange   = 8,
    PlayerOffsetY       = 35,
    PlayerOffsetInterval= 0.1,

    BringMobEnabled     = false,
    BringMobMaxDistance = 500,
    BringMobMaxBatch    = 6,
    BringMobOffsetMode  = "random",
    BringMobCustomOffset= Vector3.new(0,0,0),

    AutoSkill = {
        Enabled = false,
        Keys = {
            Z={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
            X={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
            C={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
            V={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
            F={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
        }
    },
    AimAssistEnabled = false,
}

local SETTINGS_FOLDER = "BloxFruit_ByIndex"
local SETTINGS_KEY    = SETTINGS_FOLDER .. "/" .. (LP.Name or "Unknown")
pcall(function() if not isfolder(SETTINGS_FOLDER) then makefolder(SETTINGS_FOLDER) end end)

local function saveSettings()
    pcall(function()
        if not isfolder(SETTINGS_FOLDER) then makefolder(SETTINGS_FOLDER) end
        local d = {
            AutoJumpEnabled      = S.AutoJumpEnabled,
            SelectedWeaponType   = S.SelectedWeaponType,
            AutoEquipEnabled     = S.AutoEquipEnabled,
            MoveSpeed            = S.MoveSpeed,
            YOffset              = S.YOffset,
            BringMobMaxDistance  = S.BringMobMaxDistance,
            BringMobMaxBatch     = S.BringMobMaxBatch,
            BringMobOffsetMode   = S.BringMobOffsetMode,
            PlayerOffsetMode     = S.PlayerOffsetMode,
            PlayerOffsetRange    = S.PlayerOffsetRange,
            PlayerOffsetInterval = S.PlayerOffsetInterval,
            PlayerOffsetY        = S.PlayerOffsetY,
            BringMobEnabled      = S.BringMobEnabled,
            AimAssistEnabled     = S.AimAssistEnabled,
            AutoSkillEnabled     = S.AutoSkill.Enabled,
        }
        for k, v in pairs(S.AutoSkill.Keys) do
            d["AutoSkill_"..k.."_Enabled"] = v.Enabled
            d["AutoSkill_"..k.."_Hold"]    = v.HoldTime
            d["AutoSkill_"..k.."_CD"]      = v.Cooldown
        end
        writefile(SETTINGS_KEY .. "_main.json", HttpService:JSONEncode(d))
    end)
end

local function loadSettings()
    local ok, c = pcall(readfile, SETTINGS_KEY .. "_main.json")
    if not ok or not c then return {} end
    local ok2, d = pcall(HttpService.JSONDecode, HttpService, c)
    if not ok2 or type(d) ~= "table" then return {} end
    return d
end

do
    local sv = loadSettings()
    local function gs(k, def) local v = sv[k] if v == nil then return def end return v end
    S.AutoJumpEnabled    = gs("AutoJumpEnabled",    true)
    S.SelectedWeaponType = gs("SelectedWeaponType", "Melee")
    S.AutoEquipEnabled   = gs("AutoEquipEnabled",   false)
    S.MoveSpeed          = gs("MoveSpeed",          250)
    S.YOffset            = gs("YOffset",            35)
    S.BringMobMaxDistance= gs("BringMobMaxDistance",500)
    S.BringMobMaxBatch   = gs("BringMobMaxBatch",   6)
    S.BringMobOffsetMode = gs("BringMobOffsetMode", "random")
    S.PlayerOffsetMode   = gs("PlayerOffsetMode",   "random")
    S.PlayerOffsetRange  = gs("PlayerOffsetRange",  8)
    S.PlayerOffsetInterval=gs("PlayerOffsetInterval",0.1)
    S.PlayerOffsetY      = gs("PlayerOffsetY",      35)
    S.PlayerOffsetCustom = Vector3.new(0, S.PlayerOffsetY, 0)
    S.BringMobEnabled    = gs("BringMobEnabled",    false)
    S.AimAssistEnabled   = gs("AimAssistEnabled",   false)
    S.AutoSkill.Enabled  = gs("AutoSkillEnabled",   false)
    for _, k in ipairs({"Z","X","C","V","F"}) do
        S.AutoSkill.Keys[k].Enabled  = gs("AutoSkill_"..k.."_Enabled", false)
        S.AutoSkill.Keys[k].HoldTime = gs("AutoSkill_"..k.."_Hold",    0.1)
        S.AutoSkill.Keys[k].Cooldown = gs("AutoSkill_"..k.."_CD",      2.0)
    end
end

-- ─── Helpers ───────────────────────────────────────────────────────────────
local function notify(t, c, d) WindUI:Notify({Title=t, Content=c or "", Duration=d or 3}) end
local function getHRP(ch)  return ch and ch:FindFirstChild("HumanoidRootPart") end
local function getHum(ch)  return ch and ch:FindFirstChildOfClass("Humanoid") end

local function isAlive(m)
    if not m or not m.Parent then return false end
    local h = getHum(m)
    return h and h.Health > 0
end

local function isPC(m)
    for _, p in ipairs(Players:GetPlayers()) do if p.Character == m then return true end end
    return false
end

local function getEHRP(e)
    if not e then return nil end
    if e:IsA("Model") then
        return e:FindFirstChild("HumanoidRootPart")
            or e.PrimaryPart
            or e:FindFirstChildWhichIsA("BasePart")
    elseif e:IsA("BasePart") then
        return e
    end
    return nil
end

local function getTip(t)
    if not t then return nil end
    local ok, tip = pcall(function() return t.ToolTip end)
    if ok and tip and tip ~= "" then return tip end
    local c2 = t:FindFirstChild("ToolTip")
    if c2 then return type(c2.Value)=="string" and c2.Value or nil end
    return t:GetAttribute("ToolTip") or t.Name
end

local function pressKey(key, holdDuration)
    holdDuration = holdDuration or 0.1
    pcall(function()
        VIM:SendKeyEvent(true,  Enum.KeyCode[key], false, game)
        if holdDuration > 0 then task.wait(holdDuration) end
        VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

-- ─── Noclip ────────────────────────────────────────────────────────────────
local function enableNoclip()
    F.clip = false
    if Refs.noclip then return end
    Refs.noclip = RunService.Stepped:Connect(function()
        if F.clip then return end
        local c = LP.Character if not c then return end
        for _, child in pairs(c:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide then child.CanCollide = false end
        end
    end)
end

local function disableNoclip()
    F.clip = true
    if Refs.noclip then Refs.noclip:Disconnect() Refs.noclip = nil end
end

-- ─── Player Offset Loop ────────────────────────────────────────────────────
local playerOffsetCurrent = Vector3.new(0, 35, 0)
local function startPlayerOffsetLoop()
    task.spawn(function()
        while true do
            if S.PlayerOffsetMode == "random" then
                local r = S.PlayerOffsetRange
                playerOffsetCurrent = Vector3.new(
                    math.random(-r, r),
                    S.PlayerOffsetY,
                    math.random(-r, r)
                )
            end
            task.wait(S.PlayerOffsetInterval)
        end
    end)
end

-- ─── Find Closest Enemy ────────────────────────────────────────────────────
local CurrentFarmTarget = nil

local function FindClosestEnemy()
    local hrp = getHRP(LP.Character)
    if not hrp then return nil end
    local ef = workspace:FindFirstChild("Enemies")
    if not ef then return nil end
    local closest, closestDist = nil, math.huge
    for _, e in ipairs(ef:GetChildren()) do
        if e and e.Parent and isAlive(e) and not isPC(e) then
            local p = getEHRP(e)
            if p then
                local d = (hrp.Position - p.Position).Magnitude
                if d < closestDist then closestDist = d; closest = e end
            end
        end
    end
    return closest
end

-- ★ ล็อกเป้าหมาย: ถ้าตัวเดิมยังมีชีวิต ใช้ต่อ; ถ้าตายให้หาใหม่ทันที
local function GetLockedFarmTarget()
    if CurrentFarmTarget and CurrentFarmTarget.Parent and isAlive(CurrentFarmTarget) then
        return CurrentFarmTarget
    end
    CurrentFarmTarget = FindClosestEnemy()
    return CurrentFarmTarget
end

-- ─── Farm Aura (Heartbeat / CFrame — ไม่มี TweenService) ──────────────────
local farmAuraConn = nil

local function StartFarmAura()
    if farmAuraConn then return end
    F.farmAura = true
    enableNoclip()

    farmAuraConn = RunService.Heartbeat:Connect(function(dt)
        if not F.farmAura then return end

        local char = LP.Character
        if not char then return end
        local hrp = getHRP(char)
        if not hrp then return end

        local target = GetLockedFarmTarget()
        if not target then return end
        local ep = getEHRP(target)
        if not ep or not ep.Parent then return end

        -- เคลียร์ velocity กัน physics ดัน
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

        -- คำนวณตำแหน่งเป้าหมาย
        local off
        if S.PlayerOffsetMode == "custom" then
            off = S.PlayerOffsetCustom
        else
            off = playerOffsetCurrent
        end

        local ePos      = ep.Position
        local targetPos = Vector3.new(ePos.X + off.X, ePos.Y + S.YOffset, ePos.Z + off.Z)
        local delta     = targetPos - hrp.Position
        local dist      = delta.Magnitude
        local step      = S.MoveSpeed * dt

        local newPos
        if dist <= step then
            newPos = targetPos
        else
            newPos = hrp.Position + (delta / dist) * step
        end

        -- หันหน้าเข้าหามอน ใช้ rotation ของ enemy HRP
        local enemyRot = ep.CFrame - ep.CFrame.Position
        pcall(function()
            hrp.CFrame = CFrame.new(newPos) * enemyRot
        end)
    end)
end

local function StopFarmAura()
    F.farmAura = false
    if farmAuraConn then
        farmAuraConn:Disconnect()
        farmAuraConn = nil
    end
    CurrentFarmTarget = nil
    disableNoclip()
end

-- ─── Auto Equip ────────────────────────────────────────────────────────────
local function equipWeapon(wt)
    local c = LP.Character if not c then return end
    local function match(t) local tip = getTip(t) return tip and string.find(string.lower(tip), string.lower(wt)) end
    local tool = nil
    for _, t in ipairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and match(t) then tool = t break end end
    if not tool then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and match(t) then tool = t break end end end
    if tool then
        local h = getHum(c)
        if h then
            if tool.Parent == LP.Backpack then tool.Parent = c; task.wait(0.1) end
            h:EquipTool(tool)
        end
    end
end

local function startAutoEquip()
    if Tasks.autoEquip then return end
    Tasks.autoEquip = task.spawn(function()
        while S.AutoEquipEnabled do
            local c = LP.Character
            local equipped = nil
            if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then equipped = t break end end end
            if not equipped then
                equipWeapon(S.SelectedWeaponType); task.wait(0.5)
            else
                local tip = getTip(equipped)
                if not tip or not string.find(string.lower(tip), string.lower(S.SelectedWeaponType)) then
                    equipped.Parent = LP.Backpack; task.wait(0.2); equipWeapon(S.SelectedWeaponType)
                end
            end
            task.wait(1)
        end
        Tasks.autoEquip = nil
    end)
end

local function stopAutoEquip()
    S.AutoEquipEnabled = false
    if Tasks.autoEquip then task.cancel(Tasks.autoEquip); Tasks.autoEquip = nil end
end

-- ─── Auto Skill ────────────────────────────────────────────────────────────
local function startAutoSkill()
    if Tasks.autoSkill then return end
    Tasks.autoSkill = task.spawn(function()
        while S.AutoSkill.Enabled do
            for key, data in pairs(S.AutoSkill.Keys) do
                if data.Enabled then
                    local now = tick()
                    if now - data.LastUsed >= data.Cooldown then
                        local shouldUse = true
                        if S.AimAssistEnabled then
                            local target = FindClosestEnemy()
                            if not target then shouldUse = false end
                        end
                        if shouldUse then
                            data.LastUsed = now
                            task.spawn(function() pressKey(key, data.HoldTime) end)
                        end
                    end
                end
            end
            task.wait(0.1)
        end
        Tasks.autoSkill = nil
    end)
end

local function stopAutoSkill()
    S.AutoSkill.Enabled = false
    if Tasks.autoSkill then task.cancel(Tasks.autoSkill); Tasks.autoSkill = nil end
end

-- ─── Auto Jump ─────────────────────────────────────────────────────────────
local function startAutoJump()
    if Tasks.autoJump then return end
    Tasks.autoJump = task.spawn(function()
        while S.AutoJumpEnabled do
            local c = LP.Character
            if c then
                local h = getHum(c)
                if h and h.Health > 0 then h.Jump = true end
            end
            task.wait(0.5)
        end
        Tasks.autoJump = nil
    end)
end

local function stopAutoJump()
    S.AutoJumpEnabled = false
    if Tasks.autoJump then task.cancel(Tasks.autoJump); Tasks.autoJump = nil end
end

-- ─── Aim Assist ────────────────────────────────────────────────────────────
local aimConn = nil

local function startAimAssist()
    if aimConn then return end
    aimConn = RunService.Heartbeat:Connect(function()
        if not S.AimAssistEnabled then return end
        local char = LP.Character if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local target = FindClosestEnemy() if not target then return end
        local tEHRP  = getEHRP(target) if not tEHRP or not tEHRP.Parent then return end
        local tPos   = tEHRP.Position
        pcall(function()
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tPos.X, hrp.Position.Y, tPos.Z))
        end)
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, tPos) end
        end)
    end)
end

local function stopAimAssist()
    S.AimAssistEnabled = false
    if aimConn then aimConn:Disconnect(); aimConn = nil end
end

-- ─── Bring Mob (Spin ตัวเอง + ดึงมาหา Farm target + Auto-Release) ──────────
--
-- แนวคิด:
--  1. ดึงมอนมาหาตัวละครด้วย BodyPosition (เหมือนเดิม)
--  2. ใส่ BodyAngularVelocity → มอน Spin รอบแกน Y ตัวเอง
--  3. เมื่อมอนมาถึงใกล้ Farm Aura target (≤ RELEASE_THRESHOLD)
--     → ปล่อยทั้ง BodyPosition และ BodyAngularVelocity ทันที
--  4. ถ้ามอนตาย/หายไป → ปล่อยออกอัตโนมัติ

local mobData = {}  -- key=enemy, value={bp, bav}

local SPIN_SPEED        = 30     -- rad/s ความเร็ว spin (ประมาณ 5 รอบ/วินาที)
local RELEASE_THRESHOLD = 8      -- studs ระยะที่ถือว่า "ถึง Farm target" แล้ว → ปล่อย

local function releaseMob(e)
    if not e then return end
    local data = mobData[e] if not data then return end
    -- ลบ BodyPosition
    if data.bp  then pcall(function() data.bp:Destroy()  end) end
    -- ลบ BodyAngularVelocity (หยุด spin)
    if data.bav then pcall(function() data.bav:Destroy() end) end
    -- หยุดมอนให้นิ่ง: Anchor ทุก part + เคลียร์ velocity
    if e.Parent then
        for _, p in ipairs(e:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function()
                    p.AssemblyLinearVelocity  = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                    p.Anchored   = false
                    p.CanCollide = true
                end)
            end
        end
    end
    local h = getHum(e) if h then pcall(function() h.PlatformStand = false end) end
    mobData[e] = nil
end

local function cleanupMobs()
    local snap = {}
    for e in pairs(mobData) do table.insert(snap, e) end
    for _, e in ipairs(snap) do pcall(releaseMob, e) end
    mobData = {}
    pcall(function() collectgarbage() end)
end

-- คืนตำแหน่ง Farm Aura target ปัจจุบัน (ถ้า Farm เปิดอยู่)
local function getFarmTargetPos()
    if not F.farmAura then return nil end
    local t = CurrentFarmTarget
    if not t or not t.Parent or not isAlive(t) then return nil end
    local ep = getEHRP(t)
    return ep and ep.Position or nil
end

local function startBringMob()
    if not S.BringMobEnabled then return end
    cleanupMobs()

    local bringMobConn
    bringMobConn = RunService.Heartbeat:Connect(function()
        if not S.BringMobEnabled then
            if bringMobConn then bringMobConn:Disconnect() end
            cleanupMobs()
            return
        end

        local char = LP.Character if not char then return end
        local hrp  = getHRP(char) if not hrp then return end
        local playerPos = hrp.Position

        local ef = workspace:FindFirstChild("Enemies") if not ef then return end

        -- ─ ปล่อยมอนที่ตาย/หายไปแล้ว ─
        local snap = {}
        for e in pairs(mobData) do table.insert(snap, e) end
        for _, e in ipairs(snap) do
            if not e or not e.Parent or not isAlive(e) then pcall(releaseMob, e) end
        end

        -- ─ รับ Farm target position ─
        local farmPos = getFarmTargetPos()

        -- ─ นับจำนวนที่กำลังดึงอยู่ ─
        local pulling = 0
        for _ in pairs(mobData) do pulling = pulling + 1 end

        -- ─ กำหนดตำแหน่งเป้าหมายการดึง ─
        -- ถ้า Farm เปิดและมี target → ดึงไปหา Farm target
        -- ถ้าไม่มี → ดึงมาหาตัวผู้เล่นแทน
        local pullTarget = farmPos or playerPos

        -- ─ เพิ่มมอนใหม่เข้า list ─
        for _, e in ipairs(ef:GetChildren()) do
            if not S.BringMobEnabled then break end
            if not e or not e.Parent or isPC(e) or not isAlive(e) then continue end
            if mobData[e] then continue end
            if pulling >= S.BringMobMaxBatch then break end

            local ehrp = getEHRP(e) if not ehrp then continue end
            if (playerPos - ehrp.Position).Magnitude > S.BringMobMaxDistance then continue end

            -- BodyPosition: ดึงไปหา Farm target (หรือตัวผู้เล่นถ้า Farm ปิด)
            local bp = Instance.new("BodyPosition")
            bp.Name     = "BringMobBP"
            bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.P        = 80000
            bp.D        = 3000
            bp.Position = pullTarget
            pcall(function() bp.Parent = ehrp end)

            -- BodyAngularVelocity: ทำให้มอน Spin รอบแกน Y ตัวเอง
            local bav = Instance.new("BodyAngularVelocity")
            bav.Name            = "BringMobBAV"
            bav.MaxTorque       = Vector3.new(0, 1e9, 0)
            bav.AngularVelocity = Vector3.new(0, SPIN_SPEED, 0)
            bav.P               = 1e5
            pcall(function() bav.Parent = ehrp end)

            pcall(function() local h = getHum(e) if h then h.PlatformStand = true end end)
            pcall(function()
                for _, p in ipairs(e:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)

            mobData[e] = {bp = bp, bav = bav}
            pulling = pulling + 1
        end

        -- ─ อัปเดต BodyPosition ให้ตามเป้าหมาย + ตรวจ release ─
        local toRelease = {}
        for e, data in pairs(mobData) do
            if not e or not e.Parent or not isAlive(e) then
                table.insert(toRelease, e)
                continue
            end

            -- อัปเดตตำแหน่งเป้าหมาย (Farm target ถ้ามี, ไม่งั้นผู้เล่น)
            if data.bp and data.bp.Parent then
                pcall(function() data.bp.Position = pullTarget end)
            end

            -- auto-release: ถ้ามาถึงใกล้ Farm target แล้ว
            if farmPos then
                local ehrp = getEHRP(e)
                if ehrp and (farmPos - ehrp.Position).Magnitude <= RELEASE_THRESHOLD then
                    table.insert(toRelease, e)
                end
            end
        end

        -- ─ ปล่อยตัวที่ถึงเป้าหมายแล้ว ─
        for _, e in ipairs(toRelease) do
            pcall(releaseMob, e)
            if e == CurrentFarmTarget then
                CurrentFarmTarget = nil
            end
        end
    end)
end

local function stopBringMob()
    S.BringMobEnabled = false
    cleanupMobs()
end

-- ─── Window ────────────────────────────────────────────────────────────────
local Window = WindUI:CreateWindow({
    Title  = "Blox Fruit | By Index",
    Icon   = "solar:star-bold-duotone",
    Folder = "MainFarm",
    NewElements = true,
    Topbar = {Height=44, ButtonsType="Mac"},
    OpenButton = {
        Title="Blox Fruit | By Index", Enabled=true, Draggable=true, OnlyMobile=false,
        StrokeThickness=0, CornerRadius=UDim.new(1,0),
        Color=ColorSequence.new(Color3.fromHex("#ff9f3d"), Color3.fromHex("#ff5c5c"))
    }
})

-- ─── Tab: Main (Farm Aura) ─────────────────────────────────────────────────
local MainTab = Window:Tab({Title="Main", Icon="lucide:house"})

do
    local FarmS = MainTab:Section({Title="Farm Aura", Box=true, BoxBorder=true, Opened=true})

    FarmS:Toggle({Title="Farm Aura", Value=false, Callback=function(v)
        if v then
            StopFarmAura()
            task.wait(0.05)
            StartFarmAura()
        else
            StopFarmAura()
        end
    end})
end

-- ─── Tab: Local Player ─────────────────────────────────────────────────────
do
    local LocalTab = Window:Tab({Title="Local Player", Icon="lucide:contact"})

    local EquipS = LocalTab:Section({Title="Auto Equip", Box=true, BoxBorder=true, Opened=true})
    EquipS:Dropdown({
        Title="Weapon Type", Values={"Melee","Sword","Gun","Fruit"},
        Value=1,
        Callback=function(v) S.SelectedWeaponType = v; saveSettings() end
    })
    EquipS:Space()
    EquipS:Toggle({Title="Auto Equip", Value=S.AutoEquipEnabled, Callback=function(v)
        S.AutoEquipEnabled = v; saveSettings()
        if v then startAutoEquip() else stopAutoEquip() end
    end})
end

-- ─── Tab: Settings ─────────────────────────────────────────────────────────
do
    local SettingTab = Window:Tab({Title="Settings", Icon="lucide:sliders-horizontal"})

    -- ★ Speed & Movement (ใช้ MoveSpeed แทน TweenSpeed)
    local SpeedS = SettingTab:Section({Title="Speed & Movement", Box=true, BoxBorder=true, Opened=true})
    SpeedS:Slider({
        Title="Move Speed (studs/s)", Step=10,
        Value={Min=10, Max=350, Default=S.MoveSpeed},
        Callback=function(v) S.MoveSpeed = v; saveSettings() end
    })
    SpeedS:Space()
    -- ★ Y Offset (ความสูงเหนือมอน)
    SpeedS:Slider({
        Title="Y Offset (Height above mob)", Step=1,
        Value={Min=0, Max=100, Default=S.YOffset},
        Callback=function(v) S.YOffset = v; saveSettings() end
    })
    SpeedS:Space()
    SpeedS:Toggle({Title="Auto Jump", Value=S.AutoJumpEnabled,
        Callback=function(v)
            S.AutoJumpEnabled = v; saveSettings()
            if v then startAutoJump() else stopAutoJump() end
        end})
    SpeedS:Space()

    local OffsetS = SettingTab:Section({Title="Player Offset", Box=true, BoxBorder=true, Opened=true})
    OffsetS:Dropdown({Title="Offset Mode", Values={"Random","Custom"},
        Value = S.PlayerOffsetMode == "custom" and 2 or 1,
        Callback=function(v)
            S.PlayerOffsetMode = (v == "Random") and "random" or "custom"
            saveSettings()
        end})
    OffsetS:Space()
    OffsetS:Slider({Title="Random Range", Step=1, Value={Min=1, Max=45, Default=S.PlayerOffsetRange},
        Callback=function(v) S.PlayerOffsetRange = v; saveSettings() end})
    OffsetS:Space()

    local BringS = SettingTab:Section({Title="Bring Mob", Box=true, BoxBorder=true, Opened=true})
    BringS:Toggle({Title="Bring Mob", Value=S.BringMobEnabled,
        Callback=function(v)
            S.BringMobEnabled = v; saveSettings()
            if v then startBringMob() else stopBringMob() end
        end})
    BringS:Space()
    BringS:Slider({Title="Bring Distance", Step=50, Value={Min=100, Max=1500, Default=S.BringMobMaxDistance},
        Callback=function(v) S.BringMobMaxDistance = v; saveSettings() end})
    BringS:Space()
    BringS:Slider({Title="Max Mobs", Step=1, Value={Min=1, Max=10, Default=S.BringMobMaxBatch},
        Callback=function(v) S.BringMobMaxBatch = v; saveSettings() end})
    BringS:Space()
    BringS:Slider({Title="Orbit Radius (studs)", Step=1, Value={Min=2, Max=20, Default=6},
        Callback=function(v) ORBIT_RADIUS = v end})
    BringS:Space()
    BringS:Slider({Title="Orbit Speed (rad/s)", Step=0.1, Value={Min=0.2, Max=5.0, Default=1.2},
        Callback=function(v) ORBIT_SPEED = v end})
    BringS:Space()
    BringS:Slider({Title="Release Distance (studs)", Step=1, Value={Min=2, Max=30, Default=0},
        Callback=function(v) RELEASE_THRESHOLD = v end})
end

-- ─── Tab: Auto Skill ───────────────────────────────────────────────────────
do
    local SkillTab = Window:Tab({Title="Auto Skill", Icon="solar:keyboard-bold-duotone"})

    local MainS = SkillTab:Section({Title="Auto Skill Settings", Box=true, BoxBorder=true, Opened=true})
    MainS:Toggle({
        Title="Enable Auto Skill", Value=S.AutoSkill.Enabled,
        Callback=function(v)
            S.AutoSkill.Enabled = v
            if v then startAutoSkill() else stopAutoSkill() end
            saveSettings()
        end
    })
    MainS:Space()
    MainS:Toggle({
        Title="Mob Aim Assist", Value=S.AimAssistEnabled,
        Callback=function(v)
            S.AimAssistEnabled = v
            if v then startAimAssist() else stopAimAssist() end
            saveSettings()
        end
    })
    MainS:Space()

    for _, key in ipairs({"Z","X","C","V","F"}) do
        local KeyS = SkillTab:Section({Title="Skill Key: "..key, Box=true, BoxBorder=true, Opened=false})
        KeyS:Toggle({Title="Enable "..key, Value=S.AutoSkill.Keys[key].Enabled,
            Callback=function(v) S.AutoSkill.Keys[key].Enabled = v; saveSettings() end})
        KeyS:Slider({Title="Hold Time (s)", Step=0.05, Value={Min=0.05, Max=2.0, Default=S.AutoSkill.Keys[key].HoldTime},
            Callback=function(v) S.AutoSkill.Keys[key].HoldTime = v; saveSettings() end})
        KeyS:Slider({Title="Cooldown (s)", Step=0.5, Value={Min=0.5, Max=10.0, Default=S.AutoSkill.Keys[key].Cooldown},
            Callback=function(v) S.AutoSkill.Keys[key].Cooldown = v; saveSettings() end})
    end
end

-- ─── Tab: FPS Boost ────────────────────────────────────────────────────────
do
    local FpsTab = Window:Tab({Title="FPS Boost", Icon="lucide:zap"})
    local FpsS   = FpsTab:Section({Title="FPS Optimization", Box=true, BoxBorder=true, Opened=true})

    local fpsBoostEnabled = false
    local storedEffects   = {}
    local fpsBoostConn    = nil
    local fpsContainer    = nil

    FpsS:Toggle({
        Title="FPS Boost (Clear Effects)", Value=false,
        Callback=function(v)
            fpsBoostEnabled = v
            if v then
                if not fpsContainer then
                    task.spawn(function()
                        local ok, c = pcall(function()
                            return RS:WaitForChild("Effect",10):WaitForChild("Container",10)
                        end)
                        if ok and c then
                            fpsContainer = c
                            storedEffects = {}
                            for _, child in ipairs(fpsContainer:GetChildren()) do
                                table.insert(storedEffects, child:Clone())
                                pcall(function() child:Destroy() end)
                            end
                            if fpsBoostConn then fpsBoostConn:Disconnect() end
                            fpsBoostConn = fpsContainer.ChildAdded:Connect(function(child)
                                task.wait()
                                if fpsBoostEnabled then pcall(function() child:Destroy() end) end
                            end)
                        else
                            fpsBoostEnabled = false
                        end
                    end)
                end
            else
                if fpsBoostConn then fpsBoostConn:Disconnect(); fpsBoostConn = nil end
                if fpsContainer then
                    for _, clone in ipairs(storedEffects) do
                        pcall(function() clone.Parent = fpsContainer end)
                    end
                    storedEffects = {}
                end
            end
        end
    })
end

-- ─── Head Hitbox Expander ──────────────────────────────────────────────────
-- ขยาย Size ของ Head ทุกตัวใน workspace.Enemies
-- เก็บขนาดเดิมไว้เพื่อคืนค่าเมื่อปิด

local headOrigSize  = {}   -- key=Head part, value=Vector3 (ขนาดเดิม)
local headHitboxConn = nil
local HEAD_SCALE    = 10   -- เท่าของขนาดเดิม (ปรับได้ใน UI)

local function applyHeadHitbox(scale)
    local ef = workspace:FindFirstChild("Enemies")
    if not ef then return end
    for _, e in ipairs(ef:GetChildren()) do
        if not e or not e.Parent then continue end
        local head = e:FindFirstChild("Head")
        if not head or not head:IsA("BasePart") then continue end
        -- เก็บขนาดเดิมครั้งแรกที่เจอ
        if not headOrigSize[head] then
            headOrigSize[head] = head.Size
        end
        -- ขยาย hitbox: ใช้ Size จากขนาดเดิมคูณ scale (ไม่ซ้อน)
        pcall(function()
            head.Size = headOrigSize[head] * scale
        end)
    end
end

local function restoreHeadHitbox()
    -- คืนค่าขนาดเดิมทุก Head ที่เคยเก็บไว้
    for head, origSize in pairs(headOrigSize) do
        if head and head.Parent then
            pcall(function() head.Size = origSize end)
        end
    end
    headOrigSize = {}
end

local function startHeadHitbox()
    if headHitboxConn then return end
    headHitboxConn = RunService.Heartbeat:Connect(function()
        applyHeadHitbox(HEAD_SCALE)
    end)
end

local function stopHeadHitbox()
    if headHitboxConn then
        headHitboxConn:Disconnect()
        headHitboxConn = nil
    end
    restoreHeadHitbox()
end

-- ─── Tab: Head Hitbox ──────────────────────────────────────────────────────
do
    local HitTab = Window:Tab({Title="Hitbox", Icon="lucide:scan"})
    local HitS   = HitTab:Section({Title="Head Hitbox (All Enemies)", Box=true, BoxBorder=true, Opened=true})

    HitS:Toggle({
        Title="Expand Head Hitbox", Value=false,
        Callback=function(v)
            if v then startHeadHitbox() else stopHeadHitbox() end
        end
    })
    HitS:Space()
    HitS:Slider({
        Title="Head Scale", Step=1,
        Value={Min=1, Max=50, Default=HEAD_SCALE},
        Callback=function(v)
            HEAD_SCALE = v
        end
    })
    HitS:Space()
    HitS:Toggle({
        Title="Spin Mob (ขณะ Bring)", Value=false,
        Callback=function(v)
            if v then
                SPIN_SPEED = 30
            else
                SPIN_SPEED = 0
                -- อัปเดต BodyAngularVelocity ที่มีอยู่ทันที
                for e, data in pairs(mobData) do
                    if data.bav and data.bav.Parent then
                        pcall(function() data.bav.AngularVelocity = Vector3.zero end)
                    end
                end
            end
        end
    })
    HitS:Space()
    HitS:Slider({
        Title="Spin Speed (rad/s)", Step=5,
        Value={Min=5, Max=100, Default=30},
        Callback=function(v)
            SPIN_SPEED = v
            -- อัปเดต BodyAngularVelocity ที่มีอยู่แล้วด้วย
            for e, data in pairs(mobData) do
                if data.bav and data.bav.Parent then
                    pcall(function() data.bav.AngularVelocity = Vector3.new(0, SPIN_SPEED, 0) end)
                end
            end
        end
    })
end

-- ─── Tab: Reset ────────────────────────────────────────────────────────────
do
    local ResetTab = Window:Tab({Title="Reset", Icon="lucide:refresh-cw"})
    local ResetS   = ResetTab:Section({Title="Settings", Box=true, BoxBorder=true, Opened=true})
    ResetS:Button({
        Title="Remove Saved Settings",
        Callback=function()
            pcall(function()
                if isfolder(SETTINGS_FOLDER) then
                    local files = listfiles(SETTINGS_FOLDER)
                    for _, f in ipairs(files) do pcall(function() delfile(f) end) end
                    delfolder(SETTINGS_FOLDER)
                end
            end)
            notify("Settings", "Settings deleted!", 3)
        end
    })
end

-- ─── Init ──────────────────────────────────────────────────────────────────
if S.AutoEquipEnabled  then startAutoEquip()  end
if S.AutoSkill.Enabled then startAutoSkill()  end
if S.AimAssistEnabled  then startAimAssist()  end
if S.BringMobEnabled   then startBringMob()   end
if S.AutoJumpEnabled   then startAutoJump()   end

startPlayerOffsetLoop()

-- GC loop
task.spawn(function()
    while true do
        task.wait(300)
        local snap = {}
        for e in pairs(mobData) do table.insert(snap, e) end
        for _, e in ipairs(snap) do
            if not e or not e.Parent or not isAlive(e) then pcall(releaseMob, e) end
        end
        pcall(function() collectgarbage() end)
    end
end)

LP.Idled:Connect(function()
    VU:CaptureController()
    VU:ClickButton2(Vector2.new())
end)
