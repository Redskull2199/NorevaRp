-- 0R Chat V3 - Webhook ayarlari (config/webhooks.lua)
-- Discord webhook URL'lerini buraya yapistirin, `enabled` alanini true yapin.
Webhooks = {
    enabled = false,      -- true = discord loglari aktif
    main = '',            -- genel chat log webhook (me/do/kamu/ozel mesajlar)
    report = '',          -- report / reportreply log webhook
    announce = '',        -- announce (duyuru) log webhook
}
