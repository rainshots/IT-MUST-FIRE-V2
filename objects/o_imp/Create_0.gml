// Initialize shared friendly combat state.
event_inherited();

// Demon sprites are scaled up for readability.
image_xscale = 2;
image_yscale = 2;

// Default possession data is replaced by the controller when transformed.
cultist_name = "Imp";
cultist_points = array_create(CULTIST_STAT.COUNT, 0);
demon_type = DEMON_TYPE.IMP;
demon_ability = cultist_ability_roll(demon_type);
current_exp = 0;
current_lvl = 1;
pending_level_points = 0;

// Demon combat stats are derived from base stats and cultist attributes.
cultist_stats_apply(id);
ability_cooldown = cultist_ability_cooldown_get(demon_ability) * room_speed;
ability_timer = ability_cooldown;
ability_active_timer = 0;
ability_duration = 0;
active_reload_multiplier = 1;
frenzy_particle_timer = 0;
blood_rage_active = false;
blood_rage_particle_timer = 0;
tracked_cannon_fire_version = -1;
base_reload_time = reload_time;
