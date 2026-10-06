Config = {}

Config.OpenKey = 'F3'

Config.MenuItems = {
    {
        id = 'citizen',
        title = 'Citizen',
        icon = 'user',
        items = {
            {
                id = 'givenum',
                title = 'Give Contact Details',
                icon = 'address-book',
                type = 'client',
                event = 'qb-phone:client:GiveContactDetails',
                shouldClose = true
            },
            {
                id = 'getintrunk',
                title = 'Get in Trunk',
                icon = 'car',
                type = 'client',
                event = 'qb-trunk:client:GetIn',
                shouldClose = true
            },
            {
                id = 'cornerselling',
                title = 'Corner Selling',
                icon = 'cannabis',
                type = 'client',
                event = 'qb-drugs:client:cornerselling',
                shouldClose = true
            }
        }
    },
    {
        id = 'clothing',
        title = 'Clothing',
        icon = 'shirt',
        items = {
            {
                id = 'top',
                title = 'Take Off/Put On Shirt',
                icon = 'shirt',
                type = 'client',
                event = 'clothing:toggleTop',
                shouldClose = true
            },
            {
                id = 'pants',
                title = 'Take Off/Put On Pants',
                icon = 'vest',
                type = 'client',
                event = 'clothing:togglePants',
                shouldClose = true
            },
            {
                id = 'shoes',
                title = 'Take Off/Put On Shoes',
                icon = 'vest',
                type = 'client',
                event = 'clothing:toggleShoes',
                shouldClose = true
            },
            {
                id = 'hat',
                title = 'Take Off/Put On Hat',
                icon = 'hat',
                type = 'client',
                event = 'clothing:toggleHat',
                shouldClose = true
            },
            {
                id = 'glasses',
                title = 'Take Off/Put On Glasses',
                icon = 'glasses',
                type = 'client',
                event = 'clothing:toggleGlasses',
                shouldClose = true
            },
            {
                id = 'mask',
                title = 'Take Off/Put On Mask',
                icon = 'mask',
                type = 'client',
                event = 'clothing:toggleMask',
                shouldClose = true
            }
        }
    },
    {
        id = 'vehicle',
        title = 'Vehicle',
        icon = 'car',
        items = {
            {
                id = 'engine',
                title = 'Toggle Engine',
                icon = 'engine',
                type = 'client',
                event = 'vehicle:toggleEngine',
                shouldClose = true
            },
            {
                id = 'doors',
                title = 'Toggle Doors',
                icon = 'door-open',
                type = 'client',
                event = 'vehicle:toggleDoors',
                shouldClose = true
            },
            {
                id = 'trunk',
                title = 'Open Trunk',
                icon = 'box-open',
                type = 'client',
                event = 'vehicle:toggleTrunk',
                shouldClose = true
            }
        }
    },
    {
        id = 'animations',
        title = 'Animations',
        icon = 'running',
        items = {
            {
                id = 'dance',
                title = 'Dance',
                icon = 'music',
                type = 'client',
                event = 'anim:dance',
                shouldClose = true
            },
            {
                id = 'sit',
                title = 'Sit Down',
                icon = 'chair',
                type = 'client',
                event = 'anim:sit',
                shouldClose = true
            }
        }
    },
    {
        id = 'inventory',
        title = 'Inventory',
        icon = 'backpack',
        type = 'client',
        event = 'inventory:open',
        shouldClose = true
    }
}
