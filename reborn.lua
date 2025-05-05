local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/lime"))()

local w = Library:Window("Main")

local autoTainActive = false 

w:Toggle("Auto Tain", function(v)
    autoTainActive = v  

    if autoTainActive then
        while autoTainActive do
local args = {
	"TrainPower008"
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Game"):WaitForChild("Re_TrainPower"):FireServer(unpack(args))

            wait()  
        end
    end
    end)

w:Toggle("Auto Rebirth", function(b)
    AutoRebirth = b 

    if AutoRebirth then
        while AutoRebirth do
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Stats"):WaitForChild("Re_Rebirth"):FireServer()
    wait()
        end
    end
    end)

w:Toggle("Auto Dun", function(a)
    autodun = a

    if autodun then
        task.spawn(function()
            while autodun do
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(
                        -411, 192, -2696
                    )
                end
                
                local args = {1}
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Fight"):WaitForChild("Re_ChallengeStart"):FireServer(unpack(args))

                task.wait() 
            end
        end)
    end
end)

    w:Toggle("Auto Attack NPCs", function(state)
    autoAttackNpcs = state

    if autoAttackNpcs then
        task.spawn(function()
            while autoAttackNpcs do
                for _, npc in pairs(workspace:WaitForChild("FightNpcs"):GetChildren()) do
                    if npc:IsA("Model") and npc.Name:match("Npc") then
                        local args = {npc.Name, 2}
                        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Fight"):WaitForChild("Re_TakeDamage"):FireServer(unpack(args))
                        task.wait()
                    end
                end
                task.wait()
            end
        end)
    end
end)

w:Toggle("Auto EquipbestPet", function(x)
        AutoEquipbestPet = x
        if AutoEquipbestPet then 
            while AutoEquipbestPet do
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Pets"):WaitForChild("Re_EquipBest"):FireServer()
wait(1)
            end
        end
        end)


    

