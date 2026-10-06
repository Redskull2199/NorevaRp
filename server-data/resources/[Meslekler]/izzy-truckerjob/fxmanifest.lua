fx_version 'cerulean'
game 'gta5'

author 'Izzy'
description 'Trucker Job'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/cfg.lua',
    'shared/locales.lua',
    'shared/shared.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/botToken.lua',
    'server/main.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'web/dist/images/*.png',
    'web/dist/images/*.webp',
    'web/dist/images/*.jpg'
}

escrow_ignore {
    'server/botToken.lua',
    'shared/*.lua',
}
dependency '/assetpacks'