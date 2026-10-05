--[[
    BURGER SHOT
    Coordinates are set up for the Gabz Burger Shot MLO (Vespucci / Del Perro).
    Using another MLO? Stand on the spot, type /srcoords and paste the copied vec4 here.

    Every point accepts:
        coords   = vec3 / vec4   (required)
        size     = vec3          (box zone size, default vec3(1.5, 1.5, 2.0))
        rotation = number        (box zone rotation, default 0.0)
]]

Config.Restaurants.burgershot = {
    label = 'Burger Shot',
    job = 'burgershot',           -- ESX job name (see install/sql/jobs.sql)

    blip = {
        coords = vec3(-1183.08, -884.13, 13.80),
        sprite = 106,
        color = 1,
        scale = 0.8,
    },

    -- Clock in / out
    duty = { coords = vec3(-1191.70, -900.45, 14.00), size = vec3(1.0, 1.0, 2.0), rotation = 35.0 },

    -- Boss menu (esx_society) + announcements
    boss = { coords = vec3(-1178.96, -896.62, 14.00), size = vec3(1.2, 1.2, 2.0), rotation = 35.0, minGrade = 3 },

    -- Uniform locker (needs skinchanger / esx_skin or illenium-appearance compatibility)
    wardrobe = {
        coords = vec3(-1188.40, -901.70, 14.00), size = vec3(1.2, 1.2, 2.0), rotation = 35.0,
        outfits = {
            {
                label = 'Crew Uniform',
                male = {
                    tshirt_1 = 15, tshirt_2 = 0, torso_1 = 281, torso_2 = 0, arms = 0,
                    pants_1 = 4, pants_2 = 0, shoes_1 = 1, shoes_2 = 0, helmet_1 = -1, chain_1 = 0,
                },
                female = {
                    tshirt_1 = 14, tshirt_2 = 0, torso_1 = 294, torso_2 = 0, arms = 14,
                    pants_1 = 4, pants_2 = 0, shoes_1 = 3, shoes_2 = 0, helmet_1 = -1, chain_1 = 0,
                },
            },
        },
    },

    -- Cash registers: employees ring up orders, customers can call staff
    registers = {
        { coords = vec3(-1196.05, -891.40, 14.00), size = vec3(0.7, 0.7, 0.8), rotation = 35.0 },
        { coords = vec3(-1194.71, -893.35, 14.00), size = vec3(0.7, 0.7, 0.8), rotation = 35.0 },
        { coords = vec3(-1193.39, -895.32, 14.00), size = vec3(0.7, 0.7, 0.8), rotation = 35.0 },
    },

    -- Kitchen order screens (the registers also show orders)
    orderScreens = {
        { coords = vec3(-1197.20, -896.80, 14.40), size = vec3(1.0, 0.5, 0.8), rotation = 35.0 },
    },

    -- Pick-up trays: public stashes, staff puts food in, customers take it
    trays = {
        { coords = vec3(-1195.35, -892.40, 14.00), size = vec3(0.6, 0.6, 0.5), rotation = 35.0, slots = 8, weight = 15000 },
        { coords = vec3(-1194.00, -894.35, 14.00), size = vec3(0.6, 0.6, 0.5), rotation = 35.0, slots = 8, weight = 15000 },
    },

    -- Employee-only storage
    storages = {
        { label = 'Fridge',  coords = vec3(-1202.10, -895.85, 14.00), size = vec3(1.2, 1.0, 2.0), rotation = 35.0, slots = 60, weight = 300000 },
        { label = 'Freezer', coords = vec3(-1203.60, -893.70, 14.00), size = vec3(1.2, 1.0, 2.0), rotation = 35.0, slots = 60, weight = 300000 },
    },

    -- Ingredient ordering (paid from the society by default, see Config.Supplies)
    supplies = {
        coords = vec3(-1205.40, -892.90, 14.00), size = vec3(1.2, 1.2, 2.0), rotation = 35.0,
        minGrade = 0,
        items = {
            { item = 'raw_patty',    price = 3 },
            { item = 'burger_bun',   price = 1 },
            { item = 'lettuce',      price = 1 },
            { item = 'tomato',       price = 1 },
            { item = 'cheese_slice', price = 1 },
            { item = 'onion',        price = 1 },
            { item = 'potato',       price = 1 },
            { item = 'raw_chicken',  price = 3 },
            { item = 'paper_cup',    price = 1 },
            { item = 'cola_syrup',   price = 2 },
            { item = 'orange_syrup', price = 2 },
            { item = 'milk',         price = 2 },
            { item = 'ice_cream',    price = 2 },
        },
    },

    -- Cooking stations. recipes = list of recipe ids (see `recipes` below)
    stations = {
        {
            label = 'Grill', icon = 'fas fa-fire-burner',
            coords = vec3(-1198.60, -895.30, 14.00), size = vec3(1.6, 0.8, 1.2), rotation = 35.0,
            scenario = 'PROP_HUMAN_BBQ',
            recipes = { 'cooked_patty' },
        },
        {
            label = 'Fryer', icon = 'fas fa-bowl-food',
            coords = vec3(-1201.30, -898.90, 14.00), size = vec3(1.4, 0.8, 1.2), rotation = 35.0,
            anim = { dict = 'amb@prop_human_bbq@male@base', clip = 'base' },
            recipes = { 'bs_fries', 'bs_onion_rings', 'fried_chicken' },
        },
        {
            label = 'Prep Station', icon = 'fas fa-burger',
            coords = vec3(-1197.60, -898.60, 14.00), size = vec3(1.6, 0.8, 1.2), rotation = 35.0,
            anim = { dict = 'mini@repair', clip = 'fixing_a_ped' },
            recipes = { 'raw_fries', 'bs_bleeder', 'bs_heartstopper', 'bs_moneyshot', 'bs_torpedo' },
        },
        {
            label = 'Drinks & Desserts', icon = 'fas fa-mug-hot',
            coords = vec3(-1199.00, -893.60, 14.00), size = vec3(1.4, 0.8, 1.2), rotation = 35.0,
            anim = { dict = 'mp_ped_interaction', clip = 'handshake_guy_a' },
            recipes = { 'bs_cola', 'bs_orangotang', 'bs_milkshake' },
        },
    },

    -- id = output item name (unless `item` is set). time is per unit in ms.
    recipes = {
        cooked_patty    = { amount = 1, time = 5000, ingredients = { raw_patty = 1 } },
        raw_fries       = { amount = 2, time = 3000, ingredients = { potato = 1 } },
        bs_fries        = { amount = 1, time = 4000, ingredients = { raw_fries = 1 } },
        bs_onion_rings  = { amount = 1, time = 4000, ingredients = { onion = 1 } },
        fried_chicken   = { amount = 1, time = 5000, ingredients = { raw_chicken = 1 } },
        bs_bleeder      = { amount = 1, time = 4000, ingredients = { burger_bun = 1, cooked_patty = 1, lettuce = 1, tomato = 1 } },
        bs_heartstopper = { amount = 1, time = 5000, ingredients = { burger_bun = 1, cooked_patty = 2, cheese_slice = 2, tomato = 1 } },
        bs_moneyshot    = { amount = 1, time = 4000, ingredients = { burger_bun = 1, cooked_patty = 1, cheese_slice = 1 } },
        bs_torpedo      = { amount = 1, time = 4000, ingredients = { burger_bun = 1, fried_chicken = 1, lettuce = 1 } },
        bs_cola         = { amount = 1, time = 2500, ingredients = { paper_cup = 1, cola_syrup = 1 }, skillCheck = false },
        bs_orangotang   = { amount = 1, time = 2500, ingredients = { paper_cup = 1, orange_syrup = 1 }, skillCheck = false },
        bs_milkshake    = { amount = 1, time = 3500, ingredients = { paper_cup = 1, milk = 1, ice_cream = 1 } },
    },

    -- What the cashier can sell (price per unit)
    menu = {
        { item = 'bs_bleeder',      price = 12 },
        { item = 'bs_heartstopper', price = 18 },
        { item = 'bs_moneyshot',    price = 10 },
        { item = 'bs_torpedo',      price = 12 },
        { item = 'bs_fries',        price = 5 },
        { item = 'bs_onion_rings',  price = 5 },
        { item = 'bs_cola',         price = 4 },
        { item = 'bs_orangotang',   price = 4 },
        { item = 'bs_milkshake',    price = 7 },
    },

    -- Fixed seats (vec4 = x, y, z, heading the player faces while seated)
    seats = {
        vec4(-1186.10, -883.30, 13.40, 305.0),
        vec4(-1184.60, -885.40, 13.40, 305.0),
        vec4(-1183.10, -887.60, 13.40, 305.0),
        vec4(-1189.20, -879.90, 13.40, 125.0),
        vec4(-1187.70, -882.00, 13.40, 125.0),
    },
}
