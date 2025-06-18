-- working not for all antiCheats and not for all items, only for people
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Glow_Elements = {}

local function CreateGlow(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local glowData = Glow_Elements[player]
    if not glowData then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.2
        highlight.Parent = player.Character

        Glow_Elements[player] = {
            Highlight = highlight
        }
    end
end

local function RemoveGlow(player)
    local glowData = Glow_Elements[player]
    if glowData then
        if glowData.Highlight then
            glowData.Highlight:Destroy()
        end
        Glow_Elements[player] = nil
    end
end

local function UpdateGlow()
    for player, glowData in pairs(Glow_Elements) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                glowData.Highlight.Enabled = true
            else
                glowData.Highlight.Enabled = false
            end
        else
            glowData.Highlight.Enabled = false
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateGlow(player)
    end)
    player.CharacterRemoving:Connect(function()
        RemoveGlow(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveGlow(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        CreateGlow(player)
    end
    player.CharacterAdded:Connect(function()
        CreateGlow(player)
    end)
    player.CharacterRemoving:Connect(function()
        RemoveGlow(player)
    end)
end

RunService.Heartbeat:Connect(UpdateGlow)
