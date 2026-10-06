-- IF YOU HAVE ANY PROBLEM OR DO YOU NEED HELP PLS COME TO MY DISCORD SERVER AND CREATE A TICKET
-- IF YOU DONT HAVE ANY PROBLEM YET AGAIN COME TO MY DISCORD :)
-- https://discord.gg/NCHub

NCHub = {}

NCHub.Framework = "qb" -- qb / oldqb | qb = export system | oldqb = triggerevent system
NCHub.Mysql = "oxmysql" -- Check fxmanifest.lua when you change it! | ghmattimysql / oxmysql / mysql-async
NCHub.OpenCommand = "playtimeShop"
NCHub.DefaultGarage = "pillboxgarage" -- purchased vehicles will be sent to this garage
NCHub.RewardCoin = 8
NCHub.NeededPlayTime = 60 -- Minutes

NCHub.Language = {
    title1 = "WEX",
    title2 = "Oyun Saati",
    coin = "Wex Coin",
    nextReward = "SONRAKİ COİN ÖDÜLÜ İÇİN KALAN ZAMAN;",
    exit = "Çıkış",
    reward = "ÖDÜL :",
    title3 = "OYUNCU",
    title4 = "LİSTESİ",
    title5 = "",
    title6 = "ALIŞVERİŞ",
    cancel = "İPTAL ETMEK",
    buy = "SATIN AL",
    accept = "KABUL ETMEK",
    realCurrency = "$",
    nextPage = "SONRAKİ SAYFA",
    previousPage = "ÖNCEKİ SAYFA",
    succesfully = "BAŞARIYLA",
    purchased = "SATIN ALINDI",
    invalidCode = "GEÇERSİZ KOD!",
    thxForPurch = "Satın aldığınız için teşekkürler!",
    top = "TOP",
    youDntHvEngMoney = "YETERİNCE PARANIZ YOK!",
    text6 = "6",
}

NCHub.Categories = {
    { category = "items", icon = "fa-solid fa-cookie-bite", items = {} }, -- do not touch items section..
    { category = "weapons", icon = "fa-solid fa-gun", items = {} }, -- do not touch items section..
    { category = "vehicles", icon = "fa-solid fa-car", items = {} }, -- do not touch items section..
}

-- itemType : vehicle, weapon, item, money
NCHub.Items = {
    { id = 1, itemName = "weapon_poolcue", label = "Sopa", price = 30, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_poolcue.png" },
    { id = 2, itemName = "weapon_bottle", label = "Kırık Şişe", price = 60, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_bottle.png" },
    { id = 3, itemName = "weapon_crowbar", label = "Levye", price = 75, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_crowbar.png" },
    { id = 4, itemName = "weapon_knife", label = "Knife", price = 120, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_knife.png" },
    { id = 5, itemName = "weapon_knuckle", label = "Muşta", price = 200, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_knuckle.png" },
    { id = 6, itemName = "weapon_switchblade", label = "Kelebek (Hobi)", price = 1000, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_switchblade.png" },
    { id = 7, itemName = "weapon_p226", label = "Sig Sauer P226", price = 750, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_p226.png" },
    { id = 8, itemName = "weapon_g17", label = "Glock 17 A", price = 950, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_g17.png" },
    { id = 9, itemName = "weapon_g19", label = "Glock 19", price = 1100, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_g19.png" },
    { id = 10, itemName = "weapon_microsmg2", label = "Uzi", price = 5000, count = 1, itemType = "weapon", category = "weapons", image = "./images/weapon_microsmg2.png" },

    { id = 11, itemName = "bandage", label = "Bandaj", price = 5, count = 1, itemType = "item", category = "items", image = "./images/bandage.png" },
    { id = 12, itemName = "energy", label = "Enerji İçeceği", price = 5, count = 1, itemType = "item", category = "items", image = "./images/energy.png" },
    { id = 13, itemName = "lockpick", label = "Maymuncuk", price = 5, count = 1, itemType = "item", category = "items", image = "./images/lockpick.png" },
    { id = 14, itemName = "radio", label = "Telsiz", price = 5, count = 1, itemType = "item", category = "items", image = "./images/radio.png" },
    { id = 15, itemName = "heavyarmor", label = "Çelik Yelek", price = 35, count = 1, itemType = "item", category = "items", image = "./images/heavyarmor.png" },
    { id = 16, itemName = "karapara", label = "KARA PARA", price = 60, count = 7000, itemType = "item", category = "items", image = "./images/black_money.png" },
    { id = 17, itemName = "ammo-9", label = "PISTOL AMMO", price = 175, count = 3, itemType = "item", category = "items", image = "./images/pistol_ammo.png" },
}

NCHub.CoinList = {
    -- { coinCount = 300, realPrice = 30, link = "https://www.yourTebexLink.com/crediAmountPage.html", image = "./images/coin.png" },
    -- { coinCount = 100, realPrice = 50, link = "https://www.yourTebexLink.com/crediAmountPage.html", image = "./images/coin.png" },
    -- { coinCount = 700, realPrice = 70, link = "https://www.yourTebexLink.com/crediAmountPage.html", image = "./images/coin.png" },
    -- { coinCount = 900, realPrice = 90, link = "https://www.yourTebexLink.com/crediAmountPage.html", image = "./images/coin.png" },
    -- { coinCount = 1200, realPrice = 120, link = "https://www.yourTebexLink.com/crediAmountPage.html", image = "./images/coin.png" },
    -- { coinCount = 1500, realPrice = 150, link = "https://www.yourTebexLink.com/crediAmountPage.html", image = "./images/coin.png" },
}