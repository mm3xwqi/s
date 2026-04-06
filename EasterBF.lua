local WindUI=loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local RunService,VIM,RS,Players=game:GetService("RunService"),game:GetService("VirtualInputManager"),game:GetService("ReplicatedStorage"),game:GetService("Players")
local LP=Players.LocalPlayer

_G.BringMobTargetName=nil
_G.AutoFarmEnabled,_G.QuestModeEnabled,_G.AutoJumpEnabled=false,false,true
_G.CurrentQuestMobName=nil
_G.ChestBlacklist,_G.ShardBlacklist,_G.FruitBlacklist={},{},{}
_G.ChestWaitTime,_G.FarmMode=0,"random"
_G.AutoEquipEnabled,_G.SelectedWeaponType=false,"Melee"
_G.FarmAuraEnabled,_G.FarmAuraHeight=false,35
_G.BringMobEnabled,_G.BringMobMaxDistance,_G.BringMobMaxBatch=false,500,6
_G.BringMobOffsetMode,_G.BringMobCustomOffset="random",Vector3.new(0,0,0)
_G.CurrentCircleIsland,_G.CurrentCircleIndex,_G.CurrentCircleRound=nil,1,1
_G.CurrentFarmTarget,_G.DamageAuraEnabled,_G.AutoBusoEnabled=nil,false,true
_G.FarmSelectEnabled,_G.SelectedEnemyNames=false,{}
_G.AutoGrabFruitEnabled,_G.AutoFarmLevelEnabled=false,false
_G.AutoStatDelay,_G.AutoStatEnabled=0.3,{Melee=false,Defense=false,Sword=false,Gun=false,DemonFruit=false}
_G.PlayerOffsetMode="random"
_G.PlayerOffsetCustom=Vector3.new(0,35,0)
_G.PlayerOffsetRange=8
_G.PlayerOffsetInterval=0.1

local SPEED,BRING_MOB_SPEED,lastNotifiedTarget=350,300,nil
local collectTargets

-- Save Settings
local SETTINGS_KEY = "EasterFarm_Settings"
local function saveSettings()
    local ok,svc=pcall(function() return game:GetService("DataStoreService") end)
    local data={
        FarmMode=_G.FarmMode,
        AutoJumpEnabled=_G.AutoJumpEnabled,
        ChestWaitTime=_G.ChestWaitTime,
        SelectedWeaponType=_G.SelectedWeaponType,
        AutoEquipEnabled=_G.AutoEquipEnabled,
        BringMobMaxDistance=_G.BringMobMaxDistance,
        BringMobMaxBatch=_G.BringMobMaxBatch,
        BringMobOffsetMode=_G.BringMobOffsetMode,
        PlayerOffsetMode=_G.PlayerOffsetMode,
        PlayerOffsetRange=_G.PlayerOffsetRange,
        PlayerOffsetInterval=_G.PlayerOffsetInterval,
        PlayerOffsetCustomX=_G.PlayerOffsetCustom.X,
        PlayerOffsetCustomY=_G.PlayerOffsetCustom.Y,
        PlayerOffsetCustomZ=_G.PlayerOffsetCustom.Z,
        AutoStatDelay=_G.AutoStatDelay,
        AutoStatMelee=_G.AutoStatEnabled.Melee,
        AutoStatDefense=_G.AutoStatEnabled.Defense,
        AutoStatSword=_G.AutoStatEnabled.Sword,
        AutoStatGun=_G.AutoStatEnabled.Gun,
        AutoStatDemonFruit=_G.AutoStatEnabled.DemonFruit,
        AutoBusoEnabled=_G.AutoBusoEnabled,
        DamageAuraEnabled=_G.DamageAuraEnabled,
        AutoGrabFruitEnabled=_G.AutoGrabFruitEnabled,
        AutoFarmLevelEnabled=_G.AutoFarmLevelEnabled,
        FarmAuraEnabled=_G.FarmAuraEnabled,
        BringMobEnabled=_G.BringMobEnabled,
        QuestModeEnabled=_G.QuestModeEnabled,
        SPEED=SPEED,
    }
    pcall(function() writefile(SETTINGS_KEY..".json", game:GetService("HttpService"):JSONEncode(data)) end)
end
local function loadSettings()
    local ok,content=pcall(function() return readfile(SETTINGS_KEY..".json") end)
    if not ok or not content then return {} end
    local ok2,data=pcall(function() return game:GetService("HttpService"):JSONDecode(content) end)
    if not ok2 or type(data)~="table" then return {} end
    return data
end
local savedSettings=loadSettings()
local function getSetting(key,default)
    local v=savedSettings[key]
    if v==nil then return default end
    return v
end

-- Apply saved settings
_G.FarmMode=getSetting("FarmMode","random")
_G.AutoJumpEnabled=getSetting("AutoJumpEnabled",true)
_G.ChestWaitTime=getSetting("ChestWaitTime",0)
_G.SelectedWeaponType=getSetting("SelectedWeaponType","Melee")
_G.AutoEquipEnabled=getSetting("AutoEquipEnabled",false)
_G.BringMobMaxDistance=getSetting("BringMobMaxDistance",500)
_G.BringMobMaxBatch=getSetting("BringMobMaxBatch",6)
_G.BringMobOffsetMode=getSetting("BringMobOffsetMode","random")
_G.PlayerOffsetMode=getSetting("PlayerOffsetMode","random")
_G.PlayerOffsetRange=getSetting("PlayerOffsetRange",8)
_G.PlayerOffsetInterval=getSetting("PlayerOffsetInterval",0.1)
_G.PlayerOffsetCustom=Vector3.new(getSetting("PlayerOffsetCustomX",0),getSetting("PlayerOffsetCustomY",35),getSetting("PlayerOffsetCustomZ",0))
_G.AutoStatDelay=getSetting("AutoStatDelay",0.3)
_G.AutoStatEnabled={
    Melee=getSetting("AutoStatMelee",false),
    Defense=getSetting("AutoStatDefense",false),
    Sword=getSetting("AutoStatSword",false),
    Gun=getSetting("AutoStatGun",false),
    DemonFruit=getSetting("AutoStatDemonFruit",false),
}
_G.AutoBusoEnabled=getSetting("AutoBusoEnabled",true)
_G.DamageAuraEnabled=getSetting("DamageAuraEnabled",false)
_G.AutoGrabFruitEnabled=getSetting("AutoGrabFruitEnabled",false)
_G.AutoFarmLevelEnabled=getSetting("AutoFarmLevelEnabled",false)
_G.FarmAuraEnabled=getSetting("FarmAuraEnabled",false)
_G.BringMobEnabled=getSetting("BringMobEnabled",false)
_G.QuestModeEnabled=getSetting("QuestModeEnabled",false)
SPEED=getSetting("SPEED",350)

local enemySpawnMemory={}
local spawnPartMemory={}

local function trackSpawnParts()
    spawnPartMemory={}
    local wo=workspace:FindFirstChild("_WorldOrigin") if not wo then return end
    local sf=wo:FindFirstChild("EnemySpawns") if not sf then return end
    for _,s in ipairs(sf:GetChildren()) do
        local n=(s.Name:match("^(.-)%s*%[") or s.Name):match("^%s*(.-)%s*$")
        if n~="" then
            local pos
            if s:IsA("BasePart") then pos=s.Position
            else local ok,p=pcall(function() return s:GetPivot().Position end) if ok then pos=p end end
            if pos then
                if not spawnPartMemory[n] then spawnPartMemory[n]={} end
                table.insert(spawnPartMemory[n],pos+Vector3.new(0,5,0))
            end
        end
    end
end

local spawnWatchConn=nil
local function startSpawnWatcher()
    if spawnWatchConn then return end
    local ef=workspace:FindFirstChild("Enemies") if not ef then return end
    for _,e in ipairs(ef:GetChildren()) do
        if e and e.Parent then
            local p=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p and not enemySpawnMemory[e] then enemySpawnMemory[e]=p.Position end
        end
    end
    spawnWatchConn=ef.ChildAdded:Connect(function(e)
        task.wait(0.05)
        if not e or not e.Parent then return end
        local p=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
        if p and not enemySpawnMemory[e] then enemySpawnMemory[e]=p.Position end
        e.AncestryChanged:Connect(function() if not e.Parent then enemySpawnMemory[e]=nil end end)
    end)
end

local function getSpawnPositionsForName(name)
    local pts={}
    if spawnPartMemory[name] and #spawnPartMemory[name]>0 then
        for _,pos in ipairs(spawnPartMemory[name]) do table.insert(pts,pos) end
        return pts
    end
    for e,pos in pairs(enemySpawnMemory) do
        if e and e.Parent then
            local en=(e.Name:match("^(.-)%s*%[") or e.Name):match("^%s*(.-)%s*$")
            if en==name then table.insert(pts,pos+Vector3.new(0,5,0)) end
        end
    end
    return pts
end

task.spawn(function()
    task.wait(2) trackSpawnParts() startSpawnWatcher()
    task.wait(5) trackSpawnParts()
end)

local EntranceMap={
    ["Factory Staff"]=vector.create(-286.98,306.13,597.88),["Swan Pirate"]=vector.create(-286.98,306.13,597.88),
    ["Raider"]=vector.create(-286.98,306.13,597.88),["Mercenary"]=vector.create(-286.98,306.13,597.88),
    ["Vampire"]=vector.create(-6508.55,89.03,-132.83),["Zombie"]=vector.create(-6508.55,89.03,-132.83),
    ["Ship Deckhand"]=vector.create(923.21,126.97,32852.83),["Ship Engineer"]=vector.create(923.21,126.97,32852.83),
    ["Ship Officer"]=vector.create(923.21,126.97,32852.83),["Ship Steward"]=vector.create(923.21,126.97,32852.83),
    ["Dragon Crew Warrior"]=vector.create(5669,1050,-325),["Hydra Enforcer"]=vector.create(5669,1050,-325),
    ["Hydra Leader"]=vector.create(5669,1050,-325),["Venomous Assailant"]=vector.create(5669,1050,-325),
    ["Ghost"]=vector.create(5669,1050,-325),["Beautiful Pirate"]=vector.create(5669,1050,-325),
    ["Forest Pirate"]=vector.create(-12479,375,-7573),["Mythological Pirate"]=vector.create(-12479,375,-7573),
    ["Musketeer Pirate"]=vector.create(-12479,375,-7573),["Jungle Pirate"]=vector.create(-12479,375,-7573),
    ["Fishman Captain"]=vector.create(-12479,375,-7573),["Fishman Raider"]=vector.create(-12479,375,-7573),
    ["Kilo Admiral"]=vector.create(5669,1100,-325),["Marine Commodore"]=vector.create(5669,1100,-325),
    ["Marine Rear Admiral"]=vector.create(5669,1100,-325),
}
local ExcludedMaps={FortBuilderPlacedSurfaces=true,FortBuilderPotentialSurfaces=true,Fishmen=true,MiniSky=true,RaidMap=true,["WaterBase-Plane"]=true,IndraIsland=true,EventInstances=true,GhostShipInterior=true,GhostShip=true,Group=true}
local IslandRoutes={
    ForgottenIsland={Vector3.new(-2792.612,6.151,-9489.092),Vector3.new(-3319.633,6.156,-9406.701),Vector3.new(-3723.911,6.156,-9899.021),Vector3.new(-4394.9,122.851,-10715.47),Vector3.new(-3951.024,123.336,-11537.139),Vector3.new(-3087.306,281.155,-10971.061),Vector3.new(-2619.042,317.928,-10402.976),Vector3.new(-2512.719,6.156,-9541.841),Vector3.new(-2792.603,6.153,-9498.146)},
    Dressrosa={Vector3.new(-382.166,73.071,217.102),Vector3.new(-281.807,73.071,215.005),Vector3.new(-281.125,73.002,395.918),Vector3.new(-490.96,73.002,386.886),Vector3.new(-225.164,370.002,547.916),Vector3.new(-228.155,370.002,822.693),Vector3.new(-560.809,370.002,820.613),Vector3.new(-562.119,370.002,549.666),Vector3.new(-184.705,73.002,1608.106),Vector3.new(-976.461,73.051,1526.228),Vector3.new(-1038.249,73.002,776.786),Vector3.new(-1871.038,73.002,448.122),Vector3.new(-2230.802,73,-263.154),Vector3.new(-1279.016,73.2,-764.401),Vector3.new(-207.002,73,-955.06),Vector3.new(867.52,73.002,-537.579),Vector3.new(1290.36,73.002,448.933),Vector3.new(1294.695,227.001,679.579),Vector3.new(1313.344,73.002,913.958),Vector3.new(1120.239,73.002,1597.852),Vector3.new(638.665,73.001,1771.723),Vector3.new(43.028,73.001,1719.23),Vector3.new(8.19,118.202,1241.055),Vector3.new(-490.229,118.202,1244.256)},
    GraveIsland={Vector3.new(-5828.728,48.522,-664.228),Vector3.new(-6066.852,192.232,-1105.444),Vector3.new(-5636.473,179.535,-1354.075),Vector3.new(-5181.129,122.694,-928.748),Vector3.new(-5450.169,48.522,-696.602),Vector3.new(-5849.864,254.658,-415.851)},
    CircleIsland={Vector3.new(-6061.861,80.43,-3842.269),Vector3.new(-6505.915,29.224,-4128.707),Vector3.new(-6935.194,81.363,-4653.365),Vector3.new(-6926.797,81.865,-5253.373),Vector3.new(-6797.53,61.106,-5617.261),Vector3.new(-6654.725,29.224,-6111.343),Vector3.new(-6352.736,85.321,-6204.132),Vector3.new(-5870.917,81.295,-5988.43),Vector3.new(-5624.509,29.209,-5444.182),Vector3.new(-5240.445,175.768,-5395.823),Vector3.new(-5347.583,219.409,-5958.787),Vector3.new(-4944.605,175.768,-6003.676),Vector3.new(-4488.611,175.768,-5613.406),Vector3.new(-4541.907,175.768,-5087.333),Vector3.new(-4694.477,175.768,-4540.69)},
    GreenBit={Vector3.new(-2236.883,73.312,-2654.799),Vector3.new(-1724.826,73.004,-2893.391),Vector3.new(-1400.249,73.008,-3570.906),Vector3.new(-1926.891,72.384,-4440.53),Vector3.new(-2666.597,72.383,-4357.104),Vector3.new(-3391.223,73.009,-3521.937),Vector3.new(-3370.572,73.008,-3000.55),Vector3.new(-2855.085,73.005,-2447.016),Vector3.new(-2232.458,73.312,-2642.876)},
    SnowMountain={Vector3.new(-66.768,8.518,-4954.692),Vector3.new(-219.63,2.465,-5446.675),Vector3.new(-8.583,12.464,-5862.012),Vector3.new(356.511,1.874,-6282.376),Vector3.new(829.074,42.684,-5960.455),Vector3.new(1253.673,52.489,-5812.354),Vector3.new(1851.51,76.472,-5532.257),Vector3.new(1798.399,51.739,-5070.247),Vector3.new(1619.942,45.633,-4480.307),Vector3.new(1200.262,5.41,-4264.189),Vector3.new(650.247,60.252,-4640.002),Vector3.new(786.209,429.464,-4785.48),Vector3.new(1281.058,428.017,-4553.571),Vector3.new(1651.708,429.464,-5374.66),Vector3.new(1152.688,429.464,-5610.507),Vector3.new(762.597,406.029,-5776.699),Vector3.new(243.972,414.211,-5962.319),Vector3.new(-39.41,413.141,-5164.655),Vector3.new(424.563,401.464,-4948.608)},
    IceCastle={Vector3.new(5512.187,28.232,-6120.979),Vector3.new(5159.295,283.606,-6488.404),Vector3.new(5656.009,258.007,-6972.112),Vector3.new(6136.604,294.428,-7393.519),Vector3.new(6855.872,294.428,-7209.615),Vector3.new(7069.927,496.212,-6708.433),Vector3.new(6735.651,294.429,-6422.289),Vector3.new(6195.232,167.238,-6291.69),Vector3.new(5853.233,146.496,-6076.269)},
    DarkbeardArena={Vector3.new(4074.911,13.39,-3800.093),Vector3.new(4233.6,30.16,-3353.118),Vector3.new(3962.525,42.552,-3018.284),Vector3.new(3431.821,13.391,-3244.932),Vector3.new(3340.237,30.324,-3686.796),Vector3.new(3597.007,13.391,-3902.315),Vector3.new(3841.871,32.851,-3933.289)},
}
local LevelQuestData={
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
    {minLv=150,maxLv=174,questPos=Vector3.new(-4840,718,-2611),questRemote={"StartQuest","SkyQuest",1},mobName="Sky Bandit",entranceVec=nil},
    {minLv=175,maxLv=189,questPos=Vector3.new(-4840,718,-2611),questRemote={"StartQuest","SkyQuest",2},mobName="Dark Master",entranceVec=nil},
    {minLv=190,maxLv=209,questPos=Vector3.new(5308,2,477),questRemote={"StartQuest","PrisonerQuest",1},mobName="Prisoner",entranceVec=nil},
    {minLv=210,maxLv=249,questPos=Vector3.new(5308,2,477),questRemote={"StartQuest","PrisonerQuest",2},mobName="Dangerous Prisoner",entranceVec=nil},
    {minLv=250,maxLv=274,questPos=Vector3.new(-1577,7,-2989),questRemote={"StartQuest","ColosseumQuest",1},mobName="Toga Warrior",entranceVec=nil},
    {minLv=275,maxLv=299,questPos=Vector3.new(-1577,7,-2989),questRemote={"StartQuest","ColosseumQuest",2},mobName="Gladiator",entranceVec=nil},
    {minLv=300,maxLv=324,questPos=Vector3.new(-5316,12,8518),questRemote={"StartQuest","MagmaQuest",1},mobName="Military Soldier",entranceVec=nil},
    {minLv=325,maxLv=374,questPos=Vector3.new(-5316,12,8518),questRemote={"StartQuest","MagmaQuest",2},mobName="Military Spy",entranceVec=nil},
    {minLv=375,maxLv=399,questPos=Vector3.new(61123,19,1566),questRemote={"StartQuest","FishmanQuest",1},mobName="Fishman Warrior",entranceVec=vector.create(61163.85,11.68,1819.78)},
    {minLv=400,maxLv=449,questPos=Vector3.new(61123,19,1566),questRemote={"StartQuest","FishmanQuest",2},mobName="Fishman Commando",entranceVec=vector.create(61163.85,11.68,1819.78)},
    {minLv=450,maxLv=474,questPos=Vector3.new(-4726,845,-1949),questRemote={"StartQuest","SkyExp1Quest",1},mobName="God's Guard",entranceVec=vector.create(-4607.82,874.39,-1667.56)},
    {minLv=475,maxLv=524,questPos=Vector3.new(-7861,5546,-381),questRemote={"StartQuest","SkyExp1Quest",2},mobName="Shanda",entranceVec=vector.create(-7894.62,5547.14,-380.29)},
    {minLv=525,maxLv=549,questPos=Vector3.new(-7903,5636,-1404),questRemote={"StartQuest","SkyExp2Quest",1},mobName="Royal Squad",entranceVec=nil},
    {minLv=550,maxLv=624,questPos=Vector3.new(-7903,5636,-1404),questRemote={"StartQuest","SkyExp2Quest",2},mobName="Royal Soldier",entranceVec=nil},
    {minLv=625,maxLv=649,questPos=Vector3.new(5257,39,4049),questRemote={"StartQuest","FountainQuest",1},mobName="Galley Pirate",entranceVec=vector.create(-4607.82,874.39,-1667.56)},
    {minLv=650,maxLv=9999,questPos=Vector3.new(5257,39,4049),questRemote={"StartQuest","FountainQuest",2},mobName="Galley Captain",entranceVec=vector.create(-4607.82,874.39,-1667.56)},
}

local CommF_=RS:WaitForChild("Remotes"):WaitForChild("CommF_")
local function notify(t,c,d) WindUI:Notify({Title=t,Content=c or "",Duration=d or 3}) end
local function notifyOnce(k,t,d) if lastNotifiedTarget~=k then lastNotifiedTarget=k notify(t,d) end end
local function getHRP(c) return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function isAlive(m) if not m or not m.Parent then return false end local h=getHum(m) return h and h.Health>0 end
local function isPC(m) for _,p in ipairs(Players:GetPlayers()) do if p.Character==m then return true end end return false end
local function getEHRP(e) return e and e.Parent and (e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")) end
local function getPos(o)
    if not o or not o.Parent then return nil end
    if typeof(o)=="Vector3" then return o end
    if o:IsA("Model") then local ok,p=pcall(function() return o:GetPivot().Position end) return ok and p end
    if o:IsA("BasePart") then return o.Position end
    local ok,p=pcall(function() return o:GetPivot().Position end) return ok and p
end
local function getTip(t)
    if not t then return nil end
    local ok,tip=pcall(function() return t.ToolTip end) if ok and tip and tip~="" then return tip end
    local c=t:FindFirstChild("ToolTip") if c then return type(c.Value)=="string" and c.Value or nil end
    return t:GetAttribute("ToolTip") or t.Name
end
local function doJump() VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game) task.wait(0.05) VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game) end
local function clickBtn(btn)
    if not(btn and btn:IsA("GuiButton") and btn.Visible) then return end
    local p,s=btn.AbsolutePosition,btn.AbsoluteSize
    local cx,cy=p.X+s.X/2,p.Y+s.Y/2+58
    VIM:SendMouseButtonEvent(cx,cy,0,true,game,0) task.wait(0.05) VIM:SendMouseButtonEvent(cx,cy,0,false,game,0)
end
local function getIslandRoute(name)
    if IslandRoutes[name] then return IslandRoutes[name] end
    local l=name:lower()
    for k,v in pairs(IslandRoutes) do if k:lower()==l then return v end end
    if l:find("dressrosa") then return IslandRoutes.Dressrosa end
    if l:find("forgotten") then return IslandRoutes.ForgottenIsland end
    if l:find("grave") then return IslandRoutes.GraveIsland end
    if l:find("circle") then return IslandRoutes.CircleIsland end
    if l:find("green") then return IslandRoutes.GreenBit end
    if l:find("snow") then return IslandRoutes.SnowMountain end
    if l:find("ice") then return IslandRoutes.IceCastle end
end
local function getHitPart(m)
    for _,n in ipairs({"HumanoidRootPart","Head","UpperTorso","LowerTorso"}) do local p=m:FindFirstChild(n) if p then return p end end
    for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then return p end end
end
local function makeBV(hrp,name)
    local old=hrp:FindFirstChild(name) if old then old:Destroy() end
    local bv=Instance.new("BodyVelocity") bv.Name=name bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero bv.Parent=hrp return bv
end
local function waitAlive()
    while not isAlive(LP.Character) do task.wait(0.5) end
end
local function invoke(...)
    local args={...}
    pcall(function() CommF_:InvokeServer(table.unpack(args)) end)
end

-- snapY: teleport Y ให้ตรงกับ target ก่อน tween ทุกครั้ง
local function snapY(targetPos)
    local hrp=getHRP(LP.Character) if not hrp then return end
    if math.abs(hrp.Position.Y-targetPos.Y)>3 then
        hrp.CFrame=CFrame.new(hrp.Position.X,targetPos.Y,hrp.Position.Z)
        task.wait(0.05)
    end
end

local playerOffsetCurrent=Vector3.new(0,35,0)
local playerOffsetTask=nil
local function getPlayerOffset()
    if _G.PlayerOffsetMode=="random" then return playerOffsetCurrent else return _G.PlayerOffsetCustom end
end
local function startPlayerOffsetLoop()
    if playerOffsetTask then return end
    playerOffsetTask=task.spawn(function()
        while true do
            if _G.PlayerOffsetMode=="random" then
                local r=_G.PlayerOffsetRange
                playerOffsetCurrent=Vector3.new(math.random(-r,r),35,math.random(-r,r))
            end
            task.wait(_G.PlayerOffsetInterval)
        end
    end)
end
local function getPlayerTarget(mobPos)
    local offset=getPlayerOffset()
    return Vector3.new(mobPos.X+offset.X,mobPos.Y+offset.Y,mobPos.Z+offset.Z)
end

local function fireEntrance(targetPos)
    if not targetPos then return end
    local hrp=getHRP(LP.Character) if not hrp then return end
    local pp=vector.create(hrp.Position.X,hrp.Position.Y,hrp.Position.Z)
    local tp=vector.create(targetPos.X,targetPos.Y,targetPos.Z)
    if (pp-tp).Magnitude<=1000 then return end
    local best,bestD=nil,math.huge
    for _,ep in pairs(EntranceMap) do local d=(ep-tp).Magnitude if d<bestD then bestD=d best=ep end end
    if best and bestD<(pp-tp).Magnitude-50 then invoke("requestEntrance",best) task.wait(0.8) end
end
local function fireEntranceForEnemy(name)
    if not name then return end
    local hrp=getHRP(LP.Character) if not hrp then return end
    local cur=vector.create(hrp.Position.X,hrp.Position.Y,hrp.Position.Z)
    local tgt=nil
    local sf=workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if sf then for _,s in ipairs(sf:GetChildren()) do
        local n=(s.Name:match("^(.-)%s*%[") or s.Name):match("^%s*(.-)%s*$")
        if n==name then local p=s:IsA("BasePart") and s.Position or s:GetPivot().Position tgt=vector.create(p.X,p.Y,p.Z) break end
    end end
    if not tgt or (cur-tgt).Magnitude<=1000 then return end
    local best,bestD=nil,math.huge
    for _,ep in pairs(EntranceMap) do local d=(ep-tgt).Magnitude if d<bestD then bestD=d best=ep end end
    if best and bestD<(cur-tgt).Magnitude-50 then invoke("requestEntrance",best) task.wait(0.8) end
end

local enemyDropdownRef=nil
local function cleanName(n) return (n:match("^(.-)%s*%[") or n):match("^%s*(.-)%s*$") end
local function getEnemyNames()
    local seen,names={},{}
    local sf=workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if sf then for _,s in ipairs(sf:GetChildren()) do local b=cleanName(s.Name) if b~="" and not seen[b] then seen[b]=true table.insert(names,b) end end end
    local ef=workspace:FindFirstChild("Enemies")
    if ef then for _,e in ipairs(ef:GetChildren()) do if e and e.Parent then local b=cleanName(e.Name) if b~="" and not seen[b] then seen[b]=true table.insert(names,b.." *") end end end end
    table.sort(names) return names
end
local function refreshEnemyDropdown()
    if not enemyDropdownRef then return end
    local l=getEnemyNames() if #l==0 then l={"(No enemies found)"} end
    pcall(function() enemyDropdownRef:Refresh(l) end)
end

local noclipConn,Clip=nil,true
local function enableNoclip()
    Clip=false
    if noclipConn then noclipConn:Disconnect() end
    noclipConn=RunService.Heartbeat:Connect(function()
        if Clip then return end
        local c=LP.Character if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end
    end)
end
local function disableNoclip() Clip=true if noclipConn then noclipConn:Disconnect() noclipConn=nil end end
local antiSitTask=nil
local function enableAntiSit()
    if antiSitTask then return end
    antiSitTask=task.spawn(function()
        while _G.AutoFarmEnabled do
            local h=getHum(LP.Character) if h and h.Sit then h.Sit=false h:SetStateEnabled(Enum.HumanoidStateType.Seated,false) end task.wait(0.2)
        end
    end)
end
local function disableAntiSit() if antiSitTask then task.cancel(antiSitTask) antiSitTask=nil end end

local function getWorldFruits()
    local fruits={}
    for _,obj in ipairs(workspace:GetChildren()) do
        local n=obj.Name
        if n:find("Fruit") or n=="Fruit " then
            if obj:IsA("Folder") or obj:IsA("Model") then
                for _,f in ipairs(obj:GetChildren()) do if f and f.Parent and not _G.FruitBlacklist[f] then local pos=getPos(f) if pos then table.insert(fruits,{inst=f,position=pos}) end end end
            elseif not _G.FruitBlacklist[obj] then local pos=getPos(obj) if pos then table.insert(fruits,{inst=obj,position=pos}) end end
        end
    end
    return fruits
end
local function getClosestFruit()
    local hrp=getHRP(LP.Character) if not hrp then return nil end
    local cl,cd=nil,math.huge
    for _,f in ipairs(getWorldFruits()) do local d=(hrp.Position-f.position).Magnitude if d<cd then cd=d cl=f end end
    return cl
end
local function hasFruit() return getClosestFruit()~=nil end
local function processFruit(t)
    if _G.FruitBlacklist[t] then return end _G.FruitBlacklist[t]=true
    local ok=pcall(function() CommF_:InvokeServer("StoreFruit",t.Name:gsub(" Fruit$",""),t) end)
    notify("Fruit",(ok and "Stored " or "Failed ")..t.Name)
end
local function storeFruitInv()
    local function try(c) for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name:find("Fruit") and not _G.FruitBlacklist[t] then
        local ok=pcall(function() CommF_:InvokeServer("StoreFruit",t.Name:gsub(" Fruit$",""),t) end)
        if ok then _G.FruitBlacklist[t]=true pcall(function() t:Destroy() end) end task.wait(0.3)
    end end end
    try(LP.Backpack) local c=LP.Character if c then try(c) end
end

local function getSpecialEgg()
    local c=LP.Character
    for _,n in ipairs({"Falling Sky Egg","Thirsty Egg","Molten Egg","Friendly Neighborhood Egg","Firefly Egg"}) do
        local f=LP.Backpack:FindFirstChild(n) or (c and c:FindFirstChild(n)) if f then return f end
    end
end
local function hasPriorityTarget()
    for _,v in ipairs(workspace:GetChildren()) do if v.Parent and (v.Name=="Shard" or v.Name=="EasterShard") and not _G.ShardBlacklist[v] then return true end end
    for _,v in ipairs(workspace:GetChildren()) do if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then return true end end
    local ff=workspace:FindFirstChild("Fruit ") if ff then for _,f in ipairs(ff:GetChildren()) do if f.Parent and not _G.FruitBlacklist[f] then return true end end end
    return false
end
local function hasAnyTarget()
    if _G.QuestModeEnabled and getSpecialEgg() then return false end
    if hasPriorityTarget() or hasFruit() then return true end
    local cm=workspace:FindFirstChild("ChestModels") if cm then for _,v in ipairs(cm:GetChildren()) do if v.Parent and not _G.ChestBlacklist[v] then return true end end end
    for _,o in ipairs(workspace:GetDescendants()) do if o.Parent and (o.Name=="EasterChest" or o.Name=="Chest") and not _G.ChestBlacklist[o] then return true end end
    return false
end

local sealedEggBlacklist,sealedEggTargetIsland={},nil
local function findSealedEgg()
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Model") and o.Name=="SealedShowdownEgg" and not sealedEggBlacklist[o] then
            local p=o:FindFirstChild("_PrimaryPart") if p then return o,p end
        end
    end
    return nil,nil
end
local function fireProximity(part)
    local prompt=part:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then for _,v in ipairs(part:GetDescendants()) do if v:IsA("ProximityPrompt") then prompt=v break end end end
    if prompt then fireproximityprompt(prompt) return true end return false
end

local function getClosestEnemy()
    local hrp=getHRP(LP.Character) if not hrp then return nil end
    local ef=workspace:FindFirstChild("Enemies") if not ef then return nil end
    local cl,cd=nil,math.huge
    for _,e in ipairs(ef:GetChildren()) do
        if e and e.Parent and isAlive(e) then
            local p=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p then local d=(hrp.Position-p.Position).Magnitude if d<cd then cd=d cl={enemy=e,part=p,dist=d} end end
        end
    end
    return cl
end
local function getClosestCollectible()
    local hrp=getHRP(LP.Character) if not hrp then return nil end
    local cl,cd=nil,math.huge
    local function chk(inst,t) local pos=getPos(inst) if not pos then return end local d=(hrp.Position-pos).Magnitude if d<cd then cd=d cl={type=t,instance=inst,position=pos} end end
    for _,obj in ipairs(workspace:GetChildren()) do
        local n=obj.Name
        if n:find("Fruit") or n=="Fruit " then
            if obj:IsA("Folder") or obj:IsA("Model") then for _,f in ipairs(obj:GetChildren()) do if f.Parent and not _G.FruitBlacklist[f] then chk(f,"Fruit") end end
            elseif not _G.FruitBlacklist[obj] then chk(obj,"Fruit") end
        end
    end
    for _,v in ipairs(workspace:GetChildren()) do if v.Parent and (v.Name=="Shard" or v.Name=="EasterShard") and not _G.ShardBlacklist[v] then chk(v,"Shard") end end
    for _,v in ipairs(workspace:GetChildren()) do if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then chk(v,"Egg") end end
    local cm=workspace:FindFirstChild("ChestModels") if cm then for _,v in ipairs(cm:GetChildren()) do if v.Parent and not _G.ChestBlacklist[v] then local p=v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart") if p then chk(p,"Chest") end end end end
    for _,o in ipairs(workspace:GetDescendants()) do
        if o.Parent and (o.Name=="EasterChest" or o.Name=="Chest") and not _G.ChestBlacklist[o] then
            local p=o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or o if p then chk(p,"Chest") end
        end
    end
    return cl
end

local function moveTo(targetPos,targetInst,targetType,dynamic,enableJump)
    if dynamic==nil then dynamic=true end if enableJump==nil then enableJump=false end
    if not targetPos and not targetInst then return false end
    if not targetPos then local p=getPos(targetInst) if p then targetPos=p end end
    do local hrp=getHRP(LP.Character) if hrp and targetPos and (hrp.Position-targetPos).Magnitude>1000 then fireEntrance(targetPos) task.wait(0.5) end end
    waitAlive()
    local hrp=getHRP(LP.Character) if not hrp then return false end
    snapY(targetPos)
    hrp=getHRP(LP.Character) if not hrp then return false end
    local old=hrp:FindFirstChild("Lock") if old then old:Destroy() end
    local bv=Instance.new("BodyVelocity") bv.Name="Lock" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero bv.Parent=hrp
    local checkTimer,interrupted,lastJump=0,false,0
    local function anyFarmActive() return _G.AutoFarmEnabled or _G.FarmAuraEnabled or _G.FarmSelectEnabled or _G.AutoGrabFruitEnabled or _G.AutoFarmLevelEnabled end
    while anyFarmActive() do
        local hrpNow=getHRP(LP.Character)
        if not hrpNow or not isAlive(LP.Character) then
            pcall(function() bv.Velocity=Vector3.zero end) pcall(function() bv:Destroy() end)
            waitAlive() hrpNow=getHRP(LP.Character) if not hrpNow then break end
            local o2=hrpNow:FindFirstChild("Lock") if o2 then o2:Destroy() end
            bv=Instance.new("BodyVelocity") bv.Name="Lock" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero bv.Parent=hrpNow
        end
        if _G.QuestModeEnabled and getSpecialEgg() and targetType~="Quest" then break end
        if targetInst and targetInst.Parent then local p=getPos(targetInst) if p then targetPos=p end end
        if not targetPos then break end
        local dist=(hrpNow.Position-targetPos).Magnitude
        if dist<3 then break end
        if enableJump and _G.AutoJumpEnabled and dist<15 then local now=tick() if now-lastJump>0.3 then doJump() lastJump=now end end
        if dynamic then
            checkTimer+=task.wait()
            if checkTimer>=0.2 then checkTimer=0
                local cl=getClosestCollectible()
                if cl and (hrpNow.Position-cl.position).Magnitude<(targetPos-hrpNow.Position).Magnitude-5 then interrupted=true break end
                if _G.AutoGrabFruitEnabled and targetType~="Fruit" then
                    local fr=getClosestFruit()
                    if fr and (hrpNow.Position-fr.position).Magnitude<(targetPos-hrpNow.Position).Magnitude-5 then interrupted=true break end
                end
            end
        else task.wait() end
        local spd=math.clamp(dist*6,40,SPEED)
        bv.Velocity=(targetPos-hrpNow.Position).Unit*spd
    end
    pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.05) pcall(function() bv:Destroy() end)
    return interrupted
end

local function tweenTo(targetPos,speed)
    speed=speed or SPEED
    waitAlive()
    local hrp=getHRP(LP.Character) if not hrp then return end
    snapY(targetPos)
    hrp=getHRP(LP.Character) if not hrp then return end
    local bv=makeBV(hrp,"LevelFarmBV")
    while true do
        if not isAlive(LP.Character) then
            pcall(function() bv.Velocity=Vector3.zero end) pcall(function() bv:Destroy() end)
            waitAlive() hrp=getHRP(LP.Character) if not hrp then return end
            snapY(targetPos) hrp=getHRP(LP.Character) if not hrp then return end
            bv=makeBV(hrp,"LevelFarmBV")
        end
        hrp=getHRP(LP.Character) if not hrp then break end
        local dist=(hrp.Position-targetPos).Magnitude
        if dist<4 then bv.Velocity=Vector3.zero break end
        local spd=math.clamp(dist*6,40,speed)
        bv.Velocity=(targetPos-hrp.Position).Unit*spd
        task.wait(0.05)
    end
    pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.05)
    pcall(function() bv:Destroy() end)
end

local function holdInPlace(hrp,pos,fn)
    local bv=Instance.new("BodyVelocity") bv.Name="HoldBV" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero bv.Parent=hrp
    local bp=Instance.new("BodyPosition") bp.Name="HoldBP" bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge) bp.P=10000 bp.Position=pos bp.Parent=hrp
    fn(bp)
    pcall(function() bv:Destroy() end) pcall(function() bp:Destroy() end)
end

local function deliverFallingSkyEgg(egg)
    local c=LP.Character local hrp=getHRP(c) if not hrp then return end
    local h=getHum(c) if egg.Parent~=c and h then h:EquipTool(egg) task.wait(0.3) end
    local btn=LP.PlayerGui.Main.Dialogue:FindFirstChild("Option1")
    local dropPos=Vector3.new(hrp.Position.X,hrp.Position.Y+150,hrp.Position.Z)
    holdInPlace(hrp,dropPos,function(bp)
        bp.Position=dropPos local elapsed=0
        while _G.AutoFarmEnabled and _G.QuestModeEnabled and egg.Parent==c and elapsed<15 do clickBtn(btn) task.wait(0.2) elapsed+=0.2 bp.Position=dropPos end
        while _G.AutoFarmEnabled and _G.QuestModeEnabled do bp.Position=dropPos
            for _,v in ipairs(workspace:GetChildren()) do if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then return end end
            task.wait(0.3)
        end
    end)
    local hrp2=getHRP(LP.Character) if not hrp2 then return end
    local cl,cd=nil,math.huge
    for _,v in ipairs(workspace:GetChildren()) do if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then local p=getPos(v) if p then local d=(hrp2.Position-p).Magnitude if d<cd then cd=d cl=v end end end end
    if cl then moveTo(getPos(cl),cl,"Egg",false,true) end
end
local function deliverFriendlyEgg(egg)
    local c=LP.Character local hrp=getHRP(c) if not hrp then return end
    local h=getHum(c) if egg.Parent~=c and h then h:EquipTool(egg) task.wait(0.3) end
    local targetPart=nil
    for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and obj.Name:lower():find("friendly") then targetPart=obj break end end
    if not targetPart then return end
    hrp=getHRP(LP.Character) if not hrp then return end
    local bv=makeBV(hrp,"FriendlyLock") local arrived=false
    while _G.AutoFarmEnabled and _G.QuestModeEnabled do
        hrp=getHRP(LP.Character) if not hrp then break end
        if not targetPart or not targetPart.Parent then break end
        if (hrp.Position-targetPart.Position).Magnitude<5 then arrived=true break end
        snapY(targetPart.Position) hrp=getHRP(LP.Character) if not hrp then break end
        bv.Velocity=(targetPart.Position-hrp.Position).Unit*SPEED task.wait(0.03)
    end
    pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.1) pcall(function() bv:Destroy() end)
    if arrived then
        hrp=getHRP(LP.Character) if hrp then
            holdInPlace(hrp,hrp.Position,function()
                if egg.Parent==c then pcall(function()
                    local npc=workspace.NPCs:FindFirstChild("Forgotten Quest Giver")
                    if npc then RS.Modules.Net["RF/EasterServiceRF"]:InvokeServer("NPC.TravelingQuest",npc) end
                end) end task.wait(1)
            end)
        end
    end
end
local function deliverThirstyEgg(egg)
    local c=LP.Character local hrp=getHRP(c) if not hrp then return end
    local btn=(LP.PlayerGui:FindFirstChild("Main") and LP.PlayerGui.Main:FindFirstChild("Dialogue") and LP.PlayerGui.Main.Dialogue:FindFirstChild("Option1"))
    local closestWater,cd=nil,math.huge
    for _,obj in ipairs(workspace:GetDescendants()) do if obj.Name=="WaterBase-Plane" and obj:IsA("BasePart") then local d=(hrp.Position-obj.Position).Magnitude if d<cd then cd=d closestWater=obj end end end
    if not closestWater then return end
    hrp=getHRP(LP.Character) if not hrp then return end
    local tp=Vector3.new(closestWater.Position.X,closestWater.Position.Y+100,closestWater.Position.Z)
    snapY(tp) hrp=getHRP(LP.Character) if not hrp then return end
    local bv=makeBV(hrp,"ThirstyLock")
    while _G.AutoFarmEnabled do
        hrp=getHRP(LP.Character) if not hrp then break end
        if not closestWater or not closestWater.Parent then break end
        local tp2=Vector3.new(closestWater.Position.X,closestWater.Position.Y+100,closestWater.Position.Z)
        if (hrp.Position-tp2).Magnitude<4 then bv.Velocity=Vector3.zero break end
        bv.Velocity=(tp2-hrp.Position).Unit*SPEED task.wait(0.03)
    end
    pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.1) pcall(function() bv:Destroy() end)
    hrp=getHRP(LP.Character) if not hrp then return end
    holdInPlace(hrp,hrp.Position,function(bp)
        local function getHP() if closestWater and closestWater.Parent then return Vector3.new(closestWater.Position.X,closestWater.Position.Y+20,closestWater.Position.Z) end return bp.Position end
        bp.Position=getHP() local elapsed,spawned=0,false
        while _G.AutoFarmEnabled and _G.QuestModeEnabled and egg.Parent==c and elapsed<10 do bp.Position=getHP() clickBtn(btn) task.wait(0.2) elapsed+=0.2 end
        local ws=tick()
        while _G.AutoFarmEnabled and tick()-ws<15 do bp.Position=getHP()
            for _,v in ipairs(workspace:GetChildren()) do if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then spawned=true break end end
            if spawned then break end task.wait(0.5)
        end
    end)
    hrp=getHRP(LP.Character) if hrp then
        local cl,cd2=nil,math.huge
        for _,v in ipairs(workspace:GetChildren()) do if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then local p=getPos(v) if p then local d=(hrp.Position-p).Magnitude if d<cd2 then cd2=d cl=v end end end end
        if cl then moveTo(getPos(cl),cl,"Egg",false,true) end
    end
end
local function deliverMoltenEgg(egg)
    local c=LP.Character local hrp=getHRP(c) if not hrp then return end
    local btn=(LP.PlayerGui:FindFirstChild("Main") and LP.PlayerGui.Main:FindFirstChild("Dialogue") and LP.PlayerGui.Main.Dialogue:FindFirstChild("Option1"))
    local closestLava,cd=nil,math.huge
    local ci=workspace.Map:FindFirstChild("CircleIsland") local lp=ci and ci:FindFirstChild("LavaParts")
    if lp then for _,obj in ipairs(lp:GetDescendants()) do if obj:IsA("BasePart") then local d=(hrp.Position-obj.Position).Magnitude if d<cd then cd=d closestLava=obj end end end end
    if not closestLava then return end
    local dropPos=Vector3.new(closestLava.Position.X,closestLava.Position.Y+15,closestLava.Position.Z)
    hrp=getHRP(LP.Character) if not hrp then return end
    snapY(dropPos) hrp=getHRP(LP.Character) if not hrp then return end
    local bv=makeBV(hrp,"MoltenLock")
    while _G.AutoFarmEnabled do
        hrp=getHRP(LP.Character) if not hrp then break end
        if (hrp.Position-dropPos).Magnitude<4 then break end
        bv.Velocity=(dropPos-hrp.Position).Unit*SPEED task.wait(0.03)
    end
    pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.1) pcall(function() bv:Destroy() end)
    hrp=getHRP(LP.Character) if not hrp then return end
    holdInPlace(hrp,dropPos,function(bp)
        local elapsed=0
        while _G.AutoFarmEnabled and _G.QuestModeEnabled and egg.Parent==c and elapsed<10 do clickBtn(btn) task.wait(0.2) elapsed+=0.2 bp.Position=dropPos end
        local ws=tick()
        while _G.AutoFarmEnabled and tick()-ws<10 do if hasPriorityTarget() then break end task.wait(0.5) bp.Position=dropPos end
    end)
    while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end
end

local autoGrabFruitTask=nil
local isFruitGrabbing=false
local function grabFruit(fd)
    if not fd then return end
    local f=fd.inst if not f or not f.Parent or _G.FruitBlacklist[f] then return end
    local hrp=getHRP(LP.Character)
    if hrp and (hrp.Position-fd.position).Magnitude>1000 then fireEntrance(fd.position) task.wait(0.8) end
    notify("Fruit","Grabbing "..f.Name,2)
    moveTo(fd.position,f,"Fruit",false,true) _G.FruitBlacklist[f]=true task.wait(0.8)
    local tool=nil
    for _,t in ipairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and t.Name:find("Fruit") then tool=t break end end
    if not tool then local c=LP.Character if c then for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name:find("Fruit") then tool=t break end end end end
    if tool then
        local h=getHum(LP.Character)
        if h and tool.Parent==LP.Backpack then h:EquipTool(tool) task.wait(0.4) end
        processFruit(tool) pcall(function() tool:Destroy() end)
    end
end
local function doFruitCycle()
    if isFruitGrabbing then return end isFruitGrabbing=true
    storeFruitInv()
    while true do local fr=getClosestFruit() if not fr then break end grabFruit(fr) task.wait(0.2) end
    isFruitGrabbing=false
end
local function startAutoGrabFruit()
    if autoGrabFruitTask then return end
    autoGrabFruitTask=task.spawn(function()
        while _G.AutoGrabFruitEnabled do
            if not isAlive(LP.Character) then task.wait(2) continue end
            storeFruitInv() local fr=getClosestFruit()
            if fr then grabFruit(fr) else task.wait(1) end task.wait(0.3)
        end autoGrabFruitTask=nil
    end)
end
local function stopAutoGrabFruit() _G.AutoGrabFruitEnabled=false if autoGrabFruitTask then task.cancel(autoGrabFruitTask) autoGrabFruitTask=nil end end

collectTargets=function()
    if not isAlive(LP.Character) then return false end
    if _G.QuestModeEnabled and getSpecialEgg() then return false end
    local hrp=getHRP(LP.Character) if not hrp then return false end
    if _G.AutoGrabFruitEnabled then local fr=getClosestFruit() if fr then doFruitCycle() return true end end
    local ff=workspace:FindFirstChild("Fruit ")
    if ff then
        local cf,cd=nil,math.huge
        for _,f in ipairs(ff:GetChildren()) do if f.Parent and not _G.FruitBlacklist[f] then local p=getPos(f) if p then local d=(hrp.Position-p).Magnitude if d<cd then cd=d cf=f end end end end
        if cf then
            notifyOnce(cf,"Collect","Fruit") moveTo(getPos(cf),cf,"Fruit",false,true) _G.FruitBlacklist[cf]=true task.wait(1)
            local tool=nil
            for _,t in ipairs(LP.Backpack:GetChildren()) do if t.Name:find("Fruit") then tool=t break end end
            if not tool and LP.Character then for _,t in ipairs(LP.Character:GetChildren()) do if t:IsA("Tool") and t.Name:find("Fruit") then tool=t break end end end
            if tool then local h=getHum(LP.Character) if h then h:EquipTool(tool) task.wait(0.5) end processFruit(tool) pcall(function() tool:Destroy() end) end
            return true
        end
    end
    local cs,csd=nil,math.huge
    for _,v in ipairs(workspace:GetChildren()) do if v.Parent and (v.Name=="Shard" or v.Name=="EasterShard") and not _G.ShardBlacklist[v] then local p=getPos(v) if p then local d=(hrp.Position-p).Magnitude if d<csd then csd=d cs=v end end end end
    if cs then notifyOnce(cs,"Collect","Shard") moveTo(getPos(cs),cs,"Shard",false,true) _G.ShardBlacklist[cs]=true return true end
    for _,v in ipairs(workspace:GetChildren()) do if v.Parent and v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then local p=getPos(v) if p then notifyOnce(v,"Collect","Egg") moveTo(p,v,"Egg",false,true) return true end end end
    local cm=workspace:FindFirstChild("ChestModels")
    if cm then
        local ct,cp,cd2=nil,nil,math.huge
        for _,v in ipairs(cm:GetChildren()) do if v.Parent and not _G.ChestBlacklist[v] then local p=v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart") if p then local pos=getPos(p) if pos then local d=(hrp.Position-pos).Magnitude if d<cd2 then cd2=d ct=v cp=pos end end end end end
        if ct then moveTo(cp,ct,"Chest",false,true) _G.ChestBlacklist[ct]=true if _G.ChestWaitTime>0 then task.wait(_G.ChestWaitTime) end return true end
    end
    for _,o in ipairs(workspace:GetDescendants()) do
        if o.Parent and (o.Name=="EasterChest" or o.Name=="Chest") and not _G.ChestBlacklist[o] then
            local p=o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or o
            if p then local pos=getPos(p) if pos then moveTo(pos,o,"Chest",false,true) _G.ChestBlacklist[o]=true if _G.ChestWaitTime>0 then task.wait(_G.ChestWaitTime) end return true end end
        end
    end
    return false
end

local function genBBoxRoute(island)
    local minX,minZ,maxX,maxZ,sumY,cnt=math.huge,math.huge,-math.huge,-math.huge,0,0
    for _,p in ipairs(island:GetDescendants()) do
        if p:IsA("BasePart") then local pos=p.Position minX=math.min(minX,pos.X) maxX=math.max(maxX,pos.X) minZ=math.min(minZ,pos.Z) maxZ=math.max(maxZ,pos.Z) sumY+=pos.Y cnt+=1 end
    end
    if cnt==0 then return nil end
    local pY=sumY/cnt+80 local cx,cz=(minX+maxX)/2,(minZ+maxZ)/2 local rx,rz=(maxX-minX)/2+30,(maxZ-minZ)/2+30
    return {Vector3.new(cx,pY,cz-rz),Vector3.new(cx+rx,pY,cz-rz),Vector3.new(cx+rx,pY,cz),Vector3.new(cx+rx,pY,cz+rz),Vector3.new(cx,pY,cz+rz),Vector3.new(cx-rx,pY,cz+rz),Vector3.new(cx-rx,pY,cz),Vector3.new(cx-rx,pY,cz-rz)}
end
local function getNextIsland()
    local t={} for _,i in ipairs(workspace.Map:GetChildren()) do if i:IsA("Model") and not ExcludedMaps[i.Name] then table.insert(t,i) end end
    return #t>0 and t[math.random(1,#t)] or nil
end
local function circleStep(route)
    if not route or #route==0 then return false end
    if not isAlive(LP.Character) then return "dead" end
    if _G.CurrentCircleIndex>#route then _G.CurrentCircleRound+=1 _G.CurrentCircleIndex=1 if _G.CurrentCircleRound>2 then return "finished" end notify("Circle","Round ".._G.CurrentCircleRound,2) end
    local wp=route[_G.CurrentCircleIndex] if not wp then return false end
    local interrupted=moveTo(wp,nil,"Waypoint",true,false)
    if interrupted then while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end return "continue" end
    if hasAnyTarget() then return "target_found" end
    _G.CurrentCircleIndex+=1 return "continue"
end

local function tweenToSealed(part)
    local hrp=getHRP(LP.Character) if not hrp then return false end
    snapY(part.Position) hrp=getHRP(LP.Character) if not hrp then return false end
    local bv=makeBV(hrp,"SealedEggLock") local arrived=false
    while _G.AutoFarmEnabled do
        hrp=getHRP(LP.Character) if not hrp then break end
        if not part or not part.Parent then break end
        if (hrp.Position-part.Position).Magnitude<5 then arrived=true break end
        bv.Velocity=(part.Position-hrp.Position).Unit*SPEED task.wait(0.03)
    end
    pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.05) pcall(function() bv:Destroy() end)
    return arrived
end
local function searchIslandForSealed(island)
    if not island or not island.Parent then return nil,nil end
    local ok,pivot=pcall(function() return island:GetPivot().Position end)
    if ok and pivot then
        local hrp=getHRP(LP.Character) if not hrp then return nil,nil end
        local gp=pivot+Vector3.new(0,80,0)
        if (hrp.Position-gp).Magnitude>1000 then fireEntrance(gp) task.wait(0.8) end
        hrp=getHRP(LP.Character) if not hrp then return nil,nil end
        snapY(gp) hrp=getHRP(LP.Character) if not hrp then return nil,nil end
        local bv=makeBV(hrp,"SealedEggLock")
        while _G.AutoFarmEnabled do
            hrp=getHRP(LP.Character) if not hrp then pcall(function() bv:Destroy() end) return nil,nil end
            if (hrp.Position-gp).Magnitude<15 then break end
            bv.Velocity=(gp-hrp.Position).Unit*SPEED task.wait(0.05)
            local e,p=findSealedEgg() if e then pcall(function() bv:Destroy() end) return e,p end
        end
        pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.05) pcall(function() bv:Destroy() end)
        local e,p=findSealedEgg() if e then return e,p end
    end
    local route=getIslandRoute(island.Name) or genBBoxRoute(island) if not route then return nil,nil end
    for _,wp in ipairs(route) do
        if not _G.AutoFarmEnabled then return nil,nil end
        local hrp=getHRP(LP.Character) if not hrp then return nil,nil end
        if (hrp.Position-wp).Magnitude>1000 then fireEntrance(wp) task.wait(0.8) end
        hrp=getHRP(LP.Character) if not hrp then return nil,nil end
        snapY(wp) hrp=getHRP(LP.Character) if not hrp then return nil,nil end
        local bv=makeBV(hrp,"SealedEggLock")
        while _G.AutoFarmEnabled do
            hrp=getHRP(LP.Character) if not hrp then pcall(function() bv:Destroy() end) return nil,nil end
            if (hrp.Position-wp).Magnitude<8 then break end
            bv.Velocity=(wp-hrp.Position).Unit*SPEED task.wait(0.05)
            local e,p=findSealedEgg() if e then pcall(function() bv:Destroy() end) return e,p end
        end
        pcall(function() bv.Velocity=Vector3.zero end) task.wait(0.05) pcall(function() bv:Destroy() end)
        local e,p=findSealedEgg() if e then return e,p end
    end
    return nil,nil
end

local autoEquipTask=nil
local function equipWeapon(wt)
    local c=LP.Character if not c then return end
    local function match(t) local tip=getTip(t) return tip and string.find(string.lower(tip),string.lower(wt)) end
    local tool=nil
    for _,t in ipairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and match(t) then tool=t break end end
    if not tool then for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") and match(t) then tool=t break end end end
    if tool then local h=getHum(c) if h then if tool.Parent==LP.Backpack then tool.Parent=c task.wait(0.1) end h:EquipTool(tool) end end
end
local function startAutoEquip()
    if autoEquipTask then return end
    autoEquipTask=task.spawn(function()
        while _G.AutoEquipEnabled do
            local c=LP.Character local equipped=nil
            if c then for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then equipped=t break end end end
            if not equipped then equipWeapon(_G.SelectedWeaponType) task.wait(0.5)
            else local tip=getTip(equipped) if not tip or not string.find(string.lower(tip),string.lower(_G.SelectedWeaponType)) then equipped.Parent=LP.Backpack task.wait(0.2) equipWeapon(_G.SelectedWeaponType) end end
            task.wait(1)
        end autoEquipTask=nil
    end)
end
local function stopAutoEquip() _G.AutoEquipEnabled=false if autoEquipTask then task.cancel(autoEquipTask) autoEquipTask=nil end end

local damageAuraTask=nil
local function getMeleeRemotes()
    local net=RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net") if not net then return nil,nil end
    return net:FindFirstChild("RE/RegisterAttack"),net:FindFirstChild("RE/RegisterHit")
end
local function getGunRemote() return RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net") and RS.Modules.Net:FindFirstChild("RE/ShootGunEvent") end
local function getWeaponInfo()
    local char=LP.Character
    local held=char and (function() for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") then return t end end end)()
    if not held then local a,b=getMeleeRemotes() return a,b,"melee" end
    local lc=held:FindFirstChild("LeftClickRemote") if lc and lc:IsA("RemoteEvent") then return lc,nil,"fruit" end
    local lp2=(getTip(held) or held.Name):lower()
    if lp2:find("gun") or lp2:find("pistol") or lp2:find("rifle") or lp2:find("shotgun") or lp2:find("bazooka") or lp2:find("cannon") then
        local gr=getGunRemote() if gr then return gr,nil,"gun" end
    end
    local a,b=getMeleeRemotes() return a,b,"melee"
end
local function fireGun(part)
    if not part or not part.Parent then return end
    local remote=getGunRemote()
    if remote then local hp=part.Parent:FindFirstChild("HumanoidRootPart") or getHitPart(part.Parent) or part pcall(function() remote:FireServer(hp.Position,{hp}) end) end
    local vp=workspace.CurrentCamera.ViewportSize
    VIM:SendMouseButtonEvent(vp.X/2,vp.Y/2,0,true,game,0) task.wait(0.05) VIM:SendMouseButtonEvent(vp.X/2,vp.Y/2,0,false,game,0)
end
local function fireDamage(part)
    if not part or not part.Parent then return end
    local hrp=getHRP(LP.Character) if not hrp then return end
    local remote,extra,wt=getWeaponInfo() if not remote then return end
    if wt=="gun" then fireGun(part) elseif wt=="fruit" then remote:FireServer((part.Position-hrp.Position).Unit,1) elseif extra then pcall(function() remote:FireServer(0.5) extra:FireServer(part,{},"196f522a") end) end
end
local function getNearbyEnemiesFiltered(range)
    local hrp=getHRP(LP.Character) if not hrp then return {} end
    local ef=workspace:FindFirstChild("Enemies") if not ef then return {} end
    local filterName=_G.AutoFarmLevelEnabled and _G.CurrentQuestMobName or nil
    local t={}
    for _,e in ipairs(ef:GetChildren()) do
        if isAlive(e) and not isPC(e) then
            if filterName then local en=cleanName(e.Name) if en~=filterName then continue end end
            local p=getEHRP(e) or getHitPart(e)
            if p and (hrp.Position-p.Position).Magnitude<=range then table.insert(t,p) end
        end
    end
    return t
end
local function startDamageAura()
    if damageAuraTask then return end
    damageAuraTask=task.spawn(function()
        while _G.DamageAuraEnabled do
            local _,_,wt=getWeaponInfo() local targets=getNearbyEnemiesFiltered(50)
            if #targets>0 then
                if wt=="gun" then for _,p in ipairs(targets) do fireGun(p) task.wait(0.08) end
                else for i=1,math.random(1,math.min(2,#targets)) do fireDamage(targets[math.random(1,#targets)]) end end
            end task.wait(0.05)
        end damageAuraTask=nil
    end)
end
local function stopDamageAura() if damageAuraTask then task.cancel(damageAuraTask) damageAuraTask=nil end end

local autoBusoTask=nil
local function startAutoBuso()
    if autoBusoTask then return end
    autoBusoTask=task.spawn(function()
        while _G.AutoBusoEnabled do
            local char=LP.Character if char and not char:FindFirstChild("HasBuso") then invoke("Buso") task.wait(0.3) end task.wait(0.5)
        end autoBusoTask=nil
    end)
end
local function stopAutoBuso() if autoBusoTask then task.cancel(autoBusoTask) autoBusoTask=nil end end

local bringMobTask,mobData,bringMobToggleRef=nil,{},nil
local function releaseMob(e)
    if not e then return end local data=mobData[e] if not data then return end
    if data.bp then pcall(function() data.bp:Destroy() end) end
    local ehrp=getEHRP(e)
    if ehrp then pcall(function() ehrp.Anchored=false end) pcall(function() ehrp.AssemblyLinearVelocity=Vector3.zero end) pcall(function() ehrp.AssemblyAngularVelocity=Vector3.zero end) end
    local h=getHum(e) if h then pcall(function() h.PlatformStand=false end) end
    if e.Parent then for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end end end
    mobData[e]=nil
end
local function cleanupMobs() for e in pairs(mobData) do releaseMob(e) end mobData={} end
local mobNoclipConn=nil
local function startMobNoclip()
    if mobNoclipConn then return end
    mobNoclipConn=RunService.Heartbeat:Connect(function()
        for e in pairs(mobData) do if e and e.Parent then for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then pcall(function() p.CanCollide=false end) end end end end
    end)
end
local function stopMobNoclip() if mobNoclipConn then mobNoclipConn:Disconnect() mobNoclipConn=nil end end
local function getAnchorPos()
    local cur=_G.CurrentFarmTarget
    if cur and cur.Parent and isAlive(cur) then local p=getEHRP(cur) if p then return p end end
    return nil
end
local function getMobOffset()
    if _G.BringMobOffsetMode=="custom" then return _G.BringMobCustomOffset end
    return Vector3.new(math.random(-5,5),0,math.random(-5,5))
end

local function startBringMob(targetMobName)
    _G.BringMobTargetName=targetMobName
    if bringMobTask then _G.BringMobTargetName=targetMobName return end
    cleanupMobs() startMobNoclip()
    local spawnConn=nil
    local ef=workspace:FindFirstChild("Enemies")
    if ef then
        spawnConn=ef.ChildAdded:Connect(function(e)
            task.wait(0.05)
            if not e or not e.Parent then return end
            local p=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p and not enemySpawnMemory[e] then enemySpawnMemory[e]=p.Position end
            e.AncestryChanged:Connect(function() if not e.Parent then enemySpawnMemory[e]=nil end end)
        end)
    end
    bringMobTask=task.spawn(function()
        local lastTarget=nil local lastBringName=nil
        while _G.BringMobEnabled do
            local anchorPart=getAnchorPos()
            if not anchorPart or not anchorPart.Parent then task.wait(0.1) continue end
            local cur=_G.CurrentFarmTarget local curBringName=_G.BringMobTargetName
            if cur~=lastTarget or curBringName~=lastBringName then cleanupMobs() lastTarget=cur lastBringName=curBringName end
            local ef2=workspace:FindFirstChild("Enemies") if not ef2 then task.wait(0.5) continue end
            for e in pairs(mobData) do if not e or not e.Parent or not isAlive(e) then releaseMob(e) end end
            if cur and cur.Parent and isAlive(cur) then
                local tehrp=getEHRP(cur)
                if tehrp then
                    if not mobData[cur] then
                        local bp=Instance.new("BodyPosition") bp.Name="BringMobBP" bp.MaxForce=Vector3.new(1e9,1e9,1e9) bp.P=100000 bp.D=2000 bp.Position=anchorPart.Position bp.Parent=tehrp
                        local h=getHum(cur) if h then pcall(function() h.PlatformStand=true end) end
                        for _,p in ipairs(cur:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end end
                        mobData[cur]={bp=bp,arrived=true,offset=Vector3.zero,stuckTime=0,lastPos=tehrp.Position,isTarget=true}
                    else
                        local d=mobData[cur] if d and d.bp and d.bp.Parent then d.bp.Position=anchorPart.Position d.bp.P=100000 end
                    end
                end
            end
            local pulling=0 for e in pairs(mobData) do if e~=cur then pulling+=1 end end
            for _,e in ipairs(ef2:GetChildren()) do
                if not _G.BringMobEnabled then break end
                if e==cur or not e or not e.Parent or isPC(e) or not isAlive(e) then continue end
                local filter=_G.BringMobTargetName
                if filter then local en=cleanName(e.Name) if en~=filter then if mobData[e] then releaseMob(e) end continue end end
                local ehrp=getEHRP(e) if not ehrp then continue end
                local distFromAnchor=(anchorPart.Position-ehrp.Position).Magnitude
                if distFromAnchor>_G.BringMobMaxDistance then if mobData[e] then releaseMob(e) end continue end
                if not mobData[e] then
                    if pulling>=_G.BringMobMaxBatch then continue end
                    local offset=getMobOffset()
                    local bp=Instance.new("BodyPosition") bp.Name="BringMobBP" bp.MaxForce=Vector3.new(1e9,1e9,1e9) bp.P=8000 bp.D=500 bp.Position=anchorPart.Position+offset bp.Parent=ehrp
                    local h=getHum(e) if h then pcall(function() h.PlatformStand=true end) end
                    for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end end
                    mobData[e]={bp=bp,arrived=false,offset=offset,stuckTime=0,lastPos=ehrp.Position,isTarget=false}
                    pulling+=1
                end
                local data=mobData[e] if not data or not data.bp or not data.bp.Parent then releaseMob(e) continue end
                local tp=anchorPart.Position+data.offset
                if not data.arrived then data.bp.Position=tp end
                local dist=(ehrp.Position-tp).Magnitude local moved=(ehrp.Position-data.lastPos).Magnitude
                if moved<0.1 then data.stuckTime+=0.05 else data.stuckTime=0 end
                data.lastPos=ehrp.Position
                if not data.arrived and dist<=3 then
                    if data.bp then pcall(function() data.bp:Destroy() end) end
                    local fbp=Instance.new("BodyPosition") fbp.Name="BringMobBP_Fixed" fbp.MaxForce=Vector3.new(1e9,1e9,1e9) fbp.P=100000 fbp.D=2000 fbp.Position=ehrp.Position fbp.Parent=ehrp
                    local h=getHum(e) if h then pcall(function() h.PlatformStand=true end) end
                    data.bp=fbp data.arrived=true
                elseif data.arrived then if not data.bp or not data.bp.Parent then releaseMob(e) end
                elseif data.stuckTime>=2 then
                    if _G.BringMobOffsetMode=="custom" then data.offset=_G.BringMobCustomOffset
                    else data.offset=Vector3.new(math.random(-5,5),math.random(8,20),math.random(-5,5)) end
                    data.stuckTime=0
                end
            end
            task.wait(0.05)
        end
        if spawnConn then spawnConn:Disconnect() end
        stopMobNoclip() cleanupMobs() bringMobTask=nil
    end)
end
local function stopBringMob()
    _G.BringMobEnabled=false _G.BringMobTargetName=nil
    if bringMobTask then task.cancel(bringMobTask) bringMobTask=nil end
    stopMobNoclip() cleanupMobs()
    if bringMobToggleRef then bringMobToggleRef:Set(false) end
end

local farmAuraTask,farmAuraActive,auraTargetPos=nil,false,nil
local function getRandSpawn()
    local sf=workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns")
    if sf then local sp=sf:GetChildren() if #sp>0 then local s=sp[math.random(1,#sp)] local pos if s:IsA("BasePart") then pos=s.Position else pcall(function() pos=s:GetPivot().Position end) end if pos then return pos+Vector3.new(0,50,0) end end end
    if _G.CurrentCircleIsland and _G.CurrentCircleIsland.Parent then
        local parts={} for _,p in ipairs(_G.CurrentCircleIsland:GetDescendants()) do if p:IsA("BasePart") then table.insert(parts,p) end end
        if #parts>0 then return parts[math.random(1,#parts)].Position+Vector3.new(0,80,0) end
    end
end
local function startFarmAura()
    if farmAuraTask then return end farmAuraActive=true auraTargetPos=nil
    farmAuraTask=task.spawn(function()
        while farmAuraActive and _G.FarmAuraEnabled do
            while not isAlive(LP.Character) and farmAuraActive do task.wait(0.5) end
            if not farmAuraActive or not _G.FarmAuraEnabled then break end
            if _G.AutoGrabFruitEnabled and hasFruit() then
                local hrp=getHRP(LP.Character)
                if hrp then local bv=hrp:FindFirstChild("FarmAuraBV") if bv then bv.Velocity=Vector3.zero end local bp=hrp:FindFirstChild("FarmAuraBP") if bp then bp.MaxForce=Vector3.zero end end
                doFruitCycle() task.wait(0.3) continue
            end
            local hrp=getHRP(LP.Character) if not hrp then task.wait(0.5) continue end
            local cl=getClosestEnemy()
            if cl and cl.enemy then
                _G.CurrentFarmTarget=cl.enemy
                local ep=cl.part
                if ep and (hrp.Position-ep.Position).Magnitude>1000 then fireEntrance(ep.Position) task.wait(0.8) hrp=getHRP(LP.Character) if not hrp then continue end end
                snapY(ep.Position) hrp=getHRP(LP.Character) if not hrp then continue end
                local bv=makeBV(hrp,"FarmAuraBV")
                local bp=Instance.new("BodyPosition") bp.Name="FarmAuraBP" bp.MaxForce=Vector3.new(9e9,9e9,9e9) bp.P=50000 bp.D=2500 bp.Parent=hrp
                local arrived=false
                while farmAuraActive and _G.FarmAuraEnabled do
                    if not isAlive(LP.Character) then bv.Velocity=Vector3.zero bp.MaxForce=Vector3.zero break end
                    if _G.AutoGrabFruitEnabled and hasFruit() then bv.Velocity=Vector3.zero bp.MaxForce=Vector3.zero break end
                    hrp=getHRP(LP.Character) if not hrp then break end
                    local c2=getClosestEnemy() if not c2 then break end
                    local tp=getPlayerTarget(c2.part.Position)
                    local dist=(hrp.Position-tp).Magnitude
                    if dist>8 then bv.Velocity=(tp-hrp.Position).Unit*math.clamp(dist*8,30,SPEED) bp.MaxForce=Vector3.zero arrived=false
                    else bv.Velocity=Vector3.zero bp.Position=tp bp.MaxForce=Vector3.new(9e9,9e9,9e9)
                        if not arrived then arrived=true _G.BringMobTargetName=nil if _G.BringMobEnabled and not bringMobTask then startBringMob(nil) end end
                    end
                    task.wait(0.05)
                end
                pcall(function() bv:Destroy() end) pcall(function() bp:Destroy() end)
            else
                if not auraTargetPos or (hrp.Position-auraTargetPos).Magnitude<15 then
                    auraTargetPos=getRandSpawn() if not auraTargetPos then task.wait(1) continue end
                    if (hrp.Position-auraTargetPos).Magnitude>1000 then fireEntrance(auraTargetPos) task.wait(0.8) hrp=getHRP(LP.Character) if not hrp then continue end end
                end
                snapY(auraTargetPos) hrp=getHRP(LP.Character) if not hrp then continue end
                local bv=makeBV(hrp,"FarmAuraBV")
                while farmAuraActive and _G.FarmAuraEnabled do
                    if not isAlive(LP.Character) then bv.Velocity=Vector3.zero break end
                    if _G.AutoGrabFruitEnabled and hasFruit() then bv.Velocity=Vector3.zero break end
                    hrp=getHRP(LP.Character) if not hrp then break end
                    local d=(hrp.Position-auraTargetPos).Magnitude
                    if d<12 then bv.Velocity=Vector3.zero break end
                    bv.Velocity=(auraTargetPos-hrp.Position).Unit*math.clamp(d*6,40,SPEED) task.wait(0.08)
                end
                local ws=tick()
                while farmAuraActive and _G.FarmAuraEnabled do
                    if not isAlive(LP.Character) then break end
                    if _G.AutoGrabFruitEnabled and hasFruit() then break end
                    hrp=getHRP(LP.Character) if not hrp then break end
                    if getClosestEnemy() then break end
                    if tick()-ws>=25 then local np=getRandSpawn() if np then auraTargetPos=np end ws=tick() end task.wait(0.2)
                end
                pcall(function() local b=hrp and hrp:FindFirstChild("FarmAuraBV") if b then b:Destroy() end end)
                auraTargetPos=nil
            end
            task.wait(0.1)
        end
    end)
end
local function stopFarmAura()
    farmAuraActive=false auraTargetPos=nil
    if farmAuraTask then task.cancel(farmAuraTask) farmAuraTask=nil end
    local hrp=getHRP(LP.Character)
    if hrp then for _,n in ipairs({"FarmAuraBV","FarmAuraBP"}) do local o=hrp:FindFirstChild(n) if o then o:Destroy() end end end
    if _G.BringMobEnabled then stopBringMob() end
end

local farmSelectTask=nil
local function isSelectedEnemy(e)
    if not e or not e.Parent then return false end
    local n=e.Name
    for _,sel in ipairs(_G.SelectedEnemyNames) do
        local cs=sel:gsub(" %*$","") local cn=cleanName(n)
        if cn==cs or cn:find(cs,1,true) or cs:find(cn,1,true) then return true end
    end return false
end
local function findSelectedEnemy()
    local hrp=getHRP(LP.Character) if not hrp then return nil end
    local ef=workspace:FindFirstChild("Enemies") if not ef then return nil end
    local cl,cd=nil,math.huge
    for _,e in ipairs(ef:GetChildren()) do
        if e and e.Parent and isAlive(e) and isSelectedEnemy(e) then
            local p=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
            if p then local d=(hrp.Position-p.Position).Magnitude if d<cd then cd=d cl={enemy=e,part=p} end end
        end
    end return cl
end
local function getSelectedSpawns()
    local pts={}
    local wo=workspace:FindFirstChild("_WorldOrigin")
    local sf=wo and wo:FindFirstChild("EnemySpawns")
    for _,sel in ipairs(_G.SelectedEnemyNames) do
        local cs=sel:gsub(" %*$","")
        if sf then
            for _,s in ipairs(sf:GetChildren()) do
                local n=(s.Name:match("^(.-)%s*%[") or s.Name):match("^%s*(.-)%s*$")
                if n==cs then
                    local pos
                    if s:IsA("BasePart") then pos=s.Position else local ok,p=pcall(function() return s:GetPivot().Position end) if ok then pos=p end end
                    if pos then table.insert(pts,pos+Vector3.new(0,5,0)) end
                end
            end
        end
        if #pts==0 then
            local ef=workspace:FindFirstChild("Enemies")
            if ef then for _,e in ipairs(ef:GetChildren()) do if e and e.Parent then local en=(e.Name:match("^(.-)%s*%[") or e.Name):match("^%s*(.-)%s*$") if en==cs then local p=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart") if p then table.insert(pts,p.Position+Vector3.new(0,5,0)) end end end end end
        end
    end
    return pts
end

local function startFarmSelect()
    if farmSelectTask then return end
    farmSelectTask=task.spawn(function()
        for _,sel in ipairs(_G.SelectedEnemyNames) do fireEntranceForEnemy(sel:gsub(" %*$","")) task.wait(0.2) end
        task.wait(1.5)
        local spIdx=1 local lastSelected={}
        while _G.FarmSelectEnabled do
            while not isAlive(LP.Character) and _G.FarmSelectEnabled do task.wait(0.5) end
            if not _G.FarmSelectEnabled then break end
            if #_G.SelectedEnemyNames==0 then task.wait(1) continue end
            local selChanged=false
            if #_G.SelectedEnemyNames~=#lastSelected then selChanged=true
            else for i,v in ipairs(_G.SelectedEnemyNames) do if lastSelected[i]~=v then selChanged=true break end end end
            if selChanged then lastSelected=table.clone(_G.SelectedEnemyNames) spIdx=1 _G.BringMobTargetName=nil if bringMobTask then cleanupMobs() end end
            if _G.AutoGrabFruitEnabled and hasFruit() then
                local hrp=getHRP(LP.Character) if hrp then local bv=hrp:FindFirstChild("FarmSelectBV") if bv then bv.Velocity=Vector3.zero end end
                doFruitCycle() task.wait(0.3) continue
            end
            local hrp=getHRP(LP.Character) if not hrp then task.wait(1) continue end
            local target=findSelectedEnemy()
            if target then
                _G.CurrentFarmTarget=target.enemy
                notifyOnce(target.enemy,"Farm Select",target.enemy.Name)
                local ep=target.part
                if ep and (hrp.Position-ep.Position).Magnitude>1000 then fireEntrance(ep.Position) task.wait(0.8) hrp=getHRP(LP.Character) if not hrp then continue end end
                snapY(ep.Position) hrp=getHRP(LP.Character) if not hrp then continue end
                local bv=makeBV(hrp,"FarmSelectBV") local arrived=false
                while _G.FarmSelectEnabled do
                    if not isAlive(LP.Character) then bv.Velocity=Vector3.zero break end
                    if _G.AutoGrabFruitEnabled and hasFruit() then bv.Velocity=Vector3.zero break end
                    hrp=getHRP(LP.Character) if not hrp then break end
                    if not target.enemy or not target.enemy.Parent or not isAlive(target.enemy) then break end
                    local selCh=false
                    if #_G.SelectedEnemyNames~=#lastSelected then selCh=true
                    else for i,v in ipairs(_G.SelectedEnemyNames) do if lastSelected[i]~=v then selCh=true break end end end
                    if selCh then bv.Velocity=Vector3.zero break end
                    local p=target.enemy:FindFirstChild("HumanoidRootPart") or target.enemy:FindFirstChildWhichIsA("BasePart") if not p then break end
                    local tp=getPlayerTarget(p.Position)
                    local d=(hrp.Position-tp).Magnitude
                    if d<8 then bv.Velocity=Vector3.zero
                        if not arrived then arrived=true _G.BringMobTargetName=nil if _G.BringMobEnabled and not bringMobTask then startBringMob(nil) end end
                    else bv.Velocity=(tp-hrp.Position).Unit*math.clamp(d*8,30,SPEED) arrived=false end
                    task.wait(0.05)
                end
                pcall(function() bv:Destroy() end) _G.CurrentFarmTarget=nil
            else
                local cached=getSelectedSpawns()
                if #cached==0 then task.wait(1) continue end
                if spIdx>#cached then spIdx=1 end
                local wp=cached[spIdx]
                if (hrp.Position-wp).Magnitude>1000 then fireEntrance(wp) task.wait(0.8) hrp=getHRP(LP.Character) if not hrp then continue end end
                snapY(wp) hrp=getHRP(LP.Character) if not hrp then continue end
                local bv=makeBV(hrp,"FarmSelectBV")
                while _G.FarmSelectEnabled do
                    if not isAlive(LP.Character) then bv.Velocity=Vector3.zero break end
                    if _G.AutoGrabFruitEnabled and hasFruit() then bv.Velocity=Vector3.zero break end
                    hrp=getHRP(LP.Character) if not hrp then break end
                    if findSelectedEnemy() then bv.Velocity=Vector3.zero break end
                    local selCh=false
                    if #_G.SelectedEnemyNames~=#lastSelected then selCh=true
                    else for i,v in ipairs(_G.SelectedEnemyNames) do if lastSelected[i]~=v then selCh=true break end end end
                    if selCh then bv.Velocity=Vector3.zero break end
                    local d=(hrp.Position-wp).Magnitude
                    if d<10 then
                        bv.Velocity=Vector3.zero
                        spIdx=(spIdx%#cached)+1
                        task.wait(0.1)
                        break
                    end
                    bv.Velocity=(wp-hrp.Position).Unit*math.clamp(d*6,40,SPEED) task.wait(0.05)
                end
                pcall(function() bv:Destroy() end) task.wait(0.05)
            end
        end
        _G.CurrentFarmTarget=nil farmSelectTask=nil
    end)
end
local function stopFarmSelect()
    _G.FarmSelectEnabled=false if farmSelectTask then task.cancel(farmSelectTask) farmSelectTask=nil end
    local h=getHRP(LP.Character) if h then local bv=h:FindFirstChild("FarmSelectBV") if bv then pcall(function() bv:Destroy() end) end end
    _G.CurrentFarmTarget=nil lastNotifiedTarget=nil if _G.BringMobEnabled then stopBringMob() end
end

local autoFarmLevelTask=nil
local function abandonQuest() invoke("AbandonQuest") task.wait(0.8) end
local function getQuestTitle() local ok,t=pcall(function() return LP.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text end) return ok and t~="" and t or nil end
local function isCorrectQuest(mob) local t=getQuestTitle() if not t then return true end return t:lower():find(mob:lower(),1,true)~=nil end
local function getPlayerLevel() local ok,lv=pcall(function() return LP.Data.Level.Value end) return ok and lv or 0 end
local function isQuestActive() local ok,v=pcall(function() return LP.PlayerGui.Main.Quest.Visible end) return ok and v==true end
local function getQuestForLevel(lv) for _,q in ipairs(LevelQuestData) do if lv>=q.minLv and lv<=q.maxLv then return q end end return nil end
local function findEnemyByName(name)
    local hrp=getHRP(LP.Character) if not hrp then return nil end
    local ef=workspace:FindFirstChild("Enemies") if not ef then return nil end
    local cl,cd=nil,math.huge
    for _,e in ipairs(ef:GetChildren()) do
        if e and e.Parent and isAlive(e) then
            local en=cleanName(e.Name)
            if en==name then
                local p=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChildWhichIsA("BasePart")
                if p then local d=(hrp.Position-p.Position).Magnitude if d<cd then cd=d cl={enemy=e,part=p} end end
            end
        end
    end return cl
end

local function huntMob(mobName)
    _G.CurrentQuestMobName=mobName
    if not _G.AutoFarmLevelEnabled then return end
    if isQuestActive() then
        task.wait(0.3)
        if not isCorrectQuest(mobName) then notify("Level Farm","Wrong quest: "..(getQuestTitle() or "?"),3) abandonQuest() return end
    end
    local spIdx=1
    local hrp=getHRP(LP.Character) if not hrp then return end
    local bv=makeBV(hrp,"LevelFarmBV")
    local arrived=false local currentTarget=nil local lastEntrance=0

    local function tryEntrance(targetPos)
        local h=getHRP(LP.Character) if not h then return end
        if (h.Position-targetPos).Magnitude>1000 and tick()-lastEntrance>3 then
            bv.Velocity=Vector3.zero fireEntrance(targetPos) lastEntrance=tick() task.wait(0.8)
        end
    end

    while _G.AutoFarmLevelEnabled do
        local curLv=getPlayerLevel() local curQd=getQuestForLevel(curLv)
        if curQd and curQd.mobName~=mobName then
            pcall(function() bv.Velocity=Vector3.zero end) pcall(function() bv:Destroy() end)
            _G.CurrentFarmTarget=nil currentTarget=nil return
        end
        if not isAlive(LP.Character) then
            pcall(function() bv.Velocity=Vector3.zero end)
            while not isAlive(LP.Character) and _G.AutoFarmLevelEnabled do task.wait(0.5) end
            hrp=getHRP(LP.Character) if not hrp then break end
            local old=hrp:FindFirstChild("LevelFarmBV") if old then old:Destroy() end
            bv=Instance.new("BodyVelocity") bv.Name="LevelFarmBV" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero bv.Parent=hrp
            arrived=false currentTarget=nil _G.CurrentFarmTarget=nil lastEntrance=0
        end
        if not _G.AutoFarmLevelEnabled then break end
        if not isQuestActive() then notify("Level Farm","Quest done!",2) break end
        if not isCorrectQuest(mobName) then notify("Level Farm","Quest changed | Abandoning...",3) abandonQuest() break end
        hrp=getHRP(LP.Character) if not hrp then task.wait(0.5) continue end
        local target=findEnemyByName(mobName)
        if target then
            local ep=target.part if not ep or not ep.Parent then task.wait(0.05) continue end
            if currentTarget~=target.enemy then
                arrived=false currentTarget=target.enemy _G.CurrentFarmTarget=target.enemy
                if _G.BringMobEnabled then cleanupMobs() end
            end
            tryEntrance(ep.Position) hrp=getHRP(LP.Character) if not hrp then continue end
            if not target.enemy or not target.enemy.Parent or not isAlive(target.enemy) then
                arrived=false currentTarget=nil _G.CurrentFarmTarget=nil bv.Velocity=Vector3.zero task.wait(0.05) continue
            end
            local p2=target.enemy:FindFirstChild("HumanoidRootPart") or target.enemy:FindFirstChildWhichIsA("BasePart")
            if not p2 then bv.Velocity=Vector3.zero task.wait(0.05) continue end
            local tp=getPlayerTarget(p2.Position)
            snapY(tp) hrp=getHRP(LP.Character) if not hrp then continue end
            local d=(hrp.Position-tp).Magnitude
            if d<8 then
                bv.Velocity=Vector3.zero
                if not arrived then
                    arrived=true _G.CurrentFarmTarget=target.enemy _G.BringMobTargetName=mobName
                    if _G.BringMobEnabled then if bringMobTask then _G.BringMobTargetName=mobName else startBringMob(mobName) end end
                end
            else bv.Velocity=(tp-hrp.Position).Unit*math.clamp(d*8,30,SPEED) arrived=false end
        else
            arrived=false
            if currentTarget then currentTarget=nil _G.CurrentFarmTarget=nil if _G.BringMobEnabled then cleanupMobs() end end
            local spawnPts=getSpawnPositionsForName(mobName)
            if #spawnPts==0 then bv.Velocity=Vector3.zero task.wait(0.5) continue end
            if spIdx>#spawnPts then spIdx=1 end
            local wp=spawnPts[spIdx]
            tryEntrance(wp) hrp=getHRP(LP.Character) if not hrp then continue end
            snapY(wp) hrp=getHRP(LP.Character) if not hrp then continue end
            local d=(hrp.Position-wp).Magnitude
            if d<15 then bv.Velocity=Vector3.zero spIdx=(spIdx%#spawnPts)+1 task.wait(0.1)
            else bv.Velocity=(wp-hrp.Position).Unit*math.clamp(d*6,40,SPEED) end
        end
        task.wait(0.05)
    end
    pcall(function() bv.Velocity=Vector3.zero end) pcall(function() bv:Destroy() end)
    _G.CurrentFarmTarget=nil currentTarget=nil
end

local function startAutoFarmLevel()
    if autoFarmLevelTask then return end
    autoFarmLevelTask=task.spawn(function()
        enableNoclip() notify("Level Farm","Started!",3)
        local lastQd=nil
        local function ensureBV()
            local hrp=getHRP(LP.Character) if not hrp then return nil end
            local bv=hrp:FindFirstChild("LevelFarmBV")
            if not bv then bv=Instance.new("BodyVelocity") bv.Name="LevelFarmBV" bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Velocity=Vector3.zero bv.Parent=hrp end
            return bv
        end
        local function tweenToQuestPos(questPos)
            local hrp=getHRP(LP.Character) if not hrp then return end
            snapY(questPos) hrp=getHRP(LP.Character) if not hrp then return end
            local bv=ensureBV() if not bv then return end
            while _G.AutoFarmLevelEnabled do
                if not isAlive(LP.Character) then break end
                hrp=getHRP(LP.Character) if not hrp then break end
                local d=(hrp.Position-questPos).Magnitude
                if d<5 then bv.Velocity=Vector3.zero break end
                bv.Velocity=(questPos-hrp.Position).Unit*math.clamp(d*6,40,SPEED)
                task.wait(0.05)
            end
        end
        local function acceptQuest(qd)
            local hrp=getHRP(LP.Character) if not hrp then return end
            if qd.entranceVec and (hrp.Position-qd.questPos).Magnitude>1000 then invoke("requestEntrance",qd.entranceVec) task.wait(1) end
            tweenToQuestPos(qd.questPos)
            task.wait(0.3) invoke(table.unpack(qd.questRemote)) task.wait(0.5)
            if not isQuestActive() then invoke(table.unpack(qd.questRemote)) task.wait(0.5) end
        end
        while _G.AutoFarmLevelEnabled do
            while not isAlive(LP.Character) and _G.AutoFarmLevelEnabled do task.wait(0.5) end
            if not _G.AutoFarmLevelEnabled then break end
            local lv=getPlayerLevel() local qd=getQuestForLevel(lv)
            if not qd then notify("Level Farm","No quest for lv "..lv,4) _G.AutoFarmLevelEnabled=false break end
            if lastQd~=qd then
                lastQd=qd notify("Level Farm","Lv "..lv.." | "..qd.questRemote[2],3)
                _G.CurrentQuestMobName=qd.mobName _G.BringMobTargetName=qd.mobName
                if bringMobTask then cleanupMobs() end
            end
            if not isQuestActive() then acceptQuest(qd) continue end
            local newQd=getQuestForLevel(getPlayerLevel()) if newQd and newQd~=qd then continue end
            if isQuestActive() then
                task.wait(0.5)
                if not isCorrectQuest(qd.mobName) then
                    notify("Level Farm","Wrong quest | Abandoning...",3) abandonQuest() task.wait(0.5) acceptQuest(qd)
                else huntMob(qd.mobName) end
            end
            task.wait(0.3)
        end
        autoFarmLevelTask=nil disableNoclip() notify("Level Farm","Stopped.",2)
    end)
end
local function stopAutoFarmLevel()
    _G.AutoFarmLevelEnabled=false _G.CurrentQuestMobName=nil
    if autoFarmLevelTask then task.cancel(autoFarmLevelTask) autoFarmLevelTask=nil end
    local hrp=getHRP(LP.Character) if hrp then local bv=hrp:FindFirstChild("LevelFarmBV") if bv then pcall(function() bv:Destroy() end) end end
    _G.CurrentFarmTarget=nil stopBringMob()
    if bringMobToggleRef then bringMobToggleRef:Set(false) end
end

local autoStatTasks={}
local function addStat(s) invoke("AddPoint",s,1) end
local function startStat(s) if autoStatTasks[s] then return end autoStatTasks[s]=task.spawn(function() while _G.AutoStatEnabled[s] do addStat(s) task.wait(_G.AutoStatDelay) end autoStatTasks[s]=nil end) end
local function stopStat(s) if autoStatTasks[s] then task.cancel(autoStatTasks[s]) autoStatTasks[s]=nil end end

local REDEEM_CODES={
    "EASTEREXP","LIGHTNINGABUSE","KITT_RESET","Sub2CaptainMaui",
    "SUB2GAMERROBOT_RESET1","kittgaming","Magicbus","JCWK",
    "Sub2Fer999","Enyu_is_Pro","Starcodeheo","Bluxxy",
    "BIGNEWS","THEGREATACE","FUDD10","fudd10_v2",
    "Sub2Daigrock","Sub2UncleKizaru","Axiore","TantaiGaming",
    "SUB2GAMERROBOT_EXP1","SUB2NOOBMASTER123","StrawHatMaine",
    "Sub2OfficialNoobie"
}
local function redeemCode(code)
    local ok=pcall(function() RS:WaitForChild("Remotes"):WaitForChild("Redeem"):InvokeServer(code) end)
    return ok
end
local function redeemAllCodes()
    notify("Redeem","Redeeming all codes...",3)
    local success,failed=0,0
    for _,code in ipairs(REDEEM_CODES) do if redeemCode(code) then success+=1 else failed+=1 end task.wait(0.5) end
    notify("Redeem","Done! "..success.." success / "..failed.." failed",5)
end

local function StartFarming()
    task.spawn(function()
        local chatConn=nil
        pcall(function()
            chatConn=game:GetService("TextChatService").MessageReceived:Connect(function(msg)
                if not _G.AutoFarmEnabled then return end
                local text=msg.Text or "" local lower=text:lower()
                if lower:find("sealed showdown egg") and lower:find("spawned") then
                    local iname=text:match("[Ss]pawned on ([%w%s%-_]+)") or text:match("[Ss]pawned at ([%w%s%-_]+)")
                    if iname then iname=iname:match("^%s*(.-)%s*$"):gsub("[%!%.]+$",""):match("^%s*(.-)%s*$") sealedEggTargetIsland=iname sealedEggBlacklist={} notify("Sealed Egg","Egg on "..iname,4)
                    else sealedEggBlacklist={} notify("Sealed Egg","Egg spawned",3) end
                end
            end)
        end)
        task.spawn(function() while _G.AutoFarmEnabled do task.wait(15) _G.ChestBlacklist={} _G.ShardBlacklist={} end end)
        while _G.AutoFarmEnabled do
            local sE,sP=findSealedEgg()
            if not sE and sealedEggTargetIsland then
                local tn=sealedEggTargetIsland local island=workspace.Map:FindFirstChild(tn)
                if not island then for _,ch in ipairs(workspace.Map:GetChildren()) do if ch:IsA("Model") and ch.Name:lower():find(tn:lower()) then island=ch break end end end
                if island then notify("Sealed Egg","Searching "..island.Name,3) Clip=false sE,sP=searchIslandForSealed(island) Clip=true end
                sealedEggTargetIsland=nil
            end
            if sE and sP then
                notify("Sealed Egg","Found",2) Clip=false local arrived=tweenToSealed(sP) Clip=true
                if arrived and sP and sP.Parent then task.wait(0.1) fireProximity(sP) end
                sealedEggBlacklist[sE]=true task.wait(1) continue
            end
            while not isAlive(LP.Character) and _G.AutoFarmEnabled do lastNotifiedTarget=nil _G.CurrentCircleIsland=nil _G.CurrentCircleIndex=1 _G.CurrentCircleRound=1 task.wait(2) end
            if not _G.AutoFarmEnabled then break end
            local c=LP.Character local hrp=getHRP(c) local att=0
            while (not c or not hrp) and att<10 and _G.AutoFarmEnabled do task.wait(0.5) c=LP.Character hrp=getHRP(c) att+=1 end
            if not hrp then task.wait(1) continue end
            local egg=getSpecialEgg()
            if egg and not _G.QuestModeEnabled then local h2=getHum(c) if h2 then h2.Health=0 task.wait(2) end continue end
            if _G.QuestModeEnabled and egg then
                local gui=LP.PlayerGui:FindFirstChild("Main") local dlg=gui and gui:FindFirstChild("Dialogue") local btn=dlg and dlg:FindFirstChild("Option1")
                local a2=0 while (not btn or not btn.Visible) and a2<10 and _G.AutoFarmEnabled do task.wait(0.5) gui=LP.PlayerGui:FindFirstChild("Main") dlg=gui and gui:FindFirstChild("Dialogue") btn=dlg and dlg:FindFirstChild("Option1") a2+=1 end
                c=LP.Character hrp=getHRP(c) if not hrp then task.wait(1) continue end
                local h2=getHum(c) if egg.Parent~=c and h2 then h2:EquipTool(egg) task.wait(0.3) end
                local n=egg.Name
                if n=="Firefly Egg" or n=="Friendly Neighborhood Egg" then notifyOnce(egg,"Quest",n) deliverFriendlyEgg(egg)
                elseif n:find("Falling") then notifyOnce(egg,"Quest",n) deliverFallingSkyEgg(egg)
                elseif n:find("Thirsty") then notifyOnce(egg,"Quest",n) deliverThirstyEgg(egg)
                elseif n:find("Molten") then notifyOnce(egg,"Quest",n) deliverMoltenEgg(egg)
                else task.wait(1) end
                task.wait(1.5) _G.CurrentCircleIsland=nil while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end continue
            end
            if not _G.CurrentCircleIsland or not _G.CurrentCircleIsland.Parent then
                _G.CurrentCircleIsland=getNextIsland() if not _G.CurrentCircleIsland then task.wait(1) continue end
                _G.CurrentCircleIndex=1 _G.CurrentCircleRound=1
                local ok,pivot=pcall(function() return _G.CurrentCircleIsland:GetPivot().Position end)
                if ok and _G.AutoFarmEnabled then
                    notifyOnce(_G.CurrentCircleIsland,"Moving",_G.CurrentCircleIsland.Name)
                    if (getHRP(LP.Character).Position-pivot).Magnitude>1000 then fireEntrance(pivot) task.wait(0.8) end
                    local int=moveTo(pivot+Vector3.new(0,80,0),nil,"Travel",true,false) if int then while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end end
                end
            end
            if _G.FarmMode=="random" then if hasAnyTarget() then collectTargets() else _G.CurrentCircleIsland=nil end task.wait(0.1) continue end
            local route=getIslandRoute(_G.CurrentCircleIsland.Name) or genBBoxRoute(_G.CurrentCircleIsland)
            if not route or #route==0 then if hasAnyTarget() then collectTargets() else _G.CurrentCircleIsland=nil end task.wait(0.5) continue end
            local result=circleStep(route)
            if result=="target_found" then while _G.AutoFarmEnabled and collectTargets() do task.wait(0.1) end _G.CurrentCircleIndex+=1
            elseif result=="finished" then _G.CurrentCircleIsland=nil end
            task.wait(0.1)
        end
        if chatConn then pcall(function() chatConn:Disconnect() end) end
    end)
end

-- UI
local Window=WindUI:CreateWindow({
    Title="Easter Farm",Icon="solar:star-bold-duotone",Folder="EasterFarm",
    NewElements=true,Topbar={Height=44,ButtonsType="Mac"},
    OpenButton={Title="Easter Farm",Enabled=true,Draggable=true,OnlyMobile=false,
    StrokeThickness=0,CornerRadius=UDim.new(1,0),
    Color=ColorSequence.new(Color3.fromHex("#ff9f3d"),Color3.fromHex("#ff5c5c"))}
})

local UIS=game:GetService("UserInputService")
if UIS.TouchEnabled and not UIS.KeyboardEnabled then
    local sg=Instance.new("ScreenGui") sg.Name="EasterFarmMobileBtn" sg.ResetOnSpawn=false sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling sg.DisplayOrder=999 sg.Parent=LP.PlayerGui
    local btn=Instance.new("TextButton") btn.Size=UDim2.new(0,80,0,80) btn.Position=UDim2.new(0,12,0.5,-40) btn.BackgroundColor3=Color3.fromHex("#ff7a30") btn.TextColor3=Color3.new(1,1,1) btn.Text="E" btn.TextSize=32 btn.Font=Enum.Font.GothamBold btn.ZIndex=10 btn.Parent=sg
    local c2=Instance.new("UICorner") c2.CornerRadius=UDim.new(1,0) c2.Parent=btn
    local st=Instance.new("UIStroke") st.Color=Color3.fromHex("#ffffff") st.Thickness=2 st.Transparency=0.5 st.Parent=btn
    local dragging,dragStart,startPos=false,nil,nil
    btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=i.Position startPos=btn.Position end end)
    btn.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-dragStart btn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
    btn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then local d=i.Position-dragStart local m=math.abs(d.X)+math.abs(d.Y) dragging=false if m<10 then Window:Toggle() end end end)
end

local FarmTab=Window:Tab({Title="Auto Farm",Icon="solar:egg-bold-duotone"})
local ES=FarmTab:Section({Title="Easter Egg",Box=true,BoxBorder=true,Opened=true})
ES:Dropdown({Title="Farm Mode",Values={"Random","Circle"},Value=_G.FarmMode=="circle" and 2 or 1,Callback=function(v) _G.FarmMode=(v=="Random") and "random" or "circle" saveSettings() end})
ES:Space()
ES:Toggle({Title="Auto Farm",Value=false,Callback=function(v)
    _G.AutoFarmEnabled=v
    if v then sealedEggBlacklist={} sealedEggTargetIsland=nil StartFarming() enableNoclip() enableAntiSit()
    else lastNotifiedTarget=nil _G.CurrentCircleIsland=nil sealedEggBlacklist={} sealedEggTargetIsland=nil disableNoclip() disableAntiSit()
        local hrp=getHRP(LP.Character) if hrp then for _,n in ipairs({"Lock","HoldBV","HoldBP","SealedEggLock","FriendlyLock","ThirstyLock","MoltenLock"}) do local o=hrp:FindFirstChild(n) if o then pcall(function() o:Destroy() end) end end end
    end
end})
ES:Space()
ES:Toggle({Title="Quest Delivery",Value=_G.QuestModeEnabled,Callback=function(v) _G.QuestModeEnabled=v lastNotifiedTarget=nil saveSettings() end})

local AuraTab=Window:Tab({Title="Aura & Farm",Icon="solar:fire-bold-duotone"})
local LS=AuraTab:Section({Title="Auto Farm Level",Box=true,BoxBorder=true,Opened=true})
LS:Toggle({Title="Auto Farm Level",Value=_G.AutoFarmLevelEnabled,Callback=function(v)
    _G.AutoFarmLevelEnabled=v saveSettings()
    if v then startAutoFarmLevel() _G.BringMobEnabled=true if bringMobToggleRef then bringMobToggleRef:Set(true) end
    else stopAutoFarmLevel() stopBringMob() if bringMobToggleRef then bringMobToggleRef:Set(false) end end
end})
LS:Space()
local AS=AuraTab:Section({Title="Farm Aura",Box=true,BoxBorder=true,Opened=true})
AS:Toggle({Title="Farm Aura",Value=_G.FarmAuraEnabled,Callback=function(v)
    _G.FarmAuraEnabled=v saveSettings()
    if v then enableNoclip() startFarmAura() _G.BringMobEnabled=true startBringMob(nil) if bringMobToggleRef then bringMobToggleRef:Set(true) end
    else stopFarmAura() end
end})
AS:Space()
bringMobToggleRef=AS:Toggle({Title="Bring Mob",Value=_G.BringMobEnabled,Callback=function(v)
    _G.BringMobEnabled=v saveSettings()
    if v then
        if not _G.FarmAuraEnabled and not _G.FarmSelectEnabled and not _G.AutoFarmLevelEnabled then _G.BringMobEnabled=false if bringMobToggleRef then bringMobToggleRef:Set(false) end return end
        startBringMob(nil)
    else stopBringMob() end
end})
AS:Space()

local SS=AuraTab:Section({Title="Farm Select",Box=true,BoxBorder=true,Opened=true})
local eList=getEnemyNames() if #eList==0 then eList={"(No enemies found)"} end
enemyDropdownRef=SS:Dropdown({Title="Select Enemy",Values=eList,Value=nil,AllowNone=true,Multi=true,Callback=function(sel) _G.SelectedEnemyNames=type(sel)=="table" and sel or (sel and {sel} or {}) lastNotifiedTarget=nil end})
SS:Space()
SS:Toggle({Title="Farm Selected Enemy",Value=false,Callback=function(v)
    _G.FarmSelectEnabled=v
    if v then
        if #_G.SelectedEnemyNames==0 then _G.FarmSelectEnabled=false return end
        enableNoclip() startFarmSelect() _G.BringMobEnabled=true startBringMob(nil) if bringMobToggleRef then bringMobToggleRef:Set(true) end
    else stopFarmSelect() end
end})
SS:Space()
SS:Button({Title="Refresh Enemy List",Callback=function() refreshEnemyDropdown() notify("Refresh","Enemy list updated",2) end})

local CombatTab=Window:Tab({Title="Combat",Icon="solar:shield-bold-duotone"})
local CS=CombatTab:Section({Title="Combat",Box=true,BoxBorder=true,Opened=true})
CS:Toggle({Title="Damage Aura",Value=_G.DamageAuraEnabled,Callback=function(v) _G.DamageAuraEnabled=v saveSettings() if v then startDamageAura() else stopDamageAura() end end})
CS:Space()
CS:Toggle({Title="Auto Buso",Value=_G.AutoBusoEnabled,Callback=function(v) _G.AutoBusoEnabled=v saveSettings() if v then startAutoBuso() else stopAutoBuso() end end})

local StatTab=Window:Tab({Title="Auto Stat",Icon="solar:chart-bold-duotone"})
local STS=StatTab:Section({Title="Stat Points",Box=true,BoxBorder=true,Opened=true})
STS:Toggle({Title="Melee",Value=_G.AutoStatEnabled.Melee,Callback=function(v) _G.AutoStatEnabled.Melee=v saveSettings() if v then startStat("Melee") else stopStat("Melee") end end}) STS:Space()
STS:Toggle({Title="Defense",Value=_G.AutoStatEnabled.Defense,Callback=function(v) _G.AutoStatEnabled.Defense=v saveSettings() if v then startStat("Defense") else stopStat("Defense") end end}) STS:Space()
STS:Toggle({Title="Sword",Value=_G.AutoStatEnabled.Sword,Callback=function(v) _G.AutoStatEnabled.Sword=v saveSettings() if v then startStat("Sword") else stopStat("Sword") end end}) STS:Space()
STS:Toggle({Title="Gun",Value=_G.AutoStatEnabled.Gun,Callback=function(v) _G.AutoStatEnabled.Gun=v saveSettings() if v then startStat("Gun") else stopStat("Gun") end end}) STS:Space()
STS:Toggle({Title="Demon Fruit",Value=_G.AutoStatEnabled.DemonFruit,Callback=function(v) _G.AutoStatEnabled.DemonFruit=v saveSettings() if v then startStat("Demon Fruit") else stopStat("Demon Fruit") end end}) STS:Space()
STS:Slider({Title="Delay (s)",Step=0.05,Value={Min=0.05,Max=2,Default=_G.AutoStatDelay},Callback=function(v) _G.AutoStatDelay=v saveSettings() for s,en in pairs(_G.AutoStatEnabled) do if en then stopStat(s) startStat(s) end end end})

local SetTab=Window:Tab({Title="Settings",Icon="solar:settings-bold-duotone"})
local SpS=SetTab:Section({Title="Speed & Timing",Box=true,BoxBorder=true,Opened=true})
SpS:Slider({Title="Tween Speed",Step=10,Value={Min=50,Max=600,Default=SPEED},Callback=function(v) SPEED=v saveSettings() end}) SpS:Space()
SpS:Slider({Title="Chest Wait (ms)",Step=10,Value={Min=0,Max=1000,Default=_G.ChestWaitTime*1000},Callback=function(v) _G.ChestWaitTime=v/1000 saveSettings() end}) SpS:Space()
SpS:Toggle({Title="Auto Jump",Value=_G.AutoJumpEnabled,Callback=function(v) _G.AutoJumpEnabled=v saveSettings() end})

local OffsetS=SetTab:Section({Title="Player Offset",Box=true,BoxBorder=true,Opened=true})
OffsetS:Dropdown({Title="Offset Mode",Values={"Random","Custom"},Value=_G.PlayerOffsetMode=="custom" and 2 or 1,Callback=function(v) _G.PlayerOffsetMode=(v=="Random") and "random" or "custom" saveSettings() end})
OffsetS:Space()
OffsetS:Slider({Title="Random Range (XZ)",Step=1,Value={Min=1,Max=30,Default=_G.PlayerOffsetRange},Callback=function(v) _G.PlayerOffsetRange=v saveSettings() end})
OffsetS:Space()
OffsetS:Slider({Title="Randomize Interval (s)",Step=0.05,Value={Min=0.05,Max=1,Default=_G.PlayerOffsetInterval},Callback=function(v) _G.PlayerOffsetInterval=v saveSettings() end})
OffsetS:Space()
OffsetS:Slider({Title="Custom X",Step=1,Value={Min=-50,Max=50,Default=_G.PlayerOffsetCustom.X},Callback=function(v) _G.PlayerOffsetCustom=Vector3.new(v,_G.PlayerOffsetCustom.Y,_G.PlayerOffsetCustom.Z) saveSettings() end})
OffsetS:Space()
OffsetS:Slider({Title="Custom Y",Step=1,Value={Min=0,Max=100,Default=_G.PlayerOffsetCustom.Y},Callback=function(v) _G.PlayerOffsetCustom=Vector3.new(_G.PlayerOffsetCustom.X,v,_G.PlayerOffsetCustom.Z) saveSettings() end})
OffsetS:Space()
OffsetS:Slider({Title="Custom Z",Step=1,Value={Min=-50,Max=50,Default=_G.PlayerOffsetCustom.Z},Callback=function(v) _G.PlayerOffsetCustom=Vector3.new(_G.PlayerOffsetCustom.X,_G.PlayerOffsetCustom.Y,v) saveSettings() end})

local BringS=SetTab:Section({Title="Bring Mob",Box=true,BoxBorder=true,Opened=true})
BringS:Slider({Title="Bring Distance",Step=50,Value={Min=100,Max=1500,Default=_G.BringMobMaxDistance},Callback=function(v) _G.BringMobMaxDistance=v saveSettings() end}) BringS:Space()
BringS:Slider({Title="Max Mobs",Step=1,Value={Min=1,Max=10,Default=_G.BringMobMaxBatch},Callback=function(v) _G.BringMobMaxBatch=v saveSettings() end}) BringS:Space()
BringS:Dropdown({Title="Mob Offset Mode",Values={"Random","Custom"},Value=_G.BringMobOffsetMode=="custom" and 2 or 1,Callback=function(v) _G.BringMobOffsetMode=v=="Random" and "random" or "custom" saveSettings() end})

local EqS=SetTab:Section({Title="Auto Equip",Box=true,BoxBorder=true,Opened=true})
local weaponTypes={"Melee","Sword","Gun","Fruit"}
local wIdx=1 for i,w in ipairs(weaponTypes) do if w==_G.SelectedWeaponType then wIdx=i break end end
EqS:Dropdown({Title="Weapon Type",Values=weaponTypes,Value=wIdx,Callback=function(v) _G.SelectedWeaponType=v saveSettings() if _G.AutoEquipEnabled then equipWeapon(v) end end}) EqS:Space()
EqS:Toggle({Title="Auto Equip",Value=_G.AutoEquipEnabled,Callback=function(v) _G.AutoEquipEnabled=v saveSettings() if v then startAutoEquip() else stopAutoEquip() end end})

local RedeemTab=Window:Tab({Title="Redeem",Icon="solar:ticket-bold-duotone"})
local RS2=RedeemTab:Section({Title="Codes",Box=true,BoxBorder=true,Opened=true})
RS2:Button({Title="Redeem All",Callback=function() task.spawn(redeemAllCodes) end})
RS2:Space()
for _,code in ipairs(REDEEM_CODES) do
    RS2:Button({Title=code,Callback=function() local ok=redeemCode(code) notify("Redeem",code..(ok and " OK" or " failed/used"),3) end})
end

local FruitTab=Window:Tab({Title="Fruit",Icon="solar:apple-bold-duotone"})
local FrS=FruitTab:Section({Title="Auto Grab & Store",Box=true,BoxBorder=true,Opened=true})
FrS:Toggle({Title="Auto Grab Fruit",Value=_G.AutoGrabFruitEnabled,Callback=function(v) _G.AutoGrabFruitEnabled=v saveSettings() if v then startAutoGrabFruit() else stopAutoGrabFruit() end end})

-- Auto start saved features
if _G.AutoBusoEnabled then startAutoBuso() end
if _G.DamageAuraEnabled then startDamageAura() end
if _G.AutoEquipEnabled then startAutoEquip() end
for s,en in pairs(_G.AutoStatEnabled) do if en then startStat(s) end end
if _G.AutoGrabFruitEnabled then startAutoGrabFruit() end
if _G.AutoFarmLevelEnabled then
    startAutoFarmLevel()
    _G.BringMobEnabled=true
    if bringMobToggleRef then bringMobToggleRef:Set(true) end
end
if _G.FarmAuraEnabled then
    enableNoclip() startFarmAura()
    _G.BringMobEnabled=true
    startBringMob(nil)
    if bringMobToggleRef then bringMobToggleRef:Set(true) end
end

startPlayerOffsetLoop()
