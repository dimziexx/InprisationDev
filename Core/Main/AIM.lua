local p = game:GetService("Players")
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local l = p.LocalPlayer
local c = workspace.CurrentCamera

local s = {
    e = false,
    t = "Head",
    d = 1000,
    s = 0.5,
    fov = 400,
    visible = false
}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = s.visible
fovCircle.Radius = s.fov
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.Transparency = 1

local function g()
    local cp = nil
    local sd = s.fov
    
    for _, v in ipairs(p:GetPlayers()) do
        if v == l then continue end
        
        local ch = v.Character
        if not ch then continue end
        
        local h = ch:FindFirstChild("Humanoid")
        if not h or h.Health <= 0 then continue end
        
        local tp = ch:FindFirstChild(s.t)
        if not tp then continue end
        
        -- Check if target is behind a wall
        local ray = Ray.new(c.CFrame.Position, (tp.Position - c.CFrame.Position).Unit * s.d)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {l.Character})
        if hit and hit:IsDescendantOf(ch) then
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
    
    if i.KeyCode == Enum.KeyCode.X then
        s.visible = not s.visible
        fovCircle.Visible = s.visible
    elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
        s.e = true
        fovCircle.Visible = s.visible
    end
end)

u.InputEnded:Connect(function(i, gp)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        s.e = false
    end
end)

r.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y / 2)
    
    if not s.e then return end
    
    local cp = g()
    if not cp or not cp.Character then return end
    
    local tp = cp.Character:FindFirstChild(s.t)
    if not tp then return end
    
    a(tp)
end)
