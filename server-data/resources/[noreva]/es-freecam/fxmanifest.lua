fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'es-freecam'
author 'ESMODS'
description 'discord.gg/esmods'
version '1.0.0'


client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_scripts {
    'config.lua',
    'locales.lua',
    'framework.lua',
    '@ox_lib/init.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/logo.png',
    'saved_cameras.json',
    'settings.json'
}

dependencies {
    'ox_lib'
}

escrow_ignore {
    'config.lua',
    'README.md',
}
dependency '/assetpacks'