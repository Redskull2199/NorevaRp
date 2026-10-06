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
        'data/**/carcols.meta',
        'data/**/carvariations.meta',
        'data/**/handling.meta',
        'data/**/vehicles.meta',
        }

---------------------------------------------------------------------------
-- DATA FILES
---------------------------------------------------------------------------
data_file 'HANDLING_FILE'                       'data/**/handling.meta'
data_file 'VEHICLE_METADATA_FILE'       'data/**/vehicles.meta'
data_file 'CARCOLS_FILE'                        'data/**/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE'      'data/**/carvariations.meta'

client_script 'vehicle_names.lua'

escrow_ignore {
    'vehicle_names.lua',
}

lua54 'yes'
dependency '/assetpacks'



