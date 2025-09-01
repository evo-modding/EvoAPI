fx_version 'cerulean'
game 'gta5'

name 'vmenu_rp_core'
description 'Minimal standalone core for vMenu RP: instant spawn + simple duty/dept system.'
author 'scaffold'
version '2.0.0'
lua54 'yes'

shared_scripts {
  'config.lua'
}

server_scripts {
  'server.lua'
}

client_scripts {
  'client.lua'
}
