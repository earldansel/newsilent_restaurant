ESX = exports.es_extended:getSharedObject()

Server = {}

---Send an ox_lib notification to a player
function Server.notify(src, description, nType, title)
    TriggerClientEvent('ox_lib:notify', src, {
        title = title,
        description = description,
        type = nType or 'inform',
        duration = 6000,
    })
end

---@return boolean
function Server.isNear(src, coords, maxDistance)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end

    return #(GetEntityCoords(ped) - Shared.vec3(coords)) <= (maxDistance or Config.InteractDistance)
end

function Server.isOnDuty(src, rid)
    if not Config.RequireDuty then return true end
    return Player(src).state.restaurantDuty == rid
end

---Validate that `src` works at restaurant `rid`.
---@param src number
---@param rid string
---@param opts? { minGrade?: number, duty?: boolean, coords?: vector3 }
---@return table? xPlayer, table? restaurant
function Server.getEmployee(src, rid, opts)
    local restaurant = Config.Restaurants[rid]
    if not restaurant then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or xPlayer.job.name ~= restaurant.job then return end

    opts = opts or {}

    if opts.minGrade and xPlayer.job.grade < opts.minGrade then
        Server.notify(src, L('no_permission'), 'error')
        return
    end

    if opts.duty and not Server.isOnDuty(src, rid) then
        Server.notify(src, L('not_on_duty'), 'error')
        return
    end

    if opts.coords and not Server.isNear(src, opts.coords) then
        return
    end

    return xPlayer, restaurant
end

---Server ids of all on-duty employees of a restaurant
function Server.getStaff(rid)
    local restaurant = Config.Restaurants[rid]
    local staff = {}

    for _, xPlayer in pairs(ESX.GetExtendedPlayers('job', restaurant.job)) do
        if Server.isOnDuty(xPlayer.source, rid) then
            staff[#staff + 1] = xPlayer.source
        end
    end

    return staff
end

function Server.notifyStaff(rid, description, nType)
    for _, src in ipairs(Server.getStaff(rid)) do
        Server.notify(src, description, nType, Config.Restaurants[rid].label)
    end
end

---Item label from ox_inventory, falls back to the item name
function Server.itemLabel(name)
    local item = exports.ox_inventory:Items(name)
    return item and item.label or name
end

---Simple per-key cooldown helper
local cooldowns = {}

function Server.cooldown(key, seconds)
    local now = os.time()
    if cooldowns[key] and cooldowns[key] > now then
        return true
    end
    cooldowns[key] = now + seconds
    return false
end

function Server.toInt(value, min, max)
    value = math.floor(tonumber(value) or 0)
    if value < min or value > max then return end
    return value
end
