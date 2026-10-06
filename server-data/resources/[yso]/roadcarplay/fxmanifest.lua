shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'

game 'gta5'

author 'RoadShop | https://fivem.roadshop.org'
description 'RoadCarPlay FiveM'
version '2.0.0'

lua54 'yes'

ui_page 'public/index.html'

files {
    'public/index.html',
    'public/assets/*.*',
    'public/img/*.*',
    'public/img/**/*.*',
    'public/img/**/**/*.*',
    'public/static/config/config.json',
    'public/static/locales/*.json',
    'public/js/*.js'
}

shared_scripts {
    -- Bridge core (must load first to define Bridge = {})
    'bridge/main.lua',
    'bridge/modules/helpers.lua',
    -- Bridge shared modules (explicit order: events before locale)
    'bridge/modules/events/shared.lua',
    'bridge/modules/locale/shared.lua',
    -- Config and locales (Locales table must exist before these run)
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'bridge/modules/callback/client.lua',
    'bridge/modules/player/client.lua',
    'bridge/modules/job/client.lua',
    'bridge/modules/notification/client.lua',
    'bridge/modules/ui/client.lua',
    'bridge/modules/vehicle/client.lua',
    'client/client.lua',
    'client/clientAPI.lua',
    'client/controls.lua',
    'client/audiolib.lua',
    'client/music.lua',
    'client/seatshuffle.lua',
    'client/messages.lua',
    'client/vehicle_names.lua',
    'client/autopilot.lua',
    'client/rearcamera.lua',
    'client/tuning.lua'
}

server_scripts {
    --'@oxmysql/lib/MySQL.lua',
    '@mysql-async/lib/MySQL.lua',
    'bridge/modules/callback/server.lua',
    'bridge/modules/player/server.lua',
    'bridge/modules/job/server.lua',
    'bridge/modules/inventory/server.lua',
    'bridge/modules/item/server.lua',
    'bridge/modules/account/server.lua',
    'server/server.lua',
    'server/serverAPI/serverAPI.lua',
    'server/music.lua',
    'server/messages_lbphone.lua',
    'server/versioncheck.lua'
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'client/clientAPI.lua',
    'client/vehicle_names.lua',
    'server/serverAPI/*.lua',
    'bridge/*.lua',
    'bridge/**/*.lua'
}

dependencies {
    '/server:17000',
    '/onesync'
}

-- Framework is auto-detected by bridge (ESX, QBCore, Qbox, or Standalone)
-- lb-phone integration is active when Config.LBPhone = true

exports {
    'isBlocked',
    'blockCarPlay',
    'unblockCarPlay',
    'useRoadCarPlay',
    'IsRearCameraActive',
    'ToggleRearCamera'
}

server_exports {
    'getCarsCarplayIsInstalled'
}
dependency '/assetpacks'


-- =============================================================
--
--        Patched and Authored by Big Foot#0237
--
--  For support with this modified version:
--  https://discord.gg/XevAn3uxSY
-- =============================================================



