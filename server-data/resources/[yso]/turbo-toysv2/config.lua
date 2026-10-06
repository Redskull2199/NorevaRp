Config = {}

-- ============================================================
-- KEYBINDS
-- ============================================================
Config.OpenKey         = 38   -- E (menu)
Config.OpenKeyName     = 'E'
Config.GizmoToggleKey  = 167  -- F6 (gizmo on/off)

-- ============================================================
-- CLAW MACHINE ECONOMY
-- ============================================================
-- Amount deducted from player per play (cash).
-- 0 = free (for testing).
Config.PlayCost        = 500

-- Money account: 'cash' (pocket cash) or 'bank'
-- ESX usually 'money'/'cash'/'bank'. QB uses 'cash'/'bank'.
Config.PayAccount      = 'cash'

-- ============================================================
-- INVENTORY INTEGRATION
-- 'ox' or 'qb' (qb-inventory). 'auto' = auto-detect.
-- ============================================================
Config.Inventory = 'ox'

-- ============================================================
-- TOY ITEMS
-- 17 props: turbo1 ... turbo17 (stream/turbo*.ydr)
-- ============================================================

-- Default "two-handed hold" animation - warehouse mech dual-hand carry
-- This anim ONLY plays in the "Two-Handed Hold" position.
-- flag = 50 = AF_HOLD_LAST_FRAME (2) + AF_UPPERBODY (16) + AF_SECONDARY (32)
-- 50 is more STABLE than 49 because it doesn't blend with running. Arms don't lift to head.
local DUAL_HOLD_ANIM = {
    dict = 'impexp_int-0',
    name = 'mp_m_waremech_01_dual-0',
    flag = 50,
    loop = true,
}

Config.Toys = {
    -- Prop field uses turbo1..turbo17 names - these are YTYP archetype names.
    -- YDR filenames (kitty.ydr, etc.) are different but the YTYP archetype's
    -- assetName field points to the correct .ydr.
    -- IMPORTANT: keep prop = 'turbo6', don't use 'kitty' -> "archetype not found" error.

    -- Powerpuff Girls Trio
    ['toy_ppgirls']  = { label = 'Powerpuff Girls (Red)',   prop = 'turbo1',  scale = 1.0, defaultPosition = 1, particle = 'shotburst'  },
    ['toy_ppgirls3'] = { label = 'Powerpuff Girls (Green)', prop = 'turbo2',  scale = 1.0, defaultPosition = 1, particle = 'magic'      },
    ['toy_ppgirls2'] = { label = 'Powerpuff Girls (Blue)',  prop = 'turbo12', scale = 1.0, defaultPosition = 1, particle = 'trail'      },

    -- Madagascar
    ['toy_mort']     = { label = 'Mort',                    prop = 'turbo10', scale = 1.0, defaultPosition = 1, particle = 'glow'       },
    ['toy_private']  = { label = 'Private',                 prop = 'turbo7',  scale = 1.0, defaultPosition = 1, particle = 'sparkle'    },

    -- Despicable Me
    ['toy_minion']   = { label = 'Minion',                  prop = 'turbo9',  scale = 1.0, defaultPosition = 1, particle = 'finale'     },
    ['toy_agnes']    = { label = 'Agnes',                   prop = 'turbo16', scale = 1.0, defaultPosition = 1, particle = 'celebration'},

    -- Pocoyo
    ['toy_pocoyo']   = { label = 'Pocoyo',                  prop = 'turbo15', scale = 1.0, defaultPosition = 1, particle = 'trail'      },

    -- Secret Life of Pets
    ['toy_snowball'] = { label = 'Snowball',                prop = 'turbo17', scale = 1.0, defaultPosition = 1, particle = 'sparkle'    },

    -- Cookie Monster
    ['toy_cookie']   = { label = 'Cookie Monster',          prop = 'turbo3',  scale = 1.0, defaultPosition = 1, particle = 'starburst'  },

    -- Kung Fu Panda
    ['toy_kungfu']   = { label = 'Kung Fu Panda',           prop = 'turbo14', scale = 1.0, defaultPosition = 1, particle = 'fountain'   },

    -- Animal figures
    ['toy_bear']     = { label = 'Bear',                    prop = 'turbo4',  scale = 1.0, defaultPosition = 1, particle = 'glow'       },
    ['toy_bird']     = { label = 'Bird',                    prop = 'turbo5',  scale = 1.0, defaultPosition = 1, particle = 'rainbow'    },
    ['toy_kitty']    = { label = 'Kitty',                   prop = 'turbo6',  scale = 1.0, defaultPosition = 1, particle = 'sparkle'    },
    ['toy_fox']      = { label = 'Fox',                     prop = 'turbo8',  scale = 1.0, defaultPosition = 1, particle = 'launcher'   },
    ['toy_otter']    = { label = 'Otter',                   prop = 'turbo11', scale = 1.0, defaultPosition = 1, particle = 'trail'      },

    -- Generic
    ['toy_girl']     = { label = 'Girl Figure',             prop = 'turbo13', scale = 1.0, defaultPosition = 1, particle = 'glow'       },
}

-- Example: if you want a custom label
-- Config.Toys['turbo_toy_1'].label = 'Pikachu Figure'
-- Config.Toys['turbo_toy_2'].label = 'Goku Figure'

-- ============================================================
-- DEFAULT POSITIONS (built-in)
-- ALL are attached with bone=0 (ped entity root).
-- This way the prop is FIXED to the ped's world pos+heading, unaffected by
-- any bone motion (running/walking/ragdoll/anim). Stays rock solid.
-- Animated positions still play the anim (visually arms reach the prop).
-- Origin: ped's pelvis area, +z = up, +y = forward, +x = right
-- ============================================================
Config.Positions = {
    {
        key   = '1', labelKey = 'pos_two_hand',
        bone  = 57005,                        -- SKEL_R_Hand: 1-to-1 sync with hand
        pos   = vec3(0.16, 0.05, -0.07),     -- electus-toys reference offset
        rot   = vec3(260.0, 50.0, 0.0),      -- warehouse dual-carry pose rotation
        anim  = DUAL_HOLD_ANIM,               -- two-handed hold anim (flag 50 = hold, no spin)
    },
    {
        key   = '2', labelKey = 'pos_right_hip',
        bone  = 0,
        pos   = vec3(0.22, 0.0, -0.10),
        rot   = vec3(0.0, 0.0, 90.0),
    },
    {
        key   = '3', labelKey = 'pos_left_hip',
        bone  = 0,
        pos   = vec3(-0.22, 0.0, -0.10),
        rot   = vec3(0.0, 0.0, -90.0),
    },
    {
        key   = '4', labelKey = 'pos_back',
        bone  = 0,
        pos   = vec3(0.0, -0.20, 0.30),
        rot   = vec3(0.0, 0.0, 180.0),
    },
    {
        key   = '5', labelKey = 'pos_left_shoulder',
        bone  = 0,
        pos   = vec3(-0.18, -0.05, 0.40),
        rot   = vec3(0.0, 0.0, 180.0),
    },
    {
        key   = '6', labelKey = 'pos_head_top',
        bone  = 0,
        pos   = vec3(0.0, 0.0, 0.65),
        rot   = vec3(0.0, 0.0, 0.0),
    },
    {
        key   = '7', labelKey = 'pos_waist',
        bone  = 0,
        pos   = vec3(0.0, 0.18, -0.05),
        rot   = vec3(0.0, 0.0, 0.0),
    },
}

-- ============================================================
-- GIZMO BONE LIST (player cycles through with B/N in gizmo mode)
-- ============================================================
Config.GizmoBones = {
    { id = 0,     name = 'Ped' },
    { id = 24818, name = 'Spine3 (back/chest)' },
    { id = 11816, name = 'Pelvis (waist)' },
    { id = 31086, name = 'Head' },
    { id = 64729, name = 'L_Clavicle (left shoulder)' },
    { id = 10706, name = 'R_Clavicle (right shoulder)' },
    { id = 45509, name = 'L_UpperArm (left bicep)' },
    { id = 40269, name = 'R_UpperArm (right bicep)' },
    { id = 60309, name = 'IK_R_Hand (right hand)' },
    { id = 36029, name = 'IK_L_Hand (left hand)' },
    { id = 23553, name = 'Spine0 (lower back)' },
    { id = 35502, name = 'IK_R_Foot (right foot)' },
    { id = 65245, name = 'IK_L_Foot (left foot)' },
}

-- ============================================================
-- VEHICLE BONE LIST (used in gizmo when placing on a vehicle)
-- In gizmo, press T to switch to vehicle, then B/N to pick a bone.
-- id field is a string: resolved via GetEntityBoneIndexByName
-- (ped bone hashes were numeric, vehicle bones use STRING names).
-- ============================================================
Config.VehicleBones = {
    { id = 'chassis',        name = 'Chassis (body center)' },
    { id = 'bonnet',         name = 'Bonnet (hood)' },
    { id = 'boot',           name = 'Boot (trunk lid)' },
    { id = 'roof',           name = 'Roof' },
    { id = 'roof2',          name = 'Roof2 (mid-top)' },
    { id = 'engine',         name = 'Engine' },
    { id = 'exhaust',        name = 'Exhaust' },
    { id = 'windscreen',     name = 'Windscreen (front)' },
    { id = 'windscreen_r',   name = 'Rear Window' },
    { id = 'door_dside_f',   name = 'Door FL (front-left)' },
    { id = 'door_pside_f',   name = 'Door FR (front-right)' },
    { id = 'door_dside_r',   name = 'Door RL (rear-left)' },
    { id = 'door_pside_r',   name = 'Door RR (rear-right)' },
    { id = 'wheel_lf',       name = 'Wheel FL (front-left rim)' },
    { id = 'wheel_rf',       name = 'Wheel FR (front-right rim)' },
    { id = 'wheel_lr',       name = 'Wheel RL (rear-left rim)' },
    { id = 'wheel_rr',       name = 'Wheel RR (rear-right rim)' },
    { id = 'bumper_f',       name = 'Bumper F (front)' },
    { id = 'bumper_r',       name = 'Bumper R (rear)' },
    { id = 'spoiler',        name = 'Spoiler' },
    { id = 'mirror_dside',   name = 'Mirror L (left)' },
    { id = 'mirror_pside',   name = 'Mirror R (right)' },
    { id = 'seat_dside_f',   name = 'Seat FL (driver front)' },
    { id = 'seat_pside_f',   name = 'Seat FR (passenger front)' },
    { id = 'seat_dside_r',   name = 'Seat RL (rear-left)' },
    { id = 'seat_pside_r',   name = 'Seat RR (rear-right)' },
    { id = 'dashboard',      name = 'Dashboard' },
    { id = 'steeringwheel',  name = 'Steering wheel' },
}

-- ============================================================
-- PARTICLE EFFECTS (glow / shine)
-- Pressing "Emit Light" makes the prop glow + cast real light.
--
-- Each preset:
--   dict, name      = GTA V particle asset
--   scale           = size (0.3-1.0)
--   duration        = ms duration
--   offset          = vec3 (relative to prop center)
--   color (opt)     = particle color {r, g, b} 0-1 range
--   light (opt)     = real light source {r, g, b, range, intensity}
--                     if present, the prop emits light via DrawLightWithRange every frame
-- ============================================================
Config.Particles = {
    -- Classic golden sparkle (default)
    glow = {
        dict='scr_indep_fireworks', name='scr_indep_firework_sparkle_spawn',
        scale=0.5, duration=3500, offset=vec3(0,0,0.05),
        color={r=1.0, g=0.85, b=0.3},
        light={r=255, g=200, b=80, range=1.5, intensity=2.0},
    },
    -- Fireworks fountain (flowing sparkles)
    fountain = {
        dict='scr_indep_fireworks', name='scr_indep_firework_fountain',
        scale=0.7, duration=5000, offset=vec3(0,0,0.0),
        color={r=1.0, g=0.7, b=0.2},
        light={r=255, g=180, b=60, range=2.0, intensity=2.5},
    },
    -- Purple star burst
    starburst = {
        dict='scr_indep_fireworks', name='scr_indep_firework_starburst',
        scale=0.6, duration=2500, offset=vec3(0,0,0.05),
        color={r=0.85, g=0.4, b=1.0},
        light={r=200, g=100, b=255, range=1.8, intensity=2.2},
    },
    -- Red star burst
    shotburst = {
        dict='scr_indep_fireworks', name='scr_indep_firework_shotburst',
        scale=0.6, duration=2200, offset=vec3(0,0,0.05),
        color={r=1.0, g=0.3, b=0.4},
        light={r=255, g=60, b=80, range=1.8, intensity=2.2},
    },
    -- Blue glowing trail
    trail = {
        dict='scr_indep_fireworks', name='scr_indep_firework_trailburst',
        scale=0.6, duration=3500, offset=vec3(0,0,0.05),
        color={r=0.3, g=0.7, b=1.0},
        light={r=80, g=180, b=255, range=1.8, intensity=2.2},
    },
    -- Big air burst (full burst)
    bigboom = {
        dict='scr_indep_fireworks', name='scr_indep_firework_burst_spawn',
        scale=0.8, duration=2000, offset=vec3(0,0,0.1),
        color={r=1.0, g=0.6, b=0.2},
        light={r=255, g=160, b=60, range=2.5, intensity=3.0},
    },
    -- Rainbow burst (multi-color)
    rainbow = {
        dict='scr_indep_fireworks', name='scr_indep_firework_air_burst',
        scale=0.7, duration=2500, offset=vec3(0,0,0.1),
        light={r=255, g=120, b=200, range=2.0, intensity=2.5},
    },
    -- Confetti burst (celebration)
    celebration = {
        dict='scr_xs_celebration', name='scr_xs_confetti_burst',
        scale=0.6, duration=3000, offset=vec3(0,0,0.05),
        light={r=255, g=220, b=120, range=1.5, intensity=2.0},
    },
    -- Golden finale (victory)
    finale = {
        dict='scr_xs_celebration', name='scr_xs_finale_screen',
        scale=0.8, duration=4000, offset=vec3(0,0,0.0),
        color={r=1.0, g=0.85, b=0.3},
        light={r=255, g=210, b=100, range=2.5, intensity=3.5},
    },
    -- Mystic aura (ethereal purple)
    magic = {
        dict='scr_solomon3', name='scr_sol_drone_trail',
        scale=0.7, duration=4500, offset=vec3(0,0,0.05),
        color={r=0.6, g=0.3, b=1.0},
        light={r=160, g=80, b=255, range=2.0, intensity=2.5},
    },
    -- Clown sparkle (classic FiveM)
    sparkle = {
        dict='scr_rcbarry2', name='scr_clown_appears',
        scale=0.5, duration=2500, offset=vec3(0,0,0.05),
        light={r=255, g=255, b=200, range=1.5, intensity=2.0},
    },
    -- Rocket sparkle (firework launcher)
    launcher = {
        dict='scr_indep_fireworks', name='scr_indep_launcher_sparkle_spawn',
        scale=0.5, duration=3500, offset=vec3(0,0,0.0),
        color={r=1.0, g=0.5, b=0.1},
        light={r=255, g=140, b=40, range=1.8, intensity=2.5},
    },
}

Config.UseCooldown = 800
Config.Debug = false

-- ============================================================
-- CLAW MACHINE (crane toy grabber)
-- 3 moving mechanism parts (head + hook + carriage).
-- Forward/back: all 3 on Y axis
-- Left/right:   head + hook on X axis (carriage stays fixed)
-- Down:         hook on Z axis (descends)
-- ============================================================
Config.ClawMachines = {
    -- Each entry is one machine. You can place multiple.
    {
        -- WORLD POSITION (placement in the world)
        position = vec3(-585.6974, -1070.9408, 21.3299),  -- Vespucci beach test spot
        heading  = 0.0214,

        -- ARCHETYPE NAMES (names defined inside the YTYP)
        archetypes = {
            toybox    = 'turbo_toybox',
            mekanizma = 'mekanizma',
            kafa      = 'kafa',
            kanca     = 'kanca',
        },

        -- MECHANISM OFFSETS (LOCAL coordinates relative to toybox center)
        -- You can tune these in-game via /claw_set, /claw_offset, /claw_dump
        mechanism = {
            -- "Park" position — V6 values (original spot)
            home = vec3(0.0, 0.0, 0.175),

            mekanizmaOffset = vec3(0.0, 0.0, 0.00),
            yRange = { -0.30, 0.30 },

            kafaOffset = vec3(0.0, 0.0, 0.00),
            xRange = { -0.30, 0.30 },

            kancaOffset = vec3(0.0, 0.0, -0.05),
            zRange = { 0.0, 0.45 },

            -- tipOffset = offset to the visual "gripper" center of the hook prop
            -- toyHangOffset = makes the toy sit INSIDE the hook (between the fingers)
            -- Toy no longer dangles below the hook, it appears inside the grip area.
            tipOffset = vec3(0.0, 0.0, -0.05),

            toyHangOffset = vec3(0.0, 0.0, 0.02),
        },

        -- Dispenser: hole where the won toy is dropped (front-left section of the mechanism)
        -- x negative = LEFT, y negative = FRONT (toybox opening)
        dispenser = {
            holeCenter = vec3(-0.28, -0.28, 0.85),
            holeRadius = 0.18,
        },

        -- ============ CAMERA ============
        -- Scripted camera activated when entering the machine with E.
        -- Position is in the machine's LOCAL coordinates (rotated by heading):
        --   +x = right, +y = forward (front face), +z = up
        -- As in the screenshot, looks from the glass front into the cabinet.
        camera = {
            offset   = vec3(0.0, -0.75, 1.40),
            lookAt   = vec3(0.0, 0.50, 1.25),
            fov      = 100.0,   -- 55 -> 70 (wider)
            fadeIn   = 0,
            fadeOut  = 0,
        },

        -- DELIVERY TRAY: won toy is placed here (frozen).
        -- Z value matches the test toys (bird/kitty/fox) floor level (0.10)
        tray = {
            localPos      = vec3(0.0, 0.0, 0.45),   -- 0.10 -> 0.45 (raised by 35cm)
            pickupRadius  = 2.0,
        },

        moveSpeedXY = 0.50,
        dropSpeedZ  = 0.80,
        riseSpeedZ  = 1.10,
        interactDistance = 2.5,
        prompt = 'Oyuncak Makinesi — [E] başlat',

        -- ============ WIN MECHANIC ============
        -- Pure RNG: each SPACE press wins with winChance probability.
        -- On win, a random toy from winPool spawns at the hook tip,
        -- mechanism carries it to the dispenser, drops into the tray.
        winChance = 0.40,   -- 0.0 - 1.0 (4/10 = 40%)
        winPool   = nil,    -- nil = use ALL items in Config.Toys
        -- example: winPool = { 'toy_bird', 'toy_kitty', 'toy_fox' }

        -- The "testToys" here are PURELY VISUAL DECORATION — display toys in the cabinet.
        -- These are never touched, the won toy is a fresh spawn.
        testToys = {
            { item = 'toy_bird',  localPos = vec3(-0.18, -0.10, 0.10) },
            { item = 'toy_kitty', localPos = vec3( 0.12,  0.05, 0.10) },
            { item = 'toy_fox',   localPos = vec3(-0.05,  0.18, 0.10) },
        },
    },
}

-- ============================================================
-- SCALE / SIZE ADJUSTMENT (E menu)
-- In-game prop scaling. Since prop collision is off, the player can
-- shrink or enlarge the prop to match their character's size.
-- Each player can save a separate scale per toy (stored in DB).
-- ============================================================
Config.Scale = {
    min      = 0.30,   -- minimum scale (small)
    max      = 1.00,   -- maximum scale (default size — no scaling up beyond this)
    step     = 0.05,   -- slider/button step (5%)
    bigStep  = 0.10,   -- big step (10%) - quick buttons
    default  = 1.00,   -- reset target
}

-- ============================================================
-- SOUND EFFECTS
-- Claw machine and pickup sounds (PICK_UP, CHECKPOINT_*).
-- false = silent (users often find these annoying)
-- true  = vanilla GTA frontend sounds
-- ============================================================
Config.Sounds = false

-- ============================================================
-- LOCALE / LANGUAGE
-- 'tr' = Turkish, 'en' = English, 'de' = German
-- All UI/notification strings are in locales/locales.lua
-- ============================================================
Config.Locale = 'tr'

-- ============================================================
-- NOTIFY SYSTEM
-- Default: CUSTOM NUI notify (top-right slide-in stack, no ox_lib needed).
-- Usage: notify('message', 'success'|'error'|'inform'|'warning')
-- To use your own notify system, edit the function below
-- (QBCore / ESX / okokNotify examples are in the comments).
-- ============================================================
Config.Notify = function(message, ntype)
    -- ntype: 'success' | 'error' | 'inform' | 'warning'
    local t = ntype or 'inform'
    local titles = {
        success = _('notify_title_success'),
        error   = _('notify_title_error'),
        inform  = _('notify_title_info'),
        warning = _('notify_title_warning'),
    }

    -- ===== Default: CUSTOM NUI (top-right, slide-in) =====
    SendNUIMessage({
        action   = 'notify-show',
        message  = tostring(message or ''),
        ntype    = t,
        title    = titles[t],
        duration = 3500,
    })

    -- ===== ox_lib (uncomment if you want to use it like before) =====
    -- if lib and lib.notify then
    --     lib.notify({
    --         title       = 'Turbo Toys',
    --         description = message,
    --         type        = ntype or 'inform',
    --         position    = 'top-right',
    --     })
    --     return
    -- end

    -- ===== QBCore example (remove the ox_lib block above + uncomment): =====
    -- TriggerEvent('QBCore:Notify', message, ntype == 'inform' and 'primary' or ntype, 4000)

    -- ===== ESX example: =====
    -- TriggerEvent('esx:showNotification', message)

    -- ===== okok-notify example: =====
    -- exports['okokNotify']:Alert('TURBO TOYS', message, 4000, ntype or 'info', false)

    -- ===== Fallback: chat =====
    TriggerEvent('chat:addMessage', { color={200,200,200}, args={'[Turbo Toys]', message} })
end

-- ============================================================
-- MENU BACKGROUND IMAGE (optional)
-- ============================================================
Config.MenuBackgroundUrl = 'https://r2.fivemanage.com/ovGl9DE38rLJmHMJDEExO/grsel_2026-05-11_023248698-Photoroom.png'