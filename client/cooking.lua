local busy = false

local function ingredientLines(recipe, amount)
    local lines, hasAll = {}, true

    for item, count in pairs(recipe.ingredients) do
        local needed = count * amount
        local have = Client.itemCount(item)
        if have < needed then hasAll = false end
        lines[#lines + 1] = ('%s %s: %d/%d'):format(have >= needed and '✔' or '✖', Client.itemLabel(item), have, needed)
    end

    table.sort(lines)
    return table.concat(lines, '\n'), hasAll
end

---How many batches the player can make with what they carry
local function maxCraftable(recipe)
    local max = Config.Cooking.maxBatch
    for item, count in pairs(recipe.ingredients) do
        max = math.min(max, math.floor(Client.itemCount(item) / count))
    end
    return max
end

local function cook(rid, stationIndex, recipeId)
    if busy then return end

    local restaurant = Config.Restaurants[rid]
    local station = restaurant.stations[stationIndex]
    local recipe = restaurant.recipes[recipeId]
    local output = Shared.recipeItem(recipeId, recipe)
    local label = Client.itemLabel(output)

    local amount = 1
    local max = maxCraftable(recipe)

    if max < 1 then
        return Client.notify(L('missing_ingredients'), 'error')
    end

    if max > 1 then
        local input = lib.inputDialog(L('cook_amount_title', label), {
            { type = 'slider', label = L('amount'), min = 1, max = max, default = 1, step = 1 },
        })
        if not input then return end
        amount = math.floor(tonumber(input[1]) or 1)
    end

    busy = true

    local ok, duration = lib.callback.await('silent_restaurant:server:startCooking', false, rid, stationIndex, recipeId, amount)
    if not ok then
        busy = false
        if duration then Client.notify(duration, 'error') end
        return
    end

    local useSkillCheck = recipe.skillCheck
    if useSkillCheck == nil then useSkillCheck = Config.Cooking.skillCheck end

    if useSkillCheck and not lib.skillCheck(Config.Cooking.skillCheckDifficulty, { 'e' }) then
        busy = false
        TriggerServerEvent('silent_restaurant:server:cancelCooking', true)
        return
    end

    local completed = lib.progressBar({
        duration = duration,
        label = L('cooking_progress', amount * recipe.amount, label),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true, sprint = true },
        anim = station.scenario and { scenario = station.scenario } or station.anim,
        prop = station.prop,
    })

    if completed then
        lib.callback.await('silent_restaurant:server:finishCooking', false)
    else
        TriggerServerEvent('silent_restaurant:server:cancelCooking', false)
    end

    ClearPedTasks(cache.ped)
    busy = false
end

local function openStation(rid, stationIndex)
    local restaurant = Config.Restaurants[rid]
    local station = restaurant.stations[stationIndex]
    local options = {}

    for _, recipeId in ipairs(station.recipes) do
        local recipe = restaurant.recipes[recipeId]
        if recipe then
            local output = Shared.recipeItem(recipeId, recipe)
            local description, hasAll = ingredientLines(recipe, 1)

            options[#options + 1] = {
                title = recipe.amount > 1 and ('%s (x%d)'):format(Client.itemLabel(output), recipe.amount) or Client.itemLabel(output),
                description = ('%s\n⏱ %.1fs'):format(description, recipe.time / 1000),
                image = Client.itemImage(output),
                icon = station.icon or 'fas fa-utensils',
                iconColor = hasAll and '#4caf50' or '#9e9e9e',
                disabled = not hasAll,
                onSelect = function() cook(rid, stationIndex, recipeId) end,
            }
        end
    end

    lib.registerContext({
        id = 'sr_station',
        title = ('%s - %s'):format(restaurant.label, station.label),
        options = options,
    })
    lib.showContext('sr_station')
end

Features[#Features + 1] = function(rid, restaurant)
    for i, station in ipairs(restaurant.stations) do
        Interact.addZone({
            name = ('sr_%s_station_%d'):format(rid, i),
            coords = station.coords,
            size = station.size,
            rotation = station.rotation,
            options = {
                {
                    label = L('use_station', station.label),
                    icon = station.icon or 'fas fa-utensils',
                    rid = rid,
                    staff = true,
                    canInteract = function() return not busy end,
                    onSelect = function() openStation(rid, i) end,
                },
            },
        })
    end
end
