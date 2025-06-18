-- working not for all places and only for players.
local Pz = game:GetService("Players")
local Rz = game:GetService("RunService")
local Lz = Pz.LocalPlayer

local Qw = {}

local function Xy(p)
    if p == Lz or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local gd = Qw[p]
    if not gd then
        local hl = Instance.new("Highlight")
        hl.Adornee = p.Character
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = p.Character

        Qw[p] = {
            Ht = hl
        }
    end
end

local function Zt(p)
    local gd = Qw[p]
    if gd then
        if gd.Ht then
            gd.Ht:Destroy()
        end
        Qw[p] = nil
    end
end

local function Yp()
    for p, gd in pairs(Qw) do
        if not p or not p.Character then
            if gd.Ht then
                gd.Ht.Enabled = false
            end
            continue
        end
        
        if p.Character:FindFirstChild("HumanoidRootPart") then
            local hm = p.Character:FindFirstChild("Humanoid")
            if hm and hm.Health > 0 then
                gd.Ht.Enabled = true
            else
                gd.Ht.Enabled = false
            end
        else
            gd.Ht.Enabled = false
        end
    end
end

local updateConnection = nil
updateConnection = Rz.RenderStepped:Connect(Yp)

Pz.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.delay(0.1, function()
            Xy(p)
        end)
    end)
    p.CharacterRemoving:Connect(function()
        Zt(p)
    end)
end)

Pz.PlayerRemoving:Connect(function(p)
    Zt(p)
end)

for _, p in ipairs(Pz:GetPlayers()) do
    if p.Character then
        task.delay(0.1, function()
            Xy(p)
        end)
    end
    p.CharacterAdded:Connect(function()
        task.delay(0.1, function()
            Xy(p)
        end)
    end)
    p.CharacterRemoving:Connect(function()
        Zt(p)
    end)
end
