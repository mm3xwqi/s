--[[
local Collect = 0.3 
local ScanCooldown = 0.5
local SafeZoneCD = 0.1 -- Mantiene el personaje anclado en la posición fija
]]
local FixedSafePos = Vector3.new(-7.570, 200, 86.898)

local player = game.Players.LocalPlayer
local esperandoTickets = false
local recolectando = false

print("TICKET FARM - TARGET: Lupen")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        -- เปลี่ยนเป้าหมายเป็น Game.Players.Lupen
        local lupenFolder = game.Workspace.Game.Players:FindFirstChild("Lupen")

        if hrp then
            local currentTickets = {}

            if lupenFolder then
                -- ค้นหา child แต่ละตัวใน Lupen แล้วหา Mover ข้างใน
                local allItems = lupenFolder:GetChildren()
                for _, item in ipairs(allItems) do
                    local mover = item:FindFirstChild("Mover")
                    if mover and mover:IsA("BasePart") then
                        table.insert(currentTickets, mover)
                    end
                end
            end

            if #currentTickets > 0 then
                if not recolectando then
                    print("--- Found items in Lupen!")
                    recolectando = true
                    esperandoTickets = false
                end
                for _, target in ipairs(currentTickets) do
                    pcall(function()
                        if target and target.Parent then
                            hrp.Position = target.Position + Vector3.new(0, -10, 0)
                            task.wait(Collect)  -- ตัวแปร Collect ต้องถูกกำหนดไว้ภายนอก
                        end
                    end)
                end
            else
                if not esperandoTickets then
                    print("--- No items in Lupen, returning to Fixed Safe Zone...")
                    esperandoTickets = true
                    recolectando = false
                end

                hrp.Position = FixedSafePos
                hrp.Velocity = Vector3.new(0, -10, 0)
            end
        end
        task.wait(recolectando and ScanCooldown or SafeZoneCD)  -- ตัวแปร ScanCooldown, SafeZoneCD ต้องถูกกำหนดไว้ภายนอก
    end
end)
