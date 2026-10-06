Config = {}

Config.Framework = 'autodetect' -- qb, oldqb, esx, oldesx or autodetect
Config.MySQL = 'oxmysql' -- oxmysql, ghamattimysql, mysql-async | Don't forget to edit fxmanifest.lua
Config.Language = 'en' -- en, tr

Config.TestDriveTime = 60 -- Seconds
Config.TestDrivePrice = 7500 -- Test drive price 
Config.TestDrivePlate = 'TESTDRIVE' -- Test drive plate
Config.PlateChange = true -- If true, players can change the plate
Config.PlateChangePrice = 1000 -- Plate cost

Config.DefaultGarage = 'pillboxgarage' -- The place to be written in the 'garage' section of the database when the vehicle is purchased. 
Config.PhoneMailOnline = 'qb-phone:server:sendNewMail' -- Event to send mail to active players. Customize it for your phone.

Config.CheckSalaryStatus = { -- This checks the salary every day at 12 o'clock and the players get paid.
    Hour = 12,
    Minute = 00,
}

Config.GiveVehicleKey = true -- System of giving the player the keys of the vehicle after purchasing it or during a test drive
Config.VehicleKeySystem = 'qb-vehiclekeys' -- cd_garage | qs-vehiclekeys | wasabi-carlock | qb-vehiclekeys | custom
Config.GiveVehicleKeys = function(plate, model, vehicle)
    if Config.GiveVehicleKey then
        if Config.VehicleKeySystem == 'cd_garage' then
            TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:GetPlate(vehicle))
        elseif Config.VehicleKeySystem == 'qs-vehiclekeys' then
            exports['qs-vehiclekeys']:GiveKeys(plate, model)
        elseif Config.VehicleKeySystem == 'wasabi-carlock' then
            exports.wasabi_carlock:GiveKey(plate)
        elseif Config.VehicleKeySystem == 'qb-vehiclekeys' then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
        elseif Config.VehicleKeySystem == 'custom' then
            -- Your code here
        end
    end
end

Config.Notification = function(msg, type, server, src) -- Notification
    if server then
        if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            TriggerClientEvent('QBCore:Notify', src, msg, type, 3000) -- QBCore - Client Event
        else
            TriggerClientEvent('esx:showNotification', src, msg) -- ESX - Client Event
        end
    else
        if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            TriggerEvent('QBCore:Notify', msg, type, 3000) -- QBCore - Server Event
        else
            TriggerEvent('esx:showNotification', msg) -- ESX - Server Event
        end
    end
end

Config.CheckProfanities = true -- Check for profanity when players leave feedback or fill out a complaint form.
Config.Profanities = { -- The words
    "fuck",
    "shit",
    "bitch",
    "asshole",
    "bastard",
    "damn",
    "crap",
    "dick",
    "piss",
    "cock",
    "cunt",
    "prick",
    "twat",
    "slut",
    "whore",
    "motherfucker",
    "douchebag",
    "wanker",
    "bollocks",
    "arse"
}

Config.FeedbackCharacterCheck = { -- Minimum and maximum character limit when writing feedback.
    MinimumCharacter = 50,
    MaximumCharacter = 150,
}

Config.ComplaintCharacterCheck = { -- Maximum and minimum character limit when filling out a complaint form
    MinimumCharacter = 50,
    MaximumCharacter = 150,
}

Config.VehiclesData = {
    ['car'] = {
        { name = 't20', label = 'T20', model = 'Custom', price = 150000, stock = 1, img = 'https://docs.fivem.net/vehicles/t20.webp', category = 'sports', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'sultanrs', label = 'Sultan RS', model = '', price = 50000, stock = 1, img = 'https://docs.fivem.net/vehicles/sultanrs.webp', category = 'sedans', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'adder', label = 'Adder', model = '', price = 1000000, stock = 1, img = 'https://docs.fivem.net/vehicles/adder.webp', category = 'super', discount = 0, information = {TopSpeed = 250, Braking = 95, Acceleration = 90, Suspension = 95, Handling = 88} },
        { name = 'banshee', label = 'Banshee', model = '', price = 105000, stock = 1, img = 'https://docs.fivem.net/vehicles/banshee.webp', category = 'sports', discount = 0, information = {TopSpeed = 240, Braking = 92, Acceleration = 85, Suspension = 90, Handling = 87} },
        { name = 'carbonizzare', label = 'Carbonizzare', model = '', price = 195000, stock = 1, img = 'https://docs.fivem.net/vehicles/carbonizzare.webp', category = 'sports', discount = 0, information = {TopSpeed = 230, Braking = 93, Acceleration = 80, Suspension = 85, Handling = 84} },
        { name = 'cheetah', label = 'Cheetah', model = '', price = 650000, stock = 1, img = 'https://docs.fivem.net/vehicles/cheetah.webp', category = 'super', discount = 0, information = {TopSpeed = 250, Braking = 94, Acceleration = 85, Suspension = 90, Handling = 90} },
        { name = 'entityxf', label = 'Entity', model = 'XF Model', price = 795000, stock = 1, img = 'https://docs.fivem.net/vehicles/entityxf.webp', category = 'super', discount = 0, information = {TopSpeed = 245, Braking = 95, Acceleration = 88, Suspension = 92, Handling = 91} },
        { name = 'infernus', label = 'Infernus', model = '', price = 440000, stock = 1, img = 'https://docs.fivem.net/vehicles/infernus.webp', category = 'super', discount = 0, information = {TopSpeed = 245, Braking = 94, Acceleration = 87, Suspension = 91, Handling = 90} },
        { name = 'italigtb', label = 'Itali', model = 'GTB', price = 1189000, stock = 1, img = 'https://docs.fivem.net/vehicles/italigtb.webp', category = 'super', discount = 0, information = {TopSpeed = 250, Braking = 96, Acceleration = 89, Suspension = 94, Handling = 92} },
        { name = 'osiris', label = 'Osiris', model = '', price = 1950000, stock = 1, img = 'https://docs.fivem.net/vehicles/osiris.webp', category = 'super', discount = 0, information = {TopSpeed = 240, Braking = 95, Acceleration = 88, Suspension = 93, Handling = 89} },
        { name = 'reaper', label = 'Reaper', model = '', price = 1595000, stock = 1, img = 'https://docs.fivem.net/vehicles/reaper.webp', category = 'super', discount = 0, information = {TopSpeed = 245, Braking = 96, Acceleration = 90, Suspension = 92, Handling = 91} },
        { name = 'tempesta', label = 'Tempesta', model = '', price = 1329000, stock = 1, img = 'https://docs.fivem.net/vehicles/tempesta.webp', category = 'super', discount = 0, information = {TopSpeed = 250, Braking = 97, Acceleration = 91, Suspension = 95, Handling = 93} },
        { name = 'turismor', label = 'Turismo', model = 'R Model', price = 500000, stock = 1, img = 'https://docs.fivem.net/vehicles/turismor.webp', category = 'super', discount = 0, information = {TopSpeed = 240, Braking = 95, Acceleration = 86, Suspension = 89, Handling = 88} },
        { name = 'vacca', label = 'Vacca', model = '', price = 240000, stock = 1, img = 'https://docs.fivem.net/vehicles/vacca.webp', category = 'super', discount = 0, information = {TopSpeed = 235, Braking = 92, Acceleration = 85, Suspension = 87, Handling = 86} },
        { name = 'zentorno', label = 'Zentorno', model = '', price = 725000, stock = 1, img = 'https://docs.fivem.net/vehicles/zentorno.webp', category = 'super', discount = 0, information = {TopSpeed = 250, Braking = 96, Acceleration = 92, Suspension = 95, Handling = 94} },
        { name = 'coquette', label = 'Coquette', model = '', price = 138000, stock = 1, img = 'https://docs.fivem.net/vehicles/coquette.webp', category = 'sports', discount = 0, information = {TopSpeed = 230, Braking = 90, Acceleration = 83, Suspension = 84, Handling = 82} },
        { name = 'sabregt', label = 'Sabre', model = 'Turbo', price = 15000, stock = 1, img = 'https://docs.fivem.net/vehicles/sabregt.webp', category = 'muscle', discount = 0, information = {TopSpeed = 200, Braking = 85, Acceleration = 75, Suspension = 80, Handling = 78} },
        { name = 'dominator', label = 'Dominator', model = '', price = 35000, stock = 1, img = 'https://docs.fivem.net/vehicles/dominator.webp', category = 'muscle', discount = 0, information = {TopSpeed = 210, Braking = 87, Acceleration = 78, Suspension = 82, Handling = 80} },
        { name = 'dukes', label = 'Dukes', model = '', price = 62000, stock = 1, img = 'https://docs.fivem.net/vehicles/dukes.webp', category = 'muscle', discount = 0, information = {TopSpeed = 215, Braking = 88, Acceleration = 80, Suspension = 84, Handling = 82} }
    },

    ['boat'] = {
        { name = 'seashark2', label = 'Seashark2', model = 'Normal', price = 15000, stock = 1, img = 'https://docs.fivem.net/vehicles/seashark2.webp', category = 'all', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'seashark3', label = 'Seashark3', model = 'Turbo', price = 50000, stock = 1, img = 'https://docs.fivem.net/vehicles/seashark3.webp', category = 'all', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'toro2', label = 'Toro', model = 'Luxury', price = 100000, stock = 1, img = 'https://docs.fivem.net/vehicles/toro2.webp', category = 'all', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'dinghy', label = 'Dinghy', model = 'Standard', price = 20000, stock = 1, img = 'https://docs.fivem.net/vehicles/dinghy.webp', category = 'all', discount = 0, information = {TopSpeed = 230, Braking = 90, Acceleration = 85, Suspension = 90, Handling = 87} },
        { name = 'jetmax', label = 'Jetmax', model = 'High Performance', price = 50000, stock = 1, img = 'https://docs.fivem.net/vehicles/jetmax.webp', category = 'all', discount = 0, information = {TopSpeed = 260, Braking = 95, Acceleration = 90, Suspension = 95, Handling = 90} },
        { name = 'speeder', label = 'Speeder', model = 'Sport', price = 90000, stock = 1, img = 'https://docs.fivem.net/vehicles/speeder.webp', category = 'all', discount = 0, information = {TopSpeed = 250, Braking = 92, Acceleration = 88, Suspension = 90, Handling = 88} },
        { name = 'suntrap', label = 'Suntrap', model = 'Standard', price = 30000, stock = 1, img = 'https://docs.fivem.net/vehicles/suntrap.webp', category = 'all', discount = 0, information = {TopSpeed = 210, Braking = 80, Acceleration = 75, Suspension = 80, Handling = 78} },
        { name = 'squalo', label = 'Squalo', model = 'Sport', price = 80000, stock = 1, img = 'https://docs.fivem.net/vehicles/squalo.webp', category = 'all', discount = 0, information = {TopSpeed = 240, Braking = 90, Acceleration = 85, Suspension = 88, Handling = 86} },
        { name = 'tropic', label = 'Tropic', model = 'Luxury', price = 60000, stock = 1, img = 'https://docs.fivem.net/vehicles/tropic.webp', category = 'all', discount = 0, information = {TopSpeed = 230, Braking = 88, Acceleration = 82, Suspension = 85, Handling = 84} },
        { name = 'dinghy2', label = 'Dinghy 2', model = 'Standard', price = 22000, stock = 1, img = 'https://docs.fivem.net/vehicles/dinghy2.webp', category = 'all', discount = 0, information = {TopSpeed = 235, Braking = 91, Acceleration = 86, Suspension = 90, Handling = 88} },
        { name = 'speeder2', label = 'Speeder 2', model = 'Sport', price = 95000, stock = 1, img = 'https://docs.fivem.net/vehicles/speeder2.webp', category = 'all', discount = 0, information = {TopSpeed = 255, Braking = 93, Acceleration = 89, Suspension = 92, Handling = 90} },
        { name = 'tropic2', label = 'Tropic 2', model = 'Luxury', price = 65000, stock = 1, img = 'https://docs.fivem.net/vehicles/tropic2.webp', category = 'all', discount = 0, information = {TopSpeed = 235, Braking = 89, Acceleration = 83, Suspension = 86, Handling = 85} },
    },

    ['aircraft'] = {
        { name = 'volatus', label = 'Volatus', model = 'Luxury Helicopter', price = 50000, stock = 1, img = 'https://docs.fivem.net/vehicles/volatus.webp', category = 'helicopter', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'buzzard', label = 'Buzzard', model = 'Combat Helicopter', price = 750000, stock = 1, img = 'https://docs.fivem.net/vehicles/buzzard.webp', category = 'helicopter', discount = 0, information = {TopSpeed = 250, Braking = 95, Acceleration = 90, Suspension = 95, Handling = 90} },
        { name = 'maverick', label = 'Maverick', model = 'Utility Helicopter', price = 780000, stock = 1, img = 'https://docs.fivem.net/vehicles/maverick.webp', category = 'helicopter', discount = 0, information = {TopSpeed = 240, Braking = 93, Acceleration = 85, Suspension = 92, Handling = 88} },
        { name = 'cargobob', label = 'Cargobob', model = 'Heavy Lift Helicopter', price = 1850000, stock = 1, img = 'https://docs.fivem.net/vehicles/cargobob.webp', category = 'helicopter', discount = 0, information = {TopSpeed = 200, Braking = 80, Acceleration = 75, Suspension = 85, Handling = 80} },
        { name = 'frogger', label = 'Frogger', model = 'Civilian Helicopter', price = 1300000, stock = 1, img = 'https://docs.fivem.net/vehicles/frogger.webp', category = 'helicopter', discount = 0, information = {TopSpeed = 230, Braking = 85, Acceleration = 80, Suspension = 87, Handling = 84} },
        { name = 'luxor', label = 'Luxor', model = 'Private Jet', price = 1625000, stock = 1, img = 'https://docs.fivem.net/vehicles/luxor.webp', category = 'plane', discount = 0, information = {TopSpeed = 300, Braking = 100, Acceleration = 95, Suspension = 100, Handling = 95} },
        { name = 'shamal', label = 'Shamal', model = 'Business Jet', price = 1150000, stock = 1, img = 'https://docs.fivem.net/vehicles/shamal.webp', category = 'plane', discount = 0, information = {TopSpeed = 290, Braking = 98, Acceleration = 93, Suspension = 98, Handling = 93} },
        { name = 'vestra', label = 'Vestra', model = 'Light Aircraft', price = 950000, stock = 1, img = 'https://docs.fivem.net/vehicles/vestra.webp', category = 'plane', discount = 0, information = {TopSpeed = 280, Braking = 96, Acceleration = 91, Suspension = 96, Handling = 91} },
        { name = 'dodo', label = 'Dodo', model = 'Amphibious Aircraft', price = 500000, stock = 1, img = 'https://docs.fivem.net/vehicles/dodo.webp', category = 'plane', discount = 0, information = {TopSpeed = 270, Braking = 94, Acceleration = 89, Suspension = 94, Handling = 89} },
        { name = 'cuban800', label = 'Cuban 800', model = 'Cargo Aircraft', price = 220000, stock = 1, img = 'https://docs.fivem.net/vehicles/cuban800.webp', category = 'plane', discount = 0, information = {TopSpeed = 260, Braking = 92, Acceleration = 87, Suspension = 92, Handling = 87} }
    },    
}

Config.Categories = {
    ['car'] = {
        { -- DONT REMOVE THIS ONE
            name = 'all',
            label = 'All'
        },
        {
            name = 'sports',
            label = 'Sports'
        },
        {
            name = 'sedans',
            label = 'Sedans'
        },
        {
            name = 'muscle',
            label = 'Muscles'
        },
        {
            name = 'super',
            label = 'Supers'
        },
    },

    ['boat'] = {
        { -- DONT REMOVE THIS ONE
            name = 'all',
            label = 'All'
        },
    },

    ['aircraft'] = {
        { -- DONT REMOVE THIS ONE
            name = 'all',
            label = 'All'
        },
        {
            name = 'helicopter',
            label = 'Helicopter'
        },
        {
            name = 'plane',
            label = 'Plane'
        },
    },
}

Config.BossmenuCategories = { -- Dont touch names. Just edit labels.
    {name = 'dashboard', label = 'Dashboard'}, 
    {name = 'company', label = 'Company'}, 
    {name = 'category', label = 'Categories'}, 
    {name = 'vehicles', label = 'Vehicles'}, 
    {name = 'perms', label = 'Perms'}, 
    {name = 'feedbackcomplains', label = 'Feedback & Complains'}, 
}

Config.BeginningVehicles = {  
    ['car'] = {
        { name = 't20', label = 'T20', model = 'Custom', price = 150000, stock = 1, img = 'https://docs.fivem.net/vehicles/t20.webp', category = 'sports', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'sultanrs', label = 'Sultan RS', model = '', price = 50000, stock = 1, img = 'https://docs.fivem.net/vehicles/sultanrs.webp', category = 'sedans', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
    },

    ['boat'] = {
        { name = 'seashark2', label = 'Seashark2', model = 'Normal', price = 15000, stock = 1, img = 'https://docs.fivem.net/vehicles/seashark2.webp', category = 'all', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'seashark3', label = 'Seashark3', model = 'Turbo', price = 50000, stock = 1, img = 'https://docs.fivem.net/vehicles/seashark3.webp', category = 'all', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
    },

    ['aircraft'] = {
        { name = 'volatus', label = 'Volatus', model = 'Luxury Helicopter', price = 50000, stock = 1, img = 'https://docs.fivem.net/vehicles/volatus.webp', category = 'helicopter', discount = 0, information = {TopSpeed = 273, Braking = 100, Acceleration = 89, Suspension = 100, Handling = 89} },
        { name = 'buzzard', label = 'Buzzard', model = 'Combat Helicopter', price = 750000, stock = 1, img = 'https://docs.fivem.net/vehicles/buzzard.webp', category = 'helicopter', discount = 0, information = {TopSpeed = 250, Braking = 95, Acceleration = 90, Suspension = 95, Handling = 90} },
    },
}

Config.Colors = { -- Index for game vehicle color (Almost all of them have already been added, you don't need to touch them) | https://wiki.rage.mp/index.php?title=Vehicle_Colors
    ["0"] = {name = "Black", hex = "#0d1116"},
    ["147"] = {name = "Carbon Black", hex = "#11141a"},
    ["1"] = {name = "Graphite", hex = "#1c1d21"},
    ["11"] = {name = "Anthracite Black", hex = "#1d2129"},
    ["2"] = {name = "Black Steel", hex = "#32383d"},
    ["3"] = {name = "Dark Steel", hex = "#454b4f"},
    ["4"] = {name = "Silver", hex = "#999da0"},
    ["5"] = {name = "Bluish Silver", hex = "#c2c4c6"},
    ["6"] = {name = "Rolled Steel", hex = "#979a97"},
    ["7"] = {name = "Shadow Silver", hex = "#637380"},
    ["8"] = {name = "Stone Silver", hex = "#63625c"},
    ["9"] = {name = "Midnight Silver", hex = "#3c3f47"},
    ["10"] = {name = "Cast Iron Silver", hex = "#444e54"},
    ["27"] = {name = "Red", hex = "#c00e1a"},
    ["28"] = {name = "Torino Red", hex = "#da1918"},
    ["29"] = {name = "Formula Red", hex = "#b6111b"},
    ["150"] = {name = "Lava Red", hex = "#bc1917"},
    ["30"] = {name = "Blaze Red", hex = "#a51e23"},
    ["31"] = {name = "Grace Red", hex = "#7b1a22"},
    ["32"] = {name = "Garnet Red", hex = "#8e1b1f"},
    ["33"] = {name = "Sunset Red", hex = "#6f1818"},
    ["34"] = {name = "Cabernet Red", hex = "#49111d"},
    ["143"] = {name = "Wine Red", hex = "#0e0d14"},
    ["35"] = {name = "Candy Red", hex = "#b60f25"},
    ["135"] = {name = "Hot Pink", hex = "#f21f99"},
    ["137"] = {name = "Pfister Pink", hex = "#df5891"},
    ["136"] = {name = "Salmon Pink", hex = "#fdd6cd"},
    ["36"] = {name = "Sunrise Orange", hex = "#d44a17"},
    ["38"] = {name = "Orange", hex = "#f78616"},
    ["138"] = {name = "Bright Orange", hex = "#f6ae20"},
    ["99"] = {name = "Gold", hex = "#ac9975"},
    ["90"] = {name = "Bronze", hex = "#916532"},
    ["88"] = {name = "Yellow", hex = "#ffcf20"},
    ["89"] = {name = "Race Yellow", hex = "#fbe212"},
    ["91"] = {name = "Dew Yellow", hex = "#e0e13d"},
    ["49"] = {name = "Dark Green", hex = "#132428"},
    ["50"] = {name = "Racing Green", hex = "#122e2b"},
    ["51"] = {name = "Sea Green", hex = "#12383c"},
    ["52"] = {name = "Olive Green", hex = "#31423f"},
    ["53"] = {name = "Bright Green", hex = "#155c2d"},
    ["54"] = {name = "Gasoline Green", hex = "#1b6770"},
    ["92"] = {name = "Lime Green", hex = "#98d223"},
    ["141"] = {name = "Midnight Blue", hex = "#0a0c17"},
    ["61"] = {name = "Galaxy Blue", hex = "#222e46"},
    ["62"] = {name = "Dark Blue", hex = "#233155"},
    ["63"] = {name = "Saxon Blue", hex = "#304c7e"},
    ["64"] = {name = "Blue", hex = "#47578f"},
    ["65"] = {name = "Mariner Blue", hex = "#637ba7"},
    ["66"] = {name = "Harbor Blue", hex = "#394762"},
    ["67"] = {name = "Diamond Blue", hex = "#d6e7f1"},
    ["68"] = {name = "Surf Blue", hex = "#76afbe"},
    ["69"] = {name = "Nautical Blue", hex = "#345e72"},
    ["73"] = {name = "Racing Blue", hex = "#2354a1"},
    ["70"] = {name = "Ultra Blue", hex = "#0b9cf1"},
    ["74"] = {name = "Light Blue", hex = "#6ea3c6"},
    ["96"] = {name = "Chocolate Brown", hex = "#221b19"},
    ["101"] = {name = "Bison Brown", hex = "#402e2b"},
    ["95"] = {name = "Creen Brown", hex = "#473f2b"},
    ["94"] = {name = "Feltzer Brown", hex = "#503218"},
    ["97"] = {name = "Maple Brown", hex = "#653f23"},
    ["103"] = {name = "Beechwood Brown", hex = "#46231a"},
    ["104"] = {name = "Sienna Brown", hex = "#752b19"},
    ["98"] = {name = "Saddle Brown", hex = "#775c3e"},
    ["100"] = {name = "Moss Brown", hex = "#6c6b4b"},
    ["102"] = {name = "Woodbeech Brown", hex = "#a4965f"},
    ["105"] = {name = "Sandy Brown", hex = "#bfae7b"},
    ["106"] = {name = "Bleached Brown", hex = "#dfd5b2"},
    ["71"] = {name = "Schafter Purple", hex = "#2f2d52"},
    ["72"] = {name = "Spinnaker Purple", hex = "#282c4d"},
    ["142"] = {name = "Midnight Purple", hex = "#0c0d18"},
    ["145"] = {name = "Bright Purple", hex = "#621276"},
    ["107"] = {name = "Cream", hex = "#f7edd5"},
    ["111"] = {name = "Ice White", hex = "#fffff6"},
    ["112"] = {name = "Frost White", hex = "#eaeaea"}
}