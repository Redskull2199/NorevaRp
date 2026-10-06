# NEVA STORE DİSCORD.GG/NEVASTORE

## Installation

1. Place the `neva-banking` folder inside your `resources` directory.
2. Add `ensure neva-banking` to your `server.cfg`.
3. Import `bank.sql` into your database.
4. Open `config.lua` and configure the settings below.


```lua
Config.Framework = 'qb'        -- 'qb', 'esx', 'qbx', 'vrp'
Config.Locale = 'en'           -- 'en' or 'tr'
Config.TargetSystem = 'qb-target' -- 'qb-target' or 'ox_target'

Config.DiscordWebhook = {
    Enabled = true,
    WebhookURL = 'YOUR_WEBHOOK_URL',
}

Config.AdminDiscordIDs = {
    "YOURDISCORDiD",
}
```


## Kurulum

1. `neva-banking` klasorunu `resources` dizinine koy.
2. `server.cfg` dosyasina `ensure neva-banking` ekle.
3. `bank.sql` dosyasini veritabanina import et.
4. `config.lua` dosyasini aşagidaki ayarlara gore duzenle.

```lua
Config.Framework = 'qb'           -- 'qb', 'esx', 'qbx', 'vrp'
Config.Locale = 'tr'              -- 'en' veya 'tr'
Config.TargetSystem = 'qb-target' -- 'qb-target' veya 'ox_target'

Config.DiscordWebhook = {
    Enabled = true,
    WebhookURL = 'WEBHOOK_LINKIN',
}

Config.AdminDiscordIDs = {
    "DISCORD_ID",
}
```