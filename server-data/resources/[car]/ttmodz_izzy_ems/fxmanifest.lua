fx_version 'cerulean'
games {'gta5'}

author 'TTModz'
description 'TTModz Izzy ems'
version '1.0'

files {
	'carvariations.meta',
	'handling.meta',
	'vehicles.meta',
	'vehiclelayouts_dorado.meta',
	'vehiclelayouts_castigator.meta',
}

data_file 'HANDLING_FILE'			'handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'vehiclelayouts_dorado.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'vehiclelayouts_castigator.meta'

client_script 'vehicle_names.lua'

escrow_ignore {
    'vehicle_names.lua',
}

lua54 'yes'
dependency '/assetpacks'