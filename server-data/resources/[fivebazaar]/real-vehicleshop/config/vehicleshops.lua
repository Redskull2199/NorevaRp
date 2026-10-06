Config.Vehicleshops = {
    {
        Manageable = true, -- If you make this true, it'll be available for purchase (Company).
        Type = 'car', -- Here you have 3 options as type: 'car' => vehicle, 'boat' => ship, 'aircraft' => airplane/helicopter
        Jobs = {'all'}, -- Professions listed here can only access to the menu and purchase vehicles. Recommendation: If you are going to use it as a company, make it 'all'.
        Price = 150000, -- Amount to buy the company
        Marker = "~INPUT_PICKUP~ - Open Vehicleshop", -- Drawtext

        Owner = "", -- Dont touch
        CompanyName = "Real Cardealer", -- Company Name at the beginning
        CompanyDescriptionText = "Lorem, ipsum dolor sit amet consectetur adipisicing elit. Quaerat illum aperiam neque nisi nemo itaque error voluptatem, ut minus, eaque ex similique maxime!", -- Company Description
        CompanyMoney = 10000, -- Amount of money in the company's account | At the beginning
        Rating = 0, -- Dont touch
        Vehicles = {}, -- Dont touch
        Categories = {}, -- Dont touch
        Feedbacks = {}, -- Dont touch
        Complaints = {}, -- Dont touch
        Preorders = {}, -- Dont touch
        Employees = {}, -- Dont touch
        SoldVehicles = {}, -- Dont touch
        Transactions = {}, -- Dont touch
        Perms = {}, -- Dont touch
        Discount = 0, -- Dont touch

        BlipSettings = { -- Blip settings
            Enable = true,
            Sprite = 227,
            Scale = 0.8,
            Color = 0
        },
        SpawnCoords = vector4(-13.99, -1093.8, 26.05, 160.17), -- The place to spawn when you buy the vehicle
        ShopOpenCoords = vector3(-33.21, -1103.69, 26.42), -- Coordinate to open Vehicleshop menu
        BossmenuCoords = vector3(-32.04, -1114.23, 26.42), -- Coordinate to open bossmenu
        CamSettings = {
            VehiclePos = vector4(797.25, -3000.18, -69.63, 242.65), -- When looking at vehicles, the coordinates of the vehicle | Preview mode
            PlayerPos = vector3(806.75, -3000.08, -69.0), -- Keep this coordinate in front of the vehicle | Preview mode
            Coords = vector3(806.75, -3000.08, -69.0), -- Keep this coordinate in front of the vehicle | Preview mode
        },
        TestDriveLocation = vector4(-1331.59, -2202.41, 13.32, 149.94), -- Test drive location
        ComplaintForm = vector3(-57.09, -1097.23, 26.42), -- Complaint form filing location
    },
    {
        Manageable = true, 
        Type = 'boat',
        Jobs = {'all'},
        Price = 150000,
        Marker = "~INPUT_PICKUP~ - Open Boatshop",

        Owner = "",
        CompanyName = "Real Boatshop",
        CompanyDescriptionText = "Lorem, ipsum dolor sit amet consectetur adipisicing elit. Quaerat illum aperiam neque nisi nemo itaque error voluptatem, ut minus, eaque ex similique maxime!",
        CompanyMoney = 10000,
        Rating = 0,
        Vehicles = {},
        Categories = {},
        Feedbacks = {},
        Complaints = {},
        Preorders = {},
        Employees = {},
        SoldVehicles = {},
        Transactions = {},
        Perms = {},
        Discount = 0, 

        BlipSettings = {
            Enable = true,
            Sprite = 410,
            Scale = 0.8,
            Color = 2
        },
        SpawnCoords = vector4(-727.55, -1367.86, 0.52, 136.62),
        ShopOpenCoords = vector3(-718.53, -1326.79, 1.6),
        BossmenuCoords = vector3(-696.65, -1320.73, 5.1),
        CamSettings = {
            VehiclePos = vector4(-706.67, -1338.55, -0.1, 353.3),
            PlayerPos = vector3(-710.27, -1336.03, 1.46),
            Coords = vector3(-710.27, -1336.03, 1.46),
        },
        TestDriveLocation = vector4(-727.55, -1367.86, 0.52, 136.62),
        ComplaintForm = vector3(1, 1, 1),
    },
    {
        Manageable = false, 
        Type = 'aircraft',
        Jobs = {'all'},
        Price = 150000,
        Marker = "~INPUT_PICKUP~ - Open Aircraft",

        Owner = "",
        CompanyName = "Real Aircraft",
        CompanyDescriptionText = "Lorem, ipsum dolor sit amet consectetur adipisicing elit. Quaerat illum aperiam neque nisi nemo itaque error voluptatem, ut minus, eaque ex similique maxime!",
        CompanyMoney = 10000,
        Rating = 0,
        Vehicles = {},
        Categories = {},
        Feedbacks = {},
        Complaints = {},
        Preorders = {},
        Employees = {},
        SoldVehicles = {},
        Transactions = {},
        Perms = {},
        Discount = 0,

        BlipSettings = {
            Enable = true,
            Sprite = 64,
            Scale = 0.8,
            Color = 3
        },
        SpawnCoords = vector4(-763.14, -1452.73, 5.0, 53.69),
        ShopOpenCoords = vector3(-753.48, -1512.23, 5.02),
        BossmenuCoords = vector3(-759.47, -1515.31, 4.98),
        CamSettings = {
            VehiclePos = vector4(-734.18, -1457.19, 5.66, 47.75), 
            PlayerPos = vector3(-739.79, -1435.5, 5.0),
            Coords = vector3(-739.79, -1435.5, 5.0),
        },
        TestDriveLocation = vector4(-734.18, -1457.19, 5.66, 47.75),
        ComplaintForm = vector3(1, 1, 1),
    }
}