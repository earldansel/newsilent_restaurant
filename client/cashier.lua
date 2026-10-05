local function selectCustomer()
    local nearby = lib.getNearbyPlayers(GetEntityCoords(cache.ped), Config.Cashier.maxDistance, Config.Cashier.allowSelfBilling)
    local options = {}

    for _, player in ipairs(nearby) do
        local serverId = GetPlayerServerId(player.id)
        options[#options + 1] = {
            value = serverId,
            label = serverId == cache.serverId and L('customer_self', serverId) or L('customer_id', serverId),
        }
    end

    if #options == 0 then
        Client.notify(L('no_customers_nearby'), 'error')
        return
    end

    table.sort(options, function(a, b) return a.value < b.value end)

    if #options == 1 then
        return options[1].value
    end

    local input = lib.inputDialog(L('select_customer'), {
        { type = 'select', label = L('customer'), options = options, required = true, default = options[1].value },
    })

    return input and tonumber(input[1])
end

local function ringUpOrder(rid, registerIndex)
    local restaurant = Config.Restaurants[rid]
    if #restaurant.menu == 0 then
        return Client.notify(L('menu_empty'), 'error')
    end

    local rows = {}
    for i, entry in ipairs(restaurant.menu) do
        rows[i] = {
            type = 'number',
            label = ('%s  (%s)'):format(Client.itemLabel(entry.item), Shared.formatMoney(entry.price)),
            icon = 'fas fa-utensils',
            min = 0,
            max = Config.Cashier.maxQuantity,
            default = 0,
        }
    end

    local input = lib.inputDialog(L('register_title', restaurant.label), rows, { allowCancel = true })
    if not input then return end

    local cart, total = {}, 0
    for i, entry in ipairs(restaurant.menu) do
        local count = math.floor(tonumber(input[i]) or 0)
        if count > 0 then
            cart[entry.item] = (cart[entry.item] or 0) + count
            total = total + entry.price * count
        end
    end

    if total <= 0 then
        return Client.notify(L('empty_order'), 'error')
    end

    local customer = selectCustomer()
    if not customer then return end

    TriggerServerEvent('silent_restaurant:server:createBill', rid, registerIndex, customer, cart)
end

-- ===================== Customer side =====================

local activeBill

RegisterNetEvent('silent_restaurant:client:billPrompt', function(bill)
    activeBill = bill.id

    local lines = {}
    for _, entry in ipairs(bill.items) do
        lines[#lines + 1] = ('%dx %s - %s'):format(entry.count, entry.label, Shared.formatMoney(entry.price * entry.count))
    end

    local function respond(method)
        if activeBill ~= bill.id then return end
        activeBill = nil
        TriggerServerEvent('silent_restaurant:server:respondBill', bill.id, method)
    end

    local options = {
        {
            title = L('order_summary'),
            description = table.concat(lines, '\n'),
            icon = 'fas fa-receipt',
            readOnly = true,
        },
    }

    if bill.methods.cash then
        options[#options + 1] = {
            title = L('pay_cash', Shared.formatMoney(bill.total)),
            icon = 'fas fa-money-bill-wave',
            iconColor = '#4caf50',
            onSelect = function() respond('cash') end,
        }
    end

    if bill.methods.bank then
        options[#options + 1] = {
            title = L('pay_bank', Shared.formatMoney(bill.total)),
            icon = 'fas fa-credit-card',
            iconColor = '#2196f3',
            onSelect = function() respond('bank') end,
        }
    end

    options[#options + 1] = {
        title = L('decline'),
        icon = 'fas fa-xmark',
        iconColor = '#f44336',
        onSelect = function() respond('decline') end,
    }

    lib.registerContext({
        id = 'sr_bill',
        title = L('bill_title', bill.restaurant, Shared.formatMoney(bill.total)),
        canClose = true,
        onExit = function() respond('decline') end,
        options = options,
    })

    lib.showContext('sr_bill')
    Client.notify(L('bill_received', bill.restaurant, bill.timeout), 'inform')
end)

RegisterNetEvent('silent_restaurant:client:closeBill', function(billId)
    if activeBill == billId then
        activeBill = nil
        if lib.getOpenContextMenu() == 'sr_bill' then
            lib.hideContext(false)
        end
    end
end)

-- ===================== Zones =====================

Features[#Features + 1] = function(rid, restaurant)
    for i, register in ipairs(restaurant.registers) do
        Interact.addZone({
            name = ('sr_%s_register_%d'):format(rid, i),
            label = L('register'),
            coords = register.coords,
            size = register.size or vec3(0.7, 0.7, 0.8),
            rotation = register.rotation,
            options = {
                {
                    label = L('ring_up_order'),
                    icon = 'fas fa-cash-register',
                    rid = rid,
                    staff = true,
                    onSelect = function() ringUpOrder(rid, i) end,
                },
                {
                    label = L('view_orders'),
                    icon = 'fas fa-list-check',
                    rid = rid,
                    staff = true,
                    onSelect = function() Orders.open(rid) end,
                },
                {
                    label = L('view_menu'),
                    icon = 'fas fa-book-open',
                    onSelect = function() Orders.showMenu(rid) end,
                },
                {
                    label = L('call_staff'),
                    icon = 'fas fa-bell-concierge',
                    canInteract = function() return not Client.isStaff(rid) end,
                    onSelect = function() TriggerServerEvent('silent_restaurant:server:callStaff', rid, i) end,
                },
            },
        })
    end
end
