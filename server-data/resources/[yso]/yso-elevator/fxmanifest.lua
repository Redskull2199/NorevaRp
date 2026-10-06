shared_script '@WaveShield/resource/include.lua'

fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'sheen'
description 'Elevator'
version '2.0'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client.lua',
}

ui_page 'html/index.html'
files { 
    'config.lua',
    
    'html/fonts/DS-Digital.TTF',
    'html/sounds/**.ogg',

    'html/index.html', 
    'html/script.js',
    'html/styles.css',
}




