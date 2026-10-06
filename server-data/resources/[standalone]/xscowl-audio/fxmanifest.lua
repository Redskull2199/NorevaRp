fx_version 'cerulean'

games { 'gta5' }

author 'XSCOWL'
name 'xscowl-audio'
description 'XSCOWL Audio System'
version '1.0.2'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/sh_*.lua',
}

client_scripts {
    'client/cl_*.lua',
}

server_scripts {
    'server/sv_*.lua',
}

ui_page 'web/build/index.html'

server_export 'createSound'
server_export 'addSoundSource'
server_export 'updateSoundSource'
server_export 'updateSoundSourcesVolumes'
server_export 'removeSoundSource'

files {
    'web/build/index.html',
    'web/build/**/*',
}

escrow_ignore {
    'shared/sh_*.lua',
}

-- ██╗  ██╗███████╗ ██████╗  ██████╗ ██╗    ██╗██╗     
-- ╚██╗██╔╝██╔════╝██╔════╝ ██╔═══██╗██║    ██║██║     
--  ╚███╔╝ ███████╗██║      ██║   ██║██║ █╗ ██║██║     
--  ██╔██╗ ╚════██║██║      ██║   ██║██║███╗██║██║     
-- ██╔╝ ██╗███████║╚██████╗  ╚██████╔╝╚███╔███╔╝███████╗
-- ╚═╝  ╚═╝╚══════╝ ╚═════╝   ╚═════╝  ╚══╝╚══╝ ╚══════╝
dependency '/assetpacks'