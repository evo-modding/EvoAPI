
-- EvoAPI Database (oxmysql)

local function Exec(sql, params, cb)
    if cb then
        MySQL.query(sql, params or {}, function(res) cb(res) end)
    else
        MySQL.query(sql, params or {})
    end
end

CreateThread(function()
    Exec([[
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
    ]])
    Exec([[
        CREATE TABLE IF NOT EXISTS evoapi_bans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64) NOT NULL UNIQUE,
            name VARCHAR(64),
            reason VARCHAR(255),
            banned_by VARCHAR(64),
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    ]])
    Exec([[
        CREATE TABLE IF NOT EXISTS evoapi_notes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64),
            note TEXT,
            added_by VARCHAR(64),
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    ]])
    Exec([[
        CREATE TABLE IF NOT EXISTS evoapi_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            action VARCHAR(64),
            actor_identifier VARCHAR(64),
            actor_name VARCHAR(64),
            target_identifier VARCHAR(64),
            target_name VARCHAR(64),
            details TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    ]])
    print("^4[EvoAPI]^0 Database initialized (players/bans/notes/logs).")
end)

-- Players
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
        cb(result and result[0+1])
    end)
end

function EvoAPI.DBSetGroup(identifier, group)
    MySQL.update("UPDATE evoapi_players SET `group` = ? WHERE identifier = ?", {group, identifier})
end

-- Bans
function EvoAPI.DBBan(identifier, name, reason, banned_by)
    MySQL.insert("INSERT INTO evoapi_bans (identifier, name, reason, banned_by) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE reason = VALUES(reason), banned_by = VALUES(banned_by), timestamp = CURRENT_TIMESTAMP", {identifier, name, reason, banned_by})
end

function EvoAPI.DBIsBanned(identifier, cb)
    MySQL.query("SELECT * FROM evoapi_bans WHERE identifier = ? LIMIT 1", {identifier}, function(res)
        cb(res and res[0+1])
    end)
end

function EvoAPI.DBUnban(identifier)
    MySQL.update("DELETE FROM evoapi_bans WHERE identifier = ?", {identifier})
end

-- Notes
function EvoAPI.DBAddNote(identifier, note, added_by)
    MySQL.insert("INSERT INTO evoapi_notes (identifier, note, added_by) VALUES (?, ?, ?)", {identifier, note, added_by})
end

function EvoAPI.DBGetNotes(identifier, cb)
    MySQL.query("SELECT * FROM evoapi_notes WHERE identifier = ? ORDER BY id DESC LIMIT 20", {identifier}, function(res)
        cb(res or {})
    end)
end

-- Logs
function EvoAPI.DBLog(action, actor_id, actor_name, target_id, target_name, details)
    MySQL.insert("INSERT INTO evoapi_logs (action, actor_identifier, actor_name, target_identifier, target_name, details) VALUES (?, ?, ?, ?, ?, ?)",
        {action, actor_id or "", actor_name or "", target_id or "", target_name or "", details or ""})
end
