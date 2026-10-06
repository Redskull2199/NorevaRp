fx_version 'cerulean'
games {'gta5'}

author 'Izzy'
description 'Izzy'
version '1.0'

---------------------------------------------------------------------------
-- INCLUDED FILES
---------------------------------------------------------------------------
files {
	'handling.meta',
	'vehicles.meta',
	'carvariations.meta',
}

---------------------------------------------------------------------------
-- DATA FILES
---------------------------------------------------------------------------
    data_file 'HANDLING_FILE' 'handling.meta'
    data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
    data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'
	
client_script 'vehicle_names.lua'

escrow_ignore {
    'vehicle_names.lua',
}

lua54 'yes'
dependency '/assetpacks'