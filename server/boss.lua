RegisterNetEvent('silent_restaurant:server:announce', function(rid, isOpen)
    local src = source
    local restaurant = Config.Restaurants[rid]
    if not restaurant or not restaurant.boss then return end

    local xPlayer = Server.getEmployee(src, rid, { minGrade = restaurant.boss.minGrade, coords = restaurant.boss.coords })
    if not xPlayer then return end

    if Server.cooldown(('announce:%s'):format(rid), Config.Announce.cooldown) then
        return Server.notify(src, L('announce_cooldown'), 'error')
    end

    TriggerClientEvent('ox_lib:notify', -1, {
        title = restaurant.label,
        description = isOpen and L('announce_open', restaurant.label) or L('announce_closed', restaurant.label),
        type = isOpen and 'success' or 'error',
        icon = 'utensils',
        duration = 10000,
    })
end)
