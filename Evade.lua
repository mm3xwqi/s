local FixedSafePos = Vector3.new(-7.570, 200, 86.898)

local player = game.Players.LocalPlayer
local esperandoTickets = false
local recolectando = false

print("Lupen Farm")

local Collect = 0
local ScanCooldown = 0
local SafeZoneCD = 0

task.spawn(function()
    while true do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        local lupenChar = nil
        local lupenPlayer = game.Players:FindFirstChild("Lupen")
        if lupenPlayer then
            lupenChar = lupenPlayer.Character
        else
            local lupenFolder = game.Workspace.Game and game.Workspace.Game.Players and game.Workspace.Game.Players:FindFirstChild("Lupen")
            if lupenFolder then
                lupenChar = lupenFolder
            end
        end

        if hrp and lupenChar then
            local lupenHRP = lupenChar:FindFirstChild("HumanoidRootPart") or lupenChar.PrimaryPart
            if lupenHRP then
                if not recolectando then
                    print("Goto Lupen")
                    recolectando = true
                    esperandoTickets = false
                end

                hrp.Position = lupenHRP.Position + Vector3.new(0, -3, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
            else
                if not esperandoTickets then
                    print("--- Lupen has no HumanoidRootPart")
                    esperandoTickets = true
                    recolectando = false
                end
                hrp.Position = FixedSafePos
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        else
            if not esperandoTickets then
                print("Lupen not found")
                esperandoTickets = true
                recolectando = false
            end

            if hrp then
                hrp.Position = FixedSafePos
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end

        task.wait(recolectando and ScanCooldown or SafeZoneCD)
    end
end)
