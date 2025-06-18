local p=game:GetService("Players")
local r=game:GetService("RunService")
local l=p.LocalPlayer

local q={}

local function x(a)
    if a==l or not a.Character or not a.Character:FindFirstChild("HumanoidRootPart")then
        return
    end

    local g=q[a]
    if not g then
        local h=Instance.new("Highlight")
        h.Adornee=a.Character
        h.FillColor=Color3.fromRGB(255,0,0)
        h.OutlineColor=Color3.fromRGB(255,255,255)
        h.FillTransparency=0.5
        h.OutlineTransparency=0.2
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent=a.Character

        q[a]={
            h=h
        }
    end
end

local function z(a)
    local g=q[a]
    if g then
        if g.h then
            g.h:Destroy()
        end
        q[a]=nil
    end
end

local function y()
    for a,g in pairs(q)do
        if not a or not a.Character then
            if g.h then
                g.h.Enabled=false
            end
            continue
        end
        
        if a.Character:FindFirstChild("HumanoidRootPart")then
            local m=a.Character:FindFirstChild("Humanoid")
            if m and m.Health>0 then
                g.h.Enabled=true
            else
                g.h.Enabled=false
            end
        else
            g.h.Enabled=false
        end
    end
end

local u=r.RenderStepped:Connect(y)

p.PlayerAdded:Connect(function(a)
    a.CharacterAdded:Connect(function()
        task.delay(0.1,function()
            x(a)
        end)
    end)
    a.CharacterRemoving:Connect(function()
        z(a)
    end)
end)

p.PlayerRemoving:Connect(function(a)
    z(a)
end)

for _,a in ipairs(p:GetPlayers())do
    if a.Character then
        task.delay(0.1,function()
            x(a)
        end)
    end
    a.CharacterAdded:Connect(function()
        task.delay(0.1,function()
            x(a)
        end)
    end)
    a.CharacterRemoving:Connect(function()
        z(a)
    end)
end
