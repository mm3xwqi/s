local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local hrp = player.Character and player.Character:WaitForChild("HumanoidRootPart")




local lib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt")()

local win = lib:Window("PREVIEW",Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

local tab = win:Tab("Auto")

local teleporting = false

tab:Toggle("Auto Teleport Entities", false, function(state)
    teleporting = state
    if teleporting then
        task.spawn(function()
            while teleporting do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    hrp = player.Character.HumanoidRootPart
                    for _, entity in ipairs(workspace.Entities:GetChildren()) do
                        if entity:IsA("Model") and entity:FindFirstChild("HumanoidRootPart") then
                            hrp.CFrame = entity.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                            task.wait(.1)
                        elseif entity:IsA("BasePart") then
                            hrp.CFrame = entity.CFrame * CFrame.new(0, 2, 4)
                            task.wait(.1)
                        end
                    end
                end
                task.wait(.1)
            end
        end)
    end
end)

local attacking = false

tab:Toggle("Auto Attack", false, function(state)
    attacking = state
    if attacking then
        task.spawn(function()
            while attacking do
                local args = {
                    buffer.fromstring("\a\001\001"),
                    { os.clock() }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(unpack(args))
                task.wait(0.00001)
            end
        end)
    end
end)

local teleportingDrops = false

tab:Toggle("Auto Collect", false, function(state)
    teleportingDrops = state
    if teleportingDrops then
        task.spawn(function()
            while teleportingDrops do
                local player = game.Players.LocalPlayer
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp then
                    for _, drop in ipairs(workspace.DropItems:GetChildren()) do
                        if drop:IsA("Model") and drop.PrimaryPart then
                            hrp.CFrame = drop.PrimaryPart.CFrame
                        elseif drop:IsA("BasePart") then
                            hrp.CFrame = drop.CFrame
                        end
                    end
                end
                task.wait(.1)
            end
        end)
    end
end)

local tabb = win:Tab("World 1")
local autoRadio = false

tabb:Toggle("Auto Radio", false, function(state)
    autoRadio = state

    if autoRadio then
        task.spawn(function()
            local player = game.Players.LocalPlayer

            while autoRadio do
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                local radioModel = workspace:FindFirstChild("School")
                    and workspace.School.Rooms:FindFirstChild("RooftopBoss")
                    and workspace.School.Rooms.RooftopBoss.StaticProps:FindFirstChild("jarst_radio")

                if hrp and radioModel then
                    local targetPart = radioModel.PrimaryPart or radioModel:FindFirstChildWhichIsA("BasePart")
                    if targetPart then
                        hrp.CFrame = targetPart.CFrame 

                        local prompt = radioModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            task.wait(0.05)
                            fireproximityprompt(prompt)
                        end
                    end
                end

                task.wait(0.1)
            end
        end)
    end
end)

local tabs = win:Tab("World 2")
