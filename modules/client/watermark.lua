
-- EvoAPI Rainbow Watermark (HUD) - client (DrawText-based)
local enabled = Config.Watermark.Enabled
local text = Config.Watermark.Text
local x, y, scale = Config.Watermark.X, Config.Watermark.Y, Config.Watermark.Scale
local rainbow = Config.Watermark.Rainbow
local speed = Config.Watermark.Speed
local hue = 0.0

local function HSVToRGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    local r,g,b
    if i == 0 then r,g,b = v,t,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t,p,v
    else r,g,b = v,p,q end
    return math.floor(r*255), math.floor(g*255), math.floor(b*255)
end

local function DrawBottomRight(txt)
    local r, g, b = 255,255,255
    if rainbow then
        r,g,b = HSVToRGB(hue, 1, 1)
        hue = hue + (speed or 0.0015)
        if hue > 1 then hue = 0 end
    end
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextRightJustify(true)
    SetTextWrap(0.0, x)
    SetTextEntry("STRING")
    AddTextComponentString(txt)
    DrawText(x, y)
end

RegisterNetEvent("EvoAPI:Watermark:Set", function(newText)
    text = tostring(newText or text or "Evo RP")
end)

CreateThread(function()
    while true do
        Wait(0)
        if enabled and text and text ~= "" then
            DrawBottomRight(text)
        else
            Wait(500)
        end
    end
end)
