local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()

local win = DiscordLib:Window("Fisch-1.9.2")

local serv = win:Server("Main", "")

local tgls = serv:Channel("Auto")

local islandOptions = {}

-- Get all teleport islands in the game
for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
    if teleport_island:IsA("BasePart") then
        table.insert(islandOptions, teleport_island.Name)
    end
end

local player = game.Players.LocalPlayer
local character = player.Character
local humanoid = character and character:FindFirstChild("Humanoid")
local re = game.ReplicatedStorage
local PlayerGui = player:WaitForChild("PlayerGui")

getgenv().config = getgenv().config or {}
getgenv().config.auto_throw_rod = false

-- Auto Cast Toggle
tgls:Toggle(
    "Auto Cast", "Automatically throw the rod", function(state)
    if state then
        getgenv().config.auto_throw_rod = true
        spawn(function()
            while getgenv().config.auto_throw_rod do
                task.wait()

                local rod_name = re.playerstats[player.Name].Stats.rod.Value
                local equipped_rod = player.Character:FindFirstChild(rod_name)

                if equipped_rod and equipped_rod:FindFirstChild("events") and equipped_rod.events:FindFirstChild("cast") then
                    equipped_rod.events.cast:FireServer(math.random(1,100), 1)
                end
            end
        end)
    else
        getgenv().config.auto_throw_rod = false
    end
end)

getgenv().config = getgenv().config or {}
getgenv().config.SafeMode = false

tgls:Toggle(
    "Safe-Mode",
    false,
    function(state)
        if state then
            getgenv().config.SafeMode = true
            spawn(function()
                while getgenv().config.SafeMode do  
                    task.wait() 
                    -- Ensure PlayerGui and relevant paths exist before manipulating
                    local playerBar = PlayerGui:FindFirstChild("reel") and PlayerGui.reel:FindFirstChild("bar") and PlayerGui.reel.bar:FindFirstChild("playerbar")
                    local fish = PlayerGui:FindFirstChild("reel") and PlayerGui.reel:FindFirstChild("bar") and PlayerGui.reel.bar:FindFirstChild("fish")
                    if playerBar and fish then
                        playerBar.Position = UDim2.new(
                            fish.Position.X.Scale, 
                            fish.Position.X.Offset,
                            fish.Position.Y.Scale, 
                            fish.Position.Y.Offset
                        )
                    end
                end
            end)
        else
            -- Turn off SafeMode if the toggle is switched off
            getgenv().config.SafeMode = false
        end
    end
)

local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Auto Shake Toggle
tgls:Toggle(
    "Auto Shake", "Navigate", function(state)
    if state then
        getgenv().config.auto_shake = true

        spawn(function()
            while getgenv().config.auto_shake do
                task.wait()

                local playerGui = player:WaitForChild("PlayerGui")
                local shake_button = playerGui:FindFirstChild("shakeui") 
                    and playerGui.shakeui:FindFirstChild("safezone") 
                    and playerGui.shakeui.safezone:FindFirstChild("button")

                if shake_button then
                    shake_button.Selectable = true
                    GuiService.SelectedObject = shake_button 

                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil) -- Press Enter
                    task.wait()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil) -- Release Enter
                end
            end
        end)
    else
        getgenv().config.auto_shake = false
    end
end)

-- Auto Reel Toggle
tgls:Toggle(
    "Auto Reel", "ToggleInfo", function(state)
        if state then
            getgenv().config.auto_reel = true

            spawn(function()
                while getgenv().config.auto_reel do
                    task.wait()

                    local playerGui = player:FindFirstChild("PlayerGui")
                    if playerGui then
                        local reel = playerGui:FindFirstChild("reel")

                        if reel then
                            if re and re.events and re.events.reelfinished then
                                local success, errorMsg = pcall(function()
                                    -- Fire the reelfinished event
                                    re.events.reelfinished:FireServer(100, false)

                                    -- Reset event
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Auto Reel") then
                                        LocalPlayer.Character["Auto Reel"].events.reset:FireServer()
                                    end
                                end)

                                if not success then
                                    warn("Error during reelfinished event: " .. errorMsg)
                                end
                            else
                                warn("Reel or reelfinished event not found.")
                            end
                        else
                            warn("Reel GUI not found.")
                        end
                    else
                        warn("PlayerGui not found.")
                    end
                end
            end)
        else
            getgenv().config.auto_reel = false
        end
    end
)




-- SellAll-Loop Button
tgls:Button(
    "SellAll-Loop 10 sec",
    function()
        while true do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
            wait(10)
        end
    end
)

tgls:Button(
    "SellAll 1time",
    function()
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
    end
)

tgls:Button(
    "SellAll-Loop 1min",
    function()
        while true do
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
            wait(60)
        end
    end
)

-- Teleport Section
local serv2 = win:Server("Teleport", "")
local drops = serv2:Channel("tp-Islands")

local currentOption = nil

local drop = drops:Dropdown(
    "Island", islandOptions, function(option)
        currentOption = option
    end
)

drops:Button(
    "Teleport",
    function()
        if currentOption then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                for _, teleport_island in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
                    if teleport_island.Name == currentOption and teleport_island:IsA("BasePart") then
                        player.Character.HumanoidRootPart.CFrame = teleport_island.CFrame
                        return
                    end
                end
            end
        end
    end
)

local character = game.Players.LocalPlayer.Character
local newCFrame = CFrame.new(-4288.67333984375, -996.260498046875, 2168.24560546875) 

drops:Button(
    "KrakenPool",
    function()
character:WaitForChild("HumanoidRootPart").CFrame = newCFrame
    end
)

local btns = serv:Channel("Misc")
btns:Button(
    "anti-afk",
    function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/brosula123/Anti-afk/main/Bl%C3%B8xzScript"))()
    end
)

        btns:Button(
            "Fps-Boost(DeleteMap)",
            function()
                for i,v in next, workspace:GetDescendants() do
            pcall(function()
                v.Transparency = 1
            end)
        end
        for i,v in next, getnilinstances() do
            pcall(function()
                v.Transparency = 1
                for i1,v1 in next, v:GetDescendants() do
                    v1.Transparency = 1
                end
            end)
        end
        a = workspace
        a.DescendantAdded:Connect(function(v)
            pcall(function()
                v.Transparency = 1
            end)
        end)
    end
)
