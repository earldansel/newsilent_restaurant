local function openSupplies(rid)
    local restaurant = Config.Restaurants[rid]
    local supplies = restaurant.supplies
    local rows = {}

    local header = L('supplies_title', restaurant.label)
    if Config.Supplies.payFrom == 'society' then
        local balance = lib.callback.await('silent_restaurant:server:getSocietyBalance', false, rid) or 0
        header = L('supplies_title_balance', restaurant.label, Shared.formatMoney(balance))
    end

    for i, entry in ipairs(supplies.items) do
        rows[i] = {
            type = 'number',
            label = ('%s  (%s)'):format(Client.itemLabel(entry.item), Shared.formatMoney(entry.price)),
            icon = 'fas fa-box',
            min = 0,
            max = Config.Supplies.maxQuantity,
            default = 0,
        }
    end

    local input = lib.inputDialog(header, rows)
    if not input then return end

    local cart, total = {}, 0
    for i, entry in ipairs(supplies.items) do
        local count = math.floor(tonumber(input[i]) or 0)
        if count > 0 then
            cart[entry.item] = (cart[entry.item] or 0) + count
            total = total + entry.price * count
        end
    end

    if total <= 0 then
        return Client.notify(L('empty_order'), 'error')
    end

    local confirm = lib.alertDialog({
        header = L('supplies_confirm_title'),
        content = L(Config.Supplies.payFrom == 'society' and 'supplies_confirm_society' or 'supplies_confirm_player', Shared.formatMoney(total)),
        centered = true,
        cancel = true,
    })

    if confirm == 'confirm' then
        TriggerServerEvent('silent_restaurant:server:buySupplies', rid, cart)
    end
end

Features[#Features + 1] = function(rid, restaurant)
    for i, storage in ipairs(restaurant.storages) do
        Interact.addZone({
            name = ('sr_%s_storage_%d'):format(rid, i),
            coords = storage.coords,
            size = storage.size,
            rotation = storage.rotation,
            options = {
                {
                    label = L('open_storage', storage.label or L('storage')),
                    icon = 'fas fa-box-open',
                    rid = rid,
                    staff = true,
                    minGrade = storage.minGrade,
                    onSelect = function()
                        exports.ox_inventory:openInventory('stash', Shared.storageId(rid, i))
                    end,
                },
            },
        })
    end

    for i, tray in ipairs(restaurant.trays) do
        Interact.addZone({
            name = ('sr_%s_tray_%d'):format(rid, i),
            coords = tray.coords,
            size = tray.size or vec3(0.6, 0.6, 0.5),
            rotation = tray.rotation,
            options = {
                {
                    label = L('open_tray', i),
                    icon = 'fas fa-hand-holding',
                    onSelect = function()
                        exports.ox_inventory:openInventory('stash', Shared.trayId(rid, i))
                    end,
                },
            },
        })
    end

    local supplies = restaurant.supplies
    if supplies and supplies.items and #supplies.items > 0 then
        Interact.addZone({
            name = ('sr_%s_supplies'):format(rid),
            coords = supplies.coords,
            size = supplies.size,
            rotation = supplies.rotation,
            options = {
                {
                    label = L('order_supplies'),
                    icon = 'fas fa-truck-ramp-box',
                    rid = rid,
                    staff = true,
                    minGrade = supplies.minGrade,
                    onSelect = function() openSupplies(rid) end,
                },
            },
        })
    end
end
