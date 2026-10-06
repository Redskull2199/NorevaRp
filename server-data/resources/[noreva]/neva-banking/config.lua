Config = {}

-- Framework: 'qb', 'esx', 'vrp', 'qbx'
Config.Framework = 'qb'
Config.Locale = 'tr' -- 'en' or 'tr'

-- Set to false for standard 3D Text 
Config.UseTarget = true
Config.TargetSystem = 'qb-target' -- 'ox_target' or 'qb-target'

Config.ATMProps = {
    `prop_fleeca_atm`,
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`
}

Config.BankLocations = {
    
       
    {
        coords = vector4(-1212.98, -330.84, 37.78, 20.0), 
        npcModel = 'ig_bankman'
    },
    {
        coords = vector4(-2962.58, 482.63, 15.7, 85.0), 
        npcModel = 'ig_bankman'
    },
    {
        coords = vector4(-112.2, 6469.3, 31.63, 130.0), 
        npcModel = 'ig_bankman'
    },
    {
        coords = vector4(314.19, -278.62, 54.17, 340.0), 
        npcModel = 'ig_bankman'
    },
    {
        coords = vector4(1175.06, 2706.64, 38.09, 180.0), 
        npcModel = 'ig_bankman'
    },
    {
        coords = vector4(241.73, 220.71, 106.29, 160.0), 
        npcModel = 'ig_bankman'
    }
}

Config.Blip = {
    Sprite = 108,
    Color = 2,
    Scale = 0.8,
    Label = "Banka"
}

Config.DiscordWebhook = {
    Enabled = true,
    WebhookURL = 'WEBHOOKHERE',
    BotName = 'Neva Banking Logs',
    BotAvatar = 'https://media.discordapp.net/attachments/1407015500340400278/1527868088291426395/mecbur.png?ex=6a5c398a&is=6a5ae80a&hm=cf159ab9dd13570f3f2f840ae7463a3d7df2e8631b7264f86b1d5ad73baa5a10&=&format=webp&quality=lossless&width=867&height=867',
    Color = 3447003, 
}

-- for /nbanking
Config.AdminDiscordIDs = {
    "835512171919573052", -- discordID
}
