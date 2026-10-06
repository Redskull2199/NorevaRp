fx_version 'cerulean'
game 'gta5'

name 'pulsev-blipcreator'
author 'PulseV'
description 'QBCore için kalıcı, güvenli blip yönetimi'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    'shared/protocol.lua',
    'shared/catalog.lua',
    'shared/locales/tr.lua',
    'shared/validation.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/bridge.lua',
    'server/service.lua',
    'server/main.lua',
}

client_scripts {
    'client/blips.lua',
    'client/sync.lua',
    'client/preview.lua',
    'client/teleport.lua',
    'client/main.lua',
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/*.js',
    'html/assets/catalog.json',
    'html/assets/provenance.json',
    'html/assets/blips/*.png',
    'html/assets/blips/*.gif',
}

dependencies {
    'qb-core',
    'oxmysql',
    '/onesync',
    '/gameBuild:3258',
}
