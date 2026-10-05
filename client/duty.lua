Features[#Features + 1] = function(rid, restaurant)
    local duty = restaurant.duty
    if not duty then return end

    Interact.addZone({
        name = ('sr_%s_duty'):format(rid),
        label = L('duty'),
        coords = duty.coords,
        size = duty.size,
        rotation = duty.rotation,
        options = {
            {
                label = L('clock_in'),
                icon = 'fas fa-clipboard-check',
                rid = rid,
                employee = true,
                canInteract = function() return LocalPlayer.state.restaurantDuty ~= rid end,
                onSelect = function() TriggerServerEvent('silent_restaurant:server:toggleDuty', rid) end,
            },
            {
                label = L('clock_out'),
                icon = 'fas fa-clipboard',
                rid = rid,
                employee = true,
                canInteract = function() return LocalPlayer.state.restaurantDuty == rid end,
                onSelect = function() TriggerServerEvent('silent_restaurant:server:toggleDuty', rid) end,
            },
        },
    })
end
