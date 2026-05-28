// Initialize shared friendly combat state.
event_inherited();

// Demon sprites are scaled up for readability.
image_xscale = 2;
image_yscale = 2;

// Default possession data is replaced by the controller when transformed.
cultist_name = "Brute";
cultist_points = array_create(CULTIST_STAT.COUNT, 0);
demon_type = DEMON_TYPE.BRUTE;
demon_ability = cultist_ability_roll(demon_type);
current_exp = 0;
current_lvl = 1;
pending_level_points = 0;

// Demon combat stats are derived from base stats and cultist attributes.
cultist_stats_apply(id);
ability_cooldown = cultist_ability_cooldown_get(demon_ability) * room_speed;
ability_timer = ability_cooldown;
poison_aura_radius = BALANCE_ABILITY_BRUTE_POISON_AURA_RADIUS;
poison_tick_timer = BALANCE_ABILITY_BRUTE_POISON_TICK_TIME * room_speed;
mega_strike_ready = false;
