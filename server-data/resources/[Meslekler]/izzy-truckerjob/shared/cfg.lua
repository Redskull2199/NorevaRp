cfg = {
    debug = false,
    lang = 'en',

    npc = {
        model = "s_m_m_trucker_01",
        coords = vector4(1197.2555, -3253.5784, 7.0952, 86.7294),
        scenario = "WORLD_HUMAN_CLIPBOARD",
        blip = {
            enabled = true,
            sprite = 477,
            color = 5,
            scale = 0.8,
            label = "Trucker Job"
        }
    },

    vehicleSpawn = vector4(1182.0302, -3246.4927, 6.0288, 92.2539),
    trailerSpawn = vector4(1144.1898, -3258.3345, 5.9008, 272.5346),
    vehicleReturn = vector4(1182.0302, -3246.4927, 6.0288, 92.2539),

    vehicleExitTimeout = 30,

    deliveryZone = {
        enabled = true,
        radius = 10.0,
        drawDistance = 25.0,
        trailerMarker = {
            type = 1,
            r = 46,
            g = 204,
            b = 113,
            alpha = 100
        },
        truckMarker = {
            type = 1,
            r = 52,
            g = 152,
            b = 219,
            alpha = 100
        },
        arrow = {
            enabled = true,
            type = 25,
            alpha = 200
        }
    },

    trailers = {
        {
            id = 1,
            name = "Fuel Tanker",
            model = "tanker",
            requiredLevel = 1,
            adr = 3,
            destination = vector4(632.0240, 253.2897, 103.0994, 284.9793),
            price = 5440,
            color = "#00B4FF"
        },
        {
            id = 2,
            name = "Container Hauler",
            model = "trailers",
            requiredLevel = 2,
            adr = 2,
            destination = vector4(-98.9776, -2457.5679, 6.0193, 49.3958),
            price = 3250,
            color = "#00D9A5"
        },
        {
            id = 3,
            name = "Flatbed Cargo",
            model = "freighttrailer",
            requiredLevel = 3,
            adr = 1,
            destination = vector4(2772.3999, 3500.0454, 55.1886, 335.0257),
            price = 4820,
            color = "#7ED321"
        },
        {
            id = 4,
            name = "Chemical Transport",
            model = "tanker2",
            requiredLevel = 5,
            adr = 4,
            destination = vector4(3639.6643, 3766.7998, 28.5481, 195.0324),
            price = 7250,
            color = "#FF6B35"
        },
        {
            id = 5,
            name = "Heavy Machinery",
            model = "armytrailer",
            requiredLevel = 7,
            adr = 2,
            destination = vector4(-1768.5880, 3078.7776, 32.8131, 29.0233),
            price = 9500,
            color = "#E83F6F"
        },
        {
            id = 6,
            name = "Military Cargo",
            model = "armytrailer2",
            requiredLevel = 10,
            adr = 5,
            destination = vector4(-2408.6311, 3298.3005, 32.8299, 139.6935),
            price = 15000,
            color = "#9B59B6"
        }
    },

    trucks = {
        {
            id = 1,
            name = "Hauler",
            model = "hauler",
            requiredLevel = 1,
            bonus = 0
        },
        {
            id = 2,
            name = "Phantom",
            model = "phantom",
            requiredLevel = 2,
            bonus = 5
        },
        {
            id = 3,
            name = "Packer",
            model = "packer",
            requiredLevel = 4,
            bonus = 10
        },
        {
            id = 4,
            name = "Hauler Custom",
            model = "hauler2",
            requiredLevel = 6,
            bonus = 15
        },
        {
            id = 5,
            name = "Phantom Custom",
            model = "phantom3",
            requiredLevel = 8,
            bonus = 25
        }
    },

    damageCitation = {
        enabled = true,
        notifyOnDamage = true,
        healthThresholds = {
            { minHealth = 800, maxHealth = 1000, penaltyPercent = 0 },
            { minHealth = 600, maxHealth = 799, penaltyPercent = 10 },
            { minHealth = 400, maxHealth = 599, penaltyPercent = 25 },
            { minHealth = 200, maxHealth = 399, penaltyPercent = 40 },
            { minHealth = 0, maxHealth = 199, penaltyPercent = 60 }
        }
    },

    xpRewards = {
        perDelivery = 100,
        bonusNoDamage = 50,
        levelUpXp = { 500, 1000, 1500, 2000, 3000, 4000, 5500, 7000, 9000, 12000 }
    }
}
