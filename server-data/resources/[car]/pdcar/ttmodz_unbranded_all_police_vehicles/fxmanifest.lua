shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'  -- https://discord.gg/tt1-3d --
games {'gta5'}

author 'TTModz'
description 'TTModz tol car pack'
version '3.1'

---------------------------------------------------------------------------
-- INCLUDED FILES
---------------------------------------------------------------------------
files {
	'vehiclelayouts.meta',
	'handling.meta',
	'vehicles.meta',
	'carcols.meta',
	'carvariations.meta',
	'audioconfig/*.dat10',
	'audioconfig/*.dat10.nametable',
	'audioconfig/*.dat10.rel',
	'audioconfig/*.dat151',
	'audioconfig/*.dat151.nametable',
	'audioconfig/*.dat151.rel',
	'audioconfig/*.dat54',
	'audioconfig/*.dat54.nametable',
	'audioconfig/*.dat54.rel',
	'sfx/**/*.awc',
}

---------------------------------------------------------------------------
-- DATA FILES
---------------------------------------------------------------------------
	data_file 'VEHICLE_LAYOUTS_FILE' 'vehiclelayouts.meta'
    data_file 'HANDLING_FILE' 'handling.meta'
    data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
    data_file 'CARCOLS_FILE' 'carcols.meta'
    data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'
	data_file 'AUDIO_GAMEDATA' 'audioconfig/ecoboostv6_game.dat'
	data_file 'AUDIO_SOUNDDATA' 'audioconfig/ecoboostv6_sounds.dat'
	data_file 'AUDIO_WAVEPACK' 'sfx/dlc_ecoboostv6'
	data_file 'AUDIO_GAMEDATA' 'audioconfig/lambov10_game.dat'
	data_file 'AUDIO_SOUNDDATA' 'audioconfig/lambov10_sounds.dat'
	data_file 'AUDIO_WAVEPACK' 'sfx/dlc_lambov10'
	data_file 'AUDIO_GAMEDATA' 'audioconfig/cvpiv8_game.dat'
	data_file 'AUDIO_SOUNDDATA' 'audioconfig/cvpiv8_sounds.dat'
	data_file 'AUDIO_WAVEPACK' 'sfx/dlc_cvpiv8'
	data_file 'AUDIO_GAMEDATA' 'audioconfig/npolchar_game.dat'
	data_file 'AUDIO_SOUNDDATA' 'audioconfig/npolchar_sounds.dat'
	data_file 'AUDIO_WAVEPACK' 'sfx/dlc_npolchar'
	data_file 'AUDIO_GAMEDATA' 'audioconfig/ta103ninjah2r_game.dat'
	data_file 'AUDIO_SOUNDDATA' 'audioconfig/ta103ninjah2r_sounds.dat'
	data_file 'AUDIO_WAVEPACK' 'sfx/dlc_ta103ninjah2r'
	data_file "AUDIO_SYNTHDATA" "audioconfig/lgcy04murciv12_amp.dat"
	data_file "AUDIO_GAMEDATA" "audioconfig/lgcy04murciv12_game.dat"
	data_file "AUDIO_SOUNDDATA" "audioconfig/lgcy04murciv12_sounds.dat"
	data_file "AUDIO_WAVEPACK" "sfx/dlc_lgcy04murciv12"
	data_file 'AUDIO_GAMEDATA' 'audioconfig/hemisound_game.dat'
	data_file 'AUDIO_SOUNDDATA' 'audioconfig/hemisound_sounds.dat'
	data_file 'AUDIO_WAVEPACK' 'sfx/dlc_hemisound'
	data_file 'AUDIO_GAMEDATA' 'audioconfig/fordvoodoo_game.dat'
	data_file 'AUDIO_SOUNDDATA' 'audioconfig/fordvoodoo_sounds.dat'
	data_file 'AUDIO_WAVEPACK' 'sfx/dlc_fordvoodoo'
    data_file "AUDIO_SYNTHDATA" "audioconfig/lg162gomtcev_amp.dat"
	data_file "AUDIO_GAMEDATA" "audioconfig/lg162gomtcev_game.dat"
	data_file "AUDIO_SOUNDDATA" "audioconfig/lg162gomtcev_sounds.dat"
	data_file "AUDIO_WAVEPACK" "sfx/dlc_lg162gomtcev"
	data_file 'AUDIO_GAMEDATA' 'audioconfig/aqls7raceswap_game.dat'
	data_file 'AUDIO_SOUNDDATA' 'audioconfig/aqls7raceswap_sounds.dat'
	data_file 'AUDIO_WAVEPACK' 'sfx/dlc_aqls7raceswap'
	data_file "AUDIO_GAMEDATA" "audioconfig/lg186teslaev_game.dat"
	data_file "AUDIO_SOUNDDATA" "audioconfig/lg186teslaev_sounds.dat"
	data_file "AUDIO_WAVEPACK" "sfx/dlc_lg186teslaev"
	data_file "AUDIO_SYNTHDATA" "audioconfig/lg171gomaltimaniac_amp.dat"
	data_file "AUDIO_GAMEDATA" "audioconfig/lg171gomaltimaniac_game.dat"
	data_file "AUDIO_SOUNDDATA" "audioconfig/lg171gomaltimaniac_sounds.dat"
	data_file "AUDIO_WAVEPACK" "sfx/dlc_lg171gomaltimaniac"
	
client_script 'vehicle_names.lua'

escrow_ignore {
    'vehicle_names.lua',
}

lua54 'yes'
dependency '/assetpacks'