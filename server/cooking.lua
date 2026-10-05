local ox_inventory = exports.ox_inventory
local cooking = {} -- src -> active cooking job

local function refund(src, job)
    for item, count in pairs(job.ingredients) do
        ox_inventory:AddItem(src, item, count)
    end
end

lib.callback.register('silent_restaurant:server:startCooking', function(src, rid, stationIndex, recipeId, amount)
    if cooking[src] then return false, L('already_cooking') end

    local restaurant = Config.Restaurants[rid]
    local station = restaurant and restaurant.stations[tonumber(stationIndex) or 0]
    if not station then return false end

    local xPlayer = Server.getEmployee(src, rid, { duty = true, coords = station.coords })
    if not xPlayer then return false end

    local recipe = restaurant.recipes[recipeId]
    if not recipe or not lib.table.contains(station.recipes, recipeId) then return false end

    amount = Server.toInt(amount, 1, Config.Cooking.maxBatch)
    if not amount then return false end

    -- Check every ingredient first so nothing is removed on a partial match
    local needed = {}
    for item, count in pairs(recipe.ingredients) do
        needed[item] = count * amount
        if ox_inventory:Search(src, 'count', item) < needed[item] then
            return false, L('missing_ingredients')
        end
    end

    local output = Shared.recipeItem(recipeId, recipe)
    local outputCount = recipe.amount * amount
    if not ox_inventory:CanCarryItem(src, output, outputCount) then
        return false, L('inventory_full')
    end

    local removed = {}
    for item, count in pairs(needed) do
        if not ox_inventory:RemoveItem(src, item, count) then
            refund(src, { ingredients = removed })
            return false, L('missing_ingredients')
        end
        removed[item] = count
    end

    local duration = recipe.time * amount
    cooking[src] = {
        rid = rid,
        recipeId = recipeId,
        output = output,
        outputCount = outputCount,
        ingredients = removed,
        startedAt = GetGameTimer(),
        duration = duration,
    }

    return true, duration
end)

lib.callback.register('silent_restaurant:server:finishCooking', function(src)
    local job = cooking[src]
    if not job then return false end

    -- Allow a little latency, but block instant finishes
    if GetGameTimer() - job.startedAt < job.duration * 0.85 then
        return false
    end

    cooking[src] = nil

    if not ox_inventory:AddItem(src, job.output, job.outputCount) then
        refund(src, job)
        Server.notify(src, L('inventory_full'), 'error')
        return false
    end

    Server.notify(src, L('cooked', job.outputCount, Server.itemLabel(job.output)), 'success')
    return true
end)

RegisterNetEvent('silent_restaurant:server:cancelCooking', function(failed)
    local src = source
    local job = cooking[src]
    if not job then return end

    cooking[src] = nil

    if failed and Config.Cooking.loseIngredientsOnFail then
        return Server.notify(src, L('cooking_failed_lost'), 'error')
    end

    refund(src, job)
    Server.notify(src, failed and L('cooking_failed') or L('cooking_cancelled'), 'error')
end)

AddEventHandler('playerDropped', function()
    cooking[source] = nil
end)
