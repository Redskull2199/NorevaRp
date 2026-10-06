fx_version 'cerulean'
game 'gta5'
author 'codeReal'
description 'Made by codeReal'

ui_page {
	'html/index.html',
}

files {
	'html/*.css',
	'html/utils/*.js',
	'html/*.js',
	'html/*.html',
	'html/pages/*.html',
	'html/pages/bossmenu/*.html',
	'html/pages/bossmenu/company/*.html',
	'html/sounds/*.wav',
	'html/sounds/*.mp3',
	'html/img/*.png',
    'html/img/svg/*.svg',
	'html/img/svg/Categories/*.svg',
	'html/img/bossmenu/*.png',
	'html/img/bossmenu/*.svg',
	'html/img/bossmenu/dashboard/*.png',
	'html/fonts/*.ttf',
	'html/fonts/*.otf',
}

shared_script{
	'config/config.lua',
	'locales.lua',
	'config/vehicleshops.lua',
	'language/*.lua',
	'GetFrameworkObject.lua',
}

client_scripts {
	'config/client_config.lua',
	'client/*.lua',
}
server_scripts {
	'config/server_config.lua',
	'server/*.lua',
    -- '@mysql-async/lib/MySQL.lua', --⚠️PLEASE READ⚠️; Uncomment this line if you use 'mysql-async'.⚠️
    '@oxmysql/lib/MySQL.lua', --⚠️PLEASE READ⚠️; Uncomment this line if you use 'oxmysql'.⚠️
}

lua54 'yes' -- Test