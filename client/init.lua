-- Builds every zone/blip once all feature modules are loaded
CreateThread(function()
    for rid, restaurant in pairs(Config.Restaurants) do
        for _, setup in ipairs(Features) do
            local ok, err = pcall(setup, rid, restaurant)
            if not ok then
                Shared.warn(('Failed to set up "%s": %s'):format(rid, err))
            end
        end
    end
end)
