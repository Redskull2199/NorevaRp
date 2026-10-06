-- ============================================================
-- TURBO TOYS - locales/locales.lua
-- Hem client Lua hem NUI tarafindaki tum text'ler burada.
-- Config.Locale = 'tr' veya 'en' ile dil secilir.
-- NUI tarafi otomatik olarak menu.lua'nin gonderdigi 'ui' subtable'i alir.
-- ============================================================

Locales = {

    -- ========================================================
    -- TÜRKÇE
    -- ========================================================
    tr = {
        -- Notifications (client Lua)
        toy_attached       = 'Oyuncak elinde',
        toy_removed        = 'Oyuncak kaldırıldı',
        no_toy_held        = 'Elinde bir oyuncak yok',
        position_changed   = '%s pozisyonuna geçildi',
        light_emitted      = '✨ Işık saçıldı',
        cooldown           = 'Yavaş ol',
        cant_use_now       = 'Şu an kullanamazsın',
        gizmo_active       = 'Gizmo aktif',
        gizmo_closed       = 'Gizmo kapalı',
        saved              = 'Kaydedildi: %s',
        save_failed        = 'Kayıt başarısız',
        bound              = 'Varsayılan kaydedildi',
        unbound            = 'Varsayılan kaldırıldı',
        deleted            = 'Pozisyon silindi',
        scale_reset        = 'Boyut sıfırlandı',

        -- UI (NUI'ye gonderilir - sub-table)
        ui = {
            menu_title           = 'TOY MENU',
            close_kbd            = 'KAPAT',
            action_position      = 'Pozisyon Seç',
            action_position_desc = 'tutuş şeklini ayarla',
            action_gizmo         = '3D Gizmo',
            action_gizmo_desc    = 'serbest yerleştir + kaydet',
            action_light         = 'Işık Saç',
            action_light_desc    = 'parlama efekti',
            action_scale         = 'Boyut Ayarla',
            action_scale_desc    = 'prop büyüklüğünü değiştir',
            action_back          = 'Geri',

            -- multi-toy + place vehicle (TR)
            action_place_vehicle      = 'Araca Yerleştir',
            action_place_vehicle_desc = 'en yakın araca yerleştir',
            action_drop_focused       = 'Bu Oyuncağı Kaldır',
            action_drop_focused_desc  = 'sadece bu oyuncak silinir, diğerleri kalır',
            action_drop_all           = 'Tüm Oyuncakları Kaldır',
            action_drop_all_desc      = 'hepsi silinir',

            section_defaults     = 'VARSAYILAN',
            section_user         = 'KAYDEDİLEN',
            section_settings     = 'AYARLAR',
            section_body         = 'VÜCUTTAKİ',
            section_vehicle      = 'ARAÇTAKİ',

            no_user_positions    = 'Henüz kayıt yok. <strong>3D Gizmo</strong> ile özel pozisyon kaydedebilirsin.',
            bound_default        = 'Varsayılan',
            tooltip_set_default  = 'Varsayılan yap',
            tooltip_unset_default= 'Varsayılanı kaldır',
            tooltip_delete       = 'Sil',

            setting_sound        = 'Ses Efekti',
            setting_sound_on     = 'Açık',
            setting_sound_off    = 'Kapalı',

            confirm_title        = 'Emin misin?',
            confirm_delete_text  = '"%s" pozisyonunu silmek istediğine emin misin?',
            confirm_cancel       = 'İptal',
            confirm_delete       = 'Sil',

            -- Save dialog (gizmo kaydet)
            save_title           = 'POZİSYON KAYDET',
            save_name_label      = 'İSİM',
            save_name_placeholder= 'Örn: Omzum, Belim, vs.',
            save_make_default    = 'Bu oyuncak için varsayılan yap',
            save_cancel          = 'İPTAL',
            save_save            = 'KAYDET',

            -- Scale screen
            scale_title          = 'BOYUT',
            scale_current        = 'MEVCUT',
            scale_default        = 'VARSAYILAN',
            scale_minus_big      = '−10%',
            scale_minus_small    = '−5%',
            scale_plus_small     = '+5%',
            scale_plus_big       = '+10%',
            scale_reset          = 'SIFIRLA',
            scale_hint           = 'Sürükle veya butonlarla ayarla',

            -- Gizmo HUD
            gizmo_badge          = '3D GIZMO',
            gizmo_lbl_mode       = 'MOD',
            gizmo_lbl_bone       = 'BONE',
            gizmo_lbl_pos        = 'POS',
            gizmo_lbl_rot        = 'ROT',
            gizmo_bone_change    = 'bone değiştir',
            gizmo_mode_translate = 'KONUM',
            gizmo_mode_rotate    = 'YÖN',
            gizmo_drag_translate = 'TAŞIYORUM',
            gizmo_drag_rotate    = 'DÖNDÜRÜYORUM',
            gizmo_hint_left      = 'çek = axis',
            gizmo_hint_right     = 'çek = kamera',
            gizmo_hint_wheel     = 'zoom (SHIFT=FOV)',
            gizmo_hint_save      = 'KAYDET',
            gizmo_hint_cancel    = 'iptal',
        },

        -- Position labels (TR)
        pos_two_hand       = 'İki Elle Tut',
        pos_right_hip      = 'Sağ Kalça',
        pos_left_hip       = 'Sol Kalça',
        pos_back           = 'Sırtta',
        pos_left_shoulder  = 'Sol Omuz',
        pos_head_top       = 'Baş Üstü',
        pos_waist          = 'Belde',

        -- === Multi-toy + vehicle placement (TR) ===
        toy_focus          = 'Odak: %s',
        toy_dropped        = '%s kaldırıldı (odak: %s)',
        all_toys_removed   = 'Tüm oyuncaklar kaldırıldı',
        no_focus           = 'Odak yok',
        not_active         = 'Aktif değil: %s',
        vehicle_attach     = 'ARACA yerleştiriliyor — KAPUT (B/N ile bone)',
        ped_attach         = 'KARAKTERE yerleştiriliyor',
        no_vehicle_nearby  = 'Yakında araç yok (5m)',
        gizmo_not_active   = 'Gizmo aktif değil',
        vehicle_placed     = 'Araca yerleştirildi (oturum süresince)',
        reset_done         = 'Sıfırlandı',

        -- === Claw machine (TR) ===
        claw_title         = 'VİNÇLİ OYUNCAK',
        claw_start         = 'BAŞLATMAK İÇİN BAS',
        claw_busy          = 'ŞU AN KULLANIMDA',
        claw_pickup        = 'OYUNCAĞINI AL',
        claw_busy_notify   = 'Bu makine şu anda kullanılıyor.',
        claw_no_cash       = 'Yetersiz nakit. Oyun bedeli: $%s',
        claw_play_hint     = 'Yön tuşları = hareket, ENTER = indir (TEK HAK), ESC = çık',
        claw_lose          = 'Boş! Tekrar dene.',
        claw_win_dropped   = '%s tepsiye düştü. Almak için yaklaş ve ENTER\'a bas.',
        claw_in_inv        = '%s envantere eklendi!',
        claw_add_failed    = '%s eklenemedi (item tanımlı değil?)',
        claw_orphan_cleaned= '%d yetim toy temizlendi',

        -- Notify titles (TR)
        notify_title_success = 'BAŞARILI',
        notify_title_error   = 'HATA',
        notify_title_info    = 'BİLGİ',
        notify_title_warning = 'UYARI',
    },

    -- ========================================================
    -- ENGLISH
    -- ========================================================
    en = {
        -- Notifications
        toy_attached       = 'Toy in hand',
        toy_removed        = 'Toy removed',
        no_toy_held        = "You're not holding a toy",
        position_changed   = 'Switched to %s position',
        light_emitted      = '✨ Light emitted',
        cooldown           = 'Slow down',
        cant_use_now       = "Can't use right now",
        gizmo_active       = 'Gizmo active',
        gizmo_closed       = 'Gizmo closed',
        saved              = 'Saved: %s',
        save_failed        = 'Save failed',
        bound              = 'Default position set',
        unbound            = 'Default removed',
        deleted            = 'Position deleted',
        scale_reset        = 'Scale reset',

        ui = {
            menu_title           = 'TOY MENU',
            close_kbd            = 'CLOSE',
            action_position      = 'Choose Position',
            action_position_desc = 'adjust how you hold it',
            action_gizmo         = '3D Gizmo',
            action_gizmo_desc    = 'free place + save',
            action_light         = 'Emit Light',
            action_light_desc    = 'glow effect',
            action_scale         = 'Adjust Size',
            action_scale_desc    = 'change prop size',
            action_back          = 'Back',

            -- multi-toy + place vehicle (EN)
            action_place_vehicle      = 'Place on Vehicle',
            action_place_vehicle_desc = 'attach to nearest vehicle',
            action_drop_focused       = 'Remove This Toy',
            action_drop_focused_desc  = 'only the focused one is removed',
            action_drop_all           = 'Remove All Toys',
            action_drop_all_desc      = 'wipe all attached toys',

            section_defaults     = 'DEFAULT',
            section_user         = 'SAVED',
            section_settings     = 'SETTINGS',
            section_body         = 'ON BODY',
            section_vehicle      = 'ON VEHICLE',

            no_user_positions    = 'No saved positions yet. Use <strong>3D Gizmo</strong> to save custom poses.',
            bound_default        = 'Default',
            tooltip_set_default  = 'Set as default',
            tooltip_unset_default= 'Remove default',
            tooltip_delete       = 'Delete',

            setting_sound        = 'Sound Effects',
            setting_sound_on     = 'On',
            setting_sound_off    = 'Off',

            confirm_title        = 'Are you sure?',
            confirm_delete_text  = 'Delete position "%s"?',
            confirm_cancel       = 'Cancel',
            confirm_delete       = 'Delete',

            -- Save dialog (gizmo save)
            save_title           = 'SAVE POSITION',
            save_name_label      = 'NAME',
            save_name_placeholder= 'e.g. Shoulder, Waist, etc.',
            save_make_default    = 'Set as default for this toy',
            save_cancel          = 'CANCEL',
            save_save            = 'SAVE',

            -- Scale screen
            scale_title          = 'SIZE',
            scale_current        = 'CURRENT',
            scale_default        = 'DEFAULT',
            scale_minus_big      = '−10%',
            scale_minus_small    = '−5%',
            scale_plus_small     = '+5%',
            scale_plus_big       = '+10%',
            scale_reset          = 'RESET',
            scale_hint           = 'Drag or use buttons',

            -- Gizmo HUD
            gizmo_badge          = '3D GIZMO',
            gizmo_lbl_mode       = 'MODE',
            gizmo_lbl_bone       = 'BONE',
            gizmo_lbl_pos        = 'POS',
            gizmo_lbl_rot        = 'ROT',
            gizmo_bone_change    = 'change bone',
            gizmo_mode_translate = 'MOVE',
            gizmo_mode_rotate    = 'ROTATE',
            gizmo_drag_translate = 'MOVING',
            gizmo_drag_rotate    = 'ROTATING',
            gizmo_hint_left      = 'drag = axis',
            gizmo_hint_right     = 'drag = camera',
            gizmo_hint_wheel     = 'zoom (SHIFT=FOV)',
            gizmo_hint_save      = 'SAVE',
            gizmo_hint_cancel    = 'cancel',
        },

        -- Position labels (EN)
        pos_two_hand       = 'Two-Hand Hold',
        pos_right_hip      = 'Right Hip',
        pos_left_hip       = 'Left Hip',
        pos_back           = 'On Back',
        pos_left_shoulder  = 'Left Shoulder',
        pos_head_top       = 'On Head',
        pos_waist          = 'On Waist',

        -- Multi-toy + vehicle placement (EN)
        toy_focus          = 'Focus: %s',
        toy_dropped        = '%s removed (focus: %s)',
        all_toys_removed   = 'All toys removed',
        no_focus           = 'No focused toy',
        not_active         = 'Not active: %s',
        vehicle_attach     = 'Placing on VEHICLE — HOOD (B/N to switch bone)',
        ped_attach         = 'Placing on CHARACTER',
        no_vehicle_nearby  = 'No vehicle nearby (5m)',
        gizmo_not_active   = 'Gizmo is not active',
        vehicle_placed     = 'Placed on vehicle (session only)',
        reset_done         = 'Reset',

        -- Claw machine (EN)
        claw_title         = 'CLAW MACHINE',
        claw_start         = 'PRESS TO START',
        claw_busy          = 'CURRENTLY IN USE',
        claw_pickup        = 'PICK UP YOUR TOY',
        claw_busy_notify   = 'This machine is in use.',
        claw_no_cash       = 'Not enough cash. Play cost: $%s',
        claw_play_hint     = 'Arrows = move, ENTER = drop (ONE TRY), ESC = leave',
        claw_lose          = 'Empty! Try again.',
        claw_win_dropped   = '%s dropped in the tray. Walk over and press ENTER.',
        claw_in_inv        = '%s added to inventory!',
        claw_add_failed    = '%s could not be added (item not defined?)',
        claw_orphan_cleaned= '%d orphan toys cleaned up',

        -- Notify titles (EN)
        notify_title_success = 'SUCCESS',
        notify_title_error   = 'ERROR',
        notify_title_info    = 'INFO',
        notify_title_warning = 'WARNING',
    },

    -- ========================================================
    -- DEUTSCH
    -- ========================================================
    de = {
        toy_attached       = 'Spielzeug in der Hand',
        toy_removed        = 'Spielzeug entfernt',
        no_toy_held        = 'Du hältst kein Spielzeug',
        position_changed   = 'Zu Position %s gewechselt',
        light_emitted      = '✨ Licht abgegeben',
        cooldown           = 'Langsamer',
        cant_use_now       = 'Im Moment nicht nutzbar',
        gizmo_active       = 'Gizmo aktiv',
        gizmo_closed       = 'Gizmo geschlossen',
        saved              = 'Gespeichert: %s',
        save_failed        = 'Speichern fehlgeschlagen',
        bound              = 'Standardposition gesetzt',
        unbound            = 'Standard entfernt',
        deleted            = 'Position gelöscht',
        scale_reset        = 'Größe zurückgesetzt',

        ui = {
            menu_title           = 'SPIELZEUG-MENÜ',
            close_kbd            = 'SCHLIESSEN',
            action_position      = 'Position wählen',
            action_position_desc = 'wie du es hältst',
            action_gizmo         = '3D Gizmo',
            action_gizmo_desc    = 'frei platzieren + speichern',
            action_light         = 'Licht abgeben',
            action_light_desc    = 'Leuchteffekt',
            action_scale         = 'Größe anpassen',
            action_scale_desc    = 'Prop-Größe ändern',
            action_back          = 'Zurück',
            action_place_vehicle      = 'Aufs Fahrzeug',
            action_place_vehicle_desc = 'am nächsten Fahrzeug befestigen',
            action_drop_focused       = 'Dieses Spielzeug entfernen',
            action_drop_focused_desc  = 'nur das fokussierte wird entfernt',
            action_drop_all           = 'Alle Spielzeuge entfernen',
            action_drop_all_desc      = 'alle befestigten löschen',
            section_defaults     = 'STANDARD',
            section_user         = 'GESPEICHERT',
            section_settings     = 'EINSTELLUNGEN',
            section_body         = 'AM KÖRPER',
            section_vehicle      = 'AM FAHRZEUG',
            no_user_positions    = 'Noch keine gespeicherten Positionen.',
            bound_default        = 'Standard',
            tooltip_set_default  = 'Als Standard setzen',
            tooltip_unset_default= 'Standard entfernen',
            tooltip_delete       = 'Löschen',
            setting_sound        = 'Soundeffekte',
            setting_sound_on     = 'An',
            setting_sound_off    = 'Aus',
            confirm_title        = 'Sicher?',
            confirm_delete_text  = 'Position "%s" löschen?',
            confirm_cancel       = 'Abbrechen',
            confirm_delete       = 'Löschen',
            save_title           = 'POSITION SPEICHERN',
            save_name_label      = 'NAME',
            save_name_placeholder= 'z. B. Schulter, Hüfte, etc.',
            save_make_default    = 'Als Standard für dieses Spielzeug',
            save_cancel          = 'ABBRECHEN',
            save_save            = 'SPEICHERN',
            scale_title          = 'GRÖSSE',
            scale_current        = 'AKTUELL',
            scale_default        = 'STANDARD',
            scale_minus_big      = '−10%',
            scale_minus_small    = '−5%',
            scale_plus_small     = '+5%',
            scale_plus_big       = '+10%',
            scale_reset          = 'RESET',
            scale_hint           = 'Ziehen oder Buttons nutzen',
            gizmo_badge          = '3D GIZMO',
            gizmo_lbl_mode       = 'MODUS',
            gizmo_lbl_bone       = 'KNOCHEN',
            gizmo_lbl_pos        = 'POS',
            gizmo_lbl_rot        = 'ROT',
            gizmo_bone_change    = 'Knochen wechseln',
            gizmo_mode_translate = 'BEWEGEN',
            gizmo_mode_rotate    = 'DREHEN',
            gizmo_drag_translate = 'BEWEGT',
            gizmo_drag_rotate    = 'DREHT',
            gizmo_hint_left      = 'ziehen = Achse',
            gizmo_hint_right     = 'ziehen = Kamera',
            gizmo_hint_wheel     = 'Zoom (SHIFT=FOV)',
            gizmo_hint_save      = 'SPEICHERN',
            gizmo_hint_cancel    = 'abbrechen',
        },

        pos_two_hand       = 'Mit zwei Händen',
        pos_right_hip      = 'Rechte Hüfte',
        pos_left_hip       = 'Linke Hüfte',
        pos_back           = 'Am Rücken',
        pos_left_shoulder  = 'Linke Schulter',
        pos_head_top       = 'Auf dem Kopf',
        pos_waist          = 'An der Taille',

        toy_focus          = 'Fokus: %s',
        toy_dropped        = '%s entfernt (Fokus: %s)',
        all_toys_removed   = 'Alle Spielzeuge entfernt',
        no_focus           = 'Kein Fokus',
        not_active         = 'Nicht aktiv: %s',
        vehicle_attach     = 'Auf FAHRZEUG — MOTORHAUBE (B/N für Knochen)',
        ped_attach         = 'Auf CHARAKTER',
        no_vehicle_nearby  = 'Kein Fahrzeug in der Nähe (5m)',
        gizmo_not_active   = 'Gizmo nicht aktiv',
        vehicle_placed     = 'Am Fahrzeug platziert (nur Sitzung)',
        reset_done         = 'Zurückgesetzt',

        claw_title         = 'GREIFAUTOMAT',
        claw_start         = 'DRÜCKEN ZUM STARTEN',
        claw_busy          = 'GERADE BELEGT',
        claw_pickup        = 'SPIELZEUG NEHMEN',
        claw_busy_notify   = 'Dieser Automat ist gerade belegt.',
        claw_no_cash       = 'Nicht genug Bargeld. Spielpreis: $%s',
        claw_play_hint     = 'Pfeile = Bewegen, ENTER = senken (NUR EINMAL), ESC = verlassen',
        claw_lose          = 'Leer! Versuche es erneut.',
        claw_win_dropped   = '%s ist in die Schale gefallen. Drücke ENTER zum Aufnehmen.',
        claw_in_inv        = '%s zum Inventar hinzugefügt!',
        claw_add_failed    = '%s konnte nicht hinzugefügt werden (Item nicht definiert?)',
        claw_orphan_cleaned= '%d verwaiste Spielzeuge entfernt',

        -- Notify titles (DE)
        notify_title_success = 'ERFOLG',
        notify_title_error   = 'FEHLER',
        notify_title_info    = 'INFO',
        notify_title_warning = 'WARNUNG',
    },

}

-- Aktif dili sec (config.lua sonra yuklenir, default 'tr')
local lang = (Config and Config.Locale) or 'tr'
if not Locales[lang] then lang = 'tr' end

Locale = Locales[lang]

-- _() helper: client/server Lua tarafi
function _(key, ...)
    local s = Locale[key] or key
    if select('#', ...) > 0 then return string.format(s, ...) end
    return s
end

-- NUI'ye gonderilecek UI sub-table'i (menu.lua kullanir)
function GetUILocale()
    return Locale.ui or {}
end