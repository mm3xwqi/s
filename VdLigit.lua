local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer
if not lp then
	repeat task.wait(0.5) until Players.LocalPlayer
	lp = Players.LocalPlayer
end

local cam = Workspace.CurrentCamera

local state = {
	running = true,
	cfg = {
		spear_enabled        = false,
		spear_key            = Enum.KeyCode.E,
		spear_isHolding      = false,


        spear_targetPart = "Head",
        silentAim_enabled = false,
        silentAim_fov = 150,
        silentAim_showFOV = false,
        silentAim_killerMode = "The Veil",

        silentAim_survivor_enabled = false,
        silentAim_survivor_target = "Killer",

		p_enabled         = false,
		interactionRadius = 8,
		stunReach         = 7,
		cooldown          = 0.15,
		hz                = 240,
		p_dropKey         = 32,
		antiBait          = true,

		sc_enabled  = false,
		sc_lead     = 2,
		sc_offset   = 102,
		sc_key      = 32,
        sc_speed_enabled = false,
        sc_speed_value   = 0.001,

		fv_enabled    = false,
		fv_radius     = 6,
		fv_minSpeed   = 15.5,
		fv_deadband   = 38,
		fv_target     = 36,
		fv_ignoreAxis = false,
        fv_vaultSpeed_enabled = false,
        fv_vaultSpeed_value   = 1.5,

		ap_enabled        = false,
		ap_cooldown       = 0.05,
		ap_showCircle     = true,
		ap_circleColor    = Color3.fromRGB(0, 255, 200),
		ap_animRadius     = 10,
		ap_animPreDelay   = 0,
		ap_pendingRadius  = 25,
		ap_hitboxRadius   = 16,
		ap_hitboxPreDelay = 0.0,

		ap_legitMode        = false,
		ap_legitMinDelay    = 0.01,
		ap_legitMaxDelay    = 0.10,

		esp_enabled       = false,
		esp_showName      = true,
		esp_showDist      = true,
		esp_showHighlight = true,
		esp_showBox       = true,
		esp_maxDist       = 500,

		scp_esp_enabled      = false,
		scp_esp_showHighlight = true,
		scp_esp_showBox      = true,
		scp_esp_showName     = true,
		scp_esp_showDist     = true,
		scp_esp_maxDist      = 500,

		p_esp_enabled       = false,
		p_esp_showName      = true,
		p_esp_showDist      = true,
		p_esp_showHighlight = true,
		p_esp_showBox       = true,
		p_esp_showStatus    = true,
		p_esp_maxDist       = 500,

		antiStun_enabled    = false,
		noFlashBlind        = false,
		breakSpeed_enabled  = false,
		breakSpeed_value    = 1,
		selectMask          = "Alex",
        swiftspeed_enabled = false,
		autoCrouch_enabled  = false,
		autoCrouch_delay    = 0,
		autoCrouch_humanize = false,
		autoCrouch_distance = 18,
		autoCrouch_duration = 1.5,
	}
}
_G.KKKkhub = state

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
	[118907603246885] = true,
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
local PARRY_COOLDOWN = state.cfg.ap_cooldown

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

local lastDrop, droppedPallets = {}, {}

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

local killerTeamKeywords = { "Killer", "killer" }
local spectatorKeywords  = { "Spectator", "Spectator" }

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

local function shouldTrackSpear()
	return not isSurvivor() and not isSpectator()
end

local function getSpearTarget()
	local me = myRoot()
	if not me then return nil, nil, nil end
	local cam = workspace.CurrentCamera
	if not cam then return nil, nil, nil end
	local mousePos = UserInputService:GetMouseLocation()
	local best, bestChar, minDist = nil, nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp and plr.Character then
			local char = plr.Character
			local root = char:FindFirstChild("HumanoidRootPart")
			local hum  = char:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				if not isKillerPlayer(plr) and not isSpectator() then
					local screenPos, onScreen = cam:WorldToViewportPoint(root.Position)
					if onScreen and screenPos.Z > 0 then
						local dx = screenPos.X - mousePos.X
						local dy = screenPos.Y - mousePos.Y
						local screenDist = math.sqrt(dx*dx + dy*dy)
						if screenDist < minDist then
							minDist  = screenDist
							best     = root
							bestChar = char
						end
					end
				end
			end
		end
	end
	return best, "survivor", bestChar
end

local function getSelectedTargetPart()
    local bestRoot, targetType, bestChar = getSpearTarget()
    if not bestChar then return nil end
    local targetPartName = state.cfg.spear_targetPart or "Head"
    local targetPart = bestChar:FindFirstChild(targetPartName) or bestChar:FindFirstChild("HumanoidRootPart") or bestChar:FindFirstChild("Head")
    return targetPart
end

local function getClosestToMouseAny(overrideFov)
    local mousePos = UserInputService:GetMouseLocation()
    local closestPart = nil
    local shortestDistance = math.huge
    local targetPartName = state.cfg.spear_targetPart or "Head"
    local fov = overrideFov or state.cfg.silentAim_fov or 150
    local wantKiller = state.cfg.silentAim_survivor_target == "Killer"

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and not isSpectator() then
            local ok = wantKiller and isKillerPlayer(player) or (not wantKiller and not isKillerPlayer(player))
            if ok then
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local targetPart = char:FindFirstChild(targetPartName)
                        or char:FindFirstChild("HumanoidRootPart")
                        or char:FindFirstChild("Head")
                    if hum and hum.Health > 0 and targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen and screenPos.Z > 0 then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if distance < shortestDistance and distance <= fov then
                                shortestDistance = distance
                                closestPart = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPart
end

local function getClosestPlayerToMouse(overrideFov)
    local mousePos = UserInputService:GetMouseLocation()
    local closestPart = nil
    local shortestDistance = math.huge
    local targetPartName = state.cfg.spear_targetPart or "Head"
    local fov = overrideFov or state.cfg.silentAim_fov or 150

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and not isSpectator() then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local targetPart = char:FindFirstChild(targetPartName)
                    or char:FindFirstChild("HumanoidRootPart")
                    or char:FindFirstChild("Head")

                if hum and hum.Health > 0 and targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                    if onScreen and screenPos.Z > 0 then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                        if distance < shortestDistance and distance <= fov then
                            shortestDistance = distance
                            closestPart = targetPart
                        end
                    end
                end
            end
        end
    end

    return closestPart
end

local pallets = {}
local killerRoots = {}
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

local vaults = {}
local fvStat = { near = false, holding = false, nearD = nil, vaults = 0, ang = nil }
local fvHold = false

local function refreshVaults()
	local vaultPts = {}
	for _, d in ipairs(Workspace:GetDescendants()) do
		local ok, nm = pcall(function() return string.lower(d.Name) end)
		if not ok then continue end
		if (nm == "vaulttrigger" or nm == "vaultpoint" or nm == "palletpointslide") and d:IsA("BasePart") then
			local cf = d.CFrame
			if cf then
				local lv = cf.LookVector
				local fx, fz = lv.X, lv.Z
				local mag = math.sqrt((fx * fx) + (fz * fz))
				if mag > 0.0001 then
					local pp = cf.Position
					vaultPts[#vaultPts + 1] = { pp.X, pp.Y, pp.Z, fx / mag, fz / mag }
				end
			end
		end
	end
	vaults = vaultPts
end

task.spawn(function()
	while state.running do
		if state.cfg.sc_speed_enabled and isSurvivor() then
			pcall(function()
				local charModel = workspace:FindFirstChild(lp.Name)
				if charModel then
					charModel:SetAttribute("skillcheckspeed", state.cfg.sc_speed_value)
				end
			end)
		end
		task.wait(0.2)
	end
end)

task.spawn(function()
	while state.running do
		if state.cfg.swiftspeed_enabled and not isSurvivor() then
			pcall(function()
				local charModel = workspace:FindFirstChild(lp.Name)
				if charModel then
					charModel:SetAttribute("swift", state.cfg.swiftspeed_value)
				end
			end)
		end
		task.wait(0.2)
	end
end)

local function fvAngle(tfx, tfz, lx, lz)
	local d = math.clamp((tfx * lx) + (tfz * lz), -1, 1)
	local a = math.deg(math.acos(d))
	if a > 90 then a = 180 - a end
	return a
end

local function fvNearest(mx, my, mz, lx, lz, r2)
	local best, bd
	for i = 1, #vaults do
		local v = vaults[i]
		local dx, dy, dz = mx - v[1], my - v[2], mz - v[3]
		local d2 = (dx * dx) + (dy * dy) + (dz * dz)
		if (not bd or (d2 < bd)) and (d2 <= r2) then
			bd, best = d2, v
		end
	end
	if not best then return nil end
	return best, math.sqrt(bd), fvAngle(best[4], best[5], lx, lz)
end

local function fvRotateCharacter(root, dirX, dirZ)
	if not root then return end
	pcall(function()
		local pos = root.Position
		local targetLook = pos + Vector3.new(dirX, 0, dirZ)
		root.CFrame = CFrame.new(pos, targetLook)
	end)
end

pcall(refreshVaults)
task.spawn(function()
	while state.running do
		pcall(refreshVaults)
		task.wait(1.5)
	end
end)

task.spawn(function()
	while state.running do
		if state.cfg.fv_vaultSpeed_enabled and isSurvivor() then
			pcall(function()
				local charModel = workspace:FindFirstChild(lp.Name)
				if charModel then
					charModel:SetAttribute("vaultspeed", state.cfg.fv_vaultSpeed_value)
					if charModel:GetAttribute("isvaulting") == true then
						charModel:SetAttribute("isvaulting", false)
					end
					if charModel:GetAttribute("overridelookscript") == true then
						charModel:SetAttribute("overridelookscript", false)
					end
				end
			end)
		end
		task.wait(0.2)
	end
end)

task.spawn(function()
	while state.running do
		local c = state.cfg
		if c.fv_enabled and isSurvivor() then
			local root = myRoot()
			if root and (#vaults > 0) then
				local cf = root.CFrame
				local p = cf and cf.Position
				if p then
					local lx, lz
					pcall(function()
						local clv = cam.CFrame.LookVector
						lx, lz = clv.X, clv.Z
					end)
					if not lx then
						local lv = cf.LookVector
						lx, lz = lv.X, lv.Z
					end
					local lm = math.sqrt((lx * lx) + (lz * lz))
					if lm > 0.0001 then
						lx, lz = lx / lm, lz / lm
					end
					local trig, dist, ang = fvNearest(p.X, p.Y, p.Z, lx, lz, c.fv_radius * c.fv_radius)
					fvStat.near = trig ~= nil
					fvStat.nearD = dist
					fvStat.ang = ang
					local spd = 0
					pcall(function()
						local v = root.Velocity
						spd = math.sqrt((v.X * v.X) + (v.Z * v.Z))
					end)
					fvStat.spd = spd
					local gate = (trig ~= nil) and (spd > c.fv_minSpeed)
					local angOK = c.fv_ignoreAxis or (ang and (ang > c.fv_deadband))
					if gate and not fvHold and angOK then
						fvHold = true
						fvStat.vaults = fvStat.vaults + 1
					elseif not gate then
						fvHold = false
					end
					if fvHold and trig then
						fvRotateCharacter(root, trig[4], trig[5])
						fvStat.holding = true
					else
						fvStat.holding = false
					end
				end
			else
				fvStat.near, fvStat.holding, fvStat.nearD, fvStat.ang = false, false, nil, nil
				fvHold = false
			end
		else
			fvStat.near, fvStat.holding = false, false
			fvHold = false
		end
		task.wait(1 / 240)
	end
end)

local function checkKillerApproach(kRoot, palPos, maxReach)
	local ok, kPos = pcall(function() return kRoot.Position end)
	if not ok or not kPos then return false, false end
	local dx,dy,dz = palPos.X-kPos.X, palPos.Y-kPos.Y, palPos.Z-kPos.Z
	local dist = math.sqrt(dx*dx+dy*dy+dz*dz)
	if dist > maxReach then return false, false end
	if state.cfg.antiBait then
		local dirX = dx / (dist > 0.001 and dist or 1)
		local dirZ = dz / (dist > 0.001 and dist or 1)
		local ok2, kVel = pcall(function() return kRoot.AssemblyLinearVelocity or kRoot.Velocity end)
		if not ok2 or not kVel then return true, true end
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
						local ok2, palPos = pcall(function() return pal.board.Position end)
						if ok2 and palPos then
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
		end
		pStat.elig = elig; pStat.inZone = zone; pStat.baiting = isBaiting
		local nd = nearD and math.sqrt(nearD) or nil
		pStat.nearD = (nd and nd <= 200) and nd or nil
		task.wait(1 / (c.hz or 240))
	end
end)

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
					scLast.win = string.format("%.0f\xc2\xb0..%.0f\xc2\xb0", lo, lo+14)
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

local ignoredKW = {
	"break","pallet","kick","destroy","gen","generator","vault","window",
	"pickup","carry","hook","drop","search","stun","blind","cabinet",
	"locker","open","close","repair","interact","idle","walk","run","stomp",
	"emote","taunt","dance","laugh","point","wave","Stunned","Hookked","Hooked",
    "hookked","hooked"
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

local function parry(reason, extraDelay)
	if not state.cfg.ap_enabled then return end
	if not isSurvivor() then return end
	local now = tick()
	if (now - lastParryTime) < (state.cfg.ap_cooldown or PARRY_COOLDOWN) then return end
	lastParryTime = now
	task.spawn(function()
		local delay = extraDelay or 0
		if state.cfg.ap_legitMode then
			local mn = state.cfg.ap_legitMinDelay or 0.05
			local mx = state.cfg.ap_legitMaxDelay or 0.15
			delay = delay + mn + math.random() * (mx - mn)
		end
		if delay > 0 then task.wait(delay) end
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
					char.AncestryChanged:Connect(function()
						if not char.Parent then
							hitboxMonitored[char] = nil
						end
					end)
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

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(newChar)
        for char in pairs(player2DEspElements) do
            if char ~= newChar then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p == plr and p.Character ~= char then
                        removePlayer2DESP(char)
                    end
                end
            end
        end
    end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    plr.CharacterAdded:Connect(function(newChar)
        task.wait(0.1)
        for char in pairs(player2DEspElements) do
            local found = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character == char then found = true; break end
            end
            if not found then removePlayer2DESP(char) end
        end
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

local espGui = Instance.new("ScreenGui")
espGui.Name           = "KKKkhub_2DESP_ScreenGui"
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
	local topY    = head and (head.Position.Y + 1.5) or (root.Position.Y + 3.8)
	local bottomY = root.Position.Y - 3.8
	local rootPos    = root.Position
	local topWorld    = Vector3.new(rootPos.X, topY, rootPos.Z)
	local bottomWorld = Vector3.new(rootPos.X, bottomY, rootPos.Z)
	local topScreen, topOn       = cam:WorldToViewportPoint(topWorld)
	local bottomScreen, bottomOn = cam:WorldToViewportPoint(bottomWorld)
	if not (topOn and bottomOn) or topScreen.Z < 0 then return nil end
	local height = math.abs(bottomScreen.Y - topScreen.Y)
	if height < 10 then height = 10 end
	local width = math.clamp(height * 0.55, 14, 500)
	local x = topScreen.X - (width / 2)
	local y = topScreen.Y
	local realDist = (cam.CFrame.Position - rootPos).Magnitude
	return x, y, width, height, realDist
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
	highlight.Name                = "KKKkhub_Killer_Highlight"
	highlight.FillColor           = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor        = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency    = 1
	highlight.OutlineTransparency = 0
	highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee             = char
	highlight.Parent              = char
	local container = Instance.new("Frame")
	container.Name                   = "Killer2DContainer"
	container.BackgroundTransparency = 1
	container.Size                   = UDim2.new(1, 0, 1, 0)
	container.Parent                 = espGui
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size                   = UDim2.new(0, 160, 0, 16)
	nameLabel.TextColor3             = Color3.fromRGB(255, 80, 80)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font                   = Enum.Font.GothamBold
	nameLabel.TextSize               = 13
	nameLabel.TextXAlignment         = Enum.TextXAlignment.Center
	nameLabel.Text                   = char.Name
	nameLabel.Parent                 = container
	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Size                   = UDim2.new(0, 160, 0, 14)
	distLabel.TextColor3             = Color3.fromRGB(255, 200, 0)
	distLabel.TextStrokeTransparency = 0
	distLabel.Font                   = Enum.Font.GothamBold
	distLabel.TextSize               = 11
	distLabel.TextXAlignment         = Enum.TextXAlignment.Center
	distLabel.Text                   = ""
	distLabel.Parent                 = container
	killer2DEspElements[char] = {
		container = container,
		highlight = highlight,
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
	highlight.Name                = "KKKkhub_Player_Highlight"
	highlight.FillColor           = Color3.fromRGB(0, 150, 255)
	highlight.OutlineColor        = Color3.fromRGB(0, 200, 255)
	highlight.FillTransparency    = 1
	highlight.OutlineTransparency = 0
	highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee             = char
	highlight.Parent              = char
	local container = Instance.new("Frame")
	container.Name                   = "Player2DContainer"
	container.BackgroundTransparency = 1
	container.Size                   = UDim2.new(1, 0, 1, 0)
	container.Parent                 = espGui
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size                   = UDim2.new(0, 160, 0, 16)
	nameLabel.TextColor3             = Color3.fromRGB(100, 200, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font                   = Enum.Font.GothamBold
	nameLabel.TextSize               = 13
	nameLabel.TextXAlignment         = Enum.TextXAlignment.Center
	nameLabel.Text                   = char.Name
	nameLabel.Parent                 = container
	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Size                   = UDim2.new(0, 160, 0, 14)
	distLabel.TextColor3             = Color3.fromRGB(0, 200, 255)
	distLabel.TextStrokeTransparency = 0
	distLabel.Font                   = Enum.Font.GothamBold
	distLabel.TextSize               = 11
	distLabel.TextXAlignment         = Enum.TextXAlignment.Center
	distLabel.Text                   = ""
	distLabel.Parent                 = container
    local sideFrame = Instance.new("Frame")
    sideFrame.BackgroundTransparency = 1
    sideFrame.Size                   = UDim2.new(0, 150, 0, 96)
    sideFrame.Parent                 = container
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding   = UDim.new(0, 1)
	listLayout.Parent    = sideFrame
	local knockedLabel = Instance.new("TextLabel")
	knockedLabel.LayoutOrder            = 1
	knockedLabel.BackgroundTransparency = 1
	knockedLabel.Size                   = UDim2.new(1, 0, 0, 14)
	knockedLabel.Font                   = Enum.Font.GothamBold
	knockedLabel.TextSize               = 11
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
	hookCountLabel.TextSize               = 11
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
	hookedProgLabel.TextSize               = 11
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
	healProgLabel.TextSize               = 11
	healProgLabel.TextColor3             = Color3.fromRGB(255, 130, 220)
	healProgLabel.TextXAlignment         = Enum.TextXAlignment.Left
	healProgLabel.TextStrokeTransparency = 0
	healProgLabel.Text                   = "HealProg: 0.0"
	healProgLabel.Parent                 = sideFrame
	local parryDaggerLabel = Instance.new("TextLabel")
	parryDaggerLabel.LayoutOrder            = 5
	parryDaggerLabel.BackgroundTransparency = 1
	parryDaggerLabel.Size                   = UDim2.new(1, 0, 0, 14)
	parryDaggerLabel.Font                   = Enum.Font.GothamBold
	parryDaggerLabel.TextSize               = 11
	parryDaggerLabel.TextColor3             = Color3.fromRGB(255, 80, 255)
	parryDaggerLabel.TextXAlignment         = Enum.TextXAlignment.Left
	parryDaggerLabel.TextStrokeTransparency = 0
	parryDaggerLabel.Text                   = ""
	parryDaggerLabel.Parent                 = sideFrame
	local parryItemLabel = Instance.new("TextLabel")
	parryItemLabel.LayoutOrder            = 6
	parryItemLabel.BackgroundTransparency = 1
	parryItemLabel.Size                   = UDim2.new(1, 0, 0, 14)
	parryItemLabel.Font                   = Enum.Font.GothamBold
	parryItemLabel.TextSize               = 11
	parryItemLabel.TextColor3             = Color3.fromRGB(120, 220, 255)
	parryItemLabel.TextXAlignment         = Enum.TextXAlignment.Left
	parryItemLabel.TextStrokeTransparency = 0
	parryItemLabel.Text                   = ""
	parryItemLabel.Parent                 = sideFrame
	player2DEspElements[char] = {
		container        = container,
		highlight        = highlight,
		nameLabel        = nameLabel,
		distLabel        = distLabel,
		sideFrame        = sideFrame,
		knockedLabel     = knockedLabel,
		hookCountLabel   = hookCountLabel,
		hookedProgLabel  = hookedProgLabel,
		healProgLabel    = healProgLabel,
		parryDaggerLabel = parryDaggerLabel,
		parryItemLabel   = parryItemLabel,
	}
end

local _cachedPlayers = {}
local _playerCacheTime = 0

local _espTick = 0
local _espTick = 0
RunService.Heartbeat:Connect(function()
	if not state.running then return end
	local now = tick()
	if now - _espTick < 0.0167 then return end
	_espTick = now
	local c = state.cfg
	local spectating = isSpectator()
	if spectating then
		for char in pairs(killer2DEspElements) do removeKiller2DESP(char) end
		for char in pairs(player2DEspElements) do removePlayer2DESP(char) end
		return
	end
	local cam = workspace.CurrentCamera
	if not cam then return end

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
						local dynamicFont = math.clamp(math.floor(height * 0.22), 10, 14)
						elem.container.Visible = true
						elem.nameLabel.Visible  = c.esp_showName
						elem.nameLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y - (dynamicFont + 8))
						elem.nameLabel.TextSize = dynamicFont
						elem.distLabel.Visible  = c.esp_showDist
						elem.distLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y + height + 3)
						elem.distLabel.TextSize = math.max(9, dynamicFont - 1)
                        elem.distLabel.Text = string.format("[%d studs]", math.floor(dist or 0))
					else
						elem.container.Visible = false
					end
				end
			end
		end
	else
		for char in pairs(killer2DEspElements) do removeKiller2DESP(char) end
	end

	if c.p_esp_enabled then
		if (now - _playerCacheTime) > 1.0 then
			_cachedPlayers = Players:GetPlayers()
			_playerCacheTime = now
		end
		local showSt = c.p_esp_showStatus
        for char, _ in pairs(player2DEspElements) do
            for _, plr in ipairs(_cachedPlayers) do
                if plr.Character == char and isKillerPlayer(plr) then
                    removePlayer2DESP(char)
                    break
                end
            end
        end

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
						local hideIfFar = dist and dist > 500
						if elem.highlight then
							elem.highlight.Enabled = c.p_esp_showHighlight and inRange
						end
                        if x and inRange then
                            local dynamicFont = math.clamp(math.floor(height * 0.20), 10, 14)
                            local sidePadding = math.clamp(math.floor(width * 0.15), 5, 10)
                            elem.container.Visible  = true
                            elem.nameLabel.Visible  = c.p_esp_showName
                            elem.nameLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y - (dynamicFont + 8))
                            elem.nameLabel.TextSize = dynamicFont
                            elem.distLabel.Visible  = c.p_esp_showDist
                            elem.distLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y + height + 3)
                            elem.distLabel.TextSize = math.max(9, dynamicFont - 1)
                            elem.distLabel.Text     = string.format("[%.0fm]", dist * 0.28)
                                elem.sideFrame.Visible  = showSt and not hideIfFar
                                elem.sideFrame.Size     = UDim2.new(0, 150, 0, 96)
                                local rootScreenPos = cam:WorldToViewportPoint(root.Position)
                                elem.sideFrame.Position = UDim2.new(0, rootScreenPos.X + 30, 0, rootScreenPos.Y - 48)
							if showSt and not hideIfFar then
                            local panelFont = math.clamp(math.floor(11 * math.clamp(80 / (dist or 1), 0.6, 1.0)), 7, 11)
                            elem.knockedLabel.TextSize     = panelFont
                            elem.hookCountLabel.TextSize   = panelFont
                            elem.hookedProgLabel.TextSize  = panelFont
                            elem.healProgLabel.TextSize    = panelFont
                            elem.parryDaggerLabel.TextSize = panelFont
                            elem.parryItemLabel.TextSize   = panelFont
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
								elem.hookedProgLabel.Text = string.format("HookProg: %.0f", tonumber(hookedProg) or 0)
								elem.healProgLabel.Text   = string.format("HealProg: %.0f", tonumber(healProg) or 0)
								local itemNames = {}
								for _, obj in ipairs(char:GetChildren()) do
									if obj:IsA("Model") then
										itemNames[#itemNames + 1] = obj.Name
									end
								end
								elem.parryDaggerLabel.Text = #itemNames > 0 and table.concat(itemNames, ", ") or ""
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
				if plr.Character == char and not isKillerPlayer(plr) then
					alive = true; break
				end
			end
			if not alive then removePlayer2DESP(char) end
		end
		task.wait(1.0)
	end
end)

local parryAdornment = Instance.new("CylinderHandleAdornment")
parryAdornment.Name         = "KKKK_Hub_ParryHollowRing"
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

local SPEAR_SPEED_READY = 165
local SPEAR_SPEED_CD    = 145
local SPEAR_GRAV_READY = 98.1
local SPEAR_GRAV_CD    = 100.0
local AIM_HEIGHT_OFFSET = -0.5
local function calculateSpearAim(origin, targetPos, targetVel, overrideSpeed)
    if typeof(overrideSpeed) ~= "number" then
        overrideSpeed = nil
    end
    local cdReady = (type(getSkillCooldownState) == "function" and getSkillCooldownState()) or false
    local speed = overrideSpeed or (cdReady and SPEAR_SPEED_READY or SPEAR_SPEED_CD)
    local g = cdReady and SPEAR_GRAV_READY or SPEAR_GRAV_CD
    local adjustedTargetPos = targetPos + Vector3.new(0, AIM_HEIGHT_OFFSET, 0)
    local diff = adjustedTargetPos - origin
    local dist = diff.Magnitude
    if dist < 0.1 then return adjustedTargetPos end
    local t = dist / math.max(speed, 1)
    for _ = 1, 3 do
        local dropEst = 0.5 * g * (t * t)
        local aimPos = Vector3.new(adjustedTargetPos.X, adjustedTargetPos.Y + dropEst, adjustedTargetPos.Z)
        t = (aimPos - origin).Magnitude / math.max(speed, 1)
    end
    local drop = 0.5 * g * (t * t)
    return Vector3.new(
        adjustedTargetPos.X,
        adjustedTargetPos.Y + drop,
        adjustedTargetPos.Z
    )
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
    local target, targetType, targetChar = getSpearTarget()
    if not target then return end
    local camCF = workspace.CurrentCamera.CFrame
    local aimPos
    if targetType == "spear" then
        aimPos = target.Position
    else
        local targetVel = target.AssemblyLinearVelocity or target.Velocity
        aimPos = calculateSpearAim(camCF.Position, target.Position, targetVel)
    end
    if not aimPos then return end
    workspace.CurrentCamera.CFrame = CFrame.lookAt(camCF.Position, aimPos)
end)

state.cfg.spear_esp_enabled = false
state.cfg.spear_esp_maxDist = 300

local spearEspGui = Instance.new("ScreenGui")
spearEspGui.Name           = "KKKkhub_SpearESP"
spearEspGui.ResetOnSpawn   = false
spearEspGui.DisplayOrder   = 1000
spearEspGui.IgnoreGuiInset = true
spearEspGui.Parent         = game:GetService("CoreGui")

local spearESPs = {}
local SPEAR_COLOR = Color3.fromRGB(255, 80, 0)

local function addSpearESP(model)
	if spearESPs[model] then return end
	local root = model.PrimaryPart or model:FindFirstChildOfClass("MeshPart") or model:FindFirstChildOfClass("BasePart")
	if not root then return end
	local bb = Instance.new("BillboardGui")
	bb.AlwaysOnTop = true
	bb.Size        = UDim2.new(0, 6, 0, 6)
	bb.Adornee     = root
	bb.Parent      = spearEspGui
	local dot = Instance.new("Frame")
	dot.Size             = UDim2.new(1, 0, 1, 0)
	dot.BackgroundColor3 = SPEAR_COLOR
	dot.BorderSizePixel  = 0
	dot.Parent           = bb
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	local lbl = Instance.new("TextLabel")
	lbl.Name                   = "Dist"
	lbl.BackgroundTransparency = 1
	lbl.Size                   = UDim2.new(0, 60, 0, 14)
	lbl.Position               = UDim2.new(0.5, -30, 1, 2)
	lbl.TextColor3             = SPEAR_COLOR
	lbl.TextStrokeTransparency = 0
	lbl.Font                   = Enum.Font.GothamBold
	lbl.TextSize               = 10
	lbl.Text                   = ""
	lbl.Parent                 = bb
	local hl = Instance.new("Highlight")
	hl.FillColor           = SPEAR_COLOR
	hl.OutlineColor        = SPEAR_COLOR
	hl.FillTransparency    = 0.5
	hl.OutlineTransparency = 0
	hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee             = model
	hl.Parent              = model
	spearESPs[model] = { bb = bb, hl = hl, lbl = lbl, root = root }
end

local function removeSpearESP(part)
	local e = spearESPs[part]
	if not e then return end
	pcall(function() e.bb:Destroy() end)
	pcall(function() e.hl:Destroy() end)
	spearESPs[part] = nil
end

task.spawn(function()
	while state.running do
		if not state.cfg.spear_esp_enabled or not shouldTrackSpear() then
			for model in pairs(spearESPs) do removeSpearESP(model) end
		end
		task.wait(0.5)
	end
end)

Workspace.DescendantAdded:Connect(function(obj)
	if not state.cfg.spear_esp_enabled then return end
	if not shouldTrackSpear() then return end
	if obj:IsA("Model") and string.lower(obj.Name) == "spearprojectile" then
		addSpearESP(obj)
	end
end)

local _spearTick = 0
RunService.Heartbeat:Connect(function()
	if not state.running or not state.cfg.spear_esp_enabled then return end
	if not shouldTrackSpear() then return end
	local now = tick()
	if now - _spearTick < 0.1 then return end
	_spearTick = now
	local me    = myRoot()
	local myPos = me and me.Position
	for model, e in pairs(spearESPs) do
		if not model.Parent then
			removeSpearESP(model)
			continue
		end
		if myPos then
			local ok, d = pcall(function() return (myPos - e.root.Position).Magnitude end)
			if ok and d <= state.cfg.spear_esp_maxDist then
				e.lbl.Text   = string.format("%.0f", d)
				e.bb.Enabled = true
			else
				e.bb.Enabled = false
			end
		end
	end
end)

local moonwalkEnabled = false
local moonwalkKey     = Enum.KeyCode.G
local moonwalkSway    = 0

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == moonwalkKey then
		moonwalkEnabled = not moonwalkEnabled
		moonwalkSway    = 0
		print("[KKKkhub] Moonwalk: " .. (moonwalkEnabled and "ON" or "OFF"))
	end
end)

RunService.Heartbeat:Connect(function(dt)
	if not state.running then return end
	if not moonwalkEnabled then return end
	local ch = lp.Character
	if not ch then return end
	local root = ch:FindFirstChild("HumanoidRootPart")
	local hum  = ch:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local moveDir = hum.MoveDirection
	if moveDir.Magnitude < 0.1 then
		moonwalkSway = 0
		return
	end
	moonwalkSway = moonwalkSway + dt * 18
	local swayAngle = math.sin(moonwalkSway) * 20
	local tiltAngle = -4
	local pos     = root.Position
	local backDir = Vector3.new(-moveDir.X, 0, -moveDir.Z).Unit
	root.CFrame = CFrame.new(pos, pos + backDir)
		* CFrame.Angles(math.rad(tiltAngle), math.rad(swayAngle), 0)
end)

local antiStunActive  = state.cfg.antiStun_enabled
local antiStunConns   = {}

local function attachAntiStunToChar(char)
	if not char then return end
	local function tryAttach()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		local animator = hum:FindFirstChildOfClass("Animator")
		if not animator then
			char.DescendantAdded:Connect(function(obj)
				if obj:IsA("Animator") then
					task.wait(0.05)
					tryAttach()
				end
			end)
			return
		end
		local conn = animator.AnimationPlayed:Connect(function(track)
			if not antiStunActive then return end
			local name = string.lower(track.Name or "")
			if name:find("stun") then
				track:AdjustSpeed(8)
				task.defer(function()
					pcall(function() track:Stop(0) end)
				end)
			end
		end)
		antiStunConns[#antiStunConns + 1] = conn
	end
	tryAttach()
end

if lp.Character then pcall(attachAntiStunToChar, lp.Character) end
lp.CharacterAdded:Connect(function(ch)
	for _, c in ipairs(antiStunConns) do pcall(c.Disconnect, c) end
	antiStunConns = {}
	task.wait(0.3)
	pcall(attachAntiStunToChar, ch)
end)

task.spawn(function()
	while state.running do
		task.wait(0.2)
		pcall(function()
			local c = state.cfg
			if c.breakSpeed_enabled then
				local charModel = workspace:FindFirstChild(lp.Name)
				if charModel then
					if charModel:GetAttribute("breakspeed") ~= c.breakSpeed_value then
						charModel:SetAttribute("breakspeed", c.breakSpeed_value)
					end
				end
			end
		end)
	end
end)

local lastCrouchTime = 0
local autoCrouchAnimIds = { ["80411309607666"] = true }

local function getKillerChar()
	for _, plr in ipairs(Players:GetPlayers()) do
		if isKillerPlayer(plr) and plr.Character then
			return plr.Character
		end
	end
	return nil
end

RunService.Heartbeat:Connect(function()
	if not state.running then return end
	local c = state.cfg
	if not c.autoCrouch_enabled then return end
	if not isSurvivor() then return end
	local now = tick()
	local cooldown = (c.autoCrouch_duration or 1.5) + 2.5
	if now - lastCrouchTime < cooldown then return end
	local ch = lp.Character
	if not ch then return end
	local localRoot = ch:FindFirstChild("HumanoidRootPart")
	if not localRoot then return end
	local killerChar = getKillerChar()
	if not killerChar then return end
	local killerRoot = killerChar:FindFirstChild("HumanoidRootPart")
	if not killerRoot then return end
	local dist = (killerRoot.Position - localRoot.Position).Magnitude
	if dist > (c.autoCrouch_distance or 18) then return end
	local killerHum = killerChar:FindFirstChildOfClass("Humanoid")
	if not killerHum then return end
	local detected = false
	pcall(function()
		local animator = killerHum:FindFirstChildOfClass("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				local anim = track.Animation
				if anim then
					local id = anim.AnimationId or ""
					for animId in pairs(autoCrouchAnimIds) do
						if id:find(animId) then
							detected = true
							break
						end
					end
				end
				if detected then break end
			end
		end
	end)
	if detected then
		lastCrouchTime = now
		task.spawn(function()
			local delayVal = c.autoCrouch_delay or 0
			if c.autoCrouch_humanize then
				local offset = (math.random(-80, 80)) / 1000
				delayVal = math.max(0, delayVal + offset)
			end
			if delayVal > 0 then task.wait(delayVal) end
			pcall(function() keypress(0x11) end)
			pcall(function() keypress(0x43) end)
			pcall(function()
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
				VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
			end)
			local dur = math.clamp(c.autoCrouch_duration or 1.5, 0, 3)
			if dur > 0 then task.wait(dur) end
			pcall(function() keyrelease(0x11) end)
			pcall(function() keyrelease(0x43) end)
			pcall(function()
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
				VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
			end)
		end)
	end
end)

RunService.Heartbeat:Connect(function()
	if not state.running then return end
	if not state.cfg.noFlashBlind then return end
	pcall(function()
		local selectedKiller = lp:GetAttribute("SelectedKiller")
		if not selectedKiller then return end
		local pg = lp:FindFirstChild("PlayerGui")
		local killerGui = pg and pg:FindFirstChild(selectedKiller)
		if killerGui and killerGui:FindFirstChild("Blind") then
			killerGui.Blind.Visible = false
		end
	end)
end)

local scpEspElements = {}

local function removeSCPESP(model)
	local e = scpEspElements[model]
	if not e then return end
	pcall(function() e.highlight:Destroy() end)
	scpEspElements[model] = nil
end

local function createSCPESP(model)
	if scpEspElements[model] then return end
	local root = model.PrimaryPart
		or model:FindFirstChildOfClass("MeshPart")
		or model:FindFirstChildOfClass("BasePart")
	if not root then return end
	local hl = Instance.new("Highlight")
	hl.Name                = "KKKkhub_SCP_Highlight"
	hl.FillColor           = Color3.fromRGB(255, 60, 220)
	hl.OutlineColor        = Color3.fromRGB(255, 0, 200)
	hl.FillTransparency    = 1
	hl.OutlineTransparency = 0
	hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee             = model
	hl.Parent              = model
	scpEspElements[model] = {
		highlight = hl,
	}
end

local VALID_SCP_NAMES = {
    ["scp-1"] = true, ["scp-2"] = true, ["scp-3"] = true, ["scp-4"] = true,
    ["scp-5"] = true, ["scp-6"] = true, ["scp-7"] = true, ["scp-8"] = true,
}

local function isValidSCP(name)
    local lower = string.lower(name)
    local num = lower:match("^scp[%-%s]?(%d+)$")
    if num then
        local n = tonumber(num)
        return n and n >= 1 and n <= 8
    end
    return false
end

local function scanSCPs()
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isValidSCP(obj.Name) then
            found[obj] = true
            createSCPESP(obj)
        end
    end
    for model in pairs(scpEspElements) do
        if not found[model] then removeSCPESP(model) end
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if not state.cfg.scp_esp_enabled then return end
    if obj:IsA("Model") and isValidSCP(obj.Name) then
        task.wait(0.1)
        createSCPESP(obj)
    end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if scpEspElements[obj] then removeSCPESP(obj) end
end)


task.spawn(function()
	while state.running do
		if state.cfg.scp_esp_enabled then
			pcall(scanSCPs)
		else
			for model in pairs(scpEspElements) do removeSCPESP(model) end
		end
		task.wait(1.0)
	end
end)

local _scpTick = 0
RunService.Heartbeat:Connect(function()
	if not state.running or not state.cfg.scp_esp_enabled then return end
	local now = tick()
	if now - _scpTick < 0.1 then return end
	_scpTick = now
	for model, elem in pairs(scpEspElements) do
		if not model.Parent then removeSCPESP(model); continue end
		if elem.highlight then
			elem.highlight.Enabled = state.cfg.scp_esp_showHighlight
		end
	end
end)

local flashlightAimEnabled = false
local flashlightAimConn = nil

local function startFlashlightAim()
	if flashlightAimConn then return end
	flashlightAimConn = RunService.RenderStepped:Connect(function(dt)
		if not flashlightAimEnabled then return end
		if not isSurvivor() then return end
		local ch = lp.Character
		if not ch then return end
		local hasFlashlight = ch:FindFirstChild("Flashlight")
		if not hasFlashlight then return end
		if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
		local cam = workspace.CurrentCamera
		if not cam then return end
		local me = myRoot()
		if not me then return end
		local bestRoot = nil
		local bestDist = math.huge
		for _, kRoot in ipairs(killerRoots) do
			if kRoot and kRoot.Parent then
				local d = (me.Position - kRoot.Position).Magnitude
				if d < bestDist then
					bestDist = d
					bestRoot = kRoot
				end
			end
		end
		if not bestRoot then return end
		local killerChar = bestRoot.Parent
		local head = killerChar and killerChar:FindFirstChild("Head")
		local aimTarget = (head or bestRoot).Position
		local camCF = cam.CFrame
		local targetCF = CFrame.lookAt(camCF.Position, aimTarget)
		cam.CFrame = camCF:Lerp(targetCF, math.min(dt * 25, 1))
	end)
end

local function stopFlashlightAim()
	if flashlightAimConn then
		flashlightAimConn:Disconnect()
		flashlightAimConn = nil
	end
end

startFlashlightAim()

local autoDropCarriedEnabled = false

local function findNearestPalletPoint()
    local ch = lp.Character
    local me = ch and ch:FindFirstChild("HumanoidRootPart")
    if not me then return nil end
    local myPos = me.Position
    local closest = nil
    local closestDist = math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "PalletPoint" and obj:IsA("BasePart") then
            local d = (obj.Position - myPos).Magnitude
            if d < closestDist then
                closestDist = d
                closest = obj
            end
        end
    end
    return closest, closestDist
end

task.spawn(function()
    local lastDropTime = 0
    while state.running do
        if autoDropCarriedEnabled and isSurvivor() then
            pcall(function()
                local ch = lp.Character
                if not ch then return end
                local isCarried = ch:GetAttribute("IsCarried")
                if not isCarried then return end
                local me = ch:FindFirstChild("HumanoidRootPart")
                if not me then return end
                local killerRoot = nil
                local killerDist = math.huge
                for _, kRoot in ipairs(killerRoots) do
                    if kRoot and kRoot.Parent then
                        local d = (me.Position - kRoot.Position).Magnitude
                        if d < killerDist then
                            killerDist = d
                            killerRoot = kRoot
                        end
                    end
                end
                if not killerRoot then return end
                local closestPoint = nil
                local closestDist = math.huge
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "PalletPoint" and obj:IsA("BasePart") then
                        local dToKiller = (obj.Position - killerRoot.Position).Magnitude
                        if dToKiller < closestDist then
                            closestDist = dToKiller
                            closestPoint = obj
                        end
                    end
                end
                if not closestPoint then return end
                local now = tick()
                if closestDist <= 6 and (now - lastDropTime) >= 1.0 then
                    game:GetService("ReplicatedStorage").Remotes.Pallet.PalletDropEvent:FireServer(closestPoint)
                    lastDropTime = now
                end
            end)
        end
        task.wait(0.1)
    end
end)

-- FULL BRIGHT & NO FOG
local fullbrightEnabled = false
local nofogEnabled = false
local originalLighting = {}
local fullbrightConn = nil

local Lighting = game:GetService("Lighting")

local function saveOriginalLighting()
    originalLighting.Brightness      = Lighting.Brightness
    originalLighting.ClockTime       = Lighting.ClockTime
    originalLighting.FogEnd          = Lighting.FogEnd
    originalLighting.FogStart        = Lighting.FogStart
    originalLighting.GlobalShadows   = Lighting.GlobalShadows
    originalLighting.Ambient         = Lighting.Ambient
    originalLighting.OutdoorAmbient  = Lighting.OutdoorAmbient
end

saveOriginalLighting()

local function applyFullBright()
    Lighting.Brightness     = 2
    Lighting.ClockTime      = 14
    Lighting.GlobalShadows  = false
    Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
end

local function restoreFullBright()
    Lighting.Brightness     = originalLighting.Brightness
    Lighting.ClockTime      = originalLighting.ClockTime
    Lighting.GlobalShadows  = originalLighting.GlobalShadows
    Lighting.Ambient        = originalLighting.Ambient
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
end

local function applyNoFog()
    Lighting.FogEnd   = 100000
    Lighting.FogStart = 100000
end

local function restoreNoFog()
    Lighting.FogEnd   = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
end

task.spawn(function()
    while state.running do
        pcall(function()
            if fullbrightEnabled then applyFullBright() end
            if nofogEnabled then applyNoFog() end
        end)
        task.wait(0.5)
    end
end)

local genEspEnabled = false
local genEspElements = {}
local genProgressTracker = {} 

local function removeGenESP(model)
    local e = genEspElements[model]
    if not e then return end
    pcall(function() e.highlight:Destroy() end)
    pcall(function() e.billboard:Destroy() end)
    genEspElements[model] = nil
    genProgressTracker[model] = nil
end

local function createGenESP(model, index)
    if genEspElements[model] then return end
    local root = model.PrimaryPart
        or model:FindFirstChildOfClass("MeshPart")
        or model:FindFirstChildOfClass("BasePart")
    if not root then return end

    local hl = Instance.new("Highlight")
    hl.FillColor           = Color3.fromRGB(255, 200, 0)
    hl.OutlineColor        = Color3.fromRGB(255, 150, 0)
    hl.FillTransparency    = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee             = model
    hl.Parent              = model

    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop  = true
    bb.Size         = UDim2.new(0, 160, 0, 50)
    bb.StudsOffset  = Vector3.new(0, 4, 0)
    bb.Adornee      = root
    bb.Parent       = game:GetService("CoreGui")

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size                   = UDim2.new(1, 0, 0.5, 0)
    nameLabel.TextColor3             = Color3.fromRGB(255, 200, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font                   = Enum.Font.GothamBold
    nameLabel.TextSize               = 14
    nameLabel.Text                   = "Gen " .. index
    nameLabel.TextXAlignment         = Enum.TextXAlignment.Center
    nameLabel.TextYAlignment         = Enum.TextYAlignment.Center
    nameLabel.Parent                 = bb

    local infoLabel = Instance.new("TextLabel")
    infoLabel.BackgroundTransparency = 1
    infoLabel.Size                   = UDim2.new(1, 0, 0.5, 0)
    infoLabel.Position               = UDim2.new(0, 0, 0.5, 0)
    infoLabel.TextColor3             = Color3.fromRGB(255, 255, 100)
    infoLabel.TextStrokeTransparency = 0
    infoLabel.Font                   = Enum.Font.GothamBold
    infoLabel.TextSize               = 12
    infoLabel.Text                   = "0% | idle"
    infoLabel.TextXAlignment         = Enum.TextXAlignment.Center
    infoLabel.TextYAlignment         = Enum.TextYAlignment.Center
    infoLabel.Parent                 = bb

    genEspElements[model] = {
        highlight  = hl,
        billboard  = bb,
        nameLabel  = nameLabel,
        infoLabel  = infoLabel,
        rootPart   = root,
        index      = index,
    }
end

local genModels = {}

local function onDescendantAdded(obj)
    if not genEspEnabled then return end
    if obj:IsA("Model") and obj.Name == "Generator" then
        task.wait(0.1)
        if not genEspElements[obj] then
            createGenESP(obj, 0)
        end
    end
end

local function onDescendantRemoving(obj)
    if genEspElements[obj] then
        removeGenESP(obj)
    end
end

Workspace.DescendantAdded:Connect(onDescendantAdded)
Workspace.DescendantRemoving:Connect(onDescendantRemoving)

local function initialScanGen()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            createGenESP(obj, 0)
        end
    end
end

task.spawn(function()
    while state.running do
        if genEspEnabled then
            pcall(scanGenerators)
            pcall(function()
                for model, elem in pairs(genEspElements) do
                    if not model.Parent then
                        removeGenESP(model)
                        continue
                    end
                    local repair    = model:GetAttribute("RepairProgress") or 0
                    local repairing = model:GetAttribute("PlayersRepairingCount") or 0
                    local paused    = model:GetAttribute("ProgressPaused")

                    local pct = math.clamp(repair, 0, 100)
                    local displayPct = math.floor(pct)

                    if pct >= 100 then
                        elem.highlight.FillColor    = Color3.fromRGB(0, 255, 100)
                        elem.highlight.OutlineColor = Color3.fromRGB(0, 200, 80)
                        elem.nameLabel.TextColor3   = Color3.fromRGB(0, 255, 100)
                        elem.infoLabel.Text         = "DONE ✓"
                    elseif paused then
                        elem.highlight.FillColor    = Color3.fromRGB(255, 100, 0)
                        elem.highlight.OutlineColor = Color3.fromRGB(255, 80, 0)
                        elem.nameLabel.TextColor3   = Color3.fromRGB(255, 150, 0)
                        elem.infoLabel.Text         = displayPct .. "% | paused"
                    elseif repairing > 0 then
                        elem.highlight.FillColor    = Color3.fromRGB(0, 150, 255)
                        elem.highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
                        elem.nameLabel.TextColor3   = Color3.fromRGB(0, 200, 255)
                        elem.infoLabel.Text         = displayPct .. "% | " .. repairing .. " repairing"
                    else
                        elem.highlight.FillColor    = Color3.fromRGB(255, 200, 0)
                        elem.highlight.OutlineColor = Color3.fromRGB(255, 150, 0)
                        elem.nameLabel.TextColor3   = Color3.fromRGB(255, 200, 0)
                        elem.infoLabel.Text         = displayPct .. "% | idle"
                    end
                    elem.highlight.Enabled = true
                end
            end)
        else
            for model in pairs(genEspElements) do removeGenESP(model) end
        end
        task.wait(0.1)
    end
end)

local repo         = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
Library            = loadstring(game:HttpGet(repo.."Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo.."addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo.."addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
	Title            = "KKKK",
	Footer           = "v1.0.3.1",
	Icon             = 95816097006870,
	NotifySide       = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Changelog       = Window:AddTab("Changelog", "mail"),
	Survivor        = Window:AddTab("Survivor Settings", "user"),
	Killer          = Window:AddTab("Killer Settings",   "sword"),
    Aimbot          = Window:AddTab("Aimbot",   "crosshair"),
	ESP             = Window:AddTab("ESP",       "eye"),
    World           = Window:AddTab("World Settings",   "globe"),
	["UI Settings"] = Window:AddTab("Settings",  "settings"),
}
local update = Tabs.Changelog:AddLeftGroupbox("Changelog Update 17 Aug")
update:AddLabel({ Text = "/ Improve Anti Stun +++" })
update:AddLabel({ Text = "/ Improve Moonwalk  press G" })
update:AddLabel({ Text = "+ Add SCP ESP" })
update:AddLabel({ Text = "+ Add Legit Mode For Auto Parry" })
update:AddLabel({ Text = "/ Optimize all ESP" })
local update2 = Tabs.Changelog:AddRightGroupbox("Changelog Update 18 Aug")
update2:AddLabel({ Text = "/ Improve Esp" })
update2:AddLabel({ Text = "+ Add Silent Aim Veil/Gun" })
update2:AddLabel({ Text = "+ Add Fov Circle" })
update2:AddLabel({ Text = "+ Add Silent Aim Fov Slider" })
update2:AddLabel({ Text = "+ Add Fast Skillcheck Speed" })
update2:AddLabel({ Text = "+ Add Skillcheck Speed Value Slider" })
update2:AddLabel({ Text = "+ Add Vault Speed" })
update2:AddLabel({ Text = "+ Add Vault Speed Value Slider" })
local update3 = Tabs.Changelog:AddLeftGroupbox("Changelog Update 20 Aug")
update3:AddLabel({ Text = "+ Add Vault Speed ( Killer )" })
update3:AddLabel({ Text = "+ Add Vault Speed Value Slider ( Killer )" })
update3:AddLabel({ Text = "+ Add Tab Aimbot" })
update3:AddLabel({ Text = "+ Add Silent Aim The Cure" })
update3:AddLabel({ Text = "+ Add Silent Aim Twist of Fate" })
update3:AddLabel({ Text = "+ Add Aimbot FlashLight" })
update3:AddLabel({ Text = "+ Add Auto Drop Pallet When Killer Carry" })
update3:AddLabel({ Text = "+ Add ESP Generator" })
update3:AddLabel({ Text = "+ Move Spear Aimbot to the Aimbot tab" })
update3:AddLabel({ Text = "/ Improve Aimbot The Veil 99% Hit" })
update3:AddLabel({ Text = "/ Optimize Esp Scp" })
update3:AddLabel({ Text = "* Fix ESP Generator" })
update3:AddLabel({ Text = "- Remove spear_gravity_ready Slider" })
update3:AddLabel({ Text = "- Remove spear_gravity_cd Slider" })

local PalletBox      = Tabs.Survivor:AddLeftGroupbox("Pallet Killer Stun")
local SkillBox       = Tabs.Survivor:AddRightGroupbox("Skillcheck")
local VaultBox       = Tabs.Survivor:AddRightGroupbox("Instant Fast Vault")
local ParryBox       = Tabs.Survivor:AddLeftGroupbox("Anti Hit")

PalletBox:AddToggle("Stun Killer", {
	Text     = "Auto Drop Pallet ",
	Default  = state.cfg.p_enabled,
	Tooltip  = "Automatically drop pallets on Killers",
	Callback = function(v) state.cfg.p_enabled = v end,
})
PalletBox:AddToggle("AutoDropCarriedEnabled", {
    Text     = "Auto Drop Pallet (Carried)",
    Default  = false,
    Callback = function(v)
        autoDropCarriedEnabled = v
    end,
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

SkillBox:AddToggle("Skillcheck", {
	Text     = "Auto Skillcheck",
	Default  = state.cfg.sc_enabled,
	Callback = function(v) state.cfg.sc_enabled = v end,
})
SkillBox:AddToggle("ScSpeed", {
	Text     = "Fast Skillcheck Speed",
	Default  = state.cfg.sc_speed_enabled,
	Callback = function(v)
		state.cfg.sc_speed_enabled = v
		if not v then
			pcall(function()
				local charModel = workspace:FindFirstChild(lp.Name)
				if charModel then
					charModel:SetAttribute("skillcheckspeed", nil)
				end
			end)
		end
	end,
})
SkillBox:AddSlider("ScSpeedValue", {
	Text     = "Skillcheck Speed Value",
	Default  = state.cfg.sc_speed_value,
	Min=0.001, Max=10, Rounding=3,
	Callback = function(v) state.cfg.sc_speed_value = v end,
})
SkillBox:AddSlider("ScOffset", {
	Text     = "Hit Zone Offset",
	Default  = state.cfg.sc_offset,
	Min=80, Max=130, Rounding=0, Suffix="\xc2\xb0",
	Callback = function(v) state.cfg.sc_offset = v end,
})
SkillBox:AddSlider("ScLead", {
	Text     = "Lead Angle",
	Default  = state.cfg.sc_lead,
	Min=0, Max=10, Rounding=0, Suffix="\xc2\xb0",
	Callback = function(v) state.cfg.sc_lead = v end,
})

VaultBox:AddToggle("instant FastVault", {
	Text     = "Fast Vault",
	Default  = state.cfg.fv_enabled,
	Callback = function(v) state.cfg.fv_enabled = v end,
})
VaultBox:AddToggle("FvVaultSpeed", {
	Text     = "Vault Speed",
	Default  = state.cfg.fv_vaultSpeed_enabled,
	Callback = function(v)
		state.cfg.fv_vaultSpeed_enabled = v
		if not v then
			pcall(function()
				local charModel = workspace:FindFirstChild(lp.Name)
				if charModel then
					charModel:SetAttribute("vaultspeed", nil)
				end
			end)
		end
	end,
})
VaultBox:AddSlider("FvVaultSpeedValue", {
	Text     = "Vault Speed Value",
	Default  = state.cfg.fv_vaultSpeed_value,
	Min=1.5, Max=10, Rounding=1,
	Callback = function(v) state.cfg.fv_vaultSpeed_value = v end,
})
VaultBox:AddSlider("FvRadius", {
	Text     = "Arm Radius",
	Default  = state.cfg.fv_radius,
	Min=4, Max=25, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.fv_radius = v end,
})
VaultBox:AddSlider("FvMinSpeed", {
	Text     = "Min Speed",
	Default  = state.cfg.fv_minSpeed,
	Min=5, Max=30, Rounding=1, Suffix=" studs/s",
	Callback = function(v) state.cfg.fv_minSpeed = v end,
})
VaultBox:AddSlider("FvTurnLimit", {
	Text     = "Turn Limit",
	Default  = state.cfg.fv_target,
	Min=0, Max=40, Rounding=0, Suffix="\xc2\xb0",
	Callback = function(v) state.cfg.fv_target = v end,
})
VaultBox:AddToggle("FvIgnoreAxis", {
	Text     = "Ignore Off-Axis",
	Default  = state.cfg.fv_ignoreAxis,
	Callback = function(v) state.cfg.fv_ignoreAxis = v end,
})

ParryBox:AddToggle("Anti Hit", {
	Text     = "Auto Parry",
	Default  = state.cfg.ap_enabled,
	Callback = function(v)
		state.cfg.ap_enabled = v
	end,
})
ParryBox:AddToggle("LegitMode", {
	Text     = "Legit Mode",
	Default  = state.cfg.ap_legitMode,
	Callback = function(v) state.cfg.ap_legitMode = v end,
})
ParryBox:AddSlider("LegitMinDelay", {
	Text     = "Legit Min Delay",
	Default  = state.cfg.ap_legitMinDelay,
	Min=0.0, Max=0.3, Rounding=2, Suffix="s",
	Callback = function(v) state.cfg.ap_legitMinDelay = v end,
})
ParryBox:AddSlider("LegitMaxDelay", {
	Text     = "Legit Max Delay",
	Default  = state.cfg.ap_legitMaxDelay,
	Min=0.05, Max=0.5, Rounding=2, Suffix="s",
	Callback = function(v) state.cfg.ap_legitMaxDelay = v end,
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
	Callback = function(v) state.cfg.ap_cooldown = v end,
})
ParryBox:AddSlider("AnimPreDelay", {
	Text     = "Anim Pre-Delay",
	Default  = state.cfg.ap_animPreDelay,
	Min=0.0, Max=0.3, Rounding=2, Suffix="s",
	Callback = function(v) state.cfg.ap_animPreDelay = v end,
})

local AntiStunBox = Tabs.Killer:AddRightGroupbox("Anti Stun for Killer")
AntiStunBox:AddToggle("AntiStunEnabled", {
	Text     = "Enable Anti Stun",
	Default  = state.cfg.antiStun_enabled,
	Callback = function(v)
		state.cfg.antiStun_enabled = v
		antiStunActive = v
	end,
})

local FlashBox = Tabs.Killer:AddRightGroupbox("Anti Flashlight")
FlashBox:AddToggle("NoFlashBlind", {
	Text     = "No Flash Blind",
	Default  = state.cfg.noFlashBlind,
	Callback = function(v) state.cfg.noFlashBlind = v end,
})

local BreakSpeedBox = Tabs.Killer:AddRightGroupbox("Break Speed")
BreakSpeedBox:AddToggle("BreakSpeedEnabled", {
	Text     = "Enable Break Speed",
	Default  = state.cfg.breakSpeed_enabled,
	Callback = function(v) state.cfg.breakSpeed_enabled = v end,
})
BreakSpeedBox:AddSlider("BreakSpeedValue", {
	Text     = "Break Speed Value",
	Default  = state.cfg.breakSpeed_value,
	Min=1, Max=10, Rounding=0,
	Callback = function(v) state.cfg.breakSpeed_value = v end,
})

local MaskedBox = Tabs.Killer:AddLeftGroupbox("The Masked")
local maskList = { "Alex", "Brandon", "Cobra", "Rabbit", "Richter", "Richard", "Tony" }
MaskedBox:AddDropdown("SelectMask", {
	Text    = "Select Mask",
	Default = state.cfg.selectMask,
	Values  = maskList,
	Callback = function(v)
		state.cfg.selectMask = v
	end,
})
MaskedBox:AddButton({
	Text = "Use Mask Power",
	Func = function()
		pcall(function()
			game:GetService("ReplicatedStorage")
				:WaitForChild("Remotes")
				:WaitForChild("Killers")
				:WaitForChild("Masked")
				:WaitForChild("Activatepower")
				:FireServer(state.cfg.selectMask)
		end)
	end,
})
local Swiftbox = Tabs.Killer:AddLeftGroupbox("vault")
Swiftbox:AddToggle("swiftspeed_toggle", {
	Text     = "Vault Speed (Swift)",
	Default  = false,
	Callback = function(v)
		state.cfg.swiftspeed_enabled = v
		if not v then
			pcall(function()
				local charModel = workspace:FindFirstChild(lp.Name)
				if charModel then
					charModel:SetAttribute("swift", nil)
				end
			end)
		end
	end,
})

Swiftbox:AddSlider("swiftspeed_value", {
	Text     = "Swift Speed Value",
	Default  = 1.5,
	Min      = 1,
	Max      = 10,
	Rounding = 1,
	Callback = function(v) state.cfg.swiftspeed_value = v end,
})

local aimbot = Tabs.Aimbot:AddRightGroupbox("The Veil Legit")
local aimbots = Tabs.Aimbot:AddLeftGroupbox("Twist of Fate")
aimbots:AddToggle("SilentAimSurvivorEnabled", {
    Text     = "Silent Aim",
    Default  = false,
    Callback = function(v) state.cfg.silentAim_survivor_enabled = v end,
})
aimbots:AddDropdown("SilentAimSurvivorTarget", {
    Text     = "Lock Target",
    Default  = "Killer",
    Values   = { "Killer", "Survivor" },
    Callback = function(v) state.cfg.silentAim_survivor_target = v end,
})
local aimbotf = Tabs.Aimbot:AddLeftGroupbox("Flashlight")
aimbotf:AddToggle("FlashlightAimEnabled", {
	Text     = "Aimbot Flashlight",
	Default  = false,
	Callback = function(v)
		flashlightAimEnabled = v
	end,
})
aimbot:AddToggle("The Veil Killer", {
	Text     = "Spear Aimlock (Hold E)",
	Default  = state.cfg.spear_enabled,
	Callback = function(v) state.cfg.spear_enabled = v end,
})
local aimbotc = Tabs.Aimbot:AddRightGroupbox("Silent Aim Killer")
aimbotc:AddToggle("SilentAimCureEnabled", {
    Text     = "Silent Aim",
    Default  = false,
    Callback = function(v) state.cfg.silentAim_cure_enabled = v end,
})
aimbotc:AddDropdown("KillerModeSelect", {
    Text     = "Killer",
    Default  = "The Veil",
    Values   = { "The Veil", "The Cure" },
    Callback = function(v) state.cfg.silentAim_killerMode = v end,
})
aimbotc:AddToggle("SilentAimFOVShow", {
	Text     = "Show FOV Circle",
	Default  = false,
	Callback = function(v) state.cfg.silentAim_showFOV = v end,
})
aimbotc:AddSlider("SilentAimFOV", {
	Text     = "Silent Aim FOV",
	Default  = 150,
	Min      = 10,
	Max      = 500,
	Rounding = 0,
	Suffix   = "px",
	Callback = function(v) state.cfg.silentAim_fov = v end,
})
aimbotc:AddDropdown("TargetPartSelect", {
	Text    = "Target Part",
	Default = "Head",
	Values  = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" },
	Callback = function(v) state.cfg.spear_targetPart = v end,
})
local AutoCrouchBox = Tabs.Survivor:AddRightGroupbox("Anti Skill")
AutoCrouchBox:AddToggle("AutoCrouchEnabled", {
	Text     = "Anti Skill The Abysswalker",
	Default  = state.cfg.autoCrouch_enabled,
	Callback = function(v) state.cfg.autoCrouch_enabled = v end,
})
AutoCrouchBox:AddSlider("AutoCrouchDelay", {
	Text     = "Crouch Delay",
	Default  = state.cfg.autoCrouch_delay,
	Min=0, Max=0.5, Rounding=2, Suffix="s",
	Callback = function(v) state.cfg.autoCrouch_delay = v end,
})
AutoCrouchBox:AddToggle("AutoCrouchHumanize", {
	Text     = "Crouch Humanizer",
	Default  = state.cfg.autoCrouch_humanize,
	Callback = function(v) state.cfg.autoCrouch_humanize = v end,
})
AutoCrouchBox:AddSlider("AutoCrouchDistance", {
	Text     = "Crouch Distance",
	Default  = state.cfg.autoCrouch_distance,
	Min=5, Max=50, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.autoCrouch_distance = v end,
})
AutoCrouchBox:AddSlider("AutoCrouchDuration", {
	Text     = "Crouch Duration",
	Default  = state.cfg.autoCrouch_duration,
	Min=0, Max=3, Rounding=1, Suffix="s",
	Callback = function(v) state.cfg.autoCrouch_duration = v end,
})

local SpearESPBox = Tabs.ESP:AddLeftGroupbox("Spear ESP")
SpearESPBox:AddToggle("SpearESPEnabled", {
	Text     = "Spear ESP",
	Default  = false,
	Callback = function(v)
		state.cfg.spear_esp_enabled = v
		if not v then
			for part in pairs(spearESPs) do removeSpearESP(part) end
		end
	end,
})
SpearESPBox:AddSlider("SpearESPMaxDist", {
	Text     = "Max Distance",
	Default  = 300,
	Min=50, Max=1000, Rounding=0, Suffix=" studs",
	Callback = function(v) state.cfg.spear_esp_maxDist = v end,
})

local GenESPBox = Tabs.ESP:AddRightGroupbox("Generator ESP")
GenESPBox:AddToggle("GenESPEnabled", {
    Text     = "Enable Generator ESP",
    Default  = false,
    Callback = function(v)
        genEspEnabled = v
        if v then
            pcall(initialScanGen)
        else
            for model in pairs(genEspElements) do removeGenESP(model) end
        end
    end,
})

local ESPBox       = Tabs.ESP:AddLeftGroupbox("Killer ESP")
local SCPEspBox    = Tabs.ESP:AddLeftGroupbox("SCP ESP")
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

SCPEspBox:AddToggle("SCPESPEnabled", {
	Text     = "Enable SCP ESP",
	Default  = false,
	Callback = function(v)
		state.cfg.scp_esp_enabled = v
		if not v then
			for model in pairs(scpEspElements) do removeSCPESP(model) end
		end
	end,
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

local Map = Tabs.World:AddLeftGroupbox("Visual")

Map:AddToggle("FullBrightEnabled", {
    Text     = "Full Bright",
    Default  = false,
    Callback = function(v)
        fullbrightEnabled = v
        if v then
            applyFullBright()
        else
            restoreFullBright()
        end
    end,
})
Map:AddToggle("NoFogEnabled", {
    Text     = "No Fog",
    Default  = false,
    Callback = function(v)
        nofogEnabled = v
        if v then
            applyNoFog()
        else
            restoreNoFog()
        end
    end,
})

pcall(function() ThemeManager:SetLibrary(Library) end)
pcall(function() SaveManager:SetLibrary(Library) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({"MenuKeybind"}) end)
pcall(function() ThemeManager:SetFolder("KKKK_HUB") end)
pcall(function() SaveManager:SetFolder("KKKK_HUB/settings") end)
pcall(function() SaveManager:BuildConfigSection(Tabs["UI Settings"]) end)
pcall(function() ThemeManager:ApplyToTab(Tabs["UI Settings"]) end)

local UnloadBox = Tabs["UI Settings"]:AddLeftGroupbox("Unload")
UnloadBox:AddButton({
	Text        = "Unload Script",
	Func        = function() Library:Unload() end,
	DoubleClick = false,
	Tooltip     = "Stops all loops and destroys the UI.",
})

-- SILENT AIM CACHE
local cachedSilentTarget = nil
local cachedCureTarget = nil
local cachedSurvivorTarget = nil
-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible   = false
fovCircle.Thickness = 1
fovCircle.Color     = Color3.fromRGB(255, 255, 255)
fovCircle.Filled    = false
fovCircle.Radius    = 150
fovCircle.NumSides  = 64

local lockLine = Drawing.new("Line")
lockLine.Visible   = false
lockLine.Thickness = 1.5
lockLine.Color     = Color3.fromRGB(255, 0, 0)
lockLine.Transparency = 0.3

local lockLineCure = Drawing.new("Line")
lockLineCure.Visible      = false
lockLineCure.Thickness    = 1.5
lockLineCure.Color        = Color3.fromRGB(0, 255, 150)
lockLineCure.Transparency = 0.3

local lockLineSurv = Drawing.new("Line")
lockLineSurv.Visible      = false
lockLineSurv.Thickness    = 1.5
lockLineSurv.Color        = Color3.fromRGB(255, 255, 0)
lockLineSurv.Transparency = 0.3

RunService.RenderStepped:Connect(function()
	local showFov = (state.cfg.silentAim_enabled or state.cfg.silentAim_cure_enabled) and state.cfg.silentAim_showFOV
	local center = UserInputService:GetMouseLocation()

	if showFov then
		fovCircle.Position = Vector2.new(center.X, center.Y)
		fovCircle.Radius   = state.cfg.silentAim_fov or 150
		fovCircle.Visible  = true
	else
		fovCircle.Visible = false
	end

	local target = cachedSilentTarget
	if state.cfg.silentAim_enabled and target and target.Parent then
		local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
		if onScreen and screenPos.Z > 0 then
			lockLine.From    = Vector2.new(center.X, center.Y)
			lockLine.To      = Vector2.new(screenPos.X, screenPos.Y)
			lockLine.Visible = true
		else
			lockLine.Visible = false
		end

		local lockedChar = target.Parent
		for char, elem in pairs(player2DEspElements) do
			if elem.highlight then
				if char == lockedChar then
					elem.highlight.FillColor    = Color3.fromRGB(255, 0, 0)
					elem.highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
				else
					elem.highlight.FillColor    = Color3.fromRGB(0, 150, 255)
					elem.highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
				end
			end
		end
	else
		lockLine.Visible = false

		for char, elem in pairs(player2DEspElements) do
			if elem.highlight then
				elem.highlight.FillColor    = Color3.fromRGB(0, 150, 255)
				elem.highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
			end
		end
	end

    local survTarget = cachedSurvivorTarget
	if state.cfg.silentAim_survivor_enabled and survTarget and survTarget.Parent then
		local screenPos, onScreen = Camera:WorldToViewportPoint(survTarget.Position)
		if onScreen and screenPos.Z > 0 then
			lockLineSurv.From    = Vector2.new(center.X, center.Y)
			lockLineSurv.To      = Vector2.new(screenPos.X, screenPos.Y)
			lockLineSurv.Visible = true
		else
			lockLineSurv.Visible = false
		end
	else
		lockLineSurv.Visible = false
	end

	local cureTarget = cachedCureTarget
	if state.cfg.silentAim_cure_enabled and cureTarget and cureTarget.Parent then
		local screenPos, onScreen = Camera:WorldToViewportPoint(cureTarget.Position)
		if onScreen and screenPos.Z > 0 then
			lockLineCure.From    = Vector2.new(center.X, center.Y)
			lockLineCure.To      = Vector2.new(screenPos.X, screenPos.Y)
			lockLineCure.Visible = true
		else
			lockLineCure.Visible = false
		end
	else
		lockLineCure.Visible = false
	end
end)

task.spawn(function()
    while state.running do
        if state.cfg.silentAim_enabled then
            cachedSilentTarget = getClosestPlayerToMouse(state.cfg.silentAim_fov)
        else
            cachedSilentTarget = nil
        end
        if state.cfg.silentAim_cure_enabled then
            cachedCureTarget = getClosestPlayerToMouse(state.cfg.silentAim_fov)
        else
            cachedCureTarget = nil
        end
        if state.cfg.silentAim_survivor_enabled then
            cachedSurvivorTarget = getClosestToMouseAny(state.cfg.silentAim_fov)
        else
            cachedSurvivorTarget = nil
        end
        task.wait(0.03)
    end
end)

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

local _saFiring = false
mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local selfName = ""
	pcall(function() selfName = tostring(self.Name or "") end)

	-- SURVIVOR SILENT AIM (Twist of Fate)
    if not _saFiring
    and state.cfg.silentAim_survivor_enabled
    and method == "FireServer"
    and selfName:find("Fire")
    then
        local myChar = lp.Character
        local item = myChar and myChar:FindFirstChild("Twist of Fate")
        if not item then return oldNamecall(self, ...) end
        local args = {...}
        local target = cachedSurvivorTarget
        if target and target.Parent then
            local dir = args[2]
            if typeof(dir) == "Vector3" then
                local itemRoot = item.PrimaryPart
                    or item:FindFirstChild("HumanoidRootPart")
                    or item:FindFirstChildWhichIsA("BasePart")
                if itemRoot then
                    args[2] = (target.Position - itemRoot.Position).Unit
                end
            end
            _saFiring = true
            pcall(function() self:FireServer(args[1], args[2]) end)
            _saFiring = false
            return
        end
    end

	-- THE VEIL SILENT AIM (Spearthrow)
    if not _saFiring
    and state.cfg.silentAim_cure_enabled
    and state.cfg.silentAim_killerMode == "The Veil"
    and method == "FireServer"
    and selfName:find("Spearthrow")
    then
        local args = {...}
        local target = cachedCureTarget
        if target and target.Parent then
            local origin = args[3]
            if typeof(origin) == "Vector3" then
                local targetVel = target.Parent:FindFirstChild("HumanoidRootPart")
                    and target.Parent.HumanoidRootPart.AssemblyLinearVelocity
                local aimPos = calculateSpearAim(origin, target.Position, targetVel)
                if aimPos then
                    args[1] = (aimPos - origin).Unit
                end
            end
            _saFiring = true
            pcall(function() self:FireServer(args[1], args[2], args[3]) end)
            _saFiring = false
            return
        end
    end

    -- THE CURE SILENT AIM (ThrowFlask)
	if not _saFiring
	and state.cfg.silentAim_cure_enabled
	and state.cfg.silentAim_killerMode == "The Cure"
	and method == "FireServer"
	and selfName:find("ThrowFlask")
	then
		local args = {...}
		local target = cachedCureTarget
		if target and target.Parent then
			local origin = args[2]
			if typeof(origin) == "Vector3" then
				args[1] = (target.Position - origin).Unit
			end
			_saFiring = true
			pcall(function() self:FireServer(args[1], args[2]) end)
			_saFiring = false
			return
		end
	end

	return oldNamecall(self, ...)
end)
setreadonly(mt, true)

Library:OnUnload(function()
	state.running      = false
	moonwalkEnabled    = false
	moonwalkSway       = 0
	fvHold             = false
	vaults             = {}
	cachedSilentTarget = nil
	pcall(function() fovCircle:Remove() end)
	pcall(function()
		if parryAdornment and parryAdornment.Parent then
			parryAdornment.Visible = false
			parryAdornment.Adornee = nil
			parryAdornment:Destroy()
		end
	end)
	pcall(function()
		local mt2 = getrawmetatable(game)
		setreadonly(mt2, false)
		mt2.__namecall = oldNamecall
		setreadonly(mt2, true)
	end)
	pcall(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj.Name == "KKKK_Hub_ParryHollowRing" then obj:Destroy() end
		end
	end)
	pcall(function() espGui:Destroy() end)
	pcall(function() spearEspGui:Destroy() end)
    pcall(function() lockLine:Remove() end)
    pcall(function() lockLineCure:Remove() end)
    pcall(function() lockLineSurv:Remove() end)
    pcall(function() stopFlashlightAim() end)
    pcall(function()
    restoreFullBright()
    restoreNoFog()
end)
	for part in pairs(spearESPs) do removeSpearESP(part) end
	for char, conns in pairs(killerAnimConns) do
		for _,c in ipairs(conns) do pcall(c.Disconnect, c) end
	end
	for char in pairs(killer2DEspElements) do removeKiller2DESP(char) end
	for model in pairs(scpEspElements) do removeSCPESP(model) end
	for char in pairs(player2DEspElements) do removePlayer2DESP(char) end
    for model in pairs(genEspElements) do removeGenESP(model) end
	scpEspElements           = {}
	playerParryState         = {}
	monitoredPlayerAnimators = {}
	hitboxMonitored          = {}
	_G.KKKkhub = nil
	print("[KKKK Hub v1.0.3.1] Unloaded!")
end)
