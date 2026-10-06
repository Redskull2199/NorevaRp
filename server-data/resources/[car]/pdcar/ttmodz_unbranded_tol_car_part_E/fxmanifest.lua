fx_version 'cerulean'  -- https://discord.gg/tt1-3d --
games {'gta5'}

author 'TTModz'
description 'TTModz tol car pack'
version '3.1'

files {
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

data_file "AUDIO_SYNTHDATA" "audioconfig/rx7bpeng_amp.dat"
data_file "AUDIO_GAMEDATA" "audioconfig/rx7bpeng_game.dat"
data_file "AUDIO_SOUNDDATA" "audioconfig/rx7bpeng_sounds.dat"
data_file "AUDIO_WAVEPACK" "sfx/dlc_rx7bpeng"
data_file 'AUDIO_SYNTHDATA' 'audioconfig/demonv8_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/demonv8_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/demonv8_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_demonv8'
data_file 'AUDIO_SYNTHDATA' 'audioconfig/mx5nasound_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/mx5nasound_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/mx5nasound_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_mx5nasound'

escrow_ignore {
    'stream/tolg81/tolg81_bumr_10.yft',
    'stream/tolg81/tolg81_bumr_11.yft',
    'stream/tolg81/tolg81_bumr_12.yft',
    'stream/tolg81/tolg81_bumr_13.yft',
    'stream/tolg81/tolg81_bumr_14.yft',
    'stream/tolg81/tolg81_bumr_15.yft',
}

lua54 'yes'
dependency '/assetpacks'