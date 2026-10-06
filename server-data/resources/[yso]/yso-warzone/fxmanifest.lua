shared_script '@WaveShield/resource/include.lua'
lua54 'yes' -- needed for reaper
fx_version "adamant"
game "gta5"
client_scripts {
    "handler.lua",
    "client/*.lua"
}
server_scripts {
    "handler.lua",
    "server/*.lua"
}
shared_script "config.lua"
ui_page 'web/build/index.html'
files {
    'web/build/index.html',
    'web/build/**/*'
}