-- ak4y dev.

-- IF YOU HAVE ANY PROBLEM OR DO YOU NEED HELP PLS COME TO MY DISCORD SERVER AND CREATE A TICKET
-- IF YOU DONT HAVE ANY PROBLEM YET AGAIN COME TO MY DISCORD :)
-- https://discord.gg/kWwM3Bx

AK4Y = {}

AK4Y.Framework = "qb" -- qb / oldqb | qb = export system | oldqb = triggerevent system
AK4Y.Mysql = "oxmysql" -- Check fxmanifest.lua when you change it! | ghmattimysql / oxmysql / mysql-async

AK4Y.SpinCost = 2 -- CR
AK4Y.SpinPeriod = 12 -- HOURS 
AK4Y.TebexPageLink = "https://discord.gg/wexrp"

AK4Y.DefaultGarage = "pillboxgarage" -- purchased vehicles will be sent to this garage

AK4Y.CommandUse = true
AK4Y.OpenCommandMenu = "dailywheel"

AK4Y.SpawnOpenMenu = false -- SHOULD THE MENU OPEN AUTOMATICALLY WHEN THE CHARACTER SPAWNS?

-------

-- OPEN MENU EVENT :  '    wex-dailywheel:openMenu    ' (client side event) 
-- TriggerEvent('wex-dailywheel:openMenu')

-------

--------------------------------------------------------------------------

-- MAX 8 ITEM IN TABLE
-- MAX 8 ITEM IN TABLE
-- MAX 8 ITEM IN TABLE

-- items in the table should have a chance total of 100 !! IMPORTANT !! IMPORTANT !! IMPORTANT !!
-- items in the table should have a chance total of 100 !! IMPORTANT !! IMPORTANT !! IMPORTANT !!
-- items in the table should have a chance total of 100 !! IMPORTANT !! IMPORTANT !! IMPORTANT !!

--- GiveItemTypes: "item" , "weapon", "vehicle", "money"
AK4Y.WheelItems = {
    { itemName = "heavyarmor", label = "Zırh", chance = 10, itemCount = 5, giveItemType = "item", image = "./img/itemImages/heavyarmor.png" },
    { itemName = "bread", label = "Ekmek", chance = 10, itemCount = 100000, giveItemType = "money", image = "./img/itemImages/money.png" },
    { itemName = "ammo-9", label = "Mermi", chance = 2, itemCount = 5, giveItemType = "weapon", image = "./img/itemImages/ammo-9.png" },
    { itemName = "bandage", label = "Bandaj", chance = 10, itemCount = 50, giveItemType = "item", image = "./img/itemImages/bandage.png" },
    { itemName = "weapon_p226", label = "Sig Sauer P226", chance = 1, itemCount = 1, giveItemType = "weapon", image = "./img/itemImages/weapon_p226.png" },
    { itemName = "weapon_switchblade", label = "Sustalı Bıçak", chance = 6, itemCount = 1, giveItemType = "weapon", image = "./img/itemImages/weapon_switchblade.png" },
    { itemName = "phone", label = "Telefon", chance = 20, itemCount = 1, giveItemType = "item", image = "./img/itemImages/phone.png" },
    { itemName = "tolmk7", label = "Golf MK7", chance = 0.1, itemCount = 1, giveItemType = "vehicle", image = "./img/itemImages/golf.png" },
    -- { itemName = "tolagerars", label = "Agera RS", chance = 0.1, itemCount = 1, giveItemType = "vehicle", image = "./img/itemImages/tolagerars.png" },
}

---------------------------------------------------------------------------

AK4Y.Translate = {
    title1 = "Wex",
    title2 = "ROLEPLAY",
    lwTxt = "Şanslı Çark",
    ttlDesc = "Harika ödüller kazanmak için şansınızı deneyin. Unutmayın, her gün bir çevirme hakkınız var!",
    spin = "SPIN",
    dlySpin = "Günlük Çevrim",
    gtSpin = "SPIN SATIN AL", 
    redeemCode = "E-PIN",
    enterCode = "KODU GİRİN",
    ecButton = "Kodu Girin",
    noRedeemCd = "Kullanma kodu yok mu?",
    byCodeButton = "E-PIN Satın Al",
    infoTitle = "UYARI!",
    infoWrongCodeDesc = "Kod yanlış!",
    infoYouDontHaveCoin = "Yeterli paranız yok!",
}

