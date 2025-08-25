local player = game.Players.LocalPlayer
local char = player.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")

local lib = loadstring(game:HttpGet"https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt")()

local win = lib:Window("MW V1 beta",Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)

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
                            task.wait()
                        elseif entity:IsA("BasePart") then
                            hrp.CFrame = entity.CFrame * CFrame.new(0, 2, 4)
                            task.wait()
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
                if hrp then
                    for _, drop in ipairs(workspace.DropItems:GetChildren()) do
                        if drop:IsA("Model") and drop.PrimaryPart then
                            hrp.CFrame = drop.PrimaryPart.CFrame
                        elseif drop:IsA("BasePart") then
                            hrp.CFrame = drop.CFrame
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end)

local tabb = win:Tab("World 1")
tabb:Toggle("Auto Radio", false, function(autoRadio)
    if autoRadio then
        task.spawn(function()
            -- รอจน Entities และ DropItems ว่าง
            repeat
                local hasModels = false
                for _, child in ipairs(workspace.Entities:GetChildren()) do
                    if child:IsA("Model") then
                        hasModels = true
                        break
                    end
                end
                local hasDrops = #workspace.DropItems:GetChildren() > 0
                task.wait(0.1)
            until not hasModels and not hasDrops or not autoRadio

            if not autoRadio then return end

            -- หา RadioObjective
            local radioPart = workspace.School.Rooms.RooftopBoss:FindFirstChild("RadioObjective")
            if hrp and radioPart and radioPart:IsA("BasePart") then
                local prompt = radioPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    while prompt.Enabled and autoRadio do
                        hrp.CFrame = radioPart.CFrame
                        fireproximityprompt(prompt)
                        task.wait()
                    end
                end
            end
        end)
    end
end)

tabb:Toggle("Auto Helicopter", false, function(autoHeli)
    if autoHeli then
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            -- รอจน Entities และ DropItems ว่าง
            repeat
                local hasModels = false
                for _, child in ipairs(workspace.Entities:GetChildren()) do
                    if child:IsA("Model") then
                        hasModels = true
                        break
                    end
                end
                local hasDrops = #workspace.DropItems:GetChildren() > 0
                task.wait(15)
            until not hasModels and not hasDrops or not autoHeli

            if not autoHeli then return end

            -- หา HeliObjective BasePart
            local heliObj = workspace.School.Rooms.RooftopBoss:FindFirstChild("HeliObjective")
            if not heliObj then return end

            -- วาปไป HeliObjective
            hrp.CFrame = heliObj.CFrame

            -- หา ProximityPrompt ภายใน HeliObjective
            local prompt = heliObj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                -- กดรัว ๆ จน prompt ปิด
                while prompt.Enabled and autoHeli do
                    hrp.CFrame = heliObj.CFrame
                    fireproximityprompt(prompt)
                    task.wait(0.05)
                end
            end
        end)
    end
end)

local tabs = win:Tab("World 2")

tabs:Toggle("Auto Generator", false, function(autoGen)
    if autoGen then
        task.spawn(function()

            -- รอจน Entities และ DropItems ว่าง
            repeat
                local hasModels = false
                for _, child in ipairs(workspace.Entities:GetChildren()) do
                    if child:IsA("Model") then
                        hasModels = true
                        break
                    end
                end
                local hasDrops = #workspace.DropItems:GetChildren() > 0
                task.wait(0.1)
            until not hasModels and not hasDrops or not autoGen

            if not autoGen then return end

            -- หา generator.gen และ pom
            local generator = workspace.Sewers.Rooms.BossRoom:WaitForChild("generator")
            local genPart = generator:WaitForChild("gen")
            local promptPart = genPart:WaitForChild("pom")
            local prompt = promptPart:FindFirstChildWhichIsA("ProximityPrompt", true)

            if genPart:IsA("BasePart") and prompt then
                -- วาปและกดรัว ๆ จน prompt ปิด
                while prompt.Enabled and autoGen do
                    hrp.CFrame = genPart.CFrame  -- วาปตรง gen
                    fireproximityprompt(prompt)  -- กดรัว ๆ
                    task.wait(0.05)
                end
            end
        end)
    end
end)
