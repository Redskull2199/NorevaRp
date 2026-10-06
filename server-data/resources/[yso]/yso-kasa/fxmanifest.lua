shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    'shared/config.lua',
}

escrow_ignore {
    'shared/config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/index.js',
    'html/index.css',
    'html/reset.css',
    'html/img/*.*'
}
dependency '/assetpacks'