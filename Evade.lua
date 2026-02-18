--[[V1.4
+ Removed SafeZone search by ingame part
+ Changed safezone to now just teleport you up the map
+ Fixed Mapchange crashing logic
]]

--[[
local Collect = 0.3 
local ScanCooldown = 0.5
local SafeZoneCD = 0.1 -- Mantiene el personaje anclado en la posición fija
]]
local FixedSafePos = Vector3.new(-7.570, 380.103, 86.898)

local player = game.Players.LocalPlayer
local esperandoTickets = false
local recolectando = false

print("TICKET FARM")

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local gameFolder = workspace:FindFirstChild("Game")
        local effects = gameFolder and gameFolder:FindFirstChild("Effects")
        local ticketsFolder = effects and effects:FindFirstChild("Tickets")

        if hrp then
            local currentTickets = {}

            if ticketsFolder then
                local allTickets = ticketsFolder:GetChildren()
                for _, t in ipairs(allTickets) do
                    local mover = t:FindFirstChild("Mover")
                    if mover and mover:IsA("BasePart") then
                        table.insert(currentTickets, mover)
                    end
                end
            end
            if #currentTickets > 0 then
                if not recolectando then
                    print("--- Tickets found!")
                    recolectando = true
                    esperandoTickets = false
                end
                for _, target in ipairs(currentTickets) do
                    pcall(function()
                        if target and target.Parent then
                            hrp.Position = target.Position + Vector3.new(0, -5, 0)
                            task.wait(Collect)
                        end
                    end)
                end
            else
                if not esperandoTickets then
                    print("--- No tickets, returning to Fixed Safe Zone...")
                    esperandoTickets = true
                    recolectando = false
                end

                hrp.Position = FixedSafePos
                hrp.Velocity = Vector3.new(0, -5, 0)
            end
        end
        task.wait(recolectando and ScanCooldown or SafeZoneCD)
    end
end)
