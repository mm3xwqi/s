local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'))()

-- [[ UI INITIALIZATION ]] --
local Window = Rayfield:CreateWindow({
   Name = "Easter Event Farm | FrostByte",
   LoadingTitle = "FrostByte Interface",
   LoadingSubtitle = "by Arrays",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "FrostByteFarm",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = false
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local SettingsTab = Window:CreateTab("Settings")

local FarmSection = MainTab:CreateSection("Farming", false)
local ConfigSection = SettingsTab:CreateSection("Configuration", false)

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
local THIRSTY_POS = Vector3.new(-1188, 10, 1296)
local MOLTEN_POS = Vector3.new(-5227, 287, -5497)
local FRIENDLY_POS = Vector3.new(-3053, 240, -10144)

local GHOST_SHIP_IN = Vector3.new(923.213, 126.976, 32852.832)
local GHOST_SHIP_OUT = Vector3.new(-6508.558, 89.035, -132.840)
local DRESSROSA_POS = Vector3.new(-286.9859619140625, 306.13739013671875, 597.88623046875)

-- [[ Special islands ]] --
local SPECIAL_ISLANDS = {
    DarkbeardArena = Vector3.new(2284.909, 15.538, 905.477),
    SnowMountain    = Vector3.new(0, 0, 0),
    IceCastle       = Vector3.new(0, 0, 0),
    Mini1           = Vector3.new(0, 0, 0),
}

local EXIT_REMOTE_ISLANDS = {
    Mini2 = true,
    GraveIsland = true,
    CircleIsland = true,
}

local ExcludedMaps = {
    ["FortBuilderPlacedSurfaces"] = true,
    ["FortBuilderPotentialSurfaces"] = true,
    ["Fishmen"] = true,
    ["MiniSky"] = true,
    ["RaidMap"] = true,
    ["WaterBase-Plane"] = true,
    ["IndraIsland"] = true,
    ["EventInstances"] = true -- เพิ่มการป้องกัน Folder นี้
}

-- [[ CORE FUNCTIONS ]] --
local function getNextIsland()
    local islands = {}
    for _, island in ipairs(workspace.Map:GetChildren()) do
        -- แก้ไข: เพิ่ม island:IsA("Model") เพื่อให้แน่ใจว่าเป็นโมเดลเกาะ ไม่ใช่โฟลเดอร์
        if island:IsA("Model") and not ExcludedMaps[island.Name] then 
            table.insert(islands, island) 
        end
    end
    if #islands > 0 then
        return islands[math.random(1, #islands)]
    end
    return nil
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
    task.wait(2)
end

local function teleportToDressrosa()
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("CommF_")
    if remote then
        remote:InvokeServer("requestEntrance", DRESSROSA_POS)
        task.wait(2)
    end
end

local function teleportToSpecialIsland(islandName)
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("CommF_")
    if not remote then return end

    if EXIT_REMOTE_ISLANDS[islandName] then
        remote:InvokeServer("requestEntrance", GHOST_SHIP_OUT)
        _G.InGhostShip = false
        task.wait(2)
    elseif SPECIAL_ISLANDS[islandName] then
        remote:InvokeServer("requestEntrance", SPECIAL_ISLANDS[islandName])
        task.wait(2)
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
                task.wait(15)
                _G.ChestBlacklist = {} 
                _G.ShardBlacklist = {}
            end
        end)

        while _G.AutoFarmEnabled do
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then task.wait(0.5) continue end

            local eggInHand = getSpecialEgg()
            local deliveredEgg = false 
            
            if _G.QuestModeEnabled and eggInHand then
                if _G.InGhostShip then toggleGhostShip("exit") end
                local humanoid = character:FindFirstChild("Humanoid")
                if eggInHand.Parent ~= character and humanoid then humanoid:EquipTool(eggInHand) task.wait(0.3) end
                
                if eggInHand.Name == "Firefly Egg" or eggInHand.Name == "Friendly Neighborhood Egg" then
                    moveTo(FRIENDLY_POS)
                    repeat task.wait(0.1) until (rootPart.Position - FRIENDLY_POS).Magnitude < 10 or not eggInHand.Parent
                    if eggInHand.Parent == character then
                        game:GetService("ReplicatedStorage").Modules.Net["RF/EasterServiceRF"]:InvokeServer("NPC.TravelingQuest", workspace.NPCs:FindFirstChild("Forgotten Quest Giver"))
                        deliveredEgg = true
                    end
                else
                    local optionButton = player.PlayerGui.Main.Dialogue:FindFirstChild("Option1")
                    if string.find(eggInHand.Name, "Falling") then
                        local currentPos = rootPart.Position
                        rootPart.CFrame = CFrame.new(currentPos.X, currentPos.Y + 150, currentPos.Z)
                        task.wait(0.5)
                        while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character do clickButton(optionButton) task.wait(0.2) end
                        deliveredEgg = true
                    elseif string.find(eggInHand.Name, "Thirsty") then
                        moveTo(THIRSTY_POS)
                        repeat task.wait(0.1) until (rootPart.Position - THIRSTY_POS).Magnitude < 12 or not eggInHand.Parent
                        while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character do clickButton(optionButton) task.wait(0.2) end
                        deliveredEgg = true
                    elseif string.find(eggInHand.Name, "Molten") then
                        moveTo(MOLTEN_POS)
                        repeat task.wait(0.1) until (rootPart.Position - MOLTEN_POS).Magnitude < 12 or not eggInHand.Parent
                        while _G.AutoFarmEnabled and _G.QuestModeEnabled and eggInHand.Parent == character do clickButton(optionButton) task.wait(0.2) end
                        deliveredEgg = true
                    end
                end
                if deliveredEgg then task.wait(5) else task.wait(1) end
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
                            if _G.ChestWaitTime > 0 then task.wait(_G.ChestWaitTime) end
                        end
                    else
                        if _G.InGhostShip then
                            toggleGhostShip("exit")
                            _G.TargetIsland = nil 
                        else
                            if not _G.TargetIsland then _G.TargetIsland = getNextIsland() end
                            if _G.TargetIsland then
                                local islandName = _G.TargetIsland.Name
                                if islandName == "GhostShipInterior" then
                                    if not _G.InGhostShip then toggleGhostShip("enter") end
                                    _G.TargetIsland = nil
                                elseif islandName == "Dressrosa" then
                                    teleportToDressrosa()
                                    _G.TargetIsland = nil
                                elseif SPECIAL_ISLANDS[islandName] or EXIT_REMOTE_ISLANDS[islandName] then
                                    teleportToSpecialIsland(islandName)
                                    _G.TargetIsland = nil
                                else
                                    local islandPos = _G.TargetIsland:GetPivot().Position + Vector3.new(0, 80, 0)
                                    moveTo(islandPos)
                                    if (rootPart.Position - islandPos).Magnitude < 50 then _G.TargetIsland = nil end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.01)
        end
    end)
end

-- [[ UI ELEMENTS ]] --

MainTab:CreateToggle({
   Name = "Enable Auto Farm",
   CurrentValue = false,
   Flag = "AutoFarm",
   SectionParent = FarmSection,
   Callback = function(Value)
      _G.AutoFarmEnabled = Value
      if Value then 
          StartFarming() 
      else 
          if _G.CurrentTween then _G.CurrentTween:Cancel() end 
      end
   end,
})

MainTab:CreateToggle({
   Name = "Enable Quest Delivery",
   CurrentValue = false,
   Flag = "QuestMode",
   SectionParent = FarmSection,
   Callback = function(Value)
      _G.QuestModeEnabled = Value
   end,
})

SettingsTab:CreateSlider({
   Name = "Tween Speed",
   Range = {100, 800},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 350,
   Flag = "SpeedSlider",
   SectionParent = ConfigSection,
   Callback = function(Value)
      SPEED = Value
   end,
})

SettingsTab:CreateSlider({
   Name = "Chest Wait Time (ms)",
   Range = {0, 200},
   Increment = 1,
   Suffix = "ms",
   CurrentValue = 0,
   Flag = "WaitSlider",
   SectionParent = ConfigSection,
   Callback = function(Value)
      _G.ChestWaitTime = Value / 100
   end,
})

-- Noclip logic
game:GetService("RunService").Stepped:Connect(noclip)
