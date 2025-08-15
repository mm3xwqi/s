local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()
local win = DiscordLib:Window("MM</>1.4")

local serv = win:Server("Preview", "")
local tgls = serv:Channel("Toggles")

local TweenService = game:GetService("TweenService")
local plr = game:GetService("Players").LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local character = plr.Character or plr.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local panPos, shakePos = nil, nil
local args = {1}
local running, runningShake, runningSell = false, false, false
local fillTextObj = nil
local walkSpeedValue = humanoid.WalkSpeed 
local Pan = {"Rusty Pan", "Plastic Pan", "Metal Pan",  "Silver Pan", "Golden Pan", "Magnetic Pan", "Meteoric Pan", "Diamond Pan", "Aurora Pan", "Worldshaker", "Dragonflame Pan", "Fossilized Pan"}
local Common = {"Pyrite", "Silver", "Copper" , "Gold", "Platinum", "Seashell", "Obsidian", "Amethyst", "Pearl"} 
local Uncommon = {"Titanium", "Neodymium", "Topaz", "Smoky Quartz", "Malachite", "Coral", "Sapphire", "Zircon"} 
local Rare = {"Ruby", "Lapis Lazuli", "Jade", "Silver Clamshell", "Peridot", "Onyx", "Meteoric Iron", "Azuralite", "Pyrelith"} 
local Epic = {"Iridium", "Moonstone", "Ammonite Fossil", "Ashvein", "Pyronium", "Emerald", "Golden Pearl", "Borealite", "Osmium", "Opal", "Aurorite"} 
local Legendary = {"Rose Gold", "Palladium", "Cinnabar", "Diamond", "Uranium", "Luminum", "Volcanic Key", "Fire Opal", "Dragon Bone", "Catseye", "Starshine", "Aetherite"} 
local Mythic = {"Pink Diamond", "Painite", "Inferlume", "Vortessence", "Prismara", "Flarebloom", "Volcanic Core"} 
local Exotic = {"Dinosaur Skull"}

-- Equip Pan จากตาราง Pan
local function equipPan()
    for _, panName in ipairs(Pan) do
        local tool = character:FindFirstChild(panName) or plr.Backpack:FindFirstChild(panName)
        if tool and tool:IsA("Tool") then
            tool.Parent = character
            task.wait(0.1)
            print("[Auto Pan] Equipped:", tool.Name)
            return tool
        end
    end
    print("[Auto Pan] No Pan found in table!")
    return nil
end

-- walkto
local function moveToPositionSpeed(pos, speed)
    if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
        local humanoid = plr.Character.Humanoid
        local hrp = plr.Character.HumanoidRootPart
        local distance = (pos - hrp.Position).Magnitude
        humanoid:MoveTo(pos)
        local timeout = distance / speed
        local elapsed = 0
        while (hrp.Position - pos).Magnitude > 2 and elapsed < timeout do
            task.wait(0.1)
            elapsed = elapsed + 0.1
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
    running = state
    task.spawn(function()
        while running do
            local panTool = equipPan()  -- equipPan() จะคืน Tool ที่ถือแล้ว
            if panTool then
                local fillTextObj = plr.PlayerGui:FindFirstChild("ToolUI")
                    and plr.PlayerGui.ToolUI:FindFirstChild("FillingPan")
                    and plr.PlayerGui.ToolUI.FillingPan:FindFirstChild("FillText")

                if fillTextObj then
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
                end
            end
            task.wait(0.2)
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
            task.wait(0.1)
        end
    end)
end)

local sellSpeed = 300 

local function findClosestMerchant()
    local closest = nil
    local shortestDist = math.huge
    for _, folder in ipairs(Workspace.NPCs:GetChildren()) do
        for _, npc in ipairs(folder:GetChildren()) do
            if npc:IsA("Model") and npc.Name == "Merchant" and npc:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = npc
                end
            end
        end
    end
    return closest
end

local function moveToTarget(pos, speed)
    if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
        local humanoid = plr.Character.Humanoid
        local hrp = plr.Character.HumanoidRootPart
        local distance = (pos - hrp.Position).Magnitude
        humanoid:MoveTo(pos)
        local timeout = distance / speed
        local elapsed = 0
        while (hrp.Position - pos).Magnitude > 3 and elapsed < timeout do
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end
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
        if current then
            return tonumber(current)
        end
    end
    return 0
end

tgls:Toggle("Auto-Sell", false, function(state)
    runningSell = state
    task.spawn(function()
        while runningSell do
            local invCount = getInventorySize()
            if invCount >= 500 then
                local merchant = findClosestMerchant()
                if merchant and merchant:FindFirstChild("HumanoidRootPart") then
                    moveToTarget(merchant.HumanoidRootPart.Position, sellSpeed)
                    pcall(function()
                        RepStorage:WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("SellAll"):InvokeServer()
                    end)
                end
            end
            task.wait(2) 
        end
    end)
end)


local ItemTables = {
    Common = {"Pyrite", "Silver", "Copper" , "Gold", "Platinum", "Seashell", "Obsidian", "Amethyst", "Pearl"},
    Uncommon = {"Titanium", "Neodymium", "Topaz", "Smoky Quartz", "Malachite", "Coral", "Sapphire", "Zircon"},
    Rare = {"Ruby", "Lapis Lazuli", "Jade", "Silver Clamshell", "Peridot", "Onyx", "Meteoric Iron", "Azuralite", "Pyrelith"},
    Epic = {"Iridium", "Moonstone", "Ammonite Fossil", "Ashvein", "Pyronium", "Emerald", "Golden Pearl", "Borealite", "Osmium", "Opal", "Aurorite"},
    Legendary = {"Rose Gold", "Palladium", "Cinnabar", "Diamond", "Uranium", "Luminum", "Volcanic Key", "Fire Opal", "Dragon Bone", "Catseye", "Starshine", "Aetherite"},
    Mythic = {"Pink Diamond", "Painite", "Inferlume", "Vortessence", "Prismara", "Flarebloom", "Volcanic Core"},
    Exotic = {"Dinosaur Skull"}
}

-- Dropdown เลือกระดับไอเท็ม
local levels = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Exotic"}
local selectedLevel = "Common"

tgls:Dropdown("Select Level", levels, function(level)
    selectedLevel = level
    print("[Lock] Selected level:", selectedLevel)
end)

local function lockItemsInLevel(level)
    local items = ItemTables[level]
    if not items then return end

    for _, itemName in ipairs(items) do
        local tool = plr.Character:FindFirstChild(itemName)
        if tool then
            local isLocked = tool:GetAttribute("Locked")
            if not isLocked then
                pcall(function()
                    RepStorage:WaitForChild("Remotes")
                        :WaitForChild("Inventory")
                        :WaitForChild("ToggleLock")
                        :FireServer(tool)
                end)
                print("[Lock] Locked:", itemName)
            else
                print("[Lock] Already locked:", itemName)
            end
            task.wait(0.2) -- เว้นระยะระหว่างไอเท็ม
        end
    end
end

-- Toggle ล็อคไอเท็มทั้งหมดในระดับที่เลือก
local runningLock = false
tgls:Toggle("Auto Lock", false, function(state)
    runningLock = state
    task.spawn(function()
        while runningLock do
            lockItemsInLevel(selectedLevel)
            task.wait(2) -- เว้นรอบเช็ค
        end
    end)
end)


local walkSpeedOptions = {16, 20, 22, 25}

tgls:Dropdown("WalkSpeed", walkSpeedOptions, function(selected)
    walkSpeedValue = selected
    print("Selected WalkSpeed:", walkSpeedValue)
end)

tgls:Button("Change WalkSpeed", function()
    if humanoid then
        humanoid.WalkSpeed = walkSpeedValue
        print("WalkSpeed updated to:", walkSpeedValue)
    end
end)
