local function hasSkinchanger()
    return GetResourceState('skinchanger') == 'started' or GetResourceState('illenium-appearance') == 'started'
end

local function wearOutfit(outfit)
    TriggerEvent('skinchanger:getSkin', function(skin)
        local clothes = (skin.sex == 1) and outfit.female or outfit.male
        if clothes then
            TriggerEvent('skinchanger:loadClothes', skin, clothes)
            Client.notify(L('outfit_changed'), 'success')
        end
    end)
end

local function wearCivilian()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        if skin then
            TriggerEvent('skinchanger:loadSkin', skin)
            Client.notify(L('outfit_civilian'), 'success')
        end
    end)
end

local function openWardrobe(rid)
    local restaurant = Config.Restaurants[rid]

    if not hasSkinchanger() then
        return Client.notify(L('no_skinchanger'), 'error')
    end

    local options = {}
    for _, outfit in ipairs(restaurant.wardrobe.outfits or {}) do
        options[#options + 1] = {
            title = outfit.label,
            icon = 'fas fa-shirt',
            onSelect = function() wearOutfit(outfit) end,
        }
    end

    options[#options + 1] = {
        title = L('civilian_clothes'),
        icon = 'fas fa-user-tie',
        onSelect = wearCivilian,
    }

    lib.registerContext({
        id = 'sr_wardrobe',
        title = L('wardrobe_title', restaurant.label),
        options = options,
    })
    lib.showContext('sr_wardrobe')
end

Features[#Features + 1] = function(rid, restaurant)
    local wardrobe = restaurant.wardrobe
    if not wardrobe then return end

    Interact.addZone({
        name = ('sr_%s_wardrobe'):format(rid),
        coords = wardrobe.coords,
        size = wardrobe.size,
        rotation = wardrobe.rotation,
        options = {
            {
                label = L('wardrobe'),
                icon = 'fas fa-shirt',
                rid = rid,
                employee = true,
                onSelect = function() openWardrobe(rid) end,
            },
        },
    })
end
