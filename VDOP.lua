local l = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local w = l:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "x2zu on top",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "x2zu"
    }
})

local rs = game:GetService("RunService")
local rps = game:GetService("ReplicatedStorage")
local pl = game:GetService("Players")
local tm = game:GetService("Teams")
local lp = pl.LocalPlayer

local at = rps:WaitForChild("Remotes"):WaitForChild("Attacks")
local ba = at:WaitForChild("BasicAttack")
local cr = rps:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent")
local hr = rps:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("HookEvent")
local gr = rps:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("RepairEvent")
local er = rps:WaitForChild("Remotes"):WaitForChild("Exit"):WaitForChild("LeverEvent")

local s = {
    aa = false,
    af = false,
    ar = false,
    cg = nil,
    ce = false,
    cr = false,
    kt = nil,
    kla = false,
    etf = false,
    tg = 5,
    lat = os.time(),
    isg = false
}

local function gpt(p)
    return p and p.Team
end

local function is(p)
    local t = gpt(p)
    return t and string.lower(t.Name) == "survivors"
end

local function iss(p)
    local t = gpt(p)
    return t and string.lower(t.Name) == "spectator"
end

local function isk(p)
    local t = gpt(p)
    return t and string.lower(t.Name) == "killer"
end

local function fg()
    local g = {}
    
    for _, o in pairs(workspace:GetDescendants()) do
        if o.Name == "Generator" and o:IsA("Model") then
            table.insert(g, o)
        end
    end
    
    local m = workspace:FindFirstChild("Map")
    if m then
        local r = m:FindFirstChild("Rooftop")
        if r then
            for _, o in pairs(r:GetDescendants()) do
                if o.Name == "Generator" and o:IsA("Model") then
                    table.insert(g, o)
                end
            end
        end
    end
    
    return g
end

local function hgp(gm)
    if not gm then 
        return false 
    end
    
    for i = 1, 4 do
        local pn = "GeneratorPoint" .. i
        local p = gm:FindFirstChild(pn)
        if p and p:IsA("Part") then
            return true
        end
    end
    
    return false
end

local function crp(gm)
    if not gm then return 0 end
    
    local sc, rp = pcall(function()
        return gm:GetAttribute("RepairProgress") or 0
    end)
    
    if sc and rp then
        return rp
    end
    
    local rpv = gm:FindFirstChild("RepairProgress")
    if rpv and rpv:IsA("NumberValue") then
        return rpv.Value
    end
    
    return 0
end

local function ccg()
    local g = fg()
    local c = 0
    
    for _, gen in ipairs(g) do
        local p = crp(gen)
        if p >= 100 then
            c = c + 1
        end
    end
    
    return c
end

local function fgp(gm)
    if not gm then return nil end
    
    for i = 1, 4 do
        local pn = "GeneratorPoint" .. i
        local p = gm:FindFirstChild(pn)
        if p and p:IsA("Part") then
            return p
        end
    end
    
    return nil
end

local function cdtg(gm)
    if not gm or not lp.Character or not lp.Character.PrimaryPart then
        return math.huge
    end
    
    local gp = fgp(gm)
    if not gp then
        return math.huge
    end
    
    local pp = lp.Character.PrimaryPart.Position
    local gpp = gp.Position
    
    return (pp - gpp).Magnitude
end

local function ttg(gm)
    local gp = fgp(gm)
    if gp and lp.Character and lp.Character.PrimaryPart then
        local cf = gp.CFrame
        lp.Character:SetPrimaryPartCFrame(cf + cf.LookVector * -3)
        
        task.wait(0.5)
        
        local d = cdtg(gm)
        
        if d <= 10 then
            s.cg = gm
            s.lat = os.time()
            return true
        else
            lp.Character:SetPrimaryPartCFrame(cf + cf.LookVector * -2)
            task.wait(0.5)
            
            local nd = cdtg(gm)
            
            if nd <= 10 then
                s.cg = gm
                s.lat = os.time()
                return true
            else
                s.cg = nil
                return false
            end
        end
    else
        s.cg = nil
        return false
    end
end

local function ccgs()
    if not s.cg then
        return false
    end
    
    if not s.cg.Parent then
        s.cg = nil
        return false
    end
    
    local hp = hgp(s.cg)
    if not hp then
        s.cg = nil
        return false
    end
    
    local p = crp(s.cg)
    if p >= 100 then
        s.cg = nil
        return false
    end
    
    return true
end

local function rg(gm)
    if not gm then 
        return false 
    end
    
    local gp = fgp(gm)
    if not gp then
        return false
    end
    
    local sc1, r1 = pcall(function()
        local a = { gp, true }
        gr:FireServer(unpack(a))
        s.lat = os.time()
        return true
    end)
    
    if not sc1 then
        local sc2, r2 = pcall(function()
            local a = { gp }
            gr:FireServer(unpack(a))
            s.lat = os.time()
            return true
        end)
        
        if not sc2 then
            return false
        end
    end
    
    return true
end

local function cr()
    if s.cg then
        local gp = fgp(s.cg)
        if gp then
            local a = { gp, false }
            gr:FireServer(unpack(a))
            s.cg = nil
            s.cr = true
            return true
        end
    end
    return false
end

local function conr()
    local st = os.time()
    local mrt = 120
    local trc = 0
    local mtr = 3
    
    while s.ar and s.cg and not s.cr do
        local sc, em = pcall(function()
            local d = cdtg(s.cg)
            if d > 10 then
                if trc < mtr then
                    trc = trc + 1
                    local ts = ttg(s.cg)
                    if not ts then
                        s.cg = nil
                        return
                    end
                else
                    s.cg = nil
                    return
                end
            else
                trc = 0
            end
            
            if not ccgs() then
                s.cg = nil
                return
            end
            
            if os.time() - st > mrt then
                s.cg = nil
                return
            end
            
            local rs = rg(s.cg)
            if not rs then
                s.cg = nil
                return
            end
            
            local cp = crp(s.cg)
            
            if cp >= 100 then
                s.cg = nil
                return
            end
        end)
        
        if not sc then
            s.cg = nil
            break
        end
        
        task.wait(0.3)
    end
    
    s.cr = false
end

local function fel()
    local m = workspace:FindFirstChild("Map")
    if not m then return nil end
    
    local r = m:FindFirstChild("Rooftop")
    if r then
        local g = r:FindFirstChild("Gate")
        if g then
            local el = g:FindFirstChild("ExitLever")
            if el then
                local t = el:FindFirstChild("Tp")
                local mn = el:FindFirstChild("Main")
                return t, mn
            end
        end
    end
    
    local g = m:FindFirstChild("Gate")
    if g then
        local el = g:FindFirstChild("ExitLever")
        if el then
            local t = el:FindFirstChild("Tp")
            local mn = el:FindFirstChild("Main")
            return t, mn
        end
    end
    
    return nil, nil
end

local function tte()
    local t, mn = fel()
    if t and lp.Character and lp.Character.PrimaryPart then
        lp.Character:SetPrimaryPartCFrame(t.CFrame)
        s.lat = os.time()
        return true, mn
    end
    return false, nil
end

local function ael()
    local t, mn = fel()
    if mn then
        local a = { mn, true }
        er:FireServer(unpack(a))
        s.lat = os.time()
        return true
    end
    return false
end

local function ttgc()
    if lp.Character and lp.Character.PrimaryPart then
        local m = workspace:FindFirstChild("Map")
        if not m then 
            return false 
        end
        
        local gm = nil
        
        local r = m:FindFirstChild("Rooftop")
        if r then
            gm = r:FindFirstChild("Gate")
        end
        
        if not gm then
            gm = m:FindFirstChild("Gate")
        end
        
        if gm then
            local gp = nil
            for _, c in pairs(gm:GetDescendants()) do
                if c:IsA("Part") then
                    gp = c
                    break
                end
            end
            
            if gp then
                local gpos = gp.Position
                lp.Character:SetPrimaryPartCFrame(CFrame.new(gpos + Vector3.new(-10, 20, -20)))
                s.lat = os.time()
                return true
            end
        end
    end
    return false
end

local function oeg()
    if s.ce then
        return false
    end
    
    s.ce = true
    
    local sc = false
    
    local ts, mp = tte()
    if ts then
        task.wait(0.5)
        
        local ls = ael()
        if ls then
            task.wait(0.5)
            
            local gs = ttgc()
            if gs then
                sc = true
            else
                sc = true
            end
        end
    end
    
    s.ce = false
    return sc
end

local function cph(pn)
    local pm = workspace:FindFirstChild(pn)
    if not pm then
        return {health = 0, maxHealth = 0, found = false}
    end
    
    local h = pm:FindFirstChildOfClass("Humanoid")
    if not h then
        return {health = 0, maxHealth = 0, found = true, hasHumanoid = false}
    end
    
    return {
        health = h.Health,
        maxHealth = h.MaxHealth,
        found = true,
        hasHumanoid = true,
        lowHealth = (h.Health <= 20)
    }
end

local function tbp(tp)
    if not tp or not tp.Character or not tp.Character.PrimaryPart then
        return false
    end
    
    if lp.Character and lp.Character.PrimaryPart then
        local bp = tp.Character.PrimaryPart.CFrame * CFrame.new(0, 0, 2)
        lp.Character:SetPrimaryPartCFrame(bp)
        s.lat = os.time()
        return true
    end
    return false
end

local function fhm()
    local sc, r = pcall(function()
        local m = workspace:FindFirstChild("Map")
        if not m then
            return nil
        end
        
        local r = m:FindFirstChild("Rooftop")
        if r then
            local h = r:FindFirstChild("Hook")
            if h then
                return h
            end
        end
        
        local h = m:FindFirstChild("Hook")
        if h then
            return h
        end
        
        return nil
    end)
    
    if not sc then
        return nil
    end
    
    return r
end

local function fhp()
    local sc, r = pcall(function()
        local hm = fhm()
        if not hm then 
            return nil 
        end
        
        for _, c in pairs(hm:GetChildren()) do
            if c:IsA("Part") then
                return c
            end
        end
        
        return nil
    end)
    
    if not sc then
        return nil
    end
    
    return r
end

local function tth()
    local sc, r = pcall(function()
        local hp = fhp()
        if hp and lp.Character and lp.Character.PrimaryPart then
            lp.Character:SetPrimaryPartCFrame(hp.CFrame * CFrame.new(0, 0, -3))
            s.lat = os.time()
            return true
        else
            return false
        end
    end)
    
    if not sc then
        return false
    end
    
    return r
end

local function she()
    local sc, r = pcall(function()
        local hp = fhp()
        if hp then
            local a = { hp }
            for i = 1, 20 do
                hr:FireServer(unpack(a))
                task.wait(0.02)
            end
            return true
        else
            return false
        end
    end)
    
    if not sc then
        return false
    end
    
    return r
end

local function tcp(p)
    local sc, r = pcall(function()
        if not p or not p.Character then return false end
        
        local ca = { p.Character }
        cr:FireServer(unpack(ca))
        task.wait(1.5)
        s.lat = os.time()
        return true
    end)
    
    if not sc then
        return false
    end
    
    return r
end

local function fbg()
    local g = fg()
    local bg = nil
    
    for _, gen in ipairs(g) do
        if not hgp(gen) then
            continue
        end
        
        local p = crp(gen)
        if p >= 100 then
            continue
        end
        
        if not bg then
            bg = gen
        end
    end
    
    return bg
end

local function ar()
    local sc = 0
    
    while s.ar and is(lp) do
        local sc, em = pcall(function()
            s.lat = os.time()
            
            if os.time() - s.lat > 30 then
                s.cg = nil
                sc = sc + 1
                
                if sc >= 3 then
                    cr()
                    task.wait(5)
                    sc = 0
                end
            else
                sc = 0
            end
            
            local c = ccg()
            
            if c >= s.tg then
                if oeg() then
                    task.wait(10)
                else
                    task.wait(5)
                end
                return
            end
            
            if s.cg and ccgs() then
                conr()
            else
                s.cg = nil
            end
            
            if not s.cg then
                s.isg = true
                
                local bg = fbg()
                
                if bg then
                    if ttg(bg) then
                        task.wait(1)
                        conr()
                    else
                        task.wait(2)
                    end
                else
                    if lp.Character and lp.Character.PrimaryPart then
                        local cp = lp.Character.PrimaryPart.Position
                        lp.Character:SetPrimaryPartCFrame(CFrame.new(cp + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))))
                    end
                    task.wait(3)
                end
                
                s.isg = false
            end
        end)
        
        if not sc then
            s.cg = nil
            s.isg = false
            task.wait(2)
        end
        
        task.wait(1)
    end
    
    s.ar = false
end

local function kca()
    s.kla = true
    
    while s.af and isk(lp) and s.kla do
        s.lat = os.time()
        
        local ap = {}
        
        for _, p in pairs(pl:GetPlayers()) do
            if p ~= lp then
                table.insert(ap, p)
            end
        end
        
        if #ap == 0 then
            task.wait(1.0)
            continue
        end
        
        local ft = false
        
        for i, p in ipairs(ap) do
            if not s.af or not s.kla then break end
            
            if iss(p) then
                continue
            end
            
            if not is(p) then
                continue
            end
            
            local hi = cph(p.Name)
            
            if hi.found and hi.hasHumanoid then
                ft = true
                s.kt = p
                
                while s.kt and s.kla and hi.health > 20 do
                    if not s.af then break end
                    
                    tbp(p)
                    task.wait(0.1)
                    
                    ba:FireServer()
                    task.wait(0.2)
                    
                    hi = cph(p.Name)
                    
                    if not hi.found or not hi.hasHumanoid or hi.health <= 0 then
                        break
                    end
                end
                
                if hi.lowHealth and hi.health > 0 then
                    if tcp(p) then
                        task.wait(0.5)
                        
                        if tth() then
                            task.wait(0.5)
                            
                            she()
                            task.wait(1.0)
                        end
                    end
                end
                
                break
            end
        end
        
        if not ft then
            s.kt = nil
            task.wait(1.0)
        end
        
        task.wait(0.5)
    end
    
    s.kt = nil
    s.kla = false
end

local function afc()
    local lt = nil
    
    while s.af do
        local sc, em = pcall(function()
            local ct = lp.Team and lp.Team.Name or "NT"
            
            if lt ~= ct then
                lt = ct
            end
            
            if not lp or not lp.Parent then
                s.af = false
                return
            end
            
            if iss(lp) then
                task.wait(3.0)
                return
            end
            
            if is(lp) then
                s.ar = true
                s.kla = false
                ar()
            elseif isk(lp) then
                s.ar = false
                s.cg = nil
                kca()
            else
                s.ar = false
                s.cg = nil
                s.kla = false
                task.wait(3.0)
            end
        end)
        
        if not sc then
            task.wait(2)
        end
        
        task.wait(1.0)
    end
end

local function aa()
    while s.aa do
        ba:FireServer()
        task.wait(0.1)
    end
end

local atab = w:Tab({Title = "Auto System", Icon = "swords"}) do
    atab:Section({Title = "Combat"})

    atab:Toggle({
        Title = "Auto Attack",
        Desc = "Automatic attacking",
        Value = s.aa,
        Callback = function(v)
            s.aa = v
            if v then
                spawn(aa)
                w:Notify({
                    Title = "Auto Attack",
                    Desc = "Auto Attack enabled!",
                    Time = 3
                })
            else
                w:Notify({
                    Title = "Auto Attack",
                    Desc = "Auto Attack disabled!",
                    Time = 3
                })
            end
        end
    })

    atab:Toggle({
        Title = "Auto Farm",
        Desc = "Smart mode: Repair for Survivors, Hunt for Killer",
        Value = s.af,
        Callback = function(v)
            s.af = v
            if v then
                local ct = lp.Team and lp.Team.Name or "NT"
                w:Notify({
                    Title = "Auto Farm",
                    Desc = "Auto Farm enabled! (" .. ct .. ")",
                    Time = 3
                })
                spawn(afc)
            else
                s.ar = false
                s.cg = nil
                s.kla = false
                w:Notify({
                    Title = "Auto Farm",
                    Desc = "Auto Farm disabled!",
                    Time = 3
                })
            end
        end
    })
    
    atab:Button({
        Title = "Cancel Repair",
        Desc = "Cancel current generator repair",
        Callback = function()
            if cr() then
                w:Notify({
                    Title = "Repair Cancelled",
                    Desc = "Successfully cancelled repair!",
                    Time = 3
                })
            else
                w:Notify({
                    Title = "Cancel Failed",
                    Desc = "No active repair to cancel!",
                    Time = 3
                })
            end
        end
    })
    
    atab:Button({
        Title = "Open Exit Gate Now",
        Desc = "Teleport to open exit gate immediately",
        Callback = function()
            if oeg() then
                w:Notify({
                    Title = "Gate Opened",
                    Desc = "Exit gate opened successfully!",
                    Time = 3
                })
            else
                w:Notify({
                    Title = "Gate Open Failed",
                    Desc = "Failed to open exit gate!",
                    Time = 3
                })
            end
        end
    })
    
    atab:Button({
        Title = "Test Hook Teleport",
        Desc = "Test teleport to Hook",
        Callback = function()
            if tth() then
                w:Notify({
                    Title = "Success",
                    Desc = "Teleported to Hook successfully!",
                    Time = 3
                })
            else
                w:Notify({
                    Title = "Error",
                    Desc = "Failed to teleport to Hook!",
                    Time = 3
                })
            end
        end
    })
end

w:Notify({
    Title = "x2zu",
    Desc = "Auto system loaded successfully! Target: " .. s.tg .. " generators",
    Time = 3
})
