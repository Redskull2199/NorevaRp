fx_version 'cerulean'
game { 'gta5' }
lua54 'yes'

scriptname '0r-chatv3'
version '1.0.4'

author 'vezironi'
description 'A template for creating FiveM scripts with a modular structure.'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'locales/*.lua',
    'utils/*.lua',
}

client_scripts {
    'client/main.lua',
    'client/nui.lua',
    'client/default.lua',
    'client/thread.lua',
    'client/commands.lua',
    'client/exports.lua',
    'modules/**/**/client.lua',
}

server_scripts {
    'config/webhooks.lua',
    'server/*.lua',
    'modules/**/**/server.lua',
}

escrow_ignore {
    'shared/*.lua',
    'modules/*.lua',
    'locales/*.lua',
    'config/*.lua',
    'utils/*.lua',
    'client/commands.lua',
    'client/default.lua',
    'client/exports.lua',
    'client/thread.lua',
    'server/functions.lua',
}

files {
    'web/build/*.*',
    'web/build/**/*.*',
    'locales/*.json',
}

ui_page 'web/build/index.html'

dependencies {
    'ox_lib',
}

provide 'chat'



