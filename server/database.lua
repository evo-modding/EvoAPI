
local function Exec(sql, params, cb)
    if cb then MySQL.query(sql, params or {}, function(res) cb(res) end)
    else MySQL.query(sql, params or {}) end
end

CreateThread(function()
    local sql = [[
        CREATE TABLE IF NOT EXISTS evoapi_players (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64) NOT NULL,
            name VARCHAR(64) NOT NULL,
            first_join DATETIME DEFAULT CURRENT_TIMESTAMP,
            last_join DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            playtime INT DEFAULT 0,
            `group` VARCHAR(32) DEFAULT 'user',
            UNIQUE KEY uniq_identifier (identifier)
        );
    ]]
    Exec(sql)
    EvoAPI.Log("Database initialized (evoapi_players).")
end)

function EvoAPI.DBEnsurePlayer(identifier, name)
    MySQL.scalar("SELECT id FROM evoapi_players WHERE identifier = ? LIMIT 1", {identifier}, function(id)
        if not id then
            MySQL.insert("INSERT INTO evoapi_players (identifier, name) VALUES (?, ?)", {identifier, name or "Unknown"})
        else
            MySQL.update("UPDATE evoapi_players SET name = ? WHERE id = ?", {name or "Unknown", id})
        end
    end)
end

function EvoAPI.DBUpdateLastJoin(identifier)
    MySQL.update("UPDATE evoapi_players SET last_join = CURRENT_TIMESTAMP WHERE identifier = ?", {identifier})
end

function EvoAPI.DBAddPlaytime(identifier, minutes)
    minutes = tonumber(minutes or 0) or 0
    if minutes <= 0 then return end
    MySQL.update("UPDATE evoapi_players SET playtime = playtime + ? WHERE identifier = ?", {minutes, identifier})
end

function EvoAPI.DBGetPlayerByIdentifier(identifier, cb)
    MySQL.query("SELECT * FROM evoapi_players WHERE identifier = ? LIMIT 1", {identifier}, function(result)
        cb(result and result[1])
    end)
end

function EvoAPI.DBSetGroup(identifier, group)
    MySQL.update("UPDATE evoapi_players SET `group` = ? WHERE identifier = ?", {group, identifier})
end
