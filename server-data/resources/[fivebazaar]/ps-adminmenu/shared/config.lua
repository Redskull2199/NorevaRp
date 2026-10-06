Config = Config or {}

Config.Fuel = "cdn-fuel"        -- "ps-fuel", "LegacyFuel", "ox_fuel"
Config.ResourcePerms = 'admin' -- permission to control resource(start stop restart)
Config.ShowCommandsPerms = 'admin' -- permission to show all commands
Config.RenewedPhone = false    -- if you use qb-phone from renewed. (multijob)

-- Key Bindings
Config.Keybindings = true
Config.AdminKey = "PageDown"
Config.NoclipKey = "PageUp"

-- Give Car
Config.DefaultGarage = "Alta Garage"

Config.Actions = {
    ["admin_car"] = {
        label = "Admin Aracı",
        type = "client",
        event = "ps-adminmenu:client:Admincar",
        perms = "mod",
    },

    ["ban_player"] = {
        label = "Oyuncuyu Yasakla",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu", option = "dropdown", data = "players" },
            { label = "Reason", display = "Sebep", option = "text" },
            {
                label = "Duration",
                display = "Süre",
                option = "dropdown",
                data = {
                    { label = "Kalıcı",  value = "2147483647" },
                    { label = "10 Dakika", value = "600" },
                    { label = "30 Dakika", value = "1800" },
                    { label = "1 Saat",     value = "3600" },
                    { label = "6 Saat",    value = "21600" },
                    { label = "12 Saat",   value = "43200" },
                    { label = "1 Gün",      value = "86400" },
                    { label = "3 Gün",     value = "259200" },
                    { label = "1 Hafta",     value = "604800" },
                    { label = "3 Hafta",     value = "1814400" },
                },
            },
            { label = "Onayla", option = "button", type = "server", event = "ps-adminmenu:server:BanPlayer" },
        },
    },

    ["bring_player"] = {
        label = "Oyuncuyu Yanına Getir",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:BringPlayer" },
        },
    },

    ["change_weather"] = {
        label = "Hava Durumunu Değiştir",
        perms = "mod",
        dropdown = {
            {
                label = "Weather",
                display = "Hava Durumu",
                option = "dropdown",
                data = {
                    { label = "Çok Güneşli", value = "Extrasunny" },
                    { label = "Açık",      value = "Clear" },
                    { label = "Nötr",    value = "Neutral" },
                    { label = "Dumanlı",       value = "Smog" },
                    { label = "Sisli",      value = "Foggy" },
                    { label = "Kapalı",   value = "Overcast" },
                    { label = "Bulutlu",     value = "Clouds" },
                    { label = "Açılıyor",   value = "Clearing" },
                    { label = "Yağmurlu",       value = "Rain" },
                    { label = "Gök Gürültülü",    value = "Thunder" },
                    { label = "Karlı",       value = "Snow" },
                    { label = "Kar Fırtınası",   value = "Blizzard" },
                    { label = "Hafif Kar",  value = "Snowlight" },
                    { label = "Noel",       value = "Xmas" },
                    { label = "Cadılar Bayramı",  value = "Halloween" },
                },
            },
            { label = "Onayla", option = "button", type = "client", event = "ps-adminmenu:client:ChangeWeather" },
        },
    },

    ["change_time"] = {
        label = "Saati Değiştir",
        perms = "mod",
        dropdown = {
            {
                label = "Time Events",
                display = "Saat Seçenekleri",
                option = "dropdown",
                data = {
                    { label = "Gün Doğumu", value = "06" },
                    { label = "Sabah", value = "09" },
                    { label = "Öğle",    value = "12" },
                    { label = "Gün Batımı",  value = "21" },
                    { label = "Akşam", value = "22" },
                    { label = "Gece",   value = "24" },
                },
            },
            { label = "Onayla", option = "button", type = "client", event = "ps-adminmenu:client:ChangeTime" },
        },
    },

    ["change_plate"] = {
        label = "Plakayı Değiştir",
        perms = "mod",
        dropdown = {
            { label = "Plate", display = "Plaka",   option = "text" },
            { label = "Onayla", option = "button", type = "client", event = "ps-adminmenu:client:ChangePlate" },
        },
    },

    ["clear_inventory"] = {
        label = "Envanteri Temizle",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:ClearInventory" },
        },
    },

    ["clear_inventory_offline"] = {
        label = "Çevrimdışı Envanteri Temizle",
        perms = "mod",
        dropdown = {
            { label = "Citizen ID", display = "Vatandaş No", option = "text",   data = "players" },
            { label = "Onayla",    option = "button", type = "server", event = "ps-adminmenu:server:ClearInventoryOffline" },
        },
    },

    ["clothing_menu"] = {
        label = "Kıyafet Menüsü Ver",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:ClothingMenu" },
        },
    },

    ["set_ped"] = {
        label = "Ped Ayarla",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",     option = "dropdown", data = "players" },
            { label = "Ped Models", display = "Ped Modelleri", option = "dropdown", data = "pedlist" },
            { label = "Onayla",    option = "button",   type = "server", event = "ps-adminmenu:server:setPed" },
        },
    },

    ["copy_coords"] = {
        label = "Koordinatları Kopyala",
        perms = "mod",
        dropdown = {
            {
                label = "Copy Coords",
                display = "Koordinatları Kopyala",
                option = "dropdown",
                data = {
                    { label = "Vector2 Kopyala", value = "vector2" },
                    { label = "Vector3 Kopyala", value = "vector3" },
                    { label = "Vector4 Kopyala",    value = "vector4" },
                    { label = "Bakış Yönünü Kopyala",  value = "heading" },
                },
            },
            { label = "Panoya Kopyala", option = "button", type = "client", event = "ps-adminmenu:client:copyToClipboard"},
        },
    },

    ["delete_vehicle"] = {
        label = "Aracı Sil",
        type = "command",
        event = "dv",
        perms = "mod",
    },

    ["freeze_player"] = {
        label = "Oyuncuyu Dondur",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:FreezePlayer" },
        },
    },

    ["drunk_player"] = {
        label = "Oyuncuyu Sarhoş Et",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:DrunkPlayer" },
        },
    },

    ["remove_stress"] = {
        label = "Stresi Kaldır",
        perms = "mod",
        dropdown = {
            { label = "Player (Optional)", display = "Oyuncu (Opsiyonel)", option = "dropdown", data = "players" },
            { label = "Onayla",           option = "button",   type = "server", event = "ps-adminmenu:server:RemoveStress" },
        },
    },

    ["set_ammo"] = {
        label = "Cephane Ayarla",
        perms = "admin",
        dropdown = {
            { label = "Ammo Ammount", display = "Cephane Miktarı", option = "text" },
            { label = "Onayla",      option = "button", type = "client", event = "ps-adminmenu:client:SetAmmo" },
        },
    },

    -- ["nui_focus"] = {
    --     label = "NUI Odağı Ver",
    --     perms = "mod",
    --     dropdown = {
    --         { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
    --         { label = "Onayla", option = "button",   type = "client", event = "" },
    --     },
    -- },

    ["god_mode"] = {
        label = "Tanrı Modu",
        type = "client",
        event = "ps-adminmenu:client:ToggleGodmode",
        perms = "mod",
    },

    ["give_car"] = {
        label = "Araç Ver",
        perms = "admin",
        dropdown = {
            { label = "Vehicle", display = "Araç",           option = "dropdown", data = "vehicles" },
            { label = "Player", display = "Oyuncu",            option = "dropdown", data = "players" },
            { label = "Plate (Optional)", display = "Plaka (Opsiyonel)",  option = "text" },
            { label = "Garage (Optional)", display = "Garaj (Opsiyonel)", option = "text" },
            { label = "Onayla",           option = "button",   type = "server",  event = "ps-adminmenu:server:givecar" },
        }
    },

    ["invisible"] = {
        label = "Görünmez",
        type = "client",
        event = "ps-adminmenu:client:ToggleInvisible",
        perms = "mod",
    },

    ["blackout"] = {
        label = "Elektriği Aç/Kapat",
        type = "server",
        event = "ps-adminmenu:server:ToggleBlackout",
        perms = "mod",
    },

    ["toggle_duty"] = {
        label = "Görevi Aç/Kapat",
        type = "server",
        event = "QBCore:ToggleDuty",
        perms = "mod",
    },

    ["toggle_laser"] = {
        label = "Lazeri Aç/Kapat",
        type = "client",
        event = "ps-adminmenu:client:ToggleLaser",
        perms = "mod",
    },

    ["set_perms"] = {
        label = "Yetki Ayarla",
        perms = "admin",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            {
                label = "Permissions",
                display = "Yetkiler",
                option = "dropdown",
                data = {
                    { label = "Mod",   value = "mod" },
                    { label = "Admin", value = "admin" },
                    { label = "God",   value = "god" },
                },
            },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:SetPerms" },
        },
    },

    ["set_bucket"] = {
        label = "Oturum Dünyası Ayarla",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Bucket", display = "Oturum Dünyası",  option = "text" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:SetBucket" },
        },
    },

    ["get_bucket"] = {
        label = "Oturum Dünyasını Getir",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:GetBucket" },
        },
    },

    ["mute_player"] = {
        label = "Oyuncuyu Sustur",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "client", event = "ps-adminmenu:client:MutePlayer" },
        },
    },

    ["noclip"] = {
        label = "Noclip",
        type = "client",
        event = "ps-adminmenu:client:ToggleNoClip",
        perms = "mod",
    },

    ["open_inventory"] = {
        label = "Envanteri Aç",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "client", event = "ps-adminmenu:client:openInventory" },
        },
    },

    ["open_stash"] = {
        label = "Kasayı Aç",
        perms = "mod",
        dropdown = {
            { label = "Stash", display = "Kasa",   option = "text" },
            { label = "Onayla", option = "button", type = "client", event = "ps-adminmenu:client:openStash" },
        },
    },

    ["open_trunk"] = {
        label = "Bagajı Aç",
        perms = "mod",
        dropdown = {
            { label = "Plate", display = "Plaka",   option = "text" },
            { label = "Onayla", option = "button", type = "client", event = "ps-adminmenu:client:openTrunk" },
        },
    },

    ["change_vehicle_state"] = {
        label = "Araç Garaj Durumu Ayarla",
        perms = "mod",
        dropdown = {
            { label = "Plate", display = "Plaka",   option = "text" },
            {
                label = "State",
                display = "Durum",
                option = "dropdown",
                data = {
                    { label = "İçeride",  value = "1" },
                    { label = "Dışarıda", value = "0" },
                },
            },
            { label = "Onayla", option = "button", type = "server", event = "ps-adminmenu:server:SetVehicleState" },
        },
    },

    ["revive_all"] = {
        label = "Herkesi Dirilt",
        type = "server",
        event = "ps-adminmenu:server:ReviveAll",
        perms = "mod",
    },

    ["revive_player"] = {
        label = "Oyuncuyu Dirilt",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:Revive" },
        },
    },

    ["revive_radius"] = {
        label = "Yarıçapta Dirilt",
        type = "server",
        event = "ps-adminmenu:server:ReviveRadius",
        perms = "mod",
    },

    ["refuel_vehicle"] = {
        label = "Aracı Yakıtla",
        type = "client",
        event = "ps-adminmenu:client:RefuelVehicle",
        perms = "mod",
    },

    ["set_job"] = {
        label = "Meslek Ata",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Job", display = "Meslek",     option = "dropdown", data = "jobs" },
            { label = "Grade", display = "Rütbe",   option = "text",     data = "grades" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:SetJob" },
        },
    },

    ["set_gang"] = {
        label = "Çete Ata",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Gang", display = "Çete",    option = "dropdown", data = "gangs" },
            { label = "Grade", display = "Rütbe",   option = "text",     data = "grades" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:SetGang" },
        },
    },

    ["give_money"] = {
        label = "Para Ver",
        perms = "admin",
        dropdown = {
            { label = "Player", display = "Oyuncu", option = "dropdown", data = "players" },
            { label = "Amount", display = "Miktar", option = "text" },
            {
                label = "Type",
                display = "Tür",
                option = "dropdown",
                data = {
                    { label = "Nakit",   value = "cash" },
                    { label = "Banka",   value = "bank" },
                    { label = "Kripto", value = "crypto" },
                },
            },
            { label = "Onayla", option = "button", type = "server", event = "ps-adminmenu:server:GiveMoney" },
        },
    },

    ["give_money_all"] = {
        label = "Herkese Para Ver",
        perms = "admin",
        dropdown = {
            { label = "Amount", display = "Miktar",  option = "text" },
            {
                label = "Type",
                display = "Tür",
                option = "dropdown",
                data = {
                    { label = "Nakit",   value = "cash" },
                    { label = "Banka",   value = "bank" },
                    { label = "Kripto", value = "crypto" },
                },
            },
            { label = "Onayla", option = "button", type = "server", event = "ps-adminmenu:server:GiveMoneyAll" },
        },
    },

    ["remove_money"] = {
        label = "Para Al",
        perms = "admin",
        dropdown = {
            { label = "Player", display = "Oyuncu", option = "dropdown", data = "players" },
            { label = "Amount", display = "Miktar", option = "text" },
            {
                label = "Type",
                display = "Tür",
                option = "dropdown",
                data = {
                    { label = "Nakit", value = "cash" },
                    { label = "Banka", value = "bank" },
                },
            },
            { label = "Onayla", option = "button", type = "server", event = "ps-adminmenu:server:TakeMoney" },
        },
    },

    ["give_item"] = {
        label = "Eşya Ver",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Item", display = "Eşya",    option = "dropdown", data = "items" },
            { label = "Amount", display = "Miktar",  option = "text" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:GiveItem" },
        },
    },

    ["give_item_all"] = {
        label = "Herkese Eşya Ver",
        perms = "mod",
        dropdown = {
            { label = "Item", display = "Eşya",    option = "dropdown", data = "items" },
            { label = "Amount", display = "Miktar",  option = "text" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:GiveItemAll" },
        },
    },

    ["spawn_vehicle"] = {
        label = "Araç Çıkar",
        perms = "mod",
        dropdown = {
            { label = "Vehicle", display = "Araç", option = "dropdown", data = "vehicles" },
            { label = "Onayla", option = "button",   type = "client",  event = "ps-adminmenu:client:SpawnVehicle" },
        },
    },

    ["fix_vehicle"] = {
        label = "Aracı Tamir Et",
        type = "command",
        event = "fix",
        perms = "mod",
    },

    ["fix_vehicle_for"] = {
        label = "Oyuncunun Aracını Tamir Et",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:FixVehFor" },
        },
    },

    ["spectate_player"] = {
        label = "Oyuncuyu İzle",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:SpectateTarget" },
        },
    },

    ["telport_to_player"] = {
        label = "Oyuncuya Işınlan",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:TeleportToPlayer" },
        },
    },

    ["telport_to_coords"] = {
        label = "Koordinatlara Işınlan",
        perms = "mod",
        dropdown = {
            { label = "Coords", display = "Koordinatlar",  option = "text" },
            { label = "Onayla", option = "button", type = "client", event = "ps-adminmenu:client:TeleportToCoords" },
        },
    },

    ["teleport_to_location"] = {
        label = "Konuma Işınlan",
        perms = "mod",
        dropdown = {
            { label = "Location", display = "Konum", option = "dropdown", data = "locations" },
            { label = "Onayla",  option = "button",   type = "client",   event = "ps-adminmenu:client:TeleportToLocation" },
        },
    },

    ["teleport_to_marker"] = {
        label = "İşarete Işınlan",
        type = "command",
        event = "tpm",
        perms = "mod",
    },

    ["teleport_back"] = {
        label = "Geri Işınlan",
        type = "client",
        event = "ps-adminmenu:client:TeleportBack",
        perms = "mod",
    },

    ["vehicle_dev"] = {
        label = "Araç Geliştirici Menüsü",
        type = "client",
        event = "ps-adminmenu:client:ToggleVehDevMenu",
        perms = "mod",
    },

    ["toggle_coords"] = {
        label = "Koordinatları Aç/Kapat",
        type = "client",
        event = "ps-adminmenu:client:ToggleCoords",
        perms = "mod",
    },

    ["toggle_blips"] = {
        label = "İşaretleri Aç/Kapat",
        type = "client",
        event = "ps-adminmenu:client:toggleBlips",
        perms = "mod",
    },

    ["toggle_names"] = {
        label = "İsimleri Aç/Kapat",
        type = "client",
        event = "ps-adminmenu:client:toggleNames",
        perms = "mod",
    },

    ["toggle_cuffs"] = {
        label = "Kelepçeyi Aç/Kapat",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:CuffPlayer" },
        },
    },

    ["max_mods"] = {
        label = "Maksimum Araç Modifikasyonu",
        type = "client",
        event = "ps-adminmenu:client:maxmodVehicle",
        perms = "mod",
    },

    ["warn_player"] = {
        label = "Oyuncuyu Uyar",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Reason", display = "Sebep",  option = "text" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:WarnPlayer" },
        },
    },

    ["infinite_ammo"] = {
        label = "Sınırsız Cephane",
        type = "client",
        event = "ps-adminmenu:client:setInfiniteAmmo",
        perms = "mod",
    },

    ["kick_player"] = {
        label = "Oyuncuyu At",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",  option = "dropdown", data = "players" },
            { label = "Reason", display = "Sebep",  option = "text" },
            { label = "Onayla", option = "button",   type = "server", event = "ps-adminmenu:server:KickPlayer" },
        },
    },


    ["play_sound"] = {
        label = "Ses Çal",
        perms = "mod",
        dropdown = {
            { label = "Player", display = "Oyuncu",     option = "dropdown", data = "players" },
            {
                label = "Sound",
                display = "Ses",
                option = "dropdown",
                data = {
                    { label = "Uyarı",      value = "alert" },
                    { label = "Kelepçe",       value = "cuff" },
                    { label = "Hava Anahtarı", value = "airwrench" },
                },
            },
            { label = "Ses Çal", option = "button",   type = "client", event = "ps-adminmenu:client:PlaySound" },
        },
    },
}

Config.PlayerActions = {
    ["teleportToPlayer"] = {
        label = "Oyuncuya Işınlan",
        type = "server",
        event = "ps-adminmenu:server:TeleportToPlayer",
        perms = "mod",
    },
    ["bringPlayer"] = {
        label = "Oyuncuyu Yanına Getir",
        type = "server",
        event = "ps-adminmenu:server:BringPlayer",
        perms = "mod",
    },
    ["revivePlayer"] = {
        label = "Oyuncuyu Dirilt",
        event = "ps-adminmenu:server:Revive",
        perms = "mod",
        type = "server"
    },
    ["spawnPersonalVehicle"] = {
        label = "Kişisel Aracı Çıkar",
        event = "ps-adminmenu:client:SpawnPersonalVehicle",
        perms = "mod",
        type = "client"
    },
    ["banPlayer"] = {
        label = "Oyuncuyu Yasakla",
        event = "ps-adminmenu:server:BanPlayer",
        perms = "mod",
        type = "server"
    },
    ["kickPlayer"] = {
        label = "Oyuncuyu At",
        event = "ps-adminmenu:server:KickPlayer",
        perms = "mod",
        type = "server"
    }
}

Config.OtherActions = {
    ["toggleDevmode"] = {
        type = "client",
        event = "ps-adminmenu:client:ToggleDev",
        perms = "admin",
        label = "Geliştirici Modunu Aç/Kapat"
    }
}

AddEventHandler("onResourceStart", function()
    Wait(100)
    if GetResourceState('ox_inventory') == 'started' then
        Config.Inventory = 'ox_inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        Config.Inventory = 'ps-inventory'
    elseif GetResourceState('lj-inventory') == 'started' then
        Config.Inventory = 'lj-inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Config.Inventory = 'qb-inventory'
    end
end)
