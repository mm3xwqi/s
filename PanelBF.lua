-- BloxHub v3 | Compressed Edition
local Pl,lp,pg,Run,UIS,TS,WS,HTTP = game:GetService("Players"),nil,nil,game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("TweenService"),game:GetService("Workspace"),game:GetService("HttpService")
lp=Pl.LocalPlayer; pg=lp:WaitForChild("PlayerGui")

-- ── LOADER ──────────────────────────────────────────────────
do
	local G=Instance.new("ScreenGui",pg); G.Name,G.ResetOnSpawn,G.IgnoreGuiInset,G.DisplayOrder="PanelLoad",false,true,999
	local function F(c,par,p) local o=Instance.new(c,par); if p then for k,v in pairs(p) do pcall(function()o[k]=v end) end end; return o end
	local card=F("Frame",G,{Size=UDim2.new(0,340,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(.5,-170,.5,-100),BackgroundColor3=Color3.fromRGB(13,13,13),ZIndex=100})
	F("UICorner",card,{CornerRadius=UDim.new(0,12)}); F("UIStroke",card,{Color=Color3.fromRGB(34,34,34),Thickness=1})
	F("UIPadding",card,{PaddingLeft=UDim.new(0,22),PaddingRight=UDim.new(0,22),PaddingTop=UDim.new(0,22),PaddingBottom=UDim.new(0,18)})
	F("UIListLayout",card,{Padding=UDim.new(0,0),SortOrder=Enum.SortOrder.LayoutOrder})
	local hdr=F("Frame",card,{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,LayoutOrder=1,ZIndex=101})
	local dot=F("Frame",hdr,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,0,.5,-4),BackgroundColor3=Color3.fromRGB(61,155,92),ZIndex=102}); F("UICorner",dot,{CornerRadius=UDim.new(1,0)})
	F("TextLabel",hdr,{Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.fromRGB(232,232,232),Text="BloxHub  v3",TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102})
	F("TextLabel",hdr,{Size=UDim2.new(0,60,1,0),Position=UDim2.new(1,-60,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=Color3.fromRGB(68,68,68),Text="Tab Edition",TextXAlignment=Enum.TextXAlignment.Right,ZIndex=102})
	F("Frame",card,{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,LayoutOrder=2})
	local barBg=F("Frame",card,{Size=UDim2.new(1,0,0,3),BackgroundColor3=Color3.fromRGB(26,26,26),LayoutOrder=3,ZIndex=101}); F("UICorner",barBg,{CornerRadius=UDim.new(1,0)})
	local barFl=F("Frame",barBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(61,155,92),ZIndex=102}); F("UICorner",barFl,{CornerRadius=UDim.new(1,0)})
	F("Frame",card,{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,LayoutOrder=4})
	local stF=F("Frame",card,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=5,ZIndex=101}); F("UIListLayout",stF,{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder})
	local sL={}; local sN={"Waiting for game","Game ready","Workspace ready","Leaderstats","Character ready","Enemies","Building GUI","Done"}
	for i,name in ipairs(sN) do
		local row=F("Frame",stF,{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=i,ZIndex=102})
		local d=F("Frame",row,{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,0,.5,-3.5),BackgroundColor3=Color3.fromRGB(58,58,58),ZIndex=103}); F("UICorner",d,{CornerRadius=UDim.new(1,0)})
		sL[i]={dot=d,name=F("TextLabel",row,{Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,17,0,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(85,85,85),Text=name,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=103}),status=F("TextLabel",row,{Size=UDim2.new(0,50,1,0),Position=UDim2.new(1,-50,0,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=Color3.fromRGB(68,68,68),Text="—",TextXAlignment=Enum.TextXAlignment.Right,ZIndex=103})}
	end
	F("Frame",card,{Size=UDim2.new(1,0,0,12),BackgroundTransparency=1,LayoutOrder=6})
	F("Frame",card,{Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(28,28,28),LayoutOrder=7,ZIndex=101})
	F("Frame",card,{Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,LayoutOrder=8})
	local footer=F("Frame",card,{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,LayoutOrder=9,ZIndex=101})
	F("TextLabel",footer,{Size=UDim2.new(0,100,1,0),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=Color3.fromRGB(60,60,60),Text="v3 • Panel",TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102})
	local pcLbl=F("TextLabel",footer,{Size=UDim2.new(0,50,1,0),Position=UDim2.new(1,-50,0,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Color3.fromRGB(61,155,92),Text="0%",TextXAlignment=Enum.TextXAlignment.Right,ZIndex=102})
	local n,tot=0,8
	local function log()
		n+=1; local p=math.clamp(n/tot,0,1)
		if n>1 and sL[n-1] then sL[n-1].dot.BackgroundColor3=Color3.fromRGB(61,155,92); sL[n-1].status.TextColor3=Color3.fromRGB(61,155,92); sL[n-1].status.Text="done"; sL[n-1].name.TextColor3=Color3.fromRGB(136,136,136) end
		if sL[n] then sL[n].dot.BackgroundColor3=Color3.fromRGB(61,155,92); sL[n].name.TextColor3=Color3.fromRGB(190,190,190); sL[n].status.Text="—" end
		pcLbl.Text=math.floor(p*100).."%"; TS:Create(barFl,TweenInfo.new(.18),{Size=UDim2.new(p,0,1,0)}):Play(); task.wait(.05)
	end
	log(); if not game:IsLoaded() then game.Loaded:Wait() end
	for _,v in ipairs(pg:GetChildren()) do if v.Name=="IntegratedStatusHUD" then v:Destroy() end end
	log(); local mw=0; repeat task.wait(.1);mw+=.1 until WS:FindFirstChildOfClass("Terrain") or mw>5; log()
	local lw=0; repeat task.wait(.2);lw+=.2 until lp:FindFirstChild("leaderstats") or lp:FindFirstChild("Data") or lw>8; log()
	if not lp.Character then local cw=0; repeat task.wait(.1);cw+=.1 until lp.Character or cw>8 end; log()
	local ew=0; repeat task.wait(.2);ew+=.2 until WS:FindFirstChild("Enemies") or ew>6; log()
	log(); task.wait(.05)
	_closeLoader=function()
		if sL[n] then sL[n].dot.BackgroundColor3=Color3.fromRGB(61,155,92); sL[n].status.TextColor3=Color3.fromRGB(61,155,92); sL[n].status.Text="done" end
		pcLbl.Text="100%"; TS:Create(barFl,TweenInfo.new(.2),{Size=UDim2.new(1,0,1,0)}):Play(); task.wait(.7)
		TS:Create(card,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Position=UDim2.new(.5,-170,.6,-100),BackgroundTransparency=1}):Play()
		for _,s in ipairs(sL) do pcall(function() TS:Create(s.name,TweenInfo.new(.2),{TextTransparency=1}):Play(); TS:Create(s.status,TweenInfo.new(.2),{TextTransparency=1}):Play(); TS:Create(s.dot,TweenInfo.new(.2),{BackgroundTransparency=1}):Play() end) end
		task.wait(.35); G:Destroy()
	end
end

-- ── CONFIG ───────────────────────────────────────────────────
local cfg={
	RemoveDeathEffect=true,LockFps={on=true,fps=10},
	BoostV1=false,BoostV2=false,BoostV3=true,
	HidePlayers=false,HideEnemies=true,
	AutoHop=false,HopInterval=45,HopServer="singapore",HopMaxPlayers=3,
	WebhookEnabled=false,
	WebhookURL="https://discord.com/api/webhooks/1426870143916707840/1d9rXLCZSRTlnTBE-V0AX0CxgQLodNt-zXXSggbS6MjFpPKMTfbNR8V1VrhCcm4wgnmh",
	WebhookName="Panel",WebhookInterval=30,
	AutoRerunURL="https://raw.githubusercontent.com/mm3xwqi/s/refs/heads/main/PanelBF.lua",
	AutoRerun=true,
	MilestoneBeli={1000000,5000000,10000000,50000000},
	MilestoneFrag={10000,50000,100000,500000},
	HealthFPSThreshold=30,HealthLagDuration=10,PerfBaselineBPM=50000,
}

-- ── COLORS / CONSTANTS ───────────────────────────────────────
local C={
	BG=Color3.fromRGB(6,6,6),PAN=Color3.fromRGB(10,10,10),CARD=Color3.fromRGB(20,20,20),
	HOV=Color3.fromRGB(28,28,28),SEP=Color3.fromRGB(40,40,40),BOR=Color3.fromRGB(55,55,55),
	BOR2=Color3.fromRGB(80,80,80),WHT=Color3.fromRGB(200,200,200),OFF=Color3.fromRGB(185,185,185),
	MUT=Color3.fromRGB(130,130,130),DIM=Color3.fromRGB(95,95,95),
	OK=Color3.fromRGB(70,155,90),WRN=Color3.fromRGB(185,145,50),ERR=Color3.fromRGB(185,70,70),
	BELI=Color3.fromRGB(65,155,90),FRAG=Color3.fromRGB(125,65,185),
	HOP=Color3.fromRGB(175,55,125),WH=Color3.fromRGB(55,120,185),PULL=Color3.fromRGB(185,65,65),
	V1=Color3.fromRGB(50,130,185),V2=Color3.fromRGB(185,135,40),V3=Color3.fromRGB(185,65,145),
	TABON=Color3.fromRGB(70,155,90),TABOFF=Color3.fromRGB(15,15,15),
	FAKE=Color3.fromRGB(185,110,40),BM2=Color3.fromRGB(185,100,0),RERUN=Color3.fromRGB(40,140,185),
	SPEC=Color3.fromRGB(80,160,220),
}
local K={HW=500,HH=600,PAD=10,COMBAT=2800,MAX=Pl.MaxPlayers,S2M=0.28,HMAX=60,HINT=10,TAB_H=36}
K.IW=K.HW-K.PAD*2

-- ── STATE ────────────────────────────────────────────────────
local S={
	v1=false,v2=false,v3=false,
	hidPlr=cfg.HidePlayers,hidPlrData={},hidPlrCC={},hidPlrC={},
	hidEnm=cfg.HideEnemies,hidEnmP={},enmConn=nil,
	hop=cfg.AutoHop,hopThread=nil,hopCD=cfg.HopInterval*60,hopTick=tick(),hopTotal=0,hopTarget=cfg.HopServer:lower(),
	wh=cfg.WebhookEnabled,whTimer=false,whThread=nil,whCD=cfg.WebhookInterval*60,whTick=tick(),whTotal=0,
	sessB=nil,sessF=nil,sessOK=false,beliHist={},fragHist={},
	fps=0,fc=0,fpsT=tick(),drag=false,dragS=nil,dragP=nil,
	last={},lastSz={},lastCol={},barTw={},colTw={},
	selfHL=nil,start=tick(),statC={},skillC={},plrC={[lp.UserId]={join=tick()}},
	spawnW={},raceW={},bountyW={},
	v1Parts={},v1Conn=nil,v2Orig={},v2Conn=nil,v2CharConn=nil,v3Conns={},
	fakeLevel=false,fakeLevelVal=nil,fakeLevelThread=nil,
	activeTab="status",rerun=false,rerunThread=nil,
	specTarget=nil,specConn=nil,specCharConn=nil,
	infJump=false,infJumpConn=nil,speedMult=1,
	logs={},events={},
	milestone={beliReached={},fragReached={}},
	health={fpsHist={},instanceCount=0,lagDetected=false,lagTick=0,reportSent=false,lastCheck=0,avgFPS=60},
}
local BM={on=false,task=nil,data={},noclip=nil,pin=nil,dist=500,batch=20,force=150000,snap=12,yOff=-15}
local BM2={on=false,task=nil,dist=500,interval=0.05,anchorPos=nil,resetInterval=60,resetTick=0,maxCount=10}
local bmTick=0; local BASE_WS=16

-- ── CORE HELPERS ─────────────────────────────────────────────
local function mk(cl,par,props)
	local o=Instance.new(cl); if par then o.Parent=par end
	if props then for k,v in pairs(props) do pcall(function()o[k]=v end) end end; return o
end
local function corner(p,r) return mk("UICorner",p,{CornerRadius=UDim.new(0,r or 5)}) end
local function stroke(p,c,t) return mk("UIStroke",p,{Color=c or C.BOR,Thickness=t or 1}) end
local function tw(o,p,d) TS:Create(o,TweenInfo.new(d or .2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
local function setText(lb,v) if lb and S.last[lb]~=v then S.last[lb]=v;lb.Text=v end end
local function setCol(lb,c)
	if not lb or S.lastCol[lb]==c then return end; S.lastCol[lb]=c
	if S.colTw[lb] then S.colTw[lb]:Cancel() end
	S.colTw[lb]=TS:Create(lb,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextColor3=c}); S.colTw[lb]:Play()
end
local function setBar(f,sc)
	local sv=math.clamp(sc,0,1); if S.lastSz[f]==sv then return end; S.lastSz[f]=sv
	if S.barTw[f] then S.barTw[f]:Cancel() end
	S.barTw[f]=TS:Create(f,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(sv,0,1,0)}); S.barTw[f]:Play()
end
local function tog(b,on,onC,offC,onT,offT) tw(b,{BackgroundColor3=on and onC or offC},.18); b.Text=on and onT or offT; b.TextColor3=on and C.BG or C.MUT end
local function addHov(b,getC) b.MouseEnter:Connect(function()tw(b,{BackgroundColor3=C.HOV},.12)end); b.MouseLeave:Connect(function()tw(b,{BackgroundColor3=getC()},.12)end) end

-- ── FORMAT HELPERS ───────────────────────────────────────────
local function fmtN(n) if type(n)~="number" then return"?" end; return tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","") end
local function fmtV(v,k) if type(v)~="number" then return tostring(v or"?") end; if k=="Beli" or k=="Fragments" or k=="Level" then return fmtN(v) end; if v>=1e6 then return("%.1fM"):format(v/1e6) elseif v>=1e3 then return("%.1fK"):format(v/1e3) else return tostring(math.floor(v)) end end
local function fmtS(n) n=math.max(0,math.floor(n)); local h=math.floor(n/3600);n=n%3600;local m=math.floor(n/60);n=n%60; return h>0 and("%dh %02dm %02ds"):format(h,m,n) or m>0 and("%dm %02ds"):format(m,n) or("%ds"):format(n) end
local function wFmt(n) return(n<0 and"-" or"+")..tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","") end
local function getPing() local ok,p=pcall(function()return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]end); return ok and type(p)=="number" and math.floor(p) or math.floor(lp:GetNetworkPing()*1000) end
local function ts() local ok,s=pcall(function()return os.date("!%Y-%m-%dT%H:%M:%SZ")end); return ok and s or nil end
local function localT() local ok,s=pcall(function()return os.date("%Y-%m-%d %H:%M:%S")end); return ok and s or("~"..math.floor(tick())) end
local function serverT(jt) if not jt then return"In server: ?" end; local e=math.floor(tick()-jt);local h=math.floor(e/3600);local m=math.floor((e%3600)/60);local sc=e%60; return h>0 and("In server: %dh %02dm %02ds"):format(h,m,sc) or m>0 and("In server: %dm %02ds"):format(m,sc) or("In server: %ds"):format(sc) end
local function statBar(v,cap) if not v then return string.rep("-",12).." ?" end; local f=math.floor(math.clamp(v/cap,0,1)*12); return string.rep("|",f)..string.rep("-",12-f).."  "..fmtN(v) end
local function fmtSpawn(s) if not s or s=="" then return"Unknown" end; s=tostring(s):gsub("([a-z])([A-Z])","%1 %2"):gsub("_"," "):gsub("(%a)([%w]*)",function(f2,r)return f2:upper()..r:lower()end); return s end
local function pushH(t,v) if type(v)~="number" then return end; t[#t+1]={t=tick(),v=v}; while #t>K.HMAX do table.remove(t,1) end end
local function calcRate(t) if #t<2 then return 0 end; local e=t[#t].t-t[1].t; if e<1 then return 0 end; return math.floor((t[#t].v-t[1].v)/(e/60)) end
local function emojiBar(val,maxV,len) len=len or 10;local p=math.clamp(math.floor((val/math.max(maxV,1))*len),0,len); return string.rep("🟩",p)..string.rep("⬛",len-p) end
local function perfColor(b) local base=cfg.PerfBaselineBPM or 50000; return b>=base and 3066993 or b>=base*.5 and 16776960 or 15158332 end

-- ── STAT PATHS / RESOLVE ─────────────────────────────────────
local SPATHS={
	Level={"Data.Level","leaderstats.Level","leaderstats.Lv."},
	Beli={"Data.Beli","leaderstats.Beli","leaderstats.Money"},
	Fragments={"Data.Fragments","leaderstats.Fragments","leaderstats.Fragment"},
	Melee={"leaderstats.Melee","Data.Stats.Melee.Level"},
	Defense={"leaderstats.Defense","Data.Stats.Defense.Level"},
	Sword={"leaderstats.Sword","Data.Stats.Sword.Level"},
	Gun={"leaderstats.Gun","Data.Stats.Gun.Level"},
	["Blox Fruit"]={"leaderstats.Blox Fruit","leaderstats.Demon Fruit","Data.Stats.Demon Fruit.Level","Data.Stats.Blox Fruit.Level"},
	Bounty={"leaderstats.Bounty/Honor","leaderstats.Bounty","leaderstats.Honor"},
	SpawnPoint={"Data.LastSpawnPoint"},
}
local function resolvePath(root,path) local obj=root; for part in path:gmatch("[^%.]+") do if not obj then return nil end;obj=obj:FindFirstChild(part) end; if obj and obj:IsA("ValueBase") then return obj end end
local function getStatObj(plr,key) local uid=plr.UserId;S.statC[uid]=S.statC[uid] or{};if S.statC[uid][key] then return S.statC[uid][key] end; for _,path in ipairs(SPATHS[key] or{"leaderstats."..key,"Data."..key}) do local obj=resolvePath(plr,path);if obj then S.statC[uid][key]=obj;return obj end end end
local function getStat(key,root) local obj=getStatObj(root or lp,key); return obj and obj.Value or nil end

-- ── FAKE LEVEL ────────────────────────────────────────────────
local _realLevel=nil
local function getRealLevelObj() for _,fn in ipairs({function()return lp.Data.Level end,function()return lp.leaderstats.Level end,function()return lp.leaderstats.Lv end}) do local ok,obj=pcall(fn);if ok and obj and obj:IsA("ValueBase") then return obj end end end
task.spawn(function()task.wait(2);local obj=getRealLevelObj();if obj then _realLevel=obj.Value end end)
local function stopFakeLevel()
	S.fakeLevel=false;S.fakeLevelVal=nil
	if S.fakeLevelThread then pcall(function()task.cancel(S.fakeLevelThread)end);S.fakeLevelThread=nil end
	local obj=getRealLevelObj();if obj and _realLevel then pcall(function()obj.Value=_realLevel end) end
end
local function startFakeLevel(targetVal)
	stopFakeLevel();local obj=getRealLevelObj()
	if obj then _realLevel=obj.Value;pcall(function()obj.Value=targetVal end) end
	S.fakeLevel=true;S.fakeLevelVal=targetVal
	S.fakeLevelThread=task.spawn(function()
		local conns={}
		for _,fn in ipairs({function()return lp.Data.Level end,function()return lp.leaderstats.Level end,function()return lp.leaderstats.Lv end}) do
			local ok,o=pcall(fn);if ok and o and o:IsA("ValueBase") then conns[#conns+1]=o.Changed:Connect(function(v)if S.fakeLevel and v~=targetVal then pcall(function()o.Value=targetVal end) end end) end
		end
		while S.fakeLevel do task.wait(1) end
		for _,c in ipairs(conns) do pcall(function()c:Disconnect()end) end
	end)
end

-- ── SPECTATE ─────────────────────────────────────────────────
local cam=WS.CurrentCamera
local function stopSpec()
	if S.specConn then S.specConn:Disconnect();S.specConn=nil end
	if S.specCharConn then S.specCharConn:Disconnect();S.specCharConn=nil end
	S.specTarget=nil
	pcall(function()cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") or nil end)
end
local function startSpec(p)
	if not p or p==lp then return end; stopSpec();S.specTarget=p
	local function attachCamera(char) if not char then return end;local hum=char:FindFirstChildOfClass("Humanoid");if not hum then return end;pcall(function()cam.CameraType=Enum.CameraType.Follow;cam.CameraSubject=hum end) end
	if p.Character then attachCamera(p.Character) end
	S.specCharConn=p.CharacterAdded:Connect(function(char)task.wait(.5);if S.specTarget==p then attachCamera(char) end end)
	S.specConn=Run.RenderStepped:Connect(function()
		if not S.specTarget then S.specConn:Disconnect();S.specConn=nil;return end
		local ok=false;for _,pl in ipairs(Pl:GetPlayers()) do if pl==S.specTarget then ok=true;break end end;if not ok then stopSpec() end
	end)
end

-- ── NOTIFICATIONS ────────────────────────────────────────────
local gui=mk("ScreenGui",pg,{Name="IntegratedStatusHUD",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=10})
local NW,NH,NGAP,NMAX=260,44,6,5; local activeNotifs={}
local function recalcNotifPositions() for i,e in ipairs(activeNotifs) do tw(e.frame,{Position=UDim2.new(1,-(NW+10),0,60+(i-1)*(NH+NGAP))},.2) end end
local function showN(name,sub,col)
	if #activeNotifs>=NMAX then
		local old=table.remove(activeNotifs,1)
		tw(old.frame,{Position=UDim2.new(1,NW+10,0,old.frame.Position.Y.Offset),BackgroundTransparency=1},.2)
		for _,c in ipairs(old.frame:GetDescendants()) do pcall(function()if c:IsA("TextLabel") then tw(c,{TextTransparency=1},.2) elseif c:IsA("Frame") and c~=old.frame then tw(c,{BackgroundTransparency=1},.2) elseif c:IsA("UIStroke") then tw(c,{Transparency=1},.2) end end) end
		task.delay(.26,function()if old.frame and old.frame.Parent then old.frame:Destroy() end end)
	end
	local f=mk("Frame",gui,{Size=UDim2.new(0,NW,0,NH),Position=UDim2.new(1,NW+10,0,60),BackgroundColor3=C.PAN,BackgroundTransparency=1,ZIndex=60})
	stroke(f,C.BOR2,1);corner(f,6)
	mk("Frame",f,{Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,10,0,10),BackgroundColor3=col or C.OK,ZIndex=61});corner(f:FindFirstChildOfClass("Frame"),4)
	local function lbl2(sz2,py,col2,tx,sz3) return mk("TextLabel",f,{Size=UDim2.new(1,-28,0,sz3 or 12),Position=UDim2.new(0,24,0,py),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=sz2,TextColor3=col2,Text=tx,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=61}) end
	lbl2(11,4,C.WHT,name,16);lbl2(9,24,C.DIM,sub or"",12)
	for _,c in ipairs(f:GetDescendants()) do pcall(function()if c:IsA("TextLabel") then c.TextTransparency=1 elseif c:IsA("Frame") and c~=f then c.BackgroundTransparency=1 elseif c:IsA("UIStroke") then c.Transparency=1 end end) end
	local entry={frame=f};table.insert(activeNotifs,entry);recalcNotifPositions()
	tw(f,{BackgroundTransparency=0},.2)
	for _,c in ipairs(f:GetDescendants()) do pcall(function()if c:IsA("TextLabel") then tw(c,{TextTransparency=0},.2) elseif c:IsA("Frame") and c~=f then tw(c,{BackgroundTransparency=0},.2) elseif c:IsA("UIStroke") then tw(c,{Transparency=0},.2) end end) end
	task.delay(3,function()
		local idx=nil;for i,e in ipairs(activeNotifs) do if e==entry then idx=i;break end end;if not idx then return end
		table.remove(activeNotifs,idx);recalcNotifPositions()
		tw(f,{Position=UDim2.new(1,NW+10,0,f.Position.Y.Offset),BackgroundTransparency=1},.25)
		for _,c in ipairs(f:GetDescendants()) do pcall(function()if c:IsA("TextLabel") then tw(c,{TextTransparency=1},.25) elseif c:IsA("Frame") and c~=f then tw(c,{BackgroundTransparency=1},.25) elseif c:IsA("UIStroke") then tw(c,{Transparency=1},.25) end end) end
		task.delay(.3,function()if f and f.Parent then f:Destroy() end end)
	end)
end

-- ── BOOST V1 (hide map) ──────────────────────────────────────
local function setV1(on)
	if on then
		S.v1Parts={}
		task.spawn(function()
			local list=WS:GetDescendants()
			for i,v in ipairs(list) do pcall(function()if v:IsA("BasePart") and not v:IsDescendantOf(lp.Character or{}) then S.v1Parts[#S.v1Parts+1]={o=v,t=v.Transparency};v.Transparency=1 end end);if i%200==0 then task.wait() end end
		end)
		if S.v1Conn then S.v1Conn:Disconnect() end
		S.v1Conn=WS.DescendantAdded:Connect(function(v) pcall(function()if v:IsA("BasePart") and not v:IsDescendantOf(lp.Character or{}) then v.Transparency=1 end end) end)
	else
		if S.v1Conn then S.v1Conn:Disconnect();S.v1Conn=nil end
		task.spawn(function()for i,d in ipairs(S.v1Parts) do if d.o and d.o.Parent then pcall(function()d.o.Transparency=d.t end) end;if i%200==0 then task.wait() end end;S.v1Parts={} end)
	end
end

-- ── BOOST V2 (low graphics) ──────────────────────────────────
local function setV2(on)
	local L=game:GetService("Lighting")
	if on then
		S.v2Orig={GS=L.GlobalShadows,FE=L.FogEnd,FS=L.FogStart,SS=L.ShadowSoftness,BR=L.Brightness,AM=L.Ambient,OA=L.OutdoorAmbient,CT=L.ClockTime,QL=settings().Rendering.QualityLevel}
		L.GlobalShadows=false;L.FogEnd=9e9;L.FogStart=9e9;L.ShadowSoftness=0;L.Brightness=0
		L.Ambient=Color3.new(.5,.5,.5);L.OutdoorAmbient=Color3.new(.5,.5,.5);L.ClockTime=14
		pcall(function()sethiddenproperty(L,"Technology",2)end); settings().Rendering.QualityLevel=1
		local ter=WS:FindFirstChildOfClass("Terrain")
		if ter then S.v2Orig.WW=ter.WaterWaveSize;S.v2Orig.WS2=ter.WaterWaveSpeed;ter.WaterWaveSize=0;ter.WaterWaveSpeed=0;ter.WaterReflectance=0;ter.WaterTransparency=1 end
		for _,c in ipairs(L:GetChildren()) do if c:IsA("PostEffect") then c.Enabled=false end end
		local function stripObj(o)
			if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then o.Enabled=false;if o.Rate~=nil then o.Rate=0 end
			elseif o:IsA("Beam") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then o.Enabled=false
			elseif o:IsA("BillboardGui") or o:IsA("SurfaceGui") then o.Enabled=false
			elseif o:IsA("BasePart") and o:IsDescendantOf(WS) and not o:IsDescendantOf(lp.Character or{}) then o.Material=Enum.Material.SmoothPlastic;o.Reflectance=0;o.CastShadow=false
			elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
			elseif o:IsA("SpecialMesh") then o.TextureId=""
			elseif o:IsA("MeshPart") and not o:IsDescendantOf(lp.Character or{}) then o.TextureID="";o.RenderFidelity=Enum.RenderFidelity.Performance;o.CastShadow=false end
		end
		task.spawn(function()local list=game:GetDescendants();for i,o in ipairs(list) do pcall(stripObj,o);if i%200==0 then task.wait() end end end)
		if S.v2Conn then S.v2Conn:Disconnect() end
		S.v2Conn=game.DescendantAdded:Connect(function(o)if S.v2 then task.defer(function()pcall(stripObj,o)end) end end)
		if S.v2CharConn then S.v2CharConn:Disconnect() end
		S.v2CharConn=lp.CharacterAdded:Connect(function(char)task.wait(1);if not S.v2 then return end
			task.spawn(function()local list=char:GetDescendants();for i,o in ipairs(list) do pcall(function()if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Sparkles") then o.Enabled=false;if o.Rate~=nil then o.Rate=0 end elseif o:IsA("PointLight") or o:IsA("SpotLight") then o.Enabled=false end end);if i%50==0 then task.wait() end end end)
		end)
	else
		if S.v2Conn then S.v2Conn:Disconnect();S.v2Conn=nil end
		if S.v2CharConn then S.v2CharConn:Disconnect();S.v2CharConn=nil end
		local o=S.v2Orig
		if o.GS~=nil then L.GlobalShadows=o.GS end;if o.FE~=nil then L.FogEnd=o.FE end;if o.FS~=nil then L.FogStart=o.FS end
		if o.SS~=nil then L.ShadowSoftness=o.SS end;if o.BR~=nil then L.Brightness=o.BR end
		if o.AM~=nil then L.Ambient=o.AM end;if o.OA~=nil then L.OutdoorAmbient=o.OA end;if o.CT~=nil then L.ClockTime=o.CT end
		pcall(function()settings().Rendering.QualityLevel=o.QL or 5 end)
		local ter=WS:FindFirstChildOfClass("Terrain");if ter and o.WW~=nil then ter.WaterWaveSize=o.WW;ter.WaterWaveSpeed=o.WS2 end
		for _,c in ipairs(L:GetChildren()) do if c:IsA("PostEffect") then c.Enabled=true end end; S.v2Orig={}
	end
end

-- ── BOOST V3 (strip all visuals + skill effects) ─────────────
local GREY=Color3.fromRGB(163,162,165)
local function stripCharCosmetics(char)
	if not char then return end
	for _,obj in ipairs(char:GetChildren()) do pcall(function()if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then obj:Destroy() end end) end
	for _,obj in ipairs(char:GetDescendants()) do pcall(function()
		if obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1
		elseif obj:IsA("SpecialMesh") then obj.TextureId=""
		elseif obj:IsA("MeshPart") then obj.TextureID="";obj.RenderFidelity=Enum.RenderFidelity.Performance;obj.CastShadow=false;obj.Color=GREY
		elseif obj:IsA("BasePart") then obj.Material=Enum.Material.SmoothPlastic;obj.Reflectance=0;obj.CastShadow=false;obj.Color=GREY
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled=false;if obj:IsA("ParticleEmitter") then obj.Rate=0 end
		elseif obj:IsA("Beam") or obj:IsA("PointLight") or obj:IsA("SpotLight") then obj.Enabled=false
		end
	end) end
end
local function setV3(on)
	if on then
		task.spawn(function()
			local list=WS:GetDescendants()
			for i,o in ipairs(list) do
				pcall(function()
					if o:IsA("MeshPart") then o.RenderFidelity=Enum.RenderFidelity.Performance;o.CastShadow=false;o.TextureID="";o.Color=GREY
					elseif o:IsA("BasePart") then o.CastShadow=false;if o.Material~=Enum.Material.Neon and o.Material~=Enum.Material.ForceField then o.Material=Enum.Material.SmoothPlastic;o.Reflectance=0;o.Color=GREY end
					elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
					elseif o:IsA("SpecialMesh") then o.TextureId=""
					elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("Smoke") then o.Enabled=false;if o:IsA("ParticleEmitter") then o.Rate=0 end
					elseif o:IsA("Beam") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then o.Enabled=false
					elseif o:IsA("BillboardGui") or o:IsA("SurfaceGui") then o.Enabled=false
					elseif o:IsA("Sound") then if o.Name:lower():find("ambient") or o.Name:lower():find("music") then o.Volume=0 end end
				end)
				if i%200==0 then task.wait() end
			end
		end)
		stripCharCosmetics(lp.Character)
		S.v3Conns[1]=WS.DescendantAdded:Connect(function(o)
			if not S.v3 then return end
			task.defer(function()pcall(function()
				if o:IsA("MeshPart") then o.RenderFidelity=Enum.RenderFidelity.Performance;o.CastShadow=false;o.TextureID="";o.Color=GREY
				elseif o:IsA("BasePart") then o.CastShadow=false;if o.Material~=Enum.Material.Neon then o.Material=Enum.Material.SmoothPlastic;o.Reflectance=0;o.Color=GREY end
				elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("Smoke") then o.Enabled=false;if o:IsA("ParticleEmitter") then o.Rate=0 end
				elseif o:IsA("Beam") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then o.Enabled=false
				elseif o:IsA("Decal") or o:IsA("Texture") then o.Transparency=1
				elseif o:IsA("SpecialMesh") then o.TextureId=""
				elseif o:IsA("BillboardGui") or o:IsA("SurfaceGui") then o.Enabled=false
				end
			end)end)
		end)
		S.v3Conns[2]=lp.CharacterAdded:Connect(function(char)task.wait(.5);if S.v3 then stripCharCosmetics(char) end end)
		S.v3Conns[3]=lp.CharacterAdded:Connect(function(char)
			task.wait(.3);if not S.v3 then return end
			char.ChildAdded:Connect(function(child)if not S.v3 then return end;pcall(function()if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then task.wait(.1);if S.v3 then child:Destroy() end end end) end)
		end)
		if lp.Character then lp.Character.ChildAdded:Connect(function(child)if not S.v3 then return end;pcall(function()if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then task.wait(.1);if S.v3 then child:Destroy() end end end) end) end
	else
		for _,c in ipairs(S.v3Conns) do pcall(function()c:Disconnect()end) end; S.v3Conns={}
	end
end

-- ── HIDE PLAYERS / ENEMIES ───────────────────────────────────
local function setPlrVis(p,vis) if not vis then if S.hidPlrData[p.UserId] then return end;S.hidPlrData[p.UserId]=true;pcall(function()if p.Character then p.Character:Destroy() end end) else S.hidPlrData[p.UserId]=nil end end
local function toggleHidePlr(on)
	S.hidPlr=on; for _,p in ipairs(Pl:GetPlayers()) do if p~=lp then setPlrVis(p,not on) end end
	if on then
		for _,p in ipairs(Pl:GetPlayers()) do if p~=lp then if S.hidPlrC[p.UserId] then S.hidPlrC[p.UserId]:Disconnect() end; S.hidPlrC[p.UserId]=p.CharacterAdded:Connect(function()S.hidPlrData[p.UserId]=nil;if S.hidPlr then task.wait(.5);setPlrVis(p,false) end end) end end
		if not S.hidPlrCC.pa then S.hidPlrCC.pa=Pl.PlayerAdded:Connect(function(p)if p==lp then return end;task.spawn(function()if not p.Character then p.CharacterAdded:Wait() end;task.wait(.5);if S.hidPlr then setPlrVis(p,false) end end) end) end
	else
		if S.hidPlrCC.pa then S.hidPlrCC.pa:Disconnect();S.hidPlrCC.pa=nil end
		for uid,c in pairs(S.hidPlrC) do c:Disconnect();S.hidPlrC[uid]=nil end
	end
end
local function toggleHidEnm(on)
	S.hidEnm=on; local ef=WS:FindFirstChild("Enemies");if not ef then return end
	for _,o in ipairs(ef:GetDescendants()) do if o:IsA("BasePart") then if on then if S.hidEnmP[o]==nil then S.hidEnmP[o]=o.Transparency;o.Transparency=1 end else if S.hidEnmP[o]~=nil then if o.Parent then o.Transparency=S.hidEnmP[o] end;S.hidEnmP[o]=nil end end end end
	if on then S.enmConn=S.enmConn or ef.DescendantAdded:Connect(function(o)if S.hidEnm and o:IsA("BasePart") then task.wait(.1);if S.hidEnmP[o]==nil and o.Parent then S.hidEnmP[o]=o.Transparency;o.Transparency=1 end end end)
	else if S.enmConn then S.enmConn:Disconnect();S.enmConn=nil end; for p,t in pairs(S.hidEnmP) do if p and p.Parent then pcall(function()p.Transparency=t end) end end; S.hidEnmP={} end
end

-- ── BRINGMOB V1 ──────────────────────────────────────────────
local function bmHRP(e) return e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso") end
local function bmHum(e) return e:FindFirstChildOfClass("Humanoid") end
local function bmAlive(e) local h=bmHum(e);return h and h.Health>0 end
local function bmRelease(e)
	local d=BM.data[e];if not d then return end
	for _,k in ipairs({"bp","bv","bg"}) do if d[k] and d[k].Parent then pcall(function()d[k]:Destroy()end) end end
	local hrp=bmHRP(e)
	if hrp then for _,c in ipairs(hrp:GetChildren()) do if c.Name:find("BringMob") then pcall(function()c:Destroy()end) end end;pcall(function()hrp.Anchored=false;hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end) end
	local h=bmHum(e);if h then pcall(function()h.PlatformStand=false;h.WalkSpeed=16;h.JumpPower=50 end) end
	if e.Parent then for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then pcall(function()p.CanCollide=true end) end end end
	BM.data[e]=nil
end
local function bmClean() for e in pairs(BM.data) do pcall(bmRelease,e) end;BM.data={} end
local function bmGetOff() local a=math.random()*math.pi*2;local r=math.random(2,5);return Vector3.new(math.cos(a)*r,0,math.sin(a)*r) end
local function bmMyRoot() local c=lp.Character;return c and c:FindFirstChild("HumanoidRootPart") end
local function startBM()
	BM.on=true;bmClean()
	if BM.noclip then BM.noclip:Disconnect() end
	BM.noclip=Run.Heartbeat:Connect(function()for e in pairs(BM.data) do if e and e.Parent then for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then pcall(function()p.CanCollide=false end) end end end end end)
	if BM.pin then BM.pin:Disconnect() end; bmTick=0
	BM.pin=Run.Heartbeat:Connect(function()
		bmTick+=1;if bmTick%2~=0 then return end
		local mr=bmMyRoot();if not mr then return end
		for e,d in pairs(BM.data) do
			if not e or not e.Parent or not d or not d.arrived then continue end
			local hrp=bmHRP(e);if not hrp then continue end
			d.anchorPos=d.anchorPos or mr.Position
			if(mr.Position-d.anchorPos).Magnitude>3 then
				d.anchorPos=mr.Position; local nt=Vector3.new((mr.Position+d.offset).X,mr.Position.Y+BM.yOff,(mr.Position+d.offset).Z); d.fixedPos=nt
				if d.bp and d.bp.Parent then pcall(function()d.bp.Position=nt end) else d.bp=mk("BodyPosition",hrp,{Name="BringMobBP_Fixed",MaxForce=Vector3.new(1e9,1e9,1e9),P=500000,D=10000,Position=nt}) end
			end
			if d.bp and d.bp.Parent then local cur=d.bp.Position;pcall(function()d.bp.Position=Vector3.new(cur.X,mr.Position.Y+BM.yOff,cur.Z)end) end
			if not d.bg or not d.bg.Parent then d.bg=mk("BodyGyro",hrp,{Name="BringMobBG",MaxTorque=Vector3.new(1e9,1e9,1e9),P=100000,D=2000,CFrame=hrp.CFrame}) end
			pcall(function()hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero end)
		end
	end)
	BM.task=task.spawn(function()
		local PULL,HOLD=5,3;local phase="pull";local pT=0;local lt=tick()
		while BM.on do
			task.wait(.025);local now=tick();local dt=now-lt;lt=now;pT+=dt
			local mr=bmMyRoot();if not mr then continue end
			local ap=mr.Position;local ef=WS:FindFirstChild("Enemies");if not ef then task.wait(.3);continue end
			for e in pairs(BM.data) do if not e or not e.Parent or not bmAlive(e) then pcall(bmRelease,e) end end
			if phase=="pull" and pT>=PULL then
				for e,d in pairs(BM.data) do if not d.arrived then
					local hrp=bmHRP(e);if hrp then
						pcall(function()if d.bp and d.bp.Parent then d.bp:Destroy() end end)
						local fbp=mk("BodyPosition",hrp,{Name="BringMobBP_Fixed",MaxForce=Vector3.new(1e9,1e9,1e9),P=500000,D=10000,Position=hrp.Position})
						local bg=mk("BodyGyro",hrp,{Name="BringMobBG",MaxTorque=Vector3.new(1e9,1e9,1e9),P=100000,D=2000,CFrame=hrp.CFrame})
						pcall(function()local h=bmHum(e);if h then h.PlatformStand=true;h.WalkSpeed=0;h.JumpPower=0 end end)
						d.bp=fbp;d.bg=bg;d.arrived=true;d.fixedPos=hrp.Position
					end
				end end
				phase="hold";pT=0
			elseif phase=="hold" and pT>=HOLD then bmClean();phase="pull";pT=0 end
			if phase=="hold" then continue end
			local pulling=0;for _,d in pairs(BM.data) do if not d.arrived then pulling+=1 end end
			for _,e in ipairs(ef:GetChildren()) do
				if not BM.on then break end
				if not e or not e.Parent or not bmAlive(e) then continue end
				local hrp=bmHRP(e);if not hrp then continue end
				if(ap-hrp.Position).Magnitude>BM.dist then if BM.data[e] and not BM.data[e].arrived then pcall(bmRelease,e) end;continue end
				if not BM.data[e] then
					if pulling>=BM.batch then continue end
					local off=bmGetOff();local tp=Vector3.new((ap+off).X,ap.Y+BM.yOff,(ap+off).Z)
					local bp=mk("BodyPosition",hrp,{Name="BringMobBP",MaxForce=Vector3.new(1e9,1e9,1e9),P=BM.force,D=2000,Position=tp})
					pcall(function()local h=bmHum(e);if h then h.PlatformStand=true;h.WalkSpeed=0;h.JumpPower=0 end end)
					pcall(function()for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
					BM.data[e]={bp=bp,arrived=false,offset=off,stuckTime=0,lastPos=hrp.Position};pulling+=1
				end
				local d=BM.data[e];if not d or not d.bp or not d.bp.Parent then pcall(bmRelease,e);continue end
				if d.arrived then continue end
				local tp=Vector3.new((ap+d.offset).X,ap.Y+BM.yOff,(ap+d.offset).Z)
				local dist2=(hrp.Position-tp).Magnitude;local moved=(hrp.Position-d.lastPos).Magnitude;d.lastPos=hrp.Position
				d.stuckTime=moved<.05 and d.stuckTime+.025 or 0
				pcall(function()d.bp.Position=tp end)
				if dist2<=BM.snap then
					pcall(function()d.bp:Destroy()end);pcall(function()hrp.AssemblyLinearVelocity=Vector3.zero end)
					local bv=mk("BodyVelocity",hrp,{Name="BringMobBV",MaxForce=Vector3.new(1e9,1e9,1e9),Velocity=Vector3.zero}); task.wait()
					local fbp=mk("BodyPosition",hrp,{Name="BringMobBP_Fixed",MaxForce=Vector3.new(1e9,1e9,1e9),P=500000,D=10000,Position=hrp.Position})
					local bg=mk("BodyGyro",hrp,{Name="BringMobBG",MaxTorque=Vector3.new(1e9,1e9,1e9),P=100000,D=2000,CFrame=hrp.CFrame})
					pcall(function()local h=bmHum(e);if h then h.PlatformStand=true;h.WalkSpeed=0;h.JumpPower=0 end end)
					task.delay(.5,function()if bv and bv.Parent then pcall(function()bv:Destroy()end) end end)
					d.bp=fbp;d.bg=bg;d.bv=bv;d.arrived=true;d.fixedPos=hrp.Position
				elseif d.stuckTime>=0.7 then d.offset=bmGetOff();pcall(function()d.bp.P=100000 end);d.stuckTime=0 end
			end
		end
		if BM.pin then BM.pin:Disconnect();BM.pin=nil end
		if BM.noclip then BM.noclip:Disconnect();BM.noclip=nil end
		bmClean();BM.task=nil
	end)
end
local function stopBM()
	BM.on=false
	if BM.task then task.cancel(BM.task);BM.task=nil end
	if BM.pin then BM.pin:Disconnect();BM.pin=nil end
	if BM.noclip then BM.noclip:Disconnect();BM.noclip=nil end
	bmClean()
end

-- ── BRINGMOB V2 ──────────────────────────────────────────────
local bm2XBox,bm2YBox,bm2ZBox
local function stopBM2() BM2.on=false;if BM2.task then BM2.task:Disconnect();BM2.task=nil end end
local function startBM2()
	stopBM2();BM2.on=true;BM2.resetTick=tick()
	local bm2Warped={};local nf,wf=0,0;local WARP_EVERY=math.max(1,math.floor(BM2.interval/(1/60)))
	BM2.task=Run.Stepped:Connect(function()
		if not BM2.on then return end; nf+=1;wf+=1
		if nf>=5 then nf=0;local ef=WS:FindFirstChild("Enemies");if ef then for _,e in ipairs(ef:GetChildren()) do if e and e.Parent then for _,p in ipairs(e:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end end end end end
		if wf<WARP_EVERY then return end;wf=0
		local char=lp.Character;if not char then return end
		local myHRP=char:FindFirstChild("HumanoidRootPart");if not myHRP then return end
		local anchor=BM2.anchorPos or myHRP.Position;local targetY=anchor.Y+BM.yOff
		if BM2.resetInterval>0 and(tick()-BM2.resetTick)>=BM2.resetInterval then BM2.resetTick=tick();bm2Warped={} end
		local ef=WS:FindFirstChild("Enemies");if not ef then return end
		local warpedCount=0
		for e in pairs(bm2Warped) do if e and e.Parent then local hum=e:FindFirstChildOfClass("Humanoid");if hum and hum.Health>0 then warpedCount+=1 end else bm2Warped[e]=nil end end
		for _,e in ipairs(ef:GetChildren()) do
			if not e or not e.Parent then continue end
			local hrp=e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("Torso");if not hrp then continue end
			local hum=e:FindFirstChildOfClass("Humanoid");if not hum or hum.Health<=0 then bm2Warped[e]=nil;continue end
			local ok,d=pcall(function()return(anchor-hrp.Position).Magnitude end);if not ok or d>BM2.dist then continue end
			if not bm2Warped[e] then if warpedCount>=BM2.maxCount then continue end;bm2Warped[e]=true;warpedCount+=1 end
			pcall(function()hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero;hrp.CFrame=CFrame.new(anchor.X,targetY,anchor.Z);hrp.AssemblyLinearVelocity=Vector3.zero end)
			pcall(function()hum.WalkSpeed=0;hum.JumpPower=0;hum.PlatformStand=true end)
		end
	end)
end

-- ── MOVEMENT ─────────────────────────────────────────────────
local function setInfJump(on)
	if S.infJumpConn then S.infJumpConn:Disconnect();S.infJumpConn=nil end; S.infJump=on
	if on then S.infJumpConn=UIS.JumpRequest:Connect(function()local char=lp.Character;if not char then return end;local hum=char:FindFirstChildOfClass("Humanoid");if hum and hum:GetState()~=Enum.HumanoidStateType.Dead then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
end
local function applySpeed(mult)
	S.speedMult=math.max(1,mult);local char=lp.Character;if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid");if hum then pcall(function()hum.WalkSpeed=BASE_WS*S.speedMult end) end
end

-- ── EVENTS / LOGS ────────────────────────────────────────────
local function addEvent(evType,detail,col) table.insert(S.events,1,{time=localT(),tick=tick(),evType=evType,detail=detail or"",col=col or C.DIM});if #S.events>100 then table.remove(S.events) end end
local function addLog(source)
	local b=getStat("Beli") or 0;local f=getStat("Fragments") or 0
	local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick();local elapsed=tick()-jt
	local sessBeli=S.sessOK and math.floor(b-(S.sessB or b)) or 0;local sessFrags=S.sessOK and math.floor(f-(S.sessF or f)) or 0
	local minIn=math.max(elapsed/60,.01)
	table.insert(S.logs,1,{time=localT(),source=source or"Manual",beli=sessBeli,frags=sessFrags,elapsed=elapsed,bPM=math.floor(sessBeli/minIn),fPM=math.floor(sessFrags/minIn)})
	if #S.logs>50 then table.remove(S.logs) end
end

-- ── WEBHOOK ──────────────────────────────────────────────────
local function _sendWH(url,payload)
	local ok2,json=pcall(function()return HTTP:JSONEncode(payload)end);if not ok2 then return end
	local opts={Url=url,Method="POST",Headers={["Content-Type"]="application/json"},Body=json};local sent=false
	local function tryR(fn) if sent or not fn then return end;local ok3,r=pcall(fn,opts);if ok3 and r then sent=true end end
	tryR(typeof(request)=="function" and request);tryR(typeof(http_request)=="function" and http_request)
	tryR(syn and typeof(syn.request)=="function" and syn.request);tryR(http and typeof(http.request)=="function" and http.request)
	tryR(getgenv and typeof(getgenv().request)=="function" and getgenv().request);tryR(fluxus and typeof(fluxus.request)=="function" and fluxus.request)
end
local SKILL_KEYS={"Z","X","C","V","F"}
local function getToolLv(o) local lv;pcall(function()local lo=o:FindFirstChild("Level") or o:FindFirstChildOfClass("NumberValue") or o:FindFirstChildOfClass("IntValue");if lo then lv=lo.Value end end);return lv end
local function getEquipped() local c=lp.Character;if not c then return"None",nil end;for _,o in ipairs(c:GetChildren()) do if o:IsA("Tool") then return o.Name,getToolLv(o) end end;return"None",nil end
local function getInv() local items={};local bp=lp:FindFirstChild("Backpack");if not bp then return items end;for _,o in ipairs(bp:GetChildren()) do if o:IsA("Tool") and o.Name~="Tool" then local lv=getToolLv(o);if lv~=nil then items[#items+1]={name=o.Name,level=lv} end end end;return items end
local function getSkillLevels(name)
	if S.skillC[name] and next(S.skillC[name]) then return S.skillC[name] end
	local res={}
	pcall(function()
		local main=pg:FindFirstChild("Main");if not main then return end
		local sf=main:FindFirstChild("Skills");if not sf then return end
		local iF=sf:FindFirstChild(name);if not iF then return end
		for _,child in ipairs(iF:GetChildren()) do
			if child.Name=="Template" or not child:IsA("Frame") then continue end
			local lo=child:FindFirstChild("Level");if lo then local v; if lo:IsA("TextLabel") or lo:IsA("TextButton") then v=tonumber(lo.Text:match("%d+")) elseif lo:IsA("IntValue") or lo:IsA("NumberValue") then v=lo.Value end; if v then res[child.Name]=v end end
		end
	end)
	if next(res) then S.skillC[name]=res end;return res
end
local function getRace(p) local rn,rt;pcall(function()local ro=p:FindFirstChild("Data") and p.Data:FindFirstChild("Race");if not ro then return end;if ro:IsA("ValueBase") and ro.Value~="" then rn=tostring(ro.Value) end;for _,n in ipairs({"C","V","Tier","Level","T"}) do local c=ro:FindFirstChild(n);if c and(c:IsA("NumberValue") or c:IsA("IntValue")) then rt=c.Value;break end end end);return rn,rt end

local function sendMilestoneWebhook(statName,target,totalBeli,totalFrag)
	if not cfg.WebhookEnabled then return end;local url=cfg.WebhookURL;if not url or url=="" then return end
	local pName=lp.DisplayName~=lp.Name and(lp.DisplayName.." (@"..lp.Name..")") or lp.Name
	local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick();local bPM2=calcRate(S.beliHist)
	local cur=statName=="Beli" and totalBeli or totalFrag;local bar=emojiBar(math.min(cur,target),target)
	_sendWH(url,{username=cfg.WebhookName or"BloxHub",embeds={{title="🏆 Milestone — "..fmtN(target).." "..statName,description="**["..pName.."](https://www.roblox.com/users/"..lp.UserId.."/profile)**\nReached **"..fmtN(target).."** "..statName.."!",color=statName=="Beli" and 3447003 or 10181046,fields={{name="Target",value="```"..fmtN(target).."```",inline=true},{name="Total Beli",value="```"..fmtN(totalBeli).."```",inline=true},{name="Total Frags",value="```"..fmtN(totalFrag).."```",inline=true},{name="Session",value="```"..fmtS(tick()-jt).."```",inline=true},{name="Beli/min",value="```"..wFmt(bPM2).."```",inline=true},{name="Progress",value=bar,inline=false}},footer={text="Panel • Milestone Report"},timestamp=ts()}}})
end
local function sendHealthWebhook(avgFPS,instanceCount,elapsed)
	if not cfg.WebhookEnabled then return end;local url=cfg.WebhookURL;if not url or url=="" then return end
	local pName=lp.DisplayName~=lp.Name and(lp.DisplayName.." (@"..lp.Name..")") or lp.Name
	_sendWH(url,{username=cfg.WebhookName or"BloxHub",embeds={{title="⚠️ Server Health Alert",description="**["..pName.."](https://www.roblox.com/users/"..lp.UserId.."/profile)**\nServer lag detected!",color=15158332,fields={{name="Avg FPS",value="```"..avgFPS.."```",inline=true},{name="Instances",value="```"..fmtN(instanceCount).."```",inline=true},{name="Ping",value="```"..getPing().."ms```",inline=true},{name="Session",value="```"..fmtS(elapsed).."```",inline=true},{name="Players",value="```"..#Pl:GetPlayers().."/"..K.MAX.."```",inline=true},{name="FPS Gauge",value=emojiBar(avgFPS,60),inline=false}},footer={text="Panel • Server Health Report"},timestamp=ts()}}})
end
local function sendWebhook(sessBeli,sessFrags,elapsed,source)
	if not cfg.WebhookEnabled then return end;local url=cfg.WebhookURL;if not url or url=="" or url:find("YOUR_ID") then return end
	source=source or"Manual";S.whTotal+=1
	local function gs(k) return getStat(k) or 0 end
	local lv,beli,frag=gs("Level"),gs("Beli"),gs("Fragments");local melee,sword,gun,def,fruit,bounty=gs("Melee"),gs("Sword"),gs("Gun"),gs("Defense"),gs("Blox Fruit"),gs("Bounty")
	local spawn2=getStat("SpawnPoint") or"Unknown";local raceN,raceTier="Unknown",""
	pcall(function()local d=lp:FindFirstChild("Data");if not d then return end;local rc=d:FindFirstChild("Race");if not rc then return end;if rc:IsA("ValueBase") and rc.Value~="" then raceN=tostring(rc.Value) end;for _,n in ipairs({"C","V","Tier","Level","T"}) do local c=rc:FindFirstChild(n);if c and(c:IsA("NumberValue") or c:IsA("IntValue")) then raceTier="V"..c.Value;break end end end)
	local pName=lp.DisplayName~=lp.Name and(lp.DisplayName.." (@"..lp.Name..")") or lp.Name
	local minIn=math.max((elapsed or 0)/60,.01);local bPM2=math.floor(sessBeli/minIn);local fPM2=math.floor(sessFrags/minIn)
	local nextB=nil;for _,t in ipairs(cfg.MilestoneBeli or{}) do if beli<t then nextB=t;break end end
	local nextF=nil;for _,t in ipairs(cfg.MilestoneFrag or{}) do if frag<t then nextF=t;break end end
	local beliBar=nextB and(emojiBar(beli,nextB).."  "..fmtN(beli).."/"..fmtN(nextB)) or"✅ All milestones reached"
	local fragBar=nextF and(emojiBar(frag,nextF).."  "..fmtN(frag).."/"..fmtN(nextF)) or"✅ All milestones reached"
	local jobId="unknown";pcall(function()jobId=game.JobId end)
	local plrLines={};for _,p in ipairs(Pl:GetPlayers()) do local plv=getStat("Level",p);local cache=S.plrC[p.UserId] or{};plrLines[#plrLines+1]="["..p.Name.."](https://www.roblox.com/users/"..p.UserId.."/profile)"..(plv and" — LV "..fmtN(math.floor(plv)) or"")..(cache.bounty and" | B "..fmtN(cache.bounty) or"") end
	local invLines={};local bp=lp:FindFirstChild("Backpack");if bp then for _,o in ipairs(bp:GetChildren()) do if o:IsA("Tool") and o.Name~="Tool" and #invLines<5 then local lv2=getToolLv(o);invLines[#invLines+1]=lv2~=nil and("• "..o.Name.." — LV "..fmtN(math.floor(lv2))) or("• "..o.Name) end end end
	local eqStr,eqLv="Nothing",nil;pcall(function()for _,o in ipairs((lp.Character or{}):GetChildren()) do if o:IsA("Tool") then eqStr=o.Name;eqLv=getToolLv(o);break end end end)
	local eqDisp=eqStr~="Nothing" and(eqStr..(eqLv and" [LV "..fmtN(eqLv).."]" or"")) or"None equipped"
	local skillLines={};if eqStr~="Nothing" then local rl=getSkillLevels(eqStr);for _,k in ipairs(SKILL_KEYS) do local r=rl[k];if r then local ready=eqLv and eqLv>=r;skillLines[#skillLines+1]=k..": "..(ready and"Ready" or("Need LV "..fmtN(r))) end end end
	local fields={
		{name="Player",value="["..pName.."](https://www.roblox.com/users/"..lp.UserId.."/profile)",inline=true},{name="Level",value="```"..fmtN(math.floor(lv)).."```",inline=true},{name="Race",value="```"..raceN..(raceTier~="" and" "..raceTier or"").."```",inline=true},
		{name="Bounty",value="```"..fmtN(bounty).."```",inline=true},{name="Total Beli",value="```"..fmtN(beli).."```",inline=true},{name="Total Frags",value="```"..fmtN(frag).."```",inline=true},
		{name="Beli Gained",value="```"..wFmt(sessBeli).."```",inline=true},{name="Frags Gained",value="```"..wFmt(sessFrags).."```",inline=true},{name="Session",value="```"..fmtS(elapsed or 0).."```",inline=true},
		{name="Beli/Min",value="```"..wFmt(bPM2).."```",inline=true},{name="Beli/Hr",value="```"..wFmt(bPM2*60).."```",inline=true},{name="Frag/Min",value="```"..wFmt(fPM2).."```",inline=true},
		{name="Stats",value="```\nMelee   "..statBar(melee,K.COMBAT).."\nSword   "..statBar(sword,K.COMBAT).."\nGun     "..statBar(gun,K.COMBAT).."\nDefense "..statBar(def,K.COMBAT).."\nFruit   "..statBar(fruit,K.COMBAT).."\n```",inline=false},
		{name="Equipped",value="```"..eqDisp.."```",inline=true},{name="Skills",value="```\n"..(#skillLines>0 and table.concat(skillLines,"\n") or"-").."\n```",inline=true},
		{name="Spawn",value="```"..tostring(spawn2).."```",inline=true},{name="Players",value="```"..#Pl:GetPlayers().."/"..K.MAX.."```",inline=true},{name="FPS / Ping",value="```"..S.fps.." FPS | "..getPing().."ms```",inline=true},
		{name="Backpack",value="```\n"..( #invLines>0 and table.concat(invLines,"\n") or"-").."\n```",inline=false},
		{name="Beli Progress",value=beliBar,inline=false},{name="Frag Progress",value=fragBar,inline=false},
		{name="Server Health",value="```FPS avg: "..S.health.avgFPS.." | Parts: "..fmtN(S.health.instanceCount)..(S.health.lagDetected and" | ⚠️ LAG" or" | ✅ OK").."```",inline=false},
		{name="Players in Server",value=#plrLines>0 and table.concat(plrLines,"\n") or"?",inline=false},
		{name="Report #",value="```#"..S.whTotal.."```",inline=true},{name="Source",value="```"..source.."```",inline=true},{name="Time",value="```"..localT().."```",inline=true},
	}
	if source=="Auto Hop" or source=="Instant Hop" then fields[#fields+1]={name="Hop #",value="```#"..S.hopTotal.."```",inline=true};fields[#fields+1]={name="Target",value="```"..(S.hopTarget~="" and S.hopTarget or"all").."```",inline=true};fields[#fields+1]={name="Prev Job",value="```"..tostring(jobId):sub(1,36).."```",inline=false} end
	_sendWH(url,{username=cfg.WebhookName or"BloxHub",embeds={{author={name="Panel — "..source},title="> Session Report — "..source,description="**["..pName.."](https://www.roblox.com/users/"..lp.UserId.."/profile)** | Session: **"..fmtS(elapsed or 0).."**\n\nBeli "..wFmt(sessBeli).." ("..wFmt(bPM2).."/min)\nFrags "..wFmt(sessFrags).." ("..wFmt(fPM2).."/min)",color=perfColor(bPM2),fields=fields,footer={text="Panel • Report #"..S.whTotal.." • "..source},timestamp=ts()}}})
end

-- ── WEBHOOK TIMER / HOP / RERUN ──────────────────────────────
local function startWHTimer()
	S.whTimer=true;S.whCD=cfg.WebhookInterval*60;S.whTick=tick()
	if S.whThread then task.cancel(S.whThread) end
	S.whThread=task.spawn(function()
		while S.whTimer do
			task.wait(1)
			local now=tick()
			S.whCD=S.whCD-(now-S.whTick)
			S.whTick=now
			if S.whCD<=0 then
				S.whCD=cfg.WebhookInterval*60
				if S.whTimer and cfg.WebhookEnabled then
					task.spawn(function()
						local cb=getStat("Beli") or 0
						local cf=getStat("Fragments") or 0
						local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick()
						sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0,S.sessOK and math.floor(cf-(S.sessF or cf)) or 0,tick()-jt,"Webhook Time")
					end)
				end
			end
		end
	end)
end
local function stopWHTimer() S.whTimer=false;if S.whThread then task.cancel(S.whThread);S.whThread=nil end;S.whCD=cfg.WebhookInterval*60 end

local function doHop()
	local cb=getStat("Beli") or 0;local cf=getStat("Fragments") or 0;local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick()
	S.hopTotal+=1;addLog("Auto Hop")
	task.spawn(function()sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0,S.sessOK and math.floor(cf-(S.sessF or cf)) or 0,tick()-jt,"Auto Hop")end)
	local sb=pg:FindFirstChild("ServerBrowser");if not sb then return end
	sb.Enabled=true; local frame=sb:FindFirstChild("Frame");if not frame then return end
	pcall(function()frame.Visible=true end)
	pcall(function()frame.Filters.SearchRegion.TextBox.Text=S.hopTarget~="" and S.hopTarget or""end)
	pcall(function()frame.Refresh:Activate()end); task.wait(3)
	local inside=frame and frame:FindFirstChild("FakeScroll") and frame.FakeScroll:FindFirstChild("Inside")
	if not inside then return end
	local maxP=cfg.HopMaxPlayers or 3;local tried={}
	local function findBest()
		local best, bestC = nil, math.huge
		
		-- เลื่อน FakeScroll เพื่อโหลดเซิร์ฟทั้งหมด
		local fs = frame:FindFirstChild("FakeScroll")
		if fs then
			-- รีเซ็ตไปบนสุดก่อน
			fs.CanvasPosition = Vector2.new(0, 0)
			task.wait(0.3)
			
			local lastCanvas = 0
			local maxTries = 30  -- กันวนไม่สิ้นสุด
			local tries = 0
			
			-- เลื่อนลงเรื่อยๆ จนสุด โดยรอให้เนื้อหาโหลดแต่ละครั้ง
			while tries < maxTries do
				tries += 1
				local currentCanvas = fs.AbsoluteCanvasSize.Y
				local viewSize = fs.AbsoluteSize.Y
				
				-- เลื่อนลงทีละก้อน
				local currentPos = fs.CanvasPosition.Y
				local nextPos = currentPos + viewSize * 0.8
				
				fs.CanvasPosition = Vector2.new(0, nextPos)
				task.wait(0.15)  -- รอให้ lazy-load โหลดเซิร์ฟเพิ่ม
				
				local newCanvas = fs.AbsoluteCanvasSize.Y
				
				-- ถ้า Canvas ไม่ขยายแล้ว และเลื่อนถึงล่างสุดแล้ว = โหลดครบ
				if newCanvas == lastCanvas and nextPos >= newCanvas - viewSize then
					break
				end
				lastCanvas = newCanvas
			end
			
			-- กลับขึ้นบนสุด
			fs.CanvasPosition = Vector2.new(0, 0)
			task.wait(0.1)
		end
		
		-- ค้นหาเซิร์ฟที่ดีที่สุดจาก Inside
		for _, child in ipairs(inside:GetChildren()) do
			if not child:IsA("Frame") then continue end
			local jb = child:FindFirstChild("Join")
			if not jb or jb.Text ~= "Join" then continue end
			
			-- ดึงข้อมูลจาก TextLabel ใน row
			local playerCount = nil
			for _, tl in ipairs(child:GetDescendants()) do
				if tl:IsA("TextLabel") then
					local cur, max2 = tl.Text:match("Players:%s*(%d+)/(%d+)")
					if cur then
						playerCount = tonumber(cur)
						break
					end
				end
			end
			
			if not playerCount or playerCount > maxP then continue end
			local jobId = jb:GetAttribute("Job")
			if not jobId or tried[jobId] then continue end
			if playerCount < bestC then
				bestC = playerCount
				best = {jb = jb, jobId = jobId, cur = playerCount}
			end
		end
		
		return best
	end
	local function tryHop()
		local server=findBest()
		if server then
			tried[server.jobId]=true;showN("Auto Hop","Found server: "..server.cur.." players",C.HOP)
			local fc;fc=game:GetService("TeleportService").TeleportInitFailed:Connect(function()if fc then fc:Disconnect();fc=nil end;task.wait(1);tryHop() end)
			for _,c in ipairs(getconnections(server.jb.MouseButton1Click)) do c:Fire() end
			task.delay(5,function()if fc then fc:Disconnect();fc=nil end end)
		else
			showN("Auto Hop","No server ≤"..maxP.." players, refreshing...",C.WRN)
			tried={};pcall(function()frame.Refresh:Activate()end);task.wait(4);tryHop()
		end
	end
	tryHop()
end
local function startHop()
	S.hop=true;S.hopCD=cfg.HopInterval*60;S.hopTick=tick()
	if S.hopThread then task.cancel(S.hopThread) end
	S.hopThread=task.spawn(function()while S.hop do task.wait(1);local now=tick();S.hopCD-=(now-S.hopTick);S.hopTick=now;if S.hopCD<=0 then S.hopCD=cfg.HopInterval*60;if S.hop then task.spawn(doHop) end end end end)
end
local function stopHop()
	S.hop=false;if S.hopThread then task.cancel(S.hopThread);S.hopThread=nil end; S.hopCD=cfg.HopInterval*60
	pcall(function()local sb=pg:FindFirstChild("ServerBrowser");if sb then sb.Enabled=false;local f=sb:FindFirstChild("Frame");if f then f.Visible=false end end end)
end
local UI={}
local function startRerun()
	S.rerun=true;if S.rerunThread then task.cancel(S.rerunThread);S.rerunThread=nil end
	task.spawn(function()
		if not cfg.AutoRerunURL or cfg.AutoRerunURL=="" then showN("Auto Rerun","No URL set!",C.ERR);S.rerun=false;return end
		local loader=string.format('task.wait(5)\nlocal ok,src=pcall(game.HttpGet,game,"%s",true)\nif ok and src then local f=loadstring(src) if f then pcall(f) end end',cfg.AutoRerunURL)
		local queued=false;local tried={}
		if not queued and typeof(queueonteleport)=="function" then local ok2,err=pcall(queueonteleport,loader);tried[#tried+1]="queueonteleport="..(ok2 and"OK" or tostring(err));if ok2 then queued=true end end
		if not queued and typeof(queue_on_teleport)=="function" then local ok2,err=pcall(queue_on_teleport,loader);tried[#tried+1]="queue_on_teleport="..(ok2 and"OK" or tostring(err));if ok2 then queued=true end end
		if not queued and getgenv and typeof(getgenv().queueonteleport)=="function" then local ok2,err=pcall(getgenv().queueonteleport,loader);tried[#tried+1]="genv="..(ok2 and"OK" or tostring(err));if ok2 then queued=true end end
		if queued then showN("Auto Rerun","Ready! Runs after hop",C.RERUN)
		else showN("Auto Rerun",table.concat(tried,", "),C.ERR);S.rerun=false;tog(UI.rerunBtn,false,C.RERUN,Color3.fromRGB(28,28,28),"Auto Rerun: On","Auto Rerun: Off") end
	end)
end
local function stopRerun()
	S.rerun=false;if S.rerunThread then task.cancel(S.rerunThread);S.rerunThread=nil end
	pcall(function()queueonteleport("")end);pcall(function()queue_on_teleport("")end);showN("Auto Rerun","Disabled",C.ERR)
end

-- ── HEALTH / MILESTONES ──────────────────────────────────────
local function checkServerHealth()
	local now=tick();if now-S.health.lastCheck<1 then return end;S.health.lastCheck=now
	table.insert(S.health.fpsHist,S.fps);if #S.health.fpsHist>30 then table.remove(S.health.fpsHist,1) end
	local sum=0;for _,v in ipairs(S.health.fpsHist) do sum+=v end
	S.health.avgFPS=#S.health.fpsHist>0 and math.floor(sum/#S.health.fpsHist) or S.fps
	pcall(function()S.health.instanceCount=#WS:GetDescendants()end)
	local threshold=cfg.HealthFPSThreshold or 30
	if S.health.avgFPS<threshold then
		if not S.health.lagDetected then S.health.lagDetected=true;S.health.lagTick=now
		elseif(now-S.health.lagTick)>=(cfg.HealthLagDuration or 10) and not S.health.reportSent then
			S.health.reportSent=true;addEvent("⚠️ Server Lag","Avg FPS: "..S.health.avgFPS.." | Parts: "..fmtN(S.health.instanceCount),C.ERR);showN("Server Health","Lag! Avg FPS: "..S.health.avgFPS,C.ERR)
			if cfg.WebhookEnabled then local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick();task.spawn(sendHealthWebhook,S.health.avgFPS,S.health.instanceCount,tick()-jt) end
		end
	else S.health.lagDetected=false;S.health.reportSent=false end
end
local function checkMilestones()
	local b=getStat("Beli") or 0;local f=getStat("Fragments") or 0
	for _,target in ipairs(cfg.MilestoneBeli or{}) do if b>=target and not S.milestone.beliReached[target] then S.milestone.beliReached[target]=true;addEvent("💰 Beli Milestone",fmtN(target).." Beli!",C.BELI);showN("Milestone!",fmtN(target).." Beli reached!",C.BELI);if cfg.WebhookEnabled then task.spawn(sendMilestoneWebhook,"Beli",target,b,f) end end end
	for _,target in ipairs(cfg.MilestoneFrag or{}) do if f>=target and not S.milestone.fragReached[target] then S.milestone.fragReached[target]=true;addEvent("💎 Frag Milestone",fmtN(target).." Frags!",C.FRAG);showN("Milestone!",fmtN(target).." Frags reached!",C.FRAG);if cfg.WebhookEnabled then task.spawn(sendMilestoneWebhook,"Fragments",target,b,f) end end end
end

-- ── PLAYER WATCHER ───────────────────────────────────────────
local function watchPlr(p)
	if p==lp then return end; local uid=p.UserId;S.plrC[uid]=S.plrC[uid] or{join=tick()}
	task.spawn(function()
		local d=p:FindFirstChild("Data") or p:WaitForChild("Data",30);if not d then return end
		local function watch(child,key) local obj=d:FindFirstChild(child) or d:WaitForChild(child,30);if not obj then return end;local function upd(v)S.plrC[uid]=S.plrC[uid] or{};S.plrC[uid][key]=v end;upd(obj.Value);if S.spawnW[uid] then S.spawnW[uid]:Disconnect() end;S.spawnW[uid]=obj.Changed:Connect(upd) end
		watch("LastSpawnPoint","spawn")
		local rc=d:FindFirstChild("Race") or d:WaitForChild("Race",30);if rc then
			S.plrC[uid].race=rc:IsA("ValueBase") and rc.Value~="" and tostring(rc.Value) or nil
			local cObj=rc:FindFirstChild("C");if cObj then S.plrC[uid].raceTier=cObj.Value end
			if S.raceW[uid] then S.raceW[uid]:Disconnect() end
			S.raceW[uid]=rc.Changed:Connect(function(v)S.plrC[uid]=S.plrC[uid] or{};if v~="" then S.plrC[uid].race=tostring(v) end end)
		end
	end)
	task.spawn(function()
		local bObj=getStatObj(p,"Bounty");if not bObj then task.wait(3);bObj=getStatObj(p,"Bounty") end;if not bObj then return end
		S.plrC[uid].bounty=bObj.Value
		if S.bountyW[uid] then S.bountyW[uid]:Disconnect() end
		S.bountyW[uid]=bObj.Changed:Connect(function(v)S.plrC[uid]=S.plrC[uid] or{};S.plrC[uid].bounty=v end)
	end)
end

-- ── GUI BUILDER HELPERS ──────────────────────────────────────
local function lbl(par,p)
	return mk("TextLabel",par,{BackgroundTransparency=1,Font=p.font or Enum.Font.GothamBold,TextSize=p.sz or 13,TextColor3=p.col or C.OFF,Text=p.txt or"",Size=p.size or UDim2.new(1,0,0,18),Position=p.pos or UDim2.new(0,0,0,0),TextXAlignment=p.ax or Enum.TextXAlignment.Left,TextYAlignment=p.ay or Enum.TextYAlignment.Center,TextTruncate=p.tr or Enum.TextTruncate.None,ZIndex=p.z or 2})
end
local _vis=true
local hudPos=UDim2.new(.5,-K.HW/2,.5,-K.HH/2)
local full=mk("Frame",gui,{Size=UDim2.new(0,K.HW,0,K.HH),Position=hudPos,BackgroundColor3=C.PAN,BorderSizePixel=0,ClipsDescendants=true,ZIndex=2})
stroke(full,C.BOR2,2);corner(full,8)
local titleBar=mk("Frame",full,{Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(8,8,8),BorderSizePixel=0,ZIndex=3})
corner(titleBar,8); mk("Frame",titleBar,{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=Color3.fromRGB(8,8,8),BorderSizePixel=0,ZIndex=3})
lbl(titleBar,{size=UDim2.new(1,-120,1,0),pos=UDim2.new(0,10,0,0),sz=13,col=C.WHT,txt="BloxHub  v3",z=4})
lbl(titleBar,{size=UDim2.new(0,60,1,0),pos=UDim2.new(1,-64,0,0),sz=9,col=C.DIM,txt="v3 Opt.",ax=Enum.TextXAlignment.Right,z=4})
local miniAvaTB=mk("ImageLabel",titleBar,{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,130,0,4),BackgroundColor3=C.CARD,ZIndex=4});corner(miniAvaTB,3)
titleBar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then S.drag=true;S.dragS=i.Position;S.dragP=full.Position end end)
UIS.InputChanged:Connect(function(i)if S.drag and i.UserInputType==Enum.UserInputType.MouseMovement then local ok,d=pcall(function()return i.Position-S.dragS end);if not ok then S.drag=false;return end;full.Position=UDim2.new(S.dragP.X.Scale,S.dragP.X.Offset+d.X,S.dragP.Y.Scale,S.dragP.Y.Offset+d.Y) end end)
UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then S.drag=false end end)
local tabBar=mk("Frame",full,{Size=UDim2.new(1,0,0,K.TAB_H),Position=UDim2.new(0,0,0,28),BackgroundColor3=Color3.fromRGB(8,8,8),BorderSizePixel=0,ZIndex=3})
mk("Frame",tabBar,{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.SEP,ZIndex=4})
local BODY_Y=28+K.TAB_H
local pageContainer=mk("Frame",full,{Size=UDim2.new(1,0,0,K.HH-BODY_Y),Position=UDim2.new(0,0,0,BODY_Y),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2})
local TABS={{id="status",label="Status"},{id="controls",label="Controls"},{id="bringmob",label="BringMob"},{id="players",label="Players"},{id="inv",label="Inventory"},{id="log",label="Log"}}
local tabBtns={};local tabPages={};local tabW=math.floor(K.HW/#TABS)
for i,tab in ipairs(TABS) do
	local x=(i-1)*tabW;local w=(i==#TABS) and(K.HW-(i-1)*tabW) or tabW
	local tb=mk("TextButton",tabBar,{Size=UDim2.new(0,w,1,-1),Position=UDim2.new(0,x,0,0),BackgroundColor3=C.TABOFF,BorderSizePixel=0,Text=tab.label,TextColor3=C.DIM,TextSize=11,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4})
	local underline=mk("Frame",tb,{Size=UDim2.new(0,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.TABON,BorderSizePixel=0,ZIndex=5});corner(underline,1)
	tabBtns[tab.id]={btn=tb,line=underline}
	local sf=mk("ScrollingFrame",pageContainer,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BOR2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,Visible=false,ZIndex=3})
	local inn=mk("Frame",sf,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ZIndex=3})
	mk("UIPadding",inn,{PaddingLeft=UDim.new(0,K.PAD),PaddingRight=UDim.new(0,K.PAD),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})
	mk("UIListLayout",inn,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
	tabPages[tab.id]={sf=sf,inn=inn}
end

-- Tab switch with fade
local function switchTab(id)
	if S.activeTab==id then return end
	local oldSF=tabPages[S.activeTab] and tabPages[S.activeTab].sf
	if oldSF then
		for _,obj in ipairs(oldSF:GetDescendants()) do pcall(function()if obj:IsA("TextLabel") or obj:IsA("TextButton") then TS:Create(obj,TweenInfo.new(.1),{TextTransparency=1}):Play() end end) end
		task.delay(.12,function()oldSF.Visible=false end)
	end
	S.activeTab=id
	for tid,tb in pairs(tabBtns) do local on=(tid==id);tw(tb.btn,{BackgroundColor3=on and Color3.fromRGB(16,16,16) or C.TABOFF},.12);tb.btn.TextColor3=on and C.WHT or C.DIM;tw(tb.line,{Size=UDim2.new(on and 1 or 0,0,0,2)},.15) end
	local newSF=tabPages[id] and tabPages[id].sf
	if newSF then
		for _,obj in ipairs(newSF:GetDescendants()) do pcall(function()if obj:IsA("TextLabel") or obj:IsA("TextButton") then obj.TextTransparency=1 end end) end
		task.delay(.05,function()
			newSF.Visible=true
			for _,obj in ipairs(newSF:GetDescendants()) do pcall(function()if obj:IsA("TextLabel") or obj:IsA("TextButton") then TS:Create(obj,TweenInfo.new(.15),{TextTransparency=0}):Play() end end) end
		end)
	end
end
for _,tab in ipairs(TABS) do tabBtns[tab.id].btn.MouseButton1Click:Connect(function()switchTab(tab.id)end) end

-- Section / widget helpers
local function section(tabId,order,titleTxt)
	local parent=tabPages[tabId].inn
	local f=mk("Frame",parent,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.CARD,BorderSizePixel=0,LayoutOrder=order,ZIndex=3})
	corner(f,5);stroke(f,C.BOR,1)
	mk("UIPadding",f,{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6)})
	mk("UIListLayout",f,{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
	if titleTxt then mk("TextLabel",f,{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.DIM,Text=titleTxt:upper(),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=0,ZIndex=4});mk("Frame",f,{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.SEP,ZIndex=4,LayoutOrder=1}) end
	return f
end
local function secLbl(parent,lo,txt,col,sz) return mk("TextLabel",parent,{Size=UDim2.new(1,0,0,(sz or 13)+2),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=sz or 13,TextColor3=col or C.OFF,Text=txt,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=lo,ZIndex=4}) end
local function secBtn(parent,lo,txt,on,col)
	local b=mk("TextButton",parent,{Size=UDim2.new(1,0,0,26),BackgroundColor3=on and col or Color3.fromRGB(28,28,28),BorderSizePixel=0,LayoutOrder=lo,Text=txt,TextColor3=on and C.BG or C.MUT,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4})
	stroke(b,C.BOR2,1);corner(b,4);return b
end
local function secBox(parent,lo,ph,h)
	local b=mk("TextBox",parent,{Size=UDim2.new(1,0,0,h or 26),BackgroundColor3=Color3.fromRGB(16,16,16),BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.WHT,Text="",PlaceholderText=ph,PlaceholderColor3=C.DIM,LayoutOrder=lo,ZIndex=4})
	stroke(b,C.BOR2,1);corner(b,4);return b
end
local function inlineRow(parent,lo) return mk("Frame",parent,{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=lo,ZIndex=4}) end
local function inlineBtn(row,xOff,w,txt,col)
	local b=mk("TextButton",row,{Size=UDim2.new(0,w,1,0),Position=UDim2.new(0,xOff,0,0),BackgroundColor3=col,BorderSizePixel=0,Text=txt,TextColor3=C.BG,TextSize=11,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4})
	stroke(b,C.BOR2,1);corner(b,4);return b
end
local function inlineBox(row,xOff,w,ph)
	local b=mk("TextBox",row,{Size=UDim2.new(0,w,1,0),Position=UDim2.new(0,xOff,0,0),BackgroundColor3=Color3.fromRGB(16,16,16),BorderSizePixel=0,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.WHT,Text="",PlaceholderText=ph,PlaceholderColor3=C.DIM,ZIndex=4})
	stroke(b,C.BOR2,1);corner(b,4);return b
end

-- ── STATUS TAB ───────────────────────────────────────────────
do
	local sec1=section("status",1,"Profile")
	local avaRow=mk("Frame",sec1,{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1,LayoutOrder=2,ZIndex=4})
	UI.ava=mk("ImageLabel",avaRow,{Size=UDim2.new(0,48,0,48),Position=UDim2.new(0,0,0,2),BackgroundColor3=C.CARD,ZIndex=5});corner(UI.ava,5);stroke(UI.ava,C.BOR2,1)
	task.spawn(function()local ok,t=pcall(function()return Pl:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)end);if ok and t then UI.ava.Image=t;miniAvaTB.Image=t end end)
	UI.charLbl=lbl(avaRow,{size=UDim2.new(1,-56,0,18),pos=UDim2.new(0,54,0,2),sz=13,col=C.WHT,txt="Loading...",tr=Enum.TextTruncate.AtEnd,z=5})
	UI.lvlLbl=lbl(avaRow,{size=UDim2.new(1,-56,0,13),pos=UDim2.new(0,54,0,20),font=Enum.Font.Gotham,sz=10,col=C.MUT,txt="LV. 0",z=5})
	local dot=mk("Frame",avaRow,{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,54,0,36),BackgroundColor3=C.OK,ZIndex=5});corner(dot,4)
	lbl(avaRow,{size=UDim2.new(0,60,0,11),pos=UDim2.new(0,64,0,34),sz=9,col=C.DIM,txt="ONLINE",z=5})
	task.spawn(function()while true do tw(dot,{BackgroundTransparency=.5},.8);task.wait(.8);tw(dot,{BackgroundTransparency=0},.8);task.wait(.8) end end)
	local cW2=math.floor(K.IW/3)-4
	local infoRow=mk("Frame",sec1,{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,LayoutOrder=3,ZIndex=4})
	local function infoCol(xi,lb2) lbl(infoRow,{size=UDim2.new(0,cW2,0,11),pos=UDim2.new(0,xi,0,0),sz=8,col=C.DIM,txt=lb2,z=5});return lbl(infoRow,{size=UDim2.new(0,cW2,0,15),pos=UDim2.new(0,xi,0,11),sz=11,col=C.OFF,txt="???",tr=Enum.TextTruncate.AtEnd,z=5}) end
	UI.raceLbl=infoCol(0,"RACE");UI.teamLbl=infoCol(cW2+6,"TEAM");UI.spawnLbl=infoCol((cW2+6)*2,"SPAWN")
	local fpsRow=mk("Frame",sec1,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,LayoutOrder=4,ZIndex=4})
	UI.fpsLbl=lbl(fpsRow,{size=UDim2.new(0,100,1,0),sz=11,col=C.OFF,txt="FPS 0",z=5})
	UI.pingLbl=lbl(fpsRow,{size=UDim2.new(0,100,1,0),pos=UDim2.new(0,100,0,0),sz=11,col=C.OFF,txt="PING 0ms",z=5})
	UI.timeLbl=lbl(fpsRow,{size=UDim2.new(0,120,1,0),pos=UDim2.new(1,-120,0,0),font=Enum.Font.Gotham,sz=9,col=C.DIM,txt="00:00:00",ax=Enum.TextXAlignment.Right,z=5})
	local sec2=section("status",2,"Combat Stats")
	local function statRow(lb3,lo2,col2)
		local r=mk("Frame",sec2,{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,LayoutOrder=lo2,ZIndex=4})
		lbl(r,{size=UDim2.new(0,80,0,12),sz=9,col=C.DIM,txt=lb3:upper(),z=5})
		local vl=lbl(r,{size=UDim2.new(0,80,0,15),pos=UDim2.new(0,0,0,12),sz=12,col=C.OFF,txt="0",z=5})
		local bb=mk("Frame",r,{Size=UDim2.new(1,-88,0,4),Position=UDim2.new(0,88,0,14),BackgroundColor3=C.BOR,ZIndex=4});corner(bb,2)
		local bf=mk("Frame",bb,{Size=UDim2.new(0,0,1,0),BackgroundColor3=col2 or C.V1,ZIndex=5});corner(bf,2)
		return vl,bf
	end
	UI.meleeLbl,UI.meleeBar=statRow("Melee",2,C.V1);UI.defLbl,UI.defBar=statRow("Defense",3,C.V1)
	UI.swordLbl,UI.swordBar=statRow("Sword",4,C.V1);UI.gunLbl,UI.gunBar=statRow("Gun",5,C.V1);UI.fruitLbl,UI.fruitBar=statRow("Blox Fruit",6,C.WRN)
	local sec3=section("status",3,"Economy")
	local hw2=math.floor((K.IW-4)/2)
	local function ecoRow(lo,labels,lblKeys,colors)
		local r=mk("Frame",sec3,{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,LayoutOrder=lo,ZIndex=4})
		for i,info in ipairs(labels) do
			local xi=(i-1)*(hw2+4)
			lbl(r,{size=UDim2.new(0,hw2,0,12),pos=UDim2.new(0,xi,0,0),sz=8,col=C.DIM,txt=info,z=5})
			UI[lblKeys[i]]=lbl(r,{size=UDim2.new(0,hw2,0,16),pos=UDim2.new(0,xi,0,12),sz=14,col=colors[i],txt="0",z=5})
		end
	end
	ecoRow(2,{"BELI","FRAGMENTS"},{"beliLbl","fragLbl"},{C.BELI,C.FRAG})
	local ecoRow2=mk("Frame",sec3,{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,LayoutOrder=3,ZIndex=4})
	lbl(ecoRow2,{size=UDim2.new(0,hw2,0,12),sz=8,col=C.DIM,txt="SESSION BELI",z=5});UI.sessBLbl=lbl(ecoRow2,{size=UDim2.new(0,hw2,0,16),pos=UDim2.new(0,0,0,12),sz=12,col=C.BELI,txt="+0",z=5})
	lbl(ecoRow2,{size=UDim2.new(0,hw2,0,12),pos=UDim2.new(0,hw2+4,0,0),sz=8,col=C.DIM,txt="SESSION FRAG",z=5});UI.sessFLbl=lbl(ecoRow2,{size=UDim2.new(0,hw2,0,16),pos=UDim2.new(0,hw2+4,0,12),sz=12,col=C.FRAG,txt="+0",z=5})
	local rateRow=mk("Frame",sec3,{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,LayoutOrder=4,ZIndex=4})
	local qw=math.floor(K.IW/4)-2
	local function rateCol(xi2,lb4,col4,key) lbl(rateRow,{size=UDim2.new(0,qw,0,11),pos=UDim2.new(0,xi2,0,0),sz=8,col=C.DIM,txt=lb4,z=5});UI[key]=lbl(rateRow,{size=UDim2.new(0,qw,0,15),pos=UDim2.new(0,xi2,0,13),sz=11,col=col4,txt="+0",z=5}) end
	rateCol(0,"BELI/MIN",C.BELI,"bPMLbl");rateCol(qw+2,"BELI/HR",C.BELI,"bHRLbl");rateCol((qw+2)*2,"FRAG/MIN",C.FRAG,"fPMLbl");rateCol((qw+2)*3,"FRAG/HR",C.FRAG,"fHRLbl")
end

-- ── CONTROLS TAB ─────────────────────────────────────────────
do
	local sec1=section("controls",1,"Performance Boosts")
	UI.v1Btn=secBtn(sec1,2,"Boost V1: Off",false,C.V1);UI.v2Btn=secBtn(sec1,3,"Boost V2: Off",false,C.V2);UI.v3Btn=secBtn(sec1,4,"Boost V3: Off",false,C.V3)
	local sec2=section("controls",2,"Visibility")
	UI.hidBtn=secBtn(sec2,2,"Delete Players: Off",false,C.WHT);UI.enmBtn=secBtn(sec2,3,"Hide Enemies: Off",false,C.ERR)
	local sec3=section("controls",3,"FPS Lock")
	local fpsRow=inlineRow(sec3,2);local capBox=inlineBox(fpsRow,0,K.IW-64,tostring(cfg.LockFps.fps).." FPS");local setFpsBtn=inlineBtn(fpsRow,K.IW-60,56,"SET FPS",C.OK)
	local function applyFPS(n) pcall(function()settings().Rendering.FrameRateManager.MaxFrameRate=n end);pcall(function()setfpscap(n)end) end
	setFpsBtn.MouseButton1Click:Connect(function()local n=tonumber(capBox.Text);if n and n>0 then applyFPS(n);capBox.Text="";capBox.PlaceholderText=n.." FPS";showN("FPS Lock","Set to "..n.." FPS",C.OK) end end)
	capBox.FocusLost:Connect(function(e)if e then local n=tonumber(capBox.Text);if n and n>0 then applyFPS(n);capBox.Text="";capBox.PlaceholderText=n.." FPS";showN("FPS Lock","Set to "..n.." FPS",C.OK) end end end)
	local sec4=section("controls",4,"Auto Hop")
	UI.hopBtn=secBtn(sec4,2,"Auto Hop: Off",false,C.HOP)
	local hopNowRow=inlineRow(sec4,3);UI.hopNowBtn=mk("TextButton",hopNowRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.HOP,BorderSizePixel=0,Text="Hop Now",TextColor3=C.BG,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(UI.hopNowBtn,C.BOR2,1);corner(UI.hopNowBtn,4)
	local hopMaxRow=inlineRow(sec4,4);local hopMaxBox=inlineBox(hopMaxRow,0,K.IW-70,"Max players (default: 3)");local hopMaxBtn=inlineBtn(hopMaxRow,K.IW-66,62,"SET",C.HOP)
	hopMaxBtn.MouseButton1Click:Connect(function()local n=tonumber(hopMaxBox.Text);if n and n>=0 then cfg.HopMaxPlayers=n;hopMaxBox.Text="";hopMaxBox.PlaceholderText="Max players: "..n;showN("Auto Hop","Hop to servers ≤"..n.." players",C.HOP) else showN("Auto Hop","Enter a number",C.WRN) end end)
	UI.hopCD=secLbl(sec4,5,"DISABLED",C.HOP,10)
	local sec5=section("controls",5,"Webhook")
	secLbl(sec5,2,"WEBHOOK URL",C.DIM,8);local whUrlBox=secBox(sec5,3,"Paste Discord Webhook URL...",26);whUrlBox.Text=cfg.WebhookURL;whUrlBox.ClearTextOnFocus=false
	secLbl(sec5,4,"BOT NAME",C.DIM,8);local whNameBox=secBox(sec5,5,cfg.WebhookName,22);whNameBox.Text=cfg.WebhookName;whNameBox.ClearTextOnFocus=false
	local applyRow=inlineRow(sec5,6);local applyBtn=mk("TextButton",applyRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.WH,BorderSizePixel=0,Text="Save URL & Name",TextColor3=C.BG,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(applyBtn,C.BOR2,1);corner(applyBtn,4)
	UI.whApplyStatus=secLbl(sec5,7,"Not saved yet",C.DIM,9)
	applyBtn.MouseButton1Click:Connect(function()local url=whUrlBox.Text;if url=="" or not url:find("discord.com/api/webhooks") then setText(UI.whApplyStatus,"Invalid URL");setCol(UI.whApplyStatus,C.ERR);showN("Webhook","Invalid URL!",C.ERR);return end;cfg.WebhookURL=url;cfg.WebhookName=whNameBox.Text~="" and whNameBox.Text or"Panel";setText(UI.whApplyStatus,"Saved — "..cfg.WebhookName);setCol(UI.whApplyStatus,C.OK);showN("Webhook","URL saved",C.WH) end)
	mk("Frame",sec5,{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.SEP,ZIndex=4,LayoutOrder=8})
	UI.whBtn=secBtn(sec5,9,"Webhook: Off",false,C.WH);UI.whTimBtn=secBtn(sec5,10,"WH Timer: Off",false,C.WH)
	local whTestRow=inlineRow(sec5,11);UI.whTestBtn=mk("TextButton",whTestRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,28),BorderSizePixel=0,Text="Send Test Report",TextColor3=C.WRN,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(UI.whTestBtn,C.BOR2,1);corner(UI.whTestBtn,4)
	UI.whCD=secLbl(sec5,12,"DISABLED",C.WH,10)
	local sec6=section("controls",6,"Auto Rerun")
	UI.rerunBtn=secBtn(sec6,2,"Auto Rerun: Off",false,C.RERUN)
	UI.rerunBtn.MouseButton1Click:Connect(function()if S.rerun then stopRerun();tog(UI.rerunBtn,false,C.RERUN,Color3.fromRGB(28,28,28),"Auto Rerun: On","Auto Rerun: Off") else startRerun();tog(UI.rerunBtn,true,C.RERUN,Color3.fromRGB(28,28,28),"Auto Rerun: On","Auto Rerun: Off") end end)
	local sec7=section("controls",7,"Fake Level")
	secLbl(sec7,2,"Replaces .Value on .Changed",C.DIM,9);local fakeLvBox=secBox(sec7,3,"Target level, e.g. 2450");UI.fakeLvBtn=secBtn(sec7,4,"Fake Level: Off",false,C.FAKE);UI.fakeLvStatus=secLbl(sec7,5,"OFF",C.DIM,9)
	UI.fakeLvBtn.MouseButton1Click:Connect(function()
		if S.fakeLevel then stopFakeLevel();tog(UI.fakeLvBtn,false,C.FAKE,Color3.fromRGB(28,28,28),"Fake Level: On","Fake Level: Off");setText(UI.fakeLvStatus,"OFF");setCol(UI.fakeLvStatus,C.DIM);showN("Fake Level","Disabled",C.ERR)
		else local n=tonumber(fakeLvBox.Text);if not n or n<=0 then showN("Fake Level","Enter a level first!",C.WRN);return end;startFakeLevel(n);tog(UI.fakeLvBtn,true,C.FAKE,Color3.fromRGB(28,28,28),"Fake Level: On","Fake Level: Off");setText(UI.fakeLvStatus,"ACTIVE — LV "..fmtN(n));setCol(UI.fakeLvStatus,C.FAKE);showN("Fake Level","On — LV "..fmtN(n),C.FAKE) end
	end)
	local sec8=section("controls",8,"Movement")
	UI.infJumpBtn=secBtn(sec8,2,"Infinite Jump: Off",false,C.OK)
	UI.infJumpBtn.MouseButton1Click:Connect(function()S.infJump=not S.infJump;setInfJump(S.infJump);tog(UI.infJumpBtn,S.infJump,C.OK,Color3.fromRGB(28,28,28),"Infinite Jump: On","Infinite Jump: Off");showN("Infinite Jump",S.infJump and"On" or"Off",S.infJump and C.OK or C.ERR) end)
	local speedRow=inlineRow(sec8,3);local speedBox=inlineBox(speedRow,0,K.IW-70,"Speed x  (1–20)");local speedSetBtn=inlineBtn(speedRow,K.IW-66,62,"SET",C.V2)
	UI.speedLbl=secLbl(sec8,4,"Speed: 1x  (WalkSpeed 16)",C.DIM,9)
	local speedResetRow=inlineRow(sec8,5);local speedResetBtn=mk("TextButton",speedResetRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,28),BorderSizePixel=0,Text="Reset Speed (1x)",TextColor3=C.WRN,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(speedResetBtn,C.BOR2,1);corner(speedResetBtn,4)
	speedSetBtn.MouseButton1Click:Connect(function()local n=tonumber(speedBox.Text);if n and n>=1 and n<=20 then applySpeed(n);speedBox.Text="";speedBox.PlaceholderText="Current: "..n.."x";setText(UI.speedLbl,"Speed: "..n.."x  (WalkSpeed "..math.floor(BASE_WS*n)..")");S.last[UI.speedLbl]=nil;showN("Speed",n.."x — WalkSpeed "..math.floor(BASE_WS*n),C.V2) else showN("Speed","Enter 1–20",C.WRN) end end)
	speedResetBtn.MouseButton1Click:Connect(function()applySpeed(1);speedBox.Text="";speedBox.PlaceholderText="Speed x  (1–20)";setText(UI.speedLbl,"Speed: 1x  (WalkSpeed 16)");S.last[UI.speedLbl]=nil;showN("Speed","Reset to 1x",C.DIM) end)
	for _,h in ipairs({{UI.infJumpBtn,function()return S.infJump and C.OK or Color3.fromRGB(28,28,28)end},{speedSetBtn,function()return C.V2 end},{speedResetBtn,function()return Color3.fromRGB(28,28,28)end}}) do addHov(h[1],h[2]) end
end

-- ── BRINGMOB TAB ─────────────────────────────────────────────
do
	local sec1=section("bringmob",1,"BringMob Controls")
	UI.pullBtn=secBtn(sec1,2,"BringMob V1 (Pull): Off",false,C.PULL);UI.pullBtn2=secBtn(sec1,3,"BringMob V2 (Warp): Off",false,C.BM2)
	local bm2IntRow=inlineRow(sec1,4);local bm2Box=inlineBox(bm2IntRow,0,K.IW-70,"V2 Warp interval sec (default 0.1)");local bm2SetBtn=inlineBtn(bm2IntRow,K.IW-66,62,"SET",C.BM2)
	local bm2DistRow=inlineRow(sec1,5);local bm2DistBox=inlineBox(bm2DistRow,0,K.IW-70,"V2 Range studs (default 500)");local bm2DistBtn=inlineBtn(bm2DistRow,K.IW-66,62,"SET",C.BM2)
	local bm2MaxRow=inlineRow(sec1,6);local bm2MaxBox=inlineBox(bm2MaxRow,0,K.IW-70,"V2 Max mobs (default 10)");local bm2MaxBtn=inlineBtn(bm2MaxRow,K.IW-66,62,"SET",C.BM2)
	local bm2AnchorRow=inlineRow(sec1,7);local bm2AnchorBtn=mk("TextButton",bm2AnchorRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.BM2,BorderSizePixel=0,Text="Set Anchor = My Position",TextColor3=C.BG,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(bm2AnchorBtn,C.BOR2,1);corner(bm2AnchorBtn,4)
	local bm2ClearRow=inlineRow(sec1,8);local bm2ClearBtn=mk("TextButton",bm2ClearRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,28),BorderSizePixel=0,Text="Clear Anchor (Follow Me)",TextColor3=C.WRN,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(bm2ClearBtn,C.BOR2,1);corner(bm2ClearBtn,4)
	local xyzRow=inlineRow(sec1,9);local xyzW=math.floor((K.IW-8)/3)-2
	bm2XBox=inlineBox(xyzRow,0,xyzW,"X");bm2YBox=inlineBox(xyzRow,xyzW+4,xyzW,"Y");bm2ZBox=inlineBox(xyzRow,(xyzW+4)*2,xyzW,"Z")
	local xyzApplyRow=inlineRow(sec1,10);local xyzApplyBtn=mk("TextButton",xyzApplyRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,28),BorderSizePixel=0,Text="Apply XYZ as Anchor",TextColor3=C.BM2,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(xyzApplyBtn,C.BOR2,1);corner(xyzApplyBtn,4)
	local bm2RstRow=inlineRow(sec1,11);local bm2RstBox=inlineBox(bm2RstRow,0,K.IW-70,"Auto-reset every N sec (0 = off)");local bm2RstBtn=inlineBtn(bm2RstRow,K.IW-66,62,"SET",C.BM2)
	local numSec=section("bringmob",2,"V1 Distance & Y Offset")
	local distHdr=secLbl(numSec,2,"Range (studs)  [current: "..BM.dist.."]",C.DIM,9);local distBox=secBox(numSec,3,"Dist: "..BM.dist);local setDistBtn=secBtn(numSec,4,"Apply V1 Distance",true,C.OK);setDistBtn.TextColor3=C.BG
	local yHdr=secLbl(numSec,5,"Y Offset  [current: "..BM.yOff.."]  V1 & V2",C.DIM,9);local yOffBox=secBox(numSec,6,"Y: "..BM.yOff);local setYBtn=secBtn(numSec,7,"Apply Y Offset (V1 & V2)",true,C.V1);setYBtn.TextColor3=C.BG
	local stSec=section("bringmob",3,"Status")
	UI.bmCountLbl=secLbl(stSec,2,"BringMob V1: Off",C.DIM,10);UI.bm2StatusLbl=secLbl(stSec,3,"BringMob V2: Off",C.DIM,10)
	UI.bm2AnchorLbl=secLbl(stSec,4,"V2 Anchor: —",C.DIM,9);UI.bm2ResetLbl=secLbl(stSec,5,"V2 Reset: —",C.DIM,9)
	UI.bmYLbl=secLbl(stSec,6,"Y Offset (shared): "..BM.yOff,C.DIM,9);UI.bmDistLbl=secLbl(stSec,7,"V1 Dist: "..BM.dist,C.DIM,9);UI.bm2DistLbl=secLbl(stSec,8,"V2 Dist: "..BM2.dist,C.DIM,9);UI.bm2MaxLbl=secLbl(stSec,9,"V2 Max Mobs: "..BM2.maxCount,C.DIM,9)
	setDistBtn.MouseButton1Click:Connect(function()local n=tonumber(distBox.Text);if n and n>0 then BM.dist=n;distBox.Text="";distBox.PlaceholderText="Dist: "..n;setText(distHdr,"Range (studs)  [current: "..n.."]");setText(UI.bmDistLbl,"V1 Dist: "..n);S.last[distHdr]=nil;showN("BringMob V1","Range → "..n.." studs",C.OK) else showN("BringMob","Enter a valid number!",C.WRN) end end)
	setYBtn.MouseButton1Click:Connect(function()local n=tonumber(yOffBox.Text);if n~=nil then BM.yOff=n;yOffBox.Text="";yOffBox.PlaceholderText="Y: "..n;setText(yHdr,"Y Offset  [current: "..n.."]  V1 & V2");setText(UI.bmYLbl,"Y Offset (shared): "..n);S.last[yHdr]=nil;S.last[UI.bmYLbl]=nil;showN("BringMob","Y Offset → "..n,C.V1) else showN("BringMob","Enter a number e.g. -15",C.WRN) end end)
	UI.pullBtn.MouseButton1Click:Connect(function()if BM.on then stopBM();tog(UI.pullBtn,false,C.PULL,Color3.fromRGB(28,28,28),"BringMob V1 (Pull): On","BringMob V1 (Pull): Off");setText(UI.bmCountLbl,"BringMob V1: Off");setCol(UI.bmCountLbl,C.DIM);showN("BringMob V1","Disabled",C.ERR) else startBM();tog(UI.pullBtn,true,C.PULL,Color3.fromRGB(28,28,28),"BringMob V1 (Pull): On","BringMob V1 (Pull): Off");showN("BringMob V1","Pull ON | Dist: "..BM.dist.."  Y: "..BM.yOff,C.PULL) end end)
	UI.pullBtn2.MouseButton1Click:Connect(function()if BM2.on then stopBM2();tog(UI.pullBtn2,false,C.BM2,Color3.fromRGB(28,28,28),"BringMob V2 (Warp): On","BringMob V2 (Warp): Off");setText(UI.bm2StatusLbl,"BringMob V2: Off");setCol(UI.bm2StatusLbl,C.DIM);showN("BringMob V2","Disabled",C.ERR) else startBM2();tog(UI.pullBtn2,true,C.BM2,Color3.fromRGB(28,28,28),"BringMob V2 (Warp): On","BringMob V2 (Warp): Off");setText(UI.bm2StatusLbl,"BringMob V2: ON");setCol(UI.bm2StatusLbl,C.BM2);showN("BringMob V2","Warp+Noclip ON | Max: "..BM2.maxCount,C.BM2) end end)
	bm2AnchorBtn.MouseButton1Click:Connect(function()local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart");if not hrp then showN("BringMob V2","No Character!",C.WRN);return end;BM2.anchorPos=hrp.Position;BM2.resetTick=tick();local p=hrp.Position;bm2XBox.Text=tostring(math.floor(p.X));bm2YBox.Text=tostring(math.floor(p.Y));bm2ZBox.Text=tostring(math.floor(p.Z));local aStr=("%.0f, %.0f, %.0f"):format(p.X,p.Y,p.Z);setText(UI.bm2AnchorLbl,"V2 Anchor (Fixed): "..aStr);S.last[UI.bm2AnchorLbl]=nil;showN("BringMob V2","Anchor → "..aStr,C.BM2) end)
	xyzApplyBtn.MouseButton1Click:Connect(function()local x,y,z=tonumber(bm2XBox.Text),tonumber(bm2YBox.Text),tonumber(bm2ZBox.Text);if not x or not y or not z then showN("BringMob V2","Fill X Y Z first!",C.WRN);return end;BM2.anchorPos=Vector3.new(x,y,z);BM2.resetTick=tick();local aStr=("%.0f, %.0f, %.0f"):format(x,y,z);setText(UI.bm2AnchorLbl,"V2 Anchor: "..aStr);S.last[UI.bm2AnchorLbl]=nil;showN("BringMob V2","Anchor (manual) → "..aStr,C.BM2) end)
	bm2ClearBtn.MouseButton1Click:Connect(function()BM2.anchorPos=nil;bm2XBox.Text="";bm2YBox.Text="";bm2ZBox.Text="";setText(UI.bm2AnchorLbl,"V2 Anchor: Follow Mode");S.last[UI.bm2AnchorLbl]=nil;showN("BringMob V2","Cleared → Follow mode",C.WRN) end)
	bm2SetBtn.MouseButton1Click:Connect(function()local n=tonumber(bm2Box.Text);if n and n>0 then BM2.interval=n;bm2Box.Text="";bm2Box.PlaceholderText="Interval: "..n.."s";showN("BringMob V2","Interval → "..n.."s",C.BM2) else showN("BringMob V2","Enter number e.g. 0.1",C.WRN) end end)
	bm2DistBtn.MouseButton1Click:Connect(function()local n=tonumber(bm2DistBox.Text);if n and n>0 then BM2.dist=n;bm2DistBox.Text="";bm2DistBox.PlaceholderText="V2 Range: "..n;setText(UI.bm2DistLbl,"V2 Dist: "..n);S.last[UI.bm2DistLbl]=nil;showN("BringMob V2","Range → "..n,C.BM2) else showN("BringMob V2","Enter number e.g. 500",C.WRN) end end)
	bm2MaxBtn.MouseButton1Click:Connect(function()local n=tonumber(bm2MaxBox.Text);if n and n>0 then BM2.maxCount=math.floor(n);bm2MaxBox.Text="";bm2MaxBox.PlaceholderText="Max mobs: "..BM2.maxCount;setText(UI.bm2MaxLbl,"V2 Max Mobs: "..BM2.maxCount);S.last[UI.bm2MaxLbl]=nil;showN("BringMob V2","Max mobs → "..BM2.maxCount,C.BM2) else showN("BringMob V2","Enter a number e.g. 10",C.WRN) end end)
	bm2RstBtn.MouseButton1Click:Connect(function()local n=tonumber(bm2RstBox.Text);if n~=nil and n>=0 then BM2.resetInterval=n;bm2RstBox.Text="";bm2RstBox.PlaceholderText="Reset every: "..(n==0 and"never" or n.."s");showN("BringMob V2","Auto-reset → "..(n==0 and"never" or n.."s"),C.BM2) else showN("BringMob V2","Enter a number (0 = off)",C.WRN) end end)
end

-- ── PLAYERS TAB ──────────────────────────────────────────────
do
	local sec1=section("players",1,"Server Info")
	local pcRow=mk("Frame",sec1,{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,LayoutOrder=2,ZIndex=4})
	lbl(pcRow,{size=UDim2.new(0,90,0,12),sz=8,col=C.DIM,txt="PLAYERS",z=5});UI.pcLbl=lbl(pcRow,{size=UDim2.new(0,90,0,16),pos=UDim2.new(0,0,0,12),sz=13,col=C.WHT,txt="? / "..K.MAX,z=5})
	lbl(pcRow,{size=UDim2.new(0,90,0,12),pos=UDim2.new(1,-94,0,0),sz=8,col=C.DIM,txt="TOTAL BOUNTY",ax=Enum.TextXAlignment.Right,z=5});UI.bountyLbl=lbl(pcRow,{size=UDim2.new(0,90,0,16),pos=UDim2.new(1,-94,0,12),sz=11,col=Color3.fromRGB(185,120,40),txt="0",ax=Enum.TextXAlignment.Right,z=5})
	local svrBg=mk("Frame",sec1,{Size=UDim2.new(1,0,0,3),BackgroundColor3=C.BOR,ZIndex=4,LayoutOrder=3});corner(svrBg,1);UI.svrBar=mk("Frame",svrBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.WHT,ZIndex=5});corner(UI.svrBar,1)
	local specSec=section("players",2,"Spectate")
	UI.specStatusLbl=secLbl(specSec,2,"Not spectating",C.DIM,10)
	local specStopRow=inlineRow(specSec,3);UI.specStopBtn=mk("TextButton",specStopRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,28),BorderSizePixel=0,Text="Stop Spectate",TextColor3=C.DIM,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(UI.specStopBtn,C.BOR2,1);corner(UI.specStopBtn,4)
	UI.specStopBtn.MouseButton1Click:Connect(function()if S.specTarget then local n=S.specTarget.DisplayName;stopSpec();setText(UI.specStatusLbl,"Not spectating");setCol(UI.specStatusLbl,C.DIM);tw(UI.specStopBtn,{BackgroundColor3=Color3.fromRGB(28,28,28)},.15);UI.specStopBtn.TextColor3=C.DIM;showN("Spectate","Stopped — "..n,C.DIM) end end)
	local listSec=section("players",3,"Player List")
	local plrSF=mk("ScrollingFrame",listSec,{Size=UDim2.new(1,0,0,300),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BOR2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=4,LayoutOrder=2}); mk("UIListLayout",plrSF,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
	UI.plrRows={};UI.plrRowMap={};local SPEC_BTN_W=38
	for i=1,20 do
		local row=mk("Frame",plrSF,{Size=UDim2.new(1,-4,0,66),BackgroundColor3=Color3.fromRGB(16,16,16),ZIndex=5,LayoutOrder=i,Visible=false});stroke(row,C.BOR,1);corner(row,4)
		local specBtn=mk("TextButton",row,{Size=UDim2.new(0,SPEC_BTN_W,0,24),Position=UDim2.new(1,-(SPEC_BTN_W+6),0,4),BackgroundColor3=C.SPEC,BorderSizePixel=0,Text="SPEC",TextColor3=C.BG,TextSize=10,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=7});stroke(specBtn,C.BOR2,1);corner(specBtn,3)
		UI.plrRows[i]={row=row,specBtn=specBtn,
			nameLbl=lbl(row,{size=UDim2.new(1,-(SPEC_BTN_W+16),0,14),pos=UDim2.new(0,6,0,3),sz=11,col=C.WHT,txt="",tr=Enum.TextTruncate.AtEnd,z=6}),
			lvlLbl=lbl(row,{size=UDim2.new(0,50,0,14),pos=UDim2.new(1,-(SPEC_BTN_W+60),0,3),sz=10,col=C.MUT,txt="",ax=Enum.TextXAlignment.Right,z=6}),
			raceLbl=lbl(row,{size=UDim2.new(0,120,0,12),pos=UDim2.new(0,6,0,19),font=Enum.Font.Gotham,sz=9,col=Color3.fromRGB(80,140,200),txt="",tr=Enum.TextTruncate.AtEnd,z=6}),
			spawnLbl=lbl(row,{size=UDim2.new(0,150,0,12),pos=UDim2.new(0,130,0,19),font=Enum.Font.Gotham,sz=9,col=C.DIM,txt="",tr=Enum.TextTruncate.AtEnd,z=6}),
			bountyLbl=lbl(row,{size=UDim2.new(1,-90,0,12),pos=UDim2.new(0,6,0,33),font=Enum.Font.Gotham,sz=9,col=Color3.fromRGB(185,120,40),txt="",tr=Enum.TextTruncate.AtEnd,z=6}),
			distLbl=lbl(row,{size=UDim2.new(0,82,0,12),pos=UDim2.new(1,-86,0,33),font=Enum.Font.Gotham,sz=9,col=Color3.fromRGB(130,130,185),txt="",ax=Enum.TextXAlignment.Right,z=6}),
			timeLbl=lbl(row,{size=UDim2.new(1,-6,0,12),pos=UDim2.new(0,6,0,51),font=Enum.Font.Gotham,sz=9,col=Color3.fromRGB(130,170,200),txt="",tr=Enum.TextTruncate.AtEnd,z=6}),
		}
		local idx=i
		row.InputBegan:Connect(function(input)if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end;local p=UI.plrRowMap[idx];if not p then return end;pcall(function()setclipboard("https://www.roblox.com/users/"..p.UserId.."/profile")end);showN(p.DisplayName~=p.Name and(p.DisplayName.." (@"..p.Name..")") or p.Name,"Profile URL copied!",C.WH) end)
		specBtn.MouseButton1Click:Connect(function()
			local p=UI.plrRowMap[idx];if not p then return end;if p==lp then showN("Spectate","Cannot spectate yourself",C.WRN);return end
			if S.specTarget==p then stopSpec();setText(UI.specStatusLbl,"Not spectating");setCol(UI.specStatusLbl,C.DIM);tw(UI.specStopBtn,{BackgroundColor3=Color3.fromRGB(28,28,28)},.15);UI.specStopBtn.TextColor3=C.DIM;showN("Spectate","Stopped",C.DIM)
			else startSpec(p);local dn=p.DisplayName~=p.Name and(p.DisplayName.." (@"..p.Name..")") or p.Name;setText(UI.specStatusLbl,"Spectating: "..dn);setCol(UI.specStatusLbl,C.SPEC);tw(UI.specStopBtn,{BackgroundColor3=C.SPEC},.15);UI.specStopBtn.TextColor3=C.BG;showN("Spectate","Now watching "..dn,C.SPEC) end
		end)
		specBtn.MouseEnter:Connect(function()tw(specBtn,{BackgroundColor3=Color3.fromRGB(100,180,240)},.1)end)
		specBtn.MouseLeave:Connect(function()local p=UI.plrRowMap[idx];tw(specBtn,{BackgroundColor3=(p and S.specTarget==p) and Color3.fromRGB(220,80,80) or C.SPEC},.1)end)
	end
end

-- ── INVENTORY TAB ────────────────────────────────────────────
do
	local sec1=section("inv",1,"Equipped")
	local eqRow=mk("Frame",sec1,{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=2,ZIndex=4})
	lbl(eqRow,{size=UDim2.new(1,0,0,12),sz=8,col=C.DIM,txt="EQUIPPED TOOL",z=5});UI.eqNameLbl=lbl(eqRow,{size=UDim2.new(1,0,0,16),pos=UDim2.new(0,0,0,12),sz=13,col=C.OFF,txt="None",tr=Enum.TextTruncate.AtEnd,z=5});UI.eqLvLbl=lbl(eqRow,{size=UDim2.new(1,0,0,12),pos=UDim2.new(0,0,0,24),font=Enum.Font.GothamBold,sz=10,col=C.WRN,txt="",z=5})
	local sec2=section("inv",2,"Backpack")
	local invSF=mk("ScrollingFrame",sec2,{Size=UDim2.new(1,0,0,380),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BOR2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=4,LayoutOrder=2}); mk("UIListLayout",invSF,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
	UI.invRows={}
	for i=1,20 do
		local cell=mk("Frame",invSF,{Size=UDim2.new(1,-4,0,58),BackgroundColor3=Color3.fromRGB(16,16,16),ZIndex=5,LayoutOrder=i,Visible=false});stroke(cell,C.BOR,1);corner(cell,4)
		local skillLbls={}
		for si,key in ipairs(SKILL_KEYS) do
			local xi=8+(si-1)*40
			local kl=lbl(cell,{size=UDim2.new(0,38,0,11),pos=UDim2.new(0,xi,0,28),sz=8,col=C.DIM,txt=key,ax=Enum.TextXAlignment.Center,z=6})
			local cl=lbl(cell,{size=UDim2.new(0,38,0,16),pos=UDim2.new(0,xi,0,39),sz=11,col=C.OK,txt="",ax=Enum.TextXAlignment.Center,z=6})
			kl.Visible=false;cl.Visible=false;skillLbls[key]={kl=kl,cl=cl}
		end
		mk("Frame",cell,{Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,0,24),BackgroundColor3=C.SEP,ZIndex=5})
		UI.invRows[i]={cell=cell,nameLbl=lbl(cell,{size=UDim2.new(1,-68,0,16),pos=UDim2.new(0,8,0,5),sz=11,col=C.OFF,txt="",tr=Enum.TextTruncate.AtEnd,z=6}),lvlLbl=lbl(cell,{size=UDim2.new(0,60,0,16),pos=UDim2.new(1,-66,0,5),sz=10,col=C.WRN,txt="",ax=Enum.TextXAlignment.Right,z=6}),skillLbls=skillLbls}
	end
end

-- ── LOG TAB ──────────────────────────────────────────────────
do
	local afkSec=section("log",1,"AFK Profit Estimator")
	UI.afkRateLbl=secLbl(afkSec,2,"Based on current Beli/min rate",C.DIM,9)
	local afkHours={1,4,8,24};UI.afkRows={}
	local afkRowF=mk("Frame",afkSec,{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,LayoutOrder=3,ZIndex=4});local afkW=math.floor(K.IW/4)-3
	for i,h in ipairs(afkHours) do local xi=(i-1)*(afkW+4);lbl(afkRowF,{size=UDim2.new(0,afkW,0,12),pos=UDim2.new(0,xi,0,0),sz=8,col=C.DIM,txt=h.."H",z=5});UI.afkRows[i]={bL=lbl(afkRowF,{size=UDim2.new(0,afkW,0,14),pos=UDim2.new(0,xi,0,12),sz=10,col=C.BELI,txt="+0",z=5}),fL=lbl(afkRowF,{size=UDim2.new(0,afkW,0,13),pos=UDim2.new(0,xi,0,27),sz=9,col=C.FRAG,txt="+0",z=5}),h=h} end
	local healthSec=section("log",2,"Server Health")
	local healthRow=mk("Frame",healthSec,{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=2,ZIndex=4});local hw3=math.floor(K.IW/3)-4
	lbl(healthRow,{size=UDim2.new(0,hw3,0,12),sz=8,col=C.DIM,txt="AVG FPS",z=5});lbl(healthRow,{size=UDim2.new(0,hw3,0,12),pos=UDim2.new(0,hw3+4,0,0),sz=8,col=C.DIM,txt="INSTANCES",z=5});lbl(healthRow,{size=UDim2.new(0,hw3,0,12),pos=UDim2.new(0,(hw3+4)*2,0,0),sz=8,col=C.DIM,txt="STATUS",z=5})
	UI.hFpsLbl=lbl(healthRow,{size=UDim2.new(0,hw3,0,16),pos=UDim2.new(0,0,0,14),sz=13,col=C.OK,txt="60",z=5});UI.hInstLbl=lbl(healthRow,{size=UDim2.new(0,hw3,0,16),pos=UDim2.new(0,hw3+4,0,14),sz=13,col=C.OFF,txt="0",z=5});UI.hStatLbl=lbl(healthRow,{size=UDim2.new(0,hw3,0,16),pos=UDim2.new(0,(hw3+4)*2,0,14),sz=11,col=C.OK,txt="✅ OK",z=5})
	UI.hBarBg=mk("Frame",healthSec,{Size=UDim2.new(1,0,0,4),BackgroundColor3=C.BOR,ZIndex=4,LayoutOrder=3});corner(UI.hBarBg,2);UI.hBarFl=mk("Frame",UI.hBarBg,{Size=UDim2.new(1,0,1,0),BackgroundColor3=C.OK,ZIndex=5});corner(UI.hBarFl,2)
	local threshRow=inlineRow(healthSec,4);local threshBox=inlineBox(threshRow,0,K.IW-70,"FPS threshold (default: 30)");local threshBtn=inlineBtn(threshRow,K.IW-66,62,"SET",C.OK)
	threshBtn.MouseButton1Click:Connect(function()local n=tonumber(threshBox.Text);if n and n>0 then cfg.HealthFPSThreshold=n;threshBox.Text="";threshBox.PlaceholderText="Threshold: "..n;showN("Server Health","Alert FPS < "..n,C.OK) else showN("Server Health","Enter a number",C.WRN) end end)
	local logCtrlSec=section("log",3,"Session Log")
	UI.logCountLbl=secLbl(logCtrlSec,2,"0 entries",C.DIM,9)
	local logBtnRow=inlineRow(logCtrlSec,3);local hw4=math.floor((K.IW-4)/2)
	local logNowBtn=inlineBtn(logBtnRow,0,hw4,"Log Now",C.OK);local logClrBtn=inlineBtn(logBtnRow,hw4+4,hw4,"Clear All",C.ERR)
	addHov(logNowBtn,function()return C.OK end);addHov(logClrBtn,function()return C.ERR end)
	local logListSec=section("log",4,"History  (newest first)")
	local logSF=mk("ScrollingFrame",logListSec,{Size=UDim2.new(1,0,0,200),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BOR2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=4,LayoutOrder=2}); mk("UIListLayout",logSF,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
	UI.logRows={}
	for i=1,50 do
		local card=mk("Frame",logSF,{Size=UDim2.new(1,-4,0,76),BackgroundColor3=Color3.fromRGB(14,14,14),ZIndex=5,LayoutOrder=i,Visible=false});stroke(card,C.BOR,1);corner(card,4)
		mk("UIPadding",card,{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5)}); mk("UIListLayout",card,{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder})
		UI.logRows[i]={card=card,
			line1=mk("TextLabel",card,{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.WHT,Text="",TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,ZIndex=6}),
			line2=mk("TextLabel",card,{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.BELI,Text="",TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=2,ZIndex=6}),
			line3=mk("TextLabel",card,{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.FRAG,Text="",TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=3,ZIndex=6}),
			line4=mk("TextLabel",card,{Size=UDim2.new(1,0,0,11),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=9,TextColor3=C.DIM,Text="",TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=4,ZIndex=6}),
		}
	end
	local evSec=section("log",5,"Event Timeline")
	local evClearRow=inlineRow(evSec,2);local evClrBtn=mk("TextButton",evClearRow,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,28),BorderSizePixel=0,Text="Clear Events",TextColor3=C.WRN,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=4});stroke(evClrBtn,C.BOR2,1);corner(evClrBtn,4)
	addHov(evClrBtn,function()return Color3.fromRGB(28,28,28)end)
	local evSF=mk("ScrollingFrame",evSec,{Size=UDim2.new(1,0,0,240),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.BOR2,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=4,LayoutOrder=3}); mk("UIListLayout",evSF,{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder})
	UI.evRows={}
	for i=1,100 do
		local row=mk("Frame",evSF,{Size=UDim2.new(1,-4,0,36),BackgroundColor3=Color3.fromRGB(14,14,14),ZIndex=5,LayoutOrder=i,Visible=false});stroke(row,C.BOR,1);corner(row,4)
		mk("UIPadding",row,{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)}); mk("UIListLayout",row,{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder})
		UI.evRows[i]={row=row,typeLbl=mk("TextLabel",row,{Size=UDim2.new(1,0,0,13),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.WHT,Text="",TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,ZIndex=6}),detailLbl=mk("TextLabel",row,{Size=UDim2.new(1,0,0,11),BackgroundTransparency=1,Font=Enum.Font.Gotham,TextSize=9,TextColor3=C.DIM,Text="",TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=2,ZIndex=6})}
	end
	local function refreshLogUI() setText(UI.logCountLbl,#S.logs.." entries (max 50)");for i=1,50 do local row=UI.logRows[i];local entry=S.logs[i];if entry then row.card.Visible=true;local srcCol=({["Auto Hop"]=C.HOP,["Instant Hop"]=C.HOP,["Manual"]=C.OK,["Webhook Time"]=C.WH})[entry.source] or C.DIM;row.line1.TextColor3=srcCol;setText(row.line1,"#"..i.."  ["..entry.source.."]  —  "..entry.time);setText(row.line2,"Beli  "..(entry.beli>=0 and"+" or"")..fmtN(entry.beli).."   ("..wFmt(entry.bPM).."/min  "..wFmt(entry.bPM*60).."/hr)");setText(row.line3,"Frag  "..(entry.frags>=0 and"+" or"")..fmtN(entry.frags).."   ("..wFmt(entry.fPM).."/min  "..wFmt(entry.fPM*60).."/hr)");setText(row.line4,"Duration: "..fmtS(entry.elapsed)) else row.card.Visible=false end end end
	local function refreshEventUI() for i=1,100 do local row=UI.evRows[i];local entry=S.events[i];if entry then row.row.Visible=true;row.typeLbl.TextColor3=entry.col;setText(row.typeLbl,entry.evType);setText(row.detailLbl,entry.detail.."  —  "..entry.time) else row.row.Visible=false end end end
	local function refreshAfkUI() local bPM=calcRate(S.beliHist);local fPM=calcRate(S.fragHist);setText(UI.afkRateLbl,"Rate: "..wFmt(bPM).."/min Beli  "..wFmt(fPM).."/min Frag");for _,r in ipairs(UI.afkRows) do local mins=r.h*60;setText(r.bL,"+"..fmtN(math.max(0,math.floor(bPM*mins))));setText(r.fL,"+"..fmtN(math.max(0,math.floor(fPM*mins)))) end end
	local function refreshHealthUI()
		local avg=S.health.avgFPS;local inst=S.health.instanceCount;local lag=S.health.lagDetected
		setText(UI.hFpsLbl,tostring(avg));setCol(UI.hFpsLbl,avg>=50 and C.OK or avg>=(cfg.HealthFPSThreshold or 30) and C.WRN or C.ERR)
		setText(UI.hInstLbl,fmtN(inst));setCol(UI.hInstLbl,inst<5000 and C.OK or inst<10000 and C.WRN or C.ERR)
		setText(UI.hStatLbl,lag and"⚠️ LAG" or"✅ OK");setCol(UI.hStatLbl,lag and C.ERR or C.OK)
		setBar(UI.hBarFl,math.clamp(avg/60,0,1));tw(UI.hBarFl,{BackgroundColor3=avg>=50 and C.OK or avg>=(cfg.HealthFPSThreshold or 30) and C.WRN or C.ERR},.2)
	end
	logNowBtn.MouseButton1Click:Connect(function()addLog("Manual");refreshLogUI();showN("Log","Saved entry #"..#S.logs,C.OK) end)
	logClrBtn.MouseButton1Click:Connect(function()S.logs={};refreshLogUI();showN("Log","Cleared all entries",C.ERR) end)
	evClrBtn.MouseButton1Click:Connect(function()S.events={};refreshEventUI();showN("Events","Cleared",C.ERR) end)
	UI._refreshLogUI=refreshLogUI;UI._refreshEventUI=refreshEventUI;UI._refreshAfkUI=refreshAfkUI;UI._refreshHealthUI=refreshHealthUI
end

-- ── BUTTON EVENTS ────────────────────────────────────────────
UI.v1Btn.MouseButton1Click:Connect(function()S.v1=not S.v1;task.spawn(setV1,S.v1);tog(UI.v1Btn,S.v1,C.V1,Color3.fromRGB(28,28,28),"Boost V1: On","Boost V1: Off");showN("Boost V1",S.v1 and"On — Map hidden" or"Off",S.v1 and C.V1 or C.ERR) end)
UI.v2Btn.MouseButton1Click:Connect(function()S.v2=not S.v2;task.spawn(setV2,S.v2);tog(UI.v2Btn,S.v2,C.V2,Color3.fromRGB(28,28,28),"Boost V2: On","Boost V2: Off");showN("Boost V2",S.v2 and"On — Low graphics" or"Off",S.v2 and C.V2 or C.ERR) end)
UI.v3Btn.MouseButton1Click:Connect(function()S.v3=not S.v3;task.spawn(setV3,S.v3);tog(UI.v3Btn,S.v3,C.V3,Color3.fromRGB(28,28,28),"Boost V3: On","Boost V3: Off");showN("Boost V3",S.v3 and"On — All visuals stripped" or"Off",S.v3 and C.V3 or C.ERR) end)
UI.hidBtn.MouseButton1Click:Connect(function()S.hidPlr=not S.hidPlr;toggleHidePlr(S.hidPlr);tog(UI.hidBtn,S.hidPlr,C.WHT,Color3.fromRGB(28,28,28),"Delete Players: On","Delete Players: Off");showN("Delete Players",S.hidPlr and"Players hidden" or"Players restored",S.hidPlr and C.OK or C.ERR) end)
UI.enmBtn.MouseButton1Click:Connect(function()S.hidEnm=not S.hidEnm;task.spawn(toggleHidEnm,S.hidEnm);tog(UI.enmBtn,S.hidEnm,C.ERR,Color3.fromRGB(28,28,28),"Hide Enemies: On","Hide Enemies: Off");showN("Hide Enemies",S.hidEnm and"Enemies hidden" or"Enemies shown",S.hidEnm and C.ERR or C.DIM) end)
UI.whBtn.MouseButton1Click:Connect(function()S.wh=not S.wh;cfg.WebhookEnabled=S.wh;tog(UI.whBtn,S.wh,C.WH,Color3.fromRGB(28,28,28),"Webhook: On","Webhook: Off");showN("Webhook",S.wh and"Enabled" or"Disabled",S.wh and C.WH or C.ERR) end)
UI.whTestBtn.MouseButton1Click:Connect(function()task.spawn(function()local cb=getStat("Beli") or 0;local cf=getStat("Fragments") or 0;local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick();sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0,S.sessOK and math.floor(cf-(S.sessF or cf)) or 0,tick()-jt,"Test");showN("Test Webhook","Sent! #"..S.whTotal,C.WH) end) end)
UI.whTimBtn.MouseButton1Click:Connect(function()if S.whTimer then stopWHTimer();tog(UI.whTimBtn,false,C.WH,Color3.fromRGB(28,28,28),"WH Timer: On","WH Timer: Off");showN("WH Timer","Disabled",C.ERR) else if not S.wh then S.wh=true;cfg.WebhookEnabled=true;tog(UI.whBtn,true,C.WH,Color3.fromRGB(28,28,28),"Webhook: On","Webhook: Off") end;startWHTimer();tog(UI.whTimBtn,true,C.WH,Color3.fromRGB(28,28,28),"WH Timer: On","WH Timer: Off");showN("WH Timer","Every "..cfg.WebhookInterval.." min",C.WH) end end)
UI.hopBtn.MouseButton1Click:Connect(function()if S.hop then stopHop();tog(UI.hopBtn,false,C.HOP,Color3.fromRGB(28,28,28),"Auto Hop: On","Auto Hop: Off");showN("Auto Hop","Disabled",C.ERR) else startHop();tog(UI.hopBtn,true,C.HOP,Color3.fromRGB(28,28,28),"Auto Hop: On","Auto Hop: Off");showN("Auto Hop","Every "..cfg.HopInterval.." min",C.HOP) end end)
UI.hopNowBtn.MouseButton1Click:Connect(function()showN("Hop Now","Hopping...",C.HOP);task.spawn(function()local cb=getStat("Beli") or 0;local cf=getStat("Fragments") or 0;local jt=S.plrC[lp.UserId] and S.plrC[lp.UserId].join or tick();S.hopTotal+=1;addLog("Instant Hop");sendWebhook(S.sessOK and math.floor(cb-(S.sessB or cb)) or 0,S.sessOK and math.floor(cf-(S.sessF or cf)) or 0,tick()-jt,"Instant Hop");doHop() end) end)
for _,h in ipairs({{UI.v1Btn,function()return S.v1 and C.V1 or Color3.fromRGB(28,28,28)end},{UI.v2Btn,function()return S.v2 and C.V2 or Color3.fromRGB(28,28,28)end},{UI.v3Btn,function()return S.v3 and C.V3 or Color3.fromRGB(28,28,28)end},{UI.hidBtn,function()return S.hidPlr and C.WHT or Color3.fromRGB(28,28,28)end},{UI.enmBtn,function()return S.hidEnm and C.ERR or Color3.fromRGB(28,28,28)end},{UI.hopBtn,function()return S.hop and C.HOP or Color3.fromRGB(28,28,28)end},{UI.hopNowBtn,function()return C.HOP end},{UI.whBtn,function()return S.wh and C.WH or Color3.fromRGB(28,28,28)end},{UI.whTestBtn,function()return Color3.fromRGB(28,28,28)end},{UI.whTimBtn,function()return S.whTimer and C.WH or Color3.fromRGB(28,28,28)end},{UI.pullBtn,function()return BM.on and C.PULL or Color3.fromRGB(28,28,28)end},{UI.pullBtn2,function()return BM2.on and C.BM2 or Color3.fromRGB(28,28,28)end},{UI.fakeLvBtn,function()return S.fakeLevel and C.FAKE or Color3.fromRGB(28,28,28)end},{UI.rerunBtn,function()return S.rerun and C.RERUN or Color3.fromRGB(28,28,28)end},{UI.specStopBtn,function()return S.specTarget and C.SPEC or Color3.fromRGB(28,28,28)end},{UI.infJumpBtn,function()return S.infJump and C.OK or Color3.fromRGB(28,28,28)end}}) do addHov(h[1],h[2]) end

-- GUI fade toggle (Right Ctrl)
UIS.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode==Enum.KeyCode.RightControl then
		_vis=not _vis
		if _vis then
			full.Visible=true
			for _,obj in ipairs(full:GetDescendants()) do pcall(function()if obj:IsA("TextLabel") or obj:IsA("TextButton") then TS:Create(obj,TweenInfo.new(.25),{TextTransparency=0}):Play() end end) end
			TS:Create(full,TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
		else
			TS:Create(full,TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
			for _,obj in ipairs(full:GetDescendants()) do pcall(function()if obj:IsA("TextLabel") or obj:IsA("TextButton") then TS:Create(obj,TweenInfo.new(.2),{TextTransparency=1}):Play() end end) end
			task.delay(.32,function()full.Visible=false end)
		end
	end
end)

-- ── SELF HIGHLIGHT ───────────────────────────────────────────
local function applyHL(char) if S.selfHL and S.selfHL.Parent then S.selfHL:Destroy() end;S.selfHL=nil;if not char then return end;S.selfHL=mk("Highlight",char,{Name="ESP_SelfHL",FillColor=Color3.new(1,1,1),OutlineColor=Color3.new(0,0,0),FillTransparency=.5,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Adornee=char}) end
if lp.Character then task.delay(.5,function()applyHL(lp.Character)end) end
lp.CharacterAdded:Connect(function(char)task.wait(.5);applyHL(char) end)
lp.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	if S.speedMult>1 then local hum=char:FindFirstChildOfClass("Humanoid");if hum then pcall(function()hum.WalkSpeed=BASE_WS*S.speedMult end) end end
	if S.infJump then setInfJump(true) end
	addEvent("💀 Respawned",lp.Name,C.WRN)
end)

-- ── UPDATE FUNCTIONS ─────────────────────────────────────────
local function updateFast()
	local e=tick()-S.start; setText(UI.fpsLbl,"FPS "..S.fps)
	local ping=getPing();setText(UI.pingLbl,"PING "..ping.."ms");setCol(UI.pingLbl,ping<80 and C.OK or ping<150 and C.WRN or C.ERR)
	setText(UI.timeLbl,("%02d:%02d:%02d"):format(math.floor(e/3600),math.floor(e%3600/60),math.floor(e%60)))
	local hopStr=S.hop and(function()local sv=math.max(0,math.floor(S.hopCD));return("%02d:%02d"):format(math.floor(sv/60),sv%60)end)() or"DISABLED"
	setText(UI.hopCD,hopStr);setCol(UI.hopCD,S.hop and C.HOP or C.DIM)
	local whStr=S.whTimer and(function()local sv=math.max(0,math.floor(S.whCD));return("%02d:%02d next send"):format(math.floor(sv/60),sv%60)end)() or"DISABLED"
	setText(UI.whCD,whStr);setCol(UI.whCD,S.whTimer and C.WH or C.DIM)
	if BM.on then local pc=0;for _ in pairs(BM.data) do pc+=1 end;setText(UI.bmCountLbl,"V1 Pulled: "..pc.."/"..BM.batch.." | Dist: "..BM.dist);setCol(UI.bmCountLbl,C.PULL) end
	if BM2.on then
		setText(UI.bm2StatusLbl,"V2 ON | "..BM2.interval.."s | Max:"..BM2.maxCount.." | Dist:"..BM2.dist);setCol(UI.bm2StatusLbl,C.BM2)
		local aStr=BM2.anchorPos and("%.0f,%.0f,%.0f"):format(BM2.anchorPos.X,BM2.anchorPos.Y,BM2.anchorPos.Z) or"Follow Mode";setText(UI.bm2AnchorLbl,"V2 Anchor: "..aStr)
		if BM2.resetInterval>0 then local left=math.max(0,math.floor(BM2.resetInterval-(tick()-BM2.resetTick)));setText(UI.bm2ResetLbl,"V2 Reset in: "..left.."s");setCol(UI.bm2ResetLbl,left<5 and C.WRN or C.DIM) else setText(UI.bm2ResetLbl,"V2 Reset: never");setCol(UI.bm2ResetLbl,C.DIM) end
	end
	if S.fakeLevel and S.fakeLevelVal then setText(UI.fakeLvStatus,"ACTIVE — LV "..fmtN(S.fakeLevelVal));setCol(UI.fakeLvStatus,C.FAKE) end
	if S.specTarget then local dn=S.specTarget.DisplayName~=S.specTarget.Name and(S.specTarget.DisplayName.." (@"..S.specTarget.Name..")") or S.specTarget.Name;setText(UI.specStatusLbl,"Spectating: "..dn);setCol(UI.specStatusLbl,C.SPEC) end
	if UI.speedLbl and S.speedMult>1 then setText(UI.speedLbl,"Speed: "..S.speedMult.."x  (WalkSpeed "..math.floor(BASE_WS*S.speedMult)..")");S.last[UI.speedLbl]=nil end
end
local function updateStats()
	local lv=getStat("Level");local beli=getStat("Beli");local frags=getStat("Fragments")
	local melee=getStat("Melee");local def=getStat("Defense");local sword=getStat("Sword");local gun=getStat("Gun");local fruit=getStat("Blox Fruit");local sp=getStat("SpawnPoint")
	setText(UI.charLbl,lp.DisplayName~=lp.Name and(lp.DisplayName.." (@"..lp.Name..")") or lp.Name);setText(UI.lvlLbl,"LV. "..fmtV(lv,"Level"))
	setText(UI.beliLbl,fmtV(beli,"Beli"));setCol(UI.beliLbl,C.BELI);setText(UI.fragLbl,fmtV(frags,"Fragments"));setCol(UI.fragLbl,C.FRAG)
	if not S.sessOK and beli and frags then S.sessB=beli;S.sessF=frags;S.sessOK=true end
	if S.sessOK then local gb=math.floor((beli or 0)-S.sessB);local gf=math.floor((frags or 0)-S.sessF);setText(UI.sessBLbl,(gb>=0 and"+" or"")..fmtV(gb,"Beli"));setCol(UI.sessBLbl,gb>=0 and C.BELI or C.ERR);setText(UI.sessFLbl,(gf>=0 and"+" or"")..fmtV(gf,"Fragments"));setCol(UI.sessFLbl,gf>=0 and C.FRAG or C.ERR) end
	setText(UI.meleeLbl,fmtV(melee));setBar(UI.meleeBar,(melee or 0)/K.COMBAT);setText(UI.defLbl,fmtV(def));setBar(UI.defBar,(def or 0)/K.COMBAT)
	setText(UI.swordLbl,fmtV(sword));setBar(UI.swordBar,(sword or 0)/K.COMBAT);setText(UI.gunLbl,fmtV(gun));setBar(UI.gunBar,(gun or 0)/K.COMBAT);setText(UI.fruitLbl,fmtV(fruit));setBar(UI.fruitBar,(fruit or 0)/K.COMBAT)
	local rn,rt=getRace(lp);setText(UI.raceLbl,rn and(rn..(rt and" [V"..rt.."]" or"")) or"Not V4");setText(UI.teamLbl,lp.Team and lp.Team.Name or"N/A");setText(UI.spawnLbl,sp~=nil and fmtSpawn(tostring(sp)) or"??")
end
local function updateRates()
	local bPM2=calcRate(S.beliHist);local fPM2=calcRate(S.fragHist)
	local function rs(v) local sg=v>=0 and"+" or"";return math.abs(v)>=1e6 and sg..("%.1fM"):format(v/1e6) or math.abs(v)>=1e3 and sg..("%.1fK"):format(v/1e3) or sg..tostring(v) end
	setText(UI.bPMLbl,rs(bPM2));setCol(UI.bPMLbl,bPM2>=0 and C.BELI or C.ERR);setText(UI.bHRLbl,rs(bPM2*60));setCol(UI.bHRLbl,bPM2>=0 and C.BELI or C.ERR)
	setText(UI.fPMLbl,rs(fPM2));setCol(UI.fPMLbl,fPM2>=0 and C.FRAG or C.ERR);setText(UI.fHRLbl,rs(fPM2*60));setCol(UI.fHRLbl,fPM2>=0 and C.FRAG or C.ERR)
end
local function updateInv()
	local en,elv=getEquipped();setText(UI.eqNameLbl,en)
	if elv~=nil then setText(UI.eqLvLbl,"LV "..fmtN(elv));setCol(UI.eqLvLbl,C.WRN) else setText(UI.eqLvLbl,en~="None" and"No Level" or"");setCol(UI.eqLvLbl,C.DIM) end
	local items=getInv()
	for i=1,20 do local pf=UI.invRows[i];local item=items[i]; if item then pf.cell.Visible=true;setText(pf.nameLbl,item.name);setText(pf.lvlLbl,"LV "..math.floor(item.level));for _,key in ipairs(SKILL_KEYS) do pf.skillLbls[key].kl.Visible=false;pf.skillLbls[key].cl.Visible=false end;local rl=getSkillLevels(item.name);local idx=0;for _,key in ipairs(SKILL_KEYS) do local r=rl[key];if r~=nil and item.level~=nil then local sl=pf.skillLbls[key];sl.kl.Position=UDim2.new(0,8+idx*40,0,28);sl.cl.Position=UDim2.new(0,8+idx*40,0,39);sl.kl.Visible=true;sl.cl.Visible=true;setText(sl.cl,item.level>=r and"OK" or"NO");setCol(sl.cl,item.level>=r and C.OK or C.ERR);idx+=1 end end else pf.cell.Visible=false end end
end
local function updatePlayers()
	local list=Pl:GetPlayers();local ratio=math.clamp(#list/K.MAX,0,1);setText(UI.pcLbl,#list.." / "..K.MAX)
	local barCol=ratio>=1 and C.ERR or ratio>=.75 and C.WRN or C.WHT;tw(UI.svrBar,{BackgroundColor3=barCol},.2);setCol(UI.pcLbl,barCol);setBar(UI.svrBar,ratio)
	local totalB=0;for _,p in ipairs(list) do local c=S.plrC[p.UserId];if c and c.bounty then totalB+=c.bounty else local bo=getStatObj(p,"Bounty");if bo then totalB+=(bo.Value or 0) end end end
	setText(UI.bountyLbl,fmtN(totalB))
	local myC=lp.Character;local myR=myC and myC:FindFirstChild("HumanoidRootPart");local distC={}
	for _,p in ipairs(list) do if p~=lp then local d=math.huge;if myR then local th=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if th then local ok,mag=pcall(function()return(myR.Position-th.Position).Magnitude end);if ok then d=mag end end end;distC[p.UserId]=d end end
	table.sort(list,function(a,b)if a==lp then return true end;if b==lp then return false end;return(distC[a.UserId] or math.huge)<(distC[b.UserId] or math.huge) end)
	for i=1,20 do
		local pf=UI.plrRows[i];local p=list[i];UI.plrRowMap[i]=p or nil
		if p and pf then
			pf.row.Visible=true;local ns=p.DisplayName~=p.Name and(p.DisplayName.." (@"..p.Name..")") or p.Name;setText(pf.nameLbl,ns);setCol(pf.nameLbl,p==lp and C.OK or C.WHT)
			local plv=getStat("Level",p);setText(pf.lvlLbl,plv~=nil and("LV"..fmtV(plv,"Level")) or"LV??")
			local isSpec=S.specTarget==p;tw(pf.specBtn,{BackgroundColor3=isSpec and Color3.fromRGB(220,80,80) or(p==lp and Color3.fromRGB(40,40,40) or C.SPEC)},.12);pf.specBtn.Text=isSpec and"STOP" or"SPEC";pf.specBtn.Active=(p~=lp)
			if p~=lp then local cache=S.plrC[p.UserId] or{};setText(pf.raceLbl,cache.race and("Race: "..cache.race..(cache.raceTier and" V/T "..cache.raceTier or"")) or"Race: ?");setText(pf.spawnLbl,cache.spawn and("Loc: "..fmtSpawn(tostring(cache.spawn))) or"Loc: ?");setText(pf.bountyLbl,cache.bounty~=nil and("Bounty: "..fmtN(cache.bounty)) or"Bounty: ?");local rd=distC[p.UserId] or math.huge;setText(pf.distLbl,rd==math.huge and"?" or(fmtN(math.floor(rd*K.S2M)).."m"));setText(pf.timeLbl,serverT(cache.join))
			else setText(pf.raceLbl,"");setText(pf.spawnLbl,"");setText(pf.bountyLbl,"");setText(pf.distLbl,"YOU");setCol(pf.distLbl,C.OK);setText(pf.timeLbl,serverT(S.plrC[lp.UserId] and S.plrC[lp.UserId].join)) end
		elseif pf then pf.row.Visible=false;UI.plrRowMap[i]=nil end
	end
end

-- ── MAIN LOOPS ───────────────────────────────────────────────
Run.RenderStepped:Connect(function() S.fc+=1;local n=tick();if n-S.fpsT>=.5 then S.fps=math.floor(S.fc/(n-S.fpsT));S.fc=0;S.fpsT=n end end)
local _frame=0
Run.Heartbeat:Connect(function()
	if not _vis then return end; _frame=(_frame+1)%3600
	if _frame%3==0  then updateFast() end
	if _frame%12==0 then updateStats() end
	if _frame%12==0 and S.activeTab=="inv"     then updateInv() end
	if _frame%18==0 and S.activeTab=="players" then updatePlayers() end
	if _frame%60==0  then checkServerHealth() end
	if _frame%120==0 then checkMilestones() end
	if _frame%300==0 then updateRates() end
	if _frame%600==0 then pushH(S.beliHist,getStat("Beli"));pushH(S.fragHist,getStat("Fragments")) end
	if _frame%30==0  and S.activeTab=="log" then if UI._refreshLogUI then UI._refreshLogUI() end;if UI._refreshEventUI then UI._refreshEventUI() end;if UI._refreshAfkUI then UI._refreshAfkUI() end;if UI._refreshHealthUI then UI._refreshHealthUI() end end
end)

-- ── PLAYER EVENTS ────────────────────────────────────────────
Pl.PlayerAdded:Connect(function(p)
	task.wait(1);S.plrC[p.UserId]=S.plrC[p.UserId] or{};S.plrC[p.UserId].join=tick();watchPlr(p)
	local dn=p.DisplayName~=p.Name and(p.DisplayName.." (@"..p.Name..")") or p.Name;showN(dn,"Joined the server",C.OK);addEvent("🟢 Joined",p.Name.." (LV "..(getStat("Level",p) and fmtN(getStat("Level",p)) or"?")..")",C.OK)
end)
Pl.PlayerRemoving:Connect(function(p)
	local uid=p.UserId;local dn=p.DisplayName~=p.Name and(p.DisplayName.." (@"..p.Name..")") or p.Name;showN(dn,"Left the server",C.ERR);addEvent("🔴 Left",p.Name,C.ERR)
	if S.specTarget==p then stopSpec();setText(UI.specStatusLbl,"Not spectating");setCol(UI.specStatusLbl,C.DIM);tw(UI.specStopBtn,{BackgroundColor3=Color3.fromRGB(28,28,28)},.15);UI.specStopBtn.TextColor3=C.DIM end
	for _,t in ipairs({S.spawnW,S.raceW,S.bountyW,S.hidPlrC}) do if t[uid] then t[uid]:Disconnect();t[uid]=nil end end; S.plrC[uid]=nil;S.statC[uid]=nil
end)
for _,p in ipairs(Pl:GetPlayers()) do if p~=lp then watchPlr(p) end end

-- ── SKILL PRECACHE ───────────────────────────────────────────
local function preCacheSkills()
	if not lp.Character then return end;local char=lp.Character;while not char:FindFirstChild("HumanoidRootPart") do task.wait(.1) end
	local hum=char:WaitForChild("Humanoid",10);if not hum then return end;local bp=lp:WaitForChild("Backpack",10);if not bp then return end; task.wait(1)
	for _,tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") then pcall(function()hum:EquipTool(tool)end);task.wait(.15);S.skillC[tool.Name]=getSkillLevels(tool.Name);pcall(function()hum:UnequipTools()end);task.wait(.15) end end
end
lp.CharacterAdded:Connect(function()S.skillC={};task.spawn(preCacheSkills)end);task.spawn(preCacheSkills)

-- ── INIT ─────────────────────────────────────────────────────
if cfg.RemoveDeathEffect then
	local function rde() pcall(function()local d=game:GetService("ReplicatedStorage"):WaitForChild("Effect",10):WaitForChild("Container",10):WaitForChild("Death",10);if d then d:Destroy() end end) end
	rde();lp.CharacterAdded:Connect(function()task.wait(.5);rde()end)
end
if cfg.BoostV1 then task.spawn(function()task.wait(2);S.v1=true;setV1(true);tog(UI.v1Btn,true,C.V1,Color3.fromRGB(28,28,28),"Boost V1: On","Boost V1: Off")end) end
if cfg.BoostV2 then task.spawn(function()task.wait(2);S.v2=true;setV2(true);tog(UI.v2Btn,true,C.V2,Color3.fromRGB(28,28,28),"Boost V2: On","Boost V2: Off")end) end
if cfg.BoostV3 then task.spawn(function()task.wait(2);S.v3=true;setV3(true);tog(UI.v3Btn,true,C.V3,Color3.fromRGB(28,28,28),"Boost V3: On","Boost V3: Off")end) end
if cfg.HidePlayers then task.spawn(function()task.wait(1);toggleHidePlr(true)end) end
if cfg.HideEnemies  then task.spawn(function()task.wait(2);toggleHidEnm(true)end) end
if cfg.AutoHop      then task.spawn(function()task.wait(6);startHop()end) end
if cfg.WebhookEnabled then S.wh=true;tog(UI.whBtn,true,C.WH,Color3.fromRGB(28,28,28),"Webhook: On","Webhook: Off") end
if cfg.LockFps.on   then pcall(function()settings().Rendering.FrameRateManager.MaxFrameRate=cfg.LockFps.fps end);pcall(function()setfpscap(cfg.LockFps.fps)end) end
if cfg.AutoRerun and cfg.AutoRerunURL and cfg.AutoRerunURL~="" then task.spawn(function()task.wait(3);startRerun();tog(UI.rerunBtn,true,C.RERUN,Color3.fromRGB(28,28,28),"Auto Rerun: On","Auto Rerun: Off")end) end
addEvent("🚀 Panel Loaded","BloxHub v3 started",C.OK)
switchTab("status")
_closeLoader()
