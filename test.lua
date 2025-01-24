local DiscordLib = loadstring(game:HttpGet "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord")()

local win = DiscordLib:Window("test1")

local serv = win:Server("Main", "")

local tgls = serv:Channel("Auto")
local lp = game.Players.LocalPlayer
local re = game.ReplicatedStorage

getgenv().config = getgenv().config or {}
getgenv().config.auto_thorown_rod = false

tgls:Toggle(
    "Auto Throw Rod", "Automatically throw the rod", function(state)
    if state then
        
        getgenv().config.auto_thorown_rod = true
        spawn(function()
            while getgenv().config.auto_thorown_rod do
                task.wait()

                
                local rod_name = re.playerstats[lp.Name].Stats.rod.Value
                local equipped_rod = lp.Character:FindFirstChild(rod_name)

                if equipped_rod and equipped_rod:FindFirstChild("events") and equipped_rod.events:FindFirstChild("cast") then
                    equipped_rod.events.cast:FireServer(100) 
                end
            end
        end)
    else
        
        getgenv().config.auto_thorown_rod = false
    end
end
)
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local GuiService = game:GetService("GuiService")

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager") 

tgls:Toggle(
    "Auto Shake", "Navigate", function(state)
    if state then
        getgenv().config.auto_shake = true

        
        spawn(function()
            while getgenv().config.auto_shake do
                task.wait()

                
                local playerGui = lp:WaitForChild("PlayerGui")
                local shake_button = playerGui:FindFirstChild("shakeui") 
                    and playerGui.shakeui:FindFirstChild("safezone") 
                    and playerGui.shakeui.safezone:FindFirstChild("button")

                if shake_button then
                    
                    shake_button.Selectable = true
                    GuiService.SelectedObject = shake_button 

                    
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil) -- กดปุ่ม Enter
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil) -- ปล่อยปุ่ม Enter
                end
            end
        end)
    else
        getgenv().config.auto_shake = false
    end
end
)
tgls:Toggle(
    "auto reel", "ToggleInfo", function(state)
    if state then
        getgenv().config.auto_reel = true

        spawn(function()
            while getgenv().config.auto_reel do
                task.wait(0)  

                
                local playerGui = lp:FindFirstChild("PlayerGui")
                if playerGui then
                    local reel = playerGui:FindFirstChild("reel")
                        if re and re.events and re.events.reelfinished then
                            print("Attempting to fire reelfinished event")
                            local success, errorMsg = pcall(function()
                                re.events.reelfinished:FireServer(100, 1)
                        end)
                end
            end
        end
        getgenv().config.auto_reel = false
    end)
end
end
)


local isTeleporting = false  

tgls:Toggle(
    "Teleport to Saved Position (Loop)", "Continuously teleport character to saved position", function(state)
    if state then
        isTeleporting = true

        spawn(function()
            while isTeleporting do
                task.wait(0)  

                if getgenv().position and lp.Character and lp.Character.HumanoidRootPart then
                    lp.Character.HumanoidRootPart.CFrame = getgenv().position
                    break 
                end
            end
        end)
    else
        isTeleporting = false
    end
end
)


tgls:Button(
    "Save Position", "Save your character's position permanently", function()
    if lp.Character and lp.Character.HumanoidRootPart then
        getgenv().position = lp.Character.HumanoidRootPart.CFrame
    end
end
)


