local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/vaxtalastus-web/Casserus-UI-Library-RBX/refs/heads/main/source.lua"))()
local MyWindow = UILibrary:CreateWindow("Easter Event Farm")
local mainTab = MyWindow:CreateTab("Main")
local settingsTab = MyWindow:CreateTab("Settings")

-- [[ GLOBAL SETTINGS ]] --
_G.AutoFarmEnabled = false
_G.AlreadyRunning = false
_G.CurrentTween = nil
_G.ItemMemory = {}

local SPEED = 300
local SKY_Y = 250
local THIRSTY_POS = Vector3.new(-1188, 10, 1296)
local MOLTEN_POS = Vector3.new(-5227, 287, -5497) -- พิกัดสำหรับ Molten Egg
local CLICK_X, CLICK_Y = 1431, 485 

-- [[ CORE FUNCTIONS ]] --
local function noclip()
    local character = game.Players.LocalPlayer.Character
    if not _G.AutoFarmEnabled or not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then humanoid.Sit = false end
    
    local water = workspace.Map:FindFirstChild("WaterBase-Plane")
    if water then water.CanCollide = true end
    
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") then 
            v.CanCollide = false 
            v.Velocity = Vector3.new(0, 0, 0)
            v.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end

local function moveTo(targetPos)
    local character = game.Players.LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local distance = (targetPos - rootPart.Position).Magnitude
    if distance < 3 then return end
    local duration = distance / SPEED
    
    if _G.CurrentTween then _G.CurrentTween:Cancel() end
    _G.CurrentTween = game:GetService("TweenService"):Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(targetPos)
    })
    _G.CurrentTween:Play()
end

local function rememberPos(pos)
    for _, v in pairs(_G.ItemMemory) do
        if (v - pos).Magnitude < 10 then return end
    end
    table.insert(_G.ItemMemory, pos)
    if #_G.ItemMemory > 15 then table.remove(_G.ItemMemory, 1) end
end

-- [[ START FARMING FUNCTION ]] --
local function StartFarming()
    task.spawn(function()
        local player = game.Players.LocalPlayer
        local VIM = game:GetService("VirtualInputManager")
        local memoryIndex = 1
        
        while _G.AutoFarmEnabled do
            local character = player.Character
            if not character then task.wait(1) continue end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            if not rootPart or not humanoid then task.wait(1) continue end

            local fallingEgg = player.Backpack:FindFirstChild("Falling Sky Egg") or character:FindFirstChild("Falling Sky Egg")
            local thirstyEgg = player.Backpack:FindFirstChild("Thirsty Egg") or character:FindFirstChild("Thirsty Egg")
            local moltenEgg = player.Backpack:FindFirstChild("Molten Egg") or character:FindFirstChild("Molten Egg")
            local friendlyEgg = player.Backpack:FindFirstChild("Friendly Neighborhood Egg") or character:FindFirstChild("Friendly Neighborhood Egg")
            
            -- ทำงานตามลำดับ ถ้าเจอไข่อันไหนก่อนจะทำอันนั้นให้เสร็จก่อน
            if fallingEgg then
                if _G.CurrentTween then _G.CurrentTween:Cancel() end
                if fallingEgg.Parent ~= character then 
                    humanoid:UnequipTools() -- ป้องกันการถือซ้อน
                    task.wait(0.1)
                    humanoid:EquipTool(fallingEgg) 
                    task.wait(0.3) 
                end
                rootPart.CFrame = CFrame.new(rootPart.Position.X, SKY_Y, rootPart.Position.Z)
                task.wait(0.2)
                while _G.AutoFarmEnabled and fallingEgg.Parent do
                    VIM:SendMouseMoveEvent(CLICK_X, CLICK_Y, game)
                    VIM:SendMouseButtonEvent(CLICK_X, CLICK_Y, 0, true, game, 0)
                    task.wait(0.05)
                    VIM:SendMouseButtonEvent(CLICK_X, CLICK_Y, 0, false, game, 0)
                    if not (player.Backpack:FindFirstChild("Falling Sky Egg") or character:FindFirstChild("Falling Sky Egg")) then break end
                    task.wait(0.05)
                end
                task.wait(5)
                
            elseif thirstyEgg then
                if _G.CurrentTween then _G.CurrentTween:Cancel() end
                if thirstyEgg.Parent ~= character then 
                    humanoid:UnequipTools() -- ป้องกันการถือซ้อน
                    task.wait(0.1)
                    humanoid:EquipTool(thirstyEgg) 
                    task.wait(0.3) 
                end
                moveTo(THIRSTY_POS)
                repeat task.wait() until (rootPart.Position - THIRSTY_POS).Magnitude < 8 or not thirstyEgg.Parent
                while _G.AutoFarmEnabled and thirstyEgg.Parent do
                    VIM:SendMouseMoveEvent(CLICK_X, CLICK_Y, game)
                    VIM:SendMouseButtonEvent(CLICK_X, CLICK_Y, 0, true, game, 0)
                    task.wait(0.05)
                    VIM:SendMouseButtonEvent(CLICK_X, CLICK_Y, 0, false, game, 0)
                    if not (player.Backpack:FindFirstChild("Thirsty Egg") or character:FindFirstChild("Thirsty Egg")) then break end
                    task.wait(0.05)
                end
                task.wait(5)
                
            elseif moltenEgg then
                if _G.CurrentTween then _G.CurrentTween:Cancel() end
                if moltenEgg.Parent ~= character then 
                    humanoid:UnequipTools() -- ป้องกันการถือซ้อน
                    task.wait(0.1)
                    humanoid:EquipTool(moltenEgg) 
                    task.wait(0.3) 
                end
                moveTo(MOLTEN_POS)
                repeat task.wait() until (rootPart.Position - MOLTEN_POS).Magnitude < 8 or not moltenEgg.Parent
                while _G.AutoFarmEnabled and moltenEgg.Parent do
                    VIM:SendMouseMoveEvent(CLICK_X, CLICK_Y, game)
                    VIM:SendMouseButtonEvent(CLICK_X, CLICK_Y, 0, true, game, 0)
                    task.wait(0.05)
                    VIM:SendMouseButtonEvent(CLICK_X, CLICK_Y, 0, false, game, 0)
                    if not (player.Backpack:FindFirstChild("Molten Egg") or character:FindFirstChild("Molten Egg")) then break end
                    task.wait(0.05)
                end
                task.wait(5)
                
            elseif friendlyEgg then
                if _G.CurrentTween then _G.CurrentTween:Cancel() end
                local spot = nil
                for _, v in pairs(workspace:GetChildren()) do if string.find(v.Name, "Friendly Neighborhood Egg") then spot = v break end end
                if spot then
                    moveTo(spot:GetPivot().Position)
                    repeat task.wait() until (rootPart.Position - spot:GetPivot().Position).Magnitude < 5
                    local args = {"NPC.TravelingQuest", workspace:WaitForChild("NPCs"):WaitForChild("Forgotten Quest Giver")}
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/EasterServiceRF"):InvokeServer(unpack(args))
                    task.wait(3)
                end
                
            else
                local egg = nil
                for _, v in pairs(workspace:GetChildren()) do
                    if v:IsA("Model") and (v:FindFirstChild("indra egg") or v:FindFirstChild("_PrimaryPart")) then
                        egg = v break
                    end
                end
                
                local folder = workspace:FindFirstChild("ChestModels")
                local nearestChest, dist = nil, math.huge
                if folder then
                    for _, v in pairs(folder:GetChildren()) do
                        local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                        if p then
                            local d = (rootPart.Position - p.Position).Magnitude
                            if d < dist then dist = d nearestChest = v end
                        end
                    end
                end
                
                if egg then
                    local eggPos = egg:GetPivot().Position
                    rememberPos(eggPos)
                    if (rootPart.Position - eggPos).Magnitude < 8 then
                        if _G.CurrentTween then _G.CurrentTween:Cancel() end
                        rootPart.CFrame = CFrame.new(eggPos)
                    else
                        moveTo(eggPos)
                    end
                elseif nearestChest then
                    local chestPos = nearestChest:GetPivot().Position
                    rememberPos(chestPos)
                    moveTo(chestPos)
                else
                    if #_G.ItemMemory > 0 then
                        local targetMemoryPos = _G.ItemMemory[memoryIndex]
                        moveTo(targetMemoryPos)
                        if (rootPart.Position - targetMemoryPos).Magnitude < 10 then
                            memoryIndex = memoryIndex + 1
                            if memoryIndex > #_G.ItemMemory then memoryIndex = 1 end
                            task.wait(2)
                        end
                    else
                        task.wait(1)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- [[ UI ELEMENTS ]] --
mainTab:CreateToggle("Enable Auto Farm", function(state)
    _G.AutoFarmEnabled = state
    if state then
        print("---------- STARTED ----------")
        StartFarming()
    else
        if _G.CurrentTween then _G.CurrentTween:Cancel() end
        local water = workspace.Map:FindFirstChild("WaterBase-Plane")
        if water then water.CanCollide = false end
        print("---------- STOPPED ----------")
    end
end)

settingsTab:CreateSlider("Tween Speed", 100, 800, 300, function(value)
    SPEED = value
end)

settingsTab:CreateSlider("Sky Height (Y)", 100, 500, 250, function(value)
    SKY_Y = value
end)

-- [[ NOCLIP LOOP ]] --
game:GetService("RunService").Stepped:Connect(noclip)
