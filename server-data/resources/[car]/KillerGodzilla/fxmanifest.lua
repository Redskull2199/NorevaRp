
fx_version 'adamant'
game 'gta5'

files {

        'data/**/carcols.meta',
        'data/**/carvariations.meta',
        'data/**/handling.meta',
        'data/**/vehiclelayouts.meta',
        'data/**/vehicles.meta',

  

        
        'audioconfig/nisgtr35_amp.dat10.rel',
        'audioconfig/nisgtr35_game.dat151.rel',
        'audioconfig/nisgtr35_sounds.dat54.rel',
        'sfx/dlc_nisgtr35/nisgtr35.awc',
        'sfx/dlc_nisgtr35/nisgtr35_npc.awc',
        


}

        data_file 'VEHICLE_LAYOUTS_FILE'        'data/**/vehiclelayouts.meta'
        data_file 'HANDLING_FILE'                       'data/**/handling.meta'
        data_file 'VEHICLE_METADATA_FILE'       'data/**/vehicles.meta'
        data_file 'CARCOLS_FILE'                        'data/**/carcols.meta'
        data_file 'VEHICLE_VARIATION_FILE'      'data/**/carvariations.meta'



    data_file 'AUDIO_SYNTHDATA' 'audioconfig/nisgtr35_amp.dat'
    data_file 'AUDIO_GAMEDATA' 'audioconfig/nisgtr35_game.dat'
    data_file 'AUDIO_SOUNDDATA' 'audioconfig/nisgtr35_sounds.dat'
    data_file 'AUDIO_WAVEPACK' 'sfx/dlc_nisgtr35'
        

        client_script {
                'vehicle_names.lua'
        }
        
        
    lua54 'yes'
    dependency '/assetpacks'



