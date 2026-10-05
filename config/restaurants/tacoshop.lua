--[[
    TACO SHOP
    Example coordinates (Strawberry - Taco Bomb exterior). Replace them with the coordinates of your MLO:
    stand on the spot, type /srcoords and paste the copied vec4 here.
]]

Config.Restaurants.tacoshop = {
    label = 'Taco Shop',
    job = 'tacoshop',

    blip = {
        coords = vec3(10.60, -1605.40, 29.38),
        sprite = 79,
        color = 47,
        scale = 0.8,
    },

    duty = { coords = vec3(12.90, -1599.20, 29.38), size = vec3(1.0, 1.0, 2.0), rotation = 50.0 },

    boss = { coords = vec3(15.20, -1597.10, 29.38), size = vec3(1.2, 1.2, 2.0), rotation = 50.0, minGrade = 3 },

    wardrobe = {
        coords = vec3(14.00, -1601.40, 29.38), size = vec3(1.2, 1.2, 2.0), rotation = 50.0,
        outfits = {
            {
                label = 'Taco Uniform',
                male = {
                    tshirt_1 = 15, tshirt_2 = 0, torso_1 = 146, torso_2 = 2, arms = 0,
                    pants_1 = 10, pants_2 = 0, shoes_1 = 7, shoes_2 = 0, helmet_1 = -1, chain_1 = 0,
                },
                female = {
                    tshirt_1 = 14, tshirt_2 = 0, torso_1 = 9, torso_2 = 4, arms = 14,
                    pants_1 = 6, pants_2 = 0, shoes_1 = 3, shoes_2 = 0, helmet_1 = -1, chain_1 = 0,
                },
            },
        },
    },

    registers = {
        { coords = vec3(9.30, -1604.10, 29.38), size = vec3(0.7, 0.7, 0.8), rotation = 50.0 },
    },

    orderScreens = {
        { coords = vec3(11.80, -1602.70, 29.80), size = vec3(1.0, 0.5, 0.8), rotation = 50.0 },
    },

    trays = {
        { coords = vec3(8.40, -1605.20, 29.38), size = vec3(0.6, 0.6, 0.5), rotation = 50.0, slots = 8, weight = 15000 },
    },

    storages = {
        { label = 'Fridge', coords = vec3(13.80, -1604.20, 29.38), size = vec3(1.2, 1.0, 2.0), rotation = 50.0, slots = 60, weight = 300000 },
    },

    supplies = {
        coords = vec3(16.40, -1603.00, 29.38), size = vec3(1.2, 1.2, 2.0), rotation = 50.0,
        minGrade = 0,
        items = {
            { item = 'tortilla',     price = 1 },
            { item = 'ground_beef',  price = 3 },
            { item = 'raw_chicken',  price = 3 },
            { item = 'lettuce',      price = 1 },
            { item = 'tomato',       price = 1 },
            { item = 'onion',        price = 1 },
            { item = 'cheese_slice', price = 1 },
            { item = 'beans',        price = 1 },
            { item = 'rice',         price = 1 },
            { item = 'milk',         price = 2 },
            { item = 'paper_cup',    price = 1 },
            { item = 'cola_syrup',   price = 2 },
        },
    },

    stations = {
        {
            label = 'Flat Top Grill', icon = 'fas fa-fire-burner',
            coords = vec3(11.20, -1601.10, 29.38), size = vec3(1.6, 0.8, 1.2), rotation = 50.0,
            scenario = 'PROP_HUMAN_BBQ',
            recipes = { 'cooked_beef', 'cooked_chicken', 'ts_quesadilla' },
        },
        {
            label = 'Prep Station', icon = 'fas fa-pepper-hot',
            coords = vec3(12.60, -1603.40, 29.38), size = vec3(1.6, 0.8, 1.2), rotation = 50.0,
            anim = { dict = 'mini@repair', clip = 'fixing_a_ped' },
            recipes = { 'salsa', 'ts_beef_taco', 'ts_chicken_taco', 'ts_burrito', 'ts_nachos' },
        },
        {
            label = 'Drinks', icon = 'fas fa-mug-hot',
            coords = vec3(10.10, -1602.40, 29.38), size = vec3(1.2, 0.8, 1.2), rotation = 50.0,
            anim = { dict = 'mp_ped_interaction', clip = 'handshake_guy_a' },
            recipes = { 'ts_horchata', 'ts_soda' },
        },
    },

    recipes = {
        cooked_beef     = { amount = 1, time = 5000, ingredients = { ground_beef = 1 } },
        cooked_chicken  = { amount = 1, time = 5000, ingredients = { raw_chicken = 1 } },
        salsa           = { amount = 2, time = 3000, ingredients = { tomato = 1, onion = 1 } },
        ts_beef_taco    = { amount = 1, time = 3500, ingredients = { tortilla = 1, cooked_beef = 1, lettuce = 1, salsa = 1 } },
        ts_chicken_taco = { amount = 1, time = 3500, ingredients = { tortilla = 1, cooked_chicken = 1, lettuce = 1, salsa = 1 } },
        ts_burrito      = { amount = 1, time = 5000, ingredients = { tortilla = 1, cooked_chicken = 1, rice = 1, beans = 1 } },
        ts_quesadilla   = { amount = 1, time = 4000, ingredients = { tortilla = 1, cheese_slice = 2 } },
        ts_nachos       = { amount = 1, time = 4000, ingredients = { tortilla = 1, cheese_slice = 1, salsa = 1 } },
        ts_horchata     = { amount = 1, time = 3000, ingredients = { paper_cup = 1, rice = 1, milk = 1 }, skillCheck = false },
        ts_soda         = { amount = 1, time = 2500, ingredients = { paper_cup = 1, cola_syrup = 1 }, skillCheck = false },
    },

    menu = {
        { item = 'ts_beef_taco',    price = 8 },
        { item = 'ts_chicken_taco', price = 8 },
        { item = 'ts_burrito',      price = 12 },
        { item = 'ts_quesadilla',   price = 9 },
        { item = 'ts_nachos',       price = 7 },
        { item = 'ts_horchata',     price = 5 },
        { item = 'ts_soda',         price = 4 },
    },

    seats = {
        vec4(5.90, -1608.10, 28.90, 230.0),
        vec4(7.10, -1609.50, 28.90, 230.0),
    },
}
