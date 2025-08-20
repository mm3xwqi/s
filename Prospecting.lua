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
local win = DiscordLib:Window("MM</>4.1")
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
local PanSpeed = 28
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
    Common = {"Pyrite", "Silver", "Copper", "Gold", "Platinum", "Seashell", "Obsidian", "Amethyst", "Pearl", "Blue Ice"},
    Uncommon = {"Titanium", "Neodymium", "Topaz", "Smoky Quartz", "Malachite", "Coral", "Sapphire", "Zircon"},
    Rare = {"Ruby", "Lapis Lazuli", "Jade", "Silver Clamshell", "Peridot", "Onyx", "Meteoric Iron", "Azuralite", "Pyrelith", "Glacial Quartz"},
    Epic = {"Iridium", "Moonstone", "Ammonite Fossil", "Ashvein", "Pyronium", "Emerald", "Golden Pearl", "Borealite", "Osmium", "Opal", "Aurorite", "Cobalt"},
    Legendary = {"Rose Gold", "Palladium", "Cinnabar", "Diamond", "Uranium", "Luminum", "Volcanic Key", "Fire Opal", "Dragon Bone", "Catseye", "Starshine", "Aetherite", "Tourmaline", "Aquamarine"},
    Mythic = {"Pink Diamond", "Painite", "Inferlume", "Vortessence", "Prismara", "Flarebloom", "Volcanic Core", "Frostshard", "Mythril"},
    Exotic = {"Dinosaur Skull", "Cryonic Artifact"}
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
    print("[Check Inventory] " .. current .. "/" .. max .. " | AutoSellAt: " .. autoSellAtCount)
    if max == 0 then return false end
    return current >= max or current >= autoSellAtCount
end

-- Find Closest Merchant
local function findClosestMerchant()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local npcsFolder = workspace:WaitForChild("NPCs")
    local closest, closestDist = nil, math.huge

    for _, islandFolder in ipairs(npcsFolder:GetChildren()) do
        for _, npc in ipairs(islandFolder:GetChildren()) do
            if npc.Name:match("Merchant") and npc:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
                if dist < 300 and dist < closestDist then
                    closest, closestDist = npc, dist
                end
            end
        end
    end

    if not closest then
        for _, islandFolder in ipairs(npcsFolder:GetChildren()) do
            for _, npc in ipairs(islandFolder:GetChildren()) do
                if npc.Name:match("Merchant") and npc:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closest, closestDist = npc, dist
                    end
                end
            end
        end
    end

    return closest
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
        panPos = plr.Character.HumanoidRootPart.Position + Vector3.new(0,0,0)
        print("[Auto Pan] Saved pan position:", panPos)
    end
end)

tgls:Button("saveshake", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        shakePos = plr.Character.HumanoidRootPart.Position + Vector3.new(0,0,0)
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
        local hrp = character:WaitForChild("HumanoidRootPart")

        while runningPanShake do
            if not panPos then
                task.wait(0.1)
                continue
            end

            local panTool = equipPan()
            if not panTool then
                task.wait(0.1)
                continue
            end

            local current, max = getFillValues()
            while current < max and runningPanShake do
                local bv = Instance.new("BodyVelocity")
                bv.Name = "Lock"
                bv.Parent = hrp
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(0,0,0)

                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                local distance = (panPos - hrp.Position).Magnitude
                local tweenTime = distance / PanSpeed
                local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(panPos)})
                tween:Play()
                tween.Completed:Wait()

                pcall(function()
                    panTool:WaitForChild("Scripts"):WaitForChild("Collect"):InvokeServer(1)
                end)
                task.wait(0.1)
                current, max = getFillValues()

                if bv and bv.Parent then bv:Destroy() end
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end

            if shakePos then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "Lock"
                bv.Parent = hrp
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Velocity = Vector3.new(0,0,0)

                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end

                local distance = (shakePos - hrp.Position).Magnitude
                local tweenTime = distance / PanSpeed
                local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(shakePos)})
                tween:Play()
                tween.Completed:Wait()

                current, max = getFillValues()
                while current > 0 and runningPanShake do
                    local scriptsFolder = panTool:FindFirstChild("Scripts")
                    if scriptsFolder then
                        local shakeEvent = scriptsFolder:FindFirstChild("Shake")
                        if shakeEvent then shakeEvent:FireServer() end

                        local panEvent = scriptsFolder:FindFirstChild("Pan")
                        if panEvent then panEvent:InvokeServer() end
                    end
                    task.wait(0.1)
                    current, max = getFillValues()
                end

                if bv and bv.Parent then bv:Destroy() end
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
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
        local hrp = character:WaitForChild("HumanoidRootPart")

        while runningSell do
            -- เช็คว่าของในกระเป๋าถึงเกณฑ์ขายมั้ย
            local current, max = getFillValues()
            if current >= autoSellAtCount then
                print("[Auto-Sell] เริ่มขาย -> ของในกระเป๋า:", current)

                -- วนจนกว่าของในกระเป๋าจะเหลือ 0
                while current > 0 and runningSell do
                    local merchant = findClosestMerchant()
                    if merchant and merchant:FindFirstChild("HumanoidRootPart") then
                        -- Warp ไป Merchant
                        hrp.CFrame = merchant.HumanoidRootPart.CFrame + Vector3.new(0,3,0)

                        -- กดขาย
                        pcall(function()
                            RepStorage.Remotes.Shop.SellAll:InvokeServer()
                        end)

                        task.wait(0.3) -- เวลารอให้เซิร์ฟประมวลผล
                    else
                        print("[Auto-Sell] ❌ ไม่เจอ Merchant")
                        task.wait(1)
                    end

                    -- อัปเดตจำนวนของในกระเป๋า
                    current, max = getFillValues()
                end

                print("[Auto-Sell] ✅ ขายเสร็จ ของในกระเป๋า = 0")

                -- กลับไป Pan Position ถ้ามี
                if panPos then
                    hrp.CFrame = CFrame.new(panPos + Vector3.new(0,3,0))
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

local shp = serv:Channel("Shop")

shp:Button("Buy Basic Luck Potion", function()
    local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("RiverTown"):WaitForChild("Basic Luck Potion"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

shp:Button("Buy Basic Capacity Potion", function()
local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("RiverTown"):WaitForChild("Basic Capacity Potion"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

shp:Button("Buy Greater Luck Potion", function()
local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("RiverTown"):WaitForChild("Greater Luck Potion"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

shp:Button("Buy Greater Capacity Potion", function()
local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("RiverTown"):WaitForChild("Greater Capacity Potion"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

shp:Button("Buy Volcanic Luck Potion", function()
local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("Volcano"):WaitForChild("Volcanic Luck Potion"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

shp:Button("Buy Volcanic Strength Potion", function()
local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("Volcano"):WaitForChild("Volcanic Strength Potion"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

shp:Button("Buy Volcanic Strength Potion", function()
local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("Volcano"):WaitForChild("Volcanic Strength Potion"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

shp:Button("Buy Luck Totem", function()
local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("RiverTown"):WaitForChild("Luck Totem"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

shp:Button("Buy Strength Totem", function()
local args = {
	workspace:WaitForChild("Purchasable"):WaitForChild("RiverTown"):WaitForChild("Strength Totem"):WaitForChild("ShopItem")
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
end)

