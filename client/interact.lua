--[[
    Small interaction layer so every feature works with ox_target OR plain ox_lib TextUI.

    Option fields:
        label, icon, onSelect
        rid        restaurant id, used with `staff`
        staff      true  -> must work at `rid` (and be on duty when Config.RequireDuty)
        employee   true  -> must work at `rid` (duty not required, e.g. duty point / wardrobe)
        minGrade   minimum job grade
        canInteract  extra custom check
]]

Interact = {}

local useTarget = Config.Interaction == 'target' and GetResourceState('ox_target') ~= 'missing'

if Config.Interaction == 'target' and not useTarget then
    Shared.warn('ox_target not found, falling back to TextUI interactions')
end

Interact.useTarget = useTarget

local function canUse(opt)
    if opt.rid and (opt.staff or opt.employee or opt.minGrade) then
        local restaurant = Config.Restaurants[opt.rid]
        if not Client.hasJob(restaurant.job, opt.minGrade) then return false end
        if opt.staff and not Client.isOnDuty(opt.rid) then return false end
    end

    if opt.canInteract and not opt.canInteract() then return false end
    return true
end

local function toTargetOptions(name, options, distance)
    local list = {}
    for i, opt in ipairs(options) do
        list[i] = {
            name = ('%s:%d'):format(name, i),
            label = opt.label,
            icon = opt.icon,
            distance = distance,
            canInteract = function() return canUse(opt) end,
            onSelect = function(data) opt.onSelect(data) end,
        }
    end
    return list
end

local function openOptionMenu(title, options)
    local menu = {}
    for i, opt in ipairs(options) do
        menu[i] = { title = opt.label, icon = opt.icon, onSelect = function() opt.onSelect() end }
    end
    lib.registerContext({ id = 'sr_interact', title = title, options = menu })
    lib.showContext('sr_interact')
end

---@param data { name: string, label?: string, coords: vector3, size?: vector3, rotation?: number, distance?: number, options: table[] }
function Interact.addZone(data)
    local coords = Shared.vec3(data.coords)

    if useTarget then
        return exports.ox_target:addBoxZone({
            name = data.name,
            coords = coords,
            size = data.size or vec3(1.5, 1.5, 2.0),
            rotation = data.rotation or 0.0,
            debug = Config.Debug,
            options = toTargetOptions(data.name, data.options, data.distance or 2.0),
        })
    end

    local point = lib.points.new({ coords = coords, distance = data.distance or 1.6 })
    local shownText

    local function hide()
        if shownText then
            lib.hideTextUI()
            shownText = nil
        end
    end

    function point:nearby()
        local available = {}
        for _, opt in ipairs(data.options) do
            if canUse(opt) then available[#available + 1] = opt end
        end

        if #available == 0 then return hide() end

        local text = ('[E] %s'):format(#available == 1 and available[1].label or (data.label or L('interact')))
        if text ~= shownText then
            lib.showTextUI(text)
            shownText = text
        end

        if IsControlJustReleased(0, 38) then
            hide()
            if #available == 1 then
                available[1].onSelect()
            else
                openOptionMenu(data.label or L('interact'), available)
            end
        end
    end

    point.onExit = hide

    return point
end

---Target on prop models (ox_target only)
function Interact.addModel(models, options)
    if not useTarget then return end
    exports.ox_target:addModel(models, toTargetOptions('sr_model', options, 2.0))
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and not useTarget then
        lib.hideTextUI()
    end
end)
