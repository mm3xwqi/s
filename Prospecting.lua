local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()
local win = DiscordLib:Window("MM</>2.7")

local serv = win:Server("Main", "")
local tgls = serv:Channel("Main")

local TweenService = game:GetService("TweenService")
local plr = game:GetService("Players").LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local character = plr.Character or plr.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")


local panPos, shakePos = nil, nil
local args = {1}
local runningPan, runningShake, runningSell = false, false, false
local fillTextObj = nil
local walkSpeedValue = humanoid.WalkSpeed 
local Pan = {"Rusty Pan", "Plastic Pan", "Metal Pan",  "Silver Pan", "Golden Pan", "Magnetic Pan", "Meteoric Pan", "Diamond Pan", "Aurora Pan", "Worldshaker", "Dragonflame Pan", "Fossilized Pan"}
-- local Common = {"Pyrite", "Silver", "Copper" , "Gold", "Platinum", "Seashell", "Obsidian", "Amethyst", "Pearl"} 
-- local Uncommon = {"Titanium", "Neodymium", "Topaz", "Smoky Quartz", "Malachite", "Coral", "Sapphire", "Zircon"} 
-- local Rare = {"Ruby", "Lapis Lazuli", "Jade", "Silver Clamshell", "Peridot", "Onyx", "Meteoric Iron", "Azuralite", "Pyrelith"} 
-- local Epic = {"Iridium", "Moonstone", "Ammonite Fossil", "Ashvein", "Pyronium", "Emerald", "Golden Pearl", "Borealite", "Osmium", "Opal", "Aurorite"} 
-- local Legendary = {"Rose Gold", "Palladium", "Cinnabar", "Diamond", "Uranium", "Luminum", "Volcanic Key", "Fire Opal", "Dragon Bone", "Catseye", "Starshine", "Aetherite"} 
-- local Mythic = {"Pink Diamond", "Painite", "Inferlume", "Vortessence", "Prismara", "Flarebloom", "Volcanic Core"} 
-- local Exotic = {"Dinosaur Skull"}

-- Equip Pan จากตาราง Pan
local function equipPan()
    for _, panName in ipairs(Pan) do
        local tool = character:FindFirstChild(panName) or plr.Backpack:FindFirstChild(panName)
        if tool and tool:IsA("Tool") then
            tool.Parent = character
            task.wait(0.1)
            return tool
        end
    end
    return nil
end


-- walkto
local PathfindingService = game:GetService("PathfindingService")

local function moveToPositionSpeed(pos, speed)
    if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
        local humanoid = plr.Character.Humanoid
        local hrp = plr.Character.HumanoidRootPart

        humanoid.WalkSpeed = walkSpeedValue

        -- สร้าง path
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            WaypointSpacing = 4
        })

        path:ComputeAsync(hrp.Position, pos)

        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()

            for _, waypoint in ipairs(waypoints) do
                humanoid:MoveTo(waypoint.Position)
                humanoid.MoveToFinished:Wait()

                -- ถ้าต้องกระโดด
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        else
            warn("[Auto Pan] Path not found, walking straight to target.")
            humanoid:MoveTo(pos)
        end
    end
end
-- Save Pan
tgls:Button("savepan", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        panPos = plr.Character.HumanoidRootPart.Position
        print("[Auto Pan] Saved pan position:", panPos)
    end
end)

-- Save Shake
tgls:Button("saveshake", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        shakePos = plr.Character.HumanoidRootPart.Position
        print("[Auto Pan] Saved shake position:", shakePos)
    end
end)

-- Auto-Pan
tgls:Toggle("Auto-Pan", false, function(state)
    runningPan = state
    task.spawn(function()
        while runningPan do
            local panTool = equipPan()
            if not panTool then
                task.wait(1)
                continue
            end

            local fillTextObj = plr:FindFirstChild("PlayerGui")
                and plr.PlayerGui:FindFirstChild("ToolUI")
                and plr.PlayerGui.ToolUI:FindFirstChild("FillingPan")
                and plr.PlayerGui.ToolUI.FillingPan:FindFirstChild("FillText")

            if not fillTextObj then
                task.wait(1)
                continue
            end

            local current, max = fillTextObj.Text:match("(%d+)%s*/%s*(%d+)")
            current, max = tonumber(current), tonumber(max)

            if current and max then
                if current < max and panPos then
                    moveToPositionSpeed(panPos, 150)
                    pcall(function()
                        panTool:WaitForChild("Scripts"):WaitForChild("Collect"):InvokeServer(1)
                    end)
                elseif current >= max and shakePos then
                    moveToPositionSpeed(shakePos, 150)
                end
            end

            task.wait(.1)
        end
    end)
end)

-- Auto-Shake
tgls:Toggle("Auto-Shake", false, function(state)
    runningShake = state
    task.spawn(function()
        while runningShake do
            local panTool = equipPan() 
            if panTool then
                local scriptsFolder = panTool:FindFirstChild("Scripts")
                if scriptsFolder then
                    local shakeEvent = scriptsFolder:FindFirstChild("Shake")
                    if shakeEvent then shakeEvent:FireServer() end
                    local panEvent = scriptsFolder:FindFirstChild("Pan")
                    if panEvent then panEvent:InvokeServer() end
                end
            end
            task.wait(.1)
        end
    end)
end)

local function findClosestWaypoint(targetPos)
    local closest = nil
    local shortestDist = math.huge
    local waypoints = workspace:WaitForChild("Map"):WaitForChild("Waypoints")

    for _, wp in ipairs(waypoints:GetChildren()) do
        if wp:IsA("BasePart") then
            local dist = (targetPos - wp.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = wp
            end
        end
    end

    return closest
end

local function fastTravelTo(fromWaypoint, toWaypoint)
    if fromWaypoint and toWaypoint then
        local args = {fromWaypoint, toWaypoint}
        RepStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
end

local function getInventorySize()
    local invGui = plr.PlayerGui:FindFirstChild("BackpackGui")
        and plr.PlayerGui.BackpackGui:FindFirstChild("Backpack")
        and plr.PlayerGui.BackpackGui.Backpack:FindFirstChild("Inventory")
        and plr.PlayerGui.BackpackGui.Backpack.Inventory:FindFirstChild("TopButtons")
        and plr.PlayerGui.BackpackGui.Backpack.Inventory.TopButtons:FindFirstChild("Unaffected")
        and plr.PlayerGui.BackpackGui.Backpack.Inventory.TopButtons.Unaffected:FindFirstChild("InventorySize")

    if invGui and invGui:IsA("TextLabel") then
        local contentText = invGui.Text 
        local current, max = contentText:match("(%d+)%s*/%s*(%d+)")
        if current and max then
            return tonumber(current), tonumber(max)
        end
    end
    return 0, 0
end

local function isInventoryFull()
    local current, max = getInventorySize()
    return current >= max and max > 0
end

tgls:Toggle("Auto-Sell", false, function(state)
    runningSell = state
    task.spawn(function()
        while runningSell do
            if isInventoryFull() then
                local merchant = findClosestMerchant()
                if merchant and merchant:FindFirstChild("HumanoidRootPart") then
                    local merchantPos = merchant.HumanoidRootPart.Position

                    -- 🔹 หา waypoint ใกล้ merchant
                    local merchantWP = findClosestWaypoint(merchantPos)

                    -- 🔹 หา waypoint ใกล้ panPos (จุดฟาร์ม)
                    local farmWP = panPos and findClosestWaypoint(panPos)

                    if merchantWP and farmWP then
                        -- เดินทางไปหา merchant
                        fastTravelTo(farmWP, merchantWP)
                        task.wait(2)

                        -- ขายของจนกว่าจะไม่เต็ม
                        while isInventoryFull() and runningSell do
                            pcall(function()
                                RepStorage:WaitForChild("Remotes")
                                    :WaitForChild("Shop")
                                    :WaitForChild("SellAll")
                                    :InvokeServer()
                            end)
                            task.wait(0.5)
                        end

                        -- กลับไปฟาร์ม
                        fastTravelTo(merchantWP, farmWP)
                        task.wait(2)
                        if panPos then
                            moveToPositionSpeed(panPos, walkSpeedValue)
                        end
                    else
                        warn("[Auto-Sell] ไม่เจอ waypoint ที่ใกล้ merchant หรือ panPos")
                    end
                end
            end
            task.wait(1)
        end
    end)
end)

local btns = serv:Channel("FastTravel")

btns:Button(
    "goto Rubble Creek",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Caldera Island"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto Fortune River",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Fortune River")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto Sunset Beach",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Sunset Beach")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto Fortune River Delta",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Fortune River Delta")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto Crystal Caverns",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Crystal Caverns")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto Caldera Island",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Caldera Island")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto Windswept Beach",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Windswept Beach")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto The Magma Furnace",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("The Magma Furnace")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto Frozen Peak",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Frozen Peak")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

btns:Button(
    "goto Snowy Shores",
    function()
local args = {
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
    workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Snowy Shores")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end
)

-- ตารางเก็บระดับไอเท็ม
local ItemTables = {
    Common = {"Pyrite", "Silver", "Copper" , "Gold", "Platinum", "Seashell", "Obsidian", "Amethyst", "Pearl"},
    Uncommon = {"Titanium", "Neodymium", "Topaz", "Smoky Quartz", "Malachite", "Coral", "Sapphire", "Zircon"},
    Rare = {"Ruby", "Lapis Lazuli", "Jade", "Silver Clamshell", "Peridot", "Onyx", "Meteoric Iron", "Azuralite", "Pyrelith"},
    Epic = {"Iridium", "Moonstone", "Ammonite Fossil", "Ashvein", "Pyronium", "Emerald", "Golden Pearl", "Borealite", "Osmium", "Opal", "Aurorite"},
    Legendary = {"Rose Gold", "Palladium", "Cinnabar", "Diamond", "Uranium", "Luminum", "Volcanic Key", "Fire Opal", "Dragon Bone", "Catseye", "Starshine", "Aetherite"},
    Mythic = {"Pink Diamond", "Painite", "Inferlume", "Vortessence", "Prismara", "Flarebloom", "Volcanic Core"},
    Exotic = {"Dinosaur Skull"}
}

-- Dropdown เลือกระดับ
local levels = {"None", "Common","Uncommon","Rare","Epic","Legendary","Mythic","Exotic"}
local selectedLevel = "Common"

local drops = serv:Channel("lock item")

drops:Dropdown("Select Level", levels, function(level)
    selectedLevel = level
end)

drops:Dropdown("Select Level", levels, function(level)
    selectedLevel = level
end)

drops:Dropdown("Select Level", levels, function(level)
    selectedLevel = level
end)

drops:Dropdown("Select Level", levels, function(level)
    selectedLevel = level
end)

drops:Dropdown("Select Level", levels, function(level)
    selectedLevel = level
end)

drops:Dropdown("Select Level", levels, function(level)
    selectedLevel = level
end)

drops:Dropdown("Select Level", levels, function(level)
    selectedLevel = level
end)


local lockedCache = {} 

local function lockItemsInLevel(level)
    local items = ItemTables[level]
    if not items then return end

    for _, tool in ipairs(plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, targetName in ipairs(items) do
                if tool.Name == targetName then
                    local isLocked = tool:GetAttribute("Locked")

                    -- ถ้ายังไม่เคยล็อค หรือ attribute ยังไม่ได้เป็น true
                    if not isLocked and not lockedCache[tool] then
                        pcall(function()
                            RepStorage:WaitForChild("Remotes")
                                :WaitForChild("Inventory")
                                :WaitForChild("ToggleLock")
                                :FireServer(tool)
                        end)
                        lockedCache[tool] = true 
                        print("[Lock] Locked:", tool.Name)
                    end
                end
            end
        end
    end
end

local runningLock = false
drops:Toggle("Auto Lock", false, function(state)
    runningLock = state
    if state then
        task.spawn(function()
            while runningLock do
                lockItemsInLevel(selectedLevel)
                task.wait(2) 
            end
        end)
    else
        lockedCache = {} 
    end
end)


local walkSpeedOptions = {16, 20, 22, 25}

tgls:Dropdown("WalkSpeed", walkSpeedOptions, function(selected)
    walkSpeedValue = selected
end)

tgls:Button("Change WalkSpeed", function()
    if humanoid then
        humanoid.WalkSpeed = walkSpeedValue
        print("WalkSpeed updated to:", walkSpeedValue)
    end
end)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local disUI = CoreGui:FindFirstChild("Discord")

local toggleUI = Instance.new("ScreenGui")
toggleUI.Name = "Uigame"
toggleUI.ResetOnSpawn = false
toggleUI.IgnoreGuiInset = true
toggleUI.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 45)
button.Position = UDim2.new(1, -150, 1, -400)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Text = "Toggle UI"
button.Parent = toggleUI

button.MouseButton1Click:Connect(function()
    disUI.Enabled = not disUI.Enabled
    button.Text = disUI.Enabled and "Disabled Ui" or "Enabled UI"
end)
