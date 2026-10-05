Orders = {}

local STATUS_COLOR = { paid = '#ff9800', ready = '#4caf50' }

local function timeAgo(timestamp, now)
    local minutes = math.floor((now - timestamp) / 60)
    return minutes <= 0 and L('just_now') or L('minutes_ago', minutes)
end

local function itemLines(order)
    local lines = {}
    for _, entry in ipairs(order.items) do
        lines[#lines + 1] = ('%dx %s'):format(entry.count, entry.label)
    end
    return table.concat(lines, '\n')
end

local function openOrder(rid, order)
    local options = {
        {
            title = L('order_items'),
            description = itemLines(order),
            icon = 'fas fa-receipt',
            readOnly = true,
        },
        {
            title = L('order_customer', order.customerName, order.customer),
            description = L('order_cashier', order.cashierName),
            icon = 'fas fa-user',
            readOnly = true,
        },
    }

    if order.status ~= 'ready' then
        options[#options + 1] = {
            title = L('mark_ready'),
            description = L('mark_ready_desc'),
            icon = 'fas fa-bell',
            iconColor = '#4caf50',
            onSelect = function()
                TriggerServerEvent('silent_restaurant:server:orderAction', rid, order.id, 'ready')
            end,
        }
    end

    options[#options + 1] = {
        title = L('mark_complete'),
        description = L('mark_complete_desc'),
        icon = 'fas fa-check',
        iconColor = '#2196f3',
        onSelect = function()
            TriggerServerEvent('silent_restaurant:server:orderAction', rid, order.id, 'complete')
        end,
    }

    if Client.hasJob(Config.Restaurants[rid].job, Config.Cashier.refundMinGrade) then
        options[#options + 1] = {
            title = L('refund_order'),
            description = L('refund_order_desc', Shared.formatMoney(order.total)),
            icon = 'fas fa-rotate-left',
            iconColor = '#f44336',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = L('refund_order'),
                    content = L('refund_confirm', order.number, Shared.formatMoney(order.total)),
                    centered = true,
                    cancel = true,
                })
                if confirm == 'confirm' then
                    TriggerServerEvent('silent_restaurant:server:orderAction', rid, order.id, 'refund')
                end
            end,
        }
    end

    lib.registerContext({
        id = 'sr_order',
        title = L('order_number', order.number),
        menu = 'sr_orders',
        options = options,
    })
    lib.showContext('sr_order')
end

function Orders.open(rid)
    local orders, now = lib.callback.await('silent_restaurant:server:getOrders', false, rid)
    local restaurant = Config.Restaurants[rid]
    orders = orders or {}
    now = now or 0
    local options = {}

    -- Newest first
    for i = #orders, 1, -1 do
        local order = orders[i]
        options[#options + 1] = {
            title = ('%s  •  %s'):format(L('order_number', order.number), Shared.formatMoney(order.total)),
            description = ('%s\n%s • %s'):format(itemLines(order), L('status_' .. order.status), timeAgo(order.time, now)),
            icon = order.status == 'ready' and 'fas fa-circle-check' or 'fas fa-fire',
            iconColor = STATUS_COLOR[order.status],
            arrow = true,
            onSelect = function() openOrder(rid, order) end,
        }
    end

    if #options == 0 then
        options[1] = { title = L('no_orders'), icon = 'fas fa-mug-hot', readOnly = true }
    end

    lib.registerContext({
        id = 'sr_orders',
        title = L('orders_title', restaurant.label),
        options = options,
    })
    lib.showContext('sr_orders')
end

function Orders.showMenu(rid)
    local restaurant = Config.Restaurants[rid]
    local options = {}

    for _, entry in ipairs(restaurant.menu) do
        options[#options + 1] = {
            title = Client.itemLabel(entry.item),
            description = Shared.formatMoney(entry.price),
            image = Client.itemImage(entry.item),
            icon = 'fas fa-utensils',
            readOnly = true,
        }
    end

    lib.registerContext({
        id = 'sr_menu',
        title = L('menu_title', restaurant.label),
        options = options,
    })
    lib.showContext('sr_menu')
end

-- Refresh the order screen live while it is open
RegisterNetEvent('silent_restaurant:client:ordersUpdated', function(rid)
    if lib.getOpenContextMenu() == 'sr_orders' then
        Orders.open(rid)
    end
end)

Features[#Features + 1] = function(rid, restaurant)
    for i, screen in ipairs(restaurant.orderScreens) do
        Interact.addZone({
            name = ('sr_%s_orders_%d'):format(rid, i),
            coords = screen.coords,
            size = screen.size or vec3(1.0, 0.5, 0.8),
            rotation = screen.rotation,
            options = {
                {
                    label = L('view_orders'),
                    icon = 'fas fa-list-check',
                    rid = rid,
                    staff = true,
                    onSelect = function() Orders.open(rid) end,
                },
            },
        })
    end
end
