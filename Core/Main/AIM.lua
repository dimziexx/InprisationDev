local p = game:GetService("Players")
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local l = p.LocalPlayer
local c = workspace.CurrentCamera

local s = {
    e = false,
    t = "Head",
    d = 1000,
    s = 0.2,
    fov = 400,
    visible = false,
    dt = 0.05
}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = s.visible
fovCircle.Radius = s.fov
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.Transparency = 1

local ct = nil
local lt = 0
local tp = nil

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
    
    local tpos = t.Position
    local cpos = c.CFrame.Position
    
    local ac = CFrame.lookAt(cpos, tpos)
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
        ct = nil
        tp = nil
    end
end)

u.InputEnded:Connect(function(i, gp)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        s.e = false
        ct = nil
        tp = nil
    end
end)

r.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y / 2)
    
    if not s.e then return end
    
    local n = tick()
    if n - lt < s.dt then return end
    lt = n
    
    local cp = g()
    if not cp then
        ct = nil
        tp = nil
        return
    end
    
    if cp ~= ct then
        ct = cp
        tp = nil
    end
    
    if not tp and ct.Character then
        tp = ct.Character:FindFirstChild(s.t)
    end
    
    if tp then
        a(tp)
    end
end)
