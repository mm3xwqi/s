local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "idk" .. Fluent.Version,
    SubTitle = "blablabla",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})


-- สร้าง Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ตัวแปรเก็บสถานะ Toggle
local isToggledOn = false

-- ตัวแปรเก็บขนาดเดิมของ playerBar
local originalSize = nil

-- ฟังก์ชันรีเซ็ตขนาด playerBar
local function setFixedSize()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerBar = player.PlayerGui:FindFirstChild("reel") and player.PlayerGui.reel:FindFirstChild("bar") and player.PlayerGui.reel.bar:FindFirstChild("playerbar")

    if playerBar then
        originalSize = playerBar.Size -- เก็บขนาดเดิมไว้
        playerBar.Size = UDim2.new(1, 30, 0, 33) -- รีเซ็ตขนาด
    end
end

-- ฟังก์ชันคืนค่า playerBar กลับสู่ขนาดเดิม
local function restoreOriginalSize()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerBar = player.PlayerGui:FindFirstChild("reel") and player.PlayerGui.reel:FindFirstChild("bar") and player.PlayerGui.reel.bar:FindFirstChild("playerbar")

    if playerBar and originalSize then
        playerBar.Size = originalSize -- คืนค่าขนาดที่เคยมี
    end
end

-- สร้าง Toggle Button
local Toggle = Tabs.Main:AddToggle("MyToggle", { Title = "bar", Default = false })

Toggle:OnChanged(function(state)
    isToggledOn = state

    if isToggledOn then
        print("Toggle ON: Resizing playerBar")
        spawn(function()
            while isToggledOn do
                setFixedSize()
                wait(0.1)
            end
        end)
    else
        print("Toggle OFF: Restoring playerBar size")
        restoreOriginalSize() -- คืนค่าขนาดเดิมเมื่อ Toggle ปิด
    end
end)
