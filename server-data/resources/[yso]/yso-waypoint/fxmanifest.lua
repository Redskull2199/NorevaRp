shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'
game 'gta5'

author 'MrHazar'
description 'Waypoint'
version '1.0.1'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'locales/*.lua',
    'client.lua'
}

escrow_ignore {
    'config.lua',
    'client.lua',
    'locales/*.lua'
}
dependency '/assetpacks'
dependency '/assetpacks'



