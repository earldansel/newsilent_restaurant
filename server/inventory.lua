local ox_inventory = exports.ox_inventory

local function registerStashes()
    for rid, restaurant in pairs(Config.Restaurants) do
        for i, storage in ipairs(restaurant.storages) do
            ox_inventory:RegisterStash(
                Shared.storageId(rid, i),
                ('%s - %s'):format(restaurant.label, storage.label or L('storage')),
                storage.slots or 50,
                storage.weight or 200000,
                false,
                { [restaurant.job] = storage.minGrade or 0 },
                Shared.vec3(storage.coords)
            )
        end

        for i, tray in ipairs(restaurant.trays) do
            ox_inventory:RegisterStash(
                Shared.trayId(rid, i),
                ('%s - %s %d'):format(restaurant.label, L('tray'), i),
                tray.slots or 8,
                tray.weight or 15000,
                false,
                nil,
                Shared.vec3(tray.coords)
            )
        end
    end
end

-- ox_inventory may (re)start after us, so register on both events
AddEventHandler('onServerResourceStart', function(resource)
    if resource == 'ox_inventory' or resource == GetCurrentResourceName() then
        registerStashes()
    end
end)

-- Employees must be on duty to open restaurant storage (ox_inventory >= 2.38 hook, ignored on older versions)
if Config.RequireDuty then
    local ok = pcall(function()
        ox_inventory:registerHook('openInventory', function(payload)
            local rid = payload.inventoryId and payload.inventoryId:match('^sr_(.+)_storage_%d+$')
            if rid and Config.Restaurants[rid] and not Server.isOnDuty(payload.source, rid) then
                Server.notify(payload.source, L('not_on_duty'), 'error')
                return false
            end
        end, {
            inventoryFilter = { '^sr_.+_storage_%d+$' },
        })
    end)

    if not ok then
        Shared.debug('ox_inventory openInventory hook not available, duty is only checked client-side for storage')
    end
end
