local Translations = {
    afk = {
        will_kick = 'AFK kaldınız ve şu kadar sürede atılacaksınız: ',
        time_seconds = ' saniye!',
        time_minutes = ' dakika!',
        kick_message = 'AFK kaldığınız için atıldınız'
    },
    wash = {
        in_progress = "Araç yıkanıyor...",
        wash_vehicle = "[E] Aracı Yıka",
        wash_vehicle_target = "Aracı Yıka",
        dirty = "Araç kirli değil",
        cancel = "Yıkama iptal edildi..."
    },
    consumables = {
        eat_progress = "Yiyor...",
        drink_progress = "İçiyor...",
        liqour_progress = "İçki içiyor...",
        coke_progress = "Hızlı bir nefes çekiyor...",
        crack_progress = "Crack içiyor...",
        ecstasy_progress = "Hap alıyor...",
        healing_progress = "İyileşiyor...",
        meth_progress = "Met içiyor...",
        joint_progress = "Joint yakıyor...",
        use_parachute_progress = "Paraşüt takıyor...",
        pack_parachute_progress = "Paraşütü paketliyor...",
        no_parachute = "Paraşütün yok!",
        armor_full = "Zaten yeterince zırhın var!",
        armor_empty = "Zırh giymiyorsun...",
        armor_progress = "Vücut zırhını takıyor...",
        heavy_armor_progress = "Vücut zırhını takıyor...",
        remove_armor_progress = "Vücut zırhını çıkarıyor...",
        canceled = "İptal edildi..."
    },
    cruise = {
        unavailable = "Hız sabitleyici kullanılamıyor",
        activated = "Hız sabitleyici etkinleştirildi",
        deactivated = "Hız sabitleyici devre dışı bırakıldı"
    },
    editor = {
        started = "Kaydedilmeye başlandı!",
        save = "Kayıt edildi!",
        delete = "Kayıt silindi!",
        editor = "Sonra görüşürüz!"
    },
    firework = {
        place_progress = "Havai fişek yerleştiriliyor...",
        canceled = "İptal edildi...",
        time_left = "Havai fişek fırlatılacak ~r~"
    },
    seatbelt = {
        use_harness_progress = "Yarış kemeri takılıyor",
        remove_harness_progress = "Yarış kemeri çıkarılıyor",
        no_car = "Bir arabada değilsiniz."
    },
    teleport = {
        teleport_default = 'Asansörü Kullan'
    },
    pushcar = {
        stop_push = "[E] İtmeyi Durdur"
    }
}



if GetConvar('qb_locale', 'en') == 'tr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
