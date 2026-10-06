local debugMode = false

Shared = {
    distance = 25,
    slidespeed = 5,
    slidewait = 10,
    notifyPosition = 'top',

    -- Colors
    colors = {
        'black',
        'red',
        'blue',
        'yellow',
        'fake'
    },

    -- Gamemodes
    gamemodes = {
        [1] = {
            firstPiece = 15,
            othersPiece = 14,
            minPlayers = 3, -- for testing use 1
            supported = true,
            label = "Normal Okey",
        }
    },

    -- Locations (Table spawn positions)
    locations = {
        vec4(-1896.44, 2007.17, 141.65, 272.41),
        vec4(-75.3320, -818.7833, 326.1751, 356.7128),
        vec4(1366.46, -578.21, 74.38, 58.58),
        vec4(-268.5, 6638.55, 7.36, 184.12),
        vec4(-588.65, -1083.84, 21.33, 58.38),
        vec4(470.93, 5538.77, 785.27, 125.03)
    },

    -- Models
    models = {
        table = `prop_okey_table`,
        chair = `prop_chair_09`,
        board = `prop_okey_board`,
        default = 'prop_okey_'
    },

    -- Offsets
    offsets = {
        pieceOffsets = {
            [1] = {
                offset = vec3(0.05, 0.0, 0.0),
                rotation = vec3(0.0, 180.0, 0.0)
            },
            [2] = {
                offset = vec3(-0.05, 0.0, 0.0),
                rotation = vec3(0.0, 180.0, 0.0)
            },
            [3] = {
                offset = vec3(0.0, 0.05, 0.0),
                rotation = vec3(0.0, 180.0, 0.0)
            },
            [4] = {
                offset = vec3(0.0, -0.05, 0.0),
                rotation = vec3(0.0, 180.0, 0.0)
            }
        },
        cameraOffset = vec3(0, -0.6, 0.28),
        pieceInitZ = 0.95,
        thrownPieceOffset = vec3(-0.5, 0.05, 0.011),
        midpieceoffsetx = 0.9814,

        recievedPiece = {
            stackHeight = 0.011,
            x = -0.5,
            y = 0.05,
        },

        pieceGrid = {
            piecesPerRow = 13,
            pieceSpacing = 0.05,
            rowSpacing = -0.08,
            rowOffset = -0.05,
            frontRowOffset = -0.01,
            zBase = 1.1,
        }
    }
}

DebugOky = function(...)
    if not debugMode then return end
    lib.print.info(...)
end
