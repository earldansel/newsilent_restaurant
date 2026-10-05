local seats = {}    -- seatKey -> src
local occupant = {} -- src -> seatKey

local function release(src)
    local key = occupant[src]
    if key then
        seats[key] = nil
        occupant[src] = nil
    end
end

lib.callback.register('silent_restaurant:server:claimSeat', function(src, coords)
    if type(coords) ~= 'vector3' and type(coords) ~= 'vector4' then return false end
    if not Server.isNear(src, coords, 4.0) then return false end

    local key = Shared.seatKey(coords)
    local current = seats[key]

    if current and current ~= src and GetPlayerPing(current) > 0 then
        return false
    end

    release(src)
    seats[key] = src
    occupant[src] = key
    return true
end)

RegisterNetEvent('silent_restaurant:server:releaseSeat', function()
    release(source)
end)

AddEventHandler('playerDropped', function()
    release(source)
end)
