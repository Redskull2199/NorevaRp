Config = {}

-- ========================================== --
-- ⚙️ CORE SETTINGS
-- ========================================== --
Config.currentlocale = "tr"            -- Locales type: "tr" or "en"
Config.Inventory     = "ox_inventory"     -- Options: "ox_inventory" | "framework" | "custom"
Config.Perm          = "admin"         -- Admin command permission
Config.Command       = "maddex"     -- Menu command
Config.GetTeamCommand = "getteam"      -- Team teleport command (/getteam bossid) (Admin Only)
Config.GetTeamMemberCommand = "getmember" -- Team Member teleport command (/getmember id) (Team Boss Only)
Config.RefreshTime   = 3000            -- Data Refresh time (ms)

-- ========================================== --
-- 🎮 EVENT SETTINGS
-- ========================================== --
Config.ClearInventory = true   -- Should the player's inventory be cleared upon entry?
Config.WipeData       = true   -- Should kill counts be reset when the event ends?
Config.DeathWait      = 30000  -- Time remaining to be kicked from the event after death (ms)
Config.DamageValue    = 20     -- Amount of damage taken when outside the safe zone
Config.DamageInterval = 2500   -- Damage tick interval when outside the area (ms)

-- ========================================== --
-- 📍 SPAWN & LOCATIONS
-- ========================================== --
Config.JoinCoords = {
    vector3(2444.72, 4261.37, 36.93),
}

-- ========================================== --
-- 🛑 ZONE MECHANICS
-- ========================================== --
Config.DelayBetweenZones = 7   -- Time remaining for area shrinkage (in minutes)
Config.DownSizeAlert     = 1   -- Warning message X minutes before the area shrinks
Config.RadiusDownSize    = 50  -- Area shrinkage speed (Adjust through trial and error)
Config.useScreenText     = true
Config.ScreenText        = "Madde X" -- Text appearing in the bottom right corner

Config.Redzones = {
    ["MaddeX1"] = {
        label      = "Red Zone", 
        Coords     = { ['x'] = 2434.79, ['y'] = 4968.52, ['z'] = 42.35 },
        Radius     = 130.0,
        BlipColour = 1,
    },
    ["MaddeX2"] = {
        label      = "Yellow Zone", 
        Coords     = { ['x'] = 2434.79, ['y'] = 4968.52, ['z'] = 42.35 },
        Radius     = 350.0,
        BlipColour = 5,
    },
    ["MaddeX3"] = {
        label      = "Blue Zone", 
        Coords     = { ['x'] = 2434.79, ['y'] = 4968.52, ['z'] = 42.35 },
        Radius     = 1250.0,
        BlipColour = 3,
    },
}

-- ========================================== --
-- 🎁 REWARD & HOUSE
-- ========================================== --
Config.OpenHouse           = 7     -- Time remaining for the house to open (minutes)
Config.RewardWait          = 7     -- Time remaining for the reward to be generated (minutes)
Config.RewardSpawnWait     = 7     -- Time remaining for the reward preparation (minutes)
Config.RewardCoords        = vector3(2447.77, 4982.97, 46.85) -- Reward marker coordinates
Config.Key                 = 38    -- Key to interact/receive the reward [38 = E]
Config.RewardOwnerDraw     = true  -- Show a crown above the reward owner?
Config.RewardOwnerDistance = 50.0  -- Distance (meters) the crown can be seen by others

-- ========================================== --
-- 🎒 ITEMS & LOADOUT 
-- ========================================== --
Config.Items = {
    [1] = { itemName = "weapon_pistol", amount = 1,  type = "weapon" },
    [2] = { itemName = "heavyarmor",         amount = 15, type = "item" },
    [3] = { itemName = "ammo-9",        amount = 30, type = "item" },
    [4] = { itemName = "bandage",       amount = 30, type = "item" },
    [5] = { itemName = "radio",         amount = 1,  type = "item" },
}

Config.Shops = {
    [1] = { itemName = "weapon_pistol",       itemLabel = "Pistol",       selected = true  },
    -- [2] = { itemName = "weapon_pistol50",     itemLabel = "Deagle",       selected = false },
    -- [3] = { itemName = "weapon_heavypistol",  itemLabel = "Heavy Pistol", selected = false },
}

-- ========================================== --
-- 🔫 WEAPON KILLFEED
-- ========================================== --
-- Match weapon hash to .webp image file name for the kill feed.
Config.WeaponNames = { 
    [tostring(GetHashKey('WEAPON_PISTOL'))]       = 'weapon_pistol', 
    [tostring(GetHashKey('WEAPON_BROWNING'))]     = 'weapon_heavypistol',
    [tostring(GetHashKey('WEAPON_DP9'))]          = 'weapon_pistol',
    [tostring(GetHashKey('WEAPON_GLOCK19GEN4'))]  = 'weapon_pistol',
}

-- ========================================== --
-- 🌐 LOCALES
-- ========================================== --
local Locales = {
    tr = {
        ["eventlocked"]          = "Etkinlik kilitli.",
        ["notstarted"]           = "Etkinlik başlamadı.",
        ["damaged"]              = "Yanlış alanda olduğunuz için hasar yiyorsunuz.",
        ["downalert"]            = Config.DownSizeAlert.." dakika sonra alan daralmaya başlayacaktır ve yeni alana girişler açılacaktır.",
        ["downedalert"]          = "Alan daralmaya başlamıştır ve yeni alana girişler açılmıştır.",
        ["basecommanddesc"]      = "Madde X başlatır/durdurur",
        ["eventopened"]          = "Etkinlik açıldı",
        ["locked"]               = "Etkinlik girişleri kapandı.",
        ["unlocked"]             = "Etkinlik girişleri açıldı.",
        ["started"]              = "Etkinlik başladı",
        ["startalert"]           = "Etkinlik başlamıştır. Mavi alan dışındakiler ve başka bir alanda olanlar hasar yemeye başlayacaktır. Bol Şanslar",
        ["adminmodon"]           = "Admin modu açıldı.",
        ["adminmodoff"]          = "Admin modu kapatıldı.",
        ["closed"]               = "Etkinlik kapatıldı.",
        ["houseopen"]            = Config.OpenHouse.." dakika sonra eve girişler açılacaktır. Eve girişler şu anda KAPALIDIR.",
        ["houseopened"]          = "Eve girişler açılmıştır. Ödül "..Config.RewardWait.. " dakika sonra evin içinde belirecektir.",
        ["rewardspawned"]        = "Ödül evin içinde çıkmıştır.",
        ["rewardtaked"]          = "Ödül başarılı bir şekilde alındı.",
        ["rewardalreadytaked"]   = "Ödül çoktan alındı.",
        ["rewardmsg"]            = "[E] - Maddeyi Kontrol Et",
        ["checkreward"]          = "[E] - Ödülü Kontrol Et",
        ["rewardtakedd"]         = "Ödül Alındı",
        ["takereward"]           = "[E] - Ödülü Al",
        ["annotaked"]            = "Ödül Alınmıştır!",
        ["reamingl"]             = "%d dakika %d saniye",
        ["reamingb"]             = " sonra ödülü alabilirsiniz.",
        ["reamingerror"]         = "Kalan süre hesaplanamıyor.",
        ["rewardowner"]          = "👑",
        ["uidown"]               = "ALAN DARALIYOR",
        ["uinomore"]             = "DAHA ALAN KALMADI",
        ["notspawned"]           = "Oluşturulmadı",
        ["spawned"]              = "Oluşturuldu.",
        ["startno"]              = "BASLAMADI",
        ["minutes"]              = "%d dakika",
        ["seconds"]              = "%d saniye",
        ["rewardui"]             = "Ödülün çıkmasına: ",
        ["lastui"]               = "Etkinlik bitmek ",
        ["lastui2"]              = "üzere",
        ["betweenzone"]          = Config.DelayBetweenZones.." dakika sonra alan daralacaktır.",
        ["finished"]             = "Etkinlik sona erdi.",
        ["uihouseopen"]          = "Evin açılmasına: ",
        ["nopermission"]         = "Yetkiniz yok!",
        ["notenough"]            = "Etkinlikte değilsiniz!",
        ["inventoryopened"]      = "Envanter açıldı.",
        ["inventoryupdated"]     = "Envanter güncellendi.",
        ["weaponrepaired"]       = "Silah tamir edildi.",
        ["weaponnotfound"]       = "Silah bulunamadı.",
        ["weaponselected"]       = "Silah seçildi.",
        ["weaponnotgiven"]       = "Silah verilemedi.",
        ["onlyleaderremove"]     = "Sadece lider üye çıkarabilir!",
        ["onlyleaderinvite"]     = "Sadece lider davet gönderebilir!",
        ["noteam"]               = "Bir takımın yok!",
        ["playernotenough"]      = "Oyuncu etkinlikte değil!",
        ["notsendself"]          = "Kendine davet gönderemezsin!",
        ["invite"]               = "Takıma davet gönderdin!",
        ["joinedteam"]           = "Takıma katıldın!",
        ["removedmember"]        = "Üye çıkarıldı!",
        ["membernotfound"]       = "Üye bulunamadı!",
        ["teamdisbanded"]        = "Takım dağıtıldı!",
        ["leftteam"]             = "Takımdan ayrıldın!",
        ["teamexists"]           = "Zaten bir takımın var!",
        ["teamcreated"]          = "Takım oluşturuldu.",
        ["invalidbossid"]        = "Geçersiz lider ID.",
        ["teambossnotfound"]     = "Takım lideri bulunamadı.",
        ["teamteleported"]       = "Takım üyeleri yanına ışınlandı.",
        ["notenrolled"]          = "Etkinlikte değilsiniz.",
        ["cantChangeWeapon"]     = "Etkinlik başladıktan sonra etkileşim yapamazsınız.",
        ["alreadyInEvent"]       = "Zaten etkinliktesin.",
        ["notInEvent"]           = "Zaten içeride değilsin",
        ["invalidID"]            = "Geçersiz ID!",
        ["invalidLeaderID"]      = "Geçersiz lider ID!",
        ["invalidMemberID"]      = "Geçersiz üye ID!",
        ["notteamboss"]          = "Bu komutu kullanmak için bir takımın patronu olmalısın!",
        ["invalidmemberid"]      = "Geçerli bir oyuncu ID'si girmelisin. Örn: /uyecek 5",
        ["cannotteleportself"]   = "Kendini kendi yanına çekemezsin!",
        ["notinyourteam"]        = "Belirttiğin ID'deki oyuncu senin takımında değil veya aktif değil!",
        ["memberteleported"]     = "Takım üyesi başarıyla yanına çekildi.",
        ["teleportedbyboss"]     = "Takım patronun tarafından yanına çekildin.",
        ["evacik"]     = "EV AÇIK",
        ["evkapali"]     = "EV KAPALI",
        ["odulolus"]     = "ÖDÜL OLUŞUYOR",
        ["odulolustu"]     = "ÖDÜL HAZIRLANIYOR",
        ["odulalindi"]     = "ÖDÜL ALINDI",
    },

    en = {
        ["eventlocked"]          = "Event is locked.",
        ["notstarted"]           = "Event has not started.",
        ["damaged"]              = "You are taking damage because you are in the wrong area.",
        ["downalert"]            = Config.DownSizeAlert.." minutes until the area will start shrinking and new entry points will open.",
        ["downedalert"]          = "The area has started shrinking and new entry points have opened.",
        ["basecommanddesc"]      = "Item X starts/ends",
        ["eventopened"]          = "Event opened",
        ["locked"]               = "Event entries are closed.",
        ["unlocked"]             = "Event entries are open.",
        ["started"]              = "Event started",
        ["startalert"]           = "Event has started. Anyone outside the blue zone or in another area will start taking damage. Good luck!",
        ["adminmodon"]           = "Admin mode has been enabled.",
        ["adminmodoff"]          = "Admin mode has been disabled.",
        ["closed"]               = "Event closed.",
        ["houseopen"]            = Config.OpenHouse.." minutes until the house entry will open. House entry is currently CLOSED.",
        ["houseopened"]          = "House entry has been opened. The reward will appear inside the house after "..Config.RewardWait.." minutes.",
        ["rewardspawned"]        = "The reward has spawned inside the house.",
        ["rewardtaked"]          = "Reward successfully taken.",
        ["rewardalreadytaked"]   = "The reward has already been taken.",
        ["rewardmsg"]            = "[E] - Check the Item",
        ["checkreward"]          = "[E] - Check Reward",
        ["rewardtakedd"]         = "Reward Taken",
        ["takereward"]           = "[E] - Take Reward",
        ["annotaked"]            = "Reward has been taken!",
        ["reamingl"]             = "%d minutes %d seconds",
        ["reamingb"]             = " before you can take the reward.",
        ["reamingerror"]         = "Remaining time cannot be calculated.",
        ["rewardowner"]          = "👑",
        ["uidown"]               = "AREA IS SHRINKING",
        ["uinomore"]             = "NO MORE AREA",
        ["notspawned"]           = "Not spawned",
        ["spawned"]              = "Spawned.",
        ["startno"]              = "NOT STARTED",
        ["minutes"]              = "%d minutes",
        ["seconds"]              = "%d seconds",
        ["rewardui"]             = "Time left for reward to spawn: ",
        ["lastui"]               = "Event is about to end ",
        ["lastui2"]              = "soon",
        ["betweenzone"]          = Config.DelayBetweenZones.." minutes until the area starts shrinking.",
        ["finished"]             = "Event has ended.",
        ["uihouseopen"]          = "The house will open in: ",
        ["nopermission"]         = "You do not have permission!",
        ["notenough"]            = "You are not in the event!",
        ["inventoryopened"]      = "Inventory opened.",
        ["inventoryupdated"]     = "Inventory updated.",
        ["weaponrepaired"]       = "Weapon repaired.",
        ["weaponnotfound"]       = "Weapon not found.",
        ["weaponselected"]       = "Weapon selected.",
        ["weaponnotgiven"]       = "Weapon could not be given.",
        ["onlyleaderremove"]     = "Only the leader can remove a member!",
        ["onlyleaderinvite"]     = "Only the leader can send invites!",
        ["noteam"]               = "You are not in a team!",
        ["playernotenough"]      = "Player is not in the event!",
        ["notsendself"]          = "You cannot invite yourself!",
        ["invite"]               = "Invitation sent!",
        ["joinedteam"]           = "You have joined the team!",
        ["removedmember"]        = "Member removed!",
        ["membernotfound"]       = "Member not found!",
        ["teamdisbanded"]        = "Team has been disbanded!",
        ["leftteam"]             = "You have left the team!",
        ["teamexists"]           = "You already have a team!",
        ["teamcreated"]          = "Team created.",
        ["invalidbossid"]        = "Invalid leader ID.",
        ["teambossnotfound"]     = "Team leader not found.",
        ["teamteleported"]       = "Team members have been teleported to you.",
        ["notenrolled"]          = "You are not in the event!",
        ["cantChangeWeapon"]     = "You cannot interact after the event has started.",
        ["alreadyInEvent"]       = "You are already in the event.",
        ["notInEvent"]           = "You are not in the event.",
        ["invalidID"]            = "Invalid ID!",
        ["invalidLeaderID"]      = "Invalid leader ID!",
        ["invalidMemberID"]      = "Invalid member ID!",
        ["notteamboss"]          = "You must be a team boss to use this command!",
        ["invalidmemberid"]      = "You must enter a valid player ID. e.g., /getmember 5",
        ["cannotteleportself"]   = "You cannot teleport yourself to your own location!",
        ["notinyourteam"]        = "The specified player is not in your team or is offline!",
        ["memberteleported"]     = "Team member successfully teleported to your location.",
        ["teleportedbyboss"]     = "You have been teleported by your team boss.",
        ["evacik"]       = "HOUSE OPEN",
        ["evkapali"]     = "HOUSE CLOSED",
        ["odulolus"]     = "REWARD GENERATING",
        ["odulolustu"]   = "REWARD PREPARING",
        ["odulalindi"]   = "REWARD CLAIMED",
    }
}

Config.Locales = {}

if Locales[Config.currentlocale] then
    for k, v in pairs(Locales[Config.currentlocale]) do
        Config.Locales[k] = v
    end
end

function Translate(key, ...)
    if Config.Locales[key] then
        return string.format(Config.Locales[key], ...)
    else
        return key 
    end
end

function EveryoneAnnounce(message, id)
    if IsDuplicityVersion() then
        TriggerClientEvent("txcl:showAnnouncement", id, message, "Madde X")
    else
        TriggerEvent("txcl:showAnnouncement", message, "Madde X")
    end
end