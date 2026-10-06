PulseV = PulseV or {}
PulseV.Config = {
    Command = 'blipcreator', Permissions = {'admin', 'superadmin', 'god'}, Debug = false,
    -- Any listed QBCore role OR ACE grants access; every server action rechecks it.
    -- command.blipcreator honors existing group.admin command grants without /admin.
    AcePermissions = {'command.blipcreator', 'pulsev.blipcreator'},
    Defaults = {note='', sprite=280, color=3, scale=0.80, alpha=255, display=2,
        short_range=true, rotation=0, category='Genel', map_category=2, enabled=true},
    Limits = {
        name={minChars=1,maxChars=64,maxBytes=256}, note={minChars=0,maxChars=512,maxBytes=2048},
        category={minChars=1,maxChars=48,maxBytes=192}, scale={min=0.10,max=2.00},
        x={min=-20000,max=20000}, y={min=-20000,max=20000}, z={min=-2000,max=4000},
    },
    MaxBlips=500, RequestTimeout=10000, PreviewDebounce=200, TeleportTimeout=5000,
    ListPageSize=25, SpritePageSize=72, QueueCapacity=64, MaxPendingPerPlayer=4,
    SnapshotBuffer=512, SnapshotBandwidth=100000, StartupRetryInterval=1000, StartupRetryCount=3,
    ResultCache={ttl=60000,capacity=64},
    RateLimits={snapshot={capacity=2,window=5000},reads={capacity=5,window=5000},
        mutations={capacity=5,window=5000},teleport={capacity=1,window=5000}},
    Notification={adapter='qbcore',customEvent=nil},
}
