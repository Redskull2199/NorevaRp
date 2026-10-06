shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'
game 'gta5'
author 'Atomik'
description 'Xen Store Material X Script'

client_scripts {
    'client.lua',
    'client_editable.lua',
}

server_scripts {
    'server.lua',
    'server_editable.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    '@es_extended/imports.lua',
    'handler/handler.lua',
    'config.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/locales.js',
    'html/assets/**/*',

    "handler/handler.lua",
    "handler/frameworks/qb/client.lua",
    "handler/frameworks/qb/server.lua",
    "handler/frameworks/esx/client.lua",
    "handler/frameworks/esx/server.lua",
    "handler/frameworks/qbox/client.lua",
    "handler/frameworks/qbox/server.lua",
}

lua54 'yes'

escrow_ignore {
    'config.lua', 
    'handler/**',
    'handler/**/*',
    'server_editable.lua',
    'client_editable.lua',
}

dependency '/assetpacks'