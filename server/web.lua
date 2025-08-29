
-- EvoAPI Web Panel (beta) using SetHttpHandler
local basePath = (Config.WebPanel and Config.WebPanel.BasePath) or "/evoapi"
local token = (Config.WebPanel and Config.WebPanel.Token) or ""

local function isAuthorized(qs)
    return token ~= "" and qs.token == token
end

local function parseQuery(url)
    local qs = {}
    local q = url:match("%?(.*)$")
    if not q then return qs end
    for pair in string.gmatch(q, "([^&]+)") do
        local k, v = pair:match("([^=]+)=?(.*)")
        if k then
            k = k:gsub("%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
            v = (v or ""):gsub("%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
            qs[k] = v
        end
    end
    return qs
end

local function json(obj) return tostring(obj and (type(obj)=="table" and (function() return require('json').encode(obj) end)() or obj) or "null") end

local function sendJSON(res, tbl)
    res.writeHead(200, {["Content-Type"]="application/json"})
    res.send(json(tbl))
end

local function sendText(res, txt)
    res.writeHead(200, {["Content-Type"]="text/plain; charset=utf-8"})
    res.send(txt or "")
end

local function sendHTML(res, html)
    res.writeHead(200, {["Content-Type"]="text/html; charset=utf-8"})
    res.send(html or "")
end

local function readAsset(path)
    return LoadResourceFile(GetCurrentResourceName(), path)
end

local function listPlayers()
    local arr = {}
    for _, id in ipairs(GetPlayers()) do
        table.insert(arr, { id = tonumber(id), name = GetPlayerName(id) or ("Player "..id), group = EvoAPI.GetGroup(id) })
    end
    return arr
end

local function handleAPI(req, res, url, qs)
    if not isAuthorized(qs) then
        res.writeHead(401); return res.send("Unauthorized")
    end

    if url:match("^"..basePath.."/api/players") then
        return sendJSON(res, { ok=true, players=listPlayers() })
    end

    if url:match("^"..basePath.."/api/setgroup") then
        local id = tonumber(qs.id or "")
        local group = tostring(qs.group or ""):lower()
        if not id or not GetPlayerName(id) or group == "" then
            return sendJSON(res, { ok=false, error="Usage: setgroup?id=<id>&group=<owner|admin|mod|user>" })
        end
        local identifier = EvoAPI.PrimaryIdentifier(id)
        if not identifier then return sendJSON(res, { ok=false, error="No identifier" }) end
        EvoAPI.DBSetGroup(identifier, group)
        EvoAPI.DiscordLog("Group Changed (Web)", ("Set **%s** to **%s**"):format(GetPlayerName(id) or id, group), 0xFEE75C)
        return sendJSON(res, { ok=true })
    end

    if url:match("^"..basePath.."/api/watermark") then
        local text = tostring(qs.text or "")
        if text == "" then return sendJSON(res, { ok=false, error="Missing text" }) end
        EvoAPI.Broadcast("EvoAPI:Watermark:Set", text)
        return sendJSON(res, { ok=true })
    end

    if url:match("^"..basePath.."/api/reload") then
        TriggerEvent("EvoAPI:ApplyVMenuPerms")
        return sendJSON(res, { ok=true })
    end

    res.writeHead(404); res.send("Not Found")
end

local function servePanel(res)
    local html = readAsset("web/panel.html")
    return sendHTML(res, html or "<h1>EvoAPI Panel</h1>")
end

local function serveStatic(res, file)
    local data = readAsset(file)
    if not data then res.writeHead(404); return res.send("Not Found") end
    if file:match("%.css$") then res.writeHead(200, {["Content-Type"]="text/css"}) end
    if file:match("%.js$") then res.writeHead(200, {["Content-Type"]="application/javascript"}) end
    res.send(data)
end

SetHttpHandler(function(req, res)
    if not (Config.WebPanel and Config.WebPanel.Enabled) then
        res.writeHead(404); return res.send("Web panel disabled")
    end

    local url = req.url or req.path or "/"
    local qs = parseQuery(url)

    -- API routes
    if url:find(basePath.."/api/") == 1 then
        return handleAPI(req, res, url, qs)
    end

    -- Panel + static
    if url == basePath or url == basePath.."/" or url:find(basePath.."/panel") == 1 then
        return servePanel(res)
    end
    if url:find(basePath.."/static/") == 1 then
        local file = url:gsub("^"..basePath.."/static/", "web/")
        return serveStatic(res, file)
    end

    res.writeHead(404); res.send("Not Found")
end)
