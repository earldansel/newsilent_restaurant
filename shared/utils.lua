Shared = {}

local RESOURCE = GetCurrentResourceName()

function Shared.debug(...)
    if Config.Debug then
        print(('^5[%s]^7'):format(RESOURCE), ...)
    end
end

function Shared.warn(...)
    print(('^3[%s] WARNING:^7'):format(RESOURCE), ...)
end

---@param coords vector3|vector4
---@return vector3
function Shared.vec3(coords)
    return vec3(coords.x, coords.y, coords.z)
end

---Output item of a recipe (recipe.item or the recipe id itself)
function Shared.recipeItem(recipeId, recipe)
    return recipe.item or recipeId
end

---Price of a menu item, nil if the item is not on the menu
function Shared.menuPrice(restaurant, item)
    for i = 1, #restaurant.menu do
        if restaurant.menu[i].item == item then
            return restaurant.menu[i].price
        end
    end
end

---Price of a supply item, nil if not sold
function Shared.supplyPrice(restaurant, item)
    local supplies = restaurant.supplies
    if not supplies then return end

    for i = 1, #supplies.items do
        if supplies.items[i].item == item then
            return supplies.items[i].price
        end
    end
end

function Shared.storageId(rid, index)
    return ('sr_%s_storage_%d'):format(rid, index)
end

function Shared.trayId(rid, index)
    return ('sr_%s_tray_%d'):format(rid, index)
end

function Shared.seatKey(coords)
    return ('%.1f:%.1f:%.1f'):format(coords.x, coords.y, coords.z)
end

function Shared.formatMoney(amount)
    local formatted = tostring(math.floor(amount))
    local k
    repeat
        formatted, k = formatted:gsub('^(-?%d+)(%d%d%d)', '%1,%2')
    until k == 0
    return '$' .. formatted
end

-- Validate the restaurant configs once on start so mistakes show up in the console instead of at runtime.
for rid, r in pairs(Config.Restaurants) do
    r.id = rid
    r.menu = r.menu or {}
    r.recipes = r.recipes or {}
    r.stations = r.stations or {}
    r.registers = r.registers or {}
    r.orderScreens = r.orderScreens or {}
    r.trays = r.trays or {}
    r.storages = r.storages or {}
    r.seats = r.seats or {}

    if not r.job then
        Shared.warn(('Restaurant "%s" has no job set'):format(rid))
    end

    for _, station in ipairs(r.stations) do
        station.recipes = station.recipes or {}
        for _, recipeId in ipairs(station.recipes) do
            if not r.recipes[recipeId] then
                Shared.warn(('Restaurant "%s": station "%s" uses unknown recipe "%s"'):format(rid, station.label, recipeId))
            end
        end
    end

    for recipeId, recipe in pairs(r.recipes) do
        recipe.amount = recipe.amount or 1
        recipe.time = recipe.time or 5000
        recipe.ingredients = recipe.ingredients or {}
        if not next(recipe.ingredients) then
            Shared.warn(('Restaurant "%s": recipe "%s" has no ingredients'):format(rid, recipeId))
        end
    end
end
