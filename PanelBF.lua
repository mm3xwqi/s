-- SERVICES
local Pl   = game:GetService("Players")
local Run  = game:GetService("RunService")
local UIS  = game:GetService("UserInputService")
local TS   = game:GetService("TweenService")
local WS   = game:GetService("Workspace")
local HTTP = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Pl.LocalPlayer
if not lp then
    repeat task.wait(0.5) until Pl.LocalPlayer
    lp = Pl.LocalPlayer
end

-- =====================================
--          M1 AURA CONFIG & REMOTES
-- =====================================
local MAX_DISTANCE = 100
local MIN_DISTANCE = 1
local SESSION_ID = "32501259"
local m1_enabled = false
local targetCount = 0
local firstTargetName = "None"

local Net = ReplicatedStorage:FindFirstChild("Modules")
if Net then Net = Net:FindFirstChild("Net") end
local RegisterAttack = Net and Net:FindFirstChild("RE/RegisterAttack")
local RegisterHit = Net and Net:FindFirstChild("RE/RegisterHit")

-- =====================================
--          KKKK Hub CONFIG & STATE
-- =====================================
local _cfgDefault = {
	RemoveDeathEffect = true,
	BoostV1 = false, BoostV2 = false,
	HidePlayers = false, HideEnemies = false,
	AutoHop = false, HopInterval = 45, HopServer = "singapore", HopMaxPlayers = 3,
	WebhookEnabled = false,
	WebhookURL  = "https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN",
	WebhookName = "KKKK Hub",
	WebhookInterval = 30,
	AutoRerun    = true,
	AutoRerunURL = "https://raw.githubusercontent.com/mm3xwqi/s/refs/heads/main/PanelBF.lua",
}

local cfg = {}
for k, v in pairs(_cfgDefault) do cfg[k] = v end
if type(KKKK_HubConfig) == "table" then
	for k, v in pairs(KKKK_HubConfig) do
		if cfg[k] ~= nil then cfg[k] = v end
	end
end
KKKK_HubConfig = nil

-- CONNECTION MANAGER
local Conn = {}; Conn.__index = Conn
function Conn.new() return setmetatable({ _list={} }, Conn) end
function Conn:add(c) if c and typeof(c)=="RBXScriptConnection" then self._list[#self._list+1]=c end; return c end
function Conn:disconnectAll() for _, c in ipairs(self._list) do pcall(function() c:Disconnect() end) end; self._list={} end

-- STATE
local S = {
	v1=false, v2=false,
	hidPlr=cfg.HidePlayers, hidPlrData={}, hidPlrCC={}, hidPlrC={},
	hidEnm=cfg.HideEnemies, hidEnmP={}, enmConn=nil,
	hop=cfg.AutoHop, hopThread=nil, hopCD=cfg.HopInterval*60, hopTick=tick(), hopTotal=0,
	hopTarget=cfg.HopServer:lower(),
	wh=cfg.WebhookEnabled, whTimer=false, whThread=nil,
	whCD=cfg.WebhookInterval*60, whTick=tick(), whTotal=0,
	sessB=nil, sessF=nil, sessOK=false, sessStart=nil,
	fps=0, fc=0, fpsT=tick(), fpsAccum=0, maxFps=0,
	start=tick(),
	plrC={[lp.UserId]={join=tick()}}, statC={}, skillC={},
	spawnW={}, raceW={}, bountyW={},
	specTarget=nil, specConn=nil, specCharConn=nil,
	beliSamples={}, fragSamples={},
	v1Parts={}, v1Conn=nil,
	v2Conns=Conn.new(),
	rerun=false, rerunThread=nil,
}

local BM = { on=false, task=nil, data={}, noclip=nil, pin=nil, dist=500, batch=20, force=150000, snap=12, yOff=-15 }
local BM2 = { on=false, task=nil, dist=500, interval=0.05, anchorPos=nil, resetInterval=60, resetTick=0, maxCount=10 }
local bmTick = 0
local K_MAX = Pl.MaxPlayers
local BRINGMOB_BLACKLIST = { Terrorshark=true }
local walkOnWater = { on = false, thread = nil }

-- =====================================
--          HELPERS & UTILS
-- =====================================
local function fmtN(n)
	if type(n)~="number" then return "?" end
	return tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end
local function fmtV(v,k)
	if type(v)~="number" then return tostring(v or "?") end
	if k=="Beli" or k=="Fragments" or k=="Level" then return fmtN(v) end
	if v>=1e6 then return ("%.1fM"):format(v/1e6)
	elseif v>=1e3 then return ("%.1fK"):format(v/1e3)
	else return tostring(math.floor(v)) end
end
local function fmtS(n)
	n=math.max(0,math.floor(n))
	local h=math.floor(n/3600); n=n%3600
	local m=math.floor(n/60);   n=n%60
	if h>0 then return ("%dh %02dm %02ds"):format(h,m,n) end
	if m>0 then return ("%dm %02ds"):format(m,n) end
	return ("%ds"):format(n)
end
local function wFmt(n)
	return (n<0 and "-" or "+")..tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end
local function getPing()
	local ok,p=pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"] end)
	return ok and type(p)=="number" and math.floor(p) or math.floor(lp:GetNetworkPing()*1000)
end
local function ts()
	local ok,s=pcall(function() return os.date("!%Y-%m-%dT%H:%M:%SZ") end)
	return (ok and type(s)=="string") and s or "1970-01-01T00:00:00Z"
end
local function fmtSpawn(s)
	if not s or s=="" then return "Unknown" end
	s=tostring(s):gsub("([a-z])([A-Z])","%1 %2"):gsub("_"," "):gsub("(%a)([%w]*)",function(f2,r) return f2:upper()..r:lower() end)
	return s
end

local SAMPLE_WINDOW = 600
local function pushSample(tbl, val)
	if type(val) ~= "number" then return end
	local now = tick()
	tbl[#tbl+1] = { t=now, v=val }
	while #tbl > 1 and (now - tbl[1].t) > SAMPLE_WINDOW do
		table.remove(tbl, 1)
	end
end

local function calcRateLR(samples)
	local n = #samples
	if n < 2 then return 0 end
	if n < 5 then
		local dt = samples[n].t - samples[1].t
		if dt < 1 then return 0 end
		return (samples[n].v - samples[1].v) / (dt / 60)
	end
	local sumT, sumV, sumTT, sumTV = 0, 0, 0, 0
	local t0 = samples[1].t
	for _, s in ipairs(samples) do
		local t = s.t - t0
		sumT  = sumT  + t
		sumV  = sumV  + s.v
		sumTT = sumTT + t*t
		sumTV = sumTV + t*s.v
	end
	local denom = n*sumTT - sumT*sumT
	if math.abs(denom) < 1e-9 then return 0 end
	local slope = (n*sumTV - sumT*sumV) / denom
	return math.floor(slope * 60)
end

-- STAT PATHS & RESOLVE
local SPATHS = {
	Level      = {"Data.Level","leaderstats.Level","leaderstats.Lv."},
	Beli       = {"Data.Beli","leaderstats.Beli","leaderstats.Money"},
	Fragments  = {"Data.Fragments","leaderstats.Fragments","leaderstats.Fragment"},
	Melee      = {"leaderstats.Melee","Data.Stats.Melee.Level"},
	Defense    = {"leaderstats.Defense","Data.Stats.Defense.Level"},
	Sword      = {"leaderstats.Sword","Data.Stats.Sword.Level"},
	Gun        = {"leaderstats.Gun","Data.Stats.Gun.Level"},
	["Blox Fruit"] = {"leaderstats.Blox Fruit","leaderstats.Demon Fruit","Data.Stats.Demon Fruit.Level","Data.Stats.Blox Fruit.Level"},
	Bounty     = {"leaderstats.Bounty/Honor","leaderstats.Bounty","leaderstats.Honor"},
	SpawnPoint = {"Data.LastSpawnPoint"},
}

local function resolvePath(root, path)
	local obj=root
	for part in path:gmatch("[^%.]+") do
		if not obj then return nil end
		obj=obj:FindFirstChild(part)
	end
	if obj and obj:IsA("ValueBase") then return obj end
end

local function getStatObj(plr, key)
	local uid=plr.UserId
	S.statC[uid]=S.statC[uid] or {}
	if S.statC[uid][key] then return S.statC[uid][key] end
	for _, path in ipairs(SPATHS[key] or {"leaderstats."..key,"Data."..key}) do
		local obj=resolvePath(plr,path)
		if obj then S.statC[uid][key]=obj; return obj end
	end
end

local function getStat(key, root)
	local obj=getStatObj(root or lp, key)
	return obj and obj.Value or nil
end

-- SPECTATE
local cam = WS.CurrentCamera
local function stopSpec()
	if S.specConn     then S.specConn:Disconnect();     S.specConn=nil end
	if S.specCharConn then S.specCharConn:Disconnect(); S.specCharConn=nil end
	S.specTarget=nil
	pcall(function()
		cam.CameraType=Enum.CameraType.Custom
		cam.CameraSubject=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") or nil
	end)
end

local function startSpec(p)
	if not p or p==lp then return end
	stopSpec(); S.specTarget=p
	local function attachCamera(char)
		local hum=char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end
		pcall(function() cam.CameraType=Enum.CameraType.Follow; cam.CameraSubject=hum end)
	end
	if p.Character then attachCamera(p.Character) end
	S.specCharConn=p.CharacterAdded:Connect(function(char) task.wait(.5); if S.specTarget==p then attachCamera(char) end end)
	S.specConn=Run.RenderStepped:Connect(function()
		if not S.specTarget then S.specConn:Disconnect(); S.specConn=nil; return end
		local found=false
		for _, pl in ipairs(Pl:GetPlayers()) do if pl==S.specTarget then found=true; break end end
		if not found then stopSpec() end
	end)
end

-- BOOST V1
local function setV1(on)
	if on then
		S.v1Parts={}
		task.spawn(function()
			local list=WS:GetDescendants()
			for i,v in ipairs(list) do
				pcall(function()
					if v:IsA("BasePart") and not v:IsDescendantOf(lp.Character or {}) then
						S.v1Parts[#S.v1Parts+1]={o=v,t=v.Transparency}; v.Transparency=1
					end
				end)
				if i%200==0 then task.wait() end
			end
		end)
		if S.v1Conn then S.v1Conn:Disconnect() end
		S.v1Conn=WS.DescendantAdded:Connect(function(v)
			pcall(function()
				if v:IsA("BasePart") and not v:IsDescendantOf(lp.Character or {}) then v.Transparency=1 end
			end)
		end)
	else
		if S.v1Conn then S.v1Conn:Disconnect(); S.v1Conn=nil end
		task.spawn(function()
			for i,d in ipairs(S.v1Parts) do
				if d.o and d.o.Parent then pcall(function() d.o.Transparency=d.t end) end
				if i%200==0 then task.wait() end
			end
			S.v1Parts={}
		end)
	end
end

-- BOOST V2
local GREY=Color3.fromRGB(163,162,165)
local function stripVisualObj(o)
	if o:IsA("MeshPart") then o.RenderFidelity=Enum.RenderFidelity.Performance; o.CastShadow=false; o.TextureID=""; o.Color=GREY
	elseif o:IsA("BasePart") then o.CastShadow=false; if o.Material~=Enum.Material.Neon and o.Material~=Enum.Material.ForceField then o.Material=Enum.Material.SmoothPlastic; o.Reflectance=0; o.Color=GREY end
	elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
	elseif o:IsA("SpecialMesh") then o.TextureId=""
	elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("Smoke") then o.Enabled=false; if o:IsA("ParticleEmitter") then o.Rate=0 end
	elseif o:IsA("Beam") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then o.Enabled=false
	elseif o:IsA("BillboardGui") or o:IsA("SurfaceGui") then o.Enabled=false end
end

local function stripCharCosmetics(char)
	if not char then return end
	for _,obj in ipairs(char:GetChildren()) do
		pcall(function() if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then obj:Destroy() end end)
	end
	for _,obj in ipairs(char:GetDescendants()) do pcall(stripVisualObj, obj) end
end

local function setV2(on)
	if on then
		task.spawn(function() local list=WS:GetDescendants(); for i,o in ipairs(list) do pcall(stripVisualObj,o); if i%200==0 then task.wait() end end end)
		stripCharCosmetics(lp.Character)
		S.v2Conns:disconnectAll()
		S.v2Conns:add(WS.DescendantAdded:Connect(function(o) if S.v2 then task.defer(function() pcall(stripVisualObj,o) end) end end))
		S.v2Conns:add(lp.CharacterAdded:Connect(function(char) task.wait(.5); if S.v2 then stripCharCosmetics(char) end end))
		local function watchChar(char)
			task.wait(.3); if not S.v2 or not char then return end
			S.v2Conns:add(char.ChildAdded:Connect(function(child)
				if not S.v2 then return end
				pcall(function() if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then task.wait(.1); if S.v2 then child:Destroy() end end end)
			end))
		end
		S.v2Conns:add(lp.CharacterAdded:Connect(watchChar))
		if lp.Character then watchChar(lp.Character) end
	else
		S.v2Conns:disconnectAll()
	end
end

-- HIDE PLAYERS / ENEMIES
local function setPlrVis(p, vis)
	if not vis then
		if S.hidPlrData[p.UserId] then return end
		S.hidPlrData[p.UserId] = true
		pcall(function() if p.Character then p.Character:Destroy() end end)
	else
		S.hidPlrData[p.UserId] = nil
	end
end

local function toggleHidePlr(on)
	S.hidPlr = on
	for _, p in ipairs(Pl:GetPlayers()) do
		if p ~= lp then setPlrVis(p, not on) end
	end
	if on then
		for _, p in ipairs(Pl:GetPlayers()) do
			if p ~= lp then
				if S.hidPlrC[p.UserId] then S.hidPlrC[p.UserId]:Disconnect() end
				S.hidPlrC[p.UserId] = p.CharacterAdded:Connect(function()
					S.hidPlrData[p.UserId] = nil
					if S.hidPlr then task.wait(.5); setPlrVis(p, false) end
				end)
			end
		end
		if not S.hidPlrCC.pa then
			S.hidPlrCC.pa = Pl.PlayerAdded:Connect(function(p)
				if p == lp then return end
				task.spawn(function()
					if not p.Character then p.CharacterAdded:Wait() end
					task.wait(.5)
					if S.hidPlr then setPlrVis(p, false) end
				end)
			end)
		end
	else
		if S.hidPlrCC.pa then S.hidPlrCC.pa:Disconnect(); S.hidPlrCC.pa = nil end
		for uid, c in pairs(S.hidPlrC) do c:Disconnect(); S.hidPlrC[uid] = nil end
	end
end

local function toggleHidEnm(on)
	S.hidEnm = on
	if S.enmConn then S.enmConn:Disconnect(); S.enmConn = nil end
	local ef = WS:FindFirstChild("Enemies")
	if not ef then return end
	if on then
		for _, o in ipairs(ef:GetDescendants()) do
			if o:IsA("BasePart") and S.hidEnmP[o] == nil then
				S.hidEnmP[o] = o.Transparency
				o.Transparency = 1
			end
		end
		S.enmConn = ef.DescendantAdded:Connect(function(o)
			if S.hidEnm and o:IsA("BasePart") then
				task.wait(.1)
				if S.hidEnmP[o] == nil and o.Parent then
					S.hidEnmP[o] = o.Transparency
					o.Transparency = 1
				end
			end
		end)
	else
		for o, t in pairs(S.hidEnmP) do
			if o and o.Parent then pcall(function() o.Transparency = t end) end
		end
		S.hidEnmP = {}
	end
end

-- BRINGMOB V1
local function bmHRP(e) return e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso") end
local function bmHum(e) return e:FindFirstChildOfClass("Humanoid") end
local function bmAlive(e) local h=bmHum(e); return h and h.Health>0 end

local function bmRelease(e)
	local d=BM.data[e]; if not d then return end
	for _,k in ipairs({"bp","bv","bg"}) do if d[k] and d[k].Parent then pcall(function() d[k]:Destroy() end) end end
	local hrp=bmHRP(e)
	if hrp then
		for _,c in ipairs(hrp:GetChildren()) do if c.Name:find("BringMob") then pcall(function() c:Destroy() end) end end
		pcall(function() hrp.Anchored=false; hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero end)
	end
	local h=bmHum(e); if h then pcall(function() h.PlatformStand=false; h.WalkSpeed=16; h.JumpPower=50 end) end
	if e.Parent then for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end end end
	BM.data[e]=nil
end

local function bmClean() for e in pairs(BM.data) do pcall(bmRelease,e) end; BM.data={} end
local function bmGetOff() local a=math.random()*math.pi*2; local r=math.random(2,5); return Vector3.new(math.cos(a)*r,0,math.sin(a)*r) end
local function bmMyRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end

local function startBM()
	BM.on=true; bmClean()

	-- Noclip loop
	if BM.noclip then BM.noclip:Disconnect() end
	BM.noclip=Run.RenderStepped:Connect(function()
		for e in pairs(BM.data) do
			if e and e.Parent then
				for _,p in ipairs(e:GetDescendants()) do
					if p:IsA("BasePart") then
						pcall(function() if p.CanCollide then p.CanCollide=false end end)
					end
				end
			end
		end
	end)
	if BM.pin then BM.pin:Disconnect() end
	bmTick=0
	BM.pin=Run.Heartbeat:Connect(function()
		bmTick=bmTick+1; if bmTick%2~=0 then return end
		local mr=bmMyRoot(); if not mr then return end

		for e,d in pairs(BM.data) do
			if not e or not e.Parent or not d or not d.arrived then continue end
			local hrp=bmHRP(e); if not hrp then continue end
			local h=bmHum(e)
			if h then
				pcall(function()
					h.PlatformStand=true
					h.WalkSpeed=0
					h.JumpPower=0
				end)
			end
			pcall(function()
				hrp.AssemblyLinearVelocity=Vector3.zero
				hrp.AssemblyAngularVelocity=Vector3.zero
			end)
			if not d.bp or not d.bp.Parent then
				local targetPos=d.fixedPos or Vector3.new(
					(mr.Position+(d.offset or Vector3.zero)).X,
					mr.Position.Y+BM.yOff,
					(mr.Position+(d.offset or Vector3.zero)).Z
				)
				local newBP=Instance.new("BodyPosition",hrp)
				newBP.Name="BringMobBP_Fixed"
				newBP.MaxForce=Vector3.new(1e9,1e9,1e9)
				newBP.P=500000
				newBP.D=10000
				newBP.Position=targetPos
				d.bp=newBP
				d.fixedPos=targetPos
			end
			if not d.bg or not d.bg.Parent then
				local bg=Instance.new("BodyGyro",hrp)
				bg.Name="BringMobBG"
				bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
				bg.P=100000
				bg.D=2000
				bg.CFrame=hrp.CFrame
				d.bg=bg
			end

			d.anchorPos=d.anchorPos or mr.Position
			if (mr.Position-d.anchorPos).Magnitude>3 then
				d.anchorPos=mr.Position
				local nt=Vector3.new(
					(mr.Position+(d.offset or Vector3.zero)).X,
					mr.Position.Y+BM.yOff,
					(mr.Position+(d.offset or Vector3.zero)).Z
				)
				d.fixedPos=nt
				pcall(function() d.bp.Position=nt end)
			end

			if d.bp and d.bp.Parent then
				pcall(function()
					d.bp.Position=Vector3.new(
						d.bp.Position.X,
						mr.Position.Y+BM.yOff,
						d.bp.Position.Z
					)
				end)
			end
		end
	end)

	BM.task=task.spawn(function()
		local PULL,HOLD=5,3
		local phase,pT,lt="pull",0,tick()

		while BM.on do
			task.wait(.025)
			local now=tick(); local dt=now-lt; lt=now; pT=pT+dt
			local mr=bmMyRoot(); if not mr then continue end
			local ef=WS:FindFirstChild("Enemies"); if not ef then task.wait(.3); continue end

			for e in pairs(BM.data) do
				if not e or not e.Parent or not bmAlive(e) then pcall(bmRelease,e) end
			end
			if phase=="pull" and pT>=PULL then
				for e,d in pairs(BM.data) do
					if not d.arrived then
						local hrp=bmHRP(e)
						if hrp then
							pcall(function() if d.bp and d.bp.Parent then d.bp:Destroy() end end)
							local fbp=Instance.new("BodyPosition",hrp)
							fbp.Name="BringMobBP_Fixed"
							fbp.MaxForce=Vector3.new(1e9,1e9,1e9)
							fbp.P=500000
							fbp.D=10000
							fbp.Position=hrp.Position
							local bg=Instance.new("BodyGyro",hrp)
							bg.Name="BringMobBG"
							bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
							bg.P=100000
							bg.D=2000
							bg.CFrame=hrp.CFrame
							local h=bmHum(e)
							if h then pcall(function() h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0 end) end
							d.bp=fbp; d.bg=bg; d.arrived=true; d.fixedPos=hrp.Position
						end
					end
				end
				phase="hold"; pT=0

			elseif phase=="hold" and pT>=HOLD then
				bmClean(); phase="pull"; pT=0
			end

			if phase=="hold" then continue end

			local pulling=0
			for _,d in pairs(BM.data) do if not d.arrived then pulling=pulling+1 end end

			local ap=mr.Position

			for _,e in ipairs(ef:GetChildren()) do
				if not BM.on then break end
				if not e or not e.Parent or not bmAlive(e) then continue end
				if BRINGMOB_BLACKLIST[e.Name] then continue end
				local hrp=bmHRP(e); if not hrp then continue end

				local dist=(ap-hrp.Position).Magnitude
				if dist>BM.dist then
					if BM.data[e] and not BM.data[e].arrived then pcall(bmRelease,e) end
					continue
				end
				if not BM.data[e] then
					if pulling>=BM.batch then continue end
					local off=bmGetOff()
					local tp=Vector3.new((ap+off).X, ap.Y+BM.yOff, (ap+off).Z)
					local bp=Instance.new("BodyPosition",hrp)
					bp.Name="BringMobBP"
					bp.MaxForce=Vector3.new(1e9,1e9,1e9)
					bp.P=BM.force
					bp.D=2000
					bp.Position=tp
					local h=bmHum(e)
					if h then pcall(function() h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0 end) end
					pcall(function()
						for _,p in ipairs(e:GetDescendants()) do
							if p:IsA("BasePart") then p.CanCollide=false end
						end
					end)
					BM.data[e]={bp=bp,arrived=false,offset=off,stuckTime=0,lastPos=hrp.Position}
					pulling=pulling+1
				end

				local d=BM.data[e]
				if not d or not d.bp or not d.bp.Parent then pcall(bmRelease,e); continue end
				if d.arrived then continue end

				local tp=Vector3.new((ap+d.offset).X, ap.Y+BM.yOff, (ap+d.offset).Z)
				local dist2=(hrp.Position-tp).Magnitude
				local moved=(hrp.Position-d.lastPos).Magnitude
				d.lastPos=hrp.Position
				d.stuckTime=moved<.05 and d.stuckTime+.025 or 0

				local h=bmHum(e)
				if h then pcall(function() h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0 end) end
				pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero end)

				pcall(function() d.bp.Position=tp end)

				if dist2<=BM.snap then
					pcall(function() d.bp:Destroy() end)
					pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero end)

					local bv=Instance.new("BodyVelocity",hrp)
					bv.Name="BringMobBV"
					bv.MaxForce=Vector3.new(1e9,1e9,1e9)
					bv.Velocity=Vector3.zero

					task.wait()

					local fbp=Instance.new("BodyPosition",hrp)
					fbp.Name="BringMobBP_Fixed"
					fbp.MaxForce=Vector3.new(1e9,1e9,1e9)
					fbp.P=500000
					fbp.D=10000
					fbp.Position=hrp.Position

					local bg=Instance.new("BodyGyro",hrp)
					bg.Name="BringMobBG"
					bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
					bg.P=100000
					bg.D=2000
					bg.CFrame=hrp.CFrame

					if h then pcall(function() h.PlatformStand=true; h.WalkSpeed=0; h.JumpPower=0 end) end

					task.delay(.5,function() if bv and bv.Parent then pcall(function() bv:Destroy() end) end end)

					d.bp=fbp; d.bg=bg; d.bv=bv; d.arrived=true; d.fixedPos=hrp.Position

				elseif d.stuckTime>=0.7 then
					d.offset=bmGetOff()
					pcall(function() d.bp.P=100000 end)
					d.stuckTime=0
				end
			end
		end

		if BM.pin    then BM.pin:Disconnect();    BM.pin=nil end
		if BM.noclip then BM.noclip:Disconnect(); BM.noclip=nil end
		bmClean(); BM.task=nil
	end)
end

local function stopBM()
	BM.on=false
	if BM.task   then task.cancel(BM.task);   BM.task=nil end
	if BM.pin    then BM.pin:Disconnect();    BM.pin=nil end
	if BM.noclip then BM.noclip:Disconnect(); BM.noclip=nil end
	bmClean()
end

-- BRINGMOB V2
local function stopBM2()
	BM2.on=false
	if BM2.task then BM2.task:Disconnect(); BM2.task=nil end
end

local function startBM2()
	stopBM2(); BM2.on=true; BM2.resetTick=tick()

	local bm2Warped={}
	local noClipFrame=0
	local warpFrame=0
	local enforceFrame=0
	local WARP_EVERY=math.max(1,math.floor(BM2.interval/(1/60)))

	BM2.task=Run.Stepped:Connect(function()
		if not BM2.on then return end

		noClipFrame=noClipFrame+1
		warpFrame=warpFrame+1
		enforceFrame=enforceFrame+1

		if noClipFrame>=5 then
			noClipFrame=0
			local ef=WS:FindFirstChild("Enemies")
			if ef then
				for _,e in ipairs(ef:GetChildren()) do
					if e and e.Parent then
						for _,p in ipairs(e:GetDescendants()) do
							if p:IsA("BasePart") and p.CanCollide then
								p.CanCollide=false
							end
						end
					end
				end
			end
		end

		if enforceFrame>=3 then
			enforceFrame=0
			for e in pairs(bm2Warped) do
				if e and e.Parent then
					local hrp=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso")
					local hum=e:FindFirstChildOfClass("Humanoid")
					if hrp and hum and hum.Health>0 then
						pcall(function()
							hum.PlatformStand=true
							hum.WalkSpeed=0
							hum.JumpPower=0
							hrp.AssemblyLinearVelocity=Vector3.zero
							hrp.AssemblyAngularVelocity=Vector3.zero
						end)
					end
				end
			end
		end

		if warpFrame<WARP_EVERY then return end
		warpFrame=0

		local char=lp.Character; if not char then return end
		local myHRP=char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
		local anchor=BM2.anchorPos or myHRP.Position
		local targetY=anchor.Y+BM.yOff

		if BM2.resetInterval>0 and (tick()-BM2.resetTick)>=BM2.resetInterval then
			BM2.resetTick=tick(); bm2Warped={}
		end

		local ef=WS:FindFirstChild("Enemies"); if not ef then return end

		local warpedCount=0
		for e in pairs(bm2Warped) do
			if e and e.Parent then
				local hum=e:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health>0 then warpedCount=warpedCount+1
				else bm2Warped[e]=nil end
			else
				bm2Warped[e]=nil
			end
		end

		for _,e in ipairs(ef:GetChildren()) do
			if not e or not e.Parent then continue end
			local hrp=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso"); if not hrp then continue end
			local hum=e:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then bm2Warped[e]=nil; continue end
			if BRINGMOB_BLACKLIST[e.Name] then continue end

			local ok,dist=pcall(function() return (anchor-hrp.Position).Magnitude end)
			if not ok or dist>BM2.dist then continue end

			if not bm2Warped[e] then
				if warpedCount>=BM2.maxCount then continue end
				bm2Warped[e]=true; warpedCount=warpedCount+1
			end

			pcall(function()
				hrp.AssemblyLinearVelocity=Vector3.zero
				hrp.AssemblyAngularVelocity=Vector3.zero
				hrp.CFrame=CFrame.new(anchor.X, targetY, anchor.Z)
				-- Kill velocity อีกครั้งหลัง teleport กัน skill knockback
				hrp.AssemblyLinearVelocity=Vector3.zero
				hrp.AssemblyAngularVelocity=Vector3.zero
			end)
			pcall(function()
				hum.WalkSpeed=0
				hum.JumpPower=0
				hum.PlatformStand=true
			end)
		end
	end)
end

local function startWalkOnWater()
    walkOnWater.on = true
    if walkOnWater.thread then task.cancel(walkOnWater.thread) end
    walkOnWater.thread = task.spawn(function()
        while walkOnWater.on do
            pcall(function()
                local map = WS:FindFirstChild("Map")
                local wb = map and map:FindFirstChild("WaterBase-Plane")
                if wb then
                    local inWater = false
                    if type(dzf) == "function" then
                        local ok, res = pcall(dzf, "water")
                        inWater = ok and res
                    end
                    wb.Size = Vector3.new(1000, inWater and 112 or 80, 1000)
                end
            end)
            task.wait()
        end
    end)
end

local function stopWalkOnWater()
    walkOnWater.on = false
    if walkOnWater.thread then task.cancel(walkOnWater.thread); walkOnWater.thread = nil end
    pcall(function()
        local wb = WS:FindFirstChild("Map") and WS.Map:FindFirstChild("WaterBase-Plane")
        if wb then wb.Size = Vector3.new(1000, 80, 1000) end
    end)
end

-- WEBHOOK
local function _sendWH(url,payload)
	if not url or url=="" or url:find("YOUR_ID") then return end
	local ok,json=pcall(HTTP.JSONEncode,HTTP,payload)
	if not ok or type(json)~="string" then return end
	pcall(request,{Url=url,Method="POST",Headers={["Content-Type"]="application/json"},Body=json})
end

local function buildField(n,v,inline) return {name=tostring(n),value=tostring(v),inline=inline==true} end

local function sendWebhook(sessBeli,sessFrags,elapsed,source)
	if not cfg.WebhookEnabled then return end
	local url=cfg.WebhookURL; if not url or url=="" or url:find("YOUR_ID") then return end
	source=tostring(source or "Manual"); S.whTotal=S.whTotal+1
	local lv,beli,frag,melee,sword,gun,def,fruit,bounty,spawn2
	pcall(function()
		lv=math.floor(getStat("Level") or 0); beli=math.floor(getStat("Beli") or 0)
		frag=math.floor(getStat("Fragments") or 0); melee=math.floor(getStat("Melee") or 0)
		sword=math.floor(getStat("Sword") or 0); gun=math.floor(getStat("Gun") or 0)
		def=math.floor(getStat("Defense") or 0); fruit=math.floor(getStat("Blox Fruit") or 0)
		bounty=math.floor(getStat("Bounty") or 0); spawn2=tostring(getStat("SpawnPoint") or "Unknown")
	end)
	lv=lv or 0; beli=beli or 0; frag=frag or 0; melee=melee or 0
	sword=sword or 0; gun=gun or 0; def=def or 0; fruit=fruit or 0; bounty=bounty or 0

	local bPM=calcRateLR(S.beliSamples); local fPM=calcRateLR(S.fragSamples)
	local sessBStr=(sessBeli>=0 and"+" or"")..fmtN(sessBeli)
	local sessFS=(sessFrags>=0 and"+" or"")..fmtN(sessFrags)
	local pName=lp.Name; pcall(function() if lp.DisplayName~=lp.Name then pName=lp.DisplayName.." (@"..lp.Name..")" end end)

	local fields={
		buildField("Player",pName,true), buildField("Level",tostring(lv),true), buildField("Bounty",fmtN(bounty),true),
		buildField("Total Beli",fmtN(beli),true), buildField("Total Frags",fmtN(frag),true),
		buildField("Session Beli",sessBStr,true), buildField("Session Frags",sessFS,true),
		buildField("Session",fmtS(elapsed or 0),true), buildField("Beli/Min",wFmt(bPM),true),
		buildField("Beli/Hr",wFmt(bPM*60),true), buildField("Frag/Min",wFmt(fPM),true),
		buildField("Melee",fmtN(melee),true), buildField("Sword",fmtN(sword),true),
		buildField("Gun",fmtN(gun),true), buildField("Defense",fmtN(def),true),
		buildField("Blox Fruit",fmtN(fruit),true), buildField("Spawn",spawn2,true),
		buildField("Players",tostring(#Pl:GetPlayers()).."/"..K_MAX,true),
		buildField("FPS / Ping",S.fps.." FPS | "..getPing().."ms",true),
	}
	_sendWH(url,{
		username=tostring(cfg.WebhookName or "KKKK Hub"),
		embeds={{
			title="Session Report — "..source, color=3066993,
			description=pName.." | "..fmtS(elapsed or 0).."\nBeli "..sessBStr.." ("..wFmt(bPM).."/min)\nFrags "..sessFS.." ("..wFmt(fPM).."/min)",
			fields=fields, footer={text="KKKK Hub Unified | Report #"..S.whTotal}, timestamp=ts(),
		}},
	})
end

local function startWHTimer()
	S.whTimer=true; S.whCD=cfg.WebhookInterval*60; S.whTick=tick()
	if S.whThread then task.cancel(S.whThread) end
	S.whThread=task.spawn(function()
		while S.whTimer do
			task.wait(1)
			local now=tick(); S.whCD=S.whCD-(now-S.whTick); S.whTick=now
			if S.whCD<=0 then
				S.whCD=cfg.WebhookInterval*60
				if S.whTimer and cfg.WebhookEnabled then
					task.spawn(function()
						local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0
						local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick()
						sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0, S.sessOK and math.floor(cf-(S.sessF or cf)) or 0, tick()-jt,"Webhook Time")
					end)
				end
			end
		end
	end)
end

local function stopWHTimer()
	S.whTimer=false; if S.whThread then task.cancel(S.whThread); S.whThread=nil end; S.whCD=cfg.WebhookInterval*60
end

-- AUTO HOP
local function doHop()
	S.hopTotal=S.hopTotal+1
	local cb=getStat("Beli") or 0; local cf=getStat("Fragments") or 0
	local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick()
	task.spawn(function() sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0, S.sessOK and math.floor(cf-(S.sessF or cf)) or 0, tick()-jt,"Auto Hop") end)
	
	local pg = lp:FindFirstChild("PlayerGui")
	local sb = pg and pg:FindFirstChild("ServerBrowser")
	if not sb then return end
	local frame = sb:FindFirstChild("Frame")
	if not frame then return end

	local watching=true
	task.spawn(function()
		while watching do task.wait(.5); if not sb.Enabled or not frame.Visible then sb.Enabled=true; frame.Visible=true end end
	end)

	if not sb.Enabled then sb.Enabled=true; task.wait(.3) end
	if not frame.Visible then frame.Visible=true; task.wait(.3) end

	pcall(function()
		local rb=frame.Filters.SearchRegion:FindFirstChildOfClass("TextBox")
		if rb then rb.Text=S.hopTarget~="" and S.hopTarget or ""; rb:ReleaseFocus() end
	end)
	pcall(function() frame.Refresh:Activate() end)
	task.wait(3)

	local inside=frame:FindFirstChild("FakeScroll") and frame.FakeScroll:FindFirstChild("Inside")
	if not inside then watching=false; return end
	local maxP=cfg.HopMaxPlayers or 3; local tried={}

	local function findBest()
		local best,bestC=nil,math.huge
		local fs=frame:FindFirstChild("FakeScroll"); if not fs then return nil end
		local absPos=fs.AbsolutePosition; local absSz=fs.AbsoluteSize
		local cx=absPos.X+absSz.X/2; local cy=absPos.Y+absSz.Y/2
		local function scrollDown() pcall(function() VirtualInputManager:SendMouseWheelEvent(cx,cy,false,game) end) end
		local function scrollUp() pcall(function() VirtualInputManager:SendMouseWheelEvent(cx,cy,true,game) end) end
		local seenJobs={}
		local function readRows()
			local foundNew=false
			for _,child in ipairs(inside:GetChildren()) do
				if not child:IsA("Frame") then continue end
				local jb=child:FindFirstChild("Join"); if not jb or jb.Text~="Join" then continue end
				local jobId=jb:GetAttribute("Job"); if not jobId or jobId=="1234567890123" then continue end
				if tried[jobId] or seenJobs[jobId] then continue end
				local sn=child:FindFirstChild("ServerName"); if sn and sn.Text:find("Your Server") then continue end
				local tl=child:FindFirstChildOfClass("TextLabel")
				if tl then
					local a=tl.Text:match("Players:%s*(%d+)%s*/%s*%d+")
					if a then
						local pc=tonumber(a); seenJobs[jobId]=true; foundNew=true
						if pc and pc<=maxP then if not best or pc<bestC then bestC=pc; best={jb=jb,jobId=jobId,cur=pc} end end
					end
				end
			end
			return foundNew
		end
		for pass=1,3 do
			for _=1,30 do scrollUp() end; task.wait(.5); seenJobs={}; readRows()
			local noNew=0
			while noNew<10 do
				for _=1,3 do scrollDown() end; task.wait(.25)
				if readRows() then noNew=0 else noNew=noNew+1 end
				if best then return best end
			end
			if pass<3 then tried={}; pcall(function() frame.Refresh:Activate() end); task.wait(4) end
		end
		return best
	end

	local function tryHop()
		local server=findBest()
		if server then
			tried[server.jobId]=true
			local fc; fc=TeleportService.TeleportInitFailed:Connect(function()
				if fc then fc:Disconnect(); fc=nil end; task.wait(1); tryHop()
			end)
			for _,c in ipairs(getconnections(server.jb.MouseButton1Click)) do c:Fire() end
			task.delay(5,function() if fc then fc:Disconnect(); fc=nil end end)
		end
	end

	tryHop(); task.delay(10,function() watching=false end)
end

local function startHop()
	S.hop=true; S.hopCD=cfg.HopInterval*60; S.hopTick=tick()
	if S.hopThread then task.cancel(S.hopThread) end
	S.hopThread=task.spawn(function()
		while S.hop do
			task.wait(1)
			local now=tick(); S.hopCD=S.hopCD-(now-S.hopTick); S.hopTick=now
			if S.hopCD<=0 then S.hopCD=cfg.HopInterval*60; if S.hop then task.spawn(doHop) end end
		end
	end)
end

local function stopHop()
	S.hop=false; if S.hopThread then task.cancel(S.hopThread); S.hopThread=nil end; S.hopCD=cfg.HopInterval*60
	pcall(function()
		local pg = lp:FindFirstChild("PlayerGui")
		local sb = pg and pg:FindFirstChild("ServerBrowser")
		if not sb then return end
		sb.Enabled=false; local f=sb:FindFirstChild("Frame"); if f then f.Visible=false end
	end)
end

-- AUTO RERUN
local function startRerun()
    S.rerun = true
    cfg.AutoRerun = true
    if S.rerunThread then task.cancel(S.rerunThread); S.rerunThread = nil end
    task.spawn(function()
        if not cfg.AutoRerunURL or cfg.AutoRerunURL == "" then
            S.rerun = false
            return
        end
        local loader = string.format(
            'task.wait(5)\nlocal ok,src=pcall(game.HttpGet,game,"%s",true)\nif ok and src then local f=loadstring(src) if f then pcall(f) end end',
            cfg.AutoRerunURL
        )
        local queued = false
        local methods = {
            function() return queueonteleport end,
            function() return queue_on_teleport end,
            function() return getgenv and getgenv().queueonteleport end,
        }
        for _, fn in ipairs(methods) do
            local ok2, f = pcall(fn)
            if ok2 and type(f) == "function" then
                local ok3 = pcall(f, loader)
                if ok3 then queued = true; break end
            end
        end
        if not queued then S.rerun = false; cfg.AutoRerun = false end
    end)
end

local function stopRerun()
    S.rerun = false
    cfg.AutoRerun = false
    if S.rerunThread then task.cancel(S.rerunThread); S.rerunThread = nil end
    local cleared = false
    local methods = {
        function() if type(queueonteleport) == "function" then queueonteleport("") ; cleared = true end end,
        function() if type(queue_on_teleport) == "function" then queue_on_teleport(""); cleared = true end end,
        function()
            if getgenv then
                local g = getgenv()
                if type(g.queueonteleport) == "function" then g.queueonteleport(""); cleared = true end
            end
        end,
    }
    for _, fn in ipairs(methods) do pcall(fn) end
end

-- PLAYER WATCHER
local function watchPlr(p)
	if p==lp then return end
	local uid=p.UserId; S.plrC[uid]=S.plrC[uid] or {join=tick()}
	task.spawn(function()
		local d=p:FindFirstChild("Data") or p:WaitForChild("Data",30); if not d then return end
		local sp=d:FindFirstChild("LastSpawnPoint") or d:WaitForChild("LastSpawnPoint",30)
		if sp then S.plrC[uid].spawn=sp.Value; S.spawnW[uid]=sp.Changed:Connect(function(v) S.plrC[uid]=S.plrC[uid] or {}; S.plrC[uid].spawn=v end) end
		local rc=d:FindFirstChild("Race") or d:WaitForChild("Race",30)
		if rc then
			S.plrC[uid].race=rc:IsA("ValueBase") and rc.Value~="" and tostring(rc.Value) or nil
			local cObj=rc:FindFirstChild("C"); if cObj then S.plrC[uid].raceTier=cObj.Value end
			S.raceW[uid]=rc.Changed:Connect(function(v) S.plrC[uid]=S.plrC[uid] or {}; if v~="" then S.plrC[uid].race=tostring(v) end end)
		end
	end)
	task.spawn(function()
		local bObj=getStatObj(p,"Bounty"); if not bObj then task.wait(3); bObj=getStatObj(p,"Bounty") end; if not bObj then return end
		S.plrC[uid].bounty=bObj.Value
		S.bountyW[uid]=bObj.Changed:Connect(function(v) S.plrC[uid]=S.plrC[uid] or {}; S.plrC[uid].bounty=v end)
	end)
end

-- =====================================
--          M1 AURA LOGIC
-- =====================================
local function getTargetPart(enemy)
    if not enemy or not enemy.Parent then return nil end
    local part = enemy:FindFirstChild("LeftLowerLeg")
    if part and part:IsA("BasePart") then return part end
    part = enemy:FindFirstChild("Head")
    if part and part:IsA("BasePart") then return part end
    part = enemy:FindFirstChild("HumanoidRootPart")
    if part and part:IsA("BasePart") then return part end
    for _, child in ipairs(enemy:GetChildren()) do
        if child:IsA("BasePart") then return child end
    end
    return nil
end

local function getEnemiesInRange()
    local character = lp.Character
    if not character then return {} end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    local myPos = hrp.Position

    local enemiesFolder = WS:FindFirstChild("Enemies")
    if not enemiesFolder then return {} end

    local results = {}
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        if enemy and enemy.Parent then
            local humanoid = enemy:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health and humanoid.Health > 0 then
                local part = getTargetPart(enemy)
                if part and part.Parent then
                    local ok, pos = pcall(function() return part.Position end)
                    if ok and pos then
                        local dist = (pos - myPos).Magnitude
                        if dist <= MAX_DISTANCE and dist >= MIN_DISTANCE then
                            table.insert(results, {enemy = enemy, part = part, dist = dist})
                        end
                    end
                end
            end
        end
    end
    return results
end

local function AttackMultiple(enemyList)
    if not m1_enabled or #enemyList == 0 then return end

    local hitTable = {}
    local primaryPart = nil
    for _, entry in ipairs(enemyList) do
        if entry.enemy and entry.enemy.Parent and entry.part and entry.part.Parent then
            table.insert(hitTable, {entry.enemy, entry.part})
            if not primaryPart then
                primaryPart = entry.part
            end
        end
    end

    if #hitTable == 0 then return end

    if RegisterAttack and RegisterHit then
        pcall(function()
            RegisterAttack:FireServer(0.5)
            task.wait()
            RegisterHit:FireServer(primaryPart, hitTable, nil, SESSION_ID)
        end)
    end
end

-- =====================================
--          RAYFIELD UI SETUP
-- =====================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "KKKK Hub",
   Icon = 0,
   LoadingTitle = "KKKK Hub",
   LoadingSubtitle = "Rayfield Interface Suite",
   Theme = "Default",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "KKKK_Hub_Config"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false
})

local function notify(title, text)
    pcall(function()
        Rayfield:Notify({
            Title = title or "KKKK Hub",
            Content = text or "",
            Duration = 3
        })
    end)
end

-- TABS
local M1Tab        = Window:CreateTab("M1 Aura", 4483362458)
local BringMobTab  = Window:CreateTab("BringMob", 4483362458)
local StatusTab    = Window:CreateTab("Status & Stats", 4483362458)
local BoostTab     = Window:CreateTab("Performance", 4483362458)
local HopWHTab     = Window:CreateTab("Hop & Webhook", 4483362458)
local AutoRerunTab = Window:CreateTab("Auto Rerun", 4483362458)
local SpectateTab  = Window:CreateTab("Spectate", 4483362458)

-- 1. TAB: M1 AURA
local M1Toggle = M1Tab:CreateToggle({
   Name = "Enable M1 Aura",
   CurrentValue = false,
   Flag = "M1AuraToggle",
   Callback = function(Value)
      m1_enabled = Value
   end,
})

local M1DistSlider = M1Tab:CreateSlider({
   Name = "Max Distance",
   Range = {1, 300},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = MAX_DISTANCE,
   Flag = "M1DistSlider",
   Callback = function(Value)
      MAX_DISTANCE = Value
   end,
})

local M1StatusParagraph = M1Tab:CreateParagraph({
    Title = "M1 Aura Status",
    Content = "Status: OFF\nTargets: 0 (None)"
})

-- 2. TAB: BRINGMOB
local BM1Toggle = BringMobTab:CreateToggle({
   Name = "BringMob V1 (Pull)",
   CurrentValue = false,
   Flag = "BM1Toggle",
   Callback = function(Value)
      if Value then
          startBM()
          notify("BringMob V1", "Pull ON | Range: "..BM.dist)
      else
          stopBM()
          notify("BringMob V1", "Disabled")
      end
   end,
})

local BM1DistSlider = BringMobTab:CreateSlider({
   Name = "V1 Pull Range",
   Range = {50, 1500},
   Increment = 10,
   Suffix = "Studs",
   CurrentValue = BM.dist,
   Flag = "BM1DistSlider",
   Callback = function(Value)
      BM.dist = Value
   end,
})

BringMobTab:CreateSection("BringMob V2 (Warp)")

local BM2Toggle = BringMobTab:CreateToggle({
   Name = "BringMob V2 (Warp)",
   CurrentValue = false,
   Flag = "BM2Toggle",
   Callback = function(Value)
      if Value then
          startBM2()
          notify("BringMob V2", "Warp ON | Max: "..BM2.maxCount)
      else
          stopBM2()
          notify("BringMob V2", "Disabled")
      end
   end,
})

local BM2DistSlider = BringMobTab:CreateSlider({
   Name = "V2 Warp Range",
   Range = {50, 1500},
   Increment = 10,
   Suffix = "Studs",
   CurrentValue = BM2.dist,
   Flag = "BM2DistSlider",
   Callback = function(Value)
      BM2.dist = Value
   end,
})

local BM2MaxSlider = BringMobTab:CreateSlider({
   Name = "V2 Max Mobs",
   Range = {1, 50},
   Increment = 1,
   Suffix = "mobs",
   CurrentValue = BM2.maxCount,
   Flag = "BM2MaxSlider",
   Callback = function(Value)
      BM2.maxCount = Value
   end,
})

local BM2IntervalInput = BringMobTab:CreateInput({
   Name = "V2 Warp Interval (sec)",
   PlaceholderText = "Default: 0.05",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local n = tonumber(Text)
      if n and n > 0 then
          BM2.interval = n
          notify("BringMob V2", "Interval set to " .. n .. "s")
      end
   end,
})

BringMobTab:CreateButton({
   Name = "Set Anchor = My Position",
   Callback = function()
      local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
      if hrp then
          BM2.anchorPos = hrp.Position
          BM2.resetTick = tick()
          notify("BringMob V2", ("Anchor set to %.0f, %.0f, %.0f"):format(hrp.Position.X, hrp.Position.Y, hrp.Position.Z))
      end
   end,
})

BringMobTab:CreateButton({
   Name = "Clear Anchor (Follow Mode)",
   Callback = function()
      BM2.anchorPos = nil
      notify("BringMob V2", "Cleared anchor -> Follow Mode")
   end,
})

BringMobTab:CreateSection("Shared Settings")

local YOffsetSlider = BringMobTab:CreateSlider({
   Name = "Y Offset (V1 & V2)",
   Range = {-50, 50},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = BM.yOff,
   Flag = "YOffsetSlider",
   Callback = function(Value)
      BM.yOff = Value
   end,
})

local BMStatusParagraph = BringMobTab:CreateParagraph({
    Title = "BringMob Status",
    Content = "V1: OFF\nV2: OFF\nY Offset: -15"
})

-- 3. TAB: STATUS & STATS
local ProfileParagraph = StatusTab:CreateParagraph({
    Title = "Profile & Game Info",
    Content = "Loading profile..."
})

local CombatParagraph = StatusTab:CreateParagraph({
    Title = "Combat Stats",
    Content = "Loading stats..."
})

local EconomyParagraph = StatusTab:CreateParagraph({
    Title = "Economy & Rates",
    Content = "Loading economy..."
})

local PerfParagraph = StatusTab:CreateParagraph({
    Title = "Performance & Server",
    Content = "Loading FPS/Ping..."
})

-- 4. TAB: PERFORMANCE & VISUALS
local V1Toggle = BoostTab:CreateToggle({
   Name = "Boost V1 (Hide Map)",
   CurrentValue = cfg.BoostV1,
   Flag = "V1Toggle",
   Callback = function(Value)
      S.v1 = Value
      setV1(Value)
      notify("Boost V1", Value and "Map Hidden" or "Off")
   end,
})

local V2Toggle = BoostTab:CreateToggle({
   Name = "Boost V2 (Strip Visuals / Best FPS)",
   CurrentValue = cfg.BoostV2,
   Flag = "V2Toggle",
   Callback = function(Value)
      S.v2 = Value
      setV2(Value)
      notify("Boost V2", Value and "Visuals Stripped" or "Off")
   end,
})

local HidePlrToggle = BoostTab:CreateToggle({
   Name = "Delete Other Players",
   CurrentValue = cfg.HidePlayers,
   Flag = "HidePlrToggle",
   Callback = function(Value)
      S.hidPlr = Value
      toggleHidePlr(Value)
      notify("Hide Players", Value and "Players Hidden" or "Off")
   end,
})

local HideEnmToggle = BoostTab:CreateToggle({
   Name = "Hide Enemies",
   CurrentValue = cfg.HideEnemies,
   Flag = "HideEnmToggle",
   Callback = function(Value)
      S.hidEnm = Value
      toggleHidEnm(Value)
      notify("Hide Enemies", Value and "Enemies Hidden" or "Off")
   end,
})

BoostTab:CreateToggle({
    Name = "Walk on Water",
    CurrentValue = false,
    Flag = "WalkOnWaterToggle",
    Callback = function(Value)
        if Value then
            startWalkOnWater()
            notify("Walk on Water", "Enabled")
        else
            stopWalkOnWater()
            notify("Walk on Water", "Disabled")
        end
    end,
})

BoostTab:CreateInput({
   Name = "Set FPS Cap",
   PlaceholderText = "e.g. 60",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local n = tonumber(Text)
      if n and n > 0 then
          pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate = n end)
          pcall(function() setfpscap(n) end)
          notify("FPS Cap", "Set to " .. n .. " FPS")
      end
   end,
})

-- 5. TAB: HOP & WEBHOOK
local HopToggle = HopWHTab:CreateToggle({
   Name = "Auto Hop",
   CurrentValue = cfg.AutoHop,
   Flag = "AutoHopToggle",
   Callback = function(Value)
      if Value then
          startHop()
          notify("Auto Hop", "Every " .. cfg.HopInterval .. " min")
      else
          stopHop()
          notify("Auto Hop", "Disabled")
      end
   end,
})

HopWHTab:CreateButton({
   Name = "Hop Now",
   Callback = function()
      notify("Auto Hop", "Hopping server...")
      task.spawn(doHop)
   end,
})

HopWHTab:CreateInput({
   Name = "Hop Max Players",
   PlaceholderText = tostring(cfg.HopMaxPlayers),
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local n = tonumber(Text)
      if n and n >= 0 then
          cfg.HopMaxPlayers = n
          notify("Auto Hop", "Max players: " .. n)
      end
   end,
})

HopWHTab:CreateSection("Discord Webhook")

HopWHTab:CreateInput({
   Name = "Webhook URL",
   PlaceholderText = cfg.WebhookURL,
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text ~= "" and Text:find("discord.com/api/webhooks") then
          cfg.WebhookURL = Text
          notify("Webhook", "URL Saved")
      end
   end,
})

HopWHTab:CreateInput({
   Name = "Bot Name",
   PlaceholderText = cfg.WebhookName,
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text ~= "" then
          cfg.WebhookName = Text
          notify("Webhook", "Bot Name Saved")
      end
   end,
})

local WHToggle = HopWHTab:CreateToggle({
   Name = "Enable Webhook",
   CurrentValue = cfg.WebhookEnabled,
   Flag = "WHToggle",
   Callback = function(Value)
      S.wh = Value
      cfg.WebhookEnabled = Value
      notify("Webhook", Value and "Enabled" or "Disabled")
   end,
})

local WHTimerToggle = HopWHTab:CreateToggle({
   Name = "Webhook Timer",
   CurrentValue = false,
   Flag = "WHTimerToggle",
   Callback = function(Value)
      if Value then
          startWHTimer()
          notify("WH Timer", "Every " .. cfg.WebhookInterval .. " min")
      else
          stopWHTimer()
          notify("WH Timer", "Disabled")
      end
   end,
})

HopWHTab:CreateButton({
   Name = "Send Test Webhook",
   Callback = function()
      local cb = getStat("Beli") or 0
      local cf = getStat("Fragments") or 0
      local jt = S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick()
      sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0, S.sessOK and math.floor(cf-(S.sessF or cf)) or 0, tick()-jt, "Test")
      notify("Webhook", "Test sent!")
   end,
})

local HopWHParagraph = HopWHTab:CreateParagraph({
    Title = "Timer Status",
    Content = "Next Hop: Disabled\nNext Webhook: Disabled"
})

-- 6. TAB: AUTO RERUN & EXTRA
local RerunToggle = AutoRerunTab:CreateToggle({
   Name = "Enable Auto Rerun",
   CurrentValue = cfg.AutoRerun,
   Flag = "RerunToggle",
   Callback = function(Value)
      cfg.AutoRerun = Value
      if Value then
          startRerun()
          notify("Auto Rerun", "Enabled")
      else
          stopRerun()
          notify("Auto Rerun", "Disabled")
      end
   end,
})

AutoRerunTab:CreateInput({
   Name = "Auto Rerun Script URL",
   PlaceholderText = cfg.AutoRerunURL,
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text ~= "" and Text:find("http") then
          cfg.AutoRerunURL = Text
          notify("Auto Rerun", "URL Saved!")
          if S.rerun then
              stopRerun()
              startRerun()
          end
      end
   end,
})

AutoRerunTab:CreateToggle({
   Name = "Remove Death Effect",
   CurrentValue = cfg.RemoveDeathEffect,
   Flag = "RDEText",
   Callback = function(Value)
      cfg.RemoveDeathEffect = Value
   end,
})

-- 7. TAB: SPECTATE
local function getPlayerListNames()
    local t = {}
    for _, p in ipairs(Pl:GetPlayers()) do
        if p ~= lp then
            table.insert(t, p.Name)
        end
    end
    if #t == 0 then table.insert(t, "None") end
    return t
end

local specTargetPlayer = nil

local SpecDropdown = SpectateTab:CreateDropdown({
   Name = "Target Player",
   Options = getPlayerListNames(),
   CurrentOption = {"None"},
   MultipleOptions = false,
   Flag = "SpecDropdown",
   Callback = function(Options)
      local name = Options[1]
      if name and name ~= "None" then
          specTargetPlayer = Pl:FindFirstChild(name)
      else
          specTargetPlayer = nil
      end
   end,
})

SpectateTab:CreateButton({
   Name = "Refresh Player Dropdown",
   Callback = function()
      SpecDropdown:Refresh(getPlayerListNames())
      notify("Spectate", "Player list refreshed")
   end,
})

SpectateTab:CreateButton({
   Name = "Start Spectating",
   Callback = function()
      if specTargetPlayer then
          startSpec(specTargetPlayer)
          notify("Spectate", "Spectating " .. specTargetPlayer.Name)
      else
          notify("Spectate", "Select a valid player first!")
      end
   end,
})

SpectateTab:CreateButton({
   Name = "Stop Spectating",
   Callback = function()
      stopSpec()
      notify("Spectate", "Stopped spectating")
   end,
})

-- =====================================
--          MAIN LOOPS & UPDATES
-- =====================================
-- FPS Tracker
Run.RenderStepped:Connect(function(dt)
	S.fc = S.fc + 1
	S.fpsAccum = S.fpsAccum + dt
	if S.fpsAccum >= 0.5 then
		S.fps = math.floor(S.fc / S.fpsAccum)
		S.fc = 0
		S.fpsAccum = 0
		if S.fps > S.maxFps then S.maxFps = S.fps end
	end
end)

-- M1 Aura Main Loop
task.spawn(function()
    while true do
        local enemies = getEnemiesInRange()
        targetCount = #enemies
        if targetCount > 0 then
            table.sort(enemies, function(a, b) return a.dist < b.dist end)
            firstTargetName = enemies[1].enemy.Name or "Unknown"
        else
            firstTargetName = "None"
        end

        if m1_enabled and targetCount > 0 then
            AttackMultiple(enemies)
        end

        task.wait(0.05)
    end
end)

-- Real-time UI Paragraph Updater
local _frame = 0
Run.Heartbeat:Connect(function()
	_frame = (_frame + 1) % 3600

	-- M1 & BringMob Status Update
	if _frame % 10 == 0 then
		M1StatusParagraph:Set({
			Title = "M1 Aura Status",
			Content = string.format("Status: %s\nTargets in range: %d (%s)\nDistance: %d studs", m1_enabled and "ON" or "OFF", targetCount, firstTargetName, MAX_DISTANCE)
		})

		local bm1Text = BM.on and string.format("ON | Dist: %d | Y: %d", BM.dist, BM.yOff) or "OFF"
		local bm2Text = BM2.on and string.format("ON | Dist: %d | Max: %d | Interval: %.2fs", BM2.dist, BM2.maxCount, BM2.interval) or "OFF"
		local anchorText = BM2.anchorPos and string.format("%.0f, %.0f, %.0f", BM2.anchorPos.X, BM2.anchorPos.Y, BM2.anchorPos.Z) or "Follow Mode"
		BMStatusParagraph:Set({
			Title = "BringMob Status",
			Content = string.format("V1 (Pull): %s\nV2 (Warp): %s\nAnchor: %s\nY Offset: %d", bm1Text, bm2Text, anchorText, BM.yOff)
		})
	end

	-- Stats & Performance Update
	if _frame % 15 == 0 then
		local lv = getStat("Level") or 0
		local beli = getStat("Beli") or 0
		local frags = getStat("Fragments") or 0
		local melee = getStat("Melee") or 0
		local def = getStat("Defense") or 0
		local sword = getStat("Sword") or 0
		local gun = getStat("Gun") or 0
		local fruit = getStat("Blox Fruit") or 0
		local sp = getStat("SpawnPoint") or "Unknown"

		local rn, rt
		pcall(function()
			local ro = lp:FindFirstChild("Data") and lp.Data:FindFirstChild("Race")
			if ro and ro:IsA("ValueBase") and ro.Value ~= "" then rn = tostring(ro.Value) end
			local c = ro and ro:FindFirstChild("C")
			if c then rt = c.Value end
		end)

		ProfileParagraph:Set({
			Title = "Profile & Game Info",
			Content = string.format("Name: %s\nLevel: %s\nRace: %s\nTeam: %s\nSpawn: %s",
				lp.DisplayName ~= lp.Name and (lp.DisplayName .. " (@" .. lp.Name .. ")") or lp.Name,
				fmtN(lv),
				rn and (rn .. (rt and " [V" .. rt .. "]" or "")) or "Not V4",
				lp.Team and lp.Team.Name or "N/A",
				fmtSpawn(tostring(sp))
			)
		})

		CombatParagraph:Set({
			Title = "Combat Stats",
			Content = string.format("Melee: %s | Defense: %s\nSword: %s | Gun: %s\nBlox Fruit: %s",
				fmtN(melee), fmtN(def), fmtN(sword), fmtN(gun), fmtN(fruit)
			)
		})

		if not S.sessOK and beli > 0 and frags > 0 then
			S.sessB = beli; S.sessF = frags; S.sessOK = true; S.sessStart = tick()
		end

		local sessBeliStr = "+0"
		local sessFragStr = "+0"
		if S.sessOK then
			local gb = math.floor(beli - S.sessB)
			local gf = math.floor(frags - S.sessF)
			sessBeliStr = (gb >= 0 and "+" or "") .. fmtN(gb)
			sessFragStr = (gf >= 0 and "+" or "") .. fmtN(gf)
		end

		local bPM = calcRateLR(S.beliSamples)
		local fPM = calcRateLR(S.fragSamples)

		EconomyParagraph:Set({
			Title = "Economy & Rates",
			Content = string.format("Total Beli: %s | Total Frags: %s\nSession Beli: %s | Session Frags: %s\nBeli/Min: %s | Beli/Hr: %s\nFrag/Min: %s | Frag/Hr: %s",
				fmtN(beli), fmtN(frags), sessBeliStr, sessFragStr,
				wFmt(bPM), wFmt(bPM * 60), wFmt(fPM), wFmt(fPM * 60)
			)
		})

		local ping = getPing()
		local elapsed = tick() - S.start
		PerfParagraph:Set({
			Title = "Performance & Server",
			Content = string.format("FPS: %d (Max: %d) | Ping: %dms\nTime Elapsed: %02d:%02d:%02d\nPlayers: %d/%d",
				S.fps, S.maxFps, ping,
				math.floor(elapsed / 3600), math.floor((elapsed % 3600) / 60), math.floor(elapsed % 60),
				#Pl:GetPlayers(), K_MAX
			)
		})

		local hopStr = S.hop and string.format("%02dm %02ds", math.floor(math.max(0, S.hopCD) / 60), math.floor(math.max(0, S.hopCD) % 60)) or "Disabled"
		local whStr = S.whTimer and string.format("%02dm %02ds", math.floor(math.max(0, S.whCD) / 60), math.floor(math.max(0, S.whCD) % 60)) or "Disabled"
		HopWHParagraph:Set({
			Title = "Timer Status",
			Content = string.format("Next Hop: %s\nNext Webhook: %s", hopStr, whStr)
		})
	end

	if _frame % 300 == 0 then
		local b = getStat("Beli")
		local f = getStat("Fragments")
		if b then pushSample(S.beliSamples, b) end
		if f then pushSample(S.fragSamples, f) end
	end
end)

-- PLAYER EVENTS
Pl.PlayerAdded:Connect(function(p)
	task.wait(1)
	S.plrC[p.UserId] = S.plrC[p.UserId] or {}
	S.plrC[p.UserId].join = tick()
	watchPlr(p)
	local dn = p.DisplayName ~= p.Name and (p.DisplayName .. " (@" .. p.Name .. ")") or p.Name
	notify("Player Joined", dn)
	if S.hidPlr then
		task.spawn(function()
			if not p.Character then p.CharacterAdded:Wait() end
			task.wait(.5)
			if S.hidPlr then setPlrVis(p, false) end
		end)
	end
end)

Pl.PlayerRemoving:Connect(function(p)
	local uid = p.UserId
	notify("Player Left", p.Name)
	if S.specTarget == p then stopSpec() end
	for _, t in ipairs({S.spawnW, S.raceW, S.bountyW}) do
		if t[uid] then t[uid]:Disconnect(); t[uid] = nil end
	end
	if S.hidPlrC[uid] then S.hidPlrC[uid]:Disconnect(); S.hidPlrC[uid] = nil end
	S.hidPlrData[uid] = nil
	S.plrC[uid] = nil
	S.statC[uid] = nil
end)

for _, p in ipairs(Pl:GetPlayers()) do
	if p ~= lp then watchPlr(p) end
end

-- AUTO INIT
if cfg.RemoveDeathEffect then
	local function rde()
		pcall(function()
			local d = ReplicatedStorage:WaitForChild("Effect", 10):WaitForChild("Container", 10):WaitForChild("Death", 10)
			if d then d:Destroy() end
		end)
	end
	rde()
	lp.CharacterAdded:Connect(function() task.wait(.5); rde() end)
end

if cfg.BoostV1 then task.spawn(function() task.wait(2); S.v1 = true; setV1(true) end) end
if cfg.BoostV2 then task.spawn(function() task.wait(2); S.v2 = true; setV2(true) end) end
if cfg.HidePlayers then task.spawn(function() task.wait(1); toggleHidePlr(true) end) end
if cfg.HideEnemies then task.spawn(function() task.wait(2); toggleHidEnm(true) end) end
if cfg.AutoHop then task.spawn(function() task.wait(6); startHop() end) end
if cfg.WebhookEnabled then S.wh = true end

if cfg.AutoRerun and cfg.AutoRerunURL and cfg.AutoRerunURL ~= "" then
	task.spawn(function()
		task.wait(3)
		startRerun()
	end)
end
