-- [ Example Config
-- getenv = function() return {
--    ["Lock Fps"] = { ["Enabled"] = true, ["FPS"] = 25 },
--    ["White Screen"] = true,
-- } end ]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Teams = game:GetService("Teams")
local lp = Players.LocalPlayer
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- Config
local _cfg = {}
pcall(function() local e = getenv and getenv() or {}; _cfg = type(e)=="table" and e or {} end)
local function cfgS(k,s,d)
	local ok,t = pcall(function() return _cfg[k] end)
	if not ok or type(t)~="table" then return d end
	local v = t[s]; return v==nil and d or v
end

-- ล้าง GUI เก่า
for _,v in ipairs(lp:WaitForChild("PlayerGui"):GetChildren()) do
	if v.Name=="PerfHUD" or v.Name=="BloxHUD" or v.Name=="BlackoutGui" or v.Name=="PlayerCountGui" then v:Destroy() end
end

-- FPS Cap
local FPS_CAP = 60
pcall(function()
	if cfgS("Lock Fps","Enabled",false) then FPS_CAP = cfgS("Lock Fps","FPS",60) end
end)
local function applyFpsCap(n)
	if setfpscap then pcall(function() setfpscap(n) end) end
end
applyFpsCap(FPS_CAP)

-- ── Helper ────────────────────────────────────────────────────────────────────
local function makeGui(name, order)
	local g = Instance.new("ScreenGui")
	g.Name=name; g.ResetOnSpawn=false; g.DisplayOrder=order
	g.IgnoreGuiInset=true; g.Parent=lp:WaitForChild("PlayerGui")
	return g
end

-- ── Blackout ──────────────────────────────────────────────────────────────────
local bGui = makeGui("BlackoutGui", 1)
local bFrame = Instance.new("Frame", bGui)
bFrame.Size=UDim2.new(1,0,1,0); bFrame.BackgroundColor3=Color3.new(0,0,0)
bFrame.BackgroundTransparency=1; bFrame.BorderSizePixel=0; bFrame.Visible=false

local wakeBtn = Instance.new("TextButton", bGui)
wakeBtn.Size=UDim2.new(0,100,0,40); wakeBtn.AnchorPoint=Vector2.new(0.5,1)
wakeBtn.Position=UDim2.new(0.5,0,1,-30); wakeBtn.Text="Restore"
wakeBtn.BackgroundColor3=Color3.fromRGB(30,30,50); wakeBtn.BorderSizePixel=0
wakeBtn.TextColor3=Color3.fromRGB(255,230,80); wakeBtn.Font=Enum.Font.GothamBold
wakeBtn.TextSize=14; wakeBtn.AutoButtonColor=false; wakeBtn.Visible=false; wakeBtn.ZIndex=20
Instance.new("UICorner",wakeBtn).CornerRadius=UDim.new(0,8)

local blackoutOn = false
local function setBlackout(s)
	blackoutOn=s; bFrame.Visible=s; wakeBtn.Visible=s
	bFrame.BackgroundTransparency = s and 0.001 or 1
end
pcall(function() if _cfg["White Screen"] then task.defer(function() setBlackout(true) end) end end)
wakeBtn.MouseButton1Click:Connect(function() setBlackout(false) end)
UIS.InputBegan:Connect(function(i,g)
	if not g and i.KeyCode==Enum.KeyCode.B then setBlackout(not blackoutOn) end
end)

-- ── PerfHUD: FPS / PING / CAP / TIME ─────────────────────────────────────────
local pGui = makeGui("PerfHUD", 10)
local ROW1_W = isMobile and 340 or 320
local ROW1_H = isMobile and 60 or 54
local TS_TAG = isMobile and 11 or 10
local TS_VAL = isMobile and 19 or 17
local SEC_W  = math.floor(ROW1_W/4)

local row1 = Instance.new("Frame", pGui)
row1.Size=UDim2.new(0,ROW1_W,0,ROW1_H); row1.AnchorPoint=Vector2.new(0.5,0)
row1.Position=UDim2.new(0.5,0,0, isMobile and 80 or 150)
row1.BackgroundColor3=Color3.fromRGB(14,14,24); row1.BackgroundTransparency=0.3; row1.BorderSizePixel=0
Instance.new("UICorner",row1).CornerRadius=UDim.new(1,0)
local r1St=Instance.new("UIStroke",row1); r1St.Color=Color3.fromRGB(255,255,255); r1St.Thickness=1; r1St.Transparency=0.82

for _,x in ipairs({SEC_W, SEC_W*2, SEC_W*3}) do
	local f=Instance.new("Frame",row1); f.Size=UDim2.new(0,1,0,26); f.Position=UDim2.new(0,x,0.5,-13)
	f.BackgroundColor3=Color3.fromRGB(255,255,255); f.BackgroundTransparency=0.8; f.BorderSizePixel=0
end

local function makeCell(tag, col, color)
	local tl=Instance.new("TextLabel",row1)
	tl.Size=UDim2.new(0,SEC_W,0,16); tl.Position=UDim2.new(0,SEC_W*col,0,6)
	tl.BackgroundTransparency=1; tl.Text=tag; tl.TextColor3=Color3.fromRGB(180,180,200)
	tl.TextSize=TS_TAG; tl.Font=Enum.Font.GothamBold; tl.TextXAlignment=Enum.TextXAlignment.Center
	local vl=Instance.new("TextLabel",row1)
	vl.Size=UDim2.new(0,SEC_W,0,26); vl.Position=UDim2.new(0,SEC_W*col,0,ROW1_H-32)
	vl.BackgroundTransparency=1; vl.Text="---"; vl.TextSize=TS_VAL; vl.TextColor3=color
	vl.Font=Enum.Font.GothamBold; vl.TextXAlignment=Enum.TextXAlignment.Center
	return vl
end
local lblFps  = makeCell("FPS",  0, Color3.fromRGB(74,222,128))
local lblPing = makeCell("PING", 1, Color3.fromRGB(250,200,40))
local lblTime = makeCell("TIME", 3, Color3.fromRGB(192,132,252))

-- CAP textbox
local capTag=Instance.new("TextLabel",row1)
capTag.Size=UDim2.new(0,SEC_W,0,16); capTag.Position=UDim2.new(0,SEC_W*2,0,6)
capTag.BackgroundTransparency=1; capTag.Text="CAP"; capTag.TextColor3=Color3.fromRGB(180,180,200)
capTag.TextSize=TS_TAG; capTag.Font=Enum.Font.GothamBold; capTag.TextXAlignment=Enum.TextXAlignment.Center

local capBox=Instance.new("TextBox",row1)
capBox.Size=UDim2.new(0,SEC_W-8,0,24); capBox.AnchorPoint=Vector2.new(0.5,1)
capBox.Position=UDim2.new(0,SEC_W*2+math.floor(SEC_W/2),1,-4)
capBox.BackgroundColor3=Color3.fromRGB(20,20,36); capBox.BorderSizePixel=0
capBox.Text=FPS_CAP>0 and tostring(FPS_CAP) or "∞"; capBox.PlaceholderText="60"
capBox.TextColor3=Color3.fromRGB(100,210,255); capBox.TextSize=TS_VAL
capBox.Font=Enum.Font.GothamBold; capBox.TextXAlignment=Enum.TextXAlignment.Center
capBox.ClearTextOnFocus=true
Instance.new("UICorner",capBox).CornerRadius=UDim.new(0,4)
local cbSt=Instance.new("UIStroke",capBox); cbSt.Color=Color3.fromRGB(100,180,255); cbSt.Thickness=1; cbSt.Transparency=0.5

capBox.FocusLost:Connect(function(enter)
	if not enter then return end
	local raw = capBox.Text:gsub("%s+",""):gsub("∞","0")
	local n = tonumber(raw)
	if not n or n ~= n then n = 60 end
	n = math.clamp(math.floor(n), 0, 999)
	applyFpsCap(n); FPS_CAP=n; capBox.Text=n>0 and tostring(n) or "∞"
end)

-- Timers
local t0=tick()
RunService.Heartbeat:Connect(function()
	local e=math.floor(tick()-t0)
	lblTime.Text = e>=3600 and string.format("%d:%02d:%02d",e//3600,(e%3600)//60,e%60)
		or string.format("%02d:%02d",e//60,e%60)
end)
local fc,lt=0,tick()
RunService.RenderStepped:Connect(function()
	fc+=1; local now=tick()
	if now-lt>=0.5 then
		local fps=math.floor(fc/(now-lt)); fc=0; lt=now
		lblFps.Text=tostring(fps)
		lblFps.TextColor3=fps>=60 and Color3.fromRGB(74,222,128) or fps>=30 and Color3.fromRGB(250,200,40) or Color3.fromRGB(255,70,70)
	end
end)
RunService.Heartbeat:Connect(function()
	local ok,p=pcall(function() return math.floor(lp:GetNetworkPing()*1000) end)
	if not ok then return end
	lblPing.Text=p.." ms"
	lblPing.TextColor3=p<=80 and Color3.fromRGB(74,222,128) or p<=200 and Color3.fromRGB(250,200,40) or Color3.fromRGB(255,70,70)
end)

-- ── PlayerCountGui ────────────────────────────────────────────────────────────
local MAX_PLAYERS = 12
local pcntGui = makeGui("PlayerCountGui", 10)
local ROW2_H = isMobile and 46 or 40
local ROW2_Y = (isMobile and 80 or 150) + ROW1_H + 8

local row2=Instance.new("Frame",pcntGui)
row2.Size=UDim2.new(0,ROW1_W,0,ROW2_H); row2.AnchorPoint=Vector2.new(0.5,0)
row2.Position=UDim2.new(0.5,0,0,ROW2_Y)
row2.BackgroundColor3=Color3.fromRGB(14,14,24); row2.BackgroundTransparency=0.3; row2.BorderSizePixel=0
Instance.new("UICorner",row2).CornerRadius=UDim.new(1,0)
local r2St=Instance.new("UIStroke",row2); r2St.Color=Color3.fromRGB(255,255,255); r2St.Thickness=1; r2St.Transparency=0.82

local plTag=Instance.new("TextLabel",row2)
plTag.Size=UDim2.new(0,70,0,14); plTag.Position=UDim2.new(0,10,0,4)
plTag.BackgroundTransparency=1; plTag.Text="👥 PLAYERS"; plTag.TextColor3=Color3.fromRGB(180,180,200)
plTag.TextSize=isMobile and 11 or 10; plTag.Font=Enum.Font.GothamBold; plTag.TextXAlignment=Enum.TextXAlignment.Left

local plCount=Instance.new("TextLabel",row2)
plCount.Size=UDim2.new(0,80,0,16); plCount.Position=UDim2.new(1,-90,0,2)
plCount.BackgroundTransparency=1; plCount.Text="? / "..MAX_PLAYERS
plCount.TextColor3=Color3.fromRGB(100,200,255); plCount.TextSize=isMobile and 14 or 13
plCount.Font=Enum.Font.GothamBold; plCount.TextXAlignment=Enum.TextXAlignment.Right

local barBg=Instance.new("Frame",row2)
barBg.Size=UDim2.new(1,-16,0,6); barBg.Position=UDim2.new(0,8,1,-10)
barBg.BackgroundColor3=Color3.fromRGB(40,40,60); barBg.BorderSizePixel=0
Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0)
local barFill=Instance.new("Frame",barBg)
barFill.Size=UDim2.new(0,0,1,0); barFill.BackgroundColor3=Color3.fromRGB(74,222,128); barFill.BorderSizePixel=0
Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)

local fullBadge=Instance.new("TextLabel",row2)
fullBadge.Size=UDim2.new(0,40,0,14); fullBadge.Position=UDim2.new(0,10,0,3)
fullBadge.BackgroundColor3=Color3.fromRGB(255,60,60); fullBadge.BackgroundTransparency=0.25
fullBadge.Text="FULL"; fullBadge.TextColor3=Color3.fromRGB(255,220,220)
fullBadge.TextSize=isMobile and 10 or 9; fullBadge.Font=Enum.Font.GothamBold
fullBadge.TextXAlignment=Enum.TextXAlignment.Center; fullBadge.Visible=false; fullBadge.BorderSizePixel=0
Instance.new("UICorner",fullBadge).CornerRadius=UDim.new(0,4)

-- Row3: Teams
local ROW3_H = isMobile and 58 or 52
local row3=Instance.new("Frame",pcntGui)
row3.Size=UDim2.new(0,ROW1_W,0,ROW3_H); row3.AnchorPoint=Vector2.new(0.5,0)
row3.Position=UDim2.new(0.5,0,0,ROW2_Y+ROW2_H+6)
row3.BackgroundColor3=Color3.fromRGB(14,14,24); row3.BackgroundTransparency=0.3; row3.BorderSizePixel=0
row3.Visible=false
Instance.new("UICorner",row3).CornerRadius=UDim.new(1,0)
local r3St=Instance.new("UIStroke",row3); r3St.Color=Color3.fromRGB(255,255,255); r3St.Thickness=1; r3St.Transparency=0.82

local teamTag=Instance.new("TextLabel",row3)
teamTag.Size=UDim2.new(0,55,0,14); teamTag.Position=UDim2.new(0,8,0,4)
teamTag.BackgroundTransparency=1; teamTag.Text="⚔ TEAMS"; teamTag.TextColor3=Color3.fromRGB(180,180,200)
teamTag.TextSize=isMobile and 11 or 10; teamTag.Font=Enum.Font.GothamBold; teamTag.TextXAlignment=Enum.TextXAlignment.Left

local chipHolder=Instance.new("Frame",row3)
chipHolder.Size=UDim2.new(1,-70,1,-8); chipHolder.Position=UDim2.new(0,66,0,4)
chipHolder.BackgroundTransparency=1; chipHolder.BorderSizePixel=0
local chipList=Instance.new("UIListLayout",chipHolder)
chipList.FillDirection=Enum.FillDirection.Horizontal; chipList.SortOrder=Enum.SortOrder.LayoutOrder
chipList.Padding=UDim.new(0,4); chipList.VerticalAlignment=Enum.VerticalAlignment.Center

local teamChips={}
local function rebuildTeamChips()
	for _,c in pairs(teamChips) do if c.frame and c.frame.Parent then c.frame:Destroy() end end
	teamChips={}
	local list=Teams:GetTeams()
	if #list==0 then row3.Visible=false; return end
	row3.Visible=true
	local chipW=math.clamp(math.floor((ROW1_W-70-(#list-1)*4)/math.max(#list,1)),36,100)
	for i,team in ipairs(list) do
		local tc=team.TeamColor and team.TeamColor.Color or Color3.fromRGB(120,120,180)
		local bright=Color3.new(math.clamp(tc.R*1.4+0.08,0,1),math.clamp(tc.G*1.4+0.08,0,1),math.clamp(tc.B*1.4+0.08,0,1))
		local chip=Instance.new("Frame",chipHolder)
		chip.Size=UDim2.new(0,chipW,1,-2); chip.BackgroundColor3=Color3.fromRGB(20,20,36)
		chip.BackgroundTransparency=0.1; chip.BorderSizePixel=0; chip.LayoutOrder=i
		Instance.new("UICorner",chip).CornerRadius=UDim.new(0,5)
		local cs=Instance.new("UIStroke",chip); cs.Color=bright; cs.Thickness=1; cs.Transparency=0.35
		local strip=Instance.new("Frame",chip); strip.Size=UDim2.new(1,0,0,3)
		strip.BackgroundColor3=bright; strip.BorderSizePixel=0
		Instance.new("UICorner",strip).CornerRadius=UDim.new(0,5)
		local nm=Instance.new("TextLabel",chip); nm.Size=UDim2.new(1,0,0,14); nm.Position=UDim2.new(0,0,0,5)
		nm.BackgroundTransparency=1; nm.Text=#team.Name>8 and team.Name:sub(1,7).."…" or team.Name
		nm.TextColor3=bright; nm.TextSize=isMobile and 10 or 9; nm.Font=Enum.Font.GothamBold
		nm.TextXAlignment=Enum.TextXAlignment.Center; nm.ClipsDescendants=true
		local cl=Instance.new("TextLabel",chip); cl.Size=UDim2.new(1,0,0,16); cl.Position=UDim2.new(0,0,0,19)
		cl.BackgroundTransparency=1; cl.Text="0"; cl.TextColor3=Color3.fromRGB(255,255,255)
		cl.TextSize=isMobile and 14 or 13; cl.Font=Enum.Font.GothamBold; cl.TextXAlignment=Enum.TextXAlignment.Center
		teamChips[team.Name]={frame=chip,cntLbl=cl,team=team}
	end
end

local function updatePlayerCount()
	local total=#Players:GetPlayers()
	local ratio=math.clamp(total/MAX_PLAYERS,0,1)
	plCount.Text=total.." / "..MAX_PLAYERS
	local color
	if ratio>=1 then color=Color3.fromRGB(255,70,70); plCount.TextColor3=Color3.fromRGB(255,100,100); fullBadge.Visible=true
	elseif ratio>=0.75 then color=Color3.fromRGB(255,190,40); plCount.TextColor3=Color3.fromRGB(255,210,80); fullBadge.Visible=false
	else color=Color3.fromRGB(74,222,128); plCount.TextColor3=Color3.fromRGB(100,200,255); fullBadge.Visible=false end
	barFill.BackgroundColor3=color; barFill.Size=UDim2.new(ratio,0,1,0)
	for _,c in pairs(teamChips) do
		if c.team then
			local cnt=0; for _,p in ipairs(Players:GetPlayers()) do if p.Team==c.team then cnt+=1 end end
			c.cntLbl.Text=tostring(cnt)
			c.frame.BackgroundTransparency=lp.Team==c.team and 0 or 0.1
		end
	end
end

task.spawn(function() task.wait(1); rebuildTeamChips(); updatePlayerCount() end)
Teams.ChildAdded:Connect(function() task.wait(0.1); rebuildTeamChips(); updatePlayerCount() end)
Teams.ChildRemoved:Connect(function() task.wait(0.1); rebuildTeamChips(); updatePlayerCount() end)
task.spawn(function() while true do pcall(updatePlayerCount); task.wait(2) end end)
Players.PlayerAdded:Connect(function() task.wait(0.5); pcall(updatePlayerCount) end)
Players.PlayerRemoving:Connect(function() task.wait(0.3); pcall(updatePlayerCount) end)

-- ── BloxHUD Panel ─────────────────────────────────────────────────────────────
local mainGui = makeGui("BloxHUD", 10)
local CARD_W = isMobile and 290 or 260
local CARD_H = isMobile and 340 or 300

-- Full panel
local pc=Instance.new("Frame",mainGui)
pc.Size=UDim2.new(0,CARD_W,0,CARD_H)
if isMobile then pc.AnchorPoint=Vector2.new(0.5,1); pc.Position=UDim2.new(0.5,0,1,-120)
else pc.AnchorPoint=Vector2.new(1,0); pc.Position=UDim2.new(1,-12,0,175) end
pc.BackgroundColor3=Color3.fromRGB(10,10,18); pc.BackgroundTransparency=0.15
pc.BorderSizePixel=0; pc.ClipsDescendants=true
Instance.new("UICorner",pc).CornerRadius=UDim.new(0,10)
local pcSt=Instance.new("UIStroke",pc); pcSt.Color=Color3.fromRGB(255,255,255); pcSt.Thickness=0.8; pcSt.Transparency=0.85

-- Mini panel
local MINI_H = isMobile and 64 or 54
local mini=Instance.new("Frame",mainGui)
mini.Size=UDim2.new(0,CARD_W,0,MINI_H)
if isMobile then mini.AnchorPoint=Vector2.new(0.5,1); mini.Position=UDim2.new(0.5,0,1,-120)
else mini.AnchorPoint=Vector2.new(1,0); mini.Position=UDim2.new(1,-12,0,175) end
mini.BackgroundColor3=Color3.fromRGB(10,10,18); mini.BackgroundTransparency=0.18
mini.BorderSizePixel=0; mini.ClipsDescendants=true; mini.Visible=false
Instance.new("UICorner",mini).CornerRadius=UDim.new(0,10)
local miniSt=Instance.new("UIStroke",mini); miniSt.Color=Color3.fromRGB(255,255,255); miniSt.Thickness=0.7; miniSt.Transparency=0.82

-- Collapse / Expand
local BTN_SZ = isMobile and 38 or 26
local function makeToggleBtn(parent, txt, yPos)
	local b=Instance.new("TextButton",parent)
	b.Size=UDim2.new(0,BTN_SZ,0,BTN_SZ-8); b.Position=UDim2.new(1,-BTN_SZ-6,0,yPos)
	b.BackgroundColor3=Color3.fromRGB(30,30,48); b.BorderSizePixel=0
	b.Text=txt; b.TextColor3=Color3.fromRGB(160,160,200)
	b.TextSize=isMobile and 12 or 9; b.Font=Enum.Font.GothamBold; b.AutoButtonColor=false
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
	Instance.new("UIStroke",b).Color=Color3.fromRGB(255,255,255)
	return b
end
local collapseBtn = makeToggleBtn(pc,   "▲", 12)
local expandBtn   = makeToggleBtn(mini, "▼", 7)

local isMin=false
local function applyMin()
	pc.Visible=not isMin; mini.Visible=isMin
end
collapseBtn.MouseButton1Click:Connect(function() isMin=true;  applyMin() end)
expandBtn.MouseButton1Click:Connect(function()   isMin=false; applyMin() end)

-- Body (no scroll)
local body=Instance.new("Frame",pc)
body.Size=UDim2.new(1,0,1,0); body.BackgroundTransparency=1; body.BorderSizePixel=0

local function bLabel(parent,txt,ts,tc,font,xa,sz,pos)
	local l=Instance.new("TextLabel",parent)
	l.Size=sz; l.Position=pos; l.BackgroundTransparency=1
	l.Text=txt; l.TextColor3=tc; l.TextSize=ts
	l.Font=font or Enum.Font.Gotham; l.TextXAlignment=xa or Enum.TextXAlignment.Left
	l.TextStrokeTransparency=0.4; l.TextStrokeColor3=Color3.new(0,0,0)
	return l
end
local function bDiv(y)
	local d=Instance.new("Frame",body)
	d.Size=UDim2.new(1,-16,0,1); d.Position=UDim2.new(0,8,0,y)
	d.BackgroundColor3=Color3.fromRGB(255,255,255); d.BackgroundTransparency=0.88; d.BorderSizePixel=0
end

-- Avatar
local avFrame=Instance.new("Frame",body)
avFrame.Size=UDim2.new(0,50,0,50); avFrame.Position=UDim2.new(0,10,0,10)
avFrame.BackgroundColor3=Color3.fromRGB(30,30,45); avFrame.BorderSizePixel=0
Instance.new("UICorner",avFrame).CornerRadius=UDim.new(1,0)
local avSt=Instance.new("UIStroke",avFrame); avSt.Color=Color3.fromRGB(192,132,252); avSt.Thickness=1.5; avSt.Transparency=0.2
local avImg=Instance.new("ImageLabel",avFrame)
avImg.Size=UDim2.new(1,0,1,0); avImg.BackgroundTransparency=1; avImg.BorderSizePixel=0
Instance.new("UICorner",avImg).CornerRadius=UDim.new(1,0)
local ok,th=pcall(function() return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
if ok then avImg.Image=th end

bLabel(body,lp.DisplayName,15,Color3.fromRGB(255,255,255),Enum.Font.GothamBold,Enum.TextXAlignment.Left,UDim2.new(0,150,0,18),UDim2.new(0,66,0,10))
bLabel(body,"@"..lp.Name,10,Color3.fromRGB(180,180,210),Enum.Font.Gotham,Enum.TextXAlignment.Left,UDim2.new(0,150,0,14),UDim2.new(0,66,0,30))
bDiv(68)

-- Info stats
local INFO={
	{tag="LEVEL",    key="Level",    color=Color3.fromRGB(255,215,60)},
	{tag="BELI",     key="Beli",     color=Color3.fromRGB(80,235,140)},
	{tag="FRAGMENTS",key="Fragments",color=Color3.fromRGB(200,130,255)},
	{tag="RACE",     key="Race",     color=Color3.fromRGB(210,150,255)},
}
local infoLabels={}
for i,s in ipairs(INFO) do
	local col=(i==1 or i==3) and 0 or 1; local row=(i<=2) and 0 or 1
	local x=10+col*122; local y=76+row*28
	bLabel(body,s.tag,9,Color3.fromRGB(180,180,210),Enum.Font.GothamBold,Enum.TextXAlignment.Left,UDim2.new(0,114,0,11),UDim2.new(0,x,0,y))
	infoLabels[s.key]=bLabel(body,"...",14,s.color,Enum.Font.GothamBold,Enum.TextXAlignment.Left,UDim2.new(0,114,0,15),UDim2.new(0,x,0,y+12))
end
local vSep=Instance.new("Frame",body); vSep.Size=UDim2.new(0,1,0,52); vSep.Position=UDim2.new(0,126,0,74)
vSep.BackgroundColor3=Color3.fromRGB(255,255,255); vSep.BackgroundTransparency=0.88; vSep.BorderSizePixel=0
bDiv(136)

-- Combat stats
bLabel(body,"COMBAT STATS",10,Color3.fromRGB(200,200,230),Enum.Font.GothamBold,Enum.TextXAlignment.Left,UDim2.new(1,-16,0,12),UDim2.new(0,10,0,142))
local COMBAT={
	{tag="Melee",      icon="👊",color=Color3.fromRGB(255,175,90)},
	{tag="Defense",    icon="🛡", color=Color3.fromRGB(120,190,255)},
	{tag="Sword",      icon="⚔", color=Color3.fromRGB(225,190,255)},
	{tag="Gun",        icon="🔫",color=Color3.fromRGB(90,235,150)},
	{tag="Demon Fruit",icon="🍎",color=Color3.fromRGB(255,120,150)},
}
local combatLabels={}
local MAX_STAT=2800
for i,s in ipairs(COMBAT) do
	local y=158+(i-1)*26
	local ico=Instance.new("TextLabel",body)
	ico.Size=UDim2.new(0,20,0,20); ico.Position=UDim2.new(0,8,0,y)
	ico.BackgroundTransparency=1; ico.Text=s.icon; ico.TextSize=14
	ico.Font=Enum.Font.Gotham; ico.TextXAlignment=Enum.TextXAlignment.Center; ico.TextStrokeTransparency=1
	bLabel(body,s.tag,12,Color3.fromRGB(220,220,240),Enum.Font.GothamBold,Enum.TextXAlignment.Left,UDim2.new(0,100,0,20),UDim2.new(0,30,0,y))
	local barBg2=Instance.new("Frame",body); barBg2.Size=UDim2.new(0,95,0,4); barBg2.Position=UDim2.new(0,30,0,y+17)
	barBg2.BackgroundColor3=Color3.fromRGB(50,50,70); barBg2.BorderSizePixel=0
	Instance.new("UICorner",barBg2).CornerRadius=UDim.new(1,0)
	local barFill2=Instance.new("Frame",barBg2); barFill2.Size=UDim2.new(0,0,1,0)
	barFill2.BackgroundColor3=s.color; barFill2.BorderSizePixel=0
	Instance.new("UICorner",barFill2).CornerRadius=UDim.new(1,0)
	local vl=bLabel(body,"...",12,s.color,Enum.Font.GothamBold,Enum.TextXAlignment.Right,UDim2.new(0,50,0,20),UDim2.new(0,200,0,y))
	combatLabels[s.tag]={label=vl,bar=barFill2}
end

-- Mini panel content
local AV_SIZE=isMobile and 30 or 26
local miniAv=Instance.new("Frame",mini)
miniAv.Size=UDim2.new(0,AV_SIZE,0,AV_SIZE); miniAv.Position=UDim2.new(0,8,0,7)
miniAv.BackgroundColor3=Color3.fromRGB(40,30,60); miniAv.BorderSizePixel=0
Instance.new("UICorner",miniAv).CornerRadius=UDim.new(1,0)
local miniAvSt=Instance.new("UIStroke",miniAv); miniAvSt.Color=Color3.fromRGB(192,132,252); miniAvSt.Thickness=1.2; miniAvSt.Transparency=0.15
local miniAvImg=Instance.new("ImageLabel",miniAv)
miniAvImg.Size=UDim2.new(1,0,1,0); miniAvImg.BackgroundTransparency=1; miniAvImg.BorderSizePixel=0
Instance.new("UICorner",miniAvImg).CornerRadius=UDim.new(1,0)
local ok2,th2=pcall(function() return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
if ok2 then miniAvImg.Image=th2 end

local TX=AV_SIZE+20
bLabel(mini,lp.DisplayName,isMobile and 13 or 12,Color3.fromRGB(255,255,255),Enum.Font.GothamBold,Enum.TextXAlignment.Left,UDim2.new(0,CARD_W-TX-BTN_SZ-8,0,isMobile and 16 or 14),UDim2.new(0,TX,0,7))
bLabel(mini,"@"..lp.Name,isMobile and 10 or 9,Color3.fromRGB(150,130,190),Enum.Font.Gotham,Enum.TextXAlignment.Left,UDim2.new(0,CARD_W-TX-BTN_SZ-8,0,isMobile and 13 or 11),UDim2.new(0,TX,0,isMobile and 24 or 22))

local miniDiv=Instance.new("Frame",mini)
miniDiv.Size=UDim2.new(1,-16,0,1); miniDiv.Position=UDim2.new(0,8,0,isMobile and 40 or 36)
miniDiv.BackgroundColor3=Color3.fromRGB(255,255,255); miniDiv.BackgroundTransparency=0.88; miniDiv.BorderSizePixel=0

local SCOLS={{icon="⚔",key="Level",color=Color3.fromRGB(255,215,60)},{icon="💰",key="Beli",color=Color3.fromRGB(80,235,140)},{icon="💎",key="Fragments",color=Color3.fromRGB(200,130,255)},{icon="🧬",key="Race",color=Color3.fromRGB(210,160,255)}}
local miniStatLabels={}
local SW=math.floor(CARD_W/4)
for i,s in ipairs(SCOLS) do
	local sx=(i-1)*SW
	local ico=Instance.new("TextLabel",mini)
	ico.Size=UDim2.new(0,14,0,14); ico.Position=UDim2.new(0,sx+4,0,isMobile and 43 or 39)
	ico.BackgroundTransparency=1; ico.Text=s.icon; ico.TextSize=isMobile and 11 or 10
	ico.Font=Enum.Font.Gotham; ico.TextXAlignment=Enum.TextXAlignment.Center; ico.TextStrokeTransparency=1
	local vl=Instance.new("TextLabel",mini)
	vl.Size=UDim2.new(0,SW-20,0,14); vl.Position=UDim2.new(0,sx+19,0,isMobile and 43 or 39)
	vl.BackgroundTransparency=1; vl.Text="..."; vl.TextSize=isMobile and 11 or 10
	vl.Font=Enum.Font.GothamBold; vl.TextColor3=s.color; vl.TextXAlignment=Enum.TextXAlignment.Left
	vl.ClipsDescendants=true; vl.TextStrokeTransparency=0.4; vl.TextStrokeColor3=Color3.new(0,0,0)
	miniStatLabels[s.key]=vl
end

-- Self highlight
local selfHL=nil
local function applySelfHighlight(char)
	if selfHL and selfHL.Parent then pcall(function() selfHL:Destroy() end) end; selfHL=nil
	char=char or lp.Character; if not char then return end
	local hl=Instance.new("Highlight"); hl.Name="ESP_SelfHL"
	hl.FillColor=Color3.fromRGB(60,220,120); hl.OutlineColor=Color3.fromRGB(140,255,180)
	hl.FillTransparency=0.65; hl.OutlineTransparency=0
	hl.DepthMode=Enum.HighlightDepthMode.Occluded; hl.Adornee=char; hl.Parent=char; selfHL=hl
end
if lp.Character then task.delay(0.5,function() applySelfHighlight(lp.Character) end) end
lp.CharacterAdded:Connect(function(char) task.wait(0.5); applySelfHighlight(char) end)

-- Data update
local function fmt(v,key)
	if type(v)~="number" then return tostring(v or "?") end
	local NO_SHORT={Beli=true,Fragments=true,Level=true}
	if NO_SHORT[key] then return tostring(math.floor(v)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","") end
	if v>=1e6 then return string.format("%.1fM",v/1e6) elseif v>=1e3 then return string.format("%.1fK",v/1e3) else return tostring(math.floor(v)) end
end

local function updateData()
	local data=lp:FindFirstChild("Data"); if not data then return end
	for _,k in ipairs({"Level","Beli","Fragments","Race"}) do
		local node=data:FindFirstChild(k)
		if node then
			if infoLabels[k] then infoLabels[k].Text=fmt(node.Value,k) end
			if miniStatLabels[k] then miniStatLabels[k].Text=fmt(node.Value,k) end
		end
	end
	local stats=data:FindFirstChild("Stats"); if not stats then return end
	for _,s in ipairs(COMBAT) do
		local node=stats:FindFirstChild(s.tag)
		if node then
			local lv=node:FindFirstChild("Level")
			if lv and combatLabels[s.tag] then
				local v=lv.Value or 0
				combatLabels[s.tag].label.Text=tostring(v)
				combatLabels[s.tag].bar.Size=UDim2.new(math.clamp(v/MAX_STAT,0,1),0,1,0)
			end
		end
	end
end

task.spawn(function()
	local data=lp:WaitForChild("Data",10); if not data then return end
	updateData()
	for _,k in ipairs({"Level","Beli","Fragments","Race"}) do
		local node=data:WaitForChild(k,5); if node then node.Changed:Connect(updateData) end
	end
	local stats=data:WaitForChild("Stats",5)
	if stats then
		for _,s in ipairs(COMBAT) do
			local node=stats:WaitForChild(s.tag,5)
			if node then local lv=node:WaitForChild("Level",5); if lv then lv.Changed:Connect(updateData) end end
		end
	end
end)
