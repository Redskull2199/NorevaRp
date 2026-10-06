Config.DiscordBotToken = '' -- Discord bot token (For profile picutre)
Config.DefaultProfilePicture = 'https://cdn.discordapp.com/attachments/1187803888271757444/1192875266855419994/Frame_81_3.png?ex=66a91c2a&is=66a7caaa&hm=c48a61f9199cc8d294b525160e8cf5cb53673805a6a7b90df43074513260b4a5&' -- URL | The default profile image to use when Config.DiscordBotToken is empty.
Config.BucketID = 0 -- Default | You don't need to touch here.
Config.PhoneMailOffline = 'qb-phone:server:sendNewEventMail' -- Email event for offline players
Config.DefaultPerms = {
    { -- Dont remove this table.
        name = 'owner', -- Dont touch
        label = 'Owner', -- You can edit this one
        permissions = { -- You can just edit label and description (Check language folder). Dont touch anything else.
            { name = 'administration', label = Language('administration'), description = Language('administration_description'), value = true },
            { name = 'withdrawdeposit', label = Language('withdraw_deposit'), description = Language('withdraw_deposit_description'), value = true },
            { name = 'preorder', label = Language('preorder_perm'), description = Language('preorder_description_perm'), value = true },
            { name = 'discount', label = Language('discount'), description = Language('discount_description_perm'), value = true },
            { name = 'removelog', label = Language('remove_log'), description = Language('remove_log_description'), value = true },
            { name = 'bonus', label = Language('bonus'), description = Language('bonus_description'), value = true },
            { name = 'raise', label = Language('raise'), description = Language('raise_description_perm'), value = true },
            { name = 'fire', label = Language('fire_employees'), description = Language('fire_employees_description'), value = true },
            { name = 'rankchange', label = Language('edit_staff_rank'), description = Language('edit_staff_rank_description'), value = true },
            { name = 'hire', label = Language('hire_staff'), description = Language('hire_staff_description'), value = true },
            { name = 'penalty', label = Language('give_penalty'), description = Language('give_penalty_description'), value = true },
            { name = 'category', label = Language('edit_remove_add_category'), description = Language('edit_remove_add_category_description'), value = true },
            { name = 'buyvehicle', label = Language('buy_vehicle_stock'), description = Language('buy_vehicle_stock_description'), value = true },
            { name = 'editvehicle', label = Language('edit_vehicles'), description = Language('edit_vehicles_description'), value = true },
            { name = 'removefeedback', label = Language('remove_feedbacks'), description = Language('remove_feedbacks_description'), value = true },
            { name = 'removecomplaints', label = Language('remove_complaints'), description = Language('remove_complaints_description'), value = true }
        },
        removable = false,
        editable = false,
    },
}

function SendMailToOfflinePlayer(identifier, sender, subject, message) -- Send mail to offline players function
    TriggerEvent(Config.PhoneMailOffline, identifier, {
        sender = sender,
        subject = subject,
        message = message
    })
end