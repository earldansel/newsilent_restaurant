# silent_restaurant

An all-in-one restaurant job for **ESX Legacy + ox_inventory + ox_lib** (+ ox_target).
It ships with **Burger Shot** and a **Taco Shop**. You can add more restaurants (pizza, coffee shop, noodle bar, …) by copying one config file.

## Features

| Feature | Description |
|---|---|
| **Duty** | Clock in and out. On-duty status is synced with state bags, and employees are clocked out automatically when their job changes or they disconnect. |
| **Cash register** | The cashier rings up an order from the menu, picks a nearby customer, and the customer chooses to pay by **cash** or **card** (or declines). |
| **Commission** | The cashier gets a % of every order, and the rest goes to the society account (`esx_society`). |
| **Order screen (KDS)** | Live list of paid orders. Staff can mark an order **Ready** (the customer is notified), **Complete** it, or **Refund** it (manager and up). |
| **Call staff** | Customers can ring the bell at the register, and all on-duty staff get notified. |
| **Cooking** | Multi-step recipes, for example raw patty → grill → cooked patty → prep → burger. Includes batch cooking, a progress bar with animations, an optional skill check, and a refund on cancel. |
| **Trays** | Public `ox_inventory` stashes. Staff drop the food in, customers take it out. |
| **Fridge/Freezer** | Employee-only `ox_inventory` stashes (on duty only). |
| **Supplies** | Order ingredients, paid from the **society account** (or by the employee, configurable). |
| **Seating** | Customers can sit on fixed seats and on common chair props anywhere in the map. Seats are reserved on the server so two people can't share one. |
| **Food & drinks** | Real hunger and thirst through `esx_status`, with eating and drinking animations and props (handled by ox_inventory). |
| **Wardrobe** | Work uniform (male/female) and civilian clothes (`skinchanger` / `esx_skin`). |
| **Boss menu** | `esx_society` (hire, fire, salaries, money), society balance, staff list, and server-wide **OPEN/CLOSED** announcements. |
| **Blip** | Shows **Open** or **Closed** depending on whether staff are on duty. |
| **Interaction** | `ox_target` or ox_lib **TextUI [E]**. If ox_target is missing, it falls back to TextUI automatically. |
| **Languages** | English and Tagalog (`Config.Locale = 'tl'`). |
| **Security** | Every action is validated on the server: job, grade, duty, distance, prices and recipes all come from the config. The server also rejects instant cook finishes and fake items. |

## Requirements

- [es_extended](https://github.com/esx-framework/esx_core) (ESX Legacy)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target) *(recommended, optional)*
- esx_society + esx_addonaccount *(society money / boss menu)*
- skinchanger + esx_skin *(optional, wardrobe)*
- esx_status / esx_basicneeds *(hunger/thirst)*

## Installation

1. Put the `silent_restaurant` folder in your `resources` folder.
2. **SQL:** run `install/sql/jobs.sql` once. It creates the `burgershot` and `tacoshop` jobs with 4 grades (grade 3 = `boss`) and the society accounts.
3. **Items:** copy the entries from `install/ox_inventory_items.lua` into `ox_inventory/data/items.lua`.
   Put images (`<item_name>.png`) in `ox_inventory/web/images/`.
   If an item name already exists (for example `milk` or `tomato`), keep only one of them.
4. **server.cfg**: start the resource *after* its dependencies:
   ```cfg
   ensure oxmysql
   ensure es_extended
   ensure ox_lib
   ensure ox_inventory
   ensure ox_target
   ensure esx_addonaccount
   ensure esx_society
   ensure silent_restaurant
   ```
5. Restart the server, then give yourself the job: `/setjob [id] burgershot 3`.

## Setting up coordinates (MLO)

The Burger Shot coordinates are set up for the **Gabz Burger Shot** MLO. The Taco Shop coordinates are examples only.
To change them:

1. Stand on the spot (the register, grill, chair, …).
2. Type **`/srcoords`**. The `vec4(...)` is copied to your clipboard.
3. Paste it into `config/restaurants/<restaurant>.lua`.

Set `Config.Debug = true` to see the target boxes in-game.

## How it works

```
Employee: Clock in ─► Order supplies ─► Fridge ─► Cook (grill/fryer/prep/drinks)
Customer: Goes to the register ─► Cashier "Ring up order" ─► Customer pays (cash/card)
          ─► Order appears on the Order Screen ─► Staff cooks & puts food in the Tray
          ─► "Mark as ready" (customer is notified) ─► Customer takes food from the Tray
          ─► Sits down & eats (hunger/thirst)
```

## Adding a new restaurant (for example Pizza)

1. Copy `config/restaurants/tacoshop.lua` → `config/restaurants/pizzeria.lua`.
2. Change `Config.Restaurants.tacoshop` → `Config.Restaurants.pizzeria`, then set the `label`, `job`, coordinates, `recipes`, `menu` and `supplies`.
3. Add the job and society to the database (copy the Taco Shop block in `jobs.sql` and change the names).
4. Add the new items to ox_inventory.

The new file is loaded automatically (`config/restaurants/*.lua`).

## Main config (`config/config.lua`)

| Option | Default | Description |
|---|---|---|
| `Locale` | `'en'` | `'en'` or `'tl'` |
| `Interaction` | `'target'` | `'target'` (ox_target) or `'textui'` |
| `RequireDuty` | `true` | Employees must be clocked in to work |
| `Cashier.commission` | `0.10` | Cashier commission (10%) |
| `Cashier.methods` | cash + bank | Payment methods |
| `Cashier.refundMinGrade` | `2` | Minimum grade to refund an order |
| `Cooking.skillCheck` | `true` | Skill check before cooking |
| `Cooking.loseIngredientsOnFail` | `false` | Whether a failed skill check loses the ingredients |
| `Supplies.payFrom` | `'society'` | `'society'` or `'player'` |
| `Seats.models` | chair list | Chair props anywhere in the map that players can sit on |

## Files

```
config/config.lua               main settings
config/restaurants/*.lua        one file per restaurant
locales/en.lua, locales/tl.lua  translations
shared/                         locale + helpers + config validation
client/                         interact layer, duty, cashier, orders, cooking, storage, seats, wardrobe, boss, blips
server/                         duty, society, stashes, cashier/orders, cooking, supplies, seats, boss
install/                        SQL + ox_inventory items
```
