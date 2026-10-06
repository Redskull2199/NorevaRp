Config={}

Config.Karpuztoplama = { -- Karpuzların Çıkacağı Konumlar
        vector3(-95.61, 1910.17, 196.20)
}
Config.muratislekarpuz = vector3(149.74, 1666.72, 228.00)-- Karpuz işleme kordinat
Config.xdKarpuzsatis = vector3(657.76, 593.79, 129.05)-- Karpuz satış kordinat
Config.markerboyutu = 0.9 -- Marker Boyutu
Config.xdblipac = true --Blip açıp kapatma (true/false)
Config.KarpuztoplamaBlip = vector3(-99.49, 1909.74, 197.05) 
Config.KarpuztoplamaBlipAd = "Karpuz Toplama"
Config.KarpuzislemeMiktar = 1 -- Karpuz işlemek için minimum gereken miktar
Config.KarpuzMin = 1  -- Karpuz toplarken minimum vereceği sayı
Config.KarpuzMax = 1 -- Karpuz toplarken maximum vereceği sayı
Config.KarpuzislemeBlip = vector3(149.74, 1666.72, 228.91)
Config.KarpuzislemeBlipAd = "Karpuz İşleme"
Config.KarpuzsatisBlip = vector3(657.76, 593.79, 129.05)
Config.KarpuzsatisBlipAd = "Karpuz Satış"
Config.KarpuzsatisMiktar = 10 -- Karpuz satarken minimum satılan miktar
Config.KarpuzFiyat = 0 -- Karpuz satış fiyatı
Config.KarpuzOdeme = "cash" -- Karpuz satılınca para bankayamı nakitmi gelsin (Nakit = cash / Banka = cash)

Config.Price = 82

Config.MaxActionDistance = 3.0
Config.Cooldown = {
    pickup = 2500,
    slice = 2500,
    sell = 2000,
}
Config.ActionDuration = {
    pickup = 3000,
    slice = 4000,
    sell = 1000,
}
Config.TokenExpiry = 20000

-- Toplama / cooldown sırasında E spam: "bekle" bildirimi aralığı (ms)
Config.PickupWaitNotifyCooldown = 1200

Config.NPC = vector4(658.24, 593.65, 129.05, 71.18) --Satış NPC'sinin konumu
Config.ToplamaNPC = vector4(2725.57, 1540.15, 50.53, 261.46) --İsleme NPC'sinin konumu
