fx_version 'cerulean'
game 'gta5'
lua54 'yes'


author 'Djonza'

version '1.0.1'

description 'Invoices'

server_scripts {'server.lua', '@oxmysql/lib/MySQL.lua'}

client_script 'client.lua'

shared_scripts {'@ox_lib/init.lua', 'config.lua'}

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'locales/*.json',
}

ui_page 'nui/index.html'

dependencies {
    'oxmysql',
    'ox_lib',
    'ox_target',
}

