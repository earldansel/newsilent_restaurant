local bills = {}       -- billId -> pending bill waiting for the customer
local orders = {}      -- rid -> array of paid orders
local orderCounter = {}
local billCounter = 0

local ACCOUNTS = { cash = 'money', bank = 'bank' }

for rid in pairs(Config.Restaurants) do
    orders[rid] = {}
    orderCounter[rid] = 0
end

local function findOrder(rid, orderId)
    for i, order in ipairs(orders[rid]) do
        if order.id == orderId then
            return order, i
        end
    end
end

local function customerHasBill(customer)
    for _, bill in pairs(bills) do
        if bill.customer == customer then return true end
    end
    return false
end

local function syncOrders(rid)
    for _, src in ipairs(Server.getStaff(rid)) do
        TriggerClientEvent('silent_restaurant:client:ordersUpdated', src, rid)
    end
end

-- Expire unpaid bills
CreateThread(function()
    while true do
        Wait(5000)
        local now = os.time()
        for id, bill in pairs(bills) do
            if now > bill.expires then
                bills[id] = nil
                Server.notify(bill.cashier, L('bill_expired'), 'error')
                Server.notify(bill.customer, L('bill_expired'), 'error')
                TriggerClientEvent('silent_restaurant:client:closeBill', bill.customer, id)
            end
        end
    end
end)

RegisterNetEvent('silent_restaurant:server:createBill', function(rid, registerIndex, customer, cart)
    local src = source
    local restaurant = Config.Restaurants[rid]
    local register = restaurant and restaurant.registers[tonumber(registerIndex) or 0]
    if not register or type(cart) ~= 'table' then return end

    local xPlayer = Server.getEmployee(src, rid, { duty = true, coords = register.coords })
    if not xPlayer then return end

    customer = tonumber(customer)
    if not customer or not ESX.GetPlayerFromId(customer) then
        return Server.notify(src, L('invalid_customer'), 'error')
    end

    if customer == src and not Config.Cashier.allowSelfBilling then
        return Server.notify(src, L('cannot_bill_self'), 'error')
    end

    if customer ~= src then
        local dist = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(customer)))
        if dist > Config.Cashier.maxDistance + 1.0 then
            return Server.notify(src, L('customer_too_far'), 'error')
        end
    end

    if customerHasBill(customer) then
        return Server.notify(src, L('customer_has_bill'), 'error')
    end

    -- Never trust client prices: rebuild the order from the config
    local items, total = {}, 0
    for item, count in pairs(cart) do
        local price = type(item) == 'string' and Shared.menuPrice(restaurant, item)
        count = Server.toInt(count, 1, Config.Cashier.maxQuantity)

        if price and count then
            items[#items + 1] = { item = item, label = Server.itemLabel(item), count = count, price = price }
            total = total + price * count
        end
    end

    if #items == 0 or total <= 0 then
        return Server.notify(src, L('empty_order'), 'error')
    end

    table.sort(items, function(a, b) return a.label < b.label end)

    billCounter = billCounter + 1
    local bill = {
        id = billCounter,
        rid = rid,
        cashier = src,
        cashierName = xPlayer.getName(),
        customer = customer,
        items = items,
        total = total,
        expires = os.time() + Config.Cashier.paymentTimeout,
    }
    bills[bill.id] = bill

    TriggerClientEvent('silent_restaurant:client:billPrompt', customer, {
        id = bill.id,
        restaurant = restaurant.label,
        items = items,
        total = total,
        timeout = Config.Cashier.paymentTimeout,
        methods = Config.Cashier.methods,
    })

    Server.notify(src, L('bill_sent', customer, Shared.formatMoney(total)), 'inform')
end)

RegisterNetEvent('silent_restaurant:server:respondBill', function(billId, method)
    local src = source
    local bill = bills[billId]
    if not bill or bill.customer ~= src then return end

    bills[billId] = nil

    local restaurant = Config.Restaurants[bill.rid]

    if method ~= 'cash' and method ~= 'bank' then
        Server.notify(src, L('bill_declined_customer'), 'inform')
        return Server.notify(bill.cashier, L('bill_declined'), 'error')
    end

    if not Config.Cashier.methods[method] then return end

    local xCustomer = ESX.GetPlayerFromId(src)
    if not xCustomer then return end

    local account = ACCOUNTS[method]
    if xCustomer.getAccount(account).money < bill.total then
        Server.notify(src, L('not_enough_money'), 'error')
        return Server.notify(bill.cashier, L('customer_no_money'), 'error')
    end

    -- Make sure the money has somewhere to go before charging the customer
    if not Society.get(restaurant.job) then
        Shared.warn(('Payment for %s failed: society account missing'):format(restaurant.job))
        Server.notify(src, L('society_missing'), 'error')
        return Server.notify(bill.cashier, L('society_missing'), 'error')
    end

    xCustomer.removeAccountMoney(account, bill.total, ('%s order'):format(restaurant.label))

    -- Commission to the cashier (only if still online and still working there)
    local commission = 0
    local xCashier = ESX.GetPlayerFromId(bill.cashier)
    if xCashier and xCashier.job.name == restaurant.job and Config.Cashier.commission > 0 then
        commission = math.floor(bill.total * Config.Cashier.commission)
        if commission > 0 then
            xCashier.addAccountMoney(Config.Cashier.commissionAccount, commission, ('%s commission'):format(restaurant.label))
        end
    end

    Society.add(restaurant.job, bill.total - commission)

    orderCounter[bill.rid] = orderCounter[bill.rid] % 999 + 1
    local order = {
        id = ('%d-%d'):format(os.time(), bill.id),
        number = orderCounter[bill.rid],
        customer = src,
        customerName = xCustomer.getName(),
        cashierName = bill.cashierName,
        items = bill.items,
        total = bill.total,
        method = method,
        status = 'paid',
        time = os.time(),
    }

    local list = orders[bill.rid]
    list[#list + 1] = order
    while #list > Config.Cashier.keepOrders do
        table.remove(list, 1)
    end

    Server.notify(src, L('order_paid_customer', order.number, Shared.formatMoney(bill.total)), 'success', restaurant.label)

    if xCashier then
        Server.notify(bill.cashier, commission > 0
            and L('order_paid_cashier_commission', order.number, Shared.formatMoney(commission))
            or L('order_paid_cashier', order.number), 'success')
    end

    Server.notifyStaff(bill.rid, L('new_order', order.number), 'inform')
    syncOrders(bill.rid)
end)

lib.callback.register('silent_restaurant:server:getOrders', function(src, rid)
    if not Server.getEmployee(src, rid) then return {}, os.time() end
    return orders[rid] or {}, os.time()
end)

RegisterNetEvent('silent_restaurant:server:orderAction', function(rid, orderId, action)
    local src = source
    local xPlayer, restaurant = Server.getEmployee(src, rid, { duty = true })
    if not xPlayer then return end

    local order, index = findOrder(rid, orderId)
    if not order then
        return Server.notify(src, L('order_not_found'), 'error')
    end

    if action == 'ready' then
        if order.status == 'ready' then return end
        order.status = 'ready'

        if GetPlayerPing(order.customer) > 0 then
            Server.notify(order.customer, L('order_ready_customer', order.number), 'success', restaurant.label)
        end
        Server.notify(src, L('order_marked_ready', order.number), 'success')
    elseif action == 'complete' then
        table.remove(orders[rid], index)
        Server.notify(src, L('order_completed', order.number), 'success')
    elseif action == 'refund' then
        if xPlayer.job.grade < Config.Cashier.refundMinGrade then
            return Server.notify(src, L('no_permission'), 'error')
        end

        local xCustomer = ESX.GetPlayerFromId(order.customer)
        if not xCustomer then
            return Server.notify(src, L('customer_offline'), 'error')
        end

        if not Society.remove(restaurant.job, order.total) then
            return Server.notify(src, L('society_no_money'), 'error')
        end

        xCustomer.addAccountMoney(ACCOUNTS[order.method] or 'bank', order.total, ('%s refund'):format(restaurant.label))
        table.remove(orders[rid], index)

        Server.notify(order.customer, L('order_refunded_customer', order.number, Shared.formatMoney(order.total)), 'inform', restaurant.label)
        Server.notify(src, L('order_refunded', order.number), 'success')
    else
        return
    end

    syncOrders(rid)
end)

RegisterNetEvent('silent_restaurant:server:callStaff', function(rid, registerIndex)
    local src = source
    local restaurant = Config.Restaurants[rid]
    local register = restaurant and restaurant.registers[tonumber(registerIndex) or 0]
    if not register or not Server.isNear(src, register.coords) then return end

    if Server.cooldown(('callstaff:%d'):format(src), Config.Cashier.callStaffCooldown) then
        return Server.notify(src, L('call_staff_cooldown'), 'error')
    end

    local staff = Server.getStaff(rid)
    if #staff == 0 then
        return Server.notify(src, L('no_staff'), 'error', restaurant.label)
    end

    Server.notifyStaff(rid, L('customer_waiting', src), 'inform')
    Server.notify(src, L('staff_called'), 'success', restaurant.label)
end)

AddEventHandler('playerDropped', function()
    local src = source
    for id, bill in pairs(bills) do
        if bill.customer == src or bill.cashier == src then
            bills[id] = nil
            local other = bill.customer == src and bill.cashier or bill.customer
            Server.notify(other, L('bill_cancelled'), 'error')
            TriggerClientEvent('silent_restaurant:client:closeBill', other, id)
        end
    end
end)
