local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("EiEi", "DarkTheme")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Farm")

local plr = game:GetService("Players").LocalPlayer
local panPos = nil
local shakePos = nil
local args = {1}
local running = false

local function findPan()
    if plr.Character then
        for _, tool in ipairs(plr.Character:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name:lower(), "pan") then
                return tool
            end
        end
    end
    return nil
end

--Save Pan
Section:NewButton("savepan", "Save pan position", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        panPos = plr.Character.HumanoidRootPart.Position
        print("[Auto Pan] Saved pan position:", panPos)
    end
end)

-- Save Shake
Section:NewButton("saveshake", "Save shake position", function()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        shakePos = plr.Character.HumanoidRootPart.Position
        print("[Auto Pan] Saved shake position:", shakePos)
    end
end)

-- Toggle Auto Pan
Section:NewToggle("auto pan", "ToggleInfo", function(state)
    running = state
    task.spawn(function()
        while running do
            local fillTextObj = plr.PlayerGui:FindFirstChild("ToolUI")
                and plr.PlayerGui.ToolUI:FindFirstChild("FillingPan")
                and plr.PlayerGui.ToolUI.FillingPan:FindFirstChild("FillText")

            if fillTextObj then
                local text = fillTextObj.Text
                local current, max = text:match("(%d+)%s*/%s*(%d+)")
                current, max = tonumber(current), tonumber(max)

                if current and max then
                    if current < max then
                        if panPos and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            plr.Character.HumanoidRootPart.CFrame = CFrame.new(panPos)
                        end
                        local panTool = findPan()
                        if panTool then
                            pcall(function()
                                panTool:WaitForChild("Scripts")
                                    :WaitForChild("Collect")
                                    :InvokeServer(unpack(args))
                            end)
                        end
                    else
                        if shakePos and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            plr.Character.HumanoidRootPart.CFrame = CFrame.new(shakePos)
                        end
                    end
                end
            end

            task.wait(0.3)
        end
    end)
end)

Section:NewToggle("auto shake", "ToggleInfo", function(state)
    local runningShake = state
    task.spawn(function()
        while runningShake do
            local panTool = findPan()
            if panTool then
                pcall(function()
                    local shakeEvent = panTool:FindFirstChild("Scripts") and panTool.Scripts:FindFirstChild("Shake")
                    if shakeEvent then
                        shakeEvent:FireServer()
                    end

                    local panEvent = panTool:FindFirstChild("Scripts") and panTool.Scripts:FindFirstChild("Pan")
                    if panEvent then
                        panEvent:InvokeServer()
                    end
                end)
            end
            task.wait(0.3) 
        end
    end)
end)
