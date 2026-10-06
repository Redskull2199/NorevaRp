-- Bridge Helper Functions
-- Common utility functions for all bridge modules

Bridge = Bridge or {}

-- Wait for framework initialization
function Bridge.EnsureReady()
    if not Bridge.Ready then
        if Bridge.WaitForReady then
            Bridge.WaitForReady()
        else
            -- Fallback if WaitForReady is not yet defined
            while not Bridge.Framework do
                Wait(100)
            end
        end
    end
end
