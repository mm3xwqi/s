for _, v in ipairs(workspace:GetDescendants()) do
    pcall(function()
        if v:IsA("BasePart") then
            v.Transparency = 1
        end
    end)
end
workspace.DescendantAdded:Connect(function(v)
    pcall(function()
        if v:IsA("BasePart") then
            v.Transparency = 1
        end
    end)
end)
