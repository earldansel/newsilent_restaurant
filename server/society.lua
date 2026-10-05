Society = {}

local function accountName(job)
    return ('society_%s'):format(job)
end

---esx_addonaccount shared account object of a job, nil if missing
function Society.get(job)
    if GetResourceState('esx_addonaccount') ~= 'started' then return end

    local account
    TriggerEvent('esx_addonaccount:getSharedAccount', accountName(job), function(acc)
        account = acc
    end)

    return account
end

function Society.balance(job)
    local account = Society.get(job)
    return account and account.money or 0
end

---@return boolean
function Society.add(job, amount)
    local account = Society.get(job)
    if not account then return false end
    account.addMoney(amount)
    return true
end

---@return boolean
function Society.remove(job, amount)
    local account = Society.get(job)
    if not account or account.money < amount then return false end
    account.removeMoney(amount)
    return true
end

CreateThread(function()
    Wait(1000) -- give esx_addonaccount time to load its accounts

    if GetResourceState('esx_society') ~= 'started' then
        Shared.warn('esx_society is not started - boss menu & society funds will not work. Make sure it starts BEFORE silent_restaurant.')
        return
    end

    for _, restaurant in pairs(Config.Restaurants) do
        local name = accountName(restaurant.job)
        TriggerEvent('esx_society:registerSociety', restaurant.job, restaurant.label, name, name, name, { type = 'public' })

        if not Society.get(restaurant.job) then
            Shared.warn(('Society account "%s" not found. Run install/sql/jobs.sql (addon_account) and restart.'):format(name))
        end
    end
end)
