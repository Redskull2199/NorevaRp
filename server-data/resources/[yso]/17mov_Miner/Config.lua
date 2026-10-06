Config = {}
Config.UseTarget = false
Config.UseBuiltInNotifications = true

Config.RequiredItem = "none"                            -- Set it to anything you want, to require players to have an item in their inventory before they start the job
Config.RequireItemFromWholeTeam = true                  -- If it's false, then only the host needs to have the required item, otherwise entire team needs it.
Config.RequiredJob = "none"                             -- Set to "none" if you dont want to use jobs. If you are using target, you have to set "job" parameter inside every export in target.lua
Config.RequireJobAlsoForFriends = true                  -- If it's false, then only the host needs to have the job, if it's true, then everybody from the group needs to have the Config.RequiredJob
Config.RequireOneFriendMinimum = false                  -- Set to true if you want to force players to create teams
Config.letBossSplitReward = true                        -- If it's true, then boss can manage whole party rewards percent in menu. If set to false, then everybody will get same amount. Avalible only in modern UI
Config.multiplyRewardWhileWorkingInGroup = true         -- If it's false, then reward will stay by default. For example $1000 for completing whole job. If you set it to true, then the payout will depend on how many players is there in the group. For example, if for full job there's $1000, then if player works in a 4 member group, the reward will be $4000. (baseReward * partyCount)
Config.JobCooldown = 0 * 60 -- 10 * 60                  -- 0 minutes cooldown between making jobs (in brackets there's example for 10 minutes)

Config.ProgressBarOffset = "25px"                       -- Value in px of counter offset on screen
Config.ProgressBarAlign = "bottom-center"               -- Align of the progressbar

Config.MainBucket = 0                                   -- A bucket id that you're using for your server.
Config.RequireGear = false                              -- Set to false to allow players enter job without gear
Config.LightToggleButton = 304                          -- By default "H". This is toggling the belt light on miner's gear

Config.SoundVolumeMultipler = 0.5                       -- Here you can change sounds volume multipler
Config.MiningSpeed = {
    ["onBonus"] = 0.05,
    ["normal"] = 0.025,
}

Config.PenaltyAmount = 1000                         -- Penalty when team will not build every objects
Config.OnePercentWorth = 100                        -- A reward per one percent. Fully digged tunnel is 45 meters. Tags for searching: price, reward, money, cash
Config.GiveOnlyOneItemFromTable = false              -- Set to true, if you want to give only one item from Config.ItemsWhileMining per hit. If true, Config.ItemsWhileMining should be sorted from rarest to easiest item
Config.ItemsWhileMining = {                         -- Here you can add some items that player can recive everytime that wall is hitted
    -- {
    --     chance = 1,                           -- Chance to get item. Must be between 0-100 (0 = 0% chance, 1 = 1% chance, 100 = 100% chance etc.)
    --     itemName = "steel",                   -- Name of item
    --     quantity = function(isOnBonus, src)   -- Must be a function
    --         return math.random(1, 5)          -- Must return number. In this case quantity is random from 1 to 5
    --     end,
    -- },
}

Config.RewardItemsToGive = { -- Here you can add items reward as payout for job
    -- {
    --     itemName = "water",         -- Name of item
    --     chance = 100,               -- chance to get item. Must be between 0-100 (0 = 0% chance, 1 = 1% chance, 100 = 100% chance etc.)
    --     amountPerPercent = 1,       -- How much items player will get for each percent of done job
    --     minimumProgressPercent = 0, -- Mininal progress to "got chance" to get item
    -- },
}

Config.Clothes = {
    male = {
        ["mask"] = {clotheId = 0, variation = 0},
        ["arms"] = {clotheId = 44, variation = 0},
        ["pants"] = {clotheId = 38, variation = 1},
        ["bag"] = {clotheId = 0, variation = 0},
        ["shoes"] = {clotheId = 51, variation = 0},
        ["t-shirt"] = {clotheId = 15, variation = 1},
        ["torso"] = {clotheId = 65, variation = 1},
        ["decals"] = {clotheId = 0, variation = 0},
        ["kevlar"] = {clotheId = 0, variation = 0},
    },

    female = {
        ["mask"] = {clotheId = 0, variation = 0},
        ["arms"] = {clotheId = 49, variation = 0},
        ["pants"] = {clotheId = 38, variation = 1},
        ["bag"] = {clotheId = 0, variation = 0},
        ["shoes"] = {clotheId = 25, variation = 0},
        ["t-shirt"] = {clotheId = 15, variation = 1},
        ["torso"] = {clotheId = 59, variation = 1},
        ["decals"] = {clotheId = 0, variation = 0},
        ["kevlar"] = {clotheId = 0, variation = 0},
    },
}

Config.RestrictBlipToRequiredJob = false -- Set to true, to hide job blip for players, who dont have RequiredJob. If requried job is "none", then this option will not have any effect.
Config.Blips = { -- Here you can configure Company blip.
    [1] = {
        Sprite = 124,
        Color = 26,
        Scale = 0.8,
        Pos = vector3(2445.14, 1532.14, 39.89),
        Label = 'Madencilik'
    },
}

Config.Locations = { -- Here u can change all of the base job locations.
    DutyToggle = {
        Coords = {
            vector3(2443.58, 1541.47, 39.89)
        },
        CurrentAction = 'open_dutyToggle',
        CurrentActionMsg = 'Press ~INPUT_CONTEXT~ to ~y~start/finish~s~ work.',
        type = 'duty',
        scale = {x = 1.0, y = 1.0, z = 1.0},
    },
}

Config.ChangeClothesCoordinates = vector3(2424.52, 1544.29, 39.89)
Config.GrabGearCoordinates = vector3(2434.06, 1521.99, 39.89)
Config.DeadCoords = vector3(2428.15, 1531.82, -32.75)

Config.Lang = {
    -- Client
    ["no_permission"] = "Bunu sadece ekip sahibi yapabilir!",
    ["keybind"] = 'Madenci İşaretçisi Etkileşimi',
    ["too_far"] = "Ekibiniz işe başladı ancak merkeze çok uzaksınız",
    ["kicked"] = "%s kişisini ekipten attın",
    ["alreadyWorking"] = "Önce önceki siparişi tamamla",
    ["quit"] = "Ekipten ayrıldın",
    ["nobodyNearby"] = "Yakında kimse yok",
    ["cantInvite"] = "Daha fazla kişi davet edebilmek için önce işi tamamlamalısın",
    ["inviteSent"] = "Davet gönderildi!",
    ["partyIsFull"] = "Davet gönderilemedi, grubunuz dolu",
    ["wrongReward1"] = "Ödeme yüzdesi 0 ile 100 arasında olmalıdır",
    ["wrongReward2"] = "Tüm ödeme yüzdelerinin toplamı %100'ü geçti",
    ["cantLeaveLobby"] = "Çalışırken lobiden ayrılamazsın. Önce işi bitir.",
    ["endJobHint"] = "Çalışmayı ~y~bitirmek ~s~için ~INPUT_CONTEXT~ tuşuna bas.",
    ["openDoors"] = "Kapıları açmak için ~INPUT_CONTEXT~ tuşuna bas",
    ["goDown"] = "Madene inmek için ~INPUT_CONTEXT~ tuşuna bas",
    ["goBack"] = "Geri dönüp işi bitirmek için ~INPUT_CONTEXT~ tuşuna bas",
    ["startMining"] = "~b~[E] |~s~ Madenciliğe Başla",
    ["mouseForMine"] = "Kazmak için ~INPUT_SKIP_CUTSCENE~ basılı tut",
    ["maximum"] = "Tüm tüneli kazdın. Ödemeni almak için asansörle yukarı çık",
    ["firstFinishBuilding"] = "Daha fazla kazmadan önce eksik rayları, destekleri ve ışıkları tamamla",
    ["pickUp"] = "Almak için ~INPUT_CONTEXT~ tuşuna bas",
    ["takeRails"] = "Depoya git ve rayları al",
    ["placeProp"] = "Yerleştirmek için ~INPUT_CONTEXT~ tuşuna bas",
    ["placePropBack"] = "Objeyi geri koymak için ~INPUT_CONTEXT~ tuşuna bas",
    ["minecartBusy"] = "Maden arabası meşgul, boşaltılmasını bekle ve kazmaya devam et.",
    ["startingTutorial"] = "Madenci işine hoş geldin. Görevin -1 seviyesindeki tünelleri kazmak. Çalışmaya başlamadan önce şirket üniformanı giy ve ekipmanlarını al. Bunu Depo ve Soyunma Odası'nda yapabilirsin. Görevdeyken ara kattaki madenci yemek alanını da kullanabilirsin. Hazırlan, asansöre bin ve daha fazla bilgi seni tünellerde bekliyor olacak.",
    ["downTutorial"] = "Madene hoş geldin. Asansörün sağ tarafında, inşaat için gerekli objeleri alacağın bir depo bulunuyor - ama buna sonra değineceğiz. Sana %s tüneli atandı, kazmaya başlamak için oraya git.",
    ["buildingTutorial"] = "Kazdıkça raylar ve destekler inşa etmen gerekecek. İnşa edilmesi gereken objeler işaretlenmiştir. Belirtilen objeyi depodan getirip yerleştir.",
    ["takeFood"] = "~b~[E] |~s~ Yemek Al",
    ["sitChair"] = "~b~[E] |~s~ Otur",
    ["firstBuildPrevious"] = "Önce önceki rayı inşa etmelisin",
    ["wait"] = "Lütfen birkaç saniye bekleyip tekrar dene",
    ["forceExit"] = "Madenden çıkmak için ~INPUT_CONTEXT~ tuşuna bas",
    ["grabGear"] = "~b~[E] |~s~ Ekipmanı Al",
    ["putGear"] = "~b~[E] |~s~ Ekipmanı Bırak",
    ["civClothes"] = "~b~[E] |~s~ Kendi Kıyafetlerin",
    ["workClothes"] = "~b~[E] |~s~ İş Kıyafetleri",
    ["noClothes"] = "Sen veya ekibinden biri gerekli kıyafet ya da ekipmanı giymiyor. Kıyafet olmadan madene giremezsiniz",
    ["gasLeak"] = "Birisi gaz kaçağına neden oldu. Kaçın!",
    ["teammateDown"] = "Takım arkadaşın yaralandı, işi bitirmen gerekiyor",
    ["somebodyNotInElevator"] = "Tüm ekip asansörde değil",
    ["lightToggle"] = "Feneri açıp kapatmak için ~INPUT_REPLAY_HIDEHUD~ tuşuna bas",

    -- Server
    ["isAlreadyHost"] = "Bu oyuncu kendi ekibinin lideri.",
    ["isBusy"] = "Bu oyuncu zaten başka bir ekibe ait.",
    ["hasActiveInvite"] = "Bu oyuncunun zaten aktif bir daveti var.",
    ["HaveActiveInvite"] = "Zaten bir ekibe katılmak için aktif bir davetin var.",
    ["InviteDeclined"] = "Davetin reddedildi.",
    ["InviteAccepted"] = "Davetin kabul edildi!",
    ["error"] = "Ekibe katılırken bir sorun oluştu. Lütfen daha sonra tekrar dene.",
    ["kickedOut"] = "Ekipten atıldın!",
    ["reward"] = "Ödeme aldın: $",
    ["RequireOneFriend"] = "Bu iş için en az bir ekip arkadaşı gerekiyor",
    ["dontHaveReqItem"] = "Senin veya takım arkadaşlarından birinin işe başlamak için gerekli eşyası yok",
    ["notEverybodyHasRequiredJob"] = "Arkadaşlarının hepsinde gerekli meslek yok",
    ["someoneIsOnCooldown"] = "%s şu anda işe başlayamaz (bekleme süresi: %s)",
    ["hours"] = "s",
    ["minutes"] = "d",
    ["seconds"] = "sn",
    ["newBoss"] = "Önceki ekip lideri sunucudan ayrıldı. Artık takım lideri sensin",
    ["penalty"] = "Şu miktarda ceza ödedin: ",
    ["clientsPenalty"] = "Takım lideri cezayı kabul etti",
    ["alreadyStarted"] = "Zaten işe başladın!",
    ["jobDone"] = "Tüm tüneli kazdın, artık daha fazla kazamazsın!",

    -- NUI
    ["NUI_progress"] = "İlerleme: %s%",
    ["NUI_signatureTitle"] = "MADENCİ İŞİ",
    ["NUI_signatureTitlePlaceholder"] = "MADENCİ İŞİ",
    ["NUI_tutorial"] = "Eğitim",
    ["NUI_notification"] = "Bildirim",
    ["NUI_invitation"] = "Davet",
    ["NUI_warning"] = "Uyarı",
    ["NUI_bossName"] = "Lider Adı",
    ["NUI_memberName"] = "Üye Adı",
    ["NUI_kickPlayerNotify"] = "Takım sahibi ekipten ayrılamaz!",
    ["NUI_startJobNotify"] = "Sadece ekip sahibi işi başlatabilir!",
    ["NUI_minerLobby"] = "MADENCİ LOBİSİ",
}

Config.MiningHintColor = {r = 57, g = 151, b = 201, a = 0.8}
Config.MarkerSettings = { -- used only when Config.UseTarget = false. Colors of the marker. Active = when player stands inside the marker.
    Active = {
        r = 91,
        g = 168,
        b = 255,
        a = 201,
    },
    UnActive = {
        r = 57,
        g = 151,
        b = 201,
        a = 150,
    }
}

Config.Restaurant = {
    enable = false,
    coordinates = vector3(2436.07, 1545.88, 44.02),
    tray = {
        model =  `prop_cs_silver_tray`,
        burgerModel = `prop_cs_burger_01`,
        burgerOffset = vec3(0.08, 0.0, 0.04),
        waterModel = `prop_ld_flow_bottle`,
        waterOffset = vec3(-0.08, 0.0, 0.12),
        wearingAnim = {
            dict = "anim@heists@box_carry@",
            name = "idle",
            trayOffset = vec3(0.0, -0.20, -0.16),
            trayRotation = vec3(0.0, 0.0, 0.0),
        }
    },
    restoreStatus = function()
        TriggerEvent("esx_status:add", "thirst", 100000)
        TriggerEvent("esx_status:add", "hunger", 200000)

        TriggerServerEvent("consumables:server:addHunger", 100)
        TriggerServerEvent("consumables:server:addThirst", 100)
        -- Your status restore export goes here
    end,
    objects = {
        {
            coordinates = vector3(2439.63525, 1545.90576, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 55.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2440.98535, 1544.95154, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -120.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2438.169, 1541.80579, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 80.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2439.69385, 1541.83984, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -80.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2442.12866, 1543.06384, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 90.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2443.65356, 1543.18054, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -95.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2443.87866, 1545.678, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 120.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2445.24585, 1546.45117, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -55.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2446.25757, 1542.6947, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 160.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2446.9895, 1544.03223, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -20.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2447.293, 1545.19116, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 130.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2448.63013, 1546.332, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -40.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2451.05347, 1545.14282, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 130.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2452.199, 1546.14929, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -40.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2449.27637, 1542.77747, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 65.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2450.802, 1542.222, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -110.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2453.70044, 1542.035, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 175.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2453.79858, 1543.69836, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 5.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2453.77173, 1542.84778, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2451.57837, 1545.54578, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2448.06934, 1545.79382, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2450.08325, 1542.439, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2446.606, 1543.36792, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2444.4126, 1546.06592, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },


        {
            coordinates = vector3(2442.787, 1543.07214, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },


        {
            coordinates = vector3(2440.252, 1545.38684, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2438.85034, 1541.82532, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },
    }
}

Config.WallModel = `17mov_mining_wall`

Config.MinecartModel = `17mov_cart`
Config.MinecartOffset = vector3(0.0, 0.0, 0.7)
Config.MinecartForwardOffset = -1.5

Config.RockModel = `17mov_stones_txt`
Config.RockInMinecaftMinOffset = vector3(0.0, 0.0, -0.03)
Config.RockInMinecaftMaxOffset = vector3(0.0, 0.0, 0.24)
Config.RockInMinecaftRotation = vector3(0.0, 0.0, 0.0)

Config.Props = {
    ["Rails"] = {
        model = `17mov_rail`,
        stackCoords = vector3(2416.326, 1551.32751, -33.52552),
        stackRotation = vector3(0.0, 0.0, 0.0),
        stackOffest = vector3(0.0, 0.0, 0.3),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.2, -0.26, 0.03),
            rotation = vector3(-17.0, -27.0, 96.0),
        }
    },
    ["Lights"] = {
        model = `17mov_minelight_25_off`,
        stackCoordinates = {
            vec3(2417.17822, 1546.30322, -33.50039),
            vec3(2417.17822, 1545.75916, -33.50039),
            vec3(2416.61353, 1546.30322, -33.50039),
            vec3(2416.61353, 1545.75916, -33.50039),
            vec3(2415.824, 1546.30322, -33.50039),
            vec3(2415.824, 1545.75916, -33.50039),
            vec3(2415.824, 1545.25732, -33.50039),
            vec3(2416.61353, 1545.25732, -33.50039),
            vec3(2417.17822, 1545.25732, -33.50039),
        },
        stackRotation = vector3(0.0, -180.0, 13.5),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.08, -0.2),
            rotation = vector3(0.0, 180.0, 0.0),
        }
    },
    ["SupportPillarLeft"] = {
        model = `17mov_miner_wbar1`,
        offset = vector3(0.0, -2.5, 0.0),
        rotation = vector3(0.0, 0.0, 0.0),
        stackCoordinates = {
            vec3(2430.61, 1546.913, -33.346508),
            vec3(2430.22559, 1546.913, -33.346508),
            vec3(2429.84863, 1546.913, -33.346508),
            vec3(2429.464, 1546.913, -33.346508),
            vec3(2430.4126, 1546.913, -32.9867134),
            vec3(2430.028, 1546.913, -32.9867134),
            vec3(2429.65112, 1546.913, -32.9867134),
        },
        stackRotation = vector3(90.0, 0.0, 0.0),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 90.0, 0.0),
        }
    },
    ["SupportPillarRight"] = {
        model = `17mov_miner_wbar1`,
        offset = vector3(0.0, 2.5, 0.0),
        rotation = vector3(0.0, 0.0, 0.0),
        stackCoordinates = {
            vec3(2430.61, 1550.97986, -33.346508),
            vec3(2430.22559, 1550.97986, -33.346508),
            vec3(2429.84863, 1550.97986, -33.346508),
            vec3(2429.464, 1550.97986, -33.346508),
            vec3(2430.4126, 1550.97986, -32.9867134),
            vec3(2430.028, 1550.97986, -32.9867134),
            vec3(2429.65112, 1550.97986, -32.9867134),
        },
        stackRotation = vector3(90.0, 0.0, 0.0),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 90.0, 0.0),
        }
    },
    ["SupportConnectorLeft"] = {
        model = `17mov_miner_wbar2`,
        offset = vector3(0.0, -1.675, 1.9),
        rotation = vector3(0.0, 0.0, 0.0),
        stackCoordinates = {
            vec3(2430.01782, 1555.77649, -33.3409729),
            vec3(2430.01782, 1555.41284, -33.3409729),
            vec3(2430.01782, 1555.77649, -32.96839),
            vec3(2430.01782, 1555.41284, -32.96839),
            vec3(2430.01782, 1555.77649, -32.5947571),
            vec3(2430.01782, 1555.41284, -32.5947571),
            vec3(2430.01782, 1555.61084, -32.2259521),
        },
        stackRotation = vector3(-45.0, 0.0, 90.0),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 90.0, -50.0),
        }
    },
    ["SupportConnectorRight"] = {
        model = `17mov_miner_wbar2`,
        offset = vector3(0.0, -1.675, 1.9),
        rotation = vector3(0.0, 0.0, 180.0),
        stackCoordinates = {
            vec3(2430.01782, 1554.95837, -33.3409729),
            vec3(2430.01782, 1554.59473, -33.3409729),
            vec3(2430.01782, 1554.95837, -32.96839),
            vec3(2430.01782, 1554.59473, -32.96839),
            vec3(2430.01782, 1554.95837, -32.5947571),
            vec3(2430.01782, 1554.59473, -32.5947571),
            vec3(2430.01782, 1554.79272, -32.2259521),
        },
        stackRotation = vector3(-45.0, 0.0, 90.0),
        interactionDistance = 3.0,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 90.0, -50.0),
        }
    },
    ["SupportLintel"] = {
        model = `17mov_miner_wbar3`,
        offset = vector3(0.0, 0.0, 2.7),
        rotation = vector3(0.0, 0.0, 0.0),
        stackCoordinates = {
            vec3(2425.8335, 1557.04675, -33.3713531),
            vec3(2425.8335, 1556.68274, -33.3713531),
            vec3(2425.8335, 1556.319, -33.3713531),
            vec3(2425.8335, 1555.955, -33.3713531),
            vec3(2425.8335, 1556.86951, -33.0083427),
            vec3(2425.8335, 1556.50574, -33.0083427),
            vec3(2425.8335, 1556.14172, -33.0083427),
        },
        stackRotation = vector3(0.0, 0.0, -90.0),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 0.0, 90.0),
        }
    },
}

-- Here you can configure accidential events triggered when someone is mining
Config.Events = {
    ["gas"] = {
        chance = 0.05,               -- chance to trigger event (can be triggered every hit). Must be between 0-100
        duration = 30 * 1000,        -- How long the event lasts (in ms)
        minimumProgressPercent = 15, -- Minimal percent of job to event can be triggered
        healthLossValue = 2,         -- Value of lossen health
        healthLossInterval = 1000,   -- In ms (every 1s)
    },
    ["blackout"] = {
        chance = 0.2,                -- chance to trigger event (can be triggered every hit). Must be between 0-100
        minimumProgressPercent = 15, -- Minimal percent of job to event can be triggered
        minDuration = 10000,         -- Minimum duration of event (in ms)
        maxDuration = 100000,        -- maximum duration of event (in ms)
    }
}

Config.Mineshatfs = {
    [1] = {
        wallCoordinates = vector3(2410.50122, 1516.50427, -31.17),
        wallRotation = vector3(0.0, 0.0, 180.0),

        railsStart = vector3(2409.26147, 1520.744, -33.75),
        railsRotation = vector3(0.0, 0.0, 0.0),
        railsQuantity = 10,

        supportsStart = vector3(2410.51172, 1512.74426, -32.25),
        supportsRotation = vector3(0.0, 0.0, 90.0),
        supportsQuantity = 7,

        lightsStart = vector3(2410.51172, 1512.74426, -29.7),
        lightsRotation = vector3(0.0, 0.0, 180.0),
        lightsQuantity = 7,
        forwardVector = vector3(0.0, -1.0, 0.0)
    },
    [2] = {
        wallCoordinates = vector3(2402.52832, 1516.50427, -31.17),
        wallRotation = vector3(0.0, 0.0, 180.0),

        railsStart = vector3(2401.28857, 1520.744, -33.75),
        railsRotation = vector3(0.0, 0.0, 0.0),
        railsQuantity = 10,

        supportsStart = vector3(2402.53882, 1512.74426, -32.25),
        supportsRotation = vector3(0.0, 0.0, 90.0),
        supportsQuantity = 7,

        lightsStart = vector3(2402.53882, 1512.74426, -29.7),
        lightsRotation = vector3(0.0, 0.0, 180.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, -1, 0)
    },
    [3] = {
        wallCoordinates = vector3(2394.53149, 1516.50427, -31.17),
        wallRotation = vector3(0.0, 0.0, 180.0),

        railsStart = vector3(2393.29175, 1520.744, -33.75),
        railsRotation = vector3(0.0, 0.0, 0.0),
        railsQuantity = 10,

        supportsStart = vector3(2394.542, 1512.74426, -32.25),
        supportsRotation = vector3(0.0, 0.0, 90.0),
        supportsQuantity = 7,

        lightsStart = vector3(2394.542, 1512.74426, -29.7),
        lightsRotation = vector3(0.0, 0.0, 180.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, -1, 0)
    },
    [4] = {
        wallCoordinates = vector3(2381.89, 1528.1, -31.17),
        wallRotation = vector3(0.0, 0.0, 90.0),

        railsStart = vector3(2386.13, 1529.34, -33.75),
        railsRotation = vector3(0.0, 0.0, -90.0),
        railsQuantity = 10,

        supportsStart = vector3(2378.13, 1528.09, -32.25),
        supportsRotation = vector3(0.0, 0.0, 0.0),
        supportsQuantity = 7,

        lightsStart = vector3(2378.13, 1528.09, -29.7),
        lightsRotation = vector3(0.0, 0.0, 90.0),
        lightsQuantity = 7,
        forwardVector = vec3(-1, 0, 0)
    },
    [5] = {
        wallCoordinates = vector3(2381.89, 1535.51709, -31.17),
        wallRotation = vector3(0.0, 0.0, 90.0),

        railsStart = vector3(2386.13, 1536.75708, -33.75),
        railsRotation = vector3(0.0, 0.0, -90.0),
        railsQuantity = 10,

        supportsStart = vector3(2378.13, 1535.50708, -32.25),
        supportsRotation = vector3(0.0, 0.0, 0.0),
        supportsQuantity = 7,

        lightsStart = vector3(2378.13, 1535.50708, -29.7),
        lightsRotation = vector3(0.0, 0.0, 90.0),
        lightsQuantity = 7,
        forwardVector = vec3(-1, 0, 0)
    },
    [6] = {
        wallCoordinates = vector3(2394.59717, 1547.2489, -31.17),
        wallRotation = vector3(0.0, 0.0, 0.0),

        railsStart = vector3(2395.83667, 1543.00854, -33.75),
        railsRotation = vector3(0.0, 0.0, 180.0),
        railsQuantity = 10,

        supportsStart = vector3(2394.5874, 1551.00854, -32.25),
        supportsRotation = vector3(0.0, 0.0, 270.0),
        supportsQuantity = 7,

        lightsStart = vector3(2394.5874, 1551.00854, -29.7),
        lightsRotation = vector3(0.0, 0.0, 0.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, 1, 0)
    },
    [7] = {
        wallCoordinates = vector3(2402.58252, 1547.2489, -31.17),
        wallRotation = vector3(0.0, 0.0, 0.0),

        railsStart = vector3(2403.822, 1543.00854, -33.75),
        railsRotation = vector3(0.0, 0.0, 180.0),
        railsQuantity = 10,

        supportsStart = vector3(2402.57275, 1551.00854, -32.25),
        supportsRotation = vector3(0.0, 0.0, 270.0),
        supportsQuantity = 7,

        lightsStart = vector3(2402.57275, 1551.00854, -29.7),
        lightsRotation = vector3(0.0, 0.0, 0.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, 1, 0)
    },
    [8] = {
        wallCoordinates = vector3(2410.461, 1547.2489, -31.17),
        wallRotation = vector3(0.0, 0.0, 0.0),

        railsStart = vector3(2411.70044, 1543.00854, -33.75),
        railsRotation = vector3(0.0, 0.0, 180.0),
        railsQuantity = 10,

        supportsStart = vector3(2410.45117, 1551.00854, -32.25),
        supportsRotation = vector3(0.0, 0.0, 270.0),
        supportsQuantity = 7,

        lightsStart = vector3(2410.45117, 1551.00854, -29.7),
        lightsRotation = vector3(0.0, 0.0, 0.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, 1, 0)
    },
}