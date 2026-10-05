local sitting = false

local function standUp()
    if not sitting then return end
    sitting = false

    ClearPedTasks(cache.ped)
    lib.hideTextUI()
    TriggerServerEvent('silent_restaurant:server:releaseSeat')
end

---@param coords vector3 seat position
---@param heading number direction the player faces
local function sit(coords, heading)
    if sitting or cache.vehicle or IsPedRagdoll(cache.ped) then return end

    if not lib.callback.await('silent_restaurant:server:claimSeat', false, coords) then
        return Client.notify(L('seat_taken'), 'error')
    end

    sitting = true
    local ped = cache.ped

    TaskStartScenarioAtPosition(ped, Config.Seats.scenario, coords.x, coords.y, coords.z, heading, 0, true, true)
    lib.showTextUI(L('stand_up', Config.Seats.standKeyLabel), { icon = 'fas fa-chair' })

    CreateThread(function()
        local startedAt = GetGameTimer()

        while sitting do
            if IsControlJustReleased(0, Config.Seats.standKey) then
                standUp()
                break
            end

            -- Got knocked out of the seat (damage, ragdoll, other script...)
            if GetGameTimer() - startedAt > 2000 and not IsPedUsingAnyScenario(ped) then
                standUp()
                break
            end

            Wait(0)
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and sitting then
        standUp()
    end
end)

-- Sit on any configured chair prop in the world
CreateThread(function()
    local models = {}
    for model in pairs(Config.Seats.models) do
        models[#models + 1] = model
    end

    if #models == 0 then return end

    Interact.addModel(models, {
        {
            label = L('sit'),
            icon = 'fas fa-chair',
            canInteract = function() return not sitting end,
            onSelect = function(data)
                local entity = data and data.entity
                if not entity or not DoesEntityExist(entity) then return end

                local cfg = Config.Seats.models[GetEntityModel(entity)]
                if not cfg then return end

                local coords = GetOffsetFromEntityInWorldCoords(entity, cfg.offset.x, cfg.offset.y, cfg.offset.z)
                sit(coords, (GetEntityHeading(entity) + cfg.heading) % 360.0)
            end,
        },
    })
end)

-- Fixed seats from the restaurant configs
Features[#Features + 1] = function(rid, restaurant)
    for i, seat in ipairs(restaurant.seats) do
        Interact.addZone({
            name = ('sr_%s_seat_%d'):format(rid, i),
            coords = seat,
            size = vec3(0.7, 0.7, 1.2),
            rotation = seat.w,
            distance = 1.8,
            options = {
                {
                    label = L('sit'),
                    icon = 'fas fa-chair',
                    canInteract = function() return not sitting end,
                    onSelect = function() sit(vec3(seat.x, seat.y, seat.z), seat.w) end,
                },
            },
        })
    end
end
