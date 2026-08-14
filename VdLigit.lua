if _G.vdHub and _G.vdHub.stop then
	pcall(_G.vdHub.stop)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local lp = Players.LocalPlayer
if not lp then
	repeat task.wait(0.5) until Players.LocalPlayer
	lp = Players.LocalPlayer
end

local cam = Workspace.CurrentCamera

local state = {
	running = true,
	cfg = {
		-- Spear Aimlock
		spear_enabled   = false,
		spear_key       = Enum.KeyCode.E,
		spear_isHolding = false,

		-- Auto Pallet
		p_enabled         = false,
		interactionRadius = 8,
		stunReach         = 7,
		cooldown          = 0.15,
		hz                = 240,
		p_dropKey         = 32,
		antiBait          = true,

		-- Auto Skillcheck
		sc_enabled  = false,
		sc_lead     = 2,
		sc_offset   = 102,
		sc_key      = 32,

		-- Auto Parry
		ap_enabled        = false,
		ap_cooldown       = 0.05,
		ap_showCircle     = true,
		ap_circleColor    = Color3.fromRGB(0, 255, 200),
		ap_animRadius     = 14,
		ap_animPreDelay   = 0,
		ap_pendingRadius  = 22,
		ap_hitboxRadius   = 16,
		ap_hitboxPreDelay = 0.0,

		-- Killer ESP
		esp_enabled       = false,
		esp_showName      = true,
		esp_showDist      = true,
		esp_showHighlight = true,
		esp_showBox       = true,
		esp_maxDist       = 500,

		-- Player ESP
		p_esp_enabled       = false,
		p_esp_showName      = true,
		p_esp_showDist      = true,
		p_esp_showHighlight = true,
		p_esp_showBox       = true,
		p_esp_showStatus    = true,
		p_esp_maxDist       = 500,
	}
}
_G.vdHub = state

-- [[ ANIM ID TABLES ]]

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
	[75258958842388]  = true,
	[96744338559260]  = true,
	[96839438835309]  = true,
	[133881825716964] = true,
	[71008020992570]  = true,
	[92098503722633]  = true,
}

local PARRY_ITEM_ANIM_IDS = {
	[127096285501517] = "Katana",
	[126894569253341] = "Feedbacker",
	[75939529748815]  = "Shield",
	[123307242865945] = "Fin",
	[72219761917132]  = "Sakuya",
	[109133187196613] = "Default",
}

local PARRY_ITEM_COOLDOWNS = {
	Katana     = 60.0,
	Feedbacker = 60.0,
	Shield     = 60.0,
	Fin        = 60.0,
	Sakuya     = 60.0,
	Default    = 60.0,
}

local PARRY_USE_DELAY = 0.5

-- [[ HELPER FUNCTIONS ]]

local function getAnimAssetId(track)
	local ok, animId = pcall(function()
		return track.Animation and track.Animation.AnimationId or ""
	end)
	if not ok then return nil end
	return tonumber(animId:match("(%d+)$"))
end

local function pressKey(keyCodeEnum, keyCodeNum)
	task.spawn(function()
		if typeof(keypress) == "function" and typeof(keyrelease) == "function" then
			pcall(function() keypress(keyCodeNum or 32); task.wait(0.01); keyrelease(keyCodeNum or 32) end)
		else
			pcall(function()
				VirtualInputManager:SendKeyEvent(true, keyCodeEnum or Enum.KeyCode.Space, false, game)
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
		VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
		task.wait(0.01)
		VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
	end)
end

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

-- [[ TEAM DETECTION ]]

local killerTeamKeywords = { "Killer" }
local spectatorKeywords  = { "Spectator" }

local function isSpectator()
	local team = lp.Team
	if not team then return false end
	local tn = string.lower(tostring(team.Name or ""))
	for _, kw in ipairs(spectatorKeywords) do
		if tn:find(string.lower(kw)) then return true end
	end
	return false
end

local function hasKillerTeamName(plr)
	local tn = plr.Team and string.lower(tostring(plr.Team.Name or "")) or ""
	for _, kw in ipairs(killerTeamKeywords) do
		if tn:find(string.lower(kw)) then return true end
	end
	return false
end

local function isSurvivor()
	if isSpectator() then return false end
	if hasKillerTeamName(lp) then return false end
	return true
end

local function isKillerPlayer(plr)
	if plr == lp then return false end
	if hasKillerTeamName(plr) then return true end
	if not hasKillerTeamName(lp) then
		if lp.Team and plr.Team and plr.Team ~= lp.Team then
			local tn = plr.Team and string.lower(tostring(plr.Team.Name or "")) or ""
			for _, kw in ipairs(spectatorKeywords) do
				if tn:find(string.lower(kw)) then return false end
			end
			return true
		end
	end
	return false
end
-- [[ PALLET & KILLER REFRESH ]]

local pallets = {}
local killerRoots = {}
local lastDrop, droppedPallets = {}, {}
local uiLabels = { status = nil, killerDist = nil, parryDaggerCD = nil }
local pStat = { elig=false, inZone=false, hp=true, nearD=nil, killD=nil, baiting=false }
local scLast = { l=nil, g=nil, win=nil }
local scHits, scFired = 0, false

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
	local out, byParent = {}, {}
	for _, d in ipairs(Workspace:GetDescendants()) do
		local ok, nm = pcall(function() return d.Name end)
		if not ok then continue end
		if (nm == "PalletPoint" and d.ClassName == "Part") or (string.lower(nm):find("pallet") and d:IsA("BasePart")) then
			local par = d.Parent
			if par then
				local e = byParent[par]
				if not e then
					local board = par:FindFirstChild("PrimaryPartPallet") or par:FindFirstChild("Board") or d
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
	end
	pallets = out
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

-- [[ AUTO PALLET ]]

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
		if speed < 1 then return true, true end
		if (kVel.X*dirX + kVel.Z*dirZ) < -2.5 then return true, false end
	end
	return true, true
end

task.spawn(function()
	while state.running do
		local c = state.cfg
		local elig, zone, isBaiting = false, false, false
		local nearD = nil
		if c.p_enabled and isSurvivor() then
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

-- [[ AUTO SKILLCHECK ]]

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

-- [[ AUTO PARRY ]]

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
	if not isSurvivor() then return end
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
	if not isSurvivor() then return end
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
		if not isSurvivor() then return end
		if not obj:IsA("BasePart") or not isHitboxName(obj.Name) then return end
		local me = myRoot(); if not me then return end
		local ok,dist = pcall(function() return (me.Position-obj.Position).Magnitude end)
		if ok and dist <= (state.cfg.ap_hitboxRadius or 16) then
			parry("HitboxSpawn:"..obj.Name, state.cfg.ap_hitboxPreDelay or 0)
		end
		pcall(function()
			obj:GetPropertyChangedSignal("Size"):Connect(function()
				if not state.cfg.ap_enabled then return end
				if not isSurvivor() then return end
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
					if not isSurvivor() then return end
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
	if not isSurvivor() then return end
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
		if state.cfg.ap_enabled and isSurvivor() then
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

-- [[ PARRY ITEM TRACKER ]]

local function getCharAttribute(char, attrName)
	if not char then return nil end
	local val = char:GetAttribute(attrName)
	if val ~= nil then return val end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		val = hum:GetAttribute(attrName)
		if val ~= nil then return val end
	end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		val = root:GetAttribute(attrName)
		if val ~= nil then return val end
	end
	return nil
end

local playerParryState = {}
local monitoredPlayerAnimators = {}

local function onPlayerParryAnimPlayed(plr, track)
	local animId = getAnimAssetId(track)
	if not animId then return end
	local itemName = PARRY_ITEM_ANIM_IDS[animId]
	if not itemName then return end
	local cdSec = PARRY_ITEM_COOLDOWNS[itemName] or 60.0
	playerParryState[plr] = {
		itemName    = itemName,
		lastUsed    = nil,
		cooldownSec = cdSec,
		pending     = true,
	}
	task.delay(PARRY_USE_DELAY, function()
		local ps = playerParryState[plr]
		if ps and ps.pending and ps.itemName == itemName then
			ps.lastUsed = tick()
			ps.pending  = false
		end
	end)
end

local function attachPlayerAnimListener(plr)
	if monitoredPlayerAnimators[plr] then return end
	monitoredPlayerAnimators[plr] = true
	local function tryAttach(char)
		if not char then return end
		local anim = findAnimator(char)
		if not anim then return end
		anim.AnimationPlayed:Connect(function(track)
			onPlayerParryAnimPlayed(plr, track)
		end)
	end
	pcall(tryAttach, plr.Character)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		pcall(tryAttach, char)
		playerParryState[plr] = nil
	end)
end

task.spawn(function()
	while state.running do
		pcall(function()
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= lp and not isKillerPlayer(plr) then
					attachPlayerAnimListener(plr)
				end
			end
		end)
		task.wait(2.0)
	end
end)

Players.PlayerAdded:Connect(function(plr)
	task.wait(1.0)
	pcall(function()
		if not isKillerPlayer(plr) then
			attachPlayerAnimListener(plr)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	playerParryState[plr] = nil
	monitoredPlayerAnimators[plr] = nil
end)

-- [[ 2D ESP ]]

local espGui = Instance.new("ScreenGui")
espGui.Name           = "VDHub_2DESP_ScreenGui"
espGui.ResetOnSpawn   = false
espGui.DisplayOrder   = 999
espGui.IgnoreGuiInset = true
espGui.Parent         = game:GetService("CoreGui")

local killer2DEspElements = {}
local player2DEspElements = {}

local function get2DScreenBounds(char)
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local cam = workspace.CurrentCamera
	if not cam then return nil end
	local head = char:FindFirstChild("Head")
	local topY    = head and (head.Position.Y + 1.2) or (root.Position.Y + 3.2)
	local bottomY = root.Position.Y - 3.2
	local rootPos    = root.Position
	local topWorld    = Vector3.new(rootPos.X, topY, rootPos.Z)
	local bottomWorld = Vector3.new(rootPos.X, bottomY, rootPos.Z)
	local topScreen, topOn       = cam:WorldToViewportPoint(topWorld)
	local bottomScreen, bottomOn = cam:WorldToViewportPoint(bottomWorld)
	if not (topOn and bottomOn) or topScreen.Z < 0 then return nil end
	local height = math.abs(bottomScreen.Y - topScreen.Y)
	if height < 6 then height = 6 end
	local width = math.clamp(height * 0.62, 10, 450)
	local x = topScreen.X - (width / 2)
	local y = topScreen.Y
	return x, y, width, height, topScreen.Z
end

local function removeKiller2DESP(char)
	if killer2DEspElements[char] then
		pcall(function() killer2DEspElements[char].container:Destroy() end)
		pcall(function() killer2DEspElements[char].highlight:Destroy() end)
		killer2DEspElements[char] = nil
	end
end

local function createKiller2DESP(char)
	removeKiller2DESP(char)

	local highlight = Instance.new("Highlight")
	highlight.Name                = "VDHub_Killer_Highlight"
	highlight.FillColor           = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor        = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency    = 0.6
	highlight.OutlineTransparency = 0
	highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee             = char
	highlight.Parent              = char

	local container = Instance.new("Frame")
	container.Name                   = "Killer2DContainer"
	container.BackgroundTransparency = 1
	container.Size                   = UDim2.new(1, 0, 1, 0)
	container.Parent                 = espGui

	local boxFrame = Instance.new("Frame")
	boxFrame.BackgroundTransparency = 1
	boxFrame.Parent                 = container

	local stroke = Instance.new("UIStroke")
	stroke.Color     = Color3.fromRGB(255, 0, 0)
	stroke.Thickness = 1.5
	stroke.Parent    = boxFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size                   = UDim2.new(0, 160, 0, 16)
	nameLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font                   = Enum.Font.GothamBold
	nameLabel.TextSize               = 11
	nameLabel.TextXAlignment         = Enum.TextXAlignment.Center
	nameLabel.Text                   = char.Name
	nameLabel.Parent                 = container

	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Size                   = UDim2.new(0, 160, 0, 14)
	distLabel.TextColor3             = Color3.fromRGB(255, 200, 0)
	distLabel.TextStrokeTransparency = 0
	distLabel.Font                   = Enum.Font.GothamBold
	distLabel.TextSize               = 10
	distLabel.TextXAlignment         = Enum.TextXAlignment.Center
	distLabel.Text                   = ""
	distLabel.Parent                 = container

	killer2DEspElements[char] = {
		container = container,
		highlight = highlight,
		boxFrame  = boxFrame,
		nameLabel = nameLabel,
		distLabel = distLabel,
	}
end

local function removePlayer2DESP(char)
	if player2DEspElements[char] then
		pcall(function() player2DEspElements[char].container:Destroy() end)
		pcall(function() player2DEspElements[char].highlight:Destroy() end)
		player2DEspElements[char] = nil
	end
end

local function createPlayer2DESP(char)
	removePlayer2DESP(char)

	local highlight = Instance.new("Highlight")
	highlight.Name                = "VDHub_Player_Highlight"
	highlight.FillColor           = Color3.fromRGB(0, 150, 255)
	highlight.OutlineColor        = Color3.fromRGB(0, 200, 255)
	highlight.FillTransparency    = 0.6
	highlight.OutlineTransparency = 0
	highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee             = char
	highlight.Parent              = char

	local container = Instance.new("Frame")
	container.Name                   = "Player2DContainer"
	container.BackgroundTransparency = 1
	container.Size                   = UDim2.new(1, 0, 1, 0)
	container.Parent                 = espGui

	local boxFrame = Instance.new("Frame")
	boxFrame.BackgroundTransparency = 1
	boxFrame.Parent                 = container

	local stroke = Instance.new("UIStroke")
	stroke.Color     = Color3.fromRGB(0, 170, 255)
	stroke.Thickness = 1.5
	stroke.Parent    = boxFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size                   = UDim2.new(0, 160, 0, 16)
	nameLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font                   = Enum.Font.GothamBold
	nameLabel.TextSize               = 11
	nameLabel.TextXAlignment         = Enum.TextXAlignment.Center
	nameLabel.Text                   = char.Name
	nameLabel.Parent                 = container

	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Size                   = UDim2.new(0, 160, 0, 14)
	distLabel.TextColor3             = Color3.fromRGB(0, 200, 255)
	distLabel.TextStrokeTransparency = 0
	distLabel.Font                   = Enum.Font.GothamBold
	distLabel.TextSize               = 10
	distLabel.TextXAlignment         = Enum.TextXAlignment.Center
	distLabel.Text                   = ""
	distLabel.Parent                 = container

	local sideFrame = Instance.new("Frame")
	sideFrame.BackgroundTransparency = 1
	sideFrame.Size                   = UDim2.new(0, 140, 0, 56)
	sideFrame.Parent                 = container

	local listLayoutR = Instance.new("UIListLayout")
	listLayoutR.SortOrder = Enum.SortOrder.LayoutOrder
	listLayoutR.Padding   = UDim.new(0, 0)
	listLayoutR.Parent    = sideFrame

	local knockedLabel = Instance.new("TextLabel")
	knockedLabel.LayoutOrder            = 1
	knockedLabel.BackgroundTransparency = 1
	knockedLabel.Size                   = UDim2.new(1, 0, 0, 14)
	knockedLabel.Font                   = Enum.Font.GothamBold
	knockedLabel.TextSize               = 10
	knockedLabel.TextColor3             = Color3.fromRGB(0, 255, 150)
	knockedLabel.TextXAlignment         = Enum.TextXAlignment.Left
	knockedLabel.TextStrokeTransparency = 0
	knockedLabel.Text                   = "Knocked: NO"
	knockedLabel.Parent                 = sideFrame

	local hookCountLabel = Instance.new("TextLabel")
	hookCountLabel.LayoutOrder            = 2
	hookCountLabel.BackgroundTransparency = 1
	hookCountLabel.Size                   = UDim2.new(1, 0, 0, 14)
	hookCountLabel.Font                   = Enum.Font.GothamBold
	hookCountLabel.TextSize               = 10
	hookCountLabel.TextColor3             = Color3.fromRGB(255, 200, 80)
	hookCountLabel.TextXAlignment         = Enum.TextXAlignment.Left
	hookCountLabel.TextStrokeTransparency = 0
	hookCountLabel.Text                   = "Hook: 0"
	hookCountLabel.Parent                 = sideFrame

	local hookedProgLabel = Instance.new("TextLabel")
	hookedProgLabel.LayoutOrder            = 3
	hookedProgLabel.BackgroundTransparency = 1
	hookedProgLabel.Size                   = UDim2.new(1, 0, 0, 14)
	hookedProgLabel.Font                   = Enum.Font.GothamBold
	hookedProgLabel.TextSize               = 10
	hookedProgLabel.TextColor3             = Color3.fromRGB(150, 210, 255)
	hookedProgLabel.TextXAlignment         = Enum.TextXAlignment.Left
	hookedProgLabel.TextStrokeTransparency = 0
	hookedProgLabel.Text                   = "HookProg: 100"
	hookedProgLabel.Parent                 = sideFrame

	local healProgLabel = Instance.new("TextLabel")
	healProgLabel.LayoutOrder            = 4
	healProgLabel.BackgroundTransparency = 1
	healProgLabel.Size                   = UDim2.new(1, 0, 0, 14)
	healProgLabel.Font                   = Enum.Font.GothamBold
	healProgLabel.TextSize               = 10
	healProgLabel.TextColor3             = Color3.fromRGB(255, 130, 220)
	healProgLabel.TextXAlignment         = Enum.TextXAlignment.Left
	healProgLabel.TextStrokeTransparency = 0
	healProgLabel.Text                   = "HealProg: 0.0"
	healProgLabel.Parent                 = sideFrame

	local leftFrame = Instance.new("Frame")
	leftFrame.BackgroundTransparency = 1
	leftFrame.Size                   = UDim2.new(0, 140, 0, 28)
	leftFrame.Parent                 = container

	local listLayoutL = Instance.new("UIListLayout")
	listLayoutL.SortOrder = Enum.SortOrder.LayoutOrder
	listLayoutL.Padding   = UDim.new(0, 0)
	listLayoutL.Parent    = leftFrame

	local itemsLabel = Instance.new("TextLabel")
	itemsLabel.LayoutOrder            = 1
	itemsLabel.BackgroundTransparency = 1
	itemsLabel.Size                   = UDim2.new(1, 0, 0, 14)
	itemsLabel.Font                   = Enum.Font.GothamBold
	itemsLabel.TextSize               = 10
	itemsLabel.TextColor3             = Color3.fromRGB(255, 80, 255)
	itemsLabel.TextXAlignment         = Enum.TextXAlignment.Right
	itemsLabel.TextStrokeTransparency = 0
	itemsLabel.Text                   = ""
	itemsLabel.TextWrapped            = true
	itemsLabel.Parent                 = leftFrame

	local parryItemLabel = Instance.new("TextLabel")
	parryItemLabel.LayoutOrder            = 2
	parryItemLabel.BackgroundTransparency = 1
	parryItemLabel.Size                   = UDim2.new(1, 0, 0, 14)
	parryItemLabel.Font                   = Enum.Font.GothamBold
	parryItemLabel.TextSize               = 10
	parryItemLabel.TextColor3             = Color3.fromRGB(120, 220, 255)
	parryItemLabel.TextXAlignment         = Enum.TextXAlignment.Right
	parryItemLabel.TextStrokeTransparency = 0
	parryItemLabel.Text                   = ""
	parryItemLabel.Parent                 = leftFrame

	player2DEspElements[char] = {
		container        = container,
		highlight        = highlight,
		boxFrame         = boxFrame,
		nameLabel        = nameLabel,
		distLabel        = distLabel,
		sideFrame        = sideFrame,
		knockedLabel     = knockedLabel,
		hookCountLabel   = hookCountLabel,
		hookedProgLabel  = hookedProgLabel,
		healProgLabel    = healProgLabel,
		leftFrame        = leftFrame,
		parryDaggerLabel = itemsLabel,
		parryItemLabel   = parryItemLabel,
	}
end

local _cachedPlayers = {}
local _playerCacheTime = 0

RunService.RenderStepped:Connect(function()
	if not state.running then return end
	local c = state.cfg

	local spectating = isSpectator()
	if spectating then
		for char in pairs(killer2DEspElements) do removeKiller2DESP(char) end
		for char in pairs(player2DEspElements) do removePlayer2DESP(char) end
		return
	end

	local cam = workspace.CurrentCamera
	if not cam then return end

	-- Killer ESP
	if c.esp_enabled then
		for _, kRoot in ipairs(killerRoots) do
			local char = kRoot and kRoot.Parent
			if char then
				if not killer2DEspElements[char] then createKiller2DESP(char) end
				local elem = killer2DEspElements[char]
				if elem then
					local x, y, width, height, dist = get2DScreenBounds(char)
					local inRange = (not dist) or (dist <= c.esp_maxDist)
					if elem.highlight then
						elem.highlight.Enabled = c.esp_showHighlight and inRange
					end
					if x and inRange then
						local dynamicFont = math.clamp(math.floor(height * 0.2), 8, 11)
						elem.container.Visible = true
						elem.boxFrame.Visible  = c.esp_showBox
						elem.boxFrame.Position = UDim2.new(0, x, 0, y)
						elem.boxFrame.Size     = UDim2.new(0, width, 0, height)
						elem.nameLabel.Visible  = c.esp_showName
						elem.nameLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y - (dynamicFont + 6))
						elem.nameLabel.TextSize = dynamicFont
						elem.distLabel.Visible  = c.esp_showDist
						elem.distLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y + height + 2)
						elem.distLabel.TextSize = math.max(7, dynamicFont - 1)
						elem.distLabel.Text     = string.format("[%d studs]", math.floor(dist))
					else
						elem.container.Visible = false
					end
				end
			end
		end
	else
		for char in pairs(killer2DEspElements) do removeKiller2DESP(char) end
	end

	-- Player ESP
	if c.p_esp_enabled then
		local now = tick()
		if (now - _playerCacheTime) > 0.5 then
			_cachedPlayers = Players:GetPlayers()
			_playerCacheTime = now
		end

		local showHL  = c.p_esp_showHighlight
		local showBox = c.p_esp_showBox
		local showSt  = c.p_esp_showStatus

		for _, plr in ipairs(_cachedPlayers) do
			if plr ~= lp and not isKillerPlayer(plr) then
				local char = plr.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if char and root then
					if not player2DEspElements[char] then createPlayer2DESP(char) end
					local elem = player2DEspElements[char]
					if elem then
						local x, y, width, height, dist = get2DScreenBounds(char)
						local inRange = (not dist) or (dist <= c.p_esp_maxDist)
						if elem.highlight then
							elem.highlight.Enabled = showHL and inRange
						end
						if x and inRange then
							local dynamicFont = math.clamp(math.floor(height * 0.18), 8, 11)
							local sidePadding = math.clamp(math.floor(width * 0.15), 4, 8)
							local lineHeight  = math.clamp(math.floor(height * 0.22), 10, 14)
							local hideIfFar   = dist > 150

							elem.container.Visible = true
							elem.boxFrame.Visible  = showBox
							elem.boxFrame.Position = UDim2.new(0, x, 0, y)
							elem.boxFrame.Size     = UDim2.new(0, width, 0, height)
							elem.nameLabel.Visible  = c.p_esp_showName
							elem.nameLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y - (dynamicFont + 6))
							elem.nameLabel.TextSize = dynamicFont
							elem.distLabel.Visible  = c.p_esp_showDist
							elem.distLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y + height + 2)
							elem.distLabel.TextSize = math.max(7, dynamicFont - 1)
							elem.distLabel.Text     = string.format("[%d studs]", math.floor(dist))
							elem.sideFrame.Visible  = showSt and not hideIfFar
							elem.sideFrame.Position = UDim2.new(0, x + width + sidePadding, 0, y)
							elem.leftFrame.Visible  = showSt and not hideIfFar
							elem.leftFrame.Size     = UDim2.new(0, 140, 0, lineHeight * 2)
							elem.leftFrame.Position = UDim2.new(0, x - 140 - sidePadding, 0, y)
							elem.knockedLabel.TextSize    = dynamicFont
							elem.knockedLabel.Size        = UDim2.new(1, 0, 0, lineHeight)
							elem.hookCountLabel.TextSize  = dynamicFont
							elem.hookCountLabel.Size      = UDim2.new(1, 0, 0, lineHeight)
							elem.hookedProgLabel.TextSize = dynamicFont
							elem.hookedProgLabel.Size     = UDim2.new(1, 0, 0, lineHeight)
							elem.healProgLabel.TextSize   = dynamicFont
							elem.healProgLabel.Size       = UDim2.new(1, 0, 0, lineHeight)
							elem.parryDaggerLabel.TextSize = dynamicFont
							elem.parryDaggerLabel.Size     = UDim2.new(1, 0, 0, lineHeight)
							elem.parryItemLabel.TextSize   = dynamicFont
							elem.parryItemLabel.Size       = UDim2.new(1, 0, 0, lineHeight)

							if showSt and not hideIfFar then
								local isKnocked  = getCharAttribute(char, "Knocked")
								local hookCount  = getCharAttribute(char, "HookCount") or 0
								local hookedProg = getCharAttribute(char, "HookedProgress") or 100
								local healProg   = getCharAttribute(char, "HealProgress") or 0

								if isKnocked == true then
									elem.knockedLabel.Text       = "Knocked: YES"
									elem.knockedLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
								else
									elem.knockedLabel.Text       = "Knocked: NO"
									elem.knockedLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
								end
								elem.hookCountLabel.Text  = string.format("Hook: %d", tonumber(hookCount) or 0)
								elem.hookedProgLabel.Text = string.format("HookProg: %.1f", tonumber(hookedProg) or 0)
								elem.healProgLabel.Text   = string.format("HealProg: %.1f", tonumber(healProg) or 0)

								-- Items ESP
								if elem.parryDaggerLabel then
									local itemNames = {}
									for _, obj in ipairs(char:GetChildren()) do
										if obj:IsA("Model") then
											itemNames[#itemNames + 1] = obj.Name
										end
									end
									if #itemNames > 0 then
										elem.parryDaggerLabel.Text       = table.concat(itemNames, ", ")
										elem.parryDaggerLabel.TextColor3 = Color3.fromRGB(255, 80, 255)
									else
										elem.parryDaggerLabel.Text = ""
									end
								end

								-- Parry item cooldown
								if elem.parryItemLabel then
									local ps = playerParryState[plr]
									if ps and not ps.pending and ps.lastUsed then
										local elapsed = tick() - ps.lastUsed
										local pct     = math.clamp(elapsed / ps.cooldownSec, 0, 1)
										local pctInt  = math.floor(pct * 100)
										if pctInt >= 100 then
											elem.parryItemLabel.Text       = string.format("[%s] READY", ps.itemName)
											elem.parryItemLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
										else
											elem.parryItemLabel.Text       = string.format("[%s] CD %d%%", ps.itemName, pctInt)
											elem.parryItemLabel.TextColor3 = Color3.fromRGB(255, 160, 60)
										end
									else
										elem.parryItemLabel.Text = ""
									end
								end
							end
						else
							elem.container.Visible = false
						end
					end
				end
			end
		end
	else
		for char in pairs(player2DEspElements) do removePlayer2DESP(char) end
	end
end)

task.spawn(function()
	while state.running do
		for char in pairs(killer2DEspElements) do
			local alive = false
			for _, kRoot in ipairs(killerRoots) do
				if kRoot.Parent == char then alive = true; break end
			end
			if not alive then removeKiller2DESP(char) end
		end
		for char in pairs(player2DEspElements) do
			local alive = false
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character == char then alive = true; break end
			end
			if not alive then removePlayer2DESP(char) end
		end
		task.wait(1.0)
	end
end)


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

-- PARRY DAGGER CD TRACKER

task.spawn(function()
	while state.running do
		pcall(function()
			if not uiLabels.parryDaggerCD then return end
			local pg   = lp:FindFirstChild("PlayerGui")
			local surv = pg   and pg:FindFirstChild("Survivor")
			local gen  = surv and surv:FindFirstChild("Gen")
			local item = gen  and gen:FindFirstChild("ItemFrame")
			local gui  = item and item:FindFirstChild("Gui")
			local bar  = gui  and gui:FindFirstChild("Bar")
			local grad = bar  and bar:FindFirstChild("UIGradient")
			if not grad then
				uiLabels.parryDaggerCD:SetText("Parry Dagger: N/A")
				return
			end
			local offsetY = grad.Offset.Y
			local pct     = math.clamp(1.0 - (offsetY - 0.25) / (0.75 - 0.25), 0, 1)
			local pctInt  = math.floor(pct * 100)
			if pctInt >= 100 then
				uiLabels.parryDaggerCD:SetText("Parry Dagger: READY")
			else
				uiLabels.parryDaggerCD:SetText(string.format("Parry Dagger: CD %d%%", pctInt))
			end
		end)
		task.wait(0.05)
	end
end)

-- SPEAR AIMLOCK
local _skillCDCache = false
local _skillCDLastCheck = 0

local function getSkillCooldownState()
	local now = tick()
	if (now - _skillCDLastCheck) < 2 then
		return _skillCDCache
	end
	_skillCDLastCheck = now
	local ok, result = pcall(function()
		local pg   = Players.LocalPlayer:FindFirstChild("PlayerGui")
		local sla  = pg  and pg:FindFirstChild("Slasher")
		local gen  = sla and sla:FindFirstChild("Gen")
		local mv2  = gen and gen:FindFirstChild("Move2")
		local bar  = mv2 and mv2:FindFirstChild("Bar")
		local grad = bar and bar:FindFirstChild("UIGradient")
		if not grad then return false end
		return grad.Offset.Y == 0
	end)
	_skillCDCache = ok and result
	return _skillCDCache
end

local function getSpearTarget()
	local me = myRoot()
	if not me then return nil, nil end

	local cam = workspace.CurrentCamera
	if not cam then return nil, nil end

	local mousePos = UserInputService:GetMouseLocation()

	local best, minDist = nil, math.huge

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp and plr.Character then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			local hum  = plr.Character:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				if not isKillerPlayer(plr) and not isSpectator() then
					local screenPos, onScreen = cam:WorldToViewportPoint(root.Position)
					if onScreen and screenPos.Z > 0 then
						local dx = screenPos.X - mousePos.X
						local dy = screenPos.Y - mousePos.Y
						local screenDist = math.sqrt(dx*dx + dy*dy)
						if screenDist < minDist then
							minDist = screenDist
							best = root
						end
					end
				end
			end
		end
	end

	return best, "survivor"
end

local function calculateSpearAim(origin, targetPos, targetVel)
	local skillReady = getSkillCooldownState()

	local SPEED, GRAVITY
	if skillReady then
		SPEED   = 200
		GRAVITY = 150
	else
		SPEED   = 160
		GRAVITY = 135
	end

	local toTarget  = targetPos - origin
	local horizDist = Vector3.new(toTarget.X, 0, toTarget.Z).Magnitude
	local t         = horizDist / SPEED

	local predPos = (targetVel and targetVel.Magnitude > 0.5)
		and (targetPos + targetVel * t)
		or targetPos

	return predPos + Vector3.new(0, 0.5 * GRAVITY * (t * t), 0)
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == state.cfg.spear_key then
		state.cfg.spear_isHolding = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == state.cfg.spear_key then
		state.cfg.spear_isHolding = false
	end
end)

RunService.RenderStepped:Connect(function()
	if not (state.running and state.cfg.spear_enabled and state.cfg.spear_isHolding) then return end
	local target, targetType = getSpearTarget()
	if not target then return end

	local camCF = workspace.CurrentCamera.CFrame
	local aimPos

	if targetType == "spear" then
		aimPos = target.Position
	else
		local targetVel = target.AssemblyLinearVelocity or target.Velocity
		aimPos = calculateSpearAim(camCF.Position, target.Position, targetVel)
	end

	workspace.CurrentCamera.CFrame = CFrame.lookAt(camCF.Position, aimPos)
end)

-- [[ MOONWALK ]]

local moonwalkEnabled = false
local moonwalkKey     = Enum.KeyCode.R

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == moonwalkKey then
		moonwalkEnabled = not moonwalkEnabled
		print("[vdHub] Moonwalk: " .. (moonwalkEnabled and "ON" or "OFF"))
	end
end)

RunService.Heartbeat:Connect(function()
	if not state.running then return end
	if not moonwalkEnabled then return end
	local ch = lp.Character
	if not ch then return end
	local root = ch:FindFirstChild("HumanoidRootPart")
	local hum  = ch:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local moveDir = hum.MoveDirection
	if moveDir.Magnitude < 0.1 then return end
	local pos     = root.Position
	local backDir = Vector3.new(-moveDir.X, 0, -moveDir.Z).Unit
	root.CFrame   = CFrame.new(pos, pos + backDir)
end)

-- [[ UI — LIBRARY ]]

local repo         = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
Library            = loadstring(game:HttpGet(repo.."Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo.."addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo.."addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
	Title            = "vdHub",
	Footer           = "v3.4",
	Icon             = 95816097006870,
	NotifySide       = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Survivor        = Window:AddTab("Survivor", "user"),
	Killer          = Window:AddTab("Killer",   "sword"),
	ESP             = Window:AddTab("ESP",       "eye"),
	["UI Settings"] = Window:AddTab("Settings",  "settings"),
}

-- [[ SURVIVOR TAB ]]

local PalletBox = Tabs.Survivor:AddLeftGroupbox("Auto Pallet Stun")
local SkillBox  = Tabs.Survivor:AddRightGroupbox("Auto Skillcheck")
local ParryBox  = Tabs.Survivor:AddLeftGroupbox("Auto Parry")
local ParryStatusBox = Tabs.Survivor:AddRightGroupbox("Parry Status")

-- Pallet
PalletBox:AddToggle("AutoPallet", {
	Text    = "Auto Pallet Stun",
	Default = state.cfg.p_enabled,
	Tooltip = "Automatically drop pallets on Killers",
	Callback = function(v) state.cfg.p_enabled = v end,
})
PalletBox:AddToggle("AntiBait", {
	Text     = "Anti Bait",
	Default  = state.cfg.antiBait,
	Callback = function(v) state.cfg.antiBait = v end,
})
PalletBox:AddSlider("StunReach", {
	Text     = "Stun Reach",
	Default  = state.cfg.stunReach,
	Min=4, Max=20, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.stunReach = v end,
})
PalletBox:AddSlider("InteractRadius", {
	Text     = "Interact Radius",
	Default  = state.cfg.interactionRadius,
	Min=4, Max=25, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.interactionRadius = v end,
})
PalletBox:AddSlider("PalletCooldown", {
	Text     = "Space Cooldown",
	Default  = state.cfg.cooldown,
	Min=0.05, Max=1.5, Rounding=2, Suffix="s",
	Callback = function(v) state.cfg.cooldown = v end,
})

-- Skillcheck
SkillBox:AddToggle("AutoSkillcheck", {
	Text     = "Auto Skillcheck",
	Default  = state.cfg.sc_enabled,
	Callback = function(v) state.cfg.sc_enabled = v end,
})
SkillBox:AddSlider("ScOffset", {
	Text     = "Hit Zone Offset",
	Default  = state.cfg.sc_offset,
	Min=80, Max=130, Rounding=0, Suffix="°",
	Callback = function(v) state.cfg.sc_offset = v end,
})
SkillBox:AddSlider("ScLead", {
	Text     = "Lead Angle",
	Default  = state.cfg.sc_lead,
	Min=0, Max=10, Rounding=0, Suffix="°",
	Callback = function(v) state.cfg.sc_lead = v end,
})

-- Auto Parry
ParryBox:AddToggle("AutoParry", {
	Text     = "Auto Parry (Right Click)",
	Default  = state.cfg.ap_enabled,
	Callback = function(v)
		state.cfg.ap_enabled = v
		if uiLabels.status then
			uiLabels.status:SetText("Status: " .. (v and "Active" or "Disabled"))
		end
	end,
})
ParryBox:AddToggle("ShowParryCircle", {
	Text     = "Show Detect Radius",
	Default  = state.cfg.ap_showCircle,
	Callback = function(v)
		state.cfg.ap_showCircle = v
		if parryAdornment then parryAdornment.Visible = v end
	end,
}):AddColorPicker("ParryCircleColor", {
	Default  = state.cfg.ap_circleColor,
	Title    = "Ring Color",
	Callback = function(v) state.cfg.ap_circleColor = v end,
})
ParryBox:AddSlider("AnimParryRadius", {
	Text     = "Anim Detect Radius",
	Default  = state.cfg.ap_animRadius,
	Min=5, Max=20, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.ap_animRadius = v end,
})
ParryBox:AddSlider("PendingRadius", {
	Text     = "Pending Swing Radius",
	Default  = state.cfg.ap_pendingRadius,
	Min=10, Max=35, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.ap_pendingRadius = v end,
})
ParryBox:AddSlider("HitboxRadius", {
	Text     = "Hitbox Detect Buffer",
	Default  = state.cfg.ap_hitboxRadius,
	Min=5, Max=25, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.ap_hitboxRadius = v end,
})
ParryBox:AddSlider("ParryCooldown", {
	Text     = "Parry Cooldown",
	Default  = state.cfg.ap_cooldown,
	Min=0.05, Max=2.0, Rounding=2, Suffix="s",
	Callback = function(v) state.cfg.ap_cooldown = v; PARRY_COOLDOWN = v end,
})
ParryBox:AddSlider("AnimPreDelay", {
	Text     = "Anim Pre-Delay",
	Default  = state.cfg.ap_animPreDelay,
	Min=0.0, Max=0.3, Rounding=2, Suffix="s",
	Callback = function(v) state.cfg.ap_animPreDelay = v end,
})

-- Parry Status
uiLabels.status        = ParryStatusBox:AddLabel("Status: Disabled")
uiLabels.killerDist    = ParryStatusBox:AddLabel("Killer: None")
uiLabels.parryDaggerCD = ParryStatusBox:AddLabel("Parry Dagger: N/A")

if state.cfg.ap_enabled and uiLabels.status then
	uiLabels.status:SetText("Status: Active")
end


local AimBox = Tabs.Killer:AddLeftGroupbox("Spear Aimlock")

AimBox:AddToggle("SpearAimlock", {
	Text     = "Spear Aimlock (Hold E)",
	Default  = state.cfg.spear_enabled,
	Tooltip  = "",
	Callback = function(v) state.cfg.spear_enabled = v end,
})

-- [[ ESP TAB ]]

local ESPBox       = Tabs.ESP:AddLeftGroupbox("Killer ESP")
local PlayerESPBox = Tabs.ESP:AddRightGroupbox("Player ESP")

ESPBox:AddToggle("ESPEnabled", {
	Text     = "Enable Killer ESP",
	Default  = state.cfg.esp_enabled,
	Callback = function(v) state.cfg.esp_enabled = v end,
})
ESPBox:AddToggle("ESPShowHighlight", {
	Text     = "Show 3D Highlight",
	Default  = state.cfg.esp_showHighlight,
	Callback = function(v) state.cfg.esp_showHighlight = v end,
})
ESPBox:AddToggle("ESPShowBox", {
	Text     = "Show 2D Box",
	Default  = state.cfg.esp_showBox,
	Callback = function(v) state.cfg.esp_showBox = v end,
})
ESPBox:AddToggle("ESPShowName", {
	Text     = "Show Name",
	Default  = state.cfg.esp_showName,
	Callback = function(v) state.cfg.esp_showName = v end,
})
ESPBox:AddToggle("ESPShowDist", {
	Text     = "Show Distance",
	Default  = state.cfg.esp_showDist,
	Callback = function(v) state.cfg.esp_showDist = v end,
})
ESPBox:AddSlider("ESPMaxDist", {
	Text     = "Max Distance",
	Default  = state.cfg.esp_maxDist,
	Min=50, Max=1000, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.esp_maxDist = v end,
})

PlayerESPBox:AddToggle("PlayerESPEnabled", {
	Text     = "Enable Player ESP",
	Default  = state.cfg.p_esp_enabled,
	Callback = function(v) state.cfg.p_esp_enabled = v end,
})
PlayerESPBox:AddToggle("PlayerESPShowHighlight", {
	Text     = "Show 3D Highlight",
	Default  = state.cfg.p_esp_showHighlight,
	Callback = function(v) state.cfg.p_esp_showHighlight = v end,
})
PlayerESPBox:AddToggle("PlayerESPShowBox", {
	Text     = "Show 2D Box",
	Default  = state.cfg.p_esp_showBox,
	Callback = function(v) state.cfg.p_esp_showBox = v end,
})
PlayerESPBox:AddToggle("PlayerESPShowName", {
	Text     = "Show Name",
	Default  = state.cfg.p_esp_showName,
	Callback = function(v) state.cfg.p_esp_showName = v end,
})
PlayerESPBox:AddToggle("PlayerESPShowDist", {
	Text     = "Show Distance",
	Default  = state.cfg.p_esp_showDist,
	Callback = function(v) state.cfg.p_esp_showDist = v end,
})
PlayerESPBox:AddToggle("PlayerESPShowStatus", {
	Text     = "Show Side Panel",
	Default  = state.cfg.p_esp_showStatus,
	Callback = function(v) state.cfg.p_esp_showStatus = v end,
})
PlayerESPBox:AddSlider("PlayerESPMaxDist", {
	Text     = "Max Distance",
	Default  = state.cfg.p_esp_maxDist,
	Min=50, Max=1000, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.p_esp_maxDist = v end,
})

--UI SETTINGS TAB

pcall(function() ThemeManager:SetLibrary(Library) end)
pcall(function() SaveManager:SetLibrary(Library) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({"MenuKeybind"}) end)
pcall(function() ThemeManager:SetFolder("vdHub") end)
pcall(function() SaveManager:SetFolder("vdHub/settings") end)
pcall(function() SaveManager:BuildConfigSection(Tabs["UI Settings"]) end)
pcall(function() ThemeManager:ApplyToTab(Tabs["UI Settings"]) end)

local UnloadBox = Tabs["UI Settings"]:AddLeftGroupbox("Unload")
UnloadBox:AddButton({
	Text       = "Unload Script",
	Func       = function() Library:Unload() end,
	DoubleClick = false,
	Tooltip    = "Stops all loops and destroys the UI.",
})

--UNLOAD

Library:OnUnload(function()
	state.running   = false
	moonwalkEnabled = false

	pcall(function()
		if parryAdornment and parryAdornment.Parent then
			parryAdornment.Visible = false
			parryAdornment.Adornee = nil
			parryAdornment:Destroy()
		end
	end)
	pcall(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj.Name == "VDHub_ParryHollowRing" then obj:Destroy() end
		end
	end)

	pcall(function() espGui:Destroy() end)

	for char, conns in pairs(killerAnimConns) do
		for _,c in ipairs(conns) do pcall(c.Disconnect, c) end
	end

	for char in pairs(killer2DEspElements) do removeKiller2DESP(char) end
	for char in pairs(player2DEspElements) do removePlayer2DESP(char) end


	playerParryState       = {}
	monitoredPlayerAnimators = {}
	_G.vdHub = nil
	print("[vdHub v3.4] Unloaded!")
end)
