Config = {}

Config.TVs = {}

Config.Framework = "qbcore"  -- Supported frameworks: standalone, qbcore, esx, custoim

Config.InterfaceColor = "#ff66ff" -- UI theme color in HEX format (e.g. #ff66ff)

Config.Language = "English" -- UI language used by the script (English) (located in language/main.lua)

Config.EnableExternalSources = true -- ⚠️ Optional feature (use responsibly)

-- This feature allows playback from external media providers.
-- You are responsible for ensuring its use complies with all applicable rules.

-- Requirements:
-- • Follow all third-party platform Terms of Service
-- • Do NOT stream copyrighted content without proper rights
-- • Avoid using this for public redistribution of media

-- Recommendation:
-- Use local .mp3 / .mp4 files from your resource or trusted direct links instead.

-- Interaction & Access Settings

Config.TelevisionWebhook = true -- Enable webhook logging (configure webhook URL in other.lua)

Config.TvForItem = true -- Allow opening TV via usable item
Config.TvForCommand = true -- Allow opening TV via command

Config.TvCommand = "tv" -- Command used to open the TV menu

Config.Target = false -- Enable target-based interaction (true/false)

Config.Targettype = "oxtarget" -- Target system type: qtarget, qbtarget, oxtarget

Config.TargetSystemsNames = {qtarget = "qtarget", qbtarget = "qb-target", oxtarget = "ox_target"}
Config.TargetIcons = {tvicon = "fa-solid fa-tv"} -- Icon used for TV interaction (FontAwesome)

-- Development Tools (recommended to use only on dev servers)

Config.CustomTvCreator = false -- Enable in-game creator for custom 3D TV screens (/createcustomtv)
Config.VehicleTelevisionOffSetsCreator = true -- Enable vehicle TV offset editor (/tvcreator)

-- World TV Features

Config.TelevisionObjectPlacer = false -- Spawn predefined TV objects from Config.TelevisionObjectsLocations
Config.TelevisionPermissions = false -- Enable location-based permissions (see Config.TelevisionPermissionsLocations)
Config.TelevisionPresets = false -- Auto-play predefined URLs at specific coordinates (see Config.TelevisionPresetsLocations)

-- Vehicle TV System

Config.VehicleTelevision = false -- Enable TV system inside vehicles

Config.VehicleTelevisionForEveryVehicle = true -- Allow TVs in all vehicles (ignores whitelist below if enabled)

Config.VehicleTelevisionBlacklist = false -- Block specific vehicles (see Config.TelevisonBlacklistedVehicles)

Config.VehicleTelevisionoForOnlySpecifiedTypeOfVehicle = true -- Allow only specific vehicle classes (see Config.TelevisonVehiclesClasses)

Config.VehicleTelevisionItem = false -- Require installation item for vehicle TVs (ESX/QBCore only)

Config.VehicleTelevisionEvent = false  -- Install TV via event: TriggerServerEvent("rtx_tv:InstallVehicleTVCustom", plate, netId) -- Check via export: exports["rtx_tv"]:HasVehicleTV(vehicle) -- (ESX/QBCore only)

-- Editor Settings

Config.EditorColor = {r = 255, g = 102, b = 255} -- UI accent color for TV editor

Config.EnableRoutingBucketTv = true -- Enable instanced TVs (useful for apartments/interiors with multiple players)

Config.EnableImagesForTv = false -- Allow displaying images on TVs (png, jpg, gif)

Config.EnableWebsitesForTv = false -- Allow loading external websites (no interaction/scrolling; use blacklist for restrictions)

Config.EnableMediaFromFolder = true -- Enable playback of local media from html/media folder (mp3, mp4, ogg)

Config.StreamerModeCommand = "streamermode" -- Command to mute TV audio locally (useful for streamers)

Config.EnableGetNearbyTvCoords = true -- Enable debug command to print nearby TV coordinates

Config.EnableGetNearbyTvCoordsCommand = "getnearbytv" -- Command name for fetching nearby TV coords

Config.EnableControlPermissions = false -- Restrict TV control to specific players (see Config.TelevisionControlSettings)

Config.TelevisionControlSettings = {
	acepermissionsforusecontrolmenu = {enable = false, permission = "rtxtv.managment"}, -- enable this if you want to use ace permissions
	jobpermissionsforusecontrolmenu = {enable = false, jobname = "cinema"},  -- enable this if you want to use job permissions (you need create job with name cinema or change the job title to something else)
	identifierspermissionsforcontrolmenu = true, -- enable this if you want to use identifiers permissions
	permissionsviaidentifiers = { -- permisisontypes - license, steam, xbox, live, discord, ip
		{permissiontype = "license", permisisondata = "license:REPLACE_WITH_PLAYER_IDENTIFIER"}, -- this is example line
	},
}

Config.EnableTVCamera = false -- Master switch for the TV camera feature

Config.TVCameraOpenOnMenu = true -- Automatically enable the TV camera when opening the TV menu
Config.TVCameraAllowCommand = true -- Allow players to toggle the TV camera manually with a command

Config.TVCameraCommand = "tvcam" -- Command used to toggle the TV camera manually

Config.TVCamera = {
	offset = vector3(0.0, -3.0, 0.8), -- Camera position offset relative to the TV object
	lookOffset = vector3(0.0, 0.0, 0.7), -- Point the camera looks at relative to the TV object
	fov = 50.0, -- Camera field of view
	smoothTime = 800 -- Camera transition time in milliseconds
}

Config.BlacklistedWebsites = { -- Blocks any URL containing these strings (partial match, case-insensitive, external sources only)
    "websitelink.com",
}	

--[[
	Media List

	This list is optional and only needed if you want to use custom media names.

	Example:
	- If videoname = "video" and filename = "examplevideo.mp4"
	- Then players can type "video" into the TV input
	- And the script will play "examplevideo.mp4"

	If you do not need custom names, you can leave this list empty.
	The script will automatically detect all supported files inside html/media
	and use their file names as the media names.

	Example auto-detected usage:
	- html/media/mysong.mp3  -> use: mysong.mp3
	- html/media/movie.mp4   -> use: movie.mp4
	- html/media/sound.ogg   -> use: sound.ogg

	Supported file types:
	- .mp3
	- .ogg
	- .mp4
]]

Config.MediaList = {
	["video1"] = {
		videoname = "video", -- Custom media name used in the TV URL/input
		filename = "examplevideo.mp4", -- File name located in html/media
	},
	["video2"] = {
		videoname = "audio", -- Custom media name used in the TV URL/input
		filename = "exampleaudio.mp3", -- File name located in html/media
	},
}

Config.EnabledLinkTypes = { -- Enable/disable supported media sources (set false to block a platform or file type)
    ["youtube"] = true,
    ["twitch"] = true,
    ["streamable"] = true,
    ["facebook"] = true,
    ["dailymotion"] = true,
    ["vimeo"] = true,
	["soundcloud"] = true,
	["mp4"] = true,
	["mp3"] = true,
	["ogg"] = true,
    ["bilibili"] = true,
    ["huya"] = true,
    ["aparat"] = true,
	["kick"] = true,
}

Config.TelevisionObjects = {
	-- Defines usable TV screen objects in the world and base render settings
	{
		object = "prop_tv_flat_01", --object name
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target
		rendertargetname = "tvscreen", -- render target name
	},
	{
		object = "v_ilev_cin_screen", --object name
		maxdistance = 40.0, --max distance for display screen
		maxcontroldistance = 20.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target
		rendertargetname = "cinscreen", -- render target name
	},
	{
		object = "vw_prop_vw_cinema_tv_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},
	{
		object = "prop_tv_flat_michael", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "prop_trev_tv_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},
	{
		object = "prop_tv_flat_03b", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "prop_tv_flat_03", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "prop_tv_flat_02b", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "prop_tv_flat_02", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},		
	{
		object = "hei_heist_str_avunitl_03", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "mp_b_str_avunitl_03", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "mp_b_str_avunits_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "mp_b_str_avunitl_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "hei_heist_str_avunitl_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "hei_heist_str_avunits_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},		
	{
		object = "apa_mp_h_str_avunitl_04", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "apa_mp_h_str_avunitl_01_b", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "apa_mp_h_str_avunits_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},		
	{
		object = "apa_mp_h_str_avunits_04", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},
	{
		object = "prop_tv_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "prop_tv_02", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},
	{
		object = "prop_tv_03", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "prop_tv_04", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "prop_tv_05", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "prop_tv_06", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},		
	{
		object = "prop_tv_07", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "ex_prop_ex_tv_flat_01", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "ex_tvscreen"
	},	
	{
		object = "sm_prop_smug_tv_flat_01", 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tv_flat_01"
	},
	{
		object = "prop_tv_test", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "des_tvsmash_root", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{
		object = "des_tvsmash_start", --object name 
		maxdistance = 15.0, --max distance for display screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = true, -- enable render target 
		rendertargetname = "tvscreen", -- render target name
	},	
	{ --  Armitage Games Club
		scale = vector3(0.380, 0.158, 1.0), -- rendertarget scale
		maxdistance = 100.0, --max distance for display screen--max distance for view screen
		maxcontroldistance = 50.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = false, -- enable render target
		nonobject = true,  -- enable this if you want use just screen, withount rendering on object
		nonobjectcoords = vector3(2399.82, 3016.64, 34.8), -- screen cordinates
		nonobjectrotation = vector3(0.0, 0.0, 180.0), -- screen rotation
	},	
	--[[ --This is example for television withount rendertarget with gfx (you need download generic_texture_renderer_gfx for this https://forum.cfx.re/t/release-generic-dui-2d-3d-renderer/131208)
	{
		object = "prop_tv_flat_01", --object name
		scale = vector3(0.05, 0.05, 1.0), -- rendertarget scale
		position = vector3(-0.925, -0.055, 1.0),  -- rendertarget position
		rotation = vector3(0.0, 0.0, 0.0), -- rendertarget rotation
		maxdistance = 15.0, --max distance for display screen--max distance for view screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = false, -- enable render target
		nonobject = false, -- enable this if you want use just screen, withount rendering on object
	},	
	]]--
	--[[ --This is example for television withount rendertarget with gfx withount object (you need download generic_texture_renderer_gfx for this https://forum.cfx.re/t/release-generic-dui-2d-3d-renderer/131208)
	{
		scale = vector3(0.465, 0.263, 1.0), -- rendertarget scale
		maxdistance = 100.0, --max distance for display screen--max distance for view screen
		maxcontroldistance = 15.0, -- max distance for control tv (its cannot be higher than maxdistance)
		rendertarget = false, -- enable render target
		nonobject = true,  -- enable this if you want use just screen, withount rendering on object
		nonobjectcoords = vector3(137.982, -986.145, 42.751), -- screen cordinates
		nonobjectrotation = vector3(0.0, 0.0, 289.1), -- screen rotation
	},	
	]]--	
}
 
Config.TelevisionObjectsLocations = { -- Static TV objects (requires Config.TelevisionObjectPlacer = true)
	{
		objectname = "prop_tv_flat_01", -- Object model name
		coords = vector3(244.47, -876.58, 30.49), -- World position
		rotation = vector3(0.0, 0.0, 0.0), -- Rotation (x, y, z)
		handler = nil, -- Internal use (do not modify)
	},
}

Config.TelevisionPresetsLocations = { -- Predefined screens with fixed URLs (requires Config.TelevisionPresets = true)
	{
		coords = vector3(-54.25613, -1086.99, 26.95193), -- Screen position
		url = "https://rtx.tebex.io", -- URL automatically displayed on this TV
	},
}

Config.TelevisionPermissionsLocations = { -- Restrict TV usage by location (requires Config.TelevisionPermissions = true)
	{
		coords = vector3(320.1257, 248.6608, 86.56934), -- TV position

		acepermissions = {
			enable = false, 
			permission = "rtxtv.cinema" -- Requires ACE permission (server.cfg: add_ace identifier.xxx "rtxtv.cinema" allow)
		},

		jobpermissions = {
			enable = false, 
			jobname = "cinema" -- Requires player job (framework dependent)
		},

		identifierspermissions = false, -- Enable whitelist based on identifiers (Steam, Discord, etc.)

		permissionsviaidentifiers = { -- Supported types: license, steam, xbox, live, discord, ip
			{permissiontype = "steam", permisisondata = "steam:REPLACE_WITH_PLAYER_IDENTIFIER"}, -- Example entry
		},
	},
}

Config.TelevisonVehicles = { -- Vehicles allowed to use TV screens
	{
		vehiclename = "bullet", -- Vehicle spawn/model name
	},
	{
		vehiclename = "infernus", -- Vehicle spawn/model name
	},		
}

Config.TelevisonBlacklistedVehicles = { -- Vehicles explicitly blocked from using TV screens
	{
		vehiclename = "rhino", -- Vehicle spawn/model name
	},
	{
		vehiclename = "thruster", -- Vehicle spawn/model name
	},	
}

Config.TelevisonVehiclesClasses = { -- Enable/disable TV usage by vehicle class (false = blocked)
	[0] = true,  -- Compacts
	[1] = true,  -- Sedans
	[2] = true,  -- SUVs
	[3] = true,  -- Coupes
	[4] = true,  -- Muscle
	[5] = true,  -- Sports Classics
	[6] = true,  -- Sports
	[7] = true,  -- Super
	[8] = true,  -- Motorcycles
	[9] = true,  -- Off-road
	[10] = true, -- Industrial
	[11] = true, -- Utility
	[12] = true, -- Vans
	[13] = false,-- Cycles
	[14] = false,-- Boats
	[15] = false,-- Helicopters
	[16] = false,-- Planes
	[17] = true, -- Service
	[18] = true, -- Emergency
	[19] = true, -- Military
	[20] = true, -- Commercial
	[21] = true, -- Trains
	[22] = true, -- Open Wheel
}

Config.TelevisonVehiclesOffsetsDefault = { -- Default screen position for vehicle TVs
	vehiclebone = "windscreen", -- Vehicle bone used as anchor point
	offsetx = 0.0, -- Horizontal offset (left/right)
	offsety = 0.40, -- Forward/backward offset
	offsetz = 0.41, -- Vertical offset (up/down)
	rotation = vector3(0.0, 0.0, 0.0), -- Screen rotation (x, y, z)
}

Config.TelevisonVehiclesOffsets = {
	{
		vehiclename = "bullet", -- vehicle name 
		televisions = {
			{	
				vehiclebone = "windscreen",
				offsetx = 0.0,
				offsety = 0.40,
				offsetz = 0.41,
				rotation = vector3(0.0, 0.0, 0.0),
			},
		},		
	},
	{
		vehiclename = "tyrant", -- vehicle name 
		televisions = {
			{	
				vehiclebone = "windscreen",
				offsetx = 0.0,
				offsety = 0.82,
				offsetz = 0.71,
				rotation = vector3(0.0, 0.0, 0.0),
			},
		},
	},	
	{
		vehiclename = "schafter6", -- vehicle name
		televisions = {
			{	
				vehiclebone = "windscreen",
				offsetx = 0.0,
				offsety = 0.40,
				offsetz = 0.41,
				rotation = vector3(0.0, 0.0, 0.0),
			},
			{	
				vehiclebone = "windscreen",
				offsetx = 0.40,
				offsety = -0.53,
				offsetz = 0.62,
				rotation = vector3(0.0, 0.0, 0.0),
			},	
			{	
				vehiclebone = "windscreen",
				offsetx = -0.40,
				offsety = -0.53,
				offsetz = 0.62,
				rotation = vector3(0.0, 0.0, 0.0),
			},					
		},
	},	
	{
		vehiclename = "baller2", -- vehicle name 
		televisions = {
			{	
				vehiclebone = "windscreen",
				offsetx = 0.0,
				offsety = 0.63,
				offsetz = 0.4,
				rotation = vector3(0.0, 0.0, 0.0),
			},
			{	
				vehiclebone = "windscreen",
				offsetx = 0.505,
				offsety = -0.525,
				offsetz = 0.5,
				rotation = vector3(0.0, 0.0, 0.0),
			},
			{	
				vehiclebone = "windscreen",
				offsetx = -0.505,
				offsety = -0.525,
				offsetz = 0.5,
				rotation = vector3(0.0, 0.0, 0.0),
			},				
		},
	},	
	{
		vehiclename = "luxor2", -- vehicle name 
		televisions = {
			{	
				vehiclebone = "windscreen",
				offsetx = 0.0,
				offsety = 3.81499999,
				offsetz = 1.04,
				rotation = vector3(31.0, 0.0, 0.0),
			},	
			{	
				vehiclebone = "windscreen",
				offsetx = 0.0,
				offsety = 1.9,
				offsetz = 1.04,
				rotation = vector3(31.0, 0.0, 180.75),
			},				
		},		
	},	
}

Config.ESXFramework = {
	newversion = false, -- use this if you using new esx version (if you get error with old esxsharedobjectmethod in console)
	getsharedobject = "esx:getSharedObject",
	resourcename = "es_extended"
}

Config.QBCoreFrameworkResourceName = "qb-core" -- qb-core resource name, change this if you have different name of main resource of qbcore

function Notify(text)
exports['qdev_notify']:sendAlert({
    type = 'info',
    title = 'Television',
    msg = text,
    time = 5
})	
	-- exports["rtx_notify"]:Notify("Television", text, 5000, "info") -- if you get error in this line its because you dont use our notify system buy it here https://rtx.tebex.io/package/5402098 or you can use some other notify system just replace this notify line with your notify system
	--exports["mythic_notify"]:SendAlert("inform", text, 5000)
end