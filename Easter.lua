-- [[ FrostByte Farm: SMOOTH TWEEN VERSION (NO TELEPORT) ]]

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
local Windows = NothingLibrary.new({
    Title = "FrostByte Farm",
    Description = "Egg Priority + Chase Shards + Pure Tween Movement",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

-- [[ Notification System ]]
local Notification = NothingLibrary.Notification()
local function notify(title, desc, duration)
    if Notification and Notification.new then
        Notification.new({ Title = title, Description = desc, Duration = duration or 3 })
    end
end

-- [[ Global Variables ]]
_G.AutoFarmEnabled = false
_G.QuestModeEnabled = false
_G.InGhostShip = false
_G.CurrentTween = nil
_G.TargetIsland = nil
_G.ChestBlacklist = {}
_G.ShardBlacklist = {}
_G.ChestWaitTime = 1
_G.IslandLoadWait = 2

local SPEED = 350
local currentTargetPos = nil

-- [ พิกัดสำคัญ ]
local THIRSTY_POS  = Vector3.new(-1188, 10, 1296)
local MOLTEN_POS   = Vector3.new(-5227, 287, -5497)
local FRIENDLY_POS = Vector3.new(-3053, 240, -10144)
local GATHER_POS   = Vector3.new(-385, 149, 296)
local GHOST_SHIP_INTERIOR_POS = Vector3.new(923, 126, 32852)

-- [ รายชื่อแมพที่ยกเว้น ]
local ExcludedMaps = {
    ["FortBuilderPlacedSurfaces"] = true,
    ["FortBuilderPotentialSurfaces"] = true,
    ["Fishmen"] = true,
    ["MiniSky"] = true,
    ["RaidMap"] = true,
    ["WaterBase-Plane"] = true,
    ["IndraIsland"] = true,
    ["EventInstances"] = true,
}

-- [[ ฟังก์ชันตรวจสอบไอเทม (เพิ่มไอเทมใหม่ที่คุณต้องการที่นี่) ]]
local function isCollectable(v)
    if not v then return false end
    local names = {
        "Cube", "Cube.001", "Cube.002", "Cube.003", 
        "Cylinder.003", "Cylinder.004", "indra egg", 
        "Firefly Egg", "Friendly Neighborhood Egg", "Falling Sky Egg"
    }
    for _, name in ipairs(names) do
        if v.Name == name or v:FindFirstChild(name) then
            return true
        end
    end
    return false
end

-- [ พิกัดประตูสำหรับแต่ละเกาะ ]
local RemoteTeleportIslands = {
    ["CircleIsland"]   = Vector3.new(-6508.558, 89.035, -132.840),
    ["Mini2"]          = Vector3.new(-6508.558, 89.035, -132.840),
    ["GraveIsland"]    = Vector3.new(-6508.558, 89.035, -132.840),
    ["Dressrosa"]      = Vector3.new(-286.986, 306.137, 597.886),
    ["DarkbeardArena"] = Vector3.new(2284.909, 15.538, 905.477),
    ["IceCastle"]      = Vector3.new(2284.909, 15.538, 905.477),
    ["Mini1"]          = Vector3.new(2284.909, 15.538, 905.477),
    ["SnowMountain"]   = Vector3.new(2284.909, 15.538, 905.477),
}

-- [[ Helper Functions ]]
local function getPos(v)
    if not v then return nil end
    local ok, result = pcall(function()
        if v:IsA("BasePart") then return v.Position
        elseif v:IsA("Model") then return v:GetPivot().Position
        end
        return nil
    end)
    return ok and result or nil
end

local function isInGhostShip()
    local char = game.Players.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return (root.Position - GHOST_SHIP_INTERIOR_POS).Magnitude < 500
end

local function stopMovement()
    if _G.CurrentTween then
        _G.CurrentTween:Cancel()
        _G.CurrentTween = nil
        currentTargetPos = nil
    end
end

-- ฟังก์ชัน Tween หลัก (ตัวนี้แหละที่ทำให้เดินเนียน)
local function tweenTo(targetPos)
    if not targetPos then return end
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local dist = (targetPos - root.Position).Magnitude
    if dist < 2 then return end -- ระยะใกล้มากไม่ต้องขยับ
    
    -- ถ้าเป้าหมายเดิมใกล้เคียงของเดิม ไม่ต้องสร้าง Tween ใหม่บ่อยๆ
    if currentTargetPos and (currentTargetPos - targetPos).Magnitude < 1 then return end
    
    if _G.CurrentTween then _G.CurrentTween:Cancel() end
    
    _G.CurrentTween = game:GetService("TweenService"):Create(
        root,
        TweenInfo.new(dist / SPEED, Enum.EasingStyle.Linear),
        { CFrame = CFrame.new(targetPos) }
    )
    _G.CurrentTween:Play()
    currentTargetPos = targetPos
end

-- รอจนกว่าจะถึงจุดหมาย (เอาการวาร์ป CFrame Snap ออกแล้ว)
local function waitUntilReached(targetPos, threshold, timeout)
    threshold = threshold or 5
    timeout = timeout or 30
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local startTime = tick()
    while _G.AutoFarmEnabled do
        local dist = (root.Position - targetPos).Magnitude
        if dist <= threshold then
            -- ถึงระยะแล้ว หยุดรอ (ไม่มีการ teleport snap)
            break
        end
        if not _G.CurrentTween or _G.CurrentTween.PlaybackState ~= Enum.PlaybackState.Playing then
            tweenTo(targetPos)
        end
        if tick() - startTime > timeout then
            break
        end
        task.wait(0.1)
    end
    stopMovement()
end

local function invokeEntrance(pos)
    local commF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
    commF:InvokeServer("requestEntrance", pos)
end

local function toggleGhostShip(action)
    if action == "enter" then
        invokeEntrance(Vector3.new(923.213, 126.976, 32852.832))
        _G.InGhostShip = true
        notify("👻 Ghost Ship", "Entering...", 2)
        task.wait(2)
    elseif action == "exit" then
        invokeEntrance(Vector3.new(-6508.558, 89.035, -132.840))
        _G.InGhostShip = false
        notify("🚢 Exit Ship", "Leaving...", 2)
        task.wait(2)
        -- ตอนออกวาร์ปนิดหน่อยเพื่อให้พ้นประตู (อันนี้จำเป็น)
        local root2 = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root2 then root2.CFrame = root2.CFrame + Vector3.new(0, 30, 0) end
        task.wait(0.2)
    end
end

local function getAllIslands()
    local islands = {}
    for _, v in ipairs(workspace.Map:GetChildren()) do
        if v:IsA("Model") and not ExcludedMaps[v.Name] then table.insert(islands, v) end
    end
    return islands
end

local function getRandomIsland()
    local islands = getAllIslands()
    return #islands > 0 and islands[math.random(1, #islands)] or nil
end

local function getSpecialEgg()
    local player = game.Players.LocalPlayer
    local names = {"Falling Sky Egg","Thirsty Egg","Molten Egg","Friendly Neighborhood Egg","Firefly Egg"}
    for _, n in ipairs(names) do
        local egg = player.Backpack:FindFirstChild(n) or (player.Character and player.Character:FindFirstChild(n))
        if egg then return egg end
    end
    return nil
end

local function clickButton(button)
    if button and button:IsA("GuiButton") and button.Visible then
        local VIM = game:GetService("VirtualInputManager")
        local pos, size = button.AbsolutePosition, button.AbsoluteSize
        local cx, cy = pos.X + size.X / 2, pos.Y + size.Y / 2 + 58
        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
    end
end

local function noclip()
    if not _G.AutoFarmEnabled then return end
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if humanoid.Sit then humanoid.Sit = false end
    end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

local function hasPriorityTarget()
    for _, v in ipairs(workspace:GetChildren()) do
        if not _G.ShardBlacklist[v] and (v.Name == "Shard" or isCollectable(v)) then return true end
    end
    return false
end

-- [[ Main Logic Loop ]]
local function StartFarming()
    task.spawn(function()
        task.spawn(function() while _G.AutoFarmEnabled do task.wait(15); _G.ChestBlacklist = {} end end)
        task.spawn(function() while _G.AutoFarmEnabled do task.wait(3); _G.InGhostShip = isInGhostShip() end end)

        while _G.AutoFarmEnabled do
            local player = game.Players.LocalPlayer
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then task.wait(0.5); continue end

            -- 1. Quest Mode
            local eggInHand = getSpecialEgg()
            if _G.QuestModeEnabled and eggInHand then
                if _G.InGhostShip then toggleGhostShip("exit") end
                local eggName = eggInHand.Name
                local delivered = false

                if eggName == "Firefly Egg" or eggName == "Friendly Neighborhood Egg" then
                    tweenTo(FRIENDLY_POS); waitUntilReached(FRIENDLY_POS, 10, 30)
                    if eggInHand.Parent == player.Character then
                        pcall(function() game:GetService("ReplicatedStorage").Modules.Net["RF/EasterServiceRF"]:InvokeServer("NPC.TravelingQuest", workspace.NPCs:FindFirstChild("Forgotten Quest Giver")) end)
                        delivered = true
                    end
                elseif eggName:find("Falling") then
                    -- สำหรับไข่ตกจากฟ้า ใช้การ Tween บินขึ้นแทนการวาร์ป
                    local skyPos = rootPart.Position + Vector3.new(0, 150, 0)
                    tweenTo(skyPos); waitUntilReached(skyPos, 5, 5)
                    local pressEnd = tick() + 5
                    while tick() < pressEnd and _G.AutoFarmEnabled do
                        local btn = player.PlayerGui.Main:FindFirstChild("Dialogue") and player.PlayerGui.Main.Dialogue:FindFirstChild("Option1")
                        if btn and btn.Visible then clickButton(btn) end
                        task.wait(0.05)
                    end
                    task.wait(1); continue
                else
                    local target = (eggName:find("Thirsty") and THIRSTY_POS) or (eggName:find("Molten") and MOLTEN_POS)
                    if target then tweenTo(target); waitUntilReached(target, 10, 30) end
                    local btn = player.PlayerGui.Main:FindFirstChild("Dialogue") and player.PlayerGui.Main.Dialogue:FindFirstChild("Option1")
                    if btn and btn.Visible then clickButton(btn); delivered = true end
                end
                task.wait(delivered and 5 or 1); continue
            end

            -- 2. Shard Chase (เอา rootPart.CFrame snap ออกแล้ว)
            local shard = nil
            for _, v in ipairs(workspace:GetChildren()) do if v.Name == "Shard" and not _G.ShardBlacklist[v] then shard = v; break end end
            if shard then
                while _G.AutoFarmEnabled and shard.Parent == workspace do
                    local tp = getPos(shard)
                    if not tp then break end
                    tweenTo(tp)
                    if (rootPart.Position - tp).Magnitude < 3 then break end -- ถึงระยะเก็บ
                    task.wait(0.1)
                end
                _G.ShardBlacklist[shard] = true; stopMovement(); continue
            end

            -- 3. Egg Chase (Tween จนถึงไข่ ไม่มีการวาร์ป)
            local eggTarget = nil
            for _, v in ipairs(workspace:GetChildren()) do if isCollectable(v) and not _G.ShardBlacklist[v] then eggTarget = v; break end end
            if eggTarget then
                while _G.AutoFarmEnabled and eggTarget.Parent == workspace do
                    local tp = getPos(eggTarget)
                    if not tp then break end
                    tweenTo(tp)
                    if (rootPart.Position - tp).Magnitude < 3 then break end -- ถึงระยะเก็บ
                    task.wait(0.1)
                end
                _G.ShardBlacklist[eggTarget] = true; stopMovement(); continue
            end

            -- 4. Chest Farm
            local nearestChest = nil
            local folder = workspace:FindFirstChild("ChestModels")
            if folder then
                local ndist = math.huge
                for _, c in ipairs(folder:GetChildren()) do
                    if not _G.ChestBlacklist[c] then
                        local d = (rootPart.Position - c:GetPivot().Position).Magnitude
                        if d < ndist then ndist = d; nearestChest = c end
                    end
                end
            end
            if nearestChest then
                local cp = nearestChest:GetPivot().Position
                tweenTo(cp)
                waitUntilReached(cp, 5, 20)
                _G.ChestBlacklist[nearestChest] = true
                task.wait(_G.ChestWaitTime)
                stopMovement(); continue
            end

            -- 5. Island Switch
            if not _G.TargetIsland then _G.TargetIsland = getRandomIsland() end
            if _G.TargetIsland then
                local name = _G.TargetIsland.Name
                if name == "GhostShipInterior" then toggleGhostShip("enter")
                elseif _G.InGhostShip then toggleGhostShip("exit")
                else
                    local rPos = RemoteTeleportIslands[name]
                    if rPos then
                        -- การใช้ Remote (requestEntrance) เกมจะวาร์ปเราอัตโนมัติ อันนี้แก้ไม่ได้ครับ
                        invokeEntrance(rPos); task.wait(1.5)
                    else 
                        local fPos = _G.TargetIsland:GetPivot().Position + Vector3.new(0, 80, 0)
                        tweenTo(fPos); waitUntilReached(fPos, 10, 30)
                    end
                end
                task.wait(_G.IslandLoadWait); _G.TargetIsland = nil
            end
            task.wait(0.01)
        end
    end)
end

-- [[ UI ]]
local MainTab = Windows:NewTab({ Title = "Main", Icon = "rbxassetid://7733960981" })
local MainSec = MainTab:NewSection({ Title = "Controls" })
MainSec:NewToggle({ Title = "Auto Farm", Default = false, Callback = function(v) _G.AutoFarmEnabled = v; if v then StartFarming() else stopMovement() end end })
MainSec:NewToggle({ Title = "Quest Mode", Default = false, Callback = function(v) _G.QuestModeEnabled = v end })

local SettTab = Windows:NewTab({ Title = "Settings", Icon = "rbxassetid://7733964719" })
local SettSec = SettTab:NewSection({ Title = "Movement" })
SettSec:NewSlider({ Title = "Speed", Default = 350, Min = 100, Max = 1000, Callback = function(v) SPEED = v end })
SettSec:NewSlider({ Title = "Chest Delay", Default = 1, Min = 0, Max = 5, Decimals = 1, Callback = function(v) _G.ChestWaitTime = v end })

game:GetService("RunService").Stepped:Connect(noclip)
notify("FrostByte", "Smooth Tween Loaded!", 5)
