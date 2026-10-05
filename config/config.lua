Config = {}

-- 'en' (English) or 'tl' (Tagalog / Taglish)
Config.Locale = 'en'

-- Shows target/zone debug boxes and extra prints. Keep false on a live server.
Config.Debug = false

-- 'target' = ox_target (recommended) | 'textui' = ox_lib TextUI + [E] key (no target needed)
-- If 'target' is selected but ox_target is not running, the script falls back to 'textui' automatically.
Config.Interaction = 'target'

-- Employees must clock in before they can use the register, kitchen, fridge, supplies, etc.
Config.RequireDuty = true

-- Max distance (meters) the server allows between a player and a station they interact with.
Config.InteractDistance = 4.0

Config.Cashier = {
    commission = 0.10,          -- 10% of every paid order goes to the cashier (0.0 to disable)
    commissionAccount = 'bank', -- 'bank' or 'money'
    paymentTimeout = 60,        -- seconds the customer has to pay a bill
    maxDistance = 5.0,          -- max distance between cashier and customer
    allowSelfBilling = false,   -- let employees bill themselves (handy for testing)
    maxQuantity = 25,           -- max quantity per menu item in one order
    methods = { cash = true, bank = true },
    refundMinGrade = 2,         -- minimum job grade to refund an order
    keepOrders = 30,            -- max orders kept per restaurant in the order screen
    callStaffCooldown = 30,     -- seconds between "Call staff" presses per customer
}

Config.Cooking = {
    maxBatch = 10,              -- max amount of a recipe made in one go
    skillCheck = true,          -- ox_lib skill check before cooking (per-recipe override: recipe.skillCheck)
    skillCheckDifficulty = { 'easy', 'easy', 'medium' },
    loseIngredientsOnFail = false, -- if false, failed skill check refunds the ingredients
}

Config.Supplies = {
    -- 'society' = paid from the restaurant society account, 'player' = paid by the employee
    payFrom = 'society',
    playerAccount = 'bank',     -- used when payFrom = 'player'
    maxQuantity = 50,
}

Config.Seats = {
    scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER',
    standKey = 73,              -- X  (https://docs.fivem.net/docs/game-references/controls/)
    standKeyLabel = 'X',
    -- Any of these props anywhere in the map become sittable (ox_target only).
    -- offset = position from the prop origin, heading = added to the prop heading
    models = {
        [`prop_chair_01a`]           = { offset = vec3(0.0, 0.0, 0.5), heading = 180.0 },
        [`prop_chair_01b`]           = { offset = vec3(0.0, 0.0, 0.5), heading = 180.0 },
        [`prop_chair_04a`]           = { offset = vec3(0.0, 0.0, 0.5), heading = 180.0 },
        [`prop_chair_05`]            = { offset = vec3(0.0, 0.0, 0.5), heading = 180.0 },
        [`prop_chair_08`]            = { offset = vec3(0.0, 0.0, 0.5), heading = 180.0 },
        [`prop_table_03b_chr`]       = { offset = vec3(0.0, 0.0, 0.5), heading = 180.0 },
        [`prop_bar_stool_01`]        = { offset = vec3(0.0, 0.0, 0.8), heading = 180.0 },
        [`v_ilev_fh_kitchenstool`]   = { offset = vec3(0.0, 0.0, 0.6), heading = 180.0 },
        [`v_corp_bk_chair3`]         = { offset = vec3(0.0, 0.0, 0.5), heading = 180.0 },
        [`prop_off_chair_01`]        = { offset = vec3(0.0, 0.0, 0.5), heading = 180.0 },
    },
}

Config.Announce = {
    cooldown = 120, -- seconds between "We are open/closed" announcements per restaurant
}

-- Filled by config/restaurants/*.lua
Config.Restaurants = {}
