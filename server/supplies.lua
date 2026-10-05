local ox_inventory = exports.ox_inventory

RegisterNetEvent('silent_restaurant:server:buySupplies', function(rid, cart)
    local src = source
    local restaurant = Config.Restaurants[rid]
    local supplies = restaurant and restaurant.supplies
    if not supplies or type(cart) ~= 'table' then return end

    local xPlayer = Server.getEmployee(src, rid, { duty = true, minGrade = supplies.minGrade, coords = supplies.coords })
    if not xPlayer then return end

    -- Rebuild the cart from the config
    local items, total, weight = {}, 0, 0
    for item, count in pairs(cart) do
        local price = type(item) == 'string' and Shared.supplyPrice(restaurant, item)
        count = Server.toInt(count, 1, Config.Supplies.maxQuantity)

        if price and count then
            local data = ox_inventory:Items(item)
            if not data then
                Shared.warn(('Supply item "%s" does not exist in ox_inventory'):format(item))
            else
                items[#items + 1] = { item = item, count = count, cost = price * count }
                total = total + price * count
                weight = weight + (data.weight or 0) * count
            end
        end
    end

    if #items == 0 then
        return Server.notify(src, L('empty_order'), 'error')
    end

    if not ox_inventory:CanCarryWeight(src, weight) then
        return Server.notify(src, L('inventory_full'), 'error')
    end

    for _, entry in ipairs(items) do
        if not ox_inventory:CanCarryItem(src, entry.item, entry.count) then
            return Server.notify(src, L('inventory_full'), 'error')
        end
    end

    local fromSociety = Config.Supplies.payFrom == 'society'
    if fromSociety then
        if not Society.remove(restaurant.job, total) then
            return Server.notify(src, L('society_no_money'), 'error')
        end
    else
        local account = Config.Supplies.playerAccount
        if xPlayer.getAccount(account).money < total then
            return Server.notify(src, L('not_enough_money'), 'error')
        end
        xPlayer.removeAccountMoney(account, total, ('%s supplies'):format(restaurant.label))
    end

    -- Give the items, refund anything that could not be added
    local refund = 0
    for _, entry in ipairs(items) do
        if not ox_inventory:AddItem(src, entry.item, entry.count) then
            refund = refund + entry.cost
        end
    end

    if refund > 0 then
        if fromSociety then
            Society.add(restaurant.job, refund)
        else
            xPlayer.addAccountMoney(Config.Supplies.playerAccount, refund, ('%s supplies refund'):format(restaurant.label))
        end
        Server.notify(src, L('supplies_partial', Shared.formatMoney(refund)), 'error')
    end

    Server.notify(src, L('supplies_bought', Shared.formatMoney(total - refund)), 'success', restaurant.label)
end)

lib.callback.register('silent_restaurant:server:getSocietyBalance', function(src, rid)
    local xPlayer, restaurant = Server.getEmployee(src, rid)
    if not xPlayer then return 0 end
    return Society.balance(restaurant.job)
end)
