local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/vaxtalastus-web/Casserus-UI-Library-RBX/refs/heads/main/source.lua"))()
local MyWindow = UILibrary:CreateWindow("Easter Event Farm")
local mainTab = MyWindow:CreateTab("Main")
local settingsTab = MyWindow:CreateTab("Settings")

-- [[ GLOBAL SETTINGS ]] --
_G.AutoFarmEnabled = false
_G.QuestModeEnabled = false 
_G.CurrentTween = nil
_G.TargetIsland = nil
_G.ChestBlacklist = {} 
_G.ShardBlacklist = {} 
_G.ChestWaitTime = 0
_G.InGhostShip = false

local SPEED = 350 
local SKY_Y = 250
local THIRSTY_POS = Vector3.new(-1188, 10, 1296)
local MOLTEN_POS = Vector3.new(-5227, 287, -5497)
local FRIENDLY_POS = Vector3.new(-3053, 240, -10144)

local GHOST_SHIP_IN = Vector3.new(923.213, 126.976, 32852.832)
local GHOST_SHIP_OUT = Vector3.new(-6508.558, 89.035, -132.840)
local DRESSROSA_POS = Vector3.new(-286.9859619140625, 306.13739013671875, 597.88623046875)

local ExcludedMaps = {
    ["FortBuilderPlacedSurfaces"] = true,
    ["FortBuilderPotentialSurfaces"] = true,
    ["Fishmen"] = true,
    ["MiniSky"] = true,
    ["RaidMap"] = true,
    ["WaterBase-Plane"] = true,
    ["IndraIsland"] = true
}

-- [[ CORE FUNCTIONS ]] --
local function getNextIsland()
    local islands = {}
    for _, island in ipairs(workspace.Map:GetChildren()) do
        if not ExcludedMaps[island.Name] then table.insert(islands, island) end
    end
    return islands[math.random(1, #islands)]
end

local function toggleGhostShip(mode)
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("CommF_")
    if not remote then return end
    if mode == "enter" then
        remote:InvokeServer("requestEntrance", GHOST_SHIP_IN)
        _G.InGhostShip = true
    elseif mode == "exit" then
        remote:InvokeServer("requestEntrance", GHOST_SHIP_OUT)
        _G.InGhostShip = false
    end
    task.wait(1)
end

-- ฟังก์ชันวาร์ปไป Dressrosa
local function teleportToDressrosa()
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("CommF_")
    if remote then
        remote:InvokeServer("requestEntrance", DRESSROSA_POS)
        task.wait(1)
    end
end

local function clickButton(button)
    if button and button:IsA("GuiButton") and button.Visible then
        local VIM = game:GetService("VirtualInputManager")
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize
        local centerX = pos.X + (size.X / 2)
        local centerY = pos.Y + (size.Y / 2) + 58 
        VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end
end

local function noclip()
    local character = game.Players.LocalPlayer.Character
    if not _G.AutoFarmEnabled or not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.Sit then humanoid.Sit = false end
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    end
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false v.Velocity = Vector3.new(0, 0, 0) end
    end
end

local function moveTo(targetPos)
    local character = game.Players.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not targetPos then return end
    local distance = (targetPos - rootPart.Position).Magnitude
    if distance < 3 then return end
    if _G.CurrentTween then _G.CurrentTween:Cancel() end
    _G.CurrentTween = game:GetService("TweenService"):Create(rootPart, TweenInfo.new(distance / SPEED, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    _G.CurrentTween:Play()
end

local function getSpecialEgg()
    local p = game.Players.LocalPlayer
    local c = p.Character
    local eggs = {"Falling Sky Egg", "Thirsty Egg", "Molten Egg", "Friendly Neighborhood Egg", "Firefly Egg"}
    for _, name in ipairs(eggs) do
        local found = p.Backpack:FindFirstChild(name) or (c and c:FindFirstChild(name))
        if found then return found end
    end
    return nil
end

-- [[ MAIN LOOP ]] --
local function StartFarming()
    task.spawn(function()
        local player = game.Players.LocalPlayer
        
        task.spawn(function()
            while _G.AutoFarmEnabled do 
                task.wait(10)
                _G.ChestBlacklist = {} 
                _G.ShardBlacklist = {}
            end
        end)

        while _G.AutoFarmEnabled do
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then task.wait(0.5) continue end

            local eggInHand = getSpecialEgg()
            
            -- [[ Priority 1: Quest Delivery ]] --
            if _G.QuestModeEnabled and eggInHand then
                if _G.InGhostShip then toggleGhostShip("exit") end
                local humanoid = character:FindFirstChild("Humanoid")
                if eggInHand.Parent ~= character and humanoid then humanoid:EquipTool(eggInHand) task.wait(0.3) end
                
                if eggInHand.Name == "Firefly Egg" or eggInHand.Name == "Friendly Neighborhood Egg" then
                    moveTo(FRIENDLY_POS)
                    repeat task.wait(0.1) until (rootPart.Position - FRIENDLY_POS).Magnitude < 10 or not eggInHand.Parent
                    if eggInHand.Parent == character then
                        game:GetService("ReplicatedStorage").Modules.Net["RF/EasterServiceRF"]:InvokeServer("NPC.TravelingQuest", workspace.NPCs:FindFirstChild("Forgotten Quest Giver"))
                    end
                else
                    local optionButton = player.PlayerGui.Main.Dialogue:FindFirstChild("Option1")
                    if string.find(eggInHand.Name, "Falling") then
                        rootPart.CFrame = CFrame.new(rootPart.Position.X, SKY_Y, rootPart.Position.Z)
                        while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character do clickButton(optionButton) task.wait(0.2) end
                    elseif string.find(eggInHand.Name, "Thirsty") then
                        moveTo(THIRSTY_POS)
                        repeat task.wait(0.1) until (rootPart.Position - THIRSTY_POS).Magnitude < 12 or not eggInHand.Parent
                        while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character do clickButton(optionButton) task.wait(0.2) end
                    elseif string.find(eggInHand.Name, "Molten") then
                        moveTo(MOLTEN_POS)
                        repeat task.wait(0.1) until (rootPart.Position - MOLTEN_POS).Magnitude < 12 or not eggInHand.Parent
                        while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character do clickButton(optionButton) task.wait(0.2) end
                    end
                end
                task.wait(1)

            -- [[ Priority 2: Shards & Firefly Check ]] --
            else
                local allShards = {}
                for _, v in ipairs(workspace:GetChildren()) do
                    if (v.Name == "Shard" or v:FindFirstChild("Firefly Egg")) and not _G.ShardBlacklist[v] then
                        table.insert(allShards, v)
                    end
                end

                if #allShards > 0 then
                    local closestShard = nil
                    local dist = math.huge
                    for _, s in ipairs(allShards) do
                        local sPos = s:IsA("Model") and s:GetPivot().Position or s.Position
                        local d = (rootPart.Position - sPos).Magnitude
                        if d < dist then dist = d closestShard = s end
                    end

                    if closestShard then
                        local targetPos = closestShard:IsA("Model") and closestShard:GetPivot().Position or closestShard.Position
                        moveTo(targetPos)
                        if (rootPart.Position - targetPos).Magnitude < 15 then
                            _G.ShardBlacklist[closestShard] = true
                            rootPart.CFrame = CFrame.new(targetPos)
                            task.wait(0.1)
                        end
                    end
                    
                    if #allShards == 1 and dist < 15 then 
                        local waitTime = 0
                        repeat
                            task.wait(0.5)
                            waitTime = waitTime + 0.5
                        until getSpecialEgg() or waitTime >= 10 or not _G.AutoFarmEnabled
                    end

                -- [[ Priority 3: Indra Egg / Chests ]] --
                else
                    local eggTarget = nil
                    local chestTarget = nil
                    for _, v in ipairs(workspace:GetChildren()) do
                        if v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then eggTarget = v break end
                    end
                    if not eggTarget then
                        local folder = workspace:FindFirstChild("ChestModels")
                        if folder then
                            local nearestDist = 1000
                            for _, v in ipairs(folder:GetChildren()) do
                                if not _G.ChestBlacklist[v] then
                                    local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                                    if p and (rootPart.Position - p.Position).Magnitude < nearestDist then
                                        nearestDist = (rootPart.Position - p.Position).Magnitude chestTarget = v
                                    end
                                end
                            end
                        end
                    end

                    if eggTarget then
                        moveTo(eggTarget:GetPivot().Position)
                        if (rootPart.Position - eggTarget:GetPivot().Position).Magnitude < 7 then
                            rootPart.CFrame = CFrame.new(eggTarget:GetPivot().Position)
                        end
                    elseif chestTarget then
                        moveTo(chestTarget:GetPivot().Position)
                        if (rootPart.Position - chestTarget:GetPivot().Position).Magnitude < 7 then
                            _G.ChestBlacklist[chestTarget] = true 
                            rootPart.CFrame = CFrame.new(chestTarget:GetPivot().Position)
                        end
                    else
                        -- [[ Priority 4: Island Switching ]] --
                        if not _G.TargetIsland then 
                            _G.TargetIsland = getNextIsland()
                            if _G.InGhostShip and _G.TargetIsland.Name ~= "GhostShipInterior" then toggleGhostShip("exit") end
                        end
                        if _G.TargetIsland then
                            if _G.TargetIsland.Name == "GhostShipInterior" then
                                if not _G.InGhostShip then toggleGhostShip("enter") end
                            -- ตรวจสอบเงื่อนไข Dressrosa
                            elseif _G.TargetIsland.Name == "Dressrosa" then
                                teleportToDressrosa()
                                _G.TargetIsland = nil -- รีเซ็ตเพื่อให้เริ่มสแกนหาของในเกาะใหม่ทันที
                            else
                                local islandPos = _G.TargetIsland:GetPivot().Position + Vector3.new(0, 80, 0)
                                moveTo(islandPos)
                                if (rootPart.Position - islandPos).Magnitude < 30 then _G.TargetIsland = nil end
                            end
                        end
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end

-- [[ UI Setup ]] --
mainTab:CreateToggle("Enable Auto Farm", function(state)
    _G.AutoFarmEnabled = state
    if state then StartFarming() else if _G.CurrentTween then _G.CurrentTween:Cancel() end end
end)
mainTab:CreateToggle("Enable Quest Delivery", function(state) _G.QuestModeEnabled = state end)
settingsTab:CreateSlider("Tween Speed", 100, 800, 350, function(v) SPEED = v end)
settingsTab:CreateSlider("Chest Wait Time (ms)", 0, 200, 0, function(v) _G.ChestWaitTime = v / 100 end)

game:GetService("RunService").Stepped:Connect(noclip)
