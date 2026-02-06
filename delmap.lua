for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Transparency = 1
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 then
            v.Transparency = 1
        end
    end
end)
