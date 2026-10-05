local function openStaffList(rid)
    local staff = lib.callback.await('silent_restaurant:server:getStaffList', false, rid) or {}
    local options = {}

    for _, member in ipairs(staff) do
        options[#options + 1] = {
            title = ('%s (#%d)'):format(member.name, member.id),
            description = ('%s • %s'):format(member.grade, member.onDuty and L('on_duty') or L('off_duty')),
            icon = 'fas fa-user',
            iconColor = member.onDuty and '#4caf50' or '#9e9e9e',
            readOnly = true,
        }
    end

    if #options == 0 then
        options[1] = { title = L('no_staff_online'), icon = 'fas fa-user-slash', readOnly = true }
    end

    lib.registerContext({
        id = 'sr_staff',
        title = L('staff_online'),
        menu = 'sr_boss',
        options = options,
    })
    lib.showContext('sr_staff')
end

local function openBossMenu(rid)
    local restaurant = Config.Restaurants[rid]
    local balance = lib.callback.await('silent_restaurant:server:getSocietyBalance', false, rid) or 0

    lib.registerContext({
        id = 'sr_boss',
        title = L('boss_title', restaurant.label),
        options = {
            {
                title = L('society_balance'),
                description = Shared.formatMoney(balance),
                icon = 'fas fa-sack-dollar',
                iconColor = '#4caf50',
                readOnly = true,
            },
            {
                title = L('manage_society'),
                description = L('manage_society_desc'),
                icon = 'fas fa-briefcase',
                disabled = GetResourceState('esx_society') ~= 'started',
                onSelect = function()
                    TriggerEvent('esx_society:openBossMenu', restaurant.job, function(_, menu)
                        menu.close()
                    end, { wash = false })
                end,
            },
            {
                title = L('staff_online'),
                icon = 'fas fa-users',
                arrow = true,
                onSelect = function() openStaffList(rid) end,
            },
            {
                title = L('announce_open_btn'),
                icon = 'fas fa-door-open',
                iconColor = '#4caf50',
                onSelect = function() TriggerServerEvent('silent_restaurant:server:announce', rid, true) end,
            },
            {
                title = L('announce_closed_btn'),
                icon = 'fas fa-door-closed',
                iconColor = '#f44336',
                onSelect = function() TriggerServerEvent('silent_restaurant:server:announce', rid, false) end,
            },
        },
    })
    lib.showContext('sr_boss')
end

Features[#Features + 1] = function(rid, restaurant)
    local boss = restaurant.boss
    if not boss then return end

    Interact.addZone({
        name = ('sr_%s_boss'):format(rid),
        coords = boss.coords,
        size = boss.size,
        rotation = boss.rotation,
        options = {
            {
                label = L('boss_menu'),
                icon = 'fas fa-user-tie',
                rid = rid,
                minGrade = boss.minGrade,
                onSelect = function() openBossMenu(rid) end,
            },
        },
    })
end
