return {
    key = 38, -- E

    texts = {
        open = '[E] - Asansör'
    },

    interact_dist = 1.5,

    elevators = {
        ['Life Invader'] = {
            {
                number = 0, -- floor
                name = 'Ground Floor', -- or false
                code = nil, -- restrict floor by password
                pos = vector3(-1077.96, -254.81, 37.76),
            },
            {
                number = 1, -- floor
                name = 'Floor One', -- or false
                code = nil, -- restrict floor by password
                pos = vector3(-1078.06, -254.56, 44.02),
            },
            {
                number = 2, -- floor
                name = 'Roof', -- or false
                code = '1234', -- restrict floor by password
                pos = vector3(-1072.81, -246.69, 54.01),
            },
            
        },

        ['Asansör 2'] = {
            {
                number = 0, -- floor
                name = false, -- or false
                code = nil, -- restrict floor by password
                pos = vector3(136.26, -761.49, 45.75),
            },
            {
                number = 1, -- floor
                name = 'Roof', -- or false
                code = nil, -- restrict floor by password
                pos = vector3(136.22, -761.67, 241.15),
            },
        },

    ['Asansör 4'] = {
        {
            number = 0,
            name = '1. Kat',
            code = nil,
            pos = vector3(-2360.81, 3249.28, 32.81),
        },
        {
            number = 1,
            name = '2. Kat',
            code = nil,
            pos = vector3(-2360.8, 3249.25, 92.9),
        },
    },

    ['Asansör 5'] = {
        {
            number = 0,
            name = 'Zemin Kat',
            code = nil,
            pos = vector3(389.25, -74.95, 68.18),
        },
        {
            number = 1,
            name = '2. Kat',
            code = nil,
            pos = vector3(370.49, -56.13, 102.36),
        },
        {
            number = 2,
            name = "3. Kat",
            code = nil,
            pos = vector3(370.74, -57.03, 111.96),
        },
    },

    ['Asansör 6'] = {
        {
            number = 0,
            name = 'İçeri Gir',
            code = nil,
            pos = vector3(-312.27, -1308.22, 31.3),
        },
        {
            number = 1,
            name = 'Dışarı Çık',
            code = nil,
            pos = vector3(-308.2, -1296.16, 41.94),
        },
    },


        ['Example'] = {
            {
                number = 0, -- floor
                name = false, -- or false
                code = nil, -- restrict floor by password
                pos = vector3(-1067.68, -284.49, 37.71),
            },
            {
                number = 1, -- floor
                name = 'Roof', -- or false
                code = nil, -- restrict floor by password
                pos = vector3(-1066.94, -286.98, 50.02),
            },
        },
    },
}