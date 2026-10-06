-- {"xp":0,"LspdActivePersonel":0,"PhoneCheck":0,"PhonefromName":0,"CctvCamera":0,"AnonimTweet":0,"CarLock":0,"LocationCheck":0,"BankHack":0,"SendAllDM":0}
RegisterCommand("opentablet", function (s)
    src = s
    check = CheckPlayer(s)
    TriggerClientEvent("BakiTelli_hackermenu:OpenMenu", src, check)
end)

AddEventHandler("BakiTelli_hackermenu:ClickMain")
RegisterNetEvent("BakiTelli_hackermenu:ClickMain", function (id)
    src = source
    local zrt = getplayer()
    local xPlayer = zrt(src)	
    identifier = getidentifier(xPlayer)
    check = CheckPlayer(source)
    decoded = json.decode(check)
    lvlc = calculateLevel(decoded["xp"])
    lvlm = Config.HackerMenu[id].level
    idm = tonumber(decoded[id])
    lvlw = Config.HackerMenu[id].waiter
    lvls = Config.HackerMenu[id].addXP
    moneym = Config.HackerMenu[id].price
    moneyc = getMoney(src)
    if lvlc >= lvlm then 
        if moneym <= moneyc then
            if idm == 0 then
            -- if true then
                removeMoney(src, moneym)
                updateMy(identifier, lvlw, lvls, id, decoded)
                sendToDiscord(Config.Webhook, src, "Hacking Start! ", "\n" .. GetPlayerName(src) .. "(" .. src .. ") \n\nHack : **" .. Config.HackerMenu[id].label .. "**\n\n Current Level: **" .. lvlc.. "**", 15158332)
                TriggerClientEvent("BakiTelli_hackermenu:StartHack", src, id)
            else
                local currentTime = os.time()
                if currentTime < idm then
                    TriggerClientEvent("BakiTelli_hackermenu:Notification", src, "error", Config.Langs["TimeError"])
                else
                    removeMoney(src, moneym)
                    updateMy(identifier, lvlw, lvls, id, decoded)
                    sendToDiscord(Config.Webhook, src, "Hacking Start! ", "\n" .. GetPlayerName(src) .. "(" .. src .. ") \n\nHack : **" .. Config.HackerMenu[id].label .. "**\n\n Current Level: **" .. lvlc.. "**", 15158332)
                    TriggerClientEvent("BakiTelli_hackermenu:StartHack", src, id)
                end
            end
        else
            TriggerClientEvent("BakiTelli_hackermenu:Notification", src, "error", Config.Langs["MoneyError"])
        end
    else
        TriggerClientEvent("BakiTelli_hackermenu:Notification", src, "error", Config.Langs["LevelError"])
    end
end)

AddEventHandler("BakiTelli_hackermenu:getData")
RegisterNetEvent("BakiTelli_hackermenu:getData", function (id)
    src = source
    if id == "LspdActivePersonel" then 
        rtrn = Config.Langs["ActivePolice"] .." ".. totalPolice() 
        TriggerClientEvent("BakiTelli_hackermenu:cl:getData",src ,"text" , rtrn)
    elseif id == "PhoneCheck" or id == "PhonefromName" or id == "CctvCamera" or id == "LocationCheck" then 
        TriggerClientEvent("BakiTelli_hackermenu:cl:getData",src ,"table")
    elseif id == "AnonimTweet" or id == "SendAllDM" then 
        TriggerClientEvent("BakiTelli_hackermenu:cl:getData",src ,"entertext")
    elseif id == "BankHack" then
        money = math.random(Config.HackerMenu.BankHack.giveMoney.min, Config.HackerMenu.BankHack.giveMoney.max)
        addmoney(src, money)
        rtrn = Config.Langs["BankHack"].." $" ..money
        TriggerClientEvent("BakiTelli_hackermenu:cl:getData",src ,"text" , rtrn)
    end
end)

AddEventHandler("BakiTelli_hackermenu:getUsers")
RegisterNetEvent("BakiTelli_hackermenu:getUsers", function (text, id)
    src = source
    if id == "LocationCheck" then
        TriggerClientEvent("BakiTelli_hackermenu:cl:getUsers",src , SearchNumber(tonumber(text)))
    else     
        TriggerClientEvent("BakiTelli_hackermenu:cl:getUsers",src , SearchPlayer(text))
    end
end)


function calculateLevel(experience)
    local level = math.floor(tonumber(experience) / 100)
    return level
end

function StartHack(src, id)
    if id == "LspdActivePersonel" then
        TriggerClientEvent("BakiTelli_hackermenu:StartHack", src, id)
    end
end

 function GenerateTweetId()
    local tweetId = "TWEET-"..math.random(11111111, 99999999)
    return tweetId
end

function sendToDiscord(DiscordLog, source, title, des, color)
        local debuxIMG = "https://cdn.discordapp.com/attachments/994272883918512158/994272896862134362/unknown.png"
        local log = {
            {
                ["title"] = "DEBUX HACKER MENU",
                ["color"] = color,
                author = {
                    name = "DebuX WeaponShop",
                    icon_url = "https://cdn.discordapp.com/attachments/994272883918512158/994272896862134362/unknown.png",
                    url = "https://discord.gg/debux"
                },
                ["fields"] = {
                    {
                        ["name"] = "> Info:",
                        ["value"] = title,
                        ["inline"] = false
                    },
                    {
                        ["name"] = "> Version:",
                        ["value"] = "1.0",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "> Detail:",
                        ["value"] = des,
                        ["inline"] = false
                    },
                    {
                        ["name"] = "> Website:",
                        ["value"] = 'https://debux.tebex.io',
                        ["inline"] = true
                    },
                    {
                        ["name"] = "> Support:",
                        ["value"] = 'https://discord.gg/debux',
                        ["inline"] = true
                    },
                },
                ["thumbnail"] = {
                    ["url"] = "https://cdn.discordapp.com/attachments/994272883918512158/994273062126092450/unknown.png"
                },
            },
        }
        Citizen.Wait(tonumber(1000))
        PerformHttpRequest(DiscordLog, function(err, text, headers) end, 'POST', json.encode({ username = "DebuX WorkShop", embeds = log, avatar_url = debuxIMG }), { ['Content-Type'] = 'application/json' })
end

