local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/lime"))()

local w = Library:Window("BiBi")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

w:Toggle("auto fishing", function(v)

    fishing = v 

    if fishing then
        while fishing do
local args = {
    "SW_Basic Rod_M1",
    {
        Charge = 100,
        MouseHit = workspace.SeaFolder.Sea.CFrame
    }
}

local SkillAction = ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("SkillAction")

SkillAction:InvokeServer(unpack(args))
wait()
        end
    end
end)

local fishingActive = false 

w:Toggle("Super Bar", function(state)
    fishingActive = state

    if fishingActive then
        
        coroutine.wrap(function()
            local player = Players.LocalPlayer

            while fishingActive do
                
                local gui = player:FindFirstChild("PlayerGui")
                if gui then
                    local fishingUI = gui:FindFirstChild("FishingUI")
                    if fishingUI then
                        local background = fishingUI:FindFirstChild("FishingBackground")
                        if background then
                            local fishingBar = background:FindFirstChild("FishingBar")
                            if fishingBar then
                                
                                local connection
                                connection = RunService.RenderStepped:Connect(function()
                                    if fishingActive and fishingBar and fishingBar.Parent then
                                        fishingBar.Size = UDim2.new(1, 0, 0, 50)
                                    else
                                        if connection then
                                            connection:Disconnect()
                                            connection = nil
                                        end
                                    end
                                end)

                                
                                repeat wait(0.1) 
                                    fishingUI = gui:FindFirstChild("FishingUI")
                                until not fishingUI or not fishingActive

                                
                                if connection then
                                    connection:Disconnect()
                                    connection = nil
                                end
                            end
                        end
                    end
                end
                wait(0.5)
            end
        end)()
    end
end)

local freeze = false
local hrp = humanoid.Parent:WaitForChild("HumanoidRootPart")

w:Toggle("Freeze Character", function(state)
    freeze = state
    if freeze then
        hrp.Anchored = true
    else
        hrp.Anchored = false
    end
end)

w:Button("Sellall fish", function()
local args = {
	"Fisher Frank",
	{
		SellType = "Sell Inventory Fish",
		Tier = "Common"
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("EtcFunction"):InvokeServer(unpack(args))

local args = {
	"Fisher Frank",
	{
		SellType = "Sell Inventory Fish",
		Tier = "Uncommon"
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("EtcFunction"):InvokeServer(unpack(args))

local args = {
	"Fisher Frank",
	{
		SellType = "Sell Inventory Fish",
		Tier = "Rare"
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("EtcFunction"):InvokeServer(unpack(args))

local args = {
	"Fisher Frank",
	{
		SellType = "Sell Inventory Fish",
		Tier = "Epic"
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("EtcFunction"):InvokeServer(unpack(args))

local args = {
	"Fisher Frank",
	{
		SellType = "Sell Inventory Fish",
		Tier = "Legendary"
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("EtcFunction"):InvokeServer(unpack(args))

local args = {
	"Fisher Frank",
	{
		SellType = "Sell Inventory Fish",
		Tier = "Mythical"
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("EtcFunction"):InvokeServer(unpack(args))
end)
