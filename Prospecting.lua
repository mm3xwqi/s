--==================================================
-- Services
--==================================================
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")

--==================================================
-- Player
--==================================================
local plr = Players.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local walkSpeedValue = humanoid.WalkSpeed

--==================================================
-- UI Library
--==================================================
local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()
local win = DiscordLib:Window("MM</>2.8")
local serv = win:Server("Main", "")
local tgls = serv:Channel("Main")
local btns = serv:Channel("FastTravel")
local drops = serv:Channel("lock item")

--==================================================
-- Variables
--==================================================
local panPos, shakePos = nil, nil
local args = {1}
local runningPan, runningShake, runningSell = false, false, false
local fillTextObj = nil
local runningPanShake = false
local runningLock = false
local lockedCache = {}
local autoSellAtCount = 500
local tweenSpeed = 25
local Pan = {
    "Rusty Pan", "Plastic Pan", "Metal Pan", "Silver Pan", "Golden Pan", 
    "Magnetic Pan", "Meteoric Pan", "Diamond Pan", "Aurora Pan", 
    "Worldshaker", "Dragonflame Pan", "Fossilized Pan"
}
local localMerchant = {"StarterTown", "Beach", "Cavern", "Delta", "Mountain", "RiverTown", "Volcano"}
local merchantToIsland = {
    StarterTown = "Rubble Creek",
    Beach = "Sunset Beach",
    Cavern = "Crystal Caverns",
    Delta = "Fortune River Delta",
    Mountain = "Frozen Peak",
    RiverTown = "Fortune River",
    Volcano = "The Magma Furnace"
}
local levels = {"None", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exotic"}
local selectedLevel = "Common"
local walkSpeedOptions = {16, 20, 22, 25}

--==================================================
-- Item Tables
--==================================================
local ItemTables = {
    Common = {"Pyrite", "Silver", "Copper", "Gold", "Platinum", "Seashell", "Obsidian", "Amethyst", "Pearl"},
    Uncommon = {"Titanium", "Neodymium", "Topaz", "Smoky Quartz", "Malachite", "Coral", "Sapphire", "Zircon"},
    Rare = {"Ruby", "Lapis Lazuli", "Jade", "Silver Clamshell", "Peridot", "Onyx", "Meteoric Iron", "Azuralite", "Pyrelith"},
    Epic = {"Iridium", "Moonstone", "Ammonite Fossil", "Ashvein", "Pyronium", "Emerald", "Golden Pearl", "Borealite", "Osmium", "Opal", "Aurorite"},
    Legendary = {"Rose Gold", "Palladium", "Cinnabar", "Diamond", "Uranium", "Luminum", "Volcanic Key", "Fire Opal", "Dragon Bone", "Catseye", "Starshine", "Aetherite"},
    Mythic = {"Pink Diamond", "Painite", "Inferlume", "Vortessence", "Prismara", "Flarebloom", "Volcanic Core"},
    Exotic = {"Dinosaur Skull"}
}

--==================================================
-- Functions
--==================================================

-- Equip Pan
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

-- Tween to Position
local function tweenToPosition(pos, speed)
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (hrp.Position - pos).Magnitude
    local tweenInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- Get Fill Values
local function getFillValues()
    local fillTextObj = plr.PlayerGui:WaitForChild("ToolUI"):WaitForChild("FillingPan"):WaitForChild("FillText")
    local text = fillTextObj:FindFirstChild("ContentText") and fillTextObj.ContentText or fillTextObj.Text or ""
    local current, max = text:match("([%d%.]+)%s*/%s*([%d%.]+)")
    return tonumber(current) or 0, tonumber(max) or 0
end

-- Inventory Size & Check
local function getInventorySize()
    local invGui = plr.PlayerGui:FindFirstChild("BackpackGui") and
                   plr.PlayerGui.BackpackGui:FindFirstChild("Backpack") and
                   plr.PlayerGui.BackpackGui.Backpack:FindFirstChild("Inventory") and
                   plr.PlayerGui.BackpackGui.Backpack.Inventory:FindFirstChild("TopButtons") and
                   plr.PlayerGui.BackpackGui.Backpack.Inventory.TopButtons:FindFirstChild("Unaffected") and
                   plr.PlayerGui.BackpackGui.Backpack.Inventory.TopButtons.Unaffected:FindFirstChild("InventorySize")
    if invGui and invGui:IsA("TextLabel") then
        local current, max = invGui.Text:match("(%d+)%s*/%s*(%d+)")
        if current and max then return tonumber(current), tonumber(max) end
    end
    return 0, 0
end

local function isInventoryFull()
    local current, max = getInventorySize()
    return current >= autoSellAtCount and max > 0
end

-- FastTravel Remote
local function fastTravelToIslandRemote(destination)
    local destWP = workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild(destination)
    if destWP then
        local args = {destWP}
        RepStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
        print("[FastTravel] วาปไปเกาะ:", destination)
    else
        warn("[FastTravel] ไม่พบ waypoint ของเกาะ:", destination)
    end
end

-- Find Closest Merchant
local function findClosestMerchantAndIsland()
    local closest, merchantFolderName
    local shortestDist = math.huge
    local islandName = nil
    for _, folderName in ipairs(localMerchant) do
        local npcFolder = workspace:WaitForChild("NPCs"):FindFirstChild(folderName)
        if npcFolder then
            for _, npc in ipairs(npcFolder:GetChildren()) do
                if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc.Name:lower():find("merchant") then
                    local dist = (plr.Character.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = npc
                        merchantFolderName = folderName
                        islandName = merchantToIsland[folderName] or folderName
                    end
                end
            end
        end
    end
    return closest, islandName
end

-- Lock Items
local function lockItemsInLevel(level)
    local items = ItemTables[level]
    if not items then return end
    for _, tool in ipairs(plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, targetName in ipairs(items) do
                if tool.Name == targetName then
                    local isLocked = tool:GetAttribute("Locked")
                    if not isLocked and not lockedCache[tool] then
                        pcall(function()
                            RepStorage:WaitForChild("Remotes"):WaitForChild("Inventory"):WaitForChild("ToggleLock"):FireServer(tool)
                        end)
                        lockedCache[tool] = true
                        print("[Lock] Locked:", tool.Name)
                    end
                end
            end
        end
    end
end

-- Discord UI Toggle Button
local disUI = CoreGui:FindFirstChild("Discord")
local toggleUI = Instance.new("ScreenGui")
toggleUI.Name = "Uigame"
toggleUI.ResetOnSpawn = false
toggleUI.IgnoreGuiInset = true
toggleUI.Parent = plr:WaitForChild("PlayerGui")

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

-- Check Discord Instances & Auto-Rejoin
local function checkDiscordInstances()
    local count = 0
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui.Name == "Discord" then count = count + 1 end
    end
    return count
end

local discordCount = checkDiscordInstances()
if discordCount == 2 then
    warn("[Auto-Rejoin] พบ Discord 2 อัน! กำลัง Rejoin...")
    task.wait(0.5)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, plr)
    end)
end

--==================================================
-- GUI & Toggles
--==================================================

-- Save Pan / Shake Buttons
tgls:Button("savepan", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        panPos = plr.Character.HumanoidRootPart.Position + Vector3.new(0,3,0)
        print("[Auto Pan] Saved pan position:", panPos)
    end
end)

tgls:Button("saveshake", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        shakePos = plr.Character.HumanoidRootPart.Position + Vector3.new(0,3,0)
        print("[Auto Pan] Saved shake position:", shakePos)
    end
end)

-- WalkSpeed Dropdown & Button
tgls:Dropdown("WalkSpeed", walkSpeedOptions, function(selected)
    walkSpeedValue = selected
end)

tgls:Button("Change WalkSpeed", function()
    if humanoid then
        humanoid.WalkSpeed = walkSpeedValue
        print("WalkSpeed updated to:", walkSpeedValue)
    end
end)

-- Level Lock Dropdowns
for i = 1, 8 do
    drops:Dropdown("Select Level", levels, function(level)
        selectedLevel = level
    end)
end

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

--==================================================
-- Auto-Pan & Shake
--==================================================
tgls:Toggle("Auto-Pan & Shake", false, function(state)
    runningPanShake = state
    task.spawn(function()
        while runningPanShake do
            -- รอ Auto-Sell เสร็จก่อน
            while runningSell and isInventoryFull() do
                task.wait(0.5)
            end
            if not panPos then task.wait(1) continue end
            tweenToPosition(panPos, 150)
            local panTool = equipPan()
            if panTool then
                -- ขุดจนเต็ม
                local current, max = getFillValues()
                while current < max and runningPanShake do
                    pcall(function()
                        panTool:WaitForChild("Scripts"):WaitForChild("Collect"):InvokeServer(0.1)
                    end)
                    task.wait(0.3)
                    current, max = getFillValues()
                end
                -- Tween ไป Shake
                if shakePos then tweenToPosition(shakePos, 150) end
                -- เขย่า + Pan จนหมด
                current, max = getFillValues()
                while current > 0 and runningPanShake do
                    local scriptsFolder = panTool:FindFirstChild("Scripts")
                    if scriptsFolder then
                        local shakeEvent = scriptsFolder:FindFirstChild("Shake")
                        if shakeEvent then shakeEvent:FireServer() end
                        local panEvent = scriptsFolder:FindFirstChild("Pan")
                        if panEvent then panEvent:InvokeServer() end
                    end
                    task.wait(0.3)
                    current, max = getFillValues()
                end
                -- Tween กลับ Pan
                tweenToPosition(panPos, 150)
            end
            task.wait(0.5)
        end
    end)
end)

--==================================================
-- Auto-Sell
--==================================================
tgls:Slider("Auto-Sell At", 1, 500, autoSellAtCount, function(value)
    autoSellAtCount = value
    print("[Auto-Sell] จะขายเมื่อกระเป๋ามีไอเท็ม:", autoSellAtCount)
end)

tgls:Toggle("Auto-Sell", false, function(state)
    runningSell = state
    task.spawn(function()
        while runningSell do
            if isInventoryFull() then
                print("[Auto-Sell] กระเป๋าเต็ม! หา Merchant...")
                local merchant, islandName = findClosestMerchantAndIsland()
                if merchant and islandName then
                    fastTravelToIslandRemote(islandName)
                    task.wait(2)
                    tweenToPosition(merchant.HumanoidRootPart.Position, 150)
                    while isInventoryFull() and runningSell do
                        pcall(function()
                            RepStorage:WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("SellAll"):InvokeServer()
                        end)
                        task.wait(0.5)
                    end
                    if panPos then
                        fastTravelToIslandRemote("Rubble Creek")
                        task.wait(2)
                        tweenToPosition(panPos, 150)
                    end
                else
                    print("[Auto-Sell] ไม่พบ Merchant รอ 2 วิแล้วลองใหม่")
                    task.wait(2)
                end
            end
            task.wait(1)
        end
    end)
end)

--==================================================
-- FastTravel Buttons
--==================================================
local function setupFastTravelButton(name, dest)
    btns:Button(name, function()
        local args = {
            workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild("Rubble Creek"),
            workspace:WaitForChild("Map"):WaitForChild("Waypoints"):WaitForChild(dest)
        }
        RepStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("FastTravel"):FireServer(unpack(args))
    end)
end

local islands = {
    "Rubble Creek", "Fortune River", "Sunset Beach", "Fortune River Delta",
    "Crystal Caverns", "Caldera Island", "Windswept Beach", "The Magma Furnace",
    "Frozen Peak", "Snowy Shores", "Frostbitten Path"
}

for _, island in ipairs(islands) do
    setupFastTravelButton("goto " .. island, island)
end

btns:Button("Unlock travel", function()
    local character = plr.Character or plr.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local waypoints = workspace:WaitForChild("Map"):WaitForChild("Waypoints")
    for _, waypoint in pairs(waypoints:GetChildren()) do
        local pos
        if waypoint:IsA("Model") then
            pos = waypoint:GetPivot().Position
        elseif waypoint:IsA("BasePart") then
            pos = waypoint.Position
        end
        if pos then
            hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
            for _, prompt in pairs(waypoint:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt, math.huge)
                end
            end
            task.wait(0.1)
        end
    end
end)
