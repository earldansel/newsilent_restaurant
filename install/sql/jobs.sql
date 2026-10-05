-- silent_restaurant - ESX Legacy jobs + society accounts
-- Run ONCE in your database (running it twice duplicates the job_grades rows).
-- esx_addonaccount creates the addon_account_data rows automatically on start.
-- Grade 3 must be named "boss" for esx_society.

-- ==================== BURGER SHOT ====================
INSERT IGNORE INTO `jobs` (`name`, `label`) VALUES ('burgershot', 'Burger Shot');

INSERT IGNORE INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
    ('burgershot', 0, 'trainee', 'Trainee', 150, '{}', '{}'),
    ('burgershot', 1, 'cook',    'Cook',    250, '{}', '{}'),
    ('burgershot', 2, 'manager', 'Manager', 350, '{}', '{}'),
    ('burgershot', 3, 'boss',    'Owner',   500, '{}', '{}');

INSERT IGNORE INTO `addon_account` (`name`, `label`, `shared`) VALUES ('society_burgershot', 'Burger Shot', 1);
INSERT IGNORE INTO `addon_inventory` (`name`, `label`, `shared`) VALUES ('society_burgershot', 'Burger Shot', 1);
INSERT IGNORE INTO `datastore` (`name`, `label`, `shared`) VALUES ('society_burgershot', 'Burger Shot', 1);

-- ==================== TACO SHOP ====================
INSERT IGNORE INTO `jobs` (`name`, `label`) VALUES ('tacoshop', 'Taco Shop');

INSERT IGNORE INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
    ('tacoshop', 0, 'trainee', 'Trainee', 150, '{}', '{}'),
    ('tacoshop', 1, 'cook',    'Cook',    250, '{}', '{}'),
    ('tacoshop', 2, 'manager', 'Manager', 350, '{}', '{}'),
    ('tacoshop', 3, 'boss',    'Owner',   500, '{}', '{}');

INSERT IGNORE INTO `addon_account` (`name`, `label`, `shared`) VALUES ('society_tacoshop', 'Taco Shop', 1);
INSERT IGNORE INTO `addon_inventory` (`name`, `label`, `shared`) VALUES ('society_tacoshop', 'Taco Shop', 1);
INSERT IGNORE INTO `datastore` (`name`, `label`, `shared`) VALUES ('society_tacoshop', 'Taco Shop', 1);
