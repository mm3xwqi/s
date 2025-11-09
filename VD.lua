
local get_luau =  function()
    local t = {}
    for k, v in game:HttpGet("https://offsets.ntgetwritewatch.workers.dev/offsets.json"):gmatch(
        '"([^"]-)"%s*:%s*"([^"]-)"') do
        t[k] = v
    end
    return t
end

local FrameRotation = get_luau()["FrameRotation"]



local plr = game:GetService("Players").LocalPlayer

local PlayerGui = plr:FindFirstChild("PlayerGui")

function decimalToHex(decimal)
	return "0x" .. string.format("%X", decimal)
end



local function normalizeAngle(angle)
	angle = angle % 360
	if angle < 0 then
		angle = angle + 360
	end
	return angle
end

local function getAngleDifference(angle1, angle2)
	angle1 = normalizeAngle(angle1)
	angle2 = normalizeAngle(angle2)

	local diff = math.abs(angle1 - angle2)

	if diff > 180 then
		diff = 360 - diff
	end

	return diff
end

local function isRotationClose(rotation1, rotation2, threshold)
	threshold = threshold or 5 
	local difference = getAngleDifference(rotation1, rotation2)
	return difference <= threshold
end


while true do
	local CheckPrompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
	if CheckPrompt then
		local Rotation = memory_read("float", CheckPrompt.Check.Line.Address + FrameRotation)
		local GoalRotation = memory_read("float", CheckPrompt.Check.Goal.Address + FrameRotation)

		Rotation = normalizeAngle(Rotation)
		GoalRotation = normalizeAngle(GoalRotation)

		local lowerSuccess = normalizeAngle(104 + GoalRotation)
		local upperSuccess = normalizeAngle(114 + GoalRotation)
		local upperNeutral = normalizeAngle(159 + GoalRotation)

		if lowerSuccess <= Rotation and Rotation <= upperSuccess then
			print("Success!", Rotation, GoalRotation)
			keypress(32)
		elseif upperSuccess < Rotation and Rotation <= upperNeutral then
			print("Neutral", Rotation, GoalRotation)
		end
	end
	task.wait()
end
