local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer
if not lp then
	repeat task.wait(0.5) until Players.LocalPlayer
	lp = Players.LocalPlayer
end

local _cam = Workspace.CurrentCamera

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

        antiFallDamage_enabled = false,

		sc_enabled  = false,
		sc_lead     = 2,
		sc_offset   = 102,
		sc_key      = 32,
        sc_speed_enabled = false,
        sc_speed_value   = 0.5,

		ap_enabled        = false,
		ap_cooldown       = 0.05,
		ap_showCircle     = true,
        ap_pendingColor  = Color3.fromRGB(255, 150, 0),
		ap_circleColor    = Color3.fromRGB(0, 255, 200),
		ap_animRadius     = 10,
		ap_animPreDelay   = 0,
		ap_pendingRadius  = 25,
		ap_hitboxRadius   = 16,
		ap_hitboxPreDelay = 0.0,

		ap_legitMode        = false,
		ap_legitMinDelay    = 0.01,
		ap_legitMaxDelay    = 0.10,

        ap_dirCheck_enabled = true,
        ap_facingAngle = 120,   

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
		p_esp_showStatus    = false,
		p_esp_maxDist       = 500,

		godmode_enabled     = false,
		noFlashBlind        = false,
		breakSpeed_enabled  = false,
		breakSpeed_value    = 1,
		selectMask          = "Alex",
        swiftspeed_enabled = false,
        swiftspeed_value   = 1.5,

        autoCrouch_enabled   = false,
        autoCrouch_delay     = 0.0,
        autoCrouch_humanize  = false,
        autoCrouch_distance  = 15,
        autoCrouch_duration  = 1.5,
	}
}
_G.KKKkhub = state
state.ui     = {}
state.render = {}

-- Detect ANIM for parry
local HIT_ANIM_IDS = {
	-- The Butcher
	[127417297154354] = true, -- Lunge
	[83333467665074]  = true, -- Slash

	-- Jason
	[129626174716003] = true, -- Lunge
	[113691709436161] = true, -- Slash

	-- Stalker
	[117042998468241] = true, -- Lunge
	[133963973694098] = true, -- Slash

	-- Jeff
	[93902163029544]  = true, -- Lunge
	[75618342544502]  = true, -- Slash
	[79310600168078]  = true, -- Frenzy Slash
	[104540716539347] = true, -- Frenzy Lunge

	-- Hidden
	[74968262036854]  = true, -- Slash
	[113255068724446] = true, -- Lunge
    [98163597193511] = true, -- Skill

	-- Abysswalker
	[101636125032002] = true, -- Slash
	[125430111937587] = true, -- Lunge
    [136820376940910] = true, -- kick lunge
    [125430111937587] = true, -- kick hit

	-- Veil
	[84926129581106]  = true, -- Lunge
	[81963230963908]  = true, -- Slash

	-- Jacket
	[111920872708571] = true, -- Slash
	[105374834496520] = true, -- Lunge
	[130593238885843] = true, -- Slash 2
	[115244153053858] = true, -- Lunge 2
	[109402730355822] = true, -- Slash 3
	[106871536134254] = true, -- Lunge 3
	[138720291317243] = true, -- Slash 4

	-- Sc
	[121216847022485] = true, -- Slash
	[135002183282873] = true, -- Lunge
}

local _SKILL_ANIM_IDS = {}

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

-- Picture Item for ESP
local ITEM_ICONS = {
    ["Adrenaline Shot"] = "rbxassetid://135388781922226",
    ["Bandage"]         = "rbxassetid://97791520639443",
    ["Flashlight"]      = "rbxassetid://103299939715311",
    ["Gate"]            = "rbxassetid://131249244284700",
    ["Holy Water"]      = "rbxassetid://86130208614143",
    ["Monkey Paw"]      = "rbxassetid://78636637697235",
    ["Motion Tracker"]  = "rbxassetid://92303584765773",
    ["Parrying Dagger"] = "rbxassetid://76822757630703",
    ["Riot Shield"]     = "rbxassetid://95718705901699",
    ["Shadow Clone"]    = "rbxassetid://134088840518889",
    ["Twist of Fate"]   = "rbxassetid://98397448432071",
    ["WaxBound Candle"] = "rbxassetid://110413686590821",
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
		pcall(function()
			VirtualInputManager:SendKeyEvent(true, keyCodeEnum or Enum.KeyCode.Space, false, game)
			task.wait(0.01)
			VirtualInputManager:SendKeyEvent(false, keyCodeEnum or Enum.KeyCode.Space, false, game)
		end)
	end)
end

local function healSelf()
    pcall(function()
        local Event = game:GetService("ReplicatedStorage").Remotes.Healing.HealEvent
        local myChar = lp.Character
        local myRoot2 = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot2 then return end
        Event:FireServer(
            myRoot2,
            true,
            "BBA6AE6C-E28A-45BB-AB2F-5D6F1F7CA4EE",
            myChar
        )
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

local function getClosestToMouseAny(overrideFov)
    local mousePos = UserInputService:GetMouseLocation()
    local closestPart = nil
    local shortestDistance = math.huge
    local targetPartName = state.cfg.spear_targetPart or "Head"
    local fov = overrideFov or state.cfg.silentAim_fov or 150
    local wantKiller = state.cfg.silentAim_survivor_target == "Killer"

    -- Players
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
                    local knocked = char:GetAttribute("Knocked")
                    if hum and hum.Health > 0 and targetPart and not knocked then
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

    -- Bots
    if not wantKiller then
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") then
                local ok, botId = pcall(function() return obj:GetAttribute("BotId") end)
                if ok and botId ~= nil then
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    local hum  = obj:FindFirstChildOfClass("Humanoid")
                    local knocked = obj:GetAttribute("Knocked")
                    if root and hum and hum.Health > 0 and not knocked then
                        if not player2DEspElements[obj] then createPlayer2DESP(obj) end
                        local elem = player2DEspElements[obj]
                        if elem then
                            elem.nameLabel.Text = "[Bot] " .. tostring(obj.Name) .. (knocked and "  [KNOCKED]" or "")
                            elem.nameLabel.TextColor3 = knocked and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 255, 255)
                            elem.distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                            if elem.highlight then
                                elem.highlight.FillColor    = Color3.fromRGB(255, 255, 255)
                                elem.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            end
                            local x, y, width, height, dist = get2DScreenBounds(obj)
                            updateEspElem(elem, obj, x, y, width, height, dist)
                        end
                    else
                        removePlayer2DESP(obj)
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

    -- Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and not isSpectator() then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local targetPart = char:FindFirstChild(targetPartName)
                    or char:FindFirstChild("HumanoidRootPart")
                    or char:FindFirstChild("Head")
                local knocked = char:GetAttribute("Knocked")
                if hum and hum.Health > 0 and targetPart and not knocked then
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

    -- Bots
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local ok, botId = pcall(function() return obj:GetAttribute("BotId") end)
            if ok and botId ~= nil then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local targetPart = obj:FindFirstChild(targetPartName)
                    or obj:FindFirstChild("HumanoidRootPart")
                    or obj:FindFirstChild("Head")
                local knocked = obj:GetAttribute("Knocked")
                if hum and hum.Health > 0 and targetPart and not knocked then
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

-- God Mode
task.spawn(function()
	while state.running do
		pcall(function()
			if state.cfg.godmode_enabled then
				local ch = lp.Character
				local hum = ch and ch:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
					hum.Health = hum.MaxHealth
				end
			end
		end)
		task.wait(0.1)
	end
end)

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
            local trapPerfect = chk and chk:FindFirstChild("TrapPerfect")
            local trapGoal    = chk and chk:FindFirstChild("TrapGoal")
            local isTrap      = trapPerfect and trapPerfect.Visible
            local Goal = chk and (
                isTrap and trapPerfect
                or (not isTrap and trapGoal and trapGoal.Visible and trapGoal)
                or chk:FindFirstChild("Goal")
            )
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
        task.wait(0.01)
    end
end)

local function getFacingAngleToMe(kRoot)
    local myChar = lp.Character
    local myRoot2 = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot2 or not kRoot then return nil end
    local ok, angle = pcall(function()
        local dot = kRoot.CFrame.LookVector:Dot(
            (myRoot2.Position - kRoot.Position).Unit
        )
        return math.deg(math.acos(math.clamp(dot, -1, 1)))
    end)
    return ok and angle or nil
end

local function killerFacingMe(kRoot)
    if not state.cfg.ap_dirCheck_enabled then return true end
    local angle = getFacingAngleToMe(kRoot)
    if angle == nil then return true end
    return angle <= (state.cfg.ap_facingAngle or 120)
end

local function doRightClick()
    pcall(function()
        if typeof(mouse2click) == "function" then mouse2click(); return end
        if typeof(mouse2press) == "function" and typeof(mouse2release) == "function" then
            mouse2press(); mouse2release(); return
        end
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end)
end

local lastParryTime = 0

local function parry(reason, extraDelay, kRoot)
    if not state.cfg.ap_enabled then return end
    if not isSurvivor() then return end
    if kRoot and not killerFacingMe(kRoot) then return end
    local now = tick()
    if (now - lastParryTime) < (state.cfg.ap_cooldown or PARRY_COOLDOWN) then return end
    lastParryTime = now
    if state.cfg.ap_legitMode then
        task.spawn(function()
            local mn = state.cfg.ap_legitMinDelay or 0.05
            local mx = state.cfg.ap_legitMaxDelay or 0.15
            local delay = mn + math.random() * (mx - mn)
            if delay > 0 then task.wait(delay) end
            doRightClick()
        end)
    else
        doRightClick()
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

    local animId = getAnimAssetId(track)
    if not animId or not HIT_ANIM_IDS[animId] then return end

    local me = myRoot()
    if not me then return end
    if not (kRoot and kRoot.Parent) then return end
    if not killerFacingMe(kRoot) then return end

    local dist = (me.Position - kRoot.Position).Magnitude
    local animR = state.cfg.ap_animRadius or 12

    if dist <= animR then
        parry("Anim:"..track.Name..string.format("(%.1f)", dist), 0, kRoot)
    else
        local pendR = state.cfg.ap_pendingRadius or 22
        if dist <= pendR then
            local animLen = math.min(
                (track.Length and track.Length > 0) and track.Length or 2.0, 2.5
            )
            pushPending(kRoot, track.Name, 100, animLen)
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
    for _, v in ipairs(char:GetDescendants()) do
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
        for _, c in ipairs(killerAnimConns[char] or {}) do pcall(c.Disconnect, c) end
        killerAnimConns[char] = nil
        monitoredKillers[char] = nil
    end)
end

task.spawn(function()
    while state.running do
        if state.cfg.ap_enabled and isSurvivor() then
            local me    = myRoot()
            local now   = tick()
            local animR = state.cfg.ap_animRadius or 12
            local remaining = {}
            for _, sw in ipairs(pendingSwings) do
                if sw.fired or now > sw.deadline then
                elseif not (sw.killerRoot and sw.killerRoot.Parent) then
                elseif not me then
                    remaining[#remaining+1] = sw
                else
                    local ok, dist = pcall(function()
                        return (me.Position - sw.killerRoot.Position).Magnitude
                    end)
                    if ok then
                        if dist <= animR then
                            sw.fired = true
                            parry("PendingAnim:"..sw.trackName..string.format("(%.1f)", dist), 0, sw.killerRoot)
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
            end
        end
        task.wait(0.02)
    end
end)

local ABYSSWALKER_SKILL_ID = 100014992013740
local _lastCrouchTime = 0

task.spawn(function()
    while state.running do
        if state.cfg.autoCrouch_enabled and isSurvivor() then
            pcall(function()
                local now = tick()
                local cooldown = (state.cfg.autoCrouch_duration or 1.5) + 3.0
                if now - _lastCrouchTime < cooldown then return end
                for _, plr in ipairs(Players:GetPlayers()) do
                    if isKillerPlayer(plr) then
                        local char = plr.Character
                        if not char then continue end
                        local anim = findAnimator(char)
                        if not anim then continue end
                        for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
                            local animId = getAnimAssetId(track)
                            if animId == ABYSSWALKER_SKILL_ID
                            and track.TimePosition < 0.2 then
                                local me = myRoot()
                                if not me then break end
                                local kRoot = char:FindFirstChild("HumanoidRootPart")
                                if not kRoot then break end
                                local dist = (me.Position - kRoot.Position).Magnitude
                                if dist <= state.cfg.autoCrouch_distance then
                                    _lastCrouchTime = now
                                    local delay = state.cfg.autoCrouch_delay or 0
                                    if state.cfg.autoCrouch_humanize then
                                        delay = delay + math.random() * 0.08
                                    end
                                    task.spawn(function()
                                        if delay > 0 then task.wait(delay) end
                                        pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game) end)
                                        pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game) end)
                                        pcall(function() keypress(0x11) end) -- LeftControl
                                        pcall(function() keypress(0x43) end) -- C
                                        task.wait(state.cfg.autoCrouch_duration or 1.5)
                                        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game) end)
                                        pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game) end)
                                        pcall(function() keyrelease(0x11) end)
                                        pcall(function() keyrelease(0x43) end)
                                    end)
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

local function _getCharAttribute(char, attrName)
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

local killer2DEspElements = {}
local player2DEspElements = {}

local removePlayer2DESP
local removeKiller2DESP

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

removeKiller2DESP = function(char)
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
	highlight.FillColor           = Color3.fromRGB(0, 0, 0)
	highlight.OutlineColor        = Color3.fromRGB(255, 255, 255)
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
	nameLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font                   = Enum.Font.GothamBold
	nameLabel.TextSize               = 13
	nameLabel.TextXAlignment         = Enum.TextXAlignment.Center
	nameLabel.Text                   = "[Killer] " .. char.Name
	nameLabel.Parent                 = container
	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Size                   = UDim2.new(0, 160, 0, 14)
	distLabel.TextColor3             = Color3.fromRGB(200, 200, 200)
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

removePlayer2DESP = function(char)
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
    highlight.FillColor           = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor        = Color3.fromRGB(255, 255, 255)
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
    nameLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font                   = Enum.Font.GothamBold
    nameLabel.TextSize               = 13
    nameLabel.TextXAlignment         = Enum.TextXAlignment.Center
    nameLabel.Text                   = char.Name
    nameLabel.Parent                 = container
    local distLabel = Instance.new("TextLabel")
    distLabel.BackgroundTransparency = 1
    distLabel.Size                   = UDim2.new(0, 160, 0, 14)
    distLabel.TextColor3             = Color3.fromRGB(200, 200, 200)
    distLabel.TextStrokeTransparency = 0
    distLabel.Font                   = Enum.Font.GothamBold
    distLabel.TextSize               = 11
    distLabel.TextXAlignment         = Enum.TextXAlignment.Center
    distLabel.Text                   = ""
    distLabel.Parent                 = container
    local itemLabel = Instance.new("ImageLabel")
    itemLabel.BackgroundTransparency = 1
    itemLabel.Size                   = UDim2.new(0, 24, 0, 24)
    itemLabel.ScaleType              = Enum.ScaleType.Fit
    itemLabel.Image                  = ""
    itemLabel.Visible                = false
    itemLabel.Parent                 = container
    player2DEspElements[char] = {
        container = container,
        highlight = highlight,
        nameLabel = nameLabel,
        distLabel = distLabel,
        itemLabel = itemLabel,
    }
end

local _cachedPlayers = {}
local _playerCacheTime = 0

RunService.Heartbeat:Connect(function()
	if not state.running then return end
	local c = state.cfg
	local spectating = isSpectator()
	if spectating then
		for char in pairs(killer2DEspElements or {}) do removeKiller2DESP(char) end
		for char in pairs(player2DEspElements or {}) do removePlayer2DESP(char) end
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
					if elem.highlight then
						elem.highlight.Enabled = c.esp_showHighlight
					end
					if x then
						local dynamicFont = math.clamp(math.floor(height * 0.22), 10, 14)
						elem.container.Visible  = true
						elem.nameLabel.Visible  = c.esp_showName
						elem.nameLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y - (dynamicFont + 8))
						elem.nameLabel.TextSize = dynamicFont
						elem.distLabel.Visible  = true
						elem.distLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y + height + 3)
						elem.distLabel.TextSize = math.max(9, dynamicFont - 1)
						elem.distLabel.Text     = string.format("[%d studs]", math.floor(dist or 0))
					else
						elem.container.Visible = false
					end
				end
			end
		end
	else
		for char in pairs(killer2DEspElements or {}) do removeKiller2DESP(char) end
	end

    if c.p_esp_enabled then
        local now = tick()
        if (now - _playerCacheTime) > 0.5 then
            _cachedPlayers = Players:GetPlayers()
            _playerCacheTime = now
        end

        for char, _ in pairs(player2DEspElements) do
            local shouldRemove = true
            for _, plr in ipairs(_cachedPlayers) do
                if plr.Character == char then
                    local team = plr.Team
                    local teamName = team and tostring(team.Name) or ""
                    if teamName ~= "Killer" and teamName ~= "Spectator" and plr ~= lp then
                        shouldRemove = false
                    end
                    break
                end
            end
            local ok, botId = pcall(function() return char:GetAttribute("BotId") end)
            if ok and botId ~= nil then shouldRemove = false end
            if shouldRemove then removePlayer2DESP(char) end
        end

        local function updateEspElem(elem, char, x, y, width, height, dist)
            if elem.highlight then elem.highlight.Enabled = c.p_esp_showHighlight end
            if x then
                local dynamicFont = math.clamp(math.floor(height * 0.20), 10, 14)
                elem.container.Visible  = true
                elem.nameLabel.Visible  = c.p_esp_showName

                local knocked = char:GetAttribute("Knocked")
                local okBot, botId = pcall(function() return char:GetAttribute("BotId") end)
                local okBot2, botNetId = pcall(function() return char:GetAttribute("BotNetId") end)
                local isBot = (okBot and botId ~= nil) or (okBot2 and botNetId ~= nil)
                local displayName = isBot and ("[Bot] " .. char.Name) or char.Name
                elem.nameLabel.Text = displayName .. (knocked and "  [KNOCKED]" or "")
                if knocked then
                    elem.nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    if elem.highlight then
                        elem.highlight.OutlineColor = Color3.fromRGB(255, 80, 80)
                    end
                else
                    elem.nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    if elem.highlight then
                        elem.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                end

                elem.nameLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y - (dynamicFont + 8))
                elem.nameLabel.TextSize = dynamicFont
                elem.distLabel.Visible  = true
                elem.distLabel.Position = UDim2.new(0, x + (width/2) - 80, 0, y + height + 3)
                elem.distLabel.TextSize = math.max(9, dynamicFont - 1)
                elem.distLabel.Text = string.format("[%d studs]", math.floor(dist or 0))
                if elem.itemLabel then
                    local icon = nil
                    for _, child in ipairs(char:GetChildren()) do
                        if child:IsA("Model") or child:IsA("Tool") then
                            local foundIcon = ITEM_ICONS[child.Name]
                            if foundIcon then icon = foundIcon; break end
                        end
                    end
                    if not icon then
                        local ok, eq = pcall(function() return char:GetAttribute("EquippedItem") end)
                        if ok and eq then icon = ITEM_ICONS[tostring(eq)] end
                    end
                    if icon then
                        local iconSize = 35
                        elem.itemLabel.Image    = icon
                        elem.itemLabel.Size     = UDim2.new(0, iconSize, 0, iconSize)
                        elem.itemLabel.Position = UDim2.new(0, x + (width/2) - iconSize/2, 0, y + height + 18)
                        elem.itemLabel.Visible  = true
                    else
                        elem.itemLabel.Visible = false
                    end
                end
            else
                elem.container.Visible = false
            end
        end

        -- survivor esp
        for _, plr in ipairs(_cachedPlayers) do
            if plr ~= lp then
                local team = plr.Team
                local teamName = team and tostring(team.Name) or ""
                if teamName ~= "Killer" and teamName ~= "Spectator" and teamName ~= "" then
                    local char = plr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if char and root then
                        if not player2DEspElements[char] then createPlayer2DESP(char) end
                        local elem = player2DEspElements[char]
                        if elem then
                            local x, y, width, height, dist = get2DScreenBounds(char)
                            updateEspElem(elem, char, x, y, width, height, dist)
                        end
                    end
                end
            end
        end

        -- bot esp
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") then
                local ok, botId = pcall(function() return obj:GetAttribute("BotId") end)
                local ok2, botNetId = pcall(function() return obj:GetAttribute("BotNetId") end)
                local isBot = (ok and botId ~= nil) or (ok2 and botNetId ~= nil)
                if isBot then
                    local root = obj:FindFirstChild("HumanoidRootPart")
                    local hum  = obj:FindFirstChildOfClass("Humanoid")
                    if root and hum and hum.Health > 0 then
                        if not player2DEspElements[obj] then createPlayer2DESP(obj) end
                        local elem = player2DEspElements[obj]
                        if elem then
                            local knocked = obj:GetAttribute("Knocked")
                            elem.nameLabel.Text = "[Bot] " .. tostring(obj.Name) .. (knocked and "  [KNOCKED]" or "")
                            elem.nameLabel.TextColor3 = knocked and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 255, 255)
                            elem.distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                            if elem.highlight then
                                elem.highlight.FillColor    = Color3.fromRGB(255, 255, 255)
                                elem.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            end
                            local x, y, width, height, dist = get2DScreenBounds(obj)
                            updateEspElem(elem, obj, x, y, width, height, dist)
                        end
                    else
                        removePlayer2DESP(obj)
                    end
                end
            end
        end
    else
        for char in pairs(player2DEspElements or {}) do removePlayer2DESP(char) end
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
		local gen  = sla and sla:FindFirstChild("bottom left")
		local mv2  = gen and gen:FindFirstChild("Move2")
		local bar  = mv2 and mv2:FindFirstChild("Bar")
		local grad = bar and bar:FindFirstChild("UIGradient")
		if not grad then return false end
		return grad.Offset.Y == 0
	end)
	_skillCDCache = ok and result
	return _skillCDCache
end

local SPEAR_SPEED_READY = 180
local SPEAR_SPEED_CD    = 170
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
    local team = lp.Team
    local teamName = team and tostring(team.Name) or ""
    if teamName ~= "Killer" then return end
    
    local target, targetType, _targetChar = getSpearTarget()
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

local moonwalkEnabled = false
local moonwalkKey     = Enum.KeyCode.G
local moonwalkAdT     = 0
local moonwalkAdDir   = 1
local AD_INTERVAL     = 0.03

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == moonwalkKey then
		moonwalkEnabled = not moonwalkEnabled
		moonwalkAdT     = 0
		moonwalkAdDir   = 1
		if not moonwalkEnabled then
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
		end
		print("[KKKkhub] MoonWalk: " .. (moonwalkEnabled and "ON" or "OFF"))
	end
end)

RunService.Heartbeat:Connect(function(dt)
	if not state.running then return end
	if not moonwalkEnabled then return end

	moonwalkAdT = moonwalkAdT + dt
	if moonwalkAdT >= AD_INTERVAL then
		moonwalkAdT = 0
		moonwalkAdDir = -moonwalkAdDir

		if moonwalkAdDir > 0 then
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
			VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.A, false, game)
		else
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
			VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.D, false, game)
		end
	end
end)

task.spawn(function()
	while state.running do
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
		task.wait(0.2)
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
	hl.FillColor           = Color3.fromRGB(0, 0, 0)
	hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency    = 0.5
	hl.OutlineTransparency = 0
	hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee             = model
	hl.Parent              = model
	scpEspElements[model] = { highlight = hl }
end

local function isValidSCP(name)
    local lower = string.lower(name)
    local num = lower:match("^scp[%-%s]?(%d+)$")
    if num then
        local n = tonumber(num)
        return n and n >= 1 and n <= 8
    end
    return false
end

local _scpScanTime = 0

local function scanSCPs()
    if os.clock() - _scpScanTime < 2 then return end
    _scpScanTime = os.clock()
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
			for model in pairs(scpEspElements or {}) do removeSCPESP(model) end
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

state.cfg.flashlightAim_maxDist = 30

local _flashlightNotified = false

local function startFlashlightAim()
    if flashlightAimConn then return end
    flashlightAimConn = RunService.RenderStepped:Connect(function(dt)
        if not flashlightAimEnabled then return end
        if not isSurvivor() then return end

        local ch = lp.Character
        if not ch then return end

        local hasFlashlight = ch:FindFirstChild("Flashlight")

        if not hasFlashlight then
            if not _flashlightNotified then
                _flashlightNotified = true
                OasisUI:Notify({ Title = "Flashlight Aimbot", Content = "No Flashlight found in your inventory!", Duration = 5 })
            end
            return
        end

        _flashlightNotified = false

        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

        local cam = workspace.CurrentCamera
        if not cam then return end
        local me = myRoot()
        if not me then return end

        local bestRoot = nil
        local bestDist = math.huge
        local maxDist  = state.cfg.flashlightAim_maxDist or 30

        for _, kRoot in ipairs(killerRoots) do
            if kRoot and kRoot.Parent then
                local d = (me.Position - kRoot.Position).Magnitude
                if d < bestDist and d <= maxDist then
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

-- MAP INFO DISPLAY
local function makeLabel(color, bold)
    local lbl = Drawing.new("Text")
    lbl.Visible = false
    lbl.Text    = ""
    lbl.Size    = 16
    lbl.Font    = bold and Drawing.Fonts.Plex or Drawing.Fonts.Plex
    lbl.Color   = color
    lbl.Outline = true
    return lbl
end

-- prefix labels
local lblMapPrefix    = makeLabel(Color3.fromRGB(0, 255, 0))   -- "Map |"
local lblNamePrefix   = makeLabel(Color3.fromRGB(0, 249, 255))   -- "Name Killer |"
local lblKillerPrefix = makeLabel(Color3.fromRGB(255, 51, 51))   -- "Killer |"
local lblKillerThe = makeLabel(Color3.fromRGB(255, 255, 255))  -- "The"

-- value labels
local lblMapValue    = makeLabel(Color3.fromRGB(255, 255, 255))
local lblNameValue   = makeLabel(Color3.fromRGB(255, 255, 255))
local lblKillerValue = makeLabel(Color3.fromRGB(255, 255, 255))

local function getTextWidth(text, size)
    return #text * (size * 0.55)
end

task.spawn(function()
    while state.running do
        pcall(function()
            local pg       = lp:FindFirstChild("PlayerGui")
            local darkness = pg and pg:FindFirstChild("Darkness")
            local frame    = darkness and darkness:FindFirstChild("Frame")
            local mapInfo  = frame and frame:FindFirstChild("MapInfo")
            local mapTitle = mapInfo and mapInfo:FindFirstChild("MapTitle")
            local mapName  = mapTitle and mapTitle.ContentText or "Unknown"

            local killerPlayer = "none"
            local killerMorph  = "none"
            for _, plr in ipairs(Players:GetPlayers()) do
                local team = plr.Team
                local teamName = team and tostring(team.Name) or ""
                if teamName == "Killer" then
                    killerPlayer = plr.Name
                    local ch = plr.Character
                    if ch then
                        local ok, v = pcall(function() return ch:GetAttribute("MorphedKiller") end)
                        if ok and v then killerMorph = tostring(v) end
                    end
                    break
                end
            end

            local size    = 16
            local startX  = 10
            local y1      = 450
            local y2      = y1 + size + 4
            local y3      = y2 + size + 4
            local gap     = 4

            -- Map | mapName
            local p1Text = "Map | "
            lblMapPrefix.Text     = p1Text
            lblMapPrefix.Position = Vector2.new(startX, y1)
            lblMapPrefix.Visible  = true

            local p1W = getTextWidth(p1Text, size)
            lblMapValue.Text     = mapName
            lblMapValue.Position = Vector2.new(startX + p1W + gap, y1)
            lblMapValue.Visible  = true

            -- Name Killer | killerPlayer
            local p2Text = "Who Killer | "
            lblNamePrefix.Text     = p2Text
            lblNamePrefix.Position = Vector2.new(startX, y2)
            lblNamePrefix.Visible  = true

            local p2W = getTextWidth(p2Text, size)
            lblNameValue.Text     = killerPlayer
            lblNameValue.Position = Vector2.new(startX + p2W + gap, y2)
            lblNameValue.Visible  = true

            -- Killer | The killerMorph
            local p3Text = "Killer | "
            lblKillerPrefix.Text     = p3Text
            lblKillerPrefix.Position = Vector2.new(startX, y3)
            lblKillerPrefix.Visible  = true

            local p3W = getTextWidth(p3Text, size)

            local theText = "The "
            lblKillerThe.Text     = theText
            lblKillerThe.Position = Vector2.new(startX + p3W + gap, y3)
            lblKillerThe.Visible  = true

            local theW = getTextWidth(theText, size)
            lblKillerValue.Text     = killerMorph
            lblKillerValue.Position = Vector2.new(startX + p3W + gap + theW + gap, y3)
            lblKillerValue.Visible  = true
        end)
        task.wait(1.0)
    end
end)

-- Twist of Fate Aimbot
state.cfg.tof_enabled = false
state.cfg.tof_target = "Killer"
state.cfg.tof_maxDist = 50

RunService.RenderStepped:Connect(function()
    if not (state.running and state.cfg.tof_enabled) then return end
    if not isSurvivor() then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local me = myRoot()
    if not me then return end

    local target = nil

    if state.cfg.tof_target == "Killer" then
        local mousePos = UserInputService:GetMouseLocation()
        local best = nil
        local bestDist = math.huge
        for _, kRoot in ipairs(killerRoots) do
            if kRoot and kRoot.Parent then
                local worldDist = (me.Position - kRoot.Position).Magnitude
                if worldDist <= state.cfg.tof_maxDist then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(kRoot.Position)
                    if onScreen and screenPos.Z > 0 then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = kRoot
                        end
                    end
                end
            end
        end
        target = best
    else
        local t = state.render.cachedSurvivorTarget
        if t and t.Parent then
            local worldDist = (me.Position - t.Position).Magnitude
            if worldDist <= state.cfg.tof_maxDist then
                target = t
            end
        end
    end

    if not target or not target.Parent then return end

    local camCF = workspace.CurrentCamera.CFrame
    workspace.CurrentCamera.CFrame = CFrame.lookAt(camCF.Position, target.Position)
end)

-- FULL BRIGHT & NO FOG
local _fullbrightEnabled = false
local _nofogEnabled = false
local originalLighting = {}

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

local savedAtmosphere = {}
local savedColorCorrection = {}

local function applyNoFog()
    Lighting.FogEnd   = 100000
    Lighting.FogStart = 100000
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Atmosphere") then
            savedAtmosphere[#savedAtmosphere + 1] = {
                obj = obj, Density = obj.Density, Offset = obj.Offset, Haze = obj.Haze,
            }
            obj.Density = 0; obj.Offset = 0; obj.Haze = 0
        end
        if obj:IsA("ColorCorrectionEffect") then
            savedColorCorrection[#savedColorCorrection + 1] = {
                obj = obj, Enabled = obj.Enabled,
                Brightness = obj.Brightness, Contrast = obj.Contrast, Saturation = obj.Saturation,
            }
            obj.Brightness = 0; obj.Contrast = 0; obj.Saturation = 0
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = string.lower(obj.Name or "")
        if name:find("fog") or name:find("mist") or name:find("haze") then
            if obj:IsA("BasePart") then
                obj.Transparency = 1; obj.CastShadow = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") then
                obj.Enabled = false
            end
        end
    end
end

local function restoreNoFog()
    Lighting.FogEnd   = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    for _, s in ipairs(savedAtmosphere) do
        pcall(function() s.obj.Density = s.Density; s.obj.Offset = s.Offset; s.obj.Haze = s.Haze end)
    end
    savedAtmosphere = {}
    for _, s in ipairs(savedColorCorrection) do
        pcall(function()
            s.obj.Enabled = s.Enabled; s.obj.Brightness = s.Brightness
            s.obj.Contrast = s.Contrast; s.obj.Saturation = s.Saturation
        end)
    end
    savedColorCorrection = {}
end

Lighting.Changed:Connect(function(prop)
    if not (_fullbrightEnabled or _nofogEnabled) then return end
    if _fullbrightEnabled and (prop == "Brightness" or prop == "ClockTime" or prop == "Ambient" or prop == "OutdoorAmbient") then
        if Lighting.Brightness < 1.5 then applyFullBright() end
    end
end)

Lighting.ChildAdded:Connect(function(child)
    if not _nofogEnabled then return end
    task.wait(0.1)
    if child:IsA("Atmosphere") then
        child.Density = 0; child.Offset = 0; child.Haze = 0
    elseif child:IsA("ColorCorrectionEffect") then
        child.Brightness = 0; child.Contrast = 0; child.Saturation = 0
    end
end)

task.spawn(function()
    while state.running do
        task.wait(2)
        pcall(function()
            if _fullbrightEnabled then applyFullBright() end
            if _nofogEnabled then applyNoFog() end
        end)
    end
end)

local genEspEnabled = false
local genEspElements = {}

local function removeGenESP(model)
    local e = genEspElements[model]
    if not e then return end
    pcall(function() e.highlight:Destroy() end)
    pcall(function() e.nameText:Remove() end)
    pcall(function() e.infoText:Remove() end)
    pcall(function() e.barBg:Remove() end)
    pcall(function() e.barFill:Remove() end)
    genEspElements[model] = nil
end

local bearTrapEspEnabled = false
local bearTrapEspElements = {}
local _bearTrapScanTime = 0

local function removeBearTrapESP(model)
    local e = bearTrapEspElements[model]
    if not e then return end
    pcall(function() e.highlight:Destroy() end)
    pcall(function() e.nameText:Remove() end)
    pcall(function() e.distText:Remove() end)
    bearTrapEspElements[model] = nil
end

local function createBearTrapESP(model)
    if bearTrapEspElements[model] then return end
    local root = model:FindFirstChild("RootPart")
        or model.PrimaryPart
        or model:FindFirstChildOfClass("MeshPart")
        or model:FindFirstChildOfClass("BasePart")
    if not root then return end
    local nameText = Drawing.new("Text")
    nameText.Visible   = false
    nameText.Text      = "BearTrap"
    nameText.Size      = 14
    nameText.Font      = Drawing.Fonts.Plex
    nameText.Color     = Color3.fromRGB(255, 255, 255)
    nameText.Outline   = true
    nameText.Center    = true
    local distText = Drawing.new("Text")
    distText.Visible   = false
    distText.Text      = ""
    distText.Size      = 12
    distText.Font      = Drawing.Fonts.Plex
    distText.Color     = Color3.fromRGB(200, 200, 200)
    distText.Outline   = true
    distText.Center    = true
    local barBg = Drawing.new("Square")
    barBg.Visible      = false
    barBg.Filled       = true
    barBg.Color        = Color3.fromRGB(40, 40, 40)
    barBg.Transparency = 0.4
    barBg.Thickness    = 1
    local hl = Instance.new("Highlight")
    hl.FillColor           = Color3.fromRGB(0, 0, 0)
    hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency    = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee             = model
    hl.Parent              = model
    bearTrapEspElements[model] = {
        highlight = hl,
        nameText  = nameText,
        distText  = distText,
        barBg     = barBg,
        rootPart  = root,
    }
end

local function createGenESP(model, index)
    if genEspElements[model] then return end
    local root = model:FindFirstChild("RootPart")
        or model.PrimaryPart
        or model:FindFirstChildOfClass("MeshPart")
        or model:FindFirstChildOfClass("BasePart")
    if not root then return end
    local nameText = Drawing.new("Text")
    nameText.Visible   = false
    nameText.Text      = model.Name
    nameText.Size      = 14
    nameText.Font      = Drawing.Fonts.Plex
    nameText.Color     = Color3.fromRGB(255, 255, 255)
    nameText.Outline   = true
    nameText.Center    = true
    local infoText = Drawing.new("Text")
    infoText.Visible   = false
    infoText.Text      = "0% | idle"
    infoText.Size      = 12
    infoText.Font      = Drawing.Fonts.Plex
    infoText.Color     = Color3.fromRGB(200, 200, 200)
    infoText.Outline   = true
    infoText.Center    = true
    local barBg = Drawing.new("Square")
    barBg.Visible      = false
    barBg.Filled       = true
    barBg.Color        = Color3.fromRGB(40, 40, 40)
    barBg.Transparency = 0.4
    barBg.Thickness    = 1
    local barFill = Drawing.new("Square")
    barFill.Visible      = false
    barFill.Filled       = true
    barFill.Color        = Color3.fromRGB(255, 255, 255)
    barFill.Transparency = 1
    barFill.Thickness    = 1
    local hl = Instance.new("Highlight")
    hl.FillColor           = Color3.fromRGB(0, 0, 0)
    hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency    = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee             = model
    hl.Parent              = model
    genEspElements[model] = {
        highlight = hl,
        nameText  = nameText,
        infoText  = infoText,
        barBg     = barBg,
        barFill   = barFill,
        rootPart  = root,
    }
end

local _genScanCache = nil
local _genScanTime  = 0
local _genCounter   = 0
local _genPrevProgress = {}
local _genIsBreaking = {}

local function initialScanGen()
    if _genScanCache and os.clock() - _genScanTime < 3 then return end
    _genScanTime = os.clock()
    local found = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            found[obj] = true
            if not genEspElements[obj] then
                _genCounter = _genCounter + 1
                createGenESP(obj, _genCounter)
            end
        end
    end

    -- path resources
    local resources = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("resources")
    if resources then
        local generatorsFolder = resources:FindFirstChild("Generators")
        if generatorsFolder then
            for _, obj in ipairs(generatorsFolder:GetChildren()) do
                if obj:IsA("Model") and obj.Name == "Generator" then
                    found[obj] = true
                    if not genEspElements[obj] then
                        _genCounter = _genCounter + 1
                        createGenESP(obj, _genCounter)
                    end
                end
            end
        end
    end

    for model in pairs(genEspElements) do
        if not found[model] then removeGenESP(model) end
    end
    _genScanCache = found
end

-- loop check breaking 
task.spawn(function()
    while state.running do
        if genEspEnabled then
            for model in pairs(genEspElements) do
                if model.Parent then
                    local repair = model:GetAttribute("RepairProgress") or 0
                    local pct    = math.clamp(repair, 0, 100)
                    local prevPct = _genPrevProgress[model]
                    if prevPct ~= nil then
                        _genIsBreaking[model] = pct < prevPct
                    else
                        _genIsBreaking[model] = false
                    end
                    _genPrevProgress[model] = pct
                else
                    _genPrevProgress[model] = nil
                    _genIsBreaking[model] = nil
                end
            end
        end
        task.wait(0.1)
    end
end)

-- loop render ESP 
task.spawn(function()
    local cam = workspace.CurrentCamera
    while state.running do
        if genEspEnabled then
            pcall(initialScanGen)
            pcall(function()
                cam = workspace.CurrentCamera
                for model, elem in pairs(genEspElements) do
                    if not model.Parent then
                        removeGenESP(model)
                        _genPrevProgress[model] = nil
                        _genIsBreaking[model] = nil
                    else
                        local repair    = model:GetAttribute("RepairProgress") or 0
                        local repairing = model:GetAttribute("PlayersRepairingCount") or 0
                        local paused    = model:GetAttribute("ProgressPaused")
                        local pct       = math.clamp(repair, 0, 100)
                        local displayPct = math.floor(pct)
                        local isBreaking = _genIsBreaking[model] or false

                        if pct >= 100 then
                            elem.nameText.Visible = false
                            elem.infoText.Visible = false
                            elem.barBg.Visible    = false
                            elem.barFill.Visible  = false
                            if elem.highlight then elem.highlight.Enabled = false end
                        else
                            local rootPos = elem.rootPart.Position + Vector3.new(0, 3, 0)
                            local screenPos, onScreen = cam:WorldToViewportPoint(rootPos)

                            if not onScreen or screenPos.Z < 0 then
                                elem.nameText.Visible = false
                                elem.infoText.Visible = false
                                elem.barBg.Visible    = false
                                elem.barFill.Visible  = false
                            else
                                local sx = screenPos.X
                                local sy = screenPos.Y
                                local barW = 50
                                local barH = 3

                                elem.barBg.Visible   = true
                                elem.barBg.Size      = Vector2.new(barW, barH)
                                elem.barBg.Position  = Vector2.new(sx - barW/2, sy)

                                local fillW = math.max(1, math.floor(barW * (pct / 100)))
                                elem.barFill.Visible  = true
                                elem.barFill.Size     = Vector2.new(fillW, barH)
                                elem.barFill.Position = Vector2.new(sx - barW/2, sy)

                                elem.nameText.Visible  = true
                                elem.nameText.Position = Vector2.new(sx, sy - 16)
                                elem.infoText.Visible  = true
                                elem.infoText.Position = Vector2.new(sx, sy + barH + 2)

                                if repairing > 0 and paused then
                                    elem.barFill.Color  = Color3.fromRGB(120, 120, 120)
                                    elem.nameText.Color = Color3.fromRGB(255, 255, 255)
                                    elem.infoText.Text  = displayPct .. "% | " .. repairing .. "P repairing | paused"
                                elseif repairing > 0 then
                                    elem.barFill.Color  = Color3.fromRGB(180, 180, 180)
                                    elem.nameText.Color = Color3.fromRGB(255, 255, 255)
                                    elem.infoText.Text  = displayPct .. "% | " .. repairing .. " Players repairing"
                                elseif isBreaking and paused then
                                    elem.barFill.Color  = Color3.fromRGB(200, 40, 40)
                                    elem.nameText.Color = Color3.fromRGB(255, 80, 80)
                                    elem.infoText.Text  = displayPct .. "% | breaking | paused"
                                elseif isBreaking then
                                    elem.barFill.Color  = Color3.fromRGB(255, 60, 60)
                                    elem.nameText.Color = Color3.fromRGB(255, 80, 80)
                                    elem.infoText.Text  = displayPct .. "% | breaking"
                                elseif paused then
                                    elem.barFill.Color  = Color3.fromRGB(80, 80, 80)
                                    elem.nameText.Color = Color3.fromRGB(200, 200, 200)
                                    elem.infoText.Text  = displayPct .. "% | idle | paused"
                                else
                                    elem.barFill.Color  = Color3.fromRGB(255, 255, 255)
                                    elem.nameText.Color = Color3.fromRGB(200, 200, 200)
                                    elem.infoText.Text  = displayPct .. "% | idle"
                                end

                                if elem.highlight then elem.highlight.Enabled = true end
                            end
                        end
                    end
                end
            end)
        else
            for model, elem in pairs(genEspElements) do
                pcall(function()
                    elem.nameText.Visible = false
                    elem.infoText.Visible = false
                    elem.barBg.Visible    = false
                    elem.barFill.Visible  = false
                end)
                removeGenESP(model)
                _genPrevProgress[model] = nil
                _genIsBreaking[model] = nil
            end
        end
        task.wait(0.01)
    end
end)

local function initialScanBearTrap()
    if os.clock() - _bearTrapScanTime < 3 then return end
    _bearTrapScanTime = os.clock()
    local found = {}
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return end
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj:IsA("Model") then
            local lower = string.lower(obj.Name)
            if lower == "beartrap" or lower == "bear_trap" then
                found[obj] = true
                if not bearTrapEspElements[obj] then
                    createBearTrapESP(obj)
                end
            end
        end
    end
    for model in pairs(bearTrapEspElements) do
        if not found[model] then removeBearTrapESP(model) end
    end
end

task.spawn(function()
    local cam = workspace.CurrentCamera
    while state.running do
        if bearTrapEspEnabled then
            pcall(initialScanBearTrap)
            pcall(function()
                cam = workspace.CurrentCamera
                local me = myRoot()
                local myPos = me and me.Position
                for model, elem in pairs(bearTrapEspElements) do
                    if not model.Parent then
                        removeBearTrapESP(model)
                        continue
                    end

                    local armed = model:GetAttribute("Armed")

                    if not armed then
                        elem.nameText.Visible = false
                        elem.distText.Visible = false
                        elem.barBg.Visible    = false
                        if elem.highlight then elem.highlight.Enabled = false end
                        continue
                    end

                    local rootPos = elem.rootPart.Position + Vector3.new(0, 1.5, 0)
                    local screenPos, onScreen = cam:WorldToViewportPoint(rootPos)

                    if not onScreen or screenPos.Z < 0 then
                        elem.nameText.Visible = false
                        elem.distText.Visible = false
                        elem.barBg.Visible    = false
                        if elem.highlight then elem.highlight.Enabled = false end
                        continue
                    end

                    local sx = screenPos.X
                    local sy = screenPos.Y
                    local dist = myPos and (myPos - elem.rootPart.Position).Magnitude or 0

                    local barW = 50
                    local barH = 3

                    elem.barBg.Visible   = true
                    elem.barBg.Size      = Vector2.new(barW, barH)
                    elem.barBg.Position  = Vector2.new(sx - barW/2, sy)

                    elem.nameText.Visible  = true
                    elem.nameText.Position = Vector2.new(sx, sy - 16)
                    elem.nameText.Color    = Color3.fromRGB(255, 80, 80)

                    elem.distText.Visible  = true
                    elem.distText.Text     = string.format("%.0f studs", dist)
                    elem.distText.Position = Vector2.new(sx, sy + barH + 2)

                    if elem.highlight then elem.highlight.Enabled = true end
                end
            end)
        else
            for model, elem in pairs(bearTrapEspElements) do
                pcall(function()
                    elem.nameText.Visible = false
                    elem.distText.Visible = false
                    elem.barBg.Visible    = false
                end)
                removeBearTrapESP(model)
            end
        end
        task.wait(0.01)
    end
end)

-- PUMPKIN ESP
local pumpkinEspEnabled = false
local pumpkinEspElements = {}
local _pumpkinScanTime = 0

local function removePumpkinESP(model)
    local e = pumpkinEspElements[model]
    if not e then return end
    pcall(function() e.highlight:Destroy() end)
    pumpkinEspElements[model] = nil
end

local function createPumpkinESP(model)
    if pumpkinEspElements[model] then return end
    local root = model.PrimaryPart
        or model:FindFirstChildOfClass("MeshPart")
        or model:FindFirstChildOfClass("BasePart")
    if not root then return end
    local hl = Instance.new("Highlight")
    hl.FillColor           = Color3.fromRGB(0, 0, 0)
    hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency    = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee             = model
    hl.Parent              = model
    pumpkinEspElements[model] = { highlight = hl, rootPart = root }
end

local function scanPumpkins()
    if os.clock() - _pumpkinScanTime < 3 then return end
    _pumpkinScanTime = os.clock()
    local pumpkinFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Pumpkins")
    if not pumpkinFolder then return end
    local found = {}
    for _, obj in ipairs(pumpkinFolder:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            found[obj] = true
            if not pumpkinEspElements[obj] then createPumpkinESP(obj) end
        end
    end
    for model in pairs(pumpkinEspElements) do
        if not found[model] then removePumpkinESP(model) end
    end
end

task.spawn(function()
    while state.running do
        if pumpkinEspEnabled then
            pcall(scanPumpkins)
            for model, elem in pairs(pumpkinEspElements) do
                if not model.Parent then
                    removePumpkinESP(model)
                else
                    if elem.highlight then elem.highlight.Enabled = true end
                end
            end
        else
            for model in pairs(pumpkinEspElements or {}) do removePumpkinESP(model) end
        end
        task.wait(0.5)
    end
end)

-- AUTO BREAK GEN
local autoBreakGenAura_enabled = false
local autoBreakGenAura_radius = 20

local function isPointOccupied(point)
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local ok, dist = pcall(function()
                    return (root.Position - point.Position).Magnitude
                end)
                if ok and dist <= 5 then
                    return true
                end
            end
        end
    end
    return false
end

local function breakGen(point)
    pcall(function()
        local BreakEvent  = game:GetService("ReplicatedStorage").Remotes.Generator.BreakGenEvent
        local CommitEvent = game:GetService("ReplicatedStorage").Remotes.Generator.BreakGenCommit
        BreakEvent:FireServer(point)
        task.wait(0.1)
        CommitEvent:FireServer(point)
    end)
end

local function getGenPoints(genModel)
    local points = {}
    for _, obj in ipairs(genModel:GetDescendants()) do
        if obj.Name:find("GeneratorPoint") and obj:IsA("BasePart") then
            points[#points + 1] = obj
        end
    end
    return points
end

task.spawn(function()
    while state.running do
        if autoBreakGenAura_enabled and not isSurvivor() then
            pcall(function()
                local me = myRoot()
                if not me then return end
                local gens = workspace.Map.Generators:GetChildren()
                for _, gen in ipairs(gens) do
                    local repair = gen:GetAttribute("RepairProgress") or 0
                    if repair < 100 then
                        local points = getGenPoints(gen)
                        for _, point in ipairs(points) do
                            local ok, dist = pcall(function()
                                return (me.Position - point.Position).Magnitude
                            end)
                            if ok and dist <= autoBreakGenAura_radius and not isPointOccupied(point) then
                                breakGen(point)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Vault Pallet ESP
local function addBoxOutline(part)
    if part:FindFirstChildOfClass("BoxHandleAdornment") then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = part
    box.Color3 = Color3.fromRGB(255, 255, 255)
    box.Transparency = 0.5
    box.Size = part.Size
    box.SizeRelativeOffset = Vector3.new(0, 0, 0)
    box.AlwaysOnTop = true
    box.ZIndex = 0
    box.Parent = part
end

local function addHighlight(parent, fillColor, outlineColor)
    if parent:FindFirstChildOfClass("Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = fillColor or Color3.fromRGB(0, 0, 0)
    highlight.OutlineColor = outlineColor or Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = parent
    highlight.Parent = parent
end

local vaultEspEnabled = false
local palletEspEnabled = false
local vaultEspElements = {}
local palletEspElements = {}

local function removeVaultESP(obj)
    local e = vaultEspElements[obj]
    if not e then return end
    pcall(function() e.highlight:Destroy() end)
    pcall(function()
        local box = obj:FindFirstChildOfClass("BoxHandleAdornment")
        if box then box:Destroy() end
    end)
    vaultEspElements[obj] = nil
end

local function removePalletESP(model)
    local e = palletEspElements[model]
    if not e then return end
    pcall(function() e.highlight:Destroy() end)
    palletEspElements[model] = nil
end

local function createVaultESP(obj)
    if vaultEspElements[obj] then return end
    if not obj or not obj.Parent then return end
    addBoxOutline(obj)
    local hl = Instance.new("Highlight")
    hl.FillColor           = Color3.fromRGB(0, 0, 0)
    hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency    = 0.8
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee             = obj
    hl.Parent              = obj
    vaultEspElements[obj] = { highlight = hl }
end

local function createPalletESP(model)
    if palletEspElements[model] then return end
    if not model or not model.Parent then return end
    addHighlight(model)
    local hl = model:FindFirstChildOfClass("Highlight")
    palletEspElements[model] = { highlight = hl }
end

local function isPalletObj(obj)
    if not obj:IsA("Model") then return false end
    local lname = string.lower(obj.Name)
    return lname == "newpallet"
end

local function isVaultObj(obj)
    if obj.ClassName == "Part" and obj.Name == "Bottom" then
        if obj.Parent and obj.Parent.Name == "Window" then return true end
    end
    return false
end

local _mapEspConns = {}

local function clearMapEspConns()
    for _, c in ipairs(_mapEspConns) do pcall(c.Disconnect, c) end
    table.clear(_mapEspConns)
end

local function setupMapEspListeners(mapFolder)
    clearMapEspConns()
    local conn = mapFolder.DescendantAdded:Connect(function(obj)
        task.wait()
        if vaultEspEnabled and isVaultObj(obj) then
            createVaultESP(obj)
        end
        if palletEspEnabled and isPalletObj(obj) then
            createPalletESP(obj)
        end
    end)
    table.insert(_mapEspConns, conn)
    local conn2 = mapFolder.DescendantRemoving:Connect(function(obj)
        if vaultEspElements[obj] then removeVaultESP(obj) end
        if palletEspElements[obj] then removePalletESP(obj) end
    end)
    table.insert(_mapEspConns, conn2)
end

local function scanVaultAndPallet()
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return end

    setupMapEspListeners(mapFolder)

    if vaultEspEnabled then
        for _, obj in ipairs(mapFolder:GetDescendants()) do
            if isVaultObj(obj) then createVaultESP(obj) end
        end
    else
        for obj in pairs(vaultEspElements) do removeVaultESP(obj) end
    end

    if palletEspEnabled then
        for _, obj in ipairs(mapFolder:GetDescendants()) do
            if isPalletObj(obj) then createPalletESP(obj) end
        end
    else
        for model in pairs(palletEspElements) do removePalletESP(model) end
    end
end

workspace.ChildAdded:Connect(function(child)
    if child.Name == "Map" then
        task.wait(1)
        for obj in pairs(vaultEspElements) do removeVaultESP(obj) end
        for model in pairs(palletEspElements) do removePalletESP(model) end
        if vaultEspEnabled or palletEspEnabled then
            pcall(scanVaultAndPallet)
        end
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if child.Name == "Map" then
        clearMapEspConns()
    end
end)

pcall(scanVaultAndPallet)

task.spawn(function()
    while state.running do
        if vaultEspEnabled or palletEspEnabled then
            for obj in pairs(vaultEspElements) do
                if not obj.Parent then removeVaultESP(obj) end
            end
            for model in pairs(palletEspElements) do
                if not model.Parent then removePalletESP(model) end
            end
        end
        task.wait(3.0)
    end
end)

-- Pallet Counter GUI
local palletCountGui = Instance.new("ScreenGui")
palletCountGui.Name           = "KKKkhub_PalletCount"
palletCountGui.ResetOnSpawn   = false
palletCountGui.DisplayOrder   = 1001
palletCountGui.IgnoreGuiInset = true
palletCountGui.Parent         = game:GetService("CoreGui")

local palletCountFrame = Instance.new("Frame")
palletCountFrame.BackgroundColor3    = Color3.fromRGB(0, 0, 0)
palletCountFrame.BackgroundTransparency = 0.5
palletCountFrame.Size = UDim2.new(0, 240, 0, 40)
palletCountFrame.Position = UDim2.new(0.5, -120, 0, 10)
palletCountFrame.BorderSizePixel     = 0
palletCountFrame.Parent              = palletCountGui

Instance.new("UICorner", palletCountFrame).CornerRadius = UDim.new(0, 6)

local palletCountLabel = Instance.new("TextLabel")
palletCountLabel.BackgroundTransparency = 1
palletCountLabel.Size                   = UDim2.new(1, 0, 1, 0)
palletCountLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
palletCountLabel.TextStrokeTransparency = 0
palletCountLabel.Font                   = Enum.Font.GothamBold
palletCountLabel.TextSize               = 15
palletCountLabel.Text                   = "Pallets: 0"
palletCountLabel.Parent                 = palletCountFrame

-- loop update pallet count
task.spawn(function()
    while state.running do
        pcall(function()
            local count = 0
            local dropping = 0

            local function countFromFolder(folder)
                if not folder then return end
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") then
                        local palletState    = obj:GetAttribute("PalletState")
                        local palletDropping = obj:GetAttribute("PalletDropping")
                        if palletState ~= "Broken" then
                            count = count + 1
                            if palletDropping == true then
                                dropping = dropping + 1
                            end
                        end
                    end
                end
            end

            local map = workspace:FindFirstChild("Map")
            if map then
                countFromFolder(map:FindFirstChild("pallets"))
                local resources = map:FindFirstChild("resources")
                if resources then
                    countFromFolder(resources:FindFirstChild("Pallets"))
                end
            end

            palletCountLabel.Text = "Pallets: " .. count .. "  |  Dropped: " .. dropping
        end)
        task.wait(0.5)
    end
end)

-- OasisUI 
local SOURCE = "https://raw.githubusercontent.com/Mold53/OasisUI/main/dist/OasisUI.lua"
OasisUI = getgenv().OasisUI_Dev or loadstring(game:HttpGet(SOURCE))()

state.ui.Window = OasisUI:CreateWindow({
	Title     = "KKKK Hub",
	Subtitle  = "v1.2",
	Icon      = "swords",
	Folder    = "KKKK-Hub",
	Tags      = { "v1.2" },
	ToggleKey = Enum.KeyCode.RightShift,
})

state.ui.Tabs = {
	Changelog = state.ui.Window:Tab({ Title = "Changelog", Icon = "mail-check" }),
	Survivor  = state.ui.Window:Tab({ Title = "Survivor", Icon = "user" }),
	OP        = state.ui.Window:Tab({ Title = "OP", Icon = "zap" }),
	Killer    = state.ui.Window:Tab({ Title = "Killer", Icon = "swords" }),
	Aimbot    = state.ui.Window:Tab({ Title = "Aimbot", Icon = "crosshair" }),
	ESP       = state.ui.Window:Tab({ Title = "ESP", Icon = "eye" }),
	World     = state.ui.Window:Tab({ Title = "World", Icon = "globe" }),
}

local function changelog(title, side, lines)
	local section = state.ui.Tabs.Changelog:Section({ Title = "Update " .. title, Icon = "mail", Side = side })
	for _, text in ipairs(lines) do
		section:Label({ Text = text })
	end
end

changelog("17 Aug", "Left", {
	"/ Improve Anti Stun +++",
	"/ Improve Moonwalk  press G",
	"+ Add SCP ESP",
	"+ Add Legit Mode For Auto Parry",
	"/ Optimize all ESP",
})
changelog("18 Aug", "Right", {
	"/ Improve Esp",
	"+ Add Silent Aim Veil/Gun",
	"+ Add Fov Circle",
	"+ Add Silent Aim Fov Slider",
	"+ Add Fast Skillcheck Speed",
	"+ Add Skillcheck Speed Value Slider",
	"+ Add Vault Speed",
	"+ Add Vault Speed Value Slider",
})
changelog("20 Aug", "Left", {
	"+ Add Vault Speed ( Killer )",
	"+ Add Vault Speed Value Slider ( Killer )",
	"+ Add Tab Aimbot",
	"+ Add Silent Aim The Cure",
	"+ Add Silent Aim Twist of Fate",
	"+ Add Aimbot FlashLight",
	"+ Add Auto Drop Pallet When Killer Carry",
	"+ Add ESP Generator",
	"+ Move Spear Aimbot to the Aimbot tab",
	"/ Improve Aimbot The Veil 99% Hit",
	"/ Optimize Esp Scp",
	"* Fix ESP Generator",
	"- Remove spear_gravity_ready Slider",
	"- Remove spear_gravity_cd Slider",
})
changelog("21 Oct", "Right", {
	"+ Auto Break Gen Aura",
	"+ Auto Drop Pallet Other Carried",
	"/ Change Style Gen Esp",
	"/ Optimize All Esp",
	"/ Improve Auto Parry",
	"/ Improve MoonWalk",
	"/ Improve NoFog",
	"/ Force Enable Show Distance",
	"- Remove Side Panel (Status)",
	"/ ESP Now Realtime (Heartbeat)",
})
changelog("23 Oct", "Right", {
	"+ Add OP Funtion",
})
changelog("25 Oct", "Left", {
	"+ Add Esp BearTrap",
	"+ Add Esp Pumpkin",
	"+ Add Skillcheck BearTrap",
	"+ Add Auto Parry New Killer",
	"+ Add Heal Self",
	"/ Improve FullBright",
	"/ Improve NoFog",
	"/ Improve Auto Parry",
	"- Remove Instant Vault Survivor",
	"- Remove Auto DropPallet Self",
	"- Remove Auto DropPallet Other",
})
changelog("26 Oct", "Right", {
	"+ ESP Bot",
	"+ Show Map/WhoKiller/Killer",
	"+ ESP Pallet",
	"+ ESP Vault",
	"+ ESP Gen Breaking",
	"+ Anti Fall Damage",
	"/ Improve ESP",
	"/ Change ESP Theme",
	"/ Change Silent Aim Gun to Aimbot",
})
changelog("28 Oct", "Right", {
	"+ Pallet / Drop GUI",
	"+ Status Palyer Knocked",
	"/ Improve ESP Vault",
	"/ Improve ESP Pallet",
    "/ Change UI !!!!!!",
	"- Remove ESP Spear",
})

state.ui.Tabs.Changelog:Section({ Title = "Script", Icon = "power", Side = "Left" }):Button({
	Title    = "Unload Script",
	Icon     = "power",
	Style    = "Danger",
	Confirm  = "Stop all loops and destroy the UI?",
	Callback = function() OasisUI:Unload() end,
})

-- Survivor 
state.ui.PalletBox = state.ui.Tabs.Survivor:Section({ Title = "Pallet Killer Stun", Icon = "shield", Side = "Left" })
state.ui.PalletBox:Toggle({
	Title    = "Auto Drop Pallet",
	Default  = state.cfg.p_enabled,
	Callback = function(v) state.cfg.p_enabled = v end,
})
state.ui.PalletBox:Toggle({
	Title    = "Anti Bait",
	Default  = state.cfg.antiBait,
	Callback = function(v) state.cfg.antiBait = v end,
})
state.ui.PalletBox:Slider({
	Title    = "Stun Reach",
	Default  = state.cfg.stunReach,
	Min      = 4, Max = 20, Step = 1, Suffix = " studs",
	Callback = function(v) state.cfg.stunReach = v end,
})
state.ui.PalletBox:Slider({
	Title    = "Interact Radius",
	Default  = state.cfg.interactionRadius,
	Min      = 4, Max = 25, Step = 1, Suffix = " studs",
	Callback = function(v) state.cfg.interactionRadius = v end,
})
state.ui.PalletBox:Slider({
	Title    = "Space Cooldown",
	Default  = state.cfg.cooldown,
	Min      = 0.05, Max = 1.5, Step = 0.01, Suffix = "s",
	Callback = function(v) state.cfg.cooldown = v end,
})

state.ui.SkillBox = state.ui.Tabs.Survivor:Section({ Title = "Skillcheck", Icon = "gauge", Side = "Right" })
state.ui.SkillBox:Toggle({
	Title    = "Auto Skillcheck",
	Default  = state.cfg.sc_enabled,
	Callback = function(v) state.cfg.sc_enabled = v end,
})
state.ui.SkillBox:Toggle({
	Title    = "Fast Skillcheck Speed",
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
state.ui.SkillBox:Slider({
	Title    = "Skillcheck Speed Value",
	Default  = state.cfg.sc_speed_value,
	Min      = 0.5, Max = 10, Step = 0.1,
	Callback = function(v) state.cfg.sc_speed_value = v end,
})
state.ui.SkillBox:Slider({
	Title    = "Hit Zone Offset",
	Default  = state.cfg.sc_offset,
	Min      = 80, Max = 130, Step = 1, Suffix = "°",
	Callback = function(v) state.cfg.sc_offset = v end,
})
state.ui.SkillBox:Slider({
	Title    = "Lead Angle",
	Default  = state.cfg.sc_lead,
	Min      = 0, Max = 10, Step = 1, Suffix = "°",
	Callback = function(v) state.cfg.sc_lead = v end,
})

state.ui.AutoCrouchBox = state.ui.Tabs.Survivor:Section({ Title = "Anti Skill", Icon = "shield-check", Side = "Right" })
state.ui.AutoCrouchBox:Toggle({
	Title    = "Anti Skill The Abysswalker",
	Default  = state.cfg.autoCrouch_enabled,
	Callback = function(v) state.cfg.autoCrouch_enabled = v end,
})
state.ui.AutoCrouchBox:Slider({
	Title    = "Crouch Delay",
	Default  = state.cfg.autoCrouch_delay,
	Min      = 0, Max = 0.5, Step = 0.01, Suffix = "s",
	Callback = function(v) state.cfg.autoCrouch_delay = v end,
})
state.ui.AutoCrouchBox:Toggle({
	Title    = "Crouch Humanizer",
	Default  = state.cfg.autoCrouch_humanize,
	Callback = function(v) state.cfg.autoCrouch_humanize = v end,
})
state.ui.AutoCrouchBox:Slider({
	Title    = "Crouch Distance",
	Default  = state.cfg.autoCrouch_distance,
	Min      = 5, Max = 50, Step = 1, Suffix = " studs",
	Callback = function(v) state.cfg.autoCrouch_distance = v end,
})
state.ui.AutoCrouchBox:Slider({
	Title    = "Crouch Duration",
	Default  = state.cfg.autoCrouch_duration,
	Min      = 0, Max = 3, Step = 0.1, Suffix = "s",
	Callback = function(v) state.cfg.autoCrouch_duration = v end,
})

state.ui.ParryBox = state.ui.Tabs.Survivor:Section({ Title = "Anti Hit", Icon = "swords", Side = "Left" })
state.ui.ParryBox:Toggle({
	Title    = "Auto Parry",
	Default  = state.cfg.ap_enabled,
	Callback = function(v) state.cfg.ap_enabled = v end,
})
state.ui.ParryBox:Toggle({
	Title    = "Legit Mode",
	Default  = state.cfg.ap_legitMode,
	Callback = function(v) state.cfg.ap_legitMode = v end,
})
state.ui.ParryBox:Slider({
	Title    = "Legit Min Delay",
	Default  = state.cfg.ap_legitMinDelay,
	Min      = 0, Max = 0.3, Step = 0.01, Suffix = "s",
	Callback = function(v) state.cfg.ap_legitMinDelay = v end,
})
state.ui.ParryBox:Slider({
	Title    = "Legit Max Delay",
	Default  = state.cfg.ap_legitMaxDelay,
	Min      = 0.05, Max = 0.5, Step = 0.01, Suffix = "s",
	Callback = function(v) state.cfg.ap_legitMaxDelay = v end,
})

-- OP 
state.ui.OPBox = state.ui.Tabs.OP:Section({ Title = "OP Functions", Icon = "zap", Side = "Left" })
state.ui.OPBox:Toggle({
	Title    = "God Mode",
	Default  = state.cfg.godmode_enabled,
	Callback = function(v) state.cfg.godmode_enabled = v end,
})
state.ui.OPBox:Toggle({
	Title    = "Anti Fall Damage",
	Default  = state.cfg.antiFallDamage_enabled,
	Callback = function(v) state.cfg.antiFallDamage_enabled = v end,
})
state.cfg.autoHeal_enabled = false
state.ui.OPBox:Toggle({
	Title    = "Auto Heal Self",
	Default  = false,
	Callback = function(v) state.cfg.autoHeal_enabled = v end,
})

-- Auto heal loop
task.spawn(function()
	while state.running do
		if state.cfg.autoHeal_enabled and isSurvivor() then
			pcall(healSelf)
		end
		task.wait(0.3)
	end
end)

--  Killer 
state.ui.FlashBox = state.ui.Tabs.Killer:Section({ Title = "Anti Flashlight", Icon = "flashlight-off", Side = "Right" })
state.ui.FlashBox:Toggle({
	Title    = "No Flash Blind",
	Default  = state.cfg.noFlashBlind,
	Callback = function(v) state.cfg.noFlashBlind = v end,
})

state.ui.BreakSpeedBox = state.ui.Tabs.Killer:Section({ Title = "Break Speed", Icon = "hammer", Side = "Right" })
state.ui.BreakSpeedBox:Toggle({
	Title    = "Enable Break Speed",
	Default  = state.cfg.breakSpeed_enabled,
	Callback = function(v) state.cfg.breakSpeed_enabled = v end,
})
state.ui.BreakSpeedBox:Slider({
	Title    = "Break Speed Value",
	Default  = state.cfg.breakSpeed_value,
	Min      = 1, Max = 10, Step = 0.1,
	Callback = function(v) state.cfg.breakSpeed_value = v end,
})

state.ui.BreakGenBox = state.ui.Tabs.Killer:Section({ Title = "Auto Break Generator", Icon = "wrench", Side = "Left" })
state.ui.BreakGenBox:Toggle({
	Title    = "Auto Break Gen Aura",
	Default  = false,
	Callback = function(v)
		autoBreakGenAura_enabled = v
	end,
})
state.ui.BreakGenBox:Slider({
	Title    = "Aura Radius",
	Default  = 20,
	Min      = 5, Max = 60, Step = 1, Suffix = " studs",
	Callback = function(v)
		autoBreakGenAura_radius = v
	end,
})

state.ui.MaskedBox = state.ui.Tabs.Killer:Section({ Title = "The Masked", Icon = "venetian-mask", Side = "Left" })
state.ui.maskList = { "Alex", "Brandon", "Cobra", "Rabbit", "Richter", "Richard", "Tony" }
state.ui.MaskedBox:Dropdown({
	Title    = "Select Mask",
	Default  = state.cfg.selectMask,
	Values   = state.ui.maskList,
	Callback = function(v)
		state.cfg.selectMask = v
	end,
})
state.ui.MaskedBox:Button({
	Title    = "Use Mask Power",
	Callback = function()
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

state.ui.Swiftbox = state.ui.Tabs.Killer:Section({ Title = "Vault", Icon = "door-open", Side = "Left" })
state.ui.Swiftbox:Toggle({
	Title    = "Vault Speed (Swift)",
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
state.ui.Swiftbox:Slider({
	Title    = "Swift Speed Value",
	Default  = 1.5,
	Min      = 1, Max = 10, Step = 0.1,
	Callback = function(v) state.cfg.swiftspeed_value = v end,
})

-- Aimbot 
state.ui.aimbots = state.ui.Tabs.Aimbot:Section({ Title = "Twist of Fate", Icon = "target", Side = "Left" })
state.ui.aimbots:Toggle({
	Title    = "Aimbot Gun",
	Default  = false,
	Callback = function(v) state.cfg.tof_enabled = v end,
})
state.ui.aimbots:Dropdown({
	Title    = "Lock Target",
	Default  = "Survivor",
	Values   = { "Survivor", "Killer" },
	Callback = function(v) state.cfg.tof_target = v end,
})
state.ui.aimbots:Slider({
	Title    = "Max Distance",
	Default  = 30,
	Min      = 5, Max = 100, Step = 1, Suffix = " studs",
	Callback = function(v) state.cfg.tof_maxDist = v end,
})

state.ui.aimbotf = state.ui.Tabs.Aimbot:Section({ Title = "Flashlight", Icon = "flashlight", Side = "Left" })
state.ui.aimbotf:Toggle({
	Title    = "Aimbot Flashlight",
	Default  = false,
	Callback = function(v)
		flashlightAimEnabled = v
	end,
})

state.ui.aimbot = state.ui.Tabs.Aimbot:Section({ Title = "The Veil Legit", Icon = "crosshair", Side = "Right" })
state.ui.aimbot:Toggle({
	Title    = "Spear Aimlock (Hold E)",
	Default  = state.cfg.spear_enabled,
	Callback = function(v) state.cfg.spear_enabled = v end,
})

state.ui.aimbotc = state.ui.Tabs.Aimbot:Section({ Title = "Silent Aim Killer", Icon = "crosshair", Side = "Right" })
state.ui.aimbotc:Toggle({
	Title    = "Silent Aim",
	Default  = false,
	Callback = function(v) state.cfg.silentAim_cure_enabled = v end,
})
state.ui.aimbotc:Dropdown({
	Title    = "Killer",
	Default  = "The Veil",
	Values   = { "The Veil", "The Cure" },
	Callback = function(v) state.cfg.silentAim_killerMode = v end,
})
state.ui.aimbotc:Toggle({
	Title    = "Show FOV Circle",
	Default  = false,
	Callback = function(v) state.cfg.silentAim_showFOV = v end,
})
state.ui.aimbotc:Slider({
	Title    = "Silent Aim FOV",
	Default  = 150,
	Min      = 10, Max = 500, Step = 1, Suffix = "px",
	Callback = function(v) state.cfg.silentAim_fov = v end,
})
state.ui.aimbotc:Dropdown({
	Title    = "Target Part",
	Default  = "Head",
	Values   = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" },
	Callback = function(v) state.cfg.spear_targetPart = v end,
})

-- ESP 
state.ui.VaultPalletESPBox = state.ui.Tabs.ESP:Section({ Title = "Object Esp", Icon = "boxes", Side = "Left" })
state.ui.VaultPalletESPBox:Toggle({
	Title    = "Enable Vault ESP",
	Default  = false,
	Callback = function(v)
		vaultEspEnabled = v
		if not v then
			for obj in pairs(vaultEspElements) do removeVaultESP(obj) end
		else
			pcall(scanVaultAndPallet)
		end
	end,
})
state.ui.VaultPalletESPBox:Toggle({
	Title    = "Enable Pallet ESP",
	Default  = false,
	Callback = function(v)
		palletEspEnabled = v
		if not v then
			for model in pairs(palletEspElements) do removePalletESP(model) end
		else
			pcall(scanVaultAndPallet)
		end
	end,
})

state.ui.ESPBox = state.ui.Tabs.ESP:Section({ Title = "Killer ESP", Icon = "eye", Side = "Left" })
state.ui.ESPBox:Toggle({
	Title    = "Enable Killer ESP",
	Default  = state.cfg.esp_enabled,
	Callback = function(v) state.cfg.esp_enabled = v end,
})
state.ui.ESPBox:Toggle({
	Title    = "Show 3D Highlight",
	Default  = state.cfg.esp_showHighlight,
	Callback = function(v) state.cfg.esp_showHighlight = v end,
})
state.ui.ESPBox:Toggle({
	Title    = "Show Name",
	Default  = state.cfg.esp_showName,
	Callback = function(v) state.cfg.esp_showName = v end,
})
state.ui.ESPBox:Slider({
	Title    = "Max Distance",
	Default  = state.cfg.esp_maxDist,
	Min      = 50, Max = 1000, Step = 1, Suffix = " studs",
	Callback = function(v) state.cfg.esp_maxDist = v end,
})

state.ui.SCPEspBox = state.ui.Tabs.ESP:Section({ Title = "SCP ESP", Icon = "ghost", Side = "Left" })
state.ui.SCPEspBox:Toggle({
	Title    = "Enable SCP ESP",
	Default  = false,
	Callback = function(v)
		state.cfg.scp_esp_enabled = v
		if not v then
			for model in pairs(scpEspElements or {}) do removeSCPESP(model) end
		end
	end,
})

state.ui.GenESPBox = state.ui.Tabs.ESP:Section({ Title = "Generator ESP", Icon = "wrench", Side = "Right" })
state.ui.GenESPBox:Toggle({
	Title    = "Enable Generator ESP",
	Default  = false,
	Callback = function(v)
		genEspEnabled = v
		if v then
			pcall(initialScanGen)
		else
			for model in pairs(genEspElements or {}) do removeGenESP(model) end
		end
	end,
})
state.ui.GenESPBox:Toggle({
	Title    = "Enable Bear Trap ESP",
	Default  = false,
	Callback = function(v)
		bearTrapEspEnabled = v
		if v then
			pcall(initialScanBearTrap)
		else
			for model in pairs(bearTrapEspElements or {}) do removeBearTrapESP(model) end
		end
	end,
})
state.ui.GenESPBox:Toggle({
	Title    = "Enable Pumpkin ESP",
	Default  = false,
	Callback = function(v)
		pumpkinEspEnabled = v
		if v then
			pcall(scanPumpkins)
		else
			for model in pairs(pumpkinEspElements or {}) do removePumpkinESP(model) end
		end
	end,
})

state.ui.PlayerESPBox = state.ui.Tabs.ESP:Section({ Title = "Player ESP", Icon = "users", Side = "Right" })
state.ui.PlayerESPBox:Toggle({
	Title    = "Enable Player ESP",
	Default  = state.cfg.p_esp_enabled,
	Callback = function(v) state.cfg.p_esp_enabled = v end,
})
state.ui.PlayerESPBox:Toggle({
	Title    = "Show 3D Highlight",
	Default  = state.cfg.p_esp_showHighlight,
	Callback = function(v) state.cfg.p_esp_showHighlight = v end,
})
state.ui.PlayerESPBox:Toggle({
	Title    = "Show Name",
	Default  = state.cfg.p_esp_showName,
	Callback = function(v) state.cfg.p_esp_showName = v end,
})
state.ui.PlayerESPBox:Slider({
	Title    = "Max Distance",
	Default  = state.cfg.p_esp_maxDist,
	Min      = 50, Max = 1000, Step = 1, Suffix = " studs",
	Callback = function(v) state.cfg.p_esp_maxDist = v end,
})

-- World 
state.ui.Map = state.ui.Tabs.World:Section({ Title = "Visual", Icon = "globe", Side = "Left" })
state.ui.Map:Toggle({
	Title    = "Full Bright",
	Default  = false,
	Callback = function(v)
		_fullbrightEnabled = v
		if v then applyFullBright() else restoreFullBright() end
	end,
})
state.ui.Map:Toggle({
	Title    = "No Fog",
	Default  = false,
	Callback = function(v)
		_nofogEnabled = v
		if v then applyNoFog() else restoreNoFog() end
	end,
})


-- SILENT AIM CACHE
state.render.cachedSilentTarget = nil
state.render.cachedCureTarget = nil
state.render.cachedSurvivorTarget = nil
-- FOV Circle
state.render.fovCircle = Drawing.new("Circle")
state.render.fovCircle.Visible   = false
state.render.fovCircle.Thickness = 1
state.render.fovCircle.Color     = Color3.fromRGB(255, 255, 255)
state.render.fovCircle.Filled    = false
state.render.fovCircle.Radius    = 150
state.render.fovCircle.NumSides  = 64

state.render.lines = {
    aim  = Drawing.new("Line"),
    cure = Drawing.new("Line"),
    surv = Drawing.new("Line"),
}
state.render.lines.aim.Visible      = false; state.render.lines.aim.Thickness  = 1.5
state.render.lines.aim.Color        = Color3.fromRGB(255, 0, 0);   state.render.lines.aim.Transparency = 0.3
state.render.lines.cure.Visible     = false; state.render.lines.cure.Thickness = 1.5
state.render.lines.cure.Color       = Color3.fromRGB(0, 255, 150); state.render.lines.cure.Transparency = 0.3
state.render.lines.surv.Visible     = false; state.render.lines.surv.Thickness = 1.5
state.render.lines.surv.Color       = Color3.fromRGB(255, 255, 0); state.render.lines.surv.Transparency = 0.3
state.render.lockLine     = state.render.lines.aim
state.render.lockLineCure = state.render.lines.cure
state.render.lockLineSurv = state.render.lines.surv

RunService.RenderStepped:Connect(function()
	local showFov = (state.cfg.silentAim_enabled or state.cfg.silentAim_cure_enabled) and state.cfg.silentAim_showFOV
	local center = UserInputService:GetMouseLocation()

	if showFov then
		state.render.fovCircle.Position = Vector2.new(center.X, center.Y)
		state.render.fovCircle.Radius   = state.cfg.silentAim_fov or 150
		state.render.fovCircle.Visible  = true
	else
		state.render.fovCircle.Visible = false
	end

	local target = state.render.cachedSilentTarget
	if state.cfg.silentAim_enabled and target and target.Parent then
		local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
		if onScreen and screenPos.Z > 0 then
			state.render.lockLine.From    = Vector2.new(center.X, center.Y)
			state.render.lockLine.To      = Vector2.new(screenPos.X, screenPos.Y)
			state.render.lockLine.Visible = true
		else
			state.render.lockLine.Visible = false
		end

		local lockedChar = target.Parent
		for char, elem in pairs(player2DEspElements) do
			if elem.highlight then
				if char == lockedChar then
					elem.highlight.FillColor    = Color3.fromRGB(255, 255, 255)
					elem.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				end
			end
		end
	else
		state.render.lockLine.Visible = false
	end

    local survTarget = state.render.cachedSurvivorTarget
	if state.cfg.silentAim_survivor_enabled and survTarget and survTarget.Parent then
		local screenPos, onScreen = Camera:WorldToViewportPoint(survTarget.Position)
		if onScreen and screenPos.Z > 0 then
			state.render.lockLineSurv.From    = Vector2.new(center.X, center.Y)
			state.render.lockLineSurv.To      = Vector2.new(screenPos.X, screenPos.Y)
			state.render.lockLineSurv.Visible = true
		else
			state.render.lockLineSurv.Visible = false
		end
	else
		state.render.lockLineSurv.Visible = false
	end

	local cureTarget = state.render.cachedCureTarget
	if state.cfg.silentAim_cure_enabled and cureTarget and cureTarget.Parent then
		local screenPos, onScreen = Camera:WorldToViewportPoint(cureTarget.Position)
		if onScreen and screenPos.Z > 0 then
			state.render.lockLineCure.From    = Vector2.new(center.X, center.Y)
			state.render.lockLineCure.To      = Vector2.new(screenPos.X, screenPos.Y)
			state.render.lockLineCure.Visible = true
		else
			state.render.lockLineCure.Visible = false
		end
	else
		state.render.lockLineCure.Visible = false
	end
end)

task.spawn(function()
    while state.running do
        if state.cfg.silentAim_enabled then
            state.render.cachedSilentTarget = getClosestPlayerToMouse(state.cfg.silentAim_fov)
        else
            state.render.cachedSilentTarget = nil
        end
        if state.cfg.silentAim_cure_enabled then
            state.render.cachedCureTarget = getClosestPlayerToMouse(state.cfg.silentAim_fov)
        else
            state.render.cachedCureTarget = nil
        end
        if state.cfg.silentAim_survivor_enabled then
            state.render.cachedSurvivorTarget = getClosestToMouseAny(state.cfg.silentAim_fov)
        else
            state.render.cachedSurvivorTarget = nil
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

	-- SILENT AIM (The Veil - Spear)
	if not _saFiring
	and state.cfg.silentAim_cure_enabled
	and state.cfg.silentAim_killerMode == "The Veil"
	and method == "FireServer"
	and selfName:find("Spearthrow")
	then
		local args = {...}
		local target = state.render.cachedCureTarget
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

	-- SILENT AIM (The Cure - Flask)
	if not _saFiring
	and state.cfg.silentAim_cure_enabled
	and state.cfg.silentAim_killerMode == "The Cure"
	and method == "FireServer"
	and selfName:find("ThrowFlask")
	then
		local args = {...}
		local target = state.render.cachedCureTarget
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

	-- ANTI FALL DAMAGE
	if state.cfg.antiFallDamage_enabled
	and selfName == "Fall"
	and (method == "FireServer" or method == "InvokeServer")
	then
		return
	end

	return oldNamecall(self, ...)
end)

setreadonly(mt, true)

OasisUI:OnUnload(function()
	state.running      = false
	moonwalkEnabled    = false
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
    autoBreakGenAura_enabled = false
	state.render.cachedSilentTarget = nil
	pcall(function() state.render.fovCircle:Remove() end)
    pcall(function() destroyParryRing() end)
    pcall(function()
        if skillAdornment and skillAdornment.Parent then
            skillAdornment.Visible = false
            skillAdornment.Adornee = nil
            skillAdornment:Destroy()
        end
    end)
    clearMapEspConns()
    for obj in pairs(vaultEspElements or {}) do removeVaultESP(obj) end
    for model in pairs(palletEspElements or {}) do removePalletESP(model) end
    vaultEspElements = {}
    palletEspElements = {}
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
    if bearTrapEspElements then
        for model in pairs(bearTrapEspElements or {}) do removeBearTrapESP(model) end
        bearTrapEspElements = {}
    end
    for model in pairs(pumpkinEspElements or {}) do removePumpkinESP(model) end
    pumpkinEspElements = {}
	pcall(function() espGui:Destroy() end)
    pcall(function() state.render.lockLine:Remove() end)
    pcall(function() state.render.lockLineCure:Remove() end)
    pcall(function() state.render.lockLineSurv:Remove() end)
    pcall(function() stopFlashlightAim() end)
    pcall(function()
		restoreFullBright()
		restoreNoFog()
	end)
    pcall(function() palletCountGui:Destroy() end)
    pcall(function() lblMapPrefix:Remove() end)
    pcall(function() lblMapValue:Remove() end)
    pcall(function() lblNamePrefix:Remove() end)
    pcall(function() lblNameValue:Remove() end)
    pcall(function() lblKillerPrefix:Remove() end)
    pcall(function() lblKillerValue:Remove() end)
    pcall(function() lblKillerThe:Remove() end)
	for char, conns in pairs(killerAnimConns or {}) do
		for _,c in ipairs(conns) do pcall(c.Disconnect, c) end
	end
	for char in pairs(killer2DEspElements or {}) do removeKiller2DESP(char) end
	for model in pairs(scpEspElements or {}) do removeSCPESP(model) end
	for char in pairs(player2DEspElements or {}) do removePlayer2DESP(char) end
    for model in pairs(genEspElements or {}) do removeGenESP(model) end
	scpEspElements           = {}
	playerParryState         = {}
	monitoredPlayerAnimators = {}
	_G.KKKkhub = nil
	print("[KKKK Hub v1.2] Unloaded!")
end)
