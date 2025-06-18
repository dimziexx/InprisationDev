local kz, qx = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dimziexx/InprisationDev/refs/heads/main/Core/Main/ESP.lua"))()
end)

if not kz then
    warn("Error loading ESP script: " .. tostring(qx))
end
