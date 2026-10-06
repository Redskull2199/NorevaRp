Config = {
    -- Dil: tr | en | de | fr | es | pt | ru | it | nl | pl
    Locale = 'tr',

    ToggleKey = 'V',
    CycleCameraKey = 'F6',
    FilterKey = 'G',
    SavePosKey = 'B',
    SpeedBoostKey = 'LEFTALT', -- basılı tutunca hızlı hareket
    ResetRollKey = 'R', -- roll sıfırla
    HoldDuration = 1,
    MoveSpeed = 0.08,
    BoostMultiplier = 2.4,
    VerticalSpeed = 0.05,
    RotateSpeed = 3.2,
    MaxHorizontalDistance = 8.0,
    MaxVerticalDistance = 4.5,
    CameraFOV = 45.0,
    ZoomSpeed = 1.0,
    MinZoom = 10.0,
    MaxZoom = 90.0,
    QERotateSpeed = 1.5,
    SmoothCam = true,
    SmoothFactor = 0.22,

    Filters = {
        enabled = true,
        current = 'normal',
        strength = 1.0,
        order = {
            'normal', 'bw', 'cinema', 'vintage', 'boost', 'warm', 'cool',
            'drama', 'noir', 'neon', 'fog', 'bleach', 'mute', 'punch'
        },
        -- isimler locales.lua içindeki filter_<key>
        list = {
            normal = { shader = nil },
            bw = { shader = 'NG_filmnoir_BW01' },
            cinema = { shader = 'cinema' },
            vintage = { shader = 'phone_cam6' },
            boost = { shader = 'rply_saturation' },
            warm = { shader = 'phone_cam8' },
            cool = { shader = 'phone_cam3' },
            drama = { shader = 'damage' },
            noir = { shader = 'NG_filmnoir_BW02' },
            neon = { shader = 'NG_filmic01' },
            fog = { shader = 'rply_vignette' },
            bleach = { shader = 'rply_contrast' },
            mute = { shader = 'rply_saturation_neg' },
            punch = { shader = 'spectator5' }
        }
    },

    EmoteProviders = {
        { resource = 'cylex_animmenuv2', exports = { 'getCurrentEmote' } },
        { resource = 'cylex_animmenu', exports = { 'getCurrentEmote' } },
        { resource = 'cylex-animmenu', exports = { 'getCurrentEmote' } },
        { resource = 'cylexemotes', exports = { 'getCurrentEmote' } },
        { resource = 'cylex_anims', exports = { 'getCurrentEmote' } },
        { resource = 'rpemotes', exports = { 'getCurrentEmote' } },
        { resource = 'rpemotes-reborn', exports = { 'getCurrentEmote' } },
        { resource = 'dpemotes', exports = { 'getCurrentEmote' } },
        { resource = 'dpemotes-reborn', exports = { 'getCurrentEmote' } },
        { resource = 'scully_emotemenu', exports = { 'getCurrentEmote', 'getLastEmote' } },
        { resource = 'qb-emotes', exports = { 'getCurrentEmote' } },
        { resource = 'qs-emotes', exports = { 'getCurrentEmote' } },
        { resource = 'anims', exports = { 'getCurrentEmote', 'getEmote' } },
        { resource = 'emotes', exports = { 'getCurrentEmote' } },
        { resource = 'rcore_emotes', exports = { 'getCurrentEmote' } },
        { resource = 'bablo-animations', exports = { 'getCurrentEmote' } },
        { resource = 'okokAnim', exports = { 'getCurrentEmote' } },
        { resource = 'animations', exports = { 'getCurrentEmote' } }
    },

    CommonEmotes = {
        { dict = 'anim@mp_player_intcelebrationmale@salute', name = 'salute', flag = 49, label = 'Salute' },
        { dict = 'anim@mp_player_intcelebrationfemale@wave', name = 'wave', flag = 49, label = 'Wave' },
        { dict = 'amb@world_human_hang_out_street@female_arms_crossed@idle_a', name = 'idle_a', flag = 1, label = 'Arms Crossed' },
        { dict = 'amb@world_human_leaning@male@wall@back@foot_up@idle_a', name = 'idle_a', flag = 1, label = 'Lean' },
        { dict = 'rcmnigel1a', name = 'base', flag = 1, label = 'Idle' },
        { dict = 'anim@heists@heist_corona@single_team', name = 'single_team_loop_boss', flag = 1, label = 'Boss' },
        { dict = 'mini@strip_club@idles@bouncer@base', name = 'base', flag = 1, label = 'Bouncer' },
        { dict = 'amb@world_human_cop_idles@male@base', name = 'base', flag = 1, label = 'Cop Idle' },
        { dict = 'anim@amb@nightclub@peds@', name = 'rcmme_amanda1_stand_loop_cop', flag = 1, label = 'Nightclub' },
        { dict = 'amb@world_human_aa_smoke@male@idle_a', name = 'idle_a', flag = 49, label = 'Smoke' },
        { dict = 'amb@world_human_drinking@coffee@male@idle_a', name = 'idle_a', flag = 49, label = 'Coffee' },
        { dict = 'anim@mp_player_intupperthumbs_up', name = 'idle_a', flag = 49, label = 'Thumbs Up' },
        { dict = 'anim@mp_player_intcelebrationmale@face_palm', name = 'face_palm', flag = 49, label = 'Facepalm' },
        { dict = 'random@arrests@busted', name = 'idle_a', flag = 1, label = 'Busted' },
        { dict = 'missminuteman_1ig_2', name = 'handsup_base', flag = 49, label = 'Hands Up' },
        { dict = 'anim@amb@casino@hangout@ped_male@stand@02b@base', name = 'base', flag = 1, label = 'Casino Stand' },
        { dict = 'timetable@ron@ig_3_couch', name = 'base', flag = 1, label = 'Sit Couch' },
        { dict = 'anim@heists@prison_heiststation@cop_reactions', name = 'cop_a_idle', flag = 1, label = 'Cop React' }
    },

    CinematicMode = {
        enabled = false,
        letterboxSize = 0.12
    },

    Overlay = {
        grid = false,
        hudInfo = true
    },

    SavedPositions = {
        maxSaves = 100,
        saveFile = 'saved_cameras.json'
    },

    UI = {
        theme = 'midnight',
        themes = {
            midnight = {
                background = 'rgba(10, 14, 20, 0.92)',
                text = '#f2f5f8',
                accent = '#3dd6c6',
                border = 'rgba(255, 255, 255, 0.08)'
            },
            slate = {
                background = 'rgba(22, 27, 34, 0.94)',
                text = '#e8eef5',
                accent = '#7eb6ff',
                border = 'rgba(255, 255, 255, 0.1)'
            },
            amber = {
                background = 'rgba(24, 18, 12, 0.94)',
                text = '#fff4e8',
                accent = '#f0a45d',
                border = 'rgba(255, 200, 140, 0.12)'
            },
            mono = {
                background = 'rgba(8, 8, 8, 0.94)',
                text = '#f5f5f5',
                accent = '#ffffff',
                border = 'rgba(255, 255, 255, 0.14)'
            }
        }
    },

    Framework = {
        enabled = true,
        -- Desteklenen frameworkler (name):
        --   'qb'   = QBCore          (qb-core)
        --   'esx'  = ESX Legacy      (es_extended)
        --   'qbox' = Qbox            (qbx_core)  — 'qbx' da yazılabilir
        --   'qbus' = eski QBus/QB    (QBCore:GetObject)
        -- enabled = false -> standalone (license ile kayıt)
        name = 'qb',
        disableInVehicle = true,
        disableWhenDead = true
    },

    Notify = {
        -- 'ox' | 'qb' | 'esx' | 'qbox' | 'qbus'
        type = 'ox'
    }
}
