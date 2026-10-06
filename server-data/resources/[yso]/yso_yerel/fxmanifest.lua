shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'
game 'gta5'

author 'Zodi4c'
description 'Yerel Çekici Sistemi - Dvall (Modernize Edilmiş)'
version '17.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

lua54 'yes'
