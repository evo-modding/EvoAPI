
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Devloo'
description 'EvoAPI — Core + Admin Panel (v1.3.1)'
version '1.3.1'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}

client_scripts {
    'config.lua',
    'client/core.lua',
    'client/exports.lua',
    'modules/client/*.lua',
    'client.lua' -- admin panel client
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/core.lua',
    'server/database.lua',
    'server/permissions.lua',
    'server/discord.lua',
    'server/players.lua',
    'server/moderation.lua',
    'server/commands.lua',
    'server/exports.lua',
    'modules/server/*.lua',
    'server.lua' -- admin panel server
}
