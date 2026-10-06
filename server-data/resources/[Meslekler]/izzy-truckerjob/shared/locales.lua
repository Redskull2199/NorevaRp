Locales = {}

Locales['tr'] = {
    ui = {
        title = "TRUCKER JOB",
        description = "Teslimatları kabul et ve şehir genelinde yük taşıyarak para kazan",
        search_trailer = "Trailer Ara",
        search_truck = "Truck Ara",
        level = "Level",
        price = "Price",
        trailer = "TRAILER",
        truck = "TRUCK",
        job_name = "JOB NAME",
        adr = "ADR",
        km = "KM",
        per_km = "per KM",
        bonus = "BONUS",
        total = "TOTAL",
        locked = "Level %s Gerekli",
        step_trailer = "Trailer",
        step_truck = "Truck",
        speed = "Hız",
        capacity = "Kapasite",
        to = "→"
    },
    notify = {
        job_started = "Teslimat başladı! Trailer'ı işaretli konuma götür.",
        trailer_delivered = "Trailer teslim edildi! Alınan: $%s | Şimdi truck'ı geri götür!",
        return_truck = "Şimdi truck'ı depoya geri götür!",
        job_complete = "Görev tamamlandı! Toplam kazanç: $%s | XP: +%s",
        job_cancelled = "Görev iptal edildi!",
        vehicle_destroyed = "Aracın yok edildi! Görev iptal.",
        spawn_failed = "Araçlar spawn edilemedi",
        already_has_job = "Zaten aktif bir görevin var!",
        level_too_low_trailer = "Bu trailer için levelin çok düşük!",
        level_too_low_truck = "Bu truck için levelin çok düşük!",
        no_active_job = "Aktif görev bulunamadı!",
        level_up = "Level atladın! Artık level %s!",
        return_to_vehicle = "Aracına geri dön!",
        return_warning = "Araca %s saniye içinde dön!",
        welcome_back = "Tekrar hoş geldin!",
        left_vehicle_too_long = "Görev iptal - Araçtan çok uzun süre ayrıldın!",
        vehicle_damaged = "Araç hasar aldı! Mevcut ceza: %s%%",
        perfect_delivery = "Mükemmel teslimat! Kazanılan: $%s + Bonus XP",
        stop_to_deliver = "Teslim etmek için dur",
        stop_to_return = "Aracı teslim etmek için dur",
        trailer_lost = "Trailer kayboldu veya yok edildi! Görev iptal.",
        bring_trailer = "Trailer'ı teslimat noktasına getirmen gerekiyor!"
    }
}

Locales['en'] = {
    ui = {
        title = "TRUCKER JOB",
        description = "Accept deliveries and earn money by transporting goods across the city",
        search_trailer = "Search Trailer",
        search_truck = "Search Truck",
        level = "Level",
        price = "Price",
        trailer = "TRAILER",
        truck = "TRUCK",
        job_name = "JOB NAME",
        adr = "ADR",
        km = "KM",
        per_km = "per KM",
        bonus = "BONUS",
        total = "TOTAL",
        locked = "Level %s Required",
        step_trailer = "Trailer",
        step_truck = "Truck",
        speed = "Speed",
        capacity = "Capacity",
        to = "to"
    },
    notify = {
        job_started = "Delivery started! Deliver the trailer to the marked location.",
        trailer_delivered = "Trailer delivered! Received: $%s | Now return the truck!",
        return_truck = "Now return the truck to the depot!",
        job_complete = "Job complete! Total earned: $%s | XP: +%s",
        job_cancelled = "Job cancelled!",
        vehicle_destroyed = "Your vehicle was destroyed! Job cancelled.",
        spawn_failed = "Failed to spawn vehicles",
        already_has_job = "You already have an active job!",
        level_too_low_trailer = "Your level is too low for this trailer!",
        level_too_low_truck = "Your level is too low for this truck!",
        no_active_job = "No active job found!",
        level_up = "Level Up! You are now level %s!",
        return_to_vehicle = "Return to your vehicle!",
        return_warning = "Return to vehicle in %s seconds!",
        welcome_back = "Welcome back!",
        left_vehicle_too_long = "Job cancelled - You left the vehicle too long!",
        vehicle_damaged = "Vehicle damaged! Current penalty: %s%%",
        perfect_delivery = "Perfect delivery! Earned: $%s + Bonus XP",
        stop_to_deliver = "Stop to deliver",
        stop_to_return = "Stop to return vehicle",
        trailer_lost = "Trailer lost or destroyed! Job cancelled.",
        bring_trailer = "You must bring the trailer to the delivery point!"
    }
}

function L(key, ...)
    local lang = cfg.lang or 'en'
    local locale = Locales[lang]
    if not locale then locale = Locales['en'] end
    
    local keys = {}
    for k in string.gmatch(key, "[^.]+") do
        table.insert(keys, k)
    end
    
    local value = locale
    for _, k in ipairs(keys) do
        if value[k] then
            value = value[k]
        else
            return key
        end
    end
    
    if type(value) == 'string' and select('#', ...) > 0 then
        return string.format(value, ...)
    end
    
    return value
end
