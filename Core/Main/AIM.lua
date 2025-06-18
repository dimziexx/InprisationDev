local p = game:GetService("Players")
local r = game:GetService("RunService")
local u = game:GetService("UserInputService")
local l = p.LocalPlayer
local c = workspace.CurrentCamera
local n = game:GetService("NetworkClient")
local s = game:GetService("Stats")

local cfg = {
    e = false,
    t = "Head",
    d = 1000,
    s = 0.05,
    fov = 400,
    visible = true,
    dt = 0.008,
    pt = "Nearest",
    m = "Advanced",
    ps = 0.25,
    pc = true,
    pa = 1.0
}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = cfg.visible
fovCircle.Radius = cfg.fov
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 0, 255)
fovCircle.Filled = false
fovCircle.Transparency = 0.7
fovCircle.NumSides = 60

local ct = nil
local lt = 0
local tp = nil
local lp = Vector3.new()
local pd = 0
local tc = CFrame.new()
local pv = Vector3.new()
local ph = {}
local hx = 0
local lastPing = 0
local avgPing = 0
local pingBuffer = {}
local lastFPS = 0
local fpsBuffer = {}
local pingText = Drawing.new("Text")
pingText.Visible = true
pingText.Size = 18
pingText.Color = Color3.fromRGB(255, 255, 255)
pingText.Center = false
pingText.Outline = true
pingText.Position = Vector2.new(10, 10)
pingText.Font = 3

local function updatePing()
    local ping = n:GetServerStats().ServerStatsItem[1].Value
    local fps = 1 / s:GetValue("Workspace", "LastRenderTime")
    
    table.insert(pingBuffer, ping)
    if #pingBuffer > 10 then table.remove(pingBuffer, 1) end
    
    table.insert(fpsBuffer, fps)
    if #fpsBuffer > 10 then table.remove(fpsBuffer, 1) end
    
    local sum = 0
    for _, v in ipairs(pingBuffer) do sum = sum + v end
    avgPing = sum / #pingBuffer
    
    local fpsSum = 0
    for _, v in ipairs(fpsBuffer) do fpsSum = fpsSum + v end
    lastFPS = fpsSum / #fpsBuffer
    
    pingText.Text = string.format("Ping: %d ms | FPS: %d | Mode: %s", math.floor(avgPing), math.floor(lastFPS), cfg.m)
    
    return avgPing, lastFPS
end

local function g()
    local cp = nil
    local sd = cfg.fov
    local sc = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y / 2)
    local lh = 0
    
    for _, v in ipairs(p:GetPlayers()) do
        if v == l then continue end
        
        local ch = v.Character
        if not ch then continue end
        
        local h = ch:FindFirstChild("Humanoid")
        if not h or h.Health <= 0 then continue end
        
        local tp = ch:FindFirstChild(cfg.t)
        if not tp then continue end
        
        local ray = Ray.new(c.CFrame.Position, (tp.Position - c.CFrame.Position).Unit * cfg.d)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {l.Character})
        if hit and hit:IsDescendantOf(ch) then
            local sp = c:WorldToScreenPoint(tp.Position)
            if sp.Z < 0 then continue end
            
            local pos = Vector2.new(sp.X, sp.Y)
            local d = (pos - sc).Magnitude
            
            if d < sd then
                if cfg.pt == "Nearest" then
                    cp = v
                    sd = d
                    pd = d
                elseif cfg.pt == "Health" then
                    if h.Health > lh then
                        cp = v
                        lh = h.Health
                        pd = d
                    end
                end
            end
        end
    end
    
    return cp
end

local function ap(pos, vel, acc)
    local pingCompensation = cfg.pc and (avgPing / 1000 * cfg.pa) or 0
    local t = cfg.ps + pingCompensation
    return pos + vel * t + 0.5 * acc * t^2
end

local function pr(t)
    if not t then return Vector3.new() end
    
    local pos = t.Position
    local vel = t.AssemblyLinearVelocity
    local acc = (vel - pv) / (0.016 * (60 / math.max(lastFPS, 1)))
    pv = vel
    
    if cfg.m == "Advanced" then
        local predicted = ap(pos, vel, acc)
        
        if #ph < 5 then
            table.insert(ph, predicted)
        else
            ph[hx % 5 + 1] = predicted
        end
        hx = hx + 1
        
        local avg = Vector3.new()
        for _, v in ipairs(ph) do
            avg = avg + v
        end
        avg = avg / #ph
        
        return avg
    elseif cfg.m == "Predict" then
        local pingCompensation = cfg.pc and (avgPing / 1000 * cfg.pa) or 0
        return pos + vel * (cfg.ps + pingCompensation)
    else
        return pos
    end
end

local function a(t)
    if not t then return end
    
    local tpos = pr(t)
    local cpos = c.CFrame.Position
    
    if cfg.m == "Smooth" then
        if (tpos - lp).Magnitude > 10 then
            lp = tpos
        else
            lp = lp:Lerp(tpos, 0.2)
        end
        
        local ac = CFrame.lookAt(cpos, lp)
        tc = tc:Lerp(ac, cfg.s)
        c.CFrame = tc
    elseif cfg.m == "Linear" then
        local ac = CFrame.lookAt(cpos, tpos)
        c.CFrame = c.CFrame:Lerp(ac, cfg.s)
    elseif cfg.m == "Predict" then
        local ac = CFrame.lookAt(cpos, tpos)
        c.CFrame = c.CFrame:Lerp(ac, cfg.s)
    elseif cfg.m == "Bezier" then
        if (tpos - lp).Magnitude > 10 then
            lp = tpos
        else
            local mid = lp + (tpos - lp) * 0.5 + Vector3.new(0, math.sin(tick() * 2) * 0.5, 0)
            lp = lp:Lerp(mid, 0.3):Lerp(tpos, 0.3)
        end
        
        local ac = CFrame.lookAt(cpos, lp)
        tc = tc:Lerp(ac, cfg.s)
        c.CFrame = tc
    elseif cfg.m == "Advanced" then
        if (tpos - lp).Magnitude > 5 then
            lp = tpos
        else
            lp = lp:Lerp(tpos, 0.4)
        end
        
        local ac = CFrame.lookAt(cpos, lp)
        tc = tc:Lerp(ac, cfg.s)
        c.CFrame = tc
    end
end

u.InputBegan:Connect(function(i, gp)
    if gp then return end
    
    if i.KeyCode == Enum.KeyCode.X then
        cfg.visible = not cfg.visible
        fovCircle.Visible = cfg.visible
    elseif i.KeyCode == Enum.KeyCode.Z then
        if cfg.pt == "Nearest" then
            cfg.pt = "Health"
            fovCircle.Color = Color3.fromRGB(0, 255, 0)
        else
            cfg.pt = "Nearest"
            fovCircle.Color = Color3.fromRGB(255, 0, 255)
        end
    elseif i.KeyCode == Enum.KeyCode.C then
        local modes = {"Advanced", "Smooth", "Linear", "Predict", "Bezier"}
        local idx = table.find(modes, cfg.m) or 1
        cfg.m = modes[(idx % #modes) + 1]
        
        if cfg.m == "Smooth" then
            fovCircle.Color = Color3.fromRGB(255, 0, 0)
        elseif cfg.m == "Linear" then
            fovCircle.Color = Color3.fromRGB(0, 0, 255)
        elseif cfg.m == "Predict" then
            fovCircle.Color = Color3.fromRGB(255, 165, 0)
        elseif cfg.m == "Bezier" then
            fovCircle.Color = Color3.fromRGB(255, 0, 255)
        elseif cfg.m == "Advanced" then
            fovCircle.Color = Color3.fromRGB(255, 0, 255)
        end
    elseif i.KeyCode == Enum.KeyCode.V then
        local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}
        local idx = table.find(parts, cfg.t) or 1
        cfg.t = parts[(idx % #parts) + 1]
    elseif i.KeyCode == Enum.KeyCode.P then
        cfg.pc = not cfg.pc
        pingText.Color = cfg.pc and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
        cfg.e = true
        fovCircle.Visible = cfg.visible
        ct = nil
        tp = nil
        lp = Vector3.new()
        tc = c.CFrame
        ph = {}
        hx = 0
        pv = Vector3.new()
    end
end)

u.InputEnded:Connect(function(i, gp)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        cfg.e = false
        ct = nil
        tp = nil
        lp = Vector3.new()
        ph = {}
    end
end)

r.RenderStepped:Connect(function()
    updatePing()
    
    fovCircle.Position = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y / 2)
    fovCircle.Radius = cfg.fov
    
    if not cfg.e then return end
    
    local n = tick()
    if n - lt < cfg.dt then return end
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
        ph = {}
        hx = 0
        pv = Vector3.new()
    end
    
    if not tp and ct.Character then
        tp = ct.Character:FindFirstChild(cfg.t)
        if not tp and ct.Character then
            for _, part in ipairs({"Head", "HumanoidRootPart", "Torso", "UpperTorso"}) do
                tp = ct.Character:FindFirstChild(part)
                if tp then break end
            end
        end
        
        if tp then
            lp = tp.Position
            tc = c.CFrame
            pv = tp.AssemblyLinearVelocity
        end
    end
    
    if tp then
        a(tp)
    end
end)

u.MouseWheelForward:Connect(function()
    if u:IsKeyDown(Enum.KeyCode.LeftShift) then
        cfg.fov = math.clamp(cfg.fov - 20, 50, 800)
    elseif u:IsKeyDown(Enum.KeyCode.LeftControl) then
        cfg.ps = math.clamp(cfg.ps - 0.05, 0.05, 1)
    elseif u:IsKeyDown(Enum.KeyCode.LeftAlt) then
        cfg.pa = math.clamp(cfg.pa - 0.1, 0.1, 3)
        pingText.Text = string.format("Ping: %d ms | FPS: %d | Mode: %s | Ping Mult: %.1f", math.floor(avgPing), math.floor(lastFPS), cfg.m, cfg.pa)
    end
end)

u.MouseWheelBackward:Connect(function()
    if u:IsKeyDown(Enum.KeyCode.LeftShift) then
        cfg.fov = math.clamp(cfg.fov + 20, 50, 800)
    elseif u:IsKeyDown(Enum.KeyCode.LeftControl) then
        cfg.ps = math.clamp(cfg.ps + 0.05, 0.05, 1)
    elseif u:IsKeyDown(Enum.KeyCode.LeftAlt) then
        cfg.pa = math.clamp(cfg.pa + 0.1, 0.1, 3)
        pingText.Text = string.format("Ping: %d ms | FPS: %d | Mode: %s | Ping Mult: %.1f", math.floor(avgPing), math.floor(lastFPS), cfg.m, cfg.pa)
    end
end)
