// The Cannon is the destroyable objective for every fight.
image_speed = 0;
y_sort_enabled = true;
is_attackable = true;
max_hp = BALANCE_CANNON_MAX_HP;
hp = max_hp;
combat_radius = BALANCE_CANNON_COMBAT_RADIUS;
armor = 100;
magic_resistance = 100;
building_accepts_workers = false;
building_has_upgrades = false;
// Compatibility ownership also makes the Cannon a starting sight source.
faction = global.player_faction;
vision_radius = BALANCE_FACTION_BASE_REVEAL_RADIUS;

// Retired gameplay object; initialize cleanup fields before removing any legacy instance.
instance_destroy();
