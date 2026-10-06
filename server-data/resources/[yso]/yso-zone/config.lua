Config = {}

Config.Debug         = false   -- true = bölgeleri 3D çizgiyle göster
Config.CheckInterval = 500     -- ms, dinamik wait için baz değer

Config.Default = {
    displayTime = 3500,       -- ms
    animation   = "slide",    -- "slide" | "fade" | "zoom"
    position    = "bottom",   -- "bottom" | "top" | "center"
    color       = "#D4A843",  -- hex
    cooldown    = 2000,       -- ms (sadece girişe uygulanır)
}

Config.Zones = {

    [1] = {
        enabled     = true,
        name        = "Kamu Bölgesi",
        coords      = vector3(179.71, -967.58, 35.09),
        radius      = 60.0,
        minZ        = nil,        -- nil = kapalı
        maxZ        = nil,
        color       = "#2a8ab1",
        animation   = "slide",
        position    = "bottom",
        displayTime = 3500,
        cooldown    = 2000,
        blip = {
            enabled = false,
            sprite  = 1,          -- fivem.net/game-references/blips
            color   = 3,          -- 0-85 blip renk kodu
            scale   = 0.8,
            label   = "Kamu Bölgesi",
        },
        allowedJobs = nil,    -- nil = herkese açık | {"police", "ambulance"}
        enter = { subtitle = "BÖLGEYE GİRİŞ",  title = "KAMU BÖLGESİ", color = "#FFD700" },
        exit  = { subtitle = "BÖLGEDEN ÇIKIŞ", title = "KAMU BÖLGESİ", color = "#808080" },
    },

    [2] = {
        enabled     = true,
        name        = "İskele Bölgesi",
        coords      = vector3(-1815.0552, -1202.0121, 13.0176),
        radius      = 150.0,
        minZ        = 18.0,
        maxZ        = 40.0,
        color       = "#D4A843",
        animation   = "fade",
        position    = "bottom",
        displayTime = 3500,
        cooldown    = 2000,
        blip = {
            enabled = false,
            sprite  = 356,
            color   = 5,
            scale   = 0.8,
            label   = "İskele Bölgesi",
        },
        allowedJobs = nil,    -- nil = herkese açık | {"police", "ambulance"}
        enter = { subtitle = "BÖLGEYE GİRİŞ",  title = "LİMAN BÖLGESİ", color = "#FFD700" },
        exit  = { subtitle = "BÖLGEDEN ÇIKIŞ", title = "LİMAN BÖLGESİ", color = "#808080" },
    },

}
