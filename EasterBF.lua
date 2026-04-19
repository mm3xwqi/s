local function safeCall(f, ...)
    local args = table.pack(...)
    return pcall(function() return f(table.unpack(args, 1, args.n)) end)
end

local hookfunc = hookfunction or function(f, nf) return nf end
local newc = newcclosure or function(f) return f end
local fireprox = fireproximityprompt
local issyn = is_synapse_function
local checkcaller = checkcaller or function() return true end

do
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldIdx = mt.__index
        local oldNew = mt.__newindex
        local oldNC = mt.__namecall
        mt.__index = newc(function(s, k) return oldIdx(s, k) end)
        mt.__newindex = newc(function(s, k, v) return oldNew(s, k, v) end)
        mt.__namecall = newc(function(s, ...) return oldNC(s, ...) end)
        setreadonly(mt, true)
    end
end

if fireprox then
    hookfunc(fireprox, newc(function(p)
        if not checkcaller() then return fireprox(p) end
    end))
end

if issyn then
    hookfunc(issyn, newc(function(a1, a2, a3)
        if checkcaller() then return true end
        return issyn(a1, a2, a3)
    end))
end

-- ===== SERVICES (ประกาศครั้งเดียว) =====
local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local VIM          = game:GetService("VirtualInputManager")
local VU           = game:GetService("VirtualUser")
local RS           = game:GetService("ReplicatedStorage")
local HttpService  = game:GetService("HttpService")
local LP           = Players.LocalPlayer

-- ===== HUD =====
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PerformanceGui"
ScreenGui.ResetOnSpawn = false
ScreenGui:SetAttribute("BloxFruitByIndex", true)
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

-- ===== WINDUI =====
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
            end,
            Dialog = function(self, data) print("[Dialog]", data.Title, data.Content) end
        }
    end
end

-- ===== CACHE =====
local enemyCache = {data=nil, lastUpdate=0, updateInterval=0.3}

task.spawn(function()
    while true do
        task.wait(30)
        if enemyCache.data and (not enemyCache.data.enemy or not enemyCache.data.enemy.Parent) then
            enemyCache.data = nil
        end
    end
end)

-- ===== STATE =====
local Tasks = {
    elite=nil, damageAura=nil, buso=nil, equip=nil,
    grabFruit=nil, farmAura=nil, farmSelect=nil, farmLevel=nil,
    stat={}, randomFruit=nil, awakening=nil, raceAbil=nil,
    storeFruit=nil, dungeon=nil, autoRetry=nil, tyrant=nil, bringMob=nil,
    autoSkill=nil, aimAssist=nil, ken=nil,
}

local F = {
    eliteInterrupt=false, eliteEnabled=false,
    farmAura=false, fruitGrabbing=false,
    tyrantBring=false, autoRetry=false,
    cleaningUp=false, clip=true,
}

local Refs = {
    bringMobToggle=nil, elite=nil, randomFruit=nil,
    enemyDropdown=nil, noclip=nil, spawnWatch=nil, mobNoclip=nil,
    aimAssistToggle=nil,
}

local S = {
    AutoJumpEnabled=true, ChestWaitTime=0, SelectedWeaponType="Melee",
    AutoEquipEnabled=false, SelectedTeam="Pirates",
    BringMobEnabled=false, BringMobMaxDistance=500, BringMobMaxBatch=6,
    BringMobOffsetMode="random", BringMobCustomOffset=Vector3.new(0,0,0),
    BringMobTargetName=nil,
    FarmAuraEnabled=false, FarmAuraHeight=35,
    FarmSelectEnabled=false, SelectedEnemyNames={},
    CurrentFarmTarget=nil, CurrentQuestMobName=nil,
    AutoFarmLevelEnabled=false, DamageAuraEnabled=false, AutoBusoEnabled=true,
    AutoGrabFruitEnabled=false, AutoStatDelay=0.3,
    AutoStatEnabled={Melee=false, Defense=false, Sword=false, Gun=false, DemonFruit=false},
    PlayerOffsetMode="random", PlayerOffsetCustom=Vector3.new(0,35,0),
    PlayerOffsetRange=8, PlayerOffsetY=35, PlayerOffsetInterval=0.1,
    AutoRandomFruitEnabled=false, FruitBlacklist={},
    AutoAwakeningEnabled=false, AutoRaceAbilEnabled=false,
    AutoStoreFruitEnabled=false, AutoDungeonEnabled=false, DungeonCardPriority={},
    DoubleQuestEnabled=false, VIMClickEnabled=false, AutoEliteEnabled=false,
    AimAssistEnabled=false, AutoKenEnabled=false,
    AutoSkill={
        Enabled=false,
        Keys={
            Z={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
            X={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
            C={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
            V={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
            F={Enabled=false, HoldTime=0.1, Cooldown=2.0, LastUsed=0},
        }
    },
}

local SPEED = 350
local lastNotifiedTarget = nil
local SETTINGS_FOLDER = "BloxFruit_ByIndex"
local SETTINGS_KEY = SETTINGS_FOLDER .. "/" .. (LP.Name or "Unknown")
pcall(function() if not isfolder(SETTINGS_FOLDER) then makefolder(SETTINGS_FOLDER) end end)

-- ===== SETTINGS =====
local function saveSettings()
    pcall(function()
        if not isfolder(SETTINGS_FOLDER) then makefolder(SETTINGS_FOLDER) end
        local dcpOk, dcpJson = pcall(function() return HttpService:JSONEncode(S.DungeonCardPriority) end)
        local d = {
            AutoJumpEnabled=S.AutoJumpEnabled, ChestWaitTime=S.ChestWaitTime,
            SelectedWeaponType=S.SelectedWeaponType, AutoEquipEnabled=S.AutoEquipEnabled,
            BringMobMaxDistance=S.BringMobMaxDistance, BringMobMaxBatch=S.BringMobMaxBatch,
            BringMobOffsetMode=S.BringMobOffsetMode, PlayerOffsetMode=S.PlayerOffsetMode,
            PlayerOffsetRange=S.PlayerOffsetRange, PlayerOffsetInterval=S.PlayerOffsetInterval,
            PlayerOffsetCustomX=S.PlayerOffsetCustom.X, PlayerOffsetCustomY=S.PlayerOffsetCustom.Y,
            PlayerOffsetCustomZ=S.PlayerOffsetCustom.Z, PlayerOffsetY=S.PlayerOffsetY,
            AutoStatDelay=S.AutoStatDelay,
            AutoStatMelee=S.AutoStatEnabled.Melee, AutoStatDefense=S.AutoStatEnabled.Defense,
            AutoStatSword=S.AutoStatEnabled.Sword, AutoStatGun=S.AutoStatEnabled.Gun,
            AutoStatDemonFruit=S.AutoStatEnabled.DemonFruit,
            AutoBusoEnabled=S.AutoBusoEnabled, DamageAuraEnabled=S.DamageAuraEnabled,
            AutoGrabFruitEnabled=S.AutoGrabFruitEnabled, AutoFarmLevelEnabled=S.AutoFarmLevelEnabled,
            FarmAuraEnabled=S.FarmAuraEnabled, BringMobEnabled=S.BringMobEnabled,
            SPEED=SPEED, SelectedTeam=S.SelectedTeam,
            AutoAwakeningEnabled=S.AutoAwakeningEnabled, AutoRaceAbilEnabled=S.AutoRaceAbilEnabled,
            AutoStoreFruitEnabled=S.AutoStoreFruitEnabled, AutoRandomFruitEnabled=S.AutoRandomFruitEnabled,
            AutoDungeonEnabled=S.AutoDungeonEnabled, DoubleQuestEnabled=S.DoubleQuestEnabled,
            VIMClickEnabled=S.VIMClickEnabled, AutoEliteEnabled=S.AutoEliteEnabled,
            AimAssistEnabled=S.AimAssistEnabled, AutoKenEnabled=S.AutoKenEnabled,
            DungeonCardPriorityJSON=dcpOk and dcpJson or "[]",
            AutoSkillEnabled=S.AutoSkill.Enabled,
            AutoSkillSilentAim=S.AutoSkill.SilentAim,
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
    S.AutoJumpEnabled=gs("AutoJumpEnabled",true); S.ChestWaitTime=gs("ChestWaitTime",0)
    S.SelectedWeaponType=gs("SelectedWeaponType","Melee"); S.AutoEquipEnabled=gs("AutoEquipEnabled",false)
    S.BringMobMaxDistance=gs("BringMobMaxDistance",500); S.BringMobMaxBatch=gs("BringMobMaxBatch",6)
    S.BringMobOffsetMode=gs("BringMobOffsetMode","random"); S.PlayerOffsetMode=gs("PlayerOffsetMode","random")
    S.PlayerOffsetRange=gs("PlayerOffsetRange",8); S.PlayerOffsetInterval=gs("PlayerOffsetInterval",0.1)
    S.PlayerOffsetY=gs("PlayerOffsetY",35)
    S.PlayerOffsetCustom=Vector3.new(gs("PlayerOffsetCustomX",0),gs("PlayerOffsetCustomY",35),gs("PlayerOffsetCustomZ",0))
    S.AutoStatDelay=gs("AutoStatDelay",0.3)
    S.AutoStatEnabled={
        Melee=gs("AutoStatMelee",false), Defense=gs("AutoStatDefense",false),
        Sword=gs("AutoStatSword",false), Gun=gs("AutoStatGun",false),
        DemonFruit=gs("AutoStatDemonFruit",false)
    }
    S.AutoBusoEnabled=gs("AutoBusoEnabled",true); S.DamageAuraEnabled=gs("DamageAuraEnabled",false)
    S.AutoKenEnabled=gs("AutoKenEnabled",false)
    S.AutoGrabFruitEnabled=gs("AutoGrabFruitEnabled",false); S.AutoFarmLevelEnabled=gs("AutoFarmLevelEnabled",false)
    S.FarmAuraEnabled=gs("FarmAuraEnabled",false); S.BringMobEnabled=gs("BringMobEnabled",false)
    S.SelectedTeam=gs("SelectedTeam","Pirates"); S.AutoAwakeningEnabled=gs("AutoAwakeningEnabled",false)
    S.AutoRaceAbilEnabled=gs("AutoRaceAbilEnabled",false); S.AutoStoreFruitEnabled=gs("AutoStoreFruitEnabled",false)
    S.AutoRandomFruitEnabled=gs("AutoRandomFruitEnabled",false); S.AutoDungeonEnabled=gs("AutoDungeonEnabled",false)
    S.DoubleQuestEnabled=gs("DoubleQuestEnabled",false); S.VIMClickEnabled=gs("VIMClickEnabled",false)
    S.AutoEliteEnabled=gs("AutoEliteEnabled",false); S.AimAssistEnabled=gs("AimAssistEnabled",false)
    SPEED=gs("SPEED",350)
    S.AutoSkill.Enabled=gs("AutoSkillEnabled",false)
    S.AutoSkill.SilentAim=gs("AutoSkillSilentAim",false)
    for _, k in ipairs({"Z","X","C","V","F"}) do
        S.AutoSkill.Keys[k].Enabled  = gs("AutoSkill_"..k.."_Enabled",false)
        S.AutoSkill.Keys[k].HoldTime = gs("AutoSkill_"..k.."_Hold",0.1)
        S.AutoSkill.Keys[k].Cooldown = gs("AutoSkill_"..k.."_CD",2.0)
    end
    local dcpStr = gs("DungeonCardPriorityJSON",nil)
    if dcpStr and dcpStr ~= "" then
        local ok3, dcp = pcall(HttpService.JSONDecode, HttpService, dcpStr)
        if ok3 and type(dcp)=="table" then S.DungeonCardPriority=dcp end
    end
end

-- ===== UTIL =====
local function notify(t, c, d) WindUI:Notify({Title=t, Content=c or "", Duration=d or 3}) end
local function notifyOnce(k, t, d) if lastNotifiedTarget ~= k then lastNotifiedTarget=k notify(t,d) end end
local function getHRP(c) return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function isAlive(m)
    if not m or not m.Parent then return false end
    local h = getHum(m)
    return h and h.Health > 0
end
local function isPropDead(e)
    if not e or not e.Parent then return true end
    local h = getHum(e)
    if h then return h.Health <= 0 end
    local hv = e:FindFirstChild("Health")
    if hv and (hv:IsA("NumberValue") or hv:IsA("IntValue")) then return hv.Value <= 0 end
    return not (e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart"))
end
local function isPC(m)
    for _, p in ipairs(Players:GetPlayers()) do if p.Character == m then return true end end
    return false
end
local function getEHRP(e)
    return e and e.Parent and (e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart"))
end
local function getPos(o)
    if not o or not o.Parent then return nil end
    if typeof(o)=="Vector3" then return o end
    if o:IsA("Model") then local ok, p = pcall(function() return o:GetPivot().Position end) return ok and p end
    if o:IsA("BasePart") then return o.Position end
    local ok, p = pcall(function() return o:GetPivot().Position end) return ok and p
end
local function getTip(t)
    if not t then return nil end
    local ok, tip = pcall(function() return t.ToolTip end)
    if ok and tip and tip ~= "" then return tip end
    local c2 = t:FindFirstChild("ToolTip")
    if c2 then return type(c2.Value)=="string" and c2.Value or nil end
    return t:GetAttribute("ToolTip") or t.Name
end
local function makeBV(hrp, name)
    local old = hrp:FindFirstChild(name) if old then old:Destroy() end
    local bv = Instance.new("BodyVelocity")
    bv.Name=name; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
    return bv
end
local function destroyBV(bv) if not bv then return end pcall(function() bv:Destroy() end) end
local function cleanName(n) return (n:match("^(.-)%s*%[") or n):match("^%s*(.-)%s*$") end
local function pressKey(key, holdDuration)
    holdDuration = holdDuration or 0.1
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        if holdDuration > 0 then task.wait(holdDuration) end
        VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end
local function dungeonAnchor()
    local hrp = getHRP(LP.Character) if not hrp then return end
    local bp = hrp:FindFirstChild("DungeonAnchorBP")
    if bp then bp.Position=hrp.Position return end
    bp = Instance.new("BodyPosition")
    bp.Name="DungeonAnchorBP"; bp.MaxForce=Vector3.new(9e9,9e9,9e9)
    bp.P=50000; bp.D=1000; bp.Position=hrp.Position; bp.Parent=hrp
end
local function dungeonRelease()
    local hrp = getHRP(LP.Character) if not hrp then return end
    local bp = hrp:FindFirstChild("DungeonAnchorBP")
    if bp then pcall(function() bp:Destroy() end) end
end
local function getClosestEnemy()
    local now = tick()
    if enemyCache.data and (now-enemyCache.lastUpdate) < enemyCache.updateInterval then
        local c = enemyCache.data
        if c and c.enemy and c.enemy.Parent and isAlive(c.enemy) then return c end
    end
    local hrp = getHRP(LP.Character)
    if not hrp then enemyCache.data=nil return nil end
    local ef = workspace:FindFirstChild("Enemies")
    if not ef then enemyCache.data=nil return nil end
    local cE, cP, cD = nil, nil, math.huge
    for _, e in ipairs(ef:GetChildren()) do
        if e and e.Parent and isAlive(e) then
            local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (hrp.Position-p.Position).Magnitude
                if d < cD then cD=d cE=e cP=p end
            end
        end
    end
    if cE then
        enemyCache.data = {enemy=cE, part=cP, dist=cD}
        enemyCache.lastUpdate = now
        return enemyCache.data
    end
    enemyCache.data = nil
    return nil
end

-- ===== ENTRANCE MAP =====
local EntranceMap = {
    ["Factory Staff"]=Vector3.new(-286.98,306.13,597.88), ["Swan Pirate"]=Vector3.new(-286.98,306.13,597.88),
    ["Raider"]=Vector3.new(-286.98,306.13,597.88), ["Mercenary"]=Vector3.new(-286.98,306.13,597.88),
    ["Vampire"]=Vector3.new(-6508.55,89.03,-132.83), ["Zombie"]=Vector3.new(-6508.55,89.03,-132.83),
    ["Ship Deckhand"]=Vector3.new(923.21,126.97,32852.83), ["Ship Engineer"]=Vector3.new(923.21,126.97,32852.83),
    ["Ship Officer"]=Vector3.new(923.21,126.97,32852.83), ["Ship Steward"]=Vector3.new(923.21,126.97,32852.83),
    ["Dragon Crew Warrior"]=Vector3.new(5669,1050,-325), ["Hydra Enforcer"]=Vector3.new(5669,1050,-325),
    ["Hydra Leader"]=Vector3.new(5669,1050,-325), ["Venomous Assailant"]=Vector3.new(5669,1050,-325),
    ["Ghost"]=Vector3.new(5669,1050,-325), ["Beautiful Pirate"]=Vector3.new(5669,1050,-325),
    ["Forest Pirate"]=Vector3.new(-12479,375,-7573), ["Mythological Pirate"]=Vector3.new(-12479,375,-7573),
    ["Musketeer Pirate"]=Vector3.new(-12479,375,-7573), ["Jungle Pirate"]=Vector3.new(-12479,375,-7573),
    ["Fishman Captain"]=Vector3.new(-12479,375,-7573), ["Fishman Raider"]=Vector3.new(-12479,375,-7573),
    ["Kilo Admiral"]=Vector3.new(5669,1100,-325), ["Marine Commodore"]=Vector3.new(5669,1100,-325),
    ["Marine Rear Admiral"]=Vector3.new(5669,1100,-325),
}

-- ===== LEVEL QUEST DATA =====
local LevelQuestData = {
    {minLv=0,maxLv=9,questPos=Vector3.new(1059,16,1550),questRemote={"StartQuest","BanditQuest1",1},mobName="Bandit",entranceVec=nil},
    {minLv=10,maxLv=14,questPos=Vector3.new(-1607,37,150),questRemote={"StartQuest","JungleQuest",1},mobName="Monkey",entranceVec=nil},
    {minLv=15,maxLv=29,questPos=Vector3.new(-1607,37,150),questRemote={"StartQuest","JungleQuest",2},mobName="Gorilla",entranceVec=nil},
    {minLv=30,maxLv=39,questPos=Vector3.new(-1144,5,3833),questRemote={"StartQuest","BuggyQuest1",1},mobName="Pirate",entranceVec=nil},
    {minLv=40,maxLv=59,questPos=Vector3.new(-1144,5,3833),questRemote={"StartQuest","BuggyQuest1",2},mobName="Brute",entranceVec=nil},
    {minLv=60,maxLv=74,questPos=Vector3.new(894,6,4396),questRemote={"StartQuest","DesertQuest",1},mobName="Desert Bandit",entranceVec=nil},
    {minLv=75,maxLv=89,questPos=Vector3.new(894,6,4396),questRemote={"StartQuest","DesertQuest",2},mobName="Desert Officer",entranceVec=nil},
    {minLv=90,maxLv=99,questPos=Vector3.new(1387,87,-1298),questRemote={"StartQuest","SnowQuest",1},mobName="Snow Bandit",entranceVec=nil},
    {minLv=100,maxLv=119,questPos=Vector3.new(1387,87,-1298),questRemote={"StartQuest","SnowQuest",2},mobName="Snowman",entranceVec=nil},
    {minLv=120,maxLv=149,questPos=Vector3.new(-5036,29,4327),questRemote={"StartQuest","MarineQuest2",1},mobName="Chief Petty Officer",entranceVec=nil},
    {minLv=150,maxLv=174,questPos=Vector3.new(-4840,718,-2611),questRemote={"StartQuest","SkyQuest",1},mobName="Sky Bandit",entranceVec=Vector3.new(-4607.82,874.39,-1667.56)},
    {minLv=175,maxLv=189,questPos=Vector3.new(-4840,718,-2611),questRemote={"StartQuest","SkyQuest",2},mobName="Dark Master",entranceVec=Vector3.new(-4607.82,874.39,-1667.56)},
    {minLv=190,maxLv=209,questPos=Vector3.new(5308,2,477),questRemote={"StartQuest","PrisonerQuest",1},mobName="Prisoner",entranceVec=nil},
    {minLv=210,maxLv=249,questPos=Vector3.new(5308,2,477),questRemote={"StartQuest","PrisonerQuest",2},mobName="Dangerous Prisoner",entranceVec=nil},
    {minLv=250,maxLv=274,questPos=Vector3.new(-1577,7,-2989),questRemote={"StartQuest","ColosseumQuest",1},mobName="Toga Warrior",entranceVec=nil},
    {minLv=275,maxLv=299,questPos=Vector3.new(-1577,7,-2989),questRemote={"StartQuest","ColosseumQuest",2},mobName="Gladiator",entranceVec=nil},
    {minLv=300,maxLv=324,questPos=Vector3.new(-5316,12,8518),questRemote={"StartQuest","MagmaQuest",1},mobName="Military Soldier",entranceVec=nil},
    {minLv=325,maxLv=374,questPos=Vector3.new(-5316,12,8518),questRemote={"StartQuest","MagmaQuest",2},mobName="Military Spy",entranceVec=nil},
    {minLv=375,maxLv=399,questPos=Vector3.new(61123,19,1566),questRemote={"StartQuest","FishmanQuest",1},mobName="Fishman Warrior",entranceVec=Vector3.new(61163.85,11.68,1819.78)},
    {minLv=400,maxLv=449,questPos=Vector3.new(61123,19,1566),questRemote={"StartQuest","FishmanQuest",2},mobName="Fishman Commando",entranceVec=Vector3.new(61163.85,11.68,1819.78)},
    {minLv=450,maxLv=474,questPos=Vector3.new(-4726,845,-1949),questRemote={"StartQuest","SkyExp1Quest",1},mobName="God's Guard",entranceVec=Vector3.new(-4607.82,874.39,-1667.56)},
    {minLv=475,maxLv=524,questPos=Vector3.new(-7861,5546,-381),questRemote={"StartQuest","SkyExp1Quest",2},mobName="Shanda",entranceVec=Vector3.new(-7894.62,5547.14,-380.29)},
    {minLv=525,maxLv=549,questPos=Vector3.new(-7903,5636,-1404),questRemote={"StartQuest","SkyExp2Quest",1},mobName="Royal Squad",entranceVec=nil},
    {minLv=550,maxLv=624,questPos=Vector3.new(-7903,5636,-1404),questRemote={"StartQuest","SkyExp2Quest",2},mobName="Royal Soldier",entranceVec=nil},
    {minLv=625,maxLv=649,questPos=Vector3.new(5257,39,4049),questRemote={"StartQuest","FountainQuest",1},mobName="Galley Pirate",entranceVec=nil},
    {minLv=650,maxLv=9999,questPos=Vector3.new(5257,39,4049),questRemote={"StartQuest","FountainQuest",2},mobName="Galley Captain",entranceVec=nil},
}

-- ===== SPAWN TRACKING =====
local enemySpawnMemory = {}
local spawnPartMemory  = {}
local persistentSpawnDB = {}
local _spawnCacheTime = 0
local _spawnCacheInterval = 0.2

local function recordPersistentSpawn(name, pos)
    if not name or name=="" or not pos then return end
    if not persistentSpawnDB[name] then persistentSpawnDB[name]={} end
    local key = math.round(pos.X)..","..math.round(pos.Z)
    for _, e in ipairs(persistentSpawnDB[name]) do
        if math.round(e.X)..","..math.round(e.Z)==key then return end
    end
    table.insert(persistentSpawnDB[name], pos)
end

local function trackSpawnParts()
    local now = tick()
    if now - _spawnCacheTime < _spawnCacheInterval then return end
    _spawnCacheTime = now
    spawnPartMemory = {}
    local wo = workspace:FindFirstChild("_WorldOrigin") if not wo then return end
    local sf = wo:FindFirstChild("EnemySpawns") if not sf then return end
    for _, s in ipairs(sf:GetChildren()) do
        local n = cleanName(s.Name) if n=="" then continue end
        local pos
        if s:IsA("BasePart") then pos=s.Position
        else local ok, p = pcall(function() return s:GetPivot().Position end) if ok then pos=p end end
        if pos then
            if not spawnPartMemory[n] then spawnPartMemory[n]={} end
            table.insert(spawnPartMemory[n], pos+Vector3.new(0,5,0))
            recordPersistentSpawn(n, pos+Vector3.new(0,5,0))
        end
    end
end

local function startSpawnWatcher()
    if Refs.spawnWatch then return end
    local ef = workspace:FindFirstChild("Enemies") if not ef then return end
    for _, e in ipairs(ef:GetChildren()) do
        if e and e.Parent then
            local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p and not enemySpawnMemory[e] then
                enemySpawnMemory[e]=p.Position
                recordPersistentSpawn(cleanName(e.Name), p.Position)
            end
        end
    end
    Refs.spawnWatch = ef.ChildAdded:Connect(function(e)
        task.wait(0.05)
        if not e or not e.Parent then return end
        local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
        if p then
            if not enemySpawnMemory[e] then
                enemySpawnMemory[e]=p.Position
                recordPersistentSpawn(cleanName(e.Name), p.Position)
            end
            e.AncestryChanged:Connect(function()
                if not e.Parent then enemySpawnMemory[e]=nil end
            end)
        end
    end)
end

local function getKnownSpawnPoints(name)
    local pts, seen = {}, {}
    local function addPt(pos)
        if not pos then return end
        local key = math.round(pos.X)..","..math.round(pos.Z)
        if not seen[key] then seen[key]=true table.insert(pts, pos) end
    end
    if persistentSpawnDB[name] then for _, p in ipairs(persistentSpawnDB[name]) do addPt(p) end end
    if spawnPartMemory[name] then for _, p in ipairs(spawnPartMemory[name]) do addPt(p) end end
    for e, pos in pairs(enemySpawnMemory) do
        if e and e.Parent and cleanName(e.Name)==name then addPt(pos+Vector3.new(0,5,0)) end
    end
    local ef = workspace:FindFirstChild("Enemies")
    if ef then
        for _, e in ipairs(ef:GetChildren()) do
            if e and e.Parent and cleanName(e.Name)==name then
                local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                if p then addPt(p.Position+Vector3.new(0,5,0)) end
            end
        end
    end
    return pts
end

task.spawn(function()
    task.wait(2) trackSpawnParts() startSpawnWatcher()
    task.wait(5) trackSpawnParts()
end)

local function getEnemyNames()
    local names, seen = {}, {}
    local ef = workspace:FindFirstChild("Enemies")
    if ef then
        for _, e in ipairs(ef:GetChildren()) do
            if e and e.Parent then
                local n = cleanName(e.Name)
                if n~="" and not seen[n] then seen[n]=true table.insert(names, n) end
            end
        end
    end
    local wo = workspace:FindFirstChild("_WorldOrigin")
    local sf = wo and wo:FindFirstChild("EnemySpawns")
    if sf then
        for _, s in ipairs(sf:GetChildren()) do
            local n = cleanName(s.Name)
            if n~="" and not seen[n] then seen[n]=true table.insert(names, n) end
        end
    end
    table.sort(names)
    return names
end

local function invoke(method, a1, a2, a3, a4, a5)
    if not RS:FindFirstChild("Remotes") or not RS.Remotes:FindFirstChild("CommF_") then return nil end
    local ok, result = pcall(function()
        return RS.Remotes.CommF_:InvokeServer(method, a1, a2, a3, a4, a5)
    end)
    return result
end

local function fireEntrance(targetPos)
    if not targetPos then return end
    local hrp = getHRP(LP.Character) if not hrp then return end
    if (hrp.Position-targetPos).Magnitude <= 1000 then return end
    local best, bestD = nil, math.huge
    for _, ep in pairs(EntranceMap) do
        local d = (ep-targetPos).Magnitude if d < bestD then bestD=d best=ep end
    end
    if best and bestD < (hrp.Position-targetPos).Magnitude-50 then
        invoke("requestEntrance", best) task.wait(0.8)
    end
end

local function fireEntranceForEnemy(name)
    if not name then return end
    local hrp = getHRP(LP.Character) if not hrp then return end
    local tgt = nil
    local sf = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if sf then
        for _, s in ipairs(sf:GetChildren()) do
            if cleanName(s.Name)==name then
                local p = s:IsA("BasePart") and s.Position or s:GetPivot().Position
                tgt = Vector3.new(p.X, p.Y, p.Z) break
            end
        end
    end
    if not tgt then return end
    if (hrp.Position-tgt).Magnitude <= 1000 then return end
    local best, bestD = nil, math.huge
    for _, ep in pairs(EntranceMap) do
        local d = (ep-tgt).Magnitude if d < bestD then bestD=d best=ep end
    end
    if best and bestD < (hrp.Position-tgt).Magnitude-50 then
        invoke("requestEntrance", best) task.wait(0.8)
        for _ = 1, 5 do
            hrp = getHRP(LP.Character) if not hrp then break end
            if (hrp.Position-tgt).Magnitude <= 1000 then break end
            invoke("requestEntrance", best) task.wait(1.2)
        end
    end
end

local playerOffsetCurrent = Vector3.new(0,35,0)
local function startPlayerOffsetLoop()
    task.spawn(function()
        while true do
            if S.PlayerOffsetMode=="random" then
                local r = S.PlayerOffsetRange
                playerOffsetCurrent = Vector3.new(math.random(-r,r), S.PlayerOffsetY, math.random(-r,r))
            end
            task.wait(S.PlayerOffsetInterval)
        end
    end)
end
local function getPlayerTarget(mobPos)
    local off = S.PlayerOffsetMode=="random" and playerOffsetCurrent or S.PlayerOffsetCustom
    return Vector3.new(mobPos.X+off.X, mobPos.Y+off.Y, mobPos.Z+off.Z)
end

local function enableNoclip()
    F.clip = false
    if Refs.noclip then return end
    Refs.noclip = RunService.Stepped:Connect(function()
        if F.clip then return end
        local c = LP.Character if not c then return end
        for _, child in pairs(c:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide then child.CanCollide=false end
        end
    end)
end
local function disableNoclip()
    F.clip = true
    if Refs.noclip then Refs.noclip:Disconnect() Refs.noclip=nil end
end

local function getWorldFruits()
    local fruits = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name
        if n:find("Fruit") or n=="Fruit " then
            if obj:IsA("Folder") or obj:IsA("Model") then
                for _, f in ipairs(obj:GetChildren()) do
                    if f and f.Parent and not S.FruitBlacklist[f] then
                        local pos = getPos(f) if pos then table.insert(fruits,{inst=f, position=pos}) end
                    end
                end
            elseif not S.FruitBlacklist[obj] then
                local pos = getPos(obj) if pos then table.insert(fruits,{inst=obj, position=pos}) end
            end
        end
    end
    return fruits
end
local function getClosestFruit()
    local hrp = getHRP(LP.Character) if not hrp then return nil end
    local cl, cd = nil, math.huge
    for _, f in ipairs(getWorldFruits()) do
        local d = (hrp.Position-f.position).Magnitude
        if d < cd then cd=d cl=f end
    end
    return cl
end
local function hasFruit() return getClosestFruit() ~= nil end

local function storeFruitInv()
    local function tryBag(c)
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and t.Name:find("Fruit") and not S.FruitBlacklist[t] then
                local ok = pcall(function() invoke("StoreFruit", t.Name:gsub(" Fruit$",""), t) end)
                if ok then S.FruitBlacklist[t]=true pcall(function() t:Destroy() end) end
                task.wait(0.3)
            end
        end
    end
    tryBag(LP.Backpack)
    local c = LP.Character if c then tryBag(c) end
end
local function processFruit(t)
    if S.FruitBlacklist[t] then return end
    S.FruitBlacklist[t] = true
    pcall(function() invoke("StoreFruit", t.Name:gsub(" Fruit$",""), t) end)
end

local function getNearbyEnemiesFiltered(range)
    local hrp = getHRP(LP.Character) if not hrp then return {} end
    local parts = {}
    local ef = workspace:FindFirstChild("Enemies")
    if ef then
        for _, e in ipairs(ef:GetChildren()) do
            if e and e.Parent and isAlive(e) then
                local p = getEHRP(e)
                if p and (hrp.Position-p.Position).Magnitude <= range then table.insert(parts, p) end
            end
        end
    end
    return parts
end

local function fireDamage(part)
    if not part or not part.Parent then return end
    local hrp = getHRP(LP.Character) if not hrp then return end
    if S.VIMClickEnabled then
        pcall(function()
            local vp = workspace.CurrentCamera.ViewportSize
            local rx = math.random(math.floor(vp.X*0.1), math.floor(vp.X*0.9))
            local ry = math.random(math.floor(vp.Y*0.1), math.floor(vp.Y*0.9))
            VU:CaptureController()
            VU:ClickButton1(Vector2.new(rx, ry))
        end)
    end
    local net = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
    if not net then return end
    local char = LP.Character
    local held = char and (function()
        for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then return t end end
    end)()
    if held then
        local lc = held:FindFirstChild("LeftClickRemote")
        if lc and lc:IsA("RemoteEvent") then
            pcall(function() lc:FireServer((part.Position-hrp.Position).Unit, 1) end) return
        end
    end
    local regAtk = net:FindFirstChild("RE/RegisterAttack")
    local regHit = net:FindFirstChild("RE/RegisterHit")
    if regAtk and regHit then
        pcall(function() regAtk:FireServer(0.01) regHit:FireServer(part, {}, "196f522a") end)
    end
end

-- ===== MOB DATA =====
local mobData = {}

local function releaseMob(e)
    if not e then return end
    local data = mobData[e] if not data then return end
    if data.bp then pcall(function() data.bp:Destroy() end) end
    local ehrp = getEHRP(e)
    if ehrp then
        pcall(function() ehrp.Anchored=false end)
        pcall(function() ehrp.AssemblyLinearVelocity=Vector3.zero end)
        pcall(function() ehrp.AssemblyAngularVelocity=Vector3.zero end)
    end
    local h = getHum(e) if h then pcall(function() h.PlatformStand=false end) end
    if e.Parent then
        for _, p in ipairs(e:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end
        end
    end
    mobData[e] = nil
end
local function cleanupMobs()
    local snap = {}
    for e in pairs(mobData) do table.insert(snap, e) end
    for _, e in ipairs(snap) do pcall(releaseMob, e) end
    mobData = {}
    pcall(function() collectgarbage() end)
end
local function startMobNoclip()
    if Refs.mobNoclip then return end
    local _noclipT = 0
    Refs.mobNoclip = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - _noclipT < 0.1 then return end
        _noclipT = now
        for e in pairs(mobData) do
            if e and e.Parent then
                for _, p in ipairs(e:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        pcall(function() p.CanCollide=false end)
                    end
                end
            end
        end
    end)
end
local function stopMobNoclip()
    if Refs.mobNoclip then Refs.mobNoclip:Disconnect() Refs.mobNoclip=nil end
end

-- ===== BRING MOB =====
local function startBringMob(targetMobName)
    S.BringMobTargetName = targetMobName
    if Tasks.bringMob then S.BringMobTargetName=targetMobName return end
    cleanupMobs() startMobNoclip()

    local function getAnchorPos()
        local cur = S.CurrentFarmTarget
        if cur and cur.Parent and isAlive(cur) then
            local p = getEHRP(cur)
            if p and p.Parent then return p.Position end
        end
        -- CurrentFarmTarget ไม่มี หรือตายแล้ว reset ทิ้ง
        if cur then S.CurrentFarmTarget = nil end

        local ef = workspace:FindFirstChild("Enemies")
        if not ef then return nil end
        local hrp = getHRP(LP.Character)
        if not hrp then return nil end
        local closest, closestDist = nil, math.huge
        for _, e in ipairs(ef:GetChildren()) do
            if e and e.Parent and isAlive(e) and not isPC(e) then
                if S.BringMobTargetName and cleanName(e.Name) ~= S.BringMobTargetName then continue end
                local p = getEHRP(e)
                if p then
                    local d = (hrp.Position - p.Position).Magnitude
                    if d < closestDist then closestDist=d closest=p end
                end
            end
        end
        return closest and closest.Position or nil
    end

    local pinConn = nil
    local _pinT = 0
    local function startPinLoop()
        if pinConn then pinConn:Disconnect() end
        pinConn = RunService.Heartbeat:Connect(function()
            local now = tick()
            if now - _pinT < 0.05 then return end
            _pinT = now
            local ap = getAnchorPos() if not ap then return end
            for e, data in pairs(mobData) do
                if not e or not e.Parent or not isAlive(e) then
                    pcall(releaseMob, e)
                    continue
                end
                if not data or not data.bp or not data.bp.Parent then continue end
                pcall(function() data.bp.Position = ap + data.offset end)
            end
        end)
    end
    startPinLoop()

    Tasks.bringMob = task.spawn(function()
        local _loopT = 0
        while S.BringMobEnabled do
            task.wait(0.05)

            -- throttle หลัก
            local now = tick()
            if now - _loopT < 0.08 then continue end
            _loopT = now

            local ap = getAnchorPos()
            if not ap then task.wait(0.2) continue end

            local ef2 = workspace:FindFirstChild("Enemies")
            if not ef2 then task.wait(0.3) continue end

            -- cleanup mob ที่ตายหรือหายไปทุกรอบ
            local snap = {}
            for e in pairs(mobData) do table.insert(snap, e) end
            for _, e in ipairs(snap) do
                if not e or not e.Parent or not isAlive(e) then
                    pcall(releaseMob, e)
                end
            end

            -- refresh ap หลัง cleanup
            ap = getAnchorPos()
            if not ap then task.wait(0.2) continue end

            local cur = S.CurrentFarmTarget
            if cur and cur.Parent and isAlive(cur) then
                local tehrp = getEHRP(cur)
                if tehrp and not mobData[cur] then
                    local bp = Instance.new("BodyPosition")
                    bp.Name="BringMobBP"; bp.MaxForce=Vector3.new(1e9,1e9,1e9)
                    bp.P=250000; bp.D=4000; bp.Position=ap
                    pcall(function() bp.Parent=tehrp end)
                    pcall(function() local h=getHum(cur) if h then h.PlatformStand=true end end)
                    pcall(function() for _,p in ipairs(cur:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
                    mobData[cur]={bp=bp, arrived=true, offset=Vector3.zero, stuckTime=0, lastPos=tehrp.Position}
                end
            end

            local pulling = 0
            for e in pairs(mobData) do if e~=cur then pulling=pulling+1 end end

            for _, e in ipairs(ef2:GetChildren()) do
                if not S.BringMobEnabled then break end
                if e==cur or not e or not e.Parent or isPC(e) or not isAlive(e) then continue end

                local filter = S.BringMobTargetName
                if filter and cleanName(e.Name)~=filter then
                    if mobData[e] then pcall(releaseMob,e) end
                    continue
                end

                local ehrp = getEHRP(e) if not ehrp then continue end

                -- ถ้าอยู่ไกลเกินไปให้ปล่อย
                if (ap-ehrp.Position).Magnitude > S.BringMobMaxDistance then
                    if mobData[e] then pcall(releaseMob,e) end
                    continue
                end

                if not mobData[e] then
                    if pulling >= S.BringMobMaxBatch then continue end
                    local off
                    if S.BringMobOffsetMode=="custom" then off=S.BringMobCustomOffset
                    else local r=4 off=Vector3.new(math.random(-r,r),0,math.random(-r,r)) end
                    local bp = Instance.new("BodyPosition")
                    bp.Name="BringMobBP"; bp.MaxForce=Vector3.new(1e9,1e9,1e9)
                    bp.P=60000; bp.D=2000; bp.Position=ap+off
                    pcall(function() bp.Parent=ehrp end)
                    pcall(function() local h=getHum(e) if h then h.PlatformStand=true end end)
                    pcall(function() for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
                    mobData[e]={bp=bp, arrived=false, offset=off, stuckTime=0, lastPos=ehrp.Position}
                    pulling=pulling+1
                end

                local data = mobData[e]
                if not data or not data.bp or not data.bp.Parent then
                    pcall(releaseMob,e) continue
                end

                local tp = ap+data.offset
                local dist = (ehrp.Position-tp).Magnitude
                local moved = (ehrp.Position-data.lastPos).Magnitude
                data.lastPos = ehrp.Position

                if not data.arrived then
                    if moved < 0.05 then data.stuckTime=data.stuckTime+0.08 else data.stuckTime=0 end
                    if dist <= 10 then
                        pcall(function() data.bp:Destroy() end)
                        local fbp = Instance.new("BodyPosition")
                        fbp.Name="BringMobBP_Fixed"; fbp.MaxForce=Vector3.new(1e9,1e9,1e9)
                        fbp.P=250000; fbp.D=4000; fbp.Position=tp
                        pcall(function() fbp.Parent=ehrp end)
                        pcall(function() local h=getHum(e) if h then h.PlatformStand=true end end)
                        data.bp=fbp; data.arrived=true; data.stuckTime=0
                    elseif data.stuckTime >= 2 then
                        -- mob ค้าง reset ใหม่
                        pcall(releaseMob, e)
                    end
                else
                    -- arrived แล้วแต่ bp หาย สร้างใหม่
                    if not data.bp or not data.bp.Parent then
                        local fbp = Instance.new("BodyPosition")
                        fbp.Name="BringMobBP_Fixed"; fbp.MaxForce=Vector3.new(1e9,1e9,1e9)
                        fbp.P=250000; fbp.D=4000; fbp.Position=tp
                        pcall(function() fbp.Parent=ehrp end)
                        pcall(function() local h=getHum(e) if h then h.PlatformStand=true end end)
                        data.bp=fbp
                    end
                    if dist > 20 then
                        data.arrived=false
                        pcall(function() data.bp.P=60000 end)
                    end
                end
            end
        end
        if pinConn then pinConn:Disconnect() pinConn=nil end
        stopMobNoclip() cleanupMobs() Tasks.bringMob=nil
    end)
end

local function stopBringMob()
    if F.cleaningUp then return end
    F.cleaningUp = true
    S.BringMobEnabled=false; S.BringMobTargetName=nil
    if Tasks.bringMob then task.cancel(Tasks.bringMob) Tasks.bringMob=nil end
    stopMobNoclip() cleanupMobs()
    if Refs.bringMobToggle then Refs.bringMobToggle:Set(false) end
    F.cleaningUp = false
end

-- ===== ELITE =====
local ELITE_NAMES     = {"Diablo","Urban","Deandre"}
local ELITE_QUEST_POS = Vector3.new(-5417,314,-2825)

local function findEliteEnemy(name)
    local ef = workspace:FindFirstChild("Enemies") if not ef then return nil end
    local hrp = getHRP(LP.Character)
    local cl, cd = nil, math.huge
    for _, e in ipairs(ef:GetChildren()) do
        if e and e.Parent and isAlive(e) then
            local en = cleanName(e.Name)
            if en==name or en:find(name,1,true) or name:find(en,1,true) then
                local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                if p then
                    local d = hrp and (hrp.Position-p.Position).Magnitude or 0
                    if d < cd then cd=d cl={enemy=e, part=p} end
                end
            end
        end
    end
    return cl
end

local function isQuestActive()
    local ok, v = pcall(function() return LP.PlayerGui.Main.Quest.Visible end)
    return ok and v==true
end

local function doEliteHunt()
    local hrp = getHRP(LP.Character) if not hrp then return end
    enableNoclip()
    if (hrp.Position-ELITE_QUEST_POS).Magnitude > 1000 then
        local best, bestD = nil, math.huge
        for _, ep in pairs(EntranceMap) do
            local d = (ep-ELITE_QUEST_POS).Magnitude
            if d < bestD then bestD=d best=ep end
        end
        if best then invoke("requestEntrance", best) task.wait(1.5) end
    end
    hrp = getHRP(LP.Character) if not hrp then return end
    local bv = makeBV(hrp, "EliteBV")
    local t0 = tick()
    while tick()-t0 < 20 do
        if not F.eliteEnabled then bv.Velocity=Vector3.zero break end
        if not isAlive(LP.Character) then bv.Velocity=Vector3.zero break end
        hrp = getHRP(LP.Character) if not hrp then break end
        local diff = ELITE_QUEST_POS-hrp.Position
        local d = diff.Magnitude
        if d < 8 then bv.Velocity=Vector3.zero break end
        bv.Velocity = diff.Unit*math.clamp(d*8,40,SPEED)
        task.wait(0.02)
    end
    destroyBV(bv)
    invoke("EliteHunter") task.wait(0.2)
    if not isQuestActive() then invoke("EliteHunter") task.wait(0.2) end
    local mobName = ""
    local ok, t = pcall(function() return LP.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text end)
    if ok and t and t~="" then
        mobName = t:match("Defeat%s+(.-)%s*%(") or t:match("Defeat%s+(.+)$") or ""
        mobName = mobName:match("^%s*(.-)%s*$") or ""
    end
    if mobName=="" then
        for _, name in ipairs(ELITE_NAMES) do
            if RS:FindFirstChild(name) then mobName=name break end
        end
    end
    if mobName=="" then return end
    notify("Auto Elite","Hunting: "..mobName, 4)
    local huntStart = tick()
    while F.eliteEnabled and tick()-huntStart < 300 do
        if not isAlive(LP.Character) then
            while not isAlive(LP.Character) and F.eliteEnabled do task.wait(0.5) end
            task.wait(1) continue
        end
        hrp = getHRP(LP.Character) if not hrp then break end
        if not isQuestActive() then notify("Auto Elite", mobName.." defeated!", 4) break end
        if not RS:FindFirstChild(mobName) then task.wait(1) continue end
        local target = findEliteEnemy(mobName)
        if not target then task.wait(0.5) continue end
        if (hrp.Position-target.part.Position).Magnitude > 1000 then
            fireEntrance(target.part.Position) task.wait(0.8)
            hrp = getHRP(LP.Character) if not hrp then continue end
        end
        hrp = getHRP(LP.Character) if not hrp then continue end
        local bv2 = makeBV(hrp, "EliteHuntBV")
        while F.eliteEnabled and target.enemy and target.enemy.Parent and isAlive(target.enemy) do
            if not isAlive(LP.Character) then bv2.Velocity=Vector3.zero break end
            if not isQuestActive() then bv2.Velocity=Vector3.zero break end
            hrp = getHRP(LP.Character) if not hrp then break end
            local p2 = target.enemy:FindFirstChild("HumanoidRootPart") or target.enemy:FindFirstChildWhichIsA("BasePart")
            if not p2 then break end
            local tp = getPlayerTarget(p2.Position)
            local d = (hrp.Position-tp).Magnitude
            if d < 8 then
                bv2.Velocity=Vector3.zero
                for _, pt in ipairs(getNearbyEnemiesFiltered(50)) do fireDamage(pt) end
            else
                bv2.Velocity=(tp-hrp.Position).Unit*math.clamp(d*8,30,SPEED)
            end
            task.wait(0.02)
        end
        destroyBV(bv2) task.wait(0.1)
    end
end

local function startAutoElite()
    if Tasks.elite then return end
    Tasks.elite = task.spawn(function()
        while F.eliteEnabled do
            local eliteFound = false
            for _, name in ipairs(ELITE_NAMES) do
                if RS:FindFirstChild(name) then eliteFound=true break end
            end
            if eliteFound then
                F.eliteInterrupt=true doEliteHunt() F.eliteInterrupt=false task.wait(1)
            else task.wait(3) end
        end
        Tasks.elite = nil
    end)
end
local function stopAutoElite()
    F.eliteEnabled=false; F.eliteInterrupt=false
    if Tasks.elite then task.cancel(Tasks.elite) Tasks.elite=nil end
end

local function startDamageAura()
    if Tasks.damageAura then return end
    Tasks.damageAura = task.spawn(function()
        while S.DamageAuraEnabled do
            local targets = getNearbyEnemiesFiltered(50)
            for i=#targets, 2, -1 do
                local j=math.random(i) targets[i],targets[j]=targets[j],targets[i]
            end
            for _, p in ipairs(targets) do
                if not S.DamageAuraEnabled then break end
                fireDamage(p) task.wait(0.02)
            end
            task.wait(0.05)
        end
        Tasks.damageAura = nil
    end)
end
local function stopDamageAura()
    S.DamageAuraEnabled=false
    if Tasks.damageAura then task.cancel(Tasks.damageAura) Tasks.damageAura=nil end
end

local function startAutoBuso()
    if Tasks.buso then return end
    Tasks.buso = task.spawn(function()
        while S.AutoBusoEnabled do
            local c = LP.Character
            if c and not c:FindFirstChild("HasBuso") then
                pcall(function() invoke("Buso") end) task.wait(0.3)
            end
            task.wait(0.5)
        end
        Tasks.buso = nil
    end)
end
local function stopAutoBuso()
    S.AutoBusoEnabled=false
    if Tasks.buso then task.cancel(Tasks.buso) Tasks.buso=nil end
end

local function startAutoKen()
    if Tasks.ken then return end
    Tasks.ken = task.spawn(function()
        while S.AutoKenEnabled do
            pcall(function() RS.Remotes.CommE:FireServer("Ken", true) end)
            task.wait(0.5)
        end
        Tasks.ken = nil
    end)
end
local function stopAutoKen()
    S.AutoKenEnabled=false
    if Tasks.ken then task.cancel(Tasks.ken) Tasks.ken=nil end
end

local function equipWeapon(wt)
    local c = LP.Character if not c then return end
    local function match(t) local tip=getTip(t) return tip and string.find(string.lower(tip), string.lower(wt)) end
    local tool = nil
    for _, t in ipairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and match(t) then tool=t break end end
    if not tool then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and match(t) then tool=t break end end end
    if tool then
        local h = getHum(c)
        if h then
            if tool.Parent==LP.Backpack then tool.Parent=c task.wait(0.1) end
            h:EquipTool(tool)
        end
    end
end
local function startAutoEquip()
    if Tasks.equip then return end
    Tasks.equip = task.spawn(function()
        while S.AutoEquipEnabled do
            local c = LP.Character
            local equipped = nil
            if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then equipped=t break end end end
            if not equipped then
                equipWeapon(S.SelectedWeaponType) task.wait(0.5)
            else
                local tip = getTip(equipped)
                if not tip or not string.find(string.lower(tip), string.lower(S.SelectedWeaponType)) then
                    equipped.Parent=LP.Backpack task.wait(0.2) equipWeapon(S.SelectedWeaponType)
                end
            end
            task.wait(1)
        end
        Tasks.equip = nil
    end)
end
local function stopAutoEquip()
    S.AutoEquipEnabled=false
    if Tasks.equip then task.cancel(Tasks.equip) Tasks.equip=nil end
end

local function grabFruit(fd)
    if not fd then return end
    local f = fd.inst if not f or not f.Parent or S.FruitBlacklist[f] then return end
    enableNoclip()
    local hrp = getHRP(LP.Character)
    if hrp and (hrp.Position-fd.position).Magnitude > 2000 then
        local best, bestD = nil, math.huge
        for _, ep in pairs(EntranceMap) do
            local d = (ep-fd.position).Magnitude if d < bestD then bestD=d best=ep end
        end
        if best then invoke("requestEntrance", best) task.wait(1.5) end
        hrp = getHRP(LP.Character)
    end
    if hrp then
        local bv = makeBV(hrp, "GrabFruitBV")
        local t0 = tick()
        while tick()-t0 < 10 do
            hrp = getHRP(LP.Character) if not hrp then break end
            local diff = fd.position-hrp.Position
            local d = diff.Magnitude
            if d < 3 then bv.Velocity=Vector3.zero break end
            bv.Velocity=diff.Unit*math.clamp(d*6,40,SPEED)
            task.wait(0.02)
        end
        destroyBV(bv)
    end
    S.FruitBlacklist[f] = true
    task.wait(0.8)
    if S.AutoStoreFruitEnabled then
        local tool = nil
        for _, t in ipairs(LP.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name:find("Fruit") and not S.FruitBlacklist[t] then tool=t break end
        end
        if not tool then
            local c = LP.Character if c then
                for _, t in ipairs(c:GetChildren()) do
                    if t:IsA("Tool") and t.Name:find("Fruit") and not S.FruitBlacklist[t] then tool=t break end
                end
            end
        end
        if tool then
            local h = getHum(LP.Character)
            if h and tool.Parent==LP.Backpack then h:EquipTool(tool) task.wait(0.4) end
            processFruit(tool)
        end
    end
end

local function doFruitCycle()
    if F.fruitGrabbing then return end
    F.fruitGrabbing = true
    if S.AutoStoreFruitEnabled then storeFruitInv() end
    enableNoclip()
    while true do
        local fr = getClosestFruit() if not fr then break end
        grabFruit(fr) task.wait(0.2)
    end
    F.fruitGrabbing = false
    task.wait(0.3)
end

local function startAutoGrabFruit()
    if Tasks.grabFruit then return end
    Tasks.grabFruit = task.spawn(function()
        while S.AutoGrabFruitEnabled do
            if not isAlive(LP.Character) then task.wait(2) continue end
            if S.AutoStoreFruitEnabled then storeFruitInv() end
            local fr = getClosestFruit()
            if fr then F.fruitGrabbing=true grabFruit(fr) F.fruitGrabbing=false
            else task.wait(1) end
            task.wait(0.3)
        end
        F.fruitGrabbing=false Tasks.grabFruit=nil
    end)
end
local function stopAutoGrabFruit()
    S.AutoGrabFruitEnabled=false; F.fruitGrabbing=false
    if Tasks.grabFruit then task.cancel(Tasks.grabFruit) Tasks.grabFruit=nil end
end

local function getRandSpawn()
    local sf = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if sf then
        local sp = sf:GetChildren()
        if #sp > 0 then
            local s = sp[math.random(1,#sp)]
            local pos
            if s:IsA("BasePart") then pos=s.Position
            else pcall(function() pos=s:GetPivot().Position end) end
            if pos then return pos+Vector3.new(0,50,0) end
        end
    end
end

local function startFarmAura()
    if Tasks.farmAura then return end
    F.farmAura = true
    Tasks.farmAura = task.spawn(function()
        local auraTargetPos = nil
        while F.farmAura and S.FarmAuraEnabled do
            while F.eliteInterrupt and F.farmAura do task.wait(0.5) end
            if not F.farmAura or not S.FarmAuraEnabled then break end
            while not isAlive(LP.Character) and F.farmAura do task.wait(0.5) end
            if not F.farmAura or not S.FarmAuraEnabled then break end
            if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then doFruitCycle() task.wait(0.3) continue end
            local hrp = getHRP(LP.Character) if not hrp then task.wait(0.5) continue end
            local cl = getClosestEnemy()
            if cl and cl.enemy then
                S.CurrentFarmTarget = cl.enemy
                local ep = cl.part
                if ep and (hrp.Position-ep.Position).Magnitude > 1000 then
                    fireEntrance(ep.Position) task.wait(0.8)
                    hrp = getHRP(LP.Character) if not hrp then continue end
                end
                hrp = getHRP(LP.Character) if not hrp then continue end
                local bv = makeBV(hrp, "FarmAuraBV")
                local bp = Instance.new("BodyPosition")
                bp.Name="FarmAuraBP"; bp.MaxForce=Vector3.new(9e9,9e9,9e9)
                bp.P=50000; bp.D=2500; bp.Parent=hrp
                local arrived = false
                while F.farmAura and S.FarmAuraEnabled do
                    while F.eliteInterrupt and F.farmAura do bv.Velocity=Vector3.zero; bp.MaxForce=Vector3.zero; task.wait(0.5) end
                    if not F.farmAura or not S.FarmAuraEnabled then break end
                    if not isAlive(LP.Character) then bv.Velocity=Vector3.zero; bp.MaxForce=Vector3.zero; break end
                    if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then bv.Velocity=Vector3.zero; bp.MaxForce=Vector3.zero; break end
                    hrp = getHRP(LP.Character) if not hrp then break end
                    local c2 = getClosestEnemy() if not c2 then break end
                    local tp = getPlayerTarget(c2.part.Position)
                    local dist = (hrp.Position-tp).Magnitude
                    if dist > 8 then
                        bv.Velocity=(tp-hrp.Position).Unit*math.clamp(dist*8,30,SPEED)
                        bp.MaxForce=Vector3.zero; arrived=false
                    else
                        bv.Velocity=Vector3.zero; bp.Position=tp; bp.MaxForce=Vector3.new(9e9,9e9,9e9)
                        if not arrived then
                            arrived=true
                            if S.BringMobEnabled and not Tasks.bringMob then startBringMob(nil) end
                        end
                    end
                    if arrived then for _, p in ipairs(getNearbyEnemiesFiltered(50)) do fireDamage(p) end end
                    task.wait(0.02)
                end
                destroyBV(bv); pcall(function() bp:Destroy() end)
            else
                if not auraTargetPos or (hrp.Position-auraTargetPos).Magnitude < 15 then
                    auraTargetPos = getRandSpawn()
                    if not auraTargetPos then task.wait(1) continue end
                    if (hrp.Position-auraTargetPos).Magnitude > 1000 then
                        fireEntrance(auraTargetPos) task.wait(0.8)
                        hrp = getHRP(LP.Character) if not hrp then continue end
                    end
                end
                hrp = getHRP(LP.Character) if not hrp then continue end
                local bv = makeBV(hrp, "FarmAuraBV")
                while F.farmAura and S.FarmAuraEnabled do
                    while F.eliteInterrupt and F.farmAura do bv.Velocity=Vector3.zero; task.wait(0.5) end
                    if not F.farmAura or not S.FarmAuraEnabled then break end
                    if not isAlive(LP.Character) then
                        bv.Velocity=Vector3.zero
                        while not isAlive(LP.Character) and Tasks.tyrant do task.wait(0.5) end
                        if not Tasks.tyrant then break end
                        task.wait(1)
                        enableNoclip()
                        break
                    end
                    if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then bv.Velocity=Vector3.zero; break end
                    hrp = getHRP(LP.Character) if not hrp then break end
                    local diff = auraTargetPos-hrp.Position
                    local d = diff.Magnitude
                    if d < 12 then bv.Velocity=Vector3.zero; break end
                    bv.Velocity=diff.Unit*math.clamp(d*6,40,SPEED)
                    task.wait(0.02)
                end
                local ws = tick()
                while F.farmAura and S.FarmAuraEnabled do
                    while F.eliteInterrupt and F.farmAura do task.wait(0.5) end
                    if not isAlive(LP.Character) then break end
                    if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then break end
                    if getClosestEnemy() then break end
                    if tick()-ws >= 25 then local np=getRandSpawn() if np then auraTargetPos=np end ws=tick() end
                    task.wait(0.2)
                end
                pcall(function()
                    local h2 = getHRP(LP.Character)
                    if h2 then local bv2=h2:FindFirstChild("FarmAuraBV") if bv2 then destroyBV(bv2) end end
                end)
                auraTargetPos = nil
            end
            task.wait(0.05)
        end
        Tasks.farmAura = nil
    end)
end

local function stopFarmAura()
    F.farmAura=false; S.FarmAuraEnabled=false
    if Tasks.farmAura then task.cancel(Tasks.farmAura) Tasks.farmAura=nil end
    local hrp = getHRP(LP.Character)
    if hrp then
        for _, n in ipairs({"FarmAuraBV","FarmAuraBP"}) do
            local o = hrp:FindFirstChild(n)
            if o then if n=="FarmAuraBV" then destroyBV(o) else pcall(function() o:Destroy() end) end end
        end
    end
    if S.BringMobEnabled then stopBringMob() end
end

local function isSelectedEnemy(e)
    if not e or not e.Parent then return false end
    local cn = cleanName(e.Name)
    for _, sel in ipairs(S.SelectedEnemyNames) do
        local cs = sel:gsub(" %*$","")
        if cn==cs or cn:find(cs,1,true) or cs:find(cn,1,true) then return true end
    end
    return false
end
local function findSelectedEnemy()
    local hrp = getHRP(LP.Character) if not hrp then return nil end
    local ef = workspace:FindFirstChild("Enemies") if not ef then return nil end
    local cl, cd = nil, math.huge
    for _, e in ipairs(ef:GetChildren()) do
        if e and e.Parent and isAlive(e) and isSelectedEnemy(e) then
            local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (hrp.Position-p.Position).Magnitude
                if d < cd then cd=d cl={enemy=e, part=p} end
            end
        end
    end
    return cl
end

local _fsSpawnCache = {}
local _fsSpawnCacheTime = 0
local function getSelectedSpawns()
    local now = tick()
    if now-_fsSpawnCacheTime < 0.2 then return _fsSpawnCache end
    _fsSpawnCacheTime = now
    trackSpawnParts()
    local pts, seen = {}, {}
    for _, sel in ipairs(S.SelectedEnemyNames) do
        local cs = sel:gsub(" %*$","")
        for _, pos in ipairs(getKnownSpawnPoints(cs)) do
            local key = tostring(math.round(pos.X))..","..tostring(math.round(pos.Z))
            if not seen[key] then seen[key]=true table.insert(pts, pos) end
        end
    end
    _fsSpawnCache = pts
    return pts
end

local function startFarmSelect()
    if Tasks.farmSelect then return end
    Tasks.farmSelect = task.spawn(function()
        for _, sel in ipairs(S.SelectedEnemyNames) do
            fireEntranceForEnemy(sel:gsub(" %*$","")) task.wait(0.2)
        end
        task.wait(1)
        local spIdx = 1
        local lastSelected = {}
        while S.FarmSelectEnabled do
            while F.eliteInterrupt and S.FarmSelectEnabled do task.wait(0.3) end
            if not S.FarmSelectEnabled then break end
            while not isAlive(LP.Character) and S.FarmSelectEnabled do task.wait(0.5) end
            if not S.FarmSelectEnabled then break end
            if #S.SelectedEnemyNames == 0 then task.wait(0.5) continue end
            local selChanged = #S.SelectedEnemyNames ~= #lastSelected
            if not selChanged then
                for i, v in ipairs(S.SelectedEnemyNames) do if lastSelected[i]~=v then selChanged=true break end end
            end
            if selChanged then
                lastSelected = table.clone(S.SelectedEnemyNames)
                spIdx = 1; lastNotifiedTarget = nil; _fsSpawnCacheTime = 0
                if Tasks.bringMob then cleanupMobs() end
            end
            if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then
                doFruitCycle() task.wait(0.3) continue
            end
            local hrp = getHRP(LP.Character) if not hrp then task.wait(0.5) continue end
            local target = findSelectedEnemy()
            if target then
                S.CurrentFarmTarget = target.enemy
                notifyOnce(target.enemy, "Farm Select", target.enemy.Name)
                local ep = target.part
                if ep and (hrp.Position-ep.Position).Magnitude > 1000 then
                    fireEntrance(ep.Position) task.wait(0.8)
                    hrp = getHRP(LP.Character) if not hrp then continue end
                end
                hrp = getHRP(LP.Character) if not hrp then continue end
                local bv = makeBV(hrp, "FarmSelectBV")
                local arrived = false
                while S.FarmSelectEnabled do
                    while F.eliteInterrupt and S.FarmSelectEnabled do bv.Velocity=Vector3.zero; task.wait(0.3) end
                    if not S.FarmSelectEnabled then break end
                    if not isAlive(LP.Character) then
                        bv.Velocity=Vector3.zero
                        while not isAlive(LP.Character) and Tasks.tyrant do task.wait(0.5) end
                        if not Tasks.tyrant then break end
                        task.wait(1)
                        enableNoclip()
                        break
                    end
                    if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then bv.Velocity=Vector3.zero; break end
                    hrp = getHRP(LP.Character) if not hrp then break end
                    if not target.enemy or not target.enemy.Parent or not isAlive(target.enemy) then break end
                    local selCh = #S.SelectedEnemyNames ~= #lastSelected
                    if not selCh then
                        for i, v in ipairs(S.SelectedEnemyNames) do if lastSelected[i]~=v then selCh=true break end end
                    end
                    if selCh then bv.Velocity=Vector3.zero; break end
                    local p = target.enemy:FindFirstChild("HumanoidRootPart") or target.enemy:FindFirstChildWhichIsA("BasePart")
                    if not p then break end
                    local tp = getPlayerTarget(p.Position)
                    local diff = tp-hrp.Position
                    local d = diff.Magnitude
                    if d < 8 then
                        bv.Velocity=Vector3.zero
                        if not arrived then
                            arrived=true
                            if S.BringMobEnabled and not Tasks.bringMob then startBringMob(nil) end
                        end
                        for _, pt in ipairs(getNearbyEnemiesFiltered(50)) do fireDamage(pt) end
                    else
                        bv.Velocity=diff.Unit*math.clamp(d*8,30,SPEED)
                        arrived=false
                    end
                    task.wait(0.02)
                end
                destroyBV(bv)
                S.CurrentFarmTarget = nil
            else
                local cached = getSelectedSpawns()
                if #cached==0 then task.wait(0.5) continue end
                if spIdx > #cached then spIdx=1 end
                local wp = cached[spIdx]
                hrp = getHRP(LP.Character) if not hrp then continue end
                if (hrp.Position-wp).Magnitude > 1000 then
                    fireEntrance(wp) task.wait(0.8)
                    hrp = getHRP(LP.Character) if not hrp then continue end
                end
                hrp = getHRP(LP.Character) if not hrp then continue end
                local bv = makeBV(hrp, "FarmSelectBV")
                local stuckTimer = 0
                local lastWPPos = hrp.Position
                while S.FarmSelectEnabled do
                    while F.eliteInterrupt and S.FarmSelectEnabled do bv.Velocity=Vector3.zero; task.wait(0.3) end
                    if not S.FarmSelectEnabled then break end
                    if not isAlive(LP.Character) then
                        bv.Velocity=Vector3.zero
                        while not isAlive(LP.Character) and Tasks.tyrant do task.wait(0.5) end
                        if not Tasks.tyrant then break end
                        task.wait(1)
                        enableNoclip()
                        break
                    end
                    if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then bv.Velocity=Vector3.zero; break end
                    hrp = getHRP(LP.Character) if not hrp then break end
                    if findSelectedEnemy() then bv.Velocity=Vector3.zero; break end
                    local selCh = #S.SelectedEnemyNames ~= #lastSelected
                    if not selCh then
                        for i, v in ipairs(S.SelectedEnemyNames) do if lastSelected[i]~=v then selCh=true break end end
                    end
                    if selCh then bv.Velocity=Vector3.zero; break end
                    local diff = wp-hrp.Position
                    local d = diff.Magnitude
                    if (hrp.Position-lastWPPos).Magnitude < 0.3 then
                        stuckTimer = stuckTimer+0.02
                        if stuckTimer >= 2 then
                            bv.Velocity=Vector3.zero
                            hrp.CFrame = hrp.CFrame*CFrame.new(math.random(-10,10),3,math.random(-10,10))
                            task.wait(0.15)
                            spIdx=(spIdx%#cached)+1; break
                        end
                    else stuckTimer=0 end
                    lastWPPos = hrp.Position
                    if d < 10 then
                        bv.Velocity=Vector3.zero
                        local waitT=0
                        while S.FarmSelectEnabled and waitT < 3 do
                            if findSelectedEnemy() or not isAlive(LP.Character) then break end
                            local refreshed = getSelectedSpawns()
                            if #refreshed > 0 then cached=refreshed end
                            task.wait(0.2); waitT=waitT+0.2
                        end
                        spIdx=(spIdx%#cached)+1; break
                    end
                    bv.Velocity=diff.Unit*math.clamp(d*6,40,SPEED)
                    task.wait(0.02)
                end
                destroyBV(bv)
                task.wait(0.05)
            end
        end
        S.CurrentFarmTarget=nil
        Tasks.farmSelect=nil
    end)
end

local function stopFarmSelect()
    S.FarmSelectEnabled=false
    if Tasks.farmSelect then task.cancel(Tasks.farmSelect) Tasks.farmSelect=nil end
    local h = getHRP(LP.Character)
    if h then local bv=h:FindFirstChild("FarmSelectBV") if bv then destroyBV(bv) end end
    S.CurrentFarmTarget=nil; lastNotifiedTarget=nil
    if S.BringMobEnabled then stopBringMob() end
end

local function refreshEnemyDropdown()
    if not Refs.enemyDropdown then return end
    local newList = getEnemyNames()
    if #newList==0 then newList={"(No enemies found)"} end
    pcall(function() Refs.enemyDropdown:Refresh(newList) end)
end

local function abandonQuest() invoke("AbandonQuest") task.wait(0.8) end
local function getQuestTitle()
    local ok, t = pcall(function() return LP.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text end)
    return ok and t~="" and t or nil
end
local function isCorrectQuest(mob)
    local t = getQuestTitle() if not t then return true end
    return t:lower():find(mob:lower(),1,true) ~= nil
end
local function getPlayerLevel()
    local ok, lv = pcall(function() return LP.Data.Level.Value end)
    return ok and lv or 0
end
local function getQuestForLevel(lv)
    for _, q in ipairs(LevelQuestData) do if lv>=q.minLv and lv<=q.maxLv then return q end end
    return nil
end
local function getCompanionQuest(qd)
    if not qd then return nil end
    for _, other in ipairs(LevelQuestData) do
        if other~=qd and other.questRemote[2]==qd.questRemote[2] then return other end
    end
    return nil
end
local function findEnemyByName(name)
    local hrp = getHRP(LP.Character) if not hrp then return nil end
    local ef = workspace:FindFirstChild("Enemies") if not ef then return nil end
    local cl, cd = nil, math.huge
    for _, e in ipairs(ef:GetChildren()) do
        if e and e.Parent and isAlive(e) and cleanName(e.Name)==name then
            local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (hrp.Position-p.Position).Magnitude
                if d < cd then cd=d cl={enemy=e, part=p} end
            end
        end
    end
    return cl
end

local function huntMob(mobName)
    S.CurrentQuestMobName = mobName
    if not S.AutoFarmLevelEnabled then return end
    if isQuestActive() then
        task.wait(0.3)
        if not isCorrectQuest(mobName) then abandonQuest() return end
    end
    local questEntranceVec = nil
    for _, qd in ipairs(LevelQuestData) do
        if qd.mobName==mobName then questEntranceVec=qd.entranceVec break end
    end
    local spIdx=1
    local hrp = getHRP(LP.Character) if not hrp then return end
    local bv = makeBV(hrp, "LevelFarmBV")
    local arrived=false; local currentTarget=nil
    local lastEntrance=0; local lockedTP=nil; local lockedMob=nil
    local function forceEntrance(targetPos)
        if not targetPos then return end
        if questEntranceVec then
            invoke("requestEntrance", questEntranceVec) task.wait(1.5)
            for _ = 1, 5 do
                local h = getHRP(LP.Character) if not h then break end
                if (h.Position-targetPos).Magnitude <= 1000 then break end
                invoke("requestEntrance", questEntranceVec) task.wait(1.2)
            end
            return
        end
        local best, bestD = nil, math.huge
        for _, ep in pairs(EntranceMap) do
            local d = (ep-targetPos).Magnitude if d < bestD then bestD=d best=ep end
        end
        if best then
            invoke("requestEntrance", best) task.wait(1.5)
            for _ = 1, 5 do
                local h = getHRP(LP.Character) if not h then break end
                if (h.Position-targetPos).Magnitude <= 1000 then break end
                invoke("requestEntrance", best) task.wait(1.2)
            end
        end
    end
    local function tryEntrance(targetPos)
        if not targetPos then return end
        local h = getHRP(LP.Character) if not h then return end
        if (h.Position-targetPos).Magnitude > 1000 and tick()-lastEntrance > 3 then
            bv.Velocity=Vector3.zero forceEntrance(targetPos) lastEntrance=tick() task.wait(0.5)
        end
    end
    local spawnPts = getKnownSpawnPoints(mobName)
    while S.AutoFarmLevelEnabled do
        while F.eliteInterrupt and S.AutoFarmLevelEnabled do
            pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.5)
        end
        if not S.AutoFarmLevelEnabled then break end
        task.wait(0.02)
        local curLv = getPlayerLevel()
        local curQd = getQuestForLevel(curLv)
        if curQd and curQd.mobName~=mobName then
            local companion = getCompanionQuest(curQd)
            if not (companion and companion.mobName==mobName) then
                pcall(function() bv.Velocity=Vector3.zero end) destroyBV(bv)
                S.CurrentFarmTarget=nil; currentTarget=nil return
            end
        end
        if not isAlive(LP.Character) then
            pcall(function() bv.Velocity=Vector3.zero end)
            while not isAlive(LP.Character) and S.AutoFarmLevelEnabled do task.wait(0.5) end
            if not S.AutoFarmLevelEnabled then break end
            task.wait(1.5)
            hrp = getHRP(LP.Character) if not hrp then break end
            local old = hrp:FindFirstChild("LevelFarmBV") if old then old:Destroy() end
            bv = Instance.new("BodyVelocity")
            bv.Name="LevelFarmBV"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
            arrived=false; currentTarget=nil; S.CurrentFarmTarget=nil; lockedTP=nil; lockedMob=nil; lastEntrance=0
            spawnPts = getKnownSpawnPoints(mobName)
            local targetPos = #spawnPts > 0 and spawnPts[1] or nil
            if targetPos then
                hrp = getHRP(LP.Character)
                if hrp and (hrp.Position-targetPos).Magnitude > 2000 then
                    forceEntrance(targetPos) hrp = getHRP(LP.Character) if not hrp then break end
                    local old2 = hrp:FindFirstChild("LevelFarmBV") if old2 then old2:Destroy() end
                    bv = Instance.new("BodyVelocity")
                    bv.Name="LevelFarmBV"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
                end
            end
            continue
        end
        if not S.AutoFarmLevelEnabled then break end
        if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then
            bv.Velocity=Vector3.zero
            while S.AutoFarmLevelEnabled and S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) do task.wait(0.3) end
            continue
        end
        if not isQuestActive() then break end
        if not isCorrectQuest(mobName) then abandonQuest() break end
        hrp = getHRP(LP.Character) if not hrp then task.wait(0.5) continue end
        local target = findEnemyByName(mobName)
        if target and target.enemy and target.enemy.Parent and isAlive(target.enemy) then
            local ep = target.part
            if not ep or not ep.Parent then
                arrived=false; currentTarget=nil; S.CurrentFarmTarget=nil; lockedTP=nil; lockedMob=nil
                bv.Velocity=Vector3.zero; continue
            end
            if currentTarget~=target.enemy then
                arrived=false; currentTarget=target.enemy; S.CurrentFarmTarget=target.enemy
                lockedTP=nil; lockedMob=nil
                if S.BringMobEnabled then cleanupMobs() end
            end
            tryEntrance(ep.Position) hrp = getHRP(LP.Character) if not hrp then continue end
            if not target.enemy or not target.enemy.Parent or not isAlive(target.enemy) then
                arrived=false; currentTarget=nil; S.CurrentFarmTarget=nil; lockedTP=nil; lockedMob=nil
                bv.Velocity=Vector3.zero; continue
            end
            local p2 = target.enemy:FindFirstChild("HumanoidRootPart") or target.enemy:FindFirstChildWhichIsA("BasePart")
            if not p2 then bv.Velocity=Vector3.zero; continue end
            local mobPos = p2.Position
            if not lockedTP or not lockedMob or (lockedMob-mobPos).Magnitude > 8 or arrived then
                lockedMob=mobPos; lockedTP=getPlayerTarget(mobPos)
            end
            hrp = getHRP(LP.Character) if not hrp then continue end
            local diff = lockedTP-hrp.Position
            local d = diff.Magnitude
            if d < 8 then
                bv.Velocity=Vector3.zero
                if not arrived then
                    arrived=true; S.CurrentFarmTarget=target.enemy; S.BringMobTargetName=mobName
                    if S.BringMobEnabled then
                        if Tasks.bringMob then S.BringMobTargetName=mobName
                        else startBringMob(mobName) end
                    end
                end
                lockedTP=nil; lockedMob=nil
                for _, pt in ipairs(getNearbyEnemiesFiltered(50)) do fireDamage(pt) end
            else
                arrived=false; bv.Velocity=diff.Unit*math.clamp(d*8,30,SPEED)
            end
        else
            arrived=false; lockedTP=nil; lockedMob=nil
            if currentTarget then
                currentTarget=nil; S.CurrentFarmTarget=nil
                if S.BringMobEnabled then cleanupMobs() end
            end
            local freshPts = getKnownSpawnPoints(mobName)
            if #freshPts > 0 then spawnPts=freshPts end
            if #spawnPts==0 then bv.Velocity=Vector3.zero; task.wait(0.5); continue end
            if spIdx > #spawnPts then spIdx=1 end
            local wp = spawnPts[spIdx]
            tryEntrance(wp) hrp = getHRP(LP.Character) if not hrp then continue end
            hrp = getHRP(LP.Character) if not hrp then continue end
            local breakOuter = false
            while S.AutoFarmLevelEnabled do
                while F.eliteInterrupt and S.AutoFarmLevelEnabled do bv.Velocity=Vector3.zero; task.wait(0.5) end
                if not isAlive(LP.Character) then bv.Velocity=Vector3.zero; breakOuter=true; break end
                if S.AutoGrabFruitEnabled and (hasFruit() or F.fruitGrabbing) then bv.Velocity=Vector3.zero; breakOuter=true; break end
                hrp = getHRP(LP.Character) if not hrp then breakOuter=true; break end
                if findEnemyByName(mobName) then bv.Velocity=Vector3.zero; break end
                if not isQuestActive() or not isCorrectQuest(mobName) then bv.Velocity=Vector3.zero; breakOuter=true; break end
                local diff = wp-hrp.Position
                local d = diff.Magnitude
                if d < 10 then
                    bv.Velocity=Vector3.zero
                    local waitT=0
                    while S.AutoFarmLevelEnabled and waitT < 1 do
                        if findEnemyByName(mobName) or not isAlive(LP.Character) then break end
                        task.wait(0.2); waitT=waitT+0.2
                    end
                    local refreshed = getKnownSpawnPoints(mobName)
                    if #refreshed > 0 then spawnPts=refreshed end
                    spIdx=(spIdx%math.max(#spawnPts,1))+1; break
                end
                bv.Velocity=diff.Unit*math.clamp(d*6,40,SPEED)
                task.wait(0.02)
            end
            if breakOuter then continue end
        end
    end
    pcall(function() bv.Velocity=Vector3.zero end) destroyBV(bv)
    S.CurrentFarmTarget=nil; currentTarget=nil
end

local function startAutoFarmLevel()
    if Tasks.farmLevel then return end
    Tasks.farmLevel = task.spawn(function()
        enableNoclip()
        local lastActiveQd=nil; local activeQd=nil
        local function ensureBV()
            local hrp = getHRP(LP.Character) if not hrp then return nil end
            local bv = hrp:FindFirstChild("LevelFarmBV")
            if not bv then
                bv=Instance.new("BodyVelocity")
                bv.Name="LevelFarmBV"; bv.MaxForce=Vector3.new(9e9,9e9,9e9)
                bv.Velocity=Vector3.zero; bv.Parent=hrp
            end
            return bv
        end
        local function tweenToQuestPos(questPos)
            local hrp = getHRP(LP.Character) if not hrp then return end
            local bv = ensureBV() if not bv then return end
            while S.AutoFarmLevelEnabled do
                while F.eliteInterrupt and S.AutoFarmLevelEnabled do bv.Velocity=Vector3.zero; task.wait(0.5) end
                if not isAlive(LP.Character) then break end
                hrp = getHRP(LP.Character) if not hrp then break end
                local diff = questPos-hrp.Position
                local d = diff.Magnitude
                if d < 5 then bv.Velocity=Vector3.zero; break end
                bv.Velocity=diff.Unit*math.clamp(d*6,40,SPEED)
                task.wait(0.02)
            end
        end
        local function acceptQuest(qd)
            local hrp = getHRP(LP.Character) if not hrp then return end
            if qd.entranceVec and (hrp.Position-qd.questPos).Magnitude > 1000 then
                invoke("requestEntrance", qd.entranceVec) task.wait(1)
            end
            tweenToQuestPos(qd.questPos) task.wait(0.3)
            local remote = qd.questRemote
            invoke(remote[1], remote[2], remote[3]) task.wait(0.5)
            if not isQuestActive() then invoke(remote[1], remote[2], remote[3]) task.wait(0.5) end
        end
        while S.AutoFarmLevelEnabled do
            while F.eliteInterrupt and S.AutoFarmLevelEnabled do task.wait(0.5) end
            if not S.AutoFarmLevelEnabled then break end
            while not isAlive(LP.Character) and S.AutoFarmLevelEnabled do task.wait(0.5) end
            if not S.AutoFarmLevelEnabled then break end
            local lv = getPlayerLevel()
            local qd = getQuestForLevel(lv)
            if not qd then S.AutoFarmLevelEnabled=false; break end
            if activeQd then
                local companion = getCompanionQuest(qd)
                local sameNPC = activeQd.questRemote[2]==qd.questRemote[2]
                local isCompanion = companion and activeQd.questRemote[2]==companion.questRemote[2]
                if not sameNPC and not isCompanion then activeQd=nil end
            end
            if not isQuestActive() then
                if S.DoubleQuestEnabled then
                    local companion = getCompanionQuest(qd)
                    if companion then
                        if activeQd==qd then activeQd=companion else activeQd=qd end
                    else activeQd=qd end
                else activeQd=qd end
                if lastActiveQd~=activeQd then
                    lastActiveQd=activeQd; S.CurrentQuestMobName=activeQd.mobName
                    S.BringMobTargetName=activeQd.mobName
                    if Tasks.bringMob then cleanupMobs() end
                end
                acceptQuest(activeQd) continue
            end
            local newQd = getQuestForLevel(getPlayerLevel())
            if newQd then
                local companion = getCompanionQuest(newQd)
                local sameNPC = newQd.questRemote[2]==qd.questRemote[2]
                local isCompanion = companion and newQd.questRemote[2]==companion.questRemote[2]
                if not sameNPC and not isCompanion then continue end
            end
            local curQd = activeQd or qd
            if isQuestActive() then
                task.wait(0.5)
                if not isCorrectQuest(curQd.mobName) then
                    abandonQuest() task.wait(0.5) acceptQuest(curQd)
                else huntMob(curQd.mobName) end
            end
            task.wait(0.3)
        end
        Tasks.farmLevel = nil
    end)
end
local function stopAutoFarmLevel()
    S.AutoFarmLevelEnabled=false; S.CurrentQuestMobName=nil
    if Tasks.farmLevel then task.cancel(Tasks.farmLevel) Tasks.farmLevel=nil end
    local hrp = getHRP(LP.Character)
    if hrp then local bv=hrp:FindFirstChild("LevelFarmBV") if bv then destroyBV(bv) end end
    S.CurrentFarmTarget=nil; stopBringMob()
    if Refs.bringMobToggle then Refs.bringMobToggle:Set(false) end
end

local function addStat(s)
    if s=="DemonFruit" then pcall(function() invoke("AddPoint","Demon Fruit",1) end)
    else invoke("AddPoint", s, 1) end
end
local function startStat(s)
    if Tasks.stat[s] then return end
    Tasks.stat[s] = task.spawn(function()
        while S.AutoStatEnabled[s] do addStat(s) task.wait(S.AutoStatDelay) end
        Tasks.stat[s] = nil
    end)
end
local function stopStat(s)
    if Tasks.stat[s] then task.cancel(Tasks.stat[s]) Tasks.stat[s]=nil end
end

local function getCurrentTeam()
    local playerTeam = LP.Team
    if playerTeam then return playerTeam.Name end
    local char = LP.Character
    if char then
        local tc = char:GetAttribute("Team") or (char:FindFirstChild("TeamColor") and char.TeamColor.Value)
        if tc=="Marines" or tc=="Pirates" then return tc end
    end
    return nil
end
local function setTeam(teamName)
    if getCurrentTeam()==teamName then return end
    local success = pcall(function() invoke("SetTeam", teamName) end)
    if success then task.wait(1.5) end
end

local REDEEM_CODES = {
    "EASTEREXP","LIGHTNINGABUSE","KITT_RESET","Sub2CaptainMaui",
    "SUB2GAMERROBOT_RESET1","kittgaming","Magicbus","JCWK",
    "Sub2Fer999","Enyu_is_Pro","Starcodeheo","Bluxxy",
    "BIGNEWS","THEGREATACE","FUDD10","fudd10_v2",
    "Sub2Daigrock","Sub2UncleKizaru","Axiore","TantaiGaming",
    "SUB2GAMERROBOT_EXP1","SUB2NOOBMASTER123","StrawHatMaine","Sub2OfficialNoobie"
}
local function redeemCode(code)
    return pcall(function() RS.Remotes.Redeem:InvokeServer(code) end)
end
local function redeemAllCodes()
    for _, code in ipairs(REDEEM_CODES) do redeemCode(code) task.wait(0.5) end
end

local function startAutoRandomFruit()
    if Tasks.randomFruit then return end
    Tasks.randomFruit = task.spawn(function()
        while S.AutoRandomFruitEnabled do
            local ok, result = pcall(function() return invoke("Cousin","CheckTime","DLCBoxData") end)
            local canBuy = true
            if ok and type(result)=="string" and result:find("%d") then
                canBuy=false; local waitSecs=0
                local h, m = result:match("(%d+):(%d+)")
                if h and m then waitSecs=tonumber(h)*3600+tonumber(m)*60 end
                if waitSecs <= 0 then
                    local mins=result:match("(%d+%.?%d*) min")
                    local hrs=result:match("(%d+%.?%d*) hour")
                    if hrs then waitSecs=math.floor(tonumber(hrs)*3600) end
                    if mins then waitSecs=waitSecs+math.floor(tonumber(mins)*60) end
                end
                if waitSecs > 0 then task.wait(waitSecs+2) else canBuy=true end
            end
            if canBuy and S.AutoRandomFruitEnabled then
                pcall(function() invoke("Cousin","Buy","DLCBoxData") end)
                task.wait(5)
            end
        end
        Tasks.randomFruit = nil
    end)
end
local function stopAutoRandomFruit()
    S.AutoRandomFruitEnabled=false
    if Tasks.randomFruit then task.cancel(Tasks.randomFruit) Tasks.randomFruit=nil end
end

local function startAutoAwakening()
    if Tasks.awakening then return end
    if not S.AutoAwakeningEnabled then return end
    Tasks.awakening = task.spawn(function()
        while S.AutoAwakeningEnabled do
            pcall(function()
                LP.Backpack:WaitForChild("Awakening", 3):WaitForChild("RemoteFunction", 3):InvokeServer(true)
            end)
            task.wait(0.1)
        end
        Tasks.awakening = nil
    end)
end
local function stopAutoAwakening()
    S.AutoAwakeningEnabled=false
    if Tasks.awakening then task.cancel(Tasks.awakening) Tasks.awakening=nil end
end

LP.CharacterAdded:Connect(function()
    if S.AutoAwakeningEnabled then
        if Tasks.awakening then task.cancel(Tasks.awakening) Tasks.awakening=nil end
        task.wait(1.5)
        startAutoAwakening()
    end
end)

local function startAutoRaceAbil()
    if Tasks.raceAbil then return end
    if not S.AutoRaceAbilEnabled then return end
    Tasks.raceAbil = task.spawn(function()
        while S.AutoRaceAbilEnabled do
            pcall(function()
                local remotes = RS:FindFirstChild("Remotes")
                local commE = remotes and remotes:FindFirstChild("CommE")
                if commE then commE:FireServer("ActivateAbility") end
            end)
            task.wait(0.5)
        end
        Tasks.raceAbil = nil
    end)
end
local function stopAutoRaceAbil()
    S.AutoRaceAbilEnabled=false
    if Tasks.raceAbil then task.cancel(Tasks.raceAbil) Tasks.raceAbil=nil end
end

local function startAutoStoreFruit()
    if Tasks.storeFruit then return end
    Tasks.storeFruit = task.spawn(function()
        while S.AutoStoreFruitEnabled do
            if not F.fruitGrabbing then storeFruitInv() end
            task.wait(3)
        end
        Tasks.storeFruit = nil
    end)
end
local function stopAutoStoreFruit()
    S.AutoStoreFruitEnabled=false
    if Tasks.storeFruit then task.cancel(Tasks.storeFruit) Tasks.storeFruit=nil end
end

local DUNGEON_CARD_NAMES = {"Melee","Sword","Fruit","Lifesteal","Gun","Defense","Fruit M1 Speed","Armor","HYPER!"}

local function startAutoRetry()
    if Tasks.autoRetry then return end
    Tasks.autoRetry = task.spawn(function()
        while F.autoRetry do
            local pg = LP.PlayerGui
            local retGui = pg and pg:FindFirstChild("ReturningToHubShortly")
            if retGui and retGui.Enabled then
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("DungeonShared",5):WaitForChild("ReturnToHub",5):FireServer()
                end)
                task.wait(3)
            else task.wait(0.3) end
        end
        Tasks.autoRetry = nil
    end)
end
local function stopAutoRetry()
    F.autoRetry=false
    if Tasks.autoRetry then task.cancel(Tasks.autoRetry) Tasks.autoRetry=nil end
end

local function isDungeonCardScreenVisible()
    local pg = LP.PlayerGui if not pg then return false end
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local f1 = gui:FindFirstChild("1")
            if f1 and f1:FindFirstChild("2") then return true end
        end
    end
    return false
end

local function autoPickDungeonCard()
    local pg = LP.PlayerGui if not pg then return end
    local function clickAtAbsolute(absPos, absSize)
        local cx=math.floor(absPos.X+absSize.X/2)
        local cy=math.floor(absPos.Y+absSize.Y/2)
        pcall(function() VU:CaptureController() VU:ClickButton1(Vector2.new(cx,cy)) end)
        pcall(function()
            local vp = workspace.CurrentCamera.ViewportSize
            local rx = math.random(math.floor(vp.X*0.1), math.floor(vp.X*0.9))
            local ry = math.random(math.floor(vp.Y*0.1), math.floor(vp.Y*0.9))
            VU:CaptureController()
            VU:ClickButton1(Vector2.new(rx, ry))
        end)
    end
    for _, cardName in ipairs(S.DungeonCardPriority) do
        for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local f1=gui:FindFirstChild("1")
                if f1 then
                    local f2=f1:FindFirstChild("2")
                    if f2 then
                        for _, child in ipairs(f2:GetDescendants()) do
                            if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text:find(cardName,1,true) then
                                local ok1,absPos=pcall(function() return child.AbsolutePosition end)
                                local ok2,absSize=pcall(function() return child.AbsoluteSize end)
                                if ok1 and ok2 then clickAtAbsolute(absPos,absSize) return end
                                local ok3,fPos=pcall(function() return f2.AbsolutePosition end)
                                local ok4,fSize=pcall(function() return f2.AbsoluteSize end)
                                if ok3 and ok4 then clickAtAbsolute(fPos,fSize) return end
                            end
                        end
                    end
                end
            end
        end
    end
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local f1=gui:FindFirstChild("1")
            if f1 then
                local f2=f1:FindFirstChild("2")
                if f2 then
                    local ok,absPos=pcall(function() return f2.AbsolutePosition end)
                    local ok2,absSize=pcall(function() return f2.AbsoluteSize end)
                    if ok and ok2 then clickAtAbsolute(absPos,absSize) return end
                end
            end
        end
    end
end

local function getDungeonEnemies()
    local ef = workspace:FindFirstChild("Enemies") if not ef then return {} end
    local list = {}
    for _, e in ipairs(ef:GetChildren()) do
        if e and e.Parent and not isPC(e) then
            if cleanName(e.Name)=="Blank Buddy" or cleanName(e.Name)=="Player" then continue end
            local isProp = (e.Name=="PropHitboxPlaceholder")
            if isAlive(e) then
                local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                if p then table.insert(list,{enemy=e, part=p, isProp=isProp}) end
            end
        end
    end
    return list
end

local function findDungeonProp()
    local ef = workspace:FindFirstChild("Enemies") if not ef then return nil end
    for _, e in ipairs(ef:GetChildren()) do
        if e and e.Parent and e.Name=="PropHitboxPlaceholder" then
            local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p then return {enemy=e, part=p, isProp=true} end
        end
    end
    return nil
end

local function findNearestExit()
    local hrp = getHRP(LP.Character) if not hrp then return nil end
    local map = workspace:FindFirstChild("Map") if not map then return nil end
    local dung = map:FindFirstChild("Dungeon") if not dung then return nil end
    local floors = dung:GetChildren()
    if #floors==0 then return nil end
    local currentFloor = floors[math.max(1,#floors-1)]
    local exitTP = currentFloor:FindFirstChild("ExitTeleporter")
    if not exitTP then return nil end
    local root = exitTP:FindFirstChild("Root")
    if root and root:IsA("BasePart") and root:FindFirstChild("TouchInterest") then
        return {obj=root, pos=root.Position}
    end
    for _, p in ipairs(exitTP:GetDescendants()) do
        if p:IsA("BasePart") and p:FindFirstChild("TouchInterest") then
            return {obj=p, pos=p.Position}
        end
    end
    return nil
end

local function startAutoDungeon()
    if Tasks.dungeon then return end
    S.AutoDungeonEnabled=true; saveSettings()
    Tasks.dungeon=task.spawn(function()
        enableNoclip()
        if not S.BringMobEnabled then
            S.BringMobEnabled=true
            if Refs.bringMobToggle then task.delay(0.1,function() Refs.bringMobToggle:Set(true) end) end
        end
        if not Tasks.bringMob then startMobNoclip(); startBringMob(nil) end
        local lastUsedExitObj=nil; local lastExitTime=0; local needsExitAfterDeath=false
        local function doRespawnRecovery()
            while not isAlive(LP.Character) and S.AutoDungeonEnabled do task.wait(0.5) end
            if not S.AutoDungeonEnabled then return false end
            task.wait(1.5); enableNoclip()
            local hrp=getHRP(LP.Character)
            if hrp then
                for _,n in ipairs({"DungeonFarmBV","DungeonExitBV"}) do
                    local o=hrp:FindFirstChild(n); if o then destroyBV(o) end
                end
            end
            return true
        end
        while S.AutoDungeonEnabled do
            while F.eliteInterrupt and S.AutoDungeonEnabled do task.wait(0.5) end
            if not S.AutoDungeonEnabled then break end
            if not isAlive(LP.Character) then
                needsExitAfterDeath=true
                if not doRespawnRecovery() then break end
            end
            if not getHRP(LP.Character) then task.wait(0.5); continue end
            if isDungeonCardScreenVisible() then autoPickDungeonCard(); task.wait(1); continue end
            if needsExitAfterDeath then
                needsExitAfterDeath=false
                for attempt=1,5 do
                    if not S.AutoDungeonEnabled then break end
                    if not isAlive(LP.Character) then if not doRespawnRecovery() then break end end
                    local exitInfo=findNearestExit(); if not exitInfo then break end
                    notify("Dungeon","Going to exit after death ("..attempt..")",3)
                    local hrp2=getHRP(LP.Character)
                    if hrp2 then
                        dungeonAnchor()
                        local bv2=makeBV(hrp2,"DungeonExitBV")
                        dungeonRelease()
                        local t0=tick()
                        local ok=false
                        while S.AutoDungeonEnabled and isAlive(LP.Character) and #getDungeonEnemies()==0 do
                            hrp2=getHRP(LP.Character) if not hrp2 then break end
                            local diff=exitInfo.pos-hrp2.Position
                            local d=diff.Magnitude
                            if d < 5 then dungeonAnchor(); destroyBV(bv2); task.wait(0.8); dungeonRelease(); ok=true; break end
                            if tick()-t0 > 15 then dungeonAnchor(); destroyBV(bv2); ok=true; break end
                            bv2.Velocity=diff.Unit*math.clamp(d*8,30,SPEED)
                            task.wait(0.02)
                        end
                        destroyBV(bv2)
                        if ok then break end
                    end
                    if not isAlive(LP.Character) then if not doRespawnRecovery() then break end end
                end
                enableNoclip()
                if S.BringMobEnabled and not Tasks.bringMob then startMobNoclip(); startBringMob(nil) end
                task.wait(0.3); continue
            end
            local enemies=getDungeonEnemies()
            if #enemies > 0 then
                lastUsedExitObj=nil
                local hrp=getHRP(LP.Character); if not hrp then task.wait(0.5); continue end
                local attackTarget=findDungeonProp()
                if not attackTarget then
                    local closest,closestD=nil,math.huge
                    for _,e in ipairs(enemies) do
                        if not e.isProp then
                            local d=(hrp.Position-e.part.Position).Magnitude
                            if d < closestD then closestD=d; closest=e end
                        elseif not attackTarget then attackTarget=e end
                    end
                    if not attackTarget then attackTarget=closest end
                end
                if attackTarget then
                    S.CurrentFarmTarget=attackTarget.enemy
                    dungeonRelease()
                    while S.AutoDungeonEnabled do
                        while F.eliteInterrupt and S.AutoDungeonEnabled do dungeonAnchor(); task.wait(0.5); dungeonRelease() end
                        if not S.AutoDungeonEnabled then break end
                        if isDungeonCardScreenVisible() then dungeonAnchor(); break end
                        if not isAlive(LP.Character) then dungeonAnchor(); needsExitAfterDeath=true; break end
                        hrp=getHRP(LP.Character); if not hrp then break end
                        if not attackTarget.enemy or not attackTarget.enemy.Parent or not isAlive(attackTarget.enemy) then dungeonAnchor(); break end
                        if not attackTarget.isProp then
                            local newProp=findDungeonProp()
                            if newProp and newProp.enemy~=attackTarget.enemy then dungeonAnchor(); break end
                        end
                        local p2=attackTarget.enemy:FindFirstChild("HumanoidRootPart") or attackTarget.enemy:FindFirstChildWhichIsA("BasePart")
                        if not p2 then dungeonAnchor(); break end
                        local tp=getPlayerTarget(p2.Position)
                        local d=(hrp.Position-tp).Magnitude
                        if d < 8 then
                            dungeonRelease()
                            for _,pt in ipairs(getNearbyEnemiesFiltered(50)) do fireDamage(pt) end
                            task.wait(0.05)
                        else
                            dungeonRelease()
                            local bv=makeBV(hrp,"DungeonFarmBV")
                            bv.Velocity=(tp-hrp.Position).Unit*math.clamp(d*8,32,SPEED)
                            task.wait(0.02)
                            pcall(function() bv.Velocity=Vector3.zero end)
                        end
                    end
                    S.CurrentFarmTarget=nil
                end
            else
                task.wait(0.3)
                if #getDungeonEnemies() > 0 or isDungeonCardScreenVisible() then continue end
                if S.BringMobEnabled then
                    cleanupMobs()
                    if Tasks.bringMob then task.cancel(Tasks.bringMob); Tasks.bringMob=nil end
                    stopMobNoclip()
                end
                local exitInfo=findNearestExit()
                if exitInfo and (exitInfo.obj==lastUsedExitObj or tick()-lastExitTime < 2) then exitInfo=nil end
                if exitInfo then
                    dungeonRelease()
                    local hrp=getHRP(LP.Character)
                    local ok=false
                    if hrp then
                        local bv=makeBV(hrp,"DungeonExitBV")
                        local t0=tick()
                        while S.AutoDungeonEnabled and isAlive(LP.Character) and not isDungeonCardScreenVisible() and #getDungeonEnemies()==0 do
                            hrp=getHRP(LP.Character) if not hrp then break end
                            local diff=exitInfo.pos-hrp.Position
                            local d=diff.Magnitude
                            if d < 5 then dungeonAnchor(); destroyBV(bv); task.wait(0.8); dungeonRelease(); ok=true; break end
                            if tick()-t0 > 15 then dungeonAnchor(); destroyBV(bv); ok=true; break end
                            bv.Velocity=diff.Unit*(d < 15 and math.clamp(d*2.5,8,28) or math.clamp(d*8,30,SPEED))
                            task.wait(0.02)
                        end
                        destroyBV(bv)
                    end
                    if ok then
                        lastUsedExitObj=exitInfo.obj; lastExitTime=tick()
                        enableNoclip(); task.wait(1.5)
                        local pollStart=tick()
                        while S.AutoDungeonEnabled and tick()-pollStart < 15 do
                            if isDungeonCardScreenVisible() then break end
                            if #getDungeonEnemies() > 0 then lastUsedExitObj=nil; break end
                            task.wait(0.1)
                        end
                    else
                        if not isAlive(LP.Character) then needsExitAfterDeath=true end
                    end
                else
                    local retryT=tick()
                    while S.AutoDungeonEnabled do
                        if tick()-retryT >= 5 then
                            pcall(function() RS:WaitForChild("DungeonShared"):WaitForChild("ReturnToHub"):FireServer() end)
                            retryT=tick()
                        end
                        if #getDungeonEnemies() > 0 or findNearestExit() then break end
                        task.wait(0.5)
                    end
                end
                if S.AutoDungeonEnabled and S.BringMobEnabled and not Tasks.bringMob then
                    startMobNoclip(); startBringMob(nil)
                end
                task.wait(0.3)
            end
        end
        dungeonRelease(); S.CurrentFarmTarget=nil
        if S.BringMobEnabled then
            cleanupMobs()
            if Tasks.bringMob then task.cancel(Tasks.bringMob); Tasks.bringMob=nil end
            stopMobNoclip()
        end
        Tasks.dungeon=nil
    end)
end
local function stopAutoDungeon()
    S.AutoDungeonEnabled=false
    if Tasks.dungeon then task.cancel(Tasks.dungeon); Tasks.dungeon=nil end
    dungeonRelease()
    local hrp=getHRP(LP.Character)
    if hrp then
        for _,n in ipairs({"DungeonFarmBV","DungeonExitBV"}) do
            local o=hrp:FindFirstChild(n); if o then destroyBV(o) end
        end
    end
    S.CurrentFarmTarget=nil
    if S.BringMobEnabled then stopBringMob() end
    if Refs.bringMobToggle then Refs.bringMobToggle:Set(false) end
    saveSettings()
end

-- ===== TYRANT =====
local TYRANT_MOBS = {"Isle Champion","Serpent Hunter","Skull Slayer","Sun-kissed Warrior"}
local TYRANT_START_POS = Vector3.new(-16256,153,1400)
local TYRANT_QUEST_NPC_POS = Vector3.new(-16666,106,1577)

local function findTyrantBossMob()
    local hrp = getHRP(LP.Character) if not hrp then return nil end
    local ef = workspace:FindFirstChild("Enemies") if not ef then return nil end
    local cl, cd = nil, math.huge
    for _, e in ipairs(ef:GetDescendants()) do
        if e and e.Parent and e:IsA("Model") and isAlive(e) then
            local eName = cleanName(e.Name)
            for _, mobName in ipairs(TYRANT_MOBS) do
                if eName==mobName or e.Name:find(mobName,1,true) then
                    local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                    if p then
                        local d = (hrp.Position-p.Position).Magnitude
                        if d < cd then cd=d cl={enemy=e, part=p} end
                    end break
                end
            end
        end
    end
    return cl
end
local function findTyrant()
    local ef = workspace:FindFirstChild("Enemies") if not ef then return nil end
    for _, e in ipairs(ef:GetDescendants()) do
        if e and e.Parent and e:IsA("Model") and isAlive(e) and e.Name:find("Tyrant of the Skies") then
            local p = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p then return {enemy=e, part=p} end
        end
    end
    return nil
end
local function getTyrantSpawnPoints()
    local pts, seen = {}, {}
    local function addPt(pos, name)
        if not pos then return end
        local key = math.round(pos.X)..","..math.round(pos.Z)
        if not seen[key] then seen[key]=true table.insert(pts,{pos=pos+Vector3.new(0,5,0), name=name or "?"}) end
    end
    trackSpawnParts()
    for _, mobName in ipairs(TYRANT_MOBS) do
        for _, pos in ipairs(getKnownSpawnPoints(mobName)) do addPt(pos, mobName) end
    end
    return pts
end
local function tyrantTweenTo(targetPos, bvName)
    local hrp = getHRP(LP.Character) if not hrp then return false end
    local bv = makeBV(hrp, bvName or "TyrantBV")
    while true do
        if not Tasks.tyrant then destroyBV(bv) return false end
        while F.eliteInterrupt and Tasks.tyrant do bv.Velocity=Vector3.zero; task.wait(0.5) end
        if not Tasks.tyrant then destroyBV(bv) return false end
        if not isAlive(LP.Character) then
            bv.Velocity=Vector3.zero
            while not isAlive(LP.Character) do if not Tasks.tyrant then destroyBV(bv) return false end task.wait(0.5) end
            task.wait(1) hrp=getHRP(LP.Character) if not hrp then destroyBV(bv) return false end
            local old=hrp:FindFirstChild(bvName or "TyrantBV") if old then old:Destroy() end
            bv=Instance.new("BodyVelocity")
            bv.Name=bvName or "TyrantBV"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
        end
        hrp=getHRP(LP.Character) if not hrp then destroyBV(bv) return false end
        local diff = targetPos-hrp.Position
        local d = diff.Magnitude
        if d < 10 then destroyBV(bv) return true end
        bv.Velocity=diff.Unit*math.clamp(d*8,40,SPEED)
        task.wait(0.02)
    end
end
local function goToStartPos()
    while true do
        if not Tasks.tyrant then return false end
        local hrp=getHRP(LP.Character)
        if hrp and (hrp.Position-TYRANT_START_POS).Magnitude > 1000 then invoke("requestEntrance",TYRANT_START_POS) task.wait(1.5) end
        if tyrantTweenTo(TYRANT_START_POS,"TyrantStartBV") then return true end
        if not Tasks.tyrant then return false end
        task.wait(0.5)
    end
end
local function allEyesActivated()
    local tiki = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("TikiOutpost")
    if not tiki then return false end
    local island=tiki:FindFirstChild("IslandModel") if not island then return false end
    local chunks=island:FindFirstChild("IslandChunks")
    local eChunk=chunks and chunks:FindFirstChild("E")
    local eyes={island:FindFirstChild("Eye1"),island:FindFirstChild("Eye2"),eChunk and eChunk:FindFirstChild("Eye3"),eChunk and eChunk:FindFirstChild("Eye4")}
    for _, eye in ipairs(eyes) do if not eye then return false end if eye.Transparency~=0 then return false end end
    return true
end

local function tyrantPhase1()
    if not goToStartPos() then return false end
    local spawnPts=getTyrantSpawnPoints(); local spIdx=1
    local hrp=getHRP(LP.Character) if not hrp then return false end
    local bv=makeBV(hrp,"TyrantBV")
    while not allEyesActivated() do
        if not Tasks.tyrant then bv.Velocity=Vector3.zero; break end
        while F.eliteInterrupt and Tasks.tyrant do bv.Velocity=Vector3.zero; task.wait(0.5) end
        if not Tasks.tyrant then bv.Velocity=Vector3.zero; break end
        if not isQuestActive() then bv.Velocity=Vector3.zero; break end
        if not isAlive(LP.Character) then
            bv.Velocity=Vector3.zero
            while not isAlive(LP.Character) do if not Tasks.tyrant then break end task.wait(0.5) end
            if not Tasks.tyrant then break end
            task.wait(3) hrp=getHRP(LP.Character) if not hrp then break end
            local old=hrp:FindFirstChild("TyrantBV") if old then old:Destroy() end
            bv=Instance.new("BodyVelocity"); bv.Name="TyrantBV"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
            tyrantTweenTo(TYRANT_START_POS,"TyrantRespawnBV")
            hrp=getHRP(LP.Character) if not hrp then break end
            local old2=hrp:FindFirstChild("TyrantBV") if old2 then old2:Destroy() end
            bv=Instance.new("BodyVelocity"); bv.Name="TyrantBV"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
        end
        local fresh=getTyrantSpawnPoints() if #fresh > 0 then spawnPts=fresh end
        local target=findTyrantBossMob()
        if target and target.enemy and target.enemy.Parent and isAlive(target.enemy) then
            S.CurrentFarmTarget=target.enemy
            if S.BringMobEnabled and not Tasks.bringMob then F.tyrantBring=true startBringMob(nil) end
            local arrived=false
            while not allEyesActivated() do
                if not Tasks.tyrant then bv.Velocity=Vector3.zero; break end
                while F.eliteInterrupt and Tasks.tyrant do bv.Velocity=Vector3.zero; task.wait(0.5) end
                if not Tasks.tyrant then bv.Velocity=Vector3.zero; break end
                if not isQuestActive() then bv.Velocity=Vector3.zero; break end
                if not isAlive(LP.Character) then
                    bv.Velocity=Vector3.zero
                    while not isAlive(LP.Character) and Tasks.tyrant do task.wait(0.5) end
                    if not Tasks.tyrant then break end
                    task.wait(1)
                    enableNoclip()
                    break
                end
                hrp=getHRP(LP.Character) if not hrp then break end
                if not target.enemy or not target.enemy.Parent or not isAlive(target.enemy) then break end
                local p2=target.enemy:FindFirstChild("HumanoidRootPart") or target.enemy:FindFirstChildWhichIsA("BasePart")
                if not p2 then break end
                local diff = getPlayerTarget(p2.Position)-hrp.Position
                local d = diff.Magnitude
                if d < 8 then
                    bv.Velocity=Vector3.zero
                    if not arrived then arrived=true; if S.BringMobEnabled then if Tasks.bringMob then S.BringMobTargetName=nil else F.tyrantBring=true startBringMob(nil) end end end
                    for _, pt in ipairs(getNearbyEnemiesFiltered(60)) do fireDamage(pt) end
                else arrived=false; bv.Velocity=diff.Unit*math.clamp(d*8,30,SPEED) end
                task.wait(0.02)
            end
            S.CurrentFarmTarget=nil
        else
            if #spawnPts==0 then
                local spawnWait=tick(); bv.Velocity=Vector3.zero
                while #spawnPts==0 do
                    if not Tasks.tyrant then break end; if not isQuestActive() then break end
                    task.wait(1); local fp=getTyrantSpawnPoints() if #fp > 0 then spawnPts=fp end
                    if tick()-spawnWait > 60 then break end
                end
                if #spawnPts==0 then continue end
            end
            if spIdx > #spawnPts then spIdx=1 end
            local wp=spawnPts[spIdx].pos
            while true do
                if not Tasks.tyrant then bv.Velocity=Vector3.zero; break end
                while F.eliteInterrupt and Tasks.tyrant do bv.Velocity=Vector3.zero; task.wait(0.5) end
                if not isQuestActive() then bv.Velocity=Vector3.zero; break end
                if not isAlive(LP.Character) then
                    bv.Velocity=Vector3.zero
                    while not isAlive(LP.Character) and Tasks.tyrant do task.wait(0.5) end
                    if not Tasks.tyrant then break end
                    task.wait(1)
                    enableNoclip()
                    break
                end
                if allEyesActivated() or findTyrantBossMob() then bv.Velocity=Vector3.zero; break end
                hrp=getHRP(LP.Character) if not hrp then break end
                local diff = wp-hrp.Position
                local d = diff.Magnitude
                if d < 10 then
                    bv.Velocity=Vector3.zero; local waitT=0
                    while waitT < 1.5 do
                        if not Tasks.tyrant or allEyesActivated() or findTyrantBossMob() or not isAlive(LP.Character) then break end
                        if not isQuestActive() then break end
                        local fp=getTyrantSpawnPoints() if #fp > 0 then spawnPts=fp end
                        task.wait(0.1); waitT=waitT+0.1
                    end
                    spIdx=(spIdx%#spawnPts)+1; break
                end
                bv.Velocity=diff.Unit*math.clamp(d*6,40,SPEED); task.wait(0.02)
            end
        end
    end
    destroyBV(bv)
    if F.tyrantBring then F.tyrantBring=false; cleanupMobs(); if Tasks.bringMob then task.cancel(Tasks.bringMob) Tasks.bringMob=nil end; stopMobNoclip() end
    S.CurrentFarmTarget=nil
    return Tasks.tyrant ~= nil
end

local function getGuitarTrees()
    local trees={}
    local tiki=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("TikiOutpost")
    if not tiki then return trees end
    local island=tiki:FindFirstChild("IslandModel")
    local chunks=island and island:FindFirstChild("IslandChunks")
    local dChunk=chunks and chunks:FindFirstChild("D")
    local arena=dChunk and dChunk:FindFirstChild("EagleBossArena")
    if not arena then return trees end
    local seen={}
    for _, child in ipairs(arena:GetChildren()) do
        if child:IsA("Model") and child.Name=="Tree" then
            local pos
            if child.PrimaryPart then pos=child.PrimaryPart.Position
            else local ok,p=pcall(function() return child:GetPivot().Position end) if ok then pos=p end end
            if pos then
                local key=math.round(pos.X)..","..math.round(pos.Z)
                if not seen[key] then seen[key]=true table.insert(trees,pos) end
            end
        end
    end
    return trees
end

local function tyrantPhase2()
    if not goToStartPos() then return false end
    local wasAutoEquip=S.AutoEquipEnabled
    if wasAutoEquip then S.AutoEquipEnabled=false stopAutoEquip() end
    local wasBringMob=S.BringMobEnabled
    if wasBringMob then S.BringMobEnabled=false; cleanupMobs(); if Tasks.bringMob then task.cancel(Tasks.bringMob) Tasks.bringMob=nil end; stopMobNoclip() end
    task.wait(0.5)
    local function equipGuitarNow()
        local char=LP.Character if not char then return false end
        local guitar=LP.Backpack:FindFirstChild("Skull Guitar") or char:FindFirstChild("Skull Guitar")
        if not guitar then return false end
        local h=getHum(char) if not h then return false end
        if guitar.Parent==LP.Backpack then guitar.Parent=char task.wait(0.15) end
        h:EquipTool(guitar) task.wait(0.4)
        return char:FindFirstChild("Skull Guitar") ~= nil
    end
    local function fireGuitarAt(treePos)
        local char=LP.Character if not char then return end
        local g=char:FindFirstChild("Skull Guitar")
        if not g then equipGuitarNow() char=LP.Character g=char and char:FindFirstChild("Skull Guitar") end
        if g then local re=g:FindFirstChild("RemoteEvent") if re then pcall(function() re:FireServer("TAP",treePos) end) end end
        pcall(function() invoke("GuitarActivate",treePos) end)
    end
    local function restoreState()
        if wasAutoEquip then S.AutoEquipEnabled=true startAutoEquip() end
        if wasBringMob then S.BringMobEnabled=true; startMobNoclip(); startBringMob(nil); if Refs.bringMobToggle then task.delay(0.1,function() Refs.bringMobToggle:Set(true) end) end end
    end
    if not equipGuitarNow() then restoreState() return Tasks.tyrant ~= nil end
    local trees=getGuitarTrees()
    if #trees==0 then restoreState() return Tasks.tyrant ~= nil end
    local hrp=getHRP(LP.Character) if not hrp then restoreState() return false end
    local bv=makeBV(hrp,"TyrantGuitarBV"); local tIdx=1
    while not findTyrant() do
        if not Tasks.tyrant then destroyBV(bv) break end
        while F.eliteInterrupt and Tasks.tyrant do bv.Velocity=Vector3.zero; task.wait(0.5) end
        if not Tasks.tyrant then destroyBV(bv) break end
        local freshTrees=getGuitarTrees() if #freshTrees > 0 then trees=freshTrees end
        if #trees==0 then task.wait(0.5) continue end
        if tIdx > #trees then tIdx=1 end
        local treePos=trees[tIdx]
        if not isAlive(LP.Character) then
            bv.Velocity=Vector3.zero
            while not isAlive(LP.Character) do if not Tasks.tyrant then destroyBV(bv) restoreState() return false end task.wait(0.5) end
            task.wait(3); equipGuitarNow()
            hrp=getHRP(LP.Character) if not hrp then break end
            local oldBV=hrp:FindFirstChild("TyrantGuitarBV") if oldBV then oldBV:Destroy() end
            bv=makeBV(hrp,"TyrantGuitarBV")
        end
        local char=LP.Character
        if char and not char:FindFirstChild("Skull Guitar") then bv.Velocity=Vector3.zero; equipGuitarNow() end
        hrp=getHRP(LP.Character) if not hrp then break end
        local reachedTree=false
        while not reachedTree do
            if not Tasks.tyrant or findTyrant() then bv.Velocity=Vector3.zero; break end
            while F.eliteInterrupt and Tasks.tyrant do bv.Velocity=Vector3.zero; task.wait(0.5) end
            if not isAlive(LP.Character) then
                bv.Velocity=Vector3.zero
                while not isAlive(LP.Character) and Tasks.tyrant do task.wait(0.5) end
                if not Tasks.tyrant then break end
                task.wait(1)
                enableNoclip()
                break
            end
            hrp=getHRP(LP.Character) if not hrp then break end
            local diff = treePos-hrp.Position
            local d = diff.Magnitude
            if d < 8 then bv.Velocity=Vector3.zero; reachedTree=true
            else bv.Velocity=diff.Unit*math.clamp(d*7,40,SPEED) end
            task.wait(0.02)
        end
        if not reachedTree then tIdx=(tIdx%#trees)+1; continue end
        if findTyrant() or not Tasks.tyrant then break end
        fireGuitarAt(treePos); task.wait(0.1); tIdx=(tIdx%#trees)+1
    end
    destroyBV(bv); restoreState()
    return Tasks.tyrant ~= nil
end

local function tyrantPhase3()
    local tyrant=findTyrant()
    if not tyrant then
        local waitStart=tick()
        while not findTyrant() do
            if not Tasks.tyrant then return false end
            if tick()-waitStart > 30 then return false end
            task.wait(0.3)
        end
        tyrant=findTyrant() if not tyrant then return false end
    end
    S.CurrentFarmTarget=tyrant.enemy
    if S.BringMobEnabled and not Tasks.bringMob then F.tyrantBring=true; S.BringMobTargetName=nil; startBringMob(nil) end
    local hrp=getHRP(LP.Character) if not hrp then return false end
    local bv=makeBV(hrp,"TyrantBV"); local arrived=false; local bossKilled=false
    while tyrant.enemy and tyrant.enemy.Parent and isAlive(tyrant.enemy) do
        if not Tasks.tyrant then bv.Velocity=Vector3.zero; break end
        while F.eliteInterrupt and Tasks.tyrant do bv.Velocity=Vector3.zero; task.wait(0.5) end
        if not Tasks.tyrant then bv.Velocity=Vector3.zero; break end
        if not isQuestActive() then bv.Velocity=Vector3.zero; break end
        if not isAlive(LP.Character) then
            bv.Velocity=Vector3.zero
            while not isAlive(LP.Character) do if not Tasks.tyrant then break end task.wait(0.5) end
            if not Tasks.tyrant then break end
            task.wait(3) hrp=getHRP(LP.Character) if not hrp then break end
            local old=hrp:FindFirstChild("TyrantBV") if old then old:Destroy() end
            bv=Instance.new("BodyVelocity"); bv.Name="TyrantBV"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
            arrived=false; tyrant=findTyrant() if not tyrant then break end
        end
        hrp=getHRP(LP.Character) if not hrp then break end
        local freshT=findTyrant()
        if freshT and freshT.enemy~=tyrant.enemy then tyrant=freshT; S.CurrentFarmTarget=tyrant.enemy; arrived=false end
        if not tyrant or not tyrant.enemy or not tyrant.enemy.Parent then break end
        local p2=tyrant.enemy:FindFirstChild("HumanoidRootPart") or tyrant.enemy:FindFirstChildWhichIsA("BasePart")
        if not p2 then break end
        local diff = getPlayerTarget(p2.Position)-hrp.Position
        local d = diff.Magnitude
        if d < 8 then
            bv.Velocity=Vector3.zero
            if not arrived then arrived=true; if S.BringMobEnabled then if Tasks.bringMob then S.BringMobTargetName=nil else F.tyrantBring=true startBringMob(nil) end end end
            for _, pt in ipairs(getNearbyEnemiesFiltered(80)) do fireDamage(pt) end
        else arrived=false; bv.Velocity=diff.Unit*math.clamp(d*8,30,SPEED) end
        task.wait(0.02)
    end
    if not findTyrant() and tyrant and tyrant.enemy and not isAlive(tyrant.enemy) then bossKilled=true end
    destroyBV(bv)
    if F.tyrantBring then F.tyrantBring=false; cleanupMobs(); if Tasks.bringMob then task.cancel(Tasks.bringMob) Tasks.bringMob=nil end; stopMobNoclip() end
    S.CurrentFarmTarget=nil
    return Tasks.tyrant~=nil, bossKilled
end

local function tweenToTyrantQuestNPC()
    local hrp=getHRP(LP.Character) if not hrp then return false end
    if (hrp.Position-TYRANT_QUEST_NPC_POS).Magnitude > 2000 then
        local best,bestD=nil,math.huge
        for _, ep in pairs(EntranceMap) do local d=(ep-TYRANT_QUEST_NPC_POS).Magnitude if d < bestD then bestD=d best=ep end end
        if best then
            invoke("requestEntrance",best)
            local waitStart=tick()
            while tick()-waitStart < 8 do
                task.wait(0.3); hrp=getHRP(LP.Character) if not hrp then return false end
                if (hrp.Position-TYRANT_QUEST_NPC_POS).Magnitude <= 2000 then break end
            end
            hrp=getHRP(LP.Character) if not hrp then return false end
            if (hrp.Position-TYRANT_QUEST_NPC_POS).Magnitude > 2000 then
                invoke("requestEntrance",best) task.wait(3) hrp=getHRP(LP.Character) if not hrp then return false end
            end
        end
    end
    local bv=makeBV(hrp,"TyrantQuestBV"); local t0=tick()
    while true do
        if not Tasks.tyrant then destroyBV(bv) return false end
        while F.eliteInterrupt and Tasks.tyrant do bv.Velocity=Vector3.zero; task.wait(0.5) end
        if not Tasks.tyrant then destroyBV(bv) return false end
        if not isAlive(LP.Character) then
            pcall(function() bv.Velocity=Vector3.zero end)
            while not isAlive(LP.Character) do if not Tasks.tyrant then destroyBV(bv) return false end task.wait(0.5) end
            task.wait(1) hrp=getHRP(LP.Character) if not hrp then destroyBV(bv) return false end
            local old=hrp:FindFirstChild("TyrantQuestBV") if old then old:Destroy() end
            bv=Instance.new("BodyVelocity"); bv.Name="TyrantQuestBV"; bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=Vector3.zero; bv.Parent=hrp
        end
        hrp=getHRP(LP.Character) if not hrp then destroyBV(bv) return false end
        local diff = TYRANT_QUEST_NPC_POS-hrp.Position
        local d = diff.Magnitude
        if d < 8 then destroyBV(bv) return true end
        if tick()-t0 > 30 then destroyBV(bv) return false end
        bv.Velocity=diff.Unit*math.clamp(d*8,40,SPEED)
        task.wait(0.02)
    end
end

local function acceptTyrantQuest(idx)
    pcall(function() RS.Remotes.CommF_:InvokeServer("StartQuest","TikiQuest3",idx) end)
    task.wait(0.1)
    if not isQuestActive() then pcall(function() RS.Remotes.CommF_:InvokeServer("StartQuest","TikiQuest3",idx) end) task.wait(0.1) end
end

local function startTyrantFarm()
    if Tasks.tyrant then return end
    Tasks.tyrant=true; F.tyrantBring=false
    Tasks.tyrant = task.spawn(function()
        enableNoclip()
        if S.BringMobEnabled and not Tasks.bringMob then F.tyrantBring=true startBringMob(nil) end
        local questIdx=1
        local function waitAndAcceptQuest()
            while F.eliteInterrupt and Tasks.tyrant do task.wait(0.5) end
            if not isQuestActive() then if tweenToTyrantQuestNPC() and Tasks.tyrant then acceptTyrantQuest(questIdx) end end
        end
        local function resumeAfterQuest()
            if not Tasks.tyrant then return false end
            local existingTyrant=findTyrant()
            if existingTyrant and existingTyrant.enemy and existingTyrant.enemy.Parent and isAlive(existingTyrant.enemy) then
                notify("Tyrant","Resuming boss fight after quest accepted",3)
                local p3ok, bossKilled=tyrantPhase3()
                if not p3ok or not Tasks.tyrant then return false end
                if bossKilled then questIdx=(questIdx==1) and 2 or 1; waitAndAcceptQuest(); if not Tasks.tyrant then return false end end
                return true
            end
            if not allEyesActivated() then return false end
            return false
        end
        while Tasks.tyrant do
            while F.eliteInterrupt and Tasks.tyrant do task.wait(0.5) end
            if not Tasks.tyrant then break end

            if not isAlive(LP.Character) then
                while not isAlive(LP.Character) and Tasks.tyrant do task.wait(0.5) end
                if not Tasks.tyrant then break end
                task.wait(1.5)
                enableNoclip()
                local hrp = getHRP(LP.Character)
                if hrp then
                    for _, n in ipairs({"TyrantBV","TyrantGuitarBV","TyrantStartBV","TyrantRespawnBV","TyrantQuestBV"}) do
                        local o = hrp:FindFirstChild(n) if o then destroyBV(o) end
                    end
                end
                continue
            end
            waitAndAcceptQuest(); if not Tasks.tyrant then break end
            if resumeAfterQuest() then continue end
            if not goToStartPos() then break end
            if not tyrantPhase1() or not Tasks.tyrant then break end
            if not isQuestActive() then questIdx=(questIdx==1) and 2 or 1; waitAndAcceptQuest(); if not Tasks.tyrant then break end; if resumeAfterQuest() then continue end; continue end
            if not tyrantPhase2() or not Tasks.tyrant then break end
            if not isQuestActive() then questIdx=(questIdx==1) and 2 or 1; waitAndAcceptQuest(); if not Tasks.tyrant then break end; if resumeAfterQuest() then continue end; continue end
            local tyrantBoss=findTyrant()
            if not tyrantBoss then
                local waitStart=tick()
                while not findTyrant() do
                    if not Tasks.tyrant then break end; if not isQuestActive() then break end
                    while F.eliteInterrupt and Tasks.tyrant do task.wait(0.5) end
                    task.wait(0.3); if tick()-waitStart > 120 then break end
                end
                tyrantBoss=findTyrant()
            end
            if not Tasks.tyrant then break end
            if not isQuestActive() then questIdx=(questIdx==1) and 2 or 1; waitAndAcceptQuest(); if not Tasks.tyrant then break end; if resumeAfterQuest() then continue end; continue end
            if tyrantBoss and tyrantBoss.enemy and tyrantBoss.enemy.Parent then
                if S.BringMobEnabled then if Tasks.bringMob then S.BringMobTargetName=nil else F.tyrantBring=true startBringMob(nil) end end
                local p3ok, bossKilled=tyrantPhase3()
                if not p3ok or not Tasks.tyrant then break end
                if bossKilled then questIdx=(questIdx==1) and 2 or 1; waitAndAcceptQuest(); if not Tasks.tyrant then break end; if resumeAfterQuest() then continue end; continue end
            end
            local qWait=tick()
            while isQuestActive() and Tasks.tyrant do task.wait(0.1); if tick()-qWait > 10 then break end end
            if not isQuestActive() then questIdx=(questIdx==1) and 2 or 1; waitAndAcceptQuest(); if not Tasks.tyrant then break end; if resumeAfterQuest() then continue end; continue end
            questIdx=(questIdx==1) and 2 or 1
        end
        if F.tyrantBring then F.tyrantBring=false; cleanupMobs(); if Tasks.bringMob then task.cancel(Tasks.bringMob) Tasks.bringMob=nil end; stopMobNoclip() end
        S.CurrentFarmTarget=nil; Tasks.tyrant=nil
    end)
end
local function stopTyrantFarm()
    if Tasks.tyrant then if type(Tasks.tyrant)=="thread" then task.cancel(Tasks.tyrant) end Tasks.tyrant=nil end
    if F.tyrantBring then F.tyrantBring=false; cleanupMobs(); if Tasks.bringMob then task.cancel(Tasks.bringMob) Tasks.bringMob=nil end; stopMobNoclip() end
    local hrp=getHRP(LP.Character)
    if hrp then
        for _, n in ipairs({"TyrantBV","TyrantGuitarBV","TyrantStartBV","TyrantRespawnBV","TyrantQuestBV"}) do
            local o=hrp:FindFirstChild(n) if o then destroyBV(o) end
        end
    end
    S.CurrentFarmTarget=nil; S.BringMobEnabled=false; stopBringMob()
    if Refs.bringMobToggle then Refs.bringMobToggle:Set(false) end
    saveSettings()
end

-- ===== AIM ASSIST =====
local aimConn = nil
local function startAimAssist()
    if aimConn then return end
    aimConn = RunService.Heartbeat:Connect(function()
        if not S.AimAssistEnabled then return end
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local target = getClosestEnemy()
        if not target or not target.part or not target.part.Parent then return end
        local targetPos = target.part.Position
        pcall(function()
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))
        end)
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos) end
        end)
    end)
end
local function stopAimAssist()
    S.AimAssistEnabled=false
    if aimConn then aimConn:Disconnect() aimConn=nil end
end

-- ===== AUTO SKILL =====
local function startAutoSkill()
    if Tasks.autoSkill then return end
    Tasks.autoSkill = task.spawn(function()
        while S.AutoSkill.Enabled do
            for key, data in pairs(S.AutoSkill.Keys) do
                if data.Enabled then
                    local now = tick()
                    if now-data.LastUsed >= data.Cooldown then
                        local shouldUse = true
                        if S.AimAssistEnabled then
                            local target = getClosestEnemy()
                            if not target or target.dist > 50 then shouldUse=false end
                        end
                        if shouldUse then
                            data.LastUsed=now
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
    S.AutoSkill.Enabled=false
    if Tasks.autoSkill then task.cancel(Tasks.autoSkill) Tasks.autoSkill=nil end
end

-- ===== UI =====
local Window = WindUI:CreateWindow({
    Title="Blox Fruit | By Index", Icon="solar:star-bold-duotone",
    Folder="MainFarm", NewElements=true,
    Topbar={Height=44, ButtonsType="Mac"},
    OpenButton={
        Title="Blox Fruit | By Index", Enabled=true, Draggable=true, OnlyMobile=false,
        StrokeThickness=0, CornerRadius=UDim.new(1,0),
        Color=ColorSequence.new(Color3.fromHex("#ff9f3d"), Color3.fromHex("#ff5c5c"))
    }
})

local AuraTab = Window:Tab({Title="Main", Icon="lucide:house"})

do
    local EliteS = AuraTab:Section({Title="Auto Elite Boss", Box=true, BoxBorder=true, Opened=true})
    Refs.elite = EliteS:Toggle({Title="Auto Elite", Value=S.AutoEliteEnabled, Callback=function(v)
        F.eliteEnabled=v; S.AutoEliteEnabled=v; saveSettings()
        if v then enableNoclip() startAutoElite() else stopAutoElite() end
    end})
    EliteS:Space()
end

do
    local LS = AuraTab:Section({Title="Auto Farm Level", Box=true, BoxBorder=true, Opened=true})
    LS:Toggle({Title="Auto Farm Level", Value=S.AutoFarmLevelEnabled, Callback=function(v)
        S.AutoFarmLevelEnabled=v; saveSettings()
        if v then
            enableNoclip(); startAutoFarmLevel(); S.BringMobEnabled=true
            if Refs.bringMobToggle then Refs.bringMobToggle:Set(true) end
            startBringMob(nil)
        else
            stopAutoFarmLevel(); stopBringMob()
            if Refs.bringMobToggle then Refs.bringMobToggle:Set(false) end
            if not S.FarmAuraEnabled and not S.FarmSelectEnabled then disableNoclip() end
        end
    end}) LS:Space()
    LS:Toggle({Title="Double Quest", Value=S.DoubleQuestEnabled, Callback=function(v)
        S.DoubleQuestEnabled=v; saveSettings()
    end}) LS:Space()
end

do
    local AS = AuraTab:Section({Title="Farm Aura", Box=true, BoxBorder=true, Opened=true})
    AS:Toggle({Title="Farm Aura", Value=S.FarmAuraEnabled, Callback=function(v)
        S.FarmAuraEnabled=v; saveSettings()
        if v then
            enableNoclip(); startFarmAura(); S.BringMobEnabled=true
            if Refs.bringMobToggle then Refs.bringMobToggle:Set(true) end
            startBringMob(nil)
        else
            stopFarmAura()
            if not S.FarmSelectEnabled and not S.AutoFarmLevelEnabled then disableNoclip() end
        end
    end}) AS:Space()
end

do
    local SS = AuraTab:Section({Title="Farm Select", Box=true, BoxBorder=true, Opened=true})
    local eList = getEnemyNames() if #eList==0 then eList={"(No enemies found)"} end
    Refs.enemyDropdown = SS:Dropdown({
        Title="Select Enemy", Values=eList, Value=nil, AllowNone=true, Multi=true,
        Callback=function(sel)
            S.SelectedEnemyNames=type(sel)=="table" and sel or (sel and {sel} or {})
            lastNotifiedTarget=nil; _fsSpawnCacheTime=0
        end
    })
    SS:Space()
    SS:Toggle({Title="Farm Selected Enemy", Value=false, Callback=function(v)
        S.FarmSelectEnabled=v; saveSettings()
        if v then
            if #S.SelectedEnemyNames==0 then S.FarmSelectEnabled=false return end
            enableNoclip(); startFarmSelect(); S.BringMobEnabled=true
            if Refs.bringMobToggle then Refs.bringMobToggle:Set(true) end
            startBringMob(nil)
        else
            stopFarmSelect()
            if not S.FarmAuraEnabled and not S.AutoFarmLevelEnabled then disableNoclip() end
        end
    end}) SS:Space()
    SS:Button({Title="Refresh Enemy List", Callback=function() refreshEnemyDropdown() end})
end

do
    local TyrantS = AuraTab:Section({Title="Tyrant of the Skies", Box=true, BoxBorder=true, Opened=true})
    TyrantS:Toggle({Title="Auto Tyrant Sky Boss", Value=false, Callback=function(v)
        if v then
            enableNoclip(); S.BringMobEnabled=true; startBringMob(nil); startTyrantFarm()
            task.delay(0.1, function() if Refs.bringMobToggle then Refs.bringMobToggle:Set(true) end end)
            saveSettings()
        else
            stopTyrantFarm()
            if not S.FarmAuraEnabled and not S.FarmSelectEnabled and not S.AutoFarmLevelEnabled then disableNoclip() end
        end
    end})
    TyrantS:Space()
end

do
    local DungeonS = AuraTab:Section({Title="Auto Dungeon", Box=true, BoxBorder=true, Opened=true})
    DungeonS:Toggle({Title="Auto Dungeon", Value=S.AutoDungeonEnabled, Callback=function(v)
        S.AutoDungeonEnabled=v; saveSettings()
        if v then enableNoclip() startAutoDungeon()
        else stopAutoDungeon(); if not S.FarmAuraEnabled and not S.FarmSelectEnabled and not S.AutoFarmLevelEnabled then disableNoclip() end end
    end}) DungeonS:Space()
    DungeonS:Toggle({Title="Auto Retry", Value=false, Callback=function(v)
        F.autoRetry=v; if v then startAutoRetry() else stopAutoRetry() end
    end}) DungeonS:Space()
    DungeonS:Dropdown({
        Title="Card Priority", Values=DUNGEON_CARD_NAMES,
        Value=#S.DungeonCardPriority > 0 and S.DungeonCardPriority or nil,
        AllowNone=true, Multi=true,
        Callback=function(sel)
            if type(sel)=="table" then S.DungeonCardPriority=sel
            elseif sel then S.DungeonCardPriority={sel}
            else S.DungeonCardPriority={} end
            saveSettings()
        end
    }) DungeonS:Space()
end

local LocalTab = Window:Tab({Title="Local Player", Icon="lucide:contact"})

do
    local LCS = LocalTab:Section({Title="Combat", Box=true, BoxBorder=true, Opened=true})
    LCS:Toggle({Title="Damage Aura", Value=S.DamageAuraEnabled, Callback=function(v)
        S.DamageAuraEnabled=v; saveSettings(); if v then startDamageAura() else stopDamageAura() end
    end}) LCS:Space()
    LCS:Toggle({Title="Auto Buso", Value=S.AutoBusoEnabled, Callback=function(v)
        S.AutoBusoEnabled=v; saveSettings(); if v then startAutoBuso() else stopAutoBuso() end
    end}) LCS:Space()
    LCS:Toggle({Title="Auto Ken", Value=S.AutoKenEnabled, Callback=function(v)
        S.AutoKenEnabled=v; saveSettings(); if v then startAutoKen() else stopAutoKen() end
    end}) LCS:Space()
    LCS:Toggle({Title="Auto Click (safe Damage Aura)", Value=S.VIMClickEnabled, Callback=function(v)
        S.VIMClickEnabled=v; saveSettings()
    end}) LCS:Space()
end

do
    local LEqS = LocalTab:Section({Title="Auto Equip", Box=true, BoxBorder=true, Opened=true})
    LEqS:Dropdown({
        Title="Weapon Type", Values={"Melee","Sword","Gun","Fruit"},
        Value=(function()
            local wTypes={"Melee","Sword","Gun","Fruit"}
            for i,w in ipairs(wTypes) do if w==S.SelectedWeaponType then return i end end
            return 1
        end)(),
        Callback=function(v) S.SelectedWeaponType=v; saveSettings(); if S.AutoEquipEnabled then equipWeapon(v) end
    end}) LEqS:Space()
    LEqS:Toggle({Title="Auto Equip", Value=S.AutoEquipEnabled, Callback=function(v)
        S.AutoEquipEnabled=v; saveSettings(); if v then startAutoEquip() else stopAutoEquip() end
    end}) LEqS:Space()
end

do
    local RaceS = LocalTab:Section({Title="Race / Awakening", Box=true, BoxBorder=true, Opened=true})
    RaceS:Toggle({Title="Auto V4 Awakening", Value=S.AutoAwakeningEnabled, Callback=function(v)
        S.AutoAwakeningEnabled=v; saveSettings()
        if v then stopAutoAwakening() S.AutoAwakeningEnabled=true startAutoAwakening() else stopAutoAwakening() end
    end}) RaceS:Space()
    RaceS:Toggle({Title="Auto V3 Race Ability", Value=S.AutoRaceAbilEnabled, Callback=function(v)
        S.AutoRaceAbilEnabled=v; saveSettings()
        if v then stopAutoRaceAbil() S.AutoRaceAbilEnabled=true startAutoRaceAbil() else stopAutoRaceAbil() end
    end}) RaceS:Space()
end

local FruitTab = Window:Tab({Title="Fruit", Icon="lucide:apple"})

do
    local FrGrabS = FruitTab:Section({Title="Auto Grab Fruit", Box=true, BoxBorder=true, Opened=true})
    FrGrabS:Toggle({Title="Auto Grab Fruit", Value=S.AutoGrabFruitEnabled, Callback=function(v)
        S.AutoGrabFruitEnabled=v; saveSettings(); if v then startAutoGrabFruit() else stopAutoGrabFruit() end
    end}) FrGrabS:Space()
end

do
    local FrStoreS = FruitTab:Section({Title="Auto Store Fruit", Box=true, BoxBorder=true, Opened=true})
    FrStoreS:Toggle({Title="Auto Store Fruit", Value=S.AutoStoreFruitEnabled, Callback=function(v)
        S.AutoStoreFruitEnabled=v; saveSettings(); if v then startAutoStoreFruit() else stopAutoStoreFruit() end
    end}) FrStoreS:Space()
end

do
    local RFrS = FruitTab:Section({Title="Auto Random Fruit", Box=true, BoxBorder=true, Opened=true})
    Refs.randomFruit = RFrS:Toggle({Title="Auto Random Fruit", Value=S.AutoRandomFruitEnabled, Callback=function(v)
        S.AutoRandomFruitEnabled=v; saveSettings(); if v then startAutoRandomFruit() else stopAutoRandomFruit() end
    end})
end

local StatTab = Window:Tab({Title="Auto Stat", Icon="lucide:chart-bar-increasing"})

do
    local STS = StatTab:Section({Title="Stat Points", Box=true, BoxBorder=true, Opened=true})
    for _, sName in ipairs({"Melee","Defense","Sword","Gun","Demon Fruit"}) do
        local key = sName=="Demon Fruit" and "DemonFruit" or sName
        STS:Toggle({Title=sName, Value=S.AutoStatEnabled[key], Callback=function(v)
            S.AutoStatEnabled[key]=v; saveSettings(); if v then startStat(key) else stopStat(key) end
        end}) STS:Space()
    end
    STS:Slider({Title="Delay (s)", Step=0.05, Value={Min=0.05, Max=2, Default=S.AutoStatDelay}, Callback=function(v)
        S.AutoStatDelay=v; saveSettings()
        for s2, en in pairs(S.AutoStatEnabled) do if en then stopStat(s2) startStat(s2) end end
    end})
end

local SkillTab = Window:Tab({Title="Auto Skill", Icon="solar:keyboard-bold-duotone"})

do
    local MainS = SkillTab:Section({Title="Auto Skill Settings", Box=true, BoxBorder=true, Opened=true})
    MainS:Toggle({
        Title="Enable Auto Skill", Value=S.AutoSkill.Enabled,
        Callback=function(v) S.AutoSkill.Enabled=v; if v then startAutoSkill() else stopAutoSkill() end; saveSettings() end
    }) MainS:Space()
    Refs.aimAssistToggle = MainS:Toggle({
        Title="Mob Aim Assist (Lock Camera & Character)", Value=S.AimAssistEnabled,
        Callback=function(v) S.AimAssistEnabled=v; if v then startAimAssist() else stopAimAssist() end; saveSettings() end
    }) MainS:Space()
    for _, key in ipairs({"Z","X","C","V","F"}) do
        local KeyS = SkillTab:Section({Title="Skill Key: "..key, Box=true, BoxBorder=true, Opened=false})
        KeyS:Toggle({Title="Enable "..key, Value=S.AutoSkill.Keys[key].Enabled,
            Callback=function(v) S.AutoSkill.Keys[key].Enabled=v; saveSettings() end})
        KeyS:Slider({Title="Hold Time (seconds)", Step=0.05, Value={Min=0.05, Max=2.0, Default=S.AutoSkill.Keys[key].HoldTime},
            Callback=function(v) S.AutoSkill.Keys[key].HoldTime=v; saveSettings() end})
        KeyS:Slider({Title="Cooldown (seconds)", Step=0.5, Value={Min=0.5, Max=10.0, Default=S.AutoSkill.Keys[key].Cooldown},
            Callback=function(v) S.AutoSkill.Keys[key].Cooldown=v; saveSettings() end})
    end
end

local SetTab = Window:Tab({Title="Settings", Icon="lucide:sliders-horizontal"})

do
    local TeamS = SetTab:Section({Title="Team", Box=true, BoxBorder=true, Opened=true})
    TeamS:Dropdown({
        Title="Select Team", Values={"Pirates","Marines"},
        Value=(S.SelectedTeam=="Marines") and 2 or 1,
        Callback=function(v) S.SelectedTeam=v; saveSettings(); setTeam(v) end
    }) TeamS:Space()
end

do
    local SpS = SetTab:Section({Title="Speed & Timing", Box=true, BoxBorder=true, Opened=true})
    SpS:Slider({Title="Tween Speed", Step=10, Value={Min=50, Max=600, Default=SPEED}, Callback=function(v)
        SPEED=v; saveSettings()
    end}) SpS:Space()
    SpS:Toggle({Title="Auto Jump", Value=S.AutoJumpEnabled, Callback=function(v)
        S.AutoJumpEnabled=v; saveSettings()
    end})
end

do
    local OffsetS = SetTab:Section({Title="Player Offset", Box=true, BoxBorder=true, Opened=true})
    OffsetS:Dropdown({Title="Offset Mode", Values={"Random","Custom"}, Value=S.PlayerOffsetMode=="custom" and 2 or 1, Callback=function(v)
        S.PlayerOffsetMode=(v=="Random") and "random" or "custom"; saveSettings()
    end}) OffsetS:Space()
    OffsetS:Slider({Title="Random Range", Step=1, Value={Min=1, Max=45, Default=S.PlayerOffsetRange}, Callback=function(v)
        S.PlayerOffsetRange=v; saveSettings()
    end}) OffsetS:Space()
    OffsetS:Slider({Title="Offset Y", Step=1, Value={Min=0, Max=100, Default=S.PlayerOffsetY}, Callback=function(v)
        S.PlayerOffsetY=v; saveSettings()
        S.PlayerOffsetCustom=Vector3.new(S.PlayerOffsetCustom.X, v, S.PlayerOffsetCustom.Z)
    end}) OffsetS:Space()
    OffsetS:Slider({Title="Randomize Interval", Step=0.05, Value={Min=0.05, Max=1, Default=S.PlayerOffsetInterval}, Callback=function(v)
        S.PlayerOffsetInterval=v; saveSettings()
    end}) OffsetS:Space()
    OffsetS:Slider({Title="Custom X", Step=1, Value={Min=-50, Max=50, Default=S.PlayerOffsetCustom.X}, Callback=function(v)
        S.PlayerOffsetCustom=Vector3.new(v, S.PlayerOffsetCustom.Y, S.PlayerOffsetCustom.Z); saveSettings()
    end}) OffsetS:Space()
    OffsetS:Slider({Title="Custom Y", Step=1, Value={Min=0, Max=100, Default=S.PlayerOffsetCustom.Y}, Callback=function(v)
        S.PlayerOffsetCustom=Vector3.new(S.PlayerOffsetCustom.X, v, S.PlayerOffsetCustom.Z); saveSettings()
    end}) OffsetS:Space()
    OffsetS:Slider({Title="Custom Z", Step=1, Value={Min=-50, Max=50, Default=S.PlayerOffsetCustom.Z}, Callback=function(v)
        S.PlayerOffsetCustom=Vector3.new(S.PlayerOffsetCustom.X, S.PlayerOffsetCustom.Y, v); saveSettings()
    end})
end

do
    local BringS = SetTab:Section({Title="Bring Mob", Box=true, BoxBorder=true, Opened=true})
    Refs.bringMobToggle = BringS:Toggle({Title="Bring Mob", Value=S.BringMobEnabled, Callback=function(v)
        S.BringMobEnabled=v; saveSettings()
        if v then
            if not S.FarmAuraEnabled and not S.FarmSelectEnabled and not S.AutoFarmLevelEnabled and not Tasks.tyrant and not S.AutoDungeonEnabled then
                S.BringMobEnabled=false if Refs.bringMobToggle then Refs.bringMobToggle:Set(false) end return
            end
            startBringMob(nil)
        else stopBringMob() end
    end}) BringS:Space()
    BringS:Slider({Title="Bring Distance", Step=50, Value={Min=100, Max=1500, Default=S.BringMobMaxDistance}, Callback=function(v)
        S.BringMobMaxDistance=v; saveSettings()
    end}) BringS:Space()
    BringS:Slider({Title="Max Mobs", Step=1, Value={Min=1, Max=10, Default=S.BringMobMaxBatch}, Callback=function(v)
        S.BringMobMaxBatch=v; saveSettings()
    end}) BringS:Space()
end

;(function()
    local fpsBoostEnabled = false
    local storedEffects   = {}
    local fpsBoostConn    = nil
    local fpsContainer    = nil
    local fpsV2Enabled    = false
    local fpsV2Conn       = nil
    local fpsCapEnabled   = false
    local currentFpsCap   = 120
    local fpsBoostMode    = "all"

    local function shouldRemove(child, mode)
        if child:IsA("ModuleScript") and child.Name == "TreeBreak" then return false end

        if mode == "DracoRace" then
            return child.Name:lower():find("draco") ~= nil
        elseif mode == "Death" then
            return child.Name:lower():find("death") ~= nil
        elseif mode == "DracoAndDeath" then
            return child.Name:lower():find("draco") ~= nil
                or child.Name:lower():find("death") ~= nil
        end
        return true
    end

    local function enableFpsBoost()
        if not fpsContainer then return end
        storedEffects = {}
        for _, child in ipairs(fpsContainer:GetChildren()) do
            if shouldRemove(child, fpsBoostMode) then
                table.insert(storedEffects, child:Clone())
                pcall(function() child:Destroy() end)
            end
        end
        if fpsBoostConn then fpsBoostConn:Disconnect() end
        fpsBoostConn = fpsContainer.ChildAdded:Connect(function(child)
            task.wait()
            if fpsBoostEnabled and shouldRemove(child, fpsBoostMode) then
                pcall(function() child:Destroy() end)
            end
        end)
    end

    local function disableFpsBoost()
        if fpsBoostConn then fpsBoostConn:Disconnect() fpsBoostConn=nil end
        if not fpsContainer then return end
        for _, clone in ipairs(storedEffects) do
            pcall(function() clone.Parent=fpsContainer end)
        end
        storedEffects = {}
    end

    local function applyV2Part(v)
        if v:IsA("BasePart") then
            v.CastShadow=false; v.Material=Enum.Material.Plastic; v.Reflectance=0
            v.BackSurface=Enum.SurfaceType.SmoothNoOutlines; v.BottomSurface=Enum.SurfaceType.SmoothNoOutlines
            v.FrontSurface=Enum.SurfaceType.SmoothNoOutlines; v.LeftSurface=Enum.SurfaceType.SmoothNoOutlines
            v.RightSurface=Enum.SurfaceType.SmoothNoOutlines; v.TopSurface=Enum.SurfaceType.SmoothNoOutlines
        elseif v:IsA("Decal") then v.Transparency=1; v.Texture=""
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime=NumberRange.new(0) end
    end

    local function enableFpsV2()
        local Lighting = game:GetService("Lighting")
        local Terrain  = workspace:FindFirstChildWhichIsA("Terrain")
        if Terrain then
            Terrain.WaterWaveSize=0; Terrain.WaterWaveSpeed=0
            Terrain.WaterReflectance=0; Terrain.WaterTransparency=1
        end
        Lighting.GlobalShadows=false; Lighting.FogEnd=9e9; Lighting.FogStart=9e9
        pcall(function() settings().Rendering.QualityLevel=1 end)
        for _, v in pairs(game:GetDescendants()) do pcall(function() applyV2Part(v) end) end
        for _, v in pairs(Lighting:GetDescendants()) do
            pcall(function() if v:IsA("PostEffect") then v.Enabled=false end end)
        end
        fpsV2Conn = workspace.DescendantAdded:Connect(function(child)
            if not fpsV2Enabled then return end
            local t = child.ClassName
            if t=="ForceField" or t=="Sparkles" or t=="Smoke" or t=="Fire" or t=="Beam" then
                RunService.Heartbeat:Wait()
                pcall(function() child:Destroy() end)
            elseif child:IsA("BasePart") then
                pcall(function() child.CastShadow=false end)
            end
        end)
    end

    local function disableFpsV2()
        if fpsV2Conn then fpsV2Conn:Disconnect() fpsV2Conn=nil end
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows=true; Lighting.FogEnd=100000; Lighting.FogStart=0
        pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end)
        for _, v in pairs(Lighting:GetDescendants()) do
            pcall(function() if v:IsA("PostEffect") then v.Enabled=true end end)
        end
    end

    local function applyFpsCap(cap)
        if setfpscap then pcall(function() setfpscap(cap) end) return end
        pcall(function() settings().Rendering.FrameRateManager=Enum.FramerateManagerMode.On end)
    end
    local function disableFpsCap()
        if setfpscap then pcall(function() setfpscap(0) end) return end
        pcall(function() settings().Rendering.FrameRateManager=Enum.FramerateManagerMode.Automatic end)
    end

    local FpsS = SetTab:Section({Title="FPS Boost", Box=true, BoxBorder=true, Opened=true})

    FpsS:Dropdown({
        Title="V1 Mode",
        Values={"All (lots of bugs)", "Minimal"},
        Value=1,
        Callback=function(v)
            if v=="All (lots of bugs)" then fpsBoostMode="all"
            elseif v=="Minimal" then fpsBoostMode="DracoAndDeath" end
            if fpsBoostEnabled and fpsContainer then
                disableFpsBoost()
                enableFpsBoost()
            end
        end
    }) FpsS:Space()

    FpsS:Toggle({
        Title="FPS Boost V1 (Clear Effects)", Value=false,
        Callback=function(v)
            fpsBoostEnabled=v
            if v then
                if not fpsContainer then
                    task.spawn(function()
                        local ok, c = pcall(function()
                            return RS:WaitForChild("Effect",10):WaitForChild("Container",10)
                        end)
                        if ok and c then fpsContainer=c if fpsBoostEnabled then enableFpsBoost() end
                        else fpsBoostEnabled=false end
                    end)
                else enableFpsBoost() end
            else disableFpsBoost() end
        end
    }) FpsS:Space()

    FpsS:Toggle({
        Title="FPS Boost V2 (Low Graphics)", Value=false,
        Callback=function(v) fpsV2Enabled=v if v then enableFpsV2() else disableFpsV2() end end
    }) FpsS:Space()

    FpsS:Toggle({
        Title="FPS Cap", Value=false,
        Callback=function(v) fpsCapEnabled=v if v then applyFpsCap(currentFpsCap) else disableFpsCap() end end
    }) FpsS:Space()

    FpsS:Slider({
        Title="FPS Cap Value", Step=5, Value={Min=5, Max=1000, Default=120},
        Callback=function(v)
            currentFpsCap=v
            if fpsCapEnabled and setfpscap then pcall(function() setfpscap(v) end) end
        end
    }) FpsS:Space()
end)()

do
    local ResetS = SetTab:Section({Title="Reset Settings", Box=true, BoxBorder=true, Opened=true})
    ResetS:Button({
        Title="Remove Saved Settings",
        Callback=function()
            local pg = LP:FindFirstChild("PlayerGui")
            if not pg then return end
            local oldDialog = pg:FindFirstChild("ConfirmDialog")
            if oldDialog then oldDialog:Destroy() end
            local dialogGui = Instance.new("ScreenGui")
            dialogGui.Name="ConfirmDialog"; dialogGui.ResetOnSpawn=false
            dialogGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; dialogGui.Parent=pg
            local overlay = Instance.new("Frame")
            overlay.Size=UDim2.new(1,0,1,0); overlay.BackgroundColor3=Color3.new(0,0,0)
            overlay.BackgroundTransparency=0.5; overlay.BorderSizePixel=0; overlay.Parent=dialogGui
            local box = Instance.new("Frame")
            box.Size=UDim2.new(0,320,0,160); box.Position=UDim2.new(0.5,-160,0.5,-80)
            box.BackgroundColor3=Color3.fromRGB(30,30,30); box.BorderSizePixel=0; box.Parent=overlay
            Instance.new("UICorner", box).CornerRadius=UDim.new(0,10)
            local title = Instance.new("TextLabel")
            title.Size=UDim2.new(1,0,0,40); title.Position=UDim2.new(0,0,0,0)
            title.BackgroundTransparency=1; title.Text="Remove Settings"
            title.TextColor3=Color3.new(1,1,1); title.TextSize=18
            title.Font=Enum.Font.SourceSansBold; title.Parent=box
            local msg = Instance.new("TextLabel")
            msg.Size=UDim2.new(1,-20,0,50); msg.Position=UDim2.new(0,10,0,45)
            msg.BackgroundTransparency=1; msg.Text="Delete all saved settings?\nTakes effect on next run."
            msg.TextColor3=Color3.fromRGB(200,200,200); msg.TextSize=15
            msg.Font=Enum.Font.SourceSans; msg.TextWrapped=true; msg.Parent=box
            local yesBtn = Instance.new("TextButton")
            yesBtn.Size=UDim2.new(0,120,0,36); yesBtn.Position=UDim2.new(0,20,0,110)
            yesBtn.BackgroundColor3=Color3.fromRGB(200,50,50); yesBtn.Text="Yes, Delete"
            yesBtn.TextColor3=Color3.new(1,1,1); yesBtn.TextSize=14
            yesBtn.Font=Enum.Font.SourceSansBold; yesBtn.BorderSizePixel=0; yesBtn.Parent=box
            Instance.new("UICorner", yesBtn).CornerRadius=UDim.new(0,6)
            local noBtn = Instance.new("TextButton")
            noBtn.Size=UDim2.new(0,120,0,36); noBtn.Position=UDim2.new(0,180,0,110)
            noBtn.BackgroundColor3=Color3.fromRGB(60,60,60); noBtn.Text="Cancel"
            noBtn.TextColor3=Color3.new(1,1,1); noBtn.TextSize=14
            noBtn.Font=Enum.Font.SourceSansBold; noBtn.BorderSizePixel=0; noBtn.Parent=box
            Instance.new("UICorner", noBtn).CornerRadius=UDim.new(0,6)
            yesBtn.MouseButton1Click:Connect(function()
                dialogGui:Destroy()
                pcall(function()
                    if isfolder(SETTINGS_FOLDER) then
                        local files = listfiles(SETTINGS_FOLDER)
                        for _, f in ipairs(files) do pcall(function() delfile(f) end) end
                        delfolder(SETTINGS_FOLDER)
                    end
                end)
                notify("Settings","Settings deleted. Takes effect on next run.",5)
            end)
            noBtn.MouseButton1Click:Connect(function() dialogGui:Destroy() end)
        end
    })
    ResetS:Space()
end

local RedeemTab = Window:Tab({Title="Redeem", Icon="solar:ticket-bold-duotone"})
do
    local RS2 = RedeemTab:Section({Title="Codes", Box=true, BoxBorder=true, Opened=true})
    RS2:Button({Title="Redeem All", Callback=function() task.spawn(redeemAllCodes) end}) RS2:Space()
    for _, code in ipairs(REDEEM_CODES) do
        RS2:Button({Title=code, Callback=function() redeemCode(code) end})
    end
end

-- ===== HIGHLIGHT =====
do
    local HL = {mobs={}, self=nil, name=nil, t=0}
    local _hlHBT = 0
    RunService.Heartbeat:Connect(function()
        local now = tick()
        -- self highlight ทุก 0.5 วิพอ ไม่ต้องทุก frame
        if now - _hlHBT >= 0.5 then
            _hlHBT = now
            if LP.Character and (not HL.self or not HL.self.Parent) then
                HL.self = Instance.new("Highlight")
                HL.self.Adornee = LP.Character
                HL.self.FillColor = Color3.fromRGB(40,160,255)
                HL.self.OutlineColor = Color3.fromRGB(120,220,255)
                HL.self.FillTransparency = 0.6
                HL.self.OutlineTransparency = 0
                HL.self.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                HL.self.Parent = workspace
            end
        end
        if now - HL.t < 1 then return end
        HL.t = now
        HL.name = nil
        if S.CurrentFarmTarget and S.CurrentFarmTarget.Parent then
            HL.name = cleanName(S.CurrentFarmTarget.Name)
        elseif S.BringMobTargetName and S.BringMobTargetName ~= "" then
            HL.name = S.BringMobTargetName
        elseif S.CurrentQuestMobName and S.CurrentQuestMobName ~= "" then
            HL.name = S.CurrentQuestMobName
        elseif S.SelectedEnemyNames[1] then
            HL.name = S.SelectedEnemyNames[1]:gsub(" %*$","")
        end
        for e, h in pairs(HL.mobs) do
            if e ~= "_name" and (not e or not e.Parent or not isAlive(e)) then
                pcall(function() h:Destroy() end)
                HL.mobs[e] = nil
            end
        end
        if HL.mobs._name ~= HL.name then
            for e, h in pairs(HL.mobs) do
                if e ~= "_name" then pcall(function() h:Destroy() end) end
                HL.mobs[e] = nil
            end
            HL.mobs._name = HL.name
        end
        if not HL.name then return end
        local ef = workspace:FindFirstChild("Enemies")
        if not ef then return end
        for _, e in ipairs(ef:GetChildren()) do
            if e and e.Parent and isAlive(e) and cleanName(e.Name)==HL.name and not HL.mobs[e] then
                local h = Instance.new("Highlight")
                h.Adornee=e; h.FillColor=Color3.fromRGB(255,60,40)
                h.OutlineColor=Color3.fromRGB(255,200,40)
                h.FillTransparency=0.4; h.OutlineTransparency=0
                h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent=workspace
                HL.mobs[e] = h
            end
        end
    end)
    LP.CharacterAdded:Connect(function()
        if HL.self then pcall(function() HL.self:Destroy() end) HL.self=nil end
        for e, h in pairs(HL.mobs) do
            if e ~= "_name" then pcall(function() h:Destroy() end) end
            HL.mobs[e]=nil
        end
    end)
end

-- ===== STARTUP =====
if S.AutoBusoEnabled then startAutoBuso() end
if S.AutoKenEnabled then startAutoKen() end
if S.DamageAuraEnabled then startDamageAura() end
if S.AutoEquipEnabled then startAutoEquip() end
for s2, en in pairs(S.AutoStatEnabled) do if en then startStat(s2) end end
if S.AutoGrabFruitEnabled then startAutoGrabFruit() end
if S.AutoStoreFruitEnabled then startAutoStoreFruit() end
if S.AutoRandomFruitEnabled then startAutoRandomFruit() end
if S.AutoSkill.Enabled then startAutoSkill() end
if S.AimAssistEnabled then startAimAssist() end

task.delay(0.5, function()
    if S.AutoAwakeningEnabled and not Tasks.awakening then startAutoAwakening() end
    if S.AutoRaceAbilEnabled and not Tasks.raceAbil then startAutoRaceAbil() end
    if S.AutoEliteEnabled then F.eliteEnabled=true; enableNoclip(); startAutoElite() end
end)

if S.AutoFarmLevelEnabled then
    enableNoclip(); startAutoFarmLevel(); S.BringMobEnabled=true
    if Refs.bringMobToggle then Refs.bringMobToggle:Set(true) end
end
if S.FarmAuraEnabled then
    enableNoclip(); startFarmAura(); S.BringMobEnabled=true
    startBringMob(nil); if Refs.bringMobToggle then Refs.bringMobToggle:Set(true) end
end
if S.AutoDungeonEnabled then enableNoclip() startAutoDungeon() end

startPlayerOffsetLoop()

task.spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.F24, false, game) task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.F24, false, game)
        end)
    end
end)

task.spawn(function() task.wait(1) setTeam(S.SelectedTeam) end)

LP.Idled:Connect(function()
    VU:CaptureController()
    VU:ClickButton2(Vector2.new())
end)

task.spawn(function()
    while true do
        task.wait(300)
        local snap = {}
        for e in pairs(mobData) do table.insert(snap, e) end
        for _, e in ipairs(snap) do
            if not e or not e.Parent or not isAlive(e) then
                pcall(releaseMob, e)
            end
        end
        for e in pairs(enemySpawnMemory) do
            if not e or not e.Parent then
                enemySpawnMemory[e] = nil
            end
        end
        pcall(function() collectgarbage() end)
    end
end)
