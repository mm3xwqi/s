local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/lime"))()

local w = Library:Window("Main")



w:Button("Go to Shop", function()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(122, 3, 30)
    end
end)


w:Toggle("auto tain", function(v)

    autotain = v 

    if autotain then
        while autotain do
    local args = {
	"swingKatana"
}
game:GetService("Players").LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
wait()
        end
    end
end)

w:Toggle("Auto Hoop", function(g)
    autohoop = g

    if autohoop then
        spawn(function()
            while true do
                if not autohoop then break end -- หยุดถ้า toggle ถูกปิด

                local player = game.Players.LocalPlayer
                local char = player and player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hoopsFolder = workspace:FindFirstChild("Hoops")

                if hrp and hoopsFolder then
                    for _, hoop in ipairs(hoopsFolder:GetChildren()) do
                        if not autohoop then break end -- เช็กซ้ำระหว่างลูปย่อย
                        if hoop:IsA("BasePart") then
                            hrp.CFrame = hoop.CFrame + Vector3.new(0, 5, 0)
                            task.wait()
                        end
                    end
                end

                wait(10)
            end
        end)
    end
end)



w:Toggle("Auto Chi", function(state)
    autocoin = state

    if autocoin then
        spawn(function()
            while true do
                if not autocoin then break end

                local player = game.Players.LocalPlayer
                local char = player and player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local coinFolder = workspace:FindFirstChild("spawnedCoins")
                local valleyFolder = coinFolder and coinFolder:FindFirstChild("Valley")

                if hrp and valleyFolder then
                    for _, coin in ipairs(valleyFolder:GetChildren()) do
                        if not autocoin then break end
                        
                        if coin:IsA("BasePart") and string.find(string.lower(coin.Name), "chi") then
                            hrp.CFrame = coin.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                        end
                    end
                end

                task.wait()
            end
        end)
    end
end)

w:Toggle("Auto King", function(v)
    autoking = v  -- กำหนดค่าให้กับตัวแปร autoking

    if autoking then
        spawn(function()
            while autoking do
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    -- รอให้ HumanoidRootPart พร้อมใช้งาน
                    local hrp = player.Character:WaitForChild("HumanoidRootPart", 10)
                    if hrp then
                        -- วาร์ปไปที่พิกัดที่กำหนด
                        hrp.CFrame = CFrame.new(240, 130, -286)
                    end
                end
                task.wait() 
            end
        end)
    end
end)

w:Toggle("auto sell", function(vd)
    autosell = vd

    if autosell then
        spawn(function()
            while autosell do
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(80, 91256, 124)
                end
                task.wait(1)
            end
        end)
    end
end)

w:Toggle("Auto BuyAll", function(f)
    autobuy = f
    if autobuy then
        spawn(function()
            while autobuy do
		local args = {
		    "buyAllSwords",
		    "Blazing Vortex Island"
		}
		game:GetService("Players").LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
		local args = {
		    "buyAllBelts",
		    "Blazing Vortex Island"
		}
		game:GetService("Players").LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))

                wait(0.5)
            end
        end)
    end
end)

w:Toggle("Auto buyjump", function(q)
    autobuyjump = q
    if autobuyjump then
local args = {
	    "buyAllSkills",
	    "Blazing Vortex Island"
	}
	game:GetService("Players").LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
	wait(.5)
    end
    end)

    w:Toggle("Auto BuyShurikens",function(q)
    autobuyshuri = q
    if autobuyshuri then
	local args = {
	    "buyAllShurikens",
	    "Blazing Vortex Island"
	}
	game:GetService("Players").LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
	wait(.5)
	end
    end)


