local blips = {}

local function blipName(rid, staff)
    local restaurant = Config.Restaurants[rid]
    staff = staff or GlobalState[('sr_staff_%s'):format(rid)] or 0
    return ('%s (%s)'):format(restaurant.label, staff > 0 and L('open') or L('closed'))
end

local function updateBlip(rid, staff)
    local blip = blips[rid]
    if not blip then return end

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipName(rid, staff))
    EndTextCommandSetBlipName(blip)
end

AddStateBagChangeHandler(nil, 'global', function(_, key, value)
    local rid = key:match('^sr_staff_(.+)$')
    if rid then
        updateBlip(rid, tonumber(value) or 0)
    end
end)

Features[#Features + 1] = function(rid, restaurant)
    local cfg = restaurant.blip
    if not cfg then return end

    local blip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
    SetBlipSprite(blip, cfg.sprite or 106)
    SetBlipColour(blip, cfg.color or 1)
    SetBlipScale(blip, cfg.scale or 0.8)
    SetBlipAsShortRange(blip, true)

    blips[rid] = blip
    updateBlip(rid)
end
