local staffCount = {}

local function publishStaffCount(rid)
    GlobalState[('sr_staff_%s'):format(rid)] = staffCount[rid] or 0
end

local function setDuty(src, rid)
    local state = Player(src).state
    local current = state.restaurantDuty

    if current == rid then return end

    if current and staffCount[current] then
        staffCount[current] = math.max(0, staffCount[current] - 1)
        publishStaffCount(current)
    end

    state:set('restaurantDuty', rid, true)

    if rid then
        staffCount[rid] = (staffCount[rid] or 0) + 1
        publishStaffCount(rid)
    end
end

Server.setDuty = setDuty

RegisterNetEvent('silent_restaurant:server:toggleDuty', function(rid)
    local src = source
    local restaurant = Config.Restaurants[rid]
    if not restaurant or not restaurant.duty then return end

    local xPlayer = Server.getEmployee(src, rid, { coords = restaurant.duty.coords })
    if not xPlayer then return end

    if Player(src).state.restaurantDuty == rid then
        setDuty(src, nil)
        Server.notify(src, L('duty_off'), 'inform', restaurant.label)
    else
        setDuty(src, rid)
        Server.notify(src, L('duty_on'), 'success', restaurant.label)
    end
end)

-- Job changed (fired, hired somewhere else...) -> clock out
AddEventHandler('esx:setJob', function(src, job)
    local rid = Player(src).state.restaurantDuty
    if rid and Config.Restaurants[rid] and Config.Restaurants[rid].job ~= job.name then
        setDuty(src, nil)
    end
end)

local function clockOut(src)
    if Player(src).state.restaurantDuty then
        setDuty(src, nil)
    end
end

AddEventHandler('esx:playerLogout', clockOut)
AddEventHandler('playerDropped', function()
    clockOut(source)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    -- Reset everyone after a restart so counters stay in sync
    for _, playerId in ipairs(GetPlayers()) do
        Player(tonumber(playerId)).state:set('restaurantDuty', nil, true)
    end

    for rid in pairs(Config.Restaurants) do
        staffCount[rid] = 0
        publishStaffCount(rid)
    end
end)

lib.callback.register('silent_restaurant:server:getStaffList', function(src, rid)
    local xPlayer, restaurant = Server.getEmployee(src, rid)
    if not xPlayer then return {} end

    local list = {}
    for _, xEmployee in pairs(ESX.GetExtendedPlayers('job', restaurant.job)) do
        list[#list + 1] = {
            id = xEmployee.source,
            name = xEmployee.getName(),
            grade = xEmployee.job.grade_label,
            onDuty = Server.isOnDuty(xEmployee.source, rid),
        }
    end

    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end)
