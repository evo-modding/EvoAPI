
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'EVO Modding'
description 'EvoAPI — FiveM Modding Framework (v1.2.1) with vMenu integration'
version '1.2.1'

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'permissions.vmenu.cfg'
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
    'server/exports.lua',
    'modules/server/*.lua'
}
