shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'
game 'gta5'

name "um-okey"
author "uyuyorum store"
version "3.0.0"
description "UM - Okey"

ui_page 'web/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

ox_libs {
    'locale',
}

files {
    'web/**',
    'locales/*.json',
    'modules/client/*.lua'
}


client_scripts {
    'modules/client/camera.lua',
    'modules/client/utils.lua',
    'client/interaction.lua',
    'client/main.lua',
    'client/events.lua',
    'client/nuicallback.lua',
    'client/open.lua',
}

server_scripts {
    'server/*.lua'
}


escrow_ignore {
    'modules/client/target.lua',
    'modules/client/nui.lua',
    'modules/client/hover.lua',
    'modules/server/utils.lua',
    'config.lua',
}

dependencies {
    '/server:7290',
    'ox_lib',
    '/onesync'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
nui_callback_strict_mode 'true'

dependency '/assetpacks'



