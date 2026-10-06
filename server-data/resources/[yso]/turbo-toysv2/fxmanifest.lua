shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'
games       { 'gta5' }
lua54       'yes'

author      'TurboScripts = The ElectusS'
description 'Advanced Toy System V2 Update!'
version     '3.6.0'

dependencies {
    'ox_lib',
    'oxmysql',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/locales.lua',
}

client_scripts {
    'client/_safety.lua',
    'client/main.lua',
    'client/gizmo.lua',
    'client/menu.lua',
    'client/particles.lua',
    'client/claw.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/_safety.lua',
    'server/main.lua',
    'server/items_export.lua',
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/assets/menu-bg.png',
    'nui/assets/click.mp3',

    'stream/turbopeds.ytyp',
    'stream/turbo_toybox.ytyp',
}

data_file 'DLC_ITYP_REQUEST' 'stream/turbopeds.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/turbo_toybox.ytyp'

escrow_ignore {
    'config.lua',
    'README.md',
    'install.sql',
    'locales/locales.lua',
    'install/items_ox.lua',
    'install/items_qb.lua',
}

dependency '/assetpacks'
dependency '/assetpacks'