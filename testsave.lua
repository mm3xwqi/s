local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local char = player.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local ByteNetReliable = RepStorage:WaitForChild("ByteNetReliable")

-- Skill system
local skillStates = {Z=false, X=false, C=false, E=false, G=false}
local lastUsed = {Z=0, X=0, C=0, E=0, G=0}
local skillCooldown = 2

-- Config folder/file
local configFolder = "configs"
local configFile = configFolder .. "/settings.json"

if not isfolder(configFolder) then
    makefolder(configFolder)
end

local function loadConfig()
    if isfile(configFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(configFile))
        end)
        if success and type(data) == "table" then
            return data
        end
    end
    return {}
end

local function saveConfig(settings)
    writefile(configFile, HttpService:JSONEncode(settings))
end

local settings = loadConfig()

-- UI library
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("MW v1.05 Beta", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

-- Auto tab
local tab = win:Tab("Auto")

local teleporting = settings["AutoTeleportEntities"] or false
tab:Toggle("Auto Teleport Entities", teleporting, function(state)
    teleporting = state
    settings["AutoTeleportEntities"] = state
    saveConfig(settings)
    if teleporting then
        task.spawn(function()
            while teleporting do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    hrp = player.Character.HumanoidRootPart
                    for _, entity in ipairs(workspace.Entities:GetChildren()) do
                        if entity:IsA("Model") and entity:FindFirstChild("HumanoidRootPart") then
                            hrp.CFrame = entity.HumanoidRootPart.CFrame * CFrame.new(0,2,3)
                            task.wait(.1)
                        elseif entity:IsA("BasePart") then
                            hrp.CFrame = entity.CFrame * CFrame.new(0,2,3)
                            task.wait(.1)
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end)

local attacking = settings["AutoAttack"] or false
tab:Toggle("Auto Attack", attacking, function(state)
    attacking = state
    settings["AutoAttack"] = state
    saveConfig(settings)
    if attacking then
        task.spawn(function()
            while attacking do
                local args = {buffer.fromstring("\a\001\001"), {os.clock()}}
                ByteNetReliable:FireServer(unpack(args))
                task.wait()
            end
        end)
    end
end)

local teleportingDrops = settings["AutoCollect"] or false
tab:Toggle("Auto Collect", teleportingDrops, function(state)
    teleportingDrops = state
    settings["AutoCollect"] = state
    saveConfig(settings)
    if teleportingDrops then
        task.spawn(function()
            while teleportingDrops do
                if hrp then
                    for _, drop in ipairs(workspace.DropItems:GetChildren()) do
                        if drop:IsA("Model") and drop.PrimaryPart then
                            hrp.CFrame = drop.PrimaryPart.CFrame
                        elseif drop:IsA("BasePart") then
                            hrp.CFrame = drop.CFrame
                        end
                    end
                end
                task.wait(.2)
            end
        end)
    end
end)

-- Skill tab
local tabd = win:Tab("Skill")
for _, skill in ipairs({"Z","X","C","E","G"}) do
    local skillKey = "Skill"..skill
    local default = settings[skillKey] or false
    tabd:Toggle("Skill "..skill, default, function(state)
        skillStates[skill] = state
        settings[skillKey] = state
        saveConfig(settings)
    end)
end

local function useSkill(skill)
    local args
    if skill == "Z" then
        args = {buffer.fromstring("\a\003\001"), {1756116897.145503}}
    elseif skill == "X" then
        args = {buffer.fromstring("\a\005\001"), {1756116899.176199}}
    elseif skill == "C" then
        args = {buffer.fromstring("\a\006\001"), {1756116902.587347}}
    elseif skill == "E" then
        args = {buffer.fromstring("\v")}
    elseif skill == "G" then
        args = {buffer.fromstring("\a\a\001"), {1756116983.926151}}
    end
    if args then
        ByteNetReliable:FireServer(unpack(args))
    end
end

RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    for skill, state in pairs(skillStates) do
        if state and (currentTime - lastUsed[skill] >= skillCooldown) then
            useSkill(skill)
            lastUsed[skill] = currentTime
        end
    end
end)

-- Toggle UI button
local ui = CoreGui:WaitForChild("ui")
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "ToggleUI"
toggleGui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,120,0,45)
button.Position = UDim2.new(1,-150,1,-400)
button.BackgroundColor3 = Color3.fromRGB(50,50,50)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Text = "Toggle UI"
button.Parent = toggleGui

local uiEnabled = settings["UIEnabled"]
if uiEnabled ~= nil then
    ui.Enabled = uiEnabled
    button.Text = ui.Enabled and "UI: ON" or "UI: OFF"
end

button.MouseButton1Click:Connect(function()
    if ui then
        ui.Enabled = not ui.Enabled
        button.Text = ui.Enabled and "UI: ON" or "UI: OFF"
        settings["UIEnabled"] = ui.Enabled
        saveConfig(settings)
    end
end)
