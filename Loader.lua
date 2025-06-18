local k, q = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dimziexx/InprisationDev/refs/heads/main/Core/Main/ESP.lua"))()
end)

if not k then
    warn("Error loading ESP script: " .. tostring(q))
end

local j, m = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dimziexx/InprisationDev/refs/heads/main/Core/Main/AIM.lua"))()
end)

if not j then
    warn("Error loading AIM script: " .. tostring(m))
end
