-- getenv = function() return {
-- 	["Remove Death Effect"] = true,
--	["Lock Fps"] = { ["Enabled"] = true, ["FPS"] = 120 },
--	["White Screen"] = false,
--	["Boost FPS"] = false,
-- } end

local config = getenv()
local Players, RunService, UIS, TweenService, StatsService, WS =
    game:GetService("Players"), game:GetService("RunService"),
    game:GetService("UserInputService"), game:GetService("TweenService"),
    game:GetService("Stats"), game:GetService("Workspace")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
if pg:FindFirstChild("IntegratedStatusHUD") then pg.IntegratedStatusHUD:Destroy() end
if player.Character and player.Character:FindFirstChild("ESP_SelfHL") then player.Character.ESP_SelfHL:Destroy() end

local MAX_PLAYERS = Players.MaxPlayers
local COMBAT_CAP  = 2800
local FPS_CAP     = config["Lock Fps"]["Enabled"] and config["Lock Fps"]["FPS"] or 60

if config["Lock Fps"]["Enabled"] then
    pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate = FPS_CAP end)
    pcall(function() setfpscap(FPS_CAP) end)
end

local boostFpsActive = config["Boost FPS"]
local hiddenParts, boostConn = {}, nil

local function setMapVisibility(invisible)
    if invisible then
        hiddenParts = {}
        for _, v in ipairs(WS:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    hiddenParts[#hiddenParts+1] = {obj=v, trans=v.Transparency}
                    v.Transparency = 1
                end
            end)
        end
        if boostConn then boostConn:Disconnect() end
        boostConn = WS.DescendantAdded:Connect(function(v)
            pcall(function() if v:IsA("BasePart") then v.Transparency = 1 end end)
        end)
    else
        if boostConn then boostConn:Disconnect(); boostConn = nil end
        for _, d in ipairs(hiddenParts) do
            if d.obj and d.obj.Parent then d.obj.Transparency = d.trans end
        end
        hiddenParts = {}
    end
end

if boostFpsActive then task.spawn(function() task.wait(2); setMapVisibility(true) end) end

local function removeDeathEffect()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local death = rs:WaitForChild("Effect",10):WaitForChild("Container",10):WaitForChild("Death",10)
        if death then death:Destroy() end
    end)
end
if config["Remove Death Effect"] then
    removeDeathEffect()
    player.CharacterAdded:Connect(function() task.wait(0.5); removeDeathEffect() end)
end

local function getValueByPaths(root, ...)
    for _, path in ipairs({...}) do
        local obj = root
        for part in path:gmatch("[^%.]+") do
            if not obj then break end
            obj = obj:FindFirstChild(part)
        end
        if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue")) then
            return obj.Value
        end
    end
end

local STAT_PATHS = {
    Level     = {"leaderstats.Level","leaderstats.Lv.","Data.Level"},
    Beli      = {"leaderstats.Beli","leaderstats.Money","Data.Beli"},
    Fragments = {"leaderstats.Fragments","leaderstats.Fragment","Data.Fragments"},
    Melee     = {"leaderstats.Melee","Data.Stats.Melee.Level"},
    Defense   = {"leaderstats.Defense","Data.Stats.Defense.Level"},
    Sword     = {"leaderstats.Sword","Data.Stats.Sword.Level"},
    Gun       = {"leaderstats.Gun","Data.Stats.Gun.Level"},
    ["Blox Fruit"] = {"leaderstats.Blox Fruit","leaderstats.Demon Fruit","Data.Stats.Blox Fruit.Level","Data.Stats.Demon Fruit.Level"},
    Bounty    = {"leaderstats.Bounty/Honor","leaderstats.Bounty","leaderstats.Honor"},
    SpawnPoint= {"Data.LastSpawnPoint"},
}

local function getStat(key, root)
    root = root or player
    local paths = STAT_PATHS[key]
    if not paths then return getValueByPaths(root,"leaderstats."..key,"Data."..key) end
    return getValueByPaths(root, table.unpack(paths))
end

local function formatVal(v, key)
    if type(v) ~= "number" then return tostring(v or "?") end
    if key == "Beli" or key == "Fragments" or key == "Level" then
        return tostring(math.floor(v)):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
    end
    if v >= 1e6 then return ("%.1fM"):format(v/1e6)
    elseif v >= 1e3 then return ("%.1fK"):format(v/1e3)
    else return tostring(math.floor(v)) end
end

local function fmtComma(n)
    if type(n) ~= "number" then return "?" end
    return tostring(math.floor(math.abs(n))):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end

local function getDistanceTo(p)
    local myC, thC = player.Character, p.Character
    if not myC or not thC then return nil end
    local myR, thR = myC:FindFirstChild("HumanoidRootPart"), thC:FindFirstChild("HumanoidRootPart")
    if not myR or not thR then return nil end
    local ok, mag = pcall(function() return (myR.Position - thR.Position).Magnitude end)
    return ok and math.floor(mag) or nil
end

local function getEquippedItem()
    local char = player.Character
    if not char then return "None", nil end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then
            local toolName = obj.Name
            local level = nil
            pcall(function()
                local charFolder = WS:FindFirstChild("Characters")
                if charFolder then
                    local charNode = charFolder:FindFirstChild(player.Name)
                    if charNode then
                        local toolNode = charNode:FindFirstChild(toolName)
                        if toolNode then
                            local lvObj = toolNode:FindFirstChild("Level")
                            if lvObj and (lvObj:IsA("NumberValue") or lvObj:IsA("IntValue")) then
                                level = lvObj.Value
                            end
                        end
                    end
                end
            end)
            if not level then
                pcall(function()
                    local lvObj = obj:FindFirstChild("Level") or obj:FindFirstChildOfClass("NumberValue") or obj:FindFirstChildOfClass("IntValue")
                    if lvObj then level = lvObj.Value end
                end)
            end
            return toolName, level
        end
    end
    return "None", nil
end

local function getRace(p)
    local raceName, tier
    pcall(function()
        local raceObj = p:FindFirstChild("Data") and p.Data:FindFirstChild("Race")
        if not raceObj then return end
        if raceObj:IsA("ValueBase") and raceObj.Value ~= "" then raceName = tostring(raceObj.Value) end
        for _, n in ipairs({"C","V","Tier","Level","T"}) do
            local c = raceObj:FindFirstChild(n)
            if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then tier = c.Value; break end
        end
    end)
    return raceName, tier
end

local C = {
    BG=Color3.fromRGB(10,10,10), PANEL=Color3.fromRGB(0,0,0),
    CARD=Color3.fromRGB(28,28,28), CARDHOVER=Color3.fromRGB(38,38,38),
    BORDER=Color3.fromRGB(60,60,60), BORDER2=Color3.fromRGB(90,90,90),
    WHITE=Color3.fromRGB(255,255,255), OFFWHITE=Color3.fromRGB(240,240,240),
    MUTED=Color3.fromRGB(190,190,190), DIM=Color3.fromRGB(160,160,160),
    SUCCESS=Color3.fromRGB(160,255,160), WARN=Color3.fromRGB(255,230,100),
    DANGER=Color3.fromRGB(255,140,140), FRIEND=Color3.fromRGB(120,200,255),
    DIST=Color3.fromRGB(200,200,255),
}

local function corner(p, r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8); return c end
local function stroke(p, col, t, tr) local s=Instance.new("UIStroke",p); s.Color=col or C.BORDER; s.Thickness=t or 1; s.Transparency=tr or 0; return s end
local function lbl(parent, props)
    local l=Instance.new("TextLabel",parent)
    l.BackgroundTransparency=1; l.Font=props.font or Enum.Font.GothamBold
    l.TextSize=props.size or 14; l.TextColor3=props.color or C.OFFWHITE
    l.Text=props.text or ""; l.Size=props.sz or UDim2.new(1,0,0,20)
    l.Position=props.pos or UDim2.new(0,0,0,0)
    l.TextXAlignment=props.align or Enum.TextXAlignment.Left
    l.TextYAlignment=props.yalign or Enum.TextYAlignment.Center
    l.TextTruncate=props.truncate or Enum.TextTruncate.None
    l.ZIndex=props.zindex or 2; return l
end
local function toggleBtn(parent, txt, yPos)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,28,0,22); b.Position=UDim2.new(1,-34,0,yPos)
    b.BackgroundColor3=C.CARD; b.BackgroundTransparency=0.2; b.BorderSizePixel=0
    b.Text=txt; b.TextColor3=C.MUTED; b.TextSize=12; b.Font=Enum.Font.GothamBold
    b.AutoButtonColor=false; b.ZIndex=5; corner(b,5); stroke(b,C.BORDER,1,0)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.CARDHOVER,TextColor3=C.WHITE}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.CARD,TextColor3=C.MUTED}):Play() end)
    return b
end

local gui = Instance.new("ScreenGui")
gui.Name="IntegratedStatusHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.DisplayOrder=10; gui.Parent=pg

local BASE_W, BASE_H = 520, 470
local startPos = UDim2.new(0.02,0,0.08,0)

local function makePanel(h, visible)
    local f=Instance.new("Frame"); f.Size=UDim2.new(0,BASE_W,0,h)
    f.Position=startPos; f.BackgroundColor3=C.PANEL; f.BackgroundTransparency=0.06
    f.BorderSizePixel=0; f.ClipsDescendants=true; f.Visible=visible; f.Parent=gui
    corner(f,16); stroke(f,C.BORDER2,1,0); return f
end

local fullPanel = makePanel(BASE_H, true)
local miniPanel = makePanel(68, false)
fullPanel.Active = true

local loadOverlay=Instance.new("Frame",gui)
loadOverlay.Size=fullPanel.Size; loadOverlay.Position=fullPanel.Position
loadOverlay.BackgroundColor3=Color3.fromRGB(8,8,8); loadOverlay.BackgroundTransparency=0.4
loadOverlay.BorderSizePixel=0; loadOverlay.ZIndex=50; corner(loadOverlay,16); stroke(loadOverlay,C.BORDER2,1,0)

lbl(loadOverlay,{sz=UDim2.new(1,0,0,24),pos=UDim2.new(0,0,0,180),size=16,color=C.WHITE,text="Account Info",align=Enum.TextXAlignment.Center,zindex=52})
local loadStepLbl=lbl(loadOverlay,{sz=UDim2.new(1,-60,0,16),pos=UDim2.new(0,30,0,214),font=Enum.Font.Gotham,size=12,color=C.MUTED,text="Initializing...",align=Enum.TextXAlignment.Center,zindex=52})
local loadTrackBg=Instance.new("Frame",loadOverlay); loadTrackBg.Size=UDim2.new(1,-60,0,3); loadTrackBg.Position=UDim2.new(0,30,0,238)
loadTrackBg.BackgroundColor3=C.BORDER; loadTrackBg.BorderSizePixel=0; loadTrackBg.ZIndex=52; corner(loadTrackBg,1)
local loadBarFill=Instance.new("Frame",loadTrackBg); loadBarFill.Size=UDim2.new(0,0,1,0)
loadBarFill.BackgroundColor3=C.WHITE; loadBarFill.BorderSizePixel=0; loadBarFill.ZIndex=53; corner(loadBarFill,1)
local loadPctLbl=lbl(loadOverlay,{sz=UDim2.new(1,-60,0,14),pos=UDim2.new(0,30,0,246),font=Enum.Font.GothamBold,size=10,color=C.DIM,text="0%",align=Enum.TextXAlignment.Right,zindex=52})

local collapseBtn=toggleBtn(fullPanel,"▲",10)
local expandBtn=toggleBtn(miniPanel,"▼",8)

local boostBtn=Instance.new("TextButton",fullPanel)
boostBtn.Size=UDim2.new(0,76,0,22); boostBtn.Position=UDim2.new(1,-116,0,9)
boostBtn.BackgroundColor3=boostFpsActive and C.WHITE or C.CARD; boostBtn.BackgroundTransparency=0.2
boostBtn.BorderSizePixel=0; boostBtn.Text=boostFpsActive and "BOOST ON" or "BOOST OFF"
boostBtn.TextColor3=boostFpsActive and C.BG or C.MUTED; boostBtn.TextSize=10
boostBtn.Font=Enum.Font.GothamBold; boostBtn.AutoButtonColor=false; boostBtn.ZIndex=5
corner(boostBtn,5); stroke(boostBtn,C.BORDER,1,0)
boostBtn.MouseButton1Click:Connect(function()
    boostFpsActive = not boostFpsActive
    if boostFpsActive then
        boostBtn.Text="BOOST ON"; boostBtn.BackgroundColor3=C.WHITE; boostBtn.TextColor3=C.BG
        task.spawn(function() setMapVisibility(true) end)
    else
        boostBtn.Text="BOOST OFF"; boostBtn.BackgroundColor3=C.CARD; boostBtn.TextColor3=C.MUTED
        task.spawn(function() setMapVisibility(false) end)
    end
end)

local isMini = false
local function setView(mini)
    isMini=mini; fullPanel.Visible=not mini; miniPanel.Visible=mini
end
collapseBtn.MouseButton1Click:Connect(function() setView(true) end)
expandBtn.MouseButton1Click:Connect(function() setView(false) end)

local dragging, dragStart, dragStartPos = false, nil, nil
fullPanel.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=inp.Position; dragStartPos=fullPanel.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-dragStart
        local np=UDim2.new(dragStartPos.X.Scale,dragStartPos.X.Offset+d.X,dragStartPos.Y.Scale,dragStartPos.Y.Offset+d.Y)
        fullPanel.Position=np; miniPanel.Position=np
        if loadOverlay and loadOverlay.Parent then loadOverlay.Position=np end
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

local titleBar=Instance.new("Frame",fullPanel); titleBar.Size=UDim2.new(1,0,0,66); titleBar.BackgroundTransparency=1; titleBar.ZIndex=2

local avatar=Instance.new("ImageLabel",titleBar); avatar.Size=UDim2.new(0,46,0,46); avatar.Position=UDim2.new(0,14,0,10)
avatar.BackgroundColor3=C.CARD; avatar.BorderSizePixel=0; avatar.ZIndex=3; corner(avatar,23); stroke(avatar,C.BORDER2,1,0)
task.spawn(function()
    local ok,t=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
    if ok and t then avatar.Image=t end
end)

local charLabel=lbl(titleBar,{sz=UDim2.new(1,-130,0,22),pos=UDim2.new(0,70,0,8),size=17,color=C.WHITE,text="Loading...",zindex=3})
local lvlLabel=lbl(titleBar,{sz=UDim2.new(0,150,0,18),pos=UDim2.new(0,70,0,30),size=14,color=C.MUTED,text="LV. 0",zindex=3})
local onlineDot=Instance.new("Frame",titleBar); onlineDot.Size=UDim2.new(0,7,0,7); onlineDot.Position=UDim2.new(0,70,0,52)
onlineDot.BackgroundColor3=C.WHITE; onlineDot.BorderSizePixel=0; onlineDot.ZIndex=3; corner(onlineDot,4)
lbl(titleBar,{sz=UDim2.new(0,70,0,16),pos=UDim2.new(0,82,0,47),size=11,color=C.DIM,text="ONLINE",zindex=3})
lbl(titleBar,{sz=UDim2.new(0,90,0,16),pos=UDim2.new(1,-118,0,47),size=11,color=C.DIM,text="BLOX FRUITS",align=Enum.TextXAlignment.Right,zindex=3})
local divider=Instance.new("Frame",titleBar); divider.Size=UDim2.new(1,-28,0,1); divider.Position=UDim2.new(0,14,0,65)
divider.BackgroundColor3=C.BORDER; divider.BorderSizePixel=0; divider.ZIndex=2

local content=Instance.new("Frame",fullPanel); content.Size=UDim2.new(1,-28,0,300)
content.Position=UDim2.new(0,14,0,74); content.BackgroundTransparency=1; content.ZIndex=2
lbl(content,{sz=UDim2.new(0,240,0,16),pos=UDim2.new(0,0,0,0),size=11,color=C.MUTED,text="ACCOUNT"})
lbl(content,{sz=UDim2.new(0,240,0,16),pos=UDim2.new(0,252,0,0),size=11,color=C.MUTED,text="COMBAT STATS"})

local function createCard(parent, x, y, label, defVal, isCombat, extraH)
    local h = 40 + (extraH or 0)
    local card=Instance.new("Frame",parent); card.Size=UDim2.new(0,240,0,h); card.Position=UDim2.new(0,x,0,y)
    card.BackgroundColor3=C.CARD; card.BackgroundTransparency=0.1; card.BorderSizePixel=0; card.ZIndex=3
    corner(card,7); stroke(card,C.BORDER,1,0)
    lbl(card,{sz=UDim2.new(0,120,0,16),pos=UDim2.new(0,10,0,4),size=10,color=C.MUTED,text=label:upper(),zindex=4})
    local vLbl=lbl(card,{sz=UDim2.new(1,-20,0,18),pos=UDim2.new(0,10,0,20),size=15,color=C.WHITE,text=defVal,truncate=Enum.TextTruncate.AtEnd,zindex=4})
    if isCombat then
        local tbg=Instance.new("Frame",card); tbg.Size=UDim2.new(1,-20,0,2); tbg.Position=UDim2.new(0,10,1,-5)
        tbg.BackgroundColor3=C.BORDER; tbg.BorderSizePixel=0; tbg.ZIndex=5; corner(tbg,1)
        local fill=Instance.new("Frame",tbg); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=C.WHITE
        fill.BackgroundTransparency=0; fill.BorderSizePixel=0; fill.ZIndex=6; corner(fill,1)
        return {card=card, value=vLbl, barFill=fill}
    end
    return {card=card, value=vLbl}
end

local lX, rX, yB, ROW = 0, 252, 18, 44
local leftCards={
    Beli=createCard(content,lX,yB+0*ROW,"Beli","0"),
    Frag=createCard(content,lX,yB+1*ROW,"Fragments","0"),
    Team=createCard(content,lX,yB+2*ROW,"Team","N/A"),
    Players=createCard(content,lX,yB+3*ROW,"Players","0/0"),
    Time=createCard(content,lX,yB+4*ROW,"Runtime","00:00:00"),
    Equip=createCard(content,lX,yB+5*ROW,"Equipped","None",false,16),
}
local equipLvlLbl = lbl(leftCards.Equip.card,{
    sz=UDim2.new(1,-20,0,14), pos=UDim2.new(0,10,0,36),
    font=Enum.Font.GothamBold, size=11, color=C.WARN,
    text="", truncate=Enum.TextTruncate.AtEnd, zindex=4
})
local rightCards={
    Melee=createCard(content,rX,yB+0*ROW,"Melee","0",true),
    Defense=createCard(content,rX,yB+1*ROW,"Defense","0",true),
    Sword=createCard(content,rX,yB+2*ROW,"Sword","0",true),
    Gun=createCard(content,rX,yB+3*ROW,"Gun","0",true),
    Fruit=createCard(content,rX,yB+4*ROW,"Blox Fruit","0",true),
    Race=createCard(content,rX,yB+5*ROW,"Race","Not Yet V4"),
}
local CARDS_H = yB + 6*ROW + 6 + 16
content.Size = UDim2.new(1,-28,0,CARDS_H)

local pcBar=Instance.new("Frame",fullPanel); pcBar.Size=UDim2.new(1,-28,0,42)
pcBar.Position=UDim2.new(0,14,0,74+CARDS_H+8); pcBar.BackgroundColor3=C.CARD
pcBar.BackgroundTransparency=0.1; pcBar.BorderSizePixel=0; pcBar.ZIndex=2; corner(pcBar,8); stroke(pcBar,C.BORDER,1,0)
lbl(pcBar,{sz=UDim2.new(0,120,0,16),pos=UDim2.new(0,10,0,5),size=11,color=C.MUTED,text="PLAYERS IN SERVER",zindex=3})
local pcCount=lbl(pcBar,{sz=UDim2.new(0,90,0,16),pos=UDim2.new(1,-100,0,5),size=13,color=C.WHITE,text="?/"..MAX_PLAYERS,align=Enum.TextXAlignment.Right,zindex=3})
local barBg=Instance.new("Frame",pcBar); barBg.Size=UDim2.new(1,-20,0,3); barBg.Position=UDim2.new(0,10,1,-8)
barBg.BackgroundColor3=C.BORDER; barBg.BorderSizePixel=0; barBg.ZIndex=3; corner(barBg,2)
local barFill=Instance.new("Frame",barBg); barFill.Size=UDim2.new(0,0,1,0); barFill.BackgroundColor3=C.WHITE
barFill.BorderSizePixel=0; barFill.ZIndex=4; corner(barFill,2)
local fullBadge=Instance.new("TextLabel",pcBar); fullBadge.Size=UDim2.new(0,38,0,16); fullBadge.Position=UDim2.new(1,-48,0,5)
fullBadge.BackgroundColor3=C.WHITE; fullBadge.Text="FULL"; fullBadge.TextColor3=C.BG; fullBadge.TextSize=9
fullBadge.Font=Enum.Font.GothamBold; fullBadge.TextXAlignment=Enum.TextXAlignment.Center
fullBadge.Visible=false; fullBadge.BorderSizePixel=0; fullBadge.ZIndex=4; corner(fullBadge,4)

local playerListContainer=Instance.new("Frame",fullPanel)
playerListContainer.Size=UDim2.new(1,-28,0,0)
playerListContainer.Position=UDim2.new(0,14,0, pcBar.Position.Y.Offset+42+6)
playerListContainer.BackgroundTransparency=1; playerListContainer.BorderSizePixel=0; playerListContainer.ZIndex=2

local playerRows = {}
local ROW_H, ROW_GAP, COL_W = 72, 4, (492-4)/2

local function getTeamColor(p) return p.Team and p.Team.TeamColor.Color or C.DIM end

local function createPlayerRow(p, xOff, yOff)
    local card=Instance.new("Frame",playerListContainer); card.Size=UDim2.new(0,COL_W,0,ROW_H)
    card.Position=UDim2.new(0,xOff,0,yOff); card.BackgroundColor3=C.CARD; card.BackgroundTransparency=0.1
    card.BorderSizePixel=0; card.ZIndex=3; corner(card,7); stroke(card,C.BORDER,1,0)

    local strip=Instance.new("Frame",card); strip.Size=UDim2.new(0,3,1,-8); strip.Position=UDim2.new(0,3,0,4)
    strip.BackgroundColor3=getTeamColor(p); strip.BorderSizePixel=0; strip.ZIndex=5; corner(strip,2)

    local ava=Instance.new("ImageLabel",card); ava.Size=UDim2.new(0,34,0,34); ava.Position=UDim2.new(0,9,0,10)
    ava.BackgroundColor3=C.BORDER; ava.BorderSizePixel=0; ava.ZIndex=4; corner(ava,17); stroke(ava,C.BORDER2,1,0)
    task.spawn(function()
        local ok,t=pcall(function() return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
        if ok and t and ava and ava.Parent then ava.Image=t end
    end)

    local nameW = COL_W - 108
    lbl(card,{sz=UDim2.new(0,nameW,0,17),pos=UDim2.new(0,47,0,4),size=13,color=p==player and C.SUCCESS or C.WHITE,text=p.DisplayName,truncate=Enum.TextTruncate.AtEnd,zindex=4})
    lbl(card,{sz=UDim2.new(0,nameW,0,14),pos=UDim2.new(0,47,0,20),font=Enum.Font.Gotham,size=10,color=C.DIM,text="@"..p.Name,truncate=Enum.TextTruncate.AtEnd,zindex=4})

    local levelLbl=lbl(card,{sz=UDim2.new(0,52,0,16),pos=UDim2.new(1,-104,0,3),size=12,color=C.OFFWHITE,text="LV ??",align=Enum.TextXAlignment.Center,zindex=4})
    local bountyLbl=lbl(card,{sz=UDim2.new(0,52,0,16),pos=UDim2.new(1,-52,0,3),size=12,color=C.WARN,text="??",align=Enum.TextXAlignment.Center,zindex=4})
    lbl(card,{sz=UDim2.new(0,52,0,11),pos=UDim2.new(1,-104,0,19),font=Enum.Font.Gotham,size=8,color=C.DIM,text="LEVEL",align=Enum.TextXAlignment.Center,zindex=4})
    lbl(card,{sz=UDim2.new(0,52,0,11),pos=UDim2.new(1,-52,0,19),font=Enum.Font.Gotham,size=8,color=C.DIM,text="BOUNTY",align=Enum.TextXAlignment.Center,zindex=4})

    local teamLbl=lbl(card,{sz=UDim2.new(0,nameW+52,0,13),pos=UDim2.new(0,47,0,35),font=Enum.Font.Gotham,size=10,color=C.MUTED,text=p.Team and p.Team.Name or "No Team",truncate=Enum.TextTruncate.AtEnd,zindex=4})
    local raceLbl=lbl(card,{sz=UDim2.new(0,nameW,0,13),pos=UDim2.new(0,47,0,49),size=11,color=C.FRIEND,text="??",truncate=Enum.TextTruncate.AtEnd,zindex=4})
    local spawnLbl=lbl(card,{sz=UDim2.new(0,nameW,0,12),pos=UDim2.new(0,47,0,58),font=Enum.Font.Gotham,size=9,color=C.MUTED,text="??",truncate=Enum.TextTruncate.AtEnd,zindex=4})
    local distLbl=lbl(card,{sz=UDim2.new(0,100,0,12),pos=UDim2.new(1,-104,0,58),size=9,color=C.DIST,text=p==player and "--" or "?",align=Enum.TextXAlignment.Right,zindex=4})

    if p==player then
        local b=Instance.new("TextLabel",card); b.Size=UDim2.new(0,26,0,12); b.Position=UDim2.new(0,47+nameW+2,0,5)
        b.BackgroundColor3=C.SUCCESS; b.Text="YOU"; b.TextColor3=C.BG; b.TextSize=7; b.Font=Enum.Font.GothamBold
        b.TextXAlignment=Enum.TextXAlignment.Center; b.BorderSizePixel=0; b.ZIndex=6; corner(b,3)
    else
        task.spawn(function()
            local ok,isFriend=pcall(function() return player:IsFriendsWith(p.UserId) end)
            if ok and isFriend and card and card.Parent then
                local b=Instance.new("TextLabel",card); b.Size=UDim2.new(0,34,0,12); b.Position=UDim2.new(0,47+nameW+2,0,5)
                b.BackgroundColor3=C.FRIEND; b.Text="FRIEND"; b.TextColor3=C.BG; b.TextSize=7
                b.Font=Enum.Font.GothamBold; b.TextXAlignment=Enum.TextXAlignment.Center; b.BorderSizePixel=0; b.ZIndex=6; corner(b,3)
            end
        end)
    end

    playerRows[p.UserId]={row=card,teamStrip=strip,teamLbl=teamLbl,levelLbl=levelLbl,bountyLbl=bountyLbl,raceLbl=raceLbl,spawnLbl=spawnLbl,distLbl=distLbl}
    return card
end

local function refreshPlayerPositions()
    local list = Players:GetPlayers()
    table.sort(list, function(a,b)
        if a==player then return true end
        if b==player then return false end
        return a.Name < b.Name
    end)
    for i, p in ipairs(list) do
        local data = playerRows[p.UserId]
        if data and data.row and data.row.Parent then
            local col = (i-1) % 2
            local row = math.floor((i-1)/2)
            data.row.Position = UDim2.new(0, col==0 and 0 or COL_W+4, 0, row*(ROW_H+ROW_GAP))
        end
    end
    local rowCount = math.ceil(#list/2)
    playerListContainer.Size = UDim2.new(1,-28,0, math.max(rowCount,0)*(ROW_H+ROW_GAP))
    return playerListContainer.Size.Y.Offset
end

local function addPlayerRow(p)
    if playerRows[p.UserId] then return end
    createPlayerRow(p, 0, 0)
    refreshPlayerPositions()
end

local function removePlayerRow(p)
    local data = playerRows[p.UserId]
    if not data then return end
    if data.row and data.row.Parent then data.row:Destroy() end
    playerRows[p.UserId] = nil
    refreshPlayerPositions()
end

local function buildInitialList()
    for uid, data in pairs(playerRows) do
        if data.row and data.row.Parent then data.row:Destroy() end
    end
    playerRows = {}
    local list = Players:GetPlayers()
    table.sort(list, function(a,b)
        if a==player then return true end
        if b==player then return false end
        return a.Name < b.Name
    end)
    for i, p in ipairs(list) do
        local col=(i-1)%2; local row=math.floor((i-1)/2)
        createPlayerRow(p, col==0 and 0 or COL_W+4, row*(ROW_H+ROW_GAP))
    end
    local rowCount = math.ceil(#list/2)
    playerListContainer.Size = UDim2.new(1,-28,0, math.max(rowCount,0)*(ROW_H+ROW_GAP))
end

local function updatePlayerRow(p)
    local data = playerRows[p.UserId]
    if not data then return end
    data.teamLbl.Text = p.Team and p.Team.Name or "No Team"
    data.teamStrip.BackgroundColor3 = getTeamColor(p)
    local lv = getStat("Level", p)
    data.levelLbl.Text = lv ~= nil and ("LV "..formatVal(lv,"Level")) or "LV ??"
    local bounty = getStat("Bounty", p)
    data.bountyLbl.Text = bounty ~= nil and formatVal(bounty) or "??"
    local sp = getStat("SpawnPoint", p)
    data.spawnLbl.Text = sp ~= nil and tostring(sp) or "??"
    local rn, rt = getRace(p)
    data.raceLbl.Text = rn and (rt and rn.."["..rt.."]" or rn) or "Not V4"
    if p ~= player then
        local dist = getDistanceTo(p)
        data.distLbl.Text = dist ~= nil and (fmtComma(dist).." studs") or "?"
    end
end

local Teams; pcall(function() Teams=game:GetService("Teams") end)

local teamsRow=Instance.new("Frame",fullPanel); teamsRow.Size=UDim2.new(1,-28,0,50)
teamsRow.BackgroundColor3=C.CARD; teamsRow.BackgroundTransparency=0.1; teamsRow.BorderSizePixel=0
teamsRow.Visible=false; teamsRow.ZIndex=2; corner(teamsRow,8); stroke(teamsRow,C.BORDER,1,0)
lbl(teamsRow,{sz=UDim2.new(0,60,0,16),pos=UDim2.new(0,10,0,4),size=11,color=C.MUTED,text="TEAMS",zindex=3})
local chipHolder=Instance.new("Frame",teamsRow); chipHolder.Size=UDim2.new(1,-74,1,-8)
chipHolder.Position=UDim2.new(0,68,0,4); chipHolder.BackgroundTransparency=1; chipHolder.BorderSizePixel=0; chipHolder.ZIndex=3
local chipList=Instance.new("UIListLayout",chipHolder); chipList.FillDirection=Enum.FillDirection.Horizontal
chipList.SortOrder=Enum.SortOrder.LayoutOrder; chipList.Padding=UDim.new(0,4); chipList.VerticalAlignment=Enum.VerticalAlignment.Center
local teamChips = {}

local function repositionTeamsAndBottom()
    local plY = playerListContainer.Position.Y.Offset
    local plH = playerListContainer.Size.Y.Offset
    local teamsY = plY + plH + 6
    teamsRow.Position = UDim2.new(0,14,0,teamsY)
    local teamsH = teamsRow.Visible and 50 or 0
    local bottomY = teamsY + teamsH + 6
    if fullPanel:FindFirstChild("BottomBarRef") then
        fullPanel.BottomBarRef.Position = UDim2.new(0,14,0,bottomY)
    end
    fullPanel.Size = UDim2.new(0, fullPanel.AbsoluteSize.X, 0, math.max(BASE_H, bottomY+42+8))
    if loadOverlay and loadOverlay.Parent then loadOverlay.Size = fullPanel.Size end
end

local function rebuildTeamChips()
    for _, c in pairs(teamChips) do if c.frame then c.frame:Destroy() end end
    teamChips = {}
    if not Teams then teamsRow.Visible=false; return end
    local list = Teams:GetTeams()
    if #list==0 then teamsRow.Visible=false; return end
    teamsRow.Visible=true
    local chipW = math.clamp(math.floor((480-(#list-1)*4)/math.max(#list,1)),36,100)
    for i, team in ipairs(list) do
        local chip=Instance.new("Frame",chipHolder); chip.Size=UDim2.new(0,chipW,1,-2)
        chip.BackgroundColor3=C.BORDER; chip.BackgroundTransparency=0.2; chip.BorderSizePixel=0
        chip.LayoutOrder=i; chip.ZIndex=4; corner(chip,5); stroke(chip,C.BORDER2,1,0)
        local strip2=Instance.new("Frame",chip); strip2.Size=UDim2.new(1,0,0,2)
        strip2.BackgroundColor3=C.WHITE; strip2.BorderSizePixel=0; strip2.ZIndex=5; corner(strip2,5)
        lbl(chip,{sz=UDim2.new(1,0,0,16),pos=UDim2.new(0,0,0,4),size=11,color=C.MUTED,text=#team.Name>8 and team.Name:sub(1,7).."…" or team.Name,align=Enum.TextXAlignment.Center,zindex=5})
        local cntLbl=lbl(chip,{sz=UDim2.new(1,0,0,18),pos=UDim2.new(0,0,0,20),size=14,color=C.WHITE,text="0",align=Enum.TextXAlignment.Center,zindex=5})
        teamChips[team.Name]={frame=chip,cntLbl=cntLbl,team=team}
    end
end

local function updatePlayerCount()
    local list = Players:GetPlayers()
    local total, ratio = #list, math.clamp(#list/MAX_PLAYERS,0,1)
    pcCount.Text = total.." / "..MAX_PLAYERS
    if ratio>=1 then
        barFill.BackgroundColor3=C.DANGER; pcCount.TextColor3=C.DANGER
        pcCount.Position=UDim2.new(1,-142,0,5); fullBadge.Visible=true
    elseif ratio>=0.75 then
        barFill.BackgroundColor3=C.WARN; pcCount.TextColor3=C.WARN
        pcCount.Position=UDim2.new(1,-100,0,5); fullBadge.Visible=false
    else
        barFill.BackgroundColor3=C.WHITE; pcCount.TextColor3=C.WHITE
        pcCount.Position=UDim2.new(1,-100,0,5); fullBadge.Visible=false
    end
    barFill.Size=UDim2.new(ratio,0,1,0)
    if Teams then
        for _, c in pairs(teamChips) do
            if c.team then
                local cnt=0
                for _, p in ipairs(list) do if p.Team==c.team then cnt+=1 end end
                c.cntLbl.Text=tostring(cnt)
                c.frame.BackgroundTransparency = player.Team==c.team and 0 or 0.2
            end
        end
    end
end

local bottomBar=Instance.new("Frame",fullPanel); bottomBar.Name="BottomBarRef"
bottomBar.Size=UDim2.new(1,-28,0,38); bottomBar.BackgroundTransparency=1; bottomBar.ZIndex=2
local fpsLabel=lbl(bottomBar,{sz=UDim2.new(0,110,1,0),pos=UDim2.new(0,0,0,0),size=15,color=C.OFFWHITE,text="FPS 0"})
local pingLabel=lbl(bottomBar,{sz=UDim2.new(0,130,1,0),pos=UDim2.new(0,114,0,0),size=15,color=C.OFFWHITE,text="PING 0 ms"})
local timeLabel=lbl(bottomBar,{sz=UDim2.new(0,120,1,0),pos=UDim2.new(0,248,0,0),size=15,color=C.MUTED,text="00:00:00"})

local capGroup=Instance.new("Frame",bottomBar); capGroup.Size=UDim2.new(0,148,1,0)
capGroup.Position=UDim2.new(1,-148,0,0); capGroup.BackgroundTransparency=1; capGroup.ZIndex=3
lbl(capGroup,{sz=UDim2.new(0,34,1,0),size=9,color=C.DIM,text="FPSCAP",zindex=5})
local capBox=Instance.new("TextBox",capGroup); capBox.Size=UDim2.new(0,50,1,-8); capBox.Position=UDim2.new(0,36,0,4)
capBox.BackgroundColor3=C.CARD; capBox.BackgroundTransparency=0.1; capBox.BorderSizePixel=0
capBox.Font=Enum.Font.Gotham; capBox.TextSize=13; capBox.TextColor3=C.WHITE; capBox.Text=""
capBox.PlaceholderText=tostring(FPS_CAP); capBox.PlaceholderColor3=C.DIM; capBox.ZIndex=4; corner(capBox,5); stroke(capBox,C.BORDER,1,0)
local setCapBtn=Instance.new("TextButton",capGroup); setCapBtn.Size=UDim2.new(0,46,1,-8); setCapBtn.Position=UDim2.new(0,90,0,4)
setCapBtn.BackgroundColor3=C.WHITE; setCapBtn.BorderSizePixel=0; setCapBtn.Font=Enum.Font.GothamBold
setCapBtn.TextSize=12; setCapBtn.TextColor3=C.BG; setCapBtn.Text="SET"; setCapBtn.ZIndex=4; corner(setCapBtn,5)
setCapBtn.MouseEnter:Connect(function() TweenService:Create(setCapBtn,TweenInfo.new(0.15),{BackgroundColor3=C.OFFWHITE}):Play() end)
setCapBtn.MouseLeave:Connect(function() TweenService:Create(setCapBtn,TweenInfo.new(0.15),{BackgroundColor3=C.WHITE}):Play() end)
local function applyFpsCap()
    local num=tonumber(capBox.Text)
    if num and num>0 then
        pcall(function() settings().Rendering.FrameRateManager.MaxFrameRate=num end)
        pcall(function() setfpscap(num) end)
        FPS_CAP=num; capBox.Text=""
    end
end
setCapBtn.MouseButton1Click:Connect(applyFpsCap)
capBox.FocusLost:Connect(function(enter) if enter then applyFpsCap() end end)

local miniAvatar=Instance.new("ImageLabel",miniPanel); miniAvatar.Size=UDim2.new(0,40,0,40)
miniAvatar.Position=UDim2.new(0,14,0,14); miniAvatar.BackgroundColor3=C.CARD
miniAvatar.BorderSizePixel=0; miniAvatar.ZIndex=3; corner(miniAvatar,20); stroke(miniAvatar,C.BORDER2,1,0)
task.spawn(function()
    local ok,t=pcall(function() return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
    if ok and t then miniAvatar.Image=t end
end)
local miniName=lbl(miniPanel,{sz=UDim2.new(0,170,0,20),pos=UDim2.new(0,64,0,12),size=15,color=C.WHITE,text="Loading...",zindex=3})
local miniLvl=lbl(miniPanel,{sz=UDim2.new(0,110,0,16),pos=UDim2.new(0,64,0,32),size=12,color=C.DIM,text="LV. 0",zindex=3})
local miniStats={}
for i, pair in ipairs({{"Level","LV"},{"Beli","G"},{"Fragments","◈"}}) do
    local key, icon = pair[1], pair[2]
    local x=244+(i-1)*94
    lbl(miniPanel,{sz=UDim2.new(0,22,0,16),pos=UDim2.new(0,x,0,10),size=10,color=C.DIM,text=icon,align=Enum.TextXAlignment.Center,zindex=3})
    miniStats[key]=lbl(miniPanel,{sz=UDim2.new(0,68,0,18),pos=UDim2.new(0,x+24,0,8),size=14,color=C.WHITE,text="...",truncate=Enum.TextTruncate.AtEnd,zindex=3})
    lbl(miniPanel,{sz=UDim2.new(0,72,0,14),pos=UDim2.new(0,x+24,0,28),size=9,color=C.DIM,text=key:upper(),zindex=3})
end

local blackoutFrame=Instance.new("Frame",gui); blackoutFrame.Size=UDim2.new(1,0,1,0)
blackoutFrame.BackgroundColor3=Color3.fromRGB(0,0,0); blackoutFrame.BackgroundTransparency=0
blackoutFrame.BorderSizePixel=0; blackoutFrame.ZIndex=1; blackoutFrame.Visible=false
local restoreBtn=Instance.new("TextButton",gui); restoreBtn.Size=UDim2.new(0,96,0,34)
restoreBtn.AnchorPoint=Vector2.new(0.5,1); restoreBtn.Position=UDim2.new(0.5,0,1,-30)
restoreBtn.BackgroundColor3=C.WHITE; restoreBtn.BorderSizePixel=0; restoreBtn.Text="RESTORE"
restoreBtn.TextColor3=C.BG; restoreBtn.Font=Enum.Font.GothamBold; restoreBtn.TextSize=13
restoreBtn.AutoButtonColor=false; restoreBtn.Visible=false; restoreBtn.ZIndex=51; corner(restoreBtn,6)
local blackoutActive=false
local function setBlackout(state)
    blackoutActive=state; blackoutFrame.Visible=state; restoreBtn.Visible=state
end
if config["White Screen"] then setBlackout(true) end
restoreBtn.MouseButton1Click:Connect(function() setBlackout(false) end)

local selfHL
local function applyHighlight(char)
    if selfHL and selfHL.Parent then selfHL:Destroy() end
    selfHL=nil; if not char then return end
    local hl=Instance.new("Highlight"); hl.Name="ESP_SelfHL"
    hl.FillColor=Color3.fromRGB(255,255,255); hl.OutlineColor=Color3.fromRGB(0,0,0)
    hl.FillTransparency=0.5; hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=char; hl.Parent=char; selfHL=hl
end
if player.Character then task.delay(0.5,function() applyHighlight(player.Character) end) end
player.CharacterAdded:Connect(function(char) task.wait(0.5); applyHighlight(char) end)

local fps, frameCount, lastFpsTime = 0, 0, tick()
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now-lastFpsTime >= 0.5 then
        fps = math.floor(frameCount/(now-lastFpsTime))
        frameCount, lastFpsTime = 0, now
    end
end)

local function getPing()
    local ok,p=pcall(function() return StatsService.Network.ServerStatsItem["Data Ping"] end)
    return ok and type(p)=="number" and math.floor(p) or math.floor(player:GetNetworkPing()*1000)
end

local scriptStart = tick()

local function updateSelf()
    local disp, name = player.DisplayName, player.Name
    charLabel.Text = disp~=name and disp.." (@"..name..")" or name
    miniName.Text = charLabel.Text
    local lv = getStat("Level")
    local lvStr = "LV. "..formatVal(lv,"Level")
    lvlLabel.Text = lvStr; miniLvl.Text = lvStr
    leftCards.Beli.value.Text = formatVal(getStat("Beli"),"Beli")
    leftCards.Frag.value.Text = formatVal(getStat("Fragments"),"Fragments")
    leftCards.Team.value.Text = player.Team and player.Team.Name or "N/A"
    leftCards.Players.value.Text = #Players:GetPlayers().." / "..MAX_PLAYERS
    local e = tick()-scriptStart
    local ts = ("%02d:%02d:%02d"):format(math.floor(e/3600),math.floor(e%3600/60),math.floor(e%60))
    leftCards.Time.value.Text = ts; timeLabel.Text = ts
    local equipName, equipLv = getEquippedItem()
    leftCards.Equip.value.Text = equipName
    if equipLv ~= nil then
        equipLvlLbl.Text = "LV "..fmtComma(equipLv)
        equipLvlLbl.TextColor3 = C.WARN
    else
        equipLvlLbl.Text = equipName ~= "None" and "Level N/A" or ""
        equipLvlLbl.TextColor3 = C.DIM
    end
    for n2, card in pairs(rightCards) do
        if n2=="Race" then
            local rn,rt=getRace(player)
            card.value.Text = rn and (rt and rn.."["..rt.."]" or rn.." [Not Yet V4]") or "Not Yet V4"
        else
            local val = getStat(n2=="Fruit" and "Blox Fruit" or n2)
            card.value.Text = formatVal(val)
            if card.barFill then card.barFill.Size=UDim2.new(math.clamp(tonumber(val) and tonumber(val)/COMBAT_CAP or 0,0,1),0,1,0) end
        end
    end
    fpsLabel.Text = "FPS "..fps
    local ping = getPing()
    pingLabel.Text = "PING "..ping.." ms"
    pingLabel.TextColor3 = ping<80 and C.SUCCESS or ping<150 and C.WARN or C.DANGER
    if miniStats.Level then miniStats.Level.Text=formatVal(lv,"Level") end
    if miniStats.Beli then miniStats.Beli.Text=formatVal(getStat("Beli"),"Beli") end
    if miniStats.Fragments then miniStats.Fragments.Text=formatVal(getStat("Fragments"),"Fragments") end
    local curCap=0; pcall(function() curCap=settings().Rendering.FrameRateManager.MaxFrameRate end)
    capBox.PlaceholderText = curCap>0 and tostring(curCap) or "∞"
    updatePlayerCount()
end

Players.PlayerAdded:Connect(function(p)
    task.wait(0.3)
    addPlayerRow(p)
    repositionTeamsAndBottom()
    updatePlayerCount()
end)
Players.PlayerRemoving:Connect(function(p)
    removePlayerRow(p)
    repositionTeamsAndBottom()
    updatePlayerCount()
end)

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode==Enum.KeyCode.B then setBlackout(not blackoutActive) end
    if inp.KeyCode==Enum.KeyCode.RightControl then setView(not isMini) end
end)

local fadeTargets = {
    avatar, charLabel, lvlLabel, onlineDot,
    leftCards.Beli.card, leftCards.Frag.card, leftCards.Team.card,
    leftCards.Players.card, leftCards.Time.card, leftCards.Equip.card,
    rightCards.Melee.card, rightCards.Defense.card, rightCards.Sword.card,
    rightCards.Gun.card, rightCards.Fruit.card, rightCards.Race.card,
    pcBar, bottomBar,
}

local origTrans = {}
local function snapshotTrans(obj)
    local snap={bg=obj.BackgroundTransparency, children={}}
    for _, c in ipairs(obj:GetDescendants()) do
        local cd={}
        if c:IsA("Frame") or c:IsA("ImageLabel") or c:IsA("TextLabel") or c:IsA("TextButton") then cd.bg=c.BackgroundTransparency end
        if c:IsA("TextLabel") or c:IsA("TextButton") then cd.text=c.TextTransparency end
        if c:IsA("ImageLabel") then cd.img=c.ImageTransparency end
        if c:IsA("UIStroke") then cd.stroke=c.Transparency end
        snap.children[c]=cd
    end
    return snap
end

local function hideElement(obj)
    obj.BackgroundTransparency=1
    for _, c in ipairs(obj:GetDescendants()) do
        if c:IsA("Frame") or c:IsA("ImageLabel") or c:IsA("TextLabel") or c:IsA("TextButton") then c.BackgroundTransparency=1 end
        if c:IsA("TextLabel") or c:IsA("TextButton") then c.TextTransparency=1 end
        if c:IsA("ImageLabel") then c.ImageTransparency=1 end
        if c:IsA("UIStroke") then c.Transparency=1 end
    end
end

for _, obj in ipairs(fadeTargets) do origTrans[obj]=snapshotTrans(obj); hideElement(obj) end

local function fadeIn(obj)
    local snap=origTrans[obj]; if not snap then return end
    task.spawn(function()
        local s=tick(); local DUR=0.35
        while true do
            local r=math.min((tick()-s)/DUR,1); local ease=r*r*(3-2*r); local inv=1-ease
            if obj and obj.Parent then obj.BackgroundTransparency=snap.bg+(1-snap.bg)*inv end
            for c, cd in pairs(snap.children) do
                if c and c.Parent then
                    if cd.bg    ~=nil then c.BackgroundTransparency=cd.bg+(1-cd.bg)*inv end
                    if cd.text  ~=nil then c.TextTransparency=cd.text+(1-cd.text)*inv end
                    if cd.img   ~=nil then c.ImageTransparency=cd.img+(1-cd.img)*inv end
                    if cd.stroke~=nil then c.Transparency=cd.stroke+(1-cd.stroke)*inv end
                end
            end
            if r>=1 then break end
            RunService.Heartbeat:Wait()
        end
    end)
end

local LOAD_ELEMENTS={
    {"Loading account...","avatar"},{"Loading username...","charLabel"},{"Loading level...","lvlLabel"},
    {"Loading status...","onlineDot"},{"Loading beli...","leftCards.Beli"},{"Loading fragments...","leftCards.Frag"},
    {"Loading team...","leftCards.Team"},{"Loading players...","leftCards.Players"},{"Loading runtime...","leftCards.Time"},
    {"Loading equipped...","leftCards.Equip"},{"Loading melee...","rightCards.Melee"},{"Loading defense...","rightCards.Defense"},
    {"Loading sword...","rightCards.Sword"},{"Loading gun...","rightCards.Gun"},{"Loading blox fruit...","rightCards.Fruit"},
    {"Loading race...","rightCards.Race"},{"Loading player bar...","pcBar"},{"Loading bottom bar...","bottomBar"},
}

local fadeTargetMap={
    avatar=avatar, charLabel=charLabel, lvlLabel=lvlLabel, onlineDot=onlineDot,
    ["leftCards.Beli"]=leftCards.Beli.card, ["leftCards.Frag"]=leftCards.Frag.card,
    ["leftCards.Team"]=leftCards.Team.card, ["leftCards.Players"]=leftCards.Players.card,
    ["leftCards.Time"]=leftCards.Time.card, ["leftCards.Equip"]=leftCards.Equip.card,
    ["rightCards.Melee"]=rightCards.Melee.card, ["rightCards.Defense"]=rightCards.Defense.card,
    ["rightCards.Sword"]=rightCards.Sword.card, ["rightCards.Gun"]=rightCards.Gun.card,
    ["rightCards.Fruit"]=rightCards.Fruit.card, ["rightCards.Race"]=rightCards.Race.card,
    pcBar=pcBar, bottomBar=bottomBar,
}

task.spawn(function()
    task.wait(1)
    rebuildTeamChips()
    buildInitialList()
    repositionTeamsAndBottom()
    updatePlayerCount()
end)
if Teams then
    Teams.ChildAdded:Connect(function() task.wait(0.1); rebuildTeamChips(); repositionTeamsAndBottom(); updatePlayerCount() end)
    Teams.ChildRemoved:Connect(function() task.wait(0.1); rebuildTeamChips(); repositionTeamsAndBottom(); updatePlayerCount() end)
end

task.spawn(function()
    updateSelf()
    local TOTAL = #LOAD_ELEMENTS
    local totalDur = TOTAL * 0.3
    local done = false

    task.spawn(function()
        for _, item in ipairs(LOAD_ELEMENTS) do
            loadStepLbl.Text = item[1]
            local obj = fadeTargetMap[item[2]]
            if obj then fadeIn(obj) end
            local s2=tick(); repeat RunService.Heartbeat:Wait() until tick()-s2 >= totalDur/TOTAL
        end
        done = true
    end)

    local s = tick()
    while not done do
        local r = math.min((tick()-s)/totalDur,1); local ease=r*r*(3-2*r)
        loadBarFill.Size=UDim2.new(ease,0,1,0); loadPctLbl.Text=math.floor(ease*100).."%"
        loadOverlay.BackgroundTransparency=0.4+0.2*ease
        RunService.Heartbeat:Wait()
    end
    loadBarFill.Size=UDim2.new(1,0,1,0); loadPctLbl.Text="100%"

    local startAlpha=loadOverlay.BackgroundTransparency; local s2=tick()
    while true do
        local r=math.min((tick()-s2)/0.5,1); local ease=r*r*(3-2*r); local a=startAlpha+(1-startAlpha)*ease
        loadOverlay.BackgroundTransparency=a
        for _, c in ipairs(loadOverlay:GetDescendants()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") then c.TextTransparency=ease
            elseif c:IsA("ImageLabel") then c.ImageTransparency=ease; c.BackgroundTransparency=a
            elseif c:IsA("Frame") then c.BackgroundTransparency=a
            elseif c:IsA("UIStroke") then c.Transparency=ease end
        end
        if r>=1 then break end
        RunService.Heartbeat:Wait()
    end
    loadOverlay:Destroy()

    task.spawn(function()
        while true do updateSelf(); task.wait(0.1) end
    end)
    task.spawn(function()
        while true do
            for _, p in ipairs(Players:GetPlayers()) do updatePlayerRow(p) end
            task.wait(0.25)
        end
    end)
end)
