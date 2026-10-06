fx_version 'cerulean'

game 'gta5'

author 'XSCOWL'
description 'XSCOWL DJ Creator'
version '1.0.2'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/cl_utils.lua',
    'client/cl_admin.lua',
    'client/cl_main.lua'
}

server_scripts {
    'server/sv_main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css.css',
    'html/main.js'
}

dependencies {
    'ox_lib',
    'xscowl-audio'
}

escrow_ignore {
    'shared/config.lua'
}

-- ██╗  ██╗███████╗ ██████╗  ██████╗ ██╗    ██╗██╗     
-- ╚██╗██╔╝██╔════╝██╔════╝ ██╔═══██╗██║    ██║██║     
--  ╚███╔╝ ███████╗██║      ██║   ██║██║ █╗ ██║██║     
--  ██╔██╗ ╚════██║██║      ██║   ██║██║███╗██║██║     
-- ██╔╝ ██╗███████║╚██████╗  ╚██████╔╝╚███╔███╔╝███████╗
-- ╚═╝  ╚═╝╚══════╝ ╚═════╝   ╚═════╝  ╚══╝╚══╝ ╚══════╝
dependency '/assetpacks'