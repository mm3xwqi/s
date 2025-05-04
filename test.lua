-- discord.gg/uPypknTskC
-- ควยแม่มึงตายไอหน้าหีช้างเย็ด

_G.FAK = true
_G.BMS = true
_G.BMB = true

if _G.FAK then
    local _v13 = (getgenv or getrenv or getfenv)()

    local function SafeWaitForChild(parent, childName)
        local success, result = pcall(function()
            return parent:WaitForChild(childName)
        end)
        if not success or not result then
            warn("hee dum e dok" .. childName)
        end
        return result
    end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    if not Player then
        warn("kuy i sus gu uniquerank1")
        return
    end

    local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes")
    if not Remotes then return end

    local CommF = SafeWaitForChild(Remotes, "CommF_")
    local WorldOrigin = SafeWaitForChild(workspace, "_WorldOrigin")
    local Characters = SafeWaitForChild(workspace, "Characters")
    local Enemies = SafeWaitForChild(workspace, "Enemies")
    local Locations = SafeWaitForChild(WorldOrigin, "Locations")
    local Stepped = RunService.Stepped
    local Modules = SafeWaitForChild(ReplicatedStorage, "Modules")
    local Net = SafeWaitForChild(Modules, "Net")
    local sethiddenproperty = sethiddenproperty or function(...) return ... end
    local setupvalue = setupvalue or (debug and debug.setupvalue)
    local getupvalue = getupvalue or (debug and debug.getupvalue)

    local Settings = {
        AutoClick = true,
        ClickDelay = 0
    }

    local Module = {}

    Module.FastAttack = (function()
        if _v13.e_fastattack then
            return _v13.e_fastattack
        end

        local FastAttack = {
            Distance = 100,
            Equipped = nil
        }

        local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
        local RegisterHit = SafeWaitForChild(Net, "RE/RegisterHit")

        local function IsAlive(character)
            return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
        end

        local function ProcessEnemies(OthersEnemies, Folder)
            local BasePart = nil
            for _, Enemy in Folder:GetChildren() do
                local Head = Enemy:FindFirstChild("Head")
                if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < FastAttack.Distance then
                    if Enemy ~= Player.Character then
                        table.insert(OthersEnemies, { Enemy, Head })
                        BasePart = Head
                    end
                end
            end
            return BasePart
        end

        function FastAttack:Attack(BasePart, OthersEnemies)
            if not BasePart or #OthersEnemies == 0 then return end
            RegisterAttack:FireServer(Settings.ClickDelay or 0)
            RegisterHit:FireServer(BasePart, OthersEnemies)
        end

        function FastAttack:AttackNearest()
            local OthersEnemies = {}
            local Part1 = ProcessEnemies(OthersEnemies, Enemies)
            local Part2 = ProcessEnemies(OthersEnemies, Characters)

            local character = Player.Character
            if not character then return end
            local equippedWeapon = character:FindFirstChildOfClass("Tool")

            if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
                for _, enemyData in ipairs(OthersEnemies) do
                    local enemy = enemyData[1]
                    local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                    pcall(function()
                        equippedWeapon.LeftClickRemote:FireServer(direction, 1)
                    end)
                end
            elseif #OthersEnemies > 0 then
                self:Attack(Part1 or Part2, OthersEnemies)
            else
                task.wait(0)
            end
        end

        function FastAttack:BladeHits()
            local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
            if Equipped and Equipped.ToolTip ~= "Gun" then
                self:AttackNearest()
            else
                task.wait(0)
            end
        end

        task.spawn(function()
            while task.wait(Settings.ClickDelay) do
                if Settings.AutoClick then
                    FastAttack:BladeHits()
                end
            end
        end)

        _v13.e_fastattack = FastAttack
        return FastAttack
    end)()
end

if game.PlaceId == 2753915549 then
        W1 = true
    elseif game.PlaceId == 4442272183 then
        W2 = true
    elseif game.PlaceId == 7449423635 then
        W3 = true
end

function CQ()
    MyLevel = game:GetService("Players").LocalPlayer.Data.Level.Value
    if W1 then
        if (MyLevel >= 1 and MyLevel <= 9) or SMN == "Bandit" then
            MN = "Bandit"
            LQ = 1
            NQ = "BanditQuest1"
            NM = "Bandit"
            CFQ = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, 0, 1, -0, 0.341998369, 0, 0.939700544)
            CFM = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)              
        elseif (MyLevel >= 10 and MyLevel <= 14) or SMN == "Monkey" then
            MN = "Monkey"
            LQ = 1
            NQ = "JungleQuest"
            NM = "Monkey"
            CFQ = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            CFM = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)                
        elseif (MyLevel >= 15 and MyLevel <= 29) or SMN == "Gorilla" then
            MN = "Gorilla"
            LQ = 2
            NQ = "JungleQuest"
            NM = "Gorilla"
            CFQ = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            CFM = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875)
        elseif (MyLevel >= 30 and MyLevel <= 39) or SMN == "Pirate" then
            MN = "Pirate"
            LQ = 1
            NQ = "BuggyQuest1"
            NM = "Pirate"
            CFQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
            CFM = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)                
        elseif (MyLevel >= 40 and MyLevel <= 59) or SMN == "Brute" then
            MN = "Brute"
            LQ = 2
            NQ = "BuggyQuest1"
            NM = "Brute"
            CFQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627)
            CFM = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)
        elseif (MyLevel >= 60 and MyLevel <= 74) or SMN == "Desert Bandit" then
            MN = "Desert Bandit"
            LQ = 1
            NQ = "DesertQuest"
            NM = "Desert Bandit"
            CFQ = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
            CFM = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)            
        elseif (MyLevel >= 75 and MyLevel <= 89) or SMN == "Desert Officer" then
            MN = "Desert Officer"
            LQ = 2
            NQ = "DesertQuest"
            NM = "Desert Officer"
            CFQ = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
            CFM = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)               
        elseif (MyLevel >= 90 and MyLevel <= 99) or SMN == "Snow Bandit" then
            MN = "Snow Bandit"
            LQ = 1
            NQ = "SnowQuest"
            NM = "Snow Bandit"
            CFQ = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
            CFM = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)
            
        elseif (MyLevel >= 100 and MyLevel <= 119) or SMN == "Snowman" then
            MN = "Snowman"
            LQ = 2
            NQ = "SnowQuest"
            NM = "Snowman"
            CFQ = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
            CFM = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)
        elseif (MyLevel >= 120 and MyLevel <= 149) or SMN == "Chief Petty Officer" then
            MN = "Chief Petty Officer"
            LQ = 1
            NQ = "MarineQuest2"
            NM = "Chief Petty Officer"
            CFQ = CFrame.new(-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFM = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)
        elseif (MyLevel >= 150 and MyLevel <= 174) or SMN == "Sky Bandit" then
            MN = "Sky Bandit"
            LQ = 1
            NQ = "SkyQuest"
            NM = "Sky Bandit"
            CFQ = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
            CFM = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)
            
        elseif (MyLevel >= 175 and MyLevel <= 189) or SMN == "Dark Master" then
            MN = "Dark Master"
            LQ = 2
            NQ = "SkyQuest"
            NM = "Dark Master"
            CFQ = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
            CFM = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)
        elseif (MyLevel >= 190 and MyLevel <= 209) or SMN == "Prisoner" then
            MN = "Prisoner"
            LQ = 1
            NQ = "PrisonerQuest"
            NM = "Prisoner"
            CFQ = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712)
            CFM = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)
        elseif (MyLevel >= 210 and MyLevel <= 249) or SMN == "Dangerous Prisone" then
            MN = "Dangerous Prisoner"
            LQ = 2
            NQ = "PrisonerQuest"
            NM = "Dangerous Prisoner"
            CFQ = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712)
            CFM = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)
        elseif (MyLevel >= 250 and MyLevel <= 274) or SMN == "Toga Warrior" then
            MN = "Toga Warrior"
            LQ = 1
            NQ = "ColosseumQuest"
            NM = "Toga Warrior"
            CFQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
            CFM = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625)
        elseif (MyLevel >= 275 and MyLevel <= 299) or SMN == "Gladiator" then
            MN = "Gladiator"
            LQ = 2
            NQ = "ColosseumQuest"
            NM = "Gladiator"
            CFQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298)
            CFM = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625)
        elseif (MyLevel >= 300 and MyLevel <= 324) or SMN == "Military Soldier" then
            MN = "Military Soldier"
            LQ = 1
            NQ = "MagmaQuest"
            NM = "Military Soldier"
            CFQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
            CFM = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875)
        elseif (MyLevel >= 325 and MyLevel <= 374) or SMN == "Military Spy" then
            MN = "Military Spy"
            LQ = 2
            NQ = "MagmaQuest"
            NM = "Military Spy"
            CFQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
            CFM = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375)
        elseif (MyLevel >= 375 and MyLevel <= 399) or SMN == "Fishman Warrior" then
            MN = "Fishman Warrior"
            LQ = 1
            NQ = "FishmanQuest"
            NM = "Fishman Warrior"
            CFQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            CFM = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625)
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
            end
        elseif (MyLevel >= 400 and MyLevel <= 449) or SMN == "Fishman Commando" then
            MN = "Fishman Commando"
            LQ = 2
            NQ = "FishmanQuest"
            NM = "Fishman Commando"
            CFQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            CFM = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875)
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
            end
        elseif (MyLevel >= 450 and MyLevel <= 474) or SMN == "God's Guard" then
            MN = "God's Guard"
            LQ = 1
            NQ = "SkyExp1Quest"
            NM = "God's Guard"
            CFQ = CFrame.new(-4721.88867, 843.874695, -1949.96643, 0.996191859, -0, -0.0871884301, 0, 1, -0, 0.0871884301, 0, 0.996191859)
            CFM = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375)
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-4607.82275, 872.54248, -1667.55688))
            end
        elseif (MyLevel >= 475 and MyLevel <= 524) or SMN == "Shanda" then
            MN = "Shanda"
            LQ = 2
            NQ = "SkyExp1Quest"
            NM = "Shanda"
            CFQ = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, -0.422592998)
            CFM = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531)
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
            end
        elseif (MyLevel >= 525 and MyLevel <= 549) or SMN == "Royal Squad" then
            MN = "Royal Squad"
            LQ = 1
            NQ = "SkyExp2Quest"
            NM = "Royal Squad"
            CFQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFM = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875)
        elseif (MyLevel >= 550 and MyLevel <= 624) or SMN == "Royal Soldier" then
            MN = "Royal Soldier"
            LQ = 2
            NQ = "SkyExp2Quest"
            NM = "Royal Soldier"
            CFQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFM = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)
        elseif (MyLevel >= 625 and MyLevel <= 649) or SMN == "Galley Pirate" then
            MN = "Galley Pirate"
            LQ = 1
            NQ = "FountainQuest"
            NM = "Galley Pirate"
            CFQ = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381)
            CFM = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875)
        elseif MyLevel >= 650 or SMN == "Galley Captain" then
            MN = "Galley Captain"
            LQ = 2
            NQ = "FountainQuest"
            NM = "Galley Captain"
            CFQ = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381)
            CFM = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)
        end
       elseif W2 then
        if (MyLevel >= 700 and MyLevel <= 724) or SMN == "Raider" then
            MN = "Raider"
            LQ = 1
            NQ = "Area1Quest"
            NM = "Raider"
            CFQ = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
            CFM = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125)
        elseif (MyLevel >= 725 and MyLevel <= 774) or SMN == "Mercenary" then
            MN = "Mercenary"
            LQ = 2
            NQ = "Area1Quest"
            NM = "Mercenary"
            CFQ = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985)
            CFM = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)
        elseif (MyLevel >= 775 and MyLevel <= 799) or SMN == "Swan Pirate" then
            MN = "Swan Pirate"
            LQ = 1
            NQ = "Area2Quest"
            NM = "Swan Pirate"
            CFQ = CFrame.new(638.43811, 71.769989, 918.282898, 0.139203906, 0, 0.99026376, 0, 1, 0, -0.99026376, 0, 0.139203906)
            CFM = CFrame.new(1068.664306640625, 137.61428833007812, 1322.1060791015625)
        elseif (MyLevel >= 800 and MyLevel <= 874) or SMN == "Factory Staff" then
            MN = "Factory Staff"
            NQ = "Area2Quest"
            LQ = 2
            NM = "Factory Staff"
            CFQ = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-10, -0.999488771, 1.36326533e-10, 1, 8.92172336e-10, 0.999488771, -1.07732087e-10, -0.0319722369)
            CFM = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875)
        elseif (MyLevel >= 875 and MyLevel <= 899) or SMN == "Marine Lieutenant" then           
            MN = "Marine Lieutenant"
            LQ = 1
            NQ = "MarineQuest3"
            NM = "Marine Lieutenant"
            CFQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
            CFM = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125)
        elseif (MyLevel >= 900 and MyLevel <= 949) or SMN == "Marine Captain" then
            MN = "Marine Captain"
            LQ = 2
            NQ = "MarineQuest3"
            NM = "Marine Captain"
            CFQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)
            CFM = CFrame.new(-1861.2310791015625, 80.17658233642578, -3254.697509765625)
        elseif (MyLevel >= 950 and MyLevel <= 974) or SMN == "Zombie" then
            MN = "Zombie"
            LQ = 1
            NQ = "ZombieQuest"
            NM = "Zombie"
            CFQ = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146)
            CFM = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875)
        elseif (MyLevel >= 975 and MyLevel <= 999) or SMN == "Vampire" then
            MN = "Vampire"
            LQ = 2
            NQ = "ZombieQuest"
            NM = "Vampire"
            CFQ = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146)
            CFM = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625)
        elseif (MyLevel >= 1000 and MyLevel <= 1049) or SMN == "Snow Trooper" then
            MN = "Snow Trooper"
            LQ = 1
            NQ = "SnowMountainQuest"
            NM = "Snow Trooper"
            CFQ = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
            CFM = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875)
        elseif (MyLevel >= 1050 and MyLevel <= 1099) or SMN == "Winter Warrior" then
            MN = "Winter Warrior"
            LQ = 2
            NQ = "SnowMountainQuest"
            NM = "Winter Warrior"
            CFQ = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
            CFM = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625)
        elseif (MyLevel >= 1100 and MyLevel <= 1124) or SMN == "Lab Subordinate" then
            MN = "Lab Subordinate"
            LQ = 1
            NQ = "IceSideQuest"
            NM = "Lab Subordinate"
            CFQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, 0, 1, -0, 0.891015649, 0, 0.453972578)
            CFM = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375)
        elseif (MyLevel >= 1125 and MyLevel <= 1174) or SMN == "Horned Warrior" then
            MN = "Horned Warrior"
            LQ = 2
            NQ = "IceSideQuest"
            NM = "Horned Warrior"
            CFQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, 0, 1, -0, 0.891015649, 0, 0.453972578)
            CFM = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375)
        elseif (MyLevel >= 1175 and MyLevel <= 1199) or SMN == "Magma Ninja" then
            MN = "Magma Ninja"
            LQ = 1
            NQ = "FireSideQuest"
            NM = "Magma Ninja"
            CFQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
            CFM = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375)
        elseif (MyLevel >= 1200 and MyLevel <= 1249) or SMN == "Lava Pirate" then
            MN = "Lava Pirate"
            LQ = 2
            NQ = "FireSideQuest"
            NM = "Lava Pirate"
            CFQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
            CFM = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)
        elseif (MyLevel >= 1250 and MyLevel <= 1274) or SMN == "Ship Deckhand" then
            MN = "Ship Deckhand"
            LQ = 1
            NQ = "ShipQuest1"
            NM = "Ship Deckhand"
            CFQ = CFrame.new(1037.80127, 125.092171, 32911.6016)         
            CFM = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375)    
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end
        elseif (MyLevel >= 1275 and MyLevel <= 1299) or SMN == "Ship Engineer" then
            MN = "Ship Engineer"
            LQ = 2
            NQ = "ShipQuest1"
            NM = "Ship Engineer"
            CFQ = CFrame.new(1037.80127, 125.092171, 32911.6016)   
            CFM = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875)   
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end             
        elseif (MyLevel >= 1300 and MyLevel <= 1324) or SMN == "Ship Steward" then
            MN = "Ship Steward"
            LQ = 1
            NQ = "ShipQuest2"
            NM = "Ship Steward"
            CFQ = CFrame.new(968.80957, 125.092171, 33244.125)         
            CFM = CFrame.new(919.4385375976562, 129.55599975585938, 33436.03515625)      
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end
        elseif (MyLevel >= 1325 and MyLevel <= 1349) or SMN == "Ship Officer" then
            MN = "Ship Officer"
            LQ = 2
            NQ = "ShipQuest2"
            NM = "Ship Officer"
            CFQ = CFrame.new(968.80957, 125.092171, 33244.125)
            CFM = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625)
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end
        elseif (MyLevel >= 1350 and MyLevel <= 1374) or SMN == "Arctic Warrior" then
            MN = "Arctic Warrior"
            LQ = 1
            NQ = "FrostQuest"
            NM = "Arctic Warrior"
            CFQ = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909)
            CFM = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125)
            if _G.Auto_Farm_Level and (CFQ.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-6508.5581054688, 5000.034996032715, -132.83953857422))
            end
        elseif (MyLevel >= 1375 and MyLevel <= 1424) or SMN == "Snow Lurker" then
            MN = "Snow Lurker"
            LQ = 2
            NQ = "FrostQuest"
            NM = "Snow Lurker"
            CFQ = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909)
            CFM = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375)
        elseif (MyLevel >= 1425 and MyLevel <= 1449) or SMN == "Sea Soldier" then
            MN = "Sea Soldier"
            LQ = 1
            NQ = "ForgottenQuest"
            NM = "Sea Soldier"
            CFQ = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376)
            CFM = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125)
        elseif MyLevel >= 1450 or SMN == "Water Fighter" then
            MN = "Water Fighter"
            LQ = 2
            NQ = "ForgottenQuest"
            NM = "Water Fighter"
            CFQ = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376)
            CFM = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875)
        end
            elseif W3 then
       if (MyLevel >= 1500 and MyLevel <= 1524) or SMN == "Pirate Millionaire" then
            MN = "Pirate Millionaire"
            LQ = 1
            NQ = "PiratePortQuest"
            NM = "Pirate Millionaire"
            CFQ = CFrame.new(-450.104645, 107.681458, 5950.72607, 0.957107544, -0, -0.289732844, 0, 1, -0, 0.289732844, 0, 0.957107544)
            CFM = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
        elseif (MyLevel >= 1525 and MyLevel <= 1574) or SMN == "Pistol Billionaire" then
            MN = "Pistol Billionaire"
            LQ = 2
            NQ = "PiratePortQuest"
            NM = "Pistol Billionaire"
            CFQ = CFrame.new(-450.104645, 107.681458, 5950.72607, 0.957107544, -0, -0.289732844, 0, 1, -0, 0.289732844, 0, 0.957107544)
            CFM = CFrame.new(-54.8110352, 83.7698746, 5947.84082, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
        elseif (MyLevel >= 1575 and MyLevel <= 1599) or SMN == "Dragon Crew Warrior" then
            MN = "Dragon Crew Warrior"
            LQ = 1
            NQ = "DragonCrewQuest"
            NM = "Dragon Crew Warrior"
            CFQ = CFrame.new(6750.4931640625, 127.44916534423828, -711.0308837890625)
            CFM = CFrame.new(6709.76367, 52.3442993, -1139.02966, -0.763515472, 0, 0.645789504, 0, 1, 0, -0.645789504, 0, -0.763515472)          
        elseif (MyLevel >= 1600 and MyLevel <= 1624) or SMN == "Dragon Crew Archer" then
            MN = "Dragon Crew Archer"
            NQ = "DragonCrewQuest"
            LQ = 2
            NM = "Dragon Crew Archer"
            CFQ = CFrame.new(6750.4931640625, 127.44916534423828, -711.0308837890625)
            CFM = CFrame.new(6668.76172, 481.376923, 329.12207, -0.121787429, 0, -0.992556155, 0, 1, 0, 0.992556155, 0, -0.121787429)
        elseif (MyLevel >= 1625 and MyLevel <= 1649) or SMN == "Hydra Enforcer" then
            MN = "Hydra Enforcer"
            NQ = "VenomCrewQuest"
            LQ = 1
            NM = "Hydra Enforcer"
            CFQ = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875)
            CFM = CFrame.new(4547.11523, 1003.10217, 334.194824, 0.388810456, -0, -0.921317935, 0, 1, -0, 0.921317935, 0, 0.388810456)
        elseif (MyLevel >= 1650 and MyLevel <= 1699) or SMN == "Venomous Assailant" then
            MN = "Venomous Assailant"
            NQ = "VenomCrewQuest"
            LQ = 2
            NM = "Venomous Assailant"
            CFQ = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875)
            CFM = CFrame.new(4674.92676, 1134.82654, 996.308838, 0.731321394, -0, -0.682033002, 0, 1, -0, 0.682033002, 0, 0.731321394)
        elseif (MyLevel >= 1700 and MyLevel <= 1724) or SMN == "Marine Commodore" then
            MN = "Marine Commodore"
            LQ = 1
            NQ = "MarineTreeIsland"
            NM = "Marine Commodore"
            CFQ = CFrame.new(2481.09228515625, 74.27049255371094, -6779.640625)
            CFM = CFrame.new(2577.25391, 75.6100006, -7739.87207, 0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, 0.499959469)
        elseif (MyLevel >= 1725 and MyLevel <= 1774) or SMN == "Marine Rear Admiral" then
            MN = "Marine Rear Admiral"
            LQ = 2
            NQ = "MarineTreeIsland"
            NM = "Marine Rear Admiral"
            CFQ = CFrame.new(2481.09228515625, 74.27049255371094, -6779.640625)
            CFM = CFrame.new(3761.81006, 123.912003, -6823.52197, 0.961273968, 0, 0.275594592, 0, 1, 0, -0.275594592, 0, 0.961273968)
        elseif (MyLevel >= 1775 and MyLevel <= 1799) or SMN == "Fishman Raider" then
            MN = "Fishman Raider"
            LQ = 1
            NQ = "DeepForestIsland3"
            NM = "Fishman Raider"
            CFQ = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)   
            CFM = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625)
        elseif (MyLevel >= 1800 and MyLevel <= 1824) or SMN == "Fishman Captain" then
            MN = "Fishman Captain"
            LQ = 2
            NQ = "DeepForestIsland3"
            NM = "Fishman Captain"
            CFQ = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)   
            CFM = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625) 
        elseif (MyLevel >= 1825 and MyLevel <= 1849) or SMN == "Forest Pirate" then
            MN = "Forest Pirate"
            LQ = 1
            NQ = "DeepForestIsland"
            NM = "Forest Pirate"
            CFQ = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)
            CFM = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625)
        elseif (MyLevel >= 1850 and MyLevel <= 1899) or SMN == "Mythological Pirate" then
            MN = "Mythological Pirate"
            LQ = 2
            NQ = "DeepForestIsland"
            NM = "Mythological Pirate"
            CFQ = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247)   
            CFM = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
        elseif (MyLevel >= 1900 and MyLevel <= 1924) or SMN == "Jungle Pirate" then
            MN = "Jungle Pirate"
            LQ = 1
            NQ = "DeepForestIsland2"
            NM = "Jungle Pirate"
            CFQ = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
            CFM = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625)
        elseif (MyLevel >= 1925 and MyLevel <= 1974) or SMN == "Musketeer Pirate" then
            MN = "Musketeer Pirate"
            LQ = 2
            NQ = "DeepForestIsland2"
            NM = "Musketeer Pirate"
            CFQ = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
            CFM = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375)
        elseif (MyLevel >= 1975 and MyLevel <= 1999) or SMN == "Reborn Skeleton" then
            MN = "Reborn Skeleton"
            LQ = 1
            NQ = "HauntedQuest1"
            NM = "Reborn Skeleton"
            CFQ = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            CFM = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625)
        elseif (MyLevel >= 2000 and MyLevel <= 2024) or SMN == "Living Zombie" then
            MN = "Living Zombie"
            LQ = 2
            NQ = "HauntedQuest1"
            NM = "Living Zombie"
            CFQ = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            CFM = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875)
        elseif (MyLevel >= 2025 and MyLevel <= 2049) or SMN == "Demonic Soul" then
            MN = "Demonic Soul"
            LQ = 1
            NQ = "HauntedQuest2"
            NM = "Demonic Soul"
            CFQ = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0) 
            CFM = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625)
        elseif (MyLevel >= 2050 and MyLevel <= 2074) or SMN == "Posessed Mummy" then
            MN = "Posessed Mummy"
            LQ = 2
            NQ = "HauntedQuest2"
            NM = "Posessed Mummy"
            CFQ = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFM = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625)
        elseif (MyLevel >= 2075 and MyLevel <= 2099) or SMN == "Peanut Scout" then
            MN = "Peanut Scout"
            LQ = 1
            NQ = "NutsIslandQuest"
            NM = "Peanut Scout"
            CFQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFM = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875)
        elseif (MyLevel >= 2100 and MyLevel <= 2124) or SMN == "Peanut President" then
            MN = "Peanut President"
            LQ = 2
            NQ = "NutsIslandQuest"
            NM = "Peanut President"
            CFQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFM = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875)
        elseif (MyLevel >= 2125 and MyLevel <= 2149) or SMN == "Ice Cream Chef" then
            MN = "Ice Cream Chef"
            LQ = 1
            NQ = "IceCreamIslandQuest"
            NM = "Ice Cream Chef"
            CFQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFM = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125)
        elseif (MyLevel >= 2150 and MyLevel <= 2199) or SMN == "Ice Cream Commander" then
            MN = "Ice Cream Commander"
            LQ = 2
            NQ = "IceCreamIslandQuest"
            NM = "Ice Cream Commander"
            CFQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            CFM = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625)
        elseif (MyLevel >= 2200 and MyLevel <= 2224) or SMN == "Cookie Crafter" then
            MN = "Cookie Crafter"
            LQ = 1
            NQ = "CakeQuest1"
            NM = "Cookie Crafter"
            CFQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
            CFM = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375)
        elseif (MyLevel >= 2225 and MyLevel <= 2249) or SMN == "Cake Guard" then
            MN = "Cake Guard"
            LQ = 2
            NQ = "CakeQuest1"
            NM = "Cake Guard"
            CFQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-08, 0.288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, 0.957576931)
            CFM = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875)
        elseif (MyLevel >= 2250 and MyLevel <= 2274) or SMN == "Baking Staff" then
            MN = "Baking Staff"
            LQ = 1
            NQ = "CakeQuest2"
            NM = "Baking Staff"
            CFQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
            CFM = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375)
        elseif (MyLevel >= 2275 and MyLevel <= 2299) or SMN == "Head Baker" then
            MN = "Head Baker"
            LQ = 2
            NQ = "CakeQuest2"
            NM = "Head Baker"
            CFQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, 0.250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
            CFM = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125)
        elseif (MyLevel >= 2300 and MyLevel <= 2324) or SMN == "Cocoa Warrior" then
            MN = "Cocoa Warrior"
            LQ = 1
            NQ = "ChocQuest1"
            NM = "Cocoa Warrior"
            CFQ = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
            CFM = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125)
        elseif (MyLevel >= 2325 and MyLevel <= 2349) or SMN == "Chocolate Bar Battler" then
            MN = "Chocolate Bar Battler"
            LQ = 2
            NQ = "ChocQuest1"
            NM = "Chocolate Bar Battler"
            CFQ = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
            CFM = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109375)
        elseif (MyLevel >= 2350 and MyLevel <= 2374) or SMN == "Sweet Thief" then
            MN = "Sweet Thief"
            LQ = 1
            NQ = "ChocQuest2"
            NM = "Sweet Thief"
            CFQ = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
            CFM = CFrame.new(165.1884765625, 76.05885314941406, -12600.8369140625)
        elseif (MyLevel >= 2375 and MyLevel <= 2399) or SMN == "Candy Rebel" then
            MN = "Candy Rebel"
            LQ = 2
            NQ = "ChocQuest2"
            NM = "Candy Rebel"
            CFQ = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
            CFM = CFrame.new(134.86563110351562, 77.2476806640625, -12876.5478515625)
        elseif (MyLevel >= 2400 and MyLevel <= 2424) or SMN == "Candy Pirate" then
            MN = "Candy Pirate"
            LQ = 1
            NQ = "CandyQuest1"
            NM = "Candy Pirate"
            CFQ = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
            CFM = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296875)
        elseif (MyLevel >= 2425 and MyLevel <= 2449) or SMN == "Snow Demon" then
            MN = "Snow Demon"
            LQ = 2
            NQ = "CandyQuest1"
            NM = "Snow Demon"
            CFQ = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
            CFM = CFrame.new(-880.2006225585938, 71.24776458740234, -14538.609375)
        elseif (MyLevel >= 2450 and MyLevel <= 2474) or SMN == "Isle Outlaw" then
            MN = "Isle Outlaw"
            LQ = 1
            NQ = "TikiQuest1"
            NM = "Isle Outlaw"
            CFQ = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
            CFM = CFrame.new(-16442.814453125, 116.13899993896484, -264.4637756347656)
        elseif (MyLevel >= 2475 and MyLevel <= 2524) or SMN == "Island Boy" then
            MN = "Island Boy"
            LQ = 2
            NQ = "TikiQuest1"
            NM = "Island Boy"
            CFQ = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812)
            CFM = CFrame.new(-16901.26171875, 84.06756591796875, -192.88906860351562)
        elseif (MyLevel >= 2525 and MyLevel <= 2550) or SMN == "Isle Champion" then
            MN = "Isle Champion"
            LQ = 2
            NQ = "TikiQuest2"
            NM = "Isle Champion"
            CFQ = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
            CFM = CFrame.new(-16641.6796875, 235.7825469970703, 1031.282958984375)
            elseif (MyLevel >= 2550 and MyLevel <= 2574) or SMN == "Serpent Hunter" then
            MN = "Serpent Hunter"
            LQ = 1
            NQ = "TikiQuest3"
            NM = "Serpent Hunter"
            CFQ = CFrame.new(-16665.1914, 104.596405, 1579.69434, 0.951068401, -0, -0.308980465, 0, 1, -0, 0.308980465, 0, 0.951068401)
            CFM = CFrame.new(-16521.0625, 106.09285, 1488.78467, 0.469467044, 0, 0.882950008, 0, 1, 0, -0.882950008, 0, 0.469467044)
           elseif MyLevel >= 2575 or SMN == "Skull Slayer" then
            MN = "Skull Slayer"
            LQ = 2
            NQ = "TikiQuest3"
            NM = "Skull Slayer"
            CFQ = CFrame.new(-16665.1914, 104.596405, 1579.69434, 0.951068401, -0, -0.308980465, 0, 1, -0, 0.308980465, 0, 0.951068401)
            CFM = CFrame.new(-16855.043, 122.457253, 1478.15308, -0.999392271, 0, -0.0348687991, 0, 1, 0, 0.0348687991, 0, -0.999392271)
        end
    end
end

function ST(v1)
    local plyr = game:GetService("Players").LocalPlayer
    local char = plyr.Character

    if not v1 then
        _G.StopTween = true
        wait(0.2)
        TP(char.HumanoidRootPart.CFrame)
        wait(0.2)
        if char.HumanoidRootPart:FindFirstChild("BodyClip") then
            char.HumanoidRootPart.BodyClip:Destroy()
        end
        if char:FindFirstChild("Block") then
            char.Block:Destroy()
        end
        _G.StopTween = false
        _G.Clip = false
    end

    if char:FindFirstChild("Highlight") then
        char.Highlight:Destroy()
    end
end

function HRP(v2)
    if not v2 then return end
    return v2.Character:WaitForChild("HumanoidRootPart", 9)
end

function CNT(v3)
    local vcspos = v3.Position
    local minDist = math.huge
    local chosenTeleport = nil
    local y = game.PlaceId

    local TableLocations = {}

    if y == 2753915549 then
        TableLocations = {
            ["Sky3"] = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"] = Vector3.new(-4607, 874, -1667),
            ["UnderWater"] = Vector3.new(61163, 11, 1819),
            ["Underwater City"] = Vector3.new(61165.19140625, 0.18704631924629211, 1897.379150390625),
            ["Pirate Village"] = Vector3.new(-1242.4625244140625, 4.787059783935547, 3901.282958984375),
            ["UnderwaterExit"] = Vector3.new(4050, -1, -1814)
        }
    elseif y == 4442272183 then
        TableLocations = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        }
    elseif y == 7449423635 then
        TableLocations = {
            ["Floating Turtle"] = Vector3.new(-12462, 375, -7552),
            ["Hydra Island"] = Vector3.new(5657.88623046875, 1013.0790405273438, -335.4996337890625),
            ["Mansion"] = Vector3.new(-12462, 375, -7552),
            ["Castle"] = Vector3.new(-5036, 315, -3179),
            ["Dimensional Shift"] = Vector3.new(-2097.3447265625, 4776.24462890625, -15013.4990234375),
            ["Beautiful Pirate"] = Vector3.new(5319, 23, -93),
            ["Beautiful Room"] = Vector3.new(5314.58203, 22.5364361, -125.942276, 1, 2.14762768e-08, -1.99111154e-13, -2.14762768e-08, 1, -3.0510602e-08, 1.98455903e-13, 3.0510602e-08, 1),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103)
        }
    end

    for _, v in pairs(TableLocations) do
        local dist = (v - vcspos).Magnitude
        if dist < minDist then
            minDist = dist
            chosenTeleport = v
        end
    end

    local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    if minDist <= (vcspos - playerPos).Magnitude then
        return chosenTeleport
    end
end

function RE(v4)
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", v4)
    local char = game.Players.LocalPlayer.Character.HumanoidRootPart
    char.CFrame = char.CFrame + Vector3.new(0, 50, 0)
    task.wait(0.5)
end

function TP(v5)
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("HumanoidRootPart") then
        local Distance = (v5.Position - plr.Character.HumanoidRootPart.Position).Magnitude
        if not v5 then 
            return 
        end
        local nearestTeleport = CNT(v5)
        if nearestTeleport then
            RE(nearestTeleport)
        end
        if not plr.Character:FindFirstChild("PartTele") then
            local PartTele = Instance.new("Part", plr.Character)
            PartTele.Size = Vector3.new(10,1,10)
            PartTele.Name = "PartTele"
            PartTele.Anchored = true
            PartTele.Transparency = 1
            PartTele.CanCollide = true
            PartTele.CFrame = HRP(plr).CFrame 
            PartTele:GetPropertyChangedSignal("CFrame"):Connect(function()
                if not isTeleporting then return end
                task.wait()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    HRP(plr).CFrame = PartTele.CFrame
                end
            end)
        end
        isTeleporting = true
        local Tween = game:GetService("TweenService"):Create(plr.Character.PartTele, TweenInfo.new(Distance / 360, Enum.EasingStyle.Linear), {CFrame = v5})
        Tween:Play()
        Tween.Completed:Connect(function(status)
            if status == Enum.PlaybackState.Completed then
                if plr.Character:FindFirstChild("PartTele") then
                    plr.Character.PartTele:Destroy()
                end
                isTeleporting = false
            end
        end)
    end
end

function TP1(v5)
    TP(v5)
end

function EW(v6)
    if not _G.NotAutoEquip then
        if game.Players.LocalPlayer.Backpack:FindFirstChild(v6) then
            Tool = game.Players.LocalPlayer.Backpack:FindFirstChild(v6)
            wait(.1)
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(Tool)
        end
    end
end

function AH()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
        if character and not character:FindFirstChild("HasBuso") then
    local remote = game:GetService("ReplicatedStorage").Remotes.CommF_
        if remote then
            remote:InvokeServer("Buso") 
        end
    end
end

spawn(function()
    while task.wait() do
        pcall(function()
                if _G.Auto_Farm_Level then
                if not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local Noclip = Instance.new("BodyVelocity")
                    Noclip.Name = "BodyClip"
                    Noclip.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
                    Noclip.MaxForce = Vector3.new(100000,100000,100000)
                    Noclip.Velocity = Vector3.new(0,0,0)
                end
            else
                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
            end
        end)
    end
end)

spawn(function()
    pcall(function()
        game:GetService("RunService").Stepped:Connect(function()
            if _G.Auto_Farm_Level then
                    for i,v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end)
end)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Blox Hee Blox Tad",
    SubTitle = "by Unique Sute Roe :3",
    TabWidth = 100,
    Size = UDim2.fromOffset(600, 350),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})
local Tabs = {
    Main = Window:AddTab({ Title = "General", Icon = "" }),
} local Options = Fluent.Options

do
_G.SW = "Melee"

task.spawn(function()
    while wait() do
        pcall(function()
         if _G.SW == "Melee" then
            for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v.ToolTip == "Melee" then
                    if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
                        _G.SW = v.Name
                    end
                end
            end
        elseif _G.SW == "Sword" then
            for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v.ToolTip == "Sword" then
                    if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
                        _G.SW = v.Name
                    end
                end
            end
        elseif _G.SW == "Gun" then
            for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v.ToolTip == "Gun" then
                    if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
                        _G.SW = v.Name
                    end
                end
            end
        elseif _G.SW == "Fruit" then
            for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if v.ToolTip == "Blox Fruit" then
                    if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
                         _G.SW = v.Name
                        end
                      end
                end
            end
         end)
     end
end)

local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Auto Farm Level", Default = false}); Toggle:OnChanged(function(Value)
    _G.Auto_Farm_Level = Value
    ST(_G.Auto_Farm_Level)
end); Options.MyToggle:SetValue(false)

spawn(function()
    while wait() do
        if _G.Auto_Farm_Level then
            pcall(function()
                local QuestTitle = game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                CQ()
                if not string.find(QuestTitle, NM) then
                    SB = false
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                end
                if game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false then
                    SB = false
                    if BTP then
                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFQ.Position).Magnitude > 1500 then
                    TP1(CFQ)
                    elseif (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFQ.Position).Magnitude < 1500 then
                    TP1(CFQ)
                    end
                else
                    TP1(CFQ)
                end
                if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFQ.Position).Magnitude <= 20 then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest",NQ,LQ)
                end
                elseif game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == true then
                    if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "kissed") then
                        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            if string.find(v.Name,"kissed Warrior") then
                                if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                    if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NM) then
                                        repeat task.wait()
                                            EW(_G.SW)
                                            PMN = v.HumanoidRootPart.CFrame
                                            TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                            v.HumanoidRootPart.CanCollide = false
                                            v.Humanoid.WalkSpeed = 0
                                            v.Head.CanCollide = false
                                            MF = v.Name
                                            v.HumanoidRootPart.Size = Vector3.new(70,70,70)
                                            SB = true
                                            game:GetService'VirtualUser':CaptureController()
                                            game:GetService'VirtualUser':Button1Down(Vector2.new(1280, 672))
                                        until not _G.Auto_Farm_Level or v.Humanoid.Health <= 0 or not v.Parent or game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false
                                    else
                                        SB = false
                                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                                    end
                                end
                            elseif string.find(v.Name,"kissed Warrior") == nil then
                                TP1(CFM)
                                SB = false
                                if game:GetService("ReplicatedStorage"):FindFirstChild(MN) then
                                    TP1(game:GetService("ReplicatedStorage"):FindFirstChild(MN).HumanoidRootPart.CFrame * CFrame.new(0,20,0))
                                end
                            end
                        end
                    else
                        if game:GetService("Workspace").Enemies:FindFirstChild(MN) then
                            for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                                if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                    if v.Name == MN then
                                        if string.find(game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NM) then
                                            repeat task.wait()
                                                EW(_G.SW)
                                                AH()
                                                PMN = v.HumanoidRootPart.CFrame
                                                TP(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                                v.HumanoidRootPart.CanCollide = false
                                                v.Humanoid.WalkSpeed = 0
                                                v.Head.CanCollide = false
                                                v.HumanoidRootPart.Size = Vector3.new(70,70,70)
                                                SB = true
                                                MF = v.Name          
                                                game:GetService'VirtualUser':CaptureController()
                                                game:GetService'VirtualUser':Button1Down(Vector2.new(1280, 672))
                                            until not _G.Auto_Farm_Level or v.Humanoid.Health <= 0 or not v.Parent or game:GetService("Players").LocalPlayer.PlayerGui.Main.Quest.Visible == false
                                        else
                                            SB = false
                                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                                        end
                                    end
                                end
                            end
                        else
                            TP1(CFM)
                            SB = false
                            if game:GetService("ReplicatedStorage"):FindFirstChild(MN) then
                                TP1(game:GetService("ReplicatedStorage"):FindFirstChild(MN).HumanoidRootPart.CFrame * CFrame.new(0,20,0))
                            end
                        end
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        pcall(function()
            CQ()
            if _G.BMS and SB and PMN then
                for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    local isValid = (v.Name == MF or v.Name == MN)
                    local hasPart = v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head")
                    local isAlive = v.Humanoid and v.Humanoid.Health > 0
                    local inRange = (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 350

                    if isValid and hasPart and isAlive and inRange then
                        local distToPMN = (v.HumanoidRootPart.Position - PMN.Position).Magnitude
                        if distToPosMon <= 350 then
                            v.HumanoidRootPart.CanCollide = false
                            v.Head.CanCollide = false
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            v.HumanoidRootPart.CFrame = PMN
                            if v.Humanoid:FindFirstChild("Animator") then
                                v.Humanoid.Animator:Destroy()
                            end
                        end
                    end
                end
                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                if _G.BMB and BMO then
                    if v.Name == MF and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        if v.Name == "Factory Staff" then
                            if (v.HumanoidRootPart.Position - FarmPos.Position).Magnitude <= 1000000000 then
                                v.Head.CanCollide = false
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.CFrame = FarmPos
                                if v.Humanoid:FindFirstChild("Animator") then
                                    v.Humanoid.Animator:Destroy()
                                end
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                            end
                        elseif v.Name == MF then
                            if (v.HumanoidRootPart.Position - FarmPos.Position).Magnitude <= 10000000000 then
                                v.HumanoidRootPart.CFrame = FarmPos
                                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                v.HumanoidRootPart.Transparency = 1
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                if v.Humanoid:FindFirstChild("Animator") then
                                    v.Humanoid.Animator:Destroy()
                                end
                                v.HumanoidRootPart.CanCollide = false
                                v.Head.CanCollide = false
                                v.Humanoid:ChangeState(11)
                                v.Humanoid:ChangeState(14)
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

if not syn then isnetworkowner = function() return true end end
getgenv().BM = function(F, z)
    PMN = F
    NM = z
end

task.spawn(function()
    while task.wait() do
        pcall(function()
            if PMN then
                CQ() 
                for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if syn then
                        if v.Name == NM and v.Name ~= "Ice Admiral" and v.Name ~= "Don Swan" and v.Name ~= "Saber Expert" and v.Name ~= "Longma" and  v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                            if isnetworkowner(v.HumanoidRootPart) then
                                v.HumanoidRootPart.CFrame = PMN
                                v.Humanoid.JumpPower = 0
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(2,2,2)
                                if v.Humanoid:FindFirstChild("Animator") then
                                    v.Humanoid.Animator:Destroy()
                                end
                                sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)
                                v.Humanoid:ChangeState(11)
                            end
                        end
                    else
                        if v.Name == NM and v.Name ~= "Ice Admiral" and v.Name ~= "Don Swan" and v.Name ~= "Saber Expert" and v.Name ~= "Longma" and  v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
                            v.HumanoidRootPart.CFrame = PMN
                            v.Humanoid.JumpPower = 0
                            v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.CanCollide = false
                            v.HumanoidRootPart.Size = Vector3.new(2,2,2)
                            if v.Humanoid:FindFirstChild("Animator") then
                                v.Humanoid.Animator:Destroy()
                            end
                            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)
                            v.Humanoid:ChangeState(11)
                        end
                    end
                end
            end
        end)
    end
end) PosY = 35
end
