ESX = exports.es_extended:getSharedObject()

Client = {
    PlayerData = {},
}

-- Each client module adds a setup function(rid, restaurant); client/init.lua runs them all
Features = {}

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    Client.PlayerData = xPlayer
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    Client.PlayerData = {}
end)

RegisterNetEvent('esx:setJob', function(job)
    Client.PlayerData.job = job
end)

if ESX.IsPlayerLoaded() then
    Client.PlayerData = ESX.GetPlayerData()
end

---@param job string
---@param minGrade? number
function Client.hasJob(job, minGrade)
    local current = Client.PlayerData.job
    if not current or current.name ~= job then return false end
    return not minGrade or current.grade >= minGrade
end

function Client.isOnDuty(rid)
    if not Config.RequireDuty then return true end
    return LocalPlayer.state.restaurantDuty == rid
end

---Employee of `rid` (and on duty when required)
function Client.isStaff(rid, minGrade)
    local restaurant = Config.Restaurants[rid]
    return Client.hasJob(restaurant.job, minGrade) and Client.isOnDuty(rid)
end

function Client.notify(description, nType, title)
    lib.notify({ title = title, description = description, type = nType or 'inform' })
end

local itemCache = {}

function Client.itemLabel(name)
    if itemCache[name] == nil then
        local item = exports.ox_inventory:Items(name)
        itemCache[name] = item and item.label or false
    end
    return itemCache[name] or name
end

function Client.itemCount(name)
    return exports.ox_inventory:Search('count', name) or 0
end

function Client.itemImage(name)
    return ('nui://ox_inventory/web/images/%s.png'):format(name)
end

-- Dev helper: copy your current position as a vec4 for the config
RegisterCommand('srcoords', function()
    local coords = GetEntityCoords(cache.ped)
    local text = ('vec4(%.2f, %.2f, %.2f, %.1f)'):format(coords.x, coords.y, coords.z, GetEntityHeading(cache.ped))
    lib.setClipboard(text)
    print(text)
    Client.notify(L('coords_copied', text), 'success')
end, false)
