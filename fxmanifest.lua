fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'silent_restaurant'
author 'Silent'
description 'All-in-one restaurant job (Burger Shot, Taco Shop, ...) for ESX Legacy + ox_inventory'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'config/restaurants/*.lua',
    'shared/locale.lua',
    'locales/*.lua',
    'shared/utils.lua',
}

client_scripts {
    'client/main.lua',
    'client/interact.lua',
    'client/duty.lua',
    'client/cashier.lua',
    'client/orders.lua',
    'client/cooking.lua',
    'client/storage.lua',
    'client/seats.lua',
    'client/wardrobe.lua',
    'client/boss.lua',
    'client/blips.lua',
    'client/init.lua',
}

server_scripts {
    'server/main.lua',
    'server/duty.lua',
    'server/society.lua',
    'server/inventory.lua',
    'server/cashier.lua',
    'server/cooking.lua',
    'server/supplies.lua',
    'server/seats.lua',
    'server/boss.lua',
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
}
