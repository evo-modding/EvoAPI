
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'EVO Modding'
description 'EvoAPI — FiveM Modding Framework (v1.3.0) with Web Panel (beta)'
version '1.3.0'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'web/panel.html',
    'web/panel.css',
    'web/panel.js'
}

client_scripts {
    'config.lua',
    'client/core.lua',
    'client/exports.lua',
    'modules/client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/core.lua',
    'server/database.lua',
    'server/players.lua',
    'server/permissions.lua',
    'server/commands.lua',
    'server/discord.lua',
    'server/vmenu_integration.lua',
    'server/web.lua',
    'server/exports.lua',
    'modules/server/*.lua'
}
