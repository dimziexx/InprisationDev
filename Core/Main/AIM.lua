local p = game:GetService("Players")
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local l = p.LocalPlayer
local c = workspace.CurrentCamera

local s = {
    e = false,
    t = "Head",
    d = 1000,
    s = 0.5
}

local function g()
    local cp = nil
    local sd = s.d
    
    for _, v in ipairs(p:GetPlayers()) do
        if v == l then continue end
        
        local ch = v.Character
        if not ch then continue end
        
        local h = ch:FindFirstChild("Humanoid")
        if not h or h.Health <= 0 then continue end
        
        local tp = ch:FindFirstChild(s.t)
        if not tp then continue end
        
        local sp = c:WorldToScreenPoint(tp.Position)
        if sp.Z < 0 then continue end
        
        local sc = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y / 2)
        local pos = Vector2.new(sp.X, sp.Y)
        local d = (pos - sc).Magnitude
        
        if d < sd then
            cp = v
            sd = d
        end
    end
    
    return cp
end

local function a(t)
    if not t then return end
    
    local tp = t.Position
    local cp = c.CFrame.Position
    
    local ac = CFrame.lookAt(cp, tp)
    c.CFrame = c.CFrame:Lerp(ac, s.s)
end

u.InputBegan:Connect(function(i, gp)
    if gp then return end
    
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        s.e = true
    end
end)

u.InputEnded:Connect(function(i, gp)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        s.e = false
    end
end)

r.RenderStepped:Connect(function()
    if not s.e then return end
    
    local cp = g()
    if not cp or not cp.Character then return end
    
    local tp = cp.Character:FindFirstChild(s.t)
    if not tp then return end
    
    a(tp)
end)
